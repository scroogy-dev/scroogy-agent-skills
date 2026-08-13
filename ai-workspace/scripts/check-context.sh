#!/usr/bin/env bash
#
# check-context.sh — repo 안내도 `.ai/AI-CONTEXT.md` 의 update-4 멱등 보강 검사를 결정적으로 판정한다.
#
# SKILL.md update-4단계 "멱등 보강 검사" 표가 규격의 SSoT 이며 이 스크립트는 그 **검사** 열의 사본이다.
# 표가 바뀌면 이 스크립트와 tests/ 의 기대값을 함께 갱신한다.
#
# 이 스크립트는 판정만 한다. 표의 **누락 시 조치**(삽입·정정·교체)는 내용 생성이 섞여 있어 SKILL.md 절차가 맡는다.
# 검사 표 10행 중 8행을 다룬다. `## 디렉토리 구조` 의 `.ai/` 한 줄 압축과 트리 정렬 순서 2종은
# 앵커 존재 판정이 아니라 트리 구조 해석이라 제외했다 (조건 분기가 과하게 늘어나는 경우 —
# `.ai/10_rules/architecture.md` "디자인 원칙"의 예외).
#
# 사용법:
#   check-context.sh <AI-CONTEXT.md 경로>
#
# 종료 코드: 0 누락 없음(무출력) / 1 누락 있음(항목을 1행씩 출력) / 2 사용오류

set -o pipefail

usage() { sed -n '3,18p' "$0" | sed 's/^# \{0,1\}//'; }

SSOT_LINE='> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.'
PREMISE='전제: 상위 디렉토리에 `.ai/AI-CONTEXT.md`가 있으면'

file=''
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -*) echo "error: 알 수 없는 옵션 — $1" >&2; exit 2 ;;
    *)
      [ -z "$file" ] || { echo "error: 파일은 하나만 지정합니다" >&2; exit 2; }
      file="$1"; shift ;;
  esac
done

[ -n "$file" ] || { echo "error: AI-CONTEXT.md 경로가 필요합니다" >&2; usage >&2; exit 2; }
[ -r "$file" ] || { echo "error: 읽을 수 없는 파일 — $file" >&2; exit 2; }

missing=0
ng() { echo "누락: $1"; missing=$((missing + 1)); }

# 본문 시작 위치 — H1 제목과 그 뒤 빈 줄은 본문으로 세지 않는다.
# 템플릿이 `# AI-CONTEXT.md` 로 시작하므로 "본문 첫 줄"은 그다음 비어 있지 않은 줄이다.
body_start="$(awk '
  NR == 1 && /^# / { next }
  NF { print NR; exit }
' "$file")"
[ -n "$body_start" ] || body_start=1

line1="$(sed -n "${body_start}p" "$file")"
line2="$(sed -n "$((body_start + 1))p" "$file")"

# --- 본문 첫 줄 last updated ----------------------------------------------------

printf '%s\n' "$line1" | grep -qE '^> last updated: [0-9]{4}-[0-9]{2}-[0-9]{2}$' \
  || ng "본문 첫 줄 '> last updated: YYYY-MM-DD' — 실제 [$line1]"

# --- 본문 두 번째 줄 SSoT 선언 ---------------------------------------------------

[ "$line2" = "$SSOT_LINE" ] \
  || ng "본문 두 번째 줄 SSoT 선언 — 실제 [$line2]"

# --- 프로젝트 도메인 섹션 + 2행 표 -------------------------------------------------

if ! grep -qE '^## 프로젝트 도메인[[:space:]]*$' "$file"; then
  ng "'## 프로젝트 도메인' 섹션"
else
  for k in domain keywords; do
    awk -v key="$k" '
      /^## 프로젝트 도메인[[:space:]]*$/ { f = 1; next }
      f && /^## / { exit }
      f && /^\|/ {
        v = $0
        sub(/^\|[[:space:]]*/, "", v)
        sub(/[[:space:]]*\|.*$/, "", v)
        if (v == key) { found = 1; exit }
      }
      END { exit !found }
    ' "$file" || ng "'## 프로젝트 도메인' 표의 \`$k\` 행"
  done
fi

# --- 프로젝트 규칙 섹션 + 3열 표 ---------------------------------------------------
#
# 조치가 상태별로 갈리므로(섹션 부재 / 표 부재 / 2열 구버전) 세 상태를 구분해 보고한다.
# "규칙 표 없음" 한 줄로 뭉치면 어느 조치를 골라야 하는지가 출력에서 사라진다.

rules_ok=false
if ! grep -qE '^## 프로젝트 규칙[[:space:]]*$' "$file"; then
  ng "'## 프로젝트 규칙' 섹션 (섹션 부재 — 템플릿 골격 삽입 대상)"
else
  rules_header="$(awk '
    /^## 프로젝트 규칙[[:space:]]*$/ { f = 1; next }
    f && /^## / { exit }
    f && /^\|/ { print; exit }
  ' "$file")"

  if [ -z "$rules_header" ]; then
    ng "'## 프로젝트 규칙' 표 (섹션은 있고 표 부재 — 섹션 끝에 3열 표 삽입 대상)"
  else
    cols="$(printf '%s\n' "$rules_header" | awk -F'|' '{ print NF - 2 }')"
    if [ "$cols" -lt 3 ]; then
      ng "'## 프로젝트 규칙' 표의 '사용 시점' 열 (${cols}열 구버전 표 — 열 확장 대상)"
    else
      rules_ok=true
    fi
  fi
fi

# --- 표준 2행 -------------------------------------------------------------------
#
# 섹션·표 존재가 보장된 뒤에만 수행한다 (SKILL.md 표의 "아래 두 행 검사는 이 검사로 …" 조건).
# 표가 없는 상태에서 행을 찾으면 조치가 겹쳐 같은 결함이 세 번 보고된다.

if [ "$rules_ok" = true ]; then
  for row in '.ai/10_rules/context-loading.md' '.ai/10_rules/writing-principles.md'; do
    awk -v needle="$row" '
      /^## 프로젝트 규칙[[:space:]]*$/ { f = 1; next }
      f && /^## / { exit }
      f && /^\|/ && index($0, needle) { found = 1; exit }
      END { exit !found }
    ' "$file" || ng "'## 프로젝트 규칙' 표의 \`$row\` 행"
  done
fi

# --- 에이전트 운영 지침 섹션 + 전제 한 줄 -------------------------------------------

if ! grep -qE '^## 에이전트 운영 지침[[:space:]]*$' "$file"; then
  ng "'## 에이전트 운영 지침' 섹션"
else
  awk -v needle="$PREMISE" '
    /^## 에이전트 운영 지침[[:space:]]*$/ { f = 1; next }
    f && /^## / { exit }
    f && index($0, needle) { found = 1; exit }
    END { exit !found }
  ' "$file" || ng "'## 에이전트 운영 지침' 의 전제 컨벤션 한 줄"
fi

# --- 구버전 워크스페이스 위치 섹션 --------------------------------------------------
#
# 이 항목만 "있으면 위반"이다. 나머지 검사와 방향이 반대라 메시지를 구분한다.

grep -qE '^## 워크스페이스 위치[[:space:]]*$' "$file" \
  && echo "구버전: '## 워크스페이스 위치' 섹션 — '## 프로젝트 도메인' 2행 표로 마이그레이션 대상" \
  && missing=$((missing + 1))

[ "$missing" -eq 0 ]
