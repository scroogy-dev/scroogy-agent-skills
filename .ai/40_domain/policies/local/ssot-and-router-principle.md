---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/1
last_harvested: 2026-09-09
---

# SSoT 원칙과 안내도 라우터 정책

## 원칙

- SSoT(Single Source of Truth, 단일 진실 원천)는 repo 안내도의 SSoT 선언이 정한다. 선언은 본문 2번째 줄(H1 제목과 그 뒤 빈 줄 제외)의 `> SSoT: <값>.` 행이며, dev 프로파일은 소스 코드, doc 프로파일은 원본 문서(`## 프로젝트 도메인` 표 `ssot_dir` 아래 `.md` 파일)다. 다른 확장자와 첨부(이미지·PDF 등)의 분류는 repo 문서 규약 파일(`10_rules/document-convention.md`)이 정한다. 선언을 찾지 못하면 소스 코드를 SSoT로 본다. 안내도 마크다운은 SSoT를 가리키는 지도이지 SSoT의 사본이 아니다.
- 퍼블리싱은 SSoT에서 파생해 밖으로 내보낸 사본(위키·블로그·PDF 등 형태 불문)이며 SSoT도 출처도 아니다. 위치는 `## 프로젝트 도메인` 표 `publish` 행으로 선언할 수 있다.
- 출처는 SSoT에서 파생되지 않은 외부 자료이며 `40_domain/`·`50_adr/`가 근거로 인용한다. 퍼블리싱과 출처는 매체로 가르지 않고 SSoT에서 파생했는지로 가른다.
- 정보 충돌 시 우선순위는 SSoT(소스 코드 또는 원본 문서) > repo 안내도(`.ai/AI-CONTEXT.md`) > 상위 워크스페이스 로비 안내도다. 근거 출처와 원본 문서 사이 같은 세부 우선순위는 repo 문서 규약 파일(`10_rules/document-convention.md`)이 정하며 스킬 표준에 넣지 않는다.
- 로비 안내도는 라우터다. 도메인 지식 본문, 코드 스니펫·API 명세 복제, 자주 바뀌는 운영 정보, repo의 상세 목차를 두지 않는다. 분량 가드레일은 150~250줄이다.
- repo 안내도는 `## 프로젝트 도메인`(domain/keywords)과 `## 에이전트 운영 지침`을 두고, SSoT 진입은 `.ai/` 라우터(`60_codebase/index.md` 포인터)를 경유한다. `60_codebase/`는 SSoT 색인이며, dev는 소스 코드 엔트리포인트·호출 흐름, doc은 `ssot_dir` 아래 문서 파일 지도다. `## 디렉토리 구조`는 코드 트리 개관이다.
- 멀티/단독 repo 여부는 런타임에 `../.ai/AI-CONTEXT.md` 존재로 자동 판정한다(CoC, Convention over Configuration, 컨벤션 우선). 판정 결과는 보고에만 노출하고 git 추적 파일에 기재하지 않는다. 역참조 메타 필드(`building`/`lobby`)는 두지 않는다.
- 로비 `Repos` 행의 domain/keywords와 repo 안내도 `## 프로젝트 도메인` 표는 1:1 동기화 대상이다.
- 산출물 어휘는 `Repos`/`repo`다. SKILL.md 내부 메타포 `building`/`floor`는 유지한다.
- 수집·색인 스킬(context-harvest, code-map)의 산출물은 선언이 가리키는 SSoT에 반영된 사실의 계약·근거만 담고, 퍼블리싱 사본은 수집하지 않으며, 외부 URL은 원본 출처 섹션에만 둔다.

<details>
<summary>근거 펼치기</summary>

- 로비에 도메인 본문이 적히면 층과 SSoT 충돌이 생기고, 코드 스니펫이 복제되면 드리프트가 생기며, 운영 정보가 섞이면 리뷰 부담이 커지고, 상세 목차까지 알면 결합도가 커지며, 분량이 비대해지면 세션 시작 토큰이 낭비된다 (#1).
- 상위 `../.ai/AI-CONTEXT.md`는 git 비추적 로컬 파일이라 사용자마다 부모 디렉토리 구조가 다르다. 한 사람의 "단독 repo다" 기록이 다른 클론에서는 거짓이 된다. 같은 문서가 "자동 판정"을 선언하면서 판정 결과까지 적는 것은 자기모순이다 (#5).
- 로비 → repo 안내도 → 코드·문서 탐색 흐름이 명시되어야 어느 AI 도구로 진입해도 안내판을 보고 찾아 답할 수 있다 (#3).
- 수집 스킬이 기각된 제안·미구현 요청까지 담으면 SSoT와 대응하지 않는 정보가 `.ai/`에 남는다.
- 스킬마다 "SSoT = 소스 코드"로 고정한 문구는 문서가 산출물인 doc repo에서 작동하지 않는다. 위키를 SSoT로 두면 PR diff와 감사가 원본을 보지 못하므로, repo 안 지정 디렉토리의 문서 파일을 SSoT로 정하고 위키·블로그는 퍼블리싱으로 정의했다. 선언을 안내도 한 곳에 두고 스킬이 따르게 했다 (#114).
- SSoT 대상 확장자를 정하지 않으면 이미지·PDF가 색인 행이 되는지 스킬마다 다르게 판단한다. 스킬 표준은 `.md`까지만 정하고, 첨부를 SSoT·출처·파생물 중 무엇으로 볼지는 repo마다 다르므로 doc 프로파일이 배포하는 문서 규약 파일에 맡겼다 (#118).

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #1 로비 안내도를 SSoT 원칙에 맞게 생성하는 스킬 추가](https://github.com/scroogy-dev/scroogy-agent-skills/issues/1)
- [Issue #3 에이전트 서치를 위한 스킬 보강](https://github.com/scroogy-dev/scroogy-agent-skills/issues/3)
- [Issue #5 AI-CONTEXT.md에서 로컬 환경 기반 정적 판정 결과 제거](https://github.com/scroogy-dev/scroogy-agent-skills/issues/5)
- [Issue #114 doc 프로파일에서 SSoT를 원본 문서(repo 지정 디렉토리)로 선언하고 스킬이 그 선언을 따르게 한다](https://github.com/scroogy-dev/scroogy-agent-skills/issues/114)
- [Issue #118 doc 프로파일 운영 보강: 문서 규약 파일·SSoT 대상 범위·로비와 건물 repo의 SSoT 선언·리뷰 카테고리 doc 세트·보류 항목 원장 등재](https://github.com/scroogy-dev/scroogy-agent-skills/issues/118)

</details>
