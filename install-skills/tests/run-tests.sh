#!/usr/bin/env bash
#
# install-skills 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# 1) verify-install.sh: 픽스처를 임시 디렉토리에 동적으로 만들고 exit code 를
#    기대값과 비교한다.
# 2) SKILL.md 스니펫 스모크: 본문 bash 블록(가드·스캔·헬퍼 탐색)을 추출해
#    픽스처에서 실행한다 — 문서의 실행 지침이 깨지면 여기서 감지된다.
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.
#
# 심링크 픽스처는 git 에 커밋하면 취약하므로 런타임에 생성한다.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$HERE/../scripts/verify-install.sh"

if [ ! -x "$SCRIPT" ]; then
  echo "error: 검증 스크립트가 실행 가능하지 않음 — $SCRIPT" >&2
  exit 1
fi

pass=0
fail=0

# assert_exit <기대코드> <설명> <명령...>
assert_exit() {
  expected="$1"; desc="$2"; shift 2
  "$@" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$expected" ]; then
    echo "ok     - $desc (exit $got)"
    pass=$((pass + 1))
  else
    echo "NOT OK - $desc (기대 $expected, 실제 $got)"
    fail=$((fail + 1))
  fi
}

sandbox="$(mktemp -d)"
trap 'rm -rf "$sandbox"' EXIT

# 대상 경로 <target> 에 skill <name> 의 정상 설치본을 만든다.
mk_skill() {
  mkdir -p "$1/$2"
  printf -- '---\nname: %s\n---\n예시 본문\n' "$2" > "$1/$2/SKILL.md"
}

# --- 정상 설치 → PASS ---
clean="$sandbox/clean"
mk_skill "$clean" "alpha"
mk_skill "$clean" "beta"
assert_exit 0 "정상 설치 → PASS" \
  "$SCRIPT" --target "$clean" alpha beta

# --- skill 누락 → FAIL ---
assert_exit 1 "누락 skill → FAIL" \
  "$SCRIPT" --target "$clean" alpha gamma

# --- SKILL.md 부재 → FAIL ---
no_md="$sandbox/no-md"
mkdir -p "$no_md/alpha"
assert_exit 1 "SKILL.md 부재 → FAIL" \
  "$SCRIPT" --target "$no_md" alpha

# --- tests/ 잔존 → FAIL ---
with_tests="$sandbox/with-tests"
mk_skill "$with_tests" "alpha"
mkdir -p "$with_tests/alpha/tests"
touch "$with_tests/alpha/tests/run-tests.sh"
assert_exit 1 "tests/ 잔존 → FAIL" \
  "$SCRIPT" --target "$with_tests" alpha

# --- *.test.* 잔존 → FAIL ---
with_testfile="$sandbox/with-testfile"
mk_skill "$with_testfile" "alpha"
touch "$with_testfile/alpha/helper.test.js"
assert_exit 1 "*.test.* 잔존 → FAIL" \
  "$SCRIPT" --target "$with_testfile" alpha

# --- 레거시 실제 디렉토리(비어있지 않음) → FAIL ---
legacy_real="$sandbox/legacy-real"
mkdir -p "$legacy_real"
touch "$legacy_real/leftover-skill-marker"
assert_exit 1 "레거시 실제 디렉토리 잔존 → FAIL" \
  "$SCRIPT" --target "$clean" --legacy-dir "$legacy_real" alpha beta

# --- 레거시 심링크 → PASS ---
legacy_link="$sandbox/legacy-link"
ln -s "$clean" "$legacy_link"
assert_exit 0 "레거시 심링크 → PASS" \
  "$SCRIPT" --target "$clean" --legacy-dir "$legacy_link" alpha beta

# --- 레거시 부재 → PASS ---
assert_exit 0 "레거시 부재 → PASS" \
  "$SCRIPT" --target "$clean" --legacy-dir "$sandbox/does-not-exist" alpha beta

# --- 빈 실제 디렉토리 레거시 → PASS (정리 권고 대상 아님) ---
legacy_empty="$sandbox/legacy-empty"
mkdir -p "$legacy_empty"
assert_exit 0 "레거시 빈 실제 디렉토리 → PASS" \
  "$SCRIPT" --target "$clean" --legacy-dir "$legacy_empty" alpha beta

# ============ SKILL.md 스니펫 스모크 테스트 ============

SKILL_MD="$HERE/../SKILL.md"

# assert_out <기대출력> <설명> <명령...> — exit code 무시, stdout 만 비교
assert_out() {
  expected="$1"; desc="$2"; shift 2
  got="$("$@" 2>/dev/null)"
  if [ "$got" = "$expected" ]; then
    echo "ok     - $desc"
    pass=$((pass + 1))
  else
    echo "NOT OK - $desc (기대 [$expected], 실제 [$got])"
    fail=$((fail + 1))
  fi
}

# SKILL.md 에서 marker 를 포함한 줄부터 코드펜스 종료 직전까지 추출한다.
extract_snippet() {
  awk -v m="$1" 'index($0, m) {on=1} on && /^[[:space:]]*```/ {exit} on {print}' "$SKILL_MD"
}

snip_dir="$sandbox/snippets"
mkdir -p "$snip_dir"
extract_snippet "판별 가드 — */SKILL.md 가 0개면 중단" > "$snip_dir/guard.sh"
extract_snippet "기본: install-skills 자신 제외" > "$snip_dir/scan.sh"
extract_snippet "헬퍼 탐색: 홈 설치본 우선" > "$snip_dir/lookup.sh"

assert_exit 0 "스니펫 추출: 가드" test -s "$snip_dir/guard.sh"
assert_exit 0 "스니펫 추출: 스캔" test -s "$snip_dir/scan.sh"
assert_exit 0 "스니펫 추출: 헬퍼 탐색" test -s "$snip_dir/lookup.sh"

# --- 가드: 비-스킬 디렉토리(0건) → 중단, 단일 스킬 repo(1건) → 통과 ---
non_skill="$sandbox/non-skill"
mkdir -p "$non_skill"
assert_exit 1 "가드: 비-스킬 디렉토리(0건) → 중단" \
  bash -c 'cd "$1" && bash "$2"' _ "$non_skill" "$snip_dir/guard.sh"

single_skill="$sandbox/single-skill"
mk_skill "$single_skill" "solo"
assert_exit 0 "가드: 단일 스킬 repo(1건) → 통과" \
  bash -c 'cd "$1" && bash "$2"' _ "$single_skill" "$snip_dir/guard.sh"

# --- 가드: nullglob 켠 셸에서도 오작동 없이 판정 (source 로 셸 옵션을 유지한 채 실행) ---
assert_exit 1 "가드: nullglob 셸(0건) → 중단" \
  bash -c 'shopt -s nullglob; cd "$1" && . "$2"' _ "$non_skill" "$snip_dir/guard.sh"
assert_exit 0 "가드: nullglob 셸(1건) → 통과" \
  bash -c 'shopt -s nullglob; cd "$1" && . "$2"' _ "$single_skill" "$snip_dir/guard.sh"

# --- 스캔: 기본은 install-skills 자신 제외, self_install=true 면 포함 ---
scan_repo="$sandbox/scan-repo"
mk_skill "$scan_repo" "alpha"
mk_skill "$scan_repo" "install-skills"
assert_out "alpha" "스캔: 기본 — install-skills 자신 제외" \
  bash -c 'cd "$1" && bash "$2"' _ "$scan_repo" "$snip_dir/scan.sh"
assert_out "alpha
install-skills" "스캔: --self — 자기 자신 포함" \
  bash -c 'cd "$1" && self_install=true bash "$2"' _ "$scan_repo" "$snip_dir/scan.sh"

# --- 헬퍼 탐색: 홈 설치본 우선, 없으면 cwd 폴백 (스니펫 끝의 검증 호출까지 실행) ---
lookup_wrapper="$snip_dir/lookup-wrapper.sh"
cat > "$lookup_wrapper" <<'EOF'
#!/usr/bin/env bash
# T_HOME/T_CWD/T_TARGET/SNIP/EXPECT 는 러너가 env 로 주입한다.
HOME="$T_HOME"
target="$T_TARGET"
skills=(alpha beta)
cd "$T_CWD" || exit 9
. "$SNIP" || exit 4
if [ "$EXPECT" = "home" ]; then
  [ "$verify" = "$HOME/.claude/skills/install-skills/scripts/verify-install.sh" ] || exit 3
else
  [ "$verify" = "install-skills/scripts/verify-install.sh" ] || exit 3
fi
EOF

home_with="$sandbox/home-with"
mkdir -p "$home_with/.claude/skills/install-skills/scripts"
cp "$SCRIPT" "$home_with/.claude/skills/install-skills/scripts/verify-install.sh"
chmod +x "$home_with/.claude/skills/install-skills/scripts/verify-install.sh"

home_without="$sandbox/home-without"
mkdir -p "$home_without"

lookup_cwd="$sandbox/lookup-cwd"
mkdir -p "$lookup_cwd/install-skills/scripts"
cp "$SCRIPT" "$lookup_cwd/install-skills/scripts/verify-install.sh"
chmod +x "$lookup_cwd/install-skills/scripts/verify-install.sh"

assert_exit 0 "헬퍼 탐색: 홈 설치본 우선 선택" \
  env T_HOME="$home_with" T_CWD="$lookup_cwd" T_TARGET="$clean" SNIP="$snip_dir/lookup.sh" EXPECT=home \
  bash "$lookup_wrapper"
assert_exit 0 "헬퍼 탐색: 홈 부재 시 cwd 폴백" \
  env T_HOME="$home_without" T_CWD="$lookup_cwd" T_TARGET="$clean" SNIP="$snip_dir/lookup.sh" EXPECT=cwd \
  bash "$lookup_wrapper"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
