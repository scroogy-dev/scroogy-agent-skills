# issue-work 스킬 단건 재점검 보고서 (2026-06-12, v2)

- **대상**: `issue-work/SKILL.md` + `templates/` 4종
- **기준선**: 직전 점검(skill-audit-issue-work-2026-06-12.md, 116줄 · ⚠️ 경미한 개선 3건) 이후 반영분
- **변경 범위 (git diff `58900ad..fb0abc8`)**: SKILL.md 116줄 → 118줄 (+2줄, 3 삽입/1 삭제),
  issue-workflow-template.md 36줄 → 38줄 (+2줄). 그 외 templates/ 3종 변경 없음.
  - 커밋: `fb0abc8` feat(issue-work): --clear 옵션 skill-creator 점검 피드백 반영 (#15)
  - 작업 트리 clean — 미커밋 변경 없음

## 종합 판정: ✅ 개선 3건 모두 정상 반영, 회귀 없음

직전 보고서의 수정안 3건이 제안 문구 그대로 반영되었고, 변경으로 인한 신규 문제는 발견되지 않음.

## 1. 개선 3건 반영 여부

| # | 점검 항목 | 상태 | 판정 |
|---|----------|------|------|
| 1-1 | `--clear` 3단계 이슈 번호 매핑 규칙 | SKILL.md 109행에 "디렉토리명 `issue-<번호>`에서 앞자리 0을 제거해 사용한다 (예: issue-0015 → #15)" 추가. 설계 문서(issue-0015) 결정 사항과 일치 | ✅ |
| 1-2 | 템플릿 "이슈 완료 시"에 `--clear` 안내 | issue-workflow-template.md 39행에 안내 1줄 추가. 컨텍스트 초기화 후에도 `--clear` 존재를 인지 가능. 템플릿은 스킬 외부에서 단독으로 읽히므로 "issue-work `--clear`"로 스킬명을 명시한 것도 적절 | ✅ |
| 1-3 | `--clear` 5단계 정리 범위·notes/ 취급 | SKILL.md 112~113행에 "재귀로 보여주고", "`.gitkeep`은 항상 보존, `notes/`는 context-save 산출물이므로 기본 보존 — 사용자가 요청할 때만 정리 대상에 포함" 명시. context-save 스킬이 실제로 `.ai/99_workspace/notes/`에 저장함을 교차 확인 — 서술 사실과 일치 | ✅ |

## 2. 회귀(regression) 점검

| # | 점검 항목 | 상태 | 판정 |
|---|----------|------|------|
| 2-1 | frontmatter 유효성 | `quick_validate` 통과 ("Skill is valid!"). name 규칙 적합. description 162자 — 직전과 동일(이번 변경에서 frontmatter 미수정) | ✅ |
| 2-2 | 시작/진행/완료 워크플로우 | 본문 절차 미변경. `## 이슈 완료 시`(1~3단계) ↔ `--clear` 1·2·4단계 대응 관계 유지, 118행 양방향 포인터 주석도 그대로 유효 | ✅ |
| 2-3 | `--workflow-only` 정합성 | 해당 섹션 미변경. 템플릿에 추가된 `--clear` 안내는 절차 가이드 보강일 뿐 `--workflow-only`의 생성·덮어쓰기 동작과 무관 | ✅ |
| 2-4 | `--resume` 정합성 | `--resume`은 99_workspace를 재귀로 **읽고**, `--clear`는 재귀로 **정리** — 5단계의 "재귀" 명시로 두 옵션의 탐색 범위가 오히려 일치하게 됨. notes/ 기본 보존은 context-save가 명시한 `--resume` 복구 흐름(노트를 다음 세션에 복구)과도 충돌 없음 | ✅ |
| 2-5 | SKILL.md ↔ templates/ 정합성 | 템플릿 4종 모두 존재, 깨진 포인터 없음. "이슈 완료 시" 3단계가 SKILL.md와 템플릿에서 동일하게 유지되고, 양쪽 모두 `--clear` 안내 보유 — 직전 점검의 비대칭(SKILL.md에만 안내 존재) 해소 | ✅ |
| 2-6 | progressive disclosure | 본문 118줄(+2) — 권장 한도(500줄) 대비 여유 충분. references/ 분리 불필요 | ✅ |
| 2-7 | 변경 파일 범위 | 변경은 SKILL.md `--clear` 섹션 2개 hunk + 템플릿 말미 2줄로, 직전 보고서 수정안 범위를 벗어난 변경 없음 | ✅ |

## 3. 미반영·불완전 반영 항목

없음. 3건 모두 직전 보고서의 수정안 문구가 사실상 그대로 적용됨.

## 변경분 외 참고 (이번 변경과 무관, 판정에 미반영)

- issue-workflow-template.md 파일 끝 개행 없음(no newline at EOF) — 변경 전부터 존재, 이번 커밋에서도 유지됨. 실해 없으나 다음 수정 시 개행 추가 권장. → **본 보고서 작성 후 반영됨, 아래 4절 참조**
- `issue-plan-template.md`·`issue-summary-template.md` 상단 링크 표기(`./issue-spec.md`) 불일치는 직전 보고서 그대로 잔존 — 당시에도 별도 이슈 처리 권장 사항이었으며 이번 점검 범위 아님. → **본 보고서 작성 후 반영됨, 아래 4절 참조**

## 4. 추가 점검: 참고 2건 반영 확인 (동일 기준 적용)

- **변경 범위 (git diff `fb0abc8` → 작업 트리, uncommitted)**: templates/ 4종만 변경. SKILL.md 변경 없음(118줄 유지).
  - plan 29→30줄, spec 35→36줄, summary 30→31줄, workflow 38→39줄 — 각 +1줄은 모두 EOF 개행 추가분

| # | 점검 항목 | 상태 | 판정 |
|---|----------|------|------|
| 4-1 | 링크 표기 통일 | plan-template 스펙 링크가 `[issue-<번호>-spec.md](./issue-<번호>-spec.md)`로, summary-template은 스펙·계획 링크 2개 모두 `<번호>` 표기로 수정됨. 직전 보고서 권장안과 일치하며, 권장안에 없던 summary의 plan 링크(`issue-plan.md`)까지 함께 통일 — 누락 없음. 구표기(`issue-spec.md` 등) 잔존 0건 grep 확인 | ✅ |
| 4-2 | EOF 개행 | 템플릿 4종 모두 파일 끝 개행 추가 확인(od 검사). 보고서가 지적한 workflow-template 외에 plan·spec·summary의 동일 문제까지 일괄 해소 | ✅ |
| 4-3 | 회귀: frontmatter | SKILL.md 미변경 — `quick_validate` 재실행 통과 ("Skill is valid!") | ✅ |
| 4-4 | 회귀: 내용 변경 여부 | diff상 내용 변경은 링크 표기 2개 hunk뿐, 나머지는 전부 EOF 개행. 워크플로우 절차·`--clear`·템플릿 구조에 영향 없음 | ✅ |
| 4-5 | 회귀: SKILL.md ↔ templates/ 정합성 | 수정된 링크 표기가 SKILL.md의 파일명 규칙(`issue-<번호>-spec.md` 등) 및 workflow-template 표기와 일치하게 됨 — 정합성 오히려 개선 | ✅ |
| 4-6 | progressive disclosure | SKILL.md 118줄 유지, 템플릿 합계 +4줄(개행분) — 한도 무관 | ✅ |

**판정: ✅ 참고 2건 모두 정상 반영, 회귀 없음.** 미반영·불완전 반영 항목 없음.

참고: 작업 트리에 `.ai/90_issues/active/issue-0015/`의 plan·summary 수정도 함께 존재하나, 이는 이슈 진행 기록이며 스킬 파일이 아니므로 점검 범위 외.
