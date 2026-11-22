#!/usr/bin/env bash
#
# collect-branch-changes.sh — git-review 브랜치 모드의 변경과 표시한 경로를 결정적으로 모은다.
#
# SKILL.md "## 대상 수집"의 2단계(브랜치 모드)·3단계가 규칙의 SSoT 이며 이 스크립트는 그것을 옮긴 사본이다.
#
# --base 는 merge-base 와 "지금 작업 트리를 전부 스테이징해 커밋하면 들어갈 내용"의 차이를 낸다.
#   실제 인덱스의 사본에서 추적 파일을 작업 트리의 내용·모드로 갱신하고(`git add -u`) `.ai/99_workspace/` 밖의
#   미추적 파일을 더한(`git add -A`) 스냅샷을 임시 인덱스·임시 객체 디렉토리에 만들어 merge-base 트리와 견준다.
#   무엇이 스테이징되는지는 Git 이 정한다(무시 규칙, 변경을 보지 않도록 표시한 경로, 하위 모듈, 내용 변환 필터 등).
#   대상 수집 2단계는 merge-base 커밋의 해시를 미리 구해 넘긴다. 그 해시가 HEAD 의 조상이면 결과는 그 해시 기준이다.
#   목록과 patch 는 사용자 diff 설정을 읽지 않는 `git diff-index --cached` 로 한 스냅샷에서 함께 낸다.
#
# --marked 는 변경을 보지 않도록 표시한 경로(assume-unchanged, skip-worktree)를 낸다. 실제 인덱스를 읽기만 한다.
#
# 실제 인덱스, 작업 트리, 저장소 객체와 `.git` 아래 파일을 바꾸지 않는다. git 명령은 모두 분할 인덱스·훅·
# 파일 시스템 감시를 끄고 실행한다(`-c core.splitIndex=false -c core.hooksPath=/dev/null -c core.fsmonitor=false`).
# 켜 두면 임시 인덱스에 쓸 때도 Git 이 원본 `.git` 에 공유 인덱스 파일을 쓰거나, 저장소의 훅과 변경 조회를 부른다.
# 저장소 설정은 바꾸지 않는다. gh 를 부르지 않는다.
# 내용 변환 필터(`filter.<이름>.clean`·`.process`)는 끄지 않는다. 끄면 "커밋하면 들어갈 내용"이 달라진다.
#   필터 프로그램이 스스로 남기는 파일(Git LFS 의 객체 캐시 등)은 사용자가 직접 스테이징할 때처럼 생길 수 있다.
#   헬퍼와 Git 이 쓰는 파일이 아니므로 위의 `.git` 보장에 들지 않는다.
#
# 호출 환경의 Git 환경 변수: 헬퍼가 값을 정하는 `GIT_INDEX_FILE`·`GIT_OBJECT_DIRECTORY`·`GIT_ALTERNATE_OBJECT_DIRECTORIES`
#   는 호출 쪽 값을 이어받는다(인덱스와 객체 디렉토리는 `--git-path` 로 얻고, 대체 객체 디렉토리는 뒤에 이어 붙인다).
#   헬퍼가 적은 pathspec 과 patch 형식의 해석을 바꾸는 `GIT_LITERAL_PATHSPECS`·`GIT_GLOB_PATHSPECS`·
#   `GIT_NOGLOB_PATHSPECS`·`GIT_ICASE_PATHSPECS`·`GIT_DIFF_OPTS` 는 끈다. 그 밖의 변수(`GIT_DIR`·`GIT_WORK_TREE` 등)는
#   Git 의 결과를 따른다.
#
# 사용법:
#   collect-branch-changes.sh --base <브랜치|커밋>
#   collect-branch-changes.sh --marked
#
# 출력:
#   --base    변경 파일 목록(`<변경 종류><탭><경로>` 1행씩, 변경 종류는 A·M·D·T), 빈 줄 1행, patch 순서.
#             변경 파일이 0개면 아무것도 쓰지 않는다. 이름 변경은 삭제와 추가로 나온다.
#             Git 이 바이너리로 보는 파일(내용 판정, `binary`·`-diff` 속성, `core.bigFileThreshold` 초과 등)은 목록에 나오고
#             patch 에는 `Binary files … differ` 행만 나온다.
#   --marked  `<표지><공백><경로>` 1행씩. 표지는 `git ls-files -v` 가 내는 첫 글자이며
#             소문자(assume-unchanged)이거나 `S`(skip-worktree)다. 표시한 경로가 없으면 아무것도 쓰지 않는다.
#   경로 표기(두 목록 공통): 큰따옴표로 시작하지 않는 경로는 저장소 루트 기준의 실제 경로이고, 큰따옴표로 시작하는
#             경로는 Git 의 인용 표기다. 이름에 줄바꿈이 들었거나 이름이 큰따옴표로 시작하는 경로만 인용 표기로 나오며,
#             서로 다른 경로는 서로 다른 행으로 나온다. patch 의 파일 머리 행은 Git 의 표기 그대로다.
#
# 종료 코드: 0 성공 / 1 수집 실패(git 작업 트리 밖에서 실행, merge-base 를 구할 수 없음, 스냅샷이나 diff 를 만들지 못함,
#            인덱스를 조회하지 못함) / 2 사용오류(--base 와 --marked 가 둘 다 없거나 함께 있음, 옵션 중복,
#            --base 의 빈 값, 알 수 없는 인자). 1·2 에서는 표준 출력에 아무것도 쓰지 않고 사유를 표준 오류에 1행으로 쓴다.

set -o pipefail
export LC_ALL=C   # 경로를 바이트 단위로 다룬다 (substring·패턴 판정이 로캘에 따라 갈리지 않게)
# 헬퍼가 적은 pathspec·patch 형식의 해석을 바꾸는 호출 환경 변수를 끈다 (헤더 주석 참조)
unset GIT_LITERAL_PATHSPECS GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_ICASE_PATHSPECS GIT_DIFF_OPTS

# fail <사유> <종료 코드> — 사유를 표준 오류에 1행으로 쓰고 끝낸다.
fail() { printf 'collect-branch-changes.sh: %s\n' "$1" >&2; exit "$2"; }

# 모든 git 명령에 붙이는 설정 (헤더 주석 참조)
G=(-c core.splitIndex=false -c core.hooksPath=/dev/null -c core.fsmonitor=false)

base='' has_base=0 marked=0
while [ $# -gt 0 ]; do
  case "$1" in
    --base)
      [ "$has_base" = 0 ] || fail '--base 가 두 번 왔다' 2
      [ $# -ge 2 ] || fail '--base 의 값이 없다' 2
      case "$2" in (-*) fail "--base 의 값이 없다(옵션이 이어짐): $2" 2 ;; esac
      base="$2"; has_base=1; shift 2 ;;
    --marked)
      [ "$marked" = 0 ] || fail '--marked 가 두 번 왔다' 2
      marked=1; shift ;;
    *)
      fail "알 수 없는 인자: $1" 2 ;;
  esac
done
if [ "$has_base" = 1 ] && [ "$marked" = 1 ]; then fail '--base 와 --marked 는 함께 쓸 수 없다' 2; fi
if [ "$has_base" = 0 ] && [ "$marked" = 0 ]; then fail '--base 나 --marked 가 필요하다' 2; fi
if [ "$has_base" = 1 ] && [ -z "$base" ]; then fail '--base 의 값이 비어 있다' 2; fi

top="$(git "${G[@]}" rev-parse --show-toplevel 2>/dev/null)" && [ -n "$top" ] || fail 'git 작업 트리 밖에서 실행했다' 1
cd "$top" || fail "작업 트리 루트로 옮기지 못했다: ${top}" 1

tmp="$(mktemp -d)" || fail '임시 디렉토리를 만들지 못했다' 1
trap 'rm -rf "$tmp"' EXIT   # 자기가 만든 디렉토리만 지운다

# first_err — 마지막 git 명령이 표준 오류에 낸 첫 줄
first_err() { head -n 1 "$tmp/err" 2>/dev/null; }

# read_lines <파일> — 줄 단위 목록을 배열 lines 에 담고 줄 수를 nlines 에 남긴다
read_lines() {
  lines=(); nlines=0
  while IFS= read -r l; do lines[nlines]="$l"; nlines=$((nlines + 1)); done < "$1"
}

# --- --marked: 변경을 보지 않도록 표시한 경로 -------------------------------------------
#
# 표지는 NUL 구분 레코드마다 판정한다. NUL 을 줄바꿈으로 바꾼 뒤 거르면 이름에 줄바꿈이 든 파일의 뒷부분이
# 다른 레코드로 읽힌다. 인용 표기가 필요한 경로는 같은 순번의 줄 단위 행을 그대로 쓴다.

if [ "$marked" = 1 ]; then
  git "${G[@]}" ls-files -v -z > "$tmp/marked.z" 2> "$tmp/err" \
    || fail "인덱스를 조회하지 못했다: $(first_err)" 1
  git "${G[@]}" -c core.quotePath=false ls-files -v > "$tmp/marked.txt" 2> "$tmp/err" \
    || fail "인덱스를 조회하지 못했다: $(first_err)" 1
  read_lines "$tmp/marked.txt"
  : > "$tmp/out"
  j=0
  while IFS= read -r -d '' rec; do
    tag="${rec:0:1}"; path="${rec:2}"
    case "$tag" in
      ([[:lower:]]|S)
        case "$path" in
          ('"'*|*$'\n'*) printf '%s\n' "${lines[j]}" ;;
          (*)            printf '%s %s\n' "$tag" "$path" ;;
        esac >> "$tmp/out" ;;
    esac
    j=$((j + 1))
  done < "$tmp/marked.z"
  [ "$j" = "$nlines" ] || fail "인덱스 조회의 두 목록 레코드 수가 다르다(NUL 구분 ${j}개, 줄 단위 ${nlines}개)" 1
  cat "$tmp/out"
  exit 0
fi

# --- --base: merge-base 와 작업 트리 스냅샷의 차이 -----------------------------------------

bc="$(git "${G[@]}" rev-parse --verify --quiet "${base}^{commit}" 2>/dev/null)" && [ -n "$bc" ] \
  || fail "base 를 커밋으로 해석하지 못했다: ${base}" 1
mb="$(git "${G[@]}" merge-base "$bc" HEAD 2> "$tmp/err")" && [ -n "$mb" ] \
  || fail "merge-base 를 구하지 못했다: ${base} $(first_err)" 1

index="$(git "${G[@]}" rev-parse --git-path index 2> "$tmp/err")" && [ -n "$index" ] \
  || fail "인덱스 경로를 얻지 못했다: $(first_err)" 1
objects="$(git "${G[@]}" rev-parse --git-path objects 2> "$tmp/err")" && [ -n "$objects" ] \
  || fail "객체 디렉토리 경로를 얻지 못했다: $(first_err)" 1
case "$index" in (/*) ;; (*) index="${top}/${index}" ;; esac
case "$objects" in (/*) ;; (*) objects="${top}/${objects}" ;; esac
# 대체 객체 디렉토리 목록은 `:` 로 구분한다. 경로에 `:`·`"`·`\` 가 있으면 큰따옴표로 감싸 이스케이프한다.
case "$objects" in
  (*[:\"\\]*) objects="\"$(printf '%s' "$objects" | sed 's/[\\"]/\\&/g')\"" ;;
esac

# 스냅샷 환경: 실제 인덱스의 사본과 빈 객체 디렉토리. 기존 객체는 대체 객체 디렉토리로 읽는다.
mkdir "$tmp/objects" || fail '임시 객체 디렉토리를 만들지 못했다' 1
if [ -f "$index" ]; then
  cp -p "$index" "$tmp/index" || fail "인덱스를 복사하지 못했다: ${index}" 1
fi
# 호출 환경에 대체 객체 디렉토리가 있으면 뒤에 이어 붙인다. 덮어쓰면 그 디렉토리에만 있는 객체를 읽지 못한다.
export GIT_INDEX_FILE="$tmp/index" GIT_OBJECT_DIRECTORY="$tmp/objects" \
  GIT_ALTERNATE_OBJECT_DIRECTORIES="${objects}${GIT_ALTERNATE_OBJECT_DIRECTORIES:+:${GIT_ALTERNATE_OBJECT_DIRECTORIES}}"

# 스냅샷: 추적 파일을 작업 트리의 내용·모드로 갱신하고, `.ai/99_workspace/` 밖의 미추적 파일을 더한다.
# `git add -u` 에는 경로를 주지 않는다. 인덱스가 비어 있으면 `.` 에 맞는 파일이 없어 명령이 실패한다.
git "${G[@]}" add -u > /dev/null 2> "$tmp/err" \
  || fail "스냅샷을 만들지 못했다(git add -u): $(first_err)" 1
git "${G[@]}" add -A -- . ':(exclude).ai/99_workspace' > /dev/null 2> "$tmp/err" \
  || fail "스냅샷을 만들지 못했다(git add -A): $(first_err)" 1

# 산출: 목록(NUL 구분·줄 단위)과 patch. `git diff` 는 사용자 diff 설정을 읽어 저장소마다 출력이 달라지므로 쓰지 않는다.
# `--ignore-submodules=dirty` 는 하위 모듈의 무시 설정(`ignore = all` 등)을 덮어 커밋 이동만 내게 한다.
D=(-c core.quotePath=false diff-index --cached --no-renames --no-ext-diff --no-textconv --no-color --ignore-submodules=dirty)
git "${G[@]}" "${D[@]}" --name-status -z "$mb" > "$tmp/list.z" 2> "$tmp/err" \
  || fail "diff 를 만들지 못했다(목록): $(first_err)" 1
git "${G[@]}" "${D[@]}" --name-status "$mb" > "$tmp/list.txt" 2> "$tmp/err" \
  || fail "diff 를 만들지 못했다(목록): $(first_err)" 1
git "${G[@]}" "${D[@]}" -p "$mb" > "$tmp/patch" 2> "$tmp/err" \
  || fail "diff 를 만들지 못했다(patch): $(first_err)" 1

# 목록: NUL 구분 레코드(변경 종류, 경로)마다 한 행. 인용 표기가 필요한 경로는 같은 순번의 줄 단위 행을 그대로 쓴다.
# 두 목록은 같은 스냅샷에서 같은 옵션으로 내 레코드 순서가 같다.
read_lines "$tmp/list.txt"
: > "$tmp/out"
j=0
while IFS= read -r -d '' st && IFS= read -r -d '' path; do
  case "$path" in
    ('"'*|*$'\n'*) printf '%s\n' "${lines[j]}" ;;
    (*)            printf '%s\t%s\n' "$st" "$path" ;;
  esac >> "$tmp/out"
  j=$((j + 1))
done < "$tmp/list.z"
[ "$j" = "$nlines" ] || fail "변경 목록의 두 형태 레코드 수가 다르다(NUL 구분 ${j}개, 줄 단위 ${nlines}개)" 1

if [ "$j" -gt 0 ]; then
  cat "$tmp/out"
  printf '\n'
  cat "$tmp/patch"
fi
exit 0
