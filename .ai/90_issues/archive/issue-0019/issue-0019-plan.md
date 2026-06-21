# Issue #19 실행계획 AI 도구 호환성 목록 갱신 (Gemini CLI → Antigravity, Cursor 제외)

> 스펙: [issue-0019-spec.md](./issue-0019-spec.md)

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> 각 작업은 독립적으로 검증 가능해야 합니다.

### Task 1: README.md 갱신

- [x] 완료
- **목표**: README의 도구 나열 문장에서 Gemini CLI → Antigravity, Cursor 제거
- **작업 내용**:
  1. 도구 나열 문장에서 "Gemini CLI"를 "Antigravity"로 교체
  2. 동일 문장에서 "Cursor" 제거 후 어순·구두점 정리
- **완료 기준**: README.md에 "Gemini CLI"·"Cursor" 잔여 없음, 문장이 자연스러움

---

### Task 2: .ai/AI-CONTEXT.md 갱신

- [x] 완료
- **목표**: AI-CONTEXT의 `domain` 행과 본문에서 Gemini CLI → Antigravity, Cursor 제거
- **작업 내용**:
  1. `domain` 행의 "Cursor·Gemini CLI" → "Antigravity"로 정리 (Cursor 제거)
  2. "프로젝트 목적" 본문의 "Cursor, Gemini CLI" → "Antigravity"로 정리 (Cursor 제거)
- **완료 기준**: AI-CONTEXT.md에 "Gemini CLI"·"Cursor" 잔여 없음, 문장이 자연스러움

---

### Task 3: context-save/SKILL.md 갱신

- [x] 완료
- **목표**: SKILL.md의 Gemini CLI 언급(2곳)을 Antigravity로 교체
- **작업 내용**:
  1. 8행 도구 나열에서 "Gemini CLI" → "Antigravity"
  2. 176행 공통 포맷 설명에서 "Gemini CLI" → "Antigravity"
- **완료 기준**: context-save/SKILL.md에 "Gemini CLI" 잔여 없음

---

### Task 4: 잔여 언급 검증

- [x] 완료
- **목표**: archive를 제외한 전체에서 변경 누락이 없는지 확인
- **작업 내용**:
  1. `grep -rn "Gemini CLI\|Cursor" --include="*.md"`로 archive 외 잔여 확인
- **완료 기준**: archive 외 잔여 언급 0건
