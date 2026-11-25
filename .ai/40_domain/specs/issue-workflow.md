---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/100
last_harvested: 2026-09-09
---

# 이슈 단위 작업 워크플로우(issue-work) 요건

## 요건

- 이슈마다 `.ai/90_issues/active/issue-<번호>/`에 spec·plan·summary 3종을 둔다. 디렉토리 번호는 GitHub 이슈 번호를 4자리로 채운다(issue-0015 ↔ #15).
- 진행 루프 (#145): 이슈는 계획 수립 → 계획 검증 → 구현 → 구현 검증 → 완료 확인의 다섯 단계를 지나고, 한 번 지나는 것이 한 회차다. 완료 확인에서 사용자가 `다음 회차`로 정하면 계획 수립으로 돌아가고 `마무리`로 정하면 Task N에 들어간다.
  - 계획 수립: spec·plan이 없으면 이슈 시작 절차로 쓴다. 뒤 회차에는 지난 회차의 결정을 반영해 고치며, spec은 요구사항·AC·결정이 바뀔 때만 고치고 발견을 고치는 Task는 Task N 앞에 다음 번호로 더한다. 같은 종류의 발견이 지난 두 회차에 이어서 나왔으면 plan `설계 결정`부터 고친다.
  - 계획 검증: 계획 감사(`--plan`) 수행 여부는 이슈에 한 번 묻는다. 수행으로 정한 이슈는 지난 계획 검증 뒤에 AC·요구사항, `설계 결정`, `테스트 계획`(`확인` 칸 제외) 가운데 하나가 바뀌면 다시 받는다. 6단계나 Task 0에서 바뀐 것도 같으며 일반 Task를 시작하기 전에 받는다. 기존 AC 안에서 발견을 고치는 Task를 더한 것만으로는 다시 받지 않는다.
  - 구현: 기능을 바꾸는 Task는 테스트 작성 → 실패 확인 → 테스트 커밋 → 구현 → 통과 확인 → 구현 커밋 순서다. 동작을 바꾸지 않는 Task(문서만, 화면 배치, 스파이크, 리팩터링)는 구현 → 통과 확인 두 단계이고 이유를 한 줄 적는다.
  - 구현 검증: 지난 구현 검증 뒤에 구현이 바뀌었으면 사용자가 구현 모델과 다른 벤더 모델로 교차 감사를 전체로 다시 받는다. 고친 발견의 위험도에 따른 예외는 없다. 리포트는 `--response`로 결정만 받고 소스를 고치지 않는다.
  - 구현이 바뀌었는지: summary `루프 기록`의 `구현 검증 커밋` 뒤 diff로 본다. 이슈 작업 기록(`.ai/90_issues/`, `.ai/99_workspace/`, `.ai/70_ledger/`)과 Task N이 마무리로 적은 문서 밖의 diff, 일반 Task가 고친다고 적은 파일의 diff, `테스트 계획`의 `[D]`·`[QD]` 줄 추가·변경(`확인` 칸 제외), spec AC·결정의 추가나 문장 변경(체크박스 제외) 가운데 하나라도 있으면 바뀐 것이다.
  - 완료 확인: 마지막 교차 감사의 1단계 상태·2단계 상태·종합 판정과 `테스트 계획`의 확인한 줄 수를 보인다. 1단계 상태 충족, 2단계 상태 통과나 주의, 모든 줄 확인, 반영으로 정한 발견 종결이 모두 맞으면 `마무리`를, 그 밖은 `다음 회차`를 권장한다. 결정은 사용자가 하며, 기준에 못 미친 채 `마무리`로 정하면 남은 AC와 발견마다 완화·원장 등재·새 이슈 가운데 결정을 받는다.
  - 마무리(Task N): 전체 회귀 → 색인 → 충족 AC 체크 → repo 고유 마무리 → `--clear` → PR 순서이고 교차 감사를 받지 않는다. Task N에서 구현을 고치면 계획 수립으로 돌아간다.
  - PR 뒤 피드백: git-pr-feedback으로 처리하고 이슈 문서는 고치지 않는다. 피드백으로 구현을 고쳤을 때 교차 감사를 다시 받을지는 사용자가 고른다.
- 이슈 시작 절차: 요구사항 승인 게이트(3-1) → 완료의 정의·결정 사항·plan·summary 작성(3-2) → 계획 종료 게이트 → 계획 감사 수행 여부 질의(5단계) → 이슈 본문 갱신 질의(6단계) → Task 0 구현 시작 게이트 순서다.
  - 3-1은 이슈 본문의 묶음 제목과 문장을 그대로 옮긴다. 승인 요청은 spec 경로와 목표 한 줄·포함·제외 목록만 제시하며, 목록은 spec의 묶음대로 나눠 보여 주고 R은 한 문장 그대로 보여 준다 (#140, #145).
  - 계획 종료 게이트와 Task 0에서 찾은 것은 제품·도메인 내용이면 spec `결정 사항`에, 설계 내용이면 plan `설계 결정`에 적는다 (#145).
- 원장 연계
  - 함께 해소 후보: 3-1에서 원장 `.ai/70_ledger/index.md`를 훑어 이슈 범위와 관련된 `active/` 항목을 따로 표시해 질의하고, 포함하면 R 첫 줄 끝에 `(함께 해소: K-<번호>)`로 넣는다(미포함은 기록하지 않음).
  - 해소 기재: 함께 해소 항목과 `--response` 원장 종결의 `해소(PR #N)`은 PR 번호를 알 때만 확정한다. `--clear`(이슈 완료 시) 시점에 PR이 있으면 그때 기재 → `archive/` 이관 → index 갱신 → 들어오는 링크 갱신을 같은 PR에 포함하고, 없으면 PR 생성 후 git-pr이 원장 대조 승인분에 번호를 적는다.
  - 들어오는 링크 갱신: `archive/`로 옮긴 원장 항목을 가리키는 `.ai/` 아래 문서(`.ai/90_issues/archive/` 제외)의 링크를 새 경로로 고치고 `check-ledger-links.sh`로 끊긴 원장 링크 0건을 확인한다. `--response`의 승격·해소·원인 소멸 종결로 옮길 때도 수행한다 (#120).
  - 보류 항목 등재: 이슈 완료 시(`--clear` 4단계) spec 제외 목록의 `보류` 항목을 보여 주고 승인분만 등재한다. `출처`는 `이슈 #N`이고 수용 사유·재검토 조건은 필수이며, 같은 대상을 기록한 원장 항목이 이미 있는 보류 항목만 건너뛴다 (#118).
- AC 옮기기(3-2): 이슈 본문에 `- [ ] AC<n>: `·`- [x] AC<n>: ` 행이 1개 이상이면 AC가 있는 이슈다. 완료의 정의는 이슈 본문의 AC를 같은 묶음 제목·문장·번호로 옮기고 행 끝에 `(R<n>)`을 붙인다 (#130, #145).
  - 모든 AC 행에 R 표기가 있고 포함 R마다 AC가 1개 이상 연결되며 같은 번호의 행은 하나다. AC 번호는 뒤에만 추가하고 다시 매기지 않는다.
  - 이슈 본문의 AC가 대응하지 않는 R마다(AC가 없는 이슈는 모든 R) spec이 AC를 다음 번호로 직접 쓰고 6단계가 이슈 본문에 올릴지 묻는다.
  - 레벨 태그, 검증 명령, 케이스 목록은 적지 않는다. 검증은 plan `테스트 계획`이 맡는다.
- 이슈 본문 갱신 질의(6단계): 계획 감사 처리 뒤 Task 0 전에, spec이 직접 쓴 AC가 있는 이슈만 그 AC를 같은 번호와 문장으로 이슈 본문에 더할지 묻는다. 초안 직전에 받은 기준 본문(`issue-<번호>-body-base.md`)과 실행 직전에 다시 받은 본문이 `cmp -s`로 같고 사용자가 승인했을 때만 `gh issue edit --repo --body-file`을 실행한다. 편집이 실패하면 기록하지 않고 오류를 보고한 뒤 다시 시도할지 묻는다 (#130).
  - 결과는 summary `이슈 본문 갱신` 줄에 `갱신 · <AC 번호>`·`거절 · <AC 번호>`·`대상 아님` 중 하나로 적고, 거절하면 spec의 AC가 기준이다. 이 줄이 비어 있으면 Task 0 전에 6단계를 먼저 수행한다 (#145).
- 변경 통제: 3-2 작성과 작업 진행 중에 spec 요구사항·완료의 정의·결정 사항이나 커밋한 테스트를 바꾸는 변경을 셋으로 나누고 확장·완화만 질의한다. 기준선은 이슈 본문의 AC다. 이슈 본문의 AC가 대응하지 않는 R은 3-1에서 승인받은 요구사항이 기준이고, 6단계를 마친 뒤에는 spec의 AC가 기준이다 (#130, #145).
  - 구체화: AC가 다루는 상황과 결과는 그대로 두고 판정 기준만 명확히 하는 변경이다. 질의 없이 반영하며 AC 문장은 바꾸지 않고 `결정 사항`이나 `테스트 계획`에 적는다.
  - 확장: AC에 없는 결과를 더하는 변경이다. 범위 확장(6단계와 같은 규칙으로 이슈 본문 갱신 + 재승인)·원장 등재·새 이슈(`--create`) 중에서 고르게 묻는다.
  - 완화: 오류 상황을 빼거나 성공 조건을 약하게 하거나 AC를 빼거나 제외로 옮기는 변경과, 커밋한 테스트의 기대값 변경·단언 축소·테스트 삭제다. 재승인 없이 반영하지 않는다. 결과는 그대로이고 이름·위치·준비 코드·호출 방식만 바뀌는 테스트 수정은 질의 없이 반영한다.
  - 승인 뒤에 바뀐 요구사항·AC·결정은 spec `변경 이력`에 적는다.
- spec 구성: 목표 → 요구사항(포함 R<n>·제외) → 완료의 정의(AC 행) → 결정 사항(D<n>) → 변경 이력 → 연관 문서. 적을 것이 없는 `결정 사항`과 `변경 이력`은 두지 않는다 (#145).
  - 요구사항의 포함·제외 표지는 `### 포함`·`### 제외` 제목이다. 추적성 헬퍼(`check-plan.sh --trace`)는 `### 포함`부터 다음 `### ` 제목까지를 포함 목록으로 읽는다 (#140).
  - R은 이슈 본문의 포함 항목과 같은 한 문장이고 하위 목록을 두지 않는다. 이슈 본문에 근거가 없는 R은 줄 끝에 `(이슈 본문 근거 없음: <출처>)`를 적는다 (#145).
  - 포함·제외는 따로 세어 5개 이상이면 묶음으로 나누고 5개 미만이면 묶지 않는다. 포함은 내용(기능 영역)별 `#### <묶음 이름>` 묶음이고 R 번호는 다시 매기지 않는다. 제외는 `#### 보류`, `#### 대체`, `#### 불필요` 순서의 사유별 묶음이며 항목이 없는 사유는 생략한다 (#140).
  - 완료의 정의는 포함과 같은 묶음 이름의 `### <묶음 이름>` 제목 아래 `- [ ] AC<n>: <이슈 본문과 같은 문장> (R<n>)` 행을 둔다. 이슈 본문 템플릿도 포함과 완료의 정의를 같은 묶음으로 나눈다 (#145).
  - `결정 사항`에는 경계 규칙·계산식·합의한 값·버린 대안을 적는다. 구현 방법은 plan `설계 결정`에 적는다 (#145).
- plan 구성: 계획 종료 게이트 블록 → 설계 결정(선택) → 테스트 계획 → Tasks(Task 0, 일반 Task, Task N) (#145).
  - `테스트 계획`: AC마다 테스트 표나 `테스트로 못 보는 항목` 표에 한 줄 이상 적는다. 테스트 표는 단위 테스트를 먼저 고르고 위 층을 쓰면 단위로 못 보는 이유를 적는다. 레벨은 테스트 표가 `[D]`, 못 보는 항목 표가 `[QD]`나 `[ND]`다.
  - `확인` 칸: `[D]`·`[QD]` 줄에는 그 AC를 충족으로 판정한 교차 감사의 회차를, `[ND]` 줄에는 사용자가 확인한 날짜를 적는다. 줄을 더하거나 `확인` 외 칸을 바꾸면 비운다.
  - 일반 Task: `대상 요구사항`, `테스트 먼저`(실패 확인 포함), `구현`(통과 확인 포함) 필드를 둔다. 별도 테스트 Task는 테스트 자체가 작업 대상일 때만 둔다. 회차별 묶음 제목은 두지 않는다.
  - Task는 진행만 판정하고 spec에 없는 결과를 더하지 않는다 (#130).
- summary 구성: `모델 기록` 표, `계획 감사` 줄, `이슈 본문 갱신` 줄, `루프 기록`, `종류별 발견`, Task별 수행 결과다.
  - `모델 기록`은 계획·계획 audit·구현·최종 audit 4행에 모델("벤더, 모델명 (모델 ID)", ID 확인 불가면 `(-)`)·effort 열을 둔다. effort는 도구가 기록한 표기 그대로 적고(확인 불가면 `-`) 벤더끼리 비교하지 않으며 게이트 조건에 쓰지 않는다.
  - `루프 기록`은 회차마다 한 줄이다. 칸은 회차, 바뀐 것, 다시 시작한 단계, 계획 검증 커밋, 구현 검증 커밋, 검증 결과, 결정이다 (#145).
  - `종류별 발견`은 `--response`에서 붙인 최종 감사 발견의 종류를 한 행에 한 종류의 한 회차로 적는다. 발견이 없으면 두지 않는다 (#145).
  - Task 0·일반 Task 블록의 지표 5종(`수행 모델`·`수행 effort`·`audit 발견`·`보정 반영`·`재시도`)은 값이 없어도 필드를 남긴다. 수치 지표는 이슈 전체 누적이며 한 발견은 발견이 나온 주 Task 하나에만 귀속한다. 일반 Task 블록의 `테스트`·`대응 발견`은 집계하지 않는다.
- 옵션
  - `--create`(이슈 등록): 이슈 본문 템플릿 `issue-body-template.md` 구조의 초안 `.ai/99_workspace/issue-create-body.md` 1회 작성 → 요약 제시 → 승인 → `gh issue create --repo --body-file` → 번호 보고 → "새 이슈 시작 시" 진행 여부 질의. 요약 제시는 포함·제외 목록을 초안의 묶음대로 한 문장씩 보이고(#140, #145) 완료의 정의의 묶음별 항목 수, 정한 것, 검토 필요, 분할 권고, AC가 대응하지 않는 포함 항목을 보고한다. 등록만 할 때는 active 작업 파일을 바꾸지 않는다.
  - `--workflow-only`(워크플로우 강제 복구), `--resume`(요약 보고 → 승인 시 진행, 루프 기록 마지막 행으로 회차와 단계를 알림)
  - `--response`(감사 리포트 검토 게이트, 최종·계획 리포트 자동 탐색): 최종 감사 리포트에서는 결정만 받고, 반영으로 정한 발견은 다음 회차의 계획 수립에서 plan에 Task로 더한다. 계획 감사 리포트의 승인분은 spec·plan에 바로 반영한다 (#145).
  - `--clear`(정리): PR을 만들기 직전에 실행한다. 1단계는 계획 종료 게이트·Task 0·일반 Task의 체크박스와 루프 기록 마지막 행의 `결정`이 `마무리`인지를 보고 Task N의 미체크는 세지 않는다. 미완료 항목 없이 통과한 실행만 4단계에서 Task N의 완료와 `PR 대기(git-pr로 생성)`를 적는다 (#145).
- 새 이슈 시작 시 `issue-workflow.md`가 템플릿과 다르면 자동 갱신한다.
- 템플릿이 SSoT다. SKILL.md 본문은 절차 서술과 포인터만 두고, 템플릿 변경은 신규 이슈부터 적용하며 기존 active/archive 이슈에 소급하지 않는다. 옛 구조와 새 구조를 함께 읽는 규칙은 두지 않으므로 진행 중인 옛 구조 이슈는 마친 뒤에 재설치한다 (#145).
- 결정적 헬퍼: `check-clear.sh`(`--clear` 완료·경로 참조 검사), `summarize-metrics.sh`(수치 3종 `audit 발견`·`보정 반영`·`재시도`의 표기 검사·보정률 집계), `check-ledger-links.sh`(원장 항목 이동 뒤 끊긴 원장 링크 검사, git-pr·git-pr-feedback과 바이트 단위로 같은 사본). 러너는 템플릿 본문의 게이트 명령을 추출해 fixture에 실행한다.

## 게이트 요약

| 게이트 | 시점 | 판정 주체 | 근거 이슈 |
|--------|------|-----------|-----------|
| `--create` 승인 | 이슈 등록 직전 | 사용자 | #130 |
| 요구사항 승인 | spec 목표·요구사항 작성 직후 | 사용자 | #100 |
| 변경 통제 (확장·완화) | 3-2 작성과 작업 진행 중 spec·커밋한 테스트 변경 시 | 사용자 | #130, #145 |
| 계획 종료 | plan 작성 완료 직전 | 작성 AI 자기점검 | #43 |
| 계획 감사·보정 (선택) | 계획 검증 단계. 첫 회차는 Task 0 전, 뒤 회차는 다시 받는 조건에 맞을 때 | 사용자(타벤더 모델) + `--response` | #100, #145 |
| 이슈 본문 갱신 질의 | 계획 감사 처리 후, Task 0 전 | 사용자 | #130 |
| 구현 시작 (Task 0) | 구현 첫 Task | 사람 | #43 |
| 최종 감사 (교차 감사) | 구현 검증 단계. 지난 검증 뒤에 구현이 바뀌었을 때 | 사용자(타벤더 모델) | #25, #29, #145 |
| `--response` 순서 게이트 | 리포트 검토 시 | 사용자 항목별 승인 | #31, #52 |
| 완료 확인 | 회차마다 구현 검증 뒤 | 사용자(AI는 권장만) | #145 |
| `--clear` | Task N에서 PR을 만들기 직전 | 사용자 | #15, #21, #145 |

## 산출물 구조를 읽는 스킬

이슈 본문·spec·plan·summary·감사 리포트와 그것을 옮겨 적은 PR 본문의 구조를 바꿀 때 이 표로 영향을 확인한다. 마지막 확인은 2026-11-25(#145)이며, 스킬마다 SKILL.md·템플릿·스크립트·테스트를 검색해 읽었다.

| 스킬 | 읽는 것 | 영향 | 처리 |
|------|---------|------|------|
| `ai-workspace` | update-3 기존 파일 정리가 `90_issues/` 바로 아래 옛 파일의 Task 체크박스와 완료 표시를 읽는다. 원장 항목 템플릿이 `--clear` 5·6단계를 가리킨다 | 없음 | Task의 `- [ ] 완료` 체크박스, summary의 완료 표시 문구, `--clear` 단계 번호를 그대로 두었다 |
| `ai-workspace-directory` | 읽지 않는다 | 없음 | - |
| `code-map` | 읽지 않는다. 러너가 git-pr의 PR 본문 템플릿에서 `호출 흐름`의 시퀀스 배치만 읽는다 | 없음 | `호출 흐름` 예시를 바꾸지 않았다 |
| `context-harvest` | GitHub 이슈와 PR의 본문·댓글을 구조 없이 글로 읽는다 | 없음 | - |
| `context-save` | `active/` 아래 디렉토리 이름에서 이슈 번호만 읽는다 | 없음 | 디렉토리 이름 규칙을 바꾸지 않았다 |
| `git-commit` | 읽지 않는다 | 없음 | - |
| `git-pr` | spec의 AC 행, plan `테스트 계획`, 감사 리포트의 `### 완료의 정의(DoD) 대조` 표, 이슈 본문의 AC 행(spec이 없을 때)을 읽는다 | 있음 | AC 번호로 행을 잇고 리포트 판정을 그대로 옮기게 고쳤다. PR 본문의 항목 이름·표 머리·상태 이름은 그대로다 |
| `git-pr-feedback` | 이슈 문서를 읽지 않는다. 원장 링크 검사에서 `90_issues/archive/`를 뺀다 | 없음 | 교차 감사를 다시 받을지 묻는 안내는 issue-work에만 두었다 |
| `git-qa` | PR 본문의 이슈 참조와 이슈 내용을 구조 없이 글로 읽는다 | 없음 | - |
| `git-review` | PR 본문의 `리뷰어 확인 요청`, `완료의 정의 대조` 항목과 대조 표의 AC 행, 연결 이슈 본문을 읽는다 | 없음 | PR 본문의 항목 이름과 표 머리, 이슈 본문의 AC 행 형식을 그대로 두었다 |
| `git-review-context` | 읽지 않는다 | 없음 | - |
| `git-review-quiz` | PR 본문과 연결 이슈 본문을 설명의 소재로만 읽는다. 산출 파일이 `--clear` 작업공간 정리 대상이다 | 없음 | `--clear`의 정리 동작을 그대로 두었다 |
| `install-skills` | 읽지 않는다 | 없음 | - |
| `issue-audit` | 이슈 본문의 포함·제외·AC 행, spec, plan, summary(`모델 기록`, `이슈 본문 갱신` 줄, Task의 `테스트`), 이전 감사 리포트를 읽는다 | 있음 | `check-plan.sh`, 1단계·2단계 절차, `--plan` 관점, 리포트 템플릿을 새 구조로 고쳤다 |
| `issue-work` | 이슈 본문의 포함·AC 행, spec, plan, summary, 감사 리포트를 쓰고 읽는다 | 있음 | 템플릿 5종, SKILL.md, `check-clear.sh`를 고쳤다. `summarize-metrics.sh`는 새 구조에서 그대로 동작한다 |
| `readme-sync` | 읽지 않는다 | 없음 | - |

## 관련 결정

- [ADR 0003 검증 레벨](../../50_adr/active/0003-verification-levels-and-determinization.md), [ADR 0004 교차모델 audit](../../50_adr/active/0004-cross-model-audit-and-response-gate.md), [ADR 0005 모델 분리 게이트](../../50_adr/active/0005-model-separation-gates.md), [ADR 0013 긴 산출물](../../50_adr/active/0013-long-output-single-file-generation.md), [ADR 0015 --clear](../../50_adr/active/0015-issue-clear-timing-and-archive-rules.md), [ADR 0016 요구사항 층·계획 감사](../../50_adr/active/0016-spec-requirements-layer-and-plan-audit.md), [ADR 0018 원장 선제 대조·해소 시점](../../50_adr/active/0018-ledger-proactive-review-and-resolve-timing.md), [ADR 0019 테스트 관점·Task별 배치](../../50_adr/active/0019-test-perspectives-and-task-level-placement.md), [ADR 0021 원장 이동 시 들어오는 링크 갱신](../../50_adr/active/0021-ledger-archive-move-link-update.md), [ADR 0026 완료의 정의를 이슈·spec·PR로 잇기](../../50_adr/active/0026-acceptance-criteria-across-issue-spec-pr.md), [ADR 0031 한 문장 요구사항과 진행 루프](../../50_adr/active/0031-issue-work-loop-and-one-sentence-requirements.md), 정책 [외부 공개 행위 승인 게이트](../policies/local/external-action-approval-gate.md)
- 절차 상세(How)는 `issue-work/SKILL.md`와 `issue-work/templates/`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #15](https://github.com/scroogy-dev/scroogy-agent-skills/issues/15), [#21](https://github.com/scroogy-dev/scroogy-agent-skills/issues/21), [#25](https://github.com/scroogy-dev/scroogy-agent-skills/issues/25), [#29](https://github.com/scroogy-dev/scroogy-agent-skills/issues/29), [#31](https://github.com/scroogy-dev/scroogy-agent-skills/issues/31), [#37](https://github.com/scroogy-dev/scroogy-agent-skills/issues/37), [#43](https://github.com/scroogy-dev/scroogy-agent-skills/issues/43), [#50](https://github.com/scroogy-dev/scroogy-agent-skills/issues/50), [#52](https://github.com/scroogy-dev/scroogy-agent-skills/issues/52), [#66](https://github.com/scroogy-dev/scroogy-agent-skills/issues/66), [#74](https://github.com/scroogy-dev/scroogy-agent-skills/issues/74), [#94](https://github.com/scroogy-dev/scroogy-agent-skills/issues/94), [#100](https://github.com/scroogy-dev/scroogy-agent-skills/issues/100), [#110](https://github.com/scroogy-dev/scroogy-agent-skills/issues/110), [#112](https://github.com/scroogy-dev/scroogy-agent-skills/issues/112), [#118](https://github.com/scroogy-dev/scroogy-agent-skills/issues/118), [#120](https://github.com/scroogy-dev/scroogy-agent-skills/issues/120), [#130](https://github.com/scroogy-dev/scroogy-agent-skills/issues/130), [#140](https://github.com/scroogy-dev/scroogy-agent-skills/issues/140), [#145](https://github.com/scroogy-dev/scroogy-agent-skills/issues/145)

</details>
