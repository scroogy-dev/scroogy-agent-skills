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

## --local (floor 모드)

### 트리거 조건

- 개별 리포의 코드 색인을 생성/갱신/점검할 때
- `.ai/60_codebase/`가 작업 대상일 때

### 파일 구조

```
.ai/60_codebase/
├── index.md                    # 기능별 엔트리포인트 색인 (진입점)
├── board/                      # 예: 게시판 기능
│   ├── create-call-flow.md     #     게시판 생성 흐름
│   ├── list-call-flow.md       #     게시판 목록 조회 흐름
│   └── update-call-flow.md     #     게시판 수정 흐름
└── payment/                    # 예: 결제 기능
    ├── process-call-flow.md    #     결제 처리 흐름
    └── refund-call-flow.md     #     환불 처리 흐름
```

### 실행 절차

#### 0단계: 모드 결정

`.ai/60_codebase/index.md`의 내용 유무에 따라 모드를 결정한다.
(ai-workspace가 빈 index.md를 생성하므로 파일 존재가 아닌 **내용 유무**로 판정한다.)

- **비어 있음** → `build`(최초 생성) 실행
- **내용 있음** → 사용자에게 선택 요청
  - `sync`: 소스코드 변경분을 색인에 반영
  - `check`: 색인의 정합성 점검
  - `rebuild`: 전체 재생성 (기존 색인 덮어씀, Why 태깅은 보존)

---

#### 1단계: 소스코드 색인

소스코드를 읽고 `.ai/60_codebase/`의 색인을 생성/업데이트한다.

**1-1. 스캔 범위 결정**

- build / rebuild: 리포 전체
- sync: `source_hash`(마지막 동기화 커밋) 이후 **변경된 파일** 기준으로 관련 기능만 산정 (`git diff <source_hash>..HEAD --name-only`)

**1-2. 기능 식별 및 엔트리포인트 추출**

기능(feature)의 단위는 **HTTP 요청 API 단위**(컨트롤러 메서드)이다.
배치 애플리케이션의 경우 **Job 단위**를 기능으로 식별한다.

- 컨트롤러 클래스를 스캔하여 각 요청 매핑(GET/POST/PUT/DELETE 등)을 하나의 기능으로 식별한다.
- 배치의 경우 `@Scheduled`, `Job`, `Tasklet` 등을 엔트리포인트로 식별한다.
- sync 시, 변경된 파일에서 **삭제된 컨트롤러 메서드·Job**이 발견되면 해당 기능을 index.md와 상세 호출 흐름 파일에서 자동 제거한다.

**1-3. index.md 작성**

기능별 엔트리포인트를 `index.md`에 색인한다:

```markdown
---
last_synced: <동기화 일시>
source_hash: <커밋 해시>
status: current
---

# 코드맵

## 기능 목록

| 기능 | 엔트리포인트 | 관련 문서 |
|------|-------------|-----------|
| 주문 생성 | `com.example.order.OrderController.createOrder()` | [상세 흐름](order/create-call-flow.md), [계약](../30_contract/order-api.md), [명세](../40_domain/specs/order.md) |
| 결제 처리 | `com.example.payment.PaymentService.processPayment()` | [상세 흐름](payment/process-call-flow.md), [ADR-003](../50_adr/active/003-payment-gateway.md) |
| RSA 키 생성 | `com.example.crypto.RsaKeyGenerateJob` | — (단순 CRUD, 외부 의존 없음) |
```

- 각 기능에서 관련된 `30_contract`, `40_domain`, `50_adr` 문서가 있으면 교차 참조 링크를 연결한다.
- 관련 문서가 없으면 링크 없이 비워둔다 (없는 문서를 가리키는 링크를 만들지 않는다).
- 상세 호출 흐름 문서가 **있는** 기능: 관련 문서 칸에 `[상세 흐름](<feature>/<action>-call-flow.md)` 링크를 포함한다.
- 상세 호출 흐름 문서가 **없는** 기능 (1-4단계 기준 미해당): 관련 문서 칸에 생략 사유를 짧게 표기한다 (예: `— (단순 CRUD, 외부 의존 없음)`).
- 이를 통해 "아직 안 만든 것"과 "만들 필요가 없는 것"을 구분할 수 있게 한다.

**1-4. 상세 호출 흐름 작성 (선택)**

아래 기준에 해당하는 경우, 기능별 디렉토리(`<feature>/`) 아래에 엔트리포인트별 `<action>-call-flow.md` 파일을 만들어 상세 호출 흐름을 기록한다.
호출 흐름은 **엔트리포인트 → 핵심 로직 → 외부 의존성(DB, 외부 API 등)** 순서로 추적하며, 디렉토리 트리 형태의 ASCII 다이어그램으로 시각화한다:

`````markdown
---
last_synced: <동기화 일시>
source_hash: <커밋 해시>
status: current
---

# 주문 생성 호출 흐름

## What

주문 생성 요청을 받아 검증 → 재고 확인 → 주문 저장 → 이벤트 발행까지의 흐름.

## How

```
OrderController#createOrder
├── OrderService#createOrder             # 주문 생성 트랜잭션 관리
│   ├── InventoryClient#reserve          # 재고 확인 (외부 서비스 호출)
│   ├── OrderRepository#save             # DB 저장
│   └── ApplicationEventPublisher#publishEvent(OrderCreatedEvent)  # 도메인 이벤트 발행
```

## Why

> 1차 참조는 `.ai/` 내부 문서만 사용한다. 외부 URL은 내부 문서 안에 원본 출처로 기재한다.

- 계약: [주문 API 명세](../../30_contract/order-api.md)
- 도메인: [주문 기능 명세](../../40_domain/specs/order.md)
- ADR: [ADR-003 결제 게이트웨이 선정](../../50_adr/active/003-payment-gateway.md)
- [WHY-NEEDED] 재고 확인을 동기 호출로 처리하는 근거가 문서화되지 않았습니다.
`````

- 상세 호출 흐름은 다음 기준에 해당하면 작성한다:
  - 엔트리포인트 → 핵심 로직 → 외부 의존성(DB, 외부 API 등) 사이에 **2단계 이상의 호출 계층**이 존재하는 경우
  - **외부 서비스 호출**(HTTP 클라이언트, 메시지 발행 등)이 포함된 경우
  - **트랜잭션 경계**, **이벤트 발행**, **비동기 처리** 등 흐름 분기가 있는 경우
- 단순 CRUD라도 엔트리포인트마다 흐름이 다르면 각각 파일을 분리한다 (예: `board/create-call-flow.md`, `board/list-call-flow.md`).
- 위 기준에 해당하지 않는 단순한 흐름은 index.md의 한 줄로 충분하므로 상세 문서를 생략한다.

---

#### 2단계: 교차 참조 연결

색인에서 `.ai/` 내 다른 디렉토리의 문서를 교차 참조로 연결한다.

| 참조 대상 | 연결 기준 |
|-----------|-----------|
| `30_contract/` | 기능이 외부 API를 노출하거나 소비하면, 해당 계약 문서를 링크 |
| `40_domain/specs/` | 기능이 특정 도메인 기능 명세와 관련되면, 해당 문서를 링크 |
| `40_domain/policies/` | 기능이 공통 정책(`common/`) 또는 로컬 정책(`local/`)과 관련되면, 해당 문서를 링크 |
| `50_adr/` | 기능의 설계에 관련 ADR이 있으면, 해당 문서를 링크 |

- **존재하는 문서만 링크한다** — 문서가 없는데 링크를 만들지 않는다.
- 관련 문서가 존재할 것으로 판단되나 아직 작성되지 않은 경우, `[DOC-NEEDED: 30_contract/order-api.md]` 태그로 표시한다.
- **외부 URL은 교차 참조 대상이 아니다** — wiki, GitHub issue 등 외부 URL은 `.ai/` 내부 문서 안에 원본 출처로 기재하며, 색인 문서에서 직접 링크하지 않는다.

---

#### 3단계: 정합성 점검

색인의 정합성을 점검한다. (`check` 모드 선택 시 1~2단계를 건너뛰고 이 단계만 실행한다.)

| 점검 | 설명 |
|------|------|
| stale 탐지 | `source_hash` 이후 변경된 파일 목록을 조회하여, 해당 파일이 관여하는 기능의 색인이 미반영이면 → `[UPDATE-NEEDED]` |
| 엔트리포인트 유효성 | 색인에 기재된 컨트롤러·메서드·Job이 실제로 존재하는지. **존재하지 않으면 해당 항목을 색인과 상세 호출 흐름 파일에서 자동 제거한다.** |
| 교차참조 유효성 | `30_contract`, `40_domain`, `50_adr`로의 링크가 실제로 존재하는지 |
| Why 미태깅 | `[WHY-NEEDED]` 태그가 있는 항목 목록 |
| 문서 누락 | `[DOC-NEEDED]` 태그가 있는 항목 목록 |

---

#### 4단계: 결과 보고

사용자에게 요약을 보고한다.

   ```
   ## code-map --local 실행 결과

   - 모드: build | sync | check | rebuild
   - 기능 색인: N건 (신규 N / 갱신 N / 삭제 N)
   - 상세 호출 흐름: N건
   - 교차 참조: 30_contract N건, 40_domain N건, 50_adr N건
   - [WHY-NEEDED]: N건
   - [DOC-NEEDED]: N건
   - [UPDATE-NEEDED]: N건

   > 진입점: .ai/60_codebase/index.md
   ```

---

## --global (building 모드)

### 트리거 조건

- 멀티 리포 횡단 도메인 지식을 통합·관리할 때
- 공통 도메인 리포에서 작업할 때

### 전제 조건

- 현재 프로젝트는 **소스코드가 없는 문서 전용 리포**이다.
- 현재 프로젝트의 `.ai/60_codebase/repository.yaml`이 존재해야 한다.
- `repository.yaml`에 등록된 각 리포에는 이미 `--local`로 `.ai/60_codebase/index.md`가 존재해야 한다.
- 이 모드는 각 리포의 색인을 분석하여, `.ai/10_rules/` 아래에 리포 간 의존 관계·서비스 호출 흐름·공통 인프라 정보를 아키텍처 문서로 **생성·관리**하는 역할이다.

### repository.yaml

대상 리포 목록을 `.ai/60_codebase/repository.yaml`에 정의한다:

```yaml
org:
  workspace: /Users/dev/projects    # 리포들이 clone되는 상위 디렉토리
  repos:
    - https://github.com/our-org/auth-service
    - https://github.com/our-org/gateway
    - https://github.com/our-org/user-service
```

- 에이전트는 이 파일을 읽어 대상 리포를 결정한다.
- 파일이 없으면 사용자에게 생성을 안내하고 중단한다.
- 로컬 경로는 `workspace` + URL의 리포명으로 도출한다 (예: `/Users/dev/projects/auth-service`).
- `workspace` 경로에 해당 리포가 없으면 디폴트 브랜치로 clone한다.

### 파일 구조

이 스킬이 관리하는 파일:

```
.ai/
├── 10_rules/
│   ├── architecture.md              # 서비스 목록, 리포 간 의존 관계
│   ├── service-call-flows.md        # 서비스 간 호출 흐름
│   └── infra.md                     # 공통 인프라 정보
└── 60_codebase/
    ├── repository.yaml              # 대상 리포 목록 (workspace 경로 + URL)
    └── index.md                     # 건물 안내도 (최상위 진입점)
```

- `architecture.md`: 서비스 목록과 리포 간 의존 관계를 기록한다. `service-call-flows.md`, `infra.md`로의 링크를 포함한다.
- `service-call-flows.md`: 서비스 간 크로스-서비스 호출 흐름을 기록한다.
- `infra.md`: 공통 인프라 정보(메시지 브로커, 서비스 디스커버리, DB 등)를 기록한다.
- `60_codebase/index.md`(건물 안내도)는 리포 목록과 상태를 관리하며, 아키텍처 문서(`10_rules/`)로의 링크를 포함한다.

### 실행 절차

#### 0단계: 리포 목록 확인 및 모드 결정

1. `.ai/60_codebase/repository.yaml`을 읽어 대상 리포 목록을 확인한다.
2. 파일이 없으면 사용자에게 `repository.yaml` 생성을 안내하고 중단한다.
3. 각 리포의 로컬 clone 경로를 탐색한다. 찾을 수 없는 리포는 `[REPO-NOT-FOUND]`로 표시하고 사용자에게 보고한다.
4. 각 리포의 `.ai/60_codebase/index.md` 존재 여부를 확인하여 분석 상태를 분류한다.
   - **분석 완료**: `.ai/60_codebase/index.md`에 내용이 있는 리포 → 동기화 대상
   - **미분석**: `.ai/60_codebase/index.md`가 없거나 비어 있는 리포 → 건너뛰고 `[NOT-INDEXED]`로 표시
5. `.ai/60_codebase/index.md`의 내용 유무에 따라 모드를 결정한다.
   - **비어 있음** → `build`(최초 생성) 실행
   - **내용 있음** → 사용자에게 선택 요청
     - `sync`: 각 리포의 변경분을 건물 안내도에 반영
     - `check`: 건물 안내도의 정합성 점검
     - `rebuild`: 전체 재생성

---

#### 1단계: 수집 (floor → building)

0단계에서 분석 완료로 분류된 리포만 대상으로 정보를 수집한다.

1. **리포 스캔** — 각 리포의 `.ai/60_codebase/index.md`와 상세 호출 흐름 문서를 읽는다.
2. **변경 감지** — 이전 동기화 이후 변경된 색인을 식별한다.
3. **교차 참조 수집** — 각 리포 색인에 연결된 `.ai/30_contract/`, `.ai/40_domain/`, `.ai/50_adr/` 문서 목록을 수집한다.
4. **크로스-서비스 호출 식별** — 각 리포의 호출 흐름에서 다른 리포의 API를 호출하는 지점을 식별한다.

---

#### 2단계: 아키텍처 문서 생성/갱신

각 리포의 색인에서 도출한 정보를 바탕으로 `.ai/10_rules/` 아래 3개 파일을 생성/갱신한다.

**architecture.md** — 서비스 목록, 의존 관계, 다른 문서로의 링크:

`````markdown
# 시스템 아키텍처

## 서비스 목록

| 서비스 | 역할 | 리포 |
|--------|------|------|
| auth-service | 인증/인가 | https://github.com/our-org/auth-service |
| gateway | API 게이트웨이 | https://github.com/our-org/gateway |
| user-service | 사용자 관리 | https://github.com/our-org/user-service |

## 서비스 간 의존 관계

```
gateway → auth-service      # 인증 토큰 검증
gateway → user-service      # 사용자 조회 프록시
auth-service → user-service # 사용자 인증 정보 조회
```

## 관련 문서

- [서비스 간 호출 흐름](service-call-flows.md)
- [공통 인프라](infra.md)
`````

**service-call-flows.md** — 크로스-서비스 호출 흐름:

`````markdown
# 서비스 간 호출 흐름

## 사용자 로그인

```
gateway#POST /api/login
└── auth-service#AuthController#login
    └── user-service#UserController#findByEmail (내부 API)
```
`````

**infra.md** — 공통 인프라 정보:

`````markdown
# 공통 인프라

- 메시지 브로커: Kafka (이벤트 발행/소비)
- 서비스 디스커버리: Eureka
- ...
`````

---

#### 3단계: 건물 안내도 갱신

`.ai/60_codebase/index.md` (건물 안내도)를 생성/갱신한다.

```markdown
# 건물 안내도

## 리포 목록

| 리포 | 요약 | URL | 상태 | 마지막 동기화 |
|------|------|-----|------|---------------|
| auth-service | 인증/인가 서비스 | https://github.com/our-org/auth-service | 분석 완료 | 2026-04-08 |
| gateway | API 게이트웨이 | https://github.com/our-org/gateway | 분석 완료 | 2026-04-08 |
| user-service | 사용자 관리 서비스 | https://github.com/our-org/user-service | [NOT-INDEXED] | - |

## 아키텍처 문서

- [시스템 아키텍처](../10_rules/architecture.md)
- [서비스 간 호출 흐름](../10_rules/service-call-flows.md)
- [공통 인프라](../10_rules/infra.md)
```

---

#### 4단계: 정합성 점검

`check` 모드 선택 시 1~3단계를 건너뛰고 이 단계만 실행한다.

| 점검 | 설명 |
|------|------|
| 리포 접근성 | `repository.yaml`에 등록된 리포가 로컬에 clone되어 있고 `.ai/60_codebase/index.md`가 존재하는지 |
| 안내도 불일치 | 건물 안내도의 리포 목록과 `repository.yaml`이 일치하는지 |
| 아키텍처 문서 유효성 | `architecture.md`의 서비스·의존 관계, `service-call-flows.md`의 호출 흐름, `infra.md`의 인프라 정보가 각 리포의 현재 색인과 일치하는지 |
| 교차참조 유효성 | 각 리포 색인에 연결된 `.ai/30_contract/`, `.ai/40_domain/`, `.ai/50_adr/` 문서가 실제 존재하는지 |

---

#### 5단계: 결과 보고

사용자에게 요약을 보고한다.

   ```
   ## code-map --global 실행 결과

   - 모드: build | sync | check | rebuild
   - 대상 리포: N개 (분석 완료 N / [NOT-INDEXED] N / [REPO-NOT-FOUND] N)
   - 아키텍처 문서: architecture.md (신규 생성 | 갱신 | 변경 없음)
   - 서비스 간 의존 관계: N건
   - 서비스 간 호출 흐름: N건
   - 교차 참조 깨짐: N건

   > 아키텍처: .ai/10_rules/architecture.md
   > 안내도: .ai/60_codebase/index.md
   ```

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
