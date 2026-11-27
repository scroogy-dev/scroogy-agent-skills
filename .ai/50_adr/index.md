# 50_adr 인덱스

이 디렉토리는 프로젝트의 주요 의사결정 기록(Architecture Decision Records)을 보관합니다.
AI는 작업 시 이 파일을 먼저 읽고, 관련된 ADR만 선택적으로 읽어옵니다.

## 파일 목록

| 파일 | 설명 |
|------|------|
| `active/` | 현재 유효한 결정 |
| `active/0001-skill-deterministic-helper-test-convention.md` | 스킬 결정적 헬퍼의 테스트 동일 위치 배치 규칙 (테스트 위치·러너·배포 제외) |
| `active/0002-skill-independence-intentional-duplication.md` | 스킬은 AI-CONTEXT 비의존·단독 설치, 공통 규칙은 스킬별 복제 + 동기화 주석, 참조 링크 대체 불가 |
| `active/0003-verification-levels-and-determinization.md` | 검증 레벨 `[D]`/`[QD]`/`[ND]`와 강등 사유(plan `테스트 계획`과 고정 Task 완료 기준에 둠, #145 일부 변경), 완료 기준 접기 형식, 결정화 판단 체크리스트, 임계 수치 미도입, 헬퍼 경로 형식 |
| `active/0004-cross-model-audit-and-response-gate.md` | 구현 검증 단계의 교차 감사는 사용자가 타벤더 모델로 수동 수행, `--response` 피드백 먼저·항목별 승인(최종 감사는 결정만, #145 일부 변경), 1단계 우선 순서 게이트, 지표 누적·귀속, 전체 재감사 유지 |
| `active/0005-model-separation-gates.md` | 계획 종료 게이트·Task 0 구현 시작 게이트, 찾은 것은 spec `결정 사항`·plan `설계 결정`에 기록(#145 일부 변경), Task별 모델·보정 지표, 모델명 하드코딩 금지 |
| `active/0006-risk-matrix-and-treatment.md` | 영향×발생확률 매트릭스로 등급 산출(재량 배제), 등급별 기본 처리, git-review 수용 범위, 보안 결함 매핑 |
| `active/0007-tech-debt-ledger-location-and-structure.md` | 원장 위치 `.ai/70_ledger/`(90_issues 하위에서 번복), 항목별 파일·필수 필드 7종·출처 식별자만, 소비자 3종과 상태 행렬, 종결 독립 |
| `active/0008-writing-principles-ssot-distribution.md` | writing-principles SSoT 배포(템플릿 구조 우선·local 우선), context-loading·AI-CONTEXT 참조 연결, 스킬 내장 기본값 + 조건부 참조, 한국어 작성 규칙·번역투 패턴 |
| `active/0009-install-skills-self-install.md` | install-skills 홈 한 벌 self-install(`--self`), 헬퍼 홈 우선 탐색은 install-skills만, 스킬 repo 가드, Antigravity 공식 경로·레거시 처리, 보고 템플릿 |
| `active/0010-output-format-templates-separation.md` | 산출물 형식 블록을 templates/로 분리(SKILL.md는 참조만), "이 skill 디렉토리의" 표기 통일, 제외 스킬 근거 |
| `active/0011-git-pr-submission-and-approval-gate.md` | git-pr 제출까지 확장, 유형 확인·승인 게이트 필수, `--draft`, gh 기본 + MCP 폴백, 포크 비지원, 문서 동기화 점검 flag-only |
| `active/0012-git-pr-feedback-separate-skill.md` | 리뷰 코멘트 대응은 별도 스킬(git-pr 확장·`--response`·git-review 확장 기각), 의견 유형 5종, 외부 공개 행위 승인, push 방어, 이름 결정 기준 |
| `active/0013-long-output-single-file-generation.md` | PR 본문·이슈 댓글은 99_workspace 파일 1회 생성 + 경로·요약 제시, 파일명 규약, 정리 시점 A+B 병행 |
| `active/0014-inverted-pyramid-and-verdict-derivation.md` | 평가 결과 역피라미드(판정 한 줄·요약·상세), 카테고리 7종 원본 git-review, 상태·판정 재량 없는 산출, 신호등 이모지 SSoT는 SKILL.md 대응표, 이모지 정책, git-review의 변경 전부터 있던 결함은 별도 섹션에 적고 산출 제외(#142) |
| `active/0015-issue-clear-timing-and-archive-rules.md` | `--clear`는 PR을 만들기 직전(#145 일부 변경), archive 이관은 머지 전 PR 브랜치, 댓글은 시점 무관, 이관 파일 경로 참조 갱신·stale 0건 검사, workflow 자동 동기화 |
| `active/0016-spec-requirements-layer-and-plan-audit.md` | spec 요구사항(포함 R<n>·제외) 신설·범위 삭제·DoD AC 행·Task 대상 요구사항, `### 포함`·`### 제외` 표지·한 문장 R·5개 이상 묶음, 요구사항 승인 게이트(목록은 묶음대로), `--plan` 계획 감사(선택)와 다시 받는 조건·계획 보정, 단계 어휘(#145 일부 변경) |
| `active/0017-git-review-quiz-study-mode.md` | git-review-quiz 별도 스킬, 문항 구성(위치 본문·힌트·정답 접기), 근거 규칙, 일반 댓글 하나 게시, 머지 차단 게이트 배제 |
| `active/0018-ledger-proactive-review-and-resolve-timing.md` | 원장 재검토·종결 계기 확장(git-pr 원장 대조·issue-work 함께 해소 후보, 권고·승인형), `해소(PR #N)`은 PR 번호를 알 때만 확정하고 없으면 git-pr 생성 후 기재 |
| `active/0019-test-perspectives-and-task-level-placement.md` | 테스트 관점 구분(계획 관점은 plan `테스트 계획`, 구현 테스트는 plan Task), Task별 테스트 배치와 테스트 먼저 순서·실패 확인 기록, 최종 감사 관점 5 Task별 테스트 기준·1단계 `[D]` 실제 실행(#145 일부 변경) |
| `active/0020-doc-ssot-original-documents-and-publishing-deferred.md` | doc SSoT는 `ssot_dir`의 원본 문서(위키 원본·page ID 추적 기각), 퍼블리싱은 스킬 범위 밖(재검토 K-0014), `.md` 대상·문서 규약 파일·로비와 건물 repo 선언·doc 카테고리·보류 항목 등재 |
| `active/0021-ledger-archive-move-link-update.md` | 원장 항목 archive 이동 시 들어오는 링크 갱신(`.ai/` 아래, `90_issues/archive/` 제외, 같은 디렉토리 링크 포함·깊이 재계산), 적용 지점 5곳·스킬별 정의 1곳, 끊긴 원장 링크 검사 헬퍼 `check-ledger-links.sh` 사본 3개, ADR 0018 유지, #121 복제 |
| `active/0022-adr-lifecycle-status-and-superseded-move.md` | ADR 수명 주기(일부 변경·대체·폐기)를 index에 두고 경계는 결정 섹션, 상태 줄(`유효`·`대체`·`폐기`, 없으면 유효)과 `superseded/` 제약 제외(context-loading 명시), 이동 시 index 행·들어오는 링크 갱신(0021 복제, 파일명 검색 확인·헬퍼 보류), update-3 상태 줄 판정·회귀 fixture(K-0001 해소), context-harvest 상태 줄 유지·섹션 부재 보류 |
| `active/0023-testing-principles-pair-and-consumer-skill-references.md` | 테스트 실행 원칙 파일 쌍(`testing-principles.md` 버전 고정·`testing-principles-local.md` 사용자 관리, dev 전용)으로 ADR 0008 쌍 구조 확장, context-loading 라우팅·dev 표준 선언 한정 규칙 표 행 검사, issue-work·issue-audit·git-qa 조건부 직접 참조(local > 공통 > 내장)와 러너 조항 검사, local 템플릿 `## 로컬 서버` 절과 테스트 절의 `ide-tools.md` 라우팅(#144 일부 변경), 소비 스킬의 참조 자리를 plan `테스트 계획`으로(#145 일부 변경) |
| `active/0024-code-map-sequence-diagram-alongside-call-flow-tree.md` | code-map 호출 흐름 트리 다음 Mermaid 시퀀스 다이어그램(local `## How`·global 흐름별 섹션, global 참여자는 서비스), 트리·시퀀스 역할 분담과 SKILL.md 공통 작성 규칙(비동기 표기 정정·금지 문자·긴 흐름 생략 안내), 바뀐 기능만 반영, check 누락·불일치 건수 보고(새 태그 없음, global은 흐름 섹션 단위), K-0006 계속 수용 |
| `active/0025-sequence-diagram-extended-to-git-pr-and-review-context.md` | 호출 흐름 트리 다음 시퀀스 다이어그램을 git-pr(기능별)·git-review-context(`## 호출 흐름` 접기 안)로 확장(소제목 없음, code-map 상세 흐름 작성 기준 해당 기능만, 의사코드 행 삭제), 작성 규칙 사본(원본 code-map, 사본 git-pr·git-review-context·git-review-quiz(#132 추가), 위치·형식 행 스킬별·`--global` 구절 제외, 동기화 문구, 링크 대체 불가), code-map 러너의 `SEQ_ROWS` 사본 대조·배치 검사(git-review-quiz는 사본 대조만, 문장 전체 일치는 K-0019 수용), ADR 0024 유지 |
| `active/0026-acceptance-criteria-across-issue-spec-pr.md` | 이슈 본문 템플릿(한 문장 포함·같은 묶음의 AC·`정한 것`)과 `--create`(묶음대로 목록 제시·분할 권고·AC 미대응 포함 항목 보고), AC 옮기기(같은 묶음·문장·번호와 `(R<n>)`), 변경 통제 3분류(구체화·확장·완화, 커밋한 테스트 변경 포함), 6단계 이슈 본문 갱신 질의(기준 본문 재조회·summary 기록), 계획 감사 `check-plan.sh --ac`와 관점 3 완화·확장 점검, PR 첫 화면 5항목·접기 안 5헤더, PR 완료의 정의 대조는 AC 번호로 최종 감사 리포트 판정을 옮김, ADR 0016 일부 변경(#145 일부 변경) |
| `active/0027-git-review-quiz-explanation-sections-and-html-output.md` | git-review-quiz 문항 앞 설명 절(배경·목적·변경 설명, 출처 우선순위·`(추정)`, 변경 개요·호출 흐름·묶음 소절), 시퀀스 규칙 네 번째 사본, 형식 검사 R7 설명 절·R8 정답 편향·설명 절 펜스 인식, 대상별 산출 이름(치환 충돌 K-0024), md 원본·브라우저 렌더 HTML(CDN 고정 버전, DOMPurify 정화, 라이브러리 하나라도 실패하면 원문, 도식 오류는 그 자리만 코드), 설명 요약 먼저, 지시문 데이터 취급, PR 무영향·git-pr 비의존, ADR 0017 유지 |
| `active/0028-ai-workspace-owned-sections-and-profile-row.md` | ai-workspace update의 소유 구분(파일 단위 최신본·구간 단위 교체·사용자 작성)과 안내 주석, 헬퍼 `sync-owned.sh`(`--dirs`·`--context`·`--profile`, 실패한 파일은 변경 전 유지), 표준 섹션 템플릿은 SSoT 선언으로 선택, `profile` 행과 SSoT 선언의 역할 구분, 1단계 프로파일 결정 규칙(`check-context.sh --profile`, 추정·자동 변경 없음), `## Git 정책` 미검사 리스크(#70) 해소, ADR 0007·0008 유지 |
| `active/0029-ide-tools-rule-dev-profile-distribution.md` | IDE 도구 우선 규칙 `ide-tools.md`(dev 전용 버전 고정 단일 파일, local 쌍 없음), 규칙 표 설명 열에 핵심 기준(IDE 도구 먼저 쓸 작업·grep 전환 조건), context-loading 코드 절 라우팅, 서버 등록 이름 미기재·`lint_files` 기본(`build_project`는 선언 변경 뒤), dev 표준 선언 한정 행 검사와 선언 보정·규칙 섹션 복구 실행의 dev 전용 행 보강(K-0018 해소), ADR 0023 유지, 적용 범위·사용 시점을 탐색·수정·실행으로 넓히고 context-loading 테스트 절 라우팅 추가(#144 일부 변경) |
| `active/0030-ide-tools-execution-table-and-tool-decisions.md` | `ide-tools.md` 실행 표(테스트·커버리지·로컬 서버·디버깅, 뒷정리 열, 실행 흔적은 두고 띄운 프로세스는 사용자에게 종료 요청), 표 밖 작업은 기존 도구, IDE 실행과 러너 판정 분리, 디버깅은 사용자 요청 시, 탐색·수정 표 3행·요청 전용 도구·한 번에 불러오기, context-loading 테스트 절 라우팅·local `## 로컬 서버` 절, 배포된 안내도 행 설명 미갱신, IntelliJ MCP 도구별 결정 목록(`40_domain/specs/`, 결정 값 4종, 내부 일치 검사, IntelliJ 업데이트 때 목록 대조 헬퍼로 다시 비교), ADR 0029·0023 일부 변경 |
| `active/0031-issue-work-loop-and-one-sentence-requirements.md` | 한 문장 요구사항·AC와 spec `결정 사항`·`변경 이력`(전제 섹션 폐지), plan `설계 결정`·`테스트 계획`, 테스트 먼저 Task(실패 확인이 가짜 `[D]` 판별 대체)와 테스트 기대값 변경의 완화 분류, 진행 루프 다섯 단계·완료 확인 권장 기준(결정은 사용자)·Task N 마무리, 루프 기록·종류별 발견, issue-audit·git-pr 새 구조 대조, 옛 구조 병행 규칙 없음, ADR 0003·0004·0005·0015·0016·0019·0023·0026 일부 변경 |
| `superseded/` | 대체·폐기된 결정 (상태 줄에 대체한 ADR 번호 또는 폐기 이슈 번호를 적음) |
| (문서를 추가하면 이 목록에 함께 기재하세요) | |

## 수명 주기

<!-- 이 구간은 ai-workspace update가 최신본으로 덮어씁니다. 직접 고치면 사라집니다. -->

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
