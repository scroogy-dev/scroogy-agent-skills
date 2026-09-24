# Issue #104 실행요약 모델 기록 형식에 모델 ID 병기 도입

> 스펙: [issue-0104-spec.md](./issue-0104-spec.md) | 계획: [issue-0104-plan.md](./issue-0104-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task 4 — .ai 안내도 정합

## 모델 기록

| 구분 | 모델 | effort |
|------|------|--------|
| 계획 모델 | Anthropic, Claude Fable 5.1 (claude-fable-5-1) | high |
| 계획 audit 모델 | OpenAI, GPT-6 (gpt-6-astra) | high |
| 구현 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | high |
| 최종 audit 모델 |  |  |

- **계획 감사**: 수행 · 발견 4건 · 보정 3건 (1차 F-1 회귀 방지·선행 조건 표시 6건, Task N 고정 블록 2건은 유지 / F-2 R1-b·R2 `[D]` 계약 문구 검사로 좁힘과 Task 1 `[QD]` 채점 책임 연결 / F-3 줄 끝 공백 예외를 "두 칸 이상"으로 확정 / 2차 F-4 예외 표기 잔여는 원장 K-0011 이관)

---

## Task별 수행 결과

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: 실행 기록을 대조해 전제·모호점 4건을 질의하고 답변을 spec `## 전제`에 반영했다. R1-b의 적용 대상을 실행 기록 `model` 값에서 모델 ID 전반으로 넓혔고(실행 기록 `model` 값에는 접미어 0건), 예시 구분자 ` / `는 유지, Codex 자동 리뷰 세션은 R2 문장에 안내하지 않기로 정했다. 예시 ID 값(`gpt-6-astra`, Google `(-)`)도 전제에 적었다.
- **특이 사항**: R1-b 문구가 바뀌어 요구사항 승인 게이트를 다시 거쳤다(2026-09-25 승인). Codex 실행 기록(`gpt-6-astra`, `high`)을 근거로, 사용자 승인을 받아 `계획 audit 모델` 행을 `OpenAI, GPT-6 (gpt-6-astra)` / `high`로 보정했다.

---

### Task 1: issue-work 템플릿 3종·SKILL.md 형식 확장

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: summary 템플릿의 `모델 기록` 주석·표 4행 셀 주석·`수행 모델` 규칙을 "벤더, 모델명 (모델 ID)"로 바꿨다. 괄호 안은 모델 ID 전용이라는 문장, 확인 불가 `(-)`, 항목마다 괄호를 붙인 나열 예시를 넣었다. plan 템플릿 Task N `[QD]` 문장(awk는 그대로 둠)과 workflow 템플릿 완료 조건을 고치고 `active/issue-workflow.md`를 동기화했다. SKILL.md에는 형식 언급 4곳을 고치고, `수행 effort` 소절에 모델 ID 읽기(`model`·`payload.model`, effort와 같은 레코드)·컨텍스트 접미어 제거·`(-)` 처리를 넣었다. spec R1 `[D]` 5건과 R2 `[D]` 1건이 통과했고, issue-work 테스트는 107건 모두 통과했다.
- **특이 사항**: R1-4 정규식은 새로 넣은 나열 예시(64행) 외에 `모델 기록` 주석의 예시 줄(22행)에도 매치된다. Task 0에서 예시 구분자 ` / `를 유지하기로 정했기 때문이며, spec 전제에 기록되어 있다. Task 1의 `[QD]`는 교차모델 audit이 채점한다.

---

### Task 2: issue-audit SKILL.md·리포트 템플릿 형식 확장

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: issue-audit SKILL.md 3단계 4항의 형식 문장과 예시를 "벤더, 모델명 (모델 ID)"로 바꾸고, 괄호 안 모델 ID 전용·자기 세션 실행 기록에서 읽기·컨텍스트 접미어 제거·확인 불가 `(-)` 문장을 더했다. 리포트 템플릿 `> 감사 모델:` 줄 예시를 확장 형식과 `(-)` 안내로 바꿨다. `--plan` 절 결과 기록 문장에는 형식 언급이 없어 그대로 두었다. spec R3 `[D]` 3건과 issue-audit 테스트 201건이 모두 통과했다.
- **특이 사항**: 특정 UI 이름은 쓰지 않고 "로컬 실행 기록이 없는 환경"으로 적었다(R3). ID 읽기 규칙은 스킬 독립성을 위해 issue-work를 참조하지 않고 issue-audit 본문에 직접 적었다.

---

### Task 3: 게이트·테스트 정합 확인

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: plan 템플릿 Task N `[D]` awk의 `수행 모델` 앵커 행이 바뀌지 않았음을 확인했다(Task 1의 템플릿 변경은 `[QD]` 문장 1행뿐). `issue-work/tests/run-tests.sh` 정상 fixture Task 1의 `수행 모델`을 `OpenAI, GPT-6 (-)`로 바꾸고 fixture 주석에 그 의도를 한 줄 적었다. 수행 모델 게이트는 정상 fixture를 통과시키고 반례 4건(빈 값·행 누락·리터럴 `-`·중복)을 그대로 걸렀다. `summarize-metrics.sh`에 `수행 모델` 참조는 0건이다. spec R4 `[D]` 3건이 통과했고 issue-work 테스트 107건이 모두 통과했다.
- **특이 사항**: 반례를 만드는 awk는 벤더 접두 `OpenAI`로 행을 고르므로 접두를 유지했다.

---

### Task 4: .ai 안내도 정합

- **결과**:
- **수행 모델**: -
- **수행 effort**: -
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**:
- **특이 사항**:

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:
