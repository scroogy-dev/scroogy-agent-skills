# K-0039: 목록 대조 헬퍼가 IntelliJ MCP 서버의 `tools/list`를 직접 호출하지 않고 사람이 모은 목록 파일로 대조한다

- **유형**: 기술부채
- **등재일**: 2026-11-23
- **출처**: 이슈 #144 (spec 제외 보류 항목)
- **위험도**: 낮음(LOW)
- **수용 사유**: IntelliJ가 켜져 있어야 하고 MCP 서버 연결 절차가 헬퍼에 더 필요하다. 지금은 AI 도구의 지연 도구 목록에서 이름을 모아 목록 파일(`ai-workspace/tests/fixtures/ide-tool-list/intellij-mcp-tools.txt`)로 두고 `check-ide-tool-list.sh`로 대조하며, 수집 방법은 결정 목록에 적혀 있다. 수집이 번거로운지 경험해 보고 판단하기로 했다.
- **재검토 조건**: IntelliJ 업데이트 때 목록 수집이 번거로워 대조를 미룬 사례가 나올 때, 또는 `check-ide-tool-list.sh`의 입력 방식을 바꿀 때
- **상태**: 수용

## 내용

IntelliJ 업데이트 뒤 결정 목록을 실제 도구와 다시 비교하려면 사람이(또는 AI가 세션의 도구 목록에서) 도구 이름을 모아 목록 파일을 갱신해야 한다. 헬퍼가 MCP 서버에서 목록을 직접 받는 기능은 없다.

## 재검토 이력

없음

<details>
<summary>근거·배경 펼치기</summary>

- **영향**: 기술 품질 의견.
- **발생확률**: 통상 사용.
- **위험도 산출**: `classify-risk.sh --impact '기술 품질 의견' --likelihood '통상 사용'` → 낮음(LOW).
- **채택하지 않은 대안**: 헬퍼가 MCP 서버에 직접 연결해 `tools/list`를 호출하는 안. IntelliJ 실행과 연결 설정이 테스트 실행 조건이 되어 배포 제외 테스트가 환경에 묶인다.
- 같은 이슈의 다른 보류 항목은 [K-0040](./K-0040-ide-tool-missing-notice-deferred.md)·[K-0041](./K-0041-ide-inspection-kts-tools-deferred.md)·[K-0042](./K-0042-ide-jvm-memory-tools-deferred.md)·[K-0043](./K-0043-ide-debug-attach-process-deferred.md)·[K-0044](./K-0044-deployed-ide-tools-row-description-stale.md)로 같은 날 등재했다.

</details>
