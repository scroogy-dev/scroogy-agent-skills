# 입력: dev-source

## 안내도 머리 (`.ai/AI-CONTEXT.md`)

```markdown
# AI-CONTEXT.md

> last updated: 2026-10-23
> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.

## 프로젝트 도메인

| 항목 | 값 |
|------|----|
| domain | 온라인 강의 결제 서비스 |
| keywords | 결제, 환불, 청약 철회 |
```

## SSoT에 반영된 사실 (소스 코드)

| 위치 | 반영된 사실 |
|------|-------------|
| `src/main/java/com/example/refund/RefundPolicy.java` | 결제 후 7일 이내 미수강 강의는 전액 환불한다 |

## 후보 자료

| # | 자료 | 위치 | 내용 |
|---|------|------|------|
| C1 | PR "환불 기한 7일 도입" (머지됨) | https://github.example.com/pay/pull/42 | `RefundPolicy.java`에 7일 기한을 넣은 이유(청약 철회 기간과 일치) |
| C2 | Jira 티켓 "환불 기한 30일 제안" (기각) | https://jira.example.com/browse/PAY-88 | 30일 기한 제안. 비용 문제로 기각되어 코드에 없음 |
| C3 | 가상 법령 「예시소비자법」 제17조 | https://law.example.org/acts/17 | 계약 후 7일 이내 청약 철회를 보장하는 조항, 시행일 2026-01-01 |
