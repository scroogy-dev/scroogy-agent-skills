# Issue #140 스펙 issue-work: 요구사항이 5개 이상이면 spec·이슈 본문·승인 요청에서 포함은 내용별·제외는 사유별로 묶는다

## 목표 (Goal)

요구사항이 많은 spec과 이슈 본문에서도 포함·제외 목록을 주제별로 훑어 읽을 수 있다.

---

## 요구사항 (Requirements)

**포함**

- R1: spec의 포함 항목이 5개 이상이면 내용(기능 영역)별 묶음으로 나눠 쓰고, 5개 미만이면 지금처럼 한 목록으로 쓴다. 묶음 제목은 `#### <묶음 이름>` 형식이고 이름은 기능 영역을 가리키는 명사구이며, 이슈 본문의 포함이 묶여 있으면 spec은 그 묶음 이름을 이어 쓴다. R 번호는 묶음과 무관한 식별자라 다시 매기지 않고, 나중에 더한 R은 다음 번호를 받아 맞는 묶음에 들어간다.
- R2: spec의 제외 항목이 5개 이상이면 사유별 묶음(`#### 보류`, `#### 대체`, `#### 불필요` 순서, 항목이 없는 사유는 생략)으로 나눠 쓰고, 5개 미만이면 지금처럼 한 목록으로 쓴다.
- R3: spec의 R 항목은 항목 수와 무관하게 첫 줄을 한 문장으로 쓰고, 세부 조건과 근거 표기(이슈 본문 근거 없음 등)는 그 항목의 하위 목록에 둔다. 하위 목록의 세부 조건도 그 R의 요구사항이다. `(함께 해소: K-<번호>)` 표기는 첫 줄 끝에 그대로 둔다.
- R4: 이슈 본문 템플릿의 범위(포함·제외)에도 같은 5개 기준을 적용해, 포함은 내용별 `#### <묶음 이름>` 묶음으로, 제외는 사유별 묶음으로 나눠 쓴다.
- R5: 3-1 승인 요청의 대화 제시는 포함·제외 목록을 spec의 묶음대로 나눠 보여 주고 R은 첫 줄만 보여 준다(하위 목록은 파일에서 확인한다). 이슈 본문에 근거 없는 요구사항을 따로 표시하는 규칙은 그대로 둔다.
- R6: `--create` 요약 제시의 대화 제시는 포함·제외 목록을 이슈 본문 초안의 묶음대로 나눠 보여 주고 항목은 첫 줄만 보여 준다(하위 목록은 파일에서 확인한다).
- R7: 묶음 제목과 하위 목록을 쓴 spec이 추적성 검사(`check-plan.sh --trace`)를 통과하고, 테스트(`issue-audit/tests/run-tests.sh`)가 이를 지킨다.
- R8: issue-work 구조 검사(`issue-work/tests/run-tests.sh`)가 새 규칙 조항(spec 템플릿, 이슈 본문 템플릿, SKILL.md 3-1·`--create` 2단계)의 소실을 잡는다.
- R9: 요구사항 형식과 승인 요청을 서술하는 문서(명세 `.ai/40_domain/specs/issue-workflow.md`, ADR 0016, ADR 0026, issue-work 코드맵)가 바뀐 내용과 맞는다.
- R10: spec과 이슈 본문의 포함·제외 표지를 `### 포함`·`### 제외` 제목으로 써서 `#### ` 묶음 제목보다 한 단계 위로 보이게 한다. 추적성 헬퍼(`check-plan.sh --trace`)는 `### 포함`을 포함 목록의 시작으로 읽고 이미 쓴 spec의 `**포함**` 표지도 계속 읽으며, 행 끝에 닫힌 주석이 붙은 표지도 같은 표지로 읽는다. issue-work 구조 검사(`issue-work/tests/run-tests.sh`)는 두 템플릿의 표지가 제목인지 확인한다. 명세 `.ai/40_domain/specs/issue-workflow.md`, ADR 0016, issue-audit 코드맵 `.ai/60_codebase/issue-audit/plan-audit-call-flow.md`가 새 표지와 헬퍼의 두 표기 인식을 서술한다. (함께 해소: K-0023)

**제외**

- R 줄에 짧은 이름 두기: 불필요(완료의 정의 그룹 제목과 같은 이름이 두 곳에 생김)
- 완료의 정의 섹션 묶기: 불필요(지금 구조로 읽는 데 문제 없음)
- 기준 수 이상인데 묶지 않은 spec을 헬퍼로 잡는 검사: 보류(규칙이 지켜지지 않는 사례를 본 뒤 판단)
- archive에 있는 기존 spec 다시 쓰기: 불필요(새로 쓰는 spec부터 적용)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

> 검증 명령은 모두 repo 루트에서 bash로 실행한다. 명령 안의 따옴표 속 문구는 조항에 그대로 쓰는 앵커 문구다(전제 1).

### R1: 포함 묶음

- [ ] [D]  spec 템플릿 요구사항 안내의 `포함 묶음` 행이 5개 이상이면 `#### <묶음 이름>` 제목으로 묶고 5개 미만이면 묶지 않는다는 규칙과 묶음 이름 규칙을 담는다 (AC1)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-spec-template.md
  sec() { awk '/^## 요구사항 \(Requirements\)$/ { s = 1; next } /^## / { s = 0 } s' "$T"; }
  row() { sec | awk -v l="- $1: " 'index($0, l) == 1 { s = 1; print; next } s && /^  / { print; next } { s = 0 }'; }
  need() { row "$1" | grep -qF -- "$2" || echo "위반: [$1] 행에 [$2] 없음"; }
  [ "$(sec | grep -c '^- 포함 묶음: ')" -eq 1 ] || echo '위반: 포함 묶음 행이 1개가 아님'
  need '포함 묶음' '포함 항목이 5개 이상이면'
  need '포함 묶음' '`#### <묶음 이름>`'
  need '포함 묶음' '5개 미만이면 묶지 않는다'
  need '포함 묶음' '기능 영역을 가리키는 명사구'
  ```

  - 설계 주의: `sec`은 요구사항 섹션만, `row`는 그 안에서 `- <라벨>: `로 시작하는 행과 두 칸 들여쓴 이어지는 행만 읽는다. 같은 문구가 다른 행이나 다른 섹션에 있어도 세지 않는다.
  </details>
- [ ] [D]  같은 행이 R 번호를 다시 매기지 않고 나중에 더한 R은 다음 번호로 맞는 묶음에 넣는다는 규칙을 담는다 (AC2)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-spec-template.md
  sec() { awk '/^## 요구사항 \(Requirements\)$/ { s = 1; next } /^## / { s = 0 } s' "$T"; }
  row() { sec | awk -v l="- $1: " 'index($0, l) == 1 { s = 1; print; next } s && /^  / { print; next } { s = 0 }'; }
  need() { row "$1" | grep -qF -- "$2" || echo "위반: [$1] 행에 [$2] 없음"; }
  need '포함 묶음' '다시 매기지 않'
  need '포함 묶음' '다음 번호를 받아 맞는 묶음'
  ```

  </details>
- [ ] [D]  같은 행이 이슈 본문의 포함이 묶여 있으면 그 묶음 이름을 이어 쓴다는 규칙을 담는다 (AC3)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-spec-template.md
  sec() { awk '/^## 요구사항 \(Requirements\)$/ { s = 1; next } /^## / { s = 0 } s' "$T"; }
  row() { sec | awk -v l="- $1: " 'index($0, l) == 1 { s = 1; print; next } s && /^  / { print; next } { s = 0 }'; }
  need() { row "$1" | grep -qF -- "$2" || echo "위반: [$1] 행에 [$2] 없음"; }
  need '포함 묶음' '이슈 본문의 포함이 묶여 있으면'
  need '포함 묶음' '묶음 이름을 이어 쓴다'
  ```

  </details>
- [ ] [QD] `포함 묶음` 행의 문장이 AC1~AC3의 조건과 결과를 어긋나지 않게 잇는다 (AC1, AC2, AC3)  (검증: 최종 감사에서 다른 AI가 AC 문장과 조항을 대조)  ← 강등 사유: 앵커 문구가 있어도 문장이 조건과 결과를 바르게 잇는지는 명령으로 판정할 수 없다

### R2: 제외 묶음

- [ ] [D]  spec 템플릿 요구사항 안내의 `제외 묶음` 행이 5개 이상이면 보류, 대체, 불필요 순서의 사유별 묶음으로 나누고 5개 미만이면 묶지 않으며 항목이 없는 사유는 생략한다는 규칙을 담는다 (AC4)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-spec-template.md
  sec() { awk '/^## 요구사항 \(Requirements\)$/ { s = 1; next } /^## / { s = 0 } s' "$T"; }
  row() { sec | awk -v l="- $1: " 'index($0, l) == 1 { s = 1; print; next } s && /^  / { print; next } { s = 0 }'; }
  need() { row "$1" | grep -qF -- "$2" || echo "위반: [$1] 행에 [$2] 없음"; }
  [ "$(sec | grep -c '^- 제외 묶음: ')" -eq 1 ] || echo '위반: 제외 묶음 행이 1개가 아님'
  need '제외 묶음' '제외 항목이 5개 이상이면'
  need '제외 묶음' '`#### 보류`, `#### 대체`, `#### 불필요` 순서'
  need '제외 묶음' '5개 미만이면 묶지 않는다'
  need '제외 묶음' '항목이 없는 사유는 생략'
  ```

  </details>
- [ ] [QD] `제외 묶음` 행의 문장이 AC4의 조건과 결과를 어긋나지 않게 잇는다 (AC4)  (검증: 최종 감사에서 다른 AI가 AC 문장과 조항을 대조)  ← 강등 사유: R1의 `[QD]`와 같다

### R3: R 하위 목록

- [ ] [D]  spec 템플릿 요구사항 안내가 R 첫 줄은 한 문장으로 쓰고 세부 조건과 근거 표기는 하위 목록에 둔다고 정하며, `근거 표기` 행에 옛 위치(문장 끝)가 남지 않는다 (AC5)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-spec-template.md
  sec() { awk '/^## 요구사항 \(Requirements\)$/ { s = 1; next } /^## / { s = 0 } s' "$T"; }
  row() { sec | awk -v l="- $1: " 'index($0, l) == 1 { s = 1; print; next } s && /^  / { print; next } { s = 0 }'; }
  need() { row "$1" | grep -qF -- "$2" || echo "위반: [$1] 행에 [$2] 없음"; }
  need '포함' '첫 줄은 한 문장'
  need '포함' '세부 조건과 근거 표기는 그 항목의 하위 목록에'
  need '근거 표기' '하위 목록'
  row '근거 표기' | grep -qF '문장 끝' && echo '위반: 근거 표기 행에 옛 위치(문장 끝)가 남음'
  ```

  </details>
- [ ] [D]  spec 템플릿의 포함 예시가 R 항목 바로 아래에 하위 목록 줄을 보여 준다 (AC5)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-spec-template.md
  sec() { awk '/^## 요구사항 \(Requirements\)$/ { s = 1; next } /^## / { s = 0 } s' "$T"; }
  sec | awk '/^### 포함$/ { i = 1; next } /^### / { i = 0 }
             i && p ~ /^- R[0-9]+: / && /^  - / { n++ } { p = $0 }
             END { if (n < 1) print "위반: 포함 예시의 R 항목 아래에 하위 목록 없음" }'
  ```

  </details>
- [ ] [D]  같은 안내가 하위 목록의 세부 조건도 그 R의 요구사항이라고 적고, `(함께 해소: K-<번호>)` 표기 위치를 R 첫 줄 끝으로 적는다 (AC6)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-spec-template.md
  sec() { awk '/^## 요구사항 \(Requirements\)$/ { s = 1; next } /^## / { s = 0 } s' "$T"; }
  row() { sec | awk -v l="- $1: " 'index($0, l) == 1 { s = 1; print; next } s && /^  / { print; next } { s = 0 }'; }
  need() { row "$1" | grep -qF -- "$2" || echo "위반: [$1] 행에 [$2] 없음"; }
  need '포함' '하위 목록의 세부 조건도 그 R의 요구사항'
  need '함께 해소 표기' '첫 줄 끝에 `(함께 해소: K-<번호>)`'
  ```

  </details>
- [ ] [QD] `포함`·`근거 표기`·`함께 해소 표기` 행의 문장이 AC5·AC6의 규칙을 어긋나지 않게 서술한다 (AC5, AC6)  (검증: 최종 감사에서 다른 AI가 AC 문장과 조항을 대조)  ← 강등 사유: R1의 `[QD]`와 같다

### R4: 이슈 본문 템플릿 묶음

- [ ] [D]  이슈 본문 템플릿의 범위 안내가 포함은 5개 이상이면 `#### <묶음 이름>` 제목으로, 제외는 5개 이상이면 보류, 대체, 불필요 순서의 사유별로 묶고 5개 미만이면 묶지 않는다고 정하며, 하위 목록은 세부 조건 자리로 안내한다 (AC7)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  B=issue-work/templates/issue-body-template.md
  scope() { awk '/^## 범위$/ { s = 1; next } /^## / { s = 0 } s' "$B"; }
  has() { scope | grep -qF -- "$1" || echo "위반: 범위 안내에 [$1] 없음"; }
  has '포함 항목이 5개 이상이면'
  has '`#### <묶음 이름>`'
  has '제외 항목이 5개 이상이면'
  has '`#### 보류`, `#### 대체`, `#### 불필요` 순서'
  has '항목이 없는 사유는 생략'
  has '세부 조건은 하위 목록에 둔다'
  [ "$(scope | grep -oF '5개 미만이면 묶지 않는다' | wc -l | tr -d ' ')" -eq 2 ] || echo '위반: 5개 미만 규칙이 포함·제외 두 곳(2회)이 아님'
  scope | grep -qF '관련 항목은 하위 목록으로 묶어도 된다' && echo '위반: 하위 목록으로 묶는다는 옛 문장이 남음'
  ```

  - 설계 주의: 범위 섹션(`## 범위`부터 다음 `## ` 앞까지)만 읽어, 규칙 문장을 다른 섹션으로 옮기면 실패한다. 하위 목록 문장 두 건은 전제 4의 해석을 판정한다.
  </details>
- [ ] [QD] 범위 안내의 문장이 AC7의 조건과 결과를 어긋나지 않게 잇는다 (AC7)  (검증: 최종 감사에서 다른 AI가 AC 문장과 조항을 대조)  ← 강등 사유: R1의 `[QD]`와 같다

### R5: 승인 요청 제시

- [ ] [D]  `issue-work/SKILL.md` 3-1이 승인 요청에서 포함·제외 목록을 spec의 묶음대로 나눠 보여 주고 R은 첫 줄만 보여 준다고 정한다 (AC8)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  s31() { awk '/^   - \*\*3-1\. 승인 전/ { s = 1 } /^   - \*\*3-2\. 승인 후/ { s = 0 } s' "$S"; }
  [ -n "$(s31)" ] || echo '위반: 3-1 범위 없음'
  for p in 'spec의 묶음대로 나눠 보여 주고' 'R은 첫 줄만 보여 준다'; do
    s31 | grep -qF -- "$p" || echo "위반: 3-1에 [$p] 없음"
  done
  ```

  - 설계 주의: 3-1 범위(`3-1. 승인 전` 행부터 `3-2. 승인 후` 행 앞까지)만 읽는다. 범위가 비면 문구 검사가 공집합 통과가 되므로 범위 실재를 먼저 판정한다.
  </details>
- [ ] [D]  3-1에 이슈 본문에 근거 없는 요구사항을 목록에서 따로 표시하고 확정·제외를 질의하는 규칙이 그대로 있다 (AC8) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  s31() { awk '/^   - \*\*3-1\. 승인 전/ { s = 1 } /^   - \*\*3-2\. 승인 후/ { s = 0 } s' "$S"; }
  [ -n "$(s31)" ] || echo '위반: 3-1 범위 없음'
  for p in '이슈 본문에 근거가 없는' '목록에서 따로 표시하고, 추가로 확정할지 제외할지 질의한다'; do
    s31 | grep -qF -- "$p" || echo "위반: 3-1에 [$p] 없음"
  done
  ```

  </details>
- [ ] [QD] 3-1의 새 조항이 기존 승인 요청 조항(경로·목표 한 줄·포함·제외만 제시, 전문 미출력)과 어긋나지 않는다 (AC8)  (검증: 최종 감사에서 다른 AI가 3-1 조항을 읽고 채점)  ← 강등 사유: 조항끼리 뜻이 부딪히는지는 명령으로 판정할 수 없다

### R6: --create 요약 제시

- [ ] [D]  `issue-work/SKILL.md` `--create` 2단계 요약 제시가 포함·제외 목록을 초안의 묶음대로 나눠 보여 주고 항목은 첫 줄만 보여 준다고 정한다 (AC13)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  st() { awk '/^### `--create`$/ { f = 1; next } f && /^###? / { exit } f' "$S" \
           | awk '/^  [0-9]+\. \*\*요약 제시\*\*/ { s = 1; print; next } s && /^  [0-9]+\. / { exit } s'; }
  [ -n "$(st)" ] || echo '위반: --create 요약 제시 단계 범위 없음'
  for p in '초안의 묶음대로 나눠 보여 주고' '항목은 첫 줄만 보여 준다'; do
    st | grep -qF -- "$p" || echo "위반: 요약 제시 단계에 [$p] 없음"
  done
  ```

  - 설계 주의: `--create` 절의 요약 제시 단계(다음 번호 단계 앞까지)만 읽어, 조항을 다른 단계로 옮기면 실패한다.
  </details>
- [ ] [QD] 요약 제시의 새 조항이 같은 단계의 기존 조항(제시 항목, 분할 권고, AC 대응 점검)과 어긋나지 않는다 (AC13)  (검증: 최종 감사에서 다른 AI가 요약 제시 단계를 읽고 채점)  ← 강등 사유: R5의 `[QD]`와 같다

### R7: 추적성 검사

- [ ] [D]  `issue-audit/tests/run-tests.sh`가 요구사항 묶음 fixture(spec·plan)로 `check-plan.sh --trace`의 통과와 격추를 판정하는 케이스를 실행하고 0 실패로 끝난다 (AC9)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  R=issue-audit/tests/run-tests.sh
  out=$("$R" 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- trace: 요구사항 묶음.* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- trace: 요구사항 묶음.* 격추')" -ge 2 ] \
    || echo '위반: 테스트 실패 또는 요구사항 묶음 케이스(통과 1·격추 2 이상) 미실행'
  ```

  - 설계 주의: 러너 종료 코드만 보면 케이스를 넣기 전에도 통과한다. 러너 출력의 `ok` 행을 `통과`·`격추` 낱말별로 세어 케이스가 실제로 실행됐을 때만 통과한다(케이스 설명 규칙은 전제 7).
  - 격추 2건은 묶음 제목을 굵은 글씨로 바꾼 spec과, 뒤 묶음에 있는 R의 Task 연결을 지운 plan이다(plan Task 5).
  </details>
- [ ] [QD] 위 통과 케이스의 spec fixture가 포함 목록의 `#### ` 묶음 제목, R 하위 목록, 번호 순서가 섞인 R을 모두 담고 plan fixture가 그 R을 빠짐없이 대상으로 삼는다 (AC9)  (검증: 최종 감사에서 다른 AI가 러너의 fixture를 읽고 채점)  ← 강등 사유: fixture가 세 요소를 담는지는 러너 출력 행에 드러나지 않는다

### R8: 조항 소실 검사

- [ ] [D]  spec 템플릿, 이슈 본문 템플릿, SKILL.md 3-1, SKILL.md `--create` 2단계 가운데 한 곳에서 묶음 규칙이나 하위 목록 규칙 문구를 지우면 `issue-work/tests/run-tests.sh`가 실패한다 (AC10)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과 (러너를 10회 병렬 실행, 1~2분)</summary>

  ```bash
  tmp=$(mktemp -d)
  mut() {  # <번호> <issue-work 안 파일> <지울 문구>
    local w="$tmp/w$1"
    cp -R issue-work "$w"
    awk -v s="$3" '{ while ((i = index($0, s))) $0 = substr($0, 1, i - 1) substr($0, i + length(s)); print }' "issue-work/$2" > "$w/$2"
    if cmp -s "issue-work/$2" "$w/$2"; then echo "위반: $2 에 [$3] 가 없어 지울 수 없음"
    elif "$w/tests/run-tests.sh" >/dev/null 2>&1; then echo "위반: $2 에서 [$3] 를 지워도 러너 통과"; fi
  }
  { cp -R issue-work "$tmp/w0" && "$tmp/w0/tests/run-tests.sh" >/dev/null 2>&1 || echo '위반: 변형 전 사본에서 러너 실패'; } &
  mut 1 templates/issue-spec-template.md '포함 항목이 5개 이상이면' &
  mut 2 templates/issue-spec-template.md '제외 항목이 5개 이상이면' &
  mut 3 templates/issue-spec-template.md '세부 조건과 근거 표기는 그 항목의 하위 목록에' &
  mut 4 templates/issue-body-template.md '포함 항목이 5개 이상이면' &
  mut 5 templates/issue-body-template.md '세부 조건은 하위 목록에 둔다' &
  mut 6 SKILL.md 'spec의 묶음대로 나눠 보여 주고' &
  mut 7 SKILL.md 'R은 첫 줄만 보여 준다' &
  mut 8 SKILL.md '초안의 묶음대로 나눠 보여 주고' &
  mut 9 SKILL.md '항목은 첫 줄만 보여 준다' &
  wait
  rm -rf "$tmp"
  ```

  - 설계 주의: `issue-work/` 사본에서 문구 하나를 지우고 사본의 러너를 돌린다. 변형 전 사본이 통과하고 변형 사본이 실패해야 그 문구의 삭제를 러너가 잡은 것이다. 문구가 파일에 없으면 변형이 일어나지 않으므로 위반으로 센다(구현 전에는 이 경로로 실패한다).
  - 러너는 `issue-work/` 안의 파일만 읽어 사본에서 그대로 돈다. 러너 1회가 약 20초라 병렬로 실행하며, 도구의 명령 제한 시간이 2분보다 짧으면 늘려서 실행한다.
  - 문구 9개는 자리 4곳마다 묶음 규칙과 하위 목록(첫 줄) 규칙을 하나 이상 고른 것이다. 문구별 전수 삭제 반례는 러너 안의 케이스가 맡는다(plan Task 1·3·4).
  </details>

### R9: 문서 정합

- [ ] [D]  명세, ADR 0016, ADR 0026, issue-work 코드맵 2건이 5개 기준 묶음, 하위 목록, 묶음대로 나눠 첫 줄만 보여 주는 제시를 언급하고, 명세와 두 ADR이 이슈 #140을 근거로 적는다 (AC11)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  chk() { grep -qF -- "$2" "$1" || echo "위반: $1 에 [$2] 없음"; }
  D=.ai/40_domain/specs/issue-workflow.md
  A16=.ai/50_adr/active/0016-spec-requirements-layer-and-plan-audit.md
  A26=.ai/50_adr/active/0026-acceptance-criteria-across-issue-spec-pr.md
  C1=.ai/60_codebase/issue-work/start-call-flow.md
  C2=.ai/60_codebase/issue-work/create-call-flow.md
  for f in "$D" "$A16"; do chk "$f" '5개 이상'; chk "$f" '하위 목록'; chk "$f" '묶음대로'; chk "$f" '첫 줄만'; done
  chk "$A26" '5개 이상'; chk "$A26" '묶음대로'; chk "$A26" '첫 줄만'
  for f in "$D" "$A16" "$A26"; do chk "$f" '#140'; done
  for f in "$C1" "$C2"; do chk "$f" '묶음대로'; chk "$f" '첫 줄만'; done
  ```

  </details>
- [ ] [D]  코드맵 2건의 frontmatter가 기준 브랜치와 같다 (AC11) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in .ai/60_codebase/issue-work/start-call-flow.md .ai/60_codebase/issue-work/create-call-flow.md; do
    diff <(git show "main:$f" | sed -n '1,5p') <(sed -n '1,5p' "$f") >/dev/null || echo "위반: $f frontmatter 가 main 과 다름"
  done
  ```

  - 설계 주의: 표지(`last_synced`·`source_hash`)는 구현 커밋 뒤 code-map sync가 갱신한다(전제 13, 2026-11-11 사용자 확정). 본문만 고쳤는지를 frontmatter 5행 대조로 본다. 구현 전에도 통과하는 것이 정상이다.
  </details>
- [ ] [QD] 다섯 문서의 서술이 바뀐 템플릿·SKILL.md 조항과 뜻이 같고, 두 ADR은 결정 항목을 제자리에서 고친 뒤 근거에 변경 날짜·이슈 번호·경위를 적었다 (AC11)  (검증: 최종 감사에서 다른 AI가 문서와 조항을 대조)  ← 강등 사유: 낱말이 있어도 서술이 조항과 같은 뜻인지는 명령으로 판정할 수 없다

### R10: 포함·제외 표지

- [ ] [D]  spec 템플릿 요구사항 섹션과 이슈 본문 템플릿 범위 섹션에 `### 포함`·`### 제외` 표지가 하나씩 이 순서로 있고 굵은 글씨 표지 행은 없다 (AC14)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  lab() {  # <파일> <섹션 헤더>
    awk -v h="$2" -v f="$1" '
      /^## / { s = ($0 == h) }
      /^### 포함$/ { if (s) { i++; ia = NR } else o++ }
      /^### 제외$/ { if (s) { e++; ea = NR } else o++ }
      /^\*\*(포함|제외)\*\*/ { b++ }
      END { if (i != 1 || e != 1) print "위반: " f " 표지 제목 포함 " i + 0 "개·제외 " e + 0 "개 (기대 각 1개)"
            else if (ia > ea) print "위반: " f " 표지 순서 역전"
            if (o) print "위반: " f " 표지 제목이 섹션 밖에 " o "개"
            if (b) print "위반: " f " 굵은 글씨 표지 " b "행 남음" }' "$1"
  }
  lab issue-work/templates/issue-spec-template.md '## 요구사항 (Requirements)'
  lab issue-work/templates/issue-body-template.md '## 범위'
  ```

  </details>
- [ ] [D]  두 템플릿 가운데 한 곳의 표지 하나를 굵은 글씨로 되돌리면 `issue-work/tests/run-tests.sh`가 실패한다 (AC14)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과 (러너를 5회 병렬 실행, 1분 안팎)</summary>

  ```bash
  tmp=$(mktemp -d)
  rev() {  # <번호> <issue-work 안 파일> <표지 이름>
    local w="$tmp/w$1"
    cp -R issue-work "$w"
    awk -v l="### $3" -v b="**$3**" '$0 == l { $0 = b } { print }' "issue-work/$2" > "$w/$2"
    if cmp -s "issue-work/$2" "$w/$2"; then echo "위반: $2 에 [### $3] 행이 없어 되돌릴 수 없음"
    elif "$w/tests/run-tests.sh" >/dev/null 2>&1; then echo "위반: $2 의 [### $3] 를 굵은 글씨로 되돌려도 러너 통과"; fi
  }
  { cp -R issue-work "$tmp/w0" && "$tmp/w0/tests/run-tests.sh" >/dev/null 2>&1 || echo '위반: 변형 전 사본에서 러너 실패'; } &
  rev 1 templates/issue-spec-template.md 포함 &
  rev 2 templates/issue-spec-template.md 제외 &
  rev 3 templates/issue-body-template.md 포함 &
  rev 4 templates/issue-body-template.md 제외 &
  wait
  rm -rf "$tmp"
  ```

  - 설계 주의: R8의 변형 명령과 같은 방식이다. 표지 행이 없으면 변형이 일어나지 않으므로 위반으로 센다(구현 전에는 이 경로로 실패한다).
  </details>
- [ ] [D]  `issue-audit/tests/run-tests.sh`가 새 표지·옛 표지·행 끝 닫힌 주석이 붙은 두 표지의 `--trace` 통과, `### 제외`에서 포함 목록이 끝나는 통과, 표지가 아닌 `#### 포함` 제목의 격추 케이스를 실행하고 0 실패로 끝난다 (AC15, AC17)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  R=issue-audit/tests/run-tests.sh
  out=$("$R" 2>&1) || echo '위반: issue-audit 러너 실패'
  oks=$(printf '%s\n' "$out" | sed -n 's/^ok  *- //p')
  for d in 'trace: 포함 표지 ### 포함 통과' \
           'trace: 포함 표지 **포함** 통과' \
           'trace: 포함 표지 ### 포함 행 끝 닫힌 주석 통과' \
           'trace: 포함 표지 **포함** 행 끝 닫힌 주석 통과' \
           'trace: 포함 표지 ### 제외에서 포함 목록 끝남 통과' \
           'trace: 포함 표지 #### 포함 제목 격추'; do
    printf '%s\n' "$oks" | grep -qxF -- "$d" || echo "위반: [$d] 케이스가 ok 로 실행되지 않음"
  done
  ```

  - 설계 주의: 러너 종료 코드만 보면 케이스를 넣기 전에도 통과한다. 케이스 설명 6개를 글자 그대로 찾아 실제로 실행됐을 때만 통과한다(설명 규칙은 전제 7).
  - `### 제외` 케이스는 제외 아래에 `- R<n>: ` 형식 줄을 둔 spec이 통과하는지 본다. 포함 목록이 `### 제외`에서 끝나지 않으면 그 줄이 R로 읽혀 `DoD 없는 R`이 나온다.
  </details>
- [ ] [D]  명세, ADR 0016, issue-audit 코드맵이 새 표지 `### 포함`과 옛 표지 `**포함**`을 함께 언급한다 (AC16)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  chk() { grep -qF -- "$2" "$1" || echo "위반: $1 에 [$2] 없음"; }
  for f in .ai/40_domain/specs/issue-workflow.md .ai/50_adr/active/0016-spec-requirements-layer-and-plan-audit.md .ai/60_codebase/issue-audit/plan-audit-call-flow.md; do
    chk "$f" '### 포함'; chk "$f" '**포함**'
  done
  ```

  </details>
- [ ] [D]  issue-audit 코드맵의 frontmatter가 기준 브랜치와 같다 (AC16) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  f=.ai/60_codebase/issue-audit/plan-audit-call-flow.md
  diff <(git show "main:$f" | sed -n '1,5p') <(sed -n '1,5p' "$f") >/dev/null || echo "위반: $f frontmatter 가 main 과 다름"
  ```

  - 설계 주의: R9의 코드맵 frontmatter 항목과 같은 이유다(전제 13). 구현 전에도 통과하는 것이 정상이다.
  </details>
- [ ] [QD] 세 문서의 서술이 헬퍼 동작(`### 포함`에서 시작해 다음 `### ` 제목에서 끝남, 옛 `**포함**` 표지와 행 끝 닫힌 주석이 붙은 표지도 읽음)과 뜻이 같다 (AC16)  (검증: 최종 감사에서 다른 AI가 문서와 헬퍼를 대조)  ← 강등 사유: 낱말이 있어도 서술이 동작과 같은 뜻인지는 명령으로 판정할 수 없다

### 공통

- [ ] [D]  repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [ND] 포함 14개·제외 10개인 #132 spec의 요구사항 섹션을 R1~R3·R10의 새 규칙으로 옮겨 쓴 결과(`./issue-0140-spec-0132-requirements.md`)를 사용자가 읽고 읽기 쉬워졌다고 판정한다 (AC12)  (검증: 사용자 판정)  ← 강등 사유: 읽기 쉬운지는 사람 판단이다

---

## 전제 (Assumptions)

1. **앵커 문구**: 완료의 정의 검증 명령의 따옴표 속 문구는 조항에 글자 그대로 쓰고 한 행 안에 둔다(행을 바꿔 끊지 않는다). 문구를 바꾸려면 이 spec의 검증 명령과 러너 케이스를 같이 고친다. 초안 문구를 넣은 사본에서 R1~R6의 `[D]` 명령이 출력 0건이고 기존 러너 276건이 그대로 통과하는 것을 2026-11-11 계획 작성 중에 확인했다.
2. **규칙을 두는 자리**: spec 템플릿은 요구사항 안내 주석(HTML 주석)에 `- 포함 묶음:`·`- 제외 묶음:` 행을 새로 두고 `- 포함:`·`- 근거 표기:`·`- 함께 해소 표기:` 행을 고친다. 포함 예시는 R이 2개라 묶음 제목 없이 하위 목록만 보인다.
3. **제외 묶음 안의 줄 형식**: 묶음 안의 줄도 묶지 않을 때와 같은 `<항목>: <사유>(<이유>)` 형식으로 쓴다. 이슈 본문에 정해져 있지 않아 2026-11-11 요구사항 승인 때 이 해석으로 진행하기로 했다.
4. **이슈 본문 템플릿의 하위 목록**: 기존 문장 "관련 항목은 하위 목록으로 묶어도 된다"는 "항목의 세부 조건은 하위 목록에 둔다"로 고친다(묶기는 `####` 제목이 맡는다). 이슈 본문 항목에 "첫 줄 한 문장" 규칙은 두지 않는다. 2026-11-11 요구사항 승인 때 이 해석으로 진행하기로 했다.
5. **5개를 세는 단위**: 포함과 제외를 따로 세고, 최상위 항목(포함은 R, 제외는 제외 줄)만 센다. 하위 목록 줄은 세지 않는다.
6. **추적성 헬퍼는 표지 판정만 고친다**: `check-plan.sh --trace`의 spec 파서에서 포함 목록 시작 조건에 `### 포함`을 더하고, 끝 조건에 `### ` 제목을 더한다. 옛 `**포함**` 표지는 계속 읽는다(archive spec과 이 spec이 쓴다). 표지 판정은 행 안의 닫힌 주석을 지운 결과(`scan`)로 해서 K-0023을 함께 해소한다. `#### ` 묶음 제목, 하위 목록, 섞인 R 번호 순서는 지금 코드로 통과하므로(2026-11-11 임시 fixture로 재확인) 그 밖의 파서는 고치지 않는다. 묶음 제목을 굵은 글씨로 쓰면 포함 목록이 거기서 끊기는 동작은 그대로 두고 R7 테스트의 격추 케이스로 고정한다. K-0010은 함께 해소하지 않는다(2026-11-11 요구사항 승인).
7. **러너 케이스 설명**: issue-work 러너의 새 케이스는 `요구사항 묶음: `으로, issue-audit 러너의 새 케이스는 `trace: 요구사항 묶음`으로 시작한다. R10 케이스는 issue-work 러너에서 `요구사항 표지: `로, issue-audit 러너에서 `trace: 포함 표지 `로 시작하며, issue-audit 쪽 설명 6개는 R10 완료의 정의 검증 명령에 적힌 글자 그대로 쓴다. 설명에는 `통과`·`격추` 가운데 하나만 쓴다(plan 완료 기준이 낱말별로 센다).
8. **테스트 층과 실행 셸**: `.ai/10_rules/testing-principles-local.md`의 테스트 층 표와 실행 셸이 비어 있어 템플릿 기본값을 따른다. 러너는 `<skill>/tests/run-tests.sh`이고 출력은 `ok     - <설명>`·`NOT OK - <설명>` 행과 종료 코드로 읽는다. 검증 명령은 repo 루트에서 bash로 실행하며, AI 도구의 기본 셸이 zsh면 `bash -s <<'EOF' … EOF`로 감싼다.
9. **SKILL.md의 함께 해소 표기 위치**: 3-1 `함께 해소 후보` 항목의 "R 문장 끝에"를 "R 첫 줄 끝에"로 고쳐 템플릿(R3)과 같은 자리를 가리키게 한다. `--create` 1단계(초안 작성) 문장은 고치지 않는다. 묶음 규칙은 이슈 본문 템플릿 안내가 맡는다.
10. **이 spec의 형식**: 이 spec은 현행 템플릿 형식(한 목록)으로 둔다. 템플릿 변경은 신규 이슈부터 적용하고 진행 중인 이슈에 소급하지 않는다(명세 `issue-workflow.md`).
11. **AC12 산출물**: 옮겨 쓴 결과는 `./issue-0140-spec-0132-requirements.md`(작성 시점 경로는 `.ai/99_workspace/issue-0140-spec-0132-requirements.md`, --clear로 이관)에 두고 archive의 #132 spec은 고치지 않는다(제외 항목). 파일은 `## 요구사항 (Requirements)` 행으로 시작해 포함·제외 목록만 담고, 표지는 R10의 `### 포함`·`### 제외`를 쓴다. 묶음 이름은 구현 AI가 정한다. 사용자가 읽기 쉽지 않다고 판정하면 규칙을 고치기 전에 변경 통제로 분류해 질의한다.
12. **ADR 처리**: ADR 0016·0026은 결정 항목 일부 변경이라 제자리에서 고치고 근거에 변경 날짜·이슈 번호·경위를 적는다(ADR index `## 수명 주기`). 새 ADR은 쓰지 않는다. 5개 기준의 근거(이슈 본문 배경)는 ADR 0016 근거에 옮긴다. ADR 0003과 `architecture.md`의 임계 수치 미도입은 결정화 판단(반복 호출 횟수, 분기 개수)이 대상이라 목록 묶기 기준과 대상이 다르다.
13. **코드맵 표지**: 코드맵 3건(R9의 issue-work 2건, R10의 issue-audit `plan-audit-call-flow.md`)은 본문(트리 주석, 시퀀스 다이어그램 Note, 원장 서술)만 고치고 frontmatter의 `last_synced`·`source_hash`는 건드리지 않는다. 표지는 구현 커밋 뒤 code-map sync가 갱신한다(#138 선례, 2026-11-11 사용자 확정).
14. **index 설명 열**: `.ai/50_adr/index.md`의 0016·0026 행과 `.ai/40_domain/index.md`의 `specs/issue-workflow.md` 행 설명이 바뀐 내용과 어긋나면 R9 작업에서 같이 고친다.
15. **설치본**: `~/.claude/skills/issue-work`는 repo와 같은 내용의 사본이다(2026-11-11 `diff -rq` 확인, 차이는 배포 제외인 `tests/`뿐). 재설치는 PR 머지 뒤에 하며, 이 이슈의 절차는 repo의 `issue-work/SKILL.md`를 기준으로 수행한다.
16. **범위 확장 경위**: 2026-11-11 Task 2(AC12) 판정 중 사용자가 `**포함**`·`**제외**` 표지가 `#### ` 묶음 제목과 같은 크기로 보인다고 지적했다. 이슈 본문 제외의 "표지를 제목으로 바꾸기: 대체"를 포함으로 옮기는 변경이라 변경 통제에서 확장으로 분류했고, 사용자가 범위 확장을 골랐다. 기준 본문을 다시 받아 대조한 뒤 이슈 본문에 포함 항목과 AC14~AC17을 더하고 그 제외 줄을 지웠으며, 3-1 재승인으로 R10을 확정했다. 재검토 조건(포함 표지 판정 변경)에 해당한 K-0023은 같은 재승인에서 함께 해소로 포함했다. 이 확장으로 R7의 "헬퍼가 기준 브랜치와 같다" 회귀 방지 항목을 지웠다. plan에는 Task 7을 더하고 Task 2 완료 전에 수행한다(옮겨 쓴 사본의 `--trace`가 새 표지를 읽어야 한다).

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/50_adr/active/0016-spec-requirements-layer-and-plan-audit.md` | 요구사항 층 형식(포함 R<n> 한 문장, 제외 이유 한 줄)과 3-1 승인 요청 제시 결정 (R9·R10 수정 대상) |
| `.ai/50_adr/active/0026-acceptance-criteria-across-issue-spec-pr.md` | 이슈 본문 템플릿과 `--create` 요약 제시 결정 (R9 수정 대상) |
| `.ai/40_domain/specs/issue-workflow.md` | spec 구성, 3-1 승인 요청, `--create` 요건 명세 (R9·R10 수정 대상) |
| `.ai/60_codebase/issue-work/start-call-flow.md` | 새 이슈 시작 흐름 코드맵 (R9 수정 대상) |
| `.ai/60_codebase/issue-work/create-call-flow.md` | 이슈 등록 흐름 코드맵 (R9 수정 대상) |
| `.ai/60_codebase/issue-audit/plan-audit-call-flow.md` | 추적성 헬퍼의 spec 파서 흐름 코드맵 (R10 수정 대상) |
| `.ai/50_adr/active/0003-verification-levels-and-determinization.md` | 완료의 정의 검증 레벨. 임계 수치 미도입 결정은 결정화 판단(반복 호출 횟수, 분기 개수)이 대상이라 목록 묶기 기준 5개와 대상이 다름 |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 헬퍼 테스트 위치·러너 (R7·R8 테스트) |
| `.ai/50_adr/active/0013-long-output-single-file-generation.md` | 파일 1회 생성 뒤 경로·요약만 제시하는 결정 (R5·R6 대화 제시의 바탕) |
| `.ai/40_domain/specs/issue-audit.md` | `--plan` 추적성 검사 요건 (R7) |
| `.ai/70_ledger/active/K-0010-check-plan-line-based-markdown-boundary.md` | 추적성 헬퍼의 행 단위 파서 경계 (R10에서도 함께 해소하지 않음) |
| `.ai/70_ledger/active/K-0023-check-plan-include-label-trailing-comment.md` | 추적성 헬퍼의 `**포함**` 라벨 판정 경계 (R10에서 함께 해소) |
| `.ai/90_issues/archive/issue-0132/issue-0132-spec.md` | 포함 14개·제외 10개 사례 (AC12에서 새 규칙으로 옮겨 써 볼 대상) |
