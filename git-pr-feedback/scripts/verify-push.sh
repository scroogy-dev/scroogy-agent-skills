#!/usr/bin/env bash
#
# verify-push.sh — 리뷰 대응 push 직전 가드를 결정적으로 판정한다.
#
# SKILL.md "코드 변경" 절의 push 승인·실행 규칙이 SSoT 이며 이 스크립트는 그것을 옮긴 사본이다.
# 네 가지를 한 번에 본다.
#   1. fetch URL 의 정규화 결과가 보관한 head 저장소와 같은가
#   2. push URL 이 정확히 1개이고 그 정규화 결과도 head 저장소와 같은가
#   3. 원격 ref 의 현재 SHA 가 보관한 headRefOid 와 같은가 (없으면 삭제된 것)
#   4. 승인 SHA 가 headRefOid 를 조상으로 포함하는가 (lease 가 성립하면 전진 push 임을 보장)
#
# `remote.<이름>.pushurl` 은 fetch URL 과 다르게 복수로도 설정되고 `git push` 는 push URL 전부에 게시한다.
# fetch URL 만 보면 승인은 PR 저장소 기준으로 받고 실제 push 는 다른 저장소로도 나간다.
#
# git-pr 의 verify-submit.sh 와 URL 정규화가 겹치나 스킬 독립성 원칙(단독 실행·단독 설치)상
# 헬퍼를 공유하지 않는다. 한쪽 정규화 규칙을 고치면 다른 쪽도 함께 고친다.
#
# 사용법:
#   verify-push.sh --normalize <URL>
#   verify-push.sh --remote <원격 이름> --repo <호스트/소유자/저장소> \
#                  --branch <승인 대상 브랜치> --head-oid <headRefOid> --approved-sha <승인 SHA>
#
# 종료 코드: 0 통과(정규화는 값 출력, 대조는 무출력) / 1 위반(사유를 1행씩 출력) / 2 사용오류

set -o pipefail

usage() { sed -n '3,26p' "$0" | sed 's/^# \{0,1\}//'; }

normalize() {
  local url="$1" rest host path
  case "$url" in
    *://*)  rest="${url#*://}" ;;
    *:*/*)  rest="${url%%:*}/${url#*:}" ;;   # scp 문법 — git@host:owner/repo
    *)      return 1 ;;
  esac

  host="${rest%%/*}"
  path="${rest#*/}"
  [ "$host" != "$rest" ] || return 1

  host="${host#*@}"
  host="${host%%:*}"
  path="${path%/}"
  path="${path%.git}"

  case "$host" in '' ) return 1 ;; esac
  case "$path" in */*) ;; *) return 1 ;; esac

  printf '%s/%s\n' "$host" "$path"
}

mode=''
url=''
remote=''
repo=''
branch=''
head_oid=''
approved=''

while [ $# -gt 0 ]; do
  case "$1" in
    --normalize)
      [ $# -ge 2 ] || { echo "error: --normalize 에 값이 필요합니다" >&2; exit 2; }
      mode='normalize'; url="$2"; shift 2 ;;
    --remote)
      [ $# -ge 2 ] || { echo "error: --remote 에 값이 필요합니다" >&2; exit 2; }
      remote="$2"; shift 2 ;;
    --repo)
      [ $# -ge 2 ] || { echo "error: --repo 에 값이 필요합니다" >&2; exit 2; }
      repo="$2"; shift 2 ;;
    --branch)
      [ $# -ge 2 ] || { echo "error: --branch 에 값이 필요합니다" >&2; exit 2; }
      branch="$2"; shift 2 ;;
    --head-oid)
      [ $# -ge 2 ] || { echo "error: --head-oid 에 값이 필요합니다" >&2; exit 2; }
      head_oid="$2"; shift 2 ;;
    --approved-sha)
      [ $# -ge 2 ] || { echo "error: --approved-sha 에 값이 필요합니다" >&2; exit 2; }
      approved="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: 알 수 없는 인자 — $1" >&2; exit 2 ;;
  esac
done

if [ "$mode" = 'normalize' ]; then
  if [ -n "$remote" ] || [ -n "$repo" ] || [ -n "$branch" ] || [ -n "$head_oid" ] || [ -n "$approved" ]; then
    echo "error: --normalize 는 다른 옵션과 함께 쓸 수 없습니다" >&2; exit 2
  fi
  if ! normalize "$url"; then
    echo "위반: 원격 URL 을 '호스트/소유자/저장소' 로 정규화할 수 없습니다 — $url"
    exit 1
  fi
  exit 0
fi

for pair in "--remote:$remote" "--repo:$repo" "--branch:$branch" "--head-oid:$head_oid" "--approved-sha:$approved"; do
  case "${pair#*:}" in
    '') echo "error: ${pair%%:*} 가 필요합니다" >&2; usage >&2; exit 2 ;;
  esac
done
command -v git >/dev/null 2>&1 || { echo "error: git 을 찾을 수 없습니다" >&2; exit 2; }

for s in "$head_oid" "$approved"; do
  case "$s" in
    *[!0-9a-fA-F]*) echo "error: SHA 형식이 아닙니다 — $s" >&2; exit 2 ;;
  esac
  [ ${#s} -ge 7 ] || { echo "error: SHA 가 너무 짧습니다(7자 이상) — $s" >&2; exit 2; }
done

violations=0
ng() { echo "위반: $1"; violations=$((violations + 1)); }

same_sha() {
  local a="$1" b="$2" n
  n=${#a}; [ ${#b} -lt "$n" ] && n=${#b}
  [ "$n" -ge 7 ] || return 1
  [ "${a:0:n}" = "${b:0:n}" ]
}

# --- 1. fetch URL ---------------------------------------------------------------

fetch_url="$(git remote get-url "$remote" 2>/dev/null)"
if [ -z "$fetch_url" ]; then
  ng "원격을 찾을 수 없습니다 — $remote"
else
  got="$(normalize "$fetch_url")" || got=''
  if [ -z "$got" ]; then
    ng "fetch URL 을 정규화할 수 없습니다 — $fetch_url"
  elif [ "$got" != "$repo" ]; then
    ng "fetch URL 이 보관한 head 저장소와 다릅니다 — 보관 [$repo] 실제 [$got]"
  fi
fi

# --- 2. push URL (복수 가능) ------------------------------------------------------

if [ -n "$fetch_url" ]; then
  push_urls="$(git remote get-url --push --all "$remote" 2>/dev/null)"
  push_count="$(printf '%s' "$push_urls" | grep -c .)"
  if [ "$push_count" -ne 1 ]; then
    ng "push URL 이 ${push_count}개입니다 — 정확히 1개일 때만 진행합니다"
  fi
  while IFS= read -r u; do
    [ -n "$u" ] || continue
    got="$(normalize "$u")" || got=''
    if [ -z "$got" ]; then
      ng "push URL 을 정규화할 수 없습니다 — $u"
    elif [ "$got" != "$repo" ]; then
      ng "push URL 이 보관한 head 저장소와 다릅니다 — 보관 [$repo] 실제 [$got]"
    fi
  done <<EOF
$push_urls
EOF
fi

# --- 3. 원격 ref 현재 SHA ----------------------------------------------------------

if [ -n "$fetch_url" ]; then
  out="$(git ls-remote "$remote" "refs/heads/$branch" 2>/dev/null)"
  lines="$(printf '%s' "$out" | grep -c .)"
  if [ "$lines" -eq 0 ]; then
    ng "원격 ref 가 없습니다(삭제됨) — $remote refs/heads/$branch"
  elif [ "$lines" -ne 1 ]; then
    ng "ls-remote 출력이 ${lines}행입니다 — ref 패턴이 여러 브랜치에 걸렸습니다"
  else
    actual="$(printf '%s\n' "$out" | awk '{print $1}')"
    same_sha "$actual" "$head_oid" \
      || ng "원격 ref 가 보관한 headRefOid 와 다릅니다 — 보관 [$head_oid] 실제 [$actual]"
  fi
fi

# --- 4. 승인 SHA 가 headRefOid 를 조상으로 포함 --------------------------------------
#
# 이 조건이 서야 lease 가 성립한 push 가 전진이 되고 강제 덮어쓰기로 동작하지 않는다.

if ! git rev-parse --verify --quiet "$head_oid^{commit}" >/dev/null 2>&1; then
  ng "headRefOid 커밋을 로컬에서 찾을 수 없습니다 — $head_oid (fetch 후 다시 실행하세요)"
elif ! git rev-parse --verify --quiet "$approved^{commit}" >/dev/null 2>&1; then
  ng "승인 SHA 커밋을 로컬에서 찾을 수 없습니다 — $approved"
elif ! git merge-base --is-ancestor "$head_oid" "$approved" 2>/dev/null; then
  ng "승인 SHA 가 headRefOid 를 조상으로 포함하지 않습니다 — 전진 push 가 아닙니다"
fi

[ "$violations" -eq 0 ]
