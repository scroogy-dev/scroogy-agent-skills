# Issue #92 스펙 git-review-quiz: PR 변경 이해도를 문항으로 점검하는 스터디 모드 스킬 신설

## 목표 (Goal)

PR 또는 현재 브랜치의 변경에서 비즈니스·테크 관점 문항을 만들어 대화형으로 풀거나 PR 댓글로 게시하는 스킬 `git-review-quiz`를 추가한다. 문항마다 변경 위치를 본문에 두고, 힌트와 정답·해설은 문항별 접기로 둔다.

---

## 범위 (Scope)

**포함 (In)**

- `git-review-quiz/SKILL.md` 신설: 대상 식별, 근거 문서 확보, 문항 생성, 대화형 진행, `--comment` 게시, 옵션 3종
- `git-review-quiz/templates/quiz-template.md`: 산출 파일 형식의 SSoT (아래 "산출 파일 형식 규칙")
- `git-review-quiz/scripts/check-quiz.sh` + `git-review-quiz/tests/`: 산출 파일 형식 검사 헬퍼와 회귀 테스트 (ADR 0001 배치)
- `.ai/AI-CONTEXT.md` 디렉토리 구조·스킬 목록·Git 정책 표, `README.md` Skill 목록·관계도에 새 스킬 반영
- 이 repo의 실제 PR로 시험 실행: `--comment`는 승인 게이트 직전까지(게시하지 않음), 대화형은 3문항 이상 실제 응답

**비포함 (Out)**

- 온보딩용(`.ai/40_domain/` 문서 기반) 문항 스킬. 2026-08-29 논의에서 별도 스킬 방향으로 보류
- 머지 차단 게이트·status check 연동
- 문항을 코드 라인 리뷰 코멘트로 분산 게시하는 방식
- `git-review`의 "문서 부재 시 처리"(추정 문서 작성). 문서가 없으면 테크 문항만 내고 알린다
- 문항 수 옵션(`--count`). 자연어 지정으로 대체
- 응답 정답률의 세션 간 누적·통계

---

## 산출 파일 형식 규칙 (R1~R7)

`templates/quiz-template.md`가 형식의 SSoT이고, `scripts/check-quiz.sh`는 아래 규칙을 옮긴 사본이다. 한쪽을 고치면 다른 쪽과 `tests/`의 기대값을 함께 갱신한다.

| 규칙 | 내용 |
|------|------|
| R1 | 문항 헤더는 `### Q<n> [<관점> · <형식>]` 한 줄이다. `<관점>`은 `비즈니스`/`테크`, `<형식>`은 `객관식`/`주관식`, `<n>`은 1부터 연속 증가 |
| R2 | 문항 블록 안에 `위치: `<경로>:<시작>(-<끝>)?`` 행이 1개 이상 있고, 헤더 다음 첫 비어 있지 않은 행이 위치 행이다. 뒤에 ` (base)` 또는 ` ([permalink](<URL>))` 병기를 허용한다 |
| R3 | `<details>`~`</details>` 안에 `<summary>힌트</summary>`를 둔 힌트 블록이 정확히 1개 |
| R4 | `<summary>정답·해설</summary>`을 둔 정답 블록이 정확히 1개이고 힌트 블록 뒤에 온다 |
| R5 | 객관식은 첫 `<details>` 앞에 `- (a) ` 형식 선택지가 2개 이상, 주관식은 0개 |
| R6 | 문항 블록 안 `<details>` 밖 행 중 `정답`으로 시작하는 행이 0건 (정답 비노출의 형식 검사) |
| R7 | 문서 골격: `## 대상`·`## 문항` 헤더 각 1개, 문항 블록은 `## 문항` 아래에만, 문항이 1개 이상, `## 응답 기록`(선택)은 마지막 문항 블록 뒤에만 온다 |

- 헬퍼 출력 규약: 통과는 무출력·종료 코드 0, 위반은 `위반 R<n> Q<n>: <사유>` 1행씩·종료 코드 1, 사용오류는 종료 코드 2 (`issue-work/scripts/check-clear.sh`와 같은 규약).
- 산출 파일 경로: `.ai/99_workspace/temp_review_quiz.md`. `--comment` 모드는 게시 본문을 `.ai/99_workspace/temp_review_quiz_comment.md`에 따로 쓴다 (위치 행에 permalink 병기, `## 응답 기록` 없음).
- permalink 형식: `https://<호스트>/<소유자>/<저장소>/blob/<커밋 SHA>/<경로>#L<시작>-L<끝>` (한 줄이면 `#L<n>`). 추가·수정 코드는 `headRefOid`, 삭제 코드는 `baseRefOid` 기준.

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D] `git-review-quiz/SKILL.md`의 프론트매터 `name`이 디렉토리명과 일치하고 `description`이 20자 이상이다
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
- [ ] [D] `SKILL.md`에 표준 섹션 5개(`## 개요`, `## 관련 skill`, `## 참조 문서`, `## 옵션`, `## 산출물 접기 기준`)가 있고, `## 옵션` 아래 `### ` 소절 집합이 `--comment`, `--mcq` / `--open`, `--business` / `--tech` 세 개와 정확히 일치한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  f=git-review-quiz/SKILL.md
  for h in '## 개요' '## 관련 skill' '## 참조 문서' '## 옵션' '## 산출물 접기 기준'; do
    [ "$(grep -cE "^$h[[:space:]]*$" "$f")" -eq 1 ] || echo "위반: 섹션 $h"
  done
  awk '/^## 옵션/{f=1; next} /^## /{f=0} f && /^### /' "$f" \
    | diff - <(printf '%s\n' '### `--comment`' '### `--mcq` / `--open`' '### `--business` / `--tech`') \
    >/dev/null || echo '위반: 옵션 소절 집합 불일치'
  ```

  - 설계 주의: 소절 집합을 `diff`로 대조하므로 소절이 빠지거나 남는 변형을 모두 잡는다.
  </details>
- [ ] [D] `tests/run-tests.sh`가 0 실패로 끝나고, 출력에 R1~R7 반례 케이스 통과 행이 각각 1개 이상 있으며, 템플릿 자체가 `check-quiz.sh`를 통과한다
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

  - 설계 주의: 러너 출력 행은 `ok     - R<n>: <설명>` 형식으로 고정해 규칙별 반례 커버리지를 명령으로 센다.
  </details>
- [ ] [D] 테스트 파일이 `git-review-quiz/tests/` 밖에 없고 러너가 `tests/run-tests.sh`에 있다 (ADR 0001 배치, `install-skills` 배포 제외의 전제)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  [ -x git-review-quiz/tests/run-tests.sh ] || echo '위반: tests/run-tests.sh 없음 또는 실행 권한 없음'
  find git-review-quiz -path 'git-review-quiz/tests' -prune -o \
    \( -name '*.test.*' -o -name 'run-tests.sh' -o -name 'fixtures' \) -print
  ```

  </details>
- [ ] [D] 시험 실행 산출 파일이 형식 검사를 통과하고 문항 3개 이상·응답 기록 3행 이상이며, `--comment` 본문 파일의 위치 행에 커밋 SHA permalink가 1개 이상 있다
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

  - 설계 주의: 두 파일은 `--clear` 5단계에서 정리되므로 Task N 검증은 `--clear` 전에 수행한다.
  </details>
- [ ] [D] `.ai/AI-CONTEXT.md`의 디렉토리 구조 트리·스킬 목록 표·Git 정책 표, `README.md`의 Skill 목록 표·관계도에 새 스킬 행이 각 1개 있다
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
- [ ] [D] 새 스킬 디렉토리(`git-review-quiz/`)에 em dash(`—`)가 없다. 이슈 산출 문서는 issue-work 템플릿 고정 블록이 em dash를 포함하므로 대상에서 제외한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -rn '—' git-review-quiz/
  ```

  </details>
- [ ] [QD] 시험 실행 산출물의 모든 문항이 변경 자체를 묻고(일반 지식 문항 0건), 힌트가 정답을 직접 말하지 않으며, 정답 블록의 근거 위치가 실제 diff와 일치한다  (검증: 교차모델 audit이 산출물과 diff를 대조 채점)  ← 강등 사유: 문항·힌트 내용의 의미 판단이라 명령으로 환원 불가
- [ ] [QD] `SKILL.md`가 다른 스킬 파일을 읽지 않고도 절차가 완결된다 (대상 PR 식별·댓글 게시 규칙이 본문에 있음)  (검증: 교차모델 audit이 본문만으로 절차 추적)  ← 강등 사유: 절차 완결성은 서술의 의미 판단
- [ ] [ND] 대화형 진행(한 문항씩 제시, 힌트 요청, 응답 후 정답 공개, 종료 시 결과 요약)이 사용자 체감에서 자연스럽다  (검증: 사용자가 시험 실행에서 확인)  ← 강등 사유: 대화 흐름의 적절성은 사람이 체험해야 판단 가능

---

## 전제 (Assumptions)

- 스킬 이름은 `git-review-quiz`로 확정한다. 사용자가 이 기능을 "리뷰 퀴즈·문제"로 부르므로 의도 기준 명명이며, `git-review` 계열의 대상-행위 패턴과도 맞는다. 온보딩용 문서 기반 스킬은 2026-08-29 논의에서 "입력과 근거 위치가 다르면 별도 스킬"로 정리했고, 만들지 여부는 보류 상태다.
- 옵션 소절 헤더 표기는 `### `--comment``, `### `--mcq` / `--open``, `### `--business` / `--tech``로 고정한다. DoD 2의 `diff` 대조와 결속되어 있어 표기를 바꾸면 검증 명령도 함께 바꾼다.
- 위치 필드 라벨은 `위치:`로 두고 R2 정규식은 `<경로>:<줄 범위>`만 요구한다. 온보딩 스킬이 생기면 문서 경로도 같은 형식으로 담을 수 있으므로 지금 라벨을 일반화하지 않는다.
- 문항 수 기본값은 5, 허용 범위 3~10이다. 변경 파일이 1~2개면 3까지 줄이고, 사용자가 수를 말하면 따른다. `--count` 옵션은 두지 않는다.
- 테크 문항의 소재 축은 `git-review` 테크 리뷰 7 카테고리(기능·아키텍처·버그·보안·코드품질·성능·테스트)를 쓴다. 비즈니스 문항은 `.ai/30_contract/`·`.ai/40_domain/` 문서 조항과 diff의 대응을 묻는다.
- 주관식 판정은 AI가 정답 블록의 해설과 대조해 정답/부분/오답 중 하나로 매기고 근거 한 줄을 붙인다. 객관식은 선택지 문자 비교다.
- `## 응답 기록`은 대화형에서만 만든다. `--comment` 본문 파일에는 없으므로 파일을 그대로 게시한다.
- 브랜치 모드(PR 없음)의 diff는 `git diff $(git merge-base <base> HEAD)`로 작업 트리 변경까지 포함한다. `<base>`는 `origin/HEAD`가 가리키는 브랜치, 없으면 `main`이다. 브랜치 모드에서는 `--comment`를 쓸 수 없고 permalink도 붙이지 않는다.
- 삭제 코드 문항의 base 기준 permalink는 `baseRefOid`를 쓴다. PR 생성 뒤 base가 전진하면 줄이 어긋날 수 있으나, 삭제 코드 문항은 드물어 감수한다 (merge-base 조회 추가는 검토 후 버림).
- 대상 PR 식별·댓글 게시 규칙(`--repo`·`--hostname` 명시, 본문 파일 전달, 승인 게이트)은 `git-pr-feedback/SKILL.md`에서 핵심만 복사하고 "한쪽 변경 시 동기화" 주석을 남긴다. 스킬 독립성 원칙 때문에 참조만으로 대체하지 않는다.
- `--comment` 승인 게이트의 대화 제시분은 파일 경로, 문항 수, 관점별 건수, 위치 목록만이다. 본문 전문은 대화에 다시 출력하지 않는다 (`issue-work --clear` 3단계와 같은 방식).
- R6은 행 시작 `정답` 문자열만 보는 형식 검사다. 문장 속 정답 노출은 DoD의 `[QD]` audit 항목이 맡는다.
- 시험 실행 대상 PR은 이 repo의 머지된 PR #91이다. `.ai/40_domain/`·`.ai/30_contract/`가 비어 있으므로 비즈니스 문항은 나오지 않고, "문서 없음 → 테크 문항만" 경로가 검증된다. 시험 실행 순서는 `--comment` 먼저(게시하지 않고 중단), 대화형 나중이다. 대화형이 주 산출 파일을 덮어쓰므로 순서를 바꾸면 DoD 5의 응답 기록 검사가 실패한다.
- `README.md` 반영은 `readme-sync` 대신 표·관계도 두 행만 수동으로 넣는다. `readme-sync`는 전체 재작성이라 diff가 커진다 (최소 변경 원칙).
- 헬퍼 분리 판정: `check-quiz.sh`는 `.ai/10_rules/architecture.md` 체크리스트 1(같은 입력 같은 출력)·2(문항 생성마다, 게시 전 반복 호출)·3(기계 검증)·4(게시 전 명확한 오류)를 모두 만족해 `scripts/`로 분리한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/10_rules/architecture.md` | 디자인 원칙. 헬퍼 분리 판정 체크리스트 |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | `scripts/`·`tests/` 배치와 배포 제외 |
| `.ai/70_ledger/index.md` | K-0005(배포 제외 패턴 리터럴 복제 주의), K-0006(결정화 선례) |
| `git-review/SKILL.md` | 비즈니스 리뷰 참조 절차와 테크 리뷰 7 카테고리(문항 소재 축의 원본) |
| `git-pr-feedback/SKILL.md` | 대상 PR 식별·댓글 게시·승인 게이트 규칙의 원본 |
| `issue-work/scripts/check-clear.sh` | 검사 헬퍼 출력 규약 선례 |
| `.ai/30_contract/index.md`, `.ai/40_domain/index.md` | 비즈니스 문항 근거 문서 목차 (현재 비어 있음) |
