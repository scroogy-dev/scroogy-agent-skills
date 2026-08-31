#!/usr/bin/env bash
#
# check-quiz.sh - git-review-quiz 산출 파일의 형식 규칙 R1~R7 을 결정적으로 판정한다.
#
# `git-review-quiz/SKILL.md` 와 `templates/quiz-template.md` 가 규격의 SSoT 이며
# 이 스크립트는 그 규칙을 옮긴 사본이다. 한쪽을 고치면 나머지 둘과 `tests/` 의 기대값을 함께 갱신한다.
#
# 사용법:
#   check-quiz.sh <산출 파일>
#   check-quiz.sh --comment [--head <SHA>] [--base <SHA>] <산출 파일>
#
# 판정 규칙:
#   R1 `## 문항` 아래 모든 `### ` 헤더가 문항이며 `### Q<n> [<관점> · <형식>]` 이고 번호가 1 부터 연속 증가한다
#   R2 헤더 다음 첫 비어 있지 않은 행이 위치 행이고, 형식이 위치: `<경로>:<줄 범위>` 다 (경로·줄 범위는 백틱 필수)
#      (뒤에 ` (base)`, ` ([permalink](<URL>))` 병기를 허용한다.
#       `--comment` 모드에서는 모든 위치 행에 규격에 맞는 permalink 를 필수로 요구한다)
#   R3 힌트 접기 블록이 문항마다 정확히 1 개이고, 문항 종료 시 접기 깊이가 0 이다
#   R4 정답 접기 블록이 문항마다 정확히 1 개이고 힌트 블록 뒤의 다른 접기 블록에 온다.
#      블록 안 첫 내용 행이 객관식은 `(<문자>). <해설>`, 주관식은 모범 답안이고 `근거: <내용>` 행이 있다
#      (비즈니스 문항은 `정책 근거: <내용>` 행도 둔다)
#   R5 접기 밖 선택지는 첫 접기 앞에만 둔다. 객관식은 그것이 2 개 이상·라벨 `(a)` 부터 연속이고,
#      정답 문자가 그 라벨 중 하나다. 주관식은 0 개다
#   R6 문항 블록의 접기 밖에 `정답` 으로 시작하는 행이 없다
#   R7 문서 골격을 지킨다 (`## 대상`·`## 문항` 각 1 개, 문항은 `## 문항` 아래에만 1 개 이상,
#      `## 응답 기록` 은 선택이며 마지막 문항 뒤. `--comment` 모드에서는 `## 응답 기록` 을 두지 않는다)
#
# 종료 코드: 0 통과(무출력) / 1 위반(`위반 R<n> [Q<m>]: <사유>` 를 1 행씩 출력) / 2 사용오류
#
# 전제: 문항 블록 안에 코드 블록을 두지 않는다. 블록 경계와 접기 판정이 행 접두어를 그대로 보므로
#       코드 블록 안의 `### `·`<details>` 행도 문서 구조로 센다.

set -o pipefail

usage() { sed -n '3,30p' "$0" | sed 's/^# \{0,1\}//'; }

target=''
mode='plain'
head_sha=''
base_sha=''

need_sha() {
  case "$2" in
    [0-9a-f]*) [ "${#2}" -eq 40 ] || { echo "error: $1 은 40자 커밋 SHA 여야 합니다 ($2)" >&2; exit 2; } ;;
    *) echo "error: $1 은 40자 커밋 SHA 여야 합니다 ($2)" >&2; exit 2 ;;
  esac
  case "$2" in *[!0-9a-f]*) echo "error: $1 은 40자 커밋 SHA 여야 합니다 ($2)" >&2; exit 2 ;; esac
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --comment) mode='comment'; shift ;;
    --head) [ $# -ge 2 ] || { echo "error: --head 에 값이 필요합니다" >&2; exit 2; }
            need_sha --head "$2"; head_sha="$2"; shift 2 ;;
    --base) [ $# -ge 2 ] || { echo "error: --base 에 값이 필요합니다" >&2; exit 2; }
            need_sha --base "$2"; base_sha="$2"; shift 2 ;;
    -*) echo "error: 알 수 없는 인자 ($1)" >&2; exit 2 ;;
    *)
      [ -z "$target" ] || { echo "error: 파일은 하나만 지정합니다" >&2; exit 2; }
      target="$1"; shift ;;
  esac
done

[ -n "$target" ] || { echo "error: 산출 파일 경로가 필요합니다" >&2; usage >&2; exit 2; }
{ [ -f "$target" ] && [ -r "$target" ]; } || { echo "error: 읽을 수 없는 파일 ($target)" >&2; exit 2; }

# SHA 대조는 댓글 모드 전용이다. 일반 모드에서 받으면 조용히 무시되므로 사용오류로 막는다.
if [ "$mode" != 'comment' ] && { [ -n "$head_sha" ] || [ -n "$base_sha" ]; }; then
  echo "error: --head/--base 는 --comment 와 함께 씁니다" >&2; exit 2
fi

violations="$(awk -v mode="$mode" -v head_sha="$head_sha" -v base_sha="$base_sha" '
  BEGIN { expect = 1; qid = ""; alpha = "abcdefghijklmnopqrstuvwxyz" }

  function qerr(rule, msg) { qn++; qmsg[qn] = "위반 " rule " Q" qid ": " msg }
  function derr(msg)       { dn++; dmsg[dn] = "위반 R7: " msg }

  # permalink URL 이 `https://<호스트>/<소유자>/<저장소>/blob/<40자 SHA>/<경로>#L<n>[-L<m>]` 인지 본다.
  # 어긋난 첫 축의 이름을 돌려주고, 규격을 지키면 빈 문자열을 돌려준다.
  function link_bad(url,   n, A, sha, p, anchor, path) {
    if (url !~ /^https:\/\/[^\/]/) return "`https://` 접두어"
    n = split(url, A, "/")
    if (n < 8 || A[3] == "" || A[4] == "" || A[5] == "") return "호스트·소유자·저장소 경로"
    if (A[6] != "blob") return "`blob/<SHA>` 경로"
    sha = A[7]
    if (length(sha) != 40 || sha !~ /^[0-9a-f]+$/) return "40자 커밋 SHA"
    p = index(url, "#L")
    if (p == 0) return "줄 앵커"
    anchor = substr(url, p)
    if (anchor !~ /^#L[0-9]+$/ && anchor !~ /^#L[0-9]+-L[0-9]+$/) return "줄 앵커 형식"
    path = substr(url, index(url, "/blob/") + 6 + 41, p - (index(url, "/blob/") + 6 + 41))
    if (path == "") return "파일 경로"
    return ""
  }

  function link_sha(url,   A) { split(url, A, "/"); return A[7] }

  # 문항 블록 하나를 닫으면서 R1~R6 을 판정한다.
  function flush_q() {
    if (qid == "") return

    if (!hdr_ok)
      qerr("R1", "헤더 형식이 `### Q<n> [<관점> · <형식>]` 이 아닙니다 (" hdr_line "행)")

    if (!first_is_loc)
      qerr("R2", "헤더 다음 첫 행이 위치 행이 아닙니다")
    if (loc_bad > 0)
      qerr("R2", "위치 행 형식이 위치: `<경로>:<줄 범위>` 가 아닙니다. 경로·줄 범위를 백틱으로 감쌉니다 (" loc_bad_line "행)")
    if (loc_ok == 0)
      qerr("R2", "형식에 맞는 위치 행이 없습니다")
    if (link_miss > 0)
      qerr("R2", "댓글 모드 위치 행에 permalink 병기가 없습니다 (" link_miss_line "행)")
    if (link_bad_axis != "")
      qerr("R2", "permalink 의 " link_bad_axis " 이(가) 규격과 다릅니다 (" link_bad_line "행)")
    if (link_sha_bad > 0)
      qerr("R2", "permalink 커밋 SHA 가 기준 커밋과 다릅니다 (" link_sha_line "행)")

    if (hint_n == 0)      qerr("R3", "힌트 블록이 없습니다")
    else if (hint_n > 1)  qerr("R3", "힌트 블록이 " hint_n "개입니다 (1개여야 합니다)")
    if (depth != 0)       qerr("R3", "접기 블록이 닫히지 않았습니다 (문항 종료 시 깊이 " depth ")")
    if (unbalanced)       qerr("R3", "짝이 없는 `</details>` 가 있습니다 (" unbalanced_line "행)")

    if (ans_n == 0)       qerr("R4", "정답 블록이 없습니다")
    else if (ans_n > 1)   qerr("R4", "정답 블록이 " ans_n "개입니다 (1개여야 합니다)")
    else if (hint_n >= 1 && ans_line < hint_line)
      qerr("R4", "정답 블록이 힌트 블록보다 앞에 있습니다")
    else if (hint_n >= 1 && ans_blk == hint_blk)
      qerr("R4", "정답 블록이 힌트 블록과 같은 접기 안에 있습니다")

    # 정답 블록의 내용 계약. 블록의 존재·위치만 보면 빈 정답·형식 이탈·근거 누락이 통과하고,
    # 6 단계 형식 검사가 잘못된 정답을 실은 산출물을 그대로 게시로 넘긴다.
    if (ans_n == 1) {
      if (ans_first == "")
        qerr("R4", "정답 블록에 내용이 없습니다 (" ans_line "행)")
      else if (qfmt == "객관식" && ans_first !~ /^\([a-z]\)\. [[:space:]]*[^[:space:]]/)
        qerr("R4", "객관식 정답 블록 첫 행이 `(<문자>). <해설>` 형식이 아닙니다 (" ans_first_line "행)")
      else if (qfmt == "주관식" && (ans_first ~ /^근거: / || ans_first ~ /^정책 근거: /))
        qerr("R4", "주관식 정답 블록에 모범 답안이 없습니다 (" ans_first_line "행)")

      if (ans_first != "" && basis_n == 0)
        qerr("R4", "정답 블록에 `근거: <내용>` 행이 없습니다")
      if (ans_first != "" && qpersp == "비즈니스" && pbasis_n == 0)
        qerr("R4", "비즈니스 문항 정답 블록에 `정책 근거: <내용>` 행이 없습니다")

      # 라벨이 연속일 때만 정답 문자를 대조한다. 연속이 아니면 R5 가 이미 그 사실을 보고하며,
      # 어긋난 라벨 집합을 기준으로 삼으면 사유가 뒤바뀐다.
      if (qfmt == "객관식" && opt_bad == "" && opt_n > 0 && ans_first ~ /^\([a-z]\)\. [[:space:]]*[^[:space:]]/) {
        alab = substr(ans_first, 2, 1)
        if (index(substr(alpha, 1, opt_n), alab) == 0)
          qerr("R5", "정답 문자 `(" alab ")` 가 선택지 라벨에 없습니다 (" ans_first_line "행)")
      }
    }

    # 헤더 형식이 깨진 문항은 관점·형식을 확정할 수 없어 R5 를 건너뛴다 (R1 이 이미 보고한다).
    if (qfmt == "객관식" && opt_n < 2)
      qerr("R5", "객관식 선택지가 " opt_n "개입니다 (2개 이상이어야 합니다)")
    if (qfmt == "객관식" && opt_bad != "")
      qerr("R5", "선택지 라벨이 `(a)` 부터 연속 증가하지 않습니다 (" opt_bad ")")
    if (qfmt == "객관식" && opt_late > 0)
      qerr("R5", "선택지가 첫 접기 뒤에 있습니다 (" opt_late_line "행)")
    if (qfmt == "주관식" && opt_n + opt_late > 0)
      qerr("R5", "주관식에 선택지가 " (opt_n + opt_late) "개 있습니다 (0개여야 합니다)")

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

  # `## 문항` 아래의 모든 `### ` 헤더를 문항 후보로 연다. 인식 범위 밖 헤더를 조용히 버리면
  # 그 블록의 R2~R6 검사가 통째로 빠지고, 마지막 문항이면 번호 연속성으로도 잡히지 않는다.
  /^### / {
    flush_q()
    if (cur == "문항" || $0 ~ /^### Q[0-9]+ \[/) {
      total_q++
      last_q_line = NR
      hdr_line = NR

      hdr_ok = ($0 ~ /^### Q[0-9]+ \[(테크|비즈니스) · (객관식|주관식)\][[:space:]]*$/)
      if ($0 ~ /^### Q[0-9]+([ \[]|$)/) {
        match($0, /Q[0-9]+/)
        qid = substr($0, RSTART + 1, RLENGTH - 1)
        num = qid + 0
        if (num != expect)
          qerr("R1", "문항 번호가 1부터 연속이 아닙니다 (기대 Q" expect ")")
        expect = num + 1
      } else {
        # 번호를 읽을 수 없는 헤더는 등장 순번으로 식별한다. 연속성 판정은 다음 문항으로 넘긴다.
        qid = total_q
        hdr_ok = 0
        expect++
      }

      qfmt = ""; qpersp = ""
      if (hdr_ok) {
        qfmt = ($0 ~ /객관식/) ? "객관식" : "주관식"
        qpersp = ($0 ~ /비즈니스/) ? "비즈니스" : "테크"
      }

      if (cur != "문항")
        outside = (outside == "" ? "" : outside ", ") "Q" qid "(" NR "행)"

      first_seen = 0; first_is_loc = 0
      loc_ok = 0; loc_bad = 0; loc_bad_line = 0
      link_miss = 0; link_miss_line = 0
      link_bad_axis = ""; link_bad_line = 0
      link_sha_bad = 0; link_sha_line = 0
      depth = 0; seen_details = 0; blk = 0
      unbalanced = 0; unbalanced_line = 0
      hint_n = 0; hint_line = 0; hint_blk = 0
      ans_n = 0; ans_line = 0; ans_blk = -1
      in_ans = 0; ans_first = ""; ans_first_line = 0; basis_n = 0; pbasis_n = 0
      opt_n = 0; opt_bad = ""; opt_late = 0; opt_late_line = 0; r6_list = ""
    }
    next
  }

  qid != "" {
    if (!first_seen && $0 !~ /^[[:space:]]*$/) {
      first_seen = 1
      first_is_loc = ($0 ~ /^위치: /)
    }

    if ($0 ~ /^위치: /) {
      if ($0 ~ /^위치: `[^`]+:[0-9]+(-[0-9]+)?`( \(base\))?( \(\[permalink\]\(https?:\/\/[^)]+\)\))?[[:space:]]*$/) {
        loc_ok++
        if (mode == "comment") {
          if (match($0, /\(\[permalink\]\([^)]+\)\)/)) {
            url = substr($0, RSTART + 13, RLENGTH - 15)
            bad = link_bad(url)
            if (bad != "") {
              if (link_bad_axis == "") { link_bad_axis = bad; link_bad_line = NR }
            } else {
              want = ($0 ~ /` \(base\)/) ? base_sha : head_sha
              if (want != "" && link_sha(url) != want) {
                link_sha_bad++; if (link_sha_line == 0) link_sha_line = NR
              }
            }
          } else {
            link_miss++; if (link_miss_line == 0) link_miss_line = NR
          }
        }
      }
      else { loc_bad++; if (loc_bad_line == 0) loc_bad_line = NR }
    }

    # 접기 안팎은 이 행 이전까지의 깊이로 판정한다. 깊이 갱신은 행 끝에서 한다.
    outside_details = (depth == 0)

    if (outside_details && $0 ~ /^정답/)
      r6_list = (r6_list == "" ? "" : r6_list ", ") NR "행"

    # 접기 밖 선택지는 첫 접기 앞에만 유효하다. 첫 접기 뒤의 선택지를 세지 않으면
    # 주관식이 힌트 뒤에 선택지를 두어 R5 의 0 개 규칙을 우회한다.
    if (outside_details && $0 ~ /^- \([a-z]\) /) {
      if (!seen_details) {
        opt_n++
        lab = substr($0, 4, 1)
        want_lab = substr(alpha, opt_n, 1)
        if (lab != want_lab && opt_bad == "")
          opt_bad = NR "행: `(" lab ")` 자리에 `(" want_lab ")` 가 와야 합니다"
      } else {
        opt_late++; if (opt_late_line == 0) opt_late_line = NR
      }
    }

    # 정답 블록 안의 내용 행을 모은다. 태그 처리 전이라 `in_ans` 는 이전 행까지의 상태이며,
    # 여닫는 태그 행과 빈 행은 내용으로 세지 않는다. 한 행짜리 HTML 주석도 제외한다.
    # 렌더링되지 않아 읽는 사람에게 해설·모범 답안으로 보이지 않기 때문이다.
    if (in_ans && $0 !~ /<\/?details>/ && $0 !~ /^[[:space:]]*$/ \
        && $0 !~ /^[[:space:]]*<!--.*-->[[:space:]]*$/) {
      if (ans_first == "") { ans_first = $0; ans_first_line = NR }
      if ($0 ~ /^근거: [^[:space:]]/) basis_n++
      if ($0 ~ /^정책 근거: [^[:space:]]/) pbasis_n++
    }

    # 태그는 같은 행 안에서도 등장 순서대로 처리한다. 행 단위로 개수만 합산하면
    # `</details><details><details>` 처럼 선행 닫기가 후행 열기에 상쇄되어 짝 없는 닫기를 놓친다.
    s = $0; o = 0
    while (match(s, /<\/?details>/)) {
      tok = substr(s, RSTART, RLENGTH)
      s = substr(s, RSTART + RLENGTH)
      if (tok == "<details>") {
        o++; seen_details = 1
        if (depth == 0) blk++
        depth++
      } else if (depth > 0) {
        depth--
      } else if (!unbalanced) {
        unbalanced = 1; unbalanced_line = NR
      }
    }

    # 정답 블록은 최상위 접기이므로 깊이가 0 으로 돌아오면 닫힌 것으로 본다.
    if (in_ans && depth == 0) in_ans = 0

    # 여는 행과 summary 가 한 행에 있어도 접기 안으로 세도록 갱신 뒤에 판정한다.
    if (depth > 0 || o > 0) {
      if ($0 ~ /^[[:space:]]*<summary>힌트<\/summary>[[:space:]]*$/) { hint_n++; if (hint_line == 0) { hint_line = NR; hint_blk = blk } }
      if ($0 ~ /^[[:space:]]*<summary>정답·해설<\/summary>[[:space:]]*$/) { ans_n++; if (ans_line == 0) { ans_line = NR; ans_blk = blk; in_ans = 1 } }
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
    if (mode == "comment" && n_record >= 1)
      derr("댓글 본문에는 `## 응답 기록` 을 두지 않습니다 (" rec_line "행)")

    for (i = 1; i <= dn; i++) print dmsg[i]
    for (i = 1; i <= qn; i++) print qmsg[i]
  }
' "$target")" || { echo "error: 파일을 읽지 못했습니다 ($target)" >&2; exit 2; }

[ -z "$violations" ] || { printf '%s\n' "$violations"; exit 1; }
