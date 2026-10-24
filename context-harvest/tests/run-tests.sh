#!/usr/bin/env bash
#
# context-harvest 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# 이 스킬은 scripts/ 가 없어 수집 동작이 SKILL.md 절차 문장과 templates/ 에 있다.
# 수집 필터·퍼블리싱 제외·근거 출처 섹션의 규칙 문장이 제자리에 있는지를 [D] 로 보고,
# 규칙을 하나씩 되돌린 사본이 격추되는지로 검사가 실제로 동작함을 확인한다 (#114 최종 감사 F-3).
#
# 규칙을 입력에 적용한 결과(무엇을 수집·제외하고 근거 출처 섹션을 남길지)는
# fixtures/collect-filter/ 의 입력·기대 쌍으로 [QD] 모의 실행한다. 여기서는 그 쌍이 빠짐없이 있는지만 본다.
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
TPL="$HERE/../templates/40_domain-template.md"
FIX="$HERE/fixtures/collect-filter"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

for f in "$SKILL" "$TPL" "$FIX/README.md"; do
  [ -r "$f" ] || { echo "NOT OK - 파일을 찾을 수 없습니다 — $f"; exit 1; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# sec <파일> <제목 행> — 제목 행 다음부터 같은 수준 이상의 다음 제목 전까지 출력한다.
# 코드 블록 안의 `#` 행은 제목으로 보지 않는다 (실행 결과 보고 예시가 `## ` 행을 담는다).
sec() {
  awk -v h="$2" '
    /^[[:space:]]*```/ { code = !code }
    !code && $0 == h { f = 1; n = index(h, " "); next }
    f && !code && /^#+ / && index($0, " ") <= n { exit }
    f' "$1"
}

# has <본문> <문자열> — 고정 문자열 포함 여부.
has() { printf '%s\n' "$1" | grep -qF -- "$2"; }

# violations <SKILL.md> <40_domain 템플릿> — 어긋난 규칙을 1행씩 출력한다. 무출력이면 통과.
violations() {
  local skill="$1" tpl="$2" s a b
  s="$(sec "$skill" '### SSoT 원칙 유지')"
  has "$s" '`AI-CONTEXT.md` 본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)의 `> SSoT: <값>.` 선언을 따른다' || echo '선언 위치'
  has "$s" '그 외 값은 선언으로 보지 않는다' || echo '허용 값'
  has "$s" '`원본 문서`(`## 프로젝트 도메인` 표 `ssot_dir` 아래 `.md` 파일.' || echo '원본 문서 .md 정의'
  has "$s" '다른 확장자·첨부의 분류는 repo 문서 규약 파일(`.ai/10_rules/document-convention.md`)이 정한다' || echo '문서 규약 위임'
  has "$s" '선언을 찾지 못하면 소스 코드를 SSoT로 본다' || echo '선언 부재 폴백'
  has "$s" '선언이 원본 문서이면 `ssot_dir` 아래 문서에 반영된 사실이 대상이다' || echo '원본 문서 수집 대상'
  has "$s" 'SSoT에 대응하지 않는 정보(기각된 제안, 미구현 요청 등)는 수집하지 않는다' || echo '대응하지 않는 정보 제외'
  has "$s" '`publish` 행에 적힌 위치 아래 자료는 판단 없이 제외한다' || echo 'publish 아래 자료 제외'
  has "$s" 'SSoT 내용을 내보낸 사본은 출처로 인용하지 않고 repo 문서를 링크한다' || echo '퍼블리싱 판정 규칙 문장'
  has "$s" 'SSoT에서 파생하지 않은 자료는 출처로 수집한다' || echo '비파생 자료 수집'
  sec "$skill" '## 수집 제외 대상' | grep -qE '^\| 퍼블리싱 사본' || echo '수집 제외 표 퍼블리싱 사본 행'

  s="$(sec "$skill" '### 4단계: 증류 및 분류')"
  has "$s" 'SSoT 선언이 원본 문서이면 40_domain 문서의 `근거 출처` 섹션' || echo '4단계 근거 출처 채움'
  has "$s" '소스 코드가 SSoT이면 이 섹션을 지운다' || echo '4단계 근거 출처 삭제'

  [ "$(grep -c '^## 근거 출처$' "$tpl")" -eq 1 ] || echo '템플릿 근거 출처 섹션'
  a="$(grep -n '^## 근거 출처$' "$tpl" | head -1 | cut -d: -f1)"
  b="$(grep -n '^## 원본 출처$' "$tpl" | head -1 | cut -d: -f1)"
  { [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; } || echo '템플릿 근거 출처 위치'
  sec "$tpl" '## 근거 출처' | grep -qxF '| 출처 | 조항 | 시행일 | 확인일 |' || echo '템플릿 근거 출처 4열'
  [ "$(grep -c '^## 원본 반영' "$tpl")" -eq 0 ] || echo '템플릿 원본 반영 섹션'
  [ "$(sed -n '1,5p' "$tpl" | sed 's/:.*//' | tr '\n' ' ')" = '--- source source_url last_harvested --- ' ] \
    || echo '템플릿 frontmatter 3키'
}

# --- 현재 본문이 규칙을 모두 갖는다 ------------------------------------------------

out="$(violations "$SKILL" "$TPL")"
if [ -z "$out" ]; then
  ok "수집 필터 규칙 통과"
else
  ng "수집 필터 규칙 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
fi

# --- 규칙별 격추 -----------------------------------------------------------------
#
# 원본 사본에 변형 하나를 적용하고 그 규칙의 위반이 나오는지 본다.
# 위반 행을 정확히 대조해 다른 규칙이 대신 걸려 통과처럼 보이는 것을 막는다.
# 변형 대상 문자열이 없으면 "변형 실패"로 떨어져, 본문이 바뀌었는데 케이스가 헛도는 것을 막는다.

mkdir -p "$TMP/case"
C_SKILL="$TMP/case/SKILL.md"
C_TPL="$TMP/case/tpl.md"

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

# move_sec_end <파일> <제목 행> — 그 절을 파일 끝으로 옮긴다.
move_sec_end() {
  awk -v h="$2" '
    $0 == h { f = 1; hit = 1 }
    f && /^## / && $0 != h { f = 0 }
    f { buf = buf $0 "\n"; next }
    { print }
    END { printf "%s", buf; exit !hit }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

add_line() { printf '\n%s\n' "$2" >> "$1"; }

# assert_reject <설명> <위반 행> <변형 명령...>
assert_reject() {
  local desc="$1" want="$2" out; shift 2
  cp "$SKILL" "$C_SKILL"; cp "$TPL" "$C_TPL"
  "$@" || { ng "$desc — 변형 실패"; return; }
  out="$(violations "$C_SKILL" "$C_TPL")"
  if printf '%s\n' "$out" | grep -qxF "$want"; then
    ok "$desc"
  else
    ng "$desc — 위반에 '$want' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

assert_reject '선언 위치 원복 격추'          '선언 위치' \
  sub_str "$C_SKILL" 'SSoT는 `AI-CONTEXT.md` 본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)의 `> SSoT: <값>.` 선언을 따른다.' 'SSoT는 소스코드이다.'
assert_reject '허용 값 문장 삭제 격추'        '허용 값'                 cut_str "$C_SKILL" ' 그 외 값은 선언으로 보지 않는다'
assert_reject '원본 문서 .md 정의 원복 격추'  '원본 문서 .md 정의'      sub_str "$C_SKILL" '`ssot_dir` 아래 `.md` 파일.' '`ssot_dir` 아래 문서 파일.'
assert_reject '문서 규약 위임 삭제 격추'      '문서 규약 위임' \
  cut_str "$C_SKILL" ' 다른 확장자·첨부의 분류는 repo 문서 규약 파일(`.ai/10_rules/document-convention.md`)이 정한다'
assert_reject '선언 부재 폴백 삭제 격추'      '선언 부재 폴백'          cut_str "$C_SKILL" '선언을 찾지 못하면 소스 코드를 SSoT로 본다.'
assert_reject '원본 문서 수집 대상 삭제 격추' '원본 문서 수집 대상' \
  cut_str "$C_SKILL" ' 선언이 원본 문서이면 `ssot_dir` 아래 문서에 반영된 사실이 대상이다.'
assert_reject '수집 필터 소스코드 원복 격추'  '대응하지 않는 정보 제외' sub_str "$C_SKILL" 'SSoT에 대응하지 않는 정보' '소스코드에 대응하지 않는 정보'
assert_reject 'publish 제외 삭제 격추'        'publish 아래 자료 제외' \
  cut_str "$C_SKILL" '`## 프로젝트 도메인` 표 `publish` 행에 적힌 위치 아래 자료는 판단 없이 제외한다. '
assert_reject '퍼블리싱 판정 규칙 문장 삭제 격추' '퍼블리싱 판정 규칙 문장' \
  sub_str "$C_SKILL" '"SSoT 내용을 내보낸 사본은 출처로 인용하지 않고 repo 문서를 링크한다"' '상황에 맞게'
assert_reject '비파생 자료 수집 삭제 격추'    '비파생 자료 수집' \
  cut_str "$C_SKILL" '이며, 위키·블로그에 있어도 SSoT에서 파생하지 않은 자료는 출처로 수집한다'
assert_reject '수집 제외 표 퍼블리싱 행 삭제 격추' '수집 제외 표 퍼블리싱 사본 행' drop_line "$C_SKILL" '| 퍼블리싱 사본('
assert_reject '4단계 근거 출처 조건 삭제 격추' '4단계 근거 출처 채움' \
  sub_str "$C_SKILL" 'SSoT 선언이 원본 문서이면 40_domain 문서의 `근거 출처` 섹션' '40_domain 문서의 `근거 출처` 섹션'
assert_reject '4단계 근거 출처 삭제 분기 삭제 격추' '4단계 근거 출처 삭제' cut_str "$C_SKILL" ' 소스 코드가 SSoT이면 이 섹션을 지운다.'
assert_reject '템플릿 근거 출처 섹션 삭제 격추' '템플릿 근거 출처 섹션'   drop_line "$C_TPL" '## 근거 출처'
assert_reject '템플릿 근거 출처 위치 이동 격추' '템플릿 근거 출처 위치'   move_sec_end "$C_TPL" '## 근거 출처'
assert_reject '템플릿 근거 출처 열 축소 격추'   '템플릿 근거 출처 4열' \
  sub_str "$C_TPL" '| 출처 | 조항 | 시행일 | 확인일 |' '| 출처 | 조항 | 시행일 |'
assert_reject '템플릿 원본 반영 섹션 추가 격추' '템플릿 원본 반영 섹션'   add_line "$C_TPL" '## 원본 반영'
assert_reject '템플릿 frontmatter 키 변경 격추' '템플릿 frontmatter 3키'  sub_str "$C_TPL" 'source_url:' 'url:'

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
