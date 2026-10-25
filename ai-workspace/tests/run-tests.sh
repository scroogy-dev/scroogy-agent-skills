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

# --- update-1 문서 규약 복사 (SKILL.md 코드 블록 실행) ----------------------------
#
# 문서 규약은 사용자 관리 파일이라 update-1이 doc 프로파일에서만, 없을 때만 복사한다.
# 위 doc 템플릿 검사는 템플릿 쪽만 보므로 SKILL.md의 복사 분기를 지워도 통과한다 (#118 최종 감사 F-1).
# update-1단계 코드 블록을 그대로 꺼내 임시 repo에서 실행하고, 생긴 파일로 판정한다.

U1_BLOCK="$TMP/update1.sh"
CONV='.ai/10_rules/document-convention.md'

# update1_block <SKILL.md> → `### update-1단계` 절의 첫 bash 코드 블록 본문
update1_block() {
  awk '/^### update-1단계/ { f = 1; next }
       f && /^### / { exit }
       f && /^```bash$/ { c = 1; next }
       c && /^```$/ { exit }
       c' "$1"
}

# run_update1 <코드 블록 파일> <프로파일> <작업 디렉토리> — 블록을 그 디렉토리에서 실행한다.
run_update1() {
  (cd "$3" && SKILL_DIR="$HERE/.." PROFILE="$2" bash "$1") >/dev/null 2>&1
}

# update1_violations <코드 블록 파일> — 어긋난 동작을 1행씩 출력한다. 무출력이면 통과.
update1_violations() {
  local w
  w="$(mktemp -d "$TMP/u1.XXXXXX")"; mkdir -p "$w/.ai"
  run_update1 "$1" doc "$w"
  cmp -s "$w/$CONV" "$TPL_DIR/doc/$CONV" || echo 'doc 신규 복사'
  w="$(mktemp -d "$TMP/u1.XXXXXX")"; mkdir -p "$w/.ai/10_rules"; echo '사용자 내용' > "$w/$CONV"
  run_update1 "$1" doc "$w"
  [ "$(cat "$w/$CONV" 2>/dev/null)" = '사용자 내용' ] || echo 'doc 기존 내용 보존'
  w="$(mktemp -d "$TMP/u1.XXXXXX")"; mkdir -p "$w/.ai"
  run_update1 "$1" dev "$w"
  [ ! -e "$w/$CONV" ] || echo 'dev 미복사'
}

# assert_update1_reject <설명> <위반 행> <awk 변형 프로그램> — 변형 대상이 없으면 "변형 실패"로 떨어진다.
assert_update1_reject() {
  local f="$TMP/update1-case.sh" out
  awk "$3" "$U1_BLOCK" > "$f" || { ng "$1 — 변형 실패"; return; }
  out="$(update1_violations "$f")"
  if printf '%s\n' "$out" | grep -qxF "$2"; then
    ok "$1"
  else
    ng "$1 — 위반에 '$2' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

update1_block "$SKILL" > "$U1_BLOCK"
out="$(update1_violations "$U1_BLOCK")"
if [ -z "$out" ]; then
  ok "문서 규약 update-1 복사(doc 신규·기존 보존·dev 미복사) 통과"
else
  ng "문서 규약 update-1 복사(doc 신규·기존 보존·dev 미복사) 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
fi
assert_update1_reject '문서 규약 update-1 doc 분기 삭제 격추' 'doc 신규 복사' \
  '/^# doc 프로파일 전용/ { skip = 1; hit = 1 } skip && /^fi$/ { skip = 0; next } !skip { print } END { exit !hit }'
assert_update1_reject '문서 규약 update-1 보존 조건 삭제 격추' 'doc 기존 내용 보존' \
  'index($0, "[ ! -f .ai/10_rules/document-convention.md ] && \\") { hit = 1; next } { print } END { exit !hit }'
assert_update1_reject '문서 규약 update-1 프로파일 조건 변경 격추' 'dev 미복사' \
  '/^# doc 프로파일 전용/ { d = 1 } d && /^if \[ "\$PROFILE" = "doc" \]; then$/ { sub(/"doc"/, "\"dev\""); d = 0; hit = 1 } { print } END { exit !hit }'

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

# --- 문서 변형 도구 ---------------------------------------------------------------
#
# 아래 블록들은 원본 사본에 변형 하나를 적용하고 그 규칙의 위반이 나오는지 본다 (context-harvest 러너와 같은 방식).
# 변형 대상 문자열이 없으면 종료 코드 1로 "변형 실패"가 되어, 본문이 바뀌었는데 케이스가 헛도는 것을 막는다.

# sub_str <파일> <찾을 문자열> <바꿀 문자열> — 첫 등장 하나를 바꾼다(고정 문자열 대조).
sub_str() {
  awk -v s="$2" -v r="$3" '
    !done && (i = index($0, s)) { $0 = substr($0, 1, i - 1) r substr($0, i + length(s)); done = 1 }
    { print }
    END { exit !done }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}
cut_str() { sub_str "$1" "$2" ''; }

# drop_line <파일> <문자열> — 문자열을 포함한 행을 모두 지운다.
drop_line() {
  awk -v s="$2" 'index($0, s) { hit = 1; next } { print } END { exit !hit }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

# drop_sec <파일> <제목 행> — 제목 행부터 다음 `## ` 전까지 지운다.
drop_sec() {
  awk -v h="$2" '$0 == h { f = 1; hit = 1; next } f && /^## / { f = 0 } !f { print } END { exit !hit }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

# --- ADR index 수명 주기 ---------------------------------------------------------
#
# ADR을 쓰거나 고치는 쪽(이슈 작업, context-harvest)은 `50_adr/index.md`의 `## 수명 주기`에서
# 경우별 처리·상태 줄·옮길 때 갱신 규칙을 읽는다 (#121). 라벨 행과 인용 문구는 이슈 spec이 정한 경계다.
# 이 저장소 사본(`.ai/50_adr/index.md`)은 update가 덮어쓰지 않아 직접 고치므로 템플릿과 섹션 본문이 같은지도 본다
# (파일이 없으면 건너뛴다).

ADR_TPL="$TPL_DIR/shared/.ai/50_adr/index.md"
REPO_ADR="$HERE/../../.ai/50_adr/index.md"

# adr_sec <파일> — `## 수명 주기` 다음부터 다음 `## ` 전까지.
adr_sec() { awk '/^## 수명 주기$/ { f = 1; next } f && /^## / { exit } f' "$1"; }

# adr_line <섹션 본문> <라벨> <위반 행> <문자열...> — `- **<라벨>**:` 행이 정확히 1개이고 문자열을 모두 담는지 본다.
adr_line() {
  local s="$1" label="$2" bad="$3" l x; shift 3
  l="$(printf '%s\n' "$s" | grep -E "^- \*\*$label\*\*:")"
  [ "$(printf '%s\n' "$l" | grep -c .)" -eq 1 ] || { echo "$bad"; return; }
  for x in "$@"; do printf '%s' "$l" | grep -qF -- "$x" || { echo "$bad"; return; }; done
}

# adr_superseded_ok <파일> — 파일 목록 `superseded/` 행이 1개이고 새 설명으로 시작하며 옛 설명이 없다.
adr_superseded_ok() {
  [ "$(grep -c '^| `superseded/` |' "$1")" -eq 1 ] \
    && grep -q '^| `superseded/` | 대체·폐기된 결정' "$1" \
    && ! grep -qF '대체된 결정 (대체한 ADR 번호를 문서 내에 명시)' "$1"
}

# adr_violations <템플릿> [<사본>] — 어긋난 항목을 1행씩 출력한다. 무출력이면 통과.
# 표는 섹션 안 유일한 표로 보고, 헤더(`| 경우 |`)를 뺀 `| ` 행이 경우 행이다. 위치는 마지막 열이다.
adr_violations() {
  local t="$1" c="${2:-}" s rows loc
  [ "$(grep -c '^## 수명 주기$' "$t")" -eq 1 ] || echo '섹션 수'
  s="$(adr_sec "$t")"
  rows="$(printf '%s\n' "$s" | grep '^| ' | grep -v '^| 경우 |')"
  loc="$(printf '%s\n' "$rows" | awk -F'|' 'NF > 2 { print $(NF-1) }')"
  { [ "$(printf '%s\n' "$rows" | grep -c '^| ')" -eq 4 ] \
    && [ "$(printf '%s\n' "$loc" | grep -c 'active/')" -eq 2 ] \
    && [ "$(printf '%s\n' "$loc" | grep -c 'superseded/')" -eq 2 ]; } || echo '경우 행'
  adr_line "$s" '일부 변경과 대체의 경계' '경계 행' '결정 항목이 하나라도 유효하면'
  adr_line "$s" '상태 줄' '상태 줄 행' \
    '`- **상태**:`' '`유효`' '`대체(ADR <번호>)`' '`폐기(이슈 #N)`' '상태 줄이 없는 ADR은 `유효`로 봅니다'
  adr_line "$s" '대체·폐기된 ADR 읽기' '읽기 행' '제약으로 쓰지 않고 이력을 확인할 때만 읽습니다'
  adr_line "$s" '옮길 때 index 갱신' 'index 갱신 행' '`superseded/` 행 아래로'
  adr_line "$s" '들어오는 링크 갱신' '링크 갱신 행' \
    '`50_adr/active/<파일>`' '(`.ai/90_issues/archive/` 제외)' '상대 경로 깊이는 링크가 있는 문서 위치에서 다시 계산합니다' '파일명으로'
  printf '%s\n' "$s" | grep -E '^- \*\*들어오는 링크 갱신\*\*:' | grep -qE 'check-ledger-links|K-<번호>' \
    && echo '링크 갱신 원장 표기'
  adr_superseded_ok "$t" || echo 'superseded 설명'
  if [ -n "$c" ]; then
    { [ "$(grep -c '^## 수명 주기$' "$c")" -eq 1 ] && [ "$s" = "$(adr_sec "$c")" ]; } || echo '사본 섹션 불일치'
    adr_superseded_ok "$c" || echo '사본 superseded 설명'
  fi
}

# assert_adr_reject <설명> <위반 행> <변형 명령...> — 템플릿 사본과 사본 자리(템플릿 복제)를 만든 뒤 변형한다.
mkdir -p "$TMP/adr"
C_ADR="$TMP/adr/index.md"
C_ADR_COPY="$TMP/adr/copy.md"
assert_adr_reject() {
  local desc="$1" want="$2" out; shift 2
  cp "$ADR_TPL" "$C_ADR"; cp "$ADR_TPL" "$C_ADR_COPY"
  "$@" || { ng "$desc — 변형 실패"; return; }
  out="$(adr_violations "$C_ADR" "$C_ADR_COPY")"
  if printf '%s\n' "$out" | grep -qxF "$want"; then
    ok "$desc"
  else
    ng "$desc — 위반에 '$want' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

if [ -r "$ADR_TPL" ]; then
  if [ -r "$REPO_ADR" ]; then
    desc='ADR 수명 주기 템플릿 규칙·저장소 사본 일치 통과'; out="$(adr_violations "$ADR_TPL" "$REPO_ADR")"
  else
    desc='ADR 수명 주기 템플릿 규칙(저장소 사본 없음, 대조 건너뜀) 통과'; out="$(adr_violations "$ADR_TPL")"
  fi
  if [ -z "$out" ]; then
    ok "$desc"
  else
    ng "$desc — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
  assert_adr_reject 'ADR 수명 주기 섹션 삭제 격추'           '섹션 수'       drop_sec "$C_ADR" '## 수명 주기'
  assert_adr_reject 'ADR 수명 주기 경우 행 삭제 격추'        '경우 행'       drop_line "$C_ADR" '| 대체 결정 없이 폐기 |'
  assert_adr_reject 'ADR 수명 주기 경계 문구 삭제 격추'      '경계 행'       cut_str "$C_ADR" '결정 항목이 하나라도 유효하면 '
  assert_adr_reject 'ADR 수명 주기 상태 값 변경 격추'        '상태 줄 행'    sub_str "$C_ADR" '`폐기(이슈 #N)` 중' '`폐기` 중'
  assert_adr_reject 'ADR 수명 주기 읽기 규칙 삭제 격추'      '읽기 행'       drop_line "$C_ADR" '- **대체·폐기된 ADR 읽기**:'
  assert_adr_reject 'ADR 수명 주기 index 갱신 행 삭제 격추'  'index 갱신 행' drop_line "$C_ADR" '- **옮길 때 index 갱신**:'
  assert_adr_reject 'ADR 수명 주기 링크 확인 수단 변경 격추' '링크 갱신 행'  sub_str "$C_ADR" '옮긴 ADR 파일명으로' '옮긴 ADR 이름으로'
  assert_adr_reject 'ADR 수명 주기 링크 갱신 원장 표기 원복 격추' '링크 갱신 원장 표기' \
    sub_str "$C_ADR" '`50_adr/active/<파일>`' '`70_ledger/active/K-<번호>-`'
  assert_adr_reject 'ADR 수명 주기 superseded 설명 원복 격추' 'superseded 설명' \
    sub_str "$C_ADR" '대체·폐기된 결정 (상태 줄에 대체한 ADR 번호 또는 폐기 이슈 번호를 적음)' '대체된 결정 (대체한 ADR 번호를 문서 내에 명시)'
  assert_adr_reject 'ADR 수명 주기 사본 섹션 불일치 격추'    '사본 섹션 불일치' \
    sub_str "$C_ADR_COPY" '제자리에서 고칩니다.' '제자리에서 고칩니다. 사본에만 있는 문장입니다.'
  assert_adr_reject 'ADR 수명 주기 사본 superseded 설명 원복 격추' '사본 superseded 설명' \
    sub_str "$C_ADR_COPY" '대체·폐기된 결정 (상태 줄에 대체한 ADR 번호 또는 폐기 이슈 번호를 적음)' '대체된 결정 (대체한 ADR 번호를 문서 내에 명시)'
else
  ng "ADR 수명 주기: 템플릿을 찾을 수 없습니다 — $ADR_TPL"
fi

# --- update-3 ADR 판정 -----------------------------------------------------------
#
# update-3 "기존 파일 정리"는 `50_adr/` 루트 파일을 상태 줄 값으로 나눈다 (#121).
# 본문 키워드 판정은 유효한 ADR(0007·0018 등)도 `superseded/`로 옮기므로 키워드 어휘가 남지 않았는지도 본다.
# 같은 파일의 하위 디렉토리 구조 표에도 `` | `50_adr/` | `` 행이 있어 `**이동 판단 기준:**` 뒤에서만 찾는다.

# u3_adr_violations <SKILL.md> — 어긋난 항목을 1행씩 출력한다. 무출력이면 통과.
u3_adr_violations() {
  local row x
  row="$(awk '/^\*\*이동 판단 기준:\*\*/ { f = 1; next } f && /^#/ { exit } f && /^\| `50_adr\/` \|/' "$1")"
  [ "$(printf '%s\n' "$row" | grep -c .)" -eq 1 ] || echo '판정 행 수'
  for x in '`- **상태**:`' '`대체(ADR <번호>)`' '`폐기(이슈 #N)`' '`superseded/`' '상태 줄이 없으면 `active/`'; do
    printf '%s' "$row" | grep -qF -- "$x" || { echo '판정 행 문구'; break; }
  done
  grep -qE 'deprecated|replaced' "$1" && echo '키워드 어휘'
}

mkdir -p "$TMP/skill"
C_SKILL="$TMP/skill/SKILL.md"

# assert_u3_adr_reject <설명> <위반 행> <변형 명령...>
assert_u3_adr_reject() {
  local desc="$1" want="$2" out; shift 2
  cp "$SKILL" "$C_SKILL"
  "$@" || { ng "$desc — 변형 실패"; return; }
  out="$(u3_adr_violations "$C_SKILL")"
  if printf '%s\n' "$out" | grep -qxF "$want"; then
    ok "$desc"
  else
    ng "$desc — 위반에 '$want' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

out="$(u3_adr_violations "$SKILL")"
if [ -z "$out" ]; then
  ok 'update-3 ADR 판정 상태 줄 기준 통과'
else
  ng "update-3 ADR 판정 상태 줄 기준 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
fi
assert_u3_adr_reject 'update-3 ADR 판정 키워드 판정 원복 격추' '키워드 어휘' \
  sub_str "$C_SKILL" 'ADR의 `- **상태**:` 값이 `대체(ADR <번호>)`·`폐기(이슈 #N)`이면 `superseded/`, `유효`이거나 상태 줄이 없으면 `active/`로 이동' \
  '`superseded`, `deprecated`, `replaced` 등의 키워드가 있으면 `superseded/`, 아니면 `active/`로 이동'
assert_u3_adr_reject 'update-3 ADR 판정 상태 줄 없음 분기 삭제 격추' '판정 행 문구' \
  sub_str "$C_SKILL" '`유효`이거나 상태 줄이 없으면 `active/`' '`유효`이면 `active/`'
assert_u3_adr_reject 'update-3 ADR 판정 행 삭제 격추' '판정 행 수' drop_line "$C_SKILL" '| `50_adr/` | ADR의'

# --- update-3 fixture ------------------------------------------------------------
#
# update-3 "기존 파일 정리"는 AI가 수행하는 절차라 이동 결과는 fixtures/update3-file-cleanup/ 의
# 입력·기대 쌍으로 [QD] 모의 실행한다 (K-0001, #121). 여기서는 README 케이스 표의 `대상 행`이
# SKILL.md 이동 판단 기준 표의 디렉토리와 루트 상주 파일·`legacy/`를 모두 덮는지, 케이스 쌍이 빠짐없는지를 본다.
# 판단 기준 표에 행이 늘면 대상 행 대조가 실패해 fixture를 함께 늘리게 한다.

U3_FIX="$HERE/fixtures/update3-file-cleanup"

# u3_dirs <SKILL.md> — 이동 판단 기준 표의 디렉토리(백틱 안) 목록.
u3_dirs() {
  awk '/^\*\*이동 판단 기준:\*\*/ { f = 1; next } f && /^#/ { exit } f && /^\| `/' "$1" | awk -F'`' '{ print $2 }'
}
# u3_cases <fixture 디렉토리> — README 케이스 표의 케이스명 목록.
u3_cases() { awk -F'`' '/^\| `[a-z0-9-]+` \|/ { print $2 }' "$1/README.md"; }

# u3_cover_violations <SKILL.md> <fixture 디렉토리> — 대상 행 열이 덮지 못한 항목을 1행씩 출력한다.
u3_cover_violations() {
  local dirs cov d
  dirs="$(u3_dirs "$1")"
  [ -n "$dirs" ] || echo '판단 기준 표 추출'
  cov="$(awk -F'|' '/^\| `[a-z0-9-]+` \|/ { print $3 }' "$2/README.md")"
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    printf '%s\n' "$cov" | grep -qF "\`$d\`" || echo "대상 행 미포함 — $d"
  done <<< "$dirs"
  printf '%s\n' "$cov" | grep -qF '루트 상주 파일' || echo '대상 행 미포함 — 루트 상주 파일'
  printf '%s\n' "$cov" | grep -qF '`legacy/`' || echo '대상 행 미포함 — legacy/'
}

# u3_pair_violations <fixture 디렉토리> — 케이스 쌍 누락과 표에 없는 파일을 1행씩 출력한다.
u3_pair_violations() {
  local cases c f
  cases="$(u3_cases "$1")"
  [ -n "$cases" ] || echo '케이스 표 추출'
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    { [ -r "$1/$c.input.md" ] && [ -r "$1/$c.expected.md" ]; } || echo "쌍 없음 — $c"
  done <<< "$cases"
  for f in "$1"/*.input.md "$1"/*.expected.md; do
    [ -e "$f" ] || continue
    c="$(basename "$f")"; c="${c%.input.md}"; c="${c%.expected.md}"
    printf '%s\n' "$cases" | grep -qxF "$c" || echo "표에 없는 파일 — $(basename "$f")"
  done
}

C_U3_FIX="$TMP/u3-fix"

# assert_u3_fix_reject <설명> <위반 행> <변형 명령...> — SKILL.md 사본과 fixture 디렉토리 사본을 만든 뒤 변형한다.
assert_u3_fix_reject() {
  local desc="$1" want="$2" out; shift 2
  cp "$SKILL" "$C_SKILL"; rm -rf "$C_U3_FIX"; cp -R "$U3_FIX" "$C_U3_FIX"
  "$@" || { ng "$desc — 변형 실패"; return; }
  out="$(u3_cover_violations "$C_SKILL" "$C_U3_FIX"; u3_pair_violations "$C_U3_FIX")"
  if printf '%s\n' "$out" | grep -qxF "$want"; then
    ok "$desc"
  else
    ng "$desc — 위반에 '$want' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

if [ -r "$U3_FIX/README.md" ]; then
  out="$(u3_cover_violations "$SKILL" "$U3_FIX")"
  if [ -z "$out" ]; then
    ok 'update-3 fixture 대상 행 대조 통과'
  else
    ng "update-3 fixture 대상 행 대조 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
  out="$(u3_pair_violations "$U3_FIX")"
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    if printf '%s\n' "$out" | grep -qxF "쌍 없음 — $c"; then
      ng "update-3 fixture 쌍: $c — input·expected 중 없는 파일이 있습니다"
    else
      ok "update-3 fixture 쌍: $c 통과"
    fi
  done <<< "$(u3_cases "$U3_FIX")"
  while IFS= read -r l; do
    [ -n "$l" ] && ng "update-3 fixture: $l"
  done <<< "$(printf '%s\n' "$out" | grep -v '^쌍 없음 — ')"
  assert_u3_fix_reject 'update-3 fixture 판단 기준 표 행 추가 격추' '대상 행 미포함 — 60_codebase/' \
    sub_str "$C_SKILL" '| `70_ledger/` | 항목의' '| `60_codebase/` | 격추용 행 |\n| `70_ledger/` | 항목의'
  assert_u3_fix_reject 'update-3 fixture 대상 행 50_adr 제거 격추' '대상 행 미포함 — 50_adr/' \
    sub_str "$C_U3_FIX/README.md" '`50_adr/`·루트 상주 파일' '루트 상주 파일'
  assert_u3_fix_reject 'update-3 fixture expected 파일 누락 격추' '쌍 없음 — adr' rm "$C_U3_FIX/adr.expected.md"
  assert_u3_fix_reject 'update-3 fixture 표에 없는 파일 격추'     '표에 없는 파일 — stray.input.md' \
    cp "$U3_FIX/adr.input.md" "$C_U3_FIX/stray.input.md"
else
  ng "update-3 fixture: README를 찾을 수 없습니다 — $U3_FIX/README.md"
fi

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
