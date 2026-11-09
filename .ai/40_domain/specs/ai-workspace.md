---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/3
last_harvested: 2026-09-09
---

# .ai 작업공간과 안내도 요건 (ai-workspace·ai-workspace-directory)

## 요건

- ai-workspace는 개별 repo의 층 안내도(`.ai/AI-CONTEXT.md`)와 `.ai/` 구조를, ai-workspace-directory는 멀티 repo 워크스페이스 루트의 로비 안내도(`<워크스페이스 루트>/.ai/AI-CONTEXT.md`)를 담당한다. 둘은 자매 스킬이며 모든 안내도는 각자의 `.ai/` 안에 둔다.
- ai-workspace-directory: `init`/`update` 모드, 로비 파일 존재로 모드 자동 판정. 표준 섹션 구조 강제, 분량 가드레일, SSoT 위배 진단 체크리스트(`check-lobby.sh`). 안내도 부재 repo는 `status: placeholder`, `archived`는 drift 검사 제외. git 명령에 의존하지 않는다.
- 로비 SSoT 선언: 로비는 SSoT 값을 선언하지 않고 각 repo 안내도의 선언을 따른다. 본문 2번째 줄은 `> SSoT: 각 repo 안내도의 선언을 따른다. 이 파일은 라우터일 뿐 진실의 원천이 아니다.`로 고정하고 그 외 문구(구 `소스 코드` 고정 문구 포함)는 update가 교체한다. 충돌 우선순위는 `각 repo의 SSoT(repo 안내도 선언: 소스 코드 또는 원본 문서) > 각 repo 안내도 > 로비`이며, `placeholder` repo는 선언을 찾지 못하므로 소스 코드로 폴백하고 문서 repo이면 doc 프로파일 설치를 권한다.
- ai-workspace: `init`(전체 초기화, 복사 전 기존 `.ai/` 제거)/`update`(멱등 보강) 모드, dev/doc 프로파일. update는 대상을 소유에 따라 셋으로 나눈다. 파일 단위 최신본은 버전 고정 파일(`context-loading.md`, `writing-principles.md`, dev 전용 `testing-principles.md`·`ide-tools.md`)과 `70_ledger/ledger-entry-template.md`이며 실행마다 덮어쓴다. 구간 단위 교체는 `50_adr/index.md`의 `## 수명 주기`, `70_ledger/index.md`의 머리말과 `## 수명 주기`, `AI-CONTEXT.md` 표준 섹션 4개(`.ai 디렉토리 구조`, `에이전트 운영 지침`, `Git 정책`, `이슈 작업 워크플로우`)이며 헬퍼 `sync-owned.sh`가 맡는다. 사용자 작성분은 바꾸지 않는다. 사용자 관리 파일(`writing-principles-local.md`, dev 전용 `architecture.md`·`coding-convention.md`·`testing-principles-local.md`, doc 전용 `document-convention.md`)은 없을 때만 빈 템플릿을 복사한다. 덮어쓰는 대상의 템플릿에는 직접 고치면 update 때 사라진다는 안내 주석을 한 줄씩 둔다(`70_ledger/index.md` 머리말 제외).
- 안내도 SSoT 선언: 본문 2번째 줄이 dev는 `> SSoT: 소스 코드. …`, doc은 `> SSoT: 원본 문서. …`이다. doc 템플릿은 충돌 우선순위를 `원본 문서 > 이 repo 안내도 > 상위 워크스페이스 안내도`로 두고, `## 프로젝트 도메인` 표에 `ssot_dir`(필수, SSoT 문서 디렉토리)·`publish`(선택, 퍼블리싱 위치 URL) 행을 둔다. dev 템플릿에는 두 행이 없다.
- 프로파일 표시와 결정: `## 프로젝트 도메인` 첫 표의 `profile` 행(`dev`·`doc`)이 프로파일을 표시한다. init은 템플릿 값으로 채우고 update는 `sync-owned.sh --profile`로 맞춘다. 1단계 `check-context.sh --profile`이 값을 정하며 파일을 바꾸지 않는다. 인자가 없으면 유효한 값을 쓰고, 값이 없거나 무효이거나 안내도가 없으면 묻는다. 인자가 있으면 값과 같거나, 값이 없거나 무효이거나, 안내도가 없을 때 인자를 쓰고, 값과 다르면 묻는다. 인자가 `dev`·`doc`이 아니거나 행이 둘 이상이면 묻는다. 내용으로 추정하지 않고 값을 자동으로 바꾸지 않는다. `profile`은 SSoT 선언과 대조하지 않으며 다른 스킬은 계속 SSoT 선언을 따른다. 건물 repo는 doc 프로파일과 `소스 코드` 선언이 함께 있을 수 있다.
- 버전 고정 `context-loading.md`는 프로파일과 무관하게 SSoT 선언을 따르고(선언이 없으면 소스 코드. 안내도는 있는데 선언을 찾지 못하면 사용자에게 알림), 코드 수정·리뷰·분석 절의 `ide-tools.md`(IDE 도구 우선 규칙, 존재하면 읽음), 원본 문서 작업 절(색인 → 관련 문서 → `ssot_dir` 직접 확인), 테스트 작성·실행 절(`testing-principles.md`·local, 존재하면 읽음)을 둔다. `60_codebase/`는 SSoT 색인이다(dev 소스코드 엔트리포인트·호출 흐름, doc `ssot_dir` 아래 문서 파일 지도).
- update 구조 정합: 정의된 디렉토리 생성, 신규 디렉토리(`70_ledger/`)와 골격 index·`40_domain/glossary.md` 전파(`sync-owned.sh --dirs`. 없을 때만 복사하고, 있으면 `glossary.md`는 그대로 두고 `index.md`는 위 구간 외에 바꾸지 않음), 기존 파일 정리 시 루트 상주 파일(각 index.md, `40_domain/glossary.md`) 제외. 원장 항목은 `- **상태**:` 앵커 값으로 이동 판단. ADR은 `- **상태**:` 값(`대체`·`폐기`면 `superseded/`, `유효`이거나 상태 줄이 없으면 `active/`)으로 이동 판단.
- update 멱등 보강 검사(`check-context.sh` 12종 + AI 판정 2종): `## 프로젝트 규칙` 표 존재·3열, `context-loading.md` 행, `writing-principles.md` 행, dev 표준 선언일 때만 `testing-principles.md`·`ide-tools.md` 행(doc·비표준 선언은 미검사, 같은 실행에서 dev 문구를 넣거나 규칙 섹션·표를 복구하면 선택한 프로파일과 무관하게 함께 보강), `## 프로젝트 도메인`, `profile` 행, `## 에이전트 운영 지침`, 트리 정렬 등. SSoT 선언은 dev·doc 두 표준 문구를 인정하고 그 외 문구만 교체 대상이며, doc 선언이면 `ssot_dir` 행과 dev 표준 문구 4곳(충돌 우선순위, `60_codebase` 설명 3곳) 잔존을 검사한다. doc 문구를 넣은 실행은 `ssot_dir` 자리표시자 행을 함께 보강하고, dev 문구를 doc 문구로 자동 전환하지 않는다. `## 프로젝트 도메인` 골격의 `ssot_dir`·`publish` 행 포함 여부는 선택한 프로파일과 무관하게 SSoT 선언을 따른다. code-map 건물 repo(`.ai/60_codebase/repository.yaml` 존재)는 `소스 코드`로 선언하며(SSoT는 등록 repo의 소스 코드), doc 문구이면 보고만 하고 자동 전환하지 않는다. 4곳은 표준 섹션 안에 있어 아래 표준 구간 최신화가 선언에 맞는 템플릿으로 교체한다. 2열 표는 열 확장만 하고 구버전 기본 행 복원은 별도 마이그레이션 경로다. 헤더가 `파일`·`설명`인 2열 표는 같은 실행에서 표준 행도 검사해 넓힌 표 끝에 보강한다. 섹션 판정은 앞 공백 3칸까지 들여쓴 제목을 같은 섹션으로 본다.
- 표준 구간 최신화: update-4의 조치와 마이그레이션 뒤에 `sync-owned.sh --profile`과 `--context`를 실행한다. `--context`는 표준 섹션 4개를 본문 2번째 줄의 SSoT 선언에 맞는 템플릿 최신본으로 교체하고(`profile` 값과 무관), 없는 섹션은 파일 끝에 템플릿 순서로 더한다. 선언이 표준 문구가 아니면 실패로 보고한다. `## Git 정책` 표도 이 교체로 최신본이 되어 표에 없던 스킬 행이 전파된다(#70 리스크 해소, ADR 0028).
- 구간 교체 규칙(`sync-owned.sh`): 구간 밖 내용과 구간 안의 템플릿에 없는 `###` 소제목은 유지하고, 소제목은 원래 순서대로 템플릿 본문 뒤에 놓는다. 코드 펜스와 HTML 주석 안의 제목은 세지 않고, 앞 공백 3칸까지 들여쓴 제목은 제목으로 센다. 닫히지 않은 코드 펜스·HTML 주석, 같은 제목 둘 이상, 템플릿에 구간 없음은 실패이며 그 파일은 변경 전 내용으로 남고 다른 대상은 계속 처리한다. 출력은 바뀐 대상마다 `교체:`·`추가:`·`실패:` 행이고 update-5가 이를 보고한다. 최신 상태에서 다시 실행하면 출력이 없다. 종료 코드는 0 실패 없음, 1 실패 1건 이상, 2 사용 오류다.
- 두 스킬 모두 `> last updated:` 자동 갱신, 판정 결과(멀티/단독)를 안내도 본문에 기재하지 않는다.
- 로비 `Repos` 4열(path, domain, keywords, status)이 라우팅 신호이며 층 안내도 `## 프로젝트 도메인` 표와 1:1 동기화한다.
- `.ai/` 읽기 우선순위: 10_rules(1순위) → 30_contract(2) → 40_domain(3) → 50_adr(4) → 60_codebase(5) → 70_ledger(6). 90_issues, 99_workspace는 작업 영역이다.
- 산출물 스킬 8종은 `.ai/`가 없어도 동작하도록 접기 기준을 내장한다(ai-workspace 배포에 의존하지 않음).

## 관련 결정

- 정책 [SSoT 원칙과 안내도 라우터](../policies/local/ssot-and-router-principle.md), [ADR 0003](../../50_adr/active/0003-verification-levels-and-determinization.md), [ADR 0007](../../50_adr/active/0007-tech-debt-ledger-location-and-structure.md), [ADR 0008](../../50_adr/active/0008-writing-principles-ssot-distribution.md), [ADR 0022](../../50_adr/active/0022-adr-lifecycle-status-and-superseded-move.md), [ADR 0023](../../50_adr/active/0023-testing-principles-pair-and-consumer-skill-references.md), [ADR 0028](../../50_adr/active/0028-ai-workspace-owned-sections-and-profile-row.md), [ADR 0029](../../50_adr/active/0029-ide-tools-rule-dev-profile-distribution.md)
- 절차 상세는 `ai-workspace/SKILL.md`, `ai-workspace-directory/SKILL.md`와 각 `templates/`·`references/`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #1](https://github.com/scroogy-dev/scroogy-agent-skills/issues/1), [#3](https://github.com/scroogy-dev/scroogy-agent-skills/issues/3), [#5](https://github.com/scroogy-dev/scroogy-agent-skills/issues/5), [#39](https://github.com/scroogy-dev/scroogy-agent-skills/issues/39), [#41](https://github.com/scroogy-dev/scroogy-agent-skills/issues/41), [#61](https://github.com/scroogy-dev/scroogy-agent-skills/issues/61), [#70](https://github.com/scroogy-dev/scroogy-agent-skills/issues/70), [#90](https://github.com/scroogy-dev/scroogy-agent-skills/issues/90), [#114](https://github.com/scroogy-dev/scroogy-agent-skills/issues/114), [#118](https://github.com/scroogy-dev/scroogy-agent-skills/issues/118), [#121](https://github.com/scroogy-dev/scroogy-agent-skills/issues/121), [#122](https://github.com/scroogy-dev/scroogy-agent-skills/issues/122), [#134](https://github.com/scroogy-dev/scroogy-agent-skills/issues/134), [#136](https://github.com/scroogy-dev/scroogy-agent-skills/issues/136)
- [PR #40 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/40), [PR #91 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/91)

</details>
