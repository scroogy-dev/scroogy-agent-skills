---
last_synced: 2026-11-01
source_hash: 6e0ddb3
status: current
---

# 코드맵

> 이 repo는 Agent Skills 모음이라 code-map의 기본 단위(HTTP API·배치 Job) 대신 **스킬**을 기능 단위로 삼는다.
> 엔트리포인트는 `<스킬>/SKILL.md`와 그 옵션이고, 호출 흐름은 절차가 부르는 `scripts/` 헬퍼·`templates/`·`references/`·외부 명령(git·gh·MCP)이다.
> 상세 호출 흐름은 헬퍼나 외부 부작용(push·PR·댓글·파일 삭제)이 있는 스킬에만 둔다.

## 기능 목록

| 기능 | 엔트리포인트 | 관련 문서 |
|------|-------------|-----------|
| ai-workspace | `ai-workspace/SKILL.md` (`/ai-workspace [dev·doc]`) | [init 흐름](ai-workspace/init-call-flow.md), [update 흐름](ai-workspace/update-call-flow.md), [명세](../40_domain/specs/ai-workspace.md), [SSoT·라우터 정책](../40_domain/policies/local/ssot-and-router-principle.md), [ADR 0007](../50_adr/active/0007-tech-debt-ledger-location-and-structure.md), [ADR 0008](../50_adr/active/0008-writing-principles-ssot-distribution.md), [ADR 0020](../50_adr/active/0020-doc-ssot-original-documents-and-publishing-deferred.md), [ADR 0022](../50_adr/active/0022-adr-lifecycle-status-and-superseded-move.md), [ADR 0023](../50_adr/active/0023-testing-principles-pair-and-consumer-skill-references.md), [K-0001](../70_ledger/archive/K-0001-update3-fixture-absent.md), [K-0018](../70_ledger/active/K-0018-update4-rules-restore-profile-mismatch-row.md) |
| ai-workspace-directory | `ai-workspace-directory/SKILL.md` (`/ai-workspace-directory [init·update]`) | [init 흐름](ai-workspace-directory/init-call-flow.md), [update 흐름](ai-workspace-directory/update-call-flow.md), [명세](../40_domain/specs/ai-workspace.md), [SSoT·라우터 정책](../40_domain/policies/local/ssot-and-router-principle.md), [ADR 0020](../50_adr/active/0020-doc-ssot-original-documents-and-publishing-deferred.md) |
| code-map | `code-map/SKILL.md` (`/code-map --local·--global`) | [SSoT·라우터 정책](../40_domain/policies/local/ssot-and-router-principle.md), [ADR 0020](../50_adr/active/0020-doc-ssot-original-documents-and-publishing-deferred.md), [ADR 0024](../50_adr/active/0024-code-map-sequence-diagram-alongside-call-flow-tree.md), [ADR 0025](../50_adr/active/0025-sequence-diagram-extended-to-git-pr-and-review-context.md), [K-0006](../70_ledger/active/K-0006-code-map-check-not-deterministic.md), [K-0019](../70_ledger/active/K-0019-seq-copy-literal-check-misses-meaning-change.md) — 헬퍼 없음. `references/local.md`(소스 코드)·`doc.md`(원본 문서 `.md` 파일, SSoT 선언으로 선택)·`global.md`(건물 repo, `소스 코드` 선언. 대상 repo 선언을 읽어 `원본 문서` repo는 서비스 간 호출 식별에서 제외)의 단계가 그대로 흐름. 건물 repo(`repository.yaml` 존재)에서 `--local`은 멈추고 `--global`을 안내. `## 시퀀스 다이어그램 작성 규칙`의 원본이며 git-pr·git-review-context가 사본을 둔다 |
| context-harvest | `context-harvest/SKILL.md` (`/context-harvest [--full]`) | [SSoT·라우터 정책](../40_domain/policies/local/ssot-and-router-principle.md), [ADR 0022](../50_adr/active/0022-adr-lifecycle-status-and-superseded-move.md) — 헬퍼 없음. 수집은 WebFetch·gh·MCP 읽기, 산출은 `templates/` 3종으로 30_contract·40_domain·50_adr 문서 생성. 퍼블리싱 사본(`publish` 선언 위치 포함)은 수집 제외 |
| context-save | `context-save/SKILL.md` (`/context-save [<slug>]`) | — (헬퍼·외부 호출 없음. `templates/context-note-template.md` 1종으로 `.ai/99_workspace/notes/` 작성) |
| git-commit | `git-commit/SKILL.md` | [검증 흐름](git-commit/validate-call-flow.md), [ADR 0001](../50_adr/active/0001-skill-deterministic-helper-test-convention.md), [ADR 0002](../50_adr/active/0002-skill-independence-intentional-duplication.md) |
| git-pr | `git-pr/SKILL.md` (`/git-pr [--draft]`) | [제출 흐름](git-pr/submit-call-flow.md), [계약](../30_contract/github-integration.md), [명세](../40_domain/specs/git-pr-submission.md), [승인 게이트 정책](../40_domain/policies/local/external-action-approval-gate.md), [ADR 0011](../50_adr/active/0011-git-pr-submission-and-approval-gate.md), [ADR 0013](../50_adr/active/0013-long-output-single-file-generation.md), [ADR 0021](../50_adr/active/0021-ledger-archive-move-link-update.md), [ADR 0025](../50_adr/active/0025-sequence-diagram-extended-to-git-pr-and-review-context.md), [ADR 0026](../50_adr/active/0026-acceptance-criteria-across-issue-spec-pr.md), [K-0003](../70_ledger/active/K-0003-approved-file-content-unverified.md), [K-0012](../70_ledger/active/K-0012-git-pr-push-url-unverified.md), [K-0016](../70_ledger/active/K-0016-git-pr-adr-sync-check-absent.md), [K-0020](../70_ledger/active/K-0020-quiz-link-to-pr-and-task-deferred.md), [K-0021](../70_ledger/active/K-0021-microworld-generation-deferred.md), [K-0022](../70_ledger/active/K-0022-doc-profile-flow-substitute-format-deferred.md) — 이슈 섹션은 첫 화면 5항목(완료의 정의 대조는 최종 감사 리포트 판정)과 접기 안 헤더 5개 |
| git-pr-feedback | `git-pr-feedback/SKILL.md` (`/git-pr-feedback [PR 번호]`) | [대응 흐름](git-pr-feedback/respond-call-flow.md), [계약](../30_contract/github-integration.md), [명세](../40_domain/specs/git-pr-feedback.md), [승인 게이트 정책](../40_domain/policies/local/external-action-approval-gate.md), [ADR 0007](../50_adr/active/0007-tech-debt-ledger-location-and-structure.md), [ADR 0012](../50_adr/active/0012-git-pr-feedback-separate-skill.md), [ADR 0021](../50_adr/active/0021-ledger-archive-move-link-update.md) |
| git-qa | `git-qa/SKILL.md` | [ADR 0023](../50_adr/active/0023-testing-principles-pair-and-consumer-skill-references.md) — 헬퍼 없음. 4단계 `gh api`로 대상 브랜치 `testing-principles-local.md` 읽기(없으면 표시 없음), `gh issue create` 1단 호출과 `templates/qa-checklist-template.md`, 승인 게이트 없음 |
| git-review | `git-review/SKILL.md` | [리뷰 흐름](git-review/review-call-flow.md), [명세](../40_domain/specs/git-review-output.md), [ADR 0006](../50_adr/active/0006-risk-matrix-and-treatment.md), [ADR 0014](../50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md), [K-0002](../70_ledger/active/K-0002-audit-axis-tiebreak-absent.md) |
| git-review-context | `git-review-context/SKILL.md` | [git-review 명세](../40_domain/specs/git-review-output.md)(사용자 명시 요청 시에만 실행, 자동 호출 없음), [ADR 0025](../50_adr/active/0025-sequence-diagram-extended-to-git-pr-and-review-context.md) — 헬퍼·외부 쓰기 없음. `git diff` 읽기 후 `templates/review-context-template.md`로 `.ai/99_workspace/temp_review_context.md` 작성. `## 호출 흐름`은 엔트리 포인트마다 트리 다음에, 작성 대상이면 시퀀스 다이어그램 |
| git-review-quiz | `git-review-quiz/SKILL.md` (`--comment·--mcq·--open·--business·--tech`) | [퀴즈 흐름](git-review-quiz/quiz-call-flow.md), [계약](../30_contract/github-integration.md), [명세](../40_domain/specs/git-review-quiz.md), [승인 게이트 정책](../40_domain/policies/local/external-action-approval-gate.md), [ADR 0014](../50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md), [ADR 0017](../50_adr/active/0017-git-review-quiz-study-mode.md), [ADR 0020](../50_adr/active/0020-doc-ssot-original-documents-and-publishing-deferred.md), [K-0007](../70_ledger/active/K-0007-quiz-permalink-target-unverified.md), [K-0008](../70_ledger/active/K-0008-quiz-format-vocab-fixture-absent.md) |
| install-skills | `install-skills/SKILL.md` (`--claude…--junie·--all·--clear·--self`) | [설치 흐름](install-skills/install-call-flow.md), [계약](../30_contract/ai-tool-skill-paths.md), [명세](../40_domain/specs/install-skills.md), [ADR 0001](../50_adr/active/0001-skill-deterministic-helper-test-convention.md), [ADR 0009](../50_adr/active/0009-install-skills-self-install.md), [K-0005](../70_ledger/active/K-0005-install-template-exclude-pattern-literal.md) |
| issue-audit | `issue-audit/SKILL.md` (`/issue-audit [--plan]`) | [최종 감사 흐름](issue-audit/final-audit-call-flow.md), [계획 감사 흐름](issue-audit/plan-audit-call-flow.md), [명세](../40_domain/specs/issue-audit.md), [ADR 0004](../50_adr/active/0004-cross-model-audit-and-response-gate.md), [ADR 0006](../50_adr/active/0006-risk-matrix-and-treatment.md), [ADR 0014](../50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md), [ADR 0016](../50_adr/active/0016-spec-requirements-layer-and-plan-audit.md), [ADR 0023](../50_adr/active/0023-testing-principles-pair-and-consumer-skill-references.md), [ADR 0026](../50_adr/active/0026-acceptance-criteria-across-issue-spec-pr.md), [K-0002](../70_ledger/active/K-0002-audit-axis-tiebreak-absent.md), [K-0009](../70_ledger/active/K-0009-plan-audit-fake-d-check-manual.md), [K-0010](../70_ledger/active/K-0010-check-plan-line-based-markdown-boundary.md), [K-0011](../70_ledger/archive/K-0011-plan-audit-regression-exception-spec-only.md), [K-0023](../70_ledger/active/K-0023-check-plan-include-label-trailing-comment.md) |
| issue-work | `issue-work/SKILL.md` (`--create·--workflow-only·--resume·--response·--clear`) | [새 이슈 시작 흐름](issue-work/start-call-flow.md), [--create 흐름](issue-work/create-call-flow.md), [--response 흐름](issue-work/response-call-flow.md), [--clear 흐름](issue-work/clear-call-flow.md), [계약](../30_contract/github-integration.md), [명세](../40_domain/specs/issue-workflow.md), [승인 게이트 정책](../40_domain/policies/local/external-action-approval-gate.md), [ADR 0003](../50_adr/active/0003-verification-levels-and-determinization.md), [ADR 0004](../50_adr/active/0004-cross-model-audit-and-response-gate.md), [ADR 0005](../50_adr/active/0005-model-separation-gates.md), [ADR 0013](../50_adr/active/0013-long-output-single-file-generation.md), [ADR 0015](../50_adr/active/0015-issue-clear-timing-and-archive-rules.md), [ADR 0016](../50_adr/active/0016-spec-requirements-layer-and-plan-audit.md), [ADR 0018](../50_adr/active/0018-ledger-proactive-review-and-resolve-timing.md), [ADR 0019](../50_adr/active/0019-test-perspectives-and-task-level-placement.md), [ADR 0021](../50_adr/active/0021-ledger-archive-move-link-update.md), [ADR 0023](../50_adr/active/0023-testing-principles-pair-and-consumer-skill-references.md), [ADR 0026](../50_adr/active/0026-acceptance-criteria-across-issue-spec-pr.md), [K-0003](../70_ledger/active/K-0003-approved-file-content-unverified.md), [K-0004](../70_ledger/active/K-0004-clear-preserve-destination-mismatch.md), [K-0013](../70_ledger/active/K-0013-issue-work-pr-lookup-fork-same-branch.md) — 이슈 완료 시(`--clear` 4단계) 원장 해소 기재와 spec 제외 `보류` 항목 원장 등재 질의. 외부 쓰기는 `--create`의 이슈 등록, 시작 6단계의 이슈 본문 갱신, `--clear`의 이슈 댓글 |
| readme-sync | `readme-sync/SKILL.md` (`--mode·--profile·--force-license`) | [명세](../40_domain/specs/readme-sync.md), [라이선스 정책](../40_domain/policies/local/license-policy.md) — 헬퍼 없음. `templates/README-template.md`와 `references/license.md` 2단, 외부 쓰기는 `README.md`·`LICENSE`·`NOTICE` |

## 파일 구조

```
.ai/60_codebase/
├── ai-workspace/
│   ├── init-call-flow.md
│   └── update-call-flow.md
├── ai-workspace-directory/
│   ├── init-call-flow.md
│   └── update-call-flow.md
├── git-commit/
│   └── validate-call-flow.md
├── git-pr/
│   └── submit-call-flow.md
├── git-pr-feedback/
│   └── respond-call-flow.md
├── git-review/
│   └── review-call-flow.md
├── git-review-quiz/
│   └── quiz-call-flow.md
├── install-skills/
│   └── install-call-flow.md
├── issue-audit/
│   ├── final-audit-call-flow.md
│   └── plan-audit-call-flow.md
├── issue-work/
│   ├── clear-call-flow.md
│   ├── create-call-flow.md
│   ├── response-call-flow.md
│   └── start-call-flow.md
└── index.md
```

## 공통 참조

스킬 전반의 구현 방식을 정하는 문서다. 상세 흐름의 Why 절이 이 문서들을 가리킨다.

- [architecture.md 디자인 원칙](../10_rules/architecture.md): 결정적 로직을 `scripts/`로 분리하는 판단 체크리스트와 `scripts/`·`SKILL.md`·`references/`·`templates/`·`tests/`의 역할 분담
- [ADR 0001](../50_adr/active/0001-skill-deterministic-helper-test-convention.md): 헬퍼는 `<skill>/scripts/`, 테스트는 `<skill>/tests/`, 배포 시 `tests/` 제외(제외 패턴의 단일 출처는 `install-skills/SKILL.md` 5단계)
- [ADR 0002](../50_adr/active/0002-skill-independence-intentional-duplication.md): 스킬은 AI-CONTEXT 비의존·단독 설치. 공통 규칙(트리 정렬·위험도 매트릭스·카테고리 7종과 doc 카테고리 7종·접기 기준)은 스킬별 복제 + 동기화 주석이며 참조 링크로 대체하지 않는다
- [ADR 0003](../50_adr/active/0003-verification-levels-and-determinization.md): 완료 기준의 검증 레벨 `[D]`/`[QD]`/`[ND]`, 결정화 판단은 architecture.md 체크리스트(임계 수치 없음), 헬퍼 경로 표기 `'<skill 디렉토리>/scripts/<헬퍼>'`
- [ADR 0008](../50_adr/active/0008-writing-principles-ssot-distribution.md): 산출물 작성 원칙의 단일 원본은 ai-workspace 템플릿의 `writing-principles.md`. 산출물 스킬 8종(git-pr·git-qa·issue-work·issue-audit·git-review·git-review-context·context-save·context-harvest)은 접기 기준을 내장하고 조건부로 참조한다
- [ADR 0023](../50_adr/active/0023-testing-principles-pair-and-consumer-skill-references.md): 테스트 실행 원칙의 단일 원본은 ai-workspace dev 템플릿의 `testing-principles.md`(버전 고정)이고, repo 고유 층 표·대상 환경·실행 셸은 `testing-principles-local.md`에 둔다. issue-work·issue-audit·git-qa는 두 파일을 조건부로 참조한다(없으면 현재 동작)
- [ADR 0010](../50_adr/active/0010-output-format-templates-separation.md): 산출물 형식 블록은 `templates/`로 분리하고 SKILL.md는 참조만 둔다. 표기는 "이 skill 디렉토리의 `templates/<파일>`"(제외: git-commit·git-pr-feedback)
- [표기·명명 관례](../40_domain/policies/local/notation-conventions.md): 분류 값 한글 우선 병기, 모델 기록 "벤더, 모델명 (모델 ID)", 트리 정렬, 이모지는 산출물 값 명세에만, 스킬·옵션 이름은 사용자 의도 기준
- [원장 index](../70_ledger/index.md): 수용한 기술부채·known issue. 위 표의 `K-` 링크가 스킬별 대응이다. 위치·필수 필드·소비자 3종의 결정은 [ADR 0007](../50_adr/active/0007-tech-debt-ledger-location-and-structure.md)
- 헬퍼 공통 규약: 통과는 무출력·종료 코드 0, 위반은 사유 1행씩·종료 코드 1, 사용오류는 종료 코드 2 (`validate-message.sh`·`check-clear.sh`·`check-plan.sh`·`check-quiz.sh`·`verify-submit.sh`·`verify-push.sh`·`verify-install.sh`·`check-context.sh`·`check-lobby.sh`·`check-ledger-links.sh`). 산출형 헬퍼(`classify-risk.sh`·`summarize-metrics.sh`·`next-finding-number.sh`)는 값을 출력하고 종료 코드 0이다
- `classify-risk.sh`는 git-review와 issue-audit에 각각 있으며 내용이 다르다(issue-audit 쪽에 `--treatment`·`--compliance` 추가). 스킬 독립성 원칙으로 공유하지 않는다([ADR 0002](../50_adr/active/0002-skill-independence-intentional-duplication.md)). 매트릭스 원본은 issue-audit([ADR 0006](../50_adr/active/0006-risk-matrix-and-treatment.md)), 카테고리 7종과 doc 카테고리 7종(SSoT 선언이 원본 문서일 때)의 원본은 git-review([ADR 0014](../50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md))
- `check-ledger-links.sh`는 issue-work·git-pr·git-pr-feedback에 바이트 단위로 같은 사본 3개를 둔다. 한쪽을 고치면 나머지도 고친다([ADR 0021](../50_adr/active/0021-ledger-archive-move-link-update.md))
- `## 시퀀스 다이어그램 작성 규칙`은 code-map이 원본이고 git-pr·git-review-context에 사본을 둔다. 사본은 위치·형식 행만 스킬별로 쓰고 참여자 행의 `--global` 구절을 뺀다. code-map 러너가 두 사본을 원본과 같은 `SEQ_ROWS`로 대조하며, 리터럴을 남긴 의미 변경은 잡지 못한다([ADR 0024](../50_adr/active/0024-code-map-sequence-diagram-alongside-call-flow-tree.md), [ADR 0025](../50_adr/active/0025-sequence-diagram-extended-to-git-pr-and-review-context.md), [K-0019](../70_ledger/active/K-0019-seq-copy-literal-check-misses-meaning-change.md))

## 태그 현황

- `[DOC-NEEDED]` 0건: 최초 build의 2건은 2026-09-09 sync에서 해소했다. 교차모델 audit 수동 수행 원칙은 [ADR 0004](../50_adr/active/0004-cross-model-audit-and-response-gate.md), 외부 공개 행위 승인 게이트 원칙은 [승인 게이트 정책](../40_domain/policies/local/external-action-approval-gate.md)과 [ADR 0011](../50_adr/active/0011-git-pr-submission-and-approval-gate.md)이 담는다
- `[WHY-NEEDED]` 0건: 각 스킬의 설계 근거는 작성자가 SKILL.md 본문(`설계 원칙`·근거 절)에 직접 기재했다. 상세 흐름의 Why 절이 그 절 이름을 가리킨다
- `[UPDATE-NEEDED]` 0건: 2026-11-01 sync(`6e0ddb3`, #130 PR 리뷰 대응). 계획 감사 흐름에 `--ac` 판정 보정(닫는 괄호·`### 공통` 헤더·인라인 코드 자리표시자)과 `조회 실패` 행, 원장 K-0023을 반영했다. 시작 흐름의 본문 갱신 종료 코드 처리는 리뷰 대응 커밋에서 이미 반영돼 대조만 했다. 그 전 기준은 2026-11-01 sync(`0844084`, #130). issue-work 시작 흐름(AC 정제·6단계·변경 통제)·계획 감사 흐름(`--ac`·관점 3)·git-pr 제출 흐름(첫 화면·완료의 정의 대조)을 갱신하고 `--create` 흐름을 새로 두었다. 그 전 기준은 2026-10-31 rebuild(`552fe6a`). 16개 스킬의 색인 행을 소스와 다시 대조하고, 상세 흐름 15건은 트리를 재대조한 뒤 시퀀스 다이어그램을 더했다. 이전 sync의 부분 반영 이력(#114~#126)은 이 rebuild로 대체한다
