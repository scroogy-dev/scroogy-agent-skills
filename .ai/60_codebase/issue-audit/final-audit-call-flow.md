---
last_synced: 2026-09-09
source_hash: 5ab2b67
status: current
---

# issue-audit 최종 감사 호출 흐름

## What

이슈 spec 대비 구현을 독립 감사인 관점에서 검증한다. 1단계 적합성(요구사항·DoD·경계·계약·ADR 대조)과 2단계 비판적 검증(발견·위험도)을 수행하고 리포트를 `.ai/99_workspace/`에 쓴다. 사용자가 구현 모델과 다른 벤더 모델로 직접 실행한다.

## How

```
issue-audit/SKILL.md (기본 모드: 최종 감사)
├── 0단계: 컨텍스트 수집
│   ├── .ai/90_issues/active|archive/issue-<번호>/ spec·plan·summary
│   ├── .ai/60_codebase/index.md, .ai/30_contract·40_domain·50_adr index
│   ├── .ai/70_ledger/index.md + active/K-*.md         # 기등재 대조로 반복 보고 차단
│   ├── 구현 브랜치 diff
│   └── 기존 리포트 .ai/99_workspace/issue-<번호>-audit-report*.md
├── 1단계: 적합성 검증 (Compliance Check)
│   └── scripts/classify-risk.sh --compliance <판정>…    # 1단계 상태 (최고값)
├── 2단계: 비판적 검증 (Critical Review)               # 5관점·7카테고리
│   ├── scripts/classify-risk.sh --impact <축> --likelihood <축>   # 등급, 감사인이 직접 고르지 않음
│   ├── scripts/classify-risk.sh --treatment <위험도>    # 등급별 기본 처리 (LOW 는 .ai/70_ledger/ 이관)
│   └── scripts/next-finding-number.sh <리포트 글롭>     # F- 번호 이슈 단위 계승
└── 3단계: 결과 기록
    ├── templates/issue-audit-report-template.md
    ├── scripts/classify-risk.sh --status [<위험도>…] / --verdict <상태> <상태>   # 2단계 상태·종합 판정 한 줄
    └── .ai/99_workspace/issue-<번호>-audit-report.md   # 직전 회차는 -<회차>.md 로 회전, 모델은 "벤더, 모델명"
```

리포트의 보정은 이 스킬이 하지 않는다. issue-work `--response`가 피드백·항목별 승인·승인분 보정을 맡는다([--response 흐름](../issue-work/response-call-flow.md)).

## Why

- 근거는 `issue-audit/SKILL.md` `## 역할 원칙`(구현자 선의 해석 금지), `#### 위험도 분류`(영향×발생확률 매트릭스), `#### 발견 기록 규칙`(원장 기등재 대조, 번호 계승), `#### 상태 산출`·`#### 판정 산출`에 있다.
- 원장 [K-0002](../../70_ledger/active/K-0002-audit-axis-tiebreak-absent.md): 축의 경계 판정 우선 규칙 부재(수용).
- 사용자가 구현 모델과 다른 벤더 모델로 직접 수행하고 구현 AI가 자동 실행·종료하지 않는 원칙, 전체 재감사 유지, 종료 기준 유한 체크리스트는 [ADR 0004](../../50_adr/active/0004-cross-model-audit-and-response-gate.md).
- 명세: [이슈 감사 요건](../../40_domain/specs/issue-audit.md)(0~3단계 요건, 번호 계승·계보, 리포트 구조·회차 보존).
- 매트릭스·등급별 처리는 [ADR 0006](../../50_adr/active/0006-risk-matrix-and-treatment.md), 기등재 대조·상태 행렬은 [ADR 0007](../../50_adr/active/0007-tech-debt-ledger-location-and-structure.md), 역피라미드·상태·판정 산출은 [ADR 0014](../../50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md). 카테고리 7종은 git-review 원본의 사본이다([ADR 0002](../../50_adr/active/0002-skill-independence-intentional-duplication.md)).
- 헬퍼·테스트 배치는 [ADR 0001](../../50_adr/active/0001-skill-deterministic-helper-test-convention.md). 헬퍼 분리 판단은 [architecture.md 디자인 원칙](../../10_rules/architecture.md).
