#!/usr/bin/env bash
#
# sync-owned.sh — ai-workspace 가 소유한 파일과 구간을 설치본에서 템플릿 최신본으로 맞춘다.
#
# SKILL.md update-3단계와 update-4단계 `#### 표준 구간 최신화` 가 호출한다. 구간 교체는 같은 입력에
# 같은 결과가 나와야 하고 실패를 보고해야 해서 헬퍼로 둔다 (`.ai/10_rules/architecture.md` "디자인 원칙").
#
# 사용법:
#   sync-owned.sh --dirs <templates 디렉토리> <.ai 디렉토리>
#   sync-owned.sh --context <templates 디렉토리> <.ai 디렉토리>
#   sync-owned.sh --profile <dev|doc> <.ai 디렉토리>
#
# --dirs (update-3):
#   없을 때만 복사: 30_contract·40_domain·50_adr·60_codebase·70_ledger 의 index.md, 40_domain/glossary.md
#   항상 최신본: 70_ledger/ledger-entry-template.md
#   구간 교체: 50_adr/index.md 의 `## 수명 주기`, 70_ledger/index.md 의 머리말과 `## 수명 주기`
# --context (update-4):
#   AI-CONTEXT.md 표준 섹션 4개를 본문 2번째 줄의 SSoT 선언에 맞는 템플릿으로 교체한다.
#   선언이 dev·doc 표준 문구가 아니면 고를 근거가 없어 실패로 보고한다.
# --profile (update-4):
#   AI-CONTEXT.md `## 프로젝트 도메인` 첫 표의 `profile` 행을 명시한 값의 한 행으로 맞춘다.
#   행이 없으면 표 끝에 넣고, 둘 이상이면 첫 행을 그 값으로 바꾸고 나머지를 지운다. 섹션이나 표가 없으면 실패로 보고한다.
#
# 구간 규칙:
#   코드 펜스(앞 공백 3칸까지, 백틱·물결 3개 이상)와 HTML 주석 안의 제목은 제목으로 세지 않는다. 제목 끝 공백은 무시한다.
#   닫히지 않은 코드 펜스·HTML 주석, 같은 제목 둘 이상, 템플릿에 구간 없음은 실패이며 그 파일을 바꾸지 않는다.
#   없는 섹션은 파일 끝에 템플릿 순서로 추가한다. 템플릿에 없는 `###` 소제목은 원래 순서대로 템플릿 본문 뒤에 남긴다.
#   구간 끝의 빈 줄만 다르면 변경으로 보지 않는다.
#
# 출력: 바뀐 대상마다 1행. 경로는 .ai 기준 상대 경로이고 바뀐 내용이 없으면 출력하지 않는다.
#   교체: <경로>[ <구간>]
#   추가: <경로>[ <구간>]
#   실패: <경로>[ <구간>] — <사유>
# 종료 코드: 0 실패 없음 / 1 실패 1건 이상(다른 대상은 계속 처리) / 2 사용오류

set -o pipefail
export LC_ALL=C

usage() { sed -n '3,34p' "$0" | sed 's/^# \{0,1\}//'; }

failures=0
serial=0

fail_line() { echo "실패: $1 — $2"; failures=$((failures + 1)); }

# 코드 펜스와 HTML 주석 상태를 한 행씩 추적하는 awk 함수. 호출 전의 `fence_ch`·`in_comment` 가 그 행이 펜스·주석 안인지 알려 준다.
# check-context.sh 에 같은 사본이 있다. 읽기와 쓰기가 같은 범위를 봐야 하므로 함께 고친다 (tests/run-tests.sh 가 일치를 검사한다).
MD_TRACK_AWK='
  function fence_run(s, ch,    n) {
    sub(/^ ? ? ?/, "", s)
    n = 0
    while (substr(s, n + 1, 1) == ch) n++
    fence_rest = substr(s, n + 1)
    return n
  }
  # 인라인 코드 안의 주석 표식은 주석으로 세지 않는다.
  function scan_comment(s,    p) {
    if (!in_comment) gsub(/`[^`]*`/, "", s)
    while (1) {
      if (in_comment) {
        p = index(s, "-->"); if (!p) return
        in_comment = 0; s = substr(s, p + 3)
      } else {
        p = index(s, "<!--"); if (!p) return
        in_comment = 1; s = substr(s, p + 4)
      }
    }
  }
  function md_track(line,    c, n) {
    if (fence_ch) {
      if (fence_run(line, fence_ch) >= fence_len && fence_rest ~ /^[[:space:]]*$/) fence_ch = ""
    } else if (in_comment) {
      scan_comment(line)
    } else if (line ~ /^ ? ? ?(```|~~~)/) {
      c = substr(line, match(line, /[`~]/), 1); n = fence_run(line, c)
      # 정보 문자열에 백틱이 있는 행은 펜스가 아니라 인라인 코드다.
      if (c == "`" && index(fence_rest, "`")) scan_comment(line)
      else { fence_ch = c; fence_len = n }
    } else {
      scan_comment(line)
    }
  }
'

# split_md <파일> <디렉토리> <제목 접두어>
# 파일을 제목 단위 조각으로 나눈다. <디렉토리>/0 은 첫 제목 앞, <디렉토리>/<k> 는 k번째 제목 구간이고
# <디렉토리>/titles 의 k번째 줄이 그 제목이다. 닫히지 않은 펜스·주석이 있으면 사유를 출력하고 1을 돌려준다.
split_md() {
  mkdir -p "$2" || return 1
  OUT_DIR="$2" HEAD="$3" awk "$MD_TRACK_AWK"'
    BEGIN {
      dir = ENVIRON["OUT_DIR"]; head = ENVIRON["HEAD"]
      k = 0; seg = dir "/0"; printf "" > seg
      titles = dir "/titles"; printf "" > titles
    }
    {
      if (!fence_ch && !in_comment && index($0, head) == 1) {
        close(seg); k++; seg = dir "/" k
        t = $0; sub(/[[:space:]]+$/, "", t); print t > titles
      }
      print > seg
      md_track($0)
    }
    END {
      if (fence_ch) { print "닫히지 않은 코드 펜스"; exit 1 }
      if (in_comment) { print "닫히지 않은 HTML 주석"; exit 1 }
    }
  ' "$1"
}

# trim_tail <파일> — 끝 빈 줄을 뺀 내용을 출력한다.
trim_tail() {
  awk 'NF { for (i = 1; i <= n; i++) print buf[i]; n = 0; print; next } { buf[++n] = $0 }' "$1"
}

# merge_section <설치본 구간> <템플릿 구간> <작업 디렉토리> — 템플릿 본문 뒤에 템플릿에 없는 `###` 소제목을 이어 출력한다.
merge_section() {
  local inst="$1" tpl="$2" d="$3" k=0 t
  split_md "$inst" "$d/i" '### ' >/dev/null || return 1
  split_md "$tpl" "$d/t" '### ' >/dev/null || return 1
  trim_tail "$tpl"
  while IFS= read -r t; do
    k=$((k + 1))
    grep -qxF -e "$t" "$d/t/titles" && continue
    echo
    trim_tail "$d/i/$k"
  done < "$d/i/titles"
}

# target_problem <경로> — 읽고 덮어쓸 수 없는 설치본이면 사유를 출력한다. 없는 파일은 문제로 보지 않는다.
target_problem() {
  if [ -L "$1" ] && [ ! -e "$1" ]; then echo '끊긴 심볼릭 링크'
  elif [ ! -e "$1" ]; then :
  elif [ ! -f "$1" ]; then echo '일반 파일이 아님'
  elif [ ! -r "$1" ]; then echo '읽을 수 없음'
  fi
}

# write_file <상대 경로> <원본> <대상> — 권한과 심볼릭 링크를 유지하려고 대상을 바꿔치지 않고 내용만 쓴다.
write_file() {
  mkdir -p "$(dirname "$3")" 2>/dev/null || { fail_line "$1" '디렉토리를 만들 수 없음'; return 1; }
  { cat "$2" > "$3"; } 2>/dev/null || { fail_line "$1" '쓰기 실패'; return 1; }
}

# put_segment <설치본 구간> <새 구간> <결과 파일> — 끝 빈 줄만 다르면 설치본을 그대로 잇고 1을, 바꾸면 0을 돌려준다.
put_segment() {
  trim_tail "$1" > "$1.trim"
  if cmp -s "$1.trim" "$2"; then
    cat "$1" >> "$3"
    return 1
  fi
  cat "$2" >> "$3"
  echo >> "$3"
}

# sync_sections <상대 경로> <템플릿 파일> <head|nohead> <제목>...
# 대상 구간을 교체하거나 추가한다. 실패가 하나라도 있으면 그 파일을 바꾸지 않고 실패 행만 낸다.
sync_sections() {
  local rel="$1" tpl="$2" head="$3"
  shift 3
  local target="$AI/$rel" why bad=0 k t n seg want last_changed=0
  serial=$((serial + 1))
  local w="$TMP/$serial"
  mkdir -p "$w"

  why="$(target_problem "$target")"
  [ -z "$why" ] || { fail_line "$rel" "$why"; return; }
  [ -r "$tpl" ] || { fail_line "$rel" '템플릿 없음'; return; }
  why="$(split_md "$target" "$w/inst" '## ')" || { fail_line "$rel" "$why"; return; }
  why="$(split_md "$tpl" "$w/tpl" '## ')" || { fail_line "$rel" "템플릿: ${why}"; return; }

  if [ "$head" = head ]; then
    [ -s "$w/inst/titles" ] || { fail_line "$rel 머리말" '`##` 제목이 없어 경계를 정할 수 없음'; bad=1; }
    [ -s "$w/tpl/titles" ] || { fail_line "$rel 머리말" '템플릿에 구간 없음'; bad=1; }
  fi
  for t in "$@"; do
    n="$(grep -cxF -e "$t" "$w/inst/titles")"
    [ "$n" -le 1 ] || { fail_line "$rel $t" "같은 제목이 ${n}개"; bad=1; }
    n="$(grep -cxF -e "$t" "$w/tpl/titles")"
    [ "$n" -eq 1 ] || { fail_line "$rel $t" '템플릿에 구간 없음'; bad=1; }
  done
  [ "$bad" -eq 0 ] || return

  : > "$w/out"; : > "$w/log"
  if [ "$head" = head ]; then
    trim_tail "$w/tpl/0" > "$w/new"
    if put_segment "$w/inst/0" "$w/new" "$w/out"; then
      echo "교체: $rel 머리말" >> "$w/log"
    fi
  else
    cat "$w/inst/0" >> "$w/out"
  fi

  k=0
  while IFS= read -r seg; do
    k=$((k + 1))
    want=0
    for t in "$@"; do [ "$t" = "$seg" ] && want=1; done
    if [ "$want" -eq 0 ]; then
      cat "$w/inst/$k" >> "$w/out"
      last_changed=0
      continue
    fi
    n="$(grep -nxF -e "$seg" "$w/tpl/titles" | cut -d: -f1)"
    merge_section "$w/inst/$k" "$w/tpl/$n" "$w/m$k" > "$w/new" || { fail_line "$rel $seg" '소제목을 나눌 수 없음'; return; }
    if put_segment "$w/inst/$k" "$w/new" "$w/out"; then
      echo "교체: $rel $seg" >> "$w/log"
      last_changed=1
    else
      last_changed=0
    fi
  done < "$w/inst/titles"

  for t in "$@"; do
    grep -qxF -e "$t" "$w/inst/titles" && continue
    n="$(grep -nxF -e "$t" "$w/tpl/titles" | cut -d: -f1)"
    trim_tail "$w/out" > "$w/out.tmp"
    [ ! -s "$w/out.tmp" ] || echo >> "$w/out.tmp"
    trim_tail "$w/tpl/$n" >> "$w/out.tmp"
    echo >> "$w/out.tmp"
    mv "$w/out.tmp" "$w/out"
    echo "추가: $rel $t" >> "$w/log"
    last_changed=1
  done

  [ -s "$w/log" ] || return 0
  if [ "$last_changed" -eq 1 ]; then
    trim_tail "$w/out" > "$w/out.tmp"
    mv "$w/out.tmp" "$w/out"
  fi
  write_file "$rel" "$w/out" "$target" && cat "$w/log"
}

# copy_if_missing <상대 경로> — 설치본이 없을 때만 템플릿을 복사한다.
copy_if_missing() {
  local rel="$1" target="$AI/$1" src="$TPL/shared/.ai/$1" why
  why="$(target_problem "$target")"
  [ -z "$why" ] || { fail_line "$rel" "$why"; return; }
  [ ! -e "$target" ] || return 0
  [ -r "$src" ] || { fail_line "$rel" '템플릿 없음'; return; }
  write_file "$rel" "$src" "$target" && echo "추가: $rel"
}

# always_latest <상대 경로> — 설치본을 템플릿과 같게 맞춘다.
always_latest() {
  local rel="$1" target="$AI/$1" src="$TPL/shared/.ai/$1" why verb='교체'
  why="$(target_problem "$target")"
  [ -z "$why" ] || { fail_line "$rel" "$why"; return; }
  [ -r "$src" ] || { fail_line "$rel" '템플릿 없음'; return; }
  [ -e "$target" ] || verb='추가'
  ! cmp -s "$src" "$target" || return 0
  write_file "$rel" "$src" "$target" && echo "${verb}: $rel"
}

run_dirs() {
  local rel
  for rel in 30_contract/index.md 40_domain/index.md 40_domain/glossary.md 50_adr/index.md 60_codebase/index.md 70_ledger/index.md; do
    copy_if_missing "$rel"
  done
  always_latest 70_ledger/ledger-entry-template.md
  # 복사에 실패해 파일이 없으면 위에서 이미 보고했다.
  [ ! -e "$AI/50_adr/index.md" ] || sync_sections 50_adr/index.md "$TPL/shared/.ai/50_adr/index.md" nohead '## 수명 주기'
  [ ! -e "$AI/70_ledger/index.md" ] || sync_sections 70_ledger/index.md "$TPL/shared/.ai/70_ledger/index.md" head '## 수명 주기'
}

# ssot_line <파일> — H1 제목과 뒤 빈 줄을 뺀 본문의 2번째 줄을 출력한다 (check-context.sh 와 같은 기준).
ssot_line() {
  awk 'NR == 1 && /^# / { next } !s && NF { s = NR; next } s && NR == s + 1 { print; exit }' "$1"
}

run_context() {
  local target="$AI/AI-CONTEXT.md" line2 p why
  why="$(target_problem "$target")"
  [ -z "$why" ] || { fail_line AI-CONTEXT.md "$why"; return; }
  [ -e "$target" ] || { fail_line AI-CONTEXT.md '파일 없음'; return; }
  line2="$(ssot_line "$target")"
  if [ "$line2" = "$(ssot_line "$TPL/doc/.ai/AI-CONTEXT.md" 2>/dev/null)" ]; then p=doc
  elif [ "$line2" = "$(ssot_line "$TPL/dev/.ai/AI-CONTEXT.md" 2>/dev/null)" ]; then p=dev
  else
    fail_line AI-CONTEXT.md '본문 2번째 줄이 표준 SSoT 선언이 아님'
    return
  fi
  sync_sections AI-CONTEXT.md "$TPL/$p/.ai/AI-CONTEXT.md" nohead \
    '## .ai 디렉토리 구조' '## 에이전트 운영 지침' '## Git 정책' '## 이슈 작업 워크플로우'
}

# set_profile_row <구간 파일> <값> <결과 파일> — 첫 표의 `profile` 행을 맞춘 구간을 쓰고 same·replace·add·none 중 하나를 출력한다.
# check-context.sh 의 profile_state 와 같은 범위를 본다. 값이 같은 행은 표기가 달라도 그대로 둔다.
set_profile_row() {
  VALUE="$2" OUT_FILE="$3" awk "$MD_TRACK_AWK"'
    function cell(line, i,    c, v) {
      split(line, c, "|")
      v = c[i]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      return v
    }
    BEGIN {
      value = ENVIRON["VALUE"]; dest = ENVIRON["OUT_FILE"]
      row = "| profile | " value " |"
      printf "" > dest
    }
    {
      out = $0; keep = 1
      if (!ended && !fence_ch && !in_comment && $0 ~ /^\|/) {
        table = 1
        if (cell($0, 2) == "profile") {
          rows++
          if (rows > 1) { keep = 0; changed = 1 }
          else if (cell($0, 3) != value) { out = row; changed = 1 }
        }
      } else if (table && !ended) {
        ended = 1
        if (!rows) { print row > dest; added = 1 }
      }
      if (keep) print out > dest
      md_track($0)
    }
    END {
      if (table && !ended && !rows) { print row > dest; added = 1 }
      print (!table ? "none" : added ? "add" : changed ? "replace" : "same")
    }
  ' "$1"
}

run_profile() {
  local rel=AI-CONTEXT.md target="$AI/AI-CONTEXT.md" w="$TMP/profile" why n k=0 sec=0 state verb t
  why="$(target_problem "$target")"
  [ -z "$why" ] || { fail_line "$rel profile" "$why"; return; }
  [ -e "$target" ] || { fail_line "$rel profile" '파일 없음'; return; }
  why="$(split_md "$target" "$w" '## ')" || { fail_line "$rel profile" "$why"; return; }
  n="$(grep -cxF -e '## 프로젝트 도메인' "$w/titles")"
  [ "$n" -ge 1 ] || { fail_line "$rel profile" '`## 프로젝트 도메인` 섹션 없음'; return; }
  [ "$n" -eq 1 ] || { fail_line "$rel profile" "같은 제목이 ${n}개"; return; }
  sec="$(grep -nxF -e '## 프로젝트 도메인' "$w/titles" | cut -d: -f1)"
  state="$(set_profile_row "$w/$sec" "$VALUE" "$w/new")"
  case "$state" in
    same) return 0 ;;
    add) verb='추가' ;;
    replace) verb='교체' ;;
    none) fail_line "$rel profile" '`## 프로젝트 도메인` 표 없음'; return ;;
    *) fail_line "$rel profile" '구간을 고칠 수 없음'; return ;;
  esac
  cp "$w/0" "$w/out"
  while IFS= read -r t; do
    k=$((k + 1))
    if [ "$k" -eq "$sec" ]; then cat "$w/new"; else cat "$w/$k"; fi >> "$w/out"
  done < "$w/titles"
  write_file "$rel profile" "$w/out" "$target" && echo "${verb}: $rel profile"
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  --dirs|--context|--profile) mode="$1" ;;
  '') echo 'error: 모드가 필요합니다' >&2; usage >&2; exit 2 ;;
  *) echo "error: 알 수 없는 옵션 — $1" >&2; exit 2 ;;
esac
[ $# -eq 3 ] || { echo 'error: 인자 수가 맞지 않습니다' >&2; usage >&2; exit 2; }
if [ "$mode" = --profile ]; then
  VALUE="$2"
  case "$VALUE" in
    dev|doc) ;;
    *) echo "error: 프로파일은 dev·doc 중 하나입니다 — ${VALUE}" >&2; exit 2 ;;
  esac
else
  TPL="$2"
  [ -d "$TPL" ] || { echo "error: templates 디렉토리가 없습니다 — $TPL" >&2; exit 2; }
fi
AI="$3"
[ -d "$AI" ] || { echo "error: .ai 디렉토리가 없습니다 — $AI" >&2; exit 2; }

TMP="$(mktemp -d)" || { echo 'error: 임시 디렉토리를 만들 수 없습니다' >&2; exit 2; }
trap 'rm -rf "$TMP"' EXIT

case "$mode" in
  --dirs) run_dirs ;;
  --context) run_context ;;
  --profile) run_profile ;;
esac

[ "$failures" -eq 0 ] || exit 1
exit 0
