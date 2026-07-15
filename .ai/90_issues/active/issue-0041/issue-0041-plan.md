# Issue #41 실행계획 — ai-workspace writing-principles 참조 경로 보강

> 스펙: [issue-0041-spec.md](./issue-0041-spec.md)

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> 각 작업은 독립적으로 검증 가능해야 하며, **완료 기준은 자연어 대신 실행 명령 + 임계값**으로 적습니다.
> 명령으로 환원이 어려운 항목만 판정 주체(다른 AI / 사람)를 적고 강등 사유를 남깁니다.
> 마지막 고정 Task(교차모델 issue-audit)는 삭제하지 말고 그대로 둡니다.

### Task 1: 템플릿 context-loading.md에 산출물 작성 라우팅 섹션 추가

- [ ] 완료
- **목표**: 스킬 단독 실행 경로에서 `writing-principles.md`로 가는 안내를 만든다.
- **작업 내용**:
  1. `ai-workspace/templates/shared/.ai/10_rules/context-loading.md`의 작업 유형 목록에 "산출 문서·PR·이슈·리뷰 코멘트 작성 시" 섹션을 추가한다.
  2. 섹션 내용: `writing-principles.md`(산출물 작성 원칙) + `writing-principles-local.md`(repo 고유 확장, 충돌 시 local 우선) 두 줄.
- **완료 기준**: `grep -c 'writing-principles' ai-workspace/templates/shared/.ai/10_rules/context-loading.md` ≥ 2

---

### Task 2: ai-workspace/SKILL.md 멱등 보강 검사에 프로젝트 규칙 행 검사 추가

- [ ] 완료
- **목표**: update 모드가 기존 repo 안내도의 `## 프로젝트 규칙` 표에 라우터 행을 전파하게 한다.
- **작업 내용**:
  1. update-4단계 멱등 보강 검사 표에 항목 추가 — 검사: `## 프로젝트 규칙` 표에 `writing-principles.md` 행 존재 여부. 누락 시 조치: 표준 행(#39에서 확정한 라우터 한 줄) 삽입, 기존 사용자 작성 행 보존.
- **완료 기준**: `grep -n 'writing-principles' ai-workspace/SKILL.md`에 update-4단계 멱등 보강 검사 표 내 행 ≥ 1

---

### Task 3: 이 repo 설치본·안내도 반영

- [ ] 완료
- **목표**: 이 repo에서 실제 참조 경로가 이어지게 한다.
- **작업 내용**:
  1. `.ai/10_rules/context-loading.md`를 Task 1 반영본 템플릿으로 갱신한다 (버전 고정 정책과 동일하게 복사).
  2. `.ai/AI-CONTEXT.md`의 `## 프로젝트 규칙` 표에 `writing-principles.md` 행을 추가한다 (Task 2에서 확정한 표준 행).
- **완료 기준**: `diff ai-workspace/templates/shared/.ai/10_rules/context-loading.md .ai/10_rules/context-loading.md` 차이 0건, `grep -c 'writing-principles' .ai/AI-CONTEXT.md` ≥ 1

---

### Task 4: 홈 설치본 동기화

- [ ] 완료
- **목표**: 갱신된 `ai-workspace` 스킬이 홈 설치본에서도 동일하게 동작하게 한다.
- **작업 내용**:
  1. `/install-skills`로 `ai-workspace`를 재설치한다 (또는 동등한 복사).
- **완료 기준**: `diff -r ai-workspace ~/.claude/skills/ai-workspace` 차이 0건 (배포 제외 경로 없음 — 이 스킬에는 `tests/` 없음)

---

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

<!--
이 블록은 모든 이슈 계획의 마지막 Task로 고정한다. 삭제하지 말 것.
audit은 L2 [QD] 보완 검증 — L1 [D] 결정적 게이트의 대체가 아니라 보완이다.
이 Task는 사용자가 직접 수행하며, 구현 AI는 자동으로 닫지 않는다.
-->

- [ ] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **실행 주체**: **사용자가 직접** 수행한다. 구현 AI는 이 Task를 **자동으로 닫지 않으며**, `issue-audit`를 자동 실행하지도 않는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 전부 재실행해 통과를 확인한다.
  2. 계획·구현을 수행한 모델과 **다른 벤더 모델**(Non-Anthropic 포함, 최소 동급 이상 역량)로 사용자가 직접 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 사용자가 audit 결과(지적 사항·감사 모델)를 summary에 반영·기록한다. 발견사항 보정은 issue-work `--response`로 검토한다 — **피드백 먼저, 항목별 승인 후에만** 앞 Task를 보정하며, 리포트를 받자마자 자동 보정하지 않는다.
- **완료 기준**: `[D]` 검증 명령 전부 통과 + 구현 모델 ≠ audit 모델 기록이 summary 모델 칸("벤더, 모델명" 형식)에 남는다.
