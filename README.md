# scroogy-agent-skills

개인적으로 사용할 [Agent Skills](https://agentskills.io/)를 모아두는 프로젝트입니다.

Agent Skills는 특정 벤더에 종속되지 않는 오픈 포맷으로, Claude Code, Codex, Gemini CLI, GitHub Copilot, Cursor 등 다양한 AI 개발 도구에서 호환됩니다.

## Skill 목록

| Skill | 설명 |
|-------|------|
| [ai-workspace](./ai-workspace/) | `.ai/` 디렉토리 구조 초기화 및 갱신 (dev/doc 프로파일) |
| [git-commit](./git-commit/) | Conventional Commits 규칙에 따른 커밋 메시지 작성 |
| [git-pr](./git-pr/) | PR 제목/메시지 작성 (비즈니스+기술 관점) |
| [git-review](./git-review/) | 비즈니스/테크 리뷰 수행 |
| [git-review-context](./git-review-context/) | 리뷰 전 변경사항 사전 분석 |
| [issue-work](./issue-work/) | 이슈 단위 스펙/계획/요약 관리 워크플로우 |
| [sync-readme](./sync-readme/) | 프로젝트 분석 후 README.md 생성/재작성 |

## Skill 간 관계

```
ai-workspace (디렉토리 스캐폴딩)
├── git-commit        ← 독립 사용 가능
├── git-pr            ← git-commit 규칙 참조, .ai/ 문서 활용
├── git-review        ← git-review-context와 연계, .ai/ 문서 활용
│   └── git-review-context
├── issue-work        ← .ai/90_issues/ 활용
└── sync-readme       ← 독립 사용 가능
```

모든 관계는 **권장(약한 의존)**입니다. 각 skill은 단독으로도 사용할 수 있습니다.

## 설치 방법

[install-skills](./install-skills/) skill을 사용하여 원하는 skill을 `~/.claude/skills/`에 선택 설치할 수 있습니다.

```
/install-skills
```
