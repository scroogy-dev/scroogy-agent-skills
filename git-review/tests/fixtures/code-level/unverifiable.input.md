# 입력: unverifiable

## 대상

- 모드: `PR 모드`
- 인자: `#57`
- 원격 URL: `https://github.example.com/acme/shop-api.git` (현재 브랜치의 upstream 원격 `origin`)
- 저장소 대조 헬퍼 출력: `github.example.com/acme/shop-api 57` (종료 코드 0)
- PR: #57 `feat: 주문 결제 함수 추가`
- `headRefOid`: `5d7b9f1a3c5e7092b4d6f8a0c2e4b6d8f0a2c4e6` (diff를 받은 뒤 다시 조회한 값도 같다)
- `baseRefOid`: `0e2c4a6f8b1d3e5c7a9f1b3d5c7e9a1f3b5d7c92` (diff를 받은 뒤 다시 조회한 값도 같다)
- PR의 커밋 수: 2 (`gh api` PR 조회 응답의 `commits`)
- 연결 이슈: 없음 (PR 본문에 이슈 참조가 없고 `closingIssuesReferences`는 빈 배열)

## PR 본문

```markdown
### 주문 결제 함수 추가

**목적·범위**
- 주문 금액을 결제 대행사 SDK(`paygate_sdk`)로 결제하고 주문을 결제 완료로 바꾸는 `pay`를 더한다.
```

## 커밋 메시지

```
e1f2a3b feat: 주문 결제 함수 pay를 더한다

f2a3b4c test: pay의 결제 완료 처리를 확인한다
```

## diff (`gh pr diff`)

```diff
diff --git a/app/payments.py b/app/payments.py
new file mode 100644
index 0000000..4c6e8a0
--- /dev/null
+++ b/app/payments.py
@@ -0,0 +1,10 @@
+"""주문 결제."""
+
+from paygate_sdk import charge
+
+
+def pay(order):
+    """주문 금액을 결제하고 주문을 결제 완료로 바꾼다."""
+    result = charge(order.total, order.card_token)
+    order.mark_paid(result.transaction_id)
+    return result
diff --git a/tests/test_payments.py b/tests/test_payments.py
new file mode 100644
index 0000000..7a9c1e3
--- /dev/null
+++ b/tests/test_payments.py
@@ -0,0 +1,12 @@
+from types import SimpleNamespace
+from unittest import mock
+
+from app.payments import pay
+
+
+def test_pay_marks_order_paid():
+    order = mock.Mock(total=1000, card_token="tok_1")
+    approved = SimpleNamespace(transaction_id="tx_1")
+    with mock.patch("app.payments.charge", return_value=approved):
+        pay(order)
+    order.mark_paid.assert_called_once_with("tx_1")
```

## 주변 코드 (`headRefOid` 커밋의 파일)

변경 파일 둘은 diff가 전체 내용이다(새 파일).

### `pyproject.toml` (변경 파일 아님, 발췌)

```toml
[tool.poetry.dependencies]
python = "^3.11"
paygate-sdk = "^4.2"
```

`paygate_sdk`는 외부 패키지라 저장소에 소스가 없다. 저장소 안에서 `charge`를 정의하거나 부르는 곳은 위 diff뿐이다.
