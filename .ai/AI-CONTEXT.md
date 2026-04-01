# AI-CONTEXT.md

이 파일은 AI 어시스턴트를 위한 프로젝트 가이드입니다.
사람을 위한 안내는 프로젝트 루트의 [README.md](../README.md)를 참고하세요.

---

## 프로젝트 목적

개인적으로 사용하는 [Agent Skills](https://agentskills.io/)를 만들고 관리하는 저장소입니다.
Agent Skills 오픈 포맷을 따르며, Claude Code, Cursor, Gemini CLI, Junie 등 다양한 AI 도구에서 호환됩니다.

---

## AI가 작업 시 지켜야 할 원칙

1. **최소 변경 원칙** — 요청된 범위만 수정합니다. 불필요한 리팩토링, 주석 추가를 하지 않습니다.
2. **기존 패턴 준수** — 새 스킬 추가 시 기존 스킬 구조를 따릅니다.
3. **파일 생성 최소화** — 꼭 필요한 파일만 만듭니다. 기존 파일 편집을 우선합니다.
4. **커밋 전 확인** — 명시적으로 요청받지 않으면 커밋하지 않습니다.

---

## 디렉토리 구조

```
.
├── .ai/                        # AI 협업 가이드 문서 (이 디렉토리)
├── ai-workspace/               # .ai 작업공간 관리 스킬
│   ├── SKILL.md
│   └── templates/              # 프로파일별 템플릿
├── git-commit/                 # 커밋 메시지 작성 스킬
├── git-pr/                     # PR 제목/메시지 작성 스킬
├── git-review/                 # 리뷰 수행 스킬
├── git-review-context/         # 리뷰 전 사전 분석 스킬
├── issue-work/                 # 이슈 단위 작업 워크플로우 스킬
│   └── templates/              # 이슈 템플릿
├── install-skills/             # skill 선택 설치 스킬
├── sync-readme/                # README.md 생성/갱신 스킬
└── README.md
```

---

## 스킬 목록

| 스킬 | 설명 |
|------|------|
| `ai-workspace` | `.ai` 작업공간 설치 및 갱신 (dev/doc 프로파일 지원) |
| `git-commit` | Conventional Commits 규칙에 따른 커밋 메시지 작성 |
| `git-pr` | PR 제목/메시지 작성 (비즈니스+테크 관점) |
| `git-review` | 비즈니스/테크 리뷰 수행 |
| `git-review-context` | 리뷰 전 변경사항 사전 분석 |
| `issue-work` | 이슈 단위 스펙/계획/요약 관리 워크플로우 |
| `sync-readme` | 프로젝트를 분석하여 README.md 생성 또는 최신화 |

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

디렉토리명 앞의 숫자는 AI가 문서를 읽는 우선순위를 나타냅니다.
숫자가 낮을수록 먼저 읽어야 하며, 상위 우선순위 문서가 하위 우선순위 문서보다 우선합니다.

```
.ai/
├── 10_rules/        # [1순위] AI 행위 규칙
├── 20_templates/    # 필요 시 참조하는 템플릿
├── 30_contract/     # [2순위] 소프트웨어 계약 (index.md로 선택적 참조)
├── 40_domain/       # [3순위] 비즈니스 도메인 (index.md로 선택적 참조)
│   ├── policies/    # common/ (공통 정책, 동기화 대상) + local/ (이 repo 고유 정책)
│   └── specs/       # 기능 명세
├── 50_adr/          # [4순위] 의사결정 기록 (index.md로 선택적 참조)
├── 60_codebase/     # [5순위] 소스코드 엔트리포인트·호출 흐름 색인 (index.md로 선택적 참조)
├── 90_issues/       # 이슈 단위 작업 (active/ + archive/)
└── 99_workspace/    # AI 임시 작업공간
```

## 프로젝트 규칙

| 파일 | 설명 |
|------|------|
| `.ai/10_rules/architecture.md` | 프로젝트 아키텍처 방향 |

## Git 정책

아래 skill이 설치되어 있으면 해당 skill의 지침을 따릅니다.

| Skill | 설명 | 사용 시점 |
|-------|------|----------|
| `/git-commit` | 커밋 메시지 규칙 | 커밋 생성 시 |
| `/git-pr` | PR 생성 규칙 | PR 생성 시 |
| `/git-review-context` | 리뷰 전 변경사항 사전 분석 | 사용자 요청 시 |
| `/git-review` | 리뷰 수행 절차 | 리뷰 수행 시 |

## 이슈 작업 워크플로우

`/issue-work` skill이 설치되어 있으면 해당 skill의 지침을 따릅니다.