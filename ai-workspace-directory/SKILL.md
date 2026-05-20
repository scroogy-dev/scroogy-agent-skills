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

<!-- Task 5: 워크스페이스 루트의 .ai/AI-CONTEXT.md 존재 여부로 자동 판정 + 덮어쓰기 위험 회피 절차 -->

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

<!-- Task 4: 진단·재구성·이동 목록 3단계 -->

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

<!-- Task 4: update 모드의 1단계 진단에서 사용 -->

## 예시

### init 모드 예시

<!-- Task 6 -->

### update 모드 예시

<!-- Task 6 -->
