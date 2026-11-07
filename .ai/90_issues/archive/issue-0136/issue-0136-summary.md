# Issue #136 실행요약 ai-workspace: IDE 도구 우선 규칙(ide-tools.md)을 dev 프로파일에 도입하고 init·update에서 안내도 규칙 표·context-loading에 연결한다

> 스펙: [issue-0136-spec.md](./issue-0136-spec.md) | 계획: [issue-0136-plan.md](./issue-0136-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다.

## 모델 기록

| 구분 | 모델 | effort |
|------|------|--------|
| 계획 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | xhigh |
| 계획 audit 모델 | OpenAI, GPT-6.1 (gpt-6.1-sol) | high |
| 구현 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | xhigh |
| 최종 audit 모델 | OpenAI, GPT-6.1 (gpt-6.1-sol) | high |

- **계획 감사**: 수행 · 발견 1건 · 보정 1건

- **이슈 본문 갱신**: 갱신 · AC11, AC12, AC13

---

## Task별 수행 결과

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: 미결 2건과 규칙 표 설명 셀 문구를 사용자에게 질의해 spec `## 전제`의 `Task 0 답변`에 반영했다. 서버 등록 이름은 적지 않고 도구 이름으로만 안내하고, 수정 후 검증 기본값은 `lint_files`이며 `build_project`는 선언 변경 뒤에만 쓴다. 설명 셀은 상세형 문구로 정했다. `context-loading.md` 목록 위치(2번)와 규칙 표 행 위치(알파벳 순서)는 관례대로 정해 같은 섹션에 적었다.
- **특이 사항**: 서버 이름 질의 중 사용자 요청으로 Codex 동작을 확인했다. `codex-cli 0.167.0` 설정과 실행 기록 기준으로 도구 전체 이름은 Claude Code와 같은 `mcp__idea__<도구>` 형식이다. IntelliJ 도구는 `exec` 도구 안의 지연 도구라 `ALL_TOOLS`를 도구 이름으로 걸러 찾는다. spec R2 `[D]` 설계 주의의 `build_project` 제외 근거를 미결 질의에서 Task 0 답변(조건부 도구)으로 고쳤다(판정 기준 무변경).

---

### Task 1: 규칙 파일 작성과 dev 배포

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `templates/dev/.ai/10_rules/ide-tools.md`(버전 1.0.0)를 만들고 이 저장소 `.ai/10_rules/`에 같은 사본을 두었다. 작업별 우선 도구는 6종을 표로 두고, `build_project`는 선언 변경 뒤에만 쓰는 조건부 도구로 표 아래에 적었다. 호출 방법에는 서버 등록 이름 없이 도구 이름으로 찾는 방법(Claude Code 도구 검색, Codex `ALL_TOOLS` 필터)과 `projectPath` 전달을 적었다. spec R1·R2 `[D]` 4개, 사본 `cmp`, `run-tests.sh`(178 통과·0 실패)가 모두 통과했다.
- **특이 사항**: 도구 사용법(`include_external`, `INCOMING_CALLS`/`OUTGOING_CALLS`, `preview`, `applied`)은 이 세션에서 불러온 IntelliJ MCP 도구 스키마에 맞춰 적었다. 이 저장소 안내도 규칙 표에는 아직 행이 없으며 Task 2에서 넣는다.

---

### Task 2: 안내도 규칙 표 행과 context-loading 라우팅

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: dev AI-CONTEXT 템플릿과 이 저장소 안내도 규칙 표에 `ide-tools.md` 행을 `file-change-policy.md` 다음에 넣었다(설명 셀은 spec 전제 문구, 사용 시점 `코드 탐색·수정 전`). `context-loading.md` 템플릿 코드 절 2번에 항목을 넣고 뒤 번호를 하나씩 미룬 뒤 이 저장소 사본을 맞췄다. 러너 `ctx_violations`에 `IDE 도구 라우팅` 검사를 더하고 통과 1개(기존 통과 케이스 설명 확장), 격추 3개(항목 삭제·다른 절로 이동·다른 절에 중복)를 넣었다. spec R3 2개·R4 1개·R9 2개 `[D]`와 러너(181 통과·0 실패)가 모두 통과했다.
- **특이 사항**: 격추 케이스는 plan의 2개(삭제·이동)에 파일 전체 1곳 조건을 보는 중복 케이스 1개를 더했다. 이 저장소 안내도 `last updated`는 바꾸지 않았다(직전 안내도 커밋도 날짜를 바꾸지 않은 관례를 따름).

---

### Task 3: update-1 복사

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `SKILL.md` update-1 dev 분기에 `ide-tools.md` 덮어쓰기 복사 줄을 넣고 분기 주석을 고쳤다. init-1의 `dev` 전용 파일 목록, 일괄 복사 안내 문장, 복사 정책 목록에 `ide-tools.md`를 더했다. 러너에 `ide_update1_violations`를 더하고 통과 1개, 격추 3개(복사 줄 삭제·덮어쓰기 조건 추가·doc 분기 복사 추가)를 넣었다. spec R5 `[D]` 2개와 러너(185 통과·0 실패)가 모두 통과했다.
- **특이 사항**: 격추 케이스는 plan의 2개에 doc 분기 복사 추가 케이스 1개를 더했다(doc 미복사 조건 회귀 방지).

---

### Task 4: update-4 행 검사

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `check-context.sh`가 dev 선언일 때 `ide-tools.md` 행도 검사하게 하고 머리말(`검사 표 14행 중 12행`)과 주석을 맞췄다. `SKILL.md` 멱등 보강 검사 표에 `ide-tools.md` 행 항목을 `testing-principles.md` 행 다음에 넣고, 항목 수 표기(`14개 항목 중 12개`)와 "아래 네 행 검사" 2곳을 고쳤다. SSoT 선언 행·건물 repo 선언 행 조치에 `ide-tools.md` 행 보강을 더했다(R12, 계획 감사 F-1). 러너에 `ide-tools 행` 케이스 4개(격추 2·통과 2)를 넣고 항목 수 기대값을 14로 바꿨다. fixture 기대 파일 4종과 README를 맞췄다. spec R6 4개·R12 1개 `[D]`와 러너(189 통과·0 실패)가 모두 통과했다.
- **특이 사항**: `no-rules-section`·`no-rules-table` 기대 파일은 dev 템플릿 골격을 그대로 넣는 조치라 `ide-tools.md` 행을 템플릿 위치(`file-change-policy.md` 다음)에 두었다. `missing-rows`·`legacy-two-col`은 표 끝 삽입 조치라 마지막 행으로 두었다. 헬퍼·러너 주석의 "세 번 보고" 표기는 행 수가 늘어 "검사하는 행 수만큼"으로 고쳤다.

---

### Task 5: 프로파일이 어긋난 복구의 dev 행 보강 (K-0018)

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `SKILL.md` 멱등 보강 검사 표의 `## 프로젝트 규칙` 섹션·표 행 조치에, 섹션 부재·표 부재로 복구했고 본문 두 번째 줄이 dev 표준 문구이면 `testing-principles.md`·`ide-tools.md` 행 가운데 없는 행을 표 끝에 넣는다는 문장을 더했다. fixture `no-rules-section-mismatch`·`no-rules-table-mismatch`(dev 선언, `profile` 행 `doc`)를 만들고 기대 파일은 doc 템플릿 골격 뒤에 두 dev 행을 넣은 결과로 두었다. README 케이스 표와 러너 `assert_fixture` 상태 판정 2개를 더했다. spec R11 `[D]` 2개와 러너(191 통과·0 실패)가 모두 통과했다.
- **특이 사항**: 두 기대 파일을 `check-context.sh`로 다시 검사해 `## 프로젝트 규칙` 관련 보고가 0건인 것을 확인했다(2회 실행 수렴). 입력의 `profile` 행을 `doc`으로 두어 표준 구간 최신화가 이 fixture 범위 밖에서 값을 바꾸지 않게 했다. K-0018 원장 종결은 이슈 완료 시 원장 해소 기재가 맡는다(spec 전제).

---

### Task 6: 명세 동기화와 결정 기록

- **결과**: 완료
- **수행 모델**: Anthropic, Claude Opus 5.5 (claude-opus-5-5)
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `specs/ai-workspace.md` `## 요건`의 세 줄(파일 단위 최신본 목록, `context-loading.md` 요건, 멱등 보강 검사 요건 `12종`)에 `ide-tools.md`와 규칙 섹션·표 복구 실행의 보강을 반영하고 `## 관련 결정`에 ADR 0029, 출처에 #136을 더했다. ADR 0029(`0029-ide-tools-rule-dev-profile-distribution.md`)를 결정·근거·대안·출처 형식으로 쓰고 `50_adr/index.md`에 등재했다. spec R8·R10 `[D]`, repo 전체 스킬 테스트(13개 러너), 끊긴 원장 링크 검사(0건)가 모두 통과했다.
- **특이 사항**: ADR 0023은 결정이 바뀌지 않아 그대로 두고 0029에서 관계를 적었다(수명 주기 "새 결정이 기존 결정을 바꾸지 않음"). ADR 0029는 K-0018을 `active/` 경로로 가리키므로, 이슈 완료 시 원장 해소 기재로 K-0018을 `archive/`로 옮기면 이 링크도 함께 고친다. 전체 테스트는 600초를 넘겨 백그라운드로 끝까지 실행했다.

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

- **결과**: 완료
- **수행 내용 요약**: 사용자가 OpenAI GPT-6.1(`gpt-6.1-sol`, effort high)로 `issue-audit`를 1회 실행했다(HEAD `58143bf`, 미커밋 구현 파일 포함). 결과는 적합(PASS)이다. 충족(PASS) 40건(요구사항 12, 완료의 정의 28), 미충족(FAIL)·부분 충족(PARTIAL) 0건, 신규 발견 0건이다. spec `[D]` 22개와 13개 러너 전체가 통과했다.
- **특이 사항**:
  - 신규 발견이 없어 Task 0~6의 `audit 발견`·`보정 반영`은 0건 그대로다.
  - 기등재 K-0018은 R11 구현으로 원인이 사라졌다고 판정됐다. PR이 아직 없어 해소를 확정하지 않고 git-pr 4단계 "원장 해소 기재"로 넘긴다. 옮길 때 ADR 0029와 `60_codebase/ai-workspace/update-call-flow.md`의 K-0018 링크도 고친다.
  - 리포트의 코드 색인 갱신 의견(`init-call-flow.md` dev 배포 목록, `update-call-flow.md` 검사 수 11종 표기)은 `--response` 검토에서 PR 문서 동기화 점검의 `/code-map` 질의로 넘기기로 정했다.
  - 이 블록과 `최종 audit 모델` 행, plan Task N 체크박스는 사용자 지시(2026-11-07)로 구현 AI가 최종 감사 리포트(`issue-0136-audit-report.md`)의 머리말·요약을 옮겨 적었다.
