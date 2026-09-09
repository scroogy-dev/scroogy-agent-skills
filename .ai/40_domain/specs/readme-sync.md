---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/7
last_harvested: 2026-09-09
---

# README 생성·갱신(readme-sync) 요건

## 요건

- README는 사람을 위한 문서이고 AI-CONTEXT.md는 AI 에이전트를 위한 문서다. 중복이 있을 수 있으며 README 생성 시 AI-CONTEXT.md를 참고할 수 있다.
- 모드 `init`(없으면 생성)/`update`(있으면 현재 구조에 맞게 재작성), 프로파일 `individual`/`business`. 프로파일은 init의 기본값 프리셋이며 update에서는 무시해 기존 README 말미 블록을 보호한다.
- 단일 템플릿 `templates/README-template.md`: 필수 3섹션(Header·개요·Quick Start) + 옵션 섹션 + 말미 마커(라이선스·개인 저작물 고지). 옵션 섹션을 0개 골라도 정상이다(Simple is Best).
- 라이선스 옵션, LICENSE 파일 생성, `--force-license` 가드, 헤더 파일명 가드는 [라이선스 정책](../policies/local/license-policy.md)을 따른다. 상세 사양은 `references/license.md`(오픈소스 분기 전용).
- 디렉토리 구조 섹션은 IDE 정렬 규칙을 따른다.
- 표본 분석: Spring·OpenClaw·React·Kubernetes README에서 표준 섹션 8종을 도출했다.
- 스킬 목록 표 갱신은 readme-sync가 담당한다. 다른 이슈에서 README 행을 손으로 넣은 경우는 diff 축소를 위한 예외다.

## 관련 결정

- 정책 [라이선스 정책](../policies/local/license-policy.md), [표기·명명 관례](../policies/local/notation-conventions.md)
- 절차 상세는 `readme-sync/SKILL.md`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #7](https://github.com/scroogy-dev/scroogy-agent-skills/issues/7), [#9](https://github.com/scroogy-dev/scroogy-agent-skills/issues/9), [#11](https://github.com/scroogy-dev/scroogy-agent-skills/issues/11), [#92](https://github.com/scroogy-dev/scroogy-agent-skills/issues/92), [#100](https://github.com/scroogy-dev/scroogy-agent-skills/issues/100)

</details>
