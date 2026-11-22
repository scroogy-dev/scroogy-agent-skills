---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/144
related_jira:
last_harvested: 2026-11-22
---

# ADR: IDE 도구 우선 규칙에 실행 표를 더하고 IntelliJ MCP 도구별 결정 목록으로 표 밖의 도구를 관리하는 결정

- **상태**: 유효

## 결정

- `ide-tools.md`의 적용 범위를 코드 탐색·수정·실행으로 넓히고, `## 작업별 우선 도구`를 `### 탐색·수정` 표와 `### 실행` 표로 나눈다 (#144). 버전은 1.1.0이다.
  - **실행 표**: 테스트 실행·커버리지 확인·로컬 서버 기동·디버깅 4행이고, 행마다 먼저 쓸 도구·쓰는 방법·뒷정리를 적는다. 뒷정리가 없는 행은 `없음`을 적는다.
  - **테스트 실행**: `get_run_configurations(filePath)`로 run point를 찾고 `execute_run_configuration(filePath, line, waitForExit=true, timeout)`으로 실행한다. `exitCode`와 `fullOutputPath` 로그의 실패 건수로 판정하고, `exitCode`가 없으면 판정하지 않는다. 실패 건수를 확인할 수 없으면 러너 명령으로 판정한다.
  - **커버리지 확인**: `coverage_run_configuration(filePath, line)`으로 실행하고 `coverage_get_file`로 변경한 줄이 실행됐는지 본다.
  - **로컬 서버 기동**: `testing-principles-local.md`의 `## 로컬 서버` 절에 적힌 Run Configuration 이름으로 `execute_run_configuration(configurationName, waitForExit=false)`를 호출한다. 이름이 없으면 `get_run_configurations()` 목록에서 구성 이름만 보여 주고 사용자에게 고르게 한다.
  - **디버깅**: 사용자가 요청할 때만 시작한다. 순서는 표 아래 `#### 디버깅 순서`에 둔다. 예외·메서드 중단점은 걸기 전에 같은 대상의 사용자 중단점을 확인하고, 끝나면 `xdebug_control_session(action=STOP)`과 `owner=agent`만 준 `xdebug_remove_breakpoints`로 정리한다.
  - **실행 흔적**: 테스트·커버리지 실행이 남기는 임시 Run Configuration과 에디터의 커버리지 표시는 그대로 둔다(이슈 `검토 필요` 1). IDE로 띄운 프로세스(로컬 서버, `timeout` 안에 끝나지 않은 테스트)는 계속 돌고 있다고 사용자에게 알리고 종료를 요청한다(이슈 `검토 필요` 2).
- 표에 없는 작업은 IDE 도구가 있어도 기존 도구(grep·파일 읽기·편집 도구·셸 명령)를 쓴다. "IDE로 할 수 있으면 IDE 우선" 같은 포괄 원칙은 두지 않는다.
- IDE 실행과 러너 판정을 나눈다. 검증 레벨 `[D]` 판정과 이슈 완료·PR 전 회귀 판정은 IDE 실행이 있어도 `testing-principles-local.md` 테스트 층 표의 러너 명령으로 한다. `testing-principles.md` 본문은 바꾸지 않는다.
- 탐색·수정 표에 의존성·모듈 구조 확인(`get_project_dependencies`·`get_project_modules`), 수정 후 import 정리(`optimize_imports`, 수정한 파일에만), 사용자가 가리킨 파일 확인(`get_all_open_file_paths`) 3행을 더한다. 기존 6행은 그대로 둔다.
- `## 사용자가 요청할 때만 쓰는 도구` 절을 두어 `reformat_file`·`xdebug_set_variable`·`open_file_in_editor`·changelist 도구 4개·`convert_java_to_kotlin`을 이유와 함께 적는다. `## 호출 방법`에는 작업을 시작할 때 그 행의 도구를 한 번에 불러온다는 항목을 더한다.
- 연결 경로를 실행 작업에 맞춘다.
  - **context-loading**: shared `context-loading.md`의 `## 테스트 작성·실행 시` 목록 세 번째 항목에 `ide-tools.md`를 둔다. `## 코드 수정·리뷰·분석 시` 2번 항목은 그대로 두고 설명만 탐색·수정·실행으로 바꾼다. `run-tests.sh` 라우팅 검사는 코드 절 1곳·테스트 절 1곳·파일 전체 2곳을 지킨다.
  - **안내도 규칙 표**: dev AI-CONTEXT 템플릿의 `ide-tools.md` 행 설명에 실행 작업·표 밖 작업·러너 판정 기준을 더하고, 사용 시점을 `코드 탐색·수정·실행 전`으로 바꾼다. update-4 표준 행 문구도 같게 둔다.
  - **local 템플릿**: dev `testing-principles-local.md` 템플릿에 `## 로컬 서버` 절(`Run Configuration 이름`·`IDE 미연결 시 실행 명령`)을 둔다. repo별 값은 이 파일이 맡고 `ide-tools-local.md` 쌍은 두지 않는다.
- 이미 배포된 repo 안내도의 `ide-tools.md` 행 설명은 update로 갱신하지 않는다(이슈 `검토 필요` 4). update-4는 행이 있으면 사용자 행으로 보존한다. 필요한 repo에서 직접 고친다.
- IntelliJ MCP 도구별 결정 목록을 `.ai/40_domain/specs/ide-tools-decisions.md`에 둔다. 이 저장소 전용이며 배포하지 않는다.
  - **결정 값**: `표에 둠`(규칙에 이름을 적고 쓰는 도구), `기존 도구`(기존 도구가 맡는 도구), `쓰지 않음`(에이전트가 스스로 쓰지 않는 도구, 요청 전용 절에만 이름을 적음), `보류`(경험이나 사례가 생긴 뒤 다시 판단하는 도구). 도구마다 이유 한 줄을 적는다.
  - **내부 일치 검사**: `ai-workspace/tests/run-tests.sh`가 템플릿 `ide-tools.md`에 적힌 도구 이름과 결정 목록이 어긋나면 실패한다. 결정 목록을 읽지 못해도 실패로 본다.
  - **다시 비교하는 계기**: IntelliJ를 업데이트하면 도구 이름 목록을 받아 `ai-workspace/tests/check-ide-tool-list.sh <목록 파일>`로 대조한다. 새 도구만 판단해 표에 더하고, 사라진 도구는 결정 행과 `ide-tools.md`의 참조를 정리한 뒤 목록 사본(`ai-workspace/tests/fixtures/ide-tool-list/intellij-mcp-tools.txt`)과 머리의 확인일·IntelliJ 버전·도구 수를 고친다.
- ADR 0029는 적용 범위·사용 시점·context-loading 라우팅을 일부 변경으로 고치고 나머지 결정은 유지한다. ADR 0023은 local 템플릿 섹션 구성과 context-loading 테스트 절 라우팅을 일부 변경으로 고친다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 계기: 2026-11-20 dev 프로파일 Java repo에서 `get_run_configurations`·`execute_run_configuration`으로 테스트 클래스 하나(파라미터 테스트 포함 46건)를 실행해 종료 코드 0과 실패 0건을 받았다. 그런데 `ide-tools.md`는 탐색·수정만 다뤄, 테스트·서버 실행을 요청받으면 에이전트가 셸 명령으로 실행했다 (#144 배경).
- 포괄 원칙 대신 행위를 명시한 이유(2026-11-20 사용자 결정): IntelliJ MCP에는 터미널·git·DB·SQL 도구까지 있어 포괄 원칙은 의도보다 범위가 넓고 판단이 세션마다 갈린다. IDE에 등록된 DB 연결은 대상 환경을 알 수 없다.
- 공통 규칙은 `ide-tools.md`에, repo별 값은 `testing-principles-local.md`에 둔 이유(같은 날 사용자 결정): Run Configuration 이름과 셸 명령은 repo마다 다르고, 테스트 실행 값을 이미 맡는 local 파일이 있다. ADR 0029의 단일 파일 결정을 유지할 수 있다.
- 러너 판정을 나눈 이유: IDE 실행은 IDE 빌드 설정과 IDE에서 고른 빌드 profile을 따른다. profile별 리소스를 쓰는 repo는 셸 러너와 결과가 달라질 수 있어, `[D]` 판정과 최종 회귀 판정은 CI와 같은 조건의 러너로 한다.
- `fullOutputPath`가 없으면 러너로 판정하는 이유: `fullOutputPath`는 선택 필드이고, 결과의 출력은 그 순간의 일부만 담는다(2026-11-22 계획 감사 F-13).
- 실행 흔적을 그대로 두는 이유(2026-11-22 Task 1 사용자 결정): IntelliJ는 임시 구성을 최대 5개까지 두고 새 구성이 생기면 오래된 것부터 지운다. Run Configuration을 지우는 도구와 커버리지 표시를 끄는 도구가 IntelliJ MCP 도구에 없다. 사용자는 실제 호출 없이 도구 정의와 공식 문서(IntelliJ IDEA 2026.3 MCP Server·Run/Debug Configuration)로 결정했다.
- 띄운 프로세스의 종료를 사용자에게 요청하는 이유(같은 Task 1 사용자 결정): 일반 실행 프로세스를 끄는 MCP 도구가 없고 `execute_run_configuration` 결과에 프로세스 ID가 없다. `timeout`이 지나도 프로세스는 계속 돈다. AC에 없던 결과라 변경 통제(확장)로 이슈 본문에 AC31을 더했다.
- 디버깅을 사용자 요청 시로 한정한 이유(2026-11-22 요구사항 승인에서 이슈 `검토 필요` 3 결정): 디버그 세션은 프로그램을 띄우고 IDE에 디버그 창과 중단점을 남긴다.
- 예외·메서드 중단점을 걸기 전에 확인하는 이유: 그 도구는 같은 대상의 기존 설정을 덮어쓰고 소유자를 `user`로 남겨, `owner=agent` 뒷정리로 되돌릴 수 없다.
- 도구를 한 번에 불러오는 이유: #136에서 IDE 도구를 쓰지 않은 원인이 지연 로드였고, 디버깅은 도구가 6~8개 필요하다.
- 101개 도구를 모두 검토한 이유(2026-11-22 사용자 결정): 규칙에 이름이 있는 도구가 7개라 일부 도구만 쓰게 될 수 있었다. 검토에서 나온 디버깅 보강·커버리지 확인·모듈 구조·열린 파일 확인·import 정리 조건·한 번에 불러오기를 범위에 넣었다.
- 결정 목록을 ADR 밖 `40_domain/specs/`에 둔 이유(같은 날 사용자 결정): IntelliJ 업데이트로 도구가 바뀌면 목록을 고쳐야 한다. ADR 근거에 두면 바뀔 때마다 ADR 이력이 늘어난다. 목록과 대조하면 새 도구만 판단하면 된다.
- 목록 대조를 헬퍼가 MCP를 직접 호출하지 않고 목록 파일로 하는 이유: 직접 호출하려면 IntelliJ가 켜져 있어야 하고 연결 절차가 필요하다. 헬퍼와 목록 사본은 배포 제외 경로 `ai-workspace/tests/`에 둔다(ADR 0001).
- 이슈 본문에 결정 근거가 없던 도구 4개는 사용자가 확인했다(2026-11-22). `coverage_get_stats`·`xdebug_set_breakpoints_muted`는 보류, `get_repositories`·`get_changelists`는 기존 도구다.
- 배포된 안내도의 행 설명을 갱신하지 않는 이유(2026-11-22 요구사항 승인에서 이슈 `검토 필요` 4 결정): update-4는 행이 있으면 사용자 행으로 보존하고, `## 프로젝트 규칙`은 표준 구간 최신화 대상이 아니다(ADR 0028). 본문과 context-loading 코드·테스트 절은 update가 덮어써 새 실행 규칙을 읽게 된다.
- 새 ADR로 기록한 이유(2026-11-22 요구사항 승인에서 이슈 `검토 필요` 5 결정): 실행 표와 결정 목록은 ADR 0029가 정하지 않은 새 결정이다. ADR 0029에서 바뀐 항목(적용 범위·사용 시점·context-loading 라우팅)만 일부 변경으로 고쳤다. ADR 0023의 local 템플릿 섹션 구성과 테스트 절 라우팅 서술도 이번 변경으로 낡아 같은 방식으로 고쳤다(2026-11-22 계획 감사 F-6).
- 원장 K-0028의 재검토 조건(`context-loading.md`의 `ide-tools.md` 라우팅 변경)에 해당해 재검토했다. 소비 스킬 본문 참조 여부는 바뀌지 않아 계속 수용이다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- "IDE로 할 수 있으면 IDE 우선"이라는 포괄 원칙: 범위가 넓어지고 판단이 세션마다 갈려 불필요.
- IDE 터미널·git·DB·SQL 도구 행: 기존 도구가 맡고, IDE에 등록된 DB 연결은 대상 환경을 알 수 없어 불필요.
- `ide-tools-local.md` 쌍: repo별 값은 `testing-principles-local.md`가 맡아 대체.
- 도구별 결정 목록을 ADR 근거에 두는 안: 목록이 바뀔 때마다 ADR 이력이 늘어나 `40_domain/specs/`로 대체.
- 기존 도구와 겹치는 IDE 도구(`search_text`·`search_regex`·`search_file`·`list_directory_tree`·`apply_patch`·`create_new_file`·`get_file_problems`): grep·파일 읽기·편집 도구와 `lint_files`가 맡아 대체. 텍스트 검색은 grep보다 나은 점이 없다.
- 실행 흔적을 사용자에게 알리거나 지우는 안: 알리는 안은 AC에 없는 결과를 더하고, 지우는 안은 IDE가 열린 채로 `.idea/workspace.xml`을 고쳐야 해 덮어쓰기·설정 손상 위험이 있어 배제.
- 테스트·서버를 디버그 세션으로 띄워 `xdebug_control_session(action=STOP)`으로 끄는 안: 실행 도구와 고정 문구를 바꿔야 하고, 디버깅은 사용자가 요청할 때만 한다는 결정과 충돌하며, `STOP`이 디버그 대상 프로세스까지 끝내는지 도구 정의와 공식 문서로 확인되지 않아 배제.
- 원인 추적 중 AI 판단으로 디버깅을 시작하는 안: IDE에 디버그 창과 중단점을 남겨 배제.
- update가 배포된 안내도의 표준 행 설명을 갱신하는 안: 사용자 행 보존 원칙과 어긋나 보류. 옛 행 설명 때문에 실행 작업에서 IDE 도구를 놓친 사례가 나오면 다시 본다.
- 헬퍼가 IntelliJ MCP의 `tools/list`를 직접 호출하는 안: IntelliJ가 켜져 있어야 하고 연결 절차가 필요해 보류.
- MCP는 연결됐는데 표의 도구를 찾지 못할 때 사용자에게 알리는 안: 도구 이름 변경은 목록 대조로 확인해 보류.
- inspection.kts 도구 6종과 `generate_psi_tree`, `jvm_debug_memory_*` 4종, `xdebug_attach_to_process`: 써 본 경험이나 필요한 사례가 없어 보류.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #144 ai-workspace: ide-tools.md에 실행 표(테스트·커버리지·로컬 서버·디버깅)를 더하고 IntelliJ MCP 도구별 결정 목록으로 표에 없는 도구를 관리한다](https://github.com/scroogy-dev/scroogy-agent-skills/issues/144)
- 규칙 본문: [`.ai/10_rules/ide-tools.md`](../../10_rules/ide-tools.md)
- 도구별 결정 목록: [`.ai/40_domain/specs/ide-tools-decisions.md`](../../40_domain/specs/ide-tools-decisions.md)
- 관련 결정: [ADR 0001 헬퍼 테스트 위치](./0001-skill-deterministic-helper-test-convention.md), [ADR 0023 테스트 실행 원칙 쌍](./0023-testing-principles-pair-and-consumer-skill-references.md), [ADR 0028 소유 구간과 profile 행](./0028-ai-workspace-owned-sections-and-profile-row.md), [ADR 0029 IDE 도구 우선 규칙 배포](./0029-ide-tools-rule-dev-profile-distribution.md)
- 재검토한 원장 항목: [K-0028](../../70_ledger/active/K-0028-consumer-skill-ide-tools-reference-deferred.md)
- 외부 문서: [IntelliJ IDEA MCP 서버](https://www.jetbrains.com/help/idea/mcp-server.html)

</details>
