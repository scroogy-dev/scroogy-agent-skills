# Issue #122 실행계획 ai-workspace: 테스트 원칙 파일 쌍(testing-principles·local) 도입과 안내도·context-loading 라우팅 연결

> 스펙: [issue-0122-spec.md](./issue-0122-spec.md)

---

## 계획 종료 게이트 (고정)

<!--
이 블록은 모든 이슈 계획에 고정한다. 삭제하지 말 것.
plan 작성을 끝내기 직전에 수행하는 자기점검이며, 실행 Task가 아니라 "plan 작성 절차"라 Tasks 앞에 둔다.
문서를 쓴 주체와 읽는 주체가 다를 수 있다는 것만 전제한다 — 다른 모델이든, 세션 교체 후의 같은 모델이든 같다.
-->

> **점검 질문**: 이 spec/plan만 보고, 작성에 참여하지 않은 쪽이 구현에 필요한 내용을 스스로 알 수 있는가?

- [x] 점검 완료
- **점검 대상** (작성 중 머릿속에만 있었던 것):
  - 코드베이스 관례 — 이 repo에서만 통하는 패턴·명명·배치 규칙
  - 버전·환경 제약 — 특정 버전·플랫폼·도구에 묶인 조건
  - 검토 후 버린 대안과 그 이유
  - 사용자와의 합의로만 정해진 값
- **발견 시 조치**: spec `## 전제 (Assumptions)` 섹션에 적는다. 발견이 없으면 그 섹션에 "없음" 한 줄을 남긴다.

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> **작성 원칙**: 구현자에게 이 문서 외 컨텍스트가 없다고 가정하고, Task별 완료 기준을 결정적으로 씁니다.
> 각 작업은 독립적으로 검증 가능해야 하며, 완료 기준은 **항목별 리스트로 쪼개 레벨 태그 + 검증 수단**을 적습니다.
> 명령으로 환원이 어려운 항목만 판정 주체(다른 AI / 사람)를 적고 강등 사유를 남깁니다.
>
> **대상 요구사항 필드** — 일반 Task에는 `- **대상 요구사항**: R<n>` 필드를 `목표` 다음 행에 두어
> 이 Task가 spec의 어느 요구사항을 구현하는지 밝힙니다. 여러 개면 `R<n>, R<m>`로 나열합니다.
> 고정 Task(Task 0·Task N)는 특정 요구사항에 속하지 않으므로 이 필드를 두지 않습니다.
>
> **완료 기준 형식** — 본문(접기 금지)에는 레벨 태그 + 무엇이 보장되는지 한 문장(+ 강등 사유)만 두고,
> 검증 명령·테스트케이스·기대 출력·명령 설계 주의점은 접기로 내립니다. 접기 제목에 기대 출력을 함께 적습니다
> (기본형: "검증 명령 — 출력 0건이면 통과"). 접을 상세가 없는 항목은 접기 없이 본문 한 줄로 둡니다.
> 다른 게이트의 선행 조건이 되는 항목은 의존 관계와 **선행 조건이 무너졌을 때의 결과**를 본문 문장에 남기고, 메커니즘만 접기에 둡니다.
> 첫 고정 Task(Task 0 구현 시작 게이트)와 마지막 고정 Task(교차모델 issue-audit)는 삭제하지 말고 그대로 둡니다.
>
> **테스트 배치** — 구현 테스트(단위·회귀)는 그 기능을 만드는 Task 안에 둡니다. 테스트 작성(fixture·기대 출력)을
> `작업 내용`의 단계로 넣고 테스트 파일을 그 Task의 산출물로 삼으며, `완료 기준`에는 "이 Task의 테스트 0 실패" `[D]`를 둡니다.
> 별도 테스트 Task는 fixture 일괄 갱신처럼 테스트 자체가 작업 대상일 때만 둡니다.
> 전체 테스트 통과는 spec `### 공통`의 회귀 방지 항목으로 유지합니다.
>
> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> **문서를 대상으로 검증할 때는 문구가 아니라 행 구조를 셉니다**. 같은 문구가 주석·안내문에도 등장하므로
> `grep -c '<문구>'`는 실제 구조가 없어도 통과합니다. 헤더는 `^## `, Task는 `^### Task `,
> 필드는 `^- \*\*…\*\*:`로 앵커를 고정하고, 명령은 작업 디렉토리에 의존하지 않게 repo 루트 기준 경로로 적습니다.
> **검증 명령 보정은 반례 격추가 아니라 불변식 전수 명세로 합니다**. 지적된 변형 하나만 막으면 이웃 변형이
> 다음 감사에서 재발하므로, 기대 구조를 열거하고 "그 외 0건"까지 판정에 넣습니다.

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

<!--
이 블록은 모든 이슈 계획의 첫 Task로 고정한다. 삭제하지 말 것.
계획 종료 게이트가 "쓰는 쪽"의 자기점검이라면, 이 게이트는 "읽는 쪽"이 착수 전에 거는 확인이다.
spec을 쓴 주체와 구현하는 주체가 같아도 수행한다 — 세션이 바뀌면 전제는 똑같이 유실된다.
-->

- [x] 완료
- **목표**: 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 코드 작성 전에 걷어낸다.
- **작업 내용**:
  1. spec/plan을 읽고, 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 나열한다.
  2. 항목이 있으면 **코드를 쓰기 전에 사용자에게 질의**하고, 답변을 spec `## 전제 (Assumptions)` 섹션에 반영한 뒤 구현을 시작한다.
  3. 항목이 없으면 summary Task 0의 `수행 내용 요약`에 `전제 누락 없음` 한 줄을 기록하고 진행한다.
- **완료 기준**:
  - [ND] 나열한 항목이 전부 spec `## 전제 (Assumptions)`에 반영되어 미해소 0건이거나, summary Task 0에 `전제 누락 없음`이 기록된다  (검증: 사람 리뷰)  ← 강등 사유: 전제·모호점을 빠짐없이 나열했는지는 의미 판단이라 명령으로 환원 불가

---

### Task 1: 테스트 원칙 파일 쌍 템플릿과 init·update 배포

- [x] 완료
- **목표**: dev 프로파일 repo가 init·update로 `testing-principles.md`(버전 고정)와 `testing-principles-local.md`(사용자 관리)를 받는다.
- **대상 요구사항**: R1, R2, R9
- **작업 내용**:
  1. `ai-workspace/templates/dev/.ai/10_rules/testing-principles.md`를 쓴다. 1행 SYNCED 헤더·2행 `<!-- 버전: 1.0.0 -->`(형식은 spec 전제 "원칙 제목 고정"), H1 제목, 우선순위 안내(local 우선, 무엇을 어느 문서에서 검증할지는 각 스킬 규칙이 정하고 이 파일은 실행 층·수단·환경을 정한다), `## 공통 원칙` 아래 이슈 본문 A의 9개 원칙을 `###` 제목과 본문으로 둔다. `writing-principles.md` 한국어 작성 규칙을 따른다(em dash 삽입구 금지 등).
  2. `ai-workspace/templates/dev/.ai/10_rules/testing-principles-local.md`를 쓴다. 상단 blockquote는 `writing-principles-local.md`와 같은 형식(사용자 관리, update는 없을 때만 복사, 충돌 시 local 우선)이다. 섹션 4개와 두 표 헤더는 spec R2 DoD 문구 그대로 두고, 값 행은 비우며 예시는 HTML 주석으로 든다(이슈 본문 "사용 중인 테스트 수단" 예). `## 기기 확인 (모바일 앱 repo만)`은 선택 섹션 표시, 요청 시 절차 자리, 되돌릴 항목 목록 자리를 두고 기기 이름은 적지 않는다.
  3. `ai-workspace/SKILL.md`를 고친다. init-1단계 "프로파일별 전용 파일 예시" dev 줄과 그 아래 복사 정책 목록에 두 파일을 더하고, update-1단계 "사용자가 작성한 파일" 목록에 `testing-principles-local.md`를 더하며, 코드 블록의 dev 분기에 `testing-principles.md` 무조건 `cp`와 local 없을 때만 `cp`를 넣는다(주석으로 버전 고정·사용자 관리 구분).
  4. 이 repo `.ai/10_rules/`에 두 템플릿 파일을 그대로 복사한다(R9).
  5. `ai-workspace/tests/run-tests.sh`에 테스트를 더한다. 기존 "update-1 문서 규약 복사" 절과 같은 방식으로 update-1 코드 블록을 임시 디렉토리에서 실행해 dev 신규 복사·dev 버전 고정 덮어쓰기·dev local 보존·doc 미복사를 한 통과 케이스로 보고, 격추 케이스 3종(dev 분기의 `testing-principles.md` `cp` 삭제, local 보존 조건 삭제, `testing-principles.md` `cp`에 없을 때만 조건 추가)을 둔다. 케이스 설명은 `테스트 원칙 update-1`로 시작하고 끝 낱말을 `통과`·`격추` 중 하나로 한다.
- **완료 기준**:
  - [D] spec R1·R2의 `[D]` 항목 4개가 통과한다  (검증: spec 접기 명령 실행, 각 출력 0건)
  - [D] spec R9 항목 중 파일 쌍 사본 일치가 성립한다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    for f in testing-principles.md testing-principles-local.md; do
      cmp -s "ai-workspace/templates/dev/.ai/10_rules/$f" ".ai/10_rules/$f" || echo "위반: $f 사본 불일치"
    done
    ```

    </details>
  - [D] 이 Task의 테스트가 새 케이스를 포함해 0 실패로 통과한다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    R=ai-workspace/tests/run-tests.sh
    out=$("$R" 2>&1) \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 테스트 원칙 update-1.* 통과$')" -ge 1 ] \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 테스트 원칙 update-1.* 격추$')" -ge 3 ] \
      || echo '위반: 테스트 실패 또는 테스트 원칙 update-1 케이스(통과 1·격추 3 이상) 미실행'
    ```

    - 설계 주의: 러너만 실행하면 케이스를 넣기 전에도 통과해 가짜 `[D]`가 된다. 통과·격추 낱말을 따로 세어 정상 통과와 반례 격추를 함께 요구한다.
    </details>
  - [QD] 9개 원칙 본문과 local 골격이 이슈 본문 A와 맞고 한국어 작성 규칙을 지킨다  (검증: 교차모델 audit 채점)  ← 강등 사유: 서술 충실도와 문체는 의미 판단이다

---

### Task 2: context-loading 테스트 라우팅

- [x] 완료
- **목표**: 테스트를 작성·실행하는 에이전트가 context-loading에서 두 파일로 안내받는다.
- **대상 요구사항**: R3, R9
- **작업 내용**:
  1. `ai-workspace/templates/shared/.ai/10_rules/context-loading.md`의 `## 외부 API·계약 변경 시` 섹션 다음에 `## 테스트 작성·실행 시` 섹션을 넣는다. 항목은 `writing-principles` 섹션과 같은 형식으로 두 줄이다(공통 원칙, repo 고유 층 표·대상 환경과 local 우선).
  2. 이 repo `.ai/10_rules/context-loading.md`를 템플릿으로 덮어쓴다(R9, 버전 고정 파일).
  3. `ai-workspace/tests/run-tests.sh`의 `ctx_violations`에 `테스트 라우팅` 위반(섹션 1개·항목 2개)을 더하고, 통과 케이스 설명을 `context-loading 제약 문장·테스트 라우팅·저장소 사본 일치 통과`로 바꾸며, 격추 케이스 `context-loading 테스트 라우팅 삭제 격추`를 더한다.
- **완료 기준**:
  - [D] spec R3 `[D]` 항목이 통과한다  (검증: spec 접기 명령 실행, 출력 0건)
  - [D] 이 Task의 테스트가 새 케이스를 포함해 0 실패로 통과한다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    R=ai-workspace/tests/run-tests.sh
    out=$("$R" 2>&1) \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*테스트 라우팅.* 통과$')" -ge 1 ] \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*테스트 라우팅.* 격추$')" -ge 1 ] \
      || echo '위반: 테스트 실패 또는 테스트 라우팅 케이스(통과·격추 각 1 이상) 미실행'
    ```

    </details>

---

### Task 3: 안내도 규칙 표 행과 멱등 보강 검사

- [x] 완료
- **목표**: dev 안내도에 `testing-principles.md` 행이 있고, update가 dev 표준 선언 repo에만 그 행을 전파한다.
- **대상 요구사항**: R4, R9
- **작업 내용**:
  1. `ai-workspace/templates/dev/.ai/AI-CONTEXT.md` `## 프로젝트 규칙` 표의 `file-change-policy.md` 행과 `writing-principles.md` 행 사이에 `| \`.ai/10_rules/testing-principles.md\` | 테스트 실행 원칙 (층·수단·환경) | 테스트 작성·실행 시 |`를 넣는다(파일명 알파벳순). doc 템플릿은 고치지 않는다.
  2. `ai-workspace/SKILL.md` update-4를 고친다.
     - 멱등 보강 검사 표의 `writing-principles.md` 행 다음에 `| \`## 프로젝트 규칙\` 표의 \`testing-principles.md\` 행 |` 항목을 넣는다. 검사 열은 "본문 두 번째 줄이 dev 표준 문구일 때만" 조건과 행 인정 기준(`context-loading.md` 행과 같음), doc 문구·비표준 문구면 검사하지 않음을 적고, 조치 열은 표 끝에 dev 템플릿 행과 같은 표준 행 삽입을 적는다.
     - SSoT 선언 행 조치에 "같은 실행에서 dev 문구를 삽입·교체했으면 `testing-principles.md` 행이 없을 때 함께 넣는다"를 더한다(spec 전제 "같은 실행의 dev 문구 보강").
     - `## 프로젝트 규칙` 섹션 행의 "아래 두 행 검사"·"표준 2행" 표현을 세 행 검사에 맞게 고치고, "헬퍼는 표의 11개 항목 중 9개" 문장을 12개 중 10개로 고친다.
  3. `ai-workspace/scripts/check-context.sh`에서 `rules_ok`일 때 `line2`가 `SSOT_LINE_DEV`와 같으면 `.ai/10_rules/testing-principles.md` 행을 기존 행 검사와 같은 awk로 검사한다. 머리 주석의 "검사 표 11행 중 9행"을 12행 중 10행으로 고친다.
  4. `ai-workspace/tests/run-tests.sh`에 케이스를 더한다. 설명에 `testing-principles 행`을 넣고 끝 낱말은 `통과`·`격추` 중 하나로 한다.
     - 격추: dev 템플릿에서 행 삭제, 경로가 확장 열에만 있음
     - 통과: 행을 지운 안내도의 선언을 doc 표준 문구로 바꾸면 무보고, 비표준 문구로 바꾸면 이 행 무보고
     - 검사 표 행 수 기대값을 12로, 설명의 헬퍼 판정 수를 10종으로 바꾸고, 머리 주석의 "`## 프로젝트 규칙` 3개 항목"을 4개로 고친다.
  5. `ai-workspace/tests/fixtures/update4-idempotent/`를 고친다. dev 케이스 4종의 `expected.md`에 이 행을 조치 규칙대로 넣고(`no-rules-section`·`no-rules-table`은 dev 템플릿 표와 같게, `legacy-two-col`·`missing-rows`는 표 끝에), `missing-rows-doc`의 input·expected 2번째 줄을 doc 표준 문구로 바꾼다. README의 항목 수(3개 → 4개)와 케이스 표의 표준 행 수(dev 3개, doc 2개)를 고친다.
  6. 이 repo `.ai/AI-CONTEXT.md` `## 프로젝트 규칙` 표의 `file-change-policy.md` 행과 `writing-principles.md` 행 사이에 같은 행을 넣는다(R9).
- **완료 기준**:
  - [D] spec R4의 `[D]` 항목 4개가 통과한다  (검증: spec 접기 명령 실행, 각 출력 0건)
  - [D] spec R9 `[D]` 항목이 통과한다  (검증: spec 접기 명령 실행, 출력 0건)
  - [D] 이 Task의 테스트가 새 케이스를 포함해 0 실패로 통과한다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    R=ai-workspace/tests/run-tests.sh
    out=$("$R" 2>&1) \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*testing-principles 행.* 통과$')" -ge 2 ] \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*testing-principles 행.* 격추$')" -ge 2 ] \
      && printf '%s\n' "$out" | grep -qE '^ok +- SKILL\.md 멱등 보강 검사 표: 12행' \
      || echo '위반: 테스트 실패 또는 testing-principles 행 케이스(통과 2·격추 2 이상)·검사 표 12행 미확인'
    ```

    </details>
  - [QD] update-4 모의 실행이 fixture README 절차(2회 실행 멱등 포함)로 기대 결과와 일치한다  (검증: 다른 AI가 fixture README 절차로 채점, 별도 세션)  ← 강등 사유: 조치(삽입)는 내용 생성이 섞인 AI 절차라 헬퍼가 판정하지 않는다

---

### Task 4: issue-work 조건부 참조

- [x] 완료
- **목표**: issue-work가 plan을 쓸 때 repo의 테스트 층 표를 따른다.
- **대상 요구사항**: R5
- **작업 내용**:
  1. `issue-work/SKILL.md` `## 참조 문서`의 `writing-principles` 항목 다음에 `  - \`.ai/10_rules/testing-principles.md\`·\`.ai/10_rules/testing-principles-local.md\` — `로 시작하는 항목을 넣는다. 있으면 테스트 실행 원칙으로 참조하고, 충돌 시 local 우선, 없으면 현재 템플릿·절차가 기본값이라고 적는다.
  2. "새 이슈 시작 시" 3-2 항목 아래에 하위 항목을 넣는다. local 파일이 있으면 plan Task 테스트 `[D]`의 러너 호출·출력 판독·실행 셸은 층 표를 따르고, spec DoD `[D]`의 인수 테스트 층은 층 표에서 고르며, "기기 확인 Task는 두지 않는다"(실기기 확인은 사용자가 요청할 때만)를 적는다.
  3. `issue-work/templates/issue-plan-template.md` `## Tasks` 머리말의 `**테스트 배치**` 문단 끝에(빈 `>` 줄 앞) local 파일이 있으면 러너 호출·출력 판독·실행 셸은 그 층 표를 따른다는 줄을 붙인다.
  4. `issue-work/tests/run-tests.sh`에 조항 구조 검사를 더한다(spec 전제 "소비 스킬 문장 테스트"). 검사 함수는 앵커 문구를 범위 안에서 찾아 빠진 앵커를 1행씩 출력하고, 반례는 issue-audit 러너의 `drop_literal`처럼 문구를 정규식 해석 없이 지운 사본으로 만들어 기존 `assert_structure`로 판정한다. 케이스 설명은 `테스트 원칙 조항:`으로 시작하고 끝 낱말을 `통과`·`격추` 중 하나로 한다.
     - SKILL.md 앵커: `## 참조 문서`의 두 파일 항목 1개(spec R5 첫 항목의 정규식과 같다), 3-2 범위의 `testing-principles-local.md`와 `기기 확인 Task는 두지 않는다`
     - plan 템플릿 앵커: `**테스트 배치**` 문단 안의 `testing-principles-local.md`
     - 통과 케이스 2개(실제 SKILL.md, 실제 plan 템플릿), 격추 케이스 4개(참조 항목 삭제, 3-2 local 참조 삭제, 기기 확인 문장 삭제, 테스트 배치 문단 local 참조 삭제)
- **완료 기준**:
  - [D] spec R5 `[D]` 항목이 통과한다  (검증: spec 접기 명령 실행, 출력 0건)
  - [D] issue-work 테스트가 새 조항 검사를 포함해 0 실패로 통과한다(테스트 배치 머리말 문단 검사 포함)
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    out=$(issue-work/tests/run-tests.sh 2>&1) \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 테스트 원칙 조항: .* 통과 \(위반 0건\)$')" -ge 2 ] \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 테스트 원칙 조항: .* 격추 \(위반 검출\)$')" -ge 4 ] \
      && printf '%s\n' "$out" | grep -qE '^ok +- .*테스트 배치: 머리말 문단 통과' \
      || echo '위반: issue-work 테스트 실패 또는 테스트 원칙 조항 케이스(통과 2·격추 4 이상)·머리말 문단 검사 미실행'
    ```

    - 설계 주의: 러너만 실행하면 케이스를 넣기 전에도 통과해 가짜 `[D]`가 된다. `assert_structure`의 통과(`위반 0건`)·격추(`위반 검출`) 행을 따로 센다.
    - 설계 주의: 문단 안에 붙인 줄이 빈 `>` 줄 뒤로 밀리면 별도 문단이 되어 spec R5 검사가 실패한다. 머리말 문단 검사는 기존 문구 유지를 본다.
    </details>

---

### Task 5: issue-audit 조건부 참조

- [x] 완료
- **목표**: issue-audit이 `[D]` 명령을 repo가 정한 셸·전제 조건으로 실행하고, 전제가 없으면 판정 불가로 둔다.
- **대상 요구사항**: R6
- **작업 내용**:
  1. `issue-audit/SKILL.md` `## 참조 문서`에 Task 4 1번과 같은 형식의 항목을 넣는다.
  2. 0단계에 7항을 넣는다. 두 파일이 있으면 읽고, 1단계 `[D]` 재실행과 `--plan` 관점 2의 실행 셸·전제 조건 기준으로 쓴다.
  3. 1단계 `#### 검증 항목` 2번(`2. **완료의 정의(DoD) 대조**`) 줄 끝에, local 파일이 있으면 그 파일의 실행 셸·전제 조건으로 실행하고 전제 조건이 갖춰지지 않으면 판정 불가(N/A)로 두고 사유를 적는다는 문장을 덧붙인다.
  4. `--plan` 관점 2(`2. **가짜 \`[D]\` 사전 판별**`) 줄에 같은 문장을 덧붙이고, `--plan` 대조 기준의 0단계 항목 수행 목록(현재 "3·4항은 그대로 수행")에 7항을 넣어 `3·4·7항은 그대로 수행`이 되게 한다. 3·4번 문장에는 `전제 조건이 갖춰지지 않으면 판정 불가(N/A)` 구절을 그대로 쓴다(5번 검사의 앵커).
  5. `issue-audit/tests/run-tests.sh`에 조항 검사 함수를 새로 더한다(spec 전제 "소비 스킬 문장 테스트"). 기존 `check_dod_run_clause`·`check_fake_d_clause`는 고치지 않고, 같은 방식으로 앵커를 행 단위로 판정하며 반례는 `drop_literal` 사본을 `assert_clause`로 판정한다. 케이스 설명은 `테스트 원칙 조항:`으로 시작하고 끝 낱말을 `통과`·`격추` 중 하나로 한다.
     - 앵커: `## 참조 문서`의 두 파일 항목 1개, 0단계 7항의 `testing-principles-local.md`, DoD 대조 행과 관점 2 행 각각의 `testing-principles-local.md`와 `전제 조건이 갖춰지지 않으면 판정 불가(N/A)`, `--plan` 대조 기준의 `3·4·7항은 그대로 수행`
     - 기존 DoD 대조 행에는 "명령을 실행할 수 없는 환경이면 판정 불가(N/A)" 구절이 이미 있어 `판정 불가(N/A)`만 앵커로 쓰면 새 문장을 지워도 통과한다. 앵커는 위 구절 전체로 둔다.
     - 통과 케이스 1개(실제 SKILL.md), 격추 케이스 5개 이상(참조 항목 삭제, 0단계 7항 삭제, DoD 대조 행 새 구절 삭제, 관점 2 행 새 구절 삭제, `--plan` 수행 목록의 7항 삭제)
- **완료 기준**:
  - [D] spec R6 `[D]` 항목이 통과한다  (검증: spec 접기 명령 실행, 출력 0건)
  - [D] issue-audit 테스트가 새 조항 검사를 포함해 0 실패로 통과한다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    out=$(issue-audit/tests/run-tests.sh 2>&1) \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 테스트 원칙 조항: .* 통과 \(위반 0건\)$')" -ge 1 ] \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 테스트 원칙 조항: .* 격추 \(위반 검출\)$')" -ge 5 ] \
      || echo '위반: issue-audit 테스트 실패 또는 테스트 원칙 조항 케이스(통과 1·격추 5 이상) 미실행'
    ```

    - 설계 주의: 러너만 실행하면 케이스를 넣기 전에도 통과해 가짜 `[D]`가 된다. `assert_clause`의 통과(`위반 0건`)·격추(`위반 검출`) 행을 따로 센다.
    </details>

---

### Task 6: git-qa 자동 테스트 표시

- [x] 완료
- **목표**: git-qa가 자동 테스트가 덮는 항목을 수동 확인 항목과 구분해 반복 확인을 줄인다.
- **대상 요구사항**: R7
- **작업 내용**:
  1. `git-qa/SKILL.md` `## 참조 문서`에 Task 4 1번과 같은 형식의 항목을 넣는다.
  2. 4단계에 규칙 문단을 넣는다. PR이 속한 repo의 base 브랜치 `.ai/10_rules/testing-principles-local.md`를 `gh api`로 읽어(저장소·호스트 명시) 층 표를 확인하고, 층 표의 자동 테스트가 덮는 항목은 체크박스를 유지한 채 끝에 `— 자동 테스트로 덮음(<러너>)`을 붙여 수동 확인 항목과 구분하며, 같은 동작을 수동으로 반복 확인하는 항목을 따로 만들지 않는다. 파일을 읽지 못하면 표시 없이 지금 방식으로 쓴다. 덮음 판정 기준(테스트를 찾은 항목만)과 증빙 문구 대체는 spec 전제 "git-qa 덮음 판정·표시 형식"을 따른다.
  3. `git-qa/templates/qa-checklist-template.md` Issue #5 체크리스트에 `- [ ] ... — 자동 테스트로 덮음(<러너 예>)` 형식의 예시 한 줄을 넣는다.
  4. `git-qa/tests/run-tests.sh`를 새로 만들고 실행 권한을 준다(spec 전제 "소비 스킬 문장 테스트"). code-map 러너처럼 헬퍼 없이 조항만 검사하며, 머리 주석에 검사 범위(4단계 자동 테스트 표시 조항, #122)를 적는다. `ok`/`NOT OK` 행 형식, 통과(`위반 0건`)·격추(`위반 검출`) 판정 함수, 종료 코드(모두 통과 0, 실패 1)는 issue-audit 러너의 `assert_clause`와 같게 둔다. 케이스 설명은 `테스트 원칙 조항:`으로 시작하고 끝 낱말을 `통과`·`격추` 중 하나로 한다.
     - SKILL.md 앵커: `## 참조 문서`의 두 파일 항목 1개(spec R7 첫 항목의 정규식과 같다), 4단계 범위의 `testing-principles-local.md`·`자동 테스트로 덮음(`·`읽지 못하면 표시 없이`(2번 폴백 문장에 이 구절을 그대로 쓴다)·`테스트를 찾지 못하면 표시하지 않고`(덮음 판정 기준 문장, spec 전제 "git-qa 덮음 판정·표시 형식")
     - 템플릿 앵커: 체크리스트 행(`^- \[ \] `)의 `자동 테스트로 덮음(` 예시
     - 통과 케이스 2개(실제 SKILL.md, 실제 템플릿), 격추 케이스 6개(참조 항목 삭제, 4단계 local 참조 삭제, 표시 규칙 삭제, 읽기 실패 폴백 삭제, 덮음 판정 기준 삭제, 템플릿 예시 삭제)
  5. `.ai/AI-CONTEXT.md` 디렉토리 구조 트리의 `git-qa/` 아래에 `tests/` 줄(4단계 자동 테스트 표시 조항 구조 검사, 배포 제외)을 더한다. `templates/` 줄의 가지 기호는 `├──`로 바꾼다.
- **완료 기준**:
  - [D] spec R7 `[D]` 항목이 통과한다  (검증: spec 접기 명령 실행, 출력 0건)
  - [D] git-qa 테스트가 새 조항 검사를 포함해 0 실패로 통과한다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    out=$(git-qa/tests/run-tests.sh 2>&1) \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 테스트 원칙 조항: .* 통과 \(위반 0건\)$')" -ge 2 ] \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 테스트 원칙 조항: .* 격추 \(위반 검출\)$')" -ge 6 ] \
      || echo '위반: git-qa 테스트 실패 또는 테스트 원칙 조항 케이스(통과 2·격추 6 이상) 미실행'
    ```

    - 설계 주의: 러너 파일이 없거나 실행 권한이 없으면 `out=$(...)`가 실패해 위반 행이 나온다. spec `### 공통`의 전체 테스트(`*/tests/run-tests.sh`)도 이 러너를 자동으로 포함한다.
    </details>
  - [D] AI-CONTEXT 디렉토리 구조 트리의 `git-qa/` 아래에 `tests/` 줄이 있다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    awk '/^├── git-qa\// { f = 1; next } f && !/^│ / { exit } f' .ai/AI-CONTEXT.md | grep -qE '^│   └── tests/ ' \
      || echo '위반: AI-CONTEXT 트리 git-qa tests 줄'
    ```

    </details>

---

### Task 7: SSoT 선언 폴백 알림 (K-0015 함께 해소)

- [x] 완료
- **목표**: 안내도는 있는데 표준 선언을 찾지 못한 repo에서 스킬이 소스 코드로 진행하면서 그 사실을 알린다.
- **대상 요구사항**: R10
- **작업 내용**:
  1. 선언 읽기 표준 문장이 있는 8곳(`ai-workspace/templates/shared/.ai/10_rules/context-loading.md`, `code-map`·`context-harvest`·`issue-audit`·`git-pr`·`git-review`·`git-review-context`·`git-review-quiz`의 `SKILL.md`)에서 "선언을 찾지 못하면 소스 코드를 SSoT로 본다(봅니다)." 바로 뒤에 알림 문장을 넣는다. 앵커는 spec 전제 "알림 문장 고정" 그대로이고, 사용자에게 한 줄로 알리며 `ai-workspace` update로 선언을 보강할 수 있다고 안내한다. 어미는 파일 문체를 따른다.
  2. 이 repo `.ai/10_rules/context-loading.md`를 템플릿으로 다시 덮어쓴다(R3 사본 일치 유지).
  3. `.ai/40_domain/policies/local/ssot-and-router-principle.md` 11행의 폴백 문장 뒤에 같은 알림 규칙(안내도가 없는 repo는 알리지 않음 포함)을 적는다.
  4. ADR 0020을 일부 변경한다. `## 결정`에 알림을 더하고, `## 대안`의 "선언이 깨졌을 때 경고를 더하는 안" 줄을 #122에서 채택했다는 내용으로 고치며, `## 근거`에 변경 날짜(2026-10-26)·#122·경위(K-0015 함께 해소)를 적는다. K-0015 링크 경로는 바꾸지 않는다(종결 시점은 spec 전제 "K-0015 종결 시점").
  5. `code-map/tests/run-tests.sh`·`context-harvest/tests/run-tests.sh`의 SKILL.md 구조 검사에 알림 문장 확인을 더하고, 알림 문장을 지우는 격추 케이스를 각각 둔다. 설명은 `알림`을 넣고 `격추`로 끝낸다.
- **완료 기준**:
  - [D] spec R10의 `[D]` 항목 3개가 통과한다  (검증: spec 접기 명령 실행, 각 출력 0건)
  - [D] spec R3 `[D]` 항목이 계속 통과한다(템플릿과 이 repo 사본 일치)  (검증: spec 접기 명령 실행, 출력 0건)
  - [D] 알림 문장을 넣은 스킬의 테스트가 0 실패로 통과한다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    for t in ai-workspace code-map context-harvest git-pr git-review git-review-quiz issue-audit; do
      "$t/tests/run-tests.sh" >/dev/null 2>&1 || echo "위반: $t 테스트 실패"
    done
    ```

    - 설계 주의: git-review-context는 테스트 러너가 없다. 알림 격추 케이스 실행 여부는 spec R10 세 번째 항목이 센다.
    </details>

---

### Task 8: 결정 기록과 색인

- [x] 완료
- **목표**: 이번 결정과 변경이 ADR·명세·색인에 남는다.
- **대상 요구사항**: R8
- **작업 내용**:
  1. `.ai/50_adr/active/0023-<slug>.md`를 ADR 0022와 같은 형식(frontmatter `source: github_issue`·#122 URL·`last_harvested: 2026-10-26`, `- **상태**: 유효`, 결정·근거·대안·원본 출처)으로 쓴다. 결정은 ADR 0008 쌍 구조의 테스트 원칙 확장(dev 전용, 버전 고정·사용자 관리, context-loading 라우팅, dev 표준 선언 한정 행 검사)과 소비 스킬 3종의 조건부 직접 참조다. 대안은 이슈 본문의 검토한 대안을 옮긴다.
  2. `.ai/50_adr/index.md` 파일 목록에 0023 행을 0022 행 다음에 넣는다.
  3. `.ai/60_codebase/index.md` ai-workspace 행의 관련 문서에 ADR 0023 링크를 넣고, ADR 요약 목록에 0023 줄을 넣는다.
  4. `.ai/40_domain/specs/ai-workspace.md`를 고친다. update 복사 정책 문장에 dev 전용 `testing-principles.md`(버전 고정)·`testing-principles-local.md`(사용자 관리)를 넣고, 멱등 보강 검사 문장을 `check-context.sh` 10종과 dev 표준 선언 한정 `testing-principles.md` 행으로 고치며, 관련 결정에 ADR 0023을 넣는다.
  5. `.ai/60_codebase/ai-workspace/init-call-flow.md`·`update-call-flow.md`의 복사 줄·판정 수(9항목 → 10항목)·명세 요약·결정 링크에 이번 변경을 반영한다.
- **완료 기준**:
  - [D] spec R8 `[D]` 항목이 통과한다  (검증: spec 접기 명령 실행, 출력 0건)
  - [D] 끊긴 원장 링크가 0건이다 (회귀 방지)
    <details>
    <summary>검증 명령 — 무출력·종료 코드 0이면 통과</summary>

    ```bash
    issue-work/scripts/check-ledger-links.sh .ai
    ```

    </details>
  - [QD] ADR 0023과 명세·색인 서술이 구현과 맞는다  (검증: 교차모델 audit 채점)  ← 강등 사유: 결정 서술의 충실도는 의미 대조다

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

<!--
이 블록은 모든 이슈 계획의 마지막 Task로 고정한다. 삭제하지 말 것.
audit은 L2 [QD] 보완 검증 — L1 [D] 결정적 게이트의 대체가 아니라 보완이다.
이 Task는 사용자가 직접 수행하며, 구현 AI는 자동으로 닫지 않는다.
이 블록의 완료 기준은 계획 감사의 가짜 [D] 사전 판별 대상이 아니다(issue-audit `--plan` 관점 2 예외).
-->

- [ ] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **실행 주체**: **사용자가 직접** 수행한다. 구현 AI는 이 Task를 **자동으로 닫지 않으며**, `issue-audit`를 자동 실행하지도 않는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 전부 재실행해 통과를 확인한다.
  2. 구현을 수행한 모델과 **다른 벤더 모델**(최소 동급 이상 역량)로 사용자가 직접 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 사용자가 audit 결과(지적 사항·감사 모델·감사 effort)를 summary에 반영·기록한다. 발견사항 보정은 issue-work `--response`로 검토한다. **피드백 먼저, 항목별 승인 후에만** 앞 Task를 보정하며, 리포트를 받자마자 자동 보정하지 않는다.
- **완료 기준**:
  - [D] spec `완료의 정의`의 `[D]` 항목 검증 명령 전부 통과  (검증: 해당 명령 재실행)
  <!-- 아래 5개 항목은 순서가 아니라 의존 관계다: 선행 조건(Task 집합 일치 → 결과 확정 → 수행 모델 채움)이 서지 않으면 교차 벤더 비교가 공집합이 되어 통과처럼 보인다. -->
  - [D] summary의 Task 헤더 집합이 plan과 일치한다. 블록 전체 누락·Task N 누락·빈 summary·두 경로 오기를 차단하며, 아래 두 게이트의 선행 조건이라 블록 자체가 없으면 그 두 게이트는 검사 대상이 사라져 그대로 통과한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    P=.ai/90_issues/active/issue-0122/issue-0122-plan.md
    S=.ai/90_issues/active/issue-0122/issue-0122-summary.md
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
    S=.ai/90_issues/active/issue-0122/issue-0122-summary.md
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
    S=.ai/90_issues/active/issue-0122/issue-0122-summary.md
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
  - [QD] summary `모델 기록` 표의 `구현 모델`·`최종 audit 모델` 두 행이 "벤더, 모델명 (모델 ID)" 형식으로 채워지고 서로 다른 벤더  (검증: 교차모델 audit이 두 행 대조 채점)  ← 강등 사유: 벤더 토큰 추출이 자유 문자열 의미 대조라 명령으로 환원하면 표기 변형에 취약하다
  - [QD] 구현에 여러 벤더가 관여했으면 최종 audit 모델의 벤더가 Task 0 및 일반 실행 Task의 비어 있지 않은 모든 `수행 모델` 값에 나열된 벤더 전부와도 상이  (검증: 교차모델 audit이 `수행 모델` 행 전수 추출 후 audit 벤더와 대조 채점)  ← 강등 사유: 위와 같음. 표의 대표값 비교만으로는 audit 벤더의 구현 참여를 놓치고, 한 Task를 여러 모델이 수행했으면 그 값에 나열된 벤더를 모두 비교 대상에 넣는다
  - [ND] audit이 칭찬이 아니라 허점 탐색 방향으로 수행됨  (검증: 사용자가 audit 리포트 내용으로 판단)  ← 강등 사유: 감사 방향성은 리포트 서술의 의미 판단이라 명령으로 환원 불가
