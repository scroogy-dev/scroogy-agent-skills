# Issue #17 스펙 git-pr 스킬에 문서 동기화 점검 단계 추가

## 목표 (Goal)

git-pr 작성 시 브랜치 diff를 보고 README·AI-CONTEXT·code-map의 drift를 감지해 PR에 갱신 권고를 남기는 "문서 동기화 점검" 단계를 `git-pr/SKILL.md`에 추가한다.

---

## 범위 (Scope)

**포함 (In)**

- `git-pr/SKILL.md`에 "문서 동기화 점검" 단계 추가
- **절차 순서**: 이 단계는 PR 초안 작성이 끝난 뒤 마지막 패스(후속조치)로 1회 수행 — PR 작성 본류 흐름을 끊지 않음
- drift 감지 규칙 테이블 작성 (diff 신호 → 의심 문서 → 권고 스킬)
- **각 규칙 행은 해당 diff 신호가 있을 때만 권고를 냄** (코드 변경 없는 PR이면 code-map 행은 켜지지 않는 식으로 자연 처리)
- 기존 code-map drift 힌트 처리: `SKILL.md:100`의 drift 권고("색인과 실제 코드가 다르면 `/code-map` 의견")**만** 후속조치 단계의 code-map 행으로 흡수해 중복 제거. `SKILL.md:99`의 작성 지침("실제 코드로 작성")은 호출 흐름 블록에 **유지**
- 출력 형식 정의: PR 메시지에 갱신 권고만 표기 (flag-only 기본)
- 승인형 tier(선택) 기술: git-pr 도중 해당 스킬 실행 여부 질의 후 같은 PR 반영
- skill-creator 감사 findings 반영 (사용자 결정: 전부 이 이슈에 포함):
  - P4: "문서 동기화 점검" 섹션 축약 (drift 표·승인형 tier 등 DoD 항목 보존)
  - P1: 작성 예시의 호출 흐름을 본문 지침과 동일한 ASCII 트리 + `Class#method` 표기로 통일 (지침↔예시 모순 해소)
  - P2: frontmatter description 트리거 변형 보강 + "메시지 작성용(실제 PR 생성 아님)" 경계 명시
  - P3: 번호 매긴 "실행 절차" 섹션 추가
  - P5: 테크 관점 참고사항의 ADR/계약/도메인 경로 안내 중복을 "참조 문서" 포인터로 정리

**비포함 (Out)**

- `issue-work`의 `--clear` 변경 (drift 신호는 diff에서 직접 재도출 가능, 중복)
- `readme-sync`·`ai-workspace`·`code-map` 스킬 자체 변경
- 문서 자동 재생성 로직 (이 단계는 감지·권고까지만, 재생성은 각 스킬 책임)

---

## 완료의 정의 (Definition of Done)

- [x] `git-pr/SKILL.md`에 "문서 동기화 점검" 단계가 추가됨
- [x] 이 단계가 PR 초안 작성 완료 후 마지막 패스로 1회 수행됨이 명시됨 (절차 순서)
- [x] drift 감지 규칙 테이블이 포함됨 (스킬 디렉토리 변경 / 디렉토리 구조 변경 / 호출 흐름 변경 / domain·keywords 변경 4개 신호 매핑)
- [x] 각 규칙 행이 해당 diff 신호가 있을 때만 권고를 냄(코드 변경 없는 PR 포함 자연 처리)이 명시됨
- [x] `SKILL.md:100`의 drift 권고만 code-map 행으로 흡수되어 중복·충돌이 없고, `SKILL.md:99` 작성 지침은 호출 흐름에 유지됨
- [x] 출력이 flag-only 기본임이 명시되고, 승인형 tier가 함께 기술됨
- [x] `--clear` 등 다른 스킬 파일은 변경되지 않음 (범위 밖 준수)
- [x] 작성 규칙 준수: 본문 이모지 미사용, 기존 `SKILL.md` 문체·구조와 일관
- [x] Claude skill-creator 점검을 거침 (코워크 환경)
- [x] (P1) 작성 예시 호출 흐름이 본문 지침과 동일한 ASCII 트리·`Class#method` 표기로 통일됨
- [x] (P2) description에 트리거 변형이 추가되고 메시지 작성용 경계가 명시됨
- [x] (P3) 번호 매긴 실행 절차 섹션이 추가됨
- [x] (P5) 참고사항의 ADR/계약/도메인 경로 안내 중복이 정리됨
- [x] description 변경이 README/AI-CONTEXT를 낡게 만들지 않음 재확인 (verbatim 미러 없음 → 갱신 불필요)

---

## 연관 문서

> `.ai/30_contract`·`40_domain`·`50_adr` 인덱스에는 아직 실질 문서가 없어, 이 이슈의 연관 대상은 소스(스킬 파일)다.

| 문서 | 역할 |
|------|------|
| `git-pr/SKILL.md` | 변경 대상. 기존 code-map 힌트(호출 흐름 블록)를 일반화 |
| `code-map/SKILL.md` | 권고 대상 스킬 (`.ai/60_codebase/` drift) |
| `readme-sync/SKILL.md` | 권고 대상 스킬 (README drift) |
| `ai-workspace/SKILL.md` | 권고 대상 스킬 (AI-CONTEXT 구조·스킬 목록·domain/keywords drift) |
