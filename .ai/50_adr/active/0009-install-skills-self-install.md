---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/35
related_jira:
last_harvested: 2026-09-09
---

# ADR: install-skills self-install 전환과 헬퍼 경로 탐색

## 결정

- `install-skills`를 홈(`~/.claude/skills/install-skills/`)에 한 벌만 두고 어느 스킬 repo에서든 복제본 없이 `/install-skills`로 실행한다.
- 일반 배포 시 자기 제외는 유지하고, `--self` 지정 시에만 해제해 자기 자신을 홈에 설치한다(최초 1회 부트스트랩).
- `verify-install.sh` 헬퍼는 홈 설치본 우선, 없으면 cwd(current working directory, 현재 작업 디렉토리) 폴백으로 탐색한다. 홈 탐색은 install-skills만의 예외이며 나머지 스킬 헬퍼는 `<skill 디렉토리>` 상대 참조를 쓴다.
- 스킬 repo 판별 가드: 루트에 `*/SKILL.md`가 0건이면 경고 후 중단, 1건이면 사용자 확인(AI가 대화로 수행), 2건 이상이면 통과. 판정 스니펫은 셸 내장만 쓴다(bash·zsh 겸용, nullglob 대응).
- 설치 검증은 결정적 확인(`verify-install.sh` exit code) 우선, AI 크로스체크는 보조다.
- Antigravity 대상 경로는 공식 경로 `~/.gemini/config/skills/`다. 구 경로 `~/.gemini/antigravity/skills/`는 심링크·부재·빈 디렉토리면 보존하고, 비어 있지 않은 실제 디렉토리로 잔존하면 경고·정리 제안한다. 구 경로 리터럴은 `verify-install.sh`만 보유하고 SKILL.md에는 두지 않는다.
- 설치 결과 보고 형식은 `templates/install-result-template.md`로 고정한다. 설치된 skill 설명은 `description` 한 줄 요약본이다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 스킬 저장소가 용도별(개발·컴플라이언스·콘텐츠)로 분리되어 있는데 install-skills가 홈에 설치되지 않아 각 repo에 복제해 동기화해야 했다. SSoT 훼손, 개선 전파 비용, drift 위험이 생겼다 (#35).
- 슬래시 커맨드는 `~/.claude/skills/`에서 전역 인식되므로 각 repo에 아무것도 두지 않아도 실행된다.
- 홈 경로 탐색은 `--agents`·`--antigravity`·`--codex`·`--junie` 설치본에서 빗나간다. 자기 디렉토리와 작업 대상 repo가 다른 유일한 스킬이 install-skills라 탐색이 기능이며, `.claude`만 보는 것은 기본 설치 경로를 전제한 의도된 설계다 (#90).
- 구 경로는 심링크 환경에서만 우연히 동작했다. 경로만 바꾸면 잔존물이 죽은 파일로 남거나 중복 인식되고, 심링크면 지우면 안 되므로 분기가 필요했다 (#28).
- 설치 성공 판단을 AI에 전적으로 위임해 신뢰성이 낮았다. bash word-splitting을 가정한 스크립트가 zsh에서 잘못된 디렉토리를 만드는 문제도 함께 드러났다.
- Copilot이 제안한 `compgen -G`는 bash 전용이라 zsh에서 가드가 정상 repo에서도 중단되는 회귀가 있어, for-loop + `[ -e ]`로 대체했다 (PR #36).
- 보고 형식이 미규정이라 같은 명령을 다른 세션에서 실행하면 보고 모양이 달랐다. `description` 말미가 트리거 키워드 나열이라 원문 전재 시 검색어가 함께 노출되어 요약본으로 정했다 (#84).

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 각 스킬 repo에 install-skills 복제본 유지: SSoT 훼손으로 기각. 다른 repo의 복제본 제거는 별도 이슈.
- 스킬 repo 가드에서 1건 매칭도 단순 통과: 교차모델 audit에서 승인된 설계(1건 시 사용자 확인)와 충돌해 채택하지 않았다.
- 모든 스킬 헬퍼를 홈 우선 탐색으로 통일: 다른 설치 경로에서 빗나가 기각 (#90, 13군데 `<skill 디렉토리>` 형식으로 통일).
- 설치 결과의 skill 설명 원문 전량 전재: audit 권장안이었으나 3회 반려 후 요약본 규칙으로 전환.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #28 Antigravity 설치 경로 공식화 및 설치 검증 결정적화](https://github.com/scroogy-dev/scroogy-agent-skills/issues/28)
- [Issue #35 install-skills self-install형 전환](https://github.com/scroogy-dev/scroogy-agent-skills/issues/35)
- [Issue #84 설치 결과 출력 형식을 templates/로 분리](https://github.com/scroogy-dev/scroogy-agent-skills/issues/84)
- [Issue #90 결정화 여지 전수 조사 (헬퍼 경로 결정)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/90)
- [PR #36 리뷰 코멘트 (가드 셸 호환)](https://github.com/scroogy-dev/scroogy-agent-skills/pull/36)

</details>
