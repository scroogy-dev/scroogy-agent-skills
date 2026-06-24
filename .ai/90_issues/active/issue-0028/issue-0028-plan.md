# Issue #28 실행계획 install-skills Antigravity 경로 공식화 및 설치 검증 결정적화

> 스펙: [issue-0028-spec.md](./issue-0028-spec.md)

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> 각 작업은 독립적으로 검증 가능해야 하며, **완료 기준은 자연어 대신 실행 명령 + 임계값**으로 적습니다.
> 마지막 고정 Task(교차모델 issue-audit)는 삭제하지 않습니다.

### Task 1: Antigravity 경로 수정 + 레거시 정리 단계 명문화

- [x] 완료
- **목표**: `--antigravity` 경로를 공식 경로로 교체하고, 구 경로 잔존물 처리(레거시 마이그레이션)를 절차로 명문화한다.
- **작업 내용**:
  1. SKILL.md "설치 경로 옵션" 표의 `--antigravity` 행을 `~/.gemini/config/skills/`로 수정한다.
  2. 본문·절차 어디에도 구 경로 리터럴 `antigravity/skills`(소문자·슬래시)가 남지 않도록 정리한다.
  3. 설치 절차에 **레거시 경로 마이그레이션** 단계를 추가한다 (결정: 옵션 B — 구 경로 리터럴은 SKILL.md에 쓰지 않고 `verify-install.sh`가 보유). Antigravity 설치 시 구 Antigravity skills 경로 잔존을 `verify-install.sh`가 결정적으로 점검한다고 기재한다:
     - **심링크/부재면 보존한다**(신 경로와 동일 위치 — 이 환경의 inode 동일 사례). 정보만 출력.
     - **실제 디렉토리로 내용이 잔존하면** 사용자에게 경고하고 정리(제거)를 제안한다. 승인 시에만 제거.
- **완료 기준**: `grep -F '~/.gemini/config/skills/' install-skills/SKILL.md` ≥ 1 AND 구 경로 리터럴 미잔존(`grep -c 'antigravity/skills' install-skills/SKILL.md` == 0) AND 레거시 정리 단계 문구 존재(`grep -c '레거시' install-skills/SKILL.md` ≥ 1)

---

### Task 2: 결정적 설치 검증 스크립트 + 테스트 추가

- [x] 완료
- **목표**: 설치 결과와 레거시 잔존을 사람·AI 판단 없이 합/불 판정하는 결정적 헬퍼를 추가한다 (ADR 0001 준수).
- **작업 내용**:
  1. `install-skills/scripts/verify-install.sh` 작성: 인자로 대상 경로와 설치한 skill 목록을 받아 검사하고 실패 시 항목을 출력, exit code로 합/불을 낸다.
     - 각 대상 경로에 각 skill 디렉토리 존재 / 각 설치본에 `SKILL.md` 존재
     - 설치본에 배포 제외 경로(`tests/` 디렉토리, `*.test.*` 파일) 미포함
     - 옵션 `--legacy-dir <path>`로 구 경로를 받으면: 그 경로가 **실제 디렉토리이고 비어있지 않으면 FAIL**, **심링크/부재면 PASS**
  2. `install-skills/tests/`에 셸 기반 러너와 픽스처를 추가: 정상 설치 PASS, 누락·`SKILL.md` 부재·`tests/` 잔존·`*.test.*` 잔존·레거시 실제-디렉토리 잔존 → FAIL, 레거시 심링크/부재 → PASS 케이스를 모두 덮는다.
  3. 스크립트는 `#!/usr/bin/env bash` shebang + 배열·`"$@"` 기반으로 작성해 단어 분리에 의존하지 않는다.
- **완료 기준**: `test -x install-skills/scripts/verify-install.sh` 성공 AND `install-skills/tests/`의 러너 실행 시 0 실패

---

### Task 3: SKILL.md 절차에 검증 단계·셸 보완 반영

- [x] 완료
- **목표**: 설치 절차에 "결정적 확인 우선 + AI 크로스체크" 단계를 명문화하고, 설치 예시의 셸 호환성을 보완한다.
- **작업 내용**:
  1. 설치 절차에 검증 단계를 추가: `verify-install.sh`로 결정적 확인을 먼저 수행(설치 결과 + 레거시 잔존)하고, AI는 그 PASS/FAIL 결과를 읽어 누락·불일치를 준결정적으로 크로스체크한다고 기재한다.
  2. 설치 절차의 셸 예시를 zsh word-splitting에 깨지지 않는 형태(배열/`for ... in "${arr[@]}"` 또는 명시적 분리)로 보완한다.
  3. ADR 0001과의 SSoT 관계(배포 제외 패턴 단일 출처)가 깨지지 않는지 확인한다.
- **완료 기준**: `grep -F 'verify-install.sh' install-skills/SKILL.md` ≥ 1 AND `grep -c '크로스체크' install-skills/SKILL.md` ≥ 1

---

### Task N (고정): 교차모델 issue-audit 검증

<!--
이 블록은 모든 이슈 계획의 마지막 Task로 고정한다. 삭제하지 말 것.
audit은 L2 [QD] 보완 검증 — L1 [D] 결정적 게이트의 대체가 아니라 보완이다.
-->

- [ ] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 전부 재실행해 통과를 확인한다.
  2. 계획·구현을 수행한 모델과 **다른 모델**(최소 동급 이상 역량)로 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 지적 사항을 summary에 반영하고 필요 시 앞 Task를 보정한다.
- **완료 기준**: `[D]` 검증 명령 전부 통과 + 구현 모델 ≠ audit 모델 기록이 summary 모델 칸에 남는다.
