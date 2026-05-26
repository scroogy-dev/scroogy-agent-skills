# Issue #11 스펙 디렉토리 표현 순서를 IDE 기준(알파벳 + 디렉토리 우선)으로 통일

> 원본 이슈: https://github.com/scroogy-dev/scroogy-agent-skills/issues/11

## 목표 (Goal)

`.ai` 구조 또는 디렉토리 구조를 트리/표 형태로 표현하는 모든 스킬에서, 표현 순서를 IDE와 동일하게 **알파벳순 + 디렉토리 우선, 파일 후행**으로 명확히 지시한다.

---

## 범위 (Scope)

**포함 (In)**

- `ai-workspace`, `readme-sync`에서 디렉토리 트리/구조를 출력·생성하는 부분의 정렬 규칙 명문화
- 동일 패턴을 사용하는 다른 스킬 식별 후 동일한 정렬 규칙 적용
  - 후보(grep 기준): `ai-workspace-directory`, `code-map`, `context-harvest`, `install-skills`, `issue-work`, `readme-sync`
- 정렬 규칙: 알파벳순(case-insensitive) + 디렉토리가 파일보다 위 + 숨김 항목(`.`로 시작) 처리 기준 명시
- 기존 템플릿(예: `readme-sync/templates/README-template.md`, `issue-workflow-template.md`)의 트리 블록도 새 규칙과 충돌 없는지 점검

**비포함 (Out)**

- 정렬 규칙과 무관한 본문 리라이팅, 디자인 변경
- `.ai` 디렉토리 구조 자체의 변경 (디렉토리 추가·삭제·이름변경)
- 본 repo 외부 도구(IDE 설정 등) 변경

---

## 완료의 정의 (Definition of Done)

- [ ] 디렉토리 표현 순서 규칙이 한 곳(예: 별도 ADR 또는 공통 규칙 문서)에 정의되어 있다 — 또는 각 스킬에 동일한 문장으로 명시되어 있다
- [ ] `ai-workspace`, `readme-sync` SKILL.md에 정렬 규칙(알파벳 + 디렉토리 우선)이 명시되어 있다
- [ ] 동일 패턴을 사용하는 다른 스킬 후보를 모두 점검했고, 영향받는 스킬은 동일 규칙을 명시한다 (해당 없음이면 그 사실을 요약에 기록)
- [ ] 스킬 내부에 예시로 들어 있는 트리 블록이 새 규칙대로 정렬되어 있다
- [ ] 규칙 적용 후 셀프 검증(예: `ai-workspace`로 생성된 트리, `readme-sync` 생성 결과)이 IDE 표시 순서와 일치함을 summary에 기록

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/10_rules/file-change-policy.md` | 파일 변경 규칙 — 기존 스킬 본문 수정 시 준수 |
| `.ai/10_rules/architecture.md` | 아키텍처 방향 — 공통 규칙 위치(공용 vs 스킬별) 결정 시 참조 |
| `.ai/50_adr/` | 정렬 규칙을 ADR로 남길지 결정 시 사용 (현재 비어 있음) |
