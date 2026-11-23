---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/144
last_harvested: 2026-11-22
---

# IntelliJ MCP 도구별 결정 목록

IntelliJ MCP 도구마다 `ide-tools.md`(dev 템플릿 `ai-workspace/templates/dev/.ai/10_rules/ide-tools.md`)에서 쓸지를 정하고 이유를 남긴다. IntelliJ 업데이트로 도구가 바뀌면 이 목록과 대조해 새 도구만 판단한다.

- **확인일**: 2026-11-22
- **IntelliJ 버전**: 2026.3 (IU-263.7307.200)
- **도구 수**: 101

## 도구 이름 목록 받는 방법

목록 파일은 한 줄에 도구 이름 하나다. MCP 서버 등록 이름은 환경마다 다르므로 접두어를 지워 도구 이름만 남긴다.

- Claude Code: 지연 도구 목록에서 `mcp__<등록 이름>__`으로 시작하는 이름을 모아 접두어를 지운다.
- Codex: `exec` 도구 안에서 `ALL_TOOLS`를 IntelliJ 서버 도구로 걸러 이름만 뽑는다.

현재 사본은 `ai-workspace/tests/fixtures/ide-tool-list/intellij-mcp-tools.txt`이며, `LC_ALL=C sort` 순서로 적는다.

## 다시 비교하는 절차

1. IntelliJ를 업데이트하면 위 방법으로 목록을 받아 `ai-workspace/tests/check-ide-tool-list.sh <목록 파일>`로 대조한다.
   - `새 도구: <이름>`은 목록에만 있고, `사라진 도구: <이름>`은 이 결정 목록에만 있다. 차이가 있으면 종료 코드 1, 없으면 0이다.
2. 새 도구만 결정하고 아래 표에 행을 더한다.
3. 사라진 도구는 표에서 그 행을 지우고, `ide-tools.md`에 이름이 있으면 그 줄도 고친다. 이름이 바뀐 도구는 사라진 도구와 새 도구로 함께 나오므로 옛 행을 새 이름으로 옮긴다.
4. 목록 사본과 이 파일 머리의 확인일·IntelliJ 버전·도구 수를 고친다.
5. 같은 목록으로 대조를 다시 실행해 무출력·종료 코드 0을 확인하고, `ai-workspace/tests/run-tests.sh`로 `ide-tools.md`와의 내부 일치 검사도 통과하는지 본다.

## 결정 값

- `표에 둠`: `ide-tools.md`에 이름을 적고 에이전트가 쓰는 도구. 표 행과 표 아래 목록을 포함하며, `## 사용자가 요청할 때만 쓰는 도구` 절 밖에 이름을 적는다.
- `쓰지 않음`: 에이전트가 스스로 쓰지 않는 도구. 사용자가 요청할 때만 쓰는 도구도 여기에 넣는다. `ide-tools.md`에는 `## 사용자가 요청할 때만 쓰는 도구` 절에만 이름을 적을 수 있다.
- `기존 도구`: grep·파일 읽기·편집 도구·셸 명령 같은 기존 도구가 맡는 도구.
- `보류`: 써 본 경험이나 사례가 생긴 뒤 다시 판단하는 도구.

`ai-workspace/tests/run-tests.sh`는 `ide-tools.md`에 적힌 도구 이름과 이 표의 결정이 위 뜻과 어긋나면 실패한다.

## 탐색·수정

| 도구 | 결정 | 이유 |
|------|------|------|
| `analyze_calls` | 표에 둠 | 호출 관계를 FQN 기준으로 찾는다 |
| `build_project` | 표에 둠 | 다른 파일에 영향이 가는 선언을 바꾼 뒤에만 쓴다 |
| `get_all_open_file_paths` | 표에 둠 | 사용자가 IDE에 열린 파일을 가리킬 때 대상을 찾는다 |
| `get_project_dependencies` | 표에 둠 | IDE가 불러온 라이브러리 목록을 빌드 파일보다 먼저 본다 |
| `get_project_modules` | 표에 둠 | IDE가 불러온 모듈 구조를 빌드 파일보다 먼저 본다 |
| `get_symbol_info` | 표에 둠 | 선언·타입·시그니처를 확인한다 |
| `lint_files` | 표에 둠 | 수정한 파일의 검사를 한다 |
| `optimize_imports` | 표에 둠 | 수정한 파일의 import를 정리한다 |
| `read_file` | 표에 둠 | 라이브러리·JDK 소스를 jar 안에서 읽는다 |
| `rename_refactoring` | 표에 둠 | 식별자 이름을 참조와 함께 바꾼다 |
| `search_symbol` | 표에 둠 | 클래스·메서드·필드 위치를 의미 기반으로 찾는다 |

## 파일·편집

| 도구 | 결정 | 이유 |
|------|------|------|
| `apply_patch` | 기존 도구 | 편집 도구가 맡는다 |
| `create_new_file` | 기존 도구 | 파일 쓰기 도구가 맡는다 |
| `get_file_problems` | 기존 도구 | 수정 후 검증은 `lint_files`가 맡는다 |
| `list_directory_tree` | 기존 도구 | 파일 목록은 셸 명령이 맡는다 |
| `search_file` | 기존 도구 | 파일 이름 검색은 셸 명령이 맡는다 |
| `search_regex` | 기존 도구 | 텍스트 검색은 grep보다 나은 점이 없다 |
| `search_text` | 기존 도구 | 텍스트 검색은 grep보다 나은 점이 없다 |
| `convert_java_to_kotlin` | 쓰지 않음 | 파일의 언어를 바꾼다. 사용자가 요청할 때만 쓴다 |
| `open_file_in_editor` | 쓰지 않음 | 사용자의 IDE 화면을 바꾼다. 사용자가 요청할 때만 쓴다 |
| `reformat_file` | 쓰지 않음 | 파일 전체 서식을 바꿔 손대지 않은 줄까지 diff에 들어간다. 사용자가 요청할 때만 쓴다 |

## 테스트·커버리지·실행

| 도구 | 결정 | 이유 |
|------|------|------|
| `coverage_get_file` | 표에 둠 | 변경한 줄이 실행됐는지 본다 |
| `coverage_get_status` | 표에 둠 | 커버리지 결과를 불러오는 중인지 확인한다 |
| `coverage_run_configuration` | 표에 둠 | run point를 커버리지와 함께 실행한다 |
| `execute_run_configuration` | 표에 둠 | 테스트 run point와 로컬 서버 Run Configuration을 실행한다 |
| `get_run_configurations` | 표에 둠 | 파일의 run point와 프로젝트의 Run Configuration 목록을 찾는다 |
| `coverage_get_stats` | 보류 | 변경한 줄 확인은 `coverage_get_file`이 맡고, 전체 비율이 필요한 사례가 아직 없다 |

## 디버깅

| 도구 | 결정 | 이유 |
|------|------|------|
| `jvm_debug_get_thread_dump` | 표에 둠 | 프로그램이 멈추거나 느린 원인을 본다 |
| `jvm_debug_list_exception_breakpoints` | 표에 둠 | 예외 중단점을 걸기 전에 같은 대상의 기존 중단점을 확인한다 |
| `jvm_debug_list_method_breakpoints` | 표에 둠 | 메서드 중단점을 걸기 전에 같은 대상의 기존 중단점을 확인한다 |
| `jvm_debug_set_exception_breakpoint` | 표에 둠 | 예외 중단점을 걸고, 응답의 `created`가 `true`일 때만 `breakpointId`를 기록한다 |
| `jvm_debug_set_method_breakpoint` | 표에 둠 | 메서드 중단점을 걸고, 응답의 `created`가 `true`일 때만 `breakpointId`를 기록한다 |
| `xdebug_control_session` | 표에 둠 | 멈출 때까지 기다리기, 로그 지점 기록 읽기, 단계 실행, 세션 멈추기를 한다 |
| `xdebug_evaluate_expression` | 표에 둠 | 멈춘 뒤 식을 평가한다 |
| `xdebug_get_debugger_status` | 표에 둠 | 디버깅 중 세션 상태를 조회한다 |
| `xdebug_get_frame_values` | 표에 둠 | 멈춘 뒤 프레임 값을 본다 |
| `xdebug_get_process_output` | 표에 둠 | 디버깅 중 프로세스 출력을 본다 |
| `xdebug_get_stack` | 표에 둠 | 멈춘 뒤 스택을 본다 |
| `xdebug_get_threads` | 표에 둠 | 디버깅 중 스레드 목록을 본다 |
| `xdebug_get_value_by_path` | 표에 둠 | 디버깅 중 중첩 값을 경로로 본다 |
| `xdebug_list_breakpoints` | 표에 둠 | 디버깅 중 중단점 목록을 본다 |
| `xdebug_remove_breakpoints` | 표에 둠 | 뒷정리에서 이번 작업에서 건 중단점의 ID와 `owner=agent`를 함께 주어 그 중단점만 지운다 |
| `xdebug_run_to_line` | 표에 둠 | 디버깅 중 지정한 줄까지 실행한다 |
| `xdebug_set_breakpoints` | 표에 둠 | 줄 중단점과 로그 지점을 건다 |
| `xdebug_start_debugger_session` | 표에 둠 | 디버그 세션을 시작한다 |
| `xdebug_set_variable` | 쓰지 않음 | 실행 중 값을 바꿔 결과가 실제 코드 동작과 달라진다. 사용자가 요청할 때만 쓴다 |
| `jvm_debug_memory_class_snapshot` | 보류 | 메모리 분석이 필요한 사례가 아직 없다 |
| `jvm_debug_memory_closest_gc_roots` | 보류 | 메모리 분석이 필요한 사례가 아직 없다 |
| `jvm_debug_memory_get_instances` | 보류 | 메모리 분석이 필요한 사례가 아직 없다 |
| `jvm_debug_memory_read_fields` | 보류 | 메모리 분석이 필요한 사례가 아직 없다 |
| `xdebug_attach_to_process` | 보류 | 밖에서 띄운 프로세스에 디버그 에이전트가 있어야 붙일 수 있다 |
| `xdebug_set_breakpoints_muted` | 보류 | 중단점을 끈 채 끝까지 실행해야 하는 사례가 아직 없다 |

## 검사·구조 분석

| 도구 | 결정 | 이유 |
|------|------|------|
| `compile_inspection_kts` | 보류 | 직접 만든 검사로 구조 검색에 쓸 수 있지만 써 본 경험이 없다 |
| `generate_inspection_kts_api` | 보류 | 직접 만든 검사로 구조 검색에 쓸 수 있지만 써 본 경험이 없다 |
| `generate_inspection_kts_examples` | 보류 | 직접 만든 검사로 구조 검색에 쓸 수 있지만 써 본 경험이 없다 |
| `generate_psi_tree` | 보류 | 직접 만든 검사로 구조 검색에 쓸 수 있지만 써 본 경험이 없다 |
| `run_inspection_kts` | 보류 | 직접 만든 검사로 구조 검색에 쓸 수 있지만 써 본 경험이 없다 |
| `run_inspection_kts_examples` | 보류 | 직접 만든 검사로 구조 검색에 쓸 수 있지만 써 본 경험이 없다 |
| `run_inspection_kts_project` | 보류 | 직접 만든 검사로 구조 검색에 쓸 수 있지만 써 본 경험이 없다 |

## VCS·터미널

| 도구 | 결정 | 이유 |
|------|------|------|
| `execute_terminal_command` | 기존 도구 | 셸 명령은 기존 셸 도구가 맡는다 |
| `get_changelists` | 기존 도구 | 변경 사항은 git 명령으로 보고, changelist는 IDE 안에서만 쓰는 묶음이다 |
| `get_repositories` | 기존 도구 | 저장소 확인은 git 명령이 맡는다 |
| `git_status` | 기존 도구 | git 상태는 git 명령이 맡는다 |
| `create_changelist` | 쓰지 않음 | 사용자의 변경 목록을 바꾼다. 사용자가 요청할 때만 쓴다 |
| `delete_changelist` | 쓰지 않음 | 사용자의 변경 목록을 바꾼다. 사용자가 요청할 때만 쓴다 |
| `move_changes_to_changelist` | 쓰지 않음 | 사용자의 변경 목록을 바꾼다. 사용자가 요청할 때만 쓴다 |
| `set_active_changelist` | 쓰지 않음 | 사용자의 변경 목록을 바꾼다. 사용자가 요청할 때만 쓴다 |

## DB·SQL

IDE에 등록된 DB 연결은 대상 환경을 알 수 없어, DB·SQL 작업은 기존 도구가 맡는다.

| 도구 | 결정 | 이유 |
|------|------|------|
| `cancel_sql_query` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `create_database_connection` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `edit_database_connection` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `execute_cross_db_query` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `execute_sql_query` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `export_query_result` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `fetch_query_result` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `get_database_object_description` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `import_data` | 기존 도구 | DB 데이터 가져오기라 DB·SQL 작업과 같이 기존 도구가 맡는다 |
| `inspect_import_file` | 기존 도구 | DB 데이터 가져오기라 DB·SQL 작업과 같이 기존 도구가 맡는다 |
| `inspect_import_query` | 기존 도구 | DB 데이터 가져오기라 DB·SQL 작업과 같이 기존 도구가 맡는다 |
| `introspect_schema` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `list_data_extractors` | 기존 도구 | DB 결과 내보내기라 DB·SQL 작업과 같이 기존 도구가 맡는다 |
| `list_database_connections` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `list_database_schemas` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `list_recent_sql_queries` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `list_schema_object_kinds` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `list_schema_objects` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `preview_table_data` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |
| `test_database_connection` | 기존 도구 | DB·SQL 작업은 기존 도구가 맡는다 |

## 노트북·기타

| 도구 | 결정 | 이유 |
|------|------|------|
| `create_notebook` | 쓰지 않음 | 노트북 기능은 이 규칙의 작업과 관계없다 |
| `edit_notebook` | 쓰지 않음 | 노트북 기능은 이 규칙의 작업과 관계없다 |
| `execute_code_on_kernel` | 쓰지 않음 | 노트북 기능은 이 규칙의 작업과 관계없다 |
| `get_notebook_state` | 쓰지 않음 | 노트북 기능은 이 규칙의 작업과 관계없다 |
| `interrupt_notebook` | 쓰지 않음 | 노트북 기능은 이 규칙의 작업과 관계없다 |
| `kill_notebook` | 쓰지 않음 | 노트북 기능은 이 규칙의 작업과 관계없다 |
| `read_notebook` | 쓰지 않음 | 노트북 기능은 이 규칙의 작업과 관계없다 |
| `read_notebook_cell` | 쓰지 않음 | 노트북 기능은 이 규칙의 작업과 관계없다 |
| `run_notebook_cell` | 쓰지 않음 | 노트북 기능은 이 규칙의 작업과 관계없다 |
| `wait_cell_execution` | 쓰지 않음 | 노트북 기능은 이 규칙의 작업과 관계없다 |
| `air_set_session_title` | 쓰지 않음 | 이 규칙의 작업과 관계없는 IDE 기능이다 |
| `execute_tool` | 쓰지 않음 | 다른 도구를 이름으로 대신 부르는 도구라 그 도구를 직접 부른다 |
| `spec_report_status` | 쓰지 않음 | 이 규칙의 작업과 관계없는 IDE 기능이다 |
| `spec_specify_finished` | 쓰지 않음 | 이 규칙의 작업과 관계없는 IDE 기능이다 |
