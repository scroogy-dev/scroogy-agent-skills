#!/usr/bin/env bash
#
# classify-risk.sh — git-review 위험도·상태를 결정적으로 산출한다.
#
# SKILL.md "위험도 분류"는 리뷰어가 등급을 직접 고르지 않고 두 축의 조합으로
# 산출하도록 정한다. 이 스크립트가 그 매핑을 명령으로 강제해 리뷰마다 등급이
# 갈리지 않게 한다. 축 값·매트릭스·상태 표의 SSoT 는 SKILL.md 이며,
# 표가 바뀌면 이 스크립트와 tests/ 의 기대값을 함께 갱신한다.
#
# 사용법:
#   classify-risk.sh --impact <영향 축> --likelihood <발생확률 축>
#   classify-risk.sh --status [<위험도>...]
#
# 옵션:
#   --impact <값>      영향 축 — 스펙·기능 달성 차단 / 기능 저하 / 기술 품질 의견
#   --likelihood <값>  발생확률 축 — 통상 사용 / 특수 조건·엣지
#   --status [값...]   위험도 목록의 최고값으로 상태를 산출한다. 인자가 없으면 발견 없음으로 보고 통과(PASS).
#
# 종료 코드: 0 산출 성공 / 2 사용오류(허용되지 않은 값, 인자 누락, 모드 혼용)

set -o pipefail

usage() { sed -n '3,20p' "$0" | sed 's/^# \{0,1\}//'; }

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

impact=''
likelihood=''
status_mode=false
levels=()

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
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "error: 알 수 없는 인자 — $1" >&2; exit 2 ;;
  esac
done

if [ "$status_mode" = true ]; then
  if [ -n "$impact" ] || [ -n "$likelihood" ]; then
    echo "error: --status 는 --impact·--likelihood 와 함께 쓸 수 없습니다" >&2; exit 2
  fi
  # 발견 없음도 통과(PASS)다 — SKILL.md 상태 산출 표의 "낮음(LOW) 이하 또는 발견 없음".
  max=0
  for l in ${levels+"${levels[@]}"}; do
    r="$(rank "$l")" || { echo "error: 알 수 없는 위험도 — $l" >&2; exit 2; }
    [ "$r" -gt "$max" ] && max="$r"
  done
  case "$max" in
    3) echo '보완 필요(FAIL)' ;;
    2) echo '주의(WARN)' ;;
    *) echo '통과(PASS)' ;;
  esac
  exit 0
fi

if [ -z "$impact" ] || [ -z "$likelihood" ]; then
  echo "error: --impact 와 --likelihood 가 모두 필요합니다" >&2
  usage >&2
  exit 2
fi

if ! matrix "$impact" "$likelihood"; then
  echo "error: 허용되지 않은 축 값 — 영향[$impact] 발생확률[$likelihood]" >&2
  echo "  영향 축: 스펙·기능 달성 차단 / 기능 저하 / 기술 품질 의견" >&2
  echo "  발생확률 축: 통상 사용 / 특수 조건·엣지" >&2
  exit 2
fi
