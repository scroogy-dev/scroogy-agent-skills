# Issue #92 실행계획 git-review-quiz: PR 변경 이해도를 문항으로 점검하는 스터디 모드 스킬 신설

> 스펙: [issue-0092-spec.md](./issue-0092-spec.md)

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
> **문서를 대상으로 검증할 때는 문구가 아니라 행 구조를 셉니다**. 같은 문구가 주석·안내문에도 등장하므로
> `grep -c '<문구>'`는 실제 구조가 없어도 통과합니다. 헤더는 `^## `, Task는 `^### Task `,
> 필드는 `^- \*\*…\*\*:`로 앵커를 고정하고, 명령은 작업 디렉토리에 의존하지 않게 repo 루트 기준 경로로 적습니다.
> **검증 명령 보정은 반례 격추가 아니라 불변식 전수 명세로 합니다**. 지적된 변형 하나만 막으면 이웃 변형이
> 다음 감사에서 재발하므로, 기대 구조를 열거하고 "그 외 0건"까지 판정에 넣습니다.

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

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

### Task 1: 산출 파일 템플릿 quiz-template.md 작성

- [x] 완료
- **목표**: 산출 파일 형식의 SSoT를 `git-review-quiz/templates/quiz-template.md`에 만든다. 이후 Task 2 헬퍼와 Task 3 SKILL.md가 이 파일을 기준으로 삼는다.
- **작업 내용**:
  1. spec "산출 파일 형식 규칙 (R1~R7)"을 골격으로 옮긴다. `# 리뷰 퀴즈 <대상>` 제목, `## 대상`(PR 또는 브랜치, head SHA, 형식·관점, 근거 문서 목록 또는 "없음 (테크 문항만)"), `## 문항`, `## 응답 기록`(대화형 전용 주석 포함, `| 문항 | 응답 | 판정 |` 표) 순서다.
  2. `## 문항` 아래에 예시 문항 두 개를 둔다. `Q1 [테크 · 객관식]`(선택지 3개, 위치 행, 힌트 접기, 정답·해설 접기)과 `Q2 [비즈니스 · 주관식]`(위치 행에 ` ([permalink](https://…/blob/<40자 SHA>/…#L…))` 병기 예시, 정답 블록에 정책 문서 경로 근거). 예시는 실제 형식을 갖춰 템플릿 자체가 R1~R7을 통과하게 한다.
  3. 파일 첫머리 HTML 주석에 "작성 규칙은 `git-review-quiz/SKILL.md`, 형식 검사는 `scripts/check-quiz.sh`, 한쪽 변경 시 동기화"를 적는다. 주석 안 행이 `정답`으로 시작하지 않게 한다 (R6).
  4. 정답·해설 블록 안 형식을 고정한다: 첫 행은 객관식이면 `(<문자>). <근거 한 문장>`, 주관식이면 `<모범 답안 한두 문장>`. 이어서 `근거: `<경로>:<줄>``, 비즈니스 문항이면 `정책 근거: `<.ai 문서 경로>` "<조항>"` 행.
- **완료 기준**:
  - [D] 템플릿에 `## 대상`·`## 문항`·`## 응답 기록` 헤더가 각 1개 있고, 문항 헤더가 `Q1 [테크 · 객관식]`·`Q2 [비즈니스 · 주관식]` 정확히 2개다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    t=git-review-quiz/templates/quiz-template.md
    for h in '## 대상' '## 문항' '## 응답 기록'; do
      [ "$(grep -cE "^$h[[:space:]]*$" "$t")" -eq 1 ] || echo "위반: 헤더 $h"
    done
    grep -E '^### Q[0-9]+ \[' "$t" \
      | diff - <(printf '%s\n' '### Q1 [테크 · 객관식]' '### Q2 [비즈니스 · 주관식]') >/dev/null \
      || echo '위반: 예시 문항 집합 불일치'
    ```

    </details>
  - [D] 템플릿의 두 예시 문항이 각각 위치 행·힌트 블록·정답 블록을 갖추고, Q2 위치 행에 permalink 병기가 있다 (Task 2 헬퍼가 생기기 전의 골격 검사. Task 2 완료 후에는 헬퍼 통과로 대체된다)
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0이면 통과</summary>

    ```bash
    t=git-review-quiz/templates/quiz-template.md
    awk '
      /^### Q[0-9]+ \[/ { if (o) { if (p != 1 || h != 1 || a != 1) b++ }; o = 1; p = 0; h = 0; a = 0; next }
      /^## / { if (o) { if (p != 1 || h != 1 || a != 1) b++ }; o = 0 }
      o && /^위치: `[^`]+:[0-9]+(-[0-9]+)?`/ { p++ }
      o && /^<summary>힌트<\/summary>$/ { h++ }
      o && /^<summary>정답·해설<\/summary>$/ { a++ }
      END { if (o && (p != 1 || h != 1 || a != 1)) b++; print b+0 }
    ' "$t"
    grep -cE '^위치: `[^`]+` \(\[permalink\]\(https://[^)]+/blob/[0-9a-f]{40}/[^)]+\)\)' "$t" | grep -qx 1 || echo '위반: permalink 예시'
    ```

    </details>

---

### Task 2: 형식 검사 헬퍼 check-quiz.sh와 회귀 테스트 작성

- [ ] 완료
- **목표**: spec R1~R7을 결정적으로 판정하는 `git-review-quiz/scripts/check-quiz.sh`와 `git-review-quiz/tests/`(러너·fixture)를 만든다. ADR 0001 배치를 따른다.
- **작업 내용**:
  1. `scripts/check-quiz.sh <파일>`: bash, 외부 의존성 없음. 파일 첫머리 주석에 사용법·종료 코드·"SKILL.md와 템플릿이 SSoT, 이 스크립트는 사본" 문구를 둔다 (`issue-work/scripts/check-clear.sh` 첫머리 형식). 통과 무출력·종료 코드 0, 위반 `위반 R<n> Q<n>: <사유>` 1행씩·종료 코드 1 (R7처럼 문항에 귀속되지 않는 위반은 `위반 R7: <사유>`), 인자 오류·읽을 수 없는 파일은 종료 코드 2.
  2. 판정은 `^### Q[0-9]+ \[` 앵커로 블록을 나누고 블록 단위로 R1~R6을, 파일 전체로 R7을 센다. `<details>` 안팎 판정은 `<details>`/`</details>` 행으로 상태를 토글한다.
  3. `tests/run-tests.sh`: `git-review/tests/run-tests.sh`와 같은 `ok     - ` / `NOT OK - ` 출력·집계 형식. 케이스 이름은 반례가 `R<n>: <설명>`으로 시작하게 고정한다 (spec DoD 3이 이 접두어를 센다).
  4. `tests/fixtures/`: 정상 fixture 2개 이상 (대화형 산출 예시: 응답 기록 있음 / 댓글 본문 예시: permalink 있고 응답 기록 없음)과 R1~R7 반례 각 1개 이상 (예: R1 번호 건너뜀·관점 오기, R2 위치 행 없음·헤더 직후가 위치 행이 아님, R3 힌트 블록 2개·0개, R4 정답 블록이 힌트 앞, R5 객관식 선택지 1개·주관식에 선택지, R6 접기 밖 `정답` 행, R7 `## 문항` 없음·문항 0개·응답 기록이 문항 사이에 위치). 러너는 템플릿 파일도 정상 fixture로 실행한다.
  5. 사용오류 케이스: 인자 없음, 없는 파일, 인자 2개 이상 → 종료 코드 2.
  6. `chmod +x scripts/check-quiz.sh tests/run-tests.sh`.
- **완료 기준**:
  - [D] 러너가 0 실패로 끝나고 R1~R7 반례 통과 행이 각각 1개 이상 있으며, 템플릿이 헬퍼를 통과한다  (spec DoD 3 명령과 동일)
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    out="$(bash git-review-quiz/tests/run-tests.sh 2>&1)" || echo '위반: 테스트 실패'
    for r in R1 R2 R3 R4 R5 R6 R7; do
      printf '%s\n' "$out" | grep -qE "^ok +- $r[ :]" || echo "위반: $r 반례 미검증"
    done
    git-review-quiz/scripts/check-quiz.sh git-review-quiz/templates/quiz-template.md \
      || echo '위반: 템플릿이 형식 검사를 통과하지 못함'
    ```

    </details>
  - [D] 헬퍼 출력 규약이 지켜진다: 정상 fixture는 무출력·종료 0, 반례 fixture는 `위반 R<n>` 행만 출력·종료 1, 사용오류는 종료 2
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    h=git-review-quiz/scripts/check-quiz.sh
    for f in git-review-quiz/tests/fixtures/valid-*.md; do
      out="$("$h" "$f" 2>&1)"; rc=$?
      { [ "$rc" -eq 0 ] && [ -z "$out" ]; } || echo "위반: 정상 fixture $f → rc=$rc, out=[$out]"
    done
    for f in git-review-quiz/tests/fixtures/invalid-*.md; do
      out="$("$h" "$f" 2>&1)"; rc=$?
      { [ "$rc" -eq 1 ] && [ -n "$out" ] && ! printf '%s\n' "$out" | grep -vqE '^위반 R[1-7]( Q[0-9]+)?: '; } \
        || echo "위반: 반례 fixture $f → rc=$rc"
    done
    "$h" >/dev/null 2>&1; [ $? -eq 2 ] || echo '위반: 인자 없음이 종료 2가 아님'
    "$h" /nonexistent/quiz.md >/dev/null 2>&1; [ $? -eq 2 ] || echo '위반: 없는 파일이 종료 2가 아님'
    ```

    - 설계 주의: fixture 파일명을 `valid-*.md`·`invalid-*.md`로 고정해 이 명령이 fixture 집합을 전수로 돈다. 다른 접두어를 쓰면 검사에서 빠진다.
    </details>
  - [D] 테스트 파일이 `tests/` 밖에 없고 러너·헬퍼에 실행 권한이 있다  (spec DoD 4 명령과 동일)
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    [ -x git-review-quiz/tests/run-tests.sh ] || echo '위반: tests/run-tests.sh 없음 또는 실행 권한 없음'
    [ -x git-review-quiz/scripts/check-quiz.sh ] || echo '위반: scripts/check-quiz.sh 실행 권한 없음'
    find git-review-quiz -path 'git-review-quiz/tests' -prune -o \
      \( -name '*.test.*' -o -name 'run-tests.sh' -o -name 'fixtures' \) -print
    ```

    </details>

---

### Task 3: SKILL.md 작성

- [ ] 완료
- **목표**: `git-review-quiz/SKILL.md`를 작성해 스킬이 단독으로 실행되게 한다.
- **작업 내용**:
  1. 프론트매터: `name: git-review-quiz`, `description`은 한 줄로 기능·트리거어("리뷰 퀴즈, review quiz, PR 퀴즈, 스터디 모드, 변경 이해도 점검")를 담는다.
  2. `## 개요`: PR 리뷰·셀프 리뷰 전 이해도 점검이 목적이고 리뷰 지적은 내지 않는다는 경계. 대화형(기본)·`--comment` 두 방식과 산출 파일 경로.
  3. `## 관련 skill`: git-review(독립, 서로 호출 없음), git-review-context(산출물이 있으면 참고, 자동 호출 없음), git-pr-feedback(댓글 게시 규칙 원본), ai-workspace(권장, `.ai/99_workspace/` 경로).
  4. `## 참조 문서`: 공통 규칙 `context-loading.md` 한 줄과 스킬 고유 참조 (`.ai/30_contract/index.md`·`.ai/40_domain/index.md` 비즈니스 문항 근거, `.ai/60_codebase/index.md` 호출 흐름, `writing-principles.md`·`-local.md`).
  5. `## 실행 절차`: 1단계 대상 식별 (PR 번호 인자 → `gh pr view --repo` 불변값 보관, 인자 없음 → 현재 브랜치 열린 PR 자동 감지, 없으면 브랜치 모드; `git-pr-feedback` "대상 PR 식별"의 `--repo`·`--hostname` 규칙을 핵심만 복사하고 동기화 주석) → 2단계 diff 수집 (`gh pr diff` 또는 spec 전제의 브랜치 모드 명령) → 3단계 근거 문서 확보 (index 먼저, 관련 파일만. 없으면 "비즈니스 문항 없음, 테크 문항만" 알림) → 4단계 옵션 확정 (형식 미지정 시 1회 질의, 관점 미지정 시 둘 다, 문항 수 기본 5·범위 3~10) → 5단계 문항 생성·파일 작성 → 6단계 헬퍼 검사 (`check-quiz.sh` 호출 코드 블록, 위반 시 보정 후 재검사) → 7단계 대화형 진행 또는 `--comment` 게시.
  6. `## 문항 생성 규칙`: 근거 규칙 (변경 위치 필수, 비즈니스 문항은 문서 근거 필수, 일반 지식 문항 금지, 소재는 기능 구현부·정책 우선), 테크 소재 축(git-review 7 카테고리), 힌트 규칙(정답 직접 언급 금지, 볼 위치·조건만), 정답 블록 형식(Task 1의 4번), 삭제 코드는 ` (base)` 표기.
  7. `## 대화형 진행`: 한 문항씩 위치·문제·선택지 제시 → 응답 → 판정(객관식 문자 비교, 주관식은 해설 대비 정답/부분/오답 + 근거 한 줄) → 정답·해설 제시 → `## 응답 기록` 표 갱신 → 다음 문항. "힌트" 요청 시 힌트만, "건너뛰기"·"그만" 지원. 종료 시 결과 요약(정답 수/문항 수, 틀린 문항의 위치 목록).
  8. `## 옵션`: `### `--comment``(PR 대상에서만, 본문 파일 `temp_review_quiz_comment.md` 생성, 위치 행에 permalink 병기, 승인 게이트에서 파일 경로·문항 수·관점별 건수·위치 목록만 제시하고 전문 재출력 금지, 승인 시 `gh pr comment '<PR 번호>' --repo '<호스트>/<소유자>/<저장소>' --body-file '<본문 파일>'`), `### `--mcq` / `--open``, `### `--business` / `--tech``(문서 없이 `--business`만 지정하면 그 사실을 알리고 중단).
  9. `## 산출물 접기 기준`: 다른 스킬과 같은 고정 블록. `## 결과 기록`: 템플릿 참조 한 줄과 파일 경로 안내.
  10. 산출물 작성 원칙(`.ai/10_rules/writing-principles.md`)의 번역투 금지 패턴을 본문에 적용한다. em dash 0건.
- **완료 기준**:
  - [D] 프론트매터 `name`·`description`이 규격을 만족한다  (spec DoD 1 명령과 동일)
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    f=git-review-quiz/SKILL.md
    fm="$(awk '/^---$/{c++; next} c==1' "$f" 2>/dev/null)"
    { printf '%s\n' "$fm" | grep -qE '^name: git-review-quiz$' \
      && printf '%s\n' "$fm" | grep -qE '^description: .{20,}'; } \
      || echo '위반: 프론트매터 name/description'
    ```

    </details>
  - [D] 표준 섹션 5개와 작업 내용의 고유 섹션 3개(`## 실행 절차`, `## 문항 생성 규칙`, `## 대화형 진행`)가 각 1개 있고, `## 옵션` 소절 집합이 세 개와 정확히 일치한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    f=git-review-quiz/SKILL.md
    for h in '## 개요' '## 관련 skill' '## 참조 문서' '## 실행 절차' '## 문항 생성 규칙' '## 대화형 진행' '## 옵션' '## 산출물 접기 기준'; do
      [ "$(grep -cE "^$h[[:space:]]*$" "$f")" -eq 1 ] || echo "위반: 섹션 $h"
    done
    awk '/^## 옵션/{f=1; next} /^## /{f=0} f && /^### /' "$f" \
      | diff - <(printf '%s\n' '### `--comment`' '### `--mcq` / `--open`' '### `--business` / `--tech`') \
      >/dev/null || echo '위반: 옵션 소절 집합 불일치'
    ```

    </details>
  - [D] 본문의 bash 코드 블록 안에 `check-quiz.sh` 호출과 `gh pr comment … --body-file` 호출이 각 1회 이상 있다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    f=git-review-quiz/SKILL.md
    code="$(awk '/^```bash/{f=1; next} /^```/{f=0} f' "$f")"
    printf '%s\n' "$code" | grep -q 'check-quiz.sh' || echo '위반: 헬퍼 호출 코드 블록 없음'
    printf '%s\n' "$code" | grep -qE "gh pr comment .*--repo .*--body-file" || echo '위반: 댓글 게시 명령 없음'
    ```

    </details>
  - [D] em dash 0건  (spec DoD 7 명령과 동일: `grep -rn '—' git-review-quiz/`)
  - [QD] 다른 스킬 파일을 읽지 않고도 절차가 완결된다  (검증: 교차모델 audit이 본문만으로 절차 추적)  ← 강등 사유: 절차 완결성은 서술의 의미 판단

---

### Task 4: AI-CONTEXT.md와 README.md에 새 스킬 반영

- [ ] 완료
- **목표**: repo 안내도와 README에 `git-review-quiz`를 등록한다.
- **작업 내용**:
  1. `.ai/AI-CONTEXT.md` 디렉토리 구조 트리: `git-review-context/` 블록 뒤에 `git-review-quiz/` 블록을 넣는다. 하위 행은 `scripts/`(형식 검사 헬퍼 (check-quiz.sh)), `templates/`(퀴즈 산출 템플릿), `tests/`(헬퍼 테스트 + fixture (배포 제외)). 기존 행의 `#` 정렬 열에 맞춘다.
  2. `.ai/AI-CONTEXT.md` 스킬 목록 표: `git-review-context` 행 뒤에 `| `git-review-quiz` | PR 변경에서 비즈니스·테크 문항을 만들어 대화형으로 풀거나 PR 댓글로 게시 (문항별 변경 위치 표시, 힌트·정답 접기) |`.
  3. `.ai/AI-CONTEXT.md` Git 정책 표: `/git-review` 행 뒤에 `| `/git-review-quiz` | PR 변경 이해도 문항 생성·진행 | 리뷰 전 이해도 점검 시 |`.
  4. `README.md` Skill 목록 표에 `[git-review-quiz](./git-review-quiz/)` 행, 관계도에 `├── git-review-quiz     ← .ai/ 문서 활용, git-review와 독립` 행을 `git-review-context` 행 뒤에 넣는다. `readme-sync`는 실행하지 않는다 (spec 전제).
  5. `.ai/AI-CONTEXT.md` 상단 `last updated`를 작업일로 갱신한다.
- **완료 기준**:
  - [D] 다섯 위치에 새 스킬 행이 각 1개 있다  (spec DoD 6 명령과 동일)
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    c() { [ "$(grep -cE "$2" "$1")" -eq 1 ] || echo "위반: $1 — $2"; }
    c .ai/AI-CONTEXT.md '^├── git-review-quiz/ +#'
    c .ai/AI-CONTEXT.md '^\| `git-review-quiz` \|'
    c .ai/AI-CONTEXT.md '^\| `/git-review-quiz` \|'
    c README.md '^\| \[git-review-quiz\]\(\./git-review-quiz/\) \|'
    c README.md '^├── git-review-quiz +←'
    ```

    </details>
  - [D] 트리 블록의 하위 행 3개(`scripts/`, `templates/`, `tests/`)가 `git-review-quiz/` 행 바로 아래에 순서대로 있다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    awk '/^├── git-review-quiz\//{f=1; next} f && /^├── /{exit} f' .ai/AI-CONTEXT.md \
      | sed -E 's/^│   [├└]── ([a-z]+\/).*/\1/' \
      | diff - <(printf '%s\n' 'scripts/' 'templates/' 'tests/') >/dev/null \
      || echo '위반: 트리 하위 행 불일치'
    ```

    </details>

---

### Task 5: 실제 PR로 시험 실행

- [ ] 완료
- **목표**: 이 repo의 머지된 PR #91을 대상으로 두 방식을 실제로 실행해 산출물이 형식·근거 규칙을 지키는지 확인한다.
- **작업 내용**:
  1. `--comment` 먼저: `git-review-quiz #91 --comment --mcq`로 실행한다. `.ai/40_domain/`·`.ai/30_contract/`가 비어 있어 "비즈니스 문항 없음, 테크 문항만" 알림이 나와야 한다. 승인 게이트에서 파일 경로·문항 수·관점별 건수·위치 목록이 제시되면 **게시하지 않고 중단**한다. `.ai/99_workspace/temp_review_quiz_comment.md`가 남는다.
  2. 대화형 나중: `git-review-quiz #91 --mcq`로 실행해 문항 3개 이상에 실제로 응답한다. 한 문항에서 "힌트"를 요청하고, 최소 1문항은 일부러 틀려 오답 판정·해설 흐름을 확인한다. 종료 시 결과 요약을 받는다. `.ai/99_workspace/temp_review_quiz.md`에 `## 응답 기록`이 남는다.
  3. 두 파일에 `check-quiz.sh`를 실행해 통과를 확인한다. 위반이 나오면 SKILL.md 절차(6단계 보정)의 결함이므로 SKILL.md를 고치고 재실행한다.
  4. 시험에서 드러난 절차 결함(문항 소재 쏠림, 힌트가 정답 노출, 위치 줄 범위 오류)은 SKILL.md 규칙을 보정하고 summary `특이 사항`에 남긴다.
- **완료 기준**:
  - [D] 두 산출 파일이 형식 검사를 통과하고 문항 3개 이상·응답 기록 3행 이상이며 댓글 본문에 permalink가 있다  (spec DoD 5 명령과 동일)
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    q=.ai/99_workspace/temp_review_quiz.md
    c=.ai/99_workspace/temp_review_quiz_comment.md
    git-review-quiz/scripts/check-quiz.sh "$q" || echo '위반: 산출 파일 형식'
    [ "$(grep -cE '^### Q[0-9]+ \[' "$q")" -ge 3 ] || echo '위반: 문항 3개 미만'
    [ "$(awk '/^## 응답 기록/{f=1; next} f && /^\| Q[0-9]+ \|/' "$q" | wc -l)" -ge 3 ] || echo '위반: 응답 기록 3행 미만'
    git-review-quiz/scripts/check-quiz.sh "$c" || echo '위반: 댓글 본문 형식'
    grep -qE '^위치: `[^`]+` \(\[permalink\]\(https://[^)]+/blob/[0-9a-f]{40}/[^)]+\)\)' "$c" \
      || echo '위반: permalink 없음'
    ```

    </details>
  - [D] 댓글 본문의 permalink SHA가 PR #91의 head SHA이고, 댓글 본문에는 `## 응답 기록`이 없으며, PR #91에 이 시험에서 게시한 댓글이 없다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    c=.ai/99_workspace/temp_review_quiz_comment.md
    head_sha="$(gh pr view 91 --repo github.com/scroogy-dev/scroogy-agent-skills --json headRefOid --jq .headRefOid)"
    grep -oE 'blob/[0-9a-f]{40}/' "$c" | sort -u | grep -vqx "blob/$head_sha/" && echo '위반: head SHA가 아닌 permalink'
    grep -qE '^## 응답 기록' "$c" && echo '위반: 댓글 본문에 응답 기록 존재'
    n="$(gh api --hostname github.com --paginate repos/scroogy-dev/scroogy-agent-skills/issues/91/comments --jq '[.[] | select(.body | test("^# 리뷰 퀴즈"))] | length')"
    [ "$n" -eq 0 ] || echo "위반: PR #91에 퀴즈 댓글 ${n}건 게시됨"
    ```

    - 설계 주의: 삭제 코드 문항이 있으면 `baseRefOid` permalink가 섞이므로, 그 경우 위 SHA 대조에서 `(base)` 표기 행을 제외하고 다시 판정한다.
    </details>
  - [QD] 모든 문항이 변경 자체를 묻고 힌트가 정답을 직접 말하지 않으며 정답 블록의 근거 위치가 diff와 일치한다  (검증: 교차모델 audit이 산출물과 `gh pr diff 91`을 대조 채점)  ← 강등 사유: 의미 판단
  - [ND] 대화형 진행이 사용자 체감에서 자연스럽다  (검증: 사용자가 시험 실행에서 확인)  ← 강등 사유: 대화 흐름의 적절성은 사람이 체험해야 판단 가능

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

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
  3. 사용자가 audit 결과(지적 사항·감사 모델)를 summary에 반영·기록한다. 발견사항 보정은 issue-work `--response`로 검토한다. **피드백 먼저, 항목별 승인 후에만** 앞 Task를 보정하며, 리포트를 받자마자 자동 보정하지 않는다.
- **완료 기준**:
  - [D] spec `완료의 정의`의 `[D]` 항목 검증 명령 전부 통과  (검증: 해당 명령 재실행)
  <!-- 아래 5개 항목은 순서가 아니라 의존 관계다: 선행 조건(Task 집합 일치 → 결과 확정 → 수행 모델 채움)이 서지 않으면 교차 벤더 비교가 공집합이 되어 통과처럼 보인다. -->
  - [D] summary의 Task 헤더 집합이 plan과 일치한다. 블록 전체 누락·Task N 누락·빈 summary·두 경로 오기를 차단하며, 아래 두 게이트의 선행 조건이라 블록 자체가 없으면 그 두 게이트는 검사 대상이 사라져 그대로 통과한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    P=.ai/90_issues/active/issue-0092/issue-0092-plan.md
    S=.ai/90_issues/active/issue-0092/issue-0092-summary.md
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
    S=.ai/90_issues/active/issue-0092/issue-0092-summary.md
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
    S=.ai/90_issues/active/issue-0092/issue-0092-summary.md
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
