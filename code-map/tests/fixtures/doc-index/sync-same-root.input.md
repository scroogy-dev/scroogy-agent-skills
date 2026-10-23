# 입력: sync-same-root

- 사용자 선택: `sync`
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
| `docs/gone.md` | 출장비 정산 규정 | |
| `docs/old.md` | 재택근무 신청 절차 | [ADR-0007](../50_adr/active/0007-remote-work.md), [WHY-NEEDED] 신청 기한을 3일 전으로 정한 근거가 문서화되지 않았습니다. |
| `docs/out.md` | 복지 제도 초안 | |
```

## `git diff a1a1a1a..HEAD --name-status -M` 출력

```text
M	docs/leave.md
D	docs/gone.md
R100	docs/old.md	docs/remote-work.md
R100	docs/out.md	drafts/out.md
R100	drafts/benefits.md	docs/benefits.md
A	drafts/new-idea.md
```

## 변경 후 `docs/` 아래 문서 (diff에 잡힌 파일)

| 경로 | H1 제목 | 머리 요약 | 근거 서술 |
|------|---------|-----------|-----------|
| `docs/leave.md` | 연차 부여 기준 | 입사 1년 후 15일, 3년차부터 2년마다 1일 가산 | 있음 |
| `docs/remote-work.md` | 재택근무 신청 절차 | 내용 변경 없이 이름만 바뀜 | 없음 (규칙만 적힘) |
| `docs/benefits.md` | 복지 포인트 | 연 100만 포인트를 지급한다 | 해당 없음 (안내 문서) |

## 기존 `.ai` 문서

- `.ai/40_domain/policies/local/leave.md`
- `.ai/50_adr/active/0007-remote-work.md`
