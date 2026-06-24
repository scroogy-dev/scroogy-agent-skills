# Issue #31 실행요약 교차모델 audit 리포트 검토→피드백→승인 실행 흐름 옵션화

> 스펙: [issue-0031-spec.md](./issue-0031-spec.md) | 계획: [issue-0031-plan.md](./issue-0031-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task N — 교차모델 issue-audit (사용자가 직접 타벤더 모델로 수동 수행). 구현 AI는 자동 실행·종료하지 않음.

## 모델 기록

<!--
형식: "벤더, 모델명". 계획·구현 모델도 audit 모델도 어느 벤더·모델이든 가능하다
(예: Anthropic, Claude Opus 4.8 (claude-opus-4-8) / OpenAI, GPT-5.x / Google, Gemini 3.x).
"audit 모델 ≠ 구현 모델" 조건을 나중에 명령으로 확인 가능하도록 기록한다. 모델 전환은 사람이 수행하므로 기계로 강제하기 어렵다.
-->

| 구분 | 모델 |
|------|------|
| 계획·구현 모델 | Anthropic, Claude Opus 4.8 (claude-opus-4-8) |
| audit 모델 | <!-- 구현 모델과 다른 벤더 모델. 형식: 벤더, 모델명. 마지막 교차모델 audit Task에서 사용자가 기록 --> |

---

## Task별 수행 결과

### Task 1: 열린 결정 확정

- **결과**: 완료
- **수행 내용 요약**:
  1. **옵션 이름 = `--response`** — 감사 도메인 정식 용어(auditee/management response)와 일치, `issue-audit`의 짝, 동의·반론·보정을 중립 포괄. 사용자가 동사형 `--respond`보다 개발자 친숙한 명사형 `--response` 선택.
  2. **자동탐색 = 인자 없는 플래그** — 생략 시 `active/` 이슈 번호로 `.ai/99_workspace/issue-<번호>-audit-report.md` 자동 탐색, 여러 개면 목록 제시 후 선택. (기존 옵션의 인자 없는 패턴과 일치)
  3. **옵션 + 절차 동시 반영 = 둘 다** — 플래그(호출용) + `issue-workflow.md` 절차(컨텍스트 초기화 후 유지용). #29 F-1과 동일 근거.
- **특이 사항**: 옵션 이름은 후보 비교 2회 + 사용자 직접 제안을 거쳐 확정. spec "열린 결정" 섹션에 확정 결과 반영함.

---

### Task 2: SKILL.md에 옵션 추가

- **결과**: 완료
- **수행 내용 요약**:
  1. `issue-work/SKILL.md` `## 옵션`에 `--response` 섹션 추가 (`--resume`과 `--clear` 사이 — 재개→audit응답→정리 흐름순). 요약 + 용도 + **경계**(audit 수행=사용자/`issue-audit`, 검토·피드백·보정=이 옵션) + 동작 5단계(리포트 확보→피드백만/수정금지→처리방향 표→항목별 승인→승인분만 보정).
  2. `## 작업 진행 중`에 진입점 연결 불릿 추가 — audit 리포트를 받으면 `--response`로 검토, 피드백 먼저·항목별 승인 후에만 보정.
- **특이 사항**: `grep -cE '^### \`--' issue-work/SKILL.md` = 4 (완료 기준 ≥ 4 충족). 옵션 정의만으로 발견성이 약해 본문(`## 작업 진행 중`)에서 옵션을 가리키도록 보강함.

---

### Task 3: issue-workflow.md 절차 반영 (SSoT + active 동기화)

- **결과**: 완료
- **수행 내용 요약**:
  1. `issue-work/templates/issue-workflow-template.md`(SSoT) `## 작업 진행 중`에 게이트 불릿 추가 — audit 리포트를 받으면 `--response`로 검토, 피드백 먼저·항목별 승인 후에만 보정, 자동 보정 금지.
  2. `cp`로 active 복사본 `.ai/90_issues/active/issue-workflow.md`를 템플릿과 동일하게 동기화.
- **특이 사항**: `diff issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md` 차이 없음(완료 기준 충족). 템플릿은 컨텍스트 초기화 후 핵심 절차만 유지하는 성격이라 SKILL.md보다 간결하게 1줄로 기재.
- **게이트 완전성 보강(범위 추가)**: `issue-work/templates/issue-plan-template.md`의 Task N(고정) 블록 3번에 audit 결과 보정을 `--response`로 연결(피드백 먼저·항목별 승인 후 보정). audit 실행(Task N)→결과 처리(`--response`) 고리를 닫음. 이 이슈 자신의 `issue-0031-plan.md` Task N도 동일하게 동기화.

---

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

- **결과**: <!-- 완료 / 부분 완료 / 스킵 -->
- **수행 내용 요약**:
- **특이 사항**:
