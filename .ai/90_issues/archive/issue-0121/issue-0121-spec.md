# Issue #121 스펙 ai-workspace·context-harvest: ADR 처리 규칙 도입 (일부 변경·대체·폐기 구분, superseded 이동 기준, 상태 표기)

## 목표 (Goal)

ADR을 일부 변경·대체·폐기할 때의 처리 기준과 상태 줄이 생겨, ADR을 `superseded/`로 옮기는 절차와 update-3 판정이 상태 줄을 기준으로 동작한다.

---

## 요구사항 (Requirements)

**포함**

- R1: ADR index(ai-workspace shared 템플릿과 이 repo 사본)의 수명 주기 섹션이 경우 4종(기존 결정을 바꾸지 않는 새 결정·결정 항목 일부 변경·결정 항목 전체 대체·대체 없는 폐기)의 처리와 위치를 정한다.
- R2: 같은 섹션이 일부 변경과 대체의 경계(결정 항목이 하나라도 유효하면 일부 변경)와 `superseded/`의 ADR은 제약으로 쓰지 않고 이력 확인에만 읽는다는 규칙을 정하고, 파일 목록의 `superseded/` 설명이 "대체·폐기된 결정"으로 바뀐다.
- R3: ADR 상태 줄(제목 아래 `- **상태**:`, 값 `유효`·`대체(ADR <번호>)`·`폐기(이슈 #N)`)이 정의되고, 상태 줄이 없는 ADR은 `유효`로 보며 기존 ADR 21건은 고치지 않는다.
- R4: ADR을 `superseded/`로 옮길 때 들어오는 링크(`50_adr/active/<파일>` 경로 링크와 ADR 사이 같은 디렉토리 링크 `./<파일>`·`<파일>`)를 새 경로로 고치고 index 파일 목록의 그 행을 `superseded/` 아래로 옮기며, 옮긴 ADR 파일명으로 `.ai/`를 검색해 옛 경로가 남지 않았는지 확인하는 규칙이, #120 들어오는 링크 갱신 정의 문장을 복제해 ADR index에 있다. (확인 수단은 이슈 본문에 없음. 2026-10-25 대화에서 헬퍼 대신 파일명 검색으로 결정)
- R5: ai-workspace update-3 "기존 파일 정리"의 `50_adr/` 판정이 본문 키워드 대신 상태 줄 값으로 동작한다(`대체`·`폐기`면 `superseded/`, `유효`이거나 상태 줄이 없으면 `active/`). (상태 줄 없는 옛 파일의 판정은 이슈 본문이 맡김. 2026-10-25 대화에서 `active/`로 결정)
- R6: context-harvest ADR 템플릿의 제목 아래에 상태 줄 자리가 있다.
- R7: context-harvest가 증분 수집으로 기존 ADR을 갱신할 때 상태 줄을 유지하고, 수집한 결정이 기존 ADR을 대체하면 ADR index 수명 주기의 처리를 따른다.
- R8: 이 처리 규칙을 새 ADR로 남긴다.
- R9: `context-loading.md`(ai-workspace shared 템플릿과 이 repo 사본)의 "정책·ADR은 코드와 동등한 제약" 문장이 `superseded/`의 ADR을 제외한다. (이슈 본문은 적을지 판단을 맡김. 2026-10-25 대화에서 적기로 결정)
- R10: `.ai/40_domain/specs/ai-workspace.md`와 `.ai/60_codebase/ai-workspace/update-call-flow.md`가 update-3 판정 변경을 반영한다.
- R11: ai-workspace update-3 "기존 파일 정리"의 이동 판단 기준 표(디렉토리 5행)와 루트 상주 파일 제외 규칙을 회귀 fixture가 덮는다. (재검토 조건 "update-3 이동 판단 기준 재수정 시" 충족. 이슈 본문은 함께 해소 여부를 맡김. 2026-10-25 대화에서 함께 해소로 결정) (함께 해소: K-0001)
- R12: `.ai/60_codebase/index.md`의 ai-workspace·context-harvest 행이 새 ADR을 링크한다. (이슈 본문 근거 없음. 2026-10-25 대화에서 #120 ADR 0021 링크 선례로 제안)

**제외**

- 기존 ADR 21건의 대체·폐기 재분류(내용 검토)와 상태 줄 소급 기재: 불필요. 상태 줄이 없으면 `유효`로 보므로 기존 파일을 고칠 이유가 없다.
- git-pr 문서 동기화 점검에 ADR 대조 행 추가: 보류. 변경이 ADR 결정과 어긋나는지 감지하는 일이며 겪은 사례가 없다. 재검토 조건 예시는 ADR 결정과 어긋난 변경이 머지된 사례 관측 시.
- issue-audit·git-review의 ADR 정합성 대조 방식 변경: 불필요. 두 스킬은 ADR index와 `context-loading.md`를 거쳐 ADR을 읽으므로 R2·R9로 `superseded/` 처리가 정해진다.
- 원장 항목의 링크 갱신: 대체. #120(ADR 0021)에서 처리했다.
- 끊긴 ADR 링크 검사 헬퍼: 보류. 규칙이 스킬 밖(ADR index)에 있어 헬퍼를 둘 스킬이 정해지지 않았고 `superseded/` 이동 사례가 0건이다. 재검토 조건 예시는 첫 `superseded/` 이동에서 링크 갱신 누락 관측 시. (이슈 본문 근거 없음. 2026-10-25 대화에서 결정)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> 모든 명령은 repo 루트에서 실행한다. 아래 고정 문자열(수명 주기 섹션의 굵은 라벨, 인용한 문구)은 이 spec이 정한 경계이며 구현은 그대로 쓴다.

### R1: 수명 주기 경우 4종

- [ ] [D]  ADR index 템플릿과 repo 사본에 `## 수명 주기` 섹션이 각각 정확히 1개이고 두 섹션 본문이 같다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/shared/.ai/50_adr/index.md; R=.ai/50_adr/index.md
  sec() { awk '/^## 수명 주기$/{f=1;next} f&&/^## /{exit} f' "$1"; }
  { [ "$(grep -c '^## 수명 주기$' "$T")" -eq 1 ] && [ "$(grep -c '^## 수명 주기$' "$R")" -eq 1 ] \
    && [ -n "$(sec "$T")" ] && [ "$(sec "$T")" = "$(sec "$R")" ]; } || echo '위반: 섹션 수 또는 두 사본 본문 불일치'
  ```

  - 설계 주의: 빈 섹션끼리 같아서 통과하지 않게 `-n`으로 본문 실재를 먼저 본다.
  </details>
- [ ] [D]  수명 주기 섹션의 표(섹션 안 유일한 표)에 경우 행이 정확히 4개이고, 위치 열이 `active/` 2행·`superseded/` 2행이다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/shared/.ai/50_adr/index.md
  rows=$(awk '/^## 수명 주기$/{f=1;next} f&&/^## /{exit} f&&/^\| /&&!/^\| 경우 \|/' "$T")
  loc=$(printf '%s\n' "$rows" | awk -F'|' 'NF>2{print $(NF-1)}')
  n=$(printf '%s\n' "$rows" | grep -c '^| '); a=$(printf '%s\n' "$loc" | grep -c 'active/'); s=$(printf '%s\n' "$loc" | grep -c 'superseded/')
  [ "$n" -eq 4 ] && [ "$a" -eq 2 ] && [ "$s" -eq 2 ] || echo "위반: 경우 행 $n, active $a, superseded $s"
  ```

  - 설계 주의: 구분선(`|---`)은 `| `로 시작하지 않아 빠진다. 섹션에 표를 하나 더 두면 행 수가 어긋나 실패하므로 상태 값 등은 표가 아닌 라벨 행에 둔다.
  </details>
- [ ] [QD] 경우 4종의 처리 문장이 이슈 본문 "방향 A" 표와 뜻이 같다  (검증: 교차모델 audit)  ← 강등 사유: 문장 의미 대조라 명령으로 환원 불가

### R2: 경계·읽기 규칙과 superseded 설명

- [ ] [D]  수명 주기 섹션에 `- **일부 변경과 대체의 경계**:` 행과 `- **대체·폐기된 ADR 읽기**:` 행이 각각 정확히 1개이고, 각각 `결정 항목이 하나라도 유효하면`과 `제약으로 쓰지 않고 이력을 확인할 때만 읽습니다`를 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/shared/.ai/50_adr/index.md
  sec=$(awk '/^## 수명 주기$/{f=1;next} f&&/^## /{exit} f' "$T")
  chk() { l=$(printf '%s\n' "$sec" | grep -E "^- \*\*$1\*\*:"); [ "$(printf '%s\n' "$l" | grep -c .)" -eq 1 ] && printf '%s' "$l" | grep -qF -- "$2" || echo "위반: $1"; }
  chk '일부 변경과 대체의 경계' '결정 항목이 하나라도 유효하면'
  chk '대체·폐기된 ADR 읽기' '제약으로 쓰지 않고 이력을 확인할 때만 읽습니다'
  ```

  </details>
- [ ] [D]  템플릿과 repo 사본의 파일 목록 `superseded/` 행이 각각 정확히 1개이고 설명이 `대체·폐기된 결정`으로 시작하며, 옛 설명 `대체된 결정 (대체한 ADR 번호를 문서 내에 명시)`이 0건이다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in ai-workspace/templates/shared/.ai/50_adr/index.md .ai/50_adr/index.md; do
    [ "$(grep -c '^| `superseded/` |' "$f")" -eq 1 ] && grep -q '^| `superseded/` | 대체·폐기된 결정' "$f" || echo "위반: $f superseded/ 행"
    grep -n '대체된 결정 (대체한 ADR 번호를 문서 내에 명시)' "$f"
  done
  ```

  - 설계 주의: 옮긴 ADR 행(`superseded/<파일>`)은 `` `superseded/` | `` 패턴에 걸리지 않아 행 수 판정에 섞이지 않는다.
  </details>

### R3: 상태 줄 정의

- [ ] [D]  수명 주기 섹션에 `- **상태 줄**:` 행이 정확히 1개이고, 형식 `` `- **상태**:` ``, 값 `` `유효` ``·`` `대체(ADR <번호>)` ``·`` `폐기(이슈 #N)` ``, `상태 줄이 없는 ADR은 \`유효\`로 봅니다`를 모두 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/shared/.ai/50_adr/index.md
  l=$(awk '/^## 수명 주기$/{f=1;next} f&&/^## /{exit} f' "$T" | grep -E '^- \*\*상태 줄\*\*:')
  [ "$(printf '%s\n' "$l" | grep -c .)" -eq 1 ] || echo '위반: 상태 줄 행 수'
  for s in '`- **상태**:`' '`유효`' '`대체(ADR <번호>)`' '`폐기(이슈 #N)`' '상태 줄이 없는 ADR은 `유효`로 봅니다'; do
    printf '%s' "$l" | grep -qF -- "$s" || echo "위반: 상태 줄 행에 없음 — $s"
  done
  ```

  - 설계 주의: 표의 처리 열에도 `대체(ADR <번호>)` 등이 있으므로 섹션 전체가 아닌 라벨 행 하나에서 찾는다. 라벨 행이 없으면 표의 문구로 통과하는 가짜 `[D]`를 막는다.
  </details>
- [ ] [D]  기존 ADR 21건(0001~0021)이 main 대비 바뀌지 않고 `active/`에 그대로 있다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  git diff --name-status main -- '.ai/50_adr/active/000[1-9]-*' '.ai/50_adr/active/001[0-9]-*' '.ai/50_adr/active/002[01]-*'
  n=$(find .ai/50_adr/active -maxdepth 1 \( -name '000[1-9]-*.md' -o -name '001[0-9]-*.md' -o -name '002[01]-*.md' \) | wc -l | tr -d ' ')
  [ "$n" -eq 21 ] || echo "위반: 기존 ADR $n건 (21건 기대)"
  ```

  - 설계 주의: 셸 glob 대신 `find`를 써서 zsh의 일치 없음 오류(`no matches found`)에 영향받지 않게 한다.
  </details>

### R4: superseded 이동 시 링크·index 갱신

- [ ] [D]  수명 주기 섹션에 `- **들어오는 링크 갱신**:` 행이 정확히 1개이고, 대상 경로·범위 제외·깊이 재계산·파일명 검색 확인 문구를 담으며 원장 전용 표기(`check-ledger-links.sh`, `K-<번호>`)는 담지 않는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/shared/.ai/50_adr/index.md
  l=$(awk '/^## 수명 주기$/{f=1;next} f&&/^## /{exit} f' "$T" | grep -E '^- \*\*들어오는 링크 갱신\*\*:')
  [ "$(printf '%s\n' "$l" | grep -c .)" -eq 1 ] || echo '위반: 들어오는 링크 갱신 행 수'
  for s in '`50_adr/active/<파일>`' '(`.ai/90_issues/archive/` 제외)' '상대 경로 깊이는 링크가 있는 문서 위치에서 다시 계산합니다' '파일명으로'; do
    printf '%s' "$l" | grep -qF -- "$s" || echo "위반: 없음 — $s"
  done
  printf '%s' "$l" | grep -nE 'check-ledger-links|K-<번호>' && echo '위반: 원장 전용 표기 잔존'
  ```

  </details>
- [ ] [D]  수명 주기 섹션에 `- **옮길 때 index 갱신**:` 행이 정확히 1개이고 `` `superseded/` 행 아래로 ``를 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/shared/.ai/50_adr/index.md
  l=$(awk '/^## 수명 주기$/{f=1;next} f&&/^## /{exit} f' "$T" | grep -E '^- \*\*옮길 때 index 갱신\*\*:')
  [ "$(printf '%s\n' "$l" | grep -c .)" -eq 1 ] && printf '%s' "$l" | grep -qF '`superseded/` 행 아래로' || echo '위반: 옮길 때 index 갱신 행'
  ```

  </details>
- [ ] [QD] 들어오는 링크 갱신 행이 #120 정의 문장(issue-work SKILL.md `## 이슈 완료 시` 3단계)과 대상 경로·확인 수단·종결 어미 외에는 뜻이 같다  (검증: 교차모델 audit)  ← 강등 사유: 두 문장의 대응 관계는 의미 대조라 명령으로 환원 불가

### R5: update-3 ADR 판정

- [ ] [D]  ai-workspace SKILL.md 이동 판단 기준 표의 `50_adr/` 행이 정확히 1개이고 상태 줄 값으로 판정하며(`대체`·`폐기`면 `superseded/`, 상태 줄이 없으면 `active/`), SKILL.md 전체에 키워드 판정 어휘(`deprecated`·`replaced`)가 0건이다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=ai-workspace/SKILL.md
  row=$(awk '/^\*\*이동 판단 기준:\*\*/{f=1;next} f&&/^#/{exit} f&&/^\| `50_adr\/` \|/' "$S")
  [ "$(printf '%s\n' "$row" | grep -c .)" -eq 1 ] || echo '위반: 50_adr/ 판정 행 수'
  for s in '`- **상태**:`' '`대체(ADR <번호>)`' '`폐기(이슈 #N)`' '`superseded/`' '상태 줄이 없으면 `active/`'; do
    printf '%s' "$row" | grep -qF -- "$s" || echo "위반: 판정 행에 없음 — $s"
  done
  grep -nE 'deprecated|replaced' "$S"
  ```

  - 설계 주의: 같은 파일의 하위 디렉토리 구조 표에도 `` | `50_adr/` | `` 행이 있어 `**이동 판단 기준:**` 뒤에서만 찾는다.
  </details>

### R6: ADR 템플릿 상태 줄

- [ ] [D]  context-harvest ADR 템플릿에서 상태 줄이 정확히 1개이고, `# ADR: <결정 제목>` 다음 비어 있지 않은 첫 행이 `- **상태**: 유효`다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=context-harvest/templates/50_adr-template.md
  [ "$(grep -c '^- \*\*상태\*\*:' "$F")" -eq 1 ] \
    && [ "$(awk '/^# ADR: /{f=1;next} f&&NF{print;exit}' "$F")" = '- **상태**: 유효' ] || echo '위반: 상태 줄 위치·값'
  ```

  </details>
- [ ] [D]  ADR 템플릿 frontmatter 키 4종(`source`·`source_url`·`related_jira`·`last_harvested`)이 그대로다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=context-harvest/templates/50_adr-template.md
  [ "$(sed -n '1,6p' "$F" | sed 's/:.*//' | tr '\n' ' ')" = '--- source source_url related_jira last_harvested --- ' ] || echo '위반: frontmatter 키'
  ```

  </details>

### R7: 증분 수집의 상태 줄 유지와 수명 주기 처리

- [ ] [D]  context-harvest SKILL.md `### 5단계: 문서 생성`이 상태 줄 유지 문장(`상태 줄(\`- **상태**:\`)은 그대로 둔다`)과 수명 주기 참조 문장(`` `.ai/50_adr/index.md`의 `## 수명 주기` ``, `섹션이 없으면 기존 ADR은 옮기지 않고`, `` 내용·상태 줄·`last_harvested`도 바꾸지 않으며 ``)을 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=context-harvest/SKILL.md
  sec=$(awk '/^### 5단계: 문서 생성$/{f=1;next} f&&/^#+ /{exit} f' "$S")
  for s in '상태 줄(`- **상태**:`)은 그대로 둔다' '`.ai/50_adr/index.md`의 `## 수명 주기`' '섹션이 없으면 기존 ADR은 옮기지 않고' '내용·상태 줄·`last_harvested`도 바꾸지 않으며'; do
    printf '%s\n' "$sec" | grep -qF -- "$s" || echo "위반: 5단계에 없음 — $s"
  done
  ```

  - 설계 주의: 5단계 본문의 코드 블록에는 `#`로 시작하는 행이 없어 `^#+ ` 종료 조건이 코드 블록 안에서 걸리지 않는다. 구현이 5단계 코드 블록에 `#` 행을 넣으면 이 전제가 깨지므로 넣지 않는다.
  </details>
- [ ] [QD] 상태 줄 유지와 수명 주기 처리 문장이 증분 수집 흐름(3단계 판정 → 5단계 갱신)과 어긋나지 않는다  (검증: 교차모델 audit)  ← 강등 사유: 절차 흐름 정합은 의미 판단

### R8: 새 ADR

- [ ] [D]  `.ai/50_adr/active/0022-*.md`가 정확히 1개이고 `- **상태**: 유효` 행과 `## 결정`·`## 근거`·`## 대안`·`## 원본 출처` 헤더를 각각 1개씩 가지며, ADR index 파일 목록에 그 파일 행이 1개 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  L=$(find .ai/50_adr/active -maxdepth 1 -name '0022-*.md')
  if [ "$(printf '%s' "$L" | grep -c .)" -ne 1 ]; then echo '위반: 0022 ADR 파일이 정확히 1개가 아님'; else
    F=$L; [ "$(grep -c '^- \*\*상태\*\*: 유효$' "$F")" -eq 1 ] || echo '위반: 상태 줄'
    for h in '## 결정' '## 근거' '## 대안' '## 원본 출처'; do [ "$(grep -cx "$h" "$F")" -eq 1 ] || echo "위반: 헤더 $h"; done
    [ "$(grep -cF "| \`active/$(basename "$F")\` |" .ai/50_adr/index.md)" -eq 1 ] || echo '위반: index 행'
  fi
  ```

  </details>
- [ ] [QD] 새 ADR의 결정 섹션이 R1~R5·R7·R9·R11의 결정과 링크 확인 수단(파일명 검색, 헬퍼 보류)을 빠짐없이 담는다  (검증: 교차모델 audit)  ← 강등 사유: 결정 내용의 누락 여부는 의미 대조

### R9: context-loading 제약 문장

- [ ] [D]  `context-loading.md` 템플릿과 repo 사본이 바이트 단위로 같고, "정책·ADR은 코드와 동등한 제약" 행이 정확히 1개이며 그 행이 `` `50_adr/superseded/` ``를 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/shared/.ai/10_rules/context-loading.md; R=.ai/10_rules/context-loading.md
  cmp -s "$T" "$R" || echo '위반: 템플릿과 repo 사본 불일치'
  [ "$(grep -c '정책·ADR은 코드와 동등한 제약' "$T")" -eq 1 ] && grep '정책·ADR은 코드와 동등한 제약' "$T" | grep -qF '`50_adr/superseded/`' || echo '위반: 제약 문장'
  ```

  </details>

### R10: 도메인 명세·호출 흐름 반영

- [ ] [D]  `specs/ai-workspace.md`의 `- update 구조 정합:` 행이 `` ADR은 `- **상태**:` ``를 담고, `update-call-flow.md`의 `루트 파일 이동` 행이 `ADR 상태 줄`을 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep '^- update 구조 정합:' .ai/40_domain/specs/ai-workspace.md | grep -qF 'ADR은 `- **상태**:`' || echo '위반: 도메인 명세'
  grep '루트 파일 이동' .ai/60_codebase/ai-workspace/update-call-flow.md | grep -qF 'ADR 상태 줄' || echo '위반: 호출 흐름'
  ```

  </details>
- [ ] [QD] 두 문서의 서술이 SKILL.md update-3 판정 행과 어긋나지 않는다  (검증: 교차모델 audit)  ← 강등 사유: 요약 서술의 정합은 의미 판단

### R11: update-3 회귀 fixture

- [ ] [D]  `ai-workspace/tests/fixtures/update3-file-cleanup/README.md` 케이스 표의 `대상 행` 열이 SKILL.md 이동 판단 기준 표의 디렉토리 5개, `루트 상주 파일`, `` `legacy/` ``를 모두 덮고, 케이스마다 input·expected 쌍이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=ai-workspace/SKILL.md; D=ai-workspace/tests/fixtures/update3-file-cleanup; R=$D/README.md
  [ -r "$R" ] || echo '위반: README 없음'
  dirs=$(awk '/^\*\*이동 판단 기준:\*\*/{f=1;next} f&&/^#/{exit} f&&/^\| `/' "$S" | awk -F'`' '{print $2}')
  [ "$(printf '%s\n' "$dirs" | grep -c .)" -eq 5 ] || echo '위반: 판단 기준 표 디렉토리 수'
  cov=$(awk -F'|' '/^\| `[a-z0-9-]+` \|/{print $3}' "$R" 2>/dev/null)
  printf '%s\n' "$dirs" | while IFS= read -r d; do
    [ -n "$d" ] && { printf '%s\n' "$cov" | grep -qF "\`$d\`" || echo "위반: 대상 행 미포함 — $d"; }
  done
  printf '%s\n' "$cov" | grep -qF '루트 상주 파일' || echo '위반: 루트 상주 파일 케이스'
  printf '%s\n' "$cov" | grep -qF '`legacy/`' || echo '위반: legacy/ 케이스'
  awk -F'`' '/^\| `[a-z0-9-]+` \|/{print $2}' "$R" 2>/dev/null | while IFS= read -r c; do
    [ -r "$D/$c.input.md" ] && [ -r "$D/$c.expected.md" ] || echo "위반: 쌍 없음 — $c"
  done
  ```

  - 설계 주의: 판단 기준 표의 디렉토리를 SKILL.md에서 뽑아 대조하므로 표에 행이 늘면 이 검사가 실패해 fixture를 함께 늘리게 한다. `` `40_domain/` ``는 `` `40_domain/policies/` ``의 부분 문자열이 아니다(뒤따르는 백틱 위치가 다름).
  - 설계 주의: 목록 순회는 `while read`로 한다. zsh는 따옴표 없는 `$dirs`를 단어로 나누지 않아 `for d in $dirs`가 한 번만 돌고, 여러 줄 패턴의 `grep -F`가 아무 줄에나 걸려 가짜 통과가 된다.
  </details>
- [ ] [QD] AI가 각 `<케이스>.input.md`에 SKILL.md update-3 "기존 파일 정리"를 적용한 결과가 `<케이스>.expected.md` 이동 표와 일치한다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: update-3은 AI가 수행하는 절차라 실행 결과를 명령으로 만들 수 없다(update-4 fixture와 같은 방식)

### R12: 코드 색인 링크

- [ ] [D]  `.ai/60_codebase/index.md`의 ai-workspace 행과 context-harvest 행이 각각 `(../50_adr/active/0022-` 링크를 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=.ai/60_codebase/index.md
  for s in ai-workspace context-harvest; do grep -E "^\| $s \|" "$F" | grep -qF '(../50_adr/active/0022-' || echo "위반: $s 행"; done
  ```

  </details>

### 공통

- [ ] [D]  repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D]  `.ai/` 아래 끊긴 원장 링크가 0건이다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  issue-work/scripts/check-ledger-links.sh '.ai'
  ```

  - 설계 주의: K-0001을 `archive/`로 옮기는 해소 기재(이슈 완료 시) 뒤에도 이 명령으로 다시 확인한다.
  </details>

---

## 전제 (Assumptions)

- **작업 기준**: 브랜치 `issue-0121`(main `429337b`에서 분기). 설치된 스킬은 #120 머지 전 버전일 수 있어 절차는 repo 소스를 기준으로 한다.
- **ADR 건수**: 이슈 작성 뒤 #120에서 0021이 추가돼 기존 ADR은 21건이다. 새 ADR 번호는 0022다.
- **설치본 index 미전파**: ai-workspace update는 설치본에 `index.md`가 있으면 덮어쓰지 않는다. 기존 설치 repo에는 수명 주기 섹션이 전파되지 않으므로 이 repo 사본만 직접 고친다. 그래서 context-harvest의 수명 주기 참조 문장에 "섹션이 없으면 기존 ADR은 옮기지 않고 내용·상태 줄·`last_harvested`도 바꾸지 않으며 새 ADR도 만들지 않는다. 6단계 결과 보고에 결정 변경 후보로 적는다. 다음 증분 수집에서 같은 소스는 이 ADR의 `last_harvested` 이후 변경분부터 다시 판정한다"는 대비 문장을 둔다(계획 단계에서 정하고 계획 감사 F-1로 보류 범위를 보정). 섹션이 없으면 일부 변경과 대체의 경계도 없어 결정 변경 전체를 보류한다. 새 ADR을 만들면 상태 줄 없는 옛 ADR과 어긋나는 결정이 둘 다 `active/`에서 제약이 된다. 같은 소스에서 문서가 여럿일 때 어느 `last_harvested`로 필터링할지 기존 SKILL.md가 정하지 않으므로, 마지막 문장으로 재판정 시점을 고정한다.
- **context-loading 전파**: `context-loading.md`는 update-1이 항상 덮어쓰는 버전 고정 파일이라 템플릿 변경이 설치본에 전파된다. repo 사본은 템플릿과 바이트 단위로 같게 둔다.
- **문체**: ADR index·ai-workspace SKILL.md는 합니다체, context-harvest SKILL.md·`context-loading.md`·ADR 본문은 한다체다.
- **수명 주기 섹션 구성**: `## 파일 목록` 다음에 두고, 표는 경우 4종 하나만 둔다. 나머지 규칙은 굵은 라벨 행 5개(`일부 변경과 대체의 경계`·`상태 줄`·`대체·폐기된 ADR 읽기`·`옮길 때 index 갱신`·`들어오는 링크 갱신`)로 둔다. 완료의 정의 `[D]`가 이 라벨과 인용 문구를 경계로 쓴다.
- **링크 갱신 문장 복제**: 원본은 issue-work SKILL.md `## 이슈 완료 시` 3단계의 `**들어오는 링크 갱신**:` 행이다(ADR 0021). 대상 경로를 `50_adr/active/<파일>`과 ADR 파일끼리의 `./` 링크로 바꾸고, 마지막 확인 문장을 헬퍼 대신 옮긴 ADR 파일명 검색으로 바꾼다. `superseded/`는 `active/`와 깊이가 같아 옮긴 ADR 안의 `../../` 링크는 그대로 유효하고, 같은 디렉토리 링크만 고칠 대상이다.
- **같은 디렉토리 링크 형식 (Task 0, 2026-10-25 사용자 결정)**: 기존 ADR 사이 링크는 `./<파일>` 형식(0007·0018·0019·0020·0021)과 `./` 없는 `<파일>` 형식(0002·0003·0004·0006·0010·0012, 7줄)이 섞여 있다. 이슈 본문의 "ADR 사이 5줄"은 `./` 형식만 센 값이다. 들어오는 링크 갱신 행은 두 형식을 모두 대상으로 적는다.
- **6단계 결과 보고 행 (Task 0, 2026-10-25 사용자 결정)**: context-harvest 5단계의 섹션 부재 대비 문장이 가리키는 보고 위치를 `### 6단계: 결과 보고` 예시 블록에 1행으로 둔다. 새 테스트 케이스는 두지 않는다.
- **사용자 결정(2026-10-25)**: 상태 줄 없는 옛 ADR은 update-3에서 `active/`로 옮긴다(키워드 판정 유지·`legacy/` 이동 기각). 링크 확인은 파일명 검색으로 하고 헬퍼는 보류한다(기존 `check-ledger-links.sh` 확장·새 헬퍼 기각). `context-loading.md`에 `superseded/` 제외를 적는다. K-0001은 함께 해소한다.
- **update-3 fixture 방식**: update-3은 AI가 수행하는 절차라 fixture 모의 실행은 `[QD]`다(update-4 fixture와 같은 방식). 러너는 케이스 쌍과 판단 기준 표 대조만 `[D]`로 본다. fixture는 K-0001 수용 사유가 요구한 대칭을 따라 판단 기준 표 5행과 루트 상주 파일·`legacy/`를 함께 덮는다.
- **K-0001 해소 시점**: fixture를 만든 Task에서 원장 상태를 바꾸지 않는다. 이슈 완료 시(`## 이슈 완료 시` 3단계) PR 번호를 알면 `해소(PR #N)`로 종결해 `archive/`로 옮기고, `60_codebase/index.md`·`update-call-flow.md`의 K-0001 링크를 들어오는 링크 갱신으로 고친다. `update-call-flow.md`의 "(수용)" 표기도 그때 바꾼다.
- **이슈 본문 "검토한 대안"**: `deprecated/` 디렉토리 신설, 상태 프론트매터 필드, issue-work에 처리 규칙 두기는 이슈 본문에서 기각했다. 새 ADR 대안 섹션에 옮겨 적는다.
- **60_codebase 반영 방식**: code-map 부분 반영 관례(#114·#118·#120)를 따른다. `60_codebase/index.md` 메모에 `#121 부분 반영` 한 줄을 더하고 index frontmatter는 유지한다. `update-call-flow.md`의 `last_synced`·`source_hash`는 이 이슈의 마지막 ai-workspace 소스 커밋으로 갱신한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/50_adr/index.md` | 수명 주기 섹션을 더할 이 repo 사본 (설치본이 있으면 update가 덮어쓰지 않음) |
| `.ai/50_adr/active/0021-ledger-archive-move-link-update.md` | 복제할 들어오는 링크 갱신 정의 문장과 #121 복제 결정 |
| `.ai/50_adr/active/0007-tech-debt-ledger-location-and-structure.md` | ADR 수명 주기(active/superseded) 언급, 키워드 판정 오분류 예 |
| `.ai/50_adr/active/0018-ledger-proactive-review-and-resolve-timing.md` | 기존 ADR을 대체하지 않고 새 ADR을 더한 관행, 키워드 판정 오분류 예 |
| `.ai/50_adr/active/0002-skill-independence-intentional-duplication.md` | shared 템플릿과 repo 사본, 정의 문장 복제의 근거 |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md`, `.ai/50_adr/active/0019-test-perspectives-and-task-level-placement.md` | 테스트 배치와 Task별 테스트 기준 |
| `.ai/50_adr/active/0003-verification-levels-and-determinization.md` | 검증 레벨과 결정화 판단 |
| `.ai/70_ledger/index.md` | 수명 주기 섹션과 `- **상태**:` 형식의 본보기 |
| `.ai/70_ledger/active/K-0001-update3-fixture-absent.md` | 함께 해소할 원장 항목 (fixture 범위의 대칭 요구는 수용 사유 참조) |
| `ai-workspace/tests/fixtures/update4-idempotent/README.md`, `context-harvest/tests/fixtures/collect-filter/README.md` | 모의 실행 fixture(`[QD]`)의 기존 형식 |
| `.ai/40_domain/specs/ai-workspace.md` | update 구조 정합 서술 갱신 대상 |
| `.ai/60_codebase/ai-workspace/update-call-flow.md` | update-3 흐름 갱신 대상 |
| `.ai/10_rules/context-loading.md` | "정책·ADR은 코드와 동등한 제약" 문장 갱신 대상 |
| `.ai/10_rules/architecture.md` | `## 디자인 원칙` 결정화 판단 (링크 검사 헬퍼 판정 근거) |
