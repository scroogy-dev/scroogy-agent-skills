# K-0033: git-pr·git-pr-feedback 헬퍼가 정규화에 실패한 원격 URL의 원문을 위반 행에 적는다

- **유형**: known issue
- **등재일**: 2026-11-22
- **출처**: 이슈 #142 / audit 발견 F-14 (최종 감사 4차)
- **위험도**: 중간(MEDIUM)
- **수용 사유**: 이슈 #142는 git-review 범위이고 두 헬퍼는 이 브랜치 전부터 있던 코드다. 고치려면 두 헬퍼의 위반 행 4곳과 알 수 없는 인자 행 2곳을 바꾸고 git-pr·git-pr-feedback 러너에 케이스를 더해야 해 이슈 범위를 넘는다(2026-11-22 사용자 결정). 원문이 나오려면 URL이 정규화에 실패하고 그 URL에 자격 증명까지 들어 있어야 해 발생확률이 낮다.
- **재검토 조건**: `git-pr/scripts/verify-submit.sh`나 `git-pr-feedback/scripts/verify-push.sh`의 정규화 함수·위반 메시지·인자 처리를 고칠 때, `git-review/scripts/resolve-target.sh`와 정규화 함수 사본을 맞출 때, 또는 위반 행이나 오류 행에 자격 증명이 든 URL이 나온 사례 관측 시
- **상태**: 수용

## 내용

`git-pr/scripts/verify-submit.sh`(85행)와 `git-pr-feedback/scripts/verify-push.sh`(90·128·146행)는 원격 URL을 `호스트/소유자/저장소`로 정규화하지 못하면 위반 행에 URL 원문을 그대로 적고, 알 수 없는 인자 오류(각 76·81행)도 인자 원문을 표준 오류에 적는다. push URL은 `verify-push.sh` 안에서만 조회하므로, 자격 증명이 든 push URL이 정규화에 실패하면 그 자격 증명이 위반 행으로 처음 드러난다. 계약 `github-integration.md`의 "표시할 때는 userinfo를 제거한다"와 git-pr-feedback 승인 정보의 표시 규칙에 어긋난다.

## 재검토 이력

없음

<details>
<summary>근거·배경 펼치기</summary>

- **관측**: 이슈 #142 최종 감사 4차의 F-14(저장소 대조 헬퍼 `resolve-target.sh`가 실패 사유에 입력 값 원문을 적음)를 반영하면서, 정규화 함수 사본의 원본인 두 헬퍼에 같은 패턴이 있음을 코드를 읽어 확인했다. 실행해 재현하지는 않았다.
- **영향**:
  - push URL 사례(`verify-push.sh` 146행): 스펙·기능 달성 차단. 헬퍼 밖에서 표시하지 않는 URL이라 자격 증명이 위반 행으로 처음 나온다.
  - 나머지 사례: 기능 저하. git-pr 1단계와 git-pr-feedback의 대상 저장소 확정이 `git remote get-url`로 fetch URL을 먼저 출력하고, `--normalize` 입력과 인자는 호출 명령줄에 들어 있어 오류 행이 새로 드러내는 정보가 없다.
- **발생확률**: 특수 조건·엣지. 정규화는 `://` 형식이나 scp 문법(`git@호스트:소유자/저장소`)이고 호스트 뒤 경로에 `/`가 있으면 성공하며, 성공하면 사용자 정보를 지운 표기만 낸다. 원문이 나오려면 경로가 한 단계뿐이거나 형식이 맞지 않는 URL에 자격 증명까지 들어 있어야 한다.
- **위험도 산출**: `classify-risk.sh --impact '스펙·기능 달성 차단' --likelihood '특수 조건·엣지'` → 중간(MEDIUM). 나머지 사례만 보면 `--impact '기능 저하'`로 낮음(LOW)이며, 항목 등급은 높은 쪽을 쓴다.
- **이슈 #142에서 고친 쪽**: `git-review/scripts/resolve-target.sh`는 실패 사유에 어느 입력이 틀렸는지와 기대 형식만 적고, 알 수 없는 인자는 옵션 이름 형식일 때만 이름을 적는다(커밋 `09aca45`). 정규화 함수는 사본 관계를 지키려고 바꾸지 않았다.
- **채택하지 않은 대안**: 이슈 #142에서 함께 고치는 안은 git-pr·git-pr-feedback으로 범위를 넓히는 확장이라 이슈 본문 AC 추가와 재승인이 필요해 택하지 않았다.
- **고칠 때의 방향**: `resolve-target.sh` 4차 보정과 같이 위반 행에는 어느 URL(fetch URL·push URL·`--normalize` 입력)이 정규화되지 않았는지와 기대 형식만 적는다. `verify-submit.sh`의 push URL 대조를 다루는 [K-0012](K-0012-git-pr-push-url-unverified.md)와 함께 볼 수 있다.

</details>
