# 입력: index-read

## 대상

- 모드: `브랜치 모드` (인자 없음)
- 현재 브랜치: `feature/notify-export`
- base: `main` (`origin/HEAD`가 가리키는 브랜치)
- 2단계에서 보관한 merge-base 커밋의 해시 `mb`: `7c3e5a9b1d3f5e7a9c1b3d5f7e9a1c3b5d7f9e02`

## 브랜치 수집 헬퍼의 표준 출력

명령: `'git-review/scripts/collect-branch-changes.sh' --base "$mb"` (종료 코드 0)

```
M	app/export_job.py
M	app/notify.py

diff --git a/app/export_job.py b/app/export_job.py
index 3a5c7e9..8b0d2f4 100644
--- a/app/export_job.py
+++ b/app/export_job.py
@@ -1,7 +1,9 @@
 """주문 내보내기 작업."""
 
+from app.config import load_ini
+
 
 def plan_batches(order_ids):
     """주문 ID 목록을 batch_size 크기의 묶음으로 나눈다."""
-    size = 100
+    size = int(load_ini("config/batch.ini")["batch_size"])
     return [order_ids[i:i + size] for i in range(0, len(order_ids), size)]
diff --git a/app/notify.py b/app/notify.py
index 2c4e6a8..5d7f9b1 100644
--- a/app/notify.py
+++ b/app/notify.py
@@ -8,7 +8,7 @@ def format_message(text):
 
 
 def send_with_retry(send, message):
-    attempts = 1 + RETRY_LIMIT
+    attempts = RETRY_LIMIT
     for _ in range(attempts):
         if send(message):
             return True
```

## 커밋 메시지

명령: `git log --format='%h %s%n%n%b' "${mb}..HEAD"`

```
4b6d8f0 feat: 내보내기 묶음 크기를 설정 파일에서 읽는다

```

## 표시한 경로 조회

명령: `'git-review/scripts/collect-branch-changes.sh' --marked` (종료 코드 0)

```
S app/notify.py
```

## `app/notify.py`

### 작업 트리 내용

```python
"""알림 발송."""

RETRY_LIMIT = 3  # 추가 재시도 횟수. 0이면 한 번만 보낸다


def format_message(text):
    return text.strip()


def send_with_retry(send, message):
    attempts = 1 + RETRY_LIMIT
    for _ in range(attempts):
        if send(message):
            return True
    return False
```

### 인덱스의 내용

명령: `git show ":0:app/notify.py"`

```python
"""알림 발송."""

RETRY_LIMIT = 0  # 추가 재시도 횟수. 0이면 한 번만 보낸다


def format_message(text):
    return text.strip()


def send_with_retry(send, message):
    attempts = RETRY_LIMIT
    for _ in range(attempts):
        if send(message):
            return True
    return False
```

### merge-base 커밋의 내용

명령: `git show "${mb}:app/notify.py"`

```python
"""알림 발송."""

RETRY_LIMIT = 0  # 추가 재시도 횟수. 0이면 한 번만 보낸다


def format_message(text):
    return text.strip()


def send_with_retry(send, message):
    attempts = 1 + RETRY_LIMIT
    for _ in range(attempts):
        if send(message):
            return True
    return False
```

## `app/export_job.py`

### 작업 트리 내용

```python
"""주문 내보내기 작업."""

from app.config import load_ini


def plan_batches(order_ids):
    """주문 ID 목록을 batch_size 크기의 묶음으로 나눈다."""
    size = int(load_ini("config/batch.ini")["batch_size"])
    return [order_ids[i:i + size] for i in range(0, len(order_ids), size)]
```

## `app/config.py` (변경 파일 목록에 없음)

### 작업 트리 내용

작업 트리 내용과 merge-base 커밋의 내용이 같다.

```python
"""설정 파일 읽기."""

import configparser


def load_ini(path):
    """INI 파일의 [export] 절을 dict로 돌려준다. 값은 문자열이다."""
    parser = configparser.ConfigParser()
    parser.read(path, encoding="utf-8")
    return dict(parser["export"])
```

## `config/batch.ini` (변경 파일 목록에 없음)

이 파일에는 스테이징할 때 내용을 바꾸는 필터가 걸려 있다. `.git/info/attributes`에 `config/batch.ini filter=localvals`가 있고, `filter.localvals.clean`은 로컬에서 고친 `batch_size` 줄을 저장소의 기본값 줄로 되돌린다.

### 작업 트리 내용

```ini
[export]
batch_size = 50
```

### merge-base 커밋의 내용

명령: `git show "${mb}:config/batch.ini"`

```ini
[export]
batch_size = 0
```

## 참조 문서 발췌

비즈니스 리뷰의 참조 문서는 아래 발췌로 대신한다.

### `.ai/40_domain/specs/notification.md` (발췌)

- 알림은 요청마다 최소 한 번 발송을 시도한다.
- 발송에 실패하면 `RETRY_LIMIT`번까지 다시 시도한다.

### `.ai/40_domain/specs/order-export.md` (발췌)

- 주문 내보내기는 주문 ID 목록을 묶음으로 나눠 처리한다.
- 묶음 크기는 `config/batch.ini`의 `batch_size`로 정하며, 저장소에 커밋된 값이 배포에 그대로 쓰인다.
