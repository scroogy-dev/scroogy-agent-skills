# Issue #147 계획 감사 리포트 git-review-quiz·ai-workspace·issue-work: en_US.UTF-8 로케일에서 헬퍼와 러너의 한글 문자열 비교가 틀리는 것을 고친다

> 감사 일시: 2026-11-27  
> 감사 모델: Google, Gemini 4 Neon (gemini-4-neon-high)  
> 감사 effort: high  
> 감사 회차: 1차 (이전 리포트: 없음)  
> 감사 대상 브랜치: issue-0147  
> 감사 대상 커밋: 53982fefc237e8636fbb7fd86e914fe7a80dac76  
> 스펙 출처: [GitHub 이슈 #147](https://github.com/scroogy-dev/scroogy-agent-skills/issues/147) · [spec](./issue-0147-spec.md) · [plan](./issue-0147-plan.md) (작성 시점 경로는 `.ai/90_issues/active/issue-0147/`, --clear로 이관)

---

## 종합 의견

🔴 부적합(FAIL)

<details>
<summary>종합 의견 펼치기</summary>

이슈 본문의 포함·제외 항목과 AC1~AC6의 추적성은 모두 맞는다. 다만 Task 2(`check-context.sh`) 회귀 케이스 입력이 실제 한글 `==` 비교 경로에 닿지 않아 구현을 빼도 통과하는 테스트가 만들어지며, AC5의 0건 수정 분기 `[D]` 판정과 로케일 미설치 전제 기준도 보정이 필요하다. F-1과 F-2를 보정한 뒤 구현에 들어가야 한다.

</details>

## 요약

- 1단계 적합성: 🟢 충족(PASS) · 충족(PASS) 13건 / 미충족(FAIL) 0건 / 부분 충족(PARTIAL) 0건 / 판정 불가(N/A) 2건
- 2단계 위험도: 🔴 보완 필요(FAIL) · 높음(HIGH) 1건 / 중간(MEDIUM) 1건 / 낮음(LOW) 2건 / 정보(INFO) 0건
- 기등재 참조: 0건 (원장 기등재와 일치, 위험도·카테고리 집계에 포함하지 않음)
- 이전 발견: 해당 없음

| 카테고리 | 건수 |
|----------|------|
| 기능 | 0 |
| 아키텍처 | 0 |
| 버그 | 0 |
| 보안 | 0 |
| 코드품질 | 0 |
| 성능 | 0 |
| 테스트 | 높음(HIGH) 1 · 중간(MEDIUM) 1 · 낮음(LOW) 2 |

---

## 1단계: 적합성 검증 (Compliance Check)

### 요구사항 대조

| # | 이슈 본문 요구 항목 | 판정 | spec 근거 |
|---|---------------------|------|-----------|
| 포함 1 | git-review-quiz의 `check-quiz.sh`가 로케일과 무관하게 같은 판정을 낸다. | 🟢 충족(PASS) | `R1` (spec 15행) |
| 포함 2 | ai-workspace의 `check-context.sh`가 로케일과 무관하게 같은 판정을 낸다. | 🟢 충족(PASS) | `R2` (spec 16행) |
| 포함 3 | git-review-quiz와 ai-workspace의 테스트 러너가 `en_US.UTF-8`에서도 실패 없이 끝난다. | 🟢 충족(PASS) | `R3` (spec 21행) |
| 포함 4 | issue-work의 테스트 러너가 `en_US.UTF-8`에서도 실패 없이 끝난다. | 🟢 충족(PASS) | `R4` (spec 22행) |
| 포함 5 | awk를 쓰면서 `LC_ALL` 지정이 없는 나머지 배포 헬퍼 5개에 같은 비교가 있는지 확인하고, 있으면 고친다. | 🟢 충족(PASS) | `R5` (spec 17행) |
| 제외 1 | issue-audit의 `check-plan.sh`: 대체(#145에서 고쳤다) | 🟢 충족(PASS) | 제외 목록 (spec 26행) |
| 제외 2 | `LC_ALL=C`에서 issue-audit 러너가 첫 검사에서 멈추는 현상: 보류(#145 이전에도 있던 동작이고 원인을 확인하지 않았다) | 🟢 충족(PASS) | 제외 목록 (spec 27행) |
| 검토 필요 1 | 고치는 방식을 스크립트 머리의 `export LC_ALL=C`(issue-audit `check-plan.sh`의 방식)로 할지, 문제가 되는 `awk` 호출에만 `LC_ALL=C`를 붙일지 정한다. | ⚪ 판정 불가(N/A) | 이슈 본문이 결정을 열어 둔 항목 (spec `D1` 44행에 2026-11-27 답변 반영) |
| 검토 필요 2 | 로케일 회귀 케이스를 러너에 둘지, 둔다면 `en_US.UTF-8`이 없는 환경에서 어떻게 할지 정한다. | ⚪ 판정 불가(N/A) | 이슈 본문이 결정을 열어 둔 항목 (spec `D2`·`D3` 45–46행에 2026-11-27 답변 반영) |

### 완료의 정의(DoD) 대조

| AC | 완료의 정의 항목 | 판정 | 근거 |
|----|------------------|------|------|
| AC1 | `check-quiz.sh`가 같은 입력에 대해 `C.UTF-8`과 `en_US.UTF-8`에서 같은 출력과 종료 코드를 낸다. | 🟢 충족(PASS) | `(R1)`, `R1` 포함 목록 존재 (`check-plan.sh --trace` 0건) |
| AC2 | `check-context.sh`가 같은 입력에 대해 `C.UTF-8`과 `en_US.UTF-8`에서 같은 출력과 종료 코드를 낸다. | 🟢 충족(PASS) | `(R2)`, `R2` 포함 목록 존재 (`check-plan.sh --trace` 0건) |
| AC3 | git-review-quiz 러너가 `LC_ALL=en_US.UTF-8`에서 실패 0건으로 끝난다. | 🟢 충족(PASS) | `(R3)`, `R3` 포함 목록 존재 (`check-plan.sh --trace` 0건) |
| AC4 | ai-workspace 러너가 `LC_ALL=en_US.UTF-8`에서 실패 0건으로 끝난다. | 🟢 충족(PASS) | `(R3)`, `R3` 포함 목록 존재 (`check-plan.sh --trace` 0건) |
| AC5 | `verify-submit.sh`, `verify-push.sh`, `check-lobby.sh`, `summarize-metrics.sh`, `check-clear.sh`마다 로케일에 따라 결과가 달라지는 비교가 있는지 확인한 결과가 남고, 있는 헬퍼는 두 로케일에서 같은 결과를 낸다. | 🟢 충족(PASS) | `(R5)`, `R5` 포함 목록 존재 (`check-plan.sh --trace` 0건) |
| AC6 | issue-work 러너가 `LC_ALL=en_US.UTF-8`에서 실패 0건으로 끝난다. | 🟢 충족(PASS) | `(R4)`, `R4` 포함 목록 존재 (`check-plan.sh --trace` 0건) |

### 경계 검증

- **스펙 요구사항의 제외 목록 침범 여부**: 없음. `issue-audit/scripts/check-plan.sh`와 `issue-audit/tests/run-tests.sh`는 변경 대상에서 제외되어 있다.
- **스펙에 없는 추가 구현 여부**: 없음. 일반 Task 1~4 모두 `R1`~`R5`에 대응하며, `ai-workspace/tests/check-ide-tool-list.sh`도 별도 수정 없이 러너 상속으로 범위를 한정했다.

### 도메인/계약 정합성

- `.ai/30_contract/`(`ai-tool-skill-paths.md`, `github-integration.md`): 충돌 없음.
- `.ai/40_domain/`(`specs/issue-workflow.md`, `specs/issue-audit.md`, `specs/git-review-quiz.md`, `specs/ai-workspace.md`): 충돌 없음.
- `.ai/50_adr/`: ADR 0001(러너 배치·외부 의존성 없음), ADR 0003(검증 레벨·강등 사유), ADR 0031(한 문장 요구사항·테스트 계획·테스트 먼저 구조)과 큰 틀에서 맞는다. 다만 `.ai/10_rules/testing-principles.md`의 전제 조건 미충족 시 `판정 불가(N/A)` 규칙과 D3 `건너뜀` 출력의 판정 연결이 빠져 있다(F-3). `.ai/10_rules/testing-principles-local.md`는 테스트 층 표가 비어 있어 층·러너 표 대조 대상이 없다.

---

## 2단계: 비판적 검증 (Critical Review)

### 발견 사항

| # | 위험도 | 영향 | 발생확률 | 카테고리 | 계보 | 설명 | 관련 파일 |
|---|--------|------|----------|----------|------|------|-----------|
| F-1 | 🔴 높음(HIGH) | 스펙·기능 달성 차단 | 통상 사용 | 테스트 | 신규 | Task 2(`check-context.sh`) 회귀 입력이 실제 한글 `==` 경로에 도달하지 못하고 실패 0건 커밋 예외가 AC2 검증을 무력화한다 | `.ai/90_issues/archive/issue-0147/issue-0147-plan.md` (57, 141–143행), `ai-workspace/scripts/check-context.sh` (95, 207, 226, 371, 378행) |
| F-2 | 🟡 중간(MEDIUM) | 스펙·기능 달성 차단 | 특수 조건·엣지 | 테스트 | 신규 | AC5의 `[D]` 줄이 0건 수정 분기에서 실행할 대상 없이 남아 최종 감사 `판정 불가(N/A)`와 완료 확인 차단을 부른다 | `.ai/90_issues/archive/issue-0147/issue-0147-plan.md` (60, 67, 173, 195행) |
| F-3 | 🟢 낮음(LOW) | 기능 저하 | 특수 조건·엣지 | 테스트 | 신규 | `en_US.UTF-8`·`C.UTF-8` 미설치 환경의 전제 조건과 `건너뜀` 시 `판정 불가(N/A)` 처리 기준이 `테스트 계획`과 `설계 결정`에 빠져 있다 | `.ai/90_issues/archive/issue-0147/issue-0147-plan.md` (33, 56–61행), `.ai/10_rules/testing-principles.md` (41–42행) |
| F-4 | 🟢 낮음(LOW) | 기능 저하 | 특수 조건·엣지 | 테스트 | 신규 | `설계 결정`이 참조한 `issue-audit`의 `assert_locale` 선례와 D2 비교 계약(종료 코드·stderr 처리)이 맞지 않는다 | `.ai/90_issues/archive/issue-0147/issue-0147-plan.md` (32행), `issue-audit/tests/run-tests.sh` (1299–1306행) |

### 상세 분석

#### F-1: Task 2(`check-context.sh`) 회귀 입력이 실제 한글 `==` 경로에 도달하지 못하고 실패 0건 커밋 예외가 AC2 검증을 무력화한다

- **위험도**: 🔴 높음(HIGH)
- **영향 축**: 스펙·기능 달성 차단
- **발생확률 축**: 통상 사용
- **카테고리**: 테스트
- **관점**: 테스트 계획
- **계보**: 신규
- **권장 조치**: Task 2와 `테스트 계획` AC2의 입력을 `check-context.sh`의 실제 한글 `==` 비교 경로 두 곳(`profile_state` 95행, `dev_residue` 371행)을 타도록 수정하고, "재현 입력을 찾지 못하면 실패 0건으로 커밋" 예외를 제거한다. 정상 입력도 치환 전 원본 템플릿 대신 날짜를 치환한 사본(`prepare` 적용)을 쓰도록 명시한다.
- **완료 기준**:
  - Task 2의 회귀 케이스에 `profile_state()`(95행) 경로(`--profile` 모드에서 `## 프로젝트 도메인`을 같은 길이 한글 제목으로 바꾼 입력 또는 기본 모드에서 `## 프로젝트 도메인` 앞에 같은 길이 한글 `## ` 섹션을 둔 입력)와 `dev_residue()`(371행) 경로(`doc` 선언 파일에서 `## .ai 디렉토리 구조` 또는 `## 에이전트 운영 지침`에 같은 길이 한글 제목이 걸리는 입력) 가운데 최소 1개 이상이 명시되어 수정 전 `check-context.sh`에서 실제로 실패한다.
  - Task 2의 "재현 입력을 찾지 못했으면 실패 0건으로 커밋" 문구가 삭제된다.
  - `테스트 계획` AC2 줄의 설명이 수정된 회귀 케이스 입력과 일치하며, 정상 템플릿 입력이 날짜 치환(`prepare`) 여부를 분명히 적는다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- **설명**: `ai-workspace/scripts/check-context.sh`에서 한글 문자열을 `awk`의 `==`로 비교하는 자리는 95행 `profile_state()`(`h == "## 프로젝트 도메인"`)와 371행 `dev_residue()`(`h == head`) 두 곳뿐이다. 기본 모드(`check-context.sh <파일>`)에서 `profile_state()`는 207행 `grep -qE '^ ? ? ?## 프로젝트 도메인[[:space:]]*$'`가 먼저 통과할 때만 호출되고(226행), `dev_residue()`는 378행 `if [ "$line2" = "$SSOT_LINE_DOC" ]`일 때만 호출된다. 그런데 plan Task 2(141행)는 `dev` 템플릿을 기본 모드로 넘기면서 한글 섹션 제목 하나를 같은 길이의 다른 한글 제목으로 바꾸라고 적었다. 이 입력은 `## 프로젝트 도메인`을 바꾸면 207행 `grep`에서 두 로케일 모두 먼저 걸려 `profile_state()`에 도달하지 못하고, 다른 제목을 바꾸면 `dev` 선언이라 378행 `dev_residue()`에 도달하지 못한다. 더불어 원본 `ai-workspace/templates/dev/.ai/AI-CONTEXT.md`는 `YYYY-MM-DD` 자리표시자가 남아 있어 치환 없이는 두 로케일 모두 181행에서 종료 코드 1이 나온다.
- **영향**: Task 2 절차를 그대로 실행하면 재현 입력을 찾지 못해 142–143행의 "실패 0건으로 커밋" 분기로 빠진다. 그 결과 `check-context.sh`에서 `export LC_ALL=C`를 제거해도 통과하는 비유효 회귀 케이스가 커밋되어 AC2 검증과 최종 감사 2단계 관점 5("변경을 되돌리면 실패하는 케이스")가 성립하지 않는다.

</details>

#### F-2: AC5의 `[D]` 줄이 0건 수정 분기에서 실행할 대상 없이 남아 최종 감사 `판정 불가(N/A)`와 완료 확인 차단을 부른다

- **위험도**: 🟡 중간(MEDIUM)
- **영향 축**: 스펙·기능 달성 차단
- **발생확률 축**: 특수 조건·엣지
- **카테고리**: 테스트
- **관점**: 테스트 계획
- **계보**: 신규
- **권장 조치**: 5개 헬퍼 모두 수정 대상이 없을 때(0건 분기) `테스트 계획`의 AC5 `[D]` 줄을 어떻게 처리할지 구현 전에 확정한다. 5개 헬퍼의 비교 유무를 계획 보정 시점에 확인해 `테스트 계획`에 반영하거나, 0건 분기에서도 실행해 합·불을 낼 수 있는 결정적 검증 기준(또는 `[D]` 줄 제거 및 계획 재검증 경로)을 명확히 적는다.
- **완료 기준**:
  - 5개 헬퍼 수정 건수가 0건일 때 최종 감사 1단계에서 AC5가 `판정 불가(N/A)`로 떨어지지 않는 검증 구성이 `테스트 계획`에 명시된다.
  - Task N 전체 회귀(plan 195행)의 "`테스트 계획`의 `[D]` 줄을 모두 실행해 통과를 확인한다" 조건과 충돌하지 않는다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- **설명**: plan `테스트 계획` 60행은 AC5에 `[D]` 줄로 "Task 4에서 고친 헬퍼마다 그 러너의 `로케일:` 회귀 케이스. 고친 헬퍼가 없으면 이 줄은 판정할 대상이 없다"를 두었다. 실제 대상 헬퍼 5개(`verify-submit.sh`, `verify-push.sh`, `check-lobby.sh`, `summarize-metrics.sh`, `check-clear.sh`) 소스를 확인하면 `awk` 안의 한글 문자열 `==`·`!=`·`<`·`>` 비교, `sort`, `[[ … < … ]]`가 보이지 않아 0건 수정 분기에 들 가능성이 높다.
- **영향**: `issue-audit` 1단계 1항은 실패한 줄이 없고 실행하지 못한 `[D]` 줄이 있으면 그 AC를 `판정 불가(N/A)`로 두도록 정한다. 0건 수정 시 60행에 실행할 명령·케이스가 없어 AC5가 `판정 불가(N/A)`로 남으면, `issue-work` 완료 확인에서 `확인` 칸이 채워지지 않아 `다음 회차`를 권장하게 된다. 반대로 구현 중 60행을 지우면 `테스트 계획` 변경에 해당해 계획 감사를 다시 받아야 한다.

</details>

#### F-3: `en_US.UTF-8`·`C.UTF-8` 미설치 환경의 전제 조건과 `건너뜀` 시 `판정 불가(N/A)` 처리 기준이 `테스트 계획`과 `설계 결정`에 빠져 있다

- **위험도**: 🟢 낮음(LOW)
- **영향 축**: 기능 저하
- **발생확률 축**: 특수 조건·엣지
- **카테고리**: 테스트
- **관점**: 테스트 계획
- **계보**: 신규
- **권장 조치**: `테스트 계획`에 `en_US.UTF-8`과 `C.UTF-8` 설치를 실행 전제로 명시하고, 미설치로 `건너뜀` 줄이 출력되거나 로케일이 `C`로 폴백되는 환경에서는 `testing-principles.md`에 따라 AC1~AC6을 통과가 아닌 `판정 불가(N/A)`로 판정함을 적는다. `설계 결정` 33행의 로케일 존재 검사에도 `C.UTF-8`(`C.utf8`) 확인 여부를 함께 정한다.
- **완료 기준**:
  - `테스트 계획`에 `en_US.UTF-8` 미설치로 `건너뜀`이 나오거나 `LC_ALL=en_US.UTF-8`이 폴백되는 환경에서는 통과로 보지 않고 `판정 불가(N/A)`로 둔다는 기준이 기재된다.
  - `설계 결정` 33행에 `C.UTF-8` 존재 여부 확인 기준(함께 검사하거나 `C` 폴백을 허용하는 근거)이 명시된다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- **설명**: `.ai/10_rules/testing-principles.md` 42행은 전제가 갖춰지지 않아 실행하지 못한 테스트를 통과로 보지 않고 `판정 불가(N/A)`로 두도록 정한다. 그러나 `설계 결정` 33행은 `en_US.UTF-8`이 없으면 `ok "<설명> — 건너뜀 (<사유>)"`을 출력하고 종료 코드 0(`failed: 0`)으로 끝내도록 정하면서도, `테스트 계획` AC1~AC6에는 `건너뜀` 출력이나 `en_US.UTF-8` 미설치 환경에서의 판정 불가 처리가 적혀 있지 않다. 또한 D2는 `C.UTF-8`과 `en_US.UTF-8`을 모두 호출하지만 33행은 `en_US.UTF-8`(`en_US.utf8`) 존재 여부만 `locale -a`로 확인한다.
- **영향**: `en_US.UTF-8`이 없는 머신에서 러너를 돌리면 AC1·AC2·AC5는 `ok ... — 건너뜀`으로, AC3·AC4·AC6은 POSIX `C` 폴백으로 모두 `failed: 0`·종료 코드 0이 나와 실제 검증 없이 통과로 오인할 수 있다. `C.UTF-8`이 없는 환경에서는 비교 기준 로케일 호출에서 stderr 경고나 의도치 않은 폴백이 생길 수 있다.

</details>

#### F-4: `설계 결정`이 참조한 `issue-audit`의 `assert_locale` 선례와 D2 비교 계약(종료 코드·stderr 처리)이 맞지 않는다

- **위험도**: 🟢 낮음(LOW)
- **영향 축**: 기능 저하
- **발생확률 축**: 특수 조건·엣지
- **카테고리**: 테스트
- **관점**: 모호성
- **계보**: 신규
- **권장 조치**: `설계 결정` 32행에서 `issue-audit/tests/run-tests.sh`의 `assert_locale`과의 차이(두 로케일 상호 비교, 종료 코드 대조, stdout·stderr 처리 방식)를 분명히 적는다.
- **완료 기준**:
  - `설계 결정` 32행에 두 로케일의 출력 비교 시 표준 오류를 포함(`2>&1`)할지 분리 비교할지와 종료 코드 비교 방식이 명시되어 `issue-audit` `assert_locale`(기대 출력 대조·`2>/dev/null`·종료 코드 미확인)과의 차이가 드러난다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- **설명**: plan `설계 결정` 32행은 "`issue-audit/tests/run-tests.sh`의 `assert_locale` 형식을 따른다. 같은 입력을 로케일마다 실행하고 출력과 종료 코드를 비교한다"고 적었다. 그러나 실제 `issue-audit/tests/run-tests.sh` 1299–1306행의 `assert_locale`은 (1) 두 로케일 출력을 서로 비교하지 않고 고정 기대 출력(`$5`)과 대조하며, (2) 종료 코드를 비교하지 않고, (3) `2>/dev/null`로 표준 오류를 버린다.
- **영향**: 구현자가 선례 함수를 그대로 본떠 작성하면 종료 코드 비교가 빠지거나 `2>/dev/null`로 표준 오류 차이를 놓칠 수 있다. 반대로 `2>&1`로 합칠지 stdout·stderr를 따로 비교할지도 정해져 있지 않아 헬퍼·러너마다 구현이 갈릴 수 있다.

</details>

### 검증 실행 기록

- **추적성 (`--trace`)**: `/Users/user/.gemini/config/skills/issue-audit/scripts/check-plan.sh --trace .ai/90_issues/archive/issue-0147/issue-0147-spec.md .ai/90_issues/archive/issue-0147/issue-0147-plan.md` → 무출력, 종료 코드 0 (위반 0건).
- **AC 대조 (`--ac`)**: `gh issue view 147 --repo scroogy-dev/scroogy-agent-skills --json body -q .body`로 본문을 임시 파일에 저장한 뒤 `check-plan.sh --ac` 실행 → 무출력, 종료 코드 0 (위반 0건). summary `이슈 본문 갱신` 줄은 비어 있으나 이슈 본문에 없는 AC는 0건이다.
- **발견 번호 계승**: `/Users/user/.gemini/config/skills/issue-audit/scripts/next-finding-number.sh` (보존된 이전 계획 감사 리포트 없음) → `1`.
- **위험도·상태·판정 산출**: `/Users/user/.gemini/config/skills/issue-audit/scripts/classify-risk.sh`로 F-1~F-4 위험도, 1단계 상태(`🟢 충족(PASS)`), 2단계 상태(`🔴 보완 필요(FAIL)`), 종합 판정(`🔴 부적합(FAIL)`)을 산출했다.
- **벤더 교차 확인**: summary `계획 모델`은 `Anthropic, Claude Opus 5.5 (claude-opus-5-5)`이고, 이번 감사 모델은 `Google, Gemini 4 Neon (gemini-4-neon-high)`으로 서로 다른 벤더다.

### 기등재 참조 항목

해당 없음

### 이전 발견 추적

해당 없음
