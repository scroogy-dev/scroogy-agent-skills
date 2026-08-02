# Issue #66 스펙 — issue-work 완료 기준 가독성 개선: 항목은 문장으로, 검증 상세는 접기로

## 목표 (Goal)

spec `완료의 정의`·plan Task `완료 기준` 항목을 "문장으로 읽고, 검증 상세는 펼쳐서 확인"하는 구조로 바꾼다 — 본문(접기 금지)은 레벨 태그 + 보장 내용 한 문장(+ 강등 사유), 접기(`<details>`)는 검증 명령·테스트케이스·기대 출력·명령 설계 주의점.

---

## 범위 (Scope)

**포함 (In)**

- `issue-work/templates/issue-spec-template.md` — `완료의 정의` 항목 형식 변경 (안내 주석 + 예시)
- `issue-work/templates/issue-plan-template.md` — Task `완료 기준` 형식 변경, Task 0·Task N 고정 블록 포함
- `issue-work/SKILL.md` — 형식 규칙 명시 (본문=문장·레벨 태그·강등 사유 / 접기=검증 명령·테스트케이스·기대 출력)
- `issue-work/tests/run-tests.sh` — 게이트 명령 추출 로직의 새 형식 대응 (템플릿 본문이 명령의 SSoT이므로 형식 변경에 따라 추출도 갱신)

**비포함 (Out)**

- 이미 작성된 활성·archive 이슈 문서의 소급 수정 — 템플릿 변경 후 새로 인스턴스화되는 이슈부터 적용
- `issue-summary-template.md`·`issue-workflow-template.md` — 완료 기준 형식이 없어 대상 아님
- `~/.claude/skills/` 설치본 반영 — `install-skills` 재실행으로 별도 수행

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D] spec 템플릿 `완료의 정의` 예시에 접기 구조가 실재  (검증: repo 루트에서 `grep -c '<details>' issue-work/templates/issue-spec-template.md` ≥ 1 그리고 `grep -c '</details>' issue-work/templates/issue-spec-template.md`가 같은 값)
- [ ] [D] plan 템플릿의 일반 Task 예시와 Task N 고정 블록 양쪽에 접기 구조가 실재  (검증: repo 루트에서 `awk '/^### Task N/{n=1} /<details>/{if(n)tn++; else t++} END{print (t>=1 && tn>=1) ? 0 : 1}' issue-work/templates/issue-plan-template.md` 출력 0)
- [ ] [D] SKILL.md에 완료 기준 형식 규칙이 기재  (검증: repo 루트에서 `grep -c '완료 기준 형식' issue-work/SKILL.md` ≥ 1 — 구현 시 이 문구를 규칙 앵커로 사용)
- [ ] [D] 기존 `[D]` 앵커 기반 검증 명령이 새 형식에서도 통과  (검증: `bash issue-work/tests/run-tests.sh` 종료 코드 0, 출력 마지막 행 `failed: 0`)
- [ ] [QD] 본문·접기 배치가 제안 형식과 일치하고 접기 금지 기준(writing-principles: 결정사항·리스크·액션 아이템)과 불일치 없음  (검증: 교차모델 audit이 채점)  ← 강등 사유: 형식 일치·규칙 간 정합은 의미 대조라 명령으로 환원 불가
- [ ] [ND] 리스트 항목 하위에 들여쓴 `<details>`가 GitHub에서 접힘/펼침으로 정상 렌더링  (검증: 사람이 GitHub 파일 뷰에서 확인)  ← 강등 사유: 렌더링 결과는 화면 판정이라 명령으로 환원 불가

---

## 전제 (Assumptions)

- 게이트 명령의 SSoT는 plan 템플릿 본문이며 `run-tests.sh`가 `extract_gate`/`extract_pair_gate`(sed 인라인 코드 스팬 추출)로 꺼내 실행한다 — 완료 기준을 접기 안 코드 블록으로 옮기면 이 추출이 깨지므로 추출 로직 갱신이 범위에 포함된다. 명령을 `scripts/` 헬퍼로 분리하는 대안은 인스턴스화된 plan의 자족성 때문에 기각되어 있다(`run-tests.sh` 상단 주석, ADR 0001).
- 수정 대상은 repo의 `issue-work/`(SSoT)다. `~/.claude/skills/` 설치본은 수정하지 않으며, 반영은 `install-skills` 재실행으로 한다.
- 이 이슈 자체의 문서 3종(issue-0066)은 변경 전 템플릿(구형식)으로 작성되었고 소급 수정하지 않는다 — "신규 작성분부터 적용"은 템플릿 변경 머지 후 인스턴스화되는 이슈부터라는 뜻이다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/10_rules/writing-principles.md` | 접기 규칙 SSoT — 접기 금지 기준(결정사항·리스크·액션 아이템) 정합 판정 기준 |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | `tests/` 배치·러너·배포 제외 관례 — `run-tests.sh` 수정 시 준수 |
| `.ai/90_issues/archive/issue-0060/` | 이력 참조(필요 시) — 스킬 전반 접기 적용 지점 명시(#60), 이 이슈의 선행 |
| `.ai/90_issues/archive/issue-0050/` | 이력 참조(필요 시) — 검증 레벨 표기 도입(#50), 레벨 태그 형식의 기반 |
