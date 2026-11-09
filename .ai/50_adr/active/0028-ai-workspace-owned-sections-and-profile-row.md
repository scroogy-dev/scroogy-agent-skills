---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/134
related_jira:
last_harvested: 2026-11-05
---

# ADR: ai-workspace update가 스킬 소유 파일·구간을 최신본으로 맞추고 안내도 `profile` 행으로 프로파일을 정하는 결정

- **상태**: 유효

## 결정

- update가 다루는 대상을 소유에 따라 셋으로 나눈다 (#134).
  - **파일 단위 최신본**: 실행마다 템플릿으로 덮어쓴다. 버전 고정 파일(`context-loading.md`, `writing-principles.md`, dev 전용 `testing-principles.md`)과 `70_ledger/ledger-entry-template.md`가 대상이다.
  - **구간 단위 교체**: 정한 구간만 템플릿 최신본으로 바꾸고, 없는 섹션은 파일 끝에 템플릿 순서로 더한다. `50_adr/index.md`의 `## 수명 주기`, `70_ledger/index.md`의 머리말과 `## 수명 주기`, `AI-CONTEXT.md` 표준 섹션 4개(`.ai 디렉토리 구조`, `에이전트 운영 지침`, `Git 정책`, `이슈 작업 워크플로우`)가 대상이다. `## 에이전트 운영 지침`이 없으면 update-4의 기존 삽입 규칙이 먼저 넣는다.
  - **사용자 작성**: 내용을 바꾸지 않는다. 사용자 관리 규칙 파일(`architecture.md`, `coding-convention.md`, `document-convention.md`, `file-change-policy.md`, `*-local.md`)과 `40_domain/glossary.md`, 각 `index.md`는 없을 때만 복사한다. 구간 밖 내용, 구간 안의 템플릿에 없는 `###` 소제목, `AI-CONTEXT.md`의 나머지 섹션도 유지한다. `## 프로젝트 규칙`은 update-4의 행 검사가 표준 행만 알파벳순 자리에 보강하고, 행 순서가 어긋나면 정렬을 권유해 승인한 경우에만 행 단위로 재정렬한다.
- 덮어쓰는 대상의 템플릿에 직접 고치면 update 때 사라진다는 안내 주석을 한 줄씩 둔다. 원장 템플릿, 두 index의 `## 수명 주기`, dev·doc `AI-CONTEXT.md` 표준 섹션 4개에 두고 `70_ledger/index.md` 머리말에는 두지 않는다. 덮어쓰기 전에 사용자에게 확인하지 않는다.
- 구간 교체와 `profile` 행 쓰기는 헬퍼 `ai-workspace/scripts/sync-owned.sh`가 맡는다.
  - **호출 위치**: `--dirs`는 update-3이 하위 디렉토리를 만든 뒤, `--profile`과 `--context`는 update-4의 조치와 마이그레이션을 끝낸 뒤에 호출한다.
  - **출력**: 바뀐 대상마다 `교체:`·`추가:`·`실패:` 행을 내고, 바뀐 내용이 없으면 출력하지 않는다. update-5가 이 행을 보고한다.
  - **실패**: 닫히지 않은 코드 펜스·HTML 주석, 같은 제목 둘 이상, 템플릿에 구간 없음, `70_ledger/index.md`에 `##` 제목 없음은 실패다. 실패한 파일은 변경 전 내용으로 남고 다른 대상은 계속 처리한다.
  - **종료 코드**: 0은 실패 없음, 1은 실패 1건 이상, 2는 사용 오류다. update는 1이면 계속하고 2이면 그 호출을 중단하고 보고한다.
- 표준 섹션의 템플릿은 본문 2번째 줄의 SSoT 선언으로 고른다. dev 표준 문구면 dev 템플릿, doc 표준 문구면 doc 템플릿을 쓰고, 둘 다 아니면 고를 근거가 없어 실패로 보고한다.
- `profile` 행과 SSoT 선언은 역할을 나눈다. 두 값을 대조하지 않고, 건물 repo는 doc 프로파일과 `소스 코드` 선언이 함께 있을 수 있다.
  - **`profile` 행**: `## 프로젝트 도메인` 첫 표의 `dev`·`doc` 값이다. ai-workspace가 배포할 프로파일을 표시한다. init은 템플릿 값으로 채우고, update는 1단계에서 정한 값으로 `sync-owned.sh --profile`이 맞춘다. `check-context.sh`가 행 누락, 무효 값, 행 둘 이상을 보고한다.
  - **SSoT 선언**: 진실의 원천을 정한다. 다른 스킬은 계속 이 선언을 따르고 `profile`을 판단 기준으로 쓰지 않는다.
- 1단계는 `check-context.sh --profile`로 프로파일을 정한다. 내용으로 추정하지 않고 안내도 값을 자동으로 바꾸지 않는다. 파일도 바꾸지 않는다.
  - **인자 없음**: 유효한 값을 쓰고, 값이 없거나 무효이거나 안내도가 없으면 묻는다.
  - **인자 있음**: 값과 같거나, 값이 없거나 무효이거나, 안내도가 없으면 인자를 쓴다. 값과 다르면 묻는다.
  - **항상 묻는 경우**: 인자가 `dev`·`doc`이 아니거나 `profile` 행이 둘 이상이면 묻는다. 행이 둘 이상이면 답한 값으로 update-4가 한 행으로 정리한다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 계기: 버전 고정 파일 3종이 최신인 repo에서 원장 템플릿만 #118 이전 문구로 남아 있었다. update-3이 항목 템플릿을 `index.md`와 묶어 사용자 작성분으로 처리했기 때문이다.
- 비교 결과: 다른 repo 10곳을 비교했고 그중 4곳에 `70_ledger`가 있었다.
  - `## 수명 주기`(#121)는 10곳의 `50_adr/index.md`에 모두 없었다. 섹션이 없으면 context-harvest가 결정 변경 처리를 보류한다.
  - 원장 템플릿은 #118 문구 1행만 달랐고, `70_ledger/index.md`의 머리말과 `## 수명 주기`는 과거 공식 버전과 같았다.
  - 표준 섹션 4개도 모두 과거 공식 버전과 같았다. 사용자 수정분이 없어 덮어쓰기 전 확인을 두지 않았다. `issue-workflow.md`도 확인 없이 덮어쓰는 선례다.
  - 한 repo의 `50_adr/index.md`에 `Active ADR`·`Superseded ADR` 섹션이 있어 구간 단위 교체가 필요했다.
- `## Git 정책` 미검사 리스크(#70)의 해소 경위: #70은 템플릿과 이 repo 안내도의 표에 행을 더했지만, update-4가 이 표를 검사하지 않아 기존 설치 repo에 전파되지 않았고 명세에 미해결 리스크로 남았다. 비교한 한 repo의 표에는 `/git-pr-feedback`, `/git-review-quiz` 행이 없었다. 행 검사를 늘리면 스킬을 더할 때마다 검사도 늘어나므로, 표준 섹션 전체를 교체해 앞으로 더해질 행까지 전파되게 했다.
- ADR 0022와의 관계: 0022 근거의 "설치본에 `index.md`가 있으면 수명 주기 섹션이 전파되지 않는다"는 이 결정으로 더는 맞지 않다. 0022의 context-harvest 보류 규칙은 update를 아직 실행하지 않은 repo에 필요해 그대로 둔다.
- ADR 0007·0008과의 관계: 0007의 원장 골격 배포를 원장 템플릿 최신화와 index 구간 교체로, 0008의 버전 고정 덮어쓰기를 원장 템플릿과 구간 단위로 넓혔다. 두 ADR의 결정 항목은 바뀌지 않아 그대로 유효하다.
- 헬퍼로 분리한 이유: 구간 교체는 같은 입력에 같은 결과가 나와야 하고 실패를 보고해야 해서 [architecture.md 디자인 원칙](../../10_rules/architecture.md)의 분리 기준을 충족한다. 테스트 위치는 [ADR 0001](./0001-skill-deterministic-helper-test-convention.md)을 따른다.
- 템플릿을 SSoT 선언으로 고르는 이유: 표준 섹션의 충돌 우선순위와 `60_codebase` 설명은 SSoT 값에 따라 갈린다. `소스 코드`로 선언한 건물 repo는 doc 프로파일이어도 dev 템플릿 문구가 맞다.
- 판정 근거가 없으면 값을 고르지 않는다(2026-11-04 사용자 결정). 그래서 `profile` 행 둘 이상은 값이 같아도 묻고, 표준 문구가 아닌 SSoT 선언의 `--context`와 닫히지 않은 코드 펜스·HTML 주석은 실패로 처리한다.
- 인자를 쓰는 경우를 넓게 둔 이유: 인자는 사용자가 명령으로 정한 결정이다. 행이 없거나 값이 무효이면 대조할 값이 없어 인자를 쓰고, 값과 다를 때만 어느 쪽이 맞는지 묻는다.
- `## 프로젝트 규칙`을 표준 섹션에서 뺀 이유: 사용자 행이 섞여 있어 통째로 교체하면 사라진다.
- 원장 K-0018을 함께 해소하지 않은 이유: 건물 repo의 규칙 표 복구 경로가 남아 원인이 사라지지 않는다.
- 2026-11-09 일부 변경(#138): 표준 행을 표 끝에 붙이면 알파벳순인 템플릿 표와 순서가 달라져, `파일` 셀 기준 알파벳순 자리에 넣게 했다. 이전 update로 순서가 어긋난 기존 표는 사용자가 정한 순서일 수 있어 자동으로 바꾸지 않고, 디렉토리 트리 정렬처럼 권유해 승인한 경우에만 재정렬한다. `## 프로젝트 규칙`이 사용자 작성 구간이라는 결정은 바뀌지 않는다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- index 파일 전체 덮어쓰기: 파일 목록과 항목 목록, 한 repo의 `Active ADR` 섹션이 사라져 배제.
- 보존 구간만 지정하고 나머지를 템플릿 기준으로 맞추기: 사용자가 추가한 섹션을 보호하려면 예외 규칙이 더 필요해 배제.
- `## 수명 주기`를 AI 절차로 교체: 같은 입력에 같은 결과를 보장하고 검증과 오류 보고를 해야 해 배제.
- `> profile: dev`를 본문 3번째 줄에 두기: `## 프로젝트 도메인` 표가 이미 프로파일별 행을 담고 표 행 검사 코드도 있어 배제.
- SSoT 선언으로 프로파일 대신하기: 건물 repo는 doc 프로파일이어도 `소스 코드`로 선언해 배제.
- `profile`과 SSoT 선언의 일치 검사, 다른 스킬의 판단 기준을 `profile`로 변경: 같은 건물 repo 사례로 불일치가 정상이고 스킬은 계속 SSoT 선언을 따라 배제.
- 덮어쓰기 전 사용자 확인: 비교한 repo에 사용자 수정분이 없고 `issue-workflow.md`도 확인 없이 덮어써 배제.
- SYNCED 머리글과 버전 표기: 안내 주석으로 충분하고 섹션 단위 구간에는 적용하기 어려워 배제.
- `30_contract`·`40_domain`·`60_codebase`의 `index.md` 교체: 스킬이 고정한 정책 구간이 없고 `60_codebase`는 code-map이 머리말까지 고쳐 써서 배제.
- `check-context.sh`의 doc 선언 dev 문구 잔존 검사 제거: `--context`가 같은 구간을 덮어써 조치는 중복되지만, 검사와 테스트를 지우는 변경은 범위 밖이라 유지.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #134 ai-workspace: update가 스킬 소유 구간을 최신본으로 반영하고 안내도에 프로파일을 표시한다](https://github.com/scroogy-dev/scroogy-agent-skills/issues/134)
- [Issue #70 Git 정책 표에 git-pr-feedback 행 추가](https://github.com/scroogy-dev/scroogy-agent-skills/issues/70)
- 일부 변경: [Issue #138](https://github.com/scroogy-dev/scroogy-agent-skills/issues/138)
- 절차와 헬퍼: [`ai-workspace/SKILL.md`](../../../ai-workspace/SKILL.md), [`sync-owned.sh`](../../../ai-workspace/scripts/sync-owned.sh), [`check-context.sh`](../../../ai-workspace/scripts/check-context.sh)
- 관련 결정: [ADR 0001 헬퍼 테스트 위치](./0001-skill-deterministic-helper-test-convention.md), [ADR 0007 원장 위치와 구조](./0007-tech-debt-ledger-location-and-structure.md), [ADR 0008 작성 원칙 SSoT 배포](./0008-writing-principles-ssot-distribution.md), [ADR 0020 doc SSoT와 건물 repo 선언](./0020-doc-ssot-original-documents-and-publishing-deferred.md), [ADR 0022 ADR 수명 주기](./0022-adr-lifecycle-status-and-superseded-move.md), [ADR 0023 테스트 원칙 파일 쌍](./0023-testing-principles-pair-and-consumer-skill-references.md)

</details>
