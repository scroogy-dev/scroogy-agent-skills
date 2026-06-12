# Issue #0015 실행요약 issue-work 스킬에 정리 옵션 추가

> 스펙: [issue-0015-spec.md](./issue-0015-spec.md) | 계획: [issue-0015-plan.md](./issue-0015-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task 3 — SKILL.md 반영

---

## Task별 수행 결과

### Task 1: 옵션명 결정

- **결과**: 완료
- **수행 내용 요약**: 옵션명을 `--clear`로 확정. AI가 제안한 후보(`--cleanup`, `--archive`, `--finish`, `--close`) 대신 사용자가 Claude Code의 `/clear` 명령을 유추 근거로 제안했고, "이슈를 마무리하고 active/99_workspace를 비워 다음 이슈를 준비한다"는 의도가 `/clear`의 의미와 일치하여 채택.
- **특이 사항**: `clear`가 삭제로 오해되지 않도록, SKILL.md 옵션 설명에 "archive로 이관하며 비운다(삭제 아님)"를 명시할 것 — Task 3에서 반영.

---

### Task 2: 정리 옵션 동작 설계

- **결과**: 완료
- **수행 내용 요약**: `--clear` 옵션의 동작을 설계하고 SKILL.md 반영 초안을 `.ai/99_workspace/issue-0015-clear-option-design.md`에 작성. 핵심 결정 — ① `--clear`는 기존 `## 이슈 완료 시` 절차의 상위 집합 (완료 절차 포함 + 99_workspace 정리 + 댓글 질의), ② 동작 순서: 완료 확인 → summary 갱신 → 댓글 질의 → archive 이관 → 99_workspace 정리, ③ 미완료 Task가 있으면 질의 후 진행 (중단·종료 케이스 지원), ④ 99_workspace는 목록 제시 후 삭제 확인, `.gitkeep` 항상 보존, 보존 가치 있는 파일은 archive 이슈 디렉토리로 이동 제안.
- **특이 사항**: 댓글 등록은 부가 기능으로 설계 — 거절·연동 불가 시 건너뛰고 정리는 계속. 설계 문서는 이 이슈를 `--clear`로 마무리할 때 정리 대상이 됨.

---

### Task 3: SKILL.md 반영

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 4: 점검 및 문서 동기화

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:
