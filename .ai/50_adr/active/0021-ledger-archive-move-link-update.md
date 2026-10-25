---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/120
related_jira:
last_harvested: 2026-10-25
---

# ADR: 원장 항목을 archive로 옮길 때 들어오는 링크를 고치고 끊긴 원장 링크를 헬퍼로 확인하는 결정

## 결정

- 원장 항목을 `active/`에서 `archive/`로 옮기면 그 항목을 가리키는 다른 `.ai/` 문서의 링크(들어오는 링크)를 새 경로로 고치고, 끊긴 원장 링크가 0건인지 확인한다. 옮기는 스킬은 이 단계를 "들어오는 링크 갱신"으로 부른다 (#120).
- 갱신 범위와 대상을 아래와 같이 정한다.
  - **범위**: `.ai/` 아래 문서이며 `.ai/90_issues/archive/`는 뺀다. 그 아래 이슈 문서에 남은 옛 경로도 소급해 고치지 않는다.
  - **대상**: `70_ledger/active/K-<번호>-` 경로 링크와 원장 항목 파일끼리의 같은 디렉토리 링크다. 같은 디렉토리 링크는 `active/`에 남은 항목이 옮긴 항목을 가리키는 링크와 옮긴 항목이 남은 항목을 가리키는 링크를 모두 포함한다.
  - **깊이**: 상대 경로 깊이는 링크가 있는 문서 위치에서 다시 계산한다.
- 적용 지점은 원장 항목을 옮기는 5곳이다. 스킬마다 정의 행(`**들어오는 링크 갱신**:`)을 1곳에 두고 나머지 지점은 참조한다.
  - **issue-work**: `## 이슈 완료 시` 3단계 원장 해소 기재에 정의하고, `--response` 5단계의 이슈 승격·이번에 반영·보정으로 원인이 사라진 기등재 종결이 참조한다. `--clear` 4단계는 원장 해소 기재를 그대로 부르므로 따로 고치지 않는다.
  - **git-pr**: "PR 제출" 4단계 원장 해소 기재의 번호 단계(index 갱신 뒤, 커밋과 push 앞)에 정의하고, "문서 동기화 점검" 원장 대조의 승격 이관이 참조한다. 승격 이관에 빠져 있던 `.ai/70_ledger/index.md` 항목 목록 갱신도 함께 적는다.
  - **git-pr-feedback**: `### 기존 원장 항목의 종결`에 정의한다.
- 세 정의 행은 같은 문장으로 복제하고 종결 어미만 스킬 문체를 따른다(issue-work 한다체, git-pr·git-pr-feedback 합니다체). 원장 index 수명 주기 설명(shared 템플릿과 이 repo 사본)과 issue-work 워크플로우 템플릿에는 요약 한 줄을 둔다.
- 0건 확인은 결정적 헬퍼 `check-ledger-links.sh`가 맡는다. `architecture.md` `## 디자인 원칙`의 판단 체크리스트로 분리를 판정했다.
  - **사본**: `issue-work`·`git-pr`·`git-pr-feedback`의 `scripts/`에 사본 3개를 두고 바이트 단위로 같게 유지한다. 한쪽을 고치면 나머지도 고친다(ADR 0002).
  - **판정**: `.ai/` 아래 `*.md`(`90_issues/archive/` 제외)에서 파일 이름이 `K-<4자리 숫자>-`로 시작하는 링크 대상을 링크가 있는 파일의 디렉토리 기준으로 푼다. 파일이 없으면 `<파일>:<줄>: <대상>`을 1행씩 내고 종료 코드 1이며, 끊긴 링크가 없으면 무출력·종료 코드 0, 사용오류는 종료 코드 2다.
  - **출력 처리**: 이번 이동으로 끊긴 링크는 고치고, 이동과 무관하게 이미 끊겨 있던 링크는 목록으로 알려 고칠지 묻는다. 헬퍼는 검사만 하고 링크를 고치지 않는다.
- 세 스킬의 러너는 헬퍼 테스트(ADR 0001)와 정의 행·적용 지점·헬퍼 호출 블록의 구조 검사를 둔다. 다른 헬퍼(`check-clear.sh`·`verify-push.sh` 등)의 호출 블록 검사는 소급하지 않는다.
- #121(ADR 처리 규칙)은 이 정의 문장의 대상 경로만 바꿔 ADR을 `superseded/`로 옮길 때의 링크 갱신에 복제한다.
- ADR 0018은 고치지 않는다. ai-workspace update-3 "기존 파일 정리"의 원장 이동은 이 결정의 대상이 아니다.

## 근거

<details>
<summary>상세 펼치기</summary>

- 링크가 끊기면 문서에서 원장 항목을 찾아갈 수 없다. `60_codebase/` 색인의 "관련 문서" 열은 context-loading 절차가 따라가는 경로이고, ADR 0020은 퍼블리싱 재검토 조건을 원장 [K-0014](../../70_ledger/active/K-0014-publishing-skill-deferred.md)에 맡긴다. 이슈 작성 시점에 index 밖에서 `active/K-*`를 가리키는 링크는 10개 파일 19줄이었다.
- 지금까지 옮긴 항목은 [K-0011](../../70_ledger/archive/K-0011-plan-audit-regression-exception-spec-only.md)(승격, #108) 1건이다. 그때 `60_codebase/index.md` 링크는 절차 밖에서 손으로 고쳤다(3d3ff5e). 절차에 없으면 다음 이동에서 빠진다.
- ADR 0015의 `--clear` 이관 규칙은 옮긴 파일 안의 링크를 고치고 `check-clear.sh --refs`로 남은 옛 경로를 찾는다. 원장 이동에서 끊기는 링크는 대부분 다른 파일에서 옮긴 항목으로 들어오는 링크라 그 규칙을 그대로 쓸 수 없다.
- 원장 항목끼리는 같은 디렉토리 상대 링크로 가리킨다(K-0014가 K-0015를 `K-0015-…md`로 가리키는 식). `70_ledger/active/K-<번호>-` 경로 패턴은 이 링크를 잡지 못해 대상에 따로 넣었다. 옮긴 항목이 `active/`에 남은 항목을 가리키는 링크도 같은 이유로 끊긴다.
- 판단 체크리스트 판정은 아래와 같다. 1번과 3·4번을 만족해 통과 기준(1번과 2~4번 중 두 문항)을 넘는다.
  - 1번(같은 입력에 같은 출력): 충족. 같은 트리에는 같은 끊긴 링크 목록이 나와야 한다.
  - 2번(반복 호출): 미충족. 이동 1회에 한 번 부른다.
  - 3번(기계 검증): 충족. 종료 코드로 판정한다.
  - 4번(명확한 오류): 충족. 끊긴 링크를 파일·줄로 낸다.
- 옛 경로 grep 대신 끊긴 링크 검사를 택했다. 옮긴 뒤에는 옛 경로 파일이 없어 옛 경로 링크도 끊긴 링크로 잡히고, 같은 검사가 같은 디렉토리 링크와 깊이 오계산까지 잡는다.
- 사본 3개는 스킬 독립 설치를 위한 의도적 중복이다(ADR 0002). `verify-push.sh`·`verify-submit.sh`의 URL 정규화와 두 `classify-risk.sh`가 선례다. 바이트 단위로 같게 두면 동기화 확인이 `cmp` 하나로 끝난다.
- ADR 0018은 원장 종결의 계기와 기재 시점(언제·누가)을 정한다. 이번 결정은 옮길 때 무엇을 고치고 어떻게 확인하는지와 헬퍼 판정이라 주제가 달라 새 ADR로 남겼다. #121이 같은 규칙을 복제하므로 독립 ADR이 인용하기 쉽고, 이관 파일의 경로 참조 갱신을 독립 ADR(0015)로 남긴 선례도 있다.
- 구조 검사는 이슈 단위 명령만으로는 이후 개정이 정의 문장·적용 지점·헬퍼 호출을 깨도 알 수 없어서 둔다(#118 보류 항목 등재 선례). 호출 블록 검사는 계획 감사 발견(F-1·F-2)을 반영했다. 정의 행의 헬퍼 이름만으로는 경로 오타나 호출 행 누락을 잡지 못하고, ADR 0019는 Task의 변경을 되돌리면 실패하는 케이스를 요구한다.
- `.ai/90_issues/archive/`를 뺀 이유는 이슈 문서가 작성 시점 기록이기 때문이다. 옛 경로가 남아도 원장 index에서 번호로 찾을 수 있다. 이슈 작성 시점에 끊겨 있던 `issue-0104` 감사 리포트의 K-0011 링크 1건도 그대로 둔다.
- update-3 "기존 파일 정리"는 디렉토리 루트에 남은 옛 배치 파일만 옮기는 단계라 들어오는 링크가 거의 없다.

</details>

## 대안

<details>
<summary>상세 펼치기</summary>

- 본문에 grep 명령 한 줄을 적는 안: 옛 경로 grep은 같은 디렉토리 링크와 깊이 오계산을 잡지 못한다. 잡으려면 링크를 하나씩 풀어 확인하는 반복문이 필요해 한 줄을 넘으므로 헬퍼로 대체.
- 다른 문서에서 원장 항목을 경로 링크 없이 `K-<번호>`로만 가리키는 안: 옮겨도 끊길 링크가 없다. 대신 `60_codebase/` "관련 문서" 열의 링크 규약을 바꿔야 하고 읽는 쪽이 index를 한 번 더 거쳐야 해 들어오는 링크 갱신으로 대체.
- code-map이 원장 링크를 맞추는 안: code-map은 `70_ledger`를 다루지 않고, 맡겨도 `60_codebase/` 밖의 링크(ADR 0020)가 남아 들어오는 링크 갱신으로 대체.
- ADR 0018을 갱신하는 안: 주제가 달라 배제 (근거 참조).
- 헬퍼에 링크 자동 재작성 모드를 두는 안: 이슈가 갱신을 스킬 절차로 정했고, 검사만으로 갱신 누락과 깊이 오계산을 잡을 수 있어 불필요.

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #120 issue-work·git-pr·git-pr-feedback: 원장 항목을 archive로 옮길 때 그 항목을 가리키는 다른 문서의 링크도 갱신](https://github.com/scroogy-dev/scroogy-agent-skills/issues/120)
- 후속 복제: [Issue #121 ai-workspace·context-harvest: ADR 처리 규칙 도입 (일부 변경·대체·폐기 구분, superseded 이동 기준, 상태 표기)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/121)
- 규칙: [`architecture.md` `## 디자인 원칙`](../../10_rules/architecture.md)
- 관련 결정: [ADR 0001 결정적 헬퍼의 테스트 배치](./0001-skill-deterministic-helper-test-convention.md), [ADR 0002 스킬 독립성과 의도적 중복](./0002-skill-independence-intentional-duplication.md), [ADR 0007 원장 위치와 구조](./0007-tech-debt-ledger-location-and-structure.md), [ADR 0015 `--clear` 이관과 경로 참조 갱신](./0015-issue-clear-timing-and-archive-rules.md), [ADR 0018 원장 재검토·해소 계기](./0018-ledger-proactive-review-and-resolve-timing.md), [ADR 0019 테스트 관점과 Task별 배치](./0019-test-perspectives-and-task-level-placement.md), [ADR 0020 doc SSoT와 퍼블리싱 보류](./0020-doc-ssot-original-documents-and-publishing-deferred.md)
- 원장 항목: [K-0011 계획 감사 회귀 방지 예외](../../70_ledger/archive/K-0011-plan-audit-regression-exception-spec-only.md) (archive로 옮긴 첫 항목), [K-0014 퍼블리싱 스킬 범위 밖](../../70_ledger/active/K-0014-publishing-skill-deferred.md) (같은 디렉토리 링크를 가진 항목)

</details>
