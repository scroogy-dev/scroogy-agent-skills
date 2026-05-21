# Issue #0003 실행요약 에이전트 서치를 위한 스킬 보강

> 스펙: [issue-0003-spec.md](./issue-0003-spec.md) | 계획: [issue-0003-plan.md](./issue-0003-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task 3 — 빌딩(`ai-workspace`) 보강 설계

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

- **결과**: 완료
- **수행 내용 요약**:
  - 라우팅 신호 정의: 기존 `Floors`(path/domain/keywords/status) + `라우팅 규칙` 유지하되, `에이전트 운영 지침` 섹션을 `### 진입 절차`(4단계 번호) + `### 작성 규칙`(글머리) 두 서브헤딩으로 분리해 에이전트 진입 절차를 산출물에 명시.
  - SSoT 위치·문구 확정: 본문 두 번째 줄에 `> SSoT: 소스 코드. 이 파일은 라우터일 뿐 진실의 원천이 아니다.` 고정. `last updated` 바로 아래에 메타로 박아 단독 진입 에이전트가 첫 5초 안에 라우터 정체성을 인식하도록 함.
  - placeholder fallback: 진입 절차 step 3에 `active`/`placeholder`/`archived` 분기 명시 — placeholder는 소스 코드만 SSoT로 사용 + `ai-workspace` 안내도 생성 권유.
  - update 모드 멱등 보강: 형식 위배 검사 2개(SSoT 선언, 진입 절차 4단계), 재구성 규칙 3개(자동 보강·사용자 추가분 보존), SSoT 위배 체크리스트 2개 신규 추가.
  - drift 진단 확장: floor 자기 선언 메타가 있을 때만 동작하는 메타 일치 검사 표 추가 (`domain`/`keywords`/`building`). Task 3에서 floor 측 메타 블록 필드명을 일치시키는 것이 전제.
  - 상호 참조 강화: `ai-workspace-directory/SKILL.md` "관련 skill"에 양방향 메타 한 줄 추가.
  - SKILL.md 변경 지점 10곳 표로 정리 — Task 4에서 순서대로 적용.
  - 설계 노트: `.ai/99_workspace/notes/2026-05-21-issue-0003-task2-lobby-design.md`
- **특이 사항**:
  - 6개 H2 표준 섹션의 **이름·순서는 변경 없음**. 산출 호환성 보호 + update 멱등성 확보 위해 변경을 섹션 내부 골격에 한정.
  - drift 메타 검사는 Task 3 산출(floor 자기 선언 메타) 의존. Task 4 반영 시 필드명 동기화 필수.
  - 본문 추가 분량: 약 6~8줄(SSoT 1줄 + 진입 절차 4~5줄 + 작성 규칙 2줄). 250줄 가드레일 영향 미미.

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
