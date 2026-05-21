# Issue #0003 실행요약 에이전트 서치를 위한 스킬 보강

> 스펙: [issue-0003-spec.md](./issue-0003-spec.md) | 계획: [issue-0003-plan.md](./issue-0003-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task 2 — 루트 로비(`ai-workspace-directory`) 보강 설계

---

## Task별 수행 결과

### Task 1: 현재 상태 진단

- **결과**: 완료
- **수행 내용 요약**:
  - `ai-workspace-directory/SKILL.md`와 `ai-workspace/SKILL.md`, 그리고 `ai-workspace/templates/{dev,doc}/.ai/AI-CONTEXT.md`를 정독해 로비/빌딩 현재 안내판 항목을 표로 정리.
  - 임의의 에이전트가 루트 로비만 보고 repo를 고를 수 있는가 7개 시나리오(A~G)로 갭 분석: 로비 측은 floor 진입 절차·placeholder fallback 부재가 주된 갭, 빌딩 측은 building 역참조·자기 도메인 선언·SSoT 원칙·답변 전 참조 순서 부재가 핵심 갭.
  - 보강 항목 10건과 각 항목의 대상 스킬·파일 1:1 매핑을 진단 노트에 정리. Task 2는 로비 측(#1, #2, #8, #9, #10), Task 3은 빌딩 측(#3~#7, #9, #10) 항목으로 분리됨.
  - 진단 노트: `.ai/99_workspace/notes/2026-05-21-issue-0003-task1-diagnosis.md`
- **특이 사항**:
  - 현재 로비는 단방향(로비 → floor)이어서 floor 단독 진입 에이전트가 building을 식별 불가. 보강 #3·#4로 양방향화 필요.
  - floor 안내도의 `디렉토리 구조` 섹션은 템플릿 placeholder(`└── ...`) 상태로 설치되므로 `ai-workspace update`가 갱신해주지 않으면 라우팅에 도움이 안 됨 — Task 4에서 갱신 동작 점검 필요.

---

### Task 2: 루트 로비(`ai-workspace-directory`) 보강 설계

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 3: 빌딩(`ai-workspace`) 보강 설계

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 4: 스킬·템플릿 반영

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 5: 자가 검증 및 본 repo 로비 정합 확인

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:
