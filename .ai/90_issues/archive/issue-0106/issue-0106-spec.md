# Issue #106 스펙 ai-workspace 템플릿: Git 정책·이슈 작업 워크플로우 표에 git-review-quiz 행과 issue-audit 계획 감사 반영

## 목표 (Goal)

ai-workspace로 새로 만드는 안내도의 Git 정책·이슈 작업 워크플로우 표가 이 repo 안내도(`.ai/AI-CONTEXT.md`)의 같은 표와 일치한다.

---

## 요구사항 (Requirements)

**포함**

- R1: dev·doc 템플릿(`ai-workspace/templates/{dev,doc}/.ai/AI-CONTEXT.md`)의 `## Git 정책` 표에 `/git-review-quiz` 행이 `/git-review` 행 바로 아래에 있다.
- R2: dev·doc 템플릿의 `## 이슈 작업 워크플로우` 표 `/issue-audit` 행이 설명 "이슈 스펙 대비 구현 독립 감사, `--plan` 계획 감사", 사용 시점 "계획·구현 검증 시"를 담는다.
- R3: `ai-workspace/SKILL.md`의 관련 skill 목록에 `git-review-quiz` 항목이 있고, `issue-audit` 항목이 `--plan` 계획 감사를 언급한다. (이슈 본문 근거 없음. 2026-10-01 spec 작성 중 같은 누락을 발견해 추가)

**제외**

- `.ai/AI-CONTEXT.md` 수정: 두 표가 이미 반영되어 있어 변경할 것이 없다.
- 두 표 외 템플릿 섹션의 정합 점검: 이슈 본문에서 범위 밖으로 정했다.
- `check-context.sh`에 `## Git 정책` 표 검사 추가: update 멱등 보강 검사의 범위 변경이며 #70부터 미해결 리스크로 남겨 둔 별도 사안이다.

---

## 완료의 정의 (Definition of Done)

> **검증 레벨**: 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적: 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적: 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적: 사람이 직접 읽고 판단

### R1: Git 정책 표

- [ ] [D]  dev·doc 템플릿의 `## Git 정책` 표 행이 `.ai/AI-CONTEXT.md`의 같은 표 행과 순서까지 일치한다 (`/git-review-quiz` 행의 존재·위치·문구를 함께 보장)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  sec() { awk -v h="$1" '$0==h{f=1;next} f&&/^## /{f=0} f&&/^\|/' "$2"; }
  h='## Git 정책'
  a=$(sec "$h" .ai/AI-CONTEXT.md)
  printf '%s\n' "$a" | grep -qF '| `/git-review-quiz` |' || echo '위반: 기준 표에 git-review-quiz 행 없음'
  for p in dev doc; do
    b=$(sec "$h" "ai-workspace/templates/$p/.ai/AI-CONTEXT.md")
    [ -n "$b" ] && [ "$a" = "$b" ] || echo "위반: $p 템플릿 $h 표 불일치"
  done
  ```

  - 설계 주의: 기준 표가 비거나 행이 빠진 채 템플릿과 같아지면 비교가 무의미해지므로, 기준 표에 `/git-review-quiz` 행이 있는지 먼저 확인한다. 템플릿에 헤더가 없으면 `b`가 비어 위반으로 나온다.
  </details>

### R2: issue-audit 행

- [ ] [D]  dev·doc 템플릿의 `## 이슈 작업 워크플로우` 표 행이 `.ai/AI-CONTEXT.md`의 같은 표 행과 순서까지 일치한다 (`/issue-audit` 행의 `--plan` 계획 감사 설명·사용 시점을 함께 보장)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  sec() { awk -v h="$1" '$0==h{f=1;next} f&&/^## /{f=0} f&&/^\|/' "$2"; }
  h='## 이슈 작업 워크플로우'
  a=$(sec "$h" .ai/AI-CONTEXT.md)
  printf '%s\n' "$a" | grep -E '^\| `/issue-audit` \|' | grep -qF -- '--plan' || echo '위반: 기준 표 issue-audit 행에 --plan 없음'
  for p in dev doc; do
    b=$(sec "$h" "ai-workspace/templates/$p/.ai/AI-CONTEXT.md")
    [ -n "$b" ] && [ "$a" = "$b" ] || echo "위반: $p 템플릿 $h 표 불일치"
  done
  ```

  </details>

### R3: ai-workspace SKILL.md 관련 skill 목록

- [ ] [D]  `## 이 구조와 함께 사용 가능한 skill` 목록에 `git-review-quiz` 항목이 정확히 1개 있고, `git-review-context`와 `issue-audit` 사이에 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  F=ai-workspace/SKILL.md
  n=$(awk '/^## /{f=($0=="## 이 구조와 함께 사용 가능한 skill")} f' "$F" \
    | grep -oE '^- \*\*[a-z-]+\*\*' | sed -E 's/^- \*\*//; s/\*\*$//' | tr '\n' ' ')
  [ "$(printf '%s' "$n" | tr ' ' '\n' | grep -cx 'git-review-quiz')" = 1 ] || echo "위반: git-review-quiz 항목 수가 1이 아님: $n"
  printf ' %s' "$n" | grep -qF ' git-review-context git-review-quiz issue-audit ' || echo "위반: git-review-quiz 위치 불일치: $n"
  ```

  </details>
- [ ] [D]  같은 목록의 `issue-audit` 항목이 정확히 1개이고 `--plan` 계획 감사를 언급한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  F=ai-workspace/SKILL.md
  L=$(awk '/^## /{f=($0=="## 이 구조와 함께 사용 가능한 skill")} f' "$F" | grep -E '^- \*\*issue-audit\*\*:')
  [ "$(printf '%s\n' "$L" | grep -c .)" = 1 ] || echo '위반: issue-audit 항목 수가 1이 아님'
  printf '%s\n' "$L" | grep -F -- '--plan' | grep -qF '계획 감사' || echo '위반: issue-audit 항목에 --plan 계획 감사 언급 없음'
  ```

  </details>
- [ ] [QD] 두 항목의 설명이 각 스킬의 실제 동작(`git-review-quiz/SKILL.md`, `issue-audit/SKILL.md`)과 어긋나지 않는다  (검증: 교차모델 audit이 채점)  ← 강등 사유: 설명 문장과 스킬 동작의 의미 대조라 명령으로 환원할 수 없다

### 공통

- [ ] [D]  이 브랜치의 변경 파일이 대상 3개 파일, 이슈 작업 문서(`.ai/90_issues/`, `.ai/99_workspace/`), 계획 감사 F-2로 갱신한 원장 K-0011과 원장 index뿐이며, `.ai/AI-CONTEXT.md`는 바뀌지 않았다. 회귀 방지 항목: 구현 전에도 통과하는 것이 정상이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  base=$(git merge-base HEAD main)
  { git diff --name-only "$base"; git ls-files --others --exclude-standard; } | sort -u \
    | grep -vxE 'ai-workspace/templates/(dev|doc)/\.ai/AI-CONTEXT\.md|ai-workspace/SKILL\.md|\.ai/(90_issues|99_workspace)/.*|\.ai/70_ledger/(index\.md|active/K-0011-[^/]+\.md)' \
    | sed 's/^/위반: 범위 밖 변경 /'
  ```

  - 설계 주의: 커밋 전 작업 트리 변경과 추적되지 않는 새 파일까지 함께 본다. `.ai/AI-CONTEXT.md`가 바뀌면 허용 목록 밖이라 위반으로 나온다. `.ai/99_workspace/`는 감사 리포트가 놓이는 작업 영역이라 허용한다. 원장은 K-0011 파일과 index만 허용해 다른 항목의 변경은 위반으로 잡는다.
  </details>
- [ ] [D]  이 브랜치에서 대상 3개 파일에 추가한 행에 em dash(`—`)가 없다. 회귀 방지 항목: 구현 전에도 통과하는 것이 정상이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  base=$(git merge-base HEAD main)
  git diff "$base" -- ai-workspace/templates/dev/.ai/AI-CONTEXT.md ai-workspace/templates/doc/.ai/AI-CONTEXT.md ai-workspace/SKILL.md \
    | grep -E '^\+[^+]' | grep -F '—'
  ```

  </details>
- [ ] [D]  ai-workspace 테스트 러너가 0 실패로 끝난다. 회귀 방지 항목: 구현 전에도 통과하는 것이 정상이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  ai-workspace/tests/run-tests.sh >/dev/null 2>&1 || echo '위반: ai-workspace 테스트 실패'
  ```

  </details>

---

## 전제 (Assumptions)

- 기준 표는 `.ai/AI-CONTEXT.md`다. 이 파일의 두 표는 #92·#100에서 이미 갱신되어 올바른 값으로 본다. 템플릿을 이 표에 맞추며, 기준 쪽은 고치지 않는다.
- R3은 이슈 본문 범위 밖이다. spec 작성 중 발견해 2026-10-01 사용자 승인으로 포함했다. PR 본문에 이 사실을 적는다.
- R3에 넣을 문구는 plan Task 2에 확정해 두었다. 목록의 기존 항목 형식(`- **<스킬>**: <설명> (<활용 경로>)`)과 알파벳 순서를 따른다.
- 검증 명령은 repo 루트에서 실행하고, 로컬 `main` 브랜치가 있어야 한다(`git merge-base HEAD main`). bash·zsh 양쪽에서 구현 전 상태에 위반을 내는 것을 확인했다.
- 계획 감사(2026-10-01) F-2 처리로 원장 K-0011을 이 브랜치에서 갱신했다(계속 수용, 재검토 조건 정리). 이 때문에 변경 범위 검사가 K-0011 파일과 원장 index를 허용한다.
- `check-context.sh`가 `## Git 정책` 표를 검사하지 않으므로, 이미 설치된 다른 repo의 안내도에는 ai-workspace update로 이 변경이 자동 전파되지 않는다. 이 이슈는 템플릿만 고치며 전파는 다루지 않는다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/40_domain/specs/ai-workspace.md` | 템플릿·update 멱등 보강 검사 범위(`## Git 정책` 표 미검사) 확인 |
| `.ai/40_domain/policies/local/notation-conventions.md` | 스킬·옵션 표기 기준 |
| `.ai/50_adr/active/0016-spec-requirements-layer-and-plan-audit.md` | `--plan` 계획 감사 도입 결정(반영할 설명의 근거) |
| `.ai/50_adr/active/0017-git-review-quiz-study-mode.md` | git-review-quiz 신설 결정(추가할 행의 근거) |
| `.ai/AI-CONTEXT.md` | 두 표의 기준 값 |
