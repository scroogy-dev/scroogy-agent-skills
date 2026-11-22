#!/usr/bin/env bash
#
# resolve-target.sh — git-review 대상 수집 1단계의 저장소 대조를 결정적으로 판정한다.
#
# SKILL.md "## 대상 수집"의 "1단계: 대상 식별"이 규칙의 SSoT 이며 이 스크립트는 그것을 옮긴 사본이다.
# PR 링크나 PR 번호와 원격 URL 을 받아, 링크의 저장소가 원격 저장소와 같으면 대상 저장소와 PR 번호를 낸다.
# 링크의 저장소가 원격 저장소와 다르면 리뷰를 시작하지 않도록 종료 코드 1 로 알린다.
#
# 원격 URL 정규화(normalize)는 git-pr/scripts/verify-submit.sh 의 normalize 함수를 옮긴 사본이다
# (git-pr-feedback/scripts/verify-push.sh 도 같은 규칙의 사본을 둔다). 스킬 독립성 원칙(단독 실행·단독 설치)상
# 헬퍼를 공유하지 않는다. 한쪽 정규화 규칙을 고치면 다른 쪽도 함께 고친다.
#
# 외부 명령(git, gh)을 부르지 않는다. 원격 URL 은 호출하는 쪽이 넘긴다.
#
# 사용법:
#   resolve-target.sh --remote-url <원격 URL> --pr <PR 링크|PR 번호>
#
# 옵션:
#   --remote-url <URL>  `https://호스트/소유자/저장소(.git)`, `ssh://…`, scp 형식(`git@호스트:소유자/저장소.git`)
#   --pr <값>           PR 링크 `http(s)://<호스트>/<소유자>/<저장소>/pull/<숫자>` 또는 PR 번호 `<숫자>`·`#<숫자>`.
#                       링크에서 숫자 뒤의 `/files`·`/commits/…`·`?…`·`#…`는 버린다.
#
# 출력: 종료 코드 0 이면 표준 출력에 `<호스트>/<소유자>/<저장소> <PR 번호>` 1행을 낸다.
#       저장소 표기는 원격 URL 에서 얻은 값이다. 저장소 비교는 호스트·소유자·저장소를 대소문자 구분 없이 한다.
#
# 종료 코드: 0 대상 확정 / 1 PR 링크의 저장소(호스트 포함)가 원격 저장소와 다름 /
#            2 사용오류(옵션 누락·중복·알 수 없는 인자, 원격 URL 정규화 실패, PR 링크·번호 형식 아님).
#            1·2 에서는 표준 출력에 아무것도 쓰지 않고 사유를 표준 오류에 1행으로 쓴다.
#
# 사유에는 입력 값(원격 URL·PR 값·알 수 없는 인자)의 원문을 넣지 않는다. 어느 입력이 틀렸는지와 기대 형식만 적는다.
# 원격 URL 에 든 자격 증명(`사용자:토큰@`)이 오류 출력에 남지 않게 하기 위해서다. 종료 코드 1 의 두 저장소는
# 사용자 정보를 지운 정규화 표기이고, 알 수 없는 인자는 옵션 이름 형식(`--` 뒤 영소문자·`-`)일 때만 이름을 적는다
# (이슈 #142 최종 감사 4차 F-14, .ai/30_contract/github-integration.md 의 userinfo 제거 규칙).

set -o pipefail

# fail <사유> <종료 코드> — 사유를 표준 오류에 1행으로 쓰고 끝낸다.
fail() { printf 'resolve-target.sh: %s\n' "$1" >&2; exit "$2"; }

# normalize <URL> — `호스트/소유자/저장소` 를 출력한다. 파싱 실패는 종료 코드 1.
# git-pr/scripts/verify-submit.sh 의 normalize 와 같은 규칙이다 (헤더 주석 참조).
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

lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

remote_url='' pr='' has_remote=0 has_pr=0 argc=$#
while [ $# -gt 0 ]; do
  case "$1" in
    --remote-url)
      [ "$has_remote" = 0 ] || fail '--remote-url 이 두 번 왔다' 2
      [ $# -ge 2 ] || fail '--remote-url 의 값이 없다' 2
      remote_url="$2"; has_remote=1; shift 2 ;;
    --pr)
      [ "$has_pr" = 0 ] || fail '--pr 이 두 번 왔다' 2
      [ $# -ge 2 ] || fail '--pr 의 값이 없다' 2
      pr="$2"; has_pr=1; shift 2 ;;
    *)
      if [[ $1 =~ ^--[a-z][a-z-]*$ ]]; then fail "알 수 없는 옵션: $1" 2; fi
      fail "알 수 없는 인자가 $((argc - $# + 1))번째에 있다 (값은 적지 않는다)" 2 ;;
  esac
done
[ "$has_remote" = 1 ] || fail '--remote-url 이 없다' 2
[ "$has_pr" = 1 ] || fail '--pr 이 없다' 2

remote="$(normalize "$remote_url")" \
  || fail '--remote-url 값을 정규화할 수 없다 (기대 형식: https://호스트/소유자/저장소, ssh://…, git@호스트:소유자/저장소)' 2

num_re='^#?([0-9]+)$'
# 링크는 소문자로 바꾼 뒤 읽는다. 저장소 비교가 대소문자를 가리지 않고, 출력의 저장소 표기는 원격 URL 에서 얻는다.
link_re='^https?://([^/?#]+)/([^?#]+)/pull/([0-9]+)([/?#].*)?$'
repo_re='^[^/]+(/[^/]+)+$'
link="$(lower "$pr")"

if [[ $pr =~ $num_re ]]; then
  n="${BASH_REMATCH[1]}"
elif [[ $link =~ $link_re ]]; then
  host="${BASH_REMATCH[1]}"; path="${BASH_REMATCH[2]}"; n="${BASH_REMATCH[3]}"
  host="${host#*@}"                          # user@ 제거 (원격 URL 정규화와 같은 규칙)
  host="${host%%:*}"                         # 포트 제거
  [ -n "$host" ] && [[ $path =~ $repo_re ]] \
    || fail '--pr 값이 PR 링크 형식이 아니다 (기대 형식: http(s)://호스트/소유자/저장소/pull/숫자)' 2
  linked="${host}/${path}"
  [ "$linked" = "$(lower "$remote")" ] \
    || fail "PR 링크의 저장소(${linked})가 원격 저장소(${remote})와 다르다" 1
else
  fail '--pr 값이 PR 링크나 PR 번호 형식이 아니다 (기대 형식: PR 링크, 숫자, #숫자)' 2
fi

n="$(printf '%s' "$n" | sed 's/^0*//')"
[ -n "$n" ] || fail '--pr 값의 PR 번호가 0 이다' 2

printf '%s %s\n' "$remote" "$n"
