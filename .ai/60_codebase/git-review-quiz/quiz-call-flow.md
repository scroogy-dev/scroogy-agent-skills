---
last_synced: 2026-09-09
source_hash: 5ab2b67
status: current
---

# git-review-quiz 퀴즈 호출 흐름

## What

PR 또는 현재 브랜치의 변경에서 비즈니스·테크 문항을 만들어 대화형으로 풀거나 `--comment`로 PR 댓글에 게시한다. 게시 전 형식 검사와 승인 게이트를 지난다.

## How

```
git-review-quiz/SKILL.md
├── 1단계: 대상 식별          # PR 번호 인자 또는 git rev-parse @{upstream}·git remote get-url, gh pr view --repo (headRefOid·baseRefOid 보관)
├── 2단계: diff 수집          # gh pr diff --repo / 브랜치 모드는 git merge-base + git diff
├── 3단계: 근거 문서 확보     # .ai/30_contract·40_domain index, 근거 0건이면 알림·중단
├── 4단계: 옵션 확정          # --mcq·--open·--business·--tech, 형식 미지정 시 1회 질의
├── 5단계: 문항 생성·파일 작성   # templates/quiz-template.md → .ai/99_workspace/temp_review_quiz.md (--comment 는 temp_review_quiz_comment.md)
├── 6단계: 헬퍼 검사
│   ├── scripts/check-quiz.sh <파일>                                  # R1 헤더·R2 위치 행·R3 힌트 접기·R4 정답 접기·R5 선택지·R6 접기 밖 정답·R7 골격
│   └── scripts/check-quiz.sh --comment --head <SHA> --base <SHA> <파일>   # 댓글 모드는 permalink 필수, exit 0/1/2
└── 7단계: 대화형 진행 또는 게시
    └── --comment: 승인 게이트 (생략 불가) → gh pr comment --repo --body-file   # 본문 보간 금지, 파일 전달
```

## Why

- 근거는 `git-review-quiz/SKILL.md` `### 문항 본문에 코드 블록을 두지 않습니다`(행 접두어 파싱), `### 근거 규칙`(변경 자체를 묻고 실제 동작으로 확인), `### 힌트 규칙`, `#### 승인 게이트 (생략 불가)`에 있다.
- PR 식별·게시 규칙은 git-pr-feedback 원본의 사본이다(`## 관련 skill`, 의도적 중복은 [ADR 0002](../../50_adr/active/0002-skill-independence-intentional-duplication.md)). 계약: [GitHub 연동 수단](../../30_contract/github-integration.md). 정책: [외부 공개 행위 승인 게이트](../../40_domain/policies/local/external-action-approval-gate.md).
- 명세: [리뷰 퀴즈 요건](../../40_domain/specs/git-review-quiz.md)(옵션, 산출 파일, R1~R7, `--comment` 검사). 별도 스킬·문항 구성 순서·근거 규칙·일반 댓글 하나 게시는 [ADR 0017](../../50_adr/active/0017-git-review-quiz-study-mode.md).
- 원장 [K-0007](../../70_ledger/active/K-0007-quiz-permalink-target-unverified.md): permalink 검사가 경로·줄 범위를 대조하지 않는다. [K-0008](../../70_ledger/active/K-0008-quiz-format-vocab-fixture-absent.md): 미지원 형식 어휘 반례 fixture가 없다.
- 헬퍼·테스트 배치는 [ADR 0001](../../50_adr/active/0001-skill-deterministic-helper-test-convention.md).
