# Issue #29 실행계획 교차모델 audit 실행 주체·모델 명확화 + summary 모델 표기 일관화 + issue-work↔issue-audit 연관성

> 스펙: [issue-0029-spec.md](./issue-0029-spec.md)

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> 각 작업은 독립적으로 검증 가능해야 하며, **완료 기준은 자연어 대신 실행 명령 + 임계값**으로 적습니다.
> 마지막 고정 Task(교차모델 issue-audit)는 삭제하지 말고 그대로 둡니다.

### Task 1: plan 템플릿 Task N 고정 블록 개정

- [x] 완료
- **목표**: Task N 고정 블록에 실행 주체(사용자)·모델 범위(타벤더 포함)·AI 자동 종료 금지·결과 기록 위치를 명문화한다.
- **작업 내용**:
  1. `issue-work/templates/issue-plan-template.md`의 Task N 블록에서 "다른 모델로 `issue-audit`를 실행한다"를 **"사용자가 직접, 다른 벤더(Non-Anthropic 포함) 모델로 수동 수행한다. 구현 AI는 이 Task를 자동으로 닫지 않는다"**로 개정한다.
  2. audit 결과(지적 사항·감사 모델)를 사용자가 받아 **summary에 반영·기록**한다는 흐름을 블록에 명시한다.
  3. 완료 기준 줄을 새 흐름에 맞게 갱신한다 (구현 모델 ≠ audit 모델 기록이 summary 모델 칸에 남는다 — 형식은 Task 2와 정합).
- **완료 기준**: 아래 grep 3개 모두 매칭
  - `grep -E '사용자가 직접' issue-work/templates/issue-plan-template.md`
  - `grep -E '다른 벤더|타벤더|Non-Anthropic' issue-work/templates/issue-plan-template.md`
  - `grep -E '자동.*(종료|닫)' issue-work/templates/issue-plan-template.md`

---

### Task 2: summary 템플릿 모델 기록 "벤더, 모델명" 형식 통일

- [x] 완료
- **목표**: "모델 기록" 표의 계획·구현 칸과 audit 칸을 모두 "벤더, 모델명" 형식으로 통일하고, 계획·구현 칸 예시가 특정 벤더로 고정돼 보이지 않게 한다(개발도 어느 벤더·모델이든 가능).
- **작업 내용**:
  1. `issue-work/templates/issue-summary-template.md`의 모델 기록 표 예시를 `Anthropic, Claude Opus 4.8 (claude-opus-4-8)` / `OpenAI, GPT-5.x` / `Google, Gemini 3.x` 형식으로 교체한다.
  2. 형식 안내 주석을 "벤더, 모델명" 통일 형식으로 갱신하고, #26(리포트 측 감사 모델)과 형식이 어긋나지 않음을 의식해 작성한다.
  3. 계획·구현 모델도 audit 모델도 어느 벤더·모델이든 가능함이 드러나도록, 계획·구현 칸 예시를 한 벤더로 고정하지 않고 복수 벤더를 노출한다.
- **완료 기준**: 아래 grep 2개 모두 매칭
  - `grep -E 'Anthropic,' issue-work/templates/issue-summary-template.md` (쉼표 포함 "벤더, 모델명" 예시 존재)
  - `grep -E 'OpenAI|Google' issue-work/templates/issue-summary-template.md` (복수 벤더 노출 = 벤더 고정 아님)

---

### Task 3: issue-work/SKILL.md 갱신 (Task N 서술 + issue-audit 상호 참조)

- [x] 완료
- **목표**: SKILL.md의 Task N 관련 서술을 새 흐름(사용자 수동 수행·자동 종료 금지)에 맞추고 `issue-audit` 상호 참조를 추가한다.
- **작업 내용**:
  1. "작업 진행 중"의 교차모델 검증 서술을 "사용자가 직접·다른 벤더 모델로 수동 수행, 구현 AI 자동 종료 금지" 취지로 갱신한다.
  2. `issue-audit`와의 상호 참조(Task N에서 호출되는 관계, 결과를 summary에 기록)를 명시한다.
- **완료 기준**: `grep -c 'issue-audit' issue-work/SKILL.md` ≥ 1 이고, 사용자 수동 수행/자동 종료 금지 취지 문구가 본문에 존재 (사람 확인)

---

### Task 4: issue-audit/SKILL.md 상호 참조 추가

- [x] 완료
- **목표**: `issue-audit`가 `issue-work`의 Task N(교차모델 검증)에서 호출되는 관계·결과 기록 위치를 명시하고, 감사 모델 표기 "벤더, 모델명" 형식을 안내한다(summary와 동일 형식, #26이 준수).
- **작업 내용**:
  1. `issue-audit/SKILL.md`의 "관련 skill" 또는 별도 줄에 `issue-work` Task N과의 상호 참조를 추가한다 (구현 모델과 다른 벤더 모델로 사용자가 수동 실행, 결과를 summary에 반영).
  2. 감사 모델 표기 형식을 "벤더, 모델명"으로 안내한다(summary 모델 기록과 동일). 리포트 템플릿의 실제 '감사 모델' 줄 추가는 #26 소관이며 이 형식을 따른다.
- **완료 기준**: 아래 grep 2개 모두 매칭
  - `grep -E 'Task N|교차모델|구현 모델과 다른' issue-audit/SKILL.md`
  - `grep -E '벤더, 모델명|벤더.*모델명' issue-audit/SKILL.md`

---

### Task 5: 교차모델 audit 지적사항 보정 (F-1, F-2)

- [x] 완료
- **목표**: GPT-5(Codex) 교차모델 audit의 발견 사항 중 F-1·F-2를 보정한다. (audit 리포트: `.ai/99_workspace/issue-0029-audit-report.md`)
- **작업 내용**:
  1. **F-1**: `issue-work/SKILL.md`의 "이슈 완료 시" 1단계에 Task N 사용자 audit 완료 조건(audit 결과·audit 모델이 summary에 기록된 경우에만 완료, 구현 AI가 대신 마감 금지)을 추가한다. 동일 절차를 갖는 `issue-work/templates/issue-workflow-template.md`와 그 사본 `active/issue-workflow.md`에도 반영한다.
  2. **F-2**: plan Task N의 검증 개수 표현을 숫자 고정 없이 "전부 재실행"으로 바꾼다.
  3. **F-3**: 리포트 템플릿 '감사 모델' 줄 정합 점검은 #26으로 이관(코멘트 기록).
- **완료 기준**: 아래 grep 모두 매칭
  - `grep -l '대신 완료 처리하지' issue-work/SKILL.md issue-work/templates/issue-workflow-template.md` (두 파일 모두 매칭)
  - `grep -c '전부.*재실행' .ai/90_issues/active/issue-0029/issue-0029-plan.md` ≥ 1 (Task N이 숫자 고정 없이 "전부 재실행"으로 서술)

---

### Task N (고정): 교차모델 issue-audit 검증

<!--
이 블록은 모든 이슈 계획의 마지막 Task로 고정한다. 삭제하지 말 것.
audit은 L2 [QD] 보완 검증 — L1 [D] 결정적 게이트의 대체가 아니라 보완이다.
-->

- [x] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 **전부** 재실행해 통과를 확인한다(개수는 DoD 변경에 따라 달라지므로 숫자에 묶지 않는다).
  2. 계획·구현을 수행한 모델과 **다른 모델**(최소 동급 이상 역량)로 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 지적 사항을 summary에 반영하고 필요 시 앞 Task를 보정한다.
- **완료 기준**: `[D]` 검증 명령 전부 통과 + 구현 모델 ≠ audit 모델 기록이 summary 모델 칸에 남는다.

> 본 이슈는 이 고정 블록 자체의 문구를 개정하는 작업이므로(Task 1), audit 실행 시 개정된 블록 기준으로 수행한다 — **사용자가 직접, 다른 벤더 모델로 수동 수행하며 구현 AI는 이 Task를 자동으로 닫지 않는다.**
