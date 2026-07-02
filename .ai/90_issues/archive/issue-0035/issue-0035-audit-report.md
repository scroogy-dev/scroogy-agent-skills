# Issue #35 감사 리포트 install-skills self-install형으로 전환

> 감사 일시: 2026-07-02  
> 감사 모델: OpenAI, GPT-5.5  
> 감사 대상 브랜치: issue-0035  
> 스펙 출처: `.ai/90_issues/active/issue-0035/issue-0035-spec.md`

---

## Phase 1: 적합성 검증 (Compliance Check)

### 요구사항 대조

| # | 요구사항 | 판정 | 근거 |
|---|----------|------|------|
| 1 | 일반 배포 시 `install-skills` 자기 자신은 제외하고, 명시적 `--self` 시 홈에 self-install 가능하도록 절차 명문화 | PASS | `install-skills/SKILL.md`에 `--self` 옵션, Self-install 부트스트랩, 자기제외 조건 해제(`self_install=true`)가 기재됨. `grep -n -- '--self' install-skills/SKILL.md`로 관련 문구 확인. |
| 2 | `verify-install.sh` 등 헬퍼 참조를 홈 설치본 우선, 없으면 cwd 폴백 순으로 탐색 | PASS | `~/.claude/skills/install-skills/scripts/verify-install.sh` 우선, `install-skills/scripts/verify-install.sh` 폴백 문구와 스니펫이 존재함. `run-tests.sh`의 헬퍼 탐색 스니펫 테스트도 홈 우선/폴백 양쪽을 통과함. |
| 3 | 스킬 repo 판별 가드: `*/SKILL.md` 0건 차단, 1건 이상 통과, 1건만 매칭되면 사용자 확인 후 진행 | PASS | spec/plan이 단일 스킬 repo 지원 의도를 명시하도록 정합화되었고, `install-skills/SKILL.md`도 `1건 이상`, `1건만 매칭되면` 확인 지침을 포함함. 스니펫 테스트에서 0건은 중단, 1건은 통과가 확인됨. |
| 4 | 기존 "스캔 목록 제시 -> 사용자 선택" 절차 유지, `--self`일 때만 자기제외 해제 | PASS | SKILL.md의 스캔 절차는 목록 제시 흐름을 유지하며, `self_install=true`일 때만 `install-skills` 제외 조건을 해제함. 스니펫 테스트에서 기본 스캔은 `install-skills` 제외, `--self` 스캔은 포함을 확인함. |
| 5 | install-skills 한정 감사 피드백: description 트리거 커버리지 확장, 설치본 dead link 제거, Antigravity 상세 분리 | PASS | description에 Claude Code/Agents/Antigravity/Codex/Junie와 `--all`/`--clear`/`--self`가 반영됨. `rg -nF '](../' install-skills/SKILL.md` 결과 없음. `references/antigravity-legacy.md` 참조와 본문 축약 확인. |
| 6 | 기존 옵션과 설치 검증 동작 회귀 방지 | PASS | `bash install-skills/tests/run-tests.sh` 실행 결과 18개 통과, 0 실패. 기존 verify-install 9개와 신규 SKILL.md 스니펫 9개가 모두 통과함. |

### 완료의 정의(DoD) 대조

| # | DoD 항목 | 판정 | 근거 |
|---|----------|------|------|
| 1 | `install-skills`를 홈에 self-install하는 절차(`--self`)가 SKILL.md에 명문화됨 | PASS | `--self` 옵션, Self-install 부트스트랩, 자기제외 조건화 문구가 존재함. |
| 2 | 헬퍼 참조가 "홈 설치본 우선, 없으면 cwd 폴백" 순으로 기재됨 | PASS | `.claude/skills/install-skills/scripts`와 cwd 폴백 경로가 SKILL.md에 존재하고, 스니펫 테스트가 홈 우선/폴백을 실행 확인함. |
| 3 | 스킬 repo 판별 가드가 SKILL.md에 추가됨 | PASS | `*/SKILL.md` 1건 이상 통과, 0건 중단, 1건 사용자 확인 지침이 명시됨. |
| 4 | 비-스킬 디렉토리에서 실행 시 안전하게 중단/경고함 | PASS | `run-tests.sh`의 "가드: 비-스킬 디렉토리(0건) -> 중단" 테스트가 exit 1을 기대대로 확인함. |
| 5 | 홈 self-install 뒤 다른 스킬 repo에서 복제본 없이 `/install-skills`로 정상 설치됨 | PASS | summary Task 4에 실제 L2 실행 확인이 기록되어 있고, 현재 SKILL.md는 홈 설치본 실행/다른 cwd 스캔/홈 우선 헬퍼 탐색 흐름을 유지함. 이번 보정은 해당 흐름을 약화하지 않음. |
| 6 | 기존 옵션과 설치 검증(결정적 확인 + AI 크로스체크) 동작이 회귀 없이 유지됨 | PASS | `bash install-skills/tests/run-tests.sh` 결과 `passed: 18, failed: 0`. |
| 7 | description에 5개 설치 경로·주요 옵션·배포/재설치/self-install 키워드가 반영됨 | PASS | frontmatter description에 Claude Code, Agents, Antigravity, Codex, Junie, `--all`, `--clear`, `--self`, 스킬 배포/재설치/self-install 키워드가 존재함. |
| 8 | SKILL.md에 skill 디렉토리 밖으로 나가는 상대 링크가 없음 | PASS | `rg -nF '](../' install-skills/SKILL.md` 결과 없음(exit 1, no matches). |
| 9 | Antigravity 상세가 `references/antigravity-legacy.md`로 분리되고 본문에 `inode` 없음 | PASS | reference 파일 존재, SKILL.md의 해당 파일 참조 확인, `rg -ni 'inode' install-skills/SKILL.md` 결과 없음. |
| 10 | 가드·자기제외 스캔·헬퍼 탐색 스니펫이 SKILL.md 본문에서 추출되어 픽스처 스모크 테스트됨 | PASS | `run-tests.sh`가 세 스니펫을 추출해 9개 스모크 테스트를 수행했고 모두 통과함. |

### 범위 검증

- **스펙 비포함(Out) 침범 여부**: PASS. `scroogy-content-skills` / `platform-compliance-skills`의 `install-skills` 복제본 제거는 수행하지 않았고, issue-work 등 다른 스킬 피드백도 반영하지 않음.
- **스펙에 없는 추가 구현 여부**: PASS. 변경은 Issue #35 보정 범위인 `install-skills/SKILL.md`, `install-skills/tests/run-tests.sh`, 이슈 문서 갱신에 한정됨.

### 도메인/계약/ADR 정합성

- `.ai/30_contract/index.md`: 관련 계약 문서 없음.
- `.ai/40_domain/index.md`: 관련 도메인 정책 문서 없음. `glossary.md`도 이 변경과 충돌하는 내용 없음.
- `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md`: PASS. `scripts/` 헬퍼와 `tests/` 테스트 배치는 ADR과 일치하며, 배포 제외 패턴의 단일 출처를 SKILL.md 설치 절차로 유지함.

---

## Phase 2: 비판적 검증 (Critical Review)

### 발견 사항

| # | 위험도 | 분류 | 설명 | 관련 파일 |
|---|--------|------|------|-----------|
| - | - | - | 보정 필요 발견 사항 없음. 기존 감사 F-1/F-2/F-3는 현재 스펙·계획·SKILL.md·테스트 기준으로 해소됨. | - |

### 상세 분석

#### 기존 F-1: 가드가 "복수 존재 확인"보다 약하다는 지적

- **재판정**: 해소됨
- **근거**: 사용자 승인 보정으로 spec/plan이 "복수 존재 확인"이 아니라 "0건 차단, 1건 이상 통과, 1건이면 사용자 확인"을 의도한 설계로 정합화됨. `install-skills/SKILL.md`도 동일한 문구를 반영했고, `run-tests.sh`가 0건 중단/1건 통과를 스모크 테스트함.

#### 기존 F-2: 새 실행 지침 스니펫 자동 테스트 부재

- **재판정**: 해소됨
- **근거**: `run-tests.sh`가 SKILL.md 본문에서 가드·스캔·헬퍼 탐색 스니펫을 추출해 픽스처에서 실행함. 재검증 결과 `passed: 18, failed: 0`.

#### 기존 F-3: 단일 스킬 repo 지원 여부 모호성

- **재판정**: 해소됨
- **근거**: spec 범위와 plan Task 3/8이 단일 스킬 repo 지원을 명시하고, `install-skills/SKILL.md`도 1건 통과가 설계 의도임을 명시함.

---

## 종합 의견

Issue #35는 현재 스펙 대비 충족으로 판단한다. 이전 감사에서 PARTIAL/MEDIUM/LOW/INFO로 남았던 가드 설계 모호성, 스니펫 테스트 부재, 단일 스킬 repo 지원 모호성은 모두 보정되었다.

결정적 검증은 `bash install-skills/tests/run-tests.sh` 기준 18개 통과, 0 실패다. 추가 보정이 필요한 감사 발견 사항은 없다.
