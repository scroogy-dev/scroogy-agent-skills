#!/usr/bin/env bash
#
# check-ide-tool-list.sh — IntelliJ MCP 도구 이름 목록을 도구별 결정 목록과 대조한다 (#144).
#
# IntelliJ를 업데이트하면 도구가 늘거나 사라지거나 이름이 바뀐다. 새로 받은 목록을 결정 목록
# (`.ai/40_domain/specs/ide-tools-decisions.md`)과 맞춰 보고, 결정이 필요한 새 도구와 정리할 사라진 도구를 출력한다.
# 저장소 안에서만 쓰는 도구라 배포하지 않는 `tests/` 아래에 둔다.
#
# 사용법:
#   check-ide-tool-list.sh <목록 파일> [<결정 목록>]
#
#   목록 파일: 한 줄에 도구 이름 하나. 앞뒤 공백을 지우고, 빈 줄과 `#`로 시작하는 줄은 건너뛴다.
#   결정 목록: 생략하면 이 스크립트 위치 기준 `../../.ai/40_domain/specs/ide-tools-decisions.md`.
#              첫 칸이 백틱으로 감싼 도구 이름 하나인 표 행(`| `<이름>` | …`)에서 이름을 뽑는다.
#
# 출력: 차이를 도구 이름순으로 한 줄씩 쓴다.
#   새 도구: <이름>       목록에만 있다. 결정해서 결정 목록에 행을 더한다.
#   사라진 도구: <이름>   결정 목록에만 있다. 결정 목록과 `ide-tools.md`에서 정리한다.
#   이름이 바뀐 도구는 두 줄로 함께 나온다.
#
# 종료 코드: 0 차이 없음(무출력) / 1 차이 있음 / 2 사용 오류(인자 수 오류, 파일을 읽지 못함 — 표준 오류에 사유)

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo '사용법: check-ide-tool-list.sh <목록 파일> [<결정 목록>]' >&2
  exit 2
fi

LIST="$1"
DECISIONS="${2:-$HERE/../../.ai/40_domain/specs/ide-tools-decisions.md}"

for f in "$LIST" "$DECISIONS"; do
  if [ ! -f "$f" ] || [ ! -r "$f" ]; then
    echo "파일을 읽을 수 없습니다: $f" >&2
    exit 2
  fi
done

W="$(mktemp -d)" || { echo '임시 디렉토리를 만들 수 없습니다' >&2; exit 2; }
trap 'rm -rf "$W"' EXIT

awk '{ sub(/^[ \t]+/, ""); sub(/[ \t\r]+$/, "") } $0 == "" || /^#/ { next } { print }' "$LIST" \
  | LC_ALL=C sort -u > "$W/list" || { echo "목록 파일을 처리할 수 없습니다: $LIST" >&2; exit 2; }
awk -F'|' '/^\| `[a-z0-9_]+` \|/ { c = $2; gsub(/[ `]/, "", c); print c }' "$DECISIONS" \
  | LC_ALL=C sort -u > "$W/decisions" || { echo "결정 목록을 처리할 수 없습니다: $DECISIONS" >&2; exit 2; }

{
  LC_ALL=C comm -23 "$W/list" "$W/decisions" | sed 's/$/	새 도구/'
  LC_ALL=C comm -13 "$W/list" "$W/decisions" | sed 's/$/	사라진 도구/'
} | LC_ALL=C sort -t '	' -k1,1 | awk -F'\t' '{ print $2 ": " $1 }' > "$W/out"

if [ -s "$W/out" ]; then
  cat "$W/out"
  exit 1
fi
exit 0
