# Issue #35 스펙 install-skills self-install형으로 전환 — 다중 스킬 repo에서 복제본 없이 실행

> 원본 이슈: https://github.com/scroogy-dev/scroogy-agent-skills/issues/35

## 목표 (Goal)

`install-skills`를 홈에 한 벌만 두고, 어느 스킬 repo에서든 복제본 없이 `/install-skills`로 실행할 수 있게 self-install형으로 전환한다.

---

## 범위 (Scope)

**포함 (In)**

- 자기제외 규칙 조건화 — 일반 배포 시에는 `install-skills` 자신을 계속 제외하되, 명시적 self-install(예: `--self`) 시에는 홈에 자기 자신을 설치할 수 있게 부트스트랩 절차를 `install-skills/SKILL.md`에 명문화한다.
- 헬퍼 스크립트 경로 홈 우선 탐색 — `verify-install.sh` 등 헬퍼 참조를 홈 설치본(`~/.claude/skills/install-skills/scripts/...`) 우선, 없으면 cwd 상대 경로 폴백 순으로 탐색하도록 바꾼다.
- 스킬 repo 판별 가드 — 임의의 cwd에서 실수로 실행해 엉뚱한 디렉토리를 소스로 삼는 오설치를 막는 가벼운 가드를 둔다. 기존 "스캔 목록 제시 → 사용자 선택" 절차는 유지한다.
- 스킬 감사 피드백 반영 (install-skills 한정) — `.ai/99_workspace/skill-audit-report.md`(2026-07-02)의 install-skills 항목을 반영한다: description 트리거 커버리지 확장(P1), 설치본에서 깨지는 ADR 상대 링크 정리(P1), 6·7단계 상세의 `references/` 분리와 환경 과적합 서사·중복 서술 정리(P2·P3).

**비포함 (Out)**

- `scroogy-content-skills` / `platform-compliance-skills`의 `install-skills` 복제본 제거 — 이 이슈의 self-install 지원이 선행되어야 가능한 **후속 별도 이슈**.
- 감사 리포트의 issue-work 등 **다른 스킬** 피드백 반영 — 이 이슈에서는 install-skills 항목만 다룬다.
- 기존 설치 경로 옵션(`--claude`/`--agents`/`--antigravity`/`--codex`/`--junie`/`--all`/`--clear`)의 동작 변경 — 회귀 방지만 하며 신규 동작을 얹지 않는다.

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D]  `install-skills`를 홈에 self-install하는 절차(자기제외 규칙 조건화, `--self`)가 SKILL.md에 명문화됨  (검증: `grep -q -- '--self' install-skills/SKILL.md`)
- [ ] [D]  `verify-install.sh` 등 헬퍼 참조가 "홈 설치본 우선, 없으면 cwd 폴백" 순으로 탐색하도록 SKILL.md에 기재됨  (검증: `grep -q '.claude/skills/install-skills/scripts' install-skills/SKILL.md` 그리고 폴백 경로 문구 존재)
- [ ] [D]  스킬 repo 판별 가드가 SKILL.md에 추가됨  (검증: 가드 로직 문구가 `grep`으로 확인됨 — 예: `*/SKILL.md` 복수 존재 확인)
- [ ] [QD] 비-스킬 디렉토리에서 실행 시 안전하게 중단/경고함  (검증: 다른 AI가 채점, 별도 세션)  ← 강등 사유: 가드는 AI 실행 지침이라 "안전 중단" 분기를 이 세션의 결정적 명령으로 재현·판정하기 어렵다
- [ ] [QD] 홈에 self-install한 뒤, 다른 스킬 repo에서 복제본 없이 `/install-skills`로 그 repo의 skill이 정상 설치됨  (검증: 다른 AI/사람이 실제 실행 확인, 별도 세션)  ← 강등 사유: 홈 실제 설치 + 별도 repo cwd라는 런타임 상태에 의존해 이 세션에서 결정적으로 재현·판정 불가
- [ ] [D]  기존 옵션과 설치 검증(결정적 확인 + AI 크로스체크) 동작이 회귀 없이 유지됨  (검증: `bash install-skills/tests/run-tests.sh` 0 실패)
- [ ] [D]  description에 5개 설치 경로·주요 옵션·배포/재설치/self-install 키워드가 반영됨  (검증: `head -4 install-skills/SKILL.md`에서 `Codex`·`Junie`·`self-install` grep 통과)
- [ ] [D]  SKILL.md에 skill 디렉토리 밖으로 나가는 상대 링크가 없음 — 설치본 dead link 제거  (검증: `! grep -F '](../' install-skills/SKILL.md`)
- [ ] [D]  Antigravity 레거시 판정 상세가 `references/antigravity-legacy.md`로 분리되고 본문은 요약+포인터만 유지  (검증: `test -f install-skills/references/antigravity-legacy.md` + SKILL.md의 참조 grep + `! grep -qi 'inode' install-skills/SKILL.md`)

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `install-skills/SKILL.md` | 변경 대상 본체 — 자기제외 규칙(38줄)·헬퍼 경로 참조(74줄)·스캔 절차(58줄) |
| `install-skills/scripts/verify-install.sh` | 홈 우선 탐색 대상 헬퍼 스크립트 |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 헬퍼(`scripts/`)·테스트(`tests/`) 배치·배포 제외 규칙 (헬퍼 경로 변경 시 참조) |
