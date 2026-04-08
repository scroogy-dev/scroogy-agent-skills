# scroogy-agent-skills

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

개인적으로 사용할 [Agent Skills](https://agentskills.io/)를 모아두는 프로젝트입니다.

Agent Skills는 특정 벤더에 종속되지 않는 오픈 포맷으로, Claude Code, Codex, Gemini CLI, GitHub Copilot, Cursor 등 다양한 AI 개발 도구에서 호환됩니다.

## Skill 목록

| Skill | 설명 |
|-------|------|
| [ai-workspace](./ai-workspace/) | `.ai/` 디렉토리 구조 초기화 및 갱신 (dev/doc 프로파일) |
| [code-map](./code-map/) | 소스코드 기능별 엔트리포인트·호출 흐름을 `.ai/60_codebase/`에 색인 |
| [git-commit](./git-commit/) | Conventional Commits 규칙에 따른 커밋 메시지 작성 |
| [git-pr](./git-pr/) | PR 제목/메시지 작성 (비즈니스+테크 관점) |
| [git-qa](./git-qa/) | 배포 대상 PR에서 repo별 QA 체크리스트 생성 |
| [git-review](./git-review/) | 비즈니스/테크 리뷰 수행 |
| [git-review-context](./git-review-context/) | 리뷰 전 변경사항 사전 분석 |
| [issue-audit](./issue-audit/) | 이슈 스펙 대비 구현을 독립 감사인 관점에서 검증 |
| [issue-work](./issue-work/) | 이슈 단위 스펙/계획/요약 관리 워크플로우 |
| [sync-readme](./sync-readme/) | 프로젝트 분석 후 README.md 생성/재작성 |

## Skill 간 관계

```
ai-workspace (디렉토리 스캐폴딩)
├── code-map            ← .ai/60_codebase/ 활용
├── git-commit          ← 독립 사용 가능
├── git-pr              ← git-commit 규칙 참조, .ai/ 문서 활용
├── git-qa              ← git-pr 참고, 독립 사용 가능
├── git-review          ← .ai/ 문서 활용
├── git-review-context  ← .ai/ 문서 활용, git-review와 함께 사용 가능
├── issue-audit         ← issue-work 스펙 활용, .ai/ 문서 활용
├── issue-work          ← .ai/90_issues/ 활용
└── sync-readme         ← 독립 사용 가능
```

모든 관계는 **권장(약한 의존)**이며, 각 skill은 단독으로도 사용할 수 있습니다.
`git-review`와 `git-review-context`는 함께 쓸 수 있지만 호출 의존 관계는 없습니다.

## 설치 방법

[install-skills](./install-skills/) skill을 사용하여 원하는 skill을 `~/.claude/skills/`에 선택 설치할 수 있습니다.

```
/install-skills
```

## 라이선스

이 프로젝트는 [Apache License 2.0](./LICENSE)에 따라 라이선스가 부여됩니다.

- 상업적 이용, 수정, 배포, 특허 사용, 개인 사용이 자유롭게 허용됩니다.
- 수정된 파일에는 변경 사항을 명시해야 합니다.
- 원본의 [NOTICE](./NOTICE) 파일을 배포 시 포함해야 합니다.
- 소스 파일 헤더 템플릿은 [LICENSE-HEADER.txt](./LICENSE-HEADER.txt)를 참고하세요.

### 개인 저작물 고지

이 프로젝트는 **scroogy-dev**의 개인 저작물입니다. 특정 기업이나 조직의 업무와 무관하게, 개인적인 목적으로 개발 및 관리되고 있습니다.

```
Copyright 2026 scroogy-dev (scroogy@swtest.co.kr)
```
