# Issue #147 실행요약 git-review-quiz·ai-workspace·issue-work: en_US.UTF-8 로케일에서 헬퍼와 러너의 한글 문자열 비교가 틀리는 것을 고친다

> 스펙: [issue-0147-spec.md](./issue-0147-spec.md) | 계획: [issue-0147-plan.md](./issue-0147-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task N(마무리). 전체 회귀 → 색인 → 충족 AC 체크 → repo 고유 마무리 → `--clear` → PR 순서로 진행한다

## 모델 기록

<!--
이슈 단위 요약(대표값)이다. 세부 SSoT는 아래 `Task별 수행 결과`의 `수행 모델`·`수행 effort`이며,
한 구분에 여러 모델이 관여했으면 대표 모델을 적고 세부는 Task별 기록을 본다.

형식: "벤더, 모델명 (모델 ID)". 계획·구현·audit 어느 칸이든 어느 벤더·모델이든 가능하다
(예: Anthropic, Claude Opus 4.8 (claude-opus-4-8) / OpenAI, GPT-6 (gpt-6-astra) / Google, Gemini 3.x (-)).
괄호 안은 모델 ID 전용이며 도구명·회차 같은 다른 정보를 넣지 않는다.
모델 ID를 확인할 수 없으면 괄호를 남겨 `(-)`로 적는다. 괄호가 없으면 ID를 적지 않은 것이고, `(-)`는 확인할 수 없었다는 기록이다.
모델 ID를 읽는 위치와 컨텍스트 접미어(`[1m]` 등) 제거는 issue-work SKILL.md `## 작업 진행 중`을 따른다.
effort 열에는 그 모델의 추론 강도 설정값을 도구가 기록한 표기(`high`, `xhigh` 등) 그대로 적고, 확인할 수 없으면 `-`를 적는다.
모델 열의 "벤더, 모델명 (모델 ID)" 형식은 바꾸지 않고 effort는 이 열에만 둔다.
벤더가 다르면 같은 이름의 단계라도 같은 수준이라는 보장이 없으므로 effort는 벤더끼리 비교하지 않는다.
effort와 모델 ID는 게이트 조건에 쓰지 않는다. 아래 벤더 교차 조건은 모델 열의 벤더로만 확인하며, effort가 `-`이거나 모델 ID가 `(-)`여도 조건 판정과 Task N 완료에 영향이 없다.
계획 모델(spec·plan을 쓴 모델)과 구현 모델은 다를 수 있어 칸을 나눈다 — 같으면 같은 값을 적는다.
"계획 audit 모델 ≠ 계획 모델"·"최종 audit 모델 ≠ 구현 모델" 조건을 나중에 명령으로 확인 가능하도록 기록한다. 모델 전환은 사람이 수행하므로 기계로 강제하기 어렵다.
구현에 여러 벤더가 관여했으면 최종 audit 모델의 벤더는 Task별 `수행 모델`의 모든 벤더와도 달라야 한다
— 대표 행 비교만으로는 audit 벤더가 구현 일부에 참여한 경우를 놓친다.
계획 감사를 건너뛴 이슈는 계획 audit 모델 행과 표 아래 계획 감사 줄에 `생략`을 적는다.
-->

| 구분 | 모델 | effort |
|------|------|--------|
| 계획 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | high |
| 계획 audit 모델 | Google, Gemini 4 Neon (gemini-4-neon-high) | high |
| 구현 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | high |
| 최종 audit 모델 | Google, Gemini 4 Neon (-) | high |

- **계획 감사**: 수행 · 발견 9건 · 보정 6건

<!--
5단계 결정 전에는 비워 둔다. 미리 `생략`을 적으면 결정 전에 중단·재개했을 때 명시적 생략으로 오인한다.
수행했으면 `수행 · 발견 N건 · 보정 N건`, 건너뛰었으면 `생략`을 적는다. 건수는 계획 감사 리포트를 `--response`로 검토한 결과다.
아래 Task 블록 지표 5종 중 `audit 발견`·`보정 반영`과 별개다. 그 지표는 구현 Task 축이라 `summarize-metrics.sh` 집계 대상이고, 이 줄은 집계하지 않는다.
이 줄은 `## 모델 기록` 섹션 안, 첫 `### Task ` 앞에 둔다. Task 블록 안이나 뒤로 옮기면 집계 헬퍼의 블록 판정 대상이 된다.
-->

- **이슈 본문 갱신**: 대상 아님

<!--
이 줄도 `계획 감사` 줄과 같은 자리(`## 모델 기록` 섹션 안, 첫 `### Task ` 앞)에 두며 집계하지 않는다.
6단계는 대상이 아니어도 `대상 아님`을 적으므로, 세션이 바뀐 뒤 이 줄이 비어 있으면 Task 0 전에 6단계를 수행한다.
AC 번호는 이슈 본문에 없어 spec이 직접 쓴 AC의 번호다. issue-audit `--plan`이 이 줄의 값으로 이슈 본문에 없는 AC를 판정한다.
-->

---

## 루프 기록

| 회차 | 바뀐 것 | 다시 시작한 단계 | 계획 검증 커밋 | 구현 검증 커밋 | 검증 결과 | 결정 |
|------|---------|------------------|----------------|----------------|-----------|------|
| 1 | spec·plan·summary 작성, 계획 감사 1차 F-1~F-4를 plan에 반영, 2차와 독립 비교 감사의 발견 가운데 2건을 Task 3·Task N 문구에 반영하고 2건을 원장 K-0047·K-0048로 이관 | - | dc1763a | 98f2a6b | 계획 감사 1차: 충족(PASS), 보완 필요(FAIL), 부적합(FAIL), 테스트 계획 0/7줄 · 계획 감사 2차: 충족(PASS), 통과(PASS), 적합(PASS) · 독립 비교 감사(OpenAI): 충족(PASS), 주의(WARN), 조건부 적합(CONDITIONAL) · 최종 1차: 미충족(FAIL), 보완 필요(FAIL), 부적합(FAIL), 테스트 계획 5/6줄 | 다음 회차 |
| 2 | plan `설계 결정`의 로케일 비교 기준 정정, `테스트 계획`에 AC5 `[D]` 줄 3개 추가, Task 5·6 추가 (최종 1차 F-1~F-3) | 계획 검증 | e5d5b2d | 3f5fc0a | 계획 감사 3차: 충족(PASS), 통과(PASS), 적합(PASS) · 최종 2차: 충족(PASS), 통과(PASS), 적합(PASS), 테스트 계획 9/9줄 | 마무리 |

---

## 종류별 발견

| 종류 | 발견 | 회차 | 고친 Task |
|------|------|------|-----------|
| 로케일 비교 판단 기준 누락 | F-1, F-2 | 1 | Task 5 |
| 실패 원인 표기 오류 | F-3 | 1 | Task 6 |

---

## Task별 수행 결과

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- **결과**: 완료
- **수행 모델**: claude-opus-5-5
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: 전제 누락 없음
- **특이 사항**: 착수 전에 plan의 전제를 실행으로 확인했다(2026-11-27, HEAD `0523642`). 이 머신에 `C.UTF-8`·`en_US.UTF-8`이 모두 있다. 세 러너의 `LC_ALL=en_US.UTF-8` 실패 수는 git-review-quiz 16건·ai-workspace 9건·issue-work 11건으로 이슈 본문과 같다. Task 1 fixture(`valid-interactive.md`, `invalid-r7-duplicate-target.md`)와 Task 2 경계 입력(`profile_state`, `dev_residue`)은 수정 전에 plan이 적은 대로 두 로케일의 출력·종료 코드가 갈린다. 다섯 파일 모두 `set -o pipefail`이 머리에 있어 고정 줄의 자리가 정해진다.

---

### Task 1: git-review-quiz 헬퍼와 러너의 로케일 고정

- **결과**: 완료
- **수행 모델**: claude-opus-5-5
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **테스트**: `e3c5097` · 실패 3건 (`bash git-review-quiz/tests/run-tests.sh`의 `로케일:` 케이스 3건). 같은 커밋에서 `LC_ALL=en_US.UTF-8 bash git-review-quiz/tests/run-tests.sh`는 실패 19건(기존 16건 + 회귀 케이스 3건)
- **대응 발견**: -
- **수행 내용 요약**: `git-review-quiz/tests/run-tests.sh`에 `assert_locale_same`과 `로케일:` 회귀 케이스 3건(`valid-interactive.md`, `--comment valid-comment.md`, `invalid-r7-duplicate-target.md`)을 더했다. `check-quiz.sh`와 러너의 `set -o pipefail` 다음에 이유 주석과 `export LC_ALL=C`를 두었다(구현 커밋 `3b08215`). 기본 로케일과 `LC_ALL=en_US.UTF-8` 모두 126건 통과, 실패 0건이다.
- **특이 사항**: 처음 쓴 로케일 판정 `locale -a | grep -qiE …`는 `set -o pipefail` 아래에서 `grep -q`가 첫 일치에서 끝나 `locale`이 SIGPIPE로 죽어 늘 건너뜀으로 빠졌다. `-q` 없이 끝까지 읽고 출력을 버리는 방식으로 고친 뒤 테스트 커밋을 만들었다. Task 2도 같은 방식을 쓴다. 러너 고정 없이 헬퍼만 고친 상태에서는 러너 자체의 조항 검사 3건(`h2_sec`·`h3_sec`의 awk `==`)이 `en_US.UTF-8`에서 실패해, 러너 고정이 따로 필요함을 확인했다.

---

### Task 2: ai-workspace 헬퍼와 러너의 로케일 고정

- **결과**: 완료
- **수행 모델**: claude-opus-5-5
- **수행 effort**: high
- **audit 발견**: 1건
- **보정 반영**: 1건
- **재시도**: 0회
- **테스트**: `e98114d` · 실패 2건 (`bash ai-workspace/tests/run-tests.sh`의 `로케일:` 경계 입력 케이스 `profile_state`·`dev_residue`). 같은 커밋에서 `LC_ALL=en_US.UTF-8 bash ai-workspace/tests/run-tests.sh`는 실패 11건(기존 9건 + 회귀 케이스 2건)
- **대응 발견**: -
- **수행 내용 요약**: `ai-workspace/tests/run-tests.sh`에 `assert_locale_same`과 `로케일:` 회귀 케이스 4건(정상 dev 사본, 정상 doc 사본, `--profile` `profile_state` 경계 입력, `dev_residue` 경계 입력)을 더했다. 경계 입력은 템플릿 사본에서 만들고, `PRIO_DEV`는 헬퍼 소스에서 읽으며, 입력이 실제로 바뀌었는지 먼저 확인한다. `check-context.sh`와 러너의 `set -o pipefail` 다음에 이유 주석과 `export LC_ALL=C`를 두었다(구현 커밋 `6f58cb2`). 327행의 `LC_ALL=C awk`는 그대로 두었다. 기본 로케일과 `LC_ALL=en_US.UTF-8` 모두 234건 통과, 실패 0건이다.
- **특이 사항**: 실패 확인에서 두 경계 입력의 출력은 plan에 적은 기대값과 같았다(`C.UTF-8`은 ``질의: 안내도에 `profile` 행이 없음``·종료 코드 1과 무출력·종료 코드 0, `en_US.UTF-8`은 `dev`·종료 코드 0과 충돌 우선순위 누락·종료 코드 1). 러너 고정 없이 헬퍼만 고친 상태에서는 `en_US.UTF-8`에서 9건이 실패했다(러너 안 `ide_decision_violations`의 결정 목록 대조 5건, 소유 구간 검사 4건). 러너 고정이 따로 필요하다. `check-ide-tool-list.sh`에는 로케일에 따라 갈리는 비교가 없어 고치지 않았다(`설계 결정`, Task 6에서 정정).

---

### Task 3: issue-work 러너의 로케일 고정

- **결과**: 완료
- **수행 모델**: claude-opus-5-5
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **테스트**: `5b8113f` · 실패 11건 (`LC_ALL=en_US.UTF-8 bash issue-work/tests/run-tests.sh`, 861건 통과). 새 테스트 없이 실패하는 기존 검사가 이미 커밋된 HEAD를 테스트 커밋으로 적는다(plan Task 3 `실패 확인`)
- **대응 발견**: -
- **수행 내용 요약**: `issue-work/tests/run-tests.sh`의 `set -o pipefail` 다음에 이유 주석과 `export LC_ALL=C`를 두었다(구현 커밋 `9426505`). 기본 로케일과 `LC_ALL=en_US.UTF-8` 모두 872건 통과, 실패 0건이다.
- **특이 사항**: 실패 11건은 모두 템플릿·SKILL.md 구조 검사였다(본문 묶음 대응, 변경 이력 섹션 2건, 설계 결정 섹션, 루프 기록 표, 발견 기록, 한 회차 산출물 3건, 구현 검증 단계, 같은 종류 발견). 러너가 부르는 `summarize-metrics.sh`·`check-clear.sh`는 실패에 없었고, 두 헬퍼의 비교 확인은 Task 4가 맡는다.

---

### Task 4: 나머지 배포 헬퍼 5개의 비교 확인과 수정

- **결과**: 완료
- **수행 모델**: claude-opus-5-5
- **수행 effort**: high
- **audit 발견**: 2건
- **보정 반영**: 2건
- **재시도**: 0회
- **테스트**: -
- **대응 발견**: -
- **수행 내용 요약**: 다섯 헬퍼 모두 로케일에 따라 결과가 달라지는 비교가 없어 고치지 않았다. 테스트 커밋과 구현도 건너뛰었다. 헬퍼마다 확인 결과는 아래와 같다(줄 번호는 HEAD `dfd86cf` 기준).
  - `git-pr/scripts/verify-submit.sh`: 비교 없음. awk는 138행의 필드 추출(`{print $1}`)뿐이고, 42행 `[ "$host" != "$rest" ]`는 셸의 바이트 비교다. `sort`·`[[ … < … ]]`는 없다. (Task 5에서 정정)
  - `git-pr-feedback/scripts/verify-push.sh`: 비교 없음. awk는 165행의 필드 추출뿐이고, 39·129·147행의 `[ … != … ]`는 셸의 바이트 비교다. `sort`·`[[ … < … ]]`는 없다. (Task 5에서 정정)
  - `ai-workspace-directory/scripts/check-lobby.sh`: 비교 없음. awk 비교는 149행 `out == ""`(빈 문자열)과 167행 `v != "active"` 등(ASCII 값)뿐이다. 한글 헤더는 135·184행 awk 정규식과 `grep -qE`·`grep -xF`로 찾고, 128행 H2 순서와 Repos 표 열은 셸 `[ … = … ]`로 견준다. 모두 바이트로 정확히 일치하는 것만 찾는다. `sort`·`[[ … < … ]]`는 없다. (Task 5에서 정정)
  - `issue-work/scripts/summarize-metrics.sh`: 비교 없음. awk 비교는 65·73행 `title == ""`(빈 문자열)과 66행 `c == 0`(숫자)뿐이다. 한글 필드 이름은 70행 `index()`, `### Task N`은 69행 정규식으로 찾는다. `sort`·`[[ … < … ]]`는 없다.
  - `issue-work/scripts/check-clear.sh`: 비교 없음. awk 비교는 63행 `title == ""`(빈 문자열)과 64행 `n == 0`(숫자)뿐이다. `완료`·`(고정)`은 68·69·71행 awk 정규식으로 찾고, `작성 시점 경로는`은 106행 `grep -v`로 거른다. `sort`·`[[ … < … ]]`는 없다.
- **특이 사항**: 판단 근거를 실험으로 확인했다(macOS awk 20200816, 2026-11-27). 같은 길이의 다른 한글 문자열(`## 에이전트 운영 지칩`과 `지침`)을 `en_US.UTF-8`에서 견주면, awk `==`만 같다고 보았다. awk 정규식, `index()`, 셸 `[ = ]`, `grep -xF`는 두 로케일 모두 다르다고 보았다. 그래서 결과가 갈리는 비교는 awk의 문자열 `==`·`!=`·`<`·`>` 가운데 양쪽이 한글인 것으로 좁혔다. 위 다섯 헬퍼에는 그런 비교가 없다. 비교를 새로 찾지 않았으므로 AC5 `[D]` 줄과 계획 감사 재수행은 해당하지 않는다(`설계 결정`).

---

### Task 5: 로케일 비교 판단 기준 정정과 세 헬퍼의 로케일 고정

- **결과**: 완료
- **수행 모델**: claude-opus-5-5
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **테스트**: `47434bd` · 실패 3건 (러너마다 1건: `bash ai-workspace-directory/tests/run-tests.sh`의 `로케일: status 칸을 active예정으로 바꾼 사본`, `bash git-pr/tests/run-tests.sh`의 `로케일: --expect 가 ébcdef0`, `bash git-pr-feedback/tests/run-tests.sh`의 `로케일: --head-oid 가 ébcdef0`)
- **대응 발견**: F-1, F-2 (최종 1차)
- **수행 내용 요약**: 세 러너 끝에 `assert_locale_same`과 `로케일:` 회귀 케이스를 2건씩 더했다(바뀐 입력 1건과 기존 입력 1건). 세 헬퍼의 `set -o pipefail` 다음에 갈리는 비교를 적은 주석과 `export LC_ALL=C`를 두었다. 세 러너 머리는 고치지 않았다. 세 러너 모두 기본 로케일과 `LC_ALL=en_US.UTF-8`에서 실패 0건이고 `로케일:` 케이스는 건너뛰지 않았다(ai-workspace-directory 32건, git-pr 182건, git-pr-feedback 48건 통과). 다섯 헬퍼의 확인 결과를 `설계 결정`의 기준으로 다시 적으면 아래와 같다(줄 번호는 구현 커밋 기준).
  - `ai-workspace-directory/scripts/check-lobby.sh`: 비교 있음, 고쳤다. 170행 awk `v != "active"` 등은 status 값에 한글이 붙으면(`active예정`) `en_US.UTF-8`에서 같다고 보아 위반을 놓친다. 152행 `out == ""`는 빈 문자열 비교라 갈리지 않는다. 대괄호 범위는 awk 정규식과 `grep -E`에만 있다.
  - `git-pr/scripts/verify-submit.sh`: 비교 있음, 고쳤다. 111행 `case`의 `*[!0-9a-fA-F]*`가 `en_US.UTF-8`에서 `é`를 범위에 넣어 SHA 형식이 아닌 `--expect`를 통과시킨다. awk 문자열 비교는 없고, 45행 `[ != ]`는 셸 비교라 갈리지 않는다.
  - `git-pr-feedback/scripts/verify-push.sh`: 비교 있음, 고쳤다. 108행 `case`의 `*[!0-9a-fA-F]*`가 같은 이유로 SHA 형식이 아닌 `--head-oid`·`--approved-sha`를 통과시킨다. awk 문자열 비교는 없고, 42·132·150행 `[ != ]`는 셸 비교라 갈리지 않는다.
  - `issue-work/scripts/summarize-metrics.sh`: 비교 없음. awk 문자열 비교는 65·73행 `title == ""`(빈 문자열)뿐이다. `case`는 31·94행의 옵션·종류 값 분기로 대괄호 범위가 없고, 범위는 72·76행 awk 정규식에만 있다.
  - `issue-work/scripts/check-clear.sh`: 비교 없음. awk 문자열 비교는 63·69행 `title == ""`·`title != ""`(빈 문자열)뿐이다. `case`는 25행 옵션 분기로 대괄호 범위가 없고, 범위는 45·52행 `grep -E`와 104행 `grep -rnE`에만 있다.
- **특이 사항**: 수정 전 실패 출력은 plan의 예상과 같았다. `check-lobby.sh`는 `C.UTF-8`에서 status 위반 2행·종료 코드 1, `en_US.UTF-8`에서 무출력·종료 코드 0이었다. `verify-submit.sh`는 `C.UTF-8`에서 SHA 형식 오류·종료 코드 2, `en_US.UTF-8`에서 head 불일치 위반·종료 코드 1이었다. `verify-push.sh`는 `C.UTF-8`에서 SHA 형식 오류·종료 코드 2, `en_US.UTF-8`에서 원격 URL 정규화·원격 ref·headRefOid 위반 4행·종료 코드 1이었다. `LC_ALL=C`에서 `${#s}`는 바이트 수가 되지만, 길이 검사는 형식 검사 뒤라 ASCII 16진수에만 쓰여 결과가 같다. 계획 감사 3차 F-10(awk 문자열 `<`·`>`는 한글 없는 값도 갈림)은 보류로 정했고, 다섯 헬퍼에 awk 문자열 `<`·`>` 비교는 없다.

---

### Task 6: ai-workspace 러너 주석과 Task 2 기록의 실패 원인 정정

- **결과**: 완료
- **수행 모델**: claude-opus-5-5
- **수행 effort**: high
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **테스트**: - (먼저 쓰지 않음. 러너 주석과 이슈 기록만 고치는 Task)
- **대응 발견**: F-3 (최종 1차)
- **수행 내용 요약**: `ai-workspace/tests/run-tests.sh` 20행 주석에서 `check-ide-tool-list.sh`를 빼고, 원인을 러너 안의 결정 목록 대조(`ide_decision_violations`)와 소유 구간 검사로 적었다. summary Task 2 `특이 사항`에서 `check-ide-tool-list.sh`를 원인으로 적은 두 곳을 고쳤다. `bash ai-workspace/tests/run-tests.sh`와 `LC_ALL=en_US.UTF-8 bash ai-workspace/tests/run-tests.sh` 모두 234건 통과, 실패 0건이다.
- **특이 사항**: 고치기 전에 원인을 실행으로 확인했다(2026-11-28). 러너의 `export LC_ALL=C` 줄만 뺀 임시 사본을 `LC_ALL=en_US.UTF-8`로 돌리면 9건이 실패했다. 그 가운데 결정 목록 대조 5건은 모두 `ide-tools 결정 목록 일치` 케이스였고, 출력은 `ide_decision_violations`의 `dec[k] == "표에 둠"` 비교가 내는 `표에 둠인데 절 밖에 이름 없음` 위반이었다. 임시 사본은 실행 뒤 지웠다.

---

### Task N (고정): 마무리

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:
