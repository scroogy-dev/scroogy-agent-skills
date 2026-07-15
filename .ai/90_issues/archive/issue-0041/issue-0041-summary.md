# Issue #41 실행요약 — ai-workspace writing-principles 참조 경로 보강

> 스펙: [issue-0041-spec.md](./issue-0041-spec.md) | 계획: [issue-0041-plan.md](./issue-0041-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다.

## 모델 기록

| 구분 | 모델 |
|------|------|
| 계획·구현 모델 | Anthropic, Claude Fable 5 (claude-fable-5) |
| audit 모델 | OpenAI, GPT-5 |

---

## Task별 수행 결과

### Task 1: 템플릿 context-loading.md에 산출물 작성 라우팅 섹션 추가

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - 템플릿 작업 유형 목록에 `## 산출 문서·PR·이슈·리뷰 코멘트 작성 시` 섹션 추가 (외부 API·계약 변경 시 섹션 뒤)
  - 내용 2줄: `writing-principles.md`(산출물 작성 원칙, 소스 코드 미적용) + `writing-principles-local.md`(repo 고유 확장, 충돌 시 local 우선)
  - 검증 통과: `grep -c 'writing-principles' ai-workspace/templates/shared/.ai/10_rules/context-loading.md` = 2 (≥ 2)
- **특이 사항**: 섹션 표기·설명 문구는 AI-CONTEXT 템플릿 `## 프로젝트 규칙` 표의 표준 행("사용 시점" 열)과 일치시킴

---

### Task 2: ai-workspace/SKILL.md 멱등 보강 검사에 프로젝트 규칙 행 검사 추가

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - update-4단계 멱등 보강 검사 표에 `## 프로젝트 규칙` 표의 `writing-principles.md` 행 검사 항목 추가 (`## 프로젝트 도메인` 행 다음 — AI-CONTEXT 본문 섹션 순서 기준)
  - 누락 시 조치: 표준 행 삽입(AI-CONTEXT 템플릿 행과 동일), 기존 사용자 작성 행 보존
  - 검증 통과: `grep -c '프로젝트 규칙.*writing-principles\|writing-principles.*프로젝트 규칙' ai-workspace/SKILL.md` = 1 (≥ 1)
- **특이 사항**: 표 셀 안에 마크다운 표 행 원문을 넣으면 파이프 충돌이 생겨, 표준 행은 열별 값 서술로 기재하고 템플릿 행 참조로 갈음

---

### Task 3: 이 repo 설치본·안내도 반영

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - `.ai/10_rules/context-loading.md`를 Task 1 반영본 템플릿으로 복사 갱신 (버전 고정 정책과 동일)
  - `.ai/AI-CONTEXT.md`의 `## 프로젝트 규칙` 표 끝에 `writing-principles.md` 표준 행 추가
  - 검증 통과: 템플릿-설치본 diff 0건, `grep -c 'writing-principles' .ai/AI-CONTEXT.md` = 1 (≥ 1)
- **특이 사항**: 없음

---

### Task 4: 홈 설치본 동기화

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - `rsync -a --delete`로 repo `ai-workspace/` → `~/.claude/skills/ai-workspace/` 동기화 (plan의 "동등한 복사" 경로)
  - 동기화 전 차이는 이번 이슈 변경 2건(SKILL.md 검사 행, 템플릿 라우팅 섹션)뿐임을 확인
  - 검증 통과: `diff -r ai-workspace ~/.claude/skills/ai-workspace` 차이 0건
- **특이 사항**: spec DoD [QD] "update 재실행 시 사용자 작성분 보존" 모의 실행 수행 — 사용자 행·인라인 규칙이 있는 모의 AI-CONTEXT에 새 멱등 보강 검사를 적용해 사용자 작성분 3건 보존·표준 행 삽입·재실행 무변경(멱등)을 확인

---

### Task 5: update-4 멱등 보강 검사에 context-loading.md 행 검사 추가 (일관성 보강)

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - 사용자 질의로 범위 확장 — 버전 고정 파일 2종은 "파일 무조건 덮어쓰기 + 안내도 행 없으면 삽입"을 같은 조건으로 통일 (spec 포함 범위·DoD 갱신)
  - 검사 표에 `context-loading.md` 행 검사 추가 (writing-principles 행 검사 바로 앞) — 사용 시점 문구 프로파일별 구분(dev/doc), 사용자 작성 행 보존
  - 이 repo `.ai/AI-CONTEXT.md`에는 해당 행이 이미 있어 확인만 수행, 홈 설치본 재동기화
  - 검증 통과: `grep -c '프로젝트 규칙.*context-loading\|context-loading.*프로젝트 규칙' ai-workspace/SKILL.md` = 1 (≥ 1), `diff -r` 0건
- **특이 사항**: 모의 실행 재확인 — context-loading 행이 없는 모의 표에 검사를 적용해 표 끝 삽입·사용자 행 보존·재실행 무변경(멱등) 확인

---

### Task 6: 교차모델 audit 발견사항 보정 (--response 승인분)

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - audit 리포트 **1차**(PASS 15 / PARTIAL 1, 발견 3건)를 `--response` 절차로 검토 — 피드백 제시 후 사용자가 항목별 승인 (F-1 반영, F-2 스펙 명시, F-3 반영). 1·2차 리포트 원문은 회차마다 같은 경로에 덮어써져 남지 않으며, 보존된 [issue-0041-audit-report.md](./issue-0041-audit-report.md)는 3차 최종본이다 (회차별 결과는 Task N에 정리)
  - F-1(MEDIUM): `ai-workspace/SKILL.md` 멱등 보강 검사 표에 `## 프로젝트 규칙` 섹션·3열 표 존재 검사 행 추가 — 섹션 부재 시 `## 프로젝트 목적` 다음에 프로파일별 템플릿 골격 삽입, 2열 구버전 표는 3열 확장(사용자 행 `사용 시점`은 `<사용 시점>` placeholder), 두 행 검사에 선행
  - F-2(LOW): spec 포함 범위에 dev update 실행 산출물 3파일(`coding-convention.md`, `writing-principles.md`, `writing-principles-local.md`) 명시 — 제거·분리하면 라우터 행 참조가 다시 끊기므로 범위 명시로 처리
  - F-3(LOW): spec DoD 검증 명령을 해당 섹션 범위(awk)로 강화, fixture 3케이스(input/expected)+README 7파일을 `ai-workspace/tests/fixtures/update4-idempotent/`에 보존
  - 홈 설치본 재동기화(`tests/` 배포 제외) 및 강화판 DoD 재검증 통과: awk 범위 grep 4건(2·1·1·1), diff 2건(0건·0건), fixture 7파일
- **특이 사항**: `tests/` 신설로 홈 동기화 검증 명령이 `diff -r -x tests`로 변경됨 (install-skills 배포 제외 규칙과 정합). `[QD]` 모의 실행은 fixture 3종으로 재현 가능해짐 — expected 재입력 시 무변경(멱등) 확인

---

### Task 7: 재감사 발견사항 보정 (--response 승인분)

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - 재감사 리포트(PASS 19 / FAIL 0 / PARTIAL 3)를 `--response` 절차로 검토 — 피드백 제시 후 사용자가 항목별 승인 (F-1 반영, F-2 "열 확장만", F-3 반영)
  - F-1(MEDIUM): 섹션·표 검사를 상태 3분기로 재작성 — 섹션 부재는 템플릿 골격 삽입, **섹션 존재+표 부재는 인라인 본문 보존한 채 섹션 끝에 프로파일별 3열 표 삽입**(신규 분기), 2열은 열 확장. `no-rules-table` fixture 케이스(input/expected) 추가로 fixture 3종 → 4종
  - F-2(MEDIUM): 2열 확장 범위를 "열 확장만"으로 확정 — SKILL.md에서 `legacy-migration.md` ② 참조를 제거하고 자체 서술(헤더·구분선에 `사용 시점` 열 추가 + `<사용 시점>` placeholder)로 대체. 기본 행 복원은 별도 경로(구버전 구조 마이그레이션)임을 명시해 fixture와의 정답 충돌 해소. fixture 무변경
  - F-3(LOW): fixture 검사를 개수(`ls | wc -l`, 임의 7파일도 통과)에서 파일명 9건 `test -f`로, 홈 동기화 검사에 `test ! -e ~/.claude/skills/ai-workspace/tests` 부재 검사 추가 (`-x tests`가 양쪽을 제외해 잔존을 놓치는 공백 차단)
  - 홈 재동기화 후 강화판 DoD 재검증 전부 통과: awk 범위 grep 4건(2·1·1·1), diff 2건(0건·0건), fixture 파일명 9건 누락 0, 홈 `tests/` 부재, 멱등 보강 검사 섹션 내 `legacy-migration` 참조 0건
- **특이 사항**: `[QD]` fixture 4종 모의 실행 통과 — `no-rules-section`(템플릿 골격 삽입·사용자 섹션 보존), `no-rules-table`(인라인 규칙 보존·표 삽입), `legacy-two-col`(열 확장·placeholder·표준 2행 삽입, 기본 행 미보충), `missing-rows`(표준 2행 삽입·기존 3행 보존) 모두 expected와 일치하고 expected 재입력 시 무변경(멱등)

---

### Task 8: 최종 재감사 발견사항 보정 (--response 승인분)

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - 최종 재감사 리포트(PASS 22 / FAIL 0 / PARTIAL 0, 이전 MEDIUM 2건·LOW 1건 전부 해소 판정)를 `--response` 절차로 검토 — 피드백 제시 후 사용자가 F-1 반영 승인(대표 케이스 1개)
  - F-1(LOW): doc 프로파일 분기 fixture 부재 — `missing-rows-doc`(input/expected) 추가로 fixture 4종 → 5종(dev 4 + doc 1). 이 이슈가 Task 5에서 도입한 dev/doc 문구 분기의 회귀를 `[QD]`가 잡게 됨
  - 대표 케이스로 `missing-rows` 계열을 택한 근거: 감사가 지목한 `SKILL.md`의 `context-loading.md` 행 검사(프로파일별 문구 분기)를 직접 태우는 경로가 "기존 표에 행 삽입"이기 때문. 섹션·표 부재 케이스는 템플릿 표를 통째로 삽입해 문구 분기를 간접적으로만 지남
  - README에 프로파일 표기 규칙(`-doc` 접미사) 명시, spec 포함 범위·DoD 갱신(fixture 4종→5종, 파일명 9→11건)
  - DoD 재검증 전부 통과: awk 범위 grep 4건(2·1·1·1), diff 2건(0건·0건), fixture 파일명 11건 누락 0, 홈 `tests/` 부재. doc expected 문구 검증도 통과 — "문서 작업 전" 1건 / "코드·문서 작업 전" 0건
- **특이 사항**: 홈 재동기화 불필요 — `tests/`는 배포 제외 경로라 홈에 반영되지 않음. `[QD]` 5종 모의 실행 통과 (`missing-rows-doc`은 표준 2행 삽입 시 doc 문구 적용·사용자 행 보존, expected 재입력 시 무변경)

---

### Task N: 교차모델 issue-audit 검증 — 사용자 수동 수행

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - 사용자가 타벤더 모델(OpenAI, GPT-5)로 `issue-audit`를 **3회** 수행 — 구현 모델(Anthropic, Claude Fable 5)과 벤더 상이
  - 1차: PASS 15 / PARTIAL 1, 발견 3건(F-1 MEDIUM 섹션·표 부재 처리 미정의, F-2 스펙 미기재 설치 산출물, F-3 검증 의미 공백·fixture 부재) → Task 6에서 `--response` 승인분 보정
  - 2차 재감사: PASS 19 / FAIL 0 / PARTIAL 3, 발견 3건(F-1 MEDIUM 표 부재 경로, F-2 MEDIUM 2열 fixture와 production 규칙 충돌, F-3 LOW 결정적 게이트 공백) → Task 7에서 보정
  - 3차 최종 재감사: **PASS 22 / FAIL 0 / PARTIAL 0**, 이전 MEDIUM 2건·LOW 1건 전부 해소 판정. 유일 발견 F-1(LOW, doc 프로파일 fixture 부재) → Task 8에서 보정. 감사 결론: "Issue #41은 감사 관점에서 완료 판정 가능"
  - 감사 리포트 원문: [issue-0041-audit-report.md](./issue-0041-audit-report.md) — 3차 최종 재감사본 (작성 시점 경로는 `.ai/99_workspace/issue-0041-audit-report.md`, --clear로 이관)
  - `[D]` 검증 명령 전부 통과 (감사 측·구현 측 각각 재실행), 구현 모델 ≠ audit 모델 기록 완료
- **특이 사항**: 감사 지적 누적 7건을 3라운드에 걸쳐 전부 해소 — MEDIUM 3건은 반영, LOW 4건은 반영 3건(F-3 게이트 강화, doc fixture)·스펙 명시 1건. 보정은 모두 `--response`의 항목별 승인 게이트를 거침
