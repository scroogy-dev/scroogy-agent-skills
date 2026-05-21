# Issue #0003 스펙 에이전트 서치를 위한 스킬 보강

> 원본 이슈: https://github.com/scroogy-dev/scroogy-agent-skills/issues/3

## 목표 (Goal)

`ai-workspace-directory`로 생성된 멀티 repo 워크스페이스에서 Claude Code·Codex·Antigravity 등 임의의 에이전트가 루트의 안내판(`.ai/AI-CONTEXT.md`)만 보고도 관련 repo와 문서를 정확히 찾아 답변할 수 있도록, `ai-workspace-directory`와 `ai-workspace`의 산출물 구조를 보강한다.

---

## 범위 (Scope)

**포함 (In)**

- `ai-workspace-directory` 스킬이 생성·재구성하는 워크스페이스 루트 `.ai/AI-CONTEXT.md`(로비) 구조 보강
  - 에이전트가 "어디를 보면 되는지" 판별할 수 있는 라우팅 신호(인덱스/태그/repo 요약 등) 정의
  - 멀티 repo 환경에서 repo 간 탐색 흐름(루트 로비 → 개별 repo `.ai/` 진입) 명시
- `ai-workspace`가 생성하는 repo별 `.ai/AI-CONTEXT.md`(building) 구조 보강
  - 루트 로비에서 진입한 에이전트가 해당 repo의 코드와 문서를 빠르게 찾아갈 수 있도록 항목 정비
- 두 스킬의 산출물·템플릿이 일관되게 맞물리도록 정렬

**비포함 (Out)**

- 실제 사용자 워크스페이스/repo의 컨텐츠 작성 (스킬과 템플릿 구조만 다룸)
- 신규 스킬 생성 (기존 두 스킬의 보강에 한정)
- 에이전트(클라이언트) 측 설정 변경
- SSOT 정책 변경 — SSOT는 기존과 동일하게 무조건 소스코드

---

## 완료의 정의 (Definition of Done)

- [ ] 멀티 repo 워크스페이스에서 임의의 에이전트가 루트 `.ai/AI-CONTEXT.md`만 읽고도 어떤 repo를 봐야 하는지 판단할 수 있는 라우팅 정보가 로비 구조에 명세되어 있다
- [ ] 루트 로비 → 개별 repo `.ai/AI-CONTEXT.md` → 코드/문서로 이어지는 탐색 흐름이 두 스킬의 SKILL.md(또는 템플릿)에 명시되어 있다
- [ ] `ai-workspace-directory`와 `ai-workspace`의 산출물 항목이 서로 충돌·중복 없이 맞물린다 (양쪽 SKILL.md에서 상호 참조 확인 가능)
- [ ] SSOT는 소스코드라는 원칙이 보강 후에도 두 스킬에서 명시적으로 유지된다 (안내판은 라우터일 뿐, 진실의 원천이 아니라는 점 명문화)
- [ ] 기존에 생성된 워크스페이스/repo에 대해서도 재실행(재구성/갱신) 시 보강된 구조로 정렬되는 절차가 두 스킬에 반영되어 있다

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `ai-workspace-directory/SKILL.md` | 보강 대상 — 루트 로비 생성·재구성 스킬 |
| `ai-workspace/SKILL.md` | 보강 대상 — repo별 `.ai/` 생성·갱신 스킬 |
| `ai-workspace/templates/` | repo 프로파일별 템플릿 (보강 시 동기화 대상) |
| `.ai/AI-CONTEXT.md` | 본 repo의 안내판 — 보강된 구조의 레퍼런스 예시로 활용 |
| `.ai/10_rules/architecture.md` | 아키텍처 방향성 (보강 변경이 기존 원칙과 정합하는지 확인) |
| `.ai/10_rules/context-loading.md` | 컨텍스트 로딩 절차 (에이전트 탐색 흐름과 정합 확인) |
