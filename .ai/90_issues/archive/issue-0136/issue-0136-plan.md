# Issue #136 실행계획 ai-workspace: IDE 도구 우선 규칙(ide-tools.md)을 dev 프로파일에 도입하고 init·update에서 안내도 규칙 표·context-loading에 연결한다

> 스펙: [issue-0136-spec.md](./issue-0136-spec.md)

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

---

## Tasks

> 검증 명령은 전부 repo 루트에서 `bash`로 실행한다. spec 항목을 가리키는 완료 기준은 그 항목의 접기 안 명령을 그대로 실행한다.
> 템플릿을 바꾸는 Task는 같은 Task에서 이 저장소 사본도 바꾼다(spec `## 전제`의 환경·관례). 그래서 각 Task 끝에서 `run-tests.sh` 전체가 통과해야 한다.
>
> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- [x] 완료
- **목표**: 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 코드 작성 전에 걷어낸다.
- **작업 내용**:
  1. spec/plan을 읽고, 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 나열한다. spec `## 전제`의 미결 2건(서버 이름 `idea` 표기, `build_project` 기본값)은 반드시 포함한다.
  2. 항목이 있으면 **코드를 쓰기 전에 사용자에게 질의**하고, 답변을 spec `## 전제 (Assumptions)` 섹션에 반영한 뒤 구현을 시작한다.
  3. 항목이 없으면 summary Task 0의 `수행 내용 요약`에 `전제 누락 없음` 한 줄을 기록하고 진행한다.
- **완료 기준**:
  - [ND] 나열한 항목이 전부 spec `## 전제 (Assumptions)`에 반영되어 미해소 0건이거나, summary Task 0에 `전제 누락 없음`이 기록된다  (검증: 사람 리뷰)  ← 강등 사유: 전제·모호점을 빠짐없이 나열했는지는 의미 판단이라 명령으로 환원 불가

---

### Task 1: 규칙 파일 작성과 dev 배포

- [x] 완료
- **목표**: dev 템플릿에 `ide-tools.md`를 두어 init이 dev에만 배포하고, 이 저장소에도 같은 사본을 둔다.
- **대상 요구사항**: R1, R2, R9
- **작업 내용**:
  1. `ai-workspace/templates/dev/.ai/10_rules/ide-tools.md`를 만든다. 1·2행은 SYNCED 머리글과 `<!-- 버전: 1.0.0 -->`, `## ` 제목 4개는 spec `## 전제`의 순서를 따른다.
  2. 본문은 이슈 범위와 spec `## 전제`의 정해진 값, Task 0 답변을 반영한다. `.ai/10_rules/writing-principles.md`의 서술 규칙을 따른다.
  3. 같은 파일을 이 저장소 `.ai/10_rules/ide-tools.md`로 복사한다.
- **완료 기준**:
  - [D] spec `### R1`·`### R2`의 `[D]` 항목 명령이 전부 출력 0건이다
    <details>
    <summary>검증 명령 — spec 해당 항목의 접기 안 명령, 출력 0건이면 통과</summary>

    - spec `### R1` 1개, `### R2` 3개 항목의 명령을 그대로 실행한다.
    </details>
  - [D] 이 저장소 `ide-tools.md` 사본이 템플릿과 같다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    cmp -s .ai/10_rules/ide-tools.md ai-workspace/templates/dev/.ai/10_rules/ide-tools.md || echo '위반: 사본 불일치'
    ```

    </details>
  - [D] 이 시점에도 `ai-workspace/tests/run-tests.sh`가 0 실패다 (회귀 방지)
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    ai-workspace/tests/run-tests.sh >/dev/null 2>&1 || echo '위반: 러너 실패'
    ```

    </details>

---

### Task 2: 안내도 규칙 표 행과 context-loading 라우팅

- [x] 완료
- **목표**: 규칙 표 행과 context-loading 코드 절이 `ide-tools.md`를 가리키게 하고, 이 저장소 사본과 러너 검사를 맞춘다.
- **대상 요구사항**: R3, R4, R7, R9
- **작업 내용**:
  1. `templates/dev/.ai/AI-CONTEXT.md` `## 프로젝트 규칙` 표에 `ide-tools.md` 행을 넣는다. 설명 셀은 spec `## 전제`의 조건을 따른다.
  2. 이 저장소 `.ai/AI-CONTEXT.md` 규칙 표에 같은 셀의 행을 넣는다(열 정렬 공백은 이 파일 표에 맞춘다).
  3. `templates/shared/.ai/10_rules/context-loading.md`의 `## 코드 수정·리뷰·분석 시` 번호 목록에 항목 하나를 넣고, 이 저장소 사본을 템플릿과 같게 맞춘다.
  4. `run-tests.sh`의 `ctx_violations`에 코드 라우팅 검사를 더한다. 코드 절에 `ide-tools.md` 목록 항목이 정확히 1개이고 파일 전체에서 1곳에만 나와야 통과한다. 통과 케이스 1개와, 항목을 지운 변형·다른 절로 옮긴 변형을 잡는 격추 케이스 2개를 넣는다. 케이스 설명에 `ide-tools`를 넣는다.
- **완료 기준**:
  - [D] spec `### R3`·`### R4`의 `[D]` 항목 명령과 `### R9` 두 항목 명령이 전부 출력 0건이다
    <details>
    <summary>검증 명령 — spec 해당 항목의 접기 안 명령, 출력 0건이면 통과</summary>

    - spec `### R3` 2개, `### R4` 1개, `### R9` 2개 항목의 명령을 그대로 실행한다.
    </details>
  - [D] 이 Task의 러너 케이스가 통과 1개·격추 2개 이상 실행되고 러너가 0 실패다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    out=$(ai-workspace/tests/run-tests.sh 2>&1) || echo '위반: 러너 실패'
    [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*context-loading.*ide-tools.* 통과|^ok +- .*ide-tools.*context-loading.* 통과')" -ge 1 ] || echo '위반: 라우팅 통과 케이스 없음'
    [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*context-loading.*ide-tools.* 격추|^ok +- .*ide-tools.*context-loading.* 격추')" -ge 2 ] || echo '위반: 라우팅 격추 케이스 2개 미만'
    ```

    - 설계 주의: 케이스 설명에 `context-loading`과 `ide-tools`를 함께 넣어 다른 Task의 `ide-tools` 케이스와 섞이지 않게 센다.
    </details>

---

### Task 3: update-1 복사

- [x] 완료
- **목표**: update-1이 dev 프로파일에서 `ide-tools.md`를 항상 최신본으로 덮어쓰고, `SKILL.md` 목록이 이를 반영한다.
- **대상 요구사항**: R5, R7
- **작업 내용**:
  1. `SKILL.md` update-1 코드 블록의 dev 분기에 `ide-tools.md` 덮어쓰기 복사를 넣는다(`testing-principles.md` 줄과 같은 형식). 분기 주석도 맞춘다.
  2. `SKILL.md` init-1의 `dev` 전용 파일 목록과 복사 정책 목록에 `- \`ide-tools.md\` (dev 전용): 버전 고정 — ...` 줄을 넣는다.
  3. `run-tests.sh`에 update-1 검사를 더한다. dev 신규 복사·dev 구버전 덮어쓰기·doc 미복사를 보는 통과 케이스 1개와, 복사 줄 삭제·`[ ! -f ... ] &&` 조건 추가 변형을 잡는 격추 케이스 2개를 넣는다(기존 테스트 원칙 update-1 검사와 같은 방식). 케이스 설명에 `ide-tools`와 `update-1`을 넣는다.
- **완료 기준**:
  - [D] spec `### R5`의 `[D]` 항목 명령 2개가 출력 0건이다
    <details>
    <summary>검증 명령 — spec 해당 항목의 접기 안 명령, 출력 0건이면 통과</summary>

    - spec `### R5` 2개 항목의 명령을 그대로 실행한다.
    </details>
  - [D] 이 Task의 러너 케이스가 통과 1개·격추 2개 이상 실행되고 러너가 0 실패다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    out=$(ai-workspace/tests/run-tests.sh 2>&1) || echo '위반: 러너 실패'
    [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*ide-tools.*update-1.* 통과|^ok +- .*update-1.*ide-tools.* 통과')" -ge 1 ] || echo '위반: update-1 통과 케이스 없음'
    [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*ide-tools.*update-1.* 격추|^ok +- .*update-1.*ide-tools.* 격추')" -ge 2 ] || echo '위반: update-1 격추 케이스 2개 미만'
    ```

    </details>

---

### Task 4: update-4 행 검사

- [x] 완료
- **목표**: dev 선언 안내도에서 `ide-tools.md` 행 누락을 헬퍼가 보고하고, `SKILL.md` 검사 표와 fixture가 이를 반영한다.
- **대상 요구사항**: R6, R7, R12
- **작업 내용**:
  1. `check-context.sh`의 `rows`에 dev 선언일 때 `.ai/10_rules/ide-tools.md`를 더하고, 머리말 주석(검사 대상 설명, `검사 표 14행 중 12행`)을 맞춘다.
  2. `SKILL.md` 멱등 보강 검사 표에 `` `## 프로젝트 규칙` 표의 `ide-tools.md` 행 `` 항목을 `testing-principles.md` 행 다음에 넣는다(검사 조건·조치는 `testing-principles.md` 행과 같은 형식, 표준 행 셀은 dev 템플릿 행과 같게). 본문의 항목 수 표기를 `14개 항목 중 12개`로, 섹션·표 행의 "아래 세 행 검사"를 행 수에 맞게 고친다.
  3. `SKILL.md` 멱등 보강 검사 표의 SSoT 선언 행(dev 문구 삽입·교체)과 건물 repo 선언 행(dev 전환 승인) 조치에서 `testing-principles.md` 행을 함께 넣는 문장을 `testing-principles.md`·`ide-tools.md` 두 행으로 늘린다. 헬퍼를 한 번만 실행해 선언을 보정한 실행에서는 새 행 검사가 돌지 않기 때문이다(계획 감사 F-1).
  4. `run-tests.sh`: 검사 표 항목 수 기대값을 14로 바꾸고, `ide-tools.md` 행 누락(dev 선언) 격추, 경로가 확장 열에만 있음 격추, doc 선언 무보고 통과, 비표준 선언 무보고 통과 케이스를 넣는다(기존 `testing-principles` 케이스와 같은 방식). 케이스 설명에 `ide-tools`를 넣는다.
  5. fixture `update4-idempotent`: `missing-rows` 입력에서 `ide-tools.md` 행을 빼 두고 기대 파일 표 끝에 넣는다. dev 골격을 쓰는 `no-rules-section`·`no-rules-table`·`legacy-two-col` 기대 파일에 행을 넣는다. README의 항목 수·케이스 표 설명을 맞춘다.
- **완료 기준**:
  - [D] spec `### R6`·`### R12`의 `[D]` 항목 명령이 전부 출력 0건이다
    <details>
    <summary>검증 명령 — spec 해당 항목의 접기 안 명령, 출력 0건이면 통과</summary>

    - spec `### R6` 4개, `### R12` 1개 항목의 명령을 그대로 실행한다.
    </details>
  - [D] 이 Task의 러너 케이스가 통과 2개·격추 2개 이상 실행되고 러너가 0 실패다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    out=$(ai-workspace/tests/run-tests.sh 2>&1) || echo '위반: 러너 실패'
    [ "$(printf '%s\n' "$out" | grep -cE '^ok +- ide-tools 행.* 통과')" -ge 2 ] || echo '위반: 행 검사 통과 케이스 2개 미만'
    [ "$(printf '%s\n' "$out" | grep -cE '^ok +- ide-tools 행.* 격추')" -ge 2 ] || echo '위반: 행 검사 격추 케이스 2개 미만'
    ```

    - 설계 주의: 이 Task 케이스 설명은 `ide-tools 행`으로 시작한다.
    </details>

---

### Task 5: 프로파일이 어긋난 복구의 dev 행 보강 (K-0018)

- [x] 완료
- **목표**: update-4가 섹션·표를 복구한 실행에서 dev 선언이면 dev 전용 표준 행 두 개를 함께 넣게 하고, 그 상태를 fixture로 남긴다.
- **대상 요구사항**: R11, R7
- **작업 내용**:
  1. `SKILL.md` 멱등 보강 검사 표의 `## 프로젝트 규칙` 섹션·표 행 조치에, 섹션 부재·표 부재로 복구했으면 헬퍼 보고와 별개로 본문 두 번째 줄이 dev 표준 선언일 때 `testing-principles.md`·`ide-tools.md` 표준 행을 함께 넣는다는 문장을 더한다.
  2. fixture `no-rules-section-mismatch`·`no-rules-table-mismatch` 입력·기대 파일을 만든다. 입력은 dev 표준 선언에 각각 섹션 부재·표 부재이고, 기대 파일은 doc 템플릿 골격으로 복구한 뒤 두 dev 행을 표 끝에 넣은 결과다.
  3. README 케이스 표에 두 케이스를 "dev 선언 + doc 프로파일 선택" 상태로 넣고, `run-tests.sh`에 두 입력의 `assert_fixture` 상태 판정을 더한다.
- **완료 기준**:
  - [D] spec `### R11`의 `[D]` 항목 명령 2개가 출력 0건이다
    <details>
    <summary>검증 명령 — spec 해당 항목의 접기 안 명령, 출력 0건이면 통과</summary>

    - spec `### R11` 2개 항목의 명령을 그대로 실행한다.
    </details>
  - [D] 러너가 두 fixture 상태 판정을 실행하고 0 실패다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    out=$(ai-workspace/tests/run-tests.sh 2>&1) || echo '위반: 러너 실패'
    for n in no-rules-section-mismatch no-rules-table-mismatch; do
      printf '%s\n' "$out" | grep -qE "^ok +- fixture 상태 판정\\($n\\)" || echo "위반: $n 판정 없음"
    done
    ```

    </details>

---

### Task 6: 명세 동기화와 결정 기록

- [x] 완료
- **목표**: `specs/ai-workspace.md`를 새 동작에 맞추고, 결정을 ADR 0029로 남긴다.
- **대상 요구사항**: R8, R10
- **작업 내용**:
  1. `.ai/40_domain/specs/ai-workspace.md` `## 요건`의 세 줄(파일 단위 최신본 목록, `context-loading.md` 요건, 멱등 보강 검사 요건)에 `ide-tools.md`와 K-0018 해소 동작을 반영한다. `## 관련 결정`에 ADR 0029 링크를 더한다.
  2. `.ai/50_adr/active/0029-<slug>.md`를 기존 ADR 형식으로 쓴다. 결정(dev 전용 버전 고정 단일 파일, 규칙 표 설명 열에 핵심 기준, context-loading 코드 절 라우팅, dev 선언 한정 행 검사, K-0018 해소 방식)과 근거(호출 0건 관측, 지연 로드, 두 도구 공통 진입점, local 쌍·전역 파일·`alwaysLoad`를 버린 이유)를 담는다.
  3. `.ai/50_adr/index.md` 파일 목록에 0029 행을 더한다.
- **완료 기준**:
  - [D] spec `### R8`·`### R10`의 `[D]` 항목 명령이 전부 출력 0건이다
    <details>
    <summary>검증 명령 — spec 해당 항목의 접기 안 명령, 출력 0건이면 통과</summary>

    - spec `### R8` 1개, `### R10` 1개 항목의 명령을 그대로 실행한다.
    </details>
  - [D] repo 전체 스킬 테스트가 통과한다 (회귀 방지)
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
    ```

    </details>

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

- [x] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **실행 주체**: **사용자가 직접** 수행한다. 구현 AI는 이 Task를 **자동으로 닫지 않으며**, `issue-audit`를 자동 실행하지도 않는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 전부 재실행해 통과를 확인한다.
  2. 구현을 수행한 모델과 **다른 벤더 모델**(최소 동급 이상 역량)로 사용자가 직접 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 사용자가 audit 결과(지적 사항·감사 모델·감사 effort)를 summary에 반영·기록한다. 발견사항 보정은 issue-work `--response`로 검토한다. **피드백 먼저, 항목별 승인 후에만** 앞 Task를 보정하며, 리포트를 받자마자 자동 보정하지 않는다.
- **완료 기준**:
  - [D] spec `완료의 정의`의 `[D]` 항목 검증 명령 전부 통과  (검증: 해당 명령 재실행)
  - [D] summary의 Task 헤더 집합이 plan과 일치한다. 블록 전체 누락·Task N 누락·빈 summary·두 경로 오기를 차단하며, 아래 두 게이트의 선행 조건이라 블록 자체가 없으면 그 두 게이트는 검사 대상이 사라져 그대로 통과한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    P=.ai/90_issues/archive/issue-0136/issue-0136-plan.md
    S=.ai/90_issues/archive/issue-0136/issue-0136-summary.md
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
    S=.ai/90_issues/archive/issue-0136/issue-0136-summary.md
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
    S=.ai/90_issues/archive/issue-0136/issue-0136-summary.md
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
