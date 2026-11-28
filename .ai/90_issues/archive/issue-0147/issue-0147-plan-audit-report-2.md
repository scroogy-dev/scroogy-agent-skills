# Issue #147 계획 감사 리포트 git-review-quiz·ai-workspace·issue-work: en_US.UTF-8 로케일에서 헬퍼와 러너의 한글 문자열 비교가 틀리는 것을 고친다

> 감사 일시: 2026-11-27  
> 감사 모델: Google, Gemini 4 Neon (gemini-4-neon-high)  
> 감사 effort: high  
> 감사 회차: 2차 (이전 리포트: `issue-0147-plan-audit-report-1.md`)  
> 번호 기준선: F-8 (`next-finding-number.sh`가 1차 리포트 본문의 `UTF-8` 문자열을 `F-8`로 읽어 다음 번호 9를 반환했다. 실제 1차 발견은 F-1~F-4이며, 헬퍼 출력에 맞춰 이번 신규 발견을 F-9로 적는다)  
> 감사 대상 브랜치: issue-0147  
> 감사 대상 커밋: dc1763acad803b27c9bf0b1754929e3d78fdd032  
> 스펙 출처: [GitHub 이슈 #147](https://github.com/scroogy-dev/scroogy-agent-skills/issues/147) · [spec](./issue-0147-spec.md) · [plan](./issue-0147-plan.md) (작성 시점 경로는 `.ai/90_issues/active/issue-0147/`, --clear로 이관)

---

## 종합 의견

🟢 적합(PASS)

<details>
<summary>종합 의견 펼치기</summary>

1차 계획 감사의 F-1~F-4 완료 기준 8개 항목이 모두 plan에 반영되어 닫혔다. Task 2의 `profile_state`·`dev_residue` 회귀 입력은 수정 전 `check-context.sh`에서 실제로 두 로케일 결과가 갈리는 것을 확인했고, AC5의 `[QD]` 검증 구성과 `en_US.UTF-8` 미설치 판정 불가 기준도 정리됐다. 신규 발견 1건(F-9)은 낮음(LOW)급이므로 원장 이관 대상이며, 구현 단계(Task 0)로 넘어가도 된다.

</details>

## 요약

- 1단계 적합성: 🟢 충족(PASS) · 충족(PASS) 13건 / 미충족(FAIL) 0건 / 부분 충족(PARTIAL) 0건 / 판정 불가(N/A) 2건
- 2단계 위험도: 🟢 통과(PASS) · 높음(HIGH) 0건 / 중간(MEDIUM) 0건 / 낮음(LOW) 1건 / 정보(INFO) 0건
- 기등재 참조: 0건 (원장 기등재와 일치, 위험도·카테고리 집계에 포함하지 않음)
- 이전 발견: 닫힘 4건 / 잔여 0건

| 카테고리 | 건수 |
|----------|------|
| 기능 | 0 |
| 아키텍처 | 0 |
| 버그 | 0 |
| 보안 | 0 |
| 코드품질 | 0 |
| 성능 | 0 |
| 테스트 | 낮음(LOW) 1 |

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
- **스펙에 없는 추가 구현 여부**: 없음. 일반 Task 1~4 모두 `R1`~`R5`에 대응하며, `ai-workspace/tests/check-ide-tool-list.sh`도 러너 상속으로 범위를 한정했다.

### 도메인/계약 정합성

- `.ai/30_contract/`(`ai-tool-skill-paths.md`, `github-integration.md`): 충돌 없음.
- `.ai/40_domain/`(`specs/issue-workflow.md`, `specs/issue-audit.md`, `specs/git-review-quiz.md`, `specs/ai-workspace.md`): 충돌 없음.
- `.ai/50_adr/`: ADR 0001(러너 배치·외부 의존성 없음), ADR 0003(검증 레벨·강등 사유), ADR 0016·0019·0023·0026·0031(요구사항·테스트 계획·테스트 먼저 구조)과 정합한다.
- `.ai/10_rules/testing-principles.md`: 1차 F-3에서 지적한 전제 조건 미충족 시 `판정 불가(N/A)` 규칙이 plan `테스트 계획` 63행(`로케일 전제`)에 반영되어 정합한다. `.ai/10_rules/testing-principles-local.md`는 테스트 층 표가 비어 있어 층·러너 표 대조 대상이 없다.

---

## 2단계: 비판적 검증 (Critical Review)

### 발견 사항

| # | 위험도 | 영향 | 발생확률 | 카테고리 | 계보 | 설명 | 관련 파일 |
|---|--------|------|----------|----------|------|------|-----------|
| F-9 | 🟢 낮음(LOW) | 기능 저하 | 특수 조건·엣지 | 테스트 | 신규 | `2>&1` 출력 비교(32행)와 `C.UTF-8` 미확인 폴백(33행)이 결합되어 GNU bash에서 `C.UTF-8`이 없는 환경은 setlocale 경고로 거짓 실패한다 | `.ai/90_issues/archive/issue-0147/issue-0147-plan.md` (32–33행) |

### 상세 분석

#### F-9: `2>&1` 출력 비교(32행)와 `C.UTF-8` 미확인 폴백(33행)이 결합되어 GNU bash에서 `C.UTF-8`이 없는 환경은 setlocale 경고로 거짓 실패한다

- **위험도**: 🟢 낮음(LOW)
- **영향 축**: 기능 저하
- **발생확률 축**: 특수 조건·엣지
- **카테고리**: 테스트
- **관점**: 테스트 계획
- **계보**: 신규
- **권장 조치**: 등급별 기본 처리 기준에 따라 원장(`.ai/70_ledger/`)에 이관하거나, 구현 시 `locale -a`에서 `C.UTF-8`(`C.utf8`)이 없을 때만 기준 로케일을 `C`로 내려 호출하도록 보완한다.
- **완료 기준**:
  - 원장 이관 시 `C.UTF-8` 미설치·GNU bash 환경의 `setlocale` stderr 경고로 인한 거짓 실패 가능성과 재검토 조건이 원장 항목으로 기록된다.
  - 보정 승격 시 `설계 결정` 33행에 `C.UTF-8` 미설치 환경에서 `C`로 대체 호출하거나 `C.UTF-8`을 함께 검사하는 기준이 명시된다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- **설명**: plan `설계 결정` 32행은 두 로케일(`C.UTF-8`, `en_US.UTF-8`) 실행의 표준 출력과 표준 오류를 합쳐(`2>&1`) 비교하도록 정했다. 동시에 33행은 Linux glibc의 `en_US.utf8` 표기를 고려하면서도 `C.UTF-8` 존재 여부는 확인하지 않고, 없으면 `C`로 떨어져 기준 로케일 역할이 같다고 적었다. Apple macOS 기본 `/bin/bash`(3.2)는 없는 로케일에도 경고를 출력하지 않으나, GNU bash와 glibc 조합(또는 Homebrew bash)에서는 존재하지 않는 `LC_ALL=C.UTF-8`로 서브프로세스를 시작할 때 헬퍼의 `export LC_ALL=C`가 실행되기 전에 `bash: warning: setlocale: LC_ALL: cannot change locale (C.UTF-8)` 경고가 stderr로 출력된다.
- **영향**: `en_US.UTF-8`은 설치되어 있고 `C.UTF-8`은 없는 GNU bash 환경에서 러너를 실행하면, `C.UTF-8` 쪽 `2>&1` 출력에만 `setlocale` 경고가 섞여 헬퍼 수정 뒤에도 회귀 케이스가 거짓 실패한다. 최신 macOS와 glibc 2.35 이상 Linux는 `C.UTF-8`을 기본 제공하므로 특수 조건에 해당한다.

</details>

### 검증 실행 기록

- **추적성 (`--trace`)**: `/Users/user/.gemini/config/skills/issue-audit/scripts/check-plan.sh --trace .ai/90_issues/archive/issue-0147/issue-0147-spec.md .ai/90_issues/archive/issue-0147/issue-0147-plan.md` → 무출력, 종료 코드 0 (위반 0건).
- **AC 대조 (`--ac`)**: `gh issue view 147 --repo scroogy-dev/scroogy-agent-skills --json body -q .body`로 본문을 임시 파일에 저장한 뒤 `check-plan.sh --ac` 실행 → 무출력, 종료 코드 0 (위반 0건). summary `이슈 본문 갱신` 줄은 비어 있으나 이슈 본문에 없는 AC는 0건이다.
- **발견 번호 계승**: `/Users/user/.gemini/config/skills/issue-audit/scripts/next-finding-number.sh ./issue-0147-plan-audit-report*.md` → `9` (작성 시점 경로는 `.ai/99_workspace/issue-0147-plan-audit-report*.md`, --clear로 이관) (1차 리포트 본문의 `UTF-8` 문자열이 `F-8`에 일치해 9를 반환). 헬퍼 출력에 맞춰 신규 발견을 `F-9`로 두고 머리말 `번호 기준선`에 경위를 남겼다.
- **위험도·상태·판정 산출**: `/Users/user/.gemini/config/skills/issue-audit/scripts/classify-risk.sh`로 F-9 위험도(`🟢 낮음(LOW)`), 1단계 상태(`🟢 충족(PASS)`), 2단계 상태(`🟢 통과(PASS)`), 종합 판정(`🟢 적합(PASS)`)을 산출했다.
- **Task 1·2 회귀 입력 및 나머지 헬퍼 5개 확인**: 수정 전 `check-quiz.sh`(3개 fixture)와 `check-context.sh`(Task 2의 `profile_state`·`dev_residue` 입력 2건)가 실제로 `C.UTF-8`과 `en_US.UTF-8`에서 다른 출력과 종료 코드를 내는 것을 직접 실행해 확인했다. 나머지 헬퍼 5개(`verify-submit.sh`, `verify-push.sh`, `check-lobby.sh`, `summarize-metrics.sh`, `check-clear.sh`) 소스에서도 한글 값끼리의 awk 비교·`sort`·`[[ … < … ]]`가 없음을 확인했다.
- **벤더 교차 확인**: summary `계획 모델`은 `Anthropic, Claude Opus 5.5 (claude-opus-5-5)`이고, 이번 감사 모델은 `Google, Gemini 4 Neon (gemini-4-neon-high)`으로 서로 다른 벤더다.

### 기등재 참조 항목

해당 없음

### 이전 발견 추적

<details>
<summary>이전 발견 추적 표 펼치기</summary>

| 이전 발견 | 완료 기준 항목 | 판정 (닫힘/잔여) | 근거 |
|-----------|----------------|------------------|------|
| F-1 | Task 2 회귀 케이스에 `profile_state`(95행) 또는 `dev_residue`(371행) 경로 가운데 최소 1개 이상이 명시되어 수정 전 `check-context.sh`에서 실제로 실패 | 닫힘 | plan 146–147행에 두 경로 모두 구체 입력과 기대 차이가 명시되었고, 수정 전 `check-context.sh`에서 두 입력 모두 `C.UTF-8`과 `en_US.UTF-8`의 출력·종료 코드가 갈리는 것을 확인했다 |
| F-1 | Task 2의 "재현 입력을 찾지 못했으면 실패 0건으로 커밋" 문구 삭제 | 닫힘 | plan Task 2(137–153행)에서 해당 예외 문구가 삭제됐다 |
| F-1 | `테스트 계획` AC2 줄 설명이 수정된 회귀 케이스 입력과 일치하고 정상 템플릿 날짜 치환 여부 명시 | 닫힘 | plan 58행에 "날짜를 바꾼 dev·doc 템플릿 사본, `profile_state` 경로 입력, `dev_residue` 경로 입력. 입력은 Task 2"로 명시되어 Task 2(143–147행)와 일치한다 |
| F-2 | 5개 헬퍼 수정 건수가 0건일 때 최종 감사 1단계에서 AC5가 `판정 불가(N/A)`로 떨어지지 않는 검증 구성이 `테스트 계획`에 명시 | 닫힘 | plan 34행·65–69행에서 5개 헬퍼 사전 확인 결과를 반영해 AC5를 `[QD]` 단독 검증으로 옮기고, Task 4에서 비교를 새로 찾으면 `[D]` 줄을 추가해 계획 감사를 다시 받도록 정리했다 |
| F-2 | Task N 전체 회귀의 "`테스트 계획`의 `[D]` 줄을 모두 실행해 통과를 확인한다" 조건과 충돌 없음 | 닫힘 | `테스트 계획` `[D]` 표(57–61행)에 조건부 빈 줄이 사라지고 AC1·AC2·AC3·AC4·AC6 실행 가능 줄만 남았다 |
| F-3 | `테스트 계획`에 `en_US.UTF-8` 미설치로 `건너뜀`이 나오거나 `LC_ALL=en_US.UTF-8`이 폴백되는 환경에서는 통과로 보지 않고 `판정 불가(N/A)`로 둔다는 기준 기재 | 닫힘 | plan 63행 `로케일 전제`에 `en_US.UTF-8`(`en_US.utf8`) 미설치 또는 `건너뜀` 출력 시 `failed: 0`이어도 통과로 보지 않고 `판정 불가(N/A)`로 둔다는 기준과 근거가 기재됐다 |
| F-3 | `설계 결정` 33행에 `C.UTF-8` 존재 여부 확인 기준 명시 | 닫힘 | plan 33행에 `C.UTF-8`은 확인하지 않고 `C` 폴백을 허용한다는 기준과 근거가 명시됐다 (단 `2>&1`과의 상호작용은 별도 신규 발견 F-9로 기록) |
| F-4 | `설계 결정` 32행에 표준 오류 포함(`2>&1`) 또는 분리 비교와 종료 코드 비교 방식이 명시되어 `issue-audit` `assert_locale`과의 차이가 드러남 | 닫힘 | plan 32행에 `2>&1` 합산 출력 비교·종료 코드 비교 방식과 `issue-audit` `assert_locale`(기대 출력 대조·`2>/dev/null`·종료 코드 미확인)과의 차이가 명시됐다 |

</details>
