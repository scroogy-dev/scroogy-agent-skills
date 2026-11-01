# Issue #130 스펙 issue-work·git-pr·issue-audit: 이슈 등록 옵션(--create)과 이슈 본문 템플릿을 추가하고 완료의 정의를 이슈·spec·PR로 잇는다

## 목표 (Goal)

완료의 정의를 이슈 등록 때 정하고, spec은 같은 기준을 판정할 수 있게 정제하며, 완화·확장은 재승인 없이 통과하지 못하게 한다.

---

## 요구사항 (Requirements)

**포함**

- R1: issue-work에 이슈 본문 템플릿 `templates/issue-body-template.md`가 생긴다. 목표·범위·완료의 정의·검토 필요는 본문에, 배경·현재 동작 → 기대 동작·연관 문서는 접기에 둔다.
- R2: `issue-work --create`가 초안 파일 1회 작성 → 요약 제시 → 승인 → `gh issue create --repo --body-file` → 번호 보고 → "새 이슈 시작 시" 진행 여부 질의 순서로 이슈를 등록한다. 승인 전에는 이슈를 만들지 않고 `--repo`를 생략하지 않으며, 등록만 할 때는 active 작업 파일을 옮기거나 지우지 않는다.
- R3: `--create` 요약 제시 단계에서, 초안 범위 안에 서로 독립으로 머지할 수 있는 항목이 있으면 AI가 이슈 분할을 권고한다. 수치 기준은 두지 않고 권고까지만 하며 결정은 사용자가 한다. (이슈 본문 `검토 필요` 항목. 2026-11-01 대화에서 AI 판단으로 결정)
- R4: 이슈에 완료의 정의(AC)가 있으면 3-2는 완료의 정의를 새로 쓰지 않고 AC를 `[D]`/`[QD]`/`[ND]`로 정제한다. spec 완료의 정의 항목은 출처 AC를 표기하고 모든 AC가 1개 이상의 항목에 연결된다(`공통` 회귀 방지 항목은 예외). AC 번호는 뒤에만 추가하고 다시 매기지 않으며, plan Task 완료 기준은 진행만 판정하고 spec에 없는 결과를 더하지 않는다.
- R5: 3-2 정제와 작업 진행 중의 변경을 구체화·확장·완화로 분류한다. 구체화는 질의 없이 반영하고, 확장은 범위 확장(이슈 본문 갱신 + 재승인)·원장 등재·새 이슈(`--create`) 중에서 고르게 질의하며, 완화는 재승인 없이 반영하지 않는다.
- R6: 완료의 정의가 없는 기존 이슈는 spec·plan 작성과 계획 감사(선택)를 마친 뒤, Task 0 전에 spec 기준 AC 초안으로 이슈 본문을 갱신할지 질의받는다. 승인할 때만 `gh issue edit --body-file`을 실행한다.
- R7: `issue-audit --plan` 관점 3 "범위"가 spec 완료의 정의를 이슈 AC와 대조해 완화·확장을 발견으로 보고한다.
- R8: git-pr 이슈별 섹션의 첫 화면(접기 밖)에 변경 목적과 이 PR이 맡는 범위, 리뷰어 확인 요청(사람이 판단할 결정·트레이드오프를 질문으로, 없으면 "없음"), 리스크·주의사항, 완료의 정의 대조 요약(충족 n/m과 미충족·이관 항목), 이번 PR에서 하지 않는 것을 둔다. AC별 대조 표 전체·전후 예시·배경·비즈니스 관점·테크 관점(구현 요약, 호출 흐름 트리, 시퀀스 다이어그램, 실패 경로)은 접기 안에 두고, 시퀀스 다이어그램의 대상과 규칙은 ADR 0025를 따른다. 테크 관점 배치를 검사하는 `code-map/tests/run-tests.sh`도 새 배치에 맞춘다.
- R9: git-pr 3단계 승인 요약에 리뷰어 확인 요청과 미충족 완료 항목이 들어간다.
- R10: 외부 공개 행위 정책 대상 목록에 이슈 등록과 이슈 본문 갱신(issue-work)을 추가하고, 도메인 요건 문서 3개(`issue-workflow.md`·`issue-audit.md`·`git-pr-submission.md`)를 갱신하며 ADR을 신설한다.
- R11: issue-work·issue-audit·git-pr의 tests에 구조 검사와 격추 케이스를 둔다. 기존 동작(기존 이슈 번호로 시작하는 흐름, Conventional Commits 제목, 이슈별 비즈니스·테크 관점, git-qa의 변경 요약 수집)은 그대로이고 저장소 전체 스킬 테스트가 통과한다.
- R12: issue-work SKILL.md `description`과 `.ai/AI-CONTEXT.md`·`README.md`의 issue-work 설명에 이슈 등록(`--create`)을 반영한다. (이슈 본문 근거 없음. 2026-11-01 대화에서 작성 AI 제안을 사용자가 확정)
- R13: issue-audit `check-plan.sh`에 이슈 본문 AC와 spec 완료의 정의 항목의 출처 표기를 대조하는 `--ac` 모드를 더한다. 연결되지 않은 AC, 이슈에 없는 AC 참조, 출처 표기가 없는 항목(`공통` 회귀 방지 항목 제외)을 1건 1행으로 출력하고, `--plan` 계획 감사가 이 모드를 실행해 발견으로 센다. (이슈 본문 근거 없음. 2026-11-01 3-2 계획 종료 뒤 대화에서 사용자가 결정, 3-1 재승인 대상)

**제외**

- 이해 점검 퀴즈 연결(PR 안내, Task별 퀴즈): 보류(퀴즈 운영 방식을 먼저 정한다)
- 마이크로월드(조작 가능한 축소 모형) 생성: 보류(작성 비용이 커서 별도 스킬 후보로 둔다)
- doc 프로파일 저장소에서 호출 흐름·시퀀스를 대신할 형식(문서 구조 변경 전후 표 등): 보류(doc 저장소의 PR 경험을 쌓은 뒤 정한다. 이슈 본문 `검토 필요` 항목, 2026-11-01 대화에서 결정)
- 이슈와 spec의 번호 통합(이슈부터 R 번호 사용): 불필요(AC와 R을 따로 두고 출처 표기로 잇는다. 2026-11-01 대화에서 결정)
- 3-2 끝의 별도 승인 게이트: 대체(완화·확장만 질의하는 자기 분류와 계획 감사가 맡는다)
- git-review 변경: 불필요(이미 형식화되어 있다)
- `.github/ISSUE_TEMPLATE`·`PULL_REQUEST_TEMPLATE.md` 파일: 대체(스킬 템플릿이 SSoT다)
- 기존 이슈 본문 일괄 소급 보강: 불필요(신규 이슈부터 적용하고, 기존 이슈는 작업을 시작할 때 갱신 질의로 보강한다)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> 항목 끝의 `(AC<n>)`은 이슈 #130 본문 완료의 정의의 출처 표기다. 이슈 AC가 없는 R의 항목은 `(AC 없음: <사유>)`로 적는다 (형식은 전제 2).
> 검증 명령은 repo 루트에서 `bash`로 실행한다 (전제 1).

### R1: 이슈 본문 템플릿

- [ ] [D] 이슈 본문 템플릿의 본문 헤더는 목표·범위·완료의 정의·검토 필요 4개이고, 그 뒤 접기는 배경·현재 동작 → 기대 동작·연관 문서 3개다 (AC1)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-body-template.md
  body=$(awk '/<!--/ { c = 1 } c { if (/-->/) c = 0; next } 1' "$T" 2>/dev/null) || echo '위반: 템플릿 읽기 실패'
  [ "$(printf '%s\n' "$body" | grep -E '^## ' | tr '\n' '|')" = '## 목표|## 범위|## 완료의 정의|## 검토 필요|' ] || echo '위반: 본문 헤더 구성'
  [ "$(printf '%s\n' "$body" | grep -oE '<summary>[^<]+</summary>' | tr '\n' '|')" \
    = '<summary>배경</summary>|<summary>현재 동작 → 기대 동작</summary>|<summary>연관 문서</summary>|' ] || echo '위반: 접기 구성'
  printf '%s\n' "$body" | awk '/^<details>/ { d++ } /^<\/details>/ { d-- } d > 0 && /^## / { print "위반: 접기 안 헤더 " $0 }
    /^## 검토 필요$/ { k = 1 } /^<details>/ && !k { print "위반: 검토 필요 앞 접기" }'
  ```

  - 설계 주의: HTML 주석 안의 안내문은 빼고 센다. 헤더와 접기 제목을 열거해 그 외 0건까지 판정한다.
  </details>
- [ ] [D] 템플릿 완료의 정의 섹션이 `- [ ] AC<n>: ` 형식 행을 1개 이상 보여 준다 (AC4)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-body-template.md
  awk '/^## 완료의 정의$/ { s = 1; next } /^## / { s = 0 } s && /^- \[ \] AC[0-9]+: / { n++ }
       END { if (n < 1) print "위반: 완료의 정의에 AC 행 없음" }' "$T" 2>/dev/null || echo '위반: 템플릿 읽기 실패'
  ```

  </details>
- [ ] [D] issue-work 러너의 `이슈 본문 템플릿:` 케이스가 통과·격추 각 1건 이상 실행되고 러너가 0 실패다 (AC1)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(bash issue-work/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 이슈 본문 템플릿: .* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 이슈 본문 템플릿: .* 격추')" -ge 1 ] \
    || echo '위반: 러너 실패 또는 이슈 본문 템플릿 케이스 미실행'
  ```

  </details>

### R2: --create 등록 흐름

- [ ] [D] `## 옵션` 아래 `--create` 절이 1개이고, 동작 단계가 초안 작성 → 요약 제시 → 승인 → 등록 → 번호 보고 → 시작 질의 순서이며 그 외 단계가 없다 (AC2, AC3)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  [ "$(grep -c '^### `--create`$' "$S")" -eq 1 ] || echo '위반: --create 절 개수'
  awk '/^## 옵션$/ { o = NR } /^### `--create`$/ { c = NR } END { if (!o || !c || c < o) print "위반: --create 절이 옵션 섹션 밖" }' "$S"
  sec=$(awk '/^### `--create`$/ { f = 1; next } f && /^#{2,3} / { exit } f' "$S")
  [ "$(printf '%s\n' "$sec" | grep -oE '^  [0-9]+\. \*\*[^*]+\*\*' | sed -E 's/^  [0-9]+\. //' | tr '\n' '|')" \
    = '**초안 작성**|**요약 제시**|**승인**|**등록**|**번호 보고**|**시작 질의**|' ] || echo '위반: 단계 구성·순서'
  ```

  - 설계 주의: 단계 행 형식은 `--clear`와 같은 `  <번호>. **<이름>**:`이다. 단계 이름을 열거해 추가·삭제·순서 변경을 모두 위반으로 센다.
  </details>
- [ ] [D] `--create` 절이 가리키는 작업 파일은 `.ai/99_workspace/issue-create-body.md` 하나다 (AC2)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  got=$(awk '/^### `--create`$/ { f = 1; next } f && /^#{2,3} / { exit } f' "$S" \
    | grep -oE "\.ai/99_workspace/[^\`' )]+" | sort -u | tr '\n' '|')
  [ "$got" = '.ai/99_workspace/issue-create-body.md|' ] || echo "위반: 작업 파일 [$got]"
  ```

  </details>
- [ ] [D] SKILL.md의 `gh issue create` 명령 행은 1개 이상이고 모두 `--repo '`와 `--body-file`을 갖는다 (AC2)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  [ "$(grep -c 'gh issue create --' "$S")" -ge 1 ] || echo '위반: gh issue create 명령 행 없음'
  grep -n 'gh issue create --' "$S" | grep -vF -e "--repo '" | sed 's/^/위반(--repo 없음): /'
  grep -n 'gh issue create --' "$S" | grep -vF -e '--body-file' | sed 's/^/위반(--body-file 없음): /'
  ```

  - 설계 주의: 명령 형태(`gh issue create --`)만 센다. 산문 속 `` `gh issue create`를 `` 같은 언급은 대상이 아니다.
  </details>
- [ ] [D] `--create` 절에 승인 전 미실행 문장과 active 작업 파일 무변경 문장이 있다 (AC2, AC3)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  sec=$(awk '/^### `--create`$/ { f = 1; next } f && /^#{2,3} / { exit } f' "$S")
  for p in '승인 전에는 `gh issue create`를 실행하지 않는다' 'active 작업 파일을 옮기거나 지우지 않는다'; do
    printf '%s\n' "$sec" | grep -qF -- "$p" || echo "위반: 문장 없음 [$p]"
  done
  ```

  </details>
- [ ] [D] issue-work 러너의 `--create 절:` 케이스가 통과·격추 각 1건 이상 실행되고 러너가 0 실패다 (AC2, AC3)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(bash issue-work/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- --create 절: .* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- --create 절: .* 격추')" -ge 1 ] \
    || echo '위반: 러너 실패 또는 --create 절 케이스 미실행'
  ```

  </details>
- [ ] [QD] 승인 거절·저장소 미확정·생성 실패 경로에서 이슈가 만들어지거나 active 작업 파일이 바뀌는 길이 `--create` 절에 없다 (AC2, AC3)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: AI가 따르는 절차 문장이라 실행 경로를 명령으로 돌려 볼 수 없다

### R3: 이슈 분할 권고

- [ ] [D] `--create` 요약 제시 단계에 분할 권고 조항(서로 독립으로 머지할 수 있는 항목이 있으면 권고, 수치 기준 없음, 결정은 사용자)이 있다 (AC 없음: 검토 필요 결정)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  st=$(awk '/^### `--create`$/ { f = 1; next } f && /^#{2,3} / { exit } f' "$S" \
    | awk '/^  [0-9]+\. \*\*요약 제시\*\*/ { s = 1; print; next } s && /^  [0-9]+\. / { exit } s')
  for p in '서로 독립으로 머지할 수 있는' '분할을 권고' '수치 기준은 두지 않' '결정은 사용자'; do
    printf '%s\n' "$st" | grep -qF -- "$p" || echo "위반: 요약 제시 단계에 [$p] 없음"
  done
  ```

  </details>

### R4: AC 정제

- [ ] [D] 3-2 범위에 AC 정제 조항 5개(`[D]`/`[QD]`/`[ND]` 정제, 출처 AC 표기, 모든 AC 연결, `공통` 회귀 방지 예외, AC 번호 유지)가 있다 (AC4)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  r=$(awk '/^   - \*\*3-2\. 승인 후\*\*/ { s = 1 } s && /^4\. / { exit } s' "$S")
  [ -n "$r" ] || echo '위반: 3-2 범위 없음'
  for p in 'AC를 `[D]`/`[QD]`/`[ND]`로 정제' '출처 AC를 표기' '모든 AC가 1개 이상의 항목에 연결' \
           '`공통` 회귀 방지 항목은 예외' 'AC 번호는 뒤에만 추가하고 다시 매기지 않는다'; do
    printf '%s\n' "$r" | grep -qF -- "$p" || echo "위반: 3-2에 [$p] 없음"
  done
  ```

  </details>
- [ ] [D] spec 템플릿 완료의 정의 예시 항목에 출처 표기 `(AC<n>)`가 있고, 출처 표기는 회귀 방지 표시보다 앞에 둔다 (AC4)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-spec-template.md
  awk '/^## 완료의 정의/ { s = 1; next } /^## / { s = 0 }
       s && /^- \[ \] \[(D|QD|ND)\]/ {
         if ($0 ~ /\(AC[0-9]+(, AC[0-9]+)*\)/) n++
         if ($0 ~ /\(회귀 방지 항목\).*\(AC[0-9]/) print "위반: 출처 표기가 회귀 방지 표시 뒤 (행 " NR ")"
       }
       END { if (n < 1) print "위반: 출처 AC 표기 예시 없음" }' "$T"
  ```

  - 설계 주의: `(회귀 방지 항목)`은 항목 본문 끝에 두는 기존 규칙(issue-audit `--plan` 관점 2 예외 판정)을 바꾸지 않으려고 출처 표기를 그 앞에 둔다.
  </details>
- [ ] [D] plan 템플릿 `## Tasks` 안내에 Task 완료 기준은 진행만 판정하고 spec에 없는 결과를 더하지 않는다는 문장이 있다 (AC4)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/issue-plan-template.md
  r=$(awk '/^## Tasks$/ { s = 1 } /^### Task 0/ { exit } s' "$T")
  for p in '진행만 판정' 'spec에 없는 결과를 더하지 않는다'; do
    printf '%s\n' "$r" | grep -qF -- "$p" || echo "위반: Tasks 안내에 [$p] 없음"
  done
  ```

  </details>
- [ ] [D] issue-work 러너의 `AC 정제:` 케이스가 통과·격추 각 1건 이상 실행되고 러너가 0 실패다 (AC4)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(bash issue-work/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- AC 정제: .* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- AC 정제: .* 격추')" -ge 1 ] \
    || echo '위반: 러너 실패 또는 AC 정제 케이스 미실행'
  ```

  </details>
- [ ] [QD] 3-2 조항이 AC가 있는 이슈에서 완료의 정의를 AC와 무관하게 새로 쓰는 길을 남기지 않고, AC가 없는 이슈는 지금 방식대로 쓰게 한다 (AC4)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 조항 사이의 적용 조건 해석은 의미 판단이다

### R5: 변경 통제

- [ ] [D] `## 작업 진행 중`에 `- **변경 통제**:` 항목이 1개이고, 하위에 구체화·확장·완화 항목이 각 1개이며, 항목마다 처리 문장이 있다 (AC5)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  b=$(awk '/^## 작업 진행 중$/ { w = 1; next } w && /^## / { exit }
           w && /^- \*\*변경 통제\*\*:/ { s = 1; print; next } s && /^- / { s = 0 } s' "$S")
  [ "$(printf '%s\n' "$b" | grep -c '^- \*\*변경 통제\*\*:')" -eq 1 ] || echo '위반: 변경 통제 항목 개수'
  for k in 구체화 확장 완화; do
    [ "$(printf '%s\n' "$b" | grep -cE "^  - \*\*$k\*\*: ")" -eq 1 ] || echo "위반: $k 항목 개수"
  done
  printf '%s\n' "$b" | grep -E '^  - \*\*구체화\*\*: ' | grep -qF '질의 없이 반영' || echo '위반: 구체화 처리 문장'
  l=$(printf '%s\n' "$b" | grep -E '^  - \*\*확장\*\*: ')
  for p in '범위 확장' '원장 등재' '새 이슈(`--create`)'; do
    printf '%s\n' "$l" | grep -qF -- "$p" || echo "위반: 확장 선택지 [$p]"
  done
  printf '%s\n' "$b" | grep -E '^  - \*\*완화\*\*: ' | grep -qF '재승인 없이 반영하지 않는다' || echo '위반: 완화 처리 문장'
  ```

  </details>
- [ ] [D] 3-2 범위와 `issue-workflow-template.md`의 `## 작업 진행 중`에 변경 통제 참조가 각 1개 이상 있다 (AC5)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^   - \*\*3-2\. 승인 후\*\*/ { s = 1 } s && /^4\. / { exit } s && index($0, "변경 통제") { n++ }
       END { if (n < 1) print "위반: 3-2에 변경 통제 참조 없음" }' issue-work/SKILL.md
  awk '/^## 작업 진행 중$/ { s = 1; next } s && /^## / { exit } s && index($0, "변경 통제") { n++ }
       END { if (n < 1) print "위반: workflow 템플릿에 변경 통제 없음" }' issue-work/templates/issue-workflow-template.md
  ```

  - 설계 주의: `issue-workflow-template.md`는 컨텍스트 초기화 뒤에도 절차를 잇는 `active/issue-workflow.md`의 원본이라, 작업 진행 중 변경 통제가 여기에 없으면 세션이 바뀐 뒤 적용되지 않는다.
  </details>
- [ ] [D] issue-work 러너의 `변경 통제:` 케이스가 통과·격추 각 1건 이상 실행되고 러너가 0 실패다 (AC5)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(bash issue-work/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 변경 통제: .* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 변경 통제: .* 격추')" -ge 1 ] \
    || echo '위반: 러너 실패 또는 변경 통제 케이스 미실행'
  ```

  </details>
- [ ] [QD] 분류 정의와 예시가 경계 사례(검증 대상 오류 상황을 빼면 완화, 같은 AC의 판정 기준을 좁히면 구체화, AC에 없는 결과를 더하면 확장)를 가를 만큼 명확하다 (AC5)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 분류는 변경 내용의 의미 판단이다

### R6: 기존 이슈 본문 갱신 질의

- [ ] [D] "새 이슈 시작 시" 번호 단계가 1~6이고, 6단계에 AC 없는 이슈의 본문 갱신 질의 조항(대상 판정, Task 0 전, 승인할 때만 실행, 명령 형식)이 있다 (AC7)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  sec=$(awk '/^## 새 이슈 시작 시$/ { f = 1; next } f && /^## / { exit } f' "$S")
  [ "$(printf '%s\n' "$sec" | grep -oE '^[0-9]+\. ' | tr -d '. ' | tr '\n' '|')" = '1|2|3|4|5|6|' ] || echo '위반: 단계 번호'
  six=$(printf '%s\n' "$sec" | awk '/^6\. / { s = 1; print; next } s && /^[^[:space:]]/ { exit } s')
  for p in '완료의 정의가 없는' 'Task 0 전에' '승인할 때만' "gh issue edit --repo '" \
           "--body-file '.ai/99_workspace/issue-<번호>-body.md'"; do
    printf '%s\n' "$six" | grep -qF -- "$p" || echo "위반: 6단계에 [$p] 없음"
  done
  ```

  </details>
- [ ] [D] SKILL.md의 `gh issue edit` 명령 행은 1개 이상이고 모두 `--repo '`와 `--body-file`을 갖는다 (AC7)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  [ "$(grep -c 'gh issue edit --' "$S")" -ge 1 ] || echo '위반: gh issue edit 명령 행 없음'
  grep -n 'gh issue edit --' "$S" | grep -vF -e "--repo '" | sed 's/^/위반(--repo 없음): /'
  grep -n 'gh issue edit --' "$S" | grep -vF -e '--body-file' | sed 's/^/위반(--body-file 없음): /'
  ```

  </details>
- [ ] [D] issue-work 러너의 `본문 갱신 질의:` 케이스가 통과·격추 각 1건 이상 실행되고 러너가 0 실패다 (AC7)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(bash issue-work/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 본문 갱신 질의: .* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 본문 갱신 질의: .* 격추')" -ge 1 ] \
    || echo '위반: 러너 실패 또는 본문 갱신 질의 케이스 미실행'
  ```

  </details>
- [ ] [QD] AC가 있는 이슈에서는 질의가 생략되고, 거절하면 이슈 본문을 바꾸는 명령이 실행되지 않으며, 갱신 본문이 기존 본문을 지우지 않는다 (AC7)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 절차 실행 경로는 명령으로 돌려 볼 수 없다

### R7: 계획 감사 관점 3

- [ ] [D] issue-audit `--plan` 2단계 관점 3이 1개이고, 이슈 AC 대비 spec 완료의 정의의 완화·확장을 발견으로 보고하는 조항과 AC 없는 이슈 처리 문장이 있다 (AC6)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  A=issue-audit/SKILL.md
  p3=$(awk '/^### `--plan`$/ { f = 1; next } f && /^### / { exit }
            f && /^3\. \*\*범위\*\* / { n++; s = 1; print; next } s && /^[0-9]+\. / { s = 0 } s' "$A")
  [ "$(printf '%s\n' "$p3" | grep -c '^3\. \*\*범위\*\* ')" -eq 1 ] || echo '위반: 관점 3 개수'
  for p in '이슈 AC' '완화' '확장' '발견으로 보고' 'AC가 없으면'; do
    printf '%s\n' "$p3" | grep -qF -- "$p" || echo "위반: 관점 3에 [$p] 없음"
  done
  ```

  - 설계 주의: 관점 3 범위는 `3. **범위**` 행부터 다음 번호 관점 전까지다. 하위 행으로 나눠 써도 잡히고, 다른 관점으로 옮긴 문장은 잡히지 않는다.
  </details>
- [ ] [D] issue-audit 러너의 `관점 3 범위:` 케이스가 통과·격추 각 1건 이상 실행되고 러너가 0 실패다 (AC6)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(bash issue-audit/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 관점 3 범위: .* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 관점 3 범위: .* 격추')" -ge 1 ] \
    || echo '위반: 러너 실패 또는 관점 3 범위 케이스 미실행'
  ```

  </details>
- [ ] [QD] 관점 3이 완화(오류 상황 제외, 성공 조건 약화, 어느 항목에도 연결되지 않은 AC)와 확장(AC에 없는 결과)을 가를 기준을 감사인에게 준다 (AC6)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 기준의 충분성은 의미 판단이다

### R8: PR 본문 첫 화면과 접기

- [ ] [D] PR 본문 템플릿 첫 이슈 섹션의 접기 밖 라벨은 목적·범위 → 리뷰어 확인 요청 → 리스크·주의사항 → 완료의 정의 대조 → 이번 PR에서 하지 않는 것 5개이고, 접기 안 `#### ` 헤더는 완료의 정의 대조 표 → 전후 예시 → 배경 → 1. 비즈니스 관점 → 2. 테크 관점 5개다 (AC8)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=git-pr/templates/pr-body-template.md
  got=$(awk '/^### Issue: / { n++ } n == 1 && /^<details>/ { d++ } n == 1 && /^<\/details>/ { d-- }
             n == 1 && d == 0 && /^\*\*[^*]+\*\*$/ { printf "%s|", $0 }' "$T")
  [ "$got" = '**목적·범위**|**리뷰어 확인 요청**|**리스크·주의사항**|**완료의 정의 대조**|**이번 PR에서 하지 않는 것**|' ] \
    || echo "위반: 첫 화면 라벨 [$got]"
  got=$(awk '/^### Issue: / { n++ } n == 1 && /^<details>/ { d++ } n == 1 && /^<\/details>/ { d-- }
             n == 1 && d > 0 && /^#### / { printf "%s|", $0 }' "$T")
  [ "$got" = '#### 완료의 정의 대조 표|#### 전후 예시|#### 배경|#### 1. 비즈니스 관점|#### 2. 테크 관점|' ] \
    || echo "위반: 접기 안 헤더 [$got]"
  ```

  - 설계 주의: 접기는 깊이로 세어 접기를 나눠 쓰거나 겹쳐 써도 판정이 깨지지 않게 한다. 라벨·헤더를 열거해 그 외 0건까지 판정한다.
  </details>
- [ ] [D] git-pr SKILL.md와 PR 본문 템플릿의 테크 관점 항목은 구현 요약 → 호출 흐름 → 실패 경로 → 참고사항 순서이고 그 외 0건이다 (AC8)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in git-pr/SKILL.md git-pr/templates/pr-body-template.md; do
    got=$(awk '/^#### 2\. 테크 관점$/ { s = 1; next } s && (/^## / || /^<\/details>/) { exit }
               s && /^\* \*\*[^*]+:\*\*/ { match($0, /\*\*[^*]+:\*\*/); printf "%s|", substr($0, RSTART, RLENGTH) }' "$f")
    [ "$got" = '**구현 요약:**|**호출 흐름:**|**실패 경로:**|**참고사항:**|' ] || echo "위반: $f 테크 관점 항목 [$got]"
  done
  ```

  </details>
- [ ] [D] git-pr SKILL.md 이슈 섹션 설명에 첫 화면 라벨 5개가 항목별 행으로 순서대로 있고, 리뷰어 확인 요청은 질문으로 쓰며 없으면 `없음`을 적는다는 문장이 있다 (AC8)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=git-pr/SKILL.md
  sec=$(awk '/^### Issue: #\[이슈번호\]/ { f = 1; next } f && /^#### 1\. 비즈니스 관점$/ { exit } f' "$S")
  prev=0
  for p in '**목적·범위**' '**리뷰어 확인 요청**' '**리스크·주의사항**' '**완료의 정의 대조**' '**이번 PR에서 하지 않는 것**'; do
    ln=$(printf '%s\n' "$sec" | grep -nF -- "$p" | head -1 | cut -d: -f1)
    if [ -z "$ln" ] || [ "$ln" -le "$prev" ]; then echo "위반: 첫 화면 라벨 순서 [$p]"; else prev=$ln; fi
  done
  for p in '질문으로' '`없음`'; do
    printf '%s\n' "$sec" | grep -F '**리뷰어 확인 요청**' | grep -qF -- "$p" || echo "위반: 리뷰어 확인 요청 규칙 [$p]"
  done
  ```

  - 설계 주의: 라벨마다 첫 등장 행 번호가 커져야 통과한다. 라벨을 한 행에 몰아 쓰면 행 번호가 같아 위반으로 센다.
  </details>
- [ ] [D] code-map 러너의 git-pr 시퀀스 배치 검사(본문·템플릿)가 통과한다. 시퀀스 대상과 규칙이 ADR 0025와 같다는 근거다 (AC8) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(bash code-map/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 시퀀스 배치 git-pr (본문|템플릿) 통과$')" -eq 2 ] \
    || echo '위반: code-map 러너 실패 또는 git-pr 시퀀스 배치 검사 미실행'
  ```

  </details>
- [ ] [D] git-pr 러너의 `PR 본문 구성:` 케이스가 통과·격추 각 1건 이상 실행되고 러너가 0 실패다 (AC8)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(bash git-pr/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- PR 본문 구성: .* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- PR 본문 구성: .* 격추')" -ge 1 ] \
    || echo '위반: 러너 실패 또는 PR 본문 구성 케이스 미실행'
  ```

  </details>
- [ ] [QD] 첫 화면만 읽고 리뷰어가 판단할 결정과 완료 정도(충족 n/m, 미충족·이관)를 알 수 있고, 접기 안 내용이 첫 화면과 겹쳐 쓰이지 않는다 (AC8)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 읽는 사람 기준의 정보 배치는 의미 판단이다

### R9: PR 승인 요약

- [ ] [D] git-pr 3단계의 `최종 PR 본문` 요약 항목에 리뷰어 확인 요청과 미충족 완료 항목이 들어 있다 (AC9)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=git-pr/SKILL.md
  l=$(awk '/^### 3\. 최종 제시 및 승인/ { f = 1; next } f && /^### / { exit } f && /^  - 최종 PR 본문 — / { print }' "$S")
  [ "$(printf '%s\n' "$l" | grep -c .)" -eq 1 ] || echo '위반: 최종 PR 본문 항목 개수'
  for p in '리뷰어 확인 요청' '미충족 완료 항목'; do
    printf '%s\n' "$l" | grep -qF -- "$p" || echo "위반: 승인 요약에 [$p] 없음"
  done
  ```

  </details>
- [ ] [D] git-pr 러너의 `승인 요약:` 케이스가 통과·격추 각 1건 이상 실행되고 러너가 0 실패다 (AC9)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(bash git-pr/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 승인 요약: .* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 승인 요약: .* 격추')" -ge 1 ] \
    || echo '위반: 러너 실패 또는 승인 요약 케이스 미실행'
  ```

  </details>

### R10: 정책·도메인 요건·ADR

- [ ] [D] 외부 공개 행위 정책의 대상 행에 이슈 등록과 이슈 본문 갱신이 있다 (AC10)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  P=.ai/40_domain/policies/local/external-action-approval-gate.md
  l=$(grep -E '^- 대상: ' "$P")
  [ "$(printf '%s\n' "$l" | grep -c .)" -eq 1 ] || echo '위반: 대상 행 개수'
  for p in '이슈 등록' '이슈 본문 갱신'; do printf '%s\n' "$l" | grep -qF -- "$p" || echo "위반: 대상에 [$p] 없음"; done
  ```

  </details>
- [ ] [D] ADR 0026이 `active/`에 1개 있고 ADR index에 행이 1개 있으며, 도메인 요건 문서 3개가 ADR 0026을 링크한다 (AC10)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  set -- .ai/50_adr/active/0026-*.md
  { [ "$#" -eq 1 ] && [ -f "$1" ]; } || echo '위반: ADR 0026 파일 개수'
  [ "$(grep -cE '^\| `active/0026-' .ai/50_adr/index.md)" -eq 1 ] || echo '위반: ADR index 행 개수'
  for d in issue-workflow issue-audit git-pr-submission; do
    grep -qE '50_adr/active/0026-' ".ai/40_domain/specs/$d.md" || echo "위반: $d.md에 ADR 0026 링크 없음"
  done
  ```

  - 설계 주의: zsh는 맞는 파일이 없는 글롭을 오류로 끝내므로 bash로 실행한다 (전제 1).
  </details>
- [ ] [D] 도메인 요건 문서 3개가 이번 변경의 핵심 어휘를 담는다. issue-workflow.md 옵션 행에 `--create`, issue-audit.md `--plan` 행에 완화·확장, git-pr-submission.md에 리뷰어 확인 요청·완료의 정의 대조가 있다 (AC10)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  D=.ai/40_domain/specs
  grep -E '^- 옵션: ' "$D/issue-workflow.md" | grep -qF -- '`--create`' || echo '위반: issue-workflow.md 옵션 행'
  l=$(grep -E '^- `--plan` 모드: ' "$D/issue-audit.md")
  for p in 완화 확장; do printf '%s\n' "$l" | grep -qF "$p" || echo "위반: issue-audit.md --plan 행 [$p]"; done
  for p in '리뷰어 확인 요청' '완료의 정의 대조'; do grep -qF "$p" "$D/git-pr-submission.md" || echo "위반: git-pr-submission.md [$p]"; done
  ```

  </details>
- [ ] [QD] 정책·도메인 요건 문서·ADR 0026의 서술이 구현한 SKILL.md·템플릿과 어긋나지 않고, 기존 ADR 결정과 겹치는 항목은 ADR index `## 수명 주기` 규칙대로 처리됐다 (AC10)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 문서 사이의 의미 대조다

### R11: 테스트와 기존 동작 유지

- [ ] [D] 저장소 전체 스킬 테스트가 통과한다 (AC11) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do bash "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D] git-qa 디렉토리는 바뀌지 않는다 (AC11) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  git diff --quiet "$(git merge-base HEAD origin/main)" -- git-qa/ || echo '위반: git-qa 변경'
  ```

  </details>
- [ ] [D] PR 본문 템플릿이 `## 이슈 목록`, `- #<번호> - ` 행, `### Issue: #<번호> - ` 헤더를 유지한다. git-qa가 PR 본문에서 이슈 링크를 읽는 근거다 (AC11) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=git-pr/templates/pr-body-template.md
  [ "$(grep -c '^## 이슈 목록$' "$T")" -eq 1 ] || echo '위반: 이슈 목록 헤더'
  grep -qE '^- #[0-9]+ - ' "$T" || echo '위반: 이슈 목록 행'
  grep -qE '^### Issue: #[0-9]+ - ' "$T" || echo '위반: 이슈 헤더'
  ```

  </details>
- [ ] [QD] 이슈 번호 인자로 시작하는 기존 흐름이 `--create` 없이 그대로 진행되고, 새 단계(3-2 AC 정제, 6단계 질의)는 이슈 AC 유무 조건으로만 갈린다 (AC11)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 절차 분기 해석은 의미 판단이다

### R12: issue-work 설명 반영

- [ ] [D] issue-work `description`, `AI-CONTEXT.md` 스킬 목록, `README.md` 스킬 표의 issue-work 설명에 이슈 등록이 반영된다 (AC 없음: 3-1 승인으로 추가)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk 'NR == 1 && $0 == "---" { f = 1; next } f && $0 == "---" { exit } f && /^description: / { print }' issue-work/SKILL.md \
    | grep -qF -- '--create' || echo '위반: description에 --create 없음'
  grep -E '^\| `issue-work` \|' .ai/AI-CONTEXT.md | grep -qF '등록' || echo '위반: AI-CONTEXT 스킬 목록'
  grep -E '^\| \[issue-work\]' README.md | grep -qF '등록' || echo '위반: README 스킬 표'
  ```

  </details>

### R13: AC 대조 헬퍼

- [ ] [D] `check-plan.sh --ac <이슈 본문 파일> <spec 파일>`이 정상 입력에서 무출력·종료 코드 0이고, 연결 없는 AC·없는 AC 참조·출처 없는 항목·AC 없는 이슈 본문을 각각 해당 접두 행과 종료 코드 1로, 읽을 수 없는 파일을 종료 코드 2로 낸다 (AC 없음: 3-1 재승인으로 추가)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  H=issue-audit/scripts/check-plan.sh
  d=$(mktemp -d)
  printf '%s\n' '## 완료의 정의' '' '- [ ] AC1: 가' '- [ ] AC2: 나' > "$d/issue.md"
  printf '%s\n' '## 목표' '' '없음' > "$d/noac.md"
  spec() {
    printf '%s\n' '## 완료의 정의 (Definition of Done)' '' '### R1: 가' '' "$@" '' '### 공통' '' \
      '- [ ] [D]  전체 테스트가 통과한다 (회귀 방지 항목)'
  }
  spec '- [ ] [D]  가를 본다 (AC1)' '- [ ] [QD] 나를 본다 (AC1, AC2)' '- [ ] [D]  다를 본다 (AC 없음: 3-1 승인)' > "$d/ok.md"
  spec '- [ ] [D]  가를 본다 (AC1)' > "$d/unlinked.md"
  spec '- [ ] [D]  가를 본다 (AC1, AC2)' '- [ ] [D]  라를 본다 (AC3)' > "$d/unknown.md"
  spec '- [ ] [D]  가를 본다 (AC1, AC2)' '- [ ] [D]  출처가 없다' > "$d/nosource.md"
  chk() {  # chk <이슈> <spec> <기대 종료 코드> <기대 접두(없으면 빈 문자열)>
    out=$(bash "$H" --ac "$d/$1" "$d/$2" 2>/dev/null); rc=$?
    [ "$rc" -eq "$3" ] || echo "위반: $1·$2 종료 코드 $rc (기대 $3)"
    if [ -z "$4" ]; then [ -z "$out" ] || echo "위반: $1·$2 출력 [$out]"
    else printf '%s\n' "$out" | grep -q "^$4" || echo "위반: $1·$2 [$4] 행 없음"; fi
  }
  chk issue.md ok.md       0 ''
  chk issue.md unlinked.md 1 '연결 없는 AC: AC2'
  chk issue.md unknown.md  1 '없는 AC 참조: AC3'
  chk issue.md nosource.md 1 '출처 없는 항목: '
  chk noac.md  ok.md       1 '대조 불가: '
  chk missing.md ok.md     2 ''
  rm -rf "$d"
  ```

  - 설계 주의: `(AC 없음: …)` 표기와 `### 공통`의 `(회귀 방지 항목)` 항목은 정상 입력에 넣어 오탐하지 않는지 함께 본다. AC가 없는 이슈 본문은 공집합 통과를 막으려고 `대조 불가`로 실패시킨다 (`--trace`의 `추적 불가`와 같은 취지).
  </details>
- [ ] [D] issue-audit `--plan` 2단계 관점 1(추적성)에 `--ac` 실행 명령 행이 있고, 헬퍼 머리 주석의 사용법·출력 목록에 `--ac`가 있다 (AC 없음: 3-1 재승인으로 추가)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  A=issue-audit/SKILL.md
  awk '/^### `--plan`$/ { f = 1; next } f && /^### / { exit } f && /^1\. \*\*추적성\*\* / { s = 1 } s && /^2\. / { s = 0 }
       s && index($0, "\"$check_plan\" --ac ") { n++ } END { if (n < 1) print "위반: 관점 1에 --ac 실행 명령 없음" }' "$A"
  H=issue-audit/scripts/check-plan.sh
  for p in 'check-plan.sh --ac ' '연결 없는 AC: ' '없는 AC 참조: ' '출처 없는 항목: ' '대조 불가: '; do
    awk '/^[^#]/ { exit } 1' "$H" | grep -qF -- "$p" || echo "위반: 머리 주석에 [$p] 없음"
  done
  ```

  </details>
- [ ] [D] issue-audit 러너의 `AC 대조:` 케이스가 통과·격추 각 1건 이상 실행되고 러너가 0 실패다 (AC 없음: 3-1 재승인으로 추가)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(bash issue-audit/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- AC 대조: .* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- AC 대조: .* 격추')" -ge 1 ] \
    || echo '위반: 러너 실패 또는 AC 대조 케이스 미실행'
  ```

  </details>

---

## 전제 (Assumptions)

1. **검증 실행 셸**: spec·plan의 검증 명령은 repo 루트에서 `bash`로 실행한다. `testing-principles-local.md`의 테스트 층 표·실행 셸이 비어 있어 템플릿 기본(러너 `*/tests/run-tests.sh`, `ok`/`NOT OK` 행 판독)을 따른다.
2. **출처 AC 표기 형식**: 항목 본문 끝에 `(AC<n>)` 또는 `(AC<n>, AC<m>)`을 두고, `(회귀 방지 항목)`이 있으면 그 앞에 둔다. AC가 없는 R의 항목은 `(AC 없음: <사유>)`로 적는다. 이 spec이 첫 적용 사례이며 R4 구현이 같은 형식을 skill에 적는다.
3. **고정 리터럴**: 위 검증 명령이 고정한 값은 구현이 그대로 쓴다. 대상은 파일명(`issue-body-template.md`, `issue-create-body.md`, `issue-<번호>-body.md`), `--create` 단계 이름 6개, PR 첫 화면 라벨 5개, 접기 안 헤더 5개, 테스트 라벨 9개(`이슈 본문 템플릿:`·`--create 절:`·`AC 정제:`·`변경 통제:`·`본문 갱신 질의:`·`관점 3 범위:`·`AC 대조:`·`PR 본문 구성:`·`승인 요약:`), `check-plan.sh --ac` 출력 접두 4개, 조항 문장이다. 바꿔야 하면 변경 통제(구체화)로 spec을 함께 고친다.
4. **`--create` 제목 전달**: 초안 파일을 1개로 제한하므로 제목은 파일로 두지 않는다. 승인 제시에서 제목 전문을 보이고, 승인한 값을 `--title '<제목>'`로 넘긴다. 값 속 작은따옴표는 `'\''`로 바꾼다 (외부 공개 행위 정책의 동적 인자 규칙).
5. **대상 저장소 확정**: `--create`와 6단계 모두 현재 브랜치 upstream 원격 URL에서 `[호스트/]소유자/저장소`를 정한다. upstream이 없으면 `git config branch.<브랜치>.remote`를 쓰고, 원격이 없거나 여럿이라 정할 수 없으면 사용자에게 묻는다. MCP로 폴백하면 owner·repo를 필수 입력으로 넘긴다 (`30_contract/github-integration.md`).
6. **AC 유무 판정**: 이슈 본문에 `- [ ] AC<n>: ` 또는 `- [x] AC<n>: ` 형식 행이 1개 이상 있으면 AC가 있는 이슈다. 3-2 정제(R4)와 6단계 질의(R6)는 이 판정으로 갈린다.
7. **6단계 갱신 본문**: `gh issue edit --body-file`은 본문 전체를 바꾸므로, 초안은 기존 본문을 그대로 두고 `## 완료의 정의` 섹션만 더한 전체 본문으로 쓴다. 승인되면 spec 완료의 정의 항목에 새 AC의 출처 표기를 채운다. 초안 파일은 `--clear` 5단계에서 정리한다.
8. **PR 완료의 정의 대조 근거**: 이슈 AC와 spec 완료의 정의의 체크 상태로 대조한다. `--clear` 뒤면 spec은 `archive/issue-<번호>/`에 있다. AC가 없는 이슈는 spec R 그룹 기준으로 대조하고 그 사실을 적으며, spec도 없으면 `없음`을 적는다.
9. **PR 첫 화면 항목 고정**: 첫 화면 5항목은 항상 두고, 해당 내용이 없으면 `없음`을 적는다. 그래서 기존 "리스크·주의사항이 없으면 목록 생략" 규칙도 `없음` 표기로 바꾼다.
10. **테크 관점 `실패 경로` 위치**: `호출 흐름` 다음, `참고사항` 앞에 둔다. code-map 러너의 git-pr 시퀀스 검사 구간 끝은 `* **참고사항:**`에서 `* **실패 경로:**`로 옮긴다.
11. **분할 권고 적용 범위**: `--create` 요약 제시 단계에만 둔다. 이미 등록된 이슈로 시작하는 "새 이슈 시작 시" 3-1에는 두지 않는다.
12. **변경 통제 기준선**: 이슈 AC가 있으면 AC를, 없으면 3-1에서 승인된 spec 요구사항을 기준으로 분류한다. 확장의 "범위 확장"은 6단계와 같은 파일·명령·승인 규칙으로 이슈 본문을 갱신하고, spec 요구사항이 바뀌면 3-1 승인 게이트를 다시 거친다.
13. **AC 대조 헬퍼(R13)**: 처음 계획에서는 AC 형식이 새로 생긴다는 이유로 헬퍼를 미루려 했으나, `architecture.md` 판단 체크리스트상 스크립트 후보라 2026-11-01 사용자가 도입을 결정했다(3-1 재승인). 배치·출력 규칙은 아래와 같다.
    - 위치는 issue-audit `check-plan.sh`의 새 모드 `--ac`이고, 사용처는 계획 감사(`--plan`) 관점 1이다. issue-work 3-2는 헬퍼를 부르지 않고 자기 점검으로 둔다(스킬 독립성, ADR 0002).
    - 출력 접두는 `연결 없는 AC: AC<n>`·`없는 AC 참조: AC<n>`·`출처 없는 항목: <spec 행>`·`대조 불가: <사유>`이고, 종료 코드는 기존 규약(0 통과·1 위반·2 사용오류)을 따른다.
    - AC 행 판정은 전제 6, 출처 표기 판정은 전제 2를 따른다. `(AC 없음: …)`은 출처 표기로 인정하고, 출처 표기가 없어도 되는 항목은 `### 공통` 그룹의 `(회귀 방지 항목)` 항목뿐이다.
    - 코드 펜스·HTML 주석 건너뛰기는 `--trace`의 파서 규칙을 같이 쓴다. 행 단위로 읽는 경계(원장 K-0010)는 그대로 이어받으며, 이번 이슈에서 K-0010을 해소하지 않는다(3-1 재승인 때 미포함으로 결정).
    - 감사인은 이슈 본문을 `gh issue view '<번호>' --repo '<대상 저장소>' --json body -q .body`로 받아 파일이나 프로세스 치환으로 넘긴다.
14. **이 이슈의 본문**: R3·R12·R13은 이슈 AC에 없지만 3-1 승인(R13은 재승인)으로 확정했으므로 이슈 #130 본문은 갱신하지 않는다.
15. **범위 밖 문서**: `.ai/60_codebase/` 색인과 `active/issue-workflow.md` 사본은 이번에 고치지 않는다. 색인은 PR의 문서 동기화 점검 권고로 처리하고, 사본은 다음 새 이슈 시작 때 템플릿과 비교해 갱신된다.
16. **git-qa 무변경**: git-qa는 PR 본문에서 이슈 링크만 읽으므로 고치지 않는다 (R11 `[D]`가 무변경을 검사).

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/40_domain/specs/issue-workflow.md` | issue-work 절차·게이트 요건. R2~R6 반영 대상 |
| `.ai/40_domain/specs/issue-audit.md` | issue-audit `--plan` 요건. R7 반영 대상 |
| `.ai/40_domain/specs/git-pr-submission.md` | git-pr 제출 절차 요건. R8·R9 반영 대상 |
| `.ai/40_domain/policies/local/external-action-approval-gate.md` | 외부 공개 행위 승인 게이트. R10 대상 목록 추가, R2·R6 승인 절차 기준 |
| `.ai/40_domain/policies/local/notation-conventions.md` | 옵션 명명 기준(`--create`), 분류 값 표기 |
| `.ai/30_contract/github-integration.md` | `gh` 기본·MCP 폴백, `--repo` 명시, `--body-file` 전달 규약. R2·R6 |
| `.ai/10_rules/writing-principles.md` | 이슈 본문·PR 본문 작성 원칙. R1·R8 |
| `.ai/10_rules/testing-principles-local.md` | 테스트 층 표·실행 셸. R11 |
| ADR 0003 (`50_adr/active/0003-verification-levels-and-determinization.md`) | 검증 레벨·완료 기준 접기 형식·임계 수치 미도입. R3·R4 |
| ADR 0004 (`50_adr/active/0004-cross-model-audit-and-response-gate.md`) | 교차모델 audit·`--response` 게이트. R7 |
| ADR 0010 (`50_adr/active/0010-output-format-templates-separation.md`) | 산출물 형식 블록을 `templates/`로 분리. R1 |
| ADR 0011 (`50_adr/active/0011-git-pr-submission-and-approval-gate.md`) | git-pr 승인 게이트. R9 |
| ADR 0013 (`50_adr/active/0013-long-output-single-file-generation.md`) | 긴 산출물 파일 1회 생성·경로와 요약 제시. R2·R6 |
| ADR 0016 (`50_adr/active/0016-spec-requirements-layer-and-plan-audit.md`) | spec 요구사항 층·요구사항 승인 게이트·계획 감사. R4~R7 |
| ADR 0018 (`50_adr/active/0018-ledger-proactive-review-and-resolve-timing.md`) | 원장 재검토·종결 계기. R5의 원장 등재 선택지 |
| ADR 0024·0025 (`50_adr/active/0024-…`, `50_adr/active/0025-…`) | 시퀀스 다이어그램 대상·규칙·사본 검사. R8 |
