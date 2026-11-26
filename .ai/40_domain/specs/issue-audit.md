---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/62
last_harvested: 2026-09-09
---

# 이슈 감사(issue-audit) 요건

## 요건

- 감사는 독립 감사인 관점이다. 사용자가 기준 모델과 다른 벤더 모델로 직접 수행하며(계획 감사는 계획 모델, 최종 감사는 구현 모델 기준) 작성·구현 AI는 자동 실행하지 않는다.
- 기본 모드는 최종 감사(구현 검증), `--plan`은 계획 감사다. 최종 감사는 issue-work 진행 루프의 구현 검증 단계에서, 계획 감사는 계획 검증 단계에서 호출한다 (#145).
- 구현 브랜치 확인 (최종 감사, #145): 지정받은 구현 브랜치가 현재 체크아웃한 브랜치와 다르면 감사를 시작하지 않고 그 브랜치를 체크아웃한 작업 트리에서 다시 실행하도록 알린다.
- 0단계 컨텍스트 수집: spec·plan·summary, 이슈 본문, `.ai` 문서(30/40/50), 원장 `70_ledger/index.md`의 관련 항목(`active/` 수용 항목과 관련 `archive/` 항목), 같은 이슈의 이전 회차 리포트(workspace와 active/archive 디렉토리 모두 탐색).
- 1단계 적합성 검증: 최종 감사는 완료의 정의(DoD) 대조와 결정 사항 대조 두 표를 두고 항목별로 충족(PASS)/미충족(FAIL)/부분 충족(PARTIAL)/판정 불가(N/A)를 판정한다. 경계 검증은 요구사항 제외 목록 침범과 스펙에 없는 추가 구현을 본다 (#145).
  - DoD 대조: 행은 spec의 AC이고 근거는 plan `테스트 계획`에서 그 AC를 적은 줄이다. `[D]` 줄은 테스트와 명령을 구현 뒤 트리에서 실행하고, `[QD]` 줄은 감사인이 채점하며, `[ND]` 줄은 판정하지 않는다. `[ND]` 줄만 있거나 줄이 없는 AC는 판정 불가다.
  - 줄이 여러 개인 AC: 실패한 줄이 있으면 미충족이다. 실패가 없고 실행하지 못한 `[D]` 줄이 있으면 판정 불가이고, 줄을 모두 합쳐도 AC 문장의 일부만 보면 부분 충족이다.
  - 결정 사항 대조: 행은 spec `결정 사항`의 D이고 구현이 그 결정대로인지 본다. `결정 사항`이 없는 spec은 DoD 대조만 둔다.
  - spec 파일이 없는 감사: 이슈 본문의 AC를 구현에 직접 대조하고, 본문에 AC가 없으면 포함 항목을 DoD 대조의 행으로 삼는다.
- 2단계 비판적 검증: 발견마다 영향 축·발생확률 축 판정 → 매트릭스 등급, 카테고리 7종, 검증 관점(엣지케이스·암묵적 가정·부작용·스펙 모호성·누락된 검증), 계보, 발견별 완료 기준. 2단계 발견을 1단계 판정의 근거로 삼는 대상은 스펙의 요구사항·AC·`결정 사항`의 결정으로 한정한다 (#145). 누락된 검증은 기능을 바꾸는 구현 Task마다 테스트 커밋이 구현 커밋보다 앞에 있는지, summary의 `테스트` 기록이 있는지, 적은 테스트가 변경을 덮는지로 판정한다. 테스트 커밋으로 돌아가 실패를 다시 실행하지 않으며, 전체 테스트 통과만 적은 Task는 테스트가 없는 것으로 본다 (#145).
- 코드 레벨 검증 (최종 감사, #145): 변경 파일마다 추가·수정 줄과 삭제 줄을 빠짐없이 읽고 버그·보안·성능을 git-review와 같은 확인 관점으로 본다. 발견은 기록 전에 인용 위치를 다시 읽어 성립을 확인하고, 버그·보안·성능 발견에는 실패 시나리오를 적는다. 읽은 파일 수와 읽지 않은 파일·사유는 리포트 요약에 적는다. 확인 관점과 실패 시나리오는 doc 카테고리 세트에 적용하지 않으며 계획 감사에는 모두 적용하지 않는다.
- 발견 번호 `F-n`은 이슈 단위로 연속 계승한다(`next-finding-number.sh`). 계보 표기: 신규 / `F-n 잔여` / `기등재 K-n 재제기` / `K-n 재발`.
- 기등재 대조는 번호 부여 전에 한다. `active/수용`이고 재검토 조건 미충족이면 별도 섹션에 참조로만 적고 집계에서 제외한다. 위험도가 등재 시점보다 높아 보이거나 원장이 낡았으면 원장 갱신 권고로 유도한다.
- 리포트 상단 메타에 `> 감사 모델: <벤더, 모델명 (모델 ID)>`(ID 확인 불가면 `(-)`), `> 감사 effort: <도구가 기록한 표기, 확인 불가면 ->`와 감사 회차를 적는다. `감사 effort` 줄 값은 summary `모델 기록` 표의 해당 audit 행 `effort` 열로 옮겨 적으며 벤더끼리 비교하지 않는다. 이전 회차 리포트는 `issue-<번호>-audit-report-<회차>.md`로 보존하고, archive 재감사 시 archive의 최신 리포트도 같은 규칙으로 회전한다.
- 리포트 구조: `## 종합 의견`(첫 줄 판정) → `## 요약`(1단계 상태·2단계 상태·카테고리 집계·기등재 참조·이전 발견 닫힘/잔여) → 1단계 표 → 2단계 표·상세 → 기등재 참조·이전 발견 추적(접기). 판정·상태·이모지는 `classify-risk.sh`가 산출한다.
- 출력 요약(대화)은 판정 한 줄로 시작하고 판정 집계는 4종 전부 적는다. 대화 출력에는 접기를 쓰지 않는다.
- `--plan` 모드: 대상은 active spec·plan, 대조 기준은 이슈 본문과 30/40/50/70 문서다. 리포트는 `issue-<번호>-plan-audit-report.md`이고 `F-` 번호 축은 최종 감사와 분리한다.
  - 1단계: 요구사항 대조(행은 이슈 본문의 포함·제외 항목과 `검토 필요` 항목. 제외 항목을 승인 근거 없이 포함 R로 옮겼으면 미충족, `검토 필요` 항목은 판정 불가)와 DoD 대조(행은 spec의 AC, 판정은 행 끝의 `(R<n>)` 기준) 두 표다. `AC 없는 R`은 AC 칸이 `-`인 미충족 행으로 더하고 결정 사항 대조 표는 두지 않는다 (#145).
  - 2단계 관점: 추적성(`check-plan.sh`의 `--trace`·`--ac`), 테스트 계획(층 선택과 못 보는 항목의 이유), 범위(AC 대비 `결정 사항`·`테스트 계획`의 완화·확장), 모호성, 과잉 설계다. 구현 전이라 테스트를 실행하지 않는다 (#145).
  - 추적성 `--trace`: spec 포함 R, spec AC 행의 `(R<n>)`, plan 일반 Task의 `대상 요구사항`, plan `테스트 계획`의 AC 줄 사이에서 대응이 끊긴 자리를 9종으로 낸다 (#145).
  - 추적성 `--ac`: 이슈 본문과 spec의 AC가 번호·문장·묶음 제목까지 같은지 견줘 5종(`spec에 없는 AC`, `이슈 본문에 없는 AC`, `문장 다른 AC`, `묶음 다른 AC`, `대조 불가: 이슈 본문에 AC 없음`)으로 낸다. 이슈 본문은 임시 파일로 받아 조회가 성공했을 때만 넘기고, 조회가 실패하면 판정 불가(N/A)다 (#130, #145).
  - `이슈 본문에 없는 AC`와 `대조 불가`의 판정: summary `이슈 본문 갱신` 줄로 정한다. 비어 있으면 보강 대기로 적고 위반으로 세지 않으며, `거절 · <AC 번호>`면 그 번호와 그 이슈의 `대조 불가`를 세지 않고, `갱신 · <AC 번호>`나 `대상 아님`이면 위반이다. 세지 않은 행도 검증 실행 기록에 남긴다 (#145).
  - 범위의 AC 대조: 완화는 `결정 사항`이나 `테스트 계획`이 AC의 오류 상황을 빼거나 성공 조건을 약하게 한 경우와 spec이 AC를 빼거나 제외로 옮긴 경우다. 확장은 AC에 없는 결과를 더한 경우와 본문의 AC가 이미 대응하는 R에 spec이 AC를 더한 경우다. 같은 결함을 추적성과 두 번 세지 않으며, 이슈 AC가 없으면 이 대조를 건너뛴다 (#130, #145).
  - 모호성: spec `결정 사항`이나 plan `설계 결정`에 남았어야 할 결정이 빠진 자리를 본다. 이슈 본문의 `정한 것`이 `결정 사항`에 없는 경우도 든다 (#145).
- 감사 리포트는 감사인의 증적 문서다. 피감 측이 소급 수정하지 않고 최신 검증 결과는 답글로 기록한다. 라인 번호 참조는 감사 시점 diff 기준이다.

## 관련 결정

- [ADR 0004](../../50_adr/active/0004-cross-model-audit-and-response-gate.md), [ADR 0006](../../50_adr/active/0006-risk-matrix-and-treatment.md), [ADR 0007](../../50_adr/active/0007-tech-debt-ledger-location-and-structure.md), [ADR 0014](../../50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md), [ADR 0016](../../50_adr/active/0016-spec-requirements-layer-and-plan-audit.md), [ADR 0019](../../50_adr/active/0019-test-perspectives-and-task-level-placement.md), [ADR 0026](../../50_adr/active/0026-acceptance-criteria-across-issue-spec-pr.md), [ADR 0031](../../50_adr/active/0031-issue-work-loop-and-one-sentence-requirements.md)
- 절차 상세는 `issue-audit/SKILL.md`와 `issue-audit/templates/issue-audit-report-template.md`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #26](https://github.com/scroogy-dev/scroogy-agent-skills/issues/26), [#46](https://github.com/scroogy-dev/scroogy-agent-skills/issues/46), [#61](https://github.com/scroogy-dev/scroogy-agent-skills/issues/61), [#62](https://github.com/scroogy-dev/scroogy-agent-skills/issues/62), [#64](https://github.com/scroogy-dev/scroogy-agent-skills/issues/64), [#76](https://github.com/scroogy-dev/scroogy-agent-skills/issues/76), [#94](https://github.com/scroogy-dev/scroogy-agent-skills/issues/94), [#98](https://github.com/scroogy-dev/scroogy-agent-skills/issues/98), [#100](https://github.com/scroogy-dev/scroogy-agent-skills/issues/100), [#112](https://github.com/scroogy-dev/scroogy-agent-skills/issues/112), [#130](https://github.com/scroogy-dev/scroogy-agent-skills/issues/130), [#145](https://github.com/scroogy-dev/scroogy-agent-skills/issues/145)
- [PR #44 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/44), [PR #49 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/49), [PR #65 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/65)

</details>
