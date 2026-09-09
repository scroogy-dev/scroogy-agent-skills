---
last_synced: 2026-09-09
source_hash: 5ab2b67
status: current
---

# issue-work --clear 호출 흐름

## What

진행 중인 이슈를 마무리해 archive로 이관하고 작업공간을 비운다. 이슈 댓글 요약 등록까지 한 번에 수행한다. PR 머지 전 작업 브랜치에서 실행해 이관을 같은 PR에 포함한다.

## How

```
issue-work/SKILL.md `### --clear`
├── 1. 완료 확인
│   └── scripts/check-clear.sh --completion <plan>   # 계획 종료 게이트 `점검 완료` + Task 체크박스, 미완료 1행씩·exit 1 → 계속 진행 질의
├── 2. summary 갱신           # 다음 작업을 `✅ 모든 작업이 완료되었습니다.` 또는 종료 사유로
├── 3. 이슈 댓글              # .ai/99_workspace/issue-<번호>-comment.md 1회 작성(요약 본문 + 결정·리스크·액션 승격 + Task 상세 접기)
│   └── 승인 시 gh issue comment '<번호>' --body-file <파일>
├── 4. archive 이관           # active/issue-<번호>/ → archive/ 디렉토리 단위 (git 이동)
├── 5. 99_workspace 정리      # 보존 파일은 archive/issue-<번호>/ 로 이동 제안, .gitkeep·notes/ 는 보존, 나머지 삭제 확인
└── 6. 경로 참조 갱신·검증    # 함께 옮긴 파일은 ./ 링크, ../ 깊이 재계산, 99_workspace 참조 제거 또는 병기 문구
    └── scripts/check-clear.sh --refs <archive 디렉토리>   # 잔존 참조 1행씩·exit 1, 오탐(옵션 설명 서술)은 AI 판정
```

## Why

- 머지 전에 실행하는 이유는 `### --clear` 시점 항목에 있다. 머지 후 이관은 `main` 직접 푸시가 된다.
- 댓글 초안을 파일에 1회만 쓰고 대화에 전문을 출력하지 않는 이유는 3단계 본문에 있다(승인 대상은 파일, 같은 텍스트를 다시 만들면 응답만 늦어진다).
- 원장 [K-0004](../../70_ledger/active/K-0004-clear-preserve-destination-mismatch.md): 5단계 보존 목적지가 파일명의 이슈 번호를 대조하지 않는다(수용).
- 명세: [이슈 단위 작업 워크플로우 요건](../../40_domain/specs/issue-workflow.md)(게이트 요약 표 `--clear` 행). 머지 직전 시점·archive 이관·경로 참조 갱신·stale 0건 검사는 [ADR 0015](../../50_adr/active/0015-issue-clear-timing-and-archive-rules.md).
- 댓글 파일 1회 생성과 5단계 잔존 파일 회수(정리 시점 B)는 [ADR 0013](../../50_adr/active/0013-long-output-single-file-generation.md). 이슈 댓글 등록의 승인은 [외부 공개 행위 승인 게이트](../../40_domain/policies/local/external-action-approval-gate.md), `--body-file`·이슈 번호 앞자리 0 제거는 [GitHub 연동 수단](../../30_contract/github-integration.md).
- 헬퍼·테스트 배치는 [ADR 0001](../../50_adr/active/0001-skill-deterministic-helper-test-convention.md).
