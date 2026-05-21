# issue-0003 Task 1 진단 노트 — 에이전트 서치 보강 갭 분석

> 작성일: 2026-05-21
> 이슈: [#3](https://github.com/scroogy-dev/scroogy-agent-skills/issues/3)
> 단계: Task 1 — 현재 상태 진단

---

## 1. 현재 안내판 항목 (로비/빌딩) 표

### 로비 — `ai-workspace-directory` 산출물

루트 `.ai/AI-CONTEXT.md`의 6개 H2 표준 섹션 (강제 순서):

| 섹션 | 보유 정보 | 라우팅 효용 |
|------|----------|-------------|
| `정체성` | building 정체성 2~3문장 | 컨텍스트 진입 — 어떤 building인지 식별 |
| `Floors` | `path` / `domain` / `keywords` / `status` 4열 | **핵심 라우팅 테이블** — repo 후보 산출 |
| `라우팅 규칙` | 키워드/요청 패턴 → `path` 매핑 | 직접 매핑 — 결정 보조 |
| `공통 규약` | floor의 `.ai/10_rules/` 등 포인터만 | 정책 라우팅 |
| `Why 진입점` | ADR·정책 결정 포인터 | "왜" 질의 라우팅 |
| `에이전트 운영 지침` | SSoT 우선순위, archived/placeholder 처리 원칙 | 동작 규범 |

### 빌딩(floor) — `ai-workspace` 산출물

repo별 `.ai/AI-CONTEXT.md` 섹션 (dev 프로파일 기준):

| 섹션 | 보유 정보 | 라우팅 효용 |
|------|----------|-------------|
| `프로젝트 목적` | repo가 하는 일 (주석 placeholder) | floor 정체성 식별 |
| `프로젝트 규칙` + 10_rules 테이블 | architecture / coding-convention / context-loading / file-change-policy | 작업 전 규칙 진입 |
| `기술 스택` (dev만) | 사용 언어/프레임워크/라이브러리 | 기술 스택 라우팅 |
| `디렉토리 구조` | 코드 디렉토리 트리 (주석 placeholder) | 코드 진입점 — 단, placeholder가 다수 |
| `.ai 디렉토리 구조` | 10~99 우선순위 디렉토리 도해 | 문서 라우팅 |
| `Git 정책` | git-commit/pr/review/review-context 스킬 | 작업 절차 |
| `이슈 작업 워크플로우` | issue-work / issue-audit 스킬 | 작업 절차 |

---

## 2. 시나리오 갭 분석 — "임의의 에이전트가 루트 로비만 보고 repo를 고를 수 있는가"

### 시나리오 A: "결제 API 트랜잭션 상태 보여줘"
- 로비의 `라우팅 규칙` + `Floors.keywords`에서 `api-server` 라우팅 가능 — ✅
- 단, **로비 → floor 진입 후 어디까지 어떤 순서로 봐야 하는지**의 단계가 로비에 없음 — ⚠️

### 시나리오 B: "이 repo의 코드 진입점이 어디야?" (이미 floor 안내도를 본 상태)
- floor `디렉토리 구조`가 placeholder(`└── ...`)로 채워져 있으면 정보 부재 — ⚠️
- `60_codebase/index.md`가 더 정확한 진입점인데 floor 안내도에서 강조되지 않음 — ⚠️

### 시나리오 C: "로비에 등록된 floor인데 안내도가 없는 placeholder"
- 로비 `에이전트 운영 지침`에 *"안내도 생성을 안내한다"* 한 줄만 있음
- placeholder 만났을 때 **답변 가능 범위**(코드만 보고 답할지, 사용자에게 멈출지)가 모호 — ⚠️

### 시나리오 D: floor 측에서 "내가 어느 building에 속한 floor인가" 식별
- floor `AI-CONTEXT.md`에 **building 이름·루트 로비 경로** 역참조가 **없음** — ❌
- floor 단독으로 진입한 에이전트가 멀티 repo 컨텍스트로 zoom-out 불가능

### 시나리오 E: floor의 도메인·키워드 자기 선언
- 로비의 `Floors.keywords`는 로비에만 존재
- floor 측 안내도에는 자신의 도메인/키워드 자기 선언이 없어 **drift 가능** — ⚠️

### 시나리오 F: 충돌 시 우선순위
- 로비는 `에이전트 운영 지침`에 *"소스 코드 > floor > 로비"* 명시
- floor 안내도에는 동일한 우선순위·SSoT 원칙이 **없음** — ❌
- floor에만 진입한 에이전트는 우선순위 모름

### 시나리오 G: 에이전트가 답변 전에 .ai 문서를 어떤 순서로 봐야 하나
- floor `.ai 디렉토리 구조`에 숫자 우선순위(10~99) 안내는 있음
- 그러나 "**답변 직전**에 어디부터 어디까지 봐야 하는지" 명시적 진입 절차는 없음 — ⚠️
- `context-loading.md`가 별도 파일로 있어 한 단계 더 들어가야 함

---

## 3. 보강 항목 → 스킬·파일 1:1 매핑

| # | 보강 항목 | 어느 스킬 | 어느 파일/섹션 |
|---|----------|----------|----------------|
| 1 | 로비 → floor 진입 절차 (에이전트가 답변 전에 거치는 라우팅 단계) | `ai-workspace-directory` | `SKILL.md` 표준 섹션의 `에이전트 운영 지침` — 단계형 절차 보강 |
| 2 | `placeholder` floor 만났을 때의 답변 가능 범위 및 fallback | `ai-workspace-directory` | 동상 — `에이전트 운영 지침` 항목 추가 |
| 3 | floor → 로비 역참조 (building 이름·루트 로비 상대 경로) | `ai-workspace` | `templates/dev/.ai/AI-CONTEXT.md`, `templates/doc/.ai/AI-CONTEXT.md` — 상단에 "워크스페이스 위치" 섹션 추가, `SKILL.md`에 갱신 절차 |
| 4 | floor 자신의 도메인·키워드 자기 선언 | `ai-workspace` | 동상 — "프로젝트 목적" 옆 메타 블록(도메인 + 키워드) |
| 5 | floor 측 코드 진입점 명시 (`60_codebase/index.md` 강조 + 주요 진입 모듈) | `ai-workspace` | `templates/dev/.ai/AI-CONTEXT.md` — "디렉토리 구조" 보강 또는 별도 "코드 진입점" 섹션 |
| 6 | floor 측 SSoT·우선순위 원칙 명시 (소스 코드 > floor > 로비) | `ai-workspace` | `templates/dev|doc/.ai/AI-CONTEXT.md` — "에이전트 운영 지침" 섹션 추가 |
| 7 | floor 측 "답변 전 참조 순서" 단계형 명시 | `ai-workspace` | 동상 — `에이전트 운영 지침`에 단계 + `context-loading.md` 링크 |
| 8 | 로비 ↔ floor 메타 일치(drift) 검사 (floor 자기 선언 keywords vs 로비 등록 keywords) | `ai-workspace-directory` | `SKILL.md` `update` 모드 drift 진단 — 키워드/도메인 일치 검사 항목 추가 |
| 9 | 두 스킬의 상호 참조 강화 (양쪽 SKILL.md 첫머리에 "이 산출물은 상대 스킬과 어떻게 맞물리는가") | 양쪽 | 양쪽 `SKILL.md` 개요/관련 skill 섹션 |
| 10 | 보강 후 기존 워크스페이스 재실행 시 멱등 갱신 (`ai-workspace-directory --update`, `ai-workspace update`) | 양쪽 | 양쪽 `SKILL.md` update 모드 — 보강 섹션 누락 시 자동 보강 절차 |

---

## 4. 원칙 점검 (보강 시 위배 금지)

- **SSoT는 무조건 소스코드.** 안내판은 라우터일 뿐. 보강 항목 1~10 모두 라우팅·메타 정보에 한정하고 도메인 본문/코드 스니펫을 안내판에 넣지 않는다.
- **로비는 안내판, floor는 안내도.** 보강 #5(코드 진입점)는 floor의 코드 디렉토리·`60_codebase` 포인터까지만. 함수/클래스 본문은 금지.
- **분량 가드레일**(로비 250줄 미만)을 침해하지 않도록 보강 항목은 각 1~5줄.
- **단방향이 아니라 양방향**(로비↔floor 상호 참조)를 만들어 drift 진단을 가능하게 한다.

---

## 5. 다음 Task로 넘기는 입력

- Task 2 (로비 보강 설계): 위 표의 #1, #2, #8, #9, #10 중 `ai-workspace-directory` 측
- Task 3 (빌딩 보강 설계): 위 표의 #3, #4, #5, #6, #7, #9, #10 중 `ai-workspace` 측
- Task 4 (반영): Task 2/3 설계를 SKILL.md·templates에 일괄 반영
