---
last_synced: 2026-09-09
source_hash: 5ab2b67
status: current
---

# ai-workspace update 호출 흐름

## What

기존 `.ai/`를 보존하면서 규칙 파일·디렉토리 골격·`AI-CONTEXT.md`를 최신 구조로 맞춘다. 사용자 작성 파일은 없을 때만 빈 템플릿을 복사한다.

## How

```
ai-workspace/SKILL.md
├── 1·2단계: 프로파일·모드 결정
├── update-1단계: 10_rules/ 정리
│   ├── rm -f 구버전 정책 5종           # git-commit-policy·git-pr-policy·git-review-policy·git-review-context-builder·issue-workflow
│   ├── cp context-loading.md·writing-principles.md   # 버전 고정, 항상 덮어쓰기
│   └── 없을 때만 cp                    # file-change-policy·writing-principles-local, dev면 architecture·coding-convention
├── update-2단계: 20_templates/ 정리    # rm -rf .ai/20_templates/* (issue-work로 이관된 구 템플릿 제거)
├── update-3단계: 콘텐츠 디렉토리 정비   # 30_contract~90_issues 하위 구조·.gitkeep, index.md·ledger-entry-template.md 없으면 배포
│   └── 루트 파일 이동                  # 판단 기준 표로 specs·policies/local·active·superseded·archive, 불가면 legacy/
├── update-4단계: AI-CONTEXT.md 갱신
│   ├── scripts/check-context.sh <AI-CONTEXT.md>   # 8항목 판정, 누락 1행씩·exit 1, 조치는 SKILL.md
│   ├── .ai/ 한 줄 압축·트리 정렬 판단   # 헬퍼 밖 2항목, 트리 구조 해석
│   ├── last updated 를 실행일로 갱신
│   └── references/legacy-migration.md  # 구버전 구조 발견 시에만
└── update-5단계: 완료 보고             # 생성·이동·legacy/ 목록, legacy/ 는 수동 분류 요청
```

## Why

- 설계 근거는 `ai-workspace/SKILL.md` `### 설계 원칙`과 `## 디렉토리 트리 정렬 규칙`에 있다. 버전 고정 파일과 사용자 관리 파일을 나눈 이유는 update-1단계 주석에 있다.
- `check-context.sh`가 판정만 맡고 조치를 SKILL.md에 남긴 것은 [architecture.md 디자인 원칙](../../10_rules/architecture.md)의 역할 분담을 따른 것이다. 헬퍼·테스트 배치는 [ADR 0001](../../50_adr/active/0001-skill-deterministic-helper-test-convention.md).
- 원장 [K-0001](../../70_ledger/active/K-0001-update3-fixture-absent.md): update-3 파일 정리에 회귀 fixture가 없다(수용).
- 명세: [.ai 작업공간과 안내도 요건](../../40_domain/specs/ai-workspace.md)(update 구조 정합, 멱등 보강 검사 8종 + AI 판정 2종, 루트 상주 파일 제외, `## Git 정책` 표 미검사).
- 정책: [SSoT 원칙과 안내도 라우터](../../40_domain/policies/local/ssot-and-router-principle.md).
- 버전 고정 파일(`context-loading.md`·`writing-principles.md`)만 덮어쓰고 AI-CONTEXT 규칙 표 행을 멱등 보강으로 전파하는 결정은 [ADR 0008](../../50_adr/active/0008-writing-principles-ssot-distribution.md). `70_ledger/` 신규 디렉토리·골격 index 전파는 [ADR 0007](../../50_adr/active/0007-tech-debt-ledger-location-and-structure.md). 검사 표 10종 중 8종만 헬퍼로 옮긴 판단은 [ADR 0003](../../50_adr/active/0003-verification-levels-and-determinization.md) 대안 절.
