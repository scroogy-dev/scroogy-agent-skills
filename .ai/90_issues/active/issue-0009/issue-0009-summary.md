# Issue #9 실행요약 readme-sync 개선: LICENSE 파일 생성 옵션 + 라이선스 인식 가드

> 스펙: [issue-0009-spec.md](./issue-0009-spec.md) | 계획: [issue-0009-plan.md](./issue-0009-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task 2 — 본 저장소 NOTICE 파일 정리

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

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 3: readme-sync SKILL.md — LICENSE 파일 생성 옵션 사양 추가

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 4: readme-sync SKILL.md — 라이선스 헤더 파일명 가드 사양 추가

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

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
