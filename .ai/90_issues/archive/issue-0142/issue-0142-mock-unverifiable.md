# 리뷰 결과

🔴 변경 요청(REQUEST CHANGES)

<details>
<summary>최종 의견 펼치기</summary>

`pay`가 `charge`의 결과에서 결제 성공 여부를 확인하지 않고 주문을 결제 완료로 바꿉니다. 이 지적이 성립하는지는 저장소 밖 `paygate_sdk` 4.x가 거절을 어떻게 알리는지에 달려 있어 확인하지 못했습니다(확인 필요).
후속 액션은 SDK 문서나 소스로 `charge`의 거절 표현·인자 순서·금액 단위를 확인하고, 성공 확인 분기와 실패 경로 테스트를 더하는 것입니다. 비즈니스 리뷰는 참조 문서가 없어 대조하지 못했습니다.

</details>

## 요약

- 비즈니스 리뷰: 🟢 통과(PASS)
- 테크 리뷰: 🔴 보완 필요(FAIL)
- 검토 파일: 2개
- 코드 레벨 검증: 읽은 파일 2개 · 읽지 않은 파일 0개
- 변경 전부터 있던 결함: 0건 (판정 산출 제외)

| 카테고리 | 건수 | 상태 |
|----------|------|------|
| 기능 | 0 | 🟢 통과(PASS) |
| 아키텍처 | 0 | 🟢 통과(PASS) |
| 버그 | 높음(HIGH) 1 | 🔴 보완 필요(FAIL) |
| 보안 | 0 | 🟢 통과(PASS) |
| 코드품질 | 0 | 🟢 통과(PASS) |
| 성능 | 0 | 🟢 통과(PASS) |
| 테스트 | 낮음(LOW) 1 | 🟢 통과(PASS) |

## PR 본문 대조

해당 없음

## 비즈니스 리뷰

참조 문서 없음: 변경 전체 (주문 결제 완료 처리 정책, 결제 대행사 `paygate_sdk` 연동 계약)

발견 없음

## 테크 리뷰

### 버그 — 🔴 보완 필요(FAIL), 1건

**🔴 높음(HIGH) `charge` 결과의 결제 성공 여부를 확인하지 않고 주문을 결제 완료로 바꿈 (확인 필요)**

`pay`는 `charge`의 반환값을 받자마자 `order.mark_paid(result.transaction_id)`를 부르며, 승인·거절을 가르는 분기가 없습니다. SDK가 거절을 예외 대신 결과 상태로 알리면 결제되지 않은 주문이 결제 완료가 됩니다. SDK의 거절 표현을 확인하고, 성공일 때만 `mark_paid`를 부르도록 분기를 두기를 권합니다.

<details>
<summary>근거 펼치기</summary>

- 영향 축: 스펙·기능 달성 차단 (결제 없이 주문이 결제 완료가 되어 PR 목적인 결제 완료 처리의 보장이 깨짐) / 발생확률 축: 통상 사용 (카드 거절은 결제 기능의 정상 사용 중에 일상적으로 생김)
- 확인하지 못한 사유: 성립이 저장소 밖 외부 패키지 `paygate_sdk`(`pyproject.toml`의 `paygate-sdk = "^4.2"`)의 `charge` 동작에 달려 있고, 그 소스가 저장소에 없음
- 코드 위치: `app/payments.py` 8~9행 (`headRefOid` `5d7b9f1a3c5e7092b4d6f8a0c2e4b6d8f0a2c4e6` 기준으로 다시 읽어 분기가 없음을 확인)
- 호출 흐름: `pay(order)` → `paygate_sdk.charge(order.total, order.card_token)` → `order.mark_paid(result.transaction_id)` → `return result`. 저장소 안에서 `charge`를 부르는 곳은 이 한 곳뿐임
- 같은 사유로 `charge`의 인자 순서(금액, 토큰)와 `order.total`의 금액 단위가 SDK 약속과 맞는지도 저장소 안에서 대조하지 못함

실패 시나리오: SDK가 잔액 부족 카드를 예외 없이 거절 상태의 결과(거래 ID 포함)로 돌려주면, 대금이 청구되지 않은 주문이 `mark_paid`로 결제 완료가 된다.

</details>

### 테스트 — 🟢 통과(PASS), 1건

**🟢 낮음(LOW) 결제 거절·실패 경로 테스트 없음**

`tests/test_payments.py`는 승인 결과를 돌려주는 경로 하나만 확인하며, 거절이나 예외일 때 `mark_paid`를 부르지 않는지는 확인하지 않습니다. `charge`가 거절을 돌려주거나 예외를 낼 때 `mark_paid`가 불리지 않음을 확인하는 테스트를 더하기를 권합니다.

<details>
<summary>근거 펼치기</summary>

- 영향 축: 기술 품질 의견 (테스트 부재는 동작에 영향 없음) / 발생확률 축: 통상 사용
- 코드 위치: `tests/test_payments.py` 7~12행 (`test_pay_marks_order_paid` 하나)
- 모의 객체 `SimpleNamespace(transaction_id="tx_1")`는 성공 여부 필드가 없는 결과 형태를 가정하며, 이 형태가 SDK의 실제 반환 형태와 같은지는 테스트가 확인하지 않음 (`autospec` 없이 `app.payments.charge`를 바꿔 끼움)

</details>

## 변경 전부터 있던 결함

발견 없음
