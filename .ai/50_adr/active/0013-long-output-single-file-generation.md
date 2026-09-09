---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/74
related_jira:
last_harvested: 2026-09-09
---

# ADR: 긴 산출물의 파일 1회 생성과 임시 파일 정리 시점

## 결정

- 긴 산출물(PR 제목·본문, `--clear` 이슈 댓글)은 `.ai/99_workspace/` 파일에 1회만 생성하고, 대화에는 경로와 요약(이슈 목록·리스크·결정사항·승격 목록)만 제시한다. 본문 전문을 대화에 출력하지 않는다. 짧은 제목의 전문 제시는 예외다.
- 파일 경로 제시도 승인 게이트의 "제시"에 해당한다. 게이트 절차는 바뀌지 않는다.
- 파일명: PR 파일은 GitHub 이슈 번호 그대로 `pr-<이슈번호>-title.md`·`pr-<이슈번호>-body.md`, 댓글 파일은 이슈 디렉토리명 기준 `issue-<번호>-comment.md`(4자리). 통합 배포는 PR 제목의 첫 이슈 번호를 쓴다.
- `.ai/99_workspace/`가 없으면 생성 후 그대로 사용한다. 대화 출력 폴백은 두지 않는다.
- 정리 시점은 A+B 병행이다. git-pr 4단계 head SHA 대조 통과 직후 삭제 질의(거절 시 보존), 잔존분은 issue-work `--clear` 5단계가 회수한다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 같은 2000자를 파일용과 대화용으로 두 번 생성해 해당 구간 응답 지연이 2배였다. 지연의 주 요인이 토큰 생성이라 렌더링 최적화로는 해소되지 않는다.
- git-review는 이미 `temp_review_result.md`에 1회만 쓰는 선례가 있다.
- 세션 scratchpad는 종료 시 소멸해 나중에 열람할 수 없어 repo 안에 둔다.
- 대조 전에는 삭제 질의를 하지 않아 생성 실패·불일치 시 사본이 먼저 사라지지 않는다. `--clear` 권장 시점이 머지 직전이라 git-pr보다 먼저 실행되는 순서 문제(#72에서 실제 발생)는 A로 보완한다.
- 본문 승격 규칙이 파일 안에서만 지켜지면 대화로 승인하는 사용자에겐 접힌 것과 같아, 승격 목록을 대화 제시분에도 포함한다.
- 수용한 known issue: 승인과 외부 등록 사이의 파일 내용 동일성 미검증(K-0003), `--clear` 보존 목적지의 이슈 번호 미대조(K-0004).

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- A 단독(생성 직후 삭제 질의): PR 본문 수정이 필요할 때 사본이 사라진다.
- B 단독(`--clear` 회수): `--clear`가 먼저 실행되면 그 뒤 생성된 파일이 다음 이슈까지 잔류한다.
- C(정리 없이 덮어쓰기): 이슈 번호가 파일명에 들어가 덮어쓰기가 안 되어 계속 쌓인다.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #74 git-pr 긴 산출물 중복 생성 제거](https://github.com/scroogy-dev/scroogy-agent-skills/issues/74)
- [PR #79 리뷰 코멘트](https://github.com/scroogy-dev/scroogy-agent-skills/pull/79)

</details>
