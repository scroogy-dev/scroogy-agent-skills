---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/25
related_jira:
last_harvested: 2026-09-09
---

# ADR: 검증 레벨 체계와 결정화 판단 규칙

## 결정

- 완료 기준(spec 완료의 정의, plan Task 완료 기준)은 항목마다 검증 레벨 태그를 붙인다. 결정적 `[D]`(명령이 합·불 판정), 준결정적 `[QD]`(다른 AI·체크리스트 채점), 비결정적 `[ND]`(사람 판단).
- 기본값은 `[D]`다. 레벨을 내릴 때마다 강등 사유를 병기한다. 태그는 완료 항목 하나하나에 붙인다. 한 이슈 안에 세 레벨이 섞이는 것이 정상이다.
- 분류 기준은 "판정이 재현되고 사람 판단이 끼지 않는가"다. 수치도 고정 임계값으로 합·불에 환원하면 결정적이다.
- 완료 기준 항목의 형식은 본문에 태그와 보장 문장(강등 사유 포함)만 두고, 검증 명령·기대 출력·설계 주의점은 `<details>` 접기에 둔다 (#66).
- 검증 명령을 보정할 때는 불변식을 전수 명세한다. 개별 반례만 막는 보정은 하지 않는다 (#43).
- 결정론으로 표현할 수 있는 로직은 LLM 추론에 맡기지 않는다. 헬퍼 도입 여부는 `.ai/10_rules/architecture.md` `## 디자인 원칙`의 판단 체크리스트(1번 필수 + 2~4번 중 2문항 이상)로 정한다 (#90).
- 임계 수치(반복 호출 횟수, 분기 개수)는 두지 않는다. 판정 재현성은 체크리스트 통과 기준이 담당한다.
- 헬퍼의 기대값은 테스트에 적지 않고 SSoT 문서(SKILL.md 표)에서 뽑는다. 헬퍼 호출 경로는 `'<skill 디렉토리>/scripts/<헬퍼>'` 형식으로 통일한다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 생성형 AI 출력은 비결정적이다. 변경 범위를 통제하고 결과를 검증하려면 테스트·린터·검증 게이트 같은 결정적 하네스가 필요하다. 완료 기준이 산문으로 남으면 하네스 역할을 못 한다 (#25).
- plan을 세운 모델과 구현하는 모델이 달라도(세션 교체 포함) 문서만 읽고 합·불을 판정할 수 있어야 한다. Task 완료 판정은 구현 세션에서 반복되는 지점이라 결정적 기준의 효과가 spec 쪽보다 크다 (#50).
- 접기 형식 도입 전에는 `[D]` 항목 하나가 수백 자 한 행이 되어 읽기 어려웠다. 접기 뒤에도 `run-tests.sh`가 접기 안 코드 블록에서 게이트 명령을 추출하므로 템플릿 본문이 게이트 명령의 SSoT로 유지된다 (#66).
- 결정화가 우발적으로만 일어났다. 15개 스킬 중 결정적 요소가 있던 스킬은 3개였고 모두 개별 audit 발견을 막다 나온 산물이었다 (#90).
- 임계 수치를 두면 스킬마다 호출 단위와 분기 무게가 달라 같은 숫자가 다른 뜻이 되고, 기준을 넘기려 로직을 쪼개는 형식 충족이 생긴다 (#90).
- 홈 경로(`~/.claude/skills/`) 탐색은 `--agents`·`--codex` 등 다른 설치 경로에서 빗나간다. install-skills만 예외로 홈 탐색을 유지한다 ([ADR 0009](0009-install-skills-self-install.md)).
- #90 audit 발견 9건 중 7건이 신설 헬퍼의 거짓 통과였다. 판정 단위를 파일 전체에 두거나 위치 조건을 빠뜨린 것이 공통 원인이며, 전부 블록·범위 단위 판정으로 바꾸고 반례 회귀 테스트를 추가했다.
- 함정 두 가지 (#25): 가짜 `[D]`("이게 틀렸을 때 검사가 실제로 실패하나"를 물어야 한다. 구현 전 트리에서 통과하는 명령은 완료 여부를 구분하지 못한다)와 과한 자동화(자주 반복되고 중요한 항목만 `[D]`로 내리고 일회성은 `[QD]`가 비용 대비 낫다).

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 완료 기준을 산문으로 유지: 하네스 역할을 못 해 기각.
- 코드 블록을 통째로 뽑아 sed로 경로를 치환하는 게이트 추출 (#66): fixture 경로 주입이 이중화되어 기각. 접기 안 코드 블록에서 `P=`/`S=` 할당 행만 제외하고 추출한다.
- 결정화 임계 수치 도입 (#90): 위 근거로 기각.
- ai-workspace 검사 표 10종 전부 헬퍼화 (#90): `.ai/` 한 줄 압축과 트리 정렬 순서는 앵커 판정으로 환원되지 않는 트리 구조 해석이라 "조건 분기 과다" 예외로 두고 8종만 옮겼다.
- code-map check 헬퍼 (#90): 판정은 결정화 대상이나 이 repo에 `.ai/60_codebase/` 색인이 없어 원장 K-0006으로 이관했다.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #25 결정적 하네스 기반 DoD + 교차모델 audit 의무화](https://github.com/scroogy-dev/scroogy-agent-skills/issues/25)
- [Issue #43 모델 분리 운용 지원](https://github.com/scroogy-dev/scroogy-agent-skills/issues/43)
- [Issue #50 plan Task별 완료 기준에 검증 레벨 표기 도입](https://github.com/scroogy-dev/scroogy-agent-skills/issues/50)
- [Issue #66 완료 기준 가독성 개선 (문장 + 접기)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/66)
- [Issue #90 결정화 여지 전수 조사 + architecture.md 디자인 원칙 신설](https://github.com/scroogy-dev/scroogy-agent-skills/issues/90)
- 결정적 하네스 논의: https://news.hada.io/topic?id=30711

</details>
