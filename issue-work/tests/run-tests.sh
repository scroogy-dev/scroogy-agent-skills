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
# `P=`/`S=`/`R=` 경로 할당 행은 제외한다 — fixture 경로는 호출자(run_gate·assert_pair_gate·assert_example)가
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
      if (line !~ /^[PRS]=/) print line
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
# Task 1 수행 모델은 모델 ID 확인 불가 표기 `(-)`가 수행 모델 게이트를 통과함을 고정한다(#104).
base="$sandbox/summary-valid.md"
cat > "$base" <<'EOF'
# Issue #99 실행요약 — 게이트 테스트 fixture

## Task별 수행 결과

### Task 0 (고정): 구현 시작 게이트 — 전제·모호점 확인

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 4.8 (claude-opus-4-8)
- **수행 effort**: high
- **audit 발견**: 0건

### Task 1: 본작업

- **결과**: 부분 완료
- **수행 모델**: OpenAI, GPT-6 (-)
- **수행 effort**: xhigh
- **audit 발견**: 1건

### Task 2: 후속 작업

- **결과**: 스킵
- **수행 모델**: -
- **수행 effort**: -
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
# 소속 비교는 접두사 매칭이 아니라 계약이 고정한 정확한 섹션명과의 동등 비교다 —
# 접두사 매칭은 `## 요구사항 참고` 같은 유사 헤더 아래 배치를 통과시킨다.
# 포함 목록의 R 번호와 DoD `### R<n>` 그룹은 1:1 대응해야 한다 —
# R1 개수만 세면 R2 그룹 삭제가 통과해 포함 R2 가 DoD 연결 없이 남는다.
# 섹션 순서(목표 → 요구사항 → DoD)는 헤더 위치로 판정한다 —
# 소속만 보면 요구사항 블록 전체를 DoD 뒤로 옮겨도 통과한다.
# 목표 헤더도 개수를 판정한다 — 위치 판정은 헤더가 있을 때만 걸려 삭제·중복이 통과한다.
# R 번호 집합은 출현 횟수로 누적한다 — 불리언 대입은 같은 번호의 중복 그룹·항목을 잃는다.
# `(회귀 방지 항목)` 표시는 issue-audit 관점 2 가 spec 항목 본문에서만 인정하는 예외 계약이다 —
# DoD 주석의 표시 규칙과 R1·공통 예시의 첫 `[D]` 항목 본문 줄을 판정한다 (PR #109 리뷰 반례).
check_spec_structure() {
  awk '
    /^## /                           { sec = $0; list = "" }
    /^##/                            { g = "" }
    /^### R1: /                      { g = "R1" }
    /^### 공통$/                     { g = "공통" }
    g != "" && /^- \[ \] \[D\]/ && !seen[g]++ { if (index($0, "(회귀 방지 항목)")) mark[g]++ }
    /^- 회귀 방지 항목 표시: / && index($0, "`(회귀 방지 항목)`") { if (sec == "## 완료의 정의 (Definition of Done)") rule++ }
    /^## 목표 \(Goal\)$/             { goal++; goal_at = NR }
    /^## 요구사항 \(Requirements\)$/ { req++; req_at = NR }
    /^## 완료의 정의 \(Definition of Done\)$/ { dod_at = NR }
    /^\*\*포함\*\*$/                 { inc++; if (sec != "## 요구사항 (Requirements)") mis++; inc_at = NR; list = "inc" }
    /^\*\*제외\*\*$/                 { exc++; if (sec != "## 요구사항 (Requirements)") mis++; exc_at = NR; list = "exc" }
    list == "inc" && /^- /           { if ($0 ~ /^- R[0-9]+: /) { inc_items++
                                         n = $0; sub(/^- R/, "", n); sub(/:.*/, "", n); inc_rs[n]++
                                       } else inc_bad++ }
    list == "exc" && /^- /           { exc_items++ }
    /^### R[0-9]+: /                 { if (sec != "## 완료의 정의 (Definition of Done)") dod_mis++
                                       n = $0; sub(/^### R/, "", n); sub(/:.*/, "", n); dod_rs[n]++ }
    /^### R1: /                      { r1++ }
    /^### 공통$/                     { com++; if (sec != "## 완료의 정의 (Definition of Done)") dod_mis++ }
    /^## 범위/                       { scope++ }
    /포함 \(In\)|비포함 ?\(Out\)/    { old++ }
    END {
      if (goal != 1)      print "목표 헤더 " goal + 0 "개 (기대 1개)"
      if (req != 1)       print "요구사항 헤더 " req + 0 "개 (기대 1개)"
      if (inc != 1)       print "포함 표기 " inc + 0 "개 (기대 1개)"
      if (exc != 1)       print "제외 표기 " exc + 0 "개 (기대 1개)"
      if (mis)            print "포함·제외 표기가 요구사항 섹션 밖: " mis "개"
      if (inc == 1 && exc == 1 && inc_at > exc_at) print "포함·제외 순서 역전"
      if (goal_at && req_at && goal_at > req_at) print "목표·요구사항 섹션 순서 역전"
      if (req_at && dod_at && req_at > dod_at)   print "요구사항·완료의 정의 섹션 순서 역전"
      if (inc_items < 1)  print "포함 목록에 R<n> 항목 없음"
      if (inc_bad)        print "포함 목록에 R<n> 형식 아닌 항목: " inc_bad "개"
      if (exc_items < 1)  print "제외 목록에 항목 없음"
      if (r1 != 1)        print "DoD R 그룹 예시 헤더 " r1 + 0 "개 (기대 1개)"
      if (com != 1)       print "DoD 공통 그룹 헤더 " com + 0 "개 (기대 1개)"
      if (dod_mis)        print "DoD 그룹 헤더가 완료의 정의 섹션 밖: " dod_mis "개"
      for (n in inc_rs) if (!(n in dod_rs)) print "포함 R" n " 에 대응하는 DoD 그룹 없음"
      for (n in dod_rs) if (!(n in inc_rs)) print "포함 목록에 없는 DoD R" n " 그룹"
      for (n in inc_rs) if (inc_rs[n] > 1) print "포함 R" n " 항목 중복: " inc_rs[n] "개"
      for (n in dod_rs) if (dod_rs[n] > 1) print "DoD R" n " 그룹 중복: " dod_rs[n] "개"
      if (scope)          print "범위 헤더 잔존 (경계는 제외 목록으로 일원화)"
      if (old)            print "옛 포함(In)·비포함(Out) 표기 잔존"
      if (rule != 1)      print "DoD 주석의 회귀 방지 항목 표시 규칙 " rule + 0 "개 (기대 1개)"
      if (!mark["R1"])    print "DoD R1 예시 첫 [D] 항목 본문에 (회귀 방지 항목) 표시 없음"
      if (!mark["공통"])  print "DoD 공통 예시 첫 [D] 항목 본문에 (회귀 방지 항목) 표시 없음"
    }
  ' "$1"
}

# check_plan_structure <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 총개수 비교는 고정 Task 의 오기와 일반 Task 의 누락이 상쇄되어 통과하므로
# 블록 단위로 센다. 고정 Task 는 spec R4 가 명명한 Task 0·Task N 뿐이므로 이 두 식별자에
# `(고정)` 표기가 붙은 헤더만 고정으로 분류한다 — 표기만 믿으면 일반 Task 헤더에 표기를 붙여
# 필드 계약을 우회하고, 부분 문자열 `고정` 매칭은 일반 Task 제목에 든 단어까지 오분류한다.
# 개수만 세면 값 형식 위반과 `목표` 다음 행 이탈이 통과하므로 (F-2),
# 값이 유효한 `R<n>[, R<m>]` 나열인지와 직전 행이 `목표` 필드인지도 함께 판정한다.
# 첫 Task 앞의 필드는 블록 단위 집계가 보지 못하므로 별도 위반으로 센다 (일반 Task에만 필드를 두는 계약).
# 값 형식만 보면 spec 포함 목록에 없는 번호(dangling 참조)가 형식상 통과하므로,
# spec 템플릿의 포함 R 번호 집합과 대조해 Task→요구사항 연결이 실제로 이어지는지도 판정한다.
check_plan_structure() {
  local valid
  valid="$(awk '/^\*\*포함\*\*$/ { list = 1; next } /^\*\*/ { list = 0 }
               list && /^- R[0-9]+: / { n = $0; sub(/^- /, "", n); sub(/:.*/, "", n); printf "%s ", n }' \
    "$SPEC_TPL")"
  awk -v valid="$valid" '
    BEGIN { split(valid, a); for (i in a) ok_rs[a[i]] = 1 }
    function flush() { if (!o) return
      if (fixed && c > 0) print "고정 Task에 대상 요구사항 필드: " t
      if (!fixed && c != 1) print "일반 Task 필드 " c "개: " t }
    /^### Task / { flush(); o = 1; t = $0; c = 0; fixed = ($0 ~ /^### Task (0|N) \(고정\)/) }
    !o && /^- \*\*대상 요구사항\*\*:/ { print "필드가 Task 블록 밖 (" NR "행)" }
    o && /^- \*\*대상 요구사항\*\*:/ {
      c++
      if ($0 !~ /^- \*\*대상 요구사항\*\*: R[0-9]+(, R[0-9]+)*$/) print "필드 값이 R<n> 나열이 아님: " t
      else {
        v = $0; sub(/^- \*\*대상 요구사항\*\*: /, "", v); gsub(/, /, " ", v)
        m = split(v, rs); for (i = 1; i <= m; i++)
          if (!(rs[i] in ok_rs)) print "필드 값이 spec 포함 목록에 없음(" rs[i] "): " t
      }
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
# PR #95 2차 리뷰 반례: R1 외 그룹의 소속 이탈 — 소속 검사가 R1 패턴에만 걸리면 R2 이동이 통과한다.
awk '!/^### R2: /{print} END{print ""; print "### R2: <짧은 이름>"}' "$SPEC_TPL" > "$sandbox/s-r2-outside.md"
# PR #95 3차 리뷰 반례: 소속 접두사 매칭 우회 — 원 헤더는 비워 두고 블록을 유사 헤더 아래로
# 옮기면 `^## 요구사항`·`^## 완료의 정의` 접두사에 걸려 위반 0건으로 통과한다.
awk '/^\*\*포함\*\*$/{hold=1} /^## 완료의 정의/{hold=0} hold{buf = buf $0 "\n"; next} {print}
     END{print ""; print "## 요구사항 참고"; print ""; printf "%s", buf}' \
  "$SPEC_TPL" > "$sandbox/s-req-lookalike.md"
awk '/^### R1: /{hold=1} /^### 공통$/{hold=0} hold{buf = buf $0 "\n"; next} {print}
     END{print ""; print "## 완료의 정의 참고"; print ""; printf "%s", buf}' \
  "$SPEC_TPL" > "$sandbox/s-dod-lookalike.md"
# PR #95 3차 리뷰 반례: R2 그룹 통삭제 — R1 개수·소속 검사만으로는 포함 R2 의 DoD 연결 소실이 통과한다.
awk '/^### R2: /{skip=1} skip && /^### 공통$/{skip=0} !skip' "$SPEC_TPL" > "$sandbox/s-no-r2group.md"
# PR #95 4차 리뷰 반례: 소속·1:1 대응만으로는 통과하는 변형 —
# 요구사항 블록 전체를 DoD 뒤로 이동 / 같은 번호의 DoD 그룹·포함 항목 중복.
awk '/^## 요구사항 \(Requirements\)$/{hold=1} /^## 완료의 정의/{hold=0} hold{buf = buf $0 "\n"; next}
     /^## 전제/ && buf{printf "%s", buf; buf=""} {print}' "$SPEC_TPL" > "$sandbox/s-req-after-dod.md"
awk '{print} /^### R2: /{print ""; print "### R2: <짧은 이름>"}' "$SPEC_TPL" > "$sandbox/s-dup-rgroup.md"
awk '{print} /^- R2: /{print $0}' "$SPEC_TPL" > "$sandbox/s-dup-ritem.md"
# PR #95 5차 리뷰 반례: 목표 헤더 삭제·중복 — 위치 판정은 헤더가 있을 때만 걸려 개수 없이는 통과한다.
awk '!/^## 목표 \(Goal\)$/' "$SPEC_TPL" > "$sandbox/s-no-goal.md"
awk '{print} END{print ""; print "## 목표 (Goal)"}' "$SPEC_TPL" > "$sandbox/s-dup-goal.md"
# PR #109 리뷰 반례: 회귀 방지 표시 계약 — 주석 규칙 삭제 / R1 예시 표시 삭제 / 공통 예시 표시를 접기 안으로 이동.
awk '!/^- 회귀 방지 항목 표시: /' "$SPEC_TPL" > "$sandbox/s-no-mark-rule.md"
awk '/^### R1: /{g=1} /^### R2: /{g=0} g && /^- \[ \] \[D\]/{sub(/ \(회귀 방지 항목\)/, "")} {print}' \
  "$SPEC_TPL" > "$sandbox/s-no-r1-mark.md"
awk '/^### 공통$/{g=1} g && /^- \[ \] \[D\]/{sub(/ \(회귀 방지 항목\)/, ""); m=1}
     g && m && /<summary>/{sub(/<\/summary>/, " (회귀 방지 항목)</summary>"); m=0} {print}' \
  "$SPEC_TPL" > "$sandbox/s-common-mark-folded.md"

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
assert_structure check_spec_structure "$sandbox/s-r2-outside.md"     fail "spec 구조: DoD R2 그룹 헤더 섹션 밖 이동(PR #95 2차 리뷰 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-req-lookalike.md"  fail "spec 구조: 유사 헤더 아래 포함·제외 이동(PR #95 3차 리뷰 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-dod-lookalike.md"  fail "spec 구조: 유사 헤더 아래 DoD 그룹 이동 격추"
assert_structure check_spec_structure "$sandbox/s-no-r2group.md"     fail "spec 구조: DoD R2 그룹 삭제(포함 목록과 1:1 대응) 격추"
assert_structure check_spec_structure "$sandbox/s-req-after-dod.md"  fail "spec 구조: 요구사항 섹션 DoD 뒤 이동(PR #95 4차 리뷰 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-dup-rgroup.md"     fail "spec 구조: DoD R2 그룹 중복 격추"
assert_structure check_spec_structure "$sandbox/s-dup-ritem.md"      fail "spec 구조: 포함 R2 항목 중복 격추"
assert_structure check_spec_structure "$sandbox/s-no-goal.md"        fail "spec 구조: 목표 헤더 소실(PR #95 5차 리뷰 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-dup-goal.md"       fail "spec 구조: 목표 헤더 중복 격추"
assert_structure check_spec_structure "$sandbox/s-no-mark-rule.md"   fail "spec 구조: 회귀 방지 표시 규칙 삭제(PR #109 리뷰 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-no-r1-mark.md"     fail "spec 구조: R1 예시 회귀 방지 표시 삭제 격추"
assert_structure check_spec_structure "$sandbox/s-common-mark-folded.md" fail "spec 구조: 공통 예시 회귀 방지 표시 접기 안 이동 격추"

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
# PR #95 2차 리뷰 반례: 첫 Task 앞의 최상위 필드 — 블록 집계만으로는 정상 필드가 남아 있어 통과한다.
awk 'NR == 1 { print; print ""; print "- **대상 요구사항**: R1"; next } { print }' \
  "$TEMPLATE" > "$sandbox/p-field-outside.md"
# PR #95 3차 리뷰 반례: dangling 참조 — 형식은 유효하나 spec 포함 목록에 없는 번호는 연결이 끊긴다.
awk '{gsub(/^- \*\*대상 요구사항\*\*: R1$/, "- **대상 요구사항**: R999"); print}' \
  "$TEMPLATE" > "$sandbox/p-field-dangling.md"
# PR #95 5차 리뷰 반례: 일반 Task 를 `(고정)`으로 개서하고 필드 삭제 — 표기만 믿으면 필드 계약을 우회한다.
awk '/^### Task 2/{s=1} /^### Task N/{s=0} s && /^- \*\*대상 요구사항\*\*:/{next}
     {gsub(/^### Task 2: /, "### Task 2 (고정): "); print}' \
  "$TEMPLATE" > "$sandbox/p-general-as-fixed.md"

assert_structure check_plan_structure "$TEMPLATE"                   pass "plan 구조: 실제 템플릿 통과"
assert_structure check_plan_structure "$sandbox/p-field-missing.md" fail "plan 구조: 일반 Task 필드 누락 격추"
assert_structure check_plan_structure "$sandbox/p-field-fixed.md"   fail "plan 구조: 고정 Task 필드 오기 격추"
assert_structure check_plan_structure "$sandbox/p-field-dup.md"     fail "plan 구조: 필드 중복 격추"
assert_structure check_plan_structure "$sandbox/p-field-offset.md"  fail "plan 구조: 누락+오기 상쇄(총개수 우회) 격추"
assert_structure check_plan_structure "$sandbox/p-field-moved.md"   fail "plan 구조: 필드 위치 이동(2차 audit F-2 반례) 격추"
assert_structure check_plan_structure "$sandbox/p-field-empty.md"   fail "plan 구조: 필드 빈 값 격추"
assert_structure check_plan_structure "$sandbox/p-field-invalid.md" fail "plan 구조: 필드 값 형식 위반 격추"
assert_structure check_plan_structure "$sandbox/p-fixed-in-title.md" pass "plan 구조: 일반 Task 제목의 고정 단어 오분류 없음(PR #95 리뷰 반례)"
assert_structure check_plan_structure "$sandbox/p-field-outside.md"  fail "plan 구조: Task 밖 최상위 필드(PR #95 2차 리뷰 반례) 격추"
assert_structure check_plan_structure "$sandbox/p-field-dangling.md" fail "plan 구조: spec 포함 목록에 없는 dangling 참조(PR #95 3차 리뷰 반례) 격추"
assert_structure check_plan_structure "$sandbox/p-general-as-fixed.md" fail "plan 구조: 일반 Task의 (고정) 개서 우회(PR #95 5차 리뷰 반례) 격추"

# --- summary 템플릿 effort 구조 (PR #103 리뷰 반례) -------------------------------
#
# 모델 기록 표 effort 열과 Task `수행 effort` 행은 issue-0102 spec R1·R2 의 일회성 [D]
# 명령으로만 검증되었고, 게이트·집계 파서는 effort 행을 읽지 않는다 — 삭제·이동해도
# 정규 러너가 통과하므로 여기에 편입한다.
# 표 행은 이름별로 센다 — 총 행 수만 보면 한 행 삭제와 다른 행 중복이 상쇄된다.
# 이름별 개수와 함께 헤더·구분선 바로 뒤 4행의 이름·순서도 본다 — 개수만 보면 행을
# 표 밖(파일 끝 등)으로 옮겨도 통과한다(PR #103 2차 리뷰 반례).
# 구분선도 셀을 정확히 3개로 본다 — 셀 수를 보지 않으면 effort 구분 셀 삭제가 통과한다(PR #103 3차 리뷰 반례).
# Task 블록도 블록 단위로 센다 — 한 블록의 누락을 다른 블록의 중복으로 상쇄할 수 없다.
# PR #105 리뷰 보강: 모델 ID 형식(issue #104)은 spec R1 의 일회성 [D] 명령으로만 검증되었고,
# 게이트는 `수행 모델` 값의 첫 글자만 본다 — 구 형식 단독 표기 0건, 괄호 전용·확인 불가 (-) 계약 문장,
# `수행 모델` 나열 예시의 항목별 괄호를 판정한다.
# PR #105 3차 리뷰 보강: 모델 기록 표 행마다 모델 열의 형식 안내를 본다 — 파일 전체 카운터만 보면
# 한 행에서 형식 안내 문구 전체를 지워도 다른 행의 확장 형식이 남아 통과한다.

SUMMARY_TPL="$HERE/../templates/issue-summary-template.md"

# check_summary_structure <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_summary_structure() {
  awk -F'|' '
    function chk() { if (!t) return
      if (n) { if (e) print "Task N 블록에 수행 effort 행: " t }
      else if (e != 1) print "수행 effort 행 " e + 0 "개: " t }
    BEGIN { split("계획 모델|계획 audit 모델|구현 모델|최종 audit 모델", want, "|") }
    /^\| 구분 \| 모델 \| effort \|$/ { hdr++; h = NR; next }
    h && NR == h + 1 && !/^\|-+\|-+\|-+\|$/ { print "모델 기록 표 3열 구분선이 헤더 바로 다음에 없음 (" NR "행)" }
    h && NR >= h + 2 && NR <= h + 5 {
      p = NR - h - 1; l = $2; gsub(/^ +| +$/, "", l)
      if (l != want[p]) print "모델 기록 표 " p "번째 행이 " want[p] " 아님 (" NR "행): " l }
    /^\| (계획 모델|계획 audit 모델|구현 모델|최종 audit 모델) \|/ {
      l = $2; gsub(/^ +| +$/, "", l); rows[l]++
      if (NF != 5) print "모델 기록 행 셀 수 " NF - 2 "개: " l
      if ($3 !~ /형식: 벤더, 모델명 \(모델 ID\)/) print "모델 기록 행 모델 열에 확장 형식 안내 없음: " l }
    /^### Task / { chk(); t = $0; n = ($0 ~ /^### Task N/); m = 0; e = 0 }
    !t && /^- \*\*수행 effort\*\*:/ { print "수행 effort 행이 Task 블록 밖 (" NR "행)" }
    t && /^- \*\*수행 모델\*\*:/ { m = NR }
    t && /^- \*\*수행 effort\*\*:/ { e++; if (NR != m + 1) print "수행 effort 행이 수행 모델 바로 다음이 아님: " t }
    { cp = $0; mfmt += gsub(/벤더, 모델명 \(모델 ID\)/, "", cp); mold += gsub(/벤더, 모델명/, "", cp) }
    /^괄호 안은 모델 ID 전용이며 / { idonly++ }
    /^모델 ID를 확인할 수 없으면 괄호를 남겨 `\(-\)`로 적는다\./ { unk++ }
    /^- 수행 모델: "벤더, 모델명 \(모델 ID\)" .*확인할 수 없으면 `\(-\)`로 적는다/ { tunk++ }
    /^  \(예: `[^`]* \/ [^`]*`\)/ { lx++
      match($0, /`[^`]*`/); k = split(substr($0, RSTART + 1, RLENGTH - 2), it, / \/ /)
      for (i = 1; i <= k; i++) if (it[i] !~ /[^ ] \([^()]+\)$/) print "수행 모델 나열 예시 " i "번째 항목에 모델 ID 괄호 없음: " it[i] }
    END { chk()
      if (mold)        print "구 형식 단독 표기(벤더, 모델명) 잔존: " mold "개"
      if (!mfmt)       print "확장 형식(벤더, 모델명 (모델 ID)) 표기 0개"
      if (idonly != 1) print "괄호 안 모델 ID 전용 문장 " idonly + 0 "개 (기대 1개)"
      if (unk != 1)    print "모델 기록 확인 불가 표기 (-) 문장 " unk + 0 "개 (기대 1개)"
      if (tunk != 1)   print "수행 모델 확인 불가 표기 (-) 안내 " tunk + 0 "개 (기대 1개)"
      if (lx != 1)     print "수행 모델 나열 예시 " lx + 0 "개 (기대 1개)"
      if (hdr != 1) print "모델 기록 표 헤더(구분·모델·effort) " hdr + 0 "개 (기대 1개)"
      for (i = 1; i <= 4; i++) if (rows[want[i]] != 1) print "모델 기록 " want[i] " 행 " rows[want[i]] + 0 "개 (기대 1개)" }
  ' "$1"
}

awk '{sub(/^\| 구분 \| 모델 \| effort \|$/, "| 구분 | 모델 |"); print}' "$SUMMARY_TPL" > "$sandbox/m-no-effort-col.md"
awk '/^\| 구현 모델 \|/{sub(/ \| <!--[^|]*--> \|$/, " |")} {print}' "$SUMMARY_TPL" > "$sandbox/m-row-cells.md"
awk '!/^\| 최종 audit 모델 \|/' "$SUMMARY_TPL" > "$sandbox/m-row-missing.md"
awk '/^\| 계획 audit 모델 \|/{next} {print} /^\| 구현 모델 \|/{print}' "$SUMMARY_TPL" > "$sandbox/m-row-offset.md"
# PR #103 2차 리뷰 반례: 행을 표 밖(파일 끝)으로 이동, 표 안 행 순서 교환 — 이름별 개수는 그대로다.
awk '/^\| 최종 audit 모델 \|/{held = $0; next} {print} END{print held}' "$SUMMARY_TPL" > "$sandbox/m-row-outside.md"
awk '/^\| 계획 audit 모델 \|/{held = $0; next} {print} /^\| 구현 모델 \|/{print held}' "$SUMMARY_TPL" > "$sandbox/m-row-order.md"
# PR #103 3차 리뷰 반례: 구분선에서 effort 구분 셀만 삭제 — 헤더·4개 행은 그대로다.
awk 'p && /^\|[-|]+\|$/{print "|------|------|"; p=0; next} {p = /^\| 구분 \| 모델 \| effort \|$/; print}' \
  "$SUMMARY_TPL" > "$sandbox/m-sep-cells.md"
awk '/^### Task 1:/{s=1} /^### Task 2:/{s=0} !(s && /^- \*\*수행 effort\*\*:/)' \
  "$SUMMARY_TPL" > "$sandbox/m-task-missing.md"
awk '{print} /^### Task 0/{s=1} s && /^- \*\*수행 effort\*\*:/{print; s=0}' "$SUMMARY_TPL" > "$sandbox/m-task-dup.md"
awk '/^### Task 2:/{s=1} /^### Task N/{s=0}
     s && /^- \*\*수행 effort\*\*:/ { held = $0; next }
     { print }
     s && held && /^- \*\*재시도\*\*:/ { print held; held = "" }' \
  "$SUMMARY_TPL" > "$sandbox/m-task-moved.md"
awk '{print} /^### Task N/{s=1} s && /^- \*\*결과\*\*:/{print "- **수행 effort**: -"; s=0}' \
  "$SUMMARY_TPL" > "$sandbox/m-taskn-effort.md"
awk '/^### Task 1:/{s=1} /^### Task 2:/{s=0; d=1} s && /^- \*\*수행 effort\*\*:/{next}
     {print} d && /^- \*\*수행 effort\*\*:/{print; d=0}' \
  "$SUMMARY_TPL" > "$sandbox/m-task-offset.md"
# PR #105 리뷰 반례(issue #104 모델 ID 형식): 구 형식 되돌림 / 한 행만 괄호 누락 / 계약 문장 삭제 / 나열 예시 괄호 누락.
awk '{gsub(/ \(모델 ID\)/, ""); print}' "$SUMMARY_TPL" > "$sandbox/m-id-old.md"
awk '/^\| 최종 audit 모델 \|/{sub(/ \(모델 ID\)/, "")} {print}' "$SUMMARY_TPL" > "$sandbox/m-id-row-old.md"
awk '!/^괄호 안은 모델 ID 전용이며 /' "$SUMMARY_TPL" > "$sandbox/m-id-no-only.md"
awk '!/^모델 ID를 확인할 수 없으면 괄호를 남겨 /' "$SUMMARY_TPL" > "$sandbox/m-id-no-unk.md"
awk '/^- 수행 모델: /{sub(/, 모델 ID를 확인할 수 없으면 `\(-\)`로 적는다/, "")} {print}' \
  "$SUMMARY_TPL" > "$sandbox/m-id-task-no-unk.md"
awk '/^  \(예: `/{sub(/ \(gpt-6-astra\)/, "")} {print}' "$SUMMARY_TPL" > "$sandbox/m-id-list-bare.md"
awk '/^  \(예: `/{sub(/ \(claude-opus-4-8\)/, "")} {print}' "$SUMMARY_TPL" > "$sandbox/m-id-list-first-bare.md"
# PR #105 3차 리뷰 반례: 한 행에서 형식 안내 문구 전체 삭제 — 구 형식 흔적이 남지 않는다.
awk '/^\| 계획 모델 \|/{sub(/ 형식: 벤더, 모델명 \(모델 ID\)/, "")} {print}' "$SUMMARY_TPL" > "$sandbox/m-id-row-no-fmt.md"

assert_structure check_summary_structure "$SUMMARY_TPL"               pass "summary 구조: 실제 템플릿 통과"
assert_structure check_summary_structure "$sandbox/m-no-effort-col.md" fail "summary 구조: 모델 기록 표 effort 열 삭제 격추"
assert_structure check_summary_structure "$sandbox/m-row-cells.md"    fail "summary 구조: 모델 기록 행 셀 소실 격추"
assert_structure check_summary_structure "$sandbox/m-row-missing.md"  fail "summary 구조: 모델 기록 행 삭제 격추"
assert_structure check_summary_structure "$sandbox/m-row-offset.md"   fail "summary 구조: 모델 기록 행 삭제+중복 상쇄 격추"
assert_structure check_summary_structure "$sandbox/m-row-outside.md"  fail "summary 구조: 모델 기록 행 표 밖 이동(PR #103 2차 리뷰 반례) 격추"
assert_structure check_summary_structure "$sandbox/m-row-order.md"    fail "summary 구조: 모델 기록 행 순서 교환(PR #103 2차 리뷰 반례) 격추"
assert_structure check_summary_structure "$sandbox/m-sep-cells.md"    fail "summary 구조: 구분선 effort 셀 삭제(PR #103 3차 리뷰 반례) 격추"
assert_structure check_summary_structure "$sandbox/m-task-missing.md" fail "summary 구조: 일반 Task 수행 effort 누락 격추"
assert_structure check_summary_structure "$sandbox/m-task-dup.md"     fail "summary 구조: Task 0 수행 effort 중복 격추"
assert_structure check_summary_structure "$sandbox/m-task-moved.md"   fail "summary 구조: 수행 effort 수행 모델 뒤 이탈 격추"
assert_structure check_summary_structure "$sandbox/m-taskn-effort.md" fail "summary 구조: Task N 블록 수행 effort 오기 격추"
assert_structure check_summary_structure "$sandbox/m-task-offset.md"  fail "summary 구조: 블록 간 누락+중복 상쇄 격추"
assert_structure check_summary_structure "$sandbox/m-id-old.md"       fail "summary 구조: 모델 ID 형식 구 형식 되돌림(PR #105 리뷰 반례) 격추"
assert_structure check_summary_structure "$sandbox/m-id-row-old.md"   fail "summary 구조: 모델 기록 한 행만 (모델 ID) 누락 격추"
assert_structure check_summary_structure "$sandbox/m-id-no-only.md"   fail "summary 구조: 괄호 안 모델 ID 전용 문장 삭제 격추"
assert_structure check_summary_structure "$sandbox/m-id-no-unk.md"    fail "summary 구조: 모델 기록 확인 불가 (-) 문장 삭제 격추"
assert_structure check_summary_structure "$sandbox/m-id-task-no-unk.md" fail "summary 구조: 수행 모델 확인 불가 (-) 안내 삭제 격추"
assert_structure check_summary_structure "$sandbox/m-id-list-bare.md" fail "summary 구조: 수행 모델 나열 예시 뒤 항목 괄호 누락 격추"
assert_structure check_summary_structure "$sandbox/m-id-list-first-bare.md" fail "summary 구조: 수행 모델 나열 예시 앞 항목 괄호 누락 격추"
assert_structure check_summary_structure "$sandbox/m-id-row-no-fmt.md" fail "summary 구조: 모델 기록 한 행만 형식 안내 전체 삭제(PR #105 3차 리뷰 반례) 격추"

# --- 테스트 관점 조항 (issue #112) ------------------------------------------------
#
# spec DoD [D] 는 외부 경계의 인수 테스트이고 구현 테스트는 plan Task 가 맡는다는 구분은
# 조항 문장이 곧 계약이다 — SKILL.md "완료 기준 형식" 절과 spec 템플릿 DoD 주석의 테스트 관점 행을
# 판정한다. 절 범위를 다음 헤더까지로 잘라, 같은 문구가 다른 절에 있어도 세지 않는다.
# 행 안의 조항(인수 테스트·외부 경계 목록·러너 호출 조건·명령 수준·plan Task 담당)마다 앵커 문구를 판정하고,
# 문구마다 삭제 반례를 격추한다 — 낱말 두 개만 보면 조건 문구를 지워도 통과한다 (PR #113 리뷰 반례).

# check_test_view_skill <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_test_view_skill() {
  awk '/^### 완료 기준 형식$/ { s = 1; next } /^#/ { s = 0 }
       s && /^- \*\*테스트 관점\*\*: / {
         n++
         if (!index($0, "`[D]`는 계획 관점의 인수 테스트"))
           print "테스트 관점 행에 계획 관점 인수 테스트 언급 없음"
         if (!index($0, "외부 경계(명령 인자·종료 코드·출력 행·파일 내용)"))
           print "테스트 관점 행에 외부 경계 목록 없음"
         if (!index($0, "경계가 spec에 고정되면 테스트 러너 호출로 적을 수 있고"))
           print "테스트 관점 행에 러너 호출 조건 없음"
         if (!index($0, "구현 중에 정해지면 명령 수준으로 둡니다"))
           print "테스트 관점 행에 명령 수준 조건 없음"
         if (!index($0, "그 기능을 만드는 plan Task의 `작업 내용`·`완료 기준`이 맡습니다"))
           print "테스트 관점 행에 구현 테스트의 plan Task 담당 없음"
       }
       END { if (n != 1) print "테스트 관점 행 " n + 0 "개 (기대 1개)" }' "$1"
}

# check_test_view_spec <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_test_view_spec() {
  awk '/^## 완료의 정의 \(Definition of Done\)$/ { s = 1; next } /^## / { s = 0 }
       s && /^- 테스트 관점: / {
         n++
         if (!index($0, "외부 경계(명령 인자·종료 코드·출력 행·파일 내용)"))
           print "spec 템플릿 테스트 관점 행에 외부 경계 목록 없음"
         if (!index($0, "인수 테스트"))
           print "spec 템플릿 테스트 관점 행에 인수 테스트 언급 없음"
       }
       END { if (n != 1) print "spec 템플릿 테스트 관점 행 " n + 0 "개 (기대 1개)" }' "$1"
}

# drop_literal <파일> <문자열> → 문자열을 정규식 해석 없이 지운 사본을 표준 출력으로
drop_literal() {
  awk -v s="$2" '{ while ((i = index($0, s))) $0 = substr($0, 1, i - 1) substr($0, i + length(s)); print }' "$1"
}

awk '!/^- \*\*테스트 관점\*\*: /' "$SKILL" > "$sandbox/tv-skill-del.md"
awk '!/^- 테스트 관점: /' "$SPEC_TPL" > "$sandbox/tv-spec-del.md"
drop_literal "$SKILL" '`[D]`는 계획 관점의 인수 테스트' > "$sandbox/tv-skill-no-accept.md"
drop_literal "$SKILL" '외부 경계(명령 인자·종료 코드·출력 행·파일 내용)' > "$sandbox/tv-skill-no-boundary.md"
drop_literal "$SKILL" '경계가 spec에 고정되면 테스트 러너 호출로 적을 수 있고' > "$sandbox/tv-skill-no-runner.md"
drop_literal "$SKILL" '구현 중에 정해지면 명령 수준으로 둡니다' > "$sandbox/tv-skill-no-cmd.md"
drop_literal "$SKILL" '그 기능을 만드는 plan Task의 `작업 내용`·`완료 기준`이 맡습니다' > "$sandbox/tv-skill-no-task.md"
drop_literal "$SPEC_TPL" '외부 경계(명령 인자·종료 코드·출력 행·파일 내용)' > "$sandbox/tv-spec-no-boundary.md"
drop_literal "$SPEC_TPL" '인수 테스트' > "$sandbox/tv-spec-no-accept.md"

assert_structure check_test_view_skill "$SKILL"                    pass "테스트 관점: SKILL.md 완료 기준 형식 행 통과"
assert_structure check_test_view_skill "$sandbox/tv-skill-del.md"  fail "테스트 관점: SKILL.md 완료 기준 형식 행 삭제 격추"
assert_structure check_test_view_skill "$sandbox/tv-skill-no-accept.md"   fail "테스트 관점: SKILL.md 계획 관점 인수 테스트 문구 삭제 격추"
assert_structure check_test_view_skill "$sandbox/tv-skill-no-boundary.md" fail "테스트 관점: SKILL.md 외부 경계 목록 삭제(PR #113 리뷰 반례) 격추"
assert_structure check_test_view_skill "$sandbox/tv-skill-no-runner.md"   fail "테스트 관점: SKILL.md 러너 호출 조건 삭제(PR #113 리뷰 반례) 격추"
assert_structure check_test_view_skill "$sandbox/tv-skill-no-cmd.md"      fail "테스트 관점: SKILL.md 명령 수준 조건 삭제 격추"
assert_structure check_test_view_skill "$sandbox/tv-skill-no-task.md"     fail "테스트 관점: SKILL.md 구현 테스트 plan Task 담당 삭제 격추"
assert_structure check_test_view_spec  "$SPEC_TPL"                 pass "테스트 관점: spec 템플릿 DoD 주석 행 통과"
assert_structure check_test_view_spec  "$sandbox/tv-spec-del.md"   fail "테스트 관점: spec 템플릿 DoD 주석 행 삭제 격추"
assert_structure check_test_view_spec  "$sandbox/tv-spec-no-boundary.md"  fail "테스트 관점: spec 템플릿 외부 경계 목록 삭제(PR #113 리뷰 반례) 격추"
assert_structure check_test_view_spec  "$sandbox/tv-spec-no-accept.md"    fail "테스트 관점: spec 템플릿 인수 테스트 문구 삭제 격추"

# --- 테스트 배치 (issue #112) ------------------------------------------------------
#
# 구현 테스트를 각 Task 의 `작업 내용`·`완료 기준`에 두는 규칙은 plan 템플릿의 머리말 문단,
# Task 1 예시 `작업 내용` 주석, Task 1 예시 테스트 [D] 항목이 계약이다 — spec R2 [D] 와 같은 범위·앵커로 판정한다.
# 테스트 [D] 예시는 모양만 보면 명령이 판정을 못 해도 통과하므로, 예시 명령을 템플릿에서 추출해
# fixture 러너 5종에 실행한다 (Task N 게이트와 같은 추출 방식, `R=` 행은 떼고 fixture 러너 경로를 주입).

# check_placement_header <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# blockquote 문단이 여러 행에 걸치므로 `>` 빈 행 또는 `>` 아닌 행 전까지를 한 문단으로 모은다.
check_placement_header() {
  awk '/^## Tasks$/ { s = 1 } /^### Task 0/ { s = 0 }
       s && /^> \*\*테스트 배치\*\*/ { p = 1; n++ }
       p && (/^>[[:space:]]*$/ || !/^>/) { p = 0 }
       p { t = t $0 }
       END { if (n != 1) print "테스트 배치 규칙 " n + 0 "개 (기대 1개)"
             else { if (t !~ /테스트 자체가 작업 대상/) print "테스트 배치 규칙에 별도 테스트 Task 조건 문구 없음"
                    if (t !~ /회귀 방지/) print "테스트 배치 규칙에 공통 회귀 항목 문구 없음" } }' "$1"
}

# check_placement_comment <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 필드 앵커로 범위를 자르므로 같은 주석을 `완료 기준` 등 다른 필드로 옮기면 실패한다.
check_placement_comment() {
  awk '/^### Task 1: / { s = 1 } /^### Task 2: / { s = 0 }
       s && /^- \*\*작업 내용\*\*:/ { f = 1 }
       s && /^- \*\*완료 기준\*\*:/ { f = 0 }
       s && /<!--/ && /테스트 작성/ && /산출물/ { if (f) n++; else o++ }
       END { if (n != 1) print "Task 1 작업 내용 테스트 배치 주석 " n + 0 "행 (기대 1행)"
             if (o > 0) print "Task 1 작업 내용 밖에 테스트 배치 주석 " o "행 (기대 0행)" }' "$1"
}

# check_placement_example <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 접기 구성 요소를 전수 열거한다. 러너 경로·grep 행은 bash 코드 블록 안에서만 세고 주석 행은 건너뛴다.
check_placement_example() {
  awk '/^### Task 1: / { s = 1 } /^### Task 2: / { s = 0; c = 0 }
       s && /^  - \[D\] / && /테스트/ && /0 실패/ { n++; c = 1; next }
       c && /^  - \[/ { c = 0 }
       c && /^    <details>/ { d++ }
       c && /^    <\/details>/ { e++ }
       c && !inb && /^    ```bash/ { b++; inb = 1; next }
       c && inb && /^    ```[[:space:]]*$/ { inb = 0; next }
       c && inb && /^[[:space:]]*#/ { next }
       c && inb && /run-tests\.sh/ { r++ }
       c && inb && /grep/ && / 통과/ { g1++ }
       c && inb && /grep/ && / 격추/ { g2++ }
       c && /설계 주의/ && /구현 전/ { w++ }
       END { if (n != 1) print "Task 1 테스트 [D] 예시 " n + 0 "개 (기대 1개)"
             else { if (d != 1 || e != 1) print "테스트 [D] 예시 접기 details 여닫음 " d + 0 "/" e + 0 " (기대 1/1)"
                    if (b < 1) print "테스트 [D] 예시 접기에 bash 코드 블록 없음"
                    if (r < 1) print "테스트 [D] 예시 코드 블록에 러너 경로 행 없음(주석 제외)"
                    if (g1 < 1 || g2 < 1) print "테스트 [D] 예시 코드 블록에 통과·격추 grep 행 " g1 + 0 "/" g2 + 0 " (기대 각 1 이상, 주석 제외)"
                    if (w < 1) print "테스트 [D] 예시 접기에 구현 전 통과 설계 주의 없음" } }' "$1"
}

awk '/^> \*\*테스트 배치\*\*/ { p = 1 } p && /^>[[:space:]]*$/ { p = 0 } !p' "$TEMPLATE" > "$sandbox/tp-header-del.md"
awk '!(/<!--/ && /테스트 작성/ && /산출물/)' "$TEMPLATE" > "$sandbox/tp-comment-del.md"
awk '/^### Task 1: /{s=1} /^### Task 2: /{s=0}
     s && /<!--/ && /테스트 작성/ && /산출물/ { held = $0; next }
     { print }
     s && held && /^- \*\*완료 기준\*\*:/ { print held; held = "" }' \
  "$TEMPLATE" > "$sandbox/tp-comment-moved.md"
awk '/^### Task 1: /{s=1} /^### Task 2: /{s=0}
     s && /^  - \[D\] / && /테스트/ && /0 실패/ { d = 1; next }
     d && /^  - \[/ { d = 0 }
     !d' "$TEMPLATE" > "$sandbox/tp-example-del.md"

assert_structure check_placement_header  "$TEMPLATE"                    pass "테스트 배치: 머리말 문단 통과"
assert_structure check_placement_header  "$sandbox/tp-header-del.md"    fail "테스트 배치: 머리말 문단 삭제 격추"
assert_structure check_placement_comment "$TEMPLATE"                    pass "테스트 배치: Task 1 작업 내용 주석 통과"
assert_structure check_placement_comment "$sandbox/tp-comment-del.md"   fail "테스트 배치: Task 1 작업 내용 주석 삭제 격추"
assert_structure check_placement_comment "$sandbox/tp-comment-moved.md" fail "테스트 배치: Task 1 주석의 완료 기준 이동 격추"
assert_structure check_placement_example "$TEMPLATE"                    pass "테스트 배치: Task 1 테스트 [D] 예시 통과"
assert_structure check_placement_example "$sandbox/tp-example-del.md"   fail "테스트 배치: Task 1 테스트 [D] 예시 삭제 격추"

# 예시 명령 실행: 정상 러너는 출력 0건, `ok` 행 없는 러너·한쪽 행만 있는 러너·종료 1 러너는 위반 행을 내야 한다.
GATE_T="$(extract_gate '새 케이스를 포함해 0 실패로 통과')"

case "$GATE_T" in
  *'<skill>'*) ng "추출: 테스트 배치 예시 명령 — 러너 경로 할당 행이 제거되지 않음 (fixture 경로 주입 계약 위반)" ;;
  out=*) ok "추출: 테스트 배치 예시 명령" ;;
  *) ng "추출: 테스트 배치 예시 명령 — [$GATE_T]" ;;
esac

# fixture 러너는 템플릿 예시의 `<라벨>` 자리표시자를 그대로 담은 `ok` 행을 낸다.
mkdir -p "$sandbox/runners"
cat > "$sandbox/runners/pair.sh" <<'EOF'
#!/usr/bin/env bash
echo 'ok     - <라벨>: 정상 입력 통과'
echo 'ok     - <라벨>: 반례 격추'
EOF
cat > "$sandbox/runners/no-case.sh" <<'EOF'
#!/usr/bin/env bash
echo 'passed: 0, failed: 0'
EOF
# 한쪽 행만 있는 러너: 통과·격추 하한 중 하나가 무력화되면 이 입력을 받아들인다.
cat > "$sandbox/runners/pass-only.sh" <<'EOF'
#!/usr/bin/env bash
echo 'ok     - <라벨>: 정상 입력 통과'
EOF
cat > "$sandbox/runners/fail-only.sh" <<'EOF'
#!/usr/bin/env bash
echo 'ok     - <라벨>: 반례 격추'
EOF
cat > "$sandbox/runners/exit1.sh" <<'EOF'
#!/usr/bin/env bash
echo 'ok     - <라벨>: 정상 입력 통과'
echo 'ok     - <라벨>: 반례 격추'
echo 'NOT OK - <라벨>: 다른 케이스'
exit 1
EOF
chmod +x "$sandbox/runners/"*.sh

# assert_example <fixture 러너> <기대: pass|fail> <설명>
# 예시 명령은 출력 자체로 판정한다 (출력 0건이면 통과). 러너 경로는 로컬 변수 `R` 로 주입한다.
assert_example() {
  local out R="$1"
  out="$(eval "$GATE_T" 2>/dev/null)"
  case "$2" in
    pass) if [ -z "$out" ]; then ok "$3 (출력 0건)"; else ng "$3 (기대 0건, 실제 [$out])"; fi ;;
    fail) if [ -n "$out" ]; then ok "$3 (위반 출력)"; else ng "$3 (기대 위반 행, 실제 0건)"; fi ;;
  esac
}

assert_example "$sandbox/runners/pair.sh"    pass "테스트 배치: 예시 명령 정상 러너 통과"
assert_example "$sandbox/runners/no-case.sh" fail "테스트 배치: 예시 명령 ok 행 없는 러너 격추"
assert_example "$sandbox/runners/pass-only.sh" fail "테스트 배치: 예시 명령 정상 행만 있는 러너 격추"
assert_example "$sandbox/runners/fail-only.sh" fail "테스트 배치: 예시 명령 반례 행만 있는 러너 격추"
assert_example "$sandbox/runners/exit1.sh"   fail "테스트 배치: 예시 명령 종료 1 러너 격추"

# --- 보류 항목 원장 등재 질의 (issue #118) ------------------------------------------
#
# 이슈 완료 시 spec 제외 `보류` 항목의 원장 등재 질의는 SKILL.md `## 이슈 완료 시` 3단계의 하위 항목과
# `--clear` 4단계의 연결 문장이 계약이다. 질의 행은 절 안에서 정확히 1개로 세고, 하위 항목 범위
# (질의 행부터 다음 형제 항목·번호 단계·최상위 행 전까지)에서 조항(질의 대상·승인분 등재·출처·필수 필드·
# 보류 항목 단위 중복 판정과 그 예시)마다 앵커 문구를 판정한다 — `보류`·`원장`·`등재` 낱말만 보면
# 조항 문구를 지워도 통과한다 (PR #113 리뷰 반례와 같은 취지).

# check_deferred_ledger <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_deferred_ledger() {
  awk '/^## 이슈 완료 시$/ { s = 1; next }
       /^## / { s = 0; b = 0 }
       s && /^   - \*\*보류 항목 원장 등재 질의\*\*: / { n++; b = 1; blk = blk $0 "\n"; next }
       b && (/^   - / || /^[0-9]+\. / || /^[^[:space:]]/) { b = 0 }
       b { blk = blk $0 "\n" }
       /^### `--clear`$/ { c = 1; next }
       c && /^#/ { c = 0 }
       c && /^  [0-9]+\. / { st = substr($0, 3, 1) }
       c && st == "4" && index($0, "**보류 항목 원장 등재 질의**") { m++ }
       END {
         if (n != 1) print "이슈 완료 시 절의 보류 항목 원장 등재 질의 행 " n + 0 "개 (기대 1개)"
         if (!index(blk, "사유가 `보류`인 항목을 보여 주고 원장 등재 여부를 묻는다")) print "질의 대상(spec 제외 보류 항목) 문구 없음"
         if (!index(blk, "승인한 항목만 등재한다")) print "승인분만 등재 문구 없음"
         if (!index(blk, "`출처`는 `이슈 #N`")) print "출처 이슈 #N 문구 없음"
         if (!index(blk, "**수용 사유**와 **재검토 조건**은 필수")) print "수용 사유·재검토 조건 필수 문구 없음"
         if (!index(blk, "보류 항목 하나씩 판정한다")) print "보류 항목 단위 중복 판정 문구 없음"
         if (!index(blk, "보류 A만 등재된 상태면 B는 질의하고, A·B가 모두 등재됐으면 둘 다 건너뛴다")) print "중복 판정 예시 문구 없음"
         if (m != 1) print "--clear 4단계의 보류 항목 원장 등재 질의 문장 " m + 0 "개 (기대 1개)"
       }' "$1"
}

awk '/^## 이슈 완료 시$/ { s = 1; print; next } /^## / { s = 0 } !(s && /보류/ && /원장/ && /등재/)' "$SKILL" > "$sandbox/dl-del.md"
drop_literal "$SKILL" '사유가 `보류`인 항목을 보여 주고 원장 등재 여부를 묻는다' > "$sandbox/dl-no-target.md"
drop_literal "$SKILL" '승인한 항목만 등재한다' > "$sandbox/dl-no-approval.md"
drop_literal "$SKILL" '`출처`는 `이슈 #N`' > "$sandbox/dl-no-source.md"
drop_literal "$SKILL" '**수용 사유**와 **재검토 조건**은 필수' > "$sandbox/dl-no-required.md"
drop_literal "$SKILL" '보류 항목 하나씩 판정한다' > "$sandbox/dl-no-unit.md"
drop_literal "$SKILL" '보류 A만 등재된 상태면 B는 질의하고, A·B가 모두 등재됐으면 둘 다 건너뛴다' > "$sandbox/dl-no-example.md"
awk '!index($0, "같은 3단계의 **보류 항목 원장 등재 질의**")' "$SKILL" > "$sandbox/dl-no-clear.md"

assert_structure check_deferred_ledger "$SKILL"                      pass "보류 등재: 실제 SKILL.md 이슈 완료 시·--clear 4단계 통과"
assert_structure check_deferred_ledger "$sandbox/dl-del.md"          fail "보류 등재: 이슈 완료 시 절의 보류·원장·등재 행 삭제 격추"
assert_structure check_deferred_ledger "$sandbox/dl-no-target.md"    fail "보류 등재: 질의 대상 문구 삭제 격추"
assert_structure check_deferred_ledger "$sandbox/dl-no-approval.md"  fail "보류 등재: 승인분만 등재 문구 삭제 격추"
assert_structure check_deferred_ledger "$sandbox/dl-no-source.md"    fail "보류 등재: 출처 이슈 #N 문구 삭제 격추"
assert_structure check_deferred_ledger "$sandbox/dl-no-required.md"  fail "보류 등재: 수용 사유·재검토 조건 필수 문구 삭제 격추"
assert_structure check_deferred_ledger "$sandbox/dl-no-unit.md"      fail "보류 등재: 보류 항목 단위 중복 판정 문구 삭제 격추"
assert_structure check_deferred_ledger "$sandbox/dl-no-example.md"   fail "보류 등재: 중복 판정 예시 삭제 격추"
assert_structure check_deferred_ledger "$sandbox/dl-no-clear.md"     fail "보류 등재: --clear 4단계 연결 문장 삭제 격추"

# --- `--clear` 완료 확인 (check-clear.sh --completion) ---------------------------

CLEAR="$HERE/../scripts/check-clear.sh"
METRICS="$HERE/../scripts/summarize-metrics.sh"
LEDGER="$HERE/../scripts/check-ledger-links.sh"

for s in "$CLEAR" "$METRICS" "$LEDGER"; do
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

## 계획 종료 게이트 (고정)

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
assert_clear fail "clear 완료 확인: 계획 종료 게이트 미체크 격추" --completion "$sandbox/plan-gate-open.md"
# `set -o pipefail` 아래에서는 헬퍼의 exit 1 이 파이프라인 전체로 전파되므로 출력을 변수에 담아 본다.
gate_out="$("$CLEAR" --completion "$sandbox/plan-gate-open.md" 2>&1)"
printf '%s\n' "$gate_out" | grep -q '계획 종료 게이트 점검 완료' \
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
assert_clear fail "clear 완료 확인: 계획 종료 게이트 중복 격추" --completion "$sandbox/plan-gate-dup.md"
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
- **수행 effort**: high
- **audit 발견**: 1건
- **보정 반영**: 1건
- **재시도**: 0회

### Task 1: 본작업

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5 (claude-opus-5)
- **수행 effort**: high
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

# --- 원장 링크 검사 (check-ledger-links.sh, issue #120) -----------------------------
#
# 케이스마다 새 `.ai` 트리를 만든다. 기본 트리는 K-0001 을 archive/ 로 옮기고 링크를 다 고친 상태이며,
# K-0001 과 active/ 에 남은 K-0002 가 서로를 가리킨다. 격추 케이스는 그 트리에서 한 곳만 바꾼다.
# 헬퍼 사본을 둔 issue-work·git-pr·git-pr-feedback 러너에 같은 케이스를 둔다. 한쪽을 고치면 나머지도 고친다.

# ledger_tree <이름> — 기본 트리를 "$sandbox/ledger-<이름>" 에 만들고 그 경로를 LT 에 둔다.
ledger_tree() {
  LT="$sandbox/ledger-$1"
  local A="$LT/.ai"
  mkdir -p "$A/70_ledger/active" "$A/70_ledger/archive" "$A/60_codebase/x"
  cat > "$A/70_ledger/index.md" <<'EOF'
# 원장

| [K-0002](active/K-0002-b.md) | 수용 |
| [K-0001](archive/K-0001-a.md#상태) | 해소 |
EOF
  printf '# K-0002\n\n관련: [K-0001](../archive/K-0001-a.md)\n' > "$A/70_ledger/active/K-0002-b.md"
  printf '# K-0001\n\n관련: [K-0002](../active/K-0002-b.md)\n' > "$A/70_ledger/archive/K-0001-a.md"
  printf '[K-0001](../../70_ledger/archive/K-0001-a.md#상태) [외부](https://example.com/70_ledger/active/K-0009-z.md)\n' \
    > "$A/60_codebase/x/flow.md"
}

# assert_ledger <기대: pass|fail|usage> <설명> <기대 출력> <인자...>
# 트리 루트(LT)에서 실행한다. fail 은 출력 전체가 기대 출력 1행과 같아야 한다
# — 기본 트리의 살아 있는 링크(앵커·외부 URL·상호 링크)가 오탐으로 섞이면 실패한다.
assert_ledger() {
  local want="$1" desc="$2" hit="$3"; shift 3
  local out rc
  out="$(cd "$LT" && "$LEDGER" "$@" 2>&1)"; rc=$?
  case "$want" in
    pass)  { [ "$rc" -eq 0 ] && [ -z "$out" ]; } && ok "$desc" \
             || ng "$desc (기대 exit 0·무출력, 실제 exit $rc — $(printf '%s' "$out" | tr '\n' ' '))" ;;
    fail)  { [ "$rc" -eq 1 ] && [ "$out" = "$hit" ]; } && ok "$desc" \
             || ng "$desc (기대 exit 1·[$hit], 실제 exit $rc — $(printf '%s' "$out" | tr '\n' ' '))" ;;
    usage) [ "$rc" -eq 2 ] && ok "$desc" || ng "$desc (기대 exit 2, 실제 $rc)" ;;
  esac
}

ledger_tree ok
assert_ledger pass "원장 링크: 옮긴 뒤 링크를 다 고친 트리 통과 (앵커·외부 URL·인자 생략)" ''

ledger_tree issue-archive
mkdir -p "$LT/.ai/90_issues/archive/issue-0001"
printf '[K-0001](../../../70_ledger/active/K-0001-a.md)\n' > "$LT/.ai/90_issues/archive/issue-0001/r.md"
assert_ledger pass "원장 링크: 90_issues/archive 아래 옛 경로만 남은 트리 통과" '' .ai

# 앵커를 붙인다 — 앵커를 떼지 못하면 파일 이름이 `.md` 로 끝나지 않아 후보에서 조용히 빠진다.
ledger_tree old-path
printf '# old\n[K-0001](../../70_ledger/active/K-0001-a.md#상태)\n' > "$LT/.ai/60_codebase/x/old.md"
assert_ledger fail "원장 링크: 옛 경로 링크 격추 (앵커 포함)" \
  '.ai/60_codebase/x/old.md:2: ../../70_ledger/active/K-0001-a.md#상태' .ai

ledger_tree incoming
printf '# K-0002\n\n관련: [K-0001](K-0001-a.md)\n' > "$LT/.ai/70_ledger/active/K-0002-b.md"
assert_ledger fail "원장 링크: 같은 디렉토리 들어오는 링크(남은 항목 → 옮긴 항목) 격추" \
  '.ai/70_ledger/active/K-0002-b.md:3: K-0001-a.md' .ai

ledger_tree outgoing
printf '# K-0001\n\n관련: [K-0002](K-0002-b.md)\n' > "$LT/.ai/70_ledger/archive/K-0001-a.md"
assert_ledger fail "원장 링크: 옮긴 항목에서 나가는 링크(옮긴 항목 → 남은 항목) 격추" \
  '.ai/70_ledger/archive/K-0001-a.md:3: K-0002-b.md' .ai

ledger_tree depth
printf '[K-0001](../70_ledger/archive/K-0001-a.md)\n' > "$LT/.ai/60_codebase/x/depth.md"
assert_ledger fail "원장 링크: 깊이 오계산 격추" \
  '.ai/60_codebase/x/depth.md:1: ../70_ledger/archive/K-0001-a.md' .ai

ledger_tree usage
assert_ledger usage "원장 링크: 없는 디렉토리 사용오류 격추" '' no-such-dir
assert_ledger usage "원장 링크: 인자 2개 사용오류 격추" '' .ai .ai

# --- 링크 갱신 규칙 (issue #120) --------------------------------------------------
#
# 원장 항목을 archive/ 로 옮긴 뒤의 링크 갱신은 SKILL.md `## 이슈 완료 시` 3단계 원장 해소 기재의 정의 행
# (`**들어오는 링크 갱신**:`)과 그 아래 헬퍼 호출 블록, `--response` 5단계의 참조 행이 계약이다.
# 정의 행은 파일 전체에서 정확히 1개로 세고 조각 8개를 그 행에서 판정한다. 위치·참조 판정은
# issue-0120 spec R2 의 두 [D] 를 옮긴 것이다. 호출 블록은 정의 행 다음 행부터 보류 항목 질의 행 앞까지에서
# 경로 설정 행과 호출 행을 본다 — 정의 행의 헬퍼 이름 조각으로는 경로 오타나 호출 행 누락을 잡지 못한다.
# 위반 행은 판정 이름(정의·위치·참조·호출)으로 시작하고, 격추 케이스는 노린 판정이 위반을 냈는지 본다.
# git-pr·git-pr-feedback 러너에도 같은 판정을 그 스킬의 적용 지점에 맞춰 둔다.

# check_link_rule <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_link_rule() {
  local re n line a cfg v blk
  re='^ *([0-9]+\.|-) \*\*들어오는 링크 갱신\*\*: '
  n=$(grep -cE "$re" "$1")
  if [ "$n" = 1 ]; then
    line=$(grep -E "$re" "$1")
    for a in '`.ai/` 아래 문서' '`.ai/90_issues/archive/` 제외' '`70_ledger/active/K-<번호>-`' \
             '링크가 있는 문서 위치에서 다시 계산' '`check-ledger-links.sh`' '0건' \
             '같은 디렉토리 링크' '옮긴 항목 안에서'; do
      case "$line" in *"$a"*) ;; *) echo "정의: 정의 행에 [$a] 없음" ;; esac
    done
  else
    echo "정의: 정의 행 ${n}개 (기대 1개)"
  fi
  awk '/^## 이슈 완료 시$/ { s = 1; next } /^## / { s = 0 }
       s && /\*\*원장 해소 기재\*\*/ && !a { a = NR }
       s && /^ *- \*\*들어오는 링크 갱신\*\*: / { b = NR }
       s && /\*\*보류 항목 원장 등재 질의\*\*/ { c = NR }
       END { if (!(a && b && c && a < b && b < c)) print "위치: 원장 해소 기재 " a+0 ", 정의 " b+0 ", 보류 " c+0 }' "$1"
  resp_section "$1" | awk '/^  5\. /{f=1} f && /^[^[:space:]]/ && !/^  5\. /{f=0} f' \
    | grep -q '들어오는 링크 갱신' || echo '참조: --response 5단계에 들어오는 링크 갱신 참조 없음'
  # 호출 블록: 정의 행 다음 행부터 보류 항목 질의 행(없으면 다음 `## ` 제목) 앞까지
  blk=$(awk '/^ *([0-9]+\.|-) \*\*들어오는 링크 갱신\*\*: / { r = 1; next }
             r && (/\*\*보류 항목 원장 등재 질의\*\*/ || /^## /) { r = 0 }
             r' "$1")
  n=$(grep -cE "^[[:space:]]*ledger_links='" "$1")
  [ "$n" = 1 ] || echo "호출: 경로 설정 행 ${n}개 (기대 1개)"
  cfg=$(printf '%s\n' "$blk" | grep -E "^[[:space:]]*ledger_links='")
  if [ -z "$cfg" ]; then
    echo '호출: 호출 블록에 경로 설정 행 없음'
  else
    v=${cfg#*\'}; v=${v%%\'*}
    case "$v" in '<skill 디렉토리>/'*) v="$HERE/../${v#'<skill 디렉토리>/'}" ;; esac
    { [ -f "$v" ] && [ -x "$v" ]; } || echo "호출: 경로 설정 값 [$v] 이 실행 가능한 파일이 아님"
    printf '%s\n' "$blk" | awk '/^[[:space:]]*ledger_links=/ { p = 1; next } p && /^[[:space:]]*"\$ledger_links"/ { n++ }
                                END { exit !n }' \
      || echo '호출: 경로 설정 행 뒤에 "$ledger_links" 호출 행 없음'
  fi
}

# assert_link_rule <파일> <기대: pass | 판정 이름> <설명>
# 격추 케이스는 노린 판정 이름으로 시작하는 위반 행이 있어야 통과한다
# — 변형이 다른 판정에만 걸리면 노린 판정이 깨져도 알 수 없다.
assert_link_rule() {
  local out
  out="$(check_link_rule "$1")"
  if [ "$2" = pass ]; then
    if [ -z "$out" ]; then ok "$3 (위반 0건)"; else ng "$3 (기대 0건, 실제 [$out])"; fi
  elif printf '%s\n' "$out" | grep -q "^$2: "; then
    ok "$3 ($2 위반 검출)"
  else
    ng "$3 (기대 [$2: …], 실제 [$out])"
  fi
}

# 호출 블록의 두 변형(lr-bad-path·lr-no-call)은 그 블록 행만 바꿔 정의·위치·참조 판정은 그대로 둔다.
awk '!/^ *([0-9]+\.|-) \*\*들어오는 링크 갱신\*\*: /' "$SKILL" > "$sandbox/lr-del.md"
drop_literal "$SKILL" '링크가 있는 문서 위치에서 다시 계산' > "$sandbox/lr-no-depth.md"
awk '/^ *- \*\*들어오는 링크 갱신\*\*: / { held = $0; next } { print }
     /^   - \*\*보류 항목 원장 등재 질의\*\*: / { print held }' "$SKILL" > "$sandbox/lr-moved.md"
awk '!/^ *- \*\*옮긴 뒤 링크 갱신\*\*: /' "$SKILL" > "$sandbox/lr-no-ref.md"
awk '/^[[:space:]]*ledger_links=/ { sub(/check-ledger-links\.sh/, "missing-helper.sh") } { print }' \
  "$SKILL" > "$sandbox/lr-bad-path.md"
awk '!/^[[:space:]]*"\$ledger_links"/' "$SKILL" > "$sandbox/lr-no-call.md"

assert_link_rule "$SKILL"                    pass "링크 갱신 규칙: 실제 SKILL.md 정의 행·적용 지점·호출 블록 통과"
assert_link_rule "$sandbox/lr-del.md"        정의 "링크 갱신 규칙: 정의 행 삭제 격추"
assert_link_rule "$sandbox/lr-no-depth.md"   정의 "링크 갱신 규칙: 정의 행의 깊이 재계산 조각 삭제 격추"
assert_link_rule "$sandbox/lr-moved.md"      위치 "링크 갱신 규칙: 정의 행을 보류 항목 질의 행 뒤로 이동 격추"
assert_link_rule "$sandbox/lr-no-ref.md"     참조 "링크 갱신 규칙: --response 5단계 옮긴 뒤 링크 갱신 참조 행 삭제 격추"
assert_link_rule "$sandbox/lr-bad-path.md"   호출 "링크 갱신 규칙: 경로 설정 값을 없는 파일로 바꾼 호출 블록 격추"
assert_link_rule "$sandbox/lr-no-call.md"    호출 "링크 갱신 규칙: 호출 행 삭제 격추"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
