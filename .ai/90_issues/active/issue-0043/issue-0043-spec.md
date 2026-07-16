# Issue #43 스펙 issue-work: 모델 분리 운용 지원 — 설계 문서 점검 게이트 및 Task별 모델·보정 지표 기록

## 목표 (Goal)

설계·구현·audit을 서로 다른 모델이 맡아도 문서만으로 인수인계가 되도록 `issue-work`에 점검 게이트 2건을 고정하고, 모델 분리의 효과를 사후 집계할 수 있도록 Task별 모델·보정 지표 기록 형식을 만든다.

---

## 범위 (Scope)

**포함 (In)**

- `issue-plan-template.md` — 설계 종료 게이트 고정 블록 추가 (plan 작성 완료 직전 자기점검)
- 구현 시작 게이트 고정 블록 추가 (구현 첫 Task, 위치는 결정거리에서 확정)
- `issue-spec-template.md` — 전제(Assumptions) 섹션 추가
- `issue-summary-template.md` — Task별 `수행 모델`·`audit 발견`·`보정 반영`·`재시도` 필드 추가
- `모델 기록` 표 구조 결정 및 참조 4곳(plan Task N 완료 기준, SKILL.md `작업 진행 중`·`이슈 완료 시`, `issue-workflow-template.md`) 연동 갱신
- `SKILL.md` 본문 절차 서술 갱신 (새 이슈 시작 시 / 작업 진행 중 / `--response` 연계)
- 기록 형식의 grep 집계 가능성 검증 스니펫

**비포함 (Out)**

- 기존 active 이슈 소급 적용 (신규 이슈부터 템플릿 자동 반영)
- 모델 자동 전환·자동 선택 (모델 전환은 사람이 수행)
- 보정률 자동 집계 도구 (표기 형식만 보장, 집계는 사후 grep)
- 특정 모델·벤더에 맞춘 분기 로직

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D]  `issue-plan-template.md`에 설계 종료 게이트 고정 블록이 있다  (검증: `grep -c '설계 종료 게이트' issue-work/templates/issue-plan-template.md` ≥ 1)
- [ ] [D]  구현 시작 게이트 고정 블록이 결정된 위치에 있다  (검증: `grep -c '구현 시작 게이트' issue-work/templates/*.md` ≥ 1)
- [ ] [D]  `issue-spec-template.md`에 전제(Assumptions) 섹션이 있다  (검증: `grep -c '전제(Assumptions)' issue-work/templates/issue-spec-template.md` ≥ 1)
- [ ] [D]  `issue-summary-template.md`의 Task 블록에 4개 필드가 모두 있다  (검증: `grep -cE '수행 모델|audit 발견|보정 반영|재시도' issue-work/templates/issue-summary-template.md` ≥ 4)
- [ ] [D]  `모델 기록` 표 문구를 참조하는 4곳이 결정된 구조와 일치한다  (검증: 확정 문구로 `grep -rn` 했을 때 구 문구 잔존 0건)
- [ ] [D]  절차·규칙 본문에 특정 모델명이 없다  (검증: `grep -rnE 'Claude|GPT|Gemini|Opus|Sonnet' issue-work/` 결과가 기록 필드 값·주석 예시 라인만 — 그 외 0건)
- [ ] [D]  기록 형식이 grep 집계 가능하다  (검증: 보정률 추출 스니펫이 샘플 summary에서 `보정 반영 / audit 발견` 수치를 뽑아낸다)
- [ ] [D]  기존 active 이슈에 소급 변경이 없다  (검증: `git diff --name-only main...` 에 `90_issues/active/issue-0043/` 외 이슈 파일 0건)
- [ ] [QD] 신설 게이트 2건이 모델 분리 여부와 무관하게(동일 모델·세션 교체 시에도) 동작하는 서술인지  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: "무관하게 동작한다"는 서술의 일반성 판정이라 명령으로 참·거짓을 가릴 수 없다
- [ ] [ND] `SKILL.md` 본문 절차 서술이 템플릿 변경과 어긋나지 않고 읽히는지  (검증: 사람 리뷰)  ← 강등 사유: 문서 가독성·서술 일관성은 사람 판단 영역

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `issue-work/SKILL.md` | 변경 대상 본문 — `작업 진행 중`·`이슈 완료 시`·`--response` 절차 서술 |
| `issue-work/templates/` | 변경 대상 SSoT — spec·plan·summary·workflow 템플릿 4종 |
| `.ai/90_issues/archive/issue-0029/` | 교차모델 audit 실행 주체·AI 자동 마감 금지 결정 (본 이슈 게이트 2건의 선례) |
| `.ai/90_issues/archive/issue-0031/` | `--response` 게이트 — `보정 반영` 건수 정의가 의존 |
| `../.ai/AI-CONTEXT.md` (repo 안내도) | 스킬 작성 규칙 — 템플릿 SSoT 원칙, 스킬 독립성 |
