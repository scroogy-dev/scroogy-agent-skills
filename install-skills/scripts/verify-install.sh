#!/usr/bin/env bash
#
# verify-install.sh — install-skills 설치 결과를 결정적으로 검증한다.
#
# 사람·AI 판단 없이 exit code로 합/불을 낸다 (PASS=0, FAIL=1, 사용오류=2).
# 검사 항목:
#   - 각 대상 경로에 각 skill 디렉토리가 존재하는가
#   - 각 설치본에 SKILL.md가 존재하는가
#   - 설치본에 배포 제외 경로(tests/ 디렉토리, *.test.* 파일)가 섞이지 않았는가
#   - (옵션) 레거시 구 경로가 실제 디렉토리로 잔존하지 않는가 (심링크/부재는 정상)
#
# 사용법:
#   verify-install.sh --target <dir> [--target <dir>...] \
#       [--legacy-dir <path>] [--antigravity-legacy] [--] <skill-name>...
#
# 옵션:
#   --target <dir>         설치 대상 경로 (1회 이상, 반복 가능)
#   --legacy-dir <path>    점검할 레거시 구 경로 (반복 가능). 테스트가 픽스처를 주입할 때 사용.
#   --antigravity-legacy   내장 기본 레거시 경로를 점검 대상에 추가한다.
#                          (구 경로 리터럴은 SKILL.md가 아니라 이 스크립트가 보유 — 이슈 #28 결정)
#
# 단어 분리에 의존하지 않도록 배열과 "$@"만 사용한다.

set -o pipefail

# 구 Antigravity skills 경로의 단일 출처(SSoT). SKILL.md는 이 리터럴을 갖지 않고
# --antigravity-legacy 플래그로 이 값을 참조한다 (이슈 #28 옵션 B).
LEGACY_DEFAULT="$HOME/.gemini/antigravity/skills"

usage() {
  sed -n '3,20p' "$0" | sed 's/^# \{0,1\}//'
}

targets=()
skills=()
legacy_dirs=()

while [ $# -gt 0 ]; do
  case "$1" in
    --target)
      [ $# -ge 2 ] || { echo "error: --target 에 값이 필요합니다" >&2; exit 2; }
      targets+=("$2"); shift 2 ;;
    --legacy-dir)
      [ $# -ge 2 ] || { echo "error: --legacy-dir 에 값이 필요합니다" >&2; exit 2; }
      legacy_dirs+=("$2"); shift 2 ;;
    --antigravity-legacy)
      legacy_dirs+=("$LEGACY_DEFAULT"); shift ;;
    -h|--help)
      usage; exit 0 ;;
    --)
      shift
      while [ $# -gt 0 ]; do skills+=("$1"); shift; done ;;
    -*)
      echo "error: 알 수 없는 옵션 — $1" >&2; exit 2 ;;
    *)
      skills+=("$1"); shift ;;
  esac
done

if [ ${#targets[@]} -eq 0 ]; then
  echo "error: --target 가 최소 1개 필요합니다" >&2; exit 2
fi
if [ ${#skills[@]} -eq 0 ]; then
  echo "error: 검사할 skill 이름이 최소 1개 필요합니다" >&2; exit 2
fi

fail=0
err() { echo "FAIL: $*" >&2; fail=1; }

# 1) skill 디렉토리·SKILL.md 존재 + 배포 제외 경로 미포함
for t in "${targets[@]}"; do
  for s in "${skills[@]}"; do
    inst="$t/$s"
    if [ ! -d "$inst" ]; then
      err "skill 디렉토리 없음 — $inst"
      continue
    fi
    [ -f "$inst/SKILL.md" ] || err "SKILL.md 없음 — $inst/SKILL.md"
    # 배포 제외 패턴(tests/, *.test.*)의 SSoT 는 SKILL.md 설치 절차 5단계다 (ADR 0001).
    # 그 목록이 바뀌면 아래 두 검사도 함께 갱신한다.
    if [ -d "$inst/tests" ]; then
      err "배포 제외 위반(tests/ 잔존) — $inst/tests"
    fi
    while IFS= read -r f; do
      [ -n "$f" ] && err "배포 제외 위반(*.test.* 잔존) — $f"
    done < <(find "$inst" -type f -name '*.test.*' 2>/dev/null)
  done
done

# 2) 레거시 구 경로 점검 (옵션). 심링크/부재 → 정상, 비어있지 않은 실제 디렉토리 → FAIL.
if [ ${#legacy_dirs[@]} -gt 0 ]; then
  for ld in "${legacy_dirs[@]}"; do
    if [ -L "$ld" ]; then
      echo "INFO: 레거시 경로가 심링크 — 보존 ($ld -> $(readlink "$ld"))"
    elif [ ! -e "$ld" ]; then
      echo "INFO: 레거시 경로 없음 — 정상 ($ld)"
    elif [ -d "$ld" ]; then
      if [ -n "$(ls -A "$ld" 2>/dev/null)" ]; then
        err "레거시 구 경로가 실제 디렉토리로 잔존(정리 필요) — $ld"
      else
        # 빈 실제 디렉토리는 skill 중복 인식 위험이 없어 PASS (plan Task 2: "비어있지 않으면 FAIL").
        echo "INFO: 레거시 경로가 빈 실제 디렉토리 — 정상 ($ld)"
      fi
    else
      err "레거시 경로가 예상치 못한 유형 — $ld"
    fi
  done
fi

if [ "$fail" -ne 0 ]; then
  echo "RESULT: FAIL" >&2
  exit 1
fi
echo "RESULT: PASS"
exit 0
