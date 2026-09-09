---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/46
last_harvested: 2026-09-09
---

# 표기·명명 관례

## 관례

- 분류 값은 한글 우선 병기다. 위험도 높음(HIGH)/중간(MEDIUM)/낮음(LOW)/정보(INFO), 판정 충족(PASS)/미충족(FAIL)/부분 충족(PARTIAL)/판정 불가(N/A), 단계는 1단계/2단계(영문 부제 병기). 새 분류 값도 같은 관례를 따른다.
- 예외: 스크립트 출력 토큰(`verify-install.sh`의 PASS/FAIL), 기계 판독용 YAML 값(`confidence: high`), CLI 옵션 인자(`init`/`update`, `dev`/`doc`), 완료 이슈의 이력 문서.
- 모델 기록은 "벤더, 모델명" 형식이다(예: `OpenAI, GPT-5 (Codex)`). 특정 모델·벤더명은 절차·규칙에 하드코딩하지 않는다.
- 디렉토리 트리는 IDE 기본 표시 순서다. 같은 단계 항목은 대소문자 무시 알파벳순, 디렉토리를 파일보다 위, `.` 숨김 항목도 같은 알파벳순.
- 이모지는 SKILL.md 설명 본문에 쓰지 않는다. 산출물 값 명세(issue-work 요약의 완료 표시, 신호등 판정·상태·등급)는 예외이며 헬퍼가 출력한다.
- `templates/` 참조는 "이 skill 디렉토리의 `templates/<파일>`"로 적는다.
- 스킬 디렉토리명과 `name`은 kebab-case로 같게 두고 대상-행위 패턴을 따른다(`git-review-quiz`, `readme-sync`). 이름·옵션명은 대칭·메타포보다 사용자가 그 기능을 부를 때의 의도로 고른다(`git-pr-feedback`, `--response`, `--clear`).
- 호환 AI 도구 목록은 Claude Code·Agents·Antigravity·Codex·Junie다. Gemini CLI는 Antigravity로 명칭을 바꿨고 Cursor는 제외했다.
- 헬퍼 호출 경로는 `'<skill 디렉토리>/scripts/<헬퍼>'` 형식이다.
- 라인 번호 참조(`path:line`)는 작성 시점 diff 기준이다. 이후 변경으로 어긋날 수 있어 섹션 제목으로 찾는다.

<details>
<summary>근거 펼치기</summary>

- repo 전수 확인 결과 영문 단독 분류 값은 issue-audit뿐이었고, 위험도 외 판정 값·단계 명명도 같은 성격이라 함께 전환했다. "통과" 대신 미충족·부분 충족과 같은 계열인 "충족"으로 확정했다 (#46).
- 트리 정렬 규칙은 각 영향 스킬에 같은 문장으로 명시한다. 본 repo의 트리는 이미 IDE 순서와 일치해 명문화가 본질이었다 (#11).
- 스킬명 결정 기준은 #64에서 확정했다. `install-skills --clear` 선례와 Claude Code `/clear` 유추가 `--clear`의 근거다 (#15). `--response`는 감사 도메인의 auditee response 용어와 일치한다 (#31).
- 이모지 정책은 #96에서 확인했다. 산출물 값 명세 예외는 issue-work 요약의 완료 표시 선례를 따른다.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #11 디렉토리 표현 순서 교정](https://github.com/scroogy-dev/scroogy-agent-skills/issues/11)
- [Issue #15 issue-work 정리 옵션 추가](https://github.com/scroogy-dev/scroogy-agent-skills/issues/15)
- [Issue #19 AI 도구 호환성 목록 갱신](https://github.com/scroogy-dev/scroogy-agent-skills/issues/19)
- [Issue #29 summary 모델 표기 일관화](https://github.com/scroogy-dev/scroogy-agent-skills/issues/29)
- [Issue #46 issue-audit 표기를 한글 우선 병기로 전환](https://github.com/scroogy-dev/scroogy-agent-skills/issues/46)
- [Issue #64 스킬명 확정 댓글](https://github.com/scroogy-dev/scroogy-agent-skills/issues/64)
- [Issue #82 templates/ 참조 표기 통일](https://github.com/scroogy-dev/scroogy-agent-skills/issues/82)
- [Issue #92 git-review-quiz (대상-행위 패턴)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/92)
- [Issue #96 git-review 신호등 판정 (이모지 정책)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/96)
- [PR #65 리뷰 코멘트 (라인 번호 참조)](https://github.com/scroogy-dev/scroogy-agent-skills/pull/65)

</details>
