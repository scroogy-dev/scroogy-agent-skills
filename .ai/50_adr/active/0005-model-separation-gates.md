---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/43
related_jira:
last_harvested: 2026-09-09
---

# ADR: 모델 분리 운용을 위한 설계 문서 점검 게이트

## 결정

- 설계(spec/plan)·구현·audit을 서로 다른 모델이 맡을 수 있다는 상황만 전제한다. 특정 모델·벤더명은 절차·규칙에 하드코딩하지 않고 기록 필드의 값으로만 존재한다.
- 계획 종료 게이트: plan `## Tasks` 앞 고정 블록. "이 spec/plan만 보고, 작성에 참여하지 않은 모델이 구현에 필요한 내용을 알 수 있는가"를 점검하고, 문서에 없는 전제(코드베이스 관례, 버전·환경 제약, 버린 대안)를 spec `## 전제 (Assumptions)`에 적는다.
- 구현 시작 게이트(Task 0): 구현 첫 고정 Task. spec/plan을 읽고 문서만으로 알 수 없는 전제·모호점을 나열해 코드 작성 전에 사용자에게 질의하고, 답을 spec 전제에 반영한다. 없으면 summary에 "전제 누락 없음"을 적는다. 판정 주체는 사람이다.
- summary `모델 기록` 표는 설계·구현·audit 행으로 나누고, Task별로 `수행 모델`·`audit 발견`·`보정 반영`·`재시도`를 기록한다. 세부 SSoT는 Task별 `수행 모델`이며, 한 Task를 둘 이상이 수행했으면 ` / `로 전부 나열한다.
- `수행 모델` `-`는 미착수·스킵 Task 전용이다. Task N 전에 모든 일반 Task의 `결과`가 완료·부분 완료·스킵 중 하나로 확정돼 있어야 한다.
- 이슈 종료 점검은 Task 체크박스에 더해 계획 종료 게이트의 `점검 완료` 체크박스도 확인한다.
- 게이트 2건은 모델 분리 여부와 무관하게 동작하며, 기존 active 이슈에 소급하지 않는다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 설계 문서에 작성 모델의 머릿속에만 있던 전제가 남으면 다른 모델이 문서만으로 구현에 착수할 수 없다. 같은 모델이라도 `--resume` 등 세션 교체 시 동일하게 적용된다.
- 이슈 단위 1행짜리 모델 기록으로는 "모델 분리가 재작업을 줄이는가"를 사후 확인할 수 없다. 보정률은 `보정 반영 / audit 발견`으로 grep 집계한다.
- PR #44 리뷰에서 우회 경로 3건이 드러났다. 전 Task `수행 모델: -`로 교차모델 조건 통과, summary `결과` 미확정으로 강화 조건 공집합화, 게이트 체크박스가 `## Tasks` 밖이라 종료 점검 누락. 각각 위 결정으로 닫았다.
- "계획·구현 모델"이 한 행이던 시절의 문구가 audit 벤더 조건에 남아 설계 벤더 배제로 읽혔다. #29에서 계승한 조건은 구현 기준이라 정합화했다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 구현 시작 게이트 위치: plan 고정 Task / workflow 절차 / 둘 다 중 "plan 고정 블록 + workflow `작업 진행 중` 한 줄"을 택했다 (#29 F-1 선례).
- 전제 섹션 위치: 기존 `연관 문서` 확장 대신 spec `## 전제 (Assumptions)` 신설.
- 설계 벤더까지 audit에서 배제: spec 결정 변경에 해당해 범위에서 제외했다.
- 모델 자동 전환·자동 선택, 보정률 자동 집계 도구: 비포함.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #43 모델 분리 운용 지원 (설계 문서 점검 게이트·Task별 모델·보정 지표)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/43)
- [PR #44 리뷰 코멘트](https://github.com/scroogy-dev/scroogy-agent-skills/pull/44)

</details>
