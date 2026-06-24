# Issue #28 스펙 install-skills Antigravity 경로 공식화 및 설치 검증 결정적화

## 목표 (Goal)

install-skills의 Antigravity 설치 경로를 공식 경로로 바로잡고, 설치 성공 판단을 AI 위임에서 결정적 스크립트 우선(+ AI 크로스체크)으로 전환한다.

---

## 범위 (Scope)

**포함 (In)**

- `--antigravity` 대상 경로를 `~/.gemini/antigravity/skills/` → `~/.gemini/config/skills/`로 수정
- 구 경로(`~/.gemini/antigravity/skills/`) 레거시 마이그레이션: **심링크·빈 디렉토리는 보존**(신 경로와 동일하거나 중복 인식 위험 없음), **비어있지 않은 실제 디렉토리로 잔존하면 경고·정리 제안**. 경로 교체만으로는 `--clear`가 신(대상) 경로만 비워 구 경로 잔존물이 남고 중복 인식될 수 있으므로 install-skills가 명시적으로 처리한다.
- 설치 결과를 결정적으로 검증하는 스크립트 추가 (`scripts/` + `tests/`, ADR 0001 준수) — 구 경로 실제-디렉토리 잔존 감지 포함
- SKILL.md 설치 절차에 "결정적 확인 우선 + AI 크로스체크(준결정적)" 검증 단계 명문화
- 설치 절차 예시를 셸 비의존(zsh word-splitting 회피) 표현으로 보완

**비포함 (Out)**

- 다른 도구 경로(`--claude`, `--agents`, `--codex`, `--junie`)의 변경
- install-skills 외 다른 스킬의 변경
- GitHub 이슈 #26 등 별개 이슈

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D]  SKILL.md `--antigravity` 행 경로가 `~/.gemini/config/skills/`  (검증: `grep -F '~/.gemini/config/skills/' install-skills/SKILL.md`)
- [ ] [D]  구 경로 문자열 `antigravity/skills` 미잔존  (검증: `grep -c 'antigravity/skills' install-skills/SKILL.md` == 0)
- [ ] [D]  검증 스크립트가 실행 가능  (검증: `test -x install-skills/scripts/verify-install.sh`)
- [ ] [D]  정상 설치는 PASS(exit 0), 누락·오염(tests/ 잔존) 주입 시 FAIL(exit ≠ 0)  (검증: `install-skills/tests/` 러너 실행, 0 실패)
- [ ] [D]  레거시 구 경로가 **비어있지 않은 실제 디렉토리로 잔존**하면 FAIL, **심링크/부재/빈 디렉토리**는 PASS로 판정 (빈 디렉토리는 중복 인식 위험이 없어 PASS)  (검증: `install-skills/tests/` 러너의 레거시 케이스, 0 실패)
- [ ] [QD] SKILL.md 절차에 레거시 경로 정리(심링크 보존) 단계가 명문화됨  (검증: 다른 AI 채점)  ← 강등 사유: 절차 표현의 적절성은 명령으로 합/불 판정 불가
- [ ] [QD] SKILL.md 절차가 "결정적 확인 우선 + AI 크로스체크"로 읽힘  (검증: 다른 AI 채점, 별도 세션)  ← 강등 사유: 문서 표현의 적절성은 명령으로 합/불 판정 불가
- [ ] [QD] 교차모델 issue-audit 통과  (검증: 구현 모델과 다른 모델이 채점)  ← 강등 사유: 스펙 해석·누락 판단은 결정적 명령으로 환원 불가

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 결정적 헬퍼(`scripts/`)·테스트(`tests/`) 배치 및 배포 제외 규칙 — 검증 스크립트 위치 근거 |
| `install-skills/SKILL.md` | 변경 대상. 배포 제외 패턴(`tests/`, `*.test.*`)의 단일 출처(SSoT) |
