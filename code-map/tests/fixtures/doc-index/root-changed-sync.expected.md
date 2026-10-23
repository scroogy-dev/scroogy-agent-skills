# 기대 결과: root-changed-sync

- 0단계 루트 대조: 안내도 `docs/, handbook/`이 frontmatter `docs/`와 달라 루트 불일치다. `sync`를 `rebuild`로 전환하고 전환 사실을 사용자에게 알린다.
- diff 출력(안내도 한 파일)으로 스캔 범위를 정하지 않는다. 범위는 안내도 `ssot_dir` 아래 문서 전체다.

## 색인 (`.ai/60_codebase/index.md`)

| 파일 경로 | 관련 문서 칸 |
|-----------|--------------|
| `docs/leave.md` | 정책 링크와 `[WHY-NEEDED] 3년차 가산 규칙의 근거가 문서화되지 않았습니다.` 설명이 그대로 있다 (Why 태깅 보존) |
| `handbook/conduct.md` | `[WHY-NEEDED]` (금지 행위 규칙의 근거 요청) |
| `handbook/intro.md` | 비어 있음 |

- 절 제목은 `docs`·`handbook` 두 개다.
- 머리의 색인 루트는 `docs/, handbook/`이다.
- frontmatter: `ssot_dir: docs/, handbook/`, `source_hash: d4d4d4d`. 두 값은 위 행을 모두 반영한 뒤에 바꾼다.

## 결과 보고

- 모드: sync → rebuild
- 색인 루트: docs/, handbook/
- [WHY-NEEDED]: 2건
