# Issue #108 스펙 issue-work·issue-audit: 회귀 방지 항목 표시 규칙을 spec 템플릿에 도입하고 고정 블록을 가짜 [D] 사전 판별에서 제외

## 목표 (Goal)

issue-work로 세운 계획에 issue-audit `--plan`을 돌려도 회귀 방지 예외 표기 누락 발견이 규칙 공백 때문에 반복해서 나오지 않는다.

---

## 요구사항 (Requirements)

**포함**

- R1: issue-work spec 템플릿이 구현 전에도 통과하는 것이 정상인 DoD 항목(무변경·전체 테스트 통과·형식 검사)에 항목 본문 `(회귀 방지 항목)` 표시를 붙이도록 안내하고, `### 공통` 예시와 R1 줄 끝 공백 예시 본문에 그 표시를 둔다.
- R2: issue-work SKILL.md "완료 기준 형식"이 같은 표시 규칙을 한 줄로 안내하며, 표시 위치는 본문(접기 금지)이다.
- R3: issue-audit `--plan` 관점 2가 issue-work 템플릿 고정 블록(Task 0·Task N)의 완료 기준을 가짜 `[D]` 사전 판별 대상에서 뺀다. 이슈별 spec DoD·plan 일반 Task 완료 기준은 지금처럼 판별하고, 예외 표시 위치("spec 항목 본문")는 유지한다.
- R4: issue-plan 템플릿 Task N 블록 주석이 그 블록은 계획 감사의 가짜 `[D]` 판별 대상이 아님(issue-audit `--plan` 관점 2 예외)을 한 줄로 알린다. Task N 블록의 본문·검증 명령은 바꾸지 않는다. (이슈 본문은 "둘지 검토한다"로 남김. 2026-10-09 요구사항 승인 시 포함 확정)
- R5: 안내도 `.ai/40_domain/specs/issue-audit.md`·`.ai/60_codebase/issue-audit/plan-audit-call-flow.md`가 관점 2의 고정 블록 제외를 반영한다. ADR 0016과 결정 변경 범위를 대조해, 결정이 바뀌면 새 ADR로 기록한다.
- R6: 원장 K-0011은 상태를 `승격(이슈 #108)`로 바꿔 `archive/`로 옮기고, K-0009는 재검토 조건 충족에 따라 `재검토 이력`을 남기고 계속 수용 여부를 정한다. `.ai/70_ledger/index.md` 항목 목록을 함께 갱신한다.
- R7: `.ai/40_domain/specs/issue-workflow.md`의 spec 구성 서술이 완료의 정의 항목의 `(회귀 방지 항목)` 표시를 반영한다. (이슈 본문 근거 없음. 2026-10-09 대화에서 R1과 안내도 정합을 위해 추가, 요구사항 승인 시 포함 확정)

**제외**

- 가짜 `[D]` 사전 판별의 헬퍼 결정화(K-0009 본건): 이슈 본문이 범위에서 제외(보류).
- 예외 범위를 plan 완료 기준까지 넓히고 Task N 항목에 `(회귀 방지 항목)` 표시(대안 C): `수행 모델` 게이트는 선행 게이트에 의존하는 조건부 게이트라 표시 의미가 맞지 않고, 표시 종류가 늘면 K-0009 헬퍼가 읽을 계약이 복잡해진다(대체: R3).
- 원장 등재로 계속 억제: 재검토 조건이 매번 충족되고 다른 repo에는 억제가 미치지 않는다(불필요).
- plan 템플릿 Task N 블록의 검증 명령 변경: 고정 블록 동작은 그대로 두고 감사 쪽 예외로 해결한다(불필요).

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> 검증 명령은 모두 repo 루트에서 실행한다.

### R1: spec 템플릿 표시 규칙

- [ ] [D]  spec 템플릿 완료의 정의 주석이 `(회귀 방지 항목)` 표시 규칙을 안내한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^## 완료의 정의/{f=1} /^> \*\*검증 레벨\*\*/{f=0} f' issue-work/templates/issue-spec-template.md \
    | grep -qF '(회귀 방지 항목)' || echo '위반: DoD 주석에 표시 규칙 없음'
  ```

  - 범위: `## 완료의 정의` 헤더부터 `> **검증 레벨**` 인용 블록 직전까지(주석 영역)만 본다. 예시 항목의 표시와 섞이지 않게 하기 위함이다.
  </details>
- [ ] [D]  `### R1:` 그룹과 `### 공통` 그룹의 첫 `[D]` 예시 항목 본문에 `(회귀 방지 항목)` 표시가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '
    /^##/ { g = ($0 ~ /^### R1: /) ? "R1" : ($0 ~ /^### 공통$/) ? "공통" : "" }
    g && /^- \[ \] \[D\]/ && !seen[g]++ { if (index($0, "(회귀 방지 항목)")) n++ }
    END { if (n != 2) print "위반: 예시 표시 " n+0 "/2" }
  ' issue-work/templates/issue-spec-template.md
  ```

  - 설계 주의: 그룹 판정은 모든 `##`·`###` 헤더에서 다시 하므로 R2 그룹이나 다른 섹션의 표시는 세지 않는다. 표시가 접기 안에만 있으면 본문 행이 아니라서 실패한다.
  </details>
- [ ] [QD] 주석이 표시 대상(구현 전에도 통과하는 것이 정상인 무변경·전체 테스트 통과·형식 검사 항목)과 표시 위치(항목 본문)를 함께 안내한다  (검증: 교차모델 audit 채점)  ← 강등 사유: 안내 문장이 대상·위치를 빠짐없이 담았는지는 의미 판단이라 문구 grep으로는 표기 변형에 취약하다

### R2: SKILL.md 완료 기준 형식

- [ ] [D]  issue-work SKILL.md `### 완료 기준 형식` 소절이 `(회귀 방지 항목)` 표시 규칙을 안내한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^### 완료 기준 형식$/{f=1; next} f && /^##/{f=0} f' issue-work/SKILL.md \
    | grep -qF '(회귀 방지 항목)' || echo '위반: 완료 기준 형식에 표시 규칙 없음'
  ```

  </details>
- [ ] [QD] 그 안내가 표시를 본문(접기 금지)에 둔다고 밝힌다  (검증: 교차모델 audit 채점)  ← 강등 사유: 표시 위치 서술은 문장 의미 판단이다

### R3: issue-audit 관점 2 고정 블록 제외

- [ ] [D]  issue-audit SKILL.md `--plan` 관점 2 행이 고정 블록(Task 0·Task N) 제외를 명시한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -E '^2\. \*\*가짜 `\[D\]` 사전 판별\*\*' issue-audit/SKILL.md \
    | grep -F 'Task 0' | grep -qF 'Task N' || echo '위반: 관점 2 행에 고정 블록 제외 없음'
  ```

  - 설계 주의: 관점 2 행 하나만 대상으로 한다. 제외 문구를 다른 행에 두면 관점 2를 읽는 감사인이 놓칠 수 있어 같은 행에 둔다.
  </details>
- [ ] [D]  관점 2 행이 예외 표시 위치("spec 항목 본문")를 유지한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -E '^2\. \*\*가짜 `\[D\]` 사전 판별\*\*' issue-audit/SKILL.md \
    | grep -qF 'spec 항목 본문' || echo '위반: 예외 표시 위치 문구 유실'
  ```

  </details>
- [ ] [QD] 제외 범위가 고정 블록에 한정되고 이슈별 spec DoD·plan 일반 Task 완료 기준은 판별 대상으로 남는다는 뜻이 관점 2 문장에서 읽힌다  (검증: 교차모델 audit 채점)  ← 강등 사유: 제외 범위의 한정은 문장 의미 판단이다

### R4: plan 템플릿 Task N 주석

- [ ] [D]  plan 템플릿 Task N 블록 주석이 issue-audit `--plan` 관점 2 예외를 안내한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^### Task N \(고정\)/{f=1} f && /^-->$/{exit} f' issue-work/templates/issue-plan-template.md \
    | grep -F 'issue-audit' | grep -qF '관점 2' || echo '위반: Task N 주석에 판별 제외 안내 없음'
  ```

  - 범위: `### Task N (고정)` 헤더부터 첫 주석 닫힘(`-->`)까지다.
  </details>
- [ ] [D]  Task N 블록에서 첫 주석을 뺀 본문(완료 기준·검증 명령 포함)이 `main`과 같다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  f=issue-work/templates/issue-plan-template.md
  strip() { awk '/^### Task N \(고정\)/{f=1} f && !d && /^<!--$/{c=1} f && !c {print} f && c && /^-->$/{c=0; d=1}'; }
  [ -n "$(strip < "$f")" ] || echo '위반: Task N 블록 없음'
  diff <(git show main:"$f" | strip) <(strip < "$f") >/dev/null || echo '위반: Task N 블록 본문 변경'
  ```

  - 설계 주의: 헤더가 바뀌어 양쪽이 모두 빈 출력이면 diff가 통과하므로 현재 파일의 블록 실재를 먼저 확인한다. 머지 전 브랜치에서 실행해야 `main`이 비교 기준이 된다.
  - 설계 주의: 주석 제외는 첫 주석 블록 하나로 한정한다(`d` 플래그). 뒤에 나오는 여러 줄 주석의 추가·변경도 본문 변경으로 잡기 위함이다(계획 감사 F-1).
  - 의존 관계: issue-work `tests/run-tests.sh`가 이 블록의 게이트 명령을 추출해 fixture로 실행하므로, 본문이 바뀌면 `### 공통` 전체 테스트도 함께 실패할 수 있다.
  </details>

### R5: 안내도·ADR 정합

- [ ] [D]  `.ai/40_domain/specs/issue-audit.md`의 `--plan` 모드 행이 고정 블록 제외를 반영한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -E '^- `--plan` 모드:' .ai/40_domain/specs/issue-audit.md \
    | grep -qF '고정 블록' || echo '위반: issue-audit 명세에 고정 블록 제외 없음'
  ```

  </details>
- [ ] [D]  `.ai/60_codebase/issue-audit/plan-audit-call-flow.md`의 가짜 `[D]` 사전 판별 행이 고정 블록 제외를 반영한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -F '가짜 [D] 사전 판별' .ai/60_codebase/issue-audit/plan-audit-call-flow.md \
    | grep -qF '고정 블록' || echo '위반: 호출 흐름 색인에 고정 블록 제외 없음'
  ```

  </details>
- [ ] [D]  `.ai/50_adr/active/` ADR 파일 집합과 `.ai/50_adr/index.md`의 `active/` 행 집합이 일치한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  diff <(ls .ai/50_adr/active | grep -E '^[0-9]{4}-.*\.md$' | sed 's|^|active/|' | sort) \
       <(grep -oE '`active/[0-9]{4}-[^`]+\.md`' .ai/50_adr/index.md | tr -d '`' | sort)
  ```

  - 의도: 새 ADR을 쓰면 index 등재를 함께 강제한다. 새 ADR을 쓰지 않아도 통과하는 것이 정상이다.
  </details>
- [ ] [QD] ADR 0016과의 대조 결과(새 ADR 작성 여부와 근거)가 summary Task 3 `특이 사항`에 기록되고 판단이 타당하다  (검증: 교차모델 audit 채점)  ← 강등 사유: 결정 변경에 해당하는지는 의미 판단이다

### R6: 원장 정리

- [ ] [D]  K-0011이 `archive/`에 있고 상태가 `승격(이슈 #108)`이며, index 항목 행이 같은 경로·상태를 가리킨다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  L=.ai/70_ledger; K=K-0011-plan-audit-regression-exception-spec-only.md
  test -f "$L/archive/$K" || echo '위반: archive에 없음'
  test ! -e "$L/active/$K" || echo '위반: active에 잔존'
  grep -qxF -- '- **상태**: 승격(이슈 #108)' "$L/archive/$K" 2>/dev/null || echo '위반: 상태 값'
  grep -E '^\| \[K-0011\]\(archive/K-0011-' "$L/index.md" | grep -qF '| 승격(이슈 #108) |' || echo '위반: index 행'
  ```

  </details>
- [ ] [D]  K-0009의 `재검토 이력` 표에 이슈 #108 재검토 행이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  k9=$(ls .ai/70_ledger/*/K-0009-*.md 2>/dev/null | head -1)
  [ -n "$k9" ] && awk '/^## 재검토 이력$/{s=1; next} s && /^(## |<details>)/{s=0} s && /^\| 2026-/ && /#108/' "$k9" \
    | grep -q . || echo '위반: K-0009 재검토 이력에 #108 행 없음'
  ```

  - 설계 주의: 계속 수용이면 `active/`, 종결이면 `archive/`에 있으므로 두 위치를 함께 찾는다.
  </details>
- [ ] [D]  원장 `active/`·`archive/` 항목 파일 집합과 index 항목 목록의 링크 집합이 일치한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  diff <(cd .ai/70_ledger && ls active/K-*.md archive/K-*.md 2>/dev/null | sort) \
       <(grep -oE '\]\((active|archive)/K-[0-9]{4}-[^)]+\.md\)' .ai/70_ledger/index.md | sed -E 's/^\]\(//; s/\)$//' | sort)
  ```

  </details>
- [ ] [QD] K-0009 계속 수용 여부 판단과 재검토 조건 갱신이 R1 도입 결과에 비추어 타당하다  (검증: 교차모델 audit 채점)  ← 강등 사유: 수용 판단의 타당성은 의미 판단이다

### R7: issue-workflow 명세

- [ ] [D]  `.ai/40_domain/specs/issue-workflow.md`의 spec 구성 행이 `회귀 방지 항목` 표시를 반영한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -E '^- spec 구성:' .ai/40_domain/specs/issue-workflow.md \
    | grep -qF '회귀 방지 항목' || echo '위반: issue-workflow 명세에 표시 반영 없음'
  ```

  </details>

### 공통

- [ ] [D]  repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>

---

## 전제 (Assumptions)

- **표시 리터럴**: 표시는 괄호를 포함한 `(회귀 방지 항목)`로 고정한다. issue-audit 관점 2의 기존 표시 문구('"회귀 방지 항목"으로 표시')도 이 리터럴로 맞춘다. K-0009 헬퍼가 나중에 읽을 계약을 하나로 두기 위함이다. (리터럴 `(회귀 방지 항목)`은 이슈 본문 방향 A에 있음. issue-audit 기존 문구를 이 리터럴로 맞추는 것은 이슈 본문 근거 없이 2026-10-09 계획 작성 중 R3 구현 방식으로 결정)
- **R1 예시 해석**: spec 템플릿 `### R1:` 그룹의 `[D]` 예시는 접기 안 명령이 줄 끝 공백 검사다. 본문 placeholder 그대로 표시를 붙이면 모든 R 항목에 표시를 붙이라는 뜻으로 읽힐 수 있다. 그래서 본문 문장을 그 명령에 맞춘 구체 문장으로 바꾸고 표시를 붙인다.
- **plan 템플릿 예시는 표시하지 않음**: plan 템플릿 Task 1의 줄 끝 공백 예시에는 표시를 붙이지 않는다. 예외 표시 위치는 spec 항목 본문으로 유지하고(R3), plan 완료 기준까지 넓히는 대안 C는 제외했다.
- **고정 블록 범위**: 제외 대상은 이슈 본문대로 Task 0·Task N이다. 계획 종료 게이트 블록은 `[D]` 완료 기준이 없어 판별 대상이 아니라서 따로 적지 않는다.
- **K-0011 이후 처리**: 승격은 종결 상태라 이 이슈 머지 뒤에 상태를 다시 바꾸지 않는다. 같은 결함이 다시 나오면 원장 수명 주기의 "승격 · 연결 이슈가 닫힘" 행(재발 계보)을 따른다.
- **설치본**: `~/.claude/skills/` 등의 설치본 갱신은 이 이슈 범위 밖이다. 머지 뒤 사용자가 install-skills로 재설치한다.
- **ADR 0016 기록 위치**: ADR 0016에는 결과 절이 없다(결정·근거·대안·원본 출처). 고정 블록 제외는 기존 결정의 보강으로 보고 새 ADR 없이, 결정 절 `--plan` 항목의 "가짜 `[D]` 사전 판별(감사인 수동)"에 고정 블록 제외를 덧붙이고 근거 한 줄과 원본 출처 #108을 더한다. (2026-10-09 Task 0 질의로 확정)
- **K-0009 처리**: 계속 수용한다. 재검토 이력에 #108 행을 더하고, 표기 도입으로 낡는 수용 사유를 "표기는 도입됐고 판별이 갈리는 사례를 모으는 중"으로 고친다. 재검토 조건은 "계획 감사 2회 이상에서 판별 결과가 감사 모델 간에 갈린 사례 관측 시, 또는 `(회귀 방지 항목)` 표시의 리터럴·위치 규칙 변경 시"로 바꾼다. (2026-10-09 Task 0 질의로 확정)
- **색인 frontmatter**: `.ai/60_codebase/issue-audit/plan-audit-call-flow.md`의 `last_synced`는 구현 때 갱신하고, `source_hash`는 커밋 요청 시 issue-audit/SKILL.md 변경 커밋을 먼저 만든 뒤 그 해시로 맞춘다(#102 선례). `.ai/40_domain/specs/`의 `last_harvested`는 수집 시점 필드라 편집으로 갱신하지 않는다(기존 이슈 선례). (2026-10-09 Task 0 질의로 확정)

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/50_adr/active/0016-spec-requirements-layer-and-plan-audit.md` | `--plan` 계획 감사·관점 2 결정. R3·R5의 결정 변경 범위 대조 기준 |
| `.ai/50_adr/active/0003-verification-levels-and-determinization.md` | 검증 레벨·가짜 `[D]` 함정·완료 기준 접기 형식. R1·R2 표시 규칙의 근거 |
| `.ai/40_domain/specs/issue-audit.md` | issue-audit `--plan` 요건 안내도. R5 갱신 대상 |
| `.ai/40_domain/specs/issue-workflow.md` | issue-work spec·plan 구성 안내도. R7 갱신 대상 |
| `.ai/60_codebase/issue-audit/plan-audit-call-flow.md` | 계획 감사 호출 흐름 색인. R5 갱신 대상 |
| `.ai/70_ledger/active/K-0011-plan-audit-regression-exception-spec-only.md` | 이 이슈로 승격하는 원장 항목. R6 |
| `.ai/70_ledger/active/K-0009-plan-audit-fake-d-check-manual.md` | 재검토 조건이 R1로 충족되는 원장 항목. R6 |
