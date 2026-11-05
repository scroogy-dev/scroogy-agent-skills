# Issue #134 스펙 ai-workspace: update가 스킬 소유 구간을 최신본으로 반영하고 안내도에 프로파일을 표시한다

## 목표 (Goal)

`ai-workspace` update가 dev·doc 프로파일 모두에서 스킬이 소유한 원장 템플릿, index 고정 구간, `AI-CONTEXT.md` 표준 섹션을 최신본으로 바꾸되 사용자 작성 내용은 유지하고, 안내도에 표시한 프로파일을 내용 추정 없이 쓴다.

---

## 요구사항 (Requirements)

**포함**

- R1: update가 `70_ledger/ledger-entry-template.md`를 실행마다 템플릿 최신본으로 덮어쓴다.
- R2: update가 `50_adr/index.md`의 `## 수명 주기`를 템플릿 최신본으로 교체하고, 섹션이 없으면 파일 끝에 추가한다.
- R3: update가 `70_ledger/index.md`의 머리말(첫 `##` 제목 앞 구간)과 `## 수명 주기`를 템플릿 최신본으로 교체하고, 섹션이 없으면 파일 끝에 추가한다.
- R4: update가 `AI-CONTEXT.md`의 표준 섹션 4개(`.ai 디렉토리 구조`, `에이전트 운영 지침`, `Git 정책`, `이슈 작업 워크플로우`)를 설치본의 SSoT 선언에 맞는 템플릿 최신본으로 교체하고, 섹션이 없으면 파일 끝에 추가한다. `## 에이전트 운영 지침`이 없을 때는 update-4의 기존 삽입 규칙을 따른다.
- R5: 구간 교체는 교체 구간 밖의 내용(ADR 파일 목록, 원장 항목 목록, 사용자가 추가한 섹션, 표준 섹션 안의 템플릿에 없는 `###` 소제목)을 바꾸지 않고, 실패하면 해당 파일의 구간을 변경 전 내용 그대로 둔다.
- R6: update가 `40_domain/glossary.md`가 없으면 템플릿을 복사하고, 있으면 내용을 유지한다.
- R7: 원장 템플릿, 두 index 템플릿의 `## 수명 주기`, dev·doc `AI-CONTEXT.md` 템플릿의 표준 섹션 4개에 직접 고치면 update 때 사라진다는 안내 주석을 한 줄씩 둔다.
- R8: update 완료 보고가 내용이 바뀐 교체 대상 파일·구간과 실패 항목을 나열하고, 최신 상태에서 다시 실행하면 교체 목록이 비어 있다.
- R9: 구간 교체는 `ai-workspace/scripts/` 헬퍼로 구현하고, `ai-workspace/tests/run-tests.sh`가 정상, 섹션 없음, 사용자 섹션 보존, 실패 경로, SSoT 선언별 템플릿 선택, `###` 소제목 유지를 검사한다.
- R10: 소유 구분 기준을 새 ADR에 남기고, `specs/ai-workspace.md`와 이 repo의 `.ai/` 사본을 새 동작에 맞춘다.
- R11: `AI-CONTEXT.md`의 `## 프로젝트 도메인` 표에 `profile` 행(`dev`·`doc`)을 둔다. init은 선택한 프로파일로 채우고, update는 행이 없으면 그 실행에서 확정한 프로파일로 추가하며, `check-context.sh`가 행 누락과 `dev`·`doc` 외 값을 보고한다.
- R12: 프로파일 인자가 없으면 update가 `profile` 값을 쓰고, 값이 없거나 유효하지 않으면 내용으로 추정하지 않고 사용자에게 묻는다. 인자와 값이 다르면 자동으로 바꾸지 않고 묻는다.

**제외**

- `30_contract`·`40_domain`·`60_codebase`의 `index.md` 교체: 불필요(스킬이 고정한 정책 구간이 없고, `60_codebase`는 code-map이 머리말까지 고쳐 쓴다)
- 사용자 작성 규칙 파일 덮어쓰기: 불필요(`architecture.md`, `coding-convention.md`, `document-convention.md`, `file-change-policy.md`, `*-local.md`는 사용자가 관리한다)
- `AI-CONTEXT.md`의 나머지 섹션 교체: 불필요(도메인·목적·기술 스택·디렉토리 구조는 사용자가 쓰고, `## 프로젝트 규칙`은 사용자 행이 섞여 있어 update-4의 행 검사가 표준 행만 보강한다)
- 다른 스킬의 판단 기준을 `profile`로 변경, `profile`과 SSoT 선언의 일치 검사: 불필요(스킬은 계속 SSoT 선언을 따르고, 건물 repo는 doc 프로파일과 `소스 코드` 선언이 함께 있을 수 있다)
- 덮어쓰기 전 사용자 확인: 불필요(비교한 repo에 사용자 수정분이 없고, `issue-workflow.md`도 확인 없이 덮어쓴다)
- SYNCED 머리글과 버전 표기: 불필요(안내 주석으로 충분하고, 섹션 단위 구간에는 적용하기 어렵다)
- 다른 repo 일괄 실행: 대체(머지 후 각 repo에서 update를 실행해 반영한다)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

아래 명령은 전부 repo 루트에서 `bash`로 실행한다. 출력 0건이면 통과다.

### R1: 원장 템플릿 덮어쓰기

- [ ] [D]  구버전 `ledger-entry-template.md`가 `--dirs` 실행 뒤 템플릿 최신본과 같아지고 `교체:` 행이 출력된다 (AC1)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates; H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d)
  L=70_ledger/ledger-entry-template.md
  mkdir -p "$W/.ai/70_ledger"; echo '구버전' > "$W/.ai/$L"
  out=$("$H" --dirs "$T" "$W/.ai") || echo '위반: 종료 코드'
  cmp -s "$W/.ai/$L" "$T/shared/.ai/$L" || echo '위반: 최신본과 다름'
  printf '%s\n' "$out" | grep -qxF "교체: $L" || echo '위반: 교체 행 없음'
  rm -rf "$W"
  ```

  </details>
- [ ] [D]  `SKILL.md` update-3이 `--dirs` 호출 블록을 두어 update 실행에서 위 동작이 일어난다 (AC1)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^### update-3단계/{f=1;next} /^### update-4단계/{f=0} f' ai-workspace/SKILL.md \
    | grep -qF "\"\$sync\" --dirs '<skill 디렉토리>/templates' '.ai'" || echo '위반: update-3 호출 없음'
  ```

  </details>

### R2: ADR index 수명 주기

- [ ] [D]  `50_adr/index.md`의 `## 수명 주기`가 없거나 구버전이면 `--dirs` 실행 뒤 템플릿 최신본과 같아지고, 없던 섹션은 파일 끝에 놓인다 (AC2)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates; H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d)
  sec() { awk -v h="$2" '$0==h{f=1;print;next} f&&/^## /{exit} f' "$1"; }
  A="$W/a/.ai"; B="$W/b/.ai"; mkdir -p "$A/50_adr" "$B/50_adr"
  printf '%s\n' '# 50_adr 인덱스' '' '## 파일 목록' '' '| 파일 | 설명 |' '|------|------|' '| `active/0001-x.md` | 사용자 행 |' > "$A/50_adr/index.md"
  printf '%s\n' '# 50_adr 인덱스' '' '## 파일 목록' '' '사용자 내용' '' '## 수명 주기' '' '옛 문구' '' '## 메모' '' '사용자 메모' > "$B/50_adr/index.md"
  for w in "$A" "$B"; do
    "$H" --dirs "$T" "$w" >/dev/null || echo "위반: 종료 코드 $w"
    [ "$(sec "$w/50_adr/index.md" '## 수명 주기')" = "$(sec "$T/shared/.ai/50_adr/index.md" '## 수명 주기')" ] || echo "위반: 수명 주기 불일치 $w"
  done
  [ "$(grep '^## ' "$A/50_adr/index.md" | tail -1)" = '## 수명 주기' ] || echo '위반: 없던 섹션이 파일 끝에 없음'
  rm -rf "$W"
  ```

  </details>

### R3: 원장 index 머리말·수명 주기

- [ ] [D]  `70_ledger/index.md`의 머리말과 `## 수명 주기`가 구버전이면 `--dirs` 실행 뒤 템플릿 최신본과 같아지고, 없던 `## 수명 주기`는 파일 끝에 놓인다 (AC3)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates; H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d)
  R="$T/shared/.ai/70_ledger/index.md"
  sec() { awk -v h="$2" '$0==h{f=1;print;next} f&&/^## /{exit} f' "$1"; }
  hd() { awk '/^## /{exit} {print}' "$1"; }
  A="$W/a/.ai"; B="$W/b/.ai"; mkdir -p "$A/70_ledger" "$B/70_ledger"
  printf '%s\n' '# 70_ledger 인덱스' '' '옛 머리말' '' '## 파일 목록' '' '옛 표' '' '## 항목 목록' '' '| K-0001 |' '' '## 수명 주기' '' '옛 문구' > "$A/70_ledger/index.md"
  printf '%s\n' '# 70_ledger 인덱스' '' '옛 머리말' '' '## 파일 목록' '' '옛 표' '' '## 항목 목록' '' '| K-0001 |' > "$B/70_ledger/index.md"
  for w in "$A" "$B"; do
    "$H" --dirs "$T" "$w" >/dev/null || echo "위반: 종료 코드 $w"
    [ "$(hd "$w/70_ledger/index.md")" = "$(hd "$R")" ] || echo "위반: 머리말 불일치 $w"
    [ "$(sec "$w/70_ledger/index.md" '## 수명 주기')" = "$(sec "$R" '## 수명 주기')" ] || echo "위반: 수명 주기 불일치 $w"
  done
  [ "$(grep '^## ' "$B/70_ledger/index.md" | tail -1)" = '## 수명 주기' ] || echo '위반: 없던 섹션이 파일 끝에 없음'
  rm -rf "$W"
  ```

  </details>

### R4: AI-CONTEXT 표준 섹션

- [ ] [D]  표준 섹션 4개가 없거나 구버전이면 `--context` 실행 뒤 SSoT 선언에 맞는 템플릿 최신본과 같아진다. `profile`이 `doc`이어도 선언이 `소스 코드`면 dev 템플릿을 쓴다 (AC12)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates; H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d)
  sec() { awk -v h="$2" '$0==h{f=1;print;next} f&&/^## /{exit} f' "$1"; }
  mk() {
    mkdir -p "$1"
    printf '%s\n' '# AI-CONTEXT.md' '' '> last updated: 2026-01-01' "> SSoT: $2. 이 파일은 안내도일 뿐 진실의 원천이 아니다." '' \
      '## 프로젝트 도메인' '' '| 항목 | 값 |' '|------|----|' '| domain | d |' '| keywords | k |' "| profile | $3 |" '' \
      '## .ai 디렉토리 구조' '' '옛' '' '## 에이전트 운영 지침' '' '옛' '' '## 이슈 작업 워크플로우' '' '옛' > "$1/AI-CONTEXT.md"
  }
  mk "$W/dev/.ai" '소스 코드' dev; mk "$W/doc/.ai" '원본 문서' doc; mk "$W/bld/.ai" '소스 코드' doc
  for c in dev:dev doc:doc bld:dev; do
    d=${c%%:*}; t=${c##*:}
    "$H" --context "$T" "$W/$d/.ai" >/dev/null || echo "위반: 종료 코드 $d"
    for s in '## .ai 디렉토리 구조' '## 에이전트 운영 지침' '## Git 정책' '## 이슈 작업 워크플로우'; do
      [ "$(sec "$W/$d/.ai/AI-CONTEXT.md" "$s")" = "$(sec "$T/$t/.ai/AI-CONTEXT.md" "$s")" ] || echo "위반: $d $s 불일치"
    done
  done
  rm -rf "$W"
  ```

  </details>
- [ ] [D]  `SKILL.md` update-4가 `--context` 호출 블록을 두어 update 실행에서 위 동작이 일어난다 (AC12)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^### update-4단계/{f=1;next} /^### update-5단계/{f=0} f' ai-workspace/SKILL.md \
    | grep -qF "\"\$sync\" --context '<skill 디렉토리>/templates' '.ai'" || echo '위반: update-4 호출 없음'
  ```

  </details>
- [ ] [D]  `## 에이전트 운영 지침`이 없을 때 쓰는 update-4의 기존 삽입 규칙이 남아 있다 (AC12) (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -qF '`## .ai 디렉토리 구조` 바로 다음에 표준 골격' ai-workspace/SKILL.md || echo '위반: 삽입 규칙 없음'
  ```

  </details>

### R5: 구간 밖 보존과 실패 처리

- [ ] [D]  `--dirs` 뒤 교체 구간 밖의 내용(ADR 파일 목록, 원장 항목 목록, 사용자가 추가한 섹션)이 변경 전과 같다 (AC4)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates; H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d)
  A="$W/.ai"; mkdir -p "$A/50_adr" "$A/70_ledger"
  printf '%s\n' '# 50_adr 인덱스' '' '사용자 머리말' '' '## 파일 목록' '' '| `active/0001-x.md` | 사용자 행 |' '' '## 수명 주기' '' '옛 문구' '' '## Active ADR' '' '사용자 섹션' > "$A/50_adr/index.md"
  printf '%s\n' '# 70_ledger 인덱스' '' '옛 머리말' '' '## 파일 목록' '' '사용자 파일 행' '' '## 항목 목록' '' '| K-0001 | 사용자 행 |' '' '## 수명 주기' '' '옛 문구' '' '## 메모' '' '사용자 메모' > "$A/70_ledger/index.md"
  cp "$A/50_adr/index.md" "$W/adr.before"; cp "$A/70_ledger/index.md" "$W/led.before"
  out50() { awk '/^## 수명 주기$/{s=1;next} /^## /{s=0} !s' "$1"; }
  out70() { awk 'BEGIN{s=1} /^## 수명 주기$/{s=1;next} /^## /{s=0} !s' "$1"; }
  "$H" --dirs "$T" "$A" >/dev/null || echo '위반: 종료 코드'
  [ "$(out50 "$W/adr.before")" = "$(out50 "$A/50_adr/index.md")" ] || echo '위반: 50_adr 구간 밖 변경'
  [ "$(out70 "$W/led.before")" = "$(out70 "$A/70_ledger/index.md")" ] || echo '위반: 70_ledger 구간 밖 변경'
  rm -rf "$W"
  ```

  </details>
- [ ] [D]  `--context` 뒤 표준 섹션 밖의 내용과 표준 섹션 안의 템플릿에 없는 `###` 소제목이 변경 전과 같고, 그 소제목은 템플릿 본문 뒤에 놓인다 (AC13)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates; H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d)
  I="$W/.ai/AI-CONTEXT.md"; mkdir -p "$W/.ai"
  printf '%s\n' '# AI-CONTEXT.md' '' '> last updated: 2026-01-01' '> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.' '' \
    '## 프로젝트 목적' '' '사용자 목적' '' '## 에이전트 운영 지침' '' '옛 문구' '' '### 사용자 지침' '' '사용자 지침 본문' '' \
    '## 사용자 섹션' '' '사용자 본문' '' '## Git 정책' '' '옛 표' > "$I"
  cp "$I" "$W/before"
  sec() { awk -v h="$2" '$0==h{f=1;print;next} f&&/^## /{exit} f' "$1"; }
  out() { awk '/^## (\.ai 디렉토리 구조|에이전트 운영 지침|Git 정책|이슈 작업 워크플로우)$/{s=1;next} /^## /{s=0} !s' "$1"; }
  "$H" --context "$T" "$W/.ai" >/dev/null || echo '위반: 종료 코드'
  [ "$(out "$W/before")" = "$(out "$I")" ] || echo '위반: 표준 섹션 밖 변경'
  s=$(sec "$I" '## 에이전트 운영 지침')
  printf '%s\n' "$s" | grep -qxF '### 사용자 지침' || echo '위반: 소제목 사라짐'
  printf '%s\n' "$s" | grep -qxF '사용자 지침 본문' || echo '위반: 소제목 본문 사라짐'
  case "$s" in "$(sec "$T/dev/.ai/AI-CONTEXT.md" '## 에이전트 운영 지침')"*) ;; *) echo '위반: 템플릿 본문 뒤에 소제목이 없음' ;; esac
  rm -rf "$W"
  ```

  </details>
- [ ] [D]  구간 경계를 정할 수 없는 index는 변경 전 내용 그대로 남고, 종료 코드 1과 `실패:` 행이 나온다 (AC8)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates; H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d)
  A="$W/a/.ai"; B="$W/b/.ai"; mkdir -p "$A/50_adr" "$B/70_ledger"
  printf '%s\n' '# 50_adr 인덱스' '' '## 파일 목록' '' '사용자 행' '' '## 수명 주기' '' '옛1' '' '## 수명 주기' '' '옛2' > "$A/50_adr/index.md"
  printf '%s\n' '# 70_ledger 인덱스' '' '제목 없는 본문' > "$B/70_ledger/index.md"
  cp "$A/50_adr/index.md" "$W/a.before"; cp "$B/70_ledger/index.md" "$W/b.before"
  o=$("$H" --dirs "$T" "$A"); [ $? = 1 ] || echo '위반: 같은 제목 둘의 종료 코드'
  printf '%s\n' "$o" | grep -q '^실패: 50_adr/index.md' || echo '위반: 같은 제목 둘의 실패 행 없음'
  cmp -s "$W/a.before" "$A/50_adr/index.md" || echo '위반: 같은 제목 둘인데 파일 변경'
  o=$("$H" --dirs "$T" "$B"); [ $? = 1 ] || echo '위반: 제목 없음의 종료 코드'
  printf '%s\n' "$o" | grep -q '^실패: 70_ledger/index.md' || echo '위반: 제목 없음의 실패 행 없음'
  cmp -s "$W/b.before" "$B/70_ledger/index.md" || echo '위반: 제목 없는데 파일 변경'
  rm -rf "$W"
  ```

  </details>
- [ ] [D]  표준 섹션 경계를 정할 수 없거나 SSoT 선언이 표준 문구가 아닌 `AI-CONTEXT.md`는 변경 전 내용 그대로 남고, 종료 코드 1과 `실패:` 행이 나온다 (AC15)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates; H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d)
  I="$W/.ai/AI-CONTEXT.md"; mkdir -p "$W/.ai"
  L='> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.'
  chk() {
    cp "$I" "$W/before"
    o=$("$H" --context "$T" "$W/.ai"); [ $? = 1 ] || echo "위반: $1 종료 코드"
    printf '%s\n' "$o" | grep -q '^실패: AI-CONTEXT.md' || echo "위반: $1 실패 행 없음"
    cmp -s "$W/before" "$I" || echo "위반: $1 파일 변경"
  }
  printf '%s\n' '# AI-CONTEXT.md' '' '> last updated: 2026-01-01' "$L" '' '## Git 정책' '' '옛1' '' '## Git 정책' '' '옛2' > "$I"; chk '같은 제목'
  printf '%s\n' '# AI-CONTEXT.md' '' '> last updated: 2026-01-01' "$L" '' '## Git 정책' '' '```' '옛' > "$I"; chk '닫히지 않은 펜스'
  printf '%s\n' '# AI-CONTEXT.md' '' '> last updated: 2026-01-01' "$L" '' '## Git 정책' '' '<!-- 옛' > "$I"; chk '닫히지 않은 주석'
  printf '%s\n' '# AI-CONTEXT.md' '' '> last updated: 2026-01-01' '> SSoT: 사내 위키.' '' '## Git 정책' '' '옛' > "$I"; chk '비표준 선언'
  rm -rf "$W"
  ```

  </details>

### R6: 용어 사전 복사

- [ ] [D]  `40_domain/glossary.md`가 없으면 `--dirs` 뒤 템플릿본이 생기고, 있으면 내용이 바뀌지 않는다 (AC5)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates; H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d)
  G=40_domain/glossary.md; mkdir -p "$W/a/.ai" "$W/b/.ai/40_domain"; echo '사용자 용어' > "$W/b/.ai/$G"
  o=$("$H" --dirs "$T" "$W/a/.ai") || echo '위반: 신규 종료 코드'
  cmp -s "$W/a/.ai/$G" "$T/shared/.ai/$G" || echo '위반: 템플릿본 없음'
  printf '%s\n' "$o" | grep -qxF "추가: $G" || echo '위반: 추가 행 없음'
  "$H" --dirs "$T" "$W/b/.ai" >/dev/null || echo '위반: 기존 종료 코드'
  [ "$(cat "$W/b/.ai/$G")" = '사용자 용어' ] || echo '위반: 사용자 내용 변경'
  rm -rf "$W"
  ```

  </details>

### R7: 안내 주석

- [ ] [D]  원장 템플릿 주석 블록과 두 index 템플릿의 `## 수명 주기`에 안내 주석이 한 줄씩 있다 (AC6)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/shared/.ai
  sec() { awk -v h="$2" '$0==h{f=1;print;next} f&&/^## /{exit} f' "$1"; }
  C='<!-- 이 구간은 ai-workspace update가 최신본으로 덮어씁니다. 직접 고치면 사라집니다. -->'
  L='이 파일은 ai-workspace update가 최신본으로 덮어씁니다. 직접 고치면 사라집니다.'
  [ "$(grep -cxF "$L" "$T/70_ledger/ledger-entry-template.md")" = 1 ] || echo '위반: 원장 템플릿 주석'
  for d in 50_adr 70_ledger; do
    [ "$(sec "$T/$d/index.md" '## 수명 주기' | grep -cxF "$C")" = 1 ] || echo "위반: $d 주석"
  done
  ```

  </details>
- [ ] [D]  dev·doc `AI-CONTEXT.md` 템플릿의 표준 섹션 4개에 안내 주석이 한 줄씩 있다 (AC14)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates
  sec() { awk -v h="$2" '$0==h{f=1;print;next} f&&/^## /{exit} f' "$1"; }
  C='<!-- 이 구간은 ai-workspace update가 최신본으로 덮어씁니다. 직접 고치면 사라집니다. -->'
  for p in dev doc; do
    for s in '## .ai 디렉토리 구조' '## 에이전트 운영 지침' '## Git 정책' '## 이슈 작업 워크플로우'; do
      [ "$(sec "$T/$p/.ai/AI-CONTEXT.md" "$s" | grep -cxF "$C")" = 1 ] || echo "위반: $p $s 주석"
    done
  done
  ```

  </details>

### R8: 완료 보고와 재실행

- [ ] [D]  헬퍼 출력이 내용이 바뀐 파일과 구간만 나열하고, `SKILL.md` update-5가 그 출력을 완료 보고에 싣는다 (AC7)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates; H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d)
  S="$T/shared/.ai"; cp -R "$S" "$W/.ai"; A="$W/.ai"
  echo '구버전' > "$A/70_ledger/ledger-entry-template.md"
  awk '/^## 수명 주기$/{exit} {print}' "$S/50_adr/index.md" > "$A/50_adr/index.md"
  { printf '%s\n' '# 70_ledger 인덱스' '' '옛 머리말' ''; awk '/^## 파일 목록$/{f=1} f' "$S/70_ledger/index.md"; } > "$A/70_ledger/index.md"
  o=$("$H" --dirs "$T" "$A") || echo '위반: 종료 코드'
  diff <(printf '%s\n' "$o" | sort) <(printf '%s\n' '교체: 70_ledger/index.md 머리말' '교체: 70_ledger/ledger-entry-template.md' '추가: 50_adr/index.md ## 수명 주기' | sort) || echo '위반: 보고 행 불일치'
  awk '/^### update-5단계/{f=1;next} f&&/^(## |### |---$)/{exit} f' ai-workspace/SKILL.md \
    | grep -qF '`sync-owned.sh` 출력의 `교체:`·`추가:`·`실패:` 행' || echo '위반: update-5 조항 없음'
  rm -rf "$W"
  ```

  </details>
- [ ] [D]  최신 상태에서 세 모드를 다시 실행하면 출력이 없고 파일이 바뀌지 않는다 (AC9)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates; H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d)
  sed 's/^> last updated: YYYY-MM-DD$/> last updated: 2026-01-01/' "$T/dev/.ai/AI-CONTEXT.md" > "$W/ctx"
  cp -R "$T/shared/.ai" "$W/.ai"; cp "$W/ctx" "$W/.ai/AI-CONTEXT.md"
  echo '구버전' > "$W/.ai/70_ledger/ledger-entry-template.md"
  "$H" --dirs "$T" "$W/.ai" >/dev/null || echo '위반: 1회차 --dirs'
  "$H" --context "$T" "$W/.ai" >/dev/null || echo '위반: 1회차 --context'
  "$H" --profile dev "$W/.ai" >/dev/null || echo '위반: 1회차 --profile'
  cp -R "$W/.ai" "$W/snap"
  o=$("$H" --dirs "$T" "$W/.ai"; "$H" --context "$T" "$W/.ai"; "$H" --profile dev "$W/.ai")
  [ -z "$o" ] || echo "위반: 재실행 출력 $o"
  diff -r "$W/snap" "$W/.ai" >/dev/null || echo '위반: 재실행으로 파일 변경'
  rm -rf "$W"
  ```

  </details>

### R9: 헬퍼 테스트

- [ ] [D]  러너가 구간 교체의 정상, 섹션 없음, 사용자 섹션 보존, 실패 경로 케이스를 실행해 통과한다 (AC10)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(ai-workspace/tests/run-tests.sh 2>&1) || echo '위반: 러너 실패'
  for l in '소유 구간 정상' '소유 구간 섹션 없음' '소유 구간 사용자 섹션 보존' '소유 구간 실패 경로'; do
    printf '%s\n' "$out" | grep -qE "^ok +- $l.* 통과" || echo "위반: $l 케이스 없음"
  done
  ```

  - 설계 주의: 러너만 실행하면 케이스를 넣기 전에도 통과한다. 그래서 `ok` 행의 라벨을 함께 본다.
  </details>
- [ ] [D]  러너가 SSoT 선언별 템플릿 선택(소스 코드·원본 문서)과 `###` 소제목 유지 케이스를 실행해 통과한다 (AC16)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(ai-workspace/tests/run-tests.sh 2>&1) || echo '위반: 러너 실패'
  for l in '소유 구간 SSoT 선언별 템플릿 선택' '소유 구간 소제목 유지'; do
    printf '%s\n' "$out" | grep -qE "^ok +- $l.* 통과" || echo "위반: $l 케이스 없음"
  done
  ```

  </details>

### R10: ADR·명세·저장소 사본

- [ ] [D]  새 ADR이 `active/`에 있고 상태가 `유효`이며, 이슈 링크가 있고 `50_adr/index.md` 파일 목록에 실린다 (AC11)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  A=$(ls .ai/50_adr/active/0028-*.md 2>/dev/null)
  [ "$(printf '%s\n' "$A" | grep -c .)" = 1 ] || echo '위반: ADR 0028 파일 수'
  if [ -n "$A" ]; then
    grep -qxF -- '- **상태**: 유효' "$A" || echo '위반: 상태 줄'
    grep -qF 'issues/134' "$A" || echo '위반: 이슈 링크'
    grep -qF "| \`active/$(basename "$A")\` |" .ai/50_adr/index.md || echo '위반: index 행'
  fi
  ```

  </details>
- [ ] [D]  `specs/ai-workspace.md`가 헬퍼와 `profile`을 적고, "버전 고정 파일만 덮어쓴다"와 "`## Git 정책` 표는 검사하지 않는다" 서술을 남기지 않는다 (AC11)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=.ai/40_domain/specs/ai-workspace.md
  grep -qF 'sync-owned.sh' "$S" || echo '위반: 헬퍼 서술 없음'
  grep -qF '`profile`' "$S" || echo '위반: profile 서술 없음'
  grep -nF '만 덮어쓴다' "$S"
  grep -nF '`## Git 정책` 표는 검사하지 않는다' "$S"
  ```

  </details>
- [ ] [D]  이 repo의 `.ai/` 사본에 세 모드를 실행해도 바뀔 내용이 없다 (AC11)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates; H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d)
  cp -R .ai "$W/.ai"
  "$H" --dirs "$T" "$W/.ai" || echo '위반: --dirs 종료 코드'
  "$H" --context "$T" "$W/.ai" || echo '위반: --context 종료 코드'
  "$H" --profile dev "$W/.ai" || echo '위반: --profile 종료 코드'
  rm -rf "$W"
  ```

  - 설계 주의: 실제 `.ai/`를 바꾸지 않도록 임시 사본에서 실행한다. 바뀔 내용이 있으면 헬퍼가 `교체:`·`추가:` 행을 출력해 실패한다. 종료 코드도 함께 봐서 헬퍼가 없으면 위반으로 잡는다.
  </details>
- [ ] [QD] ADR과 명세의 서술이 구현한 소유 구분·프로파일 규칙과 일치한다 (AC11)  (검증: 교차모델 audit이 채점)  ← 강등 사유: 문장과 동작의 일치는 의미 대조라 명령으로 환원할 수 없다

### R11: profile 행

- [ ] [D]  dev·doc 템플릿의 `## 프로젝트 도메인` 표에 해당 값의 `profile` 행이 정확히 하나 있어, init으로 복사한 안내도에 선택한 프로파일이 적힌다 (AC17)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates
  for p in dev doc; do
    n=$(awk '/^## 프로젝트 도메인$/{f=1;next} f&&/^## /{exit} f' "$T/$p/.ai/AI-CONTEXT.md" | grep -cxF "| profile | $p |")
    [ "$n" = 1 ] || echo "위반: $p profile 행 ${n}개"
  done
  ```

  </details>
- [ ] [D]  `profile` 행이 없는 안내도에 `--profile`을 실행하면 그 값의 행이 표 끝에 추가되고, 다시 실행하면 출력이 없으며, `SKILL.md` update-4가 이 호출을 둔다 (AC18)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  H=ai-workspace/scripts/sync-owned.sh; W=$(mktemp -d); I="$W/.ai/AI-CONTEXT.md"; mkdir -p "$W/.ai"
  printf '%s\n' '# AI-CONTEXT.md' '' '> last updated: 2026-01-01' '> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.' '' \
    '## 프로젝트 도메인' '' '| 항목 | 값 |' '|------|----|' '| domain | d |' '| keywords | k |' '' '## 프로젝트 목적' '' '목적' > "$I"
  o=$("$H" --profile doc "$W/.ai") || echo '위반: 종료 코드'
  [ "$o" = '추가: AI-CONTEXT.md profile' ] || echo "위반: 출력 [$o]"
  [ "$(sed -n '/^| keywords | k |$/{n;p;}' "$I")" = '| profile | doc |' ] || echo '위반: 행 위치'
  o=$("$H" --profile doc "$W/.ai"); [ -z "$o" ] || echo "위반: 재실행 출력 [$o]"
  rm -rf "$W"
  awk '/^### update-4단계/{f=1;next} /^### update-5단계/{f=0} f' ai-workspace/SKILL.md \
    | grep -qF "\"\$sync\" --profile '<1단계에서 정한 프로파일>' '.ai'" || echo '위반: update-4 호출 없음'
  ```

  </details>
- [ ] [D]  `check-context.sh`가 `profile` 행 누락, 행 둘 이상, `dev`·`doc` 외 값을 보고하고, doc 프로파일과 `소스 코드` 선언의 조합은 보고하지 않으며, 러너가 이 경우들을 검사한다 (AC21)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=ai-workspace/scripts/check-context.sh; D=ai-workspace/templates/dev/.ai/AI-CONTEXT.md; W=$(mktemp -d)
  sed 's/^> last updated: YYYY-MM-DD$/> last updated: 2026-01-01/' "$D" > "$W/ok.md"
  sed '/^| profile | /d' "$W/ok.md" > "$W/none.md"
  sed 's/^| profile | dev |$/| profile | foo |/' "$W/ok.md" > "$W/bad.md"
  sed 's/^| profile | dev |$/| profile | doc |/' "$W/ok.md" > "$W/bld.md"
  awk '{print} $0=="| profile | dev |"{print "| profile | doc |"}' "$W/ok.md" > "$W/dup.md"
  "$C" "$W/ok.md" >/dev/null || echo '위반: 정상 입력 보고'
  o=$("$C" "$W/none.md"); [ $? = 1 ] && printf '%s\n' "$o" | grep -q '`profile` 행' || echo '위반: 행 누락 미보고'
  o=$("$C" "$W/dup.md"); [ $? = 1 ] && printf '%s\n' "$o" | grep -q '`profile` 행' || echo '위반: 행 둘 이상 미보고'
  o=$("$C" "$W/bad.md"); [ $? = 1 ] && printf '%s\n' "$o" | grep -q '`profile` 값' || echo '위반: 값 오류 미보고'
  "$C" "$W/bld.md" >/dev/null || echo '위반: doc 프로파일과 소스 코드 조합 보고'
  rm -rf "$W"
  out=$(ai-workspace/tests/run-tests.sh 2>&1) || echo '위반: 러너 실패'
  for l in '프로파일 행 누락' '프로파일 행 중복' '프로파일 값 오류'; do
    printf '%s\n' "$out" | grep -qE "^ok +- $l.* 격추" || echo "위반: $l 케이스 없음"
  done
  printf '%s\n' "$out" | grep -qE '^ok +- 프로파일 SSoT 조합.* 통과' || echo '위반: 조합 케이스 없음'
  ```

  </details>

### R12: 프로파일 결정

- [ ] [D]  인자가 없으면 `check-context.sh --profile`이 유효한 `profile` 값을 출력하고, 값이 없거나 유효하지 않거나 `profile` 행이 둘 이상이면 종료 코드 1과 `질의:` 행을 낸다. `SKILL.md` 1단계가 이 호출과 추정 금지를 적는다 (AC19)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=ai-workspace/scripts/check-context.sh; D=ai-workspace/templates/dev/.ai/AI-CONTEXT.md; W=$(mktemp -d)
  cp "$D" "$W/ok.md"; sed '/^| profile | /d' "$D" > "$W/none.md"; sed 's/^| profile | dev |$/| profile | foo |/' "$D" > "$W/bad.md"
  awk '{print} $0=="| profile | dev |"{print "| profile | doc |"}' "$D" > "$W/dup.md"
  [ "$("$C" --profile "$W/ok.md")" = dev ] || echo '위반: 유효 값 미출력'
  for f in none bad dup; do
    o=$("$C" --profile "$W/$f.md"); [ $? = 1 ] || echo "위반: $f 종료 코드"
    printf '%s\n' "$o" | grep -q '^질의:' || echo "위반: $f 질의 행 없음"
  done
  o=$("$C" --profile "$W/absent.md"); [ $? = 1 ] && printf '%s\n' "$o" | grep -q '^질의:' || echo '위반: 안내도 없음 질의'
  [ "$("$C" --profile "$W/absent.md" doc)" = doc ] || echo '위반: 안내도 없음 인자 미출력'
  rm -rf "$W"
  A=$(awk '/^### 1단계: 프로파일 확인/{f=1;next} /^### 2단계/{f=0} f' ai-workspace/SKILL.md)
  printf '%s\n' "$A" | grep -qF "\"\$check\" --profile '.ai/AI-CONTEXT.md'" || echo '위반: 1단계 호출 없음'
  printf '%s\n' "$A" | grep -qF '내용을 보고 추정하지 않습니다' || echo '위반: 추정 금지 없음'
  ```

  </details>
- [ ] [D]  인자가 `profile` 값과 다르거나 `profile` 행이 둘 이상이면 `check-context.sh --profile`이 안내도를 바꾸지 않고 종료 코드 1과 `질의:` 행을 낸다. `SKILL.md` 1단계가 자동 변경 금지를 적고, `sync-owned.sh --profile`은 명시한 값으로만 바꾸며 행을 하나로 남긴다 (AC20)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=ai-workspace/scripts/check-context.sh; H=ai-workspace/scripts/sync-owned.sh; D=ai-workspace/templates/dev/.ai/AI-CONTEXT.md; W=$(mktemp -d)
  mkdir -p "$W/.ai"; I="$W/.ai/AI-CONTEXT.md"; cp "$D" "$I"; cp "$I" "$W/before"
  [ "$("$C" --profile "$I" dev)" = dev ] || echo '위반: 같은 인자 미출력'
  o=$("$C" --profile "$I" doc); [ $? = 1 ] || echo '위반: 종료 코드'
  printf '%s\n' "$o" | grep -q '^질의:' || echo '위반: 질의 행 없음'
  cmp -s "$W/before" "$I" || echo '위반: 판정이 파일 변경'
  o=$("$H" --profile doc "$W/.ai") || echo '위반: 명시 변경 종료 코드'
  [ "$o" = '교체: AI-CONTEXT.md profile' ] || echo "위반: 명시 변경 출력 [$o]"
  grep -qxF '| profile | doc |' "$I" || echo '위반: 명시 변경 미반영'
  awk '{print} $0=="| profile | dev |"{print "| profile | doc |"}' "$D" > "$I"; cp "$I" "$W/before"
  o=$("$C" --profile "$I" dev); [ $? = 1 ] && printf '%s\n' "$o" | grep -q '^질의:' || echo '위반: 행 둘 이상 인자 우회'
  cmp -s "$W/before" "$I" || echo '위반: 행 둘 이상 판정이 파일 변경'
  o=$("$H" --profile dev "$W/.ai") || echo '위반: 행 정리 종료 코드'
  [ "$o" = '교체: AI-CONTEXT.md profile' ] || echo "위반: 행 정리 출력 [$o]"
  [ "$(grep -c '^| profile | ' "$I")" = 1 ] && grep -qxF '| profile | dev |' "$I" || echo '위반: 행 정리 결과'
  o=$("$H" --profile dev "$W/.ai"); [ -z "$o" ] || echo "위반: 행 정리 재실행 출력 [$o]"
  rm -rf "$W"
  awk '/^### 1단계: 프로파일 확인/{f=1;next} /^### 2단계/{f=0} f' ai-workspace/SKILL.md \
    | grep -qF '안내도 값을 자동으로 바꾸지 않습니다' || echo '위반: 자동 변경 금지 없음'
  ```

  </details>
- [ ] [QD] 1단계 질의의 답에 따라 update-4가 `profile` 값을 유지하거나 바꾸는 절차가 인자·값 조합마다 일관된다 (AC19, AC20)  (검증: 교차모델 audit이 채점)  ← 강등 사유: 질의와 답의 반영은 AI가 수행하는 절차라 명령으로 실행할 수 없다

### 공통

- [ ] [D]  repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do bash "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>

---

## 전제 (Assumptions)

**헬퍼 경계** (완료의 정의가 이 경계를 검증한다)

- `sync-owned.sh --dirs <templates 디렉토리> <.ai 디렉토리>`: update-3에서 호출한다.
  - 없을 때만 복사: 각 `index.md`, `40_domain/glossary.md`
  - 항상 최신본: `70_ledger/ledger-entry-template.md`
  - 구간 교체: `50_adr/index.md`의 `## 수명 주기`, `70_ledger/index.md`의 머리말과 `## 수명 주기`
- `sync-owned.sh --context <templates 디렉토리> <.ai 디렉토리>`: update-4 끝에서 호출한다. 표준 섹션 4개를 교체한다. 본문 2번째 줄이 doc 표준 문구면 doc 템플릿, dev 표준 문구면 dev 템플릿을 쓴다. 둘 다 아니면 고를 근거가 없어 실패로 보고한다. update-4의 SSoT 선언 행이 앞에서 표준 문구로 맞추므로 정상 흐름에서는 이 실패가 나지 않는다.
- `sync-owned.sh --profile <dev|doc> <.ai 디렉토리>`: update-4에서 1단계에서 정한 값으로 호출한다. `## 프로젝트 도메인` 첫 표 끝에 행을 넣거나 값을 바꾼다. 행이 둘 이상이면 첫 행을 그 값으로 바꾸고 나머지를 지워 한 행으로 만든다. 섹션이나 표가 없으면 실패로 보고한다.
- `check-context.sh --profile <AI-CONTEXT.md> [dev|doc]`: 1단계에서 호출한다. 정해지면 값을 출력하고 종료 코드 0, 사용자에게 물어야 하면 `질의: <사유>`를 출력하고 종료 코드 1이다. 파일을 바꾸지 않는다.
- 출력 행: `교체: <경로>[ <구간>]`, `추가: <경로>[ <구간>]`, `실패: <경로>[ <구간>] — <사유>`. 경로는 `.ai` 기준 상대 경로이고, 바뀐 내용이 없으면 출력하지 않는다.
- 종료 코드: 0 실패 없음, 1 실패 1건 이상, 2 사용 오류. 한 대상이 실패해도 다른 대상은 계속 처리한다.
- `SKILL.md`의 처리: 종료 코드 1이면 update를 계속하고 `실패:` 행을 update-5 보고에 싣는다. 종료 코드 2이면 그 호출을 중단하고 보고한다.
- 덮어쓰기는 임시 결과를 설치본에 `cat`으로 써서 권한과 심볼릭 링크를 유지한다.

**`profile` 행 규칙**

- 정상 상태의 행은 하나다. 스킬과 헬퍼는 한 행만 쓰므로 둘 이상은 손으로 고치거나 병합하면서 생긴 상태로 본다.
- 행은 `## 프로젝트 도메인` 첫 표 안에서 첫 칸의 앞뒤 공백을 뺀 값이 `profile`인 행이다. 일반 검사, `--profile` 판정, 쓰기가 같은 범위를 본다.
- 행이 둘 이상이면 값이 같아도 인자 유무와 상관없이 `질의:`로 묻는다. 일반 검사는 `'## 프로젝트 도메인' 표의 \`profile\` 행 — <N>개`로 보고한다.
- 인자는 사용자가 명령으로 정한 결정으로 본다. 그래서 행이 없거나 값이 무효일 때는 인자를 쓰고, 인자가 없으면 묻는다.

**구간 규칙**

- 제목 판정: 코드 펜스와 HTML 주석 안의 `## `는 제목으로 보지 않는다. 제목 행 끝의 공백은 무시한다.
- 코드 펜스: 앞 공백 3칸까지 들여쓴 백틱·물결 3개 이상을 인식한다.
- 닫히지 않은 코드 펜스나 HTML 주석이 있으면 뒤쪽 구간 경계를 정할 수 없어 실패로 처리한다.
- 머리말: 첫 `## ` 제목 앞까지다. 머리말을 교체하는 `70_ledger/index.md`에 `##` 제목이 없으면 경계를 정할 수 없어 실패로 처리한다.
- 없는 섹션: `50_adr/index.md`·`AI-CONTEXT.md`는 없는 섹션을 파일 끝에 템플릿 순서로 추가한다.
- 같은 `## ` 제목이 설치본에 둘 이상이거나 템플릿에 구간이 없으면 실패로 처리한다.
- 실패한 파일은 임시 결과를 쓰지 않아 변경 전 내용 그대로 남는다.
- 템플릿 섹션에 없는 `###` 소제목은 원래 순서대로 템플릿 본문 뒤에 둔다. `## 수명 주기`에도 같은 규칙을 쓴다.
- 구간 끝의 빈 줄만 다르면 변경으로 보지 않는다. 구간을 넣거나 바꾼 뒤에는 다음 구간과 빈 줄 한 줄로 구분한다.

**코드베이스 관례**

- 헬퍼는 macOS 기본 bash 3.2와 BSD awk에서 동작해야 한다. 연관 배열과 `mapfile`을 쓰지 않는다. bash 3.2는 `$변수` 바로 뒤에 한글이 오면 값이 깨지므로 `${변수}`로 쓴다.
- 헬퍼 머리 주석에 용도·사용법·종료 코드를 적고 `usage()`가 그 주석을 출력한다 (`check-context.sh`와 같은 형식). 실행 권한을 둔다.
- 러너 `ok` 행은 낱말 `통과`나 `격추` 중 하나로 끝낸다. 격추 케이스는 보호 코드나 문구를 지운 사본이 실제로 잡히는지 본다.
- `testing-principles-local.md`의 층 표가 비어 있어 템플릿 기본(`ai-workspace/tests/run-tests.sh`)을 쓴다.
- 커밋은 사용자가 요청할 때만 한다.

**검토 후 버린 대안**

- index 파일 전체 덮어쓰기: 파일 목록과 항목 목록, 한 repo의 `Active ADR` 섹션이 사라진다.
- 보존 구간만 지정하고 나머지를 템플릿 기준으로 맞추기: 사용자가 추가한 섹션을 보호하려면 예외 규칙이 더 필요하다.
- `## 수명 주기`를 AI 절차로 교체: 같은 입력에 같은 결과가 보장되어야 하고 검증과 오류 보고가 필요해 `architecture.md` 분리 기준을 충족한다.
- `> profile: dev`를 본문 3번째 줄에 두기: `## 프로젝트 도메인` 표가 이미 프로파일별 행을 담고 표 행 검사 코드도 있다.
- SSoT 선언으로 프로파일 대신하기: 건물 repo는 doc 프로파일이어도 `소스 코드`로 선언한다.
- `check-context.sh`의 doc 선언 dev 문구 잔존 검사 제거: `--context`가 같은 구간을 덮어써 조치는 중복되지만, 검사와 테스트를 지우는 변경은 이번 범위 밖이라 유지한다.

**사용자 합의 (2026-11-04 대화)**

- 교체 대상에 `70_ledger/index.md` 머리말을 포함한다.
- 표준 섹션은 4개 전부로 정한다. `## 프로젝트 규칙`은 포함하지 않는다.
- 안내 주석은 SYNCED 머리글과 버전 대신 한 줄 주석으로 둔다. AC6 범위에 따라 `70_ledger` 머리말에는 주석을 두지 않는다.
- `profile`은 `## 프로젝트 도메인` 표에 둔다.
- 원장 K-0018은 함께 해소하지 않는다. 건물 repo의 규칙 표 복구 경로가 남기 때문이다.
- 판정 근거가 없으면 헬퍼와 AI가 값을 고르지 않고 사용자 결정을 받는다. 이 원칙으로 `profile` 행 둘 이상은 `질의:`, 표준 문구가 아닌 SSoT 선언의 `--context`는 `실패:`로 처리한다 (Task 0).
- 닫히지 않은 코드 펜스와 HTML 주석은 실패로 처리한다 (Task 0).
- Task 4는 코드맵 본문만 고치고, `source_hash`·`last_synced` 표지는 커밋 뒤 코드맵 sync로 갱신한다 (Task 0).

**기존 동작 유지**

- `.ai/`는 있는데 `AI-CONTEXT.md`가 없는 경우의 처리는 바꾸지 않는다. `--context`는 이 경우 `실패:`로 보고한다.
- 다른 repo의 update 실행, `AI-CONTEXT.md` 나머지 섹션의 표준 행 보강은 변경하지 않는다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/40_domain/specs/ai-workspace.md` | update 구조 정합과 덮어쓰기 대상을 적은 명세. 이번 변경으로 갱신한다 |
| `.ai/40_domain/policies/local/ssot-and-router-principle.md` | SSoT 선언과 안내도 역할. 표준 섹션의 템플릿 선택 기준 |
| `.ai/50_adr/active/0007-tech-debt-ledger-location-and-structure.md` | 원장 index 골격과 항목 템플릿의 소유·배포 결정 |
| `.ai/50_adr/active/0008-writing-principles-ssot-distribution.md` | 버전 고정 파일을 update마다 덮어쓰는 결정 |
| `.ai/50_adr/active/0022-adr-lifecycle-status-and-superseded-move.md` | ADR `## 수명 주기`를 index에 두는 결정 |
| `.ai/50_adr/active/0023-testing-principles-pair-and-consumer-skill-references.md` | 버전 고정과 사용자 관리 파일 쌍 구조 |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 헬퍼 테스트 위치와 배포 제외 규칙 |
| `.ai/10_rules/architecture.md` | `## 디자인 원칙`의 스크립트 분리 기준 |
| `.ai/60_codebase/ai-workspace/update-call-flow.md` | update 호출 흐름 색인 |
| `.ai/60_codebase/ai-workspace/init-call-flow.md` | init 호출 흐름 색인. `profile` 행 추가로 갱신 대상 |
| `code-map/references/global.md` | 건물 repo의 SSoT 선언. 프로파일과 SSoT가 다를 수 있는 근거 |
