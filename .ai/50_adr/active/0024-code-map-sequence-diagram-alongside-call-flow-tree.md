---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/126
related_jira:
last_harvested: 2026-10-31
---

# ADR: code-map 호출 흐름 트리 다음에 Mermaid 시퀀스 다이어그램을 함께 두는 결정

- **상태**: 유효

## 결정

- code-map의 호출 흐름 문서는 트리 코드 블록 바로 다음에 `### 시퀀스 다이어그램` 소제목과 Mermaid `sequenceDiagram` 블록을 둔다 (#126).
  - **local**: 상세 호출 흐름 문서(`<feature>/<action>-call-flow.md`)의 `## How` 안에 둔다. 참여자는 트리 노드의 호출 주체(클래스)다.
  - **global**: `service-call-flows.md`의 흐름별 섹션마다 둔다. 참여자는 서비스(리포) 단위다.
- 트리는 누가 누구를 호출하는지 보여 주고, 시퀀스 다이어그램은 호출 순서·응답·동기와 비동기 구분·분기와 반복·트랜잭션 경계처럼 트리에 없는 정보를 보여 준다. 참여자는 트리 노드와 같게 두고 처음 호출되는 순서로 놓으며, 디렉토리 트리 정렬 규칙은 참여자 순서에 적용하지 않는다.
- 두 모드가 따르는 작성 규칙은 `code-map/SKILL.md`의 `## 시퀀스 다이어그램 작성 규칙` 한 곳에 두고, `references/local.md`·`references/global.md`는 링크로 가리킨다. 응답은 `-->>`, 동기 호출은 `->>`, 호출한 쪽이 응답을 기다리지 않는 호출은 `-)`, 분기·반복은 `alt`·`opt`·`loop`, 트랜잭션 경계는 `rect` 또는 `Note`로 적고, 메시지 문구에 `;`와 `#`를 쓰지 않는다.
- 기존 색인은 바뀐 기능만 반영한다. build·rebuild는 트리와 시퀀스를 함께 만들고, sync는 소스가 바뀐 기능의 문서에서 둘을 함께 갱신하며 시퀀스가 없는 기존 문서에는 이때 추가한다. 한꺼번에 채우려면 rebuild를 쓴다.
- `check`는 누락·불일치를 새 태그 없이 결과 보고의 건수로 알린다.
  - **local**: 3단계 점검 표에 시퀀스 누락(`## How`에 `mermaid` 블록이 없는 문서)과 트리·시퀀스 불일치(참여자가 트리 노드의 호출 주체와 맞지 않는 문서) 행을 둔다.
  - **global**: 4단계 `아키텍처 문서 유효성` 행이 시퀀스를 포함하고, local 기준을 `## How` 대신 흐름 섹션마다 따로 적용해 흐름 단위로 센다.
- 긴 흐름은 수치 기준 없이 한 다이어그램으로 읽기 어려운지로 판단한다. 핵심 경로만 그리고 다이어그램 아래에 `생략한 호출은 위 트리에서 확인한다.` 한 줄을 적는다. 불일치 판정은 이 줄의 유무로 생략과 누락을 가른다.
- 새 절차 문장은 code-map 러너(`code-map/tests/run-tests.sh`)가 구조 검사하고, 문장을 지운 사본이 격추되는지로 검사가 동작함을 확인한다. `check` 판정 헬퍼는 만들지 않는다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 트리는 호출 구조를 보여 주지만 호출 순서, 반환 값과 예외, 비동기 여부, 조건 분기, 트랜잭션 범위는 노드 주석에 흩어지거나 빠진다. 시퀀스 다이어그램은 이 정보를 표기법으로 담는다 (#126 배경).
- Mermaid는 GitHub·GHE·IntelliJ의 마크다운 미리보기에서 그림으로 그려지고, AI는 텍스트로 읽는다. VS Code 기본 미리보기는 확장이 있어야 그려진다.
- 비동기 표기 정정(2026-10-31 작성 AI 결정): 이슈 본문은 "이벤트 발행·메시지 전송은 `-)`"라 적었지만 Spring `ApplicationEventPublisher#publishEvent`는 기본 동작이 동기 호출이다. 그래서 규칙은 호출한 쪽이 응답을 기다리지 않는 호출(메시지 브로커 전송, `@Async` 메서드 등)을 `-)`로 정하고, local 예시의 `publishEvent`는 `->>`로 그렸다.
- 금지 문자: Mermaid는 `;`를 문장 구분자로, `#`를 엔티티 코드(`#59;` 등)의 시작으로 해석해 메시지 문구가 잘린다. 트리 노드의 `Class#method` 표기를 그대로 옮기지 않는 이유다.
- 공통 규칙을 SKILL.md에 둔 이유: 두 모드가 같은 규칙을 쓰고, 두 모드에 걸친 `## 디렉토리 트리 정렬 규칙`도 SKILL.md에 있다.
- global 판정 범위(계획 감사 F-2 보정, 2026-10-31): `service-call-flows.md`는 한 파일에 흐름 섹션이 여러 개이고 `## How`가 없다. 파일 단위로 판정하면 한 흐름의 블록이 다른 흐름의 누락을 가리므로 흐름 섹션마다 판정하고 흐름 단위로 센다.
- 새 태그를 두지 않은 이유: 누락은 sync가 기능 변경 때 채우고 rebuild로 일괄 보충할 수 있어, 태그로 문서에 남기지 않고 결과 보고 건수로 충분하다(이슈 본문 범위 결정).
- 긴 흐름의 수치 기준(참여자 수 등)을 두지 않은 이유(2026-10-31 대화 결정): 흐름마다 읽기 어려워지는 지점이 달라 수치가 판단을 대신하지 못한다.
- 원장 K-0006(`check` 판정이 추론에 남음)은 이번에 해소하지 않았다(2026-10-31 사용자 결정). 시퀀스 누락 행은 블록 유무 판정이라 헬퍼를 만들 때 함께 다루고, 불일치 행은 호출 주체 해석이 섞여 절반만 결정적이다. K-0006 재검토 이력에 계속 수용으로 기록했다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- PlantUML: GitHub에서 그림으로 그려지지 않아 배제.
- ASCII 시퀀스 다이어그램: 참여자가 늘면 세로선 정렬을 손으로 유지하기 어려워 배제.
- 트리를 호출 순서대로 옮겨 적는 안: 트리와 내용이 겹쳐 중복이 크고 트리에 없는 정보가 늘지 않아 배제.
- 레이어 단위(Controller·Service·Repository) 참여자로 요약하는 안: 클래스 단위 추적이 트리에만 남아 두 표현이 어긋나므로 배제. 참여자는 트리 노드와 대응한다.
- 다음 sync에서 기존 상세 흐름 문서를 일괄 보충하는 안: 바뀌지 않은 기능까지 sync 범위가 넓어져 배제. 일괄 보충은 rebuild가 맡는다.
- rebuild 때만 시퀀스를 추가하는 안: sync로 바뀐 기능이 시퀀스 없이 남아 배제.
- K-0006을 함께 해소하는 안: 이슈 본문 제외 범위라 배제.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #126 code-map: 호출 흐름 트리 다음에 Mermaid 시퀀스 다이어그램을 추가한다 (local·global)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/126)
- 규칙 본문: [`code-map/SKILL.md`](../../../code-map/SKILL.md), [`code-map/references/local.md`](../../../code-map/references/local.md), [`code-map/references/global.md`](../../../code-map/references/global.md)
- 관련 결정: [ADR 0001 결정적 헬퍼 테스트 규칙](./0001-skill-deterministic-helper-test-convention.md), [ADR 0003 검증 레벨](./0003-verification-levels-and-determinization.md), [원장 K-0006](../../70_ledger/active/K-0006-code-map-check-not-deterministic.md)
- 외부 문서: [Mermaid sequenceDiagram](https://mermaid.js.org/syntax/sequenceDiagram.html), [Spring 애플리케이션 이벤트](https://docs.spring.io/spring-framework/reference/core/beans/context-introduction.html#context-functionality-events)

</details>
