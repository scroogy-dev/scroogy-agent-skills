# AI-CONTEXT.md

> last updated: 2026-07-15
> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.

## 프로젝트 도메인

| 항목 | 값 |
|------|----|
| domain | fixture 검증용 예시 서비스 |
| keywords | fixture, update4 |
| profile | doc |

---

## 프로젝트 목적

update-4 멱등 보강 검사 fixture — dev 선언 안내도를 doc 프로파일로 update하며 `## 프로젝트 규칙` 섹션은 있으나 표가 없고 인라인 규칙만 있는 안내도.

---

## 프로젝트 규칙

1. **최소 변경 원칙** — 요청된 범위만 수정합니다.
2. **커밋 전 확인** — 명시적으로 요청받지 않으면 커밋하지 않습니다.

| 파일 | 설명 | 사용 시점 |
|------|------|----------|
| `.ai/10_rules/context-loading.md`    | 작업 전 컨텍스트 확인 절차 | 문서 작업 전      |
| `.ai/10_rules/document-convention.md` | 문서 규약 (SSoT 대상 확장자·첨부 분류·우선순위·명명) | 원본 문서 작성·리뷰 시 |
| `.ai/10_rules/file-change-policy.md` | 파일 변경 규칙             | 파일 추가·삭제 시 |
| `.ai/10_rules/ide-tools.md`          | IDE 도구 우선 규칙 (IntelliJ MCP 연결 시 심볼·호출 관계·이름 변경·수정 후 검증은 IDE 도구 먼저, 연결 실패·문서·문자열 검색은 grep, 빈 결과는 grep으로 재확인) | 코드 탐색·수정 전 |
| `.ai/10_rules/testing-principles.md` | 테스트 실행 원칙 (층·수단·환경) | 테스트 작성·실행 시 |
| `.ai/10_rules/writing-principles.md` | 산출물 작성 원칙 (소스 코드 미적용) | 산출 문서·PR·이슈·리뷰 코멘트 작성 시 |

---

## 기술 스택

- 사용자 작성 내용: Kotlin, Spring Boot
