# git-review PR 모드 실행 로그 (PR #139)

- 실행일: 2026-11-21
- 작업 디렉토리: `/Users/user/Dev/git-repository/scroogy-agent-skills` (브랜치 `issue-0142`)
- 따른 절차: 저장소의 `git-review/SKILL.md`·`git-review/templates/`·`git-review/scripts/` (설치본 미사용)
- 인자: `https://github.com/scroogy-dev/scroogy-agent-skills/pull/139`
- 결과 파일: `.ai/99_workspace/temp_review_result.md`
- 명령은 셸(zsh)에서 실행한 그대로 적었다. `sha`처럼 변수를 쓴 명령은 바로 뒤에 변수 값을 적었다.

---

## 1. 저장소 확정·대조

upstream 원격 조회. 현재 브랜치에 upstream이 없어 SKILL.md 규칙대로 `origin`을 썼다. 원격은 `origin` 하나뿐이다.

```
$ git rev-parse --abbrev-ref '@{upstream}'
fatal: no upstream configured for branch 'issue-0142'
exit=128
$ git remote
origin
exit=0
$ git remote get-url 'origin'
https://github.com/scroogy-dev/scroogy-agent-skills.git
exit=0
```

- 쓴 원격: `origin`
- 원격 URL: `https://github.com/scroogy-dev/scroogy-agent-skills.git`

저장소 대조 헬퍼 호출:

```
$ 'git-review/scripts/resolve-target.sh' --remote-url 'https://github.com/scroogy-dev/scroogy-agent-skills.git' --pr 'https://github.com/scroogy-dev/scroogy-agent-skills/pull/139'
```

- 표준 출력: `github.com/scroogy-dev/scroogy-agent-skills 139`
- 표준 오류: (없음)
- 종료 코드: `0`

## 2. 1단계 `gh pr view`와 보관한 값

```
$ gh pr view '139' --repo 'github.com/scroogy-dev/scroogy-agent-skills' --json number,title,url,body,commits,headRefName,headRefOid,baseRefName,baseRefOid,closingIssuesReferences
exit=0
```

응답의 PR URL `https://github.com/scroogy-dev/scroogy-agent-skills/pull/139`이 헬퍼가 낸 저장소 `github.com/scroogy-dev/scroogy-agent-skills`와 같아 아래 값을 불변값으로 보관했다.

| 항목 | 값 |
|------|----|
| 저장소 | `github.com/scroogy-dev/scroogy-agent-skills` |
| PR 번호 | `139` |
| URL | `https://github.com/scroogy-dev/scroogy-agent-skills/pull/139` |
| `headRefOid` | `e5f2a0761ae902e54e12a2ba2faa2db28abb2c81` |
| `baseRefOid` | `3f50a962871233143daaa3100e5c7c5a340c711f` |

- 참고로 같은 응답의 `headRefName`은 `issue-0138`, `baseRefName`은 `main`, `closingIssuesReferences`는 `[]`이다.

## 3. 2단계에서 모은 것

```
$ gh pr diff '139' --repo 'github.com/scroogy-dev/scroogy-agent-skills'
exit=0  (1685행)
$ gh pr diff '139' --repo 'github.com/scroogy-dev/scroogy-agent-skills' --name-only
exit=0  (24행)
```

- diff의 변경 파일 수: `24` (`--name-only` 24행, diff의 `diff --git` 머리 행 24개)
- PR 본문: 모았다. 1단계 응답의 `body`, 5909글자
- 커밋 메시지의 수: `5` (1단계 응답 `commits` 배열 길이)

1단계 응답의 커밋 목록:

```
0bcdc07eb6657873c2bfdb4916f87099fc6f1588 feat(ai-workspace): update가 프로젝트 규칙 표에 넣는 행을 알파벳순 자리에 두고 어긋난 표는 정렬을 권…
47ccc4ed46450188ba3e92d9107ab21920f4f679 docs: ai-workspace 명세와 ADR 0028·0029에 알파벳순 자리 보강과 행 순서 정렬 권유 반영 (#138)
404d227feccd4c18203a9840cef532fbf76c8474 docs(issue-0138): Task N 최종 감사 결과 기록과 이슈 문서·감사 리포트 archive 이관, 경로 참조 …
5482a1dfd434de154585a3ddc5e337b5b3cc6835 docs(ledger): 원장 K-0029에 규칙 표 알파벳순의 이름 속 숫자 비교 방식 미정을 수용으로 등재 (#138)
e5f2a0761ae902e54e12a2ba2faa2db28abb2c81 docs: 코드맵 sync로 ai-workspace update 흐름에 규칙 표 알파벳순 자리와 행 순서 검사를 반영하고 동…
```

- 제목 끝의 `…`은 GitHub가 긴 제목을 `messageHeadline`에서 자르고 나머지를 `messageBody` 앞에 `…`으로 이어 붙인 표기다. 두 값을 이어 읽으면 전체 메시지다.

## 4. PR의 커밋 수와 견준 결과

```
$ gh api --hostname 'github.com' 'repos/scroogy-dev/scroogy-agent-skills/pulls/139' --jq .commits
5
exit=0
```

- PR의 커밋 수: `5`
- 커밋 메시지 수: `5`
- 견준 결과: 같다. 다 모은 것으로 보고 `--paginate` 페이지 조회는 하지 않았다.

## 5. 연결 이슈

- PR 본문 참조에서 찾은 번호: `#138`(5회), `#136`(1회)
  - `#136`은 본문 `#### 배경`의 "#136에서 dev 전용 행을 표 끝에 넣는 조치가 늘면서 차이가 커졌다" 한 곳에 나온다.
- `closingIssuesReferences`에서 찾은 번호: 없음 (`[]`)
- 중복을 뺀 번호: `#138`, `#136` (둘 다 같은 저장소)

본문 참조가 이슈인지 확인한 조회(PR 번호와 이슈 번호가 같은 번호 공간을 써서 확인했다):

```
$ gh api --hostname 'github.com' 'repos/scroogy-dev/scroogy-agent-skills/issues/136' --jq '{number, title, state, is_pr: (.pull_request != null)}'
{"is_pr":false,"number":136,"state":"closed","title":"ai-workspace: IDE 도구 우선 규칙(ide-tools.md)을 dev 프로파일에 도입하고 init·update에서 안내도 규칙 표·context-loading에 연결한다"}
exit=0
$ gh api --hostname 'github.com' 'repos/scroogy-dev/scroogy-agent-skills/issues/138' --jq '{number, title, state, is_pr: (.pull_request != null)}'
{"is_pr":false,"number":138,"state":"closed","title":"ai-workspace: update가 프로젝트 규칙 표에 넣는 행을 알파벳순 자리에 두고 어긋난 표는 정렬을 권유한다"}
exit=0
```

실제로 본문을 읽은 번호와 명령:

```
$ gh issue view '138' --repo 'github.com/scroogy-dev/scroogy-agent-skills' --json title,body
exit=0
$ gh issue view '136' --repo 'github.com/scroogy-dev/scroogy-agent-skills' --json title,body
exit=0
```

- `#138`: 본문 읽음. `## 완료의 정의`에 AC1~AC9가 있다.
- `#136`: 본문 읽음. 배경 언급이라 AC 대조에는 쓰지 않았다.

## 6. diff를 받은 뒤 다시 조회한 값

```
$ gh pr view '139' --repo 'github.com/scroogy-dev/scroogy-agent-skills' --json headRefOid,baseRefOid
{"baseRefOid":"3f50a962871233143daaa3100e5c7c5a340c711f","headRefOid":"e5f2a0761ae902e54e12a2ba2faa2db28abb2c81"}
exit=0
```

| 항목 | 1단계 값 | 다시 조회한 값 | 같은가 |
|------|----------|----------------|--------|
| `headRefOid` | `e5f2a0761ae902e54e12a2ba2faa2db28abb2c81` | `e5f2a0761ae902e54e12a2ba2faa2db28abb2c81` | 같다 |
| `baseRefOid` | `3f50a962871233143daaa3100e5c7c5a340c711f` | `3f50a962871233143daaa3100e5c7c5a340c711f` | 같다 |

- 같으므로 1단계부터 다시 모으지 않았다.

## 7. 3단계 읽기 기준

커밋 존재 확인 (`sha=e5f2a0761ae902e54e12a2ba2faa2db28abb2c81`):

```
$ git cat-file -e "${sha}^{commit}"
exit=0
```

- 결과: 고정한 커밋이 로컬에 있다. `git fetch`는 하지 않았고 `gh api` contents 조회도 쓰지 않았다. 주변 코드는 모두 `git show "${sha}:<경로>"`로 읽었다.

주변 코드를 읽은 명령의 예. `bash -c '…'` 안에서 `sha="e5f2a0761ae902e54e12a2ba2faa2db28abb2c81"`을 정한 뒤 실행했고, 모두 `git show` 종료 코드 0이다. 아래는 `bash -c` 따옴표를 푼 안쪽 명령이다.

```
git show "${sha}:ai-workspace/scripts/check-context.sh" | sed -n "1,40p" | cat -n
git show "${sha}:ai-workspace/scripts/check-context.sh" | sed -n "225,350p" | awk "{printf \"%4d  %s\n\", NR+224, \$0}"
git show "${sha}:ai-workspace/SKILL.md" | grep -nE "^#{2,4} "
git show "${sha}:ai-workspace/references/legacy-migration.md" | cat -n
git show "${sha}:ai-workspace/tests/run-tests.sh" | awk "(NR>=28&&NR<=60)||(NR>=305&&NR<=320)||(NR>=330&&NR<=400)||(NR>=640&&NR<=700){printf \"%4d  %s\n\", NR, \$0}"
git show "${sha}:ai-workspace/tests/fixtures/update4-idempotent/missing-rows.input.md" | awk "NR<=30{printf \"%3d  %s\n\", NR, \$0}"
git show "${sha}:.ai/60_codebase/ai-workspace/update-call-flow.md" | awk "NR>=55&&NR<=100{printf \"%4d  %s\n\", NR, \$0}"
git show "${sha}:.ai/AI-CONTEXT.md" | head -5
git show "${sha}:.ai/40_domain/policies/local/notation-conventions.md" | grep -n "트리" | cut -c1-300
```

- 6번째 명령은 실제로 `for c in missing-rows.input missing-rows.expected` 반복 안에서 `…/$c.md`로 실행했다.
- 비즈니스 리뷰의 참조 문서(`.ai/30_contract/index.md`, `.ai/40_domain/index.md`, `.ai/50_adr/index.md`, ADR 0008·0023·0028·0029)도 같은 `git show "${sha}:…"`로 읽었다.
- SSoT 선언: head 판 `.ai/AI-CONTEXT.md` 본문 2번째 줄이 `> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.`라 코드 카테고리 세트를 썼다.

## 8. `.ai/70_ledger/index.md`와 `.ai/60_codebase/index.md` 읽기

처음에는 zsh에서 `${PIPESTATUS[0]}`로 종료 코드를 남기려 했으나 zsh에서는 값이 비어, 같은 명령을 bash로 다시 실행했다. 출력 행은 두 번 모두 같다. 아래는 bash 실행분이다 (`sha=e5f2a0761ae902e54e12a2ba2faa2db28abb2c81`).

```
$ git show "${sha}:.ai/70_ledger/index.md" | grep -n K-0023
exit: git show=0 grep=0
```

출력의 `K-0023` 행 전체:

```
43:| [K-0023](active/K-0023-check-plan-include-label-trailing-comment.md) | issue-audit 추적성 헬퍼가 행 끝에 닫힌 주석이 붙은 `**포함**` 라벨을 인식하지 못한다 | known issue | 낮음(LOW) | 수용 | 실제 spec에서 이 경계 때문에 `추적 불가`로 오판정된 사례 관측 시, 또는 `check-plan.sh --trace`의 spec 앵커 판정(`**포함**` 라벨·포함 목록 경계) 변경 시, 또는 issue-work spec 템플릿의 `**포함**` 행에 주석을 두는 구조가 도입될 때 |
```

```
$ git show "${sha}:.ai/60_codebase/index.md" | grep -n "^| issue-work "
exit: git show=0 grep=0
```

출력의 `issue-work` 행 전체:

```
31:| issue-work | `issue-work/SKILL.md` (`--create·--workflow-only·--resume·--response·--clear`) | [새 이슈 시작 흐름](issue-work/start-call-flow.md), [--create 흐름](issue-work/create-call-flow.md), [--response 흐름](issue-work/response-call-flow.md), [--clear 흐름](issue-work/clear-call-flow.md), [계약](../../../30_contract/github-integration.md), [명세](../../../40_domain/specs/issue-workflow.md), [승인 게이트 정책](../../../40_domain/policies/local/external-action-approval-gate.md), [ADR 0003](../../../50_adr/active/0003-verification-levels-and-determinization.md), [ADR 0004](../../../50_adr/active/0004-cross-model-audit-and-response-gate.md), [ADR 0005](../../../50_adr/active/0005-model-separation-gates.md), [ADR 0013](../../../50_adr/active/0013-long-output-single-file-generation.md), [ADR 0015](../../../50_adr/active/0015-issue-clear-timing-and-archive-rules.md), [ADR 0016](../../../50_adr/active/0016-spec-requirements-layer-and-plan-audit.md), [ADR 0018](../../../50_adr/active/0018-ledger-proactive-review-and-resolve-timing.md), [ADR 0019](../../../50_adr/active/0019-test-perspectives-and-task-level-placement.md), [ADR 0021](../../../50_adr/active/0021-ledger-archive-move-link-update.md), [ADR 0023](../../../50_adr/active/0023-testing-principles-pair-and-consumer-skill-references.md), [ADR 0026](../../../50_adr/active/0026-acceptance-criteria-across-issue-spec-pr.md), [K-0003](../../../70_ledger/active/K-0003-approved-file-content-unverified.md), [K-0004](../../../70_ledger/active/K-0004-clear-preserve-destination-mismatch.md), [K-0013](../../../70_ledger/active/K-0013-issue-work-pr-lookup-fork-same-branch.md) — 이슈 완료 시(`--clear` 4단계) 원장 해소 기재와 spec 제외 `보류` 항목 원장 등재 질의. 외부 쓰기는 `--create`의 이슈 등록, 시작 6단계의 이슈 본문 갱신, `--clear`의 이슈 댓글 |
```

- 대조용 관찰: 작업 트리(`issue-0142`)의 같은 K-0023 행은 `archive/` 경로·`해소(PR #141)` 상태라 head 판(`active/`·`수용`)과 다르다. 리뷰에는 head 판만 썼다.

## 9. 4단계에서 뽑은 PR 본문 항목

**리뷰어 확인 요청** (본문 12행 `**리뷰어 확인 요청**` 아래 2항목):

1. 정렬 권유 거절을 기억하지 않아, 행 순서를 일부러 다르게 둔 repo는 update를 실행할 때마다 권유를 받는다. 디렉토리 트리 정렬 권유와 같은 방식인데, 이 반복 질의가 허용 범위인가?
2. 비교 기준은 `파일` 셀 경로 전체를 소문자로 바꾼 `LC_ALL=C` 바이트 순이고 디렉토리 우선은 적용하지 않는다. 이름 속 숫자도 문자로 비교해 `rule-10.md`가 `rule-2.md`보다 앞에 온다(원장 K-0029로 수용). 이 기준을 그대로 둬도 되는가?

**완료의 정의 대조**:

- 요약 줄 (본문 20~21행): `- 충족 9/9`
- 대조 표: 본문 `<details>` 안 `#### 완료의 정의 대조 표`(본문 32행)의 AC 행 9개 (AC1~AC9, PR 본문 상태는 모두 `충족`)

## 참고: AC7 확인을 위한 러너 실행

- SKILL.md가 정한 단계는 아니다. 완료의 정의 대조(AC7)의 근거를 얻으려고 head 판을 scratchpad로 내보내 러너를 실행했다. 저장소 작업 트리의 파일은 쓰지 않았다.

```
$ git archive 'e5f2a0761ae902e54e12a2ba2faa2db28abb2c81' ai-workspace .ai | tar -x -C "<scratchpad>/head139"
$ bash "<scratchpad>/head139/ai-workspace/tests/run-tests.sh"
```

- 결과: `passed: 209, failed: 0`, 종료 코드 0 (`ok` 209행, `NOT OK` 0행)
- AC7 관련 `ok` 행: 행 순서 통과 7개·격추 4개, `fixture 상태 판정(unsorted-rows): 표의 행 순서`, `SKILL.md 멱등 보강 검사 표: 15행 (헬퍼 13종 + 트리 관련 2종 제외)`, `저장소 안내도: .ai/AI-CONTEXT.md 통과`

같은 사본에서 spec R3·R4·R5 검증 명령(AC3·AC4·AC5·AC6)도 실행했고 위반 출력은 없었다. 맞바꾼 dev 템플릿의 헬퍼 출력은 다음 1행, 종료 코드 1이다.

```
누락: '## 프로젝트 규칙' 표의 행 순서 (`.ai/10_rules/coding-convention.md` 뒤에 `.ai/10_rules/architecture.md` — 알파벳순 정렬 권유 대상)
```

## 보충: PR 번호 인자로 한 대상 수집 (최종 감사 1차 F-6)

- 실행일: 2026-11-21. 위 실행의 인자는 PR 링크였고, spec R1의 실제 실행 `[QD]`는 PR 번호로 실행한 기록을 요구한다. 그래서 인자 `139`로 대상 수집 1·2단계를 한 번 더 수행했다(GitHub 읽기 조회만, 비즈니스·테크 리뷰는 하지 않음).
- 실행 셸은 bash 3.2.57이고 저장소의 `git-review/SKILL.md`·`git-review/scripts/`를 따랐다. 실행 전후 `git status --porcelain`의 `cksum`이 `950438485 1699`로 같고 브랜치는 `issue-0142` 그대로다.

1단계 저장소 확정·대조:

```
git rev-parse --abbrev-ref '@{upstream}'   → 종료 코드 128 (fatal: no upstream configured for branch 'issue-0142')
git remote                                 → origin
git remote get-url 'origin'                → https://github.com/scroogy-dev/scroogy-agent-skills.git
resolve-target.sh --remote-url 'https://github.com/scroogy-dev/scroogy-agent-skills.git' --pr '139'
                                           → 종료 코드 0, 표준 출력 [github.com/scroogy-dev/scroogy-agent-skills 139]
```

1단계 조회 `gh pr view '139' --repo 'github.com/scroogy-dev/scroogy-agent-skills' --json number,title,url,body,commits,headRefName,headRefOid,baseRefName,baseRefOid,closingIssuesReferences`:

- `headRefName` `issue-0138`, `headRefOid` `e5f2a0761ae902e54e12a2ba2faa2db28abb2c81`, `baseRefOid` `3f50a962871233143daaa3100e5c7c5a340c711f` (위 2절에 보관한 값과 같다)
- PR 본문 5909자, `commits` 항목 5개, `closingIssuesReferences` 빈 배열

2단계 변경 수집:

```
gh pr diff '139' --repo 'github.com/scroogy-dev/scroogy-agent-skills'               → 1685행
gh pr diff '139' --repo 'github.com/scroogy-dev/scroogy-agent-skills' --name-only   → 변경 파일 24개
gh api --hostname 'github.com' 'repos/scroogy-dev/scroogy-agent-skills/pulls/139' --jq .commits → 5
gh issue view '136' --repo 'github.com/scroogy-dev/scroogy-agent-skills' --json title,body → 종료 코드 0 (본문을 읽음)
gh issue view '138' --repo 'github.com/scroogy-dev/scroogy-agent-skills' --json title,body → 종료 코드 0 (본문을 읽음)
gh pr view '139' --repo 'github.com/scroogy-dev/scroogy-agent-skills' --json headRefOid,baseRefOid → 1단계 값과 같다
```

- 모은 커밋 메시지 5개와 PR의 커밋 수 5가 같아 페이지 조회는 하지 않았다.
- 연결 이슈는 본문 참조 `#136`·`#138`이고 `closingIssuesReferences`에서 더해진 번호는 없다.
- 링크로 실행한 위 2~6절과 diff 행 수, 변경 파일 수, 커밋 수, 연결 이슈, 다시 조회한 값이 모두 같다.
