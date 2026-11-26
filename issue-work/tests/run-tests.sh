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

### Task N (고정): 마무리

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

### Task N (고정): 마무리

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
  # 5단계는 결정만 받는다 — 소스를 고치는 시점은 다음 회차의 구현이고, 지표는 발견이 나온 Task 에 센다 (issue #145).
  local s5 t
  s5="$(printf '%s\n' "$s45" | awk '/^  5\. /{f=1} f')"
  for t in '결정만 받고 소스를 고치지 않는다' '다음 회차의 계획 수립에서 plan에 Task로 더하고' \
           '발견이 나온 Task 블록의 `audit 발견`' '고친 Task의 `대응 발견`' '승인분만 그 두 파일에 반영한다'; do
    printf '%s\n' "$s5" | grep -qF -- "$t" || echo "5단계 범위에 [$t] 없음"
  done
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
i=0
for p in '결정만 받고 소스를 고치지 않는다' '다음 회차의 계획 수립에서 plan에 Task로 더하고' \
         '발견이 나온 Task 블록의 `audit 발견`' '고친 Task의 `대응 발견`' '승인분만 그 두 파일에 반영한다'; do
  i=$((i + 1))
  DL="$p" awk '{ while ((k = index($0, ENVIRON["DL"]))) $0 = substr($0, 1, k - 1) substr($0, k + length(ENVIRON["DL"])); print }' "$SKILL" > "$sandbox/r-drop-$i.md"
  assert_response "$sandbox/r-drop-$i.md"    fail "response 스모크: 5단계 [$p] 삭제 격추"
done

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
# 포함 목록의 R 번호는 완료의 정의 AC 행 끝의 `(R<n>)` 표기와 이어져야 한다 (issue #145) —
# 포함 R 마다 AC 행이 1개 이상이고, AC 행이 가리키는 R 은 포함 목록에 있어야 한다.
# AC 행은 완료의 정의 섹션 안의 것만 연결로 세고, 섹션 밖의 AC 행은 위반으로 센다.
# 섹션 순서(목표 → 요구사항 → DoD)는 헤더 위치로 판정한다 —
# 소속만 보면 요구사항 블록 전체를 DoD 뒤로 옮겨도 통과한다.
# 목표·완료의 정의 헤더도 개수를 판정한다 — 위치 판정은 헤더가 있을 때만 걸려 삭제·중복이 통과한다.
# R·AC 번호 집합은 출현 횟수로 누적한다 — 불리언 대입은 같은 번호의 중복 항목을 잃는다.
# HTML 주석 안의 형식 안내는 행으로 세지 않는다.
check_spec_structure() {
  awk '
    /^## /                           { sec = $0; list = "" }
    /<!--/                           { c = 1 }
    c                                { if (/-->/) c = 0; next }
    /^## 목표 \(Goal\)$/             { goal++; goal_at = NR }
    /^## 요구사항 \(Requirements\)$/ { req++; req_at = NR }
    /^## 완료의 정의 \(Definition of Done\)$/ { dod++; dod_at = NR }
    /^### 포함$/                     { inc++; if (sec != "## 요구사항 (Requirements)") mis++; inc_at = NR; list = "inc" }
    /^### 제외$/                     { exc++; if (sec != "## 요구사항 (Requirements)") mis++; exc_at = NR; list = "exc" }
    /^\*\*(포함|제외)\*\*/           { bold++ }
    list == "inc" && /^- /           { if ($0 ~ /^- R[0-9]+: /) { inc_items++
                                         n = $0; sub(/^- R/, "", n); sub(/:.*/, "", n); inc_rs[n]++
                                       } else inc_bad++ }
    list == "exc" && /^- /           { exc_items++ }
    /^- \[ \] AC[0-9]+: /            { if (sec != "## 완료의 정의 (Definition of Done)") { ac_mis++; next }
                                       n = $0; sub(/^- \[ \] AC/, "", n); sub(/:.*/, "", n); acs[n]++
                                       if (match($0, /\(R[0-9]+(, R[0-9]+)*\)$/)) {
                                         v = substr($0, RSTART + 1, RLENGTH - 2); gsub(/R/, "", v)
                                         m = split(v, a, /, /); for (i = 1; i <= m; i++) link[a[i]]++
                                       } }
    /^## 범위/                       { scope++ }
    /포함 \(In\)|비포함 ?\(Out\)/    { old++ }
    END {
      if (goal != 1)      print "목표 헤더 " goal + 0 "개 (기대 1개)"
      if (req != 1)       print "요구사항 헤더 " req + 0 "개 (기대 1개)"
      if (dod != 1)       print "완료의 정의 헤더 " dod + 0 "개 (기대 1개)"
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
      if (ac_mis)         print "AC 행이 완료의 정의 섹션 밖: " ac_mis "개"
      for (n in inc_rs) if (!(n in link))   print "포함 R" n " 에 연결된 AC 행 없음"
      for (n in link)   if (!(n in inc_rs)) print "포함 목록에 없는 R" n " 을 가리키는 AC 행"
      for (n in inc_rs) if (inc_rs[n] > 1)  print "포함 R" n " 항목 중복: " inc_rs[n] "개"
      for (n in acs)    if (acs[n] > 1)     print "AC" n " 행 중복: " acs[n] "개"
      if (scope)          print "범위 헤더 잔존 (경계는 제외 목록으로 일원화)"
      if (old)            print "옛 포함(In)·비포함(Out) 표기 잔존"
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
awk '!/^## 완료의 정의 \(Definition of Done\)$/' "$SPEC_TPL" > "$sandbox/s-no-dod.md"
awk '{print} END{print ""; print "## 완료의 정의 (Definition of Done)"}' "$SPEC_TPL" > "$sandbox/s-dup-dod.md"
awk '{print} END{print ""; print "## 범위 (Scope)"}' "$SPEC_TPL" > "$sandbox/s-scope-back.md"

# F-2 반례(2차 audit 재현·이웃 변형): 존재 검사만으로는 통과하는 변형들.
awk '{print} END{print ""; print "## 요구사항 (Requirements)"}' "$SPEC_TPL" > "$sandbox/s-dup-req.md"
awk '{print} /^### 포함$/{print ""; print "### 포함"}' "$SPEC_TPL" > "$sandbox/s-dup-incl.md"
awk '/^### 포함$/{next} {print} /^### 제외$/{print ""; print "### 포함"}' \
  "$SPEC_TPL" > "$sandbox/s-swap-order.md"
awk '!/^### 제외$/{print} END{print ""; print "### 제외"}' "$SPEC_TPL" > "$sandbox/s-excl-outside.md"
awk '{print} /^### 제외$/{print ""; print "**비포함 (Out)**"}' "$SPEC_TPL" > "$sandbox/s-old-coexist.md"
# PR #95 리뷰 반례: 소속·목록 항목까지 판정 — AC 행의 섹션 밖 이동, 목록 항목 삭제·형식 훼손.
awk '/^- \[ \] AC1: /{held = $0; next} {print} END{print ""; print held}' "$SPEC_TPL" > "$sandbox/s-ac-outside.md"
awk '!/^- R[0-9]+: /' "$SPEC_TPL" > "$sandbox/s-no-ritems.md"
awk '{gsub(/^- R1: /, "- "); print}' "$SPEC_TPL" > "$sandbox/s-bad-ritem.md"
awk '!/^- <검토했지만/' "$SPEC_TPL" > "$sandbox/s-no-excl-items.md"
# PR #95 2차 리뷰 반례: AC1 외 행의 소속 이탈 — 소속 검사가 AC1 패턴에만 걸리면 AC2 이동이 통과한다.
awk '/^- \[ \] AC2: /{held = $0; next} {print} END{print ""; print held}' "$SPEC_TPL" > "$sandbox/s-ac2-outside.md"
# PR #95 3차 리뷰 반례: 소속 접두사 매칭 우회 — 원 헤더는 비워 두고 블록을 유사 헤더 아래로
# 옮기면 `^## 요구사항`·`^## 완료의 정의` 접두사에 걸려 위반 0건으로 통과한다.
awk '/^### 포함$/{hold=1} /^## 완료의 정의/{hold=0} hold{buf = buf $0 "\n"; next} {print}
     END{print ""; print "## 요구사항 참고"; print ""; printf "%s", buf}' \
  "$SPEC_TPL" > "$sandbox/s-req-lookalike.md"
awk '/^## 완료의 정의 \(Definition of Done\)$/{print; hold=1; next} /^## 결정 사항/{hold=0} hold{buf = buf $0 "\n"; next} {print}
     END{print ""; print "## 완료의 정의 참고"; print ""; printf "%s", buf}' \
  "$SPEC_TPL" > "$sandbox/s-dod-lookalike.md"
# PR #95 3차 리뷰 반례: R2 에 연결된 AC 행 삭제 — AC 행 존재만 보면 포함 R2 의 연결 소실이 통과한다.
awk '!/^- \[ \] AC2: /' "$SPEC_TPL" > "$sandbox/s-no-r2link.md"
# PR #95 4차 리뷰 반례: 소속·연결만으로는 통과하는 변형 —
# 요구사항 블록 전체를 DoD 뒤로 이동 / 같은 번호의 AC 행·포함 항목 중복.
awk '/^## 요구사항 \(Requirements\)$/{hold=1} /^## 완료의 정의/{hold=0} hold{buf = buf $0 "\n"; next}
     /^## 결정 사항/ && buf{printf "%s", buf; buf=""} {print}' "$SPEC_TPL" > "$sandbox/s-req-after-dod.md"
awk '{print} /^- \[ \] AC2: /{print $0}' "$SPEC_TPL" > "$sandbox/s-dup-ac.md"
awk '{print} /^- R2: /{print $0}' "$SPEC_TPL" > "$sandbox/s-dup-ritem.md"
# PR #95 5차 리뷰 반례: 목표 헤더 삭제·중복 — 위치 판정은 헤더가 있을 때만 걸려 개수 없이는 통과한다.
awk '!/^## 목표 \(Goal\)$/' "$SPEC_TPL" > "$sandbox/s-no-goal.md"
awk '{print} END{print ""; print "## 목표 (Goal)"}' "$SPEC_TPL" > "$sandbox/s-dup-goal.md"
# issue #145: AC 행이 포함 목록에 없는 R 을 가리키는 dangling 참조.
awk '{sub(/\(R2\)$/, "(R9)"); print}' "$SPEC_TPL" > "$sandbox/s-ac-dangling.md"

assert_structure check_spec_structure "$SPEC_TPL"                  pass "spec 구조: 실제 템플릿 통과"
assert_structure check_spec_structure "$sandbox/s-no-req.md"       fail "spec 구조: 요구사항 헤더 소실 격추"
assert_structure check_spec_structure "$sandbox/s-no-incl.md"      fail "spec 구조: 포함 목록 소실 격추"
assert_structure check_spec_structure "$sandbox/s-no-excl.md"      fail "spec 구조: 제외 목록 소실 격추"
assert_structure check_spec_structure "$sandbox/s-no-dod.md"       fail "spec 구조: 완료의 정의 헤더 소실 격추"
assert_structure check_spec_structure "$sandbox/s-dup-dod.md"      fail "spec 구조: 완료의 정의 헤더 중복 격추"
assert_structure check_spec_structure "$sandbox/s-scope-back.md"   fail "spec 구조: 범위 섹션 재유입 격추"
assert_structure check_spec_structure "$sandbox/s-dup-req.md"      fail "spec 구조: 요구사항 헤더 중복(2차 audit F-2 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-dup-incl.md"     fail "spec 구조: 포함 표기 중복 격추"
assert_structure check_spec_structure "$sandbox/s-swap-order.md"   fail "spec 구조: 포함·제외 순서 역전 격추"
assert_structure check_spec_structure "$sandbox/s-excl-outside.md" fail "spec 구조: 제외 표기 섹션 밖 배치 격추"
assert_structure check_spec_structure "$sandbox/s-old-coexist.md"  fail "spec 구조: 옛 비포함(Out) 표기 공존 격추"
assert_structure check_spec_structure "$sandbox/s-ac-outside.md"     fail "spec 구조: AC 행 섹션 밖 이동(PR #95 리뷰 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-no-ritems.md"      fail "spec 구조: 포함 목록 R 항목 삭제 격추"
assert_structure check_spec_structure "$sandbox/s-bad-ritem.md"      fail "spec 구조: 포함 항목 R 번호 소실 격추"
assert_structure check_spec_structure "$sandbox/s-no-excl-items.md"  fail "spec 구조: 제외 목록 항목 삭제 격추"
assert_structure check_spec_structure "$sandbox/s-ac2-outside.md"    fail "spec 구조: AC2 행 섹션 밖 이동(PR #95 2차 리뷰 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-req-lookalike.md"  fail "spec 구조: 유사 헤더 아래 포함·제외 이동(PR #95 3차 리뷰 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-dod-lookalike.md"  fail "spec 구조: 유사 헤더 아래 AC 행 이동 격추"
assert_structure check_spec_structure "$sandbox/s-no-r2link.md"      fail "spec 구조: R2에 연결된 AC 행 삭제(포함 목록과 연결) 격추"
assert_structure check_spec_structure "$sandbox/s-req-after-dod.md"  fail "spec 구조: 요구사항 섹션 DoD 뒤 이동(PR #95 4차 리뷰 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-dup-ac.md"         fail "spec 구조: AC2 행 중복 격추"
assert_structure check_spec_structure "$sandbox/s-dup-ritem.md"      fail "spec 구조: 포함 R2 항목 중복 격추"
assert_structure check_spec_structure "$sandbox/s-no-goal.md"        fail "spec 구조: 목표 헤더 소실(PR #95 5차 리뷰 반례) 격추"
assert_structure check_spec_structure "$sandbox/s-dup-goal.md"       fail "spec 구조: 목표 헤더 중복 격추"
assert_structure check_spec_structure "$sandbox/s-ac-dangling.md"    fail "spec 구조: AC 행의 포함 목록에 없는 R 참조 격추"

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
# 완료의 정의는 결과만 적고 검증은 plan `테스트 계획`과 Task 의 테스트 코드가 맡는다는 구분은 조항 문장이 곧 계약이다.
# SKILL.md "완료 기준 형식" 절과 spec 템플릿 DoD 주석의 테스트 관점 행을 판정한다.
# 절 범위를 다음 헤더까지로 잘라, 같은 문구가 다른 절에 있어도 세지 않는다.
# 행 안의 조항마다 앵커 문구를 판정하고, 문구마다 삭제 반례를 격추한다 — 낱말 두 개만 보면 조건 문구를 지워도 통과한다 (PR #113 리뷰 반례).
# issue #145: 완료의 정의가 AC 행만 두므로 [D] 인수 테스트 조항 대신 검증 명령·케이스 목록을 적지 않고
# plan `## 테스트 계획`이 맡는다는 문장을 판정한다.

# check_test_view_skill <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_test_view_skill() {
  awk '/^### 완료 기준 형식$/ { s = 1; next } /^#/ { s = 0 }
       s && /^- \*\*테스트 관점\*\*: / {
         n++
         if (!index($0, "spec 완료의 정의는 관찰할 수 있는 결과만 적고"))
           print "테스트 관점 행에 완료의 정의가 결과만 적는다는 문구 없음"
         if (!index($0, "검증 명령과 케이스 목록을 적지 않습니다"))
           print "테스트 관점 행에 검증 명령·케이스 목록을 적지 않는다는 문구 없음"
         if (!index($0, "plan `## 테스트 계획`이 AC마다 층과 테스트, 검증 레벨, 강등 사유를 잇고"))
           print "테스트 관점 행에 plan 테스트 계획 담당 없음"
         if (!index($0, "그 기능을 만드는 plan Task의 테스트 코드가 맡습니다"))
           print "테스트 관점 행에 케이스의 plan Task 담당 없음"
       }
       END { if (n != 1) print "테스트 관점 행 " n + 0 "개 (기대 1개)" }' "$1"
}

# check_test_view_spec <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_test_view_spec() {
  awk '/^## 완료의 정의 \(Definition of Done\)$/ { s = 1; next } /^## / { s = 0 }
       s && /^- 테스트 관점: / {
         n++
         if (!index($0, "검증 명령과 케이스 목록은 여기에 적지 않는다"))
           print "spec 템플릿 테스트 관점 행에 검증 명령·케이스 목록을 적지 않는다는 문장 없음"
         if (!index($0, "plan `## 테스트 계획`에 적는다"))
           print "spec 템플릿 테스트 관점 행에 plan 테스트 계획 담당 없음"
       }
       END { if (n != 1) print "spec 템플릿 테스트 관점 행 " n + 0 "개 (기대 1개)" }' "$1"
}

# drop_literal <파일> <문자열> → 문자열을 정규식 해석 없이 지운 사본을 표준 출력으로
drop_literal() {
  awk -v s="$2" '{ while ((i = index($0, s))) $0 = substr($0, 1, i - 1) substr($0, i + length(s)); print }' "$1"
}

awk '!/^- \*\*테스트 관점\*\*: /' "$SKILL" > "$sandbox/tv-skill-del.md"
awk '!/^- 테스트 관점: /' "$SPEC_TPL" > "$sandbox/tv-spec-del.md"
drop_literal "$SKILL" 'spec 완료의 정의는 관찰할 수 있는 결과만 적고' > "$sandbox/tv-skill-no-result.md"
drop_literal "$SKILL" '검증 명령과 케이스 목록을 적지 않습니다' > "$sandbox/tv-skill-no-cmd.md"
drop_literal "$SKILL" 'plan `## 테스트 계획`이 AC마다 층과 테스트, 검증 레벨, 강등 사유를 잇고' > "$sandbox/tv-skill-no-plan.md"
drop_literal "$SKILL" '그 기능을 만드는 plan Task의 테스트 코드가 맡습니다' > "$sandbox/tv-skill-no-task.md"
drop_literal "$SPEC_TPL" '검증 명령과 케이스 목록은 여기에 적지 않는다' > "$sandbox/tv-spec-no-cmd.md"
drop_literal "$SPEC_TPL" 'plan `## 테스트 계획`에 적는다' > "$sandbox/tv-spec-no-plan.md"

assert_structure check_test_view_skill "$SKILL"                    pass "테스트 관점: SKILL.md 완료 기준 형식 행 통과"
assert_structure check_test_view_skill "$sandbox/tv-skill-del.md"  fail "테스트 관점: SKILL.md 완료 기준 형식 행 삭제 격추"
assert_structure check_test_view_skill "$sandbox/tv-skill-no-result.md" fail "테스트 관점: SKILL.md 결과만 적는다는 문구 삭제 격추"
assert_structure check_test_view_skill "$sandbox/tv-skill-no-cmd.md"    fail "테스트 관점: SKILL.md 검증 명령·케이스 목록 미기재 문구 삭제 격추"
assert_structure check_test_view_skill "$sandbox/tv-skill-no-plan.md"   fail "테스트 관점: SKILL.md plan 테스트 계획 담당 문구 삭제 격추"
assert_structure check_test_view_skill "$sandbox/tv-skill-no-task.md"   fail "테스트 관점: SKILL.md 케이스의 plan Task 담당 문구 삭제 격추"
assert_structure check_test_view_spec  "$SPEC_TPL"                 pass "테스트 관점: spec 템플릿 DoD 주석 행 통과"
assert_structure check_test_view_spec  "$sandbox/tv-spec-del.md"   fail "테스트 관점: spec 템플릿 DoD 주석 행 삭제 격추"
assert_structure check_test_view_spec  "$sandbox/tv-spec-no-cmd.md"       fail "테스트 관점: spec 템플릿 검증 명령·케이스 목록 미기재 문구 삭제 격추"
assert_structure check_test_view_spec  "$sandbox/tv-spec-no-plan.md"      fail "테스트 관점: spec 템플릿 plan 테스트 계획 담당 문구 삭제 격추"

# --- 테스트 배치 (issue #112, #145) ------------------------------------------------
#
# 구현 테스트를 그 기능을 만드는 Task 안에 두는 규칙은 plan 템플릿의 머리말 문단이 계약이다.
# issue #145: 일반 Task 가 테스트 작성·실패 확인 단계를 직접 가지므로 Task 1 의 테스트 [D] 예시와
# `작업 내용` 주석은 두지 않는다. Task 안의 단계는 아래 `테스트 먼저 Task` 케이스가 판정한다.

# check_placement_header <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# blockquote 문단이 여러 행에 걸치므로 `>` 빈 행 또는 `>` 아닌 행 전까지를 한 문단으로 모은다.
check_placement_header() {
  awk '/^## Tasks$/ { s = 1 } /^### Task 0/ { s = 0 }
       s && /^> \*\*테스트 배치\*\*/ { p = 1; n++ }
       p && (/^>[[:space:]]*$/ || !/^>/) { p = 0 }
       p { t = t $0 }
       END { if (n != 1) print "테스트 배치 규칙 " n + 0 "개 (기대 1개)"
             else { if (t !~ /그 기능을 만드는 Task 안에 둡니다/) print "테스트 배치 규칙에 Task 안 배치 문구 없음"
                    if (t !~ /테스트 자체가 작업 대상/) print "테스트 배치 규칙에 별도 테스트 Task 조건 문구 없음"
                    if (t !~ /전체 회귀는 Task N이 맡습니다/) print "테스트 배치 규칙에 전체 회귀 담당 문구 없음" } }' "$1"
}

awk '/^> \*\*테스트 배치\*\*/ { p = 1 } p && /^>[[:space:]]*$/ { p = 0 } !p' "$TEMPLATE" > "$sandbox/tp-header-del.md"
drop_literal "$TEMPLATE" '그 기능을 만드는 Task 안에 둡니다' > "$sandbox/tp-no-place.md"
drop_literal "$TEMPLATE" '테스트 자체가 작업 대상' > "$sandbox/tp-no-cond.md"
drop_literal "$TEMPLATE" '전체 회귀는 Task N이 맡습니다' > "$sandbox/tp-no-regress.md"

assert_structure check_placement_header  "$TEMPLATE"                    pass "테스트 배치: 머리말 문단 통과"
assert_structure check_placement_header  "$sandbox/tp-header-del.md"    fail "테스트 배치: 머리말 문단 삭제 격추"
assert_structure check_placement_header  "$sandbox/tp-no-place.md"      fail "테스트 배치: Task 안 배치 문구 삭제 격추"
assert_structure check_placement_header  "$sandbox/tp-no-cond.md"       fail "테스트 배치: 별도 테스트 Task 조건 문구 삭제 격추"
assert_structure check_placement_header  "$sandbox/tp-no-regress.md"    fail "테스트 배치: 전체 회귀 담당 문구 삭제 격추"

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

### Task N (고정): 마무리

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

### Task N (고정): 마무리

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
# plan 템플릿 `## 테스트 계획` 안내의 층 행이 local 파일을 참조하는지를 앵커로 판정하고, 앵커마다 지운 사본과 범위 밖으로 옮긴 사본을 격추한다.
# 조건·우선순위의 뜻은 판정하지 않는다 (이슈 spec 의 [QD] 몫).

# check_testing_skill <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_testing_skill() {
  awk '/^## 참조 문서/ { r = 1; next } r && /^## / { r = 0 }
       r && /^  - `\.ai\/10_rules\/testing-principles\.md`·`\.ai\/10_rules\/testing-principles-local\.md` — / { n++ }
       /^   - \*\*3-2\. 승인 후\*\*/ { s = 1 } s && /^4\. / { s = 0 }
       s && /^     - \*\*테스트 층 표\*\*: / && index($0, "testing-principles-local.md`가 있으면 plan `테스트 계획`의 `층` 칸은 그 파일의 테스트 층 표에서 고르고") { l++ }
       s && index($0, "기기 확인 Task는 두지 않는다") { d++ }
       END { if (n != 1) print "참조 문서의 테스트 원칙 항목 " n + 0 "개 (기대 1개)"
             if (l < 1) print "3-2 테스트 층 표 항목에 층 칸의 testing-principles-local.md 참조 없음"
             if (d < 1) print "3-2 범위에 기기 확인 Task 문장 없음" }' "$1"
}

# check_testing_plan <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# issue #145: 층과 러너를 고르는 자리가 spec 완료의 정의 [D]와 Task 완료 기준에서 `## 테스트 계획`의 층 칸으로 바뀌었다.
check_testing_plan() {
  awk '/^## / { s = ($0 == "## 테스트 계획") }
       s && /^- 층: / { n++; if (index($0, "`.ai/10_rules/testing-principles-local.md`가 있으면 그 파일의 테스트 층 표를 따른다")) l++ }
       END { if (n != 1) print "테스트 계획 안내의 층 행 " n + 0 "개 (기대 1개)"
             else if (l < 1) print "테스트 계획 안내의 층 행에 testing-principles-local.md 참조 없음" }' "$1"
}

awk '!index($0, "  - `.ai/10_rules/testing-principles.md`·`.ai/10_rules/testing-principles-local.md` — ")' \
  "$SKILL" > "$sandbox/tr-ref-del.md"
drop_literal "$SKILL" '`.ai/10_rules/testing-principles-local.md`가 있으면 plan `테스트 계획`의 `층` 칸' > "$sandbox/tr-32-no-local.md"
drop_literal "$SKILL" '기기 확인 Task는 두지 않는다' > "$sandbox/tr-32-no-device.md"
awk '/^     - \*\*테스트 층 표\*\*: / { held = $0; next } { print } /^4\. / && held { print held; held = "" }' \
  "$SKILL" > "$sandbox/tr-32-moved.md"
drop_literal "$TEMPLATE" '`.ai/10_rules/testing-principles-local.md`가 있으면 그 파일의 테스트 층 표를 따른다' > "$sandbox/tr-plan-del.md"
awk '/^- 층: / { held = $0; next } { print } /^## Tasks$/ && held { print ""; print held; held = "" }' \
  "$TEMPLATE" > "$sandbox/tr-plan-moved.md"

assert_structure check_testing_skill "$SKILL"                      pass "테스트 원칙 조항: SKILL.md 참조 항목·3-2 층 표 문장 통과"
assert_structure check_testing_plan  "$TEMPLATE"                   pass "테스트 원칙 조항: plan 템플릿 테스트 계획 층 안내 통과"
assert_structure check_testing_skill "$sandbox/tr-ref-del.md"      fail "테스트 원칙 조항: SKILL.md 참조 항목 삭제 격추"
assert_structure check_testing_skill "$sandbox/tr-32-no-local.md"  fail "테스트 원칙 조항: 3-2 local 층 표 참조 삭제 격추"
assert_structure check_testing_skill "$sandbox/tr-32-no-device.md" fail "테스트 원칙 조항: 3-2 기기 확인 Task 문장 삭제 격추"
assert_structure check_testing_skill "$sandbox/tr-32-moved.md"     fail "테스트 원칙 조항: 3-2 층 표 항목의 4단계 이동 격추"
assert_structure check_testing_plan  "$sandbox/tr-plan-del.md"     fail "테스트 원칙 조항: 테스트 계획 층 안내의 local 참조 삭제 격추"
assert_structure check_testing_plan  "$sandbox/tr-plan-moved.md"   fail "테스트 원칙 조항: 테스트 계획 층 안내의 Tasks 섹션 이동 격추"

# --- 이슈 본문 템플릿 (issue #130) ------------------------------------------------
#
# `--create` 초안, 3-1 근거 판정, issue-audit `--plan` 1단계가 같은 이슈 본문 구조를 읽는다.
# 본문 헤더 5개(issue #145에서 `## 정한 것`을 더함)와 접기 제목 3개를 열거해 그 외 0건까지 판정하고(HTML 주석 안 안내문은 빼고 센다),
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
      if (h != "## 목표|## 범위|## 완료의 정의|## 정한 것|## 검토 필요|") print "본문 헤더 구성 [" h "]"
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
  for p in '서로 독립으로 머지할 수 있는' '분할을 권고' '수치 기준은 두지 않' '결정은 사용자' 'AC가 대응하지 않는 포함 항목' \
           '완료의 정의의 묶음별 항목 수, 정한 것, 검토 필요' '포함과 같은 묶음 제목마다 AC 수'; do
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
drop_literal "$SKILL" '완료의 정의의 묶음별 항목 수, 정한 것, 검토 필요' > "$sandbox/cr-no-decided.md"
drop_literal "$SKILL" '포함과 같은 묶음 제목마다 AC 수' > "$sandbox/cr-no-ac-count.md"
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
assert_structure check_create_section "$sandbox/cr-no-decided.md"       fail "--create 절: 요약 제시의 묶음별 항목 수·정한 것 삭제 격추"
assert_structure check_create_section "$sandbox/cr-no-ac-count.md"      fail "--create 절: 묶음 제목별 AC 수 문구 삭제 격추"
assert_structure check_create_section "$sandbox/cr-ac-report-moved.md"  fail "--create 절: AC 미대응 포함 항목 보고의 승인 단계 이동 격추"
assert_structure check_create_section "$sandbox/cr-before-options.md"   fail "--create 절: 절의 옵션 섹션 앞 이동 격추"

# --- AC 정제 (issue #130) ---------------------------------------------------------
#
# 3-2가 이슈 본문의 AC를 번호와 문장 그대로 옮기고 `(R<n>)`으로 요구사항에 잇는다(issue #145에서 레벨 정제·출처 표기를 없앴다).
# SKILL.md는 3-2 범위(`3-2. 승인 후` 행부터 `4. ` 행 전까지)에 `AC 옮기기` 항목 1개와 그 항목 안의 조항 문구가 있는지 본다.
# 다른 단계나 다른 항목으로 옮긴 문장은 세지 않는다.
# spec 템플릿은 완료의 정의 AC 행이 `(R<n>)` 표기로 끝나고 옛 출처 표기(`(AC<n>)`·`(AC 없음: …)`)가 남지 않았는지(issue #145),
# plan 템플릿은 `## Tasks` 안내(Task 0 전까지)에 진행만 판정한다는 문장이 있는지 본다.

# check_ac_refine_skill <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_ac_refine_skill() {
  local r n p
  r="$(awk '/^   - \*\*3-2\. 승인 후\*\*/ { s = 1 } s && /^4\. / { exit } s' "$1")"
  [ -n "$r" ] || echo "3-2 범위 없음"
  n="$(printf '%s\n' "$r" | grep -c '^     - \*\*AC 옮기기\*\*: ')"
  [ "$n" -eq 1 ] || echo "3-2의 AC 옮기기 항목 ${n}개 (기대 1개)"
  r="$(printf '%s\n' "$r" | awk '/^     - \*\*AC 옮기기\*\*: / { s = 1; print; next } s && /^       / { print; next } { s = 0 }')"
  for p in '같은 묶음 제목·문장·번호로 옮기고' '`(R<n>)`이나 `(R<n>, R<m>)`으로 붙인다' '포함 R마다 AC가 1개 이상 연결' \
           '같은 AC 번호의 행은 하나' 'spec이 AC를 다음 번호로 직접 쓴다' '이슈 본문에 올릴지는 6단계가 묻는다' \
           'AC 번호는 뒤에만 추가하고 다시 매기지 않는다' '레벨 태그, 검증 명령, 케이스 목록을 적지 않는다'; do
    printf '%s\n' "$r" | grep -qF -- "$p" || echo "3-2 AC 옮기기에 [$p] 없음"
  done
}

# check_ac_refine_spec_tpl <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_ac_refine_spec_tpl() {
  awk '/^## 완료의 정의/ { s = 1; next } /^## / { s = 0 }
       /<!--/ { c = 1 }
       c { if (/-->/) c = 0; next }
       s && /^- \[ \] / {
         if ($0 ~ /^- \[ \] AC[0-9]+: .* \(R[0-9]+(, R[0-9]+)*\)$/) n++
         else print "R 표기로 끝나지 않는 완료의 정의 행 (행 " NR ")"
         if ($0 ~ /\(AC[0-9]+(, AC[0-9]+)*\)/ || index($0, "(AC 없음:")) print "옛 출처 표기가 남음 (행 " NR ")"
       }
       END { if (n < 1) print "R 표기가 붙은 AC 행 예시 없음" }' "$1"
}

# check_ac_refine_plan_tpl <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_ac_refine_plan_tpl() {
  local r p
  r="$(awk '/^## Tasks$/ { s = 1 } /^### Task 0/ { exit } s' "$1")"
  for p in '진행만 판정' 'spec에 없는 결과를 더하지 않는다'; do
    printf '%s\n' "$r" | grep -qF -- "$p" || echo "Tasks 안내에 [$p] 없음"
  done
}

# AC 옮기기 항목(하위 행 포함)을 3-2 범위 밖의 4단계 아래로 옮긴다.
awk '/^     - \*\*AC 옮기기\*\*: / { hold = 1; buf = $0 "\n"; next } hold && /^       / { buf = buf $0 "\n"; next }
     hold { hold = 0; held = 1 } { print } held && /^4\. / { printf "%s", buf; held = 0 }' "$SKILL" > "$sandbox/ar-moved-step4.md"
awk '{ print } /^     - \*\*AC 옮기기\*\*: / { print }' "$SKILL" > "$sandbox/ar-dup.md"
awk '/^## 완료의 정의/ { s = 1 } s && /^- \[ \] AC1: / { sub(/ \(R[0-9]+(, R[0-9]+)*\)$/, "") } { print }' \
  "$SPEC_TPL" > "$sandbox/ar-spec-no-rmark.md"
awk '/^- \[ \] AC1: / { sub(/ \(R1\)$/, " (AC1) (R1)") } { print }' "$SPEC_TPL" > "$sandbox/ar-spec-old-source.md"
awk '!index($0, "spec에 없는 결과를 더하지 않는다")' "$TEMPLATE" > "$sandbox/ar-plan-no-rule.md"

assert_structure check_ac_refine_skill    "$SKILL"                            pass "AC 정제: 실제 SKILL.md 3-2 AC 옮기기 통과"
for p in '같은 묶음 제목·문장·번호로 옮기고' '`(R<n>)`이나 `(R<n>, R<m>)`으로 붙인다' '포함 R마다 AC가 1개 이상 연결' \
         '같은 AC 번호의 행은 하나' 'spec이 AC를 다음 번호로 직접 쓴다' '이슈 본문에 올릴지는 6단계가 묻는다' \
         'AC 번호는 뒤에만 추가하고 다시 매기지 않는다' '레벨 태그, 검증 명령, 케이스 목록을 적지 않는다'; do
  drop_literal "$SKILL" "$p" > "$sandbox/ar-drop.md"
  assert_structure check_ac_refine_skill  "$sandbox/ar-drop.md"               fail "AC 정제: 3-2 AC 옮기기의 [${p}] 삭제 격추"
done
assert_structure check_ac_refine_skill    "$sandbox/ar-moved-step4.md"        fail "AC 정제: AC 옮기기 항목의 4단계 이동 격추"
assert_structure check_ac_refine_skill    "$sandbox/ar-dup.md"                fail "AC 정제: AC 옮기기 항목 중복 격추"
assert_structure check_ac_refine_spec_tpl "$SPEC_TPL"                         pass "AC 정제: 실제 spec 템플릿 AC 행 R 표기 통과"
assert_structure check_ac_refine_spec_tpl "$sandbox/ar-spec-no-rmark.md"      fail "AC 정제: spec 템플릿 AC 행 R 표기 삭제 격추"
assert_structure check_ac_refine_spec_tpl "$sandbox/ar-spec-old-source.md"    fail "AC 정제: spec 템플릿 옛 출처 표기 다시 넣기 격추"
assert_structure check_ac_refine_plan_tpl "$TEMPLATE"                         pass "AC 정제: 실제 plan 템플릿 Tasks 안내 통과"
assert_structure check_ac_refine_plan_tpl "$sandbox/ar-plan-no-rule.md"       fail "AC 정제: plan 템플릿 진행만 판정 문장 삭제 격추"

# --- 변경 통제 (issue #130) -------------------------------------------------------
#
# 3-2 작성과 작업 진행 중의 변경을 구체화·확장·완화로 나누고 확장·완화만 질의하는 규칙이 문장으로 지켜진다.
# SKILL.md는 `## 작업 진행 중` 범위의 `- **변경 통제**:` 항목 1개(다음 `- ` 항목 전까지)와 하위 3종 각 1개,
# 하위 행마다 정의·처리 문구, 3-2 범위(`3-2. 승인 후` 행부터 `4. ` 행 전까지)의 변경 통제 항목을 판정한다. 테스트 기대값 조항은 아래 `기대값 완화`가 본다.
# workflow 템플릿은 `active/issue-workflow.md`의 원본이라 `## 작업 진행 중`의 변경 통제 항목 1개와 세 분류·처리 문구를 본다.

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
  for p in '판정 기준만 명확히' '질의 없이 반영' 'AC 문장은 바꾸지 않고 `결정 사항`이나 `테스트 계획`에 적는다'; do
    printf '%s\n' "$l" | grep -qF -- "$p" || echo "구체화 항목에 [$p] 없음"
  done
  l="$(printf '%s\n' "$b" | grep -E '^  - \*\*확장\*\*: ')"
  for p in '범위 확장' '원장 등재' '새 이슈(`--create`)'; do
    printf '%s\n' "$l" | grep -qF -- "$p" || echo "확장 항목에 선택지 [$p] 없음"
  done
  l="$(printf '%s\n' "$b" | grep -E '^  - \*\*완화\*\*: ')"
  for p in 'AC를 빼거나 제외로 옮기는' '재승인 없이 반영하지 않는다' '확장과 같은 파일·명령·승인 규칙으로 이슈 본문도 고친다'; do
    printf '%s\n' "$l" | grep -qF -- "$p" || echo "완화 항목에 [$p] 없음"
  done
  printf '%s\n' "$b" | head -1 | grep -qF '분류 기준선은 이슈 본문의 AC다' || echo "변경 통제 첫 행에 분류 기준선 없음"
  awk '/^   - \*\*3-2\. 승인 후\*\*/ { s = 1 } s && /^4\. / { exit } s && /^     - \*\*변경 통제\*\*: / && index($0, "`## 작업 진행 중`의 변경 통제를 따른다") { n++ }
       END { if (n != 1) print "3-2의 변경 통제 항목 " n + 0 "개 (기대 1개)" }' "$1"
}

# check_change_control_workflow <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_change_control_workflow() {
  local l n p
  l="$(awk '/^## 작업 진행 중$/ { s = 1; next } s && /^## / { exit } s && /^- \*\*변경 통제\*\*: /' "$1")"
  n="$(printf '%s\n' "$l" | grep -c .)"
  [ "$n" -eq 1 ] || echo "작업 진행 중의 변경 통제 항목 ${n}개 (기대 1개)"
  for p in '구체화(' '확장(' '완화(' '질의 없이 반영' '범위 확장·원장 등재·새 이슈(`--create`)' '재승인 없이 반영하지 않는다' \
           '커밋한 테스트의 기대값을 바꾸거나 단언을 줄이거나 테스트를 지우는 변경도 완화다' 'spec `변경 이력`에 적는다'; do
    printf '%s\n' "$l" | grep -qF -- "$p" || echo "변경 통제 항목에 [$p] 없음"
  done
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
drop_literal "$SKILL" 'AC 문장은 바꾸지 않고 `결정 사항`이나 `테스트 계획`에 적는다' > "$sandbox/cc-no-refine-place.md"
drop_literal "$SKILL" '확장과 같은 파일·명령·승인 규칙으로 이슈 본문도 고친다' > "$sandbox/cc-no-relax-body.md"
drop_literal "$SKILL" '분류 기준선은 이슈 본문의 AC다' > "$sandbox/cc-no-base.md"
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
assert_structure check_change_control_skill    "$sandbox/cc-no-refine-place.md"  fail "변경 통제: 구체화를 적는 자리 문구 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-relax-body.md"    fail "변경 통제: 완화의 이슈 본문 갱신 문구 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-base.md"          fail "변경 통제: 분류 기준선 문구 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-no-3-2-ref.md"       fail "변경 통제: 3-2 항목 삭제 격추"
assert_structure check_change_control_skill    "$sandbox/cc-moved-out.md"        fail "변경 통제: 항목의 작업 진행 중 밖 이동 격추"
assert_structure check_change_control_workflow "$WORKFLOW_TPL"                   pass "변경 통제: 실제 workflow 템플릿 통과"
assert_structure check_change_control_workflow "$sandbox/cc-wf-no-item.md"       fail "변경 통제: workflow 템플릿 항목 삭제 격추"
for p in '구체화(' '확장(' '완화(' '질의 없이 반영' '범위 확장·원장 등재·새 이슈(`--create`)' '재승인 없이 반영하지 않는다' \
         '커밋한 테스트의 기대값을 바꾸거나' 'spec `변경 이력`에 적는다'; do
  drop_literal "$WORKFLOW_TPL" "$p" > "$sandbox/cc-wf-drop.md"
  assert_structure check_change_control_workflow "$sandbox/cc-wf-drop.md"        fail "변경 통제: workflow 템플릿 항목의 [$p] 삭제 격추"
done
awk '/^- \*\*변경 통제\*\*: / { buf = $0; next } { print } /^## 이슈 완료 시$/ { print ""; print buf }' "$WORKFLOW_TPL" > "$sandbox/cc-wf-moved.md"
assert_structure check_change_control_workflow "$sandbox/cc-wf-moved.md"         fail "변경 통제: workflow 템플릿 항목의 작업 진행 중 밖 이동 격추"

# --- 본문 갱신 질의 (issue #130) ---------------------------------------------------
#
# 이슈 본문에 없어 spec이 직접 쓴 AC가 있는 이슈가 계획 감사 뒤, Task 0 전에 이슈 본문 갱신 질의를 거친다.
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
  for p in '이슈 본문에 없어 spec이 직접 쓴 AC가 있는' '3-2 `AC 옮기기`의 AC 없는 R' 'Task 0 전에' '승인할 때만' "gh issue edit --repo '" \
           "--body-file '.ai/99_workspace/issue-<번호>-body.md'" '`- [ ] AC<n>: `' '행 끝의 `(R<n>)` 표기는 옮기지 않는다' \
           '초안을 쓰기 직전에' '실행 직전에' '기준 본문과 다르면 실행하지 않' '.ai/99_workspace/issue-<번호>-body-base.md' 'cmp -s' \
           '본문 편집이 성공했을 때만' '(exit "$rc")' '같은 번호와 문장' '변경 통제에 따라 spec을 먼저 맞춘다' \
           '`갱신 · <AC 번호>`' '`거절 · <AC 번호>`' 'spec의 AC가 기준이 된다'; do
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
           if (!index(l, "`갱신 · <AC 번호>`")) print "이슈 본문 갱신 줄에 값 [`갱신 · <AC 번호>`] 안내 없음"
           if (!index(l, "`거절 · <AC 번호>`")) print "이슈 본문 갱신 줄에 값 [`거절 · <AC 번호>`] 안내 없음"
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
for p in '이슈 본문에 없어 spec이 직접 쓴 AC가 있는' '3-2 `AC 옮기기`의 AC 없는 R' 'Task 0 전에' '승인할 때만' "gh issue edit --repo '" \
         "--body-file '.ai/99_workspace/issue-<번호>-body.md'" '`- [ ] AC<n>: `' '행 끝의 `(R<n>)` 표기는 옮기지 않는다' \
         '초안을 쓰기 직전에' '실행 직전에' '기준 본문과 다르면 실행하지 않' '.ai/99_workspace/issue-<번호>-body-base.md' 'cmp -s' \
         '본문 편집이 성공했을 때만' '(exit "$rc")' '같은 번호와 문장' '변경 통제에 따라 spec을 먼저 맞춘다' \
           '`갱신 · <AC 번호>`' '`거절 · <AC 번호>`' 'spec의 AC가 기준이 된다'; do
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
drop_literal "$SUMMARY_TPL" '`갱신 · <AC 번호>`' > "$sandbox/bu-sum-no-update.md"
drop_literal "$SUMMARY_TPL" '`거절 · <AC 번호>`' > "$sandbox/bu-sum-no-reject.md"
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
for p in '대상 판정 spec이 직접 쓴 AC' '대상 판정 3-2 참조' 'Task 0 전 시점' '승인할 때만 실행' 'gh issue edit 명령' \
         '갱신 본문 파일' 'AC 행 형식' 'R 표기 미이전' '초안 직전 조회' '실행 직전 재조회' \
         '불일치 시 미실행' '기준 본문 파일' 'cmp -s 비교' '편집 성공 시만 기록' '종료 코드 반환' 'spec과 같은 번호·문장' '본문 AC가 다를 때' \
         '갱신 기록 값' '거절 기록 값' '거절 뒤 기준'; do
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
# 요구사항이 5개 이상이면 포함은 내용별, 제외는 사유별로 묶는 규칙과, R을 하위 목록 없는 한 문장으로 쓰고
# 세부를 `## 결정 사항`에 적는 규칙(issue #145)이 spec 템플릿 요구사항 안내에서 사라지지 않았는지 판정한다.
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
  for p in 'R은 한 문장으로 쓰고 하위 목록을 두지 않는다' '문장 그대로 옮기고' '세부는 `## 결정 사항`에 적는다'; do
    group_need "$sec" '포함' "$p"
  done
  for p in '포함 항목이 5개 이상이면' '`#### <묶음 이름>`' '5개 미만이면 묶지 않는다' '기능 영역을 가리키는 명사구' \
           '다시 매기지 않' '다음 번호를 받아 맞는 묶음' '이슈 본문의 포함이 묶여 있으면' '묶음 이름을 이어 쓴다'; do
    group_need "$sec" '포함 묶음' "$p"
  done
  for p in '제외 항목이 5개 이상이면' '`#### 보류`, `#### 대체`, `#### 불필요` 순서' '5개 미만이면 묶지 않는다' '항목이 없는 사유는 생략'; do
    group_need "$sec" '제외 묶음' "$p"
  done
  group_need "$sec" '근거 표기' '줄 끝에'
  group_need "$sec" '함께 해소 표기' '첫 줄 끝에 `(함께 해소: K-<번호>)`'
  if printf '%s\n' "$sec" | group_row '근거 표기' | grep -qF '하위 목록'; then echo '[근거 표기] 행에 옛 위치(하위 목록)가 남음'; fi
  printf '%s\n' "$sec" | awk '/^### 포함$/ { i = 1; next } /^### / { i = 0 }
    i && /^[ \t]+[-*] / { n++ }
    END { if (n) print "포함 예시의 R 항목 아래에 하위 목록 줄 " n "개 (R은 하위 목록 없는 한 문장)" }'
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
for p in 'R은 한 문장으로 쓰고 하위 목록을 두지 않는다' '문장 그대로 옮기고' '세부는 `## 결정 사항`에 적는다'; do
  group_spec_drop_case '포함' "$p"
done
for p in '포함 항목이 5개 이상이면' '`#### <묶음 이름>`' '5개 미만이면 묶지 않는다' '기능 영역을 가리키는 명사구' \
         '다시 매기지 않' '다음 번호를 받아 맞는 묶음' '이슈 본문의 포함이 묶여 있으면' '묶음 이름을 이어 쓴다'; do
  group_spec_drop_case '포함 묶음' "$p"
done
for p in '제외 항목이 5개 이상이면' '`#### 보류`, `#### 대체`, `#### 불필요` 순서' '5개 미만이면 묶지 않는다' '항목이 없는 사유는 생략'; do
  group_spec_drop_case '제외 묶음' "$p"
done
group_spec_drop_case '근거 표기' '줄 끝에'
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
     q && /^- 근거 표기: / { $0 = $0 " 하위 목록에 적어도 된다." } { print }' "$SPEC_TPL" > "$sandbox/gs-basis-sublist.md"
awk '{ print } /^- R1: / { print "  - <세부 조건>" }' "$SPEC_TPL" > "$sandbox/gs-sublist-back.md"

assert_structure check_group_spec_tpl "$sandbox/gs-no-inc-row.md"     fail "요구사항 묶음: spec 템플릿 포함 묶음 행 삭제 격추"
assert_structure check_group_spec_tpl "$sandbox/gs-no-exc-row.md"     fail "요구사항 묶음: spec 템플릿 제외 묶음 행 삭제 격추"
assert_structure check_group_spec_tpl "$sandbox/gs-inc-row-in-dod.md" fail "요구사항 묶음: spec 템플릿 포함 묶음 행의 완료의 정의 주석 이동 격추"
assert_structure check_group_spec_tpl "$sandbox/gs-basis-sublist.md"  fail "요구사항 묶음: spec 템플릿 근거 표기 행에 하위 목록 다시 넣기 격추"
assert_structure check_group_spec_tpl "$sandbox/gs-sublist-back.md"   fail "요구사항 묶음: spec 템플릿 포함 예시 하위 목록 줄 다시 넣기 격추"

# 이슈 본문 템플릿의 범위 안내도 같은 5개 기준으로 묶고 포함 항목을 하위 목록 없는 한 문장으로 쓰도록 안내한다(issue #145).
# 범위 섹션(주석 행 포함)만 읽어, 규칙 문장을 다른 섹션으로 옮기면 세지 않는다.
# `5개 미만이면 묶지 않는다`는 포함·제외 두 곳에 있어 횟수로 판정한다.

# group_scope_section <파일> → 이슈 본문 범위 섹션 (헤더 행 다음부터 다음 `## ` 앞까지)
group_scope_section() { awk '/^## 범위$/ { s = 1; next } /^## / { s = 0 } s' "$1"; }

# check_group_body_tpl <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_group_body_tpl() {
  local sec p n
  sec="$(group_scope_section "$1")"
  for p in '포함 항목이 5개 이상이면' '`#### <묶음 이름>`' '제외 항목이 5개 이상이면' \
           '`#### 보류`, `#### 대체`, `#### 불필요` 순서' '항목이 없는 사유는 생략' '포함 항목은 하위 목록 없는 한 문장으로 쓴다'; do
    printf '%s\n' "$sec" | grep -qF -- "$p" || echo "범위 안내에 [$p] 없음"
  done
  n="$(printf '%s\n' "$sec" | grep -oF '5개 미만이면 묶지 않는다' | wc -l | tr -d ' ')"
  [ "$n" -eq 2 ] || echo "범위 안내의 [5개 미만이면 묶지 않는다] ${n}회 (기대 2회: 포함·제외)"
  for p in '관련 항목은 하위 목록으로 묶어도 된다' '세부 조건은 하위 목록에 둔다'; do
    if printf '%s\n' "$sec" | grep -qF -- "$p"; then echo "범위 안내에 옛 문장($p)이 남음"; fi
  done
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
         '`#### 보류`, `#### 대체`, `#### 불필요` 순서' '항목이 없는 사유는 생략' '포함 항목은 하위 목록 없는 한 문장으로 쓴다'; do
  GB_N=$((GB_N + 1))
  group_scope_drop "$BODY_TPL" "$p" > "$sandbox/gb-drop-$GB_N.md"
  assert_structure check_group_body_tpl "$sandbox/gb-drop-$GB_N.md" fail "요구사항 묶음: 이슈 본문 템플릿 [$p] 삭제 격추"
done

group_scope_drop "$BODY_TPL" '5개 미만이면 묶지 않는다' 1 > "$sandbox/gb-under5-once.md"
awk '/^## / { q = ($0 == "## 범위") }
     q && /^- 포함: / { $0 = $0 " 관련 항목은 하위 목록으로 묶어도 된다." } { print }' "$BODY_TPL" > "$sandbox/gb-old-sentence.md"
awk '/^## / { q = ($0 == "## 범위") }
     q && /^- 포함: / { $0 = $0 " 항목의 세부 조건은 하위 목록에 둔다." } { print }' "$BODY_TPL" > "$sandbox/gb-old-sublist.md"
GB_RULE="$(grep -F '포함 항목이 5개 이상이면' "$BODY_TPL")" \
  awk 'index($0, "포함 항목이 5개 이상이면") { next }
       /^## / { d = ($0 == "## 완료의 정의") }
       { print }
       d && /^<!--$/ { print ENVIRON["GB_RULE"]; d = 0 }' "$BODY_TPL" > "$sandbox/gb-inc-rule-in-dod.md"

assert_structure check_group_body_tpl "$sandbox/gb-under5-once.md"     fail "요구사항 묶음: 이슈 본문 템플릿 5개 미만 규칙 한 곳만 삭제 격추"
assert_structure check_group_body_tpl "$sandbox/gb-old-sentence.md"    fail "요구사항 묶음: 이슈 본문 템플릿 옛 하위 목록 문장 다시 넣기 격추"
assert_structure check_group_body_tpl "$sandbox/gb-old-sublist.md"     fail "요구사항 묶음: 이슈 본문 템플릿 세부 조건 하위 목록 문장 다시 넣기 격추"
assert_structure check_group_body_tpl "$sandbox/gb-inc-rule-in-dod.md" fail "요구사항 묶음: 이슈 본문 템플릿 포함 묶음 규칙의 완료의 정의 주석 이동 격추"

# SKILL.md 3-1 승인 요청과 `--create` 요약 제시는 목록을 묶음대로 나눠 보여 주고 항목은 한 문장 그대로 보여 준다.
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
  for p in 'spec의 묶음대로 나눠 보여 주고' 'R은 한 문장 그대로 보여 준다' \
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
  for p in '초안의 묶음대로 나눠 보여 주고' '항목은 한 문장 그대로 보여 준다'; do
    printf '%s\n' "$st" | grep -qF -- "$p" || echo "요약 제시 단계에 [$p] 없음"
  done
}

assert_structure check_group_skill_31     "$SKILL" pass "요구사항 묶음: SKILL.md 3-1 실제 SKILL.md 통과"
assert_structure check_group_skill_create "$SKILL" pass "요구사항 묶음: SKILL.md --create 실제 SKILL.md 통과"
GK_N=0
for p in 'spec의 묶음대로 나눠 보여 주고' 'R은 한 문장 그대로 보여 준다' \
         '이슈 본문에 근거가 없는' '목록에서 따로 표시하고, 추가로 확정할지 제외할지 질의한다'; do
  GK_N=$((GK_N + 1))
  drop_literal "$SKILL" "$p" > "$sandbox/gk-31-drop-$GK_N.md"
  assert_structure check_group_skill_31 "$sandbox/gk-31-drop-$GK_N.md" fail "요구사항 묶음: SKILL.md 3-1 [$p] 삭제 격추"
done
for p in '초안의 묶음대로 나눠 보여 주고' '항목은 한 문장 그대로 보여 준다'; do
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

# --- 한 문장 요구사항과 AC 행 (issue #145) ----------------------------------------
#
# 이슈 본문은 포함과 완료의 정의를 같은 묶음 제목으로 나누고 포함 항목을 하위 목록 없는 한 문장으로 쓰며,
# 등록 때 정한 세부는 `## 정한 것`에 둔다. spec 은 완료의 정의를 묶음 제목 아래 `- [ ] AC<n>: … (R<n>)` 행으로 두고
# 레벨 태그·검증 명령·케이스 목록을 담지 않으며, `## 결정 사항`·`## 변경 이력`을 두고 `## 전제`를 두지 않는다.
# 규칙 문장은 주석 안 안내라 주석 행도 섹션 범위로 세고, 구조(제목·행·표)는 주석 밖에서만 센다.
# 다른 섹션으로 옮긴 규칙 문장과 구조는 세지 않는다.

# check_body_groups <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_body_groups() {
  awk '
    /^## / { sec = substr($0, 4); part = ""; grp = 0
             if (sec == "완료의 정의") dod_at = NR
             if (sec == "정한 것") { dec++; dec_at = NR }
             if (sec == "검토 필요") rev_at = NR }
    sec == "범위" && index($0, "포함 항목은 하위 목록 없는 한 문장으로 쓴다") { one++ }
    sec == "완료의 정의" && index($0, "포함과 같은 묶음 이름의 `### <묶음 이름>` 제목으로 나누고") { grule++ }
    sec == "완료의 정의" && index($0, "포함을 묶지 않았으면 제목 없이 둔다") { nrule++ }
    sec == "정한 것" && index($0, "`- 정한 것: (<묶음>) <내용>`") { drule++ }
    /<!--/ { c = 1 }
    c { if (/-->/) c = 0; next }
    sec == "범위" && /^### 포함$/ { part = "inc"; next }
    sec == "범위" && /^### /      { part = "" }
    part == "inc" && /^#### /     { ig = ig substr($0, 6) "|" }
    part == "inc" && /^- /        { items++ }
    part == "inc" && /^[ \t]+[-*] / { subl++ }
    sec == "완료의 정의" && /^### / { dg = dg substr($0, 5) "|"; grp = 1 }
    sec == "완료의 정의" && /^- \[ \] AC[0-9]+: / { if (!grp) loose++ }
    sec == "정한 것" && /^- 정한 것: \(/ { drow++ }
    END {
      if (one != 1)   print "범위 안내의 한 문장 규칙 " one + 0 "개 (기대 1개)"
      if (grule != 1) print "완료의 정의 안내의 묶음 제목 규칙 " grule + 0 "개 (기대 1개)"
      if (nrule != 1) print "완료의 정의 안내의 묶지 않는 이슈 규칙 " nrule + 0 "개 (기대 1개)"
      if (items < 1)  print "포함 예시 항목 없음"
      if (subl)       print "포함 항목 아래 하위 목록 " subl "줄"
      if (ig == "")   print "포함 예시에 묶음 제목 없음"
      if (ig != dg)   print "포함 묶음 [" ig "]과 완료의 정의 묶음 [" dg "]이 다름"
      if (loose)      print "묶음 제목 밖의 AC 행 " loose "개"
      if (dec != 1)   print "정한 것 헤더 " dec + 0 "개 (기대 1개)"
      else if (!(dod_at && dod_at < dec_at && dec_at < rev_at)) print "정한 것 섹션이 완료의 정의와 검토 필요 사이가 아님"
      if (drule != 1) print "정한 것 안내의 행 형식 " drule + 0 "개 (기대 1개)"
      if (drow < 1)   print "정한 것 예시 행 없음"
    }' "$1"
}

awk '/^## / { d = ($0 == "## 완료의 정의") } d && /^### <묶음 이름>$/ { $0 = "### <다른 묶음>" } { print }' \
  "$BODY_TPL" > "$sandbox/bg-dod-renamed.md"
awk '/^## / { d = ($0 == "## 완료의 정의") } d && /^### <묶음 이름>$/ { next } { print }' "$BODY_TPL" > "$sandbox/bg-dod-nogroup.md"
awk '!/^#### <묶음 이름>$/' "$BODY_TPL" > "$sandbox/bg-inc-nogroup.md"
awk '{ print } /^- <이 이슈로 가능해져야 하는 것 한 문장>$/ { print "  - <세부 조건>" }' "$BODY_TPL" > "$sandbox/bg-sublist.md"
drop_literal "$BODY_TPL" '포함 항목은 하위 목록 없는 한 문장으로 쓴다' > "$sandbox/bg-no-one.md"
drop_literal "$BODY_TPL" '포함과 같은 묶음 이름의 `### <묶음 이름>` 제목으로 나누고' > "$sandbox/bg-no-grule.md"
drop_literal "$BODY_TPL" '포함을 묶지 않았으면 제목 없이 둔다' > "$sandbox/bg-no-nrule.md"
awk '!/^## 정한 것$/' "$BODY_TPL" > "$sandbox/bg-no-decided.md"
awk '!/^- 정한 것: \(/' "$BODY_TPL" > "$sandbox/bg-no-drow.md"
# 정한 것 섹션을 검토 필요 뒤(첫 접기 앞)로 옮긴다.
awk '/^## 정한 것$/ { hold = 1 } /^## 검토 필요$/ { hold = 0 } hold { buf = buf $0 "\n"; next }
     /^<details>$/ && buf { printf "%s", buf; buf = "" } { print }' "$BODY_TPL" > "$sandbox/bg-decided-late.md"

assert_structure check_body_groups "$BODY_TPL"                    pass "본문 묶음 대응: 실제 이슈 본문 템플릿 통과"
assert_structure check_body_groups "$sandbox/bg-dod-renamed.md"   fail "본문 묶음 대응: 완료의 정의 묶음 제목 이름 바꿈 격추"
assert_structure check_body_groups "$sandbox/bg-dod-nogroup.md"   fail "본문 묶음 대응: 완료의 정의 묶음 제목 삭제 격추"
assert_structure check_body_groups "$sandbox/bg-inc-nogroup.md"   fail "본문 묶음 대응: 포함 묶음 제목 삭제 격추"
assert_structure check_body_groups "$sandbox/bg-sublist.md"       fail "본문 묶음 대응: 포함 항목 아래 하위 목록 추가 격추"
assert_structure check_body_groups "$sandbox/bg-no-one.md"        fail "본문 묶음 대응: 한 문장 규칙 문구 삭제 격추"
assert_structure check_body_groups "$sandbox/bg-no-grule.md"      fail "본문 묶음 대응: 묶음 제목 규칙 문구 삭제 격추"
assert_structure check_body_groups "$sandbox/bg-no-nrule.md"      fail "본문 묶음 대응: 묶지 않는 이슈 규칙 문구 삭제 격추"
assert_structure check_body_groups "$sandbox/bg-no-decided.md"    fail "본문 묶음 대응: 정한 것 섹션 헤더 삭제 격추"
assert_structure check_body_groups "$sandbox/bg-no-drow.md"       fail "본문 묶음 대응: 정한 것 예시 행 삭제 격추"
assert_structure check_body_groups "$sandbox/bg-decided-late.md"  fail "본문 묶음 대응: 정한 것 섹션의 검토 필요 뒤 이동 격추"

# check_spec_ac_rows <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 완료의 정의 섹션은 주석까지 읽어 레벨 태그를 센다 — 주석의 안내에 태그가 남으면 그 모양대로 쓰게 된다.
check_spec_ac_rows() {
  awk '
    /^## / { sec = $0; part = ""; grp = 0 }
    sec == "## 완료의 정의 (Definition of Done)" && /\[(D|QD|ND)\]/ { tag++ }
    /<!--/ { c = 1 }
    c { if (/-->/) c = 0; next }
    sec == "## 요구사항 (Requirements)" && /^### 포함$/ { part = "inc"; next }
    sec == "## 요구사항 (Requirements)" && /^### /      { part = "" }
    part == "inc" && /^#### /       { ig = ig substr($0, 6) "|" }
    part == "inc" && /^- R[0-9]+: / { rs++ }
    part == "inc" && /^[ \t]+[-*] / { subl++ }
    sec == "## 완료의 정의 (Definition of Done)" {
      if (/^### /) { t = substr($0, 5); dg = dg t "|"; grp = 1; if (t ~ /^R[0-9]+: / || t == "공통") oldg++ }
      else if (/^- \[ \] /) {
        rows++
        if ($0 !~ /^- \[ \] AC[0-9]+: .* \(R[0-9]+(, R[0-9]+)*\)$/) bad++
        if (!grp) loose++
      }
      else if (/^[ \t]*```/)          fence++
      else if (/<details>|<summary>/) fold++
      else if (/^>/)                  quote++
      else if (/^[ \t]*[-*] /)        other++
    }
    END {
      if (rs < 1)   print "포함 예시에 R 항목 없음"
      if (subl)     print "요구사항 R 항목 아래 하위 목록 " subl "줄 (R은 하위 목록 없는 한 문장)"
      if (rows < 1) print "완료의 정의에 AC 행 없음"
      if (bad)      print "`- [ ] AC<n>: … (R<n>)` 형식이 아닌 완료의 정의 행 " bad "개"
      if (tag)      print "완료의 정의 섹션에 레벨 태그 " tag "행"
      if (fence)    print "완료의 정의 섹션에 코드 블록 " fence "행 (검증 명령은 적지 않는다)"
      if (fold)     print "완료의 정의 섹션에 접기 " fold "행"
      if (quote)    print "완료의 정의 섹션에 인용 블록 " quote "행 (검증 레벨 안내는 두지 않는다)"
      if (other)    print "완료의 정의 섹션에 AC 행이 아닌 목록 " other "행 (케이스 목록은 적지 않는다)"
      if (oldg)     print "완료의 정의에 옛 그룹 제목(R<n>·공통) " oldg "개"
      if (ig == "") print "포함 예시에 묶음 제목 없음"
      if (ig != dg) print "포함 묶음 [" ig "]과 완료의 정의 묶음 [" dg "]이 다름"
      if (loose)    print "묶음 제목 밖의 AC 행 " loose "개"
    }' "$1"
}

awk '{ sub(/^- \[ \] AC1: /, "- [ ] [D]  AC1: "); print }' "$SPEC_TPL" > "$sandbox/sa-level-tag.md"
awk '/^- \[ \] AC1: / { sub(/ \(R1\)$/, "") } { print }' "$SPEC_TPL" > "$sandbox/sa-no-rmark.md"
awk '{ print } /^- \[ \] AC1: / { print "  <details>"; print "  <summary>검증 명령 — 출력 0건이면 통과</summary>"; print ""
       print "  ```bash"; print "  true"; print "  ```"; print ""; print "  </details>" }' "$SPEC_TPL" > "$sandbox/sa-command-fold.md"
awk '{ print } /^- \[ \] AC1: / { print "  - 케이스: <입력> → <기대 출력>" }' "$SPEC_TPL" > "$sandbox/sa-case-list.md"
awk '/^## / { d = ($0 == "## 완료의 정의 (Definition of Done)") } d && /^### <묶음 이름>$/ { $0 = "### R1: <짧은 이름>" } { print }' \
  "$SPEC_TPL" > "$sandbox/sa-rgroup.md"
awk '/^## / { d = ($0 == "## 완료의 정의 (Definition of Done)") } d && /^### <묶음 이름>$/ { next } { print }' \
  "$SPEC_TPL" > "$sandbox/sa-no-group.md"
awk '{ print } /^- R1: / { print "  - <세부 조건>" }' "$SPEC_TPL" > "$sandbox/sa-sublist.md"
awk '{ print } /^## 완료의 정의 \(Definition of Done\)$/ { print ""; print "> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움)." }' \
  "$SPEC_TPL" > "$sandbox/sa-level-quote.md"
awk '/^## / { d = ($0 == "## 완료의 정의 (Definition of Done)") }
     d && index($0, "- 테스트 관점: ") == 1 { $0 = $0 " 예: `[D]` 항목은 명령으로 판정한다." } { print }' \
  "$SPEC_TPL" > "$sandbox/sa-tag-in-comment.md"

assert_structure check_spec_ac_rows "$SPEC_TPL"                     pass "spec AC 행: 실제 spec 템플릿 통과"
assert_structure check_spec_ac_rows "$sandbox/sa-level-tag.md"      fail "spec AC 행: AC 행의 레벨 태그 다시 넣기 격추"
assert_structure check_spec_ac_rows "$sandbox/sa-no-rmark.md"       fail "spec AC 행: AC 행 끝의 R 표기 삭제 격추"
assert_structure check_spec_ac_rows "$sandbox/sa-command-fold.md"   fail "spec AC 행: 검증 명령 접기 다시 넣기 격추"
assert_structure check_spec_ac_rows "$sandbox/sa-case-list.md"      fail "spec AC 행: AC 행 아래 케이스 목록 추가 격추"
assert_structure check_spec_ac_rows "$sandbox/sa-rgroup.md"         fail "spec AC 행: 옛 R 그룹 제목 다시 넣기 격추"
assert_structure check_spec_ac_rows "$sandbox/sa-no-group.md"       fail "spec AC 행: 완료의 정의 묶음 제목 삭제 격추"
assert_structure check_spec_ac_rows "$sandbox/sa-sublist.md"        fail "spec AC 행: 요구사항 R 아래 하위 목록 추가 격추"
assert_structure check_spec_ac_rows "$sandbox/sa-level-quote.md"    fail "spec AC 행: 검증 레벨 인용 블록 다시 넣기 격추"
assert_structure check_spec_ac_rows "$sandbox/sa-tag-in-comment.md" fail "spec AC 행: 완료의 정의 주석의 레벨 태그 격추"

# check_spec_decisions <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_spec_decisions() {
  awk '
    /^## / { sec = $0 }
    /^## 전제/ { pre++ }
    /^## 완료의 정의 \(Definition of Done\)$/ { dod_at = NR }
    /^## 결정 사항 \(Decisions\)$/ { dec++; dec_at = NR }
    /^## 변경 이력$/ { his_at = NR }
    /^## 연관 문서$/ { rel_at = NR }
    sec == "## 결정 사항 (Decisions)" {
      if (index($0, "- 적을 것: 경계 규칙·계산식·합의한 값·버린 대안")) keep++
      if (index($0, "- 적지 않을 것: 구현 방법")) drop++
      if (index($0, "plan `## 설계 결정`에 적는다")) plan++
      if (index($0, "`- D<n> <이름>: <내용>`")) fmt++
      if (index($0, "적을 결정이 없으면 이 섹션을 두지 않는다")) none++
    }
    /<!--/ { c = 1 }
    c { if (/-->/) c = 0; next }
    sec == "## 결정 사항 (Decisions)" && /^- D[0-9]+ [^:]+: / { rows++ }
    sec == "## 결정 사항 (Decisions)" && index($0, "<summary>버린 대안과 이유</summary>") { fold++ }
    END {
      if (pre) print "전제 섹션 헤더 " pre "개 (결정 사항·설계 결정으로 옮겼다)"
      if (dec != 1) print "결정 사항 헤더 " dec + 0 "개 (기대 1개)"
      else {
        if (!(dod_at && dod_at < dec_at)) print "결정 사항 섹션이 완료의 정의 뒤가 아님"
        if (his_at && his_at < dec_at)    print "결정 사항 섹션이 변경 이력 뒤"
        if (!(rel_at && dec_at < rel_at)) print "결정 사항 섹션이 연관 문서 앞이 아님"
      }
      if (keep != 1) print "결정 사항 안내의 적을 것(경계 규칙·계산식·합의한 값·버린 대안) " keep + 0 "개 (기대 1개)"
      if (drop != 1) print "결정 사항 안내의 적지 않을 것(구현 방법) " drop + 0 "개 (기대 1개)"
      if (plan != 1) print "결정 사항 안내의 plan 설계 결정 담당 " plan + 0 "개 (기대 1개)"
      if (fmt != 1)  print "결정 사항 안내의 행 형식 " fmt + 0 "개 (기대 1개)"
      if (none != 1) print "결정 사항 안내의 섹션을 두지 않는 기준 " none + 0 "개 (기대 1개)"
      if (rows < 1)  print "결정 행(`- D<n> <이름>: `) 예시 없음"
      if (fold != 1) print "버린 대안 접기 " fold + 0 "개 (기대 1개)"
    }' "$1"
}

awk '!/^## 결정 사항 \(Decisions\)$/' "$SPEC_TPL" > "$sandbox/sd-no-section.md"
awk '{ print } END { print ""; print "## 전제 (Assumptions)" }' "$SPEC_TPL" > "$sandbox/sd-assumption-back.md"
awk '!/^- D[0-9]+ /' "$SPEC_TPL" > "$sandbox/sd-no-drow.md"
drop_literal "$SPEC_TPL" '- 적을 것: 경계 규칙·계산식·합의한 값·버린 대안' > "$sandbox/sd-no-keep.md"
drop_literal "$SPEC_TPL" '- 적지 않을 것: 구현 방법' > "$sandbox/sd-no-drop.md"
drop_literal "$SPEC_TPL" 'plan `## 설계 결정`에 적는다' > "$sandbox/sd-no-plan.md"
drop_literal "$SPEC_TPL" '적을 결정이 없으면 이 섹션을 두지 않는다' > "$sandbox/sd-no-none.md"
drop_literal "$SPEC_TPL" '<summary>버린 대안과 이유</summary>' > "$sandbox/sd-no-fold.md"
# 결정 사항 섹션(다음 헤더 앞까지)을 완료의 정의 앞으로 옮긴다.
awk '{ l[NR] = $0 }
     /^## 완료의 정의 \(Definition of Done\)$/ { d = NR } /^## 결정 사항 \(Decisions\)$/ { a = NR } /^## 변경 이력$/ { b = NR }
     END { for (i = 1; i < d; i++) print l[i]; for (i = a; i < b; i++) print l[i]
           for (i = d; i < a; i++) print l[i]; for (i = b; i <= NR; i++) print l[i] }' "$SPEC_TPL" > "$sandbox/sd-before-dod.md"

assert_structure check_spec_decisions "$SPEC_TPL"                      pass "결정 사항 섹션: 실제 spec 템플릿 통과"
assert_structure check_spec_decisions "$sandbox/sd-no-section.md"      fail "결정 사항 섹션: 섹션 헤더 삭제 격추"
assert_structure check_spec_decisions "$sandbox/sd-assumption-back.md" fail "결정 사항 섹션: 전제 섹션 다시 넣기 격추"
assert_structure check_spec_decisions "$sandbox/sd-no-drow.md"         fail "결정 사항 섹션: 결정 행 예시 삭제 격추"
assert_structure check_spec_decisions "$sandbox/sd-no-keep.md"         fail "결정 사항 섹션: 적을 것 문구 삭제 격추"
assert_structure check_spec_decisions "$sandbox/sd-no-drop.md"         fail "결정 사항 섹션: 적지 않을 것 문구 삭제 격추"
assert_structure check_spec_decisions "$sandbox/sd-no-plan.md"         fail "결정 사항 섹션: plan 설계 결정 담당 문구 삭제 격추"
assert_structure check_spec_decisions "$sandbox/sd-no-none.md"         fail "결정 사항 섹션: 섹션을 두지 않는 기준 문구 삭제 격추"
assert_structure check_spec_decisions "$sandbox/sd-no-fold.md"         fail "결정 사항 섹션: 버린 대안 접기 제목 삭제 격추"
assert_structure check_spec_decisions "$sandbox/sd-before-dod.md"      fail "결정 사항 섹션: 섹션의 완료의 정의 앞 이동 격추"

# check_spec_history <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 표는 섹션 안 주석 밖의 `|` 행으로 센다 — 첫 행이 머리, 둘째 행이 4칸 구분선, 셋째 행부터 예시 행이다.
check_spec_history() {
  awk '
    /^## / { sec = $0 }
    /^## 결정 사항 \(Decisions\)$/ { dec_at = NR }
    /^## 변경 이력$/ { his++; his_at = NR }
    /^## 연관 문서$/ { rel_at = NR }
    sec == "## 변경 이력" {
      if (index($0, "문장이 바뀐 회차만 적는다")) only++
      if (index($0, "- 적을 것: 바뀐 번호(R·AC·D), 변경 통제의 분류(구체화·확장·완화)")) keep++
      if (index($0, "- 적지 않을 것: spec 문장이 바뀌지 않은 회차")) drop++
      if (index($0, "적을 회차가 없으면 이 섹션을 두지 않는다")) none++
    }
    /<!--/ { c = 1 }
    c { if (/-->/) c = 0; next }
    sec == "## 변경 이력" && /^\|/ {
      tl++
      if (tl == 1 && $0 != "| 시점 | 바뀐 것 | 분류 | 계기 |") print "표 머리가 [| 시점 | 바뀐 것 | 분류 | 계기 |]가 아님: " $0
      if (tl == 2 && $0 !~ /^\|[ :-]+\|[ :-]+\|[ :-]+\|[ :-]+\|$/) print "표 구분선이 4칸이 아님: " $0
    }
    END {
      if (his != 1) print "변경 이력 헤더 " his + 0 "개 (기대 1개)"
      else {
        if (!(dec_at && dec_at < his_at)) print "변경 이력 섹션이 결정 사항 뒤가 아님"
        if (!(rel_at && his_at < rel_at)) print "변경 이력 섹션이 연관 문서 앞이 아님"
      }
      if (tl < 3)    print "변경 이력 표에 머리·구분선·예시 행이 없음 (" tl + 0 "행)"
      if (only != 1) print "변경 이력 안내의 적는 회차 기준 " only + 0 "개 (기대 1개)"
      if (keep != 1) print "변경 이력 안내의 적을 것 " keep + 0 "개 (기대 1개)"
      if (drop != 1) print "변경 이력 안내의 적지 않을 것 " drop + 0 "개 (기대 1개)"
      if (none != 1) print "변경 이력 안내의 섹션을 두지 않는 기준 " none + 0 "개 (기대 1개)"
    }' "$1"
}

awk '!/^## 변경 이력$/' "$SPEC_TPL" > "$sandbox/sh-no-section.md"
awk '$0 == "| 시점 | 바뀐 것 | 분류 | 계기 |" { $0 = "| 시점 | 바뀐 것 | 분류 | 사유 |" } { print }' "$SPEC_TPL" > "$sandbox/sh-head-renamed.md"
awk '$0 == "| 시점 | 바뀐 것 | 분류 | 계기 |" { $0 = "| 시점 | 바뀐 것 | 계기 |" } { print }' "$SPEC_TPL" > "$sandbox/sh-head-dropcol.md"
awk '!/^\| <회차나 날짜> /' "$SPEC_TPL" > "$sandbox/sh-no-row.md"
drop_literal "$SPEC_TPL" '문장이 바뀐 회차만 적는다' > "$sandbox/sh-no-only.md"
drop_literal "$SPEC_TPL" '- 적을 것: 바뀐 번호(R·AC·D), 변경 통제의 분류(구체화·확장·완화)' > "$sandbox/sh-no-keep.md"
drop_literal "$SPEC_TPL" '- 적지 않을 것: spec 문장이 바뀌지 않은 회차' > "$sandbox/sh-no-drop.md"
drop_literal "$SPEC_TPL" '적을 회차가 없으면 이 섹션을 두지 않는다' > "$sandbox/sh-no-none.md"
awk '/^## 변경 이력$/ { next } { print } END { print ""; print "## 변경 이력" }' "$SPEC_TPL" > "$sandbox/sh-after-rel.md"

assert_structure check_spec_history "$SPEC_TPL"                    pass "변경 이력 섹션: 실제 spec 템플릿 통과"
assert_structure check_spec_history "$sandbox/sh-no-section.md"    fail "변경 이력 섹션: 섹션 헤더 삭제 격추"
assert_structure check_spec_history "$sandbox/sh-head-renamed.md"  fail "변경 이력 섹션: 표 머리 칸 이름 바꿈 격추"
assert_structure check_spec_history "$sandbox/sh-head-dropcol.md"  fail "변경 이력 섹션: 표 머리 분류 칸 삭제 격추"
assert_structure check_spec_history "$sandbox/sh-no-row.md"        fail "변경 이력 섹션: 표 예시 행 삭제 격추"
assert_structure check_spec_history "$sandbox/sh-no-only.md"       fail "변경 이력 섹션: 적는 회차 기준 문구 삭제 격추"
assert_structure check_spec_history "$sandbox/sh-no-keep.md"       fail "변경 이력 섹션: 적을 것 문구 삭제 격추"
assert_structure check_spec_history "$sandbox/sh-no-drop.md"       fail "변경 이력 섹션: 적지 않을 것 문구 삭제 격추"
assert_structure check_spec_history "$sandbox/sh-no-none.md"       fail "변경 이력 섹션: 섹션을 두지 않는 기준 문구 삭제 격추"
assert_structure check_spec_history "$sandbox/sh-after-rel.md"     fail "변경 이력 섹션: 섹션의 연관 문서 뒤 이동 격추"

# --- 설계 결정, 테스트 계획, 테스트 먼저 Task, 마무리 (issue #145) ------------------
#
# plan 템플릿은 계획 종료 게이트 뒤에 선택 섹션 `## 설계 결정`과 `## 테스트 계획`을 두고,
# 일반 Task 를 테스트 작성 → 실패 확인 → 구현 → 통과 확인 순서로, Task N 을 마무리로 둔다.
# 규칙 문장은 주석·머리말 안내라 섹션 범위로 세고, 구조(제목·행·표)는 주석 밖에서만 센다.

# check_plan_design <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_plan_design() {
  awk '
    /^## / { sec = $0; task = "" }
    /^### Task / { task = $0 }
    index($0, "전제 (Assumptions)") { pre++ }
    /^## 계획 종료 게이트 \(고정\)$/ { gate_at = NR }
    /^## 설계 결정$/ { des++; des_at = NR }
    /^## 테스트 계획$/ { tp_at = NR }
    sec == "## 계획 종료 게이트 (고정)" && /^- \*\*발견 시 조치\*\*: / {
      g++
      if (!index($0, "spec `## 결정 사항`"))      print "계획 종료 게이트의 발견 시 조치에 spec 결정 사항 없음"
      if (!index($0, "plan `## 설계 결정`"))      print "계획 종료 게이트의 발견 시 조치에 plan 설계 결정 없음"
      if (!index($0, "발견이 없으면 체크만 한다")) print "계획 종료 게이트의 발견 시 조치에 발견 없을 때의 처리 없음"
    }
    task ~ /^### Task 0 \(고정\)/ && index($0, "spec `## 결정 사항`이나 plan `## 설계 결정`") { t0++ }
    sec == "## 설계 결정" {
      if (index($0, "선택 섹션이다"))                                  opt++
      if (/^  - 시스템 구성: /)                                         k1++
      if (/^  - 다른 시스템과의 연결: /)                                k2++
      if (/^  - 애플리케이션 구조 안의 자리: /)                         k3++
      if (/^  - 영향 모듈, 순서의 근거, 관례: /)                        k4++
      if (/^- 적지 않을 것: / && index($0, "spec `## 결정 사항`에 적는다")) drop++
      if (index($0, "바꾸는 모듈이 하나이고 구조나 순서에서 고를 것이 없으면 이 섹션을 두지 않는다")) none++
      if (index($0, "같은 종류의 발견이 두 회차 이어지면 그때 만든다")) later++
    }
    /<!--/ { c = 1 }
    c { if (/-->/) c = 0; next }
    sec == "## 설계 결정" && /^- \*\*[^*]+\*\*: / { rows++ }
    END {
      if (pre) print "옛 전제 섹션 참조 " pre "행"
      if (des != 1) print "설계 결정 헤더 " des + 0 "개 (기대 1개)"
      else if (!(gate_at && gate_at < des_at && des_at < tp_at)) print "설계 결정 섹션이 계획 종료 게이트와 테스트 계획 사이가 아님"
      if (g != 1)     print "계획 종료 게이트의 발견 시 조치 행 " g + 0 "개 (기대 1개)"
      if (t0 < 2)     print "Task 0의 작업 내용·완료 기준이 답을 적는 자리를 가리키지 않음 (" t0 + 0 "행)"
      if (opt != 1)   print "설계 결정 안내의 선택 섹션 문구 " opt + 0 "개 (기대 1개)"
      if (k1 != 1 || k2 != 1 || k3 != 1 || k4 != 1) print "설계 결정 안내의 적을 것 네 가지 " k1 + 0 "/" k2 + 0 "/" k3 + 0 "/" k4 + 0 " (기대 각 1개)"
      if (drop != 1)  print "설계 결정 안내의 적지 않을 것 " drop + 0 "개 (기대 1개)"
      if (none != 1)  print "설계 결정 안내의 섹션을 두지 않는 기준 " none + 0 "개 (기대 1개)"
      if (later != 1) print "설계 결정 안내의 뒤에 만드는 기준 " later + 0 "개 (기대 1개)"
      if (rows != 4)  print "설계 결정 예시 행 " rows + 0 "개 (기대 4개)"
    }' "$1"
}

awk '!/^## 설계 결정$/' "$TEMPLATE" > "$sandbox/pd-no-section.md"
drop_literal "$TEMPLATE" '선택 섹션이다' > "$sandbox/pd-no-opt.md"
for k in '시스템 구성' '다른 시스템과의 연결' '애플리케이션 구조 안의 자리' '영향 모듈, 순서의 근거, 관례'; do
  awk -v k="  - ${k}: " 'index($0, k) != 1' "$TEMPLATE" > "$sandbox/pd-no-key.md"
  assert_structure check_plan_design "$sandbox/pd-no-key.md" fail "설계 결정 섹션: 적을 것 안내의 ${k} 삭제 격추"
done
awk '/^## 설계 결정$/ { s = 1 } s && /^- 적지 않을 것: / { s = 0; next } { print }' "$TEMPLATE" > "$sandbox/pd-no-drop.md"
drop_literal "$TEMPLATE" '바꾸는 모듈이 하나이고 구조나 순서에서 고를 것이 없으면 이 섹션을 두지 않는다' > "$sandbox/pd-no-none.md"
drop_literal "$TEMPLATE" '같은 종류의 발견이 두 회차 이어지면 그때 만든다' > "$sandbox/pd-no-later.md"
awk '/^## / { s = ($0 == "## 설계 결정") } s && /^- \*\*시스템 구성\*\*: / { next } { print }' "$TEMPLATE" > "$sandbox/pd-no-row.md"
# 설계 결정 섹션(다음 헤더 앞까지)을 Tasks 뒤(파일 끝)로 옮긴다.
awk '/^## / { s = ($0 == "## 설계 결정") } s { buf = buf $0 "\n"; next } { print } END { print ""; printf "%s", buf }' \
  "$TEMPLATE" > "$sandbox/pd-late.md"
awk '/^- \*\*발견 시 조치\*\*: / { $0 = "- **발견 시 조치**: spec `## 전제 (Assumptions)` 섹션에 적는다." } { print }' \
  "$TEMPLATE" > "$sandbox/pd-gate-old.md"
drop_literal "$TEMPLATE" '발견이 없으면 체크만 한다' > "$sandbox/pd-gate-no-empty.md"
awk '/^### Task 0/ { t = 1 } /^### Task 1/ { t = 0 } t { sub(/ spec `## 결정 사항`이나 plan `## 설계 결정`/, " spec") } { print }' \
  "$TEMPLATE" > "$sandbox/pd-task0.md"

assert_structure check_plan_design "$TEMPLATE"                    pass "설계 결정 섹션: 실제 plan 템플릿 통과"
assert_structure check_plan_design "$sandbox/pd-no-section.md"    fail "설계 결정 섹션: 섹션 헤더 삭제 격추"
assert_structure check_plan_design "$sandbox/pd-no-opt.md"        fail "설계 결정 섹션: 선택 섹션 문구 삭제 격추"
assert_structure check_plan_design "$sandbox/pd-no-drop.md"       fail "설계 결정 섹션: 적지 않을 것 안내 삭제 격추"
assert_structure check_plan_design "$sandbox/pd-no-none.md"       fail "설계 결정 섹션: 섹션을 두지 않는 기준 삭제 격추"
assert_structure check_plan_design "$sandbox/pd-no-later.md"      fail "설계 결정 섹션: 뒤에 만드는 기준 삭제 격추"
assert_structure check_plan_design "$sandbox/pd-no-row.md"        fail "설계 결정 섹션: 예시 행 삭제 격추"
assert_structure check_plan_design "$sandbox/pd-late.md"          fail "설계 결정 섹션: 섹션의 Tasks 뒤 이동 격추"
assert_structure check_plan_design "$sandbox/pd-gate-old.md"      fail "설계 결정 섹션: 계획 종료 게이트의 옛 전제 섹션 되돌리기 격추"
assert_structure check_plan_design "$sandbox/pd-gate-no-empty.md" fail "설계 결정 섹션: 계획 종료 게이트의 발견 없을 때 문구 삭제 격추"
assert_structure check_plan_design "$sandbox/pd-task0.md"         fail "설계 결정 섹션: Task 0의 답을 적는 자리 삭제 격추"

# plan_tables <파일> → 테스트 계획 섹션의 주석 밖 표 행을 `<표>\t<행 번호>\t<행>`으로 낸다 (표: main·manual)
plan_tables() {
  awk '/^## / { s = ($0 == "## 테스트 계획"); k = "main" }
       /<!--/ { c = 1 } c { if (/-->/) c = 0; next }
       s && /^### 테스트로 못 보는 항목$/ { k = "manual"; n = 0 }
       s && /^\|/ { if (k != pk) { n = 0; pk = k } n++; print k "\t" n "\t" $0 }' "$1"
}

# check_test_plan <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 한 행의 칸 수를 함께 센다 — 머리만 보면 예시 행에서 칸이 빠져도 통과한다.
check_test_plan() {
  awk '
    /^## / { sec = $0 }
    /^## 설계 결정$/ { des_at = NR }
    /^## 테스트 계획$/ { tp++; tp_at = NR }
    /^## Tasks$/ { tasks_at = NR }
    sec == "## 테스트 계획" {
      if (/^### /) { if ($0 == "### 테스트로 못 보는 항목") man++; else print "테스트 계획 섹션의 모르는 하위 제목: " $0 }
      if (index($0, "spec의 AC마다 아래 두 표 가운데 한 줄 이상에 적는다")) each++
      if (index($0, "`[D]`·`[QD]` 줄에는 그 줄의 AC를 충족으로 판정한 교차 감사의 회차를 적는다")) c1++
      if (index($0, "`[ND]` 줄에는 사용자가 확인한 날짜를 적는다")) c2++
      if (index($0, "계획을 쓸 때는 비워 둔다")) c3++
      if (index($0, "줄을 더하거나 `확인` 외 칸을 바꾸면 그 줄의 `확인`을 비운다")) c4++
    }
    END {
      if (tp != 1) print "테스트 계획 헤더 " tp + 0 "개 (기대 1개)"
      else if (!(des_at && des_at < tp_at && tp_at < tasks_at)) print "테스트 계획 섹션이 설계 결정과 Tasks 사이가 아님"
      if (man != 1)  print "테스트로 못 보는 항목 제목 " man + 0 "개 (기대 1개)"
      if (each != 1) print "AC마다 한 줄 이상 적는다는 안내 " each + 0 "개 (기대 1개)"
      if (c1 != 1 || c2 != 1 || c3 != 1 || c4 != 1) print "확인 칸 안내 " c1 + 0 "/" c2 + 0 "/" c3 + 0 "/" c4 + 0 " (기대 각 1개)"
    }' "$1"
  plan_tables "$1" | awk -F'\t' '
    function cells(r) { return gsub(/\|/, "|", r) - 1 }
    { rows[$1]++; want = ($1 == "main") ? 6 : 5
      head = ($1 == "main") ? "| AC | 레벨 | 층 | 테스트 | 단위로 못 보는 이유 | 확인 |" : "| AC | 레벨 | 누가 보나 | 이유 | 확인 |"
      if ($2 == 1 && $3 != head) print $1 " 표 머리가 [" head "]가 아님: " $3
      if (cells($3) != want) print $1 " 표 행의 칸 수가 " want "이 아님: " $3
      if ($2 == 2 && $3 !~ /^[|-]+$/) print $1 " 표 구분선이 아님: " $3
      if ($2 > 2) {
        split($3, v, "|"); for (i in v) gsub(/^ +| +$/, "", v[i])
        if (v[2] !~ /^AC[0-9]+$/) print $1 " 표 예시 행의 AC 칸이 AC<n> 하나가 아님: " $3
        if ($1 == "main" && v[3] != "[D]") print "테스트 표 예시 행의 레벨이 [D]가 아님: " $3
        if ($1 == "manual" && v[3] != "[QD]" && v[3] != "[ND]") print "못 보는 항목 표 예시 행의 레벨이 [QD]·[ND]가 아님: " $3
        if (v[want + 1] != "") print $1 " 표 예시 행의 확인 칸이 비어 있지 않음: " $3
      } }
    END { if (rows["main"] < 3) print "테스트 표에 머리·구분선·예시 행이 없음 (" rows["main"] + 0 "행)"
          if (rows["manual"] < 3) print "못 보는 항목 표에 머리·구분선·예시 행이 없음 (" rows["manual"] + 0 "행)" }'
}

awk '!/^## 테스트 계획$/' "$TEMPLATE" > "$sandbox/tl-no-section.md"
awk '/^## / { s = ($0 == "## 테스트 계획") } s { buf = buf $0 "\n"; next } { print } END { print ""; printf "%s", buf }' \
  "$TEMPLATE" > "$sandbox/tl-late.md"
awk '/^\| AC \| 레벨 \| 층 / { sub(/ 층 \|/, "") } { print }' "$TEMPLATE" > "$sandbox/tl-no-layer-col.md"
awk '/^\| AC \| 레벨 \| 층 / { sub(/ 테스트 \|/, "") } { print }' "$TEMPLATE" > "$sandbox/tl-no-test-col.md"
awk '/^\| AC \| 레벨 \| 층 / { sub(/ 확인 \|$/, "") } { print }' "$TEMPLATE" > "$sandbox/tl-no-check-col.md"
awk '/^\| AC \| 레벨 \| 누가 보나 / { sub(/ 확인 \|$/, "") } { print }' "$TEMPLATE" > "$sandbox/tl-no-check-col2.md"
awk '/^\| AC \| 레벨 \| 누가 보나 / { sub(/ 누가 보나 \|/, "") } { print }' "$TEMPLATE" > "$sandbox/tl-no-who-col.md"
awk '/^\| AC1 \| \[D\] / { sub(/\[D\]/, "[ND]") } { print }' "$TEMPLATE" > "$sandbox/tl-main-nd.md"
awk '/^\| AC[0-9]+ \| \[ND\] / { sub(/\[ND\]/, "[D]") } { print }' "$TEMPLATE" > "$sandbox/tl-manual-d.md"
awk '/^\| AC1 \| \[D\] / { sub(/\| *\|$/, "| 최종 1차 |") } { print }' "$TEMPLATE" > "$sandbox/tl-prefilled.md"
awk '/^\| AC1 \| \[D\] / { sub(/^\| AC1 /, "| AC1, AC2 ") } { print }' "$TEMPLATE" > "$sandbox/tl-multi-ac.md"
awk '!/^### 테스트로 못 보는 항목$/' "$TEMPLATE" > "$sandbox/tl-no-manual.md"
drop_literal "$TEMPLATE" 'spec의 AC마다 아래 두 표 가운데 한 줄 이상에 적는다' > "$sandbox/tl-no-each.md"
drop_literal "$TEMPLATE" '`[D]`·`[QD]` 줄에는 그 줄의 AC를 충족으로 판정한 교차 감사의 회차를 적는다' > "$sandbox/tl-no-c1.md"
drop_literal "$TEMPLATE" '`[ND]` 줄에는 사용자가 확인한 날짜를 적는다' > "$sandbox/tl-no-c2.md"
drop_literal "$TEMPLATE" '계획을 쓸 때는 비워 둔다' > "$sandbox/tl-no-c3.md"
drop_literal "$TEMPLATE" '줄을 더하거나 `확인` 외 칸을 바꾸면 그 줄의 `확인`을 비운다' > "$sandbox/tl-no-c4.md"

assert_structure check_test_plan "$TEMPLATE"                     pass "테스트 계획 표: 실제 plan 템플릿 통과"
assert_structure check_test_plan "$sandbox/tl-no-section.md"     fail "테스트 계획 표: 섹션 헤더 삭제 격추"
assert_structure check_test_plan "$sandbox/tl-late.md"           fail "테스트 계획 표: 섹션의 Tasks 뒤 이동 격추"
assert_structure check_test_plan "$sandbox/tl-no-layer-col.md"   fail "테스트 계획 표: 테스트 표의 층 칸 삭제 격추"
assert_structure check_test_plan "$sandbox/tl-no-test-col.md"    fail "테스트 계획 표: 테스트 표의 테스트 칸 삭제 격추"
assert_structure check_test_plan "$sandbox/tl-no-check-col.md"   fail "테스트 계획 표: 테스트 표의 확인 칸 삭제 격추"
assert_structure check_test_plan "$sandbox/tl-no-check-col2.md"  fail "테스트 계획 표: 못 보는 항목 표의 확인 칸 삭제 격추"
assert_structure check_test_plan "$sandbox/tl-no-who-col.md"     fail "테스트 계획 표: 못 보는 항목 표의 누가 보나 칸 삭제 격추"
assert_structure check_test_plan "$sandbox/tl-main-nd.md"        fail "테스트 계획 표: 테스트 표 행의 레벨 [ND] 격추"
assert_structure check_test_plan "$sandbox/tl-manual-d.md"       fail "테스트 계획 표: 못 보는 항목 행의 레벨 [D] 격추"
assert_structure check_test_plan "$sandbox/tl-prefilled.md"      fail "테스트 계획 표: 예시 행의 확인 칸 미리 채움 격추"
assert_structure check_test_plan "$sandbox/tl-multi-ac.md"       fail "테스트 계획 표: 한 줄에 AC 두 개 격추"
assert_structure check_test_plan "$sandbox/tl-no-manual.md"      fail "테스트 계획 표: 테스트로 못 보는 항목 제목 삭제 격추"
assert_structure check_test_plan "$sandbox/tl-no-each.md"        fail "테스트 계획 표: AC마다 한 줄 이상 안내 삭제 격추"
assert_structure check_test_plan "$sandbox/tl-no-c1.md"          fail "테스트 계획 표: 확인 칸의 감사 회차 안내 삭제 격추"
assert_structure check_test_plan "$sandbox/tl-no-c2.md"          fail "테스트 계획 표: 확인 칸의 사용자 확인 날짜 안내 삭제 격추"
assert_structure check_test_plan "$sandbox/tl-no-c3.md"          fail "테스트 계획 표: 확인 칸을 비워 두는 안내 삭제 격추"
assert_structure check_test_plan "$sandbox/tl-no-c4.md"          fail "테스트 계획 표: 바뀐 줄의 확인을 비우는 안내 삭제 격추"

# check_test_layer <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 예시 행은 단위 층(이유 `-`)과 단위보다 위 층(이유 있음)을 모두 보여 준다.
check_test_layer() {
  awk '
    /^## / { s = ($0 == "## 테스트 계획") }
    s && index($0, "단위 테스트를 먼저 고른다") { unit++ }
    s && index($0, "단위보다 위 층을 쓰면 `단위로 못 보는 이유` 칸에 이유를 적는다") { why++ }
    s && index($0, "테스트 케이스가 아닌 결정적 명령(bash 명령 등)도 테스트 표에 적는다") { cmd++ }
    END { if (unit != 1) print "단위 먼저 안내 " unit + 0 "개 (기대 1개)"
          if (why != 1)  print "위 층의 이유 안내 " why + 0 "개 (기대 1개)"
          if (cmd != 1)  print "결정적 명령 안내 " cmd + 0 "개 (기대 1개)" }' "$1"
  plan_tables "$1" | awk -F'\t' '
    $1 == "main" && $2 == 1 { h = ($3 ~ /\| 단위로 못 보는 이유 \|/) }
    $1 == "main" && $2 > 2 {
      split($3, v, "|"); for (i in v) gsub(/^ +| +$/, "", v[i])
      if (v[4] == "단위") { u++; if (v[6] != "-") print "단위 층 행의 이유 칸이 -가 아님: " $3 }
      else { o++; if (v[6] == "" || v[6] == "-") print "단위보다 위 층 행에 이유 없음: " $3 } }
    END { if (!h) print "테스트 표 머리에 단위로 못 보는 이유 칸 없음"
          if (u < 1) print "단위 층 예시 행 없음"
          if (o < 1) print "단위보다 위 층 예시 행 없음" }'
}

awk '/^\| AC \| 레벨 \| 층 / { sub(/ 단위로 못 보는 이유 \|/, "") } { print }' "$TEMPLATE" > "$sandbox/ty-no-col.md"
drop_literal "$TEMPLATE" '단위 테스트를 먼저 고른다' > "$sandbox/ty-no-unit.md"
drop_literal "$TEMPLATE" '단위보다 위 층을 쓰면 `단위로 못 보는 이유` 칸에 이유를 적는다' > "$sandbox/ty-no-why.md"
drop_literal "$TEMPLATE" '테스트 케이스가 아닌 결정적 명령(bash 명령 등)도 테스트 표에 적는다' > "$sandbox/ty-no-cmd.md"
awk -F'|' '/^\| AC[0-9]+ \| \[D\] \|/ && $4 !~ /^ 단위 $/ { print "|" $2 "|" $3 "|" $4 "|" $5 "| - |" $7 "|"; next } { print }' \
  "$TEMPLATE" > "$sandbox/ty-dash.md"

assert_structure check_test_layer "$TEMPLATE"              pass "테스트 층 이유: 실제 plan 템플릿 통과"
assert_structure check_test_layer "$sandbox/ty-no-col.md"  fail "테스트 층 이유: 단위로 못 보는 이유 칸 삭제 격추"
assert_structure check_test_layer "$sandbox/ty-no-unit.md" fail "테스트 층 이유: 단위 먼저 안내 삭제 격추"
assert_structure check_test_layer "$sandbox/ty-no-why.md"  fail "테스트 층 이유: 위 층의 이유 안내 삭제 격추"
assert_structure check_test_layer "$sandbox/ty-no-cmd.md"  fail "테스트 층 이유: 결정적 명령 안내 삭제 격추"
assert_structure check_test_layer "$sandbox/ty-dash.md"    fail "테스트 층 이유: 위 층 예시 행의 이유 비움 격추"

# check_test_first <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 일반 Task 의 최상위 필드는 목표·대상 요구사항·테스트 먼저·구현 네 개가 이 순서로 전부다.
# `테스트 먼저` 값이 비어 있으면 테스트 이름 목록과 실패 확인 행을, `쓰지 않음(<이유>)`이면 기존 테스트 전체 통과를 요구한다.
check_test_first() {
  awk '
    function flush() {
      if (t == "") return
      if (box != 1)  print "완료 체크박스 " box + 0 "개: " t
      if (seq != "목표|대상 요구사항|테스트 먼저|구현|") print "최상위 필드 구성이 다름 [" seq "]: " t
      if (pas != 1)  print "통과 확인 행 " pas + 0 "개: " t
      if (num < 1)   print "구현 번호 목록 없음: " t
      if (kind == "first") {
        first_n++
        if (names < 1) print "테스트 이름 목록 없음: " t
        if (red != 1)  print "실패 확인 행 " red + 0 "개: " t
        if (!redc)     print "실패 확인 행에 테스트 커밋 없음: " t
        if (!pasc)     print "통과 확인 행에 구현 커밋 없음: " t
      } else if (kind == "skip") {
        skip_n++
        if (red || names) print "테스트를 먼저 쓰지 않는 Task에 실패 확인이나 테스트 목록: " t
        if (!pasall)      print "테스트를 먼저 쓰지 않는 Task의 통과 확인이 기존 테스트 전체가 아님: " t
      } else print "테스트 먼저 값이 빈 값이나 쓰지 않음(<이유>)이 아님: " t
      t = ""
    }
    /^## Tasks$/ { s = 1 }
    /^### Task / { flush(); if ($0 !~ /^### Task (0|N) \(고정\)/) { t = $0; box = num = names = red = pas = 0; redc = pasc = pasall = 0; seq = kind = cur = "" } s = 0 }
    s && /^>/ {
      if (index($0, "테스트 작성 → 실패 확인 → 구현 → 통과 확인")) h1++
      if (index($0, "테스트 커밋과 구현 커밋을 나눕니다")) h2++
      if (index($0, "동작을 바꾸지 않는 Task")) h3++
      if (index($0, "문서만 고치는 Task")) k1++
      if (index($0, "화면 배치")) k2++
      if (index($0, "스파이크")) k3++
      if (index($0, "리팩터링")) k4++
      if (index($0, "구현 → 통과 확인 두 단계")) h4++
      if (index($0, "통과 확인은 기존 테스트 전체 통과")) h5++
      if (index($0, "먼저 쓰지 않는 이유를 한 줄")) h6++
    }
    /<!--/ { c = 1 }
    c { if (/-->/) c = 0; next }
    t != "" && /^- \[ \] 완료$/ { box++ }
    t != "" && /^- \*\*[^*]+\*\*:/ {
      cur = $0; sub(/^- \*\*/, "", cur); sub(/\*\*:.*/, "", cur); seq = seq cur "|"
      if (cur == "테스트 먼저") kind = ($0 ~ /^- \*\*테스트 먼저\*\*:$/) ? "first" : ($0 ~ /^- \*\*테스트 먼저\*\*: 쓰지 않음\(.+\)$/) ? "skip" : "bad"
    }
    t != "" && cur == "테스트 먼저" && /^  - \*\*실패 확인\*\*: / { red++; if (index($0, "테스트 커밋")) redc = 1; next }
    t != "" && cur == "테스트 먼저" && /^  - / { if (!red) names++ }
    t != "" && cur == "구현" && /^  [0-9]+\. / { if (!pas) num++ }
    t != "" && cur == "구현" && /^  - \*\*통과 확인\*\*: / { pas++; if (index($0, "구현 커밋")) pasc = 1; if (index($0, "기존 테스트 전체")) pasall = 1 }
    END {
      flush()
      if (first_n < 1) print "테스트를 먼저 쓰는 Task 예시 없음"
      if (skip_n < 1)  print "테스트를 먼저 쓰지 않는 Task 예시 없음"
      if (h1 != 1) print "머리말의 네 단계 순서 " h1 + 0 "개 (기대 1개)"
      if (h2 != 1) print "머리말의 커밋 분리 " h2 + 0 "개 (기대 1개)"
      if (h3 != 1) print "머리말의 먼저 쓰지 않는 기준 " h3 + 0 "개 (기대 1개)"
      if (!k1 || !k2 || !k3 || !k4) print "머리말의 먼저 쓰지 않는 Task 네 가지 " k1 + 0 "/" k2 + 0 "/" k3 + 0 "/" k4 + 0
      if (h4 != 1) print "머리말의 두 단계 진행 " h4 + 0 "개 (기대 1개)"
      if (h5 != 1) print "머리말의 기존 테스트 전체 통과 " h5 + 0 "개 (기대 1개)"
      if (h6 != 1) print "머리말의 이유 한 줄 " h6 + 0 "개 (기대 1개)"
    }' "$1"
}

awk '/^### Task 1: /{s=1} /^### Task 2: /{s=0} s && /^  - \*\*실패 확인\*\*: / { next } { print }' "$TEMPLATE" > "$sandbox/tf-no-red.md"
awk '/^### Task 1: /{s=1} /^### Task 2: /{s=0} s && /^  - \*\*통과 확인\*\*: / { next } { print }' "$TEMPLATE" > "$sandbox/tf-no-green.md"
awk '/^### Task 1: /{s=1} /^### Task 2: /{s=0} s && /^  - <테스트 파일>/ { next } { print }' "$TEMPLATE" > "$sandbox/tf-no-names.md"
# 테스트 먼저 필드(하위 행 포함)를 구현 뒤로 옮긴다.
awk '/^### Task 1: /{s=1} /^### Task 2: /{s=0}
     s && /^- \*\*테스트 먼저\*\*:/ { h = 1 } s && /^- \*\*구현\*\*:/ { h = 0 }
     h { buf = buf $0 "\n"; next }
     s && buf && /^---$/ { printf "%s", buf; buf = "" } { print }' "$TEMPLATE" > "$sandbox/tf-after-impl.md"
awk '{ sub(/^- \*\*구현\*\*:$/, "- **작업 내용**:"); print }' "$TEMPLATE" > "$sandbox/tf-old-field.md"
awk '/^### Task 1: /{s=1} /^### Task 2: /{s=0} s && /통과 확인/ { gsub(/구현 커밋/, "커밋") } { print }' "$TEMPLATE" > "$sandbox/tf-no-impl-commit.md"
awk '/^### Task 1: /{s=1} /^### Task 2: /{s=0} s && /실패 확인/ { gsub(/테스트 커밋/, "커밋") } { print }' "$TEMPLATE" > "$sandbox/tf-no-test-commit.md"
awk '{ sub(/^- \*\*테스트 먼저\*\*: 쓰지 않음\(.+\)$/, "- **테스트 먼저**: 쓰지 않음"); print }' "$TEMPLATE" > "$sandbox/tf-skip-no-reason.md"
awk '/^### Task 2: /{s=1} /^### Task N/{s=0} s && /통과 확인/ { gsub(/기존 테스트 전체/, "테스트") } { print }' "$TEMPLATE" > "$sandbox/tf-skip-partial.md"
awk '{ print } /^### Task 1: /{s=1} s && /^- \[ \] 완료$/ { print; s=0 }' "$TEMPLATE" > "$sandbox/tf-dup-box.md"

assert_structure check_test_first "$TEMPLATE"                      pass "테스트 먼저 Task: 실제 plan 템플릿 통과"
assert_structure check_test_first "$sandbox/tf-no-red.md"          fail "테스트 먼저 Task: 실패 확인 행 삭제 격추"
assert_structure check_test_first "$sandbox/tf-no-green.md"        fail "테스트 먼저 Task: 확인 행(구현 뒤) 삭제 격추"
assert_structure check_test_first "$sandbox/tf-no-names.md"        fail "테스트 먼저 Task: 테스트 이름 목록 삭제 격추"
assert_structure check_test_first "$sandbox/tf-after-impl.md"      fail "테스트 먼저 Task: 테스트 먼저 필드의 구현 뒤 이동 격추"
assert_structure check_test_first "$sandbox/tf-old-field.md"       fail "테스트 먼저 Task: 옛 작업 내용 필드 되돌리기 격추"
assert_structure check_test_first "$sandbox/tf-no-test-commit.md"  fail "테스트 먼저 Task: 실패 확인 행의 테스트 커밋 삭제 격추"
assert_structure check_test_first "$sandbox/tf-no-impl-commit.md"  fail "테스트 먼저 Task: 구현 커밋 문구 삭제 격추"
assert_structure check_test_first "$sandbox/tf-skip-no-reason.md"  fail "테스트 먼저 Task: 먼저 쓰지 않는 이유 삭제 격추"
assert_structure check_test_first "$sandbox/tf-skip-partial.md"    fail "테스트 먼저 Task: 먼저 쓰지 않는 Task의 전체 테스트 문구 삭제 격추"
assert_structure check_test_first "$sandbox/tf-dup-box.md"         fail "테스트 먼저 Task: 완료 체크박스 중복 격추"
for p in '테스트 작성 → 실패 확인 → 구현 → 통과 확인' '테스트 커밋과 구현 커밋을 나눕니다' '동작을 바꾸지 않는 Task' '문서만 고치는 Task' \
         '화면 배치' '스파이크' '리팩터링' '구현 → 통과 확인 두 단계' '통과 확인은 기존 테스트 전체 통과' '먼저 쓰지 않는 이유를 한 줄'; do
  drop_literal "$TEMPLATE" "$p" > "$sandbox/tf-drop.md"
  # 케이스 설명에 격추 외 판정 낱말이 섞이지 않게 문구의 해당 낱말을 가린다.
  assert_structure check_test_first "$sandbox/tf-drop.md" fail "테스트 먼저 Task: 머리말의 [$(printf '%s' "$p" | sed 's/통과/…/g')] 삭제 격추"
done

# check_finish_task <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# Task N 의 작업은 이름을 열거한 여섯 개가 이 순서로 전부다. 교차 감사 실행 단계(issue-audit 호출)를 두지 않는다.
check_finish_task() {
  awk '
    /^### Task / { on = 0 }
    /^### Task N / { tn++; on = 1; if ($0 != "### Task N (고정): 마무리") print "Task N 헤더가 다름: " $0 }
    !on { next }
    index($0, "완료 확인에서 사용자가 `마무리`로 정한 뒤에만 들어간다") { enter++ }
    index($0, "이 Task에서 구현을 고치면 계획 수립으로 돌아간다") { back++ }
    index($0, "`--clear`가 archive 이관 직전에 이 체크박스를 체크하고 PR은 그 뒤에 만든다") { tick++ }
    /issue-audit/ { audit++ }
    /<!--/ { c = 1 }
    c { if (/-->/) c = 0; next }
    /^- \[ \] 완료$/ { box++ }
    /^- \*\*[^*]+\*\*:/ { cur = $0; sub(/^- \*\*/, "", cur); sub(/\*\*:.*/, "", cur); seq = seq cur "|" }
    cur == "작업 내용" && /^  [0-9]+\. / { v = $0; if (!match(v, /\*\*[^*]+\*\*/)) v = "?"; else v = substr(v, RSTART + 2, RLENGTH - 4); steps = steps v "|" }
    cur == "완료 기준" && /^  - \[D\] /  { d++; if (index($0, "`테스트 계획`의 `[D]` 줄")) reg++
                                            if (index($0, "summary의 Task 헤더 집합이 plan과 일치")) g0++
                                            if (index($0, "블록마다 유효 `결과` 행 정확히 1개")) g1++
                                            if (index($0, "`-`도 아닌 행 정확히 1개")) g2++ }
    cur == "완료 기준" && /^  - \[QD\] / { q++; if (index($0, "서로 다른 벤더")) v1++; if (index($0, "벤더 전부와도 상이")) v2++ }
    cur == "완료 기준" && /^  - \[ND\] / { nd++ }
    END {
      if (tn != 1)  print "Task N 헤더 " tn + 0 "개 (기대 1개)"
      if (box != 1) print "Task N 완료 체크박스 " box + 0 "개 (기대 1개)"
      if (seq != "목표|작업 내용|완료 기준|") print "Task N 최상위 필드 구성이 다름 [" seq "]"
      if (steps != "전체 회귀|색인|충족 AC 체크|repo 고유 마무리|--clear|PR|") print "Task N 작업 구성이 다름 [" steps "]"
      if (audit)      print "Task N에 issue-audit 언급 " audit "행 (교차 감사는 구현 검증 단계에서 받는다)"
      if (enter != 1) print "마무리로 정한 뒤에만 들어간다는 문장 " enter + 0 "개 (기대 1개)"
      if (back != 1)  print "구현을 고치면 돌아간다는 문장 " back + 0 "개 (기대 1개)"
      if (tick != 1)  print "체크박스를 --clear가 체크한다는 문장 " tick + 0 "개 (기대 1개)"
      if (d != 4 || reg != 1 || g0 != 1 || g1 != 1 || g2 != 1) print "Task N [D] 기준 " d + 0 "개, 회귀 " reg + 0 " 게이트 " g0 + 0 "/" g1 + 0 "/" g2 + 0 " (기대 4개, 각 1)"
      if (q != 2 || v1 != 1 || v2 != 1) print "Task N 벤더 교차 조건 " v1 + 0 "/" v2 + 0 " ([QD] " q + 0 "개, 기대 2개)"
      if (nd) print "Task N에 [ND] 기준 " nd "개 (기대 0개)"
    }' "$1"
}

awk '{ sub(/^### Task N \(고정\): 마무리$/, "### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)"); print }' "$TEMPLATE" > "$sandbox/fi-old-header.md"
for st in '전체 회귀' '색인' '충족 AC 체크' 'repo 고유 마무리' '--clear' 'PR'; do
  awk -v st="**${st}**" '/^### Task N/ { s = 1 } s && /^  [0-9]+\. / && index($0, st) { next } { print }' "$TEMPLATE" > "$sandbox/fi-no-step.md"
  assert_structure check_finish_task "$sandbox/fi-no-step.md" fail "마무리 Task: 작업 [${st}] 삭제 격추"
done
awk '/^### Task N/ { s = 1 } { print } s && /^- \*\*작업 내용\*\*:/ { print "  1. **교차 감사**: 다른 벤더 모델로 감사를 받는다."; s = 0 }' "$TEMPLATE" > "$sandbox/fi-audit-step.md"
awk '/^### Task N/ { s = 1 } s && /\*\*전체 회귀\*\*/ { $0 = $0 " `issue-audit`를 실행한다." } { print }' "$TEMPLATE" > "$sandbox/fi-audit-run.md"
# --clear 와 PR 의 순서를 바꾼다.
awk '/^### Task N/ { s = 1 } s && /^  [0-9]+\. \*\*--clear\*\*/ { held = $0; next } { print } held && /^  [0-9]+\. \*\*PR\*\*/ { print held; held = "" }' \
  "$TEMPLATE" > "$sandbox/fi-swap.md"
drop_literal "$TEMPLATE" '완료 확인에서 사용자가 `마무리`로 정한 뒤에만 들어간다' > "$sandbox/fi-no-enter.md"
drop_literal "$TEMPLATE" '이 Task에서 구현을 고치면 계획 수립으로 돌아간다' > "$sandbox/fi-no-back.md"
drop_literal "$TEMPLATE" '`--clear`가 archive 이관 직전에 이 체크박스를 체크하고 PR은 그 뒤에 만든다' > "$sandbox/fi-no-tick.md"
awk '!/^  - \[QD\] 구현에 여러 벤더가/' "$TEMPLATE" > "$sandbox/fi-no-vendor.md"
awk '/^### Task N/ { s = 1 } s && /^- \[ \] 완료$/ { next } { print }' "$TEMPLATE" > "$sandbox/fi-no-box.md"

assert_structure check_finish_task "$TEMPLATE"                    pass "마무리 Task: 실제 plan 템플릿 통과"
assert_structure check_finish_task "$sandbox/fi-old-header.md"    fail "마무리 Task: 옛 교차모델 감사 헤더 되돌리기 격추"
assert_structure check_finish_task "$sandbox/fi-audit-step.md"    fail "마무리 Task: 교차 감사 작업 추가 격추"
assert_structure check_finish_task "$sandbox/fi-audit-run.md"     fail "마무리 Task: 감사 실행 문구 추가 격추"
assert_structure check_finish_task "$sandbox/fi-swap.md"          fail "마무리 Task: --clear와 PR 순서 역전 격추"
assert_structure check_finish_task "$sandbox/fi-no-enter.md"      fail "마무리 Task: 들어가는 조건 문장 삭제 격추"
assert_structure check_finish_task "$sandbox/fi-no-back.md"       fail "마무리 Task: 돌아가는 조건 문장 삭제 격추"
assert_structure check_finish_task "$sandbox/fi-no-tick.md"       fail "마무리 Task: 체크박스 기록 문장 삭제 격추"
assert_structure check_finish_task "$sandbox/fi-no-vendor.md"     fail "마무리 Task: 벤더 교차 조건 삭제 격추"
assert_structure check_finish_task "$sandbox/fi-no-box.md"        fail "마무리 Task: 완료 체크박스 삭제 격추"

# --- 루프 기록, 종류별 발견, 새 구조 fixture (issue #145) ---------------------------
#
# summary 템플릿은 `## 모델 기록` 뒤, `## Task별 수행 결과` 앞에 `## 루프 기록`과 `## 종류별 발견`을 두고,
# 일반 Task 블록에 `테스트`·`대응 발견` 필드를 둔다. plan 템플릿의 Task 는 회차 묶음 없이 이어진다.

# check_loop_table <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_loop_table() {
  awk '
    /^## / { sec = $0 }
    /^## 모델 기록$/ { model_at = NR }
    /^## 루프 기록$/ { loop++; loop_at = NR }
    /^## Task별 수행 결과$/ { task_at = NR }
    sec == "## 루프 기록" {
      if (index($0, "회차마다 한 줄을 적고 회차 1부터 적는다")) g1++
      if (index($0, "그 회차에 받지 않은 검증의 커밋 칸은 `-`로 둔다")) g2++
      if (index($0, "값이 있는 가장 최근 행")) g3++
      if (index($0, "감사 종류와 리포트 머리말의 감사 회차(`계획 2차`, `최종 1차`)")) g4++
      if (index($0, "1단계 상태·2단계 상태·종합 판정·테스트 계획 줄 수")) g5++
      if (index($0, "파일 이름은 적지 않는다")) g6++
      if (/^- 다시 시작한 단계: / && index($0, "`계획 검증`이나 `구현`")) g7++
      if (/^- 결정: / && index($0, "`마무리`나 `다음 회차`")) g8++
      if (index($0, "`(미커밋 포함)`이 있으면 diff로 가리지 않고 바뀐 것으로 본다")) g9++
    }
    /<!--/ { c = 1 }
    c { if (/-->/) c = 0; next }
    sec == "## 루프 기록" && /^\|/ {
      tl++; r = $0; n = gsub(/\|/, "|", r) - 1
      if (tl == 1 && $0 != "| 회차 | 바뀐 것 | 다시 시작한 단계 | 계획 검증 커밋 | 구현 검증 커밋 | 검증 결과 | 결정 |") print "루프 기록 표 머리가 다름: " $0
      if (n != 7) print "루프 기록 표 행의 칸 수가 7이 아님: " $0
      if (tl == 2 && $0 !~ /^[|-]+$/) print "루프 기록 표 구분선이 아님: " $0
    }
    END {
      if (loop != 1) print "루프 기록 헤더 " loop + 0 "개 (기대 1개)"
      else if (!(model_at && model_at < loop_at && loop_at < task_at)) print "루프 기록 섹션이 모델 기록과 Task별 수행 결과 사이가 아님"
      if (tl < 3) print "루프 기록 표에 머리·구분선·예시 행이 없음 (" tl + 0 "행)"
      if (g1 != 1 || g2 != 1 || g3 != 1 || g4 != 1 || g5 != 1 || g6 != 1 || g7 != 1 || g8 != 1 || g9 != 1)
        print "루프 기록 안내 " g1 + 0 g2 + 0 g3 + 0 g4 + 0 g5 + 0 g6 + 0 g7 + 0 g8 + 0 g9 + 0 " (기대 111111111)"
    }' "$1"
}

# check_plan_heads <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# Tasks 뒤의 제목은 Task 헤더가 전부다 — 회차 묶음 제목은 `## `·`### `·`#### ` 어느 수준으로 넣어도 위반이다.
check_plan_heads() {
  awk '
    /^```|^    ```/ { f = !f }
    f { next }
    /^## Tasks$/ { s = 1; next }
    s && /^##+ / {
      if ($0 ~ /^### Task [0-9]+: / || $0 == "### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)" || $0 == "### Task N (고정): 마무리") n++
      else print "Task 헤더가 아닌 제목: " $0
    }
    END { if (n < 4) print "Task 헤더 " n + 0 "개 (기대 4개 이상)" }' "$1"
}

LT='/^## / { s = ($0 == "## 루프 기록") }'
awk '!/^## 루프 기록$/' "$SUMMARY_TPL" > "$sandbox/lt-no-section.md"
awk "$LT"' s { buf = buf $0 "\n"; next } { print } END { print ""; printf "%s", buf }' "$SUMMARY_TPL" > "$sandbox/lt-late.md"
awk "$LT"' s && /^\| 회차 / { sub(/ 계획 검증 커밋 \| 구현 검증 커밋 \|/, " 검증한 커밋 |") } { print }' "$SUMMARY_TPL" > "$sandbox/lt-one-commit.md"
awk "$LT"' s && /^\| 회차 / { sub(/ 결정 \|$/, "") } { print }' "$SUMMARY_TPL" > "$sandbox/lt-no-decision.md"
awk "$LT"' s && /^\| 1 / { next } { print }' "$SUMMARY_TPL" > "$sandbox/lt-no-row.md"
awk "$LT"' s && /^\| 1 / { sub(/ [^|]*\|$/, "") } { print }' "$SUMMARY_TPL" > "$sandbox/lt-row-cells.md"
assert_structure check_loop_table "$SUMMARY_TPL"                 pass "루프 기록 표: 실제 summary 템플릿 통과"
assert_structure check_loop_table "$sandbox/lt-no-section.md"    fail "루프 기록 표: 섹션 헤더 삭제 격추"
assert_structure check_loop_table "$sandbox/lt-late.md"          fail "루프 기록 표: 섹션의 Task별 수행 결과 뒤 이동 격추"
assert_structure check_loop_table "$sandbox/lt-one-commit.md"    fail "루프 기록 표: 검증 커밋 칸 합침 격추"
assert_structure check_loop_table "$sandbox/lt-no-decision.md"   fail "루프 기록 표: 결정 칸 삭제 격추"
assert_structure check_loop_table "$sandbox/lt-no-row.md"        fail "루프 기록 표: 회차 1 예시 행 삭제 격추"
assert_structure check_loop_table "$sandbox/lt-row-cells.md"     fail "루프 기록 표: 예시 행의 칸 소실 격추"
for p in '회차마다 한 줄을 적고 회차 1부터 적는다' '그 회차에 받지 않은 검증의 커밋 칸은 `-`로 둔다' '값이 있는 가장 최근 행' \
         '감사 종류와 리포트 머리말의 감사 회차(`계획 2차`, `최종 1차`)' '1단계 상태·2단계 상태·종합 판정·테스트 계획 줄 수' \
         '파일 이름은 적지 않는다' '`계획 검증`이나 `구현`' '`마무리`나 `다음 회차`' \
         '`(미커밋 포함)`이 있으면 diff로 가리지 않고 바뀐 것으로 본다'; do
  drop_literal "$SUMMARY_TPL" "$p" > "$sandbox/lt-drop.md"
  assert_structure check_loop_table "$sandbox/lt-drop.md" fail "루프 기록 표: 안내의 [${p}] 삭제 격추"
done
awk '{ if (/^### Task 1: /) { print "## 회차 1"; print "" } print }' "$TEMPLATE" > "$sandbox/ph-h2.md"
awk '{ if (/^### Task 1: /) { print "### 회차 1"; print "" } print }' "$TEMPLATE" > "$sandbox/ph-h3.md"
awk '{ sub(/^### Task 1: /, "### Task 1-1: "); print }' "$TEMPLATE" > "$sandbox/ph-cycle-id.md"
assert_structure check_plan_heads "$TEMPLATE"               pass "루프 기록 표: 실제 plan 템플릿의 Task 헤더 통과"
assert_structure check_plan_heads "$sandbox/ph-h2.md"       fail "루프 기록 표: plan의 회차 묶음 제목(##) 추가 격추"
assert_structure check_plan_heads "$sandbox/ph-h3.md"       fail "루프 기록 표: plan의 회차 묶음 제목(###) 추가 격추"
assert_structure check_plan_heads "$sandbox/ph-cycle-id.md" fail "루프 기록 표: plan의 회차별 Task 번호 격추"

# check_kind_table <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_kind_table() {
  awk '
    function flush() {
      if (t == "") return
      if (gen) { if (ts != 1 || fx != 1) print "일반 Task의 테스트·대응 발견 필드 " ts + 0 "/" fx + 0 " (기대 1/1): " t }
      else if (ts || fx) print "고정 Task에 테스트·대응 발견 필드: " t
    }
    /^## / { sec = $0 }
    /^## 루프 기록$/ { loop_at = NR }
    /^## 종류별 발견$/ { k++; k_at = NR }
    /^## Task별 수행 결과$/ { task_at = NR }
    sec == "## 종류별 발견" {
      if (index($0, "발견이 없으면 이 섹션을 두지 않는다")) g1++
      if (index($0, "한 행에 한 종류의 한 회차를 적는다")) g2++
      if (index($0, "회차 번호가 이어진 두 행")) g3++
    }
    /^### Task / { flush(); t = $0; gen = ($0 ~ /^### Task [0-9]+: /); ts = fx = 0 }
    /<!--/ && !/-->/ { c = 1 }
    c { if (/-->/) c = 0; next }
    sec == "## 종류별 발견" && /^\|/ {
      tl++; r = $0; n = gsub(/\|/, "|", r) - 1
      if (tl == 1 && $0 != "| 종류 | 발견 | 회차 | 고친 Task |") print "종류별 발견 표 머리가 다름: " $0
      if (n != 4) print "종류별 발견 표 행의 칸 수가 4가 아님: " $0
    }
    t != "" && /^- \*\*테스트\*\*:/ { ts++ }
    t != "" && /^- \*\*대응 발견\*\*:/ { fx++ }
    END {
      flush()
      if (k != 1) print "종류별 발견 헤더 " k + 0 "개 (기대 1개)"
      else if (!(loop_at && loop_at < k_at && k_at < task_at)) print "종류별 발견 섹션이 루프 기록과 Task별 수행 결과 사이가 아님"
      if (tl < 3) print "종류별 발견 표에 머리·구분선·예시 행이 없음 (" tl + 0 "행)"
      if (g1 != 1 || g2 != 1 || g3 != 1) print "종류별 발견 안내 " g1 + 0 g2 + 0 g3 + 0 " (기대 111)"
    }' "$1"
}

KT='/^## / { s = ($0 == "## 종류별 발견") }'
awk '!/^## 종류별 발견$/' "$SUMMARY_TPL" > "$sandbox/kt-no-section.md"
awk "$KT"' s && /^\| 종류 / { sub(/ 회차 \|/, "") } { print }' "$SUMMARY_TPL" > "$sandbox/kt-no-round.md"
awk "$KT"' s { buf = buf $0 "\n"; next } { print } END { print ""; printf "%s", buf }' "$SUMMARY_TPL" > "$sandbox/kt-late.md"
awk '/^### Task 1: /{s=1} /^### Task 2: /{s=0} s && /^- \*\*테스트\*\*:/ { next } { print }' "$SUMMARY_TPL" > "$sandbox/kt-no-test.md"
awk '/^### Task 2: /{s=1} /^### Task N/{s=0} s && /^- \*\*대응 발견\*\*:/ { next } { print }' "$SUMMARY_TPL" > "$sandbox/kt-no-fix.md"
awk '/^### Task 1: /{s=1} /^### Task 2: /{s=0} s && /^- \*\*테스트\*\*:/ { next } { print } /^### Task 2: /{d=1} d && /^- \*\*테스트\*\*:/ { print; d=0 }' \
  "$SUMMARY_TPL" > "$sandbox/kt-offset.md"
awk '{ print } /^### Task N/{s=1} s && /^- \*\*결과\*\*:/ { print "- **대응 발견**: -"; s=0 }' "$SUMMARY_TPL" > "$sandbox/kt-taskn.md"
assert_structure check_kind_table "$SUMMARY_TPL"              pass "발견 기록: 실제 summary 템플릿 통과"
assert_structure check_kind_table "$sandbox/kt-no-section.md" fail "발견 기록: 종류별 발견 헤더 삭제 격추"
assert_structure check_kind_table "$sandbox/kt-no-round.md"   fail "발견 기록: 회차 칸 삭제 격추"
assert_structure check_kind_table "$sandbox/kt-late.md"       fail "발견 기록: 섹션의 Task별 수행 결과 뒤 이동 격추"
assert_structure check_kind_table "$sandbox/kt-no-test.md"    fail "발견 기록: 일반 Task의 테스트 필드 삭제 격추"
assert_structure check_kind_table "$sandbox/kt-no-fix.md"     fail "발견 기록: 일반 Task의 대응 발견 필드 삭제 격추"
assert_structure check_kind_table "$sandbox/kt-offset.md"     fail "발견 기록: 블록 간 누락+중복 상쇄 격추"
assert_structure check_kind_table "$sandbox/kt-taskn.md"      fail "발견 기록: Task N의 대응 발견 필드 추가 격추"
for p in '발견이 없으면 이 섹션을 두지 않는다' '한 행에 한 종류의 한 회차를 적는다' '회차 번호가 이어진 두 행'; do
  drop_literal "$SUMMARY_TPL" "$p" > "$sandbox/kt-drop.md"
  assert_structure check_kind_table "$sandbox/kt-drop.md" fail "발견 기록: 안내의 [${p}] 삭제 격추"
done

# 한 회차만 돈 새 구조 예시 산출물. 변경 이력과 종류별 발견이 없다.
n_spec="$sandbox/n-spec.md"; n_plan="$sandbox/n-plan.md"; n_sum="$sandbox/n-summary.md"
cat > "$n_spec" <<'EOF'
# Issue #99 스펙 목록 정렬 옵션

## 목표 (Goal)

목록을 이름이나 날짜로 정렬해 볼 수 있다.

---

## 요구사항 (Requirements)

### 포함

- R1: 목록을 이름이나 날짜로 정렬한다.
- R2: 모르는 정렬 값은 오류로 끝난다.

### 제외

- 여러 열 정렬: 보류(쓰는 사람이 없다)

---

## 완료의 정의 (Definition of Done)

- [ ] AC1: 정렬 값으로 준 열의 순서대로 목록이 나온다. (R1)
- [ ] AC2: 모르는 정렬 값을 주면 종료 코드 2로 끝난다. (R2)

---

## 결정 사항 (Decisions)

- D1 같은 값의 순서: 입력 순서를 유지한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/40_domain/specs/list.md` | 목록 명세 |
EOF
cat > "$n_plan" <<'EOF'
# Issue #99 실행계획 목록 정렬 옵션

> 스펙: [issue-0099-spec.md](./issue-0099-spec.md)

---

## 계획 종료 게이트 (고정)

> **점검 질문**: 이 spec/plan만 보고 구현할 수 있는가?

- [x] 점검 완료

---

## 테스트 계획

| AC | 레벨 | 층 | 테스트 | 단위로 못 보는 이유 | 확인 |
|----|------|----|--------|---------------------|------|
| AC1 | [D] | 단위 | sort_test: 이름순, 날짜순 | - | 최종 1차 |
| AC2 | [D] | 통합 | cli_test: 모르는 값 | 종료 코드는 실행해야 보인다 | 최종 1차 |

---

## Tasks

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- [x] 완료
- **목표**: 전제를 확인한다.

---

### Task 1: 정렬 함수

- [x] 완료
- **목표**: 정렬 함수를 만든다.
- **대상 요구사항**: R1
- **테스트 먼저**:
  - sort_test: 이름순, 날짜순
  - **실패 확인**: 러너에서 2건 실패를 보고 테스트 커밋을 만든다.
- **구현**:
  1. 정렬 함수를 더한다.
  - **통과 확인**: 러너 0 실패를 보고 구현 커밋을 만든다.

---

### Task 2: 명령 인자

- [x] 완료
- **목표**: 정렬 인자를 읽는다.
- **대상 요구사항**: R2
- **테스트 먼저**:
  - cli_test: 모르는 값
  - **실패 확인**: 러너에서 1건 실패를 보고 테스트 커밋을 만든다.
- **구현**:
  1. 인자를 더한다.
  - **통과 확인**: 러너 0 실패를 보고 구현 커밋을 만든다.

---

### Task N (고정): 마무리

- [ ] 완료
- **목표**: 문서와 이슈 기록을 정리하고 PR을 만든다.
EOF
cat > "$n_sum" <<'EOF'
# Issue #99 실행요약 목록 정렬 옵션

## 다음 작업

> ▶️ 다음 작업: Task N (마무리)

## 모델 기록

| 구분 | 모델 | effort |
|------|------|--------|
| 계획 모델 | Anthropic, Claude Opus 5 (claude-opus-5) | high |
| 계획 audit 모델 | 생략 | 생략 |
| 구현 모델 | Anthropic, Claude Opus 5 (claude-opus-5) | high |
| 최종 audit 모델 | OpenAI, GPT-6 (gpt-6-astra) | high |

- **계획 감사**: 생략
- **이슈 본문 갱신**: 대상 아님

---

## 루프 기록

| 회차 | 바뀐 것 | 다시 시작한 단계 | 계획 검증 커밋 | 구현 검증 커밋 | 검증 결과 | 결정 |
|------|---------|------------------|----------------|----------------|-----------|------|
| 1 | spec·plan 작성, Task 1~2 | - | - | `abc1234` | 최종 1차: 1단계 충족, 2단계 통과, 종합 적합, 테스트 계획 2/2줄 | 마무리 |

---

## Task별 수행 결과

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5 (claude-opus-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: 전제 누락 없음
- **특이 사항**:

---

### Task 1: 정렬 함수

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5 (claude-opus-5)
- **수행 effort**: high
- **audit 발견**: 2건
- **보정 반영**: 1건
- **재시도**: 1회
- **테스트**: `aaa1111`에서 2건 실패
- **대응 발견**: F-9
- **수행 내용 요약**: 정렬 함수를 더했다.
- **특이 사항**:

---

### Task 2: 명령 인자

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5 (claude-opus-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **테스트**: `bbb2222`에서 1건 실패
- **대응 발견**: -
- **수행 내용 요약**: 인자를 더했다.
- **특이 사항**:

---

### Task N (고정): 마무리

- **결과**: <!-- 완료 / 부분 완료 / 스킵 -->
- **수행 내용 요약**:
- **특이 사항**:
EOF

# 새 구조 fixture: 두 스크립트와 Task N 게이트 명령이 새 구조 문서를 읽는다.
assert_clear pass "새 구조 fixture: check-clear --completion의 plan 통과" --completion "$n_plan"
awk '/^### Task 2: /{s=1} s && /^- \[x\] 완료$/ { print "- [ ] 완료"; s=0; next } { print }' "$n_plan" > "$sandbox/n-plan-open.md"
assert_clear fail "새 구조 fixture: check-clear --completion의 일반 Task 미완료 plan 격추" --completion "$sandbox/n-plan-open.md"
n_out="$("$METRICS" "$n_sum" 2>&1)"
[ "$n_out" = "$(printf 'audit 발견: 2건\n보정 반영: 1건\n재시도: 1회\n보정률: 1/2')" ] \
  && ok "새 구조 fixture: summarize-metrics의 summary 통과 (새 필드는 세지 않음)" \
  || ng "새 구조 fixture: summarize-metrics 출력이 다름 — [$(printf '%s' "$n_out" | tr '\n' ' ')]"
# assert_n_metrics_fail <설명> <사유> <awk 프로그램>
assert_n_metrics_fail() {
  local out rc
  awk "$3" "$n_sum" > "$sandbox/n-sum-case.md"
  out="$("$METRICS" "$sandbox/n-sum-case.md" 2>&1)"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -qF -- "$2"; then ok "$1"; else ng "$1 (exit $rc, [$out])"; fi
}
assert_n_metrics_fail "새 구조 fixture: summarize-metrics의 재시도 필드 삭제 격추" "'재시도' 필드를" \
  '/^### Task 1: /{s=1} s && /^- \*\*재시도\*\*:/ { s=0; next } { print }'
assert_n_metrics_fail "새 구조 fixture: summarize-metrics의 마무리 블록 지표 격추" 'Task N 블록에' \
  '{ print } END { print "- **audit 발견**: 1건" }'
assert_pair_gate "$GATE0" "$n_plan" "$n_sum" pass "새 구조 fixture: Task 집합 게이트 통과"
assert_gate "$GATE1" "$n_sum" pass "새 구조 fixture: 결과 게이트 통과"
assert_gate "$GATE2" "$n_sum" pass "새 구조 fixture: 수행 모델 게이트 통과"
assert_pair_gate "$GATE0" "$plan_done" "$n_sum" fail "새 구조 fixture: Task 집합이 다른 plan 격추"

# 마무리 완료 검사: `--clear`가 Task N 의 한 단계라 Task N 의 미체크는 미완료로 세지 않는다.
# 격추 케이스는 어느 블록이 걸렸는지까지 본다.
assert_finish_fail() {
  local out rc
  out="$("$CLEAR" --completion "$2" 2>&1)"; rc=$?
  if [ "$rc" -eq 1 ] && [ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" = 1 ] && printf '%s\n' "$out" | grep -qF -- "$3"; then ok "$1"; else ng "$1 (exit $rc, [$out])"; fi
}
assert_clear pass "마무리 완료 검사: Task N만 열린 plan 통과" --completion "$n_plan"
awk '/^### Task N/{s=1} s && /^- \[ \] 완료$/ { print "- [x] 완료"; s=0; next } { print }' "$n_plan" > "$sandbox/n-plan-n-done.md"
assert_clear pass "마무리 완료 검사: Task N까지 체크한 plan 통과" --completion "$sandbox/n-plan-n-done.md"
awk '/^### Task 1: /{s=1} s && /^- \[x\] 완료$/ { print "- [ ] 완료"; s=0; next } { print }' "$n_plan" > "$sandbox/n-plan-1-open.md"
awk '/^### Task 0 /{s=1} s && /^- \[x\] 완료$/ { print "- [ ] 완료"; s=0; next } { print }' "$n_plan" > "$sandbox/n-plan-0-open.md"
awk '/^### Task N/{s=1} s && /^- \[ \] 완료$/ { s=0; next } { print }' "$n_plan" > "$sandbox/n-plan-n-nobox.md"
awk '{ print } /^### Task N/{s=1} s && /^- \[ \] 완료$/ { print; s=0 }' "$n_plan" > "$sandbox/n-plan-n-dup.md"
awk '{ sub(/^### Task 2: 명령 인자$/, "### Task Next: 명령 인자"); print }' "$sandbox/n-plan-open.md" > "$sandbox/n-plan-next.md"
assert_finish_fail "마무리 완료 검사: 일반 Task가 열린 plan 격추"             "$sandbox/n-plan-1-open.md" '미완료: Task 1: 정렬 함수'
assert_finish_fail "마무리 완료 검사: Task 0이 열린 plan 격추"                "$sandbox/n-plan-0-open.md" '미완료: Task 0 (고정)'
assert_finish_fail "마무리 완료 검사: Task N 블록에 체크박스가 없는 plan 격추" "$sandbox/n-plan-n-nobox.md" '완료 체크박스가 없습니다'
assert_finish_fail "마무리 완료 검사: Task N 블록에 체크박스가 두 개인 plan 격추" "$sandbox/n-plan-n-dup.md" '완료 체크박스가 2개입니다'
assert_finish_fail "마무리 완료 검사: Task N으로 시작하는 다른 이름의 Task가 열린 plan 격추" "$sandbox/n-plan-next.md" '미완료: Task Next'

# check_one_round <산출물> <템플릿> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 표 머리만 있는 표와 내용 없는 섹션을 센다. 섹션 제목과 표 머리가 템플릿에 있는 것인지도 봐
# fixture 가 템플릿과 따로 놀지 않게 한다. 내용은 하위 제목·구분선(---)·주석·빈 줄을 뺀 줄이다.
check_one_round() {
  awk '
    function tflush() { if (tl > 0 && tl < 3) print "행이 없는 표: " th; tl = 0 }
    function hflush(lv) { while (d > 0 && lvl[d] >= lv) { if (!has[d]) print "내용 없는 섹션: " name[d]; d-- } }
    NR == FNR { if (/^## /) oksec[$0] = 1; if (/^\|/ && !pt) okhead[$0] = 1; pt = /^\|/; next }
    /<!--/ && !/-->/ { c = 1 }
    c { if (/-->/) c = 0; next }
    /^#+ / {
      tflush(); l = index($0, " ") - 1
      if (l == 2 && !($0 in oksec)) print "템플릿에 없는 섹션: " $0
      if (l == 2 && ($0 == "## 변경 이력" || $0 == "## 종류별 발견")) print "한 회차 산출물에 없어야 할 섹션: " $0
      if (l > 1) { hflush(l); d++; lvl[d] = l; name[d] = $0; has[d] = 0 }
      next
    }
    /^\|/ { if (tl == 0) { th = $0; if (!($0 in okhead)) print "템플릿에 없는 표 머리: " $0 } tl++ }
    !/^\|/ { tflush() }
    /[^ \t]/ && !/^---$/ { for (i = 1; i <= d; i++) has[i] = 1 }
    END { tflush(); hflush(0) }
  ' "$2" "$1"
}
assert_round() {
  local out
  out="$(check_one_round "$2" "$3")"
  case "$1" in
    pass) if [ -z "$out" ]; then ok "$4 (위반 0건)"; else ng "$4 (기대 0건, 실제 [$out])"; fi ;;
    fail) if printf '%s\n' "$out" | grep -qF -- "$5"; then ok "$4 (위반 검출)"; else ng "$4 (기대 [$5], 실제 [$out])"; fi ;;
  esac
}
awk '{ print } /^\| 1 \| spec·plan/ { print ""; print "## 종류별 발견"; print ""; print "| 종류 | 발견 | 회차 | 고친 Task |"; print "|------|------|------|-----------|" }' \
  "$n_sum" > "$sandbox/or-sum-headonly.md"
awk '/^## 연관 문서$/ { print "## 변경 이력"; print "" } { print }' "$n_spec" > "$sandbox/or-spec-empty.md"
awk '/^## Tasks$/ { print "### 테스트로 못 보는 항목"; print ""; print "| AC | 레벨 | 누가 보나 | 이유 | 확인 |"; print "|----|------|-----------|------|------|"; print "" } { print }' \
  "$n_plan" > "$sandbox/or-plan-headonly.md"
awk '/^## 테스트 계획$/ { print "## 설계 결정"; print ""; print "---"; print "" } { print }' "$n_plan" > "$sandbox/or-plan-empty.md"
assert_round pass "$n_spec" "$SPEC_TPL"    "한 회차 산출물: 새 구조 예시 spec 통과"
assert_round pass "$n_plan" "$TEMPLATE"    "한 회차 산출물: 새 구조 예시 plan 통과"
assert_round pass "$n_sum"  "$SUMMARY_TPL" "한 회차 산출물: 새 구조 예시 summary 통과"
assert_round fail "$sandbox/or-sum-headonly.md"  "$SUMMARY_TPL" "한 회차 산출물: 표 머리만 있는 종류별 발견 격추" '행이 없는 표: | 종류'
assert_round fail "$sandbox/or-spec-empty.md"    "$SPEC_TPL"    "한 회차 산출물: 내용 없는 변경 이력 격추" '내용 없는 섹션: ## 변경 이력'
assert_round fail "$sandbox/or-plan-headonly.md" "$TEMPLATE"    "한 회차 산출물: 표 머리만 있는 못 보는 항목 격추" '행이 없는 표: | AC | 레벨 | 누가'
assert_round fail "$sandbox/or-plan-empty.md"    "$TEMPLATE"    "한 회차 산출물: 내용 없는 설계 결정 격추" '내용 없는 섹션: ## 설계 결정'

# check_finish_block <summary 템플릿> → Task N 블록의 헤더와 `--clear` 기록 안내 (0건이면 통과)
check_finish_block() {
  awk '/^### Task / { s = 0 } /^### Task N/ { s = 1; n++; if ($0 != "### Task N (고정): 마무리") print "Task N 헤더가 다름: " $0 }
       s && index($0, "`--clear`가 `결과`에 `완료`를, `수행 내용 요약`에 `PR 대기(git-pr로 생성)`를 적는다") { g++ }
       s && /^- \*\*/ { f = $0; sub(/^- \*\*/, "", f); sub(/\*\*:.*/, "", f); q = q f "|" }
       END { if (n != 1) print "Task N 블록 " n + 0 "개 (기대 1개)"
             if (g != 1) print "--clear 기록 안내 " g + 0 "개 (기대 1개)"
             if (q != "결과|수행 내용 요약|특이 사항|") print "Task N 필드 구성이 다름 [" q "]" }' "$1"
}
awk '{ sub(/^### Task N \(고정\): 마무리$/, "### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)"); print }' "$SUMMARY_TPL" > "$sandbox/fb-old.md"
drop_literal "$SUMMARY_TPL" '`PR 대기(git-pr로 생성)`' > "$sandbox/fb-no-pr.md"
assert_structure check_finish_block "$SUMMARY_TPL"          pass "summary 구조: 실제 템플릿 마무리 블록 통과"
assert_structure check_finish_block "$sandbox/fb-old.md"    fail "summary 구조: 옛 교차모델 감사 블록 되돌리기 격추"
assert_structure check_finish_block "$sandbox/fb-no-pr.md"  fail "summary 구조: 마무리 블록의 PR 대기 기록 안내 삭제 격추"

# 두 템플릿의 Task 헤더가 같아야 Task 집합 게이트가 새 이슈에서 통과한다.
diff <(grep -E '^### Task ' "$TEMPLATE") <(grep -E '^### Task ' "$SUMMARY_TPL") >/dev/null \
  && ok "summary 구조: plan 템플릿과 Task 헤더 집합 일치 통과" || ng "summary 구조: plan 템플릿과 Task 헤더 집합이 다름"

# --- 계획 수립과 계획 검증, 테스트 기대값 변경 (issue #145) --------------------------
#
# SKILL.md "새 이슈 시작 시"는 진행 루프의 계획 수립(1~4단계)과 계획 검증(5단계)이고, 변경 통제는
# 커밋한 테스트의 기대값 변경을 완화로 다룬다. 조항은 절·단계·항목 범위로 잘라 판정하므로
# 같은 문구가 다른 단계나 다른 항목에 있으면 세지 않는다.

# start_section <파일> → "새 이슈 시작 시" 절
start_section() { awk '/^## 새 이슈 시작 시$/ { f = 1; next } f && /^## / { exit } f' "$1"; }

# start_step <파일> <번호> → 그 번호 단계 (다음 들여쓰지 않은 행 전까지)
start_step() { start_section "$1" | awk -v n="$2. " 'index($0, n) == 1 { s = 1; print; next } s && /^[^[:space:]]/ { exit } s'; }

# start_32 <파일> → 3-2 범위
start_32() { awk '/^   - \*\*3-2\. 승인 후\*\*/ { s = 1 } s && /^4\. / { exit } s' "$1"; }

# item_block <행 머리> → 표준 입력에서 그 머리로 시작하는 행과 더 깊이 들여쓴 이어지는 줄
item_block() {
  awk -v l="$1" 'BEGIN { match(l, /^ */); d = RLENGTH }
    index($0, l) == 1 { s = 1; print; next }
    s { match($0, /^ */); if ($0 != "" && RLENGTH > d) print; else s = 0 }'
}

# need_all <내용> <자리 이름> <문구…> → 없는 문구를 한 줄씩 출력
need_all() {
  local c="$1" w="$2" p
  shift 2
  for p in "$@"; do printf '%s\n' "$c" | grep -qF -- "$p" || echo "${w}에 [$p] 없음"; done
}

# need_one <내용> <자리 이름> <행 머리> → 그 머리로 시작하는 행이 1개가 아니면 위반 1줄
need_one() {
  local n
  n="$(printf '%s\n' "$1" | awk -v l="$3" 'index($0, l) == 1 { n++ } END { print n + 0 }')"
  [ "$n" -eq 1 ] || echo "${2}의 [$3] 행 ${n}개 (기대 1개)"
}

# check_plan_build <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_plan_build() {
  local sec intro b p
  sec="$(start_section "$1")"
  [ "$(printf '%s\n' "$sec" | grep -oE '^[0-9]+\. ' | tr -d '. ' | tr '\n' '|')" = '1|2|3|4|5|6|' ] \
    || echo '새 이슈 시작 시 단계 번호가 1~6 아님'
  intro="$(printf '%s\n' "$sec" | awk '/^1\. / { exit } { print }')"
  need_all "$intro" '1단계 앞' '`## 진행 루프`의 다섯 단계 가운데 **계획 수립**(1~4단계)과 **계획 검증**(5단계)'
  need_one "$intro" '1단계 앞' '- **첫 회차의 계획 수립**: '
  need_one "$intro" '1단계 앞' '- **뒤 회차의 계획 수립**: '
  need_all "$(printf '%s\n' "$intro" | item_block '- **첫 회차의 계획 수립**: ')" '첫 회차 항목' 'spec·plan이 없으면 1단계부터 차례로 쓴다'
  b="$(printf '%s\n' "$intro" | item_block '- **뒤 회차의 계획 수립**: ')"
  need_all "$b" '뒤 회차 항목' '지난 회차의 결정을 반영해' '1~3단계를 다시 밟지 않는다'
  need_all "$(printf '%s\n' "$b" | item_block '  - **spec**: ')"    '뒤 회차 spec 항목' '요구사항·AC·결정이 바뀔 때만 고친다' '`변경 이력`'
  need_all "$(printf '%s\n' "$b" | item_block '  - **plan**: ')"    '뒤 회차 plan 항목' '발견을 고치는 Task를 Task N 앞에 다음 번호로 더한다'
  need_all "$(printf '%s\n' "$b" | item_block '  - **summary**: ')" '뒤 회차 summary 항목' '더한 Task의 블록'
  need_all "$(group_skill_31 "$1")" '3-1' '이슈 본문의 묶음 제목과 문장을 그대로 옮긴다'
  b="$(start_32 "$1")"
  for p in 'AC 옮기기' '결정 사항' '테스트 계획' '설계 결정' '테스트 층 표'; do need_one "$b" '3-2' "     - **${p}**: "; done
  need_all "$(printf '%s\n' "$b" | item_block '     - **결정 사항**: ')"   '3-2 결정 사항 항목' '이슈 본문의 `정한 것`' '사용자가 답한 `검토 필요`' '적을 결정이 없으면 섹션을 두지 않는다'
  need_all "$(printf '%s\n' "$b" | item_block '     - **테스트 계획**: ')" '3-2 테스트 계획 항목' 'AC마다' '단위 테스트를 먼저 고' '테스트로 못 보는 항목'
  need_all "$(printf '%s\n' "$b" | item_block '     - **설계 결정**: ')"   '3-2 설계 결정 항목' '필요할 때만'
  need_all "$(start_step "$1" 4)" '4단계' 'spec `## 결정 사항`이나 plan `## 설계 결정`' '발견이 없으면 체크만 한다'
  for p in '전제 (Assumptions)' '출처 AC' '출처 표기' '(AC 없음' '`[D]`/`[QD]`/`[ND]`로 정제' '### R<n>'; do
    printf '%s\n' "$sec" | grep -nF -- "$p" | sed "s/^/새 이슈 시작 시에 옛 구조 문구 남음: /" | cut -c1-80
  done
}

# check_plan_verify <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_plan_verify() {
  local st b got
  st="$(start_step "$1" 5)"
  need_all "$(printf '%s\n' "$st" | head -1)" '5단계 첫 행' '이슈에 한 번 묻'
  need_one "$st" '5단계' '   - **다시 받는 조건**: '
  need_one "$st" '5단계' '   - **바뀌었는지의 판별**: '
  b="$(printf '%s\n' "$st" | item_block '   - **다시 받는 조건**: ')"
  need_all "$(printf '%s\n' "$b" | head -1)" '다시 받는 조건' '수행으로 정한 이슈' '지난 계획 검증 뒤에' '하나라도 바뀌면' '조건은 이 셋이 전부다'
  got="$(printf '%s\n' "$b" | awk 'NR > 1 && /^ +- / { l = $0; sub(/^ +- /, "", l); sub(/: .*/, "", l); printf "%s|", l }')"
  [ "$got" = 'AC·요구사항|`설계 결정`|`테스트 계획`|' ] || echo "다시 받는 조건의 변경 목록 [$got]"
  need_all "$(printf '%s\n' "$b" | item_block '     - `테스트 계획`: ')" '테스트 계획 조건' '`확인` 칸만 바뀐 것은 변경으로 보지 않는다'
  need_all "$(printf '%s\n' "$st" | item_block '   - **바뀌었는지의 판별**: ')" '판별 항목' \
    'summary `루프 기록`' '`계획 검증 커밋` 칸에 값이 있는 가장 최근 행의 커밋 뒤 diff' \
    '`(미커밋 포함)`이 있으면 diff로 가리지 않고 바뀐 것으로 본다'
  need_all "$(printf '%s\n' "$st" | item_block '   - **수행**: ')" '수행 항목' '다시 받는 조건에 맞으면 계획 감사를 다시 받'
  need_all "$(printf '%s\n' "$st" | item_block '   - **건너뜀**: ')" '건너뜀 항목' '뒤 회차에서 다시 묻지 않는다'
  need_one "$st" '5단계' '   - **5단계 뒤의 변경**: '
  need_all "$(printf '%s\n' "$st" | item_block '   - **5단계 뒤의 변경**: ')" '5단계 뒤의 변경 항목' \
    '6단계나 구현 시작 게이트에서 다시 받는 조건에 맞는 변경이 생기면' '일반 Task를 시작하기 전에 계획 감사를 다시 받는다' \
    '건너뛰기로 정한 이슈와 조건에 맞지 않는 변경은 그대로 진행한다'
  need_all "$(start_step "$1" 6 | item_block '   - **기록**: ')" '6단계 기록 항목' '5단계의 `5단계 뒤의 변경`을 확인한 뒤 Task 0으로 진행한다'
  need_all "$(awk '/^## 작업 진행 중$/ { w = 1; next } w && /^## / { exit } w' "$1" | item_block '- 구현 착수 전 **Task 0')" 'Task 0 항목' '"새 이슈 시작 시" 5단계의 `5단계 뒤의 변경`을 확인한 뒤 구현을 시작한다'
}

# check_plan_skip <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_plan_skip() {
  local st
  st="$(start_step "$1" 5)"
  need_one "$st" '5단계' '   - **다시 받지 않는 변경**: '
  need_all "$(printf '%s\n' "$st" | item_block '   - **다시 받지 않는 변경**: ')" '다시 받지 않는 변경 항목' \
    '기존 AC 안에서 발견을 고치는 Task를 더한 것만으로는 다시 받지 않는다'
  printf '%s\n' "$st" | item_block '   - **다시 받는 조건**: ' | grep -F '발견을 고치는 Task' | sed 's/^/다시 받는 조건에 Task 추가가 있음: /'
}

# control_block <파일> → `## 작업 진행 중`의 변경 통제 항목
control_block() { awk '/^## 작업 진행 중$/ { w = 1; next } w && /^## / { exit } w' "$1" | item_block '- **변경 통제**: '; }

# check_expect_relax <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_expect_relax() {
  local b k
  b="$(control_block "$1")"
  if [ -z "$b" ]; then echo '작업 진행 중의 변경 통제 항목 없음'; return; fi
  need_all "$(printf '%s\n' "$b" | head -1)" '변경 통제 첫 행' '커밋한 테스트를 바꾸는 변경'
  need_one "$b" '변경 통제' '  - **완화**: '
  need_one "$b" '변경 통제' '  - **테스트 수정**: '
  need_one "$b" '변경 통제' '  - **기록**: '
  need_all "$(printf '%s\n' "$b" | item_block '  - **완화**: ')" '완화 항목' \
    '커밋한 테스트의 기대값을 바꾸거나 단언을 줄이거나 테스트를 지우는 변경도 완화다' '기대값이 처음부터 틀렸던 경우도 같다' '재승인 없이 반영하지 않는다'
  need_all "$(printf '%s\n' "$b" | item_block '  - **테스트 수정**: ')" '테스트 수정 항목' \
    '결과는 그대로이고' '이름·위치·준비 코드·호출 방식만 바뀌는' '질의 없이 반영한다'
  need_all "$(printf '%s\n' "$b" | item_block '  - **기록**: ')" '기록 항목' '승인 뒤에 바뀐 요구사항·AC·결정' 'spec `변경 이력`에 적는다'
  for k in 구체화 확장 '테스트 수정'; do
    printf '%s\n' "$b" | item_block "  - **${k}**: " | grep -qF '기대값' && echo "${k} 항목이 기대값 변경을 다룸"
  done
  return 0
}

# drop_cases <검사 함수> <라벨> <문구…> → 문구마다 지운 사본을 격추한다
drop_cases() {
  local fn="$1" l="$2" p
  shift 2
  for p in "$@"; do
    drop_literal "$SKILL" "$p" > "$sandbox/dc.md"
    assert_structure "$fn" "$sandbox/dc.md" fail "${l}: [${p}] 삭제 격추"
  done
}

# move_item <행 머리> <붙일 행 머리> → 그 항목(이어지는 줄 포함)을 붙일 행 앞으로 옮긴 SKILL.md 사본
move_item() {
  local blk
  blk="$(item_block "$1" < "$SKILL")"
  MV_BLK="$blk" awk -v l="$1" -v to="$2" 'BEGIN { match(l, /^ */); d = RLENGTH }
    index($0, l) == 1 { s = 1; next }
    s { match($0, /^ */); if ($0 != "" && RLENGTH > d) next; s = 0 }
    index($0, to) == 1 && !done { print ENVIRON["MV_BLK"]; done = 1 }
    { print }' "$SKILL"
}

assert_structure check_plan_build "$SKILL" pass "계획 수립 단계: 실제 SKILL.md 통과"
drop_cases check_plan_build '계획 수립 단계' \
  '`## 진행 루프`의 다섯 단계 가운데' 'spec·plan이 없으면 1단계부터 차례로 쓴다' '지난 회차의 결정을 반영해' '1~3단계를 다시 밟지 않는다' \
  '요구사항·AC·결정이 바뀔 때만 고친다' '발견을 고치는 Task를 Task N 앞에 다음 번호로 더한다' '더한 Task의 블록' \
  '이슈 본문의 묶음 제목과 문장을 그대로 옮긴다' '이슈 본문의 `정한 것`' '사용자가 답한 `검토 필요`' '적을 결정이 없으면 섹션을 두지 않는다' \
  '     - **테스트 계획**: ' '     - **설계 결정**: ' '단위 테스트를 먼저 고' '필요할 때만' \
  'spec `## 결정 사항`이나 plan `## 설계 결정`' '발견이 없으면 체크만 한다'
move_item '- **뒤 회차의 계획 수립**: ' '## 작업 진행 중' > "$sandbox/pb-later-out.md"
move_item '     - **결정 사항**: ' '5. ' > "$sandbox/pb-dec-step4.md"
awk '/^4\. / { sub(/spec `## 결정 사항`이나 plan `## 설계 결정`/, "spec `## 전제 (Assumptions)`") } { print }' "$SKILL" > "$sandbox/pb-old-premise.md"
awk '{ print } /^     - \*\*AC 옮기기\*\*: / { print "       - **출처 표기**: 항목마다 출처 AC를 표기한다." }' "$SKILL" > "$sandbox/pb-old-source.md"
awk '{ print } /^     - \*\*AC 옮기기\*\*: / { print "       - AC가 대응하지 않는 R의 항목은 `(AC 없음: <사유>)`로 적는다." }' "$SKILL" > "$sandbox/pb-old-none.md"
awk '/^## 새 이슈 시작 시$/ { f = 1 } f && /^6\. / { sub(/^6\. /, "7. "); f = 0 } { print }' "$SKILL" > "$sandbox/pb-renumber.md"
assert_structure check_plan_build "$sandbox/pb-later-out.md"   fail "계획 수립 단계: 뒤 회차 항목의 절 밖 이동 격추"
assert_structure check_plan_build "$sandbox/pb-dec-step4.md"   fail "계획 수립 단계: 결정 사항 항목의 4단계 이동 격추"
assert_structure check_plan_build "$sandbox/pb-old-premise.md" fail "계획 수립 단계: 4단계의 옛 전제 섹션 되돌리기 격추"
assert_structure check_plan_build "$sandbox/pb-old-source.md"  fail "계획 수립 단계: 옛 출처 표기 규칙 되돌리기 격추"
assert_structure check_plan_build "$sandbox/pb-old-none.md"    fail "계획 수립 단계: 옛 AC 없음 표기 되돌리기 격추"
assert_structure check_plan_build "$sandbox/pb-renumber.md"    fail "계획 수립 단계: 단계 번호 변경 격추"

assert_structure check_plan_verify "$SKILL" pass "계획 검증 조건: 실제 SKILL.md 통과"
drop_cases check_plan_verify '계획 검증 조건' \
  '이슈에 한 번 묻' '수행으로 정한 이슈' '지난 계획 검증 뒤에' '하나라도 바뀌면' '조건은 이 셋이 전부다' \
  '`확인` 칸만 바뀐 것은 변경으로 보지 않는다' '`계획 검증 커밋` 칸에 값이 있는 가장 최근 행의 커밋 뒤 diff' \
  '`(미커밋 포함)`이 있으면 diff로 가리지 않고 바뀐 것으로 본다' \
  '다시 받는 조건에 맞으면 계획 감사를 다시 받' '뒤 회차에서 다시 묻지 않는다' \
  '   - **5단계 뒤의 변경**: ' '6단계나 구현 시작 게이트에서 다시 받는 조건에 맞는 변경이 생기면' '일반 Task를 시작하기 전에 계획 감사를 다시 받는다' \
  '건너뛰기로 정한 이슈와 조건에 맞지 않는 변경은 그대로 진행한다' '5단계의 `5단계 뒤의 변경`을 확인한 뒤 Task 0으로 진행한다' \
  '"새 이슈 시작 시" 5단계의 `5단계 뒤의 변경`을 확인한 뒤 구현을 시작한다'
for p in '     - AC·요구사항: ' '     - `설계 결정`: ' '     - `테스트 계획`: '; do
  awk -v l="$p" 'index($0, l) != 1' "$SKILL" > "$sandbox/pv-no.md"
  assert_structure check_plan_verify "$sandbox/pv-no.md" fail "계획 검증 조건: 변경 목록의 [${p#     - }] 행 삭제 격추"
done
awk '{ print } /^     - `테스트 계획`: / { print "     - plan Task: Task가 더해졌다." }' "$SKILL" > "$sandbox/pv-extra.md"
move_item '   - **다시 받는 조건**: ' '5. ' > "$sandbox/pv-step4.md"
move_item '   - **바뀌었는지의 판별**: ' '> 게이트 2건' > "$sandbox/pv-step6.md"
assert_structure check_plan_verify "$sandbox/pv-extra.md" fail "계획 검증 조건: 변경 목록에 네 번째 조건 추가 격추"
assert_structure check_plan_verify "$sandbox/pv-step4.md" fail "계획 검증 조건: 다시 받는 조건의 4단계 이동 격추"
assert_structure check_plan_verify "$sandbox/pv-step6.md" fail "계획 검증 조건: 판별 항목의 6단계 이동 격추"
# 미커밋 감사의 판별(issue #145 최종 감사 2차 F-7) — 한쪽 판별 항목에만 남은 사본은 다른 쪽 검사에 걸린다.
DIRTY_RULE='`(미커밋 포함)`이 있으면 diff로 가리지 않고 바뀐 것으로 본다'
R="$DIRTY_RULE" awk 'index($0, "   - **바뀌었는지의 판별**: ") == 1 { i = index($0, ENVIRON["R"]); if (i) $0 = substr($0, 1, i - 1) substr($0, i + length(ENVIRON["R"])) } { print }' "$SKILL" > "$sandbox/pv-dirty.md"
assert_structure check_plan_verify "$sandbox/pv-dirty.md" fail "계획 검증 조건: 계획 검증 판별의 미커밋 규칙만 삭제 격추"

assert_structure check_plan_skip "$SKILL" pass "계획 검증 제외: 실제 SKILL.md 통과"
drop_cases check_plan_skip '계획 검증 제외' '   - **다시 받지 않는 변경**: ' '기존 AC 안에서' '발견을 고치는 Task를 더한 것만으로는 다시 받지 않는다'
awk '{ print } /^   - \*\*다시 받지 않는 변경\*\*: / { print }' "$SKILL" > "$sandbox/ps-dup.md"
move_item '   - **다시 받지 않는 변경**: ' '5. ' > "$sandbox/ps-step4.md"
awk '{ print } /^     - `테스트 계획`: / { print "     - plan Task: 발견을 고치는 Task가 더해졌다." }' "$SKILL" > "$sandbox/ps-in-cond.md"
assert_structure check_plan_skip "$sandbox/ps-dup.md"     fail "계획 검증 제외: 항목 중복 격추"
assert_structure check_plan_skip "$sandbox/ps-step4.md"   fail "계획 검증 제외: 항목의 4단계 이동 격추"
assert_structure check_plan_skip "$sandbox/ps-in-cond.md" fail "계획 검증 제외: 다시 받는 조건에 Task 추가 넣기 격추"

assert_structure check_expect_relax "$SKILL" pass "기대값 완화: 실제 SKILL.md 변경 통제 통과"
drop_cases check_expect_relax '기대값 완화' \
  '커밋한 테스트를 바꾸는 변경' '커밋한 테스트의 기대값을 바꾸거나' '단언을 줄이거나' '테스트를 지우는' '기대값이 처음부터 틀렸던 경우도 같다' \
  '재승인 없이 반영하지 않는다' '  - **테스트 수정**: ' '결과는 그대로이고' '이름·위치·준비 코드·호출 방식만 바뀌는' \
  '  - **기록**: ' 'spec `변경 이력`에 적는다'
ER_TXT='커밋한 테스트의 기대값을 바꾸거나 단언을 줄이거나 테스트를 지우는 변경도 완화다.'
drop_literal "$SKILL" "$ER_TXT" | ER_TXT="$ER_TXT" awk '/^  - \*\*구체화\*\*: / { $0 = $0 " " ENVIRON["ER_TXT"] } { print }' > "$sandbox/er-refine.md"
awk '{ print } /^  - \*\*테스트 수정\*\*: / { print "  - **테스트 수정**: 기대값 변경도 질의 없이 반영한다." }' "$SKILL" > "$sandbox/er-dup.md"
awk '/^  - \*\*테스트 수정\*\*: / { sub(/호출 방식만 바뀌는/, "호출 방식이나 기대값만 바뀌는") } { print }' "$SKILL" > "$sandbox/er-soft.md"
move_item '  - **테스트 수정**: ' '## 이슈 완료 시' > "$sandbox/er-out.md"
assert_structure check_expect_relax "$sandbox/er-refine.md" fail "기대값 완화: 기대값 변경의 구체화 이동 격추"
assert_structure check_expect_relax "$sandbox/er-dup.md"    fail "기대값 완화: 테스트 수정 항목 중복 격추"
assert_structure check_expect_relax "$sandbox/er-soft.md"   fail "기대값 완화: 테스트 수정에 기대값 넣기 격추"
assert_structure check_expect_relax "$sandbox/er-out.md"    fail "기대값 완화: 테스트 수정 항목의 변경 통제 밖 이동 격추"

# --- 진행 루프 (issue #145) -------------------------------------------------------
#
# SKILL.md `## 진행 루프`는 다섯 단계와 돌아가는 길, 마무리, PR 뒤 피드백을 정하고 `--response`·`--clear`·
# "이슈 완료 시"가 그 절차를 따른다. 조항은 절·소제목·항목 범위로 잘라 판정하므로 같은 문구가 다른 자리에 있으면
# 세지 않는다. 다시 받는 조건·보이는 값·권장 기준처럼 닫힌 목록은 항목 이름을 전부 이어 붙여 견준다.

# loop_section <파일> → `## 진행 루프` 절
loop_section() { awk '/^## 진행 루프$/ { f = 1; next } f && /^## / { exit } f' "$1"; }

# loop_part <파일> <소제목> → 그 소제목의 본문 (소제목이 빈 값이면 첫 소제목 앞)
loop_part() { loop_section "$1" | awk -v h="$2" 'BEGIN { s = (h == "") } /^### / { if (s && h == "") exit; s = ($0 == "### " h); next } s'; }

# item_names → 표준 입력에서 첫 행을 뺀 하위 항목 이름(`: ` 앞)을 `|`로 이어 출력
item_names() { awk 'NR > 1 && /^ +- / { l = $0; sub(/^ +- /, "", l); sub(/: .*/, "", l); printf "%s|", l }'; }

# h2_section <파일> <제목> → `## <제목>` 절, opt_section <파일> <옵션> → `### `<옵션>`` 절
h2_section()  { awk -v h="## $2" '$0 == h { f = 1; next } f && /^## / { exit } f' "$1"; }
opt_section() { awk -v h="### \`$2\`" '$0 == h { f = 1; next } f && /^##/ { exit } f' "$1"; }

# opt_step <파일> <옵션> <번호> → 옵션 절의 그 번호 단계
opt_step() { opt_section "$1" "$2" | awk -v n="  $3. " 'index($0, n) == 1 { s = 1; print; next } s && (/^  [0-9]+\. / || /^[^[:space:]]/) { exit } s'; }

# check_loop_stages <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_loop_stages() {
  local got b
  got="$(grep -E '^## ' "$1" | sed 's/^## //' | tr '\n' '|')"
  case "$got" in
    *'|새 이슈 시작 시|진행 루프|작업 진행 중|'*) ;;
    *) echo "## 진행 루프의 자리가 새 이슈 시작 시와 작업 진행 중 사이가 아님" ;;
  esac
  got="$(grep -c '^## 진행 루프$' "$1")"
  [ "$got" -eq 1 ] || echo "## 진행 루프 제목 ${got}개 (기대 1개)"
  got="$(loop_section "$1" | grep -E '^### ' | sed 's/^### //' | tr '\n' '|')"
  [ "$got" = '계획 수립|계획 검증|구현|구현 검증|완료 확인|마무리|PR 뒤 피드백|' ] || echo "진행 루프의 소제목 [$got]"
  b="$(loop_part "$1" '')"
  need_all "$b" '진행 루프 첫머리' '**계획 수립 → 계획 검증 → 구현 → 구현 검증 → 완료 확인**의 다섯 단계를 이 순서로 지난다' \
    '계획 수립에서 완료 확인까지 한 번 지나는 것이 한 회차다'
  need_one "$b" '진행 루프 첫머리' '- **돌아가는 길**: '
  need_all "$(printf '%s\n' "$b" | item_block '- **돌아가는 길**: ')" '돌아가는 길' \
    '완료 확인에서 사용자가 `다음 회차`로 정하면 계획 수립으로 돌아간다' '`마무리`로 정하면 루프를 나가 Task N'
  need_all "$(printf '%s\n' "$b" | item_block '- **회차 기록**: ')" '회차 기록' 'summary `루프 기록`에 한 행을 더하고'
  need_all "$(printf '%s\n' "$b" | item_block '- **검증 기록**: ')" '검증 기록' \
    '`계획 검증 커밋`이나 `구현 검증 커밋` 칸에 감사 대상 커밋을' '감사 종류와 리포트 머리말의 감사 회차' \
    '리포트 머리말의 `감사 대상 커밋` 줄에서 옮기고' '`(미커밋 포함)`을 붙인다'
  need_one "$b" '진행 루프 첫머리' '- **감사 전 커밋**: '
  need_all "$(printf '%s\n' "$b" | item_block '- **감사 전 커밋**: ')" '감사 전 커밋' \
    '감사를 받기 전에 감사 대상(계획 감사는 spec·plan, 교차 감사는 구현과 spec·plan)에 미커밋 변경이 있으면 커밋할지 사용자에게 묻는다' \
    '커밋한 대상으로 다시 받을 때까지 바뀐 것으로 본다는 사실을 함께 알린다'
  b="$(loop_part "$1" '계획 수립')"
  need_all "$b" '계획 수립' 'spec·plan이 없으면 쓰고, 지난 회차에서 바꿀 것이 나왔으면 고친다' '"새 이슈 시작 시" 1~4단계'
  need_all "$(printf '%s\n' "$b" | item_block '- **발견을 고치는 Task**: ')" '발견을 고치는 Task' \
    '`--response`에서 반영으로 정한 발견을 plan에 Task로 더한다'
  need_all "$(loop_part "$1" '계획 검증')" '계획 검증' '"새 이슈 시작 시" 5단계' '조건에 맞지 않으면 구현으로 간다'
  b="$(loop_part "$1" '구현')"
  need_one "$b" '구현' '- **테스트 먼저**: '
  need_one "$b" '구현' '- **테스트를 먼저 쓰지 않는 Task**: '
  need_all "$(printf '%s\n' "$b" | item_block '- **테스트 먼저**: ')" '테스트 먼저' \
    '테스트 작성 → 실패 확인 → 테스트 커밋 → 구현 → 통과 확인 → 구현 커밋 순서로 진행한다' '재현 테스트'
  b="$(printf '%s\n' "$b" | item_block '- **테스트를 먼저 쓰지 않는 Task**: ')"
  need_all "$b" '테스트를 먼저 쓰지 않는 Task' '동작을 바꾸지 않는 Task' '구현 → 통과 확인 두 단계' '통과 확인은 기존 테스트 전체 통과' \
    '러너도 결정적 명령도 없는 repo만 통과 확인을 건너뛴다' '먼저 쓰지 않는 이유를 한 줄'
  got="$(printf '%s\n' "$b" | awk 'NR > 1 && /^  - / { sub(/^  - /, ""); printf "%s|", $0 }')"
  [ "$got" = '문서만 고치는 Task|자동 테스트가 보지 못하는 화면 배치|버릴 코드를 쓰는 스파이크|기존 테스트가 그대로 통과해야 하는 리팩터링|' ] \
    || echo "테스트를 먼저 쓰지 않는 Task의 기준 목록 [$got]"
}

# check_impl_verify <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_impl_verify() {
  local b c got p
  b="$(loop_part "$1" '구현 검증')"
  for p in '감사 실행' '바뀌었는지의 판별' '검토'; do need_one "$b" '구현 검증' "- **${p}**: "; done
  need_all "$(printf '%s\n' "$b" | item_block '- **감사 실행**: ')" '감사 실행' \
    '지난 검증 뒤에 구현이 바뀌었으면' '교차 감사를 전체로 다시 받는다' '사용자가 구현 모델과 **다른 벤더 모델**' '직접 실행' \
    '고친 발견의 위험도에 따른 예외는 없다' '구현 AI는 감사를 실행하지 않는다' '스펙 위반·누락·소스코드와의 모순'
  c="$(printf '%s\n' "$b" | item_block '- **바뀌었는지의 판별**: ')"
  need_all "$(printf '%s\n' "$c" | head -1)" '판별 첫 행' '`구현 검증 커밋` 칸에 값이 있는 가장 최근 행의 커밋 뒤 diff' \
    '하나라도 맞으면 바뀐 것' '조건은 이 넷이 전부다' '값이 있는 행이 없으면 받는다' '문서만 고친 회차도' \
    '`(미커밋 포함)`이 있으면 diff로 가리지 않고 바뀐 것으로 본다'
  got="$(printf '%s\n' "$c" | item_names)"
  [ "$got" = '제외 경로 밖|제외 경로 안의 산출물|`테스트 계획`의 줄|AC와 결정|' ] || echo "구현이 바뀐 조건 목록 [$got]"
  need_all "$(printf '%s\n' "$c" | item_block '  - 제외 경로 밖: ')" '제외 경로 밖' \
    '`.ai/90_issues/`' '`.ai/99_workspace/`' '`.ai/70_ledger/`' 'plan Task N이 마무리로 적은 문서'
  need_all "$(printf '%s\n' "$c" | item_block '  - 제외 경로 안의 산출물: ')" '제외 경로 안의 산출물' 'plan 일반 Task가 고친다고 적은 파일'
  need_all "$(printf '%s\n' "$c" | item_block '  - `테스트 계획`의 줄: ')" '테스트 계획의 줄' \
    '`[D]`·`[QD]` 줄이 더해졌거나' '`확인` 외 칸이 바뀌었다' '`확인` 칸만 바뀐 것과 `[ND]` 줄의 변경은 세지 않는다'
  need_all "$(printf '%s\n' "$c" | item_block '  - AC와 결정: ')" 'AC와 결정' \
    'spec 완료의 정의의 AC나 `결정 사항`의 결정이 더해졌거나 문장이 바뀌었다' '체크박스만 바뀐 것은 세지 않는다'
  need_all "$(printf '%s\n' "$b" | item_block '- **검토**: ')" '검토' '`--response`'
  need_all "$(h2_section "$1" '관련 skill' | item_block '- issue-audit (권장): ')" '관련 skill의 issue-audit' \
    '구현 검증' '**구현 AI는 감사를 실행하지 않습니다.**'
  for p in '교차모델 검증으로 고정' 'Task N(교차모델 audit)' 'Task N 교차모델' '마지막 고정 Task(교차모델'; do
    grep -nF -- "$p" "$1" | sed 's/^/Task N에서 교차 감사를 받는 옛 문구 남음: /' | cut -c1-90
  done
}

# check_done_check <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_done_check() {
  local b c got p
  b="$(loop_part "$1" '완료 확인')"
  for p in '보이는 값' '확인 칸' '권장' '결정' '기준에 못 미친 마무리'; do need_one "$b" '완료 확인' "- **${p}**: "; done
  c="$(printf '%s\n' "$b" | item_block '- **보이는 값**: ')"
  need_all "$c" '보이는 값' '마지막 교차 감사 리포트' '새 판정 값을 만들지 않는다' '두 표에서 `확인` 칸이 채워진 줄 수'
  got="$(printf '%s\n' "$c" | item_names)"
  [ "$got" = '1단계 상태|2단계 상태|종합 판정|확인한 줄 수|' ] || echo "보이는 값 목록 [$got]"
  c="$(printf '%s\n' "$b" | item_block '- **권장**: ')"
  need_all "$(printf '%s\n' "$c" | head -1)" '권장 첫 행' '네 가지가 모두 맞으면 `마무리`, 그 밖은 `다음 회차`를 권장한다'
  got="$(printf '%s\n' "$c" | item_names)"
  [ "$got" = '1단계 상태|2단계 상태|확인한 줄 수|반영으로 정한 발견|' ] || echo "권장 기준 목록 [$got]"
  need_one "$c" '권장' '  - 1단계 상태: 충족(PASS)이다.'
  need_one "$c" '권장' '  - 2단계 상태: 통과(PASS)나 주의(WARN)다.'
  need_one "$c" '권장' '  - 확인한 줄 수: `테스트 계획`의 모든 줄을 확인했다.'
  need_all "$(printf '%s\n' "$c" | item_block '  - 반영으로 정한 발견: ')" '반영으로 정한 발견' '모두 닫았다' '이관이나 보류로 정한 발견은 세지 않는다'
  c="$(printf '%s\n' "$b" | item_block '- **확인 칸**: ')"
  need_all "$c" '확인 칸' '충족으로 판정한 AC의 `[D]`·`[QD]` 줄에 그 감사 회차를 적' '감사 대상 커밋의 `테스트 계획`에 같은 내용으로 있던 줄에만' \
    '새 회차로 다시 적' '`확인`이 빈 `[ND]` 줄과 지난 확인 뒤에 구현이 바뀐 `[ND]` 줄은 사용자에게 보여 주고' '사용자가 확인하지 않은 줄은 비워 둔다'
  need_all "$(printf '%s\n' "$b" | item_block '- **결정**: ')" '결정' '사용자가 정하고' '`결정` 칸에 적는다'
  need_all "$(printf '%s\n' "$b" | item_block '- **기준에 못 미친 마무리**: ')" '기준에 못 미친 마무리' \
    '남은 AC와 발견마다 완화·원장 등재·새 이슈 가운데 결정을 받는다'
}

# check_finish_entry <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_finish_entry() {
  local b c
  b="$(loop_part "$1" '마무리')"
  need_all "$b" '마무리' '사용자가 `마무리`로 정한 뒤에만 Task N에 들어간다' '교차 감사를 받지 않는다' \
    '전체 회귀, 색인, 충족 AC 체크, repo 고유 마무리, `--clear`, PR'
  need_one "$b" '마무리' '- **구현을 고칠 때**: '
  need_all "$(printf '%s\n' "$b" | item_block '- **구현을 고칠 때**: ')" '구현을 고칠 때' 'Task N에서 구현을 고치면 계획 수립으로 돌아간다' '체크한 AC의 체크를 지운다'
  b="$(opt_step "$1" --clear 1)"
  need_one "$b" '--clear 1단계' '     - **체크박스**: '
  need_one "$b" '--clear 1단계' '     - **루프 기록의 결정**: '
  need_all "$(printf '%s\n' "$b" | item_block '     - **체크박스**: ')" '체크박스 검사' \
    '계획 종료 게이트 `점검 완료`, Task 0, 일반 Task' 'Task N의 미체크는 미완료로 세지 않는다' '`--clear`가 Task N의 한 단계'
  c="$(printf '%s\n' "$b" | item_block '     - **루프 기록의 결정**: ')"
  need_all "$c" '루프 기록의 결정 검사' 'summary `루프 기록` 마지막 행의 `결정`이 `마무리`인지 본다' \
    '결정 전이거나 `다음 회차`' '미완료 항목으로 보여 준다'
  need_all "$b" '--clear 1단계' '계속 진행할지 질의한다' '"$clear_check" --completion'
  b="$(opt_step "$1" --clear 4)"
  need_one "$b" '--clear 4단계' '     - **Task N 기록**: '
  need_all "$(printf '%s\n' "$b" | item_block '     - **Task N 기록**: ')" 'Task N 기록' \
    '1단계의 두 검사가 모두 통과' '이관 직전에 plan의 Task N 체크박스를 체크하고' '`결과`에 `완료`를' \
    '`수행 내용 요약`에 `PR 대기(git-pr로 생성)`를 적는다' '미완료를 안고 진행한 실행(중단·종료)에서는 체크하지 않는다'
  b="$(h2_section "$1" '이슈 완료 시' | awk '/^1\. / { s = 1 } /^2\. / { exit } s')"
  need_all "$b" '이슈 완료 시 1단계' 'Task N의 미체크는 미완료로 세지 않는다' \
    '최종 audit 모델("벤더, 모델명 (모델 ID)")이 summary `모델 기록` 표의 `최종 audit 모델` 행에 기록'
  b="$(opt_section "$1" --clear)"
  [ "$(printf '%s\n' "$b" | grep -oE '^  [0-9]+\. ' | tr -d '. ' | tr '\n' '|')" = '1|2|3|4|5|6|' ] || echo '--clear 단계 번호가 1~6 아님'
  need_all "$(printf '%s\n' "$b" | item_block '- **시점**: ')" '--clear 시점' 'PR을 만들기 직전'
}

# check_same_kind <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_same_kind() {
  local b
  b="$(loop_part "$1" '계획 수립')"
  need_one "$b" '계획 수립' '- **같은 종류의 발견**: '
  need_all "$(printf '%s\n' "$b" | item_block '- **같은 종류의 발견**: ')" '같은 종류의 발견' \
    'summary `종류별 발견`' '지난 두 회차에 이어서 나왔으면' 'plan `설계 결정`부터 고친다' '섹션이 없으면 이때 만든다'
  b="$(opt_step "$1" --response 3)"
  need_one "$b" '--response 3단계' '     - **종류**: '
  need_all "$(printf '%s\n' "$b" | item_block '     - **종류**: ')" '종류 칸' '`종류` 칸을 둔다' '이미 있는 이름을 그대로 쓴다'
  b="$(opt_step "$1" --response 5)"
  need_one "$b" '--response 5단계' '     - **종류 기록**: '
  need_all "$(printf '%s\n' "$b" | item_block '     - **종류 기록**: ')" '종류 기록' 'summary `종류별 발견`에 적는다' '루프 회차 번호'
}

# check_pr_feedback <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_pr_feedback() {
  local b
  need_all "$(loop_part "$1" '마무리')" '마무리' 'PR은 Task N에서 git-pr로 만든다'
  b="$(loop_part "$1" 'PR 뒤 피드백')"
  need_all "$b" 'PR 뒤 피드백' '리뷰 피드백은 git-pr-feedback으로 처리한다' \
    '구현을 고쳤을 때 교차 감사를 다시 받을지는 사용자가 고른다' 'PR을 만든 뒤에는 이슈 문서를 고치지 않는다'
}

# swap_parts <소제목 A> <소제목 B> → 두 소제목 이름을 바꾼 SKILL.md 사본
swap_parts() { awk -v a="### $1" -v b="### $2" '/^## / { f = ($0 == "## 진행 루프") } f && $0 == a { print b; next } f && $0 == b { print a; next } { print }' "$SKILL"; }

# drop_row <행 머리> → 그 머리로 시작하는 행을 지운 SKILL.md 사본
drop_row() { awk -v l="$1" 'index($0, l) != 1' "$SKILL"; }

# add_after <행 머리> <더할 행> → 그 머리로 시작하는 행 뒤에 한 행을 더한 SKILL.md 사본
add_after() { ADD="$2" awk -v l="$1" '{ print } index($0, l) == 1 { print ENVIRON["ADD"] }' "$SKILL"; }

assert_structure check_loop_stages "$SKILL" pass "루프 다섯 단계: 실제 SKILL.md 통과"
drop_cases check_loop_stages '루프 다섯 단계' \
  '**계획 수립 → 계획 검증 → 구현 → 구현 검증 → 완료 확인**의 다섯 단계를 이 순서로 지난다' '계획 수립에서 완료 확인까지 한 번 지나는 것이 한 회차다' \
  '완료 확인에서 사용자가 `다음 회차`로 정하면 계획 수립으로 돌아간다' '`마무리`로 정하면 루프를 나가 Task N' \
  'summary `루프 기록`에 한 행을 더하고' '`계획 검증 커밋`이나 `구현 검증 커밋` 칸에 감사 대상 커밋을' '감사 종류와 리포트 머리말의 감사 회차' \
  '리포트 머리말의 `감사 대상 커밋` 줄에서 옮기고' '`(미커밋 포함)`을 붙인다' \
  '- **감사 전 커밋**: ' '계획 감사는 spec·plan, 교차 감사는 구현과 spec·plan' '미커밋 변경이 있으면 커밋할지 사용자에게 묻는다' \
  '커밋한 대상으로 다시 받을 때까지 바뀐 것으로 본다는 사실을 함께 알린다' \
  'spec·plan이 없으면 쓰고, 지난 회차에서 바꿀 것이 나왔으면 고친다' '`--response`에서 반영으로 정한 발견을 plan에 Task로 더한다' \
  '조건에 맞지 않으면 구현으로 간다' '테스트 작성 → 실패 확인 → 테스트 커밋' '→ 구현 커밋 순서로 진행한다' '재현 테스트' \
  '동작을 바꾸지 않는 Task' '확인 두 단계' '확인은 기존 테스트 전체' '러너도 결정적 명령도 없는 repo만' '먼저 쓰지 않는 이유를 한 줄'
for p in '계획 수립' '계획 검증' '구현' '구현 검증' '완료 확인'; do
  awk -v h="### $p" '$0 != h' "$SKILL" > "$sandbox/lp-no.md"
  assert_structure check_loop_stages "$sandbox/lp-no.md" fail "루프 다섯 단계: 소제목 [$p] 삭제 격추"
done
swap_parts '구현' '구현 검증' > "$sandbox/lp-swap.md"
drop_row '## 진행 루프' > "$sandbox/lp-no-h2.md"
awk '/^## 진행 루프$/ { s = 1 } s && /^## 작업 진행 중$/ { s = 0 } s { buf = buf $0 "\n"; next } /^## 이슈 완료 시$/ { printf "%s", buf } { print }' "$SKILL" > "$sandbox/lp-moved.md"
drop_row '  - 버릴 코드를 쓰는 스파이크' > "$sandbox/lp-no-spike.md"
add_after '  - 버릴 코드를 쓰는 스파이크' '  - 급한 수정' > "$sandbox/lp-extra.md"
assert_structure check_loop_stages "$sandbox/lp-swap.md"     fail "루프 다섯 단계: 구현과 구현 검증의 순서 바꾸기 격추"
assert_structure check_loop_stages "$sandbox/lp-no-h2.md"    fail "루프 다섯 단계: 절 제목 삭제 격추"
assert_structure check_loop_stages "$sandbox/lp-moved.md"    fail "루프 다섯 단계: 절의 작업 진행 중 뒤 이동 격추"
assert_structure check_loop_stages "$sandbox/lp-no-spike.md" fail "루프 다섯 단계: 테스트를 먼저 쓰지 않는 기준 한 줄 삭제 격추"
assert_structure check_loop_stages "$sandbox/lp-extra.md"    fail "루프 다섯 단계: 테스트를 먼저 쓰지 않는 기준 추가 격추"
move_item '- **감사 전 커밋**: ' '### 완료 확인' > "$sandbox/lp-commit-moved.md"
assert_structure check_loop_stages "$sandbox/lp-commit-moved.md" fail "루프 다섯 단계: 감사 전 커밋 항목의 구현 검증 이동 격추"

assert_structure check_impl_verify "$SKILL" pass "구현 검증 단계: 실제 SKILL.md 통과"
drop_cases check_impl_verify '구현 검증 단계' \
  '지난 검증 뒤에 구현이 바뀌었으면' '교차 감사를 전체로 다시 받는다' '**다른 벤더 모델**' '고친 발견의 위험도에 따른 예외는 없다' \
  '구현 AI는 감사를 실행하지 않는다' '스펙 위반·누락·소스코드와의 모순' '`구현 검증 커밋` 칸에 값이 있는 가장 최근 행의 커밋 뒤 diff' \
  '하나라도 맞으면 바뀐 것' '조건은 이 넷이 전부다' '값이 있는 행이 없으면 받는다' '문서만 고친 회차도' \
  '`(미커밋 포함)`이 있으면 diff로 가리지 않고 바뀐 것으로 본다' \
  'spec 완료의 정의의 AC나 `결정 사항`의 결정이 더해졌거나 문장이 바뀌었다' '체크박스만 바뀐 것은 세지 않는다' \
  'plan Task N이 마무리로 적은 문서' 'plan 일반 Task가 고친다고 적은 파일' '`[D]`·`[QD]` 줄이 더해졌거나' \
  '`확인` 칸만 바뀐 것과 `[ND]` 줄의 변경은 세지 않는다' '**구현 AI는 감사를 실행하지 않습니다.**'
for p in '  - 제외 경로 밖: ' '  - 제외 경로 안의 산출물: ' '  - `테스트 계획`의 줄: ' '  - AC와 결정: '; do
  drop_row "$p" > "$sandbox/iv-no.md"
  assert_structure check_impl_verify "$sandbox/iv-no.md" fail "구현 검증 단계: 조건 [${p#  - }] 행 삭제 격추"
done
for p in '`.ai/90_issues/`' '`.ai/99_workspace/`' '`.ai/70_ledger/`'; do
  P="$p" awk 'index($0, "  - 제외 경로 밖: ") == 1 { i = index($0, ENVIRON["P"]); if (i) $0 = substr($0, 1, i - 1) substr($0, i + length(ENVIRON["P"])) } { print }' "$SKILL" > "$sandbox/iv-path.md"
  assert_structure check_impl_verify "$sandbox/iv-path.md" fail "구현 검증 단계: 제외 경로 [$p] 삭제 격추"
done
add_after '  - `테스트 계획`의 줄: ' '  - 위험도: 높음 발견을 고쳤다.' > "$sandbox/iv-extra.md"
move_item '- **감사 실행**: ' '### 마무리' > "$sandbox/iv-moved.md"
add_after '## 작업 진행 중' '- 계획의 마지막 Task는 교차모델 검증으로 고정한다.' > "$sandbox/iv-old.md"
add_after '- **용도**: 세션 종료' '- 최종 감사는 Task N 교차모델 audit에서 받는다.' > "$sandbox/iv-old2.md"
R="$DIRTY_RULE" awk 'index($0, "- **바뀌었는지의 판별**: ") == 1 { i = index($0, ENVIRON["R"]); if (i) $0 = substr($0, 1, i - 1) substr($0, i + length(ENVIRON["R"])) } { print }' "$SKILL" > "$sandbox/iv-dirty.md"
assert_structure check_impl_verify "$sandbox/iv-dirty.md" fail "구현 검증 단계: 구현 검증 판별의 미커밋 규칙만 삭제 격추"
assert_structure check_impl_verify "$sandbox/iv-extra.md" fail "구현 검증 단계: 조건에 위험도 추가 격추"
assert_structure check_impl_verify "$sandbox/iv-moved.md" fail "구현 검증 단계: 감사 실행 항목의 완료 확인 이동 격추"
assert_structure check_impl_verify "$sandbox/iv-old.md"   fail "구현 검증 단계: 작업 진행 중의 옛 교차모델 검증 문구 되돌리기 격추"
assert_structure check_impl_verify "$sandbox/iv-old2.md"  fail "구현 검증 단계: 옵션 절의 옛 Task N 교차모델 문구 되돌리기 격추"

assert_structure check_done_check "$SKILL" pass "완료 확인 단계: 실제 SKILL.md 통과"
drop_cases check_done_check '완료 확인 단계' \
  '마지막 교차 감사 리포트' '새 판정 값을 만들지 않는다' '두 표에서 `확인` 칸이 채워진 줄 수' '네 가지가 모두 맞으면 `마무리`, 그 밖은 `다음 회차`를 권장한다' \
  '이관이나 보류로 정한 발견은 세지 않는다' '충족으로 판정한 AC의 `[D]`·`[QD]` 줄에 그 감사 회차를 적' '감사 대상 커밋의 `테스트 계획`에 같은 내용으로 있던 줄에만' \
  '새 회차로 다시 적' '`확인`이 빈 `[ND]` 줄과 지난 확인 뒤에 구현이 바뀐 `[ND]` 줄은 사용자에게 보여 주고' '사용자가 확인하지 않은 줄은 비워 둔다' \
  '`결정` 칸에 적는다' '남은 AC와 발견마다 완화·원장 등재·새 이슈 가운데 결정을 받는다'
for p in '보이는 값|  - 1단계 상태' '보이는 값|  - 2단계 상태' '보이는 값|  - 종합 판정' '보이는 값|  - 확인한 줄 수: ' \
         '권장|  - 1단계 상태: ' '권장|  - 2단계 상태: ' '권장|  - 확인한 줄 수: ' '권장|  - 반영으로 정한 발견: '; do
  awk -v it="- **${p%%|*}**: " -v l="${p#*|}" '/^- / { s = (index($0, it) == 1) } s && index($0, l) == 1 { next } { print }' "$SKILL" > "$sandbox/dn-no.md"
  assert_structure check_done_check "$sandbox/dn-no.md" fail "완료 확인 단계: ${p%%|*}의 [${p#*|  - }] 행 삭제 격추"
done
awk '/^  - 1단계 상태: 충족\(PASS\)이다\.$/ { $0 = "  - 1단계 상태: 충족(PASS)이나 부분 충족(PARTIAL)이다." } { print }' "$SKILL" > "$sandbox/dn-soft1.md"
awk '/^  - 2단계 상태: 통과\(PASS\)나 주의\(WARN\)다\.$/ { $0 = "  - 2단계 상태: 보완 필요(FAIL)여도 된다." } { print }' "$SKILL" > "$sandbox/dn-soft2.md"
add_after '  - 반영으로 정한 발견: ' '  - 종합 판정: 적합(PASS)이다.' > "$sandbox/dn-extra.md"
awk '/^- \*\*결정\*\*: / { sub(/사용자가 정하고/, "구현 AI가 정하고") } { print }' "$SKILL" > "$sandbox/dn-ai.md"
assert_structure check_done_check "$sandbox/dn-soft1.md" fail "완료 확인 단계: 1단계 상태 기준을 부분 충족까지 넓히기 격추"
assert_structure check_done_check "$sandbox/dn-soft2.md" fail "완료 확인 단계: 2단계 상태 기준을 보완 필요까지 넓히기 격추"
assert_structure check_done_check "$sandbox/dn-extra.md" fail "완료 확인 단계: 권장 기준에 다섯 번째 추가 격추"
assert_structure check_done_check "$sandbox/dn-ai.md"    fail "완료 확인 단계: 결정 주체를 구현 AI로 바꾸기 격추"

assert_structure check_finish_entry "$SKILL" pass "마무리 진입: 실제 SKILL.md 통과"
drop_cases check_finish_entry '마무리 진입' \
  '사용자가 `마무리`로 정한 뒤에만 Task N에 들어간다' '교차 감사를 받지 않는다' '전체 회귀, 색인, 충족 AC 체크, repo 고유 마무리, `--clear`, PR' \
  'Task N에서 구현을 고치면 계획 수립으로 돌아간다' '체크한 AC의 체크를 지운다' '     - **체크박스**: ' '     - **루프 기록의 결정**: ' \
  'summary `루프 기록` 마지막 행의 `결정`이 `마무리`인지 본다' '결정 전이거나 `다음 회차`' '미완료 항목으로 보여 준다' '계속 진행할지 질의한다' \
  '     - **Task N 기록**: ' '1단계의 두 검사가 모두' '이관 직전에 plan의 Task N 체크박스를 체크하고' '`PR 대기(git-pr로 생성)`' \
  '미완료를 안고 진행한 실행(중단·종료)에서는 체크하지 않는다' '행에 기록' 'PR을 만들기 직전'
for p in "이슈 완료 시|## 이슈 완료 시" '--clear 1단계|### `--clear`'; do
  awk -v h="${p#*|}" '/^##/ { s = ($0 == h) } s { gsub(/Task N의 미체크는 미완료로 세지 않는다/, "Task N도 체크되어야 한다") } { print }' "$SKILL" > "$sandbox/fe-n.md"
  assert_structure check_finish_entry "$sandbox/fe-n.md" fail "마무리 진입: ${p%%|*}에서 Task N 미체크를 미완료로 되돌리기 격추"
done
move_item '     - **Task N 기록**: ' '  6. **경로 참조' > "$sandbox/fe-step5.md"
move_item '     - **루프 기록의 결정**: ' '  3. **이슈 댓글' > "$sandbox/fe-step2.md"
awk '/^### `--clear`$/ { f = 1 } f && /^  5\. / { sub(/^  5\. /, "  7. "); f = 0 } { print }' "$SKILL" > "$sandbox/fe-renum.md"
assert_structure check_finish_entry "$sandbox/fe-step5.md" fail "마무리 진입: Task N 기록의 --clear 5단계 이동 격추"
assert_structure check_finish_entry "$sandbox/fe-step2.md" fail "마무리 진입: 루프 기록 결정 검사의 --clear 2단계 이동 격추"
assert_structure check_finish_entry "$sandbox/fe-renum.md" fail "마무리 진입: --clear 단계 번호 변경 격추"

assert_structure check_same_kind "$SKILL" pass "같은 종류 발견: 실제 SKILL.md 통과"
drop_cases check_same_kind '같은 종류 발견' \
  '- **같은 종류의 발견**: ' '지난 두 회차에 이어서 나왔으면' 'plan `설계 결정`부터 고친다' '섹션이 없으면 이때 만든다' \
  '     - **종류**: ' '`종류` 칸을 둔다' '이미 있는 이름을 그대로 쓴다' '     - **종류 기록**: ' 'summary `종류별 발견`에 적는다'
move_item '- **같은 종류의 발견**: ' '### 완료 확인' > "$sandbox/sk-moved.md"
move_item '     - **종류**: ' '  3. **처리 방향 표' > "$sandbox/sk-step2.md"
assert_structure check_same_kind "$sandbox/sk-moved.md" fail "같은 종류 발견: 규칙의 구현 검증 이동 격추"
assert_structure check_same_kind "$sandbox/sk-step2.md" fail "같은 종류 발견: 종류 칸의 --response 2단계 이동 격추"

assert_structure check_pr_feedback "$SKILL" pass "PR 뒤 피드백: 실제 SKILL.md 통과"
drop_cases check_pr_feedback 'PR 뒤 피드백' \
  'PR은 Task N에서 git-pr로 만든다' '리뷰 피드백은 git-pr-feedback으로 처리한다' '구현을 고쳤을 때 교차 감사를 다시 받을지는 사용자가 고른다' \
  'PR을 만든 뒤에는 이슈 문서를 고치지 않는다' '### PR 뒤 피드백'
swap_parts '마무리' 'PR 뒤 피드백' > "$sandbox/pf-swap.md"
awk '{ sub(/교차 감사를 다시 받을지는 사용자가 고른다/, "교차 감사를 다시 받는다") } { print }' "$SKILL" > "$sandbox/pf-always.md"
assert_structure check_pr_feedback "$sandbox/pf-swap.md"   fail "PR 뒤 피드백: 마무리와 내용 바꾸기 격추"
assert_structure check_pr_feedback "$sandbox/pf-always.md" fail "PR 뒤 피드백: 사용자 선택을 필수로 바꾸기 격추"

# --- issue-workflow 템플릿 (issue #145) --------------------------------------------
#
# `issue-workflow-template.md`는 세션이 바뀐 AI가 읽는 절차 안내다. 다섯 단계와 돌아가는 길을 아스키 그림과
# 단계 목록으로 두고, 완료 확인의 결정 주체·마무리 Task·PR 뒤 피드백을 SKILL.md의 새 절차대로 적는다.
# 그림의 줄은 ASCII와 한글뿐이고 선은 한글보다 왼쪽에만 있다(글꼴마다 한글 폭이 달라도 어긋나지 않는다).

# wf_steps <파일> → `## 진행 루프`의 번호 단계 이름을 `|`로 이어 출력
wf_steps() { loop_section "$1" | grep -E '^[0-9]+\. \*\*' | sed -E 's/^([0-9]+)\. \*\*([^*]*)\*\*.*/\1 \2/' | tr '\n' '|'; }

# wf_step <파일> <번호> → `## 진행 루프`의 그 번호 단계 (다음 들여쓰지 않은 행 전까지)
wf_step() { loop_section "$1" | awk -v n="$2. **" 'index($0, n) == 1 { s = 1; print; next } s && /^[^[:space:]]/ { exit } s'; }

# wf_drawing <파일> → `## 진행 루프`의 첫 코드 블록 본문
wf_drawing() { loop_section "$1" | awk '/^```/ { if (f) exit; f = 1; next } f'; }

# check_workflow_flow <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_workflow_flow() {
  local b c got p
  got="$(grep -E '^## ' "$1" | sed 's/^## //' | tr '\n' '|')"
  [ "$got" = '디렉토리 구조|진행 루프|작업 진행 중|이슈 완료 시|' ] || echo "절 제목 순서 [$got]"
  need_all "$(h2_section "$1" '디렉토리 구조')" '디렉토리 구조' \
    '-spec.md      ← 목표, 요구사항, 완료의 정의, 결정 사항, 변경 이력, 연관 문서' \
    '-plan.md      ← 설계 결정, 테스트 계획, 실행 Task 목록' \
    '-summary.md   ← 다음 작업, 루프 기록, 종류별 발견, Task별 수행 결과'
  got="$(wf_steps "$1")"
  [ "$got" = '1 계획 수립|2 계획 검증|3 구현|4 구현 검증|5 완료 확인|' ] || echo "진행 루프의 단계 목록 [$got]"
  b="$(loop_section "$1")"
  need_all "$b" '진행 루프' '한 번 지나는 것이 한 회차다' 'summary `루프 기록`에 한 행을' 'issue-work SKILL.md `## 진행 루프`' \
    '미커밋 변경이 있으면 커밋할지 사용자에게 묻는다' '커밋한 대상으로 다시 받을 때까지 바뀐 것으로 본다'
  need_all "$(wf_step "$1" 1)" '1단계' '없으면 쓰고' '지난 회차의 결정을 반영' '반영으로 정한 발견은 plan에 Task로 더하고' \
    '같은 종류의 발견이 지난 두 회차에 이어서 나왔으면 plan `설계 결정`부터 고친다'
  need_all "$(wf_step "$1" 2)" '2단계' 'AC·요구사항, `설계 결정`, `테스트 계획` 가운데 하나가 바뀌었으면' '계획 감사를 다시 받는다' \
    '발견을 고치는 Task를 더한 것만으로는 다시 받지 않는다'
  need_all "$(wf_step "$1" 3)" '3단계' '테스트 작성 → 실패 확인 → 테스트 커밋 → 구현 → 통과 확인 → 구현 커밋' \
    '동작을 바꾸지 않는 Task'
  need_all "$(wf_step "$1" 4)" '4단계' '지난 검증 뒤에 구현이 바뀌었으면' '사용자가 구현 모델과 다른 벤더 모델로' '교차 감사를 전체로 다시 받는다' \
    '구현 AI는 감사를 실행하지 않는다'
  need_all "$(wf_step "$1" 5)" '5단계' '감사 상태와 `테스트 계획`의 확인한 줄 수' '루프를 나갈지는 사용자가 정하고' '`결정` 칸에 적는다'
  need_one "$b" '진행 루프' '- **권장 기준**: '
  c="$(printf '%s\n' "$b" | item_block '- **권장 기준**: ')"
  need_all "$(printf '%s\n' "$c" | head -1)" '권장 기준 첫 행' '네 가지가 모두 맞으면 `마무리`, 그 밖은 `다음 회차`를 권장한다'
  got="$(printf '%s\n' "$c" | item_names)"
  [ "$got" = '1단계 상태|2단계 상태|확인한 줄 수|반영으로 정한 발견|' ] || echo "권장 기준 목록 [$got]"
  need_one "$c" '권장 기준' '  - 1단계 상태: 충족(PASS)이다.'
  need_one "$c" '권장 기준' '  - 2단계 상태: 통과(PASS)나 주의(WARN)다.'
  need_one "$c" '권장 기준' '  - 확인한 줄 수: `테스트 계획`의 모든 줄을 확인했다.'
  need_all "$(printf '%s\n' "$c" | item_block '  - 반영으로 정한 발견: ')" '반영으로 정한 발견' '모두 닫았다' '이관이나 보류로 정한 발견은 세지 않는다'
  need_one "$b" '진행 루프' '- **마무리**: '
  need_all "$(printf '%s\n' "$b" | item_block '- **마무리**: ')" '마무리' '사용자가 `마무리`로 정한 뒤에만 Task N에 들어간다' \
    '전체 회귀, 색인, 충족 AC 체크, repo 고유 마무리, `--clear`, PR' '교차 감사를 받지 않는다' 'Task N에서 구현을 고치면 계획 수립으로 돌아간다'
  b="$(h2_section "$1" '작업 진행 중')"
  need_all "$(printf '%s\n' "$b" | grep -F 'Task 0(구현 시작 게이트)')" 'Task 0 항목' 'spec `## 결정 사항`이나 plan `## 설계 결정`에 적는다' \
    '`전제 누락 없음`'
  need_all "$(printf '%s\n' "$b" | grep -F -- '/issue-<번호>-audit-report.md')" '감사 리포트 항목' 'issue-work `--response`' '항목별 결정' \
    '소스를 고치지 않는다' '반영으로 정한 발견은 다음 회차'
  c="$(h2_section "$1" '이슈 완료 시' | awk '/^1\. / { s = 1 } /^2\. / { exit } s')"
  need_all "$c" '이슈 완료 시 1단계' '`점검 완료`, Task 0, 일반 Task' 'Task N의 미체크는 미완료로 세지 않는다' \
    'summary `루프 기록` 마지막 행의 `결정`이 `마무리`인지' '`최종 audit 모델` 행에 기록' '**대신 채우지 않는다.**'
  c="$(h2_section "$1" '이슈 완료 시' | awk '/^3\. / { s = 1 } /^4\. / { exit } s')"
  need_all "$c" '이슈 완료 시 3단계' '이관 직전에' 'Task N 체크박스를 체크하고' '`PR 대기(git-pr로 생성)`'
  for p in '전제 (Assumptions)' 'Task N(교차모델' '항목별 승인 후에만 보정' '3-2 정제'; do
    grep -nF -- "$p" "$1" | sed 's/^/옛 절차 문구 남음: /' | cut -c1-90
  done
}

# 한글 음절(U+AC00~U+D7A3)의 UTF-8 바이트. 로케일에 기대지 않게 바이트로 견준다.
HG="$(printf 's/\352[\260-\277][\200-\277]//g;s/[\353\354][\200-\277][\200-\277]//g;s/\355[\200-\235][\200-\277]//g;s/\355\236[\200-\243]//g')"

# check_loop_drawing <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_loop_drawing() {
  local d got
  got="$(loop_section "$1" | grep -c '^```')"
  [ "$got" -eq 2 ] || echo "진행 루프의 코드 펜스 행 ${got}개 (기대 2개)"
  d="$(wf_drawing "$1")"
  if [ -z "$d" ]; then echo '그림 없음'; return; fi
  printf '%s\n' "$d" | LC_ALL=C sed "$HG" | LC_ALL=C grep -n '[^ -~]' | cut -d: -f1 | sed 's/^/ASCII와 한글 밖의 문자가 있는 그림 줄: /'
  printf '%s\n' "$d" | LC_ALL=C grep -n "$(printf '[\352-\355]').*[|+]" | cut -d: -f1 | sed 's/^/한글 오른쪽에 선이 있는 그림 줄: /'
  got="$(printf '%s\n' "$d" | grep -oE '[0-9]+\. .*$' | tr '\n' '|')"
  [ "$got" = '1. 계획 수립|2. 계획 검증|3. 구현|4. 구현 검증|5. 완료 확인|' ] || echo "그림의 단계 [$got]"
  # 돌아가는 선: 완료 확인 줄에서 나가 세로선으로 올라가 계획 수립 줄로 들어온다.
  printf '%s\n' "$d" | awk '
    /^  \+--> 1\. 계획 수립$/ { a++; on = 1; next }
    /^  \+--- 5\. 완료 확인$/ { z++; if (!on) bad++; on = 0; next }
    on && !/^  \|/ { bad++ }
    END { if (a != 1) print "계획 수립으로 들어오는 선 " a + 0 "개 (기대 1개)"
          if (z != 1) print "완료 확인에서 나가는 선 " z + 0 "개 (기대 1개)"
          if (bad || on) print "돌아가는 세로선이 끊김" }'
  got="$(printf '%s\n' "$d" | grep -oE '이슈 등록|1\. 계획 수립|5\. 완료 확인|다음 회차로 정하면 1로 돌아간다|Task N \(마무리\)|git-pr-feedback' | tr '\n' '|')"
  [ "$got" = '이슈 등록|1. 계획 수립|5. 완료 확인|다음 회차로 정하면 1로 돌아간다|Task N (마무리)|git-pr-feedback|' ] || echo "그림의 앞뒤 길 [$got]"
}

# check_workflow_pr <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_workflow_pr() {
  local b
  b="$(loop_section "$1")"
  need_all "$(printf '%s\n' "$b" | item_block '- **마무리**: ')" '마무리' 'PR은 Task N에서 git-pr로 만든다'
  need_one "$b" '진행 루프' '- **PR 뒤 피드백**: '
  need_all "$(printf '%s\n' "$b" | item_block '- **PR 뒤 피드백**: ')" 'PR 뒤 피드백' '리뷰 피드백은 git-pr-feedback으로 처리한다' \
    '구현을 고쳤을 때 교차 감사를 다시 받을지는 사용자가 고른다' 'PR을 만든 뒤에는 이슈 문서를 고치지 않는다'
}

# SKILL.md용 사본 함수를 workflow 템플릿에 쓴다 (함수 안의 SKILL만 바꾼다).
wf_drop_cases() { local SKILL="$WORKFLOW_TPL"; drop_cases "$@"; }
wf_move_item()  { local SKILL="$WORKFLOW_TPL"; move_item "$@"; }
wf_drop_row()   { local SKILL="$WORKFLOW_TPL"; drop_row "$@"; }
wf_add_after()  { local SKILL="$WORKFLOW_TPL"; add_after "$@"; }

# wf_sub <원래 문구> <바꿀 문구> → 첫 자리를 바꾼 workflow 템플릿 사본
wf_sub() { A="$1" B="$2" awk '{ if (!d && (i = index($0, ENVIRON["A"]))) { $0 = substr($0, 1, i - 1) ENVIRON["B"] substr($0, i + length(ENVIRON["A"])); d = 1 } print }' "$WORKFLOW_TPL"; }

assert_structure check_workflow_flow "$WORKFLOW_TPL" pass "워크플로우 흐름: 실제 workflow 템플릿 통과"
wf_drop_cases check_workflow_flow '워크플로우 흐름' \
  '목표, 요구사항, 완료의 정의, 결정 사항, 변경 이력, 연관 문서' '설계 결정, 테스트 계획, 실행 Task 목록' '루프 기록, 종류별 발견, ' \
  '한 번 지나는 것이 한 회차다' 'summary `루프 기록`에 한 행을' '지난 회차의 결정을 반영' '반영으로 정한 발견은 plan에 Task로 더하고' \
  '미커밋 변경이 있으면 커밋할지 사용자에게 묻는다' '커밋한 대상으로 다시 받을 때까지 바뀐 것으로 본다' \
  'plan `설계 결정`부터 고친다' 'AC·요구사항, `설계 결정`, `테스트 계획` 가운데' '계획 감사를 다시 받는다' '더한 것만으로는 다시 받지 않는다' \
  '테스트 작성 → 실패 확인 → 테스트 커밋' '동작을 바꾸지 않는 Task' '지난 검증 뒤에 구현이 바뀌었으면' '구현 모델과 다른 벤더 모델로' \
  '교차 감사를 전체로 다시 받는다' '구현 AI는 감사를 실행하지 않는다' '감사 상태와 `테스트 계획`의 확인한 줄 수' '루프를 나갈지는 사용자가 정하고' \
  '네 가지가 모두 맞으면 `마무리`, 그 밖은' '이관이나 보류로 정한 발견은 세지 않는다' '사용자가 `마무리`로 정한 뒤에만' \
  '전체 회귀, 색인, 충족 AC 체크' '교차 감사를 받지 않는다' 'Task N에서 구현을 고치면 계획 수립으로' \
  'spec `## 결정 사항`이나 plan `## 설계 결정`에' '항목별 결정' '소스를 고치지 않는다' '반영으로 정한 발견은 다음 회차' \
  'Task N의 미체크는 미완료로 세지 않는다' 'summary `루프 기록` 마지막 행의 `결정`이' '**대신 채우지 않는다.**' \
  'Task N 체크박스를 체크하고' '`PR 대기(git-pr로 생성)`'
for p in '  - 1단계 상태: ' '  - 2단계 상태: ' '  - 확인한 줄 수: ' '  - 반영으로 정한 발견: '; do
  wf_drop_row "$p" > "$sandbox/wf-no-crit.md"
  assert_structure check_workflow_flow "$sandbox/wf-no-crit.md" fail "워크플로우 흐름: 권장 기준 [${p#  - }] 행 삭제 격추"
done
for p in 1 2 3 4 5; do
  wf_drop_row "$p. **" > "$sandbox/wf-no-step.md"
  assert_structure check_workflow_flow "$sandbox/wf-no-step.md" fail "워크플로우 흐름: ${p}단계 설명 행 삭제 격추"
done
awk '/^3\. \*\*구현\*\*/ { hold = $0; next } { print } hold != "" && /^4\. \*\*/ { print hold; hold = "" }' "$WORKFLOW_TPL" > "$sandbox/wf-swap.md"
awk '/^## 진행 루프$/ { s = 1 } s && /^## 작업 진행 중$/ { s = 0 } s { buf = buf $0 "\n"; next } /^## 이슈 완료 시$/ { printf "%s", buf } { print }' \
  "$WORKFLOW_TPL" > "$sandbox/wf-moved.md"
wf_add_after '  - 반영으로 정한 발견: ' '  - 급한 일정: 남은 발견이 있어도 나간다.' > "$sandbox/wf-extra.md"
wf_sub '루프를 나갈지는 사용자가 정하고' '루프를 나갈지는 구현 AI가 정하고' > "$sandbox/wf-ai.md"
wf_sub '충족(PASS)이다.' '충족(PASS)이나 부분 충족(PARTIAL)이다.' > "$sandbox/wf-soft.md"
wf_sub 'spec `## 결정 사항`이나 plan `## 설계 결정`에 적는다' 'spec `## 전제 (Assumptions)`에 적는다' > "$sandbox/wf-assume.md"
assert_structure check_workflow_flow "$sandbox/wf-swap.md"   fail "워크플로우 흐름: 구현과 구현 검증의 순서 바꾸기 격추"
assert_structure check_workflow_flow "$sandbox/wf-moved.md"  fail "워크플로우 흐름: 진행 루프 절의 작업 진행 중 뒤 이동 격추"
assert_structure check_workflow_flow "$sandbox/wf-extra.md"  fail "워크플로우 흐름: 권장 기준 추가 격추"
assert_structure check_workflow_flow "$sandbox/wf-ai.md"     fail "워크플로우 흐름: 결정 주체를 구현 AI로 바꾸기 격추"
assert_structure check_workflow_flow "$sandbox/wf-soft.md"   fail "워크플로우 흐름: 1단계 상태 기준을 부분 충족까지 넓히기 격추"
assert_structure check_workflow_flow "$sandbox/wf-assume.md" fail "워크플로우 흐름: Task 0 답을 옛 전제 섹션에 적기 격추"

assert_structure check_loop_drawing "$WORKFLOW_TPL" pass "루프 그림: 실제 workflow 템플릿 통과"
awk '{ if ($0 ~ / 3\. 구현$/) sub(/3\. 구현$/, "3. 구현 검증"); else if ($0 ~ / 4\. 구현 검증$/) sub(/4\. 구현 검증$/, "4. 구현"); print }' "$WORKFLOW_TPL" > "$sandbox/ld-swap.md"
awk '{ sub(/^  \+--> 1\./, "       1."); sub(/^  \+--- 5\./, "       5."); if (/^  \|  /) sub(/^  \|/, "   "); print }' "$WORKFLOW_TPL" > "$sandbox/ld-noback.md"
awk '/^  \+--- 5\./ { sub(/^  \+---/, "      ") } { print }' "$WORKFLOW_TPL" > "$sandbox/ld-noout.md"
awk '/^  \+--> 1\./ { sub(/^  \+-->/, "      ") } { print }' "$WORKFLOW_TPL" > "$sandbox/ld-noin.md"
awk '/^  \|    3\. 구현$/ { sub(/^  \|/, "   ") } { print }' "$WORKFLOW_TPL" > "$sandbox/ld-cut.md"
awk '/^  \|  / { sub(/^  \|/, "  │") } { print }' "$WORKFLOW_TPL" > "$sandbox/ld-box.md"
wf_sub '테스트 작성 -> 실패 확인' '테스트 작성 → 실패 확인' > "$sandbox/ld-arrow.md"
wf_sub 'spec, plan이 없으면' 'spec·plan이 없으면' > "$sandbox/ld-dot.md"
awk '/^  \|    3\. 구현$/ { $0 = $0 "   |" } { print }' "$WORKFLOW_TPL" > "$sandbox/ld-right.md"
awk '/^## / { f = ($0 == "## 진행 루프") } f && /^```/ { c = !c; next } f && c { next } { print }' "$WORKFLOW_TPL" > "$sandbox/ld-none.md"
awk '/^## 진행 루프$/ { s = 1 } s && /^```/ { if (c) { print; print ""; print "```"; print "두 번째"; print "```"; s = 0; next } c = 1 } { print }' "$WORKFLOW_TPL" > "$sandbox/ld-two.md"
wf_sub 'Task N (마무리)' '끝' > "$sandbox/ld-notn.md"
for kv in 'swap:단계 순서 바꾸기' 'noback:돌아가는 선 전체 삭제' 'noout:완료 확인에서 나가는 선 삭제' 'noin:계획 수립으로 들어오는 선 삭제' \
          'cut:돌아가는 세로선 한 칸 끊기' 'box:선 그리기 문자(U+2502) 넣기' 'arrow:화살표(U+2192) 넣기' 'dot:가운뎃점(U+00B7) 넣기' \
          'right:한글 오른쪽에 선 두기' 'none:그림 삭제' 'two:코드 블록 추가' 'notn:마무리로 나가는 길 삭제'; do
  assert_structure check_loop_drawing "$sandbox/ld-${kv%%:*}.md" fail "루프 그림: ${kv#*:} 격추"
done
# 사본이 다른 이유로 걸리지 않는지 본다: 문자만 바꾼 사본은 문자 위반 한 종류만 낸다.
for k in box arrow dot; do
  got="$(check_loop_drawing "$sandbox/ld-$k.md" | grep -c 'ASCII와 한글 밖의 문자')"
  if [ "$got" -ge 1 ]; then ok "루프 그림: ${k} 사본의 문자 위반 검출 격추"; else ng "루프 그림: ${k} 사본의 문자 위반 검출 격추"; fi
done

assert_structure check_workflow_pr "$WORKFLOW_TPL" pass "PR 뒤 피드백 안내: 실제 workflow 템플릿 통과"
wf_drop_cases check_workflow_pr 'PR 뒤 피드백 안내' \
  'PR은 Task N에서 git-pr로 만든다' '리뷰 피드백은 git-pr-feedback으로 처리한다' '교차 감사를 다시 받을지는 사용자가 고른다' 'PR을 만든 뒤에는 이슈 문서를 고치지 않는다'
wf_drop_row '- **PR 뒤 피드백**: ' > "$sandbox/wp-no.md"
wf_move_item '- **PR 뒤 피드백**: ' '## 이슈 완료 시' > "$sandbox/wp-moved.md"
wf_sub '교차 감사를 다시 받을지는 사용자가 고른다' '교차 감사를 다시 받는다' > "$sandbox/wp-always.md"
assert_structure check_workflow_pr "$sandbox/wp-no.md"     fail "PR 뒤 피드백 안내: 항목 삭제 격추"
assert_structure check_workflow_pr "$sandbox/wp-moved.md"  fail "PR 뒤 피드백 안내: 항목의 진행 루프 밖 이동 격추"
assert_structure check_workflow_pr "$sandbox/wp-always.md" fail "PR 뒤 피드백 안내: 사용자 선택을 필수로 바꾸기 격추"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
