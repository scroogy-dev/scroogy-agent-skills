# K-0012: git-pr의 push 전 원격 대조가 fetch URL만 정규화해 push URL을 대조하지 않는다

- **유형**: known issue
- **등재일**: 2026-10-10
- **출처**: PR #111 코멘트 스레드
- **위험도**: 낮음(LOW)
- **수용 사유**: `remote.<이름>.pushurl`을 fetch URL과 다르게 따로 설정하는 구성은 드물어 발생확률이 낮다. push 직전에 대상 원격·브랜치·SHA를 승인받으므로 작성자가 확인할 기회도 있다. 고치려면 `verify-submit.sh`에 push URL 대조 모드를 더하고 테스트·SKILL.md 4단계 명령을 함께 바꿔야 해, 원장 재검토 계기를 다룬 이슈 #110 범위를 넘는다.
- **재검토 조건**: git-pr 4단계의 push 절차(PR 생성 전 push, 원장 해소 기재 push) 또는 `git-pr/scripts/verify-submit.sh`의 원격 대조 모드를 실질 변경할 때. 또는 push URL이 fetch URL과 다른 원격으로 git-pr을 실행한 사례 관측 시.
- **상태**: 수용

## 내용

git-pr 4단계는 push 전에 `verify-submit.sh --normalize "$(git remote get-url '<원격>')"`로 fetch URL만 정규화해 승인한 대상 저장소와 대조한다. `git push`는 push URL 전체로 게시하므로, push URL이 다른 저장소를 가리키거나 복수로 설정돼 있으면 승인한 커밋이 승인하지 않은 저장소에도 게시된다. PR 생성 후 원장 해소 기재 push도 같은 절차를 따르며, 원격 head를 `--force-with-lease`로 고정하지 않는다.

## 재검토 이력

없음

<details>
<summary>근거·배경 펼치기</summary>

- **발생확률**: 낮음. 개인 저장소에서 `pushurl`을 따로 두는 구성은 드물고, git-pr은 원격 이름과 fetch URL을 승인 시점과 실행 직전에 두 번 대조한다.
- **영향도**: 중간. 발생하면 승인한 커밋이 다른 저장소로 공개되며 되돌릴 수 없다.
- **계약과의 관계**: `.ai/30_contract/github-integration.md`는 push 전에 `git remote get-url --push --all`로 push URL이 정확히 1개이고 fetch·push URL 모두 대상 저장소와 일치하는지 확인하도록 정한다. git-pr-feedback은 `verify-push.sh`로 이를 지키지만, git-pr은 이슈 #110 이전부터 fetch URL만 대조했다. 이번 PR의 원장 해소 기재 push는 그 기존 절차를 그대로 따른다.
- **채택하지 않은 대안**: `verify-submit.sh`에 `verify-push.sh`와 같은 push URL 대조를 더하고, 원장 해소 기재 push에 `--force-with-lease`를 붙이는 안. 헬퍼 인터페이스·테스트·SKILL.md 명령이 함께 바뀌어 별도 작업으로 다루는 편이 맞다.

</details>
