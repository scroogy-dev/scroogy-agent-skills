# 작업 전 컨텍스트 확인

> 이 문서는 모든 코드·문서 작업과 스킬 실행에 선행 적용됩니다.
> 이미 현재 컨텍스트에 적재된 파일은 다시 Read 하지 않습니다.

## 참조 원칙

- `30_contract/`, `40_domain/`, `50_adr/`, `60_codebase/`, `70_ledger/`: **index.md를 먼저 읽어 목차로 활용**하고, 작업과 관련 있는 파일만 선택적으로 추가 읽는다.
- `90_issues/active/`: 하위 전체를 읽는다 (index 개념 없음).
- `90_issues/archive/<issue-dir>/`: 사용자가 명시적으로 언급한 이슈 디렉토리 전체를 읽는다.
- 이미 컨텍스트에 적재된 파일은 재로딩하지 않는다.

---

작업 유형에 따라 아래 문서가 **존재하면** 먼저 읽는다. 없으면 해당 단계를 건너뛴다.

## 코드 수정·리뷰·분석 시

1. `.ai/10_rules/architecture.md` — 아키텍처 제약 준수 여부 확인
2. `.ai/60_codebase/index.md` — 대상 기능의 엔트리포인트·호출 흐름 파악
3. 색인 행의 "관련 문서" 열에 링크된 `40_domain/`, `50_adr/`, `30_contract/` 문서를 따라 읽는다
4. 링크가 없더라도 변경 내용이 아래에 해당하면 해당 index.md를 연다:
   - 데이터·정책 변경 → `40_domain/index.md`
   - 아키텍처·기술 선택 변경 → `50_adr/index.md`
   - 외부 API·연동 변경 → `30_contract/index.md`

## 원본 문서 작업 시

SSoT 선언이 원본 문서인 repo에서 문서를 작성·수정·리뷰·분석할 때 적용한다.

1. `.ai/60_codebase/index.md` — 대상 문서 파일을 찾는다
2. 색인 행의 "관련 문서" 열에 링크된 `40_domain/`, `50_adr/` 문서를 따라 읽는다
3. `AI-CONTEXT.md` `## 프로젝트 도메인` 표의 `ssot_dir` 아래 대상 파일을 직접 읽어 확인한다

## 정책·명세 문서 수정 시

- `.ai/40_domain/index.md` — 기존 정책과의 충돌 여부
- `.ai/50_adr/index.md` — 이전 의사결정과의 정합성

## 외부 API·계약 변경 시

- `.ai/30_contract/index.md`

## 산출 문서·PR·이슈·리뷰 코멘트 작성 시

- `.ai/10_rules/writing-principles.md` — 산출물 작성 원칙 (소스 코드 미적용)
- `.ai/10_rules/writing-principles-local.md` — repo 고유 확장 (원칙과 충돌하면 local 우선)

---

**SSoT는 `AI-CONTEXT.md` 본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)의 `> SSoT: <값>.` 선언을 따른다.** 값은 `소스 코드` 또는 `원본 문서`이며 그 외 값은 선언으로 보지 않는다. 선언을 찾지 못하면 소스 코드를 SSoT로 본다. 색인(`60_codebase/`)은 오래되었을 수 있으므로 보조 자료로 활용하고 SSoT를 직접 확인한다.
**정책·ADR은 코드와 동등한 제약**으로 취급한다. 단, `50_adr/superseded/`의 ADR은 제약으로 쓰지 않고 이력 확인에만 읽는다.
