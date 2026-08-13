#!/usr/bin/env bash
#
# validate-title.sh — PR 제목이 "PR 제목" 규격을 지키는지 결정적으로 판정한다.
#
# SKILL.md 의 "PR 제목" 섹션이 규격의 SSoT 이며 이 스크립트는 그것을 옮긴 사본이다.
# 타입 목록이나 이슈 번호 표기가 바뀌면 이 스크립트와 tests/ 의 기대값을 함께 갱신한다.
#
# git-commit 의 validate-message.sh 와 규격이 겹치나 두 지점이 다르다.
#   - PR 제목은 이슈 번호 나열이 필수이고 통합 배포에서 여러 개를 쉼표로 잇는다.
#   - 스킬 독립성 원칙(단독 실행·단독 설치)상 헬퍼를 공유하지 않으므로 각 스킬이 따로 갖는다.
#
# 사용법:
#   validate-title.sh --title '<제목>'
#   validate-title.sh <제목 파일>
#
# 판정 항목:
#   - `<타입>[(적용 범위)][!]: <제목> (#<번호>[, #<번호>]…)` 형식인가
#   - 타입이 허용 8종 중 하나인가
#   - 이슈 번호 나열이 말미에 있고 쉼표+공백으로 이어지는가
#
# 종료 코드: 0 통과(무출력) / 1 규격 위반(사유를 표준 출력에 1행씩) / 2 사용오류

set -o pipefail

usage() { sed -n '3,23p' "$0" | sed 's/^# \{0,1\}//'; }

# git-commit SKILL.md "타입" 표의 8종. PR 제목도 같은 Conventional Commits 규격을 쓴다.
TYPES='feat|fix|docs|style|refactor|test|chore|ci'

# 이슈 번호 나열 — 단일 `(#123)`, 통합 `(#123, #124)`.
ISSUES=' \(#[0-9]+(, #[0-9]+)*\)$'

file=''
title_arg=''
have_title=false

while [ $# -gt 0 ]; do
  case "$1" in
    --title)
      [ $# -ge 2 ] || { echo "error: --title 에 값이 필요합니다" >&2; exit 2; }
      title_arg="$2"; have_title=true; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "error: 알 수 없는 옵션 — $1" >&2; exit 2 ;;
    *)
      [ -z "$file" ] || { echo "error: 제목 파일은 하나만 지정합니다" >&2; exit 2; }
      file="$1"; shift ;;
  esac
done

if [ "$have_title" = true ] && [ -n "$file" ]; then
  echo "error: --title 과 제목 파일은 함께 쓸 수 없습니다" >&2; exit 2
fi
if [ "$have_title" = false ] && [ -z "$file" ]; then
  echo "error: 제목 파일 또는 --title 이 필요합니다" >&2
  usage >&2
  exit 2
fi

if [ -n "$file" ]; then
  # 존재하지 않는 경로를 빈 제목으로 흘리지 않는다 — 제출 직전 파일 경로 오타가 "제목 없음" 위반으로 둔갑한다.
  [ -r "$file" ] || { echo "error: 읽을 수 없는 파일 — $file" >&2; exit 2; }
  title="$(sed -n '1p' "$file")"
else
  title="$title_arg"
fi

violations=0
ng() { echo "위반: $1"; violations=$((violations + 1)); }

if [ -z "$title" ]; then
  ng "제목이 비어 있습니다"
else
  # 형식 검사는 이슈 나열을 떼어낸 나머지로 한다. 붙인 채로 보면 `feat: (#123)` 처럼
  # 설명 자리에 이슈 번호만 있는 제목이 "설명 있음"으로 통과한다.
  core="$(printf '%s\n' "$title" | sed -E "s/$ISSUES//")"

  if ! printf '%s\n' "$core" | grep -qE "^($TYPES)(\([^()]+\))?!?: .+$"; then
    if printf '%s\n' "$core" | grep -qE "^($TYPES)(\([^()]+\))?!?: *$"; then
      ng "제목 설명이 비어 있습니다: $title"
    elif printf '%s\n' "$core" | grep -qE '^[A-Za-z]+(\([^()]+\))?!?: '; then
      ng "허용되지 않은 타입 — $(printf '%s\n' "$core" | sed -E 's/^([A-Za-z]+).*/\1/') (허용: ${TYPES//|/, })"
    else
      ng "제목 형식 위반 — '<타입>[(적용 범위)][!]: <제목> (#<번호>)' 형식이어야 합니다: $title"
    fi
  fi

  # 이슈 번호는 Squash Merge 후 커밋 이력에서 PR 을 되짚는 유일한 단서라 나열을 필수로 둔다.
  if ! printf '%s\n' "$title" | grep -qE "$ISSUES"; then
    if printf '%s\n' "$title" | grep -qE '#[0-9]+'; then
      ng "이슈 번호 나열 형식 위반 — 말미에 ' (#<번호>)' 또는 ' (#<번호>, #<번호>)' 로 적습니다: $title"
    else
      ng "이슈 번호가 없습니다 — 말미에 ' (#<번호>)' 를 적습니다: $title"
    fi
  fi
fi

[ "$violations" -eq 0 ]
