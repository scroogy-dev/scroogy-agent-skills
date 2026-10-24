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

# --- doc 템플릿 고유 행 ----------------------------------------------------------
#
# 헬퍼는 dev·doc 두 선언 문구를 모두 인정하므로, 위 템플릿 통과 루프는 doc 템플릿이
# dev 선언·dev 우선순위로 되돌아가도 통과한다 (최종 감사 F-2 반례).
# doc 템플릿이 doc 선언·doc 우선순위·`ssot_dir`·`publish` 행을 갖는지 따로 본다.
# 문서 규약(`document-convention.md`)은 헬퍼가 검사하지 않는 사용자 관리 파일이라(dev의
# `architecture.md`·`coding-convention.md`와 같은 취급) `## 프로젝트 규칙` 표 행과 파일 존재를 여기서 본다.

DOC_TPL="$TMP/doc.md"
SSOT_DOC='> SSoT: 원본 문서. 이 파일은 안내도일 뿐 진실의 원천이 아니다.'

# doc_tpl_violations <파일> [<10_rules 디렉토리>] — 어긋난 항목을 1행씩 출력한다. 무출력이면 통과.
# 본문 2번째 줄은 헬퍼와 같은 계산(H1 제목을 건너뛴 첫 비어 있지 않은 줄의 바로 다음 물리 행)으로 고른다.
# 10_rules 디렉토리를 생략하면 doc 템플릿의 디렉토리를 본다.
doc_tpl_violations() {
  local f="$1" rules="${2:-$TPL_DIR/doc/.ai/10_rules}" start line2 k
  start=$(awk 'NR == 1 && /^# / { next } NF { print NR; exit }' "$f")
  line2=$(sed -n "$((start + 1))p" "$f")
  [ "$line2" = "$SSOT_DOC" ] || echo '본문 두 번째 줄 doc 선언'
  [ "$(grep -c '원본 문서 > 이 repo 안내도 > 상위 워크스페이스 안내도' "$f")" -eq 1 ] || echo 'doc 우선순위 행'
  for k in ssot_dir publish; do
    awk -v key="$k" '
      /^## 프로젝트 도메인[[:space:]]*$/ { f = 1; next } f && /^## / { exit }
      f && /^\|/ { v = $0; sub(/^\|[[:space:]]*/, "", v); sub(/[[:space:]]*\|.*$/, "", v); if (v == key) { found = 1; exit } }
      END { exit !found }' "$f" || echo "프로젝트 도메인 표 $k 행"
  done
  awk '
    /^## 프로젝트 규칙[[:space:]]*$/ { f = 1; next } f && /^## / { exit }
    f && /^\|/ { v = $0; sub(/^\|[[:space:]]*/, "", v); sub(/[[:space:]]*\|.*$/, "", v); if (v == "`.ai/10_rules/document-convention.md`") { found = 1; exit } }
    END { exit !found }' "$f" || echo '프로젝트 규칙 표 문서 규약 행'
  [ -f "$rules/document-convention.md" ] || echo '문서 규약 파일'
}

# assert_doc_tpl_reject <설명> <위반 조각> <변형 명령...>
assert_doc_tpl_reject() {
  local desc="$1" want="$2"; shift 2
  local f="$TMP/doc-case.md" out
  cp "$DOC_TPL" "$f"
  "$@" "$f" || { ng "$desc — 변형 실패"; return; }
  out="$(doc_tpl_violations "$f")"
  if printf '%s\n' "$out" | grep -qF "$want"; then
    ok "$desc"
  else
    ng "$desc — 위반에 '$want' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

d_dev_line()   { sed -i.bak 's/^> SSoT: .*/> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다./' "$1" && rm -f "$1.bak"; }
d_dev_prio()   { sed -i.bak 's/원본 문서 > 이 repo 안내도 > 상위 워크스페이스 안내도/소스 코드 > 이 repo 안내도 > 상위 워크스페이스 안내도/' "$1" && rm -f "$1.bak"; }
d_no_root()    { sed -i.bak '/^| ssot_dir | /d' "$1" && rm -f "$1.bak"; }
d_no_publish() { sed -i.bak '/^| publish | /d' "$1" && rm -f "$1.bak"; }
d_no_conv()    { sed -i.bak '/^| `\.ai\/10_rules\/document-convention\.md` /d' "$1" && rm -f "$1.bak"; }

if [ -r "$DOC_TPL" ]; then
  out="$(doc_tpl_violations "$DOC_TPL")"
  if [ -z "$out" ]; then
    ok "doc 템플릿 고유 행·문서 규약 통과"
  else
    ng "doc 템플릿 고유 행·문서 규약 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
  assert_doc_tpl_reject 'doc 템플릿 dev 선언 원복 격추'     '본문 두 번째 줄 doc 선언'   d_dev_line
  assert_doc_tpl_reject 'doc 템플릿 dev 우선순위 원복 격추' 'doc 우선순위 행'            d_dev_prio
  assert_doc_tpl_reject 'doc 템플릿 ssot_dir 행 삭제 격추'  '프로젝트 도메인 표 ssot_dir 행' d_no_root
  assert_doc_tpl_reject 'doc 템플릿 publish 행 삭제 격추'   '프로젝트 도메인 표 publish 행'  d_no_publish
  assert_doc_tpl_reject 'doc 템플릿 문서 규약 행 삭제 격추'  '프로젝트 규칙 표 문서 규약 행'  d_no_conv
  mkdir -p "$TMP/rules-empty"
  out="$(doc_tpl_violations "$DOC_TPL" "$TMP/rules-empty")"
  if printf '%s\n' "$out" | grep -qxF '문서 규약 파일'; then
    ok 'doc 템플릿 문서 규약 파일 부재 격추'
  else
    ng "doc 템플릿 문서 규약 파일 부재 격추 — 위반에 '문서 규약 파일' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
else
  ng "doc 템플릿 고유 행: 준비된 doc 템플릿 없음 — $DOC_TPL"
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
# 5차 audit F-5 반례: 열 수는 3이지만 헤더 이름이 표준과 다른 표.
m_rules_hdr() { sed -i.bak 's/^| 파일 | 설명 | 사용 시점 |$/| foo | bar | baz |/' "$1" && rm -f "$1.bak"; }
m_rules_ord() { sed -i.bak 's/^| 파일 | 설명 | 사용 시점 |$/| 설명 | 파일 | 사용 시점 |/' "$1" && rm -f "$1.bak"; }

# doc 선언 변형. dev 템플릿에서 출발해 "doc 선언이 `ssot_dir`·dev 표준 문구 4곳 검사를 켠다"를 고정한다.
# 유사 문구 변형은 `ssot_dir` 행·doc 문구 4곳이 있는 파일로 만들어 격추 원인을 2번째 줄로 한정한다.
m_doc_noroot() { sed -i.bak 's/^> SSoT: .*/> SSoT: 원본 문서. 이 파일은 안내도일 뿐 진실의 원천이 아니다./' "$1" && rm -f "$1.bak"; }
# PR #115 리뷰 반례: 이전 doc 템플릿(dev 선언·dev 표준 문구)에서 2번째 줄만 바꾸고 update가 `ssot_dir` 행을 보강한 상태.
m_doc_dev_text() {
  m_doc_noroot "$1" || return 1
  awk '{ print } /^\| keywords \| / { print "| ssot_dir | docs/ |" }' "$1" > "$1.root" && mv "$1.root" "$1"
}

# dev 표준 문구 4곳과 doc 템플릿 문구의 짝 (sed 구분자 `|`). D_* 는 dev → doc, R_* 는 doc → dev.
D_PRIO='s|\*\*소스 코드 > 이 repo 안내도 > 상위 워크스페이스 안내도\*\*|**원본 문서 > 이 repo 안내도 > 상위 워크스페이스 안내도**|'
D_TREE='s|# \[5순위\] 소스코드 엔트리포인트·호출 흐름 색인 (index.md로 선택적 참조)|# [5순위] SSoT 색인. 원본 문서(ssot_dir) 파일 지도 (index.md로 선택적 참조)|'
D_ENTRY='s|`60_codebase/index.md`(코드 진입점)|`60_codebase/index.md`(원본 문서 색인)|'
D_RULE='s|코드 상세는 `60_codebase/`|원본 문서 색인은 `60_codebase/`|'
R_PRIO='s|\*\*원본 문서 > 이 repo 안내도 > 상위 워크스페이스 안내도\*\*|**소스 코드 > 이 repo 안내도 > 상위 워크스페이스 안내도**|'
R_TREE='s|# \[5순위\] SSoT 색인\. 원본 문서(ssot_dir) 파일 지도 (index.md로 선택적 참조)|# [5순위] 소스코드 엔트리포인트·호출 흐름 색인 (index.md로 선택적 참조)|'
R_ENTRY='s|`60_codebase/index.md`(원본 문서 색인)|`60_codebase/index.md`(코드 진입점)|'
R_RULE='s|원본 문서 색인은 `60_codebase/`|코드 상세는 `60_codebase/`|'

# 4곳을 모두 doc 템플릿 문구로 바꾼 상태 (doc 전환 완료).
m_doc_root() { m_doc_dev_text "$1" && sed -i.bak -e "$D_PRIO" -e "$D_TREE" -e "$D_ENTRY" -e "$D_RULE" "$1" && rm -f "$1.bak"; }
# 전환 완료 상태에서 한 곳만 dev 표준 문구로 되돌린다. 나머지가 doc 문구라 격추 원인이 그 한 곳으로 한정된다.
m_doc_prio_dev()  { m_doc_root "$1" && sed -i.bak "$R_PRIO"  "$1" && rm -f "$1.bak"; }
m_doc_tree_dev()  { m_doc_root "$1" && sed -i.bak "$R_TREE"  "$1" && rm -f "$1.bak"; }
m_doc_entry_dev() { m_doc_root "$1" && sed -i.bak "$R_ENTRY" "$1" && rm -f "$1.bak"; }
m_doc_rule_dev()  { m_doc_root "$1" && sed -i.bak "$R_RULE"  "$1" && rm -f "$1.bak"; }
# 사용자가 고쳐 쓴 우선순위. dev 표준 문구를 부분 문자열로 품고 있어도 굵게 표시한 구간이 달라 보존 대상이다.
m_doc_prio_custom() { m_doc_root "$1" && sed -i.bak 's/\*\*원본 문서 > 이 repo 안내도/**원본 문서 > 소스 코드 > 이 repo 안내도/' "$1" && rm -f "$1.bak"; }
m_near_with_root() { m_doc_root "$1" && sed -i.bak 's/^> SSoT: .*/> SSoT: 원본 문서./' "$1" && rm -f "$1.bak"; }

# SKILL.md 검사 표가 허용하는 뒤 확장 열(앞 3열의 이름·순서는 그대로).
m_rules_4col() {
  awk '
    /^## 프로젝트 규칙[[:space:]]*$/ { f = 1; print; next }
    f && /^## / { f = 0 }
    f && /^\|/ {
      if ($0 ~ /^\|[-:| ]+\|$/) { print $0 "------|" }
      else if ($0 ~ /^\| 파일 \|/) { print $0 " 비고 |" }
      else { print $0 " <비고> |" }
      next
    }
    { print }
  ' "$1" > "$1.4col" && mv "$1.4col" "$1"
}

# 3차 audit F-8 반례: 앞 3열이 정상인 4열 표에서 필수 경로를 `파일` 셀 밖 확장 열로 옮긴다.
# 행 전체를 부분 문자열로 찾는 검사는 이 입력을 통과시키므로, `파일` 셀 정확 대조만 잡아낸다.
m_row_in_ext() {
  local path="$1" f="$2"
  m_rules_4col "$f" || return 1
  awk -v path="$path" '
    /^\|/ && index($0, "`" path "`") {
      n = split($0, c, "|")
      c[2] = " `.ai/10_rules/custom.md` "
      c[n-1] = " `" path "` "
      out = c[1]
      for (i = 2; i <= n; i++) out = out "|" c[i]
      print out
      next
    }
    { print }
  ' "$f" > "$f.ext" && mv "$f.ext" "$f"
}
m_ctx_in_ext() { m_row_in_ext '.ai/10_rules/context-loading.md' "$1"; }
m_wr_in_ext()  { m_row_in_ext '.ai/10_rules/writing-principles.md' "$1"; }

# 4차 audit F-9 반례: 두 필수 행을 첫 번째 표에서 빼 같은 H2의 두 번째 표로 옮긴다.
# 탐색이 첫 번째 표 블록에서 멈추지 않으면 이 입력이 통과한다.
m_rows_in_2nd() {
  awk '
    /^## 프로젝트 규칙[[:space:]]*$/ { f = 1; print; next }
    f && /^## / { f = 0 }
    f && /^\|/ {
      t = 1
      if (index($0, "`.ai/10_rules/context-loading.md`") || index($0, "`.ai/10_rules/writing-principles.md`")) {
        moved = moved $0 "\n"
        next
      }
      print; next
    }
    f && t {
      print ""
      print "추가 규칙 표:"
      print ""
      print "| 파일 | 설명 | 사용 시점 |"
      print "|------|------|----------|"
      printf "%s", moved
      f = 0; t = 0
    }
    { print }
  ' "$1" > "$1.2nd" && mv "$1.2nd" "$1"
}

# assert_pass <설명> <변형 명령...>
#
# 통과를 기대하는 변형이다. assert_missing 과 짝을 이뤄 "허용하기로 한 입력"이 실제로
# 종료 코드 0인지 고정한다. 허용 범위를 문서에만 적어 두면 이후 보정이 조용히 좁힌다.
assert_pass() {
  local desc="$1"; shift
  local f="$TMP/case.md" out rc
  cp "$BASE" "$f"
  "$@" "$f" || { ng "$desc — 변형 실패"; return; }
  out="$("$CHECK" "$f" 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ]; then
    ok "$desc"
  else
    ng "$desc — exit 0 기대, 실제 $rc ($(printf '%s' "$out" | tr '\n' ' '))"
  fi
}

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
assert_missing '프로젝트 규칙 표 헤더 이름(5차 audit F-5 반례)' '헤더 이름'          m_rules_hdr
assert_missing '프로젝트 규칙 표 헤더 순서'      '헤더 이름'                          m_rules_ord
assert_pass    '프로젝트 규칙 표 사용자 확장 열 허용'                                m_rules_4col
assert_missing 'context-loading.md 경로가 확장 열에만 있음(3차 audit F-8 반례)' 'context-loading.md` 행' m_ctx_in_ext
assert_missing 'writing-principles.md 경로가 확장 열에만 있음(3차 audit F-8 반례)' 'writing-principles.md` 행' m_wr_in_ext
assert_missing 'context-loading.md 행이 두 번째 표에만 있음(4차 audit F-9 반례)' 'context-loading.md` 행' m_rows_in_2nd
assert_missing 'writing-principles.md 행이 두 번째 표에만 있음(4차 audit F-9 반례)' 'writing-principles.md` 행' m_rows_in_2nd
assert_missing 'SSoT 선언 doc ssot_dir 행 없음 격추' 'ssot_dir` 행'           m_doc_noroot
assert_pass    'SSoT 선언 doc 문구 통과'                                      m_doc_root
assert_missing 'SSoT 선언 doc 전환 전 dev 표준 문구 잔존 격추(PR #115 리뷰 반례)' 'doc 선언의 충돌 우선순위' m_doc_dev_text
assert_missing 'SSoT 선언 doc dev 우선순위만 잔존 격추'          'doc 선언의 충돌 우선순위'                  m_doc_prio_dev
assert_missing 'SSoT 선언 doc 디렉토리 구조 트리 설명만 잔존 격추' "'## .ai 디렉토리 구조' 트리에 dev 표준 설명" m_doc_tree_dev
assert_missing 'SSoT 선언 doc 진입 절차 2번 설명만 잔존 격추'     "'### 진입 절차' 2번에 dev 표준 설명"        m_doc_entry_dev
assert_missing 'SSoT 선언 doc 작성 규칙 설명만 잔존 격추'         "'### 작성 규칙'에 dev 표준 설명"           m_doc_rule_dev
assert_pass    'SSoT 선언 doc 사용자 작성 우선순위 보존'                        m_doc_prio_custom
assert_missing 'SSoT 선언 doc 유사 문구 격추' '본문 두 번째 줄 SSoT'           m_near_with_root

# --- 건물 repo SSoT 선언 ----------------------------------------------------------
#
# 헬퍼는 입력 파일 옆 `60_codebase/repository.yaml` 존재로 건물 repo를 판정한다.
# 위 케이스들은 `$TMP/case.md` 옆에 그 파일이 없어야 하므로 repo 구조를 별도 디렉토리에 만든다.

# assert_building <설명> <프로파일 템플릿> <repository.yaml 유무 yes|no> <기대 exit> <건물 보고 기대 yes|no> [<2번째 줄 치환>]
assert_building() {
  local desc="$1" src="$2" yaml="$3" want_rc="$4" want_msg="$5" line2="${6:-}" dir out rc hit=no
  dir="$(mktemp -d "$TMP/bld.XXXXXX")"
  mkdir -p "$dir/.ai/60_codebase"
  [ "$yaml" = yes ] && : > "$dir/.ai/60_codebase/repository.yaml"
  prepare "$src" "$dir/.ai/AI-CONTEXT.md"
  if [ -n "$line2" ]; then
    sed -i.bak "s/^> SSoT: .*/$line2/" "$dir/.ai/AI-CONTEXT.md" && rm -f "$dir/.ai/AI-CONTEXT.md.bak"
  fi
  out="$("$CHECK" "$dir/.ai/AI-CONTEXT.md" 2>&1)"; rc=$?
  printf '%s\n' "$out" | grep -qF '건물 repo 선언' && hit=yes
  if [ "$rc" -eq "$want_rc" ] && [ "$hit" = "$want_msg" ]; then
    ok "$desc"
  else
    ng "$desc — exit $want_rc·건물 보고 $want_msg 기대, 실제 exit $rc·건물 보고 $hit ($(printf '%s' "$out" | tr '\n' ' '))"
  fi
}

assert_building '건물 repo doc 선언 보고 격추'                       "$TPL_DIR/doc/.ai/AI-CONTEXT.md" yes 1 yes
assert_building '건물 repo dev 선언 무보고 통과'                     "$TPL_DIR/dev/.ai/AI-CONTEXT.md" yes 0 no
assert_building '건물 repo 아님(repository.yaml 없음) doc 선언 무보고 통과' "$TPL_DIR/doc/.ai/AI-CONTEXT.md" no 0 no
assert_building '건물 repo 비표준 선언 중복 보고 없음 통과'           "$TPL_DIR/dev/.ai/AI-CONTEXT.md" yes 1 no '> SSoT: 알아서 판단할 것.'

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
# 헬퍼가 다루는 9종 외 2종(디렉토리 구조 관련)은 의도적으로 제외했다.
# SKILL.md 표가 늘면 이 검사가 걸려 제외 범위를 다시 판단하게 한다.

rows="$(awk '
  /^#### 멱등 보강 검사/ { f = 1; next }
  f && /^#### / { exit }
  f && /^\|/ { n++ }
  END { print n + 0 }
' "$SKILL")"
# 헤더·구분선 2행을 뺀 항목 수
items=$((rows - 2))
[ "$items" -eq 11 ] \
  && ok "SKILL.md 멱등 보강 검사 표: ${items}행 (헬퍼 9종 + 트리 관련 2종 제외)" \
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
