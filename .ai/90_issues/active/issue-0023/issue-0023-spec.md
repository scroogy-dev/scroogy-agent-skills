# Issue #23 스펙 스킬 결정적 헬퍼 테스트 컨벤션 정립 및 install-skills strip

## 목표 (Goal)

스킬에 결정적 헬퍼(`scripts/`)가 도입될 때 따를 **테스트 co-locate 컨벤션을 ADR로 확정**하고, **install-skills가 배포 시 dev 전용 경로(`tests/`)를 제외**하도록 한다.

---

## 범위 (Scope)

**포함 (In)**

- `install-skills/SKILL.md`의 복사 단계(`cp -r`)를 dev 경로 제외 복사로 변경 — **배포 제외 동작의 SSoT**. 제외 패턴 목록은 이 파일에만 둔다.
- `.ai/50_adr/active/`에 ADR 1건 작성(결정·근거·기각안, 메커니즘은 install-skills 참조) 및 `50_adr/index.md` 등록
- `.ai/AI-CONTEXT.md` "스킬 작성 규칙"에 테스트 위치·배포 제외 포인터 한 줄 추가 (→ install-skills, ADR)

**비포함 (Out)**

- 실제 `scripts/` 헬퍼나 `tests/`·fixtures 파일 추가 (헬퍼가 처음 생기는 시점에 별도 이슈)
- pytest 등 러너 설치·CI 파이프라인 구성
- 스킬 행동 평가(eval) 체계 — 결정적 단위 테스트와 별개 분야
- `README.md` 반영 — `readme-sync`가 재생성하는 파일이라 **의도적 제외** (필요 시 별도 이슈로 readme-sync 확장)

---

## 완료의 정의 (Definition of Done)

- [ ] `install-skills/SKILL.md`의 복사 단계가 `tests/`를 제외하도록 변경되고(배포 제외 동작의 SSoT), 자기 동작을 한 줄로 명시한다. 제외 패턴 목록은 이 파일에만 둔다.
- [ ] ADR이 `.ai/50_adr/active/`에 존재하고 **결정·근거·기각안**을 기재하며, 메커니즘은 install-skills를 **참조**한다(패턴 목록 미복제).
- [ ] `50_adr/index.md`에 새 ADR이 등록된다.
- [ ] `.ai/AI-CONTEXT.md` "스킬 작성 규칙"에 테스트 위치·배포 제외 포인터 한 줄이 추가된다(install-skills·ADR 참조).
- [ ] 변경된 install-skills 절차가 기존 동작(`--claude`/`--all`/`--clear`/개별 설치)과 모순되지 않는다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/50_adr/index.md` | 새 ADR 등록 대상 |
| `install-skills/SKILL.md` | 변경 대상 (설치 절차 5단계 `cp -r`) |
| `.ai/AI-CONTEXT.md` (스킬 작성 규칙 · 스킬 독립성) | 컨벤션 정합성 근거 |
| `context-harvest/templates/50_adr-template.md` | ADR 포맷 참조 |
