# Issue #98 스펙 issue-audit: 감사 리포트에 신호등 판정 한 줄·항목별 판정·위험도 이모지와 종합 의견 접기 도입

## 목표 (Goal)

감사 리포트를 열면 `## 종합 의견` 첫 줄의 신호등 판정으로 적합 여부가 읽히고, 1단계 항목 판정과 2단계 위험도 등급의 심각도가 이모지로 구분되며, 판정·상태·이모지는 감사인이 고르지 않고 헬퍼가 산출하게 한다.

---

## 요구사항 (Requirements)

**포함**

- R1: 헬퍼 `--verdict <1단계 상태> <2단계 상태>`가 두 상태의 최고값으로 판정 3종(🟢 적합(PASS) / 🟡 조건부 적합(CONDITIONAL) / 🔴 부적합(FAIL))을 산출한다. 위치 인자 정확히 2개, 순서 무관이며 판정 불가(N/A)는 판정에 영향을 주지 않는다. 리포트 `## 종합 의견` 헤더 바로 아래 첫 줄에 이 출력이 오고, 판정을 뺀 종합 판단·후속 액션은 접힌다.
- R2: 헬퍼 `--compliance <판정...>`이 1단계 항목 판정 값의 최고값(미충족(FAIL) > 부분 충족(PARTIAL) > 충족(PASS))으로 1단계 상태를 산출한다. 판정 불가(N/A)는 상태를 올리지 않고 항목 전부가 판정 불가일 때만 ⚪ 판정 불가(N/A)가 나온다. 값 하나를 넘기면 그 항목의 라벨이 나오고, 인자 0개는 사용오류다.
- R3: 헬퍼 `--status [등급...]`이 최고 위험도로 2단계 상태(🔴 보완 필요(FAIL) / 🟡 주의(WARN) / 🟢 통과(PASS))를 산출하고, 인자가 없으면 통과(PASS)를 낸다.
- R4: 매트릭스 출력(`--impact`·`--likelihood`)이 `<이모지> <등급>`이고, 값 입력 모드 4종(`--treatment`·`--compliance`·`--status`·`--verdict`)이 대응표 접두 4종(`🔴 `·`🟡 `·`🟢 `·`⚪ `)이 붙은 값과 붙지 않은 값을 모두 받는다. 그 밖의 접두는 종료 코드 2다. `--treatment` 출력은 처리 문구 그대로다.
- R5: 모드 혼용 검사가 축 옵션(`--impact`·`--likelihood`)의 등장 여부로 판정해 빈 축 값도 거부하고, 값 모드 4종 간 혼용도 거부하며, 모든 사용오류가 종료 코드 2와 표준 출력 공집합을 함께 보장한다.
- R6: SKILL.md에 상태 산출·판정 산출 소절(1단계·2단계 상태 규칙, 판정 표, 판정 의미, 헬퍼 사용 예), 이모지 대응표 14행(적합성 4·등급 4·상태 3·판정 3), 갱신된 헬퍼 예시 출력, 결과 기록의 판정 한 줄·종합 의견 접기 해석·상태·등급 표기 위치, 출력 요약 형식의 첫 줄 판정이 기재된다.
- R7: 리포트 템플릿이 `## 종합 의견` 헤더를 유지한 채 그 아래 판정 자리표시자와 종합 의견 접기를 두고, 요약 1단계·2단계 줄이 `<이모지> <상태> · <텍스트 건수>` 형식이며, 1단계 표 판정 열·발견 사항 표 위험도 열·상세 분석 위험도 필드가 헬퍼 출력을 그대로 쓴다고 안내한다.
- R8: issue-audit 러너가 SKILL.md 표에서 기대값을 추출하는 방식을 유지한 채 이모지 출력·`--compliance`·`--status`·`--verdict`·입력 호환·사용오류(빈 축 값 혼용 포함)·템플릿 구조 스모크(판정 자리표시자 위치·종합 의견 접기)를 검사하고, 사본 대조가 접두를 걷어내지 않고 git-review 헬퍼 출력과 전체를 비교하며, `.ai/AI-CONTEXT.md`의 issue-audit scripts 행이 상태·판정 산출을 반영한다.

**제외**

- 위험도 매트릭스·축 값·정의·등급별 처리 표 값 변경: 원장 K-0002의 재검토 조건을 발동시키지 않는다.
- 이전 발견 추적 표의 닫힘/잔여 이모지: 잔여는 발견 사항 표에 `F-n 잔여` 계보로 다시 올라와 등급 색을 받는다.
- 요약 카테고리 표의 상태 열 추가: 2단계 상태 줄로 충분하다.
- `#### F-<번호>: <제목>` 헤더의 이모지: 발견 사항 표 위험도 열과 상세 분석 위험도 필드가 색을 맡는다.
- issue-work `--response`·summary Task N 기록 변경: 등급에 접두가 붙어도 읽는 데 지장이 없다.
- git-review 헬퍼·SKILL.md·템플릿 변경: #96에서 완료했고 이번 이슈는 issue-audit 쪽 정렬이다.
- `.ai/10_rules/writing-principles.md` 변경: ai-workspace 동기화 대상이라 이 repo에서 직접 고치지 않는다.
- 기존 감사 리포트 소급 개정: 신규 감사부터 적용한다.

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

### R1: 판정 한 줄

- [ ] [D] 헬퍼 `--verdict`가 1단계 상태와 2단계 상태의 최고값으로 판정 3종을 산출하고 순서 무관이며 판정 불가(N/A)가 판정을 바꾸지 않는다. 인자 개수가 2가 아니거나, 상태가 아닌 값이거나, 두 인자가 같은 단계의 값이면 종료 코드 2이고 표준 출력에 판정이 없다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  C=issue-audit/scripts/classify-risk.sh
  v() { "$C" --verdict "$@" 2>/dev/null; }
  [ "$(v '충족(PASS)' '통과(PASS)')" = '🟢 적합(PASS)' ]                        || echo '위반: 충족+통과'
  [ "$(v '판정 불가(N/A)' '통과(PASS)')" = '🟢 적합(PASS)' ]                    || echo '위반: N/A+통과'
  [ "$(v '부분 충족(PARTIAL)' '통과(PASS)')" = '🟡 조건부 적합(CONDITIONAL)' ]   || echo '위반: 부분 충족+통과'
  [ "$(v '주의(WARN)' '충족(PASS)')" = '🟡 조건부 적합(CONDITIONAL)' ]            || echo '위반: 주의+충족(역순)'
  [ "$(v '판정 불가(N/A)' '주의(WARN)')" = '🟡 조건부 적합(CONDITIONAL)' ]        || echo '위반: N/A+주의'
  [ "$(v '미충족(FAIL)' '통과(PASS)')" = '🔴 부적합(FAIL)' ]                      || echo '위반: 미충족+통과'
  [ "$(v '보완 필요(FAIL)' '부분 충족(PARTIAL)')" = '🔴 부적합(FAIL)' ]           || echo '위반: 보완 필요+부분 충족(역순)'
  u() { local o r; o="$("$C" "$@" 2>/dev/null)"; r=$?; { [ "$r" -eq 2 ] && [ -z "$o" ]; } || echo "위반: 사용오류 아님 — $*"; }
  u --verdict
  u --verdict '충족(PASS)'
  u --verdict '충족(PASS)' '통과(PASS)' '통과(PASS)'
  u --verdict '적합' '통과(PASS)'
  u --verdict '충족(PASS)' '미충족(FAIL)'
  u --verdict '통과(PASS)' '주의(WARN)'
  ```

  - 설계 주의: 기대값은 GitHub 이슈 #98 결정 사항의 확정값이다. 순서 무관(최고값)임을 1단계 값이 앞인 조합과 2단계 값이 앞인 조합 양쪽으로 확인한다. 같은 단계 2개 거부는 `## 전제`에서 정한 값이다.
  - 설계 주의: 축 옵션·다른 값 모드와의 혼용은 R5 항목이 전수로 센다. 여기서는 `--verdict` 고유의 인자 규칙만 본다.
  </details>
- [ ] [D] 템플릿의 `## 종합 의견` 헤더가 1개이고, 그 아래에 판정 자리표시자 → 접기 시작 → 접기 제목 `종합 의견 펼치기` → `## 요약` 순서로 각각 1개씩 있으며, 종합 의견과 요약 사이에 다른 H2가 없다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=issue-audit/templates/issue-audit-report-template.md
  [ "$(grep -cE '^## 종합 의견$' "$T")" -eq 1 ]                        || echo '위반: 종합 의견 헤더 1개 아님'
  [ "$(grep -cE '^<판정>$' "$T")" -eq 1 ]                               || echo '위반: 판정 자리표시자 1개 아님'
  [ "$(grep -cF '<summary>종합 의견 펼치기</summary>' "$T")" -eq 1 ]     || echo '위반: 종합 의견 접기 1개 아님'
  h=$(grep -nE '^## 종합 의견$' "$T" | cut -d: -f1 | head -1)
  v=$(grep -nE '^<판정>$' "$T" | cut -d: -f1 | head -1)
  o=$(grep -nF '<summary>종합 의견 펼치기</summary>' "$T" | cut -d: -f1 | head -1)
  s=$(grep -nE '^## 요약$' "$T" | cut -d: -f1 | head -1)
  d=$(awk -v from="${v:-0}" 'NR > from && /^<details>$/ { print NR; exit }' "$T")
  { [ -n "$h" ] && [ -n "$v" ] && [ -n "$o" ] && [ -n "$s" ] && [ -n "$d" ] \
    && [ "$h" -lt "$v" ] && [ "$v" -lt "$d" ] && [ "$d" -lt "$o" ] && [ "$o" -lt "$s" ]; } \
    || echo "위반: 종합 의견($h) → 판정($v) → 접기 시작($d) → 접기 제목($o) → 요약($s) 순서 아님"
  { [ -n "$h" ] && [ -n "$s" ] && [ "$(sed -n "${h},${s}p" "$T" | grep -cE '^## ')" -eq 2 ]; } \
    || echo '위반: 종합 의견과 요약 사이에 다른 H2 존재'
  ```

  - 설계 주의: 행 앵커(`^## 종합 의견$`, `^<판정>$`, `^<details>$`, summary 태그, `^## 요약$`)의 행 번호 순서를 센다. 문구 검색은 안내 주석에도 걸리므로 쓰지 않는다. 판정이 접기 안으로 들어가면 `v < d` 조건이 깨진다. 자리표시자 이름은 `<판정>`으로 고정한다 (`## 전제` 참조).
  </details>

### R2: 1단계 상태

- [ ] [D] 헬퍼 `--compliance`가 값 하나에는 그 항목의 라벨을, 여러 값에는 서열 최고값을 `<이모지> <판정>` 형식으로 내고, 판정 불가(N/A)는 다른 값이 하나라도 있으면 묻히며 전부 판정 불가일 때만 나온다. 인자 0개·미지 값은 종료 코드 2이고 표준 출력이 비어 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  C=issue-audit/scripts/classify-risk.sh
  c() { "$C" --compliance "$@" 2>/dev/null; }
  [ "$(c '충족(PASS)')" = '🟢 충족(PASS)' ]                                          || echo '위반: 단일 충족'
  [ "$(c '미충족(FAIL)')" = '🔴 미충족(FAIL)' ]                                       || echo '위반: 단일 미충족'
  [ "$(c '부분 충족(PARTIAL)')" = '🟡 부분 충족(PARTIAL)' ]                           || echo '위반: 단일 부분 충족'
  [ "$(c '판정 불가(N/A)')" = '⚪ 판정 불가(N/A)' ]                                   || echo '위반: 단일 판정 불가'
  [ "$(c '충족(PASS)' '충족(PASS)' '판정 불가(N/A)')" = '🟢 충족(PASS)' ]             || echo '위반: N/A가 상태를 바꿈'
  [ "$(c '판정 불가(N/A)' '판정 불가(N/A)')" = '⚪ 판정 불가(N/A)' ]                  || echo '위반: 전부 N/A'
  [ "$(c '충족(PASS)' '부분 충족(PARTIAL)' '충족(PASS)')" = '🟡 부분 충족(PARTIAL)' ]  || echo '위반: 부분 충족 포함'
  [ "$(c '부분 충족(PARTIAL)' '미충족(FAIL)' '판정 불가(N/A)')" = '🔴 미충족(FAIL)' ]  || echo '위반: 미충족 포함'
  [ "$(c '충족(PASS)' '충족(PASS)' '충족(PASS)' '미충족(FAIL)')" = '🔴 미충족(FAIL)' ] || echo '위반: 충족 다수 + 미충족 1건'
  u() { local o r; o="$("$C" "$@" 2>/dev/null)"; r=$?; { [ "$r" -eq 2 ] && [ -z "$o" ]; } || echo "위반: 사용오류 아님 — $*"; }
  u --compliance
  u --compliance '통과(PASS)'
  u --compliance '충족(PASS)' '높음(HIGH)'
  ```

  - 설계 주의: 판정 불가(N/A)를 서열 최하위(0)로 두면 별도 분기 없이 "다른 값이 있으면 묻히고 전부 N/A일 때만 N/A"가 성립한다. 2단계 상태 값(`통과(PASS)`)·등급 값(`높음(HIGH)`)은 1단계 판정이 아니므로 미지 값이다.
  </details>

### R3: 2단계 상태

- [ ] [D] 헬퍼 `--status`가 최고 위험도로 2단계 상태 3종을 `<이모지> <상태>` 형식으로 내고, 인자 없음·낮음(LOW) 이하는 통과(PASS)다. 미지 값은 종료 코드 2이고 표준 출력이 비어 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  C=issue-audit/scripts/classify-risk.sh
  [ "$("$C" --status)" = '🟢 통과(PASS)' ]                                          || echo '위반: 발견 없음'
  [ "$("$C" --status '정보(INFO)')" = '🟢 통과(PASS)' ]                             || echo '위반: 정보만'
  [ "$("$C" --status '낮음(LOW)' '정보(INFO)')" = '🟢 통과(PASS)' ]                  || echo '위반: 낮음 이하'
  [ "$("$C" --status '낮음(LOW)' '중간(MEDIUM)')" = '🟡 주의(WARN)' ]                || echo '위반: 중간 포함'
  [ "$("$C" --status '정보(INFO)' '높음(HIGH)' '중간(MEDIUM)')" = '🔴 보완 필요(FAIL)' ] || echo '위반: 높음 포함'
  [ "$("$C" --status '낮음(LOW)' '낮음(LOW)' '높음(HIGH)')" = '🔴 보완 필요(FAIL)' ]  || echo '위반: 낮음 다수 + 높음 1건'
  u() { local o r; o="$("$C" "$@" 2>/dev/null)"; r=$?; { [ "$r" -eq 2 ] && [ -z "$o" ]; } || echo "위반: 사용오류 아님 — $*"; }
  u --status '치명적'
  u --status '충족(PASS)'
  ```

  - 설계 주의: 규칙과 기대값은 git-review `--status`와 같다 (#96 확정값 재사용). 1단계 판정 값(`충족(PASS)`)은 등급이 아니므로 미지 값이다.
  </details>

### R4: 이모지 출력·입력 호환

- [ ] [D] 헬퍼의 매트릭스 6조합 출력이 `<이모지> <등급>` 형식으로 이슈 확정값과 일치한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  C=issue-audit/scripts/classify-risk.sh
  g() { "$C" --impact "$1" --likelihood "$2" 2>/dev/null; }
  [ "$(g '스펙·기능 달성 차단' '통상 사용')" = '🔴 높음(HIGH)' ]      || echo '위반: 차단×통상'
  [ "$(g '스펙·기능 달성 차단' '특수 조건·엣지')" = '🟡 중간(MEDIUM)' ] || echo '위반: 차단×엣지'
  [ "$(g '기능 저하' '통상 사용')" = '🟡 중간(MEDIUM)' ]             || echo '위반: 저하×통상'
  [ "$(g '기능 저하' '특수 조건·엣지')" = '🟢 낮음(LOW)' ]            || echo '위반: 저하×엣지'
  [ "$(g '기술 품질 의견' '통상 사용')" = '🟢 낮음(LOW)' ]            || echo '위반: 의견×통상'
  [ "$(g '기술 품질 의견' '특수 조건·엣지')" = '⚪ 정보(INFO)' ]       || echo '위반: 의견×엣지'
  ```

  - 설계 주의: 등급 텍스트는 현행과 같고 이모지만 앞에 붙는다. 매트릭스 표 자체는 바뀌지 않으므로 6조합 전수를 그대로 대조한다.
  </details>
- [ ] [D] 값 모드 4종이 이모지 접두 유무와 무관하게 같은 결과를 내고, `--treatment` 출력은 처리 문구 그대로이며, 대응표에 없는 접두는 네 모드 모두 종료 코드 2로 거른다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  C=issue-audit/scripts/classify-risk.sh
  [ "$("$C" --treatment '🟡 중간(MEDIUM)')" = '`--response` 승인 게이트에서 사용자 판단' ]           || echo '위반: --treatment 접두 입력'
  [ "$("$C" --treatment '높음(HIGH)')" = '보정 필수 → 재검증 대상' ]                                 || echo '위반: --treatment 출력이 처리 문구가 아님'
  [ "$("$C" --compliance '🔴 미충족(FAIL)' '충족(PASS)')" = '🔴 미충족(FAIL)' ]                     || echo '위반: --compliance 접두·비접두 혼합'
  [ "$("$C" --status '🟡 중간(MEDIUM)' '⚪ 정보(INFO)')" = '🟡 주의(WARN)' ]                        || echo '위반: --status 접두 입력'
  [ "$("$C" --verdict '🟡 부분 충족(PARTIAL)' '🟡 주의(WARN)')" = '🟡 조건부 적합(CONDITIONAL)' ]   || echo '위반: --verdict 접두 입력'
  [ "$("$C" --verdict '⚪ 판정 불가(N/A)' '통과(PASS)')" = '🟢 적합(PASS)' ]                        || echo '위반: --verdict 접두·비접두 혼합'
  u() { local o r; o="$("$C" "$@" 2>/dev/null)"; r=$?; { [ "$r" -eq 2 ] && [ -z "$o" ]; } || echo "위반: 사용오류 아님 — $*"; }
  u --treatment '🔵 중간(MEDIUM)'
  u --compliance '🔵 충족(PASS)'
  u --status '🔵 높음(HIGH)'
  u --verdict '🔵 충족(PASS)' '통과(PASS)'
  ```

  - 설계 주의: "같은 결과"를 두 호출의 출력 비교로 판정하면 둘 다 빈 출력(오류)일 때 통과한다. 기대값을 직접 적는다. `--treatment` 기대값은 SKILL.md 등급별 처리 표의 셀 전문이다.
  </details>

### R5: 모드 혼용·사용오류

- [ ] [D] 축 옵션 2종 × 값 형태(빈 값·일반 값) × 값 모드 4종 × 배치(전치·후치)의 혼용 전수, 값 모드 4종 간 혼용 전수, 축 모드의 빈 값·미지 값·인자 누락·미지 옵션이 모두 종료 코드 2이고 표준 출력이 비어 있다. 모드 혼용은 축 옵션의 **등장 여부**로 판정하므로 값이 빈 문자열이어도 거부된다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  C=issue-audit/scripts/classify-risk.sh
  u() { local o r; o="$("$C" "$@" 2>/dev/null)"; r=$?; { [ "$r" -eq 2 ] && [ -z "$o" ]; } || echo "위반: 사용오류 아님 — $*"; }
  modes=( '--treatment|높음(HIGH)' '--compliance|충족(PASS)' '--status|높음(HIGH)' '--verdict|충족(PASS)|통과(PASS)' )
  for pair in '--impact|기능 저하' '--likelihood|통상 사용'; do
    opt="${pair%%|*}"
    for val in '' "${pair#*|}"; do
      for m in "${modes[@]}"; do
        IFS='|' read -r -a call <<< "$m"
        u "$opt" "$val" "${call[@]}"
        u "${call[@]}" "$opt" "$val"
      done
    done
  done
  for a in "${modes[@]}"; do
    for b in "${modes[@]}"; do
      [ "$a" = "$b" ] && continue
      IFS='|' read -r -a ca <<< "$a"; IFS='|' read -r -a cb <<< "$b"
      u "${ca[@]}" "${cb[@]}"
    done
  done
  u --impact '' --likelihood '통상 사용'
  u --impact '기능 저하' --likelihood ''
  u --impact ''
  u --impact '심각' --likelihood '통상 사용'
  u --impact '기능 저하' --likelihood '가끔'
  u --likelihood '통상 사용'
  u --impact '기능 저하'
  u
  u --grade '높음(HIGH)'
  ```

  - 설계 주의: 불변식 전수로 센다. 값이 있는 조합만 검사하면 빈 문자열이 옵션 미지정과 같아져 혼용이 통과한다 (#96 audit F-1과 같은 결함이 현행 `--treatment` 검사에 남아 있다). 종료 코드와 함께 표준 출력 공집합도 보는 이유는, 사용오류인데 산출값이 나오면 호출자가 그 값을 읽어 쓰기 때문이다.
  - 설계 주의: `--compliance`·`--status`·`--verdict`는 뒤따르는 인자를 전부 위치 인자로 흡수하므로, 후치 조합은 개수 위반이나 미지 값으로 걸린다. 배치가 달라도 거부는 같아야 한다.
  </details>

### R6: SKILL.md 규칙

- [ ] [D] `### 3단계: 결과 기록` 아래에 `#### 상태 산출`·`#### 판정 산출` 소절이 그 순서로 있고, 2단계 상태 표(데이터 3행)·판정 표(데이터 3행)·이모지 대응표(적합성 4·등급 4·상태 3·판정 3 = 데이터 14행, 값 14종 상이, 이모지 값은 🔴🟡🟢⚪ 중 하나)가 있으며, 판정 표 최고 상태 셀의 값이 전부 대응표에 있고, 헬퍼 예시 출력이 이모지 포함 값이며, 출력 요약 형식이 판정 한 줄로 시작한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  S=issue-audit/SKILL.md
  for h in '#### 상태 산출' '#### 판정 산출'; do
    [ "$(grep -cxF "$h" "$S")" -eq 1 ] || echo "위반: '$h' 헤더 1개 아님"
  done
  t3=$(grep -nE '^### 3단계: 결과 기록$' "$S" | cut -d: -f1 | head -1)
  ss=$(grep -nxF '#### 상태 산출' "$S" | cut -d: -f1 | head -1)
  vs=$(grep -nxF '#### 판정 산출' "$S" | cut -d: -f1 | head -1)
  nx=$(awk -v from="${t3:-0}" 'NR > from && /^##(#)? / { print NR; exit }' "$S")
  { [ -n "$t3" ] && [ -n "$ss" ] && [ -n "$vs" ] && [ -n "$nx" ] \
    && [ "$t3" -lt "$ss" ] && [ "$ss" -lt "$vs" ] && [ "$vs" -lt "$nx" ]; } \
    || echo "위반: 3단계($t3) → 상태 산출($ss) → 판정 산출($vs) → 다음 섹션($nx) 배치 아님"
  n=$(awk '/^\| *최고 위험도 *\| *상태 *\|/{f=1;next} f&&/^\|/{n++;next} f{exit} END{print n+0}' "$S")
  [ "$n" -eq 4 ] || echo "위반: 2단계 상태 표 행 수 $n (구분선 1 + 데이터 3 기대)"
  n=$(awk '/^\| *최고 상태 *\| *판정 *\|/{f=1;next} f&&/^\|/{n++;next} f{exit} END{print n+0}' "$S")
  [ "$n" -eq 4 ] || echo "위반: 판정 표 행 수 $n (구분선 1 + 데이터 3 기대)"
  rows=$(awk '/^\*\*이모지 대응표\*\*/{f=1;next} f&&/^\|/{print;n++;next} f&&n{exit}' "$S")
  data=$(printf '%s\n' "$rows" | tail -n +3)
  [ "$(printf '%s\n' "$data" | grep -c '^|')" -eq 14 ] || echo '위반: 대응표 데이터 14행 아님'
  for k in '적합성:4' '등급:4' '상태:3' '판정:3'; do
    c=$(printf '%s\n' "$data" | grep -c "^| ${k%%:*} |"); [ "$c" -eq "${k##*:}" ] || echo "위반: 대응표 ${k%%:*} 행 ${c}개"
  done
  printf '%s\n' "$data" | grep '^|' | awk -F'|' '{print $4}' | sed 's/ //g' | grep -vxE '🔴|🟡|🟢|⚪' | sed 's/^/위반: 이모지 값 /'
  vals=$(printf '%s\n' "$data" | grep '^|' | awk -F'|' '{v=$3; gsub(/^ +| +$/,"",v); print v}')
  [ "$(printf '%s\n' "$vals" | sort -u | grep -c .)" -eq 14 ] || echo '위반: 대응표 값 14종이 서로 다르지 않음'
  awk '/^\| *최고 상태 *\| *판정 *\|/{f=1;next} f&&/^\|/{if(++n>1){c=$0; sub(/^\|/,"",c); sub(/\|.*$/,"",c); gsub(/ · /,"\n",c); print c}; next} f{exit}' "$S" \
    | sed 's/^ *//; s/ *$//' | grep -v '^$' \
    | while read -r v; do printf '%s\n' "$vals" | grep -qxF "$v" || echo "위반: 판정 표 값 '$v'가 대응표에 없음"; done
  grep -qF '# → 🟡 중간(MEDIUM)' "$S" || echo '위반: 매트릭스 예시 출력에 이모지 없음'
  grep -nE '# → (높음\(HIGH\)|중간\(MEDIUM\)|낮음\(LOW\)|정보\(INFO\))' "$S" | sed 's/^/위반: 이모지 없는 예시 출력 /'
  o=$(grep -nE '^## 출력 요약 형식$' "$S" | cut -d: -f1 | head -1)
  p=$(awk -v from="${o:-0}" 'NR > from && /^<판정>$/ { print NR; exit }' "$S")
  q=$(awk -v from="${o:-0}" 'NR > from && /^### 1단계: 적합성 검증$/ { print NR; exit }' "$S")
  { [ -n "$o" ] && [ -n "$p" ] && [ -n "$q" ] && [ "$p" -lt "$q" ]; } || echo '위반: 출력 요약 형식이 판정 한 줄로 시작하지 않음'
  ```

  - 설계 주의: 판정 표는 `| 최고 상태 | 판정 |` 헤더 행, 2단계 상태 표는 `| 최고 위험도 | 상태 |` 헤더 행, 대응표는 `**이모지 대응표**` 볼드 행을 앵커로 잡고 그 다음 연속된 표 행만 센다. 표 열 구성과 판정 표 셀의 ` · ` 나열 형식은 `## 전제`에서 고정한다.
  - 설계 주의: 값 14종 상이 검사는 러너 `emoji_of`와 헬퍼 `emoji`가 구분 열 없이 값만으로 조회하는 전제를 지킨다. 값이 겹치면 조회가 어느 구분의 이모지를 돌려줄지 정해지지 않는다.
  </details>
- [ ] [QD] 상태 산출·판정 산출 소절이 1단계 상태 규칙(항목 판정 값을 그대로 상태로 쓰고 서열 최고값, 판정 불가(N/A)는 올리지 않으며 전부 판정 불가일 때만 판정 불가), 2단계 상태 규칙, 판정 규칙(감사인이 고르지 않고 두 상태의 최고값)과 판정 3종의 의미(부적합은 스펙 미충족 또는 보정 필수 발견 있음, 조건부 적합은 `--response` 승인 게이트에서 사용자 판단이 필요한 항목 있음, 적합은 보정 대상이 없어 Task N을 닫을 수 있음), 판정은 우선순위 신호이고 실제 처리는 issue-work `--response`의 항목별 승인이 정한다는 문장, 헬퍼 사용 예를 담는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 서술 충분성은 의미 판단이라 명령으로 환원 불가
- [ ] [QD] 3단계 결과 기록·산출물 접기 기준이 판정 한 줄을 `--verdict` 출력 그대로 적는 규칙, 종합 의견 접기가 "액션 아이템 접기 금지"와 충돌하지 않는 해석(판정 한 줄이 밖에 있고 발견 제목·권장 조치가 본문에 남음), 상태·등급 표기 위치 4곳(요약 1단계·2단계 줄, 1단계 표 판정 열, 발견 사항 표 위험도 열, 상세 분석 위험도 필드)에 헬퍼 출력을 그대로 쓴다는 규칙, 요약 건수·카테고리 표 건수는 텍스트 등급만 쓴다는 규칙, 대화창 보고가 판정 한 줄로 시작한다는 규칙을 담고, 위험도 매트릭스·등급별 처리·상태·판정 표의 셀에 이모지가 들어가지 않았다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 위와 같음

### R7: 리포트 템플릿

- [ ] [D] 요약 1단계·2단계 줄이 `<이모지> <상태> · <텍스트 건수>` 형식이고, 상세 분석 위험도 필드가 `<이모지> <등급>` 자리표시자이며, 1단계 섹션에 `<이모지> <판정>`과 `--compliance` 안내가, 2단계 섹션에 `<이모지> <등급>` 안내가 있고, 옛 위험도 필드 형식과 카테고리 표 건수 열의 이모지 미표기 안내 누락이 없으며, H2 집합·순서가 현행과 같다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=issue-audit/templates/issue-audit-report-template.md
  grep -qE '^- 1단계 적합성: <이모지> <상태> · 충족\(PASS\) N건 / 미충족\(FAIL\) N건 / 부분 충족\(PARTIAL\) N건 / 판정 불가\(N/A\) N건$' "$T" || echo '위반: 요약 1단계 줄'
  grep -qE '^- 2단계 위험도: <이모지> <상태> · 높음\(HIGH\) N건 / 중간\(MEDIUM\) N건 / 낮음\(LOW\) N건 / 정보\(INFO\) N건$' "$T" || echo '위반: 요약 2단계 줄'
  grep -qE '^- \*\*위험도\*\*: <이모지> <등급>' "$T" || echo '위반: 상세 분석 위험도 필드'
  grep -nE '^- \*\*위험도\*\*: 높음\(HIGH\) / 중간\(MEDIUM\)' "$T" | sed 's/^/위반: 옛 위험도 필드 잔존 /'
  sec() { awk -v h="$1" '$0 == h { f = 1; next } /^## / { f = 0 } f' "$T"; }
  sec '## 1단계: 적합성 검증 (Compliance Check)' | grep -qF '<이모지> <판정>'  || echo '위반: 1단계 섹션에 판정 자리표시자 안내 없음'
  sec '## 1단계: 적합성 검증 (Compliance Check)' | grep -qF -- '--compliance' || echo '위반: 1단계 섹션에 --compliance 안내 없음'
  sec '## 2단계: 비판적 검증 (Critical Review)' | grep -qF '<이모지> <등급>'    || echo '위반: 2단계 섹션에 등급 자리표시자 안내 없음'
  grep -qE '^\| 기능 \|.*텍스트 등급만' "$T" || echo '위반: 카테고리 표 건수 열에 텍스트 등급 안내 없음'
  grep -E '^## ' "$T" | paste -sd'|' - \
    | grep -qxF '## 종합 의견|## 요약|## 1단계: 적합성 검증 (Compliance Check)|## 2단계: 비판적 검증 (Critical Review)' \
    || echo '위반: H2 집합·순서 불일치'
  ```

  - 설계 주의: 섹션 본문은 `^## ` 앵커로 잘라 섹션별 실재를 따로 센다. H2 집합은 #76 확정 구조 그대로이며 이번 이슈는 H2를 더하거나 빼지 않는다.
  </details>
- [ ] [QD] 템플릿 안내 주석이 판정은 헬퍼 `--verdict` 출력 그대로이고 감사인이 고르지 않는다는 점, 접기 안은 종합 판단·후속 액션 3문장 이내라는 점, 요약 상태는 `--compliance`·`--status` 출력 그대로라는 점, 1단계 판정 열은 값 하나를 넘긴 `--compliance` 출력이라는 점, 발견 사항 표 위험도 열·상세 분석 위험도 필드는 매트릭스 헬퍼 출력 그대로라는 점을 설명한다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 주석 서술의 충분성은 의미 판단이라 명령으로 환원 불가

### R8: 테스트·안내도 정합

- [ ] [D] issue-audit 러너가 통과하고, 대응표 추출·1단계 상태·2단계 상태·판정·입력 호환·리포트 구조 케이스를 `ok` 행으로 보고하며, 사본 대조가 이모지를 포함한 전체 일치로 보고되고, 빈 축 값 혼용과 판정 자리표시자 구조 케이스가 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  out=$(issue-audit/tests/run-tests.sh 2>&1); rc=$?
  [ "$rc" -eq 0 ] || { echo "위반: issue-audit 러너 exit $rc"; printf '%s\n' "$out" | grep 'NOT OK'; }
  for p in '대응표 추출' '1단계 상태: ' '2단계 상태: ' '판정: ' '입력 호환: ' '리포트 구조: '; do
    printf '%s\n' "$out" | grep -qE "^ok     - $p" || echo "위반: 러너에 '$p' 케이스 없음"
  done
  printf '%s\n' "$out" | grep -qF 'ok     - 사본 대조: git-review classify-risk.sh 와 매트릭스·이모지 일치' \
    || echo '위반: 사본 대조가 이모지 포함 일치로 보고되지 않음'
  printf '%s\n' "$out" | grep -qE '^ok     - 사용오류: .*빈 값' || echo '위반: 러너에 빈 축 값 혼용 케이스 없음'
  printf '%s\n' "$out" | grep -qE '^ok     - 리포트 구조: .*판정' || echo '위반: 러너에 판정 자리표시자 구조 케이스 없음'
  ```

  - 설계 주의: 러너 통과만 보면 케이스를 지워도 통과한다. 케이스 종류별 `ok` 행 접두를 고정해 실재를 함께 센다 (접두 문자열은 `## 전제` 참조). git-review 사본이 없으면 러너가 "건너뜀"으로 통과하므로 "일치" 행의 실재를 따로 센다.
  </details>
- [ ] [D] 러너가 이모지 기대값을 리터럴로 갖지 않는다 (미지 접두 사용오류 케이스의 `🔵` 제외)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -nE '🔴|🟡|🟢|⚪' issue-audit/tests/run-tests.sh
  ```

  - 설계 주의: 기대값을 SKILL.md 표에서 추출한다는 방식 유지는 "러너에 이모지 리터럴 0건"으로 환원된다. 미지 접두 케이스는 대응표 밖 값(🔵)을 쓰므로 이 grep에 걸리지 않는다.
  </details>
- [ ] [D] `.ai/AI-CONTEXT.md`의 issue-audit 하위 scripts 행에 상태·판정 산출이 기재된다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  awk '/^├── issue-audit\//{f=1;next} /^├── /{f=0} f' .ai/AI-CONTEXT.md \
    | grep -E 'scripts/.*classify-risk\.sh' | grep -qF '판정' \
    || echo '위반: AI-CONTEXT issue-audit scripts 행에 판정 없음'
  ```

  - 설계 주의: `classify-risk.sh`는 git-review 행에도 있어 파일 전체 grep은 다른 행을 잡는다. issue-audit 블록만 잘라 본다.
  </details>

### 공통

- [ ] [D] repo 전체 스킬 러너가 통과한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D] 위험도 매트릭스·영향 축·발생확률 축·등급별 기본 처리 표의 행이 `main`과 같다 (제외 항목 경계, K-0002 재검토 조건 비발동)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  cur=issue-audit/SKILL.md
  old=$(mktemp); git show main:issue-audit/SKILL.md > "$old"
  tbl() { awk -v a="$2" 'index($0, a) == 1 { f = 1; next } f && /^\|/ { print; n++; next } f && n > 0 { exit }' "$1"; }
  same_tbl() {
    local a b; a="$(tbl "$old" "$1")"; b="$(tbl "$cur" "$1")"
    [ -n "$a" ] || { echo "위반: main에 $2 표 없음(앵커 불일치)"; return; }
    [ "$a" = "$b" ] || echo "위반: $2 표 변경"
  }
  same_tbl '**영향 × 발생확률 매트릭스**' '매트릭스'
  same_tbl '**영향 축**' '영향 축'
  same_tbl '**발생확률 축**' '발생확률 축'
  same_tbl '#### 등급별 기본 처리 기준' '등급별 처리'
  rm -f "$old"
  ```

  - 설계 주의: 표 행만 비교한다. 표 앞의 서술 문구는 이번 이슈에서 예시 출력 갱신으로 바뀌므로 파일 diff는 쓰지 않는다. 앵커가 사라져 양쪽이 비면 통과처럼 보이므로 `main` 쪽 실재를 먼저 확인한다.
  </details>
- [ ] [D] git-review 스킬 파일이 바뀌지 않는다 (제외 항목 경계)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  git diff --name-only main -- git-review/
  ```

  </details>

---

## 전제 (Assumptions)

- 설계 단계 결정 (2026-09-06, 이슈 본문의 확정값을 헬퍼·문서 구조로 옮기며 정한 값. Task 0에서 사용자 확인 완료 — 10항목 전부 확정값 그대로 진행):
  - `--verdict`는 위치 인자 정확히 2개이며 **1단계 상태 1개와 2단계 상태 1개**를 받는다. 순서는 무관하고, 두 인자가 같은 단계의 값이면(둘 다 1단계 판정이거나 둘 다 2단계 상태) 종료 코드 2다. 판정의 입력이 두 단계 상태로 고정되어 있어 같은 단계 2개는 호출 실수이기 때문이다. 판정 서열은 이모지 색으로 정한다. 🔴(미충족(FAIL)·보완 필요(FAIL)) 2 > 🟡(부분 충족(PARTIAL)·주의(WARN)) 1 > 🟢·⚪(충족(PASS)·판정 불가(N/A)·통과(PASS)) 0이며, 최고값 2는 부적합(FAIL), 1은 조건부 적합(CONDITIONAL), 0은 적합(PASS)이다. 판정 불가(N/A)가 판정에 영향을 주지 않는다는 이슈 규칙은 서열 0으로 성립한다.
  - `--compliance`는 위치 인자 1개 이상이며 서열은 미충족(FAIL) 3 > 부분 충족(PARTIAL) 2 > 충족(PASS) 1 > 판정 불가(N/A) 0이다. 최고값을 그대로 출력한다. 판정 불가(N/A)를 최하위에 두면 별도 분기 없이 "다른 값이 있으면 묻히고 전부 판정 불가일 때만 판정 불가"가 성립한다. 인자 0개는 사용오류다. 요구사항·DoD 대조가 항상 있어 1단계 항목이 0개인 감사는 성립하지 않는다 (`--status`가 0개를 "발견 없음"으로 받는 것과 다르다).
  - `--status`는 git-review와 같다. 0개 이상, 서열 높음(HIGH) 3 > 중간(MEDIUM) 2 > 낮음(LOW) 1 > 정보(INFO) 0, 3은 보완 필요(FAIL), 2는 주의(WARN), 그 밖은 통과(PASS).
  - 모드 혼용은 축 옵션의 **등장 여부**(`impact_set`·`likelihood_set` 플래그)로 판정하고, 값 모드 4종(`--treatment`·`--compliance`·`--status`·`--verdict`)이 둘 이상 등장해도 종료 코드 2다. 사용오류의 판정에 **표준 출력 공집합**을 포함한다 (#96 F-1 보정과 같은 기준). 현행 `--treatment` 혼용 검사가 값 기준이라 `--impact '' --treatment '높음(HIGH)'`가 종료 코드 0으로 처리 문구를 내는 결함이 이번에 함께 닫힌다.
  - 이모지의 SSoT는 SKILL.md의 `**이모지 대응표**` 한 곳이다. 표 열은 `| 구분 | 값 | 이모지 |`이고 구분 값은 적합성·등급·상태·판정 넷이며 데이터 14행이다. 대응표 값 14종은 서로 다른 문자열이라(충족(PASS)·통과(PASS)·적합(PASS)은 한글이 다르다) 헬퍼 `emoji`와 러너 `emoji_of`가 구분 열 없이 값만으로 조회한다. 위험도 매트릭스·등급별 처리·2단계 상태·판정 표의 셀 값은 텍스트로 유지한다 (논리 표와 표시 규칙의 분리, #96과 같은 결정).
  - 2단계 상태 표 헤더는 `| 최고 위험도 | 상태 |`(데이터 3행, git-review와 동일)다. 1단계 상태는 항목 판정 값을 그대로 쓰므로 별도 표 없이 서열 문장으로 적는다.
  - 판정 표 헤더는 `| 최고 상태 | 판정 |`(데이터 3행)이고, 최고 상태 셀에는 두 단계의 상태 값을 ` · `로 나열한다 (예: `미충족(FAIL) · 보완 필요(FAIL)`). 판정 열은 텍스트다. 러너 `verdict_for`는 셀을 ` · `로 나눠 값이 들어 있는 행을 찾는다. 1단계 × 2단계 조합 표(4 × 3)는 판정이 색만으로 정해지는 규칙을 12행으로 늘어놓는 것이라 두지 않는다.
  - 소절 배치는 `### 3단계: 결과 기록` 아래 `#### 상태 산출` → `#### 판정 산출`(판정 표·의미·헬퍼 예·이모지 대응표 포함) 순서이며, 3단계의 번호 목록은 헤더 바로 아래에 그대로 두고 두 소절을 앞에서 참조한다. 상태·판정은 두 단계를 마친 뒤 산출하므로 결과 기록 단계에 속하고, git-review처럼 H2로 두면 issue-audit의 `## 절차`(0~3단계 H3, 세부 H4) 구조와 어긋난다.
  - 템플릿의 판정 자리표시자는 `## 종합 의견` 헤더 다음 `<판정>` 한 줄이다. 종합 의견 본문은 `<details><summary>종합 의견 펼치기</summary>` 접기이며 헤더는 유지한다 (#76에서 `## 종합 의견` 명칭을 유지하기로 한 결정과 정합). 요약 줄은 `- 1단계 적합성: <이모지> <상태> · 충족(PASS) N건 / …`, `- 2단계 위험도: <이모지> <상태> · 높음(HIGH) N건 / …`이고, 상세 분석 위험도 필드는 `- **위험도**: <이모지> <등급>`이다. 카테고리 표 건수 열 안내에 "텍스트 등급만"을 넣는다 (#96 규칙).
  - `## 출력 요약 형식`은 `## Issue #<번호> 감사 결과 요약` 다음 줄에 `<판정>` 한 줄을 두고 그 밖은 현행을 유지한다. 이슈가 대화창 형식으로 정한 것은 첫 줄뿐이다.
  - 사본 대조는 정규화 1행(`case "$b" in *' '*) b="${b#* }" ;; esac`)을 걷어내고 두 헬퍼 출력을 전체 비교한다. `ok` 행 문구는 `사본 대조: git-review classify-risk.sh 와 매트릭스·이모지 일치`다.
- 구현 세부 (2026-09-06, Task 0에서 문서에 없어 구현 측이 정한 값):
  - 러너 `verdict_for`는 판정 표의 최고 상태 셀을 ` · `로 분할한 뒤 **정확 일치**로 행을 찾는다. 부분 문자열 매칭이면 `충족(PASS)`가 `부분 충족(PARTIAL)` 셀에도 걸려 조건부 적합 행을 잘못 고른다.
  - `--treatment`는 현행 `shift 2` 인자 처리(값 1개)를 유지하고 입력에만 `strip_emoji`를 적용한다. 흡수형으로 바꿀 이유가 없고, 흡수형 모드 뒤에 오는 `--treatment`는 위치 인자로 흡수되어 미지 값으로 종료 코드 2가 된다.
- 러너 `ok` 행 접두 고정값 (R8 검증 앵커): `대응표 추출`, `1단계 상태: `, `2단계 상태: `, `판정: `, `입력 호환: `, `사용오류: `, `리포트 구조: `. issue-audit 러너의 기존 접두 관례(`매트릭스: `, `등급별 처리: `, `사용오류: `, `사본 대조: `, `번호 계승: `, `리포트 구조: `)를 따른다.
- 헬퍼 확인 결과 (2026-09-06): issue-audit 헬퍼 출력을 소비하는 스크립트는 issue-audit 러너뿐이다. git-review 러너는 사본 대조를 하지 않으므로 issue-audit 변경이 git-review 러너에 영향을 주지 않는다. issue-work `--response`는 리포트를 자연어로 읽으며 등급 문자열을 파싱하지 않는다.
- 작업 순서상 Task 2(헬퍼) 뒤 Task 4(러너) 전에는 issue-audit 러너가 실패 상태다. 매트릭스 기대값에 이모지가 없고, 사본 대조가 git-review 출력의 접두만 걷어내 issue-audit 출력과 어긋나기 때문이다. plan에 명시된 계획 상태이며, repo 전체 러너 통과는 Task 4 완료 기준에서 본다.
- 이 repo의 스킬 실행본은 install-skills로 홈 경로(`~/.claude/skills/`)에 설치된 사본이다. repo 파일 수정 후 재설치 전까지 실행본과 차이가 나는 것은 정상이며, 이번 작업 대상은 repo 파일이다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| [GitHub 이슈 #98](https://github.com/scroogy-dev/scroogy-agent-skills/issues/98) | 배경·결정 사항·새 형식 예시의 SSoT |
| `issue-audit/SKILL.md` | 상태 산출·판정 산출 소절·이모지 대응표·결과 기록·출력 요약 형식 갱신 대상 |
| `issue-audit/templates/issue-audit-report-template.md` | 감사 리포트 형식의 SSoT, 개편 대상 |
| `issue-audit/scripts/classify-risk.sh` · `issue-audit/tests/run-tests.sh` | 이모지 출력·`--compliance`·`--status`·`--verdict`·입력 호환·모드 혼용 구현과 회귀 검사 |
| `git-review/SKILL.md` · `git-review/scripts/classify-risk.sh` · `git-review/tests/run-tests.sh` | #96 선례의 참조 구현 (판정 산출 소절·대응표·`emoji`/`strip_emoji`/`srank`·러너 추출 함수). 이번 이슈에서 불변 |
| `.ai/90_issues/archive/issue-0096/` | 선례 이슈 문서 (DoD 명령 형태·전제·audit F-1 보정 기준) |
| `.ai/AI-CONTEXT.md` | issue-audit scripts 설명 행 갱신 대상 |
| `.ai/70_ledger/active/K-0002-audit-axis-tiebreak-absent.md` | 매트릭스 불변 경계의 근거 (재검토 조건 비발동 확인) |
| issue-work `SKILL.md` `--response` 등급별 기본 제시값 표 | 판정 3종 의미의 대조 기준 (높음은 반영, 중간은 사용자 판단, 낮음·정보는 이관·보류) |
| `.ai/10_rules/architecture.md` | 결정화 판단 기준 (`--compliance`·`--status`·`--verdict`를 헬퍼에 두는 근거) |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 헬퍼·테스트 배치 규칙 |
| `.ai/10_rules/writing-principles.md` | 종합 의견 접기 해석의 대조 기준 ("액션 아이템 접기 금지") |
