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
| `active/0018-ledger-proactive-review-and-resolve-timing.md` | 원장 재검토·종결 계기 확장(git-pr 원장 대조·issue-work 함께 해소 후보, 권고·승인형), `해소(PR #N)`은 PR 번호를 알 때만 확정하고 없으면 git-pr 생성 후 기재 |
| `active/0019-test-perspectives-and-task-level-placement.md` | 테스트 관점 구분(spec DoD `[D]`는 외부 경계의 인수 테스트, 구현 테스트는 plan Task), Task별 테스트 배치와 러너형 테스트 `[D]`, 최종 감사 관점 5 Task별 테스트 기준·1단계 `[D]` 실제 실행 |
| `active/0020-doc-ssot-original-documents-and-publishing-deferred.md` | doc SSoT는 `ssot_dir`의 원본 문서(위키 원본·page ID 추적 기각), 퍼블리싱은 스킬 범위 밖(재검토 K-0014), `.md` 대상·문서 규약 파일·로비와 건물 repo 선언·doc 카테고리·보류 항목 등재 |
| `active/0021-ledger-archive-move-link-update.md` | 원장 항목 archive 이동 시 들어오는 링크 갱신(`.ai/` 아래, `90_issues/archive/` 제외, 같은 디렉토리 링크 포함·깊이 재계산), 적용 지점 5곳·스킬별 정의 1곳, 끊긴 원장 링크 검사 헬퍼 `check-ledger-links.sh` 사본 3개, ADR 0018 유지, #121 복제 |
| `active/0022-adr-lifecycle-status-and-superseded-move.md` | ADR 수명 주기(일부 변경·대체·폐기)를 index에 두고 경계는 결정 섹션, 상태 줄(`유효`·`대체`·`폐기`, 없으면 유효)과 `superseded/` 제약 제외(context-loading 명시), 이동 시 index 행·들어오는 링크 갱신(0021 복제, 파일명 검색 확인·헬퍼 보류), update-3 상태 줄 판정·회귀 fixture(K-0001 해소), context-harvest 상태 줄 유지·섹션 부재 보류 |
| `active/0023-testing-principles-pair-and-consumer-skill-references.md` | 테스트 실행 원칙 파일 쌍(`testing-principles.md` 버전 고정·`testing-principles-local.md` 사용자 관리, dev 전용)으로 ADR 0008 쌍 구조 확장, context-loading 라우팅·dev 표준 선언 한정 규칙 표 행 검사, issue-work·issue-audit·git-qa 조건부 직접 참조(local > 공통 > 내장)와 러너 조항 검사 |
| `superseded/` | 대체·폐기된 결정 (상태 줄에 대체한 ADR 번호 또는 폐기 이슈 번호를 적음) |
| (문서를 추가하면 이 목록에 함께 기재하세요) | |

## 수명 주기

ADR을 쓰거나 고칠 때(이슈 작업 중 직접 작성, context-harvest 수집)는 아래 처리를 따릅니다.

| 경우 | 처리 | 위치 |
|------|------|------|
| 새 결정이 기존 결정을 바꾸지 않음 | 새 ADR을 씁니다. 기존 ADR은 그대로 둡니다 | `active/` |
| 결정 항목 일부 변경 | 같은 ADR을 고치고 근거에 변경 날짜·이슈 번호·경위를 적습니다 | `active/` |
| 결정 항목 전체를 새 ADR이 대체 | 옛 ADR 상태를 `대체(ADR <번호>)`로 바꾸고, 새 ADR 근거에 대체 대상을 적습니다 | 옛 ADR은 `superseded/` |
| 대체 결정 없이 폐기 | 옛 ADR 상태를 `폐기(이슈 #N)`로 바꾸고 근거에 사유를 적습니다 | `superseded/` |

- **일부 변경과 대체의 경계**: 결정 섹션으로 정합니다. 결정 항목이 하나라도 유효하면 일부 변경으로 보고 제자리에서 고칩니다.
- **상태 줄**: 제목 아래에 `- **상태**:` 한 줄을 둡니다. 값은 `유효`·`대체(ADR <번호>)`·`폐기(이슈 #N)` 중 하나이며, 상태 줄이 없는 ADR은 `유효`로 봅니다.
- **대체·폐기된 ADR 읽기**: `superseded/`의 ADR은 제약으로 쓰지 않고 이력을 확인할 때만 읽습니다.
- **옮길 때 index 갱신**: ADR을 `superseded/`로 옮기면 위 파일 목록에서 그 ADR 행을 `superseded/` 행 아래로 옮기고 경로를 `superseded/<파일>`로 고칩니다.
- **들어오는 링크 갱신**: ADR을 `superseded/`로 옮겼으면 `.ai/` 아래 문서(`.ai/90_issues/archive/` 제외)에서 그 ADR을 가리키는 링크를 새 경로로 고칩니다. 대상은 `50_adr/active/<파일>` 경로 링크와 ADR 파일끼리의 같은 디렉토리 링크(`./<파일>`·`<파일>`)이며, 옮긴 ADR 안에서 `active/`에 남은 ADR을 가리키는 링크도 고칩니다. 상대 경로 깊이는 링크가 있는 문서 위치에서 다시 계산합니다. 고친 뒤 옮긴 ADR 파일명으로 `.ai/`(`.ai/90_issues/archive/` 제외)를 검색해 옛 경로를 가리키는 링크가 0건인지 확인합니다.
