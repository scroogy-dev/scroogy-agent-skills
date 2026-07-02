# Issue #37 스펙 issue-work --clear: archive 이관 시 이동 md 본문의 경로 참조 미갱신 (dead link) 개선

> GitHub: [#37](https://github.com/scroogy-dev/scroogy-agent-skills/issues/37)

## 목표 (Goal)

`--clear`(및 `## 이슈 완료 시`) 절차에서 md 파일 이관 후에도 본문 경로 참조가 이관 후 위치 기준으로 유효하도록 갱신 단계와 결정적 검증을 절차에 명시해, PR 리뷰의 dead link 지적 재발을 방지한다.

---

## 범위 (Scope)

**포함 (In)**

- `issue-work/SKILL.md` — `--clear`(archive 이관·99_workspace 정리 이후)와 `## 이슈 완료 시`(archive 이관 이후)에 이관 파일 본문 경로 참조 갱신 규칙 추가
  - 대상 패턴 3종: ① `active/issue-<번호>` 경로 참조 잔존, ② `.ai/99_workspace/` 경로 참조 잔존, ③ 이동으로 인한 상대 링크 깊이 변화
  - 함께 이동한 파일 간 참조는 `./` 상대 링크로 통일 (디렉토리 단위 이관에 안전)
- 이관 이력 표기 표준화 — 새 경로 링크 + "(작성 시점 경로는 …, --clear로 이관)" 병기 (issue-0035 수기 보정 방식의 절차화)
- 이관 완료 후 stale 참조 0건을 확인하는 결정적 검증(grep 스니펫) 절차 추가
- `issue-work/templates/issue-workflow-template.md`(SSoT)와 active 사본 `.ai/90_issues/active/issue-workflow.md`의 `## 이슈 완료 시` 동기화
- 설치본(`~/.claude/skills/issue-work/`) 동기화

**비포함 (Out)**

- 기존 archive 파일의 stale 참조 소급 보정 — 이 이슈는 재발 방지가 목적, 소급 정리는 필요 시 별도 작업
- 다른 스킬(context-save 등) 산출물의 링크 규칙 변경

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D]  SKILL.md의 `--clear`와 `## 이슈 완료 시` 두 절차에 경로 참조 갱신 단계가 있다  (검증: `grep -c '경로 참조 갱신' issue-work/SKILL.md` ≥ 2)
- [ ] [D]  SKILL.md에 이관 후 stale 참조를 확인하는 grep 기반 검증 명령이 기재되어 있다  (검증: `grep -c 'grep -' issue-work/SKILL.md` ≥ 1 — 현재 0건이므로 추가 시에만 통과)
- [ ] [D]  워크플로우 템플릿(SSoT)과 active 사본에도 경로 참조 갱신 규칙이 있다  (검증: `grep -l '경로 참조 갱신' issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md` 두 파일 모두 매칭)
- [ ] [D]  워크플로우 템플릿과 active 사본이 동일하다  (검증: `diff issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md` 차이 없음)
- [ ] [D]  설치본이 repo와 동기화되어 있다  (검증: `diff -rq issue-work ~/.claude/skills/issue-work` 차이 없음)
- [ ] [QD] 절차 문구가 깨짐 패턴 3종(①active 잔존 ②99_workspace 잔존 ③상대 깊이 변화)을 모두 커버하고, 오탐(절차 서술 문구·기록된 검증 명령 인용 등 정당한 옛 경로 표기) 처리 방침을 포함한다  (검증: 교차모델 audit가 채점)  ← 강등 사유: 서술의 의미 커버리지와 오탐 방침의 타당성은 명령으로 판정 불가

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 검증을 `scripts/` 헬퍼로 만들 경우 테스트 위치·배포 제외 규칙 (조건부 — 절차 내 grep 스니펫으로 충분하면 해당 없음) |
| `.ai/90_issues/archive/issue-0031/issue-0031-audit-report.md` | stale 참조 실사례 ① — `active/issue-0031/...` 스펙 출처 잔존 (근거, 명시 참조 시에만 읽음) |
| `.ai/90_issues/archive/issue-0028/issue-0028-summary.md` | stale 참조 실사례 ② — 이관된 audit 리포트를 `.ai/99_workspace/...` 옛 경로로 참조 (근거, 명시 참조 시에만 읽음) |
| `.ai/90_issues/archive/issue-0035/issue-0035-audit-report.md` | 수기 보정 선례 — 새 경로 링크 + 작성 시점 경로 병기 (표준화 원형, 명시 참조 시에만 읽음) |
