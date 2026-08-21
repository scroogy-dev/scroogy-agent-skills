#!/usr/bin/env bash
#
# check-lobby.sh — 로비 `.ai/AI-CONTEXT.md` 의 형식 위배와 분량 가드레일을 결정적으로 판정한다.
#
# SKILL.md update-1단계 (4) 형식 위배 표와 init-5단계 분량 가드레일 표,
# 그리고 references/standard-structure.md 가 규격의 SSoT 이며 이 스크립트는 그것을 옮긴 사본이다.
# 어느 한쪽 표가 바뀌면 이 스크립트와 tests/ 의 기대값을 함께 갱신한다.
#
# 이 스크립트는 판정만 한다. update-2단계의 재구성(자동 갱신·삽입·정규화)은 SKILL.md 의 절차가 맡는다.
#
# 사용법:
#   check-lobby.sh <로비 파일>            # 형식 위배 8종
#   check-lobby.sh --lines <로비 파일>    # 분량 가드레일 판정
#
# 형식 위배는 위반 사유를 1행씩 출력하고 종료 코드 1 을 낸다.
# 분량 판정은 `<판정> (<줄 수>줄)` 을 출력하고 종료 코드 0 을 낸다 —
# 분량은 권고라 실패로 취급하지 않는다는 SKILL.md init-5단계 규칙을 그대로 따른다.
#
# 종료 코드: 0 통과(형식) 또는 판정 출력(분량) / 1 형식 위배 / 2 사용오류

set -o pipefail

usage() { sed -n '3,21p' "$0" | sed 's/^# \{0,1\}//'; }

# standard-structure.md 의 표준 6개 H2 섹션. 순서까지 규격이다.
STANDARD_H2='정체성
Repos
라우팅 규칙
공통 규약
Why 진입점
에이전트 운영 지침'

# 본문 두 번째 줄의 고정 문구.
SSOT_LINE='> SSoT: 소스 코드. 이 파일은 라우터일 뿐 진실의 원천이 아니다.'

# Repos 표의 4열 이름.
REPOS_HEADER='path domain keywords status'

# init-5단계 분량 가드레일 경계.
MIN_LINES=150
MAX_LINES=250

lines_mode=false
file=''

while [ $# -gt 0 ]; do
  case "$1" in
    --lines) lines_mode=true; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "error: 알 수 없는 옵션 — $1" >&2; exit 2 ;;
    *)
      [ -z "$file" ] || { echo "error: 파일은 하나만 지정합니다" >&2; exit 2; }
      file="$1"; shift ;;
  esac
done

[ -n "$file" ] || { echo "error: 로비 파일 경로가 필요합니다" >&2; usage >&2; exit 2; }
[ -r "$file" ] || { echo "error: 읽을 수 없는 파일 — $file" >&2; exit 2; }

if [ "$lines_mode" = true ]; then
  n="$(grep -c '' "$file")"
  if [ "$n" -gt "$MAX_LINES" ]; then
    printf '비대 (%d줄)\n' "$n"
  elif [ "$n" -lt "$MIN_LINES" ]; then
    printf '짧음 (%d줄)\n' "$n"
  else
    printf '정상 (%d줄)\n' "$n"
  fi
  exit 0
fi

violations=0
ng() { echo "위반: $1"; violations=$((violations + 1)); }

# --- (3) YAML frontmatter 부재 ------------------------------------------------
#
# frontmatter 가 있으면 그 사실을 위반으로 세되, 이어지는 머리말 2줄 검사는 본문 시작 위치를
# frontmatter 뒤로 옮겨 판정한다. 두 줄이 밀렸다는 이유로 같은 결함을 세 번 세지 않기 위함이다.

body_start=1
if [ "$(sed -n '1p' "$file")" = '---' ]; then
  ng "YAML frontmatter 가 있습니다 — 로비 산출물은 frontmatter 를 쓰지 않습니다"
  close="$(awk 'NR > 1 && /^---[[:space:]]*$/ { print NR; exit }' "$file")"
  if [ -n "$close" ]; then
    body_start=$((close + 1))
    # 닫는 구분선 뒤 빈 줄은 본문 시작으로 세지 않는다.
    while [ -z "$(sed -n "${body_start}p" "$file")" ] && [ "$body_start" -lt "$(grep -c '' "$file")" ]; do
      body_start=$((body_start + 1))
    done
  fi
fi

line1="$(sed -n "${body_start}p" "$file")"
line2="$(sed -n "$((body_start + 1))p" "$file")"

# --- (1) 본문 첫 줄 `> last updated: YYYY-MM-DD` --------------------------------

printf '%s\n' "$line1" | grep -qE '^> last updated: [0-9]{4}-[0-9]{2}-[0-9]{2}$' \
  || ng "본문 첫 줄이 '> last updated: YYYY-MM-DD' 가 아닙니다 — [$line1]"

# --- (2) 본문 두 번째 줄 SSoT 고정 문구 ------------------------------------------

[ "$line2" = "$SSOT_LINE" ] \
  || ng "본문 두 번째 줄이 표준 SSoT 문구가 아닙니다 — [$line2]"

# --- (5) 섹션명 Repos (구버전 Floors 아님) ---------------------------------------
#
# 순서 검사보다 먼저 판정한다. `Floors` 를 쓰는 구버전 파일은 `Repos` 누락으로도 걸리는데,
# 그때 원인이 "섹션명이 낡음"임을 알려주지 않으면 표를 새로 만들라는 지시로 읽힌다.

grep -qE '^## Floors[[:space:]]*$' "$file" \
  && ng "구버전 섹션명 'Floors' 를 씁니다 — 'Repos' 로 정규화합니다"

# --- (4) 표준 6개 H2 존재·순서 ---------------------------------------------------

actual_h2="$(grep -E '^## ' "$file" | sed -E 's/^## +//; s/[[:space:]]+$//')"

missing=''
while IFS= read -r h; do
  printf '%s\n' "$actual_h2" | grep -qxF "$h" || missing="$missing $h"
done <<EOF
$STANDARD_H2
EOF
[ -z "$missing" ] || ng "표준 H2 섹션 누락 —$missing"

if [ -z "$missing" ]; then
  filtered="$(printf '%s\n' "$actual_h2" | grep -xF -e '정체성' -e 'Repos' -e '라우팅 규칙' -e '공통 규약' -e 'Why 진입점' -e '에이전트 운영 지침')"
  if [ "$filtered" != "$STANDARD_H2" ]; then
    ng "표준 H2 섹션 순서가 규격과 다릅니다 — 실제 [$(printf '%s' "$filtered" | tr '\n' '>' | sed 's/>$//')]"
  fi
fi

# --- (6) Repos 표 4열 -----------------------------------------------------------

repos_header="$(awk '
  /^## Repos[[:space:]]*$/ { f = 1; next }
  f && /^## / { exit }
  f && /^\|/ { print; exit }
' "$file")"

if [ -z "$repos_header" ]; then
  ng "Repos 표를 찾을 수 없습니다"
else
  got_cols="$(printf '%s\n' "$repos_header" | awk -F'|' '{
    out = ""
    for (i = 2; i < NF; i++) {
      v = $i
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      out = out (out == "" ? "" : " ") v
    }
    print out
  }')"
  [ "$got_cols" = "$REPOS_HEADER" ] \
    || ng "Repos 표가 4열($REPOS_HEADER)이 아닙니다 — 실제 [$got_cols]"
fi

# --- (8) status 열거값 ------------------------------------------------------------

bad_status="$(awk -F'|' '
  /^## Repos[[:space:]]*$/ { f = 1; next }
  f && /^## / { exit }
  f && /^\|/ {
    n++
    if (n <= 2) next                      # 헤더·구분선
    v = $5
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
    if (v != "active" && v != "placeholder" && v != "archived") print v
  }
' "$file")"

if [ -n "$bad_status" ]; then
  while IFS= read -r v; do
    ng "status 값이 열거값(active/placeholder/archived)이 아닙니다 — [$v]"
  done <<EOF
$bad_status
EOF
fi

# --- (7) 진입 절차 4단계 ----------------------------------------------------------
#
# 표준 구조가 `### 진입 절차` 를 `## 에이전트 운영 지침` 의 하위로 강제하므로 탐색 범위를 그 H2 안으로 제한한다.
# 파일 전체에서 첫 서브헤딩을 찾으면 다른 H2 아래의 같은 이름 소절이 위치 위반을 가려 준다.

ops="$(awk '
  /^## 에이전트 운영 지침[[:space:]]*$/ { f = 1; next }
  f && /^## / { exit }
  f { print }
' "$file")"

if ! printf '%s\n' "$ops" | grep -qE '^### 진입 절차'; then
  ng "'에이전트 운영 지침' 에 '### 진입 절차' 서브헤딩이 없습니다"
else
  steps="$(printf '%s\n' "$ops" | awk '
    /^### 진입 절차/ { f = 1; next }
    f && /^#{2,3} / { exit }
    f && /^[0-9]+\./ { n++ }
    END { print n + 0 }
  ')"
  [ "$steps" -eq 4 ] || ng "진입 절차가 번호 4단계가 아닙니다 — 실제 ${steps}단계"
fi

[ "$violations" -eq 0 ]
