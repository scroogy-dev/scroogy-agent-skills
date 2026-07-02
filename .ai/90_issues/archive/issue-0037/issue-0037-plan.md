# Issue #37 실행계획 issue-work --clear: archive 이관 시 이동 md 본문의 경로 참조 미갱신 (dead link) 개선

> 스펙: [issue-0037-spec.md](./issue-0037-spec.md)

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> 각 작업은 독립적으로 검증 가능해야 하며, **완료 기준은 자연어 대신 실행 명령 + 임계값**으로 적습니다.
> 명령으로 환원이 어려운 항목만 판정 주체(다른 AI / 사람)를 적고 강등 사유를 남깁니다.
> 마지막 고정 Task(교차모델 issue-audit)는 삭제하지 말고 그대로 둡니다.

### Task 1: 경로 참조 갱신 규칙·검증 스니펫 설계

- [x] 완료
- **목표**: 깨짐 패턴 3종의 갱신 규칙, 이관 이력 표기 표준 문구, stale 참조 검증 grep 스니펫과 오탐 처리 방침을 확정한다.
- **작업 내용**:
  1. archive 실사례(issue-0026·0028·0031의 잔존 참조, issue-0035의 수기 보정)를 패턴 3종으로 분류·정리한다.
  2. 갱신 규칙 초안을 작성한다 — 함께 이동한 파일 간 참조는 `./` 상대 링크, 이동하지 않은 대상 참조는 이관 후 위치 기준 경로로 재작성, 이력 병기 표준 문구("작성 시점 경로는 …, --clear로 이관") 확정.
  3. 검증 스니펫을 설계한다 — 이관 직후 `archive/issue-<번호>/` 하위에서 `90_issues/active/`·`.ai/99_workspace/` 참조를 검색하는 grep 명령. 오탐(절차 서술 문구, spec·리포트에 기록된 과거 검증 명령 인용, 이력 병기 표기) 처리 방침을 함께 결정한다 — 링크·경로 표기만 검사할지, 병기 표기를 허용 예외로 둘지.
  4. 설계안을 사용자에게 제시하고 승인받는다.
- **완료 기준**: 설계안(규칙·표준 문구·grep 스니펫·오탐 방침)이 `issue-0037-summary.md` Task 1에 기록되고 사용자 승인 (판정 주체: 사람 — 설계 타당성은 명령으로 환원 불가)

---

### Task 2: SKILL.md 절차 반영

- [x] 완료
- **목표**: 확정된 규칙을 `issue-work/SKILL.md`의 `--clear`와 `## 이슈 완료 시` 절차에 반영한다.
- **작업 내용**:
  1. `--clear` 동작에 6단계 "경로 참조 갱신·검증"을 신설해 갱신 규칙 5항과 이력 병기 표준 문구를 기재한다 (갱신은 4·5단계 이동 완료를 전제하므로 통합 배치).
  2. 이관 완료 후 잔존 참조 0건을 확인하는 grep 검증 스니펫과 제외 2건의 근거를 같은 단계에 기재한다.
  3. `## 이슈 완료 시`에 4단계를 추가한다 (갱신 규칙·스니펫은 `--clear` 6단계 참조).
- **완료 기준**: `grep -c '경로 참조 갱신' issue-work/SKILL.md` ≥ 2 그리고 `grep -c 'grep -' issue-work/SKILL.md` ≥ 1

---

### Task 3: 템플릿(SSoT)·active 사본·설치본 동기화

- [x] 완료
- **목표**: 워크플로우 템플릿과 그 사본, 설치본에 동일 규칙이 유지되게 한다.
- **작업 내용**:
  1. `issue-work/templates/issue-workflow-template.md`의 `## 이슈 완료 시`에 경로 참조 갱신 규칙을 반영한다.
  2. active 사본 `.ai/90_issues/active/issue-workflow.md`를 템플릿과 동일하게 동기화한다.
  3. 설치본 `~/.claude/skills/issue-work/`를 repo와 동기화한다 (install-skills 또는 직접 복사).
- **완료 기준**:
  - `grep -l '경로 참조 갱신' issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md` 두 파일 모두 매칭
  - `diff issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md` 차이 없음
  - `diff -rq issue-work ~/.claude/skills/issue-work` 차이 없음

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
