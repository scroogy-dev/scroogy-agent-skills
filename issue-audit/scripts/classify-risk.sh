#!/usr/bin/env bash
#
# classify-risk.sh — issue-audit 위험도와 등급별 기본 처리를 결정적으로 산출한다.
#
# SKILL.md "위험도 분류"는 감사인이 등급을 직접 고르지 않고 두 축의 조합으로
# 산출하도록 정한다. 교차모델 감사에서 모델마다 등급이 갈리면 등급별 처리 기준이
# 일관성을 잃으므로, 그 매핑을 명령으로 강제한다. 축 값·매트릭스·등급별 처리 표의
# SSoT 는 SKILL.md 이며, 표가 바뀌면 이 스크립트와 tests/ 의 기대값을 함께 갱신한다.
#
# git-review 에 같은 매트릭스를 쓰는 사본이 있다. 스킬 독립성 원칙(단독 실행·단독 설치)상
# 헬퍼를 공유하지 않으므로, 한쪽 매트릭스를 고치면 다른 쪽도 함께 고친다.
#
# 사용법:
#   classify-risk.sh --impact <영향 축> --likelihood <발생확률 축>
#   classify-risk.sh --treatment <위험도>
#
# 옵션:
#   --impact <값>      영향 축 — 스펙·기능 달성 차단 / 기능 저하 / 기술 품질 의견
#   --likelihood <값>  발생확률 축 — 통상 사용 / 특수 조건·엣지
#   --treatment <값>   위험도의 등급별 기본 처리를 출력한다 (--response 승인 게이트의 기본 제시값).
#
# 종료 코드: 0 산출 성공 / 2 사용오류(허용되지 않은 값, 인자 누락, 모드 혼용)

set -o pipefail

usage() { sed -n '3,24p' "$0" | sed 's/^# \{0,1\}//'; }

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

# SKILL.md "등급별 기본 처리 기준" 표. 출력은 그 표의 기본 처리 셀 전문이다.
treatment() {
  case "$1" in
    '높음(HIGH)')   echo '보정 필수 → 재검증 대상' ;;
    '중간(MEDIUM)') echo '`--response` 승인 게이트에서 사용자 판단' ;;
    '낮음(LOW)')    echo '원장(`.ai/70_ledger/`) 이관 — 수용 사유·재검토 조건 기재. 사용자가 명시 승격하지 않는 한 보정 루프에 넣지 않는다' ;;
    '정보(INFO)')   echo '기록만 — 리포트에 남기고 원장 등재는 선택' ;;
    *) return 1 ;;
  esac
}

impact=''
likelihood=''
level=''
treatment_mode=false

while [ $# -gt 0 ]; do
  case "$1" in
    --impact)
      [ $# -ge 2 ] || { echo "error: --impact 에 값이 필요합니다" >&2; exit 2; }
      impact="$2"; shift 2 ;;
    --likelihood)
      [ $# -ge 2 ] || { echo "error: --likelihood 에 값이 필요합니다" >&2; exit 2; }
      likelihood="$2"; shift 2 ;;
    --treatment)
      [ $# -ge 2 ] || { echo "error: --treatment 에 값이 필요합니다" >&2; exit 2; }
      treatment_mode=true; level="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "error: 알 수 없는 인자 — $1" >&2; exit 2 ;;
  esac
done

if [ "$treatment_mode" = true ]; then
  if [ -n "$impact" ] || [ -n "$likelihood" ]; then
    echo "error: --treatment 는 --impact·--likelihood 와 함께 쓸 수 없습니다" >&2; exit 2
  fi
  if ! treatment "$level"; then
    echo "error: 알 수 없는 위험도 — $level" >&2
    echo "  허용값: 높음(HIGH) / 중간(MEDIUM) / 낮음(LOW) / 정보(INFO)" >&2
    exit 2
  fi
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
