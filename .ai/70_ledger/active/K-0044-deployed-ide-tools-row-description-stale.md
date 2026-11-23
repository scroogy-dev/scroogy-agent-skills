# K-0044: 이미 배포된 repo 안내도의 `ide-tools.md` 행 설명이 update로 갱신되지 않는다

- **유형**: known issue
- **등재일**: 2026-11-23
- **출처**: 이슈 #144 (spec 제외 보류 항목)
- **위험도**: 낮음(LOW)
- **수용 사유**: ai-workspace update-4는 안내도에 행이 있으면 사용자 행으로 보존한다. `ide-tools.md` 본문과 context-loading 코드·테스트 절은 update가 덮어써 새 실행 규칙을 읽게 되므로, 행 설명은 필요한 repo에서 직접 고치기로 했다(이슈 `검토 필요` 4를 2026-11-22 요구사항 승인에서 결정).
- **재검토 조건**: 옛 행 설명 때문에 실행 작업(테스트·커버리지·로컬 서버·디버깅)에서 IDE 도구를 놓친 사례가 나올 때, 또는 update-4의 행 보존 규칙을 바꿀 때
- **상태**: 수용

## 내용

#144 이전에 ai-workspace를 설치한 repo의 안내도에는 `ide-tools.md` 행 설명이 `코드 탐색·수정 전` 기준으로 남는다. 새 설명(실행 네 작업, 표 밖 작업은 기존 도구, `[D]`·회귀 판정은 러너 명령)은 새로 설치하거나 행이 없는 repo에만 들어간다.

## 재검토 이력

없음

<details>
<summary>근거·배경 펼치기</summary>

- **영향**: 기능 저하.
- **발생확률**: 특수 조건·엣지.
- **위험도 산출**: `classify-risk.sh --impact '기능 저하' --likelihood '특수 조건·엣지'` → 낮음(LOW).
- **채택하지 않은 대안**: update-4가 옛 표준 행과 같은 행을 새 표준 행으로 바꾸는 안. 사용자가 고친 행과 옛 표준 행을 가리는 규칙이 더 필요해 보류했다.
- 같은 이슈의 다른 보류 항목은 [K-0039](./K-0039-ide-tool-list-direct-fetch-deferred.md)·[K-0040](./K-0040-ide-tool-missing-notice-deferred.md)·[K-0041](./K-0041-ide-inspection-kts-tools-deferred.md)·[K-0042](./K-0042-ide-jvm-memory-tools-deferred.md)·[K-0043](./K-0043-ide-debug-attach-process-deferred.md)로 같은 날 등재했다.

</details>
