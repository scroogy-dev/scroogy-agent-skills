# Issue #100 실행계획 issue-work·issue-audit: 요구사항 승인 게이트 신설과 계획 감사 모드(--plan)·계획 보정 도입

> 스펙: [issue-0100-spec.md](./issue-0100-spec.md)

---

## 계획 종료 게이트 (고정)

> **점검 질문**: 이 spec/plan만 보고, 작성에 참여하지 않은 쪽이 구현에 필요한 내용을 스스로 알 수 있는가?

- [x] 점검 완료
- **점검 대상** (작성 중 머릿속에만 있었던 것):
  - 코드베이스 관례 — 이 repo에서만 통하는 패턴·명명·배치 규칙
  - 버전·환경 제약 — 특정 버전·플랫폼·도구에 묶인 조건
  - 검토 후 버린 대안과 그 이유
  - 사용자와의 합의로만 정해진 값
- **발견 시 조치**: spec `## 전제 (Assumptions)` 섹션에 적는다. 발견이 없으면 그 섹션에 "없음" 한 줄을 남긴다.
- **점검 결과**: 용어 결정, 이슈 본문 `검토 필요` 3건의 결정, 발견 번호 축 분리, `--response` 러너 계약, 게이트 개명의 판정 영향, 헬퍼 배치·앵커를 spec 전제에 남겼다. `검토 필요` 2·3은 작성 AI의 제안값이라 Task 0에서 사용자 확인을 받는다.

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> **작성 원칙**: 구현자에게 이 문서 외 컨텍스트가 없다고 가정하고, Task별 완료 기준을 결정적으로 씁니다.
> 완료 기준의 검증 명령은 spec `완료의 정의`의 해당 그룹에 있으며, 여기서는 그룹을 가리키고 Task 고유 검사만 접기에 둡니다.
>
> **검증 레벨** — `[D]` L1 결정적 / `[QD]` L2 준결정적 / `[ND]` L3 비결정적. 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> **문서를 대상으로 검증할 때는 문구가 아니라 행 구조를 셉니다**. 헤더는 `^## `, Task는 `^### Task `, 필드는 `^- \*\*…\*\*:`로 앵커를 고정하고, 명령은 repo 루트 기준 경로로 적습니다.
>
> **용어**: 이 문서와 산출물은 spec 전제의 통일 용어(계획 모델·계획 audit 모델·구현 모델·최종 audit 모델·계획 종료 게이트·최종 감사)만 쓴다. 옛 표기는 spec R8의 검색 패턴이 잡는다.

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- [x] 완료
- **목표**: 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 코드 작성 전에 걷어낸다.
- **작업 내용**:
  1. spec/plan을 읽고, 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 나열한다.
  2. spec 전제의 `검토 필요` 2·3 결정(가짜 `[D]` 결정화 보류·모드 이름)을 사용자에게 확인받는다. 뒤집히면 spec 전제와 관련 Task를 고친다.
  3. 항목이 있으면 **코드를 쓰기 전에 사용자에게 질의**하고, 답변을 spec `## 전제 (Assumptions)` 섹션에 반영한 뒤 구현을 시작한다.
  4. 항목이 없으면 summary Task 0의 `수행 내용 요약`에 `전제 누락 없음` 한 줄을 기록하고 진행한다.
- **완료 기준**:
  - [ND] 나열한 항목이 전부 spec `## 전제 (Assumptions)`에 반영되어 미해소 0건이거나, summary Task 0에 `전제 누락 없음`이 기록된다  (검증: 사람 리뷰)  ← 강등 사유: 전제·모호점을 빠짐없이 나열했는지는 의미 판단이라 명령으로 환원 불가

---

### Task 1: 용어 통일 (계획 모델·최종 audit 모델·계획 종료 게이트·최종 감사)

- [x] 완료
- **목표**: 뒤 Task가 새 용어 위에서 쓰이도록 issue-work·issue-audit의 기존 표기를 먼저 통일한다.
- **대상 요구사항**: R8
- **작업 내용**:
  1. spec R8의 대응대로 `issue-work/templates` 3종을 치환한다. summary 템플릿은 `모델 기록` 표 행 이름·주석(계획 모델이 spec·plan을 쓴 모델임을 명시)과 Task N 블록 주석, plan 템플릿은 게이트 헤더·Task 0 주석·Task N `[QD]` 행 이름, workflow 템플릿은 이슈 완료 시 1단계다.
  2. `issue-work/SKILL.md`의 관련 skill·새 이슈 시작 시 4단계·작업 진행 중·이슈 완료 시·`--clear` 1단계를 같은 대응으로 치환한다.
  3. `issue-work/scripts/check-clear.sh`의 주석과 미완료 메시지 3줄, `issue-work/tests/run-tests.sh`의 fixture 헤더·케이스 이름·대조 문자열을 치환한다.
  4. `issue-audit/SKILL.md` `## 개요`에 기본 모드를 최종 감사로 부른다는 한 줄을 넣는다.
  5. 갱신한 workflow 템플릿으로 `.ai/90_issues/active/issue-workflow.md`를 덮어쓴다.
- **완료 기준**:
  - [D] spec DoD R8 `[D]` 항목 2건 통과 (옛 표기 0건·새 표기 실재)
  - [D] issue-work·issue-audit 러너가 통과한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    for t in issue-work/tests/run-tests.sh issue-audit/tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
    ```

    </details>

---

### Task 2: issue-work SKILL.md 새 이슈 시작 절차 분할과 계획 감사 질의

- [x] 완료
- **목표**: "새 이슈 시작 시"를 요구사항 승인 게이트 기준으로 나누고, 계획 종료 게이트 뒤에 계획 감사 수행 여부 질의를 넣는다.
- **대상 요구사항**: R1, R2
- **작업 내용**:
  1. `issue-work/SKILL.md` "새 이슈 시작 시" 3단계를 둘로 나눈다. 3-1은 spec 목표·요구사항(포함·제외)·연관 문서 후보까지 쓰고 승인 요청, 3-2는 승인 후 완료의 정의·plan·summary 작성이다.
  2. 승인 요청 제시 형식을 적는다. 대화에는 spec 경로와 목표 한 줄·포함 목록·제외 목록만 제시하고 전문을 출력하지 않는다(`--clear` 3단계와 같은 방식). 이슈 본문에 근거가 없는 요구사항은 따로 표시해 추가 확정·제외를 질의한다.
  3. 4단계(계획 종료 게이트) 뒤에 5단계로 계획 감사 수행 여부 질의를 넣는다. 기본값 없음, 수행 시 사용자가 계획 모델과 다른 벤더 모델로 issue-audit `--plan`을 직접 수행하고 리포트를 `--response`로 검토한 뒤 Task 0, 건너뛰면 summary `모델 기록`의 `계획 audit 모델` 행과 `계획 감사` 줄에 `생략`을 적고 Task 0으로 진행한다.
  4. `## 관련 skill`의 issue-audit 항목과 `## 작업 진행 중`에 계획 감사 연계를 한 줄씩 보강한다.
- **완료 기준**:
  - [D] spec DoD R1 `[D]` 항목 통과 (승인 게이트 앵커·서술 순서)
  - [D] spec DoD R2 `[D]` 항목 통과 (계획 종료 게이트 뒤 질의·앵커)
  - [D] "새 이슈 시작 시" 절의 번호 단계가 5개 이상이고 `issue-work/tests/run-tests.sh`가 통과한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    n="$(sed -n '/^## 새 이슈 시작 시$/,/^## 작업 진행 중$/p' issue-work/SKILL.md | grep -cE '^[0-9]+\. ')"
    [ "$n" -ge 5 ] || echo "위반: 새 이슈 시작 시 번호 단계 $n 개 (기대 5개 이상)"
    issue-work/tests/run-tests.sh >/dev/null 2>&1 || echo '위반: issue-work 러너 실패'
    ```

    </details>
  - [QD] spec DoD R1 `[QD]` 항목 (제시 형식의 동등성)  (검증: 교차모델 audit 채점)  ← 강등 사유: spec과 같음

---

### Task 3: issue-work --response 계획 리포트 탐색·spec·plan 보정

- [x] 완료
- **목표**: `--response`가 계획 감사 리포트를 찾고, 승인분만 spec·plan에 반영하며, 결과를 `계획 감사` 줄에 기록한다.
- **대상 요구사항**: R3
- **작업 내용**:
  1. `--response` 1단계 리포트 확보에 `issue-<번호>-plan-audit-report.md` 자동 탐색을 추가한다. 최종 감사 리포트와 둘 다 있으면 목록을 제시해 선택받는다.
  2. 5단계 승인분 보정에 계획 리포트 분기를 추가한다. 보정 대상이 spec·plan이면 영향 파일 목록에 그 파일을 적고 승인분만 반영하며, 발견·보정 건수는 Task 블록이 아니라 summary `모델 기록` 아래 `계획 감사` 줄에 `수행 · 발견 N건 · 보정 N건`으로 적는다.
  3. `--response` 용도 문단에 계획 감사 리포트도 대상임을 한 줄 보강한다. 새 번호 단계를 만들지 않는다(러너 스모크가 5개를 고정).
- **완료 기준**:
  - [D] spec DoD R3 `[D]` 항목 통과 (번호 단계 5개 유지·1단계 `plan-audit-report`·5단계 `spec·plan`·`계획 감사`·러너 통과)

---

### Task 4: issue-work 템플릿 반영

- [x] 완료
- **목표**: spec·summary·workflow 템플릿이 승인 게이트·계획 감사 기록을 담는다.
- **대상 요구사항**: R4
- **작업 내용**:
  1. `templates/issue-spec-template.md` 요구사항 주석에 이슈 본문 근거 표기 안내를 넣는다(근거가 없는 항목은 승인 요청에서 따로 표시된다는 점 포함). 헤더·`**포함**`·`**제외**`·R 예시 구조는 바꾸지 않는다.
  2. `templates/issue-summary-template.md` `모델 기록` 표에 `계획 audit 모델` 행을 `계획 모델` 행 다음에 추가하고(주석: 계획 모델과 다른 벤더, 생략 시 `생략`), 표 바로 아래 `- **계획 감사**: 생략` 줄을 둔다(주석: 수행 시 `수행 · 발견 N건 · 보정 N건`, 지표 4종 집계 대상 아님).
  3. `templates/issue-workflow-template.md` "작업 진행 중"에 계획 감사 리포트(`issue-<번호>-plan-audit-report.md`)도 `--response`로 Task 0 착수 전에 검토한다는 한 줄을 넣고, `.ai/90_issues/active/issue-workflow.md`를 갱신한 템플릿으로 덮어쓴다.
- **완료 기준**:
  - [D] spec DoD R4 `[D]` 항목 2건 통과 (템플릿 앵커·행 개수·러너 통과, `summarize-metrics.sh` 무위반)
  - [D] `active/issue-workflow.md`가 갱신한 템플릿과 동일하다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    diff issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md
    ```

    </details>

---

### Task 5: issue-audit 추적성 헬퍼 check-plan.sh와 테스트

- [x] 완료
- **목표**: spec·plan의 R·DoD·Task 삼자 대응 위반을 결정적으로 산출한다.
- **대상 요구사항**: R6
- **작업 내용**:
  1. `issue-audit/scripts/check-plan.sh`를 만든다(`#!/usr/bin/env bash`, 실행 권한, 머리말 주석·`usage`·종료 코드 규약은 `classify-risk.sh`와 같은 형식). 모드는 `--trace <spec> <plan>` 하나다.
  2. 판정 4종을 1행씩 출력한다. `R 없는 DoD 그룹: R<n>`, `DoD 없는 R: R<n>`, `Task 없는 R: R<n>`, `대상 요구사항 없는 일반 Task: <헤더>`. 앵커는 spec 전제 "헬퍼가 읽는 앵커"를 따른다. 위반 0건이면 무출력·종료 0, 1건 이상이면 종료 1, 파일 누락·인자 부족·모드 미지정·알 수 없는 옵션은 종료 2다.
  3. `issue-audit/tests/run-tests.sh`에 케이스를 추가한다. 정상 fixture(R1·R2, DoD R1·R2·공통, Task 0·1·2·N) 통과, 반례 4종 격추(정상 fixture의 awk 변형), 일반 Task 제목의 `고정` 단어 오분류 없음, 사용오류 3종(exit 2). 케이스 이름에 `trace: 정상`, `R 없는 DoD`, `DoD 없는 R`, `Task 없는 R`, `필드 없는 일반 Task`, `고정 단어`, `exit 2` 문구를 넣는다(spec DoD R6 명령과 아래 명령이 이 문구를 찾는다).
- **완료 기준**:
  - [D] spec DoD R6 `[D]` 항목 2건 통과 (러너 케이스·종료 코드, 이 이슈 spec·plan 자체 통과)
  - [D] 헬퍼가 고정 Task 헤더 두 가지만 필드 검사에서 제외한다 (일반 Task 제목의 `고정` 단어를 오분류하지 않는다)
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    issue-audit/tests/run-tests.sh 2>/dev/null | grep -q 'trace: .*고정 단어' || echo '위반: 러너에 고정 단어 오분류 케이스 없음'
    ```

    </details>

---

### Task 6: issue-audit --plan 모드 소절과 리포트 템플릿 주석

- [x] 완료
- **목표**: issue-audit이 구현 전 spec·plan을 GitHub 이슈 본문·`.ai` 문서 대비 감사하는 절차를 갖는다.
- **대상 요구사항**: R5
- **작업 내용**:
  1. `issue-audit/SKILL.md`에 `## 옵션` 또는 절차 뒤 `### --plan` 소절을 1개 신설한다. 내용은 입력(이슈 번호, 대상 `active/issue-<번호>/` spec·plan), 대조 기준(GitHub 이슈 본문·`30_contract`·`40_domain`·`50_adr`·`70_ledger`), 시점(plan 완료 후·Task 0 전, 사용자가 계획 모델과 다른 벤더 모델로 직접 수행, 자동 실행 금지), 1단계(이슈 본문 요구 항목 대비 spec 요구사항 대조, 판정 값 동일), 2단계 5관점(추적성은 `check-plan.sh --trace` 호출, 가짜 `[D]`는 구현 전 트리에서 명령 실행·회귀 방지 항목 예외 표시, 범위, 모호성, 과잉 설계는 `[QD]`), 공통 규칙(위험도·처리·이모지·판정·원장 대조·발견 번호 헬퍼가 최종 감사와 동일), 리포트 경로 `.ai/99_workspace/issue-<번호>-plan-audit-report.md`와 회차 보존·`--clear` 이관 동일, 발견 번호 축이 최종 감사 리포트와 분리된다는 점이다.
  2. frontmatter `description`에 계획 감사(`--plan`) 문구를 넣는다. `## 개요`·`## 관련 skill`에 모드 존재를 한 줄씩 보강한다.
  3. `templates/issue-audit-report-template.md` 1단계 요구사항 대조 표 주석에 `--plan` 모드에서는 행이 이슈 본문 요구 항목이 된다는 점을 적는다. 기존 러너의 리포트 구조 스모크가 검사하는 헤더·필드는 바꾸지 않는다.
- **완료 기준**:
  - [D] spec DoD R5 `[D]` 항목 통과 (소절 1개·앵커 전부·템플릿 주석·description)
  - [D] `issue-audit/tests/run-tests.sh`가 통과한다 (리포트 구조 스모크 포함)
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    issue-audit/tests/run-tests.sh >/dev/null 2>&1 || echo '위반: issue-audit 러너 실패'
    ```

    </details>
  - [QD] spec DoD R5 `[QD]` 항목 (최종 감사 절차와의 정합, 회귀 방지 예외 표시 서술)  (검증: 교차모델 audit 채점)  ← 강등 사유: spec과 같음

---

### Task 7: 안내도 정합

- [x] 완료
- **목표**: `.ai/AI-CONTEXT.md`가 새 헬퍼와 계획 감사 모드를 가리킨다.
- **대상 요구사항**: R7
- **작업 내용**:
  1. 디렉토리 구조의 issue-audit `scripts/` 행에 `check-plan.sh`를 추가한다.
  2. 스킬 목록의 `issue-audit` 행 설명에 계획 감사 모드(`--plan`)를 반영한다. `## 이슈 작업 워크플로우` 표의 사용 시점도 "계획·구현 검증 시"로 맞춘다.
  3. `last updated` 날짜를 갱신한다.
  4. spec 전제 "검토 필요 2"에 따라 가짜 `[D]` 사전 판별의 헬퍼 결정화 보류를 원장 `.ai/70_ledger/active/K-<번호>-<slug>.md`에 기술부채로 등재하고 `index.md` 항목 목록을 갱신한다(수용 사유·재검토 조건 필수). Task N이 전제 이행을 확인할 수 있도록 이슈 완료 전에 등재한다.
- **완료 기준**:
  - [D] spec DoD R7 `[D]` 항목 통과
  - [D] spec DoD 공통 항목 2건 통과 (전체 러너·줄 끝 공백)

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

- [x] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **실행 주체**: **사용자가 직접** 수행한다. 구현 AI는 이 Task를 **자동으로 닫지 않으며**, `issue-audit`를 자동 실행하지도 않는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 전부 재실행해 통과를 확인한다.
  2. 구현을 수행한 모델과 **다른 벤더 모델**(최소 동급 이상 역량)로 사용자가 직접 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 사용자가 audit 결과(지적 사항·감사 모델)를 summary에 반영·기록한다. 발견사항 보정은 issue-work `--response`로 검토한다. **피드백 먼저, 항목별 승인 후에만** 앞 Task를 보정하며, 리포트를 받자마자 자동 보정하지 않는다.
- **완료 기준**:
  - [D] spec `완료의 정의`의 `[D]` 항목 검증 명령 전부 통과  (검증: 해당 명령 재실행)
  <!-- 아래 5개 항목은 순서가 아니라 의존 관계다: 선행 조건(Task 집합 일치 → 결과 확정 → 수행 모델 채움)이 서지 않으면 교차 벤더 비교가 공집합이 되어 통과처럼 보인다. -->
  - [D] summary의 Task 헤더 집합이 plan과 일치한다. 블록 전체 누락·Task N 누락·빈 summary·두 경로 오기를 차단하며, 아래 두 게이트의 선행 조건이라 블록 자체가 없으면 그 두 게이트는 검사 대상이 사라져 그대로 통과한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    P=.ai/90_issues/archive/issue-0100/issue-0100-plan.md
    S=.ai/90_issues/archive/issue-0100/issue-0100-summary.md
    { grep -qE '^### Task ' "$P" && grep -qE '^### Task ' "$S" \
      && diff <(grep -E '^### Task ' "$P") <(grep -E '^### Task ' "$S") \
      || echo '위반: 입력 접근 실패 또는 Task 집합 불일치'; }
    ```

    - 설계 주의: 프로세스 치환 안의 `grep` 실패는 `diff` 종료 상태로 전파되지 않아 두 경로가 모두 잘못되면 빈 입력끼리 비교해 통과한다. 선행 `grep -q`로 두 파일의 Task 헤더 실재를 먼저 확인하고 실패를 stdout 위반 행으로 환원한다.
    - 의존 근거: 아래 두 게이트는 `^### Task ` 블록 안의 행만 훑는 awk라 블록 유무 자체를 판정할 수 없다. 그 판정은 이 게이트에만 있다.
    </details>
  - [D] 이 검증 전에 Task 0 및 모든 일반 실행 Task의 summary `결과`가 완료·부분 완료·스킵 중 하나로 확정된다. Task N 제외 블록마다 유효 `결과` 행 정확히 1개, 무효·중복 0건이며, 아래 `수행 모델` 게이트의 선행 조건이라 비워 두면 그 게이트의 검사 대상이 공집합이 되어 통과처럼 보인다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0이면 통과</summary>

    ```bash
    S=.ai/90_issues/archive/issue-0100/issue-0100-summary.md
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
    S=.ai/90_issues/archive/issue-0100/issue-0100-summary.md
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
  - [QD] summary `모델 기록` 표의 `구현 모델`·`최종 audit 모델` 두 행이 "벤더, 모델명" 형식으로 채워지고 서로 다른 벤더  (검증: 교차모델 audit이 두 행 대조 채점)  ← 강등 사유: 벤더 토큰 추출이 자유 문자열 의미 대조라 명령으로 환원하면 표기 변형에 취약하다
  - [QD] 구현에 여러 벤더가 관여했으면 최종 audit 모델의 벤더가 Task 0 및 일반 실행 Task의 비어 있지 않은 모든 `수행 모델` 값에 나열된 벤더 전부와도 상이  (검증: 교차모델 audit이 `수행 모델` 행 전수 추출 후 audit 벤더와 대조 채점)  ← 강등 사유: 위와 같음. 표의 대표값 비교만으로는 audit 벤더의 구현 참여를 놓치고, 한 Task를 여러 모델이 수행했으면 그 값에 나열된 벤더를 모두 비교 대상에 넣는다
  - [ND] audit이 칭찬이 아니라 허점 탐색 방향으로 수행됨  (검증: 사용자가 audit 리포트 내용으로 판단)  ← 강등 사유: 감사 방향성은 리포트 서술의 의미 판단이라 명령으로 환원 불가
