---
name: install-skills
description: 현재 저장소의 skill을 선택하여 ~/.claude/skills/에 설치합니다. skill 설치, install skills 시 사용합니다.
---

## 개요

이 저장소의 skill을 선택하여 설치합니다.
이미 설치된 skill은 삭제 후 클린 설치합니다.
설치 시 `tests/` 같은 개발 전용 경로는 배포 결과물에서 제외합니다 — 제외 패턴의 단일 출처는 [설치 절차](#설치-절차) 5단계이며, 규칙 배경은 [ADR](../.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md)를 참조하세요.

### 설치 경로 옵션

| 옵션              | 설치 경로                        |
| ----------------- | -------------------------------- |
| (없음)            | `~/.claude/skills/`              |
| `--claude`        | `~/.claude/skills/`              |
| `--agents`        | `~/.agents/skills/`              |
| `--antigravity`   | `~/.gemini/config/skills/`       |
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
5. 선택한 skill이 이미 설치되어 있으면 기존 디렉토리를 삭제한 뒤, 개발 전용 경로를 제외하고 복사합니다.
   아래 `--exclude` 플래그가 제외 패턴(`tests/`, `*.test.*`)의 **단일 출처**입니다 — ADR·AI-CONTEXT는 이 목록을 복제하지 않고 이 절차를 참조만 합니다.
   선택 목록은 **배열**로 다뤄 zsh/bash 모두에서 단어 분리에 깨지지 않게 합니다.
   ```bash
   # 선택한 skill 목록과 대상 경로 (배열 — zsh word-splitting 회피)
   skills=(git-commit git-pr issue-work)
   target="$HOME/.claude/skills"
   for s in "${skills[@]}"; do
     rm -rf "$target/$s"
     rsync -a --exclude 'tests/' --exclude '*.test.*' "$s/" "$target/$s/"
     # rsync 미가용 환경 fallback (tests/ 디렉토리 + *.test.* 파일 모두 제외):
     #   cp -r "$s" "$target/" && rm -rf "$target/$s/tests" && find "$target/$s" -name '*.test.*' -delete
   done
   ```
6. **설치 검증 (결정적 확인 우선 + AI 크로스체크)**: 복사 후 `install-skills/scripts/verify-install.sh`(저장소 루트 기준 경로)로 설치 결과와 레거시 잔존을 **결정적으로** 먼저 확인합니다(합/불은 exit code). AI는 그 PASS/FAIL 출력을 읽어 누락·경로 불일치를 **준결정적으로 크로스체크**합니다 — 결정적 결과가 우선이고 AI 판단은 보완입니다.
   ```bash
   # 5단계의 skills·target 배열을 그대로 재사용.
   # --antigravity 설치일 때만 --antigravity-legacy 를 붙인다. 그 외 대상(--claude 등)에는 생략한다.
   install-skills/scripts/verify-install.sh --target "$target" --antigravity-legacy "${skills[@]}"
   ```
   `--antigravity-legacy`는 구 Antigravity skills 경로(리터럴은 SKILL.md가 아니라 스크립트가 보유)를 점검 대상에 추가하며, `--antigravity` 설치에만 사용합니다.
7. **레거시 경로 마이그레이션 (Antigravity 한정)**: 6단계 검증이 구 경로를 다음과 같이 판정하면 그에 맞춰 처리합니다.
   - **심링크이거나 없으면 보존**합니다(PASS). 현재 신(공식) 경로와 동일 위치를 가리키므로(이 환경의 inode 동일 사례) 건드리지 않고 정보만 출력합니다.
   - **실제 디렉토리로 내용이 잔존하면**(FAIL) 사용자에게 경고하고 정리(제거)를 제안합니다. 승인 시에만 제거합니다.
   - 배경: `--clear`는 신(대상) 경로만 비우므로, 구 경로가 실제 디렉토리로 남으면 동일 skill이 중복 인식될 수 있어 install-skills가 이 레거시 잔존을 명시적으로 처리합니다.
8. 복사 완료 후 설치된 skill 목록을 대상 경로별로 출력합니다.

## 참고

- `all`을 선택하면 모든 skill을 설치합니다 (`install-skills` 제외).
- `~/.claude/skills/`에 복사된 skill은 Claude Code가 자동 인식합니다. CLAUDE.md에 별도 등록이 필요 없습니다.
- `--all`을 사용하면 모든 경로에 동일한 skill을 설치합니다.
