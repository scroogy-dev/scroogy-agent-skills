# Issue #21 스펙 issue-work --clear 시점·순서 및 issue-workflow.md 동기화 개선

## 목표 (Goal)

`issue-work --clear`의 시점·순서 모호함을 해소해, archive 이관이 머지 후 `main` 직접 푸시로 처리되는 혼선의 재발을 방지한다. 더불어 템플릿 개선이 기존 `active/issue-workflow.md` 인스턴스에 전파되지 않는 문제를, "새 이슈 시작 시" 내용 불일치를 자동 갱신하도록 해소한다.

---

## 범위 (Scope)

**포함 (In)**

- `issue-work/SKILL.md` — `--clear` 용도/동작, "이슈 완료 시" 절차
- `issue-work/SKILL.md` — "새 이슈 시작 시" issue-workflow.md 동기화 동작, `--workflow-only` 역할 차별화
- `issue-work/templates/issue-workflow-template.md` — "이슈 완료 시" 절차

**비포함 (Out)**

- `git-pr` 스킬 변경 — description상 "메시지 텍스트 작성 전용"이라 워크플로우 순서는 책임 범위 밖
- `--clear` 동작 단계(1~5)의 구성 자체 변경 (순서·타이밍 규칙만 명문화, 단계 추가/삭제는 하지 않음)
- 다른 프로젝트(이 repo 밖) 인스턴스의 일괄 갱신 — 각 프로젝트가 다음 issue-work 실행 또는 `--workflow-only`로 자연 반영

---

## 문제 (모호함)

1. `--clear` 용도의 "이슈 작업이 끝났을 때"가 구현 완료인지 머지 완료인지 정의가 없음 (`SKILL.md:101`)
2. archive 이관(git 파일 이동)이 어느 브랜치·머지 전후 언제 수행되는지 순서 규칙 부재 (`SKILL.md:111`) — issue-0017 관례는 머지 전 PR 포함이나 미문서화
3. 이슈 댓글 등록(머지 후 적합)과 archive 이관(머지 전 적합)이 한 옵션에 묶여 타이밍 충돌

---

## 완료의 정의 (Definition of Done)

- [ ] `--clear` 용도에 시점 정의가 명시됨 (구현/리뷰 완료 후 머지를 올리기 직전)
- [ ] archive 이관 단계에 "PR 머지 전, 작업 브랜치에서 수행해 같은 PR에 포함" 규칙이 명시됨
- [ ] 이슈 댓글 단계가 머지 전/후 모두 가능함이 명시되어 archive 이관과 타이밍이 분리됨
- [ ] `issue-workflow-template.md`의 "이슈 완료 시" 절차도 동일 규칙으로 동기화됨
- [ ] SKILL.md와 템플릿 간 "이슈 완료 시" 절차 표현이 어긋나지 않음
- [ ] "새 이슈 시작 시" 절차가 issue-workflow.md를 내용 불일치 시 갱신하도록 명시됨
- [ ] `--workflow-only`가 내용 비교 없이 무조건 덮어쓰는 강제 복구로 일반 흐름과 차별화되어 명시됨

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `issue-work/SKILL.md` | 변경 대상 — `--clear`/이슈 완료 절차 |
| `issue-work/templates/issue-workflow-template.md` | 변경 대상 — 이슈 완료 절차 가이드 |
| `git-pr/SKILL.md` | 경계 확인 — 텍스트 작성 전용이므로 비포함 근거 |
