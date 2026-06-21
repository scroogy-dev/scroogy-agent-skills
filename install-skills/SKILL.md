---
name: install-skills
description: 현재 저장소의 skill을 선택하여 ~/.claude/skills/에 설치합니다. skill 설치, install skills 시 사용합니다.
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

설치 대상 목록은 본문에 고정하지 않고, 실행 시점에 저장소를 스캔하여 동적으로 구성합니다.

- 저장소 루트에서 `SKILL.md`를 보유한 1차 하위 디렉토리를 모두 수집합니다. `install-skills` 자신은 설치 대상에서 제외합니다.
- 각 skill의 한 줄 설명은 해당 `SKILL.md` frontmatter의 `description`에서 가져옵니다.
- 수집한 목록에 번호를 붙여 사용자에게 제시합니다.

```bash
for f in */SKILL.md; do
  d=$(dirname "$f")
  [ "$d" != "install-skills" ] && echo "$d"
done
```

---

## 설치 절차

1. 인자에서 `--claude`, `--agents`, `--antigravity`, `--codex`, `--junie`, `--all`, `--clear` 옵션을 파싱합니다. 옵션이 없으면 기본값 `~/.claude/skills/`를 사용합니다.
2. `--clear`가 지정된 경우, 대상 skills 디렉토리 내부의 모든 하위 항목을 삭제합니다.
   ```bash
   rm -rf <target-skills-dir>/*
   ```
3. 위 스캔으로 구성한 목록에서 번호 또는 skill명으로 설치할 skill을 선택받습니다.
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
