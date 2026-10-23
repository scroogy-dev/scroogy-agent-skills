# Issue #114 실행계획 doc 프로파일에서 SSoT를 원본 문서(repo 지정 디렉토리)로 선언하고 스킬이 그 선언을 따르게 한다

> 스펙: [issue-0114-spec.md](./issue-0114-spec.md)

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

> 이 이슈의 Task 완료 기준에서 `spec R<n> [D]`는 [issue-0114-spec.md](./issue-0114-spec.md) `## 완료의 정의`의 해당 그룹 `[D]` 항목 검증 명령을 그대로 실행한다는 뜻이다. 명령을 plan에 다시 적지 않는다(이중 기재 방지).

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

### Task 1: ai-workspace SSoT 선언 프로파일화 (doc 템플릿·check-context.sh·검사 표·테스트)

- [x] 완료
- **목표**: doc 프로파일 안내도가 doc 선언·doc 우선순위·`ssot_dir`·`publish` 행을 갖고, update 검사가 dev·doc 두 표준 문구를 모두 인정하며 doc 선언이면 `ssot_dir` 행을 검사한다.
- **대상 요구사항**: R2, R3
- **작업 내용**:
  1. `ai-workspace/templates/doc/.ai/AI-CONTEXT.md` 4행을 `> SSoT: 원본 문서. 이 파일은 안내도일 뿐 진실의 원천이 아니다.`로, 94행 우선순위를 `원본 문서 > 이 repo 안내도 > 상위 워크스페이스 안내도`로 바꾼다. `## 프로젝트 도메인` 표의 `keywords` 행 뒤에 `| ssot_dir | <SSoT 문서 디렉토리. repo 루트 기준 상대 경로, 콤마 나열 가능. 예: docs/> |`와 `| publish | <선택. 퍼블리싱 위치(위키·블로그 등) URL 콤마 나열. 쓰지 않으면 이 행을 지운다> |` 두 행을 추가하고, 섹션 주석에 `ssot_dir`은 필수(SSoT 선언이 원본 문서인 repo의 색인 루트), `publish`는 선택(context-harvest가 이 아래 자료를 출처에서 제외)이라고 적는다. dev 템플릿은 건드리지 않는다.
  2. `ai-workspace/scripts/check-context.sh`의 `SSOT_LINE` 단일 상수를 `SSOT_LINE_DEV`·`SSOT_LINE_DOC` 두 상수로 나누고, 본문 두 번째 줄이 둘 중 하나와 정확히 같을 때만 통과시킨다. 누락 메시지(`본문 두 번째 줄 SSoT 선언 — 실제 [...]`)는 유지한다. `## 프로젝트 도메인` 표 행 검사의 키 목록(`domain keywords`)에 두 번째 줄이 `SSOT_LINE_DOC`와 같을 때만 `ssot_dir`를 더해, 같은 awk·같은 메시지 형식(`'## 프로젝트 도메인' 표의 \`ssot_dir\` 행`)으로 보고한다. dev 선언이거나 선언이 비표준이면 `ssot_dir`를 검사하지 않는다. 머리 주석의 "10행 중 8행"은 유지하고, 사용법 설명에 doc 선언 분기 한 줄을 더한다.
  3. `ai-workspace/SKILL.md` 멱등 보강 검사 표에서 `본문 두 번째 줄 SSoT 선언` 행의 검사를 "dev·doc 두 표준 문구 중 하나 존재?"로, 조치를 "선택한 프로파일의 표준 문구를 삽입·교체. doc 문구를 삽입·교체했으면 `## 프로젝트 도메인` 표에 `ssot_dir` 행이 없을 때 템플릿과 같은 자리표시자 행도 함께 넣는다(헬퍼를 한 번만 실행하므로 이 실행에서는 `ssot_dir` 검사가 돌지 않는다)"로 고친다(spec 전제 "update의 doc 선언 처리"). `` `## 프로젝트 도메인` 섹션 `` 행의 검사에 "doc 선언이면 `ssot_dir` 행 존재?"를, 조치에 "doc 프로파일이면 골격에 `ssot_dir`(필수)·`publish`(선택) 행을 포함하고, `ssot_dir` 행만 누락이면 표 끝에 템플릿과 같은 자리표시자 행을 삽입한 뒤 사용자 입력을 요청"을 더한다. 표는 10행을 유지한다. 13행 `### 설계 원칙`의 "SSoT는 소스 코드" 문장을 "SSoT는 `AI-CONTEXT.md` 본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)의 `> SSoT: <값>.` 선언이 정한다 (dev: 소스 코드, doc: 원본 문서 = `ssot_dir` 아래 문서 파일)"로 바꾸고, 122행 init 보고 안내에 "doc 프로파일은 `ssot_dir` 행도 채워주세요"를 더한다.
  4. `ai-workspace/tests/run-tests.sh`에 변형 3종과 케이스 3건을 추가한다. `m_doc_noroot`(2번째 줄을 doc 문구로 교체)·`m_doc_root`(`m_doc_noroot` 뒤 `keywords` 행 다음에 `| ssot_dir | docs/ |` 삽입)·`m_near_with_root`(`m_doc_root` 뒤 2번째 줄을 `> SSoT: 원본 문서.`로 교체). 케이스는 `assert_missing 'SSoT 선언 doc ssot_dir 행 없음 격추' 'ssot_dir` 행' m_doc_noroot`, `assert_pass 'SSoT 선언 doc 문구 통과' m_doc_root`, `assert_missing 'SSoT 선언 doc 유사 문구 격추' '본문 두 번째 줄 SSoT' m_near_with_root`다. 기존 `본문 두 번째 줄 SSoT` 격추 케이스(`m_ssot`)와 템플릿 2종 통과 루프는 그대로 둔다(doc 템플릿의 `ssot_dir` 행이 검사 대상임은 그 루프가 증명한다).
- **완료 기준**:
  - [D] spec R2 [D] 1건 통과 (doc init 2번째 줄·우선순위 행·`ssot_dir`·`publish` 행)
  - [D] spec R3 [D] 3건 통과 (헬퍼 통과 3종·격추 4종, 러너의 doc 케이스 3건 실행, 검사 표 2행·10행 유지)
  - [D] 이 Task의 테스트가 새 케이스 3건을 포함해 0 실패로 통과한다  (검증: spec R3 두 번째 `[D]` 명령과 동일)
  - [D] 검사 표의 SSoT 선언 행 조치가 doc 문구를 넣은 실행의 `ssot_dir` 행 동시 보강을 적는다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    [ "$(grep -E '^\| 본문 두 번째 줄 SSoT 선언 \|' ai-workspace/SKILL.md | grep -c 'ssot_dir')" -eq 1 ] || echo '위반: 검사 표 SSoT 행에 ssot_dir 동시 보강 없음'
    ```

    </details>

---

### Task 2: shared 템플릿의 선언 참조·원본 문서 작업 절·SSoT 색인 정의

- [x] 완료
- **목표**: 버전 고정 파일과 shared 색인 골격, doc 안내도 설명이 프로파일과 무관하게 SSoT 선언을 따르고 `60_codebase/`를 SSoT 색인으로 정의한다.
- **대상 요구사항**: R4, R5
- **작업 내용**:
  1. `ai-workspace/templates/shared/.ai/10_rules/context-loading.md` 43행의 "**SSoT는 소스코드.**" 문장을 "**SSoT는 `AI-CONTEXT.md` 본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)의 `> SSoT: <값>.` 선언을 따른다.** 값은 `소스 코드` 또는 `원본 문서`이며 그 외 값은 선언으로 보지 않는다. 선언을 찾지 못하면 소스 코드를 SSoT로 본다. 색인(`60_codebase/`)은 오래되었을 수 있으므로 보조 자료로 활용하고 SSoT를 직접 확인한다."로 바꾼다.
  2. 같은 파일에 `## 원본 문서 작업 시` 절을 `## 코드 수정·리뷰·분석 시` 뒤에 추가한다. 절 머리에 "SSoT 선언이 원본 문서인 repo에서"라는 적용 조건을 적고, 내용은 (1) `.ai/60_codebase/index.md`로 대상 문서 파일을 찾고 (2) 색인 행의 관련 문서 링크를 따라 `40_domain/`·`50_adr/` 문서를 읽은 뒤 (3) `AI-CONTEXT.md` `## 프로젝트 도메인` 표의 `ssot_dir` 아래 파일을 직접 읽어 확인하는 3단계다.
  3. 이 repo의 `.ai/10_rules/context-loading.md`를 템플릿과 같은 내용으로 덮어쓴다(버전 고정 파일, update가 덮어쓰는 것과 같은 결과).
  4. `ai-workspace/templates/shared/.ai/60_codebase/index.md` 3~4행을 "SSoT 색인" 정의로 바꾼다. 선언이 소스코드이면 엔트리포인트·호출 흐름, 원본 문서이면 `ssot_dir` 아래 문서 파일 지도를 보관하며, AI는 이 파일을 먼저 읽고 관련 SSoT(소스코드 또는 원본 문서)를 직접 읽는다.
  5. `ai-workspace/templates/doc/.ai/AI-CONTEXT.md`의 `60_codebase` 언급 3곳(76행 트리 설명, 93행 진입 절차의 `(코드 진입점)`, 98행 작성 규칙의 `코드 상세는`)을 원본 문서 색인 기준으로 바꾼다. dev 템플릿은 건드리지 않는다.
  6. `ai-workspace/SKILL.md` 20행 code-map 소개를 "SSoT 색인 — 소스코드 기능별 엔트리포인트·호출 흐름 또는 원본 문서 파일 지도 (`.ai/60_codebase/` 활용)"로 바꾼다.
  7. `ai-workspace/tests/run-tests.sh`를 실행해 doc 템플릿이 여전히 `check-context.sh`를 통과하는지 확인한다(새 케이스 없음. 기능 변경이 아닌 설명 변경이라 Task별 테스트를 두지 않는다).
- **완료 기준**:
  - [D] spec R4 [D] 1건 통과 (구 문구 0건, 원본 문서 작업 절·참조·`ssot_dir`, 이 repo 사본 동일)
  - [D] spec R5 [D] 1건 통과 (shared index 3행, doc 템플릿 60_codebase 행 3곳, ai-workspace 소개 행; context-harvest 관계표 행은 Task 3 이후 통과)
  - [D] `ai-workspace/tests/run-tests.sh`가 0 실패로 통과한다 (회귀 확인)
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    ai-workspace/tests/run-tests.sh >/dev/null 2>&1 || echo '위반: ai-workspace 테스트 실패'
    ```

    </details>

---

### Task 3: context-harvest 수집 필터의 선언 의존·퍼블리싱 제외와 40_domain 템플릿 근거 출처 섹션

- [ ] 완료
- **목표**: context-harvest가 SSoT 선언을 따라 "SSoT에 대응하지 않는 정보"를 거르고, 퍼블리싱 사본을 출처에서 제외하며, 40_domain 문서가 근거 출처를 담을 수 있다.
- **대상 요구사항**: R5, R6, R7, R8
- **작업 내용**:
  1. `context-harvest/SKILL.md` `### SSoT 원칙 유지` 절을 다섯 항목으로 다시 쓴다. (1) SSoT는 `AI-CONTEXT.md` 본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)의 `> SSoT: <값>.` 선언을 따른다. 값은 `소스 코드` 또는 `원본 문서`(`## 프로젝트 도메인` 표 `ssot_dir` 아래 문서 파일)이며 그 외 값은 선언으로 보지 않는다. 선언을 찾지 못하면 소스 코드를 SSoT로 본다. (2) 수집하는 정보는 **SSoT에 반영된 사실의 계약/명세(What)와 배경/근거(Why)**다. (3) 산출물은 `.ai/` 내부 문서이며 외부 URL은 "원본 출처" 섹션에만 기재한다. (4) SSoT에 대응하지 않는 정보(기각된 제안, 미구현 요청 등)는 수집하지 않는다. (5) 퍼블리싱 사본(SSoT에서 파생해 위키·블로그·PDF 등으로 내보낸 사본)은 출처가 아니므로 수집하지 않는다. `## 프로젝트 도메인` 표 `publish` 행 아래 자료는 제외하고, 선언이 없거나 URL이 없는 매체는 "SSoT 내용을 내보낸 사본은 출처로 인용하지 않고 repo 문서를 링크한다"로 판단한다. 판정 기준은 매체가 아니라 유래다. 개요·description의 "소스코드 바깥" 문구는 바꾸지 않는다(dev 기준 설명으로 참이며 범위 최소화).
  2. 같은 파일 `### code-map과의 관계` 표의 `code-map` 행 설명을 "SSoT 색인(소스코드 How 또는 원본 문서 파일 지도)"으로 고친다.
  3. 같은 파일 `### 4단계: 증류 및 분류`에 doc 분기를 한 줄 추가한다. 선언이 원본 문서이면 40_domain 문서의 `근거 출처`(출처·조항·시행일·확인일) 섹션을 채운다.
  4. 같은 파일 `## 수집 제외 대상` 표에 행을 추가한다. 대상 "퍼블리싱 사본(SSoT를 내보낸 위키·블로그 페이지 등)", 사유 "SSoT의 사본이라 출처가 아니다. repo 문서를 링크한다. `publish` 선언 아래 자료는 결정적으로 제외한다".
  5. `context-harvest/templates/40_domain-template.md`에 `## 근거 출처` 섹션을 `## 원본 출처` 앞에 추가한다. 선택 섹션이며 주석으로 "SSoT 선언이 원본 문서인 repo에서 문서가 근거로 삼는 외부 자료(법령·표준 등)를 적는다. 소스 코드가 SSoT인 repo에서는 삭제한다"를 적고, 출처·조항·시행일·확인일 4열 표를 둔다. `## 원본 반영` 섹션은 두지 않는다. frontmatter 1~5행은 바꾸지 않는다.
- **완료 기준**:
  - [D] spec R6 [D] 1건 통과 (구 문구·구 필터 0건, 원본 문서 분기, 일반화 필터)
  - [D] spec R7 [D] 1건 통과 (SSoT 원칙 절의 퍼블리싱·`publish`·규칙 문장, 수집 제외 대상 행)
  - [D] spec R8 [D] 1건 통과 (frontmatter 동일, 근거 출처 섹션 1개·필드, 원본 반영 0개)
  - [D] spec R5 [D]의 context-harvest 관계표 행 조건 통과
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    [ "$(grep -E '^\| `code-map` \|' context-harvest/SKILL.md | grep -c 'SSoT 색인')" -eq 1 ] || echo '위반: context-harvest 관계표 code-map 행'
    ```

    </details>
  - [QD] 선언이 원본 문서인 repo에서 `ssot_dir` 문서에 반영된 사실의 근거를 수집하고 퍼블리싱 사본을 거르는 절차가 소스 코드 분기와 섞이지 않고 읽힌다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 분기 서술의 명확성은 의미 판단이라 명령으로 환원 불가

---

### Task 4: code-map 원본 문서 색인 절차 (`references/doc.md` 신설)

- [ ] 완료
- **목표**: code-map이 SSoT 선언이 원본 문서이면 별도 참조 파일의 절차로 `ssot_dir` 아래 문서 파일 지도를 build·sync·check한다.
- **대상 요구사항**: R9
- **작업 내용**:
  1. `code-map/references/doc.md`를 신설한다. `local.md`와 같은 골격(트리거 조건 → 파일 구조 → 실행 절차 0~4단계 → 결과 보고)으로 쓰되 내용은 원본 문서 기준이다.
     - 트리거 조건: `--local`이고 `AI-CONTEXT.md` 본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)의 `> SSoT: <값>.` 선언이 원본 문서일 때.
     - 파일 구조: `60_codebase/index.md` 하나다. 상세 흐름 파일은 두지 않는다. frontmatter는 `last_synced`·`source_hash`·`ssot_dir`·`status` 4키다.
     - 0단계 모드 결정: `index.md` 내용 유무로 build / sync·check·rebuild 선택(local과 동일). sync·check를 고르면 진입 시 안내도 `## 프로젝트 도메인` 표의 `ssot_dir`과 frontmatter `ssot_dir`을 대조한다. 다르면 sync는 rebuild로 전환하고(Why 태깅 보존, 전환 사실을 사용자에게 알린다), check는 3단계의 루트 불일치 판정으로 넘긴다. 선언만 바뀐 커밋은 `source_hash` 기준 diff에 안내도만 잡혀 새 루트의 기존 문서와 범위 밖 행을 놓치기 때문이다 (계획 감사 F-2).
     - 1단계 원본 문서 색인: 1-1 스캔 범위 — build/rebuild는 `AI-CONTEXT.md` `## 프로젝트 도메인` 표의 `ssot_dir` 전체이며, 행이 없으면 사용자에게 묻고 답을 frontmatter `ssot_dir`에 기록한 뒤 안내도 표에도 채우라고 안내한다. sync는 루트가 같을 때만 수행하며 `git diff <source_hash>..HEAD --name-only` 중 `ssot_dir` 아래 파일만이다. frontmatter `ssot_dir`·`source_hash`는 색인 반영을 마친 뒤에만 갱신한다. 1-2 단위 식별 — 문서 파일 1개가 색인 행 1개이고 하위 디렉토리는 행을 묶는 절 제목이며, sync에서 삭제된 파일은 행을 제거한다. 1-3 index.md 작성 — 표는 파일 경로·다루는 주제·관련 문서 3열이고, `다루는 주제`는 문서 H1·머리 요약·헤더에서 뽑으며, 근거 없이 규칙·결정만 적힌 문서는 `[WHY-NEEDED]`로 표시한다.
     - 2단계 교차 참조 연결: `local.md` 2단계의 표·규칙(존재하는 문서만 링크, `[DOC-NEEDED]`, 외부 URL은 교차 참조 대상 아님)을 그대로 복제한다(ADR 0002 의도적 중복). 퍼블리싱 URL도 색인에 두지 않는다.
     - 3단계 정합성 점검: 루트 불일치(안내도 `ssot_dir`과 frontmatter `ssot_dir`이 다르면 색인 전체를 `[UPDATE-NEEDED]`로 보고하고 rebuild 권고), stale 탐지(`source_hash` 이후 `ssot_dir` 변경 파일이 미반영 → `[UPDATE-NEEDED]`), 파일 유효성(없으면 행 제거), 교차참조 유효성, `[WHY-NEEDED]`·`[DOC-NEEDED]` 목록.
     - 4단계 결과 보고: `local.md` 4단계 형식에 "문서 색인 N건 (신규 N / 갱신 N / 삭제 N)"으로 맞춘다.
  2. `code-map/SKILL.md`를 고친다. (a) frontmatter `description`과 `## 개요`에 원본 문서 색인을 추가한다. (b) `### SSoT 원칙`을 선언 참조로 바꾼다. SSoT는 `AI-CONTEXT.md` 본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)의 `> SSoT: <값>.` 선언을 따른다. 값은 `소스 코드` 또는 `원본 문서`이며 그 외 값은 선언으로 보지 않는다. 선언을 찾지 못하면 소스 코드를 SSoT로 본다. `60_codebase/`는 SSoT에서 파생된 2차 산출물이며 불일치 시 SSoT가 우선한다. (c) `## 참조 문서`의 분리 참조 파일 목록과 `## 모드별 실행 절차` 표에 `references/doc.md` 행을 추가하고, `--local`이 선언에 따라 `local.md`(소스 코드) 또는 `doc.md`(원본 문서)를 읽는다고 적는다. (d) `## 적용 대상`에 "원본 문서 저장소 (SSoT 선언이 원본 문서인 doc 프로파일 repo. `ssot_dir` 아래 문서 파일)"를 추가한다. (e) `## 문서 메타데이터`에 doc 색인은 `ssot_dir` 키를 더해 쓴다는 주석을 더한다.
  3. `references/local.md`·`references/global.md`는 바꾸지 않는다.
- **완료 기준**:
  - [D] spec R9 [D] 1건 통과 (doc.md 존재·필수 어휘·루트 불일치 어휘·외부 원본 어휘 0건·단계 수, SKILL.md 적용 대상·참조 2곳·구 문구 0건, local.md·global.md 무변경)
  - [QD] `doc.md`의 build·sync·check 절차가 `local.md`를 읽지 않은 구현자도 따라 할 수 있을 만큼 자기완결적이다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 절차 완결성은 의미 판단이라 명령으로 환원 불가

---

### Task 5: 색인 맥락 문구 5곳 교체와 폴백 문구 전수 확인

- [ ] 완료
- **목표**: "SSoT는 소스코드" 문구가 5개 파일(색인 맥락 5곳 + git-pr 294행)에서 사라지고, 선언을 읽는 8개 파일 모두가 같은 선언 읽기 표준 문장(허용 값·폴백 포함)을 갖는다.
- **대상 요구사항**: R1, R10
- **작업 내용**:
  1. 아래 5곳의 문장을 바꾼다. 각 파일의 종결 어미(한다/합니다)는 유지한다.
     - `issue-audit/SKILL.md` 70행: "단, SSoT는 소스코드이므로 색인을 신뢰하지 않고 반드시 실제 코드를 확인한다." → "단, 색인을 신뢰하지 않고 SSoT를 직접 확인한다. SSoT는 `AI-CONTEXT.md` 본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)의 `> SSoT: <값>.` 선언을 따른다. 값은 `소스 코드` 또는 `원본 문서`이며 그 외 값은 선언으로 보지 않는다. 선언을 찾지 못하면 소스 코드를 SSoT로 본다."
     - `git-review/SKILL.md` 84행, `git-review-context/SKILL.md` 52행: 같은 문장.
     - `git-review-quiz/SKILL.md` 28행, `git-pr/SKILL.md` 262행: 같은 뜻을 합니다체로. 28행은 괄호 안 목록 설명이라 문장 배치를 그 맥락에 맞춘다.
  2. `git-pr/SKILL.md` 294행의 괄호 근거 `(SSoT는 소스코드)`를 `` (SSoT는 `AI-CONTEXT.md` 선언을 따릅니다) ``로 바꾼다 (2026-10-23 Task 0 결정, 이슈 본문 근거 없음).
  3. 폴백 문구 어간 `선언을 찾지 못하면 소스 코드를 SSoT로 보`와 허용 값 문장 어간 `그 외 값은 선언으로 보지 않`이 8개 파일(위 5곳 + context-harvest·code-map `SKILL.md` + shared `context-loading.md`)에 모두 있는지 확인한다. Task 2~4에서 빠진 곳이 있으면 이 Task에서 보완한다.
- **완료 기준**:
  - [D] spec R10 [D] 1건 통과 (5개 파일 구 문구 0건·폴백 문구)
  - [D] spec R1 [D] 1건 통과 (8개 파일 폴백 문구)
  - [D] 8개 파일 모두에 허용 값 문장이 있다 (spec 전제 "선언 읽기 표준 문장")
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    for f in context-harvest/SKILL.md code-map/SKILL.md issue-audit/SKILL.md git-review/SKILL.md \
             git-review-context/SKILL.md git-review-quiz/SKILL.md git-pr/SKILL.md \
             ai-workspace/templates/shared/.ai/10_rules/context-loading.md; do
      [ "$(grep -c '그 외 값은 선언으로 보지 않' "$f")" -ge 1 ] || echo "위반: $f 허용 값 문장 없음"
    done
    ```

    - 설계 주의: 어미가 파일마다 다르므로(`않는다`/`않습니다`) 어간까지만 대조한다. 허용 값 두 개(`소스 코드`·`원본 문서`)를 함께 적었는지는 spec R1 [QD]가 채점한다.
    </details>

---

### Task 6: 정책·명세·색인·안내도·README 문서 정합

- [ ] 완료
- **목표**: 이 repo의 정책·명세·색인·안내도·README가 바뀐 절차(선언 위치·값·폴백·우선순위·`ssot_dir`·`publish`·퍼블리싱 판정·SSoT 색인)를 기록한다.
- **대상 요구사항**: R11
- **작업 내용**:
  1. `.ai/40_domain/policies/local/ssot-and-router-principle.md` `## 원칙`을 고친다. 첫 항목을 "SSoT는 repo 안내도 본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)의 `> SSoT: <값>.` 선언이 정한다. dev 프로파일은 소스 코드, doc 프로파일은 원본 문서(`## 프로젝트 도메인` 표 `ssot_dir` 아래 문서 파일)다. 선언을 찾지 못하면 소스 코드를 SSoT로 본다. 마크다운은 SSoT를 가리키는 지도이지 사본이 아니다"로 바꾼다. 그 아래에 용어 항목 두 개를 더한다. "퍼블리싱은 SSoT에서 파생해 밖으로 내보낸 사본(위키·블로그·PDF 등 형태 불문)이며 SSoT도 출처도 아니다. `publish` 행으로 위치를 선언할 수 있다"와 "출처는 SSoT에서 파생되지 않은 외부 자료이며 `40_domain/`·`50_adr/`가 근거로 인용한다. 판정 기준은 매체가 아니라 유래다". 우선순위를 "SSoT(소스 코드 또는 원본 문서) > repo 안내도 > 로비 안내도"로, `60_codebase/index.md` 포인터 설명을 "SSoT 색인"으로, 마지막 항목(수집·색인 스킬 산출물 제약)을 "선언이 가리키는 SSoT에 반영된 사실의 계약·근거만 담고, 퍼블리싱 사본은 수집하지 않으며, 외부 URL은 원본 출처 섹션에만 둔다"로 바꾼다. 근거 접기에 #114의 이유(스킬마다 고정한 "SSoT = 소스 코드"가 doc repo에서 작동하지 않음, 위키를 SSoT로 두면 PR diff·감사가 원본을 보지 못해 repo 안 문서 파일을 SSoT로 정함)를 한 항목 더하고, 원본 출처에 이슈 #114 링크를 추가한다. 근거 출처 > 원본 문서 우선순위는 repo 규칙 파일 영역이라 스킬 표준에 넣지 않는다는 한 줄도 적는다.
  2. `.ai/40_domain/specs/ai-workspace.md`를 갱신한다. doc 프로파일 선언 문구·`ssot_dir`(필수)·`publish`(선택) 행, `check-context.sh`의 두 문구 인정과 doc 선언 시 `ssot_dir` 검사, `60_codebase/` SSoT 색인 정의.
  3. `.ai/60_codebase/index.md`의 code-map 행 설명(참조 파일 목록에 `doc.md`)과 context-harvest 행 설명(퍼블리싱 제외), `.ai/60_codebase/ai-workspace/update-call-flow.md`의 `check-context.sh` 설명(두 문구 인정, doc 선언 시 `ssot_dir` 행 검사, doc 문구를 넣은 실행의 `ssot_dir` 동시 보강), `.ai/60_codebase/ai-workspace/init-call-flow.md` 25행(init-2 보고의 doc `ssot_dir` 입력 안내)·30행(설계 원칙의 SSoT 문구를 선언 기준으로)을 대조해 반영하고, index frontmatter `last_synced`·`source_hash`를 갱신한다.
  4. `.ai/AI-CONTEXT.md` `## 스킬 목록`의 `code-map` 설명과 `README.md` 15행 code-map 설명에 원본 문서 색인을 더한다. `.ai/AI-CONTEXT.md` `## 디렉토리 구조`의 code-map `references/` 행(70행 `모드별(local/global) 실행 절차`)에 원본 문서 절차(`doc.md`)를 더한다. `.ai/AI-CONTEXT.md` 2번째 줄은 dev 문구를 유지한다.
- **완료 기준**:
  - [D] spec R11 [D] 1건 통과 (고정 문구 0건, 선언·원본 문서·SSoT 색인·퍼블리싱·`ssot_dir` 언급, #114 출처)
  - [D] 명세·색인·안내도·README가 새 어휘를 담는다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    [ "$(grep -c 'ssot_dir' .ai/40_domain/specs/ai-workspace.md)" -ge 1 ] || echo '위반: specs/ai-workspace.md'
    [ "$(grep -c 'doc.md' .ai/60_codebase/index.md)" -ge 1 ] || echo '위반: 60_codebase/index.md code-map 행'
    [ "$(grep -c 'ssot_dir' .ai/60_codebase/ai-workspace/update-call-flow.md)" -ge 1 ] || echo '위반: update-call-flow.md'
    [ "$(grep -c 'SSoT는 소스 코드' .ai/60_codebase/ai-workspace/init-call-flow.md)" -eq 0 ] || echo '위반: init-call-flow.md 구 SSoT 문구 잔존'
    [ "$(grep -c 'ssot_dir' .ai/60_codebase/ai-workspace/init-call-flow.md)" -ge 1 ] || echo '위반: init-call-flow.md init 보고의 ssot_dir 안내 없음'
    [ "$(grep -E '^\| `code-map` \|' .ai/AI-CONTEXT.md | grep -c '원본 문서')" -eq 1 ] || echo '위반: AI-CONTEXT 스킬 목록 code-map 행'
    [ "$(grep -A1 '^├── code-map/' .ai/AI-CONTEXT.md | grep -c 'doc')" -ge 1 ] || echo '위반: AI-CONTEXT 디렉토리 구조 code-map references 행'
    [ "$(grep -E '^\| \[code-map\]' README.md | grep -c '원본 문서')" -eq 1 ] || echo '위반: README code-map 행'
    ```

    - 설계 주의: 디렉토리 구조에는 `references/` 행이 스킬마다 있으므로 `├── code-map/` 바로 다음 행만 본다.
    </details>
  - [QD] spec R11 [QD] 통과 (정책이 R1~R10과 모순 없음)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 정책 서술과 스킬 절차의 의미 대조라 명령으로 환원 불가

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
    P=.ai/90_issues/active/issue-0114/issue-0114-plan.md
    S=.ai/90_issues/active/issue-0114/issue-0114-summary.md
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
    S=.ai/90_issues/active/issue-0114/issue-0114-summary.md
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
    S=.ai/90_issues/active/issue-0114/issue-0114-summary.md
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
