# Issue #84 스펙 install-skills 설치 결과 출력 형식 templates/ 분리

## 목표 (Goal)

`install-skills` 설치 결과 보고 형식을 `templates/install-result-template.md`로 고정해, 같은 설치 명령을 어느 세션에서 실행해도 보고 모양이 같아지게 한다.

---

## 범위 (Scope)

**포함 (In)**

- `install-skills/templates/install-result-template.md` 신설 (`templates/` 디렉토리도 함께 신설)
- SKILL.md 8단계를 템플릿 참조로 교체 — 표기는 "이 skill 디렉토리의 `templates/install-result-template.md`" (#82 통일 형식)
- `.ai/AI-CONTEXT.md` 디렉토리 구조의 `install-skills/` 항목에 `templates/` 추가
- self-install(`--self`) 배포 시 `templates/` 포함 확인 — 절차 변경 없이 성립하는지 검증

**비포함 (Out)**

- 설치 절차 1~7단계·`verify-install.sh` 헬퍼의 동작 변경
- 다른 스킬의 산출물 형식 변경
- `RESULT: PASS`/`FAIL` 판정 로직 변경 — 헬퍼가 결정한 값을 어떻게 보고할지만 다룬다

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [x] [D] `install-skills/templates/install-result-template.md`가 존재하고 SKILL.md 8단계가 이 템플릿을 참조한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  test -f install-skills/templates/install-result-template.md \
    && grep -qE '^8\. .*templates/install-result-template\.md' install-skills/SKILL.md \
    || echo '위반: 템플릿 부재 또는 8단계 참조 누락'
  ```

  - 설계 주의: 참조 문장은 8단계 첫 행에 둔다 — 앵커 `^8\. `가 행 단위라, 참조가 부속 행으로 밀리면 이 검증이 참조를 놓친다.
  </details>
- [x] [D] 8단계의 옛 서술("대상 경로별로 출력")이 SKILL.md 본문에 남아 있지 않다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -n '대상 경로별로 출력' install-skills/SKILL.md
  ```

  </details>
- [x] [QD] SKILL.md 본문에 출력 형식을 직접 서술한 문장이 남아 있지 않다  (검증: 교차모델 audit이 본문 전수 채점)  ← 강등 사유: "형식 서술"인지 "동작 설명"인지는 의미 판단이라 문구 grep으로 환원 불가 — 위 [D]는 옛 문구 1종만 차단한다
- [x] [D] `.ai/AI-CONTEXT.md` 디렉토리 구조의 `install-skills/` 블록에 `templates/`가 반영되어 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -A4 '^├── install-skills/' .ai/AI-CONTEXT.md | grep -q 'templates/' \
    || echo '위반: AI-CONTEXT install-skills 블록에 templates/ 없음'
  ```

  - 설계 주의: 블록 하위가 4행(references·scripts·templates·tests)이 되므로 `-A4`로 잡는다 — 하위 디렉토리가 늘면 범위를 같이 늘린다.
  </details>
- [x] [D] self-install 배포 목록에 `templates/install-result-template.md`가 포함된다 — 제외 패턴(`tests/`, `*.test.*`)이 `templates/`를 건드리지 않아 절차 변경 없이 성립한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  rsync -r --exclude 'tests/' --exclude '*.test.*' --list-only install-skills/ \
    | grep -q 'templates/install-result-template.md' \
    || echo '위반: 배포 목록에 템플릿 없음'
  ```

  - 설계 주의: `--exclude` 2종은 SKILL.md 5단계(제외 패턴의 단일 출처)와 동일하게 유지한다 — 5단계 패턴이 바뀌면 이 명령도 따라 바꾼다.
  </details>

---

## 전제 (Assumptions)

- 설치 결과 보고는 파일 산출물이 아니라 **대화 출력**이다 — git-pr·git-review 템플릿은 `.ai/99_workspace/` 파일을 쓰지만, 이 템플릿은 8단계에서 사용자에게 보고하는 대화 출력의 구조 기준이다. 이슈 본문은 "출력 형식"이라고만 적어 산출 매체가 명시돼 있지 않다.
- 템플릿 섹션명은 이슈의 "템플릿 초안 항목" 3종을 그대로 승격해 `경로별 결과`·`설치된 skill 목록`·`적용 옵션 내역`으로 고정한다 — plan Task 1 검증 명령의 앵커로 쓰므로 구현 시 임의 개명하지 않는다.
- 설치된 skill 목록의 설명은 frontmatter `description`의 **한 줄 요약본**을 노출한다 — 원문 전량 전재가 아니다. 템플릿이 고정하는 대상은 보고 구조이지 설명 문구가 아니며, 요약 문구는 세션마다 다를 수 있다 (3차 audit F-1 대응, 사용자 확정).
- 템플릿 참조 표기는 #82 통일 형식 "이 skill 디렉토리의 `templates/<파일명>`"을 그대로 쓴다 — 설치본에서도 상대 참조가 깨지지 않게 하는 repo 관례.
- 파일 본문에 이모지를 쓰지 않는다 (repo 관례 — 사용자 피드백). 검증 결과는 `PASS`/`FAIL` 텍스트로 표기한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 배포 제외 패턴(`tests/`) 규칙 배경 — DoD "배포 포함" 항목의 근거 |
| `.ai/AI-CONTEXT.md` | 디렉토리 구조 갱신 대상 (Task 3) |
