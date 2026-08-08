---
name: install-skills
description: 현재 스킬 repo의 skill을 선택하여 Claude Code·Agents·Antigravity·Codex·Junie 경로(~/.claude/skills/ 등 5개)에 설치합니다. --all(전체 경로)·--clear(클린 재설치)·--self(self-install 부트스트랩) 옵션을 지원합니다. skill 설치, install skills, 스킬 배포, 스킬 재설치, self-install 시 사용합니다.
---

## 개요

이 저장소의 skill을 선택하여 설치합니다.
클린 설치(기존 설치본 삭제 후 복사)와 개발 전용 경로(`tests/` 등) 배포 제외의 단일 출처는 [설치 절차](#설치-절차) 5단계입니다.
규칙 배경(결정적 헬퍼의 테스트는 스킬 디렉토리에 함께 두되 배포에서 제외)은 이 repo의 ADR 0001에 있습니다 — repo 전용 문서라 설치본에서는 열람할 수 없어 링크하지 않습니다.

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
| `--clear`  | 설치 전 대상 skills 디렉토리 내부를 비웁니다 — 동작은 [설치 절차](#설치-절차) 2단계. |
| `--self`   | `install-skills` 자신을 설치 대상에 포함합니다 — 절차는 아래 Self-install 부트스트랩. |

> `--clear`는 스킬명 변경 등으로 기존 스킬이 남아 있을 때 유용합니다. 디렉토리 자체(`~/.claude/skills/` 등)는 유지됩니다.

### Self-install 부트스트랩

`install-skills`는 홈에 한 벌만 두고, 어느 스킬 repo에서든 복제본 없이 실행하는 것을 전제로 합니다.

1. 이 저장소 루트에서 최초 1회 `/install-skills --self`를 실행해 `install-skills` 자신을 홈(예: `~/.claude/skills/install-skills/`)에 설치합니다.
2. 이후에는 다른 스킬 repo 루트를 cwd(current working directory, 현재 작업 디렉토리)로 `/install-skills`를 실행하면, 그 repo에 복제본이 없어도 홈 설치본이 그 repo의 skill을 스캔·설치합니다.

self-install에도 일반 설치와 동일한 절차(클린 설치, 배포 제외 패턴)가 적용됩니다.

---

## 사용 가능한 skill

설치 대상 목록은 본문에 고정하지 않고, 실행 시점에 저장소를 스캔하여 동적으로 구성합니다.

**스킬 repo 판별 가드** — 스캔 전에 cwd가 스킬 repo인지 먼저 확인합니다. `*/SKILL.md`가 1건 이상 매칭되면 통과, 하나도 매칭되지 않으면 스킬 repo가 아닌 것으로 판정하고 경고 후 안전하게 중단합니다. 단일 스킬 repo도 지원 대상이므로 1건 통과는 설계 의도이며, 다만 **1건만 매칭되면** 해당 디렉토리가 스킬 repo가 맞는지 사용자에게 확인한 뒤 진행합니다 (이 확인은 아래 스니펫이 아니라 지침을 실행하는 AI가 대화로 수행합니다 — 스니펫은 0건 차단만 담당합니다). 임의의 cwd에서 실수로 실행해 엉뚱한 디렉토리를 소스로 삼는 오설치를 막기 위한 가드입니다.

```bash
# 스킬 repo 판별 가드 — */SKILL.md 가 0개면 중단 (셸 내장만 사용 — bash nullglob·zsh 모두 안전)
found=false
for f in */SKILL.md; do [ -e "$f" ] && { found=true; break; }; done
if [ "$found" != "true" ]; then
  echo "스킬 repo가 아닙니다 (*/SKILL.md 없음) — 설치를 중단합니다." >&2
  exit 1
fi
```

가드를 통과한 경우에만 아래 스캔을 진행하며, "스캔 목록 제시 → 사용자 선택" 절차는 기존과 동일하게 유지합니다.

- 저장소 루트에서 `SKILL.md`를 보유한 1차 하위 디렉토리를 모두 수집합니다. `install-skills` 자신은 설치 대상에서 제외하되, `--self`가 지정된 경우에는 제외를 해제하고 자기 자신을 대상에 포함합니다.
- 각 skill의 한 줄 설명은 해당 `SKILL.md` frontmatter의 `description`에서 가져옵니다.
- 수집한 목록에 번호를 붙여 사용자에게 제시합니다.

```bash
# 기본: install-skills 자신 제외. --self 지정 시(self_install=true) 제외 해제.
for f in */SKILL.md; do
  d=$(dirname "$f")
  { [ "$self_install" = "true" ] || [ "$d" != "install-skills" ]; } && echo "$d"
done
```

---

## 설치 절차

1. 인자에서 `--claude`, `--agents`, `--antigravity`, `--codex`, `--junie`, `--all`, `--clear`, `--self` 옵션을 파싱합니다. 옵션이 없으면 기본값 `~/.claude/skills/`를 사용합니다.
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
6. **설치 검증 (결정적 확인 우선 + AI 크로스체크)**: 복사 후 `verify-install.sh` 헬퍼로 설치 결과를 **결정적으로** 먼저 확인합니다(합/불은 exit code). 헬퍼는 **홈 설치본 우선, 없으면 cwd 폴백** 순으로 탐색합니다 — 홈 설치본(`~/.claude/skills/install-skills/scripts/verify-install.sh`)이 있으면 그것을 사용하고, 없으면 cwd(스킬 repo) 상대 경로 `install-skills/scripts/verify-install.sh`로 폴백합니다. 다른 스킬 repo에는 헬퍼 복제본이 없으므로 홈 설치본 탐색이 먼저입니다. AI는 그 PASS/FAIL 출력을 읽어 누락·경로 불일치를 **준결정적으로 크로스체크**합니다 — 결정적 결과가 우선이고 AI 판단은 보완입니다.
   ```bash
   # 헬퍼 탐색: 홈 설치본 우선, 없으면 cwd(스킬 repo) 폴백
   verify="$HOME/.claude/skills/install-skills/scripts/verify-install.sh"
   [ -x "$verify" ] || verify="install-skills/scripts/verify-install.sh"

   # 5단계의 skills·target 배열을 그대로 재사용 — 공통 검증(모든 대상에 적용).
   "$verify" --target "$target" "${skills[@]}"
   ```
   **Antigravity 경로가 설치 대상일 때만**(`--antigravity` 또는 `--all`) `--antigravity-legacy`를 붙여 구 Antigravity skills 경로의 레거시 잔존을 추가 점검합니다. 적용 조건·판정 기준·배경 상세는 [references/antigravity-legacy.md](references/antigravity-legacy.md)를 참조하세요.
   ```bash
   # Antigravity 대상 경로에 대해서만 추가 실행. $verify 는 위 헬퍼 탐색 결과를 재사용.
   "$verify" --target "$antigravity_target" --antigravity-legacy "${skills[@]}"
   ```
7. **레거시 경로 마이그레이션 (Antigravity 경로 한정)**: 6단계 레거시 점검이 FAIL(비어있지 않은 실제 디렉토리 잔존)이면 사용자에게 경고하고 정리를 제안하며, **승인 시에만 제거**합니다. INFO(심링크·부재·빈 디렉토리)는 보존하고 조치하지 않습니다 — 판정 기준·배경은 [references/antigravity-legacy.md](references/antigravity-legacy.md)에 있습니다.
8. 복사 완료 후 설치 결과를 이 skill 디렉토리의 `templates/install-result-template.md` 형식으로 보고합니다.

## 참고

- `all`을 선택하면 모든 skill을 설치합니다 (`install-skills` 제외, `--self` 지정 시 포함).
- `~/.claude/skills/`에 복사된 skill은 Claude Code가 자동 인식합니다. CLAUDE.md에 별도 등록이 필요 없습니다.
- `--all`을 사용하면 모든 경로에 동일한 skill을 설치합니다.
