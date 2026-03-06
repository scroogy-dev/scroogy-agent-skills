# AI-CONTEXT.md

이 파일은 AI 어시스턴트를 위한 프로젝트 가이드입니다.
사람을 위한 안내는 프로젝트 루트의 [README.md](../README.md)를 참고하세요.

---

## 프로젝트 목적

개인적으로 사용하는 [Agent Skills](https://agentskills.io/)를 만들고 관리하는 저장소입니다.
Agent Skills 오픈 포맷을 따르며, Claude Code, Cursor, Gemini CLI, Junie 등 다양한 AI 도구에서 호환됩니다.

---

## 디렉토리 구조

```
.
├── .ai/                        # AI 협업 가이드 문서 (이 디렉토리)
├── ai-workspace/               # .ai 작업공간 관리 스킬
│   ├── SKILL.md                # 스킬 정의 및 실행 절차
│   └── templates/              # 프로파일별 템플릿
│       ├── shared/.ai/         # 공통 파일 (10_rules, 20_templates 등)
│       ├── dev/.ai/            # 개발 프로젝트용 AI-CONTEXT.md
│       └── doc/.ai/            # 문서 프로젝트용 AI-CONTEXT.md
├── sync-readme/                # README.md 생성/갱신 스킬
│   └── SKILL.md
└── README.md
```

---

## 스킬 목록

| 스킬 | 설명 | 상태 |
|------|------|------|
| `ai-workspace` | `.ai` 작업공간 설치 및 갱신 (dev/doc 프로파일 지원) | 개발 중 |
| `sync-readme` | 프로젝트를 분석하여 README.md 생성 또는 최신화 | 개발 중 |

---

## 스킬 작성 규칙

### SKILL.md 포맷

모든 스킬은 YAML 프론트매터와 마크다운 본문으로 구성됩니다.

```markdown
---
name: <skill-name>          # 스킬 식별자 (디렉토리명과 일치)
description: <한 줄 설명>   # AI 도구가 스킬 선택 시 참고하는 설명
---
```

### 명명 규칙

- 스킬 디렉토리명: `kebab-case`
- `name` 필드: 디렉토리명과 동일하게 유지

### 언어

- 사용자 대화 및 스킬 설명: **한국어**
- 코드, 파일명, 기술 용어: **영어**

---

## .ai 디렉토리 구조

```
.ai/
├── 10_rules/        # AI 행위 규칙 (절차, 코딩 컨벤션, 커밋 규칙 등)
├── 20_templates/    # 각종 템플릿 파일
├── 30_contract/     # API 명세, 연동 규약 등 소프트웨어 계약
│   └── index.md     # 디렉토리 내 파일별 요약 목차 (AI 선택적 참조용)
├── 40_domain/       # 비즈니스 도메인 정보
│   ├── index.md     # 디렉토리 내 파일별 요약 목차 (AI 선택적 참조용)
│   ├── specs/       # 비즈니스 스펙
│   ├── policies/    # 비즈니스 정책
│   └── glossary.md  # 용어 사전
├── 50_adr/          # 의사결정 기록 (Architecture Decision Records)
│   ├── active/
│   └── superseded/
├── 90_issues/       # 이슈 단위 작업
│   ├── active/      # issue-<번호>/ 디렉토리 단위로 관리
│   │   └── issue-<번호>/
│   │       ├── issue-<번호>-spec.md
│   │       ├── issue-<번호>-plan.md
│   │       └── issue-<번호>-summary.md
│   └── archive/     # 완료된 이슈 디렉토리 이관
└── 99_workspace/    # AI 작업 중 생성·사용하는 임시 파일 작업공간
```

**디렉토리 우선순위:**
디렉토리명 앞의 숫자는 AI가 문서를 읽는 우선순위를 나타냅니다.
숫자가 낮을수록 먼저 읽어야 하며, 상위 우선순위 문서가 하위 우선순위 문서보다 우선합니다.

| 디렉토리 | 우선순위 | 설명 |
|---------|---------|------|
| `10_rules/` | 1순위 | 모든 작업에 앞서 반드시 숙지해야 할 행위 규칙 |
| `30_contract/` | 2순위 | 절대 위반하면 안 되는 소프트웨어 계약 |
| `40_domain/` | 3순위 | 작업 맥락 이해를 위한 비즈니스 도메인 지식 |
| `50_adr/` | 4순위 | 과거 의사결정 기록 및 근거 |
| `20_templates/` | - | 필요 시 참조하는 템플릿 |
| `90_issues/` | - | 현재 이슈 작업 문서 |
| `99_workspace/` | - | AI 작업 중 생성·사용하는 임시 파일 작업공간 |

## Git 정책

| 파일 | 설명 |
|------|------|
| `.ai/10_rules/git-commit-policy.md` | 커밋 메시지 규칙 |
| `.ai/10_rules/git-pr-policy.md` | PR 생성 규칙 |
| `.ai/10_rules/git-review-policy.md` | PR 리뷰 및 셀프 리뷰 체크리스트 |
| `.ai/10_rules/git-review-context-builder.md` | 리뷰 전 변경 사항 사전 분석 및 컨텍스트 정리 |

## 이슈 작업 워크플로우

이슈 작업 시 `.ai/90_issues/active/issue-<번호>/` 아래 3개 파일을 작성합니다.
자세한 운영 규칙은 `.ai/10_rules/issue-workflow.md`를 참고하세요.

| 파일 | 역할 | 생명주기 |
|------|------|---------|
| `issue-<번호>-spec.md` | 목표, 범위, DoD, 연관 문서 | 안정 — 작성 후 거의 변경 없음 |
| `issue-<번호>-plan.md` | 실행 Task 목록 + 체크박스 | 가변 — 실행 결과에 따라 Task 추가·수정·삭제 가능 |
| `issue-<번호>-summary.md` | 다음 작업, Task별 수행 결과 | 누적 — Task 완료 시마다 갱신 |

템플릿은 `.ai/20_templates/` 아래에 보관합니다.

---

## AI가 작업 시 지켜야 할 원칙

1. **최소 변경 원칙** — 요청된 범위만 수정합니다. 불필요한 리팩토링, 주석 추가를 하지 않습니다.
2. **기존 패턴 준수** — 새 스킬 추가 시 기존 스킬 구조를 따릅니다.
3. **파일 생성 최소화** — 꼭 필요한 파일만 만듭니다. 기존 파일 편집을 우선합니다.
4. **커밋 전 확인** — 명시적으로 요청받지 않으면 커밋하지 않습니다.
