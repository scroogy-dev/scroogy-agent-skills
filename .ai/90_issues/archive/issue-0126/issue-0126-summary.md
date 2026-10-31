# Issue #126 실행요약 code-map: 호출 흐름 트리 다음에 Mermaid 시퀀스 다이어그램을 추가한다 (local·global)

> 스펙: [issue-0126-spec.md](./issue-0126-spec.md) | 계획: [issue-0126-plan.md](./issue-0126-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다.

## 모델 기록

| 구분 | 모델 | effort |
|------|------|--------|
| 계획 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | xhigh |
| 계획 audit 모델 | OpenAI, GPT-6.1 (gpt-6.1-sol) | high |
| 구현 모델 | Anthropic, Claude Opus 5.5 (claude-opus-5-5) | xhigh |
| 최종 audit 모델 | OpenAI, GPT-6.1 (gpt-6.1-sol) | high |

- **계획 감사**: 수행 · 발견 2건 · 보정 2건

---

## Task별 수행 결과

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- **결과**: 완료
- **수행 모델**: claude-opus-5-5
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: 전제 누락 없음
- **특이 사항**: 2차 계획 감사(적합, 발견 0건)를 `--response`로 검토했고, 1차 F-2 보정으로 바뀐 R6을 2026-10-31에 재승인받았다. spec·plan을 `code-map/SKILL.md`·`references/local.md`·`references/global.md`·`tests/run-tests.sh`, ADR 0023, K-0006 재검토 이력 표, `60_codebase/index.md` 부분 반영 메모, 표기 규칙 정책과 대조했다. 바꿀 문장과 DoD 리터럴이 현재 본문과 맞고, 예시에 mermaid 블록을 넣어도 러너 `sec`의 코드 펜스 상태가 맞아 기존 검사에 영향이 없다.

---

### Task 1: SKILL.md 공통 작성 규칙과 표기

- **결과**: 완료
- **수행 모델**: claude-opus-5-5
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `code-map/SKILL.md` 끝에 `## 시퀀스 다이어그램 작성 규칙`(적용 대상·역할 분담 문단과 라벨 행 8개)을 더하고, How 행·`<action>-call-flow.md` 트리 주석·정렬 규칙 적용 제외 문장을 고쳤다. 러너에 `sequence_violations`(SKILL.md 검사)와 통과 케이스 1개, 격추 20개를 더했다. spec R3 첫 항목·R4·R7 검증 출력 0건, 러너 87 통과 0 실패.
- **특이 사항**: 라벨 목록(`SEQ_LABELS`)과 라벨 행 리터럴 목록(`SEQ_ROWS`)은 배열 하나씩으로 두고 검사와 격추 12개가 같이 쓴다. 트랜잭션 경계 행은 `Note`가 범위를 감싸지 않으므로 "감싼다" 대신 "표시합니다"로 적었다(DoD 리터럴 `` `rect` 또는 `Note` ``는 그대로).

---

### Task 2: local.md 상세 흐름 구조·갱신·점검

- **결과**: 완료
- **수행 모델**: claude-opus-5-5
- **수행 effort**: xhigh
- **audit 발견**: 1건
- **보정 반영**: 1건
- **재시도**: 0회
- **수행 내용 요약**: `code-map/references/local.md` 1-4에 시퀀스 안내 문장과 build·rebuild·sync 행을 더하고, 주문 생성 예시 `## How`에 `### 시퀀스 다이어그램`과 mermaid 블록(참여자 5개, `rect`·`Note` 트랜잭션, `alt` 재고 부족·재고 있음)을 넣었다. 3단계 점검 표에 시퀀스 누락·트리·시퀀스 불일치 행을, 4단계 결과 보고에 시퀀스 건수 행을 더했다. 러너 `sequence_violations`에 local 검사와 격추 11개를 더했다. spec R1·R5·R6 첫 항목 출력 0건, R3 둘째·셋째 항목의 local 행 0건, 러너 98 통과 0 실패.
- **특이 사항**: 예시 순서·참여자·금지 문자 판정은 global 검사(Task 3)에서도 쓰도록 보조 함수(`cut_sec`·`seq_order`·`seq_parts`·`seq_chars`)로 분리했다. 예시는 Mermaid 문법대로 썼지만 이 환경에 렌더러가 없어 `[QD]` 그림 표시는 PR 화면에서 확인했다. 예시가 복사용 템플릿 블록 안에 있어 파일 화면에서는 코드로 보이므로, 두 예시를 옮긴 PR #127 리뷰 답글에서 그림으로 나오는 것을 사용자가 확인했다(2026-10-31). 최종 감사 F-1(러너가 R6의 태그 체계 표 5개 유지를 검사하지 않아 R8 부분 충족)을 `--response`에서 반영했다. `sequence_violations`에 태그 표 정확 일치 검사와 격추 4개(행 추가·삭제·태그 이름 변경·순서 변경)를 더해 러너 113 통과 0 실패, 1회 실행 약 1분 30초.

---

### Task 3: global.md 서비스 간 흐름 구조·점검

- **결과**: 완료
- **수행 모델**: claude-opus-5-5
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: `code-map/references/global.md` `## 파일 구조`의 `service-call-flows.md` 설명 줄에 흐름별 시퀀스 생성·갱신·서비스 단위 참여자·작성 규칙 링크를 잇고, 2단계 `## 사용자 로그인` 예시에 mermaid 블록(gateway·auth-service·user-service, `alt` 인증 실패·성공)을 넣었다. 4단계 `아키텍처 문서 유효성` 행에 시퀀스와 흐름 섹션 단위 판정·집계를, 5단계 결과 보고에 서비스 간 시퀀스 건수 행을 더했다. 러너에 global 검사와 격추 11개를 더했다. spec R2·R3 둘째·셋째·R6 둘째·R8 첫 항목 출력 0건, 러너 109 통과 0 실패.
- **특이 사항**: 점검 표 행 추가 격추는 `sub_str` 바꿀 문자열의 `\n`(awk `-v`가 줄바꿈으로 해석)으로 행을 끼워 넣는다. 러너 한 번 실행이 약 1분 걸려, 같은 셸에서 두 번 돌리면 도구의 120초 제한을 넘는다. `[QD]` 두 흐름 사례(A만 시퀀스 있음, 참여자 상쇄 없음)는 2차 최종 감사에서 채점했고 충족이다.

---

### Task 4: 결정 기록·원장·문서 정합

- **결과**: 완료
- **수행 모델**: claude-opus-5-5
- **수행 effort**: xhigh
- **audit 발견**: 0건
- **보정 반영**: 0건
- **재시도**: 0회
- **수행 내용 요약**: ADR 0024(`.ai/50_adr/active/0024-code-map-sequence-diagram-alongside-call-flow-tree.md`)를 쓰고 ADR index에 행을 더했다. K-0006 재검토 이력에 #126 계속 수용 행을 더했다. 문서 동기화 점검에서 README code-map 행은 갱신 불필요로 판단했다(색인 대상인 엔트리포인트·호출 흐름은 그대로이고 시퀀스 다이어그램은 같은 호출 흐름의 표현이라 한 줄 설명이 계속 맞다). `60_codebase/index.md` code-map 행은 갱신했다(ADR 0024 링크를 더하고 하단에 `#126 부분 반영` 줄을 더함, frontmatter 유지).
- **특이 사항**: ADR 0024는 공통 참조가 아닌 code-map 고유 결정이라 `60_codebase/index.md` `## 공통 참조`에는 넣지 않았다. 기존 상세 흐름 15건은 제외 범위라 바꾸지 않았다.

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

- **결과**: 완료
- **수행 내용 요약**: OpenAI GPT-6.1(gpt-6.1-sol, high)로 최종 감사 2회 수행. 1차는 조건부 적합(F-1, R8 부분 충족)이었고 `--response`로 Task 2에 반영했다. 2차는 적합(1단계 32건 충족, 2단계 발견 0건, F-1 닫힘)이다.
- **특이 사항**: Mermaid 그림 표시(Task 2 `[QD]`)는 PR #127 리뷰 답글에서 사용자가 확인했다(2026-10-31).
