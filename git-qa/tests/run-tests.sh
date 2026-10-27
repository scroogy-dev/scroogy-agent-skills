#!/usr/bin/env bash
#
# git-qa 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# 이 스킬은 scripts/ 가 없어 체크리스트 작성 규칙이 SKILL.md 절차 문장과 출력 템플릿에 있다.
# 4단계 자동 테스트 표시 조항(#122)이 제자리에 있는지를 [D] 로 보고,
# 앵커 문구를 지운 사본과 조항을 4단계 밖으로 옮긴 사본이 격추되는지로 검사가 실제로 동작함을 확인한다.
# 앵커는 `## 참조 문서`의 테스트 원칙 항목, 4단계의 local 파일 참조·표시 규칙·읽기 실패 폴백·덮음 판정 기준,
# 템플릿 체크리스트 행의 표시 예시다. 조건·우선순위의 뜻은 판정하지 않는다 (이슈 spec 의 [QD] 몫).
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
TEMPLATE="$HERE/../templates/qa-checklist-template.md"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

for f in "$SKILL" "$TEMPLATE"; do
  [ -r "$f" ] || { echo "NOT OK - 파일을 찾을 수 없습니다 — $f"; exit 1; }
done

sandbox="$(mktemp -d)"
trap 'rm -rf "$sandbox"' EXIT

# check_skill_clause <SKILL.md> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 4단계 범위는 `### 4단계` 제목부터 다음 `##`·`###` 제목 전까지다. 코드 블록 안의 `#` 행은 제목으로 보지 않는다.
check_skill_clause() {
  awk '
    /^[[:space:]]*```/ { code = !code }
    !code && /^## / { r = ($0 ~ /^## 참조 문서/); s = 0 }
    !code && /^### / { s = ($0 ~ /^### 4단계/) }
    r && /^  - `\.ai\/10_rules\/testing-principles\.md`·`\.ai\/10_rules\/testing-principles-local\.md` — / { ref++ }
    s && index($0, "testing-principles-local.md") { loc++ }
    s && index($0, "자동 테스트로 덮음(") { mark++ }
    s && index($0, "읽지 못하면 표시 없이") { fb++ }
    s && index($0, "테스트를 찾지 못하면 표시하지 않고") { cov++ }
    END {
      if (ref != 1) print "참조 문서의 테스트 원칙 항목 " ref + 0 "개 (기대 1개)"
      if (!loc) print "4단계에 testing-principles-local.md 참조 없음"
      if (!mark) print "4단계에 자동 테스트로 덮음( 표시 규칙 없음"
      if (!fb) print "4단계에 읽기 실패 폴백 없음"
      if (!cov) print "4단계에 덮음 판정 기준 없음"
    }
  ' "$1"
}

# check_template_clause <템플릿> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_template_clause() {
  awk '/^- \[ \] / && index($0, "자동 테스트로 덮음(") { n++ } END { if (!n) print "체크리스트 행에 자동 테스트로 덮음( 예시 없음" }' "$1"
}

# drop_literal <파일> <문자열> → 문자열을 정규식 해석 없이 지운 사본을 표준 출력으로
drop_literal() {
  awk -v s="$2" '{ while ((i = index($0, s))) $0 = substr($0, 1, i - 1) substr($0, i + length(s)); print }' "$1"
}

# drop_in_step4 <파일> <문자열> → 4단계 범위에서만 문자열을 지운 사본을 표준 출력으로
# 참조 문서 항목에도 같은 파일명이 있어, 파일 전체에서 지우면 4단계 검사가 아니라 참조 항목 검사가 걸린다.
drop_in_step4() {
  awk -v s="$2" '
    /^[[:space:]]*```/ { code = !code }
    !code && /^(## |### )/ { f = ($0 ~ /^### 4단계/) }
    f { while ((i = index($0, s))) $0 = substr($0, 1, i - 1) substr($0, i + length(s)) }
    { print }' "$1"
}

# assert_clause <검사 함수> <파일> <기대: pass|fail> <설명>
assert_clause() {
  local out
  out="$("$1" "$2")"
  case "$3" in
    pass) if [ -z "$out" ]; then ok "$4 (위반 0건)"; else ng "$4 (기대 0건, 실제 [$out])"; fi ;;
    fail) if [ -n "$out" ]; then ok "$4 (위반 검출)"; else ng "$4 (기대 >0건, 실제 0건)"; fi ;;
  esac
}

# --- SKILL.md·템플릿 테스트 원칙 조항 (issue #122) ---------------------------------

awk '!index($0, "  - `.ai/10_rules/testing-principles.md`·`.ai/10_rules/testing-principles-local.md` — ")' \
  "$SKILL" > "$sandbox/tc-ref-del.md"
drop_in_step4 "$SKILL" 'testing-principles-local.md' > "$sandbox/tc-loc-del.md"
drop_literal "$SKILL" '자동 테스트로 덮음(' > "$sandbox/tc-mark-del.md"
drop_literal "$SKILL" '읽지 못하면 표시 없이' > "$sandbox/tc-fb-del.md"
drop_literal "$SKILL" '테스트를 찾지 못하면 표시하지 않고' > "$sandbox/tc-cov-del.md"
# 자동 테스트 표시 블록을 4단계 밖(`## 결과 출력` 아래)으로 옮긴다. 블록을 찾지 못하면 사본이 원본과 같아 격추가 실패한다.
awk '
  /^\*\*자동 테스트 표시\*\*/ { h = 1 }
  h && /^---$/ { h = 0 }
  h { held = held $0 "\n"; next }
  { print }
  /^## 결과 출력/ && held != "" { printf "\n%s", held; held = "" }
' "$SKILL" > "$sandbox/tc-moved.md"
drop_literal "$TEMPLATE" '자동 테스트로 덮음(' > "$sandbox/tc-tpl-del.md"

assert_clause check_skill_clause    "$SKILL"                 pass "테스트 원칙 조항: 실제 SKILL.md 통과"
assert_clause check_template_clause "$TEMPLATE"              pass "테스트 원칙 조항: 실제 템플릿 통과"
assert_clause check_skill_clause    "$sandbox/tc-ref-del.md"  fail "테스트 원칙 조항: 참조 문서 항목 삭제 격추"
assert_clause check_skill_clause    "$sandbox/tc-loc-del.md"  fail "테스트 원칙 조항: 4단계 local 참조 삭제 격추"
assert_clause check_skill_clause    "$sandbox/tc-mark-del.md" fail "테스트 원칙 조항: 4단계 표시 규칙 삭제 격추"
assert_clause check_skill_clause    "$sandbox/tc-fb-del.md"   fail "테스트 원칙 조항: 4단계 읽기 실패 폴백 삭제 격추"
assert_clause check_skill_clause    "$sandbox/tc-cov-del.md"  fail "테스트 원칙 조항: 4단계 덮음 판정 기준 삭제 격추"
assert_clause check_skill_clause    "$sandbox/tc-moved.md"    fail "테스트 원칙 조항: 자동 테스트 표시 블록의 4단계 밖 이동 격추"
assert_clause check_template_clause "$sandbox/tc-tpl-del.md"  fail "테스트 원칙 조항: 템플릿 표시 예시 삭제 격추"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
