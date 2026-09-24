# Issue #102 스펙 issue-work: 모델 기록에 effort(추론 강도) 기록 추가

## 목표 (Goal)

issue-work summary의 모델 기록(`모델 기록` 표·Task별 `수행 모델`)에 effort(모델의 추론 강도 설정값)를 함께 남겨, 같은 모델의 수행을 설정 단위로 구분해 사후 집계할 수 있게 한다.

---

## 요구사항 (Requirements)

**포함**

- R1: summary `모델 기록` 표의 4행(계획·계획 audit·구현·최종 audit)마다 effort를 기록할 수 있다. 모델 값의 "벤더, 모델명" 형식은 그대로 두고, effort는 표에 `effort` 열을 추가해 별도 필드로 둔다. (열 추가는 이슈 본문 "검토 필요" 항목. 2026-09-24 대화에서 확정)
- R2: Task 0과 일반 실행 Task 블록에 `수행 effort` 필드를 `수행 모델` 바로 아래에 두고, 값이 없어도 필드를 남기는 지표 규칙(4종에서 5종으로)에 포함한다. Task N 블록에는 두지 않는다(`수행 모델`과 같이 `최종 audit 모델` 행이 SSoT). (필드명과 지표 규칙 포함은 이슈 본문 "검토 필요" 항목. 2026-09-24 대화에서 확정)
- R3: effort 값은 도구가 기록한 표기(`high`, `xhigh` 등)를 그대로 적고, 확인할 수 없으면 `-`를 허용하며, 한 Task 안에서 바꿨으면 `수행 모델`과 같은 순서로 ` / `로 나열한다. 두 목록은 위치로 대응한다. 항목 수를 같게 두고, 같은 모델이 effort를 바꿔 다시 수행했으면 모델도 그 자리에 반복해 적는다(모델 `A / A / B`에 effort `high / low / high`). 확인 불가 값은 그 자리에 `-`를 두고(모델 `A / B`에 effort `high / -`), 같은 effort면 그대로 반복한다. 벤더가 다르면 비교하지 않는다는 주석을 템플릿에 둔다. (위치 대응 규칙은 계획 감사 F-2 보정. 2026-09-24 `--response`에서 확정)
- R4: issue-work SKILL.md의 Task 완료 시 갱신 절차에 effort 기록 규칙과 값을 읽는 위치를 적는다. 설정 파일 값보다 실행 기록 값을 우선하고, 로컬 기록이 없는 도구(ChatGPT 웹·앱)는 사람이 적는다. 구현 AI는 자기 세션 값을 실행 기록이나 환경변수에서 읽어 채우고, audit 모델의 effort는 사용자가 적는다.
- R5: `issue-workflow-template.md`·`issue-plan-template.md`의 모델 기록 관련 문장과 Task N 게이트(awk `수행 모델` 검사, [QD] 벤더 대조)가 새 필드와 정합하며, 필요한 곳만 고친다.
- R6: `issue-work/tests/run-tests.sh`의 summary fixture가 새 필드를 포함하고, 게이트·집계 헬퍼 테스트가 전부 통과한다.
- R7: 모델 기록을 언급하는 문서의 영향을 확인하고 새 필드에 맞춰 정합화한다. 대상 후보는 `.ai/40_domain/specs/issue-workflow.md`, `.ai/40_domain/policies/local/notation-conventions.md`, `.ai/60_codebase/issue-work/start-call-flow.md`, `issue-audit/SKILL.md`다.
- R8: issue-audit 리포트 머리말에 `감사 effort` 줄을 `감사 모델` 줄 바로 아래에 두어, 사용자가 summary의 audit 모델 행에 그대로 옮겨 적을 수 있게 한다. (이슈 본문 근거 없음. R7의 `issue-audit/SKILL.md` 영향 확인에서 작성 AI가 제안, 2026-09-24 대화에서 확정)

**제외**

- effort를 게이트 조건(벤더 교차 조건 등)에 쓰는 것: 이슈 비포함. `-` 허용이 게이트 우회로 이어지지 않게 하는 전제다.
- 스킬별·Task별 effort 추천: 이슈 비포함.
- 실행 기록에서 effort를 읽는 결정적 헬퍼: 보류. 도구 버전에 따라 기록 형식이 바뀌어 같은 입력에 같은 출력을 보장하기 어렵고, 도구별 경로를 코드에 고정하게 된다. R4대로 SKILL.md에 읽는 위치만 적는다. (이슈 본문 "검토 필요" 항목. 2026-09-24 대화에서 제외로 확정)
- effort 필드의 존재·형식을 `summarize-metrics.sh`나 Task N 게이트로 검사하는 것: 보류. 헬퍼 집계 대상은 수치 3종뿐이고, effort는 `-`를 허용하는 비수치 필드라 검사를 붙여도 걸러낼 위반이 없다. (이슈 본문 근거 없음. 2026-09-24 대화에서 제외로 확정)
- 벤더 간 effort 비교·정규화: 불필요. 이슈 방향대로 벤더끼리 비교하지 않는다.
- archive 이슈 summary 소급 갱신: 불필요. 기존 이슈에 소급하지 않은 ADR 0005 선례를 따른다. (이슈 본문 근거 없음. 2026-09-24 대화에서 제외로 확정)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

모든 검증 명령은 repo 루트에서 실행한다.

### R1: 모델 기록 표 effort 열

- [ ] [D] summary 템플릿의 `모델 기록` 표가 `구분·모델·effort` 3열이고, 4행(계획·계획 audit·구현·최종 audit) 모두 셀이 3개다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-summary-template.md
  grep -qxE '\| 구분 \| 모델 \| effort \|' "$T" || echo '위반: 표 헤더가 구분·모델·effort 3열이 아님'
  awk -F'|' '
    /^\| (계획 모델|계획 audit 모델|구현 모델|최종 audit 모델) \|/ { r++; if (NF != 5) print "위반: 셀 수 — " $0 }
    END { if (r != 4) print "위반: 모델 기록 행 수 " r + 0 " (기대 4)" }
  ' "$T"
  ```

  - 설계 주의: 셀 안 주석에 `|`가 들어가면 NF가 늘어 위반으로 잡힌다. 주석에는 `|`를 쓰지 않는다.
  </details>

### R2: Task 블록 수행 effort 필드

- [ ] [D] summary 템플릿의 Task 0·일반 Task 블록마다 `- **수행 effort**:` 행이 `- **수행 모델**:` 바로 다음 행에 정확히 1개 있고, Task N 블록에는 없다
  <details>
  <summary>검증 명령 — 출력 0이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-summary-template.md
  awk '
    function chk() { if (!t) return; if (n) { if (e) b++ } else if (e != 1) b++ }
    /^### Task / { chk(); t = $0; n = ($0 ~ /^### Task N/); m = 0; e = 0 }
    t && /^- \*\*수행 모델\*\*:/ { m = NR }
    t && /^- \*\*수행 effort\*\*:/ { e++; if (NR != m + 1) b++ }
    END { chk(); print b + 0 }
  ' "$T"
  ```

  - 설계 주의: 블록 단위로 세므로 한 블록의 누락을 다른 블록의 중복으로 상쇄할 수 없다. 주석 안의 `- 수행 effort:` 설명 행은 굵게 표기가 없어 앵커에 걸리지 않는다.
  </details>
- [ ] [D] 템플릿 Task 블록의 `수행 effort` 기본값이 리터럴 `-`다 (Task 0·1·2, 3건)
  <details>
  <summary>검증 명령 — 출력이 3이면 통과</summary>

  ```bash
  grep -cxE -- '- \*\*수행 effort\*\*: -' issue-work/templates/issue-summary-template.md
  ```

  </details>
- [ ] [D] 지표 종수 표기가 5종으로 바뀌어 repo 상주 문서에 `지표 4종`이 남지 않는다 (이슈 문서·작업공간 제외)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -rn '지표 4종' --include='*.md' --include='*.sh' . | grep -vE '^\./\.ai/(90_issues|99_workspace)/'
  ```

  - 설계 주의: 이 spec·plan 본문에 같은 문구가 있어 `90_issues/`를 제외한다. `summarize-metrics.sh`의 "지표 3종"은 수치 3종을 뜻하므로 대상이 아니다.
  </details>

### R3: effort 값 규칙

- [ ] [QD] summary 템플릿 주석이 값 규칙 6가지(도구가 기록한 표기 그대로, 확인 불가 시 `-` 허용, 한 Task 안에서 바꿨으면 `수행 모델`과 같은 순서로 ` / ` 나열, 두 목록의 위치 대응(항목 수 동일·같은 모델 반복·확인 불가는 그 자리에 `-`), 벤더 간 비교 안 함, 게이트 조건에 쓰지 않음)를 빠짐없이 담고, 주석의 예시만으로 `A/high → A/low → B/high`와 `A/high → B/low → B/high`가 서로 다른 기록으로 구분된다  (검증: 감사 모델이 주석 대조 채점)  ← 강등 사유: 규칙 문장의 의미 충족은 명령으로 환원 불가

### R4: SKILL.md effort 기록 절차

- [ ] [D] issue-work SKILL.md `## 작업 진행 중` 섹션 안에 `수행 effort` 언급과 값을 읽는 위치(실행 기록·환경변수·설정 파일, Claude Code·Codex 각각)가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  sec=$(awk '/^## 작업 진행 중/ { s = 1; next } /^## / { s = 0 } s' issue-work/SKILL.md)
  for p in '수행 effort' '실행 기록' 'CLAUDE_EFFORT' 'settings.json' 'config.toml' 'rollout-'; do
    printf '%s\n' "$sec" | grep -q -- "$p" || echo "위반: 작업 진행 중 섹션에 '$p' 없음"
  done
  ```

  - 설계 주의: 섹션 앵커(`^## 작업 진행 중`부터 다음 `^## `까지)로 범위를 한정해 다른 섹션의 우연한 언급이 통과로 이어지지 않게 한다.
  </details>
- [ ] [QD] 절차에 규칙 6가지(실행 기록 우선, 로컬 기록 없는 도구는 사람이 기입, 구현 AI는 자기 세션 값을 채움, audit 모델의 effort는 사용자가 기입, 표 행을 채우는 시점 문장 3곳(3-2·5단계·Task N)에 effort 병기, 집계 헬퍼의 검사 대상은 수치 3종뿐이라 `수행 effort`의 `-`는 위반이 아님)가 있다  (검증: 감사 모델이 채점)  ← 강등 사유: 규칙의 의미 충족은 명령으로 환원 불가

### R5: workflow·plan 템플릿 정합

- [ ] [D] `active/issue-workflow.md`가 workflow 템플릿과 동일하다 (템플릿을 고쳤으면 사본도 같이 갱신. 회귀 방지 항목: 구현 전에도 통과한다)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  diff -q issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md
  ```

  </details>
- [ ] [D] plan 템플릿 Task N 게이트 명령 3종이 `수행 effort` 행을 포함한 fixture에서 정상 통과·반례 격추한다  (검증: R6의 테스트 실행에 포함, 러너가 plan 템플릿에서 게이트를 추출해 실행)
- [ ] [QD] plan·workflow 템플릿의 모델 기록 관련 문장(Task N 게이트 [QD] 항목, Task N 완료 조건)이 effort 도입 뒤에도 사실과 어긋나지 않는다  (검증: 감사 모델이 채점)  ← 강등 사유: 문장과 구조의 정합은 의미 판단

### R6: 테스트 정합

- [ ] [D] `run-tests.sh`의 summary fixture 두 벌(게이트용·집계용)에서 `수행 모델` 행이 있는 `### Task` 블록마다 `수행 effort` 행이 `수행 모델` 바로 다음 행에 정확히 1개 있고(그런 블록 5개), issue-work 테스트가 0 실패로 끝난다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  R=issue-work/tests/run-tests.sh
  awk '
    function chk() { if (m && e != 1) print "위반: 블록별 수행 effort 누락·중복 — " t }
    /^### Task / { chk(); t = $0; m = 0; e = 0 }
    /^- \*\*수행 모델\*\*:/ { if (!m) k++; m = NR }
    /^- \*\*수행 effort\*\*:/ { e++; if (NR != m + 1) print "위반: 수행 effort 위치 — " t }
    END { chk(); if (k != 5) print "위반: 수행 모델 행이 있는 fixture 블록 수 " k + 0 " (기대 5)" }
  ' "$R"
  bash "$R" 2>&1 | tail -1 | grep -qE '^passed: [0-9]+, failed: 0$' || echo '위반: issue-work 테스트 실패'
  ```

  - 설계 주의: 블록 단위로 세므로 한 블록의 누락을 다른 블록의 중복으로 상쇄할 수 없다(계획 감사 F-1에서 파일 전체 행 수 합산의 거짓 통과를 재현). `수행 모델` 행이 없는 블록(plan fixture·Task N)은 검사 대상에서 빠지며, 대상 블록 5개는 게이트 fixture Task 0·1·2와 집계 fixture Task 0·1이다. 반례 fixture는 게이트 fixture에서 awk로 파생되므로 따로 세지 않는다.
  </details>

### R7: 문서 정합

- [ ] [D] 모델 기록을 언급하는 문서 4건에 `effort` 언급이 있고, 색인 `start-call-flow.md`의 `last_synced`가 갱신되어 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in .ai/40_domain/specs/issue-workflow.md \
           .ai/40_domain/policies/local/notation-conventions.md \
           .ai/60_codebase/issue-work/start-call-flow.md \
           issue-audit/SKILL.md; do
    grep -q 'effort' "$f" || echo "위반: $f 에 effort 언급 없음"
  done
  awk -F': ' '/^last_synced:/ { if ($2 < "2026-09-24") print "위반: start-call-flow.md last_synced " $2 }' \
    .ai/60_codebase/issue-work/start-call-flow.md
  ```

  </details>
- [ ] [QD] 각 문서의 모델 기록 서술이 새 구조(표 `effort` 열, Task `수행 effort`, 지표 5종)와 어긋나지 않고, 집계 헬퍼 `summarize-metrics.sh`의 검사 범위는 수치 3종(`audit 발견`·`보정 반영`·`재시도`)으로만 서술된다  (검증: 감사 모델이 채점)  ← 강등 사유: 서술과 구조의 정합은 의미 판단

### R8: 감사 리포트 effort 줄

- [ ] [D] issue-audit 리포트 템플릿 머리말에 `> 감사 effort:` 줄이 `> 감사 모델:` 줄 바로 다음에 정확히 1개 있고, issue-audit SKILL.md와 issue-audit 명세가 `감사 effort`를 언급한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^> 감사 모델:/ { m = NR } /^> 감사 effort:/ { e++; if (NR != m + 1) bad = 1 }
       END { if (e != 1 || bad) print "위반: 감사 effort 줄 위치·개수" }' \
    issue-audit/templates/issue-audit-report-template.md
  for f in issue-audit/SKILL.md .ai/40_domain/specs/issue-audit.md; do
    grep -q '감사 effort' "$f" || echo "위반: $f 에 감사 effort 언급 없음"
  done
  ```

  </details>

### 공통

- [ ] [D] repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목: 구현 전에도 통과한다)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do bash "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D] 새 형식을 선반영한 이 이슈의 summary가 집계 헬퍼를 통과한다 (새 필드가 집계를 깨지 않음. 회귀 방지 항목: 구현 전에도 통과한다)
  <details>
  <summary>검증 명령 — 종료 코드 0이면 통과</summary>

  ```bash
  issue-work/scripts/summarize-metrics.sh .ai/90_issues/active/issue-0102/issue-0102-summary.md
  ```

  </details>

---

## 전제 (Assumptions)

- **코드베이스 관례**: workflow 템플릿(`issue-work/templates/issue-workflow-template.md`)과 그 사본(`.ai/90_issues/active/issue-workflow.md`)은 같은 커밋에서 함께 갱신한다 (#94·#100 선례). 사본은 다음 이슈 시작 때 자동 동기화되지만, PR 안에 어긋난 상태를 남기지 않는다.
- **코드베이스 관례**: `.ai/60_codebase/*.md`의 `source_hash`는 색인이 반영한 소스 변경 커밋의 짧은 해시다. 커밋은 사용자 요청 시에만 하므로 구현 Task에서는 `last_synced`만 갱신하고, `source_hash`는 SKILL.md 변경 커밋이 생긴 뒤 그 해시로 별도 갱신한다 (#100의 a364e9e 선례).
- **코드베이스 관례**: `.ai/40_domain/`·`.ai/50_adr/`의 `source: github_issue` 문서는 context-harvest가 수확한 문서다(#100에서 처음 생성, 직접 편집 선례 없음). 이 이슈는 이슈 본문의 "안내도 정합"에 따라 명세·정책 문서(R7)를 직접 고치되 `last_harvested`는 건드리지 않고, `notation-conventions.md`의 원본 출처 목록에 Issue #102 링크를 더한다. ADR 0004·0005는 편집하지 않는다. effort 결정을 ADR로 남길지는 이슈 종료 뒤 context-harvest에서 정한다.
- **환경 제약**: effort를 읽는 위치는 2026-09-24 로컬 환경 기준이다(이슈 본문 "기술 확인" 표). 계획 세션에서 Claude Code 실행 기록(`~/.claude/projects/<repo>/<세션>.jsonl`)의 assistant 항목에서 `claude-fable-5-1`·`xhigh`를 읽었고, 셸 환경변수 `CLAUDE_EFFORT`도 `xhigh`였다. 이어진 계획 감사 `--response` 세션 2회는 같은 위치에서 `high`를 읽었고, 표의 계획 모델 행 effort는 사용자 지시로 `high`로 확정했다. 설정 파일에는 전역 `effortLevel`과 모델별 `modelSettings.<모델>.effortLevel`이 다른 값으로 함께 있어 실행 기록 우선 규칙이 실제로 필요하다. 도구 버전이 바뀌면 키 이름·경로가 달라질 수 있어 SKILL.md에는 위치를 안내로만 적고 헬퍼로 고정하지 않는다.
- **버린 대안**: effort를 표 아래 별도 줄로 두는 안. 4행마다 값이 달라 행과 값의 대응을 다시 적어야 한다. 표 `effort` 열로 확정했다. 감사 리포트에서는 `감사 모델` 줄 안에 인라인 병기하는 안을 버렸다. 기존 "벤더, 모델명" 줄을 그대로 두어야 summary 모델 열과의 교차 대조가 흔들리지 않는다. 별도 `감사 effort` 줄로 확정했다.
- **계획 결정**: 이 이슈의 summary는 새 형식(표 `effort` 열, Task `수행 effort`)을 선반영한다. 구현 검증 표본(spec 공통 [D] 둘째 항목)으로 쓰며, 이후 이슈부터는 갱신된 템플릿이 적용된다. 계획 모델 행의 effort는 위 환경 제약대로 실행 기록을 근거로 사용자가 확정한 값이다.
- **계획 결정**: Task N 완료 조건은 기존대로 `최종 audit 모델` 행의 모델 기록이며, effort 열이 `-`여도 완료를 막지 않는다 (제외 목록의 "게이트 조건에 쓰지 않음"과 같은 취지).
- **계획 결정**: 계획 감사(OpenAI, GPT-6, 2026-09-24) 발견 4건을 `--response`로 검토해 F-1(R6 블록 단위 검사)·F-2(R3 위치 대응 규칙)·F-3(필드 5종과 헬퍼 수치 3종 검사 범위 분리)은 반영, F-4(회귀 방지 항목 표기)는 spec 항목 3건과 그 참조 plan 완료 기준에만 부분 반영했다. Task N 고정 블록은 plan 템플릿 소유라 이 이슈에서 손대지 않는다. K-0009 재검토 조건(템플릿에 예외 표기 도입)에는 해당하지 않는다.
- **계획 결정**: 2차 계획 감사(같은 모델, 2026-09-24)의 F-4 잔여를 `--response`로 반영한다. plan Task N 고정 블록의 Task 집합 대조 검사와 `수행 모델` 조건부 검사는 이 이슈의 구현을 증명하는 항목이 아니라 summary 구조를 지키는 게이트라 구현 전에도 통과한다(회귀 방지·조건부 검사). 구현 전 통과와 선행 검사 실패 상태의 `0` 출력을 구현 완료 근거로 쓰지 않으며, 예외는 이 검사 2건에 한정하고 R1·R2·R4·R6·R7·R8의 신규 구현 검사는 예외로 두지 않는다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/40_domain/policies/local/notation-conventions.md` | 모델 기록 "벤더, 모델명" 형식 규약. effort 별도 필드 문장을 더한다 |
| `.ai/40_domain/specs/issue-workflow.md` | summary 구성(모델 기록 표·Task별 지표) 명세. 새 필드를 반영한다 |
| `.ai/40_domain/specs/issue-audit.md` | 감사 리포트 `감사 모델` 메타 줄 요건 (R8 확정 시 갱신) |
| `.ai/50_adr/active/0005-model-separation-gates.md` | 모델 기록 표·Task별 지표 결정. 확장이 결정과 충돌하지 않는지 확인한다 |
| `.ai/50_adr/active/0004-cross-model-audit-and-response-gate.md` | "벤더, 모델명" 형식 통일과 audit 벤더 비교 기준. effort를 비교 조건에 넣지 않는 근거 |
| `.ai/50_adr/active/0003-verification-levels-and-determinization.md` | 결정화 판단 체크리스트. 읽기 헬퍼를 두지 않는 판단 근거 |
| `.ai/10_rules/architecture.md` | 결정화 판단 체크리스트 본문 |
| `.ai/60_codebase/issue-work/start-call-flow.md` | issue-work 색인. 모델 기록 표 언급을 갱신한다 |
