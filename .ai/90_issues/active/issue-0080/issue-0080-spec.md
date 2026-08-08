# Issue #80 스펙 — git 스킬 3종: 산출물 형식 블록을 templates/로 분리

> GitHub: [#80](https://github.com/scroogy-dev/scroogy-agent-skills/issues/80)

## 목표 (Goal)

git-pr·git-qa·git-review-context의 SKILL.md에 임베드된 산출물 형식 블록을 각 스킬의 `templates/`로 분리하고 SKILL.md에는 템플릿 참조만 남겨, 산출물 형식 배치를 기존 분리 스킬(git-review #75 등)과 일관되게 한다.

---

## 범위 (Scope)

**포함 (In)**

- git-pr: "작성 예시 (템플릿)" 섹션 블록 → `git-pr/templates/pr-body-template.md`
- git-qa: "출력 템플릿" 섹션 블록 → `git-qa/templates/qa-checklist-template.md`
- git-review-context: "결과 기록"의 형식 블록 → `git-review-context/templates/review-context-template.md`
- 각 SKILL.md의 이동 블록 자리·내부 상호 참조를 템플릿 참조 문구로 대체
- `.ai/AI-CONTEXT.md` 디렉토리 구조 트리에 신규 `templates/` 3행 반영

**비포함 (Out)**

- 형식 내용 개편 — 위치 이동·참조 연결만 수행 (내용 변경은 별도 이슈)
- git-commit — Conventional Commits 1.0.0 규칙(링크)이 곧 템플릿 (이슈 #80 "범위" 참조)
- git-pr-feedback — 산출물 형식은 `.ai/70_ledger/ledger-entry-template.md` 공유(issue-work와 공동 사용, ai-workspace 배포)로 이미 분리됨 (이슈 #80 "범위" 참조)
- 절차 설명 속 예시(호출 흐름 ASCII 다이어그램 예 등)·규칙 표(산출물 접기 기준 등) — SKILL.md 유지
- README.md — 디렉토리 구조 표기가 없어 갱신 대상 아님 ("전제" 참조)

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [x] [D] 3개 스킬의 템플릿 파일이 존재하고, 각 SKILL.md가 자기 템플릿 경로를 참조한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for f in git-pr/templates/pr-body-template.md git-qa/templates/qa-checklist-template.md git-review-context/templates/review-context-template.md; do
    [ -f "$f" ] || echo "누락: $f"
  done
  grep -L 'templates/pr-body-template\.md' git-pr/SKILL.md
  grep -L 'templates/qa-checklist-template\.md' git-qa/SKILL.md
  grep -L 'templates/review-context-template\.md' git-review-context/SKILL.md
  ```

  - 설계 주의: `grep -L`은 패턴이 **없을 때** 파일명을 출력하므로 "참조 누락 시 실패"가 성립한다.
  </details>
- [x] [D] 이동한 형식 블록이 SKILL.md에서 제거되고 템플릿 파일에 존재한다 — 블록 고유 앵커 문구로 판정
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  # 앵커가 SKILL.md에 남아 있으면 위반 (블록 미제거)
  grep -n 'InventoryCache#get' git-pr/SKILL.md
  grep -n '^## 배포 대상 요약' git-qa/SKILL.md
  grep -n '^# 리뷰 컨텍스트' git-review-context/SKILL.md
  # 앵커가 템플릿에 없으면 위반 (블록 미이관) — grep -L은 패턴 없는 파일명을 출력
  grep -L 'InventoryCache#get' git-pr/templates/pr-body-template.md
  grep -L '^## 배포 대상 요약' git-qa/templates/qa-checklist-template.md
  grep -L '^# 리뷰 컨텍스트' git-review-context/templates/review-context-template.md
  ```

  - 설계 주의: 앵커는 이동 블록에만 존재하는 문구로 고정했다 — `InventoryCache#get`은 SKILL.md에 잔존하는 "PR 메시지 구조"의 호출 흐름 예(`InventoryService#decrease` 등)와 겹치지 않는 값이고, 헤더 앵커 2종은 `^` 고정이라 참조 문구 속 인라인 코드와 매칭되지 않는다.
  </details>
- [x] [D] `.ai/AI-CONTEXT.md` 디렉토리 구조 트리에 3개 스킬의 `templates/` 하위 행이 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for s in git-pr git-qa git-review-context; do
    grep -A1 "── $s/" .ai/AI-CONTEXT.md | grep -q 'templates/' || echo "누락: $s"
  done
  ```

  - 설계 주의: 패턴 `── git-pr/`은 이름 끝 슬래시까지 고정해 `git-pr-feedback/` 행과 구분된다.
  </details>
- [ ] [QD] 템플릿 내용이 이동 전 SKILL.md 형식 블록과 동등하다 — 코드 펜스 해제·안내 주석 추가 외 내용 변경 없음  (검증: 교차모델 audit이 `git diff main` 대조 채점)  ← 강등 사유: 펜스 해제·안내 주석·개행 조정을 허용하는 "동등" 판단은 의미 대조라 명령으로 환원하면 표기 변형에 취약
- [ ] [ND] SKILL.md의 참조 문구가 읽는 흐름을 해치지 않는다  (검증: 사람 리뷰)  ← 강등 사유: 가독성은 주관 판단

---

## 전제 (Assumptions)

- 템플릿 파일명은 `<대상>-template.md` 관례를 따른다 (기존 7개 분리 스킬 전례). SKILL.md 참조 문구는 git-review 선례를 따른다 — "이 skill 디렉토리의 `templates/review-result-template.md`를 참조하여 …를 작성합니다" (`git-review/SKILL.md:169`).
- SKILL.md의 임베드 블록은 ` ```markdown ` 코드 펜스로 감싸져 있으나, 템플릿 파일로 옮길 때 펜스를 벗긴다 — 기존 템플릿 파일들이 펜스 없는 순수 마크다운인 관례를 따르며, 이 조정은 "내용 변경 없음" 판정에서 변경으로 보지 않는다. 템플릿 상단에 SKILL.md 규칙을 가리키는 안내 주석(HTML comment)을 추가하는 것도 선례(`git-review/templates/review-result-template.md`)를 따른 조정으로, 변경으로 보지 않는다.
- git-pr은 "작성 예시 (템플릿)" 섹션만 이동한다 — "PR 제목"·"PR 메시지 구조" 속 부분 형식 코드 블록과 호출 흐름 *(예)*는 규칙 설명의 일부라 SKILL.md에 유지한다 (이슈 #80 "범위: 산출물 형식 블록만"의 구체 적용).
- git-pr `SKILL.md:215`의 "접기 구조는 아래 \"작성 예시\"를 따릅니다"처럼 이동 블록을 가리키는 내부 상호 참조는 템플릿 파일 참조로 함께 재작성한다 (git-qa의 "아래 템플릿 구조를 따름" 2곳 동일).
- README.md에는 디렉토리 구조 표기·templates 언급이 없어 문서 동기화 대상은 AI-CONTEXT.md 트리뿐이다 (2026-08-08 확인 — `grep -n 'templates' README.md` 0건).
- install-skills 배포는 `tests/`만 제외하므로 신규 `templates/`는 추가 조치 없이 배포에 포함된다 (메커니즘: `install-skills/SKILL.md`).
- git-commit·git-pr-feedback 제외와 대상 3종·파일명은 사용자 합의로 확정된 값이다 (2026-08-08 대화, 이슈 #80 본문 "범위"에 문서화).

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| [이슈 #80](https://github.com/scroogy-dev/scroogy-agent-skills/issues/80) | 대상·제외 근거 SSoT |
| `git-review/SKILL.md` · `git-review/templates/review-result-template.md` | 분리 선례(#75) — 참조 문구·템플릿 형식 |
| `.ai/10_rules/writing-principles.md` | 산출물 작성 원칙 |
| `.ai/10_rules/file-change-policy.md` | 파일 추가 시 규칙 |
