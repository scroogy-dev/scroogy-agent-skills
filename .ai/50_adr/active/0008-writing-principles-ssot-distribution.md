---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/39
related_jira:
last_harvested: 2026-09-09
---

# ADR: 산출물 작성 원칙의 SSoT 배포와 참조 연결

## 결정

- 산출물 작성 원칙의 단일 원본은 `ai-workspace/templates/shared/.ai/10_rules/writing-principles.md`다. `context-loading.md`와 같이 버전 고정 파일로 두고 update 시 항상 최신본으로 덮어쓴다. 상단에 SYNCED 헤더와 버전 주석을 둔다.
- 원칙의 역할은 서술 방식 제한이다. 스킬 템플릿이 산출물 구조(섹션·순서)를 정의하면 템플릿이 우선한다.
- repo 고유 확장은 `writing-principles-local.md`에 둔다. 사용자 관리 파일이며 없을 때만 빈 템플릿을 복사하고, 충돌 시 local이 우선한다.
- 참조 경로 두 곳을 잇는다. `context-loading.md`에 "산출 문서·PR·이슈·리뷰 코멘트 작성 시" 라우팅 섹션, AI-CONTEXT `## 프로젝트 규칙` 표에 라우터 한 줄(update 멱등 보강 검사로 기존 repo에 전파).
- 산출물 스킬 8종(git-pr, git-qa, issue-work, issue-audit, git-review, git-review-context, context-save, context-harvest)은 SKILL.md에 접기 기준 블록을 내장하고, `writing-principles.md`·local을 조건부 직접 참조한다. 우선순위는 local > writing-principles.md > 내장 기준.
- 템플릿의 상세 섹션은 `<details>`로 감싼다. 결정사항·리스크·액션 아이템은 접지 않는다. issue-work 템플릿 4종은 결정·검증 앵커 중심 문서라 접기를 적용하지 않는다.
- 원칙에 `## 한국어 작성 규칙` 섹션(규범·문장·표현·용어·일관성 5분류)을 두고, 번역투 금지 패턴 6종(부정 대조, em dash, 수사적 콜론, 3항 병렬, 하이픈 합성, 은유 직역)을 대체 표현과 쌍으로 적는다. 리스트 항목의 "라벨: 설명" 형식 전반은 콜론 금지에서 제외한다.
- repo 상주 문서(SKILL.md·templates·references·`.ai/`·README)는 원칙 적용 범위 밖이지만 본보기가 되므로 일회성으로 정비했다(#87). 정당한 사용(리스트 라벨 구분자, 표 셀, 접기 제목 기본형, HTML 주석, 코드 펜스)은 예외 목록에 기록한다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 문서 생산 스킬의 산출물이 장황해 핵심 파악 부담이 컸다. 원칙을 스킬마다 개별 기술하면 중복·드리프트가 생긴다 (#39).
- 원칙이 별도 구조를 강제하면 스킬 템플릿과 충돌해 모델·세션에 따라 산출물 구조가 재배열된다. 구조 정의를 배제하고 서술 제한으로 한정했다.
- 파일만 배포되고 에이전트가 안내받는 경로가 끊겨 있었다. 스킬 독립성 규칙상 스킬은 `context-loading.md`만 참조하는데 그 파일에 라우팅이 없었고, update는 AI-CONTEXT 본문을 사용자 작성분으로 보존해 규칙 표 행이 전파되지 않았다 (#41).
- 규칙을 참조하는 산출물 스킬이 0개였다. SKILL.md → context-loading → writing-principles의 2단계 간접 참조가 실행 시점에 단절되고, 가까운 구체 지시(출력 형식)가 먼 추상 원칙을 이기며, `.ai/`가 없는 repo에서는 사슬 원천이 끊긴다 (#60).
- 내장 블록은 접기 규칙 하나의 스냅샷이라 분량 예산 등 나머지 원칙과 local 확장은 참조 없이 발동하지 않는다. 버전 표류를 막기 위해 우선순위 문구를 내장 블록에 함께 명시했다.
- 추상 선언("번역투를 피한다")만으로는 효과가 약하다. "박다" 금지 규칙에서 구체 패턴과 대체 표현 쌍 방식이 검증됐다. 규칙 파일 자체가 em dash 5회를 쓰고 있어 예시가 규칙을 이기는 상태였다 (#86).
- 스킬 문서 자체가 번역투면 템플릿과 SKILL.md가 산출물 문체의 본보기가 되어 규칙만 추가하면 예시가 규칙을 이긴다 (#87).
- PR #88 리뷰로 콜론 예외를 "라벨: 설명" 형식 전반으로 넓히고 버전을 1.1.1로 올렸다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 원칙이 산출물 구조까지 정의: 템플릿 충돌·재배열 드리프트로 기각.
- 참조 전용 방식(내장 없이 파일만 참조): 파일 부재 환경에서 미발동, 스킬 독립성 훼손으로 기각.
- 중요도 태그 체계: 도입하지 않고 배치("중요한 것 먼저")로 표현한다.
- 규칙 적용 범위를 SKILL.md 등 코드베이스 내 문서까지 확장: 범위는 바꾸지 않고 일회성 정비로 처리했다.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #39 writing-principles SSoT 배포 체계 추가](https://github.com/scroogy-dev/scroogy-agent-skills/issues/39)
- [Issue #41 writing-principles 참조 경로 보강](https://github.com/scroogy-dev/scroogy-agent-skills/issues/41)
- [Issue #60 접기 적용 지점 명시 및 writing-principles 참조 연결](https://github.com/scroogy-dev/scroogy-agent-skills/issues/60)
- [Issue #86 번역투 금지 패턴 추가](https://github.com/scroogy-dev/scroogy-agent-skills/issues/86)
- [Issue #87 전체 스킬 번역투 문체 일괄 정비](https://github.com/scroogy-dev/scroogy-agent-skills/issues/87)
- [PR #40 리뷰 코멘트](https://github.com/scroogy-dev/scroogy-agent-skills/pull/40), [PR #88 리뷰 코멘트](https://github.com/scroogy-dev/scroogy-agent-skills/pull/88)
- 규칙 본문: [`.ai/10_rules/writing-principles.md`](../../10_rules/writing-principles.md)

</details>
