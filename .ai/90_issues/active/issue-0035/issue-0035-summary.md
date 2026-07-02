# Issue #35 실행요약 install-skills self-install형으로 전환

> 스펙: [issue-0035-spec.md](./issue-0035-spec.md) | 계획: [issue-0035-plan.md](./issue-0035-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task 4 잔여 — 홈 self-install 후 다른 스킬 repo에서 엔드투엔드 확인 (별도 세션·사람, L2) → 이후 Task N 교차모델 audit (사용자 직접 수행)

## 모델 기록

<!--
형식: "벤더, 모델명". 계획·구현 모델도 audit 모델도 어느 벤더·모델이든 가능하다
(예: Anthropic, Claude Opus 4.8 (claude-opus-4-8) / OpenAI, GPT-5.x / Google, Gemini 3.x).
"audit 모델 ≠ 구현 모델" 조건을 나중에 명령으로 확인 가능하도록 기록한다. 모델 전환은 사람이 수행하므로 기계로 강제하기 어렵다.
-->

| 구분 | 모델 |
|------|------|
| 계획·구현 모델 | 계획: Anthropic, Claude Opus 4.8 (claude-opus-4-8) / 구현: Anthropic, Claude Fable 5 (claude-fable-5) |
| audit 모델 | <!-- 구현 모델과 다른 벤더 모델. 형식: 벤더, 모델명. 마지막 교차모델 audit Task에서 사용자가 기록 --> |

---

## Task별 수행 결과

### Task 1: 자기제외 규칙 조건화 (self-install 부트스트랩)

- **결과**: 완료
- **수행 내용 요약**: `install-skills/SKILL.md`에 `--self` 옵션을 추가 옵션 표·설치 절차 1단계 파싱에 추가하고, 스캔의 자기제외를 `--self` 지정 시에만 해제하는 조건(`self_install=true`)으로 명문화. "최초 1회 `/install-skills --self` → 이후 어디서든 사용" 부트스트랩 흐름을 `### Self-install 부트스트랩` 섹션으로 기재. 참고 절의 `all` 동작에도 `--self` 지정 시 포함을 반영.
- **특이 사항**: self-install에도 클린 설치·배포 제외 패턴이 동일 적용됨을 명시 (`scripts/`는 포함, `tests/`는 제외 — ADR 0001 규칙 유지).
- **검증**: `grep -q -- '--self' install-skills/SKILL.md` 통과 (L1).

---

### Task 2: 헬퍼 스크립트 경로 홈 우선 탐색

- **결과**: 완료
- **수행 내용 요약**: 설치 검증 6단계의 헬퍼 참조를 "홈 설치본(`~/.claude/skills/install-skills/scripts/verify-install.sh`) 우선, 없으면 cwd 상대 경로(`install-skills/scripts/verify-install.sh`) 폴백" 순으로 탐색하도록 변경. 탐색 스니펫(`verify` 변수)을 기재하고 공통 검증·Antigravity 레거시 검증 양쪽 호출이 `"$verify"`를 재사용하게 통일.
- **특이 사항**: `verify-install.sh` 스크립트 본체는 변경 없음 — 호출 경로 탐색만 SKILL.md에서 변경.
- **검증**: `grep -q '.claude/skills/install-skills/scripts' install-skills/SKILL.md` 통과 + 폴백 문구 존재 (L1).

---

### Task 3: 스킬 repo 판별 가드 추가

- **결과**: 완료
- **수행 내용 요약**: `## 사용 가능한 skill`의 스캔 앞단에 **스킬 repo 판별 가드**를 추가 — `*/SKILL.md`가 하나도 매칭되지 않으면 스킬 repo가 아닌 것으로 판정하고 경고 후 안전하게 중단(bash 스니펫 포함). 가드 통과 시에만 기존 "스캔 목록 제시 → 사용자 선택" 절차를 그대로 진행함을 명시.
- **특이 사항**: 비-스킬 디렉토리 실제 중단 동작의 채점은 spec DoD의 [QD] 항목으로 별도 세션에서 확인 예정.
- **검증**: 가드 로직 문구(`스킬 repo 판별 가드`, `*/SKILL.md`) grep 확인 (L1).

---

### Task 4: 회귀·엔드투엔드 검증

- **결과**: 부분 완료 (L1 통과, L2 대기)
- **수행 내용 요약**: `bash install-skills/tests/run-tests.sh` 실행 — 9개 테스트 전부 통과, 0 실패 (회귀 없음). spec DoD의 [D] 검증 명령 4건(--self·홈 경로·폴백 문구·가드 로직 grep)도 전부 통과.
- **특이 사항**: 홈 self-install 후 다른 스킬 repo에서 복제본 없이 실행되는지의 엔드투엔드 확인(L2)은 별도 세션·사람 판정 항목으로 미수행 — 이 항목 확인 전까지 체크박스는 미체크 유지.

---

### Task N: 교차모델 issue-audit 검증

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:
