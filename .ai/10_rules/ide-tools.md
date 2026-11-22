<!-- SYNCED by ai-workspace — 원본: ai-workspace/templates/dev/.ai/10_rules/ide-tools.md, DO NOT EDIT -->
<!-- 버전: 1.1.0 -->

# IDE 도구 우선 규칙

> 이 파일은 코드 탐색·수정·실행에서 어떤 도구를 먼저 쓸지 정한다. 무엇을 탐색·수정·실행할지는 각 스킬 규칙과 작업 지시가 정한다.

## 적용 조건

- 아래 두 조건이 모두 맞을 때만 적용한다.
  - IntelliJ MCP가 연결되어 있다.
  - 대상 프로젝트가 IntelliJ에 열려 있다.
- 조건을 확인하려고 따로 호출하지 않는다. 도구를 찾지 못하거나 첫 호출이 아래 전환 조건의 오류로 끝나면 조건이 맞지 않는 것으로 본다.
- 조건이 맞지 않으면 이 규칙을 적용하지 않고 grep·파일 읽기·셸 명령 같은 기존 도구를 쓴다.

## 작업별 우선 도구

아래 작업은 grep·파일 읽기·셸 명령보다 IDE 도구를 먼저 쓴다.

### 탐색·수정

| 작업 | 먼저 쓸 도구 | 쓰는 방법 |
|------|-------------|-----------|
| 클래스·메서드·필드 위치 찾기 | `search_symbol` | 결과가 없으면 `include_external=true`로 라이브러리까지 다시 찾는다 |
| 호출 관계 찾기 | `analyze_calls` | `search_symbol`로 얻은 FQN(fully qualified name, 패키지를 포함한 전체 이름)을 `symbolFqn`에 넘긴다. 이 심볼을 부르는 곳은 `INCOMING_CALLS`, 이 심볼이 부르는 곳은 `OUTGOING_CALLS`로 본다 |
| 식별자 이름 변경 | `rename_refactoring` | `preview=true`로 영향 범위와 충돌을 확인한 뒤 적용한다. 성공 여부는 결과의 `applied`로 판단한다 |
| 선언·타입·시그니처 확인 | `get_symbol_info` | 줄·열 위치는 `search_symbol` 결과를 쓴다 |
| 수정 후 검증 | `lint_files` | 수정한 파일 목록을 넘긴다 |
| 수정 후 import 정리 | `optimize_imports` | 수정한 파일에만 쓴다. 결과 diff에 손대지 않은 import의 재정렬이 섞이면 되돌린다 |
| 라이브러리·JDK 소스 읽기 | `read_file` | jar 안 소스를 읽고, 소스가 없으면 디컴파일 결과를 읽는다 |
| 의존성·모듈 구조 확인 | `get_project_dependencies`·`get_project_modules` | 빌드 파일을 읽기 전에 IDE가 불러온 라이브러리와 모듈 목록을 본다 |
| 사용자가 가리킨 파일 확인 | `get_all_open_file_paths` | 사용자가 "이 파일"처럼 IDE에 열린 파일을 가리킬 때 쓴다 |

- `build_project`는 시그니처·이름·타입처럼 다른 파일에 영향이 가는 선언을 바꾼 뒤에만 쓴다. 도구 설명의 "수정 후 반드시 빌드" 안내보다 이 규칙이 우선한다.

### 실행

| 작업 | 먼저 쓸 도구 | 쓰는 방법 | 뒷정리 |
|------|-------------|-----------|--------|
| 테스트 실행 | `get_run_configurations`·`execute_run_configuration` | `get_run_configurations(filePath)`로 run point를 찾고 `execute_run_configuration(filePath, line, waitForExit=true, timeout)`으로 실행한다. 판정은 `exitCode`와 `fullOutputPath` 로그의 실패 건수로 한다. `exitCode`가 없으면 `timeout` 안에 끝나지 않아 프로세스가 계속 돌고 있으므로 판정하지 않는다. `fullOutputPath`가 없어 실패 건수를 확인할 수 없으면 `exitCode`가 0이어도 통과로 보지 않고 러너 명령으로 판정한다 | 임시 Run Configuration은 그대로 둔다(IntelliJ가 5개까지만 남기고 오래된 것부터 지운다). `exitCode`가 없으면 테스트가 계속 돌고 있다고 사용자에게 알리고 종료를 요청한다 |
| 커버리지 확인 | `coverage_run_configuration`·`coverage_get_file` | `coverage_run_configuration(filePath, line)`으로 실행하고 `coverage_get_file`로 변경한 줄이 실행됐는지 본다. 결과를 아직 불러오는 중이면 `coverage_get_status`로 확인한다 | 없음(임시 Run Configuration과 에디터의 커버리지 표시는 그대로 둔다. 지우거나 끄는 도구가 없다) |
| 로컬 서버 기동 | `execute_run_configuration` | `testing-principles-local.md`의 로컬 서버 절에 적힌 Run Configuration 이름으로 `execute_run_configuration(configurationName, waitForExit=false)`를 호출해 띄운다. 이름이 없으면 `get_run_configurations()` 목록을 보여 주고 사용자에게 고르게 한다. 반환값에 환경 변수·실행 인자가 함께 들어 있으므로 목록에서는 구성 이름만 보여 준다 | 작업이 끝나면 서버가 떠 있다고 사용자에게 알리고 종료를 요청한다(일반 실행 프로세스를 끄는 도구가 없다) |
| 디버깅 | `xdebug_set_breakpoints`·`xdebug_start_debugger_session`·`xdebug_control_session` | 사용자가 요청할 때만 시작한다. 중단점을 건 뒤 세션을 시작해 멈출 때까지 기다리고, 멈춘 뒤 스택 → 프레임 값 → 식 평가 순서로 확인한다. 자세한 순서는 아래 디버깅 순서를 따른다 | `xdebug_control_session(action=STOP)`으로 세션을 멈추고, `owner=agent`만 준 `xdebug_remove_breakpoints`로 에이전트가 건 중단점만 지운다 |

#### 디버깅 순서

- 디버깅은 사용자가 요청할 때만 시작한다. 디버그 세션은 프로그램을 띄우고 IDE에 디버그 창과 중단점을 남기기 때문이다.
- 중단점은 줄이면 `xdebug_set_breakpoints`, 예외면 `jvm_debug_set_exception_breakpoint`, 메서드면 `jvm_debug_set_method_breakpoint`로 건다.
- 예외·메서드 중단점은 걸기 전에 `jvm_debug_list_exception_breakpoints`·`jvm_debug_list_method_breakpoints`로 같은 대상의 사용자 중단점을 확인하고, 있으면 건드리지 않는다. 도구가 그 설정을 덮어쓰고 소유자는 `user`로 남아 뒷정리로 되돌릴 수 없기 때문이다.
- 멈추지 않고 값만 기록할 때는 `logExpression`과 `suspendPolicy=NONE`을 준 로그 지점을 건다.
- `xdebug_start_debugger_session`으로 시작하고, 멈추는 중단점이 있으면 `xdebug_control_session(action=WAIT_FOR_PAUSE)`로 멈출 때까지 기다린다.
- 로그 지점만 걸었으면 프로그램이 멈추지 않으므로 기다리지 않고 `xdebug_control_session(action=DRAIN_EVENTS)`로 기록한 값을 읽는다. 기록은 JVM 디버거에서만 돌아온다.
- 멈춘 뒤에는 `xdebug_get_stack` → `xdebug_get_frame_values` → `xdebug_evaluate_expression` 순서로 확인한다.
- 프로그램이 멈추거나 느린 원인은 `jvm_debug_get_thread_dump`로 본다.
- `xdebug_get_threads`·`xdebug_get_value_by_path`·`xdebug_get_debugger_status`·`xdebug_get_process_output`·`xdebug_list_breakpoints`·`xdebug_run_to_line`과 `xdebug_control_session`의 단계 실행(`STEP_INTO`·`STEP_OVER`·`STEP_OUT`)은 디버깅 중에 필요하면 쓴다.
- 끝나면 `xdebug_control_session(action=STOP)`으로 세션을 멈추고 `owner=agent`만 준 `xdebug_remove_breakpoints`로 에이전트가 건 중단점만 지운다. 사용자 중단점(`owner=user`)은 건드리지 않는다.

#### 실행 표 밖의 작업과 판정

- 표에 없는 작업은 IDE 도구가 있어도 기존 도구를 쓴다.
- 검증 레벨 `[D]` 판정과 이슈 완료·PR 전 회귀 판정은 `testing-principles-local.md` 테스트 층 표의 러너 명령으로 한다. IDE 실행은 IDE 빌드 설정과 IDE에서 고른 빌드 profile을 따라 셸 러너와 결과가 달라질 수 있다.

## 기존 도구로 전환하는 조건

아래 경우에는 IDE 도구 대신 grep·파일 읽기·셸 명령을 쓴다.

- IntelliJ MCP 연결이 실패하거나 `doesn't correspond to any open project` 오류가 난다. 대상 프로젝트가 IntelliJ에 열려 있지 않다는 뜻이다.
- 문서·설정 파일·로그·문자열 리터럴을 검색한다.
- 명령 출력을 가공한다.
- 프로젝트 밖 파일을 다룬다. 라이브러리·JDK 소스 읽기는 예외로 `read_file`을 쓴다.

아래 경우에는 IDE 도구 결과를 grep으로 다시 확인한다.

- 의미 기반 검색 결과가 비었으면 "사용처 없음"으로 판단하지 않고 텍스트 검색으로 다시 확인한다. 찾는 심볼이 없어도 오류 없이 빈 목록이 오기 때문이다.
- 삭제나 이름 변경 전에는 리플렉션·설정 파일·XML 매퍼·뷰 템플릿·문자열로 참조하는 곳이 있는지 grep으로 한 번 더 확인한다. IDE 도구는 코드 참조만 추적한다.

## 사용자가 요청할 때만 쓰는 도구

아래 도구는 에이전트가 스스로 쓰지 않고, 사용자가 요청할 때만 쓴다.

- `reformat_file`: 파일 전체 서식을 바꿔 손대지 않은 줄까지 diff에 들어간다.
- `xdebug_set_variable`: 실행 중 값을 바꿔 결과가 실제 코드 동작과 달라진다.
- `open_file_in_editor`: 사용자의 IDE 화면을 바꾼다.
- changelist 도구(`create_changelist`·`delete_changelist`·`move_changes_to_changelist`·`set_active_changelist`): 사용자의 변경 목록을 바꾼다.
- `convert_java_to_kotlin`: 파일의 언어를 바꾼다.

## 호출 방법

- IntelliJ MCP 도구는 지연 로드라 세션 시작 시 도구 목록에 없을 수 있다. 없으면 도구 이름(`search_symbol` 등)으로 찾아 불러온다.
  - Claude Code: 도구 검색(ToolSearch)에 도구 이름을 넘겨 불러온다.
  - Codex: `exec` 도구 안에서 `ALL_TOOLS`를 도구 이름으로 걸러 찾는다.
- 작업을 시작할 때 그 행의 도구를 한 번에 불러온다. 디버깅은 도구가 6~8개 필요해, 쓸 때마다 하나씩 불러오면 불러오지 못한 도구 대신 기존 도구로 넘어가기 쉽다.
- MCP 서버 등록 이름은 환경마다 다를 수 있으므로 도구 이름으로 찾는다.
- 모든 호출에 `projectPath`로 현재 프로젝트 경로(보통 repo 루트)를 넘긴다. 여러 프로젝트가 열려 있을 때 대상이 모호해지지 않게 하려는 것이다.
- 파일 경로 인자는 프로젝트 루트 기준 상대 경로로 넘긴다.
