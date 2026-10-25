# Issue #121 감사 리포트 ADR 처리 규칙 도입

> 감사 일시: 2026-10-25 (Asia/Seoul)
> 감사 모델: OpenAI, GPT-6 (gpt-6-astra)
> 감사 effort: high
> 감사 회차: 1차 (이전 최종 감사 리포트 없음)
> 감사 대상 브랜치: issue-0121, HEAD `6bf0d50`
> 비교 기준: main과의 분기점 `429337b`, 변경 파일 25개
> 스펙 출처: [spec](./issue-0121-spec.md), [plan](./issue-0121-plan.md), [summary](./issue-0121-summary.md), [GitHub Issue #121](https://github.com/scroogy-dev/scroogy-agent-skills/issues/121)

## 종합 의견

🟢 적합(PASS)

<details>
<summary>종합 의견 펼치기</summary>

- 요구사항 12개와 DoD 25개를 충족하며, 구현 모델(Anthropic)과 감사 모델(OpenAI)의 벤더가 다르다.
- F-1은 현재 동작의 결함이 아닌 재수집 기준 시각의 회귀 검증 누락이다. 기본 처리는 원장 이관이며 보정 루프를 다시 열지 않는다.
- K-0001은 fixture 도입과 이번 모의 실행으로 원인이 사라졌다. 종결과 링크 갱신은 spec이 정한 이슈 완료·PR 번호 확정 시점에 수행한다.

</details>

## 요약

- 1단계 적합성: 🟢 충족(PASS) · 충족(PASS) 37건 / 미충족(FAIL) 0건 / 부분 충족(PARTIAL) 0건 / 판정 불가(N/A) 0건
- 2단계 위험도: 🟢 통과(PASS) · 높음(HIGH) 0건 / 중간(MEDIUM) 0건 / 낮음(LOW) 1건 / 정보(INFO) 0건
- 기등재 참조: 1건 (K-0001, 위험도·카테고리 집계 제외)
- 이전 발견: 해당 없음 (최종 감사 초회)

| 카테고리 | 건수 |
|----------|------|
| 기능 | 0 |
| 아키텍처 | 0 |
| 버그 | 0 |
| 보안 | 0 |
| 코드품질 | 0 |
| 성능 | 0 |
| 테스트 | 낮음(LOW) 1 |

## 1단계: 적합성 검증 (Compliance Check)

### 요구사항 대조

| # | 요구사항 | 판정 | 근거 |
|---|----------|------|------|
| R1 | 수명 주기 경우 4종 | 🟢 충족(PASS) | ADR index 템플릿·repo 사본의 동일 섹션, GitHub 방향 A의 네 행과 의미 일치 |
| R2 | 일부 변경 경계·읽기 규칙·superseded 설명 | 🟢 충족(PASS) | 두 index의 경계·읽기 라벨과 파일 목록 설명 |
| R3 | 상태 줄·기본값·기존 ADR 보존 | 🟢 충족(PASS) | 상태 형식·세 값·무상태 유효 정의, 기존 0001~0021 무변경 |
| R4 | 이동 시 링크·index 갱신 | 🟢 충족(PASS) | active 경로, 같은 디렉토리 두 링크 형식, 이동 파일의 나가는 링크, 깊이 재계산·검색 확인 명시 |
| R5 | update-3 상태 줄 판정 | 🟢 충족(PASS) | ai-workspace/SKILL.md:219, 대체·폐기와 유효·상태 없음 분기 |
| R6 | ADR 템플릿 상태 줄 | 🟢 충족(PASS) | context-harvest/templates/50_adr-template.md:10, 제목 다음 첫 비어 있지 않은 행 |
| R7 | 증분 수집의 상태 유지·수명 주기 처리 | 🟢 충족(PASS) | context-harvest/SKILL.md:183~184, 섹션 부재 보류·재수집 모의 실행도 일치 |
| R8 | 새 ADR | 🟢 충족(PASS) | ADR 0022의 결정·근거·대안·출처, index 등록 |
| R9 | context-loading 제약 예외 | 🟢 충족(PASS) | superseded 제외 명시, shared 템플릿·repo 사본 바이트 일치 |
| R10 | 명세·호출 흐름 반영 | 🟢 충족(PASS) | specs/ai-workspace.md의 update 구조 정합, update-call-flow.md 이동 행 |
| R11 | update-3 회귀 fixture | 🟢 충족(PASS) | 디렉토리 5행·루트 상주·legacy 포함, 4쌍·19개 파일 모의 분류 일치 |
| R12 | 코드 색인 ADR 링크 | 🟢 충족(PASS) | ai-workspace·context-harvest 두 행에서 ADR 0022로 연결 |

### 완료의 정의(DoD) 대조

검증 ID는 각 R 그룹의 체크박스를 위에서부터 센다. D01~D19는 spec의 bash 블록 순서다.

| # | DoD 항목 | 판정 | 근거 |
|---|----------|------|------|
| R1-1 | 수명 주기 섹션 1개·두 사본 동일 | 🟢 충족(PASS) | D01 무출력 |
| R1-2 | 경우 4행·위치 2:2 | 🟢 충족(PASS) | D02 무출력 |
| R1-3 | 방향 A와 처리 의미 일치 [QD] | 🟢 충족(PASS) | 이슈 본문을 조회해 네 행 대조 |
| R2-1 | 경계·읽기 라벨과 필수 문구 | 🟢 충족(PASS) | D03 무출력 |
| R2-2 | superseded 설명 갱신 | 🟢 충족(PASS) | D04 무출력, 옛 설명 검색 0건 |
| R3-1 | 상태 줄 형식·세 값·기본값 | 🟢 충족(PASS) | D05 무출력 |
| R3-2 | 기존 ADR 21건 무변경 | 🟢 충족(PASS) | D06 무출력, main diff 0건·active 21건 |
| R4-1 | 들어오는 링크 갱신 라벨·범위 | 🟢 충족(PASS) | D07 무출력, 원장 전용 표기 0건 |
| R4-2 | index 행 이동 라벨 | 🟢 충족(PASS) | D08 무출력 |
| R4-3 | #120 정의 문장과 의미 대응 [QD] | 🟢 충족(PASS) | issue-work/SKILL.md:119 대조, 대상·확인 수단·문체 외 처리 동일 |
| R5-1 | 상태 판정 행·옛 키워드 제거 | 🟢 충족(PASS) | D09 무출력, deprecated·replaced 0건 |
| R6-1 | 템플릿 상태 줄 개수·위치·값 | 🟢 충족(PASS) | D10 무출력 |
| R6-2 | frontmatter 4키 유지 | 🟢 충족(PASS) | D11 무출력 |
| R7-1 | 상태 유지·수명 주기·보류 문구 | 🟢 충족(PASS) | D12 무출력 |
| R7-2 | 증분 흐름 정합 [QD] | 🟢 충족(PASS) | 아래 첫 실행·재실행 시나리오, 일반 갱신보다 구체적인 보류 규칙 적용 |
| R8-1 | ADR 0022 파일·상태·헤더·index | 🟢 충족(PASS) | D13 무출력 |
| R8-2 | 결정 섹션의 요구 결정 수록 [QD] | 🟢 충족(PASS) | R1~R5·R7·R9·R11, 파일명 검색·헬퍼 보류 포함 |
| R9-1 | context-loading 사본 일치·예외 문구 | 🟢 충족(PASS) | D14 무출력 |
| R10-1 | 명세·흐름 필수 문구 | 🟢 충족(PASS) | D15 무출력 |
| R10-2 | 명세·흐름과 구현 정합 [QD] | 🟢 충족(PASS) | 상태 줄 분기 일치, source_hash d368084가 마지막 ai-workspace 소스 커밋 |
| R11-1 | fixture 대상 행·파일 쌍 | 🟢 충족(PASS) | D16 무출력 |
| R11-2 | fixture 모의 실행 [QD] | 🟢 충족(PASS) | 아래 4개 케이스·19개 파일 전부 expected와 일치 |
| R12-1 | 두 색인 행의 ADR 0022 링크 | 🟢 충족(PASS) | D17 무출력 |
| 공통-1 | 전체 스킬 테스트 | 🟢 충족(PASS) | D18: 러너 12개 실행, 실패 출력 0건 |
| 공통-2 | 끊긴 원장 링크 | 🟢 충족(PASS) | D19: check-ledger-links.sh .ai 무출력·exit 0 |

<details>
<summary>명령 실행·Task별 검증 근거 펼치기</summary>

- spec bash 블록 19개를 그대로 추출해 repo 루트에서 각각 `bash -c`로 실행했다. 모두 stdout·stderr가 비었다.
- D04·D07·D09의 셸 종료 코드는 1이다. 각각 마지막의 부재 검색 `grep`, `grep && echo`, `grep`이 일치 없음으로 끝난 결과다. spec은 이 세 명령도 **출력 0건**을 통과 기준으로 정했으므로 그 계약에 따라 판정했다. 나머지 16개 블록은 exit 0이다.
- 공통 전체 테스트 명령은 개별 러너 실패를 `위반: <경로> 실패`로 출력한다. 12개 러너가 전부 실행됐고 이 출력은 없었다.
- plan 일반 Task의 독립 bash 블록 6개도 전부 실행했다. Task 1·2·3·4·5의 테스트 케이스 하한 검사 5개와 Task 7의 원장 링크 검사 1개 모두 무출력·exit 0이다.
- 기능을 바꾸는 Task 1~5 모두 Task별 테스트 `[D]`가 있다. Task 6·7은 결정 기록·안내 문서 정합 작업이다. Task 4의 재수집 시각 규칙 검증 누락은 F-1로 별도 기록했다.
- Task N의 세 결정적 선행 게이트도 실행했다. Task 헤더 집합은 일치하며, 일반 Task 결과·수행 모델 누락 건수는 각각 0이다. Task 0~7의 수행 벤더는 모두 Anthropic이다.
- `git diff --check main` 통과. 기존 최종 감사 리포트는 없으며 `next-finding-number.sh`가 1을 반환했다. 계획 감사 F-1과 최종 감사 F-1의 번호 축은 별개다.
- 모델·effort는 현재 세션 rollout의 마지막 `turn_context`에서 `gpt-6-astra`, `high`로 확인했다.

</details>

<details>
<summary>update-3 모의 실행 [QD] 결과 펼치기</summary>

구현에 참여하지 않은 이번 세션에서 input의 파일 내용에 `ai-workspace/SKILL.md`의 기존 파일 정리 규칙을 적용했다. 아래 판정을 expected의 이동 위치와 대조했으며 19/19 일치한다. 실제 사용자 파일 이동은 수행하지 않았다.

| 케이스 | 파일 | 판정 |
|--------|------|------|
| domain | 40_domain/index.md | 루트 유지 |
| domain | 40_domain/glossary.md | 루트 유지 |
| domain | 40_domain/refund-flow.md | specs/ |
| domain | 40_domain/data-retention.md | policies/local/ |
| domain | 40_domain/meeting-notes-2026-03.md | legacy/ |
| domain | 40_domain/policies/password-rule.md | policies/local/ |
| adr | 50_adr/index.md | 루트 유지 |
| adr | 50_adr/0001-session-store-memory.md | superseded/ |
| adr | 50_adr/0002-nightly-batch.md | superseded/ |
| adr | 50_adr/0003-session-store-redis.md | active/ |
| adr | 50_adr/0004-review-cycle.md | active/ |
| ledger | 70_ledger/index.md | 루트 유지 |
| ledger | 70_ledger/ledger-entry-template.md | 루트 유지 |
| ledger | 70_ledger/K-0001-login-retry-absent.md | archive/ |
| ledger | 70_ledger/K-0002-report-timeout.md | archive/ |
| ledger | 70_ledger/K-0003-cache-warmup.md | active/ |
| issues | 90_issues/issue-0003-plan.md | archive/ |
| issues | 90_issues/issue-0003-summary.md | archive/ |
| issues | 90_issues/issue-0005-plan.md | active/ |

- 명세·정책·회의 메모를 내용으로 구별했고, policies 루트의 정책 파일은 local로 분류했다.
- 상태 줄 없는 ADR은 본문에 superseded가 있어도 active로 분류했다.
- 원장 템플릿은 상태 값 수용보다 루트 상주 제외 규칙을 먼저 적용했다. 완료 plan·완료 summary·미완료 plan도 각각 기대 위치와 일치했다.

</details>

<details>
<summary>context-harvest 모의 실행 [QD] 결과 펼치기</summary>

- 입력: 수명 주기 섹션 없는 index, 기존 ADR A(상태 유효, `last_harvested=2026-10-01`), 같은 소스의 전체 대체 결정(`updated_at=2026-10-20`, SSoT 반영 완료)을 둔다.
- 첫 실행: 3단계가 변경분을 선택한다. 5단계는 A의 내용·상태·시각·경로를 보존하고 새 ADR을 만들지 않는다. 6단계에 결정 변경 후보 1건을 보고한다.
- 다음 실행: A의 시각이 10월 1일로 남고 5단계 마지막 문장이 이 값을 기준으로 고정한다. 같은 후보가 다시 수집되어 동일하게 보류·보고된다.
- 같은 소스의 다른 문서 B가 10월 25일로 갱신되어도 보류 ADR A의 시각을 기준으로 하므로 후보가 누락되지 않는다. 이 문장을 잘못 고친 변형의 테스트 결과는 F-1에 기록했다.
- 수명 주기 섹션이 있는 경우: 일부 변경은 같은 ADR 수정·근거 기록, 전체 대체는 옛 상태·경로·링크·index 갱신과 새 ADR의 대체 대상 기록, 폐기는 상태·사유 기록 후 이동으로 연결된다. 상태 줄 없는 옛 ADR의 단순 갱신은 무상태를 유지해도 유효 기본값과 충돌하지 않는다.
- 이는 자연어 절차를 적용한 `[QD]` 검증이며 외부 서비스를 연결한 실제 수집 실행은 아니다.

</details>

### 경계 검증

- 기존 ADR 21건 재분류·상태 소급 기재, git-pr ADR 대조 행, issue-audit·git-review 대조 절차, 원장 링크 헬퍼는 바뀌지 않았다.
- 링크 검사 헬퍼 신설 없이 spec이 정한 파일명 검색을 규칙으로 두었다. 새 테스트·fixture·ADR·색인 변경은 포함 범위와 대응한다.
- K-0001 원장 상태와 기존 링크를 유지한 것은 spec의 이슈 완료 시 종결 전제에 따른다.

### 도메인/계약 정합성

- ADR 0001의 스킬별 테스트 배치·배포 제외, ADR 0002의 독립 설치·의도적 복제와 정합하다. 상태 값 처리의 세부 규칙은 이번 ADR 0022가 명시한다.
- ADR 0021의 들어오는 링크 정의와 대조했다. 두 종류의 같은 디렉토리 링크, 이동 파일의 나가는 링크, archive 제외, 깊이 재계산 범위가 보존됐다.
- ADR 0019의 Task별 테스트 배치는 충족한다. 변경 동작을 되돌렸을 때 검출해야 한다는 기준에는 F-1의 좁은 누락이 남지만, 이는 spec 요구사항·DoD의 현재 충족 판정을 낮추는 근거로 삼지 않았다.
- update-call-flow의 상태 줄 판정과 source_hash는 실제 소스와 일치한다. K-0001의 옛 설명은 아래 기등재 참조에 종결 시 갱신 대상으로 기록한다.
- 외부 연동 계약 변경은 없다. GitHub #121 본문은 `gh issue view 121 --repo scroogy-dev/scroogy-agent-skills --json title,body`로 읽어 방향 A·C와 대조했다.

## 2단계: 비판적 검증 (Critical Review)

### 발견 사항

| # | 위험도 | 영향 | 발생확률 | 카테고리 | 계보 | 설명 | 관련 파일 |
|---|--------|------|----------|----------|------|------|-----------|
| F-1 | 🟢 낮음(LOW) | 기능 저하 | 특수 조건·엣지 | 테스트 | 신규 | 보류 ADR의 재수집 기준 시각을 다른 문서의 시각으로 바꿔도 러너가 통과한다 | context-harvest/tests/run-tests.sh:184~187, context-harvest/SKILL.md:184 |

### 상세 분석

#### F-1: 보류 ADR의 재수집 기준 시각을 지키는 회귀 검증이 빠졌다

- **위험도**: 🟢 낮음(LOW)
- **영향 축**: 기능 저하. 현재 절차는 맞지만 이후 잘못 고쳤을 때 테스트의 회귀 검출력이 떨어진다.
- **발생확률 축**: 특수 조건·엣지. 재수집 문구를 개정하고, 같은 소스의 문서들이 서로 다른 수집 시각을 갖는 경우다.
- **카테고리**: 테스트
- **관점**: 누락된 검증
- **계보**: 신규 (계획 감사 F-1의 구현 결함 재발 판정과는 별개)
- **권장 조치**: 기본값은 원장 이관이다. 추후 보정하면 Task 4 테스트에서 보류 ADR 자신의 `last_harvested`를 쓰는 규칙과 다른 문서의 최신 시각을 쓰는 반례를 함께 고정한다.
- **기본 처리**: 원장(`.ai/70_ledger/`) 이관 — 수용 사유·재검토 조건 기재. 사용자가 명시 승격하지 않는 한 보정 루프에 넣지 않는다
- **완료 기준**:
  - [ ] Task 4 검증이 재수집 기준 시각 문장의 삭제와 다른 문서의 최신 시각으로 바꾼 반례를 실패로 판정한다.
  - [ ] 같은 소스에 보류 ADR A와 더 최근에 갱신한 문서 B를 둔 입력에서, A 이후·B 이전에 발생한 대체 후보를 다음 수집에서도 다시 판정하는 검증 근거를 남긴다.
  - [ ] 원본의 context-harvest 테스트가 통과하고 위 두 변형은 실패한다.

<details>
<summary>근거·재현 결과 펼치기</summary>

- `adr_violations`는 상태 유지·수명 주기 참조·이동 보류·내용과 시각 보존 문구 네 개만 검사한다(`context-harvest/tests/run-tests.sh:184~187`). `context-harvest/SKILL.md:184`의 마지막 재판정 문장은 검사하지 않는다.
- repo 소스는 보존하고 임시 디렉토리에 context-harvest 전체를 복사했다. SKILL.md 한 문장만 다음과 같이 바꿔 사본의 러너를 실행했다.

```text
원본: 다음 증분 수집에서 같은 소스는 이 ADR의 `last_harvested` 이후 변경분부터 다시 판정한다.
변형: 다음 증분 수집에서 같은 소스는 최신 문서의 `last_harvested` 이후 변경분부터 판정한다.
실행: bash <임시 사본>/context-harvest/tests/run-tests.sh
결과: passed: 32, failed: 0 / exit 0
```

- A의 시각이 10월 1일, 대체 후보가 10월 20일, B의 시각이 10월 25일이면 변형은 후보를 다음 증분 수집에서 제외한다. 현재 본문은 A를 기준으로 명시하므로 이 문제는 현재 구현에서 재현된 기능 결함이 아니다.
- plan Task 4의 `[QD]`는 첫 실행·다음 실행을 요구하지만 다른 문서의 더 최근 시각을 반례 입력으로 고정하지 않는다. 전체 테스트 통과와 단일 ADR 시나리오만으로는 이 변형을 검출하지 못한다.
- 새 ADR 생성 금지 문구를 바꾼 별도 탐색에서는 러너가 실패했다(30 통과·2 실패). 따라서 그 문구까지 검출 누락이라고 확대해 보고하지 않는다.
- spec R7의 현행 문장과 `[QD]` 결과는 충족한다. F-1은 issue-audit 관점 5와 ADR 0019의 변경 동작별 회귀 검증 기준으로 기록하며 1단계 판정을 낮추지 않는다.
- 적용 원장 항목과 같은 결함인 항목은 없다. K-0001은 update-3 fixture 부재로 대상과 원인이 다르다.

</details>

### 기등재 참조 항목

<details>
<summary>기등재 참조 표 펼치기</summary>

| 원장 항목 | 상태 | 대조한 발견 내용 | 재검토 조건 충족 | 처리 |
|-----------|------|------------------|------------------|------|
| [K-0001](../../../70_ledger/active/K-0001-update3-fixture-absent.md) | 수용 | update-3 fixture 부재 원인이 이번 4쌍 도입으로 사라짐. 19개 모의 판정 일치 | 충족(update-3 판정 변경), 이미 R11에 함께 해소로 반영 | 기등재 K-0001 참조. 신규 F 번호 없음. 이슈 완료·PR 번호 확정 시 종결·이관·재검토 이력·들어오는 링크 갱신 권고 |

</details>

- `update-call-flow.md`의 “회귀 fixture가 없다(수용)” 서술도 종결 시 갱신할 대상이다. 코드베이스 색인 갱신이 필요해 보입니다 (`/code-map`). spec이 이 갱신 시점을 이슈 완료 시로 정했으므로 신규 결함으로 집계하지 않는다.

### 이전 발견 추적

- 해당 없음. 보존된 최종 감사 리포트가 없어 최종 감사 번호는 F-1부터 시작한다.
- 별도 축인 계획 감사 1·2차 리포트는 참고했다. 계획 감사 F-1의 보류 범위·재수집 조건이 현재 SKILL.md에 구현됐고 위 `[QD]`로 확인됐다. 해당 계획 발견을 이번 최종 감사의 잔여로 다시 세지 않는다.
