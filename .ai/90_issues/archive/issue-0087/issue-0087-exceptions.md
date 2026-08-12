# Issue #87 검사 기준·예외 목록

> 스펙: [issue-0087-spec.md](./issue-0087-spec.md) | 계획: [issue-0087-plan.md](./issue-0087-plan.md)

검사 기준의 SSoT는 [.ai/10_rules/writing-principles.md](../../../10_rules/writing-principles.md)(버전 1.1.1) "한국어 작성 규칙"의 표현 소절이다.
이 파일은 그 규칙을 #87 정비에 적용하기 위한 검사식·심사 지침과, 고치지 않고 남긴 행의 등재 표를 담는다.

기준 시점은 2026-08-11이며 실측값은 em dash 532행 / 49개 파일, "가 아니라" 18행 / 11개 파일이다.

---

## 검사식

grep으로 기계 판정이 가능한 패턴 2종의 스캔 방법을 고정한다. 나머지 4종은 `## 심사 지침`의 통독 심사로 처리한다.

**스캔 스코프**: repo 루트의 md 파일 전체에서 `.git/`, `.ai/90_issues/`, `*/tests/`를 뺀 집합이다.

```bash
find . -name '*.md' -not -path './.git/*' -not -path './.ai/90_issues/*' -not -path '*/tests/*' | sort
```

**건수 산정 기준**

- 잔존 건수는 패턴 포함 **행 수**(`grep -c`)로 센다. 한 행에 패턴이 두 번 나와도 1행이다.
- em dash는 `—` 문자 전체를 세며 공백으로 둘러싼 형태(` — `)로 좁히지 않는다. 기준 시점 532행 중 48행이 행 끝에서 다음 줄로 잇는 형태라 좁히면 그만큼을 놓친다.
- 예외 목록의 `허용 건수` 열도 같은 기준이다. Task별 검증 스니펫이 이 값을 `grep -c` 결과와 직접 대조한다.

**패턴별 스캔 명령**

| 패턴 키 | 대상 | 스캔 명령 |
|---------|------|-----------|
| `emdash` | em dash `—` | `grep -c '—' "$f"` |
| `negation` | 부정 대조 "가 아니라" | `grep -c '가 아니라' "$f"` |

**전체 현황 집계** — 진행 대조용으로 아무 때나 재실행한다.

<details>
<summary>집계 명령 — 파일별 잔존 행 수와 합계를 출력</summary>

```bash
find . -name '*.md' -not -path './.git/*' -not -path './.ai/90_issues/*' -not -path '*/tests/*' | sort \
  | { te=0; tn=0; fe=0; fn=0; while read -r f; do
      e=$(grep -c '—' "$f"); n=$(grep -c '가 아니라' "$f")
      te=$((te+e)); tn=$((tn+n))
      [ "$e" -gt 0 ] && fe=$((fe+1))
      [ "$n" -gt 0 ] && fn=$((fn+1))
      [ "$e" -eq 0 ] && [ "$n" -eq 0 ] && continue
      printf '%s\temdash=%s\tnegation=%s\n' "${f#./}" "$e" "$n"
    done; echo "합계 emdash ${te}행 / ${fe}파일, negation ${tn}행 / ${fn}파일"; }
```

</details>

---

## 심사 지침

#86이 확정한 패턴 6종의 판별 기준과 수정 지침이다. 1·2번은 검사식이 위치를 찾아 주고 수정 여부만 심사하며, 3~6번은 대상 파일 통독으로 찾는다.

수정 지침은 모두 같은 제약 아래 적용된다. **의미·구조·산출물 형식은 바꾸지 않는다.**

### 1. em dash (`emdash`)

- **규칙**: em dash(`—`)를 삽입구·절 연결에 쓰지 않는다. 쉼표·마침표로 문장을 나누거나 괄호를 쓴다.
- **수정 대상**
  - 문장 안 삽입구·절 연결. 행 끝에서 다음 줄로 잇는 형태를 포함한다.
  - 헤더 부제 구분자 (`## 제목 — 부제`). #86이 규칙 파일 본문에서 같은 판단을 한 선례를 따른다.
- **수정 방법**: 삽입구는 괄호로, 절 연결은 쉼표나 마침표로 바꾼다. 부제는 문장으로 풀거나 괄호로 감싼다.
- **구분자와 절 연결의 경계** (판정이 갈리는 리스트 항목 안에서 적용)
  - em dash 앞이 명사구·명사형으로 끝나고 뒤가 그 항목의 설명·부연·증빙이면 **구분자**다. 유지하고 등재한다. (`- \`path\` — 설명`, `- 초과 판매 가능성 — TTL 5초로 완화`)
  - em dash 앞이 서술어로 끝나는 절이고 뒤가 그 절의 근거·이유·역접·후속을 잇는 형태면 **절 연결**이다. 수정한다.
  - 리스트 밖 문단 안의 em dash는 앞뒤 형태와 무관하게 수정 대상이다. 다만 볼드 라벨로 시작해 설명이 이어지는 캡션 행(`**영향 축** — 발견이 실현됐을 때 무엇이 무너지는가`)은 리스트 항목 라벨과 같은 구조이므로 구분자로 본다.
  - 템플릿이 정의하는 산출물의 헤더 형식(`### <카테고리> — <상태>, N건`)은 `형식 고정`으로 유지한다. 수정 대상인 헤더 부제는 문서 자신의 서술형 부제에 한정하며, 산출물 형식을 바꾸는 수정은 spec 비포함 범위다.
  - HTML 주석 블록(`<!-- -->`) 안은 문장 형태와 무관하게 유지한다. 절 연결로 이어진 산문형 긴 주석도 같다. 렌더링되지 않는 작성자·AI용 안내이며 spec 전제가 유지 대상으로 명시했다.
  - 플레이스홀더(`<...>`) 안의 안내 텍스트에는 위 명사구·서술어 경계를 그대로 적용한다. `<검사할 불변 조건 — 무엇이 보장되는지 한 문장>`은 앞이 명사구라 구분자로 유지하고, `<이전 회차와 번호가 불연속일 때만 기재 — 마지막 사용·예약 번호…>`는 앞이 서술어라 수정한다.
  - 고정 Task 헤더(`### Task 0 (고정): … — 전제·모호점 확인`)는 헤더 부제라 수정하며, 부제를 괄호로 감싼다. plan·summary 두 템플릿과 진행 중인 이슈 문서의 헤더를 같은 문구로 함께 바꾼다 (Task N 검증이 두 파일의 Task 헤더 집합 일치를 대조한다).
  - 표 셀 안은 절 연결이어도 유지한다. spec 전제가 표 셀을 유지 대상으로 명시했고, 셀 안에서 문장을 나누면 셀 하나에 문장 여럿이 들어가 표의 가독 단위가 무너진다.
  - 조건절 뒤 명사 종결 + 후속 지시(`- \`../.ai/AI-CONTEXT.md\`가 존재하면 상위 워크스페이스의 일부 — 인접 repo가 필요한 질의면 …`)는 절 연결로 보고 수정한다. 앞이 명사로 끝나도 라벨과 설명의 관계가 아니라 판정 결과와 그에 따른 행동이므로, 서술어를 붙여 문장으로 끊는다.
  - 인용문·안내 문구를 여는 도입부(`… 다음 안내만 출력합니다 — *"…"*`)는 마침표로 끊는다. 볼드 라벨 뒤에 이미 콜론이 있는 자리라 콜론을 겹치지 않는다.
  - 라벨 콜론 뒤 본문이 서술 흐름으로 진행된 다음에 나오는 em dash는 절 연결로 보고 수정한다 (`- **채택하지 않은 대안**: … 자리표시자로 교체하는 안 — 한 줄 보정으로 …`). 콜론 바로 뒤의 값·짧은 명사구 라벨을 그 부연과 가르는 em dash는 위 명사구 경계대로 구분자로 유지한다 (`- git-pr (권장): 선행 단계 — 이 스킬은 …`, `- **공통 규칙**: <경로> — 있으면 따르며 …`). 판정 이력: 2차 audit(F-6)이 무조건 수정 서술("콜론 뒤는 문단과 같이 보고 수정")과 예외 표의 충돌을 제기해, 원장 사례가 겨냥한 서술 흐름 중간의 em dash로 범위를 좁혔다.
  - 링크 텍스트 안의 "출처 번호 — 제목" 형식(`[Issue #23 — 스킬 결정적 헬퍼 테스트 규칙 정립…](…)`)은 라벨 구분자로 유지한다. 링크 텍스트를 문장으로 바꾸면 출처 표기 형식이 깨진다.
  - 다른 문서의 소제목·고정 문구를 그대로 인용한 em dash는 `형식 고정`으로 유지한다. 인용 쪽만 고치면 원문과 문자열이 어긋난다 (`"이동 제외 — 루트 상주 파일" 규칙`).
- **예외 (고치지 않고 등재)**
  - 리스트 항목의 라벨 구분자 (`- **용어** — 설명`) → 분류 `구분자 용법`
  - 표 셀 안의 구분자 → 분류 `구분자 용법`
  - 접기 제목 기본형 (`검증 명령 — 출력 0건이면 통과`) → 분류 `형식 고정`
  - HTML 주석 안의 SYNCED 마커·템플릿 안내 주석 → 분류 `형식 고정`
  - 코드 펜스 안 리터럴 → 분류 `코드 블록 리터럴`
  - 규칙·패턴 자체를 설명하거나 인용하는 용법 → 분류 `메타 사용`

### 2. 부정 대조 (`negation`)

- **규칙**: "A가 아니라 B입니다" 같은 부정 대조를 습관적으로 쓰지 않는다. "B이다"로 단언하고, 실제 오해를 바로잡을 때만 대조를 쓴다.
- **판별**: 18행을 행별로 심사한다. 독자가 실제로 A로 오해할 소지가 있어 그것을 바로잡는 문장인지 본다.
- **수정 대상**: 오해 소지 없이 강조 목적으로만 쓴 대조. "B이다" 단언형으로 재작성한다.
- **예외**: 실제 오해를 바로잡는 대조는 그 오해가 무엇인지 근거 열에 적고 등재한다 → 분류 `정당한 대조`. 규칙 인용은 분류 `메타 사용`.

### 3. 문장 안 수사적 콜론

- **규칙**: "핵심은 하나다: ~" 같은 문장 안 수사적 콜론은 풀어쓴다.
- **판별**: 콜론 앞이 완결된 문장이고 뒤가 그 문장의 내용을 다시 여는 형태다. 규칙이 금지하는 것은 앞 문장을 끊고 같은 내용을 강조하며 되여는 장치다.
- **수정 방법**: 한 문장으로 합치거나 두 문장으로 나눈다.
- **예외**: 리스트 항목의 "라벨: 설명" 형식 전반(`**용어**: 설명` 포함)은 규칙이 명시적으로 제외한 형식이므로 심사 대상이 아니며 등재도 하지 않는다. 표 셀의 라벨 구분, 코드·명령 출력 예시의 콜론도 같다.
- **값 제시 도입 콜론도 예외**: 완결 문장 뒤 콜론이 인용문·경로·열거값·고정 문구 리터럴을 여는 형태는 심사 대상이 아니며 등재도 하지 않는다. 뒤에 오는 것이 앞 문장의 재진술이면 수사적 콜론이고, 앞 문장이 지시하는 대상 값이면 값 제시다. 백틱 코드 스팬 유무는 판정을 가르지 않는다. 경로를 코드 스팬으로 감싼 행과 감싸지 않은 행이 같은 구조이기 때문이다.
  - 예: `… 확인을 요청합니다: *"이대로 … 덮어쓸까요?"*`(인용문), `… 파일 경로를 구성한다: .ai/99_workspace/notes/<날짜>-<slug>.md`(경로), `… 표로 제시합니다: 번호 | 출처 | 요지 …`(열거값), `… 표준 병기 문구를 붙인다: (작성 시점 경로는 …)`(고정 문구)
- **HTML 주석 안도 예외**: 주석 블록(`<!-- -->`) 안의 콜론은 형태와 무관하게 유지한다. em dash 항목과 같은 근거이며, 렌더링되지 않는 작성자·AI용 안내다.
  - 판정 이력: 1차 교차모델 audit(OpenAI, GPT-5.6 Sol)이 이 형태 5행을 미정비로 제기했다. `--response` 검토에서 규칙 원문의 금지 대상과 대조해 심사 대상 밖으로 판정하고, 같은 판정이 다음 감사에서 반복되지 않도록 이 항목을 명문화했다. 감사인이 코드·명령 예시로 보아 제외한 `issue-work/SKILL.md`의 명령 리터럴 행도 같은 구조이며 같은 근거로 대상 밖이다. 2차 audit(F-5)은 이 예외의 spec 전제 근거 부재를 제기했고, 2차 `--response`에서 예외 유지를 사용자 확정받아 spec 전제에 패턴 공통 예외로 기록했다.

### 4. 관성적 3항 병렬

- **규칙**: "빠르고, 안전하며, 확장 가능한" 같은 관성적 3항 병렬 나열 대신 실제 필요한 항목만 쓴다.
- **판별**: 세 항목이 같은 층위의 수식·서술로 늘어서고, 그중 일부를 빼도 문장의 정보가 줄지 않는 경우다.
- **수정 방법**: 실제로 필요한 항목만 남긴다.
- **예외**: 항목 각각이 서로 다른 정보를 담아 하나라도 빼면 내용이 누락되는 나열은 관성적 병렬이 아니므로 심사 대상이 아니다. 절차·목록의 열거도 같다.

### 5. 영어식 하이픈 합성

- **규칙**: "고품질-저비용" 같은 영어식 하이픈 합성 대신 조사·어미로 잇는다.
- **판별**: 한국어 낱말 둘을 하이픈으로 붙여 하나의 수식어처럼 쓴 형태다.
- **수정 방법**: 조사·어미로 풀거나 가운뎃점으로 바꾼다.
- **예외**: 코드 식별자·파일명·명령 옵션(`kebab-case`, `--workflow-only`, `writing-principles-local.md`)은 원문 표기 유지 대상이므로 심사 대상이 아니다.
- **개념 복합어는 수정 대상**: 서술문 안에서 개념 둘을 하이픈으로 이어 붙인 말("건물-층" 비유, "크로스-서비스 호출")은 식별자가 아니므로 고친다. 가운뎃점으로 바꾸거나("건물·층"), 같은 문서가 이미 쓰는 우리말 표현으로 통일한다("서비스 간 호출").

### 6. 은유·비유 직역

- **규칙**: 요청받지 않은 은유·비유·의인화 대신 뜻을 직접 서술한다. 영어 관용 은유의 직역("북극성 지표", "낮게 매달린 과일")도 쓰지 않는다.
- **판별**: 대상을 다른 사물에 빗대거나 문서·도구를 사람처럼 서술한 표현이다.
- **수정 방법**: 빗댄 뜻을 직접 서술한다.
- **예외**: 정착된 기술 용어의 비유적 어원(로비, 층, 게이트, 원장)은 이 repo가 용어로 채택한 것이라 심사 대상이 아니다. 구체 예시 제시도 은유와 다르므로 제한하지 않는다.
- **비유를 선언하는 문장도 예외 (사용자 확정, `code-map/SKILL.md:11`)**: `"건물·층" 비유의 2레이어 구조를 사용하며…`는 용어를 쓰는 수준을 넘어 비유 자체를 선언하지만 고치지 않는다. 이 문장이 바로 아래 두 행의 모드 명칭 `floor 모드`·`building 모드`의 근거이고, building·floor는 `ai-workspace-directory/SKILL.md`·`.ai/AI-CONTEXT.md`·`ai-workspace-directory/references/examples.md`가 함께 쓰는 이 repo의 용어다. 낱말을 걷어내면 모드명이 근거를 잃는다.
  - 판정 이력: 3차 audit(F-7)이 위 어원 예외가 이 문장을 온전히 덮지 못한다고 제기했다. `--response` 3차에서 예외 유지를 사용자 확정받아 spec 전제에 함께 기록했다. 예외 목록 표는 `emdash`·`negation` 두 패턴 전용이라 이 행은 표에 등재하지 않고 여기에 파일·행으로 추적한다.
  - 전수 확인: 스캔 스코프에서 "비유·은유·메타포·빗대"를 조회하면 서술로 쓰인 행은 이 1행뿐이다. 나머지 2행은 `writing-principles.md` 원본·사본의 규칙 원문이라 `메타 사용`이다. 미처리 0건이다.

### 공통 제약

- **고정 문구 불변**: 검증 명령·다른 문서가 문자열로 대조하는 앵커와 고정 문구는 바꾸지 않는다. 접기 제목 기본형, 표준 병기 문구 "작성 시점 경로는", summary 지표 필드 표기가 여기 해당한다.
- **구조 불변**: 헤더·체크박스·코드 펜스·표 행 수를 유지한다.
- **동기화 쌍**: 템플릿이 SSoT다. 템플릿을 먼저 고치고 `.ai/` 사본에 반영한다.

---

## 예외 목록

Task 2~5가 고치지 않고 남긴 행을 여기에 등재한다. Task별 검증 스니펫이 이 표의 `허용 건수`를 `grep -c` 결과와 대조하므로, 아래 기재 규칙을 지키지 않으면 검증이 오작동한다.

**기재 규칙**

- **1파일 1패턴 1행**: 같은 파일의 같은 패턴은 분류가 여럿이어도 표에서 **정확히 1행**으로 합산한다. 검증 awk가 (파일, 패턴) 일치 행의 허용 건수를 뽑아 단일 값으로 비교하므로, 2행으로 나누면 대조가 깨진다. 분류가 여럿이면 분류 열에 가운뎃점으로 잇고 근거 열에 내역별 건수를 적는다.
- **파일 경로**: 백틱 없이 repo 루트 기준 상대 경로로 적는다 (`git-pr/SKILL.md`). 검증 awk가 공백만 제거하므로 백틱이 남으면 대조가 어긋난다.
- **패턴**: `emdash` 또는 `negation` 리터럴만 쓴다. 검증 스니펫의 키와 문자열로 대조한다.
- **허용 건수**: 숫자만 적는다. 단위·주석을 붙이지 않는다.
- **분류**: 아래 6종에서 고른다. `수용`이 섞이면 분류 열을 `수용`으로 적고 나머지 내역은 근거 열에 적는다. 혼합 표기로는 수용 행 검증(`분류 == 수용`)에 걸리지 않아 원장 등재가 누락된다.
- **근거**: 왜 남겼는지 한 줄. 분류가 `수용`인 행은 원장 항목 번호 `K-<번호>`를 반드시 포함한다.

**분류 6종**

| 분류 | 뜻 |
|------|-----|
| 메타 사용 | 금지 패턴 자체를 규칙·예시로 설명·인용하는 용법 |
| 형식 고정 | 검증 명령·다른 문서가 문자열로 대조하는 앵커·고정 문구 |
| 구분자 용법 | 리스트 항목 라벨·표 셀의 구분자 |
| 코드 블록 리터럴 | 코드 펜스 안의 문자열 |
| 정당한 대조 | 실제 오해를 바로잡는 부정 대조 |
| 수용 | 이번에 고치지 못해 기술부채로 안고 가는 행. 원장 등재 필수 |

| 파일 | 패턴 | 허용 건수 | 분류 | 근거 |
|------|------|-----------|------|------|
| git-pr/SKILL.md | emdash | 9 | 구분자 용법·코드 블록 리터럴 | 리스트 라벨 구분자 8행, 코드 펜스 주석 1행 |
| git-pr/SKILL.md | negation | 1 | 정당한 대조 | 생성 명령이 SHA를 쓴다는 오해를 바로잡는 대조 |
| git-pr/templates/pr-body-template.md | emdash | 2 | 형식 고정·구분자 용법 | 템플릿 안내 HTML 주석 1행, 리스크 항목의 라벨 구분자 1행 |
| git-pr-feedback/SKILL.md | emdash | 29 | 구분자 용법·코드 블록 리터럴·형식 고정 | 리스트 라벨 14행, 표 셀 4행, 코드 펜스 주석 10행, 선택지 명칭 "수용 — 원장 등재" 1행 |
| git-pr-feedback/SKILL.md | negation | 3 | 정당한 대조 | 완벽한 방어가 기준이라는 오해, 출처에 파일 경로를 적는 오해, 회귀를 과거 부채로 보는 오해를 각각 바로잡는 대조 |
| git-qa/SKILL.md | emdash | 4 | 구분자 용법 | 참조 문서 리스트에서 경로와 설명을 가르는 구분자 |
| git-qa/templates/qa-checklist-template.md | emdash | 5 | 형식 고정·구분자 용법 | 템플릿 안내 HTML 주석 1행, 체크 항목과 증빙을 가르는 구분자 4행 |
| git-review/SKILL.md | emdash | 10 | 구분자 용법 | 참조 문서 5행, 임시 파일 목록 2행, 볼드 라벨 캡션 2행, 예시 뒤 부연 1행 |
| git-review/templates/review-result-template.md | emdash | 8 | 형식 고정·구분자 용법 | 템플릿 안내 HTML 주석 6행, 표 셀 1행, 산출물 헤더 형식 1행 |
| git-review-context/SKILL.md | emdash | 4 | 구분자 용법 | 참조 문서 리스트에서 경로와 설명을 가르는 구분자 |
| issue-work/SKILL.md | emdash | 15 | 구분자 용법·형식 고정·코드 블록 리터럴 | 표 셀 8행, 참조 문서 리스트 라벨 3행, 코드 펜스 안 댓글 형식 2행, 볼드 라벨 캡션 1행, 접기 제목 기본형 1행 |
| issue-work/SKILL.md | negation | 1 | 정당한 대조 | `--clear`가 이슈 디렉토리를 삭제한다는 오해를 바로잡는 대조 |
| issue-work/templates/issue-spec-template.md | emdash | 14 | 형식 고정·구분자 용법 | 템플릿 안내 HTML 주석 8행, 리스트 라벨 구분자 4행, 플레이스홀더 라벨 구분자 1행, 접기 제목 기본형 1행 |
| issue-work/templates/issue-spec-template.md | negation | 1 | 정당한 대조 | 레벨 태그를 이슈 단위로 붙인다는 오해를 바로잡는 대조 |
| issue-work/templates/issue-plan-template.md | emdash | 18 | 형식 고정·구분자 용법 | 접기 제목 기본형 6행, 리스트 라벨 구분자 5행, 템플릿 안내 HTML 주석 3행, 볼드 라벨 캡션 2행, 플레이스홀더 라벨 구분자 2행 |
| issue-work/templates/issue-plan-template.md | negation | 5 | 정당한 대조 | 설계 종료 게이트를 실행 Task로, 문서 검증을 문구 대조로, 명령 보정을 반례 격추로, audit을 결정적 게이트의 대체로, Task N 완료 기준 5항목을 순서로 오해하는 것을 각각 바로잡는 대조 |
| issue-work/templates/issue-summary-template.md | emdash | 11 | 형식 고정 | 지표 표기·집계 스니펫·다음 작업 예시를 설명하는 템플릿 안내 HTML 주석 |
| issue-audit/SKILL.md | emdash | 28 | 구분자 용법·코드 블록 리터럴 | 리스트 라벨 구분자 23행, 볼드 라벨 캡션 2행, 표 셀 2행, 코드 펜스 안 출력 형식 1행 |
| issue-audit/SKILL.md | negation | 2 | 정당한 대조 | 동작하면 통과라는 오해와 승격을 원인 해소로 보는 오해를 각각 바로잡는 대조 |
| issue-audit/templates/issue-audit-report-template.md | emdash | 15 | 형식 고정·구분자 용법 | 템플릿 안내 HTML 주석 11행, 산출물 요약 형식 2행, 머리말 플레이스홀더 라벨 구분자 1행, 표 셀 1행 |
| issue-audit/templates/issue-audit-report-template.md | negation | 1 | 정당한 대조 | 재발 항목을 기등재 참조 표에 적는다는 오해를 바로잡는 대조 |
| ai-workspace/SKILL.md | emdash | 12 | 구분자 용법·코드 블록 리터럴 | 리스트 라벨 4행, 표 셀 3행, 코드 펜스 주석 3행, 볼드 라벨 캡션 1행, 괄호 안 라벨 구분 1행 |
| ai-workspace-directory/SKILL.md | emdash | 12 | 구분자 용법 | 리스트 라벨 8행, 표 셀 4행 |
| ai-workspace-directory/references/examples.md | emdash | 8 | 코드 블록 리터럴 | 진단 리포트·완성 예시의 출력 형식 코드 펜스 안 |
| ai-workspace-directory/references/ssot-checklist.md | emdash | 1 | 구분자 용법 | 판정 기준 괄호 안의 라벨 구분자 |
| ai-workspace-directory/references/standard-structure.md | emdash | 1 | 코드 블록 리터럴 | 골격 코드 펜스 안의 플레이스홀더 라벨 구분자 |
| ai-workspace/templates/shared/.ai/10_rules/context-loading.md | emdash | 6 | 구분자 용법 | 참조 문서 리스트에서 경로와 설명을 가르는 구분자 |
| ai-workspace/templates/shared/.ai/10_rules/writing-principles.md | emdash | 2 | 형식 고정·메타 사용 | SYNCED 마커 HTML 주석 1행, em dash 금지 규칙을 인용하는 행 1행 |
| ai-workspace/templates/shared/.ai/10_rules/writing-principles.md | negation | 1 | 메타 사용 | 부정 대조 금지 규칙을 인용하는 행 |
| ai-workspace/templates/shared/.ai/70_ledger/index.md | emdash | 9 | 구분자 용법·형식 고정 | 표 셀 8행, 선택지 명칭 "수용 — 원장 등재" 1행 |
| ai-workspace/templates/shared/.ai/70_ledger/ledger-entry-template.md | emdash | 7 | 형식 고정 | 템플릿 안내·필드 설명 HTML 주석 |
| .ai/10_rules/context-loading.md | emdash | 6 | 구분자 용법 | 동기화 사본. 템플릿 원본과 같은 리스트 라벨 구분자 |
| .ai/10_rules/writing-principles.md | emdash | 2 | 형식 고정·메타 사용 | 동기화 사본. 템플릿 원본과 같은 SYNCED 마커 1행, 규칙 인용 1행 |
| .ai/10_rules/writing-principles.md | negation | 1 | 메타 사용 | 동기화 사본. 템플릿 원본과 같은 규칙 인용 |
| .ai/70_ledger/index.md | emdash | 9 | 구분자 용법·형식 고정 | 상이 쌍 사본. 공통 서술부의 표 셀 8행, 선택지 명칭 1행 |
| .ai/70_ledger/ledger-entry-template.md | emdash | 7 | 형식 고정 | 동기화 사본. 템플릿 원본과 같은 안내 HTML 주석 |
| code-map/SKILL.md | emdash | 7 | 구분자 용법 | 참조 문서 리스트 라벨 4행, 괄호 안 라벨 구분 1행, 표 셀 2행 |
| code-map/references/global.md | emdash | 7 | 구분자 용법 | 수집 절차 번호 리스트의 볼드 라벨 4행, 산출물 예시 캡션의 파일명 라벨 3행 |
| code-map/references/local.md | emdash | 2 | 코드 블록 리터럴 | index.md 예시 표의 생략 표기 1행, 그 표기를 인용한 인라인 코드 1행 |
| context-harvest/SKILL.md | emdash | 4 | 구분자 용법 | 참조 문서 리스트 라벨 3행, 증분 지원 목록의 라벨 구분자 1행 |
| context-save/SKILL.md | emdash | 4 | 구분자 용법 | 참조 문서 리스트에서 경로와 설명을 가르는 구분자 |
| context-save/SKILL.md | negation | 1 | 정당한 대조 | 대화 로그를 그대로 옮겨 적는다는 오해를 바로잡는 대조 (핵심 원칙이 대화 재현 금지다) |
| install-skills/SKILL.md | emdash | 7 | 구분자 용법·코드 블록 리터럴 | 코드 펜스 안 주석·출력 문자열 4행, 표 셀 2행, 볼드 라벨 캡션 1행 |
| install-skills/references/antigravity-legacy.md | emdash | 4 | 구분자 용법 | 판정 기준 표 셀에서 처리와 사유를 가르는 구분자 |
| install-skills/references/antigravity-legacy.md | negation | 1 | 정당한 대조 | 구 경로 리터럴을 SKILL.md가 보유한다는 오해를 바로잡는 대조 |
| install-skills/templates/install-result-template.md | emdash | 12 | 형식 고정·구분자 용법 | 템플릿 안내 HTML 주석 7행, 플레이스홀더 라벨 구분자 4행, 목록 항목 라벨 1행 |
| readme-sync/SKILL.md | emdash | 9 | 코드 블록 리터럴·구분자 용법 | 대화형 질문 선택지 코드 펜스 6행, 판정 결과 볼드 라벨 2행, 표 셀 1행 |
| readme-sync/templates/README-template.md | emdash | 3 | 형식 고정·구분자 용법 | 템플릿 안내 HTML 주석 2행, 플레이스홀더 라벨 구분자 1행 |
| .ai/AI-CONTEXT.md | emdash | 4 | 구분자 용법 | 프로젝트 규칙 번호 리스트의 볼드 라벨 구분자 |
| .ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md | emdash | 7 | 구분자 용법 | 근거·대안 리스트의 볼드 라벨 6행, 원본 출처 링크 텍스트의 이슈 번호 구분자 1행 |
| .ai/70_ledger/active/K-0001-update3-fixture-absent.md | emdash | 1 | 형식 고정 | `ai-workspace/SKILL.md` update-3단계 소제목 "이동 제외 — 루트 상주 파일"을 인용한 행 |

**정비 결과 (Task 6 확정, 2026-08-11)**

- 기준 시점 532행 / 49파일에서 정비 후 325행 / 40파일이 되었다. em dash 207행을 수정했고, "가 아니라" 18행은 행별 심사 결과 전부 정당한 대조·메타 사용이라 유지했다.
- 위 표 51행(emdash 40행, negation 11행)이 잔존 전량을 설명한다. 등재 없는 잔존 0건, 실체 없는 등재 0건이다.
- 분류 `수용` 행이 0건이라 원장(`.ai/70_ledger/`) 신규 등재 대상이 없다.

<details>
<summary>역방향 대조 명령 — 출력 0건이면 통과</summary>

Task별·DoD 검증 스니펫은 잔존이 0행인 파일을 건너뛰므로 실체 없는 등재 행을 잡지 못한다. 표에서 출발해 실제 파일을 대조하는 방향이 필요하다.

```bash
EX=.ai/90_issues/archive/issue-0087/issue-0087-exceptions.md
awk -F'|' 'NF>=6 && $2 ~ /\// {f=$2; gsub(/[[:space:]]/,"",f); k=$3; gsub(/[[:space:]]/,"",k); c=$4; gsub(/[[:space:]]/,"",c); if (k=="emdash"||k=="negation") print f"\t"k"\t"c}' "$EX" \
| while IFS=$'\t' read -r f k c; do
  if [ ! -f "$f" ]; then echo "위반: $f 파일 없음"; continue; fi
  if [ "$k" = emdash ]; then n=$(grep -c '—' "$f"); else n=$(grep -c '가 아니라' "$f"); fi
  [ "$n" = "$c" ] || echo "위반: $f $k 실제 $n행, 등재 $c행"
done
```

</details>

**수사적 콜론 전수 확인 (audit `--response` 보정, 2026-08-11)**

- 1차 교차모델 audit이 미정비로 제기한 5행을 심사 지침 3번의 값 제시 도입 콜론 예외로 판정했다. 스킬 문서는 수정하지 않았고 예외 목록에도 등재하지 않는다. 지침 3번 예외는 심사 대상 밖이라 등재 대상이 아니기 때문이다.
- 같은 기준으로 스캔 스코프 전체를 통독해 **미정비 수사적 콜론 0건**을 확인했다. 후보 18행이 전부 값 제시 도입(6행), 리스트 라벨 형식(4행), HTML 주석 안(4행), 규칙 인용 메타 사용(4행)에 해당한다.
- 범주별 내역은 3차 audit(F-5 잔여)이 합계 오기를 제기해 정정했다. HTML 주석 4행은 `70_ledger/ledger-entry-template.md:19`의 원본·사본 2행과 `issue-plan-template.md:136`, `issue-summary-template.md:60`이고(마지막 행은 39행에서 열린 주석 블록 안이다), 규칙 인용 4행은 `writing-principles.md` 43·49행의 원본·사본 2벌이다. 정정 전 기록은 규칙 인용을 2행으로 세고 그 차이를 HTML 주석에 얹은 값이었다. 네 범주 합이 후보 18행과 일치하며, 후보가 전부 허용 범주라는 판정 자체는 바뀌지 않았다.
- 통독 중 지침 3번에 HTML 주석 예외가 빠져 있는 공백을 찾아 함께 명문화했다. em dash 항목에만 있던 규정이라 콜론 심사에서 근거가 비어 있었다.

<details>
<summary>후보 추출 명령 — 코드 펜스·표 밖에서 완결 문장 뒤 콜론을 뽑아 통독 대상으로 삼는다</summary>

수사적 콜론은 grep으로 판정할 수 없으므로 후보만 좁히고 판정은 통독으로 한다. 콜론 앞이 한국어 종결어미로 끝나는 행이 후보다.

```bash
find . -name '*.md' -not -path './.git/*' -not -path './.ai/90_issues/*' -not -path '*/tests/*' | sort | while read -r f; do
  awk -v F="${f#./}" '
    /^[[:space:]]*```/ { fence = !fence; next }
    fence { next }
    /^[[:space:]]*\|/ { next }
    /(다|니다|요|음|함)[[:space:]]*:[[:space:]]*[^[:space:]]/ { printf "%s:%d\t%s\n", F, NR, $0 }
  ' "$f"
done
```

HTML 주석 여부는 이 명령이 가리지 못하므로 후보별로 여는 마커를 거슬러 확인한다.

</details>

**라벨 콜론 뒤 em dash 전수 확인 (audit `--response` 2차 보정, 2026-08-11)**

- 2차 audit(F-6)이 라벨 콜론 뒤 em dash의 무조건 수정 서술과 예외 표의 충돌을 제기했다. 그 서술을 문자 그대로 적용하면 spec 전제가 유지 대상으로 확정한 참조 문서 구분자(공통 규칙 행 11개 파일)까지 수정 대상이 되므로, 표의 재분류 대신 심사 지침 1번의 해당 규정을 원장 사례가 겨냥한 범위(콜론 뒤 서술 흐름 중간의 em dash)로 좁혔다.
- 좁힌 기준으로 코드 펜스·표·HTML 주석 밖의 라벨 콜론 뒤 em dash 후보 29행을 전수 대조해 **지침과 표의 충돌 0건**을 확인했다. 내역은 참조 문서·공통 규칙 라벨 구분자 11행, 콜론 뒤 짧은 명사구 라벨과 부연을 가르는 구분자 8행, 괄호 안 라벨 구분 2행, 플레이스홀더 라벨 구분자 4행, 산출물 요약 형식 2행, 인라인 코드 인용 2행이며 전부 기존 등재 근거와 일치한다. 파일 수정 0건이라 허용 건수도 불변이다.

<details>
<summary>후보 추출 명령 — 코드 펜스·표·HTML 주석 밖에서 라벨 콜론 뒤 em dash 행을 뽑아 통독 대상으로 삼는다</summary>

판정은 통독으로 한다. 리스트 행에서 콜론이 나온 뒤 em dash가 이어지는 행이 후보다.

```bash
find . -name '*.md' -not -path './.git/*' -not -path './.ai/90_issues/*' -not -path '*/tests/*' | sort | while read -r f; do
  awk -v F="${f#./}" '
    /^[[:space:]]*```/ { fence = !fence; next }
    fence { next }
    /<!--/ { comment = 1 }
    comment { if (/-->/) comment = 0; next }
    /^[[:space:]]*\|/ { next }
    /^[[:space:]]*[-*].*[^ ]: .*—/ { printf "%s:%d\t%s\n", F, NR, $0 }
  ' "$f"
done
```

</details>

---

<details>
<summary>기준 시점 잔존 현황 (2026-08-11, 파일별 행 수)</summary>

유형별 분포는 spec `## 전제 (Assumptions)`의 기준 시점 실측 항목에 있다.

| 파일 | emdash 행 | negation 행 |
|------|-----------|--------------|
| .ai/10_rules/context-loading.md | 6 | 0 |
| .ai/10_rules/writing-principles-local.md | 2 | 0 |
| .ai/10_rules/writing-principles.md | 2 | 1 |
| .ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md | 7 | 0 |
| .ai/70_ledger/active/K-0001-update3-fixture-absent.md | 3 | 0 |
| .ai/70_ledger/active/K-0002-audit-axis-tiebreak-absent.md | 1 | 0 |
| .ai/70_ledger/active/K-0003-approved-file-content-unverified.md | 1 | 0 |
| .ai/70_ledger/active/K-0005-install-template-exclude-pattern-literal.md | 1 | 0 |
| .ai/70_ledger/index.md | 15 | 0 |
| .ai/70_ledger/ledger-entry-template.md | 7 | 0 |
| .ai/AI-CONTEXT.md | 6 | 0 |
| ai-workspace-directory/SKILL.md | 15 | 0 |
| ai-workspace-directory/references/examples.md | 8 | 0 |
| ai-workspace-directory/references/ssot-checklist.md | 1 | 0 |
| ai-workspace-directory/references/standard-structure.md | 2 | 0 |
| ai-workspace/SKILL.md | 17 | 0 |
| ai-workspace/templates/dev/.ai/AI-CONTEXT.md | 2 | 0 |
| ai-workspace/templates/doc/.ai/AI-CONTEXT.md | 2 | 0 |
| ai-workspace/templates/shared/.ai/10_rules/context-loading.md | 6 | 0 |
| ai-workspace/templates/shared/.ai/10_rules/writing-principles-local.md | 2 | 0 |
| ai-workspace/templates/shared/.ai/10_rules/writing-principles.md | 2 | 1 |
| ai-workspace/templates/shared/.ai/70_ledger/index.md | 15 | 0 |
| ai-workspace/templates/shared/.ai/70_ledger/ledger-entry-template.md | 7 | 0 |
| code-map/SKILL.md | 7 | 0 |
| code-map/references/global.md | 7 | 0 |
| code-map/references/local.md | 4 | 0 |
| context-harvest/SKILL.md | 5 | 0 |
| context-save/SKILL.md | 5 | 1 |
| git-pr-feedback/SKILL.md | 78 | 3 |
| git-pr/SKILL.md | 41 | 1 |
| git-pr/templates/pr-body-template.md | 2 | 0 |
| git-qa/SKILL.md | 5 | 0 |
| git-qa/templates/qa-checklist-template.md | 5 | 0 |
| git-review-context/SKILL.md | 5 | 0 |
| git-review/SKILL.md | 20 | 0 |
| git-review/templates/review-result-template.md | 8 | 0 |
| install-skills/SKILL.md | 11 | 0 |
| install-skills/references/antigravity-legacy.md | 6 | 1 |
| install-skills/templates/install-result-template.md | 12 | 0 |
| issue-audit/SKILL.md | 53 | 2 |
| issue-audit/templates/issue-audit-report-template.md | 16 | 1 |
| issue-work/SKILL.md | 41 | 1 |
| issue-work/templates/issue-plan-template.md | 27 | 5 |
| issue-work/templates/issue-spec-template.md | 14 | 1 |
| issue-work/templates/issue-summary-template.md | 13 | 0 |
| issue-work/templates/issue-workflow-template.md | 3 | 0 |
| readme-sync/SKILL.md | 10 | 0 |
| readme-sync/references/license.md | 1 | 0 |
| readme-sync/templates/README-template.md | 3 | 0 |
| **합계** | **532** | **18** |

스캔 스코프에 있으나 위 표에 없는 파일(README.md, .claude/CLAUDE.md 등)은 두 패턴 모두 0행이다.

</details>
