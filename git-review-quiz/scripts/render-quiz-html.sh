#!/usr/bin/env bash
#
# render-quiz-html.sh - git-review-quiz 대화형 산출 md 를 같은 디렉토리·같은 이름의 .html 로 만든다.
#
# `templates/quiz-template.html` 의 원문 자리 `<pre id="quiz-source">@@QUIZ_SOURCE@@</pre>` 에
# md 를 HTML 이스케이프(`&` → `&amp;`, `<` → `&lt;`, `>` → `&gt;`)만 해서 넣는다.
# 시작 태그 바로 뒤에는 LF 하나를 더한다. HTML 파서가 `<pre>` 시작 태그 바로 뒤 LF 하나를 지우므로,
# 빈 줄로 시작하는 md 도 원문 영역 글자가 md 와 같아진다. md 바이트는 그대로 넣는다.
# 마크다운 변환·정화·도식 렌더는 HTML 안의 JS 가 브라우저에서 한다 (marked·DOMPurify·mermaid).
# 같은 md 를 두 번 렌더하면 결과가 바이트 단위로 같다.
#
# 사용법:
#   render-quiz-html.sh <md 파일>
#
# 출력: 만든 .html 경로 1 행
# 종료 코드: 0 성공 / 1 실패(템플릿 이상·읽기·쓰기 실패) / 2 사용오류(인자 개수·읽을 수 없는 파일·.md 아닌 파일)

set -o pipefail
export LC_ALL=C
# bash 5.2 부터 패턴 치환의 바꿀 문자열 안 `&` 가 일치한 문자열을 뜻한다. 이스케이프 문자열을 글자 그대로 쓰도록 끈다.
shopt -u patsub_replacement 2>/dev/null || true

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$HERE/../templates/quiz-template.html"
MARK='@@QUIZ_SOURCE@@'

usage() { sed -n '3,16p' "$0" | sed 's/^# \{0,1\}//'; }

case "${1-}" in -h|--help) usage; exit 0 ;; esac
[ $# -eq 1 ] || { echo "error: md 파일 하나를 지정합니다" >&2; usage >&2; exit 2; }

md="$1"
case "$md" in *.md) ;; *) echo "error: .md 파일만 렌더합니다 ($md)" >&2; exit 2 ;; esac
{ [ -f "$md" ] && [ -r "$md" ]; } || { echo "error: 읽을 수 없는 파일 ($md)" >&2; exit 2; }
[ -r "$TEMPLATE" ] || { echo "error: 템플릿이 없습니다 ($TEMPLATE)" >&2; exit 1; }

# 명령 치환은 끝 개행을 지우므로 끝에 표지 문자를 붙였다가 떼어 바이트를 그대로 보존한다.
tpl="$(cat "$TEMPLATE" && printf x)" || { echo "error: 템플릿을 읽지 못했습니다" >&2; exit 1; }
tpl="${tpl%x}"
src="$(cat "$md" && printf x)" || { echo "error: md 를 읽지 못했습니다 ($md)" >&2; exit 1; }
src="${src%x}"

rest="${tpl#*"$MARK"}"
[ "$rest" != "$tpl" ] && [ "${rest#*"$MARK"}" = "$rest" ] \
  || { echo "error: 템플릿의 원문 자리 $MARK 가 정확히 1 개가 아닙니다" >&2; exit 1; }
head="${tpl%%"$MARK"*}"

src="${src//&/&amp;}"
src="${src//</&lt;}"
src="${src//>/&gt;}"

out="${md%.md}.html"
dir="$(dirname "$out")"
tmp="$(mktemp "$dir/.render-quiz-html.XXXXXX")" || { echo "error: 임시 파일을 만들지 못했습니다 ($dir)" >&2; exit 1; }
trap 'rm -f "$tmp"' EXIT

printf '%s\n%s%s' "$head" "$src" "$rest" > "$tmp" || { echo "error: 쓰지 못했습니다 ($tmp)" >&2; exit 1; }
mv -f "$tmp" "$out" || { echo "error: 결과 파일을 만들지 못했습니다 ($out)" >&2; exit 1; }
trap - EXIT

printf '%s\n' "$out"
