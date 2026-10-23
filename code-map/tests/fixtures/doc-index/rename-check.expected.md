# 기대 결과: rename-check

- 0단계 루트 대조: 안내도 `docs/`와 frontmatter `docs/`가 같아 `check`를 그대로 진행한다. 1~2단계를 건너뛰고 3단계만 실행한다.

## 색인 (`.ai/60_codebase/index.md`)

- 색인 행과 frontmatter를 바꾸지 않는다. `source_hash`는 `a1a1a1a`로 남는다.
- `docs/old.md` 행은 파일이 없어도 지우지 않는다. `ADR-0007` 링크와 `[WHY-NEEDED] 신청 기한을 3일 전으로 정한 근거가 문서화되지 않았습니다.` 설명이 그대로 남아 있다.
- `docs/remote-work.md` 행을 만들지 않는다. 행 추가는 1단계의 일이다.

## 결과 보고

- 모드: check
- `docs/old.md` 행을 파일 유효성 점검의 `[UPDATE-NEEDED]`로 보고한다.
- 색인이 최신이라고 보고하지 않는다.

## 이어지는 `sync`

이 실행 뒤의 색인은 `docs/old.md` 행과 `source_hash: a1a1a1a`를 그대로 가진다. 따라서 이어지는 `sync`는 같은 `R100` 행을 받아 Why 태깅을 `docs/remote-work.md`로 옮길 수 있다. 그 동작은 `sync-same-root`가 판정하므로 이 케이스에서는 보지 않는다.
