# Issue #94 스펙 issue-work: 스펙에 요구사항(Requirements) 섹션 신설과 범위(Scope) 통합, DoD·Task를 요구사항 단위로 연결

> 이 spec/plan은 이 이슈가 정의하는 신구조의 첫 적용례로 작성했다. 현행 템플릿과 형식이 다른 것은 의도된 것이다 (`## 전제` 참조).

## 목표 (Goal)

issue-work 스펙·계획 템플릿에 요구사항 층을 신설해, 목표를 무엇으로 달성하는지(요구사항)와 검증(DoD)·실행(Task)이 요구사항 단위로 연결되게 한다.

---

## 요구사항 (Requirements)

**포함**

- R1: 스펙 템플릿에 `## 요구사항 (Requirements)` 섹션이 생겨, 포함 목록(R<n> 번호 + 무엇이 가능해져야 하는지 한 문장)과 제외 목록(항목 + 이유 한 줄)을 안내 주석과 함께 적을 수 있다.
- R2: 스펙 템플릿에서 `## 범위 (Scope)` 섹션이 사라지고, 경계 선언이 요구사항의 제외 목록으로 일원화된다.
- R3: 스펙 템플릿의 완료의 정의가 요구사항 단위 그룹으로 구조화된다. 상위는 레벨 태그 없는 그룹 제목(`### R<n>: <짧은 이름>`, 횡단 항목은 `### 공통`)이고, 합·불 판정은 레벨 태그를 유지한 하위 항목이 맡으며, `[D]`가 못 덮는 나머지를 `[QD]`/`[ND]`로 그룹 안에 남기는 규칙이 안내된다.
- R4: 계획 템플릿의 일반 Task에 `- **대상 요구사항**: R<n>` 필드가 생기고, 고정 Task(Task 0·Task N)에는 이 필드를 두지 않는다.
- R5: issue-work SKILL.md·워크플로우 템플릿과 issue-audit의 스펙 구성 참조 문구가 새 구성(목표·요구사항·완료의 정의·전제·연관 문서)과 정합한다.
- R6: 기존 결정적 헬퍼·테스트가 새 구조에서도 통과하고, 옛 구조를 전제하는 부분이 있으면 함께 갱신된다.

**제외**

- 기존 active/archive 이슈 문서의 소급 개정: 신규 이슈부터 적용한다.
- issue-audit 절차 자체의 개편: R5의 문구 정합(3단계 명칭 개명 포함)으로 한정한다. 감사 3단계 구조 자체는 유지한다.
- summary 템플릿 변경: 이번 구조 변경이 summary의 계약(Task 헤더 집합·지표 필드)에 닿지 않는다. 필요가 드러나면 별도 이슈로 본다.
- 전제(Assumptions)의 정책/기술 하위 분류: 2026-08-31 논의에서 실익 없음으로 결론. 유형 분류 대신 "깨지면 무엇이 무너지나"로 요구사항·DoD 승격을 판단한다.

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

### R1: 요구사항 섹션 신설

- [ ] [D] 스펙 템플릿에 요구사항 헤더와 포함·제외 하위 목록 구조가 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-spec-template.md
  { grep -qE '^## 요구사항 \(Requirements\)$' "$T" \
    && grep -qE '^\*\*포함\*\*$' "$T" \
    && grep -qE '^\*\*제외\*\*$' "$T" \
    || echo '위반: 요구사항 섹션 구조(헤더·포함·제외) 누락'; }
  ```

  - 설계 주의: 문구가 아니라 행 앵커(`^## `, `^\*\*…\*\*$`)를 센다. 하위 목록 표기는 `**포함**`/`**제외**`로 고정한다 (`## 전제` 참조).
  </details>
- [ ] [QD] 안내 주석이 포함 항목의 동작·보장 중심 서술과 제외 항목의 이유 병기(보류·대체·불필요)를 설명한다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 주석 서술의 충분성은 의미 판단이라 명령으로 환원 불가

### R2: 범위 섹션 제거

- [ ] [D] 스펙 템플릿에 범위 섹션 헤더가 남아 있지 않다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -nE '^## 범위' issue-work/templates/issue-spec-template.md
  ```

  </details>

### R3: DoD 그룹 구조

- [ ] [D] 스펙 템플릿 DoD에 R 그룹 예시 헤더와 공통 그룹 헤더가 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-spec-template.md
  { grep -qE '^### R1: ' "$T" && grep -qE '^### 공통$' "$T" \
    || echo '위반: DoD 그룹 예시(R1·공통) 누락'; }
  ```

  </details>
- [ ] [QD] 안내가 그룹 규칙(상위 무태그·짧은 이름만, 판정은 하위 전담, 커버리지 잔여의 `[QD]`/`[ND]` 명시, 공통 그룹 용도)을 설명한다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 규칙 설명의 충분성은 의미 판단이라 명령으로 환원 불가

### R4: Task 대상 요구사항 필드

- [ ] [D] 계획 템플릿의 일반 Task 예시에 `대상 요구사항` 필드가 블록당 정확히 1개 있고, 고정 Task 블록에는 0건이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  P=issue-work/templates/issue-plan-template.md
  awk '
    function flush() { if (!o) return
      if (fixed && c > 0) print "위반(고정 Task에 대상 요구사항 필드): " t
      if (!fixed && c != 1) print "위반(일반 Task 필드 " c "개): " t }
    /^### Task / { flush(); o = 1; t = $0; c = 0; fixed = ($0 ~ /고정/) }
    o && /^- \*\*대상 요구사항\*\*:/ { c++ }
    END { flush() }
  ' "$P"
  ```

  - 설계 주의: 총개수 비교는 고정 Task의 오기와 일반 Task의 누락이 상쇄되어 통과하므로 블록 단위로 센다. 고정 여부는 헤더의 `고정` 표기로 판별한다.
  </details>

### R5: 참조 문구 정합

- [ ] [D] 옛 구성 서술("목표, 범위" 병렬)과 옛 경계 개념("비포함(Out)", "·범위 대조")이 스킬 문서에 남아 있지 않다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -rnE '목표, 범위' --include='*.md' issue-work/ .ai/90_issues/active/issue-workflow.md
  grep -rnE '비포함 ?\(Out\)|·범위 대조|범위 검증' --include='*.md' issue-work/ issue-audit/
  ```

  - 설계 주의: `.ai/90_issues/active/issue-workflow.md`는 템플릿의 상주 사본이라 명시적으로 포함한다. archive 이슈 문서는 소급 대상이 아니므로 검사하지 않는다.
  </details>
- [ ] [QD] 갱신된 문구가 새 구성을 정확히 반영한다 (SKILL.md 스펙 구성 서술, `--response` 1단계 대조 기준, issue-audit 경계 검증의 명칭·대조 원천)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 문구의 의미 정합은 명령으로 환원 불가

### R6: 헬퍼·테스트 정합

- [ ] [D] issue-work 테스트 스위트가 통과한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 실패 0건·종료 코드 0이면 통과</summary>

  ```bash
  issue-work/tests/run-tests.sh
  ```

  </details>

### 공통

- [ ] [D] repo 전체 스킬 테스트가 통과한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  - 설계 주의: 러너 명명이 `run-tests.sh` 관례(ADR 0001)임을 전제한다. 2026-08-31 기준 10개 스킬 전부 이 관례를 따름을 확인했다.
  </details>

---

## 전제 (Assumptions)

- 이 이슈의 spec/plan 자체를 신구조의 첫 적용례로 작성했다. 템플릿 개편 전이라 현행 템플릿과 형식이 다르며, 이 문서가 확정 형식의 실증 표본이다.
- 형식 확정값 (2026-08-31 사용자 논의로 결정, GitHub 이슈 #94 본문이 SSoT):
  - 요구사항 하위 목록 표기는 `**포함**`/`**제외**`. 포함 항목은 `- R<n>: <한 문장>`, 제외 항목은 번호 없이 `- <항목>: <이유 한 줄>`.
  - DoD 그룹 제목은 `### R<n>: <짧은 이름>`과 `### 공통`(횡단 항목 전용, 없으면 생략 가능). 그룹 제목에 요구사항 문장을 재기재하지 않는다.
  - 계획의 대상 요구사항 표기는 별도 필드 `- **대상 요구사항**: R<n>[, R<m>]`으로 하고 `목표` 필드 다음 행에 둔다. 고정 Task에는 필드 자체를 두지 않는다.
  - 전제의 정책/기술 하위 분류는 하지 않는다. 가벼운 신호가 필요하면 항목 앞 `(정책)`/`(기술)` 표기를 선택 허용한다.
- 구현 세부 결정 (2026-08-31 Task 0 질의로 확정):
  - issue-audit의 감사 3단계는 구조를 유지하되, 3단계 명칭을 "범위 검증"에서 "경계 검증"으로 개명하고 대조 원천을 "스펙의 비포함(Out)"에서 "스펙 요구사항의 제외 목록"으로 바꾼다. 리포트 템플릿의 `### 범위 검증` 헤더도 `### 경계 검증`으로 바꾼다. 이름은 제외 목록 침범과 스펙에 없는 추가 구현(무단 확장) 두 확인을 함께 담아야 해서 "제외 검증"으로 하지 않았다.
  - issue-work SKILL.md `--response` 1단계 문구 "요구사항·DoD·범위 대조"는 "요구사항(포함·제외)·DoD 대조"로 바꾼다.
- 헬퍼 확인 결과 (2026-08-31): `check-clear.sh --completion`은 plan의 게이트 체크박스와 `^### Task ` 블록당 체크박스 1개만 전제하므로 필드 추가와 충돌하지 않는다. `summarize-metrics.sh`는 summary만 파싱한다. spec 구조를 파싱하는 헬퍼는 없다.
- 이 repo의 스킬 실행본은 install-skills로 홈 경로(`~/.claude/skills/`)에 설치된 사본이다. repo 파일 수정 후 재설치 전까지 실행본과 차이가 나는 것은 정상이며, 이번 작업 대상은 repo 파일이다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| [GitHub 이슈 #94](https://github.com/scroogy-dev/scroogy-agent-skills/issues/94) | 배경·결정 사항의 SSoT |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 헬퍼·테스트 배치 규칙 (R6 확인 시) |
| `.ai/10_rules/writing-principles.md` | 템플릿 안내 문구 작성 원칙 |
| `.ai/10_rules/architecture.md` | 결정화 판단 기준 (헬퍼 수정이 생길 경우) |
