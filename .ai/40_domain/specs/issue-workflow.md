---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/100
last_harvested: 2026-09-09
---

# 이슈 단위 작업 워크플로우(issue-work) 요건

## 요건

- 이슈마다 `.ai/90_issues/active/issue-<번호>/`에 spec·plan·summary 3종을 둔다. 디렉토리 번호는 GitHub 이슈 번호를 4자리로 채운다(issue-0015 ↔ #15).
- 절차 순서: 새 이슈 시작 → 요구사항 승인 게이트 → 완료의 정의·plan·summary 작성 → 계획 종료 게이트 → 계획 감사 수행 여부 질의(선택, `--plan` + `--response`) → Task 0 구현 시작 게이트 → 일반 Task → Task N 교차모델 최종 감사(사용자 수동) → `--response` 보정 → `--clear` 정리 → PR.
- spec 구성: 목표 → 요구사항(포함 R<n>·제외) → 완료의 정의(R 그룹 + 공통, 항목별 검증 레벨 태그) → 전제(Assumptions) → 연관 문서.
- plan 구성: 계획 종료 게이트 블록, Task 0·N 고정 블록, 일반 Task의 `대상 요구사항` 필드, Task별 완료 기준(태그 + 문장 본문, 검증 명령은 접기).
- summary 구성: `모델 기록` 표(계획·계획 audit·구현·최종 audit), `계획 감사` 줄, Task별 `결과`·`수행 모델`·`audit 발견`·`보정 반영`·`재시도`. 지표는 이슈 전체 누적이며 한 발견은 주 Task 하나에만 귀속한다.
- 옵션: `--workflow-only`(워크플로우 강제 복구), `--resume`(요약 보고 → 승인 시 진행), `--response`(감사 리포트 검토 게이트, 최종·계획 리포트 자동 탐색), `--clear`(정리).
- 새 이슈 시작 시 `issue-workflow.md`가 템플릿과 다르면 자동 갱신한다.
- 템플릿이 SSoT다. SKILL.md 본문은 절차 서술과 포인터만 두고, 템플릿 변경은 신규 이슈부터 적용하며 기존 active/archive 이슈에 소급하지 않는다.
- 결정적 헬퍼: `check-clear.sh`(`--clear` 완료·경로 참조 검사), `summarize-metrics.sh`(지표 집계). 러너는 템플릿 본문의 게이트 명령을 추출해 fixture에 실행한다.

## 게이트 요약

| 게이트 | 시점 | 판정 주체 | 근거 이슈 |
|--------|------|-----------|-----------|
| 요구사항 승인 | spec 목표·요구사항 작성 직후 | 사용자 | #100 |
| 계획 종료 | plan 작성 완료 직전 | 작성 AI 자기점검 | #43 |
| 계획 감사·보정 (선택) | plan 완료 후, Task 0 전 | 사용자(타벤더 모델) + `--response` | #100 |
| 구현 시작 (Task 0) | 구현 첫 Task | 사람 | #43 |
| 최종 감사 (Task N) | 모든 일반 Task 완료 후 | 사용자(타벤더 모델) | #25, #29 |
| `--response` 순서 게이트 | 리포트 검토 시 | 사용자 항목별 승인 | #31, #52 |
| `--clear` | 머지 직전 | 사용자 | #15, #21 |

## 관련 결정

- [ADR 0003 검증 레벨](../../50_adr/active/0003-verification-levels-and-determinization.md), [ADR 0004 교차모델 audit](../../50_adr/active/0004-cross-model-audit-and-response-gate.md), [ADR 0005 모델 분리 게이트](../../50_adr/active/0005-model-separation-gates.md), [ADR 0013 긴 산출물](../../50_adr/active/0013-long-output-single-file-generation.md), [ADR 0015 --clear](../../50_adr/active/0015-issue-clear-timing-and-archive-rules.md), [ADR 0016 요구사항 층·계획 감사](../../50_adr/active/0016-spec-requirements-layer-and-plan-audit.md)
- 절차 상세(How)는 `issue-work/SKILL.md`와 `issue-work/templates/`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #15](https://github.com/scroogy-dev/scroogy-agent-skills/issues/15), [#21](https://github.com/scroogy-dev/scroogy-agent-skills/issues/21), [#25](https://github.com/scroogy-dev/scroogy-agent-skills/issues/25), [#29](https://github.com/scroogy-dev/scroogy-agent-skills/issues/29), [#31](https://github.com/scroogy-dev/scroogy-agent-skills/issues/31), [#37](https://github.com/scroogy-dev/scroogy-agent-skills/issues/37), [#43](https://github.com/scroogy-dev/scroogy-agent-skills/issues/43), [#50](https://github.com/scroogy-dev/scroogy-agent-skills/issues/50), [#52](https://github.com/scroogy-dev/scroogy-agent-skills/issues/52), [#66](https://github.com/scroogy-dev/scroogy-agent-skills/issues/66), [#74](https://github.com/scroogy-dev/scroogy-agent-skills/issues/74), [#94](https://github.com/scroogy-dev/scroogy-agent-skills/issues/94), [#100](https://github.com/scroogy-dev/scroogy-agent-skills/issues/100)

</details>
