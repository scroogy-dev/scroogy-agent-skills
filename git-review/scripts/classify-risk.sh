#!/usr/bin/env bash
#
# classify-risk.sh — git-review 위험도·상태·판정을 결정적으로 산출한다.
#
# SKILL.md "위험도 분류"·"상태 산출"·"판정 산출"은 리뷰어가 등급·상태·판정을 직접
# 고르지 않고 축·서열의 조합으로 산출하도록 정한다. 이 스크립트가 그 매핑을 명령으로
# 강제해 리뷰마다 값이 갈리지 않게 한다. 축 값·매트릭스·상태 표·판정 표·이모지
# 대응표의 SSoT 는 SKILL.md 이며, 표가 바뀌면 이 스크립트와 tests/ 의 기대값을
# 함께 갱신한다.
#
# 출력은 대응표 이모지를 앞에 붙인 `<이모지> <값>` 형식이다. 입력은 이모지 접두가
# 붙은 값과 붙지 않은 값을 모두 받아 헬퍼 출력을 그대로 되넘길 수 있다.
#
# 사용법:
#   classify-risk.sh --impact <영향 축> --likelihood <발생확률 축>
#   classify-risk.sh --status [<위험도>...]
#   classify-risk.sh --verdict <상태> <상태>
#
# 옵션:
#   --impact <값>       영향 축 — 스펙·기능 달성 차단 / 기능 저하 / 기술 품질 의견
#   --likelihood <값>   발생확률 축 — 통상 사용 / 특수 조건·엣지
#   --status [값...]    위험도 목록의 최고값으로 상태를 산출한다. 인자가 없으면 발견 없음으로 보고 통과(PASS).
#   --verdict <값> <값> 비즈니스·테크 리뷰 상태 2개의 최고값으로 판정을 산출한다. 순서는 무관하다.
#
# 종료 코드: 0 산출 성공 / 2 사용오류(허용되지 않은 값, 인자 누락·개수 불일치, 모드 혼용)

set -o pipefail

usage() { sed -n '3,25p' "$0" | sed 's/^# \{0,1\}//'; }

# SKILL.md "판정 산출"의 이모지 대응표. 등급 4·상태 3·판정 3 을 표와 같은 순서로 옮긴다.
emoji() {
  case "$1" in
    '높음(HIGH)')                 echo '🔴' ;;
    '중간(MEDIUM)')               echo '🟡' ;;
    '낮음(LOW)')                  echo '🟢' ;;
    '정보(INFO)')                 echo '⚪' ;;
    '보완 필요(FAIL)')            echo '🔴' ;;
    '주의(WARN)')                 echo '🟡' ;;
    '통과(PASS)')                 echo '🟢' ;;
    '변경 요청(REQUEST CHANGES)') echo '🔴' ;;
    '조건부 승인(CONDITIONAL)')   echo '🟡' ;;
    '승인(APPROVE)')              echo '🟢' ;;
    *) return 1 ;;
  esac
}

# 대응표의 접두 4종만 걷어낸다. 그 밖의 접두는 남겨 뒤의 값 검증에서 사용오류가 되게 한다.
strip_emoji() {
  case "$1" in
    '🔴 '*) echo "${1#🔴 }" ;;
    '🟡 '*) echo "${1#🟡 }" ;;
    '🟢 '*) echo "${1#🟢 }" ;;
    '⚪ '*) echo "${1#⚪ }" ;;
    *) echo "$1" ;;
  esac
}

# SKILL.md 영향 × 발생확률 매트릭스. 구분자 `|` 는 축 값에 등장하지 않는다.
matrix() {
  case "$1|$2" in
    '스펙·기능 달성 차단|통상 사용')     echo '높음(HIGH)' ;;
    '스펙·기능 달성 차단|특수 조건·엣지') echo '중간(MEDIUM)' ;;
    '기능 저하|통상 사용')               echo '중간(MEDIUM)' ;;
    '기능 저하|특수 조건·엣지')           echo '낮음(LOW)' ;;
    '기술 품질 의견|통상 사용')           echo '낮음(LOW)' ;;
    '기술 품질 의견|특수 조건·엣지')       echo '정보(INFO)' ;;
    *) return 1 ;;
  esac
}

# 상태 산출용 서열. 값이 아니라 서열을 비교해야 목록의 최고 위험도를 고를 수 있다.
rank() {
  case "$1" in
    '높음(HIGH)')   echo 3 ;;
    '중간(MEDIUM)') echo 2 ;;
    '낮음(LOW)')    echo 1 ;;
    '정보(INFO)')   echo 0 ;;
    *) return 1 ;;
  esac
}

# 판정 산출용 상태 서열. 위험도 서열(rank)과 입력 집합이 달라 함수를 나눈다.
srank() {
  case "$1" in
    '보완 필요(FAIL)') echo 2 ;;
    '주의(WARN)')      echo 1 ;;
    '통과(PASS)')      echo 0 ;;
    *) return 1 ;;
  esac
}

impact=''
likelihood=''
status_mode=false
levels=()
verdict_mode=false
verdicts=()

while [ $# -gt 0 ]; do
  case "$1" in
    --impact)
      [ $# -ge 2 ] || { echo "error: --impact 에 값이 필요합니다" >&2; exit 2; }
      impact="$2"; shift 2 ;;
    --likelihood)
      [ $# -ge 2 ] || { echo "error: --likelihood 에 값이 필요합니다" >&2; exit 2; }
      likelihood="$2"; shift 2 ;;
    --status)
      status_mode=true; shift
      while [ $# -gt 0 ]; do levels+=("$1"); shift; done ;;
    --verdict)
      verdict_mode=true; shift
      while [ $# -gt 0 ]; do verdicts+=("$1"); shift; done ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "error: 알 수 없는 인자 — $1" >&2; exit 2 ;;
  esac
done

if [ "$verdict_mode" = true ]; then
  if [ -n "$impact" ] || [ -n "$likelihood" ] || [ "$status_mode" = true ]; then
    echo "error: --verdict 는 다른 모드와 함께 쓸 수 없습니다" >&2; exit 2
  fi
  # 판정의 입력은 비즈니스·테크 두 리뷰 상태로 고정이라 개수를 강제한다.
  if [ "${#verdicts[@]}" -ne 2 ]; then
    echo "error: --verdict 는 상태 2개가 필요합니다 — 받은 인자 ${#verdicts[@]}개" >&2; exit 2
  fi
  max=0
  for v in "${verdicts[@]}"; do
    r="$(srank "$(strip_emoji "$v")")" || { echo "error: 알 수 없는 상태 — $v" >&2; exit 2; }
    [ "$r" -gt "$max" ] && max="$r"
  done
  case "$max" in
    2) verdict='변경 요청(REQUEST CHANGES)' ;;
    1) verdict='조건부 승인(CONDITIONAL)' ;;
    *) verdict='승인(APPROVE)' ;;
  esac
  echo "$(emoji "$verdict") $verdict"
  exit 0
fi

if [ "$status_mode" = true ]; then
  if [ -n "$impact" ] || [ -n "$likelihood" ]; then
    echo "error: --status 는 --impact·--likelihood 와 함께 쓸 수 없습니다" >&2; exit 2
  fi
  # 발견 없음도 통과(PASS)다 — SKILL.md 상태 산출 표의 "낮음(LOW) 이하 또는 발견 없음".
  max=0
  for l in ${levels+"${levels[@]}"}; do
    r="$(rank "$(strip_emoji "$l")")" || { echo "error: 알 수 없는 위험도 — $l" >&2; exit 2; }
    [ "$r" -gt "$max" ] && max="$r"
  done
  case "$max" in
    3) status='보완 필요(FAIL)' ;;
    2) status='주의(WARN)' ;;
    *) status='통과(PASS)' ;;
  esac
  echo "$(emoji "$status") $status"
  exit 0
fi

if [ -z "$impact" ] || [ -z "$likelihood" ]; then
  echo "error: --impact 와 --likelihood 가 모두 필요합니다" >&2
  usage >&2
  exit 2
fi

if ! grade="$(matrix "$impact" "$likelihood")"; then
  echo "error: 허용되지 않은 축 값 — 영향[$impact] 발생확률[$likelihood]" >&2
  echo "  영향 축: 스펙·기능 달성 차단 / 기능 저하 / 기술 품질 의견" >&2
  echo "  발생확률 축: 통상 사용 / 특수 조건·엣지" >&2
  exit 2
fi

echo "$(emoji "$grade") $grade"
