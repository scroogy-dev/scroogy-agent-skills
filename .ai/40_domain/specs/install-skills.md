---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/35
last_harvested: 2026-09-09
---

# 스킬 설치(install-skills) 요건

## 요건

- 대상 경로 5종: `--claude`(기본) `~/.claude/skills/`, `--agents` `~/.agents/skills/`, `--antigravity` `~/.gemini/config/skills/`, `--codex` `~/.codex/skills/`, `--junie` `~/.junie/skills/`. `--all`은 전체.
- 소스는 cwd의 `*/SKILL.md` 보유 디렉토리 스캔(하드코딩 목록 없음) → 목록 제시 → 사용자 선택. 스킬 repo 판별 가드(0건 중단 / 1건 확인 / 2건 이상 통과).
- 자기 자신은 기본 제외, `--self`로만 설치. `--clear`는 대상 경로의 기존 스킬을 비운 뒤 재설치한다(디렉토리 자체 유지, Antigravity 구 경로는 건드리지 않음).
- 복사는 `rsync -a --exclude 'tests/' --exclude '*.test.*'`(rsync 부재 시 fallback 병기). 이 `--exclude`가 배포 제외 패턴의 단일 출처다.
- 설치 검증: `verify-install.sh`(홈 우선 → cwd 폴백)로 대상 경로별 skill 디렉토리·`SKILL.md` 존재, dev 경로 미포함, Antigravity 구 경로 실제 디렉토리 잔존 여부를 exit code로 판정. AI는 결과를 읽어 크로스체크. Antigravity 레거시 점검은 `--antigravity` 또는 `--all`일 때만.
- 보고는 `templates/install-result-template.md`(경로별 결과 / 설치된 skill 목록(description 한 줄 요약) / 적용 옵션 내역)에 따른 대화 출력.
- 셸 스니펫은 bash·zsh 겸용이어야 한다(word-splitting 배열 처리, nullglob 대응).
- 회귀 테스트 `tests/run-tests.sh`는 verify 케이스와 SKILL.md 스니펫 스모크(문서·구현 드리프트 감지)를 포함한다.
- 수용한 기술부채: 배포 제외 패턴 리터럴이 SKILL.md 5단계와 템플릿에 중복(K-0005).

## 관련 결정

- [ADR 0001](../../50_adr/active/0001-skill-deterministic-helper-test-convention.md), [ADR 0009](../../50_adr/active/0009-install-skills-self-install.md), 계약 [AI 도구 스킬 포맷과 설치 경로](../../30_contract/ai-tool-skill-paths.md)
- 절차 상세는 `install-skills/SKILL.md`가 SSoT다.

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #13 (스킬 목록 스캔 방식 전환)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/13)
- [Issue #23](https://github.com/scroogy-dev/scroogy-agent-skills/issues/23), [#28](https://github.com/scroogy-dev/scroogy-agent-skills/issues/28), [#35](https://github.com/scroogy-dev/scroogy-agent-skills/issues/35), [#84](https://github.com/scroogy-dev/scroogy-agent-skills/issues/84)
- [PR #36 리뷰](https://github.com/scroogy-dev/scroogy-agent-skills/pull/36)

</details>
