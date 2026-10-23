# 입력: root-changed-check

- 사용자 선택: `check`
- HEAD 커밋: `d4d4d4d`
- 실행 일시: 2026-10-23 10:00

## 안내도 머리 (`.ai/AI-CONTEXT.md`)

```markdown
# AI-CONTEXT.md

> last updated: 2026-10-23
> SSoT: 원본 문서. 이 파일은 안내도일 뿐 진실의 원천이 아니다.

## 프로젝트 도메인

| 항목 | 값 |
|------|----|
| domain | 사내 인사 규정 문서 |
| keywords | 인사 규정, 연차, 사원 핸드북 |
| ssot_dir | docs/, handbook/ |
```

## 기존 색인 (`.ai/60_codebase/index.md`)

```markdown
---
last_synced: 2026-10-01 10:00
source_hash: c3c3c3c
ssot_dir: docs/
status: current
---

# 원본 문서 색인

> 색인 루트: `docs/` (안내도 `## 프로젝트 도메인` 표의 `ssot_dir`)

## docs

| 파일 경로 | 다루는 주제 | 관련 문서 |
|-----------|-------------|-----------|
| `docs/leave.md` | 연차 부여 기준 | [정책](../40_domain/policies/local/leave.md), [WHY-NEEDED] 3년차 가산 규칙의 근거가 문서화되지 않았습니다. |
```

## `git diff c3c3c3c..HEAD --name-status -M` 출력

```text
M	.ai/AI-CONTEXT.md
```

안내도의 `ssot_dir` 값만 바뀐 커밋이다.

## `docs/`·`handbook/` 아래 문서 전체

| 경로 | H1 제목 |
|------|---------|
| `docs/leave.md` | 연차 부여 기준 |
| `handbook/intro.md` | 사원 핸드북 소개 |
| `handbook/conduct.md` | 행동 강령 |

## 기존 `.ai` 문서

- `.ai/40_domain/policies/local/leave.md`
