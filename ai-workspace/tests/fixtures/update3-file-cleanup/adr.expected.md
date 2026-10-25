# 기대 결과: adr

| 파일 | 이동 위치 | 근거 |
|------|-----------|------|
| `50_adr/index.md` | 루트 유지 | 루트 상주 파일(각 디렉토리의 `index.md`)은 이동·`legacy/` 대상에서 제외 |
| `50_adr/0001-session-store-memory.md` | `superseded/` | `50_adr/` 행: 상태 줄 값 `대체(ADR 0003)` |
| `50_adr/0002-nightly-batch.md` | `superseded/` | `50_adr/` 행: 상태 줄 값 `폐기(이슈 #12)` |
| `50_adr/0003-session-store-redis.md` | `active/` | `50_adr/` 행: 상태 줄 값 `유효` |
| `50_adr/0004-review-cycle.md` | `active/` | `50_adr/` 행: 상태 줄이 없으면 `active/`. 본문의 `superseded` 낱말은 판정에 쓰지 않는다(옛 키워드 판정이면 `superseded/`로 잘못 옮겨지는 회귀 반례) |
