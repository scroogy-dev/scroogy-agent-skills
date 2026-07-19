# Issue #50 스펙 — plan Task별 완료 기준에 검증 레벨 표기 도입

## 목표 (Goal)

issue-work plan 템플릿의 Task별 완료 기준을 spec 완료의 정의와 같은 검증 레벨 표기 — 결정적(`[D]`) / 준결정적(`[QD]`) / 비결정적(`[ND]`) — 와 항목별 리스트 형식으로 전환하고 결정적 우선 원칙을 명시하여, 작성 세션에 참여하지 않은 쪽도 문서만으로 Task 합/불을 판정할 수 있게 한다.

---

## 범위 (Scope)

**포함 (In)**

- `issue-work/templates/issue-plan-template.md`
  - `## Tasks` 안내 블록: 작성 원칙 문구(문서 외 컨텍스트 없음 가정 + 결정적 우선)와 검증 레벨 안내 추가 — spec 템플릿의 검증 레벨 인용 블록과 표기 통일
  - Task 1·2 예시 블록: `완료 기준`을 한 줄 서술에서 항목별 레벨 태그 리스트로 교체 (항목 형식: 레벨 태그 + 검증 수단 + 강등 사유)
  - Task 0 고정 블록: `완료 기준`을 같은 리스트 형식으로 정리
  - Task N 고정 블록: `완료 기준`을 같은 리스트 형식으로 분해
- `issue-work/SKILL.md`: `## 작업 진행 중`의 완료 기준 문장 확인, 새 형식과 어긋나면 소폭 보정
- `issue-work/tests/run-tests.sh` (신규): Task N `[D]` 게이트 명령의 반례 회귀 테스트 — 2차 audit F-1·F-2 보정에 대한 `--response` 항목별 승인으로 범위 확장 (2026-07-19)

**비포함 (Out)**

- spec 템플릿의 완료의 정의 표기 — 이미 체계가 있어 변경하지 않음
- `.ai/90_issues/archive/` 과거 plan — 완료 이슈의 이력 기록이라 소급하지 않음
- 설치본(`~/.claude/skills/` 등 5개 경로) 갱신 — `install-skills` 재설치로 별도 수행

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [x] [D] plan 템플릿 `## Tasks` 안내 블록에 "문서 외 컨텍스트 없음 가정" 축 명시  (검증: `awk '/^## Tasks/,/^### Task 0/' issue-work/templates/issue-plan-template.md | grep -c '문서 외 컨텍스트'` ≥ 1)
- [x] [D] 검증 레벨 안내 3행이 spec 템플릿과 표기 동일  (검증: `diff <(grep -E '^> - ' issue-work/templates/issue-spec-template.md) <(awk '/^## Tasks/,/^### Task 0/' issue-work/templates/issue-plan-template.md | grep -E '^> - ')` 출력 0건)
- [x] [D] Task 0·1·2·N 각 블록의 `완료 기준`에 레벨 태그 항목 1개 이상  (검증: plan Task 2~4의 블록별 `sed` 추출 + `grep -cE '\- \[(D|QD|ND)\]'` 명령, 4개 블록 전부 ≥ 1)
- [x] [D] Task N 블록에 `[D]` 항목과 `[QD]`/`[ND]` 항목이 각 1개 이상 혼재  (검증: `sed -n '/^### Task N/,$p' issue-work/templates/issue-plan-template.md`에 태그별 `grep -cE` 각 ≥ 1)
- [x] [D] Task 헤더 행 구조 유지 — `^### Task ` 4건, 그 외 0건  (검증: `grep -cE '^### Task ' issue-work/templates/issue-plan-template.md` = 4)
- [x] [QD] Task 0·N 고정 블록의 기존 조건·강등 사유가 리스트 분해 후에도 누락 없음  (검증: 교차모델 audit이 개정 전후 대조 채점)  ← 강등 사유: 조건 보존 여부는 의미 대조라 명령으로 환원 불가
- [x] [ND] SKILL.md `## 작업 진행 중` 완료 기준 문장이 새 형식과 모순 없음  (검증: 사람 리뷰)  ← 강등 사유: 위임 문장과 새 형식의 정합 여부는 의미 판단
- [x] [D] Task N `[D]` 게이트 명령이 정상 fixture를 통과시키고 반례 fixture(미확정 상쇄·행 누락·중복·허용 외 값·빈 값·`-`)를 격추  (검증: `bash issue-work/tests/run-tests.sh` 종료 코드 0, 실패 0건)

---

## 전제 (Assumptions)

- repo 원본(`issue-work/…`)이 SSoT이고 `~/.claude/skills/issue-work/…` 설치본은 사본이다 — 구현은 repo 파일만 수정하며, 설치본 갱신은 `install-skills` 재설치로 별도 수행한다. 작성 시점에 두 경로의 plan 템플릿·SKILL.md는 diff 0건으로 동일 확인.
- 표기 통일의 기준은 spec 템플릿 쪽이다 — L1/L2/L3 병기를 포함한 spec의 검증 레벨 인용 블록을 plan에 그대로 복제하고, spec 템플릿은 손대지 않는다.
- 이 이슈의 plan(`issue-0050-plan.md`)은 개정 전 템플릿으로 생성하되 Task별 완료 기준은 목표 형식(레벨 태그 리스트)을 선적용했다 — 템플릿 개정 결과와 세부 문구가 달라도 소급 수정하지 않는다.
- Task N `[D]` 게이트 명령의 SSoT는 plan 템플릿 인라인 명령이다 — 인스턴스화된 plan은 어느 repo·AI 도구에서도 자족해야 해서 `scripts/` 헬퍼 참조로 바꾸지 않고, 테스트가 템플릿 본문에서 명령을 추출해 fixture에 실행함으로써 문서와 검증의 드리프트를 막는다 (`install-skills` SKILL.md 스니펫 스모크와 같은 방식, 2차 audit `--response` 승인으로 확정).

---

## 연관 문서

> `.ai/30_contract/`·`40_domain/`·`50_adr/` index를 훑은 결과 직접 연관 문서 없음 — 수정 대상·기준 파일만 나열한다.

| 문서 | 역할 |
|------|------|
| `issue-work/templates/issue-plan-template.md` | 주 수정 대상 |
| `issue-work/templates/issue-spec-template.md` | 검증 레벨 표기 통일 기준 (수정 없음) |
| `issue-work/SKILL.md` | 부 수정 대상 — `## 작업 진행 중` 완료 기준 문장 |
| `.ai/10_rules/writing-principles.md` | 산출 문서 서술 원칙 |
