---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/29
related_jira:
last_harvested: 2026-09-09
---

# ADR: 교차모델 audit 실행 주체와 리포트 보정 게이트

## 결정

- plan의 마지막 고정 Task(Task N)는 교차모델 `issue-audit`이다. 사용자가 직접, 구현 모델과 다른 벤더(Non-Anthropic 포함) 모델로 수동 수행한다. 구현 AI는 이 Task를 자동 실행하거나 닫지 않는다.
- audit 벤더 비교 기준은 구현 모델이다. summary Task별 `수행 모델`에 나열된 벤더 전부와 달라야 한다. 설계 모델은 비교 대상이 아니다.
- 모델 기록은 "벤더, 모델명" 형식으로 통일한다. audit 리포트 상단에도 `> 감사 모델:` 메타 줄을 두어 summary의 audit 모델 칸과 교차 대조할 수 있게 한다 (#26).
- 리포트 보정은 issue-work `--response`로 한다. 피드백만 먼저 제시하고, 항목 단위로 승인받은 뒤, 승인분만 보정한다. 승인 없는 자동 보정은 금지다 (#31).
- 순서 게이트: 1단계 적합성 발견(미충족·부분 충족)의 처리 방향이 전부 확정되기 전에는 2단계 비판적 발견의 승인 질의·보정에 들어가지 않는다. 예외는 사용자 명시 지시로만 연다 (#52).
- 등급별 기본 제시값을 따른다. 낮음(LOW)은 원장 이관, 정보(INFO)는 기록만이 기본이며 사용자 명시 승격 없이는 보정 루프에 넣지 않는다 ([ADR 0006](0006-risk-matrix-and-treatment.md)).
- summary 지표(`audit 발견`·`보정 반영`·`재시도`)는 이슈 전체 누적이다. 여러 회차가 같은 발견을 재확인해도 1건으로 세고, 한 발견은 가장 직접 수정된 주 Task 하나에만 귀속한다 (PR #44 리뷰).
- 재검증은 전체 재감사를 유지한다. 보정분만 보는 delta 재검증은 하지 않는다 (#62).
- 감사 종료 기준을 유한 체크리스트로 고정할 수 있다. 체크리스트 밖 신규 방어 제안은 별도 개선 사항으로 분리하며 미충족 사유로 삼지 않는다 (#64).

## 근거

<details>
<summary>상세 펼치기</summary>

- #28 진행 중 교차모델 audit이 같은 세션의 Sonnet 서브에이전트로 자동 수행되어, 구현자가 만든 컨텍스트를 같은 하네스에서 읽는 형태라 독립성이 약했다 (#29).
- "리포트 보고 진행하지 말고 피드백만" 같은 자연어 지시는 휘발되어 신규 세션·다른 모델에서 재현이 보장되지 않는다. 한 번이라도 빠뜨리면 구현 AI가 리포트를 받자마자 자동 보정할 여지가 있다 (#31).
- 옵션 이름 `--response`는 감사 도메인의 auditee/management response 용어와 일치한다. `--feedback`은 무엇에 대한 피드백인지 모호해 기각했다.
- 옵션 플래그와 workflow 절차 문서를 둘 다 두는 것은 #29 F-1 선례를 따른 것이다. 컨텍스트 초기화 후에도 절차가 유지되어야 한다.
- 품질 속성은 기능이 존재해야 의미가 있다. 스펙이 요구한 기능이 없는 상태에서 그 기능의 품질을 다듬으면 2단계 발견의 전제가 흔들리고, 다음 회차에 같은 1단계 지적이 반복된다 (#52).
- issue-audit은 이미 1단계 → 2단계 순서로 리포트를 만든다. 소비 쪽(`--response`)에만 순서가 없어 절차가 비대칭이었다.
- 지표 누적·주 Task 귀속 규칙이 없으면 후속 작성자가 회차별 값을 덮어쓰거나 반복 발견을 더해 보정률이 달라진다.
- 부분 충족(PARTIAL) 반복으로 감사가 종결되지 않는 문제(#64 push 승인 게이트 완전성)를 막기 위해 종료 기준을 유한 체크리스트 6항목으로 고정했다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 같은 세션 서브에이전트로 자동 audit (#28 실제 사례): 독립성이 약해 기각.
- delta 재검증 (#62): 검증 비용은 가장 낮으나 보정이 만든 회귀를 놓칠 수 있어 배제. 비용 절감은 등급별 처리 기준으로 달성한다.
- `--response` 순서 게이트의 강도: 순서만 강제하는 안 대신, 1단계 미해소 동안 2단계 보정 착수 금지를 채택했다. 충족·판정 불가는 게이트 대상이 아니다.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #26 issue-audit 리포트에 감사 모델 기재 추가](https://github.com/scroogy-dev/scroogy-agent-skills/issues/26)
- [Issue #28 install-skills Antigravity 경로 공식화 및 설치 검증 결정적화](https://github.com/scroogy-dev/scroogy-agent-skills/issues/28)
- [Issue #29 교차모델 audit 실행 주체 명확화](https://github.com/scroogy-dev/scroogy-agent-skills/issues/29)
- [Issue #31 audit 리포트 검토→피드백→승인 실행 흐름 옵션화](https://github.com/scroogy-dev/scroogy-agent-skills/issues/31)
- [Issue #52 --response 1단계 적합성 발견 우선 처리](https://github.com/scroogy-dev/scroogy-agent-skills/issues/52)
- [Issue #62 issue-audit 심각도 체계 개선](https://github.com/scroogy-dev/scroogy-agent-skills/issues/62)
- [Issue #64 git-pr-feedback 스킬 신규 작성](https://github.com/scroogy-dev/scroogy-agent-skills/issues/64)
- [PR #44 리뷰 코멘트 (지표 누적·귀속 규칙)](https://github.com/scroogy-dev/scroogy-agent-skills/pull/44)

</details>
