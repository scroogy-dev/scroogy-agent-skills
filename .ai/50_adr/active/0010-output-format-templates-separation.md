---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/80
related_jira:
last_harvested: 2026-09-09
---

# ADR: 산출물 형식의 templates/ 분리와 참조 표기

## 결정

- 산출물 형식 블록은 SKILL.md에 임베드하지 않고 각 스킬의 `templates/`에 둔다. SKILL.md는 템플릿 참조와 작성 규칙만 유지한다.
- 분리 대상은 산출물 형식 블록만이다. 절차 설명 속 예시, 규칙 표(접기 기준 등), 접기 안내 문장은 SKILL.md에 남긴다.
- 템플릿 파일은 코드 펜스 없는 순수 마크다운이며, 첫 행 주석에 용도를 적는다. 펜스 해제·안내 주석 추가는 내용 변경으로 보지 않는다.
- `templates/` 참조 표기는 "이 skill 디렉토리의 `templates/<파일>`" 하나로 통일한다. 매핑 표는 셀마다 반복하지 않고 도입 문장에서 한 번 기준을 명시한다.
- 제외: git-commit(Conventional Commits 규칙 링크가 곧 템플릿), git-pr-feedback(형식이 원장 항목 템플릿으로 이미 분리, 그 외는 대화 출력 표 수준).
- 파일명 관례는 `<산출물>-template.md`(예: `pr-body-template.md`, `review-result-template.md`, `quiz-template.md`).

## 근거

<details>
<summary>상세 펼치기</summary>

- 분리한 스킬과 임베드한 스킬이 혼재해 구조 일관성이 깨져 있었다. git-review가 #75에서 먼저 분리했고 git 스킬 3종(#80), install-skills(#84)가 뒤따랐다.
- 스킬은 self-install로 `~/.claude/skills/<name>/`에 설치되고 실행 시점 cwd는 대상 프로젝트 repo다. `templates/`를 cwd 기준으로 해석하면 파일을 찾지 못한다. 같은 SKILL.md 안에 `.ai/99_workspace/...`(cwd 기준)와 `templates/...`(스킬 디렉토리 기준)가 섞이므로 수식어는 해석 기준을 정하는 실질 정보다 (#82).
- PR #81 리뷰에서 git-qa 한 파일 안의 표기 불일치를 지적받았고, 같은 결함이 repo 전반 21곳 중 10곳에 남아 있었다.
- 통일 기준은 현행 다수 표기(9곳)인 `이 skill 디렉토리의`다. 영문 `skill` 표기는 유지하고 한글 치환은 범위 밖으로 두었다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 장문 명시형("이 스킬 파일의 위치(SKILL.md가 있는 디렉토리)를 기준으로") 전면 통일: 채택하지 않았다. ai-workspace의 기존 장문 1곳은 더 명시적이라 그대로 두었다.
- git-pr-feedback 원장 템플릿을 스킬 내부로 이동: 사본 동기화 부채 또는 교차 참조 단절이 생겨 기각 ([ADR 0007](0007-tech-debt-ledger-location-and-structure.md)).

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #75 git-review 카테고리 상세화 (템플릿 분리 선례)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/75)
- [Issue #80 git 스킬 3종 산출물 형식 블록 templates/ 분리](https://github.com/scroogy-dev/scroogy-agent-skills/issues/80)
- [Issue #82 templates/ 참조 표기 통일](https://github.com/scroogy-dev/scroogy-agent-skills/issues/82)
- [Issue #84 install-skills 설치 결과 출력 형식 templates/ 분리](https://github.com/scroogy-dev/scroogy-agent-skills/issues/84)
- [PR #81 리뷰 코멘트](https://github.com/scroogy-dev/scroogy-agent-skills/pull/81)

</details>
