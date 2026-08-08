# Issue #80 실행계획 — git 스킬 3종: 산출물 형식 블록을 templates/로 분리

> 스펙: [issue-0080-spec.md](./issue-0080-spec.md)

---

## 설계 종료 게이트 (고정)

> **점검 질문**: 이 spec/plan만 보고, 작성에 참여하지 않은 쪽이 구현에 필요한 내용을 스스로 알 수 있는가?

- [x] 점검 완료
- **점검 대상** (작성 중 머릿속에만 있었던 것):
  - 코드베이스 관례 — 이 repo에서만 통하는 패턴·명명·배치 규칙
  - 버전·환경 제약 — 특정 버전·플랫폼·도구에 묶인 조건
  - 검토 후 버린 대안과 그 이유
  - 사용자와의 합의로만 정해진 값
- **발견 시 조치**: spec `## 전제 (Assumptions)`에 7건 기재 — 파일명·참조 문구 관례, 코드 펜스 해제 규칙, git-pr 이동 범위 한정, 내부 상호 참조 재작성, README 비대상 확인, install-skills 배포 포함 근거, 사용자 합의 값.

---

## Tasks

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

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

### Task 1: git-pr — "작성 예시 (템플릿)" 블록 분리

- [x] 완료
- **목표**: PR 본문 작성 예시 블록을 `git-pr/templates/pr-body-template.md`로 옮기고 SKILL.md는 참조만 남긴다.
- **작업 내용**:
  1. `git-pr/templates/pr-body-template.md`를 생성하고 "작성 예시 (템플릿)" 섹션의 형식 블록을 코드 펜스 해제 후 그대로 이관한다.
  2. SKILL.md의 해당 섹션을 템플릿 참조 문구로 대체한다 (형식은 spec 전제의 git-review 선례).
  3. 이동 블록을 가리키는 내부 상호 참조(`SKILL.md:215` "접기 구조는 아래 \"작성 예시\"를 따릅니다" 등)를 템플릿 파일 참조로 재작성한다.
- **완료 기준**:
  - [D] 템플릿 파일이 존재하고 SKILL.md가 참조하며, 앵커 `InventoryCache#get`이 SKILL.md 0건·템플릿 ≥1건
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    [ -f git-pr/templates/pr-body-template.md ] || echo '누락: 템플릿 파일'
    grep -L 'templates/pr-body-template\.md' git-pr/SKILL.md
    grep -n 'InventoryCache#get' git-pr/SKILL.md
    grep -L 'InventoryCache#get' git-pr/templates/pr-body-template.md
    ```

    </details>
  - [D] 옮긴 섹션을 가리키던 내부 상호 참조가 남지 않음
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    grep -n '아래 "작성 예시"' git-pr/SKILL.md
    ```

    </details>

---

### Task 2: git-qa — "출력 템플릿" 블록 분리

- [x] 완료
- **목표**: QA 체크리스트 출력 템플릿 블록을 `git-qa/templates/qa-checklist-template.md`로 옮기고 SKILL.md는 참조만 남긴다.
- **작업 내용**:
  1. `git-qa/templates/qa-checklist-template.md`를 생성하고 "출력 템플릿" 섹션의 형식 블록을 코드 펜스 해제 후 그대로 이관한다.
  2. SKILL.md의 해당 섹션을 템플릿 참조 문구로 대체한다.
  3. "결과 출력" 섹션의 "아래 템플릿 구조를 따름"·"아래 템플릿 구조로 업데이트합니다" 2곳을 템플릿 파일 참조로 재작성한다.
- **완료 기준**:
  - [D] 템플릿 파일이 존재하고 SKILL.md가 참조하며, 앵커 `^## 배포 대상 요약`이 SKILL.md 0건·템플릿 ≥1건
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    [ -f git-qa/templates/qa-checklist-template.md ] || echo '누락: 템플릿 파일'
    grep -L 'templates/qa-checklist-template\.md' git-qa/SKILL.md
    grep -n '^## 배포 대상 요약' git-qa/SKILL.md
    grep -L '^## 배포 대상 요약' git-qa/templates/qa-checklist-template.md
    ```

    </details>
  - [D] 옮긴 섹션을 가리키던 내부 상호 참조가 남지 않음
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    grep -n '아래 템플릿 구조' git-qa/SKILL.md
    ```

    </details>

---

### Task 3: git-review-context — "결과 기록" 형식 블록 분리

- [x] 완료
- **목표**: 리뷰 컨텍스트 결과 형식 블록을 `git-review-context/templates/review-context-template.md`로 옮기고 SKILL.md는 참조만 남긴다.
- **작업 내용**:
  1. `git-review-context/templates/review-context-template.md`를 생성하고 "결과 기록" 섹션의 형식 블록을 코드 펜스 해제 후 그대로 이관한다.
  2. SKILL.md의 형식 블록 자리를 템플릿 참조 문구로 대체한다 — 접기 안내 문장("호출 흐름 상세는 접고 …")은 규칙이라 SKILL.md에 유지한다.
- **완료 기준**:
  - [D] 템플릿 파일이 존재하고 SKILL.md가 참조하며, 앵커 `^# 리뷰 컨텍스트`가 SKILL.md 0건·템플릿 ≥1건
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    [ -f git-review-context/templates/review-context-template.md ] || echo '누락: 템플릿 파일'
    grep -L 'templates/review-context-template\.md' git-review-context/SKILL.md
    grep -n '^# 리뷰 컨텍스트' git-review-context/SKILL.md
    grep -L '^# 리뷰 컨텍스트' git-review-context/templates/review-context-template.md
    ```

    </details>

---

### Task 4: AI-CONTEXT.md 디렉토리 구조 트리 반영

- [x] 완료
- **목표**: 신규 `templates/` 3개 디렉토리를 repo 안내도의 디렉토리 구조 트리에 반영한다.
- **작업 내용**:
  1. `.ai/AI-CONTEXT.md` 디렉토리 구조 트리의 git-pr·git-qa·git-review-context 행 아래에 `templates/` 하위 행을 추가한다 (git-review 행의 기존 표기 형식을 따름).
  2. README.md는 디렉토리 구조 표기가 없어 대상 아님 (spec 전제 참조) — 변경하지 않는다.
- **완료 기준**:
  - [D] 트리에 3개 스킬의 `templates/` 하위 행이 존재
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    for s in git-pr git-qa git-review-context; do
      grep -A1 "── $s/" .ai/AI-CONTEXT.md | grep -q 'templates/' || echo "누락: $s"
    done
    ```

    - 설계 주의: 패턴 `── git-pr/`은 이름 끝 슬래시까지 고정해 `git-pr-feedback/` 행과 구분된다.
    </details>

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
    P=.ai/90_issues/archive/issue-0080/issue-0080-plan.md
    S=.ai/90_issues/archive/issue-0080/issue-0080-summary.md
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
    S=.ai/90_issues/archive/issue-0080/issue-0080-summary.md
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
    S=.ai/90_issues/archive/issue-0080/issue-0080-summary.md
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
