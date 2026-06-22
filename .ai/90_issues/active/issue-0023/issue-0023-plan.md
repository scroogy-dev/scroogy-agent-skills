# Issue #23 실행계획 스킬 결정적 헬퍼 테스트 컨벤션 정립 및 install-skills strip

> 스펙: [issue-0023-spec.md](./issue-0023-spec.md)

> SSoT 원칙: 배포 제외 **동작**의 원천은 `install-skills/SKILL.md`(소스). ADR은 **결정·근거**를, AI-CONTEXT는 **작성자 포인터**를 두고 둘 다 install-skills를 참조한다. 제외 패턴 목록은 install-skills 한 곳에만 둔다.

---

## Tasks

> AI가 순서대로 실행할 작업 단위를 정의합니다.
> 각 작업은 독립적으로 검증 가능해야 합니다.

### Task 1: install-skills 배포 시 dev 경로 strip (배포 제외 동작의 SSoT)

- [ ] 완료
- **목표**: 설치 아티팩트에서 `tests/`를 제외한다. 이 변경이 배포 제외 동작의 단일 원천이 된다.
- **작업 내용**:
  1. `install-skills/SKILL.md` "설치 절차" 5단계의 `cp -r <skill> <target>/`를 제외 복사로 변경: `rsync -a --exclude 'tests/' --exclude '*.test.*' <skill>/ <target>/<skill>/`.
  2. rsync 미가용 환경 대비 fallback(예: `cp -r` 후 `rm -rf <target>/<skill>/tests`) 병기 여부 검토 후 반영.
  3. 개요/참고에 "배포 시 `tests/` 등 dev 전용 경로 제외" **자기 동작**을 한 줄 명시(ADR 링크). 제외 패턴 목록은 이 파일에만 둔다.
- **완료 기준**: 복사 단계가 `tests/`를 배포에서 제외하고, 자기 동작이 한 줄로 명시됨.

---

### Task 2: 테스트 컨벤션 ADR 작성 (결정·근거 기록, 메커니즘은 install-skills 참조)

- [ ] 완료
- **목표**: 이미 내려진 결정을 기록한다. 소스(install-skills)에서 드러나지 않는 why·기각안을 남긴다.
- **작업 내용**:
  1. `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` 작성 (`context-harvest/templates/50_adr-template.md` 포맷: 결정 / 근거 / 대안 / 원본 출처, frontmatter `source: github_issue`, `source_url`=이슈 #23 URL).
  2. **결정**: 헬퍼는 `scripts/`, 테스트는 `<skill>/tests/`에 co-locate(fixtures `tests/` 안에 중첩) · 스크립트 언어에 맞춘 경량 러너(zero-dependency 지향) · golden/fixture 테스트 · 배포 시 `tests/` strip.
  3. **근거**: 스킬 독립성 + progressive disclosure(번들 리소스는 읽기 전까지 컨텍스트 비용 0) + 배포 풋프린트(install-skills `cp -r`는 통째 복사) 의 세 축 분리.
  4. **기각안**: 루트 중앙집중 `tests/`(독립성 깨짐) · 테스트 미배포(strip 안 함, 풋프린트 부담) · JUnit/maven 도입(헬퍼 규모 대비 과함).
  5. "무엇을 어떻게 제외하는지"는 **`install-skills/SKILL.md`를 참조**로 가리킨다 — 제외 패턴 목록을 ADR에 복제하지 않는다(drift 방지).
  6. `.ai/50_adr/index.md` 파일 목록에 새 ADR 등록.
- **완료 기준**: ADR 파일(결정·근거·기각안 + install-skills 참조) 존재 + index 등록.

---

### Task 3: AI-CONTEXT.md 작성자 포인터 추가

- [ ] 완료
- **목표**: 스킬 작성자(에이전트)가 첫 안내도에서 테스트 위치·배포 제외를 알게 한다.
- **작업 내용**:
  1. `.ai/AI-CONTEXT.md` "스킬 작성 규칙"에 포인터 한 줄 추가: "테스트는 `<skill>/tests/`에 두며(fixtures 중첩), `install-skills` 배포 시 제외됨 → `install-skills/SKILL.md`, ADR".
  2. `README.md`는 반영하지 않는다(`readme-sync` 재생성 리스크) — 의도적 제외임을 summary에 기록.
- **완료 기준**: AI-CONTEXT에 포인터 한 줄 추가, install-skills·ADR 참조.

---

### Task 4: 정합성 검증

- [ ] 완료
- **목표**: 변경이 기존 동작·문서와 모순되지 않음을 확인한다.
- **작업 내용**:
  1. install-skills 절차가 `--claude`/`--agents`/`--all`/`--clear`/개별 설치와 모순 없는지 검토.
  2. ADR ↔ install-skills ↔ AI-CONTEXT 참조가 끊김 없이 연결되는지 확인(패턴 목록은 install-skills 단일 출처 유지).
- **완료 기준**: 스펙의 DoD 전 항목 충족.
