#!/usr/bin/env bash
#
# issue-work 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# plan 템플릿 Task N 블록의 [D] 게이트 명령(결과 확정·수행 모델 검사)을
# 템플릿 본문에서 추출해 fixture 에 실행한다 — 게이트 명령의 SSoT 는 템플릿
# 완료 기준의 접기 안 코드 블록이며(인스턴스화된 plan 의 자족성 때문에 scripts/ 헬퍼로 빼지 않는다),
# 문서의 명령이 깨지거나 반례를 다시 통과시키면 여기서 감지된다
# (install-skills 의 SKILL.md 스니펫 스모크와 같은 방식).
#
# 여기에 더해 SKILL.md `--response` 절의 단계 구조·앵커 토큰 계약을 스모크로 검사한다
# — 이슈 단위 plan 의 일회성 명령으로만 지켜지면 이후 문서 개정이 구조를 깨도 감지되지 않는다.
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$HERE/../templates/issue-plan-template.md"
SKILL="$HERE/../SKILL.md"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

# 완료 기준 항목의 접기 안 bash 코드 블록에서 게이트 명령을 추출한다.
# 앵커 문구가 있는 본문 행 다음에 오는 첫 ```bash 블록이 대상이며,
# `P=`/`S=` 경로 할당 행은 제외한다 — fixture 경로는 호출자(run_gate·assert_pair_gate)가
# 로컬 변수로 주입하는 현행 계약을 그대로 유지하기 위함이다.
# 블록의 공통 들여쓰기(완료 기준 리스트 하위 배치)는 첫 행 기준으로 벗겨낸다.
# 블록 서식이 바뀌어 추출이 깨지면 아래 "추출:" 검사가 실패해 드리프트를 알린다.
extract_gate() {
  awk -v anchor="$1" '
    !found && index($0, anchor) { found = 1; next }
    found && !inblock && /^[[:space:]]*```bash[[:space:]]*$/ { inblock = 1; next }
    inblock && /^[[:space:]]*```[[:space:]]*$/ { exit }
    inblock {
      if (!measured) { match($0, /^[[:space:]]*/); ind = RLENGTH; measured = 1 }
      line = substr($0, ind + 1)
      if (line !~ /^[PS]=/) print line
    }
  ' "$TEMPLATE"
}

GATE0="$(extract_gate 'summary의 Task 헤더 집합이 plan과 일치')"
GATE1="$(extract_gate '블록마다 유효 `결과` 행 정확히 1개')"
GATE2="$(extract_gate '`-`도 아닌 행 정확히 1개')"

case "$GATE0" in '{ grep '*) ok "추출: Task 집합 대조 게이트" ;; *) ng "추출: Task 집합 대조 게이트 — [$GATE0]" ;; esac
case "$GATE1" in awk\ *) ok "추출: 결과 확정 게이트" ;; *) ng "추출: 결과 확정 게이트 — [$GATE1]" ;; esac
case "$GATE2" in awk\ *) ok "추출: 수행 모델 게이트" ;; *) ng "추출: 수행 모델 게이트 — [$GATE2]" ;; esac

# 경로 할당 행이 남으면 템플릿의 미치환 `<번호>` 경로가 fixture 경로를 덮어써
# 정상 fixture 검사부터 무너진다. 추출 단계에서 먼저 끊는다.
case "$GATE0$GATE1$GATE2" in
  *'.ai/90_issues/'*) ng "추출: 경로 할당 행이 제거되지 않음 (fixture 경로 주입 계약 위반)" ;;
  *) ok "추출: fixture 경로 주입 계약 유지" ;;
esac

# run_gate <awk 프로그램> <summary 경로> → stdout 에 위반 건수
run_gate() {
  local prog="$1" S="$2"
  eval "$prog"
}

# assert_pair_gate <집합 대조 프로그램> <plan> <summary> <기대: pass|fail> <설명>
# 집합 대조는 위반 건수가 아니라 출력 자체로 판정한다 (출력 0건이면 통과).
# stderr 는 버린다 — 경로 오기 fixture 의 `grep` 오류 메시지가 테스트 출력을 덮지 않게 하기 위함이며,
# 게이트가 실행 실패를 stdout 위반 행으로 환원하므로 판정에 필요한 정보는 stdout 에 남는다.
assert_pair_gate() {
  local out P="$2" S="$3"
  out="$(eval "$1" 2>/dev/null)"
  case "$4" in
    pass) if [ -z "$out" ]; then ok "$5 (diff 0건)"; else ng "$5 (기대 0건, 실제 [$out])"; fi ;;
    fail) if [ -n "$out" ]; then ok "$5 (diff 검출)"; else ng "$5 (기대 >0건, 실제 0건)"; fi ;;
  esac
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

# 집합 대조용 plan fixture: base 와 Task 헤더가 정확히 같다.
plan="$sandbox/plan-valid.md"
cat > "$plan" <<'EOF'
# Issue #99 실행계획 — 게이트 테스트 fixture

## Tasks

### Task 0 (고정): 구현 시작 게이트 — 전제·모호점 확인

- [x] 완료

### Task 1: 본작업

- [x] 완료

### Task 2: 후속 작업

- [ ] 완료

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

- [ ] 완료
EOF

# 반례 fixture 는 base 의 awk 변형으로 만든다 (BSD sed 의 GNU 확장 미지원 회피).

# F-1(3차 audit) 반례: Task 블록이 통째로 없으면 아래 두 게이트는 검사 대상이 사라져 통과한다.
awk '/^### Task 1:/{s=1} /^### Task 2:/{s=0} !s' "$base" > "$sandbox/f0-block-missing.md"
awk '/^### Task N/{s=1} !s' "$base" > "$sandbox/f0-taskn-missing.md"
: > "$sandbox/f0-empty.md"

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

assert_pair_gate "$GATE0" "$plan" "$base" pass "집합 게이트: 정상 fixture 통과"
assert_pair_gate "$GATE0" "$plan" "$sandbox/f0-block-missing.md" fail "집합 게이트: Task 블록 전체 누락(3차 audit F-1 반례) 격추"
assert_pair_gate "$GATE0" "$plan" "$sandbox/f0-taskn-missing.md" fail "집합 게이트: Task N 블록 누락 격추"
assert_pair_gate "$GATE0" "$plan" "$sandbox/f0-empty.md"         fail "집합 게이트: 빈 summary 격추"

# F-1(4차 audit) 반례: 두 경로가 모두 잘못되면 빈 입력끼리 비교돼 diff 만으로는 통과한다.
assert_pair_gate "$GATE0" "$sandbox/f0-nonexistent-plan.md" "$sandbox/f0-nonexistent-summary.md" \
  fail "집합 게이트: plan·summary 경로 동시 누락(4차 audit F-1 반례) 격추"
assert_pair_gate "$GATE0" '.ai/90_issues/active/issue-<번호>/issue-<번호>-plan.md' \
  '.ai/90_issues/active/issue-<번호>/issue-<번호>-summary.md' \
  fail "집합 게이트: 미치환 <번호> 경로 격추"
assert_pair_gate "$GATE0" "$sandbox/f0-nonexistent-plan.md" "$base" fail "집합 게이트: plan 경로만 누락 격추"

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

# --- SKILL.md `--response` 절 구조 스모크 -------------------------------------
#
# 검사 대상은 spec 앵커 토큰 계약과 같다 — 번호 단계 5개, 그리고 각 앵커 토큰이
# 지정된 단계 범위 안에 있을 것. 단계 범위 추출(awk)은 다음 번호 단계 직전까지
# 포함하므로 단계 본문이 늘어나도 판정이 유지된다.

resp_section() { sed -n '/^### `--response`/,/^### `--clear`/p' "$1"; }

# check_response <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_response() {
  local sec s2 s3 s45
  sec="$(resp_section "$1")"
  [ "$(printf '%s\n' "$sec" | grep -cE '^  [0-9]+\. \*\*[^*]+\*\*')" = 5 ] || echo "번호 단계가 정확히 5개가 아님"
  s2="$(printf '%s\n' "$sec" | awk '/^  2\. /{f=1} /^  3\. /{f=0} f')"
  s3="$(printf '%s\n' "$sec" | awk '/^  3\. /{f=1} /^  4\. /{f=0} f')"
  # 4~5단계는 마지막 번호 단계라 종료 앵커가 없다 — 절 끝까지 잡으면 뒤에 붙은
  # 리스트 밖 최상위 블록(등급별 기본 제시값 등)까지 범위에 들어와, 실제 게이트
  # 토큰이 사라져도 그 블록의 토큰으로 통과한다. 첫 비공백-시작 행에서 끊는다.
  s45="$(printf '%s\n' "$sec" | awk '/^  4\. /{f=1} f && /^[^[:space:]]/ && !/^  4\. /{f=0} f')"
  printf '%s\n' "$s2"  | grep -q '1단계 발견'          || echo "2단계 범위에 '1단계 발견' 없음"
  printf '%s\n' "$s2"  | grep -q '2단계 발견'          || echo "2단계 범위에 '2단계 발견' 없음"
  printf '%s\n' "$s3"  | grep -q '상단'                || echo "3단계 범위에 '상단' 없음"
  printf '%s\n' "$s3"  | grep -q '미해소'              || echo "3단계 범위에 '미해소' 없음"
  printf '%s\n' "$s45" | grep -q '순서 게이트'         || echo "4~5단계 범위에 '순서 게이트' 없음"
  printf '%s\n' "$sec" | grep -q '항목 단위로'         || echo "절 전체에 '항목 단위로' 없음"
  printf '%s\n' "$sec" | grep -q '자동 보정하지 않는다' || echo "절 전체에 '자동 보정하지 않는다' 없음"
}

# assert_response <파일> <기대: pass|fail> <설명>
assert_response() {
  local out
  out="$(check_response "$1")"
  case "$2" in
    pass) if [ -z "$out" ]; then ok "$3 (위반 0건)"; else ng "$3 (기대 0건, 실제 [$out])"; fi ;;
    fail) if [ -n "$out" ]; then ok "$3 (위반 검출)"; else ng "$3 (기대 >0건, 실제 0건)"; fi ;;
  esac
}

# 반례 fixture 는 실제 SKILL.md 의 awk 변형으로 만든다 (구조 드리프트를 그대로 재현하기 위함).
awk '!/^  5\. /' "$SKILL" > "$sandbox/r-steps4.md"
awk '/^  4\. /{gsub(/순서 게이트/, "순서 규칙")} /^  5\. /{gsub(/순서 게이트/, "순서 규칙")} {print}' \
  "$SKILL" > "$sandbox/r-no-gate.md"
awk '/^  2\. /{gsub(/1단계 발견/, "적합성 발견"); gsub(/2단계 발견/, "비판적 발견")} {print}' \
  "$SKILL" > "$sandbox/r-no-split.md"
awk '/^  3\. /{gsub(/상단/, "앞쪽"); gsub(/미해소/, "남은")} {print}' "$SKILL" > "$sandbox/r-no-order.md"
awk '{gsub(/항목 단위로/, "하나씩"); print}' "$SKILL" > "$sandbox/r-no-approval.md"
awk '!/^### `--response`/' "$SKILL" > "$sandbox/r-no-section.md"

assert_response "$SKILL"                     pass "response 스모크: 실제 SKILL.md 통과"
assert_response "$sandbox/r-steps4.md"       fail "response 스모크: 번호 단계 수 변경 격추"
assert_response "$sandbox/r-no-gate.md"      fail "response 스모크: 순서 게이트 토큰 소실 격추"
assert_response "$sandbox/r-no-split.md"     fail "response 스모크: 2단계 구분 제시 소실 격추"
assert_response "$sandbox/r-no-order.md"     fail "response 스모크: 상단 배치·미해소 명시 소실 격추"
assert_response "$sandbox/r-no-approval.md"  fail "response 스모크: 항목별 승인 원칙 소실 격추"
assert_response "$sandbox/r-no-section.md"   fail "response 스모크: 절 헤더 소실 격추"

# --- 템플릿 구조 계약 스모크 (issue #94 audit F-1·F-2) --------------------------
#
# 요구사항 섹션·DoD 그룹·대상 요구사항 필드 구조는 issue-0094 spec 의 일회성 [D]
# 명령으로만 검증되었다 — 이후 템플릿 개정이 구조를 깨도 정규 러너가 감지하지
# 못하므로, `--response` 스모크와 같은 방식으로 여기에 편입한다.
# F-2 보강: 존재·개수만 세면 헤더 중복, 섹션 밖 배치, 필드 위치 이동·빈 값,
# 옛 표기 공존이 위반 0건으로 통과한다 — 개수·소속·순서·값 형식까지 판정한다.

SPEC_TPL="$HERE/../templates/issue-spec-template.md"

# check_spec_structure <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 소속은 직전 `^## ` 헤더로 추적한다 — `###` 하위 헤더는 섹션을 바꾸지 않는다.
check_spec_structure() {
  awk '
    /^## /                           { sec = $0; list = "" }
    /^## 요구사항 \(Requirements\)$/ { req++ }
    /^\*\*포함\*\*$/                 { inc++; if (sec !~ /^## 요구사항/) mis++; inc_at = NR; list = "inc" }
    /^\*\*제외\*\*$/                 { exc++; if (sec !~ /^## 요구사항/) mis++; exc_at = NR; list = "exc" }
    list == "inc" && /^- /           { if ($0 ~ /^- R[0-9]+: /) inc_items++; else inc_bad++ }
    list == "exc" && /^- /           { exc_items++ }
    /^### R1: /                      { r1++; if (sec !~ /^## 완료의 정의/) dod_mis++ }
    /^### 공통$/                     { com++; if (sec !~ /^## 완료의 정의/) dod_mis++ }
    /^## 범위/                       { scope++ }
    /포함 \(In\)|비포함 ?\(Out\)/    { old++ }
    END {
      if (req != 1)       print "요구사항 헤더 " req + 0 "개 (기대 1개)"
      if (inc != 1)       print "포함 표기 " inc + 0 "개 (기대 1개)"
      if (exc != 1)       print "제외 표기 " exc + 0 "개 (기대 1개)"
      if (mis)            print "포함·제외 표기가 요구사항 섹션 밖: " mis "개"
      if (inc == 1 && exc == 1 && inc_at > exc_at) print "포함·제외 순서 역전"
      if (inc_items < 1)  print "포함 목록에 R<n> 항목 없음"
      if (inc_bad)        print "포함 목록에 R<n> 형식 아닌 항목: " inc_bad "개"
      if (exc_items < 1)  print "제외 목록에 항목 없음"
      if (r1 != 1)        print "DoD R 그룹 예시 헤더 " r1 + 0 "개 (기대 1개)"
      if (com != 1)       print "DoD 공통 그룹 헤더 " com + 0 "개 (기대 1개)"
      if (dod_mis)        print "DoD 그룹 헤더가 완료의 정의 섹션 밖: " dod_mis "개"
      if (scope)          print "범위 헤더 잔존 (경계는 제외 목록으로 일원화)"
      if (old)            print "옛 포함(In)·비포함(Out) 표기 잔존"
    }
  ' "$1"
}

# check_plan_structure <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 총개수 비교는 고정 Task 의 오기와 일반 Task 의 누락이 상쇄되어 통과하므로
# 블록 단위로 센다. 고정 여부는 헤더의 `(고정)` 표기로 판별한다 (issue-0094 spec DoD R4 와 같은 논리).
# 부분 문자열 `고정` 매칭은 일반 Task 제목에 든 단어까지 고정 Task 로 오분류하므로 정확 매칭한다.
# 개수만 세면 값 형식 위반과 `목표` 다음 행 이탈이 통과하므로 (F-2),
# 값이 유효한 `R<n>[, R<m>]` 나열인지와 직전 행이 `목표` 필드인지도 함께 판정한다.
check_plan_structure() {
  awk '
    function flush() { if (!o) return
      if (fixed && c > 0) print "고정 Task에 대상 요구사항 필드: " t
      if (!fixed && c != 1) print "일반 Task 필드 " c "개: " t }
    /^### Task / { flush(); o = 1; t = $0; c = 0; fixed = ($0 ~ /^### Task [0-9N]+ \(고정\)/) }
    o && /^- \*\*대상 요구사항\*\*:/ {
      c++
      if ($0 !~ /^- \*\*대상 요구사항\*\*: R[0-9]+(, R[0-9]+)*$/) print "필드 값이 R<n> 나열이 아님: " t
      if (prev !~ /^- \*\*목표\*\*:/) print "필드가 목표 다음 행이 아님: " t
    }
    { prev = $0 }
    END { flush() }
  ' "$1"
}

# assert_structure <검사 함수> <파일> <기대: pass|fail> <설명>
assert_structure() {
  local out
  out="$("$1" "$2")"
  case "$3" in
    pass) if [ -z "$out" ]; then ok "$4 (위반 0건)"; else ng "$4 (기대 0건, 실제 [$out])"; fi ;;
    fail) if [ -n "$out" ]; then ok "$4 (위반 검출)"; else ng "$4 (기대 >0건, 실제 0건)"; fi ;;
  esac
}

# 반례 fixture 는 실제 템플릿의 awk 변형으로 만든다 (구조 드리프트를 그대로 재현).
awk '!/^## 요구사항 \(Requirements\)$/' "$SPEC_TPL" > "$sandbox/s-no-req.md"
awk '!/^\*\*포함\*\*$/' "$SPEC_TPL" > "$sandbox/s-no-incl.md"
awk '!/^\*\*제외\*\*$/' "$SPEC_TPL" > "$sandbox/s-no-excl.md"
awk '!/^### R1: /' "$SPEC_TPL" > "$sandbox/s-no-rgroup.md"
awk '!/^### 공통$/' "$SPEC_TPL" > "$sandbox/s-no-common.md"
awk '{print} END{print ""; print "## 범위 (Scope)"}' "$SPEC_TPL" > "$sandbox/s-scope-back.md"

# F-2 반례(2차 audit 재현·이웃 변형): 존재 검사만으로는 통과하는 변형들.
awk '{print} END{print ""; print "## 요구사항 (Requirements)"}' "$SPEC_TPL" > "$sandbox/s-dup-req.md"
awk '{print} /^\*\*포함\*\*$/{print ""; print "**포함**"}' "$SPEC_TPL" > "$sandbox/s-dup-incl.md"
awk '/^\*\*포함\*\*$/{next} {print} /^\*\*제외\*\*$/{print ""; print "**포함**"}' \
  "$SPEC_TPL" > "$sandbox/s-swap-order.md"
awk '!/^\*\*제외\*\*$/{print} END{print ""; print "**제외**"}' "$SPEC_TPL" > "$sandbox/s-excl-outside.md"
awk '{print} /^\*\*제외\*\*$/{print ""; print "**비포함 (Out)**"}' "$SPEC_TPL" > "$sandbox/s-old-coexist.md"
# PR #95 리뷰 반례: 소속·목록 항목까지 판정 — DoD 그룹 헤더의 섹션 밖 이동, 목록 항목 삭제·형식 훼손.
awk '!/^### R1: /{print} END{print ""; print "### R1: <짧은 이름>"}' "$SPEC_TPL" > "$sandbox/s-rgroup-outside.md"
awk '!/^### 공통$/{print} END{print ""; print "### 공통"}' "$SPEC_TPL" > "$sandbox/s-common-outside.md"
awk '!/^- R[0-9]+: /' "$SPEC_TPL" > "$sandbox/s-no-ritems.md"
awk '{gsub(/^- R1: /, "- "); print}' "$SPEC_TPL" > "$sandbox/s-bad-ritem.md"
awk '!/^- <검토했지만/' "$SPEC_TPL" > "$sandbox/s-no-excl-items.md"

assert_structure check_spec_structure "$SPEC_TPL"                  pass "spec 구조: 실제 템플릿 통과"
assert_structure check_spec_structure "$sandbox/s-no-req.md"       fail "spec 구조: 요구사항 헤더 소실 격추"
assert_structure check_spec_structure "$sandbox/s-no-incl.md"      fail "spec 구조: 포함 목록 소실 격추"
assert_structure check_spec_structure "$sandbox/s-no-excl.md"      fail "spec 구조: 제외 목록 소실 격추"
assert_structure check_spec_structure "$sandbox/s-no-rgroup.md"    fail "spec 구조: DoD R 그룹 소실 격추"
assert_structure check_spec_structure "$sandbox/s-no-common.md"    fail "spec 구조: DoD 공통 그룹 소실 격추"
assert_structure check_spec_structure "$sandbox/s-scope-back.md"   fail "spec 구조: 범위 섹션 재유입 격추"
assert_structure check_spec_structure "$sandbox/s-dup-req.md"      fail "spec 구조: 요구사항 헤더 중복(2차 audit F-2 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-dup-incl.md"     fail "spec 구조: 포함 표기 중복 격추"
assert_structure check_spec_structure "$sandbox/s-swap-order.md"   fail "spec 구조: 포함·제외 순서 역전 격추"
assert_structure check_spec_structure "$sandbox/s-excl-outside.md" fail "spec 구조: 제외 표기 섹션 밖 배치 격추"
assert_structure check_spec_structure "$sandbox/s-old-coexist.md"  fail "spec 구조: 옛 비포함(Out) 표기 공존 격추"
assert_structure check_spec_structure "$sandbox/s-rgroup-outside.md" fail "spec 구조: DoD R 그룹 헤더 섹션 밖 이동(PR #95 리뷰 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-common-outside.md" fail "spec 구조: DoD 공통 그룹 헤더 섹션 밖 이동 격추"
assert_structure check_spec_structure "$sandbox/s-no-ritems.md"      fail "spec 구조: 포함 목록 R 항목 삭제 격추"
assert_structure check_spec_structure "$sandbox/s-bad-ritem.md"      fail "spec 구조: 포함 항목 R 번호 소실 격추"
assert_structure check_spec_structure "$sandbox/s-no-excl-items.md"  fail "spec 구조: 제외 목록 항목 삭제 격추"

# 일반 Task 필드 누락 / 고정 Task 오기 / 중복 / 누락+오기 상쇄(총개수 우회) 반례.
awk '/^### Task 1:/{s=1} /^### Task 2:/{s=0} !(s && /^- \*\*대상 요구사항\*\*:/)' \
  "$TEMPLATE" > "$sandbox/p-field-missing.md"
awk '/^### Task 0/{f=1} {print} f && /^- \*\*목표\*\*:/{print "- **대상 요구사항**: R1"; f=0}' \
  "$TEMPLATE" > "$sandbox/p-field-fixed.md"
awk '{print} /^- \*\*대상 요구사항\*\*: R1$/{print}' "$TEMPLATE" > "$sandbox/p-field-dup.md"
awk '/^### Task 1:/{s=1} /^### Task 2:/{s=0} s && /^- \*\*대상 요구사항\*\*:/{next}
     /^### Task 0/{f=1} {print} f && /^- \*\*목표\*\*:/{print "- **대상 요구사항**: R1"; f=0}' \
  "$TEMPLATE" > "$sandbox/p-field-offset.md"

# F-2 반례(2차 audit 재현·이웃 변형): 블록당 개수만 세면 통과하는 변형들 —
# 필드를 목표 다음 행에서 작업 내용 아래로 이동 / 값 비움 / 쉼표 없는 나열.
awk '/^### Task 1:/{s=1} /^### Task 2:/{s=0}
     s && /^- \*\*대상 요구사항\*\*:/ { held = $0; next }
     { print }
     s && held && /^- \*\*작업 내용\*\*:/ { print held; held = "" }' \
  "$TEMPLATE" > "$sandbox/p-field-moved.md"
awk '{gsub(/^- \*\*대상 요구사항\*\*: R1$/, "- **대상 요구사항**:"); print}' \
  "$TEMPLATE" > "$sandbox/p-field-empty.md"
awk '{gsub(/^- \*\*대상 요구사항\*\*: R1$/, "- **대상 요구사항**: R1 R2"); print}' \
  "$TEMPLATE" > "$sandbox/p-field-invalid.md"
# PR #95 리뷰 반례: 일반 Task 제목에 든 `고정` 단어 — 오분류하면 거짓 위반이 나와 pass 가 깨진다.
awk '{gsub(/^### Task 1: <작업 이름>$/, "### Task 1: 고정 설정 갱신"); print}' \
  "$TEMPLATE" > "$sandbox/p-fixed-in-title.md"

assert_structure check_plan_structure "$TEMPLATE"                   pass "plan 구조: 실제 템플릿 통과"
assert_structure check_plan_structure "$sandbox/p-field-missing.md" fail "plan 구조: 일반 Task 필드 누락 격추"
assert_structure check_plan_structure "$sandbox/p-field-fixed.md"   fail "plan 구조: 고정 Task 필드 오기 격추"
assert_structure check_plan_structure "$sandbox/p-field-dup.md"     fail "plan 구조: 필드 중복 격추"
assert_structure check_plan_structure "$sandbox/p-field-offset.md"  fail "plan 구조: 누락+오기 상쇄(총개수 우회) 격추"
assert_structure check_plan_structure "$sandbox/p-field-moved.md"   fail "plan 구조: 필드 위치 이동(2차 audit F-2 반례) 격추"
assert_structure check_plan_structure "$sandbox/p-field-empty.md"   fail "plan 구조: 필드 빈 값 격추"
assert_structure check_plan_structure "$sandbox/p-field-invalid.md" fail "plan 구조: 필드 값 형식 위반 격추"
assert_structure check_plan_structure "$sandbox/p-fixed-in-title.md" pass "plan 구조: 일반 Task 제목의 고정 단어 오분류 없음(PR #95 리뷰 반례)"

# --- `--clear` 완료 확인 (check-clear.sh --completion) ---------------------------

CLEAR="$HERE/../scripts/check-clear.sh"
METRICS="$HERE/../scripts/summarize-metrics.sh"

for s in "$CLEAR" "$METRICS"; do
  [ -x "$s" ] || { echo "NOT OK - 헬퍼 실행 권한 없음 — $s"; fail=$((fail + 1)); }
done

# assert_clear <기대: pass|fail> <설명> <인자...>
assert_clear() {
  local want="$1" desc="$2"; shift 2
  local out rc
  out="$("$CLEAR" "$@" 2>&1)"; rc=$?
  case "$want" in
    pass) [ "$rc" -eq 0 ] && ok "$desc" || ng "$desc (기대 통과, 실제 exit $rc — $(printf '%s' "$out" | tr '\n' ' '))" ;;
    fail) [ "$rc" -eq 1 ] && ok "$desc" || ng "$desc (기대 exit 1, 실제 $rc)" ;;
    usage) [ "$rc" -eq 2 ] && ok "$desc" || ng "$desc (기대 exit 2, 실제 $rc)" ;;
  esac
}

# 완료 plan fixture: 게이트 체크 + Task 3개 전부 체크.
plan_done="$sandbox/plan-done.md"
cat > "$plan_done" <<'EOF'
# Issue #99 실행계획 — clear 게이트 fixture

## 설계 종료 게이트 (고정)

- [x] 점검 완료

## Tasks

### Task 0 (고정): 구현 시작 게이트

- [x] 완료

### Task 1: 본작업

- [x] 완료

### Task N (고정): 교차모델 issue-audit 검증

- [x] 완료
EOF

assert_clear pass "clear 완료 확인: 전부 체크된 plan 통과" --completion "$plan_done"

# 게이트만 미체크 — `## Tasks` 밖이라 Task 체크박스만 세면 놓치는 자리다.
awk '{gsub(/^- \[x\] 점검 완료$/, "- [ ] 점검 완료"); print}' "$plan_done" > "$sandbox/plan-gate-open.md"
assert_clear fail "clear 완료 확인: 설계 종료 게이트 미체크 격추" --completion "$sandbox/plan-gate-open.md"
# `set -o pipefail` 아래에서는 헬퍼의 exit 1 이 파이프라인 전체로 전파되므로 출력을 변수에 담아 본다.
gate_out="$("$CLEAR" --completion "$sandbox/plan-gate-open.md" 2>&1)"
printf '%s\n' "$gate_out" | grep -q '설계 종료 게이트 점검 완료' \
  && ok "clear 완료 확인: 게이트 미완료 사유 출력" \
  || ng "clear 완료 확인: 게이트 미완료 사유가 출력되지 않음 — [$gate_out]"

# Task N 미체크 — 사용자 수동 수행 Task 라 구현 AI 가 대신 닫지 않는다.
awk 'BEGIN{n=0} /^### Task N/{n=1} n && /^- \[x\] 완료$/{print "- [ ] 완료"; n=0; next} {print}' \
  "$plan_done" > "$sandbox/plan-taskn-open.md"
assert_clear fail "clear 완료 확인: Task N 미체크 격추" --completion "$sandbox/plan-taskn-open.md"

# 게이트 항목 자체가 사라진 경우 — 체크박스가 없으면 "미완료 0건"으로 통과해선 안 된다.
awk '!/점검 완료/' "$plan_done" > "$sandbox/plan-no-gate.md"
assert_clear fail "clear 완료 확인: 게이트 항목 소실 격추" --completion "$sandbox/plan-no-gate.md"

# 이웃 반례: 게이트 체크박스가 2개이고 둘 다 체크된 경우.
# 미체크만 세면 이 입력이 통과하므로 Task 쪽과 같이 유일성도 함께 센다.
awk '{print} /^- \[x\] 점검 완료$/{print "- [x] 점검 완료"}' "$plan_done" > "$sandbox/plan-gate-dup.md"
assert_clear fail "clear 완료 확인: 설계 종료 게이트 중복 격추" --completion "$sandbox/plan-gate-dup.md"
dup_gate_out="$("$CLEAR" --completion "$sandbox/plan-gate-dup.md" 2>&1)"
printf '%s\n' "$dup_gate_out" | grep -q '항목이 2개입니다' \
  && ok "clear 완료 확인: 게이트 중복 사유 출력" \
  || ng "clear 완료 확인: 게이트 중복 사유가 출력되지 않음 — [$dup_gate_out]"

# 5차 audit F-2 반례: Task 블록은 있는데 완료 체크박스가 없는 경우.
# 미체크만 세면 이 입력이 "미완료 0건"으로 통과한다.
awk 'BEGIN{n=0} /^### Task 0/{n=1} n && /^- \[x\] 완료$/{n=0; next} {print}' \
  "$plan_done" > "$sandbox/plan-task-no-box.md"
assert_clear fail "clear 완료 확인: Task 완료 체크박스 소실(5차 audit F-2 반례) 격추" \
  --completion "$sandbox/plan-task-no-box.md"
box_out="$("$CLEAR" --completion "$sandbox/plan-task-no-box.md" 2>&1)"
printf '%s\n' "$box_out" | grep -q '완료 체크박스가 없습니다' \
  && ok "clear 완료 확인: 체크박스 소실 사유 출력" \
  || ng "clear 완료 확인: 체크박스 소실 사유가 출력되지 않음 — [$box_out]"

# 이웃 반례: 한 블록에 완료 체크박스가 2개 — 어느 쪽이 판정 대상인지 정해지지 않는다.
awk '{print} /^### Task 1:/{d=1} d && /^- \[x\] 완료$/{print "- [ ] 완료"; d=0}' \
  "$plan_done" > "$sandbox/plan-task-dup-box.md"
assert_clear fail "clear 완료 확인: Task 완료 체크박스 중복 격추" --completion "$sandbox/plan-task-dup-box.md"

# Task 블록이 없는 파일(경로 오기) — 검사 대상 공집합을 통과로 보지 않는다.
printf '# 빈 문서\n' > "$sandbox/plan-empty.md"
assert_clear fail "clear 완료 확인: Task 블록 없음 격추" --completion "$sandbox/plan-empty.md"

assert_clear usage "clear 완료 확인: 읽을 수 없는 파일 (exit 2)" --completion "$sandbox/absent.md"
assert_clear usage "clear: 모드 미지정 (exit 2)"

# --- `--clear` 경로 참조 검증 (check-clear.sh --refs) ------------------------------

arch="$sandbox/archive/issue-0099"
mkdir -p "$arch"
cat > "$arch/issue-0099-summary.md" <<'EOF'
# Issue #99 실행요약

> 스펙: [issue-0099-spec.md](./issue-0099-spec.md)

- 작업 절차는 `.ai/90_issues/active/issue-workflow.md`를 따른다.
- 감사 리포트는 이 디렉토리의 `./issue-0099-audit-report.md`에 있다 (작성 시점 경로는 `.ai/99_workspace/issue-0099-audit-report.md`, --clear로 이관).
EOF

assert_clear pass "clear 경로 검증: 제외 2건만 남은 디렉토리 통과" --refs "$arch"

printf '자세한 내용은 `.ai/90_issues/active/issue-0099/issue-0099-plan.md` 참조.\n' >> "$arch/issue-0099-summary.md"
assert_clear fail "clear 경로 검증: active 경로 잔존 격추" --refs "$arch"

printf '초안은 `.ai/99_workspace/issue-0099-comment.md`에 있다.\n' > "$arch/note.md"
assert_clear fail "clear 경로 검증: 99_workspace 참조 잔존 격추" --refs "$arch"

assert_clear usage "clear 경로 검증: 디렉토리 아님 (exit 2)" --refs "$arch/note.md"

# --- 보정률 집계 (summarize-metrics.sh) --------------------------------------------

metrics_ok="$sandbox/summary-metrics.md"
cat > "$metrics_ok" <<'EOF'
# Issue #99 실행요약

## Task별 수행 결과

<!--
- audit 발견: 이 Task와 관련된 발견 건수 — 없으면 `0건`
- 보정 반영: 승인을 통과해 실제로 보정한 건수 — 없으면 `0건`
- 재시도: 재수정·재시도 횟수 — 없으면 `0회`
예시 주석 안의 숫자 99건 은 집계에 섞이지 않아야 한다.
-->

### Task 0 (고정): 구현 시작 게이트

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5 (claude-opus-5)
- **audit 발견**: 1건
- **보정 반영**: 1건
- **재시도**: 0회

### Task 1: 본작업

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5 (claude-opus-5)
- **audit 발견**: 2건
- **보정 반영**: 1건
- **재시도**: 1회

### Task N (고정): 교차모델 issue-audit 검증

- **결과**: 완료
- **수행 내용 요약**: 감사 리포트 1건
EOF

out="$("$METRICS" "$metrics_ok" 2>&1)"
if printf '%s\n' "$out" | grep -qx '보정률: 2/3'; then
  ok "보정률 집계: 3건 중 2건 → 2/3"
else
  ng "보정률 집계: 기대 [보정률: 2/3], 실제 [$(printf '%s' "$out" | tr '\n' ' ')]"
fi
printf '%s\n' "$out" | grep -qx '재시도: 1회' \
  && ok "보정률 집계: 재시도 합산" \
  || ng "보정률 집계: 재시도 합산 실패 — $(printf '%s' "$out" | tr '\n' ' ')"

# 주석 안 예시 숫자가 집계에 섞이면 합계가 커진다 — 위 2/3 판정이 그 회귀도 함께 막는다.
printf '%s\n' "$out" | grep -qx 'audit 발견: 3건' \
  && ok "보정률 집계: 주석 안 예시 숫자를 제외" \
  || ng "보정률 집계: 주석 제거 실패 — $(printf '%s' "$out" | tr '\n' ' ')"

# assert_metrics_fail <설명> <변형 명령...>
assert_metrics_fail() {
  local desc="$1" want="$2"; shift 2
  local f="$sandbox/metrics-case.md" out rc
  cp "$metrics_ok" "$f"
  "$@" "$f" || { ng "$desc — 변형 실패"; return; }
  out="$("$METRICS" "$f" 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ]; then
    ng "$desc — exit 1 기대, 실제 $rc"
  elif printf '%s\n' "$out" | grep -qF "$want"; then
    ok "$desc"
  else
    ng "$desc — 사유에 '$want' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

m_dash()    { awk '{gsub(/^- \*\*audit 발견\*\*: 1건$/, "- **audit 발견**: -"); print}' "$1" > "$1.t" && mv "$1.t" "$1"; }
m_nofield() { awk '!/^- \*\*보정 반영\*\*:/' "$1" > "$1.t" && mv "$1.t" "$1"; }
m_taskn()   { printf -- '- **audit 발견**: 5건\n' >> "$1"; }
m_word()    { awk '{gsub(/^- \*\*재시도\*\*: 1회$/, "- **재시도**: 미기록"); print}' "$1" > "$1.t" && mv "$1.t" "$1"; }

# 5차 audit F-3 반례: Task 1 의 지표 3종을 지우고 Task 0 에 같은 수만큼 중복시킨다.
# 파일 전체 개수만 세면 누락과 중복이 상쇄돼 계약 위반 summary 가 그대로 집계된다.
m_offset() {
  awk '
    /^### Task 1:/ { s = 1 }
    s && /^- \*\*(audit 발견|보정 반영|재시도)\*\*:/ { next }
    { print }
    /^- \*\*재시도\*\*: 0회$/ && !d { print "- **audit 발견**: 2건"; print "- **보정 반영**: 1건"; print "- **재시도**: 1회"; d = 1 }
  ' "$1" > "$1.t" && mv "$1.t" "$1"
}
# 이웃 반례: 한 Task 만 필드가 빠진 경우 (다른 Task 에는 그대로 있어 전역 개수는 0이 아니다).
m_onemiss() {
  awk '
    /^### Task 1:/ { s = 1 }
    s && /^- \*\*보정 반영\*\*:/ { next }
    { print }
  ' "$1" > "$1.t" && mv "$1.t" "$1"
}

assert_metrics_fail '보정률 집계: `-` 표기 격추'        "'audit 발견' 표기가"    m_dash
assert_metrics_fail '보정률 집계: 필드 누락 격추'        "'보정 반영' 필드를"     m_nofield
assert_metrics_fail '보정률 집계: Task N 지표 격추'      'Task N 블록에'          m_taskn
assert_metrics_fail '보정률 집계: 비수치 값 격추'        "'재시도' 표기가"        m_word
assert_metrics_fail '보정률 집계: Task별 누락+중복 상쇄(5차 audit F-3 반례) 격추' \
  "'audit 발견' 필드가 2개입니다"  m_offset
assert_metrics_fail '보정률 집계: 한 Task 만 필드 누락 격추' \
  "'보정 반영' 필드를"             m_onemiss

"$METRICS" >/dev/null 2>&1
[ $? -eq 2 ] && ok "사용오류: 인자 없음 (exit 2)" || ng "사용오류: 인자 없음 — exit 2 기대"
"$METRICS" "$sandbox/absent.md" >/dev/null 2>&1
[ $? -eq 2 ] && ok "사용오류: 읽을 수 없는 파일 (exit 2)" || ng "사용오류: 읽을 수 없는 파일 — exit 2 기대"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
