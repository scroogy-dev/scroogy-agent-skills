# 입력: adr

## 50_adr/ 루트

### index.md

```markdown
# 50_adr 인덱스

이 디렉토리는 프로젝트의 주요 의사결정 기록(Architecture Decision Records)을 보관합니다.
```

### 0001-session-store-memory.md

```markdown
# ADR: 세션 저장소로 서버 메모리를 쓴다

- **상태**: 대체(ADR 0003)

## 결정

- 로그인 세션을 애플리케이션 서버 메모리에 둔다.

## 근거

- 서버가 한 대라 별도 저장소가 필요 없었다.
```

### 0002-nightly-batch.md

```markdown
# ADR: 정산은 야간 배치로 처리한다

- **상태**: 폐기(이슈 #12)

## 결정

- 매일 02시에 전날 거래를 모아 정산한다.

## 근거

- 2026-05-10 실시간 정산 도입으로 배치를 없앴고 대체 결정은 없다 (이슈 #12).
```

### 0003-session-store-redis.md

```markdown
# ADR: 세션 저장소로 Redis를 쓴다

- **상태**: 유효

## 결정

- 로그인 세션을 Redis에 둔다.

## 근거

- 서버를 여러 대로 늘리면서 세션을 공유해야 한다. ADR 0001의 결정 전체를 대체한다.
```

### 0004-review-cycle.md

```markdown
# ADR: 결정 기록의 수명 주기를 둔다

## 결정

- ADR 수명 주기(active/superseded)를 두고, 기존 결정을 바꾸지 않는 새 결정은 새 ADR로 쓴다.

## 근거

- 기존 ADR을 대체(superseded)하지 않고 결정을 더한 사례가 쌓였다.
```
