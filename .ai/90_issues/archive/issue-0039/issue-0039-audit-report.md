# Issue #39 3차 재감사 리포트 ai-workspace 산출물 작성 원칙 SSoT 배포 체계 추가

> 감사 일시: 2026-07-15  
> 감사 모델: OpenAI, GPT-5  
> 감사 대상 브랜치: issue-0039 (현재 작업트리 보정 포함)  
> 스펙 출처: [issue-0039-spec.md](./issue-0039-spec.md) (작성 시점 경로는 `.ai/90_issues/active/issue-0039/issue-0039-spec.md`, --clear로 이관)

---

## 재검증 결론

- 2차 감사 F-1(`.ai/10_rules/` 누락 시 update 중단)은 `mkdir -p .ai/10_rules` 보강 후 재현 검증을 통과했다.
- 2차 감사 F-2(init/update의 local 정책 문서 불일치)는 spec·plan·summary·SKILL.md·local 템플릿이 모두 `init=전체 초기화`, `update=local 보존`으로 일치해 해소됐다.
- 명시된 요구사항과 DoD는 **PASS 16 / FAIL 0 / PARTIAL 0**이다.
- 새 기능 결함은 발견하지 않았다. 기존에 보류하기로 한 약한 문자열 게이트만 LOW 잔여 위험으로 남는다.

---

## Phase 1: 적합성 검증 (Compliance Check)

### 요구사항 대조

| # | 요구사항 | 판정 | 근거 |
|---|----------|------|------|
| 1 | `writing-principles.md` SSoT에 헤더·버전·우선순위·적용/제외 범위·서술 제약·자유 서술 구조 기본값을 30~50줄에 담는다. | PASS | 원본은 34줄이며 요구 요소를 모두 포함한다. |
| 2 | `writing-principles-local.md`를 사용자 관리 파일로 만들고 update에서 없을 때만 복사하며 충돌 시 local 우선을 적용한다. | PASS | local 템플릿과 `SKILL.md` update 절차가 누락 시 생성·기존 내용 보존을 일관되게 규정한다. |
| 3 | dev·doc `AI-CONTEXT.md` 템플릿에 내용 복제 없이 라우터 한 줄을 추가한다. | PASS | 두 템플릿 모두 `writing-principles.md` 라우터를 한 줄씩 포함한다. |
| 4 | init 절차에 두 파일을 포함하고 기존 `.ai/`에서 init을 선택하면 전체 초기화 계약을 따른다. | PASS | 신규 init에서 두 파일 생성, 기존 local이 있는 init에서 템플릿으로 초기화됨을 재현했다. |
| 5 | update에서 SSoT를 최신본으로 보강하고 local은 누락 시 생성·기존 내용 보존하며 멱등이어야 한다. | PASS | `.ai/`만 있고 `10_rules/`가 없는 상태, 구버전 SSoT, 기존·누락 local, 2회 실행을 모두 재현해 통과했다. |
| 6 | 설치본 `~/.claude/skills/ai-workspace/`를 repo와 동기화한다. | PASS | `diff -rq` 결과 차이가 없다. |
| 7 | 문서 생산 스킬과 이 repo 자체 `.ai/10_rules/`를 변경하지 않고 후속 이슈 후보만 정리한다. | PASS | `origin/main` 대비 변경은 이슈 문서와 명시된 `ai-workspace` 파일에 한정된다. |

### 완료의 정의(DoD) 대조

| # | DoD 항목 | 판정 | 근거 |
|---|----------|------|------|
| 1 | SSoT에 동기화 헤더·버전 표기가 있다. | PASS | `SYNCED by ai-workspace=1`, `버전\|version=1`. |
| 2 | 최상단에 템플릿 구조 우선·서술 제약만 선언한다. | PASS | `템플릿이 우선=1`; 본문 의미도 일치한다. |
| 3 | 원칙 파일이 50줄 이하다. | PASS | 34줄. |
| 4 | local 템플릿과 local 우선 규칙이 있다. | PASS | 파일 존재 및 `local 우선=1`. |
| 5 | SKILL.md init 복사 절차에 두 파일이 반영됐다. | PASS | 전체 `writing-principles` 매칭 7건이며 init 동작도 재현했다. |
| 6 | update에 writing-principles 멱등 보강이 있다. | PASS | update 섹션 매칭 5건; SSoT 갱신·local 보존·2회 멱등을 재현했다. |
| 7 | dev·doc 라우터가 모두 있다. | PASS | 두 파일 모두 매칭한다. |
| 8 | 설치본이 repo와 동기화됐다. | PASS | `diff -rq` 출력 없음. |
| 9 | init 생성·update 구버전 갱신·local 보존 시나리오와 본문 의미 요구를 충족한다. | PASS | 모든 시나리오 및 의미 체크리스트를 통과했다. |

### 판정 집계

- 요구사항: PASS 7건 / FAIL 0건 / PARTIAL 0건
- DoD: PASS 9건 / FAIL 0건 / PARTIAL 0건
- 합계: PASS 16건 / FAIL 0건 / PARTIAL 0건

### 범위 검증

- **스펙 비포함(Out) 침범 여부**: PASS. 다른 문서 생산 스킬, 루트 `.ai/10_rules/`, 후속 GitHub Issue를 변경·생성하지 않았다.
- **스펙에 없는 추가 구현 여부**: PASS. `mkdir -p .ai/10_rules`는 명시된 update 누락 보강을 모든 허용 진입 상태에서 성립시키는 범위 내 보정이다.

### 도메인/계약/ADR 정합성

- `.ai/30_contract/index.md`: 관련 계약 문서 없음.
- `.ai/40_domain/index.md`: 충돌하는 등록 정책·스펙 없음.
- `.ai/50_adr/index.md`: 결정적 helper/script를 추가하지 않아 ADR-0001 적용 대상 아님.
- `.ai/60_codebase/index.md`: 색인이 비어 있어 실제 diff와 대상 파일을 SSoT로 확인했다.

---

## Phase 2: 비판적 검증 (Critical Review)

### 발견 사항

| # | 위험도 | 분류 | 설명 | 관련 파일 |
|---|--------|------|------|-----------|
| F-1 | LOW | 누락된 검증 | DoD의 init 검증이 SKILL.md 전체 문자열 개수만 세어 init/update 정책 의미의 회귀를 L1에서 판정하지 못한다. 기존 보류 결정에 따른 잔여 위험이며 신규 결함은 아니다. | [issue-0039-spec.md](./issue-0039-spec.md), `ai-workspace/SKILL.md` |

### 상세 분석

#### F-1: 결정적 init 검증의 의미 공백 — OPEN / DEFERRED

- **위험도**: LOW
- **분류**: 누락된 검증
- **설명**: `grep -c 'writing-principles' ai-workspace/SKILL.md >= 2`는 init 섹션을 별도로 검사하지 않는다. 현재 구현은 재현 검증으로 정상임을 확인했지만, 향후 init 절차가 깨져도 설명이나 update 문구가 남으면 해당 게이트는 통과할 수 있다.
- **영향**: 회귀가 L1에서 잡히지 않고 후속 QD 감사까지 남을 수 있다.
- **권장 조치**: 이번 이슈에서 보류 결정을 유지할 수 있다. 후속 보강 시 init 섹션 범위 검사 또는 임시 workspace 재현 테스트를 결정적 게이트로 추가한다.

### 이전 발견 사항 재검증

| 이전 항목 | 상태 | 재검증 결과 |
|----------|------|-------------|
| 1차 F-1: init/local 보존 정책 충돌 | RESOLVED | spec·plan·summary·SKILL.md·local 템플릿이 `init=전체 초기화`, `update=local 보존`으로 일치한다. |
| 2차 F-1: `10_rules/` 누락 시 update 중단 | RESOLVED | `mkdir -p .ai/10_rules` 추가 후 `.ai/`만 있는 workspace에서 update 성공·2회 멱등을 재현했다. |
| 2차 F-2: plan·summary 정책 문구 불일치 | RESOLVED | 두 문서 모두 최종 정책으로 정정됐다. |
| 기존 약한 문자열 검증 | OPEN / DEFERRED | 현재 구현은 정상이나 L1 게이트의 의미 공백은 잔여 위험 F-1로 유지한다. |

---

## 검증 명령 및 결과

| 검증 | 결과 |
|------|------|
| 스펙 `[D]` grep/wc 명령 전체 | `1`, `1`, `1`, `34`, `1`, `7`, `5`, 라우터 2개 — 모두 PASS |
| `diff -rq ai-workspace /Users/user/.claude/skills/ai-workspace` | PASS — 출력 없음 |
| 신규 workspace init | PASS — 두 원칙 파일 생성 |
| 기존 workspace init 전체 초기화 | PASS — 기존 local을 템플릿으로 초기화 |
| `.ai/`만 존재하고 `10_rules/`가 없는 update | PASS — 디렉토리 및 원칙 파일 생성 |
| update 구버전 SSoT 갱신 | PASS |
| update 기존 local 보존·누락 local 생성 | PASS |
| update 2회 실행 멱등 | PASS |
| `git diff origin/main --check`, `git diff --check` | PASS — 출력 없음 |
| 관련 자동 테스트 검색 | 전용 테스트 없음 (`install-skills/tests/run-tests.sh`만 존재) |

---

## 종합 의견

2차 감사 후 보정은 의도대로 작동한다. 스펙의 모든 명시 요구사항과 DoD가 충족되고 이전 MEDIUM 결함도 실제 재현에서 해소됐다. 새 기능 결함이나 범위 침범은 발견하지 않았으므로 Issue #39의 Task N을 완료로 판단할 수 있다.

남은 LOW 항목은 이미 합의된 검증 게이트의 한계이며 현재 기능의 실패를 의미하지 않는다. 후속 회귀 방지 강화를 원할 때 별도 테스트 보강 대상으로 관리하면 된다.
