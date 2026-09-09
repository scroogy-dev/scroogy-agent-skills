---
last_synced: 2026-09-09
source_hash: cf3fdca
status: current
---

# issue-work 새 이슈 시작 호출 흐름

## What

이슈 단위로 spec·plan·summary를 만들고 Task를 진행한다. spec 요구사항은 사용자 승인 뒤에 완료의 정의·plan으로 이어지고, 계획 종료 게이트 뒤에 계획 감사 수행 여부를 묻는다. 마지막 Task N은 사용자가 교차모델 audit으로 직접 수행한다.

## How

```
issue-work/SKILL.md `## 새 이슈 시작 시` → `## 작업 진행 중`
├── 1. active/ 기존 이슈 → archive/ 이동
├── 2. templates/issue-workflow-template.md → active/issue-workflow.md   # 템플릿이 SSoT, 다르면 덮어쓰기
├── 3-1. 승인 전                        # templates/issue-spec-template.md 로 목표·요구사항(포함·제외)·연관 문서 후보 (30_contract·40_domain·50_adr index)
│   └── 요구사항 승인 게이트            # spec 경로 + 목표 한 줄·포함·제외 목록만 제시, 이슈 본문 근거 없는 항목은 표시·질의
├── 3-2. 승인 후                        # 완료의 정의·전제, templates/issue-plan-template.md·issue-summary-template.md
├── 4. 계획 종료 게이트                 # 문서에 없는 전제를 spec `## 전제` 에 기록
├── 5. 계획 감사 질의                   # 기본값 없음. 수행: 사용자가 issue-audit --plan → --response / 건너뜀: summary `계획 audit 모델`·`계획 감사` 줄에 `생략`
├── Task 0: 구현 시작 게이트            # 전제·모호점 질의 후 착수
├── Task 1..N-1                         # 완료 시 plan 체크·summary 갱신
│   └── scripts/summarize-metrics.sh <summary>   # 지표 4종 표기 검사·보정률 집계, 위반은 exit 1
└── Task N: 교차모델 issue-audit         # 사용자 수동 (구현 AI 자동 실행·종료 금지), 리포트는 --response 로
```

## Why

- 게이트 2건(계획 종료·구현 시작)의 근거는 `## 새 이슈 시작 시` 인용문에 있다. 문서를 쓴 주체와 읽는 주체가 다를 수 있고 세션이 바뀌면 전제가 유실된다.
- 완료 기준을 `[D]`·`[QD]`·`[ND]`로 나누는 축은 [architecture.md 디자인 원칙](../../10_rules/architecture.md) `### 기존 체계와의 관계`에 있다. 레벨 정의·기본값 `[D]`·강등 사유 병기·접기 형식은 [ADR 0003](../../50_adr/active/0003-verification-levels-and-determinization.md).
- 지표 4종을 값이 없어도 남기는 이유는 `## 작업 진행 중`(사후 집계가 표기 고정에 의존)에 있다.
- Task N을 사용자가 타벤더 모델로 직접 수행하는 원칙은 [ADR 0004](../../50_adr/active/0004-cross-model-audit-and-response-gate.md). 계획 종료·구현 시작 게이트와 `모델 기록` 표는 [ADR 0005](../../50_adr/active/0005-model-separation-gates.md). 요구사항 승인 게이트와 계획 감사 질의는 [ADR 0016](../../50_adr/active/0016-spec-requirements-layer-and-plan-audit.md).
- 명세: [이슈 단위 작업 워크플로우 요건](../../40_domain/specs/issue-workflow.md)(절차 순서, spec·plan·summary 구성, 게이트 7종 요약).
- 헬퍼·테스트 배치는 [ADR 0001](../../50_adr/active/0001-skill-deterministic-helper-test-convention.md).
