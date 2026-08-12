# K-0001: ai-workspace update-3 "기존 파일 정리"에 회귀 fixture가 없다

- **유형**: 기술부채
- **등재일**: 2026-08-03
- **출처**: 이슈 #61 / audit 발견 F-1
- **위험도**: 낮음(LOW)
- **수용 사유**: 발생확률이 낮고 영향도는 중간이나 되돌릴 수 있는 종류(파일 이동뿐, 위치 복구로 해소)여서 종합 위험도가 낮으며, 막으려면 이 이슈 범위를 넘는 작업이 필요하다. update-3에는 애초에 fixture 관례가 없다. `tests/fixtures/update4-idempotent/`는 이슈 #41 audit F-3 반영으로 update-4단계에만 도입된 것이다. 이번에 닫은 규칙은 `70_ledger/` 전용이 아니라 모든 디렉토리의 루트 상주 파일 제외이므로, fixture를 만든다면 `50_adr/`·`40_domain/`·`90_issues/`까지 함께 커버해야 대칭이 맞고 그것은 원장 도입 범위 밖이다. 규칙 자체는 SKILL.md 본문에 명시돼 있어 현재 동작은 올바르며, 노출되는 것은 이후 문구가 바뀔 때의 회귀 검출뿐이다.
- **재검토 조건**: `ai-workspace/SKILL.md` update-3단계의 이동 판단 기준 또는 루트 상주 파일 제외 규칙을 다시 수정할 때. 또는 update-3 전체 fixture 도입을 별도 이슈로 착수할 때.
- **상태**: 수용

## 내용

`ai-workspace/SKILL.md` update-3단계의 "이동 제외 — 루트 상주 파일" 규칙(각 디렉토리 `index.md`, `40_domain/glossary.md`)에 대응하는 실행 fixture가 `ai-workspace/tests/`에 없다. 규칙이 문서 본문에만 있어, 이후 update-3 문구가 바뀌어 `70_ledger/index.md`가 다시 `active/`나 `legacy/`로 밀려도 기존 테스트가 회귀를 검출하지 못한다. 검출 실패 시 원장·ADR·도메인 index가 이동해 `context-loading.md`가 가리키는 공통 진입점이 깨진다.

## 재검토 이력

없음

<details>
<summary>근거·배경 펼치기</summary>

- **발생확률**: 낮음. update-3 이동 규칙을 다시 손대는 일 자체가 드물고, 손댈 때는 이 규칙 문단이 판단 기준 표 바로 위에 있어 눈에 들어온다.
- **영향도**: 중간. 깨지면 index가 사라진 것처럼 보이나 파일은 이동만 되므로 데이터 손실은 없고, 위치를 되돌리면 복구된다.
- **채택하지 않은 대안**: `70_ledger/` 한 행만 fixture로 고정하는 안. 이웃 3건(`50_adr/index.md`, `40_domain/index.md`, `40_domain/glossary.md`)이 같은 규칙에 의존하는데 한 건만 덮으면 비대칭 방어가 되어 실익이 낮다.
- **판정 수단의 한계**: update-4 fixture도 README에 `[QD]`(AI가 채점)로 명시돼 있어, fixture를 만들어도 결정적 판정이 되지 않는다. 감사 리포트가 요구한 "자동 판정"은 이 repo의 fixture 관례로는 성립하지 않는다.
- **경위**: 이슈 #61 audit 1차에서 F-1(중간(MEDIUM), 기능 결함)로 보고돼 루트 상주 파일 일반 제외 규칙으로 닫혔고, 2차에서 회귀 검증 부분이 낮음(LOW) 잔여로 남아 `--response` 검토에서 이관하기로 확정했다.

</details>
