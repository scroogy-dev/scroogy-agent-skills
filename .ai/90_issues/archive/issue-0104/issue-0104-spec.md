# Issue #104 스펙 모델 기록 형식에 모델 ID 병기 도입

## 목표 (Goal)

issue-work·issue-audit의 모델 기록 값 형식을 "벤더, 모델명 (모델 ID)"로 확장해, 같은 제품명 아래의 다른 변형을 사후에 구분할 수 있게 한다.

---

## 요구사항 (Requirements)

**포함**

- R1: issue-work 템플릿 3종(summary·plan·workflow)과 SKILL.md가 모델 값 형식을 "벤더, 모델명 (모델 ID)"로 규정한다. 괄호 안은 모델 ID 전용이며, 도구명·회차 같은 다른 정보를 넣지 않는다.
  - R1-a: 모델 ID를 확인할 수 없으면 `(-)`로 적는다. 괄호를 유지해 "ID를 적지 않음"과 "확인 불가"를 구분한다. (이슈 본문이 `검토 필요`로 남긴 항목. 2026-09-25 승인으로 확정)
  - R1-b: 모델 ID에 컨텍스트 접미어(`[1m]` 등)가 붙어 있으면 `[`부터 끝까지 ID에서 제거한다. 접미어는 API 모델 ID가 아니다. Claude Code 실행 기록 `model` 값에는 접미어가 없고, 시스템 프롬프트·`/model` 설정값처럼 다른 출처의 모델 ID에 붙는다. (이슈 본문이 `검토 필요`로 남긴 항목. 2026-09-25 승인으로 확정, Task 0에서 적용 대상을 실행 기록 `model` 값에서 모델 ID 전반으로 넓힘)
  - R1-c: 한 Task를 여러 모델이 수행해 ` / `로 나열할 때도 각 항목에 괄호 병기를 유지하고 별도 축약 표기를 두지 않는다. (이슈 본문이 `검토 필요`로 남긴 항목. 2026-09-25 승인으로 확정)
- R2: issue-work SKILL.md `수행 effort` 읽기 규칙 소절에 모델 ID를 effort와 같은 레코드에서 읽는다는 문장이 있다. Claude Code는 실행 기록 jsonl assistant 항목의 `model`, Codex는 rollout `turn_context`의 `payload.model`이다.
- R3: issue-audit SKILL.md의 모델 기록 형식 문장·예시와 리포트 템플릿의 `감사 모델` 줄 예시가 확장 형식이다. 감사 모델이 자기 ID를 리포트에 적고 사용자가 summary의 audit 행으로 옮겨 적는 흐름은 그대로 둔다. 웹 UI처럼 ID를 확인할 수 없는 환경은 R1-a를 따르며, 특정 UI의 확인 방법을 절차에 적지 않는다. (웹 UI 처리는 이슈 본문이 `검토 필요`로 남긴 항목. 2026-09-25 승인으로 확정)
- R4: Task N 게이트의 `[D]` awk(`수행 모델` 앵커)와 `[QD]` 벤더 대조 문장, `issue-work/tests/run-tests.sh`가 확장 형식에서 그대로 통과한다. 변경이 필요한 곳만 최소로 고친다.
- R5: `.ai` 안내도의 모델 기록 형식 언급이 확장 형식과 일치한다. 대상은 `notation-conventions.md`, ADR 0004, `specs/issue-workflow.md`, `specs/issue-audit.md`, `60_codebase/` 색인 2곳(index·final-audit-call-flow)이다.

**제외**

- archive 기존 기록의 소급 수정: 이력 문서는 작성 시점 표기를 유지한다 (불필요)
- 모델 ID를 게이트 조건·벤더 교차 조건에 쓰는 것: 벤더 토큰만 보는 현행 판정을 유지한다 (불필요)
- 특정 벤더의 모델 ID 목록을 절차에 하드코딩하는 것: notation-conventions의 하드코딩 금지 원칙을 유지한다 (불필요)
- `[1m]` 같은 접미어를 별도 필드로 기록하는 것: 이슈가 요구하지 않았고 effort처럼 비교 가치가 확인되지 않았다 (보류. 이슈 본문 근거 없음. 2026-09-25 승인으로 확정)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

### R1: issue-work 형식 규정

- [ ] [D] issue-work 템플릿 3종·SKILL.md에 구 형식 단독 표기("벤더, 모델명" 뒤에 "(모델 ID)"가 없는 행)가 0건이고, 4개 파일 모두 확장 형식 표기가 1건 이상이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  F='issue-work/SKILL.md issue-work/templates/issue-summary-template.md issue-work/templates/issue-plan-template.md issue-work/templates/issue-workflow-template.md'
  grep -n '벤더, 모델명' $F | grep -v '벤더, 모델명 (모델 ID)'
  for f in $F; do grep -q '벤더, 모델명 (모델 ID)' "$f" || echo "위반: 확장 형식 없음 $f"; done
  ```

  - 설계 주의: 확장 형식 문자열은 구 형식 문자열을 포함하므로 첫 명령은 확장 형식 행을 제외한 나머지를 센다. 두 번째 명령은 문구를 지우기만 해도 첫 명령이 통과하는 우회를 막는다.
  </details>
- [ ] [D] summary 템플릿에 괄호 안이 모델 ID 전용이라는 문장과 확인 불가 표기 `(-)`가 있다 (R1-a)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-summary-template.md
  grep -q '모델 ID 전용' "$T" || echo '위반: 모델 ID 전용 문장 없음'
  [ "$(grep -c '(-)' "$T")" -ge 2 ] || echo '위반: (-) 표기가 모델 기록 주석과 수행 모델 규칙 양쪽에 없음'
  ```

  </details>
- [ ] [D] issue-work SKILL.md에 컨텍스트 접미어를 `` `[` ``부터 끝까지 ID에서 제거한다는 계약 문구가 있다 (R1-b). 문구의 존재만 검사하며, 방향·범위의 의미 판정은 plan Task 1 `[QD]`가 맡는다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -n '접미어' issue-work/SKILL.md | grep -F '`[`부터' | grep -qE '제거한다' \
    || echo '위반: 접미어 제거 문장 없음 또는 범위(`[`부터)·방향(제거한다) 미명시'
  ```

  - 설계 주의: `제거한다`는 `제거하지 않는다`와 매치되지 않아 반대 방향 문장을 거부한다. `` `[`부터 ``는 spec 전제의 제거 범위를 같은 행에 요구한다. 계획 감사 F-2로 키워드 존재 검사(`제거`)에서 좁혔다.
  </details>
- [ ] [D] summary 템플릿의 `수행 모델` 나열 예시가 항목마다 괄호 병기를 유지한다 (R1-c)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -qE '\([a-z0-9.-]+\) / [A-Za-z]+, [^/]+\([a-z0-9.-]+\)' issue-work/templates/issue-summary-template.md \
    || echo '위반: 괄호 병기 나열 예시 없음'
  ```

  </details>
- [ ] [D] `active/issue-workflow.md`가 갱신된 workflow 템플릿과 동일하다. R1-1(템플릿 확장 형식) 통과가 선행 조건이며, 템플릿이 갱신되지 않으면 옛 템플릿과 옛 사본이 같아 그대로 통과한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  diff -q issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md
  ```

  </details>

### R2: 모델 ID 읽기 위치

- [ ] [D] issue-work SKILL.md `수행 effort` 규칙 소절 안에 모델 ID를 effort와 같은 레코드에서 읽는다는 계약 문구와 도구별 키(`model`·`payload.model`)가 있다. 문구의 존재만 검사하며, 레코드 관계의 의미 판정은 plan Task 1 `[QD]`가 맡는다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  SEC=$(sed -n '/^  `수행 effort`는 아래 규칙으로 적는다/,/게이트 조건에도 쓰지 않는다\.$/p' issue-work/SKILL.md)
  echo "$SEC" | grep -qE '모델 ID.*같은 레코드' || echo '위반: 수행 effort 소절에 같은 레코드 문장 없음'
  echo "$SEC" | grep -q 'payload\.model' || echo '위반: Codex 키 payload.model 없음'
  echo "$SEC" | grep -qE '`model`' || echo '위반: Claude Code 키 model 없음'
  ```

  - 설계 주의: 소절 범위를 앵커 두 줄로 잘라 세므로 파일 다른 곳의 "모델 ID"는 통과 근거가 되지 않는다. `같은 레코드`를 같은 행에 요구해 `다른 레코드` 반례를 거부한다. 도구별 키 2건은 현행 소절에 이미 있어 삭제 회귀만 막는다. 계획 감사 F-2로 키워드 존재 검사(`모델 ID`)에서 좁혔다.
  </details>

### R3: issue-audit 형식 규정

- [ ] [D] issue-audit SKILL.md·리포트 템플릿에 구 형식 단독 표기 0건, 확장 형식 표기 각 1건 이상이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  F='issue-audit/SKILL.md issue-audit/templates/issue-audit-report-template.md'
  grep -n '벤더, 모델명' $F | grep -v '벤더, 모델명 (모델 ID)'
  for f in $F; do grep -q '벤더, 모델명 (모델 ID)' "$f" || echo "위반: 확장 형식 없음 $f"; done
  ```

  </details>
- [ ] [D] 리포트 템플릿 `감사 모델` 줄에 확장 형식 예시와 확인 불가 표기 `(-)`가 함께 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  L=$(grep -E '^> 감사 모델:' issue-audit/templates/issue-audit-report-template.md)
  { echo "$L" | grep -q '모델 ID' && echo "$L" | grep -q '(-)'; } || echo '위반: 감사 모델 줄 형식 미갱신'
  ```

  </details>
- [ ] [D] issue-audit SKILL.md·리포트 템플릿에 특정 UI 이름(`ChatGPT`)이 0건이다 (회귀 방지 항목: 구현 전에도 통과해야 한다)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -n 'ChatGPT' issue-audit/SKILL.md issue-audit/templates/issue-audit-report-template.md
  ```

  </details>

### R4: 게이트·테스트 정합

- [ ] [D] plan 템플릿 Task N `[D]` awk의 `수행 모델` 앵커 행이 그대로 1건이다 (회귀 방지 항목: 구현 전에도 통과해야 한다)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  [ "$(grep -cF 'o && /^- \*\*수행 모델\*\*:/ { t++; if ($0 ~ /^- \*\*수행 모델\*\*: [^-[:space:]]/) m++ }' issue-work/templates/issue-plan-template.md)" -eq 1 ] \
    || echo '위반: 수행 모델 앵커 awk 행 변경'
  ```

  </details>
- [ ] [D] plan 템플릿 Task N `[QD]` 벤더 대조 문장이 확장 형식이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -E '^  - \[QD\] summary .모델 기록. 표의' issue-work/templates/issue-plan-template.md | grep -q '모델 ID' \
    || echo '위반: [QD] 벤더 대조 문장 미갱신'
  ```

  </details>
- [ ] [D] issue-work 테스트의 정상 fixture에 확인 불가 표기 `(-)` 값이 있고 `run-tests.sh`가 통과한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -qE '^- \*\*수행 모델\*\*: [A-Za-z]+, .*\(-\)$' issue-work/tests/run-tests.sh || echo '위반: (-) fixture 없음'
  issue-work/tests/run-tests.sh >/dev/null 2>&1 || echo '위반: issue-work 테스트 실패'
  ```

  - 설계 주의: `(-)` 값이 `수행 모델` 게이트(`[^-[:space:]]` 첫 글자 검사)를 통과함을 정상 fixture로 고정한다. 반례 생성 awk가 벤더 접두(`Anthropic`/`OpenAI`)로 행을 고르므로 접두는 유지한다.
  </details>

### R5: 안내도 정합

- [ ] [D] `.ai/40_domain`·`50_adr`·`60_codebase`에 구 형식 단독 표기가 0건이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -rn '벤더, 모델명' .ai/40_domain .ai/50_adr .ai/60_codebase | grep -v '벤더, 모델명 (모델 ID)'
  ```

  </details>
- [ ] [D] notation-conventions에 도구명 괄호 예시(`GPT-5 (Codex)`)가 0건, 확인 불가 표기 `(-)`가 1건 이상, 출처 목록에 #104가 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  N=.ai/40_domain/policies/local/notation-conventions.md
  grep -n 'GPT-5 (Codex)' "$N"
  grep -q '(-)' "$N" || echo '위반: 확인 불가 표기 없음'
  grep -q 'issues/104' "$N" || echo '위반: 출처 #104 없음'
  ```

  </details>
- [ ] [D] 60_codebase 변경 파일 2개의 `last_synced`가 2026-09-25 이후이고 `source_hash`가 실재 커밋을 가리킨다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for f in .ai/60_codebase/index.md .ai/60_codebase/issue-audit/final-audit-call-flow.md; do
    [ "$(sed -n 's/^last_synced: //p' "$f")" \> "2026-09-24" ] || echo "위반: last_synced 미갱신 $f"
    h=$(sed -n 's/^source_hash: //p' "$f"); git cat-file -e "${h}^{commit}" 2>/dev/null || echo "위반: source_hash 커밋 없음 $f"
  done
  ```

  - 설계 주의: 문자열 비교(`\>`)는 `YYYY-MM-DD` 고정 폭이라 날짜 순서와 같다. hash 실재 확인은 임의 문자열 기입을 막는다.
  </details>

### 공통

- [ ] [D] repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목: 구현 전에도 통과해야 한다)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D] 이번 브랜치에서 변경한 md 파일에 줄 끝 공백이 없다 (두 칸 이상은 마크다운 강제 개행이라 제외. 회귀 방지 항목: 구현 전에도 통과해야 한다)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  git diff --name-only main -- '*.md' | xargs grep -nE ' +$' | grep -vE '  $'
  ```

  </details>

---

## 전제 (Assumptions)

- 모델 기록 관례의 SSoT는 `.ai/40_domain/policies/local/notation-conventions.md`다. 스킬 본문·템플릿의 형식 문장은 복제본이라(ADR 0002) 두 곳을 같은 이슈에서 함께 고친다.
- ADR 0004의 형식 통일 결정 문장은 새 ADR 없이 원문을 확장 형식으로 갱신하고 출처를 `(#26, #104)`로 병기한다. "ADR 신설" 대안은 형식 확장이 결정 번복이 아니라 버렸다.
- 확장 형식의 예시 모델명·ID는 예시값이며 실재 여부와 무관하다. 기존 템플릿 예시(`Claude Opus 4.8 (claude-opus-4-8)`)와 같은 성격이고 특정 모델 하드코딩이 아니다.
- R1-b의 접미어 제거는 모델 ID 값에서 `[`부터 끝까지를 잘라낸다는 뜻이다(`claude-opus-5-5[1m]` → `claude-opus-5-5`). Task 0 확인(2026-09-25): 최근 30개 세션의 Claude Code 실행 기록 assistant 항목 `model` 값에는 접미어가 0건이었다. 접미어는 시스템 프롬프트의 모델 ID와 `/model` 설정의 modelId에 붙는다. 그래서 규칙 대상을 실행 기록 `model` 값에서 모델 ID 전반으로 넓혔다.
- 예시 사이 구분자 ` / `는 유지한다(summary 템플릿 `모델 기록` 주석, issue-audit SKILL.md 3단계 4항. Task 0 결정). ID를 붙인 예시 줄도 R1-4 정규식에 매치될 수 있으므로, R1-4가 요구하는 나열 예시는 summary 템플릿 `수행 모델` 규칙 안에 따로 둔다.
- 확장 형식 예시의 OpenAI 값은 `OpenAI, GPT-6 (gpt-6-astra)`(Codex 실행 기록 `payload.model` 실재값)를 쓰고, Google 예시는 `(-)`를 붙여 확인 불가 예시로 쓴다.
- Codex는 자동 리뷰 세션을 같은 디렉토리의 별도 rollout 파일로 남긴다(`payload.model`이 리뷰용 값). R2 문장에는 따로 안내하지 않는다. 현행 규칙의 "자기 세션"에서 읽는다는 문구로 충분하다(Task 0 결정).
- `60_codebase/` 변경 파일은 #102 선례(c75a007)대로 frontmatter `last_synced`를 작업일로, `source_hash`를 스킬 소스 변경을 담은 커밋의 short hash로 갱신한다. 커밋은 사용자가 만들므로 Task 4 착수 시점의 HEAD를 적고, Task 1~3 변경이 아직 커밋되지 않았으면 커밋을 먼저 요청한다.
- issue-work 테스트 fixture의 `수행 모델` 값은 벤더 접두(`Anthropic`·`OpenAI`)를 유지한다. 반례 생성 awk가 그 접두로 행을 고른다.
- 이 세션의 설치본 issue-work 스킬(`~/.claude/skills/issue-work`)은 #102 이전 버전이다. 문서 작성과 구현 대상은 모두 repo 소스(`issue-work/`·`issue-audit/`)를 기준으로 한다.
- 웹 UI 감사(ChatGPT 웹 등)의 ID 확인 방법은 절차에 적지 않는다. issue-work SKILL.md `수행 effort` 소절에 이미 있는 "로컬 기록이 없는 도구" 문장에 모델 ID를 함께 걸어 `(-)`로 처리한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/40_domain/policies/local/notation-conventions.md` | 모델 기록 관례의 SSoT. 이 이슈로 형식 문장·예시를 바꾼다 |
| `.ai/40_domain/specs/issue-workflow.md` | summary 구성 요약. 형식 언급 정합 확인 |
| `.ai/40_domain/specs/issue-audit.md` | 리포트 메타 줄(`감사 모델`) 요건. 형식 언급 정합 확인 |
| `.ai/50_adr/active/0004-cross-model-audit-and-response-gate.md` | "벤더, 모델명" 통일 결정(#26). 확장 형식으로 문장 갱신 |
| `.ai/50_adr/active/0005-model-separation-gates.md` | 모델명 하드코딩 금지. 벤더별 ID 목록을 두지 않는 근거 |
| `.ai/60_codebase/index.md`, `.ai/60_codebase/issue-audit/final-audit-call-flow.md` | 색인의 형식 언급 2곳. 정합 확인 |
