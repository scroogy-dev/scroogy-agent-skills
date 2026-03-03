---
name: ai-workspace
description: 프로젝트의 .ai 디렉토리 구조를 초기화하거나 최신 구조로 갱신합니다. dev(개발) 또는 doc(문서) 프로파일을 선택할 수 있습니다.
---

## 개요

현재 프로젝트 루트에 `.ai/` 디렉토리와 AI 협업을 위한 기본 구조를 생성하거나 갱신합니다.
이 스킬 디렉토리의 `templates/` 아래 파일을 기준으로 구성합니다.

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

# 프로파일별 AI-CONTEXT.md 복사
cp "$SKILL_DIR/templates/$PROFILE/.ai/AI-CONTEXT.md" .ai/AI-CONTEXT.md
```

### init-2단계: 완료 보고

생성된 파일 목록을 트리 구조로 출력하고, 사용자에게 다음 안내를 제공합니다.

- `.ai/AI-CONTEXT.md`의 주석 처리된 섹션(`<!-- ... -->`)을 프로젝트에 맞게 채워주세요.
- 이슈 작업 시 `.ai/10_rules/issue-workflow.md`를 참고하세요.

---

## update 모드

기존 `.ai/` 내용을 최대한 보존하면서 최신 구조로 맞춥니다.

### update-1단계: 10_rules/ 갱신

스킬이 관리하는 디렉토리이므로 항상 스킬의 최신 파일로 덮어씁니다.

```bash
cp -r "$SKILL_DIR/templates/shared/.ai/10_rules/" .ai/10_rules/
```

### update-2단계: 20_templates/ 갱신

스킬이 관리하는 디렉토리이므로 항상 스킬의 최신 파일로 덮어씁니다.

```bash
cp -r "$SKILL_DIR/templates/shared/.ai/20_templates/" .ai/20_templates/
```

### update-3단계: 콘텐츠 디렉토리 구조 정비

`30_contract/`, `40_domain/`, `50_adr/`, `90_issues/` 각각에 대해 아래를 수행합니다.

#### 하위 디렉토리 구조 생성

정의된 하위 디렉토리가 없으면 생성합니다.

| 디렉토리 | 생성할 하위 구조 |
|---------|--------------|
| `30_contract/` | (하위 디렉토리 없음) |
| `40_domain/` | `specs/`, `policies/` |
| `50_adr/` | `active/`, `superseded/` |
| `90_issues/` | `active/`, `archive/` |

#### 기존 파일 정리

각 디렉토리 바로 아래에 파일이 있으면 내용과 파일명을 분석하여 적절한 하위 디렉토리로 이동합니다.

**이동 판단 기준:**

| 디렉토리 | 판단 기준 |
|---------|---------|
| `40_domain/` | 파일명·내용이 비즈니스 스펙이면 `specs/`, 정책이면 `policies/`로 이동 |
| `50_adr/` | `superseded`, `deprecated`, `replaced` 등의 키워드가 있으면 `superseded/`, 아니면 `active/`로 이동 |
| `90_issues/` | 모든 Task 체크박스가 완료되었거나 완료 표시가 있으면 `archive/`, 아니면 `active/`로 이동 |

판단이 불가능한 파일은 해당 디렉토리 안에 `legacy/`를 만들어 이동합니다.

### update-4단계: AI-CONTEXT.md 갱신

프로젝트를 분석하여 AI-CONTEXT.md를 갱신합니다. **이미 사용자가 작성한 섹션은 유지하고, 주석(`<!-- ... -->`)으로 비어있는 섹션만 채웁니다.**

분석 대상:
- 프로젝트 루트의 `README.md`
- 디렉토리 구조 (`ls`, `find` 등)
- 기존 `.ai/AI-CONTEXT.md` 내용

### update-5단계: 완료 보고

변경된 내용을 요약하여 보고합니다.

- 새로 생성된 디렉토리/파일 목록
- 이동된 파일 목록 (이동 전 → 이동 후)
- `legacy/`로 이동된 파일이 있으면 사용자에게 수동 분류를 요청합니다.
