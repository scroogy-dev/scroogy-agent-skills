#!/usr/bin/env bash
#
# check-context.sh — repo 안내도 `.ai/AI-CONTEXT.md` 의 update-4 멱등 보강 검사를 결정적으로 판정한다.
#
# SKILL.md update-4단계 "멱등 보강 검사" 표가 규격의 SSoT 이며 이 스크립트는 그 **검사** 열의 사본이다.
# 표가 바뀌면 이 스크립트와 tests/ 의 기대값을 함께 갱신한다.
#
# 이 스크립트는 판정만 한다. 표의 **누락 시 조치**(삽입·정정·교체)는 내용 생성이 섞여 있어 SKILL.md 절차가 맡는다.
# 검사 표 11행 중 9행을 다룬다. `## 디렉토리 구조` 의 `.ai/` 한 줄 압축과 트리 정렬 순서 2종은
# 앵커 존재 판정이 아니라 트리 구조 해석이라 제외했다 (조건 분기가 과하게 늘어나는 경우 —
# `.ai/10_rules/architecture.md` "디자인 원칙"의 예외).
#
# 사용법:
#   check-context.sh <AI-CONTEXT.md 경로>
#
# 본문 두 번째 줄은 dev(`소스 코드`)·doc(`원본 문서`) 두 표준 문구를 인정하며, doc 문구이면 `## 프로젝트 도메인` 표의 `ssot_dir` 행과 dev 표준 문구(충돌 우선순위, `60_codebase` 설명 3곳) 잔존도 검사한다.
# 입력 파일 옆에 `60_codebase/repository.yaml`이 있으면(code-map 건물 repo) doc 문구를 보고한다. 건물 repo는 `소스 코드`로 선언한다.
#
# 종료 코드: 0 누락 없음(무출력) / 1 누락 있음(항목을 1행씩 출력) / 2 사용오류

set -o pipefail

usage() { sed -n '3,19p' "$0" | sed 's/^# \{0,1\}//'; }

SSOT_LINE_DEV='> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.'
SSOT_LINE_DOC='> SSoT: 원본 문서. 이 파일은 안내도일 뿐 진실의 원천이 아니다.'
PREMISE='전제: 상위 디렉토리에 `.ai/AI-CONTEXT.md`가 있으면'
PRIO_DEV='**소스 코드 > 이 repo 안내도 > 상위 워크스페이스 안내도**'
TREE_DEV='# [5순위] 소스코드 엔트리포인트·호출 흐름 색인 (index.md로 선택적 참조)'
ENTRY_DEV='`60_codebase/index.md`(코드 진입점)'
RULE_DEV='코드 상세는 `60_codebase/`'
RULES_HEADER='파일/설명/사용 시점'

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

[ "$line2" = "$SSOT_LINE_DEV" ] || [ "$line2" = "$SSOT_LINE_DOC" ] \
  || ng "본문 두 번째 줄 SSoT 선언 — 실제 [$line2]"

# --- 건물 repo SSoT 선언 -----------------------------------------------------------
#
# code-map 건물 repo(`.ai/60_codebase/repository.yaml` 존재)의 문서는 등록 repo의 색인에서 만든 것이라
# SSoT가 등록 repo의 소스 코드이고 건물 repo 안에는 없다. 그래서 `소스 코드`로 선언한다 (code-map `references/global.md`).
# doc 표준 문구만 보고한다. 비표준 문구는 위 검사가 이미 보고했다. 조치는 보고와 질의까지이며 자동 전환은 없다.

if [ "$line2" = "$SSOT_LINE_DOC" ] && [ -f "$(dirname "$file")/60_codebase/repository.yaml" ]; then
  ng "건물 repo 선언 (repository.yaml 존재, doc 선언 — 소스 코드 선언 대상, 자동 전환 없음)"
fi

# --- 프로젝트 도메인 섹션 + 표 행 ---------------------------------------------------
#
# `ssot_dir` 행은 doc 선언일 때만 검사한다. dev 선언이거나 선언이 비표준이면 검사하지 않는다
# (비표준 선언은 위에서 이미 보고했고, 어느 프로파일 문구로 바뀔지는 조치 단계가 정한다).

keys='domain keywords'
[ "$line2" = "$SSOT_LINE_DOC" ] && keys="$keys ssot_dir"

if ! grep -qE '^## 프로젝트 도메인[[:space:]]*$' "$file"; then
  ng "'## 프로젝트 도메인' 섹션"
else
  for k in $keys; do
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
      # SKILL.md 표가 3열의 이름까지 `파일`·`설명`·`사용 시점` 으로 고정하므로 열 수만 세지 않는다.
      # 개수만 보면 이름이 다른 3열 표가 통과해 이후 행 검사가 엉뚱한 표에 붙는다.
      # 앞 3열의 이름·순서만 판정하고 뒤에 붙은 사용자 확장 열은 허용한다
      # (SKILL.md 검사 표에 명시한 관용 범위이며 `-lt 3` 관용과 같은 정책이다).
      names="$(printf '%s\n' "$rules_header" | awk -F'|' '{
        out = ""
        for (i = 2; i <= NF - 1 && i <= 4; i++) {
          v = $i
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
          out = (out == "" ? v : out "/" v)
        }
        print out
      }')"
      if [ "$names" != "$RULES_HEADER" ]; then
        ng "'## 프로젝트 규칙' 표의 헤더 이름 ($RULES_HEADER 순서 — 실제 [$names], 헤더 정정 대상)"
      else
        rules_ok=true
      fi
    fi
  fi
fi

# --- 표준 2행 -------------------------------------------------------------------
#
# 섹션·표 존재가 보장된 뒤에만 수행한다 (SKILL.md 표의 "아래 두 행 검사는 이 검사로 …" 조건).
# 표가 없는 상태에서 행을 찾으면 조치가 겹쳐 같은 결함이 세 번 보고된다.
# 행 인정 기준은 첫 번째 `파일` 셀의 정확 대조다(백틱·양끝 공백 무시 — SKILL.md 검사 표의 계약).
# 행 전체를 부분 문자열로 찾으면 경로가 설명·확장 열에만 있어도 표준 행으로 오인한다.
# 탐색 범위는 섹션의 첫 번째 표 블록(헤더를 검증한 그 표)이며, 표가 끝난 첫 비표 행에서 멈춘다.
# 섹션 전체를 훑으면 같은 H2의 두 번째 표에만 있는 동명 행까지 표준 행으로 오인하는데,
# 누락 시 조치가 "그 표 끝에 삽입"이라 다른 표의 행은 조치 결과 상태가 아니다.

if [ "$rules_ok" = true ]; then
  for row in '.ai/10_rules/context-loading.md' '.ai/10_rules/writing-principles.md'; do
    awk -F'|' -v needle="$row" '
      /^## 프로젝트 규칙[[:space:]]*$/ { f = 1; next }
      f && /^## / { exit }
      f && /^\|/ {
        t = 1
        v = $2
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
        gsub(/`/, "", v)
        if (v == needle) { found = 1; exit }
        next
      }
      f && t { exit }
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

# --- doc 선언의 dev 표준 문구 잔존 --------------------------------------------------
#
# 이전 doc 템플릿은 dev 선언·dev 표준 문구였다. 사용자가 2번째 줄만 doc 문구로 바꾸면 update가
# 기존 섹션을 보존하므로 충돌 우선순위와 `60_codebase` 설명 3곳이 소스 코드 기준으로 남는다.
# dev 표준 문구가 그대로 있을 때만 보고한다. 사용자가 고쳐 쓴 문구는 보존 대상이다.
# 우선순위는 굵게 표시한 구간 전체를 찾는다. 앞뒤 `**` 없이 찾으면 `**원본 문서 > 소스 코드 > …**`처럼
# 사용자가 고쳐 쓴 우선순위까지 dev 표준 문구로 오인한다.

# dev_residue <H2 제목> <dev 표준 문구> <보고 문구>
dev_residue() {
  awk -v head="$1" -v needle="$2" '
    { h = $0; sub(/[[:space:]]+$/, "", h) }
    h == head { f = 1; next }
    f && /^## / { exit }
    f && index($0, needle) { found = 1; exit }
    END { exit found }
  ' "$file" || ng "$3"
}

if [ "$line2" = "$SSOT_LINE_DOC" ]; then
  dev_residue '## 에이전트 운영 지침' "$PRIO_DEV" \
    "doc 선언의 충돌 우선순위 ('### 진입 절차'에 dev 표준 우선순위 잔존 — doc 문구로 교체 대상)"
  dev_residue '## .ai 디렉토리 구조' "$TREE_DEV" \
    "doc 선언의 60_codebase 설명 ('## .ai 디렉토리 구조' 트리에 dev 표준 설명 잔존 — doc 문구로 교체 대상)"
  dev_residue '## 에이전트 운영 지침' "$ENTRY_DEV" \
    "doc 선언의 60_codebase 설명 ('### 진입 절차' 2번에 dev 표준 설명 잔존 — doc 문구로 교체 대상)"
  dev_residue '## 에이전트 운영 지침' "$RULE_DEV" \
    "doc 선언의 60_codebase 설명 ('### 작성 규칙'에 dev 표준 설명 잔존 — doc 문구로 교체 대상)"
fi

# --- 구버전 워크스페이스 위치 섹션 --------------------------------------------------
#
# 이 항목만 "있으면 위반"이다. 나머지 검사와 방향이 반대라 메시지를 구분한다.

grep -qE '^## 워크스페이스 위치[[:space:]]*$' "$file" \
  && echo "구버전: '## 워크스페이스 위치' 섹션 — '## 프로젝트 도메인' 2행 표로 마이그레이션 대상" \
  && missing=$((missing + 1))

[ "$missing" -eq 0 ]
