---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/58
last_harvested: 2026-09-09
---

# PR 제출(git-pr) 요건

## 요건

- 제목은 Conventional Commits 형식이며 `validate-title.sh`로 검사한다. 본문은 이슈별 비즈니스·테크 관점이며 형식은 `templates/pr-body-template.md`다.
- 절차: PR 유형 확인(정식/드래프트, `--draft`면 생략) → 제목·본문 파일 생성(`.ai/99_workspace/pr-<이슈번호>-title.md`·`-body.md`) → 최종 제시(제목 전문 + 본문 파일 경로 + 요약 + 대상 저장소·베이스·소스·SHA·동기화 상태) → 승인 → 생성 → head SHA 대조 → 임시 파일 삭제 질의.
- 생성 수단: `gh pr create --repo --base --head --body-file` 기본, GitHub MCP 폴백(`github.com` 한정, `base` 누락 보정). 베이스는 원격 기본 브랜치 자동 감지. 저장소 판정은 원격 URL 정규화(`verify-submit.sh`), `refs/heads/` 완전 ref 조회.
- push는 제출과 분리된 절차이며 push 전 저장소를 재확인한다. 포크 경로는 비지원 안내 후 종료한다.
- 승인 거절, 포크 미지원, 생성 수단 부재, MCP host 제한으로 종료할 때는 파일 경로를 안내한다. 대화에 본문 전문을 남기지 않는다.
- 문서 동기화 점검: 브랜치 diff 신호 → 의심 문서 → 권고 스킬 표. 스킬 디렉토리·description 변경은 README·AI-CONTEXT(readme-sync·ai-workspace), 디렉토리 구조 변경은 AI-CONTEXT 트리(ai-workspace), 호출 흐름 변경은 `.ai/60_codebase/`(code-map), domain·keywords 변경은 AI-CONTEXT와 상위 `Repos` 행(ai-workspace). PR 끝에 `## 문서 동기화 점검` 블록으로 권고만 남긴다.
- git-pr 제출 후 단계는 git-pr-feedback이 담당한다(관련 skill 역참조).

## 관련 결정

- [ADR 0011](../../50_adr/active/0011-git-pr-submission-and-approval-gate.md), [ADR 0013](../../50_adr/active/0013-long-output-single-file-generation.md), 정책 [외부 공개 행위 승인 게이트](../policies/local/external-action-approval-gate.md), 계약 [GitHub 연동 수단](../../30_contract/github-integration.md)
- 절차 상세는 `git-pr/SKILL.md`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #17](https://github.com/scroogy-dev/scroogy-agent-skills/issues/17), [#58](https://github.com/scroogy-dev/scroogy-agent-skills/issues/58), [#74](https://github.com/scroogy-dev/scroogy-agent-skills/issues/74), [#80](https://github.com/scroogy-dev/scroogy-agent-skills/issues/80), [#90](https://github.com/scroogy-dev/scroogy-agent-skills/issues/90)
- [PR #79 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/79)

</details>
