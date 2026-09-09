---
last_synced: 2026-09-09
source_hash: 5ab2b67
status: current
---

# git-pr-feedback 대응 호출 흐름

## What

PR 리뷰 코멘트를 수집·분류해 항목별 의견을 내고, 사용자 선택에 따라 답글 게시·코드 수정·스레드 resolve·원장 등재로 대응한다. 외부 공개 행위는 승인 게이트를 지난다.

## How

```
git-pr-feedback/SKILL.md
├── 코멘트 수집
│   ├── 대상 PR 식별      # git rev-parse @{upstream}, git remote get-url, gh pr view --repo --json …headRefOid,isCrossRepository (불변값 보관)
│   ├── gh api --paginate reviews·comments, gh api graphql --paginate reviewThreads
│   └── 폴백: GitHub MCP pull_request_read
├── 분류·의견 제시        # 5유형(조치 필요·불필요·수용·코멘트로 충분·확인 필요), 파일 수정·게시 금지
├── 사용자 선택·승인 게이트 (생략 불가)
│   ├── 항목별 선택        # 코드 수정 / 답글 / 보류 / 수용(원장 등재)
│   └── 기존 원장 항목 종결   # 코드 수정으로 원인이 사라진 K 항목을 해소로
└── 조치 실행
    ├── 코드 수정
    │   ├── scripts/verify-push.sh --normalize <URL>
    │   ├── scripts/verify-push.sh --remote --repo --branch --head-oid --approved-sha   # fetch·push URL 1개·원격 ref·조상 관계, exit 0/1/2
    │   ├── git push --force-with-lease
    │   └── gh pr view --json headRefOid
    ├── 답글 게시          # gh pr comment --body-file / gh api …/comments/<id>/replies (폴백 MCP add_issue_comment·add_reply_to_pull_request_comment)
    ├── 스레드 resolve     # gh api graphql resolveReviewThread (폴백 MCP pull_request_review_write resolve_thread)
    └── 원장 등재          # .ai/70_ledger/ledger-entry-template.md → active/K-<번호>-<slug>.md, index.md 갱신
```

## Why

- 근거는 `git-pr-feedback/SKILL.md` `### 대상 PR 식별`(최초 조회부터 `--repo`·`--hostname` 명시), `### 항목별 선택`(등재 없는 수용은 추적처가 없다, 중복 등재 금지), `### 기존 원장 항목의 종결`, `### 승인 게이트 (생략 불가)`, `### 코드 수정`(포크 PR 제외, `git add -A` 금지, pushurl 복수 위험)에 있다.
- 원장 형식은 ai-workspace가 배포하는 `.ai/70_ledger/ledger-entry-template.md`이며 issue-work `--response`와 공유한다. 등재 주체가 둘이라 어느 스킬에도 두지 않는다(ai-workspace SKILL.md `## 이 구조와 함께 사용 가능한 skill`).
- 계약: [GitHub 연동 수단](../../30_contract/github-integration.md)(gh 기본·MCP 폴백, `--repo`·`--hostname`, resolve 스키마 필수 입력, push URL 1개 규칙). 명세: [PR 리뷰 코멘트 대응 요건](../../40_domain/specs/git-pr-feedback.md).
- 정책: [외부 공개 행위 승인 게이트](../../40_domain/policies/local/external-action-approval-gate.md)(답글·resolve·push 승인, 승인 값 불변 보관·재대조, userinfo 제거). 별도 스킬로 둔 결정과 의견 유형 5종은 [ADR 0012](../../50_adr/active/0012-git-pr-feedback-separate-skill.md).
- 원장 등재·종결 규칙과 소비자 상태 행렬은 [ADR 0007](../../50_adr/active/0007-tech-debt-ledger-location-and-structure.md).
- 헬퍼·테스트 배치는 [ADR 0001](../../50_adr/active/0001-skill-deterministic-helper-test-convention.md).
