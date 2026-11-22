# Issue #142 실행요약 git-review: PR 링크로 리뷰 대상을 모으고 변경 줄을 빠짐없이 읽어 코드 레벨 검증을 보강한다

> 스펙: [issue-0142-spec.md](./issue-0142-spec.md) | 계획: [issue-0142-plan.md](./issue-0142-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다.

## 모델 기록

<!--
이슈 단위 요약(대표값)이다. 세부 SSoT는 아래 `Task별 수행 결과`의 `수행 모델`·`수행 effort`이며,
한 구분에 여러 모델이 관여했으면 대표 모델을 적고 세부는 Task별 기록을 본다.

형식: "벤더, 모델명 (모델 ID)". 계획·구현·audit 어느 칸이든 어느 벤더·모델이든 가능하다
(예: Anthropic, Claude Opus 4.8 (claude-opus-4-8) / OpenAI, GPT-6 (gpt-6-astra) / Google, Gemini 3.x (-)).
괄호 안은 모델 ID 전용이며 도구명·회차 같은 다른 정보를 넣지 않는다.
모델 ID를 확인할 수 없으면 괄호를 남겨 `(-)`로 적는다. 괄호가 없으면 ID를 적지 않은 것이고, `(-)`는 확인할 수 없었다는 기록이다.
모델 ID를 읽는 위치와 컨텍스트 접미어(`[1m]` 등) 제거는 issue-work SKILL.md `## 작업 진행 중`을 따른다.
effort 열에는 그 모델의 추론 강도 설정값을 도구가 기록한 표기(`high`, `xhigh` 등) 그대로 적고, 확인할 수 없으면 `-`를 적는다.
모델 열의 "벤더, 모델명 (모델 ID)" 형식은 바꾸지 않고 effort는 이 열에만 둔다.
벤더가 다르면 같은 이름의 단계라도 같은 수준이라는 보장이 없으므로 effort는 벤더끼리 비교하지 않는다.
effort와 모델 ID는 게이트 조건에 쓰지 않는다. 아래 벤더 교차 조건은 모델 열의 벤더로만 확인하며, effort가 `-`이거나 모델 ID가 `(-)`여도 조건 판정과 Task N 완료에 영향이 없다.
계획 모델(spec·plan을 쓴 모델)과 구현 모델은 다를 수 있어 칸을 나눈다 — 같으면 같은 값을 적는다.
"계획 audit 모델 ≠ 계획 모델"·"최종 audit 모델 ≠ 구현 모델" 조건을 나중에 명령으로 확인 가능하도록 기록한다. 모델 전환은 사람이 수행하므로 기계로 강제하기 어렵다.
구현에 여러 벤더가 관여했으면 최종 audit 모델의 벤더는 Task별 `수행 모델`의 모든 벤더와도 달라야 한다
— 대표 행 비교만으로는 audit 벤더가 구현 일부에 참여한 경우를 놓친다.
계획 감사를 건너뛴 이슈는 계획 audit 모델 행과 표 아래 계획 감사 줄에 `생략`을 적는다.
-->

| 구분 | 모델 | effort |
|------|------|--------|
| 계획 모델 | Anthropic, Claude Fable 5.2 (claude-fable-5-2) | xhigh |
| 계획 audit 모델 | OpenAI, GPT-6.2 Astra (gpt-6.2-astra) | high |
| 구현 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | xhigh |
| 최종 audit 모델 | OpenAI, GPT-6.2 Astra (gpt-6.2-astra) | high |

- **계획 감사**: 수행 · 발견 36건 · 보정 36건

<!--
5단계 결정 전에는 비워 둔다. 미리 `생략`을 적으면 결정 전에 중단·재개했을 때 명시적 생략으로 오인한다.
수행했으면 `수행 · 발견 N건 · 보정 N건`, 건너뛰었으면 `생략`을 적는다. 건수는 계획 감사 리포트를 `--response`로 검토한 결과다.
아래 Task 블록 지표 5종 중 `audit 발견`·`보정 반영`과 별개다. 그 지표는 구현 Task 축이라 `summarize-metrics.sh` 집계 대상이고, 이 줄은 집계하지 않는다.
이 줄은 `## 모델 기록` 섹션 안, 첫 `### Task ` 앞에 둔다. Task 블록 안이나 뒤로 옮기면 집계 헬퍼의 블록 판정 대상이 된다.
-->

- **이슈 본문 갱신**: 갱신 · AC15 (8차 계획 감사 검토에서 AC2 문장 수정, 12차 계획 감사 검토에서 범위의 지시문 줄과 AC5 문장 수정, AC 번호는 그대로)

<!--
이 줄도 `계획 감사` 줄과 같은 자리(`## 모델 기록` 섹션 안, 첫 `### Task ` 앞)에 두며 집계하지 않는다.
6단계는 대상이 아니어도 `대상 아님`을 적으므로, 세션이 바뀐 뒤 이 줄이 비어 있으면 Task 0 전에 6단계를 수행한다.
-->

---

## Task별 수행 결과

<!--
Task 0 및 일반 실행 Task(Task N 제외) 블록의 지표 5종은 사후 집계용이라 표기를 고정한다
(값이 없어도 필드는 지우지 않는다. Task N 예외의 근거는 아래 Task N 블록 주석).
- 수행 모델: "벤더, 모델명 (모델 ID)" — `모델 기록` 표와 같은 형식이며, 모델 ID를 확인할 수 없으면 `(-)`로 적는다.
  한 Task를 모델 전환·재시도로 둘 이상이 수행했으면
  관여한 모델을 전부 ` / `로 나열한다 — 하나만 남기면 누락된 벤더가 audit을 맡아도 Task N의 강화 조건을 통과한다.
  나열할 때도 항목마다 괄호를 붙이며 줄여 쓰지 않는다
  (예: `Anthropic, Claude Opus 4.8 (claude-opus-4-8) / OpenAI, GPT-6 (gpt-6-astra)`).
  같은 모델이 effort를 바꿔 다시 수행했으면 그 자리에 반복해 적는다(아래 `수행 effort`의 위치 대응).
  `-`는 미착수·스킵 Task 전용이며, `결과`가 완료·부분 완료면 실제 값을 필수로 기록한다
  (`-`로 남기면 Task N의 교차모델 강화 조건이 공집합이 되어 우회가 된다)
- 수행 effort: 그 Task를 수행한 모델의 effort. 도구가 기록한 표기(`high`, `xhigh` 등) 그대로 적는다.
  한 Task 안에서 바꿨으면 `수행 모델`과 같은 순서로 ` / `로 나열하고, 두 목록은 위치로 대응한다.
  항목 수를 `수행 모델`과 같게 두고, 확인할 수 없는 값은 그 자리에 `-`를 두며, 같은 effort가 이어지면 그대로 반복한다.
  아래 예시의 A·B는 위치 대응을 보이기 위한 모델 기호이며, 실제 기록은 항목마다 "벤더, 모델명 (모델 ID)"로 적는다.
    A/high 뒤 A/low 뒤 B/high:  수행 모델 `A / A / B`, 수행 effort `high / low / high`
    A/high 뒤 B/low 뒤 B/high:  수행 모델 `A / B / B`, 수행 effort `high / low / high`
    A/high 뒤 B(확인 불가):     수행 모델 `A / B`, 수행 effort `high / -`
  확인 불가 외에 미착수·스킵 Task도 `-`로 둔다. 벤더끼리 비교하지 않고 게이트 조건에 쓰지 않는 점은 위 `모델 기록` 주석과 같다.
  값을 읽는 위치(실행 기록 우선)는 issue-work SKILL.md `## 작업 진행 중`을 따른다.
- audit 발견: 이 Task와 관련된 audit 발견사항 건수 — 없으면 `0건` (`-` 금지)
- 보정 반영: `--response` 항목별 승인을 통과해 실제로 보정한 건수 — 없으면 `0건` (`-` 금지)
- 재시도: 같은 Task에서 재수정·재시도한 횟수 — 없으면 `0회` (`-` 금지)

한 발견이 여러 Task 산출물에 걸쳐도 가장 직접 수정된 주 Task 하나에만 귀속한다 —
`audit 발견`·`보정 반영` 모두 그 주 Task에서 1회만 세고 관련된 다른 Task에는 세지 않는다.
Task 축에서도 이슈 단위 합계가 중복으로 부풀지 않게 하기 위함이다(아래 회차 축 중복 제외와 같은 취지).

수치 3종은 회차별 값이 아니라 이슈 전체 누적이다 — 여러 차수 감사가 같은 발견을 재확인해도
1건으로 세고(중복 제외), 새 회차 값으로 덮어쓰지 않는다. 보정률 사후 집계의 분모·분자가 회차 반복으로 부풀지 않게 하기 위함이다.

수치 3종에 `-`를 쓰지 않는 이유: 아래 스니펫이 `[0-9]+`만 추출하므로 `-`인 Task는
합계에서 조용히 빠지고, 전부 `-`면 합계 자체가 빈 문자열이 된다. `-` 허용은 비수치 필드(`수행 모델`·`수행 effort`)에만 둔다.

수치 3종의 기본값은 주석이 아니라 리터럴 `0건`/`0회`로 둔다: 주석 placeholder는 렌더링 값이
비어 있는데도 집계기가 주석 안 숫자를 실제 값으로 오인하고, `미기록` 같은 형식 위반도 걸러지지 않는다.

보정률은 별도 필드로 두지 않고 `보정 반영 / audit 발견`으로 사후 집계한다.
아래 스니펫이 동작하도록 `- **<필드>**: <숫자><단위>` 표기를 지킨다 (줄 시작, 굵게, 콜론 뒤 숫자).

  # 이슈 하나의 보정률
  found=$(grep -E '^- \*\*audit 발견\*\*:' issue-<번호>-summary.md | grep -oE '[0-9]+' | paste -sd+ - | bc)
  fixed=$(grep -E '^- \*\*보정 반영\*\*:' issue-<번호>-summary.md | grep -oE '[0-9]+' | paste -sd+ - | bc)
  echo "보정률: ${fixed}/${found}"

  # 모델별 집계는 `수행 모델`·`수행 effort` 행과 함께 뽑는다
  grep -E '^- \*\*(수행 모델|수행 effort|audit 발견|보정 반영|재시도)\*\*:' issue-<번호>-summary.md
-->

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

<!--
plan 템플릿의 첫 고정 Task에 대응하는 블록이다. 삭제하지 말 것.
질의로 해소한 전제는 spec `## 전제 (Assumptions)`에 남기고, 여기에는 수행 사실만 적는다.
나열한 항목이 없었으면 `수행 내용 요약`에 `전제 누락 없음` 한 줄을 기록한다.
-->

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: spec·plan 전체와 변경 대상(`git-review/SKILL.md`, 러너), 사본 원본(`git-pr/scripts/verify-submit.sh`의 `normalize`)을 읽고 전제 5건을 나열했다. 질의 1건(Task 6 모의 실행의 수행 방식)은 사용자가 "하위 에이전트 6개를 저장소 안에서 동시에 실행하고 케이스별 파일에 바로 쓴다"를 골랐다. 나머지 4건(헬퍼의 실행 셸 bash 3.2, 단계 번호 변경과 R10 회귀의 무충돌, Task 7의 저장소 확정이 `origin`이라는 것, 도구 버전)은 저장소와 실행 기록으로 확인했다. 다섯 건 모두 spec `## 전제`의 "구현 시작 게이트에서 정한 것 (2026-11-21)"에 반영했다.
- **특이 사항**: R10의 회귀 방지 명령을 구현 전 상태에서 실행해 `passed: 61, failed: 0`을 확인했다. 12차 보정의 훅·파일 시스템 감시 끄기 옵션은 실행해 보지 않았고, Task 1 러너가 처음 판정한다.

---

### Task 1: 저장소 대조 헬퍼와 브랜치 수집 헬퍼

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5) / Anthropic, Claude Fable 5.2 (claude-fable-5-2)
- **수행 effort**: xhigh / xhigh
- **audit 발견**: 7건
- **보정 반영**: 7건
- **재시도**: 1회
- **수행 내용 요약**: `git-review/scripts/resolve-target.sh`(원격 URL 정규화는 `git-pr/scripts/verify-submit.sh`의 사본, 헤더에 사본 관계 기재)와 `git-review/scripts/collect-branch-changes.sh`(`--base`·`--marked`)를 실행 권한과 함께 만들었다. 러너에 `대상 대조` 케이스(통과 9·격추 10)와 `브랜치 수집` 케이스(통과 35·격추 9)를 더해 124건이 모두 통과한다. 러너의 새 케이스는 전역·시스템 Git 설정을 끄고(`GIT_CONFIG_GLOBAL=/dev/null`, `GIT_CONFIG_NOSYSTEM=1`) 작업 트리 밖 실행 케이스가 상위 저장소를 찾지 않게 막는다. `.ai/AI-CONTEXT.md` 디렉토리 구조의 `git-review/` 구간(scripts·tests 주석)과 `last updated`를 고쳤다. Task 1 완료 기준 `[D]` 세 개가 출력 없이 끝난다.
- **특이 사항**:
  - 10~12차 보정에 적은 명령의 첫 실행 확인(Git 2.50.1): spec R1의 헬퍼 `[D]` 다섯 개(저장소 대조, 브랜치 수집, 커밋 대조, 경로 표기, `--marked`)를 spec에서 그대로 꺼내 bash 3.2.57과 zsh 5.9로 실행했고 모두 출력 없이 끝났다. 훅(`post-index-change`)과 파일 시스템 감시의 조회 훅이 도는 사전 조건도 성립했고, `-c core.hooksPath=/dev/null`·`-c core.fsmonitor=false`로 `.git` 아래 파일이 그대로였다.
  - 판별력 확인: 헬퍼 사본에서 장치를 하나씩 뺀 변형 9개(훅·파일 시스템 감시·분할 인덱스를 끄지 않음, `--ignore-submodules=dirty` 제거, `git diff`로 바꿈, 10차 경로 규칙, 9차까지의 Git 표기, 줄 단위로 거르는 `--marked`, `.ai/99_workspace` 제외 누락)를 만들었다. 각 변형에서 해당 spec `[D]`와 러너 케이스가 위반을 낸다. 변형과 실행 기록은 scratchpad에만 두었다.
  - 러너 실행 시간이 약 1초에서 약 22초로 늘었다(임시 저장소 7개를 만들고 헬퍼를 40여 번 부른다). spec "환경·관례"의 "Task 단위 확인은 git-review 러너(1초)"는 분기점 기준의 기록이다.
  - 최종 감사 1차 보정(2026-11-21, F-1·F-2·F-4·F-5, spec 전제 "최종 감사에서 정한 것 (2026-11-21, 1차)"):
    - F-4·F-5: 헬퍼가 호출 환경의 `GIT_ALTERNATE_OBJECT_DIRECTORIES`를 뒤에 이어 붙이고, pathspec 변수 4종과 `GIT_DIFF_OPTS`를 해제한다. `GIT_DIFF_OPTS`는 감사 밖에서 같은 원인으로 찾은 사례다.
    - F-1·F-2: 필터 프로그램이 스스로 남기는 파일과 Git의 바이너리 판정을 경계로 선언했다. 헬퍼 머리 주석, spec R1 `[D]` 본문, SKILL.md, 원장 K-0031에 적었다.
    - 테스트: 러너 `브랜치 수집`에 8건(기준 출력 1, 환경 변수 5, 대체 객체 1, 바이너리 판정 1)을 더했고, spec R1에 `[D]` 2개(환경 변수, 바이너리 판정)를 더했다. 보정 전 헬퍼로 돌리면 러너의 `GIT_LITERAL_PATHSPECS`·`GIT_DIFF_OPTS`·대체 객체 케이스와 spec 환경 변수 `[D]`가 위반을 낸다.
    - 감사 사례 다섯(F-1·F-2·F-4·F-5, `GIT_DIFF_OPTS`)은 보정 전 헬퍼로 scratchpad 임시 저장소에서 재현했다. 보정 뒤 F-4·F-5·`GIT_DIFF_OPTS`는 변수가 없을 때와 출력이 같고, F-1·F-2는 선언한 경계대로 동작이 그대로다.
  - 최종 감사 2차 보정(2026-11-22, F-9·F-10, spec 전제 "최종 감사에서 정한 것 (2026-11-22, 2차)"):
    - F-9: 헬퍼가 임시 디렉토리에 `*` 한 줄의 `.gitignore`를 둔다. macOS의 `mktemp -d`는 `TMPDIR`을 보지 않아 리포트 사례가 그대로 재현되지 않았고, `TMPDIR`을 따르는 대체 `mktemp`(GNU 동작)로 재현했다.
    - F-10: 헬퍼가 현재 디렉토리를 옮기지 않는다(`cd` 제거, `git add -A`는 `:(top)`, `--marked`는 `--full-name -- ':/'`, `--git-path`의 상대 경로는 `$PWD` 기준). 바깥에 다른 저장소가 있으면 보정 전 헬퍼가 그 저장소의 변경을 종료 코드 0으로 내는 것을 감사 밖에서 재현했다.
    - 테스트: 러너 `브랜치 수집`에 4건(임시 디렉토리 2, 상대 경로 변수 `--base`·`--marked` 2)을 더했고, spec R1에 `[D]` 1개를 더했다. 보정 전 헬퍼로 돌리면 러너의 새 4건과 spec `[D]`의 위반 4행이 모두 나온다.
  - 최종 감사 3차 보정(2026-11-22, F-12, spec 전제 "최종 감사에서 정한 것 (2026-11-22, 3차)"):
    - F-12(F-9 잔여): 헬퍼가 임시 디렉토리를 첫 `git` 명령 앞에서 만들고, 부르는 프로그램의 `TMPDIR`을 그 디렉토리로 지정한다. 헬퍼가 부른 프로그램이 `TMPDIR`에 남기는 파일도 목록에 나오지 않고 작업 트리에 남지 않는다.
    - 리포트의 `xcrun_db` 사례는 이 머신에서 재현되지 않았다(보정 전 헬퍼로 R1 `[D]`가 출력 없이 끝남). 부를 때마다 `TMPDIR`에 파일을 남기는 대역 `git`으로 같은 상태를 만들었다.
    - 감사 밖에서 함께 고친 것: 임시 디렉토리가 상대 경로로 나오면 절대 경로로 바꾼다. 보정 전 헬퍼는 하위 디렉토리에서 상대 경로 `TMPDIR`로 부르면 수집에 실패했다.
    - 테스트: 러너 `브랜치 수집`에 5건을 더했고, spec R1의 임시 디렉토리 `[D]`에 대역 `git`·`--marked`·상대 경로 `TMPDIR` 확인을 더했다. 보정 전 헬퍼로 돌리면 러너의 새 5건이 실패하고 spec `[D]`가 위반 6행을 낸다.
    - F-9의 잔여라 `audit 발견`·`보정 반영`은 그대로 두고 `재시도`에 1회를 더했다. 이번 보정은 Anthropic, Claude Fable 5.2 (claude-fable-5-2), xhigh가 수행했다.
  - 최종 감사 4차 보정(2026-11-22, F-14, spec 전제 "최종 감사에서 정한 것 (2026-11-22, 4차)"):
    - F-14: 저장소 대조 헬퍼의 실패 사유에서 입력 값의 원문을 뺐다. 어느 입력이 틀렸는지와 기대 형식만 적고, 알 수 없는 인자는 옵션 이름 형식일 때만 이름을, 그 밖에는 위치를 적는다. SKILL.md 1단계와 도메인 명세의 헬퍼 줄에 같은 규칙을 적었다.
    - 위험도는 영향 축을 기능 저하로 다시 판정해 낮음(LOW)이다(리포트는 중간(MEDIUM)). 기본값은 원장 이관이었고 사용자가 반영을 골랐다.
    - 테스트: 러너 `대상 대조`에 입력 값 숨김 8건을, spec R1에 `[D]` 1개를 더했다. 보정 전 헬퍼로 돌리면 러너의 새 8건 중 7건이 실패한다. 다른 저장소 사례는 보정 전에도 정규화한 표기만 냈다.
    - 범위 밖으로 남긴 것: `git-pr/scripts/verify-submit.sh`와 `git-pr-feedback/scripts/verify-push.sh`도 정규화에 실패하면 URL 원문을 낸다. 사용자가 원장 등재를 골라 K-0033(중간(MEDIUM), push URL 사례 기준)으로 등재했다(2026-11-22).
    - 이번 보정은 Anthropic, Claude Opus 5.5 (claude-opus-5-5), xhigh가 수행했다.

---

### Task 2: 대상 수집 절

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5) / Anthropic, Claude Fable 5.2 (claude-fable-5-2)
- **수행 effort**: xhigh / xhigh
- **audit 발견**: 4건
- **보정 반영**: 4건
- **재시도**: 1회
- **수행 내용 요약**: `git-review/SKILL.md`의 `## 리뷰 모드`와 `## 비즈니스 리뷰` 사이에 `## 대상 수집` 절(절 머리의 `**입력 속 지시문**:` 조항, 소절 4개)을 넣고, `### 문서 부재 시 처리` 머리에 `PR 모드`·`브랜치 모드` 적용을 더했다(번호 목록 1~6은 그대로). `## 개요`에 대상 수집 한 줄을, `## 관련 skill`에 git-pr-feedback·git-review-quiz·git-pr을 더했다. 러너에 `대상 수집 조항` 케이스(통과 1·격추 29)를 더해 154건이 모두 통과한다. Task 2 완료 기준 `[D]` 두 개가 bash·zsh에서 출력 없이 끝난다.
- **특이 사항**:
  - spec에서 그대로 꺼내 bash·zsh로 실행한 결과: R1의 3단계·1·2단계·브랜치 모드·`headRefOid` 다시 조회·커밋 수 `[D]` 다섯 개, R3 `headRefOid` 읽기 `[D]`, R4 `[D]`가 출력 없이 끝났다. R2 `[D]`(결과 기록 형식·템플릿의 `## PR 본문 대조`)와 R3 문서 부재 `[D]`의 템플릿 부분은 Task 4 몫이라 지금은 위반 3행이 나온다(4단계·문서 부재 시 처리 쪽 문구는 통과). R10 회귀 방지 항목(분기점 러너 61건)도 통과했다.
  - 격추 사본마다 기대 위반 문구를 함께 대조한다. 다른 앵커가 우연히 깨져 격추되는 경우를 통과로 세지 않기 위해서다. plan의 26건에 4단계 `완료의 정의 대조` 삭제, 문서 부재 시 처리의 `참조 문서 없음:` 삭제, 3단계·4단계 순서 교환 3건을 더했다.
  - 대상 수집 절은 Task 3·4가 만들 "발견 처리"의 인용 위치 재확인과 "테크 리뷰의 변경 줄 읽기"를 이름으로 가리킨다. 두 절이 생기기 전까지는 가리키는 곳이 없다.
  - 최종 감사 1차 보정(2026-11-21, F-3·F-7):
    - F-3: 3단계의 contents 조회를 경로가 영문자·숫자·`.`·`_`·`-`·`~`·`/`로만 된 파일에만 쓰고, 그 밖의 경로는 읽기 실패로 두게 했다(조항 한 줄과 코드 블록의 `case` 판정).
    - F-7: 러너 `대상 수집 조항`이 판정 블록을 꺼내 실행하고 `?ref=${sha}`를 찾는다. 격추 4건(`?ref=` 삭제, 판정 문자 확장, `case` 행 삭제, 조건 행 삭제)을 더했다. spec R3에 같은 판정의 `[D]`를 더했다.
    - 감사 밖에서 함께 고친 것: SKILL.md 코드 블록의 경로 변수를 `path`에서 `file`로 바꿨다(zsh에서 `path`는 `PATH`와 묶임, 사용자 승인). 감사 발견이 아니라 `audit 발견`에 세지 않는다.
  - 최종 감사 2차 보정(2026-11-22, F-11): 3단계에 diff의 파일 머리 행에 모드 `120000`(심볼릭 링크)이 나오는 파일에는 contents 조회를 쓰지 않고 링크가 가리키는 경로를 diff의 변경 줄로 읽는다는 조항 1행을 더했다. 러너 `대상 수집 조항`에 조항 검사와 격추 1건(조항 행 삭제)을, spec R3에 `[D]` 1개를 더했다. 보정 전 SKILL.md로 돌리면 러너의 실제 SKILL.md 통과 케이스와 spec `[D]`가 위반을 낸다. contents 조회가 링크를 따라가는 동작은 GitHub REST 문서와 리포트 사례로 확인했고 외부 조회로 다시 재현하지는 않았다.
  - 최종 감사 3차 보정(2026-11-22, F-13, spec 전제 "최종 감사에서 정한 것 (2026-11-22, 3차)"):
    - F-13(F-11 잔여): 3단계의 contents 조회 앞에 고정한 커밋의 트리 조회(`git/trees/<SHA>?recursive=1`)로 경로의 모드를 읽고, 모드가 `100644`·`100755`일 때만 조회한다. 모드 `120000`인 링크는 가리키는 경로가 diff의 변경 줄에 나올 때만 그 줄로 읽고, 그 밖의 모드와 모드를 얻지 못한 경로는 읽기 실패로 둔다. 2차의 diff 머리 행 조항을 이 조항으로 바꿨다.
    - 테스트: 러너 `대상 수집 조항`의 판정 블록 실행이 트리 조회와 모드별 조회 여부를 보고, 조항 검사 2행과 격추 6건을 더했다. spec R3의 contents 조회 `[D]` 두 개를 고쳤다. 보정 전 SKILL.md로 돌리면 spec `[D]` 두 개가 위반 8행을 낸다.
    - 확인하지 않은 것: GitHub 실호출은 하지 않았다(실행 확인 허용 여부에 답이 없었다). 재귀 트리 조회의 `path`가 저장소 루트 기준 전체 경로라는 점과 `gh api --jq` 필터의 실제 출력이 남는다. 다르면 읽기 실패가 되고 다른 파일을 읽지는 않는다.
    - F-11의 잔여라 `audit 발견`·`보정 반영`은 그대로 두고 `재시도`에 1회를 더했다. 이번 보정은 Anthropic, Claude Fable 5.2 (claude-fable-5-2), xhigh가 수행했다.
  - 최종 감사 4차 보정(2026-11-22, F-15, spec 전제 "최종 감사에서 정한 것 (2026-11-22, 4차)"):
    - F-15: 러너 `대상 수집 조항`과 spec R3 contents 조회 `[D]`의 대역 `gh`가 트리 조회에 링크 항목과 그 경로의 항목이 든 응답을 만들고, SKILL.md의 `--jq` 필터를 `jq`로 평가한 값을 돌려준다. 러너에 `.mode`를 `.sha`로 바꾼 격추 사본 1건을 더했다.
    - 위험도는 리포트와 같은 낮음(LOW)이다. 기본값은 원장 이관이었고 사용자가 반영을 골랐다.
    - `.sha` 변형 SKILL.md로 돌리면 보정 전 러너는 221건이 모두 통과하고, 보정 후 러너는 실제 SKILL.md 통과 케이스를 포함해 2건이 실패하며 spec R3 `[D]`도 위반 2행을 낸다.
    - `jq`가 없는 환경에서는 러너와 spec R3 `[D]`가 위반을 낸다. repo 테스트가 `jq`를 쓰는 것은 처음이다.
    - 이번 보정은 Anthropic, Claude Opus 5.5 (claude-opus-5-5), xhigh가 수행했다.

---

### Task 3: 테크 리뷰 변경 줄 읽기와 확인 관점

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `git-review/SKILL.md`의 `## 테크 리뷰`를 4단계로 다시 매겼다. `### 2단계: 변경 줄 읽기`를 새로 넣고 기존 2·3단계를 3·4단계로 옮겼다. 2단계에는 읽는 줄(삭제 줄 포함), 삭제 줄을 보는 관점, 삭제만 있는 파일의 집계, 주변 코드의 읽기 기준, 읽지 않는 파일의 사유 4가지, 파일 수의 합을 적었다. 3단계 끝에는 판정 문장 한 줄과 `**확인 관점**` 목록(버그 5·보안 4·성능 4)을 두고, doc 카테고리 세트에는 적용하지 않는다는 줄을 더했다. 카테고리 표와 doc 카테고리 표는 그대로다. 러너에 `코드 레벨 조항` 케이스(통과 1·격추 11)를 더해 166건이 모두 통과한다. Task 3 완료 기준 `[D]`가 bash·zsh에서 출력 없이 끝난다.
- **특이 사항**:
  - spec에서 그대로 꺼내 bash·zsh로 실행한 결과: R5 `[D]`와 R6 `[D]` 두 개(확인 관점 구조, 카테고리 표 첫 열 7개)가 출력 없이 끝났다. R7 `[D]`는 템플릿 요약 2행만 위반이고(Task 4 몫), SKILL.md 2단계의 `잠금 파일`·`생성 파일`은 통과한다. R10 회귀 방지 항목(분기점 러너 61건)도 통과했고, 매트릭스 행을 깨뜨린 사본에서는 위반을 낸다.
  - 판별력 확인: 러너의 격추 사본 5개(보안 관점 2개, 버그 관점 8개, 보안 항목 삭제, 2·3단계 제목 교환, 빠짐없이 읽는 행의 삭제 줄 삭제)를 scratchpad에 다시 만들어 spec R5·R6 명령에 넣었고, 모두 위반이 나왔다.
  - 확인 관점 목록은 3단계 끝, "이 카테고리 체계는 … 원본입니다" 문장 뒤에 두었다. issue-audit·git-review-quiz가 복사하는 카테고리 체계에 들지 않게 하기 위해서다(spec 배경 "카테고리 표를 복사해 쓰는 스킬은 바뀌지 않는다").
  - 옛 단계 번호를 가리키는 문장이 SKILL.md 안에는 없었다. `.ai/60_codebase/git-review/review-call-flow.md`의 옛 번호는 Task 8이 고친다.

---

### Task 4: 발견 처리 절과 결과 기록 형식·템플릿

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `git-review/SKILL.md`의 `## 테크 리뷰`와 `## 위험도 분류` 사이에 `## 발견 처리` 절(인용 위치 재확인, 실패 시나리오, 변경 전부터 있던 결함)을 넣었다. 비즈니스 리뷰 3단계·테크 리뷰 4단계에 인용 위치 재확인을 거친다는 문장을, `## 상태 산출`·`## 판정 산출`에 변경 전부터 있던 결함을 산출 입력에 넣지 않는다는 한 줄을 더했다. `## 결과 기록 형식`에는 새 기록 순서, 요약의 두 줄, PR 본문 대조(값 3종, 불일치 처리, 요약 줄만 있을 때), 비즈니스 리뷰의 `참조 문서 없음:` 줄, 실패 시나리오와 `(확인 필요)`를 반영했고, 접기 기준의 항목별 접기 줄도 고쳤다. 결과 템플릿은 고정 앵커의 표대로 `## PR 본문 대조`와 `## 변경 전부터 있던 결함`을 더하고 요약·비즈니스 리뷰·테크 리뷰 블록을 고쳤다. 표와 헬퍼 호출 예시는 그대로다. 러너에 `발견 처리 조항`(통과 1·격추 12)과 `결과 템플릿`(통과 1·격추 8) 케이스를 더해 188건이 모두 통과한다. Task 4 완료 기준 `[D]` 두 개가 bash·zsh에서 출력 없이 끝난다.
- **특이 사항**:
  - spec에서 그대로 꺼내 bash·zsh로 실행한 결과: R2~R9의 `[D]` 전부와 R10의 첫 `[D]`가 출력 없이 끝났다. Task 2·3 때 Task 4 몫으로 남았던 R2·R3·R7의 템플릿 부분도 이제 통과한다. R10 회귀 방지 항목(분기점 러너 61건)과 Task 3 완료 기준도 다시 통과했다.
  - 판별력 확인: 러너 격추 사본과 같은 변형 11개(SKILL.md 7개, 템플릿 4개)를 scratchpad에 다시 만들어 spec R2·R7~R10 명령에 넣었고, 모두 위반이 나왔다.
  - 인용 위치 재확인 소절에 `git show "${mb}:${path}"` 코드 블록을 두었다. 러너의 `git merge-base` 행 추가 격추는 이 코드 블록에 행을 더해 만든다.
  - repo 전체 스킬 테스트(spec `### 공통`, 약 10분)는 아직 돌리지 않았다.

---

### Task 5: ADR 0014에 변경 전 결함 예외 기록

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `.ai/50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md`를 제자리에서 고쳤다(`.ai/50_adr/index.md` `## 수명 주기`의 "결정 항목 일부 변경"). `## 결정` 끝에 git-review의 변경 전부터 있던 결함을 별도 섹션에 적고 카테고리 건수·상태·판정 산출에 넣지 않는다는 항목 하나를 `(#142)`와 함께 더했다. 등급은 텍스트로만 적고 issue-audit에는 이 예외를 두지 않는다는 내용도 같은 항목에 있다. `## 근거` 접기에 날짜(2026-11-21)·이슈 번호·경위를, `## 원본 출처` 접기에 이슈 #142 링크를 더했다. 프론트매터는 그대로다. `.ai/50_adr/index.md`의 0014 행 설명에 산출 제외를 더했다. Task 5 완료 기준 `[D]`가 bash·zsh에서 출력 없이 끝난다.
- **특이 사항**:
  - spec에서 그대로 꺼내 bash·zsh로 실행한 결과: R10의 첫 `[D]`(AC13)와 둘째 `[D]`(AC14)가 출력 없이 끝났다.
  - 근거 접기의 판단 기준 문장은 `git-review/SKILL.md` `## 발견 처리`의 "드러내거나 악화시키면"과 정의의 "경로를 새로 만들거나 넓히지 않은"을 함께 적어 두 문서의 표현을 맞췄다. 완료 기준 `[QD]`(ADR과 SKILL.md 규칙의 일치)는 최종 감사가 채점한다.
  - ADR을 읽는 러너는 `ai-workspace`·`context-harvest` 둘이다. 둘 다 `.ai/50_adr/index.md`의 `## 수명 주기` 구간이나 템플릿만 보므로 이번에 고친 파일 목록 행과 겹치지 않는다. repo 전체 스킬 테스트는 아직 돌리지 않았다.

---

### Task 6: 모의 실행 fixture와 모의 실행

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 1회
- **수행 내용 요약**: `git-review/tests/fixtures/code-level/`에 `README.md`와 입력·기대 쌍 6개(`planted-defects`·`unverifiable`·`clean`·`deleted-lines`·`preexisting`·`index-read`)를 만들었다. 가상 저장소 `github.example.com/acme/shop-api`의 Python 코드이며 개인정보·비밀값은 없다. README는 수행자에게 주는 파일이라 케이스 표에 모드와 입력만 적고 기대 결과를 적지 않았다. 러너에 `모의 실행 fixture` 케이스(통과 1·격추 3: 기대 파일·입력 파일·README를 하나씩 뺀 사본)를 더해 192건이 모두 통과한다. 모의 실행은 Task 0에서 정한 대로 하위 에이전트 6개를 저장소 안에서 동시에 실행했다. 지시문에는 SKILL.md·README·입력 경로와 결과 경로만 주고, 기대 파일과 `.ai/90_issues/`·`.ai/99_workspace/`의 다른 파일을 읽지 말라고 적었다. 여섯 결과를 기대 파일과 대조한 결과 모든 항목을 만족했다. Task 6 완료 기준 `[D]` 두 개가 bash·zsh에서 출력 없이 끝난다.
- **특이 사항**:
  - 1회차 대조: 여섯 케이스가 기대 항목을 모두 만족했다(판정: `planted-defects`·`unverifiable`·`deleted-lines`·`index-read` 변경 요청, `clean`·`preexisting` 승인). 임시 초안(`temp_domain.md`·`temp_contract.md`)은 생기지 않았고, 하위 에이전트가 바꾼 파일은 각자의 결과 파일뿐이다.
  - 재시도 1회(fixture 보완, SKILL.md는 고치지 않음): `preexisting` 1회차는 옮긴 블록의 `parse_qty` 결함을 낮음(LOW)·`(확인 필요)`로 산출했다. 입력에 수량이 금액에 쓰이는 곳이 없어 영향을 확인하지 못했다는 사유였다. 기대 항목은 만족했지만 plan의 fixture 설계(옮긴 블록의 결함이 중간(MEDIUM) 이상)에 못 미쳐, 입력에 변경하지 않은 `app/cart_store.py`·`app/checkout.py`를 더하고 이 케이스만 다시 실행했다. 2회차는 `parse_qty`를 중간(MEDIUM)으로 산출했고 기대 항목을 모두 만족했다(결과 파일은 2회차로 덮어씀).
  - 수행자가 SKILL.md 문장만으로 판단하기 어려웠다고 보고한 점(기대와 어긋난 결과는 없어 SKILL.md를 고치지 않음):
    - PR 본문이 미검증으로 적었는데 리뷰에서 충족을 확인한 AC의 대조 결과 값. 수행자는 두 상태를 견줘 `불일치(MISMATCH)`로 적었고 기대와 같다.
    - 변경 전부터 있던 결함 항목에 `실패 시나리오:` 줄과 `(확인 필요)`를 붙이는지(템플릿에 정해져 있지 않아 수행자마다 달랐다).
    - 같은 원인을 비즈니스 리뷰와 테크 리뷰에 모두 올리는지(`index-read`는 둘 다 올려 원인 2개가 높음(HIGH) 4건으로 집계됐다).
    - 테크 리뷰 발견이 0건일 때 섹션 본문(수행자는 `발견 없음`을 적었다).
    - 보안 주입의 발생확률 축, 누적되는 자원 고갈의 영향 축(위험도 분류의 기존 축 정의 문제로 이 이슈의 범위 밖).
    - 가상 저장소라 SSoT 선언·아키텍처 문서가 없을 때의 처리(fixture의 조건이며 실제 PR 모드에서는 현재 저장소의 문서를 쓴다).

---

### Task 7: 실제 실행 점검

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 1건
- **보정 반영**: 1건
- **재시도**: 0회
- **수행 내용 요약**: repo의 `git-review/SKILL.md`로 세 점검을 수행했고 절차와 다른 동작은 나오지 않았다. PR 모드는 하위 에이전트 1개가 저장소 안에서 끝까지 실행했고(실행 로그 [issue-0142-run-pr-log.md](./issue-0142-run-pr-log.md)), 다른 저장소 링크와 브랜치 모드 수집은 직접 수행했다. 완료 기준 `[D]` 네 개가 bash·zsh에서 출력 없이 끝난다.
  - **PR 모드 (PR #139)**
    - 대상 조건: 머지된 PR이고 head `issue-0138`이 현재 브랜치 `issue-0142`와 다르며 본문에 두 항목이 있다. 실행 직전(2026-11-21 11:37Z)에 plan의 대조 줄 명령이 3행을 냈다(`.ai/60_codebase/index.md`의 issue-audit·issue-work 행, `.ai/70_ledger/index.md`의 K-0023 행). 실행 뒤에 다시 돌려도 같은 3행이다.
    - 저장소 확정: `git rev-parse --abbrev-ref '@{upstream}'`가 종료 코드 128(upstream 없음)이고 원격은 `origin` 하나다. URL은 `https://github.com/scroogy-dev/scroogy-agent-skills.git`이다. `resolve-target.sh --remote-url '<그 URL>' --pr 'https://github.com/scroogy-dev/scroogy-agent-skills/pull/139'`가 `github.com/scroogy-dev/scroogy-agent-skills 139`, 종료 코드 0을 냈다.
    - 1단계 조회: `gh pr view '139' --repo 'github.com/scroogy-dev/scroogy-agent-skills' --json number,title,url,body,commits,headRefName,headRefOid,baseRefName,baseRefOid,closingIssuesReferences`. 보관한 `headRefOid`는 `e5f2a0761ae902e54e12a2ba2faa2db28abb2c81`, `baseRefOid`는 `3f50a962871233143daaa3100e5c7c5a340c711f`다.
    - 2단계에서 모은 것: diff(`gh pr diff`, 1685행, 변경 파일 24개), PR 본문(5909자), 커밋 메시지 5개. PR의 커밋 수는 `gh api --hostname 'github.com' 'repos/scroogy-dev/scroogy-agent-skills/pulls/139' --jq .commits`로 얻은 5다. 두 수가 같아 페이지 조회는 하지 않았다. diff를 받은 뒤 다시 조회한 `headRefOid`·`baseRefOid`가 1단계 값과 같았다.
    - 연결 이슈: 본문 참조에서 찾은 번호는 `#138`·`#136`이고 `closingIssuesReferences`는 빈 배열이다. 중복을 빼고 `#138`·`#136`의 본문을 `gh issue view '<번호>' --repo 'github.com/scroogy-dev/scroogy-agent-skills' --json title,body`로 읽었다.
    - 3단계: `git cat-file -e "${sha}^{commit}"`가 종료 코드 0이라 fetch 없이 읽었다(`sha`는 위 `headRefOid`). 대조 줄이 있는 파일을 읽은 명령 `git show "${sha}:.ai/70_ledger/index.md" | grep -n K-0023`의 출력에 대조 줄 `| [K-0023](active/K-0023-check-plan-include-label-trailing-comment.md) | … | 수용 | … |`가 있다. 작업 트리의 같은 행은 `archive/` 경로·`해소(PR #141)` 상태다. `git show "${sha}:.ai/60_codebase/index.md" | grep -n "^| issue-work "`의 출력도 head 판 행이다.
    - 결과([issue-0142-run-pr.md](./issue-0142-run-pr.md)): 승인, 리뷰 포인트 0건. 요약의 `검토 파일: 24개`와 `코드 레벨 검증: 읽은 파일 24개 · 읽지 않은 파일 0개`가 diff의 변경 파일 24개와 맞다. `## PR 본문 대조`에 리뷰어 확인 요청 2항목의 답, AC1~AC9 대조 표(모두 일치(MATCH)), 요약 줄 `충족 9/9`가 있다. 변경 전부터 있던 결함 2건(낮음(LOW) 1건, 정보(INFO) 1건)은 판정 산출에서 뺐다.
    - 전후 기록: [issue-0142-run-pr-before.txt](./issue-0142-run-pr-before.txt)와 [issue-0142-run-pr-after.txt](./issue-0142-run-pr-after.txt)가 같다(`cmp`). 브랜치는 `issue-0142`, `HEAD`는 `b94ce22`이고 `HASH-FAILED` 행이 없다.
  - **다른 저장소 링크**: `resolve-target.sh --remote-url 'https://github.com/scroogy-dev/scroogy-agent-skills.git' --pr 'https://github.com/cli/cli/pull/1'`가 표준 출력 없이 종료 코드 1을 내고 표준 오류에 `resolve-target.sh: PR 링크의 저장소(github.com/cli/cli)가 원격 저장소(github.com/scroogy-dev/scroogy-agent-skills)와 다르다`를 썼다. SKILL.md 1단계대로 리뷰를 시작하지 않고 두 저장소가 다르다는 사실을 알린 뒤 끝냈다. `gh`는 부르지 않았다.
  - **브랜치 모드 수집** (`mktemp -d`로 만든 임시 저장소, 끝난 뒤 삭제)
    - 준비 상태: plan의 준비 명령 뒤 `git status --porcelain` 15행이 plan 표와 같다. 인덱스에만 남은 변경 `MM index-only.txt`, 인덱스에서만 지운 파일 셋 `D  rm-keep.txt`·`?? rm-keep.txt`, `D  rm-edit.txt`·`?? rm-edit.txt`, `D  rm-gone.txt`, 지운 파일과 같은 내용의 새 파일 스테이징 `R  a.txt -> b.txt`·`?? a.txt`, 지운 파일의 실행 권한 변경 `D  tool.sh`·`?? tool.sh`, 표시한 경로 둘 `M  hidden-a.txt`·`M  hidden-s.txt`, 그 밖의 행 ` M edit.txt`·`?? .ai/`·`?? new.txt`다.
    - 필터 사례의 준비 상태: `settings.txt`는 위 출력에 없다. `cat settings.txt`가 `enabled=false`를, `git show 'main:settings.txt'`가 `enabled=true`를 냈다.
    - 2단계: `origin/HEAD`가 없어 base는 `main`이다. `mb="$(git merge-base "$base" HEAD)"`로 보관한 merge-base 커밋의 해시는 `60d8a70226db5848dc7ffbe0264674fe611611ae`다. 헬퍼를 `'<repo>/git-review/scripts/collect-branch-changes.sh' --base "$mb"`로 불렀고 종료 코드 0이며, 표준 출력을 [issue-0142-run-branch.txt](./issue-0142-run-branch.txt)에 그대로 남겼다. `git log "${mb}..HEAD"`는 0행이다(작업 브랜치에 커밋이 없다).
    - 확정한 변경 파일 목록 9행: `M a.txt`, `A b.txt`, `M edit.txt`, `M hidden-a.txt`, `M hidden-s.txt`, `A new.txt`, `M rm-edit.txt`, `D rm-gone.txt`, `M tool.sh`. `.ai/99_workspace/tmp.md`·`index-only.txt`·`rm-keep.txt`는 없다. patch에 `a.txt`·`rm-edit.txt`의 `+changed`, `hidden-a.txt`·`hidden-s.txt`의 `+index only a`·`+index only s`, `tool.sh`의 `old mode 100644`·`new mode 100755`가 있다.
    - 3단계: `collect-branch-changes.sh --marked`가 `h hidden-a.txt`, `S hidden-s.txt`를 냈다. 두 파일은 `git show ":0:${path}"`(`path`는 목록의 경로 그대로)로, 목록에 없는 `settings.txt`는 `git show "${mb}:${path}"`(`mb`는 2단계에서 보관한 해시)로 읽고 출력을 [issue-0142-run-branch-read.txt](./issue-0142-run-branch-read.txt)에 남겼다. 읽은 출력에 대조 줄 `index only a`·`index only s`·`enabled=true`가 있다. 작업 트리의 같은 파일에는 `hidden-a`·`hidden-s`·`enabled=false`만 있다.
- **특이 사항**:
  - PR 모드 실행은 이전 세션이 띄운 하위 에이전트 1개가 맡았다(같은 모델·effort). 세션을 비운 뒤 그 보고를 받아 실행 직후 기록, 결과 사본, 완료 기준 확인을 이어서 했다. 실행 직후 기록은 세션을 재개한 뒤에 남겼다. 재개 직후 scratchpad에 같은 `snap`으로 남긴 기록도 실행 직전 기록과 같았고, 그 사이 작업 저장소의 파일은 바꾸지 않았다.
  - 인자는 PR 링크였다. 같은 원격 URL로 `resolve-target.sh --pr '139'`와 `--pr '#139'`도 `github.com/scroogy-dev/scroogy-agent-skills 139`(종료 코드 0)를 내므로, PR 번호로 실행해도 1단계 조회부터는 같은 값으로 수집한다.
  - 하위 에이전트가 SKILL.md 문장만으로 판단하기 어려웠다고 보고한 점. 절차와 다른 동작은 아니어서 SKILL.md를 고치지 않았다(5번의 보완 대상 아님).
    - 본문 배경에만 나온 `#136`을 연결 이슈로 볼지. 문장 그대로 본문 참조로 보고 읽었으며, AC 대조에는 `#138`만 썼다.
    - PR 모드에서 비즈니스 리뷰의 참조 문서(`.ai/30_contract`·`40_domain`·`50_adr`)를 head와 작업 트리 가운데 어디에서 읽을지. head에서 읽었고, `.ai/10_rules/`의 행위 규칙은 이 실행에 적용할 규칙이라 작업 트리에서 읽었다.
    - 대조 표가 PR 본문 `<details>` 안에 있었고, 요약 줄과 대조 표가 둘 다 있을 때 결과 템플릿에 요약 줄의 자리가 없다. 표 위에 한 줄로 적었다.
    - AC7을 확인하려고 head 판을 `git archive`로 scratchpad에 내보내 러너를 실행했다(`passed: 209, failed: 0`). SKILL.md에 없는 단계이며 작업 트리는 바꾸지 않았다.
    - `gh pr view`의 `commits`는 긴 제목을 `messageHeadline`과 `messageBody`로 나눠 `…`로 잇는다. 개수 대조에는 영향이 없다.
    - zsh에서 `PIPESTATUS`가 비어 같은 명령을 bash로 다시 실행했다. 출력 행은 같았다.
  - 커밋이 100개를 넘는 PR의 페이지 조회와 본문 참조 없이 연결만 된 이슈는 PR #139로 재현되지 않는다(커밋 5개, 연결 조회 빈 배열). 계획대로 SKILL.md 문장과 러너의 `대상 수집 조항` 케이스로 확인한다.
  - 최종 감사 1차 보정(2026-11-21, F-6): 위 PR 모드 실행의 인자가 PR 링크라 spec R1 실제 실행 `[QD]`("PR 번호로 실행하면")와 달랐다. 인자 `139`로 대상 수집 1·2단계를 다시 수행해 [issue-0142-run-pr-log.md](./issue-0142-run-pr-log.md) 끝의 보충 구간에 남겼다(GitHub 읽기 조회만, 실행 전후 `git status --porcelain` 같음). diff 1685행, 변경 파일 24개, 커밋 메시지 5개와 PR 커밋 수 5, 연결 이슈 `#136`·`#138`, 다시 조회한 `headRefOid`·`baseRefOid`가 링크로 한 실행과 같다.

---

### Task 8: 도메인 명세·코드맵 동기화

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5) / Anthropic, Claude Fable 5.2 (claude-fable-5-2)
- **수행 effort**: xhigh / xhigh
- **audit 발견**: 1건
- **보정 반영**: 1건
- **재시도**: 0회
- **수행 내용 요약**: 선행 조건(git-review 본문·헬퍼·템플릿에 커밋하지 않은 변경 없음, 마지막 변경 커밋 `b00dfed`)을 확인한 뒤 문서 넷을 고쳤다. Task 8 완료 기준 `[D]` 두 개와 spec R11 `[D]`가 bash·zsh에서 출력 없이 끝난다.
  - `.ai/40_domain/specs/git-review-output.md`: `## 요건`에 대상 수집(모드, 다른 저장소 중단, PR head 기준 읽기, PR 모드의 문서 부재 시 처리 미수행, 브랜치 모드 대상을 일반 파일과 Git이 스테이징 내용을 정하는 경로로 나눔, 읽기 기준, 입력 속 지시문), PR 본문 대조, 코드 레벨 검증, 발견 처리, 변경 전부터 있던 결함 줄을 더했다. 결과 파일 구조 줄을 새 순서로 고치고 헬퍼 줄 둘을 더했으며 원본 출처에 #142를 더했다. 프론트매터는 그대로다.
  - `.ai/40_domain/index.md`: 명세 행 설명에 대상 수집·PR 본문 대조·코드 레벨 검증·발견 처리를 더했다.
  - `.ai/60_codebase/git-review/review-call-flow.md`: code-map `--local` sync 절차로 What, 호출 흐름 트리, 시퀀스 다이어그램(참여자 git·gh·헬퍼 셋), Why를 다시 썼다. 표지는 `last_synced: 2026-11-21`, `source_hash: 7265afe`다.
  - `.ai/60_codebase/index.md`: git-review 행에 엔트리포인트 인자, 계약, 원장 K-0031, 헬퍼 설명을 더했다. 헬퍼 공통 규약의 산출형 목록에 새 헬퍼 둘을, 태그 현황에 이번 sync 기록을 더하고 표지를 흐름 문서와 같게 고쳤다.
- **특이 사항**:
  - `source_hash`는 git-review 소스를 마지막으로 바꾼 `b00dfed` 대신 그 뒤의 `7265afe`(작업 시점의 `HEAD`)로 두었다. Why 절이 가리키는 ADR 0014의 새 결정 항목(`529a274`)과 원장 K-0031(`89752e1`)까지 반영한 시점이기 때문이다.
  - sync 범위: `4398a41`(색인 표지) 뒤에 바뀐 스킬 소스는 git-review뿐이라 다른 흐름 문서의 표지는 유지했다.
  - 시퀀스 다이어그램은 `;`·`#`가 없음을 명령으로 확인했다. 렌더 도구(`mmdc`)가 없어 렌더는 확인하지 못했다.
  - `issue-work/scripts/check-ledger-links.sh .ai`가 2행을 낸다. 둘 다 이 Task와 무관한 기존 행이다(summary Task 7과 [issue-0142-run-pr-log.md](./issue-0142-run-pr-log.md)가 PR #139 head 판 원장 index 행을 그대로 인용한 `active/K-0023-…` 경로). 이번에 더한 K-0031 링크는 끊긴 것이 없다.
  - git-review-quiz 행에도 원장 K-0032를 연결했다(사용자 요청, 2026-11-21). 퀴즈 흐름 문서의 Why 절에는 연결하지 않았다.
  - 최종 감사 1차 보정(2026-11-21, F-8): 흐름 문서 호출 트리의 `--repo`·`--hostname` 행에 값 자리(`<호스트>/<소유자>/<저장소>`, `<호스트>`)를 넣었다. 같은 보정에서 contents 조회 행과 시퀀스 다이어그램의 응답 줄에 경로 문자 조건(F-3)을, 도메인 명세의 헬퍼 줄에 필터 프로그램의 예외(F-1)를 더했다.
  - 최종 감사 1차 재검토(2026-11-22, `--response`): 흐름 문서 호출 트리의 `git show` 3행에 남은 경로 변수 `${path}`를 SKILL.md와 같은 `${file}`로 고쳤다. 감사 밖에서 찾은 것이라 `audit 발견`에 세지 않는다.
  - 표지 갱신(2026-11-22): 최종 감사 1차 보정을 `22968a8`(git-review 소스)·`54a33bf`(원장 K-0031)로 커밋한 뒤 흐름 문서와 코드맵 index의 `last_synced`를 2026-11-22로, `source_hash`를 `54a33bf`로 고치고 index 태그 현황 기록 맨 앞에 이번 sync를 더했다(`b9d5ebf`). 표지를 원장 커밋으로 둔 이유는 처음 sync(`7265afe`)와 같다. spec R11 `[D]`가 bash·zsh에서 출력 없이 끝난다.
  - 최종 감사 2차 보정(2026-11-22)에 맞춰 흐름 문서 호출 트리의 contents 조회 행과 시퀀스 다이어그램의 응답 줄에 심볼릭 링크 조건(F-11)을, 도메인 명세의 헬퍼 줄에 호출 위치·임시 디렉토리의 보장(F-9·F-10)을 더했다. 시퀀스 다이어그램에 `;`·`#`가 없음을 확인했다. 보정분을 `15c956b`(git-review 소스)로 커밋한 뒤 흐름 문서와 코드맵 index의 `source_hash`를 `15c956b`로 고치고 index 태그 현황 기록 맨 앞에 이번 sync를 더했다(`dee4152`). spec R11 `[D]`가 bash·zsh에서 출력 없이 끝난다.
  - 최종 감사 3차 보정(2026-11-22)에 맞춰 흐름 문서 호출 트리에 트리 조회 행을 더하고, contents 조회 행과 시퀀스 다이어그램의 응답 줄을 모드 조건으로 고쳤다(F-13). 도메인 명세의 헬퍼 줄에 부른 프로그램이 `TMPDIR`에 남기는 파일의 보장을 더했다(F-12). 시퀀스 다이어그램에 `;`·`#`가 없음을 확인했다. 보정분을 `5f602f7`(git-review 소스)로 커밋한 뒤 흐름 문서와 코드맵 index의 `source_hash`를 `5f602f7`로 고치고 index 태그 현황 기록 맨 앞에 이번 sync를 더했다(`b86f7cd`). spec R11 `[D]`가 bash·zsh에서 출력 없이 끝난다. 이번 반영은 Anthropic, Claude Fable 5.2 (claude-fable-5-2), xhigh가 수행했다.
  - 최종 감사 4차 보정(2026-11-22)에 맞춰 도메인 명세의 `resolve-target.sh` 줄에 사유의 입력 값 규칙을 더했다(F-14). 흐름 문서는 호출 순서·인자·종료 코드가 그대로라 고치지 않았다. 보정분을 `09aca45`(git-review 소스)로 커밋한 뒤 흐름 문서와 코드맵 index의 `source_hash`를 `09aca45`로 고치고 index 태그 현황 기록 맨 앞에 이번 sync를 더했다(`48e4469`). spec R11 `[D]`가 bash·zsh에서 출력 없이 끝난다. 이번 반영은 Anthropic, Claude Opus 5.5 (claude-opus-5-5), xhigh가 수행했다.

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

<!--
plan 템플릿의 마지막 고정 Task에 대응하는 블록이다. 삭제하지 말 것.
사용자가 직접 수행하며, 구현 AI는 이 블록을 대신 채우지 않는다.
지표 5종을 두지 않는다 — 수행 모델은 위 `모델 기록` 표의 `최종 audit 모델` 행이 SSoT이고,
audit 발견·보정 반영은 이 Task가 만들어낸 값이라 각 대상 Task 블록에 집계된다.
수행 effort도 같은 행의 `effort` 열이 SSoT다.
-->

- **결과**: 완료
- **수행 내용 요약**: 사용자가 OpenAI, GPT-6.2 Astra (gpt-6.2-astra), high로 최종 감사를 4회 수행했다(리포트 [issue-0142-audit-report-1.md](./issue-0142-audit-report-1.md)·[issue-0142-audit-report-2.md](./issue-0142-audit-report-2.md)·[issue-0142-audit-report-3.md](./issue-0142-audit-report-3.md)·[issue-0142-audit-report.md](./issue-0142-audit-report.md)). 발견은 1차 8건(F-1~F-8), 2차 3건(F-9~F-11), 3차 2건(F-12·F-13, 각각 F-9·F-11의 잔여), 4차 2건(F-14·F-15)으로 모두 15건이다. 판정은 1~3차가 부적합(FAIL), 4차가 조건부 적합(CONDITIONAL)이었고, 4차의 1단계는 61건 모두 충족이었다. 회차마다 `--response`로 검토해 15건을 모두 반영했다. Task 블록 지표는 잔여 2건을 `재시도`로 세어 `audit 발견` 13건·`보정 반영` 13건이다.
- **특이 사항**:
  - 이 블록과 `모델 기록` 표의 `최종 audit 모델` 행은 사용자 요청(2026-11-22)으로 구현 AI(Anthropic, Claude Opus 5.5 (claude-opus-5-5), xhigh)가 리포트 머리말 값을 옮겨 적었다. 감사는 사용자가 수행했다.
  - 4차 보정분(F-14·F-15, `09aca45`·`48e4469`)은 다시 감사하지 않았다. 두 건은 낮음(LOW)이라 기본값이 원장 이관이었고, 사용자가 반영을 골랐다.
  - 범위 밖으로 남긴 것: `git-pr/scripts/verify-submit.sh`와 `git-pr-feedback/scripts/verify-push.sh`도 URL 정규화에 실패하면 원문을 낸다(4차 F-14와 같은 패턴). 원장 K-0033으로 등재했다(2026-11-22, 사용자 결정).
  - 5차 감사는 하지 않기로 했다(2026-11-22, 사용자 결정).
  - plan Task N 작업 내용 1: 4차 보정분 커밋 뒤 spec 완료의 정의 `[D]` 32개가 모두 통과했다(`### 공통`은 repo 전체 러너 13개 1,673건 통과, 나머지 31개는 bash 3.2.57·zsh 5.9에서 출력 없음).
