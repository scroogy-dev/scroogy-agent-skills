# Issue #114 스펙 doc 프로파일에서 SSoT를 원본 문서(repo 지정 디렉토리)로 선언하고 스킬이 그 선언을 따르게 한다

## 목표 (Goal)

doc 프로파일 repo에서 SSoT 선언을 `AI-CONTEXT.md` 한 곳에 두고, ai-workspace·context-harvest·code-map과 색인 맥락 문구를 가진 스킬이 그 선언을 따라 repo 지정 디렉토리의 문서 파일을 SSoT로 다룬다. 위키·블로그 등으로 내보낸 사본은 퍼블리싱이며 SSoT도 출처도 아니다.

---

## 요구사항 (Requirements)

**포함**

- R1: 각 스킬은 SSoT를 `AI-CONTEXT.md` 2번째 줄의 선언에서 읽어 따르고, 선언을 찾지 못하면 지금 동작(소스 코드)을 유지한다.
- R2: ai-workspace doc 프로파일 산출물의 `AI-CONTEXT.md`는 2번째 줄에 doc용 선언(`> SSoT: 원본 문서. 이 파일은 안내도일 뿐 진실의 원천이 아니다.`)을 두고, 충돌 우선순위를 `원본 문서 > 이 repo 안내도 > 상위 워크스페이스 안내도`로 두며, `## 프로젝트 도메인` 표에 `ssot_dir` 행(필수)과 `publish` 행(선택)을 갖는다. dev 템플릿은 바뀌지 않는다.
- R3: `check-context.sh`와 update 검사는 dev·doc 두 표준 문구를 모두 통과시키고 그 외 문구만 교체 대상으로 판정하며, doc 선언이면 `## 프로젝트 도메인` 표의 `ssot_dir` 행이 있는지 검사한다(없으면 누락 보고, update가 자리표시자 행을 보강).
- R4: 버전 고정 파일 `context-loading.md`는 프로파일과 무관하게 `AI-CONTEXT.md`의 SSoT 선언을 따르는 문구를 쓰고, 원본 문서 작업 절(`60_codebase/index.md`로 대상 파일을 찾고 색인 행의 관련 문서 링크를 따라 `40_domain/`·`50_adr/`를 읽은 뒤 지정 디렉토리의 파일을 직접 읽어 확인하는 절차)을 갖는다.
- R5: `60_codebase/`는 "SSoT 색인"으로 정의된다. dev는 소스코드 엔트리포인트·호출 흐름, doc은 지정 디렉토리 문서 파일 지도다. shared `60_codebase/index.md`, doc 템플릿 `AI-CONTEXT.md`의 디렉토리 설명·진입 절차·작성 규칙, ai-workspace 스킬 소개 문구, context-harvest의 code-map 관계표가 이 정의를 쓴다.
- R6: context-harvest는 수집 필터를 "SSoT에 대응하지 않는 정보는 수집하지 않는다"로 일반화하고 SSoT는 선언을 따른다. 선언이 원본 문서이면 지정 디렉토리 문서에 반영된 사실의 계약·명세(What)와 배경·근거(Why)를 수집한다.
- R7: context-harvest는 퍼블리싱 사본을 수집 대상에서 제외한다. `publish` 선언 아래 자료는 결정적으로 제외하고, 선언이 없거나 URL이 없는 매체는 규칙 문장("SSoT 내용을 내보낸 사본은 출처로 인용하지 않고 repo 문서를 링크한다")으로 판단한다.
- R8: context-harvest 40_domain 템플릿은 doc용 선택 섹션 `근거 출처`(출처·조항·시행일·확인일)를 갖고, frontmatter 3키(`source`, `source_url`, `last_harvested`)는 그대로 유지한다. 원본 반영 섹션은 두지 않는다.
- R9: code-map은 SSoT 선언이 원본 문서이면 별도 참조 파일(`references/doc.md`)의 원본 문서 색인 절차를 따른다. build는 `ssot_dir`을 걸어 `60_codebase/index.md` 머리에 루트 경로를 기록하고 색인 행(파일 경로·다루는 주제·관련 문서 링크)을 만들며, 선언이 없으면 사용자에게 묻는다. sync는 `source_hash` 이후 변경된 파일 기준으로 다시 색인하되, 안내도의 `ssot_dir`이 색인 머리에 기록한 루트와 다르면 sync는 rebuild로 전환하고 check는 색인을 최신으로 보고하지 않는다. 교차 참조 연결과 `[WHY-NEEDED]`·`[DOC-NEEDED]` 태그 규칙은 `--local sync`와 같고, 새 CLI 옵션은 두지 않으며, 적용 대상에 원본 문서 색인이 들어간다.
- R10: 색인 맥락 문구 5곳(issue-audit, git-review, git-review-context, git-review-quiz, git-pr)은 "색인을 신뢰하지 않고 SSoT(`AI-CONTEXT.md` 선언)를 직접 확인한다"로 바뀌고, "SSoT는 소스코드" 문구가 남지 않는다. git-pr 문서 동기화 점검의 괄호 근거 `(SSoT는 소스코드)`(`git-pr/SKILL.md:294`)도 선언 기준으로 바꾼다. (294행은 이슈 본문 근거 없음. 2026-10-23 Task 0에서 결정)
- R11: 이 repo의 정책 문서 `.ai/40_domain/policies/local/ssot-and-router-principle.md`는 프로파일별 SSoT 선언·우선순위, SSoT·퍼블리싱·출처 용어 구분, `60_codebase/` SSoT 색인 정의, 수집·색인 스킬 산출물 제약의 선언 의존을 반영한다. (이슈 본문 근거 없음. 2026-10-20 대화에서 결정, 2026-10-22 용어 구분 추가. 현행 정책이 "소스 코드가 SSoT다"로 고정되어 있어 R1~R10과 충돌한다)

**제외**

- git-review·git-review-context·git-review-quiz의 리뷰 절차 자체: 불필요. SSoT가 repo 안이라 PR diff에 들어오므로 지금 절차가 그대로 작동한다. 색인 맥락 문구 교체는 R10에 포함한다.
- issue-work·issue-audit 절차(summary 원본 반영 섹션, 최종 감사 원본 조회 단계): 불필요. 같은 이유다. 2026-10-20 결정(원본 반영 기록 장소)은 2026-10-22에 폐기했다.
- 퍼블리싱 추적·동기화: 불필요. SSoT 정의에서 배제하는 대상이지 관리 대상이 아니다. 필요하면 별도 이슈로 다룬다.
- dev 프로파일의 `ssot_dir`·`publish` 행: 불필요. 소스 루트는 빌드 도구 관례(Maven·Gradle의 `pom.xml`·`build.gradle`)가 정하고 code-map Java 절차가 그 관례를 따른다. (2026-10-22 대화에서 결정)
- ai-workspace-directory(`scripts/check-lobby.sh:34`, `references/ssot-checklist.md`): 보류. 단독 repo에는 영향이 없다. doc repo를 포함한 멀티 워크스페이스가 생기면 후속으로 다룬다.
- code-map `--global`: 불필요. 멀티 repo 아키텍처 통합 모드라 이번 범위에 넣지 않는다.
- code-map Java 절차(`references/local.md`): 불필요. 원본 문서 절차는 별도 파일에 두므로 바뀌지 않는다.
- git-qa: 불필요. 문서 repo에 해당하지 않는다.
- dev 프로파일 동작 변경: 불필요. dev 전용 템플릿은 바뀌지 않으며 회귀 방지 항목으로만 보장한다.
- 근거 출처 > 원본 문서 우선순위의 스킬 표준화: 불필요. repo마다 달라 repo 규칙 파일에 둔다. 스킬 표준은 `원본 문서 > 안내도`까지만 정한다.

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

> 아래 명령은 모두 repo 루트에서 실행한다. 폴백 문구의 리터럴은 `선언을 찾지 못하면 소스 코드를 SSoT로 본다`와 `…봅니다` 두 형태로 고정하고, 명령은 두 어미를 열거해 대조한다 (`## 전제` 참조).

### R1: 선언 참조와 폴백

- [ ] [D]  선언을 읽는 8개 파일(context-harvest·code-map·issue-audit·git-review·git-review-context·git-review-quiz·git-pr의 `SKILL.md`, shared `context-loading.md`) 모두에 폴백 문구가 1행 이상 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in context-harvest/SKILL.md code-map/SKILL.md issue-audit/SKILL.md git-review/SKILL.md \
           git-review-context/SKILL.md git-review-quiz/SKILL.md git-pr/SKILL.md \
           ai-workspace/templates/shared/.ai/10_rules/context-loading.md; do
    [ "$(grep -cE '선언을 찾지 못하면 소스 코드를 SSoT로 (본다|봅니다)' "$f")" -ge 1 ] || echo "위반: $f 폴백 문구 없음"
  done
  ```

  - 설계 주의: 어미가 파일마다 다르므로(`본다`/`봅니다`) 두 어미를 열거해 대조한다. 한글 음절은 코드 포인트 하나라 `보`는 `본`·`봅`의 접두가 아니므로, 어간 `…SSoT로 보`로 대조하면 문구가 있어도 항상 실패한다 (2026-10-23 Task 5에서 발견·정정). 8개 파일 목록이 곧 "선언을 읽는 스킬"의 전수다.
  </details>
- [ ] [QD] 8곳의 선언 읽기 규칙이 위치(본문 2번째 줄이며 H1 제목과 그 뒤 빈 줄은 제외)·허용 값(`소스 코드`·`원본 문서`)·폴백(그 외는 소스 코드) 세 요소를 모두 담고 서로 모순 없이 같은 뜻으로 읽힌다. 물리 2행으로 읽히는 문구는 불통과다  (검증: 다른 AI가 파일별로 세 요소를 대조해 채점, 별도 세션)  ← 강등 사유: 문구가 파일마다 달라 의미 동치는 명령으로 환원 불가

### R2: doc 프로파일 선언·우선순위·선언 행

- [ ] [D]  doc 프로파일로 init한 `AI-CONTEXT.md`의 본문 2번째 줄이 doc 문구이고, 충돌 우선순위 행이 `원본 문서 > 이 repo 안내도 > 상위 워크스페이스 안내도`이며, `## 프로젝트 도메인` 표에 첫 셀이 `ssot_dir`·`publish`인 행이 각각 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  D=$(mktemp -d); cp -r ai-workspace/templates/shared/.ai/ "$D/.ai/"; cp -r ai-workspace/templates/doc/.ai/* "$D/.ai/"
  T="$D/.ai/AI-CONTEXT.md"
  body_start=$(awk 'NR == 1 && /^# / { next } NF { print NR; exit }' "$T")
  line2=$(sed -n "$((body_start + 1))p" "$T")
  [ "$line2" = '> SSoT: 원본 문서. 이 파일은 안내도일 뿐 진실의 원천이 아니다.' ] || echo "위반: doc init 2번째 줄 [$line2]"
  [ "$(grep -c '원본 문서 > 이 repo 안내도 > 상위 워크스페이스 안내도' "$T")" -eq 1 ] || echo '위반: doc 우선순위 행'
  [ "$(grep -c '소스 코드 > 이 repo 안내도' "$T")" -eq 0 ] || echo '위반: doc에 소스 코드 우선순위 잔존'
  for k in ssot_dir publish; do
    awk -v key="$k" '
      /^## 프로젝트 도메인[[:space:]]*$/ { f = 1; next } f && /^## / { exit }
      f && /^\|/ { v = $0; sub(/^\|[[:space:]]*/, "", v); sub(/[[:space:]]*\|.*$/, "", v); if (v == key) { found = 1; exit } }
      END { exit !found }' "$T" || echo "위반: doc 템플릿 프로젝트 도메인 표에 $k 행 없음"
  done
  rm -rf "$D"
  ```

  - 설계 주의: init은 템플릿 복사(SKILL.md init-1단계의 `cp -r` 2회)이므로 같은 복사를 임시 디렉토리에 재현해 산출물을 본다. 본문 2번째 줄은 `check-context.sh`와 같은 계산(H1 제목을 건너뛴 첫 비어 있지 않은 줄의 바로 다음 물리 행)으로 고르고, 표 행은 첫 셀 정확 대조로 센다. "두 번째 비어 있지 않은 줄"로 세면 날짜 행 뒤에 빈 줄이 있는 입력에서 검사기와 판정이 갈린다 (계획 감사 F-1).
  </details>

### R3: 두 표준 문구 인정과 `ssot_dir` 검사

- [ ] [D]  `check-context.sh`가 dev·doc 템플릿과 "dev 템플릿에 doc 문구와 `ssot_dir` 행을 넣은 파일"을 통과시키고, doc 선언인데 `ssot_dir` 행이 없는 파일(dev 기반·doc 템플릿 기반 2종)은 `ssot_dir`를 담은 누락 메시지로, 비표준 문구와 doc 유사 문구(`> SSoT: 원본 문서.`만 있는 줄)는 종료 코드 1로 격추한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=ai-workspace/scripts/check-context.sh; D=$(mktemp -d)
  for p in dev doc; do
    sed 's/^> last updated: YYYY-MM-DD$/> last updated: 2026-10-22/' "ai-workspace/templates/$p/.ai/AI-CONTEXT.md" > "$D/$p.md"
    "$C" "$D/$p.md" >/dev/null 2>&1 || echo "위반: $p 템플릿 불통과"
  done
  sed 's/^> SSoT: .*/> SSoT: 원본 문서. 이 파일은 안내도일 뿐 진실의 원천이 아니다./' "$D/dev.md" > "$D/docphrase-noroot.md"
  "$C" "$D/docphrase-noroot.md" >/dev/null 2>&1; [ $? -eq 1 ] || echo '위반: doc 선언인데 ssot_dir 행 없음(dev 기반)이 격추되지 않음'
  "$C" "$D/docphrase-noroot.md" 2>&1 | grep -q 'ssot_dir' || echo '위반: ssot_dir 누락 메시지 없음(dev 기반)'
  sed '/^| keywords | /a\
  | ssot_dir | docs/ |' "$D/docphrase-noroot.md" > "$D/docphrase.md"
  "$C" "$D/docphrase.md" >/dev/null 2>&1 || echo '위반: doc 문구 + ssot_dir 행이 통과하지 않음'
  sed '/^| ssot_dir | /d' "$D/doc.md" > "$D/doc-noroot.md"
  "$C" "$D/doc-noroot.md" 2>&1 | grep -q 'ssot_dir' || echo '위반: doc 템플릿에서 ssot_dir 행 삭제가 격추되지 않음'
  sed 's/^> SSoT: .*/> SSoT: 알아서 판단할 것./' "$D/dev.md" > "$D/bad.md"
  "$C" "$D/bad.md" >/dev/null 2>&1; [ $? -eq 1 ] || echo '위반: 비표준 문구가 격추되지 않음'
  sed 's/^> SSoT: .*/> SSoT: 원본 문서./' "$D/docphrase.md" > "$D/near.md"
  "$C" "$D/near.md" >/dev/null 2>&1; [ $? -eq 1 ] || echo '위반: doc 유사 문구가 격추되지 않음'
  rm -rf "$D"
  ```

  - 설계 주의: 통과 3건·격추 4건을 함께 본다. 통과만 보면 "모든 문구 허용"으로 바뀐 헬퍼가 통과하고, 격추만 보면 doc 문구를 아직 인정하지 않는 헬퍼가 통과한다. `ssot_dir` 격추를 dev 기반·doc 템플릿 기반 2종으로 두는 이유는, dev 기반은 "doc 선언이 검사를 켠다"를, doc 템플릿 기반은 "템플릿의 행이 검사 대상이다"를 각각 증명하기 때문이다. 유사 문구 격추는 `ssot_dir` 행이 있는 파일로 만들어 격추 원인이 2번째 줄임을 고정한다. `sed a\` 행의 앞 공백은 BSD sed가 그대로 삽입하므로 표 행 앞 공백을 두지 않도록 두 번째 줄을 열 머리에 둔다(검증 시 복사해 쓰면 앞 공백이 붙어도 `check-context.sh`의 첫 셀 대조는 양끝 공백을 무시하므로 통과한다).
  </details>
- [ ] [D]  `ai-workspace/tests/run-tests.sh`가 doc 문구 통과·유사 문구 격추·`ssot_dir` 행 없음 격추 케이스를 실제로 실행해 0 실패로 통과한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  R=ai-workspace/tests/run-tests.sh
  out=$("$R" 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*SSoT 선언 doc.* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*SSoT 선언 doc.* 격추')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*ssot_dir.* 격추')" -ge 1 ] \
    || echo '위반: 테스트 실패 또는 SSoT 선언 doc 케이스(통과·격추·ssot_dir 격추 각 1 이상) 미실행'
  ```

  - 설계 주의: 러너 출력의 `ok` 행을 세어 새 케이스가 실제로 실행·통과했을 때만 통과한다. 케이스 설명에는 `통과`·`격추` 중 하나만 쓴다.
  </details>
- [ ] [D]  SKILL.md 멱등 보강 검사 표의 SSoT 선언 행이 doc 문구를 함께 인정하고, `## 프로젝트 도메인` 행이 `ssot_dir`를 언급하며, 표는 10행을 유지한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  [ "$(grep -E '^\| 본문 두 번째 줄 SSoT 선언 \|' ai-workspace/SKILL.md | grep -c '원본 문서')" -eq 1 ] || echo '위반: 검사 표 SSoT 행에 doc 문구 없음'
  [ "$(grep -E '^\| `## 프로젝트 도메인` 섹션 \|' ai-workspace/SKILL.md | grep -c 'ssot_dir')" -eq 1 ] || echo '위반: 검사 표 프로젝트 도메인 행에 ssot_dir 없음'
  rows=$(awk '/^#### 멱등 보강 검사/ { f = 1; next } f && /^#### / { exit } f && /^\|/ { n++ } END { print n - 2 }' ai-workspace/SKILL.md)
  [ "$rows" -eq 10 ] || echo "위반: 검사 표 ${rows}행 (기대 10)"
  ```

  - 설계 주의: `ssot_dir` 검사는 별도 행이 아니라 `## 프로젝트 도메인` 행에 합쳐 적는다. 행을 늘리면 `check-context.sh` 머리 주석("10행 중 8행")과 명세의 항목 수가 함께 바뀐다.
  </details>

### R4: context-loading의 선언 참조와 원본 문서 작업 절

- [ ] [D]  shared `context-loading.md`에 "SSoT는 소스코드" 문구가 없고, `## ` 헤더로 시작하는 원본 문서 작업 절 안에 `60_codebase/index.md` 참조·관련 문서 추적·`ssot_dir` 직접 확인이 있으며, 이 repo의 사본과 내용이 같다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=ai-workspace/templates/shared/.ai/10_rules/context-loading.md
  [ "$(grep -c 'SSoT는 소스코드' "$F")" -eq 0 ] || echo '위반: 구 문구 잔존'
  [ "$(grep -cE '^## .*원본 문서' "$F")" -ge 1 ] || echo '위반: 원본 문서 작업 절 헤더 없음'
  sec() { awk '/^## .*원본 문서/ { f = 1; next } f && /^## / { f = 0 } f' "$F"; }
  [ "$(sec | grep -c '60_codebase/index\.md')" -ge 1 ] || echo '위반: 원본 문서 작업 절에 60_codebase/index.md 참조 없음'
  [ "$(sec | grep -cE '40_domain|50_adr')" -ge 1 ] || echo '위반: 원본 문서 작업 절에 관련 문서 링크 추적 없음'
  [ "$(sec | grep -c 'ssot_dir')" -ge 1 ] || echo '위반: 원본 문서 작업 절에 ssot_dir 직접 확인 없음'
  diff -q "$F" .ai/10_rules/context-loading.md >/dev/null || echo '위반: 이 repo 사본이 템플릿과 다름'
  ```

  - 설계 주의: 절 안의 행만 세도록 헤더 앵커(`^## `)로 범위를 자른다. 파일 전체에서 `60_codebase`를 세면 기존 코드 절의 참조로 통과한다.
  </details>

### R5: 60_codebase를 SSoT 색인으로 정의

- [ ] [D]  shared `60_codebase/index.md` 3행이 "SSoT 색인"을 선언하며 소스코드·원본 문서 두 정의를 함께 적고, doc 템플릿의 `60_codebase` 언급 행은 모두 원본 문서 기준이며, ai-workspace 스킬 소개의 code-map 행과 context-harvest 관계표의 code-map 행이 새 정의를 쓴다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  I=ai-workspace/templates/shared/.ai/60_codebase/index.md
  l3=$(sed -n 3p "$I")
  { printf '%s\n' "$l3" | grep -q 'SSoT 색인' && printf '%s\n' "$l3" | grep -q '소스코드' && printf '%s\n' "$l3" | grep -q '원본 문서'; } \
    || echo "위반: shared index 3행 [$l3]"
  T=ai-workspace/templates/doc/.ai/AI-CONTEXT.md
  [ "$(grep '60_codebase' "$T" | grep -cE '소스코드|코드 진입점|코드 상세')" -eq 0 ] || echo '위반: doc 템플릿 60_codebase 행에 코드 기준 표현 잔존'
  [ "$(grep '60_codebase' "$T" | grep -c '원본 문서')" -ge 3 ] || echo '위반: doc 템플릿 60_codebase 행 3곳(디렉토리 설명·진입 절차·작성 규칙)에 원본 문서 기준 미반영'
  [ "$(grep -E '^- \*\*code-map\*\*:' ai-workspace/SKILL.md | grep -c '원본 문서')" -eq 1 ] || echo '위반: ai-workspace 스킬 소개 code-map 행'
  [ "$(grep -E '^\| `code-map` \|' context-harvest/SKILL.md | grep -c 'SSoT 색인')" -eq 1 ] || echo '위반: context-harvest 관계표 code-map 행'
  ```

  </details>

### R6: context-harvest 수집 필터의 일반화

- [ ] [D]  context-harvest `SKILL.md`에 "SSoT는 소스코드이다"·"소스코드에 대응하지 않는" 문구가 없고, SSoT 원칙 절에 원본 문서 분기와 "SSoT에 대응하지 않는 정보" 필터가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=context-harvest/SKILL.md
  [ "$(grep -c 'SSoT는 소스코드이다' "$F")" -eq 0 ] || echo '위반: 구 문구 잔존'
  [ "$(grep -c '소스코드에 대응하지 않는' "$F")" -eq 0 ] || echo '위반: 구 필터 문구 잔존'
  sec() { awk '/^### SSoT 원칙/ { f = 1; next } f && /^### / { f = 0 } f' "$F"; }
  [ "$(sec | grep -c '원본 문서')" -ge 1 ] || echo '위반: SSoT 원칙 절에 원본 문서 분기 없음'
  [ "$(sec | grep -c 'SSoT에 대응하지 않는')" -ge 1 ] || echo '위반: 일반화한 필터 없음'
  ```

  </details>

### R7: 퍼블리싱 사본 제외

- [ ] [D]  context-harvest `SKILL.md`의 SSoT 원칙 절에 퍼블리싱 제외 규칙(`publish` 선언 참조와 규칙 문장 "출처로 인용하지 않")이 있고, `## 수집 제외 대상` 표에 퍼블리싱 행이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=context-harvest/SKILL.md
  sec() { awk '/^### SSoT 원칙/ { f = 1; next } f && /^### / { f = 0 } f' "$F"; }
  [ "$(sec | grep -c '퍼블리싱')" -ge 1 ] || echo '위반: SSoT 원칙 절에 퍼블리싱 없음'
  [ "$(sec | grep -c '`publish`')" -ge 1 ] || echo '위반: SSoT 원칙 절에 publish 선언 참조 없음'
  [ "$(sec | grep -c '출처로 인용하지 않')" -ge 1 ] || echo '위반: 규칙 문장 없음'
  [ "$(awk '/^## 수집 제외 대상/ { f = 1; next } f && /^## / { f = 0 } f && /^\|/' "$F" | grep -c '퍼블리싱')" -ge 1 ] || echo '위반: 수집 제외 대상 표에 퍼블리싱 행 없음'
  ```

  </details>
- [ ] [ND] 원본 문서를 선언한 repo에서 출처 자료를 수집하면 `근거 출처` 섹션을 갖춘 40_domain 문서가 생기고, `publish` 아래 자료는 수집하지 않는다  (검증: 사람이 doc repo에서 실행해 확인)  ← 강등 사유: 수집은 대화형 AI 절차라 명령으로 재현 불가

### R8: 40_domain 템플릿 근거 출처 섹션

- [ ] [D]  40_domain 템플릿의 frontmatter 5행이 main과 같고, `## 근거 출처` 섹션이 1개 있으며 요구 필드(조항·시행일·확인일)를 담고, `## 원본 반영` 섹션은 없다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=context-harvest/templates/40_domain-template.md
  diff <(sed -n 1,5p "$F") <(git show "main:$F" | sed -n 1,5p) >/dev/null || echo '위반: frontmatter 3키 변경'
  [ "$(grep -cE '^## 근거 출처' "$F")" -eq 1 ] || echo '위반: 근거 출처 섹션 수'
  [ "$(grep -cE '^## 원본 반영' "$F")" -eq 0 ] || echo '위반: 원본 반영 섹션 잔존'
  sec() { awk '/^## 근거 출처/ { f = 1; next } f && /^## / { f = 0 } f' "$F"; }
  for k in 조항 시행일 확인일; do [ "$(sec | grep -c "$k")" -ge 1 ] || echo "위반: 근거 출처에 $k 없음"; done
  ```

  </details>

### R9: code-map 원본 문서 색인 절차

- [ ] [D]  `code-map/references/doc.md`가 있고 build·sync, `ssot_dir`·`source_hash`, 색인 행 3열(파일 경로·다루는 주제·관련 문서), 선언 없을 때 질의, 루트 불일치 시 rebuild 전환, 두 태그 규칙을 담으며 page ID·루트 페이지 어휘가 없고, `SKILL.md`의 적용 대상·참조 문서·모드 표가 doc 절차를 가리키며, `references/local.md`·`global.md`는 main과 같다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=code-map/references/doc.md
  [ -r "$F" ] || echo '위반: doc.md 없음'
  for k in 'ssot_dir' 'source_hash' '파일 경로' '다루는 주제' '관련 문서' 'build' 'sync' '사용자에게 묻' 'ssot_dir.*다르면' '루트 불일치' '\[WHY-NEEDED\]' '\[DOC-NEEDED\]'; do
    grep -qE "$k" "$F" || echo "위반: doc.md에 $k 없음"
  done
  [ "$(grep -cE 'page ID|루트 페이지' "$F")" -eq 0 ] || echo '위반: doc.md에 외부 원본 어휘 잔존'
  [ "$(grep -cE '^### [0-9]+단계' "$F")" -ge 4 ] || echo '위반: doc.md 단계 절 수'
  S=code-map/SKILL.md
  [ "$(awk '/^## 적용 대상/ { f = 1; next } f && /^## / { f = 0 } f' "$S" | grep -c '원본 문서')" -ge 1 ] || echo '위반: 적용 대상에 원본 문서 없음'
  [ "$(grep -c 'references/doc.md' "$S")" -ge 2 ] || echo '위반: SKILL.md가 doc.md를 참조 문서·모드 표 양쪽에서 가리키지 않음'
  [ "$(grep -c '소스코드가 SSoT' "$S")" -eq 0 ] || echo '위반: 구 SSoT 원칙 문구 잔존'
  git diff --quiet main -- code-map/references/local.md code-map/references/global.md || echo '위반: local.md 또는 global.md 변경'
  ```

  - 설계 주의: `local.md`·`global.md` 무변경은 구현 전에도 통과하는 회귀 방지 조건이며 `### 공통`에서도 함께 센다.
  </details>
- [ ] [ND] 원본 문서를 선언한 repo에서 build하면 `ssot_dir` 아래 파일로 `60_codebase/index.md` 색인이 생기고 관련 `40_domain/` 문서가 교차 참조로 연결된다  (검증: 사람이 이 repo 안의 임시 디렉토리에 doc 선언·`ssot_dir`·문서 파일 몇 개를 두고 build해 확인. 외부 연결 불필요)  ← 강등 사유: build는 대화형 AI 절차라 명령으로 재현 불가

### R10: 색인 맥락 문구 5곳

- [ ] [D]  5개 `SKILL.md`에 "SSoT는 소스코드" 문구(`이므로` 형과 git-pr 294행의 괄호 형)가 없고 폴백 문구가 각각 1행 이상 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in issue-audit/SKILL.md git-review/SKILL.md git-review-context/SKILL.md git-review-quiz/SKILL.md git-pr/SKILL.md; do
    [ "$(grep -c 'SSoT는 소스코드' "$f")" -eq 0 ] || echo "위반: $f 구 문구 잔존"
    [ "$(grep -cE '선언을 찾지 못하면 소스 코드를 SSoT로 (본다|봅니다)' "$f")" -ge 1 ] || echo "위반: $f 폴백 문구 없음"
  done
  ```

  - 설계 주의: 대조 문자열을 `SSoT는 소스코드`까지로 줄여 `이므로` 형과 294행 괄호 형을 함께 잡는다. 2026-10-23 기준 5개 파일에 이 문자열을 가진 행은 이 6행(5곳 + git-pr 294행)뿐이다.
  </details>

### R11: 정책 문서 반영

- [ ] [D]  `ssot-and-router-principle.md`에 "소스 코드가 SSoT다" 고정 문구가 없고, SSoT 선언·원본 문서·SSoT 색인·퍼블리싱·`ssot_dir` 언급이 각각 1행 이상 있으며, 원본 출처에 이슈 #114가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=.ai/40_domain/policies/local/ssot-and-router-principle.md
  [ "$(grep -c '^- 소스 코드가 SSoT' "$F")" -eq 0 ] || echo '위반: 고정 문구 잔존'
  for k in 'SSoT 선언' '원본 문서' 'SSoT 색인' '퍼블리싱' 'ssot_dir'; do [ "$(grep -c "$k" "$F")" -ge 1 ] || echo "위반: $k 언급 없음"; done
  [ "$(grep -c 'issues/114' "$F")" -ge 1 ] || echo '위반: 원본 출처에 #114 없음'
  ```

  </details>
- [ ] [QD] 정책 문서가 R1~R10의 동작(선언 위치·값·폴백·우선순위·`ssot_dir`·`publish`·퍼블리싱 판정·색인 정의)과 모순되지 않는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 정책 서술과 스킬 절차의 의미 대조라 명령으로 환원 불가

### 공통

- [ ] [D]  repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D]  dev 프로파일 전용 템플릿(`ai-workspace/templates/dev/`)과 code-map 참조 2종(`references/local.md`·`global.md`)이 main과 같다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  git diff --quiet main -- ai-workspace/templates/dev/ code-map/references/local.md code-map/references/global.md || echo '위반: dev 전용 템플릿 또는 code-map 참조 변경'
  ```

  - 설계 주의: shared 템플릿(`context-loading.md`·`60_codebase/index.md`)은 두 프로파일에 함께 배포되므로 R4·R5로 바뀐다. 이 항목은 dev **전용** 파일에 한한다 (`## 전제` 참조).
  </details>

---

## 전제 (Assumptions)

- **방향 전환 이력**: 2026-10-20 초안은 repo 밖 위키(Confluence)를 원본으로 보고 page ID·확인 버전으로 추적하는 설계였다. 2026-10-22에 SSoT를 repo 지정 디렉토리의 문서 파일로 바꾸고 위키·블로그를 퍼블리싱으로 정의했다. 옛 spec의 `원본 반영` 섹션(40_domain·summary)과 issue-audit 원본 조회 단계는 폐기했으며, 이 문서에 다시 넣지 않는다.
- **용어**: SSoT는 선언이 정한다(dev 소스 코드, doc 원본 문서). 원본 문서는 `ssot_dir` 아래 문서 파일이다. 퍼블리싱은 SSoT에서 파생해 밖으로 내보낸 사본(위키·블로그·PDF·슬라이드 등 형태 불문)이며 SSoT도 출처도 아니다. 출처는 SSoT에서 파생되지 않은 외부 자료다. 판정 기준은 매체가 아니라 유래다.
- **이슈 완료 기준 "dev 프로파일 init 산출물이 바뀌지 않는다"의 범위**: dev 전용 템플릿(`templates/dev/`)에 한한다. shared 파일(`10_rules/context-loading.md`, `60_codebase/index.md`)은 두 프로파일에 함께 배포되므로 R4·R5로 dev 산출물도 바뀐다.
- **선언 읽기 규칙**: `AI-CONTEXT.md` 본문 2번째 줄의 `> SSoT: <값>. …`에서 `<값>`이 `원본 문서`이면 doc, `소스 코드`이면 dev다. 본문 2번째 줄은 `check-context.sh`와 같은 계산으로 고른다. 1행의 H1 제목을 건너뛴 첫 비어 있지 않은 줄(`> last updated:` 행)이 본문 1번째 줄이고, 그 바로 다음 물리 행이 본문 2번째 줄이다. 템플릿에서는 물리 4행이며 물리 2행은 빈 줄이다. 두 줄 사이에 빈 줄이 있으면 선언을 찾지 못한 것이다. 그 외 값·줄 없음·파일 없음은 모두 "선언을 찾지 못함"으로 보고 소스 코드로 폴백한다. 배포 파일 8곳의 문구는 위치를 "본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)"로 적어 물리 2행으로 읽히지 않게 한다 (계획 감사 F-1).
- **폴백 문구 리터럴**: `선언을 찾지 못하면 소스 코드를 SSoT로 본다`(합니다체 파일은 `봅니다`)를 8곳에 같은 문장으로 복제한다. ADR 0002의 의도적 중복이며 참조 링크로 대체하지 않는다. 문장을 바꾸면 8곳과 DoD 명령을 함께 바꾼다. DoD 명령은 두 어미 `본다`·`봅니다`를 열거해 대조한다. 어간 `보`는 `본`·`봅`과 다른 음절이라 접두 대조가 성립하지 않는다 (2026-10-23 Task 5 결정).
- **선언 읽기 표준 문장**: 8곳은 아래 세 문장을 같은 뜻으로 쓴다(합니다체 파일은 어미만 바꾸고, 문장 배치는 파일 맥락에 맞춘다). "SSoT는 `AI-CONTEXT.md` 본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)의 `> SSoT: <값>.` 선언을 따른다. 값은 `소스 코드` 또는 `원본 문서`이며 그 외 값은 선언으로 보지 않는다. 선언을 찾지 못하면 소스 코드를 SSoT로 본다." 허용 값 문장이 없으면 R1 [QD]의 세 요소(위치·허용 값·폴백) 중 허용 값이 빠진다. 허용 값 문장의 어간 `그 외 값은 선언으로 보지 않`도 8곳에 그대로 둔다 (2026-10-23 Task 0 결정).
- **update의 doc 선언 처리**: update는 dev 문구를 doc 문구로 자동 전환하지 않는다. 이전 doc 템플릿으로 만든 repo는 사용자가 2번째 줄을 직접 바꾸고, 다음 update가 `ssot_dir` 자리표시자 행을 보강한다. update-4는 헬퍼를 한 번만 실행하므로 비표준 문구를 doc 문구로 삽입·교체한 실행에서는 `ssot_dir` 검사가 돌지 않는다. 그래서 SSoT 행의 조치가 doc 문구를 넣었을 때 `ssot_dir` 행이 없으면 템플릿과 같은 자리표시자 행도 함께 넣는다. 검사 표는 10행을 유지한다 (2026-10-23 Task 0 결정).
- **`ssot_dir` 선언 규칙**: `## 프로젝트 도메인` 표의 첫 셀이 `ssot_dir`인 행이며, 값은 repo 루트 기준 상대 경로(콤마 나열 가능, 예: `docs/`)다. doc 선언일 때만 `check-context.sh`가 행 존재를 검사하고 값 형식은 검사하지 않는다. dev 선언 파일에 이 행이 있어도 무시한다. dev 템플릿에는 두지 않는다. 소스 루트는 빌드 도구 관례가 정하기 때문이다.
- **`publish` 선언 규칙**: 같은 표의 선택 행이며 값은 퍼블리싱 위치 URL 콤마 나열이다. `check-context.sh`의 검사 대상이 아니다. 템플릿에는 자리표시자 행을 두고, 쓰지 않으면 지우라고 주석에 적는다.
- **퍼블리싱 판정 규칙 문장 리터럴**: `SSoT 내용을 내보낸 사본은 출처로 인용하지 않고 repo 문서를 링크한다`. `publish` 선언 아래 자료는 이 문장 없이 결정적으로 제외한다.
- **멱등 보강 검사 표 10행 유지**: `ssot_dir` 검사는 `## 프로젝트 도메인` 행에 합쳐 적는다. 행을 늘리면 `check-context.sh` 머리 주석("10행 중 8행")과 명세의 항목 수가 함께 바뀐다. update가 보강하는 `ssot_dir` 자리표시자 값은 템플릿의 값과 같다.
- **doc 템플릿 자리표시자**: `ssot_dir` 값은 `<SSoT 문서 디렉토리. repo 루트 기준 상대 경로, 콤마 나열 가능. 예: docs/>`, `publish` 값은 `<선택. 퍼블리싱 위치(위키·블로그 등) URL 콤마 나열. 쓰지 않으면 이 행을 지운다>`. init 보고에서 `domain`/`keywords`와 함께 `ssot_dir` 입력을 요청한다.
- **doc 색인 생성 주체**: code-map이다. 대안(context-harvest가 수집 중 색인을 부산물로 씀)은 `60_codebase/` 작성 주체가 둘이 되어 기각했다 (이슈 본문 `결정 (확정)`, 2026-10-20 승인).
- **doc 색인의 메타데이터**: 코드 색인과 같은 `last_synced`·`source_hash`·`status`에 `ssot_dir`(색인한 루트 경로) 한 키를 더한다. stale 판정은 코드 색인과 같이 `source_hash` 이후 변경 파일 기준이며, 행별 확인 버전은 두지 않는다(git이 버전을 관리). sync·check는 진입 시 안내도 `## 프로젝트 도메인` 표의 `ssot_dir`과 frontmatter `ssot_dir`을 먼저 대조한다. 다르면 `source_hash` 기준 diff가 새 루트의 기존 문서와 범위 밖 행을 잡지 못하므로 sync는 rebuild로 전환하고(Why 태깅 보존), check는 색인 전체를 `[UPDATE-NEEDED]`로 보고하며 rebuild를 권고한다. frontmatter `ssot_dir`은 반영을 마친 뒤에만 갱신한다 (계획 감사 F-2).
- **doc 색인 단위**: 문서 파일 1개가 색인 행 1개다. 하위 디렉토리는 행을 묶는 절 제목으로만 쓴다. 상세 흐름 파일은 두지 않는다(코드의 호출 흐름에 대응하는 구조가 문서에는 없다).
- **CLI 옵션 불변**: code-map은 새 옵션을 두지 않는다. `--local`이 SSoT 선언에 따라 `references/local.md`(소스 코드) 또는 `references/doc.md`(원본 문서)를 읽는다.
- **근거 출처 > 원본 문서 우선순위**: repo 규칙 파일(`10_rules/`) 영역이다. 스킬 표준은 `원본 문서 > 안내도`까지만 정한다.
- **문서 정합 범위**: 명세(`specs/ai-workspace.md`), 색인(`.ai/60_codebase/index.md`·`ai-workspace/update-call-flow.md`·`ai-workspace/init-call-flow.md`), 안내도 스킬 목록·디렉토리 구조의 code-map `references/` 행·README의 code-map 설명 동기화는 R11의 정책 반영과 같은 문서 정합 작업으로 보고 Task 6에 둔다. `specs/issue-audit.md`·`specs/issue-workflow.md`는 절차가 바뀌지 않아 손대지 않는다. ADR 신설은 이번 범위에 넣지 않고, git-pr 문서 동기화 점검이 권고하면 그때 사용자가 결정한다.
- **Task 3·4 테스트 배치**: context-harvest·code-map에는 `scripts/`가 없지만 Task 3·4의 절차 변경을 덮는 테스트를 각 스킬 `tests/`에 둔다. `run-tests.sh`는 규칙 문장의 구조 회귀를 [D]로 보고 규칙별 변형을 격추하며, `fixtures/`의 입력·기대 결과 쌍은 절차를 입력에 적용한 결과를 [QD] 모의 실행으로 본다(ai-workspace update-4 fixture와 같은 형식). `architecture.md` 역할 분담 표의 `tests/` 행과 안내도 디렉토리 구조는 Task 6에서 맞춘다. 최종 감사 1차 F-2 검토에서는 테스트를 두지 않기로 했으나 2차 F-3에서 반영으로 바꿨다 (2026-10-23 최종 감사 2차 `--response` 결정).
- **원장 K-0006**: `references/doc.md`의 정합성 점검도 같은 결정화 부채를 공유하지만, K-0006 재검토 조건은 `local.md` 3단계·`global.md` 4단계 점검 표 변경 또는 `check` 첫 실행이라 doc.md 신설만으로는 충족되지 않는다. 이번 이슈의 해소 대상이 아니며 PR 시점 git-pr 원장 대조의 권고를 따른다.
- **로비 문구 불변**: `ai-workspace-directory/scripts/check-lobby.sh:34`의 로비 SSoT 문구(`라우터일 뿐`)는 범위 밖이라 그대로 둔다.
- **이 repo의 프로파일**: dev 산출물 구조(`architecture.md`·`coding-convention.md` 존재)이며 `.ai/AI-CONTEXT.md` 2번째 줄은 dev 문구를 유지한다. 이 repo의 `.ai/60_codebase/index.md`는 code-map build 산출물이라 템플릿 변경의 영향을 받지 않는다.
- **환경**: 테스트 러너는 bash이며 macOS BSD `sed -i.bak` 관용을 따른다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/40_domain/policies/local/ssot-and-router-principle.md` | 현행 SSoT 원칙·충돌 우선순위·수집 스킬 산출물 제약. 이 이슈가 바꾸는 정책의 원본 (R11) |
| `.ai/40_domain/specs/ai-workspace.md` | ai-workspace dev/doc 프로파일, update의 버전 고정 파일 덮어쓰기 규칙, 멱등 보강 검사 (R2~R5) |
| `.ai/50_adr/active/0002-skill-independence-intentional-duplication.md` | 스킬은 AI-CONTEXT 비의존·단독 설치. R1의 "선언 없으면 소스 코드" 폴백과 R10 문구의 스킬별 복제 유지 근거 |
| `.ai/50_adr/active/0008-writing-principles-ssot-distribution.md` | 내장 기본값 + 조건부 참조 패턴. SSoT 선언 참조의 선례 (R1) |
| `.ai/60_codebase/ai-workspace/init-call-flow.md`, `.ai/60_codebase/ai-workspace/update-call-flow.md` | ai-workspace init·update 호출 흐름. `check-context.sh` 호출 위치 (R3) |
| `.ai/70_ledger/active/K-0006-code-map-check-not-deterministic.md` | code-map `check` 결정화 부채. `references/doc.md`의 점검도 같은 부채를 공유하지만 재검토 조건(`local.md`·`global.md` 점검 표 변경 또는 `check` 첫 실행)에는 해당하지 않는다. 이 이슈의 해소 대상은 아니다 (R9) |
