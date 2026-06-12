# --local (floor 모드) 실행 절차

> `code-map` 스킬의 참조 문서입니다. `--local` 모드 진입 시에만 읽습니다.
> 공통 원칙(SSoT, What/How/Why, 교차 참조 규칙, 태그 체계, 문서 메타데이터)은 [SKILL.md](../SKILL.md)를 따릅니다.

## 트리거 조건

- 개별 리포의 코드 색인을 생성/갱신/점검할 때
- `.ai/60_codebase/`가 작업 대상일 때

## 파일 구조

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

> 트리 표현 순서는 [디렉토리 트리 정렬 규칙](../SKILL.md#디렉토리-트리-정렬-규칙)을 따릅니다 (대소문자 무시 알파벳순 + 디렉토리 우선).

## 실행 절차

### 0단계: 모드 결정

`.ai/60_codebase/index.md`의 내용 유무에 따라 모드를 결정한다.
(ai-workspace가 빈 index.md를 생성하므로 파일 존재가 아닌 **내용 유무**로 판정한다.)

- **비어 있음** → `build`(최초 생성) 실행
- **내용 있음** → 사용자에게 선택 요청
  - `sync`: 소스코드 변경분을 색인에 반영
  - `check`: 색인의 정합성 점검
  - `rebuild`: 전체 재생성 (기존 색인 덮어씀, Why 태깅은 보존)

---

### 1단계: 소스코드 색인

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

### 2단계: 교차 참조 연결

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

### 3단계: 정합성 점검

색인의 정합성을 점검한다. (`check` 모드 선택 시 1~2단계를 건너뛰고 이 단계만 실행한다.)

| 점검 | 설명 |
|------|------|
| stale 탐지 | `source_hash` 이후 변경된 파일 목록을 조회하여, 해당 파일이 관여하는 기능의 색인이 미반영이면 → `[UPDATE-NEEDED]` |
| 엔트리포인트 유효성 | 색인에 기재된 컨트롤러·메서드·Job이 실제로 존재하는지. **존재하지 않으면 해당 항목을 색인과 상세 호출 흐름 파일에서 자동 제거한다.** |
| 교차참조 유효성 | `30_contract`, `40_domain`, `50_adr`로의 링크가 실제로 존재하는지 |
| Why 미태깅 | `[WHY-NEEDED]` 태그가 있는 항목 목록 |
| 문서 누락 | `[DOC-NEEDED]` 태그가 있는 항목 목록 |

---

### 4단계: 결과 보고

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
