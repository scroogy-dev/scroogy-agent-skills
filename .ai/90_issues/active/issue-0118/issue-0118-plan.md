# Issue #118 실행계획 doc 프로파일 운영 보강: 문서 규약 파일·SSoT 대상 범위·로비와 건물 repo의 SSoT 선언·리뷰 카테고리 doc 세트·보류 항목 원장 등재

> 스펙: [issue-0118-spec.md](./issue-0118-spec.md)

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

모든 검증 명령은 repo 루트에서 실행한다. "spec R<n> `[D]` 통과"는 spec `완료의 정의` 해당 그룹의 `[D]` 명령을 재실행해 전부 무출력임을 뜻한다.

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

### Task 1: ai-workspace doc 문서 규약 파일과 writing-principles 위임

- [x] 완료
- **목표**: doc 프로파일에 사용자 관리 문서 규약 파일 골격을 배포하고, 산출물 작성 원칙이 `ssot_dir` 문서를 그 파일에 위임하게 한다.
- **대상 요구사항**: R1, R2
- **작업 내용**:
  1. `ai-workspace/templates/doc/.ai/10_rules/document-convention.md`를 신설한다. H1 `# 문서 규약`, H2 4칸(spec 전제 리터럴), 칸마다 HTML 주석 안내와 기본값 한 줄(`.md` / 기본값 없음 / 기본값 없음 / 기본값 없음). 머리 주석에 사용자 관리 파일임과 스킬 표준(`.md`)을 적는다.
  2. doc 템플릿 `AI-CONTEXT.md` `## 프로젝트 규칙` 표에 `.ai/10_rules/document-convention.md` 행(설명 "문서 규약 (SSoT 대상 확장자·첨부 분류·우선순위·명명)", 사용 시점 "원본 문서 작성·리뷰 시")을 `context-loading.md` 행 뒤에 둔다(파일명 알파벳순. 작성 시 "앞"으로 오기해 Task 1에서 정정).
  3. `ai-workspace/SKILL.md`: init-1단계 "doc 전용: (없음)"을 `document-convention.md`로 바꾸고, update-1단계 설명의 사용자 작성 파일 목록과 코드 블록에 doc 프로파일 분기(없을 때만 복사)를 더한다.
  4. shared `writing-principles.md` 적용 범위 제외 줄 끝에 "doc 프로파일의 `ssot_dir` 문서는 `document-convention.md`를 따른다."를 잇고 버전 주석을 `1.2.0`으로 올린 뒤 `.ai/10_rules/writing-principles.md`에 그대로 덮어쓴다.
  5. `ai-workspace/tests/run-tests.sh` "doc 템플릿 고유 행" 절에 문서 규약 검사를 더한다. `doc_tpl_violations`에 규칙 표 행 존재와 `templates/doc/.ai/10_rules/document-convention.md` 파일 존재를 더하고, 통과 케이스 라벨에 `문서 규약 … 통과`, 행 삭제 격추 케이스 라벨에 `문서 규약 … 격추`를 쓴다.
- **완료 기준**:
  - [D] spec R1·R2 `[D]` 통과  (검증: 해당 명령 재실행)
  - [D] ai-workspace 테스트가 문서 규약 케이스(통과 1·격추 1 이상)를 포함해 0 실패로 통과한다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    R=ai-workspace/tests/run-tests.sh
    out=$("$R" 2>&1) \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*문서 규약.* 통과')" -ge 1 ] \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*문서 규약.* 격추')" -ge 1 ] \
      || echo '위반: 테스트 실패 또는 문서 규약 케이스 미실행'
    ```

    - 설계 주의: 러너 출력의 `ok` 행을 세어 새 케이스가 실제로 실행·통과했을 때만 통과한다. 케이스 설명에는 `통과`·`격추` 중 하나만 쓴다.
    </details>
  - [D] dev 템플릿과 shared `context-loading.md`는 건드리지 않는다 (spec `### 공통` 회귀 방지 `[D]`가 검사)  (검증: 해당 명령 재실행)

---

### Task 2: SSoT 대상 `.md` 확정 (code-map·context-harvest·doc 템플릿·정책)

- [x] 완료
- **목표**: 색인·수집 대상 정의 4곳이 `ssot_dir` 아래 `.md` 파일을 가리키고 그 밖의 분류를 repo 문서 규약 파일에 위임하게 한다.
- **대상 요구사항**: R3
- **작업 내용**:
  1. `code-map/references/doc.md`: 색인 대상 정의 행을 "`ssot_dir` 아래 `.md` 파일"로 바꾸고, 다른 확장자·첨부의 분류는 `document-convention.md`가 정하며 첨부는 색인 행을 만들지 않고 참조하는 md 행에 딸린다는 문장을 더한다. 1-1 스캔 범위(build/rebuild·sync)와 1-2 색인 단위 첫 항목도 `.md` 파일로 쓴다.
  2. `code-map/tests/fixtures/doc-index/README.md`에 색인 범위가 `.md`임을 적는다. 입력 fixture에 `.md` 외 파일이 없으므로 기대 결과는 바꾸지 않는다.
  3. `context-harvest/SKILL.md` `### SSoT 원칙 유지` 첫 항목의 괄호를 "`ssot_dir` 아래 `.md` 파일. 다른 확장자·첨부의 분류는 repo 문서 규약 파일(`document-convention.md`)이 정한다"로 바꾼다.
  4. doc 템플릿 `AI-CONTEXT.md` `## 프로젝트 도메인` 주석의 `ssot_dir` 문장을 "이 아래 `.md` 파일이 SSoT입니다. 다른 확장자·첨부의 분류는 `10_rules/document-convention.md`가 정합니다."로 바꾼다.
  5. 정책 `ssot-and-router-principle.md` 원칙 첫 항목의 괄호를 `.md` 파일로 바꾸고 문서 규약 파일 위임 문장을 더한다. 근거 접기에 한 줄(#118)을 더한다.
  6. 테스트: `code-map/tests/run-tests.sh`의 `doc.md` 검사 함수에 `.md` 정의·첨부 딸림 규칙을 더하고 격추 케이스 2건(라벨 `… .md 정의 … 격추`, `… 첨부 … 격추`)을 추가한다. `context-harvest/tests/run-tests.sh`에 `.md` 정의 격추 케이스 1건(라벨 `… .md 정의 … 격추`)을 추가한다.
- **완료 기준**:
  - [D] spec R3 `[D]` 통과  (검증: 해당 명령 재실행)
  - [D] `code-map/references/local.md`는 건드리지 않는다 (spec `### 공통` 회귀 방지 `[D]`가 검사. `global.md`는 Task 4가 바꾼다)  (검증: 해당 명령 재실행)
  - [QD] `doc.md`의 `.md` 정의·첨부 딸림 문장이 1-1·1-2 절차와 모순 없이 읽힌다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 절차 서술의 정합은 의미 판단이라 명령으로 환원 불가

---

### Task 3: 로비 SSoT 선언 문구·충돌 우선순위·placeholder 폴백 (ai-workspace-directory 전수)

- [x] 완료
- **목표**: 로비가 특정 SSoT 값을 선언하지 않고 각 repo 안내도의 선언을 따르게 하고, 헬퍼·규격·체크리스트·예시·fixture·정책·명세를 새 문구로 맞춘다.
- **대상 요구사항**: R4, R5
- **작업 내용**:
  1. `ai-workspace-directory/scripts/check-lobby.sh` `SSOT_LINE`을 새 문구로 바꾼다. 위반 메시지는 그대로 둔다.
  2. `references/standard-structure.md`: 필수 규칙 항목, 골격 코드 블록 2번째 줄, 골격 3단계 `placeholder` 분기(spec 전제 문구), 골격 4단계 우선순위(`각 repo의 SSoT(repo 안내도 선언: 소스 코드 또는 원본 문서) > 각 repo 안내도 > 이 안내도(상위 워크스페이스)`), 섹션별 강제 규칙 표 `> SSoT:` 행, `repo status 의미` 표 `placeholder` 행(선언 부재 폴백 보충)을 바꾼다.
  3. `references/ssot-checklist.md` 표준 문구 행, `references/examples.md`의 로비 전문 3곳(2번째 줄·placeholder 분기·우선순위), `tests/fixtures/lobby-good.md`(2번째 줄·placeholder 분기·우선순위)를 같은 문구로 바꾼다.
  4. `SKILL.md`: `### 대전제` 세 항목("소스 코드가 무조건 SSoT다" → 각 repo의 SSoT는 그 repo 안내도의 선언이 정하며 로비는 값을 선언하지 않는다 / markdown 지도 문장 → spec 전제의 Task 0 확정 문구 / 우선순위 문구), update-1단계 (4) 형식 위배 표의 SSoT 행, update-2단계 SSoT 삽입·교체 문장을 바꾼다.
  5. `tests/run-tests.sh`에 구 문구 격추 변형 `mutate_ssot_legacy`(2번째 줄을 `> SSoT: 소스 코드. 이 파일은 라우터일 뿐 진실의 원천이 아니다.`로)와 케이스 `(2) SSoT 구 문구(소스 코드 고정) 격추`를 추가한다. 기대 문구는 러너가 골격에서 추출하므로 리터럴을 러너에 적지 않는다.
  6. 정책 `ssot-and-router-principle.md` 로비 항목에 "로비는 SSoT 값을 선언하지 않고 각 repo 안내도의 선언을 따른다. 안내도가 없는 repo는 선언을 찾지 못한 것으로 보고 소스 코드로 폴백한다"를 더한다. `specs/ai-workspace.md` ai-workspace-directory 항목에 로비 2번째 줄 문구와 우선순위 서술을 더한다.
- **완료 기준**:
  - [D] spec R4·R5 `[D]` 통과  (검증: 해당 명령 재실행)
  - [D] `check-lobby.sh`가 새 문구 fixture에 종료 코드 0, 2번째 줄만 구 문구로 바꾼 사본에 종료 코드 1과 `표준 SSoT 문구가 아닙니다` 사유를 낸다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    C=ai-workspace-directory/scripts/check-lobby.sh
    G=ai-workspace-directory/tests/fixtures/lobby-good.md
    "$C" "$G" >/dev/null 2>&1 || echo '위반: 새 문구 fixture 격추됨'
    tmp="$(mktemp)"; sed '2s/.*/> SSoT: 소스 코드. 이 파일은 라우터일 뿐 진실의 원천이 아니다./' "$G" > "$tmp"
    out="$("$C" "$tmp" 2>&1)"; rc=$?
    { [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q '표준 SSoT 문구가 아닙니다'; } || echo "위반: 구 문구 사본 exit $rc, 사유 [$out]"
    rm -f "$tmp"
    ```

    </details>
  - [D] `SKILL.md` `### 대전제` 절에 "무조건 SSoT" 문구가 없고 "선언" 언급이 1행 이상 있다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    sec="$(awk '/^### 대전제/ { f = 1; next } f && /^#{2,3} / { exit } f' ai-workspace-directory/SKILL.md)"
    printf '%s\n' "$sec" | grep -q '무조건 SSoT' && echo '위반: 대전제에 구 문구 잔존'
    [ "$(printf '%s\n' "$sec" | grep -c '선언')" -ge 1 ] || echo '위반: 대전제에 선언 언급 없음'
    ```

    </details>

---

### Task 4: code-map 건물 리포 선언 규칙·대상 리포 선언 확인·`--local` 멈춤·ai-workspace update 보고

- [x] 완료
- **목표**: 건물 리포가 `소스 코드`로 선언하고 그 뜻을 문서에 남기며, `--global`이 대상 리포의 선언을 읽어 문서 리포를 구분하고, 건물 리포에서 `--local`·`--local sync` 안내가 멈춘다. ai-workspace update는 어긋난 선언을 보고만 한다.
- **대상 요구사항**: R6, R7
- **작업 내용**:
  1. `code-map/references/global.md` `## 전제 조건`에 선언 규칙 항목을 더한다. "안내도의 SSoT 선언은 `소스 코드`다. 이 리포의 문서는 등록 리포의 코드 색인에서 만든 것이라 SSoT는 등록 리포의 소스 코드이며 이 리포 안에는 없다. doc 프로파일(`원본 문서`)로 init하지 않는다."
  2. `global.md` 0단계: 2번(`repository.yaml` 없음 중단) 뒤에 새 3번 "건물 리포 안내도 선언 확인(`소스 코드`가 아니면 보고하고 중단, 자동 전환 없음)"을 더한다(번호 배치는 spec 전제의 Task 0 확정값). 4번 분석 상태 분류(분석 완료 / 미분석)는 그대로 두고 그 뒤에 별도 항목 **SSoT 종류 분류**를 더한다. 각 리포 안내도의 선언을 읽어(선언 읽기 표준 세 문장) `소스 코드` / `원본 문서`로 나누고, `원본 문서` 리포는 `문서 리포`로 표시하되 분석 상태를 대체하지 않는다고 적는다. 항목이 늘어 번호가 바뀌므로 0단계 머리 문장과 `code-map/tests/run-tests.sh` 주석의 `4·5번` 참조를 새 번호로 고친다. 1단계: 머리 문장을 "0단계에서 분석 완료로 분류된 리포만(SSoT 종류 무관) 대상으로"로 바꾸고, 1번 리포 스캔에 "`원본 문서` 리포는 상세 호출 흐름 문서 대신 문서 지도(색인의 파일 목록)를 읽는다"를, 4번에 `원본 문서` 리포 제외 문장을 더한다. 3단계 건물 안내도 예시에 `> SSoT: 등록 리포의 소스 코드. 이 리포 안에는 SSoT가 없다.` 인용 행과 리포 목록 표 `SSoT` 열(`원본 문서` 행 1개 포함)을 더한다.
  3. `code-map/SKILL.md` `## 모드별 실행 절차` 앞에 건물 리포 규칙 한 항목을 둔다. "`.ai/60_codebase/repository.yaml`이 있으면 건물 리포다. `--local`은 건물 안내도를 덮어쓰지 않도록 중단하고 `--global`을 안내한다." `--local` 모드 표 요약에도 같은 조건을 붙인다.
  4. `context-harvest/SKILL.md` 6단계 결과 보고 아래에 "건물 리포(`.ai/60_codebase/repository.yaml` 존재)에서는 `/code-map --local sync`를 권하지 않고 `/code-map --global sync`를 안내한다"를 더한다.
  5. `ai-workspace/scripts/check-context.sh`: `$(dirname <파일>)/60_codebase/repository.yaml`이 있고 2번째 줄이 doc 표준 문구이면 `누락: 건물 repo 선언 (repository.yaml 존재, doc 선언 — 소스 코드 선언 대상, 자동 전환 없음)`을 보고한다. 머리 주석의 행 수를 "11행 중 9행"으로 고친다. `ai-workspace/SKILL.md` 멱등 보강 검사의 "10개 항목 중 8개" 문장을 "11개 항목 중 9개"로 고치고, 검사 표에 `repository.yaml` 행(검사·조치)을 더하고, SSoT 선언 행의 조치에 "건물 repo면 dev 문구를 넣는다"를 더한다. `specs/ai-workspace.md`의 "8종 + AI 판정 2종"을 "9종 + AI 판정 2종"으로, 건물 repo 검사 문장을 더한다.
  6. 테스트: `code-map/tests/run-tests.sh`에 격추 케이스를 더한다(라벨에 `건물` 포함, 3건 이상: SKILL.md `--local` 멈춤 규칙 삭제, global.md 전제 조건 선언 규칙 삭제, global.md 0단계 선언 읽기 삭제, 1단계 `원본 문서` 제외 삭제). `context-harvest/tests/run-tests.sh`에 6단계 건물 분기 삭제 격추 1건(라벨 `건물`). `ai-workspace/tests/run-tests.sh`에 임시 디렉토리 `.ai/60_codebase/repository.yaml`을 만든 뒤 doc 선언 보고(라벨 `건물 repo … 격추`)·dev 선언 무보고·`repository.yaml` 없는 doc 선언 무보고(라벨 `건물 repo … 통과`) 케이스를 더한다.
- **완료 기준**:
  - [D] spec R6·R7 `[D]` 통과  (검증: 해당 명령 재실행)
  - [D] `check-context.sh` 머리 주석의 행 수 표기와 `specs/ai-workspace.md`의 검사 종수가 11행·9종으로 맞는다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    grep -qE '검사 표 11행 중 9행' ai-workspace/scripts/check-context.sh || echo '위반: 헬퍼 머리 주석 행 수'
    grep -qE 'check-context\.sh` 9종 \+ AI 판정 2종' .ai/40_domain/specs/ai-workspace.md || echo '위반: 명세 검사 종수'
    ```

    </details>
  - [D] 테스트 러너 3종이 이 Task의 케이스를 포함해 0 실패로 통과한다 (spec R6 세 번째·R7 세 번째 `[D]`와 같은 명령)  (검증: 해당 명령 재실행)
  - [QD] `global.md` 0~1단계에서 분석 상태와 SSoT 종류가 별도 축으로 읽히고, `원본 문서` 리포가 1~3번 수집 대상에 남은 채 4번에서만 빠진다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 절차 서술의 정합은 의미 판단이라 명령으로 환원 불가
  - [ND] 건물 리포에서 `--local`을 실행하면 중단되고 `--global`이 안내된다  (검증: 사람이 회사 환경에서 확인)  ← 강등 사유: 스킬 실행 결과는 LLM 동작이라 명령으로 판정 불가

---

### Task 5: 리뷰·감사·퀴즈 doc 카테고리 세트

- [ ] 완료
- **목표**: SSoT 선언이 `원본 문서`인 repo에서 git-review·issue-audit·git-review-quiz가 같은 이름·순서의 doc 카테고리 7종을 쓰게 한다.
- **대상 요구사항**: R8
- **작업 내용**:
  1. `git-review/SKILL.md` 코드 7종 표 아래에 분기 문장("SSoT 선언이 `원본 문서`이면 아래 doc 카테고리 세트를 쓴다. `소스 코드`이거나 선언이 없으면 위 표를 쓴다. 개수 7과 순서는 같고 결과 템플릿의 카테고리 행 이름만 바뀐다")과 doc 표(헤더 `| doc 카테고리 | 검증 내용 | 대응 코드 카테고리 |`, 행 순서 "내용 정확성, 구조 정합, 모순·누락, 보안·민감정보, 가독성·일관성, 최신성, 근거 검증")를 둔다. 원본 표시 문장에 doc 세트도 원본임을 덧붙인다.
  2. `issue-audit/SKILL.md` 카테고리 표 아래에 같은 분기 문장과 같은 doc 표를 복제한다(동기화 주석 유지). 2단계 집계 줄 주석에 선언이 `원본 문서`면 doc 이름으로 쓴다고 적는다.
  3. `git-review-quiz/SKILL.md` 7 카테고리 소재 표 아래에 분기 문장과 doc 표(헤더 `| doc 카테고리 | 문항 소재 | 대응 코드 카테고리 |`)를 둔다. `검증 내용` 열(작업 1·2)은 이슈 본문 후보표 문구를, `문항 소재` 열은 spec 전제의 Task 0 확정 문구를 쓴다.
  4. 결과 템플릿: `git-review/templates/review-result-template.md` 카테고리 표 주석과 `issue-audit/templates/issue-audit-report-template.md` 카테고리 표·상세 분석 카테고리 주석에 "선언이 `원본 문서`이면 doc 카테고리 이름으로 바꿔 쓴다(SKILL.md doc 표)"를 더한다. 행 자체는 코드 7종 기본값으로 둔다.
  5. `specs/git-review-output.md` 카테고리 항목과 ADR 0014 결정 항목에 doc 세트 문장을 더한다(끝에 `(#118)`).
  6. 테스트: 세 스킬 `tests/run-tests.sh`에 doc 카테고리 표 검사를 더한다. SKILL.md에서 `| doc 카테고리 |` 표의 첫 열을 추출해 확정 이름·순서 7개 리터럴("내용 정확성, 구조 정합, 모순·누락, 보안·민감정보, 가독성·일관성, 최신성, 근거 검증")과 같으면 통과(라벨 `doc 카테고리 표 … 통과`). 격추는 임시 사본으로 3건을 둔다(라벨 모두 `doc 카테고리 표 … 격추`): 행 하나 삭제, 행 수를 유지한 이름 오기(한 행의 이름을 코드 이름으로 교체), 행 수를 유지한 순서 교환(두 행 맞바꿈). 리터럴은 러너마다 둔다(스킬 독립성, ADR 0002).
- **완료 기준**:
  - [D] spec R8 `[D]` 통과  (검증: 해당 명령 재실행)
  - [D] 세 스킬의 doc 표 3열 `대응 코드 카테고리`가 코드 7종을 순서대로 담는다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    map_col() {
      awk '/^\| doc 카테고리 \|/ { f = 1; next }
           f && /^\|[- |]+\|[[:space:]]*$/ { next }
           f && /^\|/ { split($0, a, "|"); gsub(/^ +| +$/, "", a[4]); print a[4]; next }
           f { exit }' "$1"
    }
    for s in git-review issue-audit git-review-quiz; do
      diff <(map_col "$s/SKILL.md") <(printf '%s\n' 기능 아키텍처 버그 보안 코드품질 성능 테스트) >/dev/null || echo "위반: $s 대응 코드 카테고리 열"
    done
    ```

    </details>
  - [D] `classify-risk.sh` 2종과 코드 7종 표가 `main`과 같다 (spec 공통 두 번째 `[D]`와 같은 명령)  (검증: 해당 명령 재실행)

---

### Task 6: issue-work 보류 항목 원장 등재 경로

- [ ] 완료
- **목표**: 이슈 완료 시 spec 제외 목록의 `보류` 항목을 원장 등재 후보로 보여 주고 승인분만 등재하는 경로를 issue-work와 원장 문서에 둔다.
- **대상 요구사항**: R9
- **작업 내용**:
  1. `issue-work/SKILL.md` `## 이슈 완료 시` 3단계에 하위 항목 **보류 항목 원장 등재 질의**를 더한다. spec `제외` 목록에서 사유가 `보류`인 항목을 보여 주고 등재 여부를 묻는다(권고·승인형). 승인분은 `ledger-entry-template.md` 형식으로 `active/K-<번호>-<slug>.md`를 신설하고 index를 갱신하며, 출처는 `이슈 #N`, 수용 사유·재검토 조건은 필수다. 중복 판정은 보류 항목 단위다. 이슈 번호는 `active/`·`archive/`를 검색하는 범위로만 쓰고, 그 보류 항목과 같은 대상(제목·내용)을 기록한 원장 항목이 있을 때 그 보류 항목만 건너뛴다. SKILL.md 문장에 예시를 함께 둔다("보류 A만 등재된 상태면 B는 질의하고, A·B가 모두 등재됐으면 둘 다 건너뛴다"). `--clear` 4단계 문장에도 같은 질의를 덧붙이고, `## 참조 문서`의 `70_ledger/index.md` 행에 "보류 항목 등재"를 더한다.
  2. `issue-work/templates/issue-spec-template.md` 요구사항 안내 주석의 제외 설명에 "`보류` 항목은 이슈 완료 시 원장 등재 여부를 질의받는다"를 더한다.
  3. 원장 등재 주체 문장을 고친다. 이 repo와 shared의 `70_ledger/index.md` 머리 문장과 수명 주기 표 등재 행, `ledger-entry-template.md` 등재 주체 줄에 "issue-work 이슈 완료 시(spec 제외 `보류` 항목)"를 더한다. 항목 템플릿 두 사본을 같게 유지한다.
  4. `specs/issue-workflow.md` 절차 문장과 ADR 0007 소비자 문장, ADR 0018 결정에 보류 등재 경로를 더한다(끝에 `(#118)`).
  5. 테스트: `issue-work/tests/run-tests.sh`에 구조 검사를 더한다. `## 이슈 완료 시` 절에 `보류`·`원장`·`등재`를 담은 행이 1 이상이면 통과(라벨 `보류 등재 … 통과`), 그 행을 지운 사본은 격추(라벨 `보류 등재 … 격추`).
- **완료 기준**:
  - [D] spec R9 `[D]` 통과 (`--clear` 단계 번호 1~6 불변 회귀 방지 항목 포함)  (검증: 해당 명령 재실행)
  - [QD] 등재 질의 문장이 `--response` 원장 등재(수용 사유·재검토 조건 필수)와 같은 필드 요구를 담고 충돌하지 않는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 두 절의 의미 정합은 명령으로 환원 불가

---

### Task 7: ADR 0020과 보류 항목 2건 원장 등재

- [ ] 완료
- **목표**: doc SSoT 결정과 퍼블리싱 범위 밖 결정을 ADR로 남기고, 이 이슈의 보류 항목 2건을 Task 6 경로로 등재해 첫 적용으로 삼는다.
- **대상 요구사항**: R10, R11
- **작업 내용**:
  1. 사용자에게 보류 항목 2건(퍼블리싱 스킬·퍼블리시 기록·위키 직접 수정 탐지 / 선언 깨짐 시 경고 없는 폴백)을 Task 6의 질의 형식으로 보여 주고 등재 승인을 받는다. 위험도는 `issue-audit/scripts/classify-risk.sh --impact … --likelihood …`로 산출한다.
  2. 승인분을 `.ai/70_ledger/active/K-0014-publishing-skill-deferred.md`(기술부채)·`K-0015-ssot-declaration-fallback-no-warning.md`(known issue)로 등재한다. 출처 `이슈 #118 (spec 제외 보류 항목)`, 수용 사유·재검토 조건(퍼블리싱: 스킬화 결정 시 또는 위키 직접 수정이 SSoT와 어긋난 사례 관측 시 / 폴백: 선언 문구 복제 8곳의 표준 문장 변경 시 또는 선언 오기로 폴백이 잘못 동작한 사례 관측 시), 재검토 이력 "없음"을 채우고 `.ai/70_ledger/index.md` 항목 목록을 갱신한다.
  3. `.ai/50_adr/active/0020-doc-ssot-original-documents-and-publishing-deferred.md`를 ADR 0018과 같은 구조(frontmatter·결정·근거 접기·대안 접기·원본 출처 접기)로 쓴다. 결정 1(doc SSoT는 repo 지정 디렉토리의 원본 문서, 기각 대안 위키 원본·page ID 추적 2026-10-20 초안과 기각 이유), 결정 2(퍼블리싱 실행·동기화·위키 직접 수정 대응은 스킬 범위 밖, 프롬프트로 경험 후 재판단, 재검토 조건은 K-0014), 이번 이슈가 채운 빈 곳(문서 규약 파일·`.md` 확정·로비 선언·건물 리포 선언·doc 카테고리·보류 등재 경로·writing-principles 1.2.0)을 결정 항목으로 적는다. 근거는 #114 spec 전제 "방향 전환 이력"과 이 이슈 본문에서 끌어온다.
  4. `.ai/50_adr/index.md`에 0020 행을 더한다.
- **완료 기준**:
  - [D] spec R10·R11 `[D]` 통과  (검증: 해당 명령 재실행)
  - [D] 두 원장 항목의 `상태`가 `수용`이고 `재검토 이력` 표 아래에 "없음" 행이 있으며, `위험도` 값이 허용 등급 4종 중 하나의 표기 형식이다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    for f in .ai/70_ledger/active/K-0014-*.md .ai/70_ledger/active/K-0015-*.md; do
      [ -f "$f" ] || { echo "위반: $f 없음"; continue; }
      grep -qE '^- \*\*상태\*\*: 수용$' "$f" || echo "위반: $f 상태"
      awk '/^## 재검토 이력/ { f = 1; next } f && /^## |^<details>/ { exit } f' "$f" | grep -qE '없음' || echo "위반: $f 재검토 이력 없음 표기"
      grep -qE '^- \*\*위험도\*\*: (높음\(HIGH\)|중간\(MEDIUM\)|낮음\(LOW\)|정보\(INFO\))$' "$f" || echo "위반: $f 위험도 표기"
    done
    ```

    - 설계 주의: 위험도는 등재 시 헬퍼로 산출하고 그 축 판정을 항목의 근거 접기에 적는다. 축 판정이 자유 서술이라 헬퍼 산출과의 일치는 명령으로 검사하지 않으며, 이 검사는 등급 리터럴의 표기 형식만 본다. 산출 일치는 작업 1의 헬퍼 호출과 아래 [ND] 승인이 맡는다.
    </details>
  - [ND] 등재 2건이 사용자 승인으로 확정됐다  (검증: 사용자)  ← 강등 사유: 승인 사실은 대화 기록이라 명령으로 환원 불가

---

### Task 8: 색인·안내도·README 문서 정합

- [ ] 완료
- **목표**: 이 repo의 `.ai/60_codebase/` 색인·상세 흐름, 안내도, 40_domain index, README가 Task 1~7의 변경을 반영한다.
- **대상 요구사항**: R1, R4, R5, R6, R8, R9
- **작업 내용**:
  1. `.ai/60_codebase/ai-workspace/init-call-flow.md`(doc 전용 `document-convention.md`)·`update-call-flow.md`(doc 전용 없을 때만 복사, 건물 repo 선언 검사 행), `ai-workspace-directory/init-call-flow.md`(대전제 문구: 로비는 선언을 따름)·`update-call-flow.md`(SSoT 문구 검사 설명), `git-review/review-call-flow.md`·`issue-audit/final-audit-call-flow.md`(카테고리 7종 사본 문장에 doc 세트), `issue-work/clear-call-flow.md`(4단계 보류 등재 질의)를 고치고 각 파일 `source_hash`를 갱신한다. `index.md` 본문의 code-map 행(건물 리포 선언)·카테고리 7종 문장 2곳·issue-work 행을 고치되 frontmatter는 두지 않는다.
  2. `.ai/40_domain/index.md`의 정책·명세 설명을 바뀐 범위(로비 선언, `.md` 확정, doc 카테고리, 보류 등재)에 맞춘다.
  3. `.ai/AI-CONTEXT.md` `last updated`를 갱신하고 디렉토리 구조·스킬 목록에 바뀐 설명이 필요하면 고친다(없으면 무변경). `README.md` 스킬 표는 변경이 필요한 행만 고친다(없으면 무변경).
  4. 전체 스킬 테스트와 spec `완료의 정의` `[D]` 전체를 재실행한다.
- **완료 기준**:
  - [D] 상세 흐름 7개 파일과 index 본문에 바뀐 문구가 있고, 상세 흐름 `source_hash`가 `main`과 다르다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    B=.ai/60_codebase
    grep -q 'document-convention' "$B/ai-workspace/init-call-flow.md" || echo '위반: init 흐름 doc 전용 파일'
    grep -q 'repository.yaml' "$B/ai-workspace/update-call-flow.md" || echo '위반: update 흐름 건물 검사 행'
    grep -q '선언' "$B/ai-workspace-directory/init-call-flow.md" || echo '위반: 로비 init 흐름 대전제'
    for f in git-review/review-call-flow.md issue-audit/final-audit-call-flow.md; do grep -q 'doc 카테고리' "$B/$f" || echo "위반: $f doc 세트"; done
    grep -q '보류' "$B/issue-work/clear-call-flow.md" || echo '위반: clear 흐름 보류 등재'
    grep -q 'doc 카테고리' "$B/index.md" || echo '위반: index 카테고리 문장'
    for f in ai-workspace/init-call-flow.md ai-workspace/update-call-flow.md ai-workspace-directory/init-call-flow.md ai-workspace-directory/update-call-flow.md git-review/review-call-flow.md issue-audit/final-audit-call-flow.md issue-work/clear-call-flow.md; do
      [ "$(git show "main:$B/$f" | grep -E '^source_hash:')" != "$(grep -E '^source_hash:' "$B/$f")" ] || echo "위반: $f source_hash 미갱신"
    done
    ```

    </details>
  - [D] spec `완료의 정의` `[D]` 전체와 공통 회귀 항목이 통과한다  (검증: 해당 명령 재실행)
  - [QD] 색인·안내도 서술이 바뀐 절차(Task 1~7)와 모순되지 않는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 서술과 절차의 의미 대조는 명령으로 환원 불가

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
    P=.ai/90_issues/active/issue-0118/issue-0118-plan.md
    S=.ai/90_issues/active/issue-0118/issue-0118-summary.md
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
    S=.ai/90_issues/active/issue-0118/issue-0118-summary.md
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
    S=.ai/90_issues/active/issue-0118/issue-0118-summary.md
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
