<!-- PR 본문 작성 예시 — 구조 규칙은 git-pr/SKILL.md "PR 메시지 구조", 접기 기준은 "산출물 접기 기준" 참조 -->

## 이슈 목록
- #123 - 주문 생성 API 성능 개선
- #124 - 결제 실패 시 사용자 알림 추가

---

### Issue: #123 - 주문 생성 API 성능 개선

**목적·범위**
- 주문 생성 응답 시간을 0.5초 미만으로 줄인다. 이 PR은 재고 조회 캐시 전환과 주문 검증 병렬화를 맡는다.

**리뷰어 확인 요청**
- 재고 캐시 TTL 5초 동안의 불일치를 주문 확정 시 DB 재검증으로 막는 방식이 초과 판매 허용 범위 안인가?

**리스크·주의사항**
- 재고 캐시 전환으로 캐시 불일치 시 초과 판매 가능성 — TTL 5초와 주문 확정 시 DB 재검증으로 완화

**완료의 정의 대조**
- 충족 2/3 (AC3 미검증)

**이번 PR에서 하지 않는 것**
- 결제 단계 응답 시간 개선: 외부 결제 대행사 구간이라 별도 이슈로 다룬다

<details>
<summary>대조 표·전후 예시·배경·비즈니스·테크 관점 상세</summary>

#### 완료의 정의 대조 표

| AC | 상태 | 근거 |
|----|------|------|
| AC1: 주문 생성 응답 시간 p95 0.5초 미만 | 충족 | spec R1 `[D]` 부하 테스트 항목, 최종 감사 충족(PASS) |
| AC2: 재고 캐시 miss 시 DB 조회로 대체 | 충족 | spec R2 `[D]` 캐시 miss 테스트 항목, 최종 감사 충족(PASS) |
| AC3: 캐시 불일치로 인한 초과 판매 0건 | 미검증 | spec R2 `[QD]` 동시 주문 시나리오 항목, 최종 감사 판정 불가(N/A): 운영 데이터가 필요 |

#### 전후 예시

| 상황 | 이전 | 이후 |
|------|------|------|
| 주문 생성 (재고 캐시 hit) | 평균 응답 2.1초 | 평균 응답 0.3초 |
| 주문 생성 (재고 캐시 miss) | 평균 응답 2.1초 | DB 조회 후 평균 응답 0.45초 |

#### 배경
- 주문 생성 응답 시간이 평균 2초를 넘어 결제 전 이탈이 늘었다. 재고 조회가 요청마다 DB를 읽고 주문 검증이 순차로 실행되는 구조였다.

#### 1. 비즈니스 관점
* **목적 및 요약:** 결제 전 단계에서 사용자가 기다리는 시간을 줄여 주문 완료율을 높인다. 응답 시간 목표 0.5초는 기획 문서의 이탈률 분석에서 정했다.
* **주요 변경 사항:**
  - 주문 생성 응답 시간 2초 → 0.5초 미만으로 단축
  - 재고 조회 로직을 캐시 기반으로 전환하여 DB 부하 감소
* **참고사항:** 기획 문서 `docs/order-performance-spec.md`

#### 2. 테크 관점
* **구현 요약:** 재고 조회 쿼리를 Redis 캐시로 대체하고, 주문 유효성 검증 로직을 병렬 처리로 변경.
* **호출 흐름:**
  - 주문 생성:

    ```
    OrderController#create
    ├── OrderValidator#validate     # 필수 필드·재고 가용성 검증(병렬)
    └── OrderService#process        # 주문 생성 트랜잭션 관리
        ├── InventoryCache#get      # 재고 캐시 우선 조회
        │   └── InventoryRepository#findById (DB, 캐시 miss 시)
        └── OrderRepository#save (DB)
    ```

    ```mermaid
    sequenceDiagram
        participant OC as OrderController
        participant OV as OrderValidator
        participant OS as OrderService
        participant IC as InventoryCache
        participant IR as InventoryRepository
        participant OR as OrderRepository

        OC->>OV: validate
        Note over OV: 필수 필드·재고 가용성 병렬 검증
        OV-->>OC: 검증 통과
        OC->>OS: process
        rect rgba(128, 128, 128, 0.1)
            Note over OS,OR: 주문 생성 트랜잭션
            OS->>IC: get
            opt 캐시 miss
                IC->>IR: findById
                IR-->>IC: 재고
            end
            IC-->>OS: 재고
            OS->>OR: save
            OR-->>OS: 저장된 주문
            OS-->>OC: 생성된 주문
        end
    ```
* **실패 경로:**
  - 캐시 조회 실패(연결 오류): `InventoryCache#get`이 캐시 miss와 같게 처리해 `InventoryRepository#findById`로 조회한다.
  - 주문 저장 실패: 주문 생성 트랜잭션이 롤백되어 주문이 남지 않는다. 캐시는 읽기만 하므로 되돌릴 것이 없다.
* **참고사항:** `.ai/50_adr/adr-cache-strategy.md`, DB 스키마 변경 없음

</details>

---

### Issue: #124 - 결제 실패 시 사용자 알림 추가

...
