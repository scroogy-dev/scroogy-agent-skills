# Issue #102 실행요약 issue-work: 모델 기록에 effort(추론 강도) 기록 추가

> 스펙: [issue-0102-spec.md](./issue-0102-spec.md) | 계획: [issue-0102-plan.md](./issue-0102-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다.

## 모델 기록

<!--
이슈 단위 요약(대표값)이다. 세부 SSoT는 아래 `Task별 수행 결과`의 `수행 모델`·`수행 effort`이며,
한 구분에 여러 모델이 관여했으면 대표 모델을 적고 세부는 Task별 기록을 본다.

이 summary는 이 이슈(#102)가 도입하는 새 형식(표 `effort` 열, Task `수행 effort` 필드)을 선반영했다.
구현 검증 표본(spec 공통 [D])으로 쓰기 위함이며, 템플릿 반영은 Task 1에서 한다.

형식: 모델은 "벤더, 모델명". effort는 도구가 기록한 표기 그대로(`high`, `xhigh` 등), 확인 불가면 `-`.
벤더가 다르면 같은 이름의 단계라도 같은 수준이라는 보장이 없으므로 effort는 벤더끼리 비교하지 않고, 게이트 조건에도 쓰지 않는다.
"계획 audit 모델 ≠ 계획 모델"·"최종 audit 모델 ≠ 구현 모델" 조건은 모델 열의 벤더로만 확인한다.
계획 감사를 건너뛴 이슈는 계획 audit 모델 행과 표 아래 계획 감사 줄에 `생략`을 적는다.
-->

| 구분 | 모델 | effort |
|------|------|--------|
| 계획 모델 | Anthropic, Claude Fable 5.1 (claude-fable-5-1) | high |
| 계획 audit 모델 | OpenAI, GPT-6 | high |
| 구현 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | high |
| 최종 audit 모델 | OpenAI, GPT-6 (gpt-6-astra) | high |

- **계획 감사**: 수행 · 발견 4건 · 보정 4건

<!--
5단계 결정 전에는 비워 둔다. 수행했으면 `수행 · 발견 N건 · 보정 N건`, 건너뛰었으면 `생략`을 적는다.
이 줄은 `## 모델 기록` 섹션 안, 첫 `### Task ` 앞에 둔다.
2026-09-24 1차 계획 감사(리포트 [issue-0102-plan-audit-report-1.md](./issue-0102-plan-audit-report-1.md), 작성 시점 경로는 `.ai/99_workspace/issue-0102-plan-audit-report.md`, --clear로 이관): 1단계 미충족 0건, 2단계 중간(MEDIUM) 4건.
`--response`에서 F-1·F-2·F-3 반영, F-4 부분 반영(Task N 고정 블록 제외). 감사 effort는 리포트에 줄이 없어(R8 구현 전) 사용자가 표에 기입한다.
2026-09-24 2차 계획 감사(같은 리포트 경로, 1차는 `-1` 접미로 보존. 이관 후 [issue-0102-plan-audit-report-2.md](./issue-0102-plan-audit-report-2.md)): 1단계 미충족 0건, 신규 발견 0건, F-4 잔여 1건.
`--response`에서 F-4 잔여를 spec 전제(Task N 검사 2건의 사전 통과 예외)로 반영해 발견 4건 전부 닫힘. 건수는 1차와 같아 위 줄을 유지한다.
2026-09-24 3차 계획 감사(같은 리포트 경로, 2차는 `-2` 접미로 보존. 이관 후 [issue-0102-plan-audit-report.md](./issue-0102-plan-audit-report.md)): 적합(PASS), 1단계 21건 충족, 이전 발견 F-1~F-4 닫힘, 신규 발견 0건.
`--response`에서 보정 대상 없음. 건수 변동이 없어 위 줄을 유지한다.
-->

---

## Task별 수행 결과

<!--
Task 0 및 일반 실행 Task(Task N 제외) 블록의 지표 5종은 사후 집계용이라 표기를 고정한다
(값이 없어도 필드는 지우지 않는다. Task N 예외의 근거는 아래 Task N 블록 주석).
- 수행 모델: "벤더, 모델명" — `모델 기록` 표와 같은 형식. 한 Task를 모델 전환·재시도로 둘 이상이 수행했으면
  관여한 모델을 전부 ` / `로 나열한다 — 하나만 남기면 누락된 벤더가 audit을 맡아도 Task N의 강화 조건을 통과한다.
  같은 모델이 effort를 바꿔 다시 수행했으면 그 자리에 반복해 적는다(아래 `수행 effort`의 위치 대응).
  `-`는 미착수·스킵 Task 전용이며, `결과`가 완료·부분 완료면 실제 값을 필수로 기록한다
  (`-`로 남기면 Task N의 교차모델 강화 조건이 공집합이 되어 우회가 된다)
- 수행 effort: 그 Task를 수행한 모델의 effort. 도구가 기록한 표기(`high`, `xhigh` 등) 그대로 적는다.
  한 Task 안에서 바꿨으면 `수행 모델`과 같은 순서로 ` / `로 나열하고, 두 목록은 위치로 대응한다.
  항목 수를 `수행 모델`과 같게 두고, 확인할 수 없는 값은 그 자리에 `-`를 두며, 같은 effort가 이어지면 그대로 반복한다.
    A/high 뒤 A/low 뒤 B/high:  수행 모델 `A / A / B`, 수행 effort `high / low / high`
    A/high 뒤 B/low 뒤 B/high:  수행 모델 `A / B / B`, 수행 effort `high / low / high`
    A/high 뒤 B(확인 불가):     수행 모델 `A / B`, 수행 effort `high / -`
  확인 불가 외에 미착수·스킵 Task도 `-`로 둔다. 벤더끼리 비교하지 않고 게이트 조건에 쓰지 않는 점은 위 `모델 기록` 주석과 같다.
  값을 읽는 위치(실행 기록 우선)는 issue-work SKILL.md `## 작업 진행 중`을 따른다.
- audit 발견: 이 Task와 관련된 audit 발견사항 건수 — 없으면 `0건` (`-` 금지)
- 보정 반영: `--response` 항목별 승인을 통과해 실제로 보정한 건수 — 없으면 `0건` (`-` 금지)
- 재시도: 같은 Task에서 재수정·재시도한 횟수 — 없으면 `0회` (`-` 금지)

한 발견이 여러 Task 산출물에 걸쳐도 가장 직접 수정된 주 Task 하나에만 귀속한다 —
`audit 발견`·`보정 반영` 모두 그 주 Task에서 1회만 세고 관련된 다른 Task에는 세지 않는다.
Task 축에서도 이슈 단위 합계가 중복으로 부풀지 않게 하기 위함이다(아래 회차 축 중복 제외와 같은 취지).

수치 3종은 회차별 값이 아니라 이슈 전체 누적이다 — 여러 차수 감사가 같은 발견을 재확인해도
1건으로 세고(중복 제외), 새 회차 값으로 덮어쓰지 않는다. 보정률 사후 집계의 분모·분자가 회차 반복으로 부풀지 않게 하기 위함이다.

수치 3종에 `-`를 쓰지 않는 이유: 아래 스니펫이 `[0-9]+`만 추출하므로 `-`인 Task는
합계에서 조용히 빠지고, 전부 `-`면 합계 자체가 빈 문자열이 된다. `-` 허용은 비수치 필드(`수행 모델`·`수행 effort`)에만 둔다.

수치 3종의 기본값은 주석이 아니라 리터럴 `0건`/`0회`로 둔다: 주석 placeholder는 렌더링 값이
비어 있는데도 집계기가 주석 안 숫자를 실제 값으로 오인하고, `미기록` 같은 형식 위반도 걸러지지 않는다.

보정률은 별도 필드로 두지 않고 `보정 반영 / audit 발견`으로 사후 집계한다.
아래 스니펫이 동작하도록 `- **<필드>**: <숫자><단위>` 표기를 지킨다 (줄 시작, 굵게, 콜론 뒤 숫자).

  # 이슈 하나의 보정률
  found=$(grep -E '^- \*\*audit 발견\*\*:' issue-<번호>-summary.md | grep -oE '[0-9]+' | paste -sd+ - | bc)
  fixed=$(grep -E '^- \*\*보정 반영\*\*:' issue-<번호>-summary.md | grep -oE '[0-9]+' | paste -sd+ - | bc)
  echo "보정률: ${fixed}/${found}"

  # 모델별 집계는 `수행 모델`·`수행 effort` 행과 함께 뽑는다
  grep -E '^- \*\*(수행 모델|수행 effort|audit 발견|보정 반영|재시도)\*\*:' issue-<번호>-summary.md
-->

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: 전제 누락 없음
- **특이 사항**: 착수 전 사용자가 계획 감사 보정으로 바뀐 spec R3를 재승인했다(3-1 게이트 재확인). Task 1~6 대상 파일을 대조해 plan 지시와 어긋나는 현재 상태가 없음을 확인했다. R7 후보 4건 밖에서 모델 기록을 언급하는 상주 문서(`.ai/60_codebase/index.md`, `plan-audit-call-flow.md`, ADR 0016, 원장 K-0009)는 effort 도입과 어긋나는 서술이 없어 범위에 넣지 않는다. 수행 effort는 실행 기록(`~/.claude/projects/<repo>/<세션>.jsonl`)과 `CLAUDE_EFFORT` 값이 `high`로 일치했다.

---

### Task 1: summary 템플릿에 effort 열·수행 effort 필드·값 규칙 추가

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `issue-summary-template.md`의 `모델 기록` 표를 `구분·모델·effort` 3열로 바꾸고 4행 effort 셀에 placeholder를 두었다. audit 두 행은 감사 리포트의 `감사 effort` 줄 값을 사용자가 옮겨 적는다고 안내한다(R8과 연결). 표 위 주석에 effort 규칙(도구 표기 그대로, 확인 불가 `-`, 모델 열 형식 유지, 벤더 간 비교 안 함, 게이트 조건 미사용)을 더했다. Task 0·1·2 블록에 `- **수행 effort**: -`를 `수행 모델` 바로 다음 행에 넣고, Task N 주석에 effort도 `최종 audit 모델` 행이 SSoT라는 줄을 더했다. `## Task별 수행 결과` 주석은 지표 5종으로 고치고 `수행 effort` 항목(위치 대응 규칙, 이력 3가지 예시)과 `수행 모델`의 반복 기재 문장을 추가했다. `-` 허용 비수치 필드와 모델별 집계 grep 스니펫에도 `수행 effort`를 넣었다. 이 이슈 summary의 같은 주석은 템플릿 주석으로 교체했다. spec R1 [D] 무출력, R2 [D] 블록 검사 0·기본값 3건·템플릿 `지표 4종` 0건, issue-work 테스트 94건 통과, 전체 스킬 테스트 통과, `summarize-metrics.sh` exit 0.
- **특이 사항**: 계획 감사를 건너뛴 이슈의 `계획 audit 모델` 행 effort 셀에도 `생략`을 적도록 안내했다. 기존 규칙이 행 단위로 `생략`을 적게 하므로 두 셀을 같게 맞췄다. 모델 기록 표의 `구현 모델` 행을 이 세션 값으로 채웠다.

---

### Task 2: SKILL.md 갱신 절차에 effort 기록 규칙과 읽는 위치 기재

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `issue-work/SKILL.md` `## 작업 진행 중`의 Task 완료 항목을 지표 5종으로 고치고, 헬퍼 검사 대상이 수치 3종뿐이며 `수행 모델`·`수행 effort`는 검사하지 않는다고 명시했다. 같은 항목 아래에 `수행 effort` 기록 규칙을 더했다. 구현 AI가 자기 세션 값을 채우고, 실행 기록(Claude Code jsonl·`CLAUDE_EFFORT`, Codex `rollout-*.jsonl`의 `turn_context`)을 우선하며, 설정 파일(`settings.json`·`config.toml`)은 보조로만 쓴다. 로컬 기록이 없는 도구는 사람이 적고, audit 모델 effort는 사용자가 리포트 `감사 effort` 줄에서 옮기며, 확인 불가면 `-`(헬퍼 위반 아님)로 적는다. 표 행을 채우는 시점 문장 3곳(3-2 `계획 모델`, 5단계 `계획 audit 모델`, `## 작업 진행 중` Task N `최종 audit 모델`)과 `## 관련 skill` issue-audit 항목에 effort를 병기했다. `## 이슈 완료 시` Task N 완료 조건에는 effort가 `-`여도 완료를 막지 않는다는 문장만 더했다. spec R4 [D] 무출력, 전체 스킬 테스트 통과, `git diff --check` 무출력.
- **특이 사항**: 읽는 위치는 이 세션에서 실제 파일로 확인했다. Claude Code jsonl의 `model`·`effort`와 `CLAUDE_EFFORT`, Codex 최신 `rollout-*.jsonl`의 `turn_context` `payload.model`·`payload.effort`, `settings.json`의 `effortLevel`(전역·모델별), `config.toml`의 `model_reasoning_effort`가 모두 있다.

---

### Task 3: workflow·plan 템플릿 정합 확인과 사본 동기화

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: 두 템플릿 모두 변경 없음. `issue-workflow-template.md`에서 모델 기록을 언급하는 문장은 2곳이다. 계획 감사 줄의 `생략` 기재 문장은 행 단위 규칙이라 effort 칸을 포함해도 사실과 맞는다. Task N 완료 조건은 모델 기록만 요구하며 effort를 조건에 넣지 않는 이 이슈 방침과 같다. 템플릿을 고치지 않았으므로 `active/issue-workflow.md` 사본 동기화도 없으며 `diff -q` 무출력이다. `issue-plan-template.md` Task N 게이트의 awk는 `^- \*\*수행 모델\*\*:`·`^- \*\*결과\*\*:` 앵커만 보므로 `수행 effort` 행에 걸리지 않는다. [QD] 벤더 대조 2건은 모델 열·`수행 모델` 값의 벤더만 비교하므로 effort 열이 생겨도 문장이 그대로 성립한다.
- **특이 사항**: 게이트 영향은 effort 행을 선반영한 이 이슈 summary에 Task 집합 대조와 `수행 모델` 게이트를 실행해 사전 확인했다(각각 무출력·`0`). fixture 기반 정상 통과·반례 격추 확인(spec R5 둘째 [D])은 Task 4의 테스트 실행에서 한다.

---

### Task 4: 테스트 fixture에 수행 effort 반영

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `issue-work/tests/run-tests.sh`의 게이트 fixture(`summary-valid.md`) Task 0·1·2와 집계 fixture(`summary-metrics.md`) Task 0·1, 모두 5블록의 `수행 모델` 바로 다음 행에 `수행 effort`를 넣었다. 값은 완료·부분 완료 Task에 `high`·`xhigh`, 스킵 Task에 `-`다. 반례 fixture는 게이트 fixture에서 awk로 파생되고 `수행 모델`·`결과` 행만 변형하므로 수정하지 않았다. spec R6 [D] 무출력(블록 5개 각각 1행, 위치 일치), issue-work 테스트 `passed: 94, failed: 0`, 전체 스킬 테스트 통과, `git diff --check` 무출력.
- **특이 사항**: 테스트 94건에 plan 템플릿에서 추출한 Task N 게이트 3종의 정상 통과·반례 격추가 포함되어, spec R5 둘째 [D]도 이 실행으로 충족된다. 게이트 fixture Task 1의 effort를 `xhigh`로 두어 fixture 안에서 도구 표기가 한 가지로 고정되지 않게 했다.

---

### Task 5: 명세·정책·색인 문서 정합

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `.ai/40_domain/specs/issue-workflow.md`의 summary 구성 문장에 표 `effort` 열과 Task `수행 effort`, 지표 5종 필드 유지, effort 값 규칙(도구 표기 그대로·벤더 간 비교 안 함·게이트 미사용)을 더하고, 결정적 헬퍼 문장의 `summarize-metrics.sh` 설명을 수치 3종 표기 검사·보정률 집계로 고쳤다. `notation-conventions.md`에 effort 별도 필드 관례 한 항목과 원본 출처 Issue #102 링크를 더했다(`last_harvested` 유지). `start-call-flow.md`의 헬퍼 주석은 수치 지표 3종 표기 검사로, 필드 유지 문장은 지표 5종으로 고치고 `last_synced`를 2026-09-24로 갱신했다(`source_hash`는 커밋 뒤 갱신). `issue-audit/SKILL.md` 계획 감사 입력 문장에 `계획 모델` 행의 모델 열 벤더만 비교하고 effort 열은 비교하지 않는다는 괄호를 더했다. ADR 0004·0005는 편집하지 않았다. spec R7 [D] 무출력, R2 셋째 [D] 무출력(시스템 grep 기준), 전체 스킬 테스트 통과, `git diff --check` 무출력.
- **특이 사항**: spec R2 셋째 검증 명령은 BSD `grep -rn ... .`가 경로 앞에 `./`를 붙인다는 전제로 제외 패턴 `^\./\.ai/`를 쓴다. 이 세션의 셸 `grep`은 ugrep 래퍼 함수라 `./` 없이 출력해 제외가 걸리지 않았고, 90_issues·99_workspace 행만 나왔다. `/usr/bin/grep`으로 재실행하면 무출력이다. repo 상주 문서의 잔존은 0건이다. `issue-audit/SKILL.md`의 계획 감사 결과 기록 문장(감사 모델을 `계획 audit 모델` 행에 기록)은 `감사 effort` 줄과 함께 다루도록 Task 6으로 넘겼다.

---

### Task 6: issue-audit 리포트 머리말에 감사 effort 줄 추가

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `issue-audit-report-template.md` 머리말의 `> 감사 모델:` 줄 바로 다음에 `> 감사 effort:` 줄을 같은 강제 개행(줄 끝 두 칸)으로 넣었다. `issue-audit/SKILL.md` 3단계 4번에 `감사 effort` 줄 규칙(도구 표기 그대로, 확인 불가 `-`, summary 해당 audit 행 `effort` 열로 옮겨 적음, 벤더 간 비교·판정·교차 조건 미사용)을 더하고, Task 5에서 넘긴 계획 감사 결과 기록 문장을 모델·effort 열 기록으로 고쳤다. `.ai/40_domain/specs/issue-audit.md` 리포트 메타 문장에 `> 감사 effort:`를 병기했다. `final-audit-call-flow.md` 리포트 주석에 effort 별도 줄을 더하고 `last_synced`를 2026-09-24로 갱신했다(`source_hash`는 커밋 뒤 갱신). spec R8 [D] 무출력, spec 공통 첫 [D](전체 스킬 테스트) 무출력.
- **특이 사항**: `git diff --check`가 새 머리말 줄의 줄 끝 두 칸을 trailing whitespace로 보고한다. plan 작업 내용이 지정한 마크다운 강제 개행이고, 같은 머리말의 기존 줄(감사 일시·감사 모델·감사 회차 등)도 모두 같은 형식이라 유지했다.

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

<!--
사용자가 직접 수행하며, 구현 AI는 이 블록을 대신 채우지 않는다.
지표를 두지 않는다. 수행 모델·effort는 위 `모델 기록` 표의 `최종 audit 모델` 행이 SSoT이고,
audit 발견·보정 반영은 이 Task가 만들어낸 값이라 각 대상 Task 블록에 집계된다.
-->

- **결과**: 완료
- **수행 내용 요약**: 사용자가 OpenAI GPT-6(effort high)로 `issue-audit` 1차 최종 감사를 수행했다(리포트 [issue-0102-audit-report.md](./issue-0102-audit-report.md), 작성 시점 경로는 `.ai/99_workspace/issue-0102-audit-report.md`, --clear로 이관, 감사 HEAD `ee0fc16`). 판정 적합(PASS)이며 1단계 요구사항 8건·DoD 16건 모두 충족, 2단계 발견 0건, 기등재 참조 0건이다. `--response`에서 판정에 동의했고 보정·이관 대상은 없다. 검토 시 전체 스킬 테스트 10개 통과와 `summarize-metrics.sh` exit 0을 다시 확인했다.
- **특이 사항**: 감사 벤더(OpenAI)는 구현 모델과 Task 0~6 `수행 모델`의 벤더(Anthropic)와 다르다. `git diff --check`의 줄 끝 공백 1건(감사 템플릿:5)은 Markdown 강제 개행이라 결함으로 분류하지 않았다.
