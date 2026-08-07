# Issue #74 스펙 git-pr 긴 산출물 중복 생성 제거 — 본문은 99_workspace 파일로, 대화에는 요약만

## 목표 (Goal)

긴 산출물(PR 제목·본문, `--clear` 이슈 댓글)을 `.ai/99_workspace/` 파일에 1회만 생성하고 대화에는 경로+요약만 제시해, 같은 텍스트를 두 번 생성하는 응답 지연을 없앤다.

---

## 범위 (Scope)

**포함 (In)**

- `git-pr` 3단계(최종 제시 및 승인): 본문 전문 대화 출력을 "파일 경로 + 요약(리스크·결정사항)" 제시로 대체
- `git-pr` 저장 위치 `.ai/99_workspace/`·파일명 규약(`pr-<이슈번호>-title.md`·`pr-<이슈번호>-body.md`) 명시
- `git-pr` 4단계: PR 생성·head SHA 대조 통과 직후 임시 파일 삭제 질의(A) + 잔존분은 `issue-work --clear` 5단계가 회수(B) 명시
- `issue-work --clear` 3단계: 이슈 댓글 초안에 동일 규칙 적용 (`issue-<번호>-comment.md`)

**비포함 (Out)**

- `git-review`의 `temp_review_result.md` — 이미 파일 1회 생성 선례라 변경 없음
- 짧은 산출물(커밋 메시지 등) — 중복 비용이 미미해 현행 유지
- 설치된 스킬 사본(`~/.claude/skills/` 등) 재배포 — `install-skills`로 별도 수행

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [x] [D] `git-pr/SKILL.md`에 저장 위치 `.ai/99_workspace/`와 파일명 규약 2종이 명시된다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  F=git-pr/SKILL.md
  grep -qF '.ai/99_workspace/' "$F" || echo '위반: 저장 위치 누락'
  grep -qF 'pr-<이슈번호>-title.md' "$F" || echo '위반: 제목 파일명 규약 누락'
  grep -qF 'pr-<이슈번호>-body.md' "$F" || echo '위반: 본문 파일명 규약 누락'
  ```

  </details>
- [x] [D] `git-pr/SKILL.md` 3단계에 본문 전문 대화 출력 금지 문구가, 4단계에 삭제 질의와 `--clear` 회수 경로가 명시된다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  F=git-pr/SKILL.md
  grep -qF '전문을 대화에 출력하지 않' "$F" || echo '위반: 전문 출력 금지 문구 누락'
  grep -qF '삭제할지 질의' "$F" || echo '위반: 삭제 질의 절차 누락'
  grep -qF -- '--clear' "$F" || echo '위반: 잔존 회수 경로 누락'
  ```

  - 설계 주의: 고정 문구 anchor 검증이다 — 구현에서 표현을 바꾸면 이 명령도 같이 갱신한다. 문구 실재만 판정하며, 규정의 의미 강제는 아래 [QD]가 채점한다.
  </details>
- [x] [D] `issue-work/SKILL.md` `--clear` 3단계에 댓글 파일 규약과 전문 출력 금지 규정이 명시된다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  F=issue-work/SKILL.md
  grep -qF 'issue-<번호>-comment.md' "$F" || echo '위반: 댓글 파일명 규약 누락'
  grep -qF '전문을 대화에 출력하지 않' "$F" || echo '위반: 전문 출력 금지 문구 누락'
  ```

  </details>
- [ ] [QD] 변경 규정이 "파일 1회 생성 → 대화에는 경로+요약 → 승인 게이트 유지" 흐름을 문면상 강제하고, 기존 승인 게이트·산출물 접기 기준과 모순이 없다  (검증: 교차모델 audit 채점)  ← 강등 사유: 문구 실재 grep만으로는 규정의 의미 강제·모순 여부를 판정할 수 없다

---

## 전제 (Assumptions)

- 정리 타이밍은 **A+B 병행**으로 사용자 확정(2026-08-07 대화): `git-pr` 4단계 head SHA 대조 통과 직후 삭제 질의(거절 시 보존) + 잔존분은 `issue-work --clear` 5단계가 회수. `--clear` 5단계는 이미 `99_workspace`를 재귀로 정리하므로 회수를 위한 `issue-work` 쪽 규정 변경은 불필요하고, `git-pr` 쪽에 회수 경로를 언급만 한다.
- `--clear` 3단계 이슈 댓글에도 동일 규칙 적용으로 사용자 확정(같은 대화). 댓글 파일은 같은 `--clear` 실행의 5단계가 곧바로 회수하므로 별도 정리 타이밍 규정이 필요 없다.
- 파일명 규약: `pr-<이슈번호>-title.md`·`pr-<이슈번호>-body.md`, 댓글은 `issue-<번호>-comment.md`(기존 `issue-<번호>-audit-report.md` 명명과 정합). 확장자는 **`.md`로 통일**한다 — 이슈 #74 본문 예시는 제목에 `.txt`였으나 사용자가 통일로 확정(2026-08-07 대화). 통합 배포(여러 이슈 1 PR)면 `<이슈번호>`는 PR 제목에 나열하는 첫 이슈 번호를 쓴다.
- 파일 경로 제시도 승인 게이트의 "제시"에 해당한다(이슈 #74 본문 합의) — 게이트 절차 자체는 변경하지 않는다.
- 완료의 정의 [D] 항목의 고정 문구 anchor("전문을 대화에 출력하지 않", "삭제할지 질의")는 구현 본문에 그대로 포함한다.
- `.ai/99_workspace/`가 없는 프로젝트에서는 **디렉토리를 생성하고 그대로 사용**한다(대화 출력 폴백 없음)로 사용자 확정(2026-08-07 Task 0 게이트). `git-review`가 `.ai/99_workspace/temp_review_result.md`를 조건 없이 쓰는 선례와 같은 방식이며, 분기를 두지 않아 실행 환경에 따라 동작이 갈리지 않는다.
- `git-pr` 3단계 밖의 "최종 제목·본문을 남긴 채 종료" 문구 4곳(1단계 포크 미지원, 3단계 승인 거절, 4단계 생성 수단 부재·MCP host 제한)도 **모두 파일 경로 안내로 갱신**한다로 사용자 확정(같은 게이트). spec 범위(3단계)를 소폭 넘지만, 남겨두면 같은 스킬 안에 "대화에 텍스트가 남는다"는 어긋난 안내가 공존한다.
- 파일명의 이슈번호 표기는 근거가 달라 갈린다 — PR 파일은 PR 제목에 나열하는 GitHub 이슈 번호를 그대로 써 `pr-74-title.md`(앞자리 0 없음), 댓글 파일은 이슈 디렉토리명 기준이라 `issue-0074-comment.md`(4자리 패딩, 기존 `issue-0074-audit-report.md` 선례와 정합).

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `git-pr/SKILL.md` | 변경 대상 — 2·3·4단계 파일 생성·제시·정리 절차 |
| `issue-work/SKILL.md` | 변경 대상 — `--clear` 3단계 댓글 규칙 |
| `git-review/SKILL.md` | 파일 1회 생성 선례(`temp_review_result.md`) — 참조만, 변경 없음 |
| `.ai/10_rules/writing-principles.md` | 산출물 접기·분량 원칙 — 요약 제시 형식의 근거 |

> `30_contract`·`40_domain`·`50_adr` index를 훑었으며 이 이슈와 직접 관련된 계약·도메인·ADR 문서는 없음 (ADR 0001은 테스트 배치 규칙이라 무관).
