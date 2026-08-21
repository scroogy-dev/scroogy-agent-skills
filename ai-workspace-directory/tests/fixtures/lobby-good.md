> last updated: 2026-08-13
> SSoT: 소스 코드. 이 파일은 라우터일 뿐 진실의 원천이 아니다.

## 정체성

결제·정산 서비스를 구성하는 repo들을 모아 둔 워크스페이스입니다.
각 repo의 상세는 해당 repo 안내도에 있으며, 이 파일은 어느 repo로 갈지만 정합니다.

## Repos

| path | domain | keywords | status |
|------|--------|----------|--------|
| payment-api | 결제 요청·승인 처리 API | 결제, 승인, PG 연동 | active |
| settlement-batch | 정산 배치 | 정산, 배치, 마감 | active |
| legacy-billing | 구 청구 시스템 | 청구, 레거시 | archived |

## 라우팅 규칙

- 결제·승인·PG → `payment-api`
- 정산·마감·배치 → `settlement-batch`

## 공통 규약

- 커밋·PR 규칙 — 본문은 `payment-api/.ai/10_rules/`에
- 로깅 포맷 — 본문은 사내 위키 표준 문서에

## Why 진입점

- 결제 재시도 정책 → `payment-api/.ai/40_domain/policies/`
- 정산 마감 시각 결정 → `settlement-batch/.ai/50_adr/active/`

## 에이전트 운영 지침

### 진입 절차 (질의 → 답변)

1. 사용자 질의에서 도메인/키워드를 추출한다.
2. `Repos` 표의 `keywords`와 `라우팅 규칙`을 매칭해 후보 repo를 정한다.
3. 후보 repo의 `status`에 따라 분기한다.
   - `active` → `<path>/.ai/AI-CONTEXT.md` (repo 안내도)로 진입한다.
   - `placeholder` → 안내도 없음. repo의 소스 코드만 SSoT로 사용한다.
   - `archived` → 자동 진입 금지. 사용자 확인 후에만 답변한다.
4. 답변 직전 정보 충돌 시 우선순위: 소스 코드 > 각 repo 안내도 > 이 안내도(상위 워크스페이스).

### 작성 규칙 (이 파일을 손볼 때)

- 도메인 본문·코드 스니펫·repo 상세 목차를 이 파일에 넣지 않는다.
- 이 안내도는 라우터다. 본문 작성이 필요하면 해당 repo의 `.ai/`로 보낸다.
