---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/64
last_harvested: 2026-09-09
---

# PR 리뷰 코멘트 대응(git-pr-feedback) 요건

## 요건

- 대상 PR: 인자 PR 번호 또는 현재 브랜치의 열린 PR 자동 감지. 저장소를 upstream 원격에서 먼저 확정하고 첫 조회부터 `--repo`를 명시하며, 응답 PR URL이 일치할 때만 불변값(head 저장소·`headRefName`·`headRefOid`)을 보관한다.
- 수집: 리뷰 본문, 코드 라인 스레드, 일반 댓글. 미해결 스레드 우선, 페이지네이션 처리. 수단은 `gh` 기본, GitHub MCP 폴백(매핑·호스트 확인).
- 분류·의견: 항목마다 의견 유형 5종(조치 필요 / 조치 불필요 / 수용(known issue) / 코멘트로 충분 / 확인 필요)과 근거·답글 초안. 의견은 제안이다.
- 선택·승인: 항목별 처리 방식(코드 수정 / 답글 게시 / 수용 — 원장 등재 / 보류). 답글·resolve·push는 승인 게이트 필수.
- 조치: 코드 수정 커밋은 git-commit 규칙을 따른다. 답글은 승인 본문 그대로 게시한다. resolve는 실행 직전 스레드 재조회·스냅샷 대조(코멘트 ID·본문·resolve 상태). push는 원격 fetch/push URL 전체가 head 저장소와 일치(정확히 1개), ref·조상 관계 대조, 커밋 목록·diffstat·최종 diff 제시, 기존 작업트리 변경 분리 확인, push 후 head SHA 일치 시에만 완료 보고(`verify-push.sh`).
- 원장 연계: `수용 — 원장 등재` 선택 시 `K-<번호>` 등재(수용 사유·재검토 조건 필수, 출처 식별자만). 기등재면 새 번호를 따지 않고 재검토 이력에 기록하며 조건 충족 시 갱신·종결한다. 코드 수정으로 기존 K의 원인이 사라지면 선택과 무관하게 `해소(PR #N)`으로 종결한다.
- 결과 요약 표(항목 | 분류 | 사용자 선택 | 결과)를 제시한다.
- 산출물 접기 기준과 writing-principles 참조를 포함한다.

## 관련 결정

- [ADR 0007](../../50_adr/active/0007-tech-debt-ledger-location-and-structure.md), [ADR 0012](../../50_adr/active/0012-git-pr-feedback-separate-skill.md), 정책 [외부 공개 행위 승인 게이트](../policies/local/external-action-approval-gate.md), 계약 [GitHub 연동 수단](../../30_contract/github-integration.md)
- 절차 상세는 `git-pr-feedback/SKILL.md`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #61](https://github.com/scroogy-dev/scroogy-agent-skills/issues/61), [#64](https://github.com/scroogy-dev/scroogy-agent-skills/issues/64), [#70](https://github.com/scroogy-dev/scroogy-agent-skills/issues/70), [#90](https://github.com/scroogy-dev/scroogy-agent-skills/issues/90)
- [PR #65 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/65)

</details>
