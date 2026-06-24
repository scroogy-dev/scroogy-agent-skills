# Issue #26 스펙 issue-audit 리포트에 '감사 모델' 기재 추가

## 목표 (Goal)

issue-audit 감사 리포트가 자기기술(self-describing)하도록 상단 메타에 감사 모델을 기재해, summary의 audit 모델 칸과 교차 대조로 "구현 모델 ≠ audit 모델" 조건을 결정적으로 확인할 수 있게 한다.

---

## 범위 (Scope)

**포함 (In)**

- `issue-audit/templates/issue-audit-report-template.md` 상단 메타에 `> 감사 모델: <모델명>` 한 줄 추가
- (선택) `issue-audit/SKILL.md`에 감사 모델 기재 안내 1줄 포인터

**비포함 (Out)**

- `issue-work` summary 템플릿 변경 (이미 issue #25에서 audit 모델 칸 보유)
- 모델 일치/불일치 자동 검사 스크립트

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D]  리포트 템플릿 상단에 '감사 모델' 메타 줄이 있음  (검증: `grep -i '감사 모델' issue-audit/templates/issue-audit-report-template.md`)
- [ ] [ND] 추가 줄이 기존 메타 표기·톤과 일관됨  (검증: 사람 리뷰)  ← 강등 사유: 톤 일관성은 주관 영역

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `issue-audit/templates/issue-audit-report-template.md` | 수정 대상 — 상단 메타에 감사 모델 줄 추가 |
| `issue-audit/SKILL.md` | (선택) 감사 모델 기재 안내 포인터 추가 대상 |
| `issue-work/templates/issue-summary-template.md` | 교차 대조 상대 — summary의 audit 모델 칸 (issue #25에서 추가, 본 이슈에서 변경 안 함) |

> 동기: issue #25 (issue-work 템플릿 결정적 DoD + 교차모델 audit). issue #25 작업 중 리포트에 모델 기재가 없어 summary 모델 칸을 채우려고 사람에게 어느 모델로 감사했는지 되물어야 했던 사례가 직접 배경이다.
