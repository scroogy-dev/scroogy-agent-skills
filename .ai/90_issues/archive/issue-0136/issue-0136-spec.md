# Issue #136 스펙 ai-workspace: IDE 도구 우선 규칙(ide-tools.md)을 dev 프로파일에 도입하고 init·update에서 안내도 규칙 표·context-loading에 연결한다

## 목표 (Goal)

`ai-workspace`가 init·update로 IDE 도구 우선 규칙을 dev repo에 배포해, IntelliJ MCP가 연결된 환경에서 에이전트가 심볼·호출 관계·이름 변경·수정 후 검증에 IDE 도구를 grep보다 먼저 쓴다.

---

## 요구사항 (Requirements)

**포함**

- R1: dev 프로파일 init이 `.ai/10_rules/ide-tools.md`를 배포하고, doc 프로파일 init은 배포하지 않는다.
- R2: `ide-tools.md`는 SYNCED 머리글과 버전 주석을 둔 버전 고정 단일 파일이며, 적용 조건(IntelliJ MCP 연결, 대상 프로젝트가 IntelliJ에 열림), 작업별 우선 도구, 기존 도구로 전환하는 조건, 지연 로드 도구 불러오기와 `projectPath` 전달을 담는다.
- R3: dev AI-CONTEXT 템플릿 `## 프로젝트 규칙` 표에 `ide-tools.md` 행이 있고, 설명 열만 읽어도 어떤 작업에 IDE 도구를 먼저 쓰고 언제 grep으로 바꾸는지 알 수 있다.
- R4: shared `context-loading.md`의 `## 코드 수정·리뷰·분석 시`가 `ide-tools.md`를 존재하면 읽는 문서로 가리킨다.
- R5: update-1이 dev 프로파일에서 `ide-tools.md`를 항상 템플릿 최신본으로 덮어쓰고, `SKILL.md`의 프로파일 전용 파일 목록과 복사 정책에 이 파일이 있다.
- R6: update-4 멱등 보강 검사가 dev 표준 SSoT 선언 안내도에서 `ide-tools.md` 행 누락을 `check-context.sh`로 보고하고 표 끝에 표준 행을 넣으며, 기존 사용자 행은 보존한다. doc 선언·비표준 선언 안내도는 검사하지 않는다.
- R7: `ai-workspace/tests/run-tests.sh`가 `ide-tools.md` 행 검사(dev 선언 누락 보고, doc 선언 미보고)와 update-4 fixture를 검사하고 모두 통과한다.
- R8: 이 결정(단일 파일로 둔 이유, 규칙 표 설명 열에 핵심 기준을 적는 이유)을 새 ADR에 남기고 `50_adr/index.md`에 등재한다.
- R9: 이 저장소 `.ai/`에 `ide-tools.md`, 규칙 표 행, `context-loading.md` 라우팅을 템플릿과 같은 내용으로 반영한다.
- R10: `.ai/40_domain/specs/ai-workspace.md`의 dev 배포 파일과 멱등 보강 검사 설명을 새 동작에 맞춘다. (이슈 본문 근거 없음. 2026-11-07 spec 작성 중 #134 R10 선례로 추가, 같은 날 승인)
- R11: update-4가 `## 프로젝트 규칙` 섹션이나 표를 복구한 실행에서 본문 두 번째 줄이 dev 표준 SSoT 선언이면, 선택한 프로파일과 관계없이 `testing-principles.md`·`ide-tools.md` 표준 행이 표에 있다. (이슈 본문 근거 없음. 2026-11-07 함께 해소 후보로 승인) (함께 해소: K-0018)
- R12: update-4가 본문 두 번째 줄을 dev 표준 SSoT 선언으로 넣거나 바꾼 실행(건물 repo 선언을 승인받아 dev로 바꾼 경우 포함)에서 `## 프로젝트 규칙` 표에 `ide-tools.md` 행이 없으면, `testing-principles.md` 행과 함께 표 끝에 표준 행을 넣는다. (이슈 본문 근거 없음. 2026-11-07 계획 감사 발견 F-1 반영으로 추가, 같은 날 승인)

**제외**

- 전역 규칙 파일(`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`): 대체(Claude Code는 `.claude/CLAUDE.md` import로, Codex는 `project_doc_fallback_filenames`로 repo `AI-CONTEXT.md`를 읽어 한 곳으로 두 도구에 적용됨)
- 호출 기록 훅·grep 안내 훅: 보류(사람별 설정이라 `~/.claude/settings.json`에서 따로 다루고, 규칙만으로 호출이 늘지 않을 때 검토)
- `alwaysLoad`·`ENABLE_TOOL_SEARCH`로 도구 미리 적재: 불필요(IntelliJ MCP 도구 101개가 모든 세션의 컨텍스트를 차지)
- `ide-tools-local.md` 쌍 파일: 불필요(repo별로 채울 표가 없고, IDE를 쓰지 않는 환경은 적용 조건으로 처리)
- doc 프로파일 배포: 불필요(코드 탐색 대상이 없음)
- 소비 스킬(`code-map`·`git-review` 등) 본문의 직접 참조: 보류(규칙 표가 스킬 실행에도 선행 적용되므로 효과를 본 뒤 판단)
- 다른 IDE의 MCP: 보류(현재 IntelliJ만 사용)
- 다른 repo 일괄 실행: 대체(머지 후 각 repo에서 update를 실행해 반영)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

아래 명령은 전부 repo 루트에서 `bash`로 실행한다. 출력 0건이면 통과다.

### R1: dev 프로파일 배포

- [ ] [D]  init의 일괄 복사(shared 다음 프로파일)를 dev로 실행하면 `ide-tools.md`가 생기고, doc으로 실행하면 생기지 않는다 (AC1)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=$PWD/ai-workspace/templates; W=$(mktemp -d)
  for p in dev doc; do
    mkdir -p "$W/$p"
    (cd "$W/$p" && cp -r "$T/shared/.ai/" .ai/ && cp -r "$T/$p/.ai/"* .ai/) || echo "위반: $p 복사 실패"
  done
  [ -f "$W/dev/.ai/10_rules/ide-tools.md" ] || echo '위반: dev init 미배포'
  [ ! -e "$W/doc/.ai/10_rules/ide-tools.md" ] || echo '위반: doc init 배포'
  rm -rf "$W"
  ```

  - 설계 주의: 복사 명령은 `ai-workspace/SKILL.md` init-1단계 코드 블록과 같다.
  </details>

### R2: 규칙 파일 구성

- [ ] [D]  `ide-tools.md` 1행은 원본 경로를 담은 SYNCED 머리글, 2행은 버전 주석이다 (AC2)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  [ "$(sed -n 1p "$F" 2>/dev/null)" = '<!-- SYNCED by ai-workspace — 원본: ai-workspace/templates/dev/.ai/10_rules/ide-tools.md, DO NOT EDIT -->' ] || echo '위반: 1행 SYNCED 머리글'
  sed -n 2p "$F" 2>/dev/null | grep -qE '^<!-- 버전: [0-9]+\.[0-9]+\.[0-9]+ -->$' || echo '위반: 2행 버전 주석'
  ```

  </details>
- [ ] [D]  `ide-tools.md`의 `## ` 제목은 `적용 조건`, `작업별 우선 도구`, `기존 도구로 전환하는 조건`, `호출 방법` 4개가 이 순서이고 그 외 `## ` 제목은 없다 (AC2)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  [ "$(grep -E '^## ' "$F" 2>/dev/null)" = "$(printf '%s\n' '## 적용 조건' '## 작업별 우선 도구' '## 기존 도구로 전환하는 조건' '## 호출 방법')" ] \
    || echo '위반: ## 제목 구성'
  ```

  </details>
- [ ] [D]  `## 작업별 우선 도구` 절이 도구 6종(`search_symbol`, `analyze_calls`, `rename_refactoring`, `get_symbol_info`, `lint_files`, `read_file`)을 모두 가리킨다 (AC2)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  S=$(awk '/^## 작업별 우선 도구$/{f=1;next} f&&/^## /{exit} f' "$F" 2>/dev/null)
  for t in search_symbol analyze_calls rename_refactoring get_symbol_info lint_files read_file; do
    printf '%s\n' "$S" | grep -qF "\`$t\`" || echo "위반: $t 없음"
  done
  ```

  - 설계 주의: `build_project`는 선언 변경 뒤에만 쓰는 조건부 도구라(`## 전제`의 Task 0 답변) 이 필수 목록에 넣지 않는다.
  </details>
- [ ] [QD] 적용 조건·전환 조건·호출 방법이 R2 문장의 항목을 빠짐없이 담고, 조건이 맞지 않는 환경에서 기존 도구 사용을 막는 문장이 없다 (AC2)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 조건 문장의 뜻과 누락 여부는 의미 판단이라 명령으로 환원 불가

### R3: 규칙 표 행

- [ ] [D]  dev AI-CONTEXT 템플릿 `## 프로젝트 규칙` 첫 표에 `파일` 셀이 `.ai/10_rules/ide-tools.md`인 행이 정확히 1개이고, 그 행의 설명 셀이 `IntelliJ MCP`와 `grep`을 담는다 (AC3)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=ai-workspace/templates/dev/.ai/AI-CONTEXT.md
  r=$(awk -F'|' '/^## 프로젝트 규칙[[:space:]]*$/{f=1;next} f&&/^## /{exit}
    f&&/^\|/{t=1;v=$2;gsub(/^[[:space:]]+|[[:space:]]+$|`/,"",v); if(v==".ai/10_rules/ide-tools.md") print; next} f&&t{exit}' "$F")
  [ "$(printf '%s\n' "$r" | grep -c .)" -eq 1 ] || echo '위반: 행 수'
  d=$(printf '%s\n' "$r" | awk -F'|' '{print $3}')
  printf '%s\n' "$d" | grep -qF 'IntelliJ MCP' || echo '위반: 설명에 IntelliJ MCP 없음'
  printf '%s\n' "$d" | grep -qF 'grep' || echo '위반: 설명에 grep 없음'
  ```

  - 설계 주의: 행 인정 기준은 `check-context.sh`와 같다(첫 표 블록, `파일` 셀 정확 대조, 백틱·양끝 공백 무시).
  </details>
- [ ] [D]  doc AI-CONTEXT 템플릿에는 `ide-tools.md`가 나오지 않는다 (AC3) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -nF 'ide-tools.md' ai-workspace/templates/doc/.ai/AI-CONTEXT.md
  ```

  </details>
- [ ] [QD] 설명 열만 읽어도 어떤 작업에 IDE 도구를 먼저 쓰고 언제 grep 등 기존 도구로 바꾸는지 판단할 수 있다 (AC3)  (검증: 다른 AI가 행만 보고 채점, 별도 세션)  ← 강등 사유: 문장만으로 판단 가능한지는 이해 가능성 판단이라 명령으로 환원 불가

### R4: context-loading 라우팅

- [ ] [D]  템플릿 `context-loading.md`에서 `.ai/10_rules/ide-tools.md`는 `## 코드 수정·리뷰·분석 시` 절의 목록 항목 1곳에만 나온다 (AC4)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=ai-workspace/templates/shared/.ai/10_rules/context-loading.md
  n=$(awk '/^## 코드 수정·리뷰·분석 시[[:space:]]*$/{f=1;next} f&&/^## /{exit}
    f&&/^([0-9]+\.|-) `\.ai\/10_rules\/ide-tools\.md`/{n++} END{print n+0}' "$F")
  [ "$n" -eq 1 ] || echo "위반: 코드 절 목록 항목 ${n}개"
  [ "$(grep -cF '.ai/10_rules/ide-tools.md' "$F")" -eq 1 ] || echo '위반: 코드 절 밖에도 있음'
  ```

  - 설계 주의: 코드 절은 "작업 유형에 따라 아래 문서가 **존재하면** 먼저 읽는다" 안내 아래에 있어, 파일이 없는 doc repo는 건너뛴다.
  </details>

### R5: update-1 복사

- [ ] [D]  `SKILL.md` update-1 코드 블록을 임시 repo에서 실행하면 dev는 `ide-tools.md`가 없을 때와 구버전일 때 모두 템플릿 최신본과 같아지고, doc은 이 파일을 만들지 않는다 (AC5)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  A=$PWD/ai-workspace; R=.ai/10_rules/ide-tools.md; B=$(mktemp)
  awk '/^### update-1단계/{f=1;next} f&&/^### /{exit} f&&/^```bash$/{c=1;next} c&&/^```$/{exit} c' "$A/SKILL.md" > "$B"
  run() { (cd "$2" && SKILL_DIR="$A" PROFILE="$1" bash "$B") >/dev/null 2>&1; }
  W=$(mktemp -d); mkdir -p "$W/new/.ai" "$W/old/.ai/10_rules" "$W/doc/.ai"; echo '구버전' > "$W/old/$R"
  run dev "$W/new"; run dev "$W/old"; run doc "$W/doc"
  cmp -s "$W/new/$R" "$A/templates/dev/$R" || echo '위반: dev 신규 복사'
  cmp -s "$W/old/$R" "$A/templates/dev/$R" || echo '위반: dev 구버전 덮어쓰기'
  [ -e "$W/doc/.ai/10_rules/document-convention.md" ] || echo '위반: doc 블록 실행 실패'
  [ ! -e "$W/doc/$R" ] || echo '위반: doc 복사'
  rm -rf "$W" "$B"
  ```

  - 설계 주의: 블록 추출·실행 방식은 `run-tests.sh`의 `update1_block`·`run_update1`과 같다. doc 실행은 문서 규약 파일 생성으로 블록이 실제로 돌았는지 먼저 확인한다(실행이 실패하면 미복사 검사가 그대로 통과하기 때문).
  </details>
- [ ] [D]  `SKILL.md`의 `dev` 전용 파일 목록과 update 복사 정책 목록에 `ide-tools.md`가 있다 (AC5)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=ai-workspace/SKILL.md
  grep -E '^- `dev` 전용: ' "$S" | grep -qF '`.ai/10_rules/ide-tools.md`' || echo '위반: dev 전용 파일 목록'
  grep -qE '^- `ide-tools\.md` \(dev 전용\): 버전 고정' "$S" || echo '위반: 복사 정책 목록'
  ```

  </details>

### R6: update-4 행 검사

- [ ] [D]  dev 템플릿에서 `ide-tools.md` 행만 지운 안내도를 `check-context.sh`가 종료 코드 1과 그 행의 누락 보고로 잡는다 (AC6)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=ai-workspace/scripts/check-context.sh; W=$(mktemp -d)
  sed "s/^> last updated: .*/> last updated: $(date +%Y-%m-%d)/" ai-workspace/templates/dev/.ai/AI-CONTEXT.md > "$W/base.md"
  "$C" "$W/base.md" >/dev/null || echo '위반: 변형 전 템플릿이 통과하지 않음'
  grep -qF '`.ai/10_rules/ide-tools.md`' "$W/base.md" || echo '위반: 변형 전 템플릿에 행 없음'
  grep -vF '`.ai/10_rules/ide-tools.md`' "$W/base.md" > "$W/miss.md"
  out=$("$C" "$W/miss.md"); rc=$?
  [ "$rc" -eq 1 ] || echo "위반: 종료 코드 $rc"
  printf '%s\n' "$out" | grep -qxF "누락: '## 프로젝트 규칙' 표의 \`.ai/10_rules/ide-tools.md\` 행" || echo '위반: 누락 보고 없음'
  rm -rf "$W"
  ```

  </details>
- [ ] [D]  doc 템플릿 안내도는 `check-context.sh`를 통과하고 `ide-tools.md`를 보고하지 않는다 (AC7) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=ai-workspace/scripts/check-context.sh; W=$(mktemp -d)
  sed "s/^> last updated: .*/> last updated: $(date +%Y-%m-%d)/" ai-workspace/templates/doc/.ai/AI-CONTEXT.md > "$W/doc.md"
  out=$("$C" "$W/doc.md") || echo "위반: doc 템플릿 검사 실패 — $out"
  printf '%s\n' "$out" | grep -F 'ide-tools.md'
  rm -rf "$W"
  ```

  - 설계 주의: doc 선언에서 검사하지 않는 동작은 행이 없을 때 보고하지 않는 것이라 구현 전에도 통과한다. dev 선언에서 실제로 보고하는지는 위 항목과 R7 러너의 격추 케이스가 판정한다.
  </details>
- [ ] [D]  `SKILL.md` 멱등 보강 검사 표에 첫 셀이 `` `## 프로젝트 규칙` 표의 `ide-tools.md` 행 ``인 행이 1개 있고, 표 항목 수 14와 헬퍼 판정 수 12가 `SKILL.md`·`check-context.sh` 머리말 표기와 맞는다 (AC6)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=ai-workspace/SKILL.md; C=ai-workspace/scripts/check-context.sh
  T=$(awk '/^#### 멱등 보강 검사/{f=1;next} f&&/^#### /{exit} f&&/^\|/' "$S")
  [ "$(printf '%s\n' "$T" | grep -cE '^\| `## 프로젝트 규칙` 표의 `ide-tools\.md` 행 \|')" -eq 1 ] || echo '위반: 검사 표 행'
  [ "$(( $(printf '%s\n' "$T" | grep -c .) - 2 ))" -eq 14 ] || echo '위반: 검사 표 항목 수'
  grep -qF '표의 14개 항목 중 12개' "$S" || echo '위반: SKILL.md 항목 수 표기'
  grep -qF '검사 표 14행 중 12행' "$C" || echo '위반: 헬퍼 머리말 항목 수 표기'
  ```

  </details>
- [ ] [D]  update-4 fixture `missing-rows`는 입력에 `ide-tools.md` 행이 없고 기대 파일 규칙 표 끝에 있으며, dev 골격을 쓰는 `no-rules-section`·`no-rules-table`·`legacy-two-col` 기대 파일에도 이 행이 있다 (AC6)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  X=ai-workspace/tests/fixtures/update4-idempotent; P='`.ai/10_rules/ide-tools.md`'
  grep -qF "$P" "$X/missing-rows.input.md" && echo '위반: missing-rows 입력에 행 있음'
  for c in missing-rows no-rules-section no-rules-table legacy-two-col; do
    grep -qF "$P" "$X/$c.expected.md" || echo "위반: $c 기대 파일에 행 없음"
  done
  last=$(awk '/^## 프로젝트 규칙/{f=1;next} f&&/^## /{exit} f&&/^\|/{l=$0} END{print l}' "$X/missing-rows.expected.md")
  printf '%s\n' "$last" | grep -qF "$P" || echo '위반: missing-rows 기대 파일의 표 끝 행이 아님'
  grep -qF 'ide-tools.md' "$X/missing-rows-doc.expected.md" && echo '위반: doc 기대 파일에 행 있음'
  ```

  </details>
- [ ] [QD] fixture README 절차로 `missing-rows`·`no-rules-section`·`no-rules-table`·`legacy-two-col` 입력에 update-4를 모의 실행하면 기대 파일과 같고, 기대 파일로 다시 실행하면 변경 0건이다 (AC6)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 삽입 조치는 AI가 `SKILL.md` 절차로 수행해 명령으로 재현할 수 없음

### R7: 회귀 테스트

- [ ] [D]  `run-tests.sh`가 0 실패이고, 설명에 `ide-tools`가 든 케이스가 통과 3개 이상, 격추 3개 이상 실행된다 (AC8)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(ai-workspace/tests/run-tests.sh 2>&1) || echo '위반: 러너 실패'
  [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*ide-tools.* 통과')" -ge 3 ] || echo '위반: ide-tools 통과 케이스 3개 미만'
  [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*ide-tools.* 격추')" -ge 3 ] || echo '위반: ide-tools 격추 케이스 3개 미만'
  ```

  - 설계 주의: 러너만 실행하면 케이스를 넣기 전에도 통과해 가짜 `[D]`가 된다. `ok` 행을 `통과`·`격추` 낱말별로 따로 세어 정상 통과와 반례 격추가 모두 실행됐을 때만 통과하게 둔다. 케이스 설명에는 두 낱말 중 하나만 쓴다.
  </details>

### R8: 결정 기록

- [ ] [D]  `.ai/50_adr/active/0029-*.md`가 정확히 1개 있고 `50_adr/index.md` 파일 목록에 그 경로 행이 있다 (AC9)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  f=$(ls .ai/50_adr/active/0029-*.md 2>/dev/null)
  if [ "$(printf '%s\n' "$f" | grep -c .)" -ne 1 ]; then echo '위반: ADR 0029 파일 수'
  else grep -qF "\`active/$(basename "$f")\`" .ai/50_adr/index.md || echo '위반: index 행 없음'; fi
  ```

  </details>
- [ ] [QD] ADR이 단일 파일로 둔 이유(local 쌍을 두지 않은 이유), 규칙 표 설명 열에 핵심 기준을 적는 이유, K-0018 해소 방식을 결정과 근거로 담는다 (AC9)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 결정·근거의 충분성은 의미 판단

### R9: 이 저장소 반영

- [ ] [D]  이 저장소 `.ai/10_rules/ide-tools.md`·`.ai/10_rules/context-loading.md`가 템플릿과 바이트 단위로 같다 (AC10)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  cmp -s .ai/10_rules/ide-tools.md ai-workspace/templates/dev/.ai/10_rules/ide-tools.md || echo '위반: ide-tools.md 사본'
  cmp -s .ai/10_rules/context-loading.md ai-workspace/templates/shared/.ai/10_rules/context-loading.md || echo '위반: context-loading.md 사본'
  ```

  </details>
- [ ] [D]  이 저장소 안내도 규칙 표의 `ide-tools.md` 행이 dev 템플릿 행과 셀 단위(앞뒤 공백 무시)로 같고, `check-context.sh`가 이 안내도를 통과시킨다 (AC10)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  row() { awk -F'|' '/^## 프로젝트 규칙[[:space:]]*$/{f=1;next} f&&/^## /{exit}
    f&&/^\|/{t=1;v=$2;gsub(/^[[:space:]]+|[[:space:]]+$|`/,"",v)
      if(v==".ai/10_rules/ide-tools.md"){for(i=2;i<=4;i++){c=$i;gsub(/^[[:space:]]+|[[:space:]]+$/,"",c);printf "%s|",c};print ""}; next}
    f&&t{exit}' "$1"; }
  a=$(row .ai/AI-CONTEXT.md); b=$(row ai-workspace/templates/dev/.ai/AI-CONTEXT.md)
  { [ -n "$a" ] && [ "$a" = "$b" ]; } || echo '위반: 규칙 표 행 불일치'
  ai-workspace/scripts/check-context.sh .ai/AI-CONTEXT.md >/dev/null || echo '위반: 저장소 안내도 검사 실패'
  ```

  </details>

### R10: 명세 동기화

- [ ] [D]  `specs/ai-workspace.md` `## 요건`의 ai-workspace 요건 줄(파일 단위 최신본 목록), `context-loading.md` 요건 줄, 멱등 보강 검사 요건 줄이 모두 `ide-tools.md`를 가리킨다 (AC11)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=.ai/40_domain/specs/ai-workspace.md
  grep -E '^- ai-workspace: ' "$F" | grep -qF '`ide-tools.md`' || echo '위반: 파일 단위 최신본 목록'
  grep -E '^- 버전 고정 `context-loading\.md`' "$F" | grep -qF '`ide-tools.md`' || echo '위반: context-loading 요건'
  grep -E '^- update 멱등 보강 검사' "$F" | grep -qF '`ide-tools.md`' || echo '위반: 멱등 보강 검사 요건'
  ```

  </details>

### R11: 프로파일이 어긋난 복구의 dev 행 보강

- [ ] [D]  `SKILL.md` 멱등 보강 검사 표의 `## 프로젝트 규칙` 섹션·표 행이 `testing-principles.md`·`ide-tools.md`를 모두 가리킨다 (AC12)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  r=$(awk '/^#### 멱등 보강 검사/{f=1;next} f&&/^#### /{exit} f&&/^\| `## 프로젝트 규칙` 섹션 \+ 3열 표 \|/' ai-workspace/SKILL.md)
  [ "$(printf '%s\n' "$r" | grep -c .)" -eq 1 ] || echo '위반: 섹션·표 행 수'
  printf '%s\n' "$r" | grep -qF 'testing-principles.md' || echo '위반: testing-principles.md 언급 없음'
  printf '%s\n' "$r" | grep -qF 'ide-tools.md' || echo '위반: ide-tools.md 언급 없음'
  ```

  </details>
- [ ] [D]  프로파일 불일치 fixture 2종의 입력은 dev 표준 선언에 각각 섹션 부재·표 부재로 `check-context.sh`에 잡히고, 기대 파일 규칙 표에는 `testing-principles.md`·`ide-tools.md` 행이 있다 (AC12)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  X=ai-workspace/tests/fixtures/update4-idempotent; C=ai-workspace/scripts/check-context.sh
  D='> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.'
  for c in 'no-rules-section-mismatch:섹션 부재' 'no-rules-table-mismatch:섹션은 있고 표 부재'; do
    n=${c%%:*}; s=${c#*:}
    grep -qxF "$D" "$X/$n.input.md" 2>/dev/null || echo "위반: $n 입력이 dev 선언 아님"
    "$C" "$X/$n.input.md" 2>/dev/null | grep -qF "$s" || echo "위반: $n 상태 보고 없음"
    for p in testing-principles.md ide-tools.md; do
      grep -qF "\`.ai/10_rules/$p\`" "$X/$n.expected.md" 2>/dev/null || echo "위반: $n 기대 파일에 $p 행 없음"
    done
  done
  ```

  </details>
- [ ] [QD] 두 fixture 입력에 doc 프로파일로 update-4를 모의 실행하면 기대 파일과 같고, 기대 파일로 다시 실행하면 변경 0건이다 (AC12)  (검증: 다른 AI가 fixture README 절차로 채점, 별도 세션)  ← 강등 사유: 복구·삽입 조치는 AI가 `SKILL.md` 절차로 수행해 명령으로 재현할 수 없음

### R12: 선언을 dev로 보정한 실행의 ide-tools 행 보강

- [ ] [D]  `SKILL.md` 멱등 보강 검사 표의 SSoT 선언 행과 건물 repo 선언 행이 각각 1개이고, 두 행의 조치 셀이 모두 `ide-tools.md`를 가리킨다 (AC13)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=$(awk '/^#### 멱등 보강 검사/{f=1;next} f&&/^#### /{exit} f&&/^\|/' ai-workspace/SKILL.md)
  for h in '본문 두 번째 줄 SSoT 선언' '건물 repo(`repository.yaml` 존재)의 SSoT 선언'; do
    r=$(printf '%s\n' "$T" | grep -F "| $h |")
    if [ "$(printf '%s\n' "$r" | grep -c .)" -ne 1 ]; then echo "위반: $h 행 수"
    else printf '%s\n' "$r" | awk -F'|' '{print $4}' | grep -qF '`ide-tools.md`' || echo "위반: $h 조치 셀에 ide-tools.md 없음"; fi
  done
  ```

  - 설계 주의: 조치 셀(4번째 필드)만 본다. 검사 셀에만 경로를 넣은 변형은 위반으로 잡는다(2026-11-07 임시 사본으로 확인).
  </details>
- [ ] [QD] 두 조치 문장이 선언을 dev 문구로 넣거나 바꾼 실행에서 `ide-tools.md` 행이 없으면 `testing-principles.md` 행과 함께 표 끝에 표준 행을 넣는다는 뜻으로 읽힌다 (AC13)  (검증: 다른 AI가 두 행만 보고 채점, 별도 세션)  ← 강등 사유: 위 `[D]`는 경로 언급만 보므로 조치 문장의 뜻은 의미 판단

### 공통

- [ ] [D]  repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>

---

## 전제 (Assumptions)

**정해진 값** (2026-11-07 대화·spec 작성에서 확정)

- 파일 이름은 `ide-tools.md`다. 사용자가 이 규칙을 "ide 관련 rule"로 부른 데 맞췄다.
- `ide-tools.md`의 `## ` 제목은 `적용 조건`, `작업별 우선 도구`, `기존 도구로 전환하는 조건`, `호출 방법` 4개다. 머리글은 `testing-principles.md`와 같은 형식이고 버전은 `1.0.0`에서 시작한다.
- 전환 조건에는 빈 결과를 "사용처 없음"으로 판단하지 않고 텍스트 검색으로 다시 확인하는 것과, 삭제·이름 변경 전에 리플렉션·설정 파일을 grep으로 한 번 더 확인하는 것을 넣는다. 열린 프로젝트가 아닐 때의 오류 문구는 `doesn't correspond to any open project`이며 2026-11-07 실제 호출로 확인했다.
- 규칙 표 행의 사용 시점은 `코드 탐색·수정 전`이다. 설명 셀에는 `IntelliJ MCP`와 `grep`을 넣는다. 표는 세션 시작부터 컨텍스트에 있어 행만 읽어도 판단되게 하려는 것이며, 코드 탐색이 작업 첫 동작이라 규칙 파일을 읽기 전에 grep부터 실행할 수 있다는 점이 근거다.
- `context-loading.md` 코드 절에는 번호 목록 항목 하나로 추가한다. 위치는 2번(`architecture.md` 다음)이고 뒤 번호를 하나씩 미룬다. 규칙 파일끼리 붙여 두려는 것이다(Task 0에서 확정).
- 템플릿과 이 저장소 규칙 표에서 `ide-tools.md` 행은 알파벳 순서대로 `file-change-policy.md` 다음에 둔다. 기존 repo의 update-4 보강은 R6대로 표 끝에 넣는다(Task 0에서 확정).
- `check-context.sh`는 `testing-principles.md`와 같은 조건(본문 두 번째 줄이 dev 표준 선언)일 때만 `ide-tools.md` 행을 검사한다. 보고 형식은 기존 `누락: '## 프로젝트 규칙' 표의 \`<경로>\` 행`이다.
- K-0018 해소는 원장 항목의 "채택하지 않은 대안"을 채택한다. update-4가 섹션·표를 복구했으면 헬퍼 보고와 별개로, 본문 두 번째 줄이 dev 표준 선언일 때 `testing-principles.md`·`ide-tools.md` 표준 행을 함께 넣는다. fixture 이름은 `no-rules-section-mismatch`·`no-rules-table-mismatch`이고 README에 "dev 선언 + doc 프로파일 선택" 상태임을 적는다.
- K-0018 원장 종결(`해소(PR #N)`, archive 이동)은 이슈 완료 시 원장 해소 기재가 맡는다.
- ADR 번호는 0029다(현재 최대 0028).
- 러너 케이스 설명에는 `ide-tools`를 넣고 `통과`·`격추` 낱말 중 하나만 쓴다(R7 판정 기준).

**환경·관례**

- 검증 명령은 repo 루트에서 `bash`로 실행한다. `testing-principles-local.md`의 테스트 층 표가 비어 있어 이 repo 관례(`<skill>/tests/run-tests.sh`, ADR 0001)를 따른다.
- 셸 문자열에서 변수 바로 뒤에 한글이 오면 `${n}개`처럼 중괄호로 감싼다. macOS 기본 bash는 `$n개`에서 한글 바이트 일부를 변수 이름으로 읽어 값과 글자가 함께 사라진다(2026-11-07 spec 검증 명령 점검에서 확인).
- 템플릿을 바꾸는 Task는 같은 Task에서 이 저장소 사본도 바꾼다. `run-tests.sh`가 이 저장소의 `context-loading.md`를 템플릿과 바이트 단위로 대조하고 이 저장소 안내도를 `check-context.sh`로 검사하므로, 사본을 뒤로 미루면 중간 Task의 러너가 실패한다.
- 이 환경의 IntelliJ MCP 서버는 Claude Code·Codex 모두 `idea`라는 이름으로 등록되어 있다.
- 다른 repo 반영은 머지 후 각 repo에서 update로 하고, 스킬 재설치(`/install-skills`)도 머지 후에 한다.

**Task 0 답변** (2026-11-07 사용자 확정)

- 규칙 본문에 서버 등록 이름을 적지 않고 도구 이름(`search_symbol` 등)으로만 안내한다. 도구 목록에 없으면 도구 이름으로 찾아 불러오라고 적는다(Claude Code는 도구 검색, Codex는 `ALL_TOOLS` 필터). (이슈 `검토 필요` 1)
  - 근거: 두 도구 모두 전체 이름이 `mcp__<등록 이름>__<도구 이름>`이라 등록 이름이 다르면 전체 이름도 달라진다. 두 도구 모두 도구 이름만으로 찾을 수 있다.
  - Codex 동작은 2026-11-07 이 머신의 `codex-cli 0.167.0` 설정과 계획 감사 세션 실행 기록으로 확인했다. MCP 도구를 `exec` 도구 안에서 `tools.mcp__idea__<도구>`로 부르고, IntelliJ 도구는 `exec` 설명에 나오지 않는 지연 도구라 `ALL_TOOLS`를 이름으로 걸러 찾는다.
- 수정 후 검증 기본값은 `lint_files`다. `build_project`는 시그니처·이름·타입처럼 다른 파일에 영향이 가는 선언 변경 뒤에만 쓰고, 도구 설명의 "수정 후 반드시 빌드" 안내보다 이 규칙이 우선한다고 적는다. (이슈 `검토 필요` 2)
- 규칙 표 `ide-tools.md` 행의 설명 셀 문구는 `IDE 도구 우선 규칙 (IntelliJ MCP 연결 시 심볼·호출 관계·이름 변경·수정 후 검증은 IDE 도구 먼저, 연결 실패·문서·문자열 검색은 grep, 빈 결과는 grep으로 재확인)`이다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/50_adr/active/0023-testing-principles-pair-and-consumer-skill-references.md` | 같은 배포 경로의 선례(dev 전용 버전 고정 파일, context-loading 라우팅, dev 선언 한정 행 검사) |
| `.ai/50_adr/active/0008-writing-principles-ssot-distribution.md` | 버전 고정 규칙 파일 배포와 context-loading·AI-CONTEXT 참조 연결의 원 결정 |
| `.ai/50_adr/active/0028-ai-workspace-owned-sections-and-profile-row.md` | update 소유 구분. `## 프로젝트 규칙`은 교체 구간이 아니고 행 검사로 보강 |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | `check-context.sh` 테스트 위치·러너 |
| `.ai/50_adr/active/0003-verification-levels-and-determinization.md` | 완료의 정의 검증 레벨 |
| `.ai/40_domain/specs/ai-workspace.md` | ai-workspace 모드·배포 파일·멱등 보강 검사 명세 (R10 수정 대상) |
| `.ai/40_domain/policies/local/notation-conventions.md` | 파일·스킬 명명 기준, 호환 도구 목록 |
| `.ai/70_ledger/active/K-0018-update4-rules-restore-profile-mismatch-row.md` | R11로 함께 해소하는 원장 항목 |
