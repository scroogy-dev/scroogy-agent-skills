#!/usr/bin/env bash
#
# git-pr-feedback 회귀 테스트 러너 (git 외 외부 의존성 없음, ADR 0001).
#
# verify-push.sh 를 임시 저장소로 실제 git 동작에 걸어 검증한다.
# push URL 복수 설정·원격 rewind·비전진 승인 SHA 처럼 손으로 재현하기 번거로운 상태를
# 여기서 만들어 각 가드가 실제로 발동하는지 본다.
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY="$HERE/../scripts/verify-push.sh"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

[ -x "$VERIFY" ] || { echo "NOT OK - 헬퍼 실행 권한 없음 — $VERIFY"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- 원격 URL 정규화 -------------------------------------------------------------

assert_normalize() {
  local want="$1" url="$2" got
  got="$("$VERIFY" --normalize "$url" 2>&1)"
  if [ "$got" = "$want" ]; then ok "정규화: $url → $want"; else ng "정규화: $url 기대 [$want], 실제 [$got]"; fi
}

assert_normalize 'github.com/owner/repo' 'https://github.com/owner/repo.git'
assert_normalize 'github.com/owner/repo' 'git@github.com:owner/repo.git'
assert_normalize 'github.com/owner/repo' 'ssh://git@github.com/owner/repo.git'
assert_normalize 'example.com/owner/repo' 'ssh://git@example.com:2222/owner/repo.git'

"$VERIFY" --normalize 'not-a-url' >/dev/null 2>&1
[ $? -eq 1 ] && ok "정규화: 파싱 불가 URL → exit 1" || ng "정규화: 파싱 불가 URL — exit 1 기대"

"$VERIFY" --normalize 'https://github.com/o/r' --remote origin >/dev/null 2>&1
[ $? -eq 2 ] && ok "사용오류: --normalize 모드 혼용 (exit 2)" || ng "사용오류: --normalize 모드 혼용 — exit 2 기대"

# --- 임시 저장소 준비 -------------------------------------------------------------

if ! command -v git >/dev/null 2>&1; then
  ng "push 가드: git 을 찾을 수 없어 검사를 수행하지 못했습니다"
  echo "-----"; echo "passed: $pass, failed: $fail"; exit 1
fi

git init -q --bare "$TMP/origin.git"
git init -q "$TMP/work"
(
  cd "$TMP/work" || exit 1
  git config user.email 'test@example.com'
  git config user.name 'test'
  git config commit.gpgsign false
  echo a > a.txt; git add a.txt; git commit -q -m 'first'
  git branch -M feature
  git remote add origin "$TMP/origin.git"
  git push -q origin feature
  echo b > b.txt; git add b.txt; git commit -q -m 'second'
) >/dev/null 2>&1 || { ng "push 가드: 임시 저장소 준비 실패"; echo "-----"; echo "passed: $pass, failed: $fail"; exit 1; }

cd "$TMP/work" || exit 1
head_oid="$(git rev-parse 'refs/heads/feature~1')"   # 원격에 게시된 SHA
approved="$(git rev-parse 'refs/heads/feature')"      # 로컬에서 한 커밋 앞선 SHA
REPO="$(printf '%s' "$TMP/origin.git" | sed 's#^/#local/#; s#/#_#g')"

# 로컬 경로 원격은 `호스트/소유자/저장소` 형태가 아니라 정규화 대상이 아니다.
# 정규화 결과를 대조하는 검사(1·2)는 URL 형태 저장소로 따로 보고, 여기서는
# ref·조상 검사(3·4)가 실제 git 상태로 발동하는지를 본다.
norm_fail="$("$VERIFY" --remote origin --repo 'github.com/o/r' --branch feature \
  --head-oid "$head_oid" --approved-sha "$approved" 2>&1)"
printf '%s\n' "$norm_fail" | grep -qF 'fetch URL' \
  && ok "가드1: 로컬 경로 원격은 head 저장소 불일치로 걸림" \
  || ng "가드1: fetch URL 위반이 보고되지 않았습니다 — $(printf '%s' "$norm_fail" | tr '\n' ' ')"

printf '%s\n' "$norm_fail" | grep -qF '원격 ref 가 보관한' \
  && ng "가드3: 원격 ref 가 일치하는데 위반으로 보고됐습니다" \
  || ok "가드3: 원격 ref 가 headRefOid 와 일치"

printf '%s\n' "$norm_fail" | grep -qF '조상으로 포함하지 않습니다' \
  && ng "가드4: 전진 관계인데 위반으로 보고됐습니다" \
  || ok "가드4: 승인 SHA 가 headRefOid 를 조상으로 포함"

# --- URL 형태 원격으로 가드 1·2 검증 ------------------------------------------------
#
# 정규화가 성립하려면 원격 URL 에 호스트가 있어야 하는데, 실제 호스트로 조회하면 테스트가 네트워크를 탄다.
# `GIT_ALLOW_PROTOCOL=file` 로 https 조회를 즉시 실패시켜 네트워크 없이 URL 검사만 남긴다.
# 이 조합에서는 가드 3(원격 ref)이 함께 걸리므로, 가드 1·2 위반 메시지의 유무로만 판정한다.
# 가드 3·4 의 통과 케이스는 위 로컬 경로 원격 블록이 담당한다.

URL_REPO='github.com/owner/repo'
git remote add urlremote 'https://github.com/owner/repo.git'

out="$(GIT_ALLOW_PROTOCOL=file "$VERIFY" --remote urlremote --repo "$URL_REPO" --branch feature \
  --head-oid "$head_oid" --approved-sha "$approved" 2>&1)"
printf '%s\n' "$out" | grep -qE 'fetch URL|push URL' \
  && ng "가드1·2: 일치하는 URL 인데 위반으로 보고됐습니다 — $(printf '%s' "$out" | tr '\n' ' ')" \
  || ok "가드1·2: fetch·push URL 이 head 저장소와 일치하면 위반 없음"

out="$(GIT_ALLOW_PROTOCOL=file "$VERIFY" --remote urlremote --repo 'github.com/owner/other' --branch feature \
  --head-oid "$head_oid" --approved-sha "$approved" 2>&1)"
printf '%s\n' "$out" | grep -qF 'fetch URL 이 보관한 head 저장소와 다릅니다' \
  && ok "가드1: fetch URL 이 다른 저장소면 거부" \
  || ng "가드1: fetch URL 불일치 — 실제: $(printf '%s' "$out" | tr '\n' ' ')"

# push URL 을 두 개 설정한다 — fetch URL 만 보면 통과하지만 push 는 두 저장소로 나간다.
git remote set-url --push --add urlremote 'https://github.com/owner/repo.git'
git remote set-url --push --add urlremote 'https://github.com/owner/other.git'
out="$(GIT_ALLOW_PROTOCOL=file "$VERIFY" --remote urlremote --repo "$URL_REPO" --branch feature \
  --head-oid "$head_oid" --approved-sha "$approved" 2>&1)"
printf '%s\n' "$out" | grep -qF 'push URL 이 2개입니다' \
  && ok "가드2: push URL 복수 설정을 거부" \
  || ng "가드2: push URL 복수 설정 — 실제: $(printf '%s' "$out" | tr '\n' ' ')"
printf '%s\n' "$out" | grep -qF 'push URL 이 보관한 head 저장소와 다릅니다' \
  && ok "가드2: 다른 저장소를 가리키는 push URL 을 거부" \
  || ng "가드2: 다른 저장소 push URL 이 보고되지 않았습니다"

# --- 가드 3: 원격 상태 변화 (로컬 경로 원격) -----------------------------------------

# 원격이 그사이 앞서면(다른 경로로 갱신) headRefOid 대조가 걸려야 한다.
git push -q origin feature >/dev/null 2>&1
out="$("$VERIFY" --remote origin --repo 'github.com/o/r' --branch feature \
  --head-oid "$head_oid" --approved-sha "$approved" 2>&1)"
printf '%s\n' "$out" | grep -qF '원격 ref 가 보관한 headRefOid 와 다릅니다' \
  && ok "가드3: 원격이 그사이 갱신된 상태를 거부" \
  || ng "가드3: 원격 갱신 — 실제: $(printf '%s' "$out" | tr '\n' ' ')"

# 원격 ref 삭제 — lease 대상이 사라진 상태.
git push -q origin --delete feature >/dev/null 2>&1
out="$("$VERIFY" --remote origin --repo 'github.com/o/r' --branch feature \
  --head-oid "$head_oid" --approved-sha "$approved" 2>&1)"
printf '%s\n' "$out" | grep -qF '원격 ref 가 없습니다(삭제됨)' \
  && ok "가드3: 원격 ref 삭제 상태를 거부" \
  || ng "가드3: 원격 ref 삭제 — 실제: $(printf '%s' "$out" | tr '\n' ' ')"

# --- 가드4: 비전진 승인 SHA ----------------------------------------------------------
#
# headRefOid 를 조상으로 포함하지 않는 SHA 를 승인값으로 넘기면 강제 덮어쓰기가 된다.

git checkout -q --detach "$head_oid"
echo z > z.txt; git add z.txt; git commit -q -m 'divergent'
diverged="$(git rev-parse HEAD)"
git checkout -q feature

out="$("$VERIFY" --remote origin --repo 'github.com/o/r' --branch feature \
  --head-oid "$approved" --approved-sha "$diverged" 2>&1)"
printf '%s\n' "$out" | grep -qF '조상으로 포함하지 않습니다' \
  && ok "가드4: 비전진 승인 SHA 를 거부" \
  || ng "가드4: 비전진 승인 SHA — 실제: $(printf '%s' "$out" | tr '\n' ' ')"

out="$("$VERIFY" --remote origin --repo 'github.com/o/r' --branch feature \
  --head-oid '0000000000000000000000000000000000000000' --approved-sha "$approved" 2>&1)"
printf '%s\n' "$out" | grep -qF 'headRefOid 커밋을 로컬에서 찾을 수 없습니다' \
  && ok "가드4: 로컬에 없는 headRefOid 를 거부" \
  || ng "가드4: 로컬에 없는 headRefOid — 실제: $(printf '%s' "$out" | tr '\n' ' ')"

# --- 사용오류 --------------------------------------------------------------------

assert_usage_error() {
  local desc="$1"; shift
  "$VERIFY" "$@" >/dev/null 2>&1
  case "$?" in
    2) ok "사용오류: $desc (exit 2)" ;;
    *) ng "사용오류: $desc — exit 2 기대, 실제 $?" ;;
  esac
}

assert_usage_error '인자 없음'
assert_usage_error '--repo 누락'       --remote origin --branch feature --head-oid "$head_oid" --approved-sha "$approved"
assert_usage_error '--branch 누락'     --remote origin --repo 'github.com/o/r' --head-oid "$head_oid" --approved-sha "$approved"
assert_usage_error '--head-oid 누락'   --remote origin --repo 'github.com/o/r' --branch feature --approved-sha "$approved"
assert_usage_error 'SHA 형식 아님'     --remote origin --repo 'github.com/o/r' --branch feature --head-oid 'zzzz123' --approved-sha "$approved"
assert_usage_error 'SHA 너무 짧음'     --remote origin --repo 'github.com/o/r' --branch feature --head-oid 'abc12' --approved-sha "$approved"
assert_usage_error '알 수 없는 인자'    --remote origin --force

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
