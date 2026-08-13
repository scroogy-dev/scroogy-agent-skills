#!/usr/bin/env bash
#
# validate-message.sh — 커밋 메시지가 Conventional Commits 제목 규격을 지키는지 결정적으로 판정한다.
#
# SKILL.md 의 "커밋 메시지 포맷"·"타입"·"파괴적 변경"·"주의사항"이 규격의 SSoT 이며
# 이 스크립트는 그것을 옮긴 사본이다. 타입 표가 바뀌면 이 스크립트와 tests/ 의 기대값을 함께 갱신한다.
#
# 사용법:
#   validate-message.sh [--allow-coauthor] <메시지 파일>
#   validate-message.sh [--allow-coauthor] --subject '<제목 줄>'
#
# 옵션:
#   --subject <값>      제목 줄만 검사한다 (파일을 만들지 않고 초안을 확인할 때).
#   --allow-coauthor    `Co-Authored-By:` 꼬리말을 허용한다 (사용자가 명시 요청한 경우).
#
# 판정 항목:
#   - 제목이 `<타입>[(적용 범위)][!]: <설명>` 형식인가
#   - 타입이 허용 8종 중 하나인가
#   - 이슈 번호를 적었으면 말미 ` (#<숫자>)` 형식인가
#   - 제목과 본문 사이에 빈 줄이 있는가 (파일 모드 전용)
#   - `Co-Authored-By:` 꼬리말이 없는가
#
# 종료 코드: 0 통과(무출력) / 1 규격 위반(사유를 표준 출력에 1행씩) / 2 사용오류

set -o pipefail

usage() { sed -n '3,26p' "$0" | sed 's/^# \{0,1\}//'; }

# SKILL.md "타입" 표의 8종. 정규식 교대(alternation)로 쓰므로 `|` 로 잇는다.
TYPES='feat|fix|docs|style|refactor|test|chore|ci'

allow_coauthor=false
file=''
subject_arg=''
have_subject=false

while [ $# -gt 0 ]; do
  case "$1" in
    --allow-coauthor) allow_coauthor=true; shift ;;
    --subject)
      [ $# -ge 2 ] || { echo "error: --subject 에 값이 필요합니다" >&2; exit 2; }
      subject_arg="$2"; have_subject=true; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "error: 알 수 없는 옵션 — $1" >&2; exit 2 ;;
    *)
      [ -z "$file" ] || { echo "error: 메시지 파일은 하나만 지정합니다" >&2; exit 2; }
      file="$1"; shift ;;
  esac
done

if [ "$have_subject" = true ] && [ -n "$file" ]; then
  echo "error: --subject 와 메시지 파일은 함께 쓸 수 없습니다" >&2; exit 2
fi
if [ "$have_subject" = false ] && [ -z "$file" ]; then
  echo "error: 메시지 파일 또는 --subject 가 필요합니다" >&2
  usage >&2
  exit 2
fi

if [ -n "$file" ]; then
  # 존재하지 않는 경로를 빈 메시지로 흘리지 않는다 — 경로 오타가 "제목 없음" 위반으로 둔갑한다.
  [ -r "$file" ] || { echo "error: 읽을 수 없는 파일 — $file" >&2; exit 2; }
  message="$(cat "$file")"
else
  message="$subject_arg"
fi

subject="$(printf '%s\n' "$message" | sed -n '1p')"

violations=0
ng() { echo "위반: $1"; violations=$((violations + 1)); }

if [ -z "$subject" ]; then
  ng "제목 줄이 비어 있습니다"
elif ! printf '%s\n' "$subject" | grep -qE "^($TYPES)(\([^()]+\))?!?: .+$"; then
  # 사유를 셋으로 나눈다. "형식 위반" 한 줄로 뭉치면 타입 오타와 설명 누락이 구분되지 않는다.
  if printf '%s\n' "$subject" | grep -qE "^($TYPES)(\([^()]+\))?!?: *$"; then
    ng "설명이 비어 있습니다: $subject"
  elif printf '%s\n' "$subject" | grep -qE '^[A-Za-z]+(\([^()]+\))?!?: '; then
    ng "허용되지 않은 타입 — $(printf '%s\n' "$subject" | sed -E 's/^([A-Za-z]+).*/\1/') (허용: ${TYPES//|/, })"
  else
    ng "제목 형식 위반 — '<타입>[(적용 범위)][!]: <설명>' 형식이어야 합니다: $subject"
  fi
fi

# 이슈 번호는 제목 말미 괄호 안에 둔다. 본문 중간의 `#12` 는 참조인지 이슈 번호인지 구분되지 않는다.
if printf '%s\n' "$subject" | grep -qE '#[0-9]+'; then
  printf '%s\n' "$subject" | grep -qE ' \(#[0-9]+\)$' \
    || ng "이슈 번호는 제목 말미에 ' (#<숫자>)' 형식으로 적습니다: $subject"
fi

# 본문 유무는 파일 모드에서만 판정한다 — --subject 는 애초에 한 줄만 받는다.
if [ -n "$file" ]; then
  line_count="$(printf '%s\n' "$message" | wc -l | tr -d ' ')"
  if [ "$line_count" -ge 2 ] && [ -n "$(printf '%s\n' "$message" | sed -n '2p')" ]; then
    ng "제목과 본문 사이에 빈 줄이 필요합니다"
  fi
fi

if [ "$allow_coauthor" = false ] && printf '%s\n' "$message" | grep -qiE '^Co-Authored-By:'; then
  ng "Co-Authored-By 꼬리말은 사용자가 명시 요청한 경우에만 씁니다 (허용하려면 --allow-coauthor)"
fi

[ "$violations" -eq 0 ]
