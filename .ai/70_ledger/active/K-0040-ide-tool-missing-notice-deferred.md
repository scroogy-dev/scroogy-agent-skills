# K-0040: IntelliJ MCP는 연결됐는데 규칙 표의 도구를 찾지 못해도 사용자에게 알리는 단계가 없다

- **유형**: known issue
- **등재일**: 2026-11-23
- **출처**: 이슈 #144 (spec 제외 보류 항목)
- **위험도**: 낮음(LOW)
- **수용 사유**: 도구 이름이 바뀌거나 빠지는 일은 IntelliJ 업데이트 때 생기고, 그때 결정 목록을 목록 대조 헬퍼로 다시 비교하는 절차가 ADR 0030에 있다. 이름 변경 때문에 IDE 도구를 놓친 사례가 아직 없다.
- **재검토 조건**: 도구 이름 변경으로 IDE 도구를 쓰지 못하고 기존 도구로 넘어간 사례가 나올 때, 또는 `ide-tools.md`의 기존 도구 전환 조건을 바꿀 때
- **상태**: 수용

## 내용

`ide-tools.md`는 IntelliJ MCP가 연결되지 않았을 때 기존 도구로 넘어가는 조건을 둔다. 연결은 됐지만 표에 적은 도구 이름이 IntelliJ 업데이트로 바뀌거나 빠졌을 때 그 사실을 사용자에게 알리는 단계는 없어, 조용히 기존 도구로 작업할 수 있다.

## 재검토 이력

없음

<details>
<summary>근거·배경 펼치기</summary>

- **영향**: 기능 저하.
- **발생확률**: 특수 조건·엣지.
- **위험도 산출**: `classify-risk.sh --impact '기능 저하' --likelihood '특수 조건·엣지'` → 낮음(LOW).
- **채택하지 않은 대안**: 규칙에 "표의 도구를 찾지 못하면 사용자에게 알린다"는 문장을 더하는 안. 이름 변경은 업데이트 때 헬퍼로 잡히므로 사례가 나온 뒤 보기로 했다.
- 같은 이슈의 다른 보류 항목은 [K-0039](./K-0039-ide-tool-list-direct-fetch-deferred.md)·[K-0041](./K-0041-ide-inspection-kts-tools-deferred.md)·[K-0042](./K-0042-ide-jvm-memory-tools-deferred.md)·[K-0043](./K-0043-ide-debug-attach-process-deferred.md)·[K-0044](./K-0044-deployed-ide-tools-row-description-stale.md)로 같은 날 등재했다.

</details>
