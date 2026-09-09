---
last_synced: 2026-09-09
source_hash: 5ab2b67
status: current
---

# issue-audit 계획 감사(--plan) 호출 흐름

## What

구현 전 spec·plan 자체를 GitHub 이슈 본문과 `.ai` 문서에 대조한다. issue-work 계획 종료 게이트 뒤·Task 0 앞에 이슈마다 사용자가 수행 여부를 정하고, 계획 모델과 다른 벤더 모델로 직접 실행한다.

## How

```
issue-audit/SKILL.md `### --plan`
├── 0단계: 컨텍스트 수집          # 이슈 본문, .ai/30_contract·40_domain·50_adr·70_ledger (구현 diff 제외, summary 미읽기)
├── 1단계: 적합성 검증            # 행 = 이슈 본문 요구 항목 ↔ spec 포함·제외 (PASS/FAIL/PARTIAL/N/A), DoD 표는 포함 R ↔ `### R<n>` 그룹
├── 2단계: 비판적 검증 5관점
│   ├── 추적성 [D]                # scripts/check-plan.sh --trace <spec> <plan>
│   ├── 가짜 [D] 사전 판별 [D]    # 구현 전 트리에서 [D] 명령 실행, 정상 명령은 실패해야 함, 회귀 방지 항목은 예외 표시 (수동)
│   └── 범위·모호성·과잉 설계 [QD]
├── 공통 규칙                     # classify-risk.sh 등급·처리·상태·판정, 원장 대조, next-finding-number.sh 는 최종 감사와 동일
└── 결과 기록                     # .ai/99_workspace/issue-<번호>-plan-audit-report.md, 회차 보존·--clear 이관 동일, F- 번호 축은 최종 감사와 분리
```

추적성 헬퍼 내부:

```
check-plan.sh --trace <spec> <plan>
├── 인자 검사                     # 모드 미지정·인자 부족·읽을 수 없는 파일은 exit 2
├── skip (awk 전처리, 두 파서 공통)
│   ├── 코드 펜스 상태            # ```·~~~, 여는 문자·길이를 기억해 같은 문자 같은 개수 이상에서만 닫힘
│   ├── HTML 블록 주석 상태       # 여러 줄 주석 안 행 건너뜀, `--> <!--` 연속 주석은 after_close 로 이어짐
│   └── scan                      # 행 안 주석·인라인 코드를 왼쪽부터 읽어 먼저 시작한 쪽이 이김
├── spec 파서                     # `**포함**` 아래 `- R<n>: ` → INC, `## 완료의 정의` 안 `### R<n>: ` → DOD
├── plan 파서                     # `### Task ` 블록별 `대상 요구사항` 값의 R<n> → REF, 없으면 NOFIELD (고정 Task 0·N 제외)
└── 대조                          # R 없는 DoD 그룹 / DoD 없는 R / Task 없는 R / 대상 요구사항 없는 일반 Task / 추적 불가 → 1행씩·exit 1
```

## Why

- 근거는 `issue-audit/SKILL.md` `### --plan` 소절(시점·입력·대조 기준·판정 매핑·5관점)과 `check-plan.sh` 머리말(읽는 앵커, 판정 순서, 행 단위 경계)에 있다.
- 원장 [K-0009](../../70_ledger/active/K-0009-plan-audit-fake-d-check-manual.md): 가짜 `[D]` 사전 판별의 헬퍼 결정화 보류(기술부채). [K-0010](../../70_ledger/active/K-0010-check-plan-line-based-markdown-boundary.md): 행 단위 파서라 여러 행 코드 스팬 등은 구분하지 않음(known issue).
- 계획 감사 리포트의 보정은 issue-work `--response`가 spec·plan에 반영하고 건수를 summary `계획 감사` 줄에 적는다([--response 흐름](../issue-work/response-call-flow.md)).
- 명세: [이슈 감사 요건](../../40_domain/specs/issue-audit.md) `--plan` 항목. 요구사항 층·계획 감사 모드·수행 여부 사용자 선택은 [ADR 0016](../../50_adr/active/0016-spec-requirements-layer-and-plan-audit.md). 가짜 `[D]` 함정("틀렸을 때 검사가 실제로 실패하나")은 [ADR 0003](../../50_adr/active/0003-verification-levels-and-determinization.md) 근거 절.
- 헬퍼·테스트 배치는 [ADR 0001](../../50_adr/active/0001-skill-deterministic-helper-test-convention.md).
