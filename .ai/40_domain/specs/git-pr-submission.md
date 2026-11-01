---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/58
last_harvested: 2026-09-09
---

# PR 제출(git-pr) 요건

## 요건

- 제목은 Conventional Commits 형식이며 `validate-title.sh`로 검사한다. 본문은 이슈별 비즈니스·테크 관점이며 형식은 `templates/pr-body-template.md`다.
- PR 본문 이슈 섹션: 첫 화면(접기 밖)은 목적·범위 → 리뷰어 확인 요청(사람이 판단할 결정·트레이드오프를 질문으로) → 리스크·주의사항 → 완료의 정의 대조(`충족 n/m`과 충족이 아닌 AC의 번호·상태) → 이번 PR에서 하지 않는 것 5항목이다. 접기 안은 완료의 정의 대조 표 → 전후 예시 → 배경 → 비즈니스 관점 → 테크 관점(구현 요약·호출 흐름·실패 경로·참고사항) 5헤더다. 10개 모두 항상 두고 내용이 없으면 `없음`을 적으며, 동작 차이가 없는 변경의 전후 예시도 `없음`이다 (#130).
- 완료의 정의 대조 근거: 최종 감사 리포트 `issue-<번호>-audit-report.md`의 `### 완료의 정의(DoD) 대조` 표다. 리포트 행을 spec 완료의 정의 항목과 R 그룹·순서로 맞추고, 그 항목의 출처 표기로 AC를 잇는다. AC 상태는 `이관` → `미검증` → `미충족` → `충족` → `부분 충족` 순서로 먼저 맞는 값을 쓴다. spec 체크박스만으로 충족으로 세지 않고, `(AC 없음: …)` 항목은 R 그룹 단위로 따로 표시해 n/m에 넣지 않는다. 대조 근거와 전후 예시는 diff·테스트·감사 리포트에서 확인한 것만 적는다 (#130).
- 절차: PR 유형 확인(정식/드래프트, `--draft`면 생략) → 제목·본문 파일 생성(`.ai/99_workspace/pr-<이슈번호>-title.md`·`-body.md`) → 최종 제시(제목 전문 + 본문 파일 경로 + 요약(이슈 목록·리뷰어 확인 요청·리스크·주의사항·미충족 완료 항목·결정사항) + 대상 저장소·베이스·소스·SHA·동기화 상태) → 승인 → 생성 → head SHA 대조 → 원장 해소 기재(원장 대조에서 종결을 승인받은 항목이 있을 때만, 생성된 PR 번호로 `해소(PR #N)` 기재 → `archive/` 이관 → index 갱신 → 들어오는 링크 갱신, 커밋·push는 별도 승인) → 임시 파일 삭제 질의.
- 생성 수단: `gh pr create --repo --base --head --body-file` 기본, GitHub MCP 폴백(`github.com` 한정, `base` 누락 보정). 베이스는 원격 기본 브랜치 자동 감지. 저장소 판정은 원격 URL 정규화(`verify-submit.sh`), `refs/heads/` 완전 ref 조회.
- push는 제출과 분리된 절차이며 push 전 저장소를 재확인한다. 포크 경로는 비지원 안내 후 종료한다.
- 승인 거절, 포크 미지원, 생성 수단 부재, MCP host 제한으로 종료할 때는 파일 경로를 안내한다. 대화에 본문 전문을 남기지 않는다.
- 문서 동기화 점검: 브랜치 diff 신호 → 의심 문서 → 권고 스킬 표. 스킬 디렉토리·description 변경은 README·AI-CONTEXT(readme-sync·ai-workspace), 디렉토리 구조 변경은 AI-CONTEXT 트리(ai-workspace), 호출 흐름 변경은 `.ai/60_codebase/`(code-map), domain·keywords 변경은 AI-CONTEXT와 상위 `Repos` 행(ai-workspace). 원장 `active/` 항목의 재검토 조건 대상·원인 파일 변경은 해당 `K-<번호>`(원장 대조: AI가 조건 문장과 diff를 읽어 재검토 이력 기록 또는 종결 권고, `.ai/70_ledger/index.md`가 없으면 생략). PR 끝에 `## 문서 동기화 점검` 블록으로 권고만 남긴다. 원장 반영은 항목별 승인분만 하며, 종결(해소)은 PR 번호를 모르는 이 단계에서 확정하지 않고 생성 후 원장 해소 기재로 넘긴다. 승격은 만든 이슈 번호로 `승격(이슈 #N)`을 적어 `archive/`로 옮기고 index 항목 목록을 갱신한 뒤 들어오는 링크 갱신을 수행한다.
- 들어오는 링크 갱신: `archive/`로 옮긴 원장 항목을 가리키는 `.ai/` 아래 문서(`.ai/90_issues/archive/` 제외)의 링크를 새 경로로 고치고 `check-ledger-links.sh`로 끊긴 원장 링크 0건을 확인한다. 같은 디렉토리의 원장 항목 링크도 대상이다 (#120).
- git-pr 제출 후 단계는 git-pr-feedback이 담당한다(관련 skill 역참조).

## 관련 결정

- [ADR 0011](../../50_adr/active/0011-git-pr-submission-and-approval-gate.md), [ADR 0018](../../50_adr/active/0018-ledger-proactive-review-and-resolve-timing.md), [ADR 0013](../../50_adr/active/0013-long-output-single-file-generation.md), [ADR 0021](../../50_adr/active/0021-ledger-archive-move-link-update.md), [ADR 0026](../../50_adr/active/0026-acceptance-criteria-across-issue-spec-pr.md), 정책 [외부 공개 행위 승인 게이트](../policies/local/external-action-approval-gate.md), 계약 [GitHub 연동 수단](../../30_contract/github-integration.md)
- 절차 상세는 `git-pr/SKILL.md`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #17](https://github.com/scroogy-dev/scroogy-agent-skills/issues/17), [#58](https://github.com/scroogy-dev/scroogy-agent-skills/issues/58), [#74](https://github.com/scroogy-dev/scroogy-agent-skills/issues/74), [#80](https://github.com/scroogy-dev/scroogy-agent-skills/issues/80), [#90](https://github.com/scroogy-dev/scroogy-agent-skills/issues/90), [#110](https://github.com/scroogy-dev/scroogy-agent-skills/issues/110), [#120](https://github.com/scroogy-dev/scroogy-agent-skills/issues/120), [#130](https://github.com/scroogy-dev/scroogy-agent-skills/issues/130)
- [PR #79 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/79)

</details>
