# Issue #61 스펙 — 기술부채·known issue 원장 도입

## 목표 (Goal)

수용된 발견사항(known issue·기술부채)의 단일 기록처 `.ai/70_ledger/`(원장)를 도입하고, issue-audit·issue-work `--response`·git-pr-feedback이 이를 참조·활용하도록 규칙화하여 같은 발견의 반복 보고를 구조적으로 차단한다.

---

## 범위 (Scope)

**포함 (In)**

- 원장 구조 정의: `.ai/70_ledger/` — `index.md` + `active/`(살아 있는 부채) + `archive/`(청산한 부채), 항목별 파일 `K-<번호>-<slug>.md`
- 원장 항목 템플릿 신설(`issue-work/templates/ledger-entry-template.md`) — 필수 필드 7종
- 원장 index 골격 신설(`ai-workspace/templates/shared/.ai/70_ledger/index.md`) — 항목 목록 표 + 수명 주기(수용 → 승격/해소 → `archive/` 이관) 규칙
- issue-work SKILL.md `--response` 개정: 미승인·보류 항목의 이관 목적지를 원장으로 표준화, 등재 시 수용 사유·재검토 조건 필수 기재
- issue-audit SKILL.md 개정: `70_ledger/index.md` 선택 적재, 기등재 일치 발견의 "기등재 참조" 표기·집계 제외, 재검토 조건 충족 시에만 재제기. 리포트 템플릿에 기등재 참조 섹션 신설
- git-pr-feedback SKILL.md 개정: 항목별 선택지에 "수용 — 원장 등재" 추가, 수용 사유·재검토 조건 필수 기재 (이슈 #61 코멘트 확정 사항)
- ai-workspace 반영: 템플릿 골격 `70_ledger/`·`context-loading.md` 참조 원칙·AI-CONTEXT 템플릿(dev/doc)·SKILL.md update-3단계 표
- 이 repo 반영: `.ai/70_ledger/` 첫 인스턴스 생성, `.ai/AI-CONTEXT.md`·`.ai/10_rules/context-loading.md` 갱신

**비포함 (Out)**

- 신규 스킬 신설 — 이슈 본문에서 배제 확정 (최소 변경 원칙)
- issue-audit 심각도 체계 개편 — #62 (이 원장을 이관 목적지로 쓰는 후행 이슈)
- git-review의 원장 연계 — 현재 의견 유형·심각도 체계가 없어 등재 기준을 세울 수 없다. #62의 심각도 체계 정비 후 별도 판단
- 과거 archive 이슈 발견사항의 소급 등재
- GitHub 이슈·라벨 기반 관리, 단일 파일 원장 — 이슈 #61 본문 "배제한 대안" 참조

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D] 원장 항목 템플릿이 필수 필드 7종(유형·등재일·출처·위험도·수용 사유·재검토 조건·상태)을 `- **<필드>**:` 앵커로 갖춘다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/ledger-entry-template.md
  for f in '유형' '등재일' '출처' '위험도' '수용 사유' '재검토 조건' '상태'; do
    grep -qE "^- \*\*$f\*\*:" "$T" || echo "위반: $f 필드 누락 또는 파일 없음"
  done
  ```

  - 설계 주의: 파일이 없으면 `grep -q`가 실패해 7건 전부 위반으로 출력된다 — 파일 실재 검사를 겸한다.
  </details>
- [ ] [D] 원장 index 골격에 `## 수명 주기` 섹션이 있고 승격·해소·`archive/` 이관의 종결 경로를 명시한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=ai-workspace/templates/shared/.ai/70_ledger/index.md
  grep -qE '^## 수명 주기' "$T" || echo '위반: 수명 주기 섹션 누락 또는 파일 없음'
  for w in '승격' '해소' 'archive/'; do
    grep -q "$w" "$T" || echo "위반: $w 미명시"
  done
  ```

  </details>
- [ ] [D] issue-work SKILL.md `--response`가 미승인·보류 항목의 이관 목적지를 원장으로 명시하고 등재 필수 필드 2종(수용 사유·재검토 조건)을 기재한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  F=issue-work/SKILL.md
  grep -q '70_ledger' "$F" || echo '위반: 원장 경로 없음'
  grep -E 'ledger|원장' "$F" | grep -q '수용 사유' || echo '위반: 수용 사유 필수 기재 없음'
  grep -E 'ledger|원장' "$F" | grep -q '재검토 조건' || echo '위반: 재검토 조건 필수 기재 없음'
  ```

  </details>
- [ ] [D] issue-audit SKILL.md가 `70_ledger/index.md` 선택 적재와 기등재 일치 발견의 참조 표기·집계 제외 규칙을 명시하고, 리포트 템플릿에 기등재 참조 섹션이 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  F=issue-audit/SKILL.md
  grep -q '70_ledger/index.md' "$F" || echo '위반: 원장 index 적재 규칙 없음'
  grep -q '기등재' "$F" || echo '위반: 기등재 참조·집계 제외 규칙 없음'
  grep -q '재검토 조건' "$F" || echo '위반: 재검토 조건 판정 규칙 없음'
  grep -qE '^### 기등재 참조 항목' issue-audit/templates/issue-audit-report-template.md \
    || echo '위반: 리포트 템플릿에 기등재 참조 섹션 없음'
  ```

  </details>
- [ ] [D] git-pr-feedback SKILL.md 항목별 선택지에 원장 등재가 추가되고 등재 필수 필드 2종을 기재한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  F=git-pr-feedback/SKILL.md
  grep -q '70_ledger' "$F" || echo '위반: 원장 경로 없음'
  grep -qE '^- \*\*수용 — 원장 등재\*\*' "$F" || echo '위반: 항목별 선택지에 원장 등재 없음'
  grep -E 'ledger|원장' "$F" | grep -q '수용 사유' || echo '위반: 수용 사유 필수 기재 없음'
  grep -E 'ledger|원장' "$F" | grep -q '재검토 조건' || echo '위반: 재검토 조건 필수 기재 없음'
  ```

  </details>
- [ ] [D] ai-workspace 산출 구조(템플릿 골격·context-loading·AI-CONTEXT 템플릿·SKILL.md)와 이 repo `.ai/`에 `70_ledger/`가 반영된다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for d in ai-workspace/templates/shared/.ai/70_ledger/active \
           ai-workspace/templates/shared/.ai/70_ledger/archive \
           .ai/70_ledger/active .ai/70_ledger/archive; do
    test -d "$d" || echo "위반: $d 없음"
  done
  test -f .ai/70_ledger/index.md || echo '위반: repo 원장 index.md 없음'
  for f in ai-workspace/templates/shared/.ai/10_rules/context-loading.md \
           ai-workspace/templates/dev/.ai/AI-CONTEXT.md \
           ai-workspace/templates/doc/.ai/AI-CONTEXT.md \
           ai-workspace/SKILL.md .ai/AI-CONTEXT.md .ai/10_rules/context-loading.md; do
    grep -q '70_ledger' "$f" || echo "위반: $f 에 70_ledger 미반영"
  done
  ```

  - 설계 주의: `.gitkeep`이 아니라 디렉토리 존재로 판정한다 — 빈 디렉토리 유지 수단이 바뀌어도 구조 요구는 그대로다.
  </details>
- [ ] [QD] 원장 참조 규칙이 발견(audit·PR 리뷰) → 등재 → 재검토(재평가·승격·해소)의 순환에서 반복 보고를 실제로 차단하는 정합 구조다  (검증: 교차모델 audit 채점)  ← 강등 사유: 절차 문서 간 의미 정합성은 문자열 대조로 환원 불가

---

## 전제 (Assumptions)

- **원장 위치는 `.ai/70_ledger/` 최상위다** — 이슈 본문이 "확정"으로 적은 `.ai/90_issues/ledger/`를 Task 0에서 뒤집은 결정이다. 근거: 이슈 본문의 위치 근거("원장 항목은 이슈 작업 흐름에서 생성·소비되므로 `90_issues/` 하위가 응집도 높음")가 코멘트의 git-pr-feedback 추가로 무너졌다 — PR 리뷰는 이슈 작업 흐름 바깥이다. `90_issues/` 하위에 두면 AI-CONTEXT의 `90_issues/ # 이슈 단위 작업` 서술과 모순되고, ai-workspace update의 이동 판단 기준에 `K-*.md` 예외 규칙이 필요해진다. 검토 후 버린 대안: `50_adr/` 하위(ADR 수명 주기 `active`/`superseded`와 원장의 `수용`/`승격`/`해소`가 달라 섞이고, 부채 항목이 늘면 ADR index가 오염됨). 이 결정은 이슈 코멘트로 갱신해 본문 "배제한 대안"과의 불일치를 남기지 않는다.
- 원장 하위 구조는 `active/`(살아 있는 부채) + `archive/`(청산한 부채)로 나눈다 — `50_adr/`의 생사 분리 관례를 따르되, 디렉토리명은 이슈 본문의 "`ledger/archive/` 이관" 용어와 `90_issues/`의 `archive/` 관례에 맞춰 `archive/`로 한다.
- 읽기 우선순위는 `[6순위]`로 둔다 — `60_codebase/`(5순위) 다음이며, `index.md`로 선택 적재하는 `30~60` 계열과 같은 형태다.
- **원장 index 골격은 ai-workspace가 단독 소유한다** (`templates/shared/.ai/70_ledger/index.md`). 이 repo의 기존 관례가 "index.md 골격은 ai-workspace가 배포하고(30_contract·40_domain·50_adr·60_codebase 전부), 개별 항목 문서 템플릿은 생산 스킬이 보유(context-harvest의 `50_adr-template.md`)"이기 때문. 따라서 issue-work에는 항목 템플릿(`ledger-entry-template.md`)만 두고 index 템플릿은 두지 않는다 — 같은 내용을 두 스킬이 갖는 SSoT 이중화를 피한다.
- 원장 항목 템플릿은 `issue-work/templates/`에 둔다 — 등재 절차의 주체가 `--response`이기 때문. 검토 후 버린 대안: `.ai/20_templates/` 배치(스킬은 `.ai/`에 의존하지 않고 단독 실행 가능해야 한다는 스킬 독립성 원칙 위반), 신규 스킬 신설(이슈 본문에서 배제 확정).
- 원장 파일명 `K-<번호>-<slug>.md`의 번호는 4자리 zero-padding(`K-0001-…`)으로 한다 — 이슈 디렉토리 관례(`issue-0061`) 준용.
- **`출처` 필드에는 식별자만 적고 파일 경로를 넣지 않는다** — 이슈 #N / audit 발견 `F-n` / PR 코멘트 스레드. audit 리포트는 `--clear` 5단계에서 `99_workspace/` → `archive/issue-N/`로 이관되므로, 경로를 적으면 원장 항목이 이관 시점에 깨진다. 원장은 이동 대상이 아니라 `--clear` 6단계 경로 갱신의 사각지대이기도 하다.
- issue-work `templates/issue-workflow-template.md`의 `--response` 안내 행에도 이관 목적지(원장)를 한 줄 반영하고 `active/issue-workflow.md` 사본을 동기화한다 — SKILL.md와 사본 간 절차 불일치 방지 목적이며 범위 확장이 아니다.
- audit 리포트의 기등재 항목은 2단계 `발견 사항` 표가 아니라 **별도 `### 기등재 참조 항목` 섹션**에 적는다 — 발견 표가 곧 집계 대상이라, 표 안에 두면 집계 오염과 `F-` 번호 소비 문제가 함께 생긴다.
- `git-review`는 이번 범위에서 제외한다 — 의견 유형·심각도 체계가 없어(결과 기록만 존재) 등재 기준을 세울 수 없다. 원장 생산자 후보이나 #62의 심각도 체계 정비 후 별도 판단한다.
- `--resume`은 원장을 적재하지 않는다(`active/` + `99_workspace/`만 읽음). 재개 후 `--response` 등재 시 기등재 대조가 필요하면 그 절차 안에서 `70_ledger/index.md`를 읽으므로, `--resume` 자체는 이번 범위에서 손대지 않는다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| GitHub 이슈 #61 본문 | 요구사항 원문 — 원장 구조·스킬 연계 확정 내용, 배제한 대안 |
| GitHub 이슈 #61 코멘트 (2026-07-31) | 확정 갱신 — git-pr-feedback 연계 추가, 출처 필드에 PR 코멘트 스레드 추가, 선행 의존 #64 |
| GitHub 이슈 #62 | 후행 의존 이슈 — 심각도 체계가 이 원장을 이관 목적지로 사용 |
| GitHub 이슈 #64 | 선행 의존 (완료) — git-pr-feedback 스킬. 이번 이슈에서 원장 등재 선택지를 배선 |
| `.ai/10_rules/writing-principles.md` | 산출 문서 서술 원칙 — 원장 항목·index 템플릿 작성에 적용 |
| `.ai/10_rules/file-change-policy.md` | 파일 추가 규칙 — 원장·템플릿 신설 시 적용 |
