# 입력: deleted-lines

## 대상

- 모드: `PR 모드`
- 인자: `https://github.example.com/acme/shop-api/pull/73`
- 원격 URL: `git@github.example.com:acme/shop-api.git` (현재 브랜치의 upstream 원격 `origin`)
- 저장소 대조 헬퍼 출력: `github.example.com/acme/shop-api 73` (종료 코드 0)
- PR: #73 `refactor: 쓰지 않는 CSV 도우미를 지우고 내보내기 실패를 기록한다`
- `headRefOid`: `c4e6a8b0d2f4a6c8e0b2d4f6a8c0e2b4d6f8a0c3` (diff를 받은 뒤 다시 조회한 값도 같다)
- `baseRefOid`: `6a8c0e2b4d6f8a0c2e4b6d8f0a2c4e6b8d0f2a45` (diff를 받은 뒤 다시 조회한 값도 같다)
- PR의 커밋 수: 2 (`gh api` PR 조회 응답의 `commits`)
- 연결 이슈: 없음 (PR 본문에 이슈 참조가 없고 `closingIssuesReferences`는 빈 배열)

## PR 본문

```markdown
### 쓰지 않는 CSV 도우미를 지우고 내보내기 실패를 기록한다

**목적·범위**
- 사용하는 곳이 없는 `app/legacy_csv.py`를 지운다.
- 상품 내보내기가 파일 쓰기에 실패하면 경고 로그를 남긴다.
```

## 커밋 메시지

```
1c3e5a7 refactor: 쓰지 않는 legacy_csv를 지운다

2d4f6b8 feat: 상품 내보내기 실패를 경고 로그로 남긴다
```

## diff (`gh pr diff`)

```diff
diff --git a/app/export.py b/app/export.py
index 3b5d7f9..8e0a2c4 100644
--- a/app/export.py
+++ b/app/export.py
@@ -13,5 +13,6 @@ def export_products(db, path):
         with open(path, "w", encoding="utf-8") as f:
             for r in rows:
                 f.write(f"{r['id']},{r['name']}\n")
-    finally:
-        conn.close()
+    except OSError:
+        log.warning("export failed: %s", path)
+        raise
diff --git a/app/legacy_csv.py b/app/legacy_csv.py
deleted file mode 100644
index 0a1b2c3..0000000
--- a/app/legacy_csv.py
+++ /dev/null
@@ -1,5 +0,0 @@
-"""옛 CSV 도우미."""
-
-
-def to_csv_line(values):
-    return ",".join(str(v) for v in values)
```

## 주변 코드 (`headRefOid` 커밋의 파일)

`app/legacy_csv.py`는 `headRefOid` 커밋에 없다(이 PR에서 지운 파일).

### `app/export.py`

```python
"""상품 내보내기."""

import logging

log = logging.getLogger(__name__)


def export_products(db, path):
    """상품 목록을 path에 CSV로 쓴다. 내보내기 요청마다 한 번 불린다."""
    conn = db.connect()
    try:
        rows = conn.fetch_all("SELECT id, name FROM products")
        with open(path, "w", encoding="utf-8") as f:
            for r in rows:
                f.write(f"{r['id']},{r['name']}\n")
    except OSError:
        log.warning("export failed: %s", path)
        raise
```

## 주변 코드 검색 (`headRefOid` 커밋에서 `git grep -n`)

```
$ git grep -n 'legacy_csv\|to_csv_line' c4e6a8b0d2f4a6c8e0b2d4f6a8c0e2b4d6f8a0c3
$ git grep -n 'conn\.' c4e6a8b0d2f4a6c8e0b2d4f6a8c0e2b4d6f8a0c3
c4e6a8b0d2f4a6c8e0b2d4f6a8c0e2b4d6f8a0c3:app/export.py:12:        rows = conn.fetch_all("SELECT id, name FROM products")
```
