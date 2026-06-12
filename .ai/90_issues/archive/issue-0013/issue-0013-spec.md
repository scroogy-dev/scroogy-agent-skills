# Issue #0013 스펙 — Fable 5 + skill-creator 기반 기존 스킬 점검·개선

> GitHub: [scroogy-dev/scroogy-agent-skills#13](https://github.com/scroogy-dev/scroogy-agent-skills/issues/13)

## 목표 (Goal)

2026-06-12 스킬 감사 보고서의 권고 사항을 14개 스킬에 반영하고, 사용자가 클로드 코워크(Fable 5 + skill-creator)에서 재점검하는 loop를 통과하여 스킬의 트리거 정확도·본문 구조·토큰 효율을 개선한다.

---

## 범위 (Scope)

**포함 (In)**

- 감사 보고서 "우선순위별 권고 요약" 1~8번 반영
  - description 트리거 정비 (ai-workspace, git-review-context)
  - 대형 본문 분리 (ai-workspace-directory, code-map → `references/`)
  - 인라인 템플릿 중복 제거 (context-harvest, context-save)
  - git-review placeholder 정리, install-skills 목록 스캔 방식 전환
  - 교차 중복 단일 출처화 설계 판단 (권고 8 — 반영 또는 보류 사유 기록)
- 감사 보고서의 하 심각도 발견 사항 (readme-sync 트리거 패턴, issue-work 플래그 표기, ai-workspace 마이그레이션 섹션 점검)
- 개선 완료 후 사용자 재점검 → 피드백 반영 loop (개선 사항이 없을 때까지 반복)

**비포함 (Out)**

- 새 스킬 추가, 스킬의 기능·동작 변경 (개선 범위는 SKILL.md 문서 품질에 한정)
- `.ai/` 디렉토리 구조 변경
- 감사 보고서 자체의 수정 (보고서는 읽기 전용 근거 자료)

---

## 완료의 정의 (Definition of Done)

- [ ] 권고 1~7이 해당 스킬의 SKILL.md(및 분리 시 `references/`)에 반영됨
- [ ] 권고 8(교차 중복 단일 출처화)에 대한 설계 판단이 기록됨 (반영 또는 보류 사유)
- [ ] 분리·신설된 파일이 각 스킬 본문에서 포인터로 연결되어 단독 실행 가능성이 유지됨
- [ ] 사용자가 클로드 코워크에서 재점검하여 추가 개선 사항이 없음을 확인함

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/99_workspace/skill-audit-report-2026-06-12.md` | 감사 결과·권고의 근거 자료 (이 이슈의 SSoT) |
| `.ai/AI-CONTEXT.md` — "스킬 작성 규칙" 섹션 | SKILL.md 포맷·명명·언어·독립성 규칙 |
| `.ai/10_rules/context-loading.md` | 작업 전 컨텍스트 확인 절차 |

> `30_contract/`, `40_domain/`, `50_adr/` index를 훑은 결과 이 이슈와 연관된 문서는 없음.
