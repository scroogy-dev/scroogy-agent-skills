#!/usr/bin/env bash
#
# git-commit 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# validate-message.sh 의 기대값을 테스트에 적지 않고 SKILL.md 의 타입 표와 예시 블록에서 추출한다
# — 표가 SSoT 이고 스크립트가 그것을 옮긴 사본이므로, 한쪽만 바뀌면 여기서 드리프트가 잡힌다
# (git-review·issue-work 러너와 같은 방식).
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
VALIDATE="$HERE/../scripts/validate-message.sh"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

[ -x "$VALIDATE" ] || { echo "NOT OK - 헬퍼 실행 권한 없음 — $VALIDATE"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- SKILL.md 타입 표 추출 ----------------------------------------------------
#
# "## 타입" 다음의 연속된 표 행만 잡는다. 첫 행은 헤더, 둘째는 구분선, 나머지가 타입 행이다.

skill_types() {
  awk '
    /^## 타입$/ { f = 1; next }
    f && /^\|/ { print; n++; next }
    f && n > 0 { exit }
  ' "$SKILL" | sed -n '3,$p' | awk -F'|' '{ gsub(/[` ]/, "", $2); print $2 }'
}

types="$(skill_types)"
type_count="$(printf '%s\n' "$types" | grep -c '[a-z]')"
if [ "$type_count" -lt 1 ]; then
  ng "타입 표 추출: 타입 0건 — 표 위치나 형식이 바뀌었습니다"
  echo "-----"; echo "passed: $pass, failed: $fail"; exit 1
fi
ok "타입 표 추출: ${type_count}종"

# --- 표의 모든 타입이 헬퍼를 통과한다 -----------------------------------------

checked=0
for t in $types; do
  if "$VALIDATE" --subject "$t: 설명" >/dev/null 2>&1; then
    ok "타입 허용: $t"
  else
    ng "타입 허용: $t — 표에 있으나 헬퍼가 거부합니다 (드리프트)"
  fi
  checked=$((checked + 1))
done
[ "$checked" -eq "$type_count" ] && ok "타입: 표 전수 대조 ${checked}종" || ng "타입: ${checked}종만 대조(기대 ${type_count})"

# --- 표에 없는 타입은 거부한다 -------------------------------------------------
#
# Conventional Commits 에는 있으나 이 SKILL.md 표가 채택하지 않은 타입을 후보로 둔다.
# 표에 나중에 추가되면 그 값은 이 검사에서 자동으로 빠진다.

for t in build perf revert wip; do
  if printf '%s\n' "$types" | grep -qx "$t"; then continue; fi
  if "$VALIDATE" --subject "$t: 설명" >/dev/null 2>&1; then
    ng "타입 거부: $t — 표에 없는데 헬퍼가 통과시킵니다"
  else
    ok "타입 거부: $t"
  fi
done

# --- SKILL.md 예시 블록이 그대로 통과한다 --------------------------------------
#
# "## 예시"의 코드 블록과 "## 파괴적 변경"의 제목 줄을 실제로 검사한다.
# 문서의 예시가 규격을 벗어나면 여기서 잡힌다.

examples() {
  awk '
    /^## 예시$/ { f = 1; next }
    f && /^```/ { b = !b; if (!b) exit; next }
    f && b { print }
  ' "$SKILL"
  awk '
    /^## 파괴적 변경/ { f = 1; next }
    f && /^```/ { b = !b; if (!b) exit; next }
    f && b && NR > 1 { print; exit }
  ' "$SKILL"
}

ex_count=0
while IFS= read -r line; do
  [ -n "$line" ] || continue
  if "$VALIDATE" --subject "$line" >/dev/null 2>&1; then
    ok "SKILL.md 예시 통과: $line"
  else
    ng "SKILL.md 예시 통과: $line — 문서 예시가 헬퍼 규격을 벗어납니다"
  fi
  ex_count=$((ex_count + 1))
done <<EOF
$(examples)
EOF
[ "$ex_count" -ge 5 ] && ok "예시: ${ex_count}건 대조" || ng "예시: ${ex_count}건만 추출(기대 5건 이상)"

# --- 제목 형식 ----------------------------------------------------------------

# assert_ok <설명> <인자...>
assert_ok() {
  local desc="$1"; shift
  if "$VALIDATE" "$@" >/dev/null 2>&1; then ok "$desc"; else ng "$desc — 통과 기대, 실제 거부"; fi
}

# assert_ng <설명> <인자...>  (규격 위반 = exit 1)
assert_ng() {
  local desc="$1"; shift
  "$VALIDATE" "$@" >/dev/null 2>&1
  case "$?" in
    1) ok "$desc" ;;
    *) ng "$desc — exit 1 기대, 실제 $?" ;;
  esac
}

assert_ok '적용 범위'           --subject 'fix(auth): 토큰 만료 처리 오류 수정'
assert_ok '파괴적 변경 표시'     --subject 'feat!: 응답 구조 변경'
assert_ok '적용 범위 + 파괴적'   --subject 'feat(api)!: 응답 구조 변경'
assert_ok '말미 이슈 번호'       --subject 'docs: 안내도 갱신 (#90)'

assert_ng '콜론 없음'           --subject 'feat 사용자 인증 기능 추가'
assert_ng '콜론 뒤 공백 없음'    --subject 'feat:사용자 인증 기능 추가'
assert_ng '설명 없음'           --subject 'feat: '
assert_ng '제목 비어 있음'       --subject ''
assert_ng '대문자 타입'          --subject 'Feat: 사용자 인증 기능 추가'
assert_ng '빈 적용 범위'         --subject 'feat(): 설명'
assert_ng '괄호 없는 이슈 번호'   --subject 'docs: 안내도 갱신 #90'
assert_ng '괄호 밖 이슈 번호'     --subject 'docs: 안내도 갱신 (#90) 추가'

# --- 파일 모드 ----------------------------------------------------------------

printf '%s\n' 'feat: 사용자 인증 기능 추가' '' '본문입니다.' > "$TMP/good.txt"
assert_ok '파일: 제목 + 빈 줄 + 본문' "$TMP/good.txt"

printf '%s\n' 'feat: 사용자 인증 기능 추가' > "$TMP/subject-only.txt"
assert_ok '파일: 제목만' "$TMP/subject-only.txt"

printf '%s\n' 'feat: 사용자 인증 기능 추가' '본문입니다.' > "$TMP/no-blank.txt"
assert_ng '파일: 제목·본문 사이 빈 줄 없음' "$TMP/no-blank.txt"

printf '%s\n' 'feat(api)!: 응답 구조 변경' '' 'BREAKING CHANGE: 기존 클라이언트와 호환되지 않습니다.' > "$TMP/breaking.txt"
assert_ok '파일: BREAKING CHANGE 꼬리말' "$TMP/breaking.txt"

printf '%s\n' 'feat: 사용자 인증 기능 추가' '' 'Co-Authored-By: Someone <someone@example.com>' > "$TMP/coauthor.txt"
assert_ng '파일: Co-Authored-By 기본 거부' "$TMP/coauthor.txt"
assert_ok '파일: Co-Authored-By 명시 허용' --allow-coauthor "$TMP/coauthor.txt"

# --- 사용오류 ------------------------------------------------------------------

# assert_usage_error <설명> <인자...>
assert_usage_error() {
  local desc="$1"; shift
  "$VALIDATE" "$@" >/dev/null 2>&1
  case "$?" in
    2) ok "사용오류: $desc (exit 2)" ;;
    *) ng "사용오류: $desc — exit 2 기대, 실제 $?" ;;
  esac
}

assert_usage_error '인자 없음'
assert_usage_error '읽을 수 없는 파일'   "$TMP/absent.txt"
assert_usage_error '알 수 없는 옵션'     --strict --subject 'feat: 설명'
assert_usage_error '모드 혼용'          --subject 'feat: 설명' "$TMP/good.txt"
assert_usage_error '메시지 파일 중복'    "$TMP/good.txt" "$TMP/subject-only.txt"
assert_usage_error '--subject 값 누락'   --subject

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
