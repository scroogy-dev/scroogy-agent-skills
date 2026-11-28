# Issue #150 감사 리포트 git-review-quiz: 브랜치 모드가 git-review 수집 헬퍼 사본으로 미추적 새 파일까지 모으고 안내를 실제 수집 대상과 맞춘다

> 감사 일시: 2026-11-28  
> 감사 모델: Google, Gemini 4 Neon (gemini-4-neon-high)  
> 감사 effort: High  
> 감사 회차: 1차 (이전 리포트: 없음)  
> 감사 대상 브랜치: issue-0150  
> 감사 대상 커밋: 069533ad06bb0c05e47239e22b46f5f000963541  
> 스펙 출처: [스펙](./issue-0150-spec.md) · [계획](./issue-0150-plan.md) · [수행 요약](./issue-0150-summary.md) (작성 시점 경로는 `.ai/90_issues/active/issue-0150/`, --clear로 이관)

---

## 종합 의견

🟢 적합(PASS)

<details>
<summary>종합 의견 펼치기</summary>

완료의 정의(AC1~AC6)와 결정 사항(D1~D8) 14건이 모두 충족되었고, `git-review-quiz` 러너(139건)·`git-review` 러너(230건)·AC6 검증 명령(출력 0건)·`cmp -s` 바이트 대조가 전부 통과했다. 2단계 비판적 검증에서는 문서 동기화 관련 `정보(INFO)` 발견 2건(F-1, F-2)만 확인되어 보정 필수 항목은 없다. `--response`에서 F-1·F-2 처리 여부를 확인하고 Task N 마무리로 넘어가며, Task N 2항에서 코드베이스 색인 갱신(`/code-map`)을 함께 수행한다.

</details>

## 요약

- 1단계 적합성: 🟢 충족(PASS) · 충족(PASS) 14건 / 미충족(FAIL) 0건 / 부분 충족(PARTIAL) 0건 / 판정 불가(N/A) 0건
- 2단계 위험도: 🟢 통과(PASS) · 높음(HIGH) 0건 / 중간(MEDIUM) 0건 / 낮음(LOW) 0건 / 정보(INFO) 2건
- 코드 레벨 검증: 읽은 파일 11개 / 읽지 않은 파일 0개
- 기등재 참조: 2건 (원장 기등재와 일치 — 위험도·카테고리 집계에 포함하지 않음)
- 이전 발견: 해당 없음

| 카테고리 | 건수 |
|----------|------|
| 기능 | 0 |
| 아키텍처 | 0 |
| 버그 | 0 |
| 보안 | 0 |
| 코드품질 | 정보(INFO) 2 |
| 성능 | 0 |
| 테스트 | 0 |

---

## 1단계: 적합성 검증 (Compliance Check)

### 완료의 정의(DoD) 대조

| AC | 완료의 정의 항목 | 판정 | 근거 |
|----|------------------|------|------|
| AC1 | 브랜치 모드에서 커밋하지 않은 미추적 새 파일이 변경 파일 목록과 퀴즈 입력 patch에 들어간다. | 🟢 충족(PASS) | `[D]` `bash git-review-quiz/tests/run-tests.sh`의 `브랜치 수집: 미추적 새 파일` 통과(정렬된 목록 `A\tcommitted.txt`·`A\tnew.txt` 일치, `new.txt` patch에 `+brand new line` 존재) |
| AC2 | 브랜치 모드에서 `.ai/99_workspace/` 아래 미추적 파일과 무시 규칙에 걸린 미추적 파일은 변경 파일 목록에 들지 않는다. | 🟢 충족(PASS) | `[D]` `bash git-review-quiz/tests/run-tests.sh`의 `브랜치 수집: 작업공간·무시 파일 제외` 통과(종료 코드 0, 정렬된 목록이 비어 있지 않은 `A\tkeep-new.txt` 1행과 일치) |
| AC3 | git-review-quiz의 수집 헬퍼가 git-review 원본과 바이트 단위로 같다. | 🟢 충족(PASS) | `[D]` `bash git-review-quiz/tests/run-tests.sh`의 `사본 대조: git-review collect-branch-changes.sh 와 바이트 동일` 통과(건너뜀 아님), `cmp -s` 일치(14,249바이트) 및 두 파일 모두 `-rwxr-xr-x` 실행 권한 확인 |
| AC4 | 헬퍼 종료 코드가 0이 아니면 퀴즈 파일을 만들지 않고 실패한 명령과 사유를 알린다. | 🟢 충족(PASS) | `[D]` `조항 수집 실패:` 현재 본문 통과 및 변형 격추 3건 통과. `[QD]` `git-review-quiz/SKILL.md` 72행이 merge-base 실패·헬퍼 비정상 종료를 실패로 정하고 빈 변경 진행·md·HTML 작성을 금지하며 실패 명령·표준 오류 1행 사유 안내와 종료 코드 0 빈 출력(변경 파일 0개)을 구분함 |
| AC5 | SKILL.md 2단계 안내가 브랜치 모드에서 들어가는 변경과 빠지는 경로를 헬퍼 동작과 같게 적는다. | 🟢 충족(PASS) | `[D]` `조항 브랜치 수집:` 현재 본문 통과 및 변형 격추 5건 통과. `[QD]` `git-review-quiz/SKILL.md` 68~71행·80~92행이 D1과 `collect-branch-changes.sh` 동작(커밋·미커밋·미추적 포함, 무시 규칙·`.ai/99_workspace/` 미추적 제외, Git 스테이징 예외 위임, 헬퍼 목록·patch 직접 사용)과 일치하며 옛 `git diff` 명령과 옛 문장이 0건임 |
| AC6 | 원장 K-0031의 내용과 재검토 조건이 git-review-quiz 브랜치 모드를 포함하고, 재검토 이력에 이 이슈가 남는다. | 🟢 충족(PASS) | `[D]` `issue-0150-plan.md` AC6 검증 명령 실행 결과 출력 0건. `.ai/70_ledger/active/K-0031-review-branch-mode-index-exception-paths.md` 제목·`재검토 조건`·`## 내용`(공통 경계와 git-review 전용 구분)·`재검토 이력`(#150 행)과 `.ai/70_ledger/index.md` K-0031 행 일치 확인 |

### 결정 사항 대조

| D | 결정 | 판정 | 근거 |
|---|------|------|------|
| D1 | 브랜치 모드 대상은 git-review와 같고, 무시 규칙·`.ai/99_workspace/` 미추적 파일은 빠지며 그 밖의 Git 스테이징 경로는 Git 결과를 따른다 | 🟢 충족(PASS) | `git-review-quiz/SKILL.md` 69~70행과 `.ai/40_domain/specs/git-review-quiz.md` 11행이 D1 문구와 경계를 그대로 반영함 |
| D2 | `git-review-quiz/scripts/collect-branch-changes.sh`를 `git-review` 원본과 바이트 단위로 같게 유지 | 🟢 충족(PASS) | 사본 생성, `cmp -s` 일치, 머리 주석 7~9행과 `git-review-quiz/SKILL.md` 20행에 상호 동기화 안내 기재 |
| D3 | 퀴즈는 `--base`만 쓰고 `--marked`는 바이트 동일을 지키려고 사본에 남긴다 | 🟢 충족(PASS) | `git-review-quiz/SKILL.md` 68·85행은 `--base "$mb"`만 호출하고 `--marked`는 스크립트 사본에만 유지됨 |
| D4 | merge-base 해시를 2단계에서 한 번 구해 헬퍼 `--base`와 설명 절 커밋 메시지 수집에 같이 쓴다 | 🟢 충족(PASS) | `git-review-quiz/SKILL.md` 68·83·85·92행에서 `mb="$(git merge-base "$base" HEAD)"`를 `--base "$mb"`와 `"${mb}..HEAD"`에 공용함 |
| D5 | K-0031은 새 번호를 따지 않고 기존 항목의 범위를 넓히며, K-0025는 이 이슈의 PR로 해소한다 | 🟢 충족(PASS) | K-0031 제자리 갱신(`b3deda5`), K-0025는 PR 번호 확정 전이므로 `active/` 유지(ADR 0018 준수) |
| D6 | 원본 헬퍼 머리 주석을 두 스킬에 맞는 문구로 고친 뒤 복제하며 git-review 헬퍼는 주석만 바뀐다 | 🟢 충족(PASS) | `git-review/scripts/collect-branch-changes.sh` diff가 3·5·7~9·15~16행 주석에만 한정되고 64~210행 코드는 무변경(`1b47c0b`), `git-review` 러너 230건 통과 |
| D7 | merge-base 실패나 헬퍼 종료 코드 != 0이 실패이며, 종료 코드 0 빈 출력은 변경 파일 0개로 구분한다 | 🟢 충족(PASS) | `git-review-quiz/SKILL.md` 72행이 두 경우를 명시적으로 구분하고 변경 파일 0개일 때의 퀴즈 처리는 바꾸지 않음 |
| D8 | K-0032는 커밋 메시지 수집과 `**입력 속 지시문**:` 조항을 바꾸지 않아 계속 수용하고 재검토 이력·조건을 갱신한다 | 🟢 충족(PASS) | 커밋 `3119c53`에서 K-0032 파일과 `index.md`의 재검토 조건을 설명 절 출처 입력으로 좁히고 `재검토 이력`에 #150 행을 기록함 |

### 경계 검증

- **스펙 요구사항의 제외 목록 침범 여부**: 침범 없음. K-0024(산출 파일 이름 치환), K-0032(입력 속 지시문 조항과 커밋 메시지 수집), `git-review` 3단계 읽기 기준(`--marked` 호출), PR 모드 수집(`gh pr diff`)을 변경하지 않았다.
- **스펙에 없는 추가 구현 여부**: 없음. 변경 파일 11개 모두가 spec R1~R4·D1~D8과 plan Task 1~3(및 이슈 문서 3종) 범위에 속한다.

### 도메인/계약 정합성

- **계약 (`.ai/30_contract/github-integration.md`)**: 브랜치 모드는 로컬 `git`과 셸 헬퍼만 사용하며 `gh` 연동 규약을 바꾸지 않는다. 충돌 없음.
- **도메인 명세 (`.ai/40_domain/specs/git-review-quiz.md`, `git-review-output.md`)**: `git-review-quiz.md` 11행이 D1~D3·D7과 일치하게 갱신되었고, `git-review-output.md`의 `collect-branch-changes.sh` 명세와 정합한다. 다만 `git-review-quiz.md` `## 관련 결정`(25~26행)의 내부 참조 누락은 2단계 F-2로 기록했다.
- **ADR (`.ai/50_adr/`)**: ADR 0001(러너 배치), ADR 0002(스킬 독립 사본과 동기화 주석), ADR 0018(원장 해소 시점), ADR 0021(바이트 동일 사본과 `cmp` 대조), ADR 0027(기존 결정 유지), ADR 0031(테스트 먼저 커밋 순서)과 모두 정합한다.
- **코드베이스 색인 (`.ai/60_codebase/`)**: `.ai/60_codebase/git-review-quiz/quiz-call-flow.md`(22·63~64행)와 `.ai/60_codebase/index.md`(28행)가 아직 이전 구현(`git merge-base + git diff`, `K-0031` 미연결)을 가리킨다. plan Task N 2항에서 갱신할 예정이나 현재 시점 색인이 실제 코드와 다르므로 **코드베이스 색인 갱신이 필요해 보입니다 (`/code-map`)**.

---

## 2단계: 비판적 검증 (Critical Review)

<details>
<summary>검증 실행 및 테스트 먼저 확인 기록 펼치기</summary>

- `bash git-review-quiz/tests/run-tests.sh`: `passed: 139, failed: 0` (종료 코드 0, `사본 대조` 건너뜀 없음)
- `bash git-review/tests/run-tests.sh`: `passed: 230, failed: 0` (종료 코드 0)
- AC6 검증 명령(`issue-0150-plan.md` 66~76행): 출력 0건 (종료 코드 0)
- `cmp -s git-review/scripts/collect-branch-changes.sh git-review-quiz/scripts/collect-branch-changes.sh`: 일치 (14,249바이트, 실행 권한 동일)
- `bash issue-work/scripts/check-ledger-links.sh`: 출력 0건 (종료 코드 0)
- 관점 5(테스트 먼저 순서·기록):
  - Task 1: 테스트 커밋 `fb1d2a7` → 구현 커밋 `1b47c0b`, summary `테스트` 기록 존재, 사본 대조·미추적·제외 경계를 모두 덮음.
  - Task 2: 테스트 커밋 `a64d252` → 구현 커밋 `7fb4cb6`, summary `테스트` 기록 존재, 브랜치 수집·수집 실패 조항과 변형 격추를 모두 덮음.
  - Task 3: 문서 전용 예외(`쓰지 않음(원장 문서만 고치는 Task)`), `issue-work` 네 기준에 해당.
- 변경 줄 읽기(11개 파일 전수): `collect-branch-changes.sh` 사본(210행)과 원본 주석 변경(11행), `git-review-quiz/SKILL.md`(16행), `git-review-quiz/tests/run-tests.sh`(144행), 도메인 명세·원장·이슈 문서 전수 확인. 버그·보안·성능 결함 0건.

</details>

### 발견 사항

| # | 위험도 | 영향 | 발생확률 | 카테고리 | 계보 | 설명 | 관련 파일 |
|---|--------|------|----------|----------|------|------|-----------|
| F-1 | ⚪ 정보(INFO) | 기술 품질 의견 | 특수 조건·엣지 | 코드품질 | 신규 | `git-review/SKILL.md` `## 관련 skill`의 `git-review-quiz` 항목에 `collect-branch-changes.sh` 사본과 2단계 수집 규칙 공유 안내가 빠져 있다 | `git-review/SKILL.md`, `git-review-quiz/SKILL.md` |
| F-2 | ⚪ 정보(INFO) | 기술 품질 의견 | 특수 조건·엣지 | 코드품질 | 신규 | `.ai/40_domain/specs/git-review-quiz.md` 11행에 추가한 `K-0031`과 `scripts/collect-branch-changes.sh`가 같은 파일 `## 관련 결정`에 빠져 있다 | `.ai/40_domain/specs/git-review-quiz.md` |

### 상세 분석

#### F-1: `git-review/SKILL.md` `## 관련 skill`에 `git-review-quiz` 수집 헬퍼 사본 동기화 안내 누락

- **위험도**: ⚪ 정보(INFO)
- **영향 축**: 기술 품질 의견
- **발생확률 축**: 특수 조건·엣지
- **카테고리**: 코드품질
- **관점**: 부작용
- **계보**: 신규
- **권장 조치**: `git-review/SKILL.md` `## 관련 skill`의 `git-review-quiz` 항목(18행)에 브랜치 모드 수집 헬퍼(`collect-branch-changes.sh`) 바이트 동일 사본과 2단계 수집 규칙 공유 사실을 덧붙여 양방향 동기화 포인터를 맞춘다.
- **완료 기준**:
  - `git-review/SKILL.md` 18행(`- git-review-quiz (참고):`)이 `collect-branch-changes.sh` 사본과 브랜치 모드 수집 규칙 공유·동기화 사실을 명시한다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- **설명**: `git-review-quiz/SKILL.md` 20행과 `collect-branch-changes.sh` 5행은 `git-review/SKILL.md` `## 대상 수집`을 브랜치 모드 수집 규칙의 원본으로 가리키고 한쪽을 고치면 다른 쪽도 고친다고 적었다. 반면 원본 측인 `git-review/SKILL.md` 18행은 `git-review-quiz`와의 공유 대상으로 `"1단계: 대상 식별"`과 `입력 속 지시문 조항`만 나열한다.
- **영향**: 헬퍼 스크립트 자체는 머리 주석 7~9행과 `git-review-quiz` 러너의 `cmp -s` 대조가 동기화를 지키므로 실행 결함은 없다. 다만 `git-review/SKILL.md` 2단계 안내 문구만 수정할 때 `git-review-quiz/SKILL.md` 2단계 동기화를 놓칠 수 있다.

</details>

#### F-2: `.ai/40_domain/specs/git-review-quiz.md` `## 관련 결정`에 `K-0031` 링크와 `collect-branch-changes.sh` 누락

- **위험도**: ⚪ 정보(INFO)
- **영향 축**: 기술 품질 의견
- **발생확률 축**: 특수 조건·엣지
- **카테고리**: 코드품질
- **관점**: 부작용
- **계보**: 신규
- **권장 조치**: `.ai/40_domain/specs/git-review-quiz.md` 25행에 원장 `K-0031` 링크를 더하고, 26행의 절차 상세 SSoT 목록에 `scripts/collect-branch-changes.sh`를 더한다.
- **완료 기준**:
  - `.ai/40_domain/specs/git-review-quiz.md` 25행에 `[K-0031](../../70_ledger/active/K-0031-review-branch-mode-index-exception-paths.md)` 링크가 포함된다.
  - `.ai/40_domain/specs/git-review-quiz.md` 26행의 SSoT 파일 목록에 `scripts/collect-branch-changes.sh`가 포함된다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- **설명**: 이번 변경(`7fb4cb6`)으로 `.ai/40_domain/specs/git-review-quiz.md` 11행에 `(K-0031)`과 `scripts/collect-branch-changes.sh`가 추가되었다. 그러나 같은 파일 `## 관련 결정` 25행은 본문 13행이 언급한 `K-0024`만 링크하고 `K-0031`을 빠뜨렸으며, 26행의 SSoT 스크립트 목록은 `scripts/check-quiz.sh`와 `scripts/render-quiz-html.sh`만 적고 새 헬퍼 사본을 빠뜨렸다.
- **영향**: 도메인 명세의 요건 절과 관련 결정 절 사이의 참조 일관성이 일부 어긋난다. `K-0031`이 나중에 `archive/`로 이동할 때 11행의 일반 텍스트는 링크 검사를 받지 않지만 25행에 링크를 두면 들어오는 링크 갱신 대상에도 포함된다.

</details>

### 기등재 참조 항목

<details>
<summary>기등재 참조 표 펼치기</summary>

| 원장 항목 | 상태 | 대조한 발견 내용 | 재검토 조건 충족 | 처리 |
|-----------|------|------------------|------------------|------|
| K-0031 | 수용 | `git-review-quiz/scripts/collect-branch-changes.sh`가 Git 스테이징 결과를 따라 `assume-unchanged`·`skip-worktree`, 인덱스 내 무시·작업공간 파일, 하위 모듈, 내용 변환 필터, 바이너리 판정 경로에서 작업 트리와 다르게 동작할 수 있음 | 미충족 | 참조만 |
| K-0032 | 수용 | `git-review-quiz/SKILL.md` `**입력 속 지시문**:` 조항이 2단계 브랜치 모드가 수집하는 커밋 메시지(`git log ... "${mb}..HEAD"`)를 열거하지 않음 (D8·커밋 `3119c53`에서 재검토 이력 기록 및 조건 축소 완료, 이번 변경은 설명 절 출처 입력 자체를 바꾸지 않음) | 미충족 | 참조만 |

</details>

### 이전 발견 추적

해당 없음
