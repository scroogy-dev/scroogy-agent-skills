# Issue #28 재감사 리포트 install-skills Antigravity 경로 공식화 및 설치 검증 결정적화

> 감사 일시: 2026-06-24
> 감사 대상 브랜치: `issue-0028`
> 감사 대상 상태: working tree 포함 (`f5e3018e40840e1024fe63ec29cd9a9776a8943a` + 미커밋 반영분)
> 기준 브랜치: `main`
> 스펙 출처: `.ai/90_issues/active/issue-0028/issue-0028-spec.md`

---

## Phase 1: 적합성 검증 (Compliance Check)

### 요구사항 대조

| # | 요구사항 | 판정 | 근거 |
|---|----------|------|------|
| 1 | `--antigravity` 설치 경로를 `~/.gemini/config/skills/`로 수정 | PASS | `install-skills/SKILL.md:19`의 `--antigravity` 행이 공식 경로를 가리킨다. |
| 2 | 구 경로 리터럴 `antigravity/skills`를 SKILL.md에서 제거 | PASS | `grep -c 'antigravity/skills' install-skills/SKILL.md` 결과 `0`. 구 경로 리터럴은 검증 스크립트가 보유한다. |
| 3 | 레거시 마이그레이션: 심링크·부재·빈 디렉토리는 PASS, 비어있지 않은 실제 디렉토리는 FAIL/정리 제안 | PASS | 스펙이 해당 정책으로 정밀화되었고, `install-skills/SKILL.md:85-88` 및 `verify-install.sh:90-103`이 같은 기준을 따른다. |
| 4 | 설치 결과를 결정적으로 검증하는 스크립트 추가 (`scripts/` + `tests/`, ADR 0001 준수) | PASS | `install-skills/scripts/verify-install.sh`와 `install-skills/tests/run-tests.sh`가 있으며 실행 가능하다. 테스트는 외부 의존성 없는 셸 러너다. |
| 5 | SKILL.md 절차에 "결정적 확인 우선 + AI 크로스체크" 명문화 | PASS | `install-skills/SKILL.md:74-84`가 exit code 우선 결정적 검증과 AI 크로스체크의 보완 관계를 명시한다. |
| 6 | 설치 절차 예시를 zsh word-splitting에 안전한 형태로 보완 | PASS | `install-skills/SKILL.md:63-72`가 배열과 `"${skills[@]}"` 루프를 사용한다. |
| 7 | 비포함 범위 침범 금지 | PASS | 변경 파일은 Issue #28 문서와 `install-skills` 범위에 한정된다. 다른 도구 경로 행은 변경되지 않았다. |

### 완료의 정의(DoD) 대조

| # | DoD 항목 | 판정 | 근거 |
|---|----------|------|------|
| 1 | `[D]` SKILL.md `--antigravity` 행 경로가 `~/.gemini/config/skills/` | PASS | `grep -F '~/.gemini/config/skills/' install-skills/SKILL.md` 통과. |
| 2 | `[D]` 구 경로 문자열 `antigravity/skills` 미잔존 | PASS | `grep -c 'antigravity/skills' install-skills/SKILL.md` 결과 `0`. |
| 3 | `[D]` 검증 스크립트 실행 가능 | PASS | `test -x install-skills/scripts/verify-install.sh` 통과. |
| 4 | `[D]` 정상 설치 PASS, 누락·오염 주입 FAIL | PASS | `install-skills/tests/run-tests.sh` 결과 `passed: 9, failed: 0`. |
| 5 | `[D]` 비어있지 않은 실제 레거시 디렉토리는 FAIL, 심링크/부재/빈 디렉토리는 PASS | PASS | 테스트 러너가 비어있지 않은 실제 디렉토리, 심링크, 부재, 빈 실제 디렉토리 케이스를 모두 검증했고 통과했다. |
| 6 | `[QD]` SKILL.md 절차에 레거시 경로 정리(심링크 보존) 단계 명문화 | PASS | `install-skills/SKILL.md:85-88`에 Antigravity 경로 한정 처리와 각 판정별 대응이 명시되어 있다. |
| 7 | `[QD]` SKILL.md 절차가 "결정적 확인 우선 + AI 크로스체크"로 읽힘 | PASS | `install-skills/SKILL.md:74`가 결정적 결과 우선과 AI 보완 관계를 직접 서술한다. |
| 8 | `[QD]` 교차모델 issue-audit 통과 | PASS | 이전 MEDIUM 지적 2건은 현재 스펙·SKILL.md 반영분에서 해소되었다. 본 재감사에서는 차단 이슈가 없다. |

### 범위 검증

- **스펙 비포함(Out) 침범 여부**: 발견되지 않음. `--claude`, `--agents`, `--codex`, `--junie` 경로는 유지되었고, install-skills 외 스킬 구현 변경은 없다.
- **스펙에 없는 추가 구현 여부**: 발견되지 않음. 빈 레거시 디렉토리 PASS 정책은 현재 스펙에 명시되어 있다.

### 도메인/계약/ADR 정합성

- `.ai/30_contract/index.md`: 관련 계약 문서 없음.
- `.ai/40_domain/index.md`: 관련 도메인 문서 없음.
- `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md`: 헬퍼 위치(`scripts/`), 테스트 위치(`tests/`), 외부 의존성 없는 경량 러너, 배포 제외 패턴의 SSoT 유지 모두 정합하다.

---

## Phase 2: 비판적 검증 (Critical Review)

### 발견 사항

| # | 위험도 | 분류 | 설명 | 관련 파일 |
|---|--------|------|------|-----------|
| F-1 | LOW | 문서 정합성 | `verify-install.sh --help`에 출력되는 상단 검사 항목 설명은 여전히 "실제 디렉토리로 잔존하지 않는가(심링크/부재 정상)"라고 되어 있어, 현재 스펙의 "빈 실제 디렉토리 PASS" 정책을 충분히 드러내지 않는다. | `install-skills/scripts/verify-install.sh` |

### 상세 분석

#### F-1: verify-install.sh 도움말의 레거시 정책 설명이 최신 스펙보다 좁음

- **위험도**: LOW
- **분류**: 문서 정합성
- **설명**: 스크립트 동작과 테스트는 현재 스펙과 일치한다. 다만 `verify-install.sh --help`가 출력하는 검사 항목에는 빈 실제 디렉토리 PASS가 언급되지 않아, 도움말만 읽으면 모든 실제 디렉토리를 비정상으로 보는 것처럼 오해할 수 있다.
- **영향**: 동작상 결함은 아니며 DoD도 통과한다. 다만 사용자나 AI가 `--help`를 근거로 레거시 정책을 해석할 때 문서 혼선이 생길 수 있다.
- **권장 조치**: 스크립트 상단 주석의 검사 항목을 `비어있지 않은 실제 디렉토리는 FAIL, 심링크/부재/빈 디렉토리는 PASS`로 갱신한다.

---

## 검증 실행 기록

- `grep -F '~/.gemini/config/skills/' install-skills/SKILL.md` → PASS
- `grep -c 'antigravity/skills' install-skills/SKILL.md` → `0`
- `test -x install-skills/scripts/verify-install.sh` → PASS
- `install-skills/tests/run-tests.sh` → `passed: 9, failed: 0`
- `bash -n install-skills/scripts/verify-install.sh` → PASS
- `bash -n install-skills/tests/run-tests.sh` → PASS
- `git diff --check` → PASS

---

## 종합 의견

이전 감사의 MEDIUM 지적 2건은 반영 완료로 판단한다. 스펙은 빈 레거시 디렉토리 PASS 정책을 명시하도록 정밀화되었고, SKILL.md의 검증 예시는 공통 검증과 Antigravity 전용 레거시 검증으로 분리되어 비-Antigravity 설치의 거짓 FAIL 위험이 해소되었다.

현 상태는 Issue #28 스펙과 DoD 기준으로 통과 가능하다. 남은 사항은 `verify-install.sh --help` 설명의 작은 문서 정합성 보정 정도이며, 기능·DoD 차단 이슈는 아니다.
