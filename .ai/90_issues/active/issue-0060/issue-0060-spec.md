# Issue #60 스펙 — 스킬 산출물 접기(`<details>`) 적용 지점 명시

## 목표 (Goal)

산출물 작성 스킬 8종의 SKILL.md·템플릿에 접기 기준과 구조를 명시하여, GitHub 이슈·PR·댓글·md 리포트가 접힘 구조로 작성되게 한다.
아울러 `.ai/` 구조가 있는 repo에서는 `writing-principles.md`·`writing-principles-local.md`를 직접 참조하도록 연결해, 내장 기준을 넘어 전체 작성 원칙과 repo 고유 확장이 발동하게 한다 (2026-07-30 범위 확장).

---

## 배경 근거 (2026-07-30 문답)

> 질문: 스킬들이 `writing-principles.md`의 산출물 작성 원칙대로 동작하지 않는 이유는? (예: git-pr 본문이 너무 길게 작성됨)

- **참조가 2단계 간접 연결**: SKILL.md → `context-loading.md` → `writing-principles.md`로 두 번 건너야 도달하고, 그마저 "있으면 따르며" 조건부 참조라 스킬 실행 시점에 규칙이 적재되지 않는 경우가 많다.
- **가까운 구체 지시가 먼 추상 원칙을 이긴다**: SKILL.md 본문의 출력 형식(이슈별 비즈니스/테크 관점 등)은 구체적이고, 접기·분량 제약은 다른 파일에 있는 추상 규칙이라 실질적으로 무시된다. `writing-principles.md` 스스로도 "템플릿이 구조를 정의하면 템플릿 우선"이라 선언한다.
- **검증 지점 부재**: 산출물이 접기·분량 규칙을 지켰는지 점검하는 단계가 스킬 절차에 없다.
- **다른 repo에서는 사슬 자체가 없다**: 스킬은 설치 경로(`~/.claude/skills/` 등)에서 어느 repo에서든 실행되는데, 대상 repo에 ai-workspace를 적용하지 않았으면 `.ai/10_rules/writing-principles.md` 자체가 없어 참조가 원천 단절된다.

→ 이 진단이 이번 이슈의 방식(공통 규칙 참조가 아니라 **접기 기준을 각 SKILL.md·템플릿에 직접 반영**)을 뒷받침하는 구체 근거다.

**후속 문답 (같은 날, 범위 확장 근거)**: 내장 블록은 접기 규칙 하나의 스냅샷이라, 분량 예산 등 나머지 원칙과 repo 고유 확장(`writing-principles-local.md`)은 여전히 발동하지 않는 공백이 남는다. 참조 **전용** 방식(버린 대안)과 달리 **내장 기본값 + 조건부 직접 참조** 혼합형은 스킬 독립성을 유지하면서 이 공백을 메우므로 채택한다. 내장 블록과 파일의 버전 표류를 막기 위해 우선순위 문구(local > writing-principles.md > 내장 기준)를 함께 명시한다.

---

## 범위 (Scope)

**포함 (In)**

- 대상 스킬 8종: git-pr, git-qa, issue-work, issue-audit, git-review, git-review-context, context-save, context-harvest
- 각 SKILL.md에 산출물 접기 기준 고정 블록 추가
- 산출물 템플릿·SKILL.md 내 출력 형식의 접기 가능 섹션에 `<details>` 구조 반영
- 8종 SKILL.md에 `writing-principles.md`·`writing-principles-local.md` 조건부 참조 추가 및 내장 접기 기준 블록에 우선순위 문구 명시 (2026-07-30 범위 확장)

**비포함 (Out)**

- git-commit·install-skills·issue-model-triage·ai-workspace 계열·code-map·readme-sync (제외 근거는 이슈 #60 본문)
- `writing-principles.md` 원본·사본 수정 (접기 기준 자체는 바꾸지 않음 — 기존 기준을 스킬로 전파만)
- 이미 작성된 과거 산출물의 소급 수정
- 분량 예산(요약 200자·항목당 3문장 등)의 스킬 전파 — 접기 적용 후에도 길이 문제가 남으면 별도 이슈로 다룬다 (2026-07-30 문답에서 확인)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [x] [D] 대상 8종 SKILL.md 각각에 `## 산출물 접기 기준` 섹션이 정확히 1개 존재  (검증: repo 루트에서 `n=$(for f in git-pr git-qa issue-work issue-audit git-review git-review-context context-save context-harvest; do grep -c '^## 산출물 접기 기준$' "$f/SKILL.md"; done | grep -c '^1$'); [ "$n" -eq 8 ] && echo PASS` 출력 `PASS`)
- [x] [D] 접기 구조 확정 적용 세트 10개 파일 전부에 `<summary>` 태그 존재  (검증: repo 루트에서 `grep -l '<summary>' issue-audit/templates/issue-audit-report-template.md context-save/templates/context-note-template.md context-harvest/templates/30_contract-template.md context-harvest/templates/40_domain-template.md context-harvest/templates/50_adr-template.md git-pr/SKILL.md git-qa/SKILL.md git-review/SKILL.md git-review-context/SKILL.md issue-work/SKILL.md | wc -l` 출력 `10`)
- [ ] [QD] 접기 가능/금지 판정이 `writing-principles.md` 기준과 정합 — 결정사항·리스크·액션 아이템(테스트 체크리스트 포함)이 접히지 않음  (검증: 교차모델 audit 채점)  ← 강등 사유: 섹션의 의미 분류(근거인가 결정인가)는 명령으로 환원 불가
- [ ] [QD] 8종 SKILL.md의 접기 기준 블록 문구가 `writing-principles.md` 접기 규칙과 불일치 없음  (검증: 교차모델 audit 대조)  ← 강등 사유: 의미 동치 비교는 명령으로 환원 불가
- [x] [D] 8종 SKILL.md 전부에 `writing-principles-local.md` 참조 존재  (검증: repo 루트에서 `n=$(for f in git-pr git-qa issue-work issue-audit git-review git-review-context context-save context-harvest; do grep -l 'writing-principles-local\.md' "$f/SKILL.md"; done | wc -l); [ "$n" -eq 8 ] && echo PASS` 출력 `PASS`)
- [x] [D] 8종 접기 기준 블록에 우선순위 폴백 앵커 문구 존재  (검증: repo 루트에서 `grep -l '이 블록은 파일이 없을 때의 기본값' git-pr/SKILL.md git-qa/SKILL.md issue-work/SKILL.md issue-audit/SKILL.md git-review/SKILL.md git-review-context/SKILL.md context-save/SKILL.md context-harvest/SKILL.md | wc -l` 출력 `8`)
- [ ] [QD] 참조·우선순위 서술이 `writing-principles.md`의 우선순위 선언(local 우선)과 불일치 없음  (검증: 교차모델 audit 대조)  ← 강등 사유: 의미 동치 비교는 명령으로 환원 불가

---

## 전제 (Assumptions)

- 반영 방식(템플릿 직접 반영 + SKILL.md 기준 요약)과 대상 범위(GitHub 게시물 + 로컬 md 리포트)는 사용자 승인으로 확정됨 — 근거는 이슈 #60 본문 (2026-07-30)
- `writing-principles.md`는 ai-workspace가 배포하는 SYNCED 사본 (원본: `ai-workspace/templates/shared/.ai/10_rules/writing-principles.md`) — 이번 이슈에서 원본·사본 모두 수정하지 않는다
- SKILL.md 접기 기준 블록의 헤더는 `## 산출물 접기 기준` 고정 — DoD 검증 명령의 앵커이므로 문구를 바꾸면 검증 명령도 함께 갱신한다
- `<summary>` 문자열은 접기 구조 반영의 검증 앵커 — Task 1의 기준 블록 서술에는 `<summary>` 단어를 쓰지 않는다 (기준 서술만으로 DoD 2번이 통과되는 우회 차단, 서술에는 `<details>`만 언급)
- issue-work plan·summary 템플릿의 기존 `[D]` 검증 앵커 행(`^### Task `, `^- \*\*결과\*\*:`, `^- \*\*수행 모델\*\*:` 등)은 접기 구조로 행 형식을 바꾸지 않는다
- 검토 후 버린 대안: 공통 규칙 파일 **참조 전용** 방식(파일이 없으면 기준 자체가 실종되는 스킬 독립성 위반으로 배제 — 내장 기본값을 유지한 채 조건부 참조를 더하는 혼합형은 2026-07-30 후속 문답으로 채택, `배경 근거` 참조), readme-sync 포함(사용자 선택으로 제외 — README는 코드베이스 내 문서라 writing-principles 적용 제외 대상이기도 함)
- 이번 이슈는 repo 소스(SKILL.md·템플릿)만 수정한다 — 설치 경로(`~/.claude/skills/` 등 5개) 반영은 install-skills 재실행으로 별도 수행한다 (Task 0에서 확인, repo 관례로 해소)
- 참조·내장 기준의 우선순위는 `writing-principles-local.md` > `writing-principles.md` > SKILL.md 내장 기준(파일이 없을 때의 기본값)으로 고정 — 우선순위 앵커 문구 `이 블록은 파일이 없을 때의 기본값`은 DoD 검증 앵커이므로 문구를 바꾸면 검증 명령도 함께 갱신한다 (2026-07-30 범위 확장)

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/10_rules/writing-principles.md` | 접기 규칙 기준 (SYNCED 사본 — 읽기 전용 참조) |
| [이슈 #60 본문](https://github.com/scroogy-dev/scroogy-agent-skills/issues/60) | 확정된 반영 방식·대상 범위·제외 근거 |
