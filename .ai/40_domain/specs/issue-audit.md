---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/62
last_harvested: 2026-09-09
---

# 이슈 감사(issue-audit) 요건

## 요건

- 감사는 독립 감사인 관점이다. 사용자가 기준 모델과 다른 벤더 모델로 직접 수행하며(계획 감사는 계획 모델, 최종 감사는 구현 모델 기준) 작성·구현 AI는 자동 실행하지 않는다.
- 기본 모드는 최종 감사(구현 검증), `--plan`은 계획 감사다.
- 0단계 컨텍스트 수집: spec·plan·summary, 이슈 본문, `.ai` 문서(30/40/50), 원장 `70_ledger/index.md`의 관련 항목(`active/` 수용 항목과 관련 `archive/` 항목), 같은 이슈의 이전 회차 리포트(workspace와 active/archive 디렉토리 모두 탐색).
- 1단계 적합성 검증: 요구사항·완료의 정의 항목별 충족(PASS)/미충족(FAIL)/부분 충족(PARTIAL)/판정 불가(N/A). 경계 검증은 요구사항 제외 목록 침범과 스펙에 없는 추가 구현을 본다. 완료의 정의 `[D]` 항목은 검증 명령을 구현 후 트리에서 실행해 그 결과로 판정한다(실행할 수 없는 환경이면 판정 불가).
- 2단계 비판적 검증: 발견마다 영향 축·발생확률 축 판정 → 매트릭스 등급, 카테고리 7종, 검증 관점(엣지케이스·암묵적 가정·부작용·스펙 모호성·누락된 검증), 계보, 발견별 완료 기준. 2단계 발견을 1단계 미충족 근거로 결속하는 범위는 한정한다. 누락된 검증은 기능을 바꾸는 구현 Task마다 Task별 테스트 `[D]`가 있는지와 그 테스트가 변경을 덮는지로 판정하며, 공통 전체 테스트 통과만으로는 충족으로 보지 않는다.
- 발견 번호 `F-n`은 이슈 단위로 연속 계승한다(`next-finding-number.sh`). 계보 표기: 신규 / `F-n 잔여` / `기등재 K-n 재제기` / `K-n 재발`.
- 기등재 대조는 번호 부여 전에 한다. `active/수용`이고 재검토 조건 미충족이면 별도 섹션에 참조로만 적고 집계에서 제외한다. 위험도가 등재 시점보다 높아 보이거나 원장이 낡았으면 원장 갱신 권고로 유도한다.
- 리포트 상단 메타에 `> 감사 모델: <벤더, 모델명 (모델 ID)>`(ID 확인 불가면 `(-)`), `> 감사 effort: <도구가 기록한 표기, 확인 불가면 ->`와 감사 회차를 적는다. `감사 effort` 줄 값은 summary `모델 기록` 표의 해당 audit 행 `effort` 열로 옮겨 적으며 벤더끼리 비교하지 않는다. 이전 회차 리포트는 `issue-<번호>-audit-report-<회차>.md`로 보존하고, archive 재감사 시 archive의 최신 리포트도 같은 규칙으로 회전한다.
- 리포트 구조: `## 종합 의견`(첫 줄 판정) → `## 요약`(1단계 상태·2단계 상태·카테고리 집계·기등재 참조·이전 발견 닫힘/잔여) → 1단계 표 → 2단계 표·상세 → 기등재 참조·이전 발견 추적(접기). 판정·상태·이모지는 `classify-risk.sh`가 산출한다.
- 출력 요약(대화)은 판정 한 줄로 시작하고 판정 집계는 4종 전부 적는다. 대화 출력에는 접기를 쓰지 않는다.
- `--plan` 모드: 대상은 active spec·plan, 대조 기준은 이슈 본문과 30/40/50/70 문서. 1단계는 이슈 본문 요구 항목 대비 spec 요구사항 대조, 2단계는 추적성(`check-plan.sh --trace`, 이슈 AC와 spec 출처 표기의 AC 대조 `check-plan.sh --ac`)·가짜 `[D]` 사전 판별(issue-work 템플릿 고정 블록 Task 0·Task N의 완료 기준은 제외, 회귀 방지 예외는 spec 항목 본문의 `(회귀 방지 항목)` 표시만 인정)·범위(이슈 AC가 있으면 AC 대비 spec 완료의 정의의 완화·확장 점검)·모호성·과잉 설계. 리포트는 `issue-<번호>-plan-audit-report.md`, `F-` 번호 축은 최종 감사와 분리한다.
  - AC 대조(`--ac`): 이슈 본문은 임시 파일로 받아 조회가 성공했을 때만 넘긴다. 출력 `연결 없는 AC`·`없는 AC 참조`·`출처 없는 항목` 1행이 발견 1건이다. `대조 불가: 이슈 본문에 AC 없음`은 AC 없는 기존 이슈의 정상 경로라 발견으로 세지 않고 검증 실행 기록에 남긴다. 본문 조회가 실패하면 판정 불가(N/A)다 (#130).
  - 범위의 AC 대조: 완화는 AC의 오류 상황·성공 조건을 빼거나 약하게 한 항목, AC 삭제·제외 이동, 어느 항목에도 연결되지 않은 AC다. 확장은 AC에 없는 결과를 더한 항목이다. `(AC 없음: …)` 항목은 그 R이 이슈 본문 범위나 3-1 승인에 근거가 있으면 확장으로 세지 않는다. 연결 누락은 `--ac` 출력을 근거로 삼아 두 번 세지 않으며, 이슈 AC가 없으면 이 대조를 건너뛴다 (#130).
- 감사 리포트는 감사인의 증적 문서다. 피감 측이 소급 수정하지 않고 최신 검증 결과는 답글로 기록한다. 라인 번호 참조는 감사 시점 diff 기준이다.

## 관련 결정

- [ADR 0004](../../50_adr/active/0004-cross-model-audit-and-response-gate.md), [ADR 0006](../../50_adr/active/0006-risk-matrix-and-treatment.md), [ADR 0007](../../50_adr/active/0007-tech-debt-ledger-location-and-structure.md), [ADR 0014](../../50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md), [ADR 0016](../../50_adr/active/0016-spec-requirements-layer-and-plan-audit.md), [ADR 0019](../../50_adr/active/0019-test-perspectives-and-task-level-placement.md), [ADR 0026](../../50_adr/active/0026-acceptance-criteria-across-issue-spec-pr.md)
- 절차 상세는 `issue-audit/SKILL.md`와 `issue-audit/templates/issue-audit-report-template.md`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #26](https://github.com/scroogy-dev/scroogy-agent-skills/issues/26), [#46](https://github.com/scroogy-dev/scroogy-agent-skills/issues/46), [#61](https://github.com/scroogy-dev/scroogy-agent-skills/issues/61), [#62](https://github.com/scroogy-dev/scroogy-agent-skills/issues/62), [#64](https://github.com/scroogy-dev/scroogy-agent-skills/issues/64), [#76](https://github.com/scroogy-dev/scroogy-agent-skills/issues/76), [#94](https://github.com/scroogy-dev/scroogy-agent-skills/issues/94), [#98](https://github.com/scroogy-dev/scroogy-agent-skills/issues/98), [#100](https://github.com/scroogy-dev/scroogy-agent-skills/issues/100), [#112](https://github.com/scroogy-dev/scroogy-agent-skills/issues/112), [#130](https://github.com/scroogy-dev/scroogy-agent-skills/issues/130)
- [PR #44 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/44), [PR #49 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/49), [PR #65 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/65)

</details>
