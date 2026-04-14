---
name: install-skills
description: scroogy-agent-skills 저장소의 skill을 선택하여 ~/.claude/skills/에 설치합니다. skill 설치, install skills 시 사용합니다.
---

## 개요

이 저장소의 skill을 선택하여 설치합니다.
이미 설치된 skill은 삭제 후 클린 설치합니다.

### 설치 경로 옵션

| 옵션              | 설치 경로                        |
| ----------------- | -------------------------------- |
| (없음)            | `~/.claude/skills/`              |
| `--claude`        | `~/.claude/skills/`              |
| `--agents`        | `~/.agents/skills/`              |
| `--antigravity`   | `~/.gemini/antigravity/skills/`  |
| `--codex`         | `~/.codex/skills/`               |
| `--junie`         | `~/.junie/skills/`               |
| `--all`           | 모두                             |

### 추가 옵션

| 옵션       | 설명                                                                 |
| ---------- | -------------------------------------------------------------------- |
| `--clear`  | 설치 전 대상 skills 디렉토리 내부의 모든 하위 항목을 삭제하고 클린 설치합니다. |

> `--clear`는 스킬명 변경 등으로 기존 스킬이 남아 있을 때 유용합니다. 디렉토리 자체(`~/.claude/skills/` 등)는 유지됩니다.

---

## 사용 가능한 skill

1. **ai-workspace** — `.ai/` 디렉토리 구조 초기화 및 갱신
2. **code-map** — 소스코드 기능별 엔트리포인트·호출 흐름 색인
3. **context-harvest** — 소스코드 바깥의 What+Why를 수집·증류하여 30_contract/, 40_domain/, 50_adr/ 문서 생성
4. **git-commit** — Conventional Commits 커밋 메시지 작성
5. **git-pr** — PR 제목/메시지 작성 (비즈니스+테크 관점)
6. **git-qa** — 배포 대상 PR에서 repo별 QA 체크리스트 생성
7. **git-review** — 비즈니스/테크 리뷰 수행
8. **git-review-context** — 리뷰 전 변경사항 사전 분석
9. **issue-audit** — 이슈 스펙 대비 구현 독립 감사
10. **issue-work** — 이슈 단위 스펙/계획/요약 관리
11. **readme-sync** — README.md 생성/재작성

> `install-skills` 자신은 설치 대상에서 제외합니다.

---

## 설치 절차

1. 인자에서 `--claude`, `--agents`, `--antigravity`, `--codex`, `--junie`, `--all`, `--clear` 옵션을 파싱합니다. 옵션이 없으면 기본값 `~/.claude/skills/`를 사용합니다.
2. `--clear`가 지정된 경우, 대상 skills 디렉토리 내부의 모든 하위 항목을 삭제합니다.
   ```bash
   rm -rf <target-skills-dir>/*
   ```
3. 사용자에게 번호 또는 skill명으로 설치할 skill을 선택받습니다.
4. 대상 디렉토리가 없으면 생성합니다.
5. 선택한 skill이 이미 설치되어 있으면 기존 디렉토리를 삭제한 뒤 새로 복사합니다.
   ```bash
   rm -rf <target-dir>/<skill-name>
   cp -r <skill-디렉토리> <target-dir>/
   ```
6. 복사 완료 후 설치된 skill 목록을 대상 경로별로 출력합니다.

## 참고

- `all`을 선택하면 모든 skill을 설치합니다 (`install-skills` 제외).
- `~/.claude/skills/`에 복사된 skill은 Claude Code가 자동 인식합니다. CLAUDE.md에 별도 등록이 필요 없습니다.
- `--all`을 사용하면 모든 경로에 동일한 skill을 설치합니다.
