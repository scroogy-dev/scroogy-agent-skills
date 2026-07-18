# Issue #46 스펙 — issue-audit 표기를 한글 우선 병기로 전환

> 이슈: [scroogy-dev/scroogy-agent-skills#46](https://github.com/scroogy-dev/scroogy-agent-skills/issues/46)

## 목표 (Goal)

issue-audit 산출물 분류 값의 영문 단독 표기 3종(위험도·판정 값·단계 명명)을 repo 표기 관례(한글 우선 + 영문 병기)로 전환한다. 표기만 바꾸고 의미 문구는 유지한다.

---

## 범위 (Scope)

**포함 (In)**

- **위험도** — HIGH/MEDIUM/LOW/INFO → 높음(HIGH)/중간(MEDIUM)/낮음(LOW)/정보(INFO)
  - `issue-audit/SKILL.md` 위험도 분류 표 1열
  - `issue-audit/SKILL.md` 출력 요약 형식의 위험도 집계 줄
  - `issue-audit/templates/issue-audit-report-template.md` 위험도 필드
- **판정 값** — PASS/FAIL/PARTIAL/N/A → 충족(PASS)/미충족(FAIL)/부분 충족(PARTIAL)/판정 불가(N/A) (Task 0에서 확정 — 전제 참조)
  - `issue-audit/SKILL.md` 판정 기준 표 1열
  - `issue-audit/SKILL.md` 출력 요약 형식의 판정 집계 줄
  - `issue-audit/templates/issue-audit-report-template.md` 판정 필드 — 실물 확인 결과 판정 값 리터럴이 없어(판정 열의 셀이 비어 있음) 전환 대상 0건 확인만 수행 (전제 참조)
- **단계 명명** — Phase 1/Phase 2 → 1단계/2단계 (Task 0에서 확정 — 전제 참조)
  - `issue-audit/SKILL.md` 개요 항목·절차 제목·본문 참조·출력 요약 형식의 단계 제목
  - `issue-audit/templates/issue-audit-report-template.md` 단계 제목 2곳

**비포함 (Out)**

- `install-skills`의 PASS/FAIL — `verify-install.sh` 스크립트 출력 토큰(코드 식별자)이라 유지 (`references/antigravity-legacy.md`의 인용 포함)
- `ai-workspace-directory`의 `confidence: high/medium/low` — 기계 판독용 YAML 값이라 유지
- 모드·프로파일 값(`init`/`update`, `dev`/`doc` 등) — CLI 옵션 인자라 유지
- `.ai/90_issues/archive/` 과거 리포트·요약 — 완료 이슈의 이력 기록이라 소급하지 않음
- 위험도·판정 표의 의미 문구(2열)와 절차 서술의 내용 변경 — 이 이슈는 1열·명명 표기 전환만 수행

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> 모든 명령은 repo 루트 기준. 판정 값 한글 명칭·단계 표기는 Task 0에서 확정된 값(전제 참조)이 아래 패턴에 반영되어 있다.

- [x] [D] 위험도 표 1열 4행이 한글 우선 병기이고 영문 단독 1열 행이 0건 (검증: `grep -cE '^\| (높음\(HIGH\)|중간\(MEDIUM\)|낮음\(LOW\)|정보\(INFO\)) \|' issue-audit/SKILL.md` = 4 && `grep -cE '^\| (HIGH|MEDIUM|LOW|INFO) \|' issue-audit/SKILL.md` = 0)
- [x] [D] 판정 기준 표 1열 4행이 한글 우선 병기이고 영문 단독 1열 행이 0건 (검증: `grep -cE '^\| (충족\(PASS\)|미충족\(FAIL\)|부분 충족\(PARTIAL\)|판정 불가\(N/A\)) \|' issue-audit/SKILL.md` = 4 && `grep -cE '^\| (PASS|FAIL|PARTIAL|N/A) \|' issue-audit/SKILL.md` = 0)
- [x] [D] 위험도·판정 표의 의미 문구(2열 이후)가 전환 전과 동일 (검증: `diff <(git show main:issue-audit/SKILL.md | grep -E '^\| (HIGH|MEDIUM|LOW|INFO) \|' | cut -d'|' -f3-) <(grep -E '^\| (높음\(HIGH\)|중간\(MEDIUM\)|낮음\(LOW\)|정보\(INFO\)) \|' issue-audit/SKILL.md | cut -d'|' -f3-)` 차이 0건 && 판정 표도 같은 방식 — `diff <(git show main:issue-audit/SKILL.md | grep -E '^\| (PASS|FAIL|PARTIAL|N/A) \|' | cut -d'|' -f3-) <(grep -E '^\| (충족\(PASS\)|미충족\(FAIL\)|부분 충족\(PARTIAL\)|판정 불가\(N/A\)) \|' issue-audit/SKILL.md | cut -d'|' -f3-)` 차이 0건)
- [x] [D] Phase 표기 잔존 0건 (검증: `grep -c 'Phase' issue-audit/SKILL.md` = 0 && `grep -c 'Phase' issue-audit/templates/issue-audit-report-template.md` = 0)
- [x] [D] 출력 요약 형식의 집계 줄이 병기 표기 (검증: `grep -c '충족(PASS): N건 / 미충족(FAIL): N건 / 부분 충족(PARTIAL): N건 / 판정 불가(N/A): N건' issue-audit/SKILL.md` = 1 && `grep -c '높음(HIGH): N건 / 중간(MEDIUM): N건 / 낮음(LOW): N건 / 정보(INFO): N건' issue-audit/SKILL.md` = 1) — 판정 집계는 당초 원본 3종 유지였으나 PR #49 리뷰 보정으로 판정 불가(N/A)를 더해 4종 완결(패턴 동반 갱신)
- [x] [D] 리포트 템플릿의 위험도 필드가 병기 표기 (검증: `grep -c '높음(HIGH) / 중간(MEDIUM) / 낮음(LOW) / 정보(INFO)' issue-audit/templates/issue-audit-report-template.md` = 1 && `grep -cE 'HIGH / MEDIUM / LOW / INFO' issue-audit/templates/issue-audit-report-template.md` = 0)
- [x] [D] 변경 파일이 대상 스킬과 이슈 문서로 한정 (검증: `git diff --name-only main | grep -vE '^(issue-audit/|\.ai/90_issues/)'` = 0건)
- [x] [QD] 본문 참조 서술(개요 항목, 참조 문서의 단계 언급 등)이 새 단계 명명과 의미상 정합 (검증: Task N 교차모델 audit 채점) ← 강등 사유: 서술 자연스러움·의미 정합은 명령으로 환원 불가

---

## 전제 (Assumptions)

- **표기 관례**: 산출물의 분류·항목 값은 한글 우선 + 영문 병기 — #45 진행 중 사용자 지시(2026-07-17)로 확립된 repo 관례. 기존 스킬과의 표기 일치보다 관례가 우선하며, 이 이슈가 그 "기존 스킬 쪽 정렬"이다.
- **#45 폐기로 선행 조건 무효**: 이슈 본문 "유의"의 "#45 완료 후 진행" 조건은 #45 폐기(2026-07-18, 브랜치 미머지 삭제)로 무효가 됐다 — main에 code-inspection이 없어 issue-audit의 영문 1열 리터럴을 참조하는 검증 명령이 존재하지 않는다.
- **검증 앵커 방식**: 표 1열의 백틱 없는 `한글(대문자 영문)` 병기 리터럴을 grep 앵커로 쓴다 — #45에서 확립한 방식과 동일. DoD의 행 구조 검증 명령이 이 표기에 의존한다.
- **구현 시 확정 위임 항목**: 판정 값 한글 명칭과 단계 표기는 이슈가 "구현 시 확정"으로 위임했고, Task 0 게이트에서 사용자가 확정했다(2026-07-18) — 판정 값은 충족(PASS)/미충족(FAIL)/부분 충족(PARTIAL)/판정 불가(N/A)로, 이슈 잠정안의 "통과" 대신 "충족"을 써서 미충족·부분 충족과 같은 계열로 통일한다. 단계 표기는 1단계/2단계.
- **단계 번호 정합**: `## 절차`가 이미 `0단계: 컨텍스트 수집`·`3단계: 결과 기록`을 쓰고 있어, Phase 1/Phase 2를 1단계/2단계로 바꾸면 0~3단계 연속 번호가 된다. 제목의 영문 부제(`(Compliance Check)`·`(Critical Review)`)는 병기로 유지한다.
- **템플릿 판정 리터럴 부재**: 이슈 본문은 리포트 템플릿의 "판정 필드"를 대상에 넣었지만, repo 확인 결과(2026-07-18) 템플릿의 판정 열은 빈 셀이라 전환할 리터럴이 없다. 확인만 수행하고, 허용 값 안내 주석 추가는 최소 변경 원칙에 따라 하지 않는다.
- **전수 확인 결과**: Phase·위험도·판정 리터럴 사용처는 `issue-audit/` 하위 2개 파일뿐이다(2026-07-18 grep 전수 확인). 비포함의 install-skills PASS/FAIL·YAML confidence 값은 이 이슈에서 건드리지 않는다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| [issue-audit/SKILL.md](../../../../issue-audit/SKILL.md) | 전환 대상 본체 |
| [issue-audit/templates/issue-audit-report-template.md](../../../../issue-audit/templates/issue-audit-report-template.md) | 전환 대상 템플릿 |
| [.ai/10_rules/writing-principles.md](../../../10_rules/writing-principles.md) | 산출물 작성 원칙 |
| [.ai/AI-CONTEXT.md](../../../AI-CONTEXT.md) | 스킬 작성 규칙(언어·표기) |

> `.ai/30_contract/`·`.ai/40_domain/`·`.ai/50_adr/` index 훑기 결과(2026-07-18) 이 이슈와 직접 관련된 계약·도메인·ADR 문서는 없다 (ADR 0001은 스크립트 헬퍼 규칙이라 미해당).
