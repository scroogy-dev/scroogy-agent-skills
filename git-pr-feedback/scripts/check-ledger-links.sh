#!/usr/bin/env bash
#
# check-ledger-links.sh — 원장 항목을 archive/ 로 옮긴 뒤 끊긴 원장 링크를 결정적으로 찾는다.
#
# 원장 항목을 옮기는 스킬 SKILL.md 의 `**들어오는 링크 갱신**` 이 SSoT 이며 이 스크립트는 그 0건 확인을 옮긴 사본이다.
# 옛 경로만 찾는 grep 은 원장 항목 파일끼리의 같은 디렉토리 링크와 깊이를 잘못 계산한 링크를 놓친다.
# 링크를 그 문서 위치에서 풀어 파일이 있는지 보면 옛 경로 링크까지 함께 잡힌다.
#
# 같은 파일이 issue-work·git-pr·git-pr-feedback 의 scripts/ 에 있다.
# 스킬 독립성 원칙(단독 실행·단독 설치)상 헬퍼를 공유하지 않는다.
# 세 파일은 바이트 단위로 같고 한쪽을 고치면 나머지도 고친다.
#
# 검사 범위: <.ai 디렉토리> 아래 *.md 전체. 90_issues/archive/ 아래는 작성 시점 기록이라 뺀다.
# 대상 링크: `](<대상>)` 가운데 파일 이름이 K-<4자리 숫자>- 로 시작하는 .md 다.
#   # 뒤 앵커는 떼고 보며, :// 가 들어간 외부 URL 은 대상이 아니다.
#   코드 블록·코드 스팬 안의 링크 문법도 구분하지 않고 검사한다. 오탐은 호출한 쪽이 건별로 판정한다.
#
# 사용법:
#   check-ledger-links.sh [<.ai 디렉토리>]    (생략하면 .ai)
#
# 출력: 끊긴 링크마다 `<파일>:<줄>: <대상>` 1행. 파일 경로는 인자로 준 디렉토리 경로로 시작한다.
# 종료 코드: 0 끊긴 링크 없음(무출력) / 1 끊긴 링크 있음 / 2 사용오류

set -o pipefail

usage() { sed -n '3,22p' "$0" | sed 's/^# \{0,1\}//'; }

[ $# -le 1 ] || { echo "error: 인자는 .ai 디렉토리 하나만 받습니다" >&2; usage >&2; exit 2; }

dir="${1:-.ai}"
[ -d "$dir" ] || { echo "error: 디렉토리가 아닙니다 — $dir" >&2; exit 2; }

# 끝의 / 를 떼어 find 출력 경로와 제외 경로의 표기를 맞춘다 (BSD find 는 `.ai/` 를 `.ai//…` 로 잇는다).
while [ "$dir" != / ] && [ "${dir%/}" != "$dir" ]; do dir="${dir%/}"; done

# 후보: <파일>\t<줄>\t<대상> — 대상은 링크에 적힌 그대로, 경로는 앵커를 뗀 값이다.
cands="$(find "$dir" -path "$dir/90_issues/archive" -prune -o -type f -name '*.md' -print \
  | LC_ALL=C sort \
  | while IFS= read -r f; do
      awk '
        {
          s = $0
          while ((i = index(s, "](")) > 0) {
            s = substr(s, i + 2)
            j = index(s, ")")
            if (j == 0) break
            t = substr(s, 1, j - 1)
            s = substr(s, j + 1)
            if (index(t, "://")) continue
            p = t; sub(/#.*/, "", p)
            b = p; sub(/.*\//, "", b)
            if (b ~ /^K-[0-9][0-9][0-9][0-9]-.*\.md$/) print FILENAME "\t" FNR "\t" t "\t" p
          }
        }
      ' "$f"
    done)" || { echo "error: 검사 대상을 읽지 못했습니다 — $dir" >&2; exit 2; }

broken=0
while IFS="$(printf '\t')" read -r f n t p; do
  [ -n "$f" ] || continue
  case "$p" in
    /*) r="$p" ;;
    *)  r="${f%/*}/$p" ;;
  esac
  [ -f "$r" ] && continue
  printf '%s:%s: %s\n' "$f" "$n" "$t"
  broken=$((broken + 1))
done <<EOF
$cands
EOF

[ "$broken" -eq 0 ]
