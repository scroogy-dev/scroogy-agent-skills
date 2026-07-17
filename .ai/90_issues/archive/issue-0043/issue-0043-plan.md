# Issue #43 실행계획 issue-work: 모델 분리 운용 지원 — 설계 문서 점검 게이트 및 Task별 모델·보정 지표 기록

> 스펙: [issue-0043-spec.md](./issue-0043-spec.md)

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> 각 작업은 독립적으로 검증 가능해야 하며, **완료 기준은 자연어 대신 실행 명령 + 임계값**으로 적습니다.
> 명령으로 환원이 어려운 항목만 판정 주체(다른 AI / 사람)를 적고 강등 사유를 남깁니다.
> 마지막 고정 Task(교차모델 issue-audit)는 삭제하지 말고 그대로 둡니다.

### Task 1: 결정거리 4건 확정

- [x] 완료
- **목표**: 템플릿을 손대기 전에 이슈 본문의 결정거리 4건을 확정해 이후 Task의 파급 범위를 고정한다.
- **작업 내용**:
  1. `모델 기록` 표와 Task별 `수행 모델`의 관계를 결정한다 (대체 / 분리 / 병존). 참조 4곳의 연동 갱신 범위를 함께 산출한다.
  2. 구현 시작 게이트의 위치를 결정한다 (plan 고정 블록 / workflow 절차 / 둘 다 — #29 F-1 선례 검토).
  3. 설계 종료 게이트의 형태를 결정한다 (Tasks 앞 고정 블록 / Task 0 / 주석 지시문).
  4. 전제 섹션 위치를 결정한다 (spec 신설 `전제(Assumptions)` / 기존 `연관 문서` 확장).
  5. 결정과 근거를 summary에 기록하고 사용자 승인을 받는다.
- **완료 기준**: 결정 4건과 각 근거가 summary Task 1 블록에 기재되고, 사용자가 승인한다. (판정 주체: 사람) ← 강등 사유: 설계 선택지 간 우열은 명령으로 판정할 수 없다

---

### Task 2: spec 템플릿에 전제(Assumptions) 섹션 추가

- [x] 완료
- **목표**: 작성 모델의 암묵 전제(코드베이스 관례, 버전·환경 제약, 버린 대안과 그 이유)를 문서에 남길 자리를 만든다.
- **작업 내용**:
  1. Task 1에서 결정한 위치에 전제 섹션을 추가한다.
  2. 무엇을 적어야 하는지 주석 지시문으로 안내한다 (모델명 하드코딩 없이).
- **완료 기준**: `grep -c '^## 전제 (Assumptions)' issue-work/templates/issue-spec-template.md` = 1

---

### Task 3: plan 템플릿에 게이트 2건 추가

- [x] 완료
- **목표**: 설계 종료 게이트와 구현 시작 게이트를 고정 블록으로 넣어 신규 이슈부터 자동 적용되게 한다.
- **작업 내용**:
  1. 설계 종료 게이트를 Task 1에서 결정한 형태로 추가한다 — 점검 질문, 점검 대상, 발견 시 spec 전제 섹션에 반영.
  2. 구현 시작 게이트를 결정한 위치에 추가한다 — 전제·모호점 나열, 항목이 있으면 코드 작성 전 사용자 질의, 없으면 summary에 "전제 누락 없음" 기록.
  3. Task N 교차모델 audit 고정 블록은 그대로 둔다.
- **완료 기준**: `grep -cE '^## 설계 종료 게이트' issue-work/templates/issue-plan-template.md` = 1 이고 `grep -cE '^### Task 0 \(고정\): 구현 시작 게이트' issue-work/templates/issue-plan-template.md` = 1 이며 `grep -cE '^### Task N \(고정\): 교차모델 issue-audit' issue-work/templates/issue-plan-template.md` = 1

---

### Task 4: summary 템플릿에 Task별 지표 필드 추가·모델 기록 표 개편

- [x] 완료
- **목표**: Task별 수행 모델과 보정 지표를 grep으로 뽑을 수 있는 형식으로 기록한다.
- **작업 내용**:
  1. `Task별 수행 결과`의 각 Task 블록에 `수행 모델`·`audit 발견`·`보정 반영`·`재시도` 필드를 추가한다.
  2. Task 1 결정에 따라 `모델 기록` 표 구조를 개편한다.
  3. 주석 지시문의 모델명은 기록 필드의 예시 값으로만 남긴다.
- **완료 기준**: `awk '/^### Task /{th++; t="stray"; if($0~/^### Task 0 \(고정\):/) t=0; else if($0~/^### Task 1:/) t=1; else if($0~/^### Task 2:/) t=2; else if($0~/^### Task N \(고정\):/) t="N"; if(t!="stray") h[t]++} /^- \*\*(수행 모델|audit 발견|보정 반영|재시도)\*\*:/{split($0,a,/\*\*/); if(t=="stray"||t==""||t=="N") stray++; else c[t"|"a[2]]++} /^- \*\*(audit 발견|보정 반영|재시도)\*\*:/{if($0 !~ /^- \*\*(audit 발견|보정 반영)\*\*: [0-9]+건$/ && $0 !~ /^- \*\*재시도\*\*: [0-9]+회$/) fmt++} END{n=0; ok=1; for(k in c){n++; if(c[k]!=1) ok=0}; print (n==12 && ok && !stray && h[0]==1 && h[1]==1 && h[2]==1 && h["N"]==1 && th==4 && !fmt) ? "PASS" : "FAIL"}' issue-work/templates/issue-summary-template.md` = PASS (기대 헤더 Task 0·1·2·N 각 1회·`^### Task ` 총계 4, Task 0·1·2 각 블록에 4종이 정확히 1회씩, 열거 외 블록의 지표 필드는 Task N 포함 0건, 수치 3종은 리터럴 형식 `[0-9]+(건|회)`)

---

### Task 5: 참조 5곳 연동 갱신 (SKILL.md 3곳, plan Task N, workflow 템플릿)

- [x] 완료
- **목표**: `모델 기록` 표 구조 변경이 이를 참조하는 문구와 어긋나지 않게 한다.
- **작업 내용**:
  1. plan 템플릿 Task N 완료 기준의 "summary 모델 칸" 문구를 확정 구조에 맞춘다.
  2. `SKILL.md` `관련 skill`·`작업 진행 중`·`이슈 완료 시` 3곳의 동일 문구를 갱신한다.
  3. `issue-workflow-template.md`의 동일 문구를 갱신한다.
  4. `SKILL.md` 본문에 새 이슈 시작 시 / 작업 진행 중 / `--response` 연계 절차 서술을 반영한다.
- **완료 기준**: `grep -rn '모델 칸\|계획·구현 모델' issue-work/` 0건이고, ``{ awk '/^## /{s=$0} /`모델 기록` 표.*`audit 모델`/{c[s]++; t++} END{print (c["## 관련 skill"]==1 && c["## 작업 진행 중"]==1 && c["## 이슈 완료 시"]==1 && t==3) ? "PASS" : "FAIL"}' issue-work/SKILL.md; awk '/^### Task /{s=$0} /`모델 기록` 표.*`audit 모델`/{c[(s~/^### Task N \(고정\)/)?"N":"other"]++; t++} END{print (c["N"]==1 && t==1) ? "PASS" : "FAIL"}' issue-work/templates/issue-plan-template.md; awk '/^## /{s=$0} /`모델 기록` 표.*`audit 모델`/{c[s]++; t++} END{print (c["## 이슈 완료 시"]==1 && t==1) ? "PASS" : "FAIL"}' issue-work/templates/issue-workflow-template.md; awk '/^## /{s=$0} /^\| (설계|구현|audit) 모델 \|/{if(s=="## 모델 기록") c[$2]++; else out++} END{print (c["설계"]==1 && c["구현"]==1 && c["audit"]==1 && !out) ? "PASS" : "FAIL"}' issue-work/templates/issue-summary-template.md; } | paste -sd/ -`` = `PASS/PASS/PASS/PASS` (SKILL.md `관련 skill`·`작업 진행 중`·`이슈 완료 시` 각 1건 + plan 템플릿 `Task N (고정)` 1건 + workflow 템플릿 `이슈 완료 시` 1건, 파일별 총계 고정으로 그 외 위치 0건 + summary 템플릿 `## 모델 기록` 섹션의 표 3행 각 1회·그 외 위치 0건 — 참조 문구만으로는 참조 대상인 표 소실을 못 잡는다(7차 F-3))

---

### Task 6: 검증 — 모델명 하드코딩 부재·grep 집계 가능성·소급 변경 부재

- [x] 완료
- **목표**: spec DoD의 결정적 항목을 명령으로 일괄 확인한다.
- **작업 내용**:
  1. `grep -rnE 'Claude|GPT|Gemini|Opus|Sonnet' issue-work/ | grep -cvE 'issue-summary-template\.md:[0-9]+:\(예: '` = 0으로, 허용 예시 행을 결정적으로 제외한 잔여 건수가 없는지 확인한다. 검사는 열거된 모델명 5종에 한정한다 — denylist는 열린 집합을 전수 검증할 수 없어 DoD 주장을 열거 범위로 축소했다(6차 F-4).
  2. 보정률 추출 스니펫이 고정 샘플(발견 3+1건 / 반영 2+0건)에서 기대 출력 `2/4`를 내는지 명령으로 판정한다 — 샘플·기대 출력이 고정되지 않으면 실행자마다 판정이 달라진다(6차 F-1). 스니펫은 spec 또는 템플릿 주석에 첨부한다. 템플릿에 첨부한 스니펫은 핵심 2행(`found=$(`·`fixed=$(`)의 존재·유일성을 별도 awk로 판정한다 — 고정 샘플 검사는 형식 계약만 방어해 스니펫 소실을 못 잡는다(7차 F-4).
  3. 추적 변경은 `git diff --name-only main -- .ai/90_issues/active`(미커밋 포함), 미추적 파일은 `git ls-files --others --exclude-standard -- .ai/90_issues/active`로 확인해, 합산 출력에 `issue-0043` 외 경로가 없는지 확인한다.
- **완료 기준**: 위 명령 전부 기대 결과 — 모델명 잔여 건수 0, 고정 샘플 보정률 `2/4` 일치(PASS), 스니펫 핵심 2행 존재·유일성 PASS, 소급 변경 파일 0건

---

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

<!--
이 블록은 모든 이슈 계획의 마지막 Task로 고정한다. 삭제하지 말 것.
audit은 L2 [QD] 보완 검증 — L1 [D] 결정적 게이트의 대체가 아니라 보완이다.
이 Task는 사용자가 직접 수행하며, 구현 AI는 자동으로 닫지 않는다.
-->

- [x] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **실행 주체**: **사용자가 직접** 수행한다. 구현 AI는 이 Task를 **자동으로 닫지 않으며**, `issue-audit`를 자동 실행하지도 않는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 전부 재실행해 통과를 확인한다.
  2. 계획·구현을 수행한 모델과 **다른 벤더 모델**(Non-Anthropic 포함, 최소 동급 이상 역량)로 사용자가 직접 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 사용자가 audit 결과(지적 사항·감사 모델)를 summary에 반영·기록한다. 발견사항 보정은 issue-work `--response`로 검토한다 — **피드백 먼저, 항목별 승인 후에만** 앞 Task를 보정하며, 리포트를 받자마자 자동 보정하지 않는다.
- **완료 기준**: `[D]` 검증 명령 전부 통과 + 구현 모델 ≠ audit 모델 기록이 summary 모델 칸("벤더, 모델명" 형식)에 남는다.
