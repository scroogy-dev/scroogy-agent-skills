# Issue #110 스펙 git-pr·issue-work: 원장 재검토·해소 트리거 보강 (PR 문서 동기화 점검과 이슈 시작 단계에서 active 항목 대조)

## 목표 (Goal)

일반 작업이 원장 `active/` 항목의 재검토 조건을 충족하거나 원인을 없애면, 감사·리뷰에서 같은 결함이 다시 나오지 않아도 PR 작성과 이슈 시작 단계에서 그 항목의 재검토·종결이 권고된다.

---

## 요구사항 (Requirements)

**포함**

- R1: git-pr 문서 동기화 점검 표에 원장 대조 행이 있다. diff가 `active/` 항목의 재검토 조건이 가리키는 파일·규칙이나 항목 원인 파일을 바꾸면 해당 `K-<번호>`의 재검토 이력 기록 또는 종결을 권고하고, 같은 PR 반영은 승인분만 한다. 원장 index나 해당 항목이 없으면 행을 생략한다.
- R2: git-pr "참조 문서"가 `.ai/70_ledger/index.md`를 index 먼저, 관련 항목만 읽는 방식으로 안내한다.
- R3: issue-work 새 이슈 시작 3-1이 연관 문서 후보와 함께 `.ai/70_ledger/index.md`를 훑어, 이슈 범위와 관련된 `active/` 항목을 "함께 해소 후보"로 따로 표시해 제시하고 포함 여부를 질의한다. 포함하면 요구사항(R)에 넣고, 포함하지 않은 후보는 기록하지 않는다.
- R4: issue-work SKILL.md가 R3로 포함한 원장 항목에 `해소(PR #N)`를 적는 시점을 PR 번호를 알 수 있는 시점 기준으로 정해 안내한다. `--response`의 원장 종결 규칙(재제기 반영·보정으로 원인이 사라진 기등재 종결)도 같은 시점 규칙을 따른다. (`--response` 적용은 이슈 본문 근거 없음, 2026-10-10 Task 0에서 사용자 확정)
- R5: issue-work spec 템플릿에 함께 해소할 원장 항목의 기재 위치(요구사항 또는 연관 문서)를 둘지 검토하고, 두기로 하면 반영한다. (이슈 본문은 "필요한지 검토한다"로 남김)
- R6: 원장 index 수명 주기 표가 재검토·종결 계기에 git-pr 문서 동기화 점검과 issue-work 이슈 시작 단계를 반영한다. `ai-workspace/templates/shared/.ai/70_ledger/index.md`와 이 repo의 `.ai/70_ledger/index.md` 사본을 함께 고친다.
- R7: ADR 0007의 원장 소비자 목록 변경을 기존 ADR 갱신과 새 ADR 중 판단해 기록한다.
- R8: 안내도 `.ai/40_domain/specs/git-pr-submission.md`·`.ai/40_domain/specs/issue-workflow.md`·`.ai/60_codebase/git-pr/submit-call-flow.md`·`.ai/60_codebase/issue-work/start-call-flow.md`가 바뀐 단계를 반영한다.
- R9: 첫 적용 사례로 K-0006의 `재검토 이력`을 남기고 계속 수용할지 승격할지 정한다. 결과에 따라 `.ai/70_ledger/index.md` 항목 목록을 갱신한다.

**제외**

- 시간 기준 주기 점검(`/schedule` 등): 이슈 본문이 범위에서 제외(불필요).
- 재검토 조건 충족의 결정적 판정 헬퍼: 조건이 자유 문장이라 명령으로 환원하기 어렵다(보류).
- issue-audit·git-pr-feedback의 기존 재검토·종결 계기 변경: 이슈 본문이 범위에서 제외(불필요).
- K-0006 본건(code-map `check` 결정화) 구현: 이슈 본문이 범위에서 제외(보류).
- 원장 상태 자동 변경: 두 지점 모두 권고·질의까지만 한다(이슈 본문 요약의 경계).

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> 검증 명령은 모두 repo 루트에서 실행한다. 용어 `원장 대조`(git-pr 행)·`함께 해소 후보`(issue-work 3-1)는 아래 명령이 앵커로 쓰는 고정 리터럴이다(전제 참조).

### R1: git-pr 원장 대조 행

- [ ] [D]  `## 문서 동기화 점검` 표에 `K-<번호>`를 대상 문서로 둔 행이 정확히 1개 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  n=$(awk '/^## 문서 동기화 점검/{f=1;next} /^## /{f=0} f' git-pr/SKILL.md | grep -E '^\|' | grep -cF 'K-<번호>')
  [ "$n" = 1 ] || echo "위반: 원장 행 ${n}개"
  ```

  - 범위: 섹션 헤더 다음 행부터 다음 `## ` 헤더 직전까지의 표 행만 센다. 본문 서술의 `K-<번호>`는 세지 않는다.
  </details>
- [ ] [D]  같은 섹션 본문(표 밖)이 `원장 대조`와 생략 조건의 대상 `.ai/70_ledger/index.md`를 함께 언급한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  s=$(awk '/^## 문서 동기화 점검/{f=1;next} /^## /{f=0} f' git-pr/SKILL.md | grep -vE '^\|')
  printf '%s\n' "$s" | grep -qF '원장 대조' || echo '위반: 원장 대조 서술 없음'
  printf '%s\n' "$s" | grep -qF '.ai/70_ledger/index.md' || echo '위반: 생략 조건 서술 없음'
  ```

  </details>
- [ ] [QD] 원장 대조가 권고만 하고 같은 PR 반영은 승인분만 하며, 원장 상태를 자동으로 바꾸지 않고, PR 생성 전이라 PR 번호를 모르는 시점의 종결 기재 방식이 모순 없이 안내된다  (검증: Task N 교차모델 audit 채점)  ← 강등 사유: 권고·승인·시점 규칙의 정합은 문장 의미 대조라 리터럴로 판정할 수 없다

### R2: git-pr 참조 문서

- [ ] [D]  `## 참조 문서`에 `.ai/70_ledger/index.md`를 index 먼저 읽는 방식으로 안내하는 행이 정확히 1개 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  n=$(awk '/^## 참조 문서/{f=1;next} /^## /{f=0} f' git-pr/SKILL.md \
    | grep -E '^ *- ' | grep -F '.ai/70_ledger/index.md' | grep -cF 'index 먼저')
  [ "$n" = 1 ] || echo "위반: 원장 참조 행 ${n}개"
  ```

  </details>

### R3: issue-work 함께 해소 후보

- [ ] [D]  `## 새 이슈 시작 시`의 3-1 영역이 `.ai/70_ledger/index.md`와 `함께 해소 후보`를 언급한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  s=$(awk '/^   - \*\*3-1\./{f=1} /^   - \*\*3-2\./{f=0} f' issue-work/SKILL.md)
  [ -n "$s" ] || echo '위반: 3-1 영역 없음'
  printf '%s\n' "$s" | grep -qF '.ai/70_ledger/index.md' || echo '위반: 원장 index 언급 없음'
  printf '%s\n' "$s" | grep -qF '함께 해소 후보' || echo '위반: 함께 해소 후보 언급 없음'
  ```

  - 범위: `- **3-1.` 행부터 `- **3-2.` 행 직전까지. 영역 앵커가 깨지면 빈 입력이 되므로 첫 줄에서 위반으로 돌린다.
  </details>
- [ ] [QD] 후보를 이슈 본문 근거 없는 항목처럼 따로 표시해 포함 여부를 묻고, 포함하면 R로 넣고 포함하지 않은 후보는 기록하지 않는다는 규칙이 3-1 영역에 있다  (검증: Task N 교차모델 audit 채점)  ← 강등 사유: 표시·질의·미기록 규칙의 의미 대조라 리터럴로 판정할 수 없다

### R4: 해소 기재 시점

- [ ] [D]  issue-work SKILL.md의 `### \`--response\`` 섹션 밖에 `해소(PR #N)` 기재 안내가 1개 이상 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  n=$(awk '/^### `--response`/{f=1;next} /^##/{f=0} !f' issue-work/SKILL.md | grep -cF '해소(PR #N)')
  [ "$n" -ge 1 ] || echo '위반: --response 밖 해소 기재 안내 없음'
  ```

  - 설계 주의: 변경 전에는 `해소(PR #N)`이 `--response` 섹션 안에만 있어 이 명령이 위반을 낸다(가짜 `[D]` 아님).
  </details>
- [ ] [QD] 정한 기재 시점이 PR 번호를 알 수 있는 시점이고 머지 전 같은 PR에 포함된다. PR 생성 전에 정리하는 경로와 `--response` 원장 종결에서도 번호 확보 전에 해소를 확정하지 않으며, issue-work SKILL.md·`issue-work/templates/issue-workflow-template.md`·`active/issue-workflow.md`·도메인 명세 절차 순서가 같은 경로를 안내한다  (검증: Task N 교차모델 audit 채점)  ← 강등 사유: 시점의 타당성과 문서 간 절차 정합은 절차 순서의 의미 판단이다

### R5: spec 템플릿 기재 위치

- [ ] [QD] spec 템플릿에 함께 해소할 원장 항목 기재 위치를 둘지의 판단과 근거가 summary 해당 Task `특이 사항`에 남고, 두기로 했으면 템플릿에 반영된다  (검증: Task N 교차모델 audit 채점)  ← 강등 사유: "두지 않음"도 정답이라 파일 변경 유무로 합·불을 가를 수 없다

### R6: 원장 수명 주기

- [ ] [D]  수명 주기 표의 재검토 행이 `문서 동기화 점검`을, 종결(해소) 행이 `문서 동기화 점검`과 `함께 해소`를 언급한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in ai-workspace/templates/shared/.ai/70_ledger/index.md .ai/70_ledger/index.md; do
    awk '/^## 수명 주기/{f=1} f' "$f" | grep -E '^\| 재검토 ' | grep -qF '문서 동기화 점검' || echo "위반: $f 재검토 행"
    r=$(awk '/^## 수명 주기/{f=1} f' "$f" | grep -E '^\| 종결\(해소\) ')
    printf '%s\n' "$r" | grep -qF '문서 동기화 점검' || echo "위반: $f 해소 행(git-pr)"
    printf '%s\n' "$r" | grep -qF '함께 해소' || echo "위반: $f 해소 행(issue-work)"
  done
  ```

  </details>
- [ ] [D]  템플릿과 이 repo 사본의 `## 수명 주기` 이하 내용이 같다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  diff <(awk '/^## 수명 주기/{f=1} f' ai-workspace/templates/shared/.ai/70_ledger/index.md) \
       <(awk '/^## 수명 주기/{f=1} f' .ai/70_ledger/index.md)
  ```

  - 설계 주의: 두 파일은 항목 목록 표가 다른 것이 정상이라 `## 수명 주기` 이하만 비교한다. 앵커가 둘 다 깨지면 빈 입력끼리 같아지지만, 위 항목이 같은 앵커로 행 실재를 먼저 확인한다.
  </details>

### R7: ADR 기록

- [ ] [D]  `.ai/50_adr/active/`의 ADR 1개 이상이 이슈 #110 링크를 출처로 갖는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -rlF 'scroogy-agent-skills/issues/110' .ai/50_adr/active/ | grep -q . || echo '위반: #110 출처 ADR 없음'
  ```

  </details>
- [ ] [D]  `.ai/50_adr/active/`의 모든 ADR 파일이 `.ai/50_adr/index.md`에 기재되어 있다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in .ai/50_adr/active/*.md; do grep -qF "active/$(basename "$f")" .ai/50_adr/index.md || echo "위반: $f 미기재"; done
  ```

  </details>
- [ ] [QD] 갱신과 새 ADR 중 고른 쪽의 근거가 ADR 또는 summary에 남고, ADR 0007의 소비자 서술이 바뀐 사실과 모순되지 않는다  (검증: Task N 교차모델 audit 채점)  ← 강등 사유: 결정 범위 판단의 타당성은 의미 대조다

### R8: 안내도 반영

- [ ] [D]  git-pr 안내도 2종은 `원장 대조`를, issue-work 안내도 2종은 `함께 해소`를 언급한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in .ai/40_domain/specs/git-pr-submission.md .ai/60_codebase/git-pr/submit-call-flow.md; do
    grep -qF '원장 대조' "$f" || echo "위반: $f"
  done
  for f in .ai/40_domain/specs/issue-workflow.md .ai/60_codebase/issue-work/start-call-flow.md; do
    grep -qF '함께 해소' "$f" || echo "위반: $f"
  done
  ```

  </details>

### R9: K-0006 재검토

- [ ] [D]  K-0006 파일의 `## 재검토 이력`이 "없음"이 아니고 #110을 언급한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  f=$(ls .ai/70_ledger/active/K-0006-*.md .ai/70_ledger/archive/K-0006-*.md 2>/dev/null)
  [ "$(printf '%s\n' "$f" | grep -c .)" = 1 ] || echo '위반: K-0006 파일 0개 또는 중복'
  s=$(awk '/^## 재검토 이력/{f=1;next} /^(## |<details>)/{f=0} f' $f)
  printf '%s\n' "$s" | grep -qxE '없음' && echo '위반: 재검토 이력 없음'
  printf '%s\n' "$s" | grep -qF '#110' || echo '위반: #110 언급 없음'
  ```

  </details>
- [ ] [D]  `.ai/70_ledger/index.md`의 K-0006 행 링크가 실제 파일 위치를 가리키고, 위치와 상태가 맞다(`active/`면 `수용`, `archive/`면 `승격(이슈 #`) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  row=$(grep -E '^\| \[K-0006\]' .ai/70_ledger/index.md)
  p=$(printf '%s\n' "$row" | sed -nE 's/^\| \[K-0006\]\(([^)]+)\).*/\1/p')
  [ -n "$p" ] && [ -f ".ai/70_ledger/$p" ] || echo '위반: 링크 대상 없음'
  case "$p" in
    active/*)  printf '%s\n' "$row" | grep -qF '| 수용 |' || echo '위반: active인데 상태 불일치' ;;
    archive/*) printf '%s\n' "$row" | grep -qF '| 승격(이슈 #' || echo '위반: archive인데 상태 불일치' ;;
  esac
  ```

  </details>
- [ ] [ND] 계속 수용·승격 판단과 갱신한 재검토 조건이 타당하다  (검증: 사람 리뷰)  ← 강등 사유: 부채를 지금 갚을지는 사용자 판단이다

### 공통

- [ ] [D]  repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D]  제외 범위 스킬(issue-audit·git-pr-feedback·code-map)에 변경이 없다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  git diff --name-only main -- issue-audit git-pr-feedback code-map
  ```

  - 범위: `main` 기준 작업 트리 전체(커밋 전 변경 포함)를 본다.
  </details>

---

## 전제 (Assumptions)

- **고정 용어**: git-pr 표의 새 행과 그 서술은 `원장 대조`, issue-work 3-1의 후보는 `함께 해소 후보`로 부른다. 완료의 정의 R1·R3·R6·R8 명령이 이 리터럴을 앵커로 쓰므로 다른 표현으로 바꾸면 명령도 함께 고친다. (2026-10-10 계획 작성 시 결정)
- **PR 번호 제약**: git-pr 문서 동기화 점검은 PR 생성(4단계) 전에 수행되어 PR 번호를 모른다. 그래서 git-pr에서 같은 PR에 반영할 수 있는 것은 재검토 이력 기록이 기본이고, `해소(PR #N)` 기재 시점(R1 종결 권고·R4)은 PR 번호를 아는 시점으로 정해야 한다. 후보는 issue-work `## 이슈 완료 시`·`--clear`다. 구체 방식은 Task 0에서 사용자에게 확인한다.
  - **정리 순서는 두 경로가 있다**: 도메인 명세 `.ai/40_domain/specs/issue-workflow.md`의 절차 순서는 `--clear → PR`이고, `git-pr/SKILL.md`도 `--clear`를 git-pr보다 먼저 실행한 회차를 다룬다. 따라서 `--clear`·`## 이슈 완료 시` 시점에 PR이 이미 있다고 가정할 수 없다.
    - PR이 있는 상태에서 정리하는 경우: 정리 단계에서 `해소(PR #N)` 기재 → `archive/` 이관 → index 갱신을 수행하고 머지 전 같은 PR에 포함한다.
    - PR 생성 전에 정리하는 경우: 정리 단계에서는 해소 상태를 확정하지 않는다. PR 번호를 확보한 뒤의 후속 기재 주체·시점을 Task 0에서 정한 경로로 안내한다.
  - 어느 경로든 PR 번호를 확보하기 전에 `해소` 상태를 확정하지 않는다. (2026-10-10 계획 감사 F-1 반영)
  - **Task 0 결정 (2026-10-10 사용자 확정)**: PR 생성 전에 정리한 경로의 후속 기재 주체는 git-pr, 시점은 4단계에서 PR 번호·URL을 보고한 뒤다. 원장 대조에서 종결을 승인받은 항목에 `해소(PR #<생성된 번호>)` 기재 → `archive/` 이관 → index 갱신을 하고, 커밋·push는 별도 승인을 받아 같은 PR에 반영한다. 3-1에서 포함한 함께 해소 항목은 diff가 원인 파일을 바꾸므로 원장 대조에서 같은 경로로 걸린다. 따라서 `--clear`·`## 이슈 완료 시`는 PR이 있으면 직접 기재하고, 없으면 확정하지 않고 git-pr 생성 후 단계로 넘긴다고 안내한다. 도메인 명세의 절차 순서 `--clear → PR`은 바꾸지 않는다. 최근 #106·#108은 `--clear` 커밋 뒤에 PR을 만들었다.
  - **`--response` 원장 종결도 같은 규칙**: `--response`의 "이번에 반영(보정)" 갈래와 "보정으로 원인이 사라진 기등재 종결"도 Task N 직후 PR 생성 전에 실행되어 번호를 모른다. PR이 있으면 그 자리에서 기재하고, 없으면 확정하지 않고 위 git-pr 생성 후 단계로 넘긴다. 승격(이슈 #N)은 이슈 번호를 그 자리에서 얻으므로 대상이 아니다. (2026-10-10 Task 0에서 사용자 확정, R4 확장)
- **원장 index 사본**: `ai-workspace/templates/shared/.ai/70_ledger/index.md`와 `.ai/70_ledger/index.md`는 항목 목록 표만 다르고 `## 수명 주기` 이하는 같아야 한다. ai-workspace update는 기존 index를 덮어쓰지 않으므로 두 파일을 직접 함께 고친다.
- **60_codebase frontmatter**: 색인을 고치면 `last_synced`만 작업일로 갱신하고 `source_hash`·`status`는 둔다(#108 선례).
- **설치본**: `~/.claude/skills/` 등 설치된 스킬은 이 이슈에서 갱신하지 않는다. 반영은 머지 후 install-skills로 한다.
- **함께 해소 후보 자기 적용**: 이 이슈의 3-1에서 원장을 대조했다. 관련 항목은 범위에 든 K-0006뿐이며, K-0003(git-pr 3·4단계 승인 게이트)·K-0004(`--clear` 5단계 보존 목적지)는 이번 변경이 재검토 조건의 대상 문장을 바꾸지 않아 후보에서 뺐다. 구현이 그 문장을 바꾸게 되면 해당 항목을 재검토한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/70_ledger/index.md` | 수명 주기 표·상태별 처리 표 (R6 수정 대상, R1·R3의 대조 입력) |
| `.ai/70_ledger/active/K-0006-code-map-check-not-deterministic.md` | R9 재검토 대상 |
| `.ai/50_adr/active/0007-tech-debt-ledger-location-and-structure.md` | 원장 소비자 3종·종결 독립 결정 (R7) |
| `.ai/50_adr/active/0011-git-pr-submission-and-approval-gate.md` | 문서 동기화 점검 flag-only 결정 (R1 정합) |
| `.ai/50_adr/active/0016-spec-requirements-layer-and-plan-audit.md` | 요구사항 승인 게이트·근거 없는 항목 표시 (R3 정합) |
| `.ai/40_domain/specs/git-pr-submission.md` | git-pr 문서 동기화 점검 표 (R8) |
| `.ai/40_domain/specs/issue-workflow.md` | issue-work 절차 순서 (R8) |
| `.ai/40_domain/policies/local/external-action-approval-gate.md` | 승인 게이트 원칙 (R1 승인형 정합) |
