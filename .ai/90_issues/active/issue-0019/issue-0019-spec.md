# Issue #19 스펙 AI 도구 호환성 목록 갱신 (Gemini CLI → Antigravity, Cursor 제외)

## 목표 (Goal)

문서에 나열된 호환 AI 도구 목록에서 "Gemini CLI"를 "Antigravity"로 바꾸고 "Cursor"를 제거한다.

---

## 범위 (Scope)

**포함 (In)**

- `README.md` — 도구 나열 문장의 "Gemini CLI" → "Antigravity", "Cursor" 제거
- `.ai/AI-CONTEXT.md` — `domain` 행 및 본문의 "Gemini CLI" → "Antigravity", "Cursor" 제거
- `context-save/SKILL.md` — "Gemini CLI" 언급(2곳) → "Antigravity"
- 도구 나열 문장의 어순·구두점 자연스럽게 정리

**비포함 (Out)**

- `.ai/90_issues/archive/` 하위 과거 이슈 문서 (이력 보존, 수정하지 않음)
- 도구 목록과 무관한 본문 내용 변경

---

## 완료의 정의 (Definition of Done)

- [ ] `README.md`, `.ai/AI-CONTEXT.md`, `context-save/SKILL.md`에서 "Gemini CLI"가 "Antigravity"로 모두 교체됨
- [ ] `README.md`, `.ai/AI-CONTEXT.md`에서 "Cursor" 언급이 제거됨
- [ ] 도구 나열 문장의 어순·구두점이 자연스럽게 정리됨
- [ ] archive를 제외한 전체 `*.md`에 "Gemini CLI"·"Cursor" 잔여 언급이 없음 (grep 확인)

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `README.md` | 변경 대상 — 도구 호환성 나열 문장 |
| `.ai/AI-CONTEXT.md` | 변경 대상 — `domain` 행 및 프로젝트 목적 본문 |
| `context-save/SKILL.md` | 변경 대상 — Gemini CLI 언급 부분 |
