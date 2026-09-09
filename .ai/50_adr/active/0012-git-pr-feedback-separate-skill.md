---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/64
related_jira:
last_harvested: 2026-09-09
---

# ADR: PR 리뷰 코멘트 대응을 위한 git-pr-feedback 별도 스킬 신설

## 결정

- git-pr 제출 이후 리뷰 코멘트 대응 단계를 별도 스킬 `git-pr-feedback`으로 둔다. 절차는 수집 → 분류·의견 → 사용자 선택·승인 → 조치 → 결과 요약이다.
- 의견 유형 5종: 조치 필요 / 조치 불필요 / 수용(known issue) / 코멘트로 충분 / 확인 필요. 의견은 제안이며 항목별 처리 방식(코드 수정 / 답글 게시 / 수용 — 원장 등재 / 보류)은 사용자가 고른다.
- 보안·결함 지적은 발생확률·영향도 대비 수정 비용으로 판단해 수용할 수 있다.
- 답글 게시·스레드 resolve·push는 외부 공개 행위라 승인 게이트를 생략하지 않는다. push는 대상 PR head 결속, 커밋 목록·diffstat·최종 diff 제시, force-with-lease 원자 대조로 방어하며 `verify-push.sh`로 일원화한다.
- resolve 직전에 스레드를 재조회해 승인 당시 스냅샷과 대조하고, 달라졌으면 중단 후 재분류한다.
- 대상 PR은 현재 브랜치의 upstream 원격에서 저장소를 먼저 확정하고 첫 조회부터 `--repo`를 명시한다.
- 스킬명은 사용자가 이 기능을 부를 때의 의도("피드백 반영해줘")를 기준으로 정했다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 스킬 체계에 git-commit → git-pr → (빈 구간) → 머지의 공백이 있었다. 대응은 답글 또는 코드 변경 두 갈래라 항목별 분류·의견 후 사용자 선택이 필요하다.
- git-pr 확장 기각: git-pr의 생명주기는 제출에서 끝나고 본문이 제출 안전장치에 집중되어 있다. 코멘트 대응은 실행 시점(며칠 뒤 별도 세션, 리뷰 라운드마다 반복)이 달라 결합하면 본문 비대·트리거 혼탁이 생긴다.
- git-pr `--response` 옵션 기각: issue-work `--response`는 자기 작업공간 산출물의 내부 교정 루프라 유비가 절반만 성립한다. git 계열은 단계마다 별도 스킬로 분리하는 관례(git-review-context)가 있다.
- git-review 확장 기각: 리뷰를 수행하는 쪽과 받은 쪽으로 방향이 반대다.
- 진행 순서는 #64 → #61 → #62다. 원장 도입 시 소비자 전체를 한 번에 같은 규칙으로 배선하려면 이 스킬이 먼저 존재해야 했다. 원장은 보류 경로를 강화하는 요소라 원장 없이도 스킬은 완결적으로 동작한다.
- PR #65 Copilot 리뷰가 push URL 다중 설정, 원격 URL의 자격증명 노출, `GH_REPO`에 의한 저장소 오선택, MCP resolve 필수 입력 누락, 수집·승인 사이 새 코멘트 등 방어 지점을 추가했다.
- push 승인 게이트 완전성은 유한 체크리스트 6항목으로만 채점해 부분 충족 반복을 끊었다 ([ADR 0004](0004-cross-model-audit-and-response-gate.md)).

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 스킬명 후보: `git-pr-response`(용어 일치), `git-pr-comments`(대상 중심), `git-pr-feedback`(넓은 표현). 사용자 의도 기준으로 마지막을 확정했다.
- 사용자 선택 없는 자동 일괄 조치, PR 머지·닫기, 리뷰 수행 자체: 범위 밖.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #64 git-pr 이후 PR 리뷰 코멘트 검토·대응 스킬 신규 작성](https://github.com/scroogy-dev/scroogy-agent-skills/issues/64)
- [Issue #70 Git 정책 표에 git-pr-feedback 행 추가](https://github.com/scroogy-dev/scroogy-agent-skills/issues/70)
- [PR #65 리뷰 코멘트](https://github.com/scroogy-dev/scroogy-agent-skills/pull/65)

</details>
