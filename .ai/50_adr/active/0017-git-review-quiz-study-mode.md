---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/92
related_jira:
last_harvested: 2026-09-09
---

# ADR: git-review-quiz 스터디 모드 스킬 설계

## 결정

- PR(또는 현재 브랜치 변경)에서 비즈니스·테크 관점 문항을 만드는 별도 스킬 `git-review-quiz`를 둔다. 대화형(기본)과 PR 댓글(`--comment`) 두 방식, `--mcq`/`--open`, `--business`/`--tech` 옵션.
- 문항 구성 순서는 변경 위치(접지 않음) → 문제 → 힌트(접기) → 정답·해설(접기)이다. 위치 행은 경로와 줄 범위를 백틱으로 감싸며 `--comment`에서는 head 커밋 permalink를 병기한다.
- 근거 규칙: 모든 문항은 diff 안의 변경 위치를 하나 이상 가리킨다. 비즈니스 문항은 `.ai/30_contract/`·`40_domain/` 문서를 근거로 만들고, 문서가 없으면 테크 문항만 내고 알린다. 일반 지식 문항은 내지 않는다.
- 정답·해설은 실제 동작으로 확인한다. 소스 주석만으로 정하지 않는다.
- 문항 본문에 코드 블록을 두지 않는다.
- PR 댓글은 일반 댓글 하나로 게시하며 승인 게이트·`--repo`·`--hostname` 명시 규칙은 git-pr-feedback을 따른다.
- 형식 검사 `check-quiz.sh`는 일반 모드와 `--comment` 모드로 나뉜다. git-review와 독립이며 서로 호출하지 않는다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 리뷰의 가장 큰 난관이 변경 이해라는 점은 관찰 연구(Code Review Comprehension, ICPC 2025)에서 확인된다. 스터디 모드처럼 질문으로 이해를 끌어낸다.
- 기존 도구(pr-quiz, SlopBlock, Gater)는 모두 기술 관점 문항이다. 이 repo는 git-review가 30/40 문서를 대조하는 절차를 갖고 있어 정책·계약 근거가 있는 비즈니스 문항을 만들 수 있다.
- 정답보다 위치가 확실한 증거이므로 위치를 본문에 두고 정답은 뒤로 미룬다.
- 헬퍼가 마크다운 코드 펜스를 상태로 다루지 않아 펜스 안 `### `·`<details>` 행도 문서 구조로 세기 때문에 코드 블록을 금지했다.
- 주석이 일반적인 성질을 설명하는데 코드는 그 성질을 피해 가는 인자를 쓰는 사례가 시험 실행에서 나왔다.
- 공개 반응의 지적 두 가지(답도 AI로 만들면 무의미, LLM이 원저자 의도를 모름)는 강제 게이트가 아닌 셀프 점검이라 전자가 덜 해당하고, 후자는 근거 규칙으로 완화한다.
- PR #93 리뷰로 위치 행의 백틱 포함 형식을 SKILL.md와 헬퍼 주석에 명시했다.
- 수용한 known issue: permalink 검사가 경로·줄 범위를 대조하지 않음(K-0007), 형식 어휘 반례 fixture 부재(K-0008).

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 문항을 코드 라인 리뷰 코멘트로 분산 게시: 순서대로 풀기 어렵고 리뷰 상태와 얽혀 기각.
- 머지 차단 게이트(status check): 개인 스킬 범위를 넘고 답까지 AI로 만드는 우회가 예상되어 셀프 점검·학습에 한정.
- git-review 옵션으로 흡수: 리뷰(지적)와 점검(문항)은 산출물·절차가 달라 SKILL.md가 비대해진다.
- 온보딩용(도메인 문서 기반) 문항 스킬: 입력·근거 위치가 달라 별도 스킬로 정리하고 신설 여부는 보류.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #92 git-review-quiz 스터디 모드 스킬 신설](https://github.com/scroogy-dev/scroogy-agent-skills/issues/92)
- [PR #93 리뷰 코멘트](https://github.com/scroogy-dev/scroogy-agent-skills/pull/93)
- 연구: [Code Review Comprehension (ICPC 2025)](https://arxiv.org/pdf/2503.21455)
- 사례: [dkamm/pr-quiz](https://github.com/dkamm/pr-quiz), [SlopBlock](https://slopblock.pro/), [Gater](https://usegater.app/), [tidewave-ai/pr-quiz](https://github.com/tidewave-ai/pr-quiz)

</details>
