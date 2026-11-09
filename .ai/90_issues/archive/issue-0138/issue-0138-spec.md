# Issue #138 스펙 ai-workspace: update가 프로젝트 규칙 표에 넣는 행을 알파벳순 자리에 두고 어긋난 표는 정렬을 권유한다

## 목표 (Goal)

ai-workspace update가 `## 프로젝트 규칙` 표에 넣는 행이 템플릿과 같은 알파벳순 자리에 들어가고, 순서가 어긋난 기존 표는 정렬 권유를 받는다.

---

## 요구사항 (Requirements)

**포함**

- R1: update-4가 `## 프로젝트 규칙` 표에 표준 행을 넣는 모든 조치(표준 행 검사 4종, SSoT 선언 보강, 건물 repo 선언 전환, 2열 표 열 확장, 섹션·표 복구 뒤 dev 전용 행 보강)는 `파일` 셀 경로(백틱·양끝 공백 제외)의 대소문자 무시 알파벳순 자리에 행을 넣는다. 자리는 그 경로보다 뒤에 오는 첫 행 바로 앞이고, 그런 행이 없으면 표 끝이다.
- R2: 구버전 구조 마이그레이션(`ai-workspace/references/legacy-migration.md`)의 누락 행 추가도 R1과 같은 자리 규칙을 따른다.
- R3: `check-context.sh`는 `## 프로젝트 규칙` 첫 표의 행이 R1의 알파벳순이 아니면 1행으로 보고하고 종료 코드 1을 낸다. 검사는 3열 표이거나 헤더가 `파일`·`설명`인 2열 표일 때만 하며, 섹션·표가 없거나 헤더 이름이 다른 표에는 보고하지 않는다.
- R4: SKILL.md 멱등 보강 검사 표에 순서 항목이 있고(항목 15개, 헬퍼 판정 13개), 조치는 정렬 여부를 묻고 승인한 경우에만 행 단위로 재정렬해 사용자 행과 확장 열을 보존한다.
- R5: update-4 fixture 기대 파일 5개(`missing-rows`·`missing-rows-doc`·`legacy-two-col`·`no-rules-section-mismatch`·`no-rules-table-mismatch`)와 fixture README가 알파벳순 자리 삽입 결과를 기대하고, `ai-workspace/tests/run-tests.sh`가 순서 검사의 통과·격추 케이스와 검사 표 행 수를 검사해 모두 통과한다.
- R6: `.ai/40_domain/specs/ai-workspace.md`의 멱등 보강 검사 설명을 새 동작(알파벳순 자리 보강, 순서 검사와 정렬 권유, 헬퍼 13종)에 맞춘다. (이슈 본문 근거 없음. 2026-11-09 spec 작성 중 #134·#136 R10 선례로 추가, 같은 날 승인)
- R7: ADR 0028(`## 프로젝트 규칙`은 표준 행만 보강)과 ADR 0029(누락 행을 표 끝에 넣음)의 결정 문장을 새 동작에 맞춰 고치고, 근거에 변경 날짜·이슈 번호·경위를 적는다. ADR 수명 주기의 "결정 항목 일부 변경"에 해당한다. (이슈 본문 근거 없음. 2026-11-09 spec 작성 중 두 ADR 결정 문장이 새 동작과 어긋남을 확인해 추가, 같은 날 승인)

**제외**

- `## 프로젝트 도메인` 표의 `profile`·`ssot_dir` 행 삽입 위치: 불필요(알파벳순 표가 아니고, 키 순서는 템플릿 고유 순서를 따른다)
- 행 삽입의 스크립트 이관: 대체(삽입은 지금처럼 AI가 SKILL.md 문구대로 하고, 결과는 헬퍼의 순서 검사로 확인한다)
- 묻지 않는 자동 재정렬: 불필요(사용자가 정한 행 순서를 승인 없이 바꾸지 않는다)
- 정렬 권유 거절의 기억: 불필요(디렉토리 트리 정렬 권유와 같이 실행마다 권유한다)
- 이름 속 숫자의 비교 방식: 보류(기존 정렬 규칙에도 정의가 없고, 규칙 파일 이름에 숫자가 드물다)
- `.ai/60_codebase/ai-workspace/update-call-flow.md`의 "표 끝에 삽입" 설명 갱신: 대체(git-pr 문서 동기화 점검의 code-map sync가 맡는다) (이슈 본문 근거 없음. 2026-11-09 spec 작성 중 #136 선례로 추가, 같은 날 승인)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

검증 명령은 repo 루트에서 `bash -s <<'EOF' ... EOF`로 감싸 실행한다(프로세스 치환과 `trap`을 쓴다).

### R1: 표준 행 삽입 자리

- [ ] [D]  멱등 보강 검사 표에서 `## 프로젝트 규칙` 표에 행을 넣는 7개 항목이 각각 정확히 1행 있고, 모두 "알파벳순 자리"로 넣도록 적혀 있다 (AC1)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk -F'|' '
    BEGIN {
      n = split("본문 두 번째 줄 SSoT 선언;건물 repo(`repository.yaml` 존재)의 SSoT 선언;`## 프로젝트 규칙` 섹션 + 3열 표;`## 프로젝트 규칙` 표의 `context-loading.md` 행;`## 프로젝트 규칙` 표의 `writing-principles.md` 행;`## 프로젝트 규칙` 표의 `testing-principles.md` 행;`## 프로젝트 규칙` 표의 `ide-tools.md` 행", w, ";")
      for (i = 1; i <= n; i++) need[w[i]] = 1
    }
    /^#### 멱등 보강 검사/ { f = 1; next }
    f && /^#### / { exit }
    f && /^\|/ {
      k = $2; gsub(/^[[:space:]]+|[[:space:]]+$/, "", k)
      if (k in need) { seen[k]++; if (!index($0, "알파벳순 자리")) print "위반: 알파벳순 자리 없음 — " k }
    }
    END { for (k in need) if (seen[k] != 1) print "위반: 행 " (seen[k] + 0) "개 — " k }
  ' ai-workspace/SKILL.md
  ```

  - 설계 주의: 항목은 첫 셀로 찾는다. 2026-11-09 기준 7개 항목 모두 위반을 내므로 구현 전에는 실패한다.
  </details>
- [ ] [D]  멱등 보강 검사 표에서 `## 프로젝트 도메인` 섹션 항목을 뺀 나머지 행에 "표 끝" 문구가 0건이다 (AC1)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '
    /^#### 멱등 보강 검사/ { f = 1; next }
    f && /^#### / { exit }
    f && /^\|/ && index($0, "표 끝") && index($0, "| `## 프로젝트 도메인` 섹션 |") != 1 { print "위반: ai-workspace/SKILL.md:" NR }
  ' ai-workspace/SKILL.md
  ```

  - 설계 주의: `## 프로젝트 도메인` 섹션 항목의 `ssot_dir` 행 삽입은 제외 범위라 남는다. 2026-11-09 기준 7행(293·294·297~301)이 위반으로 나온다.
  </details>
- [ ] [D]  SKILL.md 표 밖에 "알파벳순 자리"를 정의하고 `## 디렉토리 트리 정렬 규칙`으로 링크하는 문장이 1개 이상 있다 (AC1)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  n=$(grep -v '^|' ai-workspace/SKILL.md | grep -F '알파벳순 자리' | grep -cF '#디렉토리-트리-정렬-규칙')
  [ "$n" -ge 1 ] || echo '위반: 알파벳순 자리 정의 문장 없음'
  ```

  - 설계 주의: 정렬 기준을 따로 정의하지 않고 기존 규칙을 가리키게 한 2026-11-09 사용자 결정을 판정한다.
  </details>
- [ ] [QD] 7개 항목의 문구가 같은 자리 규칙(뒤에 오는 첫 행 바로 앞, 없으면 표 끝, 대소문자 무시)을 가리키고, 2열 표 확장·섹션 복구 경로에서도 읽는 쪽이 같은 자리를 고른다 (AC1)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 문구가 같은 뜻으로 읽히는지는 의미 판단이라 명령으로 환원 불가

### R2: 구버전 마이그레이션의 행 추가

- [ ] [D]  `legacy-migration.md`의 "누락된 행" 문장이 모두 "알파벳순 자리"를 함께 적는다 (AC2)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=ai-workspace/references/legacy-migration.md
  n=$(grep -c '누락된 행' "$F"); m=$(grep '누락된 행' "$F" | grep -c '알파벳순 자리')
  [ "$n" -ge 1 ] && [ "$n" -eq "$m" ] || echo "위반: '누락된 행' ${n}건 중 '알파벳순 자리' ${m}건"
  ```

  </details>

### R3: 순서 검사

- [ ] [D]  정렬된 표는 보고하지 않고, 두 행을 맞바꾼 표는 순서 1행만 보고하고 종료 코드 1을 내며, 확장 열 표도 검사하고, 같은 섹션의 둘째 표는 보지 않는다 (AC3)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=ai-workspace/scripts/check-context.sh
  K="'## 프로젝트 규칙' 표의 행 순서"
  d=$(mktemp -d); trap 'rm -rf "$d"' EXIT
  sed 's/^> last updated: YYYY-MM-DD$/> last updated: 2026-11-09/' ai-workspace/templates/dev/.ai/AI-CONTEXT.md > "$d/ok.md"
  out=$("$C" "$d/ok.md"); rc=$?
  { [ "$rc" -eq 0 ] && [ -z "$out" ]; } || echo "위반: 정렬된 dev 템플릿 보고 (rc=$rc)"
  awk '/^\| `\.ai\/10_rules\/architecture\.md`/ { a = $0; next } a != "" { print; print a; a = ""; next } { print }' "$d/ok.md" > "$d/swap.md"
  out=$("$C" "$d/swap.md"); rc=$?
  { [ "$rc" -eq 1 ] && [ "$(printf '%s\n' "$out" | grep -c .)" -eq 1 ] && printf '%s\n' "$out" | grep -qF "$K"; } || echo "위반: 맞바꾼 표 순서 보고 1행·종료 코드 1 아님 (rc=$rc)"
  awk '/^ ? ? ?## 프로젝트 규칙[[:space:]]*$/ { s = 1 } s && /^ ? ? ?## / && !/프로젝트 규칙/ { s = 0 }
    s && /^\|/ { if ($0 ~ /^\|-/) print $0 "------|"; else if ($0 ~ /^\| 파일 \|/) print $0 " 비고 |"; else print $0 " - |"; next } { print }' "$d/swap.md" > "$d/ext.md"
  "$C" "$d/ext.md" | grep -qF "$K" || echo '위반: 확장 열 표의 어긋남 미보고'
  awk '/^\| `\.ai\/10_rules\/writing-principles\.md`/ { print; print ""; print "| 파일 | 설명 | 사용 시점 |"; print "|------|------|----------|"; print "| `z.md` | z | z |"; print "| `a.md` | a | a |"; next } { print }' "$d/ok.md" > "$d/second.md"
  "$C" "$d/second.md" | grep -qF "$K" && echo '위반: 같은 섹션 둘째 표의 순서를 보고'
  true
  ```

  - 설계 주의: 보고 문구는 `누락: '## 프로젝트 규칙' 표의 행 순서`로 시작한다(전제 참고). 맞바꾼 표에서 출력이 정확히 1행인지 보므로, 다른 항목을 함께 보고하거나 어긋난 쌍마다 여러 행을 내면 실패한다.
  </details>
- [ ] [D]  비교가 대소문자를 무시한다. 대문자만 섞인 정렬 표는 보고하지 않고, 대소문자를 무시해야 어긋나는 표는 보고한다 (AC3)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=ai-workspace/scripts/check-context.sh
  K="'## 프로젝트 규칙' 표의 행 순서"
  d=$(mktemp -d); trap 'rm -rf "$d"' EXIT
  sed 's/^> last updated: YYYY-MM-DD$/> last updated: 2026-11-09/' ai-workspace/templates/dev/.ai/AI-CONTEXT.md > "$d/ok.md"
  sed 's#`\.ai/10_rules/coding-convention\.md`#`.ai/10_rules/Coding-convention.md`#' "$d/ok.md" > "$d/upper-ok.md"
  "$C" "$d/upper-ok.md" | grep -qF "$K" && echo '위반: 대소문자만 다른 정렬 표를 보고'
  sed 's#`\.ai/10_rules/architecture\.md`#`.ai/10_rules/Delta.md`#' "$d/ok.md" > "$d/upper-ng.md"
  "$C" "$d/upper-ng.md" | grep -qF "$K" || echo '위반: 대소문자 무시로 어긋난 표 미보고'
  true
  ```

  - 설계 주의: `Coding-convention`은 대소문자를 구분하면 `architecture`보다 앞이라 어긋남으로 오판하고, `Delta`는 대소문자를 구분하면 `coding-convention`보다 앞이라 정렬로 오판한다. 두 경우가 서로 반대 방향의 오판을 잡는다.
  </details>
- [ ] [D]  헤더가 `파일`·`설명`인 2열 표는 검사하고, 헤더 이름이 다른 표와 섹션·표가 없는 안내도에는 순서를 보고하지 않는다 (AC4)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=ai-workspace/scripts/check-context.sh
  K="'## 프로젝트 규칙' 표의 행 순서"
  X=ai-workspace/tests/fixtures/update4-idempotent
  d=$(mktemp -d); trap 'rm -rf "$d"' EXIT
  awk '/^\| `\.ai\/10_rules\/my-team-rule\.md`/ { print; print "| `.ai/10_rules/a.md` | a |"; next } { print }' "$X/legacy-two-col.input.md" > "$d/two.md"
  "$C" "$d/two.md" | grep -qF "$K" || echo '위반: 헤더가 파일·설명인 2열 표의 어긋남 미보고'
  sed 's/^> last updated: YYYY-MM-DD$/> last updated: 2026-11-09/' ai-workspace/templates/dev/.ai/AI-CONTEXT.md \
    | awk '/^\| `\.ai\/10_rules\/architecture\.md`/ { a = $0; next } a != "" { print; print a; a = ""; next } { print }' \
    | sed 's/^| 파일 | 설명 | 사용 시점 |$/| 이름 | 설명 | 사용 시점 |/' > "$d/othername.md"
  "$C" "$d/othername.md" | grep -qF "$K" && echo '위반: 헤더 이름이 다른 표의 순서를 보고'
  "$C" "$X/no-rules-section.input.md" | grep -qF "$K" && echo '위반: 섹션 부재에서 순서 보고'
  "$C" "$X/no-rules-table.input.md" | grep -qF "$K" && echo '위반: 표 부재에서 순서 보고'
  true
  ```

  - 설계 주의: 보고하지 않아야 하는 경우만 두면 구현 전에도 통과하므로, 보고해야 하는 2열 표 경우를 같은 명령에 둔다.
  </details>

### R4: 정렬 권유 항목

- [ ] [D]  멱등 보강 검사 표에 첫 셀이 `` `## 프로젝트 규칙` 표의 행 순서 ``인 항목이 정확히 1개이고, 그 행에 승인과 행 단위 재정렬이 적혀 있다 (AC5)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk -F'|' '
    /^#### 멱등 보강 검사/ { f = 1; next }
    f && /^#### / { exit }
    f && /^\|/ {
      k = $2; gsub(/^[[:space:]]+|[[:space:]]+$/, "", k)
      if (k == "`## 프로젝트 규칙` 표의 행 순서") {
        n++
        if (!index($0, "승인") || !index($0, "행 단위")) print "위반: 행 순서 항목에 승인·행 단위 문구 없음"
      }
    }
    END { if (n != 1) print "위반: 행 순서 항목 " (n + 0) "개" }
  ' ai-workspace/SKILL.md
  ```

  </details>
- [ ] [D]  멱등 보강 검사 표가 15개 항목이고, 헬퍼 판정 수 문장이 "15개 항목 중 13개"다 (AC5)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=ai-workspace/SKILL.md
  n=$(awk '/^#### 멱등 보강 검사/ { f = 1; next } f && /^#### / { exit } f && /^\|/ { n++ } END { print n - 2 }' "$S")
  [ "$n" -eq 15 ] || echo "위반: 멱등 보강 검사 표 ${n}행"
  grep -qF '헬퍼는 표의 15개 항목 중 13개를 판정합니다' "$S" || echo '위반: 헬퍼 판정 수 문장 불일치'
  ```

  </details>
- [ ] [D]  `unsorted-rows` fixture가 있고, 입력(사용자 행·확장 열이 있는 어긋난 표)은 순서를 보고하고, 기대 파일은 같은 행 집합을 정렬해 규칙 표 관련 보고가 없다 (AC5)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  X=ai-workspace/tests/fixtures/update4-idempotent
  C=ai-workspace/scripts/check-context.sh
  K="'## 프로젝트 규칙' 표의 행 순서"
  rows() { awk '/^ ? ? ?## 프로젝트 규칙[[:space:]]*$/ { s = 1; next } s && /^ ? ? ?## / { exit } s && /^\|/ { t++; if (t > 2) print; next } s && t { exit }' "$1"; }
  I="$X/unsorted-rows.input.md"; E="$X/unsorted-rows.expected.md"
  if [ ! -r "$I" ] || [ ! -r "$E" ]; then
    echo '위반: unsorted-rows fixture 쌍 없음'
  else
    "$C" "$I" | grep -qF "$K" || echo '위반: 입력의 순서 미보고'
    "$C" "$E" | grep -qF "'## 프로젝트 규칙'" && echo '위반: 기대 파일에 규칙 표 관련 보고'
    [ "$(rows "$I" | awk -F'|' '{ print NF }' | sort -u)" = 6 ] || echo '위반: 입력 표가 4열(확장 열 1개)이 아님'
    rows "$I" | grep -qF 'my-team-rule' || echo '위반: 입력에 사용자 행 없음'
    diff <(rows "$I" | LC_ALL=C sort) <(rows "$E" | LC_ALL=C sort) >/dev/null || echo '위반: 입력·기대의 행 집합이 다름'
  fi
  true
  ```

  - 설계 주의: 행 집합 비교는 행을 통째로 옮겼는지(셀 내용·확장 열 보존)를 판정한다. 셀 공백을 다시 맞추면 실패하므로 기대 파일은 행을 그대로 옮겨 만든다.
  </details>
- [ ] [QD] 순서 항목의 조치가 정렬 여부를 묻고 승인한 경우에만 재정렬하며, 같은 실행에서 행 보강과 겹칠 때의 처리 순서가 모호하지 않고, `unsorted-rows` 모의 실행 결과가 기대 파일과 일치한다 (AC5)  (검증: 다른 AI가 fixture README 실행 방법으로 채점, 별도 세션)  ← 강등 사유: 묻고 승인받는 절차는 AI가 수행하는 조치라 명령으로 실행할 수 없다

### R5: fixture와 테스트

- [ ] [D]  기대 파일 5개의 `## 프로젝트 규칙` 표가 알파벳순이고, 헬퍼가 규칙 표 관련 항목을 보고하지 않는다 (AC6)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  X=ai-workspace/tests/fixtures/update4-idempotent
  for c in missing-rows missing-rows-doc legacy-two-col no-rules-section-mismatch no-rules-table-mismatch; do
    f="$X/$c.expected.md"
    col=$(awk -F'|' '/^ ? ? ?## 프로젝트 규칙[[:space:]]*$/ { s = 1; next } s && /^ ? ? ?## / { exit }
      s && /^\|/ { t++; if (t > 2) { v = $2; gsub(/^[[:space:]]+|[[:space:]]+$/, "", v); gsub(/`/, "", v); print tolower(v) } next }
      s && t { exit }' "$f")
    [ -n "$col" ] || { echo "위반: $c 규칙 표 없음"; continue; }
    [ "$col" = "$(printf '%s\n' "$col" | LC_ALL=C sort)" ] || echo "위반: $c 규칙 표가 알파벳순 아님"
    ai-workspace/scripts/check-context.sh "$f" | grep -qF "'## 프로젝트 규칙'" && echo "위반: $c 규칙 표 관련 보고 있음"
  done
  true
  ```

  - 설계 주의: 헬퍼와 별개로 정렬을 다시 계산해, 헬퍼 순서 검사가 빠져도 기대 파일 순서를 판정한다. 기대 파일은 다른 섹션이 없어 헬퍼 종료 코드는 보지 않는다.
  </details>
- [ ] [D]  fixture README에 "표 끝에 표준·dev 전용 행" 기대 설명과 "관련 5개 항목" 문구가 남아 있지 않다 (AC6)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -nE '표 끝에 (표준|dev 전용)|관련 5개 항목' ai-workspace/tests/fixtures/update4-idempotent/README.md | sed 's/^/위반: /'
  ```

  - 설계 주의: 순서 항목이 더해져 README가 다루는 `## 프로젝트 규칙` 관련 항목은 6개가 된다.
  </details>
- [ ] [D]  `ai-workspace/tests/run-tests.sh`가 0 실패로 통과하고, "행 순서" 통과·격추 케이스와 검사 표 15행 확인이 실행된다 (AC7)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과 (실행에 2분 넘게 걸린다)</summary>

  ```bash
  out=$(ai-workspace/tests/run-tests.sh 2>&1); rc=$?
  [ "$rc" -eq 0 ] || echo "위반: 러너 실패 rc=$rc"
  [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*행 순서.*통과')" -ge 1 ] || echo '위반: 행 순서 통과 케이스 없음'
  [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*행 순서.*격추')" -ge 1 ] || echo '위반: 행 순서 격추 케이스 없음'
  printf '%s\n' "$out" | grep -qE '^ok +- SKILL.md 멱등 보강 검사 표: 15행' || echo '위반: 검사 표 15행 확인 없음'
  ```

  - 설계 주의: 러너 통과만 보면 케이스를 넣기 전에도 통과하므로 `ok` 행을 낱말별로 센다. 케이스 설명에는 `통과`·`격추` 중 하나만 쓴다.
  </details>

### R6: 도메인 명세 동기화

- [ ] [D]  `ai-workspace.md`의 멱등 보강 검사 줄이 1개이고 "13종"·"알파벳순"을 담으며 "12종"·"넓힌 표 끝에"가 없다 (AC8)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=.ai/40_domain/specs/ai-workspace.md
  l=$(grep -E '^- update 멱등 보강 검사' "$F")
  [ "$(printf '%s\n' "$l" | grep -c .)" -eq 1 ] || echo '위반: 멱등 보강 검사 줄이 1개가 아님'
  case "$l" in *'13종'*) ;; *) echo '위반: 13종 없음' ;; esac
  case "$l" in *'알파벳순'*) ;; *) echo '위반: 알파벳순 없음' ;; esac
  case "$l" in *'12종'*|*'넓힌 표 끝에'*) echo '위반: 옛 문구 잔존' ;; esac
  true
  ```

  </details>
- [ ] [QD] 명세가 알파벳순 자리 보강, 순서 검사, 승인 시 재정렬을 SKILL.md와 같은 뜻으로 담는다 (AC8)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 요약 문장이 원문과 같은 뜻인지는 의미 판단이라 명령으로 환원 불가

### R7: ADR 일부 변경

- [ ] [D]  ADR 0028·0029의 결정 섹션에서 옛 문구("표준 행만 보강한다", "표 끝에 표준 행")가 사라지고 "알파벳순"이 들어가며, 각 근거에 `일부 변경(#138)` 기록 1건과 원본 출처에 #138 링크가 있다 (AC9)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  A=.ai/50_adr/active/0028-ai-workspace-owned-sections-and-profile-row.md
  B=.ai/50_adr/active/0029-ide-tools-rule-dev-profile-distribution.md
  sec() { awk -v h="$2" '$0 == h { f = 1; next } f && /^## / { exit } f' "$1"; }
  sec "$A" '## 결정' | grep -q '표준 행만 보강한다' && echo '위반: 0028 결정에 옛 문구'
  sec "$A" '## 결정' | grep -F '`## 프로젝트 규칙`' | grep -q '알파벳순' || echo '위반: 0028 결정에 알파벳순 없음'
  sec "$B" '## 결정' | grep -q '표 끝에 표준 행' && echo '위반: 0029 결정에 옛 문구'
  sec "$B" '## 결정' | grep -q '알파벳순' || echo '위반: 0029 결정에 알파벳순 없음'
  for f in "$A" "$B"; do
    [ "$(sec "$f" '## 근거' | grep -c '일부 변경(#138)')" -eq 1 ] || echo "위반: 근거의 변경 기록 1건 아님 — $f"
    sec "$f" '## 원본 출처' | grep -qF 'issues/138' || echo "위반: 원본 출처에 #138 없음 — $f"
  done
  true
  ```

  - 설계 주의: 근거 기록 형식은 ADR 0025의 `- 2026-11-03 일부 변경(#132): ...` 선례를 따른다.
  </details>
- [ ] [QD] 두 ADR의 바뀐 결정 문장이 새 동작과 맞고, 근거에 변경 경위가 적혀 있다 (AC9)  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 결정 문장과 동작의 일치는 의미 판단이라 명령으로 환원 불가

### 공통

- [ ] [D]  repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>

---

## 전제 (Assumptions)

- **정렬 비교 구현**: 헬퍼는 `파일` 셀에서 백틱과 양끝 공백을 빼고 소문자로 바꾼 뒤 `LC_ALL=C` 바이트 순으로 비교한다. 예를 들어 `testing-principles-local.md`가 `testing-principles.md`보다 앞이다. 문서 문구에는 비교 방식을 따로 정의하지 않고 `## 디렉토리 트리 정렬 규칙`(대소문자 무시 알파벳순)을 가리킨다(2026-11-09 사용자 결정). 같은 값의 행이 이어지면 어긋남으로 보지 않는다.
- **디렉토리 우선 미적용**: SKILL.md의 알파벳순 자리 정의 문장에 "경로 전체를 한 문자열로 비교하며 디렉토리 우선은 적용하지 않는다"를 함께 적는다. `## 디렉토리 트리 정렬 규칙`의 디렉토리 우선까지 따르면 `.ai/10_rules/team/x.md` 같은 하위 디렉토리 행에서 AI가 고른 자리와 헬퍼 판정이 갈린다. AC1의 결과는 그대로 두고 판정 기준만 밝히는 구체화다(2026-11-09 Task 0 사용자 결정).
- **헤더·구분선 제외**: 순서 비교는 첫 표의 첫 행(헤더)과 둘째 행(구분선)을 뺀 데이터 행만 대상으로 한다. 구분선 `|---|`를 비교에 넣으면 헤더 `파일`과의 바이트 비교로 모든 표가 어긋남으로 나온다.
- **보고 문구**: 순서 보고는 기존 `ng` 함수로 내며 `누락: '## 프로젝트 규칙' 표의 행 순서`로 시작한다. spec 검증 명령이 이 문구로 판정한다. 뒤에 처음 어긋난 두 행을 붙여도 되지만 1행을 넘지 않는다.
- **탐색 방식**: 순서 검사는 기존 표준 행 검사와 같은 섹션·첫 표 탐색(`rules_ok=true` 조건, 첫 비표 행에서 멈춤)을 쓰고, SSoT 선언 종류와 무관하게 수행한다. 코드 펜스·주석은 추적하지 않는다(기존 행 검사와 같은 한계, 원장 K-0026·K-0027과 별개).
- **같은 실행에서 겹칠 때**: 헬퍼는 실행마다 한 번 돌아 순서 검사는 행 보강 전 상태를 보고한다. 보강할 행과 순서 보고가 함께 나오면 먼저 알파벳순 자리에 행을 넣고 정렬 여부를 묻는다. 승인하면 넣은 행까지 포함해 표 전체를 재정렬한다(계획 작성 중 정한 처리 순서).
- **`unsorted-rows` fixture 신설**: R4 조치의 모의 실행 근거로 둔다. 입력은 dev 선언, 4열(확장 열 `비고`) 표, 사용자 행 `my-team-rule.md` 포함, 표준 행 누락 없음, 순서만 어긋난 상태다. 검증 수단이라 요구사항을 넓히지 않는다.
- **기준선**: 2026-11-09 `main`(3f50a96)에서 `ai-workspace/tests/run-tests.sh`가 197 passed, 0 failed다. 실행에 2분 넘게 걸리므로 검증 명령의 시간 제한을 넉넉히 둔다.
- **검토 후 버린 대안**: 행 삽입을 `sync-owned.sh`로 옮기는 안은 헬퍼 구현·테스트가 늘어 제외했다(이슈 제외 목록). 정렬 기준을 "소문자 변환 뒤 문자 코드 순"으로 문서에 정의하는 안은 기준이 두 곳으로 갈라져 버렸다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/40_domain/specs/ai-workspace.md` | update 멱등 보강 검사 명세 (R6 수정 대상) |
| `.ai/50_adr/active/0028-ai-workspace-owned-sections-and-profile-row.md` | update 소유 구분. `## 프로젝트 규칙`은 사용자 작성 구간이고 행 검사로 보강 (R7 수정 대상) |
| `.ai/50_adr/active/0029-ide-tools-rule-dev-profile-distribution.md` | `ide-tools.md` 행 누락 시 표 끝 삽입 결정 (R7 수정 대상) |
| `.ai/40_domain/policies/local/notation-conventions.md` | 트리 정렬 관례(대소문자 무시 알파벳순, 디렉토리 우선) |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | `check-context.sh` 테스트 위치·러너 |
| `.ai/50_adr/active/0003-verification-levels-and-determinization.md` | 완료의 정의 검증 레벨 |
