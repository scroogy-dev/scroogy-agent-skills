# Issue #46 실행계획 — issue-audit 표기를 한글 우선 병기로 전환

> 스펙: [issue-0046-spec.md](./issue-0046-spec.md)

---

## 설계 종료 게이트 (고정)

> **점검 질문**: 이 spec/plan만 보고, 작성에 참여하지 않은 쪽이 구현에 필요한 내용을 스스로 알 수 있는가?

- [x] 점검 완료
- **점검 대상** (작성 중 머릿속에만 있었던 것):
  - 코드베이스 관례 — 이 repo에서만 통하는 패턴·명명·배치 규칙
  - 버전·환경 제약 — 특정 버전·플랫폼·도구에 묶인 조건
  - 검토 후 버린 대안과 그 이유
  - 사용자와의 합의로만 정해진 값
- **발견 시 조치**: spec `## 전제 (Assumptions)` 섹션에 적는다. 발견이 없으면 그 섹션에 "없음" 한 줄을 남긴다.
- **점검 결과**: 표기 관례의 출처(#45 사용자 지시), #45 폐기로 인한 선행 조건 무효, 검증 앵커 방식, 구현 시 확정 위임 항목(판정 명칭·단계 표기)의 Task 0 처리, 단계 번호 정합(0~3단계), 템플릿 판정 리터럴 부재, 전수 확인 결과를 spec 전제 7건으로 기록함.

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> 각 작업은 독립적으로 검증 가능해야 하며, **완료 기준은 자연어 대신 실행 명령 + 임계값**으로 적습니다.
> 명령으로 환원이 어려운 항목만 판정 주체(다른 AI / 사람)를 적고 강등 사유를 남깁니다.
> 첫 고정 Task(Task 0 구현 시작 게이트)와 마지막 고정 Task(교차모델 issue-audit)는 삭제하지 말고 그대로 둡니다.
>
> **문서를 대상으로 검증할 때는 문구가 아니라 행 구조를 셉니다** — 같은 문구가 주석·안내문에도 등장하므로
> `grep -c '<문구>'`는 실제 구조가 없어도 통과합니다. 헤더는 `^## `, Task는 `^### Task `,
> 필드는 `^- \*\*…\*\*:`로 앵커를 고정하고, 명령은 작업 디렉토리에 의존하지 않게 repo 루트 기준 경로로 적습니다.
> **검증 명령 보정은 반례 격추가 아니라 불변식 전수 명세로 합니다** — 지적된 변형 하나만 막으면 이웃 변형이
> 다음 감사에서 재발하므로, 기대 구조를 열거하고 "그 외 0건"까지 판정에 넣습니다.
>
> 판정 값 한글 명칭은 충족(PASS)/미충족(FAIL)/부분 충족(PARTIAL)/판정 불가(N/A), 단계 표기는 1단계/2단계로 Task 0에서 확정됐다(spec 전제 참조). 모든 명령은 repo 루트 기준.

### Task 0 (고정): 구현 시작 게이트 — 전제·모호점 확인

- [x] 완료
- **목표**: 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 코드 작성 전에 걷어낸다.
- **작업 내용**:
  1. spec/plan을 읽고, 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 나열한다.
  2. 항목이 있으면 **코드를 쓰기 전에 사용자에게 질의**하고, 답변을 spec `## 전제 (Assumptions)` 섹션에 반영한 뒤 구현을 시작한다. 이 이슈에서는 구현 시 확정 위임 항목 2건 — 판정 값 한글 명칭, 단계 표기 — 을 확정받는다 (수행 결과: 충족 계열·1단계/2단계로 확정, spec 전제 반영 완료).
  3. 항목이 없으면 summary Task 0의 `수행 내용 요약`에 `전제 누락 없음` 한 줄을 기록하고 진행한다.
- **완료 기준**: 나열한 항목이 전부 spec `## 전제 (Assumptions)`에 반영되어 미해소 0건이거나, summary Task 0에 `전제 누락 없음`이 기록된다. (판정 주체: 사람 ← 강등 사유: 전제·모호점을 빠짐없이 나열했는지는 의미 판단이라 명령으로 환원 불가)

---

### Task 1: 위험도 표기 전환

- [x] 완료
- **목표**: 위험도 4단계 표기를 높음(HIGH)/중간(MEDIUM)/낮음(LOW)/정보(INFO)로 전환한다 (의미 문구 불변).
- **작업 내용**:
  1. `issue-audit/SKILL.md` 위험도 분류 표 1열 전환.
  2. `issue-audit/SKILL.md` 출력 요약 형식의 위험도 집계 줄 전환.
  3. `issue-audit/templates/issue-audit-report-template.md`의 위험도 필드(`- **위험도**: HIGH / MEDIUM / LOW / INFO`) 전환.
- **완료 기준**: `grep -cE '^\| (높음\(HIGH\)|중간\(MEDIUM\)|낮음\(LOW\)|정보\(INFO\)) \|' issue-audit/SKILL.md` = 4 && `grep -cE '^\| (HIGH|MEDIUM|LOW|INFO) \|' issue-audit/SKILL.md` = 0 && `grep -c '높음(HIGH): N건 / 중간(MEDIUM): N건 / 낮음(LOW): N건 / 정보(INFO): N건' issue-audit/SKILL.md` = 1 && `grep -c '높음(HIGH) / 중간(MEDIUM) / 낮음(LOW) / 정보(INFO)' issue-audit/templates/issue-audit-report-template.md` = 1 && `grep -cE 'HIGH / MEDIUM / LOW / INFO' issue-audit/templates/issue-audit-report-template.md` = 0 && 의미 문구 불변 diff(spec DoD 3항의 위험도 명령) 차이 0건

---

### Task 2: 판정 값 표기 전환

- [x] 완료
- **목표**: 판정 값 4종 표기를 충족(PASS)/미충족(FAIL)/부분 충족(PARTIAL)/판정 불가(N/A)로 전환한다 (Task 0 확정값, 의미 문구 불변).
- **작업 내용**:
  1. `issue-audit/SKILL.md` 판정 기준 표 1열 전환.
  2. `issue-audit/SKILL.md` 출력 요약 형식의 판정 집계 줄 전환.
  3. 리포트 템플릿은 판정 값 리터럴이 없음을 확인만 한다 (spec 전제 "템플릿 판정 리터럴 부재") — `grep -cE '\b(PASS|FAIL|PARTIAL)\b' issue-audit/templates/issue-audit-report-template.md` = 0 유지.
- **완료 기준**: `grep -cE '^\| (충족\(PASS\)|미충족\(FAIL\)|부분 충족\(PARTIAL\)|판정 불가\(N/A\)) \|' issue-audit/SKILL.md` = 4 && `grep -cE '^\| (PASS|FAIL|PARTIAL|N/A) \|' issue-audit/SKILL.md` = 0 && `grep -c '충족(PASS): N건 / 미충족(FAIL): N건 / 부분 충족(PARTIAL): N건 / 판정 불가(N/A): N건' issue-audit/SKILL.md` = 1 && 의미 문구 불변 diff(spec DoD 3항의 판정 명령) 차이 0건 (판정 집계 패턴은 PR #49 리뷰 보정으로 4종 갱신 — spec DoD 5항 참조)

---

### Task 3: 단계 명명 전환

- [x] 완료
- **목표**: Phase 1/Phase 2 명명을 1단계/2단계로 전환해 절차의 0~3단계 번호와 연속되게 한다 (Task 0 확정값 기준).
- **작업 내용**:
  1. `issue-audit/SKILL.md` — 개요의 단계 항목 2건, 참조 문서의 본문 참조 1건, 절차 제목 2건, 출력 요약 형식의 단계 제목 2건 전환. 제목의 영문 부제(`(Compliance Check)`·`(Critical Review)`)는 유지.
  2. `issue-audit/templates/issue-audit-report-template.md` — 단계 제목 2곳 전환.
- **완료 기준**: `grep -c 'Phase' issue-audit/SKILL.md` = 0 && `grep -c 'Phase' issue-audit/templates/issue-audit-report-template.md` = 0 && `grep -cE '^### 1단계: 적합성 검증 \(Compliance Check\)$|^### 2단계: 비판적 검증 \(Critical Review\)$' issue-audit/SKILL.md` = 2 && `grep -cE '^## 1단계: 적합성 검증 \(Compliance Check\)$|^## 2단계: 비판적 검증 \(Critical Review\)$' issue-audit/templates/issue-audit-report-template.md` = 2

---

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

- [x] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **실행 주체**: **사용자가 직접** 수행한다. 구현 AI는 이 Task를 **자동으로 닫지 않으며**, `issue-audit`를 자동 실행하지도 않는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 전부 재실행해 통과를 확인한다.
  2. 구현을 수행한 모델과 **다른 벤더 모델**(최소 동급 이상 역량)로 사용자가 직접 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 사용자가 audit 결과(지적 사항·감사 모델)를 summary에 반영·기록한다. 발견사항 보정은 issue-work `--response`로 검토한다 — **피드백 먼저, 항목별 승인 후에만** 앞 Task를 보정하며, 리포트를 받자마자 자동 보정하지 않는다.
- **완료 기준**: `[D]` 검증 명령 전부 통과 + summary `모델 기록` 표의 `구현 모델`·`audit 모델` 두 행이 서로 다른 벤더로 채워진다("벤더, 모델명" 형식). 구현에 여러 벤더가 관여했으면 audit 모델의 벤더는 Task 0 및 일반 실행 Task의 비어 있지 않은 모든 `수행 모델` 값에 나열된 벤더 전부와도 달라야 한다 — 표의 대표값 비교만으로는 audit 벤더의 구현 참여를 놓치고, 한 Task를 여러 모델이 수행했으면 그 값에 나열된 벤더를 모두 비교 대상에 넣는다. 이때 완료·부분 완료 Task의 `수행 모델`은 `-`일 수 없다(`-`는 미착수·스킵 전용) — 전부 `-`로 남기면 이 강화 조건이 공집합이 되어 우회가 된다. 또한 이 검증 전에 Task 0 및 모든 일반 실행 Task의 summary `결과`가 완료·부분 완료·스킵 중 하나로 확정돼 있어야 한다 — `결과`를 비워 두면 "완료·부분 완료면 값 필수" 조건이 발동하지 않아 강화 조건이 다시 공집합이 되기 때문이다.
