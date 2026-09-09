---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/61
related_jira:
last_harvested: 2026-09-09
---

# ADR: 기술부채·known issue 원장의 위치와 구조

## 결정

- 수용한 기술부채·known issue의 단일 기록처를 `.ai/70_ledger/`에 둔다. `index.md` + `active/`(살아 있는 부채) + `archive/`(청산한 부채), 항목은 파일당 1건 `K-<번호>-<slug>.md`.
- 필수 필드 7종: 유형(known issue / 기술부채), 등재일, 출처, 위험도, 수용 사유, 재검토 조건, 상태(수용 / 승격(이슈 #N) / 해소(PR #N)).
- 출처는 식별자만 적는다(이슈 #N / audit 발견 F-n / PR 코멘트 스레드). 파일 경로를 넣지 않는다.
- 번호는 `active/`·`archive/`를 합쳐 최대 번호 + 1로 채번한다.
- index 골격은 ai-workspace가 단독 소유·배포하고, 항목 템플릿은 원장 데이터 옆(`.ai/70_ledger/ledger-entry-template.md`)에 두어 원장 골격과 함께 배포한다.
- 소비자는 issue-audit(기등재 대조·집계 제외·재검토 조건 충족 시 재제기), issue-work `--response`(미승인 항목 이관 목적지), git-pr-feedback(`수용 — 원장 등재` 선택지) 세 곳이다. 신규 스킬은 만들지 않는다.
- 소비자 두 곳은 같은 상태 행렬을 본다. `active/수용`만 억제 대상이고, `archive/해소` 재발과 `승격` 연결 이슈 닫힘은 `K-n 재발` 계보의 신규 발견이다. 확인 수단이 없으면 `승격` 항목은 참조 처리를 유지한다.
- 종결(해소)은 재검토 조건 충족 여부·등재 선택과 독립이다. 원인이 사라진 항목은 조건 미충족이어도 종결한다.
- git-review는 연계 범위 밖이다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 기술부채·known issue를 따로 관리하지 않으면 같은 발견이 교차모델 audit마다 반복 보고되어 개선→재검증이 무한 반복된다. `--response`의 "보류 또는 별도 이슈 이관"에 목적지 표준이 없어 보류 발견이 다음 audit에 신규로 다시 올라왔다.
- 수용 사유가 없으면 사유 없는 무한 보류가 되고, 재검토 조건이 없으면 issue-audit이 재제기 시점을 판정하지 못해 매 감사 신규 보고가 된다.
- 출처에 경로를 넣으면 `--clear` 5단계의 audit 리포트 이관(`99_workspace/` → `archive/issue-N/`)으로 원장 항목이 깨진다.
- archive를 빼고 채번하면 청산된 항목 번호를 재사용해 출처 추적이 깨진다.
- 위치는 당초 `.ai/90_issues/ledger/`로 확정했다가 2026-08-02 번복했다. 근거였던 "이슈 작업 흐름 안에서 생성·소비"가 git-pr-feedback(PR 리뷰는 이슈 흐름 밖)을 소비자에 추가하며 무너졌고, `90_issues/ # 이슈 단위 작업` 서술과 모순되며, update 이동 판단에 `K-*.md` 예외가 필요해진다. 최상위 신설 부담은 update 표 3곳 + AI-CONTEXT 2곳으로 작았다.
- 하위 구조는 `50_adr/`의 생사 분리 관례를 따랐다.
- 항목 템플릿을 스킬 내부로 옮기면 사본 동기화 부채 또는 스킬 간 교차 참조(선택 설치 환경에서 단절)가 생긴다 (#80).
- 4차에 걸친 audit 발견의 공통 축은 원장 소비자 두 곳(issue-audit·git-pr-feedback)의 분기 비대칭이었다. 종결을 등재 선택에서 떼어내 두 주체가 같은 상태 행렬을 보게 맞췄다.
- git-review는 의견 유형·심각도 체계가 없어 등재 기준을 세울 수 없었다(#62 이전 판단). #72 이후에도 원장 연계는 별도 이슈로 남겼다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- GitHub 이슈·라벨만으로 관리: audit마다 GitHub 조회가 필요하고 오프라인·타 AI 도구 호환이 약해 배제.
- 단일 파일 원장: 항목이 늘면 비대해지고 diff 충돌이 잦아 배제.
- `.ai/90_issues/ledger/` 하위 배치: 위 근거로 번복.
- `.ai/50_adr/` 하위 배치: ADR 수명 주기(active/superseded)와 원장(수용/승격/해소)이 달라 섞이고 ADR index가 오염되어 배제.
- 승격 경로 삭제: 원장이 이슈화 대상까지 흡수해 후속 조치가 묻혀 기각. 등재 후 `상태` 변경 단계로 재배치했다.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #61 기술부채·known issue 원장 도입](https://github.com/scroogy-dev/scroogy-agent-skills/issues/61)
- [Issue #62 issue-audit 심각도 체계 개선 (낮음 등급 이관 목적지)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/62)
- [Issue #80 git 스킬 3종 templates/ 분리 (원장 템플릿 위치 근거)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/80)
- 수명 주기·상태별 처리 표: [`.ai/70_ledger/index.md`](../../70_ledger/index.md)

</details>
