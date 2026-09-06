#!/usr/bin/env bash
#
# classify-risk.sh — issue-audit 위험도·상태·판정과 등급별 기본 처리를 결정적으로 산출한다.
#
# SKILL.md "위험도 분류"·"상태 산출"·"판정 산출"은 감사인이 등급·상태·판정을 직접 고르지 않고
# 축·서열의 조합으로 산출하도록 정한다. 교차모델 감사에서 모델마다 값이 갈리면 등급별 처리
# 기준이 일관성을 잃으므로, 그 매핑을 명령으로 강제한다. 축 값·매트릭스·등급별 처리 표·
# 2단계 상태 표·판정 표·이모지 대응표의 SSoT 는 SKILL.md 이며, 표가 바뀌면 이 스크립트와
# tests/ 의 기대값을 함께 갱신한다.
#
# git-review 에 같은 매트릭스를 쓰는 사본이 있다. 스킬 독립성 원칙(단독 실행·단독 설치)상
# 헬퍼를 공유하지 않으므로, 한쪽 매트릭스를 고치면 다른 쪽도 함께 고친다. 등급의 이모지 색도
# 두 스킬이 같아야 한다. 같은 발견에 스킬마다 다른 색이 붙으면 신호가 갈린다.
#
# 출력은 대응표 이모지를 앞에 붙인 `<이모지> <값>` 형식이다. --treatment 만 예외로 등급별
# 처리 표의 처리 문구를 그대로 낸다. 값 입력 모드 4종(--treatment·--compliance·--status·
# --verdict)은 이모지 접두가 붙은 값과 붙지 않은 값을 모두 받아 헬퍼 출력을 그대로 되넘길 수 있다.
#
# 사용법:
#   classify-risk.sh --impact <영향 축> --likelihood <발생확률 축>
#   classify-risk.sh --treatment <위험도>
#   classify-risk.sh --compliance <1단계 판정>...
#   classify-risk.sh --status [<위험도>...]
#   classify-risk.sh --verdict <상태> <상태>
#
# 옵션:
#   --impact <값>        영향 축 — 스펙·기능 달성 차단 / 기능 저하 / 기술 품질 의견
#   --likelihood <값>    발생확률 축 — 통상 사용 / 특수 조건·엣지
#   --treatment <값>     위험도의 등급별 기본 처리를 출력한다 (--response 승인 게이트의 기본 제시값).
#   --compliance <값>... 1단계 항목 판정의 최고값으로 1단계 상태를 산출한다. 값이 하나면 그 항목의 라벨이다.
#   --status [값...]     위험도 목록의 최고값으로 2단계 상태를 산출한다. 인자가 없으면 발견 없음으로 보고 통과(PASS).
#   --verdict <값> <값>  1단계 상태와 2단계 상태의 최고값으로 판정을 산출한다. 순서는 무관하다.
#
# 종료 코드: 0 산출 성공 / 2 사용오류(허용되지 않은 값·접두, 인자 누락·개수 불일치, 모드 혼용)

set -o pipefail

usage() { sed -n '3,34p' "$0" | sed 's/^# \{0,1\}//'; }

# SKILL.md "판정 산출"의 이모지 대응표. 적합성 4·등급 4·상태 3·판정 3 을 표와 같은 순서로 옮긴다.
emoji() {
  case "$1" in
    '충족(PASS)')               echo '🟢' ;;
    '미충족(FAIL)')             echo '🔴' ;;
    '부분 충족(PARTIAL)')       echo '🟡' ;;
    '판정 불가(N/A)')           echo '⚪' ;;
    '높음(HIGH)')               echo '🔴' ;;
    '중간(MEDIUM)')             echo '🟡' ;;
    '낮음(LOW)')                echo '🟢' ;;
    '정보(INFO)')               echo '⚪' ;;
    '보완 필요(FAIL)')          echo '🔴' ;;
    '주의(WARN)')               echo '🟡' ;;
    '통과(PASS)')               echo '🟢' ;;
    '부적합(FAIL)')             echo '🔴' ;;
    '조건부 적합(CONDITIONAL)') echo '🟡' ;;
    '적합(PASS)')               echo '🟢' ;;
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

# 2단계 상태 산출용 위험도 서열. 값이 아니라 서열을 비교해야 목록의 최고 위험도를 고를 수 있다.
rank() {
  case "$1" in
    '높음(HIGH)')   echo 3 ;;
    '중간(MEDIUM)') echo 2 ;;
    '낮음(LOW)')    echo 1 ;;
    '정보(INFO)')   echo 0 ;;
    *) return 1 ;;
  esac
}

# 1단계 상태 산출용 판정 서열. 판정 불가(N/A) 를 최하위에 두면 별도 분기 없이
# "다른 값이 있으면 묻히고 전부 판정 불가일 때만 판정 불가"가 성립한다.
crank() {
  case "$1" in
    '미충족(FAIL)')       echo 3 ;;
    '부분 충족(PARTIAL)') echo 2 ;;
    '충족(PASS)')         echo 1 ;;
    '판정 불가(N/A)')     echo 0 ;;
    *) return 1 ;;
  esac
}

# 2단계 상태 서열. 판정의 입력 단계를 가르는 데도 쓴다 — crank 성공이면 1단계, srank 성공이면 2단계다.
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
# 축 옵션은 값이 아니라 "등장했는지"로 추적한다. 빈 문자열을 넘긴 호출과 옵션을 쓰지 않은
# 호출은 값만으로 구분되지 않아, 값 기준 검사는 `--impact '' --treatment …` 같은 혼용을 통과시킨다.
impact_set=false
likelihood_set=false
treatment_mode=false
level=''
compliance_mode=false
judgments=()
status_mode=false
levels=()
verdict_mode=false
verdicts=()

while [ $# -gt 0 ]; do
  case "$1" in
    --impact)
      [ $# -ge 2 ] || { echo "error: --impact 에 값이 필요합니다" >&2; exit 2; }
      impact="$2"; impact_set=true; shift 2 ;;
    --likelihood)
      [ $# -ge 2 ] || { echo "error: --likelihood 에 값이 필요합니다" >&2; exit 2; }
      likelihood="$2"; likelihood_set=true; shift 2 ;;
    --treatment)
      [ $# -ge 2 ] || { echo "error: --treatment 에 값이 필요합니다" >&2; exit 2; }
      treatment_mode=true; level="$2"; shift 2 ;;
    --compliance)
      compliance_mode=true; shift
      while [ $# -gt 0 ]; do judgments+=("$1"); shift; done ;;
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

# 값 모드는 축 옵션과도, 서로와도 함께 쓸 수 없다. 산출 echo 는 모두 검증 뒤에 두어
# 사용오류가 표준 출력에 값을 남기지 않게 한다 — 호출자가 그 값을 읽어 쓰기 때문이다.
value_modes=0
for m in "$treatment_mode" "$compliance_mode" "$status_mode" "$verdict_mode"; do
  [ "$m" = true ] && value_modes=$((value_modes + 1))
done

if [ "$value_modes" -gt 0 ]; then
  if [ "$impact_set" = true ] || [ "$likelihood_set" = true ]; then
    echo "error: 값 모드는 --impact·--likelihood 와 함께 쓸 수 없습니다" >&2; exit 2
  fi
  if [ "$value_modes" -gt 1 ]; then
    echo "error: --treatment·--compliance·--status·--verdict 는 하나만 쓸 수 있습니다" >&2; exit 2
  fi
fi

if [ "$treatment_mode" = true ]; then
  if ! out="$(treatment "$(strip_emoji "$level")")"; then
    echo "error: 알 수 없는 위험도 — $level" >&2
    echo "  허용값: 높음(HIGH) / 중간(MEDIUM) / 낮음(LOW) / 정보(INFO)" >&2
    exit 2
  fi
  echo "$out"
  exit 0
fi

if [ "$compliance_mode" = true ]; then
  # 요구사항·DoD 대조는 항상 있어 항목 0개인 감사가 성립하지 않으므로 인자 0개를 거부한다.
  if [ "${#judgments[@]}" -eq 0 ]; then
    echo "error: --compliance 는 1단계 판정이 1개 이상 필요합니다" >&2; exit 2
  fi
  max=-1
  compliance=''
  for j in "${judgments[@]}"; do
    v="$(strip_emoji "$j")"
    r="$(crank "$v")" || { echo "error: 알 수 없는 1단계 판정 — $j" >&2; exit 2; }
    if [ "$r" -gt "$max" ]; then max="$r"; compliance="$v"; fi
  done
  echo "$(emoji "$compliance") $compliance"
  exit 0
fi

if [ "$status_mode" = true ]; then
  # 발견 없음도 통과(PASS)다 — SKILL.md 2단계 상태 표의 "낮음(LOW) 이하 또는 발견 없음".
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

if [ "$verdict_mode" = true ]; then
  # 판정의 입력은 1단계 상태 1개와 2단계 상태 1개로 고정이라 개수와 단계를 함께 강제한다.
  if [ "${#verdicts[@]}" -ne 2 ]; then
    echo "error: --verdict 는 1단계 상태와 2단계 상태 2개가 필요합니다 — 받은 인자 ${#verdicts[@]}개" >&2; exit 2
  fi
  stages=''
  max=0
  # 색 앵커는 대응표에서 끌어온다. 리터럴로 적으면 매핑이 emoji() 밖으로 흩어져
  # 대응표와의 드리프트가 한 곳에서 잡히지 않는다.
  red="$(emoji '미충족(FAIL)')"
  yellow="$(emoji '부분 충족(PARTIAL)')"
  for v in "${verdicts[@]}"; do
    s="$(strip_emoji "$v")"
    if crank "$s" >/dev/null 2>&1; then
      stage=1
    elif srank "$s" >/dev/null 2>&1; then
      stage=2
    else
      echo "error: 알 수 없는 상태 — $v" >&2; exit 2
    fi
    case "$stages" in
      *"$stage"*) echo "error: --verdict 는 1단계 상태와 2단계 상태를 하나씩 받습니다 — 같은 단계 2개" >&2; exit 2 ;;
    esac
    stages="$stages$stage"
    # 판정 서열은 대응표의 색으로 정한다. 1단계 판정과 2단계 상태는 값 집합이 달라 서열 함수를 공유할 수 없다.
    case "$(emoji "$s")" in
      "$red")    r=2 ;;
      "$yellow") r=1 ;;
      *)         r=0 ;;
    esac
    [ "$r" -gt "$max" ] && max="$r"
  done
  case "$max" in
    2) verdict='부적합(FAIL)' ;;
    1) verdict='조건부 적합(CONDITIONAL)' ;;
    *) verdict='적합(PASS)' ;;
  esac
  echo "$(emoji "$verdict") $verdict"
  exit 0
fi

if [ "$impact_set" != true ] || [ "$likelihood_set" != true ]; then
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
