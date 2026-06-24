# Issue #28 실행요약 install-skills Antigravity 경로 공식화 및 설치 검증 결정적화

> 스펙: [issue-0028-spec.md](./issue-0028-spec.md) | 계획: [issue-0028-plan.md](./issue-0028-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다. (다음: `--clear`로 archive 이관 → PR)

## 모델 기록

| 구분 | 모델 |
|------|------|
| 계획·구현 모델 | Anthropic, Claude Opus 4.8 (claude-opus-4-8) |
| audit 모델 | OpenAI, Codex <!-- 정확한 모델 ID는 사용자 확인 후 보정 --> |

---

## Task별 수행 결과

### Task 1: Antigravity 경로 수정 + 레거시 정리 단계 명문화

- **결과**: 완료
- **수행 내용 요약**:
  - 옵션 표 `--antigravity` 경로를 `~/.gemini/antigravity/skills/` → `~/.gemini/config/skills/`로 교체.
  - 설치 절차에 "레거시 경로 마이그레이션 (Antigravity 한정)" 단계(신 6단계) 추가, 출력은 7단계로 이동. 심링크/부재면 보존, 실제 디렉토리 잔존 시 경고·정리 제안, `--clear` 중복 인식 배경 명시.
  - 검증: 신 경로 존재 1, 구 경로 리터럴 `antigravity/skills` 0, 레거시 문구 2 — 완료 기준 충족.
- **특이 사항**:
  - 스펙 내부 모순 발견·해소: DoD #36(`grep -c 'antigravity/skills' == 0`)과 "레거시 단계에 구 경로 명시" 요구가 충돌. 사용자 결정으로 **옵션 B** 채택 — 구 경로 리터럴은 `verify-install.sh`가 보유하고 SKILL.md는 리터럴 없이 서술. plan Task 1 작업 내용·완료 기준을 이에 맞게 정합화함.

---

### Task 2: 결정적 설치 검증 스크립트 + 테스트 추가

- **결과**: 완료
- **수행 내용 요약**:
  - `install-skills/scripts/verify-install.sh` 작성: `--target`(반복) + skill 목록을 받아 skill 디렉토리·SKILL.md 존재, 배포 제외(`tests/`·`*.test.*`) 미포함을 검사. `--legacy-dir <path>`(테스트 주입용)·`--antigravity-legacy`(내장 `LEGACY_DEFAULT` 참조) 옵션으로 레거시 점검 — 심링크/부재 PASS, 비어있지 않은 실제 디렉토리 FAIL. exit code로 합/불(PASS=0/FAIL=1/사용오류=2).
  - `install-skills/tests/run-tests.sh` 작성: 픽스처를 임시 디렉토리에 동적 생성(심링크 포함)하고 exit code를 기대값과 비교하는 셸 러너(외부 의존성 0). 9개 케이스 전부 통과.
  - 검증: `test -x` OK / 러너 9 pass 0 fail (bash 3.2.57 실환경) / 실환경 `--antigravity-legacy` 통합 점검도 심링크 보존·PASS.
- **특이 사항**:
  - 이 repo의 첫 결정적 헬퍼 — ADR 0001 규약(`scripts/`+`tests/`, 경량 셸 러너)을 처음으로 실체화.
  - macOS 기본 bash 3.2 호환을 위해 `set -u`를 피하고(빈 배열 + `set -u` 지뢰), 배열 루프는 `${#arr[@]}` 카운트로 가드.
  - 옵션 B에 따라 구 경로 리터럴 `$HOME/.gemini/antigravity/skills`는 스크립트의 `LEGACY_DEFAULT`에만 존재(SKILL.md엔 없음).

---

### Task 3: SKILL.md 절차에 검증 단계·셸 보완 반영

- **결과**: 완료
- **수행 내용 요약**:
  - 설치 절차 5단계 복사 예시를 **배열 + `for ... in "${arr[@]}"`** 형태로 보완(zsh/bash 단어 분리 회피), 대상 경로도 `target` 변수화.
  - 6단계 신설 "설치 검증 (결정적 확인 우선 + AI 크로스체크)": `verify-install.sh`로 결정적 확인을 먼저 하고 AI가 PASS/FAIL을 준결정적으로 크로스체크. `--antigravity-legacy` 플래그 사용 예시 포함.
  - 7단계(레거시 마이그레이션)를 6단계 검증 결과(PASS/FAIL)에 연동, 8단계는 출력으로 재배치.
  - 검증: `verify-install.sh` 참조 2, `크로스체크` 1 — 완료 기준 충족.
- **특이 사항**:
  - **SSoT 보존 확인(Task 3.3)**: 배포 제외 패턴(`--exclude 'tests/' '*.test.*'`)은 5단계 rsync 명령 한 곳에만 유지. 6단계 검증 예시는 `--exclude`를 중복하지 않고 `verify-install.sh` 호출만 보여줘 ADR 0001 SSoT 관계가 깨지지 않음. 개요의 "5단계" 포인터도 유효.

---

### Task N: 교차모델 issue-audit 검증

- **결과**: 교차모델 audit 수행 완료(사용자가 Codex로 직접 실행) → 지적 2건 반영 완료. 리포트: `.ai/99_workspace/issue-0028-audit-report.md`
- **수행 내용 요약**:
  - `[D]` 5개 게이트는 재실행 통과 확인: #35 신 경로 1, #36 구 경로 리터럴 0, #37 실행 가능, #38·#39 러너 9/9, `bash -n` 문법 OK.
  - **Codex audit 지적 2건(둘 다 MEDIUM) 검증 후 반영**:
    - **F-1 (빈 실제 레거시 디렉토리 PASS ↔ spec DoD 문구 충돌)**: 구현(빈 디렉토리 PASS)이 더 옳다고 판단 — 코드는 유지하고 **spec 쪽을 정밀화**. spec In-scope·DoD #5를 "비어있지 않은 실제 디렉토리로 잔존하면 FAIL, 심링크/부재/빈 디렉토리는 PASS"로 수정.
    - **F-2 (검증 예시의 `--antigravity-legacy`가 Claude target 예시에 박혀 거짓 FAIL 유발)**: SKILL.md 6단계 검증 예시를 **공통 검증 + Antigravity 전용 검증으로 분리**. 추가로 사용자 지적 반영 — Antigravity 레거시 점검 조건을 `--antigravity` **또는 `--all`**(Antigravity 경로가 설치 대상일 때)로 명확화. 7단계 제목·본문도 동일하게 정합화.
  - 반영 후 게이트 재확인: 신 경로 1 / 구 경로 0 / verify-install.sh 참조 3 / 크로스체크 1 / 러너 9 pass 0 fail. 구현·테스트 코드는 무변경(문서·spec만 변경).
- **특이 사항**:
  - 착수 전 보조로 Sonnet 4.6 internal 점검을 1회 돌렸고(**정식 audit 아님**), 거기서 나온 개선을 코드에 선반영함: major 1(fallback `cp`의 `*.test.*` 미제거 → `find ... -delete`), minor 3, info 1. Codex audit은 이 보정된 상태를 봤다.
  - 교차모델 audit은 AI가 자동 실행하지 않고 사용자가 타벤더 모델로 수행하는 것이 원칙 (issue #29 방침).
  - 보류된 보조점검 info 2건(usage()의 `sed` 라인 범위 하드코딩 / run-tests.sh의 stderr 억제)은 현재 동작이 정확해 미반영 — Codex audit도 이를 짚지 않아 그대로 둔다.
