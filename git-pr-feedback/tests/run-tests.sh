#!/usr/bin/env bash
#
# git-pr-feedback 회귀 테스트 러너 (git 외 외부 의존성 없음, ADR 0001).
#
# verify-push.sh 를 임시 저장소로 실제 git 동작에 걸어 검증한다.
# push URL 복수 설정·원격 rewind·비전진 승인 SHA 처럼 손으로 재현하기 번거로운 상태를
# 여기서 만들어 각 가드가 실제로 발동하는지 본다.
# check-ledger-links.sh 는 임시 `.ai` 트리를 만들어 끊긴 원장 링크 판정을 검증한다.
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
VERIFY="$HERE/../scripts/verify-push.sh"
LEDGER="$HERE/../scripts/check-ledger-links.sh"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

for s in "$VERIFY" "$LEDGER"; do
  [ -x "$s" ] || { echo "NOT OK - 헬퍼 실행 권한 없음 — $s"; exit 1; }
done

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

# --- 링크 갱신 규칙 (issue #120) --------------------------------------------------
#
# 원장 항목을 archive/ 로 옮긴 뒤의 링크 갱신은 SKILL.md `### 기존 원장 항목의 종결` 절의 정의 행
# (`**들어오는 링크 갱신**:`)과 그 아래 헬퍼 호출 블록이 계약이다.
# 정의 행은 파일 전체에서 정확히 1개로 세고 조각 8개를 그 행에서 판정한다. 위치 판정은
# issue-0120 spec R4 의 [D] 를 옮긴 것이다. 호출 블록은 정의 행 다음 행부터 종결 절 다음의 `##` 이상 제목 앞까지에서
# 경로 설정 행과 호출 행을 본다 — 정의 행의 헬퍼 이름 조각으로는 경로 오타나 호출 행 누락을 잡지 못한다.
# 위반 행은 판정 이름(정의·위치·호출)으로 시작하고, 격추 케이스는 노린 판정이 위반을 냈는지 본다.
# issue-work·git-pr 러너에도 같은 판정을 그 스킬의 적용 지점에 맞춰 둔다.

# check_link_rule <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
check_link_rule() {
  local re n line a cfg v blk
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
  # 절 끝은 `^##+ ` 로 잡는다 — `^#` 로 잡으면 절 안 코드 블록의 `# 주석` 행에서 범위가 끊긴다.
  awk '/^### 기존 원장 항목의 종결$/ { s = 1; next } /^##+ / { s = 0 }
       s && /^ *- \*\*들어오는 링크 갱신\*\*: / { n++ }
       END { if (n != 1) print "위치: 종결 절의 정의 행 " n+0 "개 (기대 1개)" }' "$1"
  # 호출 블록: 정의 행 다음 행부터 다음 `##` 이상 제목 앞까지
  blk=$(awk '/^ *([0-9]+\.|-) \*\*들어오는 링크 갱신\*\*: / { r = 1; next }
             r && /^##+ / { r = 0 }
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

# drop_literal <파일> <문자열> → 문자열을 정규식 해석 없이 지운 사본을 표준 출력으로
drop_literal() {
  awk -v s="$2" '{ while ((i = index($0, s))) $0 = substr($0, 1, i - 1) substr($0, i + length(s)); print }' "$1"
}

# 호출 블록의 두 변형(lr-bad-path·lr-no-call)은 그 블록 행만 바꿔 정의·위치 판정은 그대로 둔다.
awk '!/^ *([0-9]+\.|-) \*\*들어오는 링크 갱신\*\*: /' "$SKILL" > "$TMP/lr-del.md"
drop_literal "$SKILL" '링크가 있는 문서 위치에서 다시 계산' > "$TMP/lr-no-depth.md"
awk '/^ *- \*\*들어오는 링크 갱신\*\*: / { held = $0; next } { print }
     held != "" && !done && /^##+ / { print held; done = 1 }' "$SKILL" > "$TMP/lr-moved.md"
awk '/^[[:space:]]*ledger_links=/ { sub(/check-ledger-links\.sh/, "missing-helper.sh") } { print }' \
  "$SKILL" > "$TMP/lr-bad-path.md"
awk '!/^[[:space:]]*"\$ledger_links"/' "$SKILL" > "$TMP/lr-no-call.md"

assert_link_rule "$SKILL"                 pass "링크 갱신 규칙: 실제 SKILL.md 정의 행·적용 지점·호출 블록 통과"
assert_link_rule "$TMP/lr-del.md"         정의 "링크 갱신 규칙: 정의 행 삭제 격추"
assert_link_rule "$TMP/lr-no-depth.md"    정의 "링크 갱신 규칙: 정의 행의 깊이 재계산 조각 삭제 격추"
assert_link_rule "$TMP/lr-moved.md"       위치 "링크 갱신 규칙: 정의 행을 종결 절 밖(다음 제목 뒤)으로 이동 격추"
assert_link_rule "$TMP/lr-bad-path.md"    호출 "링크 갱신 규칙: 경로 설정 값을 없는 파일로 바꾼 호출 블록 격추"
assert_link_rule "$TMP/lr-no-call.md"     호출 "링크 갱신 규칙: 호출 행 삭제 격추"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
