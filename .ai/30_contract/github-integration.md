---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/64
last_harvested: 2026-09-09
---

# GitHub 연동 수단 계약 (gh CLI·GitHub MCP)

## 계약

- 기본 수단은 `gh` CLI(GitHub 명령줄 도구)다. `gh`가 없거나 인증되지 않았으면 GitHub MCP(Model Context Protocol)로 폴백한다. MCP 도구 입력은 소유자/저장소만 받고 호스트를 받지 않으므로 폴백은 `github.com` 대상에 한정한다.
- 저장소는 `[호스트/]소유자/저장소`를 `gh pr` 계열에 `--repo`, `gh api` 계열에 `--hostname`으로 명시한다. 생략하면 `gh` 로컬 컨텍스트나 `GH_REPO`·`GH_HOST` 환경변수가 저장소를 고른다. `--repo`를 쓰면 PR 선택자 인자가 필수라 브랜치 이름을 지정한다.
- 긴 본문은 `--body-file`로 전달한다(PR 본문, 이슈 댓글, 퀴즈 댓글). 이슈 번호 인자는 앞자리 0을 제거한 값이다.
- PR 생성은 `gh pr create --repo --base --head --body-file`이며 `--repo`·`--head`를 생략하지 않는다. MCP `create_pull_request`는 `base`를 누락하면 보정해 넘긴다.
- MCP `pull_request_review_write`의 `resolve_thread`는 활성 스키마가 `method`·`threadId` 외에 `owner`·`repo`·`pullNumber`를 필수로 요구한다. 실행 시점의 활성 스키마를 확인해 필수 입력 전부를 보관한 불변값으로 채운다.
- 리뷰·코멘트 수집은 `gh api --paginate`(reviews, issues comments)와 GraphQL(스레드 `databaseId`·resolve 상태)로 한다.
- push 전에 `git remote get-url --push --all`로 push URL 전체를 조회한다. push URL이 정확히 1개이고 fetch·push URL 모두 head 저장소와 일치할 때만 push한다. 원격 URL은 정규화해 비교하고 표시할 때는 userinfo를 제거한다.
- 브랜치 ref 조회는 `refs/heads/<브랜치>` 완전 ref로 한다(`ls-remote` 다중 매칭 방지).
- Git ref·SHA·ID·경로 등 동적 값은 작은따옴표 인용과 `'\''` 치환으로 셸에 전달한다.
- 슬래시 커맨드 스킬은 `~/.claude/skills/`에서 전역 인식되며 CLAUDE.md 등록이 필요 없다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #58 git-pr PR 제출까지 확장](https://github.com/scroogy-dev/scroogy-agent-skills/issues/58)
- [Issue #64 git-pr-feedback 스킬 신규 작성](https://github.com/scroogy-dev/scroogy-agent-skills/issues/64)
- [Issue #74 긴 산출물 파일 1회 생성](https://github.com/scroogy-dev/scroogy-agent-skills/issues/74)
- [Issue #92 git-review-quiz 스킬 신설](https://github.com/scroogy-dev/scroogy-agent-skills/issues/92)
- [PR #65 리뷰 코멘트 (push URL·userinfo·MCP 스키마·GH_REPO)](https://github.com/scroogy-dev/scroogy-agent-skills/pull/65)
- 구현 SSoT: `git-pr/SKILL.md`, `git-pr-feedback/SKILL.md`, `git-review-quiz/SKILL.md`, `git-pr/scripts/verify-submit.sh`, `git-pr-feedback/scripts/verify-push.sh`

</details>
