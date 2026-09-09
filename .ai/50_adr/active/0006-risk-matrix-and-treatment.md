---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/62
related_jira:
last_harvested: 2026-09-09
---

# ADR: 위험도 산정 매트릭스와 등급별 처리 기준

## 결정

- 2단계 비판적 검증 발견의 등급은 감사인·리뷰어가 직접 고르지 않는다. 영향 축(스펙·기능 달성 차단 / 기능 저하 / 기술 품질 의견)과 발생확률 축(통상 사용 / 특수 조건·엣지)을 먼저 판정하고 고정 매트릭스로 산출한다.

| 영향 \ 확률 | 통상 사용 | 특수 조건·엣지 |
|-------------|-----------|----------------|
| 스펙·기능 달성 차단 | 높음(HIGH) | 중간(MEDIUM) |
| 기능 저하 | 중간(MEDIUM) | 낮음(LOW) |
| 기술 품질 의견 | 낮음(LOW) | 정보(INFO) |

- 보안·데이터 손실 결함은 영향 축 `스펙·기능 달성 차단`에 매핑한다. 특수 조건에서만 실현되면 중간(MEDIUM)이 된다.
- 등급별 기본 처리: 높음은 보정 필수·재검증, 중간은 `--response` 승인 게이트에서 사용자 판단, 낮음은 원장 이관, 정보는 기록만. 재감사 신규 발견에도 같은 기준을 적용한다.
- 1단계 적합성의 미충족·부분 충족은 매트릭스 대상이 아니다.
- 산출은 헬퍼 `classify-risk.sh`가 담당한다. 원본은 `issue-audit`이고 `git-review`가 같은 표를 복사해 쓴다. git-review에서는 등급을 우선순위 표시·수용 판단 근거로만 쓰고 등급별 처리·원장 연동은 두지 않는다.
- 리뷰 포인트에는 등급과 축 판정을 함께 병기한다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 교차모델 audit 특성상 모델마다 등급이 달라져, 사소한 기술 지적도 높음과 같은 보정 루프에 들어가 개선→재검증 반복이 과다했다 (#62).
- 등급이 처리 방식과 연결되어 있지 않아 재검증 루프 진입량을 구조적으로 줄일 수 없었다.
- 등급만 적으면 "축 먼저 판정" 원칙의 재현·검증이 불가능해 축 병기를 요구했다 (#72).
- git-review의 등급별 처리·보정 루프는 issue-work 보정 루프 전용이라 범위 밖으로 두었다. 보정은 작성자 몫이고 수용·방어 판단은 git-pr-feedback 영역이다.
- 다른 평가 스킬은 대상이 아니다. git-pr-feedback은 조치 관점의 의견 유형이 이미 있고, git-qa는 체크리스트라 등급이 불필요하며, pi-scan은 이미 노출된 정보를 평가해 발생확률 축이 성립하지 않는다.
- 축 값이 겹치거나 증거가 부족할 때의 우선 규칙 부재는 원장 K-0002로 수용했다.
- DoD 문구가 축 판정 재량(정성 평가라 제거 불가)과 등급 선택 재량(매트릭스로 제거됨)을 묶어 요구해 달성 불가능했고, "등급을 직접 선택하지 않고 축·매트릭스로 산출한다"로 좁혀 `[D]`로 승격했다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 등급 산정을 감사인 재량으로 유지하고 필드만 추가: 모델별 등급 편차가 남아 처리 기준 일관성이 무너져 배제.
- delta 재검증: [ADR 0004](0004-cross-model-audit-and-response-gate.md) 참조.
- 참조 링크로 매트릭스 공유: 스킬 독립성 원칙상 불가 ([ADR 0002](0002-skill-independence-intentional-duplication.md)).

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #62 issue-audit 심각도 체계 개선 (2축·발생확률·등급별 처리)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/62)
- [Issue #72 git-review 위험도 등급 체계 도입](https://github.com/scroogy-dev/scroogy-agent-skills/issues/72)

</details>
