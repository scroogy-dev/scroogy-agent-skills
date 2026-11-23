# K-0041: IntelliJ MCP의 inspection.kts 도구 6종과 `generate_psi_tree`를 규칙 표에 두지 않았다

- **유형**: 기술부채
- **등재일**: 2026-11-23
- **출처**: 이슈 #144 (spec 제외 보류 항목)
- **위험도**: 정보(INFO)
- **수용 사유**: 직접 만든 검사로 구조 검색에 쓸 수 있지만 써 본 경험이 없다. 결정 목록에 `보류`로 적어 두었고, 쓸 사례를 겪은 뒤 표에 둘지 정한다.
- **재검토 조건**: 구조 검색이나 사용자 정의 검사가 필요한 작업에서 이 도구를 써 본 사례가 생길 때, 또는 IntelliJ 업데이트로 결정 목록을 다시 비교할 때
- **상태**: 수용

## 내용

`compile_inspection_kts`·`generate_inspection_kts_api`·`generate_inspection_kts_examples`·`run_inspection_kts`·`run_inspection_kts_examples`·`run_inspection_kts_project`와 `generate_psi_tree`는 결정 목록에 `보류`로 있고 `ide-tools.md` 표에 없다. 표에 없는 작업은 기존 도구를 쓴다.

## 재검토 이력

없음

<details>
<summary>근거·배경 펼치기</summary>

- **영향**: 기술 품질 의견.
- **발생확률**: 특수 조건·엣지.
- **위험도 산출**: `classify-risk.sh --impact '기술 품질 의견' --likelihood '특수 조건·엣지'` → 정보(INFO).
- **채택하지 않은 대안**: 표에 "구조 검색" 행을 두고 이 도구들을 넣는 안. 사용 절차를 경험 없이 정하게 되어 보류했다.
- 같은 이슈의 다른 보류 항목은 [K-0039](./K-0039-ide-tool-list-direct-fetch-deferred.md)·[K-0040](./K-0040-ide-tool-missing-notice-deferred.md)·[K-0042](./K-0042-ide-jvm-memory-tools-deferred.md)·[K-0043](./K-0043-ide-debug-attach-process-deferred.md)·[K-0044](./K-0044-deployed-ide-tools-row-description-stale.md)로 같은 날 등재했다.

</details>
