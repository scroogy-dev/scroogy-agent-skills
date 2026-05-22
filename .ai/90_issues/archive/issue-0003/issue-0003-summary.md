# Issue #0003 실행요약 에이전트 서치를 위한 스킬 보강

> 스펙: [issue-0003-spec.md](./issue-0003-spec.md) | 계획: [issue-0003-plan.md](./issue-0003-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다.

---

## Task별 수행 결과

### Task 1: 현재 상태 진단

- **결과**: 완료
- **수행 내용 요약**:
  - `ai-workspace-directory/SKILL.md`와 `ai-workspace/SKILL.md`, 그리고 `ai-workspace/templates/{dev,doc}/.ai/AI-CONTEXT.md`를 정독해 로비/층별 안내도 현재 안내판 항목을 표로 정리.
  - 임의의 에이전트가 루트 로비만 보고 repo를 고를 수 있는가 7개 시나리오(A~G)로 갭 분석: 로비 측은 floor 진입 절차·placeholder fallback 부재가 주된 갭, 층별 안내도 측은 building 역참조·자기 도메인 선언·SSoT 원칙·답변 전 참조 순서 부재가 핵심 갭.
  - 보강 항목 10건과 각 항목의 대상 스킬·파일 1:1 매핑을 진단 노트에 정리. Task 2는 로비 측(#1, #2, #8, #9, #10), Task 3은 층별 안내도 측(#3~#7, #9, #10) 항목으로 분리됨.
  - 진단 노트: `.ai/99_workspace/notes/2026-05-21-issue-0003-task1-diagnosis.md`
- **특이 사항**:
  - 현재 로비는 단방향(로비 → floor)이어서 floor 단독 진입 에이전트가 building을 식별 불가. 보강 #3·#4로 양방향화 필요.
  - floor 안내도의 `디렉토리 구조` 섹션은 템플릿 placeholder(`└── ...`) 상태로 설치되므로 `ai-workspace update`가 갱신해주지 않으면 라우팅에 도움이 안 됨 — Task 4에서 갱신 동작 점검 필요.

---

### Task 2: 루트 로비(`ai-workspace-directory`) 보강 설계

- **결과**: 완료
- **수행 내용 요약**:
  - 라우팅 신호 정의: 기존 `Repos`(path/domain/keywords/status, 구버전 `Floors`에서 명칭 변경) + `라우팅 규칙` 유지하되, `에이전트 운영 지침` 섹션을 `### 진입 절차`(4단계 번호) + `### 작성 규칙`(글머리) 두 서브헤딩으로 분리해 에이전트 진입 절차를 산출물에 명시.
  - SSoT 위치·문구 확정: 본문 두 번째 줄에 `> SSoT: 소스 코드. 이 파일은 라우터일 뿐 진실의 원천이 아니다.` 고정. `last updated` 바로 아래에 메타로 박아 단독 진입 에이전트가 첫 5초 안에 라우터 정체성을 인식하도록 함.
  - placeholder fallback: 진입 절차 step 3에 `active`/`placeholder`/`archived` 분기 명시 — placeholder는 소스 코드만 SSoT로 사용 + `ai-workspace` 안내도 생성 권유.
  - update 모드 멱등 보강: 형식 위배 검사 2개(SSoT 선언, 진입 절차 4단계), 재구성 규칙 3개(자동 보강·사용자 추가분 보존), SSoT 위배 체크리스트 2개 신규 추가.
  - drift 진단 확장: floor 자기 선언 메타가 있을 때만 동작하는 메타 일치 검사 표 추가 (`domain`/`keywords` 2행). Task 3에서 floor 측 메타 블록 필드명을 일치시키는 것이 전제. (사용자 보정: `building` 비교 행은 CoC 도입으로 제거)
  - 상호 참조 강화: `ai-workspace-directory/SKILL.md` "관련 skill"에 양방향 메타 한 줄 추가.
  - SKILL.md 변경 지점 10곳 표로 정리 — Task 4에서 순서대로 적용.
  - 설계 노트: `.ai/99_workspace/notes/2026-05-21-issue-0003-task2-lobby-design.md`
- **특이 사항**:
  - 6개 H2 표준 섹션의 **이름·순서는 변경 없음**. 산출 호환성 보호 + update 멱등성 확보 위해 변경을 섹션 내부 골격에 한정.
  - drift 메타 검사는 Task 3 산출(floor 자기 선언 메타) 의존. Task 4 반영 시 필드명 동기화 필수.
  - 본문 추가 분량: 약 6~8줄(SSoT 1줄 + 진입 절차 4~5줄 + 작성 규칙 2줄). 250줄 가드레일 영향 미미.

---

### Task 3: 층별 안내도(`ai-workspace`) 보강 설계

- **결과**: 완료
- **수행 내용 요약**:
  - 신규 섹션 2개 정의:
    - `## 프로젝트 도메인` (2행 표 — `domain` / `keywords`). 본문 상단(헤더와 `프로젝트 목적` 사이)에 삽입.
    - `## 에이전트 운영 지침` (전제 컨벤션 한 줄 + 진입 절차 3단계 + 작성 규칙). `.ai 디렉토리 구조` 바로 다음에 삽입.
  - 본문 두 번째 줄에 SSoT 선언 1줄 고정 (상위 안내도와 동일 패턴): `> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.`
  - 라우팅 방향 원칙: 에이전트는 `.ai/` 라우터를 통해 코드로 진입한다 (`.ai/` → `60_codebase/index.md` → 코드). 따라서 `60_codebase/index.md` 포인터는 `## 에이전트 운영 지침 > 진입 절차` step 2 한 곳에만 두고, `## 디렉토리 구조`(코드 트리 개관)에는 두지 않는다.
  - `## 디렉토리 구조`에서 `.ai/`는 한 줄로만 표시 (`├── .ai/  # AI 협업 가이드 (상세는 ".ai 디렉토리 구조" 섹션)`). 내부 구조는 별도 섹션이 다루므로 중복·라우팅 분기를 피함. 두 프로파일 템플릿 placeholder 주석에 가이드 한 줄 추가, update-4단계에 펼쳐짐 검사 추가.
  - **컨벤션 우선 (CoC) 도입**: 상위 워크스페이스 디렉토리 바로 아래 각 repo가 위치한다는 컨벤션 고정. 멀티/단독 repo 여부는 `../.ai/AI-CONTEXT.md` 존재로 자동 판정. 역참조 메타 필드(`building`/`lobby`) 자체를 제거 — 두 SKILL.md 개요/원칙 단락에 "설계 원칙: 컨벤션 우선" 명문화, 산출물 본문 `## 에이전트 운영 지침` 위 전제 한 줄 박음.
  - 메타 블록 어휘 정렬: floor의 `domain`/`keywords`는 상위 워크스페이스 AI-CONTEXT.md `Repos` 행과 1:1 동일. `path`/`status`는 상위 단독 책임으로 floor에 두지 않음.
  - 진입 절차: 4단계 → 3단계로 단축. step 1을 두 진입 경로(상위 워크스페이스 진입 / 직접 진입)로 분기. placeholder 자기 모순 step 제거.
  - update 모드 멱등 보강: update-4단계에 신규 검사 5개 (SSoT 선언 / `프로젝트 도메인` / `## 디렉토리 구조`의 `.ai/` 한 줄 압축 / `에이전트 운영 지침`+전제 / 구버전 `워크스페이스 위치`→`프로젝트 도메인` 마이그레이션). 누락 시에만 표준 골격 삽입, 사용자 작성분은 보존.
  - 멀티/단독 repo 자동 판정 (`<repo>/..의 .ai/AI-CONTEXT.md` 존재). 사용자에게 묻지 않음.
  - 프로파일별 차이: 공통 보강 5개, dev/doc 본질 차이는 `## 기술 스택` 섹션 유무뿐.
  - 상위↔층별 안내도 호환 매트릭스 4종 정리 (메타 블록 부재/존재 × 상위 등록/미등록 × CoC 단독 판정).
  - `ai-workspace/SKILL.md` 변경 지점 8곳 표로 정리 — Task 4에서 Task 2 변경 표와 함께 적용.
  - 설계 노트: `.ai/99_workspace/notes/2026-05-21-issue-0003-task3-floor-design.md`
- **특이 사항**:
  - 기존 섹션 7개의 **이름·순서 변경 없음**. 신규 섹션 2개를 정해진 위치(상단/`.ai 디렉토리 구조` 다음)에 삽입만.
  - YAML frontmatter는 층별 안내도에서도 금지(상위 안내도와 동일 정책). 메타 블록은 마크다운 표 형식.
  - `.ai/` 부재 repo는 층별 안내도 메타 블록을 가질 수 없으므로 drift 메타 검사가 자동으로 스킵됨 — Task 2 §5의 fallback과 정합.
  - 사용자 보정 (2026-05-21):
    1. `60_codebase` 포인터 위치를 `.ai/` 라우터 경유(진입 절차)로 단일화, `## 디렉토리 구조`의 `.ai/`는 한 줄 압축. 같은 원칙("코드 진입은 `.ai/` 라우터 경유, `## 디렉토리 구조`는 코드 트리 개관")의 두 면.
    2. CoC(컨벤션 우선) 도입: 메타 필드 `building`/`lobby`를 제거하고 `../.ai/AI-CONTEXT.md` 존재 자동 판정으로 대체. 표 4행 → 2행, 섹션명 `워크스페이스 위치` → `프로젝트 도메인`. 진입 절차도 4단계 → 3단계로 단축.
    3. 산출물 본문 어휘를 메타포(빌딩/로비/층)에서 평이한 표현("상위 워크스페이스" / "이 repo 안내도")으로 통일.
    4. 로비 산출물 테이블 이름 `Floors` → `Repos` 통일 (Task 2 산출물 + Task 2/3 본문 참조). 설계 노트 본문의 일반 비유("로비는 라우터다", "floor 자기 선언" 등)는 옵션 B에 따라 유지.

---

### Task 4: 스킬·템플릿 반영

- **결과**: 완료
- **수행 내용 요약**:
  - `ai-workspace-directory/SKILL.md` (총 827줄) — Task 2 §7 변경 표를 순서대로 적용:
    - 대전제에 **CoC(컨벤션 우선)** 단락 추가, 우선순위 문구를 *"소스 코드 > 각 repo 안내도 > 이 안내도(상위 워크스페이스)"* 로 갱신
    - 관련 skill 단락에 양방향 도메인 동기화(`domain`/`keywords` 1:1) 한 줄 명시
    - 표준 섹션 구조 골격: 본문 두 번째 줄 `> SSoT: ...` 고정, `에이전트 운영 지침`을 `### 진입 절차`(번호 4단계) + `### 작성 규칙`(글머리) 두 서브헤딩으로 분리, `## Floors` → `## Repos` 통일
    - 섹션별 강제 규칙 표에 SSoT 줄 행과 진입 절차 4단계 필수 명시, 별도 "필수 규칙" 단락에 SSoT 줄·진입 절차 골격 추가
    - SSoT 위배 패턴 진단 체크리스트의 형식·메타 위배에 SSoT 누락·진입 절차 누락·`Floors` → `Repos` 정규화 항목 추가
    - update-1단계 (3) drift 진단에 **메타 일치 검사 표(조건부)** 추가 — repo 자기 선언 `domain`/`keywords`와 1:1 비교, 메타 블록 부재 시 스킵 fallback 안내
    - update-1단계 (4) 형식 위배에 SSoT 선언·`Floors`→`Repos` 마이그레이션·진입 절차 4단계 검사 3개 추가
    - update-2단계 재구성 규칙에 SSoT 자동 삽입·구버전 섹션명 정규화·진입 절차 골격 보강 3개 추가, 출력 형식 골격도 새 골격으로 갱신
    - update-3단계 `category`에 `meta-mismatch` 추가, `floor-toc` → `repo-toc`로 정규화
    - init-4단계 작성 규칙에 SSoT 둘째 줄 의무·진입 절차 골격 명시
    - init/update 모드 예시 산출물 본문을 새 골격(SSoT 선언 + Repos + 진입 절차 4단계 + 작성 규칙)으로 갱신, update 예시 진단 리포트와 보고에 신규 형식 위배 항목 반영
    - 산출물 어휘 정리: `Floors`/`floor` → `Repos`/`repo`로 통일(산출물 명세 표기에 한정, SKILL.md 본문 메타포는 옵션 B에 따라 유지)
  - `ai-workspace/SKILL.md` (총 250줄) — Task 3 §8 변경 표 적용:
    - 개요에 "설계 원칙" 단락 추가 — SSoT는 소스 코드 / **CoC**(`<repo>/../.ai/AI-CONTEXT.md` 자동 판정) / 상위 워크스페이스와의 `domain`/`keywords` 1:1 동기화 명문화
    - "이 구조와 함께 사용 가능한 skill" 목록 최상단에 자매 스킬 `ai-workspace-directory` 추가, 양방향 동기화 관계 명시
    - **init-0단계 신규** — 멀티/단독 repo 자동 판정 (CoC, 사용자에게 묻지 않음)
    - init-2단계 완료 보고에 자동 판정 결과(`multi`/`solo`) 안내 + `## 프로젝트 도메인` 입력 가이드 추가
    - update-4단계 AI-CONTEXT.md 갱신에 **"멱등 보강 검사" 표 5개 항목** 추가 — SSoT 둘째 줄 / `## 프로젝트 도메인` 신규 / `## 디렉토리 구조`의 `.ai/` 한 줄 압축 / `## 에이전트 운영 지침` + 전제 한 줄 / 구버전 `## 워크스페이스 위치`(4행) → `## 프로젝트 도메인`(2행) 마이그레이션
    - 분석 대상에 `<repo>/../.ai/AI-CONTEXT.md` 존재 자동 판정 명시 (CoC, 사용자 입력 요청 없음)
  - `ai-workspace/templates/dev/.ai/AI-CONTEXT.md` (125줄) — 신규 섹션 2개 정확한 위치에 삽입:
    - 본문 두 번째·세 번째 줄에 `> last updated` + `> SSoT` 선언 추가
    - `## 프로젝트 도메인` (2행 표 — `domain`/`keywords`) — 헤더와 `## 프로젝트 목적` 사이
    - `## 디렉토리 구조` placeholder 주석에 `.ai/`는 한 줄로만 표시하라는 가이드 추가 (라우팅 분기 회피)
    - `## 에이전트 운영 지침` — 전제 컨벤션 한 줄 + `### 진입 절차` 3단계 + `### 작성 규칙` — `## .ai 디렉토리 구조` 다음에 삽입
    - 기존 섹션(`프로젝트 목적`/`프로젝트 규칙`/`기술 스택`/`디렉토리 구조`/`.ai 디렉토리 구조`/`Git 정책`/`이슈 작업 워크플로우`) 이름·순서·본문 그대로 유지
  - `ai-workspace/templates/doc/.ai/AI-CONTEXT.md` (115줄) — dev와 동일 보강 (단 `## 기술 스택` 섹션 없음 유지). `## 디렉토리 구조` 가이드만 *"콘텐츠 트리 개관"*으로 어휘 미세 조정.
  - **미세 보완 (Task 5 검증 중 발견)**: `ai-workspace/SKILL.md`의 `> last updated:` 갱신 절차가 `ai-workspace-directory`와 비대칭이었던 일관성 갭을 보강. update-4단계 멱등 보강 검사 표 첫 행에 `> last updated:` 자동 갱신을 추가하고, init-1단계 끝에 placeholder(`YYYY-MM-DD`) → 시스템 날짜 치환 단계를 명시. 이로써 두 스킬 모두 init/update 양 모드에서 매 실행 시 본문 첫 줄을 시스템 날짜로 갱신하는 동일 정책을 따른다.
- **특이 사항**:
  - SKILL.md 본문에서 floor/lobby/building 메타포는 옵션 B에 따라 유지하고, 산출물 명세 어휘(섹션명·컬럼명·status 값·진단 메시지)만 `Repos`/`repo` 어휘로 통일했다. SSOT 위배 체크리스트의 `Floors → Repos` 정규화 검사가 구버전을 자동 흡수한다.
  - update 모드는 모두 **사용자 작성분 보존 + 누락 시에만 표준 골격 삽입**이라는 멱등 원칙을 유지. 신규 검사 항목 모두 동일 정책 적용.
  - 본 repo `.ai/AI-CONTEXT.md`는 보강 전 골격으로 작성되어 있어 `## 프로젝트 도메인` / `## 에이전트 운영 지침` 등이 부재 — Task 5에서 정합 점검·정렬.

---

### Task 5: 자가 검증 및 본 repo 로비 정합 확인

- **결과**: 완료
- **수행 내용 요약**:
  - **본 repo `.ai/AI-CONTEXT.md` 정합 점검**:
    - CoC 자동 판정: `../.ai/AI-CONTEXT.md` 부재 → **단독 repo**.
    - 갭 분석 결과 누락 3건 (보강 전): 본문 둘째 줄 SSoT 선언 / `## 프로젝트 도메인` 섹션 / `## 에이전트 운영 지침` 섹션. 정상 6건: 기존 섹션 순서·`## 디렉토리 구조`의 `.ai/` 한 줄 압축 상태·`## 프로젝트 목적`·`## 프로젝트 규칙`·`## .ai 디렉토리 구조`·`## Git 정책`·`## 이슈 작업 워크플로우`. 보존 대상 2건: `## 스킬 목록`·`## 스킬 작성 규칙` (본 repo 고유 섹션).
    - 보강 적용 (dev 템플릿 기준):
      1. 본문 둘째·셋째 줄에 `> last updated: 2026-05-22` + `> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.` 삽입.
      2. 헤더와 `## 프로젝트 목적` 사이에 `## 프로젝트 도메인` 2행 표 추가 (domain: Agent Skills 모음 저장소 / keywords: agent skills·claude code·ai-workspace 등) + 단독 repo 안내 한 줄.
      3. `## .ai 디렉토리 구조` 다음에 `## 에이전트 운영 지침` (전제 한 줄 + 진입 절차 3단계 + 작성 규칙) 삽입.
    - 결과 분량: 151줄 → 183줄 (+32줄). 산출물 가이드(150~250줄) 정상 범위.
  - **"루트 로비만 본 상태" 시뮬레이션**:
    - 본 repo는 단독 repo이므로 실제 상위 안내도는 없지만, 본 repo가 가상의 멀티 워크스페이스에 등록되었다고 가정해 라우팅 흐름을 시뮬레이션.
    - 가상 로비 `Repos` 행: `| scroogy-agent-skills | Claude Code·Cursor·Gemini CLI·Junie 등 다양한 AI 도구에서 호환되는 Agent Skills 모음 저장소 | agent skills, claude code, ai-workspace, ... | active |`
    - 질의: *"ai-workspace 스킬은 어떻게 동작해?"* → 키워드 `ai-workspace` 매칭 → `scroogy-agent-skills` 후보 → `status: active` → `scroogy-agent-skills/.ai/AI-CONTEXT.md` 진입 → `## 프로젝트 도메인` 검증(keywords ⊇ `ai-workspace` ✓) → `진입 절차 step 2`에 따라 `context-loading.md` 적재 후 `60_codebase/` 또는 `ai-workspace/SKILL.md` 직접 참조 → 답변 가능. **시뮬레이션 통과**.
    - 단독 진입(이 repo만 IDE로 연 상태) 시뮬레이션: `../.ai/AI-CONTEXT.md` 부재 자동 감지 → 단독 repo 경로로 진입 → `## 프로젝트 도메인` + 본문만으로 라우팅 가능. **통과**.
  - **DoD 5항목 점검** (spec의 모든 체크박스 ✅):
    1. **로비 라우팅 정보 명세** ✅ — `ai-workspace-directory/SKILL.md`의 표준 섹션 구조에 `## Repos`(4열 path/domain/keywords/status) + `## 라우팅 규칙` + `## 에이전트 운영 지침 > 진입 절차 4단계`(키워드 추출 → Repos 매칭 → status별 분기 → 충돌 우선순위)가 명세됨.
    2. **로비 → repo 안내도 → 코드/문서 탐색 흐름 명시** ✅ — 로비 측은 `진입 절차 step 3`에서 `<path>/.ai/AI-CONTEXT.md` 진입을 명시, 층별 안내도 측은 `진입 절차 step 2`에서 `context-loading.md` → `30/40/50/60 index.md` 선택 적재를 명시. 두 흐름이 자연스럽게 연결됨.
    3. **산출물 항목 충돌·중복 없이 맞물림** ✅ — 상위 `Repos` 4열(path/domain/keywords/status) vs 층별 안내도 `## 프로젝트 도메인` 2행(domain/keywords). path·status는 상위 단독 책임. 역참조는 CoC로 메타 필드 제거. 양쪽 SKILL.md에 상호 참조(`ai-workspace-directory/SKILL.md` "관련 skill" + `ai-workspace/SKILL.md` "이 구조와 함께 사용 가능한 skill" 최상단)가 양방향 명시.
    4. **SSoT 원칙 명문화** ✅ — `ai-workspace-directory/SKILL.md` 대전제 + 산출물 본문 둘째 줄 SSoT 선언. `ai-workspace/SKILL.md` 설계 원칙 + dev/doc 템플릿 본문 둘째 줄 SSoT 선언. 진입 절차 4단계의 충돌 우선순위(소스 코드 > 각 repo 안내도 > 상위 워크스페이스 안내도)에서도 일관 유지.
    5. **재실행 멱등 정렬 절차** ✅ — 상위: `update-1단계 (4)`에 SSoT/`Floors`→`Repos`/진입 절차 형식 위배 검사 3개 + `update-2단계` 재구성 규칙에 자동 보강 3개. 층별 안내도: `update-4단계`에 멱등 보강 검사 5개(SSoT/프로젝트 도메인/`.ai/` 한 줄 압축/에이전트 운영 지침+전제/구버전 `워크스페이스 위치`→`프로젝트 도메인` 마이그레이션). 모두 *사용자 작성분 보존 + 누락 시 표준 골격 삽입* 원칙.
- **특이 사항**:
  - 본 repo는 doc/dev 혼합 성격(스킬 마크다운 모음이지만 `architecture.md`/`coding-convention.md`가 작성되어 있음). dev 템플릿의 `## 기술 스택` 섹션은 본 repo에 원래 없었고 코드 언어가 사실상 markdown 뿐이라 보강 대상에서 제외.
  - 진입 절차의 단독 분기(`../.ai/AI-CONTEXT.md` 부재 자동 판정)가 본 repo에서 실제로 동작하는지 `[ -f ../.ai/AI-CONTEXT.md ]` 명령으로 검증함 → 단독으로 판정. CoC 컨벤션이 의도대로 작동.
  - `## 프로젝트 도메인` keywords에 본 repo의 12개 스킬 명을 모두 나열하지 않고 도메인 단어(agent skills, claude code, ai-workspace 등)만 담아 라우팅 키워드로서의 가독성 우선. 개별 스킬 검색은 `## 스킬 목록` 표가 담당.
