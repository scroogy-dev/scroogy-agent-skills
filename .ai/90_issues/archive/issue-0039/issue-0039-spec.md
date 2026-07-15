# Issue #39 스펙 ai-workspace: 산출물 작성 원칙(writing-principles) SSoT 배포 체계 추가

> GitHub: [#39](https://github.com/scroogy-dev/scroogy-agent-skills/issues/39)

## 목표 (Goal)

산출물 작성 원칙을 단일 원본 `ai-workspace/templates/shared/.ai/10_rules/writing-principles.md`로 신설하고, ai-workspace의 init/update 배포 메커니즘으로 각 repo `.ai/10_rules/`에 동기화되게 한다. 원칙은 스킬 템플릿이 정의한 산출물 구조(섹션·순서)를 바꾸지 않으며 그 구조 안의 서술 방식(분량·중복·접기·태그)만 제한한다 — 분량은 줄이되 정보는 보존한다.

---

## 범위 (Scope)

**포함 (In)**

- `ai-workspace/templates/shared/.ai/10_rules/writing-principles.md` 신설 (SSoT 원본)
  - 상단 동기화 헤더: `<!-- SYNCED by ai-workspace — 원본: ai-workspace/templates/shared/.ai/10_rules/writing-principles.md, DO NOT EDIT -->` + 버전 표기
  - 최상단 우선순위 선언: 스킬 템플릿이 산출물 구조(섹션·순서)를 정의하면 템플릿이 우선하며, 이 원칙은 그 구조 안의 서술 방식만 제한
  - 적용/제외 범위 선언 (적용: AI 생성 산출 문서·PR 본문·이슈 본문·리뷰 코멘트 / 제외: 소스·테스트 코드, 설정, 코드 주석, README 등 코드베이스 내 문서, 커밋 메시지)
  - 제약 규칙 — 모든 산출물에 적용, 템플릿 구조와 직교: 중요한 것 먼저(중요도 태그 체계 없이 배치로 표현), 리스트형 우선, 분량 예산 기본값, 한글 표현 우선(코드 식별자·도구명·정착 기술 용어는 예외), 금지 패턴, What/Why/How 분리(결정은 본문·근거는 접기·방법은 문서 목적별 배치), 접기(`<details>`) 가능/금지 규칙
  - 구조 기본값 — 스킬 템플릿이 구조를 정의하지 않는 자유 서술 산출물에만 적용: 계층형 출력(요약 → 핵심 → 상세 → 부록)
  - 분량: 한 페이지(30~50줄) 이내
- `writing-principles-local.md` 로컬 확장 템플릿 신설 — 사용자 관리 파일, "없을 때만 빈 템플릿 복사" 정책은 update 기준(`coding-convention.md`와 동일 카테고리 — init 완전 재설치는 기존 계약대로 전체 초기화에 포함), 두 파일 충돌 시 local 우선 규칙 명시
- AI-CONTEXT.md 템플릿(dev·doc)에 라우터 한 줄 추가 (내용 요약 없이 경로 안내만)
- `ai-workspace/SKILL.md` 절차 반영
  - init 파일 복사 절차에 두 파일 추가 (writing-principles.md는 버전 고정·항상 최신 덮어쓰기, local의 "없을 때만 복사"는 update 기준 — init은 전체 초기화 계약을 따름)
  - update 모드에 멱등 보강 검사 추가 (존재·최신 여부 확인, 누락·구버전이면 덮어쓰기, local은 보존)
- 설치본(`~/.claude/skills/ai-workspace/`) 동기화

**비포함 (Out)**

- 각 문서 생산 스킬(git-review, git-pr, issue-work 등)의 변경 — 스킬별 개별 이슈로 분리 (본 이슈의 SSoT 신설·배포가 선행 조건). 후속 이슈에서도 스킬 템플릿의 구조(섹션·순서)는 개편하지 않으며 제약 규칙에 어긋나는 서술만 손질한다. 후속 이슈 생성·링크 등록은 이슈 마무리 단계에서 사용자 승인 후 수행
- 이 repo 자체 `.ai/10_rules/`에의 실제 배포 적용 — 이슈 범위에 명시되지 않음, 필요 시 `ai-workspace` update 실행으로 언제든 반영 가능

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [ ] [D]  SSoT 원본이 존재하고 동기화 헤더·버전 표기를 포함한다  (검증: `grep -c 'SYNCED by ai-workspace' ai-workspace/templates/shared/.ai/10_rules/writing-principles.md` ≥ 1, `grep -cE '버전|version' 동일 파일` ≥ 1)
- [ ] [D]  원칙 파일 최상단에 우선순위 선언(템플릿 구조 우선·서술 제약만)이 있다  (검증: `grep -c '템플릿이 우선' ai-workspace/templates/shared/.ai/10_rules/writing-principles.md` ≥ 1)
- [ ] [D]  원칙 파일 분량이 한 페이지 이내다  (검증: `wc -l < ai-workspace/templates/shared/.ai/10_rules/writing-principles.md` ≤ 50)
- [ ] [D]  로컬 확장 템플릿이 존재하고 local 우선 규칙이 명시되어 있다  (검증: `grep -c 'local 우선' ai-workspace/templates/shared/.ai/10_rules/writing-principles-local.md` ≥ 1 — 파일 부재 시 grep 자체가 실패)
- [ ] [D]  SKILL.md init 복사 절차에 두 파일이 반영되어 있다  (검증: `grep -c 'writing-principles' ai-workspace/SKILL.md` ≥ 2 — init·update 양쪽 언급 포함)
- [ ] [D]  SKILL.md update 모드에 writing-principles 멱등 보강 검사가 있다  (검증: update 모드 섹션 범위에서 `writing-principles` 매칭 ≥ 1, 예: `sed -n '/^## update 모드/,$p' ai-workspace/SKILL.md | grep -c 'writing-principles'`)
- [ ] [D]  AI-CONTEXT.md 템플릿(dev·doc)에 라우터 한 줄이 포함된다  (검증: `grep -l 'writing-principles' ai-workspace/templates/dev/.ai/AI-CONTEXT.md ai-workspace/templates/doc/.ai/AI-CONTEXT.md` 두 파일 모두 매칭)
- [ ] [D]  설치본이 repo와 동기화되어 있다  (검증: `diff -rq ai-workspace ~/.claude/skills/ai-workspace` 차이 없음)
- [ ] [QD] init 시 생성·update 시 구버전 갱신·local 사용자 내용 보존 시나리오가 절차상 성립하고, 원칙 본문이 이슈 요구 요소(우선순위 선언, 적용/제외 선언, 제약 규칙과 구조 기본값의 구분, 중요한 것 먼저 배치, 리스트형 우선, 분량 예산, 한글 표현 우선, 금지 패턴, What/Why/How 분리, 접기 규칙, 자유 서술 한정 계층형 출력)를 모두 커버한다  (검증: 교차모델 audit가 채점)  ← 강등 사유: AI 수행 절차의 실행 결과와 본문의 의미 커버리지는 명령으로 판정 불가

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/10_rules/context-loading.md` | 동기화 정책의 선례 — "버전 고정, update 시 항상 최신본 덮어쓰기"와 동일 정책을 적용할 준거 |
| `ai-workspace/templates/dev/.ai/10_rules/coding-convention.md` | "없을 때만 빈 템플릿 복사" 카테고리의 선례 — `writing-principles-local.md`가 따를 정책 원형 |
