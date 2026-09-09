---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/92
last_harvested: 2026-09-09
---

# 리뷰 퀴즈(git-review-quiz) 요건

## 요건

- 입력: PR 번호 또는 현재 브랜치 변경. 브랜치 모드에서는 `--comment` 불가, permalink 없음.
- 옵션: `--mcq`/`--open`(없으면 객관식·주관식·혼합 중 1회 질의), `--business`/`--tech`(없으면 둘 다), `--comment`(PR 일반 댓글 하나로 게시, 승인 게이트).
- 산출: 대화형 `.ai/99_workspace/temp_review_quiz.md`, 댓글 `temp_review_quiz_comment.md`. 형식 SSoT는 `templates/quiz-template.md`(`## 대상` 표, `## 문항`, `## 응답 기록`).
- 문항 형식 규칙 R1~R7: 헤더 번호 연속·관점·형식 태그(R1), 헤더 직후 백틱 포함 위치 행(R2), 힌트 접기 1개(R3), 정답·해설 접기(첫 행 정답 문자와 해설 또는 모범 답안, `근거:` 행, 비즈니스는 `정책 근거:` 행)(R4), 객관식 선택지 (a)부터 연속·정답 문자 결속, 주관식 선택지 없음(R5), 접기 밖 정답 노출 금지(R6), 문서 구조(`## 대상` 1개, `## 문항` 존재, 문항 1개 이상, 응답 기록 위치)(R7).
- `--comment` 모드 검사: permalink 전수(https, blob에 커밋 SHA, 줄 앵커) + `--head`/`--base` SHA 대조 + `## 응답 기록` 부재.
- 대화형: 한 문항씩 제시, 답변 후 정답·해설, "힌트" 요청 시 해당 문항 힌트만. 힌트·정답은 파일·댓글에서만 접기로 남긴다.
- 근거 문서(30/40)가 0건이면 테크 문항만 내고 알린다. git-review-context 산출물이 있으면 참고하되 자동 호출하지 않는다.

## 관련 결정

- [ADR 0017](../../50_adr/active/0017-git-review-quiz-study-mode.md), 정책 [외부 공개 행위 승인 게이트](../policies/local/external-action-approval-gate.md)
- 절차 상세는 `git-review-quiz/SKILL.md`, `templates/quiz-template.md`, `scripts/check-quiz.sh`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #92](https://github.com/scroogy-dev/scroogy-agent-skills/issues/92)
- [PR #93 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/93)

</details>
