# Issue #144 스펙 ai-workspace: ide-tools.md에 실행 표(테스트·커버리지·로컬 서버·디버깅)를 더하고 IntelliJ MCP 도구별 결정 목록으로 표에 없는 도구를 관리한다

## 목표 (Goal)

IntelliJ MCP가 연결된 dev repo에서 에이전트가 테스트·커버리지·로컬 서버·디버깅 실행에도 IDE 도구를 먼저 쓰고, IntelliJ MCP 도구 101개의 사용 여부를 결정 목록과 대조 검사로 관리한다.

---

## 요구사항 (Requirements)

### 포함

#### ide-tools.md 실행 표

- R1: `ide-tools.md`가 실행 작업까지 다루고, 실행 표에 있는 작업만 IDE 도구를 먼저 쓰며 표에 없는 작업은 IDE 도구가 있어도 기존 도구를 쓴다.
  - 머리말의 적용 범위를 "코드 탐색·수정"에서 "코드 탐색·수정·실행"으로 넓힌다.
  - `## 작업별 우선 도구`를 `### 탐색·수정` 표와 `### 실행` 표로 나눈다. 기존 6행은 탐색·수정 표로 옮기고 내용은 그대로 둔다.
  - 실행 표는 테스트 실행·커버리지 확인·로컬 서버 기동·디버깅 4행이고, 행마다 먼저 쓸 도구·쓰는 방법·뒷정리를 적는다.
  - 실행 표에는 `뒷정리` 열을 더한다. 실행은 IDE에 흔적(임시 Run Configuration, 중단점, 떠 있는 프로세스)을 남기기 때문이다. 뒷정리가 없는 행은 `없음`을 적는다.
  - 테스트·커버리지 실행의 흔적(임시 Run Configuration, 에디터의 커버리지 표시)은 그대로 둔다. IntelliJ가 임시 구성을 기본 5개까지만 남기고(한도는 IDE 설정에서 바꿀 수 있다) 오래된 것부터 지우며, 커버리지 표시를 끄는 MCP 도구가 없다.
    - 이슈 `검토 필요` 1을 2026-11-22 Task 1에서 결정했다.
  - IDE로 띄운 프로세스(로컬 서버, `timeout` 안에 끝나지 않은 테스트)는 계속 돌고 있다고 사용자에게 알리고 종료를 요청한다. 일반 실행 프로세스를 끄는 MCP 도구가 없다.
    - 이슈 `검토 필요` 2를 2026-11-22 Task 1에서 결정했다. 이슈 본문에 없던 결과라 범위 확장으로 AC31을 더했다.
  - 표 아래에 "표에 없는 작업은 IDE 도구가 있어도 기존 도구를 쓴다"를 적는다.
- R2: 테스트 실행은 IDE run point로 실행하고 종료 코드와 로그의 실패 건수로 판정한다.
  - `get_run_configurations(filePath)`로 run point를 찾고 `execute_run_configuration(filePath, line, waitForExit=true, timeout)`으로 실행한다.
  - 판정은 `exitCode`와 `fullOutputPath` 로그의 실패 건수로 한다.
  - `exitCode`가 없으면 `timeout` 안에 끝나지 않은 것이다. 프로세스가 계속 돌고 있으므로 판정하지 않는다.
  - `fullOutputPath`가 없어 실패 건수를 확인할 수 없으면 `exitCode`가 0이어도 통과로 판정하지 않고 러너 명령으로 판정한다. `fullOutputPath`는 선택 필드이고 결과의 출력은 그 순간의 일부만 담기 때문이다(2026-11-22 계획 감사 F-13).
- R3: 커버리지 확인은 커버리지 실행으로 변경한 줄이 실행됐는지 본다.
  - `coverage_run_configuration(filePath, line)`으로 실행하고 `coverage_get_file`로 변경한 줄이 실행됐는지 본다.
  - 결과를 아직 불러오는 중이면 `coverage_get_status`로 확인한다.
- R4: 로컬 서버는 `testing-principles-local.md`에 적힌 Run Configuration으로 띄우고, 적힌 이름이 없으면 사용자가 목록에서 고른다.
  - `execute_run_configuration(configurationName, waitForExit=false)`로 띄운다.
  - 적힌 이름이 없으면 `get_run_configurations()` 목록을 보여 주고 사용자에게 고르게 한다. 목록이 비어 있으면 서버를 띄우지 않고 서버용 Run Configuration을 만들어 달라고 사용자에게 요청한다(2026-11-23 최종 감사 F-5). 기존 repo의 local 파일은 update가 보존하므로 새 자리가 생기지 않는다.
  - 목록에서는 구성 이름만 보여 준다. 반환값에 환경 변수·실행 인자 같은 실행 정보가 함께 들어 있어, 그대로 옮기면 설정에 든 자격 증명이 대화에 나온다(2026-11-22 계획 감사 F-12).
- R5: 디버깅은 중단점을 건 뒤 세션을 시작해 멈출 때까지 기다리고, 멈춘 뒤 스택 → 프레임 값 → 식 평가 순서로 확인한다.
  - 내용이 길면 표에는 요약을 두고 순서는 표 아래 목록에 둔다.
  - 중단점은 줄이면 `xdebug_set_breakpoints`, 예외면 `jvm_debug_set_exception_breakpoint`, 메서드면 `jvm_debug_set_method_breakpoint`로 건다.
  - 멈추지 않고 값만 기록할 때는 `logExpression`과 `suspendPolicy=NONE`을 준 로그 지점을 쓴다.
  - `xdebug_start_debugger_session`으로 시작하고, 멈추는 중단점이 있으면 `xdebug_control_session(action=WAIT_FOR_PAUSE)`로 멈출 때까지 기다린다.
  - 로그 지점만 걸었으면 프로그램이 멈추지 않으므로 기다리지 않고 `xdebug_control_session(action=DRAIN_EVENTS)`로 기록한 값을 읽는다. 기록은 JVM 디버거에서만 돌아온다(2026-11-22 계획 감사 F-11).
  - 멈춘 뒤 `xdebug_get_stack` → `xdebug_get_frame_values` → `xdebug_evaluate_expression` 순서로 확인한다.
  - 프로그램이 멈추거나 느린 원인은 `jvm_debug_get_thread_dump`로 본다.
  - 보조 조회 도구(`xdebug_get_threads`·`xdebug_get_value_by_path`·`xdebug_get_debugger_status`·`xdebug_get_process_output`·`xdebug_list_breakpoints`·`xdebug_run_to_line`, `xdebug_control_session`의 단계 실행)는 디버깅 중에 쓸 수 있다고 적는다.
  - 디버깅은 사용자가 요청할 때만 시작한다. 디버그 세션은 프로그램을 띄우고 IDE에 디버그 창과 중단점을 남기기 때문이다.
    - 이슈 `검토 필요` 3을 2026-11-22 요구사항 승인에서 결정했다.
- R6: 디버깅은 사용자 중단점을 건드리지 않고, 끝나면 세션을 멈추고 에이전트가 만든 중단점만 지운다.
  - 예외·메서드 중단점은 걸기 전에 `jvm_debug_list_exception_breakpoints`·`jvm_debug_list_method_breakpoints`로 같은 대상의 중단점을 확인하고, 있으면 소유자와 관계없이 건드리지 않는다. 도구가 같은 대상의 기존 설정을 덮어쓰기 때문이다. 사용자 중단점은 소유자가 `user`로 남아 뒷정리로 되돌릴 수 없고, 앞선 작업이 건 에이전트 중단점은 그 작업이 정한 설정을 잃는다(2026-11-23 최종 감사 2차 F-9).
  - 예외·메서드 중단점은 설정 응답의 `created`가 `true`일 때만 응답의 `breakpointId`를 기록한다. `false`면 다른 작업이 같은 대상에 건 중단점을 덮어쓴 것이라 기록하지 않고, `created`가 없으면 기록하지 않고 뒷정리에서 지울지 사용자에게 묻는다. 목록 도구로는 어느 호출이 그 중단점을 만들었는지 알 수 없다(2026-11-23 최종 감사 3차 F-11·4차 F-12). 사전 확인과 설정 사이에 다른 세션이 같은 대상을 걸어 그 설정을 덮어쓰는 경합은 원장 K-0038로 수용했다.
  - 뒷정리는 `xdebug_control_session(action=STOP)`과, 이번 작업에서 건 중단점의 ID를 `breakpointId`로 `owner=agent`와 함께 준 `xdebug_remove_breakpoints`다. `owner`만 주면 앞선 작업이나 다른 세션이 건 에이전트 중단점까지 지워진다(2026-11-23 최종 감사 F-4). ID를 잃었으면 `owner=agent` 중단점 목록을 보여 주고 지울지 사용자에게 묻는다. 사용자 중단점(`owner=user`)은 건드리지 않는다.
- R7: 검증 레벨 `[D]` 판정과 이슈 완료·PR 전 회귀 판정은 IDE 실행이 있어도 러너 명령으로 한다.
  - 실행 표 아래에 "검증 레벨 `[D]` 판정과 이슈 완료·PR 전 회귀 판정은 `testing-principles-local.md` 테스트 층 표의 러너 명령으로 한다"를 적는다.

#### ide-tools.md 탐색·수정 표와 나머지 절

- R8: 탐색·수정 표에 의존성·모듈 구조 확인, 수정 후 import 정리, 사용자가 가리킨 파일 확인 3행을 더하고 기존 6행의 내용은 바꾸지 않는다.
  - 의존성·모듈 구조 확인: `get_project_dependencies`·`get_project_modules`
  - 수정 후 import 정리: `optimize_imports`. 수정한 파일에만 쓰고, 결과 diff에 손대지 않은 import의 재정렬이 섞이면 되돌린다.
  - 사용자가 가리킨 파일 확인: `get_all_open_file_paths`. 사용자가 "이 파일"처럼 IDE에 열린 파일을 가리킬 때 쓴다.
- R9: 사용자가 요청할 때만 쓰는 도구를 이유와 함께 적는다.
  - `reformat_file`: 파일 전체 서식을 바꿔 손대지 않은 줄까지 diff에 들어간다.
  - `xdebug_set_variable`: 실행 중 값을 바꿔 결과가 실제 코드 동작과 달라진다.
  - `open_file_in_editor`·changelist 도구: 사용자의 IDE 화면과 변경 목록을 바꾼다.
    - changelist 도구는 변경 목록을 바꾸는 `create_changelist`·`delete_changelist`·`move_changes_to_changelist`·`set_active_changelist`를 이름으로 적는다. 묶음 표기만 두면 R14 검사가 이름을 읽지 못해 이 도구들의 결정이 바뀌어도 실패하지 않는다(2026-11-22 계획 감사 F-10). 읽기 전용 `get_changelists`는 Task 3에서 결정한다.
  - `convert_java_to_kotlin`: 파일의 언어를 바꾼다.
- R10: grep 재확인 조건의 문자열 참조 예시에 "XML 매퍼·뷰 템플릿"을 더한다.
- R11: `## 호출 방법`에 작업을 시작할 때 그 행의 도구를 한 번에 불러온다는 문장을 더한다.
  - 디버깅은 도구가 6~8개 필요하고, #136에서 IDE 도구를 쓰지 않은 원인이 지연 로드였다.
- R12: `ide-tools.md` 버전 주석을 올려, dev repo에서 update를 실행하면 새 본문으로 덮어써진다.

#### 도구별 결정 목록

- R13: IntelliJ MCP 도구 101개마다 결정과 이유를 적은 결정 목록이 `.ai/40_domain/specs/ide-tools-decisions.md`에 있고, `.ai/40_domain/index.md`가 이 파일을 가리킨다.
  - 결정 값은 `표에 둠`·`기존 도구`·`쓰지 않음`·`보류`이고, 이유는 한 줄이다.
  - 머리에 확인일·IntelliJ 버전·도구 수와 도구 이름 목록을 받는 방법(Claude Code 지연 도구 목록에서 `mcp__<등록 이름>__` 접두어 제거, Codex `ALL_TOOLS`)을 적는다.
- R14: `ide-tools.md`에 적힌 도구 이름과 결정 목록이 어긋나면 `ai-workspace/tests/run-tests.sh`가 실패한다.
- R15: 도구 이름 목록 파일을 받아 결정 목록과 대조하는 헬퍼가 배포하지 않는 위치에 있다.
  - 결정 목록에 없는 도구와 목록에서 사라진 도구를 한 줄씩 출력한다.
  - 차이가 있으면 종료 코드 1, 없으면 0이다.

#### 연결 문서와 검사

- R16: dev `AI-CONTEXT.md` 템플릿의 `ide-tools.md` 행은 설명 열만 읽어도 실행 작업에서 IDE 도구를 먼저 쓰는 기준을 알 수 있고, 사용 시점이 "코드 탐색·수정·실행 전"이다.
- R17: `ai-workspace/SKILL.md` update-4 검사 표의 `ide-tools.md` 표준 행 문구와 update-4 fixture 8개의 같은 행이 템플릿 행과 같다.
  - fixture 8개는 `expected.md` 7개와 `unsorted-rows.input.md`다.
- R18: shared `context-loading.md`가 테스트 작성·실행 절에서도 `ide-tools.md`를 가리키고, `run-tests.sh` 라우팅 검사가 새 배치를 지킨다.
  - `## 테스트 작성·실행 시` 목록에 `ide-tools.md`를 넣고, `## 코드 수정·리뷰·분석 시` 2번 설명을 범위 변경에 맞춘다.
  - `run-tests.sh`의 context-loading 라우팅 검사를 새 배치(코드 절 1곳, 테스트 절 1곳)에 맞춘다. 그 밖의 절에 적힌 `ide-tools.md`는 계속 실패로 잡는다.
- R19: dev `testing-principles-local.md` 템플릿에 로컬 서버 Run Configuration 이름과 IDE 미연결 시 실행 명령을 적을 자리가 있다.
- R20: 이 저장소의 `.ai/10_rules/context-loading.md`·`.ai/10_rules/ide-tools.md`와 `.ai/AI-CONTEXT.md`의 `ide-tools.md` 행이 템플릿과 같다.
  - context-loading 사본은 `run-tests.sh`가 템플릿과 바이트 단위로 비교한다.
- R21: 결정 이력을 ADR에 남기고, 도구별 결정 목록의 위치와 다시 비교하는 계기(IntelliJ 업데이트)를 함께 적는다.
  - 실행 표, 결정 목록의 위치와 다시 비교하는 계기, IDE 실행과 러너 판정의 분리는 새 ADR에 둔다.
  - ADR 0029는 바뀐 결정(적용 범위, 사용 시점, context-loading 라우팅)만 제자리에서 고치고, 근거에 변경 날짜·이슈 번호·경위를 적는다. ADR index `## 수명 주기`의 일부 변경 규칙과 ADR 0026·0016 선례를 따른다.
  - 이슈 `검토 필요` 5를 2026-11-22 요구사항 승인에서 결정했다.
  - ADR 0023도 이번 변경으로 낡는 두 결정만 같은 규칙으로 제자리에서 고친다. local 템플릿 섹션 구성에 `## 로컬 서버`를 더하고(R19), context-loading `## 테스트 작성·실행 시` 섹션이 `ide-tools.md`도 가리킨다고 적는다(R18).
    - 이슈 본문 근거 없음. 2026-11-22 계획 감사 F-6에서 유효한 ADR 0023과의 충돌로 지적되어 추가했다.
    - AC25에는 ADR 0023이 없어 이 변경의 검증은 plan Task 5 완료 기준이 맡고, spec 완료의 정의에는 두지 않는다(2026-11-22 계획 감사 F-15).
- R22: K-0028 재검토 이력에 이번 재검토 결과를 남긴다.
  - 이번 라우팅 변경이 재검토 조건("`context-loading.md`의 `ide-tools.md` 라우팅이 바뀔 때")에 해당한다.
- R23: 도메인 명세 `ai-workspace.md`와 이 저장소 안내도의 디렉토리 구조 설명이 바뀐 context-loading 라우팅·새 파일과 일치한다.
  - 이슈 본문 근거 없음. `.ai/40_domain/specs/ai-workspace.md`가 context-loading 테스트 절을 `testing-principles.md`·local만으로 적고 있어 이번 변경 뒤 어긋난다. 목록 대조 헬퍼가 `ai-workspace/tests/` 아래에 생기면 안내도의 디렉토리 구조 설명도 어긋난다. 2026-11-22 spec 작성 중 #136 R10·#142 R11 선례로 추가했고, 같은 날 요구사항 승인에서 확정했다.

### 제외

#### 보류

- IntelliJ MCP 서버의 `tools/list`를 헬퍼가 직접 호출해 목록 받기: 보류(IntelliJ가 켜져 있어야 하고 연결 절차가 필요하다. 목록 파일로 대조하다가 수집이 번거로우면 다시 본다)
- MCP는 연결됐는데 표의 도구를 찾지 못할 때 사용자에게 알리기: 보류(도구 이름 변경은 목록 대조 헬퍼로 확인한다. 이름 변경으로 IDE 도구를 놓친 사례가 나오면 다시 본다)
- inspection.kts 도구 6종과 `generate_psi_tree`: 보류(직접 만든 검사로 구조 검색에 쓸 수 있지만 써 본 경험이 없다)
- `jvm_debug_memory_*` 4종: 보류(메모리 분석이 필요한 사례가 아직 없다)
- `xdebug_attach_to_process`: 보류(밖에서 띄운 프로세스에 디버그 에이전트가 있어야 붙일 수 있다)
- 이미 배포된 repo 안내도의 `ide-tools.md` 행 설명 갱신: 보류(update-4는 행이 있으면 사용자 행으로 보존한다. 본문과 context-loading 코드·테스트 절은 update가 덮어써 새 실행 규칙을 읽게 되므로, 행 설명은 필요한 repo에서 직접 고친다. 옛 행 설명 때문에 실행 작업에서 IDE 도구를 놓친 사례가 나오면 다시 본다. 이슈 `검토 필요` 4를 2026-11-22 요구사항 승인에서 결정)

#### 대체

- `ide-tools-local.md` 쌍: 대체(repo별 값인 Run Configuration 이름·셸 명령은 `testing-principles-local.md`가 맡고, ADR 0029의 단일 파일 결정을 유지한다)
- 도구별 결정 목록을 ADR 근거에 두는 안: 대체(목록이 바뀔 때마다 ADR 이력이 늘어나므로 `40_domain/specs/`에 두고 ADR에는 위치만 적는다)
- 기존 도구와 겹치는 IDE 도구(`search_text`·`search_regex`·`search_file`·`list_directory_tree`·`apply_patch`·`create_new_file`·`get_file_problems`): 대체(grep·파일 읽기·편집 도구와 `lint_files`가 맡는다. 텍스트 검색은 grep보다 나은 점이 없다)

#### 불필요

- "IDE로 할 수 있으면 IDE 우선"이라는 포괄 원칙: 불필요(IntelliJ MCP에 터미널·git·DB·SQL 도구까지 있어 의도보다 범위가 넓어지고, 판단이 세션마다 갈린다)
- IDE 터미널·git·DB·SQL 도구 행: 불필요(기존 도구가 맡는다. IDE에 등록된 DB 연결은 대상 환경을 알 수 없다)
- 노트북 도구, `execute_tool`, `air_set_session_title`, `spec_*`: 불필요(이 규칙의 작업과 관계없는 IDE 기능이거나, 다른 도구를 이름으로 대신 부르는 도구다)
- `testing-principles.md` 본문 변경: 불필요("회귀 판정은 스크립트 러너로 한다"는 규칙은 그대로다. IDE 실행은 러너를 부르는 방법이라 `ide-tools.md`가 맡는다)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> 검증 명령은 repo 루트에서 bash로 실행한다. 출력 0건이면 통과다.

### R1: 실행 범위와 표 구조

- [ ] [D] dev 템플릿 `ide-tools.md` 머리말의 적용 범위가 "코드 탐색·수정·실행"이다 (AC1)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  grep -m1 '^> ' "$T" | grep -qF '코드 탐색·수정·실행' || echo '위반: 머리말 적용 범위'
  ```

  </details>
- [ ] [D] `## 작업별 우선 도구` 아래 소제목이 `### 탐색·수정`·`### 실행` 두 개뿐이고 이 순서다 (AC1)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  got=$(awk '/^## 작업별 우선 도구[[:space:]]*$/ { f = 1; next } f && /^## / { exit } f && /^### / { print }' "$T" | tr '\n' '|')
  [ "$got" = '### 탐색·수정|### 실행|' ] || echo "위반: 소제목 구성 [$got]"
  ```

  </details>
- [ ] [D] 실행 표 머리행이 `작업 | 먼저 쓸 도구 | 쓰는 방법 | 뒷정리`이고, 데이터 행은 테스트 실행·커버리지 확인·로컬 서버 기동·디버깅 4개가 이 순서이며 네 칸이 모두 비어 있지 않다 (AC2)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit } f && /^\|/' "$T" | awk -F'|' '
    function t(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    NR == 1 { if (NF != 6 || t($2) "|" t($3) "|" t($4) "|" t($5) != "작업|먼저 쓸 도구|쓰는 방법|뒷정리") print "위반: 머리행 " $0; next }
    NR == 2 { next }
    { names = names t($2) "|"; if (NF != 6) print "위반: 열 수 " $0; for (i = 2; i <= 5; i++) if (t($i) == "") print "위반: 빈 칸 " $0 }
    END { if (names != "테스트 실행|커버리지 확인|로컬 서버 기동|디버깅|") print "위반: 행 구성 [" names "]" }'
  ```

  - 설계 주의: 칸을 `|`로 나누므로 표 셀 안에 `|` 문자를 쓰지 않는다. `### 실행` 소절에 표가 둘 이상이면 두 번째 표의 행이 데이터 행으로 세어져 실패한다.
  </details>
- [ ] [D] "표에 없는 작업은 IDE 도구가 있어도 기존 도구를 쓴다" 문장이 파일 전체에서 1곳이고, 실행 표 마지막 행보다 뒤, `### 실행` 소절이 끝나기 전에 있다 (AC3)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  s='표에 없는 작업은 IDE 도구가 있어도 기존 도구를 쓴다'
  at=$(grep -nF -- "$s" "$T" | cut -d: -f1)
  r=$(awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit } f && /^\|/ { n = NR } END { print n + 0 }' "$T")
  e=$(awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { e = NR; exit } END { print (e ? e : NR + 1) }' "$T")
  { [ "$(printf '%s\n' "$at" | grep -c .)" -eq 1 ] && [ "$r" -gt 0 ] && [ "$at" -gt "$r" ] && [ "$at" -lt "$e" ]; } \
    || echo "위반: 문장 위치 (문장 줄 [$at], 표 끝 $r, 소절 끝 $e)"
  ```

  </details>
- [ ] [D] 테스트 실행·커버리지 확인·로컬 서버 기동 행의 뒷정리가 이슈 `검토 필요` 1·2 결정과 같다. 테스트 실행 행은 임시 구성을 그대로 두고 끝나지 않은 프로세스는 사용자에게 알려 종료를 요청하며, 커버리지 확인 행은 `없음`이고, 로컬 서버 기동 행은 사용자에게 알려 종료를 요청한다 (AC2, AC31)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit } f && /^\|/' "$T" | awk -F'|' '
    function t(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    NR <= 2 { next }
    { k = t($2); c = t($5) }
    k == "테스트 실행" { a++; if (!index(c, "그대로 둔다") || !index(c, "사용자에게 알리고 종료를 요청한다")) print "위반: 테스트 실행 뒷정리 [" c "]" }
    k == "커버리지 확인" { b++; if (c !~ /^없음/) print "위반: 커버리지 확인 뒷정리 [" c "]" }
    k == "로컬 서버 기동" { s++; if (!index(c, "사용자에게 알리고 종료를 요청한다")) print "위반: 로컬 서버 기동 뒷정리 [" c "]" }
    END { if (a != 1 || b != 1 || s != 1) print "위반: 행 수 테스트=" a + 0 ", 커버리지=" b + 0 ", 서버=" s + 0 }'
  ```

  - 설계 주의: 뒷정리는 네 번째 칸(`$5`)이다. 커버리지 확인 행은 `없음`으로 시작하면 뒤에 이유를 붙여도 된다(예: `없음(임시 구성·커버리지 표시는 그대로 둔다)`).
  </details>

### R2: 테스트 실행

- [ ] [D] 테스트 실행 행에 run point 조회·실행 도구와 인자, `exitCode`와 `fullOutputPath` 로그의 실패 건수로 판정한다는 기준, `exitCode`가 없으면 판정하지 않는다는 조건, 실패 건수를 확인할 수 없으면 러너 명령으로 판정한다는 조건이 있다 (AC4)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  row=$(awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit } f && /^\|/' "$T" \
    | awk -F'|' '{ c = $2; gsub(/^[ \t]+|[ \t]+$/, "", c) } c == "테스트 실행"')
  [ "$(printf '%s\n' "$row" | grep -c .)" -eq 1 ] || echo '위반: 테스트 실행 행 수'
  for k in 'get_run_configurations(filePath)' 'execute_run_configuration(filePath, line, waitForExit=true, timeout)' \
           '`exitCode`' '`fullOutputPath`' '실패 건수' '`exitCode`가 없으면' '판정하지 않는다' \
           '실패 건수를 확인할 수 없으면' '러너 명령으로 판정한다'; do
    printf '%s\n' "$row" | grep -qF -- "$k" || echo "위반: 테스트 실행 행에 [$k] 없음"
  done
  ```

  </details>

### R3: 커버리지 확인

- [ ] [D] 커버리지 확인 행에 `coverage_run_configuration(filePath, line)`·`coverage_get_file`·`coverage_get_status`가 있고, 변경한 줄을 확인한다는 것과 결과를 불러오는 중일 때의 확인 조건이 있다 (AC2)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  row=$(awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit } f && /^\|/' "$T" \
    | awk -F'|' '{ c = $2; gsub(/^[ \t]+|[ \t]+$/, "", c) } c == "커버리지 확인"')
  [ "$(printf '%s\n' "$row" | grep -c .)" -eq 1 ] || echo '위반: 커버리지 확인 행 수'
  for k in 'coverage_run_configuration(filePath, line)' 'coverage_get_file' 'coverage_get_status' '변경한 줄' '불러오는 중'; do
    printf '%s\n' "$row" | grep -qF -- "$k" || echo "위반: 커버리지 확인 행에 [$k] 없음"
  done
  ```

  </details>

### R4: 로컬 서버 기동

- [ ] [D] 로컬 서버 기동 행에 `execute_run_configuration(configurationName, waitForExit=false)`, 구성 이름을 `testing-principles-local.md`에서 읽는다는 것, 이름이 없으면 `get_run_configurations()` 목록을 보여 주고 사용자에게 고르게 한다는 조건, 목록에서는 구성 이름만 보여 준다는 조건이 있다 (AC5)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  row=$(awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit } f && /^\|/' "$T" \
    | awk -F'|' '{ c = $2; gsub(/^[ \t]+|[ \t]+$/, "", c) } c == "로컬 서버 기동"')
  [ "$(printf '%s\n' "$row" | grep -c .)" -eq 1 ] || echo '위반: 로컬 서버 기동 행 수'
  for k in 'execute_run_configuration(configurationName, waitForExit=false)' 'testing-principles-local.md' \
           '이름이 없으면' 'get_run_configurations()' '사용자에게 고르게 한다' '구성 이름만'; do
    printf '%s\n' "$row" | grep -qF -- "$k" || echo "위반: 로컬 서버 기동 행에 [$k] 없음"
  done
  ```

  </details>

### R5: 디버깅 절차

- [ ] [D] `### 실행` 소절(표와 표 아래 목록)에 중단점 종류별 도구 3종, 로그 지점 인자, 세션 시작·대기 도구, 로그 지점 기록을 읽는 도구, 스레드 덤프 도구, 보조 조회 도구가 있다 (AC6)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  x=$(awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit } f' "$T")
  for k in xdebug_set_breakpoints jvm_debug_set_exception_breakpoint jvm_debug_set_method_breakpoint \
           logExpression suspendPolicy=NONE xdebug_start_debugger_session 'xdebug_control_session(action=WAIT_FOR_PAUSE)' \
           'xdebug_control_session(action=DRAIN_EVENTS)' jvm_debug_get_thread_dump xdebug_get_threads xdebug_get_value_by_path xdebug_get_debugger_status \
           xdebug_get_process_output xdebug_list_breakpoints xdebug_run_to_line '단계 실행'; do
    printf '%s\n' "$x" | grep -qF -- "$k" || echo "위반: 실행 소절에 [$k] 없음"
  done
  ```

  </details>
- [ ] [D] 멈춘 뒤 확인 순서가 한 줄 안에 `xdebug_get_stack` → `xdebug_get_frame_values` → `xdebug_evaluate_expression` 순서로 적혀 있다 (AC6)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit }
    f { a = index($0, "xdebug_get_stack"); b = index($0, "xdebug_get_frame_values"); c = index($0, "xdebug_evaluate_expression")
        if (a && b && c && a < b && b < c) n++ }
    END { if (!n) print "위반: 멈춘 뒤 확인 순서" }' "$T"
  ```

  </details>
- [ ] [D] 디버깅은 사용자가 요청할 때만 시작한다는 문장이 `### 실행` 소절에 있다 (AC28)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit }
    f && index($0, "디버깅") && index($0, "사용자가 요청할 때만") { n++ } END { if (!n) print "위반: 디버깅 시작 조건" }' "$T"
  ```

  </details>

### R6: 디버깅 뒷정리

- [ ] [D] 디버깅 행의 뒷정리 칸에 `xdebug_control_session(action=STOP)`과 `owner=agent`를 준 `xdebug_remove_breakpoints`가 있고, `### 실행` 소절에 사용자 중단점(`owner=user`)은 건드리지 않는다는 문장이 있다 (AC7)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  x=$(awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit } f' "$T")
  cell=$(printf '%s\n' "$x" | awk -F'|' '/^\|/ { c = $2; gsub(/^[ \t]+|[ \t]+$/, "", c); if (c == "디버깅") print $5 }')
  for k in 'xdebug_control_session(action=STOP)' 'xdebug_remove_breakpoints' 'owner=agent'; do
    printf '%s\n' "$cell" | grep -qF -- "$k" || echo "위반: 디버깅 뒷정리 칸에 [$k] 없음"
  done
  printf '%s\n' "$x" | awk 'index($0, "owner=user") && index($0, "건드리지 않는다") { n++ } END { if (!n) print "위반: 사용자 중단점 보존 문장" }'
  ```

  </details>
- [ ] [D] 예외·메서드 중단점을 걸기 전에 확인 도구 2종으로 같은 대상의 중단점을 확인하고, 있으면 소유자와 관계없이 건드리지 않는다는 문장이 `### 실행` 소절에 있다 (AC7)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit }
    f && index($0, "걸기 전에") && index($0, "jvm_debug_list_exception_breakpoints") && index($0, "jvm_debug_list_method_breakpoints") \
      && index($0, "같은 대상") && index($0, "소유자와 관계없이") && index($0, "건드리지 않는다") { n++ }
    END { if (!n) print "위반: 예외·메서드 중단점 사전 확인 문장" }' "$T"
  ```

  - 설계 주의: 확인 시점(`걸기 전에`)과 대상(`같은 대상`)을 도구 이름과 같은 줄에서 찾는다. 도구 이름만 찾으면 중단점을 건 뒤 조회하는 문장도 통과한다.
  - 설계 주의: `소유자와 관계없이`를 함께 찾는다. 사용자 중단점만 피하면 앞선 작업이 같은 대상에 건 에이전트 중단점을 덮어쓰고 이번 작업의 ID로 기록해 지운다(2026-11-23 최종 감사 2차 F-9).
  </details>
- [ ] [D] 예외·메서드 중단점은 설정 응답의 `created`가 `true`일 때만 `breakpointId`를 기록하고, `false`이거나 `created`가 없으면 기록하지 않는다는 문장이 `### 실행` 소절에 있다 (AC7)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit }
    f && index($0, "예외·메서드 중단점은 설정 응답의") && index($0, "`created`가 `true`일 때만") && index($0, "`breakpointId`를 기록한다") \
      && index($0, "`created`가 `false`면") && index($0, "`created`가 없으면") && index($0, "기록하지 않") && index($0, "사용자에게 묻는다") { n++ }
    f && index($0, "건 뒤") && index($0, "같은 항목의 ID") { old++ }
    END { if (!n) print "위반: 예외·메서드 중단점 created 판정 문장"; if (old) print "위반: 목록 도구에서 ID를 찾는 옛 문장이 남음" }' "$T"
  ```

  - 설계 주의: `true`·`false`·필드 없음의 세 경우를 한 줄에서 찾는다. 하나만 찾으면 `false` 응답의 ID를 기록하는 문구도 통과한다.
  - 설계 주의: 목록 도구에서 건 대상과 같은 항목의 ID를 찾던 3차 보정 문구는 같은 대상을 다른 세션이 만든 경우를 가리지 못한다. 그 문구가 남으면 위반을 낸다(2026-11-23 최종 감사 4차 F-12).
  </details>

### R7: 러너 판정

- [ ] [D] "검증 레벨 `[D]` 판정과 이슈 완료·PR 전 회귀 판정은 `testing-principles-local.md` 테스트 층 표의 러너 명령으로 한다" 문장이 파일 전체에서 1곳이고, 실행 표 마지막 행보다 뒤, `### 실행` 소절이 끝나기 전에 있다 (AC8)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  s='검증 레벨 `[D]` 판정과 이슈 완료·PR 전 회귀 판정은 `testing-principles-local.md` 테스트 층 표의 러너 명령으로 한다'
  at=$(grep -nF -- "$s" "$T" | cut -d: -f1)
  r=$(awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit } f && /^\|/ { n = NR } END { print n + 0 }' "$T")
  e=$(awk '/^### 실행[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { e = NR; exit } END { print (e ? e : NR + 1) }' "$T")
  { [ "$(printf '%s\n' "$at" | grep -c .)" -eq 1 ] && [ "$r" -gt 0 ] && [ "$at" -gt "$r" ] && [ "$at" -lt "$e" ]; } \
    || echo "위반: 문장 위치 (문장 줄 [$at], 표 끝 $r, 소절 끝 $e)"
  ```

  </details>

### R8: 탐색·수정 표

- [ ] [D] 탐색·수정 표의 머리행은 그대로이고, 데이터 행은 기준 커밋 `bc26506`의 6행을 글자 그대로 포함한 9행이며, 새 3행의 첫 칸은 의존성·모듈 구조 확인·수정 후 import 정리·사용자가 가리킨 파일 확인이다 (AC9)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  base=$(git show bc26506:"$T" | awk '/^\|/ && !/^\| 작업 \|/ && !/^\|-/')
  tbl=$(awk '/^### 탐색·수정[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit } f && /^\|/' "$T")
  [ "$(printf '%s\n' "$base" | grep -c .)" -eq 6 ] || echo '위반: 기준 커밋 6행 추출 실패'
  [ "$(printf '%s\n' "$tbl" | sed -n 1p)" = '| 작업 | 먼저 쓸 도구 | 쓰는 방법 |' ] || echo '위반: 탐색·수정 표 머리행'
  data=$(printf '%s\n' "$tbl" | sed -n '3,$p')
  [ "$(printf '%s\n' "$data" | grep -c .)" -eq 9 ] || echo '위반: 탐색·수정 표 데이터 행 수'
  printf '%s\n' "$base" | while IFS= read -r l; do
    printf '%s\n' "$data" | grep -qxF -- "$l" || echo "위반: 기존 행 변경 [$l]"
  done
  new=$(printf '%s\n' "$data" | grep -vxF -f <(printf '%s\n' "$base") \
    | awk -F'|' '{ c = $2; gsub(/^[ \t]+|[ \t]+$/, "", c); print c }' | sort | tr '\n' '|')
  [ "$new" = "$(printf '%s\n' '의존성·모듈 구조 확인' '수정 후 import 정리' '사용자가 가리킨 파일 확인' | sort | tr '\n' '|')" ] \
    || echo "위반: 새 행 구성 [$new]"
  ```

  - 설계 주의: 기준 커밋은 이 브랜치의 분기점(`main`, PR #143 머지)이다. 작업 트리의 옛 내용과 비교하면 구현 뒤에는 기준이 사라진다.
  </details>
- [ ] [D] 새 3행의 먼저 쓸 도구 칸에 `get_project_dependencies`·`get_project_modules`, `optimize_imports`, `get_all_open_file_paths`가 있고, 사용자가 가리킨 파일 확인 행에 IDE에 열린 파일을 가리킬 때 쓴다는 조건이 있다 (AC9)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  tbl=$(awk '/^### 탐색·수정[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit } f && /^\|/' "$T")
  chk() { printf '%s\n' "$tbl" | awk -F'|' -v k="$1" -v n="$2" -v s="$3" '
    { c = $2; gsub(/^[ \t]+|[ \t]+$/, "", c) } c == k { r++; if (!index($n, s)) b = 1 }
    END { if (r != 1 || b) print "위반: [" k "] 행 " n - 1 "번째 칸에 [" s "] 없음" }'; }
  chk '의존성·모듈 구조 확인' 3 get_project_dependencies
  chk '의존성·모듈 구조 확인' 3 get_project_modules
  chk '수정 후 import 정리' 3 optimize_imports
  chk '사용자가 가리킨 파일 확인' 3 get_all_open_file_paths
  chk '사용자가 가리킨 파일 확인' 4 '열린 파일'
  ```

  </details>
- [ ] [D] 수정 후 import 정리 행에 수정한 파일에만 쓰고 손대지 않은 import의 재정렬이 섞이면 되돌린다는 조건이 있다 (AC10)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  awk '/^### 탐색·수정[[:space:]]*$/ { f = 1; next } f && /^(## |### )/ { exit }
    f && /^\|/ { c = $0; split(c, a, "|"); k = a[2]; gsub(/^[ \t]+|[ \t]+$/, "", k)
      if (k == "수정 후 import 정리") { r++; if (index(c, "수정한 파일에만") && index(c, "재정렬") && index(c, "되돌린다")) m++ } }
    END { if (r != 1 || m != 1) print "위반: import 정리 조건" }' "$T"
  ```

  </details>

### R9: 사용자가 요청할 때만 쓰는 도구

- [ ] [D] `## 사용자가 요청할 때만 쓰는 도구` 절이 1개 있고, 그 절의 목록 항목이 `reformat_file`·`xdebug_set_variable`·`open_file_in_editor`·changelist 도구와 그 4개 이름·`convert_java_to_kotlin`을 콜론 앞에 두고 콜론 뒤에 이유를 적는다 (AC11)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  [ "$(grep -c '^## 사용자가 요청할 때만 쓰는 도구[[:space:]]*$' "$T")" -eq 1 ] || echo '위반: 절 수'
  sec=$(awk '/^## 사용자가 요청할 때만 쓰는 도구[[:space:]]*$/ { f = 1; next } f && /^## / { exit } f' "$T")
  for k in '`reformat_file`' '`xdebug_set_variable`' '`open_file_in_editor`' 'changelist 도구' '`convert_java_to_kotlin`' \
           '`create_changelist`' '`delete_changelist`' '`move_changes_to_changelist`' '`set_active_changelist`'; do
    printf '%s\n' "$sec" | awk -v k="$k" '/^- / { i = index($0, ": "); if (i && index(substr($0, 1, i), k) && substr($0, i + 2) != "") n++ }
      END { if (!n) print "위반: [" k "] 항목 또는 이유 없음" }'
  done
  ```

  </details>

### R10: grep 재확인 예시

- [ ] [D] `## 기존 도구로 전환하는 조건`의 삭제·이름 변경 전 grep 재확인 항목에 "XML 매퍼·뷰 템플릿"이 있다 (AC12)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  awk '/^## 기존 도구로 전환하는 조건[[:space:]]*$/ { f = 1; next } f && /^## / { exit }
    f && /^- 삭제나 이름 변경 전에는/ { n++; if (index($0, "XML 매퍼·뷰 템플릿")) m++ }
    END { if (n != 1 || m != 1) print "위반: grep 재확인 예시" }' "$T"
  ```

  </details>

### R11: 도구 한 번에 불러오기

- [ ] [D] `## 호출 방법` 절의 목록 항목에 작업을 시작할 때 그 행의 도구를 한 번에 불러온다는 문장이 있다 (AC13)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  awk '/^## 호출 방법[[:space:]]*$/ { f = 1; next } f && /^## / { exit }
    f && /^ *- / && index($0, "작업을 시작할 때") && index($0, "한 번에 불러온다") { n++ }
    END { if (!n) print "위반: 한 번에 불러오기 문장" }' "$T"
  ```

  </details>

### R12: 버전과 update 덮어쓰기

- [ ] [D] `ide-tools.md` 2행 버전 주석이 `1.0.0`보다 높다 (AC14)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/ide-tools.md
  v=$(sed -n '2s/^<!-- 버전: \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\) -->$/\1/p' "$T")
  { [ -n "$v" ] && [ "$v" != 1.0.0 ] && [ "$(printf '%s\n' 1.0.0 "$v" | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)" = "$v" ]; } \
    || echo "위반: 버전 [$v]"
  ```

  </details>
- [ ] [D] update-1이 dev에서 구버전 `ide-tools.md`를 템플릿 최신본으로 덮어쓰는 기존 회귀 케이스가 통과한다 (AC14) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  ai-workspace/tests/run-tests.sh 2>&1 \
    | grep -qE '^ok +- ide-tools update-1 복사\(dev 신규·구버전 덮어쓰기·doc 미복사\) 통과$' \
    || echo '위반: update-1 덮어쓰기 케이스'
  ```

  </details>

### R13: 도구별 결정 목록

- [ ] [D] 결정 목록 표의 도구 행이 101개이고 이름이 겹치지 않으며, 결정 칸은 `표에 둠`·`기존 도구`·`쓰지 않음`·`보류` 중 하나, 이유 칸은 비어 있지 않다 (AC15)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  D=.ai/40_domain/specs/ide-tools-decisions.md
  [ -f "$D" ] || echo '위반: 결정 목록 없음'
  awk -F'|' '
    function t(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    /^\| `[a-z0-9_]+` \|/ { n++; k = t($2); if (seen[k]++) print "위반: 중복 " k
      d = t($3); if (d != "표에 둠" && d != "기존 도구" && d != "쓰지 않음" && d != "보류") print "위반: 결정 값 " k " [" d "]"
      if (NF != 5 || t($4) == "") print "위반: 이유 칸 " k }
    END { if (n != 101) print "위반: 도구 행 " n + 0 "개" }' "$D" 2>/dev/null
  ```

  - 설계 주의: 도구 행은 첫 칸이 백틱으로 감싼 도구 이름 하나인 행이다. 표를 묶음별로 나눠도 같은 규칙으로 센다.
  </details>
- [ ] [D] 결정 목록의 도구 집합이 도구 이름 목록 사본(2026-11-22, 101개)과 같아 목록 대조 헬퍼가 무출력·종료 코드 0으로 끝난다 (AC15)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  H=ai-workspace/tests/check-ide-tool-list.sh
  L=ai-workspace/tests/fixtures/ide-tool-list/intellij-mcp-tools.txt
  [ "$(grep -c . "$L" 2>/dev/null)" = 101 ] || echo '위반: 목록 사본이 101줄이 아님'
  out=$("$H" "$L" 2>&1); rc=$?
  { [ "$rc" -eq 0 ] && [ -z "$out" ]; } || echo "위반: 사본 대조 rc=$rc [$out]"
  ```

  </details>
- [ ] [D] 결정 목록 머리(첫 표 앞)에 확인일·IntelliJ 버전·도구 수 필드가 있고, 도구 수 값이 표의 도구 행 수와 같다 (AC16)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  D=.ai/40_domain/specs/ide-tools-decisions.md
  h=$(awk '/^\|/ { exit } { print }' "$D" 2>/dev/null)
  printf '%s\n' "$h" | grep -qE '^- \*\*확인일\*\*: [0-9]{4}-[0-9]{2}-[0-9]{2}$' || echo '위반: 확인일'
  printf '%s\n' "$h" | grep -qE '^- \*\*IntelliJ 버전\*\*: [^[:space:]]' || echo '위반: IntelliJ 버전'
  cnt=$(printf '%s\n' "$h" | sed -n 's/^- \*\*도구 수\*\*: \([0-9][0-9]*\)$/\1/p')
  rows=$(grep -cE '^\| `[a-z0-9_]+` \|' "$D" 2>/dev/null)
  { [ -n "$cnt" ] && [ "$cnt" = "$rows" ]; } || echo "위반: 도구 수 [$cnt], 도구 행 [$rows]"
  ```

  </details>
- [ ] [D] 결정 목록 머리에 도구 이름 목록을 받는 방법으로 Claude Code(`mcp__<등록 이름>__` 접두어 제거)와 Codex(`ALL_TOOLS`)가 있다 (AC16)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  D=.ai/40_domain/specs/ide-tools-decisions.md
  h=$(awk '/^\|/ { exit } { print }' "$D" 2>/dev/null)
  for k in 'mcp__<등록 이름>__' 'ALL_TOOLS'; do printf '%s\n' "$h" | grep -qF -- "$k" || echo "위반: 받는 방법에 [$k] 없음"; done
  ```

  </details>
- [ ] [D] `.ai/40_domain/index.md` 파일 목록 표에 `specs/ide-tools-decisions.md` 행이 1개 있다 (AC16)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  [ "$(grep -c '^| `specs/ide-tools-decisions.md` |' .ai/40_domain/index.md)" -eq 1 ] || echo '위반: 40_domain index 행'
  ```

  </details>
- [ ] [QD] 도구마다 결정과 이유가 이슈 본문의 포함·제외 결정, `ide-tools.md`의 표·목록과 맞는다 (AC15)  (검증: 교차모델 audit이 이슈 본문·`ide-tools.md`와 대조 채점)  ← 강등 사유: 이유 한 줄이 타당한지는 의미 판단이다

### R14: 내부 일치 검사

- [ ] [D] `run-tests.sh`가 템플릿 `ide-tools.md`와 결정 목록의 일치를 통과로 판정하고, 결정 목록에 없는 이름 추가·`표에 둠` 도구 삭제·`보류` 도구 추가·`기존 도구` 도구 추가·`표에 둠` 도구를 `쓰지 않음`으로 변경·`쓰지 않음` 도구를 요청 전용 절 밖에 추가·`표에 둠` 도구를 요청 전용 절에 추가·결정 목록 없음·보류 행을 앞에 둔 결정 중복·보류 행을 뒤에 둔 결정 중복의 열 변형을 각각 격추한다 (AC17)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(ai-workspace/tests/run-tests.sh 2>&1) || echo '위반: 러너 실패'
  printf '%s\n' "$out" | grep -qE '^ok +- ide-tools 결정 목록 일치 통과$' || echo '위반: 통과 케이스'
  for k in '결정 목록에 없는 이름 추가' '표에 둠 도구 삭제' '보류 도구 추가' '기존 도구 도구 추가' \
           '표에 둠 도구를 쓰지 않음으로 변경' '쓰지 않음 도구를 요청 전용 절 밖에 추가' \
           '표에 둠 도구를 요청 전용 절에 추가' '결정 목록 없음' \
           '보류 행을 앞에 둔 결정 중복' '보류 행을 뒤에 둔 결정 중복'; do
    printf '%s\n' "$out" | grep -qE "^ok +- ide-tools 결정 목록 일치: ${k} 격추\$" || echo "위반: [${k}] 격추 케이스"
  done
  ```

  - 판정 규칙(검사가 구현할 내용): `ide-tools.md`의 도구 이름은 백틱 코드 스팬 내용이 `^[a-z][a-z0-9]*(_[a-z0-9]+)+(\(.*\))?$`에 맞는 것의 `(` 앞부분이다. 아래 다섯 조건을 모두 만족해야 통과다.
    0. 결정 목록에 같은 이름의 행이 두 개 이상 없다. 행이 겹치면 마지막 행의 결정만 남아 모순이 통과한다(2026-11-23 최종 감사 F-1).
    1. 이름은 모두 결정 목록에 있다.
    2. `## 사용자가 요청할 때만 쓰는 도구` 절(다음 `## ` 전까지) 안의 이름은 결정이 `쓰지 않음`이다.
    3. 그 절 밖의 이름은 결정이 `표에 둠`이다.
    4. 결정이 `표에 둠`인 도구는 모두 그 절 밖에 이름이 있다.
  - 결정 목록 파일을 읽지 못하면 건너뛰지 않고 그 경로를 위반으로 보고한다. 결정 목록은 일치 검사의 입력이라, 없을 때 건너뛰면 파일이 빠져도 러너가 통과해 일치 검사가 사라진다.
  - 변형과 조건: 이름 추가는 1, 절 안의 `표에 둠` 도구 추가는 2, `보류`·`기존 도구` 도구 추가와 `쓰지 않음`으로 변경과 `쓰지 않음` 도구의 절 밖 추가는 3, `표에 둠` 도구 삭제는 4를 깬다. 결정 목록 없음은 입력 읽기를, 결정 중복 두 변형은 0을 깬다.
  - 설계 주의: 케이스 설명에는 `통과`·`격추` 중 한 낱말만 쓴다. 러너만 실행하면 케이스를 넣기 전에도 통과하므로 케이스 라벨을 하나씩 찾는다.
  </details>

### R15: 목록 대조 헬퍼

- [ ] [D] 목록 대조 헬퍼가 배포 제외 경로 `ai-workspace/tests/` 아래에 실행 파일로 있다 (AC18)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  [ -x ai-workspace/tests/check-ide-tool-list.sh ] || echo '위반: 헬퍼 없음 또는 실행 권한 없음'
  ```

  </details>
- [ ] [D] 목록 파일이 결정 목록과 같으면 무출력·종료 코드 0이고, 목록에만 있는 도구는 `새 도구: <이름>`, 결정 목록에만 있는 도구는 `사라진 도구: <이름>`으로 한 줄씩 출력하며 종료 코드 1이다 (AC18)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  H=ai-workspace/tests/check-ide-tool-list.sh
  D=.ai/40_domain/specs/ide-tools-decisions.md
  w=$(mktemp -d)
  awk -F'|' '/^\| `[a-z0-9_]+` \|/ { c = $2; gsub(/[ `]/, "", c); print c }' "$D" > "$w/same.txt"
  out=$("$H" "$w/same.txt"); rc=$?
  { [ "$rc" -eq 0 ] && [ -z "$out" ] && [ -s "$w/same.txt" ]; } || echo "위반: 같은 목록 rc=$rc [$out]"
  gone=$(sed -n 1p "$w/same.txt")
  { sed 1d "$w/same.txt"; echo zz_new_tool; } > "$w/diff.txt"
  out=$("$H" "$w/diff.txt"); rc=$?
  want=$(printf '%s\n' "사라진 도구: ${gone}" '새 도구: zz_new_tool' | sort)
  { [ "$rc" -eq 1 ] && [ "$(printf '%s\n' "$out" | sort)" = "$want" ]; } || echo "위반: 차이 목록 rc=$rc [$out]"
  rm -f "$w/same.txt" "$w/diff.txt" && rmdir "$w"
  ```

  </details>

### R16: 안내도 템플릿 행

- [ ] [D] dev `AI-CONTEXT.md` 템플릿의 `ide-tools.md` 행이 1개이고, 사용 시점 칸이 `코드 탐색·수정·실행 전`이며 설명 칸에 테스트·커버리지·서버·디버깅이 들어 있다 (AC19)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  A=ai-workspace/templates/dev/.ai/AI-CONTEXT.md
  row=$(grep -E '^\| `\.ai/10_rules/ide-tools\.md` +\|' "$A")
  [ "$(printf '%s\n' "$row" | grep -c .)" -eq 1 ] || echo '위반: 행 수'
  use=$(printf '%s\n' "$row" | awk -F'|' '{ s = $4; gsub(/^[ \t]+|[ \t]+$/, "", s); print s }')
  [ "$use" = '코드 탐색·수정·실행 전' ] || echo "위반: 사용 시점 [$use]"
  desc=$(printf '%s\n' "$row" | awk -F'|' '{ print $3 }')
  for k in 테스트 커버리지 서버 디버깅; do printf '%s\n' "$desc" | grep -qF -- "$k" || echo "위반: 설명에 [$k] 없음"; done
  ```

  </details>
- [ ] [QD] 설명 칸만 읽어도 어떤 실행 작업에 IDE 도구를 먼저 쓰는지, 표에 없는 작업과 `[D]`·회귀 판정은 어떻게 하는지 알 수 있다 (AC19)  (검증: 교차모델 audit 채점)  ← 강등 사유: 설명만으로 판단할 수 있는지는 의미 판단이다

### R17: update-4 표준 행 문구

- [ ] [D] `ai-workspace/SKILL.md` update-4 검사 표의 `ide-tools.md` 행 조치 칸에 적힌 설명·사용 시점 문구가 템플릿 행의 두 칸과 같고, 사용 시점은 `코드 탐색·수정·실행 전`이다 (AC20)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  A=ai-workspace/templates/dev/.ai/AI-CONTEXT.md
  want=$(grep -E '^\| `\.ai/10_rules/ide-tools\.md` +\|' "$A" \
    | awk -F'|' 'function t(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s } { print t($3) "|" t($4) }')
  got=$(grep -E '^\| `## 프로젝트 규칙` 표의 `ide-tools\.md` 행 \|' ai-workspace/SKILL.md \
    | sed -n 's/.*설명 "\([^"]*\)", 사용 시점 "\([^"]*\)".*/\1|\2/p')
  { [ -n "$want" ] && [ "$got" = "$want" ]; } || echo '위반: SKILL.md 표준 행 문구 불일치'
  [ "${want##*|}" = '코드 탐색·수정·실행 전' ] || echo '위반: 템플릿 사용 시점'
  ```

  - 설계 주의: 설명 문구에 큰따옴표와 `|`를 쓰지 않는다. SKILL.md 조치 칸은 문구를 큰따옴표로 감싸 적는다.
  </details>
- [ ] [D] update-4 fixture 디렉토리에서 `ide-tools.md` 행을 가진 파일이 8개이고, 각 행의 앞 3칸이 템플릿 행의 3칸과 같다 (AC20)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  A=ai-workspace/templates/dev/.ai/AI-CONTEXT.md
  F=ai-workspace/tests/fixtures/update4-idempotent
  re='^\| `\.ai/10_rules/ide-tools\.md` +\|'
  want=$(grep -E "$re" "$A" | awk -F'|' 'function t(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s } { print t($2) "|" t($3) "|" t($4) }')
  files=$(grep -lE "$re" "$F"/*.md)
  [ "$(printf '%s\n' "$files" | grep -c .)" -eq 8 ] || echo '위반: ide-tools 행이 있는 fixture 수'
  for f in $files; do
    grep -E "$re" "$f" | awk -F'|' -v w="$want" -v f="$f" '
      function t(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s } { if (t($2) "|" t($3) "|" t($4) != w) print "위반: " f }'
  done
  [ "${want##*|}" = '코드 탐색·수정·실행 전' ] || echo '위반: 템플릿 사용 시점'
  ```

  - 설계 주의: 사용자 확장 열(`| - |`)이 붙은 fixture 2개는 앞 3칸만 비교한다.
  </details>

### R18: context-loading 라우팅

- [ ] [D] shared `context-loading.md`의 `## 테스트 작성·실행 시` 목록이 `testing-principles.md`·`testing-principles-local.md`·`ide-tools.md` 세 항목이고 이 순서다 (AC21)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=ai-workspace/templates/shared/.ai/10_rules/context-loading.md
  got=$(awk '/^## 테스트 작성·실행 시[[:space:]]*$/ { f = 1; next } f && /^(## |---)/ { exit } f && /^- / { sub(/ —.*/, ""); print }' "$C" | tr '\n' '|')
  [ "$got" = '- `.ai/10_rules/testing-principles.md`|- `.ai/10_rules/testing-principles-local.md`|- `.ai/10_rules/ide-tools.md`|' ] \
    || echo "위반: 테스트 절 목록 [$got]"
  ```

  </details>
- [ ] [D] `## 코드 수정·리뷰·분석 시` 2번 `ide-tools.md` 항목 설명에 "실행"이 있고, `ide-tools.md` 경로는 파일 전체에서 2곳(코드 절·테스트 절)에만 있다 (AC21)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=ai-workspace/templates/shared/.ai/10_rules/context-loading.md
  awk '/^## 코드 수정·리뷰·분석 시[[:space:]]*$/ { f = 1; next } f && /^(## |---)/ { exit }
    f && /^2\. `\.ai\/10_rules\/ide-tools\.md`/ { n++; if (index($0, "실행")) m++ }
    END { if (n != 1 || m != 1) print "위반: 코드 절 2번 설명" }' "$C"
  [ "$(grep -cF '.ai/10_rules/ide-tools.md' "$C")" -eq 2 ] || echo '위반: ide-tools.md 경로 개수'
  ```

  </details>
- [ ] [D] `run-tests.sh` 라우팅 검사가 템플릿을 통과시키고, 코드 절 항목 삭제·테스트 절 항목 삭제·다른 절로 이동·다른 절에 중복의 네 변형을 각각 격추한다 (AC22)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(ai-workspace/tests/run-tests.sh 2>&1) || echo '위반: 러너 실패'
  printf '%s\n' "$out" | grep -qE '^ok +- context-loading 제약 문장·테스트 라우팅·ide-tools 라우팅·저장소 사본 일치 통과$' || echo '위반: 통과 케이스'
  for k in '코드 절 항목 삭제' '테스트 절 항목 삭제' '다른 절로 이동' '다른 절에 중복'; do
    printf '%s\n' "$out" | grep -qE "^ok +- context-loading ide-tools 라우팅 ${k} 격추\$" || echo "위반: [${k}] 격추 케이스"
  done
  ```

  </details>

### R19: 로컬 서버 기재 자리

- [ ] [D] dev `testing-principles-local.md` 템플릿에 `## 로컬 서버` 절이 1개 있고, 그 안에 `- **Run Configuration 이름**:`·`- **IDE 미연결 시 실행 명령**:` 필드 행이 하나씩 있다 (AC23)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  P=ai-workspace/templates/dev/.ai/10_rules/testing-principles-local.md
  [ "$(grep -c '^## 로컬 서버[[:space:]]*$' "$P")" -eq 1 ] || echo '위반: 로컬 서버 절 수'
  awk '/^## 로컬 서버[[:space:]]*$/ { f = 1; next } f && /^## / { exit }
    f && /^- \*\*Run Configuration 이름\*\*:/ { a++ } f && /^- \*\*IDE 미연결 시 실행 명령\*\*:/ { b++ }
    END { if (a != 1 || b != 1) print "위반: 로컬 서버 필드 행" }' "$P"
  ```

  </details>

### R20: 저장소 사본

- [ ] [D] 이 저장소 `.ai/10_rules/context-loading.md`·`.ai/10_rules/ide-tools.md`가 각 템플릿과 바이트 단위로 같고, 두 사본이 새 본문(테스트 절의 `ide-tools.md`, `1.0.0`이 아닌 버전)이다 (AC24)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  cmp -s .ai/10_rules/context-loading.md ai-workspace/templates/shared/.ai/10_rules/context-loading.md || echo '위반: context-loading 사본'
  cmp -s .ai/10_rules/ide-tools.md ai-workspace/templates/dev/.ai/10_rules/ide-tools.md || echo '위반: ide-tools 사본'
  awk '/^## 테스트 작성·실행 시[[:space:]]*$/ { f = 1; next } f && /^(## |---)/ { exit } f && /^- `\.ai\/10_rules\/ide-tools\.md`/ { n++ }
    END { if (n != 1) print "위반: context-loading 사본 테스트 절" }' .ai/10_rules/context-loading.md
  sed -n 2p .ai/10_rules/ide-tools.md | grep -qvxF '<!-- 버전: 1.0.0 -->' || echo '위반: ide-tools 사본 버전'
  ```

  </details>
- [ ] [D] 이 저장소 `.ai/AI-CONTEXT.md`의 `ide-tools.md` 행 3칸이 dev 템플릿 행 3칸과 같고, 사용 시점은 `코드 탐색·수정·실행 전`이다 (AC24)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  re='^\| `\.ai/10_rules/ide-tools\.md` +\|'
  cells() { grep -E "$re" "$1" | awk -F'|' 'function t(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s } { print t($2) "|" t($3) "|" t($4) }'; }
  want=$(cells ai-workspace/templates/dev/.ai/AI-CONTEXT.md)
  { [ -n "$want" ] && [ "$(cells .ai/AI-CONTEXT.md)" = "$want" ]; } || echo '위반: 저장소 안내도 행 불일치'
  [ "${want##*|}" = '코드 탐색·수정·실행 전' ] || echo '위반: 템플릿 사용 시점'
  ```

  </details>

### R21: ADR

- [ ] [D] 새 ADR `.ai/50_adr/active/0030-*.md`가 1개 있고 상태 줄이 `유효`이며, `## 결정`에 결정 목록 경로와 IntelliJ 업데이트를 다시 비교하는 계기로 적는다 (AC25)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  n=$(ls .ai/50_adr/active/0030-*.md 2>/dev/null | grep -c .)
  [ "$n" -eq 1 ] || echo "위반: 새 ADR 수 $n"
  F=$(ls .ai/50_adr/active/0030-*.md 2>/dev/null | head -1); F=${F:-/nonexistent}
  grep -qxF -- '- **상태**: 유효' "$F" 2>/dev/null || echo '위반: 상태 줄'
  dec=$(awk '/^## 결정[[:space:]]*$/ { f = 1; next } f && /^## / { exit } f' "$F" 2>/dev/null)
  printf '%s\n' "$dec" | grep -qF '40_domain/specs/ide-tools-decisions.md' || echo '위반: 결정 목록 경로'
  printf '%s\n' "$dec" | grep -q 'IntelliJ.*업데이트' || echo '위반: 다시 비교하는 계기'
  ```

  </details>
- [ ] [D] `.ai/50_adr/index.md` 파일 목록에 새 ADR 행이 1개 있다 (AC25)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  [ "$(grep -c '^| `active/0030-' .ai/50_adr/index.md)" -eq 1 ] || echo '위반: ADR index 행'
  ```

  </details>
- [ ] [D] ADR 0029 `## 근거`에 `#144` 일부 변경 이력 줄이 있고, `## 결정`의 사용 시점이 `코드 탐색·수정·실행 전`이며 context-loading 테스트 절 라우팅이 들어 있다 (AC25)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  Z=.ai/50_adr/active/0029-ide-tools-rule-dev-profile-distribution.md
  awk '/^## 근거[[:space:]]*$/ { f = 1; next } f && /^## / { exit } f && index($0, "#144") && index($0, "일부 변경") { n++ }
    END { if (!n) print "위반: 0029 근거의 일부 변경 이력" }' "$Z"
  dec=$(awk '/^## 결정[[:space:]]*$/ { f = 1; next } f && /^## / { exit } f' "$Z")
  printf '%s\n' "$dec" | grep -qF '코드 탐색·수정·실행 전' || echo '위반: 0029 사용 시점'
  printf '%s\n' "$dec" | grep -qF '테스트 작성·실행 시' || echo '위반: 0029 테스트 절 라우팅'
  ```

  </details>
- [ ] [QD] 새 ADR이 실행 표·결정 목록 위치·다시 비교하는 계기·러너 판정 분리를 결정과 근거로 담고, ADR 0029와 겹치거나 어긋나지 않는다 (AC25)  (검증: 교차모델 audit 채점)  ← 강등 사유: 두 ADR 사이의 중복·모순은 의미 판단이다

### R22: K-0028 재검토 이력

- [ ] [D] K-0028 `## 재검토 이력` 표에 `#144` 행이 1개 있고, 그 행의 일자·계기·판단·결과 4칸이 모두 비어 있지 않다 (AC26)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  K=$(ls .ai/70_ledger/*/K-0028-*.md 2>/dev/null | head -1); K=${K:-/nonexistent}
  awk -F'|' 'function t(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    /^## 재검토 이력[[:space:]]*$/ { f = 1; next } f && /^## / { exit }
    f && /^\| 20[0-9][0-9]-/ && index($0, "#144") { n++; if (NF != 6 || t($3) == "" || t($4) == "" || t($5) == "") b++ }
    END { if (n != 1 || b) print "위반: #144 재검토 이력 행 " n + 0 "개, 빈 칸이 있는 행 " b + 0 "개" }' "$K"
  ```

  - 설계 주의: 재검토 결과(계속 수용 등)를 미리 고정하지 않으려고 `active/`·`archive/`를 함께 찾고, 판단·결과는 값을 보지 않고 칸이 비었는지만 본다. 칸을 `|`로 나누므로 이력 행의 칸 안에 `|`를 쓰지 않는다.
  </details>

### R23: 명세와 안내도 동기화

- [ ] [D] `ai-workspace.md` 명세에서 context-loading 테스트 작성·실행 절을 설명하는 괄호 안에 `ide-tools.md`가 있다 (AC29)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -o '테스트 작성·실행 절([^)]*)' .ai/40_domain/specs/ai-workspace.md | grep -qF 'ide-tools.md' || echo '위반: 명세의 테스트 절 라우팅'
  ```

  - 설계 주의: 같은 줄의 코드 절 설명에 이미 `ide-tools.md`가 있어, 줄 단위로 찾으면 구현 전에도 통과한다. 괄호 안만 본다.
  </details>
- [ ] [D] 이 저장소 안내도 디렉토리 구조의 `ai-workspace/` 아래 `tests/` 줄에 도구 목록 대조 헬퍼가 적혀 있다 (AC30)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^├── ai-workspace\// { f = 1; next } f && /^├── / { exit } f && /tests\// { print }' .ai/AI-CONTEXT.md \
    | grep -qF '도구 목록 대조' || echo '위반: 안내도 tests 설명'
  ```

  </details>
- [ ] [QD] `ai-workspace.md` 명세가 바뀐 `ide-tools.md` 범위, context-loading 라우팅, update-4 표준 행 문구와 어긋나지 않는다 (AC29)  (검증: 교차모델 audit 채점)  ← 강등 사유: 명세 서술과 동작이 맞는지는 의미 판단이다

### 공통

- [ ] [D] `ai-workspace/tests/run-tests.sh`가 종료 코드 0으로 끝난다 (AC27) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  ai-workspace/tests/run-tests.sh >/dev/null 2>&1 || echo '위반: ai-workspace 테스트 실패'
  ```

  </details>
- [ ] [D] repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do bash "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>

---

## 전제 (Assumptions)

- **기준 커밋**: 기존 6행 비교와 현재 문구 대조는 이 브랜치의 분기점 `bc26506`(`main`, PR #143 머지)을 기준으로 한다.
- **검증 셸**: 이 저장소 `testing-principles-local.md`는 테스트 층 표와 실행 셸이 비어 있어, 검증 명령은 repo 루트에서 bash로 실행한다(대화 셸은 zsh).
  - 명령과 헬퍼의 변수 이름에 `path`를 쓰지 않고, 변수 바로 뒤에 한글이 오면 `${VAR}`로 쓴다.
  - 러너와 헬퍼는 macOS 기본 bash 3.2에서 동작해야 한다. `$( … )` 안의 `case` 패턴은 `(패턴)` 형태로 쓴다.
- **고정 문구**: spec `[D]`가 기대하는 제목·머리행·필드 이름·러너 케이스 라벨(`### 탐색·수정`, `### 실행`, 실행 표 머리행, `## 사용자가 요청할 때만 쓰는 도구`, `## 로컬 서버`와 두 필드, `ide-tools 결정 목록 일치`·`context-loading ide-tools 라우팅 …` 라벨, 실행 표 뒷정리 칸의 `그대로 둔다`·`사용자에게 알리고 종료를 요청한다`)은 spec 작성 때 정한 값이다. 바꾸려면 검증 명령도 함께 고친다.
- **실행 소절 문장 검증의 범위**: `ide-tools.md` 실행 표와 표 아래 목록을 보는 `[D]`는 spec 하위 목록의 도구 이름과 조건 문구(시점·대상·조건절)가 같은 행이나 줄에 있는지까지 본다. 조건·순서가 뜻대로 적혔는지는 Task N 최종 감사가 요구사항(R2~R6) 대조로 판정한다. 낱말 검사로는 뜻을 끝까지 판정할 수 없어서다(2026-11-22 계획 감사 F-3·F-4).
- **표 셀**: 검증 명령이 `|`로 칸을 나누므로 `ide-tools.md` 표 셀과 안내도 행 설명에 `|`를 쓰지 않는다. 안내도 행 설명에는 SKILL.md가 문구를 감싸는 큰따옴표도 쓰지 않는다.
- **결정 값의 뜻**: 결정 목록의 네 값은 아래 뜻으로 쓴다. 이슈 본문은 값 이름만 정했고, 뜻은 내부 일치 검사(R14)를 정하려고 spec 작성 때 정했다.
  - `표에 둠`: `ide-tools.md`에 이름을 적고 에이전트가 쓰는 도구. 표 행과 표 아래 목록(`build_project` 등)을 포함하며, `## 사용자가 요청할 때만 쓰는 도구` 절 밖에 이름을 적는다.
  - `쓰지 않음`: 에이전트가 스스로 쓰지 않는 도구. 사용자가 요청할 때만 쓰는 도구도 여기에 넣는다. 이 값의 도구는 `ide-tools.md`의 `## 사용자가 요청할 때만 쓰는 도구` 절에만 이름을 적을 수 있다.
  - `기존 도구`: grep·파일 읽기·편집 도구·셸 명령 같은 기존 도구가 맡는 도구.
  - `보류`: 써 본 경험이나 사례가 생긴 뒤 다시 판단하는 도구.
- **헬퍼와 목록 사본 위치**: 헬퍼는 `ai-workspace/tests/check-ide-tool-list.sh`, 도구 이름 목록 사본은 `ai-workspace/tests/fixtures/ide-tool-list/intellij-mcp-tools.txt`다. `tests/`는 install-skills 배포 제외 경로라 "배포하지 않는 위치"를 만족한다([`ai-tool-skill-paths.md`](../../../30_contract/ai-tool-skill-paths.md)).
  - 사본은 2026-11-22 이 세션(Claude Code, 서버 등록 이름 `idea`)의 지연 도구 목록 101개에서 `mcp__idea__` 접두어를 지워 이름순으로 한 줄에 하나씩 적는다.
  - 대안으로 저장소 루트에 `scripts/`를 새로 두는 안은 디렉토리를 늘리고, 목록을 spec 검증 명령 안에 적는 안은 spec이 길어져 쓰지 않았다.
- **헬퍼 읽기 실패**: 인자가 틀리거나 목록 파일을 읽지 못할 때의 종료 코드 2는 Task 3의 구현 설계와 구현 테스트(`목록 읽기 실패 격추`)가 맡고 spec 완료의 정의에 두지 않는다. AC18은 차이 유무의 결과(0·1)만 정한다(2026-11-22 계획 감사 F-7).
- **ADR 번호**: 새 ADR은 0030이다(`active/` 0001~0029, `superseded/` 없음).
- **코드맵**: init·update 호출 흐름의 본문은 바뀌지 않는다. `60_codebase` 동기화 표지는 git-pr 문서 동기화 점검이 판단하며 이 이슈의 요구사항에 넣지 않았다.
- **fixture 문구 대조**: `run-tests.sh`의 update-4 fixture 검사(`assert_fixture`)는 입력 파일을 `check-context.sh`로 판정할 뿐 기대 파일의 행 문구를 대조하지 않는다. `check-context.sh`도 `파일` 칸만 비교한다. fixture와 SKILL.md의 행 문구 일치는 spec R17의 `[D]`만 판정한다.
- **저장소 local 파일**: 이 저장소 `.ai/10_rules/testing-principles-local.md`는 사용자가 관리하는 파일이라 R19의 템플릿 변경을 옮기지 않는다(R20 대상 아님).
- **K-0028 재검토 결과**: Task 5에서 판단한다. 소비 스킬 본문 참조는 이번 범위가 아니어서 계속 수용이 예상되지만, 결과를 미리 고정하지 않는다.
- **이슈 `검토 필요` 1 결정**: 테스트·커버리지 실행의 흔적(임시 Run Configuration, 에디터의 커버리지 표시)은 그대로 둔다. 2026-11-22 Task 1에서 사용자가 실제 호출 없이 도구 정의와 공식 문서(IntelliJ IDEA 2026.3 MCP Server·Run/Debug Configuration)로 결정했다.
  - 근거: IntelliJ는 임시 구성을 기본 5개까지 두고 새 구성이 생기면 오래된 것부터 지운다(`Settings | Advanced Settings | Run/Debug | Temporary configurations limit`). Run Configuration을 지우는 도구와 커버리지 표시를 끄는 도구는 IntelliJ MCP 도구 101개에 없다.
  - 버린 대안: 사용자에게 알린다(AC에 없는 결과를 더한다), 지우는 방법을 찾는다(`.idea/workspace.xml`을 IDE가 열린 채로 고쳐야 해 덮어쓰기·설정 손상 위험이 있다).
- **이슈 `검토 필요` 2 결정**: IDE로 띄운 프로세스(로컬 서버, `timeout` 안에 끝나지 않은 테스트)는 계속 돌고 있다고 사용자에게 알리고 종료를 요청한다. 2026-11-22 Task 1에서 사용자가 결정했고, AC에 없는 결과라 변경 통제(확장)에서 범위 확장을 골라 이슈 본문에 AC31을 더했다.
  - 근거: 일반 실행 프로세스를 끄는 MCP 도구가 없고, `execute_run_configuration`의 결과에 프로세스 ID가 없다. `timeout`이 지나면 프로세스는 백그라운드에서 계속 돈다.
  - 버린 대안: 디버그 세션으로 띄워 `xdebug_control_session(action=STOP)`으로 끈다(R2·R4의 실행 도구와 고정 문구를 바꿔야 하고, 디버깅은 사용자가 요청할 때만 한다는 R5와 충돌하며, `STOP`이 디버그 대상 프로세스까지 끝내는지는 도구 정의와 공식 문서로 확인되지 않는다), 띄운 채 둔다(`timeout`을 넘긴 테스트가 알림 없이 계속 돈다).

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/50_adr/active/0029-ide-tools-rule-dev-profile-distribution.md` | IDE 도구 우선 규칙 배포 결정. 적용 범위·사용 시점·context-loading 라우팅이 바뀌는 일부 변경 대상 |
| `.ai/50_adr/active/0023-testing-principles-pair-and-consumer-skill-references.md` | 테스트 실행 원칙 쌍과 local 파일 역할, context-loading 테스트 절 라우팅. local 템플릿 섹션 구성과 테스트 절 라우팅이 바뀌는 일부 변경 대상 |
| `.ai/50_adr/active/0028-ai-workspace-owned-sections-and-profile-row.md` | update 소유 구분. 배포된 안내도의 행 설명이 보존되는 근거 |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 헬퍼·테스트를 `<skill>/tests/`에 두고 배포에서 빼는 규칙 |
| `.ai/30_contract/ai-tool-skill-paths.md` | 배포 제외 경로(목록 대조 헬퍼 위치 판단) |
| `.ai/40_domain/specs/ai-workspace.md` | ai-workspace 명세. context-loading 라우팅·dev 배포 파일 설명 동기화 대상 |
| `.ai/70_ledger/active/K-0028-consumer-skill-ide-tools-reference-deferred.md` | 재검토 이력 기록 대상 |
