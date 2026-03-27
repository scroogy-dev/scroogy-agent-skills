---
name: install-skills
description: scroogy-agent-skills 저장소의 skill을 선택하여 ~/.claude/skills/에 설치합니다. skill 설치, install skills 시 사용합니다.
---

## 개요

이 저장소의 skill을 선택하여 `~/.claude/skills/`에 설치합니다.
이미 설치된 skill은 삭제 후 클린 설치합니다.

---

## 사용 가능한 skill

1. **ai-workspace** — `.ai/` 디렉토리 구조 초기화 및 갱신
2. **git-commit** — Conventional Commits 커밋 메시지 작성
3. **git-pr** — PR 제목/메시지 작성 (비즈니스+테크 관점)
4. **git-review** — 비즈니스/테크 리뷰 수행
5. **git-review-context** — 리뷰 전 변경사항 사전 분석
6. **issue-work** — 이슈 단위 스펙/계획/요약 관리
7. **sync-readme** — README.md 생성/재작성

> `install-skills` 자신은 설치 대상에서 제외합니다.

---

## 설치 절차

1. 사용자에게 번호 또는 skill명으로 설치할 skill을 선택받습니다.
2. `~/.claude/skills/` 디렉토리가 없으면 생성합니다.
3. 선택한 skill이 이미 설치되어 있으면 기존 디렉토리를 삭제한 뒤 새로 복사합니다.
   ```bash
   rm -rf ~/.claude/skills/<skill-name>
   cp -r <skill-디렉토리> ~/.claude/skills/
   ```
4. 복사 완료 후 설치된 skill 목록을 출력합니다.

## 참고

- `all`을 선택하면 모든 skill을 설치합니다 (`install-skills` 제외).
- skill은 `~/.claude/skills/`에 복사되면 자동 인식됩니다. CLAUDE.md에 별도 등록이 필요 없습니다.
