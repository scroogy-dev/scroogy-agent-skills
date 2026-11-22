# 리뷰 결과

🔴 변경 요청(REQUEST CHANGES)

<details>
<summary>최종 의견 펼치기</summary>

`app/export.py`에서 `finally: conn.close()`를 지워 내보내기마다 DB 연결을 닫지 않게 되었으므로, 연결 해제를 되살린 뒤 다시 리뷰를 받는 것이 좋습니다. `app/legacy_csv.py` 삭제는 `headRefOid` 커밋에서 `legacy_csv`·`to_csv_line` 참조가 없어 깨지는 참조가 없고, 경고 로그 추가는 PR 본문의 목적대로 동작합니다. CSV 값 이스케이프 누락은 이번 변경 전부터 있던 결함이라 판정에 넣지 않았으며 별도로 다루면 됩니다.

</details>

## 요약

- 비즈니스 리뷰: 🟢 통과(PASS)
- 테크 리뷰: 🔴 보완 필요(FAIL)
- 검토 파일: 2개
- 코드 레벨 검증: 읽은 파일 2개 · 읽지 않은 파일 0개
- 변경 전부터 있던 결함: 1건 (판정 산출 제외)

| 카테고리 | 건수 | 상태 |
|----------|------|------|
| 기능 | 0 | 🟢 통과(PASS) |
| 아키텍처 | 0 | 🟢 통과(PASS) |
| 버그 | 0 | 🟢 통과(PASS) |
| 보안 | 0 | 🟢 통과(PASS) |
| 코드품질 | 0 | 🟢 통과(PASS) |
| 성능 | 높음(HIGH) 1 | 🔴 보완 필요(FAIL) |
| 테스트 | 낮음(LOW) 1 | 🟢 통과(PASS) |

## PR 본문 대조

해당 없음

## 비즈니스 리뷰

참조 문서 없음: 상품 내보내기(`app/export.py`)의 CSV 형식·실패 처리와 CSV 도우미(`app/legacy_csv.py`) 삭제에 관한 소프트웨어 계약·도메인 정책 전체

발견 없음

## 테크 리뷰

### 성능 — 🔴 보완 필요(FAIL), 1건

**🔴 높음(HIGH) 내보내기가 DB 연결을 닫지 않는다**

`except OSError` 분기를 더하면서 `finally: conn.close()`를 지워, `export_products`가 성공·실패 어느 경로에서도 `db.connect()`로 연 연결을 닫지 않습니다. `try` 블록에 `except OSError`와 함께 `finally: conn.close()`를 다시 두거나, 연결을 `with` 문으로 열어 해제를 보장하세요.

<details>
<summary>근거 펼치기</summary>

영향 축: 스펙·기능 달성 차단 / 발생확률 축: 통상 사용

- 코드 위치: `app/export.py` diff 삭제 줄(변경 전 16~17행) `finally:`·`conn.close()`, 추가 줄(변경 후 16~18행) `except OSError:`·`log.warning(...)`·`raise`. 연결은 `headRefOid` 커밋의 10행 `conn = db.connect()`에서 엽니다.
- 삭제 줄 재확인: diff의 삭제 줄을 다시 읽어 지워진 동작이 연결 해제임을 확인했습니다. `headRefOid` 커밋에서 `git grep -n 'conn\.'`의 결과는 12행 `conn.fetch_all(...)` 하나뿐이라, 해제가 다른 위치로 옮겨지지 않았습니다.
- 호출 흐름: docstring에 따르면 `export_products`는 내보내기 요청마다 한 번 불립니다. 요청마다 연결이 하나씩 남고, 해제는 객체가 회수될 때 드라이버가 닫아 주는지에 맡겨집니다. 이는 보장이 아니며, `OSError` 경로에서는 다시 던진 예외의 추적 정보가 프레임을 잡고 있어 회수도 늦어집니다.
- 커밋 메시지(`2d4f6b8 feat: 상품 내보내기 실패를 경고 로그로 남긴다`)와 PR 본문 어디에도 연결 해제를 없앤다는 언급이 없어, 의도하지 않은 삭제로 보입니다.

실패 시나리오: 내보내기 요청이 연결 풀 크기만큼 쌓이면 이후 `db.connect()`가 대기하거나 실패해, 내보내기와 같은 DB를 쓰는 다른 기능이 응답하지 못한다.

</details>

### 테스트 — 🟢 통과(PASS), 1건

**🟢 낮음(LOW) 바꾼 실패 경로와 연결 해제를 확인하는 테스트가 없다**

이 PR은 `export_products`의 예외 처리를 바꿨지만 테스트 변경이 없어, 위 연결 해제 누락 같은 회귀를 막지 못했습니다. 파일 쓰기가 `OSError`로 실패할 때 경고 로그가 남고 예외가 다시 던져지는지, 성공·실패 두 경로 모두에서 연결이 닫히는지를 확인하는 테스트를 더하세요.

<details>
<summary>근거 펼치기</summary>

영향 축: 기술 품질 의견 / 발생확률 축: 통상 사용

- 코드 위치: `app/export.py` 16~18행(추가 줄). diff의 변경 파일은 `app/export.py`·`app/legacy_csv.py` 둘뿐이고 테스트 파일이 없습니다.
- `headRefOid` 커밋의 `git grep -n 'conn\.'` 결과에 테스트 파일이 나오지 않아, `conn.close` 호출을 단언하는 기존 테스트도 보이지 않습니다.

</details>

## 변경 전부터 있던 결함

**중간(MEDIUM) CSV 값을 이스케이프하지 않는다**

`f.write(f"{r['id']},{r['name']}\n")`가 값을 그대로 이어 써서, 상품 이름에 쉼표·큰따옴표·줄바꿈이 들면 그 행의 열이 밀리거나 행이 둘로 갈라집니다. 표준 `csv` 모듈의 `csv.writer`로 쓰도록 바꾸는 것을 별도로 검토하세요.

<details>
<summary>근거 펼치기</summary>

영향 축: 스펙·기능 달성 차단 / 발생확률 축: 특수 조건·엣지

- 코드 위치: `app/export.py` 15행(`headRefOid` 커밋).
- 변경 전부터 있던 것으로 본 근거: 이 줄은 diff의 문맥 줄이며 추가·수정 줄이 아닙니다. 이번 변경은 쓰기 경로나 입력 범위를 바꾸지 않아 이 결함에 닿는 경로를 새로 만들거나 넓히지 않았습니다. 지운 `legacy_csv.to_csv_line`도 이스케이프하지 않았고 쓰는 곳이 없었으므로 삭제가 영향을 주지 않습니다.

</details>
