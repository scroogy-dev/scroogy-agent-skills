# Issue #35 실행계획 install-skills self-install형으로 전환

> 스펙: [issue-0035-spec.md](./issue-0035-spec.md)

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> 각 작업은 독립적으로 검증 가능해야 하며, **완료 기준은 자연어 대신 실행 명령 + 임계값**으로 적습니다.
> 명령으로 환원이 어려운 항목만 판정 주체(다른 AI / 사람)를 적고 강등 사유를 남깁니다.
> 마지막 고정 Task(교차모델 issue-audit)는 삭제하지 말고 그대로 둡니다.

### Task 1: 자기제외 규칙 조건화 (self-install 부트스트랩)

- [x] 완료
- **목표**: 일반 배포 시에는 `install-skills`를 계속 제외하되, 명시적 `--self` 시에는 홈에 자기 자신을 설치할 수 있게 한다.
- **작업 내용**:
  1. `install-skills/SKILL.md`에 `--self` 옵션을 추가하고, 자기제외(38줄 `[ "$d" != "install-skills" ]`)를 `--self`일 때만 해제하는 조건으로 명문화한다.
  2. "이 repo에서 최초 1회 self-install → 이후 어디서든 사용 가능"이라는 부트스트랩 흐름을 절차로 기재한다.
- **완료 기준**: `grep -q -- '--self' install-skills/SKILL.md` 통과 + self-install 절차 섹션이 본문에 존재.

---

### Task 2: 헬퍼 스크립트 경로 홈 우선 탐색

- [x] 완료
- **목표**: 다른 repo에는 헬퍼가 없으므로, `verify-install.sh` 참조가 홈 설치본을 우선 찾고 없으면 cwd로 폴백하게 한다.
- **작업 내용**:
  1. SKILL.md 설치 검증 6단계의 헬퍼 참조(74·77·82줄, cwd 상대 경로)를 `~/.claude/skills/install-skills/scripts/verify-install.sh` 우선, 없으면 `install-skills/scripts/verify-install.sh` 폴백 순으로 탐색하도록 바꾼다.
  2. 탐색 순서를 문구/스니펫으로 명확히 기재한다.
- **완료 기준**: `grep -q '.claude/skills/install-skills/scripts' install-skills/SKILL.md` 통과 + cwd 폴백 경로 문구가 함께 존재.

---

### Task 3: 스킬 repo 판별 가드 추가

- [x] 완료
- **목표**: 임의의 cwd에서 실수로 실행해 엉뚱한 디렉토리를 소스로 삼는 오설치를 막는다.
- **작업 내용**:
  1. 스캔 절차(58줄) 앞단에, 루트에 `*/SKILL.md`가 복수 존재하는지 확인하는 가벼운 가드를 SKILL.md에 추가한다.
  2. 비-스킬 디렉토리(가드 실패)에서는 안전하게 중단/경고하고, 기존 "스캔 목록 제시 → 사용자 선택" 절차는 그대로 유지함을 명시한다.
- **완료 기준**: 가드 로직 문구가 `grep`으로 확인됨 + 비-스킬 디렉토리 중단/경고 지침이 본문에 존재.

---

### Task 4: 회귀·엔드투엔드 검증

- [ ] 완료
- **목표**: 기존 옵션·설치 검증이 회귀 없이 유지되고, 홈 self-install 후 다른 repo에서 복제본 없이 설치됨을 확인한다.
- **작업 내용**:
  1. `bash install-skills/tests/run-tests.sh`를 실행해 헬퍼 테스트 회귀가 없는지 확인한다.
  2. (별도 세션·사람) 홈에 `--self`로 self-install한 뒤, 다른 스킬 repo cwd에서 복제본 없이 `/install-skills` 실행이 정상 동작하는지 확인한다.
- **완료 기준**: `bash install-skills/tests/run-tests.sh` 0 실패 (L1). 엔드투엔드 확인은 별도 세션·사람 판정(L2) — 강등 사유는 spec DoD 참조.

---

### Task 5: [audit P1] description 트리거 커버리지 확장

- [x] 완료
- **목표**: description이 실제 기능 범위(5개 설치 경로·주요 옵션)를 드러내 언더트리거를 없앤다.
- **작업 내용**:
  1. frontmatter description에 5개 설치 경로(Claude Code/Agents/Antigravity/Codex/Junie), 주요 옵션(`--all`/`--clear`/`--self`), "스킬 배포·재설치·self-install" 키워드를 3인칭 문장으로 반영한다.
- **완료 기준**: `head -4 install-skills/SKILL.md`에서 `Codex`·`Junie`·`self-install` grep 통과.
- **근거**: `.ai/99_workspace/skill-audit-report.md` install-skills P1 (언더트리거).

---

### Task 6: [audit P1] 설치본에서 깨지는 ADR 상대 링크 정리

- [x] 완료
- **목표**: `~/.claude/skills/`로 설치된 사본에서 dead link가 되는 `../.ai/...` 상대 링크를 없앤다.
- **작업 내용**:
  1. 개요의 ADR 마크다운 링크를 제거하고, 규칙 요지 1줄 + "repo 전용 문서" 명시로 대체한다.
- **완료 기준**: `! grep -F '](../' install-skills/SKILL.md` 통과 (skill 디렉토리 밖으로 나가는 링크 0건).
- **근거**: audit P1 (설치본 무결성).

---

### Task 7: [audit P2·P3] 6·7단계 상세 references/ 분리·중복 서술 통합

- [x] 완료
- **목표**: 본문 6·7단계는 "스크립트 실행 → PASS/FAIL 해석" 요약만 남기고 상세를 위임하며, 환경 과적합 서사·중복 서술을 정리한다.
- **작업 내용**:
  1. Antigravity 레거시 판정 분기·배경을 `install-skills/references/antigravity-legacy.md`로 분리하고 본문 6·7단계는 요약+포인터로 축약한다. "이 환경의 inode 동일 사례" 등 환경 과적합 서술은 일반화한다.
  2. 클린 설치·`--clear`·self-install 중복 서술을 각 1곳(단일 출처)으로 통합하고 나머지 위치는 참조로 바꾼다.
- **완료 기준**: `test -f install-skills/references/antigravity-legacy.md` + SKILL.md의 해당 파일 참조 grep + `! grep -qi 'inode' install-skills/SKILL.md` + `bash install-skills/tests/run-tests.sh` 0 실패.
- **근거**: audit P2 (토큰 절감)·P3 (중복 서술).

---

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

<!--
이 블록은 모든 이슈 계획의 마지막 Task로 고정한다. 삭제하지 말 것.
audit은 L2 [QD] 보완 검증 — L1 [D] 결정적 게이트의 대체가 아니라 보완이다.
이 Task는 사용자가 직접 수행하며, 구현 AI는 자동으로 닫지 않는다.
-->

- [ ] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **실행 주체**: **사용자가 직접** 수행한다. 구현 AI는 이 Task를 **자동으로 닫지 않으며**, `issue-audit`를 자동 실행하지도 않는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 전부 재실행해 통과를 확인한다.
  2. 계획·구현을 수행한 모델과 **다른 벤더 모델**(Non-Anthropic 포함, 최소 동급 이상 역량)로 사용자가 직접 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 사용자가 audit 결과(지적 사항·감사 모델)를 summary에 반영·기록한다. 발견사항 보정은 issue-work `--response`로 검토한다 — **피드백 먼저, 항목별 승인 후에만** 앞 Task를 보정하며, 리포트를 받자마자 자동 보정하지 않는다.
- **완료 기준**: `[D]` 검증 명령 전부 통과 + 구현 모델 ≠ audit 모델 기록이 summary 모델 칸("벤더, 모델명" 형식)에 남는다.
