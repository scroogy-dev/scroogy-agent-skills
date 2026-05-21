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

### 두 가지 모드

- **`init`**: building 이름과 floor 목록만 받아 표준 구조의 로비 `.ai/AI-CONTEXT.md`를 생성.
- **`update`**: 기존 로비 `.ai/AI-CONTEXT.md`를 진단·재구성하고 floor로 이동되어야 할 콘텐츠 목록을 산출.

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
- 정보 충돌 시 우선순위: **소스 코드 > floor > 로비**.

## 관련 skill

- **`ai-workspace`** (자매): 각 floor의 `.ai/` 전체 구조와 floor 안내도 `<repo>/.ai/AI-CONTEXT.md`를 생성·갱신합니다. 이 스킬은 그 위에서 building 안내판 역할을 하는 로비를 다룹니다.

## 참조 문서

- **공통 규칙**: `.ai/10_rules/context-loading.md` — 있으면 따르며, 이미 적재되어 있으면 재로딩하지 않습니다.
- **스킬 고유 추가 참조**:
  - 현재 워크스페이스 루트의 기존 `.ai/AI-CONTEXT.md` (있을 경우 — `update` 모드 입력)
  - 각 floor의 `<repo>/.ai/AI-CONTEXT.md` (디스크 스캔으로 존재 여부만 확인 — `status` 판정용)

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

```bash
[ -f .ai/AI-CONTEXT.md ] && echo "update" || echo "init"
```

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

다음 정보를 사용자에게 받습니다.

| 항목 | 필수/선택 | 설명 |
|------|----------|------|
| building 이름 | 필수 | 워크스페이스/조직 이름 (예: "ACME 워크스페이스") |
| building 정체성 (2~3문장) | 필수 | 이 building이 무엇을 위한 곳인지 |
| floor 목록 | 필수 | 각 floor의 `path`(상대 경로), `domain`(맡은 영역), `keywords`(라우팅 키워드) |
| archived floor 목록 | 선택 | 사용자가 명시적으로 "더 이상 작업하지 않음"으로 표시할 floor의 `path` |

floor 입력 예시:

```yaml
- path: api-server
  domain: 결제 API 서버
  keywords: [결제, payment, API, 트랜잭션]
- path: docs
  domain: 사용자 문서·튜토리얼
  keywords: [문서, docs, 튜토리얼, 사용자 가이드]
```

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

```bash
[ ! -d .ai ] && mkdir -p .ai
```

#### init-4단계: `.ai/AI-CONTEXT.md` 작성

[표준 섹션 구조](#표준-섹션-구조)를 따라 `<루트>/.ai/AI-CONTEXT.md`를 작성합니다.

**필수 규칙**:
- YAML frontmatter는 **사용하지 않습니다**.
- 본문 **첫 줄**은 반드시 `> last updated: YYYY-MM-DD` (스킬 실행 시점의 시스템 날짜, ISO 형식).
- 표준 섹션 6개(`정체성`, `Floors`, `라우팅 규칙`, `공통 규약`, `Why 진입점`, `에이전트 운영 지침`)를 **모두** 포함하며 **순서를 지킵니다**.
- 도메인 지식 본문, 코드 스니펫, floor 상세 목차를 **절대 포함하지 않습니다**.

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
- 기존 로비 Floors 테이블에서 `archived`로 표시된 floor 목록을 추출합니다 (drift 검사 제외 대상).

#### update-1단계: 진단 리포트 출력

다음 4개 카테고리를 순서대로 점검하고 마크다운 리포트로 출력합니다.

##### (1) SSoT 위배 패턴 진단

[SSoT 위배 패턴 진단 체크리스트](#ssot-위배-패턴-진단-체크리스트)의 각 항목을 점검합니다. 위배가 있으면 발견 위치(섹션·라인 범위)와 발췌를 기록합니다.

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

다음 두 방향으로 차이를 점검합니다. `archived` floor는 양방향 모두 검사에서 제외합니다.

| 방향 | 판정 | 조치 |
|------|------|------|
| 로비에 있음 + 디스크에 안내도 있음 | 정상 | `active` 유지 |
| 로비에 있음 + 디스크에 안내도 없음 | drift | `placeholder`로 전환 + 안내도 생성 권장 |
| 로비에 없음 + 디스크에 안내도 있음 | drift | 로비 Floors에 등록 필요 |
| 로비에 있음 + 디스크 디렉토리 자체 없음 | drift | 사용자에게 floor 삭제/이전/archive 여부 확인 |

##### (4) 형식 위배

| 검사 | 위배 시 조치 |
|------|-------------|
| 본문 첫 줄이 `> last updated: YYYY-MM-DD`인가 | update-2단계에서 자동 갱신 |
| YAML frontmatter가 없는가 | 있다면 update-2단계에서 제거 |
| 표준 6개 H2 섹션이 모두 있고 순서가 맞는가 | update-2단계에서 보강·재정렬 |
| Floors 테이블이 정확히 4열(`path`/`domain`/`keywords`/`status`)인가 | update-2단계에서 정규화 |
| `status` 값이 `active`/`placeholder`/`archived` 중 하나인가 | 다른 값은 사용자 확인 후 정규화 |

##### 진단 리포트 출력 형식

```markdown
## 진단 리포트 (update-1단계)

### SSoT 위배
- [발견] <위배 패턴>: <발견 위치> — <발췌 또는 요약>
- [없음] <검사 항목> — 깨끗함

### 로비 역할 위배
- [발견] 도메인 본문: 라인 45-78 ("결제 트랜잭션 상태는...") — floor `api-server`로 이동 후보
- [없음] 코드 스니펫

### drift 진단
| floor | 로비 status | 디스크 안내도 | 디스크 디렉토리 | 판정 |
|-------|------------|--------------|----------------|------|
| api-server | active | 존재 | 존재 | 정상 |
| mobile-app | active | 없음 | 존재 | drift: placeholder 전환 |
| infra | (없음) | 존재 | 존재 | drift: 등록 필요 |
| legacy-web | archived | (검사 제외) | (검사 제외) | 검사 제외 |

### 형식 위배
- [위배] 본문 첫 줄이 last updated 형식이 아님 → 자동 갱신 예정
- [위배] Floors 테이블에 `owner` 열이 추가됨 → 정규화 예정
```

#### update-2단계: 재구성된 로비 `.ai/AI-CONTEXT.md` 전문 출력

[표준 섹션 구조](#표준-섹션-구조)를 따라 재구성된 전문을 코드 블록으로 출력합니다.

**재구성 규칙**:
- 본문 첫 줄 `> last updated:`를 스킬 실행 시점의 시스템 날짜로 갱신합니다.
- YAML frontmatter가 있으면 제거합니다.
- 6개 H2 섹션을 표준 순서로 정렬합니다. 누락 섹션은 빈 본문 + 안내 주석으로 생성합니다.
- Floors 테이블을 4열로 정규화하고 drift 진단 결과에 따라 `status`를 갱신합니다.
- 진단에서 발견된 도메인 본문·코드 스니펫·floor 상세 목차·정책 본문 중복은 **본문에서 제거**하고 update-3단계 이동 목록으로 옮깁니다.
- 사용자가 작성한 라우팅 규칙·정체성 문구는 본문 형태로 살리되, SSoT 위배 패턴은 제거합니다.

**출력 형식**:

```markdown
## 재구성된 로비 .ai/AI-CONTEXT.md (update-2단계)

> 아래는 새 본문 전문입니다. 검토 후 승인하시면 파일에 기록합니다.

```markdown
> last updated: YYYY-MM-DD

## 정체성
...

## Floors
...

## 라우팅 규칙
...

## 공통 규약
...

## Why 진입점
...

## 에이전트 운영 지침
...
```
```

**파일 쓰기 규칙**:
- 출력 후 사용자에게 명시적으로 확인을 요청합니다: *"이대로 `<루트>/.ai/AI-CONTEXT.md`에 덮어쓸까요?"*
- 사용자가 승인하면 파일에 기록하고, 분량 가드레일(150~250줄)을 init 모드와 동일하게 검증합니다.
- 사용자가 거절하면 파일을 변경하지 않고 진단 리포트와 재구성 전문만 출력 상태로 남깁니다.

#### update-3단계: floor 이동 후보 목록 출력

진단에서 발견된 "로비에 있어서는 안 되는" 콘텐츠를 후속 스킬이 입력으로 받기 좋은 **YAML 구조**로 출력합니다.

**필수 필드**:

| 필드 | 설명 |
|------|------|
| `content_id` | 항목 고유 식별자 (예: `lobby-overflow-001`) |
| `target_floor` | 대상 floor의 `path` (로비 Floors 테이블의 `path`와 일치) |
| `target_location_hint` | 대상 floor 내부의 추정 경로 (예: `<repo>/.ai/40_domain/specs/payment-domain.md`). 사용자/후속 스킬이 최종 결정하므로 어디까지나 힌트 |
| `category` | `domain-content` / `code-snippet` / `floor-toc` / `policy-duplicate` / `other` |
| `confidence` | `high` / `medium` / `low` — `target_floor` 추정의 자신도 |
| `reason` | 왜 이동 대상인지 한 줄 근거 |
| `source_location` | 원본 로비에서의 위치 (예: `lines 45-78`) |
| `excerpt` | 원본 발췌 (전문 또는 요약 — 후속 스킬이 적용할 수 있을 만큼 충분히) |

**`target_floor` 추정 규칙**:
- 발췌의 도메인 키워드를 로비 Floors 테이블의 각 floor `keywords`와 매칭.
- 키워드 다수 일치 → `high`, 단어 부분 일치 → `medium`, 일치 없음 → `low` + `target_floor: unknown`.
- `archived` floor는 추정 대상에서 제외.

**출력 형식**:

```yaml
# floor 이동 후보 목록 (update-3단계)
migration_candidates:
  - content_id: lobby-overflow-001
    target_floor: api-server
    target_location_hint: api-server/.ai/40_domain/specs/payment-domain.md
    category: domain-content
    confidence: high
    reason: 결제 도메인 본문이 로비에 포함됨. 키워드(결제, payment, 트랜잭션)가 api-server의 keywords와 일치
    source_location: lines 45-78
    excerpt: |
      결제 트랜잭션은 다음 상태를 가진다: PENDING, AUTHORIZED,
      CAPTURED, REFUNDED, FAILED. 각 상태 전이는 ...
  - content_id: lobby-overflow-002
    target_floor: unknown
    target_location_hint: null
    category: other
    confidence: low
    reason: 키워드가 어떤 floor와도 매칭되지 않음. 사용자 확인 필요
    source_location: lines 120-125
    excerpt: |
      ...
```

이 출력은 화면에 표시만 하고 파일을 직접 수정하지 않습니다. 후속 스킬(또는 사용자 수작업)이 이 YAML을 입력으로 받아 각 floor에 콘텐츠를 배치합니다.

#### update-4단계: 보고

- 1·2·3단계 출력의 위치(또는 사용자에게 제시한 영역)를 정리합니다.
- 파일 변경 여부: 사용자 승인 시 `<루트>/.ai/AI-CONTEXT.md` 갱신됨, 거절 시 변경 없음.
- 분량 가드레일 결과 (`init` 모드와 동일 기준).
- drift로 인해 `placeholder`로 전환된 floor 목록과 안내도 생성 권장 메시지.
- 이동 후보 개수 및 `target_floor: unknown` 항목 수 (사용자 후속 확인 필요).

---

## 표준 섹션 구조

산출물 `<루트>/.ai/AI-CONTEXT.md`는 다음 6개 H2 섹션을 **반드시 이 순서대로** 포함합니다. YAML frontmatter는 사용하지 않으며, 본문 첫 줄은 `> last updated: YYYY-MM-DD`입니다.

### 골격

```markdown
> last updated: YYYY-MM-DD

## 정체성

<2~3문장. 이 building이 무엇을 위한 곳인지.>

## Floors

| path | domain | keywords | status |
|------|--------|----------|--------|
| <repo-1> | <영역 한 줄 요약> | <키워드 콤마 나열> | active / placeholder / archived |
| ... |

## 라우팅 규칙

- <키워드/요청 패턴> → `<path>`
- ...

## 공통 규약

- <짧은 포인터 한 줄> — 본문은 `<repo>/.ai/...` 또는 외부 문서로
- ...

## Why 진입점

- <결정 주제> → `<repo>/.ai/50_adr/active/...`
- <정책 주제> → `<repo>/.ai/40_domain/policies/...`
- ...

## 에이전트 운영 지침

- 도메인 콘텐츠는 이 파일에 두지 않는다. floor로 보내라.
- 로비 정보와 floor 정보 충돌 시 **floor 우선**.
- floor 정보와 소스 코드 충돌 시 **소스 코드 우선**.
- `placeholder` floor를 만나면 사용자에게 안내도 생성을 안내한다.
```

### 섹션별 강제 규칙

| 섹션 | 강제 규칙 |
|------|----------|
| `> last updated:` 줄 | 본문 **첫 줄**. ISO 날짜. `init`과 `update` 모두 매 실행 시 시스템 날짜로 갱신 |
| `## 정체성` | 2~3문장. 도메인 본문·기술 스택 상세 금지 |
| `## Floors` | `path` / `domain` / `keywords` / `status` 4열 테이블. 그 외 열 금지 |
| `## 라우팅 규칙` | floor 단위 매핑만. 코드 스니펫·구체 절차 금지 |
| `## 공통 규약` | **포인터만**. 본문은 floor의 `.ai/10_rules/` 또는 외부 문서에 |
| `## Why 진입점` | ADR·정책 결정 포인터만. 본문 금지 |
| `## 에이전트 운영 지침` | 짧은 운영 규칙. SSoT/라우터 정체성을 항상 명시 |

### floor `status` 의미

| `status` | 의미 | `update` 모드의 drift 검사 |
|----------|------|---------------------------|
| `active` | 안내도(`<repo>/.ai/AI-CONTEXT.md`) 존재, 정상 동작 중 | 포함 |
| `placeholder` | repo 디렉토리는 있으나 안내도 없음 | 포함 (생성 권장 경고) |
| `archived` | 더 이상 작업하지 않음, 참조만 가능 | **제외** |

## SSoT 위배 패턴 진단 체크리스트

`update` 모드의 진단 1단계에서 사용하는 체크리스트입니다. 각 항목은 "로비는 라우터이지 콘텐츠가 아니다"라는 대전제에 비추어 위배 여부를 판정합니다.

### 콘텐츠 위배

- [ ] **도메인 지식 본문이 로비에 포함되어 있는가?**
  - 예: "결제 트랜잭션 상태는 PENDING/AUTHORIZED/CAPTURED/...", "JWT 만료는 15분"
  - 판정: 두 문장 이상 이어지는 도메인 설명이 있으면 위배. 한 줄 요약은 라우팅 키워드로 허용
- [ ] **코드 스니펫이 로비에 포함되어 있는가?**
  - 예: 함수 정의, 클래스 시그니처, 설정 파일 일부
  - 판정: 어떤 언어든 코드 블록(```언어 ... ```)이 본문에 있으면 위배. 표준 섹션 구조 안내용 마크다운 골격은 SKILL.md의 영역이므로 산출물에는 들어가지 않음
- [ ] **특정 floor의 상세 목차/파일 트리가 로비에 펼쳐져 있는가?**
  - 예: `api-server/src/controllers/...` 같은 디렉토리 경로 다수 나열
  - 판정: floor의 path 자체는 허용하나, floor 내부 파일 트리는 위배
- [ ] **floor의 정책·규칙 본문이 로비에 중복되어 있는가?**
  - 예: 커밋 메시지 규칙, 코딩 컨벤션 본문이 로비에 그대로 적힘
  - 판정: 본문이 있으면 위배. "공통 규약" 섹션에는 포인터만 허용

### 형식·메타 위배

- [ ] **YAML frontmatter가 존재하는가?**
  - 판정: 존재하면 위배. 산출물은 frontmatter 없는 마크다운
- [ ] **본문 첫 줄이 `> last updated: YYYY-MM-DD` 형식이 아닌가?**
  - 판정: 형식 불일치 또는 누락이면 위배. 자동 갱신 대상
- [ ] **표준 6개 H2 섹션 중 누락·중복·순서 위배가 있는가?**
  - 강제 순서: `정체성` → `Floors` → `라우팅 규칙` → `공통 규약` → `Why 진입점` → `에이전트 운영 지침`
- [ ] **Floors 테이블이 4열(`path`/`domain`/`keywords`/`status`)이 아닌가?**
  - 예: `owner`, `last_activity`, `commit_hash` 등 추가 열
  - 판정: 4열 외 열이 있으면 위배

### 분량·라우터 정체성 위배

- [ ] **전체 분량이 250줄을 초과하는가?**
  - 판정: 초과 시 비대 위배. 어떤 섹션이 큰지 분석해 콘텐츠 위배 항목과 연결
- [ ] **`Floors` 또는 `라우팅 규칙` 섹션이 비어 있는가?**
  - 판정: 비어 있으면 라우터 정체성 위배 (라우팅 대상이 없음)
- [ ] **`status` 값이 `active`/`placeholder`/`archived` 외의 값을 가지는가?**
  - 판정: 정의되지 않은 값(`wip`, `legacy`, `deprecated` 등)은 위배. 사용자 확인 후 정규화

### 결과 활용

체크리스트의 모든 위배 발견은 `update-1단계` 진단 리포트에 [발견] 항목으로 기록되고, 콘텐츠 위배는 `update-3단계` 이동 후보 목록의 `migration_candidates`로 연결됩니다.

## 예시

### init 모드 예시

<!-- Task 6 -->

### update 모드 예시

<!-- Task 6 -->
