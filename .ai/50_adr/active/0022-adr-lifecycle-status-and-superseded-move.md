---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/121
related_jira:
last_harvested: 2026-10-25
---

# ADR: ADR의 일부 변경·대체·폐기를 수명 주기로 나누고 상태 줄로 superseded 이동을 판정하는 결정

- **상태**: 유효

## 결정

- ADR 처리 규칙은 `50_adr/index.md`의 `## 수명 주기` 섹션에 둔다. 이슈 작업 중 직접 쓰는 ADR과 context-harvest가 만드는 ADR이 모두 이 섹션을 따른다. ai-workspace shared 템플릿과 이 repo 사본을 함께 고친다 (#121).
- 경우 4종을 아래처럼 처리한다.
  - **새 결정이 기존 결정을 바꾸지 않음**: 새 ADR을 쓰고 기존 ADR은 `active/`에 그대로 둔다.
  - **결정 항목 일부 변경**: 같은 ADR을 제자리에서 고치고 근거에 변경 날짜·이슈 번호·경위를 적는다.
  - **결정 항목 전체 대체**: 옛 ADR 상태를 `대체(ADR <번호>)`로 바꿔 `superseded/`로 옮기고, 새 ADR 근거에 대체 대상을 적는다.
  - **대체 없는 폐기**: 옛 ADR 상태를 `폐기(이슈 #N)`로 바꾸고 근거에 사유를 적어 `superseded/`로 옮긴다.
- 일부 변경과 대체의 경계는 결정 섹션으로 정한다. 결정 항목이 하나라도 유효하면 일부 변경이다.
- 대체와 폐기는 위치를 `superseded/` 하나로 두고 상태 줄로 나눈다.
  - **형식**: 제목 아래 `- **상태**:` 한 줄이며 원장 항목과 같은 형식이다. context-harvest ADR 템플릿 제목 아래에 `- **상태**: 유효`를 둔다.
  - **값**: `유효`·`대체(ADR <번호>)`·`폐기(이슈 #N)` 중 하나다.
  - **상태 줄이 없는 ADR**: `유효`로 본다. 기존 ADR 0001~0021은 고치지 않는다.
- `superseded/`의 ADR은 제약으로 쓰지 않고 이력을 확인할 때만 읽는다. ADR index와 `context-loading.md`의 "정책·ADR은 코드와 동등한 제약" 문장에 이 제외를 적는다. `context-loading.md`는 템플릿과 repo 사본을 바이트 단위로 같게 둔다.
- ADR을 `superseded/`로 옮기면 아래를 고친다.
  - **index 행**: 파일 목록에서 그 ADR 행을 `superseded/` 행 아래로 옮기고 경로를 `superseded/<파일>`로 고친다.
  - **들어오는 링크**: ADR 0021의 정의 문장을 대상 경로만 바꿔 복제한다. 범위는 `.ai/` 아래 문서(`.ai/90_issues/archive/` 제외)다. 대상은 `50_adr/active/<파일>` 경로 링크와 ADR 파일끼리의 같은 디렉토리 링크(`./<파일>`·`<파일>` 두 형식)이며, 옮긴 ADR이 `active/`에 남은 ADR을 가리키는 링크도 포함한다. 상대 경로 깊이는 링크가 있는 문서 위치에서 다시 계산한다.
  - **확인 수단**: 옮긴 ADR 파일명으로 `.ai/`(`.ai/90_issues/archive/` 제외)를 검색해 옛 경로를 가리키는 링크가 0건인지 확인한다. 끊긴 ADR 링크 검사 헬퍼는 두지 않는다(보류).
- ai-workspace update-3 "기존 파일 정리"의 `50_adr/` 판정은 상태 줄 값으로 한다. `대체(ADR <번호>)`·`폐기(이슈 #N)`이면 `superseded/`, `유효`이거나 상태 줄이 없으면 `active/`다. 본문 키워드(`superseded`·`deprecated`·`replaced`) 판정은 없앤다.
- context-harvest 5단계는 기존 ADR을 갱신할 때 상태 줄을 그대로 두고, 상태 값은 수명 주기 처리로만 바꾼다. 수집한 결정이 기존 ADR의 결정을 바꾸면 index `## 수명 주기`에 따라 처리한다.
  - **섹션이 없는 index**: 기존 ADR을 옮기지 않고 내용·상태 줄·`last_harvested`도 바꾸지 않으며 새 ADR도 만들지 않는다. 6단계 결과 보고에 결정 변경 후보로 적는다.
  - **다음 증분 수집**: 같은 소스는 이 ADR의 `last_harvested` 이후 변경분부터 다시 판정한다.
- update-3 "기존 파일 정리"의 이동 판단 기준 표(디렉토리 5행)와 루트 상주 파일 제외, `legacy/` 이동을 회귀 fixture `ai-workspace/tests/fixtures/update3-file-cleanup/`가 덮는다. 모의 실행 채점은 `[QD]`이고, 러너는 케이스 쌍과 판단 기준 표 대조를 `[D]`로 본다. 원장 K-0001은 이 fixture로 해소한다.
- 두 스킬 러너에 이 결정의 구조 검사를 둔다. ai-workspace는 수명 주기 섹션·update-3 판정 행·fixture 대상 행·context-loading 제약 문장을, context-harvest는 템플릿 상태 줄과 5단계 문장을 검사한다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 이슈 작성 시점의 규칙은 index 설명 한 줄("대체된 결정 (대체한 ADR 번호를 문서 내에 명시)")뿐이었다. ADR 템플릿에는 상태와 대체 관계를 적을 자리가 없었고, `superseded/`로 옮긴 ADR은 0건이다.
- ADR 본문 기록으로 본 처리 관행은 아래와 같다. 전체 대체와 대체 없는 폐기는 사례가 없어 최소 규칙만 둔다.
  - **기존 결정 유지, 새 결정 추가**: 새 ADR을 쓰고 기존 ADR은 `active/`에 둔다(0018과 0007, 0019와 0003).
  - **결정 일부 번복**: 같은 ADR 본문을 고치고 근거·대안에 경위를 적는다(0007 원장 위치, 2026-08-02).
  - **초안 단계에서 버린 안**: 대안 섹션에 기각으로 적는다(0020 위키 원본 추적안). 결정이 된 적이 없어 수명 주기 경우에 넣지 않았다.
- 키워드 판정은 폐기와 대체를 구분하지 못하고, 유효한 ADR도 본문 낱말로 `superseded/`에 보낸다. 0007("ADR 수명 주기(active/superseded)"), 0018("대체(superseded)하지 않는다"), 0021(`superseded/`로 옮길 때의 링크 갱신)이 그 예다.
- 처리 기준을 index에 둔 이유: ADR은 이슈 작업과 context-harvest 두 경로로 생기고, 어느 경로든 ADR을 다룰 때 index를 먼저 읽는다. 원장 index의 수명 주기 섹션이 선례다.
- 대체와 폐기를 한 위치에 둔 이유: 둘 다 유효하지 않은 결정이라 읽는 쪽 처리가 같다. 둘의 차이는 상태 값에 적는다.
- 상태 줄 없는 옛 ADR을 `active/`로 보내는 이유(2026-10-25 사용자 결정): 상태 줄이 없으면 `유효`로 본다는 정의와 판정이 같아진다. 키워드 판정을 남기면 위 오분류가 남고, `legacy/`로 보내면 유효한 결정이 제약에서 빠진다.
- `context-loading.md`에 제외를 적은 이유(2026-10-25 사용자 결정): 1순위 규칙 문서의 "ADR은 제약" 문장이 `superseded/`까지 포함하면 index의 읽기 규칙과 어긋난다. 이 파일은 update-1이 항상 덮어써 설치본에도 전파된다.
- 링크 갱신 문장을 복제한 이유: ADR 0021이 #121 복제를 정했고, 스킬 밖 문서끼리도 정의 문장을 같게 두는 근거는 ADR 0002다.
  - `superseded/`는 `active/`와 깊이가 같아 옮긴 ADR 안의 `../../` 링크는 그대로 유효하다. 고칠 대상은 같은 디렉토리 링크다.
  - 기존 ADR 사이 링크는 `./<파일>` 형식(0007·0018·0019·0020·0021)과 `<파일>` 형식(0002·0003·0004·0006·0010·0012)이 섞여 있어 두 형식을 모두 대상으로 적었다.
- 링크 확인을 파일명 검색으로 한 이유(2026-10-25 사용자 결정): 규칙이 스킬 밖(ADR index)에 있어 헬퍼를 둘 스킬이 정해지지 않았고, `superseded/` 이동 사례가 0건이다.
- context-harvest의 섹션 부재 대비 이유:
  - ai-workspace update는 설치본에 `index.md`가 있으면 덮어쓰지 않아 기존 설치 repo에는 수명 주기 섹션이 전파되지 않는다.
  - 섹션이 없으면 일부 변경과 대체의 경계도 없어 결정 변경 전체를 보류한다. 새 ADR만 만들면 상태 줄 없는 옛 ADR과 어긋나는 결정이 둘 다 `active/`에서 제약이 된다.
  - `last_harvested`를 바꾸지 않아야 다음 증분 수집이 같은 변경분을 다시 본다. 같은 소스에서 문서가 여럿일 때 어느 `last_harvested`로 거를지 기존 SKILL.md가 정하지 않아 재판정 시점을 이 ADR의 값으로 고정했다. 보류 범위와 재판정 시점은 계획 감사 F-1을 반영해 정했다.
- K-0001을 함께 해소한 이유(2026-10-25 사용자 결정): 이번 판정 변경이 재검토 조건("update-3 이동 판단 기준 재수정 시")을 충족했다. 수용 사유가 요구한 대칭에 따라 fixture가 판단 기준 표 5행과 루트 상주 파일·`legacy/`를 함께 덮는다. update-3은 AI가 수행하는 절차라 모의 실행은 update-4 fixture처럼 `[QD]`다.
- 기존 ADR 21건의 대체·폐기 재분류는 이슈 제외 범위다. 상태 줄이 없으면 `유효`로 보므로 고칠 이유도 없다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- `deprecated/` 디렉토리 신설: 위치만 보고 대체와 폐기를 나눌 수 있다. 대신 ai-workspace 구조 표, update 판정, AI-CONTEXT 트리, 템플릿 index를 함께 바꿔야 하고, 상태 줄이 있으면 얻는 것이 적어 배제.
- 상태를 frontmatter 필드로 두는 안: frontmatter는 context-harvest 증분 수집(`source_url`·`last_harvested`)이 쓰는 영역이고 원장 항목과 표기가 달라져 배제.
- 처리 규칙을 issue-work 이슈 완료 단계에 두는 안: ADR은 issue-work 밖(context-harvest, 수동 작성)에서도 생겨 배제.
- 상태 줄 없는 옛 ADR에 키워드 판정을 유지하는 안: 0007·0018·0021 오분류가 남아 배제.
- 상태 줄 없는 옛 ADR을 `legacy/`로 옮기는 안: 유효한 결정이 판단 불가로 밀려 제약에서 빠져 배제.
- `check-ledger-links.sh`를 ADR 링크까지 넓히는 안: 원장 항목 파일명(`K-<4자리 숫자>-`)만 판정하는 헬퍼이고, 사본 3개가 ADR 이동 절차가 없는 issue-work·git-pr·git-pr-feedback에 있어 배제.
- 끊긴 ADR 링크 검사 헬퍼를 새로 두는 안: 둘 스킬이 정해지지 않았고 이동 사례가 0건이라 보류. 첫 `superseded/` 이동에서 링크 갱신 누락이 관측되면 다시 본다.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #121 ai-workspace·context-harvest: ADR 처리 규칙 도입 (일부 변경·대체·폐기 구분, superseded 이동 기준, 상태 표기)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/121)
- 규칙: [ADR index `## 수명 주기`](../index.md), [`context-loading.md`](../../10_rules/context-loading.md)
- 관련 결정: [ADR 0002 스킬 독립성과 의도적 중복](./0002-skill-independence-intentional-duplication.md), [ADR 0007 원장 위치와 구조](./0007-tech-debt-ledger-location-and-structure.md), [ADR 0018 원장 재검토·해소 계기](./0018-ledger-proactive-review-and-resolve-timing.md), [ADR 0021 원장 archive 이동 시 들어오는 링크 갱신](./0021-ledger-archive-move-link-update.md)
- 원장 항목: [K-0001 update-3 회귀 fixture 부재](../../70_ledger/active/K-0001-update3-fixture-absent.md) (이 결정의 fixture로 해소)

</details>
