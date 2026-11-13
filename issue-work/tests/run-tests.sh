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
    /^### 포함$/                     { inc++; if (sec != "## 요구사항 (Requirements)") mis++; inc_at = NR; list = "inc" }
    /^### 제외$/                     { exc++; if (sec != "## 요구사항 (Requirements)") mis++; exc_at = NR; list = "exc" }
    /^\*\*(포함|제외)\*\*/           { bold++ }
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
      if (bold)           print "굵은 글씨 포함·제외 표지 " bold "행 (표지는 ### 포함·### 제외 제목)"
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
  valid="$(awk '/^### 포함$/ { list = 1; next } /^### / || /^## / || /^\*\*/ { list = 0 }
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
awk '!/^### 포함$/' "$SPEC_TPL" > "$sandbox/s-no-incl.md"
awk '!/^### 제외$/' "$SPEC_TPL" > "$sandbox/s-no-excl.md"
awk '!/^### R1: /' "$SPEC_TPL" > "$sandbox/s-no-rgroup.md"
awk '!/^### 공통$/' "$SPEC_TPL" > "$sandbox/s-no-common.md"
awk '{print} END{print ""; print "## 범위 (Scope)"}' "$SPEC_TPL" > "$sandbox/s-scope-back.md"

# F-2 반례(2차 audit 재현·이웃 변형): 존재 검사만으로는 통과하는 변형들.
awk '{print} END{print ""; print "## 요구사항 (Requirements)"}' "$SPEC_TPL" > "$sandbox/s-dup-req.md"
awk '{print} /^### 포함$/{print ""; print "### 포함"}' "$SPEC_TPL" > "$sandbox/s-dup-incl.md"
awk '/^### 포함$/{next} {print} /^### 제외$/{print ""; print "### 포함"}' \
  "$SPEC_TPL" > "$sandbox/s-swap-order.md"
awk '!/^### 제외$/{print} END{print ""; print "### 제외"}' "$SPEC_TPL" > "$sandbox/s-excl-outside.md"
awk '{print} /^### 제외$/{print ""; print "**비포함 (Out)**"}' "$SPEC_TPL" > "$sandbox/s-old-coexist.md"
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
awk '/^### 포함$/{hold=1} /^## 완료의 정의/{hold=0} hold{buf = buf $0 "\n"; next} {print}
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

# 읽기 실패 (최종 감사 F-1). while 의 종료 상태가 마지막 awk 만 반영해, 앞 파일을 읽지 못해도 뒤 파일이 정상이면 0 이 나왔다.
# 정렬 순서로 첫·중간·마지막 위치에 읽을 수 없는 파일을 둔다. root 는 chmod 000 이어도 읽을 수 있어 읽기가 막히지 않으면 건너뛴다.
# ledger_unreadable <이름> <.ai 기준 파일> <위치> — 기본 트리에 읽을 수 없는 파일을 두고 종료 코드 2 를 기대한다.
ledger_unreadable() {
  ledger_tree "$1"
  local u="$LT/.ai/$2"
  printf '# 읽기 차단\n' > "$u"; chmod 000 "$u"
  if [ -r "$u" ]; then echo "skip   - 원장 링크: $3 파일 읽기 실패 (읽기를 막을 수 없는 환경)"
  else assert_ledger usage "원장 링크: $3 파일 읽기 실패 격추" '' .ai; fi
  chmod 644 "$u"
}
ledger_unreadable unreadable-first 60_codebase/a.md 첫
ledger_unreadable unreadable-mid   70_ledger/a.md   중간
ledger_unreadable unreadable-last  z.md             마지막

# 심볼릭 링크 루트 (최종 감사 F-2). find 가 명령행의 심볼릭 링크를 따라가지 않아 후보 0개로 통과했다.
# ledger_symlink <이름> — 기본 트리의 .ai 를 real-ai 로 옮기고 .ai 를 그 심볼릭 링크로 둔다.
ledger_symlink() {
  ledger_tree "$1"
  mv "$LT/.ai" "$LT/real-ai" && ln -s real-ai "$LT/.ai"
}

ledger_symlink symlink-ok
mkdir -p "$LT/real-ai/90_issues/archive/issue-0001"
printf '[K-0001](../../../70_ledger/active/K-0001-a.md)\n' > "$LT/real-ai/90_issues/archive/issue-0001/r.md"
assert_ledger pass "원장 링크: 심볼릭 링크 루트의 고친 트리 통과 (90_issues/archive 옛 경로·인자 생략)" ''

ledger_symlink symlink-old
printf '# old\n[K-0001](../../70_ledger/active/K-0001-a.md)\n' > "$LT/real-ai/60_codebase/x/old.md"
assert_ledger fail "원장 링크: 심볼릭 링크 루트의 옛 경로 격추 (.ai)" \
  '.ai/60_codebase/x/old.md:2: ../../70_ledger/active/K-0001-a.md' .ai
assert_ledger fail "원장 링크: 심볼릭 링크 루트의 옛 경로 격추 (.ai/)" \
  '.ai/60_codebase/x/old.md:2: ../../70_ledger/active/K-0001-a.md' .ai/

# glob 문자가 든 루트 (PR #123 리뷰). find -path 가 제외 경로를 glob 으로 읽어 루트의 [1] 이 문자 1 로 풀리면 90_issues/archive 가 빠지지 않았다.
# archive 의 옛 경로는 빠지고 그 밖의 옛 경로 1행만 나와야 한다.
ledger_tree 'glob[1]'
mkdir -p "$LT/.ai/90_issues/archive/issue-0001"
printf '[K-0001](../../../70_ledger/active/K-0001-a.md)\n' > "$LT/.ai/90_issues/archive/issue-0001/r.md"
printf '# old\n[K-0001](../../70_ledger/active/K-0001-a.md)\n' > "$LT/.ai/60_codebase/x/old.md"
assert_ledger fail "원장 링크: glob 문자가 든 루트에서 90_issues/archive 제외·옛 경로 격추" \
  "$LT/.ai/60_codebase/x/old.md:2: ../../70_ledger/active/K-0001-a.md" "$LT/.ai"

# `이름=값` 꼴 상대 루트 (PR #123 리뷰). awk 가 `scan=ledger/.ai/…` 인자를 변수 대입으로 읽어 파일을 검사하지 않고 0 으로 끝났다.
ledger_tree assign
mkdir "$LT/scan=ledger" && mv "$LT/.ai" "$LT/scan=ledger/.ai"
printf '# old\n[K-0001](../../70_ledger/active/K-0001-a.md)\n' > "$LT/scan=ledger/.ai/60_codebase/x/old.md"
assert_ledger fail "원장 링크: 이름=값 꼴 상대 루트의 옛 경로 격추" \
  'scan=ledger/.ai/60_codebase/x/old.md:2: ../../70_ledger/active/K-0001-a.md' scan=ledger/.ai

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

# --- 테스트 원칙 조항 (issue #122) --------------------------------------------------
#
# `testing-principles` 파일 쌍을 조건부로 참조하는 조항은 문장이 곧 계약이다 (Task별 테스트 배치).
# SKILL.md `## 참조 문서`의 두 파일 항목, "새 이슈 시작 시" 3-2 범위의 층 표 참조·기기 확인 Task 문장,
# plan 템플릿 `**테스트 배치**` 문단의 local 파일 참조를 앵커로 판정하고, 앵커마다 지운 사본과 범위 밖으로 옮긴 사본을 격추한다.
# 조건·우선순위의 뜻은 판정하지 않는다 (이슈 spec 의 [QD] 몫).

# check_testing_skill <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_testing_skill() {
  awk '/^## 참조 문서/ { r = 1; next } r && /^## / { r = 0 }
       r && /^  - `\.ai\/10_rules\/testing-principles\.md`·`\.ai\/10_rules\/testing-principles-local\.md` — / { n++ }
       /^   - \*\*3-2\. 승인 후\*\*/ { s = 1 } s && /^4\. / { s = 0 }
       s && index($0, "testing-principles-local.md") { l++ }
       s && index($0, "기기 확인 Task는 두지 않는다") { d++ }
       END { if (n != 1) print "참조 문서의 테스트 원칙 항목 " n + 0 "개 (기대 1개)"
             if (l < 1) print "3-2 범위에 testing-principles-local.md 참조 없음"
             if (d < 1) print "3-2 범위에 기기 확인 Task 문장 없음" }' "$1"
}

# check_testing_plan <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 문단 범위는 위 check_placement_header 와 같다. 빈 `>` 행 뒤로 밀린 줄은 별도 문단이라 세지 않는다.
check_testing_plan() {
  awk '/^## Tasks$/ { s = 1 } /^### Task 0/ { s = 0 }
       s && /^> \*\*테스트 배치\*\*/ { p = 1; n++ }
       p && (/^>[[:space:]]*$/ || !/^>/) { p = 0 }
       p && index($0, "testing-principles-local.md") { l++ }
       END { if (n != 1) print "테스트 배치 문단 " n + 0 "개 (기대 1개)"
             else if (l < 1) print "테스트 배치 문단에 testing-principles-local.md 참조 없음" }' "$1"
}

awk '!index($0, "  - `.ai/10_rules/testing-principles.md`·`.ai/10_rules/testing-principles-local.md` — ")' \
  "$SKILL" > "$sandbox/tr-ref-del.md"
drop_literal "$SKILL" '`.ai/10_rules/testing-principles-local.md`가 있으면 plan Task' > "$sandbox/tr-32-no-local.md"
drop_literal "$SKILL" '기기 확인 Task는 두지 않는다' > "$sandbox/tr-32-no-device.md"
awk '/^     - \*\*테스트 층 표\*\*: / { held = $0; next } { print } /^4\. / && held { print held; held = "" }' \
  "$SKILL" > "$sandbox/tr-32-moved.md"
awk '!index($0, "> `.ai/10_rules/testing-principles-local.md`가 있으면")' "$TEMPLATE" > "$sandbox/tr-plan-del.md"
awk 'index($0, "> `.ai/10_rules/testing-principles-local.md`가 있으면") { held = $0; next }
     { print } held && /^>[[:space:]]*$/ { print held; held = "" }' "$TEMPLATE" > "$sandbox/tr-plan-split.md"

assert_structure check_testing_skill "$SKILL"                      pass "테스트 원칙 조항: SKILL.md 참조 항목·3-2 층 표 문장 통과"
assert_structure check_testing_plan  "$TEMPLATE"                   pass "테스트 원칙 조항: plan 템플릿 테스트 배치 문단 통과"
assert_structure check_testing_skill "$sandbox/tr-ref-del.md"      fail "테스트 원칙 조항: SKILL.md 참조 항목 삭제 격추"
assert_structure check_testing_skill "$sandbox/tr-32-no-local.md"  fail "테스트 원칙 조항: 3-2 local 층 표 참조 삭제 격추"
assert_structure check_testing_skill "$sandbox/tr-32-no-device.md" fail "테스트 원칙 조항: 3-2 기기 확인 Task 문장 삭제 격추"
assert_structure check_testing_skill "$sandbox/tr-32-moved.md"     fail "테스트 원칙 조항: 3-2 층 표 항목의 4단계 이동 격추"
assert_structure check_testing_plan  "$sandbox/tr-plan-del.md"     fail "테스트 원칙 조항: 테스트 배치 문단 local 참조 삭제 격추"
assert_structure check_testing_plan  "$sandbox/tr-plan-split.md"   fail "테스트 원칙 조항: 테스트 배치 local 참조의 다음 문단 이동 격추"

# --- 이슈 본문 템플릿 (issue #130) ------------------------------------------------
#
# `--create` 초안, 3-1 근거 판정, issue-audit `--plan` 1단계가 같은 이슈 본문 구조를 읽는다.
# 본문 헤더 4개와 접기 제목 3개를 열거해 그 외 0건까지 판정하고(HTML 주석 안 안내문은 빼고 센다),
# 접기 안 헤더와 `## 검토 필요` 앞 접기를 위반으로 센다.
# 완료의 정의 섹션의 AC 행과 포함 항목 AC 규칙 문장은 섹션 범위로 판정한다.
# 규칙 문장은 주석 안 안내라 주석 행도 세며, 다른 섹션으로 옮긴 문장은 세지 않는다.

BODY_TPL="$HERE/../templates/issue-body-template.md"

# check_body_template <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_body_template() {
  awk '
    sec == "완료의 정의" && index($0, "포함 항목마다 AC를 1개 이상") { rule++ }
    /<!--/ { c = 1 }
    c { if (/-->/) c = 0; next }
    /^## / { h = h $0 "|"; sec = substr($0, 4); if (d > 0) print "접기 안 헤더 " $0 }
    /^## 검토 필요$/ { k = 1 }
    /^<details>/ { d++; if (!k) print "검토 필요 앞 접기" }
    /^<\/details>/ { d-- }
    { t = $0; while (match(t, /<summary>[^<]+<\/summary>/)) { s = s substr(t, RSTART, RLENGTH) "|"; t = substr(t, RSTART + RLENGTH) } }
    sec == "완료의 정의" && /^- \[ \] AC[0-9]+: / { ac++ }
    /^### 포함$/ { if (sec == "범위") { bi++; bi_at = NR } else bout++ }
    /^### 제외$/ { if (sec == "범위") { be++; be_at = NR } else bout++ }
    /^\*\*(포함|제외)\*\*/ { bold++ }
    END {
      if (h != "## 목표|## 범위|## 완료의 정의|## 검토 필요|") print "본문 헤더 구성 [" h "]"
      if (bi != 1 || be != 1) print "범위 표지 제목 포함 " bi + 0 "개·제외 " be + 0 "개 (기대 각 1개)"
      else if (bi_at > be_at) print "범위 포함·제외 표지 순서 역전"
      if (bout) print "포함·제외 표지 제목이 범위 섹션 밖: " bout "개"
      if (bold) print "굵은 글씨 포함·제외 표지 " bold "행 (표지는 ### 포함·### 제외 제목)"
      if (s != "<summary>배경</summary>|<summary>현재 동작 → 기대 동작</summary>|<summary>연관 문서</summary>|")
        print "접기 구성 [" s "]"
      if (ac < 1) print "완료의 정의에 AC 행 없음"
      if (rule < 1) print "완료의 정의 안내에 포함 항목 AC 규칙 없음"
    }' "$1"
}

awk '!/^## 목표$/' "$BODY_TPL" > "$sandbox/bt-no-goal.md"
awk '/^## 범위$/ { hold = 1 } /^## 완료의 정의$/ { hold = 0 } hold { buf = buf $0 "\n"; next }
     /^## 검토 필요$/ { printf "%s", buf } { print }' "$BODY_TPL" > "$sandbox/bt-swap-order.md"
awk '/^## 검토 필요$/ { hold = 1 } hold && /^<details>/ { hold = 0 } hold { buf = buf $0 "\n"; next }
     { print } /^<summary>배경<\/summary>$/ { print ""; printf "%s", buf }' "$BODY_TPL" > "$sandbox/bt-review-folded.md"
awk '{ sub(/<summary>배경<\/summary>/, "<summary>배경과 계기</summary>"); print }' "$BODY_TPL" > "$sandbox/bt-summary-renamed.md"
awk '!/^- \[ \] AC[0-9]+: /' "$BODY_TPL" > "$sandbox/bt-no-ac.md"
drop_literal "$BODY_TPL" '포함 항목마다 AC를 1개 이상' > "$sandbox/bt-no-rule.md"
BT_RULE="$(grep -F '포함 항목마다 AC를 1개 이상' "$BODY_TPL")" \
  awk 'index($0, "포함 항목마다 AC를 1개 이상") { next } /^## 완료의 정의$/ { print ENVIRON["BT_RULE"]; print "" } { print }' \
  "$BODY_TPL" > "$sandbox/bt-rule-in-scope.md"

assert_structure check_body_template "$BODY_TPL"                        pass "이슈 본문 템플릿: 실제 템플릿 통과"
assert_structure check_body_template "$sandbox/bt-no-goal.md"           fail "이슈 본문 템플릿: 목표 헤더 삭제 격추"
assert_structure check_body_template "$sandbox/bt-swap-order.md"        fail "이슈 본문 템플릿: 범위·완료의 정의 순서 바꿈 격추"
assert_structure check_body_template "$sandbox/bt-review-folded.md"     fail "이슈 본문 템플릿: 검토 필요의 접기 안 이동 격추"
assert_structure check_body_template "$sandbox/bt-summary-renamed.md"   fail "이슈 본문 템플릿: 접기 제목 변경 격추"
assert_structure check_body_template "$sandbox/bt-no-ac.md"             fail "이슈 본문 템플릿: 완료의 정의 AC 행 삭제 격추"
assert_structure check_body_template "$sandbox/bt-no-rule.md"           fail "이슈 본문 템플릿: 포함 항목 AC 규칙 문장 삭제 격추"
assert_structure check_body_template "$sandbox/bt-rule-in-scope.md"     fail "이슈 본문 템플릿: 포함 항목 AC 규칙 문장의 범위 섹션 이동 격추"

# --- --create 절 (issue #130) -----------------------------------------------------
#
# 이슈 등록은 외부 공개 행위라 승인 게이트·대상 저장소 명시·작업 파일 1개가 절 문장으로 지켜진다.
# `## 옵션` 아래 절 1개, 동작 단계 6개의 이름·순서(그 외 단계 0건), 절이 가리키는 작업 파일 집합,
# 파일 전체의 `gh issue create --` 명령 행마다 `--repo '`·`--body-file`, 승인 전 미실행·active 무변경 문장을 판정한다.
# 분할 권고와 AC 미대응 포함 항목 보고는 요약 제시 단계 범위(다음 번호 단계 전까지)로 판정해, 다른 단계로 옮긴 문장은 세지 않는다.

# check_create_section <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_create_section() {
  local n sec got st p
  n="$(grep -c '^### `--create`$' "$1")"
  [ "$n" -eq 1 ] || echo "옵션 절 개수 ${n}개 (기대 1개)"
  awk '/^## 옵션$/ { o = NR } /^### `--create`$/ { c = NR }
       END { if (!o || !c || c < o) print "--create 절이 옵션 섹션 밖" }' "$1"
  sec="$(awk '/^### `--create`$/ { f = 1; next } f && /^#{2,3} / { exit } f' "$1")"
  got="$(printf '%s\n' "$sec" | grep -oE '^  [0-9]+\. \*\*[^*]+\*\*' | sed -E 's/^  [0-9]+\. //' | tr '\n' '|')"
  [ "$got" = '**초안 작성**|**요약 제시**|**승인**|**등록**|**번호 보고**|**시작 질의**|' ] || echo "동작 단계 구성·순서 [$got]"
  got="$(printf '%s\n' "$sec" | grep -oE "\.ai/99_workspace/[^\`' )]+" | sort -u | tr '\n' '|')"
  [ "$got" = '.ai/99_workspace/issue-create-body.md|' ] || echo "작업 파일 [$got]"
  [ "$(grep -c 'gh issue create --' "$1")" -ge 1 ] || echo "gh issue create 명령 행 없음"
  grep -n 'gh issue create --' "$1" | grep -vF -e "--repo '" | sed 's/^/명령 행에 --repo 없음: /'
  grep -n 'gh issue create --' "$1" | grep -vF -e '--body-file' | sed 's/^/명령 행에 --body-file 없음: /'
  for p in '승인 전에는 `gh issue create`를 실행하지 않는다' 'active 작업 파일을 옮기거나 지우지 않는다'; do
    printf '%s\n' "$sec" | grep -qF -- "$p" || echo "절에 문장 없음 [$p]"
  done
  st="$(printf '%s\n' "$sec" | awk '/^  [0-9]+\. \*\*요약 제시\*\*/ { s = 1; print; next } s && /^  [0-9]+\. / { exit } s')"
  for p in '서로 독립으로 머지할 수 있는' '분할을 권고' '수치 기준은 두지 않' '결정은 사용자' 'AC가 대응하지 않는 포함 항목'; do
    printf '%s\n' "$st" | grep -qF -- "$p" || echo "요약 제시 단계에 [$p] 없음"
  done
}

# 단계·명령 행 변형은 --create 절 범위(f)에서만 건다. 같은 모양의 행이 다른 절에 생겨도 사본이 어긋나지 않게 하기 위함이다.
awk '!/^### `--create`$/' "$SKILL" > "$sandbox/cr-no-section.md"
awk '/^### `--create`$/ { f = 1 } f && /^## / { f = 0 } f && /^### / && !/^### `--create`$/ { f = 0 }
     f && /^  2\. \*\*요약 제시\*\*/ { sub(/\*\*요약 제시\*\*/, "**승인**"); print; next }
     f && /^  3\. \*\*승인\*\*/ { sub(/\*\*승인\*\*/, "**요약 제시**"); print; next } { print }' \
  "$SKILL" > "$sandbox/cr-swap-steps.md"
awk '{ print } /^  6\. \*\*시작 질의\*\*/ { print "  7. **정리**: 초안 파일을 지운다." }' "$SKILL" > "$sandbox/cr-extra-step.md"
drop_literal "$SKILL" '승인 전에는 `gh issue create`를 실행하지 않는다' > "$sandbox/cr-no-approval.md"
drop_literal "$SKILL" 'active 작업 파일을 옮기거나 지우지 않는다' > "$sandbox/cr-no-active.md"
awk -v r="--repo '[^']*' " '/gh issue create --/ { sub(r, "") } { print }' "$SKILL" > "$sandbox/cr-no-repo.md"
awk -v r=" --body-file '[^']*'" '/gh issue create --/ { sub(r, "") } { print }' "$SKILL" > "$sandbox/cr-no-body-file.md"
awk '{ print } /^  1\. \*\*초안 작성\*\*/ { print "     - 제목은 `.ai/99_workspace/issue-create-title.md`에 따로 쓴다." }' \
  "$SKILL" > "$sandbox/cr-second-file.md"
drop_literal "$SKILL" '서로 독립으로 머지할 수 있는' > "$sandbox/cr-no-split-indep.md"
drop_literal "$SKILL" '분할을 권고' > "$sandbox/cr-no-split-advise.md"
drop_literal "$SKILL" '수치 기준은 두지 않' > "$sandbox/cr-no-split-number.md"
drop_literal "$SKILL" '결정은 사용자' > "$sandbox/cr-no-split-user.md"
drop_literal "$SKILL" 'AC가 대응하지 않는 포함 항목' > "$sandbox/cr-no-ac-report.md"
awk 'index($0, "AC가 대응하지 않는 포함 항목") { held = $0; next } { print }
     /^  3\. \*\*승인\*\*/ && held { print held; held = "" }' "$SKILL" > "$sandbox/cr-ac-report-moved.md"
awk '/^### `--create`$/ { f = 1 } f && /^### `--workflow-only`$/ { f = 0 }
     f { buf = buf $0 "\n"; next } { line[++n] = $0 }
     END { for (i = 1; i <= n; i++) { if (line[i] == "## 옵션") printf "%s", buf; print line[i] } }' \
  "$SKILL" > "$sandbox/cr-before-options.md"

assert_structure check_create_section "$SKILL"                          pass "--create 절: 실제 SKILL.md 통과"
assert_structure check_create_section "$sandbox/cr-no-section.md"       fail "--create 절: 절 헤더 삭제 격추"
assert_structure check_create_section "$sandbox/cr-swap-steps.md"       fail "--create 절: 요약 제시·승인 단계 순서 바꿈 격추"
assert_structure check_create_section "$sandbox/cr-extra-step.md"       fail "--create 절: 동작 단계 추가 격추"
assert_structure check_create_section "$sandbox/cr-no-approval.md"      fail "--create 절: 승인 전 미실행 문장 삭제 격추"
assert_structure check_create_section "$sandbox/cr-no-active.md"        fail "--create 절: active 무변경 문장 삭제 격추"
assert_structure check_create_section "$sandbox/cr-no-repo.md"          fail "--create 절: --repo 없는 명령 행 격추"
assert_structure check_create_section "$sandbox/cr-no-body-file.md"     fail "--create 절: --body-file 없는 명령 행 격추"
assert_structure check_create_section "$sandbox/cr-second-file.md"      fail "--create 절: 두 번째 작업 파일 경로 추가 격추"
assert_structure check_create_section "$sandbox/cr-no-split-indep.md"   fail "--create 절: 분할 권고 조건 문구 삭제 격추"
assert_structure check_create_section "$sandbox/cr-no-split-advise.md"  fail "--create 절: 분할 권고 문구 삭제 격추"
assert_structure check_create_section "$sandbox/cr-no-split-number.md"  fail "--create 절: 분할 수치 기준 미사용 문구 삭제 격추"
assert_structure check_create_section "$sandbox/cr-no-split-user.md"    fail "--create 절: 분할 결정 주체 문구 삭제 격추"
assert_structure check_create_section "$sandbox/cr-no-ac-report.md"     fail "--create 절: AC 미대응 포함 항목 보고 문구 삭제 격추"
assert_structure check_create_section "$sandbox/cr-ac-report-moved.md"  fail "--create 절: AC 미대응 포함 항목 보고의 승인 단계 이동 격추"
assert_structure check_create_section "$sandbox/cr-before-options.md"   fail "--create 절: 절의 옵션 섹션 앞 이동 격추"

# --- AC 정제 (issue #130) ---------------------------------------------------------
#
# 이슈에 AC가 있으면 3-2가 완료의 정의를 새로 쓰지 않고 AC를 정제하며, spec 항목의 출처 표기로 AC와 잇는다.
# SKILL.md는 3-2 범위(`3-2. 승인 후` 행부터 `4. ` 행 전까지)에 `AC 정제` 항목 1개와 조항 문구 6개가 있는지 본다.
# 다른 단계로 옮긴 문장은 세지 않는다.
# spec 템플릿은 완료의 정의 예시 항목에 `(AC<n>)` 출처 표기가 있고 `(회귀 방지 항목)`보다 앞에 오는지,
# plan 템플릿은 `## Tasks` 안내(Task 0 전까지)에 진행만 판정한다는 문장이 있는지 본다.

# check_ac_refine_skill <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_ac_refine_skill() {
  local r n p
  r="$(awk '/^   - \*\*3-2\. 승인 후\*\*/ { s = 1 } s && /^4\. / { exit } s' "$1")"
  [ -n "$r" ] || echo "3-2 범위 없음"
  n="$(printf '%s\n' "$r" | grep -c '^     - \*\*AC 정제\*\*: ')"
  [ "$n" -eq 1 ] || echo "3-2의 AC 정제 항목 ${n}개 (기대 1개)"
  for p in 'AC를 `[D]`/`[QD]`/`[ND]`로 정제' '출처 AC를 표기' '모든 AC가 1개 이상의 항목에 연결' \
           '`공통` 회귀 방지 항목은 예외' '`(AC 없음: <사유>)`로 적고 6단계 질의 대상' \
           'AC 번호는 뒤에만 추가하고 다시 매기지 않는다'; do
    printf '%s\n' "$r" | grep -qF -- "$p" || echo "3-2에 [$p] 없음"
  done
}

# check_ac_refine_spec_tpl <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_ac_refine_spec_tpl() {
  awk '/^## 완료의 정의/ { s = 1; next } /^## / { s = 0 }
       s && /^- \[ \] \[(D|QD|ND)\]/ {
         if ($0 ~ /\(AC[0-9]+(, AC[0-9]+)*\)/) n++
         if ($0 ~ /\(회귀 방지 항목\).*\(AC[0-9]/) print "출처 표기가 회귀 방지 표시 뒤 (행 " NR ")"
       }
       END { if (n < 1) print "출처 AC 표기 예시 없음" }' "$1"
}

# check_ac_refine_plan_tpl <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_ac_refine_plan_tpl() {
  local r p
  r="$(awk '/^## Tasks$/ { s = 1 } /^### Task 0/ { exit } s' "$1")"
  for p in '진행만 판정' 'spec에 없는 결과를 더하지 않는다'; do
    printf '%s\n' "$r" | grep -qF -- "$p" || echo "Tasks 안내에 [$p] 없음"
  done
}

drop_literal "$SKILL" 'AC를 `[D]`/`[QD]`/`[ND]`로 정제' > "$sandbox/ar-no-refine.md"
drop_literal "$SKILL" '출처 AC를 표기' > "$sandbox/ar-no-source.md"
drop_literal "$SKILL" '모든 AC가 1개 이상의 항목에 연결' > "$sandbox/ar-no-link.md"
drop_literal "$SKILL" '`공통` 회귀 방지 항목은 예외' > "$sandbox/ar-no-common.md"
drop_literal "$SKILL" '`(AC 없음: <사유>)`로 적고 6단계 질의 대상' > "$sandbox/ar-no-ac-none.md"
drop_literal "$SKILL" 'AC 번호는 뒤에만 추가하고 다시 매기지 않는다' > "$sandbox/ar-no-number.md"
# AC 정제 항목(하위 행 포함)을 3-2 범위 밖의 4단계 아래로 옮긴다.
awk '/^     - \*\*AC 정제\*\*: / { hold = 1 } hold && /^4\. / { hold = 0; print; printf "%s", buf; next }
     hold && !/^       / && !/^     - \*\*AC 정제\*\*: / { hold = 0 }
     hold { buf = buf $0 "\n"; next } { print }' "$SKILL" > "$sandbox/ar-moved-step4.md"
awk '/^## 완료의 정의/ { s = 1 } s { gsub(/ \(AC[0-9]+(, AC[0-9]+)*\)/, "") } { print }' \
  "$SPEC_TPL" > "$sandbox/ar-spec-no-source.md"
awk '{ sub(/ \(AC1\) \(회귀 방지 항목\)/, " (회귀 방지 항목) (AC1)"); print }' "$SPEC_TPL" > "$sandbox/ar-spec-source-after.md"
awk '!index($0, "spec에 없는 결과를 더하지 않는다")' "$TEMPLATE" > "$sandbox/ar-plan-no-rule.md"

assert_structure check_ac_refine_skill    "$SKILL"                            pass "AC 정제: 실제 SKILL.md 3-2 통과"
assert_structure check_ac_refine_skill    "$sandbox/ar-no-refine.md"          fail "AC 정제: 3-2 정제 문구 삭제 격추"
assert_structure check_ac_refine_skill    "$sandbox/ar-no-source.md"          fail "AC 정제: 3-2 출처 표기 문구 삭제 격추"
assert_structure check_ac_refine_skill    "$sandbox/ar-no-link.md"            fail "AC 정제: 3-2 모든 AC 연결 문구 삭제 격추"
assert_structure check_ac_refine_skill    "$sandbox/ar-no-common.md"          fail "AC 정제: 3-2 공통 회귀 방지 예외 문구 삭제 격추"
assert_structure check_ac_refine_skill    "$sandbox/ar-no-ac-none.md"         fail "AC 정제: 3-2 AC 없음 표기 문구 삭제 격추"
assert_structure check_ac_refine_skill    "$sandbox/ar-no-number.md"          fail "AC 정제: 3-2 AC 번호 유지 문구 삭제 격추"
assert_structure check_ac_refine_skill    "$sandbox/ar-moved-step4.md"        fail "AC 정제: AC 정제 항목의 4단계 이동 격추"
assert_structure check_ac_refine_spec_tpl "$SPEC_TPL"                         pass "AC 정제: 실제 spec 템플릿 출처 표기 통과"
assert_structure check_ac_refine_spec_tpl "$sandbox/ar-spec-no-source.md"     fail "AC 정제: spec 템플릿 출처 표기 삭제 격추"
assert_structure check_ac_refine_spec_tpl "$sandbox/ar-spec-source-after.md"  fail "AC 정제: spec 템플릿 출처 표기의 회귀 방지 표시 뒤 이동 격추"
assert_structure check_ac_refine_plan_tpl "$TEMPLATE"                         pass "AC 정제: 실제 plan 템플릿 Tasks 안내 통과"
assert_structure check_ac_refine_plan_tpl "$sandbox/ar-plan-no-rule.md"       fail "AC 정제: plan 템플릿 진행만 판정 문장 삭제 격추"

# --- 변경 통제 (issue #130) -------------------------------------------------------
#
# 3-2 정제와 작업 진행 중의 변경을 구체화·확장·완화로 나누고 확장·완화만 질의하는 규칙이 문장으로 지켜진다.
# SKILL.md는 `## 작업 진행 중` 범위의 `- **변경 통제**:` 항목 1개(다음 `- ` 항목 전까지)와 하위 3종 각 1개,
# 하위 행마다 정의·처리 문구, 3-2 범위(`3-2. 승인 후` 행부터 `4. ` 행 전까지)의 변경 통제 참조를 판정한다.
# workflow 템플릿은 `active/issue-workflow.md`의 원본이라 `## 작업 진행 중`에 변경 통제가 있는지 본다.

WORKFLOW_TPL="$HERE/../templates/issue-workflow-template.md"

# check_change_control_skill <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_change_control_skill() {
  local b n k l p
  b="$(awk '/^## 작업 진행 중$/ { w = 1; next } w && /^## / { exit }
            w && /^- \*\*변경 통제\*\*:/ { s = 1; print; next } s && /^- / { s = 0 } s' "$1")"
  n="$(printf '%s\n' "$b" | grep -c '^- \*\*변경 통제\*\*:')"
  [ "$n" -eq 1 ] || echo "작업 진행 중의 변경 통제 항목 ${n}개 (기대 1개)"
  for k in 구체화 확장 완화; do
    n="$(printf '%s\n' "$b" | grep -cE "^  - \*\*$k\*\*: ")"
    [ "$n" -eq 1 ] || echo "변경 통제의 $k 항목 ${n}개 (기대 1개)"
  done
  l="$(printf '%s\n' "$b" | grep -E '^  - \*\*구체화\*\*: ')"
  for p in '판정 기준만 명확히' '질의 없이 반영'; do
    printf '%s\n' "$l" | grep -qF -- "$p" || echo "구체화 항목에 [$p] 없음"
  done
  l="$(printf '%s\n' "$b" | grep -E '^  - \*\*확장\*\*: ')"
  for p in '범위 확장' '원장 등재' '새 이슈(`--create`)'; do
    printf '%s\n' "$l" | grep -qF -- "$p" || echo "확장 항목에 선택지 [$p] 없음"
  done
  l="$(printf '%s\n' "$b" | grep -E '^  - \*\*완화\*\*: ')"
  for p in 'AC를 빼거나 제외로 옮기는' '재승인 없이 반영하지 않는다'; do
    printf '%s\n' "$l" | grep -qF -- "$p" || echo "완화 항목에 [$p] 없음"
  done
  awk '/^   - \*\*3-2\. 승인 후\*\*/ { s = 1 } s && /^4\. / { exit } s && index($0, "변경 통제") { n++ }
       END { if (n < 1) print "3-2에 변경 통제 참조 없음" }' "$1"
}

# check_change_control_workflow <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_change_control_workflow() {
  awk '/^## 작업 진행 중$/ { s = 1; next } s && /^## / { exit } s && index($0, "변경 통제") { n++ }
       END { if (n < 1) print "작업 진행 중에 변경 통제 없음" }' "$1"
}

awk '!/^- \*\*변경 통제\*\*:/' "$SKILL" > "$sandbox/cc-no-item.md"
for kv in 구체화:refine 확장:ext 완화:relax; do
  k="${kv%%:*}"; v="${kv#*:}"
  awk -v k="$k" '$0 ~ "^  - \\*\\*" k "\\*\\*: " { next } { print }' "$SKILL" > "$sandbox/cc-no-$v.md"
  awk -v k="$k" '{ print } $0 ~ "^  - \\*\\*" k "\\*\\*: " { print }' "$SKILL" > "$sandbox/cc-dup-$v.md"
done
drop_literal "$SKILL" '판정 기준만 명확히' > "$sandbox/cc-no-refine-def.md"
drop_literal "$SKILL" '질의 없이 반영' > "$sandbox/cc-no-refine-act.md"
drop_literal "$SKILL" '범위 확장' > "$sandbox/cc-no-ext-scope.md"
drop_literal "$SKILL" '원장 등재' > "$sandbox/cc-no-ext-ledger.md"
drop_literal "$SKILL" '새 이슈(`--create`)' > "$sandbox/cc-no-ext-create.md"
drop_literal "$SKILL" 'AC를 빼거나 제외로 옮기는' > "$sandbox/cc-no-relax-ac.md"
drop_literal "$SKILL" '재승인 없이 반영하지 않는다' > "$sandbox/cc-no-relax-act.md"
awk '!/^     - \*\*변경 통제\*\*: /' "$SKILL" > "$sandbox/cc-no-3-2-ref.md"
# 변경 통제 항목(하위 행 포함)을 `## 작업 진행 중` 밖의 `## 이슈 완료 시` 아래로 옮긴다.
awk '/^- \*\*변경 통제\*\*:/ { hold = 1; buf = $0 "\n"; next }
     hold && /^  - / { buf = buf $0 "\n"; next } hold { hold = 0 }
     { print } /^## 이슈 완료 시$/ { print ""; printf "%s", buf }' "$SKILL" > "$sandbox/cc-moved-out.md"
awk '!index($0, "변경 통제")' "$WORKFLOW_TPL" > "$sandbox/cc-wf-no-item.md"

assert_structure check_change_control_skill    "$SKILL"                          pass "변경 통제: 실제 SKILL.md 통과"
assert_structure check_change_control_skill    "$sandbox/cc-no-item.md"          fail "변경 통제: 변경 통제 항목 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-refine.md"        fail "변경 통제: 구체화 항목 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-ext.md"           fail "변경 통제: 확장 항목 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-relax.md"         fail "변경 통제: 완화 항목 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-dup-refine.md"       fail "변경 통제: 구체화 항목 중복 격추"
assert_structure check_change_control_skill    "$sandbox/cc-dup-ext.md"          fail "변경 통제: 확장 항목 중복 격추"
assert_structure check_change_control_skill    "$sandbox/cc-dup-relax.md"        fail "변경 통제: 완화 항목 중복 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-refine-def.md"    fail "변경 통제: 구체화 정의 문구 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-refine-act.md"    fail "변경 통제: 구체화 처리 문구 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-ext-scope.md"     fail "변경 통제: 확장 선택지 범위 확장 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-ext-ledger.md"    fail "변경 통제: 확장 선택지 원장 등재 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-ext-create.md"    fail "변경 통제: 확장 선택지 새 이슈 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-relax-ac.md"      fail "변경 통제: 완화의 AC 삭제·제외 이동 문구 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-relax-act.md"     fail "변경 통제: 완화 처리 문장 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-3-2-ref.md"       fail "변경 통제: 3-2 참조 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-moved-out.md"        fail "변경 통제: 항목의 작업 진행 중 밖 이동 격추"
assert_structure check_change_control_workflow "$WORKFLOW_TPL"                   pass "변경 통제: 실제 workflow 템플릿 통과"
assert_structure check_change_control_workflow "$sandbox/cc-wf-no-item.md"       fail "변경 통제: workflow 템플릿 항목 삭제 격추"

# --- 본문 갱신 질의 (issue #130) ---------------------------------------------------
#
# AC가 없거나 AC가 대응하지 않는 R이 있는 기존 이슈가 계획 감사 뒤, Task 0 전에 이슈 본문 갱신 질의를 거친다.
# SKILL.md는 "새 이슈 시작 시" 번호 단계 1~6, 6단계 범위(`6. ` 행부터 다음 들여쓰지 않은 행 전까지)의 조항 문구,
# 6단계 `gh issue view` 명령 행 2개 이상·모두 `--repo '`, 파일 전체 `gh issue edit` 명령 행의 `--repo '`·`--body-file`,
# 5단계 범위(`5. ` 행부터 `6. ` 행 전까지)의 `Task 0` 0건을 판정한다.
# summary 템플릿은 `## 모델 기록`의 첫 `### Task ` 앞, `계획 감사` 줄 뒤에 `이슈 본문 갱신` 줄 1개와 값 3개를 본다.
# 계획 감사 항목은 SKILL.md·workflow 템플릿의 `## 작업 진행 중`에서 `plan-audit-report.md`를 담은 `- ` 행 1개가
# `6단계`와 `` `이슈 본문 갱신` 줄``을 언급하는지 본다. 세션이 바뀐 뒤 6단계를 건너뛰지 않게 하는 안내다.

# check_body_update_step <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_body_update_step() {
  local sec six p n
  sec="$(awk '/^## 새 이슈 시작 시$/ { f = 1; next } f && /^## / { exit } f' "$1")"
  [ "$(printf '%s\n' "$sec" | grep -oE '^[0-9]+\. ' | tr -d '. ' | tr '\n' '|')" = '1|2|3|4|5|6|' ] \
    || echo "새 이슈 시작 시 단계 번호가 1~6 아님"
  six="$(printf '%s\n' "$sec" | awk '/^6\. / { s = 1; print; next } s && /^[^[:space:]]/ { exit } s')"
  for p in '완료의 정의가 없거나' '`(AC 없음: …)` 항목이 있는' 'Task 0 전에' '승인할 때만' "gh issue edit --repo '" \
           "--body-file '.ai/99_workspace/issue-<번호>-body.md'" '`- [ ] AC<n>: `' '레벨 태그와 검증 명령을 옮기지 않는다' \
           '초안을 쓰기 직전에' '실행 직전에' '기준 본문과 다르면 실행하지 않' '.ai/99_workspace/issue-<번호>-body-base.md' 'cmp -s' \
           '본문 편집이 성공했을 때만' '(exit "$rc")'; do
    printf '%s\n' "$six" | grep -qF -- "$p" || echo "6단계에 [$p] 없음"
  done
  n="$(printf '%s\n' "$six" | grep -cF 'gh issue view ')"
  [ "$n" -ge 2 ] || echo "6단계 본문 조회 명령 ${n}개 (기대 2개 이상)"
  printf '%s\n' "$six" | grep -F 'gh issue view ' | grep -vF -e "--repo '" | sed 's/^/6단계 --repo 없는 조회 명령: /'
  n="$(grep -c 'gh issue edit --' "$1")"
  [ "$n" -ge 1 ] || echo "gh issue edit 명령 행 없음"
  grep -n 'gh issue edit --' "$1" | grep -vF -e "--repo '" | sed 's/^/--repo 없는 gh issue edit 행: /'
  grep -n 'gh issue edit --' "$1" | grep -vF -e '--body-file' | sed 's/^/--body-file 없는 gh issue edit 행: /'
  printf '%s\n' "$sec" | awk '/^5\. / { s = 1 } /^6\. / { s = 0 } s && /Task 0/ { print "5단계에 Task 0 직행: " $0 }'
}

# check_body_update_summary <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_body_update_summary() {
  awk '/^## 모델 기록$/ { s = 1; next } /^### Task / || (s && /^## /) { exit }
       s && /^- \*\*계획 감사\*\*: / { p = NR }
       s && /^- \*\*이슈 본문 갱신\*\*: / { n++; if (!p) b = 1; l = $0 }
       END {
         if (n != 1) print "모델 기록의 이슈 본문 갱신 줄 " n + 0 "개 (기대 1개)"
         if (b) print "이슈 본문 갱신 줄이 계획 감사 줄 앞"
         if (n == 1) {
           if (!index(l, "`갱신 · ")) print "이슈 본문 갱신 줄에 값 [`갱신 · ] 안내 없음"
           if (!index(l, "`거절`")) print "이슈 본문 갱신 줄에 값 [`거절`] 안내 없음"
           if (!index(l, "`대상 아님`")) print "이슈 본문 갱신 줄에 값 [`대상 아님`] 안내 없음"
         }
       }' "$1"
}

# check_body_update_audit_item <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_body_update_audit_item() {
  awk '/^## 작업 진행 중$/ { s = 1; next } s && /^## / { s = 0 }
       s && /^- / && /plan-audit-report\.md/ { n++
         if (!index($0, "6단계")) print "계획 감사 항목에 6단계 없음"
         if (!index($0, "`이슈 본문 갱신` 줄")) print "계획 감사 항목에 이슈 본문 갱신 줄 없음" }
       END { if (n != 1) print "작업 진행 중의 계획 감사 항목 " n + 0 "개 (기대 1개)" }' "$1"
}

# 6단계 사본. 문구 삭제는 drop_literal로 파일 전체에서 지운다(6단계 밖에 같은 문구가 남아도 6단계 판정은 실패해야 한다).
awk '/^6\. / { s = 1; next } s && /^[^[:space:]]/ { s = 0 } s { next } 1' "$SKILL" > "$sandbox/bu-no-step6.md"
i=0
for p in '완료의 정의가 없거나' '`(AC 없음: …)` 항목이 있는' 'Task 0 전에' '승인할 때만' "gh issue edit --repo '" \
         "--body-file '.ai/99_workspace/issue-<번호>-body.md'" '`- [ ] AC<n>: `' '레벨 태그와 검증 명령을 옮기지 않는다' \
         '초안을 쓰기 직전에' '실행 직전에' '기준 본문과 다르면 실행하지 않' '.ai/99_workspace/issue-<번호>-body-base.md' 'cmp -s' \
         '본문 편집이 성공했을 때만' '(exit "$rc")'; do
  i=$((i + 1)); drop_literal "$SKILL" "$p" > "$sandbox/bu-drop-$i.md"
done
# 기존 명령 행은 그대로 두고 `--repo` 없는 명령 행을 6단계 안에 더한다("모두 `--repo`" 판정만 걸리게 한다).
awk '{ print } /gh issue edit --repo / { print "       gh issue edit --body-file '\''.ai/99_workspace/issue-<번호>-body.md'\'' '\''<번호>'\''" }' \
  "$SKILL" > "$sandbox/bu-edit-no-repo.md"
awk '{ print } /^     gh issue view .*body-base\.md/ { print "     gh issue view '\''<번호>'\'' --json body -q .body" }' \
  "$SKILL" > "$sandbox/bu-view-no-repo.md"
awk '!(/gh issue view / && /"\$now"/)' "$SKILL" > "$sandbox/bu-view-one.md"
# 6단계 하위 행을 `6. ` 행 앞(5단계 하위)으로 옮긴다.
awk '/^6\. / { head = $0; m = 1; next }
     m && /^[^[:space:]]/ { printf "%s", buf; print head; print ""; m = 0 }
     m { buf = buf $0 "\n"; next } { print }' "$SKILL" > "$sandbox/bu-moved-step5.md"
awk '/^   - \*\*건너뜀\*\*: / { sub(/6단계로 진행한다/, "Task 0으로 진행한다") } { print }' "$SKILL" > "$sandbox/bu-step5-task0.md"

# summary 템플릿 사본.
awk '!/^- \*\*이슈 본문 갱신\*\*: /' "$SUMMARY_TPL" > "$sandbox/bu-sum-no-line.md"
awk '{ print } /^- \*\*이슈 본문 갱신\*\*: / { print }' "$SUMMARY_TPL" > "$sandbox/bu-sum-dup.md"
BU_LINE="$(grep -E '^- \*\*이슈 본문 갱신\*\*: ' "$SUMMARY_TPL")" \
  awk '/^- \*\*이슈 본문 갱신\*\*: / { next } /^- \*\*계획 감사\*\*: / { print ENVIRON["BU_LINE"] } { print }' \
  "$SUMMARY_TPL" > "$sandbox/bu-sum-before-audit.md"
BU_LINE="$(grep -E '^- \*\*이슈 본문 갱신\*\*: ' "$SUMMARY_TPL")" \
  awk '/^- \*\*이슈 본문 갱신\*\*: / { next } { print } /^### Task / && !d { print ""; print ENVIRON["BU_LINE"]; d = 1 }' \
  "$SUMMARY_TPL" > "$sandbox/bu-sum-in-task.md"
drop_literal "$SUMMARY_TPL" '`갱신 · ' > "$sandbox/bu-sum-no-update.md"
drop_literal "$SUMMARY_TPL" '`거절`' > "$sandbox/bu-sum-no-reject.md"
drop_literal "$SUMMARY_TPL" '`대상 아님`' > "$sandbox/bu-sum-no-na.md"

# 계획 감사 항목 사본 (SKILL.md·workflow 템플릿 각각).
for fv in "$SKILL:skill" "$WORKFLOW_TPL:wf"; do
  f="${fv%:*}"; v="${fv##*:}"
  awk '/^- / && /plan-audit-report\.md/ { gsub(/6단계/, "") } { print }' "$f" > "$sandbox/bu-$v-no-step6.md"
  awk -v s='`이슈 본문 갱신` 줄' '/^- / && /plan-audit-report\.md/ { while ((i = index($0, s))) $0 = substr($0, 1, i - 1) substr($0, i + length(s)) } { print }' \
    "$f" > "$sandbox/bu-$v-no-line.md"
  awk '{ print } /^- / && /plan-audit-report\.md/ { print }' "$f" > "$sandbox/bu-$v-dup.md"
done

assert_structure check_body_update_step       "$SKILL"                            pass "본문 갱신 질의: 실제 SKILL.md 6단계 통과"
assert_structure check_body_update_step       "$sandbox/bu-no-step6.md"           fail "본문 갱신 질의: 6단계 삭제 격추"
i=0
for p in '대상 판정 완료의 정의 없음' '대상 판정 AC 없음 항목' 'Task 0 전 시점' '승인할 때만 실행' 'gh issue edit 명령' \
         '갱신 본문 파일' 'AC 행 형식' '레벨 태그·검증 명령 미이전' '초안 직전 조회' '실행 직전 재조회' \
         '불일치 시 미실행' '기준 본문 파일' 'cmp -s 비교' '편집 성공 시만 기록' '종료 코드 반환'; do
  i=$((i + 1))
  assert_structure check_body_update_step     "$sandbox/bu-drop-$i.md"            fail "본문 갱신 질의: 6단계 $p 문구 삭제 격추"
done
assert_structure check_body_update_step       "$sandbox/bu-edit-no-repo.md"       fail "본문 갱신 질의: --repo 없는 gh issue edit 행 격추"
assert_structure check_body_update_step       "$sandbox/bu-view-no-repo.md"       fail "본문 갱신 질의: --repo 없는 gh issue view 행 격추"
assert_structure check_body_update_step       "$sandbox/bu-view-one.md"           fail "본문 갱신 질의: 조회 명령 1개로 줄이기 격추"
assert_structure check_body_update_step       "$sandbox/bu-moved-step5.md"        fail "본문 갱신 질의: 6단계 하위 행의 5단계 이동 격추"
assert_structure check_body_update_step       "$sandbox/bu-step5-task0.md"        fail "본문 갱신 질의: 5단계 Task 0 직행 복원 격추"
assert_structure check_body_update_summary    "$SUMMARY_TPL"                      pass "본문 갱신 질의: 실제 summary 템플릿 통과"
assert_structure check_body_update_summary    "$sandbox/bu-sum-no-line.md"        fail "본문 갱신 질의: summary 이슈 본문 갱신 줄 삭제 격추"
assert_structure check_body_update_summary    "$sandbox/bu-sum-dup.md"            fail "본문 갱신 질의: summary 이슈 본문 갱신 줄 중복 격추"
assert_structure check_body_update_summary    "$sandbox/bu-sum-before-audit.md"   fail "본문 갱신 질의: summary 줄의 계획 감사 줄 앞 이동 격추"
assert_structure check_body_update_summary    "$sandbox/bu-sum-in-task.md"        fail "본문 갱신 질의: summary 줄의 첫 Task 블록 안 이동 격추"
assert_structure check_body_update_summary    "$sandbox/bu-sum-no-update.md"      fail "본문 갱신 질의: summary 값 갱신 삭제 격추"
assert_structure check_body_update_summary    "$sandbox/bu-sum-no-reject.md"      fail "본문 갱신 질의: summary 값 거절 삭제 격추"
assert_structure check_body_update_summary    "$sandbox/bu-sum-no-na.md"          fail "본문 갱신 질의: summary 값 대상 아님 삭제 격추"
assert_structure check_body_update_audit_item "$SKILL"                            pass "본문 갱신 질의: 실제 SKILL.md 계획 감사 항목 통과"
assert_structure check_body_update_audit_item "$sandbox/bu-skill-no-step6.md"     fail "본문 갱신 질의: SKILL.md 계획 감사 항목 6단계 삭제 격추"
assert_structure check_body_update_audit_item "$sandbox/bu-skill-no-line.md"      fail "본문 갱신 질의: SKILL.md 계획 감사 항목 이슈 본문 갱신 줄 삭제 격추"
assert_structure check_body_update_audit_item "$sandbox/bu-skill-dup.md"          fail "본문 갱신 질의: SKILL.md 계획 감사 항목 중복 격추"
assert_structure check_body_update_audit_item "$WORKFLOW_TPL"                     pass "본문 갱신 질의: 실제 workflow 템플릿 계획 감사 항목 통과"
assert_structure check_body_update_audit_item "$sandbox/bu-wf-no-step6.md"        fail "본문 갱신 질의: workflow 템플릿 계획 감사 항목 6단계 삭제 격추"
assert_structure check_body_update_audit_item "$sandbox/bu-wf-no-line.md"         fail "본문 갱신 질의: workflow 템플릿 계획 감사 항목 이슈 본문 갱신 줄 삭제 격추"
assert_structure check_body_update_audit_item "$sandbox/bu-wf-dup.md"             fail "본문 갱신 질의: workflow 템플릿 계획 감사 항목 중복 격추"

# --- 요구사항 묶음·하위 목록 (issue #140) -----------------------------------------
#
# 요구사항이 5개 이상이면 포함은 내용별, 제외는 사유별로 묶고 R 첫 줄 아래에 세부 조건을 하위 목록으로 두는 규칙이
# spec 템플릿 요구사항 안내에서 사라지지 않았는지 판정한다.
# 조항은 행 단위로 본다. 행은 `- <라벨>: `로 시작하는 줄과 두 칸 들여쓴 이어지는 줄이다.
# 같은 문구가 다른 행이나 다른 섹션에 있으면 세지 않는다. `5개 미만이면 묶지 않는다`는 포함 묶음·제외 묶음 두 행에 있다.

# group_req_section <파일> → spec 요구사항 섹션 (헤더 행 다음부터 다음 `## ` 앞까지)
group_req_section() { awk '/^## 요구사항 \(Requirements\)$/ { s = 1; next } /^## / { s = 0 } s' "$1"; }

# group_row <라벨> → 표준 입력에서 `- <라벨>: `로 시작하는 행과 두 칸 들여쓴 이어지는 줄
group_row() { awk -v l="- $1: " 'index($0, l) == 1 { s = 1; print; next } s && /^  / { print; next } { s = 0 }'; }

# group_need <섹션 내용> <라벨> <문구> → 그 행에 문구가 없으면 위반 1줄
group_need() { printf '%s\n' "$1" | group_row "$2" | grep -qF -- "$3" || echo "[$2] 행에 [$3] 없음"; }

# check_group_spec_tpl <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_group_spec_tpl() {
  local sec p
  sec="$(group_req_section "$1")"
  for p in '포함 묶음' '제외 묶음'; do
    [ "$(printf '%s\n' "$sec" | grep -c "^- $p: ")" -eq 1 ] || echo "요구사항 섹션의 [$p] 행이 1개가 아님"
  done
  for p in '첫 줄은 한 문장' '세부 조건과 근거 표기는 그 항목의 하위 목록에' '하위 목록의 세부 조건도 그 R의 요구사항'; do
    group_need "$sec" '포함' "$p"
  done
  for p in '포함 항목이 5개 이상이면' '`#### <묶음 이름>`' '5개 미만이면 묶지 않는다' '기능 영역을 가리키는 명사구' \
           '다시 매기지 않' '다음 번호를 받아 맞는 묶음' '이슈 본문의 포함이 묶여 있으면' '묶음 이름을 이어 쓴다'; do
    group_need "$sec" '포함 묶음' "$p"
  done
  for p in '제외 항목이 5개 이상이면' '`#### 보류`, `#### 대체`, `#### 불필요` 순서' '5개 미만이면 묶지 않는다' '항목이 없는 사유는 생략'; do
    group_need "$sec" '제외 묶음' "$p"
  done
  group_need "$sec" '근거 표기' '하위 목록'
  group_need "$sec" '함께 해소 표기' '첫 줄 끝에 `(함께 해소: K-<번호>)`'
  if printf '%s\n' "$sec" | group_row '근거 표기' | grep -qF '문장 끝'; then echo '[근거 표기] 행에 옛 위치(문장 끝)가 남음'; fi
  printf '%s\n' "$sec" | awk '/^### 포함$/ { i = 1; next } /^### / { i = 0 }
    i && p ~ /^- R[0-9]+: / && /^  - / { n++ } { p = $0 }
    END { if (n < 1) print "포함 예시의 R 항목 바로 아래에 하위 목록 줄 없음" }'
}

# 반례 fixture 는 실제 템플릿의 awk 변형으로 만든다. 문구 삭제는 요구사항 섹션의 그 행에서만 한다.
# group_drop_in_row <파일> <라벨> <문구> → 그 행(이어지는 줄 포함)에서만 문구를 지운 사본
group_drop_in_row() {
  awk -v l="- $2: " -v s="$3" '
    /^## / { q = ($0 == "## 요구사항 (Requirements)") }
    { if (q && index($0, l) == 1) r = 1; else if (r && !/^  /) r = 0 }
    r { while ((i = index($0, s))) $0 = substr($0, 1, i - 1) substr($0, i + length(s)) }
    { print }' "$1"
}

# group_drop_row <파일> <라벨> → 요구사항 섹션의 그 행(이어지는 줄 포함)을 지운 사본
group_drop_row() {
  awk -v l="- $2: " '
    /^## / { q = ($0 == "## 요구사항 (Requirements)") }
    { if (q && index($0, l) == 1) r = 1; else if (r && !/^  /) r = 0 }
    !r' "$1"
}

GS_N=0
# group_spec_drop_case <라벨> <문구> → spec 템플릿의 그 행에서 문구를 지운 사본이 격추되는지 본다
group_spec_drop_case() {
  GS_N=$((GS_N + 1))
  group_drop_in_row "$SPEC_TPL" "$1" "$2" > "$sandbox/gs-drop-$GS_N.md"
  assert_structure check_group_spec_tpl "$sandbox/gs-drop-$GS_N.md" fail "요구사항 묶음: spec 템플릿 [$1] 행 [$2] 삭제 격추"
}

assert_structure check_group_spec_tpl "$SPEC_TPL" pass "요구사항 묶음: spec 템플릿 실제 템플릿 통과"
for p in '첫 줄은 한 문장' '세부 조건과 근거 표기는 그 항목의 하위 목록에' '하위 목록의 세부 조건도 그 R의 요구사항'; do
  group_spec_drop_case '포함' "$p"
done
for p in '포함 항목이 5개 이상이면' '`#### <묶음 이름>`' '5개 미만이면 묶지 않는다' '기능 영역을 가리키는 명사구' \
         '다시 매기지 않' '다음 번호를 받아 맞는 묶음' '이슈 본문의 포함이 묶여 있으면' '묶음 이름을 이어 쓴다'; do
  group_spec_drop_case '포함 묶음' "$p"
done
for p in '제외 항목이 5개 이상이면' '`#### 보류`, `#### 대체`, `#### 불필요` 순서' '5개 미만이면 묶지 않는다' '항목이 없는 사유는 생략'; do
  group_spec_drop_case '제외 묶음' "$p"
done
group_spec_drop_case '근거 표기' '하위 목록'
group_spec_drop_case '함께 해소 표기' '첫 줄 끝에'

group_drop_row "$SPEC_TPL" '포함 묶음' > "$sandbox/gs-no-inc-row.md"
group_drop_row "$SPEC_TPL" '제외 묶음' > "$sandbox/gs-no-exc-row.md"
awk -v l="- 포함 묶음: " '
  /^## / { q = ($0 == "## 요구사항 (Requirements)"); d = ($0 == "## 완료의 정의 (Definition of Done)") }
  { if (q && index($0, l) == 1) r = 1; else if (r && !/^  /) r = 0 }
  r { held = held $0 "\n"; next }
  { print }
  d && /^<!--$/ { printf "%s", held; d = 0 }' "$SPEC_TPL" > "$sandbox/gs-inc-row-in-dod.md"
awk '/^## / { q = ($0 == "## 요구사항 (Requirements)") }
     q && /^- 근거 표기: / { $0 = $0 " 문장 끝에 병기해도 된다." } { print }' "$SPEC_TPL" > "$sandbox/gs-basis-end.md"
awk '/^### 포함$/ { i = 1 } /^### 제외$/ { i = 0 } i && /^  - / { next } { print }' "$SPEC_TPL" > "$sandbox/gs-no-sublist.md"

assert_structure check_group_spec_tpl "$sandbox/gs-no-inc-row.md"     fail "요구사항 묶음: spec 템플릿 포함 묶음 행 삭제 격추"
assert_structure check_group_spec_tpl "$sandbox/gs-no-exc-row.md"     fail "요구사항 묶음: spec 템플릿 제외 묶음 행 삭제 격추"
assert_structure check_group_spec_tpl "$sandbox/gs-inc-row-in-dod.md" fail "요구사항 묶음: spec 템플릿 포함 묶음 행의 완료의 정의 주석 이동 격추"
assert_structure check_group_spec_tpl "$sandbox/gs-basis-end.md"      fail "요구사항 묶음: spec 템플릿 근거 표기 행에 문장 끝 다시 넣기 격추"
assert_structure check_group_spec_tpl "$sandbox/gs-no-sublist.md"     fail "요구사항 묶음: spec 템플릿 포함 예시 하위 목록 줄 삭제 격추"

# 이슈 본문 템플릿의 범위 안내도 같은 5개 기준으로 묶고 세부 조건을 하위 목록에 두도록 안내한다.
# 범위 섹션(주석 행 포함)만 읽어, 규칙 문장을 다른 섹션으로 옮기면 세지 않는다.
# `5개 미만이면 묶지 않는다`는 포함·제외 두 곳에 있어 횟수로 판정한다.

# group_scope_section <파일> → 이슈 본문 범위 섹션 (헤더 행 다음부터 다음 `## ` 앞까지)
group_scope_section() { awk '/^## 범위$/ { s = 1; next } /^## / { s = 0 } s' "$1"; }

# check_group_body_tpl <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_group_body_tpl() {
  local sec p n
  sec="$(group_scope_section "$1")"
  for p in '포함 항목이 5개 이상이면' '`#### <묶음 이름>`' '제외 항목이 5개 이상이면' \
           '`#### 보류`, `#### 대체`, `#### 불필요` 순서' '항목이 없는 사유는 생략' '세부 조건은 하위 목록에 둔다'; do
    printf '%s\n' "$sec" | grep -qF -- "$p" || echo "범위 안내에 [$p] 없음"
  done
  n="$(printf '%s\n' "$sec" | grep -oF '5개 미만이면 묶지 않는다' | wc -l | tr -d ' ')"
  [ "$n" -eq 2 ] || echo "범위 안내의 [5개 미만이면 묶지 않는다] ${n}회 (기대 2회: 포함·제외)"
  if printf '%s\n' "$sec" | grep -qF '관련 항목은 하위 목록으로 묶어도 된다'; then
    echo '범위 안내에 옛 문장(관련 항목은 하위 목록으로 묶어도 된다)이 남음'
  fi
}

# group_scope_drop <파일> <문구> [1] → 범위 섹션에서 문구를 지운 사본 (셋째 인자가 1이면 처음 1회만 지운다)
group_scope_drop() {
  awk -v s="$2" -v once="${3:-0}" '
    /^## / { q = ($0 == "## 범위") }
    q && !(once && done) {
      while ((i = index($0, s))) {
        $0 = substr($0, 1, i - 1) substr($0, i + length(s))
        if (once) { done = 1; break }
      }
    }
    { print }' "$1"
}

assert_structure check_group_body_tpl "$BODY_TPL" pass "요구사항 묶음: 이슈 본문 템플릿 실제 템플릿 통과"
GB_N=0
for p in '포함 항목이 5개 이상이면' '`#### <묶음 이름>`' '제외 항목이 5개 이상이면' \
         '`#### 보류`, `#### 대체`, `#### 불필요` 순서' '항목이 없는 사유는 생략' '세부 조건은 하위 목록에 둔다'; do
  GB_N=$((GB_N + 1))
  group_scope_drop "$BODY_TPL" "$p" > "$sandbox/gb-drop-$GB_N.md"
  assert_structure check_group_body_tpl "$sandbox/gb-drop-$GB_N.md" fail "요구사항 묶음: 이슈 본문 템플릿 [$p] 삭제 격추"
done

group_scope_drop "$BODY_TPL" '5개 미만이면 묶지 않는다' 1 > "$sandbox/gb-under5-once.md"
awk '/^## / { q = ($0 == "## 범위") }
     q && /^- 포함: / { $0 = $0 " 관련 항목은 하위 목록으로 묶어도 된다." } { print }' "$BODY_TPL" > "$sandbox/gb-old-sentence.md"
GB_RULE="$(grep -F '포함 항목이 5개 이상이면' "$BODY_TPL")" \
  awk 'index($0, "포함 항목이 5개 이상이면") { next }
       /^## / { d = ($0 == "## 완료의 정의") }
       { print }
       d && /^<!--$/ { print ENVIRON["GB_RULE"]; d = 0 }' "$BODY_TPL" > "$sandbox/gb-inc-rule-in-dod.md"

assert_structure check_group_body_tpl "$sandbox/gb-under5-once.md"     fail "요구사항 묶음: 이슈 본문 템플릿 5개 미만 규칙 한 곳만 삭제 격추"
assert_structure check_group_body_tpl "$sandbox/gb-old-sentence.md"    fail "요구사항 묶음: 이슈 본문 템플릿 옛 하위 목록 문장 다시 넣기 격추"
assert_structure check_group_body_tpl "$sandbox/gb-inc-rule-in-dod.md" fail "요구사항 묶음: 이슈 본문 템플릿 포함 묶음 규칙의 완료의 정의 주석 이동 격추"

# SKILL.md 3-1 승인 요청과 `--create` 요약 제시는 목록을 묶음대로 나눠 보여 주고 항목은 첫 줄만 보여 준다.
# 3-1은 `3-1. 승인 전` 행부터 `3-2. 승인 후` 행 앞까지, 요약 제시는 `--create` 절의 그 단계(다음 번호 단계 앞까지)만 읽는다.
# 범위가 비면 문구 검사가 공집합 통과가 되므로 범위 실재를 먼저 판정한다.

# group_skill_31 <파일> → "새 이슈 시작 시" 3-1 범위
group_skill_31() { awk '/^   - \*\*3-1\. 승인 전/ { s = 1 } /^   - \*\*3-2\. 승인 후/ { s = 0 } s' "$1"; }

# group_skill_create_summary <파일> → `--create` 절의 요약 제시 단계
group_skill_create_summary() {
  awk '/^### `--create`$/ { f = 1; next } f && /^#{2,3} / { exit } f' "$1" \
    | awk '/^  [0-9]+\. \*\*요약 제시\*\*/ { s = 1; print; next } s && /^  [0-9]+\. / { exit } s'
}

# check_group_skill_31 <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_group_skill_31() {
  local sec p
  sec="$(group_skill_31 "$1")"
  if [ -z "$sec" ]; then echo '3-1 범위 없음'; return; fi
  for p in 'spec의 묶음대로 나눠 보여 주고' 'R은 첫 줄만 보여 준다' \
           '이슈 본문에 근거가 없는' '목록에서 따로 표시하고, 추가로 확정할지 제외할지 질의한다' \
           '첫 줄 끝에 `(함께 해소: K-<번호>)`'; do
    printf '%s\n' "$sec" | grep -qF -- "$p" || echo "3-1에 [$p] 없음"
  done
}

# check_group_skill_create <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_group_skill_create() {
  local st p
  st="$(group_skill_create_summary "$1")"
  if [ -z "$st" ]; then echo '--create 요약 제시 단계 범위 없음'; return; fi
  for p in '초안의 묶음대로 나눠 보여 주고' '항목은 첫 줄만 보여 준다'; do
    printf '%s\n' "$st" | grep -qF -- "$p" || echo "요약 제시 단계에 [$p] 없음"
  done
}

assert_structure check_group_skill_31     "$SKILL" pass "요구사항 묶음: SKILL.md 3-1 실제 SKILL.md 통과"
assert_structure check_group_skill_create "$SKILL" pass "요구사항 묶음: SKILL.md --create 실제 SKILL.md 통과"
GK_N=0
for p in 'spec의 묶음대로 나눠 보여 주고' 'R은 첫 줄만 보여 준다' \
         '이슈 본문에 근거가 없는' '목록에서 따로 표시하고, 추가로 확정할지 제외할지 질의한다'; do
  GK_N=$((GK_N + 1))
  drop_literal "$SKILL" "$p" > "$sandbox/gk-31-drop-$GK_N.md"
  assert_structure check_group_skill_31 "$sandbox/gk-31-drop-$GK_N.md" fail "요구사항 묶음: SKILL.md 3-1 [$p] 삭제 격추"
done
for p in '초안의 묶음대로 나눠 보여 주고' '항목은 첫 줄만 보여 준다'; do
  GK_N=$((GK_N + 1))
  drop_literal "$SKILL" "$p" > "$sandbox/gk-cr-drop-$GK_N.md"
  assert_structure check_group_skill_create "$sandbox/gk-cr-drop-$GK_N.md" fail "요구사항 묶음: SKILL.md --create [$p] 삭제 격추"
done

awk 'index($0, "spec의 묶음대로 나눠 보여 주고") { held = $0; next } { print }
     /^   - \*\*3-2\. 승인 후/ && held { print held; held = "" }' "$SKILL" > "$sandbox/gk-31-moved-32.md"
awk '{ sub(/R 첫 줄 끝에/, "R 문장 끝에"); print }' "$SKILL" > "$sandbox/gk-31-sentence-end.md"
awk 'index($0, "**목록 제시**") { held = $0; next } { print }
     /^  3\. \*\*승인\*\*/ && held { print held; held = "" }' "$SKILL" > "$sandbox/gk-cr-moved-approval.md"

assert_structure check_group_skill_31     "$sandbox/gk-31-moved-32.md"        fail "요구사항 묶음: SKILL.md 3-1 새 항목의 3-2 이동 격추"
assert_structure check_group_skill_31     "$sandbox/gk-31-sentence-end.md"    fail "요구사항 묶음: SKILL.md 3-1 함께 해소 표기 위치 R 문장 끝 되돌리기 격추"
assert_structure check_group_skill_create "$sandbox/gk-cr-moved-approval.md"  fail "요구사항 묶음: SKILL.md --create 목록 제시 항목의 승인 단계 이동 격추"

# 포함·제외 표지는 `### 포함`·`### 제외` 제목이라 `#### ` 묶음 제목보다 한 단계 위로 보인다.
# 표지 하나를 굵은 글씨로 되돌린 사본은 spec 구조 검사·이슈 본문 템플릿 검사가 격추한다.
group_label_bold() { awk -v l="### $2" -v b="**$2**" '$0 == l { $0 = b } { print }' "$1"; }  # <파일> <표지 이름>
group_label_bold "$SPEC_TPL" 포함 > "$sandbox/gl-spec-inc-bold.md"
group_label_bold "$SPEC_TPL" 제외 > "$sandbox/gl-spec-exc-bold.md"
group_label_bold "$BODY_TPL" 포함 > "$sandbox/gl-body-inc-bold.md"
group_label_bold "$BODY_TPL" 제외 > "$sandbox/gl-body-exc-bold.md"
awk '/^### 포함$/ { hold = 1 } /^### 제외$/ { hold = 0 } hold { buf = buf $0 "\n"; next }
     { print } /^- <검토했지만 하지 않는 것>/ { print ""; printf "%s", buf }' "$BODY_TPL" > "$sandbox/gl-body-swap.md"

assert_structure check_spec_structure "$sandbox/gl-spec-inc-bold.md" fail "요구사항 표지: spec 템플릿 포함 표지 굵은 글씨 되돌리기 격추"
assert_structure check_spec_structure "$sandbox/gl-spec-exc-bold.md" fail "요구사항 표지: spec 템플릿 제외 표지 굵은 글씨 되돌리기 격추"
assert_structure check_body_template  "$sandbox/gl-body-inc-bold.md" fail "요구사항 표지: 이슈 본문 템플릿 포함 표지 굵은 글씨 되돌리기 격추"
assert_structure check_body_template  "$sandbox/gl-body-exc-bold.md" fail "요구사항 표지: 이슈 본문 템플릿 제외 표지 굵은 글씨 되돌리기 격추"
assert_structure check_body_template  "$sandbox/gl-body-swap.md"     fail "요구사항 표지: 이슈 본문 템플릿 포함·제외 표지 순서 역전 격추"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
