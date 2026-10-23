# 기대 결과: root-changed-check

- 0단계 루트 대조: 안내도 `docs/, handbook/`이 frontmatter `docs/`와 달라 루트 불일치다. `check`는 3단계의 루트 불일치 판정으로 넘긴다.

## 색인 (`.ai/60_codebase/index.md`)

- 색인 행과 frontmatter를 바꾸지 않는다. `check`는 파일 유효성 점검에서도 행을 지우지 않는다.

## 결과 보고

- 모드: check
- 루트 불일치를 보고한다 (안내도 `docs/, handbook/`, 색인 `docs/`).
- 색인 전체를 `[UPDATE-NEEDED]`로 보고하고 `rebuild`를 권고한다.
- 색인이 최신이라고 보고하지 않는다. `handbook/` 문서가 색인에 없다는 사실은 루트 불일치에 포함된다.
