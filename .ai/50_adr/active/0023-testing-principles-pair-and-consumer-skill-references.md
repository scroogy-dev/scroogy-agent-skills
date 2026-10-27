---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/122
related_jira:
last_harvested: 2026-10-27
---

# ADR: 테스트 실행 원칙을 버전 고정·사용자 관리 파일 쌍으로 배포하고 소비 스킬 3종이 조건부로 직접 참조하는 결정

- **상태**: 유효

## 결정

- 테스트를 어느 층·수단·환경으로 실행할지는 `10_rules`의 파일 쌍에 둔다. ADR 0008의 `writing-principles` 쌍 구조를 테스트 실행 원칙으로 넓힌 것이다 (#122).
  - **`testing-principles.md`**: 버전 고정 파일이다. 1행 SYNCED 헤더와 2행 버전 주석(1.0.0)을 두고 update-1이 항상 덮어쓴다. `## 공통 원칙`에 9개 원칙(실행 환경, 대상 환경과 인증, 화면 캡처, 탐색과 판정 분리, 반복 금지, 전제 조건과 판정 불가, 시험 데이터, 환경 되돌리기, 실행 셸과 출력 형식)을 둔다.
  - **`testing-principles-local.md`**: 사용자 관리 파일이다. update-1은 없을 때만 복사하고, 공통 파일과 충돌하면 local이 우선한다. 템플릿은 `## 테스트 층`·`## 대상 환경`·`## 실행 셸`·`## 기기 확인 (모바일 앱 repo만)` 4개 섹션과 두 표 헤더만 두고, 값은 비우며 예시는 HTML 주석으로 든다.
  - **dev 프로파일 전용**: 두 파일은 `templates/dev/`에 둔다. init은 dev 템플릿 일괄 복사에 포함되어 절차 변경이 없다.
- 파일 쌍은 실행 층·수단·환경만 정한다. 무엇을 어느 문서·Task에서 검증할지는 ADR 0003(검증 레벨)과 ADR 0019(테스트 관점·Task별 배치)가 그대로 정한다.
- 에이전트가 파일 쌍으로 안내받는 경로 두 곳을 잇는다.
  - **context-loading**: shared `context-loading.md`의 "존재하면 읽는다" 목록에 `## 테스트 작성·실행 시` 섹션을 두어 두 파일을 가리킨다. 파일이 없는 doc repo에서는 건너뛴다.
  - **안내도 규칙 표**: dev AI-CONTEXT 템플릿 `## 프로젝트 규칙` 표에 `testing-principles.md` 행을 둔다. update-4 멱등 보강 검사(`check-context.sh`)는 본문 2번째 줄이 dev 표준 SSoT 선언일 때만 이 행의 누락을 보고하고, doc 선언·비표준 선언 repo에서는 검사하지 않는다. 같은 실행에서 SSoT 선언 행이나 건물 repo 선언 행의 조치로 dev 문구를 넣었으면 이 행도 함께 보강한다.
- 소비 스킬 3종이 두 파일을 조건부로 직접 참조한다. 우선순위는 local > `testing-principles.md` > 스킬 내장 기본값(현재 템플릿·절차)이고, 파일이 없으면 현재 동작을 유지한다.
  - **issue-work**: plan Task 테스트 `[D]`의 러너 호출·출력 판독·실행 셸은 local 층 표를 따르고, spec 완료의 정의 `[D]`의 인수 테스트 층은 층 표에서 고른다. 기기 확인 Task는 두지 않는다. plan 템플릿의 테스트 배치 문단도 local 층 표를 가리킨다.
  - **issue-audit**: 0단계 7항에서 두 파일을 읽는다. 1단계 DoD `[D]` 재실행과 `--plan` 관점 2(가짜 `[D]` 사전 판별)는 local의 실행 셸로 실행하고, 층 표의 전제 조건이 갖춰지지 않으면 판정 불가(N/A)로 둔다.
  - **git-qa**: 4단계에서 PR이 속한 repo의 대상 브랜치 local 파일을 `gh api`로 읽는다. 그 항목의 동작을 검사하는 테스트를 찾았고 그 테스트가 층 표의 러너로 실행될 때만 항목 끝의 증빙 문구 대신 `— 자동 테스트로 덮음(<러너>)`을 붙인다. 테스트를 찾지 못하거나 파일을 읽지 못하면 표시하지 않는다.
- 소비 스킬의 참조 문장은 각 스킬 러너의 조항 구조 검사로 고정한다. 앵커 문구가 제자리에 있는지와 문구를 지운 사본이 격추되는지를 보고, 조건·우선순위의 뜻은 교차모델 감사가 채점한다. git-qa는 러너가 없어 `git-qa/tests/run-tests.sh`를 새로 둔다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 배포하는 `10_rules`에 테스트 실행(러너와 출력 판독, 시뮬레이터·실기기, 대상 환경과 인증, 셸, 화면 캡처, 되돌릴 설정)을 정하는 칸이 없었다. 그래서 규칙이 repo의 테스트 디렉토리 README와 특정 AI 도구의 메모리에 흩어졌고, 메모리는 그 도구만 읽어 다른 벤더 감사 모델이 보지 못했다 (#122 배경).
- 공통 원칙은 겪은 사례에서 나왔다. 개인 실기기 캡처에 연락처와 다른 파일이 찍혔고, zsh·`grep` 래퍼와 `node --test`의 비TAP 출력이 메모리에만 있어 계획 감사에서 다시 올라왔다. 자동 테스트가 덮는 문구를 실기기에서 네 번 확인했고, 실기기 조작용 설정·도구 앱·시험 파일을 이슈를 마칠 때 사람이 되돌렸다.
- 쌍 구조를 따른 이유: 공통 원칙은 여러 repo에 같아 버전 고정으로 배포하고, 층 표·대상 환경은 repo마다 달라 사용자 관리로 둔다. ADR 0008의 버전 고정·local 구분, 라우팅 두 곳, 스킬 조건부 참조를 그대로 써서 새 배포 규칙을 만들지 않았다.
- 원칙 본문은 모바일 전용 표현을 "로컬 재현 환경"으로 일반화하고, 기기 확인은 local의 선택 섹션으로 뒀다. 파일 쌍은 다른 repo로 복사되므로 이 repo의 ADR·이슈 번호를 본문 근거로 쓰지 않는다. 기기 이름 같은 개인 정보는 사용자 전역 지침(repo 밖)에 둔다.
- 행 검사를 dev 표준 선언으로 한정한 이유: 파일 쌍이 dev 전용이라 doc repo에 행을 넣으면 없는 파일을 가리킨다. 비표준 선언은 SSoT 선언 행이 이미 보고하고 어느 프로파일 문구로 바뀔지는 그 조치가 정하므로, 이 행 검사에 소스 코드 폴백을 적용하지 않았다(이슈 본문 범위 결정).
- 같은 실행의 행 보강(2026-10-26 계획 단계 결정): 헬퍼를 한 번만 실행하므로 그 실행에서 dev 문구를 넣으면 행 검사가 돌지 않는다. doc 문구의 `ssot_dir` 행 보강과 같은 방식으로 선언 조치가 행을 함께 넣는다.
- 소비 스킬 연결을 같은 이슈에서 한 이유: ADR 0008 근거(#60)에서 SKILL.md → context-loading → 규칙 파일의 2단계 간접 참조가 실행 시점에 끊긴 선례가 있다.
- git-qa 덮음 판정을 테스트를 찾은 항목으로 좁힌 이유(2026-10-26 사용자 결정): 층 유형만 맞는 항목까지 덮음으로 보면 테스트가 없는 동작이 수동 확인에서 빠진다. 표시가 증빙 문구를 대체하는 이유는 둘을 함께 두면 수동 캡처를 할지가 모호해지기 때문이다.
- 참조 문장을 러너로 고정한 이유(계획 감사 F-2 보정): ADR 0019는 구현 테스트를 그 기능을 만드는 Task에 둔다. 소비 스킬 3종은 SKILL.md 문장이 곧 동작이라 조항 구조 검사가 구현 테스트다. ADR 0008의 `writing-principles` 조건부 참조 문장은 ADR 0019 이전 변경이라 검사를 소급해 더하지 않았다.
- 같은 이슈에서 원장 K-0015(SSoT 선언을 찾지 못하면 경고 없이 폴백)를 함께 해소했다. 선언 읽기 표준 문장의 결정이라 ADR 0020의 일부 변경으로 기록했다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 기존 `coding-convention.md`에 테스트 절을 두는 안: 사용자 관리 파일이라 공통 원칙을 배포할 수 없고 repo마다 같은 원칙을 다시 써야 해 배제.
- `40_domain/policies/common/`에 두는 안: 동기화 칸은 있지만 채우는 절차가 없고, AI 행동 규칙은 1순위인 `10_rules`가 맞아 배제.
- 사용자 전역 지침에만 두는 안: 그 AI 도구만 읽어 다른 벤더 감사 모델과 다른 사람의 세션에는 적용되지 않아 배제.
- 기기 확인을 plan 고정 Task로 두는 안: 실기기 확인은 이슈 진행과 무관하게 사용자가 요청할 때만 해 Task로 고정할 시점이 없어 배제.
- 인증 토큰을 AI에 전달하는 안: 인증 정보 유출 경로가 되어 배제. 사용자가 로그인하고 AI는 그 세션을 이어 쓴다.
- 소비 스킬 연결을 후속 이슈로 미루는 안: 2단계 간접 참조가 끊긴 선례(#60)가 있어 배제.
- 파일 이름 `verification-principles`: ADR 0003의 검증 레벨 용어와 겹쳐 `testing-principles`로 대체.
- doc 프로파일에도 배포하는 안: 문서만 있는 repo에는 테스트 층이 없어 불필요.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #122 ai-workspace: 테스트 원칙 파일 쌍(testing-principles·local) 도입과 안내도·context-loading 라우팅 연결](https://github.com/scroogy-dev/scroogy-agent-skills/issues/122)
- 규칙 본문: [`.ai/10_rules/testing-principles.md`](../../10_rules/testing-principles.md), [`.ai/10_rules/testing-principles-local.md`](../../10_rules/testing-principles-local.md)
- 관련 결정: [ADR 0003 검증 레벨](./0003-verification-levels-and-determinization.md), [ADR 0008 작성 원칙 SSoT 배포](./0008-writing-principles-ssot-distribution.md), [ADR 0019 테스트 관점과 Task별 배치](./0019-test-perspectives-and-task-level-placement.md), [ADR 0020 doc SSoT와 선언 폴백 알림](./0020-doc-ssot-original-documents-and-publishing-deferred.md)

</details>
