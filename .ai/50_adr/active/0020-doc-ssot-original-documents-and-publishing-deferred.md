---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/118
related_jira:
last_harvested: 2026-10-24
---

# ADR: doc 프로파일의 SSoT를 원본 문서로 두고 퍼블리싱을 스킬 범위 밖에 두는 결정

## 결정

- doc 프로파일 repo의 SSoT는 repo 지정 디렉토리(`## 프로젝트 도메인` 표 `ssot_dir`)의 원본 문서다. 위키(컨플루언스 등)를 원본으로 보고 page ID·확인 버전으로 추적하는 안(2026-10-20 초안)은 기각했다. 위키·블로그처럼 SSoT에서 파생해 내보낸 사본은 퍼블리싱이며 SSoT도 출처도 아니다 (#114).
- 퍼블리싱 실행·동기화·위키 직접 수정 대응은 스킬 범위 밖에 둔다. 당분간 프롬프트로 수행하며 경험을 쌓고, 패턴이 확인되면 스킬화를 다시 판단한다. 재검토 조건은 원장 [K-0014](../../70_ledger/active/K-0014-publishing-skill-deferred.md)에 둔다.
- 원본 문서의 범위와 규약을 아래와 같이 정한다 (#118).
  - **SSoT 대상**: `ssot_dir` 아래 `.md` 파일이다. 첨부(이미지·PDF 등)는 색인 행을 따로 두지 않고 그 첨부를 참조하는 `.md` 행에 딸린다. 다른 확장자와 첨부를 무엇으로 볼지는 문서 규약 파일이 정한다.
  - **문서 규약 파일**: doc 템플릿이 `10_rules/document-convention.md`를 배포한다. 칸은 SSoT 대상 확장자(기본 `.md`), 첨부 분류, 근거 출처와 원본 문서 사이 우선순위, 파일·디렉토리 명명이며 확장자 밖의 칸은 기본값 없이 repo가 채운다. 사용자 관리 파일이라 update는 파일이 없을 때만 복사한다.
  - **작성 원칙 위임**: writing-principles를 1.2.0으로 올리고 적용 범위 제외 줄에 "doc 프로파일의 `ssot_dir` 문서는 `document-convention.md`를 따른다"를 더한다. ADR 0008의 배포 구조는 바꾸지 않는다.
- 선언을 읽는 쪽을 아래와 같이 맞춘다 (#118).
  - **로비**: 로비는 SSoT 값을 선언하지 않고 각 repo 안내도의 선언을 따른다. 본문 2번째 줄은 `> SSoT: 각 repo 안내도의 선언을 따른다. 이 파일은 라우터일 뿐 진실의 원천이 아니다.`로 고정한다. 충돌 우선순위는 `각 repo의 SSoT(repo 안내도 선언: 소스 코드 또는 원본 문서) > 각 repo 안내도 > 이 안내도`이며, 안내도가 없는 repo는 선언을 찾지 못한 것으로 보고 소스 코드로 폴백한다.
  - **건물 repo**: code-map `--global`의 건물 repo(`.ai/60_codebase/repository.yaml`이 있는 repo)는 `소스 코드`로 선언한다. SSoT는 등록한 대상 repo의 소스 코드이며 건물 repo 안에는 없다. ai-workspace update는 건물 repo에 doc 표준 문구가 있으면 보고만 하고 자동 전환하지 않는다.
  - **건물 안내도**: `--global`은 대상 repo의 선언을 읽어 `원본 문서` repo를 서비스 간 호출 식별에서 빼고 건물 안내도 리포 목록에 SSoT 종류로 표시한다. 건물 repo에서 `--local`을 실행하면 건물 안내도를 덮어쓰지 않도록 멈추고 `--global`을 안내한다.
  - **리뷰 카테고리**: 선언이 `원본 문서`이면 git-review·issue-audit·git-review-quiz가 doc 카테고리 세트를 쓴다. 이름·순서와 사본 동기화는 ADR 0014가 정한다.
- 선언을 읽는 표준 문장(8곳 복제)은 `AI-CONTEXT.md`는 있는데 선언을 찾지 못해 소스 코드로 진행하면 그 사실을 사용자에게 알리고 `ai-workspace` update로 선언을 보강하도록 안내한다. 안내도가 없는 repo에서는 알리지 않는다 (#122).
- 이슈 spec에서 `보류`로 뺀 항목은 이슈 완료 시 원장 등재 여부를 묻고 승인분만 등재한다. 등재 계기의 상세는 ADR 0018이 정한다 (#118).

## 근거

<details>
<summary>상세 펼치기</summary>

- 위키를 원본으로 두면 문서 변경이 repo의 PR diff에 나타나지 않고, 리뷰와 감사가 원본을 보려면 매번 외부 위키를 조회해야 한다. repo 지정 디렉토리의 문서 파일을 SSoT로 두면 변경이 PR diff로 드러나 리뷰와 감사가 repo 안에서 원본을 본다 (#114 spec 전제 "방향 전환 이력", 2026-10-22 전환).
- 퍼블리싱은 운영 경험이 있어야 무엇을 기록하고 언제 동기화할지 정할 수 있다. 경험 없이 스킬을 먼저 만들면 실제 흐름과 어긋난 절차를 유지하게 된다. 결정을 ADR에 두고 다시 판단할 시점은 원장 항목에 두어, 방향과 재검토 계기를 나눠 기록했다 (이슈 #118 결정 "보류 결정 기록").
- #114의 방향 전환은 ADR 없이 정책 근거 한 줄과 archive spec에만 남아 있었다. 이번 이슈가 같은 방향의 빈 곳(확장자·첨부·규약 파일·로비·건물 repo·리뷰 카테고리)을 채우면서 결정을 한곳에 모았다.
- SSoT 대상 확장자를 정하지 않으면 이미지·PDF가 색인 행이 되는지를 스킬마다 다르게 판단한다. 첨부를 SSoT·출처·파생물 중 무엇으로 볼지는 repo마다 달라, 스킬 표준은 `.md`까지만 정하고 나머지는 repo 규약 파일에 맡겼다 (2026-10-24 결정).
- 로비가 `소스 코드`를 선언하면 `원본 문서` repo를 함께 둔 워크스페이스에서 로비와 repo 안내도의 선언이 어긋난다. 로비는 라우터라 SSoT 값을 갖지 않는다.
- 건물 repo의 문서는 대상 repo의 코드 색인에서 만든 것이라 SSoT는 대상 repo의 소스 코드다. doc 프로파일로 init하면 `원본 문서` 선언이 들어가 실제와 어긋난다. 선언은 허용 값 안에서 정했다. 새 값을 두면 선언을 읽는 문구 8곳(ADR 0002의 의도적 중복)과 `check-context.sh`를 함께 바꿔야 한다.
- 코드 카테고리 7종은 문서 변경에서 성능·테스트에 해당하는 대상이 없고, 내용 정확성·근거 최신성처럼 문서에 필요한 축이 빠져 있다. 개수와 순서를 맞춰 결과 템플릿과 집계 줄 구조를 그대로 쓰게 했다.
- 기존 ADR 0007·0014·0018은 결정은 그대로이고 범위만 넓어졌으므로 본문을 제자리에서 보정했다. ADR 0008은 배포 구조가 그대로라 고치지 않고, 이 ADR이 writing-principles 1.2.0 변경을 기록한다.
- 2026-10-27 일부 변경(#122): 원장 K-0015를 함께 해소하며 결정에 폴백 알림을 더했다. 선언이 깨진 doc repo에서 리뷰·감사·색인이 코드 기준으로 동작해도 알림이 없으면 사용자가 알아채기 어렵다. 안내도가 없는 repo는 선언을 둘 곳이 없어 소스 코드 폴백이 정상 동작이므로 알리지 않는다. 결정 항목은 모두 유효해 ADR index `## 수명 주기`의 일부 변경으로 제자리에서 고쳤다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 위키 원본·page ID 추적(2026-10-20 초안): PR diff와 감사가 원본을 보지 못하고 외부 조회가 필요해 기각. 옛 spec의 `원본 반영` 섹션과 issue-audit 원본 조회 단계도 함께 폐기했다 (#114).
- 퍼블리싱 스킬·퍼블리시 기록·위키 직접 수정 탐지를 이번에 함께 만드는 안: 운영 경험 전이라 보류하고 K-0014로 등재.
- 첨부 분류를 스킬 표준으로 정하는 안: repo마다 다르게 판단해야 해 규약 파일로 대체.
- 건물 repo용 선언 값 신설: 뜻은 정확하지만 선언을 읽는 8곳과 `check-context.sh`를 바꿔야 해 `소스 코드` 선언으로 대체.
- 로비 `Repos` 표에 repo별 SSoT 종류 열 추가: repo 안내도의 선언과 중복돼 어긋날 수 있어 불필요. 에이전트는 repo에 진입할 때 repo 안내도에서 선언을 읽는다.
- doc용 결과 템플릿을 따로 두는 안: 개수·순서를 맞추면 행 이름만 바뀌므로 배제.
- 선언이 깨졌을 때 경고를 더하는 안: #118에서는 선언을 읽는 8곳의 문구를 바꿔야 하는데 발생 확률이 낮아 보류했다. 2026-10-24 등재 질의에서는 등재하지 않았고, 2026-10-25 이슈 완료 시 질의에서 [K-0015](../../70_ledger/active/K-0015-ssot-declaration-silent-fallback.md)로 등재했다. 2026-10-27 #122에서 K-0015를 함께 해소하며 채택해 결정에 넣었다.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #114 doc 프로파일에서 SSoT를 원본 문서(repo 지정 디렉토리)로 선언하고 스킬이 그 선언을 따르게 한다](https://github.com/scroogy-dev/scroogy-agent-skills/issues/114)
- [Issue #118 doc 프로파일 운영 보강: 문서 규약 파일·SSoT 대상 범위·로비와 건물 repo의 SSoT 선언·리뷰 카테고리 doc 세트·보류 항목 원장 등재](https://github.com/scroogy-dev/scroogy-agent-skills/issues/118)
- 일부 변경: [Issue #122 ai-workspace: 테스트 원칙 파일 쌍(testing-principles·local) 도입과 안내도·context-loading 라우팅 연결](https://github.com/scroogy-dev/scroogy-agent-skills/issues/122)
- 방향 전환 이력: [`.ai/90_issues/archive/issue-0114/issue-0114-spec.md`](../../90_issues/archive/issue-0114/issue-0114-spec.md) `## 전제 (Assumptions)`
- 정책: [SSoT 원칙과 안내도 라우터 정책](../../40_domain/policies/local/ssot-and-router-principle.md)
- 관련 결정: [ADR 0002 스킬 독립성과 의도적 중복](./0002-skill-independence-intentional-duplication.md), [ADR 0007 원장 위치와 구조](./0007-tech-debt-ledger-location-and-structure.md), [ADR 0008 작성 원칙 SSoT 배포](./0008-writing-principles-ssot-distribution.md), [ADR 0014 역피라미드와 카테고리](./0014-inverted-pyramid-and-verdict-derivation.md), [ADR 0018 원장 재검토·해소 계기](./0018-ledger-proactive-review-and-resolve-timing.md)
- 원장 항목: [K-0014 퍼블리싱 스킬 범위 밖](../../70_ledger/active/K-0014-publishing-skill-deferred.md)

</details>
