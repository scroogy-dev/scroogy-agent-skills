# Issue #41 실행계획 — ai-workspace writing-principles 참조 경로 보강

> 스펙: [issue-0041-spec.md](./issue-0041-spec.md)

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> 각 작업은 독립적으로 검증 가능해야 하며, **완료 기준은 자연어 대신 실행 명령 + 임계값**으로 적습니다.
> 명령으로 환원이 어려운 항목만 판정 주체(다른 AI / 사람)를 적고 강등 사유를 남깁니다.
> 마지막 고정 Task(교차모델 issue-audit)는 삭제하지 말고 그대로 둡니다.

### Task 1: 템플릿 context-loading.md에 산출물 작성 라우팅 섹션 추가

- [x] 완료
- **목표**: 스킬 단독 실행 경로에서 `writing-principles.md`로 가는 안내를 만든다.
- **작업 내용**:
  1. `ai-workspace/templates/shared/.ai/10_rules/context-loading.md`의 작업 유형 목록에 "산출 문서·PR·이슈·리뷰 코멘트 작성 시" 섹션을 추가한다.
  2. 섹션 내용: `writing-principles.md`(산출물 작성 원칙) + `writing-principles-local.md`(repo 고유 확장, 충돌 시 local 우선) 두 줄.
- **완료 기준**: `grep -c 'writing-principles' ai-workspace/templates/shared/.ai/10_rules/context-loading.md` ≥ 2

---

### Task 2: ai-workspace/SKILL.md 멱등 보강 검사에 프로젝트 규칙 행 검사 추가

- [x] 완료
- **목표**: update 모드가 기존 repo 안내도의 `## 프로젝트 규칙` 표에 라우터 행을 전파하게 한다.
- **작업 내용**:
  1. update-4단계 멱등 보강 검사 표에 항목 추가 — 검사: `## 프로젝트 규칙` 표에 `writing-principles.md` 행 존재 여부. 누락 시 조치: 표준 행(#39에서 확정한 라우터 한 줄) 삽입, 기존 사용자 작성 행 보존.
- **완료 기준**: `grep -n 'writing-principles' ai-workspace/SKILL.md`에 update-4단계 멱등 보강 검사 표 내 행 ≥ 1

---

### Task 3: 이 repo 설치본·안내도 반영

- [x] 완료
- **목표**: 이 repo에서 실제 참조 경로가 이어지게 한다.
- **작업 내용**:
  1. `.ai/10_rules/context-loading.md`를 Task 1 반영본 템플릿으로 갱신한다 (버전 고정 정책과 동일하게 복사).
  2. `.ai/AI-CONTEXT.md`의 `## 프로젝트 규칙` 표에 `writing-principles.md` 행을 추가한다 (Task 2에서 확정한 표준 행).
- **완료 기준**: `diff ai-workspace/templates/shared/.ai/10_rules/context-loading.md .ai/10_rules/context-loading.md` 차이 0건, `grep -c 'writing-principles' .ai/AI-CONTEXT.md` ≥ 1

---

### Task 4: 홈 설치본 동기화

- [x] 완료
- **목표**: 갱신된 `ai-workspace` 스킬이 홈 설치본에서도 동일하게 동작하게 한다.
- **작업 내용**:
  1. `/install-skills`로 `ai-workspace`를 재설치한다 (또는 동등한 복사).
- **완료 기준**: `diff -r ai-workspace ~/.claude/skills/ai-workspace` 차이 0건 (배포 제외 경로 없음 — 이 스킬에는 `tests/` 없음)

---

### Task 5: update-4 멱등 보강 검사에 context-loading.md 행 검사 추가 (일관성 보강)

- [x] 완료
- **목표**: 버전 고정 파일 2종(`context-loading.md`, `writing-principles.md`)의 안내도 행 보장을 같은 조건으로 통일한다 (사용자 질의로 범위 확장, spec 갱신 반영).
- **작업 내용**:
  1. update-4단계 멱등 보강 검사 표에 `## 프로젝트 규칙` 표의 `context-loading.md` 행 검사 항목을 추가한다. 누락 시 조치: 표준 행 삽입 — 사용 시점 문구는 프로파일별 구분 (dev "코드·문서 작업 전" / doc "문서 작업 전"), 기존 사용자 작성 행 보존.
  2. 이 repo `.ai/AI-CONTEXT.md`에는 해당 행이 이미 있어 확인만 한다.
  3. 홈 설치본을 재동기화한다.
- **완료 기준**: `grep -c '프로젝트 규칙.*context-loading\|context-loading.*프로젝트 규칙' ai-workspace/SKILL.md` ≥ 1, `diff -r ai-workspace ~/.claude/skills/ai-workspace` 차이 0건

---

### Task 6: 교차모델 audit 발견사항 보정 (--response 승인분)

- [x] 완료
- **목표**: audit 리포트(OpenAI, GPT-5) 발견사항 F-1·F-2·F-3의 사용자 승인분을 보정한다.
- **작업 내용**:
  1. F-1(MEDIUM) — update-4 멱등 보강 검사 표에 `## 프로젝트 규칙` 섹션·3열 표 존재 검사 행 추가 (섹션 부재 시 프로파일별 템플릿 골격 삽입, 2열 구버전 표는 3열 확장, 두 행 검사에 선행).
  2. F-2(LOW) — spec 포함 범위에 dev update 실행 산출물 3파일 명시 (파일 제거·커밋 분리 없음 — 라우터 행이 가리키는 설치본).
  3. F-3(LOW) — spec DoD 검증 명령을 해당 섹션 범위(awk)로 강화하고, fixture 3케이스(input/expected)+README를 `ai-workspace/tests/fixtures/update4-idempotent/`에 보존.
  4. 홈 설치본 재동기화 — `tests/` 배포 제외 (install-skills 설치 절차 5단계와 동일 규칙).
- **완료 기준**: spec DoD `[D]` 강화판 전부 통과 (awk 범위 grep 4건 + diff 2건 + fixture 7파일) + `[QD]` fixture 모의 실행 통과 (expected 재입력 시 무변경)

---

### Task 7: 재감사 발견사항 보정 (--response 승인분)

- [x] 완료
- **목표**: 재감사 리포트(OpenAI, GPT-5) 발견사항 F-1·F-2·F-3의 사용자 승인분을 보정한다.
- **작업 내용**:
  1. F-1(MEDIUM) — 멱등 보강 검사의 `## 프로젝트 규칙` 섹션·표 검사를 상태 3분기(섹션 부재 / 섹션 존재+표 부재 / 2열 표)로 재작성하고, `no-rules-table` fixture 케이스를 추가한다.
  2. F-2(MEDIUM) — 2열 표 확장 범위를 "열 확장만"으로 확정한다. SKILL.md에서 `legacy-migration.md` ② 참조를 제거해 자체 서술로 바꾸고, 기본 행 복원은 별도 경로(구버전 구조 마이그레이션)임을 명시한다. fixture는 무변경.
  3. F-3(LOW) — spec DoD의 fixture 검사를 개수(`ls | wc -l`)에서 파일명 단위(`test -f`)로, 홈 동기화 검사에 `test ! -e ~/.claude/skills/ai-workspace/tests` 부재 검사를 추가한다.
  4. 홈 설치본 재동기화 — `tests/` 배포 제외.
- **완료 기준**: spec DoD `[D]` 강화판 전부 통과 (awk 범위 grep 4건 + diff 2건 + fixture 파일명 9건 + 홈 `tests/` 부재) + `[QD]` fixture 4종 모의 실행 통과 (expected 재입력 시 무변경)

---

### Task 8: 최종 재감사 발견사항 보정 (--response 승인분)

- [x] 완료
- **목표**: 최종 재감사 리포트(OpenAI, GPT-5, PASS 22 / FAIL 0 / PARTIAL 0) 유일 발견사항 F-1(LOW)의 사용자 승인분을 보정한다.
- **작업 내용**:
  1. F-1(LOW) — doc 프로파일 분기의 `[QD]` 회귀 검증 공백을 대표 케이스 1개로 메운다. `missing-rows-doc` fixture(input/expected) 추가 — `SKILL.md`의 `context-loading.md` 행 검사가 doc 프로파일에서 "문서 작업 전" 문구를 쓰는지 직접 검증한다.
  2. fixture README에 프로파일 표기 규칙(`-doc` 접미사)과 doc 케이스 행을 추가한다.
  3. spec 포함 범위·DoD 갱신 — fixture 4종→5종, 파일명 검사 9→11건.
- **완료 기준**: spec DoD `[D]` 전부 통과 (awk 범위 grep 4건 + diff 2건 + fixture 파일명 11건 + 홈 `tests/` 부재) + `[QD]` fixture 5종 모의 실행 통과
- **비고**: 홈 재동기화 불필요 — `tests/`는 install-skills 배포 제외 경로

---

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

<!--
이 블록은 모든 이슈 계획의 마지막 Task로 고정한다. 삭제하지 말 것.
audit은 L2 [QD] 보완 검증 — L1 [D] 결정적 게이트의 대체가 아니라 보완이다.
이 Task는 사용자가 직접 수행하며, 구현 AI는 자동으로 닫지 않는다.
-->

- [x] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **실행 주체**: **사용자가 직접** 수행한다. 구현 AI는 이 Task를 **자동으로 닫지 않으며**, `issue-audit`를 자동 실행하지도 않는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 전부 재실행해 통과를 확인한다.
  2. 계획·구현을 수행한 모델과 **다른 벤더 모델**(Non-Anthropic 포함, 최소 동급 이상 역량)로 사용자가 직접 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 사용자가 audit 결과(지적 사항·감사 모델)를 summary에 반영·기록한다. 발견사항 보정은 issue-work `--response`로 검토한다 — **피드백 먼저, 항목별 승인 후에만** 앞 Task를 보정하며, 리포트를 받자마자 자동 보정하지 않는다.
- **완료 기준**: `[D]` 검증 명령 전부 통과 + 구현 모델 ≠ audit 모델 기록이 summary 모델 칸("벤더, 모델명" 형식)에 남는다.
