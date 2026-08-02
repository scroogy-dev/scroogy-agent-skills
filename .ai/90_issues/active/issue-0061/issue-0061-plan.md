# Issue #61 실행계획 — 기술부채·known issue 원장 도입

> 스펙: [issue-0061-spec.md](./issue-0061-spec.md)

---

## 설계 종료 게이트 (고정)

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
- **점검 결과**: 발견 4건을 spec `## 전제 (Assumptions)`에 기록 — 템플릿 배치 위치와 버린 대안, K-번호 자릿수, workflow 사본 동기화, 템플릿 골격 반영 형태.

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> **작성 원칙**: 구현자에게 이 문서 외 컨텍스트가 없다고 가정하고, Task별 완료 기준을 결정적으로 씁니다.
> 각 작업은 독립적으로 검증 가능해야 하며, 완료 기준은 **항목별 리스트로 쪼개 레벨 태그 + 검증 수단**을 적습니다.
> 명령으로 환원이 어려운 항목만 판정 주체(다른 AI / 사람)를 적고 강등 사유를 남깁니다.
>
> **완료 기준 형식** — 본문(접기 금지)에는 레벨 태그 + 무엇이 보장되는지 한 문장(+ 강등 사유)만 두고,
> 검증 명령·테스트케이스·기대 출력·명령 설계 주의점은 접기로 내립니다. 접기 제목에 기대 출력을 함께 적습니다
> (기본형: "검증 명령 — 출력 0건이면 통과"). 접을 상세가 없는 항목은 접기 없이 본문 한 줄로 둡니다.
> 다른 게이트의 선행 조건이 되는 항목은 의존 관계와 **선행 조건이 무너졌을 때의 결과**를 본문 문장에 남기고, 메커니즘만 접기에 둡니다.
> 첫 고정 Task(Task 0 구현 시작 게이트)와 마지막 고정 Task(교차모델 issue-audit)는 삭제하지 말고 그대로 둡니다.
>
> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> **문서를 대상으로 검증할 때는 문구가 아니라 행 구조를 셉니다** — 같은 문구가 주석·안내문에도 등장하므로
> `grep -c '<문구>'`는 실제 구조가 없어도 통과합니다. 헤더는 `^## `, Task는 `^### Task `,
> 필드는 `^- \*\*…\*\*:`로 앵커를 고정하고, 명령은 작업 디렉토리에 의존하지 않게 repo 루트 기준 경로로 적습니다.
> **검증 명령 보정은 반례 격추가 아니라 불변식 전수 명세로 합니다** — 지적된 변형 하나만 막으면 이웃 변형이
> 다음 감사에서 재발하므로, 기대 구조를 열거하고 "그 외 0건"까지 판정에 넣습니다.

### Task 0 (고정): 구현 시작 게이트 — 전제·모호점 확인

<!--
이 블록은 모든 이슈 계획의 첫 Task로 고정한다. 삭제하지 말 것.
설계 종료 게이트가 "쓰는 쪽"의 자기점검이라면, 이 게이트는 "읽는 쪽"이 착수 전에 거는 확인이다.
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

### Task 1: 원장 항목 템플릿 정의

- [x] 완료
- **목표**: 원장 항목의 표준 형식을 확정한다 — 등재 절차(`--response`·git-pr-feedback)가 참조할 단일 템플릿.
- **작업 내용**:
  1. `issue-work/templates/ledger-entry-template.md` 생성 — 필수 필드 7종을 `- **<필드>**:` 앵커로 고정: 유형(known issue / 기술부채), 등재일, 출처, 위험도(높음(HIGH) / 중간(MEDIUM) / 낮음(LOW) / 정보(INFO)), 수용 사유(필수 — 왜 지금 고치지 않는지), 재검토 조건(필수 — 언제 다시 볼지), 상태(수용 / 승격(이슈 #N) / 해소(PR #N)).
  2. `출처` 필드는 **식별자만** 적고 파일 경로를 넣지 않음을 템플릿 본문에 명시한다 — 이슈 #N / audit 발견 `F-n` / PR 코멘트 스레드. 근거는 spec 전제 참조(`--clear` 이관으로 리포트 경로가 바뀌어도 원장이 깨지지 않게).
  3. 파일명 규칙 `K-<번호>-<slug>.md`(번호 4자리 zero-padding)와 배치 위치(`.ai/70_ledger/active/`, 청산 시 `archive/` 이관)를 본문에 명시한다.
- **완료 기준**:
  - [D] 항목 템플릿이 필수 필드 7종을 `- **<필드>**:` 앵커로 갖춘다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    T=issue-work/templates/ledger-entry-template.md
    for f in '유형' '등재일' '출처' '위험도' '수용 사유' '재검토 조건' '상태'; do
      grep -qE "^- \*\*$f\*\*:" "$T" || echo "위반: $f 필드 누락 또는 파일 없음"
    done
    ```

    - 설계 주의: 파일이 없으면 `grep -q`가 실패해 7건 전부 위반으로 출력된다 — 파일 실재 검사를 겸한다.
    </details>
  - [D] 템플릿이 파일명 규칙과 배치 위치, 출처의 경로 미기재 원칙을 본문에 명시한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    T=issue-work/templates/ledger-entry-template.md
    grep -q 'K-<번호>-<slug>.md' "$T" || echo '위반: 파일명 규칙 없음'
    grep -q '70_ledger/active' "$T" || echo '위반: 배치 위치 없음'
    grep -q '경로' "$T" || echo '위반: 출처 경로 미기재 원칙 없음'
    ```

    </details>

---

### Task 2: issue-work `--response` 원장 이관 규칙 반영

- [x] 완료
- **목표**: 미승인·보류 발견의 이관 목적지를 원장으로 표준화해, "별도 이슈로 이관"의 모호함을 없앤다.
- **작업 내용**:
  1. `issue-work/SKILL.md`의 `--response` 3~5단계를 개정한다 — 처리 방향 "이관"의 목적지를 `.ai/70_ledger/` 등재로 표준화하고, 등재 시 수용 사유·재검토 조건을 필수 기재로 명시한다(`ledger-entry-template.md` 참조 연결).
  2. `issue-work/templates/issue-workflow-template.md`의 `--response` 안내 행에 이관 목적지(원장)를 한 줄 반영하고, `.ai/90_issues/active/issue-workflow.md` 사본을 동기화한다.
- **완료 기준**:
  - [D] SKILL.md가 이관 목적지(원장 경로)와 등재 필수 필드 2종을 명시한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    F=issue-work/SKILL.md
    grep -q '70_ledger' "$F" || echo '위반: 원장 경로 없음'
    grep -E 'ledger|원장' "$F" | grep -q '수용 사유' || echo '위반: 수용 사유 필수 기재 없음'
    grep -E 'ledger|원장' "$F" | grep -q '재검토 조건' || echo '위반: 재검토 조건 필수 기재 없음'
    ```

    </details>
  - [D] workflow 템플릿에 이관 목적지가 반영되고 active 사본이 템플릿과 일치한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    grep -q 'ledger' issue-work/templates/issue-workflow-template.md || echo '위반: workflow 템플릿에 이관 목적지 없음'
    diff issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md >/dev/null || echo '위반: active 사본 불일치'
    ```

    </details>

---

### Task 3: issue-audit 원장 참조 규칙 반영

- [ ] 완료
- **목표**: audit이 기등재 발견을 신규로 재보고하지 않게 하여 개선 → 재검증 무한반복 구조를 끊는다.
- **작업 내용**:
  1. `issue-audit/SKILL.md` 0단계(컨텍스트 수집)에 `.ai/70_ledger/index.md`를 읽고 관련 항목만 선택 적재하는 절차를 추가하고, `## 참조 문서`의 스킬 고유 추가 참조에도 같은 경로를 넣는다.
  2. 2단계(비판적 검증) 발견이 기등재 항목과 일치하면 신규 발견으로 보고하지 않고 "기등재 K-<번호> 참조"로 표기하며 집계에서 제외하는 규칙을 추가한다. 재검토 조건이 충족된 항목만 재제기 가능함을 함께 명시한다.
  3. `issue-audit/templates/issue-audit-report-template.md`에 `### 기등재 참조 항목` 섹션을 2단계 안, `### 발견 사항` 표 바깥에 신설한다 — 표는 곧 집계 대상이라 기등재를 표 안에 두면 집계가 오염되고 `F-` 번호를 소비한다(spec 전제 참조).
  4. `## 출력 요약 형식`에 기등재 참조 건수를 집계와 분리해 표기하는 줄을 추가한다.
- **완료 기준**:
  - [D] SKILL.md가 원장 index 선택 적재와 기등재 참조·집계 제외 규칙을 명시한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    F=issue-audit/SKILL.md
    grep -q '70_ledger/index.md' "$F" || echo '위반: 원장 index 적재 규칙 없음'
    grep -q '기등재' "$F" || echo '위반: 기등재 참조·집계 제외 규칙 없음'
    grep -q '재검토 조건' "$F" || echo '위반: 재검토 조건 판정 규칙 없음'
    ```

    </details>
  - [D] 리포트 템플릿에 기등재 참조 섹션이 발견 사항 표 바깥에 존재한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    T=issue-audit/templates/issue-audit-report-template.md
    grep -qE '^### 기등재 참조 항목' "$T" || echo '위반: 기등재 참조 섹션 없음'
    awk '/^### 발견 사항/{f=1} /^### 기등재 참조 항목/{if(f)g=1} END{exit !g}' "$T" \
      || echo '위반: 기등재 섹션이 발견 사항 뒤에 없음 — 표 안에 섞였을 수 있음'
    ```

    - 설계 주의: 섹션 존재만 보면 표 안에 행으로 들어간 형태를 못 거른다 — `^### ` 앵커로 독립 섹션임을 함께 확인한다.
    </details>
  - [QD] 기등재 판정·재검토 조건 규칙이 audit 절차(0단계 적재 → 2단계 대조)와 의미적으로 정합해 반복 보고가 실제로 차단된다  (검증: 교차모델 audit 채점)  ← 강등 사유: 절차 간 의미 정합성은 문자열 대조로 환원 불가

---

### Task 4: git-pr-feedback 원장 등재 선택지 추가

- [ ] 완료
- **목표**: PR 리뷰에서 "타당하나 이번에 미조치"로 판정한 항목의 이관 목적지를 원장으로 확정한다 — 이슈 #61 코멘트의 확정 사항이며, 이 연계 때문에 원장이 이슈 흐름 밖 `70_ledger/`에 놓인다.
- **작업 내용**:
  1. `git-pr-feedback/SKILL.md`의 `### 항목별 선택` 목록에 `- **수용 — 원장 등재**` 선택지를 추가한다 — 기존 3종(코드 수정 / 답글 게시 / 보류(건너뜀)) 다음에 두고, `.ai/70_ledger/active/`에 `ledger-entry-template.md` 형식으로 등재함을 명시한다.
  2. 등재 시 수용 사유(발생확률·영향도)·재검토 조건을 필수 기재로 명시한다 — 의견 유형 `수용(known issue)`이 이미 수용 근거를 요구하므로, 그 근거를 원장 항목의 `수용 사유`로 옮겨 적는 관계를 함께 적는다.
  3. 결과 기록 형식(처리 표·본문 유지 규칙)에 원장 등재 항목의 `K-<번호>` 표기를 반영한다.
- **완료 기준**:
  - [D] 항목별 선택지에 원장 등재가 추가되고 원장 경로·필수 필드 2종이 명시된다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    F=git-pr-feedback/SKILL.md
    grep -qE '^- \*\*수용 — 원장 등재\*\*' "$F" || echo '위반: 항목별 선택지에 원장 등재 없음'
    grep -q '70_ledger' "$F" || echo '위반: 원장 경로 없음'
    grep -E 'ledger|원장' "$F" | grep -q '수용 사유' || echo '위반: 수용 사유 필수 기재 없음'
    grep -E 'ledger|원장' "$F" | grep -q '재검토 조건' || echo '위반: 재검토 조건 필수 기재 없음'
    ```

    - 설계 주의: 선택지는 `^- \*\*…\*\*` 앵커로 센다 — 본문 서술에 같은 문구가 있어도 선택지 목록에 들어갔는지는 앵커로만 판정된다.
    </details>

---

### Task 5: ai-workspace·안내도에 70_ledger/ 반영

- [ ] 완료
- **목표**: 새로 설치·갱신되는 `.ai` 구조와 이 repo 안내도가 원장을 포함하게 하고, 이 repo에 첫 인스턴스를 만든다.
- **작업 내용**:
  1. `ai-workspace/templates/shared/.ai/70_ledger/`를 신설한다 — `index.md`(항목 목록 표 + `## 수명 주기` 섹션) + `active/.gitkeep` + `archive/.gitkeep`. index 골격은 ai-workspace 단독 소유이며 issue-work에는 두지 않는다(spec 전제 참조). `index.md` 문체는 이웃 index(`50_adr/index.md`)의 형식을 따른다.
  2. `ai-workspace/templates/shared/.ai/10_rules/context-loading.md`의 `## 참조 원칙` 첫 행 열거에 `70_ledger/`를 추가한다 — index 먼저 읽고 관련 항목만 선택 적재하는 대상이다. 이 파일은 update-1단계에서 무조건 덮어쓰는 버전 고정 파일이라 갱신이 기존 설치본에도 전파된다.
  3. `ai-workspace/templates/dev|doc/.ai/AI-CONTEXT.md`를 갱신한다 — `.ai 디렉토리 구조` 트리에 `70_ledger/ # [6순위] …` 행 추가, 진입 절차의 선택 적재 문장에 `70_ledger/index.md` 추가.
  4. `ai-workspace/SKILL.md` update-3단계를 갱신한다 — 대상 디렉토리 목록에 `70_ledger/` 추가, 하위 구조 표에 `active/`, `archive/` 행 신설, 이동 판단 기준 표에 `70_ledger/` 행 신설(상태가 승격·해소면 `archive/`, 아니면 `active/`).
  5. 이 repo에 반영한다 — `.ai/70_ledger/` 첫 인스턴스 생성(index.md + active/ + archive/), `.ai/AI-CONTEXT.md` 디렉토리 구조·진입 절차, `.ai/10_rules/context-loading.md` 참조 원칙.
- **완료 기준**:
  - [D] 템플릿 골격이 `index.md` + `active/` + `archive/` 구조를 갖추고 index에 수명 주기가 명시된다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    B=ai-workspace/templates/shared/.ai/70_ledger
    test -d "$B/active" || echo '위반: 템플릿 골격에 active/ 없음'
    test -d "$B/archive" || echo '위반: 템플릿 골격에 archive/ 없음'
    grep -qE '^## 수명 주기' "$B/index.md" || echo '위반: 수명 주기 섹션 누락 또는 index.md 없음'
    for w in '승격' '해소' 'archive/'; do
      grep -q "$w" "$B/index.md" || echo "위반: $w 미명시"
    done
    test -f issue-work/templates/ledger-index-template.md \
      && echo '위반: index 템플릿이 issue-work에도 존재 — SSoT 이중화'
    ```

    - 설계 주의: 마지막 검사는 "없어야 통과"다 — index 골격의 소유자를 ai-workspace 단독으로 고정하는 불변식이라, 존재 검사만 두면 양쪽에 생겨도 통과한다.
    </details>
  - [D] context-loading·AI-CONTEXT 템플릿(dev/doc)·ai-workspace SKILL.md·이 repo 안내도와 규칙에 `70_ledger`가 반영된다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    for f in ai-workspace/templates/shared/.ai/10_rules/context-loading.md \
             ai-workspace/templates/dev/.ai/AI-CONTEXT.md \
             ai-workspace/templates/doc/.ai/AI-CONTEXT.md \
             ai-workspace/SKILL.md .ai/AI-CONTEXT.md .ai/10_rules/context-loading.md; do
      grep -q '70_ledger' "$f" || echo "위반: $f 에 70_ledger 미반영"
    done
    ```

    </details>
  - [D] 이 repo에 원장 첫 인스턴스가 존재한다 — 안내도 갱신이 가리킬 실체이며, 없으면 안내도가 존재하지 않는 구조를 서술하게 된다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    test -f .ai/70_ledger/index.md || echo '위반: repo 원장 index.md 없음'
    test -d .ai/70_ledger/active || echo '위반: repo 원장 active/ 없음'
    test -d .ai/70_ledger/archive || echo '위반: repo 원장 archive/ 없음'
    ```

    </details>

---

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

<!--
이 블록은 모든 이슈 계획의 마지막 Task로 고정한다. 삭제하지 말 것.
audit은 L2 [QD] 보완 검증 — L1 [D] 결정적 게이트의 대체가 아니라 보완이다.
이 Task는 사용자가 직접 수행하며, 구현 AI는 자동으로 닫지 않는다.
-->

- [ ] 완료
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
    P=.ai/90_issues/active/issue-0061/issue-0061-plan.md
    S=.ai/90_issues/active/issue-0061/issue-0061-summary.md
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
    S=.ai/90_issues/active/issue-0061/issue-0061-summary.md
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
    S=.ai/90_issues/active/issue-0061/issue-0061-summary.md
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
