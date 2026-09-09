# 40_domain 인덱스

이 디렉토리는 비즈니스 도메인 지식(스펙, 정책, 용어)을 보관합니다.
AI는 작업 시 이 파일을 먼저 읽고, 관련된 파일만 선택적으로 읽어옵니다.

## 파일 목록

| 파일 | 설명 |
|------|------|
| `policies/` | 비즈니스 정책 문서 모음 (`common/` 공통 정책, `local/` 이 repo 고유 정책) |
| `policies/local/ssot-and-router-principle.md` | 소스 코드 SSoT, 안내도는 라우터, 충돌 우선순위, 멀티/단독 repo CoC 런타임 판정과 판정 결과 미기재 |
| `policies/local/external-action-approval-gate.md` | PR 제출·답글·resolve·push·이슈 댓글·퀴즈 댓글의 승인 게이트, 승인 값 불변 보관·재대조, 저장소 명시, 동적 인자·자격증명 처리 |
| `policies/local/notation-conventions.md` | 분류 값 한글 우선 병기, 모델 표기, 트리 정렬, 이모지 정책, templates/ 참조 표기, 스킬·옵션 명명 기준, 호환 도구 목록 |
| `policies/local/license-policy.md` | Apache 2.0·NOTICE 두 줄·헤더 파일명 가드, readme-sync 라이선스 옵션과 `--force-license` 가드 |
| `specs/` | 비즈니스 스펙 문서 모음 |
| `specs/issue-workflow.md` | issue-work 절차 순서, spec·plan·summary 구성, 게이트 7종 요약, 옵션, 헬퍼 |
| `specs/issue-audit.md` | issue-audit 0~3단계 요건, 발견 번호 계승·계보, 기등재 대조, 리포트 구조·이력화, `--plan` 계획 감사 |
| `specs/git-review-output.md` | git-review 카테고리 7종, 위험도·상태·판정 산출, 결과 파일 구조, 헬퍼 모드 |
| `specs/git-pr-submission.md` | git-pr 제출 절차, 생성 수단, 파일 규약, 문서 동기화 점검 표 |
| `specs/git-pr-feedback.md` | git-pr-feedback 수집·분류·승인·조치 요건, push 방어, 원장 연계 |
| `specs/git-review-quiz.md` | git-review-quiz 옵션, 산출 파일, 문항 형식 규칙 R1~R7, `--comment` 검사, 대화형 진행 |
| `specs/install-skills.md` | install-skills 대상 경로, 소스 스캔·가드, 배포 제외, 검증 헬퍼, 보고 템플릿 |
| `specs/ai-workspace.md` | ai-workspace·ai-workspace-directory 모드·프로파일, update 구조 정합·멱등 보강 검사, 로비·층 안내도 동기화 |
| `specs/readme-sync.md` | readme-sync 모드·프로파일·템플릿 구성, 라이선스 옵션 연결 |
| `glossary.md` | 프로젝트 도메인 용어 사전 |
