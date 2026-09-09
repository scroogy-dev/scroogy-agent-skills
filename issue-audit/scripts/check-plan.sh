#!/usr/bin/env bash
#
# check-plan.sh — issue-audit 계획 감사(`--plan`) 2단계 "추적성" 관점을 결정적으로 판정한다.
#
# SKILL.md `--plan` 소절이 판정 4종의 SSoT 이며 이 스크립트는 그 사본이다.
# 규격이 바뀌면 이 스크립트와 tests/ 의 기대값을 함께 갱신한다.
#
# spec 포함 목록의 R<n>, spec 완료의 정의의 `### R<n>` 그룹, plan 일반 Task 의 `대상 요구사항` 필드
# 세 축의 대응이 끊긴 자리를 센다. 감사인이 눈으로 대조하면 모델·회차마다 결과가 갈린다.
#
# 읽는 앵커 (issue-work 템플릿 계약):
#   spec — `**포함**` 아래 `- R<n>: ` 항목, `### R<n>: ` DoD 그룹 (`### 공통` 은 R 이 아니다)
#   plan — `### Task ` 블록, `- **대상 요구사항**: R<n>[, R<m>]` 필드.
#          고정 Task 는 `### Task 0 (고정)`·`### Task N (고정)` 두 헤더만이며 필드 검사·참조 집계에서 제외한다.
#
# 사용법:
#   check-plan.sh --trace <spec 파일> <plan 파일>
#
# 출력 (위반 1건 1행):
#   R 없는 DoD 그룹: R<n>               — 포함 목록에 없는 번호의 DoD 그룹
#   DoD 없는 R: R<n>                    — DoD 그룹이 없는 포함 요구사항
#   Task 없는 R: R<n>                   — 어느 일반 Task 도 대상으로 삼지 않는 포함 요구사항
#   대상 요구사항 없는 일반 Task: <헤더> — 필드가 없는 일반 Task
#   추적 불가: …                         — 포함 목록이 비었거나 plan 에 Task 블록이 없음 (공집합을 통과로 보지 않는다)
#
# 종료 코드: 0 통과(무출력) / 1 위반 있음 / 2 사용오류(모드 미지정·인자 부족·읽을 수 없는 파일·알 수 없는 옵션)

set -o pipefail

usage() { sed -n '3,27p' "$0" | sed 's/^# \{0,1\}//'; }

mode=''
spec=''
plan=''

while [ $# -gt 0 ]; do
  case "$1" in
    --trace)
      [ -z "$mode" ] || { echo "error: 모드는 하나만 지정합니다" >&2; exit 2; }
      mode='trace'
      [ $# -ge 3 ] || { echo "error: $1 에 <spec 파일> <plan 파일> 두 인자가 필요합니다" >&2; exit 2; }
      spec="$2"; plan="$3"; shift 3 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: 알 수 없는 인자 — $1" >&2; exit 2 ;;
  esac
done

[ -n "$mode" ] || { echo "error: --trace 가 필요합니다" >&2; usage >&2; exit 2; }

for f in "$spec" "$plan"; do
  [ -r "$f" ] || { echo "error: 읽을 수 없는 파일 — $f" >&2; exit 2; }
done

# spec — 포함 목록은 `**포함**` 다음 행부터 다음 굵은 라벨(`**제외**`)·`## ` 헤더·구분선 앞까지다.
# DoD 그룹은 `### R<n>: ` 헤더만 센다. `### 공통` 은 R 이 아니라 여기 걸리지 않는다.
spec_out="$(awk '
  /^\*\*포함\*\*[[:space:]]*$/ { inc = 1; next }
  inc && (/^\*\*/ || /^## / || /^---/) { inc = 0 }
  inc && /^- R[0-9]+: / { n = $0; sub(/^- R/, "", n); sub(/:.*/, "", n); print "INC " n + 0 }
  /^### R[0-9]+: /      { n = $0; sub(/^### R/, "", n); sub(/:.*/, "", n); print "DOD " n + 0 }
' "$spec")"

# plan — 블록 단위로 센다. 고정 Task 두 헤더만 제외하며, 부분 문자열 `고정` 으로 판정하지 않는다
# (일반 Task 제목에 든 단어를 오분류하고, 일반 Task 에 `(고정)` 을 붙여 필드 계약을 우회하는 것을 막는다).
plan_out="$(awk '
  function flush() { if (o && !fixed && c == 0) print "NOFIELD " t }
  /^### Task / { flush(); o = 1; t = $0; sub(/^### /, "", t); c = 0; fixed = ($0 ~ /^### Task (0|N) \(고정\)/) }
  o && !fixed && /^- \*\*대상 요구사항\*\*:/ {
    c++
    v = $0; sub(/^- \*\*대상 요구사항\*\*:/, "", v)
    while (match(v, /R[0-9]+/)) { print "REF " substr(v, RSTART + 1, RLENGTH - 1) + 0; v = substr(v, RSTART + RLENGTH) }
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
