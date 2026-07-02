# Issue #37 실행요약 issue-work --clear: archive 이관 시 이동 md 본문의 경로 참조 미갱신 (dead link) 개선

> 스펙: [issue-0037-spec.md](./issue-0037-spec.md) | 계획: [issue-0037-plan.md](./issue-0037-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task N — 교차모델 issue-audit 검증 (사용자 수동 수행)

## 모델 기록

| 구분 | 모델 |
|------|------|
| 계획·구현 모델 | Anthropic, Claude Fable 5 (claude-fable-5) |
| audit 모델 | <!-- 구현 모델과 다른 벤더 모델. 형식: 벤더, 모델명. 마지막 교차모델 audit Task에서 사용자가 기록 --> |

---

## Task별 수행 결과

### Task 1: 경로 참조 갱신 규칙·검증 스니펫 설계

- **결과**: 완료
- **수행 내용 요약**: 갱신 규칙 5항과 검증 스니펫을 확정하고 사용자 승인을 받았다.
  - 갱신 규칙: ① 함께 이동한 파일 간 참조는 `./<파일명>` 상대 링크, ② 이관으로 무효가 되는 경로 참조는 이관 후 위치 기준 재작성, ③ `../` 상대 링크는 이동 후 깊이 재계산, ④ 작성 시점 맥락이 중요한 곳은 표준 병기 문구 "(작성 시점 경로는 `<옛 경로>`, --clear로 이관)", ⑤ archive 파일 본문에 99_workspace 참조를 남기지 않는다(내용이 중요하면 파일 자체를 이관해 `./` 참조, 이력 서술이면 병기).
  - 검증 스니펫: `grep -rnE '90_issues/active/|99_workspace/[A-Za-z0-9_.-]' .ai/90_issues/archive/issue-<번호>/ | grep -v 'active/issue-workflow\.md' | grep -v '작성 시점 경로는'` — 0건 통과, 1건 이상은 AI가 건별 진탐/오탐 판정 (install-skills #35 가드와 동일한 "스니펫 0건 차단 + 1건 이상 AI 확인" 주체 분리).
  - 사용자 논의로 3회 보정: ① 탐지 패턴을 include(`issue-*` 파일명 한정)에서 exclude(상주 파일만 제외)로 반전 — audit 리포트·`skill-audit-*` 등 임의 파일명도 검출, ② `active/issue-workflow.md` 제외 근거 확정 — 이동하지 않는 상주 파일이라 참조가 항상 유효, ③ `99_workspace/notes/` 제외 철회 — "99_workspace는 언제든 비워질 수 있다" 가정으로 예외 없이 검사.
- **특이 사항**: 이 summary 자체가 설계 기록으로 `90_issues/active/`·`99_workspace/` 문자열을 포함하므로, 이슈 0037 이관 시 검증 스니펫에 검출된다 — "일반 서술(설계 기록)" 오탐 판정의 첫 사례가 될 예정.

---

### Task 2: SKILL.md 절차 반영

- **결과**: 완료
- **수행 내용 요약**: `--clear` 동작에 6단계 "경로 참조 갱신·검증"을 신설 — Task 1에서 확정한 갱신 규칙 5항, 검증 스니펫(0건 통과·1건 이상 AI 건별 판정), 제외 2건 근거를 기재. 다중 이슈 처리 문구를 "1~4단계 이슈별 반복 → 5단계 1회 → 6단계는 이관한 이슈 디렉토리별 수행"으로 갱신. `## 이슈 완료 시`에 4단계(경로 참조 갱신·잔존 참조 0건 확인, 규칙은 `--clear` 6단계 참조)를 추가하고, `--clear` 하단의 절차 매핑 노트를 "1·2·4단계" → "1·2·4·6단계"로 갱신.
- **특이 사항**: spec 초안은 "`--clear` 4·5단계에 규칙 추가"로 서술했으나, 갱신이 4·5단계 이동 완료를 모두 전제하므로(이관 후 최종 위치가 확정되어야 재작성 가능) 별도 6단계로 통합 배치 — 중복 서술을 피하고 spec의 In 항목도 위치 중립 문구로 보정. [D] 검증 통과: `grep -c '경로 참조 갱신' issue-work/SKILL.md` = 2 (≥ 2), `grep -c 'grep -' issue-work/SKILL.md` = 3 (≥ 1).

---

### Task 3: 템플릿(SSoT)·active 사본·설치본 동기화

- **결과**: 완료
- **수행 내용 요약**: `issue-work/templates/issue-workflow-template.md`(SSoT)의 `## 이슈 완료 시`에 4단계(경로 참조 갱신·잔존 참조 0건 확인, 규칙은 issue-work `--clear` 6단계 참조)를 추가 — 기존 관례(issue-0031)에 따라 템플릿은 핵심 절차만 1줄로 기재. active 사본 `.ai/90_issues/active/issue-workflow.md`를 `cp`로 동기화하고, 설치본 `~/.claude/skills/issue-work/`에 SKILL.md(Task 2 변경분)와 템플릿을 복사해 동기화.
- **특이 사항**: 동기화 중 cp 인자 실수로 설치본 루트에 템플릿이 잘못 복사됐으나 즉시 제거 후 재검증. [D] 검증 통과: ① `grep -l '경로 참조 갱신'` 템플릿·사본 두 파일 모두 매칭, ② 템플릿-사본 `diff` 차이 없음, ③ `diff -rq issue-work ~/.claude/skills/issue-work` 차이 없음.

---

### Task N: 교차모델 issue-audit 검증 — 사용자 수동 수행

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:
