# Issue #60 실행계획 — 스킬 산출물 접기(`<details>`) 적용 지점 명시

> 스펙: [issue-0060-spec.md](./issue-0060-spec.md)

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
  → 발견 6건을 spec `## 전제 (Assumptions)`에 반영 완료 (검증 앵커 규칙, SYNCED 파일 취급, 버린 대안 등).

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> **작성 원칙**: 구현자에게 이 문서 외 컨텍스트가 없다고 가정하고, Task별 완료 기준을 결정적으로 씁니다.

### Task 0 (고정): 구현 시작 게이트 — 전제·모호점 확인

- [x] 완료
- **목표**: 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 코드 작성 전에 걷어낸다.
- **작업 내용**:
  1. spec/plan을 읽고, 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 나열한다.
  2. 항목이 있으면 **코드를 쓰기 전에 사용자에게 질의**하고, 답변을 spec `## 전제 (Assumptions)` 섹션에 반영한 뒤 구현을 시작한다.
  3. 항목이 없으면 summary Task 0의 `수행 내용 요약`에 `전제 누락 없음` 한 줄을 기록하고 진행한다.
- **완료 기준**:
  - [ND] 나열한 항목이 전부 spec `## 전제 (Assumptions)`에 반영되어 미해소 0건이거나, summary Task 0에 `전제 누락 없음`이 기록된다  (검증: 사람 리뷰)  ← 강등 사유: 전제·모호점을 빠짐없이 나열했는지는 의미 판단이라 명령으로 환원 불가

---

### Task 1: SKILL.md 8종에 산출물 접기 기준 고정 블록 추가

- [x] 완료
- **목표**: 각 스킬이 `.ai/` 문서 없이 단독으로도 접기 기준을 알 수 있게 한다 (스킬 독립성).
- **작업 내용**:
  1. 접기 기준 고정 블록을 확정한다 — 헤더 `## 산출물 접기 기준`(h2), 본문은 `writing-principles.md` 접기 규칙 요약 리스트 2항목: 접기 가능(근거·대안 비교·상세 절차·코드 예시·참고자료), 접기 금지(결정사항·리스크·액션 아이템). 서술에 `<details>`는 언급하되 summary 태그 단어는 쓰지 않는다 (spec 전제 참조 — 검증 앵커 보호).
  2. 대상 8종(git-pr, git-qa, issue-work, issue-audit, git-review, git-review-context, context-save, context-harvest)의 SKILL.md에 동일 블록을 추가한다. 위치는 산출물 작성 절차·출력 형식 섹션 근처로 하되 스킬별 문맥에 맞게 배치한다.
- **완료 기준**:
  - [D] 8종 SKILL.md 각각에 `## 산출물 접기 기준` 헤더 행이 정확히 1개  (검증: repo 루트에서 `n=$(for f in git-pr git-qa issue-work issue-audit git-review git-review-context context-save context-harvest; do grep -c '^## 산출물 접기 기준$' "$f/SKILL.md"; done | grep -c '^1$'); [ "$n" -eq 8 ] && echo PASS` 출력 `PASS`. 0개(누락)·2개 이상(중복) 모두 실패로 센다)
  - [QD] 블록 문구가 `writing-principles.md` 접기 규칙과 불일치 없음  (검증: 교차모델 audit 대조)  ← 강등 사유: 의미 동치 비교는 명령으로 환원 불가

---

### Task 2: 산출물 템플릿 5종에 접기 구조 반영

- [x] 완료
- **목표**: 템플릿 기반 산출물이 생성 시점부터 접힘 구조를 갖게 한다 (결정적 적용).
- **작업 내용**:
  1. `issue-audit/templates/issue-audit-report-template.md` — `### 상세 분석`(발견별 근거·설명)을 `<details>`로 감싼다. 발견 사항 표·종합 의견은 본문 유지 (리스크·결정).
  2. `context-save/templates/context-note-template.md` — `## 배경 (Why)`·`## 논의 요약`·`## 참조`를 접는다. `## 결정사항`·`## 미결 / 열린 질문`·`## 다음 액션`은 본문 유지.
  3. `context-harvest/templates/50_adr-template.md` — `## 근거`·`## 대안`·`## 원본 출처`를 접는다. `## 결정`은 본문 유지.
  4. `context-harvest/templates/30_contract-template.md`·`40_domain-template.md` — `## 원본 출처`를 접는다.
  5. issue-work 템플릿 4종(spec·plan·summary·workflow)은 접기 가능 유형 존재 여부를 판정한다 — 결정·액션·검증 앵커 중심 문서라 적용 지점이 없으면 summary Task 2에 `issue-work 템플릿 해당 없음`과 판정 근거를 기록한다. 적용하는 경우에도 spec 전제의 앵커 행(`^### Task ` 등) 형식은 바꾸지 않는다.
- **완료 기준**:
  - [D] 템플릿 5개 파일 전부에 `<summary>` 태그 존재  (검증: repo 루트에서 `grep -l '<summary>' issue-audit/templates/issue-audit-report-template.md context-save/templates/context-note-template.md context-harvest/templates/30_contract-template.md context-harvest/templates/40_domain-template.md context-harvest/templates/50_adr-template.md | wc -l` 출력 `5`)
  - [D] issue-work plan·summary 템플릿의 기존 검증 앵커 행 구조 유지  (검증: repo 루트에서 `grep -cE '^### Task ' issue-work/templates/issue-plan-template.md` = 4, `grep -cE '^- \*\*결과\*\*:|^- \*\*수행 모델\*\*:' issue-work/templates/issue-summary-template.md` = 7 — 값이 현행(HEAD)과 동일. plan 작성 시 "≥ 8"로 오기했던 것을 Task 2 수행 중 HEAD 대조 실측값으로 보정)
  - [QD] 접기 금지 유형(결정사항·리스크·액션 아이템)이 접히지 않음  (검증: 교차모델 audit 채점)  ← 강등 사유: 섹션 의미 분류는 명령으로 환원 불가

---

### Task 3: SKILL.md 내 출력 형식 5종에 접기 구조 반영

- [x] 완료
- **목표**: 템플릿 파일이 없는 산출물(SKILL.md 본문에 형식 정의)도 접힘 구조로 작성되게 한다.
- **작업 내용**:
  1. `git-pr/SKILL.md` — PR 메시지 구조에서 이슈별 비즈니스/테크 관점 상세를 `<details>`로 감싼다. PR 헤더·이슈 목록은 본문 유지.
  2. `git-qa/SKILL.md` — 출력 템플릿에서 이슈별 변경 요약·영향 범위를 접는다. 배포 대상 요약 표·테스트 체크리스트(액션)는 본문 유지.
  3. `git-review/SKILL.md` — 결과 기록(`temp_review_result.md`) 형식에 접기 구조를 명시한다 — 상세 분석·근거는 접고, 리뷰 포인트·결론은 본문 유지. 형식 코드블록이 없으면 접기 지점을 포함한 형식을 추가한다.
  4. `git-review-context/SKILL.md` — 결과 기록 형식에서 호출 흐름 상세를 접는다. 변경 요약·리뷰 포인트는 본문 유지.
  5. `issue-work/SKILL.md` — `--clear` 3단계 이슈 댓글 요약에 접기 구조를 명시한다 — 요약은 본문, Task별 상세는 접기.
- **완료 기준**:
  - [D] 5개 SKILL.md 전부에 `<summary>` 태그 존재  (검증: repo 루트에서 `grep -l '<summary>' git-pr/SKILL.md git-qa/SKILL.md git-review/SKILL.md git-review-context/SKILL.md issue-work/SKILL.md | wc -l` 출력 `5`. Task 1의 기준 블록에는 summary 태그 단어를 쓰지 않으므로 이 명령은 출력 형식 반영만 잡는다)
  - [QD] 접기 금지 유형(결정사항·리스크·액션 아이템)이 접히지 않음  (검증: 교차모델 audit 채점)  ← 강등 사유: 위와 같음

---

### Task 4: SKILL.md 8종에 writing-principles 참조·우선순위 연결

- [x] 완료
- **목표**: `.ai/` 구조가 있는 repo에서 내장 접기 기준을 넘어 전체 작성 원칙과 repo 고유 확장(`writing-principles-local.md`)이 발동하게 한다. 내장 블록은 파일 부재 시 기본값으로 유지한다 (스킬 독립성 보존 — 배제된 참조 전용 방식과의 차이, 2026-07-30 범위 확장).
- **작업 내용**:
  1. 8종 SKILL.md의 "참조 문서 > 스킬 고유 추가 참조"에 `.ai/10_rules/writing-principles.md`·`.ai/10_rules/writing-principles-local.md` 조건부 참조 1행을 추가한다 — 1단계 직접 참조로 2단계 간접 참조 단절을 보완한다 (spec `배경 근거` 참조).
  2. 8종 내장 `## 산출물 접기 기준` 블록 끝에 우선순위 문구를 추가한다 — local > writing-principles.md > 내장 기준. 앵커 문구 `이 블록은 파일이 없을 때의 기본값`을 포함하고, 블록 서술에 태그 검증 앵커 단어는 계속 쓰지 않는다 (spec 전제 참조).
- **완료 기준**:
  - [D] 8종 SKILL.md 전부에 `writing-principles-local.md` 참조 존재  (검증: repo 루트에서 `n=$(for f in git-pr git-qa issue-work issue-audit git-review git-review-context context-save context-harvest; do grep -l 'writing-principles-local\.md' "$f/SKILL.md"; done | wc -l); [ "$n" -eq 8 ] && echo PASS` 출력 `PASS`)
  - [D] 8종 접기 기준 블록에 우선순위 폴백 앵커 문구 존재  (검증: repo 루트에서 `grep -l '이 블록은 파일이 없을 때의 기본값' git-pr/SKILL.md git-qa/SKILL.md issue-work/SKILL.md issue-audit/SKILL.md git-review/SKILL.md git-review-context/SKILL.md context-save/SKILL.md context-harvest/SKILL.md | wc -l` 출력 `8`)
  - [QD] 참조·우선순위 서술이 `writing-principles.md`의 우선순위 선언(local 우선)과 불일치 없음  (검증: 교차모델 audit 대조)  ← 강등 사유: 의미 동치 비교는 명령으로 환원 불가

---

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

- [x] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **실행 주체**: **사용자가 직접** 수행한다. 구현 AI는 이 Task를 **자동으로 닫지 않으며**, `issue-audit`를 자동 실행하지도 않는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 전부 재실행해 통과를 확인한다.
  2. 구현을 수행한 모델과 **다른 벤더 모델**(최소 동급 이상 역량)로 사용자가 직접 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 사용자가 audit 결과(지적 사항·감사 모델)를 summary에 반영·기록한다. 발견사항 보정은 issue-work `--response`로 검토한다 — **피드백 먼저, 항목별 승인 후에만** 앞 Task를 보정하며, 리포트를 받자마자 자동 보정하지 않는다.
- **완료 기준**:
  - [D] spec `완료의 정의`의 `[D]` 항목 검증 명령 전부 통과  (검증: 해당 명령 재실행)
  <!-- 아래 5개 항목은 순서가 아니라 의존 관계다: 선행 조건(Task 집합 일치 → 결과 확정 → 수행 모델 채움)이 서지 않으면 교차 벤더 비교가 공집합이 되어 통과처럼 보인다. -->
  - [D] summary의 Task 헤더 집합이 plan과 일치 — 블록 전체 누락·Task N 누락·빈 summary·두 경로 오기 차단  (검증: repo 루트에서 `P=.ai/90_issues/archive/issue-0060/issue-0060-plan.md; S=.ai/90_issues/archive/issue-0060/issue-0060-summary.md; { grep -qE '^### Task ' "$P" && grep -qE '^### Task ' "$S" && diff <(grep -E '^### Task ' "$P") <(grep -E '^### Task ' "$S") || echo '위반: 입력 접근 실패 또는 Task 집합 불일치'; }` 출력 0건. 프로세스 치환 안의 `grep` 실패는 `diff` 종료 상태로 전파되지 않아 두 경로가 모두 잘못되면 빈 입력끼리 비교해 통과하므로, 선행 `grep -q`로 두 파일의 Task 헤더 실재를 먼저 확인하고 실패를 stdout 위반 행으로 환원한다) — 아래 두 게이트는 summary에 실재하는 블록의 행만 검사하므로, 블록 자체가 없으면 검사 대상이 사라져 그대로 통과한다
  - [D] 이 검증 전에 Task 0 및 모든 일반 실행 Task의 summary `결과`가 완료·부분 완료·스킵 중 하나로 확정 — Task N 제외 블록마다 유효 `결과` 행 정확히 1개, 무효·중복 0건  (검증: repo 루트에서 `S=.ai/90_issues/archive/issue-0060/issue-0060-summary.md; awk '/^### Task /{if(o&&!n&&v!=1)b++; o=1; v=0; n=($0~/^### Task N/)} o&&/^- \*\*결과\*\*:/{if($0~/^- \*\*결과\*\*: (완료|부분 완료|스킵)[[:space:]]*$/)v++; else if(!n)b++} END{if(o&&!n&&v!=1)b++; print b+0}' $S` 출력 0. 총개수 비교는 한 블록의 미확정을 다른 블록의 중복 행으로 상쇄해도 통과하므로 블록 단위로 센다) — 비워 두면 "완료·부분 완료면 `수행 모델` 값 필수" 조건이 발동하지 않아 아래 강화 조건이 공집합이 된다
  - [D] 완료·부분 완료 Task의 `수행 모델`이 비어 있지 않고 `-`도 아닌 행 정확히 1개(`-`는 미착수·스킵 전용)  (검증: repo 루트에서 `S=.ai/90_issues/archive/issue-0060/issue-0060-summary.md; awk '/^### Task /{if(o&&!n&&d&&(t!=1||m!=1))b++; o=1; d=0; t=0; m=0; n=($0~/^### Task N/)} o&&/^- \*\*결과\*\*: (완료|부분 완료)[[:space:]]*$/{d=1} o&&/^- \*\*수행 모델\*\*:/{t++; if($0~/^- \*\*수행 모델\*\*: [^-[:space:]]/)m++} END{if(o&&!n&&d&&(t!=1||m!=1))b++; print b+0}' $S` 출력 0. 리터럴 `-`만 거부하면 빈 값·행 누락·중복이 통과하므로 "없음"의 세 형태와 중복을 전부 실패로 센다) — 전부 `-`로 남기면 아래 교차 벤더 조건이 공집합이 되어 우회가 된다
  - [QD] summary `모델 기록` 표의 `구현 모델`·`audit 모델` 두 행이 "벤더, 모델명" 형식으로 채워지고 서로 다른 벤더  (검증: 교차모델 audit이 두 행 대조 채점)  ← 강등 사유: 벤더 토큰 추출이 자유 문자열 의미 대조라 명령으로 환원하면 표기 변형에 취약하다
  - [QD] 구현에 여러 벤더가 관여했으면 audit 모델의 벤더가 Task 0 및 일반 실행 Task의 비어 있지 않은 모든 `수행 모델` 값에 나열된 벤더 전부와도 상이  (검증: 교차모델 audit이 `수행 모델` 행 전수 추출 후 audit 벤더와 대조 채점)  ← 강등 사유: 위와 같음. 표의 대표값 비교만으로는 audit 벤더의 구현 참여를 놓치고, 한 Task를 여러 모델이 수행했으면 그 값에 나열된 벤더를 모두 비교 대상에 넣는다
  - [ND] audit이 칭찬이 아니라 허점 탐색 방향으로 수행됨  (검증: 사용자가 audit 리포트 내용으로 판단)  ← 강등 사유: 감사 방향성은 리포트 서술의 의미 판단이라 명령으로 환원 불가
