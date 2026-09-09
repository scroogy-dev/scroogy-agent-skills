---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/13
related_jira:
last_harvested: 2026-09-09
---

# ADR: 스킬 독립성과 공통 규칙의 의도적 중복

## 결정

- 각 스킬은 `.ai/AI-CONTEXT.md`에 의존하지 않고 단독 실행·단독 설치가 가능해야 한다. 공통 규칙은 `context-loading.md`만 명시적으로 참조한다.
- 여러 스킬이 공유하는 규칙(디렉토리 트리 정렬, 색인 갱신 문구, 위험도 매트릭스, 카테고리 7종, 접기 기준)은 각 스킬 SKILL.md에 같은 문구로 복제한다. 참조 링크로 대체하지 않는다.
- 복제한 표에는 원본 위치와 "한쪽 변경 시 양쪽 동기화" 주석을 남긴다. 위험도 매트릭스의 원본은 `issue-audit`, 카테고리 7종의 원본은 `git-review`다.
- 공통 규칙을 `.ai/10_rules/`에 두어 스킬이 참조하게 하지 않는다. 그 디렉토리는 사용자 repo로 자동 전파되지 않아 스킬 자기완결성을 해친다.
- 스킬 본문의 대형 분기·모드별 상세는 `references/`로 분리해 해당 분기에서만 적재한다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 스킬은 `install-skills`로 디렉토리 단위 선택 설치된다. 다른 스킬이나 repo 문서를 참조하면 선택 설치 환경에서 참조가 끊긴다.
- `.ai/`가 없는 repo에 스킬만 설치하는 경우에도 규칙이 발동해야 한다.
- 2026-06-12 Fable 5 감사(#13)에서 교차 중복 3건(트리 정렬 규칙·색인 갱신 문구·ASCII 지침)을 지적받았으나, 위 이유로 의도적 중복 유지를 결정하고 변경 시 grep 동시 수정 절차를 issue summary에 기록했다.
- 같은 감사에서 대형 본문을 `references/`로 분리해 SKILL.md 합계를 3,383줄에서 2,288줄로 줄이고 전 스킬을 500줄 미만으로 맞췄다.
- 트리 정렬 규칙(#11)은 영향 범위가 좁아 각 스킬에 동일 문장으로 명시했다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- ADR 또는 `.ai/10_rules/` 공통 규칙으로 분리 (#11): 사용자 repo에 전파되지 않아 채택하지 않았다.
- 참조 링크로 대체 (#72): 설치본에서 링크가 끊겨 채택하지 않았다. 두 스킬 간 표 중복은 수동 동기화 부담으로 수용했다.
- writing-principles를 참조 전용으로 연결 (#60): 파일이 없는 환경에서 규칙이 발동하지 않아 기각했다. 내장 기본값과 조건부 참조를 함께 두는 혼합형을 택했다 ([ADR 0008](0008-writing-principles-ssot-distribution.md)).

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #11 디렉토리 표현 순서 교정](https://github.com/scroogy-dev/scroogy-agent-skills/issues/11)
- [Issue #13 Fable 5 + skill-creator로 기존 스킬 점검·개선](https://github.com/scroogy-dev/scroogy-agent-skills/issues/13)
- [Issue #60 접기 적용 지점 명시 및 writing-principles 참조 연결](https://github.com/scroogy-dev/scroogy-agent-skills/issues/60)
- [Issue #72 git-review 위험도 등급 체계 도입](https://github.com/scroogy-dev/scroogy-agent-skills/issues/72)
- [Issue #75 git-review 테크 리뷰 카테고리 상세화](https://github.com/scroogy-dev/scroogy-agent-skills/issues/75)
- [Issue #76 issue-audit 리포트 역피라미드 재배치](https://github.com/scroogy-dev/scroogy-agent-skills/issues/76)

</details>
