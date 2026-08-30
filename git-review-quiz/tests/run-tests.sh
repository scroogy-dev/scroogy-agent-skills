#!/usr/bin/env bash
#
# git-review-quiz 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# 형식의 SSoT 는 templates/quiz-template.md 이고 scripts/check-quiz.sh 는 그 사본이다.
# 템플릿을 정상 fixture 로 함께 실행해, 템플릿이 규칙을 벗어나면 여기서 드리프트가 잡힌다.
#
# fixture 파일명 접두어(valid- / invalid-)는 규격이다. SKILL.md 와 이슈 검증 명령이
# 같은 접두어로 fixture 집합을 전수로 훑으므로, 다른 접두어를 쓰면 검사에서 조용히 빠진다.
# 반례 케이스 이름은 `R<n>: <설명>` 으로 고정한다. 규칙별 커버리지를 이름으로 센다.
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK="$HERE/../scripts/check-quiz.sh"
TEMPLATE="$HERE/../templates/quiz-template.md"
FIX="$HERE/fixtures"

pass=0
fail=0
used=''
rules=''

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

[ -x "$CHECK" ] || { echo "NOT OK - 헬퍼 실행 권한 없음 ($CHECK)"; exit 1; }
[ -r "$TEMPLATE" ] || { echo "NOT OK - 템플릿 없음 ($TEMPLATE)"; exit 1; }
[ -d "$FIX" ] || { echo "NOT OK - fixture 디렉토리 없음 ($FIX)"; exit 1; }

flat() { printf '%s' "$1" | tr '\n' ' '; }

# --- 정상 입력: 무출력 + 종료 0 -------------------------------------------------

# assert_valid <설명> <파일>
assert_valid() {
  local desc="$1" f="$2" out rc
  out="$("$CHECK" "$f" 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ] && [ -z "$out" ]; then
    ok "$desc"
  else
    ng "$desc (rc=$rc, 출력: $(flat "$out"))"
  fi
}

assert_valid 'SSoT 정합: 템플릿이 형식 검사를 통과' "$TEMPLATE"

n_valid=0
for f in "$FIX"/valid-*.md; do
  [ -e "$f" ] || break
  assert_valid "정상 fixture: $(basename "$f")" "$f"
  n_valid=$((n_valid + 1))
done
[ "$n_valid" -ge 2 ] \
  && ok "정상 fixture ${n_valid}개 (2개 이상)" \
  || ng "정상 fixture ${n_valid}개 (2개 이상이어야 합니다)"

# --- 반례: 사유 대조 + 출력 규약 -------------------------------------------------
#
# 사유 조각까지 대조해, 다른 규칙이 대신 걸려 통과처럼 보이는 것을 막는다.
# 출력 규약(`위반 R<n> [Q<m>]: `)도 함께 보아 stderr 혼입과 형식 이탈을 잡는다.

# assert_violation <케이스 이름> <사유 조각> <fixture 파일명>
assert_violation() {
  local desc="$1" want="$2" name="$3" f="$FIX/$3" out rc
  used="$used $name"
  rules="$rules ${desc%%:*}"
  if [ ! -r "$f" ]; then ng "$desc (fixture 없음: $name)"; return; fi
  out="$("$CHECK" "$f" 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ]; then
    ng "$desc (exit 1 기대, 실제 $rc)"
  elif ! printf '%s\n' "$out" | grep -qF "$want"; then
    ng "$desc (사유에 [$want] 없음, 실제: $(flat "$out"))"
  elif printf '%s\n' "$out" | grep -qvE '^위반 R[1-7]( Q[0-9]+)?: '; then
    ng "$desc (출력 규약 이탈: $(flat "$out"))"
  else
    ok "$desc"
  fi
}

assert_violation 'R1: 문항 번호 건너뜀'        '문항 번호가 1부터 연속이 아닙니다' invalid-r1-number-skip.md
assert_violation 'R1: 관점 어휘 오기'          '헤더 형식이'                     invalid-r1-perspective.md
assert_violation 'R2: 위치 행 없음'            '형식에 맞는 위치 행이 없습니다'    invalid-r2-missing-location.md
assert_violation 'R2: 헤더 직후가 위치 행 아님'  '헤더 다음 첫 행이 위치 행이 아닙니다' invalid-r2-location-not-first.md
assert_violation 'R2: 위치 행 형식 이탈'        '위치 행 형식이'                  invalid-r2-location-format.md
assert_violation 'R3: 힌트 블록 없음'          '힌트 블록이 없습니다'             invalid-r3-hint-none.md
assert_violation 'R3: 힌트 블록 2개'           '힌트 블록이 2개입니다'            invalid-r3-hint-duplicate.md
assert_violation 'R4: 정답 블록 없음'          '정답 블록이 없습니다'             invalid-r4-answer-none.md
assert_violation 'R4: 정답 블록이 힌트 앞'      '정답 블록이 힌트 블록보다 앞에'    invalid-r4-answer-before-hint.md
assert_violation 'R5: 객관식 선택지 부족'       '객관식 선택지가 1개입니다'         invalid-r5-too-few-options.md
assert_violation 'R5: 주관식에 선택지 존재'     '주관식에 선택지가'                invalid-r5-open-with-options.md
assert_violation 'R6: 접기 밖 정답 행'         '접기 밖에'                       invalid-r6-answer-outside-details.md
assert_violation 'R7: 대상 헤더 중복'          '`## 대상` 헤더가 2개입니다'        invalid-r7-duplicate-target.md
assert_violation 'R7: 문항 헤더 없음'          '`## 문항` 헤더가 0개입니다'        invalid-r7-no-questions-heading.md
assert_violation 'R7: 문항 0개'               '문항이 없습니다'                  invalid-r7-zero-questions.md
assert_violation 'R7: 응답 기록이 문항 사이'    '마지막 문항 블록보다 앞에'         invalid-r7-record-between-questions.md

# --- 커버리지: 규칙 7종과 fixture 전수 -------------------------------------------

missing_rule=''
for r in R1 R2 R3 R4 R5 R6 R7; do
  case " $rules " in *" $r "*) ;; *) missing_rule="$missing_rule $r" ;; esac
done
[ -z "$missing_rule" ] \
  && ok "규칙 커버리지: R1~R7 반례 전부 실행" \
  || ng "규칙 커버리지: 반례 없는 규칙$missing_rule"

missing_fix=''
for f in "$FIX"/invalid-*.md; do
  [ -e "$f" ] || break
  b="$(basename "$f")"
  case " $used " in *" $b "*) ;; *) missing_fix="$missing_fix $b" ;; esac
done
[ -z "$missing_fix" ] \
  && ok "fixture 커버리지: 반례 fixture 전수 실행" \
  || ng "fixture 커버리지: 실행되지 않은 반례$missing_fix"

# --- 사용오류 --------------------------------------------------------------------

# assert_usage_error <설명> <인자...>
assert_usage_error() {
  local desc="$1"; shift
  "$CHECK" "$@" >/dev/null 2>&1
  case "$?" in
    2) ok "사용오류: $desc (exit 2)" ;;
    *) ng "사용오류: $desc (exit 2 기대, 실제 $?)" ;;
  esac
}

assert_usage_error '인자 없음'
assert_usage_error '없는 파일'        "$FIX/absent.md"
assert_usage_error '디렉토리 지정'     "$FIX"
assert_usage_error '파일 인자 2개'     "$TEMPLATE" "$TEMPLATE"
assert_usage_error '알 수 없는 옵션'   --strict "$TEMPLATE"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
