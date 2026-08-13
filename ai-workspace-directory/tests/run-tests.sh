#!/usr/bin/env bash
#
# ai-workspace-directory 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# check-lobby.sh 의 기대값을 테스트에 적지 않고 규격 문서에서 추출한다 — 문서가 SSoT 이고
# 스크립트가 그것을 옮긴 사본이므로, 한쪽만 바뀌면 여기서 드리프트가 잡힌다.
#   - 표준 6개 H2·SSoT 문구·Repos 표 헤더: references/standard-structure.md 의 "골격" 코드 블록
#   - 분량 경계 150/250: SKILL.md init-5단계 표
#
# 정상 fixture(fixtures/lobby-good.md)는 위 골격에서 파생한 실제 값 예시다.
# fixture 가 낡으면 아래 "fixture 정합" 검사가 잡는다.
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
STRUCT="$HERE/../references/standard-structure.md"
CHECK="$HERE/../scripts/check-lobby.sh"
GOOD="$HERE/fixtures/lobby-good.md"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

[ -x "$CHECK" ] || { echo "NOT OK - 헬퍼 실행 권한 없음 — $CHECK"; exit 1; }
[ -r "$GOOD" ] || { echo "NOT OK - fixture 없음 — $GOOD"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- 규격 문서에서 기대값 추출 --------------------------------------------------
#
# standard-structure.md "## 골격" 아래 첫 코드 블록이 산출물 형식의 SSoT 다.

skeleton() {
  awk '
    /^## 골격[[:space:]]*$/ { s = 1; next }
    s && /^```/ { b = !b; if (!b) exit; next }
    s && b { print }
  ' "$STRUCT"
}

skel="$(skeleton)"
[ -n "$skel" ] || { ng "골격 추출: 코드 블록을 찾지 못했습니다"; echo "-----"; echo "passed: $pass, failed: $fail"; exit 1; }
ok "골격 추출: $(printf '%s\n' "$skel" | grep -c '')행"

want_h2="$(printf '%s\n' "$skel" | grep -E '^## ' | sed -E 's/^## +//; s/[[:space:]]+$//')"
got_h2="$(grep -E '^## ' "$GOOD" | sed -E 's/^## +//; s/[[:space:]]+$//')"
[ "$want_h2" = "$got_h2" ] \
  && ok "fixture 정합: H2 6종이 골격과 일치" \
  || ng "fixture 정합: H2 목록이 골격과 다릅니다 — 골격 [$(printf '%s' "$want_h2" | tr '\n' '>')] fixture [$(printf '%s' "$got_h2" | tr '\n' '>')]"

want_ssot="$(printf '%s\n' "$skel" | sed -n '2p')"
got_ssot="$(sed -n '2p' "$GOOD")"
[ "$want_ssot" = "$got_ssot" ] \
  && ok "fixture 정합: SSoT 문구가 골격과 일치" \
  || ng "fixture 정합: SSoT 문구가 골격과 다릅니다"

want_hdr="$(printf '%s\n' "$skel" | awk '/^## Repos/{f=1;next} f && /^\|/{print; exit}')"
got_hdr="$(awk '/^## Repos/{f=1;next} f && /^\|/{print; exit}' "$GOOD")"
[ "$want_hdr" = "$got_hdr" ] \
  && ok "fixture 정합: Repos 표 헤더가 골격과 일치" \
  || ng "fixture 정합: Repos 표 헤더가 골격과 다릅니다 — 골격 [$want_hdr] fixture [$got_hdr]"

# --- 정상 fixture 는 통과한다 ---------------------------------------------------

if "$CHECK" "$GOOD" >/dev/null 2>&1; then
  ok "정상 fixture 통과"
else
  ng "정상 fixture 통과 — 실제 위반: $("$CHECK" "$GOOD" 2>&1 | tr '\n' ' ')"
fi

# --- 형식 위배 8종 --------------------------------------------------------------
#
# 정상 fixture 를 한 곳씩 망가뜨려 각 검사가 실제로 발동하는지 본다.
# 위반 사유 문자열까지 대조해, 다른 검사가 대신 걸려 통과처럼 보이는 것을 막는다.

# assert_violation <설명> <사유 조각> <변형 명령...>
assert_violation() {
  local desc="$1" want="$2"; shift 2
  local f="$TMP/case.md" out rc
  cp "$GOOD" "$f"
  "$@" "$f" || { ng "$desc — 변형 실패"; return; }
  out="$("$CHECK" "$f" 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ]; then
    ng "$desc — exit 1 기대, 실제 $rc"
  elif printf '%s\n' "$out" | grep -qF "$want"; then
    ok "$desc"
  else
    ng "$desc — 사유에 '$want' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

mutate_first_line() { sed -i.bak '1s/.*/> last updated: 어제/' "$1" && rm -f "$1.bak"; }
mutate_ssot()       { sed -i.bak '2s/.*/> SSoT: 알아서 판단할 것./' "$1" && rm -f "$1.bak"; }
mutate_frontmatter() { printf '%s\n' '---' 'title: lobby' '---' '' > "$1.new" && cat "$1" >> "$1.new" && mv "$1.new" "$1"; }
mutate_drop_h2()    { sed -i.bak '/^## 공통 규약$/d' "$1" && rm -f "$1.bak"; }
mutate_floors()     { sed -i.bak 's/^## Repos$/## Floors/' "$1" && rm -f "$1.bak"; }
mutate_cols()       { sed -i.bak 's/^| path | domain | keywords | status |$/| path | domain | status |/' "$1" && rm -f "$1.bak"; }
mutate_status()     { sed -i.bak 's/| 결제, 승인, PG 연동 | active |/| 결제, 승인, PG 연동 | 운영중 |/' "$1" && rm -f "$1.bak"; }
mutate_steps()      { sed -i.bak '/^4\. 답변 직전 정보 충돌 시/d' "$1" && rm -f "$1.bak"; }
mutate_no_entry()   { sed -i.bak 's/^### 진입 절차 (질의 → 답변)$/### 들어가기/' "$1" && rm -f "$1.bak"; }

assert_violation '(1) 첫 줄 last updated 형식'  '본문 첫 줄이'          mutate_first_line
assert_violation '(2) SSoT 고정 문구'           '표준 SSoT 문구가 아닙니다' mutate_ssot
assert_violation '(3) YAML frontmatter 존재'    'YAML frontmatter 가 있습니다' mutate_frontmatter
assert_violation '(4) 표준 H2 누락'             '표준 H2 섹션 누락'      mutate_drop_h2
assert_violation '(5) 구버전 Floors 섹션명'      "구버전 섹션명 'Floors'" mutate_floors
assert_violation '(6) Repos 표 열 수'           'Repos 표가 4열'         mutate_cols
assert_violation '(8) status 열거값'            'status 값이 열거값'      mutate_status
assert_violation '(7) 진입 절차 단계 수'         '번호 4단계가 아닙니다'    mutate_steps
assert_violation '(7) 진입 절차 서브헤딩 부재'    "'### 진입 절차' 서브헤딩이 없습니다" mutate_no_entry

# H2 순서 검사: 섹션 하나를 통째로 뒤로 옮긴다 (누락 없이 순서만 어긋난 상태).
{
  f="$TMP/reorder.md"
  # `라우팅 규칙` 블록을 떼어 파일 끝으로 옮긴다 — 6종이 모두 있으나 순서만 어긋난 상태.
  awk '/^## 라우팅 규칙$/{g=1} g && /^## 공통 규약$/{g=0} !g{print}' "$GOOD" > "$f.body"
  awk '/^## 라우팅 규칙$/{g=1} g && /^## 공통 규약$/{g=0} g{print}' "$GOOD" > "$f.block"
  cat "$f.body" "$f.block" > "$f"
  out="$("$CHECK" "$f" 2>&1)"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -qF '순서가 규격과 다릅니다'; then
    ok "(4) 표준 H2 순서"
  else
    ng "(4) 표준 H2 순서 — exit $rc, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

# frontmatter 가 있어도 머리말 2줄은 본문 기준으로 판정한다 (같은 결함을 세 번 세지 않는다).
{
  f="$TMP/fm.md"
  printf '%s\n' '---' 'title: lobby' '---' '' > "$f"
  cat "$GOOD" >> "$f"
  count="$("$CHECK" "$f" 2>&1 | grep -c '^위반:')"
  [ "$count" -eq 1 ] \
    && ok "frontmatter: 위반 1건만 보고(머리말 2줄은 본문 기준 판정)" \
    || ng "frontmatter: 위반 ${count}건 — 1건 기대"
}

# --- 분량 가드레일 --------------------------------------------------------------
#
# 경계값 150/250 은 SKILL.md init-5단계 표에서 추출해 대조한다.

bounds="$(awk '
  /^#### init-5단계/ { f = 1; next }
  f && /^#### / { exit }
  f && /^\|/ { print }
' "$SKILL" | grep -oE '[0-9]+' | sort -n | uniq)"

echo "$bounds" | grep -qx '150' && ok "분량 경계: SKILL.md 에 150 존재" || ng "분량 경계: SKILL.md 에서 150 을 찾지 못했습니다"
echo "$bounds" | grep -qx '250' && ok "분량 경계: SKILL.md 에 250 존재" || ng "분량 경계: SKILL.md 에서 250 을 찾지 못했습니다"

# make_lines <줄 수> <경로>
make_lines() {
  local n="$1" p="$2" i=1
  : > "$p"
  while [ "$i" -le "$n" ]; do echo "line $i" >> "$p"; i=$((i + 1)); done
}

# assert_lines <줄 수> <기대 판정>
assert_lines() {
  local n="$1" want="$2" got
  make_lines "$n" "$TMP/len.md"
  got="$("$CHECK" --lines "$TMP/len.md" 2>&1)"
  if [ "$got" = "$want (${n}줄)" ]; then
    ok "분량: ${n}줄 → $want"
  else
    ng "분량: ${n}줄 기대 [$want (${n}줄)], 실제 [$got]"
  fi
}

assert_lines 149 '짧음'
assert_lines 150 '정상'
assert_lines 200 '정상'
assert_lines 250 '정상'
assert_lines 251 '비대'

# 분량 판정은 권고라 exit 0 을 유지한다 — 형식 위배와 달리 파일 생성을 막지 않는다.
make_lines 400 "$TMP/big.md"
"$CHECK" --lines "$TMP/big.md" >/dev/null 2>&1
[ $? -eq 0 ] && ok "분량: 비대여도 exit 0(권고)" || ng "분량: 비대에서 exit 0 이 아님"

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
assert_usage_error '알 수 없는 옵션'    --strict "$GOOD"
assert_usage_error '파일 중복'         "$GOOD" "$GOOD"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
