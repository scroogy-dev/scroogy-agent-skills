#!/usr/bin/env bash
#
# ai-workspace 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# check-context.sh 의 정상 케이스를 fixture 로 따로 두지 않고 `templates/<프로파일>/.ai/AI-CONTEXT.md`
# 를 그대로 쓴다 — 템플릿이 산출물의 SSoT 이므로, 템플릿이 검사를 통과하지 못하면 그 자체가 결함이다.
# `> last updated: YYYY-MM-DD` 자리표시자만 init-1단계의 치환 규칙과 같게 실제 날짜로 바꿔 검사한다.
#
# 같은 저장소의 `.ai/AI-CONTEXT.md` 도 검사해 이 repo 안내도가 표준을 유지하는지 함께 본다
# (파일이 없으면 건너뛴다 — tests/ 는 배포 제외라 통상 저장소 안에서만 실행된다).
#
# update-4 멱등 보강 검사의 `## 프로젝트 규칙` 3개 항목에는 fixtures/update4-idempotent/ 의
# 입력·기대 쌍이 따로 있다. 그쪽은 조치(삽입) 결과까지 보는 [QD] 모의 실행이고,
# 여기서는 그 입력들이 검사 단계에서 실제로 누락으로 잡히는지를 [D] 로 판정한다.
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
CHECK="$HERE/../scripts/check-context.sh"
TPL_DIR="$HERE/../templates"
FIX="$HERE/fixtures/update4-idempotent"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

[ -x "$CHECK" ] || { echo "NOT OK - 헬퍼 실행 권한 없음 — $CHECK"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

TODAY='2026-08-13'

# prepare <원본> <대상> — init-1단계의 last updated 치환과 같은 변환을 적용한다.
prepare() {
  sed "s/^> last updated: YYYY-MM-DD$/> last updated: $TODAY/" "$1" > "$2"
}

# --- 템플릿이 검사를 통과한다 ---------------------------------------------------

tpl_count=0
for p in dev doc; do
  src="$TPL_DIR/$p/.ai/AI-CONTEXT.md"
  if [ ! -r "$src" ]; then
    ng "템플릿 통과($p): 파일을 찾을 수 없습니다 — $src"
    continue
  fi
  prepare "$src" "$TMP/$p.md"
  if "$CHECK" "$TMP/$p.md" >/dev/null 2>&1; then
    ok "템플릿 통과: $p 프로파일"
  else
    ng "템플릿 통과: $p 프로파일 — 누락: $("$CHECK" "$TMP/$p.md" 2>&1 | tr '\n' ' ')"
  fi
  tpl_count=$((tpl_count + 1))
done
[ "$tpl_count" -eq 2 ] && ok "템플릿: 프로파일 2종 검사" || ng "템플릿: ${tpl_count}종만 검사(기대 2)"

# 치환 전 템플릿은 날짜 자리표시자 때문에 첫 줄 검사에 걸려야 한다 — 형식 검사가 실제로 동작한다는 증거다.
if "$CHECK" "$TPL_DIR/dev/.ai/AI-CONTEXT.md" >/dev/null 2>&1; then
  ng "날짜 자리표시자: 치환 전 템플릿이 통과했습니다 — 첫 줄 형식 검사가 동작하지 않습니다"
else
  ok "날짜 자리표시자: 치환 전 템플릿은 첫 줄 검사에 걸림"
fi

# --- 이 저장소 안내도 -----------------------------------------------------------

REPO_CTX="$HERE/../../.ai/AI-CONTEXT.md"
if [ -r "$REPO_CTX" ]; then
  if "$CHECK" "$REPO_CTX" >/dev/null 2>&1; then
    ok "저장소 안내도: .ai/AI-CONTEXT.md 통과"
  else
    ng "저장소 안내도: 누락 — $("$CHECK" "$REPO_CTX" 2>&1 | tr '\n' ' ')"
  fi
else
  ok "저장소 안내도: 파일 없음 — 건너뜀"
fi

# --- 항목별 누락 검사 -----------------------------------------------------------
#
# dev 템플릿을 한 곳씩 망가뜨려 각 검사가 실제로 발동하는지 본다.
# 출력 문자열까지 대조해 다른 검사가 대신 걸려 통과처럼 보이는 것을 막는다.

BASE="$TMP/dev.md"

# assert_missing <설명> <출력 조각> <변형 명령...>
assert_missing() {
  local desc="$1" want="$2"; shift 2
  local f="$TMP/case.md" out rc
  cp "$BASE" "$f"
  "$@" "$f" || { ng "$desc — 변형 실패"; return; }
  out="$("$CHECK" "$f" 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ]; then
    ng "$desc — exit 1 기대, 실제 $rc"
  elif printf '%s\n' "$out" | grep -qF "$want"; then
    ok "$desc"
  else
    ng "$desc — 출력에 '$want' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

m_date()      { sed -i.bak "s/^> last updated: $TODAY$/> last updated: 오늘/" "$1" && rm -f "$1.bak"; }
m_ssot()      { sed -i.bak 's/^> SSoT: .*/> SSoT: 알아서 판단할 것./' "$1" && rm -f "$1.bak"; }
m_no_domain() { sed -i.bak 's/^## 프로젝트 도메인$/## 도메인 정보/' "$1" && rm -f "$1.bak"; }
m_no_kw()     { sed -i.bak 's/^| keywords | .*/| tags | <콤마 나열> |/' "$1" && rm -f "$1.bak"; }
m_no_rules()  { sed -i.bak 's/^## 프로젝트 규칙$/## 규칙 모음/' "$1" && rm -f "$1.bak"; }
m_no_premise() { sed -i.bak '/^> 전제: 상위 디렉토리에/d' "$1" && rm -f "$1.bak"; }
m_no_agent()  { sed -i.bak 's/^## 에이전트 운영 지침$/## 운영/' "$1" && rm -f "$1.bak"; }
m_ctxrow()    { sed -i.bak '/`\.ai\/10_rules\/context-loading\.md`/d' "$1" && rm -f "$1.bak"; }
m_wrrow()     { sed -i.bak '/`\.ai\/10_rules\/writing-principles\.md`/d' "$1" && rm -f "$1.bak"; }
m_legacy()    { printf '\n## 워크스페이스 위치\n\n| 항목 | 값 |\n|------|----|\n| building | ws |\n' >> "$1"; }

assert_missing '본문 첫 줄 last updated'     "본문 첫 줄"                        m_date
assert_missing '본문 두 번째 줄 SSoT'         "본문 두 번째 줄 SSoT"              m_ssot
assert_missing '프로젝트 도메인 섹션'          "'## 프로젝트 도메인' 섹션"          m_no_domain
assert_missing '프로젝트 도메인 keywords 행'   'keywords` 행'                      m_no_kw
assert_missing '프로젝트 규칙 섹션'            '섹션 부재'                          m_no_rules
assert_missing 'context-loading.md 행'        'context-loading.md` 행'            m_ctxrow
assert_missing 'writing-principles.md 행'     'writing-principles.md` 행'         m_wrrow
assert_missing '에이전트 운영 지침 섹션'        "'## 에이전트 운영 지침' 섹션"       m_no_agent
assert_missing '전제 컨벤션 한 줄'             '전제 컨벤션 한 줄'                  m_no_premise
assert_missing '구버전 워크스페이스 위치 섹션'   "'## 워크스페이스 위치' 섹션"        m_legacy

# --- 프로젝트 규칙 표 상태 3분기 --------------------------------------------------
#
# 조치가 상태별로 갈리므로 세 상태가 서로 다른 메시지로 나와야 한다.
# fixtures/update4-idempotent/ 의 입력 파일이 그 상태들의 실제 예시다.

# assert_fixture <케이스> <출력 조각>
assert_fixture() {
  local case_name="$1" want="$2"
  local f="$FIX/$case_name.input.md"
  local out rc
  if [ ! -r "$f" ]; then ng "fixture 상태 판정($case_name): 파일 없음 — $f"; return; fi
  out="$("$CHECK" "$f" 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ]; then
    ng "fixture 상태 판정($case_name) — exit 1 기대, 실제 $rc"
  elif printf '%s\n' "$out" | grep -qF "$want"; then
    ok "fixture 상태 판정($case_name): $want"
  else
    ng "fixture 상태 판정($case_name) — 출력에 '$want' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

assert_fixture 'no-rules-section' '섹션 부재'
assert_fixture 'no-rules-table'   '섹션은 있고 표 부재'
assert_fixture 'legacy-two-col'   '구버전 표 — 열 확장 대상'
assert_fixture 'missing-rows'     'context-loading.md` 행'
assert_fixture 'missing-rows-doc' 'context-loading.md` 행'

# 표가 없는 상태에서는 표준 2행 검사를 수행하지 않는다 — 같은 결함을 세 번 세지 않기 위함이다.
{
  out="$("$CHECK" "$FIX/no-rules-section.input.md" 2>&1)"
  if printf '%s\n' "$out" | grep -qF 'context-loading.md` 행'; then
    ng "선행 조건: 표 부재 상태에서 행 검사가 함께 발동했습니다"
  else
    ok "선행 조건: 표 부재 상태에서는 행 검사를 건너뜀"
  fi
}

# --- 검사 표 행 수 (SKILL.md 대조) -------------------------------------------------
#
# 헬퍼가 다루는 8종 외 2종(디렉토리 구조 관련)은 의도적으로 제외했다.
# SKILL.md 표가 늘면 이 검사가 걸려 제외 범위를 다시 판단하게 한다.

rows="$(awk '
  /^#### 멱등 보강 검사/ { f = 1; next }
  f && /^#### / { exit }
  f && /^\|/ { n++ }
  END { print n + 0 }
' "$SKILL")"
# 헤더·구분선 2행을 뺀 항목 수
items=$((rows - 2))
[ "$items" -eq 10 ] \
  && ok "SKILL.md 멱등 보강 검사 표: ${items}행 (헬퍼 8종 + 트리 관련 2종 제외)" \
  || ng "SKILL.md 멱등 보강 검사 표가 ${items}행입니다 — 헬퍼의 제외 범위를 다시 판단하세요"

# --- 사용오류 ------------------------------------------------------------------

assert_usage_error() {
  local desc="$1"; shift
  "$CHECK" "$@" >/dev/null 2>&1
  case "$?" in
    2) ok "사용오류: $desc (exit 2)" ;;
    *) ng "사용오류: $desc — exit 2 기대, 실제 $?" ;;
  esac
}

assert_usage_error '인자 없음'
assert_usage_error '읽을 수 없는 파일'  "$TMP/absent.md"
assert_usage_error '알 수 없는 옵션'    --profile dev "$BASE"
assert_usage_error '파일 중복'         "$BASE" "$BASE"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
