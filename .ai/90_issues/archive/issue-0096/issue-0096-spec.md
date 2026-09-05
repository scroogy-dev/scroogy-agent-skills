# Issue #96 스펙 git-review: 결과 산출물에 신호등 판정 한 줄·상태 이모지·항목별 볼드 제목과 접기 도입

## 목표 (Goal)

git-review 결과 파일을 열면 첫 줄의 신호등 판정으로 승인 여부가 읽히고, 상태·등급의 심각도가 이모지로 구분되며, 리뷰 포인트마다 근거를 따로 펼쳐 볼 수 있게 한다.

---

## 요구사항 (Requirements)

**포함**

- R1: 결과 파일 제목 바로 아래에 판정 한 줄(🟢 승인(APPROVE) / 🟡 조건부 승인(CONDITIONAL) / 🔴 변경 요청(REQUEST CHANGES))이 오고, 헬퍼 `--verdict`가 비즈니스·테크 리뷰 상태 2개의 최고값에서 판정을 산출한다. 판정을 뺀 나머지 최종 의견(종합 판단·후속 액션)은 접힌다.
- R2: 헬퍼의 등급·상태 출력 앞에 대응표대로 이모지가 붙고(🔴 높음 / 🟡 중간 / 🟢 낮음 / ⚪ 정보, 🔴 보완 필요 / 🟡 주의 / 🟢 통과), 요약 상태 줄·카테고리 표 상태 열·테크 리뷰 소절 제목에 그 값이 쓰인다. 요약 표 건수 열은 텍스트 등급만 쓴다.
- R3: 리뷰 포인트가 볼드 한 줄 `**<이모지> <등급> <제목>**`, 일반체 지적·권장 조치(1~3문장), 항목 바로 아래 접기(영향·발생확률 축, 근거, 코드 위치, 호출 흐름)로 구성되고 카테고리 단위 접기는 사라진다. 비즈니스 리뷰에도 같은 형식을 적용한다.
- R4: `--status`·`--verdict`가 이모지 접두가 붙은 값과 붙지 않은 값을 모두 받는다. 헬퍼 출력을 그대로 되넘길 수 있어야 한다.
- R5: SKILL.md에 판정 산출 규칙(판정 표, Self 리뷰 의미, 헬퍼 사용 예), 이모지 대응표, 새 결과 기록 형식·접기 규칙, 대화창 보고 첫 줄 규칙이 기재되고 옛 항목 형식 문구가 남지 않는다.
- R6: git-review 러너가 SKILL.md 표에서 기대값을 추출하는 방식을 유지한 채 이모지 출력·`--verdict`·입력 호환을 검사하고, issue-audit 러너의 사본 대조가 이모지 접두를 걷어내 매트릭스만 비교하며, `.ai/AI-CONTEXT.md`의 git-review scripts 행이 판정 산출을 반영한다.

**제외**

- issue-audit 리포트·헬퍼의 이모지 정렬: 등급 값 자체는 바뀌지 않아 동기화 의무가 없다. 필요하면 후속 이슈로 연다 (#75 뒤에 #76을 연 선례).
- 위험도 매트릭스·축 값·정의 변경: 원장 K-0002의 재검토 조건을 발동시키지 않는다.
- 리뷰 포인트 식별자(예: R-1) 부여: git-pr-feedback·PR 코멘트 참조 편의는 있으나 이번 범위 밖으로 미룬다.
- 판정 첫 줄을 제외한 대화창 출력 형식: #75의 비포함을 유지한다.
- `.ai/10_rules/writing-principles.md` 변경: ai-workspace 동기화 대상이라 이 repo에서 직접 고치지 않는다.
- 기존 리뷰 산출물 소급 개정: 신규 리뷰부터 적용한다.

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

### R1: 판정 한 줄

- [ ] [D] 헬퍼 `--verdict`가 상태 2개의 최고값으로 판정 3종을 산출하고, 인자 개수가 2가 아니거나 상태가 아닌 값이거나 다른 모드와 섞이면 종료 코드 2이며 표준 출력에 판정이 없다. 모드 혼용은 축 옵션의 **등장 여부**로 판정하므로 값이 빈 문자열이어도 거부되며, 같은 판정 방식을 `--status` 혼용에도 적용한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  C=git-review/scripts/classify-risk.sh
  v() { "$C" --verdict "$@" 2>/dev/null; }
  [ "$(v '통과(PASS)' '통과(PASS)')" = '🟢 승인(APPROVE)' ]                 || echo '위반: PASS+PASS'
  [ "$(v '통과(PASS)' '주의(WARN)')" = '🟡 조건부 승인(CONDITIONAL)' ]        || echo '위반: PASS+WARN'
  [ "$(v '보완 필요(FAIL)' '통과(PASS)')" = '🔴 변경 요청(REQUEST CHANGES)' ] || echo '위반: FAIL+PASS'
  [ "$(v '주의(WARN)' '보완 필요(FAIL)')" = '🔴 변경 요청(REQUEST CHANGES)' ] || echo '위반: WARN+FAIL'
  "$C" --verdict >/dev/null 2>&1;                                        [ $? -eq 2 ] || echo '위반: 인자 0개'
  "$C" --verdict '통과(PASS)' >/dev/null 2>&1;                           [ $? -eq 2 ] || echo '위반: 인자 1개'
  "$C" --verdict '통과(PASS)' '통과(PASS)' '통과(PASS)' >/dev/null 2>&1;  [ $? -eq 2 ] || echo '위반: 인자 3개'
  "$C" --verdict '승인' '통과(PASS)' >/dev/null 2>&1;                    [ $? -eq 2 ] || echo '위반: 미지 상태'
  mix() { local o r; o="$("$C" "$@" 2>/dev/null)"; r=$?; { [ "$r" -eq 2 ] && [ -z "$o" ]; } || echo "위반: 모드 혼용 — $*"; }
  for pair in '--impact:기능 저하' '--likelihood:통상 사용'; do
    opt="${pair%%:*}"
    for val in '' "${pair#*:}"; do
      mix "$opt" "$val" --verdict '통과(PASS)' '통과(PASS)'
      mix --verdict '통과(PASS)' '통과(PASS)' "$opt" "$val"
      mix "$opt" "$val" --status '높음(HIGH)'
    done
  done
  ```

  - 설계 주의: 기대값은 GitHub 이슈 #96 결정 사항의 확정값이다. 순서 무관(최고값)임을 FAIL+PASS와 WARN+FAIL 두 방향으로 확인한다.
  - 설계 주의: 모드 혼용은 반례 하나가 아니라 불변식 전수로 센다. 축 옵션 2종 × 값 형태(빈 값·일반 값) × 배치(전치·후치)를 돌려 `--verdict`·`--status` 양쪽을 덮는다. 값이 있는 조합만 검사하면 빈 문자열이 옵션 미지정과 같아져 혼용이 통과한다. 종료 코드와 함께 표준 출력 공집합도 보는 이유는, 사용오류인데 산출값이 나오면 호출자가 그 값을 읽어 쓰기 때문이다.
  </details>
- [ ] [D] 템플릿의 판정 자리표시자가 첫 `## ` 헤더보다 앞에 있고, `## 최종 의견` 헤더는 없으며, 최종 의견 접기가 판정과 `## 요약` 사이에 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=git-review/templates/review-result-template.md
  grep -qE '^## 최종 의견' "$T" && echo '위반: 최종 의견 헤더 잔존'
  [ "$(grep -E '^## ' "$T" | head -1)" = '## 요약' ] || echo '위반: 첫 H2가 요약이 아님'
  v=$(grep -nE '^<판정>$' "$T" | cut -d: -f1 | head -1)
  o=$(grep -nF '<summary>최종 의견 펼치기</summary>' "$T" | cut -d: -f1 | head -1)
  s=$(grep -nE '^## 요약$' "$T" | cut -d: -f1 | head -1)
  { [ -n "$v" ] && [ -n "$o" ] && [ -n "$s" ] && [ "$v" -lt "$o" ] && [ "$o" -lt "$s" ]; } \
    || echo "위반: 판정($v) → 최종 의견 접기($o) → 요약($s) 순서 아님"
  ```

  - 설계 주의: 문구가 아니라 행 앵커(`^<판정>$`, `^## 요약$`, summary 태그)의 행 번호 순서를 센다. 자리표시자 이름은 `<판정>`으로 고정한다 (`## 전제` 참조).
  </details>

### R2: 상태·등급 이모지

- [ ] [D] 헬퍼의 매트릭스 6조합 출력이 `<이모지> <등급>`, `--status` 출력이 `<이모지> <상태>` 형식으로 이슈 확정값과 일치한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  C=git-review/scripts/classify-risk.sh
  g() { "$C" --impact "$1" --likelihood "$2" 2>/dev/null; }
  [ "$(g '스펙·기능 달성 차단' '통상 사용')" = '🔴 높음(HIGH)' ]      || echo '위반: 차단×통상'
  [ "$(g '스펙·기능 달성 차단' '특수 조건·엣지')" = '🟡 중간(MEDIUM)' ] || echo '위반: 차단×엣지'
  [ "$(g '기능 저하' '통상 사용')" = '🟡 중간(MEDIUM)' ]             || echo '위반: 저하×통상'
  [ "$(g '기능 저하' '특수 조건·엣지')" = '🟢 낮음(LOW)' ]            || echo '위반: 저하×엣지'
  [ "$(g '기술 품질 의견' '통상 사용')" = '🟢 낮음(LOW)' ]            || echo '위반: 의견×통상'
  [ "$(g '기술 품질 의견' '특수 조건·엣지')" = '⚪ 정보(INFO)' ]       || echo '위반: 의견×엣지'
  [ "$("$C" --status)" = '🟢 통과(PASS)' ]                               || echo '위반: 발견 없음'
  [ "$("$C" --status '낮음(LOW)' '중간(MEDIUM)')" = '🟡 주의(WARN)' ]     || echo '위반: 중간 포함'
  [ "$("$C" --status '정보(INFO)' '높음(HIGH)')" = '🔴 보완 필요(FAIL)' ] || echo '위반: 높음 포함'
  ```

  - 설계 주의: 등급 텍스트는 현행과 같고 이모지만 앞에 붙는다. 매트릭스 표 자체는 바뀌지 않으므로 6조합 전수를 그대로 대조한다.
  </details>
- [ ] [D] 템플릿의 요약 상태 줄 2개·카테고리 표 상태 열·테크 리뷰 소절 제목에 `<이모지> <상태>` 자리표시자가 있고, 카테고리 표 건수 열 안내가 텍스트 등급만 쓴다고 적는다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=git-review/templates/review-result-template.md
  grep -qE '^- 비즈니스 리뷰: <이모지> <상태>' "$T" || echo '위반: 요약 비즈니스 상태 줄'
  grep -qE '^- 테크 리뷰: <이모지> <상태>' "$T"     || echo '위반: 요약 테크 상태 줄'
  grep -qE '^\| 기능 \|.*텍스트 등급만.*\| <이모지> <상태> \|' "$T" \
    || echo '위반: 카테고리 표 기능 행(건수 텍스트 안내·상태 이모지)'
  grep -qE '^### <카테고리> — <이모지> <상태>, N건$' "$T" || echo '위반: 테크 리뷰 소절 제목'
  ```

  </details>

### R3: 리뷰 포인트 블록

- [ ] [D] 템플릿에 카테고리 단위 접기와 옛 항목 형식 문구가 없고, 볼드 제목 자리표시자와 `근거 펼치기` 접기가 비즈니스·테크 리뷰 섹션에 각각 1개 이상 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=git-review/templates/review-result-template.md
  grep -nF '상세 분석·근거 펼치기' "$T"
  grep -nF '<등급> [<영향 축> × <발생확률 축>]' "$T"
  for sec in '비즈니스 리뷰' '테크 리뷰'; do
    body=$(awk -v h="## $sec" '$0==h{f=1;next} /^## /{f=0} f' "$T")
    printf '%s\n' "$body" | grep -qE '^\*\*<이모지> <등급> <제목>\*\*$' || echo "위반: $sec 볼드 제목 자리표시자 없음"
    printf '%s\n' "$body" | grep -qF '<summary>근거 펼치기</summary>'   || echo "위반: $sec 근거 접기 없음"
  done
  ```

  - 설계 주의: 앞 두 `grep -n`은 잔존 행을 그대로 출력하므로 출력이 있으면 위반이다. 섹션 본문은 `^## ` 앵커로 잘라 섹션별 실재를 따로 센다.
  </details>
- [ ] [QD] 템플릿 안내 주석이 항목을 문단으로 두는 이유(리스트 안 접기는 GitHub·IDE 미리보기 렌더링이 깨짐)와 접기 안·밖의 경계(안은 근거·코드 위치·호출 흐름·축 판정, 밖은 제목·지적·권장 조치)를 설명한다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 주석 서술의 충분성은 의미 판단이라 명령으로 환원 불가

### R4: 입력 호환

- [ ] [D] `--status`·`--verdict`가 이모지 접두 유무와 무관하게 같은 결과를 내고, 대응표에 없는 접두는 종료 코드 2로 거른다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  C=git-review/scripts/classify-risk.sh
  [ "$("$C" --status '🟡 중간(MEDIUM)' '⚪ 정보(INFO)')" = '🟡 주의(WARN)' ]                     || echo '위반: --status 이모지 접두 입력'
  [ "$("$C" --verdict '🟢 통과(PASS)' '🔴 보완 필요(FAIL)')" = '🔴 변경 요청(REQUEST CHANGES)' ] || echo '위반: --verdict 이모지 접두 입력'
  [ "$("$C" --verdict '🟢 통과(PASS)' '주의(WARN)')" = '🟡 조건부 승인(CONDITIONAL)' ]           || echo '위반: --verdict 혼합 입력'
  "$C" --status '🔵 중간(MEDIUM)' >/dev/null 2>&1;             [ $? -eq 2 ] || echo '위반: --status 미지 접두 통과'
  "$C" --verdict '🔵 통과(PASS)' '통과(PASS)' >/dev/null 2>&1; [ $? -eq 2 ] || echo '위반: --verdict 미지 접두 통과'
  ```

  - 설계 주의: "같은 결과"를 두 호출의 출력 비교로 판정하면 둘 다 빈 출력(오류)일 때 통과한다. 기대값을 직접 적는다.
  </details>

### R5: SKILL.md 규칙

- [ ] [D] `## 판정 산출` 섹션과 판정 표(데이터 3행), 이모지 대응표(등급 4·상태 3·판정 3 = 데이터 10행, 이모지 값은 🔴🟡🟢⚪ 중 하나)가 있고, 옛 항목 형식 문구가 SKILL.md·템플릿에 0건이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  S=git-review/SKILL.md
  grep -qE '^## 판정 산출$' "$S" || echo '위반: 판정 산출 섹션 없음'
  n=$(awk '/^\| 최고 상태 \| 판정 \|/{f=1;next} f&&/^\|/{n++;next} f{exit} END{print n+0}' "$S")
  [ "$n" -eq 4 ] || echo "위반: 판정 표 행 수 $n (구분선 1 + 데이터 3 기대)"
  rows=$(awk '/^\*\*이모지 대응표\*\*/{f=1;next} f&&/^\|/{print;n++;next} f&&n{exit}' "$S")
  data=$(printf '%s\n' "$rows" | tail -n +3)
  [ "$(printf '%s\n' "$data" | grep -c '^|')" -eq 10 ] || echo '위반: 대응표 데이터 10행 아님'
  for k in '등급:4' '상태:3' '판정:3'; do
    c=$(printf '%s\n' "$data" | grep -c "^| ${k%%:*} |"); [ "$c" -eq "${k##*:}" ] || echo "위반: 대응표 ${k%%:*} 행 ${c}개"
  done
  printf '%s\n' "$data" | grep '^|' | awk -F'|' '{print $4}' | sed 's/ //g' | grep -vxE '🔴|🟡|🟢|⚪' | sed 's/^/위반: 이모지 값 /'
  grep -nF '<등급> [<영향 축> × <발생확률 축>]' "$S" git-review/templates/review-result-template.md
  ```

  - 설계 주의: 판정 표는 `| 최고 상태 | 판정 |` 헤더 행, 대응표는 `**이모지 대응표**` 볼드 행을 앵커로 잡고 그 다음 연속된 표 행만 센다. 표 열 구성(`| 구분 | 값 | 이모지 |`)은 `## 전제`에서 고정한다.
  </details>
- [ ] [QD] 판정 산출 소절이 판정은 리뷰어가 고르지 않고 비즈니스·테크 상태 최고값에서 나온다는 규칙, Self 리뷰에서 승인이 "제출 가능"을 뜻한다는 점, 판정은 우선순위 신호이고 보정 여부는 작성자 판단(`git-pr-feedback` 영역)임을 담는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 서술 충분성은 의미 판단이라 명령으로 환원 불가
- [ ] [QD] 결과 기록 형식·산출물 접기 기준이 항목별 접기 규칙, 최종 의견 접기가 "액션 아이템 접기 금지"와 충돌하지 않는 해석(리뷰 포인트 제목이 본문에 보임), 대화창 보고가 판정 한 줄로 시작한다는 규칙을 담는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 위와 같음

### R6: 테스트·안내도 정합

- [ ] [D] git-review 러너가 통과하고, 대응표 추출·판정·입력 호환 케이스를 `ok` 행으로 보고한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  out=$(git-review/tests/run-tests.sh 2>&1); rc=$?
  [ "$rc" -eq 0 ] || { echo "위반: git-review 러너 exit $rc"; printf '%s\n' "$out" | grep 'NOT OK'; }
  printf '%s\n' "$out" | grep -qE '^ok     - 대응표 추출' || echo '위반: 러너가 대응표를 추출하지 않음'
  printf '%s\n' "$out" | grep -qE '^ok     - 판정: '      || echo '위반: 러너에 판정 케이스 없음'
  printf '%s\n' "$out" | grep -qE '^ok     - 입력 호환: '  || echo '위반: 러너에 입력 호환 케이스 없음'
  ```

  - 설계 주의: 러너 통과만 보면 케이스를 지워도 통과한다. 케이스 종류별 `ok` 행 접두를 고정해 실재를 함께 센다 (접두 문자열은 `## 전제` 참조).
  </details>
- [ ] [D] issue-audit 러너가 통과하고, 사본 대조가 건너뜀이 아니라 매트릭스 일치로 보고된다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  out=$(issue-audit/tests/run-tests.sh 2>&1); rc=$?
  [ "$rc" -eq 0 ] || { echo "위반: issue-audit 러너 exit $rc"; printf '%s\n' "$out" | grep 'NOT OK'; }
  printf '%s\n' "$out" | grep -qF 'ok     - 사본 대조: git-review classify-risk.sh 와 매트릭스 일치' \
    || echo '위반: 사본 대조가 일치로 보고되지 않음'
  ```

  - 설계 주의: git-review 사본이 없으면 러너가 "건너뜀"으로 통과하므로, 통과 여부와 별개로 "일치" 행의 실재를 센다.
  </details>
- [ ] [D] `.ai/AI-CONTEXT.md`의 git-review 하위 scripts 행에 판정 산출이 기재된다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  awk '/^├── git-review\//{f=1;next} /^├── /{f=0} f' .ai/AI-CONTEXT.md \
    | grep -E 'scripts/.*classify-risk\.sh' | grep -qF '판정' \
    || echo '위반: AI-CONTEXT git-review scripts 행에 판정 없음'
  ```

  - 설계 주의: `classify-risk.sh`는 issue-audit 행에도 있어 파일 전체 grep은 다른 행을 잡는다. git-review 블록만 잘라 본다.
  </details>

### 공통

- [ ] [D] repo 전체 스킬 러너가 통과한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D] issue-audit의 SKILL.md와 헬퍼는 바뀌지 않는다 (제외 항목 경계, K-0002 재검토 조건 비발동)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  git diff --name-only main -- issue-audit/SKILL.md issue-audit/scripts/
  ```

  - 설계 주의: issue-audit 쪽 변경은 `tests/run-tests.sh`의 사본 대조 정규화 1곳뿐이어야 한다. 그 파일은 이 명령의 대상에서 뺀다.
  </details>

---

## 전제 (Assumptions)

- 설계 단계 결정 (2026-09-04, 이슈 본문이 스펙 단계로 미룬 항목과 설계 중 정한 값. Task 0에서 사용자 확인 완료, 2026-09-04):
  - `--status`·`--verdict` 입력 호환은 **둘 다 받는다**. 헬퍼가 이모지 접두 출력을 내므로 리뷰어가 그 값을 그대로 `--status`에 되넘기는 경로가 기본 사용 흐름이다. 거부하면 리뷰어가 접두를 손으로 떼야 한다. 걷어내는 접두는 대응표의 4종(`🔴 `·`🟡 `·`🟢 `·`⚪ `)으로 한정하고, 그 밖의 접두는 미지 값으로 종료 코드 2다.
  - `--verdict`는 위치 인자 정확히 2개(비즈니스 상태, 테크 상태)를 받는다. 순서는 무관하며 최고값(보완 필요(FAIL) > 주의(WARN) > 통과(PASS))으로 판정한다. 개수가 다르면 종료 코드 2다. `--status`처럼 0개 이상을 받지 않는 이유는 판정의 입력이 두 리뷰 상태로 고정되어 있기 때문이다.
  - 이모지의 SSoT는 SKILL.md의 `**이모지 대응표**` 한 곳이다. 표 열은 `| 구분 | 값 | 이모지 |`이고 구분 값은 등급·상태·판정 셋이다. 매트릭스 표·상태 산출 표·판정 표의 셀 값은 텍스트로 유지하고 이모지를 넣지 않는다. 이슈 본문의 "상태 산출 표 갱신"은 그 소절의 헬퍼 예시 출력과 설명 문구 갱신으로 해석했다. 이유는 논리 표(매트릭스·상태·판정)와 표시 규칙(이모지)을 분리해 러너가 한 곳에서 이모지를 추출하게 하고, 같은 값이 두 표에 중복 기재되지 않게 하기 위함이다.
  - 판정 표 헤더는 `| 최고 상태 | 판정 |`이고 판정 열은 텍스트(승인(APPROVE) 등)다.
  - 템플릿의 판정 자리표시자는 제목 다음 `<판정>` 한 줄이다. 최종 의견은 `<details><summary>최종 의견 펼치기</summary>` 접기이며 `## 최종 의견` H2는 없앤다.
  - 비즈니스 리뷰 섹션의 `### 리뷰 포인트` 소제목은 없앤다. 카테고리 접기가 사라지면 `## 비즈니스 리뷰`의 유일한 자식이 되어 정보가 없다. 블록을 섹션 바로 아래에 둔다.
  - 테크 리뷰 소절 제목의 구분자 `—`는 현행 형식(`### <카테고리> — <상태>, N건`)을 유지한다. 형식 고정·구분자 용법은 #87 정비에서 예외로 확정된 자리다.
- 범위 판단 (설계 중 발견, 이슈 본문에 없는 추가. Task 0에서 사용자 확인 완료, 2026-09-04):
  - `issue-audit/tests/run-tests.sh`의 사본 대조(83~98행)가 git-review 헬퍼의 매트릭스 출력을 issue-audit 헬퍼 출력과 문자열 동등 비교한다. 이모지 접두가 붙으면 이 대조가 실패해 repo 전체 러너 통과가 깨진다. issue-audit 헬퍼·SKILL.md는 손대지 않고, 이 러너의 비교 직전에 git-review 출력의 접두만 걷어내는 정규화를 R6에 넣었다. 등급 문자열에는 공백이 없으므로 "공백이 있으면 첫 공백까지 제거"로 충분하다.
- audit 보정으로 정한 범위 (2026-09-05, 1차 교차모델 audit 발견 F-1 대응. `--response` 항목별 승인 완료):
  - 모드 혼용 검사를 축 옵션의 **값**이 아니라 **등장 여부**로 판정한다. `impact_set`·`likelihood_set` 플래그를 두고 파싱 루프에서 세운다. 값 기준 검사는 빈 문자열을 옵션 미지정과 같게 보아 `--impact '' --verdict …`가 판정을 산출했다.
  - 같은 전환을 `--status` 혼용 검사에도 함께 적용한다. `--status` 쪽 빈 값 문제는 `main` 시점부터 있던 기존 동작이지만, 같은 파싱 루프의 같은 변수를 쓰므로 한쪽만 고치면 헬퍼 안에 두 판정 방식이 공존해 이웃 변형이 다음 감사에서 재발한다. 스펙 제외 목록에 걸리지 않고 변경량은 조건식 1개다.
  - 사용오류의 판정에 **표준 출력 공집합**을 포함한다. 종료 코드만 보면 산출값이 함께 나오는 경로를 잡지 못하고, 호출자가 그 값을 읽어 쓴다. 러너의 `assert_usage_error`도 같은 기준으로 강화했다.

- 러너 `ok` 행 접두 고정값 (R6 검증 앵커): `대응표 추출`, `판정: `, `입력 호환: `. git-review 러너의 기존 접두 관례(`매트릭스: `, `상태: `, `사용오류: `)를 따른다.
- 헬퍼 확인 결과 (2026-09-04): git-review 헬퍼 출력을 소비하는 다른 스크립트는 issue-audit 러너의 사본 대조뿐이다. `git-pr-feedback`·`git-review-quiz`·`git-review-context`는 결과 파일 형식을 파싱하지 않는다.
- 이 repo의 스킬 실행본은 install-skills로 홈 경로(`~/.claude/skills/`)에 설치된 사본이다. repo 파일 수정 후 재설치 전까지 실행본과 차이가 나는 것은 정상이며, 이번 작업 대상은 repo 파일이다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| [GitHub 이슈 #96](https://github.com/scroogy-dev/scroogy-agent-skills/issues/96) | 배경·결정 사항·새 형식 예시의 SSoT |
| `git-review/SKILL.md` | 판정 산출 소절·이모지 대응표·결과 기록 형식·접기 기준 갱신 대상 |
| `git-review/templates/review-result-template.md` | 결과 산출물 형식의 SSoT, 개편 대상 |
| `git-review/scripts/classify-risk.sh` · `git-review/tests/run-tests.sh` | 이모지 출력·`--verdict`·입력 호환 구현과 회귀 검사 |
| `issue-audit/tests/run-tests.sh` | 사본 대조 정규화 대상 (헬퍼·SKILL.md는 불변) |
| `.ai/AI-CONTEXT.md` | git-review scripts 설명 행 갱신 대상 |
| `.ai/70_ledger/active/K-0002-audit-axis-tiebreak-absent.md` | 매트릭스 불변 경계의 근거 (재검토 조건 비발동 확인) |
| `.ai/10_rules/architecture.md` | 결정화 판단 기준 (`--verdict`를 헬퍼에 두는 근거) |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 헬퍼·테스트 배치 규칙 |
| `.ai/10_rules/writing-principles.md` | 최종 의견 접기 해석의 대조 기준 ("액션 아이템 접기 금지") |
