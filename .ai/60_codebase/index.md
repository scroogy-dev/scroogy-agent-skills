---
last_synced: 2026-09-09
source_hash: 5ab2b67
status: current
---

# 코드맵

> 이 repo는 Agent Skills 모음이라 code-map의 기본 단위(HTTP API·배치 Job) 대신 **스킬**을 기능 단위로 삼는다.
> 엔트리포인트는 `<스킬>/SKILL.md`와 그 옵션이고, 호출 흐름은 절차가 부르는 `scripts/` 헬퍼·`templates/`·`references/`·외부 명령(git·gh·MCP)이다.
> 상세 호출 흐름은 헬퍼나 외부 부작용(push·PR·댓글·파일 삭제)이 있는 스킬에만 둔다.

## 기능 목록

| 기능 | 엔트리포인트 | 관련 문서 |
|------|-------------|-----------|
| ai-workspace | `ai-workspace/SKILL.md` (`/ai-workspace [dev·doc]`) | [init 흐름](ai-workspace/init-call-flow.md), [update 흐름](ai-workspace/update-call-flow.md), [명세](../40_domain/specs/ai-workspace.md), [SSoT·라우터 정책](../40_domain/policies/local/ssot-and-router-principle.md), [ADR 0007](../50_adr/active/0007-tech-debt-ledger-location-and-structure.md), [ADR 0008](../50_adr/active/0008-writing-principles-ssot-distribution.md), [K-0001](../70_ledger/active/K-0001-update3-fixture-absent.md) |
| ai-workspace-directory | `ai-workspace-directory/SKILL.md` (`/ai-workspace-directory [init·update]`) | [init 흐름](ai-workspace-directory/init-call-flow.md), [update 흐름](ai-workspace-directory/update-call-flow.md), [명세](../40_domain/specs/ai-workspace.md), [SSoT·라우터 정책](../40_domain/policies/local/ssot-and-router-principle.md) |
| code-map | `code-map/SKILL.md` (`/code-map --local·--global`) | [SSoT·라우터 정책](../40_domain/policies/local/ssot-and-router-principle.md), [K-0006](../70_ledger/active/K-0006-code-map-check-not-deterministic.md) — 헬퍼 없음. `references/local.md`·`global.md`의 단계가 그대로 흐름 |
| context-harvest | `context-harvest/SKILL.md` (`/context-harvest [--full]`) | [SSoT·라우터 정책](../40_domain/policies/local/ssot-and-router-principle.md) — 헬퍼 없음. 수집은 WebFetch·gh·MCP 읽기, 산출은 `templates/` 3종으로 30_contract·40_domain·50_adr 문서 생성 |
| context-save | `context-save/SKILL.md` (`/context-save [<slug>]`) | — (헬퍼·외부 호출 없음. `templates/context-note-template.md` 1종으로 `.ai/99_workspace/notes/` 작성) |
| git-commit | `git-commit/SKILL.md` | [검증 흐름](git-commit/validate-call-flow.md), [ADR 0001](../50_adr/active/0001-skill-deterministic-helper-test-convention.md), [ADR 0002](../50_adr/active/0002-skill-independence-intentional-duplication.md) |
| git-pr | `git-pr/SKILL.md` (`/git-pr [--draft]`) | [제출 흐름](git-pr/submit-call-flow.md), [계약](../30_contract/github-integration.md), [명세](../40_domain/specs/git-pr-submission.md), [승인 게이트 정책](../40_domain/policies/local/external-action-approval-gate.md), [ADR 0011](../50_adr/active/0011-git-pr-submission-and-approval-gate.md), [ADR 0013](../50_adr/active/0013-long-output-single-file-generation.md), [K-0003](../70_ledger/active/K-0003-approved-file-content-unverified.md) |
| git-pr-feedback | `git-pr-feedback/SKILL.md` (`/git-pr-feedback [PR 번호]`) | [대응 흐름](git-pr-feedback/respond-call-flow.md), [계약](../30_contract/github-integration.md), [명세](../40_domain/specs/git-pr-feedback.md), [승인 게이트 정책](../40_domain/policies/local/external-action-approval-gate.md), [ADR 0007](../50_adr/active/0007-tech-debt-ledger-location-and-structure.md), [ADR 0012](../50_adr/active/0012-git-pr-feedback-separate-skill.md) |
| git-qa | `git-qa/SKILL.md` | — (헬퍼 없음. `gh issue create` 1단 호출과 `templates/qa-checklist-template.md`, 승인 게이트 없음) |
| git-review | `git-review/SKILL.md` | [리뷰 흐름](git-review/review-call-flow.md), [명세](../40_domain/specs/git-review-output.md), [ADR 0006](../50_adr/active/0006-risk-matrix-and-treatment.md), [ADR 0014](../50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md), [K-0002](../70_ledger/active/K-0002-audit-axis-tiebreak-absent.md) |
| git-review-context | `git-review-context/SKILL.md` | [git-review 명세](../40_domain/specs/git-review-output.md)(사용자 명시 요청 시에만 실행, 자동 호출 없음) — 헬퍼·외부 쓰기 없음. `git diff` 읽기 후 `templates/review-context-template.md`로 `.ai/99_workspace/temp_review_context.md` 작성 |
| git-review-quiz | `git-review-quiz/SKILL.md` (`--comment·--mcq·--open·--business·--tech`) | [퀴즈 흐름](git-review-quiz/quiz-call-flow.md), [계약](../30_contract/github-integration.md), [명세](../40_domain/specs/git-review-quiz.md), [승인 게이트 정책](../40_domain/policies/local/external-action-approval-gate.md), [ADR 0017](../50_adr/active/0017-git-review-quiz-study-mode.md), [K-0007](../70_ledger/active/K-0007-quiz-permalink-target-unverified.md), [K-0008](../70_ledger/active/K-0008-quiz-format-vocab-fixture-absent.md) |
| install-skills | `install-skills/SKILL.md` (`--claude…--junie·--all·--clear·--self`) | [설치 흐름](install-skills/install-call-flow.md), [계약](../30_contract/ai-tool-skill-paths.md), [명세](../40_domain/specs/install-skills.md), [ADR 0001](../50_adr/active/0001-skill-deterministic-helper-test-convention.md), [ADR 0009](../50_adr/active/0009-install-skills-self-install.md), [K-0005](../70_ledger/active/K-0005-install-template-exclude-pattern-literal.md) |
| issue-audit | `issue-audit/SKILL.md` (`/issue-audit [--plan]`) | [최종 감사 흐름](issue-audit/final-audit-call-flow.md), [계획 감사 흐름](issue-audit/plan-audit-call-flow.md), [명세](../40_domain/specs/issue-audit.md), [ADR 0004](../50_adr/active/0004-cross-model-audit-and-response-gate.md), [ADR 0006](../50_adr/active/0006-risk-matrix-and-treatment.md), [ADR 0014](../50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md), [ADR 0016](../50_adr/active/0016-spec-requirements-layer-and-plan-audit.md), [K-0002](../70_ledger/active/K-0002-audit-axis-tiebreak-absent.md), [K-0009](../70_ledger/active/K-0009-plan-audit-fake-d-check-manual.md), [K-0010](../70_ledger/active/K-0010-check-plan-line-based-markdown-boundary.md) |
| issue-work | `issue-work/SKILL.md` (`--workflow-only·--resume·--response·--clear`) | [새 이슈 시작 흐름](issue-work/start-call-flow.md), [--response 흐름](issue-work/response-call-flow.md), [--clear 흐름](issue-work/clear-call-flow.md), [계약](../30_contract/github-integration.md), [명세](../40_domain/specs/issue-workflow.md), [승인 게이트 정책](../40_domain/policies/local/external-action-approval-gate.md), [ADR 0003](../50_adr/active/0003-verification-levels-and-determinization.md), [ADR 0004](../50_adr/active/0004-cross-model-audit-and-response-gate.md), [ADR 0005](../50_adr/active/0005-model-separation-gates.md), [ADR 0013](../50_adr/active/0013-long-output-single-file-generation.md), [ADR 0015](../50_adr/active/0015-issue-clear-timing-and-archive-rules.md), [ADR 0016](../50_adr/active/0016-spec-requirements-layer-and-plan-audit.md), [K-0004](../70_ledger/active/K-0004-clear-preserve-destination-mismatch.md) |
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
│   ├── response-call-flow.md
│   └── start-call-flow.md
└── index.md
```

## 공통 참조

스킬 전반의 구현 방식을 정하는 문서다. 상세 흐름의 Why 절이 이 문서들을 가리킨다.

- [architecture.md 디자인 원칙](../10_rules/architecture.md): 결정적 로직을 `scripts/`로 분리하는 판단 체크리스트와 `scripts/`·`SKILL.md`·`references/`·`templates/`·`tests/`의 역할 분담
- [ADR 0001](../50_adr/active/0001-skill-deterministic-helper-test-convention.md): 헬퍼는 `<skill>/scripts/`, 테스트는 `<skill>/tests/`, 배포 시 `tests/` 제외(제외 패턴의 단일 출처는 `install-skills/SKILL.md` 5단계)
- [ADR 0002](../50_adr/active/0002-skill-independence-intentional-duplication.md): 스킬은 AI-CONTEXT 비의존·단독 설치. 공통 규칙(트리 정렬·위험도 매트릭스·카테고리 7종·접기 기준)은 스킬별 복제 + 동기화 주석이며 참조 링크로 대체하지 않는다
- [ADR 0003](../50_adr/active/0003-verification-levels-and-determinization.md): 완료 기준의 검증 레벨 `[D]`/`[QD]`/`[ND]`, 결정화 판단은 architecture.md 체크리스트(임계 수치 없음), 헬퍼 경로 표기 `'<skill 디렉토리>/scripts/<헬퍼>'`
- [ADR 0008](../50_adr/active/0008-writing-principles-ssot-distribution.md): 산출물 작성 원칙의 단일 원본은 ai-workspace 템플릿의 `writing-principles.md`. 산출물 스킬 8종(git-pr·git-qa·issue-work·issue-audit·git-review·git-review-context·context-save·context-harvest)은 접기 기준을 내장하고 조건부로 참조한다
- [ADR 0010](../50_adr/active/0010-output-format-templates-separation.md): 산출물 형식 블록은 `templates/`로 분리하고 SKILL.md는 참조만 둔다. 표기는 "이 skill 디렉토리의 `templates/<파일>`"(제외: git-commit·git-pr-feedback)
- [표기·명명 관례](../40_domain/policies/local/notation-conventions.md): 분류 값 한글 우선 병기, 모델 기록 "벤더, 모델명", 트리 정렬, 이모지는 산출물 값 명세에만, 스킬·옵션 이름은 사용자 의도 기준
- [원장 index](../70_ledger/index.md): 수용한 기술부채·known issue. 위 표의 `K-` 링크가 스킬별 대응이다. 위치·필수 필드·소비자 3종의 결정은 [ADR 0007](../50_adr/active/0007-tech-debt-ledger-location-and-structure.md)
- 헬퍼 공통 규약: 통과는 무출력·종료 코드 0, 위반은 사유 1행씩·종료 코드 1, 사용오류는 종료 코드 2 (`validate-message.sh`·`check-clear.sh`·`check-plan.sh`·`check-quiz.sh`·`verify-submit.sh`·`verify-push.sh`·`verify-install.sh`·`check-context.sh`·`check-lobby.sh`). 산출형 헬퍼(`classify-risk.sh`·`summarize-metrics.sh`·`next-finding-number.sh`)는 값을 출력하고 종료 코드 0이다
- `classify-risk.sh`는 git-review와 issue-audit에 각각 있으며 내용이 다르다(issue-audit 쪽에 `--treatment`·`--compliance` 추가). 스킬 독립성 원칙으로 공유하지 않는다([ADR 0002](../50_adr/active/0002-skill-independence-intentional-duplication.md)). 매트릭스 원본은 issue-audit([ADR 0006](../50_adr/active/0006-risk-matrix-and-treatment.md)), 카테고리 7종 원본은 git-review([ADR 0014](../50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md))

## 태그 현황

- `[DOC-NEEDED]` 0건: 최초 build의 2건은 2026-09-09 sync에서 해소했다. 교차모델 audit 수동 수행 원칙은 [ADR 0004](../50_adr/active/0004-cross-model-audit-and-response-gate.md), 외부 공개 행위 승인 게이트 원칙은 [승인 게이트 정책](../40_domain/policies/local/external-action-approval-gate.md)과 [ADR 0011](../50_adr/active/0011-git-pr-submission-and-approval-gate.md)이 담는다
- `[WHY-NEEDED]` 0건: 각 스킬의 설계 근거는 작성자가 SKILL.md 본문(`설계 원칙`·근거 절)에 직접 기재했다. 상세 흐름의 Why 절이 그 절 이름을 가리킨다
- `[UPDATE-NEEDED]` 0건: 2026-09-09 sync. `5ab2b67` 이후 스킬 소스 변경 없음(작업 트리 변경은 `.ai/` 문서와 README뿐)
