# 입력: clean

## 대상

- 모드: `PR 모드`
- 인자: `https://github.example.com/acme/shop-api/pull/61/files`
- 원격 URL: `https://github.example.com/acme/shop-api.git` (현재 브랜치의 upstream 원격 `origin`)
- 저장소 대조 헬퍼 출력: `github.example.com/acme/shop-api 61` (종료 코드 0)
- PR: #61 `chore: 환영 문구에 상점 이름을 넣는다`
- `headRefOid`: `9b1d3f5a7c9e1b3d5f7a9c1e3b5d7f9a1c3e5b70` (diff를 받은 뒤 다시 조회한 값도 같다)
- `baseRefOid`: `2f4a6c8e0b2d4f6a8c0e2b4d6f8a0c2e4b6d8f13` (diff를 받은 뒤 다시 조회한 값도 같다)
- PR의 커밋 수: 1 (`gh api` PR 조회 응답의 `commits`)
- 연결 이슈: 없음 (PR 본문에 이슈 참조가 없고 `closingIssuesReferences`는 빈 배열)

## PR 본문

```markdown
### 환영 문구에 상점 이름을 넣는다

**목적·범위**
- 첫 화면의 환영 문구를 "Welcome to Acme Shop"으로 바꾼다.

**완료의 정의 대조**
- 충족 2/2
```

## 커밋 메시지

```
0a1b2c3 chore: 환영 문구에 상점 이름을 넣는다
```

## diff (`gh pr diff`)

```diff
diff --git a/app/messages.py b/app/messages.py
index 4d6f8a0..6e8a0c2 100644
--- a/app/messages.py
+++ b/app/messages.py
@@ -1,4 +1,4 @@
 """사용자에게 보이는 문구."""
 
-WELCOME = "Welcome"
+WELCOME = "Welcome to Acme Shop"
 GOODBYE = "See you again"
diff --git a/tests/test_messages.py b/tests/test_messages.py
index 8a0c2e4..a0c2e4b 100644
--- a/tests/test_messages.py
+++ b/tests/test_messages.py
@@ -1,8 +1,8 @@
 from app.messages import GOODBYE, WELCOME
 
 
-def test_welcome():
-    assert WELCOME == "Welcome"
+def test_welcome_mentions_shop():
+    assert WELCOME == "Welcome to Acme Shop"
 
 
 def test_goodbye():
```

## 주변 코드 (`headRefOid` 커밋의 파일)

### `app/messages.py`

```python
"""사용자에게 보이는 문구."""

WELCOME = "Welcome to Acme Shop"
GOODBYE = "See you again"
```

### `tests/test_messages.py`

```python
from app.messages import GOODBYE, WELCOME


def test_welcome_mentions_shop():
    assert WELCOME == "Welcome to Acme Shop"


def test_goodbye():
    assert GOODBYE == "See you again"
```

## 주변 코드 검색 (`headRefOid` 커밋에서 `git grep -n`)

```
$ git grep -n 'WELCOME' 9b1d3f5a7c9e1b3d5f7a9c1e3b5d7f9a1c3e5b70
9b1d3f5a7c9e1b3d5f7a9c1e3b5d7f9a1c3e5b70:app/messages.py:3:WELCOME = "Welcome to Acme Shop"
9b1d3f5a7c9e1b3d5f7a9c1e3b5d7f9a1c3e5b70:app/views.py:8:    return render("home.html", greeting=WELCOME)
9b1d3f5a7c9e1b3d5f7a9c1e3b5d7f9a1c3e5b70:tests/test_messages.py:1:from app.messages import GOODBYE, WELCOME
9b1d3f5a7c9e1b3d5f7a9c1e3b5d7f9a1c3e5b70:tests/test_messages.py:5:    assert WELCOME == "Welcome to Acme Shop"
```
