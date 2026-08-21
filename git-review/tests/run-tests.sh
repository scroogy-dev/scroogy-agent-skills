#!/usr/bin/env bash
#
# git-review 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# classify-risk.sh 의 기대값을 테스트에 적지 않고 SKILL.md 매트릭스 표에서 추출한다
# — 표가 SSoT 이고 스크립트가 그것을 옮긴 사본이므로, 한쪽만 바뀌면 여기서 드리프트가 잡힌다
# (issue-work 러너가 템플릿 본문에서 게이트 명령을 추출하는 방식과 같다).
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
CLASSIFY="$HERE/../scripts/classify-risk.sh"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

[ -x "$CLASSIFY" ] || { echo "NOT OK - 헬퍼 실행 권한 없음 — $CLASSIFY"; exit 1; }

# --- SKILL.md 매트릭스 표 추출 ------------------------------------------------
#
# "**영향 × 발생확률 매트릭스**" 다음의 연속된 표 행만 잡는다. 첫 행은 헤더(확률 축 이름),
# 둘째는 구분선, 나머지가 데이터 행이다.

matrix_rows() {
  awk '
    /영향 . 발생확률 매트릭스/ { f = 1; next }
    f && /^\|/ { print; n++; next }
    f && n > 0 { exit }
  ' "$SKILL"
}

# cell <행> <열 번호> → 앞뒤 공백을 제거한 셀 값
cell() {
  printf '%s\n' "$1" | awk -F'|' -v i="$2" '{
    v = $(i + 1)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
    print v
  }'
}

rows="$(matrix_rows)"
row_count="$(printf '%s\n' "$rows" | grep -c '^|')"
if [ "$row_count" -ne 5 ]; then
  ng "매트릭스 추출: 표 행 5개 기대, 실제 ${row_count}개"
  echo "-----"; echo "passed: $pass, failed: $fail"; exit 1
fi
ok "매트릭스 추출: 표 행 5개(헤더·구분선·데이터 3행)"

header="$(printf '%s\n' "$rows" | sed -n '1p')"
like1="$(cell "$header" 2)"
like2="$(cell "$header" 3)"
case "$like1$like2" in
  '') ng "매트릭스 추출: 발생확률 축 헤더가 비어 있음" ;;
  *)  ok "매트릭스 추출: 발생확률 축 [$like1] [$like2]" ;;
esac

# --- 매트릭스 6조합 전수 대조 -------------------------------------------------

checked=0
for i in 3 4 5; do
  row="$(printf '%s\n' "$rows" | sed -n "${i}p")"
  impact="$(cell "$row" 1)"
  for col in 1 2; do
    case "$col" in
      1) like="$like1" ;;
      2) like="$like2" ;;
    esac
    want="$(cell "$row" $((col + 1)))"
    got="$("$CLASSIFY" --impact "$impact" --likelihood "$like" 2>&1)"
    if [ "$got" = "$want" ]; then
      ok "매트릭스: [$impact × $like] → $want"
    else
      ng "매트릭스: [$impact × $like] 기대 [$want], 실제 [$got]"
    fi
    checked=$((checked + 1))
  done
done
[ "$checked" -eq 6 ] && ok "매트릭스: 6조합 전수 대조" || ng "매트릭스: ${checked}조합만 대조(기대 6)"

# --- 상태 산출 ----------------------------------------------------------------
#
# 상태 표의 세 번째 행은 "낮음(LOW) 이하 또는 발견 없음"이라 값이 아니라 서술이다.
# 표에서 기대값을 뽑는 대신 세 상태 문자열의 실재만 확인하고, 매핑은 아래 케이스로 검사한다.

for s in '보완 필요(FAIL)' '주의(WARN)' '통과(PASS)'; do
  grep -qF "$s" "$SKILL" && ok "상태 표: '$s' 존재" || ng "상태 표: '$s' 없음"
done

# assert_status <기대> <설명> [위험도...]
assert_status() {
  local want="$1" desc="$2"; shift 2
  local got
  got="$("$CLASSIFY" --status "$@" 2>&1)"
  if [ "$got" = "$want" ]; then ok "$desc → $want"; else ng "$desc 기대 [$want], 실제 [$got]"; fi
}

assert_status '통과(PASS)'     '상태: 발견 없음'
assert_status '통과(PASS)'     '상태: 정보만'            '정보(INFO)'
assert_status '통과(PASS)'     '상태: 낮음 이하'          '낮음(LOW)' '정보(INFO)'
assert_status '주의(WARN)'     '상태: 중간 포함'          '낮음(LOW)' '중간(MEDIUM)'
assert_status '보완 필요(FAIL)' '상태: 높음 포함'          '정보(INFO)' '높음(HIGH)' '중간(MEDIUM)'
assert_status '보완 필요(FAIL)' '상태: 높음 단독'          '높음(HIGH)'

# 최고값 기준임을 확인한다 — 낮은 등급이 다수여도 상태를 낮추지 않는다.
assert_status '보완 필요(FAIL)' '상태: 낮음 다수 + 높음 1건' '낮음(LOW)' '낮음(LOW)' '낮음(LOW)' '높음(HIGH)'

# --- 사용오류 ------------------------------------------------------------------

# assert_usage_error <설명> <인자...>
assert_usage_error() {
  local desc="$1"; shift
  "$CLASSIFY" "$@" >/dev/null 2>&1
  case "$?" in
    2) ok "사용오류: $desc (exit 2)" ;;
    *) ng "사용오류: $desc — exit 2 기대, 실제 $?" ;;
  esac
}

assert_usage_error '알 수 없는 영향 축'   --impact '심각' --likelihood '통상 사용'
assert_usage_error '알 수 없는 발생확률 축' --impact '기능 저하' --likelihood '가끔'
assert_usage_error '영향 축 누락'         --likelihood '통상 사용'
assert_usage_error '발생확률 축 누락'      --impact '기능 저하'
assert_usage_error '인자 없음'
assert_usage_error '모드 혼용'            --status '높음(HIGH)' --impact '기능 저하'
assert_usage_error '알 수 없는 위험도'     --status '치명적'
assert_usage_error '알 수 없는 옵션'       --grade '높음(HIGH)'

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
