# Issue #114 감사 리포트 doc 프로파일 SSoT 선언과 원본 문서 색인

> 감사 일시: 2026-10-23 (Asia/Seoul)  
> 감사 모델: OpenAI, GPT-6 (gpt-6-astra)  
> 감사 effort: high  
> 감사 회차: 최종 감사 3차 (이전 리포트: [1차](issue-0114-audit-report-1.md), [2차](issue-0114-audit-report-2.md))  
> 감사 대상 브랜치: issue-0114 (`97cbe21aa24e5089fb6ee3075be68deb32cd1308`)  
> 비교 기준: main (`23c92bb6525d6fcaf30531d4ca4867b209d07ad4`)  
> 스펙 출처: [spec](./issue-0114-spec.md), [plan](./issue-0114-plan.md), [summary](./issue-0114-summary.md)

## 종합 의견

🟢 적합(PASS)

<details>
<summary>종합 의견 펼치기</summary>

- 이전 F-1·F-2·F-3의 완료 기준을 대조해 모두 닫았으며 신규 발견은 없다.
- Task 3·4의 구조 회귀 검사와 원복 반례가 통과했고, 별도 세션 감사인이 fixture 8건을 모의 실행해 기대 결과와 대조했다.
- 감사 보정 대상은 없으나 사람 확인 DoD 2건과 plan의 rename 실사용 확인은 미검증이다. 이 판정은 사람 확인이나 summary의 Task N 기록을 대신하지 않는다.

</details>

## 요약

- 1단계 적합성: 🟢 충족(PASS) · 충족(PASS) 28건 / 미충족(FAIL) 0건 / 부분 충족(PARTIAL) 0건 / 판정 불가(N/A) 2건
- 2단계 위험도: 🟢 통과(PASS) · 높음(HIGH) 0건 / 중간(MEDIUM) 0건 / 낮음(LOW) 0건 / 정보(INFO) 0건
- 기등재 참조: 1건(K-0006, 위험도·카테고리 집계 제외)
- 이전 발견: 닫힘 3건 / 잔여 0건(F-2·F-3은 같은 결함의 계보)

| 카테고리 | 건수 |
|----------|------|
| 기능 | 0 |
| 아키텍처 | 0 |
| 버그 | 0 |
| 보안 | 0 |
| 코드품질 | 0 |
| 성능 | 0 |
| 테스트 | 0 |

## 1단계: 적합성 검증 (Compliance Check)

### 요구사항 대조

| # | 요구사항 | 판정 | 근거 |
|---|----------|------|------|
| R1 | 선언 읽기·부재 시 폴백 | 🟢 충족(PASS) | 지정 8개 파일의 본문 위치·허용 값·폴백 의미 대조 및 spec:56 명령 통과 |
| R2 | doc 선언·우선순위·ssot_dir·publish, dev 보존 | 🟢 충족(PASS) | doc 템플릿 임시 init 복사 검사와 Task 1 원복 반례 통과 |
| R3 | 두 표준 문구·doc ssot_dir 검사와 보강 | 🟢 충족(PASS) | check-context.sh:24,64,73, SKILL.md:248~249. 정상·격추 검사 및 Task 1 러너 통과 |
| R4 | 공통 선언 참조·원본 문서 작업 절 | 🟢 충족(PASS) | shared context-loading.md:27~34,51. repo 사본과 동일 |
| R5 | SSoT 색인 정의 | 🟢 충족(PASS) | shared index:3, doc 안내도 3곳, ai-workspace 소개·context-harvest 관계표 일치 |
| R6 | SSoT에 대응하는 What·Why 수집 | 🟢 충족(PASS) | context-harvest/SKILL.md:42~45. 수집 fixture 4건 대조 |
| R7 | publish·유래 기준 퍼블리싱 제외 | 🟢 충족(PASS) | context-harvest/SKILL.md:46,253. 선언 위치 아래 제외와 비파생 자료 허용을 fixture로 대조 |
| R8 | 근거 출처 4열·frontmatter 보존 | 🟢 충족(PASS) | 40_domain-template.md:11~19. 3키 보존, 원본 반영 절 없음, dev 삭제·doc 유지 모의 실행 |
| R9 | doc 색인 절차·루트 변경·교차 참조 | 🟢 충족(PASS) | doc.md 0~4단계 직접 확인. build·sync·루트 변경 fixture 4건 대조, rename 이전 경로 확보 |
| R10 | 색인 맥락 5곳·git-pr 괄호 교체 | 🟢 충족(PASS) | 지정 문구만 변경. 8곳의 위치·허용 값·폴백이 같은 뜻이며 리뷰·감사 절차 변경 없음 |
| R11 | 정책·명세·색인·안내도 정합 | 🟢 충족(PASS) | SSoT 정책, ai-workspace 명세·흐름, 안내도·README 및 tests 역할 분담 대조 |

### 완료의 정의(DoD) 대조

| # | DoD 항목 | 판정 | 근거 |
|---|----------|------|------|
| D1 | R1 [D] 8개 파일 폴백 | 🟢 충족(PASS) | spec:56, 무출력·exit 0 |
| D2 | R1 [QD] 위치·허용 값·폴백 의미 동치 | 🟢 충족(PASS) | 본문 2번째 줄(H1·뒤 빈 줄 제외), 소스 코드/원본 문서, 그 외 값·부재 시 폴백을 8곳 직접 대조 |
| D3 | R2 [D] doc init 선언·우선순위·표 행 | 🟢 충족(PASS) | spec:74, 무출력·exit 0 |
| D4 | R3 [D] 헬퍼 정상 3종·격추 4종 | 🟢 충족(PASS) | spec:100, 무출력·exit 0 |
| D5 | R3 [D] doc 테스트 실행 | 🟢 충족(PASS) | spec:127, 무출력·exit 0. Task 1 추가 명령에서 doc 고유 행 정상 1·격추 4 실행도 확인 |
| D6 | R3 [D] 검사 표 doc·ssot_dir·10행 | 🟢 충족(PASS) | spec:142, 무출력·exit 0 |
| D7 | R4 [D] 원본 문서 작업 절·repo 사본 | 🟢 충족(PASS) | spec:158, 무출력·exit 0 |
| D8 | R5 [D] SSoT 색인 정의 | 🟢 충족(PASS) | spec:178, 무출력·exit 0 |
| D9 | R6 [D] 수집 필터 일반화 | 🟢 충족(PASS) | spec:198, 무출력·exit 0 |
| D10 | R7 [D] 퍼블리싱 제외 규칙 | 🟢 충족(PASS) | spec:215, 무출력·exit 0 |
| D11 | R7 [ND] 실제 doc 수집·publish 제외 | ⚪ 판정 불가(N/A) | 사람의 실제 실행 기록 없음. fixture QD는 외부 수집을 수행하지 않으므로 이 항목을 대체하지 않음 |
| D12 | R8 [D] 근거 출처·frontmatter | 🟢 충족(PASS) | spec:233, 무출력·exit 0 |
| D13 | R9 [D] doc 구조·연결·기존 참조 보존 | 🟢 충족(PASS) | spec:250, 무출력·exit 0. Task 4 rename·러너·원복 명령도 통과 |
| D14 | R9 [ND] 실제 build·교차 참조 생성 | ⚪ 판정 불가(N/A) | 사람의 build 실행 증거 없음. 고정 입력을 적용한 QD와 구분 |
| D15 | R10 [D] 구 문구 제거·폴백 | 🟢 충족(PASS) | spec:275, 무출력·exit 0 |
| D16 | R11 [D] 정책 용어·출처 반영 | 🟢 충족(PASS) | spec:291, 무출력·exit 0 |
| D17 | R11 [QD] 정책과 R1~R10 의미 정합 | 🟢 충족(PASS) | 선언·우선순위·ssot_dir·publish·출처 구분·색인 정의 대조. 정책의 지도 표현은 .ai 문맥으로 판단 |
| D18 | 공통 [D] 전체 스킬 테스트 | 🟢 충족(PASS) | spec:307, 모든 */tests/run-tests.sh 통과, 위반 출력 없음 |
| D19 | 공통 [D] dev·local/global 무변경 | 🟢 충족(PASS) | spec:316, 무출력·exit 0 |

### 경계 검증

- **제외 범위**: dev 전용 템플릿, code-map local/global 참조, 로비, git-qa 무변경이다. 리뷰·감사 스킬은 지정된 SSoT 문구만 바뀌었다.
- **추가 구현**: git-pr 괄호, 정책·명세·색인 동기화, Task 3·4 tests 및 architecture 역할 분담 보강은 spec 전제·plan·summary의 승인 기록에 있다. 새 CLI 옵션·제품 헬퍼·퍼블리싱 관리 기능은 없다.

### 도메인/계약/ADR 정합성

- 관련 index에서 선택한 SSoT 정책·ai-workspace 명세·init/update 흐름과 ADR 0001·0002·0008·0019를 실제 변경에 대조했다. 외부 API·연동 계약 변경은 없다.
- 독립 실행 폴백·분기별 references는 ADR 0002, shared 규칙 사본은 ADR 0008과 일치한다. Task 1·3·4의 테스트 배치·정상/반례 실행·원복 검출이 ADR 0019 기준을 충족한다.
- 색인 행과 상세 흐름은 이번 변경과 일치한다. 전체 index의 과거 source_hash는 #114 부분 갱신이라는 명시적 결정으로 유지되어 있어 갱신 누락으로 보고하지 않는다.

## 2단계: 비판적 검증 (Critical Review)

### 발견 사항

신규·잔여 발견 없음.

| # | 위험도 | 영향 | 발생확률 | 카테고리 | 계보 | 설명 | 관련 파일 |
|---|--------|------|----------|----------|------|------|-----------|

### 상세 분석

- 변경된 실행 동작·검사 구조를 Task별로 대조했다. Task 1은 검사기 분기와 doc 템플릿 원복, Task 3은 수집 필터·출처 섹션, Task 4는 색인 범위·루트 대조·경로 이전·태그 보존을 덮는다.
- Task 3·4의 셸 러너는 규칙 문장의 구조와 fixture 쌍의 존재를 검사한다. fixture 결과를 자동 채점하지 않는다는 한계를 명시하고, 이번 감사에서 아래 QD 대조를 수행했다.
- 수집·색인은 자연어 절차이므로 모의 실행 결과를 실제 서비스 실행 보장으로 확대하지 않는다. 미검증 ND는 D11·D14와 아래 후속 확인에 남긴다.

### 기등재 참조 항목

<details>
<summary>기등재 참조 표 펼치기</summary>

| 원장 항목 | 상태 | 대조한 발견 내용 | 재검토 조건 충족 | 처리 |
|-----------|------|------------------|------------------|------|
| K-0006 | 수용 | code-map check 정합성 점검의 결정적 헬퍼 부재 | 미충족. local/global 점검 표 무변경, 실제 repo를 대상으로 check 모드를 실행하지 않음 | 기등재 K-0006 참조. 집계 제외 |

- 고정 입력의 root-changed-check QD는 실사용 check 운용과 구분한다. 제품용 헬퍼 도입은 이번 테스트 보정의 완료 조건이 아니다.
- 원장 index의 active·archive 항목을 대조했으며 이번 변경에서 같은 결함의 재발·재제기 근거는 찾지 못했다.

</details>

### 이전 발견 추적

<details>
<summary>이전 발견 추적 표 펼치기</summary>

| 이전 발견 | 완료 기준 항목 | 판정 (닫힘/잔여) | 근거 |
|-----------|----------------|------------------|------|
| F-1 | rename 입력에 이전·새 경로 제공 | 닫힘 | doc.md:64의 --name-status -M. Task 4 rename 검사 및 원복 반례 통과 |
| F-1 | 내부 rename의 옛 행 제거·새 행 1개·수동 Why 보존 | 닫힘 | doc.md:74, sync-same-root QD에서 old.md 제거·remote-work.md 생성과 설명 이전 확인 |
| F-1 | 루트 밖 이동 제거·안 이동 추가·반영 뒤 메타데이터 갱신 | 닫힘 | doc.md:66,75~76 및 sync-same-root QD |
| F-2 | Task 1 정상·반례와 doc 템플릿 원복 실패 | 닫힘 | plan:110 명령 통과. 고유 행 정상 1·격추 4, 23c92bb 템플릿 사본 실패 |
| F-2 | Task 3·4 테스트 파일·범위·기대 결과·Task 실행 기준 | 닫힘 | tests/run-tests.sh·각 4쌍 fixture 추가, plan Task 3·4에 D·QD 연결 |
| F-2 | 자동 원복 검증과 의미 검증 분리·수행 | 닫힘 | Task별 원복 명령 통과, QD 8건 이번 감사에서 통과. ND 미검증은 별도 유지 |
| F-3 (F-2 잔여) | Task 3 doc/dev·선언 부재·퍼블리싱·근거 출처 입력/기대 결과 | 닫힘 | 선언 부재 폴백 삭제 반례, invalid-declaration 폴백 QD, doc-publish·doc-no-publish·dev-source QD 및 plan 연결 |
| F-3 (F-2 잔여) | Task 4 build·sync·루트 변경·삭제·rename·Why 보존 입력/기대 결과 | 닫힘 | doc-index fixture 4쌍과 25개 규칙 변형, plan 연결 |
| F-3 (F-2 잔여) | 자동 정상·반례·원복 실패, 의미 검증 결과 또는 미검증 상태 | 닫힘 | 정상 2·변형 41 실행, 23c92bb·8c1abab 원복 실패. QD 8건 통과, ND 미검증 명시 |

- 2차의 F-3 완료 기준은 의미 검증의 수행 결과 또는 미검증 상태 기록을 허용한다. 사람 ND가 미검증이라는 이유만으로 같은 테스트 공백을 다시 열지 않는다.
- 보존 전 1·2차 최종 리포트를 번호 헬퍼에 넘겨 다음 번호 4를 받았다. 이번 발견은 0건이며 새 번호를 소비하지 않았다. 계획 감사 번호는 별도 축이다.

</details>

### 모의 실행 [QD] 결과

<details>
<summary>고정 입력 적용 결과와 기대 조건 대조</summary>

- 판정자: 이 리포트의 감사 모델. 각 input의 사실에 SKILL.md·doc.md 절차를 적용하고 expected의 판정 조건과 대조했다. 외부 URL 조회·실제 서비스 수집·repo check 운용은 수행하지 않았다.

| 스킬 / 케이스 | 적용 결과 | 대조 |
|----------------|-----------|------|
| context-harvest / dev-source | C1·C3 수집, C2 제외. 근거 출처 섹션 삭제, 수집 URL은 원본 출처에만 기재 | 일치 |
| context-harvest / doc-publish | C1·C4 제외, C2·C3 수집. 근거 출처에 예시근로법 제60조·2026-01-01·확인일, publish URL 제외 | 일치 |
| context-harvest / doc-no-publish | C1 파생 사본 제외·repo password.md 참조, C2 비파생 자료 수집. 예시보안표준 5.1절·2025-07-01 근거 출처 유지 | 일치 |
| context-harvest / invalid-declaration | 위키 값을 인정하지 않고 소스 코드로 폴백. C1 수집·C2 제외, 근거 출처 섹션 삭제 | 일치 |
| code-map / build | docs 3행, notes·README 제외. retention에 정책·ADR 링크, refund에 WHY, onboarding 관련 문서 빈칸. c0ffee1·docs/·current, 신규 3 | 일치 |
| code-map / sync-same-root | leave 갱신, remote-work에 old의 ADR·수동 WHY 설명 이전, benefits 추가. gone·old·out·drafts 행 없음. 반영 뒤 b2b2b2b | 일치 |
| code-map / root-changed-sync | sync → rebuild 알림. leave·conduct·intro 3행, leave 수동 WHY 보존·conduct WHY 추가. docs/, handbook/·d4d4d4d로 반영 뒤 갱신 | 일치 |
| code-map / root-changed-check | 행·frontmatter 보존. 루트 불일치와 전체 UPDATE-NEEDED 보고, rebuild 권고. 최신으로 보고하지 않음 | 일치 |

- code-map의 주제 문장 표현·DOC-NEEDED 병기는 README가 정한 채점 범위에서 제외했다. sync-same-root의 rename 건수 귀속은 절차에 정의되어 있지 않아 fixture 기준대로 판정하지 않았다.
- R1 8곳 의미 동치, R11 정책 정합, Task 3 분기 명확성, Task 4 절차 자기완결성도 직접 대조해 충족으로 판정했다.

</details>

### 검증 실행 기록

<details>
<summary>명령 실행·모델 기록·산출물 보존</summary>

- spec Bash 블록 15개와 일반 Task 추가 Bash 블록 12개를 현재 트리에서 Bash로 실행했다. 공통 들여쓰기만 제거했고 27개 모두 stdout·stderr 없음, exit 0이다.
- spec 공통 명령으로 모든 스킬 러너를 실행했다. Task 3 정상 1·격추 16, Task 4 정상 1·격추 25의 케이스 행을 plan 명령으로 확인했으며 각 fixture 쌍 4건도 검사됐다.
- Task 1의 doc 템플릿 원복, Task 3의 SKILL.md·템플릿 원복, Task 4의 doc 도입 전 및 rename 보정 전 원복 사본에서 러너 실패를 확인했다. 원복은 임시 디렉토리에서만 수행했다.
- git diff --check main...HEAD 통과. 원문 명령과 출력 기록: `/var/folders/22/lwf9n0h57sd2fp8ycxnj5pb80000gn/T/issue-0114-audit3-fm__b8vg/results.json` 및 같은 디렉토리의 spec/plan 번호별 sh 파일.
- 현재 CODEX_THREAD_ID와 일치하는 `rollout-2026-10-23T14-01-57-01a16723-20a1-7113-a1a7-61b5321a1f05.jsonl`의 동일 turn_context에서 model=gpt-6-astra, effort=high를 읽었다. summary Task 0~6의 구현 벤더는 모두 Anthropic으로 감사 벤더와 다르다.
- 설치된 issue-audit 헬퍼에 PASS 28개·N/A 2개, 발견 등급 0개를 넘겨 상태·최종 판정을 산출했다. 기존 2차 리포트를 -2.md로 원문 그대로 보존했다.
- 고정 Task N의 사용자 기록 게이트는 기능 검증 집계에서 제외했다. 구현 파일·spec·plan·summary·원장은 수정하지 않았다.

</details>

### 남은 확인

- 사람 확인: spec R7의 실제 수집·publish 제외, R9의 실제 build·교차 참조 생성, plan Task 4의 rename sync 실사용 결과.
- 사용자 기록: 최종 audit 모델·effort와 3차 결과를 summary에 반영하고 Task N 완료 여부를 기록한다. 감사 결과 자체의 보정 대상은 없다.
