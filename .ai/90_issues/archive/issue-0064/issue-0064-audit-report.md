# Issue #64 7차 감사 리포트 PR 리뷰 코멘트 검토·대응 스킬 신규 작성

> 감사 일시: 2026-08-02  
> 감사 모델: OpenAI, GPT-5  
> 감사 회차: 7차 (이전 리포트: `issue-0064-audit-report-6.md`)  
> 감사 대상 브랜치: `issue-0064` (`main...HEAD`, `956d0f5..30a3580`; 작업트리에는 감사 리포트 이력만 미추적 상태)  
> 스펙 출처: `./issue-0064-spec.md` (작성 시점 경로는 `.ai/90_issues/active/issue-0064/issue-0064-spec.md`, --clear로 이관) 및 GitHub Issue #64 본문·댓글

---

## 1단계: 적합성 검증 (Compliance Check)

### 요구사항 대조

| # | 요구사항 | 판정 | 근거 |
|---|----------|------|------|
| 1 | 신규 스킬 디렉토리·`SKILL.md` 작성 | 충족(PASS) | `git-pr-feedback/SKILL.md`가 존재하고 frontmatter `name`과 디렉토리명이 일치한다. |
| 2 | 수집 → 분류·의견 → 선택·승인 → 조치 → 결과 요약 절차 정의 | 충족(PASS) | `git-pr-feedback/SKILL.md:32-40`에 5단계가, 후속 절에 단계별 규칙이 정의되어 있다. |
| 3 | 의견 유형 4종 정의 | 충족(PASS) | `git-pr-feedback/SKILL.md:121-135`에 조치 필요·조치 불필요·코멘트로 충분·확인 필요가 모두 정의되어 있다. |
| 4 | 산출물 접기 기준과 작성 원칙 연결 | 충족(PASS) | `## 산출물 접기 기준`이 1개이고 `writing-principles` 참조가 2건이다. |
| 5 | `git-pr/SKILL.md` 관련 skill 역참조 | 충족(PASS) | 관련 skill 절에 `git-pr-feedback` 행이 정확히 1개 추가됐고, 그 외 `git-pr` 본문 변경은 없다. |
| 6 | README·AI-CONTEXT 목록과 디렉토리 구조 반영 | 충족(PASS) | README 목록·관계도와 AI-CONTEXT 목록·디렉토리 트리에 반영됐다. |
| 7 | 코멘트 조회·답글 게시의 `gh` 기본 + GitHub MCP 폴백 | 충족(PASS) | 공식 GitHub MCP 계약의 조회 3종·일반 댓글·코드 라인 답글 도구와 구현 매핑이 일치한다. F-20은 요구사항에 명시되지 않은 resolve 폴백의 계약 변화이므로 1단계 판정을 낮추지 않았다. |
| 8 | `issue-audit` 감사 운영 보강 4건 | 충족(PASS) | 발견 번호 계승·이력화·완료 기준·1단계 결속 제한이 모두 정의됐다. 6차 F-18의 기준선 의미도 스킬과 템플릿에서 `마지막 사용·예약 번호`로 일치한다. |

### 완료의 정의(DoD) 대조

| # | DoD 항목 | 판정 | 근거 |
|---|----------|------|------|
| 1 | 파일 존재·frontmatter 이름 일치 | 충족(PASS) | 명시된 검증 명령 출력 `1`. |
| 2 | 접기 기준 섹션 1개·작성 원칙 참조 | 충족(PASS) | 검증 명령 출력이 각각 `1`, `2`. |
| 3 | `git-pr` 역참조 1개 | 충족(PASS) | 검증 명령 출력 `1`. |
| 4 | README·AI-CONTEXT 스킬 목록 반영 | 충족(PASS) | 검증 명령 출력이 각각 `1`, `1`; AI-CONTEXT 트리 검사도 `1`. |
| 5 | GitHub Issue #64 스킬명 확정 댓글 | 충족(PASS) | `gh issue view` 검증 명령으로 `스킬명 확정` 댓글 1건을 확인했다. |
| 6 | 5단계·4종 의견·외부 공개 행위 승인 게이트의 완전성 | 충족(PASS) | 스펙이 고정한 push 체크리스트 6항목이 `git-pr-feedback/SKILL.md:152-218`에 모두 결속된다. F-20은 체크리스트 밖 별도 발견이므로 이 판정을 낮추지 않았다. |
| 7 | 사용자가 후보 중 스킬명 확정 | 충족(PASS) | 로컬 스펙·요약과 GitHub 확정 댓글이 `git-pr-feedback`으로 일치한다. |

### 범위 검증

- **스펙 비포함(Out) 침범 여부**: 없음. 원장 연계·리뷰 수행·자동 일괄 조치·PR 머지/닫기는 추가하지 않았고, `git-pr/SKILL.md`는 관련 skill 한 줄만 변경했다.
- **스펙에 없는 추가 구현 여부**: 없음. `issue-audit` 보강은 사용자 승인 후 로컬 스펙과 GitHub Issue #64 결정 댓글에 모두 편입됐다.

### 도메인/계약 정합성

- 관련 계약·도메인 문서는 없다. `30_contract/index.md`와 `40_domain/index.md`에 이 기능을 제약하는 항목이 없다.
- 관련 ADR도 없다. ADR 0001은 결정적 헬퍼 테스트 규칙이며, 스크립트가 없는 이번 문서 전용 변경에는 적용되지 않는다.
- `60_codebase/index.md`는 비어 있으며 실제 `main...HEAD` diff를 직접 검증했다. 색인과 구현의 불일치는 발견하지 않았다.

---

## 2단계: 비판적 검증 (Critical Review)

### 발견 사항

| # | 위험도 | 분류 | 계보 | 설명 | 관련 파일 |
|---|--------|------|------|------|-----------|
| F-20 | 중간(MEDIUM) | 암묵적 가정 | F-14 재발 | 현재 공식 GitHub MCP는 `pull_request_review_write(method: resolve_thread)`를 지원하지만, 스킬은 resolve를 항상 미지원으로 처리해 지원 가능한 환경에서도 승인된 조치를 실행하지 않는다. | `git-pr-feedback/SKILL.md:169-181` |

### 이전 발견 추적

| 이전 발견 | 완료 기준 항목 | 판정 (닫힘/잔여) | 근거 |
|-----------|----------------|------------------|------|
| F-18 | 스킬과 템플릿의 번호 기준선 의미 일치 | 닫힘 | `issue-audit/SKILL.md:130-142`와 템플릿 머리말이 모두 `마지막 사용·예약 번호`로 정의한다. |
| F-18 | 발견 0건 회차 뒤 다음 번호가 한 값으로 결정 | 닫힘 | 스킬은 모든 발견·기준선의 최대값에 1을 더하며, 기준선은 마지막 예약 번호라고 명시한다. 기준선 F-13 뒤 첫 신규 번호는 의도대로 F-14다. |
| F-18 | 구버전 번호 재사용 이력에서도 중복·건너뜀 없이 증가 | 닫힘 | 구버전 최대 예약 번호가 F-12이면 기준선 F-12, 첫 신규 번호 F-13이라는 예시가 추가됐다. |
| F-19 | push 수신 시점의 예상 이전 SHA 원자 대조 | 닫힘 | `git-pr-feedback/SKILL.md:209-225`가 `--force-with-lease='refs/heads/<브랜치>:<headRefOid>'`를 명시한다. |
| F-19 | 원격 갱신·삭제·rewind가 모두 미반영·재승인으로 귀결 | 닫힘 | 격리한 bare remote에서 세 경우 모두 명시적 lease가 종료 코드 1로 push를 거부했다. 문서도 새 head 기준 재승인과 기존 승인값 재시도 금지를 명시한다. |
| F-19 | 원자 대조 실패를 성공으로 보고하지 않음 | 닫힘 | `git-pr-feedback/SKILL.md:213-218`이 lease 거부 시 미반영 처리하고, PR head SHA 일치 때만 반영 완료로 보고한다. |

### 상세 분석

#### F-20: 공식 GitHub MCP의 resolve 지원을 미지원으로 고정

- **위험도**: 중간(MEDIUM)
- **분류**: 암묵적 가정
- **계보**: F-14 재발
- **권장 조치**:
  - 실행 시점의 활성 GitHub MCP 도구 스키마를 확인하고, `pull_request_review_write`가 `resolve_thread`와 `threadId`를 지원하면 승인된 스레드를 해당 메서드로 resolve한다.
  - 도구가 없거나 읽기 전용이거나 대상 호스트를 확인할 수 없으면 현재의 안전 종료를 유지하고 unresolved 사유를 결과에 남긴다.
- **완료 기준**:
  - [ ] 활성 도구 스키마가 `resolve_thread`를 지원할 때만 보존한 스레드 `id`로 승인된 resolve를 실행한다.
  - [ ] 도구 부재·읽기 전용·호스트 불일치에서는 계약에 없는 호출 없이 unresolved 상태와 사유를 보고한다.
  - [ ] 결과 요약이 resolve 성공과 미지원을 구분해 실제 상태를 기록한다.

<details>
<summary>근거·상세 설명 펼치기</summary>

- **설명**: 6차까지 참조한 활성 구성에는 resolve 메서드가 없어 미지원 안전 종료가 타당했다. 그러나 2026-08-02 확인한 [GitHub 공식 MCP 서버 문서](https://github.com/github/github-mcp-server)는 `pull_request_review_write`의 `threadId`가 `resolve_thread`·`unresolve_thread`에 필요하다고 명시한다. 현재 문서는 계약이 바뀌어도 항상 “미지원”으로 처리한다.
- **영향**: `gh`는 사용할 수 없고 최신 GitHub MCP 쓰기 도구만 가능한 환경에서 사용자가 resolve를 승인해도 스레드는 미해결로 남는다. 외부 오작동이나 데이터 손실은 없지만 승인된 기능이 불필요하게 누락된다.

</details>

---

## 종합 의견

- **판정**: 충족(PASS). 6차의 F-18·F-19 완료 기준은 모두 닫혔고, 스펙 요구사항 8건과 DoD 7건을 충족한다. 다만 공식 GitHub MCP 계약 변화로 resolve 폴백이 뒤처진 중간 위험 발견 F-20이 남아 있다.
- **집계**: 1단계 PASS 15건 / FAIL 0건 / PARTIAL 0건 / N/A 0건. 2단계 HIGH 0건 / MEDIUM 1건 / LOW 0건 / INFO 0건.
- **검증 결과**: 스펙 `[D]` 항목, AI-CONTEXT 트리, Task 헤더·일반 Task 결과·수행 모델 게이트를 통과했다. GitHub의 스킬명·Task 4 결정 댓글은 각 1건 확인했다. 회귀 테스트는 install-skills 20건·issue-work 27건 모두 통과했고, 명시적 lease는 격리한 bare remote의 원격 갱신·삭제·rewind 세 경우를 모두 거부했다. `git diff --check main...HEAD`의 Markdown 강제 줄바꿈용 후행 공백 1건은 기존 템플릿 표기와 같은 렌더링 용도라 발견으로 집계하지 않았다.
- **교차모델 조건**: 일반 Task의 수행 모델은 모두 Anthropic이고 이번 감사 모델은 OpenAI여서 벤더 분리 조건을 충족한다. summary의 audit 모델·Task N 결과 반영은 사용자가 리포트를 검토한 뒤 수행할 후속 기록이다.
- **다음 액션**: `issue-work --response`로 F-20을 검토하고, 승인된 보정만 반영한다.
