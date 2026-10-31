#!/usr/bin/env bash
#
# code-map 회귀 테스트 러너 (외부 의존성 없음, ADR 0001).
#
# 이 스킬은 scripts/ 가 없어 색인 동작이 SKILL.md 와 references/ 의 절차 문장에 있다.
# 원본 문서 색인 절차(references/doc.md)와 SKILL.md 의 모드 분기 규칙 문장이 제자리에 있는지를 [D] 로 보고,
# 규칙을 하나씩 되돌린 사본이 격추되는지로 검사가 실제로 동작함을 확인한다 (#114 최종 감사 F-3).
#
# 절차를 입력에 적용한 결과(어떤 행을 만들고 지우며 Why 태깅을 어디에 남기는지)는
# fixtures/doc-index/ 의 입력·기대 쌍으로 [QD] 모의 실행한다. 여기서는 그 쌍이 빠짐없이 있는지만 본다.
# local.md·global.md(소스 코드·건물 색인 절차)는 0단계 골격 판정 문장만 같은 방식으로 검사한다 (#116).
# 건물 리포 규칙(SKILL.md 의 `--local` 중단, global.md 의 선언 규칙·SSoT 종류 분류·호출 식별 제외)도 같은 방식으로 본다 (#118).
# SKILL.md 의 선언 부재 폴백 알림(안내도가 있을 때만 알림)도 같은 방식으로 본다 (#122).
# SKILL.md 의 시퀀스 다이어그램 작성 규칙과 local.md·global.md 의 시퀀스 형식·갱신·점검 문장도 같은 방식으로 본다 (#126).
#
# 모두 통과하면 exit 0, 하나라도 실패하면 exit 1.

set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$HERE/../SKILL.md"
DOC="$HERE/../references/doc.md"
LOCAL="$HERE/../references/local.md"
GLOBAL="$HERE/../references/global.md"
FIX="$HERE/fixtures/doc-index"
# ai-workspace init 이 복사하는 색인 골격. doc.md·local.md·global.md 0단계가 이 골격을 미생성으로 판정한다.
TEMPLATE="$HERE/../../ai-workspace/templates/shared/.ai/60_codebase/index.md"
PLACEHOLDER='(문서를 추가하면 이 목록에 함께 기재하세요)'

pass=0
fail=0

ok() { echo "ok     - $1"; pass=$((pass + 1)); }
ng() { echo "NOT OK - $1"; fail=$((fail + 1)); }

for f in "$SKILL" "$DOC" "$LOCAL" "$GLOBAL" "$FIX/README.md" "$TEMPLATE"; do
  [ -r "$f" ] || { echo "NOT OK - 파일을 찾을 수 없습니다 — $f"; exit 1; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# sec <파일> <제목 행> — 제목 행 다음부터 같은 수준 이상의 다음 제목 전까지 출력한다.
# 코드 블록 안의 `#` 행은 제목으로 보지 않는다 (doc.md 1-3의 index.md 예시가 `# `·`## ` 행을 담는다).
sec() {
  awk -v h="$2" '
    /^[[:space:]]*```/ { code = !code }
    !code && $0 == h { f = 1; n = index(h, " "); next }
    f && !code && /^#+ / && index($0, " ") <= n { exit }
    f' "$1"
}

# has <본문> <문자열> — 고정 문자열 포함 여부.
has() { printf '%s\n' "$1" | grep -qF -- "$2"; }

# violations <references/doc.md> <SKILL.md> — 어긋난 규칙을 1행씩 출력한다. 무출력이면 통과.
violations() {
  local doc="$1" skill="$2" s line
  s="$(sec "$doc" '## 트리거 조건')"
  has "$s" '선언 값이 `원본 문서`일 때' || echo '트리거 원본 문서'
  has "$s" '선언 값이 `소스 코드`이거나 선언을 찾지 못하면 이 파일 대신 [local.md](local.md)를 따른다' || echo '트리거 폴백'
  s="$(sec "$doc" '## 파일 구조')"
  printf '%s\n' "$s" | grep -qE '^ssot_dir: ' || echo 'frontmatter ssot_dir 키'
  printf '%s\n' "$s" | grep -qE '^- 색인 대상은 .*`ssot_dir` 행에 적힌 디렉토리.* 아래 `\.md` 파일이다\.$' || echo '색인 대상 .md 정의'
  has "$s" '- 다른 확장자와 첨부(이미지·PDF 등)의 분류는 repo 문서 규약 파일(`.ai/10_rules/document-convention.md`)이 정한다.' \
    || echo '문서 규약 위임'
  has "$s" '- 첨부는 색인 행을 따로 만들지 않고, 그 첨부를 참조하는 `.md` 파일의 색인 행에 딸린다.' || echo '첨부 딸림'

  s="$(sec "$doc" '### 0단계: 모드 결정')"
  line="$(printf '%s\n' "$s" | grep -E '^- \*\*미생성\*\* → `build`')"
  { has "$line" '템플릿 골격만 있는 상태다' && has "$line" "자리표시자 \`$PLACEHOLDER\` 하나뿐"; } || echo '골격 미생성 판정'
  has "$s" '`sync`는 `rebuild`로 전환한다' || echo '루트 불일치 sync 전환'
  has "$s" 'Why 태깅은 보존하고' || echo '루트 불일치 rebuild Why 보존'
  has "$s" '`check`는 3단계의 루트 불일치 판정으로 넘긴다' || echo '루트 불일치 check 위임'

  s="$(sec "$doc" '### 1단계: 원본 문서 색인')"
  has "$s" '- build / rebuild: 안내도 `ssot_dir` 아래 `.md` 파일 전체' || echo 'build 범위'
  has "$s" '자리표시자(`<...>`)이면 사용자에게 묻는다' || echo 'ssot_dir 부재 질의'
  line="$(printf '%s\n' "$s" | grep -E '^- sync:')"
  has "$line" '0단계 루트 대조에서 두 값이 같을 때만 수행한다' || echo 'sync 동일 루트 조건'
  { has "$line" '--name-status -M' && ! has "$line" '--name-only'; } || echo 'sync 이름 변경 입력'
  has "$line" '이름 변경(`R`) 행은 이전 경로와 새 경로 중 하나라도 `ssot_dir` 아래 `.md` 파일이면 대상이고, 그 밖의 행은 `ssot_dir` 아래 `.md` 파일만 대상이다.' \
    || echo 'sync 범위 .md'
  has "$s" '색인 반영을 마친 뒤에만 갱신한다' || echo '메타데이터 갱신 시점'
  printf '%s\n' "$s" | grep -qxF -- '- `.md` 파일 1개가 색인 행 1개다.' || echo '색인 단위 .md'
  has "$s" '**삭제된 파일**(`D`)은 해당 행을 index.md에서 제거한다' || echo '삭제 행 제거'
  has "$s" '확장자가 `.md`가 아닌 경로는 `ssot_dir` 밖과 같게 본다.' || echo '이름 변경 .md 외 확장자'
  has "$s" '두 경로 모두 `ssot_dir` 아래: 새 행을 만들고 옛 행의 Why 태깅을 새 행으로 옮긴 뒤 옛 행을 지운다' || echo '이름 변경 Why 이전'
  has "$s" '이전 경로만 `ssot_dir` 아래(루트 밖으로 이동): 옛 행을 지운다' || echo '루트 밖 이동'
  has "$s" '새 경로만 `ssot_dir` 아래(루트 안으로 이동): 새 행을 만든다' || echo '루트 안 이동'
  printf '%s\n' "$s" | grep -qxF '| 파일 경로 | 다루는 주제 | 관련 문서 |' || echo '색인 3열'
  has "$s" '`[WHY-NEEDED]`로 표시' || echo 'WHY-NEEDED 표시'

  s="$(sec "$doc" '### 2단계: 교차 참조 연결')"
  has "$s" '**존재하는 문서만 링크한다**' || echo '존재 문서만 링크'
  has "$s" '**외부 URL은 교차 참조 대상이 아니다**' || echo '외부 URL 교차 참조 제외'
  has "$s" '퍼블리싱 URL(안내도 `publish` 행의 위치 포함)도 색인에 두지 않는다' || echo '퍼블리싱 URL 제외'

  sec "$doc" '### 3단계: 정합성 점검' | grep -E '^\| 루트 불일치 \|' | grep -F '[UPDATE-NEEDED]' | grep -qF 'rebuild를 권고' \
    || echo '점검 표 루트 불일치'
  has "$(sec "$doc" '### 3단계: 정합성 점검' | grep -E '^\| stale 탐지 \|')" '`ssot_dir` 아래에서 변경된 `.md` 파일 목록' \
    || echo 'stale 탐지 .md'
  has "$(sec "$doc" '### 3단계: 정합성 점검' | grep -E '^\| 파일 유효성 \|')" '`check`는 **행을 지우지 않고 `[UPDATE-NEEDED]`로 보고한다.**' \
    || echo '파일 유효성 check 보존'
  has "$(sec "$doc" '### 3단계: 정합성 점검' | grep -E '^\| 범위 밖 행 \|')" '**`.md`가 아닌 행을 색인에서 자동 제거한다.**' \
    || echo '범위 밖 행 제거'
  has "$(sec "$doc" '### 3단계: 정합성 점검' | grep -E '^\| 범위 밖 행 \|')" '`check`는 **행을 지우지 않고 `[UPDATE-NEEDED]`로 보고한다.**' \
    || echo '범위 밖 행 check 보존'
  has "$(sec "$doc" '### 4단계: 결과 보고')" '문서 색인: N건 (신규 N / 갱신 N / 삭제 N)' || echo '보고 문서 색인 건수'

  has "$(sec "$skill" '### SSoT 원칙')" '선언을 찾지 못하면 소스 코드를 SSoT로 본다' || echo 'SKILL.md 선언 부재 폴백'
  has "$(sec "$skill" '### SSoT 원칙')" '`AI-CONTEXT.md`는 있는데 선언을 찾지 못해 소스 코드로 진행하면' || echo 'SKILL.md 선언 부재 알림'
  has "$(sec "$skill" '### SSoT 원칙')" '`AI-CONTEXT.md`가 없으면 알리지 않는다' || echo 'SKILL.md 안내도 부재 무알림'
  has "$(sec "$skill" '## 모드별 실행 절차')" '| `--local` (floor, 원본 문서) | [references/doc.md](references/doc.md) |' \
    || echo 'SKILL.md 모드 표 doc.md 행'
  has "$(sec "$skill" '## 적용 대상')" '**원본 문서 저장소**' || echo 'SKILL.md 적용 대상'
}

# local_violations <references/local.md> — 0단계 골격 판정이 doc.md 와 같은지 본다. 무출력이면 통과.
local_violations() {
  local s line
  s="$(sec "$1" '### 0단계: 모드 결정')"
  line="$(printf '%s\n' "$s" | grep -E '^- \*\*미생성\*\* → `build`')"
  { has "$line" '템플릿 골격만 있는 상태다' && has "$line" "자리표시자 \`$PLACEHOLDER\` 하나뿐"; } || echo 'local 골격 미생성 판정'
  printf '%s\n' "$s" | grep -qE '^- \*\*생성됨\*\*' || echo 'local 생성됨 분기'
}

# global_violations <references/global.md> — 0단계 5·7번이 골격을 색인 없음으로 보는지 본다. 무출력이면 통과.
# 5·7번 하위 행은 들여쓰기가 있어 앵커가 앞 공백을 허용한다.
global_violations() {
  local s line
  s="$(sec "$1" '### 0단계: 리포 목록 확인 및 모드 결정')"
  has "$s" "자리표시자 \`$PLACEHOLDER\` 하나뿐" || echo 'global 골격 기준'
  line="$(printf '%s\n' "$s" | grep -E '^[[:space:]]*- \*\*미분석\*\*')"
  has "$line" '템플릿 골격만 있는' || echo 'global 미분석 골격'
  line="$(printf '%s\n' "$s" | grep -E '^[[:space:]]*- \*\*미생성\*\* → `build`')"
  has "$line" '템플릿 골격만 있는 상태다' || echo 'global 미생성 골격'
}

# building_violations <SKILL.md> <references/global.md> — 건물 리포 규칙(#118)이 제자리에 있는지 본다. 무출력이면 통과.
# 건물 리포 자신의 선언 규칙·`--local` 중단과, 대상 리포 선언에 따른 SSoT 종류 분류·호출 식별 제외를 함께 본다.
building_violations() {
  local skill="$1" g="$2" s
  has "$(sec "$skill" '## 모드별 실행 절차')" \
    '`.ai/60_codebase/repository.yaml`이 있으면 건물 리포다. 건물 리포에서 `--local`을 실행하면 건물 안내도(`.ai/60_codebase/index.md`)를 덮어쓰지 않도록 중단하고 `--global`을 안내한다.' \
    || echo '건물 --local 중단'

  s="$(sec "$g" '## 전제 조건')"
  has "$s" 'SSoT 선언은 `소스 코드`다' || echo '건물 선언 규칙'
  has "$s" '이 리포 안에는 없다' || echo '건물 SSoT 부재'

  s="$(sec "$g" '### 0단계: 리포 목록 확인 및 모드 결정')"
  has "$s" '3. 현재 프로젝트 안내도(`.ai/AI-CONTEXT.md`)의 SSoT 선언을 확인한다. `소스 코드`가 아니면' || echo '건물 0단계 선언 확인'
  has "$s" '6. 각 리포 안내도(`.ai/AI-CONTEXT.md`)의 SSoT 선언을 읽어 SSoT 종류를 분류한다.' || echo '건물 0단계 대상 선언 읽기'
  has "$s" 'SSoT 종류는 5번 분석 상태와 별개의 축이다' || echo '건물 0단계 별개 축'

  s="$(sec "$g" '### 1단계: 수집 (floor → building)')"
  has "$s" '분석 완료로 분류된 리포만(SSoT 종류 무관)' || echo '건물 1단계 수집 대상'
  has "$s" '`원본 문서` 리포는 상세 호출 흐름 문서 대신 문서 지도(색인의 파일 목록)를 읽는다' || echo '건물 1단계 문서 지도'
  has "$s" '`원본 문서` 리포는 호출 흐름이 없으므로 이 식별에서 제외한다' || echo '건물 1단계 원본 문서 제외'

  s="$(sec "$g" '### 3단계: 건물 안내도 갱신')"
  printf '%s\n' "$s" | grep -qxF '> SSoT: 등록 리포의 소스 코드. 이 리포 안에는 SSoT가 없다.' || echo '건물 안내도 SSoT 행'
  printf '%s\n' "$s" | grep -qxF '| 리포 | 요약 | URL | SSoT | 상태 | 마지막 동기화 |' || echo '건물 안내도 SSoT 열'
}

# 작성 규칙 라벨 행과 그 행이 담아야 할 표기 리터럴(`<라벨>|<리터럴>`). 검사와 격추가 같은 목록을 쓴다.
SEQ_LABELS=('위치·형식' '참여자' '응답' '동기·비동기' '분기·반복' '트랜잭션 경계' '금지 문자' '긴 흐름')
SEQ_ROWS=(
  '위치·형식|`### 시퀀스 다이어그램`' '위치·형식|`sequenceDiagram`'
  '참여자|호출 주체' '참여자|`--global`은 서비스' '참여자|`participant`로 미리 선언' '참여자|처음 호출되는 순서'
  '응답|`-->>`' '동기·비동기|`->>`' '동기·비동기|`-)`' '분기·반복|`alt`·`opt`·`loop`'
  '트랜잭션 경계|`rect` 또는 `Note`' '금지 문자|`;`와 `#`'
)

# cut_sec <파일> <시작 행> <끝 행> — 두 행 사이를 출력한다.
# 예시 펜스 안의 3백틱 블록이 sec 의 코드 상태를 뒤집으므로, 시퀀스 검사는 sec 대신 경계 행을 고정해 자른다.
cut_sec() { awk -v a="$2" -v b="$3" '$0 == a { f = 1; next } $0 == b { exit } f' "$1"; }

# seq_order <절 본문> <흐름 시작 행> <흐름 끝 행> — 흐름 안에서 트리 코드 블록, `### 시퀀스 다이어그램`,
# `sequenceDiagram`으로 시작하는 mermaid 블록이 그 순서로 있으면 0.
seq_order() {
  printf '%s\n' "$1" | awk -v h="$2" -v e="$3" '
    $0 == h { st = 1; next }
    st == 1 && $0 == "```" { st = 2; next }
    st == 2 && $0 == "```" { st = 3; next }
    st == 3 && $0 == "### 시퀀스 다이어그램" { st = 4; next }
    st == 4 && $0 == "```mermaid" { st = 5; next }
    st == 5 { st = ($0 == "sequenceDiagram") ? 6 : -1; next }
    st == 6 && $0 == "```" { st = 7; next }
    st >= 1 && $0 == e { exit }
    END { exit st != 7 }'
}

# seq_parts <절 본문> <흐름 시작 행> — 시퀀스 참여자(`participant <별칭> as <이름>`의 이름)가
# 트리 노드의 호출 주체(`#` 앞 부분)와 첫 등장 순서까지 같으면 0. 시퀀스 블록이 없으면 1.
seq_parts() {
  local blk tree part
  blk="$(printf '%s\n' "$1" | awk -v h="$2" '$0 == h { f = 1; next } f')"
  tree="$(printf '%s\n' "$blk" | awk '$0 == "```" { n++; next } n == 1' | sed -E 's/^[^A-Za-z]*//; s/#.*//' | awk 'NF && !seen[$0]++')"
  part="$(printf '%s\n' "$blk" | awk '$0 == "```mermaid" { f = 1; next } f && $0 == "```" { exit } f' \
    | grep -E '^[[:space:]]*participant ' | sed -E 's/.* as //')"
  [ -n "$tree" ] && [ "$tree" = "$part" ]
}

# seq_chars <파일> — mermaid 블록 메시지 문구(첫 `:` 뒤)에 `;`·`#`가 있는 행을 출력한다.
seq_chars() {
  awk '$0 == "```mermaid" { m = 1; next } m && $0 == "```" { m = 0 } m && /:/ { sub(/^[^:]*:/, ""); if ($0 ~ /[;#]/) print }' "$1"
}

# sequence_violations <SKILL.md> <references/local.md> <references/global.md>
# — 시퀀스 다이어그램 규칙(#126)이 제자리에 있는지 본다. 무출력이면 통과.
sequence_violations() {
  local skill="$1" lo="$2" g="$3" s line pair lab p
  s="$(awk '$0 == "## 시퀀스 다이어그램 작성 규칙" { f = 1; next } f && /^## / { exit } f' "$skill")"
  [ -n "$s" ] || echo '시퀀스 SKILL.md 작성 규칙 섹션'
  [ "$(printf '%s\n' "$s" | grep -E '^- \*\*[^*]+\*\*:' | sed -E 's/^- \*\*([^*]+)\*\*:.*/\1/' | tr '\n' '|')" \
    = "$(printf '%s|' "${SEQ_LABELS[@]}")" ] || echo '시퀀스 SKILL.md 라벨 이름·순서'
  for pair in "${SEQ_ROWS[@]}"; do
    lab=${pair%%|*}; p=${pair#*|}
    has "$(printf '%s\n' "$s" | grep -E "^- \*\*$lab\*\*:")" "$p" || echo "시퀀스 SKILL.md $lab 행 $p"
  done
  line="$(printf '%s\n' "$s" | grep -E '^- \*\*긴 흐름\*\*:')"
  has "$line" '핵심 경로만' || echo '시퀀스 SKILL.md 긴 흐름 핵심 경로'
  has "$line" '`생략한 호출은 위 트리에서 확인한다.`' || echo '시퀀스 SKILL.md 긴 흐름 생략 안내'
  has "$(grep -E '^\| \*\*How\*\* \|' "$skill")" '(호출 흐름 트리와 시퀀스 다이어그램, 의존성, 설정)' || echo '시퀀스 SKILL.md How 행'
  has "$(awk '$0 == "### .ai 디렉토리와의 관계" { f = 1; next } f && /^#{2,3} / { exit } f' "$skill" | grep -F '<action>-call-flow.md')" \
    '# 엔트리포인트별 상세 호출 흐름 (트리 + 시퀀스 다이어그램)' || echo '시퀀스 SKILL.md 트리 주석'
  s="$(awk '$0 == "## 디렉토리 트리 정렬 규칙" { f = 1; next } f && /^## / { exit } f' "$skill")"
  has "$s" '시퀀스 다이어그램의 참여자 순서에도 이 규칙을 적용하지 않습니다' || echo '시퀀스 SKILL.md 정렬 규칙 적용 제외'
  has "$s" '[시퀀스 다이어그램 작성 규칙](#시퀀스-다이어그램-작성-규칙)' || echo '시퀀스 SKILL.md 정렬 규칙 링크'
  # 시퀀스 누락·불일치는 새 태그 없이 결과 보고 건수로 세므로, 태그 체계 표는 기존 5개 그대로다 (#126 최종 감사 F-1).
  [ "$(awk '$0 == "## 태그 체계" { f = 1; next } f && /^## / { exit } f' "$skill" | grep -E '^\| [^|]+ \|' \
       | sed -n '2,$p' | sed -E 's/^\| ([^|]+) \|.*/\1/' | tr '\n' '|')" \
    = '`[WHY-NEEDED]`|`[DOC-NEEDED]`|`[UPDATE-NEEDED]`|`[NOT-INDEXED]`|`[REPO-NOT-FOUND]`|' ] || echo '시퀀스 SKILL.md 태그 체계 표'

  s="$(cut_sec "$lo" '### 1단계: 소스코드 색인' '### 2단계: 교차 참조 연결')"
  has "$s" '트리 다음에는 같은 흐름을 Mermaid 시퀀스 다이어그램으로 그리며, [시퀀스 다이어그램 작성 규칙](../SKILL.md#시퀀스-다이어그램-작성-규칙)을 따른다' \
    || echo '시퀀스 local 1-4 안내 문장'
  seq_order "$s" '## How' '## Why' || echo '시퀀스 local 예시 트리·소제목·mermaid 순서'
  seq_parts "$s" '## How' || echo '시퀀스 local 예시 참여자'
  grep -qxF '```mermaid' "$lo" || echo '시퀀스 local mermaid 블록'
  [ -z "$(seq_chars "$lo")" ] || echo '시퀀스 local 메시지 금지 문자'
  line="$(printf '%s\n' "$s" | grep -E '^- build·rebuild는')"
  [ "$(printf '%s\n' "$line" | grep -c .)" -eq 1 ] || echo '시퀀스 local build·rebuild 행'
  has "$line" '- build·rebuild는 상세 호출 흐름 문서마다 트리와 시퀀스 다이어그램을 함께 만든다.' || echo '시퀀스 local 함께 생성'
  has "$line" 'sync는 소스가 바뀐 기능의 문서에서 둘을 함께 갱신하고, 시퀀스 다이어그램이 없는 기존 문서에는 이때 추가한다.' \
    || echo '시퀀스 local sync 갱신·추가'

  s="$(awk '$0 == "### 3단계: 정합성 점검" { f = 1; next } f && /^### / { exit } f' "$lo" | grep -E '^\| [^|]+ \|')"
  [ "$(printf '%s\n' "$s" | sed -n '2,$p' | sed -E 's/^\| ([^|]+) \|.*/\1/' | tr '\n' '|')" \
    = 'stale 탐지|엔트리포인트 유효성|교차참조 유효성|시퀀스 누락|트리·시퀀스 불일치|Why 미태깅|문서 누락|' ] \
    || echo '시퀀스 local 점검 표 행'
  line="$(printf '%s\n' "$s" | grep -E '^\| 시퀀스 누락 \|')"
  for p in '`## How`에 `mermaid` 코드 블록이 없으면' '목록으로 보고한다'; do
    has "$line" "$p" || echo "시퀀스 local 누락 행 $p"
  done
  line="$(printf '%s\n' "$s" | grep -E '^\| 트리·시퀀스 불일치 \|')"
  for p in '호출 주체' '`생략한 호출은 위 트리에서 확인한다.`' '목록으로 보고한다'; do
    has "$line" "$p" || echo "시퀀스 local 불일치 행 $p"
  done
  awk '$0 == "### 4단계: 결과 보고" { f = 1; next } f' "$lo" | grep -qE '^[[:space:]]*- 시퀀스 다이어그램: N건 \(누락 N / 불일치 N\)$' \
    || echo '시퀀스 local 4단계 보고 행'

  line="$(awk '$0 == "## 파일 구조" { f = 1; next } f && /^## / { exit } f' "$g" | grep -E '^- `service-call-flows\.md`:')"
  [ "$(printf '%s\n' "$line" | grep -c .)" -eq 1 ] || echo '시퀀스 global 설명 줄'
  for p in '흐름별 섹션마다 트리 다음에 시퀀스 다이어그램을 함께 생성·갱신한다' '참여자는 서비스(리포) 단위' \
           '[시퀀스 다이어그램 작성 규칙](../SKILL.md#시퀀스-다이어그램-작성-규칙)'; do
    has "$line" "$p" || echo "시퀀스 global 설명 줄 $p"
  done
  s="$(cut_sec "$g" '### 2단계: 아키텍처 문서 생성/갱신' '### 3단계: 건물 안내도 갱신')"
  seq_order "$s" '## 사용자 로그인' '`````' || echo '시퀀스 global 예시 트리·소제목·mermaid 순서'
  seq_parts "$s" '## 사용자 로그인' || echo '시퀀스 global 예시 참여자'
  grep -qxF '```mermaid' "$g" || echo '시퀀스 global mermaid 블록'
  [ -z "$(seq_chars "$g")" ] || echo '시퀀스 global 메시지 금지 문자'

  # global 은 한 파일에 흐름 섹션이 여럿이라, 판정 대상(흐름 섹션)과 집계 단위(흐름) 문장을 따로 본다.
  s="$(awk '$0 == "### 4단계: 정합성 점검" { f = 1; next } f && /^### / { exit } f' "$g" | grep -E '^\| [^|]+ \|')"
  [ "$(printf '%s\n' "$s" | sed -n '2,$p' | sed -E 's/^\| ([^|]+) \|.*/\1/' | tr '\n' '|')" \
    = '리포 접근성|안내도 불일치|아키텍처 문서 유효성|교차참조 유효성|' ] || echo '시퀀스 global 점검 표 행'
  line="$(printf '%s\n' "$s" | grep -E '^\| 아키텍처 문서 유효성 \|')"
  for p in '`service-call-flows.md`의 호출 흐름(트리와 시퀀스 다이어그램' '`## How` 대신 흐름 섹션마다 따로' '흐름 단위로 센다'; do
    has "$line" "$p" || echo "시퀀스 global 아키텍처 문서 유효성 행 $p"
  done
  awk '$0 == "### 5단계: 결과 보고" { f = 1; next } f' "$g" | grep -qE '^[[:space:]]*- 서비스 간 시퀀스 다이어그램: N건 \(누락 N / 불일치 N\)$' \
    || echo '시퀀스 global 5단계 보고 행'
}

# --- 현재 본문이 규칙을 모두 갖는다 ------------------------------------------------

out="$(violations "$DOC" "$SKILL")"
if [ -z "$out" ]; then
  ok "원본 문서 색인 규칙 통과"
else
  ng "원본 문서 색인 규칙 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
fi

out="$(local_violations "$LOCAL")"
if [ -z "$out" ]; then
  ok "local 0단계 골격 판정 통과"
else
  ng "local 0단계 골격 판정 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
fi

out="$(global_violations "$GLOBAL")"
if [ -z "$out" ]; then
  ok "global 0단계 골격 판정 통과"
else
  ng "global 0단계 골격 판정 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
fi

out="$(building_violations "$SKILL" "$GLOBAL")"
if [ -z "$out" ]; then
  ok "건물 리포 규칙 통과"
else
  ng "건물 리포 규칙 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
fi

out="$(sequence_violations "$SKILL" "$LOCAL" "$GLOBAL")"
if [ -z "$out" ]; then
  ok "시퀀스 다이어그램 규칙 통과"
else
  ng "시퀀스 다이어그램 규칙 통과 — 위반: $(printf '%s' "$out" | tr '\n' ' ')"
fi

# 골격 판정 기준이 실제 템플릿과 어긋나면 init 직후 색인을 생성됨으로 오판한다 (PR #115 리뷰).
if [ "$(head -n 1 "$TEMPLATE")" != '---' ] && grep -qxF "| $PLACEHOLDER | |" "$TEMPLATE"; then
  ok "골격 판정 기준과 ai-workspace 템플릿 일치"
else
  ng "골격 판정 기준과 ai-workspace 템플릿 일치 — frontmatter가 있거나 자리표시자 행이 다릅니다"
fi

# --- 규칙별 격추 -----------------------------------------------------------------
#
# 원본 사본에 변형 하나를 적용하고 그 규칙의 위반이 나오는지 본다.
# 위반 행을 정확히 대조해 다른 규칙이 대신 걸려 통과처럼 보이는 것을 막는다.
# 변형 대상 문자열이 없으면 "변형 실패"로 떨어져, 본문이 바뀌었는데 케이스가 헛도는 것을 막는다.

mkdir -p "$TMP/case"
C_DOC="$TMP/case/doc.md"
C_SKILL="$TMP/case/SKILL.md"
C_LOCAL="$TMP/case/local.md"
C_GLOBAL="$TMP/case/global.md"

# sub_str <파일> <찾을 문자열> <바꿀 문자열> — 첫 등장 하나를 바꾼다(고정 문자열 대조).
sub_str() {
  awk -v s="$2" -v r="$3" '
    !done && (i = index($0, s)) { $0 = substr($0, 1, i - 1) r substr($0, i + length(s)); done = 1 }
    { print }
    END { exit !done }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}
cut_str() { sub_str "$1" "$2" ''; }

# drop_line <파일> <문자열> — 문자열을 포함한 행을 모두 지운다.
drop_line() {
  awk -v s="$2" 'index($0, s) { hit = 1; next } { print } END { exit !hit }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

# swap_next <파일> <문자열> — 문자열을 포함한 첫 행과 그 다음 행의 순서를 바꾼다.
swap_next() {
  awk -v s="$2" '
    held != "" { print; print held; held = ""; next }
    !done && index($0, s) { held = $0; done = 1; next }
    { print }
    END { if (held != "") print held; exit !done }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

# assert_reject <설명> <위반 행> <변형 명령...>
assert_reject() {
  local desc="$1" want="$2" out; shift 2
  cp "$DOC" "$C_DOC"; cp "$SKILL" "$C_SKILL"; cp "$LOCAL" "$C_LOCAL"; cp "$GLOBAL" "$C_GLOBAL"
  "$@" || { ng "$desc — 변형 실패"; return; }
  out="$(violations "$C_DOC" "$C_SKILL"; local_violations "$C_LOCAL"; global_violations "$C_GLOBAL"; building_violations "$C_SKILL" "$C_GLOBAL"
         sequence_violations "$C_SKILL" "$C_LOCAL" "$C_GLOBAL")"
  if printf '%s\n' "$out" | grep -qxF "$want"; then
    ok "$desc"
  else
    ng "$desc — 위반에 '$want' 없음, 실제: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
}

assert_reject '트리거 선언 값 변경 격추'      '트리거 원본 문서'        sub_str "$C_DOC" '선언 값이 `원본 문서`일 때' '선언 값이 있을 때'
assert_reject '트리거 폴백 삭제 격추'         '트리거 폴백'             drop_line "$C_DOC" '이 파일 대신 [local.md](local.md)를 따른다'
assert_reject 'frontmatter ssot_dir 키 삭제 격추' 'frontmatter ssot_dir 키' drop_line "$C_DOC" '# 색인한 루트 경로'
assert_reject '색인 대상 .md 정의 원복 격추'  '색인 대상 .md 정의'      sub_str "$C_DOC" '아래 `.md` 파일이다.' '아래 문서 파일이다.'
assert_reject '문서 규약 위임 삭제 격추'      '문서 규약 위임'          drop_line "$C_DOC" '의 분류는 repo 문서 규약 파일('
assert_reject '첨부 색인 행 딸림 삭제 격추'   '첨부 딸림'               drop_line "$C_DOC" '- 첨부는 색인 행을 따로 만들지 않고'
assert_reject '골격 미생성 판정 삭제 격추'    '골격 미생성 판정'        cut_str "$C_DOC" '파일이 비어 있거나 템플릿 골격만 있는 상태다. '
assert_reject '골격 자리표시자 변경 격추'     '골격 미생성 판정'        sub_str "$C_DOC" "$PLACEHOLDER" '(자리표시자)'
assert_reject '루트 불일치 sync 전환 삭제 격추' '루트 불일치 sync 전환'  cut_str "$C_DOC" '`sync`는 `rebuild`로 전환한다. '
assert_reject '루트 불일치 Why 보존 삭제 격추' '루트 불일치 rebuild Why 보존' cut_str "$C_DOC" 'Why 태깅은 보존하고, '
assert_reject '루트 불일치 check 위임 삭제 격추' '루트 불일치 check 위임' drop_line "$C_DOC" '`check`는 3단계의 루트 불일치 판정으로 넘긴다'
assert_reject 'build 범위 확대 격추'          'build 범위' \
  sub_str "$C_DOC" '- build / rebuild: 안내도 `ssot_dir` 아래 `.md` 파일 전체' '- build / rebuild: repo 전체 문서 파일'
assert_reject 'build 범위 .md 정의 원복 격추'  'build 범위' \
  sub_str "$C_DOC" '아래 `.md` 파일 전체' '아래 문서 파일 전체'
assert_reject '색인 단위 .md 정의 원복 격추'  '색인 단위 .md'           sub_str "$C_DOC" '- `.md` 파일 1개가 색인 행 1개다.' '- 문서 파일 1개가 색인 행 1개다.'
assert_reject 'ssot_dir 부재 질의 삭제 격추'  'ssot_dir 부재 질의'      drop_line "$C_DOC" '자리표시자(`<...>`)이면 사용자에게 묻는다'
assert_reject 'sync 동일 루트 조건 삭제 격추' 'sync 동일 루트 조건'     cut_str "$C_DOC" '0단계 루트 대조에서 두 값이 같을 때만 수행한다. '
assert_reject 'sync 입력 --name-only 원복 격추' 'sync 이름 변경 입력'   sub_str "$C_DOC" '--name-status -M' '--name-only'
assert_reject 'sync 범위 이름 변경 행 .md 정의 원복 격추' 'sync 범위 .md' \
  sub_str "$C_DOC" '중 하나라도 `ssot_dir` 아래 `.md` 파일이면 대상이고' '중 하나라도 `ssot_dir` 아래이면 대상이고'
assert_reject 'sync 범위 그 밖의 행 .md 정의 원복 격추' 'sync 범위 .md' \
  sub_str "$C_DOC" '그 밖의 행은 `ssot_dir` 아래 `.md` 파일만 대상이다' '그 밖의 행은 `ssot_dir` 아래 파일만 대상이다'
assert_reject '메타데이터 갱신 시점 삭제 격추' '메타데이터 갱신 시점'   drop_line "$C_DOC" '색인 반영을 마친 뒤에만 갱신한다'
assert_reject '삭제 행 제거 삭제 격추'        '삭제 행 제거'            drop_line "$C_DOC" '**삭제된 파일**(`D`)'
assert_reject '이름 변경 .md 외 확장자 규칙 삭제 격추' '이름 변경 .md 외 확장자' \
  cut_str "$C_DOC" ' 확장자가 `.md`가 아닌 경로는 `ssot_dir` 밖과 같게 본다.'
assert_reject '이름 변경 Why 이전 삭제 격추'  '이름 변경 Why 이전' \
  sub_str "$C_DOC" '새 행을 만들고 옛 행의 Why 태깅을 새 행으로 옮긴 뒤 옛 행을 지운다' '옛 행을 지우고 새 행을 만든다'
assert_reject '루트 밖 이동 삭제 격추'        '루트 밖 이동'            drop_line "$C_DOC" '이전 경로만 `ssot_dir` 아래(루트 밖으로 이동)'
assert_reject '루트 안 이동 삭제 격추'        '루트 안 이동'            drop_line "$C_DOC" '새 경로만 `ssot_dir` 아래(루트 안으로 이동)'
assert_reject '색인 열 축소 격추'             '색인 3열' \
  sub_str "$C_DOC" '| 파일 경로 | 다루는 주제 | 관련 문서 |' '| 파일 경로 | 다루는 주제 |'
assert_reject 'WHY-NEEDED 표시 삭제 격추'     'WHY-NEEDED 표시'         sub_str "$C_DOC" '`[WHY-NEEDED]`로 표시' '빈칸으로 두어 표시'
assert_reject '존재 문서만 링크 삭제 격추'    '존재 문서만 링크'        drop_line "$C_DOC" '**존재하는 문서만 링크한다**'
assert_reject '외부 URL 제외 삭제 격추'       '외부 URL 교차 참조 제외' drop_line "$C_DOC" '**외부 URL은 교차 참조 대상이 아니다**'
assert_reject '퍼블리싱 URL 제외 삭제 격추'   '퍼블리싱 URL 제외'       drop_line "$C_DOC" '퍼블리싱 URL(안내도 `publish` 행의 위치 포함)'
assert_reject '점검 표 루트 불일치 삭제 격추' '점검 표 루트 불일치'     drop_line "$C_DOC" '| 루트 불일치 |'
assert_reject 'stale 탐지 .md 원복 격추'      'stale 탐지 .md' \
  sub_str "$C_DOC" '아래에서 변경된 `.md` 파일 목록' '아래에서 변경된 파일 목록'
assert_reject '파일 유효성 check 보존 삭제 격추' '파일 유효성 check 보존' \
  cut_str "$C_DOC" '`check`는 **행을 지우지 않고 `[UPDATE-NEEDED]`로 보고한다.** '
assert_reject '범위 밖 행 점검 삭제 격추'     '범위 밖 행 제거'         drop_line "$C_DOC" '| 범위 밖 행 |'
assert_reject '범위 밖 행 check 보존 삭제 격추' '범위 밖 행 check 보존' \
  sub_str "$C_DOC" '아닌 행을 색인에서 자동 제거한다.** `check`는 **행을 지우지 않고' '아닌 행을 색인에서 자동 제거한다.** `check`도 **행을 지우고'
assert_reject '보고 건수 축소 격추'           '보고 문서 색인 건수' \
  sub_str "$C_DOC" '문서 색인: N건 (신규 N / 갱신 N / 삭제 N)' '문서 색인: N건'
assert_reject 'SKILL.md 폴백 삭제 격추'       'SKILL.md 선언 부재 폴백' cut_str "$C_SKILL" '선언을 찾지 못하면 소스 코드를 SSoT로 본다.'
assert_reject 'SKILL.md 폴백 알림 삭제 격추'  'SKILL.md 선언 부재 알림' \
  cut_str "$C_SKILL" ' `AI-CONTEXT.md`는 있는데 선언을 찾지 못해 소스 코드로 진행하면 그 사실을 사용자에게 한 줄로 알리고, `ai-workspace` update로 선언을 보강할 수 있다고 안내한다.'
assert_reject 'SKILL.md 안내도 부재 무알림 삭제 격추' 'SKILL.md 안내도 부재 무알림' cut_str "$C_SKILL" ' `AI-CONTEXT.md`가 없으면 알리지 않는다.'
assert_reject 'SKILL.md 모드 표 doc.md 행 삭제 격추' 'SKILL.md 모드 표 doc.md 행' drop_line "$C_SKILL" '| `--local` (floor, 원본 문서) |'
assert_reject 'SKILL.md 적용 대상 삭제 격추'  'SKILL.md 적용 대상'      drop_line "$C_SKILL" '**원본 문서 저장소**'
assert_reject 'local 0단계 골격 판정 삭제 격추' 'local 골격 미생성 판정' cut_str "$C_LOCAL" '파일이 비어 있거나 템플릿 골격만 있는 상태다. '
assert_reject 'local 0단계 골격 자리표시자 변경 격추' 'local 골격 미생성 판정' sub_str "$C_LOCAL" "$PLACEHOLDER" '(자리표시자)'
assert_reject 'global 0단계 골격 미분석 삭제 격추' 'global 미분석 골격' \
  sub_str "$C_GLOBAL" '없거나 비어 있거나 템플릿 골격만 있는 리포' '없거나 비어 있는 리포'
assert_reject 'global 0단계 골격 build 분기 삭제 격추' 'global 미생성 골격' cut_str "$C_GLOBAL" '파일이 비어 있거나 템플릿 골격만 있는 상태다.'
assert_reject 'global 0단계 골격 자리표시자 변경 격추' 'global 골격 기준' sub_str "$C_GLOBAL" "$PLACEHOLDER" '(자리표시자)'
assert_reject '건물 SKILL.md --local 중단 규칙 삭제 격추' '건물 --local 중단'     drop_line "$C_SKILL" '- **건물 리포 규칙**:'
assert_reject '건물 전제 조건 선언 규칙 삭제 격추'      '건물 선언 규칙'         drop_line "$C_GLOBAL" 'SSoT 선언은 `소스 코드`다'
assert_reject '건물 0단계 선언 확인 삭제 격추'          '건물 0단계 선언 확인'   drop_line "$C_GLOBAL" '3. 현재 프로젝트 안내도(`.ai/AI-CONTEXT.md`)의 SSoT 선언을 확인한다.'
assert_reject '건물 0단계 대상 리포 선언 읽기 삭제 격추' '건물 0단계 대상 선언 읽기' \
  drop_line "$C_GLOBAL" '6. 각 리포 안내도(`.ai/AI-CONTEXT.md`)의 SSoT 선언을 읽어'
assert_reject '건물 0단계 분석 상태·SSoT 종류 별개 축 삭제 격추' '건물 0단계 별개 축' drop_line "$C_GLOBAL" 'SSoT 종류는 5번 분석 상태와 별개의 축이다'
assert_reject '건물 1단계 수집 대상 SSoT 종류 무관 삭제 격추' '건물 1단계 수집 대상' cut_str "$C_GLOBAL" '(SSoT 종류 무관)'
assert_reject '건물 1단계 문서 지도 삭제 격추'          '건물 1단계 문서 지도' \
  cut_str "$C_GLOBAL" ' `원본 문서` 리포는 상세 호출 흐름 문서 대신 문서 지도(색인의 파일 목록)를 읽는다.'
assert_reject '건물 1단계 원본 문서 제외 삭제 격추'     '건물 1단계 원본 문서 제외' \
  cut_str "$C_GLOBAL" ' `원본 문서` 리포는 호출 흐름이 없으므로 이 식별에서 제외한다.'
assert_reject '건물 안내도 SSoT 행 삭제 격추'           '건물 안내도 SSoT 행'    drop_line "$C_GLOBAL" '> SSoT: 등록 리포의 소스 코드.'
assert_reject '건물 안내도 SSoT 열 삭제 격추'           '건물 안내도 SSoT 열' \
  sub_str "$C_GLOBAL" '| 리포 | 요약 | URL | SSoT | 상태 | 마지막 동기화 |' '| 리포 | 요약 | URL | 상태 | 마지막 동기화 |'
assert_reject '시퀀스 SKILL.md 작성 규칙 섹션 제목 변경 격추' '시퀀스 SKILL.md 작성 규칙 섹션' \
  sub_str "$C_SKILL" '## 시퀀스 다이어그램 작성 규칙' '## 시퀀스 다이어그램 규칙'
assert_reject '시퀀스 SKILL.md 라벨 이름 변경 격추' '시퀀스 SKILL.md 라벨 이름·순서' sub_str "$C_SKILL" '- **응답**:' '- **응답 표기**:'
# 각 리터럴은 SKILL.md 에서 해당 라벨 행에만 있어 첫 등장 삭제가 그 행을 겨눈다.
for pair in "${SEQ_ROWS[@]}"; do
  assert_reject "시퀀스 SKILL.md ${pair%%|*} 행 ${pair#*|} 삭제 격추" "시퀀스 SKILL.md ${pair%%|*} 행 ${pair#*|}" cut_str "$C_SKILL" "${pair#*|}"
done
assert_reject '시퀀스 SKILL.md 긴 흐름 핵심 경로 삭제 격추' '시퀀스 SKILL.md 긴 흐름 핵심 경로' cut_str "$C_SKILL" '핵심 경로만 '
assert_reject '시퀀스 SKILL.md 긴 흐름 생략 안내 삭제 격추' '시퀀스 SKILL.md 긴 흐름 생략 안내' \
  cut_str "$C_SKILL" '`생략한 호출은 위 트리에서 확인한다.` '
assert_reject '시퀀스 SKILL.md How 행 원복 격추' '시퀀스 SKILL.md How 행' \
  sub_str "$C_SKILL" '(호출 흐름 트리와 시퀀스 다이어그램, 의존성, 설정)' '(호출 흐름, 의존성, 설정)'
assert_reject '시퀀스 SKILL.md 트리 주석 원복 격추' '시퀀스 SKILL.md 트리 주석' cut_str "$C_SKILL" ' (트리 + 시퀀스 다이어그램)'
assert_reject '시퀀스 SKILL.md 정렬 규칙 적용 제외 삭제 격추' '시퀀스 SKILL.md 정렬 규칙 적용 제외' \
  cut_str "$C_SKILL" '시퀀스 다이어그램의 참여자 순서에도 이 규칙을 적용하지 않습니다. '
assert_reject '시퀀스 SKILL.md 정렬 규칙 작성 규칙 링크 삭제 격추' '시퀀스 SKILL.md 정렬 규칙 링크' \
  sub_str "$C_SKILL" '[시퀀스 다이어그램 작성 규칙](#시퀀스-다이어그램-작성-규칙)' '시퀀스 다이어그램 작성 규칙'
assert_reject '시퀀스 SKILL.md 태그 체계 표 행 추가 격추' '시퀀스 SKILL.md 태그 체계 표' \
  sub_str "$C_SKILL" '| `[REPO-NOT-FOUND]` |' '| `[SEQUENCE-NEEDED]` | 시퀀스 누락 | local check |\n| `[REPO-NOT-FOUND]` |'
assert_reject '시퀀스 SKILL.md 태그 체계 표 행 삭제 격추' '시퀀스 SKILL.md 태그 체계 표' drop_line "$C_SKILL" '| `[NOT-INDEXED]` |'
assert_reject '시퀀스 SKILL.md 태그 체계 표 태그 이름 변경 격추' '시퀀스 SKILL.md 태그 체계 표' \
  sub_str "$C_SKILL" '| `[DOC-NEEDED]` |' '| `[DOCS-NEEDED]` |'
assert_reject '시퀀스 SKILL.md 태그 체계 표 행 순서 변경 격추' '시퀀스 SKILL.md 태그 체계 표' swap_next "$C_SKILL" '| `[WHY-NEEDED]` |'
assert_reject '시퀀스 local 1-4 안내 문장 삭제 격추' '시퀀스 local 1-4 안내 문장' \
  cut_str "$C_LOCAL" ' 트리 다음에는 같은 흐름을 Mermaid 시퀀스 다이어그램으로 그리며, [시퀀스 다이어그램 작성 규칙](../SKILL.md#시퀀스-다이어그램-작성-규칙)을 따른다'
assert_reject '시퀀스 local 예시 소제목 삭제 격추' '시퀀스 local 예시 트리·소제목·mermaid 순서' drop_line "$C_LOCAL" '### 시퀀스 다이어그램'
assert_reject '시퀀스 local 예시 mermaid 블록 시작 행 변경 격추' '시퀀스 local 예시 트리·소제목·mermaid 순서' \
  sub_str "$C_LOCAL" 'sequenceDiagram' 'flowchart TD'
assert_reject '시퀀스 local 예시 참여자 이름 변경 격추' '시퀀스 local 예시 참여자' \
  sub_str "$C_LOCAL" 'participant OR as OrderRepository' 'participant OR as OrderRepo'
assert_reject '시퀀스 local 예시 메시지 세미콜론 삽입 격추' '시퀀스 local 메시지 금지 문자' \
  sub_str "$C_LOCAL" 'OS->>IC: reserve' 'OS->>IC: reserve; 재고 확인'
assert_reject '시퀀스 local build·rebuild 함께 생성 삭제 격추' '시퀀스 local 함께 생성' \
  cut_str "$C_LOCAL" '상세 호출 흐름 문서마다 트리와 시퀀스 다이어그램을 함께 만든다. '
assert_reject '시퀀스 local sync 갱신·추가 삭제 격추' '시퀀스 local sync 갱신·추가' \
  cut_str "$C_LOCAL" ' sync는 소스가 바뀐 기능의 문서에서 둘을 함께 갱신하고, 시퀀스 다이어그램이 없는 기존 문서에는 이때 추가한다.'
assert_reject '시퀀스 local 점검 표 누락 행 삭제 격추' '시퀀스 local 점검 표 행' drop_line "$C_LOCAL" '| 시퀀스 누락 |'
assert_reject '시퀀스 local 누락 행 판정 기준 삭제 격추' '시퀀스 local 누락 행 `## How`에 `mermaid` 코드 블록이 없으면' \
  cut_str "$C_LOCAL" '`## How`에 `mermaid` 코드 블록이 없으면 '
assert_reject '시퀀스 local 불일치 행 생략 리터럴 삭제 격추' '시퀀스 local 불일치 행 `생략한 호출은 위 트리에서 확인한다.`' \
  cut_str "$C_LOCAL" '`생략한 호출은 위 트리에서 확인한다.` 줄 없이 '
assert_reject '시퀀스 local 4단계 보고 행 삭제 격추' '시퀀스 local 4단계 보고 행' drop_line "$C_LOCAL" '- 시퀀스 다이어그램: N건 (누락 N / 불일치 N)'
assert_reject '시퀀스 global 설명 줄 생성·갱신 문장 삭제 격추' '시퀀스 global 설명 줄 흐름별 섹션마다 트리 다음에 시퀀스 다이어그램을 함께 생성·갱신한다' \
  cut_str "$C_GLOBAL" ' 흐름별 섹션마다 트리 다음에 시퀀스 다이어그램을 함께 생성·갱신한다.'
assert_reject '시퀀스 global 설명 줄 서비스 단위 삭제 격추' '시퀀스 global 설명 줄 참여자는 서비스(리포) 단위' \
  cut_str "$C_GLOBAL" '참여자는 서비스(리포) 단위이며 '
assert_reject '시퀀스 global 설명 줄 작성 규칙 링크 삭제 격추' \
  '시퀀스 global 설명 줄 [시퀀스 다이어그램 작성 규칙](../SKILL.md#시퀀스-다이어그램-작성-규칙)' \
  sub_str "$C_GLOBAL" '[시퀀스 다이어그램 작성 규칙](../SKILL.md#시퀀스-다이어그램-작성-규칙)' '시퀀스 다이어그램 작성 규칙'
assert_reject '시퀀스 global 예시 소제목 삭제 격추' '시퀀스 global 예시 트리·소제목·mermaid 순서' drop_line "$C_GLOBAL" '### 시퀀스 다이어그램'
assert_reject '시퀀스 global 예시 mermaid 블록 시작 행 변경 격추' '시퀀스 global 예시 트리·소제목·mermaid 순서' \
  sub_str "$C_GLOBAL" 'sequenceDiagram' 'flowchart TD'
assert_reject '시퀀스 global 예시 참여자 이름 변경 격추' '시퀀스 global 예시 참여자' \
  sub_str "$C_GLOBAL" 'participant US as user-service' 'participant US as users'
assert_reject '시퀀스 global 예시 메시지 해시 삽입 격추' '시퀀스 global 메시지 금지 문자' \
  sub_str "$C_GLOBAL" 'AU->>US: findByEmail' 'AU->>US: UserController#findByEmail'
assert_reject '시퀀스 global 아키텍처 문서 유효성 행 시퀀스 문구 삭제 격추' \
  '시퀀스 global 아키텍처 문서 유효성 행 `service-call-flows.md`의 호출 흐름(트리와 시퀀스 다이어그램' \
  sub_str "$C_GLOBAL" '호출 흐름(트리와 시퀀스 다이어그램. ' '호출 흐름('
assert_reject '시퀀스 global 아키텍처 문서 유효성 행 흐름 섹션 판정 문장 삭제 격추' \
  '시퀀스 global 아키텍처 문서 유효성 행 `## How` 대신 흐름 섹션마다 따로' \
  cut_str "$C_GLOBAL" '. 시퀀스 누락과 트리와의 불일치는 local 3단계 기준을 `## How` 대신 흐름 섹션마다 따로 적용해 흐름 단위로 센다'
assert_reject '시퀀스 global 점검 표 행 추가 격추' '시퀀스 global 점검 표 행' \
  sub_str "$C_GLOBAL" '| 교차참조 유효성 | 각 리포 색인' '| 시퀀스 누락 | 흐름 섹션에 시퀀스 다이어그램이 없는지 |\n| 교차참조 유효성 | 각 리포 색인'
assert_reject '시퀀스 global 5단계 보고 행 삭제 격추' '시퀀스 global 5단계 보고 행' \
  drop_line "$C_GLOBAL" '- 서비스 간 시퀀스 다이어그램: N건 (누락 N / 불일치 N)'

# --- 모의 실행 fixture 쌍 -------------------------------------------------------

cases="$(awk -F'`' '/^\| `[a-z0-9-]+` \|/ { print $2 }' "$FIX/README.md")"
if [ -z "$cases" ]; then
  ng "fixture: README 케이스 표에서 케이스를 찾지 못했습니다"
fi
for c in $cases; do
  if [ -r "$FIX/$c.input.md" ] && [ -r "$FIX/$c.expected.md" ]; then
    ok "fixture 쌍: $c"
  else
    ng "fixture 쌍: $c — input·expected 중 없는 파일이 있습니다"
  fi
done
for f in "$FIX"/*.input.md "$FIX"/*.expected.md; do
  [ -e "$f" ] || continue
  c="$(basename "$f")"; c="${c%.input.md}"; c="${c%.expected.md}"
  printf '%s\n' $cases | grep -qxF "$c" || ng "fixture: README 케이스 표에 없는 파일 — $(basename "$f")"
done

echo "-----"
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
