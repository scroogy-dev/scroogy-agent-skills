---
name: ai-workspace
description: 프로젝트의 .ai 디렉토리 구조와 repo 안내도 AI-CONTEXT.md를 초기화하거나 최신 구조로 갱신합니다. dev(개발) 또는 doc(문서) 프로파일을 선택할 수 있습니다. 개별 repo의 층(floor)을 담당하며, 멀티 repo 워크스페이스 루트의 로비는 자매 스킬 ai-workspace-directory가 담당합니다. .ai 디렉토리, AI-CONTEXT.md 갱신, 안내도, workspace 초기화 시 사용합니다.
---

## 개요

현재 프로젝트 루트에 `.ai/` 디렉토리와 AI 협업을 위한 기본 구조를 생성하거나 갱신합니다.
이 스킬 디렉토리의 `templates/` 아래 파일을 기준으로 구성합니다.

### 설계 원칙

- **SSoT는 소스 코드.** repo 안내도(`.ai/AI-CONTEXT.md`)는 라우터일 뿐 진실의 원천이 아닙니다.
- **컨벤션 우선 (CoC).** 멀티 repo는 `<상위 워크스페이스>/<repo>` 컨벤션으로만 지원합니다. 이 repo가 멀티 워크스페이스의 일부인지 단독 repo인지는 `<repo>/../.ai/AI-CONTEXT.md` 존재 여부로 **자동 판정**합니다 — 별도 메타 필드(`building`/`lobby` 등)는 두지 않습니다 (YAGNI). 컨벤션을 벗어난 구조는 지원하지 않습니다.
- **상위 워크스페이스와의 도메인 동기화.** 멀티 워크스페이스의 일부인 경우 repo 안내도의 `## 프로젝트 도메인` 표(`domain`/`keywords`)는 상위 워크스페이스 안내도 `Repos` 표의 동일 path 행과 **1:1 동기화**됩니다 (`ai-workspace-directory`의 drift 메타 일치 검사 대상).

## 이 구조와 함께 사용 가능한 skill

- **ai-workspace-directory** (자매): 멀티 repo 워크스페이스 루트의 상위 안내도 `.ai/AI-CONTEXT.md`(로비) 생성·재구성. 상위 안내도의 `Repos` 표는 각 repo의 `path`/`domain`/`keywords`/`status`를 가지고, 본 스킬이 만드는 repo 안내도의 `## 프로젝트 도메인` 표(`domain`/`keywords`)와 **1:1 동기화 대상**입니다.
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

### init-0단계: 멀티/단독 repo 자동 판정 (CoC)

`<repo>/..`의 `.ai/AI-CONTEXT.md` 존재 여부로 자동 판정합니다. **사용자에게 묻지 않습니다** (컨벤션 우선).

```bash
[ -f ../.ai/AI-CONTEXT.md ] && echo "multi" || echo "solo"
```

| 결과 | 의미 | 이후 처리 |
|------|------|----------|
| `multi` | 멀티 워크스페이스의 일부 | init-2단계 보고에서 *"상위 안내도: `../.ai/AI-CONTEXT.md`"* 안내. `## 프로젝트 도메인`의 `domain`/`keywords`를 상위 안내도 `Repos` 행과 일치시키도록 사용자에게 권유. |
| `solo` | 단독 repo | init-2단계 보고에서 *"이 repo는 단독 repo입니다."* 안내. `## 프로젝트 도메인`은 단독 repo여도 유지 (에이전트 진입 단서). |

> **판정 결과는 사용자 보고에만 노출하고, `AI-CONTEXT.md` 본문에는 기재하지 않는다.** 판정은 런타임에 매번 `<repo>/../.ai/AI-CONTEXT.md` 존재 여부로 자동 수행하므로, 안내도에는 **판정 규칙만** 둔다 (CoC). 정적 결과("이 repo는 단독/멀티다")를 git-tracked 안내도에 직접 기재하면, 클론 환경마다 부모 디렉토리 구조가 달라 거짓이 될 수 있다.

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

#### last updated 치환

복사 직후 `.ai/AI-CONTEXT.md`의 첫 줄 `> last updated: YYYY-MM-DD` placeholder를 **스킬 실행 시점의 시스템 날짜**(`date +%Y-%m-%d`)로 치환합니다 (`ai-workspace-directory`와 동일 정책).

```bash
sed -i.bak "s/> last updated: YYYY-MM-DD/> last updated: $(date +%Y-%m-%d)/" .ai/AI-CONTEXT.md && rm .ai/AI-CONTEXT.md.bak
```

### init-2단계: 완료 보고

생성된 파일 목록을 트리 구조로 출력하고, 사용자에게 다음 안내를 제공합니다.

- init-0단계 자동 판정 결과(`multi` / `solo`) 요약. `multi`이면 상위 안내도 경로(`../.ai/AI-CONTEXT.md`)와 `## 프로젝트 도메인` 동기화 안내, `solo`이면 단독 repo임을 명시.
- `.ai/AI-CONTEXT.md`의 주석 처리된 섹션(`<!-- ... -->`)을 프로젝트에 맞게 채워주세요.
- `## 프로젝트 도메인` 표의 `domain` / `keywords` 두 행을 채워주세요 (단독 repo여도 유지). 멀티 워크스페이스인 경우 상위 안내도 `Repos` 표의 동일 path 행과 1:1 일치시켜야 합니다.
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
- 멀티/단독 자동 판정: `<repo>/../.ai/AI-CONTEXT.md` 존재 여부 (CoC — 사용자에게 묻지 않음)

#### 멱등 보강 검사 (신규)

기존 사용자 작성분은 보존하되, 아래 항목이 누락되어 있으면 표준 골격을 정확한 위치에 삽입합니다. 이미 있으면 사용자 작성분을 그대로 유지합니다.

| 항목 | 검사 | 누락 시 조치 |
|------|------|-------------|
| 본문 첫 줄 `> last updated: YYYY-MM-DD` | 본문 첫 줄이 `> last updated: <ISO 날짜>` 형식인가? | 누락이거나 형식 불일치이면 표준 형식으로 삽입·정정한다. 형식이 맞으면 매 `update` 실행 시 **스킬 실행 시점의 시스템 날짜**(`date +%Y-%m-%d`)로 갱신한다 (`ai-workspace-directory`와 동일 정책). |
| 본문 두 번째 줄 SSoT 선언 | `> SSoT: 소스 코드. 이 파일은 안내도일 뿐 진실의 원천이 아니다.` 존재? | 본문 첫 줄(`> last updated: ...`) 바로 아래에 표준 문구를 삽입한다. 비표준 문구이면 표준 문구로 교체한다. |
| `## 프로젝트 도메인` 섹션 | 섹션 존재? | 헤더와 `## 프로젝트 목적` 사이에 2행 표(`domain` / `keywords`)를 빈 값(`<...>`) 골격으로 삽입한다. `domain`/`keywords`는 사용자 입력을 요청하되, 멀티/단독 여부는 묻지 않는다 (CoC 자동 판정). |
| `## 디렉토리 구조`의 `.ai/` 한 줄 압축 | placeholder 주석에 `.ai/`는 한 줄로만 표시하라는 가이드가 있는가? 본문 트리에 `.ai/` 하위가 2단계 이상 펼쳐져 있는가? | 가이드가 없으면 표준 주석으로 보강한다. 본문 트리에서 `.ai/` 하위가 펼쳐져 있으면 한 줄(`├── .ai/  # AI 협업 가이드 (상세는 ".ai 디렉토리 구조" 섹션)`)로 정렬을 권유한다. `.ai/` 외 코드 트리 사용자 작성분은 보존한다. |
| `## 디렉토리 구조` 트리 정렬 순서 | placeholder 주석에 IDE 정렬 순서 가이드가 있는가? 본문 트리가 같은 단계에서 대소문자 무시 알파벳순 + 디렉토리 우선 순서로 정렬되어 있는가? | 가이드가 없으면 표준 주석으로 보강한다(아래 [디렉토리 트리 정렬 규칙](#디렉토리-트리-정렬-규칙) 참고). 본문 트리가 어긋나 있으면 사용자에게 IDE 순서로 정렬할지 권유한다. 사용자 작성 주석·코멘트는 줄 단위로 매칭해 그대로 옮긴다. |
| `## 에이전트 운영 지침` 섹션 + 전제 컨벤션 한 줄 | 섹션과 *"전제: 상위 디렉토리에 `.ai/AI-CONTEXT.md`가 있으면 ..."* 한 줄이 존재? | `## .ai 디렉토리 구조` 바로 다음에 표준 골격(전제 한 줄 + `### 진입 절차` 3단계 + `### 작성 규칙`)을 삽입한다. 사용자가 별도 운영 지침을 추가했다면 그 아래에 보존한다. |
| 구버전 `## 워크스페이스 위치`(4행 표) → `## 프로젝트 도메인`(2행 표) 마이그레이션 | 구버전 섹션이 존재? | 섹션명을 `## 프로젝트 도메인`으로 변경하고, `building` / `lobby` 행을 삭제한 뒤 `domain` / `keywords` 두 행만 유지한다 (CoC로 흡수된 메타 필드 제거). |

#### 구버전 구조 마이그레이션

구버전 AI-CONTEXT.md("AI가 작업 시 지켜야 할 원칙"·"코딩 컨벤션"·"프로젝트 규칙"이 별도 섹션으로 분리된 형태)를 발견한 경우에만 [references/legacy-migration.md](references/legacy-migration.md)를 읽고 그 절차를 따릅니다.

> 일회성 마이그레이션 로직입니다. 운영 중인 프로젝트가 모두 신버전으로 전환 완료되면 이 소섹션과 참조 파일을 제거해도 됩니다.

### update-5단계: 완료 보고

변경된 내용을 요약하여 보고합니다.

- 새로 생성된 디렉토리/파일 목록
- 이동된 파일 목록 (이동 전 → 이동 후)
- `legacy/`로 이동된 파일이 있으면 사용자에게 수동 분류를 요청합니다.

---

## 디렉토리 트리 정렬 규칙

`.ai/AI-CONTEXT.md`의 `## 디렉토리 구조` 트리(사용자가 채우는 프로젝트 루트 트리)를 작성·갱신할 때 적용하는 규칙입니다. `init` 모드의 보고 트리 출력과 `update` 모드의 멱등 보강 검사가 모두 이 규칙을 따릅니다.

- **같은 단계 내 정렬 기준**: 대소문자를 무시한 알파벳순으로 정렬합니다.
- **디렉토리 우선**: 디렉토리를 동일 단계의 파일보다 위에 둡니다.
- **숨김 항목 위치 고정 금지**: `.`로 시작하는 항목(예: `.ai/`, `.gitignore`)도 같은 알파벳순 규칙으로 처리하며 별도 위치(맨 위/맨 아래)에 모아두지 않습니다.
- **결과**: IntelliJ·VS Code 등 IDE의 기본 표시 순서와 일치합니다.

`## .ai 디렉토리 구조` 섹션의 트리(`10_rules/`, `20_templates/`, …)는 숫자 prefix가 정렬 키로 작동하므로 위 규칙과 자연스럽게 정합합니다.
