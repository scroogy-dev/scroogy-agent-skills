---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/136
related_jira:
last_harvested: 2026-11-07
---

# ADR: IDE 도구 우선 규칙을 dev 전용 버전 고정 단일 파일로 배포하고 규칙 표 설명 열에 핵심 기준을 적는 결정

- **상태**: 유효

## 결정

- IntelliJ MCP가 연결된 환경에서 코드 탐색·수정에 어떤 도구를 먼저 쓸지는 `10_rules/ide-tools.md` 한 파일에 둔다 (#136).
  - **버전 고정 단일 파일**: 1행 SYNCED 헤더와 2행 버전 주석(1.0.0)을 두고 update-1이 dev 프로파일에서 항상 덮어쓴다. `ide-tools-local.md` 쌍은 두지 않는다.
  - **dev 프로파일 전용**: `templates/dev/`에 둔다. init은 dev 템플릿 일괄 복사에 포함되고, doc 프로파일에는 배포하지 않는다.
  - **본문 구성**: `## 적용 조건`, `## 작업별 우선 도구`, `## 기존 도구로 전환하는 조건`, `## 호출 방법` 4절이다. 조건이 맞지 않는 환경에서는 기존 도구를 그대로 쓴다.
  - **도구 이름으로 안내**: 본문에 MCP 서버 등록 이름을 적지 않는다. 도구 목록에 없으면 도구 이름으로 찾아 불러오게 한다(Claude Code 도구 검색, Codex `ALL_TOOLS` 필터).
  - **수정 후 검증 기본값**: `lint_files`다. `build_project`는 다른 파일에 영향이 가는 선언을 바꾼 뒤에만 쓰며, 도구 설명의 "수정 후 반드시 빌드" 안내보다 이 규칙이 우선한다.
- 에이전트가 이 규칙으로 안내받는 경로 두 곳을 잇는다. ADR 0023의 테스트 실행 원칙과 같은 경로다.
  - **안내도 규칙 표**: dev AI-CONTEXT 템플릿 `## 프로젝트 규칙` 표에 `ide-tools.md` 행을 두고, **설명 열에 핵심 기준을 직접 적는다**. 설명 열만 읽어도 어떤 작업에 IDE 도구를 먼저 쓰고 언제 grep으로 바꾸는지 판단할 수 있어야 한다. 사용 시점은 `코드 탐색·수정 전`이다.
  - **context-loading**: shared `context-loading.md`의 `## 코드 수정·리뷰·분석 시` 목록 2번(`architecture.md` 다음)에 둔다. "존재하면 읽는다" 목록이라 파일이 없는 doc repo는 건너뛴다.
- update-4 멱등 보강 검사(`check-context.sh`)는 본문 2번째 줄이 dev 표준 SSoT 선언일 때만 `ide-tools.md` 행 누락을 보고한다. doc 선언·비표준 선언은 검사하지 않는다. 누락이면 알파벳순 자리에 표준 행을 넣고 사용자 행은 보존한다.
- 헬퍼를 한 번만 실행해 행 검사가 돌지 않는 실행에서도 dev 전용 행(`testing-principles.md`·`ide-tools.md`)을 함께 넣는다.
  - **선언 보정**: SSoT 선언 행·건물 repo 선언 행의 조치로 dev 문구를 넣거나 바꾼 실행.
  - **규칙 섹션·표 복구**: 섹션 부재·표 부재로 복구한 실행에서 본문 2번째 줄이 dev 표준 선언이면, 선택한 프로파일과 무관하게 넣는다. 원장 K-0018을 이 방식으로 해소하며 회귀 fixture `no-rules-section-mismatch`·`no-rules-table-mismatch`를 둔다.
- ADR 0023은 그대로 둔다. 테스트 실행 원칙 쌍과 소비 스킬 참조 결정은 바뀌지 않고, 이 ADR이 같은 배포 경로에 파일 하나와 보강 계기 하나를 더한다.

## 근거

<details>
<summary>상세 펼치기</summary>

- IntelliJ MCP를 Claude Code·Codex에 연결했지만 2026-11-07 기준 Claude Code 세션 로그 662개에서 호출이 0건이었다. 같은 기간 Bash 호출 33,052건 가운데 검색 명령(`grep`·`rg`·`find`)이 약 1만 건이다 (#136 배경).
- 원인은 MCP 도구의 지연 로드로 추정했다. 세션 시작 시 이름만 보이고, IntelliJ MCP 서버 안내문과 규칙 문서도 없었다.
- 단일 파일로 둔 이유: local 쌍은 repo마다 다른 표(테스트 층 표 등)를 채우려고 두는데, 이 규칙에는 repo별로 채울 표가 없다. IDE를 쓰지 않는 환경은 본문의 적용 조건으로 처리한다.
- 규칙 표 설명 열에 핵심 기준을 적는 이유: 규칙 표는 세션 시작부터 컨텍스트에 있다. 코드 탐색은 작업의 첫 동작이라 규칙 파일을 읽기 전에 grep부터 실행할 수 있으므로, 표 행만 읽어도 판단되게 했다.
- repo 안내도를 진입점으로 쓴 이유: Claude Code는 `.claude/CLAUDE.md` import로, Codex는 `project_doc_fallback_filenames`로 repo `AI-CONTEXT.md`를 읽어 한 곳으로 두 도구에 적용된다.
- 서버 등록 이름을 적지 않은 이유(2026-11-07 Task 0 사용자 결정): 두 도구 모두 전체 이름이 `mcp__<등록 이름>__<도구 이름>`이라 등록 이름이 사람마다 다르면 전체 이름도 달라진다. 두 도구 모두 도구 이름만으로 찾을 수 있다. Codex 동작은 `codex-cli 0.167.0` 설정과 실행 기록으로 확인했다.
- `lint_files`를 기본값으로 둔 이유(같은 날 Task 0 사용자 결정): 프로젝트가 크면 빌드가 오래 걸린다. 선언 변경처럼 다른 파일에 영향이 가는 수정만 빌드로 확인한다.
- 빈 결과를 grep으로 다시 확인하게 한 이유: 열려 있지 않은 경로는 `doesn't correspond to any open project` 오류가 나지만, 찾는 심볼이 없으면 오류 없이 빈 목록이 온다(2026-11-07 실제 호출로 확인).
- 행 검사를 dev 표준 선언으로 한정한 이유는 ADR 0023과 같다. 파일이 dev 전용이라 doc repo에 행을 넣으면 없는 파일을 가리킨다.
- 선언 보정 실행의 보강은 계획 감사 F-1(2026-11-07)을 반영했다. 비표준·doc 선언 입력은 첫 검사에서 새 행 검사를 건너뛰고, 선언 보정 뒤 표준 구간 최신화가 교체하는 4개 구간에 `## 프로젝트 규칙`이 없어 그 실행에서 행이 빠졌다.
- K-0018을 같은 이슈에서 해소한 이유: dev 전용 행 검사를 늘리는 변경이라 원장의 재검토 조건(행 검사 조건의 실질 변경)을 충족한다. 원장이 적어 둔 "채택하지 않은 대안"을 채택했다. 행이 둘로 늘어 복구 실행에서 빠지는 행도 둘이 되므로 같은 문장으로 함께 다뤘다.
- 2026-11-09 일부 변경(#138): 누락 행을 표 끝에 넣으면 알파벳순인 템플릿 표와 순서가 달라져, `ide-tools.md` 행을 포함한 표준 행을 `파일` 셀 기준 알파벳순 자리에 넣게 했다. 행 검사 조건과 dev 전용 행 보강 계기는 바뀌지 않는다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 전역 규칙 파일(`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`)에 두는 안: repo 안내도 한 곳으로 두 도구에 적용되어 대체.
- 호출 기록 훅·grep 안내 훅: 사람별 설정이라 `~/.claude/settings.json`에서 따로 다룬다. 규칙만으로 호출이 늘지 않을 때 검토하기로 보류.
- `alwaysLoad`·`ENABLE_TOOL_SEARCH`로 도구를 미리 적재하는 안: IntelliJ MCP 도구 101개가 모든 세션의 컨텍스트를 차지해 배제.
- `ide-tools-local.md` 쌍: repo별로 채울 표가 없어 불필요.
- doc 프로파일 배포: 코드 탐색 대상이 없어 불필요.
- 소비 스킬(`code-map`·`git-review` 등) 본문에서 직접 참조하는 안: 규칙 표가 스킬 실행에도 선행 적용되므로 효과를 본 뒤 판단하기로 보류.
- 규칙 표 설명 열을 짧게 두고 기준을 파일에만 두는 안: 규칙 파일을 읽기 전에 grep을 실행할 수 있어 배제.
- 규칙 본문에 서버 등록 이름 `idea`를 적는 안: 등록 이름이 사람마다 다를 수 있어 배제.
- `build_project`를 수정 후 검증 기본값에 넣는 안: 큰 프로젝트에서 빌드가 오래 걸려 선언 변경 뒤로 한정.
- 다른 IDE의 MCP: 현재 IntelliJ만 사용해 보류.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #136 ai-workspace: IDE 도구 우선 규칙(ide-tools.md)을 dev 프로파일에 도입하고 init·update에서 안내도 규칙 표·context-loading에 연결한다](https://github.com/scroogy-dev/scroogy-agent-skills/issues/136)
- 일부 변경: [Issue #138](https://github.com/scroogy-dev/scroogy-agent-skills/issues/138)
- 규칙 본문: [`.ai/10_rules/ide-tools.md`](../../10_rules/ide-tools.md)
- 해소한 원장 항목: [K-0018](../../70_ledger/archive/K-0018-update4-rules-restore-profile-mismatch-row.md)
- 관련 결정: [ADR 0008 작성 원칙 SSoT 배포](./0008-writing-principles-ssot-distribution.md), [ADR 0023 테스트 실행 원칙 쌍](./0023-testing-principles-pair-and-consumer-skill-references.md), [ADR 0028 소유 구간과 profile 행](./0028-ai-workspace-owned-sections-and-profile-row.md)
- 외부 문서: [IntelliJ IDEA MCP 서버](https://www.jetbrains.com/help/idea/mcp-server.html), [Claude Code MCP (tool search, `alwaysLoad`)](https://code.claude.com/docs/en/mcp)

</details>
