#!/usr/bin/env bash
#
# summarize-metrics.sh — summary 의 지표 3종을 합산하고 보정률을 산출한다.
#
# SKILL.md "작업 진행 중" 과 summary 템플릿 주석이 규격의 SSoT 다.
# 지표는 `- **<필드>**: <숫자><단위>` 표기를 지켜야 집계되며, 표기가 깨지면 그 사실을 위반으로 낸다.
#
# 템플릿 주석의 집계 스니펫이 `[0-9]+` 만 추출하므로 `-` 로 남긴 필드는 합계에서 조용히 빠지고,
# 전부 `-` 면 합계 자체가 빈 문자열이 된다. 여기서는 그런 표기를 통과시키지 않고 위반으로 보고한다.
#
# 집계 대상은 Task 0 및 일반 실행 Task 다. Task N 블록에는 지표를 두지 않으므로 세지 않으며,
# 그 블록에 지표가 있으면 표기 위반으로 보고한다.
#
# 사용법:
#   summarize-metrics.sh <summary 파일>
#
# 출력(통과 시):
#   audit 발견: 3건
#   보정 반영: 2건
#   재시도: 1회
#   보정률: 2/3
#
# 종료 코드: 0 통과 / 1 표기 위반(사유를 1행씩 출력) / 2 사용오류

set -o pipefail

usage() { sed -n '3,25p' "$0" | sed 's/^# \{0,1\}//'; }

file=''
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -*) echo "error: 알 수 없는 옵션 — $1" >&2; exit 2 ;;
    *)
      [ -z "$file" ] || { echo "error: 파일은 하나만 지정합니다" >&2; exit 2; }
      file="$1"; shift ;;
  esac
done

[ -n "$file" ] || { echo "error: summary 파일 경로가 필요합니다" >&2; usage >&2; exit 2; }
[ -r "$file" ] || { echo "error: 읽을 수 없는 파일 — $file" >&2; exit 2; }

# 주석 안의 형식 설명 줄이 집계에 섞이지 않도록 `<!-- ... -->` 블록을 먼저 걷어낸다.
# 템플릿 주석에는 같은 표기의 예시가 들어 있어, 걷어내지 않으면 예시 숫자가 실제 값으로 집계된다.
body="$(awk '
  /<!--/ { c = 1 }
  !c { print }
  /-->/ { c = 0 }
' "$file")"

violations=0
ng() { echo "위반: $1"; violations=$((violations + 1)); }

grep -qE '^### Task ' "$file" || ng "'### Task ' 블록을 찾을 수 없습니다 — 경로를 확인하세요"

# 필드별 표기 검사 — 값이 `<숫자><단위>` 형태이고 Task N 블록 밖에 있어야 한다.
check_field() {
  local label="$1" unit="$2"
  printf '%s\n' "$body" | awk -v label="$label" -v unit="$unit" '
    /^### Task / { n = ($0 ~ /^### Task N/) }
    index($0, "- **" label "**:") == 1 {
      if (n) { print "TASKN"; next }
      v = $0
      sub(/^- \*\*[^*]+\*\*:[[:space:]]*/, "", v)
      if (v ~ ("^[0-9]+" unit "[[:space:]]*$")) { sub(unit "[[:space:]]*$", "", v); print "OK " v + 0 }
      else print "BAD " v
    }
  '
}

# 합계는 명령 치환이 아니라 전역 변수로 돌려준다 — `$( )` 안에서 세면 서브셸이라
# 위반 카운트가 부모로 돌아오지 않고, 위반 메시지가 합계 값에 섞인다.
FIELD_TOTAL=0

sum_field() {
  local label="$1" unit="$2" count=0 line kind value
  FIELD_TOTAL=0
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    kind="${line%% *}"
    value="${line#* }"
    case "$kind" in
      OK)    FIELD_TOTAL=$((FIELD_TOTAL + value)); count=$((count + 1)) ;;
      BAD)   ng "'$label' 표기가 '<숫자>$unit' 형식이 아닙니다 — [$value]" ;;
      TASKN) ng "Task N 블록에 '$label' 지표가 있습니다 — Task N 에는 지표를 두지 않습니다" ;;
    esac
  done <<EOF
$(check_field "$label" "$unit")
EOF
  if [ "$count" -eq 0 ]; then
    ng "'$label' 필드를 찾을 수 없습니다 — 값이 없어도 필드는 남깁니다"
  fi
}

sum_field 'audit 발견' '건'; found="$FIELD_TOTAL"
sum_field '보정 반영' '건'; fixed="$FIELD_TOTAL"
sum_field '재시도' '회';     retry="$FIELD_TOTAL"

[ "$violations" -eq 0 ] || exit 1

printf 'audit 발견: %s건\n' "$found"
printf '보정 반영: %s건\n' "$fixed"
printf '재시도: %s회\n' "$retry"
printf '보정률: %s/%s\n' "$fixed" "$found"
