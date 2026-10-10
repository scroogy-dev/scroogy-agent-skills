---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/110
related_jira:
last_harvested: 2026-10-10
---

# ADR: 원장 재검토·해소의 선제 대조와 해소 기재 시점

## 결정

- 원장 `active/` 항목의 재검토·종결 계기에 감사·리뷰의 재제기 외에 선제 대조 두 곳을 더한다.
  - git-pr `문서 동기화 점검`의 원장 대조: diff가 재검토 조건이 가리키는 파일·규칙이나 항목 원인을 바꾸면 재검토 이력 기록 또는 종결을 권고한다.
  - issue-work 새 이슈 시작 3-1의 `함께 해소 후보`: 이슈 범위와 관련된 항목을 따로 표시해 포함 여부를 묻고, 포함하면 요구사항(R)에 `(함께 해소: K-<번호>)`로 넣는다. 포함하지 않은 후보는 기록하지 않는다.
- 두 대조는 권고·질의까지만 한다. 원장 상태는 사용자 승인 없이 바꾸지 않으며, 재검토 조건이 자유 문장이라 판정 헬퍼를 두지 않고 AI가 조건 문장과 diff를 읽어 대조한다.
- `해소(PR #N)`은 PR 번호를 알 때만 확정한다. 이 규칙은 `--clear`·`## 이슈 완료 시`·`--response` 원장 종결에 같이 적용한다.
  - PR이 이미 있으면 그 단계에서 기재 → `archive/` 이관 → index 갱신을 하고 머지 전 같은 PR에 포함한다.
  - PR이 없거나 확인할 수 없으면 확정하지 않고 `active/`에 둔다. git-pr이 PR 생성 후 4단계에서 원장 대조로 승인받은 종결 항목에 번호를 적고, 커밋·push는 별도 승인을 받는다.
- 승격(이슈 #N)은 이슈 번호를 그 자리에서 얻으므로 시점 규칙의 대상이 아니다.
- 절차 순서 `--clear → PR`은 바꾸지 않는다.
- ADR 0007의 소비자 3종(issue-audit·issue-work `--response`·git-pr-feedback)과 상태 행렬·종결 독립은 그대로 두고, 이 ADR이 재검토·종결 계기만 확장한다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 재검토·종결 계기가 issue-audit 재제기와 git-pr-feedback 재지적뿐이라, 일반 작업이 재검토 조건을 충족하거나 원인을 없애도 같은 결함이 다시 보고되기 전에는 원장이 갱신되지 않았다. 해결된 항목이 `active/`에 남으면 이후 감사가 그것을 억제 기준으로 삼는다.
- git-pr 문서 동기화 점검은 이미 브랜치 diff로 낡은 문서를 감지하는 flag-only 단계(ADR 0011)라, 원장 항목을 같은 방식으로 대조하면 새 단계를 만들지 않고 권고 대상만 늘어난다.
- 이슈 시작 시점에 관련 항목을 범위로 끌어오면 부채 상환이 일반 작업에 묻어간다. 근거 없는 요구사항 표시·승인 규칙(ADR 0016)을 그대로 써서 사용자가 요청하지 않은 범위가 섞이지 않게 했다.
- git-pr 문서 동기화 점검은 PR 생성 전에 수행되고, 최근 이슈(#106·#108)도 `--clear` 커밋 뒤에 PR을 만들었다. 정리 시점에 PR 번호가 없는 경로가 일반적이라, 번호를 아는 git-pr 생성 후 단계가 후속 기재를 맡는다. 함께 해소 항목은 diff가 원인 파일을 바꾸므로 원장 대조에서 같은 경로로 걸린다.
- `--response` 원장 종결도 Task N 직후 PR 생성 전에 실행되어 같은 문제가 있으므로, 규칙을 하나로 맞췄다 (#110 Task 0 사용자 확정).
- ADR 0007은 원장의 위치·구조·상태 행렬을 정한 결정이고, 이번 변경은 원장을 언제 읽고 누가 종결을 기재하는지의 새 결정이라 별도 ADR로 남겼다. 0007의 결정은 바뀌지 않아 대체(superseded)하지 않는다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- ADR 0007에 소비자만 추가: 권고형 대조와 PR 번호 기준 시점 규칙이 위치·구조 결정과 섞이고, 대안 비교를 남길 자리가 없어 배제.
- 함께 해소 항목이 있는 이슈는 PR을 먼저 만들고 `--clear`를 나중에 실행: 도메인 명세의 절차 순서를 바꿔야 하고 실제 운용 순서와 어긋나 배제.
- PR 생성 후 사용자가 `--clear`(또는 해소 단계)를 다시 실행: git-pr을 바꾸지 않지만, 재실행을 잊으면 해소 기재가 빠져 배제.
- 시간 기준 주기 점검(`/schedule` 등)과 재검토 조건의 결정적 판정 헬퍼: 이슈 #110 범위에서 제외(불필요·보류).

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #110 git-pr·issue-work: 원장 재검토·해소 트리거 보강](https://github.com/scroogy-dev/scroogy-agent-skills/issues/110)
- 관련 결정: [ADR 0007 원장 위치와 구조](./0007-tech-debt-ledger-location-and-structure.md), [ADR 0011 git-pr 제출과 승인 게이트](./0011-git-pr-submission-and-approval-gate.md), [ADR 0016 요구사항 층과 계획 감사](./0016-spec-requirements-layer-and-plan-audit.md)
- 수명 주기 표: [`.ai/70_ledger/index.md`](../../70_ledger/index.md)

</details>
