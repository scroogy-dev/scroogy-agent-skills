# 리뷰 결과

🟢 승인(APPROVE)

<details>
<summary>최종 의견 펼치기</summary>

- 함수 순서 변경과 모듈 설명 문자열 수정이 PR 본문의 범위대로이며, 옮긴 `parse_qty`의 본문과 이를 가져다 쓰는 `app/cart_api.py`의 참조는 그대로 성립합니다.
- 변경 전부터 있던 결함 2건(`cart_total`의 수량 누락, `parse_qty`의 입력 검증 누락)은 판정에서 뺐으며, 이번 PR과 별도로 고치기를 권합니다.
- 입력에 참조 문서(계약·도메인·아키텍처 방향·ADR)가 없어 비즈니스 리뷰는 대조하지 못했고, 아키텍처 카테고리는 코드만으로 확인했습니다.

</details>

## 요약

- 비즈니스 리뷰: 🟢 통과(PASS)
- 테크 리뷰: 🟢 통과(PASS)
- 검토 파일: 1개
- 코드 레벨 검증: 읽은 파일 1개 · 읽지 않은 파일 0개
- 변경 전부터 있던 결함: 2건 (판정 산출 제외)

| 카테고리 | 건수 | 상태 |
|----------|------|------|
| 기능 | 0 | 🟢 통과(PASS) |
| 아키텍처 | 0 | 🟢 통과(PASS) |
| 버그 | 0 | 🟢 통과(PASS) |
| 보안 | 0 | 🟢 통과(PASS) |
| 코드품질 | 0 | 🟢 통과(PASS) |
| 성능 | 0 | 🟢 통과(PASS) |
| 테스트 | 0 | 🟢 통과(PASS) |

## PR 본문 대조

해당 없음 (PR 본문에 리뷰어 확인 요청과 완료의 정의 대조 항목이 없음)

## 비즈니스 리뷰

참조 문서 없음: 장바구니 합계 계산과 수량 입력에 관한 도메인 정책·소프트웨어 계약 전체 (`.ai/30_contract/`·`.ai/40_domain/` 문서를 확보하지 못함)

발견 없음

## 테크 리뷰

발견 없음

## 변경 전부터 있던 결함

**높음(HIGH) `cart_total`이 수량을 곱하지 않음**

`cart_total`이 `item.price`만 더해 설명 문자열("품목마다 가격 × 수량을 더한다")과 달리 수량을 빠뜨립니다. 수량이 2 이상인 품목이 있으면 `cart_api.add_item`이 돌려주는 `total`이 실제 청구 금액(`checkout.charge_amount`의 `line_total` 합)보다 작게 나옵니다.

<details>
<summary>근거 펼치기</summary>

- 카테고리: 버그
- 영향 축: 스펙·기능 달성 차단 (수량 2 이상에서 장바구니 합계가 틀린 값) / 발생확률 축: 통상 사용 (같은 품목 여러 개 담기는 정상 경로)
- 코드 위치: `app/cart.py:10` `return sum(item.price for item in items)` (`headRefOid` 커밋 기준, 변경 전 15행)
- 호출 흐름: `app/cart_api.py:9` `add_item` → `cart_total(cart.items)` → 응답의 `total`
- 변경 전부터 있던 것으로 본 근거: 결함 줄은 diff의 문맥 줄(`@@ -13,3 +8,8 @@` 구간)이며 추가·수정 줄이 아닙니다. 함수 순서 변경은 이 함수로 가는 호출 경로를 새로 만들거나 넓히지 않습니다.

</details>

**중간(MEDIUM) `parse_qty`가 수량 입력을 검증하지 않음**

`parse_qty`가 `int(text)`만 호출해 0·음수와 숫자가 아닌 문자열을 거르지 않습니다. 음수 수량이 `cart_api.add_item`을 거쳐 장바구니에 들어가면 `charge_amount`가 그만큼 청구 금액을 줄입니다. 숫자가 아닌 입력은 처리하지 않은 `ValueError`로 요청이 실패합니다.

<details>
<summary>근거 펼치기</summary>

- 카테고리: 보안 (외부 입력의 검증 누락)
- 영향 축: 스펙·기능 달성 차단 (청구 금액 조작) / 발생확률 축: 특수 조건·엣지 (비정상 입력)
- 코드 위치: `app/cart.py:15` `return int(text)` (`headRefOid` 커밋 기준, 변경 전 6행)
- 호출 흐름: `app/cart_api.py:7` `parse_qty(request.form["qty"])` → `app/cart_store.py:18` `Cart.add` → `app/cart_store.py:10` `CartItem.qty` → `app/checkout.py:8` `charge_amount`의 `line_total(item)` 합
- 변경 전부터 있던 것으로 본 근거: `parse_qty` 블록(정의·설명 문자열·`return int(text)` 3행)은 diff의 삭제 쪽(변경 전 4~6행)과 추가 쪽(변경 후 13~15행)이 같은 내용이고 둘 다 모듈 최상위에 있어, 내용 변경 없이 옮기기만 한 블록입니다. 삭제 쪽 블록에도 같은 결함이 있었고, 호출하는 쪽 `app/cart_api.py`는 변경 파일이 아니어서 입력이 이 함수에 닿는 경로는 그대로입니다.

</details>
