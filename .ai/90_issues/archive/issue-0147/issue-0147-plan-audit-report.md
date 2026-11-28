# Issue #147 계획 감사 리포트 git-review-quiz·ai-workspace·issue-work: en_US.UTF-8 로케일에서 헬퍼와 러너의 한글 문자열 비교가 틀리는 것을 고친다

> 감사 일시: 2026-11-28  
> 감사 모델: Google, Gemini 4 Neon (-)  
> 감사 effort: high  
> 감사 회차: 3차 (이전 리포트: `issue-0147-plan-audit-report-2.md`)  
> 감사 대상 브랜치: issue-0147  
> 감사 대상 커밋: e5d5b2d1b58d564ae17d2c0eab87e39faefb6f4f  
> 스펙 출처: [GitHub 이슈 #147](https://github.com/scroogy-dev/scroogy-agent-skills/issues/147) · [spec](./issue-0147-spec.md) · [plan](./issue-0147-plan.md) (작성 시점 경로는 `.ai/90_issues/active/issue-0147/`, --clear로 이관)

---

## 종합 의견

🟢 적합(PASS)

<details>
<summary>종합 의견 펼치기</summary>

2회차에서 보강한 `설계 결정`의 로케일 비교 기준, `테스트 계획`의 AC5 `[D]` 3줄과 `[QD]` 1줄, Task 5·Task 6은 이슈 본문과 R1~R5·AC1~AC6·D1~D4에 빠짐없이 맞는다. 2차 계획 감사의 F-9는 원장 `K-0047` 등재로 닫혔고, 새로 추가된 3개 러너의 회귀 케이스에 겹치는 기존 수용 항목(`K-0047`, `K-0048`)은 재검토 조건 미충족으로 참조 처리했다. 신규 발견 F-10은 정보(INFO)급 기록 사항뿐이므로 Task 5부터 구현을 진행해도 된다.

</details>

## 요약

- 1단계 적합성: 🟢 충족(PASS) · 충족(PASS) 13건 / 미충족(FAIL) 0건 / 부분 충족(PARTIAL) 0건 / 판정 불가(N/A) 2건
- 2단계 위험도: 🟢 통과(PASS) · 높음(HIGH) 0건 / 중간(MEDIUM) 0건 / 낮음(LOW) 0건 / 정보(INFO) 1건
- 기등재 참조: 2건 (원장 기등재와 일치, 위험도·카테고리 집계에 포함하지 않음)
- 이전 발견: 닫힘 1건 / 잔여 0건

| 카테고리 | 건수 |
|----------|------|
| 기능 | 0 |
| 아키텍처 | 0 |
| 버그 | 0 |
| 보안 | 0 |
| 코드품질 | 정보(INFO) 1 |
| 성능 | 0 |
| 테스트 | 0 |

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

- **스펙 요구사항의 제외 목록 침범 여부**: 없음. `issue-audit/scripts/check-plan.sh`와 `issue-audit/tests/run-tests.sh`는 변경 대상에서 제외되어 있고, Task N 전체 회귀도 `LC_ALL`을 비운 셸에서 실행해 보류 항목과의 충돌을 피한다.
- **스펙에 없는 추가 구현 여부**: 없음. 2회차에 추가된 Task 5(`R5`)는 AC5·D1·D2·D4에 따라 로케일 의존 비교가 확인된 세 헬퍼(`check-lobby.sh`, `verify-submit.sh`, `verify-push.sh`)와 그 회귀 케이스만 다루며 세 러너 머리는 고치지 않는다. Task 6(`R3`)은 1회차 Task 2의 주석과 summary 기록의 원인 표기 오류만 정정한다.

### 도메인/계약 정합성

- `.ai/30_contract/`(`ai-tool-skill-paths.md`, `github-integration.md`): 충돌 없음.
- `.ai/40_domain/`(`specs/issue-workflow.md`, `specs/issue-audit.md`, `specs/ai-workspace.md`, `specs/git-pr-submission.md`, `specs/git-pr-feedback.md`): 충돌 없음. `테스트 계획`에서 새로 추가한 AC5 `[D]` 3줄과 문구가 바뀐 AC5 `[QD]` 1줄의 `확인` 칸을 비우고 기존 통과 줄만 `최종 1차`로 유지한 구성이 `issue-workflow.md`의 `확인` 칸 규칙과 맞는다.
- `.ai/50_adr/`: ADR 0001(러너 배치·외부 의존성 없음), ADR 0003(검증 레벨·강등 사유), ADR 0031(진행 루프·`테스트 계획` 변경 시 계획 감사 재수행·발견 보정 Task 이어 붙이기·테스트 먼저 순서)과 정합한다.
- `.ai/10_rules/testing-principles.md`·`testing-principles-local.md`: `로케일 전제`가 새로 추가된 AC5 `[D]` 3줄에도 그대로 적용되어 전제 조건 미충족 시 `판정 불가(N/A)` 규칙과 맞는다. `testing-principles-local.md`는 `## 테스트 층` 표가 비어 있어 층·러너 표 대조 대상이 없다.

---

## 2단계: 비판적 검증 (Critical Review)

### 발견 사항

| # | 위험도 | 영향 | 발생확률 | 카테고리 | 계보 | 설명 | 관련 파일 |
|---|--------|------|----------|----------|------|------|-----------|
| F-10 | ⚪ 정보(INFO) | 기술 품질 의견 | 특수 조건·엣지 | 코드품질 | 신규 | `설계 결정` 35행의 awk 비교 기준이 문자열 `<`·`>`도 한쪽 값에 한글이 있을 때만 갈린다고 적어 ASCII 대소문자 `<`·`>` 비교 차이를 빠뜨렸다 | `.ai/90_issues/archive/issue-0147/issue-0147-plan.md` (34–35행) |

### 상세 분석

#### F-10: `설계 결정` 35행의 awk 비교 기준이 문자열 `<`·`>`도 한쪽 값에 한글이 있을 때만 갈린다고 적어 ASCII 대소문자 `<`·`>` 비교 차이를 빠뜨렸다

- **위험도**: ⚪ 정보(INFO)
- **영향 축**: 기술 품질 의견
- **발생확률 축**: 특수 조건·엣지
- **카테고리**: 코드품질
- **관점**: 모호성
- **계보**: 신규
- **권장 조치**: 등급별 기본 처리 기준에 따라 리포트에 기록만 남긴다. 추후 `설계 결정`이나 Task 5의 D4 확인 근거를 다듬을 기회가 있으면, awk 문자열 `==`·`!=`는 한쪽 값에 한글이 들 때 갈리고 문자열 `<`·`>`는 ASCII 대소문자를 포함한 정렬 순서 비교 전반이 로케일을 따른다고 구분해 적는다.
- **완료 기준**:
  - (선택) `설계 결정` 35행이 awk 문자열 `==`·`!=`(한쪽 값에 한글 포함)와 문자열 `<`·`>`(정렬 순서 비교 전반)의 로케일 의존 조건을 구분해 적는다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- **설명**: plan `설계 결정` 34–35행은 "로케일에 따라 결과가 갈리는 비교는 아래 둘이 전부다"라고 선언하면서 첫째 항목을 "awk의 문자열 `==`·`!=`·`<`·`>`에서 한쪽 값에 한글이 들어 있는 비교"로 적었다. 그러나 macOS awk 20200816 실측에서 `"a" < "B"`는 `LC_ALL=C.UTF-8`에서 `0`, `LC_ALL=en_US.UTF-8`에서 `1`을 반환한다. 문자열 `<`·`>`는 한글이 없는 순수 ASCII 대소문자 비교에서도 로케일에 따라 결과가 갈린다.
- **영향**: 이번 이슈의 나머지 헬퍼 5개(`check-lobby.sh`, `verify-submit.sh`, `verify-push.sh`, `summarize-metrics.sh`, `check-clear.sh`) 소스를 모두 확인한 결과 문자열 `<`·`>` 비교 자체가 없어(`NR > 1`, `i < NF`, `n <= 2`, `c > 1`, `n > 1` 등 숫자 비교만 존재), 수정 대상 선정과 AC5 충족에는 영향이 없다. 다만 Task 5가 이 문장을 D4 판단 기준으로 삼으므로 추후 다른 스크립트에 같은 기준을 재사용할 때 오해 여지가 남는다.

</details>

### 검증 실행 기록

- **추적성 (`--trace`)**: `/Users/user/.gemini/config/skills/issue-audit/scripts/check-plan.sh --trace .ai/90_issues/archive/issue-0147/issue-0147-spec.md .ai/90_issues/archive/issue-0147/issue-0147-plan.md` → 무출력, 종료 코드 0 (위반 0건).
- **AC 대조 (`--ac`)**: `gh issue view 147 --repo scroogy-dev/scroogy-agent-skills --json body -q .body`로 본문을 임시 파일에 저장한 뒤 `check-plan.sh --ac` 실행 → 무출력, 종료 코드 0 (위반 0건). summary `이슈 본문 갱신` 줄은 `대상 아님`이며 이슈 본문에 없는 AC는 0건이다.
- **발견 번호 계승**: `/Users/user/.gemini/config/skills/issue-audit/scripts/next-finding-number.sh ./issue-0147-plan-audit-report*.md` → `10` (작성 시점 경로는 `.ai/99_workspace/issue-0147-plan-audit-report*.md`, --clear로 이관) (2차 리포트의 F-9에서 연속 계승).
- **위험도·상태·판정 산출**: `/Users/user/.gemini/config/skills/issue-audit/scripts/classify-risk.sh`로 F-10 위험도(`⚪ 정보(INFO)`), 1단계 상태(`🟢 충족(PASS)`), 2단계 상태(`🟢 통과(PASS)`), 종합 판정(`🟢 적합(PASS)`)을 산출했다.
- **헬퍼 5개 소스·비교 실측 확인**: `check-lobby.sh`, `verify-submit.sh`, `verify-push.sh`, `summarize-metrics.sh`, `check-clear.sh`와 관련 러너 3개·`check-ide-tool-list.sh`를 직접 읽어 Task 5·Task 6의 대상 줄과 입력이 소스와 일치함을 확인했다. `summarize-metrics.sh`·`check-clear.sh`에는 로케일에 따라 갈리는 비교가 없고, macOS awk 20200816·bash 3.2·BSD grep에서 `"가" == ""`(0), `"active예정" == "active"`(0 vs 1), `"a" < "B"`(0 vs 1), `case` `[0-9a-fA-F]`의 `é` 일치, `grep -E` `[A-Za-z]`의 `é` 불일치를 확인했다.
- **벤더 교차 확인**: summary `계획 모델`은 `Anthropic, Claude Opus 5.5 (claude-opus-5-5)`이고, 이번 감사 모델은 `Google, Gemini 4 Neon (-)`으로 서로 다른 벤더다.

### 기등재 참조 항목

<details>
<summary>기등재 참조 표 펼치기</summary>

| 원장 항목 | 상태 | 대조한 발견 내용 | 재검토 조건 충족 | 처리 |
|-----------|------|------------------|------------------|------|
| K-0047 | 수용 | plan `설계 결정` 33행과 Task 5(200행)가 추가하는 3개 러너(`ai-workspace-directory`·`git-pr`·`git-pr-feedback`)의 `로케일:` 회귀 케이스도 `en_US.UTF-8`만 확인하고 `C.UTF-8` 존재 여부는 확인하지 않는다 (Task 5 구현 후 `K-0047` 본문의 영향 범위에 3개 러너 추가 반영 검토 가능) | 미충족 | 참조만 |
| K-0048 | 수용 | plan `설계 결정` 32행과 Task 5(200행)가 추가하는 3개 러너의 `로케일:` 회귀 케이스도 두 로케일의 출력(`2>&1`)·종료 코드 일치만 보고 기준 로케일 기대 판정은 단언하지 않는다 (Task 5 구현 후 `K-0048` 본문의 영향 범위에 3개 러너 추가 반영 검토 가능) | 미충족 | 참조만 |

</details>

### 이전 발견 추적

<details>
<summary>이전 발견 추적 표 펼치기</summary>

| 이전 발견 | 완료 기준 항목 | 판정 (닫힘/잔여) | 근거 |
|-----------|----------------|------------------|------|
| F-9 | 원장 이관 시 `C.UTF-8` 미설치·GNU bash 환경의 `setlocale` stderr 경고로 인한 거짓 실패 가능성과 재검토 조건이 원장 항목으로 기록됨 | 닫힘 | `.ai/70_ledger/active/K-0047-locale-regression-c-utf8-not-checked.md`가 등재되어 `setlocale` stderr 경고로 인한 거짓 실패 가능성과 재검토 조건이 기록됐다 |
| F-9 | 보정 승격 시 `설계 결정` 33행에 `C.UTF-8` 미설치 환경의 처리 기준이 명시됨 | 닫힘 | 1회차 `--response`에서 원장 이관(`K-0047`)을 선택해 위 원장 이관 완료 기준으로 종결됐다 |

</details>
