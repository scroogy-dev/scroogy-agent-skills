<!-- PR 본문 작성 예시 — 구조 규칙은 git-pr/SKILL.md "PR 메시지 구조", 접기 기준은 "산출물 접기 기준" 참조 -->

## 이슈 목록
- #123 - 주문 생성 API 성능 개선
- #124 - 결제 실패 시 사용자 알림 추가

---

### Issue: #123 - 주문 생성 API 성능 개선

**리스크·주의사항**
- 재고 캐시 전환으로 캐시 불일치 시 초과 판매 가능성 — TTL 5초와 주문 확정 시 DB 재검증으로 완화

<details>
<summary>비즈니스·테크 관점 상세</summary>

#### 1. 비즈니스 관점
* **목적 및 요약:** 주문 생성 응답 시간이 평균 2초를 초과하여 사용자 이탈이 발생하고 있어, 핵심 경로를 최적화한다.
* **주요 변경 사항:**
  - 주문 생성 응답 시간 2초 → 0.5초 미만으로 단축
  - 재고 조회 로직을 캐시 기반으로 전환하여 DB 부하 감소
* **참고사항:** 기획 문서 `docs/order-performance-spec.md`

#### 2. 테크 관점
* **구현 요약:** 재고 조회 쿼리를 Redis 캐시로 대체하고, 주문 유효성 검증 로직을 병렬 처리로 변경.
* **호출 흐름:**
  - 주문 생성:
    OrderController#create
    ├── OrderValidator#validate     # 필수 필드·재고 가용성 검증(병렬)
    └── OrderService#process        # 주문 생성 트랜잭션 관리
        ├── InventoryCache#get      # 재고 캐시 우선 조회
        │   └── InventoryRepository#findById (DB, 캐시 miss 시)
        └── OrderRepository#save (DB)
* **참고사항:** `.ai/50_adr/adr-cache-strategy.md`, DB 스키마 변경 없음

</details>

---

### Issue: #124 - 결제 실패 시 사용자 알림 추가

...
