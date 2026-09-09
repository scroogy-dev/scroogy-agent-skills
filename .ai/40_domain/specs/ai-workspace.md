---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/3
last_harvested: 2026-09-09
---

# .ai 작업공간과 안내도 요건 (ai-workspace·ai-workspace-directory)

## 요건

- ai-workspace는 개별 repo의 층 안내도(`.ai/AI-CONTEXT.md`)와 `.ai/` 구조를, ai-workspace-directory는 멀티 repo 워크스페이스 루트의 로비 안내도(`<워크스페이스 루트>/.ai/AI-CONTEXT.md`)를 담당한다. 둘은 자매 스킬이며 모든 안내도는 각자의 `.ai/` 안에 둔다.
- ai-workspace-directory: `init`/`update` 모드, 로비 파일 존재로 모드 자동 판정. 표준 섹션 구조 강제, 분량 가드레일, SSoT 위배 진단 체크리스트(`check-lobby.sh`). 안내도 부재 repo는 `status: placeholder`, `archived`는 drift 검사 제외. git 명령에 의존하지 않는다.
- ai-workspace: `init`(전체 초기화, 복사 전 기존 `.ai/` 제거)/`update`(멱등 보강) 모드, dev/doc 프로파일. update는 사용자 작성분을 보존하고 버전 고정 파일(`context-loading.md`, `writing-principles.md`)만 덮어쓴다. 사용자 관리 파일(`writing-principles-local.md`, `architecture.md`, `coding-convention.md`)은 없을 때만 빈 템플릿을 복사한다.
- update 구조 정합: 정의된 디렉토리 생성, 신규 디렉토리(`70_ledger/`)와 골격 index 전파(설치본에 있으면 미덮어씀), 기존 파일 정리 시 루트 상주 파일(각 index.md, `40_domain/glossary.md`) 제외. 원장 항목은 `- **상태**:` 앵커 값으로 이동 판단.
- update 멱등 보강 검사(`check-context.sh` 8종 + AI 판정 2종): `## 프로젝트 규칙` 표 존재·3열, `context-loading.md` 행, `writing-principles.md` 행, `## 프로젝트 도메인`, `## 에이전트 운영 지침`, 트리 정렬 등. 2열 표는 열 확장만 하고 구버전 기본 행 복원은 별도 마이그레이션 경로다. `## Git 정책` 표는 검사하지 않는다(#70 미해결 리스크).
- 두 스킬 모두 `> last updated:` 자동 갱신, 판정 결과(멀티/단독)를 안내도 본문에 기재하지 않는다.
- 로비 `Repos` 4열(path, domain, keywords, status)이 라우팅 신호이며 층 안내도 `## 프로젝트 도메인` 표와 1:1 동기화한다.
- `.ai/` 읽기 우선순위: 10_rules(1순위) → 30_contract(2) → 40_domain(3) → 50_adr(4) → 60_codebase(5) → 70_ledger(6). 90_issues, 99_workspace는 작업 영역이다.
- 산출물 스킬 8종은 `.ai/`가 없어도 동작하도록 접기 기준을 내장한다(ai-workspace 배포에 의존하지 않음).

## 관련 결정

- 정책 [SSoT 원칙과 안내도 라우터](../policies/local/ssot-and-router-principle.md), [ADR 0003](../../50_adr/active/0003-verification-levels-and-determinization.md), [ADR 0007](../../50_adr/active/0007-tech-debt-ledger-location-and-structure.md), [ADR 0008](../../50_adr/active/0008-writing-principles-ssot-distribution.md)
- 절차 상세는 `ai-workspace/SKILL.md`, `ai-workspace-directory/SKILL.md`와 각 `templates/`·`references/`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #1](https://github.com/scroogy-dev/scroogy-agent-skills/issues/1), [#3](https://github.com/scroogy-dev/scroogy-agent-skills/issues/3), [#5](https://github.com/scroogy-dev/scroogy-agent-skills/issues/5), [#39](https://github.com/scroogy-dev/scroogy-agent-skills/issues/39), [#41](https://github.com/scroogy-dev/scroogy-agent-skills/issues/41), [#61](https://github.com/scroogy-dev/scroogy-agent-skills/issues/61), [#70](https://github.com/scroogy-dev/scroogy-agent-skills/issues/70), [#90](https://github.com/scroogy-dev/scroogy-agent-skills/issues/90)
- [PR #40 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/40), [PR #91 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/91)

</details>
