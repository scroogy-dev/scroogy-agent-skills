# 기대 결과: sync-same-root

- 0단계 루트 대조: 안내도 `docs/`와 frontmatter `docs/`가 같아 `sync`를 그대로 진행한다.

## 색인 (`.ai/60_codebase/index.md`)

| 파일 경로 | 처리 | 관련 문서 칸 |
|-----------|------|--------------|
| `docs/leave.md` | 갱신 (`M`) | 정책 링크 유지 |
| `docs/remote-work.md` | 이름 변경 (`R`, 두 경로 모두 `docs/` 아래) | 옛 행 `docs/old.md`의 `ADR-0007` 링크와 `[WHY-NEEDED] 신청 기한을 3일 전으로 정한 근거가 문서화되지 않았습니다.` 설명이 그대로 옮겨져 있다 |
| `docs/benefits.md` | 신규 (`R`, 새 경로만 `docs/` 아래) | 비어 있음 |

- `docs/gone.md`(`D`)·`docs/old.md`(이름 변경 전 경로)·`docs/out.md`(`R`, 이전 경로만 `docs/` 아래) 행은 없다.
- `drafts/` 경로의 행은 없다. `drafts/new-idea.md` 추가(`A`)는 `ssot_dir` 밖이다.
- frontmatter: `source_hash: b2b2b2b`, `ssot_dir: docs/`. 두 값은 위 행을 모두 반영한 뒤에 바꾼다.

## 결과 보고

- 모드: sync
- 색인 루트: docs/
- 문서 색인 건수(신규·갱신·삭제)는 판정하지 않는다. doc.md가 이름 변경을 어느 건수에 셀지 정하지 않았다.
