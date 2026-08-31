<!--
check-quiz.sh 회귀 테스트용 정상 fixture (`--comment` 게시 본문 예시).
위치 행에 permalink 를 병기하고 응답 기록 섹션을 두지 않는다.
Q2 는 삭제 코드 문항이라 base 표기와 base SHA permalink 를 함께 붙인다.
-->

# 리뷰 퀴즈 PR #91 issue-work 설계 종료 게이트 검사 추가

## 대상

| 항목 | 값 |
|------|-----|
| 대상 | PR #91 issue-work 설계 종료 게이트 검사 추가 |
| 기준 커밋 | `0123456789abcdef0123456789abcdef01234567` (삭제 코드 문항은 base `89abcdef0123456789abcdef0123456789abcdef` 기준) |
| 형식 | 객관식 |
| 관점 | 테크만 |
| 근거 문서 | 없음 (테크 문항만) |
| 문항 수 | 2 |

## 문항

### Q1 [테크 · 객관식]

위치: `issue-work/scripts/check-clear.sh:60-72` ([permalink](https://github.com/scroogy-dev/scroogy-agent-skills/blob/0123456789abcdef0123456789abcdef01234567/issue-work/scripts/check-clear.sh#L60-L72))

Task 블록 계수가 `flush()` 로 블록 단위 판정을 하는 이유는 무엇인가?

- (a) 파일 전체 총계 비교는 한 블록의 누락을 다른 블록의 중복으로 상쇄해 통과하기 때문
- (b) awk 가 블록 단위로만 정규식을 적용할 수 있기 때문
- (c) 출력 순서를 Task 순서로 맞추기 위해서

<details>
<summary>힌트</summary>

체크박스가 0 개인 블록과 2 개인 블록이 한 파일에 같이 있을 때 총계가 얼마인지 세어 본다.

</details>

<details>
<summary>정답·해설</summary>

(a). 총계 비교는 상쇄를 허용하므로 블록마다 실재와 유일성을 따로 센다.

근거: `issue-work/scripts/check-clear.sh:60-66`

</details>

### Q2 [테크 · 객관식]

위치: `issue-work/scripts/check-clear.sh:44` (base) ([permalink](https://github.com/scroogy-dev/scroogy-agent-skills/blob/89abcdef0123456789abcdef0123456789abcdef/issue-work/scripts/check-clear.sh#L44))

이번 변경에서 지워진 단일 계수 방식은 어떤 입력을 통과시켰는가?

- (a) Task 체크박스가 모두 체크된 입력
- (b) 설계 종료 게이트 체크박스가 없는 입력

<details>
<summary>힌트</summary>

지워진 계수가 무엇을 세지 않았는지 본다.

</details>

<details>
<summary>정답·해설</summary>

(b). 게이트 체크박스의 실재를 세지 않아 블록이 없는 plan 이 그대로 통과했다.

근거: `issue-work/scripts/check-clear.sh:44`

</details>
