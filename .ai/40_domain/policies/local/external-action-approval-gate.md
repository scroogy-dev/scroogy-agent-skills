---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/58
last_harvested: 2026-09-09
---

# 외부 공개 행위 승인 게이트 정책

## 정책

- 외부 공개 행위는 실행 전에 최종 내용을 그대로 제시하고 사용자 승인을 받는다. 승인 게이트는 옵션·유형과 무관하게 생략할 수 없다.
- 대상: PR 생성(git-pr), 리뷰 답글 게시·스레드 resolve·push(git-pr-feedback), 이슈 댓글 등록(issue-work `--clear`), 퀴즈 댓글 게시(git-review-quiz `--comment`).
- 승인 대상이 긴 산출물이면 파일 경로와 요약 제시가 "제시"에 해당한다 ([ADR 0013](../../../50_adr/active/0013-long-output-single-file-generation.md)).
- 승인한 값(제목·본문 파일, 대상 저장소, 소스 브랜치, SHA)은 불변 보관하고 실행 직전에 재대조한다. 승인 후 원격 상태가 달라졌으면 실행하지 않고 중단해 다시 승인받는다.
- 저장소는 현재 브랜치의 upstream 원격 URL에서 독립적으로 확정하고, `gh pr` 계열에는 `--repo`, `gh api` 계열에는 `--hostname`을 명시한다. 원격이 없거나 복수면 사용자에게 질의한다.
- 셸 명령에 보간하는 동적 값(원격 이름·브랜치·SHA·ID·경로)은 작은따옴표로 감싸고 값 속 작은따옴표는 `'\''`로 치환한다.
- 승인 화면에 제시하는 원격 URL은 userinfo(자격증명 부분)를 제거한 형태로 표시한다.
- 로컬 변경(원장 파일 생성 등)은 외부 공개 행위가 아니다. 그 커밋·push만 게이트 대상이다.
- 사용자 선택 없는 자동 일괄 조치(자동 답글·자동 수정·자동 resolve·자동 보정)는 하지 않는다.

<details>
<summary>근거 펼치기</summary>

- 제출·게시는 되돌리기 어려운 공개 행위다. 기본 동작을 "제출까지"로 확장한 파괴적 변경의 안전장치가 승인 게이트다 (#58).
- `--repo`를 생략하면 로컬 `gh` 컨텍스트나 `GH_REPO` 환경변수가 저장소를 고르고, `--head`를 생략하면 실행 시점 현재 브랜치가 쓰여 승인받은 대상과 어긋난다 (#58, PR #65).
- `gh api`의 기본 호스트는 github.com이라 GitHub Enterprise에서 호스트를 생략하면 같은 소유자/저장소·번호의 무관한 PR을 읽는다 (#92).
- 유효한 Git ref는 작은따옴표와 셸 메타문자를 포함할 수 있어 단순 치환은 인용을 깨고 브랜치명 내용을 실행한다 (PR #65).
- `git remote get-url`은 사용자명·토큰이 든 HTTPS URL을 반환할 수 있어 그대로 출력하면 대화·로그에 자격증명이 샌다 (PR #65).
- 수집·승인 사이에 리뷰어가 남긴 새 피드백을 보지 못한 채 resolve로 닫는 것을 막기 위해 실행 직전 스냅샷 대조를 둔다 (PR #65).

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #58 git-pr PR 제출까지 확장](https://github.com/scroogy-dev/scroogy-agent-skills/issues/58)
- [Issue #64 git-pr-feedback 스킬 신규 작성](https://github.com/scroogy-dev/scroogy-agent-skills/issues/64)
- [Issue #74 긴 산출물 중복 생성 제거](https://github.com/scroogy-dev/scroogy-agent-skills/issues/74)
- [Issue #92 git-review-quiz 스킬 신설](https://github.com/scroogy-dev/scroogy-agent-skills/issues/92)
- [PR #65 리뷰 코멘트](https://github.com/scroogy-dev/scroogy-agent-skills/pull/65)

</details>
