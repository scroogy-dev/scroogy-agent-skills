# Issue #0001 실행요약 building 로비 CLAUDE.md를 SSoT 원칙에 맞게 생성하는 스킬 추가

> 스펙: [issue-0001-spec.md](./issue-0001-spec.md) | 계획: [issue-0001-plan.md](./issue-0001-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task 5 — 모드 자동 판정 + 비-VCS 환경 안전성

---

## Task별 수행 결과

### Task 1: 스킬 이름·디렉토리 확정

- **결과**: `ai-workspace-directory`로 확정.
- **수행 내용 요약**:
  - 기존 스킬 네이밍 컨벤션을 분석: 대다수가 "대상-행위" 패턴(`readme-sync`, `context-harvest`, `context-save`, `issue-work` 등), `ai-workspace`는 "ai-대상" 예외 패턴.
  - 사용자 의도("건물 안내도 vs 층별 안내도" 메타포)와 `ai-workspace`와의 자매성을 고려해 `ai-workspace-{guide,route,router,directory,index,map}` 후보 비교.
  - 영어권 표준 어휘 조사: 빌딩 로비의 입주자·층 목록 패널 = **building directory**. 어원(라틴어 *directorium*, "방향 지시")이 spec의 "lean 라우터" 정체성과 일치.
  - `code-map`과의 의미 차이 분석: `map`은 동적 흐름(노선도), `directory`는 정적 색인(빌딩 안내판). lobby `.ai/AI-CONTEXT.md`는 색인+라우팅이므로 `directory`가 정확.
- **특이 사항**:
  - `ai-workspace-directory`는 기존 스킬 중 가장 긴 이름이지만, 자매성·의미 정확성을 우선해 채택.
  - `code-map`과는 의도된 차별화(흐름 vs 색인)로 읽힘. 스킬 이름 패턴의 일관성은 "영문 단어 모양"이 아니라 "같은 종류의 일에 같은 단어"라는 원칙으로 정리.

---

### Task 2: 스킬 디렉토리·기본 골격 생성

- **결과**: `ai-workspace-directory/SKILL.md` 빈 골격 생성 완료.
- **수행 내용 요약**:
  - `ai-workspace-directory/` 디렉토리 생성.
  - SKILL.md에 YAML frontmatter 작성 (`name: ai-workspace-directory`, `description`에 트리거 키워드 "로비/lobby/AI-CONTEXT.md/building 인덱스/워크스페이스 안내판" 포함, `ai-workspace`와의 자매 관계 명시).
  - 본문 섹션 헤더 골격 작성: 개요 / 관련 skill / 참조 문서 / 사용법 / 실행 절차(모드 결정·init·update) / 표준 섹션 구조 / SSoT 위배 패턴 진단 체크리스트 / 예시(init·update).
  - 각 섹션은 후속 Task에서 채울 내용을 HTML 주석으로 표시.
- **특이 사항**:
  - **spec DoD 수정**: 라이선스 헤더 항목을 "프로젝트 루트의 LICENSE/NOTICE로 일괄 적용"으로 변경. 기존 12개 스킬 어디에도 SKILL.md 본문에 라이선스 헤더가 없어 일관성 위해 따름. spec의 "포함(In)" 섹션과 DoD 두 군데 모두 수정.
  - `templates/` 디렉토리는 Task 6 예시 작성 시점에 필요 여부를 재판단 (현 시점에는 생성하지 않음).

---

### Task 3: `init` 모드 명세 작성

- **결과**: SKILL.md의 공통 영역과 `init` 모드 절차 + 표준 섹션 구조를 모두 작성 완료.
- **수행 내용 요약**:
  - **공통 영역 채움**: `개요`(building/floor 메타포, 산출물 본질, 두 모드 소개, 파일 경로 규약, 대전제), `관련 skill`(ai-workspace 자매), `참조 문서`, `사용법`.
  - **init 모드 6단계 절차**:
    1. 입력 수집 — building 이름·정체성·floor 목록(`path`/`domain`/`keywords`)·archived 목록 (필수/선택 명시, YAML 입력 예시 포함).
    2. 디스크 스캔으로 floor `status` 결정 — `archived` 명시 → `archived`, 안내도 존재 → `active`, 부재 → `placeholder`(+ 경고 메시지 양식).
    3. `<루트>/.ai/` 디렉토리 부재 시 생성.
    4. `<루트>/.ai/AI-CONTEXT.md` 작성 — YAML frontmatter 금지, 첫 줄 `> last updated: YYYY-MM-DD` 자동 기록.
    5. 분량 가드레일 검증 — 150~250줄 정상, 초과 시 비대 경고, 미달 시 안내.
    6. 보고 — 파일 경로·status별 floor 수·placeholder 경고·가드레일 결과.
  - **표준 섹션 구조** 별도 섹션에 명시:
    - 골격(코드 블록)로 6개 H2 섹션을 순서대로 제시: `정체성`, `Floors`, `라우팅 규칙`, `공통 규약`, `Why 진입점`, `에이전트 운영 지침`.
    - 섹션별 강제 규칙 테이블 — `Floors`는 4열 테이블 고정, `공통 규약`은 포인터만, 도메인 본문/코드 스니펫/floor 상세 목차 금지를 운영 지침에 반복 명시.
    - floor `status` 의미·drift 검사 포함 여부 테이블.
- **특이 사항**:
  - DoD 매핑: 본 Task에서 `init` 모드 동작 / 파일 경로 규약 / YAML frontmatter 없음 + last updated 첫 줄 / floor status 3종 / 150~250줄 가드레일 / 표준 섹션 구조 강제 / 결과물 도메인 본문 미포함 항목을 모두 충족.
  - 미충족 DoD(후속 Task): update 모드(Task 4), 모드 자동 판정(Task 5), 예시(Task 6), SSoT 진단 체크리스트(Task 4).
  - `update` 모드의 drift 검사 정의를 표준 섹션 구조 테이블에 미리 노출해 Task 4의 명세 작성 시 일관성을 확보.
  - **이모지 제거**: 초안에 사용자 강조용 이모지(체크/엑스/경고/정보)를 다수 넣었으나 사용자 지적으로 모두 텍스트 키워드("포함/금지/[경고]/정상/비대/짧음")로 대체. 시스템 정책 및 기존 12개 스킬 일관성에 부합. 향후 재발 방지를 위해 메모리에 규칙 저장 (`feedback_no_emojis_in_files`).

---

### Task 4: `update` 모드 명세 작성

- **결과**: SKILL.md의 `update` 모드 5단계 절차와 SSoT 위배 패턴 진단 체크리스트를 모두 작성 완료.
- **수행 내용 요약**:
  - **update-0단계 (사전)**: 기존 로비 읽기, 디스크 스캔, archived 목록 추출.
  - **update-1단계 (진단 리포트)**: 4개 카테고리 점검 — (1) SSoT 위배(체크리스트 참조), (2) 로비 역할 위배(도메인 본문·코드 스니펫·floor 상세 목차·정책 본문 중복·비대), (3) drift 진단(로비↔디스크 양방향, archived 제외), (4) 형식 위배(last updated·frontmatter·섹션 순서·Floors 4열·status 값). 진단 리포트의 마크다운 출력 형식 예시 명시.
  - **update-2단계 (재구성 전문)**: 표준 섹션 구조로 재정렬·정규화, last updated 갱신, frontmatter 제거, 위배 콘텐츠는 본문에서 제거하고 3단계로 이관. 코드 블록으로 전문 출력 + **사용자 명시 확인 절차**(덮어쓰기 위험 회피) 정의.
  - **update-3단계 (floor 이동 후보 목록)**: YAML 구조로 후속 스킬 친화 출력. 필수 필드 8개(`content_id`/`target_floor`/`target_location_hint`/`category`/`confidence`/`reason`/`source_location`/`excerpt`) + `target_floor` 추정 규칙(키워드 매칭 기반 high/medium/low). 이 단계는 출력만 하고 파일 수정 없음.
  - **update-4단계 (보고)**: 변경 여부·가드레일 결과·placeholder 전환 목록·이동 후보 수.
  - **SSoT 위배 패턴 진단 체크리스트** 별도 섹션:
    - 콘텐츠 위배: 도메인 본문, 코드 스니펫, floor 상세 목차/파일 트리, floor 정책 본문 중복
    - 형식·메타 위배: YAML frontmatter, last updated 형식, 6개 H2 섹션 누락·순서, Floors 4열 위반
    - 분량·정체성 위배: 250줄 초과, Floors/라우팅 규칙 비어 있음, status 값 정의 외
    - 각 항목에 판정 기준과 예시 포함. 체크리스트 위배는 update-1단계 [발견] 항목과 update-3단계 `migration_candidates`로 연결됨을 명시.
- **특이 사항**:
  - **DoD 매핑**: 이번 Task에서 `update` 모드 3단계(진단·재구성·이동 목록) / SSoT 위배 패턴 진단 체크리스트 / drift 진단(archived 제외) / 결과물 도메인 본문 미포함(재구성 시 제거) 항목 충족.
  - **drift 4가지 케이스**: 양방향(로비→디스크, 디스크→로비) + 디렉토리 자체 부재까지 총 4케이스를 표로 명시해 후속 Task 5의 자동 판정 로직과 일관성 확보.
  - **사용자 확인 절차**: update-2단계에서 명시적 승인 절차를 두어 덮어쓰기 위험을 차단. Task 5의 모드 자동 판정에서도 같은 패턴 적용 예정.
  - **lint 경고**: SKILL.md에 테이블 포맷 false positive 경고 다수 발생(라인 178/190/199/221/355/386/398). 한국어 셀과 세퍼레이터 길이 차이 또는 코드 블록 내부 예시 테이블 때문. 실제 마크다운 문법은 정상.

---

### Task 5: 모드 자동 판정 분기

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 6: 예시 2종 작성

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 7: AI-CONTEXT.md / README.md 반영 검토

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 8: DoD 자가 점검 및 마무리

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:
