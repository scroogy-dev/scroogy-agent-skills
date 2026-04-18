---
name: ai-workspace
description: 프로젝트의 .ai 디렉토리 구조를 초기화하거나 최신 구조로 갱신합니다. dev(개발) 또는 doc(문서) 프로파일을 선택할 수 있습니다.
---

## 개요

현재 프로젝트 루트에 `.ai/` 디렉토리와 AI 협업을 위한 기본 구조를 생성하거나 갱신합니다.
이 스킬 디렉토리의 `templates/` 아래 파일을 기준으로 구성합니다.

## 이 구조와 함께 사용 가능한 skill

- **code-map**: 소스코드 기능별 엔트리포인트·호출 흐름 색인 (`.ai/60_codebase/` 활용)
- **git-commit**: Conventional Commits 규칙에 따른 커밋 메시지 작성
- **git-pr**: PR 제목/메시지 작성 (비즈니스+테크 관점, `.ai/50_adr/`, `.ai/30_contract/`, `.ai/40_domain/` 활용)
- **git-qa**: 배포 대상 PR에서 repo별 QA 체크리스트 생성 (`.ai/99_workspace/` 활용)
- **git-review**: 비즈니스/테크 리뷰 수행 (`.ai/30_contract/`, `.ai/40_domain/` 활용)
- **git-review-context**: 리뷰 전 변경사항 사전 분석 (`.ai/99_workspace/` 활용)
- **issue-work**: 이슈 단위 스펙/계획/요약 관리 (`.ai/90_issues/` 활용)

## 사용법

```
/ai-workspace [dev|doc]
```

- `dev`: 개발 프로젝트용 — 기술 스택, 코딩 컨벤션 섹션 포함
- `doc`: 문서 프로젝트용 — 기술 스택, 코딩 컨벤션 섹션 없음
- 프로파일을 생략하면 사용자에게 선택을 요청합니다.

---

## 실행 절차

### 1단계: 프로파일 확인

`$ARGUMENTS`에서 프로파일을 읽습니다.
- `dev` 또는 `doc`이면 그대로 사용합니다.
- 값이 없거나 유효하지 않으면 사용자에게 `dev` / `doc` 중 선택을 요청합니다.

### 2단계: 모드 결정

`.ai/` 디렉토리 존재 여부에 따라 모드를 결정합니다.

- **없음** → [init 모드](#init-모드) 실행
- **있음** → 사용자에게 선택 요청
  - `init`: 기존 `.ai/`를 완전히 덮어씁니다.
  - `update`: 기존 내용을 최대한 보존하며 구조를 최신화합니다. → [update 모드](#update-모드) 실행

---

## init 모드

### init-1단계: 파일 복사

이 스킬 파일의 위치(`SKILL.md`가 있는 디렉토리)를 기준으로 `templates/` 경로를 찾아 복사합니다.

```bash
SKILL_DIR="<이 SKILL.md가 위치한 디렉토리>"
PROFILE="<선택된 프로파일: dev 또는 doc>"

# 공통 파일 복사
cp -r "$SKILL_DIR/templates/shared/.ai/" .ai/

# 프로파일별 파일 복사 (AI-CONTEXT.md + 프로파일 전용 10_rules 등)
cp -r "$SKILL_DIR/templates/$PROFILE/.ai/"* .ai/
```

빈 디렉토리에는 `.gitkeep` 파일이 포함되어 있습니다 (templates에서 복사됨).

프로파일별 전용 파일 예시:
- `dev` 전용: `.ai/10_rules/architecture.md`, `.ai/10_rules/coding-convention.md`
- `doc` 전용: (없음)

### init-2단계: 완료 보고

생성된 파일 목록을 트리 구조로 출력하고, 사용자에게 다음 안내를 제공합니다.

- `.ai/AI-CONTEXT.md`의 주석 처리된 섹션(`<!-- ... -->`)을 프로젝트에 맞게 채워주세요.
- 이슈 작업 시 `issue-work` skill(`/issue-work`)을 사용하세요.

---

## update 모드

기존 `.ai/` 내용을 최대한 보존하면서 최신 구조로 맞춥니다.

### update-1단계: 10_rules/ 정리

이전 버전에서 설치된 파일 중 개별 skill로 분리된 파일을 제거하고, 새 규칙 파일을 복사합니다.
사용자가 작성한 파일(`architecture.md`, `coding-convention.md`, `file-change-policy.md`)은 그대로 유지합니다.

```bash
# skill로 분리되어 더 이상 10_rules에 포함되지 않는 파일 제거
rm -f .ai/10_rules/git-commit-policy.md
rm -f .ai/10_rules/git-pr-policy.md
rm -f .ai/10_rules/git-review-policy.md
rm -f .ai/10_rules/git-review-context-builder.md
rm -f .ai/10_rules/issue-workflow.md

# 공통 규칙 파일: 버전 고정이라 항상 최신본으로 덮어쓰기
cp "$SKILL_DIR/templates/shared/.ai/10_rules/context-loading.md" .ai/10_rules/context-loading.md

# 사용자 작성 대상 파일: 없을 때만 빈 템플릿 복사
[ ! -f .ai/10_rules/file-change-policy.md ] && \
  cp "$SKILL_DIR/templates/shared/.ai/10_rules/file-change-policy.md" .ai/10_rules/file-change-policy.md

# dev 프로파일 전용 (없을 때만 빈 템플릿 복사)
if [ "$PROFILE" = "dev" ]; then
  [ ! -f .ai/10_rules/architecture.md ] && \
    cp "$SKILL_DIR/templates/dev/.ai/10_rules/architecture.md" .ai/10_rules/architecture.md
  [ ! -f .ai/10_rules/coding-convention.md ] && \
    cp "$SKILL_DIR/templates/dev/.ai/10_rules/coding-convention.md" .ai/10_rules/coding-convention.md
fi

# doc 프로파일: 기존 architecture.md가 있으면 삭제하지 않고 유지
# (시스템 아키텍처 용도로 사용자가 직접 관리하는 경우가 있어 판단을 사용자에게 위임)
```

### update-2단계: 20_templates/ 정리

이전 버전에서 설치된 템플릿 파일(issue-work skill로 이관된 `issue-*-template.md` 등)을 제거합니다.

```bash
rm -rf .ai/20_templates/*
```

### update-3단계: 콘텐츠 디렉토리 구조 정비

`30_contract/`, `40_domain/`, `50_adr/`, `60_codebase/`, `90_issues/` 각각에 대해 아래를 수행합니다.

#### 하위 디렉토리 구조 생성

정의된 하위 디렉토리가 없으면 생성합니다. 새로 생성한 빈 디렉토리에는 `.gitkeep` 파일을 함께 생성합니다.

| 디렉토리 | 생성할 하위 구조 |
|---------|--------------|
| `30_contract/` | (하위 디렉토리 없음) |
| `40_domain/` | `specs/`, `policies/common/`, `policies/local/` |
| `50_adr/` | `active/`, `superseded/` |
| `60_codebase/` | (하위 디렉토리 없음) |
| `90_issues/` | `active/`, `archive/` |

#### 기존 파일 정리

각 디렉토리 바로 아래에 파일이 있으면 내용과 파일명을 분석하여 적절한 하위 디렉토리로 이동합니다.

**이동 판단 기준:**

| 디렉토리 | 판단 기준 |
|---------|---------|
| `40_domain/` | 파일명·내용이 기능 명세이면 `specs/`, 정책이면 `policies/local/`로 이동 |
| `40_domain/policies/` | `policies/` 바로 아래에 파일이 있으면 `policies/local/`로 이동 |
| `50_adr/` | `superseded`, `deprecated`, `replaced` 등의 키워드가 있으면 `superseded/`, 아니면 `active/`로 이동 |
| `90_issues/` | 모든 Task 체크박스가 완료되었거나 완료 표시가 있으면 `archive/`, 아니면 `active/`로 이동 |

판단이 불가능한 파일은 해당 디렉토리 안에 `legacy/`를 만들어 이동합니다.

### update-4단계: AI-CONTEXT.md 갱신

프로젝트를 분석하여 AI-CONTEXT.md를 갱신합니다. **이미 사용자가 작성한 섹션은 유지하고, 주석(`<!-- ... -->`)으로 비어있는 섹션만 채웁니다.**

분석 대상:
- 프로젝트 루트의 `README.md`
- 디렉토리 구조 (`ls`, `find` 등)
- 기존 `.ai/AI-CONTEXT.md` 내용

#### 구버전 구조 마이그레이션

<!--
이 소섹션은 구버전 AI-CONTEXT.md를 신버전으로 전환하기 위한 **일회성 마이그레이션 로직**입니다.
운영 중인 프로젝트가 모두 신버전으로 전환 완료되면, 이 "구버전 구조 마이그레이션" 소섹션 전체를 제거해도 됩니다.
-->

구버전 AI-CONTEXT.md는 "AI가 작업 시 지켜야 할 원칙", "코딩 컨벤션", "프로젝트 규칙"이 별도 섹션으로 분리되어 있었습니다. 신버전은 이들을 **"프로젝트 규칙" 단일 섹션**으로 통합하고, 위치를 **`프로젝트 목적` 바로 아래**로 이동시킵니다.

**① 섹션 통합 자동 처리**

아래 섹션이 존재하면 다음과 같이 처리합니다:

| 구버전 섹션 | 처리 방법 |
|-----------|----------|
| `## AI가 작업 시 지켜야 할 원칙` | 섹션 통째로 **삭제** (필요하면 사용자가 신규 `프로젝트 규칙` 섹션에 다시 추가) |
| `## 코딩 컨벤션` (dev) | 본문을 `.ai/10_rules/coding-convention.md`로 이관. AI-CONTEXT.md 섹션은 제거 |
| 기존 `## 프로젝트 규칙` 테이블 | 아래 ②번대로 테이블을 신규 포맷으로 확장 후, 섹션을 `## 프로젝트 목적` 바로 아래로 이동 |

**② "프로젝트 규칙" 테이블 확장**

테이블에 누락된 행이 있으면 추가하고, 2열(파일·설명)이면 3열(파일·설명·사용 시점)로 확장합니다.

최종 형태 (dev):
```markdown
## 프로젝트 규칙

<!-- 간단한 인라인 규칙은 여기에 적고, 상세 규칙은 `.ai/10_rules/`에 파일로 두고 아래 테이블에 등록하세요. -->

| 파일 | 설명 | 사용 시점 |
|------|------|----------|
| `.ai/10_rules/architecture.md`       | 프로젝트 아키텍처 방향     | 코드 작성·리뷰·아키텍처 변경 시 |
| `.ai/10_rules/coding-convention.md`  | 코딩 컨벤션                | 코드 작성 시      |
| `.ai/10_rules/context-loading.md`    | 작업 전 컨텍스트 확인 절차 | 코드·문서 작업 전 |
| `.ai/10_rules/file-change-policy.md` | 파일 변경 규칙             | 파일 추가·삭제 시 |
```

doc 프로파일은 기본적으로 `coding-convention.md`와 `architecture.md` 행을 **제외**하고, `context-loading.md` 사용 시점은 "문서 작업 전"으로 기재합니다.

단, doc 프로파일에서 기존 `.ai/10_rules/architecture.md` 파일이 존재하면(예: Org 내 Repo 간 시스템 아키텍처 용도), 해당 행은 **유지**합니다. 파일 자체도 삭제하지 않습니다.

### update-5단계: 완료 보고

변경된 내용을 요약하여 보고합니다.

- 새로 생성된 디렉토리/파일 목록
- 이동된 파일 목록 (이동 전 → 이동 후)
- `legacy/`로 이동된 파일이 있으면 사용자에게 수동 분류를 요청합니다.
