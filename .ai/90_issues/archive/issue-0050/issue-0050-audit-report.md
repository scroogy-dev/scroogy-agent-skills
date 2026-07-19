# Issue #50 감사 리포트 — plan Task별 완료 기준에 검증 레벨 표기 도입 (5차 재검증)

> 감사 일시: 2026-07-19
> 감사 모델: OpenAI, GPT-5
> 감사 대상 브랜치: `issue-0050` (`1cc8ddd` + 현재 작업 트리)
> 스펙 출처: [issue-0050-spec.md](./issue-0050-spec.md) (작성 시점 경로는 `.ai/90_issues/active/issue-0050/issue-0050-spec.md`, --clear로 이관)

---

## 1단계: 적합성 검증 (Compliance Check)

### 요구사항 대조

| # | 요구사항 | 판정 | 근거 |
|---|----------|------|------|
| 1 | `## Tasks` 안내 블록에 문서 외 컨텍스트 없음 가정·결정적 우선·검증 레벨 안내 추가 | 충족(PASS) | `issue-plan-template.md:30-39`에 작성 원칙과 검증 레벨 3행이 있으며, spec 템플릿의 레벨 행과 `diff` 출력이 0건이다. |
| 2 | Task 1·2 예시의 완료 기준을 레벨 태그 항목 리스트로 교체 | 충족(PASS) | `issue-plan-template.md:73-76`, `87-89`에 각각 `[D]`와 `[QD]`/`[ND]` 예시, 검증 수단, 강등 사유가 있다. |
| 3 | Task 0 고정 블록의 기존 완료 조건을 같은 리스트 형식으로 보존 | 충족(PASS) | `issue-plan-template.md:61-62`가 기존 조건·사람 판정·강등 사유를 `[ND]` 한 항목으로 의미 손실 없이 옮겼다. |
| 4 | Task N 고정 블록의 기존 조건을 검증 레벨별 리스트로 분해 | 충족(PASS) | `issue-plan-template.md:108-116`이 기존 조건을 보존하고 `[D]` 4건·`[QD]` 2건·`[ND]` 1건으로 분해했다. Task 집합 게이트는 입력 실재 확인을 선행해 두 경로 오기까지 차단한다. |
| 5 | `SKILL.md`의 작업 진행 중 완료 기준 문장을 확인하고 필요 시 소폭 보정 | 충족(PASS) | `issue-work/SKILL.md:69`가 검증 레벨과 기록 형식을 spec·plan 템플릿에 위임하므로 새 형식과 모순이 없다. 변경하지 않은 판단이 스펙과 일치한다. |
| 6 | Task N `[D]` 게이트 명령의 반례 회귀 테스트 추가 | 충족(PASS) | `issue-work/tests/run-tests.sh`가 템플릿에서 게이트 3건을 추출해 정상 fixture와 반례 14종을 검사하며, 실행 결과 `passed: 20, failed: 0`, 종료 코드 0이다. ADR 0001의 동일 위치·경량 러너·고정 입력 비교·배포 제외 원칙에도 맞는다. |

### 완료의 정의(DoD) 대조

| # | DoD 항목 | 판정 | 근거 |
|---|----------|------|------|
| 1 | `## Tasks` 안내 블록에 “문서 외 컨텍스트” 축 명시 | 충족(PASS) | 명시된 `awk ... \| grep -c` 결과 `1`. |
| 2 | 검증 레벨 안내 3행이 spec 템플릿과 동일 | 충족(PASS) | 명시된 프로세스 치환 `diff` 출력 `0`건. |
| 3 | Task 0·1·2·N의 완료 기준에 레벨 태그 1개 이상 | 충족(PASS) | 블록별 태그 수가 Task 0=`1`, Task 1=`2`, Task 2=`2`, Task N=`7`. |
| 4 | Task N에 `[D]`와 `[QD]`/`[ND]` 항목 혼재 | 충족(PASS) | `[D]`=`4`, `[QD]`/`[ND]`=`3`. |
| 5 | Task 헤더 4건, 그 외 없음 | 충족(PASS) | `grep -cE '^### Task '` 결과 `4`; 헤더는 Task 0·1·2·N뿐이다. |
| 6 | Task 0·N의 기존 조건·강등 사유 보존 | 충족(PASS) | `origin/main`과 의미 대조한 결과 Task 0의 판정 주체·강등 사유와 Task N의 DoD 재실행·결과 확정·모델 값 필수·대표/전수 벤더 비교 조건이 모두 남아 있다. |
| 7 | `SKILL.md` 작업 진행 중 문장이 새 형식과 모순 없음 | 충족(PASS) | 특정 형식을 중복 정의하지 않고 spec·plan 템플릿을 SSoT로 가리킨다. |
| 8 | Task N 게이트가 정상 fixture를 통과시키고 명시 반례를 격추 | 충족(PASS) | `bash issue-work/tests/run-tests.sh`가 추출 3건, 정상 3건, 반례 14건을 모두 통과했다. `bash -n`과 `git diff --check origin/main`도 통과했다. |

### 범위 검증

- **스펙 비포함(Out) 침범 여부**: 없음. `issue-spec-template.md`, archive, 설치본은 변경하지 않았다.
- **스펙에 없는 추가 구현 여부**: 없음. 제품 변경은 plan 템플릿과 승인 확장된 회귀 테스트이며, `.ai/AI-CONTEXT.md` 변경은 새 `tests/` 경로를 반영한 안내도 동기화다.

### 도메인/계약/ADR 정합성

- 관련 계약·도메인 문서 없음.
- ADR 0001과 정합하다. 테스트는 `issue-work/tests/`에 있고 외부 의존성 없는 셸 러너와 고정 입력·기대 출력 비교를 사용하며, `install-skills/SKILL.md`의 `--exclude 'tests/'` 규칙으로 배포에서 제외된다.
- 코드베이스 색인은 비어 있다. 실제 템플릿·스킬·테스트·변경 전후 diff를 직접 확인했으며 색인과 소스의 불일치는 발견하지 못했다.

### 이전 감사 지적 재검증

| 이전 항목 | 결과 | 근거 |
|-----------|------|------|
| 4차 F-1: plan·summary 두 경로 오기 시 빈 입력끼리 일치 | 직접 반례 해소 | 두 파일에서 Task 헤더 실재를 선행 확인하고 실패를 stdout 위반 행으로 환원한다. 두 경로 동시 누락·미치환 `<번호>`·plan만 누락 fixture가 모두 실패한다. |
| 3차 F-1: Task 블록 전체 누락·Task N 누락·빈 summary 통과 | 직접 반례 해소 | plan↔summary Task 헤더 대조 게이트가 추가됐고, 올바른 plan 경로와 블록 전체 누락·Task N 누락·빈 summary를 조합한 fixture 3종이 모두 실패한다. 실제 Issue #50 plan↔summary 대조도 출력 0건이다. |
| 2차 F-1: `결과` 총개수 상쇄로 미확정 Task 통과 | 해소 유지 | 블록 단위 결과 게이트가 미확정+중복 상쇄·행 누락·중복·허용 외 값 fixture를 계속 실패시킨다. |
| 2차 F-2: 빈 값·행 누락 `수행 모델` 통과 | 해소 유지 | 모델 게이트가 빈 값·행 누락·`-`·중복 fixture를 계속 실패시킨다. |

---

## 2단계: 비판적 검증 (Critical Review)

### 발견 사항

| # | 위험도 | 분류 | 설명 | 관련 파일 |
|---|--------|------|------|-----------|
| F-1 | 낮음(LOW) | 암묵적 가정 / 스펙 모호성 | spec은 현재 Issue #50 plan의 Task별 완료 기준에 목표 형식을 선적용했다고 적었지만, 실제 plan의 Task 0·N은 레벨 태그 없는 개정 전 한 줄 형식이다. | `./issue-0050-spec.md:52`, `./issue-0050-plan.md:55,152` (행 번호는 감사 시점 기준) |
| F-2 | 정보(INFO) | 스펙 모호성 | spec 연관 문서 절은 관련 ADR이 없다고 적지만, Task 6의 테스트 위치·러너·배포 제외 판단은 ADR 0001을 직접 근거로 사용한다. | `./issue-0050-spec.md:59` (행 번호는 감사 시점 기준), `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` |

### 상세 분석

#### F-1: 현재 Issue #50 plan에 목표 형식을 선적용했다는 전제가 실제 문서와 다름

- **위험도**: 낮음(LOW)
- **분류**: 암묵적 가정 / 스펙 모호성
- **설명**: spec `전제`는 Issue #50 plan의 Task별 완료 기준에 레벨 태그 리스트를 선적용했다고 명시한다. 그러나 실제 plan의 Task 0·N 블록은 각각 레벨 태그가 0건이고 개정 전 한 줄 완료 기준을 유지한다.
- **영향**: 제품 산출물인 plan 템플릿과 DoD는 충족하므로 구현 PASS를 막지는 않는다. 다만 현재 이슈의 Task N을 수행하는 사용자는 새로 강화된 `[D]` 게이트가 active plan에도 들어 있다고 오인할 수 있다.
- **권장 조치**: active plan의 Task 0·N을 목표 형식으로 맞추거나, spec 전제를 “일반 실행 Task에만 선적용했으며 고정 블록은 소급하지 않음”으로 정정하고 현재 감사의 게이트 근거가 템플릿·spec DoD임을 명시한다.

#### F-2: 연관 문서 절에서 직접 적용한 ADR이 누락됨

- **위험도**: 정보(INFO)
- **분류**: 스펙 모호성
- **설명**: spec은 관련 ADR이 없다고 적었지만, plan Task 6과 구현은 ADR 0001의 테스트 동일 위치·경량 러너·고정 입력·배포 제외 규칙을 직접 따른다.
- **영향**: 구현 정합성에는 문제가 없고 감사 중 ADR을 직접 확인했다. 다만 근거 추적성이 약해진다.
- **권장 조치**: spec `연관 문서` 표에 ADR 0001을 추가한다.

---

## 종합 의견

- **최종 판정**: 충족(PASS)
- **1단계 집계**: 충족(PASS) 14건 / 미충족(FAIL) 0건 / 부분 충족(PARTIAL) 0건 / 판정 불가(N/A) 0건
- **2단계 집계**: 높음(HIGH) 0건 / 중간(MEDIUM) 0건 / 낮음(LOW) 1건 / 정보(INFO) 1건
- 4차 F-1과 이전 직접 반례는 모두 해소됐다. 잔여 2건은 구현 합/불을 뒤집지 않는 이슈 문서 정합성 문제이므로 Task N 완료를 차단하지 않는다.

### 검증 명령 요약

- 스펙 `[D]` 구조 검증: 전부 통과 (`1`, diff `0`건, 블록별 `1/2/2/7`, Task N `4/3`, 헤더 `4`)
- `bash issue-work/tests/run-tests.sh`: `passed: 20, failed: 0`, 종료 코드 0
- `bash install-skills/tests/run-tests.sh`: `passed: 20, failed: 0`, 종료 코드 0
- 현재 plan↔summary Task 집합 대조: diff 출력 `0`건
- 현재 summary의 `결과`·`수행 모델` 게이트: 각각 위반 `0`
- 구현 Task의 모든 벤더 `Anthropic`과 audit 벤더 `OpenAI`: 상이
- `issue-spec-template.md`·`issue-work/SKILL.md`·archive 변경: `0`건
- `git diff --check origin/main`, `bash -n issue-work/tests/run-tests.sh`: 통과
- 추가 반례: 두 경로 동시 누락·미치환 `<번호>`·plan만 누락 모두 stdout 위반 행을 출력해 실패
