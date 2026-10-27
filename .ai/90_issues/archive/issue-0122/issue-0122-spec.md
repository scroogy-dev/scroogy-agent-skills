# Issue #122 스펙 ai-workspace: 테스트 원칙 파일 쌍(testing-principles·local) 도입과 안내도·context-loading 라우팅 연결

## 목표 (Goal)

dev 프로파일 repo가 테스트를 어느 층·수단·환경으로 실행할지 `10_rules`의 파일 쌍에 적고, 안내도·context-loading과 소비 스킬 3종(issue-work·issue-audit·git-qa)이 그 파일을 조건부로 읽는다.

---

## 요구사항 (Requirements)

**포함**

- R1: ai-workspace가 dev 프로파일 repo에 버전 고정 파일 `testing-principles.md`(공통 원칙 9가지, SYNCED 헤더·버전 주석)를 배포하고 update 때 항상 덮어쓴다.
- R2: ai-workspace가 dev 프로파일 repo에 사용자 관리 파일 `testing-principles-local.md`를 없을 때만 복사하며, 템플릿은 테스트 층 표·대상 환경 표·실행 셸·기기 확인(선택 섹션) 골격을 값 없이 주석 예시로 둔다.
- R3: shared `context-loading.md`에 "테스트 작성·실행 시" 라우팅 섹션이 두 파일을 "존재하면 읽는다"로 가리켜, doc repo에서는 건너뛴다.
- R4: dev AI-CONTEXT 템플릿 `## 프로젝트 규칙` 표에 `testing-principles.md` 행이 있고, update 멱등 보강 검사(SKILL.md 검사 표·`check-context.sh`)가 본문 2번째 줄이 dev 표준 SSoT 선언일 때만 그 행의 누락을 보고한다. doc 선언·비표준 선언 repo에서는 보고하지 않는다.
- R5: issue-work가 두 파일이 있으면 참조한다. plan의 Task 테스트 `[D]`는 local 층 표의 러너 호출·출력 판독·셸을 따르고, spec DoD `[D]`의 인수 테스트 층은 층 표에서 고르며, 기기 확인 Task는 두지 않는다. 파일이 없으면 현재 동작을 유지한다.
- R6: issue-audit이 두 파일이 있으면 0단계 컨텍스트로 읽고, 1단계 DoD `[D]` 재실행과 `--plan` 관점 2(가짜 `[D]` 판별)를 local에 적은 셸·전제 조건으로 실행하며, 전제가 갖춰지지 않으면 판정 불가(N/A)로 적는다. 파일이 없으면 현재 동작을 유지한다.
- R7: git-qa 4단계 체크리스트가 local 층 표의 자동 테스트가 덮는 항목을 "자동 테스트로 덮음(러너)"으로 표시해 수동 확인 항목과 구분한다. 파일이 없으면 현재 동작을 유지한다.
- R8: 결정 기록과 색인이 변경과 맞는다. 새 ADR(ADR 0008의 쌍 구조를 테스트 원칙으로 넓힌 결정과 소비 스킬 3종 연결), `.ai/40_domain/specs/ai-workspace.md`, `.ai/60_codebase/ai-workspace/` init·update 호출 흐름이 갱신된다.
- R9: 이 repo에 update 적용 결과가 반영된다. `.ai/10_rules/`에 파일 쌍이 있고 `.ai/AI-CONTEXT.md` `## 프로젝트 규칙` 표에 `testing-principles.md` 행이 있다.
- R10: SSoT 선언을 읽는 표준 문장(복제 8곳)이 안내도가 있는데 본문 2번째 줄에서 표준 선언을 찾지 못하면(`> SSoT:` 줄 부재 또는 비표준 값) 소스 코드로 폴백하면서 그 사실을 사용자에게 알리게 하고, 안내도가 없는 repo에서는 지금처럼 알리지 않는다. (함께 해소: K-0015)

**제외**

- 각 repo의 `testing-principles-local.md` 내용 작성: 불필요(각 repo가 update 뒤에 채운다)
- 각 repo의 기존 테스트 문서 내용 이전: 불필요(이슈 본문 제외)
- issue-work 검증 레벨·테스트 배치 규칙(ADR 0003·0019) 변경: 불필요(실행 수단만 새 파일에 두고 무엇을 어디서 검증할지는 그대로)
- git-review·issue-audit 카테고리 표의 "테스트" 정의 문구 변경: 불필요(ADR 0019와 같은 이유)
- 실기기 확인 절차 자체(agent-device 조작법): 대체(사용자가 요청하는 프롬프트로 수행)
- doc 프로파일 적용: 불필요(문서만 있는 repo에는 테스트 층이 없다. 공통 파일은 `templates/dev/`, 규칙 표 행 검사는 dev 표준 선언 한정)
- README 배포 파일 목록 갱신: 불필요(README ai-workspace 절에 `10_rules` 배포 파일 목록이 없다)
- 규칙 표 행 검사에 비표준 선언의 소스 코드 폴백 적용: 불필요(이슈 본문 범위 결정. 비표준 선언이면 행 검사를 하지 않고, 폴백 알림은 R10이 맡는다)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> 검증 명령은 repo 루트에서 bash로 실행한다(`bash -s <<'EOF'` 등). 근거는 `## 전제` 1번.

### R1: 공통 원칙 파일 배포

- [ ] [D]  `testing-principles.md` 템플릿이 dev 프로파일에만 있고, 1행 SYNCED 헤더·2행 버전 주석과 `## 공통 원칙` 아래 이슈 본문 A의 9개 원칙 제목을 정확히 그 순서로 갖는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/dev/.ai/10_rules/testing-principles.md
  [ -r "$T" ] || echo "위반: $T 없음"
  [ "$(sed -n 1p "$T" 2>/dev/null)" = '<!-- SYNCED by ai-workspace — 원본: ai-workspace/templates/dev/.ai/10_rules/testing-principles.md, DO NOT EDIT -->' ] || echo '위반: 1행 SYNCED 헤더'
  sed -n 2p "$T" 2>/dev/null | grep -qE '^<!-- 버전: [0-9]+\.[0-9]+\.[0-9]+ -->$' || echo '위반: 2행 버전 주석'
  diff <(awk '/^## 공통 원칙[[:space:]]*$/ { f = 1; next } f && /^## / { exit } f && /^### / { print }' "$T" 2>/dev/null) \
       <(printf '%s\n' '### 실행 환경' '### 대상 환경과 인증' '### 화면 캡처' '### 탐색과 판정 분리' '### 반복 금지' \
                       '### 전제 조건과 판정 불가' '### 시험 데이터' '### 환경 되돌리기' '### 실행 셸과 출력 형식') >/dev/null \
    || echo '위반: 공통 원칙 9개 제목 불일치'
  for d in shared doc; do
    [ ! -e "ai-workspace/templates/$d/.ai/10_rules/testing-principles.md" ] || echo "위반: $d 템플릿에 존재"
  done
  ```

  - 설계 주의: 제목 집합을 `diff`로 전수 대조해 원칙 누락·추가·순서 변경을 모두 실패로 본다.
  </details>
- [ ] [D]  init은 dev에서만 이 파일을 배포하고, update-1은 dev에서 없으면 복사하고 있으면 템플릿으로 덮어쓰며 doc에서는 복사하지 않는다
  <details>
  <summary>검증 명령 — SKILL.md 코드 블록을 임시 디렉토리에서 실행, 출력 0건이면 통과</summary>

  ```bash
  ROOT=$(pwd); SK=ai-workspace/SKILL.md; F=.ai/10_rules/testing-principles.md
  TP=ai-workspace/templates/dev/.ai/10_rules/testing-principles.md
  blk() { awk -v h="$1" '$0 ~ "^### " h { f = 1; next } f && /^### / { exit } f && /^```bash$/ { c = 1; next } c && /^```$/ { exit } c' "$SK" \
          | grep -vE '^(SKILL_DIR|PROFILE)="<'; }
  run() {
    w=$(mktemp -d); mkdir -p "$w/.ai/10_rules"
    [ -z "$3" ] || printf '%s\n' "$3" > "$w/$F"
    blk "$1" > "$w/blk.sh"
    (cd "$w" && SKILL_DIR="$ROOT/ai-workspace" PROFILE="$2" bash blk.sh) >/dev/null 2>&1
    printf '%s' "$w"
  }
  ran() { s=coding-convention.md; [ "$2" = doc ] && s=document-convention.md
          [ -e "$1/.ai/10_rules/$s" ] || echo "위반: $3 실행 실패"; }
  w=$(run 'init-1단계' dev);            ran "$w" dev 'init dev';   cmp -s "$w/$F" "$TP" || echo '위반: init dev 미배포'
  w=$(run 'init-1단계' doc);            ran "$w" doc 'init doc';   [ ! -e "$w/$F" ]     || echo '위반: init doc 배포'
  w=$(run 'update-1단계' dev);          ran "$w" dev 'update dev'; cmp -s "$w/$F" "$TP" || echo '위반: update dev 신규 미복사'
  w=$(run 'update-1단계' dev '구버전'); ran "$w" dev 'update dev'; cmp -s "$w/$F" "$TP" || echo '위반: update dev 버전 고정 덮어쓰기 안 됨'
  w=$(run 'update-1단계' doc);          ran "$w" doc 'update doc'; [ ! -e "$w/$F" ]     || echo '위반: update doc 복사'
  ```

  - 설계 주의: 템플릿 파일만 보면 SKILL.md의 복사 분기를 지워도 통과하므로, 절의 첫 bash 코드 블록을 그대로 꺼내 실행한 결과 파일로 판정한다(ai-workspace 테스트의 update-1 문서 규약 검사와 같은 방식).
  - 설계 주의: init-1 블록은 첫 두 줄에서 `SKILL_DIR`·`PROFILE`을 자리표시자로 할당해 주입한 환경변수를 덮어쓴다. `blk`가 이 입력 할당 줄을 지운다(계획 감사 F-1). update-1 블록에는 이 줄이 없어 영향이 없다.
  - 설계 주의: 실행이 실패하면 doc의 미배포 검사가 그대로 통과하므로, 실행마다 프로파일 전용 파일(dev `coding-convention.md`, doc `document-convention.md`)이 생겼는지 `ran`으로 먼저 확인한다.
  </details>
- [ ] [QD] 9개 원칙 본문이 이슈 본문 A의 내용(모바일 전용 표현은 "로컬 재현 환경"으로 일반화)을 빠짐없이 담고, 배포 파일이라 이 repo의 ADR·이슈 번호에 기대지 않는다  (검증: 교차모델 audit이 이슈 본문 A와 대조 채점)  ← 강등 사유: 원칙 서술이 이슈의 뜻을 담는지는 의미 대조라 명령으로 환원할 수 없다

### R2: 사용자 관리 파일 배포

- [ ] [D]  `testing-principles-local.md` 템플릿이 dev 프로파일에만 있고, 섹션 4개와 테스트 층 표·대상 환경 표 헤더를 정해진 이름·순서로 갖는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  L=ai-workspace/templates/dev/.ai/10_rules/testing-principles-local.md
  [ -r "$L" ] || echo "위반: $L 없음"
  diff <(grep -E '^## ' "$L" 2>/dev/null) \
       <(printf '%s\n' '## 테스트 층' '## 대상 환경' '## 실행 셸' '## 기기 확인 (모바일 앱 repo만)') >/dev/null \
    || echo '위반: 섹션 이름·순서'
  awk '/^## 테스트 층[[:space:]]*$/ { f = 1; next } f && /^## / { exit } f && /^\|/ { print; exit }' "$L" 2>/dev/null \
    | grep -qxF '| 층 | 수단·러너 | 실행 명령 | 출력 판독 | 전제 조건 | 실행 시점 |' || echo '위반: 테스트 층 표 헤더'
  awk '/^## 대상 환경[[:space:]]*$/ { f = 1; next } f && /^## / { exit } f && /^\|/ { print; exit }' "$L" 2>/dev/null \
    | grep -qxF '| 환경 | 주소 변수명 | 인증 방식 | 허용 |' || echo '위반: 대상 환경 표 헤더'
  for d in shared doc; do
    [ ! -e "ai-workspace/templates/$d/.ai/10_rules/testing-principles-local.md" ] || echo "위반: $d 템플릿에 존재"
  done
  ```

  </details>
- [ ] [D]  init은 dev에서만 이 파일을 배포하고, update-1은 dev에서 없을 때만 복사해 기존 사용자 내용을 보존하며 doc에서는 복사하지 않는다
  <details>
  <summary>검증 명령 — SKILL.md 코드 블록을 임시 디렉토리에서 실행, 출력 0건이면 통과</summary>

  ```bash
  ROOT=$(pwd); SK=ai-workspace/SKILL.md; F=.ai/10_rules/testing-principles-local.md
  TL=ai-workspace/templates/dev/.ai/10_rules/testing-principles-local.md
  blk() { awk -v h="$1" '$0 ~ "^### " h { f = 1; next } f && /^### / { exit } f && /^```bash$/ { c = 1; next } c && /^```$/ { exit } c' "$SK" \
          | grep -vE '^(SKILL_DIR|PROFILE)="<'; }
  run() {
    w=$(mktemp -d); mkdir -p "$w/.ai/10_rules"
    [ -z "$3" ] || printf '%s\n' "$3" > "$w/$F"
    blk "$1" > "$w/blk.sh"
    (cd "$w" && SKILL_DIR="$ROOT/ai-workspace" PROFILE="$2" bash blk.sh) >/dev/null 2>&1
    printf '%s' "$w"
  }
  ran() { s=coding-convention.md; [ "$2" = doc ] && s=document-convention.md
          [ -e "$1/.ai/10_rules/$s" ] || echo "위반: $3 실행 실패"; }
  w=$(run 'init-1단계' dev);                 ran "$w" dev 'init dev';   cmp -s "$w/$F" "$TL"               || echo '위반: init dev 미배포'
  w=$(run 'init-1단계' doc);                 ran "$w" doc 'init doc';   [ ! -e "$w/$F" ]                   || echo '위반: init doc 배포'
  w=$(run 'update-1단계' dev);               ran "$w" dev 'update dev'; cmp -s "$w/$F" "$TL"               || echo '위반: update dev 신규 미복사'
  w=$(run 'update-1단계' dev '사용자 내용'); ran "$w" dev 'update dev'; [ "$(cat "$w/$F")" = '사용자 내용' ] || echo '위반: update dev 사용자 내용 덮어씀'
  w=$(run 'update-1단계' doc);               ran "$w" doc 'update doc'; [ ! -e "$w/$F" ]                   || echo '위반: update doc 복사'
  ```

  - 설계 주의: 자리표시자 할당 줄 제거와 실행 성공 확인(`ran`)은 R1 두 번째 항목과 같다. 실행이 실패하면 doc 미배포와 dev 사용자 내용 보존 검사가 그대로 통과하므로 `ran`을 먼저 둔다.
  </details>
- [ ] [QD] 템플릿의 표·섹션은 값을 비워 두고 HTML 주석으로 예를 들며, 기기 확인 섹션은 선택이라는 표시와 되돌릴 항목 목록 자리를 두고 기기 이름을 적지 않는다  (검증: 교차모델 audit이 이슈 본문 A의 골격 목록과 대조 채점)  ← 강등 사유: "값 비움"과 "예시는 주석"의 경계, 기기 이름 여부는 서술 판단이다

### R3: context-loading 라우팅

- [ ] [D]  shared `context-loading.md`에 "테스트 작성·실행 시" 섹션이 하나 있고, "존재하면 읽는다" 안내 뒤·SSoT 문장 앞에 놓이며, 두 파일을 순서대로 가리키는 항목 2개만 가진다. 이 repo 사본은 템플릿과 같다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=ai-workspace/templates/shared/.ai/10_rules/context-loading.md
  s=$(grep -nE '^## 테스트 작성·실행 시[[:space:]]*$' "$C" | cut -d: -f1)
  p=$(grep -nF '작업 유형에 따라 아래 문서가 **존재하면** 먼저 읽는다' "$C" | cut -d: -f1)
  e=$(grep -nF '**SSoT는 `AI-CONTEXT.md`' "$C" | cut -d: -f1)
  { [ "$(printf '%s\n' "$s" | grep -c .)" -eq 1 ] && [ "$s" -gt "$p" ] && [ "$s" -lt "$e" ]; } 2>/dev/null || echo '위반: 섹션 1개·위치'
  diff <(awk '/^## 테스트 작성·실행 시[[:space:]]*$/ { f = 1; next } f && /^(## |---)/ { exit } f && /^- / { sub(/ —.*/, ""); print }' "$C") \
       <(printf '%s\n' '- `.ai/10_rules/testing-principles.md`' '- `.ai/10_rules/testing-principles-local.md`') >/dev/null \
    || echo '위반: 항목 2개 불일치'
  cmp -s "$C" .ai/10_rules/context-loading.md || echo '위반: 저장소 사본 불일치'
  ```

  - 설계 주의: 섹션이 "존재하면 읽는다" 안내 아래에 있어야 doc repo처럼 파일이 없는 곳에서 건너뛰는 규칙이 적용된다. 위치를 줄 번호로 고정한다.
  </details>

### R4: 안내도 규칙 표 행과 멱등 보강 검사

- [ ] [D]  dev AI-CONTEXT 템플릿 `## 프로젝트 규칙` 표에 `파일` 셀이 `.ai/10_rules/testing-principles.md`인 행이 정확히 1개 있고 doc 템플릿에는 없다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  row() { awk -F'|' '/^## 프로젝트 규칙[[:space:]]*$/ { f = 1; next } f && /^## / { exit }
                     f && /^\|/ { v = $2; gsub(/^[[:space:]]+|[[:space:]]+$/, "", v); gsub(/`/, "", v); print v }' "$1" \
          | grep -cxF '.ai/10_rules/testing-principles.md'; }
  [ "$(row ai-workspace/templates/dev/.ai/AI-CONTEXT.md)" -eq 1 ] || echo '위반: dev 템플릿 행'
  [ "$(row ai-workspace/templates/doc/.ai/AI-CONTEXT.md)" -eq 0 ] || echo '위반: doc 템플릿 행'
  ```

  </details>
- [ ] [D]  `check-context.sh`는 dev 표준 선언 안내도에서 이 행이 빠지면 보고하고, 같은 안내도를 doc 선언·비표준 선언으로 바꾸면 이 행을 보고하지 않으며, 행이 있는 dev 템플릿은 통과한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  CK=ai-workspace/scripts/check-context.sh; t=$(mktemp -d)
  sed 's/^> last updated: YYYY-MM-DD$/> last updated: 2026-10-26/' ai-workspace/templates/dev/.ai/AI-CONTEXT.md > "$t/dev.md"
  sed '/`\.ai\/10_rules\/testing-principles\.md`/d' "$t/dev.md" > "$t/dev-norow.md"
  sed 's/^> SSoT: .*/> SSoT: 원본 문서. 이 파일은 안내도일 뿐 진실의 원천이 아니다./' "$t/dev-norow.md" > "$t/docdecl-norow.md"
  sed 's/^> SSoT: .*/> SSoT: 알아서 판단할 것./' "$t/dev-norow.md" > "$t/odd-norow.md"
  "$CK" "$t/dev.md" >/dev/null 2>&1 || echo '위반: 행이 있는 dev 템플릿이 통과하지 않음'
  "$CK" "$t/dev-norow.md" 2>&1 | grep -qF 'testing-principles.md` 행' || echo '위반: dev 선언에서 행 누락 미보고'
  "$CK" "$t/docdecl-norow.md" 2>&1 | grep -qF 'testing-principles.md' && echo '위반: doc 선언에서 행 보고'
  "$CK" "$t/odd-norow.md" 2>&1 | grep -qF 'testing-principles.md' && echo '위반: 비표준 선언에서 행 보고'
  ```

  - 설계 주의: 행 누락 보고만 보면 선언과 무관하게 늘 보고하는 구현도 통과하므로, 같은 입력의 선언만 바꾼 반례 2종으로 조건을 고정한다.
  </details>
- [ ] [D]  SKILL.md 멱등 보강 검사 표에 이 행 검사 항목이 정확히 1개 있고, 검사 열이 dev 표준 선언 조건을 적는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  r=$(awk '/^#### 멱등 보강 검사/ { f = 1; next } f && /^#### / { exit } f' ai-workspace/SKILL.md \
      | grep -E '^\| `## 프로젝트 규칙` 표의 `testing-principles\.md` 행 \|')
  [ "$(printf '%s\n' "$r" | grep -c .)" -eq 1 ] || echo '위반: 검사 표 행 수'
  printf '%s\n' "$r" | grep -qF 'dev 표준 문구' || echo '위반: dev 선언 조건 미기재'
  ```

  </details>
- [ ] [D]  update-4 fixture가 새 행을 반영한다. dev 기대 결과 4종은 이 행을 1개 갖고 검사에서 이 행 누락이 보고되지 않으며, doc 케이스는 doc 선언으로 바뀌고 기대 결과에 이 행이 없다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=ai-workspace/tests/fixtures/update4-idempotent; CK=ai-workspace/scripts/check-context.sh
  row() { awk -F'|' '/^## 프로젝트 규칙[[:space:]]*$/ { f = 1; next } f && /^## / { exit }
                     f && /^\|/ { v = $2; gsub(/^[[:space:]]+|[[:space:]]+$/, "", v); gsub(/`/, "", v); print v }' "$1" \
          | grep -cxF '.ai/10_rules/testing-principles.md'; }
  for c in no-rules-section no-rules-table legacy-two-col missing-rows; do
    [ "$(row "$F/$c.expected.md")" -eq 1 ] || echo "위반: $c 기대 결과 행 수"
    "$CK" "$F/$c.expected.md" 2>&1 | grep -qF 'testing-principles.md' && echo "위반: $c 기대 결과에서 행 누락 보고"
  done
  for s in input expected; do
    sed -n 4p "$F/missing-rows-doc.$s.md" | grep -qxF '> SSoT: 원본 문서. 이 파일은 안내도일 뿐 진실의 원천이 아니다.' \
      || echo "위반: missing-rows-doc.$s 선언"
  done
  [ "$(row "$F/missing-rows-doc.expected.md")" -eq 0 ] || echo '위반: doc 기대 결과에 행'
  ```

  </details>
- [ ] [QD] update-4 모의 실행(fixture README 절차, 2회 실행 멱등 포함)이 dev 케이스에 이 행을 표 끝에 넣고 doc 케이스에는 넣지 않으며, SSoT 선언 행 조치가 같은 실행에서 dev 문구를 넣으면 이 행도 함께 보강한다고 적는다  (검증: 다른 AI가 fixture README 절차로 채점, 별도 세션)  ← 강등 사유: 조치(삽입)는 내용 생성이 섞인 AI 절차라 헬퍼가 판정하지 않는다

### R5: issue-work 조건부 참조

- [ ] [D]  issue-work SKILL.md 참조 목록에 두 파일 항목이 1개 있고, 3-2 단계가 local 층 표 참조와 기기 확인 Task를 두지 않는다는 문장을 담으며, plan 템플릿 테스트 배치 문단이 local 파일을 가리킨다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  SK=issue-work/SKILL.md; PT=issue-work/templates/issue-plan-template.md
  [ "$(awk '/^## 참조 문서/ { f = 1; next } f && /^## / { exit } f' "$SK" \
       | grep -cE '^  - `\.ai/10_rules/testing-principles\.md`·`\.ai/10_rules/testing-principles-local\.md` — ')" -eq 1 ] \
    || echo '위반: 참조 목록 항목'
  r=$(awk '/^   - \*\*3-2\. 승인 후\*\*/ { f = 1 } f && /^4\. / { exit } f' "$SK")
  printf '%s\n' "$r" | grep -qF 'testing-principles-local.md' || echo '위반: 3-2 층 표 참조'
  printf '%s\n' "$r" | grep -qF '기기 확인 Task는 두지 않는다' || echo '위반: 3-2 기기 확인 Task 문장'
  awk '/^> \*\*테스트 배치\*\*/ { p = 1 } p && (/^>[[:space:]]*$/ || !/^>/) { p = 0 } p' "$PT" \
    | grep -qF 'testing-principles-local.md' || echo '위반: plan 템플릿 테스트 배치 문단'
  ```

  </details>
- [ ] [QD] 참조 문장이 파일이 없으면 현재 동작을 유지한다는 조건과 우선순위(local > `testing-principles.md` > 스킬 내장 기본값)를 담는다  (검증: 교차모델 audit 채점)  ← 강등 사유: 조건·우선순위가 문장에 담겼는지는 서술 판단이다

### R6: issue-audit 조건부 참조

- [ ] [D]  issue-audit SKILL.md 참조 목록에 두 파일 항목이 1개 있고, 0단계가 두 파일을 읽으며, 1단계 DoD 대조 항목과 `--plan` 관점 2 항목이 같은 줄에서 local 파일의 셸·전제 조건과 판정 불가(N/A)를 적는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  SK=issue-audit/SKILL.md
  [ "$(awk '/^## 참조 문서/ { f = 1; next } f && /^## / { exit } f' "$SK" \
       | grep -cE '^  - `\.ai/10_rules/testing-principles\.md`·`\.ai/10_rules/testing-principles-local\.md` — ')" -eq 1 ] \
    || echo '위반: 참조 목록 항목'
  awk '/^### 0단계/ { f = 1; next } f && /^### / { exit } f' "$SK" | grep -qF 'testing-principles-local.md' || echo '위반: 0단계'
  grep -E '^2\. \*\*완료의 정의\(DoD\) 대조\*\*' "$SK" | grep -F 'testing-principles-local.md' | grep -qF '판정 불가(N/A)' \
    || echo '위반: 1단계 DoD 재실행 문장'
  grep -E '^2\. \*\*가짜 `\[D\]` 사전 판별\*\*' "$SK" | grep -F 'testing-principles-local.md' | grep -qF '판정 불가(N/A)' \
    || echo '위반: --plan 관점 2 문장'
  ```

  </details>
- [ ] [QD] `--plan` 대조 기준 문장이 0단계의 새 항목을 수행 대상으로 적고, 파일이 없으면 현재 동작을 유지한다  (검증: 교차모델 audit 채점)  ← 강등 사유: 절차 문장 사이의 정합은 서술 판단이다

### R7: git-qa 자동 테스트 표시

- [ ] [D]  git-qa SKILL.md 참조 목록에 두 파일 항목이 1개 있고, 4단계가 local 층 표와 "자동 테스트로 덮음(" 표시 규칙을 적으며, QA 템플릿 체크리스트에 그 표시 예시가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  SK=git-qa/SKILL.md; TP=git-qa/templates/qa-checklist-template.md
  [ "$(awk '/^## 참조 문서/ { f = 1; next } f && /^## / { exit } f' "$SK" \
       | grep -cE '^  - `\.ai/10_rules/testing-principles\.md`·`\.ai/10_rules/testing-principles-local\.md` — ')" -eq 1 ] \
    || echo '위반: 참조 목록 항목'
  s=$(awk '/^### 4단계/ { f = 1; next } f && /^(### |## )/ { exit } f' "$SK")
  printf '%s\n' "$s" | grep -qF 'testing-principles-local.md' || echo '위반: 4단계 층 표 참조'
  printf '%s\n' "$s" | grep -qF '자동 테스트로 덮음(' || echo '위반: 4단계 표시 규칙'
  grep -qE '^- \[ \] .*자동 테스트로 덮음\(' "$TP" || echo '위반: 템플릿 표시 예시'
  ```

  </details>
- [ ] [QD] 표시 규칙이 PR이 속한 repo의 층 표를 기준으로 하고, 파일을 읽지 못하면 표시 없이 현재 방식으로 작성한다  (검증: 교차모델 audit 채점)  ← 강등 사유: 읽기 경로와 폴백의 서술 정합은 의미 판단이다

### R8: 결정 기록과 색인

- [ ] [D]  새 ADR 0023이 상태 `유효`로 하나 있고 ADR index·색인 index가 그 파일을 가리키며, ai-workspace 명세와 init·update 호출 흐름이 `testing-principles`와 헬퍼 판정 10종을 반영한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  A=$(ls .ai/50_adr/active/0023-*.md 2>/dev/null)
  [ "$(printf '%s\n' "$A" | grep -c .)" -eq 1 ] || echo '위반: ADR 0023 파일 1개'
  [ -n "$A" ] && {
    grep -qxF -- '- **상태**: 유효' "$A" || echo '위반: ADR 0023 상태 줄'
    grep -qF "](active/$(basename "$A"))" .ai/50_adr/index.md 2>/dev/null || grep -qF "\`active/$(basename "$A")\`" .ai/50_adr/index.md || echo '위반: ADR index 행'
    grep -qF "50_adr/active/$(basename "$A")" .ai/60_codebase/index.md || echo '위반: 색인 index 링크'
  }
  grep -qF 'testing-principles.md' .ai/40_domain/specs/ai-workspace.md || echo '위반: 명세 배포 파일'
  grep -qF '`check-context.sh` 10종' .ai/40_domain/specs/ai-workspace.md || echo '위반: 명세 판정 수'
  grep -qF 'testing-principles' .ai/60_codebase/ai-workspace/init-call-flow.md || echo '위반: init 흐름'
  grep -qF 'testing-principles' .ai/60_codebase/ai-workspace/update-call-flow.md || echo '위반: update 흐름'
  grep -qF '10항목' .ai/60_codebase/ai-workspace/update-call-flow.md || echo '위반: update 흐름 판정 수'
  ```

  </details>
- [ ] [QD] ADR 0023이 ADR 0008의 쌍 구조를 테스트 원칙으로 넓힌 결정, 소비 스킬 3종 연결, 이슈 본문의 검토한 대안을 담는다  (검증: 교차모델 audit 채점)  ← 강등 사유: 결정 서술의 충실도는 의미 대조다

### R9: 이 repo 적용

- [ ] [D]  이 repo `.ai/10_rules/`의 파일 쌍이 템플릿과 같고, 안내도 규칙 표에 이 행이 1개 있으며 안내도가 멱등 보강 검사를 통과한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in testing-principles.md testing-principles-local.md; do
    cmp -s "ai-workspace/templates/dev/.ai/10_rules/$f" ".ai/10_rules/$f" || echo "위반: $f 사본 불일치"
  done
  [ "$(awk -F'|' '/^## 프로젝트 규칙[[:space:]]*$/ { f = 1; next } f && /^## / { exit }
                 f && /^\|/ { v = $2; gsub(/^[[:space:]]+|[[:space:]]+$/, "", v); gsub(/`/, "", v); print v }' .ai/AI-CONTEXT.md \
       | grep -cxF '.ai/10_rules/testing-principles.md')" -eq 1 ] || echo '위반: 안내도 규칙 표 행'
  ai-workspace/scripts/check-context.sh .ai/AI-CONTEXT.md >/dev/null 2>&1 || echo '위반: 안내도 멱등 보강 검사'
  ```

  </details>

### R10: SSoT 선언 폴백 알림 (K-0015)

- [ ] [D]  선언 읽기 표준 문장이 있는 파일이 정해진 9개(복제 8곳 + 이 repo context-loading 사본)이고, 각 파일에 알림 문장 앵커가 정확히 1번 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  anchor='`AI-CONTEXT.md`는 있는데 선언을 찾지 못해 소스 코드로 진행하면'
  files=$(grep -rlF '`> SSoT: <값>.` 선언을 따' --include='*.md' . | grep -vE '^\./\.ai/(90_issues|99_workspace)/' | sort)
  diff <(printf '%s\n' "$files") <(printf '%s\n' ./.ai/10_rules/context-loading.md \
         ./ai-workspace/templates/shared/.ai/10_rules/context-loading.md ./code-map/SKILL.md ./context-harvest/SKILL.md \
         ./git-pr/SKILL.md ./git-review-context/SKILL.md ./git-review-quiz/SKILL.md ./git-review/SKILL.md ./issue-audit/SKILL.md | sort) \
    >/dev/null || echo '위반: 표준 문장 복제 위치 집합'
  printf '%s\n' "$files" | while read -r f; do
    [ -z "$f" ] || [ "$(grep -cF "$anchor" "$f")" -eq 1 ] || echo "위반: $f 알림 문장"
  done
  ```

  - 설계 주의: 복제 위치를 9개 목록과 전수 대조해 새로 생긴 복제본이 알림 없이 남거나 위치가 빠지는 경우도 실패로 본다. zsh는 `$files`를 단어로 나누지 않으므로 `while read`로 돈다.
  </details>
- [ ] [D]  SSoT·라우터 정책과 ADR 0020 결정 섹션이 알림을 적고, ADR 0020 근거가 이번 변경(#122)을 기록한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -qF '선언을 찾지 못해 소스 코드로 진행하면' .ai/40_domain/policies/local/ssot-and-router-principle.md || echo '위반: 정책'
  A=.ai/50_adr/active/0020-doc-ssot-original-documents-and-publishing-deferred.md
  awk '/^## 결정/ { f = 1; next } f && /^## / { exit } f' "$A" | grep -qF '선언을 찾지 못해 소스 코드로 진행하면' || echo '위반: ADR 0020 결정'
  awk '/^## 근거/ { f = 1; next } f && /^## / { exit } f' "$A" | grep -qF '#122' || echo '위반: ADR 0020 근거 변경 기록'
  ```

  </details>
- [ ] [D]  code-map·context-harvest 테스트가 알림 문장 삭제를 격추하고 0 실패로 통과한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for R in code-map/tests/run-tests.sh context-harvest/tests/run-tests.sh; do
    out=$("$R" 2>&1) && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*알림.* 격추')" -ge 1 ] \
      || echo "위반: $R 실패 또는 알림 격추 케이스 미실행"
  done
  ```

  - 설계 주의: 격추 케이스는 구조 검사에 알림 확인이 들어가야만 통과한다(검사가 없으면 기대 위반 행이 나오지 않는다). 그래서 통과 케이스는 따로 세지 않는다.
  </details>
- [ ] [QD] 알림 문장이 `AI-CONTEXT.md`가 있을 때만 알리고 없는 repo에서는 알리지 않는다는 뜻으로 읽히며, 파일 문체(한다·합니다)를 따르고, ADR 0020 대안의 "경고를 더하는 안: 보류" 서술이 이번 채택과 맞게 고쳐진다  (검증: 교차모델 audit 채점)  ← 강등 사유: 조건의 뜻과 문체는 서술 판단이다

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
  <summary>검증 명령 — 무출력·종료 코드 0이면 통과</summary>

  ```bash
  issue-work/scripts/check-ledger-links.sh .ai
  ```

  </details>

---

## 전제 (Assumptions)

- **검증 셸**: spec·plan 검증 명령은 repo 루트에서 bash로 실행한다. 이 작업 환경의 AI 도구 셸은 zsh라 붙여 넣으면 단어 분리·`grep` 래퍼 차이로 판정이 달라질 수 있다(이슈 본문 배경의 사례).
- **원칙 제목 고정**: `## 공통 원칙`의 9개 `###` 제목은 이슈 본문 A의 굵은 라벨을 그대로 쓴다. 버전은 1.0.0, 1행 SYNCED 헤더는 `writing-principles.md` 1행 형식에 원본 경로만 바꾼다.
- **배포 파일 서술**: 두 파일은 다른 repo로 복사되므로 이 repo의 ADR·이슈 번호를 본문 근거로 쓰지 않는다. 검증 레벨 같은 issue-work 용어는 "있으면" 조건으로만 가리킨다.
- **local 골격 고정**: 섹션 4개(`## 테스트 층`·`## 대상 환경`·`## 실행 셸`·`## 기기 확인 (모바일 앱 repo만)`)와 두 표 헤더는 R2 DoD 문구로 고정한다. 대상 환경 표의 `허용` 열은 이슈 본문의 "허용 여부"다.
- **update-1 배치**: 두 파일의 복사는 dev 분기(`if [ "$PROFILE" = "dev" ]`) 안에 둔다. `testing-principles.md`는 조건 없이 덮어쓰고 local은 없을 때만 복사한다. init은 `templates/dev/.ai/*` 일괄 복사에 포함되므로 코드 변경이 없다.
- **행 검사 조건**: 본문 2번째 줄이 dev 표준 문구와 정확히 같을 때만 검사한다(이슈 본문 범위 결정). 건물 repo(`repository.yaml` 존재)도 dev 문구로 선언하므로 검사 대상이다. dev 선언 repo에 `update doc`을 실행해 파일 없이 행만 생기는 경우는 라우팅이 "존재하면 읽는다"라 막지 않는다.
- **같은 실행의 dev 문구 보강**(작성 AI 결정, 2026-10-26): SKILL.md SSoT 선언 행의 조치에 "dev 문구를 삽입·교체했으면 `testing-principles.md` 행이 없을 때 함께 넣는다"를 더한다. 헬퍼를 한 번만 실행해 그 실행에서는 행 검사가 돌지 않기 때문이며, doc 문구의 `ssot_dir` 행 보강과 같은 이유다.
- **doc fixture 선언 정정**: `missing-rows-doc` fixture는 doc 선언 도입 전에 만들어져 2번째 줄이 dev 선언이다. 그대로 두면 doc 프로파일 케이스의 기대 결과에 이 행이 들어가므로 doc 선언으로 바꾼다. 이 fixture의 범위는 `## 프로젝트 규칙` 항목뿐이라 `ssot_dir` 행 등은 더하지 않는다.
- **소비 스킬 문장 테스트**(계획 감사 F-2 보정, 2026-10-26): issue-work·issue-audit·git-qa의 참조 문장은 ADR 0019의 Task별 테스트 배치를 따라 각 스킬 러너의 조항 구조 검사로 고정한다(Task 4~6). 검사는 앵커 문구가 제자리에 있는지와 문구를 지운 사본이 격추되는지까지 보고, 조건·우선순위의 뜻은 R5~R7의 `[QD]`가 맡는다. git-qa는 러너가 없어 `git-qa/tests/run-tests.sh`를 새로 두며, 헬퍼 없이 조항만 검사하는 러너는 code-map 선례를 따른다. ADR 0008의 `writing-principles` 조건부 참조 문장은 ADR 0019 이전 변경이라 이번에 검사를 소급해 더하지 않는다.
- **issue-audit 문장 위치**: 1단계 DoD 대조(`2. **완료의 정의(DoD) 대조**`)와 `--plan` 관점 2(`2. **가짜 [D] 사전 판별**`) 문장은 기존 항목 줄 안에 덧붙인다. 0단계에는 7항을 새로 두고, `--plan` 대조 기준의 0단계 항목 수행 목록에 7항을 넣는다.
- **git-qa 층 표 읽기**(작성 AI 결정, 2026-10-26): PR이 속한 repo의 base 브랜치 `.ai/10_rules/testing-principles-local.md`를 `gh api`로 읽는다(저장소·호스트 명시는 `30_contract/github-integration.md`). 읽지 못하면 표시 없이 지금 방식으로 쓴다. 표시는 체크박스를 유지하고 항목 끝에 `— 자동 테스트로 덮음(<러너>)`을 붙여 QA가 수동 재확인 대신 러너 결과를 보게 한다.
- **git-qa 덮음 판정·표시 형식**(Task 0 사용자 답변, 2026-10-26): 표시는 그 동작을 검사하는 테스트를 PR 변경이나 대상 repo에서 찾았고 그 테스트가 층 표의 러너로 실행되는 항목에만 붙인다. 층 유형만 맞는 항목에는 붙이지 않는다. 테스트를 찾지 못하면 표시하지 않고 수동 확인 항목으로 둔다. 4단계 문장에 `테스트를 찾지 못하면 표시하지 않고` 구절을 그대로 쓰고 Task 6 조항 검사 앵커에 넣는다. 표시는 항목 끝의 증빙 방법 문구(`— 응답 body 캡처` 등)를 대체한다. 덧붙이면 수동 캡처를 할지가 모호해지기 때문이다.
- **알림 문장 고정**: 앵커는 "`AI-CONTEXT.md`는 있는데 선언을 찾지 못해 소스 코드로 진행하면"이고 어미는 파일 문체를 따른다(git-pr·git-review-quiz는 합니다체). `code-map/references/doc.md`의 분기 줄과 `global.md`의 참조 줄은 SKILL.md 규칙을 가리키기만 하므로 고치지 않는다.
- **결정 기록**: 새 ADR 번호는 0023이다. K-0015 해소는 ADR 0020의 일부 변경으로 기록한다(결정에 알림 추가, 대안 줄 갱신, 근거에 날짜·#122). ADR index `## 수명 주기`의 "결정 항목 일부 변경" 행을 따른다.
- **K-0015 종결 시점**: `해소(PR #N)` 기재, `archive/` 이동, 들어오는 링크(ADR 0020 대안 줄, K-0014, 원장 index) 갱신은 PR 번호가 필요해 `--clear`(PR이 없으면 git-pr 4단계)에서 한다. DoD에는 넣지 않는다.
- **이 repo 적용 범위**: `.ai/10_rules/testing-principles-local.md`는 템플릿 사본 그대로 둔다(내용 작성은 제외 항목). 커밋은 사용자가 요청할 때만 한다(안내도 프로젝트 규칙 4).
- **설치본 갱신 시점**: 홈 설치본(`~/.claude/skills/` 등)은 이 PR이 머지된 뒤 `/install-skills`로 재설치한다(사용자 합의). 머지 전에는 이 repo의 SKILL.md를 기준으로 작업한다.
- **버린 대안**: R9를 별도 Task로 두는 안은 버렸다. 행 검사(Task 3)와 사본 일치 검사(Task 1·2)를 넣는 순간 이 repo 안내도·사본 검사가 ai-workspace 테스트에서 실패하므로, 각 산출물을 만드는 Task에서 이 repo 적용을 함께 한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| [ADR 0008](../../../50_adr/active/0008-writing-principles-ssot-distribution.md) | 따를 선례. 버전 고정·local 쌍, context-loading·규칙 표 라우팅, 스킬 조건부 직접 참조 구조 |
| [ADR 0003](../../../50_adr/active/0003-verification-levels-and-determinization.md) | 검증 레벨 `[D]`/`[QD]`/`[ND]`. 탐색 조작을 `[QD]`·`[ND]`로 두는 원칙의 기준 (변경 없음) |
| [ADR 0019](../../../50_adr/active/0019-test-perspectives-and-task-level-placement.md) | 테스트 관점·Task별 배치. 새 파일이 실행 수단만 맡는 경계의 기준 (변경 없음) |
| [ADR 0002](../../../50_adr/active/0002-skill-independence-intentional-duplication.md) | 스킬 독립성. 소비 스킬이 파일 없을 때 내장 동작을 유지하는 근거 |
| [ADR 0001](../../../50_adr/active/0001-skill-deterministic-helper-test-convention.md) | `check-context.sh` 테스트 배치·러너 규칙 |
| [ai-workspace 명세](../../../40_domain/specs/ai-workspace.md) | update 버전 고정·사용자 관리 파일 구분, 멱등 보강 검사 목록 (R8 갱신 대상) |
| [SSoT·라우터 정책](../../../40_domain/policies/local/ssot-and-router-principle.md) | 본문 2번째 줄 SSoT 선언 dev·doc 표준 문구와 폴백 (R4 조건, R10 갱신 대상) |
| [K-0015](../../../70_ledger/active/K-0015-ssot-declaration-silent-fallback.md) | R10 함께 해소 대상. 이슈 완료 시 `해소(PR #N)` 종결 |
| [issue-workflow 명세](../../../40_domain/specs/issue-workflow.md) | issue-work 절차 (R5 대상) |
| [issue-audit 명세](../../../40_domain/specs/issue-audit.md) | issue-audit 0~3단계·`--plan` 관점 (R6 대상) |
| [ai-workspace init 흐름](../../../60_codebase/ai-workspace/init-call-flow.md), [update 흐름](../../../60_codebase/ai-workspace/update-call-flow.md) | R8 갱신 대상 |
