# Issue #82 실행계획 — 전체 스킬 templates/ 참조 표기 통일

> 스펙: [issue-0082-spec.md](./issue-0082-spec.md)

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
- **점검 결과**: 4건을 spec `## 전제 (Assumptions)`에 기록 — 설치본 미갱신(SSoT), 현황 조사 재검증·문자열 기준 특정, 버린 대안(장문 명시형 통일), 확정 문자열 준수 의무.

---

## Tasks

> **완료 기준 형식** — 본문에는 레벨 태그 + 보장 내용 한 문장(+ 강등 사유)만 두고, 검증 상세는 접기로 내립니다.
> 검증 명령은 전부 repo 루트 기준 경로로 적으며, `grep -rn ... .` 형태의 출력에 붙는 `./` 프리픽스가 grep 구현체에 따라 갈리는 점을 예외 패턴 앵커(`^(\./)?`)에 반영합니다.
>
> **검증 레벨** — `[D]` L1 결정적 / `[QD]` L2 준결정적 / `[ND]` L3 비결정적. 기본은 L1, 내릴 때마다 강등 사유를 적는다.

### Task 0 (고정): 구현 시작 게이트 — 전제·모호점 확인

- [x] 완료
- **목표**: 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 코드 작성 전에 걷어낸다.
- **작업 내용**:
  1. spec/plan을 읽고, 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 나열한다.
  2. 항목이 있으면 **코드를 쓰기 전에 사용자에게 질의**하고, 답변을 spec `## 전제 (Assumptions)` 섹션에 반영한 뒤 구현을 시작한다.
  3. 항목이 없으면 summary Task 0의 `수행 내용 요약`에 `전제 누락 없음` 한 줄을 기록하고 진행한다.
- **완료 기준**:
  - [ND] 나열한 항목이 전부 spec `## 전제 (Assumptions)`에 반영되어 미해소 0건이거나, summary Task 0에 `전제 누락 없음`이 기록된다  (검증: 사람 리뷰)  ← 강등 사유: 전제·모호점을 빠짐없이 나열했는지는 의미 판단이라 명령으로 환원 불가

---

### Task 1: 수식어 없는 templates/ 참조 보정

- [x] 완료
- **목표**: context-harvest·context-save·issue-work·readme-sync의 수식어 없는 `templates/` 참조에 `이 skill 디렉토리의` 기준을 명시한다 (이슈 완료 조건 1·3).
- **작업 내용**: 아래 확정 문자열대로 7행을 수정한다 (앞뒤 문맥은 그대로, 해당 문구만 교체).
  1. `context-harvest/SKILL.md` 5단계 — `` `templates/` 디렉토리의 템플릿을 참조하여 문서를 생성한다. `` → `` 이 skill 디렉토리의 `templates/` 아래 템플릿을 참조하여 문서를 생성한다. ``
  2. `context-harvest/SKILL.md` 산출물 템플릿 도입 문장 — `` `templates/` 디렉토리의 템플릿 파일이 단일 출처이며, 본문에 템플릿 내용을 중복 기재하지 않는다. `` → `` 이 skill 디렉토리의 `templates/` 아래 템플릿 파일이 단일 출처이며, 본문에 템플릿 내용을 중복 기재하지 않는다. 아래 표의 `templates/` 경로도 모두 이 skill 디렉토리 기준이다. `` (매핑 표 3행의 셀은 수정하지 않는다)
  3. `context-save/SKILL.md` — `` 현재 대화에서 다음을 추출하여 `templates/context-note-template.md`에 따라 작성한다. `` → `` 현재 대화에서 다음을 추출하여 이 skill 디렉토리의 `templates/context-note-template.md`에 따라 작성한다. ``
  4. `context-save/SKILL.md` — `` `templates/context-note-template.md`가 단일 출처이며, `` → `` 이 skill 디렉토리의 `templates/context-note-template.md`가 단일 출처이며, ``
  5. `issue-work/SKILL.md` — `` 없으면 `templates/issue-workflow-template.md`를 참조하여 생성한다. `` → `` 없으면 이 skill 디렉토리의 `templates/issue-workflow-template.md`를 참조하여 생성한다. ``
  6. `issue-work/SKILL.md` — `` 구체 형태는 `templates/issue-spec-template.md`·`templates/issue-plan-template.md`의 예시를 따릅니다. `` → `` 구체 형태는 이 skill 디렉토리의 `templates/issue-spec-template.md`·`templates/issue-plan-template.md`의 예시를 따릅니다. `` (한 행 두 참조에 수식어 1회)
  7. `readme-sync/SKILL.md` — `` `templates/README-template.md`를 읽어 다음 순서로 처리합니다. `` → `` 이 skill 디렉토리의 `templates/README-template.md`를 읽어 다음 순서로 처리합니다. ``
- **완료 기준**:
  - [D] 대상 4개 스킬에서 수식어 없는 `templates/` 참조가 매핑 표 행 3행 외에 0건이다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    grep -rn '`templates/' --include=SKILL.md context-harvest context-save issue-work readme-sync \
      | grep -v '이 skill 디렉토리의' \
      | grep -vE '^context-harvest/SKILL\.md:[0-9]+:\| `[0-9]+_[a-z]+/`'
    ```

    - 설계 주의: 디렉토리를 명시 나열하므로 출력에 `./` 프리픽스가 붙지 않는다 — 프리픽스를 선택적으로 받는 spec DoD 1번(전수 스캔)과 앵커가 다르다.
    </details>
  - [D] 매핑 표 도입 문장에 기준이 명시되고 예외 표 행은 정확히 3행이다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    grep -q '아래 표의 `templates/` 경로도 모두 이 skill 디렉토리 기준이다' context-harvest/SKILL.md \
      || echo '위반: 매핑 표 도입 문장에 기준 명시 누락'
    c=$(grep -cE '^\| `[0-9]+_[a-z]+/` \([^)]*\) \| `templates/[0-9]+_[a-z]+-template\.md` \|$' context-harvest/SKILL.md)
    [ "$c" -eq 3 ] || echo "위반: 매핑 표 행 수 $c ≠ 3"
    ```

    </details>

---

### Task 2: ai-workspace 한글 수식어 정렬

- [x] 완료
- **목표**: `ai-workspace/SKILL.md`의 `이 스킬 디렉토리의`를 다수 표기 `이 skill 디렉토리의`로 정렬한다 (이슈 완료 조건 2).
- **작업 내용**:
  1. `ai-workspace/SKILL.md` — `` 이 스킬 디렉토리의 `templates/` 아래 파일을 기준으로 구성합니다. `` → `` 이 skill 디렉토리의 `templates/` 아래 파일을 기준으로 구성합니다. ``
  2. 같은 파일의 장문 명시형 `` 이 스킬 파일의 위치(`SKILL.md`가 있는 디렉토리)를 기준으로 `` 는 수정하지 않는다 (범위 밖 — 이미 더 명시적).
- **완료 기준**:
  - [D] `이 스킬 디렉토리의` 표기가 전체 SKILL.md에 잔존 0건이다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    grep -rn '이 스킬 디렉토리의' --include=SKILL.md .
    ```

    </details>
  - [D] 장문 명시형 표기가 그대로 1건 남아 있다 (범위 밖 오수정 차단)
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    c=$(grep -c '이 스킬 파일의 위치(`SKILL\.md`가 있는 디렉토리)' ai-workspace/SKILL.md)
    [ "$c" -eq 1 ] || echo "위반: 장문 명시형 표기 $c건 ≠ 1건"
    ```

    </details>

---

### Task 3: 전수 재검증

- [x] 완료
- **목표**: repo 전체 기준으로 표기 통일과 변경 범위를 재검증한다 (이슈 완료 조건 4).
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 4개 항목 검증 명령을 전부 실행한다.
  2. 결과(각 명령 출력 0건/빈 diff)를 summary Task 3 블록에 기록한다.
- **완료 기준**:
  - [D] spec `완료의 정의`의 `[D]` 항목 검증 명령 전부 통과  (검증: 해당 명령 재실행 — spec 접기의 명령 4종, 각각 출력 0건이면 통과)

---

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

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
    P=.ai/90_issues/archive/issue-0082/issue-0082-plan.md
    S=.ai/90_issues/archive/issue-0082/issue-0082-summary.md
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
    S=.ai/90_issues/archive/issue-0082/issue-0082-summary.md
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
    S=.ai/90_issues/archive/issue-0082/issue-0082-summary.md
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
