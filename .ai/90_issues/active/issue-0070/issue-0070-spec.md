# Issue #70 스펙 AI-CONTEXT.md·ai-workspace 템플릿 Git 정책 표에 git-pr-feedback 행 추가

## 목표 (Goal)

repo 안내도와 ai-workspace 템플릿(dev·doc)의 `## Git 정책` 표에 `/git-pr-feedback` 행이 추가되어, PR 리뷰 코멘트 대응 시 따라야 할 스킬 지침이 표에서 누락되지 않는다.

---

## 범위 (Scope)

**포함 (In)**

- `.ai/AI-CONTEXT.md` — `## Git 정책` 표에 `/git-pr-feedback` 행 1개 추가
- `ai-workspace/templates/dev/.ai/AI-CONTEXT.md` — 같은 표에 같은 행 추가
- `ai-workspace/templates/doc/.ai/AI-CONTEXT.md` — 같은 표에 같은 행 추가

**비포함 (Out)**

- `git-qa`의 표 등재 — 표 성격(commit·PR·리뷰 정책)상 의도적 제외 가능성이 있어 다루지 않음 (이슈 #70 본문 합의)
- `README.md` — 스킬 목록·관계도에 이미 반영되어 있어 변경 없음
- ai-workspace update(멱등 보강) 흐름에 Git 정책 표 검사 신설 — update는 이 표를 검사하지 않으며, 검사 추가는 별도 판단

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D] 대상 3개 파일 각각의 `## Git 정책` 표 skill 집합·순서가 기대 5종(`/git-commit`, `/git-pr`, `/git-pr-feedback`, `/git-review-context`, `/git-review`)과 일치한다 — 누락·중복·오배치를 차단하며, 아래 표 동일성 검증의 선행 조건이라 이 항목이 무너지면 그 검증은 빈 추출끼리 비교해 통과처럼 보인다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for f in .ai/AI-CONTEXT.md \
           ai-workspace/templates/dev/.ai/AI-CONTEXT.md \
           ai-workspace/templates/doc/.ai/AI-CONTEXT.md; do
    diff <(awk '/^## Git 정책/{s=1;next} /^## /{s=0} s && /^\| `/{print $2}' "$f") \
         <(printf '%s\n' '`/git-commit`' '`/git-pr`' '`/git-pr-feedback`' '`/git-review-context`' '`/git-review`') \
      >/dev/null || echo "위반: $f 표 skill 집합·순서 불일치"
  done
  ```

  - 설계 주의: 행 개수만 세면 오배치·중복이 통과하므로 기대 목록과 순서까지 diff로 대조한다. 표 헤더 행(`| Skill |`)은 백틱 시작 조건(`^\| \``)으로 제외된다.
  </details>
- [ ] [D] 대상 3개 파일의 `## Git 정책` 표 행 본문이 서로 동일하다 — repo 안내도와 템플릿 간 문구 표류 차단. 위 집합·순서 항목이 각 파일의 표 실재(5행)를 보장하는 선행 조건이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  x() { awk '/^## Git 정책/{s=1;next} /^## /{s=0} s && /^\| `/{print}' "$1"; }
  diff <(x .ai/AI-CONTEXT.md) <(x ai-workspace/templates/dev/.ai/AI-CONTEXT.md) >/dev/null || echo '위반: repo↔dev 표 불일치'
  diff <(x .ai/AI-CONTEXT.md) <(x ai-workspace/templates/doc/.ai/AI-CONTEXT.md) >/dev/null || echo '위반: repo↔doc 표 불일치'
  ```

  - 설계 주의: 섹션이 두 파일 모두에 없으면 빈 추출끼리 비교해 통과한다 — 표 실재 판정은 위 집합·순서 항목에만 있다.
  </details>
- [ ] [D] 변경 파일이 대상 3개 파일과 이슈 문서(`.ai/90_issues/`, `.ai/99_workspace/`)로 한정된다 — 최소 변경 원칙 위반 차단
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  git diff main...HEAD --name-only \
    | grep -v '^\.ai/90_issues/' \
    | grep -v '^\.ai/99_workspace/' \
    | grep -vxE '\.ai/AI-CONTEXT\.md|ai-workspace/templates/(dev|doc)/\.ai/AI-CONTEXT\.md'
  ```

  - 설계 주의: `main..HEAD`(두 점)는 main이 전진하면 무관한 변경까지 잡으므로 merge-base 기준 세 점(`main...HEAD`)을 쓴다.
  </details>
- [ ] [ND] 추가 행의 설명·사용 시점 문구가 git-pr-feedback 스킬의 실제 동작과 부합한다  (검증: 사람 리뷰)  ← 강등 사유: 문구 적정성은 의미 판단이라 명령으로 환원 불가

---

## 전제 (Assumptions)

- 행 삽입 위치는 `/git-pr` 바로 아래 — README 관계도의 "git-pr 제출 후 단계"와 정합하고, 표의 기존 순서(알파벳순이기도 함)를 유지한다. 검토 후 버린 대안: `/git-review` 아래 배치(시간순 해석) — 부모 스킬(git-pr) 인접성과 알파벳순이 모두 깨져 버림.
- 행 문구는 이슈 #70 본문의 예시 그대로 쓴다 — Skill `/git-pr-feedback`, 설명 "PR 리뷰 코멘트 검토·대응 규칙", 사용 시점 "PR 리뷰 코멘트 대응 시".
- 템플릿의 Git 정책 표는 조건부 안내("아래 skill이 설치되어 있으면")라 스킬 미설치 repo에 행이 있어도 무해하다 — 템플릿 등재의 근거.
- ai-workspace update(멱등 보강) 흐름은 `## Git 정책` 표를 검사하지 않는다(ai-workspace/SKILL.md에 해당 검사 없음) — 템플릿 수정이 기존 repo에 자동 전파되지 않으며, 이 repo 안내도는 이 이슈에서 직접 수정한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/AI-CONTEXT.md` | 수정 대상 — repo 안내도의 `## Git 정책` 표 |
| `ai-workspace/templates/dev/.ai/AI-CONTEXT.md` | 수정 대상 — dev 프로파일 템플릿 |
| `ai-workspace/templates/doc/.ai/AI-CONTEXT.md` | 수정 대상 — doc 프로파일 템플릿 |
| `README.md` | 참고 — 관계도에 "git-pr 제출 후 단계"로 기재, 이미 반영됨 |
| `.ai/10_rules/writing-principles.md` | 산출물 작성 원칙 |
