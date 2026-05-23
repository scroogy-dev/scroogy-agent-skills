# Issue #9 실행요약 readme-sync 개선: LICENSE 파일 생성 옵션 + 라이선스 인식 가드

> 스펙: [issue-0009-spec.md](./issue-0009-spec.md) | 계획: [issue-0009-plan.md](./issue-0009-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task 5 — 링크 무결성 경고 흐름 통합

---

## Task별 수행 결과

### Task 1: 본 저장소 LICENSE-HEADER.txt 인식 문제 해소

- **결과**: 완료
- **수행 내용 요약**:
  - `LICENSE-HEADER.txt` → `LICENSE_HEADER.txt`로 `git mv` 리네임 (히스토리 보존). 하이픈을 언더스코어로 바꿔 GitHub Licensee의 `LICENSE-*` 매칭에서 벗어나면서도 파일 용도는 즉시 식별되도록 함.
  - 활성 참조 3곳 갱신: `README.md`, `readme-sync/SKILL.md`, `readme-sync/templates/README-template.md`.
  - `readme-sync/SKILL.md` 동반 파일 표에는 `LICENSE_HEADER.txt`로 교체하면서 "`LICENSE-*` 하이픈 패턴은 GitHub 라이선스 인식기 오인 위험으로 회피, 언더스코어 사용"이라는 짧은 근거를 함께 명시. (Task 4에서 사양 본문에 더 자세히 다룸.)
- **특이 사항**:
  - 아카이브된 이슈 문서(`issue-0001`, `issue-0007`)의 `LICENSE-HEADER.txt` 언급은 히스토리이므로 손대지 않음.
  - 완료 기준의 "GitHub About 영역 `Apache-2.0` 표기"는 main에 머지된 뒤 확인이 가능. Task 7에서 머지 후 재검증.

---

### Task 2: 본 저장소 NOTICE 파일 정리

- **결과**: 완료
- **수행 내용 요약**:
  - NOTICE의 라이선스 본문 발췌(L4~L14)를 제거하고 프로젝트명·Copyright 두 줄만 유지.
  - 의도: Apache 2.0 §4(d)는 NOTICE에 적힌 attribution을 재배포물에 보존하도록 강제하므로, attribution 외 내용을 두면 §4(d) 보존 범위가 모호해진다. 두 줄로 좁혀 보존 범위를 명확히 함.
- **특이 사항**:
  - 본 저장소가 외부 Apache 2.0 라이브러리를 의존하지 않으므로 외부 attribution 라인은 추가하지 않음. 향후 그런 의존이 생기면 NOTICE에 해당 attribution을 추가해야 함.

---

### Task 3: readme-sync SKILL.md — LICENSE 파일 생성 옵션 사양 추가

- **결과**: 완료
- **수행 내용 요약**:
  - 사용법·인자 표에 `--force-license` 플래그 추가 (init + Q1=(a) 전용 명시).
  - init-2단계 Q1 아래에 Q1-1 (라이선스 종류: Apache 2.0 / MIT), Q1-2 (LICENSE 파일 생성 여부) 하위 질문 신설. 기존 LICENSE가 있으면 Q1-2 자체를 묻지 않고 스킵.
  - init-4단계에 "LICENSE/NOTICE 파일 생성" 단계를 1번 자리에 끼움. 링크 무결성 점검은 새 흐름과 분기되어 작동하도록 문구 정리 (Task 5에서 마무리).
  - `## 라이선스·개인 저작물 고지 옵션` 하위에 두 절 신설:
    - `### LICENSE 파일 생성 규칙` — 조건별 동작 표(없음/동일/다른). Apache 2.0이면 NOTICE 동반 생성, MIT은 NOTICE 미생성.
    - `### --force-license 플래그` — 가드 3종(동일 무동작·외부 기여자 경고·대화형 확인) + 결과 보고.
  - "스킬은 LICENSE 파일을 새로 만들지 않습니다" 기존 문구를 새 사양과 정합되는 문장으로 교체 (기본 스킵 + `--force-license` 덮어쓰기).
- **특이 사항**:
  - `--force-license`는 `init` 모드 전용으로 한정. `update` 모드는 말미 블록을 보존하는 정책이라 라이선스 변경은 init 흐름을 재호출하는 게 자연스러움.
  - 외부 기여자 판정은 `git log`에 본인 외 author 존재 여부로 간단화. 정교한 LICENSE 파일 단독 history 추적은 비포함 (현 단계 사양에는 비대화형 환경의 자동 동의 경로를 만들지 않음).

---

### Task 4: readme-sync SKILL.md — 라이선스 헤더 파일명 가드 사양 추가

- **결과**: 완료
- **수행 내용 요약**:
  - `## 라이선스·개인 저작물 고지 옵션` 하위에 `### 라이선스 헤더 파일명 가드` 신설:
    - 배경: GitHub Licensee가 `LICENSE-*` 하이픈 패턴을 라이선스 후보로 잡지만 헤더 발췌는 매칭 실패해 "Unknown licenses found" 유발.
    - 명명 규칙 후보 3종: `LICENSE_HEADER.txt`(언더스코어), `.license-header.txt`(도트), `HEADER.txt`(단순).
    - 기존 파일 감지·권유 흐름: `init-1단계`(및 `update`)에서 `LICENSE-HEADER.txt` 등 비표준 `LICENSE-*` 파일을 감지하면 `git mv` 리네임을 권유하고 README 참조 링크 동반 갱신을 안내. 사용자가 거부하면 권유만 남기고 진행.
  - init-1단계 프로젝트 분석 항목에 "`LICENSE-*` 하이픈 패턴 비표준 파일 존재 여부" 추가.
  - 라이선스 표시 3분기 표의 동반 파일 셀에 들어있던 긴 인라인 설명을 신설 절로 위임하고 표는 짧게 정리.
- **특이 사항**:
  - 자동 리네임은 일부러 하지 않음 — 외부 참조(다른 도구·문서)가 깨질 수 있어 사용자 동의·확인 후 변경이 원칙.

---

### Task 5: 링크 무결성 경고 흐름 통합

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 6: 본 저장소에 readme-sync 셀프 적용 검증

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 7: DoD 점검 및 이슈 종료 준비

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:
