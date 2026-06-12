---
name: ai-workspace-directory
description: 멀티 repo 워크스페이스 루트의 로비 `.ai/AI-CONTEXT.md`를 생성하거나 진단·재구성합니다. `ai-workspace`의 자매 스킬로, building 안내판(=lobby) 역할의 lean 라우터를 만듭니다. 로비, lobby, AI-CONTEXT.md, building 인덱스, 워크스페이스 안내판 작업 시 사용합니다.
---

## 개요

멀티 repo가 한 워크스페이스 아래 모여있는 환경에서, 워크스페이스 루트의 **로비 `.ai/AI-CONTEXT.md`** 를 생성하거나 진단·재구성하는 스킬입니다.

`ai-workspace`(floor 측, 각 repo의 `.ai/` 전체 구조 담당)의 자매 스킬이며, 빌딩의 **안내판(directory)** 역할을 합니다. 로비는 floor 안내도를 가리키는 **메타 라우터**일 뿐 도메인 콘텐츠를 보유하지 않습니다.

### 산출물의 본질

- 포함: 라우팅·색인 (어디로 가야 할지 알려주는 안내판)
- 금지: 도메인 지식 본문, 코드 스니펫, floor 상세 목차 — 이건 floor의 책임

### 파일 경로 규약

| 대상 | 경로 | 담당 스킬 |
|------|------|-----------|
| 로비 (building 안내판) | `<워크스페이스 루트>/.ai/AI-CONTEXT.md` | **이 스킬** |
| floor 안내도 (층별 안내도) | `<워크스페이스 루트>/<repo>/.ai/AI-CONTEXT.md` | `ai-workspace` |

**규약**: 모든 `AI-CONTEXT.md`는 각자의 `.ai/` 디렉토리 **안에** 있습니다. 프로젝트 루트에 직접 배치하지 않습니다.

### 대전제 (절대 위배 금지)

- 소스 코드가 무조건 SSoT다.
- markdown은 코드를 가리키는 지도이지 코드의 사본이 아니다.
- 로비는 라우터지 콘텐츠가 아니다. 도메인 지식 본문은 로비에 들어가지 않는다.
- 정보 충돌 시 우선순위: **소스 코드 > 각 repo 안내도 > 이 안내도(상위 워크스페이스)**.
- **설계 원칙: 컨벤션 우선 (CoC).** 멀티 repo는 `<상위 워크스페이스>/<repo>` 컨벤션으로만 지원한다. 각 repo가 어느 상위 워크스페이스에 속하는지는 `<repo>/../.ai/AI-CONTEXT.md` 존재로 자동 판정하며, repo 측 안내도에 역참조 메타 필드(`building`/`lobby` 등)를 두지 않는다 (YAGNI). 컨벤션을 벗어난 구조는 지원하지 않는다.

## 관련 skill

- **`ai-workspace`** (자매): 각 floor의 `.ai/` 전체 구조와 floor 안내도 `<repo>/.ai/AI-CONTEXT.md`를 생성·갱신합니다. 이 스킬은 그 위에서 building 안내판 역할을 하는 로비를 다룹니다.
- **양방향 도메인 동기화**: `ai-workspace-directory`는 로비의 `Repos` 표에 각 repo의 `path`/`domain`/`keywords`/`status`를 적고, `ai-workspace`는 각 repo의 안내도 `## 프로젝트 도메인` 표에 동일한 `domain`/`keywords`를 적습니다. **두 값은 1:1 동기화 대상**입니다 (`update` 모드의 drift 메타 일치 검사가 이를 점검). 역참조(repo → 상위 워크스페이스)는 별도 메타 필드 없이 CoC(`<repo>/../.ai/AI-CONTEXT.md` 존재 자동 판정)로 처리합니다.

## 참조 문서

- **공통 규칙**: `.ai/10_rules/context-loading.md` — 있으면 따르며, 이미 적재되어 있으면 재로딩하지 않습니다.
- **스킬 고유 추가 참조**:
  - 현재 워크스페이스 루트의 기존 `.ai/AI-CONTEXT.md` (있을 경우 — `update` 모드 입력)
  - 각 floor의 `<repo>/.ai/AI-CONTEXT.md` (디스크 스캔으로 존재 여부만 확인 — `status` 판정용)
- **분리 참조 파일** (`references/` — 해당 단계에 도달했을 때만 읽습니다):
  - [standard-structure.md](references/standard-structure.md) — 산출물 표준 섹션 구조 (필수 규칙·골격·섹션별 강제 규칙·repo `status` 의미). **산출물 형식의 단일 출처** — init-4단계, update-2단계에서 사용
  - [ssot-checklist.md](references/ssot-checklist.md) — SSoT 위배 패턴 진단 체크리스트 — update-1단계에서 사용
  - [examples.md](references/examples.md) — update 모드 출력 형식 템플릿 + init/update 완성 예시

## 사용법

```
/ai-workspace-directory [init|update]
```

- `init`: 새 로비 `.ai/AI-CONTEXT.md`를 작성합니다.
- `update`: 기존 로비를 진단·재구성하고 floor 이동 목록을 산출합니다.
- 모드를 생략하면 워크스페이스 루트의 `.ai/AI-CONTEXT.md` 존재 여부로 자동 판정합니다 (없으면 `init`, 있으면 `update`).

워크스페이스 루트가 git 저장소가 아니어도 동작합니다 (git 명령에 의존하지 않음).

## 실행 절차

### 1단계: 모드 결정

사용자가 모드를 명시했으면 그대로 진행합니다. 미지정 시 워크스페이스 루트의 `.ai/AI-CONTEXT.md` 존재 여부로 자동 분기합니다.

#### 자동 판정 규칙

| `<루트>/.ai/AI-CONTEXT.md` | 자동 선택 모드 |
|---------------------------|----------------|
| 부재 | `init` |
| 존재 | `update` |

판정 대상 경로는 **워크스페이스 루트의 `.ai/` 안**입니다. 프로젝트 루트의 `./AI-CONTEXT.md`는 검사 대상이 아닙니다 (파일 경로 규약 위반이므로 발견 시 사용자에게 이전을 안내).

#### 사용자 확인 절차 (덮어쓰기 위험 회피)

자동 판정 결과를 사용자에게 명시하고 확인을 받습니다. 확인 없이는 다음 단계로 진행하지 않습니다.

- **`init` 자동 선택 시**: *"`<루트>/.ai/AI-CONTEXT.md`가 없습니다. `init` 모드로 새 로비를 작성할까요?"*
- **`update` 자동 선택 시**: *"기존 `<루트>/.ai/AI-CONTEXT.md` (N줄, last updated: YYYY-MM-DD)를 `update` 모드로 진단·재구성할까요?"*

사용자가 자동 선택과 다른 모드를 원할 경우:

| 자동 선택 | 사용자 요청 | 처리 |
|----------|------------|------|
| `init` | `update` | 기존 파일이 다른 경로(예: 프로젝트 루트, 다른 워크스페이스)에 있을 가능성을 안내하고 경로 재확인 요청 |
| `update` | `init` | **기존 파일을 덮어쓰게 됨을 명시**하고 한 번 더 확인 요청. 백업이 필요하면 사용자에게 수동 백업을 안내한 후 진행 |

#### 비-VCS 환경 안전성

워크스페이스 루트는 일반적으로 VCS 대상이 아닌 로컬 환경 파일입니다. 이 스킬은 다음 원칙을 따릅니다.

- **git 명령에 의존하지 않습니다.** `git log`, `git status`, `git rev-parse` 등 어떤 git 호출도 하지 않으며, 워크스페이스 루트가 git 저장소가 아니어도 동일하게 동작합니다.
- 모드 자동 판정은 **파일 존재 여부**만으로 결정합니다 (`test -f`).
- 본문 첫 줄 `> last updated: YYYY-MM-DD`는 **스킬 실행 시점의 시스템 날짜**(`date +%Y-%m-%d`)로 자동 기록합니다. git 커밋 시각·작성자 정보는 사용하지 않습니다.
- `update` 모드에서도 재구성 본문을 작성할 때 `last updated`를 매번 시스템 날짜로 **갱신**합니다.

---

### init 모드

새 로비 `.ai/AI-CONTEXT.md`를 작성합니다.

#### init-1단계: 입력 수집

다음 정보를 사용자에게 받습니다. (입력 예시는 [examples.md](references/examples.md)의 init 모드 예시 참조)

| 항목 | 필수/선택 | 설명 |
|------|----------|------|
| building 이름 | 필수 | 워크스페이스/조직 이름 (예: "ACME 워크스페이스") |
| building 정체성 (2~3문장) | 필수 | 이 building이 무엇을 위한 곳인지 |
| floor 목록 | 필수 | 각 floor의 `path`(상대 경로), `domain`(맡은 영역), `keywords`(라우팅 키워드) |
| archived floor 목록 | 선택 | 사용자가 명시적으로 "더 이상 작업하지 않음"으로 표시할 floor의 `path` |

`floor 목록`은 사용자가 한 번에 모두 제공하지 않을 수 있습니다. 누락 시 항목별로 대화형 질의로 수집합니다.

#### init-2단계: 디스크 스캔 — floor `status` 결정

입력된 각 floor에 대해 다음 규칙으로 `status`를 결정합니다.

| 조건 | `status` |
|------|---------|
| 사용자가 `archived`로 명시 | `archived` |
| `<루트>/<path>/.ai/AI-CONTEXT.md` 존재 | `active` |
| `<루트>/<path>/.ai/AI-CONTEXT.md` 부재 | `placeholder` |

`placeholder`로 판정된 floor에 대해 결과 보고 시 **명시적 경고**를 함께 출력합니다.

> [경고] floor `<path>`에 안내도가 없습니다. 해당 floor에서 `ai-workspace` 스킬을 실행해 안내도를 생성하는 것을 권장합니다.

`archived` floor는 디스크 존재 여부와 무관하게 `archived`로 고정되며, 향후 `update` 모드의 drift 검사 대상에서도 제외됩니다.

#### init-3단계: `.ai/` 디렉토리 준비

`<루트>/.ai/` 디렉토리가 없으면 생성합니다. git 명령에 의존하지 않습니다.

#### init-4단계: `.ai/AI-CONTEXT.md` 작성

[standard-structure.md](references/standard-structure.md)를 읽고, 그 필수 규칙과 골격에 따라 `<루트>/.ai/AI-CONTEXT.md`를 작성합니다. 산출물 형식 규칙은 해당 문서가 단일 출처입니다.

#### init-5단계: 분량 가드레일 검증

생성된 파일의 줄 수를 측정해 가드레일을 검증합니다.

| 범위 | 판정 | 조치 |
|------|------|------|
| 150~250줄 | 정상 | — |
| 250줄 초과 | 비대 | 어떤 섹션이 큰지 분석해 사용자에게 보고. 도메인 본문 또는 floor 상세 목차가 섞여 있는지 점검 |
| 150줄 미만 | 짧음 | floor 수가 적은 경우 정상. 정체성·라우팅·운영 지침이 빈약하면 보강 권장 |

분량 검증은 권고이며 실패 시에도 파일 생성은 진행합니다. 다만 250줄 초과는 SSoT 위배 가능성이 높으므로 사용자에게 명시적 확인을 요청합니다.

#### init-6단계: 보고

다음 정보를 사용자에게 출력합니다.

- 생성된 파일 경로 (`<루트>/.ai/AI-CONTEXT.md`)
- `status`별 floor 수 (`active` X개 / `placeholder` Y개 / `archived` Z개)
- `placeholder` floor 목록과 경고 메시지
- 분량 가드레일 결과

---

### update 모드

기존 로비 `.ai/AI-CONTEXT.md`를 입력으로 받아 **진단 → 재구성 → 이동 목록** 3단계를 순서대로 출력합니다.

이 모드는 **파일을 덮어쓰기 전 사용자 확인을 반드시 받습니다**. 진단·이동 목록만 출력하고 실제 갱신은 사용자 승인 후에만 수행합니다.

#### update-0단계: 입력 수집 (사전)

- 기존 `<루트>/.ai/AI-CONTEXT.md`를 읽습니다. 파일이 없으면 사용자에게 `init` 모드로 전환할지 확인합니다.
- 디스크 스캔: 워크스페이스 루트의 모든 1차 자식 디렉토리에 대해 `<루트>/<dir>/.ai/AI-CONTEXT.md` 존재 여부를 수집합니다.
- 기존 로비 `Repos` 표(구버전은 `Floors`)에서 `archived`로 표시된 repo 목록을 추출합니다 (drift 검사 제외 대상).

#### update-1단계: 진단 리포트 출력

다음 4개 카테고리를 순서대로 점검하고 마크다운 리포트로 출력합니다. 리포트 형식은 [examples.md](references/examples.md)의 update-1단계 출력 형식 템플릿을 따릅니다.

##### (1) SSoT 위배 패턴 진단

[ssot-checklist.md](references/ssot-checklist.md)의 각 항목을 점검합니다. 위배가 있으면 발견 위치(섹션·라인 범위)와 발췌를 기록합니다.

##### (2) 로비 역할 위배 진단

로비는 라우터일 뿐이므로 다음을 점검합니다.

| 패턴 | 설명 |
|------|------|
| 도메인 본문 | 결제·인증 등 특정 도메인의 본문 설명이 로비에 포함됨 |
| 코드 스니펫 | 함수·클래스·설정 등 코드 조각이 로비에 포함됨 |
| floor 상세 목차 | 특정 floor의 파일 트리·디렉토리 구조가 로비에 펼쳐져 있음 |
| 정책 본문 중복 | floor의 `.ai/10_rules/`·`40_domain/policies/`에 있어야 할 정책 본문이 로비에 중복됨 |
| 비대 | 산출물이 250줄을 초과 |

##### (3) drift 진단 (로비 ↔ 디스크)

다음 두 방향으로 차이를 점검합니다. `archived` repo는 양방향 모두 검사에서 제외합니다.

| 방향 | 판정 | 조치 |
|------|------|------|
| 로비에 있음 + 디스크에 안내도 있음 | 정상 | `active` 유지 |
| 로비에 있음 + 디스크에 안내도 없음 | drift | `placeholder`로 전환 + 안내도 생성 권장 |
| 로비에 없음 + 디스크에 안내도 있음 | drift | 로비 `Repos`에 등록 필요 |
| 로비에 있음 + 디스크 디렉토리 자체 없음 | drift | 사용자에게 repo 삭제/이전/archive 여부 확인 |

##### (3-보강) 메타 일치 검사 (조건부)

각 repo 안내도(`<repo>/.ai/AI-CONTEXT.md`)의 `## 프로젝트 도메인` 메타 블록이 존재할 때만 동작합니다 (`ai-workspace` 보강 결과로 자기 선언 메타가 들어있는 경우). 메타 블록이 없으면 검사를 스킵합니다.

| 검사 항목 | 위배 판정 | 조치 |
|----------|-----------|------|
| 로비 `Repos.<path>` 행의 `domain` 과 repo 자기 선언 `domain` 일치 | 다르면 drift | update-3단계 `meta-mismatch` 카테고리로 정렬 권고 (어느 쪽이 SSoT에 가까운지 사용자 확인 — 통상 repo 자기 선언이 더 가깝다고 권고) |
| 로비 `Repos.<path>` 행의 `keywords` ⊇ repo 자기 선언 `keywords` 핵심 셋 | 빠진 키워드가 있으면 drift | 로비 keywords에 누락 키워드 추가 권고 |

**스킵 fallback**: repo 측 메타 블록이 없으면 다음 안내만 출력합니다 — *"해당 repo 안내도(`<path>/.ai/AI-CONTEXT.md`)에 `## 프로젝트 도메인` 메타 블록이 없습니다. `ai-workspace update`로 보강을 권장합니다."*

> 역참조(repo → 상위 워크스페이스) 일치 검사는 CoC 도입으로 **수행하지 않습니다** — 메타 필드 자체가 없으므로 검사 대상이 아닙니다 (`../.ai/AI-CONTEXT.md` 존재로 자동 판정).

##### (4) 형식 위배

형식 기준은 [standard-structure.md](references/standard-structure.md)를 따릅니다.

| 검사 | 위배 시 조치 |
|------|-------------|
| 본문 첫 줄이 `> last updated: YYYY-MM-DD`인가 | update-2단계에서 자동 갱신 |
| 본문 두 번째 줄이 `> SSoT: 소스 코드. 이 파일은 라우터일 뿐 진실의 원천이 아니다.` 인가 | update-2단계에서 표준 문구로 자동 삽입·교체 (비표준 문구이면 표준 문구로 치환) |
| YAML frontmatter가 없는가 | 있다면 update-2단계에서 제거 |
| 표준 6개 H2 섹션이 모두 있고 순서가 맞는가 | update-2단계에서 보강·재정렬 |
| `Repos` 섹션명을 사용하는가 (구버전 `Floors` 아님) | 구버전 `Floors` → `Repos`로 섹션명 정규화 |
| `Repos` 테이블이 정확히 4열(`path`/`domain`/`keywords`/`status`)인가 | update-2단계에서 정규화 |
| `에이전트 운영 지침`에 `### 진입 절차` 4단계가 있는가 | update-2단계에서 표준 진입 절차 4단계 삽입. 사용자가 커스텀 단계를 추가했다면 보존하되 표준 4단계 누락 시 보충 |
| `status` 값이 `active`/`placeholder`/`archived` 중 하나인가 | 다른 값은 사용자 확인 후 정규화 |

#### update-2단계: 재구성된 로비 `.ai/AI-CONTEXT.md` 전문 출력

[standard-structure.md](references/standard-structure.md)의 표준 섹션 구조를 따라 재구성된 전문을 코드 블록으로 출력합니다. 출력 형식은 [examples.md](references/examples.md)의 update-2단계 출력 형식 템플릿을 따릅니다.

**재구성 규칙**:
- 본문 첫 줄 `> last updated:`를 스킬 실행 시점의 시스템 날짜로 갱신합니다.
- 본문 두 번째 줄 SSoT 선언(`> SSoT: 소스 코드. 이 파일은 라우터일 뿐 진실의 원천이 아니다.`)이 없으면 표준 문구로 삽입합니다. 비표준 문구이면 표준 문구로 교체합니다.
- YAML frontmatter가 있으면 제거합니다.
- 6개 H2 섹션을 표준 순서로 정렬합니다. 누락 섹션은 빈 본문 + 안내 주석으로 생성합니다.
- 구버전 `## Floors` 섹션명이 있으면 `## Repos`로 정규화합니다.
- `Repos` 테이블을 4열로 정규화하고 drift 진단 결과에 따라 `status`를 갱신합니다.
- `에이전트 운영 지침` 섹션이 비어 있거나 `### 진입 절차` 4단계가 없으면 표준 골격(번호 4단계 + `### 작성 규칙` 글머리)을 삽입합니다. 사용자가 추가한 운영 지침 항목은 `### 작성 규칙` 아래 또는 별도 서브헤딩으로 **보존**합니다 (소실 금지).
- 진단에서 발견된 도메인 본문·코드 스니펫·repo 상세 목차·정책 본문 중복은 **본문에서 제거**하고 update-3단계 이동 목록으로 옮깁니다.
- 사용자가 작성한 라우팅 규칙·정체성 문구는 본문 형태로 살리되, SSoT 위배 패턴은 제거합니다.

**파일 쓰기 규칙**:
- 출력 후 사용자에게 명시적으로 확인을 요청합니다: *"이대로 `<루트>/.ai/AI-CONTEXT.md`에 덮어쓸까요?"*
- 사용자가 승인하면 파일에 기록하고, 분량 가드레일(150~250줄)을 init 모드와 동일하게 검증합니다.
- 사용자가 거절하면 파일을 변경하지 않고 진단 리포트와 재구성 전문만 출력 상태로 남깁니다.

#### update-3단계: floor 이동 후보 목록 출력

진단에서 발견된 "로비에 있어서는 안 되는" 콘텐츠를 후속 스킬이 입력으로 받기 좋은 **YAML 구조**로 출력합니다. 출력 YAML 형식은 [examples.md](references/examples.md)의 update-3단계 출력 형식 템플릿을 따릅니다.

**필수 필드**:

| 필드 | 설명 |
|------|------|
| `content_id` | 항목 고유 식별자 (예: `lobby-overflow-001`) |
| `target_floor` | 대상 repo의 `path` (로비 `Repos` 표의 `path`와 일치) |
| `target_location_hint` | 대상 floor 내부의 추정 경로 (예: `<repo>/.ai/40_domain/specs/payment-domain.md`). 사용자/후속 스킬이 최종 결정하므로 어디까지나 힌트 |
| `category` | `domain-content` / `code-snippet` / `repo-toc` / `policy-duplicate` / `meta-mismatch` / `other` |
| `confidence` | `high` / `medium` / `low` — `target_floor` 추정의 자신도 |
| `reason` | 왜 이동 대상인지 한 줄 근거 |
| `source_location` | 원본 로비에서의 위치 (예: `lines 45-78`) |
| `excerpt` | 원본 발췌 (전문 또는 요약 — 후속 스킬이 적용할 수 있을 만큼 충분히) |

**`target_floor` 추정 규칙**:
- 발췌의 도메인 키워드를 로비 `Repos` 표의 각 repo `keywords`와 매칭.
- 키워드 다수 일치 → `high`, 단어 부분 일치 → `medium`, 일치 없음 → `low` + `target_floor: unknown`.
- `archived` floor는 추정 대상에서 제외.

이 출력은 화면에 표시만 하고 파일을 직접 수정하지 않습니다. 후속 스킬(또는 사용자 수작업)이 이 YAML을 입력으로 받아 각 floor에 콘텐츠를 배치합니다.

#### update-4단계: 보고

- 1·2·3단계 출력의 위치(또는 사용자에게 제시한 영역)를 정리합니다.
- 파일 변경 여부: 사용자 승인 시 `<루트>/.ai/AI-CONTEXT.md` 갱신됨, 거절 시 변경 없음.
- 분량 가드레일 결과 (`init` 모드와 동일 기준).
- drift로 인해 `placeholder`로 전환된 floor 목록과 안내도 생성 권장 메시지.
- 이동 후보 개수 및 `target_floor: unknown` 항목 수 (사용자 후속 확인 필요).
