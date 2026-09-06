#!/usr/bin/env bash
#
# issue-audit 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# classify-risk.sh 의 기대값은 테스트에 적지 않고 SKILL.md 매트릭스·등급별 처리·2단계 상태·
# 판정·이모지 대응표에서 추출한다 — 표가 SSoT 이고 스크립트가 그것을 옮긴 사본이므로,
# 한쪽만 바뀌면 드리프트가 잡힌다. 이모지도 대응표에서만 합성하고 러너 본문에 리터럴로 적지 않는다.
# next-finding-number.sh 는 SKILL.md 가 서술한 함정(번호 건너뜀·재사용·발견 0건 회차)을
# 반례 fixture 로 재현해 격추 여부를 확인한다.
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
CLASSIFY="$HERE/../scripts/classify-risk.sh"
NEXTNUM="$HERE/../scripts/next-finding-number.sh"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

for s in "$CLASSIFY" "$NEXTNUM"; do
  [ -x "$s" ] || { echo "NOT OK - 헬퍼 실행 권한 없음 — $s"; exit 1; }
done

# cell <행> <열 번호> → 앞뒤 공백을 제거한 셀 값
cell() {
  printf '%s\n' "$1" | awk -F'|' -v i="$2" '{
    v = $(i + 1)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
    print v
  }'
}

# --- SKILL.md 이모지 대응표 추출 ----------------------------------------------
#
# "**이모지 대응표**" 볼드 행 다음의 연속된 표 행만 잡는다. 첫 행은 헤더, 둘째는 구분선,
# 나머지가 데이터 행(적합성 4·등급 4·상태 3·판정 3)이다. 기대 출력의 이모지는 이 표에서만
# 합성한다 — 표가 SSoT 이므로 한쪽만 바뀌면 여기서 드리프트가 잡힌다.

emoji_rows() {
  awk '
    /^\*\*이모지 대응표\*\*/ { f = 1; next }
    f && /^\|/ { print; n++; next }
    f && n > 0 { exit }
  ' "$SKILL"
}

erows="$(emoji_rows)"
edata_count="$(($(printf '%s\n' "$erows" | grep -c '^|') - 2))"
if [ "$edata_count" -ne 14 ]; then
  ng "대응표 추출: 데이터 14행 기대, 실제 ${edata_count}행"
  echo "-----"; echo "passed: $pass, failed: $fail"; exit 1
fi
ok "대응표 추출: 데이터 14행(적합성 4·등급 4·상태 3·판정 3)"

# emoji_of <값> → 대응표의 이모지. 값은 적합성·등급·상태·판정에 걸쳐 유일하므로 구분 열은 보지 않는다.
emoji_of() {
  printf '%s\n' "$erows" | awk -F'|' -v want="$1" '
    NR <= 2 { next }
    {
      v = $3; e = $4
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", e)
      if (v == want) { print e; found = 1; exit }
    }
    END { if (!found) exit 1 }
  '
}

# labeled <값> → 헬퍼가 내는 `<이모지> <값>` 기대 문자열
labeled() {
  local e
  e="$(emoji_of "$1")" || return 1
  printf '%s %s\n' "$e" "$1"
}

# --- 매트릭스 6조합 전수 대조 (SKILL.md 표에서 기대값 추출) --------------------

matrix_rows() {
  awk '
    /영향 . 발생확률 매트릭스/ { f = 1; next }
    f && /^\|/ { print; n++; next }
    f && n > 0 { exit }
  ' "$SKILL"
}

rows="$(matrix_rows)"
row_count="$(printf '%s\n' "$rows" | grep -c '^|')"
if [ "$row_count" -ne 5 ]; then
  ng "매트릭스 추출: 표 행 5개 기대, 실제 ${row_count}개"
  echo "-----"; echo "passed: $pass, failed: $fail"; exit 1
fi
ok "매트릭스 추출: 표 행 5개(헤더·구분선·데이터 3행)"

header="$(printf '%s\n' "$rows" | sed -n '1p')"
like1="$(cell "$header" 2)"
like2="$(cell "$header" 3)"

checked=0
for i in 3 4 5; do
  row="$(printf '%s\n' "$rows" | sed -n "${i}p")"
  impact="$(cell "$row" 1)"
  for col in 1 2; do
    case "$col" in
      1) like="$like1" ;;
      2) like="$like2" ;;
    esac
    grade="$(cell "$row" $((col + 1)))"
    if ! want="$(labeled "$grade")"; then
      ng "매트릭스: [$impact × $like] — 대응표에 [$grade] 없음"
      checked=$((checked + 1))
      continue
    fi
    got="$("$CLASSIFY" --impact "$impact" --likelihood "$like" 2>&1)"
    if [ "$got" = "$want" ]; then
      ok "매트릭스: [$impact × $like] → $want"
    else
      ng "매트릭스: [$impact × $like] 기대 [$want], 실제 [$got]"
    fi
    checked=$((checked + 1))
  done
done
[ "$checked" -eq 6 ] && ok "매트릭스: 6조합 전수 대조" || ng "매트릭스: ${checked}조합만 대조(기대 6)"

# git-review 사본과 매트릭스가 갈리지 않았는지 확인한다 — 두 스킬이 같은 표를 복사해 쓰므로
# 한쪽만 고치면 같은 발견에 다른 등급이 붙는다. 사본이 없는 설치본에서는 건너뛴다.
PEER="$HERE/../../git-review/scripts/classify-risk.sh"
if [ -x "$PEER" ]; then
  drift=0
  for i in 3 4 5; do
    row="$(printf '%s\n' "$rows" | sed -n "${i}p")"
    impact="$(cell "$row" 1)"
    for like in "$like1" "$like2"; do
      a="$("$CLASSIFY" --impact "$impact" --likelihood "$like" 2>&1)"
      b="$("$PEER" --impact "$impact" --likelihood "$like" 2>&1)"
      # 두 헬퍼 모두 `<이모지> <등급>` 을 내므로 전체 문자열을 비교한다 — 등급뿐 아니라
      # 등급의 색까지 함께 잡힌다. 같은 발견에 스킬마다 다른 색이 붙으면 신호가 갈린다.
      [ "$a" = "$b" ] || { drift=1; ng "사본 대조: [$impact × $like] issue-audit [$a] vs git-review [$b]"; }
    done
  done
  [ "$drift" -eq 0 ] && ok "사본 대조: git-review classify-risk.sh 와 매트릭스·이모지 일치"
else
  ok "사본 대조: git-review 사본 없음 — 건너뜀 (설치본 단독 실행)"
fi

# --- 등급별 기본 처리 (SKILL.md 표에서 기대값 추출) ---------------------------

treatment_rows() {
  awk '
    /^#### 등급별 기본 처리 기준/ { f = 1; next }
    f && /^\|/ { print; n++; next }
    f && n > 0 { exit }
  ' "$SKILL"
}

trows="$(treatment_rows)"
tcount="$(printf '%s\n' "$trows" | grep -c '^|')"
if [ "$tcount" -ne 6 ]; then
  ng "등급별 처리 추출: 표 행 6개 기대, 실제 ${tcount}개"
else
  ok "등급별 처리 추출: 표 행 6개(헤더·구분선·등급 4행)"
  for i in 3 4 5 6; do
    row="$(printf '%s\n' "$trows" | sed -n "${i}p")"
    level="$(cell "$row" 1)"
    want="$(cell "$row" 2)"
    got="$("$CLASSIFY" --treatment "$level" 2>&1)"
    if [ "$got" = "$want" ]; then
      ok "등급별 처리: $level → 표와 일치"
    else
      ng "등급별 처리: $level 기대 [$want], 실제 [$got]"
    fi
    # --treatment 는 이모지 접두가 붙은 등급도 받는다. 출력은 처리 문구 그대로라 이모지가 붙지 않는다.
    if inp="$(labeled "$level")"; then
      got="$("$CLASSIFY" --treatment "$inp" 2>&1)"
      if [ "$got" = "$want" ]; then
        ok "입력 호환: --treatment 접두 입력 [$level] → 처리 문구"
      else
        ng "입력 호환: --treatment 접두 입력 [$level] 기대 [$want], 실제 [$got]"
      fi
    else
      ng "입력 호환: --treatment 접두 입력 [$level] — 대응표에 없음"
    fi
  done
fi

# --- 1단계 상태 산출 -----------------------------------------------------------
#
# 1단계 상태는 별도 표 없이 항목 판정 값을 그대로 쓴다. 대응표 적합성 4행의 값이
# SKILL.md 판정 기준 표에 실재하는지 먼저 확인하고, 서열 매핑은 아래 케이스로 검사한다.

for j in '충족(PASS)' '미충족(FAIL)' '부분 충족(PARTIAL)' '판정 불가(N/A)'; do
  grep -qF "$j" "$SKILL" && ok "1단계 상태: 판정 값 '$j' 존재" || ng "1단계 상태: 판정 값 '$j' 없음"
done

# assert_compliance <기대 판정> <설명> <판정...>
assert_compliance() {
  local expect="$1" desc="$2"; shift 2
  local want got
  want="$(labeled "$expect")" || { ng "1단계 상태: $desc — 대응표에 [$expect] 없음"; return; }
  got="$("$CLASSIFY" --compliance "$@" 2>&1)"
  if [ "$got" = "$want" ]; then
    ok "1단계 상태: $desc → $want"
  else
    ng "1단계 상태: $desc 기대 [$want], 실제 [$got]"
  fi
}

assert_compliance '충족(PASS)'         '단일 충족'          '충족(PASS)'
assert_compliance '미충족(FAIL)'       '단일 미충족'        '미충족(FAIL)'
assert_compliance '부분 충족(PARTIAL)' '단일 부분 충족'      '부분 충족(PARTIAL)'
assert_compliance '판정 불가(N/A)'     '단일 판정 불가'      '판정 불가(N/A)'
# 판정 불가(N/A)는 서열 최하위라 다른 값이 하나라도 있으면 묻히고, 전부 판정 불가일 때만 나온다.
assert_compliance '충족(PASS)'         '판정 불가가 묻힘'    '충족(PASS)' '충족(PASS)' '판정 불가(N/A)'
assert_compliance '판정 불가(N/A)'     '전부 판정 불가'      '판정 불가(N/A)' '판정 불가(N/A)'
assert_compliance '부분 충족(PARTIAL)' '부분 충족 포함'      '충족(PASS)' '부분 충족(PARTIAL)' '충족(PASS)'
assert_compliance '미충족(FAIL)'       '미충족 포함'         '부분 충족(PARTIAL)' '미충족(FAIL)' '판정 불가(N/A)'
# 최고값 기준임을 확인한다 — 충족이 다수여도 미충족 1건이 상태를 정한다.
assert_compliance '미충족(FAIL)'       '충족 다수 + 미충족 1건' '충족(PASS)' '충족(PASS)' '충족(PASS)' '미충족(FAIL)'

# --- 2단계 상태 산출 -----------------------------------------------------------
#
# 상태 표의 세 번째 행은 "낮음(LOW) 이하 또는 발견 없음"이라 값이 아니라 서술이다.
# 표에서 기대값을 뽑는 대신 세 상태 문자열의 실재만 확인하고, 매핑은 아래 케이스로 검사한다.

for s in '보완 필요(FAIL)' '주의(WARN)' '통과(PASS)'; do
  grep -qF "$s" "$SKILL" && ok "2단계 상태: 상태 값 '$s' 존재" || ng "2단계 상태: 상태 값 '$s' 없음"
done

# assert_status <기대 상태> <설명> [위험도...]
assert_status() {
  local status="$1" desc="$2"; shift 2
  local want got
  want="$(labeled "$status")" || { ng "2단계 상태: $desc — 대응표에 [$status] 없음"; return; }
  got="$("$CLASSIFY" --status "$@" 2>&1)"
  if [ "$got" = "$want" ]; then
    ok "2단계 상태: $desc → $want"
  else
    ng "2단계 상태: $desc 기대 [$want], 실제 [$got]"
  fi
}

assert_status '통과(PASS)'      '발견 없음'
assert_status '통과(PASS)'      '정보만'            '정보(INFO)'
assert_status '통과(PASS)'      '낮음 이하'          '낮음(LOW)' '정보(INFO)'
assert_status '주의(WARN)'      '중간 포함'          '낮음(LOW)' '중간(MEDIUM)'
assert_status '보완 필요(FAIL)' '높음 포함'          '정보(INFO)' '높음(HIGH)' '중간(MEDIUM)'
assert_status '보완 필요(FAIL)' '높음 단독'          '높음(HIGH)'
# 최고값 기준임을 확인한다 — 낮은 등급이 다수여도 상태를 낮추지 않는다.
assert_status '보완 필요(FAIL)' '낮음 다수 + 높음 1건' '낮음(LOW)' '낮음(LOW)' '낮음(LOW)' '높음(HIGH)'

# --- 판정 산출 ----------------------------------------------------------------
#
# SKILL.md 판정 표에서 "최고 상태 → 판정" 매핑을 추출한다. 기대 판정을 러너에 적지 않는다.
# 최고 상태 셀에는 1단계·2단계 값이 ` · ` 로 나열되므로 셀을 나눠 정확 일치로 행을 찾는다
# — 부분 문자열로 찾으면 `충족(PASS)` 가 `부분 충족(PARTIAL)` 셀에도 걸린다.

verdict_rows() {
  awk '
    /^\| *최고 상태 *\| *판정 *\|/ { f = 1 }
    f && /^\|/ { print; n++; next }
    f && n > 0 { exit }
  ' "$SKILL"
}

vrows="$(verdict_rows)"
vrow_count="$(printf '%s\n' "$vrows" | grep -c '^|')"
if [ "$vrow_count" -ne 5 ]; then
  ng "판정: 표 행 5개 기대, 실제 ${vrow_count}개"
else
  ok "판정: 표 행 5개(헤더·구분선·데이터 3행)"
fi

# verdict_for <상태> → 그 상태가 나열된 행의 판정 값
verdict_for() {
  printf '%s\n' "$vrows" | awk -F'|' -v want="$1" '
    NR <= 2 { next }
    {
      s = $2; v = $3
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      if (index(" · " s " · ", " · " want " · ") > 0) { print v; found = 1; exit }
    }
    END { if (!found) exit 1 }
  '
}

# assert_verdict <최고 상태> <상태 A> <상태 B> <설명>
# 기대값은 표에서 합성하고, 인자 순서를 뒤집은 호출도 같은 기대값과 대조한다
# — 두 호출의 출력끼리만 비교하면 둘 다 오류로 비어도 통과한다.
assert_verdict() {
  local top="$1" a="$2" b="$3" desc="$4"
  local v want got1 got2
  v="$(verdict_for "$top")" || { ng "판정: $desc — 판정 표에 [$top] 행 없음"; return; }
  want="$(labeled "$v")"    || { ng "판정: $desc — 대응표에 [$v] 없음"; return; }
  got1="$("$CLASSIFY" --verdict "$a" "$b" 2>&1)"
  got2="$("$CLASSIFY" --verdict "$b" "$a" 2>&1)"
  if [ "$got1" = "$want" ] && [ "$got2" = "$want" ]; then
    ok "판정: $desc → $want (순서 무관)"
  else
    ng "판정: $desc 기대 [$want], 실제 [$got1] / 역순 [$got2]"
  fi
}

assert_verdict '충족(PASS)'         '충족(PASS)'         '통과(PASS)'         '충족 + 통과'
assert_verdict '판정 불가(N/A)'     '판정 불가(N/A)'     '통과(PASS)'         '판정 불가 + 통과'
assert_verdict '부분 충족(PARTIAL)' '부분 충족(PARTIAL)' '통과(PASS)'         '부분 충족 + 통과'
assert_verdict '주의(WARN)'         '주의(WARN)'         '충족(PASS)'         '주의 + 충족'
assert_verdict '주의(WARN)'         '판정 불가(N/A)'     '주의(WARN)'         '판정 불가 + 주의'
assert_verdict '미충족(FAIL)'       '미충족(FAIL)'       '통과(PASS)'         '미충족 + 통과'
assert_verdict '보완 필요(FAIL)'    '보완 필요(FAIL)'    '부분 충족(PARTIAL)' '보완 필요 + 부분 충족'

# --- 입력 호환 ----------------------------------------------------------------
#
# 헬퍼 출력(`<이모지> <값>`)을 그대로 되넘길 수 있어야 한다. 접두가 붙은 입력도 대응표에서
# 합성하고, 기대값은 접두 없는 호출의 출력이 아니라 표에서 합성한 값과 비교한다
# — 두 호출이 모두 오류로 비면 서로 같아져 통과하기 때문이다.

# assert_input_compat <설명> <기대 값> <인자...>
assert_input_compat() {
  local desc="$1" expect="$2"; shift 2
  local want got
  want="$(labeled "$expect")" || { ng "입력 호환: $desc — 대응표에 [$expect] 없음"; return; }
  got="$("$CLASSIFY" "$@" 2>&1)"
  if [ "$got" = "$want" ]; then
    ok "입력 호환: $desc → $want"
  else
    ng "입력 호환: $desc 기대 [$want], 실제 [$got]"
  fi
}

assert_input_compat '--compliance 접두 입력' '부분 충족(PARTIAL)' \
  --compliance "$(labeled '부분 충족(PARTIAL)')"
assert_input_compat '--compliance 접두·비접두 혼합' '미충족(FAIL)' \
  --compliance "$(labeled '미충족(FAIL)')" '충족(PASS)' "$(labeled '판정 불가(N/A)')"
assert_input_compat '--status 접두 입력' '주의(WARN)' \
  --status "$(labeled '중간(MEDIUM)')"
assert_input_compat '--status 접두·비접두 혼합' '보완 필요(FAIL)' \
  --status '낮음(LOW)' "$(labeled '높음(HIGH)')" '정보(INFO)'
assert_input_compat '--verdict 접두 입력' '조건부 적합(CONDITIONAL)' \
  --verdict "$(labeled '부분 충족(PARTIAL)')" "$(labeled '주의(WARN)')"
assert_input_compat '--verdict 접두·비접두 혼합' '적합(PASS)' \
  --verdict "$(labeled '판정 불가(N/A)')" '통과(PASS)'

# --- classify-risk 사용오류 ----------------------------------------------------

# 종료 코드와 함께 표준 출력이 비어 있는지도 본다 — 사용오류인데 산출값이 나오면
# 호출자가 그 값을 읽어 쓰므로, 종료 코드만 보는 검사로는 그 경로를 잡지 못한다.
assert_usage_error() {
  local desc="$1" script="$2"; shift 2
  local out rc
  out="$("$script" "$@" 2>/dev/null)"; rc=$?
  if [ "$rc" -ne 2 ]; then
    ng "사용오류: $desc — exit 2 기대, 실제 $rc"
  elif [ -n "$out" ]; then
    ng "사용오류: $desc — 표준 출력에 산출값이 남음 [$out]"
  else
    ok "사용오류: $desc (exit 2)"
  fi
}

assert_usage_error '알 수 없는 영향 축'     "$CLASSIFY" --impact '심각' --likelihood '통상 사용'
assert_usage_error '알 수 없는 발생확률 축' "$CLASSIFY" --impact '기능 저하' --likelihood '가끔'
assert_usage_error '축 인자 누락'           "$CLASSIFY" --impact '기능 저하'
assert_usage_error '발생확률 축 단독'       "$CLASSIFY" --likelihood '통상 사용'
assert_usage_error '인자 없음'              "$CLASSIFY"
assert_usage_error '알 수 없는 옵션'        "$CLASSIFY" --grade '높음(HIGH)'
assert_usage_error '알 수 없는 위험도'      "$CLASSIFY" --treatment '치명적'

assert_usage_error '--compliance 인자 0개'      "$CLASSIFY" --compliance
assert_usage_error '--compliance 알 수 없는 판정' "$CLASSIFY" --compliance '통과(PASS)'
assert_usage_error '--compliance 등급 값 혼입'   "$CLASSIFY" --compliance '충족(PASS)' '높음(HIGH)'
assert_usage_error '--status 알 수 없는 위험도'  "$CLASSIFY" --status '치명적'
assert_usage_error '--status 판정 값 혼입'       "$CLASSIFY" --status '충족(PASS)'
assert_usage_error '--verdict 인자 0개'          "$CLASSIFY" --verdict
assert_usage_error '--verdict 인자 1개'          "$CLASSIFY" --verdict '충족(PASS)'
assert_usage_error '--verdict 인자 3개'          "$CLASSIFY" --verdict '충족(PASS)' '통과(PASS)' '통과(PASS)'
assert_usage_error '--verdict 알 수 없는 상태'   "$CLASSIFY" --verdict '적합' '통과(PASS)'
# 판정의 입력은 1단계 상태 1개와 2단계 상태 1개로 고정이라 같은 단계 2개는 호출 실수다.
assert_usage_error '--verdict 1단계 상태 2개'    "$CLASSIFY" --verdict '충족(PASS)' '미충족(FAIL)'
assert_usage_error '--verdict 2단계 상태 2개'    "$CLASSIFY" --verdict '통과(PASS)' '주의(WARN)'

# 대응표 밖 접두는 걷어내지 않아 뒤의 값 검증에서 미지 값이 된다.
assert_usage_error '--treatment 알 수 없는 이모지 접두'  "$CLASSIFY" --treatment '🔵 중간(MEDIUM)'
assert_usage_error '--compliance 알 수 없는 이모지 접두' "$CLASSIFY" --compliance '🔵 충족(PASS)'
assert_usage_error '--status 알 수 없는 이모지 접두'     "$CLASSIFY" --status '🔵 높음(HIGH)'
assert_usage_error '--verdict 알 수 없는 이모지 접두'    "$CLASSIFY" --verdict '🔵 충족(PASS)' '통과(PASS)'

# 축 옵션의 존재 여부를 값으로 판정하면 빈 문자열이 "옵션 없음"과 같아져 모드 혼용 검사를
# 통과한다. 축 옵션 2종 × 값 형태(빈 값·일반 값) × 값 모드 4종 × 배치(전치·후치)를 전수로 세운다.
# 값 모드를 뒤에 두면 축 옵션이 위치 인자로 흡수되어 개수 위반·미지 값으로 걸린다.
mix_modes=( '--treatment|높음(HIGH)' '--compliance|충족(PASS)' '--status|높음(HIGH)' '--verdict|충족(PASS)|통과(PASS)' )
for pair in '--impact|기능 저하' '--likelihood|통상 사용'; do
  axis="${pair%%|*}"
  for form in '빈 값' '일반 값'; do
    if [ "$form" = '빈 값' ]; then aval=''; else aval="${pair#*|}"; fi
    for m in "${mix_modes[@]}"; do
      IFS='|' read -r -a call <<< "$m"
      assert_usage_error "${call[0]} 혼용: $axis $form 전치" "$CLASSIFY" "$axis" "$aval" "${call[@]}"
      assert_usage_error "${call[0]} 혼용: $axis $form 후치" "$CLASSIFY" "${call[@]}" "$axis" "$aval"
    done
  done
done

# 값 모드끼리도 함께 쓸 수 없다. --treatment 는 값 1개만 받으므로 뒤에 다른 값 모드가 오면
# 플래그가 둘 다 서고, 흡수형 모드 뒤에 --treatment 가 오면 위치 인자로 흡수되어 미지 값이 된다.
for m in "${mix_modes[@]}"; do
  IFS='|' read -r -a call <<< "$m"
  [ "${call[0]}" = '--treatment' ] && continue
  assert_usage_error "값 모드 혼용: --treatment 뒤 ${call[0]}" "$CLASSIFY" --treatment '높음(HIGH)' "${call[@]}"
  assert_usage_error "값 모드 혼용: ${call[0]} 뒤 --treatment" "$CLASSIFY" "${call[@]}" --treatment '높음(HIGH)'
done

# 축 모드 자체도 빈 값을 축 값으로 받지 않는다.
assert_usage_error '영향 축 빈 값'      "$CLASSIFY" --impact '' --likelihood '통상 사용'
assert_usage_error '발생확률 축 빈 값'  "$CLASSIFY" --impact '기능 저하' --likelihood ''
assert_usage_error '영향 축 빈 값 단독' "$CLASSIFY" --impact ''

# --- next-finding-number ------------------------------------------------------

sandbox="$(mktemp -d)"
trap 'rm -rf "$sandbox"' EXIT

cat > "$sandbox/r1.md" <<'EOF'
# Issue #99 감사 리포트

> 감사 회차: 1차 (이전 리포트: 없음)

| # | 발견 | 등급 |
|---|------|------|
| F-1 | 첫 발견 | 높음(HIGH) |
| F-2 | 둘째 발견 | 낮음(LOW) |
| F-3 | 셋째 발견 | 정보(INFO) |
EOF

# 발견 0건 회차 — 번호가 하나도 없다. 앞 회차의 최대값이 유지되어야 한다.
cat > "$sandbox/r2-empty.md" <<'EOF'
# Issue #99 감사 리포트

> 감사 회차: 2차 (이전 리포트: `issue-99-audit-report-1.md`)

발견 사항 없음.
EOF

# 구버전 이력 — 회차마다 번호를 재사용해 기준선 줄로 마지막 사용·예약 번호를 명시한 회차.
cat > "$sandbox/r3-baseline.md" <<'EOF'
# Issue #99 감사 리포트

> 감사 회차: 3차 (이전 리포트: `issue-99-audit-report-2.md`)
> 번호 기준선: F-12 (구버전 회차들이 F-1~F-12 를 재사용해 마지막 사용 번호를 명시)

| # | 발견 | 등급 |
|---|------|------|
| F-13 | 새 발견 | 중간(MEDIUM) |
EOF

# 원장 번호(K-)가 섞여도 발견 번호로 세지 않는다.
cat > "$sandbox/r4-ledger.md" <<'EOF'
# Issue #99 감사 리포트

### 기등재 참조 항목

- 기등재 K-0042 참조 — 위험도 집계 제외
- 기등재 K-99 승격(이슈 #77) 참조
EOF

assert_next() {
  local want="$1" desc="$2"; shift 2
  local got
  got="$("$NEXTNUM" "$@" 2>&1)"
  if [ "$got" = "$want" ]; then ok "$desc → $want"; else ng "$desc 기대 [$want], 실제 [$got]"; fi
}

assert_next 1  '번호 계승: 인자 없음(초회 감사)'
assert_next 4  '번호 계승: F-1~F-3 다음'                    "$sandbox/r1.md"
assert_next 4  '번호 계승: 발견 0건 회차가 끼어도 유지'      "$sandbox/r1.md" "$sandbox/r2-empty.md"
assert_next 1  '번호 계승: 발견 0건 회차 단독'               "$sandbox/r2-empty.md"
assert_next 14 '번호 계승: 기준선 F-12 + 본문 F-13'          "$sandbox/r3-baseline.md"
assert_next 14 '번호 계승: 전 회차 누적(최대값 기준)'         "$sandbox/r1.md" "$sandbox/r2-empty.md" "$sandbox/r3-baseline.md"
assert_next 1  '번호 계승: 원장 K- 번호는 세지 않음'          "$sandbox/r4-ledger.md"
assert_next 4  '번호 계승: 원장 번호가 섞여도 F- 만 집계'     "$sandbox/r1.md" "$sandbox/r4-ledger.md"

# 파일 순서가 결과를 바꾸지 않는다 — 최대값 기준이라 인자 순서와 무관해야 한다.
a="$("$NEXTNUM" "$sandbox/r1.md" "$sandbox/r3-baseline.md")"
b="$("$NEXTNUM" "$sandbox/r3-baseline.md" "$sandbox/r1.md")"
[ "$a" = "$b" ] && ok "번호 계승: 인자 순서 무관 ($a)" || ng "번호 계승: 인자 순서로 결과가 갈림 [$a] vs [$b]"

# 템플릿 자리표시자를 실제 번호로 오인하지 않는다.
assert_next 1 '번호 계승: 템플릿 자리표시자(F-n) 무시' "$HERE/../templates/issue-audit-report-template.md"

# 경로 오타를 초회 감사로 오인하지 않는다 — 조용히 1을 내면 쌓인 번호를 통째로 재사용한다.
assert_usage_error '읽을 수 없는 경로' "$NEXTNUM" "$sandbox/does-not-exist.md"
assert_usage_error '알 수 없는 옵션'   "$NEXTNUM" --all

# --- 리포트 템플릿 구조 계약 스모크 (issue #94 audit F-1·F-2) ------------------
#
# 3단계 명칭 개편(범위 검증 → 경계 검증)과 제외 목록 대조 필드는 issue-0094 spec 의
# 일회성 [D] 명령으로만 검증되었다 — 이후 템플릿 개정이 구조를 깨도 정규 러너가
# 감지하지 못하므로 여기에 편입한다.
# F-2 보강: 존재 검사만으로는 헤더·필드 중복과 옛 비포함(Out) 필드의 공존이
# 통과한다 — 정확한 개수를 판정하고 옛 표기 재유입을 명칭과 함께 거부한다.

REPORT_TPL="$HERE/../templates/issue-audit-report-template.md"

# check_report_structure <파일> → 위반 항목을 한 줄씩 출력 (0건이면 통과)
# 소속은 직전 헤더(`##`·`###` 모두)로 추적한다 — 필드가 다른 섹션 아래로 옮겨가면 위반이다.
check_report_structure() {
  awk '
    /^##/                                            { sec = $0 }
    /^### 경계 검증$/                                { h++ }
    /^- \*\*스펙 요구사항의 제외 목록 침범 여부\*\*:/ { f1++; if (sec != "### 경계 검증") mis++ }
    /^- \*\*스펙에 없는 추가 구현 여부\*\*:/          { f2++; if (sec != "### 경계 검증") mis++ }
    /범위 검증/                                      { old1++ }
    /비포함 ?\(Out\)/                                { old2++ }
    /^## 종합 의견$/                                 { oh++; if (!ohl) ohl = NR }
    /^<판정>$/                                       { vv++; if (!vl)  vl  = NR }
    /^<details>$/                                    { if (!dl) dl = NR }
    /^<summary>종합 의견 펼치기<\/summary>$/          { sm++; if (!sml) sml = NR }
    /^## 요약$/                                      { if (!sul) sul = NR }
    /^- 1단계 적합성: <이모지> <상태> · /             { s1++ }
    /^- 2단계 위험도: <이모지> <상태> · /             { s2++ }
    END {
      if (h != 1)  print "경계 검증 헤더 " h + 0 "개 (기대 1개)"
      if (f1 != 1) print "제외 목록 침범 여부 필드 " f1 + 0 "개 (기대 1개)"
      if (f2 != 1) print "무단 확장 확인 필드 " f2 + 0 "개 (기대 1개)"
      if (mis)     print "경계 검증 필드가 섹션 밖: " mis "개"
      if (old1)    print "옛 명칭(범위 검증) 잔존"
      if (old2)    print "옛 표기(비포함(Out)) 잔존"
      if (oh != 1) print "종합 의견 헤더 " oh + 0 "개 (기대 1개)"
      if (vv != 1) print "판정 자리표시자 " vv + 0 "개 (기대 1개)"
      if (sm != 1) print "종합 의견 접기 " sm + 0 "개 (기대 1개)"
      if (s1 != 1) print "요약 1단계 줄 " s1 + 0 "개 (기대 1개)"
      if (s2 != 1) print "요약 2단계 줄 " s2 + 0 "개 (기대 1개)"
      if (!(ohl && vl && dl && sml && sul && ohl < vl && vl < dl && dl < sml && sml < sul))
        print "종합 의견 → 판정 → 접기 시작 → 접기 제목 → 요약 순서 아님"
    }
  ' "$1"
}

# assert_report_structure <파일> <기대: pass|fail> <설명>
assert_report_structure() {
  local out
  out="$(check_report_structure "$1")"
  case "$2" in
    pass) if [ -z "$out" ]; then ok "$3 (위반 0건)"; else ng "$3 (기대 0건, 실제 [$out])"; fi ;;
    fail) if [ -n "$out" ]; then ok "$3 (위반 검출)"; else ng "$3 (기대 >0건, 실제 0건)"; fi ;;
  esac
}

# 반례 fixture 는 실제 템플릿의 awk 변형으로 만든다 (구조 드리프트를 그대로 재현).
awk '{gsub(/경계 검증/, "범위 검증"); print}' "$REPORT_TPL" > "$sandbox/t-old-name.md"
awk '!/^- \*\*스펙 요구사항의 제외 목록 침범 여부\*\*:/' "$REPORT_TPL" > "$sandbox/t-no-excl.md"
awk '!/^- \*\*스펙에 없는 추가 구현 여부\*\*:/' "$REPORT_TPL" > "$sandbox/t-no-extra.md"
# F-2 반례(2차 audit 재현·이웃 변형): 옛 비포함(Out) 필드를 새 필드와 공존시킴 / 경계 헤더 중복.
awk '{print} /^- \*\*스펙 요구사항의 제외 목록 침범 여부\*\*:/{print "- **스펙 비포함(Out) 침범 여부**:"}' \
  "$REPORT_TPL" > "$sandbox/t-old-coexist.md"
awk '{print} /^### 경계 검증$/{print ""; print "### 경계 검증"}' "$REPORT_TPL" > "$sandbox/t-dup-header.md"
# PR #95 리뷰 반례: 필드를 경계 검증 밖으로 이동 — 전체 개수만 세면 통과한다.
awk '!/^- \*\*스펙 요구사항의 제외 목록 침범 여부\*\*:/{print}
     END{print ""; print "- **스펙 요구사항의 제외 목록 침범 여부**:"}' \
  "$REPORT_TPL" > "$sandbox/t-field-outside.md"

# 판정 한 줄·종합 의견 접기 반례(issue #98): 판정이 접기 안으로 들어가거나 사라지면
# 리포트를 열었을 때 적합 여부가 첫 줄에서 읽히지 않는다.
awk '!/^<판정>$/' "$REPORT_TPL" > "$sandbox/t-no-verdict.md"
awk '!/^<summary>종합 의견 펼치기<\/summary>$/' "$REPORT_TPL" > "$sandbox/t-no-fold.md"
awk '!/^<판정>$/{print} /^<summary>종합 의견 펼치기<\/summary>$/{print ""; print "<판정>"}' \
  "$REPORT_TPL" > "$sandbox/t-verdict-inside.md"
awk '{print} /^<판정>$/{print "<판정>"}' "$REPORT_TPL" > "$sandbox/t-dup-verdict.md"
awk '{gsub(/<이모지> <상태> · /, ""); print}' "$REPORT_TPL" > "$sandbox/t-old-summary.md"

assert_report_structure "$REPORT_TPL"               pass "리포트 구조: 실제 템플릿 통과"
assert_report_structure "$sandbox/t-old-name.md"    fail "리포트 구조: 옛 명칭(범위 검증) 회귀 격추"
assert_report_structure "$sandbox/t-no-excl.md"     fail "리포트 구조: 제외 목록 대조 필드 소실 격추"
assert_report_structure "$sandbox/t-no-extra.md"    fail "리포트 구조: 무단 확장 확인 필드 소실 격추"
assert_report_structure "$sandbox/t-old-coexist.md" fail "리포트 구조: 옛 비포함(Out) 필드 공존(2차 audit F-2 반례) 격추"
assert_report_structure "$sandbox/t-dup-header.md"  fail "리포트 구조: 경계 검증 헤더 중복 격추"
assert_report_structure "$sandbox/t-field-outside.md" fail "리포트 구조: 침범 여부 필드 섹션 밖 이동(PR #95 리뷰 반례) 격추"
assert_report_structure "$sandbox/t-no-verdict.md"     fail "리포트 구조: 판정 자리표시자 삭제 격추"
assert_report_structure "$sandbox/t-no-fold.md"        fail "리포트 구조: 종합 의견 접기 삭제로 판정 배치 붕괴 격추"
assert_report_structure "$sandbox/t-verdict-inside.md" fail "리포트 구조: 판정 행 접기 안 이동 격추"
assert_report_structure "$sandbox/t-dup-verdict.md"    fail "리포트 구조: 판정 자리표시자 중복 격추"
assert_report_structure "$sandbox/t-old-summary.md"    fail "리포트 구조: 요약 줄 옛 형식 격추"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
