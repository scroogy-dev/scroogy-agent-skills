---
name: code-map
description: 소스코드의 기능별 엔트리포인트와 호출 흐름을 .ai/60_codebase/에 색인하고, 도메인·계약·ADR 문서와 교차 참조를 연결합니다. 코드맵, code map, 코드 지도, 코드베이스 색인 시 사용합니다.
---

## 개요

소스코드를 SSoT(Single Source of Truth, 단일 진실 공급원)로 삼아, 기능별 엔트리포인트와 호출 흐름을 `.ai/60_codebase/`에 마크다운으로 색인합니다.
AI가 구현, 테스트, 코드 리뷰 등 코드베이스의 맥락 파악이 필요할 때 `60_codebase/index.md`를 진입점으로 읽고, 관련된 소스코드·도메인 지식·계약·ADR 문서를 빠르게 찾을 수 있도록 합니다.

"건물-층" 비유의 2레이어 구조를 사용하며, 하나의 스킬이 두 가지 모드로 동작합니다:

- **`--local`** (floor 모드): 개별 리포의 `.ai/60_codebase/`에 코드 색인을 생성·관리
- **`--global`** (building 모드): 멀티 리포 환경에서 공통 도메인 지식을 통합·관리

## 관련 skill

- ai-workspace (권장): `.ai/` 디렉토리 구조를 활용합니다. 없으면 `.ai/60_codebase/` 디렉토리를 직접 생성합니다. `.ai/30_contract/`, `.ai/40_domain/`, `.ai/50_adr/` 경로의 문서가 있으면 교차 참조로 연결합니다.
- context-harvest (쌍): `code-map`이 소스코드(How)를 색인하는 스킬이라면, `context-harvest`는 소스코드 바깥의 What+Why를 수집·증류하여 `30_contract/`, `40_domain/`, `50_adr/` 문서를 생성하는 스킬입니다. `context-harvest` 실행 후 `code-map --local sync`를 실행하면 새로 생긴 문서를 교차 참조로 연결합니다.

## 참조 문서

- **공통 규칙**: `.ai/10_rules/context-loading.md` — 있으면 따르며, 이미 적재되어 있으면 재로딩하지 않습니다.
- **스킬 고유 추가 참조**:
  - `.ai/30_contract/index.md`, `.ai/40_domain/index.md`, `.ai/50_adr/index.md` — 교차 참조 연결용 (index 먼저 → 관련 파일만 선택적으로 추가 로드)
- **분리 참조 파일** (`references/` — 모드 결정 후 해당 모드 파일만 읽습니다):
  - [local.md](references/local.md) — `--local` (floor 모드) 실행 절차
  - [global.md](references/global.md) — `--global` (building 모드) 실행 절차

## 사용법

```
/code-map --local          # 현재 리포의 코드 색인 생성/갱신
/code-map --global         # 멀티 리포 공통 도메인 지식 통합·관리
```

옵션을 생략하면 사용자에게 선택을 요청합니다.

---

## 적용 대상

- **Java 웹 애플리케이션** (Spring Boot, Spring MVC 등)
- **Java 배치 애플리케이션** (Spring Batch, 스케줄러 등)

---

## 핵심 원칙

### SSoT 원칙

- **소스코드가 SSoT**이다.
- `.ai/60_codebase/`의 문서는 소스코드에서 파생된 2차 산출물이다.
- 소스코드와 문서 사이에 불일치가 발생하면 소스코드가 우선한다.

### 지식 프레임워크: What / How / Why

각 코드맵 문서는 3개 레이어로 구성한다:

| 레이어 | 내용 | 생성 주체 |
|--------|------|-----------|
| **What** | 이 코드/모듈이 무엇인가 (엔티티 정의, 데이터 모델, API 계약) | 에이전트가 소스코드에서 자동 추출 |
| **How** | 어떻게 동작하는가 (호출 흐름, 의존성, 설정) | 에이전트가 소스코드 + 설정파일에서 자동 추출 |
| **Why** | 왜 이렇게 설계했는가 (비즈니스 판단, 아키텍처 결정, 규제 근거) | **반드시 사람이 태깅** |

- 에이전트는 Why를 자의적으로 생성하지 않는다.
- `.ai/` 내 관련 문서(계약, 도메인 명세, ADR 등)가 있으면 Why에 교차 참조 링크로 연결한다.
- 관련 문서로도 설명되지 않는 설계 근거는 `[WHY-NEEDED]` 태그로 표시하여 사람에게 요청한다.

**Why 절의 참조 계층:**
- 1차 참조: `.ai/` 내부 문서 (`30_contract`, `40_domain`, `50_adr`)
- 외부 URL(wiki, GitHub issue 등)은 Why 절에 직접 기재하지 않는다.
- 외부 URL은 참조 대상인 `.ai/` 내부 문서 안에 원본 출처로 기재한다.
- `.ai/` 내부 문서가 아직 없으면 `[DOC-NEEDED]` 태그로 표시한다.

### .ai 디렉토리와의 관계

`60_codebase/`는 소스코드에서 `.ai/` 내 다른 디렉토리로의 **네비게이션 허브** 역할을 한다:

```
.ai/
├── 30_contract/     # 소프트웨어 계약 (API 명세, 연동 규약)
├── 40_domain/       # 비즈니스 도메인 (기능 명세, 정책, 용어)
├── 50_adr/          # 의사결정 기록
└── 60_codebase/     # ← 이 스킬의 작업 대상
    ├── index.md     # 기능별 엔트리포인트 색인 (진입점)
    └── <feature>/                        # 기능별 디렉토리
        └── <action>-call-flow.md        # 엔트리포인트별 상세 호출 흐름
```

코드맵 문서에서 관련 문서를 교차 참조 링크로 연결한다:
- 이 기능의 API 계약 → `../30_contract/<문서>.md`
- 이 기능의 도메인 명세 → `../40_domain/specs/<문서>.md`
- 이 기능의 적용 정책 → `../40_domain/policies/common/<문서>.md` 또는 `../40_domain/policies/local/<문서>.md`
- 이 설계의 결정 근거 → `../50_adr/active/<ADR>.md`

---

## 모드별 실행 절차

모드를 결정한 뒤, 해당 모드의 참조 파일만 읽고 그 절차를 따른다.

| 모드 | 참조 파일 | 요약 |
|------|-----------|------|
| `--local` (floor) | [references/local.md](references/local.md) | 개별 리포의 코드 색인 생성/갱신/점검 (build / sync / check / rebuild) |
| `--global` (building) | [references/global.md](references/global.md) | `repository.yaml` 기반 멀티 리포 수집 → 아키텍처 문서·건물 안내도 생성/갱신/점검 |

---

## 두 모드 간 참조 관계

```
--local (개별 리포)                    --global (문서 전용 리포)
┌────────────────────┐               ┌──────────────────────────────────┐
│ .ai/60_codebase/   │←──── 읽기 ─────│ .ai/10_rules/                    │
│   index.md         │               │   architecture.md         ← 생성  │
│   <feature>/       │               │   service-call-flows.md   ← 생성  │
│ .ai/30_contract/   │               │   infra.md                ← 생성  │
│ .ai/40_domain/     │               │ .ai/60_codebase/                 │
│ .ai/50_adr/        │               │   repository.yaml                │
└────────────────────┘               │   index.md                ← 생성  │
                                     └──────────────────────────────────┘
```

- **global → local (읽기 전용)**: global이 각 리포의 `60_codebase/index.md`와 교차 참조 문서를 읽어서 아키텍처 문서와 안내도를 생성
- global은 local을 **수정하지 않는다**
- global의 산출물은 `.ai/10_rules/architecture.md`(+선택적 분리 문서)와 `.ai/60_codebase/index.md`이다

---

## 지속적 업데이트 모델

이 스킬은 최초 생성(build) 이후 3가지 트리거로 지속 업데이트된다:

### 1. 변경 감지 기반 (권장)

- 개별 리포에서 main/master 브랜치에 병합될 때 `--local sync`를 실행
- 변경된 소스코드 범위를 기준으로 관련 색인만 갱신 (전체 리포를 다시 읽지 않음)
- 이 스킬이 hook을 직접 설정하지는 않으며, CI/CD 파이프라인이나 post-merge hook에 연동 가능

### 2. 주기적 check (보완)

- 정기적으로 전체 색인 상태를 점검하여 누락/불일치 탐지
- 변경 감지에서 놓친 간접적 영향(교차참조 깨짐 등)을 보완
- check 결과는 사용자에게 보고하고, 조치 필요 항목은 태그로 표시

### 3. 수동 트리거 (필요 시)

- 대규모 리팩토링, 아키텍처 변경, 새 리포 추가 등 구조적 변화 시 rebuild 요청
- `--global`에서 새 리포를 등록할 때도 수동 트리거

---

## 문서 메타데이터

각 색인 문서에 다음 메타데이터를 YAML frontmatter로 관리한다:

```yaml
---
last_synced: 2026-04-08          # 마지막 동기화 일시
source_hash: a1b2c3d             # 마지막 동기화 시점의 커밋 해시 (어디까지 반영했는지의 참조)
status: current | stale | draft  # 문서 상태
---
```

- `source_hash`는 "이 색인이 어느 시점의 소스코드까지 반영했는가"를 나타내는 참조이다.
- stale 여부는 `source_hash` 이후 **변경된 파일 목록**을 기준으로 판정한다. 무관한 파일만 변경된 경우 stale로 판정하지 않는다.
- stale 문서는 check에서 `[UPDATE-NEEDED]` 태그로 리포팅한다.

---

## 태그 체계

| 태그 | 의미 | 생성 위치 |
|------|------|-----------|
| `[WHY-NEEDED]` | Why 레이어가 미태깅 — 사람의 입력 필요 | local 색인 문서 |
| `[DOC-NEEDED]` | 관련 문서(contract/domain/ADR)가 존재해야 하나 미작성 | local 색인 문서 |
| `[UPDATE-NEEDED]` | 소스 변경 후 색인 미반영 | local check |
| `[NOT-INDEXED]` | `--local` 미실행 리포 — 동기화 대상에서 제외 | global 리포 목록 |
| `[REPO-NOT-FOUND]` | 로컬에 clone이 없는 리포 | global 리포 목록 |

---

## 권장 도입 순서

1. 가장 잘 아는 리포 1개에 `--local`로 최초 build
2. 2~3개 리포로 확장하면서 공통 패턴 관찰
3. 반복되는 용어/구조가 보이면 `--global` 적용
4. 변경 감지 기반 sync + 주기적 check를 운영 루틴으로 정착

---

## 디렉토리 트리 정렬 규칙

`.ai/60_codebase/` 내부 트리(`index.md`의 파일 구조 다이어그램, `<feature>/<action>-call-flow.md`의 호출 흐름 다이어그램 등)를 작성·갱신할 때 적용하는 규칙입니다.

- **같은 단계 내 정렬 기준**: 대소문자를 무시한 알파벳순으로 정렬합니다.
- **디렉토리 우선**: 디렉토리를 동일 단계의 파일보다 위에 둡니다.
- **숨김 항목 위치 고정 금지**: `.`로 시작하는 항목도 같은 알파벳순 규칙으로 처리하며 별도 위치에 모아두지 않습니다.
- **결과**: IntelliJ·VS Code 등 IDE의 기본 표시 순서와 일치합니다.

호출 흐름 다이어그램의 노드 순서는 의미적 흐름(엔트리포인트 → 핵심 로직 → 외부 의존성)이 우선이므로 이 규칙을 강제하지 않습니다. 단, 동일 레이어 내 동등한 형제 노드를 나열할 때는 위 규칙을 권장합니다.
