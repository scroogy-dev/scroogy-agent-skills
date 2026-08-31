#!/usr/bin/env bash
#
# verify-submit.sh — PR 제출 직전 가드를 결정적으로 판정한다.
#
# SKILL.md "PR 제출" 1·4단계가 규격의 SSoT 다. 세 가지를 명령으로 옮긴다.
#   - 원격 URL 을 `호스트/소유자/저장소` 로 정규화 (승인한 대상 저장소와 대조하기 위함)
#   - 로컬 브랜치 head 가 승인한 SHA 와 같은지
#   - 원격 브랜치 head 가 승인한 SHA 와 같은지, 그리고 `ls-remote` 출력이 정확히 1행인지
#
# `ls-remote` 의 ref 인자는 tail 패턴이라 짧은 `main` 은 `refs/heads/feature/main` 까지 함께 받는다.
# 그래서 조회를 완전한 `refs/heads/<브랜치>` 로 해 다중 매칭을 막고, 행 수 검사로 그래도 남는 경우를 걸러낸다.
#
# 사용법:
#   verify-submit.sh --normalize <원격 URL>
#   verify-submit.sh --branch <브랜치> --expect <SHA>                    # 로컬 head 대조
#   verify-submit.sh --remote <원격> --branch <브랜치> --expect <SHA>    # 원격 head 대조
#
# 옵션:
#   --normalize <URL>  URL 을 정규화해 표준 출력에 낸다 (다른 모드와 함께 쓸 수 없음).
#   --remote <이름>    원격 **이름**을 넘긴다. URL 을 직접 넘기면 remote-tracking ref 가 만들어지지 않아
#                      이후 `@{u}` 해석이 깨지므로, SKILL.md 와 같게 이름으로만 조회한다.
#   --branch <이름>    브랜치 이름. 조회는 항상 완전한 ref(`refs/heads/<이름>`)로 한다.
#   --expect <SHA>     승인받은 커밋 SHA. 축약형도 받되 짧은 쪽 길이만큼 앞에서 비교한다.
#
# 종료 코드: 0 통과(정규화는 값 출력, 대조는 무출력) / 1 불일치·다중 ref / 2 사용오류

set -o pipefail

usage() { sed -n '3,26p' "$0" | sed 's/^# \{0,1\}//'; }

# normalize <URL> — `호스트/소유자/저장소` 를 출력한다. 파싱 실패는 종료 코드 1.
normalize() {
  local url="$1" rest host path
  case "$url" in
    *://*)  rest="${url#*://}" ;;
    *:*/*)  rest="${url%%:*}/${url#*:}" ;;   # scp 문법 — git@host:owner/repo
    *)      return 1 ;;
  esac

  host="${rest%%/*}"
  path="${rest#*/}"
  [ "$host" != "$rest" ] || return 1         # `/` 가 없으면 경로가 없다

  host="${host#*@}"                          # user@ 제거
  host="${host%%:*}"                         # 포트 제거
  path="${path%/}"                           # 후행 슬래시
  path="${path%.git}"

  case "$host" in '' ) return 1 ;; esac
  case "$path" in */*) ;; *) return 1 ;; esac   # 최소 `소유자/저장소` 2단

  printf '%s/%s\n' "$host" "$path"
}

mode=''
url=''
remote=''
branch=''
expect=''

while [ $# -gt 0 ]; do
  case "$1" in
    --normalize)
      [ $# -ge 2 ] || { echo "error: --normalize 에 값이 필요합니다" >&2; exit 2; }
      mode='normalize'; url="$2"; shift 2 ;;
    --remote)
      [ $# -ge 2 ] || { echo "error: --remote 에 값이 필요합니다" >&2; exit 2; }
      remote="$2"; shift 2 ;;
    --branch)
      [ $# -ge 2 ] || { echo "error: --branch 에 값이 필요합니다" >&2; exit 2; }
      branch="$2"; shift 2 ;;
    --expect)
      [ $# -ge 2 ] || { echo "error: --expect 에 값이 필요합니다" >&2; exit 2; }
      expect="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: 알 수 없는 인자 — $1" >&2; exit 2 ;;
  esac
done

if [ "$mode" = 'normalize' ]; then
  if [ -n "$remote" ] || [ -n "$branch" ] || [ -n "$expect" ]; then
    echo "error: --normalize 는 다른 옵션과 함께 쓸 수 없습니다" >&2; exit 2
  fi
  if ! normalize "$url"; then
    echo "위반: 원격 URL 을 '호스트/소유자/저장소' 로 정규화할 수 없습니다 — $url"
    exit 1
  fi
  exit 0
fi

if [ -z "$branch" ] || [ -z "$expect" ]; then
  echo "error: --branch 와 --expect 가 모두 필요합니다" >&2
  usage >&2
  exit 2
fi
command -v git >/dev/null 2>&1 || { echo "error: git 을 찾을 수 없습니다" >&2; exit 2; }

# 축약 SHA 를 승인값으로 받아도 대조가 성립하도록 짧은 쪽 길이로 자른다.
# 긴 쪽을 자르지 않고 문자열 동일성만 보면 승인 화면의 축약 표기가 매번 불일치로 떨어진다.
same_sha() {
  local a="$1" b="$2" n
  n=${#a}; [ ${#b} -lt "$n" ] && n=${#b}
  [ "$n" -ge 7 ] || return 2
  [ "${a:0:n}" = "${b:0:n}" ]
}

case "$expect" in
  *[!0-9a-fA-F]*|'') echo "error: --expect 가 SHA 형식이 아닙니다 — $expect" >&2; exit 2 ;;
esac
[ ${#expect} -ge 7 ] || { echo "error: --expect 가 너무 짧습니다(7자 이상) — $expect" >&2; exit 2; }

if [ -z "$remote" ]; then
  actual="$(git rev-parse "refs/heads/$branch" 2>/dev/null)" || {
    echo "위반: 로컬 브랜치를 찾을 수 없습니다 — refs/heads/$branch"
    exit 1
  }
  if same_sha "$actual" "$expect"; then exit 0; fi
  echo "위반: 로컬 head 가 승인한 SHA 와 다릅니다 — 승인 [$expect] 실제 [$actual]"
  exit 1
fi

out="$(git ls-remote --heads "$remote" "refs/heads/$branch" 2>/dev/null)" || {
  echo "위반: 원격을 조회할 수 없습니다 — $remote"
  exit 1
}

lines="$(printf '%s' "$out" | grep -c .)"
if [ "$lines" -eq 0 ]; then
  echo "위반: 원격에 브랜치가 없습니다 — $remote refs/heads/$branch"
  exit 1
fi
if [ "$lines" -ne 1 ]; then
  echo "위반: ls-remote 출력이 ${lines}행입니다 — ref 패턴이 여러 브랜치에 걸렸습니다"
  printf '%s\n' "$out"
  exit 1
fi

actual="$(printf '%s\n' "$out" | awk '{print $1}')"
if same_sha "$actual" "$expect"; then exit 0; fi
echo "위반: 원격 head 가 승인한 SHA 와 다릅니다 — 승인 [$expect] 실제 [$actual]"
exit 1
