# Issue #39 실행요약 ai-workspace: 산출물 작성 원칙(writing-principles) SSoT 배포 체계 추가

> 스펙: [issue-0039-spec.md](./issue-0039-spec.md) | 계획: [issue-0039-plan.md](./issue-0039-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task 5 — 설치본 동기화·후속 이슈 후보 정리

## 모델 기록

| 구분 | 모델 |
|------|------|
| 계획·구현 모델 | Anthropic, Claude Fable 5 (claude-fable-5) |
| audit 모델 | <!-- 구현 모델과 다른 벤더 모델. 형식: 벤더, 모델명. 마지막 교차모델 audit Task에서 사용자가 기록 --> |

---

## Task별 수행 결과

### Task 1: writing-principles.md SSoT 원본 신설

- **결과**: 완료
- **수행 내용 요약**: `ai-workspace/templates/shared/.ai/10_rules/writing-principles.md` 신설 (33줄). 동기화 헤더·버전(1.0.0) 표기 → 우선순위 선언(템플릿 구조 우선·서술 제약만) → 적용/제외 범위 → 제약 규칙(중요한 것 먼저·리스트형 우선·분량 예산·한글 표현 우선·금지 패턴·What/Why/How 분리·접기) → 구조 기본값(자유 서술 한정 계층형 출력) 순으로 구성. 완료 기준 검증 통과: SYNCED 헤더 1건, '템플릿이 우선' 1건, 버전 표기 1건, 33줄 ≤ 50.
- **특이 사항**: 버전 표기는 커밋 해시 대신 버전 번호(1.0.0) 방식 채택 — 커밋 전에는 해시를 알 수 없어 자기 자신을 가리킬 수 없음. local 우선 규칙 상호 참조 한 줄은 계획대로 Task 2에서 추가 예정 (분량 여유 17줄). 사용자 피드백으로 중요도 태그 체계를 제거하고 배치 규칙(중요한 것 먼저)으로 대체, 리스트형·한글 표현 우선 추가 — 이슈 #39 본문·spec·plan에도 동일 반영.

---

### Task 2: writing-principles-local.md 로컬 확장 템플릿 신설

- **결과**: 완료
- **수행 내용 요약**: `ai-workspace/templates/shared/.ai/10_rules/writing-principles-local.md` 신설 — 상단에 사용자 관리 파일 안내("없을 때만 빈 템플릿 복사, 이후 덮어쓰지 않음")와 "충돌 시 local 우선" 규칙 기재, 본문은 `coding-convention.md` 선례를 따라 예시 주석만 담은 빈 템플릿. `writing-principles.md` 우선순위 블록에 local 우선 상호 참조 한 줄 추가(33→34줄, 예산 50줄 이내). 완료 기준 검증 통과: local 템플릿 'local 우선' 1건, 원본 상호 참조 1건, 원본 34줄 ≤ 50.
- **특이 사항**: 사용자 관리 파일이므로 SYNCED 동기화 헤더를 넣지 않음 — 동기화 대상(`writing-principles.md`)과 시각적으로도 구분됨.

---

### Task 3: AI-CONTEXT.md 템플릿(dev·doc) 라우터 한 줄 추가

- **결과**: 완료
- **수행 내용 요약**: dev·doc 두 템플릿의 `## 프로젝트 규칙` 10_rules 표 마지막 행(알파벳순 유지)에 라우터 한 줄 추가 — `.ai/10_rules/writing-principles.md` | 산출물 작성 원칙 (소스 코드 미적용) | 산출 문서·PR·이슈 본문 작성 시. 내용 요약 없이 경로 안내만 기재. 완료 기준 검증 통과: `grep -l 'writing-principles'` 두 파일 모두 매칭.
- **특이 사항**: 없음.

---

### Task 4: SKILL.md init/update 절차 반영

- **결과**: 완료
- **수행 내용 요약**: `ai-workspace/SKILL.md` 3곳 수정. init-1단계에 두 파일 복사 정책 문구 추가(일괄 복사에 포함됨을 명시, update에서 정책이 갈림을 안내). update-1단계 스크립트에 `writing-principles.md` 항상 덮어쓰기(context-loading.md와 동일 정책)와 `writing-principles-local.md` 없을 때만 복사(coding-convention.md와 동일 정책) 추가. 사용자 작성 파일 보존 목록에 `writing-principles-local.md` 추가. 완료 기준 검증 통과: 전체 7건 ≥ 2, update 섹션 5건 ≥ 1.
- **특이 사항**: 멱등 보강은 조건 분기 대신 무조건 덮어쓰기로 구현 — "누락·구버전이면 덮어쓰기"를 항상 덮어쓰기로 단순화해도 결과가 동일(멱등)하며 context-loading.md 선례와 일치. 헤더 버전 표기는 추적용으로 유지.

---

### Task 5: 설치본 동기화·후속 이슈 후보 정리

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task N (고정): 교차모델 issue-audit 검증 — 사용자 수동 수행

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:
