#!/usr/bin/env bash
#
# git-pr 회귀 테스트 러너 (git 외 외부 의존성 없음, ADR 0001).
#
# validate-title.sh 의 기대값은 SKILL.md "PR 제목" 예시 블록에서 추출한다 — 문서가 SSoT 이고
# 스크립트가 그것을 옮긴 사본이므로, 한쪽만 바뀌면 여기서 드리프트가 잡힌다.
# verify-submit.sh 는 임시 저장소를 만들어 실제 git 동작으로 검증한다.
# check-ledger-links.sh 는 임시 `.ai` 트리를 만들어 끊긴 원장 링크 판정을 검증한다.
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
TITLE="$HERE/../scripts/validate-title.sh"
SUBMIT="$HERE/../scripts/verify-submit.sh"
LEDGER="$HERE/../scripts/check-ledger-links.sh"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

for s in "$TITLE" "$SUBMIT" "$LEDGER"; do
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

# --- 원장 링크 검사 (check-ledger-links.sh, issue #120) -----------------------------
#
# 케이스마다 새 `.ai` 트리를 만든다. 기본 트리는 K-0001 을 archive/ 로 옮기고 링크를 다 고친 상태이며,
# K-0001 과 active/ 에 남은 K-0002 가 서로를 가리킨다. 격추 케이스는 그 트리에서 한 곳만 바꾼다.
# 헬퍼 사본을 둔 issue-work·git-pr·git-pr-feedback 러너에 같은 케이스를 둔다. 한쪽을 고치면 나머지도 고친다.

# ledger_tree <이름> — 기본 트리를 "$TMP/ledger-<이름>" 에 만들고 그 경로를 LT 에 둔다.
ledger_tree() {
  LT="$TMP/ledger-$1"
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
# 원장 항목을 archive/ 로 옮긴 뒤의 링크 갱신은 SKILL.md "PR 제출" 4단계 원장 해소 기재의 번호 단계 정의 행
# (`4. **들어오는 링크 갱신**:`)과 그 아래 헬퍼 호출 블록, "문서 동기화 점검"의 승격 이관 문단이 계약이다.
# 정의 행은 파일 전체에서 정확히 1개로 세고 조각 8개를 그 행에서 판정한다. 위치·참조 판정은
# issue-0120 spec R3 의 두 [D] 를 옮긴 것이다. 호출 블록은 정의 행 다음 행부터 커밋과 push 번호 단계 행 앞까지에서
# 경로 설정 행과 호출 행을 본다 — 정의 행의 헬퍼 이름 조각으로는 경로 오타나 호출 행 누락을 잡지 못한다.
# 위반 행은 판정 이름(정의·위치·참조·호출)으로 시작하고, 격추 케이스는 노린 판정이 위반을 냈는지 본다.
# issue-work·git-pr-feedback 러너에도 같은 판정을 그 스킬의 적용 지점에 맞춰 둔다.

# check_link_rule <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_link_rule() {
  local re n line a para cfg v blk
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
  awk '/\*\*원장 해소 기재는 보고 다음입니다\.\*\*/ { s = 1; next } s && /^- / { s = 0 }
       s && /^  [0-9]+\. .*`\.ai\/70_ledger\/index\.md`/ { a = NR }
       s && /^  [0-9]+\. \*\*들어오는 링크 갱신\*\*: / { b = NR }
       s && /^  [0-9]+\. 커밋과 push/ { c = NR }
       END { if (!(a && b && c && a < b && b < c)) print "위치: index " a+0 ", 정의 " b+0 ", 커밋 " c+0 }' "$1"
  n=$(grep -cE '^원장 대조 권고도 같은 방식으로' "$1")
  if [ "$n" = 1 ]; then
    para=$(grep -E '^원장 대조 권고도 같은 방식으로' "$1")
    case "$para" in *'`.ai/70_ledger/index.md`'*) ;; *) echo '참조: 승격 이관 문단에 index 갱신 없음' ;; esac
    case "$para" in *'들어오는 링크 갱신'*) ;; *) echo '참조: 승격 이관 문단에 들어오는 링크 갱신 참조 없음' ;; esac
  else
    echo "참조: 원장 대조 반영 문단 ${n}개 (기대 1개)"
  fi
  # 호출 블록: 정의 행 다음 행부터 커밋과 push 번호 단계 행(없으면 다음 `## ` 제목) 앞까지
  blk=$(awk '/^ *([0-9]+\.|-) \*\*들어오는 링크 갱신\*\*: / { r = 1; next }
             r && (/^  [0-9]+\. 커밋과 push/ || /^## /) { r = 0 }
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

# drop_literal <파일> <문자열> [<행 정규식>] → 문자열을 정규식 해석 없이 지운 사본을 표준 출력으로
# 행 정규식을 주면 그 정규식에 맞는 행에서만 지운다.
drop_literal() {
  awk -v s="$2" -v re="${3:-}" '
    re == "" || $0 ~ re { while ((i = index($0, s))) $0 = substr($0, 1, i - 1) substr($0, i + length(s)) }
    { print }' "$1"
}

# 승격 문단의 두 변형(lr-no-index·lr-no-ref)은 그 문단 행에서만 지운다. 파일 전체에서 지우면 index 갱신 단계 행이나
# 정의 행도 바뀌어 다른 판정으로 격추된다. 호출 블록의 두 변형(lr-bad-path·lr-no-call)도 그 블록 행만 바꾼다.
awk '!/^ *([0-9]+\.|-) \*\*들어오는 링크 갱신\*\*: /' "$SKILL" > "$TMP/lr-del.md"
drop_literal "$SKILL" '링크가 있는 문서 위치에서 다시 계산' > "$TMP/lr-no-depth.md"
awk '/^ *[0-9]+\. \*\*들어오는 링크 갱신\*\*: / { held = $0; next } { print }
     /^  [0-9]+\. 커밋과 push/ { print held }' "$SKILL" > "$TMP/lr-moved.md"
drop_literal "$SKILL" '`.ai/70_ledger/index.md`' '^원장 대조 권고도 같은 방식으로' > "$TMP/lr-no-index.md"
drop_literal "$SKILL" '들어오는 링크 갱신' '^원장 대조 권고도 같은 방식으로' > "$TMP/lr-no-ref.md"
awk '/^[[:space:]]*ledger_links=/ { sub(/check-ledger-links\.sh/, "missing-helper.sh") } { print }' \
  "$SKILL" > "$TMP/lr-bad-path.md"
awk '!/^[[:space:]]*"\$ledger_links"/' "$SKILL" > "$TMP/lr-no-call.md"

assert_link_rule "$SKILL"                 pass "링크 갱신 규칙: 실제 SKILL.md 정의 행·적용 지점·호출 블록 통과"
assert_link_rule "$TMP/lr-del.md"         정의 "링크 갱신 규칙: 정의 행 삭제 격추"
assert_link_rule "$TMP/lr-no-depth.md"    정의 "링크 갱신 규칙: 정의 행의 깊이 재계산 조각 삭제 격추"
assert_link_rule "$TMP/lr-moved.md"       위치 "링크 갱신 규칙: 정의 행을 커밋과 push 단계 뒤로 이동 격추"
assert_link_rule "$TMP/lr-no-index.md"    참조 "링크 갱신 규칙: 승격 이관 문단의 index 갱신 삭제 격추"
assert_link_rule "$TMP/lr-no-ref.md"      참조 "링크 갱신 규칙: 승격 이관 문단의 들어오는 링크 갱신 참조 삭제 격추"
assert_link_rule "$TMP/lr-bad-path.md"    호출 "링크 갱신 규칙: 경로 설정 값을 없는 파일로 바꾼 호출 블록 격추"
assert_link_rule "$TMP/lr-no-call.md"     호출 "링크 갱신 규칙: 호출 행 삭제 격추"

# --- PR 본문 구성 (issue #130) -------------------------------------------------------
#
# 이슈 섹션의 첫 화면 5항목·접기 안 헤더 5개(템플릿), 테크 관점 항목 순서(SKILL.md·템플릿), SKILL.md 이슈 섹션 설명의
# 라벨 순서·리뷰어 확인 요청 규칙·접기 안 `없음` 규칙이 계약이다. 판정은 issue-0130 spec R8 의 [D] 명령을 옮긴 것이다.
# 위반 행은 판정 이름으로 시작하고, 격추 케이스는 노린 판정이 위반을 냈는지 본다 (assert_link_rule 과 같은 방식).
# 첫 화면만 읽고 판단할 수 있는지는 판정하지 않는다 (이슈 spec 의 [QD] 몫).

PR_TPL="$HERE/../templates/pr-body-template.md"
P="$TMP/pr-body"
mkdir -p "$P"

# issue_sec <SKILL.md> → 이슈 섹션 설명 (`### Issue: #[이슈번호]` 다음 행부터 `#### 1. 비즈니스 관점` 앞까지)
issue_sec() { awk '/^### Issue: #\[이슈번호\]/ { f = 1; next } f && /^#### 1\. 비즈니스 관점$/ { exit } f' "$1"; }

# check_pr_body <SKILL.md> <템플릿> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_pr_body() {
  local got f sec prev ln p
  got=$(awk '/^### Issue: / { n++ } n == 1 && /^<details>/ { d++ } n == 1 && /^<\/details>/ { d-- }
             n == 1 && d == 0 && /^\*\*[^*]+\*\*$/ { printf "%s|", $0 }' "$2")
  [ "$got" = '**목적·범위**|**리뷰어 확인 요청**|**리스크·주의사항**|**완료의 정의 대조**|**이번 PR에서 하지 않는 것**|' ] \
    || echo "첫 화면 라벨: [$got]"
  got=$(awk '/^### Issue: / { n++ } n == 1 && /^<details>/ { d++ } n == 1 && /^<\/details>/ { d-- }
             n == 1 && d > 0 && /^#### / { printf "%s|", $0 }' "$2")
  [ "$got" = '#### 완료의 정의 대조 표|#### 전후 예시|#### 배경|#### 1. 비즈니스 관점|#### 2. 테크 관점|' ] \
    || echo "접기 안 헤더: [$got]"
  for f in "$1" "$2"; do
    got=$(awk '/^#### 2\. 테크 관점$/ { s = 1; next } s && (/^## / || /^<\/details>/) { exit }
               s && /^\* \*\*[^*]+:\*\*/ { match($0, /\*\*[^*]+:\*\*/); printf "%s|", substr($0, RSTART, RLENGTH) }' "$f")
    [ "$got" = '**구현 요약:**|**호출 흐름:**|**실패 경로:**|**참고사항:**|' ] || echo "테크 관점: ${f##*/} [$got]"
  done
  sec=$(issue_sec "$1")
  prev=0
  for p in '**목적·범위**' '**리뷰어 확인 요청**' '**리스크·주의사항**' '**완료의 정의 대조**' '**이번 PR에서 하지 않는 것**'; do
    ln=$(printf '%s\n' "$sec" | grep -nF -- "$p" | head -1 | cut -d: -f1)
    if [ -z "$ln" ] || [ "$ln" -le "$prev" ]; then echo "라벨 순서: [$p]"; else prev=$ln; fi
  done
  for p in '질문으로' '`없음`'; do
    printf '%s\n' "$sec" | grep -F '**리뷰어 확인 요청**' | grep -qF -- "$p" || echo "확인 요청 규칙: [$p] 없음"
  done
  for p in '접기 안 헤더 5개도 항상 두고' '동작 차이가 없는 변경이면 전후 예시는 `없음`'; do
    printf '%s\n' "$sec" | grep -qF -- "$p" || echo "접기 안 규칙: [$p] 없음"
  done
}

# assert_rule <검사 함수> <기대: pass | 판정 이름> <설명> <파일...>
# 격추 케이스는 노린 판정 이름으로 시작하는 위반 행이 있어야 통과한다 — 변형이 다른 판정에만 걸리면 노린 판정이 깨져도 알 수 없다.
assert_rule() {
  local fn="$1" want="$2" desc="$3" out; shift 3
  out="$("$fn" "$@")"
  if [ "$want" = pass ]; then
    if [ -z "$out" ]; then ok "$desc (위반 0건)"; else ng "$desc (기대 0건, 실제 [$out])"; fi
  elif printf '%s\n' "$out" | grep -q "^$want: "; then
    ok "$desc ($want 위반 검출)"
  else
    ng "$desc (기대 [$want: …], 실제 [$out])"
  fi
}

assert_rule check_pr_body pass 'PR 본문 구성: 실제 SKILL.md·템플릿 통과' "$SKILL" "$PR_TPL"

# 첫 화면 라벨: 템플릿에서 라벨 행 삭제·접기 안 이동, SKILL.md 에서 항목 행 삭제를 라벨마다 둔다.
i=0
for l in '**목적·범위**' '**리뷰어 확인 요청**' '**리스크·주의사항**' '**완료의 정의 대조**' '**이번 PR에서 하지 않는 것**'; do
  i=$((i + 1))
  L="$l" awk '$0 != ENVIRON["L"]' "$PR_TPL" > "$P/t-del-$i.md"
  L="$l" awk '$0 == ENVIRON["L"] { held = $0; next } { print }
              /^<summary>/ && held != "" { print ""; print held; held = "" }' "$PR_TPL" > "$P/t-in-$i.md"
  L="- $l: " awk 'index($0, ENVIRON["L"]) != 1' "$SKILL" > "$P/s-del-$i.md"
  assert_rule check_pr_body '첫 화면 라벨' "PR 본문 구성: 템플릿 첫 화면 라벨 $l 삭제 격추" "$SKILL" "$P/t-del-$i.md"
  assert_rule check_pr_body '첫 화면 라벨' "PR 본문 구성: 템플릿 첫 화면 라벨 $l 접기 안 이동 격추" "$SKILL" "$P/t-in-$i.md"
  assert_rule check_pr_body '라벨 순서' "PR 본문 구성: SKILL.md 첫 화면 항목 $l 삭제 격추" "$P/s-del-$i.md" "$PR_TPL"
done

A='**목적·범위**' B='**리뷰어 확인 요청**' awk '$0 == ENVIRON["A"] { print ENVIRON["B"]; next }
     $0 == ENVIRON["B"] { print ENVIRON["A"]; next } { print }' "$PR_TPL" > "$P/t-swap.md"
awk '/^- \*\*목적·범위\*\*: / { held = $0; next } { print }
     held != "" && /^- \*\*리뷰어 확인 요청\*\*: / { print held; held = "" }' "$SKILL" > "$P/s-swap.md"
assert_rule check_pr_body '첫 화면 라벨' 'PR 본문 구성: 템플릿 첫 화면 라벨 순서 바꿈 격추' "$SKILL" "$P/t-swap.md"
assert_rule check_pr_body '라벨 순서'   'PR 본문 구성: SKILL.md 첫 화면 항목 순서 바꿈 격추' "$P/s-swap.md" "$PR_TPL"

i=0
for h in '#### 완료의 정의 대조 표' '#### 전후 예시' '#### 배경' '#### 1. 비즈니스 관점' '#### 2. 테크 관점'; do
  i=$((i + 1))
  H="$h" awk '$0 != ENVIRON["H"]' "$PR_TPL" > "$P/t-hdel-$i.md"
  assert_rule check_pr_body '접기 안 헤더' "PR 본문 구성: 템플릿 접기 안 헤더 $h 삭제 격추" "$SKILL" "$P/t-hdel-$i.md"
done

# 실패 경로: 삭제와, 테크 관점 `참고사항` 뒤로 옮긴 사본. 비즈니스 관점 `참고사항`은 실패 경로보다 앞이라 옮길 자리가 되지 않는다.
for w in skill tpl; do
  if [ "$w" = skill ]; then src="$SKILL"; else src="$PR_TPL"; fi
  awk '!/^\* \*\*실패 경로:\*\*/' "$src" > "$P/$w-fp-del.md"
  awk '/^\* \*\*실패 경로:\*\*/ { held = $0; next } { print }
       /^\* \*\*참고사항:\*\*/ && held != "" { print held; held = "" }' "$src" > "$P/$w-fp-moved.md"
done
assert_rule check_pr_body '테크 관점' 'PR 본문 구성: SKILL.md 실패 경로 삭제 격추'           "$P/skill-fp-del.md" "$PR_TPL"
assert_rule check_pr_body '테크 관점' 'PR 본문 구성: SKILL.md 실패 경로를 참고사항 뒤로 이동 격추' "$P/skill-fp-moved.md" "$PR_TPL"
assert_rule check_pr_body '테크 관점' 'PR 본문 구성: 템플릿 실패 경로 삭제 격추'             "$SKILL" "$P/tpl-fp-del.md"
assert_rule check_pr_body '테크 관점' 'PR 본문 구성: 템플릿 실패 경로를 참고사항 뒤로 이동 격추'   "$SKILL" "$P/tpl-fp-moved.md"

drop_literal "$SKILL" '질문으로' '^- [*][*]리뷰어 확인 요청' > "$P/s-rq-question.md"
drop_literal "$SKILL" '`없음`'   '^- [*][*]리뷰어 확인 요청' > "$P/s-rq-none.md"
drop_literal "$SKILL" '접기 안 헤더 5개도 항상 두고' > "$P/s-fold-none.md"
drop_literal "$SKILL" '동작 차이가 없는 변경이면 전후 예시는 `없음`' > "$P/s-example-none.md"
assert_rule check_pr_body '확인 요청 규칙' 'PR 본문 구성: 리뷰어 확인 요청의 질문 규칙 문구 삭제 격추' "$P/s-rq-question.md" "$PR_TPL"
assert_rule check_pr_body '확인 요청 규칙' 'PR 본문 구성: 리뷰어 확인 요청의 없음 규칙 문구 삭제 격추' "$P/s-rq-none.md" "$PR_TPL"
assert_rule check_pr_body '접기 안 규칙'   'PR 본문 구성: 접기 안 헤더 없음 규칙 문장 삭제 격추'     "$P/s-fold-none.md" "$PR_TPL"
assert_rule check_pr_body '접기 안 규칙'   'PR 본문 구성: 전후 예시 없음 문장 삭제 격추'            "$P/s-example-none.md" "$PR_TPL"

# --- 승인 요약 (issue #130) ---------------------------------------------------------
#
# 3단계 `최종 PR 본문` 요약 항목에 리뷰어 확인 요청과 미충족 완료 항목이 들어 있어야 한다 (issue-0130 spec R9).

# check_approval <SKILL.md> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_approval() {
  local l n p
  l=$(awk '/^### 3\. 최종 제시 및 승인/ { f = 1; next } f && /^### / { exit } f && /^  - 최종 PR 본문 — / { print }' "$1")
  n=$(printf '%s\n' "$l" | grep -c .)
  [ "$n" -eq 1 ] || echo "항목 수: 최종 PR 본문 항목 ${n}개 (기대 1개)"
  for p in '리뷰어 확인 요청' '미충족 완료 항목'; do
    printf '%s\n' "$l" | grep -qF -- "$p" || echo "요약 문구: [$p] 없음"
  done
}

drop_literal "$SKILL" '리뷰어 확인 요청' '^  - 최종 PR 본문 — ' > "$P/ap-no-review.md"
drop_literal "$SKILL" '미충족 완료 항목' '^  - 최종 PR 본문 — ' > "$P/ap-no-unmet.md"
awk '{ print } /^  - 최종 PR 본문 — / { print }' "$SKILL" > "$P/ap-dup.md"
assert_rule check_approval pass        '승인 요약: 실제 SKILL.md 통과' "$SKILL"
assert_rule check_approval '요약 문구' '승인 요약: 리뷰어 확인 요청 문구 삭제 격추' "$P/ap-no-review.md"
assert_rule check_approval '요약 문구' '승인 요약: 미충족 완료 항목 문구 삭제 격추' "$P/ap-no-unmet.md"
assert_rule check_approval '항목 수'   '승인 요약: 최종 PR 본문 항목 중복 격추'     "$P/ap-dup.md"

# --- 대조 근거 (issue #130) ---------------------------------------------------------
#
# SKILL.md 첫 화면 `완료의 정의 대조` 항목(하위 행 포함)의 대조 근거·상태 5종·체크박스 미사용·`(AC 없음: …)` 표시 문장,
# 이슈 섹션 설명의 확인한 것만 적는다는 문장, 템플릿 대조 표의 머리 행·데이터 행·상태 값이 계약이다 (issue-0130 spec R14).
# 문장 리터럴은 어간까지만 고정한다 (SKILL.md 가 합니다체다). 상태 집계 규칙의 경계 사례는 판정하지 않는다 ([QD] 몫).

# check_dod_basis <SKILL.md> <템플릿> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_dod_basis() {
  local sec blk p tbl rows
  sec=$(issue_sec "$1")
  blk=$(printf '%s\n' "$sec" | awk '/^- \*\*완료의 정의 대조\*\*/ { s = 1; print; next } s && /^[[:space:]]+[^[:space:]]/ { print; next } s { exit }')
  [ -n "$blk" ] || echo '대조 항목: 항목 행 없음'
  for p in '최종 감사 리포트' '`충족`·`부분 충족`·`미충족`·`미검증`·`이관`' '체크박스만으로 충족으로 세지 않' \
           '`(AC 없음: …)` 항목은 R 그룹 단위로'; do
    printf '%s\n' "$blk" | grep -qF -- "$p" || echo "대조 항목: [$p] 없음"
  done
  printf '%s\n' "$sec" | grep -qF 'diff·테스트·감사 리포트에서 확인한 것만 적' || echo '확인 문장: 없음'
  tbl=$(awk '/^### Issue: / { n++ } n == 1 && /^#### / { s = ($0 == "#### 완료의 정의 대조 표"); next }
             n == 1 && /^<\/details>/ { s = 0 } n == 1 && s && /^\|/' "$2")
  [ "$(printf '%s\n' "$tbl" | head -1)" = '| AC | 상태 | 근거 |' ] || echo '대조 표: 머리 행'
  rows=$(printf '%s\n' "$tbl" | tail -n +3)
  [ -n "$rows" ] || echo '대조 표: 데이터 행 없음'
  printf '%s\n' "$rows" | awk -F'|' 'NF { v = $3; gsub(/^ +| +$/, "", v)
    if (v !~ /^(충족|부분 충족|미충족|미검증|이관)$/) print "대조 표: 상태 값 [" v "]" }'
}

i=0
for w in '최종 감사 리포트' '`충족`·`부분 충족`·`미충족`·`미검증`·`이관`' '체크박스만으로 충족으로 세지 않' \
         '`(AC 없음: …)` 항목은 R 그룹 단위로'; do
  i=$((i + 1)); drop_literal "$SKILL" "$w" > "$P/db-drop-$i.md"
done
# 위 루프는 사본만 만든다. 케이스 설명에 지운 문구를 이름으로 붙여 아래에서 판정한다.
assert_rule check_dod_basis pass        '대조 근거: 실제 SKILL.md·템플릿 통과'                   "$SKILL" "$PR_TPL"
assert_rule check_dod_basis '대조 항목' '대조 근거: 최종 감사 리포트 문구 삭제 격추'             "$P/db-drop-1.md" "$PR_TPL"
assert_rule check_dod_basis '대조 항목' '대조 근거: AC 상태 5종 문구 삭제 격추'                  "$P/db-drop-2.md" "$PR_TPL"
assert_rule check_dod_basis '대조 항목' '대조 근거: 체크박스 미사용 문장 삭제 격추'              "$P/db-drop-3.md" "$PR_TPL"
assert_rule check_dod_basis '대조 항목' '대조 근거: AC 없음 항목 표시 문장 삭제 격추'            "$P/db-drop-4.md" "$PR_TPL"

# 체크박스 미사용 문장 행을 `리스크·주의사항` 항목 아래 하위 행으로 옮긴다 (항목 범위 밖 이동).
M="$(grep -F '체크박스만으로 충족으로 세지 않' "$SKILL")" awk '$0 == ENVIRON["M"] { next } { print }
     /^- \*\*리스크·주의사항\*\*: / { print ENVIRON["M"] }' "$SKILL" > "$P/db-moved.md"
drop_literal "$SKILL" '·`이관`' > "$P/db-state4.md"
drop_literal "$SKILL" 'diff·테스트·감사 리포트에서 확인한 것만 적' > "$P/db-no-confirm.md"
awk '$0 == "| AC | 상태 | 근거 |" { $0 = "| AC | 판정 | 근거 |" } { print }' "$PR_TPL" > "$P/db-head.md"
awk '!/^\| AC[0-9]/' "$PR_TPL" > "$P/db-no-rows.md"
awk '!d && sub(/\| 충족 \|/, "| 완료 |") { d = 1 } { print }' "$PR_TPL" > "$P/db-bad-state.md"
assert_rule check_dod_basis '대조 항목' '대조 근거: 체크박스 미사용 문장을 리스크·주의사항 항목으로 이동 격추' "$P/db-moved.md" "$PR_TPL"
assert_rule check_dod_basis '대조 항목' '대조 근거: 상태 값 이관 빼기 격추'                     "$P/db-state4.md" "$PR_TPL"
assert_rule check_dod_basis '확인 문장' '대조 근거: 확인한 것만 적는다 문장 삭제 격추'           "$P/db-no-confirm.md" "$PR_TPL"
assert_rule check_dod_basis '대조 표'   '대조 근거: 대조 표 머리 행 변경 격추'                   "$SKILL" "$P/db-head.md"
assert_rule check_dod_basis '대조 표'   '대조 근거: 대조 표 데이터 행 삭제 격추'                 "$SKILL" "$P/db-no-rows.md"
assert_rule check_dod_basis '대조 표'   '대조 근거: 상태 열에 5종 밖 값 넣기 격추'               "$SKILL" "$P/db-bad-state.md"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
