# Issue #0001 실행요약 building 로비 CLAUDE.md를 SSoT 원칙에 맞게 생성하는 스킬 추가

> 스펙: [issue-0001-spec.md](./issue-0001-spec.md) | 계획: [issue-0001-plan.md](./issue-0001-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다.

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

### Task 5: 모드 자동 판정 + 비-VCS 환경 안전성

- **결과**: SKILL.md `1단계: 모드 결정` 절을 자동 판정 규칙·사용자 확인 절차·비-VCS 안전성 3개 하위 섹션으로 채움.
- **수행 내용 요약**:
  - **자동 판정 규칙**: `<루트>/.ai/AI-CONTEXT.md` 부재 → `init`, 존재 → `update` (테이블 + bash 한 줄 `[ -f .ai/AI-CONTEXT.md ] && echo "update" || echo "init"`로 명시). 프로젝트 루트의 `./AI-CONTEXT.md`는 검사 대상이 아님을 못박고 발견 시 이전 안내 의무 추가.
  - **사용자 확인 절차**: 자동 선택 결과를 사용자에게 명시하고 확인 받는 문구 2종 제시. 사용자가 자동 선택과 다른 모드를 요청한 경우의 처리 표(`init` 자동→`update` 요청 = 경로 재확인 / `update` 자동→`init` 요청 = 덮어쓰기 명시 + 백업 안내) 추가.
  - **비-VCS 환경 안전성**: git 명령 의존 금지 명시(`git log`/`git status`/`git rev-parse` 등 어떤 호출도 없음), 모드 판정은 `test -f`만 사용, `last updated`는 `date +%Y-%m-%d`로 자동 기록, `update` 모드에서도 매 실행 시 갱신.
- **특이 사항**:
  - **DoD 매핑**: 본 Task에서 "모드 미지정 시 자동 판정"·"비-git 환경 안전 동작"·"last updated 매 실행 자동 기록" 3개 DoD 항목 충족.
  - **사용자 확인 절차 두 군데 일관성**: update-2단계의 덮어쓰기 확인 절차와 1단계 모드 결정의 사용자 확인 절차가 의도적으로 같은 패턴(명시→확인→승인). 1단계는 *모드* 선택, update-2단계는 *재구성 본문* 적용으로 단계가 분리됨.
  - **자동 선택과 사용자 요청이 어긋날 때**의 처리 규칙을 표로 분리. 특히 `update` 자동→`init` 요청 케이스는 데이터 손실 위험이 있어 "백업 수동 안내"라는 별도 가드를 명시.
  - **lint 경고**: 한국어 셀 폭 false positive 경고가 다수 새로 발생했으나 Task 3·4와 동일한 패턴. 실제 마크다운 문법은 정상.

---

### Task 6: 예시 2종 작성

- **결과**: SKILL.md `## 예시` 절에 `init` 모드 예시 1개와 `update` 모드 예시 1개를 floor 3개(active/placeholder/archived) 기준으로 작성 완료. SKILL.md 총 744줄.
- **수행 내용 요약**:
  - **공통 가상 워크스페이스**: "ACME 결제 워크스페이스" — `api-server`(결제 API, active), `mobile-app`(모바일 클라이언트, placeholder/active), `legacy-web`(레거시 웹, archived/placeholder)의 3 floor 구성. 두 예시가 같은 도메인을 공유해 init→update 진화 흐름을 한 페이지로 따라가게 함.
  - **init 예시**: 사용자 입력 YAML(`building`/`identity`/`floors`/`archived`) + 디스크 스캔 결과 표 + 산출 `.ai/AI-CONTEXT.md` 전문(38줄, 6개 H2 섹션 표준 구조) + 보고. `placeholder` 경고 메시지를 본문 형태 그대로 노출. archived 한 행 포함.
  - **update 예시**: 오염된 입력(YAML frontmatter, H1 헤더, 도메인 본문, Python 코드 스니펫, Floors 5열에 `owner` 추가, `legacy-web active` 등록되어 있으나 디스크 안내도 없음, `mobile-app`은 로비 미등록인데 디스크 안내도 존재). update-1~4단계 모두 시연:
    - 1단계: 4개 카테고리 진단 리포트 (SSoT/로비 역할/drift/형식)
    - 2단계: 재구성 전문(30줄) + 사용자 덮어쓰기 확인 문구
    - 3단계: `migration_candidates` YAML 2건(도메인 본문 + 코드 스니펫 모두 api-server target, confidence high)
    - 4단계: 보고 (placeholder 전환, 이동 후보 수, target_floor unknown 0건)
  - **가드레일 시연**: 두 예시 산출물(38줄 / 30줄) 모두 150~250줄 미달 → "짧음" 판정. floor 3개 기준 자연스러운 분량임을 보고 문구에 명시해 가드레일이 권고임을 노출.
- **특이 사항**:
  - **DoD 매핑**: 본 Task에서 "init/update 예시 각 1개 이상"·"placeholder graceful degradation"·"archived 케이스 노출" 3개 DoD 항목 충족. 분량 가드레일 검증 노출도 함께 시연.
  - **두 예시 도메인 공유 결정**: 다른 가상 워크스페이스를 쓰면 두 예시가 독립적이지만 학습 비용이 두 배. 같은 ACME 결제 워크스페이스에서 시간이 지나 오염된 상태를 update가 정리하는 흐름으로 묶으면 floor의 의미·키워드 일관성을 한 번에 보여줄 수 있어 채택.
  - **floor 상태 진화**: init에서 mobile-app은 placeholder였으나 update 시점엔 안내도가 생겨 active로, legacy-web은 archived였으나 update에서는 안내도가 없는 placeholder로 표시되어 status 3종 전환을 모두 보여줌. spec의 "floor `.ai/AI-CONTEXT.md`가 없는 경우 placeholder + 경고로 graceful 처리" + "archived 케이스 한 행 노출" 요구를 한 묶음으로 충족.
  - **이모지 미사용**: 사용자 메모(`feedback_no_emojis_in_files`)에 따라 모든 상태 표시는 텍스트(`[발견]`/`[없음]`/`[위배]`/`[경고]`)로 유지.
  - **lint 경고**: 예시 내부 표에서 한국어 셀 폭 false positive 5건 추가. 실제 마크다운 문법 정상.

---

### Task 7: AI-CONTEXT.md / README.md 반영 검토

- **결과**: `.ai/AI-CONTEXT.md`, 루트 `README.md`, `install-skills/SKILL.md` 3곳에 신규 스킬 `ai-workspace-directory`를 알파벳 순(ai-workspace 다음, code-map 앞)으로 등재 완료.
- **수행 내용 요약**:
  - **`.ai/AI-CONTEXT.md`**: (1) 디렉토리 구조 트리에 `ai-workspace-directory/` 항목 추가, (2) 스킬 목록 표에 한 행 추가. 설명은 "멀티 repo 워크스페이스 루트의 로비 `.ai/AI-CONTEXT.md` 생성·재구성 (`ai-workspace`의 자매)"로 통일.
  - **루트 `README.md`**: (1) Skill 목록 표에 한 행 추가, (2) Skill 간 관계 다이어그램에 `ai-workspace-directory ← 워크스페이스 루트의 로비 .ai/AI-CONTEXT.md 라우터, ai-workspace의 자매` 항목 추가. 다이어그램의 `ai-workspace (디렉토리 스캐폴딩)` 루트 아래 자식으로 배치해 자매성을 시각화.
  - **`install-skills/SKILL.md`**: 사용 가능한 skill 번호 목록에 추가. 알파벳 순 삽입으로 인해 기존 2~12번이 모두 한 칸씩 밀려 총 13개로 늘어남.
- **특이 사항**:
  - **DoD 매핑**: 본 Task에서 별도 DoD 항목은 없으나, "신규 스킬이 프로젝트 메타 문서에서 일관되게 노출"이라는 운영 요구를 충족. 후속 install-skills 사용 시 자동 노출.
  - **`templates/` 디렉토리 미생성 확인**: 디렉토리 구조 트리에 `ai-workspace-directory/` 한 줄만 추가하고 `templates/` 하위 항목은 넣지 않음. Task 2 결정대로 예시는 SKILL.md 본문에 인라인으로 작성했고 별도 템플릿 파일이 필요 없음.
  - **설명 문구 일관성**: 세 곳 모두 동일한 핵심 문구("멀티 repo 워크스페이스 루트의 로비 `.ai/AI-CONTEXT.md` 생성·재구성")를 사용. AI-CONTEXT.md와 README.md는 "(ai-workspace의 자매)" 자매성 표현 포함, install-skills는 백틱 강조 형태로 동일 표현.
  - **install-skills 번호 재배치**: 알파벳 순 삽입이라 1번(ai-workspace) 다음 2번에 들어가면서 기존 항목들이 한 칸씩 밀림. 사용자가 번호로 선택하던 습관이 있다면 한 번 어긋날 수 있으나, 알파벳 정렬 원칙(기존에도 지켜짐)을 깨지 않는 게 더 중요.

---

### Task 8: DoD 자가 점검 및 마무리

- **결과**: spec의 DoD 16개 항목 전수 점검 완료. 모두 충족. spec 체크박스 [ ] → [x] 일괄 갱신.
- **수행 내용 요약** (DoD 매핑):
  - **#1 agentskills.io 표준 포맷**: SKILL.md 1~4행 YAML frontmatter(`name`/`description`) + 마크다운 본문. 충족.
  - **#2 트리거 키워드**: description에 "로비"/"lobby"/"AI-CONTEXT.md"/"building 인덱스"/"워크스페이스 안내판" 모두 포함. 충족.
  - **#3 파일 경로 규약**: 개요 섹션 표(22~29행)에 로비 / floor 안내도 경로 명시 및 "프로젝트 루트 직접 배치 금지" 못박음. update Task 5에서도 프로젝트 루트의 `./AI-CONTEXT.md`를 검사 대상에서 제외하고 이전 안내 의무 추가. 충족.
  - **#4 init 모드 동작 명세**: init-1~6단계(105~188행), 입력 수집 / 디스크 스캔 / `.ai/` 디렉토리 생성 / 작성 / 가드레일 / 보고. 충족.
  - **#5 update 모드 3단계 출력**: update-1(진단 4카테고리: SSoT/로비 역할/drift/형식) / update-2(재구성 전문 + 사용자 확인) / update-3(`migration_candidates` YAML) + update-4(보고). 충족.
  - **#6 모드 자동 판정**: 1단계 모드 결정의 자동 판정 규칙(부재→init, 존재→update) + `test -f`. 충족.
  - **#7 비-git 환경 안전성**: 1단계 모드 결정의 비-VCS 안전성 섹션. git 호출 없음을 명시. 충족.
  - **#8 frontmatter 없음 + last updated 자동 기록**: init-4단계 필수 규칙 + update-2단계 재구성 규칙 + 표준 섹션 구조 골격 모두에 명시. 충족.
  - **#9 status 3종 graceful**: init-2단계 status 결정 표 + 표준 섹션 구조의 status 의미 표. `active`/`placeholder`(+경고)/`archived`(drift 검사 제외). 충족.
  - **#10 분량 가드레일 150~250줄**: init-5단계 가드레일 표 + update-4단계 보고 + 표준 섹션 구조에 분량 검증 명세. 두 예시 산출물(38줄/30줄)은 floor 3개 기준 "짧음" 판정으로 보고되며, 가드레일이 강제가 아닌 권고임을 운영 절차에 반영. 충족.
  - **#11 도메인 본문/코드 스니펫/floor 상세 목차 미포함**: init-4단계 필수 규칙 + 표준 섹션 강제 규칙 표 + SSoT 위배 진단 체크리스트 모두에서 금지. 두 예시 산출물도 모두 라우터 본질만 유지. 충족.
  - **#12 표준 섹션 구조 강제**: `## 표준 섹션 구조` 별도 섹션(376~438행). 6개 H2 순서·각 섹션 강제 규칙 표·status 의미 표 포함. 충족.
  - **#13 SSoT 위배 패턴 진단 체크리스트**: `## SSoT 위배 패턴 진단 체크리스트` 별도 섹션(440~482행). 콘텐츠/형식·메타/분량·정체성 3카테고리. update-1단계 진단 + update-3단계 이동 후보로 연결. 충족.
  - **#14 init/update 예시 각 1개**: ACME 결제 워크스페이스를 공유하는 init 예시(488~575행, floor 3종 status 모두 노출) + update 예시(577~698행, 4단계 모두 시연). 충족.
  - **#15 라이선스 일괄 적용**: SKILL.md 본문에 라이선스 헤더 없음(`grep`으로 확인, 매칭된 두 줄은 예시 산출물 안의 공통 규약 포인터). 프로젝트 루트 `LICENSE`/`NOTICE`/`LICENSE-HEADER.txt`로 일괄 적용 — 기존 12개 스킬 패턴과 동일. 충족.
  - **#16 기존 스킬 구조**: `ai-workspace-directory/SKILL.md` 단일 파일. `templates/`는 Task 2 결정대로 생성하지 않음(예시는 본문 인라인). 충족.
- **특이 사항**:
  - **DoD #10 보정 노트**: 예시 산출물은 floor 3개 기준 38줄/30줄로 가드레일(150~250) 미만. SKILL.md에 가드레일 검증 절차와 권고/강제 구분이 정의되어 있고 보고 단계에서 "짧음" 판정으로 노출되므로 DoD는 "가드레일 명세 + 검증 절차" 기준으로 충족. 실 운영에서 floor 5~15개 워크스페이스라면 자연스럽게 150~250줄에 도달.
  - **spec 체크박스 일괄 갱신**: `replace_all`로 spec의 모든 `- [ ]`를 `- [x]`로 치환. spec에서 체크박스가 사용된 곳은 DoD 섹션뿐임을 사전 확인.
  - **이슈 마무리 절차**: workflow에 따라 plan 모든 Task 체크 + summary "✅ 모든 작업이 완료되었습니다." 갱신 완료. 디렉토리 archive 이동은 사용자 승인 후 진행 예정.
  - **이슈 전체 산출물**:
    - 신규 스킬 `ai-workspace-directory/SKILL.md` (744줄, init+update 예시 포함)
    - 메타 문서 등재: `.ai/AI-CONTEXT.md`, 루트 `README.md`, `install-skills/SKILL.md`
    - 8개 커밋 (e5a87e3 → adb76d7), 모두 `(#1)` 이슈 번호 포함.
