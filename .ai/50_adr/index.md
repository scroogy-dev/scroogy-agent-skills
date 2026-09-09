# 50_adr 인덱스

이 디렉토리는 프로젝트의 주요 의사결정 기록(Architecture Decision Records)을 보관합니다.
AI는 작업 시 이 파일을 먼저 읽고, 관련된 ADR만 선택적으로 읽어옵니다.

## 파일 목록

| 파일 | 설명 |
|------|------|
| `active/` | 현재 유효한 결정 |
| `active/0001-skill-deterministic-helper-test-convention.md` | 스킬 결정적 헬퍼의 테스트 동일 위치 배치 규칙 (테스트 위치·러너·배포 제외) |
| `active/0002-skill-independence-intentional-duplication.md` | 스킬은 AI-CONTEXT 비의존·단독 설치, 공통 규칙은 스킬별 복제 + 동기화 주석, 참조 링크 대체 불가 |
| `active/0003-verification-levels-and-determinization.md` | 검증 레벨 `[D]`/`[QD]`/`[ND]`와 강등 사유, 완료 기준 접기 형식, 결정화 판단 체크리스트, 임계 수치 미도입, 헬퍼 경로 형식 |
| `active/0004-cross-model-audit-and-response-gate.md` | Task N 교차모델 audit은 사용자가 타벤더 모델로 수동 수행, `--response` 피드백 먼저·항목별 승인, 1단계 우선 순서 게이트, 지표 누적·귀속, 전체 재감사 유지 |
| `active/0005-model-separation-gates.md` | 계획 종료 게이트·Task 0 구현 시작 게이트, spec 전제 섹션, Task별 모델·보정 지표, 모델명 하드코딩 금지 |
| `active/0006-risk-matrix-and-treatment.md` | 영향×발생확률 매트릭스로 등급 산출(재량 배제), 등급별 기본 처리, git-review 수용 범위, 보안 결함 매핑 |
| `active/0007-tech-debt-ledger-location-and-structure.md` | 원장 위치 `.ai/70_ledger/`(90_issues 하위에서 번복), 항목별 파일·필수 필드 7종·출처 식별자만, 소비자 3종과 상태 행렬, 종결 독립 |
| `active/0008-writing-principles-ssot-distribution.md` | writing-principles SSoT 배포(템플릿 구조 우선·local 우선), context-loading·AI-CONTEXT 참조 연결, 스킬 내장 기본값 + 조건부 참조, 한국어 작성 규칙·번역투 패턴 |
| `active/0009-install-skills-self-install.md` | install-skills 홈 한 벌 self-install(`--self`), 헬퍼 홈 우선 탐색은 install-skills만, 스킬 repo 가드, Antigravity 공식 경로·레거시 처리, 보고 템플릿 |
| `active/0010-output-format-templates-separation.md` | 산출물 형식 블록을 templates/로 분리(SKILL.md는 참조만), "이 skill 디렉토리의" 표기 통일, 제외 스킬 근거 |
| `active/0011-git-pr-submission-and-approval-gate.md` | git-pr 제출까지 확장, 유형 확인·승인 게이트 필수, `--draft`, gh 기본 + MCP 폴백, 포크 비지원, 문서 동기화 점검 flag-only |
| `active/0012-git-pr-feedback-separate-skill.md` | 리뷰 코멘트 대응은 별도 스킬(git-pr 확장·`--response`·git-review 확장 기각), 의견 유형 5종, 외부 공개 행위 승인, push 방어, 이름 결정 기준 |
| `active/0013-long-output-single-file-generation.md` | PR 본문·이슈 댓글은 99_workspace 파일 1회 생성 + 경로·요약 제시, 파일명 규약, 정리 시점 A+B 병행 |
| `active/0014-inverted-pyramid-and-verdict-derivation.md` | 평가 결과 역피라미드(판정 한 줄·요약·상세), 카테고리 7종 원본 git-review, 상태·판정 재량 없는 산출, 신호등 이모지 SSoT는 SKILL.md 대응표, 이모지 정책 |
| `active/0015-issue-clear-timing-and-archive-rules.md` | `--clear`는 머지 직전, archive 이관은 머지 전 PR 브랜치, 댓글은 시점 무관, 이관 파일 경로 참조 갱신·stale 0건 검사, workflow 자동 동기화 |
| `active/0016-spec-requirements-layer-and-plan-audit.md` | spec 요구사항(포함 R<n>·제외) 신설·범위 삭제·DoD R 그룹·Task 대상 요구사항, 요구사항 승인 게이트, `--plan` 계획 감사(선택)와 계획 보정, 단계 어휘 |
| `active/0017-git-review-quiz-study-mode.md` | git-review-quiz 별도 스킬, 문항 구성(위치 본문·힌트·정답 접기), 근거 규칙, 일반 댓글 하나 게시, 머지 차단 게이트 배제 |
| `superseded/` | 대체된 결정 (대체한 ADR 번호를 문서 내에 명시) |
| (문서를 추가하면 이 목록에 함께 기재하세요) | |
