---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/58
related_jira:
last_harvested: 2026-09-09
---

# ADR: git-pr의 PR 제출 확장과 승인 게이트

## 결정

- git-pr은 메시지 작성에서 PR 제출까지 수행한다. 옵션이 없으면 PR 유형(정식/드래프트)을 반드시 확인하고, 최종 제목·본문·대상을 제시해 작성자 승인을 받은 뒤에만 해당 유형으로 생성한다.
- 승인 게이트는 유형·옵션과 무관하게 생략할 수 없다. 거절하면 제출 없이 최종 제목·본문 파일만 남아 기존 "텍스트만" 용도를 대체한다.
- `--draft`는 유형 확인 질의만 생략하고 드래프트로 확정한다. 이후 절차는 기본 동작과 같다.
- 생성 수단은 `gh pr create` 기본, GitHub MCP `create_pull_request` 폴백(`github.com` 한정). 베이스는 원격 기본 브랜치 자동 감지. `--repo`·`--head`는 생략하지 않는다.
- 승인 SHA를 불변 보관하고 생성 후 head SHA를 대조한다. push 전 저장소를 재확인하고, 저장소 판정은 원격 URL 정규화로 한다(`verify-submit.sh`).
- 포크 기반 제출은 비지원이며 조기 안내 후 종료한다.
- 문서 동기화 점검: 브랜치 diff에서 README·AI-CONTEXT·코드베이스 색인 drift를 감지해 갱신 권고만 남긴다(flag-only 기본, 승인형 tier 선택). 문서 자동 재생성은 하지 않는다 (#17).

## 근거

<details>
<summary>상세 펼치기</summary>

- 메시지 작성 후 사용자가 `gh pr create`로 제목·본문을 옮기는 수동 이관에서 누락·형식 훼손이 생겼다. 실제로는 AI가 스킬 밖에서 제출까지 이어가는 경우가 많았고 그 비공식 동작에는 승인 게이트가 없었다 (#58).
- 드래프트만 스킬 안에서 제출하면 정식 PR은 수동 이관으로 남아 균형이 맞지 않는다.
- 실제 제출은 외부 공개 행위이므로 기본 동작을 "제출까지"로 바꾸는 파괴적 변경의 안전장치로 유형 확인·승인 게이트를 필수화했다.
- 교차모델 audit 6회 발견 20건이 `--head` 고정, 셸 인자 전달 규칙, 원격 URL 정규화, 승인 SHA 대조, `refs/heads/` 완전 ref 조회, MCP host 한정 등을 추가했다. 권장 2건(`git push -u <URL>`의 upstream 오염, 작은따옴표 포함 값 인용 불가 전제)은 반례 실측으로 축소했다.
- PR은 브랜치 diff 전체를 쥔 시점이라 문서 영향 판단 근거가 가장 좋고, 통합 배포에서도 PR당 1회로 집계된다. 무거운 문서 스킬 diff가 PR을 오염시키므로 자동 재생성은 하지 않는다 (#17).

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 메시지만 작성하는 별도 옵션(`--message-only`): 승인 거절 경로가 같은 역할을 해 두지 않았다.
- `--draft`와 대칭인 정식 확정 옵션: 두지 않았다.
- 드래프트 → 정식 전환 자동화, 포크 경로: 범위 밖.
- issue-work `--clear`가 문서 drift 신호를 넘기는 방식 (#17): diff에서 직접 재도출 가능해 중복이라 배제.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #17 git-pr 문서 동기화 점검 단계 추가](https://github.com/scroogy-dev/scroogy-agent-skills/issues/17)
- [Issue #58 git-pr PR 제출까지 확장 (유형 확인·승인 게이트 필수화)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/58)

</details>
