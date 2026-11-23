# K-0042: IntelliJ MCP의 `jvm_debug_memory_*` 도구 4종을 규칙 표에 두지 않았다

- **유형**: 기술부채
- **등재일**: 2026-11-23
- **출처**: 이슈 #144 (spec 제외 보류 항목)
- **위험도**: 정보(INFO)
- **수용 사유**: 메모리 분석이 필요한 사례가 아직 없다. 결정 목록에 `보류`로 적어 두었다.
- **재검토 조건**: 메모리 누수·과다 사용 원인을 디버깅으로 찾아야 하는 사례가 생길 때, 또는 IntelliJ 업데이트로 결정 목록을 다시 비교할 때
- **상태**: 수용

## 내용

`jvm_debug_memory_class_snapshot`·`jvm_debug_memory_closest_gc_roots`·`jvm_debug_memory_get_instances`·`jvm_debug_memory_read_fields`는 결정 목록에 `보류`로 있고 `ide-tools.md` 디버깅 순서에 없다.

## 재검토 이력

없음

<details>
<summary>근거·배경 펼치기</summary>

- **영향**: 기술 품질 의견.
- **발생확률**: 특수 조건·엣지.
- **위험도 산출**: `classify-risk.sh --impact '기술 품질 의견' --likelihood '특수 조건·엣지'` → 정보(INFO).
- **채택하지 않은 대안**: 디버깅 순서에 메모리 분석 단계를 더하는 안. 필요한 사례 없이 절차를 정하게 되어 보류했다.
- 같은 이슈의 다른 보류 항목은 [K-0039](./K-0039-ide-tool-list-direct-fetch-deferred.md)·[K-0040](./K-0040-ide-tool-missing-notice-deferred.md)·[K-0041](./K-0041-ide-inspection-kts-tools-deferred.md)·[K-0043](./K-0043-ide-debug-attach-process-deferred.md)·[K-0044](./K-0044-deployed-ide-tools-row-description-stale.md)로 같은 날 등재했다.

</details>
