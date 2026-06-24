#!/usr/bin/env bash
#
# verify-install.sh 의 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# 픽스처를 임시 디렉토리에 동적으로 만들고 verify-install.sh 의 exit code 를
# 기대값과 비교한다. 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.
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

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
