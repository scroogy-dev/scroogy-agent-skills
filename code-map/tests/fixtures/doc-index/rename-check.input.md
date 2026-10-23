# 입력: rename-check

- 사용자 선택: `check`
- HEAD 커밋: `b2b2b2b`
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
| keywords | 인사 규정, 연차, 재택근무 |
| ssot_dir | docs/ |
```

## 기존 색인 (`.ai/60_codebase/index.md`)

```markdown
---
last_synced: 2026-10-01 10:00
source_hash: a1a1a1a
ssot_dir: docs/
status: current
---

# 원본 문서 색인

> 색인 루트: `docs/` (안내도 `## 프로젝트 도메인` 표의 `ssot_dir`)

## docs

| 파일 경로 | 다루는 주제 | 관련 문서 |
|-----------|-------------|-----------|
| `docs/leave.md` | 연차 부여 기준 | [정책](../40_domain/policies/local/leave.md) |
| `docs/old.md` | 재택근무 신청 절차 | [ADR-0007](../50_adr/active/0007-remote-work.md), [WHY-NEEDED] 신청 기한을 3일 전으로 정한 근거가 문서화되지 않았습니다. |
```

## `git diff a1a1a1a..HEAD --name-status -M` 출력

```text
R100	docs/old.md	docs/remote-work.md
```

## `docs/` 아래 문서 전체

| 경로 | H1 제목 |
|------|---------|
| `docs/leave.md` | 연차 부여 기준 |
| `docs/remote-work.md` | 재택근무 신청 절차 |

`docs/old.md`는 없다.

## 기존 `.ai` 문서

- `.ai/40_domain/policies/local/leave.md`
- `.ai/50_adr/active/0007-remote-work.md`
