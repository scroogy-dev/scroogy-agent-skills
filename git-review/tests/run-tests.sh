#!/usr/bin/env bash
#
# git-review 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# classify-risk.sh 의 기대값을 테스트에 적지 않고 SKILL.md 매트릭스 표에서 추출한다
# — 표가 SSoT 이고 스크립트가 그것을 옮긴 사본이므로, 한쪽만 바뀌면 여기서 드리프트가 잡힌다
# (issue-work 러너가 템플릿 본문에서 게이트 명령을 추출하는 방식과 같다).
#
# 대상 대조·브랜치 수집 케이스(issue #142)는 git 으로 임시 저장소를 만들어 헬퍼를 실행한다.
# 대상 수집 조항·코드 레벨 조항·발견 처리 조항·결과 템플릿 케이스(issue #142)는 git-qa 러너와 같은 방식으로, 실제 SKILL.md·결과 템플릿은 통과하고
# 앵커를 지우거나 절 밖으로 옮긴 사본은 격추되는지 본다. 조항의 뜻은 판정하지 않는다 (이슈 spec 의 [QD] 몫).
# 모의 실행 fixture 케이스(issue #142)는 fixtures/code-level/ 의 입력·기대 쌍이 빠짐없이 있는지만 본다.
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
CLASSIFY="$HERE/../scripts/classify-risk.sh"
RESOLVE="$HERE/../scripts/resolve-target.sh"
COLLECT="$HERE/../scripts/collect-branch-changes.sh"

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

[ -x "$CLASSIFY" ] || { echo "NOT OK - 헬퍼 실행 권한 없음 — $CLASSIFY"; exit 1; }
[ -x "$RESOLVE" ]  || { echo "NOT OK - 헬퍼 실행 권한 없음 — $RESOLVE"; exit 1; }
[ -x "$COLLECT" ]  || { echo "NOT OK - 헬퍼 실행 권한 없음 — $COLLECT"; exit 1; }

# --- SKILL.md 매트릭스 표 추출 ------------------------------------------------
#
# "**영향 × 발생확률 매트릭스**" 다음의 연속된 표 행만 잡는다. 첫 행은 헤더(확률 축 이름),
# 둘째는 구분선, 나머지가 데이터 행이다.

matrix_rows() {
  awk '
    /영향 . 발생확률 매트릭스/ { f = 1; next }
    f && /^\|/ { print; n++; next }
    f && n > 0 { exit }
  ' "$SKILL"
}

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
# 나머지가 데이터 행(등급 4·상태 3·판정 3)이다. 기대 출력의 이모지는 이 표에서만 합성하고
# 러너 본문에 리터럴로 적지 않는다 — 표가 SSoT 이므로 한쪽만 바뀌면 여기서 드리프트가 잡힌다.

emoji_rows() {
  awk '
    /^\*\*이모지 대응표\*\*/ { f = 1; next }
    f && /^\|/ { print; n++; next }
    f && n > 0 { exit }
  ' "$SKILL"
}

erows="$(emoji_rows)"
edata_count="$(($(printf '%s\n' "$erows" | grep -c '^|') - 2))"
if [ "$edata_count" -ne 10 ]; then
  ng "대응표 추출: 데이터 10행 기대, 실제 ${edata_count}행"
  echo "-----"; echo "passed: $pass, failed: $fail"; exit 1
fi
ok "대응표 추출: 데이터 10행(등급 4·상태 3·판정 3)"

# emoji_of <값> → 대응표의 이모지. 값은 등급·상태·판정에 걸쳐 유일하므로 구분 열은 보지 않는다.
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
case "$like1$like2" in
  '') ng "매트릭스 추출: 발생확률 축 헤더가 비어 있음" ;;
  *)  ok "매트릭스 추출: 발생확률 축 [$like1] [$like2]" ;;
esac

# --- 매트릭스 6조합 전수 대조 -------------------------------------------------

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

# --- 상태 산출 ----------------------------------------------------------------
#
# 상태 표의 세 번째 행은 "낮음(LOW) 이하 또는 발견 없음"이라 값이 아니라 서술이다.
# 표에서 기대값을 뽑는 대신 세 상태 문자열의 실재만 확인하고, 매핑은 아래 케이스로 검사한다.

for s in '보완 필요(FAIL)' '주의(WARN)' '통과(PASS)'; do
  grep -qF "$s" "$SKILL" && ok "상태 표: '$s' 존재" || ng "상태 표: '$s' 없음"
done

# assert_status <기대 상태> <설명> [위험도...]
assert_status() {
  local status="$1" desc="$2"; shift 2
  local want got
  want="$(labeled "$status")" || { ng "$desc — 대응표에 [$status] 없음"; return; }
  got="$("$CLASSIFY" --status "$@" 2>&1)"
  if [ "$got" = "$want" ]; then ok "$desc → $want"; else ng "$desc 기대 [$want], 실제 [$got]"; fi
}

assert_status '통과(PASS)'     '상태: 발견 없음'
assert_status '통과(PASS)'     '상태: 정보만'            '정보(INFO)'
assert_status '통과(PASS)'     '상태: 낮음 이하'          '낮음(LOW)' '정보(INFO)'
assert_status '주의(WARN)'     '상태: 중간 포함'          '낮음(LOW)' '중간(MEDIUM)'
assert_status '보완 필요(FAIL)' '상태: 높음 포함'          '정보(INFO)' '높음(HIGH)' '중간(MEDIUM)'
assert_status '보완 필요(FAIL)' '상태: 높음 단독'          '높음(HIGH)'

# 최고값 기준임을 확인한다 — 낮은 등급이 다수여도 상태를 낮추지 않는다.
assert_status '보완 필요(FAIL)' '상태: 낮음 다수 + 높음 1건' '낮음(LOW)' '낮음(LOW)' '낮음(LOW)' '높음(HIGH)'

# --- 판정 산출 ----------------------------------------------------------------
#
# SKILL.md 판정 표에서 "최고 상태 → 판정" 매핑을 추출한다. 기대 판정을 러너에 적지 않는다.

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
  ng "판정 표 추출: 표 행 5개 기대, 실제 ${vrow_count}개"
else
  ok "판정 표 추출: 표 행 5개(헤더·구분선·데이터 3행)"
fi

# verdict_for <최고 상태> → 판정 표의 판정 값
verdict_for() {
  printf '%s\n' "$vrows" | awk -F'|' -v want="$1" '
    NR <= 2 { next }
    {
      s = $2; v = $3
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      if (s == want) { print v; found = 1; exit }
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

assert_verdict '통과(PASS)'      '통과(PASS)'      '통과(PASS)'      '통과 + 통과'
assert_verdict '주의(WARN)'      '통과(PASS)'      '주의(WARN)'      '통과 + 주의'
assert_verdict '보완 필요(FAIL)' '보완 필요(FAIL)' '통과(PASS)'      '보완 필요 + 통과'
assert_verdict '보완 필요(FAIL)' '주의(WARN)'      '보완 필요(FAIL)' '주의 + 보완 필요'

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

assert_input_compat '--status 접두 입력' '주의(WARN)' \
  --status "$(labeled '중간(MEDIUM)')"
assert_input_compat '--status 접두·비접두 혼합' '보완 필요(FAIL)' \
  --status '낮음(LOW)' "$(labeled '높음(HIGH)')" '정보(INFO)'
assert_input_compat '--verdict 접두 입력' '조건부 승인(CONDITIONAL)' \
  --verdict "$(labeled '통과(PASS)')" "$(labeled '주의(WARN)')"
assert_input_compat '--verdict 접두·비접두 혼합' '변경 요청(REQUEST CHANGES)' \
  --verdict '통과(PASS)' "$(labeled '보완 필요(FAIL)')"

# --- 사용오류 ------------------------------------------------------------------

# assert_usage_error <설명> <인자...>
# 종료 코드와 함께 표준 출력이 비어 있는지도 본다 — 사용오류인데 산출값이 나오면
# 호출자가 그 값을 읽어 쓰므로, 종료 코드만 보는 검사로는 그 경로를 잡지 못한다.
assert_usage_error() {
  local desc="$1"; shift
  local out rc
  out="$("$CLASSIFY" "$@" 2>/dev/null)"; rc=$?
  if [ "$rc" -ne 2 ]; then
    ng "사용오류: $desc — exit 2 기대, 실제 $rc"
  elif [ -n "$out" ]; then
    ng "사용오류: $desc — 표준 출력에 산출값이 남음 [$out]"
  else
    ok "사용오류: $desc (exit 2)"
  fi
}

assert_usage_error '알 수 없는 영향 축'   --impact '심각' --likelihood '통상 사용'
assert_usage_error '알 수 없는 발생확률 축' --impact '기능 저하' --likelihood '가끔'
assert_usage_error '영향 축 누락'         --likelihood '통상 사용'
assert_usage_error '발생확률 축 누락'      --impact '기능 저하'
assert_usage_error '인자 없음'
assert_usage_error '모드 혼용'            --status '높음(HIGH)' --impact '기능 저하'
assert_usage_error '알 수 없는 위험도'     --status '치명적'
assert_usage_error '알 수 없는 옵션'       --grade '높음(HIGH)'

assert_usage_error '--verdict 인자 0개'    --verdict
assert_usage_error '--verdict 인자 1개'    --verdict '통과(PASS)'
assert_usage_error '--verdict 인자 3개'    --verdict '통과(PASS)' '주의(WARN)' '통과(PASS)'
assert_usage_error '--verdict 알 수 없는 상태' --verdict '통과(PASS)' '애매함'
assert_usage_error '--verdict 모드 혼용'    --impact '기능 저하' --verdict '통과(PASS)' '통과(PASS)'
# 대응표 밖 접두는 걷어내지 않아 뒤의 값 검증에서 미지 값이 된다.
assert_usage_error '알 수 없는 이모지 접두'  --status '🔵 높음(HIGH)'

# 축 옵션의 존재 여부를 값으로 판정하면 빈 문자열이 "옵션 없음"과 같아져 모드 혼용 검사를
# 통과한다. 축 옵션 2종 × 값 형태(빈 값·일반 값) × 배치 순서를 전수로 세워 그 경로를 막는다.
assert_usage_error '--verdict 혼용: 영향 축 빈 값'        --impact '' --verdict '통과(PASS)' '통과(PASS)'
assert_usage_error '--verdict 혼용: 발생확률 축 빈 값'     --likelihood '' --verdict '통과(PASS)' '통과(PASS)'
assert_usage_error '--verdict 혼용: 두 축 모두 빈 값'      --impact '' --likelihood '' --verdict '주의(WARN)' '통과(PASS)'
assert_usage_error '--verdict 혼용: 발생확률 축 일반 값'   --likelihood '통상 사용' --verdict '통과(PASS)' '통과(PASS)'
# 축 옵션을 뒤에 두면 위치 인자로 흡수되어 개수 위반으로 걸린다. 배치가 달라도 거부는 같다.
assert_usage_error '--verdict 혼용: 축 옵션 후치'          --verdict '통과(PASS)' '통과(PASS)' --impact ''
assert_usage_error '--status 혼용: 영향 축 빈 값'          --impact '' --status '높음(HIGH)'
assert_usage_error '--status 혼용: 발생확률 축 빈 값'      --likelihood '' --status '높음(HIGH)'
assert_usage_error '--status 혼용: 발생확률 축 일반 값'    --likelihood '통상 사용' --status '높음(HIGH)'
# 축 모드 자체도 빈 값을 축 값으로 받지 않는다.
assert_usage_error '영향 축 빈 값'                         --impact '' --likelihood '통상 사용'
assert_usage_error '발생확률 축 빈 값'                     --impact '기능 저하' --likelihood ''
assert_usage_error '영향 축 빈 값 단독'                    --impact ''

# --- doc 카테고리 표 (issue #118) -----------------------------------------------
# SSoT 선언이 `원본 문서`일 때 쓰는 doc 카테고리 세트는 이름·순서가 결과 템플릿 행을 정하므로,
# 위 매트릭스와 달리 표 자체가 검사 대상이다. 확정 이름 7개를 리터럴로 두고(사본 러너도 각자 둔다,
# ADR 0002) 첫 열을 전수 대조한다. 행 수만 보면 이름 오기·순서 교환이 통과하므로 두 변형도 격추한다.

DOC_CATEGORIES='내용 정확성
구조 정합
모순·누락
보안·민감정보
가독성·일관성
최신성
근거 검증'

# doc_category_names <파일> → `| doc 카테고리 |` 표의 첫 열을 한 줄씩
doc_category_names() {
  awk '/^\| doc 카테고리 \|/ { f = 1; next }
       f && /^\|[- |]+\|[[:space:]]*$/ { next }
       f && /^\|/ { split($0, a, "|"); gsub(/^ +| +$/, "", a[2]); print a[2]; next }
       f { exit }' "$1"
}

# assert_doc_categories <파일> <기대: pass|fail> <설명>
assert_doc_categories() {
  local got
  got="$(doc_category_names "$1")"
  case "$2" in
    pass) if [ "$got" = "$DOC_CATEGORIES" ]; then ok "$3"; else ng "$3 (실제 [$(printf '%s' "$got" | tr '\n' ',')])"; fi ;;
    fail) if [ "$got" != "$DOC_CATEGORIES" ]; then ok "$3"; else ng "$3 (확정 이름·순서와 같게 읽힘)"; fi ;;
  esac
}

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

awk 'index($0, "| 최신성 |") != 1' "$SKILL" > "$tmpdir/doc-drop-row.md"
awk 'index($0, "| 구조 정합 |") == 1 { $0 = "| 아키텍처 |" substr($0, length("| 구조 정합 |") + 1) } { print }' \
  "$SKILL" > "$tmpdir/doc-code-name.md"
awk 'index($0, "| 모순·누락 |") == 1 { held = $0; next }
     index($0, "| 보안·민감정보 |") == 1 { print; print held; next }
     { print }' "$SKILL" > "$tmpdir/doc-swap.md"

assert_doc_categories "$SKILL"                    pass 'doc 카테고리 표: 확정 이름·순서 7개 통과'
assert_doc_categories "$tmpdir/doc-drop-row.md"   fail 'doc 카테고리 표: 행 삭제 격추'
assert_doc_categories "$tmpdir/doc-code-name.md"  fail 'doc 카테고리 표: 행 수 유지 이름 오기(구조 정합→아키텍처) 격추'
assert_doc_categories "$tmpdir/doc-swap.md"       fail 'doc 카테고리 표: 행 수 유지 순서 교환(모순·누락↔보안·민감정보) 격추'

# 표 앞의 분기 문장이 선언에 따라 어느 표를 쓸지 정한다. 위 표 검사는 첫 열만 보므로 분기 문장을 지우거나
# 두 조건을 맞바꿔도 통과한다 (#118 최종 감사 F-1). 분기 문장을 정확히 1행으로 잡아 두 조건을 대조한다.

# doc_branch_violations <파일> — 어긋난 조건을 1행씩 출력한다. 무출력이면 통과.
doc_branch_violations() {
  local rows
  rows="$(grep -F '이면 아래 doc 카테고리 세트' "$1")"
  [ "$(printf '%s' "$rows" | grep -c .)" -eq 1 ] || { echo '분기 문장 1행'; return; }
  printf '%s\n' "$rows" | grep -qF '`원본 문서`이면 아래 doc 카테고리 세트' || echo 'doc 세트 조건'
  printf '%s\n' "$rows" | grep -qF '`소스 코드`이거나 선언이 없으면 위 표를 ' || echo '코드 표 조건'
}

# assert_doc_branch <파일> <기대: pass|fail> <설명>
assert_doc_branch() {
  local out
  out="$(doc_branch_violations "$1")"
  case "$2" in
    pass) if [ -z "$out" ]; then ok "$3"; else ng "$3 (위반 [$(printf '%s' "$out" | tr '\n' ',')])"; fi ;;
    fail) if [ -n "$out" ]; then ok "$3"; else ng "$3 (분기 문장이 그대로 읽힘)"; fi ;;
  esac
}

awk 'index($0, "이면 아래 doc 카테고리 세트") == 0' "$SKILL" > "$tmpdir/doc-branch-drop.md"
awk 'index($0, "이면 아래 doc 카테고리 세트") { gsub(/`원본 문서`/, "@@"); gsub(/`소스 코드`/, "`원본 문서`"); gsub(/@@/, "`소스 코드`") } { print }' \
  "$SKILL" > "$tmpdir/doc-branch-swap.md"

assert_doc_branch "$SKILL"                      pass 'doc 카테고리 분기 문장: 원본 문서·소스 코드 두 조건 통과'
assert_doc_branch "$tmpdir/doc-branch-drop.md"  fail 'doc 카테고리 분기 문장: 행 삭제 격추'
assert_doc_branch "$tmpdir/doc-branch-swap.md"  fail 'doc 카테고리 분기 문장: 두 조건 맞바꿈 격추'

# --- 대상 수집 조항 (issue #142) -----------------------------------------------
# `## 대상 수집` 절의 소절 구성과 고정 앵커(이슈 #142 plan "고정 앵커")를 본다. 앵커는 소절 안에서 찾고,
# 두 낱말이 같은 행에 있어야 하는 앵커는 행 단위로 찾는다 — 낱말을 따로 찾으면 다른 문장의 낱말로 통과한다.
# 격추 사본마다 기대 위반 문구를 함께 대조해, 다른 앵커가 우연히 깨져 격추되는 경우를 통과로 세지 않는다.

# sec <파일> <## 제목> <### 제목> → 그 소절의 본문 행 (### 제목이 빈 값이면 절 전체). 코드 펜스 안의 # 행은 제목으로 보지 않는다
sec() { awk -v a="## $2" -v b="### $3" '/^[[:space:]]*```/{c=!c} !c&&/^## /{x=($0==a);y=0;next} !c&&/^### /{y=($0==b);next} x&&(b=="### "||y)' "$1"; }
# sec_head <파일> <## 제목> → 그 절의 첫 ### 소절 앞 본문 행
sec_head() { awk -v a="## $2" '/^[[:space:]]*```/{c=!c} !c&&/^## /{x=($0==a);y=0;next} !c&&/^### /{y=1;next} x&&!y' "$1"; }
# need <본문> <위치> <문자열…> → 본문에 없는 문자열마다 위반 1행
need() {
  local body="$1" where="$2" k; shift 2
  for k in "$@"; do printf '%s\n' "$body" | grep -qF -- "$k" || echo "${where}에 [${k}] 없음"; done
}
# need_row <본문> <위치> <문자열…> → 문자열이 모두 든 행이 없으면 위반 1행
need_row() {
  local body="$1" where="$2" rows k; shift 2
  rows="$body"
  for k in "$@"; do rows="$(printf '%s\n' "$rows" | grep -F -- "$k")"; done
  [ -n "$rows" ] || echo "${where}에 [$*]가 함께 든 행 없음"
}

# contents_guard <3단계 본문> → 3단계 코드 블록의 contents 조회 판정(`case "$file" in` … `esac`)을 실행해 위반을 1행씩 출력.
# gh 는 조회 경로(`repos/…` 인자)를 1행씩 내는 함수로 바꾼다. 트리 조회(`git/trees`)에는 그 경로를 고르는 필터가
# 있을 때만 준 모드를 돌려준다. 쓸 수 있는 경로는 고정한 SHA 로 한 번 조회하고, 다른 문자가 든 경로는
# 조회하지 않아야 한다(최종 감사 1차 F-3·F-7). 문구만 찾으면 `?ref=` 를 빼거나 판정 문자를 넓힌 사본이 통과한다.
# contents 조회 앞에 고정한 SHA 의 트리에서 모드를 읽고, 일반 파일(100644·100755)일 때만 조회해야 한다(최종 감사 3차 F-13).
contents_guard() {
  local snip="$tmpdir/contents-guard.sh" p m got
  printf '%s\n' "$1" | awk '/^case "\$file" in$/{f=1} f{print} f&&/^esac$/{exit}' > "$snip"
  if ! grep -qx 'esac' "$snip"; then echo '3단계에 contents 조회 판정(case "$file" in … esac) 없음'; return; fi
  # run_guard <경로> <트리 조회가 돌려줄 모드> → gh 호출의 조회 경로를 `GH <경로>` 1행씩
  run_guard() {
    bash -c 'sha=0123abc; file="$1"; want="$3"
      gh() { local a u=""; for a; do case "$a" in (repos/*) u="$a" ;; esac; done; printf "GH %s\n" "$u" >&3
        case "$u" in (*/git/trees/*) case "$*" in (*".path == \"${file}\""*) [ -z "$want" ] || printf "%s\n" "$want" ;; esac ;; esac; }
      . "$2"' _ "$1" "$snip" "$2" 3>&1 >/dev/null 2>&1
  }
  for m in 100644 100755; do
    got="$(run_guard 'app/a.py' "$m")"
    [ "$(printf '%s\n' "$got" | sed -n '1p')" = 'GH repos/<소유자>/<저장소>/git/trees/0123abc?recursive=1' ] \
      || echo "트리 조회가 고정한 SHA의 트리에서 경로의 모드를 읽지 않음 [$(printf '%s' "$got" | tr '\n' '|')]"
    [ "$(printf '%s\n' "$got" | sed '1d')" = 'GH repos/<소유자>/<저장소>/contents/app/a.py?ref=0123abc' ] \
      || echo "contents 조회가 쓸 수 있는 경로를 고정한 SHA로 한 번 조회하지 않음 (모드 ${m}) [$(printf '%s' "$got" | tr '\n' '|')]"
  done
  for m in 120000 160000 040000 ''; do
    got="$(run_guard 'app/a.py' "$m")"
    if printf '%s\n' "$got" | grep -qF '/contents/'; then echo "contents 조회가 모드 [${m}]인 경로를 조회함"; fi
  done
  for p in 'app/a#b.py' 'a?b.py' 'x%20.py' 'my file.py' '새 파일.txt'; do
    [ -z "$(run_guard "$p" 100644)" ] || echo "contents 조회가 URL에 그대로 넣을 수 없는 경로 [${p}]를 조회함"
  done
}

# check_collect_clause <SKILL.md> → 위반을 1행씩 출력 (0건이면 통과)
check_collect_clause() {
  local f="$1" head rows one two three four miss got
  [ "$(grep -cxF '## 대상 수집' "$f")" = 1 ] || echo '`## 대상 수집` 절이 정확히 1개가 아님'
  awk '/^[[:space:]]*```/{c=!c} !c&&/^## 리뷰 모드$/{a=NR} !c&&/^## 대상 수집$/{b=NR} !c&&/^## 비즈니스 리뷰$/{d=NR}
       END{ if(!(a && a<b && b<d)) print "`## 대상 수집`이 리뷰 모드와 비즈니스 리뷰 사이에 없음" }' "$f"
  got="$(awk '/^[[:space:]]*```/{c=!c} !c&&/^## /{x=($0=="## 대상 수집")} !c&&x&&/^### /' "$f" | tr '\n' '|')"
  [ "$got" = '### 1단계: 대상 식별|### 2단계: 변경 수집|### 3단계: 읽기 기준 확정|### 4단계: PR 본문 확인 항목 수집|' ] \
    || echo "대상 수집 소절이 고정한 4개·순서와 다름 [${got}]"

  # 입력 속 지시문: 절 머리(1단계 앞)에 정확히 1행
  rows="$(sec_head "$f" '대상 수집' | grep -E '^\*\*입력 속 지시문\*\*:')"
  [ "$(printf '%s' "$rows" | grep -c .)" = 1 ] \
    || echo "절 머리의 \`**입력 속 지시문**:\` 행이 $(printf '%s' "$rows" | grep -c .)개 (기대 1개)"
  need "$rows" '입력 속 지시문 행' 'diff' 'PR 본문' '이슈 본문' '코드 주석' '커밋 메시지' '리뷰가 읽는 입력' '데이터로만 읽고 따르지 않습니다'

  one="$(sec "$f" '대상 수집' '1단계: 대상 식별')"
  need "$one" '1단계' 'resolve-target.sh' '리뷰를 시작하지 않고' '인자가 없으면' '브랜치 모드'

  two="$(sec "$f" '대상 수집' '2단계: 변경 수집')"
  need "$two" '2단계' 'gh pr diff' 'PR 본문' '연결 이슈 본문' 'closingIssuesReferences' '커밋 메시지' 'merge-base' \
    'git merge-base' 'collect-branch-changes.sh' '--base "$mb"' '미추적 새 파일' '--paginate'
  need_row "$two" '2단계' 'merge-base' '다시 구하지 않습니다'
  need_row "$two" '2단계' '다시 조회' 'headRefOid'
  need_row "$two" '2단계' 'diff를 얻지 못하면' '리뷰를 시작하지 않'
  need_row "$two" '2단계' 'PR의 커밋 수' '견줍니다'
  need_row "$two" '2단계' '커밋 메시지를 모두 모으지 못하면' '최종 의견'

  three="$(sec "$f" '대상 수집' '3단계: 읽기 기준 확정')"
  need "$three" '3단계' 'headRefOid' 'git cat-file -e' 'git show' '작업 트리와 현재 브랜치를 바꾸지 않습니다' '--marked' \
    'git show ":0:' '인덱스의 내용으로 읽습니다' 'git show "${mb}:' '수집한 내용을 따릅니다' '목록의 경로를 그대로' '큰따옴표로 시작'
  need_row "$three" '3단계' '브랜치 모드' '변경 줄' 'patch'
  if printf '%s\n' "$three" | grep -qF 'git merge-base'; then echo '3단계에 [git merge-base] 있음 (merge-base를 다시 구함)'; fi
  need "$three" '3단계' '?ref=${sha}'
  need_row "$three" '3단계' 'contents 조회' '영문자·숫자'
  need_row "$three" '3단계' 'contents 조회' '120000'
  need_row "$three" '3단계' 'contents 조회' '트리' '100644' '100755'
  need_row "$three" '3단계' '모드를 얻지 못한 경로' '읽기 실패'
  contents_guard "$three"

  four="$(sec "$f" '대상 수집' '4단계: PR 본문 확인 항목 수집')"
  need "$four" '4단계' '리뷰어 확인 요청' '완료의 정의 대조'

  miss="$(sec "$f" '비즈니스 리뷰' '문서 부재 시 처리')"
  need_row "$miss" '문서 부재 시 처리' 'PR 모드' '수행하지 않습니다'
  need "$miss" '문서 부재 시 처리' '참조 문서 없음:'

  # SKILL.md 코드 블록에 작업 트리·현재 브랜치를 바꾸는 명령이 없다 (산문에서 이름으로 드는 것은 허용)
  awk '/^[[:space:]]*```/{c=!c;next}
       c && /^[[:space:]]*(git (checkout|switch|stash|reset|restore)|gh pr checkout)([[:space:]]|$)/{print "코드 블록의 작업 트리 변경 명령 — " $0}' "$f"
}

# edit_in <파일> <## 제목> <### 제목|빈 값> <동작> <문자열> [<바꿀 문자열>] → 그 범위에서만 고친 사본을 표준 출력으로
# 동작: drop-row(문자열이 모두 든 행 삭제, 여러 문자열은 | 로 잇는다), drop-str(문자열 삭제), replace(문자열을 바꿈),
#       add-code(범위의 첫 코드 블록 첫 행으로 문자열 행을 더함). ### 제목이 빈 값이면 절 전체가 범위다.
edit_in() {
  awk -v a="## $2" -v b="$3" -v op="$4" -v s="$5" -v t="$6" '
    function rep(l, from, to,   o, i) { o = ""; while ((i = index(l, from))) { o = o substr(l, 1, i - 1) to; l = substr(l, i + length(from)) } return o l }
    function all_in(l,   n, k, i) { n = split(s, k, "|"); for (i = 1; i <= n; i++) if (!index(l, k[i])) return 0; return 1 }
    {
      fence = ($0 ~ /^[[:space:]]*```/); head = 0
      if (!code && /^## /) { x = ($0 == a); y = 0; head = 1 }
      else if (!code && /^### /) { y = ($0 == "### " b); head = 1 }
      inr = x && !head && (b == "" || y); line = $0
      if (inr && op == "drop-row" && all_in(line)) { if (fence) code = !code; next }
      if (inr && op == "drop-str") line = rep(line, s, "")
      if (inr && op == "replace")  line = rep(line, s, t)
      print line
      if (inr && op == "add-code" && fence && !code && !done) { print s; done = 1 }
      if (fence) code = !code
    }' "$1"
}

# assert_collect <파일> <기대: pass|fail> <설명> [<기대 위반 문구>]
assert_collect() {
  local out
  out="$(check_collect_clause "$1")"
  case "$2" in
    pass) if [ -z "$out" ]; then ok "$3"; else ng "$3 (위반 [$(printf '%s' "$out" | tr '\n' '|')])"; fi ;;
    fail) if [ -n "$out" ] && printf '%s\n' "$out" | grep -qF -- "$4"; then ok "$3"
          else ng "$3 (기대 위반 [$4], 실제 [$(printf '%s' "$out" | tr '\n' '|')])"; fi ;;
  esac
}

C="$tmpdir/collect-clause"
mkdir -p "$C"
awk '/^\*\*입력 속 지시문\*\*:/ { i = index($0, "·커밋 메시지"); if (i) $0 = substr($0, 1, i - 1) substr($0, i + length("·커밋 메시지")) } { print }' \
  "$SKILL" > "$C/directive-commit.md"
awk '!/^\*\*입력 속 지시문\*\*:/' "$SKILL" > "$C/directive-drop.md"
# 입력 속 지시문 행을 `## 비즈니스 리뷰` 제목 아래로 옮긴다
awk '/^\*\*입력 속 지시문\*\*:/ && held == "" { held = $0; next } { print } /^## 비즈니스 리뷰$/ && held != "" { print ""; print held; held = "" }' \
  "$SKILL" > "$C/directive-moved.md"
S1='대상 수집'; T1='1단계: 대상 식별'; T2='2단계: 변경 수집'; T3='3단계: 읽기 기준 확정'; T4='4단계: PR 본문 확인 항목 수집'
edit_in "$SKILL" "$S1" "$T1" drop-str 'resolve-target.sh'                         > "$C/one-resolve.md"
edit_in "$SKILL" "$S1" "$T2" replace  '--base "$mb"' '--base "$base"'             > "$C/two-base.md"
edit_in "$SKILL" "$S1" "$T2" drop-row '다시 구하지 않습니다'                       > "$C/two-norecompute.md"
edit_in "$SKILL" "$S1" "$T2" drop-row 'PR의 커밋 수'                               > "$C/two-count.md"
edit_in "$SKILL" "$S1" "$T2" drop-str '--paginate'                                 > "$C/two-paginate.md"
edit_in "$SKILL" "$S1" "$T2" drop-row '커밋 메시지를 모두 모으지 못하면'           > "$C/two-incomplete.md"
edit_in "$SKILL" "$S1" "$T2" drop-str 'collect-branch-changes.sh'                  > "$C/two-collect.md"
edit_in "$SKILL" "$S1" "$T2" drop-row '다시 조회'                                  > "$C/two-requery.md"
edit_in "$SKILL" "$S1" "$T2" drop-row 'diff를 얻지 못하면'                         > "$C/two-fail.md"
edit_in "$SKILL" "$S1" "$T2" drop-str 'closingIssuesReferences'                    > "$C/two-closing.md"
edit_in "$SKILL" "$S1" "$T3" add-code 'mb="$(git merge-base "$base" HEAD)"'        > "$C/three-recompute.md"
edit_in "$SKILL" "$S1" "$T3" drop-str '큰따옴표로 시작'                            > "$C/three-quoted.md"
edit_in "$SKILL" "$S1" "$T3" replace  'git show ":0:' 'git show ":'                > "$C/three-stage.md"
edit_in "$SKILL" "$S1" "$T3" drop-str 'git show "${mb}:'                           > "$C/three-mb.md"
edit_in "$SKILL" "$S1" "$T3" drop-str '수집한 내용을 따릅니다'                     > "$C/three-follow.md"
edit_in "$SKILL" "$S1" "$T3" drop-str '목록의 경로를 그대로'                       > "$C/three-path.md"
edit_in "$SKILL" "$S1" "$T3" drop-str 'git cat-file -e'                            > "$C/three-catfile.md"
edit_in "$SKILL" "$S1" "$T3" drop-str '작업 트리와 현재 브랜치를 바꾸지 않습니다' > "$C/three-keep.md"
edit_in "$SKILL" "$S1" "$T3" drop-row '브랜치 모드|변경 줄|patch'                  > "$C/three-patch.md"
edit_in "$SKILL" "$S1" "$T3" drop-str '--marked'                                   > "$C/three-marked.md"
edit_in "$SKILL" "$S1" "$T3" drop-str '인덱스의 내용으로 읽습니다'                 > "$C/three-index.md"
edit_in "$SKILL" "$S1" "$T3" add-code "gh pr checkout '<PR 번호>'"                 > "$C/three-checkout.md"
edit_in "$SKILL" "$S1" "$T3" drop-str '?ref=${sha}'                                > "$C/three-ref.md"
edit_in "$SKILL" "$S1" "$T3" replace  '0123456789._~/-]' '0123456789._~/#?%-]'     > "$C/three-guard-wide.md"
edit_in "$SKILL" "$S1" "$T3" drop-row 'case "$file" in'                            > "$C/three-guard-drop.md"
edit_in "$SKILL" "$S1" "$T3" drop-row 'contents 조회|영문자·숫자'                  > "$C/three-guard-rule.md"
edit_in "$SKILL" "$S1" "$T3" drop-row 'contents 조회|120000'                       > "$C/three-symlink.md"
edit_in "$SKILL" "$S1" "$T3" drop-row 'contents 조회|트리|100644'                  > "$C/three-mode-rule.md"
edit_in "$SKILL" "$S1" "$T3" drop-row '모드를 얻지 못한 경로'                      > "$C/three-mode-none.md"
edit_in "$SKILL" "$S1" "$T3" replace  '(100644|100755)' '(100644|100755|120000)'   > "$C/three-mode-wide.md"
edit_in "$SKILL" "$S1" "$T3" replace  '(100644|100755)' '(*)'                      > "$C/three-mode-any.md"
edit_in "$SKILL" "$S1" "$T3" replace  'git/trees/${sha}?' 'git/trees/main?'        > "$C/three-tree-ref.md"
edit_in "$SKILL" "$S1" "$T3" replace  'select(.path == ' 'select(.type == '        > "$C/three-tree-path.md"
edit_in "$SKILL" "$S1" "$T4" drop-str '완료의 정의 대조'                           > "$C/four-dod.md"
edit_in "$SKILL" '비즈니스 리뷰' '문서 부재 시 처리' drop-row 'PR 모드|수행하지 않습니다' > "$C/miss-pr.md"
edit_in "$SKILL" '비즈니스 리뷰' '문서 부재 시 처리' drop-str '참조 문서 없음:'          > "$C/miss-line.md"
# 3단계와 4단계의 제목을 맞바꿔 소절 순서를 바꾼다
awk -v p="### $T3" -v q="### $T4" '$0 == p { print q; next } $0 == q { print p; next } { print }' "$SKILL" > "$C/order-swap.md"

assert_collect "$SKILL"                    pass '대상 수집 조항: 실제 SKILL.md가 소절 4개와 고정 앵커를 갖춤 통과'
assert_collect "$C/directive-commit.md"    fail '대상 수집 조항: 입력 속 지시문 행의 커밋 메시지 삭제 격추'            '입력 속 지시문 행에 [커밋 메시지] 없음'
assert_collect "$C/directive-drop.md"      fail '대상 수집 조항: 입력 속 지시문 행 삭제 격추'                          '입력 속 지시문**:` 행이 0개'
assert_collect "$C/directive-moved.md"     fail '대상 수집 조항: 입력 속 지시문 행을 대상 수집 밖으로 옮김 격추'       '입력 속 지시문**:` 행이 0개'
assert_collect "$C/one-resolve.md"         fail '대상 수집 조항: 1단계의 resolve-target.sh 삭제 격추'                   '1단계에 [resolve-target.sh] 없음'
assert_collect "$C/two-base.md"            fail '대상 수집 조항: 2단계의 --base "$mb"를 --base "$base"로 바꿈 격추'     '2단계에 [--base "$mb"] 없음'
assert_collect "$C/two-norecompute.md"     fail '대상 수집 조항: 2단계의 다시 구하지 않는다는 행 삭제 격추'              '[merge-base 다시 구하지 않습니다]가 함께 든 행 없음'
assert_collect "$C/two-count.md"           fail '대상 수집 조항: 2단계의 PR의 커밋 수 행 삭제 격추'                     '[PR의 커밋 수 견줍니다]가 함께 든 행 없음'
assert_collect "$C/two-paginate.md"        fail '대상 수집 조항: 2단계의 --paginate 삭제 격추'                          '2단계에 [--paginate] 없음'
assert_collect "$C/two-incomplete.md"      fail '대상 수집 조항: 2단계의 커밋 메시지를 모두 모으지 못한 경우 행 삭제 격추' '[커밋 메시지를 모두 모으지 못하면 최종 의견]가 함께 든 행 없음'
assert_collect "$C/two-collect.md"         fail '대상 수집 조항: 2단계의 collect-branch-changes.sh 삭제 격추'           '2단계에 [collect-branch-changes.sh] 없음'
assert_collect "$C/two-requery.md"         fail '대상 수집 조항: 2단계의 다시 조회 행 삭제 격추'                        '[다시 조회 headRefOid]가 함께 든 행 없음'
assert_collect "$C/two-fail.md"            fail '대상 수집 조항: 2단계의 diff 수집 실패 행 삭제 격추'                   '[diff를 얻지 못하면 리뷰를 시작하지 않]가 함께 든 행 없음'
assert_collect "$C/two-closing.md"         fail '대상 수집 조항: 2단계의 closingIssuesReferences 삭제 격추'             '2단계에 [closingIssuesReferences] 없음'
assert_collect "$C/three-recompute.md"     fail '대상 수집 조항: 3단계 코드 블록에 git merge-base 행 추가 격추'         '3단계에 [git merge-base] 있음'
assert_collect "$C/three-quoted.md"        fail '대상 수집 조항: 3단계의 큰따옴표로 시작 삭제 격추'                     '3단계에 [큰따옴표로 시작] 없음'
assert_collect "$C/three-stage.md"         fail '대상 수집 조항: 3단계의 git show ":0:을 git show ":로 바꿈 격추'       '3단계에 [git show ":0:] 없음'
assert_collect "$C/three-mb.md"            fail '대상 수집 조항: 3단계의 git show "${mb}: 삭제 격추'                    '3단계에 [git show "${mb}:] 없음'
assert_collect "$C/three-follow.md"        fail '대상 수집 조항: 3단계의 수집한 내용을 따른다는 문구 삭제 격추'         '3단계에 [수집한 내용을 따릅니다] 없음'
assert_collect "$C/three-path.md"          fail '대상 수집 조항: 3단계의 목록의 경로를 그대로 삭제 격추'                '3단계에 [목록의 경로를 그대로] 없음'
assert_collect "$C/three-catfile.md"       fail '대상 수집 조항: 3단계의 git cat-file -e 삭제 격추'                     '3단계에 [git cat-file -e] 없음'
assert_collect "$C/three-keep.md"          fail '대상 수집 조항: 3단계의 작업 트리·현재 브랜치 보존 문구 삭제 격추'     '3단계에 [작업 트리와 현재 브랜치를 바꾸지 않습니다] 없음'
assert_collect "$C/three-patch.md"         fail '대상 수집 조항: 3단계의 브랜치 모드 변경 줄을 patch로 읽는 행 삭제 격추' '[브랜치 모드 변경 줄 patch]가 함께 든 행 없음'
assert_collect "$C/three-marked.md"        fail '대상 수집 조항: 3단계의 --marked 삭제 격추'                            '3단계에 [--marked] 없음'
assert_collect "$C/three-index.md"         fail '대상 수집 조항: 3단계의 인덱스의 내용으로 읽는다는 문구 삭제 격추'     '3단계에 [인덱스의 내용으로 읽습니다] 없음'
assert_collect "$C/three-checkout.md"      fail '대상 수집 조항: 코드 블록에 gh pr checkout 행 추가 격추'               '코드 블록의 작업 트리 변경 명령'
assert_collect "$C/three-ref.md"           fail '대상 수집 조항: 3단계 contents 조회의 ?ref=${sha} 삭제 격추'           'contents 조회가 쓸 수 있는 경로를 고정한 SHA로 한 번 조회하지 않음'
assert_collect "$C/three-guard-wide.md"    fail '대상 수집 조항: contents 조회 판정 문자에 # ? %를 더함 격추'           'URL에 그대로 넣을 수 없는 경로 [app/a#b.py]를 조회함'
assert_collect "$C/three-guard-drop.md"    fail '대상 수집 조항: contents 조회 판정의 case 행 삭제 격추'                '3단계에 contents 조회 판정(case "$file" in … esac) 없음'
assert_collect "$C/three-guard-rule.md"    fail '대상 수집 조항: contents 조회의 경로 문자 조건 행 삭제 격추'           '[contents 조회 영문자·숫자]가 함께 든 행 없음'
assert_collect "$C/three-symlink.md"       fail '대상 수집 조항: 심볼릭 링크에 contents 조회를 쓰지 않는 행 삭제 격추'  '[contents 조회 120000]가 함께 든 행 없음'
assert_collect "$C/three-mode-rule.md"     fail '대상 수집 조항: contents 조회를 일반 파일 모드에만 쓰는 행 삭제 격추'  '[contents 조회 트리 100644 100755]가 함께 든 행 없음'
assert_collect "$C/three-mode-none.md"     fail '대상 수집 조항: 모드를 얻지 못한 경로의 읽기 실패 행 삭제 격추'        '[모드를 얻지 못한 경로 읽기 실패]가 함께 든 행 없음'
assert_collect "$C/three-mode-wide.md"     fail '대상 수집 조항: contents 조회 판정의 모드에 120000을 더함 격추'        'contents 조회가 모드 [120000]인 경로를 조회함'
assert_collect "$C/three-mode-any.md"      fail '대상 수집 조항: contents 조회 판정이 모드를 가리지 않음 격추'          'contents 조회가 모드 []인 경로를 조회함'
assert_collect "$C/three-tree-ref.md"      fail '대상 수집 조항: 트리 조회의 고정한 SHA를 main으로 바꿈 격추'           '트리 조회가 고정한 SHA의 트리에서 경로의 모드를 읽지 않음'
assert_collect "$C/three-tree-path.md"     fail '대상 수집 조항: 트리 조회 필터가 경로로 고르지 않음 격추'              'contents 조회가 쓸 수 있는 경로를 고정한 SHA로 한 번 조회하지 않음'
assert_collect "$C/four-dod.md"           fail '대상 수집 조항: 4단계의 완료의 정의 대조 삭제 격추'                    '4단계에 [완료의 정의 대조] 없음'
assert_collect "$C/miss-pr.md"             fail '대상 수집 조항: 문서 부재 시 처리의 PR 모드 행 삭제 격추'              '[PR 모드 수행하지 않습니다]가 함께 든 행 없음'
assert_collect "$C/miss-line.md"           fail '대상 수집 조항: 문서 부재 시 처리의 참조 문서 없음: 삭제 격추'         '문서 부재 시 처리에 [참조 문서 없음:] 없음'
assert_collect "$C/order-swap.md"          fail '대상 수집 조항: 3단계와 4단계의 순서 교환 격추'                        '대상 수집 소절이 고정한 4개·순서와 다름'

# --- 코드 레벨 조항 (issue #142) -----------------------------------------------
# `## 테크 리뷰`의 단계 4개와 2단계(변경 줄 읽기)·3단계(판정 문장, 확인 관점)의 고정 앵커를 본다.
# 위 대상 수집 조항과 같은 방식이며 sec·need·need_row 를 함께 쓴다. 확인 관점은 항목 순서와 항목당 개수(3~7개)를 센다.

# check_code_level_clause <SKILL.md> → 위반을 1행씩 출력 (0건이면 통과)
check_code_level_clause() {
  local f="$1" got read2 cat3 rows
  got="$(awk '/^[[:space:]]*```/{c=!c} !c&&/^## /{x=($0=="## 테크 리뷰")} !c&&x&&/^### /' "$f" | tr '\n' '|')"
  [ "$got" = '### 1단계: 코드베이스 색인 참조|### 2단계: 변경 줄 읽기|### 3단계: 카테고리별 검증|### 4단계: 결과 기록|' ] \
    || echo "테크 리뷰 단계 제목이 고정한 4개·순서와 다름 [${got}]"

  read2="$(sec "$f" '테크 리뷰' '2단계: 변경 줄 읽기')"
  need_row "$read2" '2단계' '삭제 줄' '빠짐없이'
  need "$read2" '2단계' '잠금 파일' '생성 파일'
  need_row "$read2" '2단계' '바이너리:' 'Git이 바이너리로 보아'

  cat3="$(sec "$f" '테크 리뷰' '3단계: 카테고리별 검증')"
  need_row "$cat3" '3단계' '버그·보안·성능' '2단계'
  rows="$(printf '%s\n' "$cat3" | grep -cE '^\*\*확인 관점\*\*')"
  [ "$rows" = 1 ] || echo "3단계의 \`**확인 관점**\` 행이 ${rows}개 (기대 1개)"
  printf '%s\n' "$cat3" | awk '
    /^- \*\*(버그|보안|성능)\*\*:/ { cur = $0; sub(/^- \*\*/, "", cur); sub(/\*\*:.*/, "", cur); order = order cur " "; next }
    /^  - / && cur != "" { n[cur]++; next }
    /^[[:space:]]*$/ { next }
    { cur = "" }
    END {
      if (order != "버그 보안 성능 ") print "확인 관점 항목이 버그·보안·성능 순서의 3개가 아님 [" order "]"
      split("버그 보안 성능", k, " ")
      for (i = 1; i <= 3; i++) if (n[k[i]] < 3 || n[k[i]] > 7) print k[i] " 확인 관점 " n[k[i]] + 0 "개 (기대 3~7개)"
    }'
}

# assert_code_level <파일> <기대: pass|fail> <설명> [<기대 위반 문구>]
assert_code_level() {
  local out
  out="$(check_code_level_clause "$1")"
  case "$2" in
    pass) if [ -z "$out" ]; then ok "$3"; else ng "$3 (위반 [$(printf '%s' "$out" | tr '\n' '|')])"; fi ;;
    fail) if [ -n "$out" ] && printf '%s\n' "$out" | grep -qF -- "$4"; then ok "$3"
          else ng "$3 (기대 위반 [$4], 실제 [$(printf '%s' "$out" | tr '\n' '|')])"; fi ;;
  esac
}

L="$tmpdir/code-level-clause"
mkdir -p "$L"
S2='2단계: 변경 줄 읽기'; S3='3단계: 카테고리별 검증'
awk -v h="### $S2" '$0 != h' "$SKILL" > "$L/read-heading.md"
awk -v p="### $S2" -v q="### $S3" '$0 == p { print q; next } $0 == q { print p; next } { print }' "$SKILL" > "$L/order-swap.md"
# `삭제 줄`과 `빠짐없이`가 함께 든 행에서만 `삭제 줄`을 지운다. 2단계의 다른 행에는 `삭제 줄`이 남는다
awk 'index($0, "삭제 줄") && index($0, "빠짐없이") { i = index($0, "삭제 줄"); $0 = substr($0, 1, i - 1) substr($0, i + length("삭제 줄")) } { print }' \
  "$SKILL" > "$L/read-deleted.md"
edit_in "$SKILL" '테크 리뷰' "$S2" drop-str '잠금 파일'               > "$L/read-lock.md"
edit_in "$SKILL" '테크 리뷰' "$S2" drop-str '생성 파일'               > "$L/read-generated.md"
edit_in "$SKILL" '테크 리뷰' "$S2" replace 'Git이 바이너리로 보아' '내용이 바이너리라' > "$L/read-binary.md"
edit_in "$SKILL" '테크 리뷰' "$S3" drop-row '버그·보안·성능|2단계'    > "$L/judge-drop.md"
awk '!/^\*\*확인 관점\*\*/' "$SKILL" > "$L/view-head.md"
awk '$0 != "- **보안**:"' "$SKILL" > "$L/view-security.md"
# 보안 항목의 관점 앞 2개를 지워 2개만 남긴다
awk '$0 == "- **보안**:" { print; f = 1; skip = 2; next } f && /^  - / && skip > 0 { skip--; next } f && !/^  - / { f = 0 } { print }' \
  "$SKILL" > "$L/view-two.md"
# 버그 항목에 관점을 더해 8개로 늘린다
awk '$0 == "- **버그**:" { print; f = 1; next } f && !/^  - / { while (n++ < 8 - m) print "  - 더한 관점 " n; f = 0 } f { m++ } { print }' \
  "$SKILL" > "$L/view-eight.md"
awk '$0 == "- **버그**:" { print "- **성능**:"; next } $0 == "- **성능**:" { print "- **버그**:"; next } { print }' "$SKILL" > "$L/view-order.md"

assert_code_level "$SKILL"                  pass '코드 레벨 조항: 실제 SKILL.md가 테크 리뷰 단계 4개·변경 줄 읽기·판정 문장·확인 관점을 갖춤 통과'
assert_code_level "$L/read-heading.md"      fail '코드 레벨 조항: 2단계 변경 줄 읽기 제목 삭제 격추'                   '테크 리뷰 단계 제목이 고정한 4개·순서와 다름'
assert_code_level "$L/order-swap.md"        fail '코드 레벨 조항: 2단계와 3단계 제목의 순서 교환 격추'                 '테크 리뷰 단계 제목이 고정한 4개·순서와 다름'
assert_code_level "$L/read-deleted.md"      fail '코드 레벨 조항: 빠짐없이 읽는 행의 삭제 줄 삭제 격추'                '[삭제 줄 빠짐없이]가 함께 든 행 없음'
assert_code_level "$L/read-lock.md"         fail '코드 레벨 조항: 2단계의 잠금 파일 삭제 격추'                         '2단계에 [잠금 파일] 없음'
assert_code_level "$L/read-generated.md"    fail '코드 레벨 조항: 2단계의 생성 파일 삭제 격추'                         '2단계에 [생성 파일] 없음'
assert_code_level "$L/read-binary.md"       fail '코드 레벨 조항: 바이너리 사유를 내용 기준으로 되돌림 격추'           '[바이너리: Git이 바이너리로 보아]가 함께 든 행 없음'
assert_code_level "$L/judge-drop.md"        fail '코드 레벨 조항: 3단계의 판정 문장 삭제 격추'                         '[버그·보안·성능 2단계]가 함께 든 행 없음'
assert_code_level "$L/view-head.md"         fail '코드 레벨 조항: 확인 관점 머리 행 삭제 격추'                         '`**확인 관점**` 행이 0개'
assert_code_level "$L/view-security.md"     fail '코드 레벨 조항: 확인 관점의 보안 항목 삭제 격추'                     '확인 관점 항목이 버그·보안·성능 순서의 3개가 아님'
assert_code_level "$L/view-two.md"          fail '코드 레벨 조항: 보안 항목의 관점을 2개로 줄임 격추'                  '보안 확인 관점 2개'
assert_code_level "$L/view-eight.md"        fail '코드 레벨 조항: 버그 항목의 관점을 8개로 늘림 격추'                  '버그 확인 관점 8개'
assert_code_level "$L/view-order.md"        fail '코드 레벨 조항: 확인 관점 항목의 순서 교환(버그↔성능) 격추'          '확인 관점 항목이 버그·보안·성능 순서의 3개가 아님'

# --- 발견 처리 조항 (issue #142) -----------------------------------------------
# `## 발견 처리` 절의 위치·소절 구성과 고정 앵커, 두 결과 기록 단계가 인용 위치 재확인을 가리키는지,
# `## 결과 기록 형식`의 PR 본문 대조 불일치 처리를 본다. 위 대상 수집 조항과 같은 방식이다.

# check_finding_clause <SKILL.md> → 위반을 1행씩 출력 (0건이면 통과)
check_finding_clause() {
  local f="$1" got rc fs pre fmt
  [ "$(grep -cxF '## 발견 처리' "$f")" = 1 ] || echo '`## 발견 처리` 절이 정확히 1개가 아님'
  awk '/^[[:space:]]*```/{c=!c} !c&&/^## 테크 리뷰$/{a=NR} !c&&/^## 발견 처리$/{b=NR} !c&&/^## 위험도 분류$/{d=NR}
       END{ if(!(a && a<b && b<d)) print "`## 발견 처리`가 테크 리뷰와 위험도 분류 사이에 없음" }' "$f"
  got="$(awk '/^[[:space:]]*```/{c=!c} !c&&/^## /{x=($0=="## 발견 처리")} !c&&x&&/^### /' "$f" | tr '\n' '|')"
  [ "$got" = '### 인용 위치 재확인|### 실패 시나리오|### 변경 전부터 있던 결함|' ] \
    || echo "발견 처리 소절이 고정한 3개·순서와 다름 [${got}]"

  rc="$(sec "$f" '발견 처리' '인용 위치 재확인')"
  need "$rc" '인용 위치 재확인' '다시 읽어' '(확인 필요)' 'patch와 다르다는 이유만으로'
  need_row "$rc" '인용 위치 재확인' '브랜치 모드' 'patch'
  need_row "$rc" '인용 위치 재확인' 'patch에 나오지 않은 줄' 'merge-base'
  if printf '%s\n' "$rc" | grep -qF 'git merge-base'; then echo '인용 위치 재확인에 [git merge-base] 있음 (merge-base를 다시 구함)'; fi

  fs="$(sec "$f" '발견 처리' '실패 시나리오')"
  need "$fs" '실패 시나리오' '실패 시나리오:' '버그·보안·성능'

  pre="$(sec "$f" '발견 처리' '변경 전부터 있던 결함')"
  need "$pre" '변경 전부터 있던 결함' '카테고리 건수·상태·판정 산출에 넣지 않습니다' '옮기기만 한 줄'

  need "$(sec "$f" '비즈니스 리뷰' '3단계: 결과 기록')" '비즈니스 리뷰 3단계' '인용 위치 재확인'
  need "$(sec "$f" '테크 리뷰' '4단계: 결과 기록')" '테크 리뷰 4단계' '인용 위치 재확인'

  fmt="$(sec "$f" '결과 기록 형식' '')"
  need "$fmt" '결과 기록 형식' 'PR 본문 대조' '불일치 자체는 리뷰 포인트로 올리지 않습니다'
}

# assert_finding <파일> <기대: pass|fail> <설명> [<기대 위반 문구>]
assert_finding() {
  local out
  out="$(check_finding_clause "$1")"
  case "$2" in
    pass) if [ -z "$out" ]; then ok "$3"; else ng "$3 (위반 [$(printf '%s' "$out" | tr '\n' '|')])"; fi ;;
    fail) if [ -n "$out" ] && printf '%s\n' "$out" | grep -qF -- "$4"; then ok "$3"
          else ng "$3 (기대 위반 [$4], 실제 [$(printf '%s' "$out" | tr '\n' '|')])"; fi ;;
  esac
}

P="$tmpdir/finding-clause"
mkdir -p "$P"
F1='발견 처리'; R1='인용 위치 재확인'; R2='실패 시나리오'; R3='변경 전부터 있던 결함'
edit_in "$SKILL" "$F1" "$R1" add-code 'mb="$(git merge-base "$base" HEAD)"'            > "$P/recheck-recompute.md"
edit_in "$SKILL" "$F1" "$R1" drop-str '(확인 필요)'                                    > "$P/recheck-unverified.md"
edit_in "$SKILL" "$F1" "$R1" drop-str 'patch와 다르다는 이유만으로'                    > "$P/recheck-differs.md"
edit_in "$SKILL" "$F1" "$R1" drop-row 'patch에 나오지 않은 줄'                         > "$P/recheck-rest.md"
edit_in "$SKILL" "$F1" "$R1" drop-row '브랜치 모드|patch'                              > "$P/recheck-patch.md"
edit_in "$SKILL" "$F1" "$R2" drop-str '실패 시나리오:'                                 > "$P/scenario-line.md"
edit_in "$SKILL" "$F1" "$R3" drop-str '카테고리 건수·상태·판정 산출에 넣지 않습니다'   > "$P/pre-exclude.md"
edit_in "$SKILL" "$F1" "$R3" drop-str '옮기기만 한 줄'                                 > "$P/pre-moved.md"
edit_in "$SKILL" '테크 리뷰' '4단계: 결과 기록' drop-str '인용 위치 재확인'             > "$P/tech-record.md"
edit_in "$SKILL" '비즈니스 리뷰' '3단계: 결과 기록' drop-str '인용 위치 재확인'         > "$P/biz-record.md"
edit_in "$SKILL" '결과 기록 형식' '' drop-str '불일치 자체는 리뷰 포인트로 올리지 않습니다' > "$P/format-mismatch.md"
# `### 변경 전부터 있던 결함` 소절(다음 ## 제목 앞까지)을 파일 끝으로 옮긴다
awk -v h="### $R3" '/^[[:space:]]*```/{c=!c} !c && $0 == h { m = 1 } m && !c && /^## / { m = 0 } m { held = held $0 "\n"; next } { print } END { printf "%s", held }' \
  "$SKILL" > "$P/pre-moved-out.md"

assert_finding "$SKILL"                    pass '발견 처리 조항: 실제 SKILL.md가 소절 3개·고정 앵커·결과 기록 단계의 재확인 문장을 갖춤 통과'
assert_finding "$P/recheck-recompute.md"   fail '발견 처리 조항: 인용 위치 재확인 코드 블록에 git merge-base 행 추가 격추'   '인용 위치 재확인에 [git merge-base] 있음'
assert_finding "$P/recheck-unverified.md"  fail '발견 처리 조항: 인용 위치 재확인의 (확인 필요) 삭제 격추'                  '인용 위치 재확인에 [(확인 필요)] 없음'
assert_finding "$P/recheck-differs.md"     fail '발견 처리 조항: 인용 위치 재확인의 patch와 다르다는 이유만으로 삭제 격추'   '인용 위치 재확인에 [patch와 다르다는 이유만으로] 없음'
assert_finding "$P/recheck-rest.md"        fail '발견 처리 조항: patch에 나오지 않은 줄을 확인하는 행 삭제 격추'             '[patch에 나오지 않은 줄 merge-base]가 함께 든 행 없음'
assert_finding "$P/recheck-patch.md"       fail '발견 처리 조항: 브랜치 모드 변경 줄을 patch로 확인하는 행 삭제 격추'        '[브랜치 모드 patch]가 함께 든 행 없음'
assert_finding "$P/scenario-line.md"       fail '발견 처리 조항: 실패 시나리오 소절의 실패 시나리오: 삭제 격추'              '실패 시나리오에 [실패 시나리오:] 없음'
assert_finding "$P/pre-exclude.md"         fail '발견 처리 조항: 변경 전부터 있던 결함의 산출 제외 문구 삭제 격추'           '변경 전부터 있던 결함에 [카테고리 건수·상태·판정 산출에 넣지 않습니다] 없음'
assert_finding "$P/pre-moved.md"           fail '발견 처리 조항: 변경 전부터 있던 결함의 옮기기만 한 줄 삭제 격추'           '변경 전부터 있던 결함에 [옮기기만 한 줄] 없음'
assert_finding "$P/tech-record.md"         fail '발견 처리 조항: 테크 리뷰 4단계의 인용 위치 재확인 삭제 격추'               '테크 리뷰 4단계에 [인용 위치 재확인] 없음'
assert_finding "$P/biz-record.md"          fail '발견 처리 조항: 비즈니스 리뷰 3단계의 인용 위치 재확인 삭제 격추'           '비즈니스 리뷰 3단계에 [인용 위치 재확인] 없음'
assert_finding "$P/format-mismatch.md"     fail '발견 처리 조항: 결과 기록 형식의 불일치 처리 문구 삭제 격추'                '결과 기록 형식에 [불일치 자체는 리뷰 포인트로 올리지 않습니다] 없음'
assert_finding "$P/pre-moved-out.md"       fail '발견 처리 조항: 변경 전부터 있던 결함 소절을 발견 처리 밖으로 옮김 격추'    '발견 처리 소절이 고정한 3개·순서와 다름'

# --- 결과 템플릿 (issue #142) --------------------------------------------------
# `templates/review-result-template.md`의 `##` 제목 순서와 고정 앵커(이슈 #142 plan "고정 앵커"의 템플릿 표)를 본다.

TEMPLATE="$HERE/../templates/review-result-template.md"

# check_result_template <템플릿> → 위반을 1행씩 출력 (0건이면 통과)
check_result_template() {
  local f="$1" got sum
  got="$(grep -E '^## ' "$f" | tr '\n' '|')"
  [ "$got" = '## 요약|## PR 본문 대조|## 비즈니스 리뷰|## 테크 리뷰|## 변경 전부터 있던 결함|' ] \
    || echo "템플릿 ## 제목이 고정한 5개·순서와 다름 [${got}]"
  sum="$(sec "$f" '요약' '')"
  need_row "$sum" '요약' '- 코드 레벨 검증: 읽은 파일 ' '읽지 않은 파일'
  printf '%s\n' "$sum" | grep -qE '^- 코드 레벨 검증: 읽은 파일 ' || echo '요약에 `- 코드 레벨 검증: 읽은 파일 ` 행 없음'
  printf '%s\n' "$sum" | grep -qE '^  - .*: .*(잠금 파일|생성 파일)' || echo '요약에 읽지 않은 파일·사유 하위 행 없음'
  printf '%s\n' "$sum" | grep -qE '^- 변경 전부터 있던 결함: ' || echo '요약에 `- 변경 전부터 있던 결함: ` 행 없음'
  need "$(sec "$f" '비즈니스 리뷰' '')" '비즈니스 리뷰' '참조 문서 없음: '
  awk '/^## /{x=($0=="## 테크 리뷰")} x&&/^<details>/{d=1} x&&/^<\/details>/{d=0} x&&d&&/^실패 시나리오: /{n++}
       END{ if(!n) print "테크 리뷰 근거 접기에 `실패 시나리오: ` 행 없음" }' "$f"
  grep -qF '(확인 필요)' "$f" || echo '템플릿에 [(확인 필요)] 없음'
}

# assert_template <파일> <기대: pass|fail> <설명> [<기대 위반 문구>]
assert_template() {
  local out
  out="$(check_result_template "$1")"
  case "$2" in
    pass) if [ -z "$out" ]; then ok "$3"; else ng "$3 (위반 [$(printf '%s' "$out" | tr '\n' '|')])"; fi ;;
    fail) if [ -n "$out" ] && printf '%s\n' "$out" | grep -qF -- "$4"; then ok "$3"
          else ng "$3 (기대 위반 [$4], 실제 [$(printf '%s' "$out" | tr '\n' '|')])"; fi ;;
  esac
}

M="$tmpdir/result-template"
mkdir -p "$M"
# `## PR 본문 대조` 섹션(다음 ## 제목 앞까지)을 `## 테크 리뷰` 바로 앞, 곧 `## 비즈니스 리뷰` 뒤로 옮긴다
awk '/^## PR 본문 대조$/ { m = 1 } m && /^## / && $0 != "## PR 본문 대조" { m = 0 } m { held = held $0 "\n"; next }
     /^## 테크 리뷰$/ { printf "%s", held } { print }' "$TEMPLATE" > "$M/pr-moved.md"
awk '$0 != "## 변경 전부터 있던 결함"' "$TEMPLATE" > "$M/pre-drop.md"
awk '!/^- 코드 레벨 검증:/' "$TEMPLATE" > "$M/sum-code.md"
awk '!/^- 변경 전부터 있던 결함:/' "$TEMPLATE" > "$M/sum-pre.md"
awk '!/^  - <경로>: /' "$TEMPLATE" > "$M/sum-reason.md"
# 테크 리뷰의 `실패 시나리오: ` 행을 근거 접기 밖(</details> 다음)으로 옮긴다
awk '/^## /{x=($0=="## 테크 리뷰")} x && /^실패 시나리오: / { held = $0; next } { print } x && /^<\/details>/ && held != "" { print ""; print held; held = "" }' \
  "$TEMPLATE" > "$M/scenario-out.md"
edit_in "$TEMPLATE" '비즈니스 리뷰' '' drop-row '참조 문서 없음: ' > "$M/biz-nodoc.md"
awk '{ gsub(/\(확인 필요\)/, "") } { print }' "$TEMPLATE" > "$M/unverified.md"

assert_template "$TEMPLATE"              pass '결과 템플릿: 실제 템플릿이 ## 제목 순서·요약 두 줄과 하위 행·참조 문서 없음·실패 시나리오·확인 필요를 갖춤 통과'
assert_template "$M/pr-moved.md"         fail '결과 템플릿: PR 본문 대조를 비즈니스 리뷰 뒤로 옮김 격추'          '템플릿 ## 제목이 고정한 5개·순서와 다름'
assert_template "$M/pre-drop.md"         fail '결과 템플릿: 변경 전부터 있던 결함 섹션 제목 삭제 격추'            '템플릿 ## 제목이 고정한 5개·순서와 다름'
assert_template "$M/sum-code.md"         fail '결과 템플릿: 요약의 코드 레벨 검증 행 삭제 격추'                   '요약에 `- 코드 레벨 검증: 읽은 파일 ` 행 없음'
assert_template "$M/sum-pre.md"          fail '결과 템플릿: 요약의 변경 전부터 있던 결함 행 삭제 격추'            '요약에 `- 변경 전부터 있던 결함: ` 행 없음'
assert_template "$M/sum-reason.md"       fail '결과 템플릿: 요약의 읽지 않은 파일·사유 하위 행 삭제 격추'         '요약에 읽지 않은 파일·사유 하위 행 없음'
assert_template "$M/scenario-out.md"     fail '결과 템플릿: 실패 시나리오 행을 근거 접기 밖으로 옮김 격추'        '테크 리뷰 근거 접기에 `실패 시나리오: ` 행 없음'
assert_template "$M/biz-nodoc.md"        fail '결과 템플릿: 비즈니스 리뷰의 참조 문서 없음 행 삭제 격추'          '비즈니스 리뷰에 [참조 문서 없음: ] 없음'
assert_template "$M/unverified.md"       fail '결과 템플릿: (확인 필요) 표기 삭제 격추'                           '템플릿에 [(확인 필요)] 없음'

# --- 모의 실행 fixture (issue #142) ---------------------------------------------
# fixtures/code-level/ 의 입력·기대 쌍으로 [QD] 모의 실행한다(방법은 그 디렉토리의 README.md).
# 여기서는 context-harvest 러너와 같이 쌍이 빠짐없이 있는지만 본다. 케이스 여섯은 이슈 #142 plan Task 6이 정한 목록이다.

FIXTURE_DIR="$HERE/fixtures/code-level"
FIXTURE_CASES='planted-defects unverifiable clean deleted-lines preexisting index-read'

# check_fixture <디렉토리> → 위반을 1행씩 출력 (0건이면 통과)
check_fixture() {
  local d="$1" c f base
  [ -r "$d/README.md" ] || echo 'README.md 없음'
  for c in $FIXTURE_CASES; do
    [ -r "$d/${c}.input.md" ] || echo "입력 파일 없음 — ${c}.input.md"
    [ -r "$d/${c}.expected.md" ] || echo "기대 파일 없음 — ${c}.expected.md"
  done
  for f in "$d"/*.input.md "$d"/*.expected.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"; base="${base%.input.md}"; base="${base%.expected.md}"
    printf '%s\n' $FIXTURE_CASES | grep -qxF -- "$base" || echo "케이스 목록에 없는 파일 — $(basename "$f")"
  done
}

# assert_fixture <디렉토리> <기대: pass|fail> <설명> [<기대 위반 문구>]
assert_fixture() {
  local out
  out="$(check_fixture "$1")"
  case "$2" in
    pass) if [ -z "$out" ]; then ok "$3"; else ng "$3 (위반 [$(printf '%s' "$out" | tr '\n' '|')])"; fi ;;
    fail) if [ -n "$out" ] && printf '%s\n' "$out" | grep -qF -- "$4"; then ok "$3"
          else ng "$3 (기대 위반 [$4], 실제 [$(printf '%s' "$out" | tr '\n' '|')])"; fi ;;
  esac
}

# fixture_copy <이름> <뺄 파일> → 뺄 파일만 지운 사본 디렉토리 경로
fixture_copy() {
  local d="$tmpdir/fixture-$1"
  mkdir -p "$d" && cp "$FIXTURE_DIR"/*.md "$d/" && rm -f "$d/$2"
  printf '%s\n' "$d"
}

assert_fixture "$FIXTURE_DIR" pass '모의 실행 fixture: 여섯 케이스의 입력·기대 쌍과 README를 모두 갖춤 통과'
assert_fixture "$(fixture_copy no-expected 'preexisting.expected.md')" fail \
  '모의 실행 fixture: 기대 파일 하나를 뺀 사본 격추' '기대 파일 없음 — preexisting.expected.md'
assert_fixture "$(fixture_copy no-input 'index-read.input.md')" fail \
  '모의 실행 fixture: 입력 파일 하나를 뺀 사본 격추' '입력 파일 없음 — index-read.input.md'
assert_fixture "$(fixture_copy no-readme 'README.md')" fail \
  '모의 실행 fixture: README를 뺀 사본 격추' 'README.md 없음'

# --- 대상 대조 (issue #142) ----------------------------------------------------
# resolve-target.sh 는 PR 링크·번호와 원격 URL 로 대상 저장소와 PR 번호를 낸다. 종료 코드와 표준 출력을 함께 대조한다
# — 종료 코드만 보면 실패 때 표준 출력에 값이 새는 경우를 놓친다. 실패 때는 사유가 표준 오류 1행인지도 본다.

# assert_resolve <기대 종료 코드> <기대 표준 출력> <설명> <헬퍼 인자…>
assert_resolve() {
  local want_rc="$1" want_out="$2" desc="$3"; shift 3
  local out rc nerr
  out="$("$RESOLVE" "$@" 2> "$tmpdir/resolve.err")"; rc=$?
  nerr="$(grep -c . "$tmpdir/resolve.err")"
  if [ "$rc" != "$want_rc" ] || [ "$out" != "$want_out" ]; then
    ng "$desc (기대 rc=${want_rc} out=[${want_out}], 실제 rc=${rc} out=[${out}])"
  elif [ "$rc" != 0 ] && [ "$nerr" != 1 ]; then
    ng "$desc (표준 오류의 사유가 1행이 아님: ${nerr}행)"
  else
    ok "$desc"
  fi
}

SHOP='https://github.com/acme/shop.git'
assert_resolve 0 'github.com/acme/shop 12' '대상 대조: https 원격과 같은 저장소 링크 통과' --remote-url "$SHOP" --pr 'https://github.com/acme/shop/pull/12'
assert_resolve 0 'github.com/acme/shop 12' '대상 대조: scp 형식 원격 통과' --remote-url 'git@github.com:acme/shop.git' --pr 'https://github.com/acme/shop/pull/12'
assert_resolve 0 'github.com/acme/shop 12' '대상 대조: 대소문자가 다른 링크 통과' --remote-url "$SHOP" --pr 'https://GitHub.com/Acme/Shop/pull/12'
assert_resolve 0 'github.com/acme/shop 12' '대상 대조: 링크 뒤 /files 통과' --remote-url "$SHOP" --pr 'https://github.com/acme/shop/pull/12/files'
assert_resolve 0 'github.com/acme/shop 12' '대상 대조: 링크 뒤 /commits·쿼리·조각 통과' --remote-url "$SHOP" --pr 'https://github.com/acme/shop/pull/12/commits/abc1234?w=1#diff'
assert_resolve 0 'github.com/acme/shop 12' '대상 대조: PR 번호 12 통과' --pr '12' --remote-url "$SHOP"
assert_resolve 0 'github.com/acme/shop 12' '대상 대조: PR 번호 #12 통과' --remote-url "$SHOP" --pr '#12'
assert_resolve 0 'github.com/Acme/Shop 12' '대상 대조: 출력의 저장소 표기는 원격 URL 의 값 통과' --remote-url 'https://github.com/Acme/Shop.git' --pr 'https://github.com/acme/shop/pull/12'
assert_resolve 0 'ghe.example.com/acme/shop 7' '대상 대조: ssh 원격의 사용자·포트 제거 통과' --remote-url 'ssh://git@ghe.example.com:2222/acme/shop.git' --pr 'https://ghe.example.com/acme/shop/pull/7'
assert_resolve 1 '' '대상 대조: 다른 저장소 링크 격추' --remote-url "$SHOP" --pr 'https://github.com/acme/other/pull/12'
assert_resolve 1 '' '대상 대조: 다른 호스트 링크 격추' --remote-url "$SHOP" --pr 'https://ghe.example.com/acme/shop/pull/12'
assert_resolve 2 '' '대상 대조: issues 링크 격추' --remote-url "$SHOP" --pr 'https://github.com/acme/shop/issues/12'
assert_resolve 2 '' '대상 대조: --pr 누락 격추' --remote-url "$SHOP"
assert_resolve 2 '' '대상 대조: --remote-url 누락 격추' --pr '12'
assert_resolve 2 '' '대상 대조: 정규화할 수 없는 원격 URL 격추' --remote-url 'not-a-url' --pr '12'
assert_resolve 2 '' '대상 대조: 저장소 단계가 모자란 링크 격추' --remote-url "$SHOP" --pr 'https://github.com/acme/pull/12'
assert_resolve 2 '' '대상 대조: PR 번호 형식 아님 격추' --remote-url "$SHOP" --pr '12a'
assert_resolve 2 '' '대상 대조: --pr 중복 격추' --remote-url "$SHOP" --pr '12' --pr '13'
assert_resolve 2 '' '대상 대조: 알 수 없는 인자 격추' --remote-url "$SHOP" --pr '12' --repo 'acme/shop'

# --- 브랜치 수집 (issue #142) --------------------------------------------------
# collect-branch-changes.sh 는 merge-base 와 "지금 작업 트리를 전부 스테이징해 커밋하면 들어갈 내용"의 차이를 내고,
# --marked 는 변경을 보지 않도록 표시한 경로를 낸다. 케이스는 임시 저장소에서 수행하며 목록은 정렬한 전체를 기대값과
# 견준다 — 기대 행이 있는지만 보면 중복 수집과 여분 경로를 놓친다. 사례를 만드는 준비 상태가 성립하지 않으면
# (훅이 돌지 않음 등) 그 케이스를 실패로 낸다. 준비 상태를 보지 않으면 사례가 없는 환경에서 그대로 통과한다.
#
# 사용자 설정(전역·시스템)에 기대지 않게 끄고, 작업 트리 밖 실행 케이스가 상위 디렉토리의 저장소를 찾지 않게 막는다.

export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
export GIT_CEILING_DIRECTORIES="${tmpdir}:$(cd "$tmpdir" && pwd -P)"
TAB="$(printf '\t')"

# newrepo <디렉토리> — 케이스용 임시 저장소를 만든다
newrepo() {
  git init -q -b main "$1" \
    && git -C "$1" config user.email 't@example.com' && git -C "$1" config user.name 't' \
    && git -C "$1" config commit.gpgsign false && git -C "$1" config core.fileMode true \
    && git -C "$1" config core.excludesFile /dev/null
}
# g <저장소> <git 인자…> — 출력 없이 git 을 실행한다
g() { local r="$1"; shift; git -C "$r" "$@" >/dev/null 2>&1; }
# collect <디렉토리> <헬퍼 인자…> — 그 디렉토리에서 헬퍼를 실행해 표준 출력을 out, 종료 코드를 rc 에 남긴다
collect() { local dir="$1"; shift; out="$(cd "$dir" && "$COLLECT" "$@" 2> "$tmpdir/collect.err")"; rc=$?; }
# list_of — out 의 변경 파일 목록(첫 빈 줄 앞)을 정렬해 낸다
list_of() { printf '%s\n' "$out" | awk 'NF==0{exit} {print}' | LC_ALL=C sort; }
# patch_of — out 의 patch(첫 빈 줄 뒤)
patch_of() { printf '%s\n' "$out" | awk 'p{print} NF==0{p=1}'; }
# file_patch <파일> — out 의 patch 에서 그 파일의 구간
file_patch() { patch_of | awk -v h="diff --git a/$1 b/$1" '/^diff --git /{x=($0==h)} x'; }
# want_rows <행…> — 기대 목록. 인자마다 한 행으로 내고 정렬한다
want_rows() { printf '%s\n' "$@" | LC_ALL=C sort; }
# fp <저장소> — .git 아래 모든 파일의 목록과 내용의 지문 (수정 시각은 보지 않는다)
fp() { find "$1/.git" -type f -exec cksum {} + | LC_ALL=C sort; }
# has_line <글> <행> — 정확히 일치하는 행이 있는가
has_line() { printf '%s\n' "$1" | grep -qxF -- "$2"; }
# show <글> — 실패 메시지용으로 줄바꿈·탭을 보이게 바꾼다
show() { printf '%s' "$1" | tr '\n\t' '| '; }
# mark_of <이름> — 파일마다 다른 기준 줄에 쓰는 수
mark_of() { printf '%s' "$1" | cksum | cut -d' ' -f1; }

# 인덱스 상태: 작업 트리를 고정하고 인덱스 상태만 바꿔, 상태마다 목록 전체가 같은 기대값과 같은지 본다.
r1="$tmpdir/bc-index"
newrepo "$r1" || ng '브랜치 수집: 인덱스 상태 저장소를 만들지 못함'
printf 'keep\n' > "$r1/keep.txt"; printf 'old\n' > "$r1/edit.txt"; printf 'gone\n' > "$r1/gone.txt"
printf '#!/bin/sh\n' > "$r1/tool.sh"; printf 'same\n' > "$r1/staged.txt"; printf '*.log\n' > "$r1/.gitignore"
{ g "$r1" add -A && g "$r1" commit -m base && g "$r1" checkout -b work \
  && printf 'committed\n' > "$r1/committed.txt" && g "$r1" add committed.txt && g "$r1" commit -m work; } \
  || ng '브랜치 수집: 기준 커밋과 브랜치 커밋을 만들지 못함'
printf 'old\nnew line\n' > "$r1/edit.txt"     # 내용 수정
rm -f "$r1/gone.txt"                          # 삭제
chmod +x "$r1/tool.sh"                        # 실행 권한만 변경
printf 'old\n' > "$r1/copy.txt"               # 기준의 다른 파일(edit.txt)과 내용이 같은 새 파일
printf 'fresh\n' > "$r1/새 파일.txt"          # 미추적 새 파일 (한글 경로)
printf 'noise\n' > "$r1/debug.log"            # 무시 규칙에 걸린 미추적 파일
mkdir -p "$r1/.ai/99_workspace" && printf 'tmp\n' > "$r1/.ai/99_workspace/tmp.md"
want1="$(want_rows "A${TAB}committed.txt" "A${TAB}copy.txt" "A${TAB}새 파일.txt" "D${TAB}gone.txt" "M${TAB}edit.txt" "M${TAB}tool.sh")"

# chk_index <상태 이름> — 목록 전체가 기대와 같은가
chk_index() {
  local got
  collect "$r1" --base main
  got="$(list_of)"
  if [ "$rc" = 0 ] && [ "$got" = "$want1" ]; then ok "브랜치 수집: 인덱스 상태 [$1] 목록 통과"
  else ng "브랜치 수집: 인덱스 상태 [$1] 목록 (rc=${rc} [$(show "$got")])"; fi
}

chk_index '스테이징 없음'
top_out="$out"
p="$(patch_of)"
if has_line "$p" '+new line' && has_line "$p" '-gone' && has_line "$p" '+fresh' \
   && has_line "$p" 'old mode 100644' && has_line "$p" 'new mode 100755'; then
  ok '브랜치 수집: patch에 수정 줄·삭제 줄·미추적 새 파일 내용·모드 변경 행 통과'
else
  ng "브랜치 수집: patch에 수정 줄·삭제 줄·미추적 새 파일 내용·모드 변경 행 [$(show "$p")]"
fi
if has_line "$(list_of)" "A${TAB}새 파일.txt" && ! printf '%s\n' "$(list_of)" | grep -qF '\'; then
  ok '브랜치 수집: 한글 경로가 이스케이프 없이 나옴 통과'
else
  ng "브랜치 수집: 한글 경로가 이스케이프 없이 나옴 [$(show "$(list_of)")]"
fi
collect "$r1/.ai/99_workspace" --base main
if [ "$rc" = 0 ] && [ -n "$out" ] && [ "$out" = "$top_out" ]; then ok '브랜치 수집: 하위 디렉토리에서 불러도 같은 출력 통과'
else ng "브랜치 수집: 하위 디렉토리에서 불러도 같은 출력 (rc=${rc})"; fi
before="$(fp "$r1")"; collect "$r1" --base main; after="$(fp "$r1")"
if [ "$rc" = 0 ] && [ "$before" = "$after" ]; then ok '브랜치 수집: 실행 전후 .git 아래 파일의 목록·내용 그대로 통과'
else ng "브랜치 수집: 실행 전후 .git 아래 파일의 목록·내용 그대로 (rc=${rc})"; fi

g "$r1" add -A -- . ':(exclude).ai/99_workspace'
chk_index '전부 스테이징'
g "$r1" reset; g "$r1" rm -r --cached .
chk_index '전부 인덱스에서 지움'
g "$r1" reset; g "$r1" rm --cached edit.txt; g "$r1" add copy.txt
chk_index '인덱스에서 지운 파일과 같은 내용의 새 파일 스테이징'
g "$r1" reset; printf 'changed\n' > "$r1/staged.txt"; g "$r1" add staged.txt; printf 'same\n' > "$r1/staged.txt"
if [ "$(git -C "$r1" status --porcelain -- staged.txt)" = 'MM staged.txt' ]; then chk_index '스테이징 뒤 작업 트리만 되돌림'
else ng '브랜치 수집: 인덱스 상태 [스테이징 뒤 작업 트리만 되돌림] 상태를 만들지 못함'; fi

# 분할 인덱스: 임시 인덱스를 쓸 때 원본 .git 에 공유 인덱스 파일(sharedindex.*)이 새로 생기지 않아야 한다.
g "$r1" reset; g "$r1" config core.splitIndex true; g "$r1" config splitIndex.maxPercentChange 0; g "$r1" update-index --split-index
if ! find "$r1/.git" -name 'sharedindex.*' | grep -q .; then
  ng '브랜치 수집: 분할 인덱스 상태를 만들지 못함'
else
  before="$(fp "$r1")"; collect "$r1" --base main; after="$(fp "$r1")"
  if [ "$rc" = 0 ] && [ "$(list_of)" = "$want1" ] && [ "$before" = "$after" ]; then
    ok '브랜치 수집: 분할 인덱스 저장소에서 목록 같고 .git 그대로 통과'
  else ng "브랜치 수집: 분할 인덱스 저장소에서 목록 같고 .git 그대로 (rc=${rc} [$(show "$(list_of)")])"; fi
fi

# 훅: 인덱스를 쓸 때 도는 훅(post-index-change)이 임시 인덱스에 쓸 때도 불리지 않아야 한다.
# 헬퍼를 부르기 전에 훅이 도는지 보고, 부른 뒤에도 사용자의 스테이징에서 훅이 도는지(설정을 바꿔 끄지 않았는지) 본다.
mkdir -p "$r1/.git/hooks"
printf '#!/bin/sh\necho run >> "%s"\n' "$r1/.git/hook.log" > "$r1/.git/hooks/post-index-change"
chmod +x "$r1/.git/hooks/post-index-change"
g "$r1" add edit.txt; g "$r1" reset
if [ ! -s "$r1/.git/hook.log" ]; then
  ng '브랜치 수집: 인덱스를 쓸 때 훅이 도는 상태를 만들지 못함'
else
  before="$(fp "$r1")"; collect "$r1" --base main; after="$(fp "$r1")"; got="$(list_of)"
  n="$(grep -c . "$r1/.git/hook.log")"; g "$r1" add edit.txt; g "$r1" reset
  if [ "$rc" = 0 ] && [ "$got" = "$want1" ] && [ "$before" = "$after" ] && [ "$(grep -c . "$r1/.git/hook.log")" -gt "$n" ]; then
    ok '브랜치 수집: 인덱스 훅을 둔 저장소에서 훅이 돌지 않고 목록 같음 통과'
  else ng "브랜치 수집: 인덱스 훅을 둔 저장소에서 훅이 돌지 않고 목록 같음 (rc=${rc} [$(show "$got")])"; fi
fi

# 파일 시스템 감시: core.fsmonitor 에 건 조회 훅이 헬퍼의 git 명령에서 불리지 않아야 한다.
# 조회 훅은 .git 아래 파일에 한 줄을 더하고 실패로 끝난다(실패하면 Git 은 작업 트리를 직접 훑는다).
printf '#!/bin/sh\necho run >> "%s"\nexit 1\n' "$r1/.git/fsm.log" > "$r1/.git/fsm.sh"
chmod +x "$r1/.git/fsm.sh"; g "$r1" config core.fsmonitor "$r1/.git/fsm.sh"
g "$r1" status
if [ ! -s "$r1/.git/fsm.log" ]; then
  ng '브랜치 수집: 파일 시스템 감시의 조회 훅이 도는 상태를 만들지 못함'
else
  before="$(fp "$r1")"; collect "$r1" --base main; after="$(fp "$r1")"; got="$(list_of)"; rc_base="$rc"
  before2="$(fp "$r1")"; collect "$r1" --marked; after2="$(fp "$r1")"
  if [ "$rc_base" = 0 ] && [ "$got" = "$want1" ] && [ "$before" = "$after" ] && [ "$rc" = 0 ] && [ "$before2" = "$after2" ]; then
    ok '브랜치 수집: 파일 시스템 감시 저장소에서 --base·--marked가 .git 그대로 통과'
  else ng "브랜치 수집: 파일 시스템 감시 저장소에서 --base·--marked가 .git 그대로 (rc=${rc_base}/${rc} [$(show "$got")])"; fi
fi

# merge-base 해시: 해시를 넘기면 base 브랜치가 움직여도 출력이 같다. 옮긴 뒤 이름을 넘긴 출력이 달라졌는지 먼저 본다.
mbh="$(git -C "$r1" merge-base main HEAD)"
collect "$r1" --base main;   by_name="$out"
collect "$r1" --base "$mbh"; by_hash="$out"
g "$r1" branch -f main work
collect "$r1" --base main;   moved_name="$out"
collect "$r1" --base "$mbh"; moved_hash="$out"
if [ "$moved_name" = "$by_name" ]; then
  ng '브랜치 수집: base 브랜치를 옮겨도 이름을 넘긴 출력이 그대로라 merge-base 해시 사례를 만들지 못함'
elif [ -n "$by_hash" ] && [ "$by_hash" = "$by_name" ] && [ "$moved_hash" = "$by_hash" ]; then
  ok '브랜치 수집: merge-base 해시를 넘기면 base 브랜치가 움직여도 출력 같음 통과'
else
  ng '브랜치 수집: merge-base 해시를 넘기면 base 브랜치가 움직여도 출력 같음'
fi

# 변경 없음
r0="$tmpdir/bc-clean"
{ newrepo "$r0" && printf 'a\n' > "$r0/a.txt" && g "$r0" add -A && g "$r0" commit -m base && g "$r0" checkout -b work; } \
  || ng '브랜치 수집: 변경 없는 저장소를 만들지 못함'
collect "$r0" --base main
if [ "$rc" = 0 ] && [ -z "$out" ]; then ok '브랜치 수집: 변경이 없으면 종료 코드 0·빈 표준 출력 통과'
else ng "브랜치 수집: 변경이 없으면 종료 코드 0·빈 표준 출력 (rc=${rc} out=[$(show "$out")])"; fi

# Git 이 스테이징 내용을 정하는 경로: 무시 규칙에 걸린 파일과 .ai/99_workspace/ 아래 파일은 인덱스에 있을 때만 들어간다.
r2="$tmpdir/bc-rules"
{ newrepo "$r2" && printf '*.log\n' > "$r2/.gitignore" && printf 'a\n' > "$r2/a.txt" && printf 'tracked\n' > "$r2/tracked.log" \
  && mkdir -p "$r2/.ai/99_workspace" && printf 'ws\n' > "$r2/.ai/99_workspace/tracked.md" \
  && g "$r2" add -A && g "$r2" add -f tracked.log && g "$r2" commit -m base && g "$r2" checkout -b work; } \
  || ng '브랜치 수집: 경로 규칙 저장소를 만들지 못함'
# assert_list <저장소> <설명> <기대 행…> — 목록 전체가 기대와 같은가
assert_list() {
  local r="$1" desc="$2" want got; shift 2
  want="$(want_rows "$@")"
  collect "$r" --base main; got="$(list_of)"
  if [ "$rc" = 0 ] && [ "$got" = "$want" ]; then ok "$desc"; else ng "$desc (rc=${rc} [$(show "$got")])"; fi
}
printf 'changed\n' >> "$r2/.ai/99_workspace/tracked.md"; printf 'new\n' > "$r2/.ai/99_workspace/new.md"
assert_list "$r2" '브랜치 수집: .ai/99_workspace 미추적 파일 빠지고 추적 파일 수정 들어감 통과' "M${TAB}.ai/99_workspace/tracked.md"
g "$r2" checkout -- .ai/99_workspace/tracked.md; rm -f "$r2/.ai/99_workspace/new.md"
printf 'noise\n' > "$r2/debug.log"; printf 'forced\n' > "$r2/forced.log"; g "$r2" add -f forced.log
assert_list "$r2" '브랜치 수집: 무시 규칙 미추적 파일 빠지고 강제로 추가한 파일 들어감 통과' "A${TAB}forced.log"
g "$r2" rm --cached forced.log; rm -f "$r2/forced.log" "$r2/debug.log"
printf 'more\n' >> "$r2/tracked.log"; g "$r2" rm --cached tracked.log
assert_list "$r2" '브랜치 수집: 추적하던 무시 파일을 고쳐 인덱스에서만 지우면 삭제 1건 통과' "D${TAB}tracked.log"
g "$r2" reset; g "$r2" checkout -- tracked.log
printf 'more\n' >> "$r2/.ai/99_workspace/tracked.md"; g "$r2" rm --cached .ai/99_workspace/tracked.md
assert_list "$r2" '브랜치 수집: 추적하던 .ai/99_workspace 파일을 고쳐 인덱스에서만 지우면 삭제 1건 통과' "D${TAB}.ai/99_workspace/tracked.md"

# 변경을 보지 않도록 표시한 경로: 인덱스의 내용을 쓴다. 수정본을 스테이징한 뒤 작업 트리를 되돌리고 표시한 파일은
# 수정 1건과 인덱스의 수정 줄로 나오고, 작업 트리만 고치고 표시한 파일은 나오지 않는다.
r3="$tmpdir/bc-hidden"
{ newrepo "$r3" && for f in hidden-a hidden-s local-a local-s; do printf '%s\n' "$f" > "$r3/${f}.txt"; done \
  && g "$r3" add -A && g "$r3" commit -m base && g "$r3" checkout -b work; } || ng '브랜치 수집: 표시한 경로 저장소를 만들지 못함'
for k in a s; do
  printf 'index only %s\n' "$k" >> "$r3/hidden-${k}.txt"; g "$r3" add "hidden-${k}.txt"; printf 'hidden-%s\n' "$k" > "$r3/hidden-${k}.txt"
done
g "$r3" update-index --assume-unchanged hidden-a.txt local-a.txt; g "$r3" update-index --skip-worktree hidden-s.txt local-s.txt
printf 'local only\n' >> "$r3/local-a.txt"; printf 'local only\n' >> "$r3/local-s.txt"
collect "$r3" --base main
want3="$(want_rows "M${TAB}hidden-a.txt" "M${TAB}hidden-s.txt")"
for k in a s; do
  case "$k" in (a) kind='assume-unchanged' ;; (s) kind='skip-worktree' ;; esac
  if [ "$rc" = 0 ] && [ "$(list_of)" = "$want3" ] && has_line "$(file_patch "hidden-${k}.txt")" "+index only ${k}" \
     && ! printf '%s\n' "$out" | grep -qF "local-${k}.txt"; then
    ok "브랜치 수집: ${kind} 표시 경로는 인덱스 내용만 나옴 통과"
  else ng "브랜치 수집: ${kind} 표시 경로는 인덱스 내용만 나옴 (rc=${rc} [$(show "$(list_of)")])"; fi
done

# 커밋 대조: 같은 작업 트리를 사본에서 실제로 전부 스테이징해 커밋한 트리와 견준다. 기대 목록은 diff 계열 명령 없이
# 두 트리의 ls-tree 행으로 만들고, merge-base 트리에 헬퍼의 patch 를 적용한 트리가 커밋한 트리와 같은지도 본다.
# 하위 모듈(ignore = all), 내용 변환 필터, 표시한 경로, 사용자 diff 설정을 한 저장소에 둔다. 바이너리 파일은 넣지 않는다.

# commit_copy <저장소> — 사본에서 전부 스테이징해 커밋한다. 사본 경로는 cc_dir, merge-base 는 cc_mb 에 남긴다
commit_copy() {
  cc_dir="$(mktemp -d "$tmpdir/copy.XXXXXX")" && cp -Rp "$1/." "$cc_dir/" \
    && cc_mb="$(git -C "$cc_dir" merge-base main HEAD)" \
    && git -C "$cc_dir" add -u >/dev/null 2>&1 \
    && git -C "$cc_dir" add -A -- . ':(exclude).ai/99_workspace' >/dev/null 2>&1 \
    && git -C "$cc_dir" commit -q --allow-empty --no-verify -m snapshot >/dev/null 2>&1
}
# tree_diff — 사본의 커밋한 트리와 merge-base 트리의 차이(정렬한 목록). 경로가 한쪽에만 있으면 A·D,
# 모드나 객체 ID 가 다르면 M, 모드의 앞 두 자리(파일 10·링크 12·하위 모듈 16)가 다르면 T
tree_diff() {
  { git -C "$cc_dir" -c core.quotePath=false ls-tree -r "$cc_mb" | sed 's/^/B /'
    git -C "$cc_dir" -c core.quotePath=false ls-tree -r HEAD | sed 's/^/S /'; } \
    | awk -F'\t' '{ split($1, a, " "); if (a[1] == "B") { bm[$2] = a[2]; bo[$2] = a[4] } else { sm[$2] = a[2]; so[$2] = a[4] }; seen[$2] = 1 }
        END { for (p in seen) {
          if (!(p in bm)) print "A\t" p
          else if (!(p in sm)) print "D\t" p
          else if (bm[p] != sm[p] || bo[p] != so[p]) print (substr(bm[p], 1, 2) == substr(sm[p], 1, 2) ? "M" : "T") "\t" p } }' \
    | LC_ALL=C sort
}
# patched_tree — merge-base 트리에 out 의 patch 를 적용한 트리의 ID (사본의 임시 인덱스에서 만든다)
patched_tree() {
  patch_of > "$cc_dir/.git/patch.tmp"
  GIT_INDEX_FILE="$cc_dir/.git/index.tmp" git -C "$cc_dir" read-tree "$cc_mb" 2>/dev/null \
    && GIT_INDEX_FILE="$cc_dir/.git/index.tmp" git -C "$cc_dir" apply --cached "$cc_dir/.git/patch.tmp" 2>/dev/null \
    && GIT_INDEX_FILE="$cc_dir/.git/index.tmp" git -C "$cc_dir" write-tree 2>/dev/null
}
# same_case <상태 이름> — 헬퍼 목록 = 커밋한 트리의 차이, patch 적용 트리 = 커밋한 트리. 헬퍼 출력은 out 에 남는다
same_case() {
  local got want pt ct
  collect "$r4" --base main; got="$(list_of)"
  if ! commit_copy "$r4"; then ng "브랜치 수집: 커밋 대조 [$1] 사본에서 커밋하지 못함"; rm -rf "$cc_dir"; return; fi
  want="$(tree_diff)"; pt="$(patched_tree)"; ct="$(git -C "$cc_dir" rev-parse 'HEAD^{tree}')"
  rm -rf "$cc_dir"
  if [ "$rc" = 0 ] && [ -n "$want" ] && [ "$got" = "$want" ] && [ -n "$pt" ] && [ "$pt" = "$ct" ]; then
    ok "브랜치 수집: 커밋 대조 [$1] 목록·patch 적용 트리 같음 통과"
  else
    ng "브랜치 수집: 커밋 대조 [$1] 목록·patch 적용 트리 같음 (rc=${rc} 헬퍼=[$(show "$got")] 커밋=[$(show "$want")] 적용=[${pt}] 커밋 트리=[${ct}])"
  fi
}

r4="$tmpdir/bc-commit"
newrepo "$r4" || ng '브랜치 수집: 커밋 대조 저장소를 만들지 못함'
for f in edit gone hidden-a hidden-s local-a local-s; do printf '%s\n' "$f" > "$r4/${f}.txt"; done
# 내용 변환 필터: 작업 트리는 enabled=false, 커밋되는 내용은 enabled=true
printf 'enabled=false\n' > "$r4/settings.txt"
g "$r4" config filter.flip.clean "sed 's/enabled=false/enabled=true/'"
mkdir -p "$r4/.git/info" && printf 'settings.txt filter=flip\n' > "$r4/.git/info/attributes"
# 하위 모듈: 중첩 저장소를 올리고 .gitmodules 에 ignore = all 을 둔다
{ newrepo "$r4/modules" && printf 'one\n' > "$r4/modules/m.txt" && g "$r4/modules" add -A && g "$r4/modules" commit -m m1; } \
  || ng '브랜치 수집: 하위 모듈 저장소를 만들지 못함'
printf '[submodule "modules"]\n\tpath = modules\n\turl = ./modules\n\tignore = all\n' > "$r4/.gitmodules"
{ g "$r4" add -A && g "$r4" commit -m base && g "$r4" checkout -b work; } || ng '브랜치 수집: 커밋 대조 기준 커밋을 만들지 못함'
sub_old="$(git -C "$r4/modules" rev-parse HEAD)"
printf 'edit\nnew line\n' > "$r4/edit.txt"; rm -f "$r4/gone.txt"; printf 'fresh\n' > "$r4/새 파일.txt"
for k in a s; do
  printf 'index only\n' >> "$r4/hidden-${k}.txt"; g "$r4" add "hidden-${k}.txt"; printf 'hidden-%s\n' "$k" > "$r4/hidden-${k}.txt"
done
g "$r4" update-index --assume-unchanged hidden-a.txt local-a.txt; g "$r4" update-index --skip-worktree hidden-s.txt local-s.txt
printf 'local only\n' >> "$r4/local-a.txt"; printf 'local only\n' >> "$r4/local-s.txt"
same_case '일반 변경과 표시한 경로'

# 내용 변환 필터: 작업 트리의 바이트는 merge-base 의 내용과 다르고 커밋될 내용은 같아 헬퍼 출력에 나오지 않는다.
base_id="$(git -C "$r4" rev-parse 'main:settings.txt')"
if [ "$(git -C "$r4" hash-object --no-filters -- settings.txt)" = "$base_id" ] \
   || [ "$(git -C "$r4" hash-object -- settings.txt)" != "$base_id" ]; then
  ng '브랜치 수집: 내용 변환 필터 상태를 만들지 못함'
elif printf '%s\n' "$out" | grep -qF 'settings.txt'; then
  ng '브랜치 수집: 커밋될 내용이 merge-base 와 같은 필터 파일이 출력에 없음 (출력에 나옴)'
else
  ok '브랜치 수집: 커밋될 내용이 merge-base 와 같은 필터 파일이 출력에 없음 통과'
fi

# 하위 모듈이 새 커밋을 가리킨다. 커밋 이동이 커밋한 트리에 들어가는 상태인지 먼저 본다.
{ printf 'two\n' >> "$r4/modules/m.txt" && g "$r4/modules" commit -am m2; } || ng '브랜치 수집: 하위 모듈 커밋을 만들지 못함'
sub_new="$(git -C "$r4/modules" rev-parse HEAD)"
sub_moved=0
if commit_copy "$r4" && has_line "$(tree_diff)" "M${TAB}modules"; then sub_moved=1; fi
rm -rf "$cc_dir"
if [ "$sub_moved" = 1 ]; then
  same_case '하위 모듈 커밋 이동'
  p="$(patch_of)"
  if has_line "$(list_of)" "M${TAB}modules" && has_line "$p" "-Subproject commit ${sub_old}" && has_line "$p" "+Subproject commit ${sub_new}"; then
    ok '브랜치 수집: 하위 모듈 커밋 이동이 목록 1행과 patch 두 커밋 행으로 나옴 통과'
  else ng "브랜치 수집: 하위 모듈 커밋 이동이 목록 1행과 patch 두 커밋 행으로 나옴 [$(show "$(list_of)")]"; fi
else
  ng '브랜치 수집: 하위 모듈의 커밋 이동이 커밋한 트리에 들어가는 상태를 만들지 못함'
fi

# 사용자 diff 설정: 설정을 두기 전과 헬퍼의 표준 출력이 같다. diff 드라이버의 command·textconv 는 실패하게 둔다.
plain_out="$out"
printf '*.txt diff=custom\n' >> "$r4/.git/info/attributes"   # 필터 행은 지우지 않는다
for kv in 'diff.noprefix true' 'diff.mnemonicPrefix true' 'diff.renames copies' 'diff.ignoreSubmodules all' \
          'diff.external false' 'diff.context 0' 'diff.relative true' 'color.ui always' \
          'diff.custom.command false' 'diff.custom.textconv false'; do
  g "$r4" config ${kv% *} "${kv#* }" || ng "브랜치 수집: 사용자 diff 설정을 두지 못함 [${kv}]"
done
same_case '사용자 diff 설정'
if [ -n "$plain_out" ] && [ "$out" = "$plain_out" ]; then ok '브랜치 수집: 사용자 diff 설정을 둬도 표준 출력이 같음 통과'
else ng '브랜치 수집: 사용자 diff 설정을 둬도 표준 출력이 같음'; fi

# 하위 모듈이 기준 커밋으로 돌아가고 안에 커밋하지 않은 변경(수정, 미추적 파일)만 있다.
{ g "$r4/modules" checkout "$sub_old" && printf 'dirty\n' > "$r4/modules/untracked.txt" && printf 'dirty\n' >> "$r4/modules/m.txt"; } \
  || ng '브랜치 수집: 하위 모듈을 기준 커밋으로 되돌리지 못함'
same_case '하위 모듈 내부 미커밋'
if [ "$(git -C "$r4/modules" rev-parse HEAD)" = "$sub_old" ] && [ -n "$(git -C "$r4/modules" status --porcelain)" ] \
   && ! printf '%s\n' "$out" | awk 'NF==0{exit} {print}' | grep -qF "modules"; then
  ok '브랜치 수집: 커밋이 같고 안에 미커밋 변경만 있는 하위 모듈은 목록에 없음 통과'
else ng "브랜치 수집: 커밋이 같고 안에 미커밋 변경만 있는 하위 모듈은 목록에 없음 [$(show "$(list_of)")]"; fi

# 경로 표기: 큰따옴표로 시작하지 않는 경로는 실제 경로이고, 이름에 줄바꿈이 들었거나 큰따옴표로 시작하는 경로만
# Git 의 인용 표기 한 행으로 나온다. 기대 이름은 파일을 만든 이름 그대로 적는다(Git 의 줄 단위 출력으로 만들지 않는다).
# 기준 줄은 파일마다 다르고 숫자로 시작한다(영문자로 시작하면 Git 이 hunk 머리 행에 싣는다).
r5="$tmpdir/bc-paths"
newrepo "$r5" || ng '브랜치 수집: 경로 표기 저장소를 만들지 못함'
pn_names() { printf '%s\n' 'quo"te.txt' 'back\slash.txt' "tab${TAB}name.txt"; }
pn_nl="$(printf 'line\nfeed.txt')"; pn_lit='"line\nfeed.txt"'
pn_mk() { printf '%s marker\n2\n3\n4\n5\n6\n' "$(mark_of "$1")" > "$r5/$1"; }
{ pn_names; printf '%s\n' "$pn_lit"; } | while IFS= read -r f; do pn_mk "$f"; done
pn_mk "$pn_nl"
{ g "$r5" add -A && g "$r5" commit -m base && g "$r5" checkout -b work; } || ng '브랜치 수집: 경로 표기 기준 커밋을 만들지 못함'
{ pn_names; printf '%s\n' "$pn_lit"; } | while IFS= read -r f; do printf 'added\n' >> "$r5/$f"; done
printf 'added\n' >> "$r5/$pn_nl"
pn_mb="$(git -C "$r5" merge-base main HEAD)"
want5="$( { pn_names | sed "s/^/M${TAB}/"; printf "M${TAB}%s\n" '"line\nfeed.txt"' '"\"line\\nfeed.txt\""'; } | LC_ALL=C sort)"
collect "$r5" --base main
list5="$(printf '%s\n' "$out" | awk 'NF==0{exit} {print}')"
if [ "$rc" = 0 ] && [ "$(printf '%s\n' "$list5" | LC_ALL=C sort)" = "$want5" ]; then
  ok '브랜치 수집: 경로 표기 목록이 실제 경로 3행과 서로 다른 인용 표기 2행 통과'
else ng "브랜치 수집: 경로 표기 목록이 실제 경로 3행과 서로 다른 인용 표기 2행 (rc=${rc} [$(show "$list5")])"; fi
printf '%s\n' "$list5" > "$tmpdir/list5"
read_ok=0; read_bad=0
while IFS= read -r row; do
  pp="${row#*${TAB}}"
  case "$pp" in ('"'*) continue ;; esac
  if git -C "$r5" show "${pn_mb}:${pp}" 2>/dev/null | grep -qxF "$(mark_of "$pp") marker"; then read_ok=$((read_ok + 1)); else read_bad=$((read_bad + 1)); fi
done < "$tmpdir/list5"
if [ "$read_ok" = 3 ] && [ "$read_bad" = 0 ]; then ok '브랜치 수집: 실제 경로를 그대로 넘겨 merge-base 의 그 파일 기준 줄을 읽음 통과'
else ng "브랜치 수집: 실제 경로를 그대로 넘겨 merge-base 의 그 파일 기준 줄을 읽음 (읽음 ${read_ok}·실패 ${read_bad})"; fi
if [ "$rc" = 0 ] && [ -n "$(patch_of)" ] && ! patch_of | grep -qF 'marker'; then
  ok '브랜치 수집: 경로 표기 사례의 기준 줄이 patch 본문·머리 행에 없음 통과'
else ng '브랜치 수집: 경로 표기 사례의 기준 줄이 patch 본문·머리 행에 없음 (patch에 있거나 patch가 비어 있음)'; fi

# 표시한 경로(--marked): 표지는 NUL 구분 레코드마다 판정한다. 표시하지 않은 파일의 이름에 줄바꿈과 `h ` 를 두고,
# 이름에 줄바꿈이 든 표시한 파일과 그 인용 표기를 실제 이름으로 쓰는 표시한 파일을 함께 둔다. 인덱스 조회는 `:0:` 를 붙인다.
r6="$tmpdir/bc-marked"
newrepo "$r6" || ng '브랜치 수집: 표시한 경로 조회 저장소를 만들지 못함'
mk_nl="$(printf 'line\nfeed.txt')"; mk_nlu="$(printf 'foo\nh bar.txt')"; mk_lit='"line\nfeed.txt"'
for f in plain.txt hidden-a.txt hidden-s.txt '2:x.txt' "$mk_nl" "$mk_nlu" "$mk_lit"; do printf 'base\n' > "$r6/$f"; done
{ g "$r6" add -A && g "$r6" commit -m base; } || ng '브랜치 수집: 표시한 경로 조회 기준 커밋을 만들지 못함'
collect "$r6" --marked
if [ "$rc" = 0 ] && [ -z "$out" ]; then ok '브랜치 수집: 표시한 경로가 없으면 --marked 종료 코드 0·빈 표준 출력 통과'
else ng "브랜치 수집: 표시한 경로가 없으면 --marked 종료 코드 0·빈 표준 출력 (rc=${rc} [$(show "$out")])"; fi
for f in hidden-a.txt hidden-s.txt '2:x.txt' "$mk_nl" "$mk_lit"; do
  printf 'index only %s\n' "$(mark_of "$f")" >> "$r6/$f"; g "$r6" add -- "$f"; printf 'base\n' > "$r6/$f"
done
{ g "$r6" update-index --assume-unchanged -- hidden-a.txt && g "$r6" update-index --skip-worktree -- hidden-s.txt '2:x.txt' "$mk_nl" "$mk_lit"; } \
  || ng '브랜치 수집: 변경을 보지 않도록 표시하지 못함'
want6="$(printf '%s\n' 'h hidden-a.txt' 'S hidden-s.txt' 'S 2:x.txt' 'S "line\nfeed.txt"' 'S "\"line\\nfeed.txt\""' | LC_ALL=C sort)"
before="$(fp "$r6")"; collect "$r6" --marked; after="$(fp "$r6")"
if [ "$rc" = 0 ] && [ "$(printf '%s\n' "$out" | LC_ALL=C sort)" = "$want6" ] && [ "$before" = "$after" ]; then
  ok '브랜치 수집: --marked가 표시한 경로만 표지와 함께 내고 .git 그대로 통과'
else ng "브랜치 수집: --marked가 표시한 경로만 표지와 함께 내고 .git 그대로 (rc=${rc} [$(show "$out")])"; fi
if has_line "$out" 'S "line\nfeed.txt"' && has_line "$out" 'S "\"line\\nfeed.txt\""' && ! printf '%s\n' "$out" | grep -qF 'bar.txt'; then
  ok '브랜치 수집: --marked가 줄바꿈 이름의 표시 파일만 서로 다른 인용 표기로 냄 통과'
else ng "브랜치 수집: --marked가 줄바꿈 이름의 표시 파일만 서로 다른 인용 표기로 냄 [$(show "$out")]"; fi
printf '%s\n' "$out" > "$tmpdir/marked6"
read_ok=0; read_bad=0; saw_stage_name=0
while IFS= read -r row; do
  pp="${row#* }"
  case "$pp" in ('"'*) continue ;; esac
  [ "$pp" = '2:x.txt' ] && saw_stage_name=1
  if git -C "$r6" show ":0:${pp}" 2>/dev/null | grep -qxF "index only $(mark_of "$pp")"; then read_ok=$((read_ok + 1)); else read_bad=$((read_bad + 1)); fi
done < "$tmpdir/marked6"
if [ "$read_ok" = 3 ] && [ "$read_bad" = 0 ] && [ "$saw_stage_name" = 1 ]; then
  ok '브랜치 수집: 표시한 실제 경로를 그대로 넘겨 :0: 인덱스 내용을 읽음 통과'
else ng "브랜치 수집: 표시한 실제 경로를 그대로 넘겨 :0: 인덱스 내용을 읽음 (읽음 ${read_ok}·실패 ${read_bad}·2:x.txt ${saw_stage_name})"; fi

# 호출 환경의 Git 환경 변수(최종 감사 1차 F-4·F-5): 헬퍼가 적은 pathspec·patch 형식의 해석을 바꾸는 변수가 호출 셸에
# 있어도, 대체 객체 디렉토리를 환경 변수로 준 저장소에서도 출력이 그 변수가 없을 때와 같다. 변수가 실제로 Git 의
# 동작을 바꾸는 사례인지 먼저 본다(GLOB·NOGLOB·ICASE 는 이 저장소에서 차이가 드러나지 않아 출력만 견준다).
r7="$tmpdir/bc-env"
{ newrepo "$r7" && printf '1\n2\n3\n4\n5\n6\n7\n' > "$r7/n.txt" && mkdir -p "$r7/.ai/99_workspace" \
  && printf 'w\n' > "$r7/.ai/99_workspace/tracked.md" && g "$r7" add -A && g "$r7" commit -m base && g "$r7" checkout -b work; } \
  || ng '브랜치 수집: 환경 변수 저장소를 만들지 못함'
printf '1\n2\n3\nfour\n5\n6\n7\n' > "$r7/n.txt"; printf 'more\n' >> "$r7/.ai/99_workspace/tracked.md"
printf 'x\n' > "$r7/.ai/99_workspace/untracked.md"; printf 'n\n' > "$r7/new.txt"
collect "$r7" --base main; env_base="$out"
want7="$(want_rows "A${TAB}new.txt" "M${TAB}.ai/99_workspace/tracked.md" "M${TAB}n.txt")"
if [ "$rc" = 0 ] && [ "$(list_of)" = "$want7" ] && has_line "$(patch_of)" '@@ -1,7 +1,7 @@'; then
  ok '브랜치 수집: 환경 변수 사례의 기준 출력(작업공간 미추적 파일 빠지고 추적 파일 수정 들어감, 맥락 줄 3) 통과'
else ng "브랜치 수집: 환경 변수 사례의 기준 출력 (rc=${rc} [$(show "$(list_of)")])"; fi
# env_case <설명> <변수=값…> — 그 변수를 둔 호출 셸에서 헬퍼의 표준 출력이 기준 출력과 같은가
env_case() {
  local desc="$1"; shift
  out="$(cd "$r7" && env "$@" "$COLLECT" --base main 2> "$tmpdir/collect.err")"; rc=$?
  if [ "$rc" = 0 ] && [ -n "$env_base" ] && [ "$out" = "$env_base" ]; then ok "브랜치 수집: ${desc} 출력이 변수 없을 때와 같음 통과"
  else ng "브랜치 수집: ${desc} 출력이 변수 없을 때와 같음 (rc=${rc} $(head -n 1 "$tmpdir/collect.err"))"; fi
}
if (cd "$r7" && GIT_LITERAL_PATHSPECS=1 git add -n -A -- . ':(exclude).ai/99_workspace' >/dev/null 2>&1); then
  ng '브랜치 수집: GIT_LITERAL_PATHSPECS 가 pathspec 매직을 끄는 상태를 만들지 못함'
else env_case 'GIT_LITERAL_PATHSPECS=1' GIT_LITERAL_PATHSPECS=1; fi
env_case 'GIT_GLOB_PATHSPECS=1' GIT_GLOB_PATHSPECS=1
env_case 'GIT_NOGLOB_PATHSPECS=1' GIT_NOGLOB_PATHSPECS=1
env_case 'GIT_ICASE_PATHSPECS=1' GIT_ICASE_PATHSPECS=1
if ! (cd "$r7" && GIT_DIFF_OPTS=-u0 git diff-index -p HEAD -- n.txt 2>/dev/null) | grep -qxF '@@ -4 +4 @@'; then
  ng '브랜치 수집: GIT_DIFF_OPTS 가 맥락 줄 수를 바꾸는 상태를 만들지 못함'
else env_case 'GIT_DIFF_OPTS=-u0' GIT_DIFF_OPTS=-u0; fi
# 대체 객체 디렉토리: r8 의 객체는 환경 변수로 준 r7 의 객체 디렉토리에만 있다. 작업 트리는 r7 과 같게 맞춘다.
r8="$tmpdir/bc-alt"
alt_env="GIT_ALTERNATE_OBJECT_DIRECTORIES=${r7}/.git/objects"
{ newrepo "$r8" \
  && env "$alt_env" git -C "$r8" update-ref refs/heads/main "$(git -C "$r7" rev-parse main)" \
  && env "$alt_env" git -C "$r8" update-ref refs/heads/work "$(git -C "$r7" rev-parse work)" \
  && git -C "$r8" symbolic-ref HEAD refs/heads/work && env "$alt_env" git -C "$r8" reset -q --hard work \
  && cp -p "$r7/n.txt" "$r7/new.txt" "$r8/" && mkdir -p "$r8/.ai/99_workspace" \
  && cp -p "$r7/.ai/99_workspace/tracked.md" "$r7/.ai/99_workspace/untracked.md" "$r8/.ai/99_workspace/"; } >/dev/null 2>&1 \
  || ng '브랜치 수집: 대체 객체 디렉토리 저장소를 만들지 못함'
if git -C "$r8" rev-parse --verify --quiet 'main^{tree}' >/dev/null 2>&1; then
  ng '브랜치 수집: 객체가 환경 변수로 준 대체 객체 디렉토리에만 있는 상태를 만들지 못함'
else
  out="$(cd "$r8" && env "$alt_env" "$COLLECT" --base main 2> "$tmpdir/collect.err")"; rc=$?
  if [ "$rc" = 0 ] && [ -n "$env_base" ] && [ "$out" = "$env_base" ]; then
    ok '브랜치 수집: 환경 변수로 준 대체 객체 디렉토리에만 객체가 있어도 출력 같음 통과'
  else ng "브랜치 수집: 환경 변수로 준 대체 객체 디렉토리에만 객체가 있어도 출력 같음 (rc=${rc} $(head -n 1 "$tmpdir/collect.err"))"; fi
fi

# Git 이 바이너리로 보는 텍스트 파일(최종 감사 1차 F-2): 목록에 나오고 patch 에는 `Binary files` 행만 나온다.
# 같은 파일이 설정 전에는 텍스트 patch 로 나오는지 먼저 본다.
r9="$tmpdir/bc-binary"
{ newrepo "$r9" && printf 'keep\n' > "$r9/keep.txt" && g "$r9" add -A && g "$r9" commit -m base && g "$r9" checkout -b work; } \
  || ng '브랜치 수집: 바이너리 판정 저장소를 만들지 못함'
printf 'print(123456789)\n' > "$r9/job.py"
collect "$r9" --base main; text_patch="$(patch_of)"
g "$r9" config core.bigFileThreshold 8
collect "$r9" --base main
if ! has_line "$text_patch" '+print(123456789)'; then
  ng '브랜치 수집: 설정 전에 텍스트 patch 로 나오는 파일을 만들지 못함'
elif [ "$rc" = 0 ] && [ "$(list_of)" = "A${TAB}job.py" ] && has_line "$(patch_of)" 'Binary files /dev/null and b/job.py differ' \
     && ! patch_of | grep -qF 'print('; then
  ok '브랜치 수집: Git 이 바이너리로 보는 텍스트 파일이 목록에 나오고 patch 에 Binary files 행만 나옴 통과'
else ng "브랜치 수집: Git 이 바이너리로 보는 텍스트 파일이 목록에 나오고 patch 에 Binary files 행만 나옴 (rc=${rc} [$(show "$(patch_of)")])"; fi

# 작업 트리 안의 임시 디렉토리(최종 감사 2차 F-9): GNU mktemp 는 TMPDIR 을 따라 작업 트리 안에 임시 디렉토리를 만든다.
# macOS 의 mktemp 는 TMPDIR 을 보지 않으므로, TMPDIR 을 따르는 대체 mktemp 를 PATH 앞에 두어 같은 상태를 만든다.
rt="$tmpdir/bc-tmpdir"; shim="$tmpdir/shim"; real_mktemp="$(command -v mktemp)"
{ newrepo "$rt" && printf 'a\n' > "$rt/tracked.txt" && g "$rt" add -A && g "$rt" commit -m base && mkdir -p "$rt/scratch" "$shim" \
  && printf '#!/bin/sh\nexec %s -d "${TMPDIR:-/tmp}/tmp.XXXXXXXXXX"\n' "'$real_mktemp'" > "$shim/mktemp" && chmod +x "$shim/mktemp"; } \
  || ng '브랜치 수집: 임시 디렉토리 저장소를 만들지 못함'
probe="$(PATH="$shim:$PATH" TMPDIR="$rt/scratch" mktemp -d 2>/dev/null)"
case "$probe" in
  ("$rt/scratch/"*)
    rmdir "$probe"
    out="$(cd "$rt" && PATH="$shim:$PATH" TMPDIR="$rt/scratch" "$COLLECT" --base main 2> "$tmpdir/collect.err")"; rc=$?
    if [ "$rc" = 0 ] && [ -z "$out" ] && [ -z "$(ls -A "$rt/scratch")" ]; then
      ok '브랜치 수집: 임시 디렉토리가 작업 트리 안이어도 변경 없는 저장소의 출력이 빔 통과'
    else ng "브랜치 수집: 임시 디렉토리가 작업 트리 안이어도 변경 없는 저장소의 출력이 빔 (rc=${rc} [$(show "$(list_of)")])"; fi
    printf 'u\n' > "$rt/scratch/user.txt"
    out="$(cd "$rt" && PATH="$shim:$PATH" TMPDIR="$rt/scratch" "$COLLECT" --base main 2> "$tmpdir/collect.err")"; rc=$?
    if [ "$rc" = 0 ] && [ "$(list_of)" = "A${TAB}scratch/user.txt" ] && has_line "$(patch_of)" '+u'; then
      ok '브랜치 수집: 임시 디렉토리와 같은 상위 디렉토리의 사용자 파일은 들어감 통과'
    else ng "브랜치 수집: 임시 디렉토리와 같은 상위 디렉토리의 사용자 파일은 들어감 (rc=${rc} [$(show "$(list_of)")])"; fi ;;
  (*) ng "브랜치 수집: TMPDIR 을 따르는 mktemp 로 작업 트리 안에 임시 디렉토리를 만드는 상태를 만들지 못함 [${probe}]" ;;
esac

# 헬퍼가 부른 프로그램이 TMPDIR 에 남기는 파일(최종 감사 3차 F-12): macOS 의 git 실행기는 환경에 따라 TMPDIR 에 캐시를 남긴다.
# 부를 때마다 TMPDIR 에 파일을 남기는 대역 git 을 PATH 앞에 두어 같은 상태를 만든다. 헬퍼는 부르는 프로그램의 TMPDIR 을
# 자기 임시 디렉토리로 지정하므로, 그 파일이 목록에 나오지 않고 호출 뒤 작업 트리에도 남지 않는다.
rl="$tmpdir/bc-launcher"; gshim="$tmpdir/gshim"; real_git="$(command -v git)"
{ newrepo "$rl" && printf 'a\n' > "$rl/tracked.txt" && printf 'h\n' > "$rl/hidden.txt" && mkdir -p "$rl/sub" && printf 's\n' > "$rl/sub/keep.txt" \
  && g "$rl" add -A && g "$rl" commit -m base && g "$rl" update-index --assume-unchanged hidden.txt \
  && mkdir -p "$rl/scratch" "$gshim" "$tmpdir/gprobe" \
  && printf '#!/bin/sh\n: > "${TMPDIR:-/tmp}/launcher_cache"\nexec %s "$@"\n' "'$real_git'" > "$gshim/git" && chmod +x "$gshim/git"; } \
  || ng '브랜치 수집: 실행기 캐시 저장소를 만들지 못함'
# launcher_run <PATH 앞에 둘 디렉토리> <호출 디렉토리> <TMPDIR> <헬퍼 인자…> — 대역 git 으로 헬퍼를 불러 out·rc 와 scratch/ 에 남은 이름(left)을 남긴다
launcher_run() {
  local pre="$1" dir="$2" td="$3"; shift 3
  out="$(cd "$dir" && PATH="${pre}:${PATH}" TMPDIR="$td" "$COLLECT" "$@" 2> "$tmpdir/collect.err")"; rc=$?
  left="$(ls -A "$rl/scratch" | tr '\n' ' ')"
}
(PATH="${gshim}:${PATH}" TMPDIR="$tmpdir/gprobe" git --version >/dev/null 2>&1)
if [ ! -e "$tmpdir/gprobe/launcher_cache" ]; then
  ng '브랜치 수집: 부를 때마다 TMPDIR 에 파일을 남기는 대역 git 상태를 만들지 못함'
else
  launcher_run "$gshim" "$rl" "$rl/scratch" --base main
  if [ "$rc" = 0 ] && [ -z "$out" ] && [ -z "$left" ]; then
    ok '브랜치 수집: 부른 프로그램이 TMPDIR 에 남기는 파일이 목록에 나오지 않고 작업 트리에 남지 않음 통과'
  else ng "브랜치 수집: 부른 프로그램이 TMPDIR 에 남기는 파일이 목록에 나오지 않고 작업 트리에 남지 않음 (rc=${rc} [$(show "$(list_of)")] 남은 파일 [${left}])"; fi
  launcher_run "${gshim}:${shim}" "$rl" "$rl/scratch" --base main
  if [ "$rc" = 0 ] && [ -z "$out" ] && [ -z "$left" ]; then
    ok '브랜치 수집: 임시 디렉토리가 작업 트리 안일 때도 부른 프로그램의 파일이 목록에 나오지 않음 통과'
  else ng "브랜치 수집: 임시 디렉토리가 작업 트리 안일 때도 부른 프로그램의 파일이 목록에 나오지 않음 (rc=${rc} [$(show "$(list_of)")] 남은 파일 [${left}])"; fi
  launcher_run "${gshim}:${shim}" "$rl/sub" ../scratch --base main
  if [ "$rc" = 0 ] && [ -z "$out" ] && [ -z "$left" ]; then
    ok '브랜치 수집: 하위 디렉토리에서 상대 경로 TMPDIR 로 불러도 출력이 비고 작업 트리에 남지 않음 통과'
  else ng "브랜치 수집: 하위 디렉토리에서 상대 경로 TMPDIR 로 불러도 출력이 비고 작업 트리에 남지 않음 (rc=${rc} [$(show "$(list_of)")] 남은 파일 [${left}] $(head -n 1 "$tmpdir/collect.err"))"; fi
  launcher_run "$gshim" "$rl" "$rl/scratch" --marked
  if [ "$rc" = 0 ] && [ "$out" = 'h hidden.txt' ] && [ -z "$left" ]; then
    ok '브랜치 수집: --marked 도 부른 프로그램의 파일을 작업 트리에 남기지 않음 통과'
  else ng "브랜치 수집: --marked 도 부른 프로그램의 파일을 작업 트리에 남기지 않음 (rc=${rc} [$(show "$out")] 남은 파일 [${left}])"; fi
  printf 'u\n' > "$rl/scratch/user.txt"
  launcher_run "${gshim}:${shim}" "$rl" "$rl/scratch" --base main
  if [ "$rc" = 0 ] && [ "$(list_of)" = "A${TAB}scratch/user.txt" ] && has_line "$(patch_of)" '+u' && [ "$left" = 'user.txt ' ]; then
    ok '브랜치 수집: 부른 프로그램이 파일을 남겨도 같은 상위 디렉토리의 사용자 파일만 들어감 통과'
  else ng "브랜치 수집: 부른 프로그램이 파일을 남겨도 같은 상위 디렉토리의 사용자 파일만 들어감 (rc=${rc} [$(show "$(list_of)")] 남은 파일 [${left}])"; fi
fi

# 호출 위치(최종 감사 2차 F-10): 하위 디렉토리에서 상대 경로 GIT_DIR·GIT_WORK_TREE 로 불러도 절대 경로로 부른 결과와 같다.
# 바깥에 다른 저장소를 두어, 작업 트리 루트로 옮긴 뒤 `../.git` 을 읽는 헬퍼가 바깥 저장소의 변경을 내는 경우도 격추한다.
ro="$tmpdir/bc-outer"; ri="$ro/inner"
{ newrepo "$ro" && printf 'o\n' > "$ro/outer.txt" && g "$ro" add -A && g "$ro" commit -m outer && printf 'o2\n' >> "$ro/outer.txt" \
  && newrepo "$ri" && mkdir -p "$ri/src" && printf 'a\n' > "$ri/src/file" && printf 'h\n' > "$ri/hidden.txt" \
  && g "$ri" add -A && g "$ri" commit -m base && g "$ri" checkout -b work && g "$ri" update-index --assume-unchanged hidden.txt \
  && printf 'b\n' >> "$ri/src/file" && printf 'n\n' > "$ri/new.txt"; } \
  || ng '브랜치 수집: 호출 위치 저장소를 만들지 못함'
# rel_abs <설명> <기대 출력> <헬퍼 인자…> — src/ 에서 절대 경로 변수로 부른 출력이 기대와 같고, 상대 경로 변수로 부른 출력이 그와 같은가
rel_abs() {
  local desc="$1" want="$2" abs_out abs_rc; shift 2
  abs_out="$(cd "$ri/src" && GIT_DIR="$ri/.git" GIT_WORK_TREE="$ri" "$COLLECT" "$@" 2> "$tmpdir/collect.err")"; abs_rc=$?
  out="$(cd "$ri/src" && GIT_DIR=../.git GIT_WORK_TREE=.. "$COLLECT" "$@" 2> "$tmpdir/collect.err")"; rc=$?
  if [ "$abs_rc" != 0 ] || [ "$want" != "$(printf '%s\n' "$abs_out" | awk 'NF==0{exit} {print}' | LC_ALL=C sort)" ]; then
    ng "브랜치 수집: ${desc} 절대 경로 대조군이 기대와 다름 (rc=${abs_rc} [$(show "$abs_out")])"
  elif [ "$rc" = 0 ] && [ "$out" = "$abs_out" ]; then ok "브랜치 수집: ${desc} 상대 경로 변수의 출력이 절대 경로와 같음 통과"
  else ng "브랜치 수집: ${desc} 상대 경로 변수의 출력이 절대 경로와 같음 (rc=${rc} [$(show "$out")] $(head -n 1 "$tmpdir/collect.err"))"; fi
}
rel_abs '하위 디렉토리 --base' "$(want_rows "A${TAB}new.txt" "M${TAB}src/file")" --base main
rel_abs '하위 디렉토리 --marked' 'h hidden.txt' --marked

# 수집 실패와 사용오류: 표준 출력 없이 종료 코드 1·2 와 표준 오류 1행
mkdir -p "$tmpdir/outside"
# assert_collect_error <기대 종료 코드> <디렉토리> <설명> <헬퍼 인자…>
assert_collect_error() {
  local want_rc="$1" dir="$2" desc="$3" nerr; shift 3
  collect "$dir" "$@"
  nerr="$(grep -c . "$tmpdir/collect.err")"
  if [ "$rc" = "$want_rc" ] && [ -z "$out" ] && [ "$nerr" = 1 ]; then ok "$desc"
  else ng "$desc (기대 rc=${want_rc}, 실제 rc=${rc} out=[$(show "$out")] 표준 오류 ${nerr}행)"; fi
}
assert_collect_error 1 "$r0" '브랜치 수집: 없는 base 격추' --base 'no-such-ref'
assert_collect_error 1 "$tmpdir/outside" '브랜치 수집: git 작업 트리 밖 --base 격추' --base main
assert_collect_error 1 "$tmpdir/outside" '브랜치 수집: git 작업 트리 밖 --marked 격추' --marked
assert_collect_error 2 "$r0" '브랜치 수집: --base·--marked 둘 다 없음 격추'
assert_collect_error 2 "$r0" '브랜치 수집: --base·--marked 함께 줌 격추' --marked --base main
assert_collect_error 2 "$r0" '브랜치 수집: 알 수 없는 인자 격추' --base main --cached
assert_collect_error 2 "$r0" '브랜치 수집: --base 중복 격추' --base main --base main
assert_collect_error 2 "$r0" '브랜치 수집: --base 빈 값 격추' --base ''
assert_collect_error 2 "$r0" '브랜치 수집: --base 값 없음 격추' --base

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
