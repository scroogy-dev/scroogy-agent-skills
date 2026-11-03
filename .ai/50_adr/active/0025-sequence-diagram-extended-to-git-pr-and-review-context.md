---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/128
related_jira:
last_harvested: 2026-10-31
---

# ADR: 시퀀스 다이어그램을 git-pr·git-review-context로 넓히고 작성 규칙 사본을 같은 문장으로 유지하는 결정

- **상태**: 유효

## 결정

- 호출 흐름 트리 다음에 Mermaid 시퀀스 다이어그램을 두는 방식을 code-map 밖의 두 스킬로 넓힌다 (#128).
  - **git-pr**: 이슈별 테크 관점 `호출 흐름`에서 기능마다 트리 코드 블록 바로 다음에 `mermaid` 블록을 둔다. SKILL.md 예시와 `templates/pr-body-template.md`는 기능 이름 줄을 코드 블록 밖 리스트 항목으로 두고, 그 아래에 트리 코드 블록과 `mermaid` 블록을 들여 쓴다.
  - **git-review-context**: 결과 기록의 `## 호출 흐름` 접기 안에서 엔트리 포인트마다 트리 코드 블록 바로 다음에 `mermaid` 블록을 둔다. 템플릿의 접기 안 주석도 트리와 시퀀스 다이어그램을 함께 안내한다. 5단계의 "의사코드 또는 단계별 목록" 행은 시퀀스가 같은 역할을 맡으므로 지운다.
  - 두 스킬 모두 `### 시퀀스 다이어그램` 소제목을 두지 않는다. 한 섹션에 기능 여러 개를 나열하는 구조라 기능(엔트리 포인트) 이름 줄이 구분을 맡는다.
- 시퀀스는 code-map 상세 흐름 작성 기준(2단계 이상의 호출 계층, 외부 서비스 호출, 트랜잭션·이벤트·비동기 분기 중 하나)에 해당하는 기능에만 그리고, 나머지 기능은 트리만 둔다. 기준 3행은 code-map `references/local.md`의 문장을 그대로 옮긴다.
- 작성 규칙은 원본 code-map `## 시퀀스 다이어그램 작성 규칙`과 사본 git-pr·git-review-context·git-review-quiz 세 곳에 둔다(git-review-quiz 사본은 #132에서 추가, ADR 0027). 사본은 같은 제목의 섹션에 규칙을 복제하며 code-map을 링크로 가리키지 않는다 (ADR 0002).
  - 참여자·응답·동기·비동기·분기·반복·트랜잭션 경계·금지 문자·긴 흐름 행은 원본과 같은 문장이다. 위치·형식 행은 스킬별로 쓰고, 참여자 행에서는 사본 스킬에 없는 옵션을 가리키는 `--global` 구절("`--global`은 서비스")만 뺀다.
  - 사본 도입 문단에는 원본이 `code-map`이라는 사실과 "한쪽 변경 시 양쪽 동기화" 문구를 링크 없이 적는다.
- code-map 러너(`code-map/tests/run-tests.sh`)가 세 사본의 규칙 섹션을 `SEQ_ROWS`로 대조한다. 라벨 이름·순서와 리터럴을 보며, code-map 전용인 위치·형식 행의 소제목 리터럴과 참여자 행의 `--global` 구절 리터럴은 대조에서 뺀다. 같은 러너가 git-pr·git-review-context의 안내 문장·작성 대상 기준·예시·템플릿 배치도 검사한다. git-review-quiz는 규칙 사본 대조만 한다. git-review-context에는 `tests/`를 새로 만들지 않는다.
- 러너는 규칙 행의 문장 전체 일치를 지속해서 검사하지 않는다. 일치는 이슈 완료 시점에 한 번 확인하고, 이후 리터럴을 남긴 채 뜻만 바꾼 수정을 잡지 못하는 범위는 원장 K-0019로 수용한다.
- ADR 0024의 결정(code-map의 위치·형식, 작성 규칙 원본 위치, check 누락·불일치 보고)은 그대로 둔다. 이 ADR은 같은 규칙을 쓰는 스킬을 더할 뿐 ADR 0024를 바꾸지 않는다.

## 근거

<details>
<summary>상세 펼치기</summary>

- #126 결과를 PR #127에서 그림으로 확인했을 때, 호출 순서와 분기를 트리보다 빨리 읽을 수 있었다. git-pr과 git-review-context는 code-map과 같은 ASCII 트리를 그리지만 시퀀스는 없었다 (#128 배경).
- 두 산출물은 주로 GitHub에서 읽는다. git-pr 결과는 PR 본문이고, git-review-context 결과(`temp_review_context.md`)는 사람 리뷰를 돕기 위해 PR 댓글로 게시하기도 한다. GitHub는 Mermaid를 그림으로 보여 준다. 리스트와 접기 안에 둔 `mermaid` 블록도 그림으로 표시되는 것을 2026-10-31 사용자가 GitHub 댓글 작성 창 Preview로 확인했다.
- git-pr 템플릿 예시의 트리는 코드 블록 없이 적혀 있어 GitHub에서 공백 정렬이 유지되지 않았다. SKILL.md 예시처럼 코드 블록으로 감쌌다.
- 기능 이름 줄을 코드 블록 밖으로 옮긴 이유(2026-10-31 계획 작성 AI 결정): 기존 SKILL.md 예시는 기능 이름 줄이 코드 블록 안에 있었다. 이슈 본문의 "기능 이름 줄이 구분을 맡는다"에 맞추려고 바꿨다.
- 작성 대상을 기준에 해당하는 기능으로 한정한 이유: PR 본문 분량이 과하게 늘지 않게 한다 (이슈 본문 범위 결정).
- 의도적 중복: 스킬은 따로 설치되므로 code-map이 없는 환경에서도 규칙이 보여야 한다 (ADR 0002).
- `--global` 구절 제외(2026-10-31 사용자 확정): 그대로 옮기면 두 스킬에 없는 옵션 언급이 사본에 남는다.
- 동기화 문구(2026-10-31 사용자 확정): ADR 0002 결정의 동기화 주석 항목과 git-review·issue-audit 사본 관례 "(스킬 단독 실행을 위해 복사해 두었으므로 한쪽 변경 시 양쪽 동기화)"를 따랐다.
- git-review-context 예시의 `OrderEventPublisher#publish`는 트리에 비동기 표시가 없어 `->>`로 그렸다. ADR 0024 근거의 비동기 표기 정정과 같은 기준이다.
- 배치 검사를 code-map 러너에 모은 이유(계획 감사 F-1 검토, 2026-10-31 사용자 확정): ADR 0019에 따라 구현 테스트는 기능을 만드는 Task에 둔다. 이슈 본문이 git-review-context `tests/` 신설을 제외해, 두 스킬의 시퀀스 검사를 둘 수 있는 러너는 code-map 러너뿐이다.
- 문장 전체 대조를 러너에 넣지 않은 범위는 계획 감사 F-2에서 원장 K-0019로 수용했다. 재검토 조건이 충족되면 K-0019의 채택하지 않은 대안(정규화한 전체 문장 대조)부터 검토한다.
- 2026-11-03 일부 변경(#132): git-review-quiz가 문항 앞 설명 절 `### 호출 흐름`에 시퀀스 다이어그램을 그리게 되어 사본을 하나 더했다. 위치·형식 행은 설명 절 배치에 맞춰 쓰고 `### ` 소제목을 두지 않는다(묶음 소절로 읽힘). 이슈 범위가 규칙 사본 대조라 배치 검사는 더하지 않았다. 결정 상세는 ADR 0027.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- code-map 규칙을 링크로 참조하는 안: 선택 설치 환경에서 링크가 끊겨 배제 (ADR 0002).
- code-map처럼 `### 시퀀스 다이어그램` 소제목을 두는 안: 한 섹션에 기능 여러 개를 나열하는 구조에서 기능 구분이 흐려져 배제.
- 모든 기능에 시퀀스를 그리는 안: PR 본문 분량이 과하게 늘어 배제.
- git-review 리뷰 포인트 접기 안의 `호출 흐름 추적`까지 포함하는 안: 지적 하나의 근거라 짧고 형식 규정이 없어 배제.
- 러너가 규칙 행 전체 문장을 code-map과 대조하는 안: 이슈 본문 범위 결정이 "`SEQ_ROWS` 하나로 대조"라 배제. 문장 일치는 이슈 완료 시점 검증으로 확인하고, 지속 감시의 한계는 K-0019로 수용했다.
- git-review-context에 `tests/`를 새로 만드는 안: 이슈 본문 범위 결정에서 제외. code-map 러너 하나가 세 사본을 대조한다.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #128 git-pr·git-review-context: 호출 흐름 트리 다음에 Mermaid 시퀀스 다이어그램을 추가한다](https://github.com/scroogy-dev/scroogy-agent-skills/issues/128)
- 규칙 본문: [`code-map/SKILL.md`](../../../code-map/SKILL.md), [`git-pr/SKILL.md`](../../../git-pr/SKILL.md), [`git-pr/templates/pr-body-template.md`](../../../git-pr/templates/pr-body-template.md), [`git-review-context/SKILL.md`](../../../git-review-context/SKILL.md), [`git-review-context/templates/review-context-template.md`](../../../git-review-context/templates/review-context-template.md), [`git-review-quiz/SKILL.md`](../../../git-review-quiz/SKILL.md)
- 일부 변경: [Issue #132](https://github.com/scroogy-dev/scroogy-agent-skills/issues/132), [ADR 0027](./0027-git-review-quiz-explanation-sections-and-html-output.md)
- 검사: [`code-map/tests/run-tests.sh`](../../../code-map/tests/run-tests.sh)
- 관련 결정: [ADR 0024 code-map 시퀀스 다이어그램](./0024-code-map-sequence-diagram-alongside-call-flow-tree.md), [ADR 0002 스킬 독립성과 의도적 중복](./0002-skill-independence-intentional-duplication.md), [ADR 0019 테스트 관점과 Task별 배치](./0019-test-perspectives-and-task-level-placement.md), [원장 K-0019](../../70_ledger/active/K-0019-seq-copy-literal-check-misses-meaning-change.md)
- 외부 문서: [Mermaid sequenceDiagram](https://mermaid.js.org/syntax/sequenceDiagram.html), [GitHub 다이어그램 작성](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams)

</details>
