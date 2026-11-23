# K-0043: IntelliJ MCP의 `xdebug_attach_to_process`를 규칙 표에 두지 않았다

- **유형**: 기술부채
- **등재일**: 2026-11-23
- **출처**: 이슈 #144 (spec 제외 보류 항목)
- **위험도**: 정보(INFO)
- **수용 사유**: 밖에서 띄운 프로세스에 디버그 에이전트가 있어야 붙일 수 있어 쓰는 조건이 좁다. 결정 목록에 `보류`로 적어 두었다.
- **재검토 조건**: IDE 밖에서 띄운 프로세스를 디버깅해야 하는 사례가 생길 때, 또는 IntelliJ 업데이트로 결정 목록을 다시 비교할 때
- **상태**: 수용

## 내용

`ide-tools.md` 디버깅은 `xdebug_start_debugger_session`으로 IDE에서 세션을 시작하는 경로만 둔다. 이미 떠 있는 프로세스에 붙는 `xdebug_attach_to_process`는 결정 목록에 `보류`로 있다.

## 재검토 이력

없음

<details>
<summary>근거·배경 펼치기</summary>

- **영향**: 기술 품질 의견.
- **발생확률**: 특수 조건·엣지.
- **위험도 산출**: `classify-risk.sh --impact '기술 품질 의견' --likelihood '특수 조건·엣지'` → 정보(INFO).
- **채택하지 않은 대안**: 디버깅 순서에 붙이기 경로를 더하는 안. 디버그 에이전트 옵션으로 띄우는 절차까지 정해야 해서 보류했다.
- 같은 이슈의 다른 보류 항목은 [K-0039](./K-0039-ide-tool-list-direct-fetch-deferred.md)·[K-0040](./K-0040-ide-tool-missing-notice-deferred.md)·[K-0041](./K-0041-ide-inspection-kts-tools-deferred.md)·[K-0042](./K-0042-ide-jvm-memory-tools-deferred.md)·[K-0044](./K-0044-deployed-ide-tools-row-description-stale.md)로 같은 날 등재했다.

</details>
