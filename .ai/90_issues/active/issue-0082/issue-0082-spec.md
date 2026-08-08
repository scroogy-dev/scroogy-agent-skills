# Issue #82 스펙 — 전체 스킬 templates/ 참조 표기 통일

> GitHub 이슈: [#82](https://github.com/scroogy-dev/scroogy-agent-skills/issues/82)

## 목표 (Goal)

SKILL.md의 `templates/` 참조 표기를 `이 skill 디렉토리의` 수식어 하나로 통일해, 상대경로 해석 기준(스킬 디렉토리 기준 vs cwd 기준)이 모든 스킬에서 일관되게 드러나게 한다.

---

## 범위 (Scope)

**포함 (In)**

- SKILL.md 5개 파일 8행의 문구 수정 — context-harvest(2행), context-save(2행), issue-work(2행), readme-sync(1행), ai-workspace(1행)
- context-harvest 매핑 표(산출물 템플릿 표 3행)는 셀을 그대로 두고 표 도입 문장에서 기준을 1회 명시
- `ai-workspace`의 `이 스킬 디렉토리의` → `이 skill 디렉토리의` 표기 정렬 (한글↔영문 치환은 이 1곳뿐)

**비포함 (Out)**

- 스킬 동작·절차 변경 — 문구만 고친다
- 한글 `스킬` ↔ 영문 `skill` 전면 치환
- `ai-workspace`의 "이 스킬 파일의 위치(`SKILL.md`가 있는 디렉토리)를 기준으로" 표기 — 이미 더 명시적이라 유지
- `references/` 참조(ai-workspace-directory, code-map) — 같은 줄 맥락으로 기준이 드러나 범위 밖
- `~/.claude/skills/` 등 설치본 동기화 — install-skills 재실행으로 반영하며 이 이슈 범위 밖

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [x] [D] SKILL.md의 `templates/` 참조 행 전부가 `이 skill 디렉토리의` 수식어를 포함하거나, 열거된 예외 2종(ai-workspace 명시 표기 행, context-harvest 매핑 표 행)에만 해당한다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -rn '`templates/' --include=SKILL.md . \
    | grep -v '이 skill 디렉토리의' \
    | grep -v '이 스킬 파일의 위치(`SKILL.md`가 있는 디렉토리)' \
    | grep -vE '^(\./)?context-harvest/SKILL\.md:[0-9]+:\| `[0-9]+_[a-z]+/`'
  ```

  - 설계 주의: 예외를 파일·행 패턴으로 열거해 그 외 신규 무수식 참조는 전부 위반으로 잡는다. `grep -rn ... .` 출력의 `./` 프리픽스는 grep 구현체에 따라 갈리므로(BSD/GNU grep은 붙이고 ugrep은 붙이지 않는다) 예외 패턴 앵커를 `^(\./)?`로 두어 양쪽을 모두 수용한다.
  </details>
- [x] [D] context-harvest 매핑 표의 도입 문장이 표 안 `templates/` 경로의 해석 기준을 명시하고, 예외로 허용한 표 행은 정확히 3행이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -q '아래 표의 `templates/` 경로도 모두 이 skill 디렉토리 기준이다' context-harvest/SKILL.md \
    || echo '위반: 매핑 표 도입 문장에 기준 명시 누락'
  c=$(grep -cE '^\| `[0-9]+_[a-z]+/` \([^)]*\) \| `templates/[0-9]+_[a-z]+-template\.md` \|$' context-harvest/SKILL.md)
  [ "$c" -eq 3 ] || echo "위반: 매핑 표 행 수 $c ≠ 3"
  ```

  - 설계 주의: 첫 검증만 통과시키고 표 행을 늘리면 무수식 참조가 예외로 숨을 수 있어, 예외 행 수 상한(3행)을 함께 판정에 넣는다.
  </details>
- [x] [D] `이 스킬 디렉토리의` 표기가 SKILL.md에 잔존 0건이다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -rn '이 스킬 디렉토리의' --include=SKILL.md .
  ```

  </details>
- [x] [D] SKILL.md 변경이 대상 5개 파일로 한정된다 (범위 밖 스킬 미변경)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  diff <(git diff --name-only origin/main -- '*SKILL.md' | sort) \
       <(printf '%s\n' ai-workspace/SKILL.md context-harvest/SKILL.md context-save/SKILL.md issue-work/SKILL.md readme-sync/SKILL.md | sort)
  ```

  - 설계 주의: 이슈 문서(`.ai/` 하위)는 pathspec `*SKILL.md`로 걸러져 비교 대상에 들어오지 않는다.
  </details>
- [ ] [ND] 문구 수정이 각 스킬의 절차·동작 의미를 바꾸지 않는다  (검증: 사람 리뷰)  ← 강등 사유: 의미 보존 여부는 문장 의미 판단이라 명령으로 환원 불가

---

## 전제 (Assumptions)

- repo의 SKILL.md가 SSoT다 — `~/.claude/skills/` 등 설치본은 이 이슈에서 갱신하지 않으며, 머지 후 install-skills 재실행으로 반영한다.
- 이슈 본문의 현황 조사(21곳)는 PR #81 머지 후 main 기준이며, 브랜치 생성 시점(2026-08-08)에 동일 grep으로 재검증해 일치를 확인했다. 행 번호는 참고값이고 plan은 문자열 기준으로 수정 대상을 특정한다.
- 검토 후 버린 대안: 전체를 ai-workspace의 장문 명시형("이 스킬 파일의 위치(`SKILL.md`가 있는 디렉토리)를 기준으로")으로 통일하는 안 — 이슈 본문이 현행 다수 표기(`이 skill 디렉토리의`, 9곳)를 기준으로 확정해 버렸다.
- context-harvest 5단계(문서 생성)와 산출물 템플릿 도입 문장의 수정 후 문구는 plan Task 1의 확정 문자열을 그대로 쓴다 — 표현을 재량으로 바꾸면 DoD 2번 grep이 실패한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/10_rules/writing-principles.md` | 이슈 문서·PR 본문 등 산출물 서술 원칙 (SKILL.md 본문 자체는 적용 제외) |
| `.ai/90_issues/archive/issue-0080/` | 선행 이슈 — git-qa 한 파일 안의 같은 불일치를 PR #81 리뷰 반영으로 보정 (명시 요청 시에만 읽음) |

> `.ai/30_contract/`·`.ai/40_domain/`·`.ai/50_adr/` index를 훑었으나 이 이슈와 관련된 항목 없음 (ADR 0001은 테스트 배치 규약이라 무관).
