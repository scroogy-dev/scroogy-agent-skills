#!/usr/bin/env bash
#
# issue-audit 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# classify-risk.sh 의 기대값은 테스트에 적지 않고 SKILL.md 매트릭스·등급별 처리 표에서
# 추출한다 — 표가 SSoT 이고 스크립트가 그것을 옮긴 사본이므로, 한쪽만 바뀌면 드리프트가 잡힌다.
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
    want="$(cell "$row" $((col + 1)))"
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
      # git-review 헬퍼는 등급 앞에 이모지를 붙여 낸다(issue-audit 헬퍼는 붙이지 않는다).
      # 등급 문자열에는 공백이 없으므로 공백이 있으면 첫 공백까지 떼어 매트릭스 값만 비교한다.
      case "$b" in *' '*) b="${b#* }" ;; esac
      [ "$a" = "$b" ] || { drift=1; ng "사본 대조: [$impact × $like] issue-audit [$a] vs git-review [$b]"; }
    done
  done
  [ "$drift" -eq 0 ] && ok "사본 대조: git-review classify-risk.sh 와 매트릭스 일치"
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
  done
fi

# --- classify-risk 사용오류 ----------------------------------------------------

assert_usage_error() {
  local desc="$1" script="$2"; shift 2
  "$script" "$@" >/dev/null 2>&1
  case "$?" in
    2) ok "사용오류: $desc (exit 2)" ;;
    *) ng "사용오류: $desc — exit 2 기대, 실제 $?" ;;
  esac
}

assert_usage_error '알 수 없는 영향 축'  "$CLASSIFY" --impact '심각' --likelihood '통상 사용'
assert_usage_error '축 인자 누락'        "$CLASSIFY" --impact '기능 저하'
assert_usage_error '인자 없음'           "$CLASSIFY"
assert_usage_error '모드 혼용'           "$CLASSIFY" --treatment '높음(HIGH)' --impact '기능 저하'
assert_usage_error '알 수 없는 위험도'    "$CLASSIFY" --treatment '치명적'

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
    END {
      if (h != 1)  print "경계 검증 헤더 " h + 0 "개 (기대 1개)"
      if (f1 != 1) print "제외 목록 침범 여부 필드 " f1 + 0 "개 (기대 1개)"
      if (f2 != 1) print "무단 확장 확인 필드 " f2 + 0 "개 (기대 1개)"
      if (mis)     print "경계 검증 필드가 섹션 밖: " mis "개"
      if (old1)    print "옛 명칭(범위 검증) 잔존"
      if (old2)    print "옛 표기(비포함(Out)) 잔존"
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

assert_report_structure "$REPORT_TPL"               pass "리포트 구조: 실제 템플릿 통과"
assert_report_structure "$sandbox/t-old-name.md"    fail "리포트 구조: 옛 명칭(범위 검증) 회귀 격추"
assert_report_structure "$sandbox/t-no-excl.md"     fail "리포트 구조: 제외 목록 대조 필드 소실 격추"
assert_report_structure "$sandbox/t-no-extra.md"    fail "리포트 구조: 무단 확장 확인 필드 소실 격추"
assert_report_structure "$sandbox/t-old-coexist.md" fail "리포트 구조: 옛 비포함(Out) 필드 공존(2차 audit F-2 반례) 격추"
assert_report_structure "$sandbox/t-dup-header.md"  fail "리포트 구조: 경계 검증 헤더 중복 격추"
assert_report_structure "$sandbox/t-field-outside.md" fail "리포트 구조: 침범 여부 필드 섹션 밖 이동(PR #95 리뷰 반례) 격추"

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
