# Issue #39 실행요약 ai-workspace: 산출물 작성 원칙(writing-principles) SSoT 배포 체계 추가

> 스펙: [issue-0039-spec.md](./issue-0039-spec.md) | 계획: [issue-0039-plan.md](./issue-0039-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다.

## 모델 기록

| 구분 | 모델 |
|------|------|
| 계획·구현 모델 | Anthropic, Claude Fable 5 (claude-fable-5) |
| audit 모델 | OpenAI, GPT-5 |

---

## Task별 수행 결과

### Task 1: writing-principles.md SSoT 원본 신설

- **결과**: 완료
- **수행 내용 요약**: `ai-workspace/templates/shared/.ai/10_rules/writing-principles.md` 신설 (33줄). 동기화 헤더·버전(1.0.0) 표기 → 우선순위 선언(템플릿 구조 우선·서술 제약만) → 적용/제외 범위 → 제약 규칙(중요한 것 먼저·리스트형 우선·분량 예산·한글 표현 우선·금지 패턴·What/Why/How 분리·접기) → 구조 기본값(자유 서술 한정 계층형 출력) 순으로 구성. 완료 기준 검증 통과: SYNCED 헤더 1건, '템플릿이 우선' 1건, 버전 표기 1건, 33줄 ≤ 50.
- **특이 사항**: 버전 표기는 커밋 해시 대신 버전 번호(1.0.0) 방식 채택 — 커밋 전에는 해시를 알 수 없어 자기 자신을 가리킬 수 없음. local 우선 규칙 상호 참조 한 줄은 계획대로 Task 2에서 추가 예정 (분량 여유 17줄). 사용자 피드백으로 중요도 태그 체계를 제거하고 배치 규칙(중요한 것 먼저)으로 대체, 리스트형·한글 표현 우선 추가 — 이슈 #39 본문·spec·plan에도 동일 반영.

---

### Task 2: writing-principles-local.md 로컬 확장 템플릿 신설

- **결과**: 완료
- **수행 내용 요약**: `ai-workspace/templates/shared/.ai/10_rules/writing-principles-local.md` 신설 — 상단에 사용자 관리 파일 안내("update는 없을 때만 빈 템플릿 복사·있으면 보존, init 완전 재설치는 예외")와 "충돌 시 local 우선" 규칙 기재, 본문은 `coding-convention.md` 선례를 따라 예시 주석만 담은 빈 템플릿. `writing-principles.md` 우선순위 블록에 local 우선 상호 참조 한 줄 추가(33→34줄, 예산 50줄 이내). 완료 기준 검증 통과: local 템플릿 'local 우선' 1건, 원본 상호 참조 1건, 원본 34줄 ≤ 50.
- **특이 사항**: 사용자 관리 파일이므로 SYNCED 동기화 헤더를 넣지 않음 — 동기화 대상(`writing-principles.md`)과 시각적으로도 구분됨.

---

### Task 3: AI-CONTEXT.md 템플릿(dev·doc) 라우터 한 줄 추가

- **결과**: 완료
- **수행 내용 요약**: dev·doc 두 템플릿의 `## 프로젝트 규칙` 10_rules 표 마지막 행(알파벳순 유지)에 라우터 한 줄 추가 — `.ai/10_rules/writing-principles.md` | 산출물 작성 원칙 (소스 코드 미적용) | 산출 문서·PR·이슈 본문 작성 시. 내용 요약 없이 경로 안내만 기재. 완료 기준 검증 통과: `grep -l 'writing-principles'` 두 파일 모두 매칭.
- **특이 사항**: 없음.

---

### Task 4: SKILL.md init/update 절차 반영

- **결과**: 완료
- **수행 내용 요약**: `ai-workspace/SKILL.md` 3곳 수정. init-1단계에 두 파일 복사 정책 문구 추가(일괄 복사에 포함됨을 명시, update에서 정책이 갈림을 안내). update-1단계 스크립트에 `writing-principles.md` 항상 덮어쓰기(context-loading.md와 동일 정책)와 `writing-principles-local.md` 없을 때만 복사(coding-convention.md와 동일 정책) 추가. 사용자 작성 파일 보존 목록에 `writing-principles-local.md` 추가. 완료 기준 검증 통과: 전체 7건 ≥ 2, update 섹션 5건 ≥ 1.
- **특이 사항**: 멱등 보강은 조건 분기 대신 무조건 덮어쓰기로 구현 — "누락·구버전이면 덮어쓰기"를 항상 덮어쓰기로 단순화해도 결과가 동일(멱등)하며 context-loading.md 선례와 일치. 헤더 버전 표기는 추적용으로 유지.

---

### Task 5: 설치본 동기화·후속 이슈 후보 정리

- **결과**: 완료
- **수행 내용 요약**: `rsync -a --delete`로 `~/.claude/skills/ai-workspace/` 동기화, `diff -rq` 차이 없음 확인. 문서 생산 스킬별 후속 이슈 후보를 아래와 같이 정리 (이슈 등록·링크 기재는 사용자 승인 시에만 수행).
- **후속 이슈 후보 목록** — 공통 변경 요지: ① 실행 절차 1단계에 `writing-principles.md`(+local) 존재 시 적재·적용 명시 ② 원칙 파일 없는 repo용 폴백 인라인 규칙 ③ 제약 규칙에 어긋나는 서술만 손질(템플릿 구조 개편 아님) ④ 산출 직전 자가 검증 체크리스트
  - `git-pr` — PR 본문
  - `git-review` — 리뷰 코멘트
  - `git-review-context` — 리뷰 사전 분석 문서(`99_workspace`)
  - `git-qa` — QA 체크리스트(`99_workspace`)
  - `issue-work` — 이슈 스펙·계획·요약(`90_issues`)
  - `issue-audit` — 감사 리포트(`99_workspace`)
  - `context-save` — 대화 맥락 노트(`99_workspace/notes`)
  - `context-harvest` — 계약·도메인·ADR 문서(`30/40/50`)
  - `code-map` — 코드베이스 색인(`60_codebase`)
  - 제외: `git-commit`(커밋 메시지는 원칙 적용 제외), `readme-sync`(README는 코드베이스 내 문서로 제외), `blog-photo-draft`·`blog-topic-draft`(외부 콘텐츠, `.ai` 산출 문서 아님), `ai-workspace`·`ai-workspace-directory`·`install-skills`(산출물이 안내도·설치 동작)
- **특이 사항**: 동기화는 `install-skills` 전체 실행 대신 동등 절차(rsync)로 Claude 경로만 수행 — 완료 기준이 `~/.claude/skills/` 일치만 요구하며, 타 도구 경로 배포는 사용자가 `install-skills`로 일괄 수행 가능.

---

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

- **결과**: 완료 — audit 3회 수행(사용자, OpenAI GPT-5)·발견사항 보정 반영·3차에서 보정 확인, 사용자 확인으로 완료 처리(--clear)
- **수행 내용 요약 (1차)**: 사용자가 GPT-5로 issue-audit 수행, 리포트 [issue-0039-audit-report.md](./issue-0039-audit-report.md) 접수 (작성 시점 경로는 `.ai/99_workspace/issue-0039-audit-report.md`, --clear로 이관) (PASS 13 / PARTIAL 3 / FAIL 0, 발견사항 2건). `--response` 게이트로 검토 후 항목별 승인 처리:
  - F-1 (MEDIUM, init이 사용자 local 파일 덮어씀) → **반영 (B안: 문구 정합화)**. init 전체 초기화는 기존 계약(카테고리 선례 coding-convention.md와 동일)으로 유지하고 과잉 약속 문구만 정정 — local 템플릿에 "update 기준 보존, init은 예외" 명시, SKILL.md init-1에 init 전체 덮어쓰기 한 줄 보강, spec In 항목 2곳에 update 기준임을 명시. 보정 후 `[D]` 검증 전체 재실행 통과, 설치본 재동기화 diff 차이 없음.
  - F-2 (LOW, 문자열 개수 검증의 의미 미검사) → **보류**. [D]는 설계상 문자열 게이트이고 의미 검증은 [QD] audit 층 담당(실제로 F-1을 탐지해 의도대로 작동). F-1을 B안으로 확정해 init의 local 보존 시나리오가 스펙에서 사라져 권장 검증의 대상이 소멸.
- **수행 내용 요약 (2차 재감사)**: 1차 보정 후 사용자가 GPT-5로 재감사 수행, 동일 경로 리포트 접수 (PASS 15 / PARTIAL 1 / FAIL 0, 신규 발견 3건 — 1차 F-1은 RESOLVED, 1차 F-2는 DEFERRED로 재확인). `--response` 게이트로 항목별 승인 처리:
  - F-1 (MEDIUM, `.ai/`만 있고 `10_rules/`가 없으면 update 첫 `cp`에서 중단) → **반영**. update-1 복사 블록 앞에 `mkdir -p .ai/10_rules` 한 줄 추가 — 이슈 이전부터 있던 기존 스크립트의 잠재 결함이나, 스펙 요구 "누락이면 보강"이 본 이슈 범위라 여기서 정정. `.ai/`만 있는 임시 workspace 재현으로 1회차 성공·2회 멱등·local 사용자 내용 보존 확인, 설치본 재동기화 diff 차이 없음.
  - F-2 (LOW, 1차 보정 정책이 plan·summary에 미전파) → **반영**. plan Task 4의 init 문구와 summary Task 2의 local 템플릿 인용을 최종 정책("없을 때만 복사"는 update 기준, init은 전체 초기화 계약)으로 정정.
  - F-3 (LOW, 문자열 게이트의 의미 미검사 — 1차 F-2와 동일 지적) → **보류 유지**. 1차 보류 사유([D]는 설계상 문자열 게이트, 의미 검증은 [QD] audit 층 담당)를 유지하며 잔여 위험으로 재확인 — 감사인도 보류 시 잔여 위험 명시를 대안으로 인정.
- **수행 내용 요약 (3차 재감사)**: 2차 보정 후 사용자가 GPT-5로 확인 감사 수행 (PASS 16 / FAIL 0 / PARTIAL 0, 신규 결함 없음). 2차 F-1·F-2는 RESOLVED로 재검증, 잔여 LOW 1건(문자열 게이트 의미 공백)은 보류 유지 — 종합 의견 "Task N 완료 판단 가능". 리포트는 [issue-0039-audit-report.md](./issue-0039-audit-report.md)로 이관 보존 (차수마다 동일 경로에 덮어쓰여 최종 3차 내용만 보존).
- **특이 사항**: 위험도 재평가 — 1차 F-1은 MEDIUM 유지하되 결함 소재를 "init 동작"이 아닌 "local 템플릿의 무조건 문구(과잉 약속)"로 재규정, 2차 F-1은 MEDIUM 유지하되 본 이슈가 만든 결함이 아닌 기존 잠재 결함으로 재규정. audit 모델 기록은 리포트 기재값을 옮겨 적음. Task N 체크박스는 사용자 확인 후 체크.
