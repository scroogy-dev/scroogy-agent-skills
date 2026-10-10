# Issue #108 실행요약 issue-work·issue-audit: 회귀 방지 항목 표시 규칙을 spec 템플릿에 도입하고 고정 블록을 가짜 [D] 사전 판별에서 제외

> 스펙: [issue-0108-spec.md](./issue-0108-spec.md) | 계획: [issue-0108-plan.md](./issue-0108-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다.

## 모델 기록

| 구분 | 모델 | effort |
|------|------|--------|
| 계획 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | high |
| 계획 audit 모델 | OpenAI, GPT-6.1 (gpt-6.1-sol) | high |
| 구현 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | high |
| 최종 audit 모델 | OpenAI, GPT-6.1 (gpt-6.1-sol) | high |

- **계획 감사**: 수행 · 발견 1건 · 보정 1건

---

## Task별 수행 결과

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: 전제·모호점 3건을 사용자에게 질의해 spec `## 전제`에 반영했다(ADR 0016 기록 위치, K-0009 처리, 색인 frontmatter). 문서 관례로 정할 수 있는 1건(`last_harvested` 미갱신)은 선례를 근거로 같은 전제 항목에 함께 적었다. 미해소 0건.
- **특이 사항**: plan Task 3.4가 ADR 0016에 없는 "결과 절"을 가리켜 결정 절 보강으로 고쳤다. Task 3.5·4.2도 확정한 전제를 참조하도록 문구를 맞췄다.

---

### Task 1: issue-work 회귀 방지 항목 표시 규칙 도입

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: spec 템플릿 완료의 정의 주석에 `(회귀 방지 항목)` 표시 규칙(대상·본문 끝 위치·접기 안 미인정)을 더했다. `### R1:` `[D]` 예시 본문을 "문서에 줄 끝 공백이 남지 않는다"로 구체화해 표시했고, `### 공통` 예시에도 표시했다. SKILL.md `### 완료 기준 형식`에 표시 규칙 한 줄을 더했다. R1·R2 `[D]` 명령 3건 출력 0건, issue-work 테스트 통과.
- **특이 사항**: `### 공통` 예시는 placeholder 문장을 유지하고 표시만 붙였다(spec 전제는 R1 예시만 구체화). R1-3·R2-2 `[QD]`는 Task N 교차모델 audit 채점 대상이다.

---

### Task 2: issue-audit 관점 2 고정 블록 제외와 Task N 주석

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: issue-audit SKILL.md `--plan` 관점 2 행에 issue-work 템플릿 고정 블록(Task 0·Task N) 제외와 근거 3가지를 같은 행에 더하고, 이슈별 spec DoD·plan 일반 Task는 그대로 판별한다고 밝혔다. 기존 표시 문구는 리터럴 `(회귀 방지 항목)`으로 맞추고 "spec 항목 본문"은 유지했다. plan 템플릿 Task N 첫 주석에 관점 2 예외 안내 한 줄을 더했다. R3·R4 `[D]` 명령 4건 출력 0건, issue-audit·issue-work 테스트 통과.
- **특이 사항**: 이 이슈의 plan Task N 블록은 템플릿 변경 전 사본이라 소급 갱신하지 않았다. R3-3 `[QD]`는 Task N 교차모델 audit 채점 대상이다.

---

### Task 3: 안내도·ADR 정합

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `.ai/40_domain/specs/issue-audit.md` `--plan` 모드 행과 `.ai/60_codebase/issue-audit/plan-audit-call-flow.md` 가짜 [D] 사전 판별 행에 고정 블록(Task 0·Task N) 제외와 `(회귀 방지 항목)` 표시 예외를 더했다. `.ai/40_domain/specs/issue-workflow.md` spec 구성 행에 표시 규칙을 더했다. ADR 0016 결정 절 `--plan` 항목에 고정 블록 제외를 덧붙이고 근거 한 줄과 원본 출처 #108을 더했다. 색인 `last_synced`는 2026-10-10으로 갱신했다. R5·R7 `[D]` 명령 4건 출력 0건, 전체 스킬 테스트 통과.
- **특이 사항**: ADR 판단은 새 ADR 없이 0016 보강이다. 0016의 결정은 "`--plan` 2단계에 가짜 `[D]` 사전 판별을 감사인 수동으로 둔다"이며, 이번 변경은 그 판별의 대상 범위(고정 블록 제외)와 예외 표시 형식을 정한 것이라 결정 자체(관점 구성·수동 수행·헬퍼 보류)는 그대로다. 그래서 ADR 집합과 index는 바뀌지 않았다. `source_hash`와 `last_harvested`는 spec 전제 "색인 frontmatter"대로 두었다.

---

### Task 4: 원장 K-0011 승격·K-0009 재검토

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: K-0011의 상태를 `승격(이슈 #108)`으로 바꾸고 재검토 이력에 승격 행을 더한 뒤 `git mv`로 `archive/`로 옮겼다. K-0009는 재검토 이력에 #108 행을 더해 계속 수용으로 두고, 수용 사유와 재검토 조건을 spec 전제 "K-0009 처리"대로 고쳤다. 원장 index의 K-0011·K-0009 행과 `.ai/60_codebase/index.md`의 K-0011 링크를 갱신했다. R6 `[D]` 명령 3건과 Task 4 링크 검사 출력 0건, 전체 스킬 테스트 통과.
- **특이 사항**: 원장 index의 종결 항목 `재검토 조건` 열은 기존 선례가 없어 `-`로 적었다. K-0011 파일 본문의 `재검토 조건` 필드는 종결 당시 기준으로 남겼다.

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

- **결과**: 완료
- **수행 내용 요약**: 사용자가 OpenAI GPT-6.1(effort high)로 최종 감사 1차를 수행했다([issue-0108-audit-report.md](./issue-0108-audit-report.md), 종합 적합(PASS)). 1단계 충족 27건·미충족 0건, 2단계 신규 발견 0건, 기등재 참조 2건(K-0009·K-0011)이다. `--response` 검토 결과 보정 대상이 없어 보정 0건이다.
- **특이 사항**: 리포트가 범위 밖 유지보수 사항으로 남긴 `.ai/60_codebase/index.md` 태그 현황 문구는 `/code-map --local` sync로 갱신했다. 감사인은 GitHub 연결 실패로 이슈 본문을 다시 확인하지 못해 로컬 spec 기준으로 판정했다.
