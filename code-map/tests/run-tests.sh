#!/usr/bin/env bash
#
# code-map 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# 이 스킬은 scripts/ 가 없어 색인 동작이 SKILL.md 와 references/ 의 절차 문장에 있다.
# 원본 문서 색인 절차(references/doc.md)와 SKILL.md 의 모드 분기 규칙 문장이 제자리에 있는지를 [D] 로 보고,
# 규칙을 하나씩 되돌린 사본이 격추되는지로 검사가 실제로 동작함을 확인한다 (#114 최종 감사 F-3).
#
# 절차를 입력에 적용한 결과(어떤 행을 만들고 지우며 Why 태깅을 어디에 남기는지)는
# fixtures/doc-index/ 의 입력·기대 쌍으로 [QD] 모의 실행한다. 여기서는 그 쌍이 빠짐없이 있는지만 본다.
# local.md·global.md(소스 코드·건물 색인 절차)는 0단계 골격 판정 문장만 같은 방식으로 검사한다 (#116).
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
DOC="$HERE/../references/doc.md"
LOCAL="$HERE/../references/local.md"
GLOBAL="$HERE/../references/global.md"
FIX="$HERE/fixtures/doc-index"
# ai-workspace init 이 복사하는 색인 골격. doc.md·local.md·global.md 0단계가 이 골격을 미생성으로 판정한다.
TEMPLATE="$HERE/../../ai-workspace/templates/shared/.ai/60_codebase/index.md"
PLACEHOLDER='(문서를 추가하면 이 목록에 함께 기재하세요)'

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

for f in "$SKILL" "$DOC" "$LOCAL" "$GLOBAL" "$FIX/README.md" "$TEMPLATE"; do
  [ -r "$f" ] || { echo "NOT OK - 파일을 찾을 수 없습니다 — $f"; exit 1; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# sec <파일> <제목 행> — 제목 행 다음부터 같은 수준 이상의 다음 제목 전까지 출력한다.
# 코드 블록 안의 `#` 행은 제목으로 보지 않는다 (doc.md 1-3의 index.md 예시가 `# `·`## ` 행을 담는다).
sec() {
  awk -v h="$2" '
    /^[[:space:]]*```/ { code = !code }
    !code && $0 == h { f = 1; n = index(h, " "); next }
    f && !code && /^#+ / && index($0, " ") <= n { exit }
    f' "$1"
}

# has <본문> <문자열> — 고정 문자열 포함 여부.
has() { printf '%s\n' "$1" | grep -qF -- "$2"; }

# violations <references/doc.md> <SKILL.md> — 어긋난 규칙을 1행씩 출력한다. 무출력이면 통과.
violations() {
  local doc="$1" skill="$2" s line
  s="$(sec "$doc" '## 트리거 조건')"
  has "$s" '선언 값이 `원본 문서`일 때' || echo '트리거 원본 문서'
  has "$s" '선언 값이 `소스 코드`이거나 선언을 찾지 못하면 이 파일 대신 [local.md](local.md)를 따른다' || echo '트리거 폴백'
  sec "$doc" '## 파일 구조' | grep -qE '^ssot_dir: ' || echo 'frontmatter ssot_dir 키'

  s="$(sec "$doc" '### 0단계: 모드 결정')"
  line="$(printf '%s\n' "$s" | grep -E '^- \*\*미생성\*\* → `build`')"
  { has "$line" '템플릿 골격만 있는 상태다' && has "$line" "자리표시자 \`$PLACEHOLDER\` 하나뿐"; } || echo '골격 미생성 판정'
  has "$s" '`sync`는 `rebuild`로 전환한다' || echo '루트 불일치 sync 전환'
  has "$s" 'Why 태깅은 보존하고' || echo '루트 불일치 rebuild Why 보존'
  has "$s" '`check`는 3단계의 루트 불일치 판정으로 넘긴다' || echo '루트 불일치 check 위임'

  s="$(sec "$doc" '### 1단계: 원본 문서 색인')"
  has "$s" '- build / rebuild: 안내도 `ssot_dir` 아래 문서 파일 전체' || echo 'build 범위'
  has "$s" '자리표시자(`<...>`)이면 사용자에게 묻는다' || echo 'ssot_dir 부재 질의'
  line="$(printf '%s\n' "$s" | grep -E '^- sync:')"
  has "$line" '0단계 루트 대조에서 두 값이 같을 때만 수행한다' || echo 'sync 동일 루트 조건'
  { has "$line" '--name-status -M' && ! has "$line" '--name-only'; } || echo 'sync 이름 변경 입력'
  has "$s" '색인 반영을 마친 뒤에만 갱신한다' || echo '메타데이터 갱신 시점'
  has "$s" '**삭제된 파일**(`D`)은 해당 행을 index.md에서 제거한다' || echo '삭제 행 제거'
  has "$s" '두 경로 모두 `ssot_dir` 아래: 새 행을 만들고 옛 행의 Why 태깅을 새 행으로 옮긴 뒤 옛 행을 지운다' || echo '이름 변경 Why 이전'
  has "$s" '이전 경로만 `ssot_dir` 아래(루트 밖으로 이동): 옛 행을 지운다' || echo '루트 밖 이동'
  has "$s" '새 경로만 `ssot_dir` 아래(루트 안으로 이동): 새 행을 만든다' || echo '루트 안 이동'
  printf '%s\n' "$s" | grep -qxF '| 파일 경로 | 다루는 주제 | 관련 문서 |' || echo '색인 3열'
  has "$s" '`[WHY-NEEDED]`로 표시' || echo 'WHY-NEEDED 표시'

  s="$(sec "$doc" '### 2단계: 교차 참조 연결')"
  has "$s" '**존재하는 문서만 링크한다**' || echo '존재 문서만 링크'
  has "$s" '**외부 URL은 교차 참조 대상이 아니다**' || echo '외부 URL 교차 참조 제외'
  has "$s" '퍼블리싱 URL(안내도 `publish` 행의 위치 포함)도 색인에 두지 않는다' || echo '퍼블리싱 URL 제외'

  sec "$doc" '### 3단계: 정합성 점검' | grep -E '^\| 루트 불일치 \|' | grep -F '[UPDATE-NEEDED]' | grep -qF 'rebuild를 권고' \
    || echo '점검 표 루트 불일치'
  has "$(sec "$doc" '### 3단계: 정합성 점검' | grep -E '^\| 파일 유효성 \|')" '`check`는 **행을 지우지 않고 `[UPDATE-NEEDED]`로 보고한다.**' \
    || echo '파일 유효성 check 보존'
  has "$(sec "$doc" '### 4단계: 결과 보고')" '문서 색인: N건 (신규 N / 갱신 N / 삭제 N)' || echo '보고 문서 색인 건수'

  has "$(sec "$skill" '### SSoT 원칙')" '선언을 찾지 못하면 소스 코드를 SSoT로 본다' || echo 'SKILL.md 선언 부재 폴백'
  has "$(sec "$skill" '## 모드별 실행 절차')" '| `--local` (floor, 원본 문서) | [references/doc.md](references/doc.md) |' \
    || echo 'SKILL.md 모드 표 doc.md 행'
  has "$(sec "$skill" '## 적용 대상')" '**원본 문서 저장소**' || echo 'SKILL.md 적용 대상'
}

# local_violations <references/local.md> — 0단계 골격 판정이 doc.md 와 같은지 본다. 무출력이면 통과.
local_violations() {
  local s line
  s="$(sec "$1" '### 0단계: 모드 결정')"
  line="$(printf '%s\n' "$s" | grep -E '^- \*\*미생성\*\* → `build`')"
  { has "$line" '템플릿 골격만 있는 상태다' && has "$line" "자리표시자 \`$PLACEHOLDER\` 하나뿐"; } || echo 'local 골격 미생성 판정'
  printf '%s\n' "$s" | grep -qE '^- \*\*생성됨\*\*' || echo 'local 생성됨 분기'
}

# global_violations <references/global.md> — 0단계 4·5번이 골격을 색인 없음으로 보는지 본다. 무출력이면 통과.
# 4·5번 하위 행은 들여쓰기가 있어 앵커가 앞 공백을 허용한다.
global_violations() {
  local s line
  s="$(sec "$1" '### 0단계: 리포 목록 확인 및 모드 결정')"
  has "$s" "자리표시자 \`$PLACEHOLDER\` 하나뿐" || echo 'global 골격 기준'
  line="$(printf '%s\n' "$s" | grep -E '^[[:space:]]*- \*\*미분석\*\*')"
  has "$line" '템플릿 골격만 있는' || echo 'global 미분석 골격'
  line="$(printf '%s\n' "$s" | grep -E '^[[:space:]]*- \*\*미생성\*\* → `build`')"
  has "$line" '템플릿 골격만 있는 상태다' || echo 'global 미생성 골격'
}

# --- 현재 본문이 규칙을 모두 갖는다 ------------------------------------------------

out="$(violations "$DOC" "$SKILL")"
if [ -z "$out" ]; then
  ok "원본 문서 색인 규칙 통과"
else
  ng "원본 문서 색인 규칙 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
fi

out="$(local_violations "$LOCAL")"
if [ -z "$out" ]; then
  ok "local 0단계 골격 판정 통과"
else
  ng "local 0단계 골격 판정 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
fi

out="$(global_violations "$GLOBAL")"
if [ -z "$out" ]; then
  ok "global 0단계 골격 판정 통과"
else
  ng "global 0단계 골격 판정 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
fi

# 골격 판정 기준이 실제 템플릿과 어긋나면 init 직후 색인을 생성됨으로 오판한다 (PR #115 리뷰).
if [ "$(head -n 1 "$TEMPLATE")" != '---' ] && grep -qxF "| $PLACEHOLDER | |" "$TEMPLATE"; then
  ok "골격 판정 기준과 ai-workspace 템플릿 일치"
else
  ng "골격 판정 기준과 ai-workspace 템플릿 일치 — frontmatter가 있거나 자리표시자 행이 다릅니다"
fi

# --- 규칙별 격추 -----------------------------------------------------------------
#
# 원본 사본에 변형 하나를 적용하고 그 규칙의 위반이 나오는지 본다.
# 위반 행을 정확히 대조해 다른 규칙이 대신 걸려 통과처럼 보이는 것을 막는다.
# 변형 대상 문자열이 없으면 "변형 실패"로 떨어져, 본문이 바뀌었는데 케이스가 헛도는 것을 막는다.

mkdir -p "$TMP/case"
C_DOC="$TMP/case/doc.md"
C_SKILL="$TMP/case/SKILL.md"
C_LOCAL="$TMP/case/local.md"
C_GLOBAL="$TMP/case/global.md"

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

# assert_reject <설명> <위반 행> <변형 명령...>
assert_reject() {
  local desc="$1" want="$2" out; shift 2
  cp "$DOC" "$C_DOC"; cp "$SKILL" "$C_SKILL"; cp "$LOCAL" "$C_LOCAL"; cp "$GLOBAL" "$C_GLOBAL"
  "$@" || { ng "$desc — 변형 실패"; return; }
  out="$(violations "$C_DOC" "$C_SKILL"; local_violations "$C_LOCAL"; global_violations "$C_GLOBAL")"
  if printf '%s\n' "$out" | grep -qxF "$want"; then
    ok "$desc"
  else
    ng "$desc — 위반에 '$want' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

assert_reject '트리거 선언 값 변경 격추'      '트리거 원본 문서'        sub_str "$C_DOC" '선언 값이 `원본 문서`일 때' '선언 값이 있을 때'
assert_reject '트리거 폴백 삭제 격추'         '트리거 폴백'             drop_line "$C_DOC" '이 파일 대신 [local.md](local.md)를 따른다'
assert_reject 'frontmatter ssot_dir 키 삭제 격추' 'frontmatter ssot_dir 키' drop_line "$C_DOC" '# 색인한 루트 경로'
assert_reject '골격 미생성 판정 삭제 격추'    '골격 미생성 판정'        cut_str "$C_DOC" '파일이 비어 있거나 템플릿 골격만 있는 상태다. '
assert_reject '골격 자리표시자 변경 격추'     '골격 미생성 판정'        sub_str "$C_DOC" "$PLACEHOLDER" '(자리표시자)'
assert_reject '루트 불일치 sync 전환 삭제 격추' '루트 불일치 sync 전환'  cut_str "$C_DOC" '`sync`는 `rebuild`로 전환한다. '
assert_reject '루트 불일치 Why 보존 삭제 격추' '루트 불일치 rebuild Why 보존' cut_str "$C_DOC" 'Why 태깅은 보존하고, '
assert_reject '루트 불일치 check 위임 삭제 격추' '루트 불일치 check 위임' drop_line "$C_DOC" '`check`는 3단계의 루트 불일치 판정으로 넘긴다'
assert_reject 'build 범위 확대 격추'          'build 범위' \
  sub_str "$C_DOC" '- build / rebuild: 안내도 `ssot_dir` 아래 문서 파일 전체' '- build / rebuild: repo 전체 문서 파일'
assert_reject 'ssot_dir 부재 질의 삭제 격추'  'ssot_dir 부재 질의'      drop_line "$C_DOC" '자리표시자(`<...>`)이면 사용자에게 묻는다'
assert_reject 'sync 동일 루트 조건 삭제 격추' 'sync 동일 루트 조건'     cut_str "$C_DOC" '0단계 루트 대조에서 두 값이 같을 때만 수행한다. '
assert_reject 'sync 입력 --name-only 원복 격추' 'sync 이름 변경 입력'   sub_str "$C_DOC" '--name-status -M' '--name-only'
assert_reject '메타데이터 갱신 시점 삭제 격추' '메타데이터 갱신 시점'   drop_line "$C_DOC" '색인 반영을 마친 뒤에만 갱신한다'
assert_reject '삭제 행 제거 삭제 격추'        '삭제 행 제거'            drop_line "$C_DOC" '**삭제된 파일**(`D`)'
assert_reject '이름 변경 Why 이전 삭제 격추'  '이름 변경 Why 이전' \
  sub_str "$C_DOC" '새 행을 만들고 옛 행의 Why 태깅을 새 행으로 옮긴 뒤 옛 행을 지운다' '옛 행을 지우고 새 행을 만든다'
assert_reject '루트 밖 이동 삭제 격추'        '루트 밖 이동'            drop_line "$C_DOC" '이전 경로만 `ssot_dir` 아래(루트 밖으로 이동)'
assert_reject '루트 안 이동 삭제 격추'        '루트 안 이동'            drop_line "$C_DOC" '새 경로만 `ssot_dir` 아래(루트 안으로 이동)'
assert_reject '색인 열 축소 격추'             '색인 3열' \
  sub_str "$C_DOC" '| 파일 경로 | 다루는 주제 | 관련 문서 |' '| 파일 경로 | 다루는 주제 |'
assert_reject 'WHY-NEEDED 표시 삭제 격추'     'WHY-NEEDED 표시'         sub_str "$C_DOC" '`[WHY-NEEDED]`로 표시' '빈칸으로 두어 표시'
assert_reject '존재 문서만 링크 삭제 격추'    '존재 문서만 링크'        drop_line "$C_DOC" '**존재하는 문서만 링크한다**'
assert_reject '외부 URL 제외 삭제 격추'       '외부 URL 교차 참조 제외' drop_line "$C_DOC" '**외부 URL은 교차 참조 대상이 아니다**'
assert_reject '퍼블리싱 URL 제외 삭제 격추'   '퍼블리싱 URL 제외'       drop_line "$C_DOC" '퍼블리싱 URL(안내도 `publish` 행의 위치 포함)'
assert_reject '점검 표 루트 불일치 삭제 격추' '점검 표 루트 불일치'     drop_line "$C_DOC" '| 루트 불일치 |'
assert_reject '파일 유효성 check 보존 삭제 격추' '파일 유효성 check 보존' \
  cut_str "$C_DOC" '`check`는 **행을 지우지 않고 `[UPDATE-NEEDED]`로 보고한다.** '
assert_reject '보고 건수 축소 격추'           '보고 문서 색인 건수' \
  sub_str "$C_DOC" '문서 색인: N건 (신규 N / 갱신 N / 삭제 N)' '문서 색인: N건'
assert_reject 'SKILL.md 폴백 삭제 격추'       'SKILL.md 선언 부재 폴백' cut_str "$C_SKILL" '선언을 찾지 못하면 소스 코드를 SSoT로 본다.'
assert_reject 'SKILL.md 모드 표 doc.md 행 삭제 격추' 'SKILL.md 모드 표 doc.md 행' drop_line "$C_SKILL" '| `--local` (floor, 원본 문서) |'
assert_reject 'SKILL.md 적용 대상 삭제 격추'  'SKILL.md 적용 대상'      drop_line "$C_SKILL" '**원본 문서 저장소**'
assert_reject 'local 0단계 골격 판정 삭제 격추' 'local 골격 미생성 판정' cut_str "$C_LOCAL" '파일이 비어 있거나 템플릿 골격만 있는 상태다. '
assert_reject 'local 0단계 골격 자리표시자 변경 격추' 'local 골격 미생성 판정' sub_str "$C_LOCAL" "$PLACEHOLDER" '(자리표시자)'
assert_reject 'global 0단계 골격 미분석 삭제 격추' 'global 미분석 골격' \
  sub_str "$C_GLOBAL" '없거나 비어 있거나 템플릿 골격만 있는 리포' '없거나 비어 있는 리포'
assert_reject 'global 0단계 골격 build 분기 삭제 격추' 'global 미생성 골격' cut_str "$C_GLOBAL" '파일이 비어 있거나 템플릿 골격만 있는 상태다.'
assert_reject 'global 0단계 골격 자리표시자 변경 격추' 'global 골격 기준' sub_str "$C_GLOBAL" "$PLACEHOLDER" '(자리표시자)'

# --- 모의 실행 fixture 쌍 -------------------------------------------------------

cases="$(awk -F'`' '/^\| `[a-z0-9-]+` \|/ { print $2 }' "$FIX/README.md")"
if [ -z "$cases" ]; then
  ng "fixture: README 케이스 표에서 케이스를 찾지 못했습니다"
fi
for c in $cases; do
  if [ -r "$FIX/$c.input.md" ] && [ -r "$FIX/$c.expected.md" ]; then
    ok "fixture 쌍: $c"
  else
    ng "fixture 쌍: $c — input·expected 중 없는 파일이 있습니다"
  fi
done
for f in "$FIX"/*.input.md "$FIX"/*.expected.md; do
  [ -e "$f" ] || continue
  c="$(basename "$f")"; c="${c%.input.md}"; c="${c%.expected.md}"
  printf '%s\n' $cases | grep -qxF "$c" || ng "fixture: README 케이스 표에 없는 파일 — $(basename "$f")"
done

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
