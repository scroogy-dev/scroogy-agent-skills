# Issue #29 스펙 교차모델 audit 실행 주체·모델 명확화 + summary 모델 표기 일관화 + issue-work↔issue-audit 연관성

## 목표 (Goal)

`issue-work`의 마지막 고정 Task(교차모델 `issue-audit`)를 **사용자가 직접·다른 벤더 모델로 수동 수행**하고 **구현 AI는 자동 종료하지 않음**을 명문화하며, 모델 표기를 **"벤더, 모델명" 형식**(계획·구현·audit 모든 칸, 특정 벤더 고정 아님 — 어느 벤더·모델이든 가능)으로 통일하여 summary와 `issue-audit` 측에 **동일 형식**으로 적용하고, `issue-work`↔`issue-audit` 상호 참조를 양쪽 SKILL.md에 명시한다.

---

## 범위 (Scope)

**포함 (In)**

- `issue-work/templates/issue-plan-template.md` — Task N 고정 블록 개정 (실행 주체=사용자, 타벤더 모델(Non-Anthropic 포함), AI 자동 종료 금지, audit 결과를 summary에 기록)
- `issue-work/templates/issue-summary-template.md` — "모델 기록" 표를 "벤더, 모델명" 형식으로 통일 (계획·구현 칸·audit 칸 모두). **계획·구현 칸도 특정 벤더 고정이 아니라 복수 벤더 예시**로 일반화 (개발도 어느 벤더·모델이든 가능)
- `issue-work/SKILL.md` — "작업 진행 중"/"이슈 완료 시"의 Task N 관련 서술 갱신 + `issue-audit` 상호 참조
- `issue-audit/SKILL.md` — `issue-work` Task N과의 상호 참조(호출 맥락·결과 기록 위치) + 감사 모델 표기 **"벤더, 모델명" 형식 안내**(summary와 동일 형식)

**비포함 (Out)**

- `issue-audit/templates/issue-audit-report-template.md`의 '감사 모델' 줄 추가 — #26 범위. 본 이슈는 "벤더, 모델명" 형식 규칙을 summary 템플릿·`issue-audit/SKILL.md`에 명문화하고, #26이 줄 추가 시 이 형식을 따르도록 제약만 남긴다(리포트 템플릿은 직접 수정하지 않음).
- 모델 일치/불일치 자동 검사 스크립트
- 설치본(`~/.claude/skills/issue-work`, `issue-audit`) 직접 수정 — `install-skills` 배포 경로로 반영되므로 저장소 원본만 수정한다.

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D]  plan 템플릿 Task N 블록에 "사용자가 직접 수행" 취지 문구가 있다  (검증: `grep -E '사용자가 직접' issue-work/templates/issue-plan-template.md`)
- [ ] [D]  plan 템플릿 Task N 블록에 "다른 벤더 모델" 취지 문구가 있다  (검증: `grep -E '다른 벤더|타벤더|Non-Anthropic' issue-work/templates/issue-plan-template.md`)
- [ ] [D]  plan 템플릿 Task N 블록에 "AI 자동 종료 금지" 취지 문구가 있다  (검증: `grep -E '자동.*(종료|닫)' issue-work/templates/issue-plan-template.md`)
- [ ] [D]  summary 템플릿 모델 기록이 "벤더, 모델명" 형식 예시를 포함한다  (검증: `grep -E 'Anthropic,' issue-work/templates/issue-summary-template.md`)
- [ ] [D]  summary 템플릿 모델 기록 예시가 특정 벤더 고정이 아니다(복수 벤더 노출)  (검증: `grep -E 'OpenAI|Google' issue-work/templates/issue-summary-template.md`)
- [ ] [D]  `issue-work/SKILL.md`에 `issue-audit` 상호 참조가 있다  (검증: `grep -c 'issue-audit' issue-work/SKILL.md` ≥ 1)
- [ ] [D]  `issue-audit/SKILL.md`에 `issue-work` Task N 상호 참조가 있다  (검증: `grep -E 'Task N|교차모델|구현 모델과 다른' issue-audit/SKILL.md`)
- [ ] [D]  `issue-audit/SKILL.md`에 "벤더, 모델명" 형식 안내가 있다  (검증: `grep -E '벤더, 모델명|벤더.*모델명' issue-audit/SKILL.md`)
- [ ] [ND] 추가/변경 문구가 #26의 표기 형식("벤더, 모델명")과 어긋나지 않고 기존 톤과 일관됨  (검증: 사람 리뷰)  ← 강등 사유: 톤·형식 정합은 주관 영역
- [ ] [QD] Task N (고정) 교차모델 issue-audit — 스펙 위반·누락·소스코드와의 모순 탐색  (검증: 다른 벤더 모델이 채점, 별도 세션)  ← 강등 사유: 의미 충족 여부는 결정적으로 못 거름

---

## 연관 문서

> `.ai` 내부에 이 이슈와 직접 관련된 계약/도메인/ADR 문서는 없다(인덱스 비어 있음, ADR 0001은 테스트 위치 규칙으로 무관). 아래는 변경 대상 파일과 형식 정합 대상 이슈다.

| 문서 | 역할 |
|------|------|
| `issue-work/SKILL.md`, `issue-work/templates/issue-plan-template.md`, `issue-work/templates/issue-summary-template.md` | 변경 대상 (워크플로우·템플릿 측) |
| `issue-audit/SKILL.md` | 변경 대상 (상호 참조 추가) |
| #26 (issue-audit 리포트에 '감사 모델' 기재) | 본 이슈가 "벤더, 모델명" 형식 규칙을 정의 → #26이 리포트 줄 추가 시 이 형식을 준수 (역할 분리) |
| #28 (도출 맥락) | 교차모델 audit이 Sonnet 서브에이전트로 자동 수행되어 본 이슈 필요성이 드러남 |
