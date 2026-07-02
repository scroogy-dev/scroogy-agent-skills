# Issue #37 감사 리포트 issue-work --clear: archive 이관 시 이동 md 본문의 경로 참조 미갱신 개선

> 감사 일시: 2026-07-02  
> 감사 모델: OpenAI, GPT-5.5  
> 감사 대상 브랜치: issue-0037  
> 스펙 출처: [`./issue-0037-spec.md`](./issue-0037-spec.md) (작성 시점 경로는 `.ai/90_issues/active/issue-0037/issue-0037-spec.md`, --clear로 이관)

---

## Phase 1: 적합성 검증 (Compliance Check)

### 요구사항 대조

| # | 요구사항 | 판정 | 근거 |
|---|----------|------|------|
| 1 | `issue-work/SKILL.md`의 `--clear`와 `## 이슈 완료 시`에 경로 참조 갱신 단계를 추가한다. | PASS | `issue-work/SKILL.md:78`에 이슈 완료 시 갱신 단계가 있고, `issue-work/SKILL.md:138-157`에 `--clear` 6단계 "경로 참조 갱신·검증"이 있다. |
| 2 | 대상 패턴 3종(active 잔존, `99_workspace` 잔존, 상대 링크 깊이 변화)을 모두 커버한다. | PASS | `issue-work/SKILL.md:140-144`가 함께 이동한 파일의 `./` 상대 링크, `active/issue-<번호>/...`, `99_workspace/...`, `../` 상대 깊이 재계산, archive 본문 `99_workspace/` 잔존 금지를 모두 명시한다. |
| 3 | 함께 이동한 파일 간 참조를 `./` 상대 링크로 통일한다. | PASS | `issue-work/SKILL.md:140`에 함께 이동한 파일 간 참조를 `./<파일명>`으로 재작성하라고 명시됐다. |
| 4 | 이관 이력 표기를 새 경로 링크 + "(작성 시점 경로는 ..., --clear로 이관)" 형식으로 표준화한다. | PASS | `issue-work/SKILL.md:143`에 표준 병기 문구가 명시됐다. |
| 5 | 이관 완료 후 stale 참조 0건을 확인하는 grep 기반 결정적 검증 절차를 추가한다. | PASS | `issue-work/SKILL.md:151-153`의 grep 스니펫이 `90_issues/active/`, `active/issue-[0-9]+`, `99_workspace/[A-Za-z0-9_.-]`를 검사한다. 이전 audit의 F-1 지적은 `active/issue-[0-9]+` 추가로 해소됐다. |
| 6 | workflow 템플릿(SSoT)과 active 사본의 `## 이슈 완료 시`를 동기화한다. | PASS | `issue-work/templates/issue-workflow-template.md:41`과 `.ai/90_issues/active/issue-workflow.md:41` 모두 경로 참조 갱신 문구를 포함하며, 두 파일의 `diff` 결과가 비어 있다. |
| 7 | 설치본 `~/.claude/skills/issue-work/`를 repo와 동기화한다. | PASS | `diff -rq issue-work /Users/user/.claude/skills/issue-work` 결과가 비어 있다. |

### 완료의 정의(DoD) 대조

| # | DoD 항목 | 판정 | 근거 |
|---|----------|------|------|
| 1 | `grep -c '경로 참조 갱신' issue-work/SKILL.md` >= 2 | PASS | 실행 결과 `2`. |
| 2 | `grep -c 'grep -' issue-work/SKILL.md` >= 1 | PASS | 실행 결과 `3`. |
| 3 | workflow 템플릿과 active 사본 모두 `경로 참조 갱신` 매칭 | PASS | `grep -l` 결과 두 파일 모두 출력됐다. |
| 4 | workflow 템플릿과 active 사본이 동일하다 | PASS | `diff issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md` 결과 출력 없음. |
| 5 | 설치본이 repo와 동기화되어 있다 | PASS | `diff -rq issue-work /Users/user/.claude/skills/issue-work` 결과 출력 없음. |
| 6 | 깨짐 패턴 3종과 오탐 처리 방침을 의미상 커버한다 | PASS | 규칙은 세 패턴을 모두 명시하고, `issue-work/SKILL.md:147-157`이 0건 통과, 1건 이상 AI 건별 판정, `active/issue-workflow.md`와 표준 병기 문구 제외 근거를 설명한다. |

### 범위 검증

- **스펙 비포함(Out) 침범 여부**: PASS. 기존 archive 파일의 stale 참조 소급 보정은 수행하지 않았고, 다른 스킬의 링크 규칙도 변경하지 않았다.
- **스펙에 없는 추가 구현 여부**: PASS. 브랜치 전체 변경은 이슈 문서 3개, `issue-work/SKILL.md`, workflow 템플릿, active workflow 사본에 한정된다.

### 도메인/계약/ADR 정합성

- `.ai/30_contract/index.md`: 관련 계약 문서 없음.
- `.ai/40_domain/index.md`: 이번 절차 변경과 충돌하는 도메인 정책 문서 없음.
- `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md`: 이번 변경은 helper/script 추가가 아니라 문서 절차와 grep 스니펫 보정이므로 충돌 없음.
- `.ai/60_codebase/index.md`: 색인은 비어 있음. 실제 diff와 소스 문서를 SSoT로 확인했다.

---

## Phase 2: 비판적 검증 (Critical Review)

### 발견 사항

| # | 위험도 | 분류 | 설명 | 관련 파일 |
|---|--------|------|------|-----------|
| F-1 | INFO | 누락된 검증 | 이전 audit의 MEDIUM 지적(`active/issue-<번호>` 상대 경로 미탐지)은 `active/issue-[0-9]+` 추가로 해소됐다. 실사례 `archive/issue-0009/issue-0009-summary.md:108`의 `active/issue-0009/`가 현재 스니펫에 검출된다. | `issue-work/SKILL.md:151` |
| F-2 | LOW | 엣지케이스 | `99_workspace/[A-Za-z0-9_.-]`는 파일·하위 경로 중심이라 bare `.ai/99_workspace/` 디렉토리 참조만 남는 경우는 직접 검출하지 않는다. 다만 사용자가 이미 보류 결정했고, `99_workspace/` 디렉토리는 `.gitkeep`으로 상주하므로 dead link 재발 위험은 낮다. | `issue-work/SKILL.md:144`, `issue-work/SKILL.md:151` |

### 상세 분석

#### F-1: `active/issue-<번호>` 상대 경로 미탐지 지적은 해소됨

- **위험도**: INFO
- **분류**: 누락된 검증
- **설명**: 보정 전 스니펫은 `90_issues/active/`만 검색해 `active/issue-0031/...` 같은 상대 경로를 놓칠 수 있었다. 현재 스니펫은 `active/issue-[0-9]+`를 포함한다.
- **검증**: `grep -rnE '90_issues/active/|active/issue-[0-9]+|99_workspace/[A-Za-z0-9_.-]' .ai/90_issues/archive/issue-0009/` 실행 시 `issue-0009-summary.md:108`의 `active/issue-0009/`가 검출됐다.
- **권장 조치**: 추가 조치 불필요.

#### F-2: bare `.ai/99_workspace/` 디렉토리 참조는 직접 탐지하지 않음

- **위험도**: LOW
- **분류**: 엣지케이스
- **설명**: 스니펫은 `99_workspace/` 뒤에 파일명·하위 경로 문자가 이어지는 경우를 검사한다. 따라서 `.ai/99_workspace/`처럼 디렉토리 자체만 적힌 참조는 검출되지 않을 수 있다.
- **영향**: 파일 경로 stale 참조는 잡지만, bare 디렉토리 참조는 사람이 별도로 읽지 않으면 남을 수 있다. 다만 현재 summary에 기록된 처리 방침처럼 bare 디렉토리는 `.gitkeep`으로 상주하고, 절차 서술 문구까지 전부 잡도록 넓히면 상시 오탐 비용이 커진다.
- **권장 조치**: 현행 보류 결정을 유지해도 스펙 완료를 막는 수준은 아니다. 향후 실제 dead link 사례가 나오면 별도 이슈로 `99_workspace/` bare 참조까지 잡는 보조 스니펫을 검토한다.

---

## 검증 명령

| 명령 | 결과 |
|------|------|
| `git diff --name-status main...HEAD` | 이슈 문서 3개 추가, `issue-work/SKILL.md`, workflow 템플릿, active 사본 수정 |
| `grep -c '경로 참조 갱신' issue-work/SKILL.md` | `2` |
| `grep -c 'grep -' issue-work/SKILL.md` | `3` |
| `grep -l '경로 참조 갱신' issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md` | 두 파일 모두 출력 |
| `diff issue-work/templates/issue-workflow-template.md .ai/90_issues/active/issue-workflow.md` | 출력 없음 |
| `diff -rq issue-work /Users/user/.claude/skills/issue-work` | 출력 없음 |
| `git diff --check` | 출력 없음 |
| `git diff --check main...HEAD` | 출력 없음 |

---

## 종합 의견

재검증 결과, 이전 audit의 주요 MEDIUM 지적(F-1)은 해소됐다. `active/issue-[0-9]+` 보정은 스펙의 첫 번째 깨짐 패턴을 직접 커버하고, 실제 archive 실사례에서도 검출 동작을 확인했다.

Issue #37의 스펙 및 DoD는 현재 구현 기준으로 충족한다. 남은 F-2는 사용자가 명시적으로 보류한 낮은 위험의 엣지케이스이며, 이번 이슈 완료를 막는 결함으로 보지는 않는다.
