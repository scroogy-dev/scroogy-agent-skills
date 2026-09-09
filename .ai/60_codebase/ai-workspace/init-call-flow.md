---
last_synced: 2026-09-09
source_hash: 5ab2b67
status: current
---

# ai-workspace init 호출 흐름

## What

`.ai/`가 없거나 사용자가 init을 고른 repo에 `templates/`를 복사해 `.ai/` 구조와 `AI-CONTEXT.md`를 새로 만든다. 기존 `.ai/`는 사용자 관리 파일까지 전부 지운다.

## How

```
ai-workspace/SKILL.md
├── 1단계: 프로파일 확인               # dev·doc 인자, 없으면 질의
├── 2단계: 모드 결정                   # .ai/ 없음이면 init, 있으면 init·update 질의 (init은 전체 덮어쓰기 경고)
├── init-0단계: 멀티/단독 자동 판정    # [ -f ../.ai/AI-CONTEXT.md ], 사용자에게 묻지 않음 (CoC)
├── init-1단계: 파일 복사
│   ├── rm -rf .ai                     # 전체 초기화, GNU cp 중첩 복사 회피 겸함
│   ├── cp -r templates/shared/.ai/    # 공통 골격: 10_rules 공통 4종, 각 index.md, 70_ledger/ledger-entry-template.md, .gitkeep
│   ├── cp -r templates/<profile>/.ai/*   # AI-CONTEXT.md, dev 전용 architecture.md·coding-convention.md
│   └── sed "> last updated: YYYY-MM-DD"  # date +%Y-%m-%d 로 치환
└── init-2단계: 완료 보고              # 생성 트리, multi면 상위 안내도 Repos 행 동기화 권유, solo면 단독 repo 명시
```

## Why

- 설계 근거는 `ai-workspace/SKILL.md` `### 설계 원칙`에 작성자가 기재했다. SSoT는 소스 코드, 멀티·단독은 CoC로 런타임 판정, 멀티면 `## 프로젝트 도메인` 표를 상위 안내도 `Repos` 행과 1:1 동기화한다.
- 판정 결과를 `AI-CONTEXT.md` 본문에 적지 않는 이유는 `### init-0단계`의 인용문에 있다. 클론 환경마다 부모 디렉토리가 달라 정적 기재는 거짓이 된다.
- 자매 스킬 ai-workspace-directory와의 역할 분담은 `## 이 구조와 함께 사용 가능한 skill`에 있다.
- 명세: [.ai 작업공간과 안내도 요건](../../40_domain/specs/ai-workspace.md)(init 전체 초기화, dev/doc 프로파일, `.ai/` 읽기 우선순위).
- 정책: [SSoT 원칙과 안내도 라우터](../../40_domain/policies/local/ssot-and-router-principle.md)(멀티/단독 CoC 런타임 판정, 판정 결과 미기재의 근거 #5).
- 배포 골격의 결정: `70_ledger/` index·항목 템플릿은 [ADR 0007](../../50_adr/active/0007-tech-debt-ledger-location-and-structure.md), `writing-principles.md` 버전 고정 배포는 [ADR 0008](../../50_adr/active/0008-writing-principles-ssot-distribution.md).
