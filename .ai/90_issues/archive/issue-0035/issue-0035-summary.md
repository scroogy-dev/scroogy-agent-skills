# Issue #35 실행요약 install-skills self-install형으로 전환

> 스펙: [issue-0035-spec.md](./issue-0035-spec.md) | 계획: [issue-0035-plan.md](./issue-0035-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다.

## 모델 기록

<!--
형식: "벤더, 모델명". 계획·구현 모델도 audit 모델도 어느 벤더·모델이든 가능하다
(예: Anthropic, Claude Opus 4.8 (claude-opus-4-8) / OpenAI, GPT-5.x / Google, Gemini 3.x).
"audit 모델 ≠ 구현 모델" 조건을 나중에 명령으로 확인 가능하도록 기록한다. 모델 전환은 사람이 수행하므로 기계로 강제하기 어렵다.
-->

| 구분 | 모델 |
|------|------|
| 계획·구현 모델 | 계획: Anthropic, Claude Opus 4.8 (claude-opus-4-8) / 구현: Anthropic, Claude Fable 5 (claude-fable-5) |
| audit 모델 | OpenAI, GPT-5.5 |

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

- **결과**: 완료 (L1 + L2)
- **수행 내용 요약**:
  - L1: `bash install-skills/tests/run-tests.sh` 9개 전부 통과·0 실패 (audit 반영 후 재실행 포함). spec DoD [D] 검증 명령 전부 통과.
  - L2 (엔드투엔드, 2026-07-02 사용자 지시로 이 세션에서 실행형 확인): ① 이 repo에서 `--self` 절차로 홈(`~/.claude/skills/install-skills/`) self-install — `tests/` 제외·`scripts/`·`references/` 포함 확인, 홈 우선 탐색으로 헬퍼 선택 후 verify PASS, Claude Code가 새 설치본 description을 즉시 인식. ② 다른 스킬 repo(`scroogy-content-skills`) cwd에서 복제본 미사용으로 가드 통과 → 스캔(자기제외 정상) → `blog-photo-draft` 설치(임시 대상 디렉토리) → 홈 설치본 헬퍼로 verify PASS. ③ 비-스킬 디렉토리에서 가드가 경고 후 중단함을 확인 (zsh·bash 모두 중단 분기로 수렴).
- **특이 사항**: 원계획은 "별도 세션·사람 판정"이었으나 사용자 지시로 이 세션에서 실제 실행으로 수행. ②의 설치 대상은 사용자 홈 오염을 피해 임시 디렉토리 사용. 확인 과정에서 검증 명령의 `&&`/`||` 조립 실수로 1회 재실행 발생(읽기 전용 스캔 타임아웃, 시스템 변경 없음).

---

### Task 5: [audit P1] description 트리거 커버리지 확장

- **결과**: 완료
- **수행 내용 요약**: frontmatter description을 재작성 — 5개 설치 경로(Claude Code·Agents·Antigravity·Codex·Junie), 주요 옵션(`--all`/`--clear`/`--self`), "스킬 배포·재설치·self-install" 트리거 키워드를 3인칭 문장으로 반영.
- **특이 사항**: 감사 리포트(`.ai/99_workspace/skill-audit-report.md`) install-skills P1 항목 반영. 사용자 지시로 audit 피드백 중 install-skills 항목만 이 이슈에서 처리 (issue-work 등 다른 스킬은 범위 외).
- **검증**: `head -4`에서 `Codex`·`Junie`·`self-install` grep 통과 (L1).

---

### Task 6: [audit P1] 설치본에서 깨지는 ADR 상대 링크 정리

- **결과**: 완료
- **수행 내용 요약**: 개요의 `../.ai/50_adr/...` 마크다운 링크를 제거하고, 규칙 요지(결정적 헬퍼의 테스트는 스킬과 함께 두되 배포에서 제외) 1줄과 "repo 전용 문서라 설치본에서 열람 불가" 명시로 대체. 클린 설치 중복 서술도 이 문장으로 통합 (단일 출처: 설치 절차 5단계).
- **특이 사항**: ADR 0001 → SKILL.md 방향의 SSoT 참조는 그대로 유효 (역방향 링크만 제거).
- **검증**: `! grep -F '](../' install-skills/SKILL.md` 통과 — skill 디렉토리 밖 상대 링크 0건 (L1).

---

### Task 7: [audit P2·P3] 6·7단계 상세 references/ 분리·중복 서술 통합

- **결과**: 완료
- **수행 내용 요약**: Antigravity 레거시 점검의 적용 조건·판정 기준(4분기 표)·배경을 `install-skills/references/antigravity-legacy.md`로 분리하고, 본문 6·7단계는 "FAIL이면 경고·승인 시 제거, INFO는 보존" 요약+포인터로 축약. "이 환경의 inode 동일 사례" 환경 과적합 서술을 일반 서술로 교체. 추가 옵션 표의 `--clear`/`--self` 설명을 각 단일 출처(설치 절차 2단계 / Self-install 부트스트랩 섹션) 참조로 정리.
- **특이 사항**: `references/`는 배포 제외 패턴(`tests/`, `*.test.*`)에 해당하지 않아 설치본에 포함됨 — 본문에서 상대 링크로 참조해도 설치본에서 깨지지 않음.
- **검증**: `test -f references/antigravity-legacy.md` + SKILL.md 참조 grep + `! grep -qi inode` 통과, `bash install-skills/tests/run-tests.sh` 9개 전부 통과·0 실패 — Task 1~3 DoD grep도 재확인 통과 (L1).

---

### Task 8: 교차모델 audit 발견사항 보정 (F-1·F-2·F-3)

- **결과**: 완료
- **수행 내용 요약**: 교차모델 audit 리포트(`.ai/99_workspace/issue-0035-audit-report.md`, OpenAI GPT-5.5)를 `--response` 게이트로 검토 — 피드백 제시 후 사용자가 F-1(수정안 A)·F-2(이번 이슈 반영)·F-3(spec 명시)을 항목별 승인.
  - F-1·F-3: 가드의 "0건 차단(1건 이상 통과)"을 설계 의도로 확정. spec 범위·DoD와 plan Task 3의 "복수 존재 확인" 문구를 "1건 이상 존재 확인"으로 정합화하고, spec에 단일 스킬 repo 지원 의도를 명시. SKILL.md 가드에 "1건만 매칭되면 사용자 확인 후 진행" 문구 보강. 감사 권고(≥2 강화)는 반려 — 후속 이슈로 복제본이 제거되면 `scroogy-content-skills`가 단일 스킬 repo가 되어 차단되는 부작용 근거.
  - F-2: SKILL.md 본문에서 가드·자기제외 스캔·헬퍼 탐색 bash 블록을 추출해 픽스처에서 실행하는 스모크 테스트 9건을 `tests/run-tests.sh`에 추가 (문서-구현 드리프트 감지).
- **특이 사항**: Task N의 audit 모델·결과 기록은 사용자 지시로 보류 — 모델 칸·체크박스 미변경. 테스트 작성 중 추출 marker가 산문과 겹쳐 1회 수정(블록 내 주석 고유 문자열로 좁힘).
- **검증**: `bash install-skills/tests/run-tests.sh` 18개 전부 통과·0 실패 (기존 9 + 스니펫 9). Task 8 완료 기준 grep 2건·기존 DoD grep 전부 통과 (L1).

---

### Task N: 교차모델 issue-audit 검증

- **결과**: 완료 — 재감사 전부 PASS
- **수행 내용 요약**: 사용자가 OpenAI GPT-5.5로 `issue-audit`를 직접 수행 (2026-07-02, 2회). 1차 감사에서 F-1(MEDIUM, 가드 설계 모호)·F-2(LOW, 스니펫 테스트 부재)·F-3(INFO, 단일 스킬 repo 지원 모호) 발견 → issue-work `--response` 게이트로 항목별 승인 후 Task 8에서 보정. 재감사(`issue-0035-audit-report.md`, 이 디렉토리에 보존)에서 요구사항 6건·DoD 10건 전부 PASS, F-1~F-3 모두 해소 판정, 추가 보정 필요 없음으로 종결. 마감 전 spec DoD `[D]` 검증 명령 전부 재실행 통과 (grep 6건 + `run-tests.sh` 18개·0 실패).
- **특이 사항**: 구현 모델(Anthropic, Claude Fable 5) ≠ audit 모델(OpenAI, GPT-5.5) — 교차모델 조건 충족, 모델 기록 칸 반영 (표기는 PR #36 Copilot 리뷰 지적으로 GPT-5 → GPT-5.5 정정, 리포트 원문 기준). audit 리포트는 `--clear` 시 `archive/issue-0035/`로 이동해 보존했다.
