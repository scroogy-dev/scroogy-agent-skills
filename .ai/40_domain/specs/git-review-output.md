---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/96
last_harvested: 2026-09-09
---

# 리뷰(git-review) 결과 산출 요건

## 요건

- 리뷰는 비즈니스 리뷰(`.ai/30_contract/`·`40_domain/` 대조)와 테크 리뷰 두 단계다. 비즈니스 리뷰 절차는 #72~#96에서 변경하지 않았다.
- 테크 리뷰는 카테고리 7종(기능, 아키텍처, 버그, 보안, 코드품질, 성능, 테스트)을 검증한다. 상호 독립이며 실행 방식은 지시하지 않는다. 프로젝트 고유 관점을 행으로 추가할 수 있으나 issue-audit 사본과 동기화해야 한다.
- 리뷰 포인트 등급은 영향×발생확률 매트릭스로 산출하고 축 판정을 병기한다. 계약·정책 위반은 영향 축 `스펙·기능 달성 차단`이다. 등급은 우선순위 표시·수용 판단 근거로만 쓴다.
- 상태: 카테고리·리뷰 상태는 최고 위험도로 산출(통과(PASS)/주의(WARN)/보완 필요(FAIL)). 판정은 두 리뷰 상태의 최고값(승인(APPROVE)/조건부 승인(CONDITIONAL)/변경 요청(REQUEST CHANGES)). Self 리뷰의 승인은 "제출 가능"을 뜻한다.
- 결과는 `.ai/99_workspace/temp_review_result.md`에 1회 기록하며 형식은 `templates/review-result-template.md`다. 순서는 판정 한 줄 → 최종 의견(접기) → 요약(리뷰 상태·검토 파일 수·카테고리별 건수·상태 표) → 비즈니스 리뷰 → 테크 리뷰(카테고리 소절, 항목별 블록·근거 접기).
- 대화창 보고는 같은 판정 한 줄로 시작한다. 대화 출력에는 접기를 쓰지 않는다.
- 헬퍼 `classify-risk.sh`: 매트릭스(`--impact`·`--likelihood`), `--status`, `--verdict`. 이모지 접두 4종 입력 호환, 그 밖의 접두와 모드 혼용·빈 축 값은 종료 코드 2·빈 표준 출력.
- git-review 발견의 원장 연계는 두지 않는다. 필요해지면 별도 이슈로 판단한다.
- git-review-context는 사용자가 명시 요청할 때만 실행하며 git-review가 자동 호출하지 않는다.

## 관련 결정

- [ADR 0002](../../50_adr/active/0002-skill-independence-intentional-duplication.md), [ADR 0006](../../50_adr/active/0006-risk-matrix-and-treatment.md), [ADR 0014](../../50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md)
- 절차 상세는 `git-review/SKILL.md`와 `git-review/templates/review-result-template.md`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #13 (git-review-context 명시적 요청 제약)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/13)
- [Issue #72](https://github.com/scroogy-dev/scroogy-agent-skills/issues/72), [#75](https://github.com/scroogy-dev/scroogy-agent-skills/issues/75), [#96](https://github.com/scroogy-dev/scroogy-agent-skills/issues/96)
- [PR #73 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/73), [PR #77 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/77)

</details>
