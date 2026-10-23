# Issue #114 감사 리포트 doc 프로파일 SSoT 선언과 원본 문서 색인

> 감사 일시: 2026-10-23 (Asia/Seoul)  
> 감사 모델: OpenAI, GPT-6 (gpt-6-astra)  
> 감사 effort: high  
> 감사 회차: 최종 감사 2차 (이전 리포트: [1차](issue-0114-audit-report-1.md))  
> 감사 대상 브랜치: issue-0114 (`8c1ababb21676a5efd9b6b0fd69599aebca33197` + 미커밋 보정 포함)  
> 비교 기준: main (`23c92bb6525d6fcaf30531d4ca4867b209d07ad4`)  
> 스펙 출처: [spec](./issue-0114-spec.md), [plan](./issue-0114-plan.md), [summary](./issue-0114-summary.md)

## 종합 의견

🟡 조건부 적합(CONDITIONAL)

<details>
<summary>종합 의견 펼치기</summary>

- 이전 F-1의 이름 변경 입력·처리 절차와 F-2의 Task 1 테스트 공백은 해소됐다.
- Task 3·4의 테스트 공백은 F-3(F-2 잔여)으로 남겨 `issue-work --response`에서 판단한다. 절차 문장으로 구현한 기능도 감사 관점 5의 대상이며, 현재 plan의 미작성 사유만으로 테스트 완료로 판정하지 않는다.
- 스펙의 사람 확인 항목 2건은 실행 증거가 없어 판정 불가다. 이 리포트는 해당 확인이나 Task N 완료를 대신하지 않는다.

</details>

## 요약

- 1단계 적합성: 🟢 충족(PASS) · 충족(PASS) 28건 / 미충족(FAIL) 0건 / 부분 충족(PARTIAL) 0건 / 판정 불가(N/A) 2건
- 2단계 위험도: 🟡 주의(WARN) · 높음(HIGH) 0건 / 중간(MEDIUM) 1건 / 낮음(LOW) 0건 / 정보(INFO) 0건
- 기등재 참조: 1건 (K-0006, 위험도·카테고리 집계 제외)
- 이전 발견: 닫힘 1건(F-1) / 잔여 1건(F-2 → F-3). 독립된 신규 결함은 0건.

| 카테고리 | 건수 |
|----------|------|
| 기능 | 0 |
| 아키텍처 | 0 |
| 버그 | 0 |
| 보안 | 0 |
| 코드품질 | 0 |
| 성능 | 0 |
| 테스트 | 중간(MEDIUM) 1 |

## 1단계: 적합성 검증 (Compliance Check)


### 요구사항 대조

요구사항 표는 배포된 절차·코드의 구현 여부를 판정한다. 사람의 실제 사용 확인은 아래 DoD 표에서 별도로 판정한다.

| # | 요구사항 | 판정 | 근거 |
|---|----------|------|------|
| R1 | 선언 읽기·부재 시 폴백 | 🟢 충족(PASS) | 지정된 8개 파일 모두 본문 위치·허용 값 2종·폴백을 명시. R1 D와 의미 대조 통과 |
| R2 | doc 선언·우선순위·ssot_dir·publish, dev 보존 | 🟢 충족(PASS) | doc 템플릿의 선언·도메인 표·진입 절차, 임시 init 복사 결과 확인. dev 전용 파일 diff 없음 |
| R3 | 두 표준 문구·doc ssot_dir 검사와 보강 | 🟢 충족(PASS) | check-context.sh:24,64,73 및 SKILL.md:248~249. 정상·격추 입력, 41개 테스트, 검사 표 10행 통과 |
| R4 | 공통 선언 참조·원본 문서 작업 절 | 🟢 충족(PASS) | shared context-loading.md의 색인→관련 문서→ssot_dir 직접 확인. repo 사본과 동일 |
| R5 | SSoT 색인 정의 | 🟢 충족(PASS) | shared index 3행, doc 안내도 3곳, ai-workspace 소개, context-harvest 관계표 일치 |
| R6 | SSoT에 대응하는 What·Why 수집 | 🟢 충족(PASS) | context-harvest/SKILL.md:42~45의 doc 분기·일반화 필터 |
| R7 | publish·유래 기준 퍼블리싱 제외 | 🟢 충족(PASS) | context-harvest/SKILL.md:46 및 수집 제외 표. 선언 위치 아래 자료는 판단 없이 제외, 그 밖은 유래로 판정 |
| R8 | 근거 출처 4열·frontmatter 보존 | 🟢 충족(PASS) | 40_domain-template.md:11~19. frontmatter 첫 5행 main과 동일, 원본 반영 절 없음 |
| R9 | doc 색인 절차·루트 변경 처리·교차 참조 | 🟢 충족(PASS) | doc.md의 build/sync/check, 루트 선대조와 rebuild, 3열 표·태그, SKILL.md의 모드 분기. rename 입력·태그 이전 절차도 보정됨(이전 발견 추적 참조) |
| R10 | 색인 맥락 5곳과 git-pr 괄호 교체 | 🟢 충족(PASS) | 5개 SKILL.md의 구 문구 제거·폴백 확인. 리뷰·감사 절차 변경 없음 |
| R11 | 정책·명세·색인·안내도 정합 | 🟢 충족(PASS) | ssot-and-router-principle.md, ai-workspace 명세·흐름, 안내도·README를 실제 변경과 대조 |

### 완료의 정의(DoD) 대조

| # | DoD 항목 | 판정 | 근거 |
|---|----------|------|------|
| D1 | R1 [D] 8개 파일 폴백 | 🟢 충족(PASS) | spec:56 명령 무출력·exit 0 |
| D2 | R1 [QD] 위치·허용 값·폴백 의미 동치 | 🟢 충족(PASS) | 8곳 모두 본문 2번째 줄(H1·뒤 빈 줄 제외), 소스 코드/원본 문서, 부재·그 외 값 폴백을 명시 |
| D3 | R2 [D] doc init 선언·우선순위·표 행 | 🟢 충족(PASS) | spec:74 명령 무출력·exit 0 |
| D4 | R3 [D] 헬퍼 정상 3종·격추 4종 | 🟢 충족(PASS) | spec:100 명령 무출력·exit 0 |
| D5 | R3 [D] doc 테스트 케이스 실행 | 🟢 충족(PASS) | spec:127 명령 무출력·exit 0. 현재 러너의 정상·격추 케이스 통과(총 41건) |
| D6 | R3 [D] 검사 표 doc·ssot_dir·10행 | 🟢 충족(PASS) | spec:142 명령 무출력·exit 0 |
| D7 | R4 [D] 원본 문서 작업 절·repo 사본 일치 | 🟢 충족(PASS) | spec:158 명령 무출력·exit 0 |
| D8 | R5 [D] SSoT 색인 정의 반영 | 🟢 충족(PASS) | spec:178 명령 무출력·exit 0 |
| D9 | R6 [D] 수집 필터 일반화 | 🟢 충족(PASS) | spec:198 명령 무출력·exit 0 |
| D10 | R7 [D] 퍼블리싱 제외 규칙 | 🟢 충족(PASS) | spec:215 명령 무출력·exit 0 |
| D11 | R7 [ND] doc repo의 실제 수집·publish 제외 | ⚪ 판정 불가(N/A) | 사람이 실행해 확인한 산출물·기록이 입력에 없다. 외부 출처 수집을 수행한 것으로 간주하지 않음 |
| D12 | R8 [D] 근거 출처·frontmatter | 🟢 충족(PASS) | spec:233 명령 무출력·exit 0 |
| D13 | R9 [D] doc.md 구조·연결·기존 참조 보존 | 🟢 충족(PASS) | spec:250 명령 무출력·exit 0. plan:207의 rename 절차 검사도 통과; 실제 사용 확인은 D14와 분리 |
| D14 | R9 [ND] 실제 build·교차 참조 생성 | ⚪ 판정 불가(N/A) | summary Task 4가 미판정으로 남겼고 사람 확인 증거 없음. 감사인의 rename 절차 점검은 사람의 build 확인을 대신하지 않음 |
| D15 | R10 [D] 구 문구 제거·폴백 | 🟢 충족(PASS) | spec:275 명령 무출력·exit 0 |
| D16 | R11 [D] 정책 용어·출처 반영 | 🟢 충족(PASS) | spec:291 명령 무출력·exit 0 |
| D17 | R11 [QD] 정책과 R1~R10 의미 정합 | 🟢 충족(PASS) | 선언·폴백·우선순위·ssot_dir·publish·유래 구분·색인 정의를 대조. 정책의 마크다운 지도 표현은 .ai 안내·색인 문맥으로 판단 |
| D18 | 공통 [D] 전체 스킬 테스트 | 🟢 충족(PASS) | spec:307 명령 무출력·exit 0. 모든 */tests/run-tests.sh 실행 |
| D19 | 공통 [D] dev·local/global 무변경 | 🟢 충족(PASS) | spec:316 명령 무출력·exit 0 |

### 경계 검증

- **제외 목록 침범**: dev 전용 템플릿, code-map local/global 참조, 로비, git-qa는 변경되지 않았다. 리뷰·감사 절차도 지정된 선언 문구 변경에 한정된다.
- **추가 구현**: git-pr 괄호, 정책·명세·색인·README 동기화는 spec 전제와 Task 0의 승인 기록에 근거한다. 새 CLI 옵션·외부 API·퍼블리싱 관리 기능은 없다.
- **감사 변경 범위**: 1차 리포트를 보존하고 2차 리포트를 작성했다. 임시 입력과 Git 실험은 임시 디렉토리에서 수행했다.

### 도메인/계약/ADR 정합성

- 관련 index를 먼저 읽고 SSoT 정책, ai-workspace 명세, init/update 흐름, ADR 0001·0002·0008·0019를 대조했다. 외부 API·설치 경로 계약을 바꾸는 변경은 없다.
- 스킬별 폴백 복제·doc 참조 분리는 ADR 0002와 일치하고, shared 규칙과 repo 사본은 ADR 0008의 배포 방식과 일치한다.
- ADR 0019의 Task별 테스트 기준에서 Task 3·4의 공백이 남아 있다(F-3, F-2 잔여). spec이 명시한 테스트 실행 조건은 실제 통과했으므로 이 발견만으로 1단계 판정을 낮추지 않는다.
- 변경된 색인 행·ai-workspace 상세 흐름은 실제 구현과 일치한다. index의 과거 source_hash는 부분 갱신이라는 명시적 결정에 따라 유지됐으며 이번 감사의 갱신 누락으로 보고하지 않는다.

## 2단계: 비판적 검증 (Critical Review)

### 발견 사항

| # | 위험도 | 영향 | 발생확률 | 카테고리 | 계보 | 설명 | 관련 파일 |
|---|--------|------|----------|----------|------|------|-----------|
| F-3 | 🟡 중간(MEDIUM) | 기능 저하 | 통상 사용 | 테스트 | F-2 잔여 | Task 3·4의 변경 동작별 테스트 파일·Task 테스트 실행 기준이 여전히 없다 | plan:166,198; context-harvest/SKILL.md:42; code-map/references/doc.md:46 |

### 상세 분석

#### F-3: Task 3·4의 동작 변경을 검증하는 Task별 테스트가 남아 있지 않다

- **위험도**: 🟡 중간(MEDIUM)
- **영향 축**: 기능 저하
- **발생확률 축**: 통상 사용
- **카테고리**: 테스트
- **관점**: 누락된 검증
- **계보**: F-2 잔여. Task 1의 해소분은 제외한다.
- **권장 조치**: Task 3·4의 입력·기대 결과·검증 범위를 남기고 각 Task의 완료 기준에 연결한다. 자동화 가능한 구조 검증과 QD/ND 의미 검증의 담당 범위를 구분하며, 예외 수용을 원하면 `--response`에서 잔여 공백으로 명시해 판단한다.
- **기본 처리**: `--response` 승인 게이트에서 사용자 판단
- **완료 기준**:
  - [ ] Task 3: doc/dev·선언 부재, `publish` 아래 자료 제외, 선언 없는 퍼블리싱 사본 제외와 비파생 외부 자료 허용, 근거 출처 섹션 생성·제거에 대한 고정 입력·기대 결과를 테스트 산출물에 기록하고 Task 기준에 연결한다.
  - [ ] Task 4: build 범위·교차 참조, 동일 루트 sync, 루트 변경 시 rebuild/check 판정, 삭제·이름 변경·Why 보존의 고정 입력·기대 결과를 테스트 산출물에 기록하고 Task 기준에 연결한다.
  - [ ] 자동 검증은 정상·반례 실행과 변경 원복 시 실패를 확인한다. 의미 판단은 QD/ND로 명시하고 수행 결과 또는 미검증 상태를 남긴다. 제품용 헬퍼 신설은 전제하지 않는다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- plan:166·198은 테스트 파일을 만들지 않는 이유로 실행 코드 부재와 spec grep 중복을 든다. `rg --files context-harvest code-map`에서도 SKILL.md·references·templates만 있고 테스트 파일은 없다.
- Task 3은 무엇을 수집·제외할지와 산출물 섹션을 바꾸고 Task 4는 build/sync/check의 대상·분기·태그 보존을 새로 정의한다. 안내도 설명 동기화와 달리 실행 동작을 바꾸므로, 적용 중인 issue-audit 관점 5 및 ADR 0019의 Task별 검증 대상이다.
- ADR 0001은 헬퍼 도입 시 테스트 배치를 정하는 조건절이지만, ADR 0019와 이번 감사 관점 5는 적용 대상을 `scripts/` 보유 여부로 제한하지 않는다. spec 인수 검증과 구현 관점 테스트도 구분한다.
- 현재 spec 15개·plan 7개 명령은 모두 통과했다. 다만 문구·구조 검사 통과만으로 수집·색인 절차의 입력별 산출물 회귀가 검증되지는 않으며, 추가된 rename 명령도 키워드 존재 검사다.
- Task 1은 5개 케이스 추가와 템플릿 원복 실패를 확인해 닫았다. Task 3·4의 사유 기록은 검토 이력으로 인정하지만 완료 기준을 구현한 증거로 보지 않는다. 원장에 수용된 동일 항목도 없어 기등재 참조로 억제할 수 없다.
- 현재 기능이 실패한다는 새 반례를 주장하지 않는다. 정상 개발·검증 경로에서 회귀 검출 품질이 떨어지는 잔여 공백이라 영향은 기능 저하, 발생확률은 통상 사용이다. 스펙의 명시된 테스트 조건은 통과했으므로 이 발견으로 1단계 판정을 낮추지 않는다.

</details>

### 기등재 참조 항목

<details>
<summary>기등재 참조 표 펼치기</summary>

| 원장 항목 | 상태 | 대조한 발견 내용 | 재검토 조건 충족 | 처리 |
|-----------|------|------------------|------------------|------|
| K-0006 | 수용 | code-map 정합성 점검의 결정적 헬퍼 부재 | 미충족. local/global 점검 표 무변경이며 이번 감사에서 code-map check 모드를 실행하지 않음 | 기등재 K-0006 참조. 위험도 집계 제외 |

- F-3은 Task별 테스트 공백이다. K-0006의 제품용 check 헬퍼 부재와는 별개이며, 해당 헬퍼를 도입해야 한다고 요구하지 않는다.
- 원장 index의 active·archive 항목을 대조했으며, 그 밖에 같은 결함을 가리키는 항목은 없다.

</details>

### 이전 발견 추적

<details>
<summary>이전 발견 추적 표 펼치기</summary>

| 이전 발견 | 완료 기준 항목 | 판정 (닫힘/잔여) | 근거 |
|-----------|----------------|------------------|------|
| F-1 | rename 입력에 이전·새 경로 제공 | 닫힘 | doc.md:64의 `--name-status -M`; 임시 Git 저장소에서 R100 세 쌍 확인 |
| F-1 | 내부 rename의 옛 행 0·새 행 1·수동 Why 보존 | 닫힘 | doc.md:74가 이전 후 삭제 순서를 명시. 감사인이 절차를 fixture에 적용해 경로·태그 보존 확인 |
| F-1 | 루트 밖 이동 제거·안 이동 추가·반영 후 메타데이터 갱신 | 닫힘 | doc.md:66,75~76. 외부 이동 행 제거·유입 행 추가 뒤 source_hash 갱신 확인 |
| F-2 | Task 1 정상·반례 실행 및 doc 템플릿 원복 실패 | 닫힘 | plan:110 명령 통과. doc 고유 행 정상 1·반례 4가 실행되며 `23c92bb` 템플릿 사본에서는 러너 실패 |
| F-2 | Task 3·4 테스트 파일·변경별 기대 결과·Task 기준 연결 | 잔여 → F-3 | 미작성 사유만 추가. 대응 테스트 파일·Task 테스트 0 실패 기준 없음 |
| F-2 | 의미 검증 분리·수행과 자동 검증 원복 반례: Task 1·QD 서술 대조 | 닫힘 | Task 1 원복 검증 통과, 의미 검증 QD/ND 분리와 QD 대조 확인 |
| F-2 | 의미 검증 분리·수행과 자동 검증 원복 반례: Task 3·4 테스트·ND 수행 | 잔여 → F-3 | 지속 가능한 테스트와 사람 ND 수행 증거는 없음 |

- F-2의 세 번째 완료 기준은 Task 1·QD와 Task 3·4의 잔여분을 나누어 추적하며 발견 건수는 한 건으로 센다.
- F-1 fixture는 감사인이 수정된 자연어 절차를 따라 수행한 제한된 점검이다. 배포된 자동 sync 함수나 사람의 실사용 ND를 실행한 것으로 해석하지 않는다. 원래 결함이었던 입력 누락은 해소됐고, 사람이 확인할 추가 ND는 미검증 상태다.
- 번호 헬퍼에 보존 전 1차 최종 리포트 전체를 넘겨 `3`을 받았다. 이번 F-3은 F-2의 잔여로 기록하며 계획 감사 번호는 별도 축이다.

</details>

### 검증 실행 기록

<details>
<summary>실행 범위와 판정 근거</summary>

- spec Bash 블록 15개와 일반 Task 추가 Bash 블록 7개를 현재 작업 트리에서 실행했다. Markdown 공통 들여쓰기만 제거했고 모두 stdout·stderr 0건·exit 0이었다. 출력 기반 명령이 있어 종료 코드와 위반 출력을 함께 확인했다.
- 공통 명령으로 모든 `*/tests/run-tests.sh`를 실행했다. `git diff --check main`도 통과했다. Task N의 summary 기록 게이트는 사용자 기록 전이라 기능 검증 대상에서 제외했다.
- QD: R1 8곳의 선언 위치·허용 값·폴백, R11 정책 정합, Task 3 분기 서술, 보정 후 Task 4 절차 자기완결성을 대조했다. ND: spec R7 수집·R9 build 두 건과 plan의 추가 rename 실사용 확인은 사람 증거가 없어 통과로 올리지 않았다.
- rename fixture의 실제 Git 출력은 `R100 outside/in.md docs/in.md`, `R100 docs/old.md docs/new.md`, `R100 docs/out.md outside/out.md`다. 1-2 절차 적용 결과 새 내부 문서 2행만 남고, `docs/new.md`의 수동 `[WHY-NEEDED]` 설명이 보존됐다. source_hash는 행 반영 후 갱신했다.
- 명령별 종료 코드·출력 기록: `/var/folders/22/lwf9n0h57sd2fp8ycxnj5pb80000gn/T/issue-0114-audit2-hdohmkex/results.json`. rename 점검 산출물: 같은 임시 루트의 `issue-0114-rename-audit-37fnt1um/.ai/60_codebase/index.md`.
- 현재 CODEX_THREAD_ID와 일치하는 `rollout-2026-10-23T11-55-10-01a166af-0d35-7e13-ab49-02d31fd952ba.jsonl`의 동일 turn_context에서 `model=gpt-6-astra`, `effort=high`를 읽었다. 구현 Task 0~6의 벤더는 모두 Anthropic이며 감사 벤더 OpenAI와 다르다.
- 설치된 issue-audit 헬퍼로 PASS 28개·N/A 2개의 적합성, MEDIUM 1개의 위험도 상태, 두 상태의 종합 판정을 산출했다. 원장·plan·summary·구현 파일은 변경하지 않았다.

</details>
