---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/28
last_harvested: 2026-09-09
---

# AI 도구별 스킬 포맷과 설치 경로 계약

## 계약

- 스킬 포맷은 Agent Skills 오픈 포맷(agentskills.io)이다. 디렉토리마다 `SKILL.md`(YAML 프론트매터 `name`·`description` + 마크다운 본문)를 두고, `scripts/`·`references/`·`templates/`를 번들할 수 있다. 번들 리소스는 에이전트가 읽기 전까지 컨텍스트 비용이 0이다(점진적 공개).
- `description`은 AI 도구가 스킬 선택 시 참고하며 말미에 트리거 키워드를 나열한다.
- 호환 도구와 글로벌 스킬 경로 5종: Claude Code `~/.claude/skills/`(기본), Agents `~/.agents/skills/`, Antigravity `~/.gemini/config/skills/`, Codex `~/.codex/skills/`, Junie `~/.junie/skills/`. 경로 표의 SSoT는 `install-skills/SKILL.md`다.
- Antigravity 공식 경로 `~/.gemini/config/skills/`는 Antigravity·Antigravity IDE·Antigravity CLI 전 제품에서 공유된다. 구 경로 `~/.gemini/antigravity/skills/`는 비표준이며 신 경로로 심링크된 환경에서만 동작한다. 심링크·부재·빈 디렉토리는 보존하고 비어 있지 않은 실제 디렉토리 잔존만 정리 대상이다.
- Claude Code는 `~/.claude/skills/`의 스킬을 자동 인식하며 슬래시 커맨드로 전역 호출된다.
- 설치본에는 `tests/`·`*.test.*` 개발 전용 경로를 포함하지 않는다. 제외 패턴의 단일 출처는 `install-skills/SKILL.md`의 복사 명령이다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #1 (agentskills.io SKILL.md 표준 포맷)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/1)
- [Issue #19 AI 도구 호환성 목록 갱신](https://github.com/scroogy-dev/scroogy-agent-skills/issues/19)
- [Issue #23 배포 시 dev 경로 제외](https://github.com/scroogy-dev/scroogy-agent-skills/issues/23)
- [Issue #28 Antigravity 설치 경로 공식화](https://github.com/scroogy-dev/scroogy-agent-skills/issues/28)
- [Issue #35 install-skills self-install 전환](https://github.com/scroogy-dev/scroogy-agent-skills/issues/35)
- Antigravity 공식 문서: https://antigravity.google/docs/skills (코드랩 "Authoring Google Antigravity Skills")
- Agent Skills 스펙: https://agentskills.io/

</details>
