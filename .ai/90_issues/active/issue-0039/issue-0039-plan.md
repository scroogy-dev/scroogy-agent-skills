# Issue #39 실행계획 ai-workspace: 산출물 작성 원칙(writing-principles) SSoT 배포 체계 추가

> 스펙: [issue-0039-spec.md](./issue-0039-spec.md)

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> 각 작업은 독립적으로 검증 가능해야 하며, **완료 기준은 자연어 대신 실행 명령 + 임계값**으로 적습니다.
> 명령으로 환원이 어려운 항목만 판정 주체(다른 AI / 사람)를 적고 강등 사유를 남깁니다.
> 마지막 고정 Task(교차모델 issue-audit)는 삭제하지 말고 그대로 둡니다.

### Task 1: writing-principles.md SSoT 원본 신설

- [x] 완료
- **목표**: 산출물 작성 원칙의 단일 원본을 `templates/shared/.ai/10_rules/`에 만든다 — 스킬 템플릿 구조는 건드리지 않는 서술 제약 문서로.
- **작업 내용**:
  1. `ai-workspace/templates/shared/.ai/10_rules/writing-principles.md` 작성 — 상단 동기화 헤더(`<!-- SYNCED by ai-workspace — 원본: …, DO NOT EDIT -->`)와 버전 표기 → 최상단 우선순위 선언(스킬 템플릿이 구조를 정의하면 템플릿 우선, 이 원칙은 서술 방식만 제한) → 적용/제외 범위 선언 → 제약 규칙(중요한 것 먼저, 리스트형 우선, 분량 예산, 한글 표현 우선, 금지 패턴, What/Why/How 분리, 접기 가능/금지) → 구조 기본값(템플릿이 구조를 정의하지 않는 자유 서술 산출물에만 계층형 출력) 순으로 구성한다.
  2. 분량을 한 페이지(30~50줄) 이내로 유지한다.
- **완료 기준**: `grep -c 'SYNCED by ai-workspace' ai-workspace/templates/shared/.ai/10_rules/writing-principles.md` ≥ 1, `grep -c '템플릿이 우선' 동일 파일` ≥ 1, `wc -l < 동일 파일` ≤ 50

---

### Task 2: writing-principles-local.md 로컬 확장 템플릿 신설

- [x] 완료
- **목표**: 사용자 관리 로컬 확장 파일의 빈 템플릿을 만들고 충돌 시 local 우선 규칙을 명시한다.
- **작업 내용**:
  1. `ai-workspace/templates/shared/.ai/10_rules/writing-principles-local.md` 빈 템플릿 작성 — 용도 안내와 "두 파일 충돌 시 local 우선" 규칙을 상단에 기재한다.
  2. `writing-principles.md` 본문에도 local 우선 규칙 상호 참조를 한 줄 기재한다 (Task 1 분량 예산 내에서).
- **완료 기준**: `grep -c 'local 우선' ai-workspace/templates/shared/.ai/10_rules/writing-principles-local.md` ≥ 1

---

### Task 3: AI-CONTEXT.md 템플릿(dev·doc) 라우터 한 줄 추가

- [x] 완료
- **목표**: 안내도가 내용 요약 없이 경로만 라우팅하게 한다.
- **작업 내용**:
  1. `ai-workspace/templates/dev/.ai/AI-CONTEXT.md`와 `ai-workspace/templates/doc/.ai/AI-CONTEXT.md`의 10_rules 안내 표(또는 대응 위치)에 한 줄 추가: "산출물 작성 규칙: `.ai/10_rules/writing-principles.md` — 문서 생산 스킬이 적용, 소스 코드 미적용".
- **완료 기준**: `grep -l 'writing-principles' ai-workspace/templates/dev/.ai/AI-CONTEXT.md ai-workspace/templates/doc/.ai/AI-CONTEXT.md` 두 파일 모두 매칭

---

### Task 4: SKILL.md init/update 절차 반영

- [x] 완료
- **목표**: 배포 메커니즘이 두 파일을 올바른 정책(버전 고정 vs 없을 때만 복사)으로 다루게 한다.
- **작업 내용**:
  1. `ai-workspace/SKILL.md` init-1단계 파일 복사 절차에 두 파일 추가 — `writing-principles.md`는 `context-loading.md`와 동일하게 항상 복사, `writing-principles-local.md`는 `coding-convention.md`와 동일하게 없을 때만 복사.
  2. update-1단계(10_rules/ 정리)에 멱등 보강 검사 추가 — `writing-principles.md` 존재·최신 여부(버전/헤더 비교) 확인, 누락·구버전이면 최신본 덮어쓰기, `writing-principles-local.md`는 없을 때만 빈 템플릿 복사·있으면 보존.
- **완료 기준**: `grep -c 'writing-principles' ai-workspace/SKILL.md` ≥ 2, `sed -n '/^## update 모드/,$p' ai-workspace/SKILL.md | grep -c 'writing-principles'` ≥ 1

---

### Task 5: 설치본 동기화·후속 이슈 후보 정리

- [ ] 완료
- **목표**: 변경분을 설치본에 반영하고 후속 스킬별 이슈 분리를 준비한다.
- **작업 내용**:
  1. `install-skills`(또는 동등 절차)로 `~/.claude/skills/ai-workspace/`를 동기화한다.
  2. 문서 생산 스킬별 후속 이슈 후보 목록(스킬명 + 변경 요지: 실행 절차 1단계 원칙 적용 명시, 폴백 인라인 규칙, 제약 규칙에 어긋나는 서술만 손질 — 템플릿 구조 개편 아님, 자가 검증 체크리스트)을 정리해 사용자에게 제시한다 — 이슈 등록·링크 기재는 사용자 승인 시에만 수행한다.
- **완료 기준**: `diff -rq ai-workspace ~/.claude/skills/ai-workspace` 차이 없음 + 후속 이슈 후보 목록이 summary에 기록됨

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
