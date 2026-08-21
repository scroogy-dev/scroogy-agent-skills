#!/usr/bin/env bash
#
# git-pr 회귀 테스트 러너 (git 외 외부 의존성 없음, ADR 0001).
#
# validate-title.sh 의 기대값은 SKILL.md "PR 제목" 예시 블록에서 추출한다 — 문서가 SSoT 이고
# 스크립트가 그것을 옮긴 사본이므로, 한쪽만 바뀌면 여기서 드리프트가 잡힌다.
# verify-submit.sh 는 임시 저장소를 만들어 실제 git 동작으로 검증한다.
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
TITLE="$HERE/../scripts/validate-title.sh"
SUBMIT="$HERE/../scripts/verify-submit.sh"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

for s in "$TITLE" "$SUBMIT"; do
  [ -x "$s" ] || { echo "NOT OK - 헬퍼 실행 권한 없음 — $s"; exit 1; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- SKILL.md 예시 블록이 그대로 통과한다 --------------------------------------
#
# "## PR 제목" 아래 배포 유형 소절의 코드 블록에서 주석·빈 줄을 뺀 제목 줄만 모은다.
# 소절 앞 첫 코드 블록은 형식 정의(`<type>(<scope>): …`)라 예시가 아니므로 수집 대상이 아니다.

titles() {
  awk '
    /^## PR 제목$/ { p = 1; next }
    p && /^### / { s = 1; next }
    s && /^## / { exit }
    s && /^```/ { b = !b; next }
    s && b && $0 !~ /^#/ && NF { print }
  ' "$SKILL"
}

t_count=0
while IFS= read -r line; do
  [ -n "$line" ] || continue
  if "$TITLE" --title "$line" >/dev/null 2>&1; then
    ok "SKILL.md 예시 통과: $line"
  else
    ng "SKILL.md 예시 통과: $line — 문서 예시가 헬퍼 규격을 벗어납니다"
  fi
  t_count=$((t_count + 1))
done <<EOF
$(titles)
EOF
[ "$t_count" -ge 4 ] && ok "예시: ${t_count}건 대조" || ng "예시: ${t_count}건만 추출(기대 4건 이상)"

# --- 제목 규격 ----------------------------------------------------------------

assert_title_ok() {
  local desc="$1"; shift
  if "$TITLE" "$@" >/dev/null 2>&1; then ok "$desc"; else ng "$desc — 통과 기대, 실제 거부"; fi
}

assert_title_ng() {
  local desc="$1"; shift
  "$TITLE" "$@" >/dev/null 2>&1
  case "$?" in
    1) ok "$desc" ;;
    *) ng "$desc — exit 1 기대, 실제 $?" ;;
  esac
}

assert_title_ok '적용 범위 + 단일 이슈'  --title 'feat(order): 주문 생성 API 성능 개선 (#123)'
assert_title_ok '적용 범위 없음'         --title 'feat: 3월 1차 배포 (#123, #124)'
assert_title_ok '파괴적 변경 표시'        --title 'feat(api)!: 응답 구조 변경 (#123)'
assert_title_ok '이슈 3개 나열'          --title 'chore: 배포 (#1, #22, #333)'

assert_title_ng '이슈 번호 없음'          --title 'feat(order): 주문 생성 API 성능 개선'
assert_title_ng '괄호 없는 이슈 번호'      --title 'feat(order): 주문 생성 API 성능 개선 #123'
assert_title_ng '이슈 번호가 말미가 아님'  --title 'feat(order): (#123) 주문 생성 API 성능 개선'
assert_title_ng '쉼표 뒤 공백 없음'        --title 'feat: 배포 (#123,#124)'
assert_title_ng '허용되지 않은 타입'       --title 'build: 배포 (#123)'
assert_title_ng '콜론 없음'               --title 'feat 주문 생성 API 성능 개선 (#123)'
assert_title_ng '제목 설명 없음'           --title 'feat: (#123)'
assert_title_ng '빈 제목'                 --title ''

printf '%s\n' 'feat(order): 주문 생성 API 성능 개선 (#123)' > "$TMP/title.md"
assert_title_ok '파일 모드'               "$TMP/title.md"

# 말미 개행이 없는 파일도 같은 한 줄이다.
printf '%s' 'feat: 개행 없는 제목 (#123)' > "$TMP/title-nonl.md"
assert_title_ok '파일 모드: 말미 개행 없음' "$TMP/title-nonl.md"

# 5차 audit F-4 반례: 검증은 첫 줄, 제출은 `cat` 전체라 둘째 줄이 검증을 건너뛴다.
printf '%s\n%s\n' 'feat: 정상 제목 (#123)' '승인되지 않은 둘째 줄' > "$TMP/title-multi.md"
assert_title_ng '파일 모드: 여러 줄 제목(5차 audit F-4 반례)' "$TMP/title-multi.md"
assert_title_ng '인자 모드: 여러 줄 제목(5차 audit F-4 반례)' \
  --title "$(printf '%s\n%s' 'feat: 정상 제목 (#123)' '승인되지 않은 둘째 줄')"
multi_out="$("$TITLE" "$TMP/title-multi.md" 2>&1)"
printf '%s\n' "$multi_out" | grep -q '여러 줄입니다' \
  && ok '여러 줄 제목: 사유 출력' \
  || ng "여러 줄 제목: 사유가 출력되지 않음 — [$multi_out]"

# CR 이 섞인 제목 — 화면에는 한 줄로 보이나 제출 문자열에는 그대로 실린다.
assert_title_ng '인자 모드: CR 포함' --title "$(printf 'feat: 제목\r 뒷부분 (#123)')"

assert_title_usage() {
  local desc="$1"; shift
  "$TITLE" "$@" >/dev/null 2>&1
  case "$?" in
    2) ok "사용오류(제목): $desc (exit 2)" ;;
    *) ng "사용오류(제목): $desc — exit 2 기대, 실제 $?" ;;
  esac
}

assert_title_usage '인자 없음'
assert_title_usage '읽을 수 없는 파일'  "$TMP/absent.md"
assert_title_usage '모드 혼용'         --title 'feat: x (#1)' "$TMP/title.md"
assert_title_usage '알 수 없는 옵션'    --strict --title 'feat: x (#1)'

# --- 원격 URL 정규화 -----------------------------------------------------------

# assert_normalize <기대> <URL>
assert_normalize() {
  local want="$1" url="$2" got
  got="$("$SUBMIT" --normalize "$url" 2>&1)"
  if [ "$got" = "$want" ]; then ok "정규화: $url → $want"; else ng "정규화: $url 기대 [$want], 실제 [$got]"; fi
}

assert_normalize 'github.com/owner/repo' 'https://github.com/owner/repo.git'
assert_normalize 'github.com/owner/repo' 'https://github.com/owner/repo'
assert_normalize 'github.com/owner/repo' 'https://user@github.com/owner/repo.git'
assert_normalize 'github.com/owner/repo' 'git@github.com:owner/repo.git'
assert_normalize 'github.com/owner/repo' 'ssh://git@github.com/owner/repo.git'
assert_normalize 'example.com/owner/repo' 'ssh://git@example.com:2222/owner/repo.git'
assert_normalize 'example.com/group/sub/repo' 'https://example.com/group/sub/repo.git'
assert_normalize 'github.com/owner/repo' 'https://github.com/owner/repo/'

# 대소문자가 다른 저장소는 같다고 판정하지 않는다 — 안전 측(제출 중단)으로 남긴다.
a="$("$SUBMIT" --normalize 'https://github.com/Owner/Repo.git')"
b="$("$SUBMIT" --normalize 'https://github.com/owner/repo.git')"
[ "$a" != "$b" ] && ok "정규화: 대소문자 차이를 동일로 뭉개지 않음" || ng "정규화: 대소문자 차이가 사라짐"

# 정규화 실패는 exit 1 (사용오류가 아니라 판정 결과다)
"$SUBMIT" --normalize 'not-a-url' >/dev/null 2>&1
[ $? -eq 1 ] && ok "정규화: 파싱 불가 URL → exit 1" || ng "정규화: 파싱 불가 URL — exit 1 기대"

"$SUBMIT" --normalize 'https://github.com/owner' >/dev/null 2>&1
[ $? -eq 1 ] && ok "정규화: 소유자만 있는 경로 → exit 1" || ng "정규화: 소유자만 있는 경로 — exit 1 기대"

"$SUBMIT" --normalize 'https://github.com/owner/repo' --branch main >/dev/null 2>&1
[ $? -eq 2 ] && ok "사용오류: --normalize 모드 혼용 (exit 2)" || ng "사용오류: --normalize 모드 혼용 — exit 2 기대"

# --- head 대조 (임시 저장소) ---------------------------------------------------

if ! command -v git >/dev/null 2>&1; then
  ng "head 대조: git 을 찾을 수 없어 검사를 수행하지 못했습니다"
  echo "-----"; echo "passed: $pass, failed: $fail"; exit 1
fi

git init -q --bare "$TMP/origin.git"
git init -q "$TMP/work"
(
  cd "$TMP/work" || exit 1
  git config user.email 'test@example.com'
  git config user.name 'test'
  git config commit.gpgsign false
  echo a > a.txt
  git add a.txt
  git commit -q -m 'init'
  git branch -M main
  git remote add origin "$TMP/origin.git"
  git push -q origin main
  git checkout -q -b feature/main
  echo b > b.txt
  git add b.txt
  git commit -q -m 'second'
  git push -q origin feature/main
) >/dev/null 2>&1 || { ng "head 대조: 임시 저장소 준비 실패"; echo "-----"; echo "passed: $pass, failed: $fail"; exit 1; }

cd "$TMP/work" || exit 1
main_sha="$(git rev-parse refs/heads/main)"
feat_sha="$(git rev-parse refs/heads/feature/main)"
other_sha="$feat_sha"

# 전제 확인: 짧은 이름으로 조회하면 tail 패턴이 두 브랜치에 걸린다.
# 헬퍼가 완전 ref 를 강제하는 이유가 유효한지 여기서 회귀 검증한다.
short_lines="$(git ls-remote --heads origin main | grep -c .)"
[ "$short_lines" -eq 2 ] \
  && ok "전제: 짧은 이름 'main' 조회는 ${short_lines}행(refs/heads/feature/main 포함)" \
  || ng "전제: 짧은 이름 조회가 ${short_lines}행 — tail 패턴 가정이 깨졌습니다"

full_lines="$(git ls-remote --heads origin refs/heads/main | grep -c .)"
[ "$full_lines" -eq 1 ] && ok "전제: 완전 ref 조회는 1행" || ng "전제: 완전 ref 조회가 ${full_lines}행"

assert_submit_ok() {
  local desc="$1"; shift
  if "$SUBMIT" "$@" >/dev/null 2>&1; then ok "$desc"; else ng "$desc — 통과 기대, 실제 거부"; fi
}

assert_submit_ng() {
  local desc="$1"; shift
  "$SUBMIT" "$@" >/dev/null 2>&1
  case "$?" in
    1) ok "$desc" ;;
    *) ng "$desc — exit 1 기대, 실제 $?" ;;
  esac
}

assert_submit_ok '로컬 head 일치'         --branch main --expect "$main_sha"
assert_submit_ok '로컬 head 축약 SHA'      --branch main --expect "${main_sha:0:8}"
assert_submit_ng '로컬 head 불일치'        --branch main --expect "$other_sha"
assert_submit_ng '로컬 브랜치 없음'        --branch absent --expect "$main_sha"

assert_submit_ok '원격 head 일치'          --remote origin --branch main --expect "$main_sha"
assert_submit_ok '원격 head 슬래시 브랜치'  --remote origin --branch feature/main --expect "$feat_sha"
assert_submit_ng '원격 head 불일치'        --remote origin --branch main --expect "$other_sha"
assert_submit_ng '원격 브랜치 없음'        --remote origin --branch absent --expect "$main_sha"
assert_submit_ng '원격 조회 실패'          --remote nosuch --branch main --expect "$main_sha"

# 로컬이 앞선 상태에서 원격 대조가 통과하지 않아야 한다 — 낡은 커밋으로 PR 이 만들어지는 경로다.
echo c > c.txt
git add c.txt
git commit -q -m 'third'
ahead_sha="$(git rev-parse refs/heads/feature/main)"
assert_submit_ok '로컬 head 갱신 반영'      --branch feature/main --expect "$ahead_sha"
assert_submit_ng '원격이 로컬보다 뒤처짐'    --remote origin --branch feature/main --expect "$ahead_sha"

assert_submit_usage() {
  local desc="$1"; shift
  "$SUBMIT" "$@" >/dev/null 2>&1
  case "$?" in
    2) ok "사용오류(제출): $desc (exit 2)" ;;
    *) ng "사용오류(제출): $desc — exit 2 기대, 실제 $?" ;;
  esac
}

assert_submit_usage '인자 없음'
assert_submit_usage '--expect 누락'      --branch main
assert_submit_usage '--branch 누락'      --expect "$main_sha"
assert_submit_usage 'SHA 형식 아님'      --branch main --expect 'not-a-sha'
assert_submit_usage 'SHA 너무 짧음'      --branch main --expect 'abc123'
assert_submit_usage '알 수 없는 인자'     --branch main --expect "$main_sha" --force
assert_submit_usage '--branch 값 누락'    --branch

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
