# Issue #25 스펙 — issue-work 템플릿: 결정적 하네스 기반 DoD + 교차모델 audit

## 목표 (Goal)

`issue-work` 템플릿이 완료 기준을 산문이 아니라 **결정적 검증 단계(명령·테스트·스크립트)**로 끌어내리도록 강제하고, 계획 마지막에 **구현 모델과 다른 모델로 issue-audit**를 의무 실행하게 보강한다.

---

## 범위 (Scope)

**포함 (In)**

- `issue-work/templates/issue-spec-template.md` — `완료의 정의` 섹션에 검증 레벨(L1/L2/L3, `[D]`/`[QD]`/`[ND]`)·핵심 규율·레벨 태그+검증 수단 예시 추가
- `issue-work/templates/issue-plan-template.md` — (a) Task 완료 기준을 자연어 대신 실행 명령+임계값으로 적도록 주석·예시 보강, (b) 마지막 Task로 교차모델 `issue-audit` 검증 고정 블록 추가
- `issue-work/templates/issue-summary-template.md` — 구현 모델 / audit 모델 이름 기록 칸 추가
- (선택) `issue-work/SKILL.md` — 위 규율을 1~2줄 반영 (템플릿이 SSoT, 본문은 포인터만)

**비포함 (Out)**

- 실제 검사기 구현(SKILL.md 형식 검사, AI-CONTEXT 스킬 목록↔디렉토리 정합 검사, 링크 무결성 `scripts/`)과 CI 게이트 구성 — 별도 이슈
- 검사기 도입 시에는 ADR 0001(`scripts/`+`tests/` 동일 위치, 배포 제외)을 따른다

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움).
> 기본은 L1. 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D]  변경된 3개 템플릿의 마크다운 구조가 손상되지 않음 — 코드펜스 짝수·헤딩 존재  (검증: 헤딩/코드펜스 grep)
- [ ] [ND] 변경된 3개 템플릿이 렌더러에서 시각적으로 정상 표시됨  (검증: 사람이 렌더 확인)  ← 강등 사유: 시각 표시 정상 여부는 렌더 결과를 사람이 봐야 판정, 정적 검사로 환원 불가
- [ ] [D]  spec 템플릿에 검증 레벨 태그(`[D]`/`[QD]`/`[ND]`)와 검증 수단 예시가 있음  (검증: `grep -E '\[D\]|\[QD\]|\[ND\]' issue-spec-template.md`)
- [ ] [D]  plan 템플릿에 "마지막 Task = 교차모델 issue-audit" 고정 블록이 있음  (검증: `grep -i 'issue-audit' issue-plan-template.md`)
- [ ] [D]  summary 템플릿에 구현 모델 / audit 모델 기록 칸이 있음  (검증: `grep -i '모델' issue-summary-template.md`)
- [ ] [QD] 새 `완료의 정의` 예시가 검증 레벨(L1/L2/L3)을 오해 없이 전달하는가  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: "오해 없이 전달되는가"는 의미 이해 판단이라 명령으로 합/불 환원 불가
- [ ] [ND] 변경 내용이 기존 템플릿 톤·간결성과 일관됨  (검증: 사람 리뷰)  ← 강등 사유: 톤·간결성은 순수 주관 영역

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 결정적 헬퍼 테스트 위치·배포 제외 규칙. 검사기 구현(Out)의 후속 근거 |
| `/.ai/AI-CONTEXT.md` (상단 SSoT 선언) | 소스코드를 SSoT로 선언해, 문서 산출물의 "소스와의 일관성"을 결정적으로 검사할 수 있는 전제 |
| [GitHub Issue #25](https://github.com/scroogy-dev/scroogy-agent-skills/issues/25) | 원격 이슈 본문(원본 요청·작업 요약). 작업 시 사용한 원본 요청 프롬프트는 작업 종료 후 정리됨(git 이력 참조) |
