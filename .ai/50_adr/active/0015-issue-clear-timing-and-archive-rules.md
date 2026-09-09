---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/21
related_jira:
last_harvested: 2026-09-09
---

# ADR: issue-work 정리(--clear) 시점과 archive 이관 규칙

## 결정

- 정리 옵션명은 `--clear`다. 구현·리뷰 완료 후 PR 머지를 올리기 직전에 실행한다.
- archive 이관(`active/issue-<번호>/` → `archive/`)은 PR 머지 전 작업 브랜치에서 수행해 같은 PR에 포함한다.
- 이슈 댓글 등록은 git 변경이 아니므로 머지 전·후 어느 시점이든 가능하다.
- 이관한 파일 본문의 경로 참조를 이관 후 위치 기준으로 갱신한다. 함께 이동한 파일 간 참조는 `./` 상대 링크, `../` 링크는 깊이 재계산, 표준 병기 문구는 "(작성 시점 경로는 `<옛 경로>`, --clear로 이관)", archive 본문에 `99_workspace/` 참조 금지. 이관 후 stale 참조 0건을 결정적으로 확인한다(`check-clear.sh`).
- 새 이슈 시작 시 `issue-workflow.md`가 템플릿과 다르면 자동 갱신한다. `--workflow-only`는 비교 없이 무조건 덮어쓰는 강제 복구다.
- 기존 archive 파일은 소급 보정하지 않는다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 옵션명은 Claude Code `/clear` 명령과 `install-skills --clear` 선례와 일관된다 (#15).
- PR #20 작업에서 머지 후 `--clear`를 실행해 archive 이관이 `main` 직접 푸시로 처리되는 혼선이 있었다. "이슈 작업이 끝났을 때"가 구현 완료인지 머지 완료인지 정의가 없었고, 댓글(머지 후 적합)과 이관(머지 전 적합)이 한 옵션에 묶여 타이밍이 충돌했다 (#21).
- 이관 뒤 `active/`·`99_workspace/` 경로 참조가 남아 dead link가 반복됐고, `.ai` 하위 1단에서 3단으로 이동하면 `../` 기준 깊이가 달라진다. 수기 보정은 절차에 없어 누락이 반복됐다 (#37).
- 탐지 패턴은 include에서 exclude로 반전해 임의 파일명도 검출하고, 상주 파일 `active/issue-workflow.md`는 제외하며, `notes/` 예외는 철회했다(99_workspace는 언제든 비워질 수 있다는 가정).
- 템플릿(SSoT) 개선이 기존 인스턴스에 자동 전파되도록 새 이슈 시작 시 동기화를 넣었다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- git-pr 스킬에 워크플로우 순서 책임 부여 (#21 당시): description상 메시지 작성 전용이라 범위 밖으로 두었다.
- 기존 archive 소급 정리: 재발 방지가 목적이라 분리했다.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #15 issue-work 정리 옵션 추가](https://github.com/scroogy-dev/scroogy-agent-skills/issues/15)
- [Issue #21 --clear 시점·순서 모호함 개선](https://github.com/scroogy-dev/scroogy-agent-skills/issues/21)
- [Issue #37 --clear archive 이관 시 경로 참조 미갱신 개선](https://github.com/scroogy-dev/scroogy-agent-skills/issues/37)

</details>
