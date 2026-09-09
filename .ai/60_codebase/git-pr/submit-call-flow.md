---
last_synced: 2026-09-09
source_hash: 5ab2b67
status: current
---

# git-pr 제출 호출 흐름

## What

PR 제목·본문을 파일로 쓰고, 유형 확인과 승인 게이트를 거쳐 push·PR 생성까지 한다. 승인받은 저장소·SHA를 불변값으로 보관해 생성 직전마다 재확인한다.

## How

```
git-pr/SKILL.md `## PR 제출`
├── 1. PR 유형 확인                     # 정식 기본, 기본값도 확인 응답 필수 (--draft 면 이 질의만 생략)
│   ├── 베이스 브랜치 자동 감지         # 원격 기본 브랜치
│   └── scripts/verify-submit.sh --normalize <URL>   # 베이스·소스 저장소 대조, 포크면 제출 미지원 (메시지만 작성 여부 질의)
├── 2. 메시지 작성                      # 기준 SHA 고정, 미커밋 변경 있으면 커밋·제외 질의
│   ├── templates/pr-body-template.md   # 이슈 목록 → 이슈별 리스크·주의사항(접기 밖) + 비즈니스·테크 관점(접기)
│   ├── scripts/validate-title.sh --title '<제목>' | <제목 파일>   # exit 0/1/2
│   ├── 문서 동기화 점검                # README·AI-CONTEXT·60_codebase 갱신 권고만, 실행 여부 질의
│   └── 산출: .ai/99_workspace/pr-<이슈>-title.md·pr-<이슈>-body.md   # 1회만 쓰고 이후 파일 참조
├── 3. 최종 제시 및 승인 (생략 불가)     # 제목 전문, 본문 경로+요약, 대상 저장소·베이스·소스·SHA·동기화 상태·유형, push 여부·원격
└── 4. PR 생성
    ├── verify-submit.sh --normalize "$(git remote get-url <원격>)"   # 승인 저장소와 동일할 때만
    ├── verify-submit.sh --branch <소스> --expect <SHA>              # 로컬 head 재확인
    ├── git push -u <원격> <소스>                                     # 승인받은 경우만
    ├── verify-submit.sh --remote <원격> --branch <소스> --expect <SHA>   # ls-remote 완전 ref 1행·SHA 일치
    ├── gh pr create [--draft] --repo --base --head --title "$(cat …)" --body-file   # 확인과 생성 사이에 다른 동작 금지
    │   └── 폴백: GitHub MCP create_pull_request (github.com 한정, 승인값 전부 명시)
    ├── gh pr view <번호> --json headRefOid                            # 생성 후 승인 SHA 대조
    └── 임시 파일 삭제 질의                                            # 대조 통과·보고 뒤에만
```

## Why

- 각 가드의 근거는 `git-pr/SKILL.md` `## PR 제출` 1~4단계 본문에 작성자가 기재했다. 포크 미지원, 승인값 불변 보관, 원격 이름은 가변 별칭이라 URL 재정규화, `ls-remote` tail 패턴 위험, `--repo`·`--head` 생략 금지, 승인값 셸 보간 금지가 그것이다.
- 제목이 Conventional Commits를 따르는 이유는 `## PR 제목`(Squash Merge 시 커밋 메시지가 됨).
- 원장 [K-0003](../../70_ledger/active/K-0003-approved-file-content-unverified.md): 승인한 제목·본문 파일의 내용 동일성은 제출 직전에 검증하지 않는다(수용).
- 정책: [외부 공개 행위 승인 게이트](../../40_domain/policies/local/external-action-approval-gate.md)(git-pr·git-pr-feedback·git-review-quiz·issue-work --clear 공통). 제출까지 확장한 결정과 유형 확인·승인 게이트 필수화는 [ADR 0011](../../50_adr/active/0011-git-pr-submission-and-approval-gate.md).
- 계약: [GitHub 연동 수단](../../30_contract/github-integration.md)(gh 기본·MCP 폴백 github.com 한정, `refs/heads/` 완전 ref, 동적 인자 인용). 명세: [PR 제출 요건](../../40_domain/specs/git-pr-submission.md)(절차, 문서 동기화 점검 표).
- 제목·본문을 파일에 1회만 쓰고 삭제 질의를 SHA 대조 뒤에 두는 정리 시점(A+B)은 [ADR 0013](../../50_adr/active/0013-long-output-single-file-generation.md).
- 헬퍼·테스트 배치는 [ADR 0001](../../50_adr/active/0001-skill-deterministic-helper-test-convention.md).
