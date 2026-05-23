# Issue #5 스펙 AI-CONTEXT.md에서 로컬 환경 기반 정적 판정 결과 제거 (CoC 일관성)

> GitHub: https://github.com/scroogy-dev/scroogy-agent-skills/issues/5

## 목표 (Goal)

git-tracked 안내도(`.ai/AI-CONTEXT.md`)에서 로컬 부모 디렉토리 구조에 따라 달라지는 *판정 결과* 문구를 제거하고, 판정 *규칙*만 남겨 CoC 원칙과 자기모순을 해소한다.

---

## 범위 (Scope)

**포함 (In)**

- `.ai/AI-CONTEXT.md`의 정적 판정 결과 문구 2곳 제거
  - `## 프로젝트 도메인` 아래의 "단독 repo이므로 ... (CoC 자동 판정 — `../.ai/AI-CONTEXT.md` 부재)"
  - `## 에이전트 운영 지침` 아래의 "본 repo는 단독 repo다."
- 판정 *규칙* 문구는 유지 (상위 안내도 존재 여부로 자동 판정한다는 안내)
- `ai-workspace` SKILL.md의 `init-0단계` / `update-4단계`에서 "판정 결과를 안내도에 기록"하라는 지시가 있는지 점검 및 필요 시 수정
- `ai-workspace-directory` SKILL.md의 자매 정책 일관성 점검

**비포함 (Out)**

- `.ai/AI-CONTEXT.md` 외 다른 섹션의 리팩토링
- 상위 워크스페이스 안내판(`../.ai/AI-CONTEXT.md`)의 구조 변경
- 신규 스킬 추가

---

## 완료의 정의 (Definition of Done)

- [ ] `.ai/AI-CONTEXT.md`에서 정적 판정 결과 2곳이 제거되고, 판정 규칙 문구만 남아 있다.
- [ ] `ai-workspace` SKILL.md와 `ai-workspace-directory` SKILL.md를 검토한 결과, "판정 결과를 git-tracked 파일에 기록"하라는 지시가 없거나, 있다면 같은 원칙에 맞게 수정되었다.
- [ ] 부모 디렉토리에 `.ai/AI-CONTEXT.md`가 있는 환경과 없는 환경 양쪽에서, 안내도 본문이 동일하게 유효한 진입 절차로 동작한다는 점을 문서상 검증한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/AI-CONTEXT.md` | 수정 대상 — 정적 판정 결과 2곳 제거 |
| `ai-workspace/SKILL.md` | 점검 대상 — `init-0단계` / `update-4단계` 지시 검토 |
| `ai-workspace-directory/SKILL.md` | 점검 대상 — 자매 스킬 정책 일관성 |
