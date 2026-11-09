# AI-CONTEXT.md

> last updated: 2026-07-15
> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.

## 프로젝트 목적

update-4 멱등 보강 검사 fixture — 2열(파일·설명) 구버전 표 + 사용자 행.

---

## 프로젝트 규칙

| 파일 | 설명 | 사용 시점 |
|------|------|----------|
| `.ai/10_rules/context-loading.md`    | 작업 전 컨텍스트 확인 절차 | 코드·문서 작업 전 |
| `.ai/10_rules/ide-tools.md`          | IDE 도구 우선 규칙 (IntelliJ MCP 연결 시 심볼·호출 관계·이름 변경·수정 후 검증은 IDE 도구 먼저, 연결 실패·문서·문자열 검색은 grep, 빈 결과는 grep으로 재확인) | 코드 탐색·수정 전 |
| `.ai/10_rules/my-team-rule.md` | 팀 커스텀 규칙 | <사용 시점> |
| `.ai/10_rules/testing-principles.md` | 테스트 실행 원칙 (층·수단·환경) | 테스트 작성·실행 시 |
| `.ai/10_rules/writing-principles.md` | 산출물 작성 원칙 (소스 코드 미적용) | 산출 문서·PR·이슈·리뷰 코멘트 작성 시 |
