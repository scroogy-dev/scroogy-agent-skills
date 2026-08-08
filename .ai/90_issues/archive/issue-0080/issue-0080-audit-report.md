# Issue #80 감사 리포트 — git 스킬 3종 산출물 형식 블록 분리

> 감사 일시: 2026-08-08  
> 감사 모델: OpenAI, GPT-5  
> 감사 회차: 1차 (이전 리포트: 없음)  
> 보정 일시: 2026-08-08  
> 감사 대상 브랜치: `issue-0080` (`origin/main...HEAD`)  
> 스펙 출처: `./issue-0080-spec.md` (작성 시점 경로는 `.ai/90_issues/active/issue-0080/issue-0080-spec.md`, --clear로 이관)

---

## 종합 의견

Issue #80의 요구사항 5건과 AI가 판정 가능한 DoD 4건은 모두 충족했다. 이동 전 형식 블록과 신규 템플릿은 허용된 코드 펜스 해제·안내 주석을 제외하면 정확히 동등하고, 참조·배포·회귀 검증도 통과했다. 초회 감사의 낮음(LOW) 발견 F-1은 사용자 승인에 따라 보정되어 현재 잔여 발견은 없다.

## 요약

- 1단계 적합성: 충족(PASS) 9건 / 미충족(FAIL) 0건 / 부분 충족(PARTIAL) 0건 / 판정 불가(N/A) 1건
- 2단계 위험도: 높음(HIGH) 0건 / 중간(MEDIUM) 0건 / 낮음(LOW) 0건 / 정보(INFO) 0건
- 기등재 참조: 0건
- 보정 결과: 닫힘 1건(F-1) / 잔여 0건
- 이전 발견: 해당 없음

| 카테고리 | 건수 |
|----------|------|
| 기능 | 0 |
| 아키텍처 | 0 |
| 버그 | 0 |
| 보안 | 0 |
| 코드품질 | 0 |
| 성능 | 0 |
| 테스트 | 0 |

---

## 1단계: 적합성 검증 (Compliance Check)

### 요구사항 대조

| # | 요구사항 | 판정 | 근거 |
|---|----------|------|------|
| 1 | `git-pr` 작성 예시를 `templates/pr-body-template.md`로 분리 | 충족(PASS) | 템플릿이 존재하고 `git-pr/SKILL.md:215,258`이 이를 참조한다. `InventoryCache#get`은 템플릿에만 남았다. |
| 2 | `git-qa` 출력 형식을 `templates/qa-checklist-template.md`로 분리 | 충족(PASS) | 템플릿이 존재하고 `git-qa/SKILL.md:98,102,123`이 이를 참조한다. `## 배포 대상 요약`은 템플릿에만 남았다. |
| 3 | `git-review-context` 결과 형식을 `templates/review-context-template.md`로 분리 | 충족(PASS) | 템플릿이 존재하고 `git-review-context/SKILL.md:117`이 이를 참조한다. 접기 안내 규칙은 SKILL.md에 유지됐다. |
| 4 | 이동 자리와 내부 상호 참조를 템플릿 참조로 교체 | 충족(PASS) | `아래 "작성 예시"`·`아래 템플릿 구조` 잔존 0건이며, 세 SKILL.md 모두 자기 템플릿을 명시한다. |
| 5 | `.ai/AI-CONTEXT.md` 구조 트리에 신규 `templates/` 3행 반영 | 충족(PASS) | `.ai/AI-CONTEXT.md:73-81`에 git-pr·git-qa·git-review-context의 하위 디렉토리가 기존 정렬·표기 관례대로 존재한다. |

### 완료의 정의(DoD) 대조

| # | DoD 항목 | 판정 | 근거 |
|---|----------|------|------|
| 1 | 템플릿 3개 존재 및 각 SKILL.md의 자기 경로 참조 | 충족(PASS) | 스펙의 `[D]` 명령 재실행 결과 위반 출력 0건. |
| 2 | 이동 블록이 SKILL.md에서 제거되고 템플릿에 존재 | 충족(PASS) | 스펙의 고유 앵커 검증 결과 위반 출력 0건. |
| 3 | AI-CONTEXT 구조 트리 3행 존재 | 충족(PASS) | 스펙의 트리 검증 결과 위반 출력 0건. |
| 4 | 이동 전후 형식 내용 동등 | 충족(PASS) | `origin/main`의 각 코드 펜스 내부를 추출해 신규 템플릿에서 허용 안내 주석만 제거한 내용과 대조한 결과 세 파일 모두 diff 0건. |
| 5 | SKILL.md 참조 문구가 읽는 흐름을 해치지 않음 | 판정 불가(N/A) | 참조는 실행 지점과 형식 설명 지점에 자연스럽게 배치됐으나, 스펙이 사람 리뷰 `[ND]`로 지정한 가독성 판단은 감사 모델이 최종 확정하지 않는다. |

### 범위 검증

- **스펙 비포함(Out) 침범 여부**: 없음. git-commit·git-pr-feedback·README.md·절차 예시·규칙 표는 변경하지 않았다.
- **스펙에 없는 추가 구현 여부**: 없음. 구현 변경 7개 파일 외 변경은 Issue #80의 spec·plan·summary 작업 문서다.

### 도메인/계약 정합성

- `.ai/30_contract/`, `.ai/40_domain/`, `.ai/50_adr/`, `.ai/60_codebase/`에 이번 템플릿 이동과 직접 관련된 계약·정책·ADR·색인은 없다. ADR 0001은 결정적 헬퍼 테스트 배치 규칙이라 비관련이다.
- `install-skills/SKILL.md`의 복사 절차는 `tests/`와 `*.test.*`만 제외하므로 신규 `templates/` 3개는 별도 변경 없이 설치본에 포함된다.
- `.ai/70_ledger/active/` 4건과 같은 결함은 없고 `archive/` 항목도 없다.
- 사용자가 첨부한 `code-map/references/local.md`는 `origin/main...HEAD` 변경 파일이 아니며 Issue #80 스펙과 직접 연결되지 않아 참고만 했다.

---

## 2단계: 비판적 검증 (Critical Review)

### 발견 사항

해당 없음 — 초회 발견 F-1은 사용자 승인 보정으로 닫혔다.

### 보정 결과

| 발견 | 판정 | 반영 내용 | 완료 기준 검증 |
|------|------|-----------|----------------|
| F-1 | 닫힘 | `.ai/AI-CONTEXT.md`의 `last updated`를 `2026-08-08`로 갱신 | 머리말 날짜 일치, 신규 템플릿 3행 유지, `git diff --check` 통과 |

- **처리 근거**: 낮음(LOW)의 기본값은 원장 이관이지만, 사용자가 단순 보정으로 직접 반영하도록 명시 승인했다.
- **잔여 위험**: 없음.

### 기등재 참조 항목

해당 없음.

### 이전 발견 추적

해당 없음 — 초회 감사.

<details>
<summary>검증 근거 펼치기</summary>

- 스펙 `[D]` 게이트 3개와 Task별 결정적 게이트: 위반 출력 0건.
- 이동 전후 동등성: `origin/main` 코드 펜스 내부와 신규 템플릿을 정규화 대조해 3개 모두 diff 0건.
- 이슈 실행요약 게이트: plan·summary Task 집합 일치, 일반 Task 결과 위반 `0`, 수행 모델 위반 `0`.
- 회귀 테스트: `install-skills/tests/run-tests.sh` 20/20, `issue-work/tests/run-tests.sh` 28/28 통과.
- 보정 검증: `.ai/AI-CONTEXT.md:3`의 날짜가 `2026-08-08`이며 신규 템플릿 3행이 유지된다.
- 정적 검증: 상대 Markdown 링크 누락 0건, `git diff --check origin/main...HEAD` 통과.
- 교차 벤더 조건: 구현 Task 수행 모델은 Anthropic, 감사 모델은 OpenAI로 상이하다.

</details>
