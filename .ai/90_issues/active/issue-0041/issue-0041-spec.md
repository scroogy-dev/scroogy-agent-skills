# Issue #41 스펙 — ai-workspace writing-principles 참조 경로 보강

> 이슈: https://github.com/scroogy-dev/scroogy-agent-skills/issues/41

## 목표 (Goal)

배포만 되고 참조가 끊긴 `writing-principles.md`를 에이전트가 실제로 안내받도록, 참조 경로 두 곳(`context-loading.md` 라우팅, AI-CONTEXT.md `## 프로젝트 규칙` 행 멱등 보강)을 잇는다.

---

## 범위 (Scope)

**포함 (In)**

- 템플릿 `ai-workspace/templates/shared/.ai/10_rules/context-loading.md`에 "산출 문서·PR·이슈·리뷰 코멘트 작성 시" 라우팅 섹션 추가 (`writing-principles.md` + `writing-principles-local.md`, 충돌 시 local 우선)
- `ai-workspace/SKILL.md` update-4단계 멱등 보강 검사 표에 `## 프로젝트 규칙` 표의 `writing-principles.md` 행 검사 추가 (누락 시 표준 행 삽입, 사용자 작성 행 보존)
- 같은 검사 표에 `context-loading.md` 행 검사 추가 — 버전 고정 파일 2종(파일은 무조건 덮어쓰기)의 안내도 행 보장을 같은 조건으로 통일 (사용 시점 문구는 프로파일별 구분: dev "코드·문서 작업 전" / doc "문서 작업 전")
- 이 repo 설치본 반영: `.ai/10_rules/context-loading.md`, `.ai/AI-CONTEXT.md` `## 프로젝트 규칙` 표
- 홈 설치본(`~/.claude/skills/ai-workspace`) 동기화

**비포함 (Out)**

- 각 산출물 생산 스킬(git-pr·git-review·issue-work 등) 본문에 참조 명시 — #39 후속 작업으로 분리됨
- `writing-principles.md` 내용 자체 변경
- AI-CONTEXT.md 템플릿 변경 — 라우터 행이 이미 있어 확인만

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D]  템플릿 `context-loading.md`에 산출물 작성 라우팅 섹션이 있음  (검증: `grep -c 'writing-principles' ai-workspace/templates/shared/.ai/10_rules/context-loading.md` ≥ 2)
- [ ] [D]  `ai-workspace/SKILL.md` 멱등 보강 검사 표에 `## 프로젝트 규칙` 행 검사 항목이 있음  (검증: `grep -c '프로젝트 규칙.*writing-principles\|writing-principles.*프로젝트 규칙' ai-workspace/SKILL.md` ≥ 1)
- [ ] [D]  같은 검사 표에 `context-loading.md` 행 검사 항목이 있음  (검증: `grep -c '프로젝트 규칙.*context-loading\|context-loading.*프로젝트 규칙' ai-workspace/SKILL.md` ≥ 1)
- [ ] [D]  이 repo 설치본 `.ai/10_rules/context-loading.md`가 템플릿과 동일함  (검증: `diff ai-workspace/templates/shared/.ai/10_rules/context-loading.md .ai/10_rules/context-loading.md` 차이 0건)
- [ ] [D]  이 repo `.ai/AI-CONTEXT.md`의 `## 프로젝트 규칙` 표에 `writing-principles.md` 행이 있음  (검증: `grep -c 'writing-principles' .ai/AI-CONTEXT.md` ≥ 1)
- [ ] [D]  홈 설치본이 repo와 동기화됨  (검증: `diff -r ai-workspace ~/.claude/skills/ai-workspace` 차이 0건)
- [ ] [QD] update 재실행 시 기존 사용자 작성 행·섹션이 보존됨  (검증: 모의 실행 확인)  ← 강등 사유: update는 AI 수행 절차라 산출이 비결정적 — 별도 모의 실행으로 채점

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/10_rules/context-loading.md` | 수정 대상 설치본이자 공통 규칙 (버전 고정, 스킬 독립성의 참조 지점) |
| `.ai/AI-CONTEXT.md` | 수정 대상 안내도 (`## 프로젝트 규칙` 표) |
| `.ai/90_issues/archive/issue-0039/` | 선행 이슈(#39, writing-principles SSoT 배포) 이력 — 필요 시에만 참조 |
