# Issue #61 스펙 — 기술부채·known issue 원장 도입

## 목표 (Goal)

audit에서 수용된 발견사항(known issue·기술부채)의 단일 기록처 `.ai/90_issues/ledger/`(원장)를 도입하고, issue-audit·issue-work `--response`가 이를 참조·활용하도록 규칙화하여 같은 발견의 반복 보고를 구조적으로 차단한다.

---

## 범위 (Scope)

**포함 (In)**

- 원장 구조 정의: `.ai/90_issues/ledger/` — 항목별 파일(`K-<번호>-<slug>.md`) + `index.md` + `archive/`
- 원장 항목·index 템플릿 신설(`issue-work/templates/`) — 수명 주기(수용 → 승격/해소 → `ledger/archive/` 이관) 규칙 포함
- issue-work SKILL.md `--response` 개정: 미승인·보류 항목의 이관 목적지를 원장으로 표준화, 등재 시 수용 사유·재검토 조건 필수 기재
- issue-audit SKILL.md 개정: `ledger/index.md` 선택 적재, 기등재 일치 발견의 "기등재 참조" 표기·집계 제외, 재검토 조건 충족 시에만 재제기
- ai-workspace 반영: 템플릿 골격(`templates/shared/.ai/90_issues/`)·AI-CONTEXT 템플릿(dev/doc)·SKILL.md 하위 구조 표에 `ledger/` 추가
- 이 repo 반영: `.ai/90_issues/ledger/` 첫 인스턴스 생성, `.ai/AI-CONTEXT.md` 디렉토리 구조 갱신

**비포함 (Out)**

- 신규 스킬 신설 — 이슈 본문에서 배제 확정 (최소 변경 원칙)
- issue-audit 심각도 체계 개편 — #62 (이 원장을 이관 목적지로 쓰는 후행 이슈)
- 과거 archive 이슈 발견사항의 소급 등재
- GitHub 이슈·라벨 기반 관리, 단일 파일 원장, 최상위 `.ai/70_*` 신설 — 이슈 #61 본문 "배제한 대안" 참조

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
- [ ] [D] 원장 index 템플릿에 `## 수명 주기` 섹션이 있고 승격·해소·`ledger/archive/` 이관의 종결 경로를 명시한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  T=issue-work/templates/ledger-index-template.md
  grep -qE '^## 수명 주기' "$T" || echo '위반: 수명 주기 섹션 누락 또는 파일 없음'
  for w in '승격' '해소' 'ledger/archive/'; do
    grep -q "$w" "$T" || echo "위반: $w 미명시"
  done
  ```

  </details>
- [ ] [D] issue-work SKILL.md `--response`가 미승인·보류 항목의 이관 목적지를 원장으로 명시하고 등재 필수 필드 2종(수용 사유·재검토 조건)을 기재한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  F=issue-work/SKILL.md
  grep -q '90_issues/ledger' "$F" || echo '위반: 원장 경로 없음'
  grep -E 'ledger|원장' "$F" | grep -q '수용 사유' || echo '위반: 수용 사유 필수 기재 없음'
  grep -E 'ledger|원장' "$F" | grep -q '재검토 조건' || echo '위반: 재검토 조건 필수 기재 없음'
  ```

  </details>
- [ ] [D] issue-audit SKILL.md가 `ledger/index.md` 선택 적재와 기등재 일치 발견의 참조 표기·집계 제외 규칙을 명시한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  F=issue-audit/SKILL.md
  grep -q 'ledger/index.md' "$F" || echo '위반: 원장 index 적재 규칙 없음'
  grep -q '기등재' "$F" || echo '위반: 기등재 참조·집계 제외 규칙 없음'
  ```

  </details>
- [ ] [D] ai-workspace 산출 구조(템플릿 골격·AI-CONTEXT 템플릿·SKILL.md)와 이 repo `.ai/`에 `ledger/`가 반영된다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  test -d ai-workspace/templates/shared/.ai/90_issues/ledger || echo '위반: 템플릿 골격에 ledger/ 없음'
  test -f .ai/90_issues/ledger/index.md || echo '위반: repo 원장 index.md 없음'
  for f in ai-workspace/templates/dev/.ai/AI-CONTEXT.md \
           ai-workspace/templates/doc/.ai/AI-CONTEXT.md \
           ai-workspace/SKILL.md .ai/AI-CONTEXT.md; do
    grep -q 'ledger' "$f" || echo "위반: $f 에 ledger 미반영"
  done
  ```

  </details>
- [ ] [QD] 원장 참조 규칙이 audit(발견) → `--response`(등재) → 재검토(재평가·승격·해소)의 순환에서 반복 보고를 실제로 차단하는 정합 구조다  (검증: 교차모델 audit 채점)  ← 강등 사유: 절차 문서 간 의미 정합성은 문자열 대조로 환원 불가

---

## 전제 (Assumptions)

- 원장 항목·index 템플릿은 `issue-work/templates/`에 둔다 — 등재 주체가 issue-work `--response`이기 때문. 검토 후 버린 대안: `.ai/20_templates/` 배치(스킬은 `.ai/`에 의존하지 않고 단독 실행 가능해야 한다는 스킬 독립성 원칙 위반), 신규 스킬 신설(이슈 본문에서 배제 확정).
- 원장 파일명 `K-<번호>-<slug>.md`의 번호는 4자리 zero-padding(`K-0001-…`)으로 한다 — 이슈 디렉토리 관례(`issue-0061`) 준용.
- issue-work `templates/issue-workflow-template.md`의 `--response` 안내 행에도 이관 목적지(원장)를 한 줄 반영하고 `active/issue-workflow.md` 사본을 동기화한다 — SKILL.md와 사본 간 절차 불일치 방지 목적이며 범위 확장이 아니다.
- ai-workspace 템플릿 골격의 `ledger/` 반영 형태(빈 디렉토리 `.gitkeep`만 둘지, 초기 index.md까지 둘지)는 구현 시 이웃 디렉토리(`30_contract/` 등)의 index 존재 관례를 확인해 맞춘다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| GitHub 이슈 #61 | 요구사항 원문 — 원장 구조·스킬 연계 확정 내용, 배제한 대안 |
| GitHub 이슈 #62 | 후행 의존 이슈 — 심각도 체계가 이 원장을 이관 목적지로 사용 |
| `.ai/10_rules/writing-principles.md` | 산출 문서 서술 원칙 — 원장 항목·index 템플릿 작성에 적용 |
| `.ai/10_rules/file-change-policy.md` | 파일 추가 규칙 — 원장·템플릿 신설 시 적용 |
