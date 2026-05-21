# Issue #0001 스펙 building 로비 AI-CONTEXT.md를 SSoT 원칙에 맞게 생성하는 스킬 추가

> 원본 이슈: https://github.com/scroogy-dev/scroogy-agent-skills/issues/1

## 목표 (Goal)

building/floor 메타포 기반 knowledge architecture에서 멀티 repo 워크스페이스의 로비 `AI-CONTEXT.md`를 SSoT 원칙과 lean 라우터 원칙에 맞춰 생성·개선해주는 스킬을 추가한다.

---

## 전제 (Premises)

- **실행 위치**: 스킬은 여러 repo가 자식 디렉토리로 모여 있는 **워크스페이스 루트**에서 실행된다.
- **파일 경로 규약** (`ai-workspace` 스킬과 동일, **루트가 아니라 `.ai/` 하위**):
  - **로비 산출물**: `<워크스페이스 루트>/.ai/AI-CONTEXT.md`
  - **floor 안내도**: `<워크스페이스 루트>/<repo>/.ai/AI-CONTEXT.md`
  - 즉 모든 `AI-CONTEXT.md`는 각자의 `.ai/` 디렉토리 안에 있다. 프로젝트 루트에 직접 두지 않는다.
- **하위 repo의 표준**: 각 자식 디렉토리는 일반적으로 `ai-workspace` 스킬로 만들어진 `.ai/` 구조와 `.ai/AI-CONTEXT.md`를 가진다. 단, **없을 수도 있다**.
- **floor 안내도 = floor의 `.ai/AI-CONTEXT.md`**: 하위 repo의 `.ai/AI-CONTEXT.md`가 그 floor의 안내도 역할을 한다. 로비는 floor 안내도를 가리키는 메타 라우터일 뿐 floor 콘텐츠를 복제하지 않는다.
- **워크스페이스 루트는 VCS 대상이 아님**: 로비 산출물은 **로컬 워크스페이스 메모/개인 환경 파일**로 다뤄진다. git 명령에 의존하지 않으며, `last_updated`는 스킬 실행 시점으로 자동 기록한다.
- **도구 비종속**: 산출물은 `.ai/AI-CONTEXT.md` 한 파일이며, Claude Code 등 특정 도구에 종속된 파일(`CLAUDE.md` 등)은 스킬이 생성하지 않는다. 필요 시 사용자가 수작업으로 만든다 (`ai-workspace` 스킬과 동일한 정책).

---

## 범위 (Scope)

**포함 (In)**

- 두 가지 모드 지원 (`ai-workspace` 스킬의 `init` / `update` 네이밍을 따른다)
  - `init`: building 이름과 floor 목록만 받아 표준 구조의 로비 `.ai/AI-CONTEXT.md` 생성 (`.ai/` 디렉토리가 없으면 함께 생성)
  - `update`: 기존 로비 `.ai/AI-CONTEXT.md`를 진단·재구성하고 floor로 이동되어야 할 콘텐츠 목록 산출
- 워크스페이스 루트가 git repo가 아닌 환경에서의 안전 동작 (git 명령 의존 금지)
- floor 디렉토리에 `.ai/AI-CONTEXT.md`가 없는 경우의 graceful degradation (placeholder + 명시적 경고)
- 표준 섹션 구조 강제 (YAML frontmatter 없음)
  - 본문 첫 줄: `> last updated: YYYY-MM-DD` (스킬 실행 시점)
  - 정체성 (2~3문장)
  - Floors 디렉터리 (`path`, `domain`, `keywords`, `status`)
    - `status` 허용 값: `active` (`.ai/AI-CONTEXT.md` 존재, 정상) / `placeholder` (repo 디렉토리는 있으나 안내도 없음, 경고 동반) / `archived` (더 이상 작업하지 않음, 참조만 가능)
  - 라우팅 규칙
  - 공통 규약 (포인터만)
  - Why 진입점 (ADR, 규제 결정 이력)
  - 에이전트 운영 지침
- 분량 가드레일 (150~250줄, `AI-CONTEXT.md` 기준)
- SSoT 위배 패턴 진단 체크리스트
- `description` 트리거 키워드: "로비", "lobby", "AI-CONTEXT.md", "building 인덱스"
- 모드 미지정 시 워크스페이스 루트의 `.ai/AI-CONTEXT.md` 존재 여부로 자동 판정 (없으면 `init`, 있으면 `update`)
- 최소 2개의 예시 (init 1개, update 1개)

**비포함 (Out)**

- floor `.ai/AI-CONTEXT.md` 생성 (`ai-workspace` 스킬이 이미 담당)
- 도구 종속 파일(`CLAUDE.md` 등) 생성 — 사용자가 필요 시 수작업
- 자동 `source_hash` 계산 (별도 도구로 분리)
- 다국어 지원 (1차는 한국어 기준)
- 위키 / Confluence 동기화
- 워크스페이스 루트의 VCS 도입·동기화 자동화
- 하위 repo `.ai/AI-CONTEXT.md`의 자동 파싱·추출 (1차는 사용자 입력 기반, 후속 스킬 연계 시 도입)
- Claude Code 플러그인 래퍼 (추후 별도 이슈)

---

## 대전제 (절대 위배 금지)

- 소스 코드가 무조건 SSoT다.
- markdown은 코드를 가리키는 지도이지 코드의 사본이 아니다.
- 로비는 라우터지 콘텐츠가 아니다. 도메인 지식 본문은 로비에 들어가지 않는다.
- 로비 정보와 floor 정보 충돌 시 floor 우선, floor 정보와 소스 코드 충돌 시 소스 코드 우선.

---

## 완료의 정의 (Definition of Done)

- [x] SKILL.md 파일이 agentskills.io 표준 포맷(YAML frontmatter + 본문)으로 작성됨
- [x] `description` 필드에 트리거 키워드("로비", "lobby", "AI-CONTEXT.md", "building 인덱스") 포함
- [x] 파일 경로 규약 준수: 로비 산출물은 `<워크스페이스 루트>/.ai/AI-CONTEXT.md`, floor 안내도는 `<워크스페이스 루트>/<repo>/.ai/AI-CONTEXT.md` (프로젝트 루트 직접 배치 금지)
- [x] `init` 모드 동작 명세: building 이름과 floor 목록만 받아 표준 구조의 로비 `.ai/AI-CONTEXT.md` 생성 (`.ai/` 부재 시 함께 생성)
- [x] `update` 모드 동작 명세: 기존 로비 `.ai/AI-CONTEXT.md`를 입력받아 다음 3단계 출력
  - 1단계: SSoT / 로비 역할 위배 진단 (+ 디스크 floor 상태와의 drift 진단)
  - 2단계: 재구성된 로비 `.ai/AI-CONTEXT.md` 전문
  - 3단계: 각 floor로 이동되어야 할 콘텐츠 목록 (대상 floor 추정 포함, 후속 스킬이 받기 좋은 구조)
- [x] 모드 미지정 시 워크스페이스 루트의 `.ai/AI-CONTEXT.md` 존재 여부로 자동 판정 (없으면 `init`, 있으면 `update`)
- [x] 워크스페이스 루트가 git repo가 아닌 경우에도 안전하게 동작 (git 명령 호출 없음)
- [x] YAML frontmatter 없음. 본문 첫 줄에 `> last updated: YYYY-MM-DD` (스킬 실행 시점)을 자동 기록
- [x] floor에 `.ai/AI-CONTEXT.md`가 없는 경우 `status: placeholder` + 명시적 경고로 graceful 처리, 존재 시 `status: active`, 사용자가 명시적으로 보존 처리한 floor는 `status: archived`
- [x] `.ai/AI-CONTEXT.md` 산출물이 150~250줄 가드레일 안에 들어옴
- [x] 결과물에 도메인 지식 본문, 코드 스니펫, floor 상세 목차가 포함되지 않음
- [x] 표준 섹션 구조(last updated 첫 줄, 정체성, Floors 디렉터리, 라우팅 규칙, 공통 규약, Why 진입점, 에이전트 운영 지침) 강제
- [x] SSoT 위배 패턴 진단 체크리스트 포함
- [x] init / update 모드 예시 각 1개 이상 포함
- [x] 라이선스: 프로젝트 루트의 `LICENSE`/`NOTICE`/`LICENSE-HEADER.txt`로 일괄 적용 (SKILL.md 본문에 별도 헤더를 넣지 않는 기존 12개 스킬과 동일 패턴)
- [x] 기존 스킬 구조와 일치하는 디렉토리 (`<skill-name>/SKILL.md`, 필요 시 `templates/`)

---

## 연관 문서

> `.ai/30_contract/index.md`, `.ai/40_domain/index.md`, `.ai/50_adr/index.md`를 확인했으나 본 이슈와 직접 연결되는 등재 문서는 없음. 새 정책·결정이 도출되면 해당 위치에 추가한다.

| 문서 | 역할 |
|------|------|
| `AI-CONTEXT.md` (스킬 작성 규칙 절) | SKILL.md 포맷, 명명 규칙, 스킬 독립성 원칙 |
| `ai-workspace/SKILL.md` | floor 측 `.ai/AI-CONTEXT.md` 생성 패턴, `.ai/` 디렉토리 배치, `init`/`update` 모드 분기 참고 |
| 기존 스킬 (`context-harvest/` 등) | 디렉토리 구조 및 `templates/` 배치 참고 |

---

## 후속 이슈 후보

- floor `.ai/AI-CONTEXT.md` 갱신 스킬 연계 (`update` 모드의 "floor 이동 목록"을 받아 처리)
- `source_hash` 자동 계산 도구
- 워크스페이스에 VCS가 도입될 경우 로비-floor 동기화 검증 CI
