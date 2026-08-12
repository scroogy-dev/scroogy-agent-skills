# Issue #87 스펙 전체 스킬 번역투 문체 일괄 정비

## 목표 (Goal)

#86에서 확정한 번역투 금지 패턴을 기준으로 repo 상주 문서 전체를 정비하고, 남긴 곳은 예외 목록으로 기록한다.

---

## 범위 (Scope)

**포함 (In)**

- 15개 스킬 디렉토리의 SKILL.md, `templates/`, `references/`
- `.ai/` 하위 repo 문서 (10_rules, 30~70 index·항목, AI-CONTEXT.md), README.md, `.claude/CLAUDE.md`
- 동기화 쌍 정합. ai-workspace 템플릿(shared·dev)과 `.ai/` 사본, issue-work의 workflow 템플릿과 `.ai/90_issues/active/issue-workflow.md`
- 예외 목록 작성(이 이슈 디렉토리의 `issue-0087-exceptions.md`)과 수용 파일의 원장(`70_ledger/`) 등재

**비포함 (Out)**

- 규칙(`writing-principles.md`) 자체의 내용·적용 범위 변경 (#86에서 완료)
- 문서의 내용·구조·산출물 형식 변경. 검증 명령이 문자열로 대조하는 앵커·고정 문구 포함
- `*/tests/` fixture (문구 변경이 테스트 앵커를 깨뜨리며, 이슈 본문의 대상 특정에도 포함되지 않음)
- `.ai/90_issues/` 하위 (이슈 수명주기 산출물이라 일괄 정비 대상에서 뺀다). 템플릿 동기화 목적의 예외 2건만 연다. `issue-workflow.md` 사본, 그리고 #87 plan·summary의 Task 0·N 헤더 4행
- 설치본 재배포 (`install-skills` 재실행은 사용자가 별도 수행)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [x] [D] 스캔 스코프 전체에서 grep 가능한 금지 패턴(em dash `—`, 부정 대조 "가 아니라") 잔존이 예외 목록 등재 건수와 정확히 일치한다 (미등재 잔존 0건). 잔존 건수는 패턴 포함 행 수(`grep -c`) 기준이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  EX=.ai/90_issues/archive/issue-0087/issue-0087-exceptions.md
  find . -name '*.md' -not -path './.git/*' -not -path './.ai/90_issues/*' -not -path '*/tests/*' | sort | while read -r f; do
    p=${f#./}
    for key in emdash negation; do
      if [ "$key" = emdash ]; then n=$(grep -c '—' "$f"); else n=$(grep -c '가 아니라' "$f"); fi
      [ "$n" -eq 0 ] && continue
      a=$(awk -F'|' -v p="$p" -v k="$key" \
        '{f=$2; gsub(/[[:space:]]/,"",f); t=$3; gsub(/[[:space:]]/,"",t); if (f==p && t==k) {c=$4; gsub(/[[:space:]]/,"",c); print c}}' "$EX")
      [ "$n" = "${a:-0}" ] || echo "위반: $p $key 잔존 $n행, 예외 등재 ${a:-0}행"
    done
  done
  ```

  - 설계 주의: 예외 목록 표의 열 순서(파일·패턴·허용 건수·분류·근거)에 의존한다. 표 형식은 Task 1이 고정한다.
  - 스캔 스코프에서 `.ai/90_issues/`를 제외하므로 이 이슈 문서·예외 목록 자체의 패턴 문자열은 오탐이 되지 않는다.
  </details>
- [x] [D] 문체 수정한 파일의 문서 구조(헤더·체크박스·코드 펜스·표 행 수)가 main 대비 불변이다. `70_ledger/`는 수용 등재로 표 행·항목 파일이 정당하게 늘어나므로 제외한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  git diff --name-only main -- '*.md' | grep -vE '^\.ai/(90_issues|70_ledger)/' | while read -r f; do
    for pat in '^#{1,6} ' '^- \[[ x]\]' '^```' '^\|'; do
      old=$(git show "main:$f" 2>/dev/null | grep -cE "$pat")
      new=$(grep -cE "$pat" "$f")
      [ "$old" = "$new" ] || echo "위반: $f 구조 변화 ($pat: $old / $new)"
    done
  done
  ```

  - 설계 주의: 구조 불변의 근사 검증이다. 문장 재작성으로 행이 늘어도 헤더·체크박스·펜스·표 행 수가 유지되면 통과하며, 의미 불변은 아래 [QD] 항목이 담당한다.
  </details>
- [x] [D] 동기화 동일 쌍 10종이 정합하다 (템플릿이 SSoT, 사본과 diff 일치). 상이 쌍 3종(`40_domain/index.md`, `50_adr/index.md`, `70_ledger/index.md`)은 repo 고유 행이 있어 이 검증에서 제외하고 아래 [QD]로 넘긴다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for f in 10_rules/context-loading.md 10_rules/file-change-policy.md 10_rules/writing-principles.md \
           30_contract/index.md 40_domain/glossary.md 60_codebase/index.md 70_ledger/ledger-entry-template.md; do
    diff -q "ai-workspace/templates/shared/.ai/$f" ".ai/$f" >/dev/null || echo "위반: shared/$f 쌍 불일치"
  done
  for f in 10_rules/architecture.md 10_rules/coding-convention.md; do
    diff -q "ai-workspace/templates/dev/.ai/$f" ".ai/$f" >/dev/null || echo "위반: dev/$f 쌍 불일치"
  done
  diff -q issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md >/dev/null \
    || echo "위반: issue-workflow 쌍 불일치"
  ```

  - 설계 주의: `writing-principles-local.md` 사본은 사용자 관리 파일이라 쌍 검증 대상이 아니다.
  </details>
- [x] [D] 예외 목록에서 분류가 `수용`인 행은 전부 원장 항목(`K-<번호>`)을 참조한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  EX=.ai/90_issues/archive/issue-0087/issue-0087-exceptions.md
  grep -E '^\|' "$EX" | awk -F'|' '{c=$5; gsub(/[[:space:]]/,"",c); if (c=="수용") print}' | grep -vE 'K-[0-9]{4}'
  ```

  - 설계 주의: 수용 행이 0건이면 이 검증은 빈 입력으로 그대로 통과한다. 수용 판단 자체의 타당성은 교차모델 audit이 본다.
  </details>
- [ ] [QD] grep으로 못 거르는 패턴 4종(문장 안 수사적 콜론, 관성적 3항 병렬, 영어식 하이픈 합성, 은유·비유 직역)의 잔존이 없거나 예외 목록에 기록되어 있다  (검증: 교차모델 audit이 대상 파일 통독 채점)  ← 강등 사유: 문장 단위 의미 판단이라 명령으로 환원 불가
- [ ] [QD] 수정이 문체에 한정되고 의미·내용 변경이 없으며, 상이 쌍 3종의 공통 서술부가 템플릿과 정합한다  (검증: 교차모델 audit이 diff 통독 채점)  ← 강등 사유: 의미 동등성·부분 정합 판단은 명령으로 환원 불가

---

## 전제 (Assumptions)

- 검사 기준의 SSoT는 `.ai/10_rules/writing-principles.md`(버전 1.1.1)의 "한국어 작성 규칙" 중 표현 소절이다. #86이 확정한 패턴이 이 파일에 반영된 상태라 #86 archive 문서를 다시 읽지 않는다.
- em dash 심사 기준 (Task 0에서 사용자 확인). 수정 대상은 문장 안 삽입구·절 연결(행 끝에서 다음 줄로 잇는 형태 포함)과 헤더 부제 구분자다. 유지 대상은 리스트 항목 라벨 구분자, 표 셀 구분자, 접기 제목 기본형, HTML 주석(SYNCED 마커·템플릿 안내 주석), 코드 펜스 안 리터럴이며 수정하지 않고 예외 목록에 등재만 한다. 헤더 부제를 수정 대상에 넣는 근거는 #86이 규칙 파일 본문에서 같은 판단을 한 선례다.
- HTML 주석 블록(`<!-- -->`) 안은 em dash 유지 대상 규정과 같은 근거(렌더링되지 않는 작성자·AI용 안내)로 패턴 6종 전부에서 심사 대상 밖이다 (1차 audit `--response` 보정으로 지침에 명문화, 2차 audit `--response`에서 사용자 확정). 세부 판정 기준과 이력은 예외 목록(issue-0087-exceptions.md)의 심사 지침이 담는다.
- `code-map/SKILL.md:11`의 "건물·층" 비유 선언은 고치지 않고 예외로 유지한다 (3차 audit `--response`에서 사용자 확정). building·floor가 바로 아래 두 행의 모드 명칭이자 repo 전반이 쓰는 용어라, 낱말을 걷어내면 모드명이 근거를 잃는다. 은유 패턴은 예외 목록 표의 대상(`emdash`·`negation`)이 아니므로 세부 근거와 전수 확인 결과는 예외 목록의 심사 지침 6번이 담는다.
- 기준 시점 실측(2026-08-11, 스캔 스코프 기준). em dash 532행 / 49개 파일, "가 아니라" 18행 / 11개 파일. 유형별로 일반 문단 174행, 리스트 라벨 구분자 152행, 리스트 문장 내부 74행, 표 셀 48행, 코드 펜스 32행, 인용문 19행, HTML 주석 17행, 헤더 부제 10행, 접기 제목 6행이며 위 심사 기준을 적용하면 수정 대상은 약 273행이다. plan 작성 시점 기재값 553행(61개 파일)은 이 실측으로 대체한다.
- issue-work 템플릿의 Task 0·N 헤더 구분자는 수정하고, 진행 중인 #87의 plan·summary 헤더 4행도 같은 문구로 함께 갱신한다 (Task 0에서 사용자 확인). Task N 검증이 plan과 summary의 Task 헤더 집합 일치를 대조하므로 두 파일을 같은 변경에서 바꾼다.
- "가 아니라" 18행은 행별로 심사한다 (Task 0에서 사용자 확인). 실제 오해를 바로잡는 대조는 근거를 적어 예외 등재하고, 습관적 사용만 단언형으로 재작성한다.
- 예외 목록 표의 파일 경로는 백틱 없이 상대 경로 문자열로 적는다 (예: `git-pr/SKILL.md`를 백틱 없이 git-pr/SKILL.md로). 검증 스니펫의 awk 필드 비교가 공백만 제거하므로 백틱이 남으면 대조가 어긋난다.
- 검증 명령·다른 문서가 문자열로 대조하는 앵커와 고정 문구는 바꾸지 않는다 (이슈의 "산출물 형식 불변" 원칙에서 도출). 예: 접기 제목 기본형, 표준 병기 문구 "작성 시점 경로는", summary 지표 필드 표기.
- 동기화 쌍은 템플릿이 SSoT다. 현재 동일한 쌍 10종은 템플릿을 수정한 뒤 사본에 그대로 복사해 동일성을 유지하고, 상이 쌍 3종은 공통 서술부만 정합시킨다. SYNCED 마커 파일(`writing-principles.md`)을 수정하게 되면 버전 주석을 패치 상승한다(1.1.1에서 1.1.2로).
- 패턴 잔존 건수는 패턴 포함 행 수(`grep -c`) 기준으로 세며, 예외 목록의 허용 건수도 같은 기준이다. em dash는 `—` 문자 전체를 세고 공백으로 둘러싼 형태(` — `)로 좁히지 않는다. 기준 시점 532행 중 48행이 행 끝에서 다음 줄로 잇는 형태라 좁히면 그만큼을 놓친다.
- `*/tests/` fixture와 `.ai/90_issues/` 하위는 정비 대상이 아니다. fixture 근거는 [ADR 0001](../../../50_adr/active/0001-skill-deterministic-helper-test-convention.md)의 테스트 동일 위치 배치 규칙이다.
- 정비 후 설치본 재배포(`install-skills` 재실행)는 이 이슈 범위 밖이며 사용자가 별도 수행한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| [.ai/10_rules/writing-principles.md](../../../10_rules/writing-principles.md) | 검사 기준 SSoT (#86 반영본, 동기화 사본) |
| [.ai/10_rules/writing-principles-local.md](../../../10_rules/writing-principles-local.md) | repo 고유 확장 (현재 빈 템플릿, 충돌 시 우선) |
| [.ai/70_ledger/index.md](../../../70_ledger/index.md) | 수용 항목 등재 절차·수명주기 |
| [.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md](../../../50_adr/active/0001-skill-deterministic-helper-test-convention.md) | tests/ 동일 위치 배치·배포 제외 규칙 (tests 제외 판단 근거) |
