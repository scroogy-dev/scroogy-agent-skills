# Issue #147 감사 리포트 git-review-quiz·ai-workspace·issue-work: en_US.UTF-8 로케일에서 헬퍼와 러너의 한글 문자열 비교가 틀리는 것을 고친다

> 감사 일시: 2026-11-27  
> 감사 모델: Google, Gemini 4 Neon (-)  
> 감사 effort: high  
> 감사 회차: 1차 (이전 리포트: 없음)  
> 감사 대상 브랜치: issue-0147  
> 감사 대상 커밋: 98f2a6ba38b3914d906019a4496cb1024abe1c18  
> 스펙 출처: [스펙](./issue-0147-spec.md) · [계획](./issue-0147-plan.md) · [수행 요약](./issue-0147-summary.md) (작성 시점 경로는 `.ai/90_issues/active/issue-0147/`, --clear로 이관)

---

## 종합 의견

🔴 부적합(FAIL)

<details>
<summary>종합 의견 펼치기</summary>

`check-quiz.sh`, `check-context.sh`, 세 러너(git-review-quiz·ai-workspace·issue-work)의 로케일 고정과 회귀 케이스는 AC1~AC4·AC6과 D3을 모두 충족한다. 그러나 Task 4가 비교 없음으로 기록한 `ai-workspace-directory/scripts/check-lobby.sh` 167행(`v != "active"` 비교)이 `en_US.UTF-8`에서 `active예정` 같은 한글 혼용 값을 정상으로 통과시켜 AC5·D4가 미충족(D1·D2는 부분 충족)이다. 다음 회차에서 `check-lobby.sh`에 D1 수정과 D2 회귀 케이스, plan `테스트 계획`의 AC5 `[D]` 줄을 반영하고 재감사를 받아야 한다.

</details>

## 요약

- 1단계 적합성: 🔴 미충족(FAIL) · 충족(PASS) 6건 / 미충족(FAIL) 2건 / 부분 충족(PARTIAL) 2건 / 판정 불가(N/A) 0건
- 2단계 위험도: 🔴 보완 필요(FAIL) · 높음(HIGH) 1건 / 중간(MEDIUM) 0건 / 낮음(LOW) 1건 / 정보(INFO) 1건
- 코드 레벨 검증: 읽은 파일 13개 / 읽지 않은 파일 0개
- 기등재 참조: 2건 (원장 기등재와 일치 — 위험도·카테고리 집계에 포함하지 않음)
- 이전 발견: 해당 없음

| 카테고리 | 건수 |
|----------|------|
| 기능 | 0 |
| 아키텍처 | 0 |
| 버그 | 높음(HIGH) 1 · 낮음(LOW) 1 |
| 보안 | 0 |
| 코드품질 | 정보(INFO) 1 |
| 성능 | 0 |
| 테스트 | 0 |

---

## 1단계: 적합성 검증 (Compliance Check)

### 완료의 정의(DoD) 대조

| AC | 완료의 정의 항목 | 판정 | 근거 |
|----|------------------|------|------|
| AC1 | `check-quiz.sh`가 같은 입력에 대해 `C.UTF-8`과 `en_US.UTF-8`에서 같은 출력과 종료 코드를 낸다. | 🟢 충족(PASS) | `locale -a`에 `en_US.UTF-8`·`C.UTF-8` 존재 확인. `git-review-quiz/tests/run-tests.sh` 실행에서 `로케일:` 케이스 3건(`valid-interactive.md`, `valid-comment.md`, `invalid-r7-duplicate-target.md`) 모두 건너뜀 없이 `ok` 통과 |
| AC2 | `check-context.sh`가 같은 입력에 대해 `C.UTF-8`과 `en_US.UTF-8`에서 같은 출력과 종료 코드를 낸다. | 🟢 충족(PASS) | `ai-workspace/tests/run-tests.sh` 실행에서 `로케일:` 케이스 4건(정상 dev·doc 사본, `profile_state` 경로, `dev_residue` 경로) 모두 건너뜀 없이 `ok` 통과 |
| AC3 | git-review-quiz 러너가 `LC_ALL=en_US.UTF-8`에서 실패 0건으로 끝난다. | 🟢 충족(PASS) | `LC_ALL=en_US.UTF-8 bash git-review-quiz/tests/run-tests.sh` 실행 결과 `passed: 126, failed: 0`, 종료 코드 0 |
| AC4 | ai-workspace 러너가 `LC_ALL=en_US.UTF-8`에서 실패 0건으로 끝난다. | 🟢 충족(PASS) | `LC_ALL=en_US.UTF-8 bash ai-workspace/tests/run-tests.sh` 실행 결과 `passed: 234, failed: 0`, 종료 코드 0 |
| AC5 | `verify-submit.sh`, `verify-push.sh`, `check-lobby.sh`, `summarize-metrics.sh`, `check-clear.sh`마다 로케일에 따라 결과가 달라지는 비교가 있는지 확인한 결과가 남고, 있는 헬퍼는 두 로케일에서 같은 결과를 낸다. | 🔴 미충족(FAIL) | `[QD]` 소스 대조와 재현으로 `ai-workspace-directory/scripts/check-lobby.sh` 167행(`v != "active" && v != "placeholder" && v != "archived"`)이 두 로케일에서 다른 결과를 냄을 확인했다(`active예정` 입력 시 `C.UTF-8`은 위반 2행·종료 코드 1, `en_US.UTF-8`은 무출력·종료 코드 0). summary Task 4는 비교 없음으로 기록했고 헬퍼를 고치지 않았다(F-1) |
| AC6 | issue-work 러너가 `LC_ALL=en_US.UTF-8`에서 실패 0건으로 끝난다. | 🟢 충족(PASS) | `LC_ALL=en_US.UTF-8 bash issue-work/tests/run-tests.sh` 실행 결과 `passed: 872, failed: 0`, 종료 코드 0 |

### 결정 사항 대조

| D | 결정 | 판정 | 근거 |
|---|------|------|------|
| D1 | 로케일에 따라 결과가 달라지는 비교가 있는 배포 헬퍼와 git-review-quiz·ai-workspace·issue-work 러너는 스크립트 머리에 `export LC_ALL=C`를 둔다. | 🟡 부분 충족(PARTIAL) | `check-quiz.sh`, `check-context.sh`, 세 러너에는 `set -o pipefail` 바로 뒤에 주석과 `export LC_ALL=C`를 두었다. 로케일 의존 비교가 있는 `check-lobby.sh`에는 누락됐다(F-1) |
| D2 | 로케일 회귀 케이스를 러너에 두고, 고친 헬퍼마다 같은 입력을 `C.UTF-8`과 `en_US.UTF-8`로 실행해 출력과 종료 코드가 같은지 본다. | 🟡 부분 충족(PARTIAL) | `git-review-quiz/tests/run-tests.sh`와 `ai-workspace/tests/run-tests.sh`에 `assert_locale_same`과 `로케일:` 케이스를 두었다. `check-lobby.sh`를 고치지 않아 `ai-workspace-directory/tests/run-tests.sh`에 회귀 케이스가 없다(F-1) |
| D3 | 실행하는 머신에 `en_US.UTF-8`이 없으면 D2 케이스는 실행하지 않고 건너뛴 사실을 한 줄 출력하며 실패로 세지 않는다. | 🟢 충족(PASS) | 두 러너 모두 `locale -a 2>/dev/null \| grep -iE '^en_US\.utf-?8$' > /dev/null`로 판정하고, 없으면 `ok "$desc — 건너뜀 (en_US.UTF-8 없음)"`을 출력해 실패로 세지 않는다 |
| D4 | 헬퍼 5개마다 로케일에 따라 결과가 달라지는 비교가 있는지와 그 근거를 summary Task 4에 적고, 있는 헬퍼만 D1 방식으로 고치고 D2 케이스를 더한다. | 🔴 미충족(FAIL) | 5개 항목이 summary Task 4에 남았으나 `check-lobby.sh`의 "비교 없음" 판정이 소스와 어긋나며, 그 결과 D1 수정과 D2 케이스 추가가 빠졌다(F-1) |

### 경계 검증

- **스펙 요구사항의 제외 목록 침범 여부**: 없음. `issue-audit/scripts/check-plan.sh`와 `issue-audit/tests/run-tests.sh`는 변경하지 않았다.
- **스펙에 없는 추가 구현 여부**: 없음. 변경 파일 13개는 이슈 문서(4개), 계획 감사 `--response` 승인 원장 등재(4개), Task 1~3 대상 헬퍼·러너(5개)로 한정된다.

### 도메인/계약 정합성

- `.ai/30_contract/`·`.ai/40_domain/`: `check-lobby.sh`의 status 열거값 검사 누락(F-1)이 `.ai/40_domain/specs/ai-workspace.md`의 형식 위배 판정 요건과 `en_US.UTF-8` 환경에서 어긋난다. 나머지 변경은 도메인·계약 문서와 충돌하지 않는다.
- `.ai/50_adr/`: ADR 0001(러너 배치·외부 의존성 없음), ADR 0003(검증 레벨), ADR 0019·0031(Task 1~3의 테스트 먼저 커밋 순서 `e3c5097`→`3b08215`, `e98114d`→`6f58cb2`, `5b8113f`→`9426505`와 summary `테스트` 기록)과 정합한다.
- `.ai/60_codebase/`: 변경된 `check-quiz.sh`·`check-context.sh`의 호출 순서·인자·종료 코드 규약은 바뀌지 않아 색인과 실제 코드의 불일치가 없다.

---

## 2단계: 비판적 검증 (Critical Review)

### 발견 사항

| # | 위험도 | 영향 | 발생확률 | 카테고리 | 계보 | 설명 | 관련 파일 |
|---|--------|------|----------|----------|------|------|-----------|
| F-1 | 🔴 높음(HIGH) | 스펙·기능 달성 차단 | 통상 사용 | 버그 | 신규 | `check-lobby.sh` 167행 `awk` 문자열 `!=` 비교가 `en_US.UTF-8`에서 한글이 붙은 잘못된 `status` 값을 통과시키는데 Task 4가 비교 없음으로 오판해 수정·테스트를 누락함 | `ai-workspace-directory/scripts/check-lobby.sh:167`, `.ai/90_issues/archive/issue-0147/issue-0147-summary.md:138`, `.ai/90_issues/archive/issue-0147/issue-0147-plan.md:34` |
| F-2 | 🟢 낮음(LOW) | 기능 저하 | 특수 조건·엣지 | 버그 | 신규 | `verify-submit.sh` 108행과 `verify-push.sh` 105행의 `case` 문자 범위 `*[!0-9a-fA-F]*`가 `en_US.UTF-8`에서 분음 부호 라틴 문자(`é` 등)를 16진 문자로 허용해 종료 코드가 갈림 | `git-pr/scripts/verify-submit.sh:108`, `git-pr-feedback/scripts/verify-push.sh:105` |
| F-3 | ⚪ 정보(INFO) | 기술 품질 의견 | 특수 조건·엣지 | 코드품질 | 신규 | `ai-workspace/tests/run-tests.sh` 20행 주석과 summary Task 2가 `en_US.UTF-8` 실패 원인을 `check-ide-tool-list.sh`로 적었으나 실제 실패 지점은 러너 내부 `ide_decision_violations` 함수임 | `ai-workspace/tests/run-tests.sh:20`, `ai-workspace/tests/run-tests.sh:334-337`, `.ai/90_issues/archive/issue-0147/issue-0147-summary.md:106` |

### 상세 분석

#### F-1: `check-lobby.sh`의 `status` 열거값 비교가 `en_US.UTF-8`에서 한글 혼용 값을 통과시킴

- **위험도**: 🔴 높음(HIGH)
- **영향 축**: 스펙·기능 달성 차단
- **발생확률 축**: 통상 사용
- **카테고리**: 버그
- **관점**: 암묵적 가정
- **계보**: 신규
- **권장 조치**: `ai-workspace-directory/scripts/check-lobby.sh`의 `set -o pipefail` 바로 다음에 D1 방식의 주석과 `export LC_ALL=C`를 추가한다. `ai-workspace-directory/tests/run-tests.sh`에 D2·D3 규격의 `로케일:` 회귀 케이스(정상 fixture와 `active예정` 같은 한글 혼용 `status` 입력)를 추가하고, plan `설계 결정`·`테스트 계획`(AC5 `[D]` 줄 추가 및 계획 감사 재수행 조건 확인)과 summary Task 4 근거를 갱신한다.
- **완료 기준**:
  1. `ai-workspace-directory/scripts/check-lobby.sh`의 `set -o pipefail` 다음에 이유 주석과 `export LC_ALL=C`가 있다.
  2. `ai-workspace-directory/tests/run-tests.sh`에 `로케일:` 회귀 케이스가 있고, `active예정` 같은 한글 혼용 `status` 입력에서 수정 전 실패·수정 후 통과(`C.UTF-8`·`en_US.UTF-8` 모두 위반 출력·종료 코드 1)를 검증한다.
  3. `LC_ALL=en_US.UTF-8 bash ai-workspace-directory/tests/run-tests.sh`가 건너뜀 없이 실패 0건으로 끝난다.
  4. plan `설계 결정`·`테스트 계획`과 summary Task 4의 `check-lobby.sh` 확인 근거가 실제 동작과 일치하게 갱신된다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- **설명**: `issue-0147-plan.md` 34행과 `issue-0147-summary.md` 138·141행은 macOS `awk`의 `en_US.UTF-8` 오동작이 "길이가 같은 한글끼리의 비교"에서만 발생하고 한글과 ASCII 값의 비교는 결과가 같다고 가정했다. 그러나 macOS `awk`의 `strcoll`은 `en_US.UTF-8`에서 한글 음절의 가중치를 무시하므로 `"가" == "가나"`뿐 아니라 `"active예정" == "active"`, `"비active" == "active"`도 참(1)으로 판정한다. 이 때문에 `ai-workspace-directory/scripts/check-lobby.sh` 167행 `if (v != "active" && v != "placeholder" && v != "archived") print v`는 유효 열거값에 한글이 섞인 잘못된 `status`를 걸러내지 못한다.
- **영향**: R5·AC5·D1·D2·D4를 직접 미충족시키며, 한국어 로비 안내도에서 `active예정`·`placeholder대기`·`archived완료` 같은 비표준 `status`가 `en_US.UTF-8` 환경에서 통과한다.
- **실패 시나리오**: `ai-workspace-directory/tests/fixtures/lobby-good.md`의 `| active |`를 `| active예정 |`로 바꾼 파일을 `check-lobby.sh`에 넣으면 `LC_ALL=C.UTF-8`에서는 위반 2행과 종료 코드 1이 나오지만, `LC_ALL=en_US.UTF-8`에서는 무출력·종료 코드 0으로 통과한다.

</details>

#### F-2: `verify-submit.sh`·`verify-push.sh`의 SHA 형식 `case` 범위 패턴이 `en_US.UTF-8`에서 분음 부호 문자를 허용함

- **위험도**: 🟢 낮음(LOW)
- **영향 축**: 기능 저하
- **발생확률 축**: 특수 조건·엣지
- **카테고리**: 버그
- **관점**: 엣지케이스
- **계보**: 신규
- **권장 조치**: 등급별 기본 처리 기준에 따라 원장(`.ai/70_ledger/active/`)에 이관하고 수용 사유·재검토 조건을 적거나, 필요 시 두 스크립트의 SHA 검사에 `LC_ALL=C` 또는 명시적 문자 집합을 적용한다.
- **완료 기준**:
  1. 원장 이관 시 `verify-submit.sh:108`·`verify-push.sh:105`의 `case` 문자 범위 로케일 의존성과 재검토 조건이 원장 항목으로 기록된다.
  2. 수정 선택 시 `ébcdef0` 입력에 대해 두 헬퍼가 `C.UTF-8`과 `en_US.UTF-8` 모두에서 종료 코드 2(SHA 형식 오류)를 낸다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- **설명**: `git-pr/scripts/verify-submit.sh` 108행(`case "$expect" in *[!0-9a-fA-F]*|'')`)과 `git-pr-feedback/scripts/verify-push.sh` 105행(`case "$s" in *[!0-9a-fA-F]*)`)은 bash의 로케일 민감 문자 범위 `[a-f]`를 쓴다. 한글(`가bcdef0`)은 두 로케일 모두 거부되지만, `en_US.UTF-8`에서 정렬 순서상 `a`~`f` 사이에 놓이는 분음 부호 라틴 문자(`é` 등)는 허용된다.
- **영향**: 잘못된 SHA에 분음 부호 라틴 문자가 들어간 경우 `C.UTF-8`에서는 사용오류(종료 코드 2)로 즉시 중단되나 `en_US.UTF-8`에서는 형식 검사를 통과해 뒤 단계 git 조회 실패(종료 코드 1)로 떨어진다. 오통과(종료 코드 0)나 잘못된 push로 이어지지는 않는다.
- **실패 시나리오**: `verify-submit.sh --branch main --expect ébcdef0`을 실행하면 `LC_ALL=C.UTF-8`에서는 `error: --expect 가 SHA 형식이 아닙니다`와 종료 코드 2를 내지만, `LC_ALL=en_US.UTF-8`에서는 형식 검사를 지나 `위반: 로컬 head 가 승인한 SHA 와 다릅니다`와 종료 코드 1을 낸다(`verify-push.sh`의 `--head-oid ébcdef0 --approved-sha ébcdef0`도 동일하게 종료 코드 2 vs 1로 갈린다).

</details>

#### F-3: `ai-workspace/tests/run-tests.sh` 주석과 summary Task 2의 실패 원인 표기 부정확

- **위험도**: ⚪ 정보(INFO)
- **영향 축**: 기술 품질 의견
- **발생확률 축**: 특수 조건·엣지
- **카테고리**: 코드품질
- **관점**: 암묵적 가정
- **계보**: 신규
- **권장 조치**: 다음 보정 기회에 `ai-workspace/tests/run-tests.sh` 20행 주석의 "러너가 부르는 check-ide-tool-list.sh" 표현을 러너 내부의 결정 목록 일치 검사(`ide_decision_violations`)를 가리키도록 다듬는다.
- **완료 기준**:
  1. `ai-workspace/tests/run-tests.sh` 20행 주석이 `check-ide-tool-list.sh`를 오동작 원인으로 지목하지 않는다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- **설명**: `ai-workspace/tests/run-tests.sh` 20행 주석과 `issue-0147-summary.md` 106행은 `en_US.UTF-8`에서 실패한 5건을 `check-ide-tool-list.sh`의 문제로 적었다. 그러나 `ai-workspace/tests/check-ide-tool-list.sh`는 한글 `awk ==` 비교가 없고 `sort`·`comm`에 모두 `LC_ALL=C`를 붙여 두어 `LC_ALL=en_US.UTF-8`에서 단독 실행해도 종료 코드 0으로 통과한다. 실제 실패 원인은 `ai-workspace/tests/run-tests.sh` 334~337행 `ide_decision_violations` 함수의 `dec[c] != "쓰지 않음"`·`dec[c] != "표에 둠"` 비교다.
- **영향**: 런타임 동작이나 테스트 결과에는 영향이 없으나, 나중에 `check-ide-tool-list.sh`를 단독 실행하거나 유지보수할 때 오해를 불러올 수 있다.

</details>

### 기등재 참조 항목

<details>
<summary>기등재 참조 표 펼치기</summary>

| 원장 항목 | 상태 | 대조한 발견 내용 | 재검토 조건 충족 | 처리 |
|-----------|------|------------------|------------------|------|
| K-0047 | 수용 | `git-review-quiz/tests/run-tests.sh` 667~676행과 `ai-workspace/tests/run-tests.sh` 2244~2253행의 로케일 회귀 케이스가 `locale -a`에서 `en_US.UTF-8`만 확인하고 `C.UTF-8` 존재 여부는 확인하지 않는다 | 미충족 | 참조만 |
| K-0048 | 수용 | `git-review-quiz/tests/run-tests.sh` 670~685행과 `ai-workspace/tests/run-tests.sh` 2247~2262행의 `assert_locale_same`이 두 로케일의 출력·종료 코드 동일성만 비교하고 기준 로케일 기대 판정은 단언하지 않는다 | 미충족 | 참조만 |

</details>

### 이전 발견 추적

해당 없음
