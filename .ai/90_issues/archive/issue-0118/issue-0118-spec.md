# Issue #118 스펙 doc 프로파일 운영 보강: 문서 규약 파일·SSoT 대상 범위·로비와 건물 repo의 SSoT 선언·리뷰 카테고리 doc 세트·보류 항목 원장 등재

## 목표 (Goal)

doc 프로파일 repo 운영 전에 #114의 SSoT 선언 구조에서 비어 있는 곳(문서 규약 파일, SSoT 대상 범위, 로비와 건물 repo 선언, 리뷰·감사·퀴즈 카테고리, 보류 항목 기록 경로, 결정 기록)을 채워 스킬이 doc repo에서 어긋남 없이 동작하게 한다.

---

## 요구사항 (Requirements)

**포함**

- R1: doc 프로파일로 `ai-workspace` init하면 `.ai/10_rules/document-convention.md` 골격이 생기고 doc 템플릿 `## 프로젝트 규칙` 표에 그 행이 있다. 골격 칸은 SSoT 대상 확장자(기본 `.md`), 첨부 분류(기본값 없이 repo가 채움), 근거 출처와 원본 문서 사이 우선순위, 파일·디렉토리 명명이다. 사용자 관리 파일이라 update는 없을 때만 복사한다(`coding-convention.md`와 같은 정책).
- R2: `writing-principles.md` 적용 범위의 제외 줄에 "doc 프로파일의 `ssot_dir` 문서는 `document-convention.md`를 따른다"가 이어지고, 버전 고정 파일의 버전이 올라간다. shared 템플릿 원본과 이 repo 사본이 같다.
- R3: SSoT 대상이 "`ssot_dir` 아래 `.md` 파일"로 확정된다. code-map `references/doc.md`(1-1 스캔 범위·1-2 색인 단위·fixture), context-harvest `SKILL.md`, doc 템플릿 `ssot_dir` 안내 주석, 정책 `ssot-and-router-principle.md`가 같은 정의와 "다른 확장자·첨부의 분류는 repo 문서 규약 파일이 정한다"는 위임 문장을 담는다. 첨부는 색인 행을 따로 만들지 않고 참조하는 md 행에 딸린다.
- R4: 로비 본문 2번째 줄이 특정 SSoT 값을 선언하지 않는 문구로 바뀐다. 리터럴은 `> SSoT: 각 repo 안내도의 선언을 따른다. 이 파일은 라우터일 뿐 진실의 원천이 아니다.`로 확정한다 (이슈 본문 후보, 2026-10-24 승인으로 확정). `check-lobby.sh`는 새 문구 로비를 통과시키고 구 문구(`> SSoT: 소스 코드. …`) 로비를 격추하며 `ai-workspace-directory/tests/`에 두 케이스가 있다. `SKILL.md` 검사 표·update-2단계, `references/` 규격·체크리스트·예시, fixture가 새 문구로 맞춰지고 `ai-workspace-directory/` 안에 구 로비 문구가 남지 않는다.
- R5: 로비 규격의 충돌 우선순위가 `각 repo의 SSoT(repo 안내도 선언: 소스 코드 또는 원본 문서) > 각 repo 안내도 > 이 안내도`가 된다. `placeholder` 분기는 "선언을 찾지 못하므로 소스 코드로 폴백한다"로 적고 문서 repo이면 `ai-workspace doc` init을 권한다. 정책 `ssot-and-router-principle.md`와 `specs/ai-workspace.md`의 로비 서술을 맞춘다.
- R6: code-map 건물 repo(`.ai/60_codebase/repository.yaml` 존재)의 SSoT 선언 규칙이 정해진다. `소스 코드`로 선언하고, SSoT는 `repository.yaml`에 등록한 대상 repo의 소스 코드이며 건물 repo 안에는 없다고 `references/global.md`와 건물 안내도에 적는다. 선언 허용 값은 그대로다 (이슈 본문 후보 (가)·(나) 중 (가), 2026-10-24 승인으로 확정). ai-workspace update는 `repository.yaml`이 있는데 선언이 이 규칙과 다르면 보고만 하고 자동 전환하지 않는다.
- R7: code-map `--global` 0단계가 대상 repo 안내도의 선언을 읽어 `원본 문서` repo를 서비스 간 호출 식별에서 빼고 건물 안내도에 문서 repo로 표시한다. 건물 repo에서 `--local`을 실행하면 건물 안내도를 덮어쓰지 않도록 멈추고 `--global`을 안내한다. context-harvest의 다음 단계 안내는 건물 repo에서 `--local sync`를 권하지 않는다.
- R8: git-review·issue-audit·git-review-quiz는 SSoT 선언이 `원본 문서`이면 doc 카테고리 세트를, `소스 코드`이거나 선언이 없으면 기존 7종을 쓴다. doc 세트는 개수 7과 순서를 유지해 세 스킬에서 같은 이름이고, 결과 템플릿의 카테고리 행 이름만 선언에 따라 바뀐다. 대응표는 이슈 본문 후보표(기능→내용 정확성, 아키텍처→구조 정합, 버그→모순·누락, 보안→보안·민감정보, 코드품질→가독성·일관성, 성능→최신성, 테스트→근거 검증)로 확정한다 (2026-10-24 승인으로 확정). `specs/git-review-output.md`·ADR 0014를 맞춘다.
- R9: issue-work 이슈 완료 시 spec 제외 항목 중 사유가 `보류`인 항목을 보여 주고 원장 등재 여부를 묻는다(권고·승인형). 등재하면 출처는 `이슈 #N`이고 수용 사유·재검토 조건을 필수로 적는다. 원장 등재 주체 문장(이 repo와 shared 템플릿의 `70_ledger/index.md`·`ledger-entry-template.md`)에 이 경로가 추가되고 `specs/issue-workflow.md`·ADR 0007·0018이 맞춰진다.
- R10: 이 이슈의 제외 항목 중 `보류` 2건(퍼블리싱 스킬·퍼블리시 기록·위키 직접 수정 탐지, 선언 깨짐 시 경고 없는 폴백)을 R9 경로로 질의하고, 승인한 퍼블리싱 항목 1건을 원장에 등재해 첫 적용으로 삼는다. 폴백 항목은 질의에서 등재하지 않기로 했다 (2026-10-24 Task 7 질의). 이후 이슈 완료 시(`--clear` 4단계) 질의에서 다시 정해 K-0015로 등재했다 (2026-10-25).
- R11: ADR 0020이 `50_adr/active/`에 있고 `50_adr/index.md`에 행이 있다. 결정 1은 doc SSoT는 repo 지정 디렉토리의 원본 문서이며, 기각 대안(위키 원본·page ID 추적, 2026-10-20 초안)과 기각 이유(PR diff와 감사가 원본을 보지 못함, 외부 조회 필요)를 남긴다. 결정 2는 퍼블리싱 실행·동기화·위키 직접 수정 대응을 스킬 범위 밖에 두고 프롬프트로 경험을 쌓은 뒤 스킬화를 다시 판단하며, 재검토 조건은 원장 항목(R10)에 둔다.

**제외**

- 퍼블리싱 스킬·퍼블리시 기록·위키 직접 수정 탐지: 보류. 운영 경험을 쌓은 뒤 스킬화한다. R10으로 원장 K-0014에 등재한다 (재검토 조건 예: 퍼블리싱을 스킬로 만들기로 할 때, 위키 직접 수정이 SSoT와 어긋난 사례가 나올 때).
- 선언이 깨졌을 때 경고 없는 폴백 보강: 보류. 8곳에 복제된 문구를 바꿔야 하는데 발생 확률이 낮다. Task 7 질의에서는 등재하지 않았고 (2026-10-24), `--clear` 질의에서 원장 K-0015에 등재했다 (2026-10-25).
- 로비 `Repos` 표에 repo별 SSoT 종류 열 추가: 불필요. repo 안내도의 선언과 중복돼 어긋날 수 있다. 에이전트는 repo에 진입할 때 repo 안내도에서 선언을 읽는다.
- 건물 repo용 새 선언 값 신설(이슈 본문 후보 (나)): 대체. R6의 (가)로 갈음한다. 선언을 읽는 8곳과 `check-context.sh`를 함께 바꿔야 한다.
- 첨부(이미지·PDF) 분류의 스킬 표준 결정: 대체. 스킬 표준은 `.md` 확정까지만 정하고 분류는 repo 문서 규약 파일(R1)에 맡긴다 (이슈 결정 2026-10-24).
- 기존 로비의 이행 절차: 불필요. ai-workspace-directory update-2단계가 비표준 문구를 표준 문구로 교체한다.
- `classify-risk.sh` 변경: 불필요. 카테고리 이름을 다루지 않는다.
- git-qa의 doc 대응: 불필요. 문서 repo에 해당하지 않는다.
- dev 프로파일 동작·dev 전용 템플릿·코드 카테고리 7종 변경: 없음. 회귀 방지 항목으로 보장한다.

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

모든 검증 명령은 repo 루트에서 실행한다.

### R1: doc 문서 규약 파일

- [ ] [D]  doc 템플릿에 `10_rules/document-convention.md` 골격(H2 4칸)이 있고 doc 안내도 `## 프로젝트 규칙` 표에 그 행이 있으며 dev 안내도 표에는 없다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=ai-workspace/templates/doc/.ai/10_rules/document-convention.md
  T=ai-workspace/templates/doc/.ai/AI-CONTEXT.md
  D=ai-workspace/templates/dev/.ai/AI-CONTEXT.md
  [ -f "$F" ] || echo '위반: document-convention.md 템플릿 없음'
  [ -f "$F" ] && [ "$(grep -cE '^## ' "$F")" -eq 4 ] || echo '위반: H2 4칸 아님'
  for k in '확장자' '첨부' '우선순위' '명명'; do
    [ -f "$F" ] && grep -qE "^## .*$k" "$F" || echo "위반: H2 '$k' 칸 없음"
  done
  rules_rows() { awk '/^## 프로젝트 규칙/ { f = 1; next } f && /^## / { exit } f && /^\|/' "$1"; }
  [ "$(rules_rows "$T" | grep -c 'document-convention.md')" -eq 1 ] || echo '위반: doc 안내도 규칙 표에 행 1개 아님'
  [ "$(rules_rows "$D" | grep -c 'document-convention.md')" -eq 0 ] || echo '위반: dev 안내도 규칙 표에 행 있음'
  ```

  - 설계 주의: 행 존재는 `## 프로젝트 규칙` 섹션 안의 표 행만 센다. 파일 전체 grep은 주석 안내문으로도 통과한다.
  </details>
- [ ] [D]  ai-workspace `SKILL.md`의 init 전용 파일 목록에 doc 전용으로 `document-convention.md`가 있고, update-1단계 코드 블록에 "없을 때만 복사" 분기가 정확히 1개 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=ai-workspace/SKILL.md
  grep -qE '^- `doc` 전용: .*`\.ai/10_rules/document-convention\.md`' "$S" || echo '위반: init doc 전용 목록'
  [ "$(grep -cF '[ ! -f .ai/10_rules/document-convention.md ]' "$S")" -eq 1 ] || echo '위반: update-1 없을 때만 복사 분기 1개 아님'
  grep -qE '^사용자가 작성한 파일\(.*document-convention\.md' "$S" || echo '위반: update-1 사용자 작성 파일 목록'
  ```

  </details>
- [ ] [D]  ai-workspace 테스트가 doc 템플릿의 문서 규약 행·파일 케이스(통과 1·격추 1 이상)를 실행해 0 실패로 통과한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  R=ai-workspace/tests/run-tests.sh
  out=$("$R" 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*문서 규약.* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*문서 규약.* 격추')" -ge 1 ] \
    || echo '위반: 테스트 실패 또는 문서 규약 케이스(통과·격추 각 1 이상) 미실행'
  ```

  </details>
- [ ] [QD] 골격 4칸의 안내 주석이 repo가 채울 내용(확장자 기본값 `.md`, 첨부를 SSoT·출처·파생물 중 어디로 볼지, 근거 출처와 원본 문서 사이 우선순위, 명명)을 설명한다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 안내문의 충분성은 의미 판단이라 명령으로 환원 불가

### R2: writing-principles 위임 문장

- [ ] [D]  shared `writing-principles.md` 적용 범위의 제외 줄에 `document-convention.md` 위임이 있고 버전이 `1.2.0`이며 이 repo 사본과 같다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  W=ai-workspace/templates/shared/.ai/10_rules/writing-principles.md
  awk '/^## 적용 범위/ { f = 1; next } f && /^## / { exit } f' "$W" \
    | grep -E '^- \*\*제외\*\*:' | grep -q 'document-convention.md' || echo '위반: 제외 줄에 위임 문장 없음'
  grep -qE '^<!-- 버전: 1\.2\.0 -->$' "$W" || echo '위반: 버전 1.2.0 아님'
  diff -q "$W" .ai/10_rules/writing-principles.md >/dev/null || echo '위반: 이 repo 사본 불일치'
  ```

  </details>

### R3: SSoT 대상 `.md` 확정

- [ ] [D]  code-map `references/doc.md`의 색인 대상 정의·1-1 스캔 범위·1-2 색인 단위가 `.md` 파일을 가리키고, 규약 위임과 첨부 딸림 문장이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  F=code-map/references/doc.md
  grep -qE '^- 색인 대상은 .*`\.md` 파일' "$F" || echo '위반: 색인 대상 정의에 .md 없음'
  grep -q 'document-convention.md' "$F" || echo '위반: 규약 위임 문장 없음'
  grep -qE '첨부.*색인 행.*(만들지 않|딸린)' "$F" || echo '위반: 첨부 딸림 문장 없음'
  awk '/^\*\*1-1\./ { f = 1 } /^\*\*1-2\./ { f = 0 } f' "$F" | grep -q '`\.md`' || echo '위반: 1-1 스캔 범위에 .md 없음'
  awk '/^\*\*1-2\./ { f = 1 } /^\*\*1-3\./ || /^### / { f = 0 } f' "$F" | grep -qE '^- `\.md` 파일 1개가 색인 행 1개' || echo '위반: 1-2 색인 단위'
  ```

  </details>
- [ ] [D]  context-harvest `SKILL.md` SSoT 원칙 절, doc 템플릿 `ssot_dir` 안내 주석, 정책 문서가 `.md` 파일 정의와 규약 위임을 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  C=context-harvest/SKILL.md
  T=ai-workspace/templates/doc/.ai/AI-CONTEXT.md
  P=.ai/40_domain/policies/local/ssot-and-router-principle.md
  awk '/^### SSoT 원칙 유지/ { f = 1; next } f && /^#{2,3} / { exit } f' "$C" | grep -qE '`ssot_dir` 아래 `\.md` 파일' || echo '위반: context-harvest .md 정의'
  grep -q 'document-convention.md' "$C" || echo '위반: context-harvest 규약 위임'
  grep -qE '^`ssot_dir`은 필수입니다\. .*`\.md` 파일' "$T" || echo '위반: doc 템플릿 ssot_dir 주석 .md'
  grep -q 'document-convention.md' "$T" || echo '위반: doc 템플릿 규약 위임'
  grep -qE '`ssot_dir` 아래 `\.md` 파일' "$P" || echo '위반: 정책 .md 정의'
  grep -q 'document-convention.md' "$P" || echo '위반: 정책 규약 위임'
  ```

  </details>
- [ ] [D]  code-map·context-harvest 테스트가 `.md` 정의·첨부 딸림 격추 케이스를 실행해 0 실패로 통과한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(code-map/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*\.md 정의.* 격추')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*첨부.* 격추')" -ge 1 ] \
    || echo '위반: code-map 테스트 실패 또는 .md 정의·첨부 격추 케이스 미실행'
  out=$(context-harvest/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*\.md 정의.* 격추')" -ge 1 ] \
    || echo '위반: context-harvest 테스트 실패 또는 .md 정의 격추 케이스 미실행'
  ```

  </details>

### R4: 로비 SSoT 선언 문구

- [ ] [D]  `check-lobby.sh`의 `SSOT_LINE`이 새 문구이고, `ai-workspace-directory/`에서 `tests/`를 제외하면 구 문구(`> SSoT: 소스 코드.`)가 0건이며, 규격·체크리스트·`SKILL.md`·예시·fixture에 새 문구가 각 1건 이상 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  NEW='> SSoT: 각 repo 안내도의 선언을 따른다. 이 파일은 라우터일 뿐 진실의 원천이 아니다.'
  D=ai-workspace-directory
  grep -qF "SSOT_LINE='$NEW'" "$D/scripts/check-lobby.sh" || echo '위반: 헬퍼 상수가 새 문구 아님'
  [ "$(grep -rF '> SSoT: 소스 코드.' "$D" --exclude-dir=tests | wc -l | tr -d ' ')" -eq 0 ] || echo '위반: 구 문구 잔존(tests 제외)'
  for f in "$D/references/standard-structure.md" "$D/references/ssot-checklist.md" "$D/SKILL.md" "$D/references/examples.md" "$D/tests/fixtures/lobby-good.md"; do
    [ "$(grep -cF "$NEW" "$f")" -ge 1 ] || echo "위반: $f 에 새 문구 없음"
  done
  ```

  - 설계 주의: 구 문구는 `tests/run-tests.sh`의 격추 입력으로만 남는다. 그래서 잔존 검사는 `tests/`를 제외한다.
  </details>
- [ ] [D]  ai-workspace-directory 테스트가 새 문구 fixture 통과와 구 문구 격추 케이스를 실행해 0 실패로 통과한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  R=ai-workspace-directory/tests/run-tests.sh
  out=$("$R" 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 정상 fixture 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*구 문구.* 격추')" -ge 1 ] \
    || echo '위반: 테스트 실패 또는 새 문구 통과·구 문구 격추 케이스 미실행'
  ```

  - 설계 주의: 러너는 기대 SSoT 문구를 `standard-structure.md` 골격에서 추출한다. 골격·헬퍼·fixture 중 한쪽만 바뀌면 "fixture 정합" 검사가 먹는다.
  </details>

### R5: 로비 충돌 우선순위·placeholder 폴백

- [ ] [D]  `ai-workspace-directory/`에 구 우선순위(`소스 코드 > 각 repo 안내도`)와 `소스 코드만 SSoT`가 0건이고, 규격·예시·fixture·`SKILL.md`의 우선순위 행에 `원본 문서`가 있으며, 규격·fixture의 `placeholder` 분기에 폴백과 `ai-workspace doc` 권고가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  D=ai-workspace-directory
  [ "$(grep -rF '소스 코드 > 각 repo 안내도' "$D" | wc -l | tr -d ' ')" -eq 0 ] || echo '위반: 구 우선순위 잔존'
  [ "$(grep -rF '소스 코드만 SSoT' "$D" | wc -l | tr -d ' ')" -eq 0 ] || echo '위반: placeholder 구 문구 잔존'
  for f in "$D/references/standard-structure.md" "$D/references/examples.md" "$D/tests/fixtures/lobby-good.md" "$D/SKILL.md"; do
    grep -qE '우선순위.*원본 문서' "$f" || echo "위반: $f 우선순위 행에 원본 문서 없음"
  done
  for f in "$D/references/standard-structure.md" "$D/tests/fixtures/lobby-good.md"; do
    grep -qE '`placeholder` → .*폴백' "$f" || echo "위반: $f placeholder 분기에 폴백 없음"
    grep -qE '`placeholder` → .*ai-workspace doc' "$f" || echo "위반: $f placeholder 분기에 doc init 권고 없음"
  done
  ```

  </details>
- [ ] [D]  정책 `ssot-and-router-principle.md`에 로비가 SSoT 값을 선언하지 않고 각 repo 안내도의 선언을 따른다는 문장이, `specs/ai-workspace.md`에 로비 2번째 줄 문구 서술이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -qE '로비.*각 repo 안내도의 선언을 따른다' .ai/40_domain/policies/local/ssot-and-router-principle.md || echo '위반: 정책 로비 선언 문장'
  grep -qE '로비.*각 repo 안내도의 선언을 따른다' .ai/40_domain/specs/ai-workspace.md || echo '위반: 명세 로비 문구 서술'
  ```

  </details>

### R6: 건물 repo SSoT 선언 규칙

- [ ] [D]  `references/global.md` 전제 조건 절에 `소스 코드` 선언 규칙과 "이 리포 안에는 없다" 문장이 있고, 3단계 건물 안내도 예시에 SSoT 문장이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  G=code-map/references/global.md
  pre="$(awk '/^## 전제 조건/ { f = 1; next } f && /^## / { exit } f' "$G")"
  printf '%s\n' "$pre" | grep -qE 'SSoT 선언.*`소스 코드`' || echo '위반: 전제 조건 선언 규칙 없음'
  printf '%s\n' "$pre" | grep -qE '이 리포 안에는 없' || echo '위반: 전제 조건 "이 리포 안에는 없다" 없음'
  awk '/^### 3단계/ { f = 1 } /^### 4단계/ { f = 0 } f' "$G" | grep -qE '^> SSoT' || echo '위반: 건물 안내도 예시 SSoT 문장 없음'
  ```

  </details>
- [ ] [D]  ai-workspace 멱등 보강 검사 표에 `repository.yaml` 행이 있고, `check-context.sh`가 `repository.yaml` 존재 + doc 표준 문구를 보고하며 dev 문구는 보고하지 않는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=ai-workspace/SKILL.md
  C=ai-workspace/scripts/check-context.sh
  awk '/^#### 멱등 보강 검사/ { f = 1; next } f && /^#### / { exit } f && /^\|/' "$S" | grep -q 'repository.yaml' || echo '위반: 검사 표에 repository.yaml 행 없음'
  tmp="$(mktemp -d)"; mkdir -p "$tmp/.ai/60_codebase"; : > "$tmp/.ai/60_codebase/repository.yaml"
  today="$(date +%Y-%m-%d)"
  sed "s/^> last updated: YYYY-MM-DD$/> last updated: $today/" ai-workspace/templates/doc/.ai/AI-CONTEXT.md > "$tmp/.ai/AI-CONTEXT.md"
  "$C" "$tmp/.ai/AI-CONTEXT.md" 2>&1 | grep -q 'repository.yaml' || echo '위반: doc 선언 + repository.yaml 미보고'
  sed "s/^> last updated: YYYY-MM-DD$/> last updated: $today/" ai-workspace/templates/dev/.ai/AI-CONTEXT.md > "$tmp/.ai/AI-CONTEXT.md"
  [ -z "$("$C" "$tmp/.ai/AI-CONTEXT.md" 2>&1)" ] || echo '위반: dev 선언 + repository.yaml 오보고'
  rm -rf "$tmp"
  ```

  - 설계 주의: 헬퍼 실행으로 동작을 본다. 표 행 존재만 보면 헬퍼 구현이 빠져도 통과한다.
  </details>
- [ ] [D]  ai-workspace 테스트가 건물 repo 검사 케이스(보고·무보고)를 실행해 0 실패로 통과한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  R=ai-workspace/tests/run-tests.sh
  out=$("$R" 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*건물 repo.* 격추')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*건물 repo.* 통과')" -ge 1 ] \
    || echo '위반: 테스트 실패 또는 건물 repo 케이스(격추·통과 각 1 이상) 미실행'
  ```

  </details>

### R7: 대상 repo 선언 확인·`--local` 멈춤

- [ ] [D]  `references/global.md` 0단계가 대상 리포 선언을 읽어 `원본 문서`를 분류하고, 1단계가 `원본 문서` 리포를 호출 식별에서 빼며, 3단계 건물 안내도 표에 표시가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  G=code-map/references/global.md
  st() { awk -v h="$1" 'index($0, h) == 1 { f = 1; next } f && /^### / { exit } f' "$G"; }
  st '### 0단계' | grep -q '선언' && st '### 0단계' | grep -q '원본 문서' || echo '위반: 0단계 선언 읽기·원본 문서 분류 없음'
  st '### 1단계' | grep -qE '원본 문서.*(제외|빼)' || echo '위반: 1단계 원본 문서 제외 없음'
  st '### 3단계' | grep -qE '^\|.*원본 문서' || echo '위반: 3단계 표에 원본 문서 표시 없음'
  ```

  </details>
- [ ] [D]  code-map `SKILL.md`에 건물 리포(`repository.yaml` 존재)에서 `--local`을 멈추고 `--global`을 안내하는 규칙 행이 있고, context-harvest 6단계 결과 보고에 건물 리포 분기 문장이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -qE 'repository\.yaml.*--local.*(중단|멈추).*--global' code-map/SKILL.md || echo '위반: code-map --local 멈춤 규칙 없음'
  awk '/^### 6단계/ { f = 1; next } f && /^## / { exit } f' context-harvest/SKILL.md | grep -qE 'repository\.yaml.*--global' || echo '위반: context-harvest 건물 리포 분기 없음'
  ```

  </details>
- [ ] [D]  code-map·context-harvest 테스트가 건물 리포 규칙 격추 케이스를 실행해 0 실패로 통과한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  out=$(code-map/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*건물.* 격추')" -ge 3 ] \
    || echo '위반: code-map 테스트 실패 또는 건물 격추 케이스 3건 미만'
  out=$(context-harvest/tests/run-tests.sh 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*건물.* 격추')" -ge 1 ] \
    || echo '위반: context-harvest 테스트 실패 또는 건물 격추 케이스 미실행'
  ```

  </details>
- [ ] [ND] 실제 건물 리포에서 `--global`을 실행하면 `원본 문서` 리포가 건물 안내도에 문서 리포로 표시된다  (검증: 사람이 회사 환경에서 확인)  ← 강등 사유: 건물 리포가 이 머신에 없어 명령으로 재현 불가

### R8: doc 카테고리 세트

- [ ] [D]  세 스킬 `SKILL.md`의 doc 카테고리 표(헤더 `| doc 카테고리 |`) 첫 열이 확정 이름·순서 7개와 같고 세 사본이 서로 같으며, 선언 분기 문장이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  doc_names() {
    awk '/^\| doc 카테고리 \|/ { f = 1; next }
         f && /^\|[- |]+\|[[:space:]]*$/ { next }
         f && /^\|/ { split($0, a, "|"); gsub(/^ +| +$/, "", a[2]); print a[2]; next }
         f { exit }' "$1"
  }
  for s in git-review issue-audit git-review-quiz; do
    n="$(doc_names "$s/SKILL.md" | grep -c .)"
    [ "$n" -eq 7 ] || echo "위반: $s doc 카테고리 표 ${n}행(기대 7)"
    grep -qE '원본 문서.*doc 카테고리' "$s/SKILL.md" || echo "위반: $s 선언 분기 문장 없음"
  done
  diff <(doc_names git-review/SKILL.md) <(printf '%s\n' '내용 정확성' '구조 정합' '모순·누락' '보안·민감정보' '가독성·일관성' '최신성' '근거 검증') >/dev/null || echo '위반: git-review doc 이름·순서가 확정 대응표와 다름'
  diff <(doc_names git-review/SKILL.md) <(doc_names issue-audit/SKILL.md) >/dev/null || echo '위반: git-review↔issue-audit doc 이름·순서 불일치'
  diff <(doc_names git-review/SKILL.md) <(doc_names git-review-quiz/SKILL.md) >/dev/null || echo '위반: git-review↔git-review-quiz doc 이름·순서 불일치'
  ```

  - 설계 주의: 첫 열만 대조한다. 2열은 스킬마다 다르다(검증 내용 / 문항 소재). 확정 이름 리터럴은 원본인 git-review와 대조하고 나머지 두 사본은 git-review와 대조한다. 세 사본이 같은 오기를 내도 리터럴 대조가 잡는다.
  </details>
- [ ] [D]  결과 템플릿 2종(`review-result-template.md`·`issue-audit-report-template.md`)에 선언에 따른 doc 카테고리 행 이름 안내가 있고, 명세 `git-review-output.md`·ADR 0014에 doc 세트 문장이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in git-review/templates/review-result-template.md issue-audit/templates/issue-audit-report-template.md \
           .ai/40_domain/specs/git-review-output.md .ai/50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md; do
    grep -q 'doc 카테고리' "$f" || echo "위반: $f 에 doc 카테고리 언급 없음"
  done
  ```

  </details>
- [ ] [D]  세 스킬 테스트가 doc 카테고리 표 케이스(확정 이름 통과 1·격추 3 이상: 행 삭제, 이름 오기, 순서 교환)를 실행해 0 실패로 통과한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for s in git-review issue-audit git-review-quiz; do
    out=$("$s/tests/run-tests.sh" 2>&1) \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*doc 카테고리.* 통과')" -ge 1 ] \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*doc 카테고리.* 격추')" -ge 3 ] \
      || echo "위반: $s 테스트 실패 또는 doc 카테고리 케이스(통과 1·격추 3 이상) 미실행"
  done
  ```

  </details>
- [ ] [ND] `원본 문서`를 선언한 repo에서 git-review를 실행하면 doc 카테고리로 결과가 나온다  (검증: 사람이 doc repo에서 확인)  ← 강등 사유: 스킬 실행 결과는 LLM 출력이라 명령으로 판정 불가

### R9: 보류 항목 원장 등재 경로

- [ ] [D]  issue-work `SKILL.md`의 `## 이슈 완료 시` 절과 `--clear` 절에 보류 항목 원장 등재 질의 문장이 있고, spec 템플릿 제외 안내 주석에 등재 질의 안내가 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  S=issue-work/SKILL.md
  awk '/^## 이슈 완료 시/ { f = 1; next } f && /^## / { exit } f' "$S" | grep -qE '보류.*원장.*등재' || echo '위반: 이슈 완료 시 절에 보류 등재 질의 없음'
  awk '/^### `--clear`/ { f = 1; next } f && /^### / { exit } f' "$S" | grep -qE '보류.*등재' || echo '위반: --clear 절에 보류 등재 없음'
  grep -qE '보류.*원장 등재' issue-work/templates/issue-spec-template.md || echo '위반: spec 템플릿 제외 주석에 등재 안내 없음'
  ```

  </details>
- [ ] [D]  원장 등재 주체 문장(이 repo·shared의 `70_ledger/index.md`와 `ledger-entry-template.md`)에 issue-work 이슈 완료 시 경로가 있고, 항목 템플릿 두 사본이 같으며, `specs/issue-workflow.md`·ADR 0007·ADR 0018에 보류 등재 문장이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for f in .ai/70_ledger/index.md ai-workspace/templates/shared/.ai/70_ledger/index.md \
           .ai/70_ledger/ledger-entry-template.md ai-workspace/templates/shared/.ai/70_ledger/ledger-entry-template.md; do
    grep -qE '등재 주체.*이슈 완료 시' "$f" || echo "위반: $f 등재 주체 문장"
  done
  diff -q ai-workspace/templates/shared/.ai/70_ledger/ledger-entry-template.md .ai/70_ledger/ledger-entry-template.md >/dev/null || echo '위반: 항목 템플릿 사본 불일치'
  for f in .ai/40_domain/specs/issue-workflow.md .ai/50_adr/active/0007-tech-debt-ledger-location-and-structure.md .ai/50_adr/active/0018-ledger-proactive-review-and-resolve-timing.md; do
    grep -qE '보류.*(원장|등재)' "$f" || echo "위반: $f 보류 등재 문장 없음"
  done
  ```

  </details>
- [ ] [D]  issue-work `--clear` 절의 단계 번호가 1~6 그대로다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  steps="$(awk '/^### `--clear`/ { f = 1; next } f && /^### / { exit } f && /^  [0-9]+\. \*\*/ { sub(/^  /, ""); sub(/\..*/, ""); print }' issue-work/SKILL.md | paste -sd' ' -)"
  [ "$steps" = '1 2 3 4 5 6' ] || echo "위반: --clear 단계 번호 [$steps]"
  ```

  - 설계 주의: 5·6단계 참조가 ADR 0015·헬퍼·템플릿에 퍼져 있어 번호를 늘리면 참조가 깨진다. 보류 등재 질의는 4단계 안에 둔다.
  </details>
- [ ] [D]  issue-work 테스트가 이슈 완료 시 보류 등재 구조 케이스(통과·격추)를 실행해 0 실패로 통과한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  R=issue-work/tests/run-tests.sh
  out=$("$R" 2>&1) \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*보류 등재.* 통과')" -ge 1 ] \
    && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- .*보류 등재.* 격추')" -ge 1 ] \
    || echo '위반: 테스트 실패 또는 보류 등재 케이스 미실행'
  ```

  </details>

### R10: 보류 항목 첫 등재

- [ ] [D]  `.ai/70_ledger/active/`에 출처가 `이슈 #118`인 항목이 K-0014·K-0015 정확히 2건이고, 필수 필드 7종이 비어 있지 않으며, index 항목 목록에 그 번호 행이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  files="$(grep -lE '^- \*\*출처\*\*: .*이슈 #118' .ai/70_ledger/active/*.md 2>/dev/null)"
  [ "$(printf '%s\n' $files | grep -c .)" -eq 2 ] || echo '위반: 이슈 #118 출처 항목 2건 아님'
  for n in K-0014 K-0015; do printf '%s\n' $files | grep -q "/$n-" || echo "위반: 이슈 #118 출처 항목에 $n 없음"; done
  for f in $files; do
    for k in 유형 등재일 출처 위험도 '수용 사유' '재검토 조건' 상태; do
      grep -qE "^- \*\*$k\*\*: [^[:space:]<]" "$f" || echo "위반: $f '$k' 비어 있음"
    done
    n="$(basename "$f" | grep -oE 'K-[0-9]{4}')"
    grep -qF "[$n](active/" .ai/70_ledger/index.md || echo "위반: index 항목 목록에 $n 없음"
  done
  ```

  - 설계 주의: K-0015는 이슈 완료 시(`--clear` 4단계) 질의에서 등재해 기대 건수를 1건(K-0014)에서 2건으로 고쳤다 (2026-10-25). 최종 감사는 고치기 전 명령으로 판정했다.
  </details>

### R11: ADR 0020

- [ ] [D]  `50_adr/active/0020-*.md`가 정확히 1개 있고, 결정 절에 원본 문서·page ID 기각·퍼블리싱 범위 밖 문장이 있으며, 원장 항목 참조와 이슈 #118 출처가 있고 index에 행이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  f="$(ls .ai/50_adr/active/0020-*.md 2>/dev/null)"
  if [ "$(printf '%s\n' $f | grep -c .)" -ne 1 ]; then
    echo '위반: ADR 0020 파일 1개 아님'
  else
    dec="$(awk '/^## 결정/ { f = 1; next } f && /^## / { exit } f' "$f")"
    for k in '원본 문서' 'page ID' '퍼블리싱' 'K-00'; do
      printf '%s\n' "$dec" | grep -qF "$k" || echo "위반: 결정 절에 '$k' 없음"
    done
    grep -q 'issues/118' "$f" || echo '위반: 원본 출처 #118 없음'
  fi
  grep -qE '^\| `active/0020-' .ai/50_adr/index.md || echo '위반: 50_adr/index.md 행 없음'
  ```

  - 설계 주의: 파일이 없을 때 빈 경로를 `awk`에 넘기면 표준 입력을 기다려 멈춘다. 개수 판정 뒤에만 본문을 읽는다.
  </details>
- [ ] [QD] ADR 0020의 결정·근거·대안이 #114 spec 전제(방향 전환 이력)와 이 이슈 본문의 결정과 모순되지 않는다  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 의미 대조라 명령으로 환원 불가

### 공통

- [ ] [D]  repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D]  dev 전용 템플릿(`ai-workspace/templates/dev/`)·shared `context-loading.md`·code-map `references/local.md`·`classify-risk.sh` 2종이 `main`과 같고, 세 스킬의 코드 카테고리 7종 표 첫 열이 그대로다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  git diff --quiet main -- ai-workspace/templates/dev/ || echo '위반: dev 전용 템플릿 변경'
  git diff --quiet main -- ai-workspace/templates/shared/.ai/10_rules/context-loading.md || echo '위반: shared context-loading.md 변경'
  git diff --quiet main -- code-map/references/local.md || echo '위반: code-map local.md 변경'
  for s in git-review issue-audit; do git diff --quiet main -- "$s/scripts/classify-risk.sh" || echo "위반: $s classify-risk.sh 변경"; done
  code_names() {
    awk '/^\| 카테고리 \| (검증 내용|문항 소재) \|/ { f = 1; next }
         f && /^\|[- |]+\|[[:space:]]*$/ { next }
         f && /^\|/ { split($0, a, "|"); gsub(/^ +| +$/, "", a[2]); print a[2]; next }
         f { exit }' "$1"
  }
  for s in git-review issue-audit git-review-quiz; do
    diff <(code_names "$s/SKILL.md") <(printf '%s\n' 기능 아키텍처 버그 보안 코드품질 성능 테스트) >/dev/null || echo "위반: $s 코드 카테고리 7종 변경"
  done
  ```

  </details>

---

## 전제 (Assumptions)

- **승인으로 확정한 값 3건 (2026-10-24)**: 로비 2번째 줄 리터럴 `> SSoT: 각 repo 안내도의 선언을 따른다. 이 파일은 라우터일 뿐 진실의 원천이 아니다.`, 건물 repo 선언은 (가) `소스 코드`, doc 카테고리 대응표는 이슈 본문 후보표 그대로.
- **Task 0 질의로 확정한 값 (2026-10-24)**:
  - 커밋 시점: Task마다 완료 후 커밋 승인을 요청한다. Task 8의 `source_hash`는 이 이슈에서 스킬 소스(스킬 디렉토리)를 바꾼 마지막 커밋 해시로 적는다(#110·#112 관례).
  - git-review-quiz doc 표 `문항 소재` 열은 아래 문구로 쓴다. 내용 정확성 "바뀐 서술이 무엇을 말하는지, 근거 출처·실제 정책과 맞는 지점", 구조 정합 "문서 배치·문서 규약, 관련 정책·ADR과의 정합성", 모순·누락 "문서 안팎 서술에서 달라진 내용, 빠진 조건·예외", 보안·민감정보 "비밀값·개인정보·내부 정보 취급의 변경", 가독성·일관성 "용어·표기·문서 규약을 따른 지점과 그 이유", 최신성 "법령 개정·시행일·확인일 등 시점 정보의 변경", 근거 검증 "주장마다 붙은 출처, 링크가 가리키는 대상".
  - ai-workspace-directory `### 대전제`의 "markdown은 코드를 가리키는 지도이지 코드의 사본이 아니다."도 "안내도 markdown은 SSoT를 가리키는 지도이지 SSoT의 사본이 아니다."로 바꾼다. doc repo의 `ssot_dir` 문서는 markdown이면서 SSoT라 기존 문장과 어긋난다. 이 문장은 `SKILL.md`에만 있어 동기화할 사본이 없다.
  - `global.md` 0단계의 건물 리포 안내도 선언 확인은 `repository.yaml` 없음 중단(현 2번) 뒤인 새 3번에 둔다. 건물 리포 판정 근거(`repository.yaml` 존재)를 확인한 뒤 선언을 검사하기 위함이다. 이후 번호는 clone 경로 탐색 4번, 분석 상태 분류 5번, SSoT 종류 분류 6번, 모드 결정 7번이며, 0단계 머리 문장과 `code-map/tests/run-tests.sh` 주석의 `4·5번`은 `5·7번`이 된다.
- **Task 0에서 기본값으로 정한 값 (2026-10-24)**:
  - `ai-workspace/SKILL.md` 멱등 보강 검사의 "헬퍼는 표의 10개 항목 중 8개를 판정합니다"도 "11개 항목 중 9개"로 함께 고친다(헬퍼 머리 주석·명세와 같은 행 수 표기).
  - git-review·issue-audit doc 표의 `검증 내용` 열은 이슈 본문 후보표의 `검증 내용` 문구를 그대로 쓴다.
  - `global.md` `## 전제 조건`의 "현재 프로젝트는 소스코드가 없는 문서 전용 리포이다"는 유지한다. 새 선언 규칙 항목이 doc 프로파일로 init하지 않는다고 명시한다.
  - `document-convention.md` 기본값 줄은 확장자 칸만 `.md`, 나머지 세 칸은 "기본값 없음"이다(plan Task 1 작업 1).
- **`document-convention.md` 골격**: H2 4칸 리터럴은 `## SSoT 대상 확장자`, `## 첨부 분류`, `## 근거 출처와 원본 문서 사이 우선순위`, `## 파일·디렉토리 명명`이다. 각 칸은 HTML 주석 안내와 기본값 한 줄로 두고, 첨부 분류 칸은 기본값 없이 repo가 채운다. 사용자 관리 파일이라 update는 없을 때만 복사하고, `check-context.sh`는 `## 프로젝트 규칙` 표의 이 행을 검사하지 않는다(dev의 `architecture.md`·`coding-convention.md` 행과 같은 취급).
- **writing-principles 버전**: 1.1.1에서 1.2.0으로 올린다(내용 추가). ADR 0008은 수정하지 않고 ADR 0020이 이 변경을 참조한다.
- **`.md` 확정의 적용 범위**: 색인·수집 대상 정의 4곳(code-map `doc.md`, context-harvest `SKILL.md`, doc 템플릿 `ssot_dir` 주석, 정책)에만 `.md`를 적는다. `60_codebase/`를 "원본 문서 파일 지도"로 부르는 일반 서술(context-loading·shared index·doc 안내도 트리)은 바꾸지 않는다. code-map `fixtures/doc-index/`는 입력에 `.md` 외 파일이 없으면 기대 결과를 바꾸지 않고 README에 범위만 적는다.
- **구 로비 문구의 잔존 위치**: 구 문구는 `ai-workspace-directory/tests/run-tests.sh`의 격추 입력(sed 변형 문자열)에만 남는다. 새 fixture 파일은 만들지 않는다. R4 [D]의 잔존 검사는 그래서 `tests/`를 제외한다.
- **로비 `placeholder` 분기 문구**: 골격·fixture·예시의 3단계 분기를 "`placeholder` → 안내도 없음. 선언을 찾지 못하므로 소스 코드로 폴백한다. `<path>/.ai/` 자체가 없으면 문서 repo는 `ai-workspace doc`, 그 외는 `ai-workspace dev` 초기 설치를, 있으면 `ai-workspace update` 갱신을 권유한다"로 쓴다. 기존 `.ai/` 유무 분기를 유지한 것은 init이 기존 `.ai/`를 지우기 때문이다. `.ai/`가 있는 문서 repo에 doc init을 권하면 기존 내용이 사라진다(Task 3에서 정정, 작성 시 "문서 repo이면 `ai-workspace doc` init"). `check-lobby.sh`는 이 문구를 검사하지 않는다(진입 절차 4단계 개수만 검사).
- **건물 repo 검사의 결정화**: `check-context.sh`에 검사 행을 더해 11행(헬퍼 9행 + AI 판정 2행)이 된다. 헬퍼 머리 주석 "10행 중 8행"과 `specs/ai-workspace.md`의 "8종 + 2종"을 함께 고친다. `repository.yaml` 경로는 입력 파일 기준 `$(dirname <AI-CONTEXT.md>)/60_codebase/repository.yaml`이다. 보고 조건은 "파일 존재 + 2번째 줄이 doc 표준 문구"다. 비표준 문구는 SSoT 선언 행이 이미 보고하므로 중복 보고하지 않고, 그 행의 조치에 "건물 repo(`repository.yaml` 존재)면 dev 문구를 넣는다"를 더한다. 조치는 보고와 질의까지며 자동 전환은 없다.
- **"건물 안내도에 적는다"의 해석**: R6의 건물 안내도는 code-map이 생성하는 `.ai/60_codebase/index.md`다. 3단계 예시 첫 줄 아래에 `> SSoT: 등록 리포의 소스 코드. 이 리포 안에는 SSoT가 없다.` 인용 행을 둔다. 건물 repo의 `.ai/AI-CONTEXT.md` 선언 확인은 0단계에 둔다(`소스 코드`가 아니면 보고하고 중단).
- **건물 안내도의 문서 리포 표시**: 0단계의 리포 분류는 두 축이다. 분석 상태(분석 완료 / 미분석)는 기존대로 `.ai/60_codebase/index.md` 유무로 정하고, SSoT 종류(`소스 코드` / `원본 문서`)는 각 리포 안내도의 선언으로 정한다. `문서 리포` 표시는 SSoT 종류 축의 값이며 분석 상태를 대체하지 않는다(원본 문서 리포도 색인이 없으면 미분석이다). 1단계는 분석 완료 리포를 SSoT 종류와 무관하게 수집한다. 1번 리포 스캔에서 `원본 문서` 리포는 상세 호출 흐름 문서 대신 문서 지도(색인의 파일 목록)를 읽고, 4번(서비스 간 호출 식별)에서는 제외하며, 2·3번(변경 감지·교차 참조)은 그대로 수행한다. 3단계 리포 목록 표에 `SSoT` 열(`소스 코드` / `원본 문서`)을 더한다.
- **doc 카테고리 표 형식**: 헤더 리터럴은 `| doc 카테고리 | <2열> | 대응 코드 카테고리 |`이며 2열은 git-review·issue-audit `검증 내용`, git-review-quiz `문항 소재`다. 코드 7종 표 바로 아래에 분기 문장과 함께 둔다. 결과 템플릿의 행은 코드 7종 이름을 기본으로 두고, 주석으로 선언이 `원본 문서`이면 doc 이름으로 바꿔 쓴다고 안내한다(템플릿을 둘로 나누지 않는다). issue-audit 2단계 집계 줄도 같은 안내를 받는다.
- **보류 등재 질의의 위치**: `## 이슈 완료 시` 3단계의 하위 항목(원장 해소 기재와 같은 단계)과 `--clear` 4단계에 둔다. 단계 번호 체계는 바꾸지 않는다(5·6단계 참조가 ADR 0015·헬퍼·템플릿에 퍼져 있다). 중복 판정은 보류 항목 단위다. 이슈 번호(`출처`의 `이슈 #N`)는 `active/`·`archive/`를 검색하는 범위로만 쓰고, 검색된 원장 항목 가운데 그 보류 항목과 같은 대상(제목·내용)을 기록한 항목이 있을 때 그 보류 항목만 건너뛴다. 같은 이슈의 다른 보류 항목은 질의한다(보류 A만 등재된 상태면 B는 질의하고, A·B가 모두 등재됐으면 둘 다 건너뛴다).
- **R10의 수행 시점**: 등재 질의는 Task 7에서 수행했다(첫 적용). 2026-10-24 질의에서 퍼블리싱 항목(K-0014, 유형 기술부채)만 승인했고, 폴백 항목은 등재하지 않기로 했다(작성 시 K-0015 known issue로 등재 예정). 위험도는 `issue-audit/scripts/classify-risk.sh` 매트릭스로 산출한다. `--clear` 시점에는 퍼블리싱 항목이 K-0014에 대응해 건너뛰기 규칙으로 재질의하지 않는다. 폴백 항목은 대응하는 원장 항목이 없어 규칙대로 다시 질의됐고, 2026-10-25 `--clear` 4단계 질의에서 K-0015(known issue, 낮음(LOW))로 등재했다. ADR 0020 결정 2의 재검토 조건은 K-0014 항목에 둔다.
- **기존 ADR 보정 방식**: ADR 0007·0014·0018은 본문을 제자리에서 보정하고 보정 문장 끝에 `(#118)`을 붙인다. 대체(superseded)하지 않는다. #114가 정책 문서를 보정한 방식과 같다.
- **설치본**: `~/.claude/skills/`는 설치 복사본이다. 수정은 이 repo에서 하고 PR 머지 후 `/install-skills`로 다시 설치한다(감사 보정으로 소스가 다시 바뀔 수 있어 머지 전에는 설치하지 않는다. 2026-10-24 사용자 확정). 머지 전 `--clear` 등 이 이슈에서 바뀐 절차는 설치본 대신 repo의 `SKILL.md`를 기준으로 수행한다. DoD 명령은 repo 경로 기준이다.
- **색인 정합**: `.ai/60_codebase/index.md`의 frontmatter는 code-map sync 산출이라 손대지 않고(#114 Task 6 선례), 상세 흐름 파일은 본문과 `source_hash`만 갱신한다.
- **환경**: 테스트 러너는 bash이며 macOS BSD `sed -i.bak` 관용을 따른다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/40_domain/policies/local/ssot-and-router-principle.md` | SSoT 선언·폴백·충돌 우선순위·로비 원칙. R3·R5 동기화 대상 |
| `.ai/40_domain/specs/ai-workspace.md` | 안내도 SSoT 선언·로비 규격·update 멱등 검사 스펙. R1·R5·R6 동기화 대상 |
| `.ai/40_domain/specs/git-review-output.md` | 카테고리 7종과 결과 구조. R8 동기화 대상 |
| `.ai/40_domain/specs/issue-workflow.md` | issue-work 절차·원장 연계. R9 동기화 대상 |
| `.ai/40_domain/policies/local/notation-conventions.md` | 분류 값 한글 우선 병기, 스킬·옵션 명명 기준. doc 카테고리 이름 표기 참고 |
| `.ai/50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md` | 카테고리 7종 원본은 git-review, 사본 동기화. R8 동기화 대상 |
| `.ai/50_adr/active/0007-tech-debt-ledger-location-and-structure.md` | 원장 필수 필드·소비자 3종. R9 동기화 대상 |
| `.ai/50_adr/active/0018-ledger-proactive-review-and-resolve-timing.md` | 원장 재검토·종결 계기 확장(권고·승인형). R9 동기화 대상 |
| `.ai/50_adr/active/0008-writing-principles-ssot-distribution.md` | writing-principles 버전 고정 배포 규칙. R2 근거 |
| `.ai/50_adr/active/0002-skill-independence-intentional-duplication.md` | 공통 규칙은 스킬별 복제 + 동기화 주석. R4·R8 사본 처리 근거 |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 헬퍼 테스트 동일 위치·러너. R4 `check-lobby.sh` 테스트 배치 |
| `.ai/50_adr/active/0003-verification-levels-and-determinization.md` | 검증 레벨·결정화 판단. 완료의 정의 작성 기준 |
| `.ai/10_rules/architecture.md` | 결정화 판단 체크리스트. R6 건물 repo 검사를 헬퍼에 둔 근거 |
| `.ai/70_ledger/index.md` | 등재 주체 문장·수명 주기 표. R9 수정 대상, R10 등재 위치 |
| `.ai/90_issues/archive/issue-0114/issue-0114-spec.md` | 선행 이슈 spec. 전제 "방향 전환 이력"이 ADR 0020 결정 1의 기각 대안 출처 |
