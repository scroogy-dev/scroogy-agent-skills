# Issue #116 스펙 code-map: local·global 0단계가 ai-workspace init 골격만 있는 색인을 생성된 색인으로 판정한다

## 목표 (Goal)

code-map `--local`(소스 코드)·`--global` 0단계가 `doc.md` 0단계와 같은 기준으로, ai-workspace init 템플릿 골격만 있는 `.ai/60_codebase/index.md`를 생성되지 않은 색인으로 판정한다.

---

## 요구사항 (Requirements)

**포함**

- R1: `references/local.md` 0단계는 `.ai/60_codebase/index.md`가 비어 있거나 템플릿 골격만 있으면 미생성으로 보고 `build`를 실행하며, 그 밖의 상태에서만 `sync`·`check`·`rebuild` 선택을 요청한다. 골격 기준은 `doc.md` 0단계와 같다(frontmatter가 없고 `## 파일 목록` 표의 행이 자리표시자 `(문서를 추가하면 이 목록에 함께 기재하세요)` 하나뿐).
- R2: `references/global.md` 0단계 4번 분석 상태 분류는 리포의 `.ai/60_codebase/index.md`가 없거나 비어 있거나 템플릿 골격만 있으면 `미분석`(`[NOT-INDEXED]`)으로 분류한다.
- R3: `references/global.md` 0단계 5번 모드 결정은 건물 안내도 `.ai/60_codebase/index.md`가 비어 있거나 템플릿 골격만 있으면 `build`를 실행한다.
- R4: code-map 회귀 테스트 러너(`code-map/tests/run-tests.sh`)는 `local.md`·`global.md` 0단계의 골격 미생성 판정 문장을 검사하고, 그 문장을 지우거나 자리표시자를 바꾼 사본을 격추한다. (이슈 본문 근거 없음. 2026-10-23 issue-work 3-1에서 제안. `doc.md` 같은 판정을 #114 최종 감사 F-3·PR #115 리뷰에서 구조 검사로 고정한 선례를 따른다)

**제외**

- ai-workspace가 빈 `index.md`를 만들도록 템플릿을 되돌리는 안: 대체. 골격의 제목·설명은 init 직후 색인 용도를 안내하므로 유지하고, code-map 판정을 골격에 맞춘다.
- 골격 판정 기준을 `SKILL.md` 한 곳으로 모으는 구조 변경: 불필요. 참조 문서는 모드별로 하나만 읽고 `doc.md` 기준과 테스트가 이미 `doc.md` 본문을 대상으로 하므로, 각 참조 문서에 같은 기준을 둔다.
- `local.md`·`global.md` 0단계의 모의 실행 fixture(입력·기대 쌍): 불필요. 바뀌는 것은 판정 문장 하나라 R4의 구조 검사로 덮는다.
- 0단계 밖의 `local.md`·`global.md` 절차(1단계 이후 수집·색인·점검): 불필요. 이슈가 지적한 위치는 0단계뿐이다.

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> 검증 명령은 모두 repo 루트에서 실행한다.

### R1: local 0단계 골격 판정

- [ ] [D]  `local.md` 0단계의 미생성 분기가 `doc.md`와 같은 골격 기준 문장을 갖고, 생성됨 분기는 미생성이 아닌 모든 상태이며, 구 판정 문구("비어 있음"·"내용 있음" 분기, "빈 index.md를 생성하므로")가 남지 않는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=code-map/references/local.md
  K='템플릿 골격은 frontmatter가 없고 `## 파일 목록` 표의 행이 자리표시자 `(문서를 추가하면 이 목록에 함께 기재하세요)` 하나뿐인 상태다.'
  s="$(awk '$0 == "### 0단계: 모드 결정" { f = 1; next } f && /^#+ / { exit } f' "$F")"
  [ -n "$s" ] || echo '위반: local.md 0단계 절 없음'
  [ "$(printf '%s\n' "$s" | grep -E '^- \*\*미생성\*\* → `build`' | grep -F '파일이 비어 있거나 템플릿 골격만 있는 상태다.' | grep -cF "$K")" -eq 1 ] || echo '위반: local.md 미생성 분기의 골격 판정'
  [ "$(printf '%s\n' "$s" | grep -cE '^- \*\*생성됨\*\*\(미생성이 아닌 모든 상태\) → 사용자에게 선택 요청')" -eq 1 ] || echo '위반: local.md 생성됨 분기'
  [ "$(printf '%s\n' "$s" | grep -cE '^- \*\*(비어 있음|내용 있음)\*\*|빈 index\.md를 생성하므로')" -eq 0 ] || echo '위반: local.md 구 판정 문구 잔존'
  ```

  - 설계 주의: `K`는 `doc.md` 0단계 미생성 행의 문장과 글자 단위로 같다. 같은 문장을 요구해야 두 절차의 기준이 갈라지지 않는다.
  </details>
- [ ] [QD] `local.md` 0단계만 읽은 AI가 ai-workspace 템플릿 골격 그대로인 `index.md`에 `build`를 고른다  (검증: Task N 교차모델 audit이 채점)  ← 강등 사유: 절차 문장을 AI가 실행한 결과라 명령으로 재현할 수 없다

### R2: global 0단계 4번 분석 상태 분류

- [ ] [D]  `global.md` 0단계가 골격 기준 문장을 정확히 1행 갖고, 미분석 분류가 템플릿 골격만 있는 리포를 포함하며, 분석 완료 분류는 미분석의 나머지로 정의되고 구 문구("내용이 있는 리포")가 남지 않는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=code-map/references/global.md
  K='템플릿 골격은 frontmatter가 없고 `## 파일 목록` 표의 행이 자리표시자 `(문서를 추가하면 이 목록에 함께 기재하세요)` 하나뿐인 상태다.'
  s="$(awk '$0 == "### 0단계: 리포 목록 확인 및 모드 결정" { f = 1; next } f && /^#+ / { exit } f' "$F")"
  [ -n "$s" ] || echo '위반: global.md 0단계 절 없음'
  [ "$(printf '%s\n' "$s" | grep -cF "$K")" -eq 1 ] || echo '위반: global.md 0단계 골격 기준 문장'
  [ "$(printf '%s\n' "$s" | grep -E '^[[:space:]]*- \*\*미분석\*\*:' | grep -F '없거나 비어 있거나 템플릿 골격만 있는 리포' | grep -cF '[NOT-INDEXED]')" -eq 1 ] || echo '위반: global.md 미분석 분류의 골격 판정'
  [ "$(printf '%s\n' "$s" | grep -E '^[[:space:]]*- \*\*분석 완료\*\*:' | grep -cF '미분석에 해당하지 않는 리포')" -eq 1 ] || echo '위반: global.md 분석 완료 분류'
  [ "$(printf '%s\n' "$s" | grep -cF '내용이 있는 리포')" -eq 0 ] || echo '위반: global.md 구 분류 문구 잔존'
  ```

  </details>
- [ ] [QD] `global.md` 0단계만 읽은 AI가 색인이 템플릿 골격 그대로인 리포를 `[NOT-INDEXED]`로 건너뛴다  (검증: Task N 교차모델 audit이 채점)  ← 강등 사유: 절차 문장을 AI가 실행한 결과라 명령으로 재현할 수 없다

### R3: global 0단계 5번 모드 결정

- [ ] [D]  `global.md` 0단계 5번의 미생성 분기가 템플릿 골격만 있는 건물 안내도를 포함해 `build`로 이어지고, 생성됨 분기는 미생성이 아닌 모든 상태이며, 구 분기("비어 있음"·"내용 있음")가 남지 않는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=code-map/references/global.md
  s="$(awk '$0 == "### 0단계: 리포 목록 확인 및 모드 결정" { f = 1; next } f && /^#+ / { exit } f' "$F")"
  [ -n "$s" ] || echo '위반: global.md 0단계 절 없음'
  [ "$(printf '%s\n' "$s" | grep -E '^[[:space:]]*- \*\*미생성\*\* → `build`' | grep -cF '파일이 비어 있거나 템플릿 골격만 있는 상태다.')" -eq 1 ] || echo '위반: global.md 미생성 분기의 골격 판정'
  [ "$(printf '%s\n' "$s" | grep -cE '^[[:space:]]*- \*\*생성됨\*\*\(미생성이 아닌 모든 상태\) → 사용자에게 선택 요청')" -eq 1 ] || echo '위반: global.md 생성됨 분기'
  [ "$(printf '%s\n' "$s" | grep -cE '^[[:space:]]*- \*\*(비어 있음|내용 있음)\*\*')" -eq 0 ] || echo '위반: global.md 구 분기 잔존'
  ```

  </details>
- [ ] [QD] `global.md` 0단계만 읽은 AI가 템플릿 골격 그대로인 건물 안내도에 `build`를 고른다  (검증: Task N 교차모델 audit이 채점)  ← 강등 사유: 절차 문장을 AI가 실행한 결과라 명령으로 재현할 수 없다

### R4: 0단계 골격 판정 회귀 테스트

- [ ] [D]  code-map 러너가 0 실패로 끝나고, `local.md`·`global.md` 0단계 골격 판정의 통과 케이스(각 1 이상)와 격추 케이스(local 2·global 3 이상)를 실행한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  R=code-map/tests/run-tests.sh
  out=$("$R" 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- local 0단계 골격 .*통과$')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- local 0단계 골격 .*격추$')" -ge 2 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- global 0단계 골격 .*통과$')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- global 0단계 골격 .*격추$')" -ge 3 ] \
    || echo '위반: 러너 실패 또는 0단계 골격 케이스(local 통과 1·격추 2, global 통과 1·격추 3 이상) 미실행'
  ```

  - 설계 주의: 러너 종료 코드만 보면 케이스를 넣기 전에도 통과한다. 출력의 `ok` 행을 라벨(`local 0단계 골격`·`global 0단계 골격`)과 끝 낱말(`통과`·`격추`)별로 따로 센다. 라벨 규칙은 `## 전제`에 적었다.
  - 격추 케이스 구성: local은 골격 판정 문장 삭제·자리표시자 변경, global은 미분석 분류의 골격 삭제·미생성 분기의 골격 삭제·자리표시자 변경이다.
  </details>
- [ ] [D]  러너 머리 주석이 `local.md`·`global.md`를 검사 대상에서 빼는 선언을 버리고 0단계 골격 판정 검사를 서술하며, `.ai/AI-CONTEXT.md` 트리의 `code-map/tests/` 설명이 그 검사를 적는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  R=code-map/tests/run-tests.sh
  [ "$(grep -cF '는 이 러너의 대상이 아니다' "$R")" -eq 0 ] || echo '위반: 러너 머리 주석이 local·global 제외를 선언'
  [ "$(sed -n '1,/^set -o pipefail/p' "$R" | grep -cE '^#.*0단계 골격 판정')" -ge 1 ] || echo '위반: 러너 머리 주석에 0단계 골격 판정 서술 없음'
  [ "$(awk '/^├── code-map\// { f = 1; next } f && /^├── / { exit } f' .ai/AI-CONTEXT.md | grep -E 'tests/' | grep -cF '0단계 골격 판정')" -eq 1 ] || echo '위반: AI-CONTEXT 트리 code-map/tests 설명'
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
- [ ] [D]  `local.md`·`global.md`는 0단계 절 밖이 착수 시점(`5db2b16`)과 같다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  strip0() { awk '/^### 0단계: / { f = 1; next } f && /^#+ / { f = 0 } !f'; }
  for F in code-map/references/local.md code-map/references/global.md; do
    { git cat-file -e "5db2b16:$F" && [ -r "$F" ] \
      && diff <(git show "5db2b16:$F" | strip0) <(strip0 < "$F") >/dev/null; } || echo "위반: $F 0단계 밖 변경 또는 입력 접근 실패"
  done
  ```

  - 설계 주의: 프로세스 치환 안의 실패는 `diff` 종료 상태로 전파되지 않는다. 그래서 `git cat-file -e`·`[ -r ]`로 두 입력이 있는지 먼저 확인한다.
  - 설계 주의: `5db2b16`은 이슈 착수 시점의 `main`이다. `main`으로 적으면 머지 뒤에는 바뀐 파일끼리 비교하게 되어 검사가 무의미해진다. 아래 항목도 같다.
  </details>
- [ ] [D]  `doc.md`·code-map `SKILL.md`·`code-map/tests/fixtures/`·ai-workspace 템플릿이 착수 시점(`5db2b16`)과 같다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  git diff --quiet 5db2b16 -- code-map/references/doc.md code-map/SKILL.md code-map/tests/fixtures/ ai-workspace/templates/ \
    || echo '위반: doc.md·SKILL.md·fixture·ai-workspace 템플릿 변경'
  ```

  - 설계 주의: 제외 목록(템플릿 되돌리기·`SKILL.md` 통합·모의 실행 fixture)의 경계와 판정 기준 원본(`doc.md`)이 그대로인지를 함께 본다.
  </details>

---

## 전제 (Assumptions)

- **골격 기준 문장**: `local.md`·`global.md`는 `doc.md` 0단계 미생성 행의 문장 `템플릿 골격은 frontmatter가 없고 ... 하나뿐인 상태다.`를 글자 그대로 옮긴다. 문구를 다듬으면 R1·R2 `[D]`가 실패한다. (2026-10-23 계획 작성에서 결정)
- **문장 배치**: `local.md`는 `doc.md` 0단계와 같은 꼴(머리 괄호 문장 + 미생성·생성됨 두 분기)로 바꾼다. `global.md`는 0단계 머리(번호 목록 앞)에 골격 기준을 한 번 두고 4번 미분석 분류와 5번 미생성 분기가 이를 가리킨다. 4번 분석 완료는 "미분석에 해당하지 않는 리포", 5번 생성됨은 "(미생성이 아닌 모든 상태)"로 나머지 집합을 정의한다.
- **러너 케이스 라벨**: 새 케이스 설명은 `local 0단계 골격 `·`global 0단계 골격 `으로 시작하고 끝 낱말을 `통과`·`격추` 중 하나만 쓴다. R4 `[D]`가 이 라벨로 `ok` 행을 센다.
- **러너 구조**: 기존 `violations <doc> <skill>`은 원본 문서 절차 전용이라 손대지 않고, `local.md`·`global.md` 검사를 별도 함수로 둔다. `assert_reject`는 네 파일을 모두 복사하고 세 함수의 위반을 합쳐 대조한다. 함수를 나누면 통과 케이스 `ok` 행도 파일별로 따로 찍힌다.
- **실행 환경**: 러너와 검증 명령은 macOS 기본 BSD awk·grep에서 돈다. awk 정규식에는 구간 표현(`{1,3}`)을 쓰지 않는다. 지원 여부가 awk 구현마다 다르다.
- **안내도 갱신일**: Task 2에서 `.ai/AI-CONTEXT.md` 트리 설명을 고칠 때 머리의 `> last updated:`도 수정일(2026-10-24)로 바꾼다. 이 파일을 고칠 때마다 날짜를 올려 온 커밋 이력을 따른다. (2026-10-24 Task 0에서 결정)
- **러너 골격 주석**: Task 2에서 러너 머리 주석과 함께 `TEMPLATE` 정의 위 주석 `doc.md 0단계가 이 골격을 미생성으로 판정한다.`를 `doc.md·local.md·global.md 0단계가 이 골격을 미생성으로 판정한다.`로 바꾼다. local·global도 같은 골격을 판정에 쓰게 되어 그대로 두면 주석 내용이 낡는다. (2026-10-24 Task 0에서 결정)

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `code-map/references/doc.md` 0단계 | 골격 미생성 판정의 기준 문장 (이슈 본문 "판정 기준") |
| `ai-workspace/templates/shared/.ai/60_codebase/index.md` | init이 복사하는 색인 골격. 판정 기준이 이 파일과 맞아야 한다 |
| `.ai/60_codebase/ai-workspace/init-call-flow.md` | init이 shared 골격(각 index.md 포함)을 복사하는 흐름 |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 테스트 위치·러너 규칙 (R4) |
| `.ai/50_adr/active/0003-verification-levels-and-determinization.md` | 검증 레벨과 완료 기준 형식 |
| `.ai/50_adr/active/0019-test-perspectives-and-task-level-placement.md` | spec DoD 인수 테스트와 plan Task 구현 테스트의 구분 (R4) |
