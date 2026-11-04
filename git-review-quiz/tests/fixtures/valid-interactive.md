<!--
check-quiz.sh 회귀 테스트용 정상 fixture (대화형 산출 예시).
설명 절(배경·목적·변경 설명)과 응답 기록 섹션이 있고 위치 행에 permalink 병기가 없다.
문항 내용은 형식 견본이며 실제 변경 내용과 일치할 필요가 없다.
-->

# 리뷰 퀴즈 PR #91 issue-work 설계 종료 게이트 검사 추가

## 대상

| 항목 | 값 |
|------|-----|
| 대상 | PR #91 issue-work 설계 종료 게이트 검사 추가 |
| 기준 커밋 | `0123456789abcdef0123456789abcdef01234567` |
| 형식 | 혼합 |
| 관점 | 테크만 |
| 근거 문서 | 없음 (테크 문항만) |
| 문항 수 | 3 |

## 배경

설계 종료 게이트 체크박스는 plan의 `## Tasks` 밖에 있다. 변경 전에는 `--clear` 완료 확인이 Task 체크박스만 세어, 게이트를 체크하지 않은 이슈도 완료로 넘어갔다.

<details>
<summary>입문용 심화 설명</summary>

완료 확인은 plan 파일에서 체크박스 행을 세어 미완료를 찾는다. 세는 구간을 Task 블록으로 한정하면 그 밖의 체크박스는 처음부터 대상이 아니다.

</details>

## 목적

완료 확인이 게이트 체크박스와 Task 체크박스를 함께 센다.

- 게이트를 체크하지 않은 이슈가 완료로 넘어가지 않는다.
- 게이트 체크박스가 없거나 두 개인 plan도 위반으로 드러난다.

## 변경 설명

### 변경 개요

| 묶음 | 위치 | 한 줄 요약 |
|------|------|-----------|
| 게이트 계수 | `issue-work/scripts/check-clear.sh:45-56` | 게이트 체크박스의 실재·유일성·체크 여부를 센다 |
| 회귀 테스트 | `issue-work/tests/run-tests.sh:12-18` | 템플릿에서 기대값을 뽑아 대조한다 |

읽을 순서: 게이트 계수 → 회귀 테스트

기타 변경: `issue-work/README.md`

### 호출 흐름

**`check-clear.sh --completion`**

```
check-clear.sh#main
└── check-clear.sh#completion (변경)   # 게이트와 Task 체크박스를 함께 센다
```

### 게이트 계수

위치: `issue-work/scripts/check-clear.sh:45-56`

**무엇이 바뀌었나**: Task 블록만 세던 완료 확인이 `## Tasks` 앞의 게이트 체크박스도 센다.

**전후 예시**

| 입력 | 변경 전 | 변경 후 |
|------|---------|---------|
| 게이트 미체크, Task 모두 체크 | 통과 | 게이트 미체크 1행 출력, 종료 코드 1 |

### 회귀 테스트

위치: `issue-work/tests/run-tests.sh:12-18`

**무엇이 바뀌었나**: 러너가 기대값을 템플릿 본문에서 뽑아 대조한다.

## 문항

### Q1 [테크 · 객관식]

위치: `issue-work/scripts/check-clear.sh:45-55`

완료 확인이 설계 종료 게이트 체크박스를 Task 체크박스와 따로 세는 이유는 무엇인가?

- (a) 게이트 체크박스가 `## Tasks` 밖에 있어 Task 계수에서 빠지기 때문
- (b) 게이트 체크박스의 문구가 Task 체크박스와 다르기 때문
- (c) 게이트가 plan 이 아니라 spec 에 있기 때문

<details>
<summary>힌트</summary>

두 체크박스가 문서의 어느 위치에 있는지 비교한다.

</details>

<details>
<summary>정답·해설</summary>

(a). 게이트 블록은 `## Tasks` 앞에 있어 Task 블록만 순회하는 계수에서 빠진다.

근거: `issue-work/scripts/check-clear.sh:45-47`

</details>

### Q2 [테크 · 주관식]

위치: `issue-work/scripts/check-clear.sh:48-56`

게이트 체크박스를 미체크만 세지 않고 실재와 유일성까지 함께 세는 이유를 설명하라.

<details>
<summary>힌트</summary>

체크박스가 아예 없는 입력과 두 개인 입력에서 미체크 계수가 각각 몇이 되는지 따져 본다.

</details>

<details>
<summary>정답·해설</summary>

미체크만 세면 체크박스가 없는 입력이 위반 0 건으로 통과한다. 실재와 유일성을 함께 세어 그 우회를 막는다.

근거: `issue-work/scripts/check-clear.sh:48-56`

</details>

### Q3 [테크 · 객관식]

위치: `issue-work/tests/run-tests.sh:12`

러너가 기대값을 테스트에 직접 적지 않고 템플릿 본문에서 추출하는 이유는 무엇인가?

- (a) 템플릿 파일이 러너보다 먼저 로드되기 때문
- (b) 템플릿이 SSoT 라서 한쪽만 바뀌면 드리프트가 잡히기 때문

<details>
<summary>힌트</summary>

두 곳에 같은 값을 적어 두면 어느 한쪽만 고쳐졌을 때 무엇이 어긋나는지 본다.

</details>

<details>
<summary>정답·해설</summary>

(b). 템플릿이 규격의 SSoT 이고 스크립트는 사본이라, 추출 대조가 두 문서의 드리프트를 잡는다.

근거: `issue-work/tests/run-tests.sh:12-18`

</details>

## 응답 기록

| 문항 | 응답 | 판정 |
|------|------|------|
| Q1 | (a) | 정답 |
| Q2 | 체크박스가 없으면 통과하기 때문 | 부분 (유일성 축을 짚지 않음) |
| Q3 | (a) | 오답 (실제 근거는 SSoT 드리프트 검출) |
