# Issue #31 스펙 교차모델 audit 리포트 검토→피드백→승인 실행 흐름 옵션화

## 목표 (Goal)

Task N 교차모델 `issue-audit` 리포트를 받았을 때 "피드백 먼저, 실행은 승인 후"라는 게이트를 `issue-work`의 옵션·절차로 표준화하여, 자연어 지시 없이도 신규 세션·다른 모델에서 동일하게 재현되게 한다.

---

## 범위 (Scope)

**포함 (In)**

- `issue-work`에 audit 리포트 검토 옵션 추가 (옵션 이름 확정 포함)
- 옵션 동작 절차화: 리포트 읽기 → 발견사항별 **피드백만**(이 단계 수정 금지) → 보정 대상·방향(반영/이관/보류) 표 제시 → **항목 단위 승인** 질의 → 승인된 항목만 보정, 미승인은 보류·별도 이슈 이관
- `issue-workflow.md` 절차(템플릿 SSoT + active 복사본)에도 동일 게이트 반영 — 컨텍스트 초기화 후에도 유지 (#29 F-1과 동일 이유로 옵션 + 절차 둘 다)
- `issue-audit`과의 경계 명시: audit **수행** = 사용자(타벤더 모델)·`issue-audit`, 리포트 **피드백·보정** = `issue-work`

**비포함 (Out)**

- audit 자체 실행 (사용자가 타벤더 모델로 수동 수행 — #29)
- 승인 없는 자동 보정

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D]  `issue-work` SKILL의 `## 옵션`에 새 옵션 1개가 추가된다  (검증: `grep -cE '^### `--' issue-work/SKILL.md` ≥ 4 — 기존 `--workflow-only`/`--resume`/`--clear` 3개 + 신규 1개)
- [ ] [D]  `issue-workflow` 템플릿(SSoT)과 active 복사본이 동일하다  (검증: `diff issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md` 차이 없음)
- [ ] [QD] 옵션·절차가 "피드백 먼저 → 항목별 승인 → 승인분만 보정" 게이트와 `issue-audit` 경계를 누락 없이 절차화했다  (검증: 교차모델 `issue-audit`)  ← 강등 사유: 절차 문장의 의미적 완전성은 문자열 매칭으로 못 거른다
- [ ] [ND] 옵션 이름이 "무엇에 대한 피드백·실행 게이트"인지 그 성격을 드러낸다  (검증: 사람 리뷰)  ← 강등 사유: 이름 적절성은 주관 판단이다

---

## 열린 결정 (이슈 진행 시 확정 — plan Task 1)

- **옵션 이름**: `--feedback`은 "무엇에 대한" 피드백인지 모호. 게이트 성격을 살린 후보(`--review-audit` / `--triage` / `--from-audit` 등)와 비교해 확정한다. (이름 선정은 대칭·메타포보다 사용자가 그 기능을 부를 때의 의도 기준)
- **자동탐색 기본 경로**: 리포트는 `issue-audit`이 `.ai/99_workspace/issue-<번호>-audit-report.md`에 생성. 기본 탐색 경로·다중 리포트 처리·인자 생략 시 동작을 확정한다.
- **옵션 + 절차문서 동시 반영 여부**: 옵션 플래그(호출용) + `issue-workflow.md` 절차(컨텍스트 초기화 후 유지용)를 둘 다 둘지. (#29 F-1과 같은 이유로 둘 다 권장)

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `issue-work/SKILL.md` | 수정 대상 — 옵션 추가 |
| `issue-work/templates/issue-workflow-template.md` | 수정 대상 — 게이트 절차 반영 (SSoT, active 복사본과 동기화) |
| `.ai/90_issues/archive/issue-0029/` | 교차모델 audit 실행 주체·"AI 자동 마감 금지" 게이트 명문화 — 본 이슈는 그 **실행 절차 버전** (명시적 참조 시에만 읽음) |
| `.ai/90_issues/archive/issue-0026/` | audit 리포트 '감사 모델' 기재 — 리포트 산출물 측 참고 (명시적 참조 시에만 읽음) |
