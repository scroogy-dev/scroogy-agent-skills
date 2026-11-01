#!/usr/bin/env bash
#
# check-plan.sh — issue-audit 계획 감사(`--plan`) 2단계 관점 1 "추적성"을 결정적으로 판정한다.
#
# SKILL.md `--plan` 소절이 판정의 SSoT 이며 이 스크립트는 그 사본이다.
# 규격이 바뀌면 이 스크립트와 tests/ 의 기대값을 함께 갱신한다.
#
# --trace: spec 포함 목록의 R<n>, spec 완료의 정의의 `### R<n>` 그룹, plan 일반 Task 의 `대상 요구사항` 필드
#   세 축의 대응이 끊긴 자리를 센다. 감사인이 눈으로 대조하면 모델·회차마다 결과가 갈린다.
# --ac: 이슈 본문의 AC 와 spec 완료의 정의 항목의 출처 표기 `(AC<n>[, AC<m>])` 의 대응이 끊긴 자리를 센다.
#
# 읽는 앵커 (issue-work 템플릿 계약):
#   spec (--trace) — `**포함**` 아래 `- R<n>: ` 항목, `## 완료의 정의` 절 안의 `### R<n>: ` DoD 그룹 (`### 공통` 은 R 이 아니다)
#   plan (--trace) — `### Task ` 블록, `- **대상 요구사항**: R<n>[, R<m>]` 필드. 값에 R<n> 이 하나도 없으면 필드가 없는 것과 같다.
#          같은 행에서 닫힌 주석(<!-- … -->) 안의 R<n> 은 값으로 세지 않는다.
#          고정 Task 는 `### Task 0 (고정)`·`### Task N (고정)` 두 헤더만이며 필드 검사·참조 집계에서 제외한다.
#   이슈 본문 (--ac) — `- [ ] AC<n>: `·`- [x] AC<n>: ` 행 (issue-work 3-2 `AC 정제`의 AC 유무 판정과 같다)
#   spec (--ac) — `## 완료의 정의` 절 안의 `- [ ] [D|QD|ND]` 항목 행(`[x]` 포함, 들여쓴 하위 행 제외).
#          출처 표기는 행 안의 `(AC<n>)`·`(AC<n>, AC<m>)` 와 `(AC 없음: <사유>)` 이며, 인라인 코드 안의 표기는 세지 않는다.
#          출처 표기 없이 두어도 되는 항목은 `### 공통` 그룹의 `(회귀 방지 항목)` 항목뿐이다.
#   모든 파일에서 코드 펜스(``` 또는 ~~~. 여는 펜스와 같은 문자를 같은 개수 이상 쓴 행에서 닫힌다)·HTML 블록 주석(<!-- … -->)
#   안의 행은 앵커로 읽지 않는다. 주석 안의 펜스 행은 펜스를 열거나 닫지 않고, 펜스 안의 `<!--` 는 주석을 열지 않는다.
#   행 중간에서 시작한 여러 줄 주석은 `<!--` 앞의 본문만 읽고, 주석을 닫은 행의 나머지에서 다시 연 주석은 이어진다.
#   인라인 코드(`…`)와 주석은 먼저 시작한 쪽이 이긴다. 코드 안의 `<!--`·`-->` 는 글자이고, 주석 안의 백틱도 글자다.
#   경계: 행 단위로 읽는다. 여러 행에 걸친 코드 스팬·들여쓰기 코드 블록 등 그 밖의 마크다운 구성은 구분하지 않는다 (원장 K-0010).
#
# 사용법:
#   check-plan.sh --trace <spec 파일> <plan 파일>
#   check-plan.sh --ac <이슈 본문 파일> <spec 파일>
#
# 출력 (위반 1건 1행):
#   --trace
#   R 없는 DoD 그룹: R<n>               — 포함 목록에 없는 번호의 DoD 그룹
#   DoD 없는 R: R<n>                    — DoD 그룹이 없는 포함 요구사항
#   Task 없는 R: R<n>                   — 어느 일반 Task 도 대상으로 삼지 않는 포함 요구사항
#   대상 요구사항 없는 일반 Task: <헤더> — 필드가 없거나 값에 R<n> 이 없는 일반 Task
#   추적 불가: …                         — 포함 목록이 비었거나 plan 에 Task 블록이 없음 (공집합을 통과로 보지 않는다)
#   --ac
#   연결 없는 AC: AC<n>                 — 어느 spec 항목의 출처 표기에도 없는 이슈 AC
#   없는 AC 참조: AC<n>                 — 출처 표기가 가리키지만 이슈 본문에 없는 AC
#   출처 없는 항목: <spec 행>           — 출처 표기가 없는 항목 (`### 공통` 의 회귀 방지 항목 제외)
#   대조 불가: 이슈 본문에 AC 없음      — 이 행 1행만 내고 spec 항목은 대조하지 않는다 (공집합을 통과로 보지 않는다)
#
# 종료 코드: 0 통과(무출력) / 1 위반 있음(대조 불가 포함) / 2 사용오류(모드 미지정·모드 중복·인자 부족·읽을 수 없는 파일·알 수 없는 옵션)

set -o pipefail

usage() { awk 'NR > 2 { if (!/^#/) exit; sub(/^# ?/, ""); print }' "$0"; }

mode=''
spec=''
plan=''
issue=''

while [ $# -gt 0 ]; do
  case "$1" in
    --trace)
      [ -z "$mode" ] || { echo "error: 모드는 하나만 지정합니다" >&2; exit 2; }
      mode='trace'
      [ $# -ge 3 ] || { echo "error: $1 에 <spec 파일> <plan 파일> 두 인자가 필요합니다" >&2; exit 2; }
      spec="$2"; plan="$3"; shift 3 ;;
    --ac)
      [ -z "$mode" ] || { echo "error: 모드는 하나만 지정합니다" >&2; exit 2; }
      mode='ac'
      [ $# -ge 3 ] || { echo "error: $1 에 <이슈 본문 파일> <spec 파일> 두 인자가 필요합니다" >&2; exit 2; }
      issue="$2"; spec="$3"; shift 3 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: 알 수 없는 인자 — $1" >&2; exit 2 ;;
  esac
done

[ -n "$mode" ] || { echo "error: --trace 또는 --ac 가 필요합니다" >&2; usage >&2; exit 2; }

if [ "$mode" = 'ac' ]; then inputs=("$issue" "$spec"); else inputs=("$spec" "$plan"); fi
for f in "${inputs[@]}"; do
  [ -r "$f" ] || { echo "error: 읽을 수 없는 파일 — $f" >&2; exit 2; }
done

# 코드 펜스·HTML 블록 주석 안의 행은 두 파서 모두 건너뛴다. 예시·주석의 앵커가 실제 구조를 대신하거나
# 유령 위반을 만들지 않게 한다. 펜스는 spec DoD 접기처럼 들여쓰기된 것도 인식한다.
# 펜스는 백틱·물결표 두 문자를 받고, 여는 펜스의 문자·길이를 기억해 같은 문자를 같은 개수 이상 쓴 행에서만 닫는다.
# 백틱 4개 예시 안의 백틱 3개 행을 닫힘으로 오인하지 않기 위해서다. 판정 순서는 주석 상태, 펜스 상태, 펜스 열기, 주석 열기다.
# 주석 안의 펜스 행이 펜스 상태를 바꾸거나 펜스 안의 `<!--` 가 주석을 열지 않게 한다.
# 한 행 안에서 닫힌 주석(<!-- … -->)은 행을 건너뛰지 않는다. 앵커 행 끝의 짧은 메모를 앵커 누락으로 만들지 않기 위해서다.
# 행 안의 주석·인라인 코드는 scan 하나가 왼쪽부터 읽는다. 먼저 시작한 쪽이 이겨서, 코드 안의 `<!--` 는 주석을 열지 않고
# 주석 안의 백틱은 코드를 열지 않는다. 코드를 먼저 가린 뒤 주석을 찾으면 두 주석에 하나씩 든 백틱이 짝지어져 사이의 본문이 사라진다.
# scan 은 닫힌 주석을 지운 본문을 돌려주고, 행이 열린 주석으로 끝나면 left_open 을 켠다. 그 행은 `<!--` 앞의 본문만 읽는다.
# `대상 요구사항` 값도 scan 으로 읽어, 주석에만 있는 R<n> 이 연결로 세지지 않게 한다.
# 주석을 닫는 행은 after_close 로 나머지를 다시 보아, 같은 행에서 다시 연 주석(`--> <!--`)이 이어지게 한다.
# 인라인 코드는 백틱 n개로 열어 같은 개수의 백틱에서 닫히며, 닫는 짝이 없는 백틱은 본문 글자다.
skip='
  function scan(s,  out, bt, cs, run, r, pos, m, k, j, q) {
    out = ""; left_open = 0
    while (s != "") {
      bt = index(s, "`"); cs = index(s, "<!--")
      if (cs > 0 && (bt == 0 || cs < bt)) {
        q = index(substr(s, cs + 4), "-->")
        if (q == 0) { left_open = 1; return out substr(s, 1, cs - 1) }
        out = out substr(s, 1, cs - 1); s = substr(s, cs + q + 6); continue
      }
      if (bt == 0) return out s
      run = 0; while (substr(s, bt + run, 1) == "`") run++
      r = substr(s, bt + run); pos = 1; j = 0
      while ((m = index(substr(r, pos), "`")) > 0) {
        k = 0; while (substr(r, pos + m - 1 + k, 1) == "`") k++
        if (k == run) { j = pos + m - 1; break }
        pos += m - 1 + k
      }
      if (j == 0) { out = out substr(s, 1, bt + run - 1); s = r; continue }
      out = out substr(s, 1, bt + run - 1) substr(r, 1, j + run - 1); s = substr(r, j + run)
    }
    return out
  }
  function after_close(s,  p) { p = index(s, "-->"); if (p == 0) return 1; scan(substr(s, p + 3)); return left_open }
  function fence_run(s,  n) { sub(/^[[:space:]]*/, "", s); n = 0; while (substr(s, n + 1, 1) == fch) n++; frest = substr(s, n + 1); return n }
  cm { cm = after_close($0); next }
  fence { if (fence_run($0) >= flen && frest ~ /^[[:space:]]*$/) fence = 0; next }
  /^[[:space:]]*(```|~~~)/ { s = $0; sub(/^[[:space:]]*/, "", s); fch = substr(s, 1, 1); flen = fence_run($0); fence = 1; next }
  { body = scan($0); if (left_open) { cm = 1; $0 = body } }
'

# --ac — 이슈 본문의 AC 번호와 spec 항목의 출처 표기를 대조한다. 행 읽기 규칙(펜스·주석·인라인 코드)은 --trace 와 같다.
# 출처 표기는 주석을 지운 행에서 인라인 코드까지 지우고 찾는다. 항목 설명이 `(AC 없음: <사유>)` 같은 형식을
# 인라인 코드로 인용해도 출처 표기로 세지 않기 위해서다. 코드 구간 판정은 scan 과 같다(백틱 n개로 열어 같은 개수에서 닫힘).
# `(AC 없음: <사유>)` 는 `(AC<n>)` 처럼 닫는 괄호까지 있어야 출처로 센다. 사유 안의 괄호는 한 겹까지 받는다.
# 닫는 괄호가 빠진 표기가 뒤따르는 `(검증: …)` 의 괄호로 닫힌 것처럼 읽히지 않게 한다.
# `### 공통` 헤더도 scan 결과로 판정해, 헤더 끝의 닫힌 주석이 공통 그룹을 가리지 않게 한다.
# AC 가 없는 이슈 본문은 `대조 불가` 1행만 낸다. AC 없는 이슈의 spec 은 출처 표기 없이 쓰므로(issue-work 3-2),
# 대조를 이어 가면 항목마다 `출처 없는 항목` 이 나와 정상 경로가 위반 목록처럼 보인다.
if [ "$mode" = 'ac' ]; then
  issue_out="$(awk "$skip"'
    /^- \[[ x]\] AC[0-9]+: / { n = $0; sub(/^- \[[ x]\] AC/, "", n); sub(/:.*/, "", n); print "AC " n + 0 }
  ' "$issue")"

  spec_out="$(awk "$skip"'
    function nocode(s,  out, bt, run, r, pos, m, k, j) {
      out = ""
      while ((bt = index(s, "`")) > 0) {
        run = 0; while (substr(s, bt + run, 1) == "`") run++
        r = substr(s, bt + run); pos = 1; j = 0
        while ((m = index(substr(r, pos), "`")) > 0) {
          k = 0; while (substr(r, pos + m - 1 + k, 1) == "`") k++
          if (k == run) { j = pos + m - 1; break }
          pos += m - 1 + k
        }
        if (j == 0) { out = out substr(s, 1, bt + run - 1); s = r; continue }
        out = out substr(s, 1, bt - 1); s = substr(r, j + run)
      }
      return out s
    }
    /^## / { dod = ($0 ~ /^## 완료의 정의/); common = 0 }
    dod && /^### / { common = (scan($0) ~ /^### 공통[[:space:]]*$/) }
    dod && /^- \[[ xX]\] \[(D|QD|ND)\]/ {
      v = nocode(scan($0)); t = v; has = 0
      while (match(t, /\(AC[0-9]+(, AC[0-9]+)*\)/)) {
        has = 1; g = substr(t, RSTART + 1, RLENGTH - 2); t = substr(t, RSTART + RLENGTH)
        while (match(g, /[0-9]+/)) { print "REF " substr(g, RSTART, RLENGTH) + 0; g = substr(g, RSTART + RLENGTH) }
      }
      if (v ~ /\(AC 없음: *([^ ()]|\([^()]*\))([^()]|\([^()]*\))*\)/) has = 1
      if (!has && !(common && index(v, "(회귀 방지 항목)"))) print "NOSRC " $0
    }
  ' "$spec")"

  hits="$(printf '%s\n%s\n' "$issue_out" "$spec_out" | awk '
    $1 == "AC"    { if (!($2 in ac))  { ac[$2] = 1;  ao[++na] = $2 } }
    $1 == "REF"   { if (!($2 in ref)) { ref[$2] = 1; ro[++nr] = $2 } }
    $1 == "NOSRC" { sub(/^NOSRC /, ""); ns[++nn] = $0 }
    END {
      if (na == 0) { print "대조 불가: 이슈 본문에 AC 없음"; exit }
      for (k = 1; k <= na; k++) if (!(ao[k] in ref)) print "연결 없는 AC: AC" ao[k]
      for (k = 1; k <= nr; k++) if (!(ro[k] in ac))  print "없는 AC 참조: AC" ro[k]
      for (k = 1; k <= nn; k++) print "출처 없는 항목: " ns[k]
    }
  ')"

  [ -z "$hits" ] || { printf '%s\n' "$hits"; exit 1; }
  exit 0
fi

# spec — 포함 목록은 `**포함**` 다음 행부터 다음 굵은 라벨(`**제외**`)·`## ` 헤더·구분선 앞까지다.
# DoD 그룹은 `## 완료의 정의` 절 안의 `### R<n>: ` 헤더만 센다. `### 공통` 은 R 이 아니라 여기 걸리지 않는다.
spec_out="$(awk "$skip"'
  /^## / { dod = ($0 ~ /^## 완료의 정의/) }
  /^\*\*포함\*\*[[:space:]]*$/ { inc = 1; next }
  inc && (/^\*\*/ || /^## / || /^---/) { inc = 0 }
  inc && /^- R[0-9]+: / { n = $0; sub(/^- R/, "", n); sub(/:.*/, "", n); print "INC " n + 0 }
  dod && /^### R[0-9]+: / { n = $0; sub(/^### R/, "", n); sub(/:.*/, "", n); print "DOD " n + 0 }
' "$spec")"

# plan — 블록 단위로 센다. 고정 Task 두 헤더만 제외하며, 부분 문자열 `고정` 으로 판정하지 않는다
# (일반 Task 제목에 든 단어를 오분류하고, 일반 Task 에 `(고정)` 을 붙여 필드 계약을 우회하는 것을 막는다).
# 필드는 값에서 R<n> 을 찾았을 때만 연결로 센다. 라벨만 있고 값이 비었거나 `-` 면 필드가 없는 것과 같다.
plan_out="$(awk "$skip"'
  function flush() { if (o && !fixed && c == 0) print "NOFIELD " t }
  /^### Task / { flush(); o = 1; t = $0; sub(/^### /, "", t); c = 0; fixed = ($0 ~ /^### Task (0|N) \(고정\)/) }
  o && !fixed && /^- \*\*대상 요구사항\*\*:/ {
    v = scan($0); sub(/^- \*\*대상 요구사항\*\*:/, "", v)
    while (match(v, /R[0-9]+/)) { c++; print "REF " substr(v, RSTART + 1, RLENGTH - 1) + 0; v = substr(v, RSTART + RLENGTH) }
  }
  END { flush(); if (!o) print "NOTASK" }
' "$plan")"

hits="$(printf '%s\n%s\n' "$spec_out" "$plan_out" | awk '
  $1 == "INC"     { inc[$2] = 1; if (!($2 in si)) { si[$2] = 1; io[++ni] = $2 } }
  $1 == "DOD"     { dod[$2] = 1; if (!($2 in sd)) { sd[$2] = 1; dor[++nd] = $2 } }
  $1 == "REF"     { ref[$2] = 1 }
  $1 == "NOFIELD" { sub(/^NOFIELD /, ""); nof[++nn] = $0 }
  $1 == "NOTASK"  { notask = 1 }
  END {
    if (ni == 0) print "추적 불가: spec 포함 목록에 R<n> 항목이 없습니다 — 경로를 확인하세요"
    if (notask)  print "추적 불가: plan 에 ### Task 블록이 없습니다 — 경로를 확인하세요"
    for (k = 1; k <= nd; k++) if (!(dor[k] in inc)) print "R 없는 DoD 그룹: R" dor[k]
    for (k = 1; k <= ni; k++) if (!(io[k] in dod))  print "DoD 없는 R: R" io[k]
    for (k = 1; k <= ni; k++) if (!(io[k] in ref))  print "Task 없는 R: R" io[k]
    for (k = 1; k <= nn; k++) print "대상 요구사항 없는 일반 Task: " nof[k]
  }
')"

[ -z "$hits" ] || { printf '%s\n' "$hits"; exit 1; }
