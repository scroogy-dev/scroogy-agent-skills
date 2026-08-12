# Issue #87 실행계획 전체 스킬 번역투 문체 일괄 정비

> 스펙: [issue-0087-spec.md](./issue-0087-spec.md)

---

## 설계 종료 게이트 (고정)

> **점검 질문**: 이 spec/plan만 보고, 작성에 참여하지 않은 쪽이 구현에 필요한 내용을 스스로 알 수 있는가?

- [x] 점검 완료
- **점검 대상** (작성 중 머릿속에만 있었던 것):
  - 코드베이스 관례 — 이 repo에서만 통하는 패턴·명명·배치 규칙
  - 버전·환경 제약 — 특정 버전·플랫폼·도구에 묶인 조건
  - 검토 후 버린 대안과 그 이유
  - 사용자와의 합의로만 정해진 값
- **발견 시 조치**: spec `## 전제 (Assumptions)` 섹션에 적는다. 발견이 없으면 그 섹션에 "없음" 한 줄을 남긴다.
- **점검 결과**: 발견 7건을 spec `## 전제 (Assumptions)`에 반영했다 (검사 기준 SSoT, em dash 심사 기준, 고정 문구 불변, 동기화 쌍 처리, 건수 산정 기준, 대상 제외 근거, 재배포 범위 외).

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> **작성 원칙**: 구현자에게 이 문서 외 컨텍스트가 없다고 가정하고, Task별 완료 기준을 결정적으로 씁니다.
>
> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> **공통 절차 (Task 2~5)**: 그룹 파일을 통독해 삽입구·절 연결 em dash를 쉼표·마침표·괄호로 재작성하고,
> 부정 대조·수사적 콜론·3항 병렬·하이픈 합성·은유 직역을 심사해 고치되, 정당한 사용(spec 전제의 예외 유형)은
> 고치지 않고 `issue-0087-exceptions.md` 표에 등재한다. 의미·구조·산출물 형식은 바꾸지 않는다.
> 그룹 검증은 spec DoD 스니펫의 대상을 그룹 파일로 좁혀 실행한다.

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- [x] 완료
- **목표**: 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 코드 작성 전에 걷어낸다.
- **작업 내용**:
  1. spec/plan을 읽고, 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 나열한다.
  2. 항목이 있으면 **코드를 쓰기 전에 사용자에게 질의**하고, 답변을 spec `## 전제 (Assumptions)` 섹션에 반영한 뒤 구현을 시작한다. 특히 spec 전제의 em dash 심사 기준(구분자 용법 허용)은 작업량을 좌우하므로 사용자 확인을 받는다.
  3. 항목이 없으면 summary Task 0의 `수행 내용 요약`에 `전제 누락 없음` 한 줄을 기록하고 진행한다.
- **완료 기준**:
  - [ND] 나열한 항목이 전부 spec `## 전제 (Assumptions)`에 반영되어 미해소 0건이거나, summary Task 0에 `전제 누락 없음`이 기록된다  (검증: 사람 리뷰)  ← 강등 사유: 전제·모호점을 빠짐없이 나열했는지는 의미 판단이라 명령으로 환원 불가

---

### Task 1: 검사 기준·예외 분류 확정

- [x] 완료
- **목표**: #86 패턴 6종을 검사식·심사 지침으로 고정하고, 이후 Task가 공유할 예외 목록 골격을 만든다.
- **작업 내용**:
  1. `.ai/90_issues/archive/issue-0087/issue-0087-exceptions.md`를 생성한다. 구성은 3개 섹션이다.
     - `## 검사식`: grep 가능한 패턴 2종(em dash, "가 아니라")의 스캔 명령과 건수 산정 기준(패턴 포함 행 수), 스캔 스코프 find 명령
     - `## 심사 지침`: grep으로 못 거르는 패턴 4종(수사적 콜론·3항 병렬·하이픈 합성·은유 직역)의 판별 기준과 수정 지침
     - `## 예외 목록`: `| 파일 | 패턴 | 허용 건수 | 분류 | 근거 |` 표 (분류 값은 메타 사용 / 형식 고정 / 구분자 용법 / 코드 블록 리터럴 / 정당한 대조 / 수용)
  2. 기준 시점 잔존 현황(파일별 건수)을 접기로 기록해 이후 Task의 진행 대조 기준으로 삼는다.
- **완료 기준**:
  - [D] 예외 목록 파일에 3개 섹션과 표 헤더가 존재한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    EX=.ai/90_issues/archive/issue-0087/issue-0087-exceptions.md
    for a in '^## 검사식$' '^## 심사 지침$' '^## 예외 목록$' '^\| 파일 \| 패턴 \| 허용 건수 \| 분류 \| 근거 \|$'; do
      grep -qE "$a" "$EX" || echo "위반: 앵커 없음 $a"
    done
    ```

    </details>
  - [QD] 심사 지침이 #86 패턴 6종을 빠짐없이 커버한다  (검증: 교차모델 audit이 writing-principles.md 표현 소절과 대조 채점)  ← 강등 사유: 커버리지 판단은 규칙 문장과의 의미 대조라 명령으로 환원 불가

---

### Task 2: git 계열 스킬 문서 정비

- [x] 완료
- **목표**: git 계열 스킬 6종의 문서에서 금지 패턴을 걷어낸다.
- **대상 파일** (10개): `git-commit/SKILL.md`, `git-pr/SKILL.md`, `git-pr/templates/pr-body-template.md`, `git-pr-feedback/SKILL.md`, `git-qa/SKILL.md`, `git-qa/templates/qa-checklist-template.md`, `git-review/SKILL.md`, `git-review/templates/review-result-template.md`, `git-review-context/SKILL.md`, `git-review-context/templates/review-context-template.md`
- **작업 내용**:
  1. Tasks 서두의 공통 절차를 대상 파일에 적용한다. 기준 시점 잔존 최다 파일은 `git-pr-feedback/SKILL.md`(em dash 78행)다.
  2. 예외로 남긴 행을 `issue-0087-exceptions.md` 표에 등재한다.
- **완료 기준**:
  - [D] 대상 파일의 greppable 잔존이 예외 목록 등재 건수와 일치한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    EX=.ai/90_issues/archive/issue-0087/issue-0087-exceptions.md
    for p in git-commit/SKILL.md git-pr/SKILL.md git-pr/templates/pr-body-template.md \
             git-pr-feedback/SKILL.md git-qa/SKILL.md git-qa/templates/qa-checklist-template.md \
             git-review/SKILL.md git-review/templates/review-result-template.md \
             git-review-context/SKILL.md git-review-context/templates/review-context-template.md; do
      for key in emdash negation; do
        if [ "$key" = emdash ]; then n=$(grep -c '—' "$p"); else n=$(grep -c '가 아니라' "$p"); fi
        [ "$n" -eq 0 ] && continue
        a=$(awk -F'|' -v p="$p" -v k="$key" \
          '{f=$2; gsub(/[[:space:]]/,"",f); t=$3; gsub(/[[:space:]]/,"",t); if (f==p && t==k) {c=$4; gsub(/[[:space:]]/,"",c); print c}}' "$EX")
        [ "$n" = "${a:-0}" ] || echo "위반: $p $key 잔존 $n행, 예외 등재 ${a:-0}행"
      done
    done
    ```

    </details>
  - [D] 대상 파일의 문서 구조(헤더·체크박스·코드 펜스·표 행 수)가 main 대비 불변이다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    git diff --name-only main -- 'git-commit/*.md' 'git-pr/*' 'git-pr-feedback/*' 'git-qa/*' 'git-review/*' 'git-review-context/*' \
      | while read -r f; do
      for pat in '^#{1,6} ' '^- \[[ x]\]' '^```' '^\|'; do
        old=$(git show "main:$f" 2>/dev/null | grep -cE "$pat")
        new=$(grep -cE "$pat" "$f")
        [ "$old" = "$new" ] || echo "위반: $f 구조 변화 ($pat: $old / $new)"
      done
    done
    ```

    </details>
  - [QD] grep으로 못 거르는 패턴 4종이 심사되었고 수정이 의미를 바꾸지 않았다  (검증: 교차모델 audit이 diff 통독 채점)  ← 강등 사유: 의미 동등성 판단은 명령으로 환원 불가

---

### Task 3: issue 계열 스킬 문서 정비

- [x] 완료
- **목표**: issue 계열 스킬 2종의 문서에서 금지 패턴을 걷어내고 workflow 사본을 동기화한다.
- **대상 파일** (7개): `issue-work/SKILL.md`, `issue-work/templates/issue-spec-template.md`, `issue-work/templates/issue-plan-template.md`, `issue-work/templates/issue-summary-template.md`, `issue-work/templates/issue-workflow-template.md`, `issue-audit/SKILL.md`, `issue-audit/templates/issue-audit-report-template.md`
- **작업 내용**:
  1. Tasks 서두의 공통 절차를 대상 파일에 적용한다. 이 그룹은 검증 스니펫·접기 제목 기본형·게이트 고정 블록 등 형식 고정 문구의 비중이 가장 높으므로, 수정보다 예외 등재가 많을 수 있다.
  2. `issue-work/templates/issue-workflow-template.md` 수정 시 `.ai/90_issues/active/issue-workflow.md` 사본에 그대로 복사한다.
  3. plan·summary 템플릿의 Task 0·N 헤더 구분자를 수정하면 이 이슈 디렉토리의 [plan](./issue-0087-plan.md)·[summary](./issue-0087-summary.md) 헤더 4행도 같은 문구로 갱신한다 (spec 전제의 Task 헤더 항목 참조).
  4. 예외로 남긴 행을 `issue-0087-exceptions.md` 표에 등재한다.
- **완료 기준**:
  - [D] 대상 파일의 greppable 잔존이 예외 목록 등재 건수와 일치한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과 (Task 2 스니펫의 대상 목록만 교체)</summary>

    ```bash
    EX=.ai/90_issues/archive/issue-0087/issue-0087-exceptions.md
    for p in issue-work/SKILL.md issue-work/templates/issue-spec-template.md \
             issue-work/templates/issue-plan-template.md issue-work/templates/issue-summary-template.md \
             issue-work/templates/issue-workflow-template.md \
             issue-audit/SKILL.md issue-audit/templates/issue-audit-report-template.md; do
      for key in emdash negation; do
        if [ "$key" = emdash ]; then n=$(grep -c '—' "$p"); else n=$(grep -c '가 아니라' "$p"); fi
        [ "$n" -eq 0 ] && continue
        a=$(awk -F'|' -v p="$p" -v k="$key" \
          '{f=$2; gsub(/[[:space:]]/,"",f); t=$3; gsub(/[[:space:]]/,"",t); if (f==p && t==k) {c=$4; gsub(/[[:space:]]/,"",c); print c}}' "$EX")
        [ "$n" = "${a:-0}" ] || echo "위반: $p $key 잔존 $n행, 예외 등재 ${a:-0}행"
      done
    done
    ```

    </details>
  - [D] 대상 파일의 문서 구조가 main 대비 불변이다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    git diff --name-only main -- 'issue-work/SKILL.md' 'issue-work/templates/*' 'issue-audit/*' \
      | grep -v '/tests/' | while read -r f; do
      for pat in '^#{1,6} ' '^- \[[ x]\]' '^```' '^\|'; do
        old=$(git show "main:$f" 2>/dev/null | grep -cE "$pat")
        new=$(grep -cE "$pat" "$f")
        [ "$old" = "$new" ] || echo "위반: $f 구조 변화 ($pat: $old / $new)"
      done
    done
    ```

    </details>
  - [D] workflow 템플릿과 `.ai` 사본이 동일하다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    diff -q issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md >/dev/null \
      || echo "위반: issue-workflow 쌍 불일치"
    ```

    </details>
  - [QD] grep으로 못 거르는 패턴 4종이 심사되었고 수정이 의미·산출물 형식을 바꾸지 않았다  (검증: 교차모델 audit이 diff 통독 채점)  ← 강등 사유: 의미 동등성·형식 보존 판단은 명령으로 환원 불가

---

### Task 4: ai-workspace 계열 정비·동기화 사본 정합

- [x] 완료
- **목표**: ai-workspace 계열 스킬 2종과 `.ai/` 동기화 사본에서 금지 패턴을 걷어낸다. 템플릿을 먼저 고치고 사본을 맞춘다.
- **대상 파일**: `ai-workspace/SKILL.md`, `ai-workspace/references/legacy-migration.md`, `ai-workspace/templates/` 하위 md 15개, `ai-workspace-directory/SKILL.md`, `ai-workspace-directory/references/` md 3개, `.ai/` 동기화 사본(동일 쌍 9종 + 상이 쌍 3종의 공통 서술부)
- **작업 내용**:
  1. Tasks 서두의 공통 절차를 템플릿 원본에 적용한 뒤, 동일 쌍 9종의 `.ai/` 사본에 그대로 복사한다 (spec DoD 3번째 항목의 쌍 목록 참조).
  2. 상이 쌍 3종(`40_domain/index.md`, `50_adr/index.md`, `70_ledger/index.md`)은 템플릿의 공통 서술부 수정을 사본에도 같은 문구로 반영하되 repo 고유 행은 보존한다.
  3. `writing-principles.md`를 수정하게 되면 SYNCED 버전 주석을 1.1.2로 올린다 (규칙 내용 변경은 범위 외이므로 문체 수정이 없으면 버전도 그대로 둔다).
  4. 예외로 남긴 행을 `issue-0087-exceptions.md` 표에 등재한다.
- **완료 기준**:
  - [D] 대상 파일의 greppable 잔존이 예외 목록 등재 건수와 일치한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    EX=.ai/90_issues/archive/issue-0087/issue-0087-exceptions.md
    { find ai-workspace ai-workspace-directory -name '*.md' -not -path '*/tests/*'; \
      find .ai/10_rules .ai/30_contract .ai/40_domain .ai/50_adr/index.md .ai/60_codebase .ai/70_ledger/index.md .ai/70_ledger/ledger-entry-template.md -name '*.md' 2>/dev/null; } \
      | sort -u | while read -r p; do
      for key in emdash negation; do
        if [ "$key" = emdash ]; then n=$(grep -c '—' "$p"); else n=$(grep -c '가 아니라' "$p"); fi
        [ "$n" -eq 0 ] && continue
        a=$(awk -F'|' -v p="$p" -v k="$key" \
          '{f=$2; gsub(/[[:space:]]/,"",f); t=$3; gsub(/[[:space:]]/,"",t); if (f==p && t==k) {c=$4; gsub(/[[:space:]]/,"",c); print c}}' "$EX")
        [ "$n" = "${a:-0}" ] || echo "위반: $p $key 잔존 $n행, 예외 등재 ${a:-0}행"
      done
    done
    ```

    - 설계 주의: `.ai/50_adr/active/`와 `.ai/70_ledger/active/`의 항목 파일은 repo 고유 문서라 Task 5 대상이다. 여기서는 index·템플릿류만 본다.
    </details>
  - [D] 동기화 동일 쌍 10종이 정합하다 (spec DoD 3번째 항목 스니펫과 동일. issue-workflow 쌍은 Task 3에서 검증하므로 여기 9종과 합쳐 10종이 된다)
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    for f in 10_rules/context-loading.md 10_rules/file-change-policy.md 10_rules/writing-principles.md \
             30_contract/index.md 40_domain/glossary.md 60_codebase/index.md 70_ledger/ledger-entry-template.md; do
      diff -q "ai-workspace/templates/shared/.ai/$f" ".ai/$f" >/dev/null || echo "위반: shared/$f 쌍 불일치"
    done
    for f in 10_rules/architecture.md 10_rules/coding-convention.md; do
      diff -q "ai-workspace/templates/dev/.ai/$f" ".ai/$f" >/dev/null || echo "위반: dev/$f 쌍 불일치"
    done
    ```

    </details>
  - [D] 대상 파일의 문서 구조가 main 대비 불변이다 (`70_ledger/` 제외)
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    git diff --name-only main -- 'ai-workspace/*' 'ai-workspace-directory/*' '.ai/10_rules/*' '.ai/30_contract/*' '.ai/40_domain/*' '.ai/50_adr/index.md' '.ai/60_codebase/*' \
      | grep -v '/tests/' | while read -r f; do
      for pat in '^#{1,6} ' '^- \[[ x]\]' '^```' '^\|'; do
        old=$(git show "main:$f" 2>/dev/null | grep -cE "$pat")
        new=$(grep -cE "$pat" "$f")
        [ "$old" = "$new" ] || echo "위반: $f 구조 변화 ($pat: $old / $new)"
      done
    done
    ```

    </details>
  - [QD] 상이 쌍 3종의 공통 서술부가 템플릿과 정합하고 repo 고유 행이 보존되었으며, 수정이 의미를 바꾸지 않았다  (검증: 교차모델 audit이 쌍별 diff 대조 채점)  ← 강등 사유: 공통 서술부와 고유 행의 경계 판정은 의미 판단이라 명령으로 환원 불가

---

### Task 5: 나머지 스킬·repo 공통 문서 정비

- [x] 완료
- **목표**: 나머지 스킬 5종과 repo 공통 문서에서 금지 패턴을 걷어낸다.
- **대상 파일**: `code-map/`, `context-harvest/`, `context-save/`, `install-skills/`, `readme-sync/`의 SKILL.md·templates·references (tests 제외), `.ai/AI-CONTEXT.md`, `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md`, `.ai/70_ledger/active/K-0001`~`K-0005`, `README.md`, `.claude/CLAUDE.md`
- **작업 내용**:
  1. Tasks 서두의 공통 절차를 대상 파일에 적용한다.
  2. 예외로 남긴 행을 `issue-0087-exceptions.md` 표에 등재한다.
- **완료 기준**:
  - [D] 대상 파일의 greppable 잔존이 예외 목록 등재 건수와 일치한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    EX=.ai/90_issues/archive/issue-0087/issue-0087-exceptions.md
    { find code-map context-harvest context-save install-skills readme-sync -name '*.md' -not -path '*/tests/*'; \
      find .ai/50_adr/active .ai/70_ledger/active -name '*.md'; \
      echo .ai/AI-CONTEXT.md; echo README.md; echo .claude/CLAUDE.md; } \
      | sort -u | while read -r p; do
      for key in emdash negation; do
        if [ "$key" = emdash ]; then n=$(grep -c '—' "$p"); else n=$(grep -c '가 아니라' "$p"); fi
        [ "$n" -eq 0 ] && continue
        a=$(awk -F'|' -v p="$p" -v k="$key" \
          '{f=$2; gsub(/[[:space:]]/,"",f); t=$3; gsub(/[[:space:]]/,"",t); if (f==p && t==k) {c=$4; gsub(/[[:space:]]/,"",c); print c}}' "$EX")
        [ "$n" = "${a:-0}" ] || echo "위반: $p $key 잔존 $n행, 예외 등재 ${a:-0}행"
      done
    done
    ```

    </details>
  - [D] 대상 파일의 문서 구조가 main 대비 불변이다 (`70_ledger/`는 spec DoD와 같은 사유로 제외)
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    git diff --name-only main -- 'code-map/*' 'context-harvest/*' 'context-save/*' 'install-skills/*' 'readme-sync/*' '.ai/AI-CONTEXT.md' '.ai/50_adr/active/*' 'README.md' '.claude/CLAUDE.md' \
      | grep -v '/tests/' | while read -r f; do
      for pat in '^#{1,6} ' '^- \[[ x]\]' '^```' '^\|'; do
        old=$(git show "main:$f" 2>/dev/null | grep -cE "$pat")
        new=$(grep -cE "$pat" "$f")
        [ "$old" = "$new" ] || echo "위반: $f 구조 변화 ($pat: $old / $new)"
      done
    done
    ```

    </details>
  - [QD] grep으로 못 거르는 패턴 4종이 심사되었고 수정이 의미를 바꾸지 않았다  (검증: 교차모델 audit이 diff 통독 채점)  ← 강등 사유: 의미 동등성 판단은 명령으로 환원 불가

---

### Task 6: 전수 재검증·원장 등재

- [x] 완료
- **목표**: 그룹 단위 검증을 전수로 재확인하고, 수용으로 남긴 파일을 원장에 등재해 DoD를 닫는다.
- **작업 내용**:
  1. spec DoD의 [D] 스니펫 4종을 전부 재실행해 통과를 확인한다.
  2. 예외 목록에서 분류가 `수용`인 파일이 있으면 `.ai/70_ledger/ledger-entry-template.md` 형식으로 `active/K-<번호>` 항목을 신설하고(수용 사유·재검토 조건 필수) `70_ledger/index.md` 항목 목록을 갱신한 뒤, 예외 목록 근거 열에 `K-<번호>`를 기입한다. 번호는 active·archive를 합쳐 최대 번호 + 1로 채번한다.
  3. 예외 목록을 최종 확정한다 (기준 시점 현황 대비 남긴 사유가 표로 완결).
- **완료 기준**:
  - [D] spec DoD [D] 항목 4종의 검증 스니펫이 전부 통과한다  (검증: 해당 스니펫 재실행, 각 출력 0건)
  - [D] 예외 목록의 `수용` 행이 전부 `K-<번호>`를 참조한다 (spec DoD 4번째 항목 스니펫과 동일)
  - [QD] 수용 등재의 수용 사유·재검토 조건이 원장 형식 요건을 충족한다  (검증: 교차모델 audit이 ledger-entry-template 필수 필드와 대조 채점)  ← 강등 사유: 사유·조건의 실질 충족은 의미 판단이라 명령으로 환원 불가

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

- [x] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **실행 주체**: **사용자가 직접** 수행한다. 구현 AI는 이 Task를 **자동으로 닫지 않으며**, `issue-audit`를 자동 실행하지도 않는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 전부 재실행해 통과를 확인한다.
  2. 구현을 수행한 모델과 **다른 벤더 모델**(최소 동급 이상 역량)로 사용자가 직접 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 사용자가 audit 결과(지적 사항·감사 모델)를 summary에 반영·기록한다. 발견사항 보정은 issue-work `--response`로 검토한다 — **피드백 먼저, 항목별 승인 후에만** 앞 Task를 보정하며, 리포트를 받자마자 자동 보정하지 않는다.
- **완료 기준**:
  - [D] spec `완료의 정의`의 `[D]` 항목 검증 명령 전부 통과  (검증: 해당 명령 재실행)
  <!-- 아래 5개 항목은 순서가 아니라 의존 관계다: 선행 조건(Task 집합 일치 → 결과 확정 → 수행 모델 채움)이 서지 않으면 교차 벤더 비교가 공집합이 되어 통과처럼 보인다. -->
  - [D] summary의 Task 헤더 집합이 plan과 일치 — 블록 전체 누락·Task N 누락·빈 summary·두 경로 오기를 차단하며, 아래 두 게이트의 선행 조건이라 블록 자체가 없으면 그 두 게이트는 검사 대상이 사라져 그대로 통과한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    P=.ai/90_issues/archive/issue-0087/issue-0087-plan.md
    S=.ai/90_issues/archive/issue-0087/issue-0087-summary.md
    { grep -qE '^### Task ' "$P" && grep -qE '^### Task ' "$S" \
      && diff <(grep -E '^### Task ' "$P") <(grep -E '^### Task ' "$S") \
      || echo '위반: 입력 접근 실패 또는 Task 집합 불일치'; }
    ```

    - 설계 주의: 프로세스 치환 안의 `grep` 실패는 `diff` 종료 상태로 전파되지 않아 두 경로가 모두 잘못되면 빈 입력끼리 비교해 통과한다 — 선행 `grep -q`로 두 파일의 Task 헤더 실재를 먼저 확인하고 실패를 stdout 위반 행으로 환원한다.
    - 의존 근거: 아래 두 게이트는 `^### Task ` 블록 안의 행만 훑는 awk라 블록 유무 자체를 판정할 수 없다 — 그 판정은 이 게이트에만 있다.
    </details>
  - [D] 이 검증 전에 Task 0 및 모든 일반 실행 Task의 summary `결과`가 완료·부분 완료·스킵 중 하나로 확정 — Task N 제외 블록마다 유효 `결과` 행 정확히 1개, 무효·중복 0건이며, 아래 `수행 모델` 게이트의 선행 조건이라 비워 두면 그 게이트의 검사 대상이 공집합이 되어 통과처럼 보인다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0이면 통과</summary>

    ```bash
    S=.ai/90_issues/archive/issue-0087/issue-0087-summary.md
    awk '
      /^### Task / { if (o && !n && v != 1) b++; o = 1; v = 0; n = ($0 ~ /^### Task N/) }
      o && /^- \*\*결과\*\*:/ {
        if ($0 ~ /^- \*\*결과\*\*: (완료|부분 완료|스킵)[[:space:]]*$/) v++
        else if (!n) b++
      }
      END { if (o && !n && v != 1) b++; print b+0 }
    ' "$S"
    ```

    - 설계 주의: 총개수 비교는 한 블록의 미확정을 다른 블록의 중복 행으로 상쇄해도 통과하므로 블록 단위로 센다.
    - 의존 근거: 아래 게이트의 "`수행 모델` 값 필수" 조건은 `결과`가 완료·부분 완료인 블록에서만 발동하도록 걸려 있다.
    </details>
  - [D] 완료·부분 완료 Task의 `수행 모델`이 비어 있지 않고 `-`도 아닌 행 정확히 1개(`-`는 미착수·스킵 전용)이며, 아래 교차 벤더 조건의 선행 조건이라 전부 `-`로 남기면 그 조건이 공집합이 되어 우회가 된다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0이면 통과</summary>

    ```bash
    S=.ai/90_issues/archive/issue-0087/issue-0087-summary.md
    awk '
      /^### Task / { if (o && !n && d && (t != 1 || m != 1)) b++; o = 1; d = 0; t = 0; m = 0; n = ($0 ~ /^### Task N/) }
      o && /^- \*\*결과\*\*: (완료|부분 완료)[[:space:]]*$/ { d = 1 }
      o && /^- \*\*수행 모델\*\*:/ { t++; if ($0 ~ /^- \*\*수행 모델\*\*: [^-[:space:]]/) m++ }
      END { if (o && !n && d && (t != 1 || m != 1)) b++; print b+0 }
    ' "$S"
    ```

    - 설계 주의: 리터럴 `-`만 거부하면 빈 값·행 누락·중복이 통과하므로 "없음"의 세 형태와 중복을 전부 실패로 센다.
    - 의존 근거: 아래 교차 벤더 조건은 비어 있지 않은 `수행 모델` 값에서만 벤더를 뽑아 대조한다.
    </details>
  - [QD] summary `모델 기록` 표의 `구현 모델`·`audit 모델` 두 행이 "벤더, 모델명" 형식으로 채워지고 서로 다른 벤더  (검증: 교차모델 audit이 두 행 대조 채점)  ← 강등 사유: 벤더 토큰 추출이 자유 문자열 의미 대조라 명령으로 환원하면 표기 변형에 취약하다
  - [QD] 구현에 여러 벤더가 관여했으면 audit 모델의 벤더가 Task 0 및 일반 실행 Task의 비어 있지 않은 모든 `수행 모델` 값에 나열된 벤더 전부와도 상이  (검증: 교차모델 audit이 `수행 모델` 행 전수 추출 후 audit 벤더와 대조 채점)  ← 강등 사유: 위와 같음. 표의 대표값 비교만으로는 audit 벤더의 구현 참여를 놓치고, 한 Task를 여러 모델이 수행했으면 그 값에 나열된 벤더를 모두 비교 대상에 넣는다
  - [ND] audit이 칭찬이 아니라 허점 탐색 방향으로 수행됨  (검증: 사용자가 audit 리포트 내용으로 판단)  ← 강등 사유: 감사 방향성은 리포트 서술의 의미 판단이라 명령으로 환원 불가
