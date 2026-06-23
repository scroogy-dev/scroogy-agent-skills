# Issue #23 실행요약 스킬 결정적 헬퍼 테스트 규칙 정립 및 install-skills 배포 제외

> 스펙: [issue-0023-spec.md](./issue-0023-spec.md) | 계획: [issue-0023-plan.md](./issue-0023-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다.

---

## Task별 수행 결과

### Task 1: install-skills 배포 시 개발 경로 제외 (배포 제외 동작의 SSoT)

- **결과**: 완료
- **수행 내용 요약**:
  - `install-skills/SKILL.md` 5단계 복사 명령을 `cp -r` → `rsync -a --exclude 'tests/' --exclude '*.test.*' <skill>/ <target>/<skill>/`로 변경. 이 `--exclude` 플래그가 제외 패턴의 단일 출처.
  - rsync 미가용 환경 fallback(`cp -r` 후 `rm -rf .../tests`)을 주석으로 병기.
  - 개요에 "개발 전용 경로는 배포에서 제외" 자기 동작 한 줄 추가 + ADR 링크(상대경로 `../.ai/50_adr/active/0001-...`).
- **특이 사항**:
  - ADR 링크는 Task 2에서 생성될 파일을 미리 가리킴(양방향 참조 의도). Task 2 완료 시 경로 정합 확인 필요.
  - fallback은 `tests/` 디렉토리만 제거하고 `*.test.*` 산재 파일은 미처리(가능한 범위 내 처리). 대부분 환경에 rsync 존재.

---

### Task 2: 테스트 규칙 ADR 작성 (결정·근거 기록, 메커니즘은 install-skills 참조)

- **결과**: 완료
- **수행 내용 요약**:
  - `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` 작성. frontmatter `source: github_issue`, `source_url`=이슈 #23 URL, `last_harvested: 2026-06-22`.
  - 결정: 헬퍼 `scripts/`, 테스트 `<skill>/tests/` 함께 둠(테스트 데이터 중첩), 외부 의존성 없는 경량 러너, 기대 출력·고정 입력 데이터 비교, 배포 시 tests 제외.
  - 근거: 스킬 독립성 + 점진적 공개 + 배포 용량 세 축 분리.
  - 대안(기각): 루트 중앙집중 tests / 제거 생략 / JUnit·maven 도입.
  - 제외 패턴 목록은 ADR에 복제하지 않고 install-skills를 상대경로(`../../../install-skills/SKILL.md`)로 참조.
  - `.ai/50_adr/index.md` 파일 목록에 새 ADR 행 등록.
- **특이 사항**:
  - install-skills(`../.ai/...`) ↔ ADR(`../../../install-skills/...`) 양방향 상대경로 링크 연결. Task 4에서 끊김 없는지 검증.

---

### Task 3: AI-CONTEXT.md 작성자 포인터 추가

- **결과**: 완료
- **수행 내용 요약**:
  - `.ai/AI-CONTEXT.md` "스킬 작성 규칙"에 `### 테스트 위치` 하위 절을 추가하고 포인터 한 줄 기재: 테스트는 `<skill>/tests/`에 함께 둠(테스트 데이터 중첩), install-skills 배포 시 제외 → install-skills(`../install-skills/SKILL.md`)·ADR(`50_adr/active/0001-...`) 참조.
  - README.md는 의도적 미반영(readme-sync 재생성 리스크) — 스펙 비포함 항목과 일치.
- **특이 사항**: 없음.

---

### Task 4: 정합성 검증

- **결과**: 완료
- **수행 내용 요약**:
  - install-skills 절차 검증: step 5 rsync는 generic placeholder(`<target-dir>`/`<skill-name>`)로 동작 → `--claude`/`--agents`/`--antigravity`/`--codex`/`--junie`/`--all` 모든 경로에 동일 적용. step 2 `--clear`(`rm -rf <target>/*`)와 독립, 개별 설치(step 3 선택)와도 모순 없음. `rm -rf <target>/<skill>` 선행으로 "클린 설치" 의미 유지.
  - 참조 무결성: install-skills↔ADR↔AI-CONTEXT 상대경로 링크 4개 모두 실제 파일로 해석됨(스크립트 검증).
  - 단일 출처: `--exclude` 패턴 리터럴은 install-skills/SKILL.md 64행에만 존재. ADR·AI-CONTEXT에 rsync/--exclude 복제 없음(grep 0건).
  - DoD 5개 항목 전부 충족 → spec 체크박스 갱신.
- **특이 사항**: 없음.
