# Issue #100 스펙 issue-work·issue-audit: 요구사항 승인 게이트 신설과 계획 감사 모드(--plan)·계획 보정 도입

> 이슈: [#100](https://github.com/scroogy-dev/scroogy-agent-skills/issues/100)

## 목표 (Goal)

spec의 목표·요구사항을 사용자가 승인한 뒤에 완료의 정의·plan을 쓰고, 이슈마다 선택해 구현 전 spec·plan을 타벤더 모델로 감사(issue-audit `--plan`)하고 그 리포트를 issue-work `--response`로 보정할 수 있게 한다. 단계 어휘는 계획 → 구현 → 최종 감사로 통일한다.

---

## 요구사항 (Requirements)

**포함**

- R1: issue-work "새 이슈 시작 시"가 spec의 목표·요구사항(포함·제외)·연관 문서 후보까지 쓴 뒤 사용자 승인을 받고, 승인 후에 완료의 정의·plan·summary를 쓴다. 승인 요청은 spec 경로와 목표 한 줄·포함 목록·제외 목록만 대화에 제시하고, GitHub 이슈 본문에 근거가 없는 요구사항은 따로 표시해 추가 확정·제외 여부를 질의한다.
- R2: issue-work가 계획 종료 게이트 뒤에 계획 감사 수행 여부를 기본값 없이 질의한다. 수행하면 리포트를 `--response`로 검토한 뒤 Task 0으로, 건너뛰면 summary에 생략 사실을 기록하고 Task 0으로 진행한다.
- R3: issue-work `--response`가 계획 감사 리포트(`issue-<번호>-plan-audit-report.md`)를 자동 탐색 대상에 포함하고, 둘 다 있으면 목록으로 선택받으며, 보정 대상이 spec·plan이면 영향 파일 목록에 적고 승인분만 spec·plan에 반영한다. 계획 감사의 발견·보정 건수는 Task 블록이 아니라 summary `모델 기록` 아래 `계획 감사` 줄에 기록한다.
- R4: issue-work 템플릿이 새 절차를 담는다. spec 템플릿 요구사항 주석에 이슈 본문 근거 표기 안내, summary 템플릿 `모델 기록` 표에 `계획 audit 모델` 행(생략 시 `생략`)과 표 아래 `계획 감사` 줄, workflow 템플릿에 계획 감사 검토 시점을 둔다.
- R5: issue-audit에 `--plan` 모드가 있다. 감사 대상은 `active/issue-<번호>/`의 spec·plan, 대조 기준은 GitHub 이슈 본문과 `.ai/30_contract/`·`40_domain/`·`50_adr/`·`70_ledger/`다. 1단계는 이슈 본문 요구 항목 대비 spec 요구사항 대조, 2단계는 추적성·가짜 `[D]` 사전 판별·범위·모호성·과잉 설계 5관점이며, 위험도·처리·판정 산출·원장 대조는 최종 감사와 같은 규칙과 헬퍼를 쓴다. 리포트는 `.ai/99_workspace/issue-<번호>-plan-audit-report.md`에 쓰고 회차 보존 규칙은 최종 감사와 같다. 리포트 템플릿에는 1단계 표의 행이 이슈 본문 요구 항목이 되는 점을 주석으로 둔다.
- R6: 추적성 헬퍼 `issue-audit/scripts/check-plan.sh --trace <spec> <plan>`이 R 없는 DoD 그룹, DoD 없는 R, Task 없는 R, 대상 요구사항 없는 일반 Task를 1행씩 출력하고 종료 코드 1, 통과 시 무출력·종료 코드 0, 사용오류 종료 코드 2를 낸다. `tests/run-tests.sh`에 정상·반례 fixture가 있다.
- R7: `.ai/AI-CONTEXT.md`의 issue-audit scripts 설명 행과 스킬 목록 설명에 계획 감사 모드를 반영한다.
- R8: 용어를 통일한다. summary `모델 기록` 표 행은 `계획 모델`·`계획 audit 모델`·`구현 모델`·`최종 audit 모델` 순서이고, plan의 자기점검 블록은 `계획 종료 게이트`, issue-audit 기본 모드는 `최종 감사`로 부른다. 옛 표기(`설계 모델`, `설계 종료 게이트`, 단독 `audit 모델` 행, `구현 감사`)는 issue-work·issue-audit의 SKILL.md·templates·scripts·tests와 상주 `issue-workflow.md`에 남지 않는다. (이슈 본문 근거 없음. 2026-09-08 대화에서 결정)

**제외**

- 계획 감사 전용 스킬 신설: issue-audit 모드로 둔다 (이슈 본문 비포함)
- spec·plan 템플릿의 `[D]` 검증 명령 접기 제거나 분량 상한: 검증 명령은 audit 근거다 (이슈 본문 비포함)
- 계획 종료 게이트·Task 0의 역할 변경: 전달 손실 점검은 그대로 둔다. 이름만 바꾼다 (이슈 본문 비포함)
- 위험도 매트릭스·축 값·등급별 처리 표 값 변경: 불필요 (이슈 본문 비포함)
- 계획 감사의 자동 실행·수행 여부 자동 판정: 사용자 수동·교차모델·이슈별 선택 원칙 (이슈 본문 비포함)
- 기존 archive 이슈·원장 항목의 옛 용어 소급 치환: 불필요. 이력 문서다 (이슈 본문 비포함)
- git-review-quiz 테스트 fixture의 `설계 종료 게이트` 문구: PR #91 제목 인용이라 이력 표기로 유지
- 가짜 `[D]` 사전 실행의 헬퍼 결정화: 보류. 회귀 방지 예외 표기가 템플릿 변경을 요구해 첫 도입은 감사인 수동 절차로 두고, 결정화는 재검토 조건과 함께 원장에 등재한다 (검토 필요 2 결정, 전제 참조. 2026-09-09 Task 0에서 사용자 승인)
- README.md 스킬 표 갱신: 대체. readme-sync 스킬이 담당하며 이슈 본문 범위(AI-CONTEXT.md) 밖이다
- 계획 감사 발견 건수의 `summarize-metrics.sh` 집계 편입: 보류. 보정률은 구현 Task 축 지표이며 계획 감사 건수는 `계획 감사` 줄 기록으로 충분하다

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

### R1: 요구사항 승인 게이트

- [ ] [D] issue-work SKILL.md "새 이슈 시작 시" 절에 승인 게이트 앵커(`승인`·`목표 한 줄`·`포함 목록`·`제외 목록`·`이슈 본문에 근거가 없는`)가 전부 있고, 승인 전 산출(요구사항)과 승인 후 산출(완료의 정의)의 서술 순서가 그 순서다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  sec="$(sed -n '/^## 새 이슈 시작 시$/,/^## 작업 진행 중$/p' issue-work/SKILL.md)"
  for t in '승인' '목표 한 줄' '포함 목록' '제외 목록' '이슈 본문에 근거가 없는' '전문을 대화에 출력하지 않는다'; do
    printf '%s\n' "$sec" | grep -q -- "$t" || echo "위반: 새 이슈 시작 시 절에 '$t' 없음"
  done
  a="$(printf '%s\n' "$sec" | grep -n '요구사항' | head -1 | cut -d: -f1)"
  b="$(printf '%s\n' "$sec" | grep -n '완료의 정의' | head -1 | cut -d: -f1)"
  [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ] || echo "위반: 요구사항 승인이 완료의 정의 작성보다 앞에 서술되지 않음"
  ```

  - 설계 주의: 절 범위는 `^## 새 이슈 시작 시$`부터 다음 `^## ` 헤더 직전까지다. 헤더 이름을 바꾸면 이 명령도 같이 바꾼다.
  </details>
- [ ] [QD] 승인 요청 제시 형식이 `--clear` 3단계 댓글 승인과 같은 방식(파일 경로 + 요약만, 전문 미출력)으로 읽힌다  (검증: 교차모델 audit 채점)  ← 강등 사유: 형식의 동등성은 서술 의미 판단이라 명령으로 환원 불가

### R2: 계획 감사 수행 여부 질의

- [ ] [D] issue-work SKILL.md에서 계획 종료 게이트 서술 뒤에 계획 감사 질의 서술이 오고, 그 서술에 `기본값`·`생략`·`Task 0`·`--response`·`다른 벤더` 앵커가 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  sec="$(sed -n '/^## 새 이슈 시작 시$/,/^## 작업 진행 중$/p' issue-work/SKILL.md)"
  g="$(printf '%s\n' "$sec" | grep -n '계획 종료 게이트' | head -1 | cut -d: -f1)"
  q="$(printf '%s\n' "$sec" | grep -n '계획 감사' | head -1 | cut -d: -f1)"
  [ -n "$g" ] && [ -n "$q" ] && [ "$g" -lt "$q" ] || echo "위반: 계획 감사 질의가 계획 종료 게이트 뒤에 서술되지 않음"
  after="$(printf '%s\n' "$sec" | awk -v s="${q:-0}" 'NR >= s')"
  for t in '기본값' '생략' 'Task 0' '--response' '다른 벤더'; do
    printf '%s\n' "$after" | grep -q -- "$t" || echo "위반: 계획 감사 질의 서술에 '$t' 없음"
  done
  ```

  </details>

### R3: --response 계획 리포트 탐색·보정

- [ ] [D] issue-work SKILL.md `--response` 절이 번호 단계 5개를 유지하고(기존 러너 스모크), 1단계 범위에 `plan-audit-report`, 5단계 범위에 `spec·plan`과 `계획 감사` 줄 기록 서술이 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  sec="$(sed -n '/^### `--response`/,/^### `--clear`/p' issue-work/SKILL.md)"
  [ "$(printf '%s\n' "$sec" | grep -cE '^  [0-9]+\. \*\*[^*]+\*\*')" = 5 ] || echo '위반: --response 번호 단계가 5개가 아님'
  s1="$(printf '%s\n' "$sec" | awk '/^  1\. /{f=1} /^  2\. /{f=0} f')"
  s5="$(printf '%s\n' "$sec" | awk '/^  5\. /{f=1} f && /^[^[:space:]]/ && !/^  5\. /{f=0} f')"
  printf '%s\n' "$s1" | grep -q 'plan-audit-report' || echo "위반: 1단계 범위에 'plan-audit-report' 없음"
  printf '%s\n' "$s5" | grep -q 'spec·plan'         || echo "위반: 5단계 범위에 'spec·plan' 없음"
  printf '%s\n' "$s5" | grep -q '계획 감사'         || echo "위반: 5단계 범위에 '계획 감사' 없음"
  issue-work/tests/run-tests.sh >/dev/null 2>&1 || echo '위반: issue-work 러너 실패 (--response 스모크 포함)'
  ```

  - 설계 주의: 러너의 `--response` 스모크가 번호 단계 5개와 앵커 토큰을 검사하므로, 이 절에 새 번호 단계를 추가하지 않고 기존 단계의 하위 항목으로 넣는다.
  </details>

### R4: 템플릿 반영

- [ ] [D] spec 템플릿 요구사항 주석에 `이슈 본문` 근거 표기 안내가 있고, summary 템플릿 `모델 기록` 표에 `계획 audit 모델` 행이 정확히 1개, 표 아래 `- **계획 감사**:` 줄이 정확히 1개 있으며, 기존 러너의 템플릿 구조 스모크가 통과한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates
  sed -n '/^## 요구사항 (Requirements)$/,/^## 완료의 정의/p' "$T/issue-spec-template.md" | grep -q '이슈 본문' \
    || echo '위반: spec 템플릿 요구사항 주석에 이슈 본문 근거 안내 없음'
  [ "$(grep -cE '^\| 계획 audit 모델 \|' "$T/issue-summary-template.md")" = 1 ] || echo '위반: summary 템플릿 계획 audit 모델 행이 1개가 아님'
  [ "$(grep -cE '^- \*\*계획 감사\*\*:' "$T/issue-summary-template.md")" = 1 ]   || echo '위반: summary 템플릿 계획 감사 줄이 1개가 아님'
  grep -q '생략' "$T/issue-summary-template.md" || echo '위반: summary 템플릿에 생략 표기 안내 없음'
  grep -q '계획 감사' "$T/issue-workflow-template.md" || echo '위반: workflow 템플릿에 계획 감사 서술 없음'
  issue-work/tests/run-tests.sh >/dev/null 2>&1 || echo '위반: issue-work 러너 실패 (템플릿 구조 스모크 포함)'
  ```

  - 설계 주의: `계획 감사` 줄은 `## 모델 기록` 섹션 안, 첫 `### Task ` 앞에 둔다. Task 블록 안이나 뒤에 두면 `summarize-metrics.sh`의 블록 판정 대상이 된다.
  </details>
- [ ] [D] summary 템플릿에 `계획 감사` 줄을 추가해도 `summarize-metrics.sh`가 표기 위반을 내지 않는다 (생략 값·수행 값 두 fixture)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  M=issue-work/scripts/summarize-metrics.sh
  grep -qE '^- \*\*계획 감사\*\*:' issue-work/templates/issue-summary-template.md || echo '위반: summary 템플릿에 계획 감사 줄 없음 (이 항목의 전제)'
  tmp="$(mktemp -d)"
  sed -e 's/^- \*\*결과\*\*: <!--.*$/- **결과**: 완료/' \
      -e 's/^- \*\*수행 모델\*\*: -$/- **수행 모델**: Anthropic, Claude/' \
      issue-work/templates/issue-summary-template.md > "$tmp/skip.md"
  sed 's/^- \*\*계획 감사\*\*:.*$/- **계획 감사**: 수행 · 발견 2건 · 보정 1건/' "$tmp/skip.md" > "$tmp/run.md"
  for f in "$tmp/skip.md" "$tmp/run.md"; do "$M" "$f" >/dev/null || echo "위반: summarize-metrics.sh 가 $f 에서 실패"; done
  rm -rf "$tmp"
  ```

  - 설계 주의: 헬퍼는 `- **audit 발견**:`처럼 라벨 전체를 대조하므로 `계획 감사` 줄의 숫자를 집계에 섞지 않는다. 이 항목은 그 사실이 유지되는지를 본다.
  </details>

### R5: issue-audit --plan 모드

- [ ] [D] issue-audit SKILL.md에 `--plan` 소절이 정확히 1개 있고, 그 소절에 입력·대조 기준·5관점·판정·리포트 파일명 앵커가 전부 있으며, 리포트 템플릿에 1단계 표 행이 이슈 본문 요구 항목이 된다는 주석이 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  S=issue-audit/SKILL.md
  [ "$(grep -cE '^##+ .*--plan' "$S")" = 1 ] || echo '위반: --plan 소절 헤더가 1개가 아님'
  sec="$(awk '/^##+ .*--plan/{f=1; print; next} f && /^##+ /{f=0} f' "$S")"
  for t in 'GitHub 이슈 본문' '30_contract' '40_domain' '50_adr' '70_ledger' \
           '추적성' '가짜 `\[D\]`' '범위' '모호성' '과잉 설계' \
           'check-plan.sh' 'plan-audit-report' '다른 벤더' '자동 실행' 'Task 0' '최종 감사'; do
    printf '%s\n' "$sec" | grep -qE -- "$t" || echo "위반: --plan 소절에 '$t' 없음"
  done
  grep -q '이슈 본문 요구 항목' issue-audit/templates/issue-audit-report-template.md \
    || echo '위반: 리포트 템플릿에 1단계 행 주석 없음'
  grep -qE '^description: .*(--plan|계획 감사)' "$S" || echo '위반: frontmatter description 에 계획 감사 없음'
  ```

  </details>
- [ ] [QD] `--plan` 소절의 1단계 판정 매핑과 2단계 5관점 서술이 최종 감사 절차와 모순 없이 읽히고, 가짜 `[D]` 사전 판별의 회귀 방지 예외 표시 방법이 서술된다  (검증: 교차모델 audit 채점)  ← 강등 사유: 절차 서술의 정합성은 의미 판단이라 명령으로 환원 불가

### R6: 추적성 헬퍼

- [ ] [D] `check-plan.sh --trace`가 정상 fixture에서 무출력·종료 0, 반례 4종(R 없는 DoD 그룹·DoD 없는 R·Task 없는 R·필드 없는 일반 Task)에서 각 위반 행 출력·종료 1, 파일 누락·모드 미지정에서 종료 2를 내고, 러너가 이를 검사한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  H=issue-audit/scripts/check-plan.sh
  [ -x "$H" ] || echo '위반: check-plan.sh 실행 권한 없음'
  issue-audit/tests/run-tests.sh 2>&1 | grep -E '^NOT OK' ; issue-audit/tests/run-tests.sh >/dev/null 2>&1 || echo '위반: issue-audit 러너 실패'
  for t in 'trace: 정상' 'R 없는 DoD' 'DoD 없는 R' 'Task 없는 R' '필드 없는 일반 Task' 'exit 2'; do
    issue-audit/tests/run-tests.sh 2>/dev/null | grep -q -- "$t" || echo "위반: 러너에 '$t' 케이스 없음"
  done
  "$H" --trace 2>/dev/null; [ $? -eq 2 ] || echo '위반: 인자 누락이 exit 2 가 아님'
  "$H" 2>/dev/null;         [ $? -eq 2 ] || echo '위반: 모드 미지정이 exit 2 가 아님'
  ```

  - 설계 주의: 러너 케이스 이름의 앵커 문구는 Task 5에서 정한 값을 그대로 쓴다. 문구를 바꾸면 이 명령도 같이 바꾼다.
  </details>
- [ ] [D] 이 이슈의 spec·plan 자체가 `check-plan.sh --trace`를 통과한다 (헬퍼의 첫 실사용 검증)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  issue-audit/scripts/check-plan.sh --trace \
    .ai/90_issues/active/issue-0100/issue-0100-spec.md \
    .ai/90_issues/active/issue-0100/issue-0100-plan.md
  ```

  </details>

### R7: 안내도 정합

- [ ] [D] `.ai/AI-CONTEXT.md`의 issue-audit scripts 행에 `check-plan.sh`가, 스킬 목록 행에 계획 감사가 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  A=.ai/AI-CONTEXT.md
  awk '/^├── issue-audit\//{f=1} f && /scripts\//{print; exit}' "$A" | grep -q 'check-plan.sh' || echo '위반: 디렉토리 구조 scripts 행에 check-plan.sh 없음'
  grep -E '^\| `issue-audit` \|' "$A" | grep -q '계획' || echo '위반: 스킬 목록 issue-audit 행에 계획 감사 없음'
  ```

  </details>

### R8: 용어 통일

- [ ] [D] 옛 표기가 issue-work·issue-audit 스킬 파일과 상주 `issue-workflow.md`, 이 이슈의 plan·summary에 0건이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -rnE '설계 모델|설계 종료 게이트|`audit 모델`|\| audit 모델 \||설계·구현·audit|구현 감사' \
    issue-work issue-audit .ai/AI-CONTEXT.md .ai/90_issues/active/issue-workflow.md \
    .ai/90_issues/active/issue-0100/issue-0100-plan.md .ai/90_issues/active/issue-0100/issue-0100-summary.md
  ```

  - 설계 주의: 이 spec은 개명 대응표를 담아 옛 표기가 남으므로 검색 대상에서 뺀다. `설계 주의`·`과잉 설계`는 다른 뜻이라 패턴에 넣지 않는다.
  </details>
- [ ] [D] 새 표기가 정확히 자리한다. summary 템플릿 표 행 4개가 `계획 모델`·`계획 audit 모델`·`구현 모델`·`최종 audit 모델` 순서로 1개씩, plan 템플릿에 `## 계획 종료 게이트 (고정)` 헤더 1개, `check-clear.sh` 미완료 메시지에 `계획 종료 게이트`, issue-audit SKILL.md에 `최종 감사`, 이 이슈 plan 헤더·summary 행도 같은 표기다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates
  rows="$(grep -E '^\| (계획 모델|계획 audit 모델|구현 모델|최종 audit 모델) \|' "$T/issue-summary-template.md" | sed -E 's/^\| ([^|]+) \|.*/\1/')"
  [ "$rows" = "$(printf '계획 모델\n계획 audit 모델\n구현 모델\n최종 audit 모델')" ] || echo "위반: summary 템플릿 표 행 순서·개수 불일치 — [$(printf '%s' "$rows" | tr '\n' ',')]"
  [ "$(grep -c '^## 계획 종료 게이트 (고정)$' "$T/issue-plan-template.md")" = 1 ] || echo '위반: plan 템플릿 계획 종료 게이트 헤더가 1개가 아님'
  grep -q '계획 종료 게이트' issue-work/scripts/check-clear.sh || echo '위반: check-clear.sh 메시지에 계획 종료 게이트 없음'
  grep -q '최종 감사' issue-audit/SKILL.md || echo '위반: issue-audit SKILL.md 에 최종 감사 호칭 없음'
  grep -q '^## 계획 종료 게이트 (고정)$' .ai/90_issues/active/issue-0100/issue-0100-plan.md || echo '위반: 이 이슈 plan 게이트 헤더가 새 표기가 아님'
  for r in '계획 모델' '계획 audit 모델' '구현 모델' '최종 audit 모델'; do
    grep -qE "^\| $r \|" .ai/90_issues/active/issue-0100/issue-0100-summary.md || echo "위반: 이 이슈 summary 에 '$r' 행 없음"
  done
  ```

  </details>

### 공통

- [ ] [D] repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목: 구현 전에도 통과한다)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D] 변경한 md 파일에 줄 끝 공백이 없다 (두 칸 강제 개행 제외, 회귀 방지 항목: 구현 전에도 통과한다)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  git diff --name-only main -- '*.md' | xargs grep -nE ' +$' 2>/dev/null | grep -vE '  $'
  ```

  </details>

---

## 전제 (Assumptions)

- 용어 (2026-09-08 사용자 결정): issue-work가 만드는 spec·plan은 설계가 아니라 계획이다. 단계 어휘는 계획 → 구현 → 최종 감사이며, 모델 행은 `계획 모델`(spec·plan을 쓴 모델)·`계획 audit 모델`·`구현 모델`·`최종 audit 모델`(구현만이 아니라 이슈 전체를 검증하므로 "최종")이다. 옛 표기 `설계 모델`은 `계획 모델`로 개명하고 행을 추가하지 않는다. `설계 종료 게이트`는 `계획 종료 게이트`로, issue-audit 기본 모드는 `최종 감사`로 부른다.
- 검토 필요 1(기록 위치, 2026-09-08 사용자 확인): summary `모델 기록` 표에 `계획 audit 모델` 행을 신설한다. 발견·보정 건수와 생략 여부는 표 바로 아래 `- **계획 감사**: 생략` 또는 `- **계획 감사**: 수행 · 발견 N건 · 보정 N건` 한 줄에 적는다. plan 게이트 블록 기록은 버렸다. plan은 감사 대상 문서라 보정 시 대상과 기록이 섞이고, 벤더 상이 대조([QD])가 `모델 기록` 표 한 곳에서 이뤄지는 편이 낫기 때문이다.
- 검토 필요 2(가짜 `[D]` 결정화): 첫 도입은 감사인 수동 절차다. 결정화는 제외 목록에 두고, 이슈 완료 시 원장 `.ai/70_ledger/`에 기술부채로 등재한다(재검토 조건: 계획 감사 2회 이상에서 가짜 `[D]` 판별 결과가 감사 모델 간에 갈린 사례 관측 시, 또는 spec·plan 템플릿에 회귀 방지 예외 표기가 도입될 때). 2026-09-09 Task 0에서 사용자가 승인했다.
- 검토 필요 3(모드 이름): `--plan`을 유지한다. 최종 감사가 기본 모드다. 2026-09-09 Task 0에서 사용자가 승인했다.
- 발견 번호 축 분리: 계획 감사 리포트(`issue-<번호>-plan-audit-report*.md`)와 최종 감사 리포트(`issue-<번호>-audit-report*.md`)는 `F-` 번호를 따로 센다. 최종 감사가 `next-finding-number.sh`에 넘기는 글롭 `issue-<번호>-audit-report*.md`가 계획 리포트 이름과 겹치지 않아 자연 분리된다.
- `--response` 러너 계약: issue-work 러너의 `--response` 스모크가 번호 단계 정확히 5개와 앵커 토큰을 검사한다. 계획 리포트 탐색·spec·plan 보정은 기존 1·5단계의 하위 항목으로 넣고 새 번호 단계를 만들지 않는다.
- 게이트 개명의 판정 영향: `check-clear.sh --completion`은 `점검 완료` 체크박스 행만 세므로 게이트 헤더 개명은 판정 로직을 바꾸지 않는다. 바뀌는 것은 메시지 문구와 러너의 대조 문자열이다.
- 헬퍼 배치: 추적성 헬퍼는 issue-audit 소속이다(감사 도구). issue-work 러너에 이미 있는 템플릿 구조 검사 awk와 판정이 겹치지만 스킬 독립성 원칙상 공유하지 않는다.
- 헬퍼가 읽는 앵커: spec은 `**포함**` 아래 `- R<n>: ` 항목과 `### R<n>: ` DoD 그룹(`### 공통`은 R이 아니다), plan은 `### Task ` 블록과 `- **대상 요구사항**: R<n>[, R<m>]` 필드다. 고정 Task는 `### Task 0 (고정)`·`### Task N (고정)` 두 헤더만이며 필드 검사에서 제외한다.
- 이 이슈의 절차: 요구사항 승인은 2026-09-08 대화로 받았다. 계획 감사는 `--plan` 모드가 이 이슈의 산출물이라 `생략`으로 기록한다(2026-09-09 Task 0에서 생략 유지 확인). 새 절차의 첫 온전한 적용 대상은 다음 이슈다.
- 이슈 본문 근거 없는 추가 항목(2026-09-09 Task 0에서 포함 유지 확인): summary 템플릿의 `계획 감사` 줄(R3·R4)과 workflow 템플릿의 계획 감사 검토 시점 한 줄(R4)은 이슈 본문에 없으나 검토 필요 1 결정(기록 위치)의 직접 결과라 포함한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/10_rules/architecture.md` | 헬퍼 분리 판단 체크리스트·역할 분담 (check-plan.sh 신설 근거) |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 헬퍼 테스트 동일 위치 배치·배포 제외 |
| `.ai/70_ledger/index.md` | `--plan` 원장 대조 규칙의 참조처, 가짜 `[D]` 결정화 보류 항목 등재 대상 |
| `.ai/10_rules/writing-principles.md` | SKILL.md·템플릿 서술 원칙 |
