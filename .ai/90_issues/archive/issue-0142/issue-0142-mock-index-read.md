# 리뷰 결과

🔴 변경 요청(REQUEST CHANGES)

<details>
<summary>최종 의견 펼치기</summary>

- 커밋될 내용 기준으로 알림은 한 번도 발송되지 않고 주문 내보내기는 호출마다 실패하므로, 두 원인(`attempts = RETRY_LIMIT`, 커밋될 `batch_size = 0`)을 고친 뒤 다시 리뷰하세요.
- 작업 트리의 `app/notify.py`(skip-worktree 표시 경로)와 `config/batch.ini`(내용 변환 필터)는 커밋될 내용과 달라 로컬 실행으로는 두 결함이 드러나지 않습니다.
- 알림 재시도 변경은 커밋 메시지에 설명이 없으니, 인덱스에 남은 `app/notify.py` 변경이 의도한 것인지 작성자가 확인하세요.

</details>

## 요약

- 비즈니스 리뷰: 🔴 보완 필요(FAIL)
- 테크 리뷰: 🔴 보완 필요(FAIL)
- 검토 파일: 2개
- 코드 레벨 검증: 읽은 파일 2개 · 읽지 않은 파일 0개
- 변경 전부터 있던 결함: 0건 (판정 산출 제외)

| 카테고리 | 건수 | 상태 |
|----------|------|------|
| 기능 | 0 | 🟢 통과(PASS) |
| 아키텍처 | 0 | 🟢 통과(PASS) |
| 버그 | 높음(HIGH) 2 · 중간(MEDIUM) 1 | 🔴 보완 필요(FAIL) |
| 보안 | 0 | 🟢 통과(PASS) |
| 코드품질 | 0 | 🟢 통과(PASS) |
| 성능 | 0 | 🟢 통과(PASS) |
| 테스트 | 낮음(LOW) 1 | 🟢 통과(PASS) |

## PR 본문 대조

해당 없음

## 비즈니스 리뷰

**🔴 높음(HIGH) 알림이 한 번도 발송되지 않아 "최소 한 번 발송" 정책을 어긴다**

`send_with_retry`의 시도 횟수가 `RETRY_LIMIT`로 바뀌어, 커밋될 값 `RETRY_LIMIT = 0`에서는 발송을 한 번도 시도하지 않습니다. 정책은 첫 발송 1회와 실패 시 재시도 `RETRY_LIMIT`회이므로 `attempts = 1 + RETRY_LIMIT`로 되돌리세요.

<details>
<summary>근거 펼치기</summary>

- 영향 축: 스펙·기능 달성 차단 / 발생확률 축: 통상 사용
- 참조 문서: `.ai/40_domain/specs/notification.md`(발췌)의 "알림은 요청마다 최소 한 번 발송을 시도한다", "발송에 실패하면 `RETRY_LIMIT`번까지 다시 시도한다"
- 코드 위치: `app/notify.py` `send_with_retry`의 추가 줄 `+    attempts = RETRY_LIMIT` (patch `@@ -8,7 +8,7 @@`)
- 커밋될 `RETRY_LIMIT`: patch에 나오지 않은 줄이라 merge-base 커밋의 파일에서 내용으로 찾았습니다(`RETRY_LIMIT = 0  # 추가 재시도 횟수. 0이면 한 번만 보낸다`). 이 경로는 skip-worktree 표시 경로이며 인덱스 내용(`git show ":0:app/notify.py"`)도 같은 값입니다.
- `RETRY_LIMIT`가 1 이상이어도 총 시도가 `RETRY_LIMIT`회라 재시도는 정책보다 1회 적습니다.
- 작업 트리의 `RETRY_LIMIT = 3`, `attempts = 1 + RETRY_LIMIT`는 수집한 내용과 달라 판단에 쓰지 않았습니다.

</details>

**🔴 높음(HIGH) 커밋될 묶음 크기가 0이라 배포된 주문 내보내기가 묶음을 나누지 못한다**

묶음 크기를 `config/batch.ini`의 `batch_size`에서 읽는 방식은 명세와 맞지만, 저장소에 커밋될 값이 `batch_size = 0`이라 배포에서 내보내기가 동작하지 않습니다. 저장소에 커밋되는 `batch_size`를 양수로 고치세요. 작업 트리의 `batch_size = 50`은 내용 변환 필터가 스테이징할 때 되돌리므로 커밋에 들어가지 않습니다.

<details>
<summary>근거 펼치기</summary>

- 영향 축: 스펙·기능 달성 차단 / 발생확률 축: 통상 사용
- 참조 문서: `.ai/40_domain/specs/order-export.md`(발췌)의 "주문 내보내기는 주문 ID 목록을 묶음으로 나눠 처리한다", "묶음 크기는 `config/batch.ini`의 `batch_size`로 정하며, 저장소에 커밋된 값이 배포에 그대로 쓰인다"
- 코드 위치: `app/export_job.py` `plan_batches`의 추가 줄 `+    size = int(load_ini("config/batch.ini")["batch_size"])`
- 커밋될 `config/batch.ini`: 변경 파일 목록에 없으므로 merge-base 커밋의 파일이 수집한 내용입니다(`batch_size = 0`). 작업 트리의 `batch_size = 50`은 `filter=localvals`의 clean 필터가 기본값 줄로 되돌리므로 수집한 내용과 다릅니다.
- 변경 전에는 코드의 `size = 100`을 써서 이 설정값을 읽지 않았습니다. 이번 변경이 0을 배포 경로에 올렸습니다.

</details>

## 테크 리뷰

### 버그 — 🔴 보완 필요(FAIL), 3건

**🔴 높음(HIGH) `send_with_retry`가 `RETRY_LIMIT`를 총 시도 횟수로 써서 기본값에서 발송을 시도하지 않는다**

`RETRY_LIMIT`는 추가 재시도 횟수인데 변경 줄이 이를 총 시도 횟수로 써서, 커밋될 값 0에서 `range(0)`이 되어 `send`를 부르지 않고 `False`를 돌려줍니다. 지운 줄 `attempts = 1 + RETRY_LIMIT`를 되살리세요.

<details>
<summary>근거 펼치기</summary>

- 영향 축: 스펙·기능 달성 차단 / 발생확률 축: 통상 사용
- 코드 위치: `app/notify.py` patch `@@ -8,7 +8,7 @@`의 삭제 줄 `-    attempts = 1 + RETRY_LIMIT`, 추가 줄 `+    attempts = RETRY_LIMIT`
- 확인 관점: 경계값(0), 호출하는 쪽과 받는 쪽의 약속 불일치(값의 뜻). 상수 정의의 주석 "추가 재시도 횟수. 0이면 한 번만 보낸다"와 변경 줄의 쓰임이 어긋납니다.
- 지운 동작(첫 발송 1회)은 다른 위치에 남아 있지 않습니다. `send_with_retry`의 나머지 줄(merge-base 커밋의 파일)은 반복문 밖에서 `send`를 부르지 않습니다.
- 나머지 줄 `RETRY_LIMIT = 0`은 merge-base 커밋의 파일에서 내용으로 찾았고, skip-worktree 표시 경로라 인덱스 내용(`git show ":0:app/notify.py"`)으로도 같은 값을 확인했습니다. 작업 트리의 `RETRY_LIMIT = 3`·`attempts = 1 + RETRY_LIMIT`는 수집한 내용과 달라 쓰지 않았습니다.
- 호출 흐름: `send_with_retry(send, message)` → `for _ in range(0)` 본문 미실행 → `return False`

실패 시나리오: 커밋될 `RETRY_LIMIT = 0`에서 `send_with_retry`를 부르면 `send`를 한 번도 부르지 않고 `False`를 돌려줘 모든 알림이 발송되지 않는다.

</details>

**🔴 높음(HIGH) 커밋될 `batch_size = 0`으로 `plan_batches`가 호출마다 `ValueError`를 낸다**

변경 줄이 `config/batch.ini`에서 읽은 값을 검증 없이 `range`의 간격으로 쓰는데, 커밋될 값이 0이라 `range(0, len(order_ids), 0)`이 `ValueError: range() arg 3 must not be zero`를 냅니다. 커밋될 `batch_size`를 양수로 고치고, `size`가 1 이상이 아니면 설정 오류를 알리는 예외를 내세요.

<details>
<summary>근거 펼치기</summary>

- 영향 축: 스펙·기능 달성 차단 / 발생확률 축: 통상 사용
- 코드 위치: `app/export_job.py` `plan_batches`의 삭제 줄 `-    size = 100`, 추가 줄 `+    size = int(load_ini("config/batch.ini")["batch_size"])`
- 주변 코드: `app/config.py`의 `load_ini`는 `[export]` 절을 문자열 값의 dict로 돌려줍니다(merge-base 커밋의 파일). `int("0")`은 0입니다.
- `config/batch.ini`의 수집한 내용: 변경 파일 목록에 없어 merge-base 커밋의 파일(`batch_size = 0`)입니다. 작업 트리의 `batch_size = 50`은 clean 필터 `localvals`가 스테이징할 때 되돌리므로 쓰지 않았습니다.
- 확인 관점: 경계값. `order_ids`가 비어 있어도 `range(0, 0, 0)`이 같은 예외를 내고, 값이 음수면 `range`가 빈 목록을 내 주문이 오류 없이 빠집니다.

실패 시나리오: 커밋된 `batch_size = 0`으로 배포한 뒤 주문 내보내기를 실행하면 `plan_batches`가 주문 목록과 상관없이 `ValueError`를 내 내보내기가 전부 실패한다.

</details>

**🟡 중간(MEDIUM) 설정 파일을 현재 디렉토리 기준 상대 경로로 읽어 실행 위치에 따라 `KeyError`로 실패한다 (확인 필요)**

`load_ini("config/batch.ini")`는 프로세스의 현재 디렉토리 기준으로 파일을 찾고, `load_ini`는 `parser.read`가 파일을 읽지 못해도 확인하지 않아 `parser["export"]`에서 `KeyError: 'export'`가 납니다. 경로를 모듈 위치나 설정으로 정하고, 파일을 읽지 못하면 경로를 담은 오류를 내세요.

<details>
<summary>근거 펼치기</summary>

- 영향 축: 스펙·기능 달성 차단 / 발생확률 축: 특수 조건·엣지
- 확인하지 못한 사유: 성립 여부가 실행 시점의 값(내보내기 작업을 실행하는 프로세스의 현재 디렉토리)에 달려 있어 수집한 내용으로 확인할 수 없습니다.
- 코드 위치: `app/export_job.py`의 추가 줄 `+    size = int(load_ini("config/batch.ini")["batch_size"])`, `app/config.py` `load_ini`의 `parser.read(path, encoding="utf-8")`와 `return dict(parser["export"])` (merge-base 커밋의 파일)
- 확인 관점: 실패한 호출의 결과를 확인하지 않고 쓰는 경로. `ConfigParser.read`는 없는 파일을 건너뛰고 읽은 파일 목록을 돌려주는데 `load_ini`는 이 반환값을 보지 않습니다.
- `load_ini`는 바뀌지 않았지만 내보내기가 이 함수를 부르는 경로를 이번 변경이 새로 만들었으므로 변경 전부터 있던 결함으로 보지 않았습니다.

실패 시나리오: 저장소 루트가 아닌 디렉토리에서 내보내기 작업을 실행하면 `config/batch.ini`를 찾지 못해 `plan_batches`가 `KeyError: 'export'`를 내고 내보내기가 실패한다.

</details>

### 테스트 — 🟢 통과(PASS), 1건

**🟢 낮음(LOW) 시도 횟수와 묶음 크기를 바꾼 변경에 테스트가 없다**

변경 파일 목록에 테스트 파일이 없어, 위 두 결함(시도 0회, 간격 0)을 잡을 테스트가 이번 변경에 함께 오지 않았습니다. `RETRY_LIMIT = 0`에서 `send`가 한 번 불리는지, `batch_size`가 0·음수일 때 `plan_batches`가 설정 오류를 내는지 확인하는 테스트를 더하세요.

<details>
<summary>근거 펼치기</summary>

- 영향 축: 기술 품질 의견 / 발생확률 축: 통상 사용
- 근거: 변경 파일 목록은 `app/export_job.py`, `app/notify.py` 두 개입니다.
- 작업 트리의 `config/batch.ini`는 필터 때문에 50이라, 실제 설정 파일을 읽는 테스트는 로컬에서 통과합니다. 설정값을 주입해 0·음수를 확인해야 결함을 잡습니다.

</details>

## 변경 전부터 있던 결함

발견 없음
