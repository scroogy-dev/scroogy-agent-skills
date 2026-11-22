# 입력: preexisting

## 대상

- 모드: `PR 모드`
- 인자: `https://github.example.com/acme/shop-api/pull/88`
- 원격 URL: `https://github.example.com/acme/shop-api.git` (현재 브랜치의 upstream 원격 `origin`)
- 저장소 대조 헬퍼 출력: `github.example.com/acme/shop-api 88` (종료 코드 0)
- PR: #88 `refactor: 장바구니 모듈의 함수 순서를 계산 먼저로 바꾼다`
- `headRefOid`: `e8a0c2e4b6d8f0a2c4e6b8d0f2a4c6e8b0d2f4a7` (diff를 받은 뒤 다시 조회한 값도 같다)
- `baseRefOid`: `4c6e8a0c2e4b6d8f0a2c4e6b8d0f2a4c6e8b0d29` (diff를 받은 뒤 다시 조회한 값도 같다)
- PR의 커밋 수: 1 (`gh api` PR 조회 응답의 `commits`)
- 연결 이슈: 없음 (PR 본문에 이슈 참조가 없고 `closingIssuesReferences`는 빈 배열)

## PR 본문

```markdown
### 장바구니 모듈의 함수 순서를 계산 먼저로 바꾼다

**목적·범위**
- `app/cart.py`에서 계산 함수를 앞에, 입력 해석 함수 `parse_qty`를 뒤에 둔다. 함수 본문은 바꾸지 않는다.
- 모듈 설명 문자열을 내용에 맞게 고친다.
```

## 커밋 메시지

```
3e5a7c9 refactor: 장바구니 모듈의 함수 순서를 계산 먼저로 바꾼다
```

## diff (`gh pr diff`)

```diff
diff --git a/app/cart.py b/app/cart.py
index 6b5a4c3..1d2e3f4 100644
--- a/app/cart.py
+++ b/app/cart.py
@@ -1,11 +1,6 @@
-"""장바구니 계산."""
+"""장바구니 계산과 입력 해석."""
 
 
-def parse_qty(text):
-    """수량 문자열을 정수로 바꾼다."""
-    return int(text)
-
-
 def line_total(item):
     return item.price * item.qty
 
@@ -13,3 +8,8 @@ def line_total(item):
 def cart_total(items):
     """장바구니 합계. 품목마다 가격 × 수량을 더한다."""
     return sum(item.price for item in items)
+
+
+def parse_qty(text):
+    """수량 문자열을 정수로 바꾼다."""
+    return int(text)
```

## 주변 코드 (`headRefOid` 커밋의 파일)

### `app/cart.py`

```python
"""장바구니 계산과 입력 해석."""


def line_total(item):
    return item.price * item.qty


def cart_total(items):
    """장바구니 합계. 품목마다 가격 × 수량을 더한다."""
    return sum(item.price for item in items)


def parse_qty(text):
    """수량 문자열을 정수로 바꾼다."""
    return int(text)
```

### `app/cart_api.py` (변경 파일 아님)

```python
"""장바구니 API."""

from app.cart import cart_total, parse_qty


def add_item(request, cart):
    qty = parse_qty(request.form["qty"])
    cart.add(request.form["item_id"], qty)
    return {"items": len(cart.items), "total": cart_total(cart.items)}
```

### `app/cart_store.py` (변경 파일 아님)

```python
"""장바구니 저장."""

from app.catalog import price_of


class CartItem:
    def __init__(self, item_id, qty):
        self.item_id = item_id
        self.price = price_of(item_id)
        self.qty = qty


class Cart:
    def __init__(self):
        self.items = []

    def add(self, item_id, qty):
        self.items.append(CartItem(item_id, qty))
```

### `app/checkout.py` (변경 파일 아님)

```python
"""결제 금액 계산."""

from app.cart import line_total


def charge_amount(cart):
    """카드로 청구할 금액. 장바구니 품목마다 line_total을 더한다."""
    return sum(line_total(item) for item in cart.items)
```

## 주변 코드 검색 (`headRefOid` 커밋에서 `git grep -n`)

```
$ git grep -n 'parse_qty\|cart_total\|line_total' e8a0c2e4b6d8f0a2c4e6b8d0f2a4c6e8b0d2f4a7
e8a0c2e4b6d8f0a2c4e6b8d0f2a4c6e8b0d2f4a7:app/cart.py:4:def line_total(item):
e8a0c2e4b6d8f0a2c4e6b8d0f2a4c6e8b0d2f4a7:app/cart.py:8:def cart_total(items):
e8a0c2e4b6d8f0a2c4e6b8d0f2a4c6e8b0d2f4a7:app/cart.py:13:def parse_qty(text):
e8a0c2e4b6d8f0a2c4e6b8d0f2a4c6e8b0d2f4a7:app/cart_api.py:3:from app.cart import cart_total, parse_qty
e8a0c2e4b6d8f0a2c4e6b8d0f2a4c6e8b0d2f4a7:app/cart_api.py:7:    qty = parse_qty(request.form["qty"])
e8a0c2e4b6d8f0a2c4e6b8d0f2a4c6e8b0d2f4a7:app/cart_api.py:9:    return {"items": len(cart.items), "total": cart_total(cart.items)}
e8a0c2e4b6d8f0a2c4e6b8d0f2a4c6e8b0d2f4a7:app/checkout.py:3:from app.cart import line_total
e8a0c2e4b6d8f0a2c4e6b8d0f2a4c6e8b0d2f4a7:app/checkout.py:8:    return sum(line_total(item) for item in cart.items)
```
