#!/usr/bin/env bash
#
# check-clear.sh — `--clear` 의 완료 확인(1단계)과 경로 참조 검증(6단계)을 결정적으로 판정한다.
#
# SKILL.md `--clear` 절이 규격의 SSoT 이며 이 스크립트는 그 두 검사의 사본이다.
# 절차가 바뀌면 이 스크립트와 tests/ 의 기대값을 함께 갱신한다.
#
# 완료 확인은 설계 종료 게이트 체크박스가 `## Tasks` 밖에 있어 Task 체크박스만 세면 누락된다.
# 두 축을 한 명령이 함께 세어 그 누락을 구조적으로 막는다.
#
# 사용법:
#   check-clear.sh --completion <plan 파일>
#   check-clear.sh --refs <archive 이슈 디렉토리>
#
# 종료 코드: 0 통과(무출력) / 1 미완료·잔존 참조 있음(항목을 1행씩 출력) / 2 사용오류

set -o pipefail

usage() { sed -n '3,18p' "$0" | sed 's/^# \{0,1\}//'; }

mode=''
target=''

while [ $# -gt 0 ]; do
  case "$1" in
    --completion|--refs)
      [ -z "$mode" ] || { echo "error: 모드는 하나만 지정합니다" >&2; exit 2; }
      mode="${1#--}"
      [ $# -ge 2 ] || { echo "error: $1 에 값이 필요합니다" >&2; exit 2; }
      target="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: 알 수 없는 인자 — $1" >&2; exit 2 ;;
  esac
done

[ -n "$mode" ] || { echo "error: --completion 또는 --refs 가 필요합니다" >&2; usage >&2; exit 2; }

if [ "$mode" = 'completion' ]; then
  [ -r "$target" ] || { echo "error: 읽을 수 없는 파일 — $target" >&2; exit 2; }

  open=0

  # 설계 종료 게이트 — `## Tasks` 앞 고정 블록이라 Task 체크박스 계수와 분리해서 센다.
  gate="$(grep -cE '^- \[[ xX]\] 점검 완료[[:space:]]*$' "$target")"
  if [ "$gate" -eq 0 ]; then
    echo "미완료: 설계 종료 게이트 '점검 완료' 항목을 찾을 수 없습니다"
    open=$((open + 1))
  elif grep -qE '^- \[ \] 점검 완료[[:space:]]*$' "$target"; then
    echo "미완료: 설계 종료 게이트 점검 완료"
    open=$((open + 1))
  fi

  # Task 체크박스 — 각 `### Task ` 블록에 완료 체크박스가 정확히 1개 있고 체크되어야 한다.
  # 미체크만 세면 체크박스가 아예 없는 블록이 "미체크 아님"으로 통과하므로 실재·유일성을 함께 센다.
  tasks="$(awk '
    function flush() {
      if (title == "") return
      if (n == 0)     print "미완료: " title " (완료 체크박스가 없습니다)"
      else if (n > 1) print "미완료: " title " (완료 체크박스가 " n "개입니다 — 블록마다 1개)"
      else if (unchecked) print "미완료: " title
    }
    /^### Task / { flush(); title = $0; sub(/^### /, "", title); n = 0; unchecked = 0; next }
    title != "" && /^- \[[ xX]\] 완료[[:space:]]*$/ {
      n++
      if ($0 ~ /^- \[ \] 완료/) unchecked = 1
    }
    END { flush() }
  ' "$target")"

  if [ -n "$tasks" ]; then
    while IFS= read -r t; do
      [ -n "$t" ] || continue
      echo "$t"
      open=$((open + 1))
    done <<EOF
$tasks
EOF
  fi

  # Task 블록이 하나도 없으면 "미완료 0건"이 아니라 입력이 잘못된 것이다.
  if ! grep -qE '^### Task ' "$target"; then
    echo "미완료: plan 에서 '### Task ' 블록을 찾을 수 없습니다 — 경로를 확인하세요"
    open=$((open + 1))
  fi

  [ "$open" -eq 0 ]
  exit $?
fi

# --- 경로 참조 검증 (6단계) --------------------------------------------------------
#
# 제외 2건의 근거는 SKILL.md 와 같다.
#   - `active/issue-workflow.md` 는 이동하지 않는 상주 파일이라 참조가 항상 유효하다.
#   - "작성 시점 경로는" 은 표준 병기 문구 안의 옛 경로(의도된 이력 표기)다.

[ -d "$target" ] || { echo "error: 디렉토리가 아닙니다 — $target" >&2; exit 2; }

hits="$(grep -rnE '90_issues/active/|active/issue-[0-9]+|99_workspace/[A-Za-z0-9_.-]' "$target" 2>/dev/null \
  | grep -v 'active/issue-workflow\.md' \
  | grep -v '작성 시점 경로는')"

[ -z "$hits" ] || { printf '%s\n' "$hits"; exit 1; }
