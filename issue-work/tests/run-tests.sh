#!/usr/bin/env bash
#
# issue-work 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# plan 템플릿 Task N 블록의 [D] 게이트 명령(결과 확정·수행 모델 검사)을
# 템플릿 본문에서 추출해 fixture 에 실행한다 — 게이트 명령의 SSoT 는 템플릿
# 인라인 명령이며(인스턴스화된 plan 의 자족성 때문에 scripts/ 헬퍼로 빼지 않는다),
# 문서의 명령이 깨지거나 반례를 다시 통과시키면 여기서 감지된다
# (install-skills 의 SKILL.md 스니펫 스모크와 같은 방식).
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$HERE/../templates/issue-plan-template.md"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

# 템플릿 행에서 `S=…; awk …' $S` 코드 스팬의 awk 프로그램만 추출한다.
# 스팬 서식이 바뀌어 추출이 깨지면 아래 "추출:" 검사가 실패해 드리프트를 알린다.
extract_gate() {
  grep -F "$1" "$TEMPLATE" | sed -E 's/.*`S=[^;]+; (awk [^`]+)` 출력 0.*/\1/'
}

GATE1="$(extract_gate '블록마다 유효 `결과` 행 정확히 1개')"
GATE2="$(extract_gate '`-`도 아닌 행 정확히 1개')"

case "$GATE1" in awk\ *) ok "추출: 결과 확정 게이트" ;; *) ng "추출: 결과 확정 게이트 — [$GATE1]" ;; esac
case "$GATE2" in awk\ *) ok "추출: 수행 모델 게이트" ;; *) ng "추출: 수행 모델 게이트 — [$GATE2]" ;; esac

# run_gate <awk 프로그램> <summary 경로> → stdout 에 위반 건수
run_gate() {
  local prog="$1" S="$2"
  eval "$prog"
}

# assert_gate <awk 프로그램> <fixture> <기대: pass|fail> <설명>
assert_gate() {
  local out
  out="$(run_gate "$1" "$2")"
  case "$3" in
    pass) if [ "$out" = "0" ]; then ok "$4 (위반 $out)"; else ng "$4 (기대 0, 실제 [$out])"; fi ;;
    fail) if [ -n "$out" ] && [ "$out" != "0" ]; then ok "$4 (위반 $out)"; else ng "$4 (기대 >0, 실제 [$out])"; fi ;;
  esac
}

sandbox="$(mktemp -d)"
trap 'rm -rf "$sandbox"' EXIT

# 정상 fixture: 확정된 일반 Task 3개(완료·부분 완료·스킵) + 미기입 Task N.
base="$sandbox/summary-valid.md"
cat > "$base" <<'EOF'
# Issue #99 실행요약 — 게이트 테스트 fixture

## Task별 수행 결과

### Task 0 (고정): 구현 시작 게이트 — 전제·모호점 확인

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 4.8 (claude-opus-4-8)
- **audit 발견**: 0건

### Task 1: 본작업

- **결과**: 부분 완료
- **수행 모델**: OpenAI, GPT-5
- **audit 발견**: 1건

### Task 2: 후속 작업

- **결과**: 스킵
- **수행 모델**: -
- **audit 발견**: 0건

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

- **결과**: <!-- 완료 / 부분 완료 / 스킵 -->
- **수행 내용 요약**:
EOF

# 반례 fixture 는 base 의 awk 변형으로 만든다 (BSD sed 의 GNU 확장 미지원 회피).

# F-1 반례(2차 audit 재현): Task 0 결과 미확정 + Task 1 에 유효 행 중복 → 총개수는 상쇄돼 같다.
awk '/^- \*\*결과\*\*: 완료$/ && !a {print "- **결과**: "; a=1; next} {print}
     /^- \*\*결과\*\*: 부분 완료$/ && !b {print "- **결과**: 완료"; b=1}' \
  "$base" > "$sandbox/f1-offset.md"
# F-1 이웃 반례: 행 누락 / 유효 행 중복 / 허용 외 값
awk '!/^- \*\*결과\*\*: 부분 완료$/ {print}' "$base" > "$sandbox/f1-missing.md"
awk '{print} /^- \*\*결과\*\*: 스킵$/ {print}' "$base" > "$sandbox/f1-dup.md"
awk '/^- \*\*결과\*\*: 완료$/ && !a {print "- **결과**: 진행 중"; a=1; next} {print}' \
  "$base" > "$sandbox/f1-invalid.md"

# F-2 반례(2차 audit 재현): 완료 Task 의 수행 모델 빈 값 / 행 누락
awk '/^- \*\*수행 모델\*\*: Anthropic/ {print "- **수행 모델**: "; next} {print}' \
  "$base" > "$sandbox/f2-empty.md"
awk '!/^- \*\*수행 모델\*\*: OpenAI/ {print}' "$base" > "$sandbox/f2-missing.md"
# F-2 이웃 반례: 리터럴 `-`(기존 검사가 막던 유일한 형태) / 행 중복
awk '/^- \*\*수행 모델\*\*: Anthropic/ {print "- **수행 모델**: -"; next} {print}' \
  "$base" > "$sandbox/f2-dash.md"
awk '{print} /^- \*\*수행 모델\*\*: OpenAI/ {print}' "$base" > "$sandbox/f2-dup.md"

assert_gate "$GATE1" "$base" pass "결과 게이트: 정상 fixture 통과"
assert_gate "$GATE2" "$base" pass "수행 모델 게이트: 정상 fixture 통과"

assert_gate "$GATE1" "$sandbox/f1-offset.md"  fail "결과 게이트: 미확정+중복 상쇄(2차 audit F-1 반례) 격추"
assert_gate "$GATE1" "$sandbox/f1-missing.md" fail "결과 게이트: 행 누락 격추"
assert_gate "$GATE1" "$sandbox/f1-dup.md"     fail "결과 게이트: 유효 행 중복 격추"
assert_gate "$GATE1" "$sandbox/f1-invalid.md" fail "결과 게이트: 허용 외 값 격추"

assert_gate "$GATE2" "$sandbox/f2-empty.md"   fail "수행 모델 게이트: 빈 값(2차 audit F-2 반례) 격추"
assert_gate "$GATE2" "$sandbox/f2-missing.md" fail "수행 모델 게이트: 행 누락(2차 audit F-2 반례) 격추"
assert_gate "$GATE2" "$sandbox/f2-dash.md"    fail "수행 모델 게이트: 리터럴 - 격추"
assert_gate "$GATE2" "$sandbox/f2-dup.md"     fail "수행 모델 게이트: 행 중복 격추"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
