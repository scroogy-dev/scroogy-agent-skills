# Issue #126 스펙 code-map: 호출 흐름 트리 다음에 Mermaid 시퀀스 다이어그램을 추가한다 (local·global)

## 목표 (Goal)

code-map의 local 상세 흐름 문서와 global 서비스 간 흐름 문서가 트리 다음에 Mermaid 시퀀스 다이어그램을 담아, 트리로 읽기 어려운 호출 순서·응답·비동기 구분·분기를 보여준다.

---

## 요구사항 (Requirements)

**포함**

- R1: `--local` 상세 흐름 문서(`<action>-call-flow.md`)는 `## How` 안에서 트리 코드 블록 다음에 `### 시퀀스 다이어그램` 소제목과 Mermaid `sequenceDiagram` 블록을 둔다. `references/local.md` 1-4단계의 형식 설명과 예시가 이 구조를 보인다.
- R2: `--global` `service-call-flows.md`는 흐름별 섹션마다 트리 다음에 같은 형식의 시퀀스 다이어그램을 두고, 참여자는 서비스(리포) 단위다. `references/global.md` 2단계의 형식 예시가 이 구조를 보인다.
- R3: local·global 시퀀스 다이어그램은 같은 작성 규칙을 따른다. 참여자는 트리 노드와 같게 두고 처음 호출되는 순서로 놓는다. 트리에 없는 정보(응답 `-->>`, 동기 `->>`와 비동기 `-)`, 분기·반복 `alt`·`opt`·`loop`, 트랜잭션 경계 `rect`·`Note`)를 표현하고, 메시지 문구에 `;`와 `#`를 쓰지 않는다.
- R4: 한 다이어그램으로 읽기 어려운 긴 흐름은 핵심 경로만 그리고, 생략한 호출은 트리에서 확인하라고 다이어그램 아래에 한 줄로 적는다.
- R5: build·rebuild는 상세 흐름 문서마다 트리와 시퀀스를 함께 만든다. sync는 소스가 바뀐 기능의 문서에서 둘을 함께 갱신하고, 시퀀스가 없는 기존 문서는 그 기능이 바뀔 때 추가한다.
- R6: local 3단계 점검 표에 시퀀스 누락(`## How`에 `mermaid` 블록이 없는 상세 흐름 문서)과 트리·시퀀스 불일치(시퀀스 참여자가 트리 노드와 맞지 않는 문서) 행이 있고, global 4단계 `아키텍처 문서 유효성` 행이 시퀀스를 포함하며 누락·불일치를 흐름 섹션마다 따로 판정해 흐름 단위로 센다. 새 태그 없이 local 4단계·global 5단계 결과 보고에 건수로 적는다.
- R7: `SKILL.md`의 What/How/Why 표 How 칸과 `.ai 디렉토리와의 관계` 트리 주석이 시퀀스 다이어그램을 포함하고, `## 디렉토리 트리 정렬 규칙`이 시퀀스 참여자 순서를 적용 제외로 적는다.
- R8: `code-map/tests/run-tests.sh`가 R1~R7의 새 절차 문장을 구조 검사하고, 그 문장을 지운 사본에서 검사가 실패하는 격추 케이스를 둔다.
- R9: 새 ADR이 시퀀스 다이어그램 형식(Mermaid)과 트리·시퀀스 역할 분담, 채택하지 않은 대안(PlantUML, ASCII)과 이유를 기록한다. 원장 K-0006 `재검토 이력`에 점검 표 항목 추가를 계기로 한 행이 추가된다.
- R10: README의 code-map 행과 `.ai/60_codebase/index.md`의 code-map 행이 변경과 맞는다. 갱신 여부는 문서 동기화 점검에서 정한다. (`60_codebase/index.md` 행은 이슈 본문 근거 없음. 2026-10-31 issue-work 시작 시 추가)

**제외**

- 원본 문서 색인(`references/doc.md`): 불필요(상세 흐름 파일이 없다)
- 이 repo `.ai/60_codebase/`의 기존 상세 흐름 15건 보충: 대체(다음 sync에서 바뀐 기능만 반영하고, check가 누락을 보고한다)
- check 판정 헬퍼(`scripts/`) 작성: 대체(기등재 K-0006이 맡는다)
- 상세 흐름 작성 기준(`references/local.md` 1-4단계 3가지) 변경: 불필요(이슈 본문 제외)
- 시퀀스 누락·불일치 전용 태그 신설: 불필요(결과 보고 건수로 대신한다)
- 긴 흐름 판정의 수치 기준(참여자 수 등): 불필요(한 다이어그램으로 읽기 어려운지로 판단한다. 이슈 본문 근거 없음. 2026-10-31 대화에서 결정)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> 검증 명령은 repo 루트에서 bash로 실행한다(`bash -s <<'EOF'` 등). 근거는 `## 전제`의 검증 셸 항목.

### R1: local 상세 흐름 구조

- [ ] [D]  `local.md` 1단계에 시퀀스 안내 문장(작성 규칙 링크 포함)이 있고, 상세 흐름 예시의 `## How`에서 트리 코드 블록, `### 시퀀스 다이어그램` 소제목, `sequenceDiagram`으로 시작하는 `mermaid` 코드 블록이 `## Why` 앞에 그 순서로 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  L=code-map/references/local.md
  s=$(awk '$0 == "### 1단계: 소스코드 색인" { f = 1; next } $0 == "### 2단계: 교차 참조 연결" { exit } f' "$L")
  [ -n "$s" ] || echo '위반: local.md 1단계 절 없음'
  printf '%s\n' "$s" | grep -qF '트리 다음에는 같은 흐름을 Mermaid 시퀀스 다이어그램으로 그리며, [시퀀스 다이어그램 작성 규칙](../SKILL.md#시퀀스-다이어그램-작성-규칙)을 따른다' \
    || echo '위반: 1-4 시퀀스 안내 문장'
  printf '%s\n' "$s" | awk '
    $0 == "## How" { st = 1; next }
    st == 1 && $0 == "```" { st = 2; next }
    st == 2 && $0 == "```" { st = 3; next }
    st == 3 && $0 == "### 시퀀스 다이어그램" { st = 4; next }
    st == 4 && $0 == "```mermaid" { st = 5; next }
    st == 5 { st = ($0 == "sequenceDiagram") ? 6 : -1; next }
    st == 6 && $0 == "```" { st = 7; next }
    $0 == "## Why" { exit }
    END { if (st != 7) print "위반: 예시 How의 트리 → 시퀀스 소제목 → mermaid 블록 순서" }'
  ```

  - 설계 주의: 절 경계를 다음 `###` 제목이 아니라 `### 2단계` 행으로 고정한다. 예시 안의 `### 시퀀스 다이어그램`이 `###` 경계로 잡히면 절이 거기서 끊긴다.
  </details>

### R2: global 서비스 간 흐름 구조

- [ ] [D]  `global.md` `## 파일 구조`의 `service-call-flows.md` 설명 줄이 1행이고 흐름별 시퀀스 생성·갱신, 서비스(리포) 단위 참여자, 작성 규칙 링크를 담으며, 2단계 예시 `## 사용자 로그인`에서 트리 코드 블록, `### 시퀀스 다이어그램`, `sequenceDiagram`으로 시작하는 `mermaid` 블록이 그 순서로 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  G=code-map/references/global.md
  line=$(awk '$0 == "## 파일 구조" { f = 1; next } f && /^## / { exit } f' "$G" | grep -E '^- `service-call-flows\.md`:')
  [ "$(printf '%s\n' "$line" | grep -c .)" -eq 1 ] || echo '위반: service-call-flows.md 설명 줄이 1행이 아님'
  for p in '흐름별 섹션마다 트리 다음에 시퀀스 다이어그램을 함께 생성·갱신한다' '참여자는 서비스(리포) 단위' \
           '[시퀀스 다이어그램 작성 규칙](../SKILL.md#시퀀스-다이어그램-작성-규칙)'; do
    printf '%s\n' "$line" | grep -qF -- "$p" || echo "위반: 설명 줄에 '$p' 없음"
  done
  awk '$0 == "### 2단계: 아키텍처 문서 생성/갱신" { f = 1; next } $0 == "### 3단계: 건물 안내도 갱신" { exit } f' "$G" | awk '
    $0 == "## 사용자 로그인" { st = 1; next }
    st == 1 && $0 == "```" { st = 2; next }
    st == 2 && $0 == "```" { st = 3; next }
    st == 3 && $0 == "### 시퀀스 다이어그램" { st = 4; next }
    st == 4 && $0 == "```mermaid" { st = 5; next }
    st == 5 { st = ($0 == "sequenceDiagram") ? 6 : -1; next }
    st == 6 && $0 == "```" { st = 7; next }
    st >= 1 && /^`````$/ { exit }
    END { if (st != 7) print "위반: 예시 사용자 로그인의 트리 → 시퀀스 소제목 → mermaid 블록 순서" }'
  ```

  </details>

### R3: 공통 작성 규칙

- [ ] [D]  `SKILL.md`에 `## 시퀀스 다이어그램 작성 규칙` 섹션이 있고, 라벨 행 8개(위치·형식, 참여자, 응답, 동기·비동기, 분기·반복, 트랜잭션 경계, 금지 문자, 긴 흐름)가 그 이름·순서로만 있으며, 각 라벨 행이 정해진 표기 리터럴을 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  K=code-map/SKILL.md
  s=$(awk '$0 == "## 시퀀스 다이어그램 작성 규칙" { f = 1; next } f && /^## / { exit } f' "$K")
  [ -n "$s" ] || echo '위반: 작성 규칙 섹션 없음'
  diff <(printf '%s\n' "$s" | grep -E '^- \*\*[^*]+\*\*:' | sed -E 's/^- \*\*([^*]+)\*\*:.*/\1/') \
       <(printf '%s\n' '위치·형식' '참여자' '응답' '동기·비동기' '분기·반복' '트랜잭션 경계' '금지 문자' '긴 흐름') >/dev/null \
    || echo '위반: 라벨 8개 이름·순서'
  row() { printf '%s\n' "$s" | grep -E "^- \*\*$1\*\*:"; }
  for pair in '위치·형식|`### 시퀀스 다이어그램`' '위치·형식|`sequenceDiagram`' '참여자|호출 주체' '참여자|`--global`은 서비스' \
              '참여자|`participant`로 미리 선언' '참여자|처음 호출되는 순서' '응답|`-->>`' '동기·비동기|`->>`' '동기·비동기|`-)`' \
              '분기·반복|`alt`·`opt`·`loop`' '트랜잭션 경계|`rect` 또는 `Note`' '금지 문자|`;`와 `#`'; do
    l=${pair%%|*}; p=${pair#*|}
    row "$l" | grep -qF -- "$p" || echo "위반: $l 행에 '$p' 없음"
  done
  ```

  - 설계 주의: 라벨 목록을 `diff`로 전수 대조해 누락·추가·순서 변경을 모두 실패로 본다.
  </details>
- [ ] [D]  local·global 예시의 시퀀스 참여자(`participant <별칭> as <이름>`의 이름)가 같은 예시 트리 노드의 호출 주체(`#` 앞 부분)와 첫 등장 순서까지 일치한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  chk() {  # <파일> <절 시작 제목> <절 끝 제목> <흐름 시작 행>
    blk=$(awk -v a="$2" -v b="$3" '$0 == a { f = 1; next } $0 == b { exit } f' "$1" | awk -v h="$4" '$0 == h { f = 1; next } f')
    tree=$(printf '%s\n' "$blk" | awk '$0 == "```" { n++; next } n == 1' | sed -E 's/^[^A-Za-z]*//; s/#.*//' | awk 'NF && !seen[$0]++')
    part=$(printf '%s\n' "$blk" | awk '$0 == "```mermaid" { f = 1; next } f && $0 == "```" { exit } f' \
           | grep -E '^[[:space:]]*participant ' | sed -E 's/.* as //')
    { [ -n "$tree" ] && [ "$tree" = "$part" ]; } || echo "위반: $1 예시 참여자와 트리 호출 주체 불일치"
  }
  chk code-map/references/local.md '### 1단계: 소스코드 색인' '### 2단계: 교차 참조 연결' '## How'
  chk code-map/references/global.md '### 2단계: 아키텍처 문서 생성/갱신' '### 3단계: 건물 안내도 갱신' '## 사용자 로그인'
  ```

  - 설계 주의: 시퀀스 블록이 없으면 `part`가 비어 불일치로 실패하므로 구현 전에는 통과하지 않는다.
  </details>
- [ ] [D]  local·global 예시마다 `mermaid` 블록이 있고, 그 메시지 문구(첫 `:` 뒤)에 `;`와 `#`가 없다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in code-map/references/local.md code-map/references/global.md; do
    grep -qxF '```mermaid' "$f" || echo "위반: $f mermaid 블록 없음"
    awk '$0 == "```mermaid" { m = 1; next } m && $0 == "```" { m = 0 } m && /:/ { sub(/^[^:]*:/, ""); if ($0 ~ /[;#]/) print FILENAME ": " $0 }' "$f"
  done
  ```

  - 설계 주의: 블록이 없으면 금지 문자 검사가 공집합으로 통과하므로 블록 존재를 먼저 확인한다.
  </details>
- [ ] [QD] 작성 규칙 문안이 이슈 본문 B의 역할 분담(트리는 호출 구조, 시퀀스는 트리에 없는 정보)과 `## 전제`의 비동기 표기 정정을 빠짐없이 담는다  (검증: 교차모델 audit이 이슈 본문과 대조 채점)  ← 강등 사유: 규칙 서술이 이슈의 뜻을 담는지는 의미 대조라 명령으로 환원할 수 없다

### R4: 긴 흐름

- [ ] [D]  `긴 흐름` 라벨 행이 `핵심 경로만`과 생략 안내 리터럴 `` `생략한 호출은 위 트리에서 확인한다.` ``를 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  l=$(awk '$0 == "## 시퀀스 다이어그램 작성 규칙" { f = 1; next } f && /^## / { exit } f' code-map/SKILL.md | grep -E '^- \*\*긴 흐름\*\*:')
  printf '%s\n' "$l" | grep -qF '핵심 경로만' || echo '위반: 핵심 경로만'
  printf '%s\n' "$l" | grep -qF '`생략한 호출은 위 트리에서 확인한다.`' || echo '위반: 생략 안내 리터럴'
  ```

  </details>

### R5: 갱신 규칙

- [ ] [D]  `local.md` 1단계에 `- build·rebuild는`으로 시작하는 행이 1개 있고, 그 행이 함께 생성 문장과 sync 갱신·추가 문장을 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  l=$(awk '$0 == "### 1단계: 소스코드 색인" { f = 1; next } $0 == "### 2단계: 교차 참조 연결" { exit } f' code-map/references/local.md | grep -E '^- build·rebuild는')
  [ "$(printf '%s\n' "$l" | grep -c .)" -eq 1 ] || echo '위반: build·rebuild 행이 1행이 아님'
  printf '%s\n' "$l" | grep -qF -- '- build·rebuild는 상세 호출 흐름 문서마다 트리와 시퀀스 다이어그램을 함께 만든다.' || echo '위반: 함께 생성'
  printf '%s\n' "$l" | grep -qF 'sync는 소스가 바뀐 기능의 문서에서 둘을 함께 갱신하고, 시퀀스 다이어그램이 없는 기존 문서에는 이때 추가한다.' \
    || echo '위반: sync 갱신·추가'
  ```

  </details>

### R6: 점검과 결과 보고

- [ ] [D]  `local.md` 3단계 점검 표의 행이 정해진 7개(기존 5개 사이에 시퀀스 누락·트리·시퀀스 불일치)로만 있고, 두 새 행이 판정 기준과 목록 보고를 담으며, 4단계 결과 보고에 시퀀스 건수 행이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  L=code-map/references/local.md
  t=$(awk '$0 == "### 3단계: 정합성 점검" { f = 1; next } f && /^### / { exit } f' "$L" | grep -E '^\| [^|]+ \|')
  diff <(printf '%s\n' "$t" | sed -n '2,$p' | sed -E 's/^\| ([^|]+) \|.*/\1/') \
       <(printf '%s\n' 'stale 탐지' '엔트리포인트 유효성' '교차참조 유효성' '시퀀스 누락' '트리·시퀀스 불일치' 'Why 미태깅' '문서 누락') >/dev/null \
    || echo '위반: local 점검 표 행 집합·순서'
  r=$(printf '%s\n' "$t" | grep -E '^\| 시퀀스 누락 \|')
  for p in '`## How`에 `mermaid` 코드 블록이 없으면' '목록으로 보고한다'; do
    printf '%s\n' "$r" | grep -qF -- "$p" || echo "위반: 시퀀스 누락 행에 '$p' 없음"
  done
  r=$(printf '%s\n' "$t" | grep -E '^\| 트리·시퀀스 불일치 \|')
  for p in '호출 주체' '`생략한 호출은 위 트리에서 확인한다.`' '목록으로 보고한다'; do
    printf '%s\n' "$r" | grep -qF -- "$p" || echo "위반: 불일치 행에 '$p' 없음"
  done
  awk '$0 == "### 4단계: 결과 보고" { f = 1; next } f' "$L" | grep -qE '^[[:space:]]*- 시퀀스 다이어그램: N건 \(누락 N / 불일치 N\)$' \
    || echo '위반: local 4단계 시퀀스 보고 행'
  ```

  - 설계 주의: 표 첫 행(머리글)은 `sed -n '2,$p'`로 빼고 구분 행(`|------|`)은 `| ` 앵커에 걸리지 않는다.
  </details>
- [ ] [D]  `global.md` 4단계 점검 표의 행이 기존 4개 그대로이고 `아키텍처 문서 유효성` 행이 시퀀스 다이어그램과 흐름 섹션 단위 판정·집계를 담으며, 5단계 결과 보고에 서비스 간 시퀀스 건수 행이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  G=code-map/references/global.md
  t=$(awk '$0 == "### 4단계: 정합성 점검" { f = 1; next } f && /^### / { exit } f' "$G" | grep -E '^\| [^|]+ \|')
  diff <(printf '%s\n' "$t" | sed -n '2,$p' | sed -E 's/^\| ([^|]+) \|.*/\1/') \
       <(printf '%s\n' '리포 접근성' '안내도 불일치' '아키텍처 문서 유효성' '교차참조 유효성') >/dev/null \
    || echo '위반: global 점검 표 행 집합·순서'
  r=$(printf '%s\n' "$t" | grep -E '^\| 아키텍처 문서 유효성 \|')
  for p in '`service-call-flows.md`의 호출 흐름(트리와 시퀀스 다이어그램' '`## How` 대신 흐름 섹션마다 따로' '흐름 단위로 센다'; do
    printf '%s\n' "$r" | grep -qF -- "$p" || echo "위반: 아키텍처 문서 유효성 행에 '$p' 없음"
  done
  awk '$0 == "### 5단계: 결과 보고" { f = 1; next } f' "$G" | grep -qE '^[[:space:]]*- 서비스 간 시퀀스 다이어그램: N건 \(누락 N / 불일치 N\)$' \
    || echo '위반: global 5단계 시퀀스 보고 행'
  ```

  - 설계 주의: `service-call-flows.md`는 한 파일에 흐름 섹션이 여러 개이고 `## How`가 없다. local 기준을 그대로 옮기면 없는 `## How`를 찾거나, 파일 단위 판정에서 한 흐름의 블록이 다른 흐름의 누락을 가린다. 판정 대상(`## How` 대신 흐름 섹션)과 집계 단위(흐름)를 따로 검사한다.
  </details>
- [ ] [D]  `SKILL.md` 태그 체계 표의 태그가 기존 5개 그대로다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  diff <(awk '$0 == "## 태그 체계" { f = 1; next } f && /^## / { exit } f' code-map/SKILL.md | grep -oE '^\| `\[[A-Z-]+\]` \|' | grep -oE '\[[A-Z-]+\]') \
       <(printf '%s\n' '[WHY-NEEDED]' '[DOC-NEEDED]' '[UPDATE-NEEDED]' '[NOT-INDEXED]' '[REPO-NOT-FOUND]') >/dev/null \
    || echo '위반: 태그 체계 표 변경'
  ```

  </details>

### R7: SKILL.md 표기

- [ ] [D]  `SKILL.md` What/How/Why 표 How 행과 `.ai 디렉토리와의 관계` 트리의 `<action>-call-flow.md` 주석이 시퀀스 다이어그램을 담고, `## 디렉토리 트리 정렬 규칙`에 시퀀스 참여자 순서 적용 제외 문장과 작성 규칙 링크가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  K=code-map/SKILL.md
  grep -E '^\| \*\*How\*\* \|' "$K" | grep -qF '(호출 흐름 트리와 시퀀스 다이어그램, 의존성, 설정)' || echo '위반: How 행'
  awk '$0 == "### .ai 디렉토리와의 관계" { f = 1; next } f && /^#{2,3} / { exit } f' "$K" | grep -F '<action>-call-flow.md' \
    | grep -qF '# 엔트리포인트별 상세 호출 흐름 (트리 + 시퀀스 다이어그램)' || echo '위반: 트리 주석'
  s=$(awk '$0 == "## 디렉토리 트리 정렬 규칙" { f = 1; next } f && /^## / { exit } f' "$K")
  printf '%s\n' "$s" | grep -qF '시퀀스 다이어그램의 참여자 순서에도 이 규칙을 적용하지 않습니다' || echo '위반: 정렬 규칙 적용 제외'
  printf '%s\n' "$s" | grep -qF '[시퀀스 다이어그램 작성 규칙](#시퀀스-다이어그램-작성-규칙)' || echo '위반: 정렬 규칙 작성 규칙 링크'
  ```

  </details>

### R8: 구조 검사 테스트

- [ ] [D]  code-map 러너가 0 실패로 통과하고, 시퀀스 규칙 통과 케이스 1개와 SKILL.md·local·global 대상 격추 케이스가 각각 1개 이상 실행·통과한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(bash code-map/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 시퀀스 다이어그램 규칙 통과$')" -eq 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 시퀀스 SKILL\.md .* 격추$')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 시퀀스 local .* 격추$')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 시퀀스 global .* 격추$')" -ge 1 ] \
    || echo '위반: 러너 실패 또는 시퀀스 케이스 미실행'
  ```

  - 설계 주의: 러너만 실행하면 구현 전에도 통과하므로 새 케이스의 `ok` 행을 라벨별로 센다. Task별 하한은 plan 완료 기준이 정한다.
  </details>
- [ ] [QD] 격추 케이스가 R1~R7 `[D]` 앵커를 빠짐없이 덮는다  (검증: 교차모델 audit이 러너 케이스와 DoD 앵커 대조 채점)  ← 강등 사유: 케이스와 앵커의 대응은 의미 대조라 명령으로 환원하면 라벨 표기에 묶인다

### R9: 결정 기록과 원장

- [ ] [D]  ADR 0024 파일이 `active/`에 1개 있고 상태 줄이 `유효`이며 Mermaid·PlantUML·ASCII·`#126`을 담고, ADR index에 그 파일 행이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  A=$(ls .ai/50_adr/active/0024-*.md 2>/dev/null)
  [ "$(printf '%s\n' "$A" | grep -c .)" -eq 1 ] || echo '위반: ADR 0024 파일이 1개가 아님'
  [ -n "$A" ] && {
    grep -qxF -- '- **상태**: 유효' "$A" || echo '위반: 상태 줄'
    for w in Mermaid PlantUML ASCII '#126'; do grep -qF -- "$w" "$A" || echo "위반: ADR에 '$w' 없음"; done
    grep -qF "| \`active/$(basename "$A")\` |" .ai/50_adr/index.md || echo '위반: ADR index 행'
  }
  ```

  </details>
- [ ] [D]  K-0006이 `active/`에 상태 `수용`으로 남고, `## 재검토 이력` 표에 `#126`과 `계속 수용`을 담은 날짜 행이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  K6=.ai/70_ledger/active/K-0006-code-map-check-not-deterministic.md
  [ -r "$K6" ] || echo '위반: K-0006이 active에 없음'
  grep -qxF -- '- **상태**: 수용' "$K6" || echo '위반: K-0006 상태'
  awk '$0 == "## 재검토 이력" { f = 1; next } f && /^## / { exit } f' "$K6" | grep -E '^\| [0-9]{4}-[0-9]{2}-[0-9]{2} \|' \
    | grep -F '#126' | grep -qF '| 계속 수용 |' || echo '위반: K-0006 재검토 이력 행'
  ```

  </details>
- [ ] [QD] ADR 0024가 형식 선택, 트리·시퀀스 역할 분담, 기존 색인 반영 방식, 채택하지 않은 대안과 이유를 이슈 본문 범위 결정과 맞게 기록한다  (검증: 교차모델 audit이 이슈 본문과 대조 채점)  ← 강등 사유: 결정 서술의 정합은 의미 대조라 명령으로 환원할 수 없다

### R10: README·색인 정합

- [ ] [D]  summary Task 4 `수행 내용 요약`에 README와 `60_codebase/index.md` code-map 행의 갱신 판단이 기록된다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=.ai/90_issues/active/issue-0126/issue-0126-summary.md
  awk '/^### Task 4:/ { f = 1; next } f && /^### / { exit } f' "$S" | grep -E '^- \*\*수행 내용 요약\*\*:' \
    | grep -F 'README' | grep -qF '60_codebase/index.md' || echo '위반: Task 4 판단 기록'
  ```

  - 설계 주의: 기록 존재만 본다. 판단이 맞는지는 아래 `[QD]`가 맡는다.
  </details>
- [ ] [QD] 두 행의 갱신 판단이 변경 내용과 맞는다  (검증: 교차모델 audit이 두 행과 diff 대조 채점)  ← 강등 사유: 요약 문장이 변경을 담는지는 의미 판단이다

### 공통

- [ ] [D]  repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do bash "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D]  `.ai/` 아래 끊긴 원장 링크가 0건이다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 무출력·종료 코드 0이면 통과</summary>

  ```bash
  issue-work/scripts/check-ledger-links.sh .ai
  ```

  </details>
- [ ] [D]  제외 범위인 `code-map/references/doc.md`와 이 repo `.ai/60_codebase/`의 기존 상세 흐름 파일이 바뀌지 않는다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  b=$(git merge-base HEAD main)
  { git diff --name-only "$b" -- code-map/references/doc.md .ai/60_codebase/
    git status --porcelain --untracked-files=all -- code-map/references/doc.md .ai/60_codebase/ | cut -c4-; } \
    | grep -E '(^code-map/references/doc\.md|-call-flow\.md)$' | sort -u | sed 's/^/위반: 변경됨 /'
  ```

  - 설계 주의: 커밋된 변경(`git diff`)과 커밋 전 변경·새 파일(`git status`)을 함께 본다. `60_codebase/index.md`는 R10 대상이라 제외한다.
  </details>

---

## 전제 (Assumptions)

- **검증 셸**: spec·plan 검증 명령은 repo 루트에서 bash로 실행한다. 이 작업 환경의 AI 도구 셸은 zsh라 붙여 넣으면 단어 분리·`grep` 래퍼 차이로 판정이 달라질 수 있다. `testing-principles-local.md`는 템플릿 골격만 있어 테스트 층 표를 쓰지 않고 issue-work 템플릿대로 둔다.
- **공통 규칙 위치**(작성 AI 결정, 2026-10-31): 작성 규칙은 `SKILL.md` 끝의 `## 시퀀스 다이어그램 작성 규칙` 한 곳에 두고 `local.md`·`global.md`는 링크로 가리킨다. 두 모드가 같은 규칙을 쓰고, 두 모드에 걸친 `## 디렉토리 트리 정렬 규칙`도 SKILL.md에 있다. 두 참조 문서에 복제하는 안은 같은 스킬 안의 중복이라 버렸다.
- **문체**: SKILL.md 새 섹션과 정렬 규칙 추가 문장은 인접한 `## 디렉토리 트리 정렬 규칙`과 같은 합니다체, `local.md`·`global.md` 추가 문장은 한다체다.
- **작성 규칙 문안**: R3 DoD의 라벨 8개와 리터럴을 쓴다. 섹션 첫 문단은 적용 대상(두 문서)과 역할 분담(트리는 누가 누구를 호출하는지, 시퀀스는 트리에 없는 정보)을 적는다. 참여자 행은 "트리 노드의 호출 주체(`OrderService#createOrder`이면 `OrderService`. `--global`은 서비스)"와 "`participant`로 미리 선언", "처음 호출되는 순서"를 담는다.
- **비동기 표기 정정**(작성 AI 결정, 2026-10-31): 이슈 본문 B는 "이벤트 발행·메시지 전송은 `-)`"라 적었지만 Spring `ApplicationEventPublisher#publishEvent`는 기본 동작이 동기 호출이다. 규칙은 "호출한 쪽이 응답을 기다리지 않는 호출(메시지 브로커 전송, `@Async` 메서드 등)은 `-)`"로 쓰고, local 예시의 `publishEvent`는 `->>`로 그린다.
- **예시 내용**: local 예시는 기존 주문 생성 트리의 호출 주체 5개를 참여자로 두고 응답·`alt`·`rect`를 보인다. global 예시는 `gateway`·`auth-service`·`user-service`를 참여자로 두고 응답·`alt`를 보인다. 참여자 선언은 `participant <별칭> as <이름>` 형식이다(R3 DoD가 ` as ` 뒤를 이름으로 읽는다). `rect` 색은 밝은·어두운 테마 모두에서 보이도록 `rgba(128, 128, 128, 0.1)`을 쓴다.
- **생략 안내 리터럴**: 긴 흐름의 생략 안내는 `생략한 호출은 위 트리에서 확인한다.` 한 문장으로 고정한다. 트리·시퀀스 불일치 판정이 이 줄의 유무로 "생략"과 "누락"을 가른다.
- **local 점검 표 위치**: 새 두 행은 `교차참조 유효성` 다음, `Why 미태깅` 앞에 둔다.
- **러너 구조**: code-map 러너에 `sequence_violations <SKILL.md> <local.md> <global.md>` 함수를 새로 두고 통과 케이스 라벨은 `시퀀스 다이어그램 규칙 통과`다. 격추 케이스 라벨은 `시퀀스 SKILL.md `·`시퀀스 local `·`시퀀스 global ` 접두로 시작하고 `격추`로 끝난다. `assert_reject`가 합치는 위반 출력에 이 함수를 더한다. 머리 주석에 `(#126)` 줄을 더한다.
- **절 추출 방식**: 러너의 기존 `sec`는 ```` ``` ```` 행마다 코드 상태를 뒤집어 예시 안의 제목을 건너뛴다. 5백틱 예시 펜스 안에 3백틱 블록이 있으면 상태가 뒤집힌 채 진행해도 결과가 맞는 구조라, 새 검사는 `sec`에 기대지 않고 spec DoD처럼 시작·끝 제목을 고정해 절을 자른다(예: `### 1단계: 소스코드 색인`부터 `### 2단계: 교차 참조 연결` 앞까지).
- **결정 기록**: 새 ADR 번호는 0024이고 frontmatter는 0023과 같은 형식(`source: github_issue`, `source_url`)이다.
- **K-0006**: 이번 이슈에서 해소하지 않는다(사용자 결정, 2026-10-31). 재검토 이력 행만 더하고 상태·위치·재검토 조건은 그대로 둔다.
- **설치본 갱신 시점**: 홈 설치본(`~/.claude/skills/` 등)은 이 PR이 머지된 뒤 `/install-skills`로 재설치한다. 머지 전에는 이 repo의 `code-map/`를 기준으로 작업한다. 커밋은 사용자가 요청할 때만 한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| [K-0006](../../../70_ledger/active/K-0006-code-map-check-not-deterministic.md) | 점검 표 항목 추가로 재검토 조건에 해당한다. R9의 재검토 이력 행 추가 대상 |
| [ADR 0003](../../../50_adr/active/0003-verification-levels-and-determinization.md) | 검증 레벨과 결정화 판단. 시퀀스 누락 행을 결정화할 수 있는 판정으로 보는 근거 |
| [ADR 0001](../../../50_adr/active/0001-skill-deterministic-helper-test-convention.md) | `tests/` 배치와 러너 규칙 (R8) |
| [표기 규칙 정책](../../../40_domain/policies/local/notation-conventions.md) | 트리 정렬 규칙. 시퀀스 참여자 순서를 적용 제외로 두는 기준 (R7) |
| [코드맵 색인](../../../60_codebase/index.md) | code-map 행 (R10) |
