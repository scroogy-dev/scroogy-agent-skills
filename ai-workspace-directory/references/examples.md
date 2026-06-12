# 출력 형식 템플릿과 완성 예시

> `ai-workspace-directory` 스킬의 참조 문서입니다.
> `update` 모드의 출력 형식 템플릿과 init/update 완성 예시를 담습니다.

## 목차

- [출력 형식 템플릿 (update 모드)](#출력-형식-템플릿-update-모드)
  - [update-1단계: 진단 리포트](#update-1단계-진단-리포트)
  - [update-2단계: 재구성된 로비 전문](#update-2단계-재구성된-로비-전문)
  - [update-3단계: floor 이동 후보 목록](#update-3단계-floor-이동-후보-목록)
- [완성 예시](#완성-예시)
  - [init 모드 예시](#init-모드-예시)
  - [update 모드 예시](#update-모드-예시)

## 출력 형식 템플릿 (update 모드)

### update-1단계: 진단 리포트

```markdown
## 진단 리포트 (update-1단계)

### SSoT 위배
- [발견] <위배 패턴>: <발견 위치> — <발췌 또는 요약>
- [없음] <검사 항목> — 깨끗함

### 로비 역할 위배
- [발견] 도메인 본문: 라인 45-78 ("결제 트랜잭션 상태는...") — floor `api-server`로 이동 후보
- [없음] 코드 스니펫

### drift 진단
| floor | 로비 status | 디스크 안내도 | 디스크 디렉토리 | 판정 |
|-------|------------|--------------|----------------|------|
| api-server | active | 존재 | 존재 | 정상 |
| mobile-app | active | 없음 | 존재 | drift: placeholder 전환 |
| infra | (없음) | 존재 | 존재 | drift: 등록 필요 |
| legacy-web | archived | (검사 제외) | (검사 제외) | 검사 제외 |

### 형식 위배
- [위배] 본문 첫 줄이 last updated 형식이 아님 → 자동 갱신 예정
- [위배] Repos 테이블에 `owner` 열이 추가됨 → 정규화 예정
```

### update-2단계: 재구성된 로비 전문

````markdown
## 재구성된 로비 .ai/AI-CONTEXT.md (update-2단계)

> 아래는 새 본문 전문입니다. 검토 후 승인하시면 파일에 기록합니다.

```markdown
> last updated: YYYY-MM-DD
> SSoT: 소스 코드. 이 파일은 라우터일 뿐 진실의 원천이 아니다.

## 정체성
...

## Repos
...

## 라우팅 규칙
...

## 공통 규약
...

## Why 진입점
...

## 에이전트 운영 지침

### 진입 절차 (질의 → 답변)
1. ...
2. ...
3. ...
4. ...

### 작성 규칙 (이 파일을 손볼 때)
- ...
```
````

### update-3단계: floor 이동 후보 목록

```yaml
# floor 이동 후보 목록 (update-3단계)
migration_candidates:
  - content_id: lobby-overflow-001
    target_floor: api-server
    target_location_hint: api-server/.ai/40_domain/specs/payment-domain.md
    category: domain-content
    confidence: high
    reason: 결제 도메인 본문이 로비에 포함됨. 키워드(결제, payment, 트랜잭션)가 api-server의 keywords와 일치
    source_location: lines 45-78
    excerpt: |
      결제 트랜잭션은 다음 상태를 가진다: PENDING, AUTHORIZED,
      CAPTURED, REFUNDED, FAILED. 각 상태 전이는 ...
  - content_id: lobby-overflow-002
    target_floor: unknown
    target_location_hint: null
    category: other
    confidence: low
    reason: 키워드가 어떤 floor와도 매칭되지 않음. 사용자 확인 필요
    source_location: lines 120-125
    excerpt: |
      ...
```

---

## 완성 예시

각 예시는 floor 3개(`active` / `placeholder` / `archived`)를 모두 노출해 graceful degradation을 보여줍니다.

### init 모드 예시

**상황**: ACME 결제 워크스페이스에 처음으로 로비 안내판을 만든다. 워크스페이스 루트에는 `.ai/`가 없다.

**사용자 입력**:

```yaml
building: ACME 결제 워크스페이스
identity: |
  ACME 결제 서비스를 구성하는 멀티 repo 워크스페이스.
  결제 API, 모바일 클라이언트, 레거시 웹 결제 페이지를 한 곳에서 본다.
floors:
  - path: api-server
    domain: 결제 API 서버
    keywords: [결제, payment, API, 트랜잭션, refund]
  - path: mobile-app
    domain: 모바일 결제 클라이언트
    keywords: [모바일, mobile, iOS, Android, 결제 UI]
archived:
  - path: legacy-web
```

**디스크 스캔 결과**:

| floor | `<repo>/.ai/AI-CONTEXT.md` | 결정된 `status` |
|-------|---------------------------|-----------------|
| api-server | 존재 | `active` |
| mobile-app | 없음 | `placeholder` (경고) |
| legacy-web | (검사 제외, archived 명시) | `archived` |

**산출물**: `<루트>/.ai/AI-CONTEXT.md` (신규 생성, `<루트>/.ai/` 디렉토리 함께 생성)

````markdown
> last updated: 2026-05-21
> SSoT: 소스 코드. 이 파일은 라우터일 뿐 진실의 원천이 아니다.

## 정체성

ACME 결제 서비스를 구성하는 멀티 repo 워크스페이스.
결제 API, 모바일 클라이언트, 레거시 웹 결제 페이지를 한 곳에서 본다.
이 파일은 상위 워크스페이스 안내판이며, 도메인 본문은 각 repo의 `.ai/AI-CONTEXT.md`로 라우팅한다.

## Repos

| path | domain | keywords | status |
|------|--------|----------|--------|
| api-server | 결제 API 서버 | 결제, payment, API, 트랜잭션, refund | active |
| mobile-app | 모바일 결제 클라이언트 | 모바일, mobile, iOS, Android, 결제 UI | placeholder |
| legacy-web | (보존, 더 이상 작업 없음) | — | archived |

## 라우팅 규칙

- 결제 / payment / 트랜잭션 / refund → `api-server`
- 모바일 / mobile / iOS / Android / 결제 UI → `mobile-app`
- legacy-web 관련 요청은 사용자 확인 후에만 답변 (archived).

## 공통 규약

- 커밋 메시지: 각 repo의 `.ai/10_rules/` 또는 루트 `/git-commit` 스킬 참조
- PR 정책: 각 repo의 `.ai/10_rules/` 참조
- 라이선스: 워크스페이스 루트 `LICENSE`

## Why 진입점

- 결제 도메인 결정 이력 → `api-server/.ai/50_adr/`
- 모바일 결정 이력 → `mobile-app/.ai/50_adr/` (안내도 생성 후 갱신 예정)

## 에이전트 운영 지침

### 진입 절차 (질의 → 답변)

1. 사용자 질의에서 도메인/키워드를 추출한다.
2. `Repos` 표의 `keywords`와 `라우팅 규칙`을 매칭해 후보 repo를 정한다.
3. 후보 repo의 `status`에 따라 분기한다.
   - `active` → `<path>/.ai/AI-CONTEXT.md` (repo 안내도)로 진입한다.
   - `placeholder` → 안내도 없음. repo의 **소스 코드만 SSoT**로 사용한다. 사용자에게 보강을 안내하되, `<path>/.ai/` 디렉토리 자체가 없으면 `ai-workspace [dev|doc]`로 **초기 설치**를, 있으면 `ai-workspace update`로 **갱신**을 권유한다.
   - `archived` → 자동 진입 금지. 사용자 확인 후에만 답변한다.
4. 답변 직전 정보 충돌 시 우선순위: **소스 코드 > 각 repo 안내도 > 이 안내도(상위 워크스페이스)**.

### 작성 규칙 (이 파일을 손볼 때)

- 도메인 본문·코드 스니펫·repo 상세 목차를 이 파일에 넣지 않는다.
- 이 안내도는 라우터다. 본문 작성이 필요하면 해당 repo의 `.ai/`로 보낸다.
````

**보고 출력**:

```
생성: <루트>/.ai/AI-CONTEXT.md (신규)
floor status: active 1 / placeholder 1 / archived 1

[경고] floor `mobile-app`에 안내도가 없습니다.
       해당 floor에서 `ai-workspace` 스킬을 실행해 안내도를 생성하는 것을 권장합니다.

분량 가드레일: 38줄 — 짧음 (floor 3개 기준 자연스러운 분량, 라우터 정체성 유지됨)
```

---

### update 모드 예시

**상황**: 시간이 지나면서 로비에 도메인 본문과 코드 스니펫이 섞이고, 디스크와 drift가 생겼다.

**기존 입력**: `<루트>/.ai/AI-CONTEXT.md` (오염 상태, 28줄)

````markdown
---
building: ACME 결제 워크스페이스
created: 2025-11-01
---

# ACME 결제 워크스페이스

ACME 결제 서비스 모음.

## 결제 도메인

결제 트랜잭션은 다음 상태를 가진다: PENDING, AUTHORIZED, CAPTURED, REFUNDED, FAILED.
각 상태 전이는 idempotency key를 통해 보장되며, 동일 키로 재요청 시 같은 결과를 반환한다.

```python
def transition(state, event):
    if state == "PENDING" and event == "authorize":
        return "AUTHORIZED"
    ...
```

## Floors

| path | domain | keywords | owner | status |
|------|--------|----------|-------|--------|
| api-server | 결제 API | 결제, payment | @alice | active |
| legacy-web | 옛 웹 | legacy | @bob | active |
````

**디스크 스캔 결과**:

| 디스크 floor | `<repo>/.ai/AI-CONTEXT.md` | 로비 등록 여부 | drift 판정 |
|-------------|---------------------------|----------------|------------|
| api-server | 존재 | 등록됨 | 정상 |
| mobile-app | 존재 | **미등록** | drift: 로비 `Repos`에 추가 필요 |
| legacy-web | 없음 | 등록됨 (`active`) | drift: `placeholder` 전환 필요 |

#### update-1단계: 진단 리포트

```markdown
## 진단 리포트 (update-1단계)

### SSoT 위배
- [발견] 도메인 본문: 라인 11-12 ("결제 트랜잭션은 다음 상태를...") — `api-server`로 이동 후보
- [발견] 코드 스니펫: 라인 14-19 (Python `transition` 함수) — `api-server`로 이동 후보
- [없음] floor 상세 목차
- [없음] floor 정책 본문 중복

### 로비 역할 위배
- [발견] 도메인 본문 (라인 11-12)
- [발견] 코드 스니펫 (라인 14-19)
- [없음] floor 상세 목차
- [없음] 비대 (28줄 < 250줄)

### drift 진단
| floor | 로비 status | 디스크 안내도 | 디스크 디렉토리 | 판정 |
|-------|------------|--------------|----------------|------|
| api-server | active | 존재 | 존재 | 정상 |
| mobile-app | (없음) | 존재 | 존재 | drift: 등록 필요 |
| legacy-web | active | 없음 | 존재 | drift: placeholder 전환 |

### 형식 위배
- [위배] YAML frontmatter 존재 (라인 1-4) → 제거 예정
- [위배] 본문 첫 줄이 `> last updated:` 형식 아님 → 자동 갱신 예정
- [위배] 본문 두 번째 줄 SSoT 선언 누락 → 표준 문구 자동 삽입 예정
- [위배] 구버전 `## Floors` 섹션명 사용 → `## Repos`로 정규화 예정
- [위배] Repos 테이블에 `owner` 열 추가 → 4열로 정규화 예정
- [위배] `에이전트 운영 지침`에 `### 진입 절차` 4단계 누락 → 표준 골격 삽입 예정
- [위배] `# ACME 결제 워크스페이스` H1 헤더 사용 → H2 표준 섹션 구조로 재정렬 예정
```

#### update-2단계: 재구성된 로비 전문

````markdown
> 아래는 새 본문 전문입니다. 검토 후 승인하시면 `<루트>/.ai/AI-CONTEXT.md`에 덮어씁니다.

```markdown
> last updated: 2026-05-21
> SSoT: 소스 코드. 이 파일은 라우터일 뿐 진실의 원천이 아니다.

## 정체성

ACME 결제 서비스를 구성하는 멀티 repo 워크스페이스.
이 파일은 상위 워크스페이스 안내판이며, 도메인 본문은 각 repo의 `.ai/AI-CONTEXT.md`로 라우팅한다.

## Repos

| path | domain | keywords | status |
|------|--------|----------|--------|
| api-server | 결제 API 서버 | 결제, payment, API, 트랜잭션 | active |
| mobile-app | 모바일 결제 클라이언트 | 모바일, mobile, iOS, Android | active |
| legacy-web | (보존, 안내도 없음) | legacy | placeholder |

## 라우팅 규칙

- 결제 / payment / 트랜잭션 → `api-server`
- 모바일 / mobile → `mobile-app`
- legacy-web 관련 요청은 사용자 확인 후 진행 (placeholder, 안내도 부재)

## 공통 규약

- 라이선스: 워크스페이스 루트 `LICENSE`
- 커밋·PR 정책: 각 repo의 `.ai/10_rules/` 참조

## Why 진입점

- 결제 도메인 결정 이력 → `api-server/.ai/50_adr/`
- 모바일 결정 이력 → `mobile-app/.ai/50_adr/`

## 에이전트 운영 지침

### 진입 절차 (질의 → 답변)

1. 사용자 질의에서 도메인/키워드를 추출한다.
2. `Repos` 표의 `keywords`와 `라우팅 규칙`을 매칭해 후보 repo를 정한다.
3. 후보 repo의 `status`에 따라 분기한다.
   - `active` → `<path>/.ai/AI-CONTEXT.md` (repo 안내도)로 진입한다.
   - `placeholder` → 안내도 없음. repo의 **소스 코드만 SSoT**로 사용한다. `<path>/.ai/` 자체가 없으면 `ai-workspace [dev|doc]` 초기 설치를, 있으면 `ai-workspace update` 갱신을 권유한다.
   - `archived` → 자동 진입 금지. 사용자 확인 후에만 답변한다.
4. 답변 직전 정보 충돌 시 우선순위: **소스 코드 > 각 repo 안내도 > 이 안내도(상위 워크스페이스)**.

### 작성 규칙 (이 파일을 손볼 때)

- 도메인 본문·코드 스니펫·repo 상세 목차를 이 파일에 넣지 않는다.
- 이 안내도는 라우터다. 본문 작성이 필요하면 해당 repo의 `.ai/`로 보낸다.
```

이대로 `<루트>/.ai/AI-CONTEXT.md`에 덮어쓸까요? (y/N)
````

#### update-3단계: floor 이동 후보 목록

```yaml
# floor 이동 후보 목록 (update-3단계)
migration_candidates:
  - content_id: lobby-overflow-001
    target_floor: api-server
    target_location_hint: api-server/.ai/40_domain/specs/payment-states.md
    category: domain-content
    confidence: high
    reason: 결제 트랜잭션 상태 본문이 로비에 포함됨. 키워드(결제, payment, 트랜잭션)가 api-server keywords와 일치
    source_location: lines 11-12
    excerpt: |
      결제 트랜잭션은 다음 상태를 가진다: PENDING, AUTHORIZED, CAPTURED, REFUNDED, FAILED.
      각 상태 전이는 idempotency key를 통해 보장되며, 동일 키로 재요청 시 같은 결과를 반환한다.
  - content_id: lobby-overflow-002
    target_floor: api-server
    target_location_hint: api-server/.ai/40_domain/specs/payment-states.md
    category: code-snippet
    confidence: high
    reason: 결제 상태 전이 함수 코드. 인접한 도메인 본문(001)과 함께 이동되어야 함
    source_location: lines 14-19
    excerpt: |
      def transition(state, event):
          if state == "PENDING" and event == "authorize":
              return "AUTHORIZED"
          ...
```

#### update-4단계: 보고

```
파일 경로: <루트>/.ai/AI-CONTEXT.md
파일 변경: 사용자 승인 대기 (미적용)

진단 결과:
- SSoT 위배 2건 (도메인 본문 1, 코드 스니펫 1)
- 형식 위배 6건 (frontmatter, last updated 누락, SSoT 선언 누락, `Floors`→`Repos` 마이그레이션, Repos 5열, 진입 절차 누락, H1 헤더)
- drift 2건 (mobile-app 신규 등록, legacy-web placeholder 전환)

분량 가드레일: 재구성 후 30줄 — 짧음 (floor 3개 기준 정상)

placeholder 전환: legacy-web (안내도 부재). `ai-workspace` 스킬로 생성 권장.

이동 후보: 2건 (모두 api-server 대상, target_floor: unknown 0건)
```
