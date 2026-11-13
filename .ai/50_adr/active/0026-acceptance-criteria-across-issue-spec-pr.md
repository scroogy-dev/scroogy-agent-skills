---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/130
related_jira:
last_harvested: 2026-11-01
---

# ADR: 완료의 정의를 이슈 등록 때 AC로 정하고 spec·계획 감사·PR이 같은 AC 번호로 잇는 결정

- **상태**: 유효

## 결정

- **이슈 본문 템플릿**: issue-work `templates/issue-body-template.md`를 둔다. 본문은 목표·범위·완료의 정의·검토 필요, 접기는 배경·현재 동작 → 기대 동작·연관 문서다. 완료의 정의는 `- [ ] AC<n>: <관찰할 수 있는 결과>` 행이며, 포함 항목마다 AC를 1개 이상 둔다 (#130).
  - 범위의 표지는 spec과 같은 `### 포함`·`### 제외` 제목이다. 포함 항목의 세부 조건은 하위 목록에 둔다. 포함·제외는 따로 세어 5개 이상이면 spec과 같은 기준으로 묶는다. 포함은 내용(기능 영역)별 `#### <묶음 이름>` 묶음, 제외는 `#### 보류`, `#### 대체`, `#### 불필요` 순서의 사유별 묶음이고, 5개 미만이면 묶지 않는다 (#140).
- **`--create`**: issue-work에 이슈 등록 옵션을 둔다. 단계는 초안 작성 → 요약 제시 → 승인 → 등록 → 번호 보고 → 시작 질의다.
  - 초안은 `.ai/99_workspace/issue-create-body.md` 1개이고 전문을 대화에 출력하지 않는다(ADR 0013 방식). 제목은 파일에 넣지 않고 승인한 값을 `--title`로 넘긴다.
  - 요약 제시 단계는 포함·제외 목록을 초안의 묶음대로 나눠 보여 주고 항목은 첫 줄만 보여 준다. 하위 목록은 파일에서 확인한다 (#140).
  - 요약 제시 단계에서 서로 독립으로 머지할 수 있는 항목이 있으면 AI가 이슈 분할을 권고한다. 수치 기준은 두지 않고 결정은 사용자가 한다. 같은 단계에서 AC가 대응하지 않는 포함 항목을 보고한다.
  - 승인 전에는 `gh issue create`를 실행하지 않고, 명령은 `--repo`와 `--body-file`을 생략하지 않는다. MCP 폴백은 `github.com` 대상일 때만 한다.
  - 등록까지만 하며 active 작업 파일을 옮기거나 지우지 않는다. 작업 시작은 시작 질의를 승인한 뒤 "새 이슈 시작 시"가 맡는다.
- **AC 2단계 해상도**: 이슈 AC는 무엇이 만족되면 끝인지를, spec 완료의 정의는 합격·불합격을 어떻게 판정하는지를 적는다. 이슈 본문에 AC 행이 1개 이상이면 AC가 있는 이슈다.
  - AC가 있으면 3-2는 완료의 정의를 새로 쓰지 않고 AC를 `[D]`/`[QD]`/`[ND]`로 정제한다.
  - spec 항목 본문 끝에 출처 `(AC<n>)`을 `(회귀 방지 항목)` 앞에 적는다. 모든 AC가 1개 이상의 항목에 연결되며 `공통` 회귀 방지 항목만 출처 표기 없이 둔다.
  - AC가 대응하지 않는 R의 항목은 `(AC 없음: <사유>)`로 적는다. 사유에는 그 R의 근거(이슈 본문 범위, 3-1 승인)를 적는다.
  - AC 번호는 뒤에만 추가하고 다시 매기지 않는다. plan Task 완료 기준은 진행만 판정하고 spec에 없는 결과를 더하지 않는다.
  - AC가 없는 이슈는 승인받은 요구사항에서 완료의 정의를 쓰고 출처를 표기하지 않는다.
- **변경 통제**: 3-2 정제와 작업 진행 중의 spec 변경을 셋으로 나누고 확장·완화만 질의한다. 기준선은 이슈 AC이고, AC가 없으면 3-1에서 승인받은 요구사항이다.
  - 구체화는 AC가 다루는 상황과 결과는 그대로 두고 판정 기준만 명확히 하는 변경이며 질의 없이 반영한다.
  - 확장은 AC에 없는 결과를 더하는 변경이다. 범위 확장(이슈 본문 갱신 + 재승인), 원장 등재, 새 이슈(`--create`) 중에서 고르게 한다.
  - 완화는 오류 상황을 빼거나 성공 조건을 약하게 하거나 AC를 빼거나 제외로 옮기는 변경이며 재승인 없이 반영하지 않는다.
- **이슈 본문 갱신 질의**: "새 이슈 시작 시" 6단계로 둔다.
  - 시점은 계획 감사 처리(수행이면 `--response` 반영까지) 뒤, Task 0 전이다.
  - 대상은 이슈 본문에 AC가 없거나 spec에 `(AC 없음: …)` 항목이 있는 이슈다. 빠진 AC를 뒤 번호로 더하고 spec 항목의 레벨 태그와 검증 명령은 옮기지 않는다.
  - 초안 직전에 본문을 다시 받아 기준 본문 `issue-<번호>-body-base.md`로 두고, 초안 `issue-<번호>-body.md`는 기준 본문에 AC 행만 더한다. 실행 직전에 다시 받은 본문이 기준 본문과 `cmp -s`로 같고 사용자가 승인했을 때만 `gh issue edit --repo --body-file`을 실행한다.
  - 결과는 summary `이슈 본문 갱신` 줄에 `갱신 · <추가한 AC 번호>`·`거절`·`대상 아님`으로 적는다. 이 줄이 비어 있으면 Task 0 전에 6단계를 먼저 수행한다.
- **계획 감사의 AC 대조**: issue-audit `--plan`이 이슈 AC를 감사 기준으로 쓴다.
  - 관점 1 추적성에 헬퍼 `check-plan.sh --ac <이슈 본문 파일> <spec 파일>`을 더한다. 출력은 `연결 없는 AC`·`없는 AC 참조`·`출처 없는 항목`·`대조 불가` 4종이고 종료 코드는 0 통과·1 위반·2 사용오류다.
  - AC 없는 이슈 본문에는 `대조 불가: 이슈 본문에 AC 없음` 1행만 내고 종료 코드 1로 끝낸다. 계획 감사는 이 행을 발견으로 세지 않고 검증 실행 기록에 남긴다.
  - 감사인은 본문을 임시 파일로 받아 조회가 성공했을 때만 `--ac`에 넘긴다. 조회가 실패하면 판정 불가(N/A)다.
  - 헬퍼는 계획 감사 전용이다. issue-work 3-2는 헬퍼를 부르지 않고 자기 점검으로 둔다.
  - 관점 3 범위가 AC 대비 완화·확장을 발견으로 보고한다. `(AC 없음: …)` 항목은 그 R이 이슈 본문 범위나 3-1 승인에 근거가 있으면 확장으로 세지 않는다.
- **PR 본문 첫 화면**: git-pr 이슈 섹션의 첫 화면(접기 밖)은 목적·범위, 리뷰어 확인 요청, 리스크·주의사항, 완료의 정의 대조, 이번 PR에서 하지 않는 것 5항목이다.
  - 접기 안은 완료의 정의 대조 표, 전후 예시, 배경, 비즈니스 관점, 테크 관점 5헤더다. 테크 관점은 구현 요약 → 호출 흐름 → 실패 경로 → 참고사항이다.
  - 10개 모두 항상 두고 내용이 없으면 `없음`을 적는다. 동작 차이가 없는 변경의 전후 예시도 `없음`이다.
  - 3단계 승인 요약에 리뷰어 확인 요청과 미충족 완료 항목을 넣는다.
- **PR 완료의 정의 대조 근거**: 최종 감사 리포트 `issue-<번호>-audit-report.md`의 `### 완료의 정의(DoD) 대조` 표로 AC별 상태를 정한다.
  - 리포트 행을 spec 항목과 R 그룹·순서로 맞추고, 그 항목의 출처 표기로 AC를 잇는다.
  - 상태는 `이관` → `미검증` → `미충족` → `충족` → `부분 충족` 순서로 먼저 맞는 값을 쓴다. 판정이 없는 AC는 `미검증`이다.
  - spec 체크박스만으로 충족으로 세지 않는다. `(AC 없음: …)` 항목은 R 그룹 단위로 따로 표시하고 `충족 n/m`에 넣지 않는다.
  - 대조 근거와 전후 예시는 diff·테스트·감사 리포트에서 확인한 것만 적는다.
- **승인 게이트 대상**: 이슈 등록과 이슈 본문 갱신을 외부 공개 행위 승인 게이트 정책 대상에 넣는다.
- **기존 ADR과의 관계**: ADR 0016의 "계획 감사를 건너뛰면 Task 0으로 간다"를 6단계를 거쳐 Task 0으로 가도록 일부 변경했다. ADR 0011(승인 게이트 절차)과 ADR 0013(파일 1회 생성)은 바꾸지 않는다. 승인 요약 항목을 더하고 같은 파일 규칙을 새 초안 파일에 적용할 뿐이다.

## 근거

<details>
<summary>상세 펼치기</summary>

- issue-work는 이미 등록된 이슈에서 시작해 이슈 등록 옵션과 본문 형식이 없었다. 이슈 본문은 3-1 근거 판정과 계획 감사 1단계의 기준인데, 형식이 없어 이슈마다 근거의 품질이 달랐다 (#130 배경).
- 완료의 정의를 3-2에서 AI가 처음 썼다. 3-1 승인 뒤 3-2에는 승인 게이트가 없어 정제 중에 기준이 약해져도 확인하는 쪽이 없었다. 이 저장소는 구현 AI의 자기 판정을 다른 벤더 모델 감사로 확인하므로(ADR 0004) 완화 점검도 계획 감사에 둔다.
- PR 본문은 이슈 목록·리스크 말고는 모두 접혀 있어 리뷰어가 판단할 것과 완료 정도가 첫 화면에 보이지 않았다. 사람이 변경을 이해하는 일이 병목이라 PR에서 사람이 판단할 자리를 드러낸다.
- 한 이슈로 묶은 이유: 완화 점검과 PR 완료 대조가 모두 이슈 AC 형식을 전제로 해, 따로 나누면 한쪽을 다른 쪽 없이 검증할 수 없다.
- 6단계를 계획 감사 뒤에 둔 이유: spec에서 만든 AC를 감사 전에 이슈 본문에 넣으면 관점 3이 spec을 그 spec에서 만든 AC와 비교하게 되어, 원래 이슈 본문이라는 감사 기준이 사라진다.
- AC가 일부만 있는 이슈도 6단계 대상에 넣은 이유: AC가 전혀 없는 이슈만 대상으로 두면 3-1에서 더한 R이 보강과 PR 대조에서 빠진다. 2026-11-01 계획 감사 뒤 보완에서 사용자가 승인했다.
- 기준 본문을 두 번 다시 받는 이유: `gh issue edit --body-file`은 본문 전체를 바꾼다. 계획 감사 동안 GitHub에서 고친 내용을 덮어쓰지 않도록 정책의 "실행 직전 재대조"를 기준 본문 비교로 적용했다.
- summary에 `이슈 본문 갱신` 줄을 둔 이유: 계획 감사는 다른 벤더 도구에서 수행해 6단계 직전에 세션이 끊기기 쉽다. 재개한 세션이 `다음 작업`의 Task 0만 보고 6단계를 건너뛰지 않게 한다. 계획 감사 1차의 F-2(복구 템플릿의 Task 0 직행 지시)를 보정하며 workflow 템플릿에도 같은 조건을 넣었다.
- AC 대조 헬퍼 도입: 처음 계획은 AC 형식이 새로 생긴다는 이유로 헬퍼를 미루려 했다. `architecture.md` 판단 체크리스트상 스크립트 후보라 2026-11-01 사용자가 도입을 결정했다(3-1 재승인). issue-work가 헬퍼를 부르지 않는 이유는 스킬 독립성이다(ADR 0002).
- `대조 불가`를 종료 코드 1로 두되 발견으로 세지 않는 이유: AC가 없을 때 무출력으로 통과시키면 공집합 통과가 된다(`--trace`의 `추적 불가`와 같은 취지). 6단계가 계획 감사 뒤라 AC 없는 기존 이슈는 정상 경로다. 계획 감사 1차의 F-1(AC 없는 이슈를 발견으로 보고할 수 있음)을 보정한 결과다.
- 본문을 프로세스 치환 대신 임시 파일로 받는 이유: 조회 실패가 빈 본문으로 바뀌어 `대조 불가`로 보인다.
- `--ac`는 `--trace`의 행 단위 파서 경계를 이어받는다. 이번 이슈에서 K-0010을 해소하지 않기로 3-1 재승인 때 정했다.
- PR 대조 근거를 감사 리포트로 정한 이유: issue-work에 spec 완료의 정의를 체크하는 단계가 없어, archive의 spec 12개(issue-0106~0128)에서 체크된 항목이 0개였다.
- PR 첫 화면·접기 안 항목을 항상 두는 이유: 내용이 없을 때 헤더를 빼면 PR마다 구성이 달라져 리뷰어가 항목을 찾기 어렵다.
- 첫 화면 `목적·범위`, 접기 안 `배경`, 비즈니스 관점 `목적 및 요약`은 역할을 나눠 같은 내용을 되풀이하지 않는다. 비즈니스 관점 3항목 구성은 유지한다(2026-11-01 Task 0에서 사용자 결정).
- `--create`·6단계의 초안 파일도 승인 뒤 내용 동일성을 검증하지 않는다. `--clear` 이슈 댓글 파일과 같은 구조다(K-0003).
- 계획 감사는 OpenAI 모델로 3회 수행했고 발견 2건(F-1·F-2)을 모두 보정했다. 3차에서 신규 발견 없이 적합(PASS)이었다.
- ADR 0016 일부 변경(2026-11-01, #130): 5단계 건너뜀 경로가 Task 0으로 바로 가면 6단계 질의가 빠진다. 결정 항목 나머지는 유효해 ADR index `## 수명 주기`의 일부 변경으로 제자리에서 고쳤다.
- 2026-11-12 #140에서 일부 변경: `이슈 본문 템플릿` 항목에 범위의 표지·묶음 규칙을, `--create` 항목에 요약 제시의 목록 모양을 더했다. 나머지 결정은 유효해 제자리에서 고쳤다.
  - 이슈 본문과 spec의 묶음이 같아야 두 문서를 맞춰 읽기 쉽다. 그래서 범위에도 spec과 같은 5개 기준을 두고, spec은 이슈 본문의 묶음 이름을 이어 쓴다([ADR 0016](./0016-spec-requirements-layer-and-plan-audit.md)).
  - 기존 범위 안내의 "관련 항목은 하위 목록으로 묶어도 된다"는 묶기를 `#### ` 제목이 맡게 되어 "항목의 세부 조건은 하위 목록에 둔다"로 바꿨다. 이슈 본문 항목에는 첫 줄 한 문장 규칙을 두지 않는다.
  - 등록 전에 범위를 읽는 요약 제시 목록도 초안과 같은 묶음으로 보여 줘야 승인할 때 읽는 구조가 파일과 같다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- **기각**:
  - 이슈와 spec의 번호 통합(이슈부터 R 번호 사용): AC와 R을 따로 두고 출처 표기로 잇는다.
  - 3-2 끝에 별도 승인 게이트: 완화·확장만 질의하는 자기 분류와 계획 감사가 같은 역할을 맡는다.
  - `.github/ISSUE_TEMPLATE`·`PULL_REQUEST_TEMPLATE.md`: 스킬 템플릿이 SSoT다.
  - 분할 권고의 수치 기준: 서로 독립으로 머지할 수 있는지는 수치로 정해지지 않아 AI 판단으로 권고하고 사용자가 정한다. 임계 수치를 두지 않는 ADR 0003과도 맞다.
  - AC 대조 헬퍼 보류안: 판단 체크리스트상 스크립트 후보라 도입했다.
  - 계획 감사 전 이슈 본문 보강: 감사 기준이 사라진다.
  - 6단계를 AC가 전혀 없는 이슈에만 두는 안: AC가 일부만 있는 이슈가 보강·대조에서 빠진다.
  - PR 대조 근거로 spec 체크박스 쓰기: 체크하는 단계가 없어 archive spec 12개 모두 체크 0개다.
  - PR 작성 때 `[D]` 명령 재실행: 비용이 크고 `[QD]`·`[ND]` 항목은 판정하지 못한다.
  - 기존 이슈 본문 일괄 소급 보강: 신규 이슈부터 적용하고 기존 이슈는 작업을 시작할 때 6단계로 보강한다.
- **보류**:
  - doc 프로파일 저장소에서 호출 흐름·시퀀스를 대신할 형식(문서 구조 변경 전후 표 등): doc 저장소의 PR 경험을 쌓은 뒤 정한다.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #130 issue-work·git-pr·issue-audit: 이슈 등록 옵션(--create)과 이슈 본문 템플릿을 추가하고 완료의 정의를 이슈·spec·PR로 잇는다](https://github.com/scroogy-dev/scroogy-agent-skills/issues/130)
- [Issue #140 issue-work: 요구사항이 5개 이상이면 spec·이슈 본문·승인 요청에서 포함은 내용별·제외는 사유별로 묶는다](https://github.com/scroogy-dev/scroogy-agent-skills/issues/140)
- 규칙 본문: [`issue-work/SKILL.md`](../../../issue-work/SKILL.md), [`issue-work/templates/issue-body-template.md`](../../../issue-work/templates/issue-body-template.md), [`issue-work/templates/issue-spec-template.md`](../../../issue-work/templates/issue-spec-template.md), [`issue-work/templates/issue-plan-template.md`](../../../issue-work/templates/issue-plan-template.md), [`issue-work/templates/issue-summary-template.md`](../../../issue-work/templates/issue-summary-template.md), [`issue-work/templates/issue-workflow-template.md`](../../../issue-work/templates/issue-workflow-template.md), [`issue-audit/SKILL.md`](../../../issue-audit/SKILL.md), [`issue-audit/scripts/check-plan.sh`](../../../issue-audit/scripts/check-plan.sh), [`git-pr/SKILL.md`](../../../git-pr/SKILL.md), [`git-pr/templates/pr-body-template.md`](../../../git-pr/templates/pr-body-template.md)
- 검사: [`issue-work/tests/run-tests.sh`](../../../issue-work/tests/run-tests.sh), [`issue-audit/tests/run-tests.sh`](../../../issue-audit/tests/run-tests.sh), [`git-pr/tests/run-tests.sh`](../../../git-pr/tests/run-tests.sh), [`code-map/tests/run-tests.sh`](../../../code-map/tests/run-tests.sh)
- 정책: [외부 공개 행위 승인 게이트](../../40_domain/policies/local/external-action-approval-gate.md)
- 관련 결정: [ADR 0002 스킬 독립성과 의도적 중복](./0002-skill-independence-intentional-duplication.md), [ADR 0003 검증 레벨](./0003-verification-levels-and-determinization.md), [ADR 0004 교차모델 audit](./0004-cross-model-audit-and-response-gate.md), [ADR 0011 git-pr 승인 게이트](./0011-git-pr-submission-and-approval-gate.md), [ADR 0013 긴 산출물](./0013-long-output-single-file-generation.md), [ADR 0016 요구사항 층·계획 감사](./0016-spec-requirements-layer-and-plan-audit.md), [ADR 0025 git-pr 시퀀스 다이어그램](./0025-sequence-diagram-extended-to-git-pr-and-review-context.md), [원장 K-0003](../../70_ledger/active/K-0003-approved-file-content-unverified.md), [원장 K-0010](../../70_ledger/active/K-0010-check-plan-line-based-markdown-boundary.md)

</details>
