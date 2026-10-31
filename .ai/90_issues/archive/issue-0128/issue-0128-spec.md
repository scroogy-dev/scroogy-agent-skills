# Issue #128 스펙 git-pr·git-review-context: 호출 흐름 트리 다음에 Mermaid 시퀀스 다이어그램을 추가한다

## 목표 (Goal)

git-pr PR 본문과 git-review-context 결과의 호출 흐름이 트리 다음에 Mermaid 시퀀스 다이어그램을 함께 보여 주고, 그 작성 규칙이 code-map과 같은 문장으로 세 스킬에 유지된다.

---

## 요구사항 (Requirements)

**포함**

- R1: git-pr SKILL.md 테크 관점 `호출 흐름`이 작성 대상 기능마다 트리 코드 블록 바로 다음에 `mermaid` 블록을 두라고 안내하고, 작성 규칙과 기존 주문 생성 트리에 맞춘 시퀀스 예시를 담는다. `### 시퀀스 다이어그램` 소제목은 두지 않는다.
- R2: git-pr 템플릿(`templates/pr-body-template.md`) 예시의 트리를 코드 블록으로 감싸고, 그 바로 다음에 `mermaid` 블록을 잇는다.
- R3: git-review-context SKILL.md 5단계 `호출 흐름 분석`이 엔트리 포인트마다 트리 코드 블록 바로 다음에 `mermaid` 블록을 두라고 안내하고, 작성 규칙과 기존 주문 생성 트리에 맞춘 시퀀스 예시를 담는다. 소제목은 두지 않으며, "흐름이 복잡한 경우 의사코드 또는 단계별 목록 형태로 표현합니다" 행을 지운다.
- R4: git-review-context 템플릿(`templates/review-context-template.md`)의 `## 호출 흐름` 접기 안 주석이 시퀀스 다이어그램을 포함한다.
- R5: 두 스킬 본문이 code-map 상세 흐름 작성 기준(2단계 이상의 호출 계층, 외부 서비스 호출, 트랜잭션·이벤트·비동기 분기 중 하나)에 해당하는 기능에만 시퀀스를 그리고 나머지는 트리만 둔다고 적는다.
- R6: 두 스킬 작성 규칙의 참여자·응답·동기·비동기·분기·반복·트랜잭션 경계·금지 문자·긴 흐름 행은 code-map `## 시퀀스 다이어그램 작성 규칙`과 같은 문장이고, 위치·형식 행만 스킬별로 쓴다. code-map을 링크로 가리키지 않는다. 단, 참여자 행의 괄호 구절 "`--global`은 서비스"는 두 스킬 사본에서 뺀다 (이 구절 제외는 이슈 본문 근거 없음. 그대로 옮기면 두 스킬에 없는 `--global` 옵션 언급이 남는다. 2026-10-31 작성 AI 추론).
- R7: code-map 러너(`code-map/tests/run-tests.sh`)가 두 스킬 본문의 규칙 행을 `SEQ_ROWS`로 대조하고, 규칙 행을 되돌린 사본을 격추 케이스로 잡는다.
- R8: 새 ADR이 시퀀스 다이어그램을 두 스킬로 넓힌 결정과 규칙 사본 3곳(code-map·git-pr·git-review-context)을 같은 문장으로 유지하는 방식을 기록하고, ADR index에 행을 더한다. ADR 0024는 바꾸지 않는다.
- R9: 두 스킬 사본에 원본이 code-map이라는 사실과 "한쪽 변경 시 양쪽 동기화" 문구를 링크 없이 적는다 (이슈 본문 근거 없음. ADR 0002 결정의 동기화 주석 항목과 git-review·issue-audit 사본 관례에서 2026-10-31 작성 AI 추론).

**제외**

- git-review 리뷰 포인트 접기 안의 `호출 흐름 추적`: 불필요. 지적 하나의 근거라 짧고 형식 규정이 없다.
- issue-audit·git-review-quiz: 불필요. `.ai/60_codebase/` 색인을 읽기만 한다.
- code-map 작성 규칙 자체 변경: 불필요. 이번 이슈는 기존 규칙을 옮기기만 한다.
- git-review-context `tests/` 신설: 대체. code-map 러너가 `SEQ_ROWS` 하나로 세 사본을 대조한다.
- README·AI-CONTEXT 설명 갱신: 대체. git-pr 문서 동기화 점검에서 갱신 여부를 정한다.

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> 검증 명령은 모두 repo 루트에서 bash로 실행한다. 구간은 git-pr이 `* **호출 흐름:**` 행부터 `* **참고사항:**`으로 시작하는 행 전까지, git-review-context가 `### 5단계: 호출 흐름 분석`부터 `### 6단계`로 시작하는 행 전까지다.

### R1: git-pr SKILL.md 안내·예시

- [ ] [D] `호출 흐름` 구간에 시퀀스 안내 문장이 한 행 있고, 그 행이 트리 코드 블록 바로 다음 배치·해당하지 않는 기능은 트리만 둔다는 점·작성 규칙 섹션 링크를 함께 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-pr/SKILL.md
  n="$(awk -v a='* **호출 흐름:**' -v b='* **참고사항:**' '$0 == a { f = 1; next } f && index($0, b) == 1 { exit } f' "$F" \
    | grep -F '트리 코드 블록 바로 다음' | grep -F '트리만' \
    | grep -cF '[시퀀스 다이어그램 작성 규칙](#시퀀스-다이어그램-작성-규칙)')"
  [ "$n" -eq 1 ] || echo "위반: 안내 문장 $n행"
  ```

  </details>
- [ ] [D] 작성 규칙 섹션의 위치·형식 행이 하나이고, `호출 흐름`의 트리 코드 블록 바로 다음 `mermaid` 블록과 소제목 없음을 적는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-pr/SKILL.md
  line="$(awk '$0 == "## 시퀀스 다이어그램 작성 규칙" { f = 1; next } f && /^## / { exit } f' "$F" | grep -E '^- \*\*위치·형식\*\*:')"
  [ "$(printf '%s\n' "$line" | grep -c .)" -eq 1 ] || echo '위반: 위치·형식 행 수'
  for p in '`호출 흐름`' '트리 코드 블록 바로 다음' '`sequenceDiagram`' '`mermaid` 코드 블록' '소제목은 두지 않'; do
    printf '%s\n' "$line" | grep -qF -- "$p" || echo "위반: 위치·형식 행 $p"
  done
  ```

  </details>
- [ ] [D] 예시가 트리 코드 블록 다음에 빈 행 말고는 다른 행 없이 첫 행이 `sequenceDiagram`인 `mermaid` 블록을 잇고, 시퀀스 소제목 행은 없다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-pr/SKILL.md
  blk="$(awk -v a='* **호출 흐름:**' -v b='* **참고사항:**' '$0 == a { f = 1; next } f && index($0, b) == 1 { exit } f' "$F" | sed -E 's/^[[:space:]]+//')"
  printf '%s\n' "$blk" | awk '
    st == 0 && $0 == "```" { st = 1; next }
    st == 1 && $0 == "```" { st = 2; next }
    st == 2 && $0 == "" { next }
    st == 2 { st = ($0 == "```mermaid") ? 3 : -1; next }
    st == 3 { st = ($0 == "sequenceDiagram") ? 4 : -1; next }
    st == 4 && $0 == "```" { st = 5; next }
    END { exit st != 5 }' || echo '위반: 예시 트리·mermaid 순서'
  printf '%s\n' "$blk" | grep -E '^#+ 시퀀스 다이어그램' | sed 's/^/위반: 소제목 /'
  ```

  - 설계 주의: 구간의 첫 3백틱 블록을 트리로 본다. 구간 안 안내 문장의 인라인 코드는 한 행 전체가 펜스가 아니라 상태를 바꾸지 않는다.
  </details>
- [ ] [D] 예시 시퀀스의 참여자가 트리 노드의 호출 주체와 같고 첫 등장 순서도 같다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-pr/SKILL.md
  blk="$(awk -v a='* **호출 흐름:**' -v b='* **참고사항:**' '$0 == a { f = 1; next } f && index($0, b) == 1 { exit } f' "$F" | sed -E 's/^[[:space:]]+//')"
  tree="$(printf '%s\n' "$blk" | awk '$0 == "```" { n++; next } n == 1' | sed -E 's/^[^A-Za-z]*//; s/[#[:space:]].*//' | awk 'NF && !seen[$0]++')"
  part="$(printf '%s\n' "$blk" | awk '$0 == "```mermaid" { m = 1; next } m && $0 == "```" { exit } m' | grep -E '^participant ' | sed -E 's/.* as //')"
  [ -n "$tree" ] && [ "$tree" = "$part" ] || echo '위반: 예시 참여자'
  ```

  </details>
- [ ] [D] 예시 시퀀스에 메시지 행이 있고, 메시지 문구에 `;`·`#`가 든 행은 0건이다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-pr/SKILL.md
  blk="$(awk -v a='* **호출 흐름:**' -v b='* **참고사항:**' '$0 == a { f = 1; next } f && index($0, b) == 1 { exit } f' "$F" | sed -E 's/^[[:space:]]+//')"
  msg="$(printf '%s\n' "$blk" | awk '$0 == "```mermaid" { m = 1; next } m && $0 == "```" { m = 0 } m && /:/ { sub(/^[^:]*:/, ""); print }')"
  [ -n "$msg" ] || echo '위반: 메시지 행 없음'
  printf '%s\n' "$msg" | grep -E '[;#]' | sed 's/^/위반: 금지 문자 /'
  ```

  </details>
- [ ] [QD] 예시 시퀀스가 트리의 호출 순서와 노드 주석(검증, 트랜잭션, 재고 차감, 결제 실패 시 롤백)을 어긋남 없이 담는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 트리 주석과 시퀀스 표기의 의미 대조는 해석이 필요하다

### R2: git-pr 템플릿

- [ ] [D] 템플릿 `호출 흐름` 구간에서 트리가 코드 블록으로 감싸지고, 빈 행 말고는 다른 행 없이 첫 행이 `sequenceDiagram`인 `mermaid` 블록이 이어진다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-pr/templates/pr-body-template.md
  blk="$(awk -v a='* **호출 흐름:**' -v b='* **참고사항:**' '$0 == a { f = 1; next } f && index($0, b) == 1 { exit } f' "$F" | sed -E 's/^[[:space:]]+//')"
  printf '%s\n' "$blk" | awk '
    st == 0 && $0 == "```" { st = 1; next }
    st == 1 && $0 == "```" { st = 2; next }
    st == 2 && $0 == "" { next }
    st == 2 { st = ($0 == "```mermaid") ? 3 : -1; next }
    st == 3 { st = ($0 == "sequenceDiagram") ? 4 : -1; next }
    st == 4 && $0 == "```" { st = 5; next }
    END { exit st != 5 }' || echo '위반: 템플릿 트리·mermaid 순서'
  printf '%s\n' "$blk" | grep -E '^#+ 시퀀스 다이어그램' | sed 's/^/위반: 소제목 /'
  ```

  </details>
- [ ] [D] 템플릿 시퀀스의 참여자가 트리 노드의 호출 주체와 같고 첫 등장 순서도 같다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-pr/templates/pr-body-template.md
  blk="$(awk -v a='* **호출 흐름:**' -v b='* **참고사항:**' '$0 == a { f = 1; next } f && index($0, b) == 1 { exit } f' "$F" | sed -E 's/^[[:space:]]+//')"
  tree="$(printf '%s\n' "$blk" | awk '$0 == "```" { n++; next } n == 1' | sed -E 's/^[^A-Za-z]*//; s/[#[:space:]].*//' | awk 'NF && !seen[$0]++')"
  part="$(printf '%s\n' "$blk" | awk '$0 == "```mermaid" { m = 1; next } m && $0 == "```" { exit } m' | grep -E '^participant ' | sed -E 's/.* as //')"
  [ -n "$tree" ] && [ "$tree" = "$part" ] || echo '위반: 템플릿 참여자'
  ```

  </details>
- [ ] [D] 템플릿 시퀀스에 메시지 행이 있고, 메시지 문구에 `;`·`#`가 든 행은 0건이다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-pr/templates/pr-body-template.md
  blk="$(awk -v a='* **호출 흐름:**' -v b='* **참고사항:**' '$0 == a { f = 1; next } f && index($0, b) == 1 { exit } f' "$F" | sed -E 's/^[[:space:]]+//')"
  msg="$(printf '%s\n' "$blk" | awk '$0 == "```mermaid" { m = 1; next } m && $0 == "```" { m = 0 } m && /:/ { sub(/^[^:]*:/, ""); print }')"
  [ -n "$msg" ] || echo '위반: 메시지 행 없음'
  printf '%s\n' "$msg" | grep -E '[;#]' | sed 's/^/위반: 금지 문자 /'
  ```

  </details>
- [ ] [QD] 템플릿 시퀀스가 트리의 호출 순서와 노드 주석(병렬 검증, 캐시 우선 조회, 캐시 miss 시 DB 조회)을 어긋남 없이 담는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 트리 주석과 시퀀스 표기의 의미 대조는 해석이 필요하다
- [ ] [ND] 리스트와 접기 안에 둔 템플릿 예시의 `mermaid` 블록이 GitHub에서 그림으로 표시된다  (검증: 사용자가 GitHub 댓글 작성 창 Preview에서 확인하고 결과를 summary에 기록)  ← 강등 사유: 그림 표시 여부는 화면으로 확인해야 한다

### R3: git-review-context SKILL.md 안내·예시

- [ ] [D] 5단계 구간에 시퀀스 안내 문장이 한 행 있고, 그 행이 트리 코드 블록 바로 다음 배치·해당하지 않는 엔트리 포인트는 트리만 둔다는 점·작성 규칙 섹션 링크를 함께 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-review-context/SKILL.md
  n="$(awk -v a='### 5단계: 호출 흐름 분석' -v b='### 6단계' '$0 == a { f = 1; next } f && index($0, b) == 1 { exit } f' "$F" \
    | grep -F '트리 코드 블록 바로 다음' | grep -F '트리만' \
    | grep -cF '[시퀀스 다이어그램 작성 규칙](#시퀀스-다이어그램-작성-규칙)')"
  [ "$n" -eq 1 ] || echo "위반: 안내 문장 $n행"
  ```

  </details>
- [ ] [D] 작성 규칙 섹션의 위치·형식 행이 하나이고, `## 호출 흐름` 접기 안의 트리 코드 블록 바로 다음 `mermaid` 블록과 소제목 없음을 적는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-review-context/SKILL.md
  line="$(awk '$0 == "## 시퀀스 다이어그램 작성 규칙" { f = 1; next } f && /^## / { exit } f' "$F" | grep -E '^- \*\*위치·형식\*\*:')"
  [ "$(printf '%s\n' "$line" | grep -c .)" -eq 1 ] || echo '위반: 위치·형식 행 수'
  for p in '`## 호출 흐름` 접기 안' '트리 코드 블록 바로 다음' '`sequenceDiagram`' '`mermaid` 코드 블록' '소제목은 두지 않'; do
    printf '%s\n' "$line" | grep -qF -- "$p" || echo "위반: 위치·형식 행 $p"
  done
  ```

  </details>
- [ ] [D] 예시가 트리 코드 블록 다음에 빈 행 말고는 다른 행 없이 첫 행이 `sequenceDiagram`인 `mermaid` 블록을 잇고, 시퀀스 소제목 행은 없다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-review-context/SKILL.md
  blk="$(awk -v a='### 5단계: 호출 흐름 분석' -v b='### 6단계' '$0 == a { f = 1; next } f && index($0, b) == 1 { exit } f' "$F" | sed -E 's/^[[:space:]]+//')"
  printf '%s\n' "$blk" | awk '
    st == 0 && $0 == "```" { st = 1; next }
    st == 1 && $0 == "```" { st = 2; next }
    st == 2 && $0 == "" { next }
    st == 2 { st = ($0 == "```mermaid") ? 3 : -1; next }
    st == 3 { st = ($0 == "sequenceDiagram") ? 4 : -1; next }
    st == 4 && $0 == "```" { st = 5; next }
    END { exit st != 5 }' || echo '위반: 예시 트리·mermaid 순서'
  printf '%s\n' "$blk" | grep -E '^#+ 시퀀스 다이어그램' | sed 's/^/위반: 소제목 /'
  ```

  </details>
- [ ] [D] 예시 시퀀스의 참여자가 트리 노드의 호출 주체와 같고 첫 등장 순서도 같다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-review-context/SKILL.md
  blk="$(awk -v a='### 5단계: 호출 흐름 분석' -v b='### 6단계' '$0 == a { f = 1; next } f && index($0, b) == 1 { exit } f' "$F" | sed -E 's/^[[:space:]]+//')"
  tree="$(printf '%s\n' "$blk" | awk '$0 == "```" { n++; next } n == 1' | sed -E 's/^[^A-Za-z]*//; s/[#[:space:]].*//' | awk 'NF && !seen[$0]++')"
  part="$(printf '%s\n' "$blk" | awk '$0 == "```mermaid" { m = 1; next } m && $0 == "```" { exit } m' | grep -E '^participant ' | sed -E 's/.* as //')"
  [ -n "$tree" ] && [ "$tree" = "$part" ] || echo '위반: 예시 참여자'
  ```

  </details>
- [ ] [D] 예시 시퀀스에 메시지 행이 있고, 메시지 문구에 `;`·`#`가 든 행은 0건이다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-review-context/SKILL.md
  blk="$(awk -v a='### 5단계: 호출 흐름 분석' -v b='### 6단계' '$0 == a { f = 1; next } f && index($0, b) == 1 { exit } f' "$F" | sed -E 's/^[[:space:]]+//')"
  msg="$(printf '%s\n' "$blk" | awk '$0 == "```mermaid" { m = 1; next } m && $0 == "```" { m = 0 } m && /:/ { sub(/^[^:]*:/, ""); print }')"
  [ -n "$msg" ] || echo '위반: 메시지 행 없음'
  printf '%s\n' "$msg" | grep -E '[;#]' | sed 's/^/위반: 금지 문자 /'
  ```

  </details>
- [ ] [D] "의사코드 또는 단계별 목록" 행이 SKILL.md에 남지 않는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -nF '의사코드 또는 단계별 목록' git-review-context/SKILL.md | sed 's/^/위반: /'
  ```

  </details>
- [ ] [QD] 예시 시퀀스가 트리의 호출 순서와 노드 주석(트랜잭션, 재고 차감, 결제 실패 시 롤백, 이벤트 발행)을 어긋남 없이 담는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 트리 주석과 시퀀스 표기의 의미 대조는 해석이 필요하다

### R4: git-review-context 템플릿

- [ ] [D] `## 호출 흐름` 접기 안에 트리와 시퀀스 다이어그램을 함께 적으라는 주석이 한 행 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=git-review-context/templates/review-context-template.md
  n="$(awk '$0 == "## 호출 흐름" { f = 1; next } f && /^## / { exit } f && /<details>/ { d = 1 } f && d' "$F" \
    | grep -cE '^<!-- .*트리.*시퀀스 다이어그램.* -->$')"
  [ "$n" -eq 1 ] || echo "위반: 접기 안 주석 $n행"
  ```

  </details>

### R5: 작성 대상 기준

- [ ] [D] 두 스킬 구간에 code-map 상세 흐름 작성 기준 3행이 같은 문장·같은 순서로 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  crit="$(awk '$0 == "- 상세 호출 흐름은 다음 기준에 해당하면 작성한다:" { f = 1; next } f && /^- / { exit } f' code-map/references/local.md | sed -E 's/^[[:space:]]+//')"
  [ "$(printf '%s\n' "$crit" | grep -c .)" -eq 3 ] || echo '위반: code-map 기준 3행 추출 실패'
  for spec in 'git-pr/SKILL.md|* **호출 흐름:**|* **참고사항:**' 'git-review-context/SKILL.md|### 5단계: 호출 흐름 분석|### 6단계'; do
    F=${spec%%|*}; r=${spec#*|}; a=${r%%|*}; b=${r#*|}
    got="$(awk -v a="$a" -v b="$b" '$0 == a { f = 1; next } f && index($0, b) == 1 { exit } f' "$F" | sed -E 's/^[[:space:]]+//' | grep -xF -- "$crit")"
    [ "$got" = "$crit" ] || echo "위반: $F 작성 대상 기준"
  done
  ```

  - 설계 주의: 기준 원문은 code-map `references/local.md` 1단계에서 읽어, code-map 쪽 문장이 바뀌면 이 검사가 사본 불일치로 실패한다. 추출이 0행이면 빈 문자열끼리 같아지므로 3행 추출을 먼저 확인한다.
  </details>

### R6: 규칙 행 같은 문장

- [ ] [D] 두 사본의 위치·형식 외 규칙 행 7개가 code-map 행(참여자 행의 `--global` 구절을 뺀 문장)과 행 단위로 같고, 사본 규칙 행에 `--global`은 0건이다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  rows() { awk '$0 == "## 시퀀스 다이어그램 작성 규칙" { f = 1; next } f && /^## / { exit } f' "$1" | grep -E '^- \*\*[^*]+\*\*:' | grep -vE '^- \*\*위치·형식\*\*:'; }
  all="$(rows code-map/SKILL.md)"
  want="$(printf '%s\n' "$all" | sed 's/\. `--global`은 서비스//')"
  [ "$(printf '%s\n' "$all" | grep -c .)" -eq 7 ] && [ "$want" != "$all" ] || echo '위반: code-map 규칙 행 추출 또는 --global 구절 제거 실패'
  for F in git-pr/SKILL.md git-review-context/SKILL.md; do
    [ "$(rows "$F")" = "$want" ] || echo "위반: $F 규칙 행이 code-map과 다름"
    rows "$F" | grep -F -- '--global' | sed "s|^|위반: $F --global 구절 |"
  done
  ```

  - 설계 주의: code-map 문장에서 구절 제거가 실제로 일어났는지(`want != all`)를 함께 본다. code-map 표기가 바뀌어 제거가 헛돌면 사본이 `--global` 구절을 그대로 가져도 통과하기 때문이다.
  </details>
- [ ] [D] 두 스킬 SKILL.md에 code-map을 가리키는 마크다운 링크가 없다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -nE '\]\([^)]*code-map' git-pr/SKILL.md git-review-context/SKILL.md | sed 's/^/위반: /'
  ```

  </details>

### R7: code-map 러너 사본 대조

- [ ] [D] code-map 러너가 0 실패로 통과하고, 사본 대조 통과 1건과 두 사본 격추 28건 이상을 실행한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  R=code-map/tests/run-tests.sh
  out=$("$R" 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 시퀀스 규칙 사본 통과$')" -eq 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 시퀀스 규칙 사본 (git-pr|git-review-context) .* 격추$')" -ge 28 ] \
    || echo '위반: 러너 실패 또는 사본 케이스(통과 1·격추 28 이상) 미실행'
  ```

  - 설계 주의: 러너 통과만 보면 사본 검사를 넣기 전에도 통과한다. 사본 통과 행과 격추 행을 따로 센다. 격추 하한 28은 사본마다 섹션 제목 1·라벨 1·`SEQ_ROWS` 리터럴 10(전체 12에서 code-map 전용 2개 제외)·긴 흐름 2다.
  </details>

### R8: ADR

- [ ] [D] ADR 0025가 `active/`에 하나 있고, 상태가 유효이며, 결정 섹션이 두 스킬·`SEQ_ROWS`·`--global` 구절 제외·동기화 문구·ADR 0024를 다루고, index의 0024 행과 `superseded/` 행 사이에 행이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  A="$(ls .ai/50_adr/active/0025-*.md 2>/dev/null)"
  [ "$(printf '%s\n' "$A" | grep -c .)" -eq 1 ] || { echo '위반: ADR 0025 파일이 1개가 아님'; A=/dev/null; }
  grep -qxF -- '- **상태**: 유효' "$A" || echo '위반: 상태 줄'
  d="$(awk '$0 == "## 결정" { f = 1; next } f && /^## / { exit } f' "$A")"
  for p in 'git-pr' 'git-review-context' '`SEQ_ROWS`' '`--global`' '한쪽 변경 시 양쪽 동기화' 'ADR 0024'; do
    printf '%s\n' "$d" | grep -qF -- "$p" || echo "위반: 결정 섹션 $p"
  done
  I=.ai/50_adr/index.md
  r="$(grep -nF "| \`active/$(basename "$A")\` |" "$I" | cut -d: -f1)"
  p="$(grep -nF '| `active/0024-' "$I" | cut -d: -f1)"
  s="$(grep -nE '^\| `superseded/` \|' "$I" | cut -d: -f1)"
  [ -n "$r" ] && [ "$r" -gt "$p" ] && [ "$r" -lt "$s" ] || echo '위반: index 행 위치'
  ```

  - 설계 주의: `superseded/` 행은 행 시작에 고정해 찾는다. `## 수명 주기` 표의 `| \`superseded/\` |` 칸도 같은 문자열을 담아, 고정하지 않으면 2행이 잡혀 비교가 오류로 끝난다 (2026-10-31 Task 5 구현 중 보정).
  </details>
- [ ] [D] ADR 0024 파일은 바뀌지 않는다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  B="$(git merge-base main HEAD)"
  git diff --quiet "$B" -- .ai/50_adr/active/0024-code-map-sequence-diagram-alongside-call-flow-tree.md || echo '위반: ADR 0024 변경'
  ```

  </details>
- [ ] [QD] ADR 0025 결정 섹션이 R1~R7·R9의 결정을 빠짐없이 담고 ADR 0024 결정과 어긋나지 않는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 결정 문장이 요구사항을 빠짐없이 덮는지는 의미 대조라 명령으로 환원할 수 없다

### R9: 동기화 문구

- [ ] [D] 두 사본 규칙 섹션의 첫 규칙 행 앞 도입 문단에 `code-map`과 "한쪽 변경 시 양쪽 동기화"가 같은 행에 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for F in git-pr/SKILL.md git-review-context/SKILL.md; do
    awk '$0 == "## 시퀀스 다이어그램 작성 규칙" { f = 1; next } f && /^- \*\*/ { exit } f' "$F" \
      | grep -F '`code-map`' | grep -qF '한쪽 변경 시 양쪽 동기화' || echo "위반: $F 동기화 문구"
  done
  ```

  </details>

### 공통

- [ ] [D] repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  - 실행 주의: 전체 실행이 2분을 넘을 수 있다. 도구 시간 제한이 짧으면 백그라운드로 실행한다.
  </details>
- [ ] [D] 제외 대상(code-map SKILL.md·references, git-review, issue-audit, git-review-quiz)은 바뀌지 않고 git-review-context `tests/`는 생기지 않는다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  B="$(git merge-base main HEAD)"
  git diff --name-only "$B" -- code-map/SKILL.md code-map/references git-review issue-audit git-review-quiz | sed 's/^/위반: 변경됨 /'
  [ ! -e git-review-context/tests ] || echo '위반: git-review-context/tests 생김'
  ```

  - 설계 주의: README·AI-CONTEXT는 git-pr 문서 동기화 점검이 같은 PR에서 갱신할 수 있어 무변경 대상에 넣지 않는다.
  </details>

---

## 전제 (Assumptions)

- **규칙 섹션 위치·제목**: 두 SKILL.md에 code-map과 같은 제목의 `## 시퀀스 다이어그램 작성 규칙` 섹션을 둔다. git-pr은 `## PR 메시지 구조`와 `## 작성 예시 (템플릿)` 사이, git-review-context는 `## 분석 절차`와 `## 산출물 접기 기준` 사이다. 제목이 같아야 러너가 code-map과 같은 추출로 세 사본을 본다.
- **작성 대상 기준 원문**: 이슈 본문의 "code-map 상세 흐름 작성 기준"은 `code-map/references/local.md` 1단계의 "상세 호출 흐름은 다음 기준에 해당하면 작성한다:" 아래 3행이다. 이 3행을 안내 문장 아래 하위 목록으로 같은 문장 그대로 옮긴다.
- **규칙 섹션 도입 문단**: 적용 대상(스킬별), 트리와 시퀀스의 역할 분담, 원본·동기화 문구(R9)를 적는다. 동기화 문구는 git-review·issue-audit 사본 관례인 "(스킬 단독 실행을 위해 복사해 두었으므로 한쪽 변경 시 양쪽 동기화)"를 따른다. 도입 문단에는 `SEQ_ROWS` 리터럴(`호출 주체`, `sequenceDiagram` 등)을 쓰지 않는다. 사본 격추가 섹션 제목 뒤 첫 등장을 지우기 때문이다.
- **git-pr 예시 구조**: 기능 이름 줄(`- 주문 생성:`)은 코드 블록 밖 리스트 항목으로 두고, 그 아래에 트리 코드 블록과 `mermaid` 블록을 들여 쓴다. SKILL.md 예시와 템플릿이 같은 구조를 쓴다. 기존 SKILL.md 예시는 기능 이름 줄이 코드 블록 안에 있었다. 이슈 본문의 "기능 이름 줄이 구분을 맡는다"에 맞추려고 바꾼다 (2026-10-31 계획 작성 AI 결정).
- **git-review-context 예시**: 기존 트리 코드 블록 바로 다음에 `mermaid` 블록을 잇는다. `OrderEventPublisher#publish`는 트리에 비동기 표시가 없어 `->>`로 그린다 (ADR 0024 근거의 비동기 표기 정정과 같은 기준).
- **사본 대조 제외 리터럴**: `SEQ_ROWS` 가운데 위치·형식 행의 `### 시퀀스 다이어그램` 리터럴과 참여자 행의 `--global` 구절 리터럴, 두 개는 code-map 전용이라 사본 대조에서 뺀다 (R6 단서, 2026-10-31 사용자 확정).
- **사본 격추 helper**: 사본 파일은 규칙 섹션 앞 예시에 같은 리터럴(메시지 화살표 등)이 나올 수 있다. 그래서 사본 격추는 `## 시퀀스 다이어그램 작성 규칙` 행 뒤의 첫 등장만 바꾸는 helper를 새로 둔다. code-map 격추에 쓰는 `cut_str`(파일 전체 첫 등장)은 그대로 둔다.
- **구현 테스트 배치**: Task 1·2·3은 각자 바꾼 구조(안내 문장, 작성 대상 기준, 위치·형식 행, 예시, 템플릿, 동기화 문구, 의사코드 행 삭제)의 검사와 격추 케이스를 code-map 러너에 더한다 (ADR 0019 Task별 테스트 배치). 이슈 본문이 git-review-context `tests/` 신설을 제외해 그쪽 검사를 둘 수 있는 러너가 code-map 러너뿐이므로, 두 스킬의 시퀀스 검사를 이 러너 하나에 모은다. 이슈 본문 "테스트와 정합"이 적은 범위(`SEQ_ROWS` 대조) 밖이며, 2026-10-31 계획 감사 F-1 검토에서 사용자가 확정했다. 케이스 설명은 `시퀀스 배치 <대상>`으로 시작해 R7 `[D]`의 `시퀀스 규칙 사본` 집계와 섞이지 않게 한다.
- **버린 대안**: 러너가 규칙 행 전체 문장을 code-map과 대조하는 안. 이슈 본문 범위 결정이 "`SEQ_ROWS` 하나로 대조"라 러너는 라벨·리터럴만 본다. 같은 문장인지는 R6 `[D]`로 이슈 완료 시점에 확인한다.
- **그림 표시 확인 방법**: 사용자가 GitHub 댓글 작성 창의 Preview 탭에 템플릿의 `### Issue: #123` 블록을 붙여 확인한다. 댓글은 게시하지 않는다.
- **ADR 번호**: 0025다. `active/`의 최대 번호가 0024이고 `superseded/`는 비어 있다.
- **README·AI-CONTEXT**: 구현 Task에서는 고치지 않는다. git-pr 문서 동기화 점검에서 판정한다 (제외 목록).

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| [`.ai/50_adr/active/0024-code-map-sequence-diagram-alongside-call-flow-tree.md`](../../../50_adr/active/0024-code-map-sequence-diagram-alongside-call-flow-tree.md) | code-map 시퀀스 다이어그램 결정. 이번에 넓히는 대상이며 바꾸지 않는다 |
| [`.ai/50_adr/active/0002-skill-independence-intentional-duplication.md`](../../../50_adr/active/0002-skill-independence-intentional-duplication.md) | 공통 규칙의 스킬별 복제, 링크 대체 불가, 사본의 동기화 문구 |
| [`.ai/50_adr/active/0010-output-format-templates-separation.md`](../../../50_adr/active/0010-output-format-templates-separation.md) | SKILL.md 절차 예시와 `templates/` 산출물 형식의 역할 분담 |
| [`.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md`](../../../50_adr/active/0001-skill-deterministic-helper-test-convention.md) | 테스트 위치·러너 규칙 (code-map 러너 확장) |
| [`.ai/50_adr/active/0019-test-perspectives-and-task-level-placement.md`](../../../50_adr/active/0019-test-perspectives-and-task-level-placement.md) | spec 인수 검증과 Task별 구현 테스트 배치 (Task 1~3 러너 케이스) |
| [`.ai/50_adr/active/0003-verification-levels-and-determinization.md`](../../../50_adr/active/0003-verification-levels-and-determinization.md) | 검증 레벨과 완료 기준 형식 |
| [`.ai/40_domain/specs/git-pr-submission.md`](../../../40_domain/specs/git-pr-submission.md) | git-pr 문서 동기화 점검 표 (README·AI-CONTEXT 갱신 판정) |
