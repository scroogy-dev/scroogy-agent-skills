# Issue #0013 실행요약 — Fable 5 + skill-creator 기반 기존 스킬 점검·개선

> 스펙: [issue-0013-spec.md](./issue-0013-spec.md) | 계획: [issue-0013-plan.md](./issue-0013-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task 8 — 재점검 1회차(v2) 피드백 반영 완료, 사용자 2회차 재점검 대기

---

## Task별 수행 결과

### Task 1: description 트리거 정비

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - `ai-workspace`: 트리거 키워드(.ai 디렉토리, AI-CONTEXT.md 갱신, 안내도, workspace 초기화) 추가 및 층(floor)/로비 역할 구분 명시 — ai-workspace-directory와의 오라우팅 위험 해소
  - `git-review-context`: "git-review 실행 전의 사전 분석 단계, 명시적 요청 시에만 실행(자동 호출 없음)" 제약을 description으로 승격
  - `readme-sync`: "README 작성, README 갱신, readme sync, 리드미 최신화 시 사용합니다" 트리거 패턴 적용
  - `issue-work`: 괄호 플래그 표기(`--workflow-only`, `--resume`) 제거, 자연어 키워드는 유지
- **특이 사항**: 4개 frontmatter 모두 YAML 파싱 검증 통과. description 길이 106~241자로 ai-workspace가 기존 최장(187자)을 넘었으나 역할 구분 문구 포함에 따른 의도된 증가임

---

### Task 2: ai-workspace-directory 본문 분리

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - SKILL.md 본문 827줄 → 287줄로 압축, `references/` 3개 파일로 분리
  - `references/standard-structure.md`(87줄): 산출물 표준 섹션 구조 — **형식 규칙의 단일 출처**로 통합 (기존 3회 반복: init-4 필수 규칙 / 표준 섹션 구조 / 체크리스트 형식 항목)
  - `references/ssot-checklist.md`(51줄): SSoT 위배 패턴 진단 체크리스트
  - `references/examples.md`(386줄): update 모드 출력 형식 템플릿 3종 + init/update 완성 예시 2건
  - 본문의 해당 단계(init-1·init-4, update-1·2·3)에서 references 파일을 포인터로 연결
- **특이 사항**:
  - 본문의 "두 가지 모드" 소섹션(사용법과 중복), init-1 인라인 floor 입력 예시(examples.md의 init 예시가 superset), bash 스니펫 2건(산문으로 충분)은 중복 제거 차원에서 본문에서 정리
  - 기존 update-2 출력 형식 블록의 코드 펜스 중첩 오류(3-backtick 안에 3-backtick)를 examples.md 이전 시 4-backtick 외곽 펜스로 수정

---

### Task 3: code-map 모드별 분리

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - SKILL.md 본문 566줄 → 202줄로 압축, skill-creator domain organization 패턴에 따라 모드별 분리
  - `references/local.md`(182줄): `--local` 트리거 조건·파일 구조·실행 절차 0~4단계
  - `references/global.md`(196줄): `--global` 트리거 조건·전제 조건·repository.yaml·실행 절차 0~5단계
  - 본문에는 공통 원칙(SSoT, What/How/Why, 교차 참조)·두 모드 간 참조 관계·지속적 업데이트 모델·문서 메타데이터·태그 체계·트리 정렬 규칙 유지, "모드별 실행 절차" 분기 표 신설
- **특이 사항**: local.md의 트리 정렬 규칙 내부 앵커 링크를 `../SKILL.md#디렉토리-트리-정렬-규칙`으로 갱신 (규칙 본문은 SKILL.md 단일 출처 유지)

---

### Task 4: 인라인 템플릿 중복 제거

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - `context-harvest`: 본문 "산출물 템플릿" 섹션의 인라인 템플릿 3종(30_contract/40_domain/50_adr) 제거, 템플릿 파일 포인터 표로 대체 (313줄 → 250줄)
  - `context-save`: 본문 인라인 템플릿 1종 제거, `templates/context-note-template.md` 포인터로 대체 (215줄 → 178줄)
- **특이 사항**: 제거 전 templates/ 파일 4종과 인라인 버전을 대조 — 템플릿 파일이 작성 지침 주석을 포함해 인라인 버전의 superset임을 확인 (정보 손실 없음)

---

### Task 5: 본문 소건 정리

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - `git-review`: 빈 placeholder 3곳 정리 — "PR 리뷰 모드"/"Self 리뷰 모드"를 "리뷰 모드" 단일 섹션으로 통합(두 모드 모두 공통 절차를 따르므로), 빈 "4단계: 기타 테크 검증" 섹션 제거 후 결과 기록을 4단계로 당김. 커스터마이징 포인트는 각각 주석 한 줄로 축약 유지
  - `ai-workspace`: "구버전 구조 마이그레이션" 소섹션(약 40줄)을 `references/legacy-migration.md`로 분리, 본문에는 발견 조건 + 포인터만 유지
- **특이 사항**: 마이그레이션 로직의 제거 시점은 도래하지 않은 것으로 판단 — 이 스킬은 사용자의 다른 repo에도 설치되어 쓰이는데 모든 운영 프로젝트의 신버전 전환 완료를 이 시점에 확인할 수 없음. 제거 대신 참조 파일 분리를 선택 (plan의 두 옵션 중 후자)

---

### Task 6: install-skills 목록 스캔 방식 전환

- **결과**: ✅ 완료
- **수행 내용 요약**:
  - "사용 가능한 skill" 섹션의 하드코딩 목록 13개를 "SKILL.md 보유 1차 하위 디렉토리 스캔(install-skills 제외)" 지침 + bash 스니펫으로 대체
  - 각 skill의 한 줄 설명은 frontmatter `description`에서 동적으로 가져오도록 명시
  - 설치 절차 3단계를 스캔 목록 기준으로 문구 정합화
- **특이 사항**: 스킬 추가·이름 변경 시 install-skills 수정이 불필요해짐 (drift 위험 제거)

---

### Task 7: 교차 중복 단일 출처화 설계 판단

- **결과**: ✅ 완료 — **보류 (의도적 중복 유지) 결정**
- **수행 내용 요약**:
  - 대상 현황 재확인 (grep): "디렉토리 트리 정렬 규칙" 3곳(ai-workspace, code-map, readme-sync), "코드베이스 색인 갱신 문구" 4곳(git-pr, git-review, git-review-context, issue-audit), "ASCII 호출 흐름 다이어그램 지침" 2곳(git-pr, git-review-context) — 감사 보고서와 일치
  - **보류 사유**:
    1. 스킬은 install-skills로 디렉토리 단위 개별 복사·설치되므로, 설치 후에는 스킬 간 상대 경로 참조가 깨짐 — 스킬 간 공유 참조 파일은 구조적으로 불가능
    2. 감사 보고서의 대안(공통 규칙을 `.ai/10_rules/`에 두고 각 스킬은 포인터만 유지)은 대상 프로젝트에 ai-workspace 설치를 전제함 — "각 스킬은 단독 실행 가능해야 한다"는 저장소의 스킬 독립성 규칙(AI-CONTEXT.md)과 충돌
    3. 중복 3건은 모두 변경 빈도가 낮은 안정 규칙이고 각각 10줄 내외라 동기화 비용이 낮음. 특히 트리 정렬 규칙은 issue-0011에서 의도적으로 3곳에 동일 명문화한 전례
- **특이 사항**: 규칙 변경 시에는 `grep`으로 등장 위치를 찾아 동시 수정해야 함 (트리 정렬 규칙: "디렉토리 트리 정렬 규칙", 색인 갱신: "코드베이스 색인 갱신이 필요해 보입니다", ASCII 지침: "ClassName#methodName"으로 검색). 구조 변경(스킬 간 공유 메커니즘 도입)이 필요해지면 별도 이슈로 분리할 것

---

### Task 8: 셀프 검증 및 사용자 재점검 요청

- **결과**: 🔄 진행 중 — 셀프 검증 완료, 사용자 재점검 대기
- **수행 내용 요약**:
  - 기준 ① frontmatter: 14개 모두 YAML 파싱 통과, name=디렉토리명 일치, description 65~241자
  - 기준 ② description: Task 1에서 정비한 4건 반영 확인 (트리거 키워드·제약·패턴·플래그 제거)
  - 기준 ③ 구조: 전 SKILL.md 500줄 미만 (최대 287줄), references/ 분리 파일 6개 모두 본문 포인터로 연결
  - 기준 ④ 토큰 효율: 인라인 템플릿·빈 placeholder·하드코딩 목록·일회성 마이그레이션 본문 잔존 없음 (grep 확인)
  - 기준 ⑤ 중복/충돌: 트리거 회색지대 2건 description 차원 해소(Task 1), 교차 중복은 의도적 유지 결정(Task 7)
  - 스킬 내부 상대 링크 전수 검사 — 깨진 링크 0건 (예시 코드 블록 내 가상 경로 8건은 원본부터 존재하는 산출물 예시로 제외)
  - 안내도 정합성: `.ai/AI-CONTEXT.md` 디렉토리 구조 트리에 신규 `references/` 3곳 반영, last updated 갱신
- **재점검 1회차 (v2 보고서, `.ai/99_workspace/skill-audit-report-2026-06-12-v2.md`) 반영**:
  - v2 판정: 1차 지적 19건 중 17건 해소, 회귀 0건, 잔여 3건 → 모두 반영 완료
  - `readme-sync`: 라이선스 세부 사양 3절(생성 규칙·`--force-license` 가드·헤더 파일명 가드)을 `references/license.md`(54줄)로 분리, 본문 268→220줄. 읽기 조건은 "Q1=(a) 분기 진입 시 또는 `LICENSE-*` 비표준 파일 발견 시"로 명시 (헤더 가드 감지가 init-1단계에서도 동작하므로 v2 방안의 조건을 보정)
  - `git-pr`: 98행 과밀 문단을 v2 제안 형식 그대로 불릿 구조로 분리
  - `ai-workspace-directory/references/examples.md`: 목차 추가 (386→396줄, skill-creator의 300줄 초과 참조 파일 TOC 기준 충족)
  - 안내도 트리에 readme-sync `references/`·`templates/` 반영 (templates/는 기존 누락분)
  - 셀프 검증: readme-sync 구 앵커 잔존 0건, references/license.md 포인터 6곳 연결 확인
- **특이 사항**: 사용자 2회차 재점검 대기 — 추가 개선 사항 없음 확인 시 Task 8 완료 처리
