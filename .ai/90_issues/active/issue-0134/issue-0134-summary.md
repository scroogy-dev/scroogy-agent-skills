# Issue #134 실행요약 ai-workspace: update가 스킬 소유 구간을 최신본으로 반영하고 안내도에 프로파일을 표시한다

> 스펙: [issue-0134-spec.md](./issue-0134-spec.md) | 계획: [issue-0134-plan.md](./issue-0134-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task N (고정) — 교차모델 issue-audit 검증 (사용자 수동 수행)

## 모델 기록

| 구분 | 모델 | effort |
|------|------|--------|
| 계획 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | xhigh |
| 계획 audit 모델 | OpenAI, GPT-6.1 (gpt-6.1-sol) | high |
| 구현 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | xhigh |
| 최종 audit 모델 |  |  |

- **계획 감사**: 수행 · 발견 2건 · 보정 2건

- **이슈 본문 갱신**: 갱신 · AC12~AC21

---

## Task별 수행 결과

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: 문서만으로 정할 수 없는 3건을 질의해 spec 전제에 반영했다. 닫히지 않은 코드 펜스·HTML 주석은 실패로 처리하고, `profile` 행 둘 이상은 인자가 있어도 사용자에게 묻고 답한 값으로 한 행을 남기며, 코드맵 표지는 커밋 뒤 sync로 갱신한다. 계획에 없던 기계적 후속 작업은 plan Task 1~4에 더했다.
- **특이 사항**: 사용자가 정한 "판정 근거가 없으면 결정을 받는다" 원칙을 `--context`에도 적용해, 표준 문구가 아닌 SSoT 선언의 "dev 템플릿 사용"을 `실패:`로 바꿨다. 이 항목은 질의한 3건 밖이라 사용자에게 별도로 알렸다.

---

### Task 1: 소유 구간 동기화 헬퍼와 테스트

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `sync-owned.sh`의 `--dirs`·`--context` 모드를 만들고, 러너에 `소유 구간` 통과 6건과 격추 11건을 더했다. 러너는 passed 111, failed 0이다(구현 전 94).
- **특이 사항**: spec `[D]` 27건 중 13건이 통과했고, 미통과 14건은 Task 2~4가 맡는 `--profile`, `SKILL.md` 호출, 안내 주석, ADR·명세 항목이다. 이 repo `.ai/` 사본에서 시험 실행한 결과 `교체: AI-CONTEXT.md ## 에이전트 운영 지침` 1행만 나왔고 달라지는 문구는 전제 줄의 "런타임에"뿐이다. 실제 사본은 Task 3에서 맞춘다.

---

### Task 2: profile 행과 프로파일 결정 헬퍼

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 1회
- **수행 내용 요약**: dev·doc 템플릿, 이 repo 안내도, fixture에 `profile` 행을 넣었다. `check-context.sh`의 일반 검사와 `--profile` 판정, `sync-owned.sh --profile` 쓰기를 더하고, `SKILL.md`·헬퍼·러너의 항목 수를 13개 중 11개로 맞췄다. 러너는 passed 127, failed 0이다(Task 1 뒤 111). `프로파일` 케이스는 통과 6건, 격추 10건이다.
- **특이 사항**: spec의 "세 경로가 같은 범위를 본다"를 지키려고 코드 펜스·HTML 주석 추적 코드를 `MD_TRACK_AWK`로 분리했다. 두 헬퍼에 같은 사본을 두고 `프로파일 추적 코드 일치` 케이스가 차이를 잡는다. 계획의 7개 케이스 외에 `범위 일치`, `추적 코드 일치`와 변형 격추 7건을 더했다. spec `[D]`는 15/27건 통과이며, R11·R12 미통과는 `SKILL.md` 호출·문구뿐이라 Task 3에서 해소한다. `SKILL.md` 표의 `#### 표준 구간 최신화` 참조도 Task 3에서 그 소절을 만든다. 재시도 1회는 첫 실행의 테스트 오류 2건(`pipefail`로 가려진 대조, `awk -v`의 `\|` 해석)을 고친 것이다.

---

### Task 3: 안내 주석, SKILL.md 절차, 이 repo 사본 동기화

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: 원장 템플릿, 두 index의 `## 수명 주기`, dev·doc 안내도 표준 섹션 4개에 안내 주석을 넣었다. `SKILL.md`의 1단계를 `check-context.sh --profile` 호출로 고치고, update-3에 `--dirs` 호출, update-4에 `#### 표준 구간 최신화`, update-5에 헬퍼 출력 보고를 더했다. 러너에 `소유 구간 절차` 통과 1건과 격추 16건을 더해 passed 144, failed 0이다(Task 2 뒤 127). 이 repo의 `.ai/` 사본을 헬퍼로 맞추고 `last updated`를 2026-11-05로 고쳤다.
- **특이 사항**: 사본 동기화 출력은 `교체: 70_ledger/ledger-entry-template.md`, `교체: 50_adr/index.md ## 수명 주기`, `교체: 70_ledger/index.md ## 수명 주기`, `교체: AI-CONTEXT.md ## .ai 디렉토리 구조`, `교체: AI-CONTEXT.md ## 에이전트 운영 지침`, `교체: AI-CONTEXT.md ## Git 정책`, `교체: AI-CONTEXT.md ## 이슈 작업 워크플로우` 7행이다. 임시 사본 `diff -ru`로 먼저 확인했고, 달라진 내용은 안내 주석과 전제 줄의 "런타임에" 삭제뿐이다. spec `[D]`는 27건 중 25건이 통과했고(공통의 전체 스킬 테스트 포함), 미통과 2건은 Task 4가 맡는 R10의 ADR·명세 항목이다. 계획의 앵커 외에 update-3 호출 위치, update-4 소절 위치, 실패 처리, 옛 조항 복원도 격추 케이스로 더했다. update-3의 호출은 `#### 스킬 소유 파일·구간 최신화` 소절로 분리했고, update-4 도입 문장에 표준 섹션과 `profile` 행의 예외를 적었다.

---

### Task 4: ADR, 명세, 코드맵 갱신

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: ADR 0028을 쓰고 ADR index 행과 ADR 0007·0008의 관련 결정 링크를 더했다. `specs/ai-workspace.md`의 update 서술을 소유 구분, 프로파일 결정, 표준 구간 최신화, 구간 교체 규칙으로 고치고 `40_domain/index.md` 설명을 맞췄다. 안내도 디렉토리 트리, update·init 호출 흐름의 트리와 시퀀스, 검사 항목 수(11항목), 코드맵 index의 ai-workspace 행과 헬퍼 공통 규약에 `sync-owned.sh`와 `--profile`을 반영했다.
- **특이 사항**: Task 4 완료 기준 2건과 spec `[D]` 27건 전부(공통의 전체 스킬 테스트 포함)가 통과했고, `ai-workspace` 러너는 passed 144, failed 0이다. `60_codebase/index.md`의 `## 파일 구조` 트리는 코드맵 문서만 나열해 헬퍼를 둘 자리가 없어, 계획의 "트리" 대신 기능 표 ai-workspace 행에 두 헬퍼를 적었다. ADR 0022 근거의 "`index.md`가 있으면 전파되지 않는다"는 더는 맞지 않지만 결정 항목은 유효해 0022를 고치지 않고 ADR 0028 근거에 관계를 적었다. 코드맵의 `source_hash`·`last_synced` 표지는 합의대로 고치지 않았으며 커밋 뒤 코드맵 sync로 갱신한다.

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:
