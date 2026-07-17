# Issue #43 스펙 issue-work: 모델 분리 운용 지원 — 설계 문서 점검 게이트 및 Task별 모델·보정 지표 기록

## 목표 (Goal)

설계·구현·audit을 서로 다른 모델이 맡아도 문서만으로 인수인계가 되도록 `issue-work`에 점검 게이트 2건을 고정하고, 모델 분리의 효과를 사후 집계할 수 있도록 Task별 모델·보정 지표 기록 형식을 만든다.

---

## 범위 (Scope)

**포함 (In)**

- `issue-plan-template.md` — 설계 종료 게이트 고정 블록 추가 (plan 작성 완료 직전 자기점검)
- 구현 시작 게이트 고정 블록 추가 (구현 첫 Task, 위치는 결정거리에서 확정)
- `issue-spec-template.md` — 전제(Assumptions) 섹션 추가
- `issue-summary-template.md` — Task별 `수행 모델`·`audit 발견`·`보정 반영`·`재시도` 필드 추가 — 대상은 Task 0 및 일반 실행 Task이며 Task N은 제외 (Task N이 만들어낸 발견·보정 수치는 각 대상 Task로 귀속)
- `모델 기록` 표 구조 결정 및 참조 5곳(plan Task N 완료 기준, SKILL.md `관련 skill`·`작업 진행 중`·`이슈 완료 시`, `issue-workflow-template.md`) 연동 갱신 — 이슈 본문은 4곳으로 봤으나 전수 조사에서 `SKILL.md`의 `관련 skill` 항목이 추가로 확인됨 (Task 1 특이 사항)
- `SKILL.md` 본문 절차 서술 갱신 (새 이슈 시작 시 / 작업 진행 중 / `--response` 연계)
- 기록 형식의 grep 집계 가능성 검증 스니펫

**비포함 (Out)**

- 기존 active 이슈 소급 적용 (신규 이슈부터 템플릿 자동 반영)
- 모델 자동 전환·자동 선택 (모델 전환은 사람이 수행)
- 보정률 자동 집계 도구 (표기 형식만 보장, 집계는 사후 grep)
- 특정 모델·벤더에 맞춘 분기 로직

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

> **검증 명령 작성 규칙** — 문구를 세지 말고 **행 구조**를 센다. 같은 문구가 주석·안내문에도 등장하므로,
> 헤더는 `^## `, Task는 `^### Task `, 필드는 `^- \*\*…\*\*:`로 앵커를 고정해야 실제 구조가 없을 때 불통과한다.

- [ ] [D]  `issue-plan-template.md`에 설계 종료 게이트 고정 블록이 있다  (검증: `grep -cE '^## 설계 종료 게이트' issue-work/templates/issue-plan-template.md` = 1)
- [ ] [D]  구현 시작 게이트 고정 블록이 결정된 위치에 있다  (검증: `grep -cE '^### Task 0 \(고정\): 구현 시작 게이트' issue-work/templates/issue-plan-template.md` = 1 이고 `awk '/^## /{s=$0} /^- \*\*구현 착수 전 Task 0\(구현 시작 게이트\)을 먼저 수행한다\*\*/{c[s]++; t++} END{print (c["## 작업 진행 중"]==1 && t==1) ? "PASS" : "FAIL"}' issue-work/templates/issue-workflow-template.md` = PASS — 비앵커 `grep -c`는 절차 bullet을 주석으로 바꾼 변형도 통과시켜(6차 F-3) `## 작업 진행 중` 섹션의 bullet 행 앵커 판정으로 교체)
- [ ] [D]  `issue-spec-template.md`에 전제(Assumptions) 섹션이 있다  (검증: `grep -c '^## 전제 (Assumptions)' issue-work/templates/issue-spec-template.md` = 1 — 헤더 스타일은 기존 `## 범위 (Scope)`와 동일하게 괄호 앞 공백)
- [ ] [D]  `issue-summary-template.md`의 Task 블록에 4개 필드가 모두 있다  (검증: `awk '/^### Task /{th++; t="stray"; if($0~/^### Task 0 \(고정\):/) t=0; else if($0~/^### Task 1:/) t=1; else if($0~/^### Task 2:/) t=2; else if($0~/^### Task N \(고정\):/) t="N"; if(t!="stray") h[t]++} /^- \*\*(수행 모델|audit 발견|보정 반영|재시도)\*\*:/{split($0,a,/\*\*/); if(t=="stray"||t==""||t=="N") stray++; else c[t"|"a[2]]++} /^- \*\*(audit 발견|보정 반영|재시도)\*\*:/{if($0 !~ /^- \*\*(audit 발견|보정 반영)\*\*: [0-9]+건$/ && $0 !~ /^- \*\*재시도\*\*: [0-9]+회$/) fmt++} END{n=0; ok=1; for(k in c){n++; if(c[k]!=1) ok=0}; print (n==12 && ok && !stray && h[0]==1 && h[1]==1 && h[2]==1 && h["N"]==1 && th==4 && !fmt) ? "PASS" : "FAIL"}' issue-work/templates/issue-summary-template.md` = PASS — 기대 헤더(Task 0·1·2)를 열거해 각 블록에 4종이 정확히 1회씩 있고, 열거 외 블록(Task N 포함)의 지표 필드는 0건임을 판정. 블록 단위 검사도 기대 Task를 열거하지 않으면 `Task X` 개명 변형을 통과시켜(4차 F-1) 열거식으로 교체. 기대 헤더 발생 횟수 각 1회 판정을 더해 같은 번호 중복 블록에 필드를 나눈 분할 변형을 차단하고(6차 F-2), 수치 3종의 리터럴 형식 `[0-9]+(건|회)` 판정을 더해 `미기록` 등 형식 위반·주석 placeholder를 차단(6차 F-1). 기대 헤더 집합에 Task N을 더해 각 1회·`^### Task ` 총계 4를 판정, Task N 삭제·중복과 지표 없는 일반 Task 추가 변형을 차단(7차 F-2))
- [ ] [D]  `모델 기록` 표 문구를 참조하는 5곳이 결정된 구조와 일치한다  (검증: `grep -rn '모델 칸\|계획·구현 모델' issue-work/` 0건 + ``{ awk '/^## /{s=$0} /`모델 기록` 표.*`audit 모델`/{c[s]++; t++} END{print (c["## 관련 skill"]==1 && c["## 작업 진행 중"]==1 && c["## 이슈 완료 시"]==1 && t==3) ? "PASS" : "FAIL"}' issue-work/SKILL.md; awk '/^### Task /{s=$0} /`모델 기록` 표.*`audit 모델`/{c[(s~/^### Task N \(고정\)/)?"N":"other"]++; t++} END{print (c["N"]==1 && t==1) ? "PASS" : "FAIL"}' issue-work/templates/issue-plan-template.md; awk '/^## /{s=$0} /`모델 기록` 표.*`audit 모델`/{c[s]++; t++} END{print (c["## 이슈 완료 시"]==1 && t==1) ? "PASS" : "FAIL"}' issue-work/templates/issue-workflow-template.md; awk '/^## /{s=$0} /^\| (설계|구현|audit) 모델 \|/{if(s=="## 모델 기록") c[$2]++; else out++} END{print (c["설계"]==1 && c["구현"]==1 && c["audit"]==1 && !out) ? "PASS" : "FAIL"}' issue-work/templates/issue-summary-template.md; } | paste -sd/ -`` = `PASS/PASS/PASS/PASS` — 파일별 개수(`3/1/1`)만으로는 파일 내부의 기대 섹션 정체성을 보장하지 못해(5차 F-1) 기대 위치별 정확히 1건 + 파일별 총계 고정(그 외 위치 0건)을 섹션 추적 awk로 판정. 참조 문구 검사만으로는 참조 대상인 표 자체의 소실을 못 잡아(7차 F-3) summary 템플릿 `## 모델 기록` 섹션의 3행(`설계`·`구현`·`audit 모델`) 각 1회·그 외 위치 0건 판정을 체인에 추가)
- [ ] [D]  절차·규칙 본문에 열거된 모델명 5종(Claude·GPT·Gemini·Opus·Sonnet)이 없다  (검증: `grep -rnE 'Claude|GPT|Gemini|Opus|Sonnet' issue-work/ | grep -cvE 'issue-summary-template\.md:[0-9]+:\(예: '` = 0 — 허용 예시 행(summary 템플릿 주석의 `(예: ` 형식 예시)을 패턴으로 결정적으로 제외한 잔여 건수를 판정, 사람 판별 없음. denylist는 열린 집합을 전수 검증할 수 없어 DoD 주장을 열거 범위로 축소(6차 F-4), 목록 밖 신규 모델명은 아래 [ND] 사람 리뷰 영역)
- [ ] [D]  기록 형식이 grep 집계 가능하다  (검증: `sample() { printf '%s\n' '- **audit 발견**: 3건' '- **보정 반영**: 2건' '- **audit 발견**: 1건' '- **보정 반영**: 0건'; }; found=$(sample | grep -E '^- \*\*audit 발견\*\*:' | grep -oE '[0-9]+' | paste -sd+ - | bc); fixed=$(sample | grep -E '^- \*\*보정 반영\*\*:' | grep -oE '[0-9]+' | paste -sd+ - | bc); [ "${fixed}/${found}" = "2/4" ] && echo PASS || echo FAIL` = PASS — "샘플에서 수치를 뽑아낸다"는 샘플·기대 출력이 고정되지 않아 실행자마다 판정이 달라져(6차 F-1) 고정 샘플(발견 3+1건 / 반영 2+0건)과 기대 출력 `2/4` 비교로 고정. 이고 `awk '/^  found=\$\(grep -E/{f++} /^  fixed=\$\(grep -E/{x++} END{print (f==1 && x==1) ? "PASS" : "FAIL"}' issue-work/templates/issue-summary-template.md` = PASS — 고정 샘플 검사는 형식 계약만 방어해 템플릿에 첨부한 실제 집계 스니펫의 소실을 못 잡아(7차 F-4) 스니펫 핵심 2행(`found=$(`·`fixed=$(`)의 존재·유일성을 판정)
- [ ] [D]  기존 active 이슈에 소급 변경이 없다  (검증: `{ git diff --name-only main -- .ai/90_issues/active; git ls-files --others --exclude-standard -- .ai/90_issues/active; } | grep -v 'issue-0043/' | grep -c .` = 0 — 추적 변경(미커밋 포함)과 미추적 파일을 한 파이프라인으로 합쳐 허용 경로 제외 후 잔여 개수를 명령이 직접 출력한다. 두 명령 출력을 사람이 합쳐 판별하면 `[D]` 계약 위반이라 단일 명령으로 고정. `main...` 커밋 비교는 미커밋·미추적 변경을 보지 못해 작업 트리 비교로 교체)
- [ ] [QD] 신설 게이트 2건이 모델 분리 여부와 무관하게(동일 모델·세션 교체 시에도) 동작하는 서술인지  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: "무관하게 동작한다"는 서술의 일반성 판정이라 명령으로 참·거짓을 가릴 수 없다
- [ ] [ND] `SKILL.md` 본문 절차 서술이 템플릿 변경과 어긋나지 않고 읽히는지  (검증: 사람 리뷰)  ← 강등 사유: 문서 가독성·서술 일관성은 사람 판단 영역

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `issue-work/SKILL.md` | 변경 대상 본문 — `작업 진행 중`·`이슈 완료 시`·`--response` 절차 서술 |
| `issue-work/templates/` | 변경 대상 SSoT — spec·plan·summary·workflow 템플릿 4종 |
| `.ai/90_issues/archive/issue-0029/` | 교차모델 audit 실행 주체·AI 자동 마감 금지 결정 (본 이슈 게이트 2건의 선례) |
| `.ai/90_issues/archive/issue-0031/` | `--response` 게이트 — `보정 반영` 건수 정의가 의존 |
| `.ai/AI-CONTEXT.md` (repo 안내도) | 스킬 작성 규칙 — 템플릿 SSoT 원칙, 스킬 독립성 |
