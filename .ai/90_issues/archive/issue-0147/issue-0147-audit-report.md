# Issue #147 감사 리포트 git-review-quiz·ai-workspace·issue-work: en_US.UTF-8 로케일에서 헬퍼와 러너의 한글 문자열 비교가 틀리는 것을 고친다

> 감사 일시: 2026-11-28  
> 감사 모델: Google, Gemini 4 Neon (-)  
> 감사 effort: high  
> 감사 회차: 2차 (이전 리포트: `issue-0147-audit-report-1.md`)  
> 감사 대상 브랜치: issue-0147  
> 감사 대상 커밋: 3f5fc0af985380b6beed4742c267450c1e175cfd  
> 스펙 출처: [스펙](./issue-0147-spec.md) · [계획](./issue-0147-plan.md) · [수행 요약](./issue-0147-summary.md) (작성 시점 경로는 `.ai/90_issues/active/issue-0147/`, --clear로 이관)

---

## 종합 의견

🟢 적합(PASS)

<details>
<summary>종합 의견 펼치기</summary>

1차 감사의 발견 3건(F-1·F-2·F-3)이 Task 5·Task 6에서 모두 해소되었고, AC1~AC6과 D1~D4가 전부 충족으로 확인되었다. `check-lobby.sh`, `verify-submit.sh`, `verify-push.sh`의 `export LC_ALL=C` 고정과 세 러너의 `로케일:` 회귀 케이스가 실제 결함을 재현·차단하며, 변경 파일 19개의 변경 줄을 전수 검토한 결과 신규 발견은 없다. `issue-work` 완료 확인 단계로 넘어가 마무리(Task N) 여부를 결정하면 된다.

</details>

## 요약

- 1단계 적합성: 🟢 충족(PASS) · 충족(PASS) 10건 / 미충족(FAIL) 0건 / 부분 충족(PARTIAL) 0건 / 판정 불가(N/A) 0건
- 2단계 위험도: 🟢 통과(PASS) · 높음(HIGH) 0건 / 중간(MEDIUM) 0건 / 낮음(LOW) 0건 / 정보(INFO) 0건
- 코드 레벨 검증: 읽은 파일 19개 / 읽지 않은 파일 0개
- 기등재 참조: 2건 (원장 기등재와 일치, 위험도·카테고리 집계에 포함하지 않음)
- 이전 발견: 닫힘 3건 / 잔여 0건

| 카테고리 | 건수 |
|----------|------|
| 기능 | 0 |
| 아키텍처 | 0 |
| 버그 | 0 |
| 보안 | 0 |
| 코드품질 | 0 |
| 성능 | 0 |
| 테스트 | 0 |

---

## 1단계: 적합성 검증 (Compliance Check)

### 완료의 정의(DoD) 대조

| AC | 완료의 정의 항목 | 판정 | 근거 |
|----|------------------|------|------|
| AC1 | `check-quiz.sh`가 같은 입력에 대해 `C.UTF-8`과 `en_US.UTF-8`에서 같은 출력과 종료 코드를 낸다. | 🟢 충족(PASS) | `locale -a`에 `en_US.UTF-8`·`C.UTF-8` 존재 확인. `bash git-review-quiz/tests/run-tests.sh` 실행에서 `로케일:` 케이스 3건(`valid-interactive.md`, `valid-comment.md`, `invalid-r7-duplicate-target.md`) 모두 건너뜀 없이 `ok` 통과(`passed: 126, failed: 0`, 종료 코드 0) |
| AC2 | `check-context.sh`가 같은 입력에 대해 `C.UTF-8`과 `en_US.UTF-8`에서 같은 출력과 종료 코드를 낸다. | 🟢 충족(PASS) | `bash ai-workspace/tests/run-tests.sh` 실행에서 `로케일:` 케이스 4건(정상 dev·doc 사본, `profile_state` 경로, `dev_residue` 경로) 모두 건너뜀 없이 `ok` 통과(`passed: 234, failed: 0`, 종료 코드 0) |
| AC3 | git-review-quiz 러너가 `LC_ALL=en_US.UTF-8`에서 실패 0건으로 끝난다. | 🟢 충족(PASS) | `LC_ALL=en_US.UTF-8 bash git-review-quiz/tests/run-tests.sh` 실행 결과 `passed: 126, failed: 0`, 종료 코드 0 |
| AC4 | ai-workspace 러너가 `LC_ALL=en_US.UTF-8`에서 실패 0건으로 끝난다. | 🟢 충족(PASS) | `LC_ALL=en_US.UTF-8 bash ai-workspace/tests/run-tests.sh` 실행 결과 `passed: 234, failed: 0`, 종료 코드 0 |
| AC5 | `verify-submit.sh`, `verify-push.sh`, `check-lobby.sh`, `summarize-metrics.sh`, `check-clear.sh`마다 로케일에 따라 결과가 달라지는 비교가 있는지 확인한 결과가 남고, 있는 헬퍼는 두 로케일에서 같은 결과를 낸다. | 🟢 충족(PASS) | `[D]` 세 러너(`ai-workspace-directory` 32건, `git-pr` 182건, `git-pr-feedback` 48건)가 기본 로케일과 `LC_ALL=en_US.UTF-8` 모두에서 `로케일:` 케이스 건너뜀 없이 실패 0건·종료 코드 0으로 통과. `check-lobby.sh`(`active예정` 입력 시 두 로케일 모두 위반 2행·종료 코드 1), `verify-submit.sh`·`verify-push.sh`(`ébcdef0` 입력 시 두 로케일 모두 SHA 형식 오류·종료 코드 2) 직접 실행과 수정 되돌림 실패 재현도 확인. `[QD]` summary Task 4·Task 5에 5개 헬퍼 각각의 확인 결과와 줄 번호 근거가 빠짐없이 남았고, `summarize-metrics.sh`·`check-clear.sh` 소스 전수 확인 및 경계 입력(`²`, `２`, `٢`, `é`, `É`, `ü`, `ß`, `가`, NBSP, 전각 공백) 두 로케일 실행에서 차이가 없음을 확인 |
| AC6 | issue-work 러너가 `LC_ALL=en_US.UTF-8`에서 실패 0건으로 끝난다. | 🟢 충족(PASS) | `LC_ALL=en_US.UTF-8 bash issue-work/tests/run-tests.sh` 실행 결과 `passed: 872, failed: 0`, 종료 코드 0 |

### 결정 사항 대조

| D | 결정 | 판정 | 근거 |
|---|------|------|------|
| D1 | 로케일에 따라 결과가 달라지는 비교가 있는 배포 헬퍼와 git-review-quiz·ai-workspace·issue-work 러너는 스크립트 머리에 `export LC_ALL=C`를 둔다. | 🟢 충족(PASS) | `check-quiz.sh`, `check-context.sh`, `check-lobby.sh`, `verify-submit.sh`, `verify-push.sh`와 세 러너(`git-review-quiz`, `ai-workspace`, `issue-work`) 모두 `set -o pipefail` 바로 뒤에 이유 주석과 `export LC_ALL=C`를 두었다. 비교가 없는 `summarize-metrics.sh`·`check-clear.sh`와 두 로케일 모두 실패 0건인 세 러너(`ai-workspace-directory`, `git-pr`, `git-pr-feedback`)는 머리를 고치지 않았다 |
| D2 | 로케일 회귀 케이스를 러너에 두고, 고친 헬퍼마다 같은 입력을 `C.UTF-8`과 `en_US.UTF-8`로 실행해 출력과 종료 코드가 같은지 본다. | 🟢 충족(PASS) | 고친 5개 헬퍼의 러너(`git-review-quiz`, `ai-workspace`, `ai-workspace-directory`, `git-pr`, `git-pr-feedback`) 모두 `assert_locale_same`과 `로케일:` 회귀 케이스를 두고, 헬퍼 호출 시 두 로케일을 명시해 합친 출력(`2>&1`)과 종료 코드 일치를 검사한다 |
| D3 | 실행하는 머신에 `en_US.UTF-8`이 없으면 D2 케이스는 실행하지 않고 건너뛴 사실을 한 줄 출력하며 실패로 세지 않는다. | 🟢 충족(PASS) | 5개 러너 모두 `locale -a 2>/dev/null \| grep -iE '^en_US\.utf-?8$' > /dev/null`로 판정하고, 없으면 `ok "$desc — 건너뜀 (en_US.UTF-8 없음)"`을 출력해 실패로 세지 않는다 |
| D4 | 헬퍼 5개마다 로케일에 따라 결과가 달라지는 비교가 있는지와 그 근거를 summary의 해당 Task 블록에 적고, 비교가 있는 헬퍼만 D1 방식으로 고치고 D2 케이스를 더한다. | 🟢 충족(PASS) | summary Task 5(및 `(Task 5에서 정정)`이 붙은 Task 4)에 5개 헬퍼 각각의 비교 유무와 줄 번호 근거가 실제 소스와 일치하게 남았고, 비교가 있는 3개 헬퍼(`check-lobby.sh`, `verify-submit.sh`, `verify-push.sh`)에만 D1 수정과 D2 회귀 케이스를 적용했다 |

### 경계 검증

- **스펙 요구사항의 제외 목록 침범 여부**: 없음. `issue-audit/scripts/check-plan.sh`와 `issue-audit/tests/run-tests.sh`는 변경하지 않았다.
- **스펙에 없는 추가 구현 여부**: 없음. 변경 파일 19개는 이슈 문서(4개), 계획 감사 `--response` 승인 원장 등재·영향 범위 갱신(4개), Task 1~3·5~6 대상 헬퍼 5개와 러너 6개(11개)로 한정된다.

### 도메인/계약 정합성

- `.ai/30_contract/`(`ai-tool-skill-paths.md`, `github-integration.md`): `verify-submit.sh`·`verify-push.sh`의 `export LC_ALL=C` 고정은 git 호출 결과와 URL 정규화 동작을 바꾸지 않고 SHA 형식 검사의 로케일 편차만 없애 계약과 충돌하지 않는다.
- `.ai/40_domain/`(`specs/ai-workspace.md`, `specs/git-pr-submission.md`, `specs/git-pr-feedback.md`, `specs/git-review-quiz.md`, `specs/issue-workflow.md`): `check-lobby.sh`의 `status` 열거값 검사가 `en_US.UTF-8`에서도 한글 혼용 값을 위반으로 잡아 `specs/ai-workspace.md`와 정합한다. 나머지 변경도 도메인 문서와 충돌하지 않는다.
- `.ai/50_adr/`: ADR 0001(러너 배치·외부 의존성 없음), ADR 0003(검증 레벨), ADR 0019·0031(테스트 먼저 커밋 순서 `e3c5097`→`3b08215`, `e98114d`→`6f58cb2`, `5b8113f`→`9426505`, `47434bd`→`1d9e5d4`와 summary `테스트` 기록, Task 6의 비동작 변경 예외 사유)과 정합한다.
- `.ai/60_codebase/`: 변경된 헬퍼 5개(`check-quiz.sh`, `check-context.sh`, `check-lobby.sh`, `verify-submit.sh`, `verify-push.sh`)의 호출 순서·인자·종료 코드 규약은 그대로라 색인과 실제 코드의 불일치가 없다.

---

## 2단계: 비판적 검증 (Critical Review)

### 발견 사항

신규 발견 없음 (0건).

### 상세 분석

해당 없음.

### 기등재 참조 항목

<details>
<summary>기등재 참조 표 펼치기</summary>

| 원장 항목 | 상태 | 대조한 발견 내용 | 재검토 조건 충족 | 처리 |
|-----------|------|------------------|------------------|------|
| K-0047 | 수용 | 5개 러너(`git-review-quiz`, `ai-workspace`, `ai-workspace-directory`, `git-pr`, `git-pr-feedback`)의 로케일 회귀 케이스가 `locale -a`에서 `en_US.UTF-8`만 확인하고 `C.UTF-8` 존재 여부는 확인하지 않는다 (커밋 `3f5fc0a`에서 세 러너 영향 범위 반영 확인) | 미충족 | 참조만 |
| K-0048 | 수용 | 5개 러너의 `assert_locale_same`이 두 로케일의 출력·종료 코드 동일성만 비교하고 기준 로케일 기대 판정은 단언하지 않는다 (커밋 `3f5fc0a`에서 세 러너 영향 범위 반영 확인) | 미충족 | 참조만 |

</details>

### 이전 발견 추적

<details>
<summary>이전 발견 추적 표 펼치기</summary>

| 이전 발견 | 완료 기준 항목 | 판정 (닫힘/잔여) | 근거 |
|-----------|----------------|------------------|------|
| F-1 | `ai-workspace-directory/scripts/check-lobby.sh`의 `set -o pipefail` 다음에 이유 주석과 `export LC_ALL=C`가 있다 | 닫힘 | `check-lobby.sh` 21~24행에 `set -o pipefail` 바로 뒤 주석과 `export LC_ALL=C` 확인(커밋 `1d9e5d4`) |
| F-1 | `ai-workspace-directory/tests/run-tests.sh`에 `로케일:` 회귀 케이스가 있고, `active예정` 같은 한글 혼용 `status` 입력에서 수정 전 실패·수정 후 통과(`C.UTF-8`·`en_US.UTF-8` 모두 위반 출력·종료 코드 1)를 검증한다 | 닫힘 | `ai-workspace-directory/tests/run-tests.sh` 249~255행에 `로케일:` 케이스 2건 추가(커밋 `47434bd`). `main` 헬퍼로 되돌려 실행 시 `active예정` 케이스 1건 실패, 현재 헬퍼에서 두 로케일 모두 위반 2행·종료 코드 1과 `ok` 통과 확인 |
| F-1 | `LC_ALL=en_US.UTF-8 bash ai-workspace-directory/tests/run-tests.sh`가 건너뜀 없이 실패 0건으로 끝난다 | 닫힘 | 직접 실행 결과 `로케일:` 2건 건너뜀 없이 `ok`, `passed: 32, failed: 0`, 종료 코드 0 |
| F-1 | plan `설계 결정`·`테스트 계획`과 summary Task 4의 `check-lobby.sh` 확인 근거가 실제 동작과 일치하게 갱신된다 | 닫힘 | `issue-0147-plan.md` 29·34~39·67·78행 갱신, `issue-0147-summary.md` Task 4 148행에 `(Task 5에서 정정)` 병기 및 Task 5 166행에 실제 근거 기재 확인 |
| F-2 | 원장 이관 시 `verify-submit.sh:108`·`verify-push.sh:105`의 `case` 문자 범위 로케일 의존성과 재검토 조건이 원장 항목으로 기록된다 | 닫힘 | 2회차에서 원장 이관 대신 수정(Task 5)을 선택해 아래 수정 완료 기준으로 종결 |
| F-2 | 수정 선택 시 `ébcdef0` 입력에 대해 두 헬퍼가 `C.UTF-8`과 `en_US.UTF-8` 모두에서 종료 코드 2(SHA 형식 오류)를 낸다 | 닫힘 | 두 헬퍼에 `export LC_ALL=C`와 세 러너 회귀 케이스 추가(커밋 `47434bd`·`1d9e5d4`). 직접 실행에서 `verify-submit.sh --expect ébcdef0`과 `verify-push.sh`의 `--head-oid`/`--approved-sha` `ébcdef0` 모두 `C.UTF-8`·`en_US.UTF-8`에서 SHA 형식 오류·종료 코드 2 확인, 수정 되돌림 시 각 러너 1건 실패 확인 |
| F-3 | `ai-workspace/tests/run-tests.sh` 20행 주석이 `check-ide-tool-list.sh`를 오동작 원인으로 지목하지 않는다 | 닫힘 | `ai-workspace/tests/run-tests.sh` 20행 주석이 `ide_decision_violations`와 소유 구간 검사를 원인으로 가리키도록 정정되었고(커밋 `0878ccd`), summary Task 2 116행 기록도 함께 정정 확인(커밋 `1da4beb`) |

</details>
