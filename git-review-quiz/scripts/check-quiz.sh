#!/usr/bin/env bash
#
# check-quiz.sh - git-review-quiz 산출 파일의 형식 규칙 R1~R7 을 결정적으로 판정한다.
#
# `git-review-quiz/SKILL.md` 와 `templates/quiz-template.md` 가 규격의 SSoT 이며
# 이 스크립트는 그 규칙을 옮긴 사본이다. 한쪽을 고치면 나머지 둘과 `tests/` 의 기대값을 함께 갱신한다.
#
# 사용법:
#   check-quiz.sh <산출 파일>
#
# 판정 규칙:
#   R1 문항 헤더가 `### Q<n> [<관점> · <형식>]` 이고 번호가 1 부터 연속 증가한다
#   R2 헤더 다음 첫 비어 있지 않은 행이 위치 행이고, 형식이 `위치: <경로>:<줄 범위>` 다
#      (뒤에 ` (base)`, ` ([permalink](<URL>))` 병기를 허용한다)
#   R3 힌트 접기 블록이 문항마다 정확히 1 개다
#   R4 정답 접기 블록이 문항마다 정확히 1 개이고 힌트 블록 뒤에 온다
#   R5 객관식은 첫 접기 앞 선택지가 2 개 이상, 주관식은 0 개다
#   R6 문항 블록의 접기 밖에 `정답` 으로 시작하는 행이 없다
#   R7 문서 골격을 지킨다 (`## 대상`·`## 문항` 각 1 개, 문항은 `## 문항` 아래에만 1 개 이상,
#      `## 응답 기록` 은 선택이며 마지막 문항 뒤)
#
# 종료 코드: 0 통과(무출력) / 1 위반(`위반 R<n> [Q<m>]: <사유>` 를 1 행씩 출력) / 2 사용오류
#
# 전제: 문항 블록 안에 코드 블록을 두지 않는다. 블록 경계와 접기 판정이 행 접두어를 그대로 보므로
#       코드 블록 안의 `### `·`<details>` 행도 문서 구조로 센다.

set -o pipefail

usage() { sed -n '3,23p' "$0" | sed 's/^# \{0,1\}//'; }

target=''

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -*) echo "error: 알 수 없는 인자 ($1)" >&2; exit 2 ;;
    *)
      [ -z "$target" ] || { echo "error: 파일은 하나만 지정합니다" >&2; exit 2; }
      target="$1"; shift ;;
  esac
done

[ -n "$target" ] || { echo "error: 산출 파일 경로가 필요합니다" >&2; usage >&2; exit 2; }
{ [ -f "$target" ] && [ -r "$target" ]; } || { echo "error: 읽을 수 없는 파일 ($target)" >&2; exit 2; }

violations="$(awk '
  BEGIN { expect = 1; qid = "" }

  function qerr(rule, msg) { qn++; qmsg[qn] = "위반 " rule " Q" qid ": " msg }
  function derr(msg)       { dn++; dmsg[dn] = "위반 R7: " msg }

  # 문항 블록 하나를 닫으면서 R1~R6 을 판정한다.
  function flush_q() {
    if (qid == "") return

    if (!hdr_ok)
      qerr("R1", "헤더 형식이 `### Q<n> [<관점> · <형식>]` 이 아닙니다")

    if (!first_is_loc)
      qerr("R2", "헤더 다음 첫 행이 위치 행이 아닙니다")
    if (loc_bad > 0)
      qerr("R2", "위치 행 형식이 `위치: <경로>:<줄 범위>` 가 아닙니다 (" loc_bad_line "행)")
    if (loc_ok == 0)
      qerr("R2", "형식에 맞는 위치 행이 없습니다")

    if (hint_n == 0)      qerr("R3", "힌트 블록이 없습니다")
    else if (hint_n > 1)  qerr("R3", "힌트 블록이 " hint_n "개입니다 (1개여야 합니다)")

    if (ans_n == 0)       qerr("R4", "정답 블록이 없습니다")
    else if (ans_n > 1)   qerr("R4", "정답 블록이 " ans_n "개입니다 (1개여야 합니다)")
    else if (hint_n >= 1 && ans_line < hint_line)
      qerr("R4", "정답 블록이 힌트 블록보다 앞에 있습니다")

    # 헤더 형식이 깨진 문항은 관점·형식을 확정할 수 없어 R5 를 건너뛴다 (R1 이 이미 보고한다).
    if (qfmt == "객관식" && opt_n < 2)
      qerr("R5", "객관식 선택지가 " opt_n "개입니다 (2개 이상이어야 합니다)")
    if (qfmt == "주관식" && opt_n > 0)
      qerr("R5", "주관식에 선택지가 " opt_n "개 있습니다 (0개여야 합니다)")

    if (r6_list != "")
      qerr("R6", "접기 밖에 `정답` 으로 시작하는 행이 있습니다 (" r6_list ")")

    qid = ""
  }

  /^## / {
    flush_q()
    h2 = $0
    sub(/^## /, "", h2)
    sub(/[[:space:]]+$/, "", h2)
    cur = h2
    if (h2 == "대상")           n_target++
    else if (h2 == "문항")      n_quiz++
    else if (h2 == "응답 기록") { n_record++; if (rec_line == 0) rec_line = NR }
    next
  }

  /^### / {
    flush_q()
    if ($0 ~ /^### Q[0-9]+ \[/) {
      total_q++
      last_q_line = NR
      match($0, /Q[0-9]+/)
      qid = substr($0, RSTART + 1, RLENGTH - 1)
      num = qid + 0
      if (num != expect)
        qerr("R1", "문항 번호가 1부터 연속이 아닙니다 (기대 Q" expect ")")
      expect = num + 1

      hdr_ok = ($0 ~ /^### Q[0-9]+ \[(테크|비즈니스) · (객관식|주관식)\][[:space:]]*$/)
      qfmt = ""
      if (hdr_ok) qfmt = ($0 ~ /객관식/) ? "객관식" : "주관식"

      if (cur != "문항")
        outside = (outside == "" ? "" : outside ", ") "Q" qid "(" NR "행)"

      first_seen = 0; first_is_loc = 0
      loc_ok = 0; loc_bad = 0; loc_bad_line = 0
      depth = 0; seen_details = 0
      hint_n = 0; hint_line = 0; ans_n = 0; ans_line = 0
      opt_n = 0; r6_list = ""
    }
    next
  }

  qid != "" {
    if (!first_seen && $0 !~ /^[[:space:]]*$/) {
      first_seen = 1
      first_is_loc = ($0 ~ /^위치: /)
    }

    if ($0 ~ /^위치: /) {
      if ($0 ~ /^위치: `[^`]+:[0-9]+(-[0-9]+)?`( \(base\))?( \(\[permalink\]\(https?:\/\/[^)]+\)\))?[[:space:]]*$/)
        loc_ok++
      else { loc_bad++; if (loc_bad_line == 0) loc_bad_line = NR }
    }

    # 접기 안팎은 이 행 이전까지의 깊이로 판정한다. 깊이 갱신은 행 끝에서 한다.
    outside_details = (depth == 0)

    if (outside_details && $0 ~ /^정답/)
      r6_list = (r6_list == "" ? "" : r6_list ", ") NR "행"

    if (outside_details && !seen_details && $0 ~ /^- \([a-z]\) /)
      opt_n++

    s = $0; o = gsub(/<details>/, "", s)
    s = $0; c = gsub(/<\/details>/, "", s)
    if (o > 0) seen_details = 1
    depth += o - c
    if (depth < 0) depth = 0

    # 여는 행과 summary 가 한 행에 있어도 접기 안으로 세도록 갱신 뒤에 판정한다.
    if (depth > 0 || o > 0) {
      if ($0 ~ /^[[:space:]]*<summary>힌트<\/summary>[[:space:]]*$/) { hint_n++; if (hint_line == 0) hint_line = NR }
      if ($0 ~ /^[[:space:]]*<summary>정답·해설<\/summary>[[:space:]]*$/) { ans_n++; if (ans_line == 0) ans_line = NR }
    }
  }

  END {
    flush_q()

    if (n_target != 1) derr("`## 대상` 헤더가 " (n_target + 0) "개입니다 (1개여야 합니다)")
    if (n_quiz != 1)   derr("`## 문항` 헤더가 " (n_quiz + 0) "개입니다 (1개여야 합니다)")
    if (n_record > 1)  derr("`## 응답 기록` 헤더가 " n_record "개입니다 (0개 또는 1개여야 합니다)")
    if (total_q == 0)  derr("문항이 없습니다 (1개 이상이어야 합니다)")
    if (outside != "") derr("문항 블록이 `## 문항` 아래에 있지 않습니다 (" outside ")")
    if (n_record >= 1 && rec_line < last_q_line)
      derr("`## 응답 기록` 이 마지막 문항 블록보다 앞에 있습니다")

    for (i = 1; i <= dn; i++) print dmsg[i]
    for (i = 1; i <= qn; i++) print qmsg[i]
  }
' "$target")" || { echo "error: 파일을 읽지 못했습니다 ($target)" >&2; exit 2; }

[ -z "$violations" ] || { printf '%s\n' "$violations"; exit 1; }
