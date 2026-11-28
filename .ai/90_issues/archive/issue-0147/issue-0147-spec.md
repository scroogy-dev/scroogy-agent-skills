# Issue #147 스펙 git-review-quiz·ai-workspace·issue-work: en_US.UTF-8 로케일에서 헬퍼와 러너의 한글 문자열 비교가 틀리는 것을 고친다

## 목표 (Goal)

`en_US.UTF-8` 로케일에서도 스킬 헬퍼와 테스트 러너가 한글 문자열을 바르게 비교해 다른 로케일과 같은 결과를 낸다.

---

## 요구사항 (Requirements)

### 포함

#### 헬퍼 판정

- R1: git-review-quiz의 `check-quiz.sh`가 로케일과 무관하게 같은 판정을 낸다.
- R2: ai-workspace의 `check-context.sh`가 로케일과 무관하게 같은 판정을 낸다.
- R5: awk를 쓰면서 `LC_ALL` 지정이 없는 나머지 배포 헬퍼 5개에 같은 비교가 있는지 확인하고, 있으면 고친다.

#### 테스트 러너

- R3: git-review-quiz와 ai-workspace의 테스트 러너가 `en_US.UTF-8`에서도 실패 없이 끝난다.
- R4: issue-work의 테스트 러너가 `en_US.UTF-8`에서도 실패 없이 끝난다.

### 제외

- issue-audit의 `check-plan.sh`: 대체(#145에서 고쳤다)
- `LC_ALL=C`에서 issue-audit 러너가 첫 검사에서 멈추는 현상: 보류(#145 이전에도 있던 동작이고 원인을 확인하지 않았다)

---

## 완료의 정의 (Definition of Done)

- [x] AC1: `check-quiz.sh`가 같은 입력에 대해 `C.UTF-8`과 `en_US.UTF-8`에서 같은 출력과 종료 코드를 낸다. (R1)
- [x] AC2: `check-context.sh`가 같은 입력에 대해 `C.UTF-8`과 `en_US.UTF-8`에서 같은 출력과 종료 코드를 낸다. (R2)
- [x] AC3: git-review-quiz 러너가 `LC_ALL=en_US.UTF-8`에서 실패 0건으로 끝난다. (R3)
- [x] AC4: ai-workspace 러너가 `LC_ALL=en_US.UTF-8`에서 실패 0건으로 끝난다. (R3)
- [x] AC5: `verify-submit.sh`, `verify-push.sh`, `check-lobby.sh`, `summarize-metrics.sh`, `check-clear.sh`마다 로케일에 따라 결과가 달라지는 비교가 있는지 확인한 결과가 남고, 있는 헬퍼는 두 로케일에서 같은 결과를 낸다. (R5)
- [x] AC6: issue-work 러너가 `LC_ALL=en_US.UTF-8`에서 실패 0건으로 끝난다. (R4)

---

## 결정 사항 (Decisions)

- D1 고치는 방식: 로케일에 따라 결과가 달라지는 비교가 있는 배포 헬퍼와 git-review-quiz·ai-workspace·issue-work 러너는 스크립트 머리에 `export LC_ALL=C`를 둔다. `issue-audit/scripts/check-plan.sh`와 `ai-workspace/scripts/sync-owned.sh`가 쓰는 방식과 같다. (이슈 본문 검토 필요 1, 2026-11-27 답변)
- D2 로케일 회귀 케이스: 러너에 둔다. 고친 헬퍼마다 같은 입력을 `C.UTF-8`과 `en_US.UTF-8`로 실행해 출력과 종료 코드가 같은지 본다. 러너 머리가 `LC_ALL=C`이므로 이 케이스만 헬퍼를 부를 때 로케일을 명시한다. (이슈 본문 검토 필요 2, 2026-11-27 답변)
- D3 로케일이 없는 환경: 실행하는 머신에 `en_US.UTF-8`이 없으면 D2 케이스는 실행하지 않고 건너뛴 사실을 한 줄 출력하며 실패로 세지 않는다. (이슈 본문 검토 필요 2, 2026-11-27 답변)
- D4 AC5의 확인 결과: 헬퍼 5개마다 로케일에 따라 결과가 달라지는 비교가 있는지와 그 근거(해당 줄이나 없다고 본 이유)를 summary의 해당 Task 블록 `수행 내용 요약`에 적는다. 비교가 있는 헬퍼만 D1 방식으로 고치고 D2 케이스를 더한다. (2026-11-27 대화)

<details>
<summary>버린 대안과 이유</summary>

| 결정 | 버린 대안 | 버린 이유 |
|------|-----------|-----------|
| D1 | 문제가 되는 `awk` 호출에만 `LC_ALL=C`를 붙인다 | 새 호출을 더할 때 빠뜨리기 쉽다. 두 헬퍼의 `substr`·`length`는 ASCII 값(펜스 문자, SHA, `a`~`z` 선택지)에만 쓰여 스크립트 전체를 바이트 단위로 바꿔도 결과가 같다 |
| D1 | 러너의 문제 비교에만 지정하고 헬퍼 호출은 사용자 로케일로 둔다 | 러너 안의 한글 비교를 하나씩 찾아 고쳐야 하고, 나중에 더한 비교가 다시 같은 결함을 낸다 |
| D3 | `en_US.UTF-8`이 없으면 실패로 센다 | 그 로케일이 없는 머신에서는 러너가 늘 실패한다 |
| D3 | 러너에 두지 않고 이번 이슈의 검증 명령으로만 본다 | 이슈를 마친 뒤 생기는 회귀를 잡지 못한다 |
| D4 | 비교가 없는 헬퍼에도 예방으로 `export LC_ALL=C`를 둔다 | 최소 변경 원칙에 맞지 않는다 |

</details>

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 헬퍼 테스트 위치·러너 규칙 (러너에 로케일 회귀 케이스를 둘 때의 기준) |
| `.ai/50_adr/active/0003-verification-levels-and-determinization.md` | 검증 레벨 `[D]`/`[QD]`/`[ND]` (`en_US.UTF-8`이 없는 환경의 강등 판단) |
| `.ai/10_rules/testing-principles.md` | 테스트 실행 원칙 (실행 셸·환경) |
| `issue-audit/scripts/check-plan.sh` | `export LC_ALL=C`로 고친 선례 (#145) |
