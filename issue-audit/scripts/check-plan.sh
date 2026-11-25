#!/usr/bin/env bash
#
# check-plan.sh — issue-audit 계획 감사(`--plan`) 2단계 관점 1 "추적성"을 결정적으로 판정한다.
#
# SKILL.md `--plan` 소절이 판정의 SSoT 이며 이 스크립트는 그 사본이다.
# 규격이 바뀌면 이 스크립트와 tests/ 의 기대값을 함께 갱신한다.
#
# --trace: spec 포함 목록의 R<n>, spec 완료의 정의 AC 행의 `(R<n>)`, plan 일반 Task 의 `대상 요구사항`, plan `테스트 계획` 의 AC 줄
#   사이에서 대응이 끊긴 자리를 센다. 감사인이 눈으로 대조하면 모델·회차마다 결과가 갈린다.
# --ac: 이슈 본문의 AC 와 spec 의 AC 가 번호·문장·묶음 제목까지 같은지 본다.
#
# 읽는 앵커 (issue-work 템플릿 계약):
#   spec (--trace) — 포함 표지 `### 포함` 아래 `- R<n>: ` 항목. `#### ` 묶음 제목은 목록을 끊지 않는다.
#   spec (--trace, --ac) — `## 완료의 정의` 절 안의 `- [ ] AC<n>: ` 행(`[x]` 포함). 행 끝의 `(R<n>)`·`(R<n>, R<m>)` 이 R 표기다.
#          묶음 제목은 그 절 안의 `### <묶음 이름>` 이다.
#   plan (--trace) — `### Task ` 블록, `- **대상 요구사항**: R<n>[, R<m>]` 필드. 값에 R<n> 이 하나도 없으면 필드가 없는 것과 같다.
#          고정 Task 는 `### Task 0 (고정)`·`### Task N (고정)` 두 헤더만이며 필드 검사·참조 집계에서 제외한다.
#          `## 테스트 계획` 절 안에서 머리가 `| AC | 레벨 | 층 |` 이나 `| AC | 레벨 | 누가 보나 |` 로 시작하는 표의 `| AC<n> |` 행.
#          첫 칸에 AC 번호 하나만 있는 행을 읽는다.
#   이슈 본문 (--ac) — `- [ ] AC<n>: `·`- [x] AC<n>: ` 행 (issue-work 3-2 의 AC 유무 판정과 같다). 묶음 제목은 그 행 앞의 `### <묶음 이름>` 이다.
#   표지·제목·표의 칸·행 끝에 붙은 닫힌 주석(<!-- … -->)은 지우고 읽는다.
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
#   추적 불가: …                         — 포함 목록이 비었거나 plan 에 Task 블록이 없음 (공집합을 통과로 보지 않는다)
#   AC 없는 R: R<n>                      — 어느 AC 행의 R 표기에도 없는 포함 요구사항
#   Task 없는 R: R<n>                    — 어느 일반 Task 도 대상으로 삼지 않는 포함 요구사항
#   없는 R 참조: R<n> (<자리>)           — AC 행이나 일반 Task 가 가리키지만 포함 목록에 없는 R. 자리는 AC<n> 이나 Task 헤더
#   대상 요구사항 없는 일반 Task: <헤더> — 필드가 없거나 값에 R<n> 이 없는 일반 Task
#   R 표기 없는 AC: AC<n> (<행>행)       — 행 끝에 R 표기가 없는 spec AC 행
#   중복 AC: AC<n> (<행>행, <행>행)      — 같은 번호의 행이 둘 이상인 spec AC
#   테스트 계획 없는 AC: AC<n>           — 테스트 계획의 두 표 어디에도 줄이 없는 spec AC
#   없는 AC 참조: AC<n>                  — 테스트 계획이 가리키지만 spec 에 없는 AC
#   --ac
#   spec에 없는 AC: AC<n>                — 이슈 본문에만 있는 AC
#   이슈 본문에 없는 AC: AC<n>           — spec 에만 있는 AC
#   문장 다른 AC: AC<n>                  — R 표기를 뺀 문장이 이슈 본문과 spec 에서 다른 AC
#   묶음 다른 AC: AC<n>                  — 놓인 묶음 제목이 다른 AC (한쪽에만 제목이 있는 경우 포함)
#   대조 불가: 이슈 본문에 AC 없음       — 이 행 1행만 내고 spec 의 AC 는 대조하지 않는다 (공집합을 통과로 보지 않는다)
#
# 종료 코드: 0 통과(무출력) / 1 위반 있음(대조 불가 포함) / 2 사용오류(모드 미지정·모드 중복·인자 부족·읽을 수 없는 파일·알 수 없는 옵션)

set -o pipefail

# 문자열을 바이트로 견준다. macOS awk 의 == 는 en_US.UTF-8 에서 서로 다른 한글 문자열을 같다고 보아, 문장·묶음이 다른 AC 를 통과시킨다.
export LC_ALL=C

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

# 코드 펜스·HTML 블록 주석 안의 행은 세 문서의 파서가 모두 건너뛴다. 예시·주석의 앵커가 실제 구조를 대신하거나
# 유령 위반을 만들지 않게 한다. 펜스는 목록 안의 접기처럼 들여쓰기된 것도 인식한다.
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

# AC 행을 읽는 함수. ac_no 는 AC 행이면 번호를, 아니면 -1 을 돌려주고 ac_body 에 주석을 지운 문장(R 표기 포함)을 둔다.
# cut_r 은 문장 끝의 R 표기를 떼어 refs 에 두고 나머지 문장을 돌려준다. 표기가 없으면 refs 가 빈다.
# 공백은 공백·탭·CR 만 다듬는다.
ac_fn='
  function trim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
  function ac_no(s,  n) {
    if (s !~ /^- \[[ xX]\] AC[0-9]+: /) return -1
    s = trim(scan(s)); sub(/^- \[[ xX]\] AC/, "", s); n = s; sub(/:.*/, "", n)
    ac_body = s; sub(/^[0-9]+:/, "", ac_body); ac_body = trim(ac_body)
    return n + 0
  }
  function cut_r(s) {
    refs = ""
    if (match(s, /\(R[0-9]+(, R[0-9]+)*\)$/)) { refs = substr(s, RSTART + 1, RLENGTH - 2); s = trim(substr(s, 1, RSTART - 1)) }
    return s
  }
'

# --ac — 이슈 본문과 spec 의 AC 를 번호로 짝지어 문장과 묶음 제목을 견준다. 행 읽기 규칙(펜스·주석·인라인 코드)은 --trace 와 같다.
# spec 은 문장 끝의 R 표기를 하나 떼고 견준다. 이슈 본문의 문장은 떼지 않는다. 본문 문장이 괄호로 끝나면 그 괄호도 문장이다.
# 같은 번호의 행이 여러 개면 모두 첫 행과 견준다. 한쪽 문서 안에서 문장이 갈려도 하나가 조용히 가려지지 않게 한다.
# 문장과 묶음은 글자 그대로 견준다. 칸 구분자는 본문에 쓰이지 않는 제어 문자(\037)라 탭을 바꾸지 않고,
# 비교에 빈 문자열을 이어 숫자 모양 값(01·1, 1e2·100)을 수치로 견주지 않게 한다.
# AC 가 없는 이슈 본문은 `대조 불가` 1행만 낸다. 대조를 이어 가면 spec 이 직접 쓴 AC 마다 위반이 나와 정상 경로가 위반 목록처럼 보인다.
if [ "$mode" = 'ac' ]; then
  ac_rows='
    function emit(src, n, text) { print src "\037" n "\037" grp "\037" text }
    /^## / { grp = "" }
    /^### / { grp = scan($0); sub(/^### /, "", grp); grp = trim(grp) }
  '
  issue_out="$(awk "$skip$ac_fn$ac_rows"'
    /^- \[[ x]\] AC/ { n = ac_no($0); if (n >= 0) emit("ISSUE", n, ac_body) }
  ' "$issue")"

  spec_out="$(awk "$skip$ac_fn$ac_rows"'
    /^## / { dod = ($0 ~ /^## 완료의 정의/) }
    dod { n = ac_no($0); if (n >= 0) emit("SPEC", n, cut_r(ac_body)) }
  ' "$spec")"

  hits="$(printf '%s\n%s\n' "$issue_out" "$spec_out" | awk -F'\037' '
    $1 == "ISSUE" { if (!($2 in inIssue)) { inIssue[$2] = 1; io[++ni] = $2 } }
    $1 == "SPEC"  { if (!($2 in inSpec))  { inSpec[$2] = 1;  so[++ns] = $2 } }
    $1 == "ISSUE" || $1 == "SPEC" {
      if (!($2 in text)) { text[$2] = $4; group[$2] = $3 }
      if (text[$2] "" != $4 "")  tdiff[$2] = 1
      if (group[$2] "" != $3 "") gdiff[$2] = 1
    }
    END {
      if (ni == 0) { print "대조 불가: 이슈 본문에 AC 없음"; exit }
      for (k = 1; k <= ni; k++) if (!(io[k] in inSpec))  print "spec에 없는 AC: AC" io[k]
      for (k = 1; k <= ns; k++) if (!(so[k] in inIssue)) print "이슈 본문에 없는 AC: AC" so[k]
      for (k = 1; k <= ni; k++) if ((io[k] in inSpec) && (io[k] in tdiff)) print "문장 다른 AC: AC" io[k]
      for (k = 1; k <= ni; k++) if ((io[k] in inSpec) && (io[k] in gdiff)) print "묶음 다른 AC: AC" io[k]
    }
  ')"

  [ -z "$hits" ] || { printf '%s\n' "$hits"; exit 1; }
  exit 0
fi

# spec — 포함 목록은 포함 표지 다음 행부터 다음 `### ` 제목(`### 제외`)·`## ` 헤더·구분선 앞까지다. `#### ` 묶음 제목과 굵은 글씨 행은 목록을 끊지 않는다.
# 표지는 행 안의 닫힌 주석을 지운 결과(scan)로 판정해, 표지 행 끝의 짧은 메모를 표지 누락으로 만들지 않는다 (원장 K-0023).
# AC 행은 `## 완료의 정의` 절 안에서만 센다.
spec_out="$(awk "$skip$ac_fn"'
  /^## / { dod = ($0 ~ /^## 완료의 정의/) }
  trim(scan($0)) == "### 포함" { inc = 1; next }
  inc && (/^## / || /^### / || /^---/) { inc = 0 }
  inc && /^- R[0-9]+: / { n = $0; sub(/^- R/, "", n); sub(/:.*/, "", n); print "INC " n + 0 }
  dod && (n = ac_no($0)) >= 0 {
    cut_r(ac_body); print "AC " n " " NR
    if (refs == "") print "NOREF " n " " NR
    while (match(refs, /R[0-9]+/)) { print "ACREF " substr(refs, RSTART + 1, RLENGTH - 1) + 0 " AC" n; refs = substr(refs, RSTART + RLENGTH) }
  }
' "$spec")"

# plan — 블록 단위로 센다. 고정 Task 두 헤더만 제외하며, 부분 문자열 `고정` 으로 판정하지 않는다
# (일반 Task 제목에 든 단어를 오분류하고, 일반 Task 에 `(고정)` 을 붙여 필드 계약을 우회하는 것을 막는다).
# 필드는 값에서 R<n> 을 찾았을 때만 연결로 센다. 라벨만 있고 값이 비었거나 `-` 면 필드가 없는 것과 같다.
# 테스트 계획의 표는 머리로 가린다. 절 안의 다른 표나 절 밖의 표에 적은 AC 는 세지 않는다.
plan_out="$(awk "$skip$ac_fn"'
  function flush() { if (o && !fixed && c == 0) print "NOFIELD " t }
  /^## / { tp = (trim(scan($0)) == "## 테스트 계획") }
  !/^\|/ { tbl = 0 }
  tp && /^\|/ {
    row = scan($0); tbl++
    if (tbl == 1) good = (row ~ /^\|[ \t]*AC[ \t]*\|[ \t]*레벨[ \t]*\|[ \t]*(층|누가 보나)[ \t]*\|/)
    else if (good && row ~ /^\|[ \t]*AC[0-9]+[ \t]*\|/) { sub(/^\|[ \t]*AC/, "", row); sub(/[ \t]*\|.*/, "", row); print "TEST " row + 0 }
  }
  /^### Task / { flush(); o = 1; t = $0; sub(/^### /, "", t); c = 0; fixed = ($0 ~ /^### Task (0|N) \(고정\)/) }
  o && !fixed && /^- \*\*대상 요구사항\*\*:/ {
    v = scan($0); sub(/^- \*\*대상 요구사항\*\*:/, "", v)
    while (match(v, /R[0-9]+/)) { c++; print "REF " substr(v, RSTART + 1, RLENGTH - 1) + 0 " " t; v = substr(v, RSTART + RLENGTH) }
  }
  END { flush(); if (!o) print "NOTASK" }
' "$plan")"

hits="$(printf '%s\n%s\n' "$spec_out" "$plan_out" | awk '
  function site(s) { sub(/^[A-Z]+ [0-9]+ /, "", s); return s }
  function refer(r, s) { if (!((r, s) in seen)) { seen[r, s] = 1; rr[++nr] = r; rs[nr] = s } }
  $1 == "INC"     { if (!($2 in inc)) { inc[$2] = 1; io[++ni] = $2 } }
  $1 == "AC"      { if (!($2 in ac)) { ac[$2] = $3 "행"; ao[++na] = $2 } else { ac[$2] = ac[$2] ", " $3 "행"; dup[$2] = 1 } }
  $1 == "NOREF"   { noref[++nf] = "AC" $2 " (" $3 "행)" }
  $1 == "ACREF"   { acref[$2] = 1; refer($2, site($0)) }
  $1 == "REF"     { ref[$2] = 1; refer($2, site($0)) }
  $1 == "TEST"    { if (!($2 in test)) { test[$2] = 1; to[++nt] = $2 } }
  $1 == "NOFIELD" { sub(/^NOFIELD /, ""); nof[++nn] = $0 }
  $1 == "NOTASK"  { notask = 1 }
  END {
    if (ni == 0) print "추적 불가: spec 포함 목록에 R<n> 항목이 없습니다 — 경로를 확인하세요"
    if (notask)  print "추적 불가: plan 에 ### Task 블록이 없습니다 — 경로를 확인하세요"
    for (k = 1; k <= ni; k++) if (!(io[k] in acref)) print "AC 없는 R: R" io[k]
    for (k = 1; k <= ni; k++) if (!(io[k] in ref))   print "Task 없는 R: R" io[k]
    for (k = 1; k <= nr; k++) if (!(rr[k] in inc))   print "없는 R 참조: R" rr[k] " (" rs[k] ")"
    for (k = 1; k <= nn; k++) print "대상 요구사항 없는 일반 Task: " nof[k]
    for (k = 1; k <= nf; k++) print "R 표기 없는 AC: " noref[k]
    for (k = 1; k <= na; k++) if (ao[k] in dup)      print "중복 AC: AC" ao[k] " (" ac[ao[k]] ")"
    for (k = 1; k <= na; k++) if (!(ao[k] in test))  print "테스트 계획 없는 AC: AC" ao[k]
    for (k = 1; k <= nt; k++) if (!(to[k] in ac))    print "없는 AC 참조: AC" to[k]
  }
')"

[ -z "$hits" ] || { printf '%s\n' "$hits"; exit 1; }
