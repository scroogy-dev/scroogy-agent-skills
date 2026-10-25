# Issue #120 스펙 원장 항목을 archive로 옮길 때 그 항목을 가리키는 다른 문서의 링크 갱신

## 목표 (Goal)

원장 항목을 `archive/`로 옮기는 세 스킬(issue-work·git-pr·git-pr-feedback)이 그 항목을 가리키는 다른 `.ai/` 문서의 링크도 고치고 옛 경로 0건을 확인해, 종결 뒤에도 색인·ADR에서 항목을 찾아갈 수 있게 한다.

---

## 요구사항 (Requirements)

**포함**

- R1: 원장 항목을 `active/`에서 `archive/`로 옮긴 뒤 수행할 링크 갱신 규칙이 정해진다. 규칙은 두 단계다. 첫째, `.ai/` 아래 문서에서 `70_ledger/active/K-<번호>-` 경로를 가리키는 링크를 `archive/` 경로로 고치며 상대 경로 깊이는 링크가 있는 문서 위치에서 다시 계산한다. 둘째, 옛 경로가 남은 곳이 0건인지 확인한다. 갱신 범위에서 `.ai/90_issues/archive/`는 뺀다. 규칙 문장은 #121(ADR 처리 규칙)이 대상 경로만 바꿔 복제할 수 있는 형태로 쓴다.
- R2: issue-work에서 원장 항목을 옮기는 지점이 R1을 수행한다. 대상은 "이슈 완료 시" 3단계 원장 해소 기재와 `--response` 5단계의 이슈 승격·이번에 반영(해소)·보정으로 원인이 사라진 기등재 종결이다.
- R3: git-pr에서 원장 항목을 옮기는 지점이 R1을 수행한다. 대상은 "문서 동기화 점검" 원장 대조의 승격 이관과 "PR 제출" 4단계 원장 해소 기재다. 승격 이관에 빠진 `.ai/70_ledger/index.md` 항목 목록 갱신도 함께 적는다.
- R4: git-pr-feedback "기존 원장 항목의 종결"이 R1을 수행한다.
- R5: R2~R4의 규칙 문장은 세 스킬에 같은 문장으로 복제한다(ADR 0002).
- R6: 0건 확인을 결정적 헬퍼로 뺄지 `architecture.md` `## 디자인 원칙`의 판단 체크리스트로 판정하고 그 결과를 따른다. 헬퍼 안(스킬마다 사본)과 본문에 grep 명령 한 줄을 적는 안을 비교한 근거를 남긴다.
- R7: 세 스킬의 `tests/`에서 바뀐 문구에 걸리는 검사가 있는지 확인하고, 걸리면 맞춘다.
- R8: 원장 index의 수명 주기 설명에 링크 갱신 한 줄이 더해진다. 대상은 `ai-workspace/templates/shared/.ai/70_ledger/index.md`와 이 repo 사본 `.ai/70_ledger/index.md`다.
- R9: 결정 기록을 ADR 0018 갱신과 새 ADR 중 하나로 정해 반영하고 `.ai/50_adr/index.md`를 맞춘다.
- R10: `.ai/40_domain/specs/`(issue-workflow, git-pr-submission, git-pr-feedback)와 `.ai/60_codebase/`(issue-work clear·response, git-pr submit, git-pr-feedback respond 호출 흐름)가 바뀐 단계를 반영한다.
- R11: R1의 링크 갱신 대상에 원장 항목 파일끼리의 같은 디렉토리 링크를 넣는다. `active/`에 남은 항목이 옮긴 항목을 가리키는 링크(예: K-0014의 `K-0015-…md`)와 옮긴 항목이 `active/`에 남은 항목을 가리키는 링크가 모두 끊기는데, `70_ledger/active/K-<번호>-` 경로 패턴은 이 링크를 잡지 못한다. (이슈 본문 근거 없음. 2026-10-25 spec 작성 중 `.ai/70_ledger/active/K-0014-publishing-skill-deferred.md:25`를 확인해 추가, 같은 날 승인으로 확정)
- R12: issue-work 워크플로우 템플릿(`issue-work/templates/issue-workflow-template.md`)과 이 repo 사본(`.ai/90_issues/active/issue-workflow.md`)의 `## 이슈 완료 시` 3단계 원장 해소 기재에 들어오는 링크 갱신 한 줄이 더해진다. (이슈 본문 근거 없음. 2026-10-25 Task 0에서 #110·#118이 SKILL.md의 같은 절을 바꿀 때 두 파일도 고친 선례를 확인해 추가, 같은 날 승인으로 확정)

**제외**

- ADR을 `superseded/`로 옮길 때의 링크 갱신: 대체. #121이 이 이슈의 규칙 문장(R1)을 복제해 다룬다.
- `.ai/90_issues/archive/` 이슈 문서의 옛 경로 정비(`issue-0104` 감사 리포트의 K-0011 링크 1건 포함): 불필요. 이슈 문서는 작성 시점 기록이고, 옛 경로가 남아도 index에서 번호로 찾을 수 있다.
- ai-workspace update-3 "기존 파일 정리"의 원장 이동: 불필요. 디렉토리 루트에 남은 옛 배치 파일만 옮기는 단계라 들어오는 링크가 거의 없다.
- 원장 수명 주기(상태 값, 종결 계기, 종결 주체) 변경: 불필요. 이 이슈는 옮기는 단계에 링크 갱신만 더한다.
- 다른 문서에서 원장 항목을 경로 링크 없이 `K-<번호>`로만 가리키는 규약 전환: 대체. `60_codebase/` "관련 문서" 열의 링크 규약을 바꿔야 하고 읽는 쪽이 index를 한 번 더 거친다. R1의 링크 갱신으로 갈음한다.
- code-map이 원장 링크를 맞추는 안: 대체. code-map은 `70_ledger`를 다루지 않고, 맡겨도 `60_codebase/` 밖의 링크(ADR 0020)가 남는다. R1로 갈음한다.

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> 검증 명령은 repo 루트에서 bash로 실행한다 (전제 참조).

### R1: 링크 갱신 규칙

- [ ] [D]  세 스킬 SKILL.md에 `**들어오는 링크 갱신**:` 정의 행이 정확히 1개씩 있고, 그 행에 갱신 범위·제외 범위·깊이 재계산·0건 확인·헬퍼 이름이 모두 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for s in issue-work git-pr git-pr-feedback; do
    f="$s/SKILL.md"
    re='^ *([0-9]+\.|-) \*\*들어오는 링크 갱신\*\*: '
    n=$(grep -cE "$re" "$f")
    [ "$n" = 1 ] || { echo "위반: $f 정의 행 ${n}개 (기대 1개)"; continue; }
    line=$(grep -E "$re" "$f")
    for a in '`.ai/` 아래 문서' '`.ai/90_issues/archive/` 제외' '`70_ledger/active/K-<번호>-`' \
             '링크가 있는 문서 위치에서 다시 계산' '`check-ledger-links.sh`' '0건'; do
      case "$line" in *"$a"*) ;; *) echo "위반: $f 정의 행에 [$a] 없음" ;; esac
    done
  done
  ```

  - 설계 주의: 정의는 행 하나에 모으고 다른 위치는 이 라벨 형식을 쓰지 않고 참조한다. 그래야 "정확히 1개"가 정의 중복과 누락을 함께 거른다. git-pr는 번호 단계 안에 두므로 정규식이 `1.` 형식도 받는다.
  </details>
- [ ] [QD] 정의 문장은 원장 고유 표현(원장 항목, `70_ledger/active/K-<번호>-`, 원장 항목 파일끼리, 헬퍼 이름)만 바꾸면 ADR 이동(#121)에 그대로 쓸 수 있다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 복제 가능성은 문장 구조의 의미 판단이라 명령으로 거르지 못한다

### R2: issue-work 적용 지점

- [ ] [D]  `## 이슈 완료 시` 절에서 정의 행이 `**원장 해소 기재**` 행 뒤, `**보류 항목 원장 등재 질의**` 행 앞에 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^## 이슈 완료 시$/ { s = 1; next } /^## / { s = 0 }
       s && /\*\*원장 해소 기재\*\*/ && !a { a = NR }
       s && /^ *- \*\*들어오는 링크 갱신\*\*: / { b = NR }
       s && /\*\*보류 항목 원장 등재 질의\*\*/ { c = NR }
       END { if (!(a && b && c && a < b && b < c)) print "위반: 위치 (원장 해소 기재 " a+0 ", 정의 " b+0 ", 보류 " c+0 ")" }' issue-work/SKILL.md
  ```

  </details>
- [ ] [D]  `--response` 5단계 범위에 `들어오는 링크 갱신`을 가리키는 행이 1개 이상 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  n=$(sed -n '/^### `--response`/,/^### `--clear`/p' issue-work/SKILL.md \
    | awk '/^  5\. /{f=1} f && /^[^[:space:]]/ && !/^  5\. /{f=0} f' \
    | grep -c '들어오는 링크 갱신')
  [ "$n" -ge 1 ] || echo '위반: --response 5단계에 들어오는 링크 갱신 참조 없음'
  ```

  - 설계 주의: 5단계 범위는 기존 러너의 4~5단계 범위 추출(`issue-work/tests/run-tests.sh` `check_response`)과 같은 방식으로 첫 비공백 시작 행에서 끊는다. 절 끝까지 잡으면 뒤의 "등급별 기본 제시값" 블록까지 범위에 들어온다.
  </details>
- [ ] [QD] `--response` 참조가 이슈 승격·이번에 반영(해소)·보정으로 원인이 사라진 기등재 종결 세 갈래를 모두 덮고, 해소를 확정하지 않아 `active/`에 둔 항목은 대상이 아님을 밝힌다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 참조가 어느 갈래를 덮는지는 문장 의미 판단이다

### R3: git-pr 적용 지점

- [ ] [D]  "PR 제출" 4단계 원장 해소 기재의 번호 단계에서 정의 행이 index 갱신 단계 뒤, 커밋·push 단계 앞에 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/\*\*원장 해소 기재는 보고 다음입니다\.\*\*/ { s = 1; next } s && /^- / { s = 0 }
       s && /^  [0-9]+\. .*`\.ai\/70_ledger\/index\.md`/ { a = NR }
       s && /^  [0-9]+\. \*\*들어오는 링크 갱신\*\*: / { b = NR }
       s && /^  [0-9]+\. 커밋과 push/ { c = NR }
       END { if (!(a && b && c && a < b && b < c)) print "위반: 위치 (index " a+0 ", 정의 " b+0 ", 커밋 " c+0 ")" }' git-pr/SKILL.md
  ```

  </details>
- [ ] [D]  "문서 동기화 점검"의 원장 대조 반영 문단이 승격 이관에 `.ai/70_ledger/index.md` 항목 목록 갱신과 `들어오는 링크 갱신`을 함께 적는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  f=git-pr/SKILL.md
  [ "$(grep -cE '^원장 대조 권고도 같은 방식으로' "$f")" = 1 ] || echo '위반: 원장 대조 반영 문단이 1개가 아님'
  line=$(grep -E '^원장 대조 권고도 같은 방식으로' "$f")
  case "$line" in *'`.ai/70_ledger/index.md`'*) ;; *) echo '위반: 승격 이관의 index 갱신 없음' ;; esac
  case "$line" in *'들어오는 링크 갱신'*) ;; *) echo '위반: 승격 이관의 들어오는 링크 갱신 참조 없음' ;; esac
  ```

  </details>

### R4: git-pr-feedback 적용 지점

- [ ] [D]  `### 기존 원장 항목의 종결` 절 안에 정의 행이 정확히 1개 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^### 기존 원장 항목의 종결$/ { s = 1; next } /^##+ / { s = 0 }
       s && /^ *- \*\*들어오는 링크 갱신\*\*: / { n++ }
       END { if (n != 1) print "위반: 종결 절의 정의 행 " n+0 "개 (기대 1개)" }' git-pr-feedback/SKILL.md
  ```

  - 설계 주의: 절 끝은 `^##+ `(2단계 이상 제목)으로 잡는다. `^#`로 잡으면 절 안 코드 블록의 `# 주석` 행에서 범위가 끊긴다.
  </details>

### R5: 같은 문장 복제

- [ ] [QD] 세 정의 행은 종결 어미(issue-work 한다체, git-pr·git-pr-feedback 합니다체)를 빼면 같은 문장이다  (검증: 다른 AI가 세 행을 대조해 채점, 별도 세션)  ← 강등 사유: 어미 차이를 걷어낸 문장 동일성은 형태소 판단이라 명령으로 정규화하기 어렵다. 핵심 조각의 존재는 R1·R11 `[D]`가 덮는다

### R6: 0건 확인 헬퍼

- [ ] [D]  `check-ledger-links.sh` 사본 3개(`issue-work`·`git-pr`·`git-pr-feedback`의 `scripts/`)가 있고, 실행 권한이 있으며, 바이트 단위로 같다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for s in issue-work git-pr git-pr-feedback; do
    f="$s/scripts/check-ledger-links.sh"
    [ -x "$f" ] || { echo "위반: $f 없음 또는 실행 권한 없음"; continue; }
    m=$(git ls-files -s "$f" | cut -d' ' -f1)
    [ -z "$m" ] || [ "$m" = 100755 ] || echo "위반: $f git index 모드 $m (기대 100755)"
  done
  for s in git-pr git-pr-feedback; do
    cmp -s issue-work/scripts/check-ledger-links.sh "$s/scripts/check-ledger-links.sh" || echo "위반: $s 사본이 issue-work 사본과 다름"
  done
  ```

  </details>
- [ ] [D]  세 사본 모두 외부 경계(인자·종료 코드·출력 행)가 전제의 인터페이스대로 동작한다. 갱신을 마친 트리는 종료 코드 0·무출력, 옛 경로나 잘못 계산한 깊이가 남은 트리는 종료 코드 1과 그 파일·줄, 없는 디렉토리는 종료 코드 2이며, `90_issues/archive/` 아래 링크는 검사하지 않는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  # mk: 옮긴 뒤 링크를 다 고친 fixture 를 새 임시 디렉토리에 만든다 (T·A 설정)
  mk() {
    T=$(mktemp -d); A="$T/.ai"
    mkdir -p "$A/70_ledger/active" "$A/70_ledger/archive" "$A/60_codebase/x" "$A/90_issues/archive/issue-0001"
    echo '# K-0001' > "$A/70_ledger/archive/K-0001-a.md"
    printf '[K-0001](%s)\n' '../../70_ledger/archive/K-0001-a.md' > "$A/60_codebase/x/flow.md"
    printf '[K-0001](%s)\n' 'archive/K-0001-a.md#상태' > "$A/70_ledger/index.md"
    printf '[K-0001](%s)\n' '../../../70_ledger/active/K-0001-a.md' > "$A/90_issues/archive/issue-0001/r.md"
  }
  for s in issue-work git-pr git-pr-feedback; do
    H="$PWD/$s/scripts/check-ledger-links.sh"
    # 1) 갱신을 마친 트리 (앵커 링크·90_issues/archive 옛 경로 포함), 인자 생략 → 0, 무출력
    mk; out=$(cd "$T" && "$H"); rc=$?
    { [ "$rc" = 0 ] && [ -z "$out" ]; } || echo "위반: $s 정상 트리 rc=$rc out=[$out]"
    # 2) 옛 경로가 남음 → 1, 그 파일:줄
    mk; printf '[K-0001](%s)\n' '../../70_ledger/active/K-0001-a.md' > "$A/60_codebase/x/old.md"
    out=$(cd "$T" && "$H" .ai); rc=$?
    { [ "$rc" = 1 ] && printf '%s\n' "$out" | grep -qF '.ai/60_codebase/x/old.md:1:'; } || echo "위반: $s 옛 경로 rc=$rc out=[$out]"
    # 3) 깊이를 잘못 계산함 → 1, 그 파일:줄
    mk; printf '[K-0001](%s)\n' '../70_ledger/archive/K-0001-a.md' > "$A/60_codebase/x/depth.md"
    out=$(cd "$T" && "$H" .ai); rc=$?
    { [ "$rc" = 1 ] && printf '%s\n' "$out" | grep -qF '.ai/60_codebase/x/depth.md:1:'; } || echo "위반: $s 깊이 오계산 rc=$rc out=[$out]"
    # 4) 없는 디렉토리 → 2
    mk; (cd "$T" && "$H" no-such-dir >/dev/null 2>&1); rc=$?
    [ "$rc" = 2 ] || echo "위반: $s 사용오류 rc=$rc"
  done
  ```

  - 설계 주의: fixture의 링크는 `printf '[K-…](%s)'`로 대상과 분리해 쓴다. 이 spec도 `.ai/` 아래에 있어 링크 문법을 그대로 적으면 공통 `[D]`의 저장소 검사가 이 문서를 끊긴 링크로 잡는다.
  - 설계 주의: 케이스마다 새 임시 디렉토리를 만들고 지우지 않는다. 변수 경로의 `rm -rf`는 AI 도구의 안전 검사에 막힐 수 있다. 임시 디렉토리는 OS 임시 영역이다.
  - 설계 주의: 헬퍼가 없으면 `rc`가 127이라 모든 케이스가 위반으로 나온다 (2026-10-25 시제품으로 확인).
  </details>
- [ ] [D]  `.ai/AI-CONTEXT.md` 디렉토리 구조의 세 스킬 `scripts/` 주석에 `check-ledger-links.sh`가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^├── [a-z-]+\/ / { d = $2 }
       /^│.*scripts\/ / && /check-ledger-links\.sh/ { h[d] = 1 }
       END { split("git-pr/ git-pr-feedback/ issue-work/", k, " ")
             for (i = 1; i <= 3; i++) if (!h[k[i]]) print "위반: " k[i] " scripts/ 주석에 check-ledger-links.sh 없음" }' .ai/AI-CONTEXT.md
  ```

  </details>
- [ ] [QD] 헬퍼 분리 판정(판단 체크리스트 4문항)과 본문에 grep 한 줄을 적는 안의 비교가 ADR 0021에 남는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 판정 근거의 충실도는 서술 의미 판단이다. 파일·핵심 낱말 존재는 R9 `[D]`가 덮는다

### R7: 기존 테스트 영향

- [ ] [QD] summary Task 3~5 `특이 사항`에 그 스킬 러너에서 바뀐 문구에 걸린 기존 검사(검사 이름 또는 "없음")가 적혀 있다  (검증: 다른 AI가 러너의 SKILL.md 대상 검사와 대조해 채점)  ← 강등 사유: 문구 변경이 어느 검사에 걸리는지는 검사 의도와의 의미 대조다. 러너 통과는 `### 공통`이 검사한다

### R8: 원장 index 수명 주기

- [ ] [D]  shared 템플릿과 이 repo 사본의 `## 수명 주기` 절에 들어오는 링크 갱신을 적은 행이 정확히 1개씩 있고, 그 행에 `.ai/90_issues/archive/` 제외가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in ai-workspace/templates/shared/.ai/70_ledger/index.md .ai/70_ledger/index.md; do
    awk -v f="$f" '/^## 수명 주기$/ { s = 1; next } /^## / { s = 0 }
         s && /들어오는 링크/ { n++; if (index($0, "`.ai/90_issues/archive/`")) m++ }
         END { if (n != 1 || m != 1) print "위반: " f " 링크 갱신 행 " n+0 "개, 제외 범위 명시 " m+0 "개 (기대 각 1개)" }' "$f"
  done
  ```

  </details>
- [ ] [D]  shared 템플릿과 이 repo 사본은 `## 항목 목록` 표의 항목 행 말고는 같다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  rows='^\| (\[K-[0-9]{4}\]|\(항목을 등재하면)'
  diff <(grep -vE "$rows" ai-workspace/templates/shared/.ai/70_ledger/index.md) \
       <(grep -vE "$rows" .ai/70_ledger/index.md) >/dev/null \
    || echo '위반: 템플릿과 사본이 항목 행 밖에서 다름'
  ```

  </details>

### R9: 결정 기록

- [ ] [D]  `.ai/50_adr/active/0021-*.md`가 정확히 1개 있고, 머리말 `source_url`이 이슈 #120이며, `## 결정` 절과 핵심 낱말(판단 체크리스트, 헬퍼 이름, #121)이 있고, `.ai/50_adr/index.md`에 그 파일 행이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  set -- .ai/50_adr/active/0021-*.md
  if [ "$#" != 1 ] || [ ! -f "$1" ]; then echo "위반: ADR 0021 파일이 1개가 아님 ($*)"; else
    f="$1"
    grep -qxF 'source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/120' "$f" || echo '위반: source_url'
    grep -qxF '## 결정' "$f" || echo '위반: 결정 절 없음'
    for a in '판단 체크리스트' 'check-ledger-links.sh' '#121'; do grep -qF "$a" "$f" || echo "위반: ADR에 [$a] 없음"; done
    grep -qF "\`active/${f##*/}\`" .ai/50_adr/index.md || echo '위반: 50_adr/index.md 행 없음'
  fi
  ```

  </details>
- [ ] [D]  ADR 0018은 바뀌지 않는다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  git diff --quiet main -- .ai/50_adr/active/0018-ledger-proactive-review-and-resolve-timing.md || echo '위반: ADR 0018 변경'
  ```

  </details>
- [ ] [QD] ADR 0021의 결정·근거·대안이 spec 전제의 결정(새 ADR 선택 이유, 헬퍼 판정, 끊긴 링크 검사 방식, 갱신·제외 범위)과 맞는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 결정 서술의 정합은 의미 대조다

### R10: 명세·색인 반영

- [ ] [D]  명세 3종에 들어오는 링크 갱신 서술이 있고, `issue-workflow.md`의 결정적 헬퍼 행에 `check-ledger-links.sh`가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in issue-workflow git-pr-submission git-pr-feedback; do
    grep -qF '들어오는 링크' ".ai/40_domain/specs/$f.md" || echo "위반: $f 명세에 들어오는 링크 서술 없음"
  done
  grep -E '^- 결정적 헬퍼:' .ai/40_domain/specs/issue-workflow.md | grep -qF 'check-ledger-links.sh' \
    || echo '위반: issue-workflow 결정적 헬퍼 행에 check-ledger-links.sh 없음'
  ```

  </details>
- [ ] [D]  호출 흐름 문서 4개에 `check-ledger-links.sh`가 있고 머리말 `source_hash`가 `main`과 달라진다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in issue-work/clear-call-flow issue-work/response-call-flow git-pr/submit-call-flow git-pr-feedback/respond-call-flow; do
    p=".ai/60_codebase/$f.md"
    grep -qF 'check-ledger-links.sh' "$p" || echo "위반: $p 헬퍼 언급 없음"
    new=$(grep -m1 '^source_hash:' "$p"); old=$(git show "main:$p" | grep -m1 '^source_hash:')
    [ -n "$new" ] && [ "$new" != "$old" ] || echo "위반: $p source_hash 미갱신 ($new)"
  done
  ```

  </details>
- [ ] [D]  `.ai/60_codebase/index.md`의 issue-work·git-pr·git-pr-feedback 행에 ADR 0021 링크가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for s in issue-work git-pr git-pr-feedback; do
    grep -E "^\| $s \|" .ai/60_codebase/index.md | grep -qE '\(\.\./50_adr/active/0021-[^)]*\.md\)' \
      || echo "위반: 색인 $s 행에 ADR 0021 링크 없음"
  done
  ```

  </details>
- [ ] [QD] 명세·호출 흐름의 서술이 SKILL.md의 바뀐 단계(적용 지점·순서·헬퍼 호출)와 맞는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 요약 서술과 원문 절차의 일치는 의미 대조다

### R11: 원장 항목 파일끼리의 링크

- [ ] [D]  세 정의 행에 같은 디렉토리 링크와 옮긴 항목에서 나가는 링크가 대상으로 적혀 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for s in issue-work git-pr git-pr-feedback; do
    line=$(grep -E '^ *([0-9]+\.|-) \*\*들어오는 링크 갱신\*\*: ' "$s/SKILL.md")
    for a in '같은 디렉토리 링크' '옮긴 항목 안에서'; do
      case "$line" in *"$a"*) ;; *) echo "위반: $s 정의 행에 [$a] 없음" ;; esac
    done
  done
  ```

  </details>
- [ ] [D]  세 사본 모두 같은 디렉토리 링크가 끊긴 트리(남은 항목 → 옮긴 항목, 옮긴 항목 → 남은 항목)에서 종료 코드 1과 두 파일·줄을 내고, 두 링크를 고친 트리에서 종료 코드 0·무출력이다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for s in issue-work git-pr git-pr-feedback; do
    H="$PWD/$s/scripts/check-ledger-links.sh"
    T=$(mktemp -d); A="$T/.ai"; mkdir -p "$A/70_ledger/active" "$A/70_ledger/archive"
    printf '[K-0002](%s)\n' 'K-0002-b.md' > "$A/70_ledger/archive/K-0001-a.md"
    printf '[K-0001](%s)\n' 'K-0001-a.md' > "$A/70_ledger/active/K-0002-b.md"
    out=$(cd "$T" && "$H" .ai); rc=$?
    { [ "$rc" = 1 ] \
      && printf '%s\n' "$out" | grep -qF '.ai/70_ledger/archive/K-0001-a.md:1:' \
      && printf '%s\n' "$out" | grep -qF '.ai/70_ledger/active/K-0002-b.md:1:'; } \
      || echo "위반: $s 같은 디렉토리 끊김 rc=$rc out=[$out]"
    printf '[K-0002](%s)\n' '../active/K-0002-b.md' > "$A/70_ledger/archive/K-0001-a.md"
    printf '[K-0001](%s)\n' '../archive/K-0001-a.md' > "$A/70_ledger/active/K-0002-b.md"
    out=$(cd "$T" && "$H" .ai); rc=$?
    { [ "$rc" = 0 ] && [ -z "$out" ]; } || echo "위반: $s 같은 디렉토리 갱신 후 rc=$rc out=[$out]"
  done
  ```

  - 설계 주의: 임시 디렉토리는 지우지 않는다 (R6 수용 명령과 같은 이유).

  </details>

### R12: 워크플로우 템플릿·사본

- [ ] [D]  템플릿 `## 이슈 완료 시` 절에서 `**원장 해소 기재**` 행 뒤, `**보류 항목 원장 등재 질의**` 행 앞에 들어오는 링크와 `check-ledger-links.sh`를 함께 적은 행이 정확히 1개 있고, 사본이 템플릿과 바이트 단위로 같다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  f=issue-work/templates/issue-workflow-template.md
  awk '/^## 이슈 완료 시$/ { s = 1; next } /^## / { s = 0 }
       s && /\*\*원장 해소 기재\*\*/ && !a { a = NR }
       s && /들어오는 링크/ && /check-ledger-links\.sh/ { n++; b = NR }
       s && /\*\*보류 항목 원장 등재 질의\*\*/ { c = NR }
       END { if (!(n == 1 && a && c && a < b && b < c)) print "위반: 템플릿 링크 갱신 행 " n+0 "개, 위치 (원장 해소 기재 " a+0 ", 행 " b+0 ", 보류 " c+0 ")" }' "$f"
  cmp -s "$f" .ai/90_issues/active/issue-workflow.md || echo '위반: 사본이 템플릿과 다름'
  ```

  - 설계 주의: 사본 동일성은 구현 전에도 통과하므로 행 검사와 한 항목으로 묶는다. 구현 전에는 행 검사가 위반을 낸다.
  </details>

### 공통

- [ ] [D]  repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D]  이 repo `.ai/`에 끊긴 원장 링크가 0건이다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(issue-work/scripts/check-ledger-links.sh .ai 2>&1); rc=$?
  { [ "$rc" = 0 ] && [ -z "$out" ]; } || echo "위반: rc=$rc [$out]"
  ```

  - 설계 주의: 헬퍼가 없으면 `rc`가 127이라 구현 전에는 실패한다.
  </details>
- [ ] [D]  제외 범위가 바뀌지 않는다. `.ai/90_issues/archive/`(이 이슈 디렉토리 제외)와 `ai-workspace/SKILL.md`(update-3)에 diff가 없다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  git diff --name-only main -- .ai/90_issues/archive/ ai-workspace/SKILL.md \
    | grep -v '^\.ai/90_issues/archive/issue-0120/' | sed 's/^/위반: 제외 범위 변경 /'
  ```

  </details>
- [ ] [D]  이 브랜치에서 바뀐 md 파일에 줄 끝 공백이 없다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  # 두 칸 이상은 마크다운 강제 개행이라 제외
  git diff --name-only --diff-filter=d main -- '*.md' | while read -r f; do
    grep -nE '[^ ] $' "$f" | sed "s|^|$f:|"
  done
  ```

  </details>

---

## 전제 (Assumptions)

- **헬퍼 인터페이스** (R6 `[D]`가 이 경계를 검사한다):
  - 호출: `check-ledger-links.sh [<.ai 디렉토리>]`. 인자를 생략하면 `.ai`다. 디렉토리가 없으면 종료 코드 2다.
  - 검사 범위: 그 디렉토리 아래 `*.md` 전체에서 `90_issues/archive/` 아래만 뺀다. 인자로 준 디렉토리가 심볼릭 링크면 그 대상 디렉토리를 검사하고, 하위 심볼릭 링크는 따라가지 않는다(최종 감사 F-2 반영).
  - 대상 링크: 마크다운 링크 `](<대상>)` 가운데 대상의 파일 이름이 `K-<4자리 숫자>-`로 시작하는 `.md`다. `#` 뒤 앵커는 떼고 보며, `://`가 들어간 외부 URL은 대상이 아니다.
  - 판정: 대상을 링크가 있는 파일의 디렉토리 기준으로 풀어 파일이 없으면 끊긴 링크다. 출력은 `<파일>:<줄>: <대상>`이고, 파일 경로는 인자로 준 디렉토리 경로로 시작한다.
  - 종료 코드: 0은 끊긴 링크 없음(무출력), 1은 끊긴 링크 있음(1행씩 출력), 2는 사용오류이거나 검사 대상 파일을 하나라도 읽지 못한 경우다. 읽은 파일만으로 0건을 확정하지 않는다(최종 감사 F-1 반영).
  - 코드 블록·코드 스팬 안의 링크 문법도 구분하지 않고 검사한다. 오탐은 `check-clear.sh --refs`처럼 AI가 건별로 판정한다.
- **0건 확인의 구현**: 옛 경로 grep 대신 끊긴 원장 링크 검사로 한다. 옮긴 뒤에는 옛 경로 파일이 없으므로 옛 경로 링크도 끊긴 링크로 잡히고, 같은 디렉토리 링크(R11)와 깊이를 잘못 계산한 링크도 함께 잡힌다.
  - 출력이 있으면 이번 이동으로 끊긴 링크는 고치고, 이동과 무관하게 이미 끊겨 있던 링크는 목록으로 알려 고칠지 묻는다. 지금 이 repo는 `90_issues/archive/` 밖에 끊긴 원장 링크가 0건이다 (2026-10-25 확인, 원장 링크 41개).
- **R6 판정 (계획 시점)**: `architecture.md` 판단 체크리스트로 `scripts/` 분리로 정했다.
  - 1번(같은 입력·같은 출력) 충족, 2번(반복 호출) 미충족(이동 1회에 한 번), 3번(기계 검증) 충족, 4번(명확한 오류) 충족이다. 1번과 2~4번 중 두 문항을 만족해 통과다.
  - 본문에 grep 한 줄을 적는 안은 버렸다. 옛 경로 grep은 같은 디렉토리 링크와 깊이 오계산을 잡지 못하고, 잡으려면 링크를 푸는 반복문이 필요해 한 줄을 넘는다.
  - 사본 3개는 ADR 0002의 의도적 중복으로 받아들인다. 선례는 `verify-push.sh`·`verify-submit.sh`의 URL 정규화와 두 `classify-risk.sh`다. 세 사본을 바이트 단위로 같게 두어 동기화 확인을 `cmp` 하나로 끝내고, 헤더 주석에 사본 위치와 "한쪽을 고치면 나머지도 고친다"를 적는다.
  - 헬퍼에 링크를 자동으로 고치는 모드는 넣지 않는다. 이슈는 갱신을 스킬 절차로 정했고, 검사만으로 갱신 누락과 깊이 오계산을 잡을 수 있다.
- **R9 판정**: ADR 0018을 고치지 않고 새 ADR 0021을 만든다.
  - ADR 0018은 종결 계기와 기재 시점(언제·누가)을 정한다. 이번 결정은 옮길 때 무엇을 고치고 어떻게 확인하는지와 헬퍼 판정이라 주제가 다르다.
  - #121이 같은 규칙을 ADR 이동에 복제하므로, 원장 계기를 다루는 ADR보다 독립 ADR이 인용하기 쉽다. 이관 파일의 경로 참조 갱신도 독립 ADR(0015)로 남긴 선례가 있다.
- **"같은 문장"의 뜻 (R5)**: 내용이 같고 종결 어미만 그 스킬 문체를 따른다. issue-work는 한다체, git-pr·git-pr-feedback은 합니다체다. 선언 읽기 표준 문장(8곳 복제)도 같은 방식이다.
- **스킬 안 배치**: 정의 행(`**들어오는 링크 갱신**:` 라벨)은 스킬마다 1개만 두고, 다른 적용 지점은 이 라벨 형식을 쓰지 않고 참조한다.
  - issue-work: `## 이슈 완료 시` 3단계 `**원장 해소 기재**`의 하위 항목으로 정의하고, `--response` 5단계는 참조한다. `--clear` 4단계는 원장 해소 기재를 그대로 부르므로 고치지 않는다.
  - git-pr: "PR 제출" 4단계 원장 해소 기재의 번호 단계로 정의한다(index 갱신 뒤, 커밋·push 앞). 문서 동기화 점검의 승격 이관 문단은 참조한다.
  - git-pr-feedback: `### 기존 원장 항목의 종결`에 정의한다.
- **테스트 배치**: 세 러너에 헬퍼 테스트(ADR 0001)와 정의 행·적용 지점·호출 블록 구조 검사를 더한다. 구조 검사는 #118 보류 항목 등재처럼 이슈 단위 명령만으로 지키면 이후 개정이 규칙 문장이나 적용 지점의 위치·참조, 헬퍼 호출을 깨도 알 수 없어서 둔다. 적용 지점 판정은 R2~R4의 위치·참조 `[D]`를 러너로 옮긴다. 테스트 라벨은 헬퍼 케이스 `원장 링크:`, 구조 검사 `링크 갱신 규칙:`이며 케이스 설명에는 `통과`·`격추` 중 하나만 쓴다.
  - 호출 블록 판정: 정의 행 다음 행부터 경계 행 앞까지를 범위로 본다. 경계 행은 issue-work `**보류 항목 원장 등재 질의**` 행, git-pr 커밋과 push 번호 단계 행, git-pr-feedback 종결 절 다음의 `##` 이상 제목이다. 파일 전체에서 경로 설정 행(`ledger_links='…'`, 앞 공백 허용)이 정확히 1개이고 그 행이 범위 안에 있어야 한다. 그 값의 `<skill 디렉토리>`를 러너 기준 `$HERE/..`로 바꾼 경로는 실행 가능한 파일이어야 한다. 경로 설정 행 뒤 범위 안에는 `"$ledger_links"`로 시작하는 호출 행이 1개 이상 있어야 한다.
  - 호출 블록을 검사하는 이유: ADR 0019는 Task의 변경을 되돌리면 실패하는 케이스를 요구하는데, 정의 행의 헬퍼 이름 조각으로는 경로 오타나 호출 행 누락을 잡지 못한다(계획 감사 F-1·F-2 반영). 이 repo의 다른 헬퍼(`check-clear.sh`·`verify-push.sh` 등) 호출 블록은 검사하지 않는 관례이며, 이 이슈에서 소급하지 않는다.
- **워크플로우 템플릿 (R12)**: Task 0에서 더한 범위라 3차 계획 감사를 거치지 않았다.
  - 템플릿 줄은 SKILL.md 정의 행의 요약이며 정의 라벨(`**들어오는 링크 갱신**:`)을 쓰지 않는다. R5의 같은 문장 복제 대상은 세 SKILL.md의 정의 행뿐이다.
  - 위치는 `**원장 해소 기재**`의 하위 항목 `PR이 아직 없으면` 뒤이며, SKILL.md 정의 행의 위치와 같다. 사본은 템플릿을 그대로 복사한다.
- **`60_codebase/` 갱신**: code-map을 실행하지 않고 직접 고친다. 고친 호출 흐름 문서의 머리말은 `last_synced`를 고친 날짜로, `source_hash`를 반영한 스킬 소스 변경 커밋 해시로 바꾼다 (#118 `ai-workspace/update-call-flow.md` 선례). `60_codebase/index.md` 머리말은 #118도 바꾸지 않았으므로 그대로 둔다.
  - `source_hash`는 커밋이 있어야 정해진다. 커밋은 사용자가 요청할 때만 하므로, 그 값은 스킬 소스 변경을 커밋한 뒤 채운다.
- **검증 환경**: 검증 명령은 repo 루트에서 bash로 실행한다. 사용자 셸이 zsh라 `${l#](}` 같은 패턴 전개와 `=====` 같은 낱말이 다르게 해석된다.
- **이 이슈 문서의 링크 문법**: spec·plan은 `.ai/` 아래에 있어 헬퍼 검사 범위에 든다. 없는 원장 파일을 가리키는 링크 문법을 그대로 쓰지 않는다(fixture는 `printf '[K-…](%s)'`로 대상을 떼어 쓴다).

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/70_ledger/index.md` | 수명 주기 설명(R8 대상), 항목 목록 |
| `.ai/50_adr/active/0018-ledger-proactive-review-and-resolve-timing.md` | 종결 시점·주체 결정. R9의 갱신 후보 |
| `.ai/50_adr/active/0007-tech-debt-ledger-location-and-structure.md` | 원장 위치·항목 파일 구조, 소비자와 상태 행렬 |
| `.ai/50_adr/active/0002-skill-independence-intentional-duplication.md` | 공통 규칙의 스킬별 복제와 동기화 주석(R5 근거) |
| `.ai/50_adr/active/0015-issue-clear-timing-and-archive-rules.md` | `--clear` 이관 파일의 경로 참조 갱신·잔존 0건 검사 선례 |
| `.ai/50_adr/active/0003-verification-levels-and-determinization.md` | 결정화 판단·검증 레벨(R6 판정과 DoD 레벨) |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | R6에서 헬퍼로 정하면 따를 테스트 배치 |
| `.ai/50_adr/active/0020-doc-ssot-original-documents-and-publishing-deferred.md` | 원장 링크 3줄(K-0014·K-0015)을 가진 갱신 대상 예 |
| `.ai/10_rules/architecture.md` `## 디자인 원칙` | R6 판단 체크리스트 |
| `.ai/40_domain/specs/issue-workflow.md`, `git-pr-submission.md`, `git-pr-feedback.md` | R10 반영 대상 명세 |
| `.ai/60_codebase/index.md`와 호출 흐름 문서 | R10 반영 대상, 원장 링크 16줄 보유 |
