---
name: context-harvest
description: 소스코드 바깥의 What(계약, 명세)과 Why(정책, 의사결정)를 외부 소스에서 수집·증류하여 .ai/30_contract/, .ai/40_domain/, .ai/50_adr/ 문서로 만듭니다. 컨텍스트 수집, context harvest, 근거 수집, 도메인 지식 수집 시 사용합니다.
---

## 개요

소스코드 바깥에 존재하는 What(계약, 명세)과 Why(정책, 의사결정)를 외부 소스에서 수집·증류하여 `.ai/30_contract/`, `.ai/40_domain/`, `.ai/50_adr/` 문서로 만드는 스킬입니다.

### code-map과의 관계

`code-map`과 `context-harvest`는 쌍을 이루는 스킬입니다.

| 스킬 | 역할 | 대상 영역 |
|------|------|-----------|
| `code-map` | 소스코드(How)를 색인 | `60_codebase/` |
| `context-harvest` | 소스코드 바깥의 What + Why를 수집·증류 | `30_contract/`, `40_domain/`, `50_adr/` |

```
/context-harvest        →  30_contract/, 40_domain/, 50_adr/ 문서 생성
/code-map --local sync  →  새로 생긴 30/40/50 문서를 60_codebase/에서 교차 참조 연결
```

## 관련 skill

- ai-workspace (권장): `.ai/` 디렉토리 구조를 활용합니다. 없으면 필요한 디렉토리를 직접 생성합니다.
- code-map (연동): 이 스킬이 생성한 30/40/50 문서를 `60_codebase/`에서 교차 참조로 연결합니다.

## 참조 문서

- **공통 규칙**: `.ai/10_rules/context-loading.md` — 있으면 따르며, 이미 적재되어 있으면 재로딩하지 않습니다.
- **스킬 고유 추가 참조**:
  - 기존 `.ai/30_contract/`, `.ai/40_domain/`, `.ai/50_adr/` 문서의 프론트매터 — 증분 수집 판정(`last_harvested` 비교)
  - `.ai/10_rules/writing-principles.md`·`.ai/10_rules/writing-principles-local.md` — 있으면 산출물 작성 원칙으로 참조 (충돌 시 local 우선; 없으면 본문의 "산출물 접기 기준"이 기본값)

---

## 핵심 원칙

### SSoT 원칙 유지

- SSoT는 소스코드이다.
- 이 스킬이 수집하는 정보는 **소스코드에 반영된 사실의 계약/명세(What)와 배경/근거(Why)**이다.
- 산출물은 `.ai/` 내부 문서이며, 외부 URL은 문서 내 "원본 출처" 섹션에만 기재한다.
- 소스코드에 대응하지 않는 정보(기각된 제안, 미구현 요청 등)는 수집하지 않는다.

### 증류 원칙

- 외부 소스의 원문을 그대로 복사하지 않는다.
- 핵심 결정/정책/근거만 추출하여 간결한 마크다운으로 증류한다.
- 고객 정보, 개인정보가 포함된 내용은 제거하고 증류한다.

---

## 실행 흐름 (대화형)

스킬은 CLI 옵션 없이 실행하며, 대화형으로 소스와 URL을 수집한다.

```
사용자: /context-harvest

스킬:  수집할 소스를 선택해주세요 (복수 선택 가능):
       1) 웹 URL (법령, 공식 문서, 뉴스 등)
       2) GitHub (issues / PRs)
       3) Confluence (페이지 + 하위)
       4) Jira (프로젝트 이슈)

사용자: 1, 2

스킬:  [웹 URL] 수집할 URL을 입력해주세요 (여러 개 가능):
사용자: https://law.go.kr/..., https://docs.example.com/...

스킬:  [GitHub] 리포지토리 URL을 입력해주세요:
사용자: https://github.com/org/repo

스킬:  수집을 시작합니다...
       - 웹 URL 2건 fetch 중...
       - GitHub org/repo issues/PRs 스캔 중...
```

유일한 CLI 옵션은 `--full`이며, 증분이 아닌 전체 재스캔을 강제한다.

```
사용자: /context-harvest --full
```

---

## 소스 목록

| 번호 | 소스 | 접근 수단 | URL 입력 | 수집 내용 예시 |
|------|------|-----------|----------|----------------|
| 1 | 웹 URL | WebFetch 도구 | 멀티 | 법령, 공식 문서, 뉴스, RFC, 블로그, 외부 API 스펙 등 |
| 2 | GitHub issues / PRs | MCP (github) 또는 `gh` CLI | 단일 (리포 URL) | 기술적 설계 결정, 버그 원인 분석, 리뷰에서 나온 Why, 거절된 대안 |
| 3 | Confluence | MCP (atlassian) | 단일 (페이지 URL) | 정책, 법적 근거, 비즈니스 요건, 도메인 명세, API 계약 |
| 4 | Jira | MCP (atlassian) | 단일 (프로젝트 URL) | 비즈니스 배경, 외부 API 스펙, 요구사항 |

> 산출물은 소스에 고정되지 않는다. 수집된 내용의 성격에 따라 `30_contract/`, `40_domain/`, `50_adr/` 중 적절한 위치에 배치한다.

> **확장**: 새로운 소스가 필요하면 위 테이블에 번호를 추가하고, 해당 소스의 수집 로직을 구현한다.

---

## 소스별 수집 범위

**웹 URL**: 사용자가 제공한 URL 각각에서 도메인 지식을 추출한다. 공개 페이지가 주 대상이며, 인증이 필요한 비공개 페이지는 접근 실패 시 스킵하고 사용자에게 알린다.

**GitHub**: 리포 URL 하나를 받으면 해당 리포의 전체 issues(열린 + 닫힌 모두)와 전체 PRs(머지된 PR의 description + review comments)를 스캔한다.

**Confluence**: 페이지 URL 하나를 받으면 해당 페이지 + 모든 하위 페이지를 재귀적으로 스캔한다.

**Jira**: 프로젝트 URL을 받으면 해당 프로젝트의 모든 이슈를 스캔한다. 운영이 오래되어 양이 방대해지면 GitHub issues/PRs에서 언급된 티켓만 역추적하는 전략으로 전환을 검토한다.

---

## 실행 절차

### 1단계: 소스 선택 및 URL 수집

1. 사용자에게 소스 목록을 제시하고 복수 선택을 받는다.
2. 선택된 소스 각각에 대해 URL을 입력받는다.
   - 웹 URL: 여러 개 가능 (쉼표 또는 줄바꿈 구분)
   - GitHub / Confluence / Jira: 각각 단일 URL

### 2단계: 기존 산출물 확인

`.ai/30_contract/`, `.ai/40_domain/`, `.ai/50_adr/` 에 이미 수집된 문서가 있는지 확인한다.

- 기존 문서의 프론트매터에서 `source_url`과 `last_harvested`를 읽는다.
- 동일 소스에서 이미 수집된 문서가 있으면 증분 수집 대상으로 분류한다.
- `--full` 옵션이 지정된 경우 이 단계를 건너뛰고 전체 수집한다.

### 3단계: 소스별 수집

선택된 소스에서 데이터를 수집한다.

**웹 URL:**
1. 각 URL에 대해 WebFetch로 내용을 가져온다.
2. 접근 실패 시 해당 URL을 스킵하고 실패 목록에 추가한다.

**GitHub:**
1. MCP (github) 또는 `gh` CLI로 리포의 issues와 PRs를 조회한다.
2. 증분 수집 시 `last_harvested` 이후 `updated_at` 기준으로 필터링한다.
3. 각 issue의 본문 + 코멘트, 각 PR의 description + review comments를 수집한다.

**Confluence:**
1. MCP (atlassian)로 지정된 페이지와 하위 페이지 목록을 조회한다.
2. 증분 수집 시 `last_harvested` 이후 `lastModified` 기준으로 필터링한다.
3. 각 페이지의 본문을 수집한다.

**Jira:**
1. MCP (atlassian)로 프로젝트의 이슈 목록을 조회한다.
2. 증분 수집 시 JQL `updated >= "last_harvested"` 기준으로 필터링한다.
3. 각 이슈의 본문 + 코멘트를 수집한다.

### 4단계: 증류 및 분류

수집된 원문에서 핵심 내용을 증류하고, 성격에 따라 산출물 위치를 결정한다.

**분류 기준:**

| 내용의 성격 | 산출물 위치 | 예시 |
|-------------|-------------|------|
| 외부 API 계약, 인터페이스 명세 | `30_contract/` | 외부 연동 API 스펙, 프로토콜 규약 |
| 비즈니스 정책, 법적 근거, 규제 | `40_domain/policies/` | 개인정보 보관 정책, 법령 근거 |
| 기능 명세, 도메인 요건 | `40_domain/specs/` | 기능별 요구사항, 도메인 규칙 |
| 기술적 설계 결정, 아키텍처 판단 | `50_adr/active/` | 기술 선택 근거, 설계 트레이드오프 |

**증류 규칙:**
- 원문을 그대로 복사하지 않는다.
- 하나의 주제 = 하나의 문서 원칙을 따른다.
- 여러 소스에서 동일 주제가 수집되면 하나의 문서로 통합한다.
- 고객 정보, 개인정보는 제거한다.

### 5단계: 문서 생성

이 skill 디렉토리의 `templates/` 아래 템플릿을 참조하여 문서를 생성한다.

- 신규 문서: 템플릿에 따라 생성
- 기존 문서 갱신: 내용을 업데이트하고 `last_harvested`를 갱신

디렉토리가 없으면 생성한다:
```
.ai/30_contract/
.ai/40_domain/policies/
.ai/40_domain/specs/
.ai/50_adr/active/
```

### 6단계: 결과 보고

사용자에게 요약을 보고한다.

```
## context-harvest 실행 결과

- 소스: 웹 URL 2건, GitHub myorg/myrepo
- 문서 생성: 30_contract/ 1건, 40_domain/ 3건, 50_adr/ 2건
- 문서 갱신: 40_domain/ 1건
- 스킵 (접근 실패): 웹 URL 0건
- 증류 불가 (What/Why 아님): 3건

> 다음 단계: /code-map --local sync 로 교차 참조를 연결하세요.
```

---

## 산출물 접기 기준

산출물의 상세 내용은 `<details>` 접기로 분량을 줄이되, 아래 기준을 따릅니다.

- **접기 가능**: 근거·대안 비교·상세 절차·코드 예시·참고자료
- **접기 금지**: 결정사항·리스크·액션 아이템

`.ai/10_rules/writing-principles.md`가 있으면 그 원칙을 따르고, repo 고유 확장 `writing-principles-local.md`와 충돌하면 local이 우선합니다. 이 블록은 파일이 없을 때의 기본값입니다.

---

## 산출물 템플릿

이 skill 디렉토리의 `templates/` 아래 템플릿 파일이 단일 출처이며, 본문에 템플릿 내용을 중복 기재하지 않는다. 아래 표의 `templates/` 경로도 모두 이 skill 디렉토리 기준이다.

| 산출물 위치 | 템플릿 |
|-------------|--------|
| `30_contract/` (계약 문서) | `templates/30_contract-template.md` |
| `40_domain/` (도메인 문서) | `templates/40_domain-template.md` |
| `50_adr/` (의사결정 기록) | `templates/50_adr-template.md` |

---

## 증분 수집 전략

매 실행마다 전체를 다시 스캔하는 것은 비효율적이다. 이를 완화하기 위해:

- 산출물 프론트매터의 `last_harvested` 날짜를 기준으로, 이미 수집된 소스는 해당 날짜 이후 변경분만 확인한다.
- `--full` 옵션을 제공하면 전체 재스캔을 강제한다.
- 소스별 증분 지원:
  - `github`: 이슈/PR의 `updated_at` 기준 필터링
  - `confluence`: 페이지의 `lastModified` 기준 필터링
  - `jira`: JQL의 `updated >=` 기준 필터링
  - `web`: 증분 불가 — 항상 전체 fetch (URL 자체가 사용자 지정이므로)

---

## 수집 제외 대상

| 소스 | 제외 이유 |
|------|-----------|
| Git commit messages | 대부분 What(무엇을 변경)이며, Why는 PR/issue에 더 상세하게 존재. 중복 소스. |
| 소스코드 주석 | 대부분 What/How. Why는 극소수. code-map이 이미 소스코드를 읽고 있으므로 중복. |

---

## 남는 빈 자리: 사람의 역할

이 스킬이 채울 수 없는 Why:

- 구두 결정 (회의에서 합의, 어디에도 기록 없음)
- 암묵지 (담당자만 아는 히스토리)
- 메일로만 주고받은 합의 (메일 소스는 향후 옵션으로 추가 검토)

이것들은 `[WHY-NEEDED]` 태그로 남아 있으며, 사람이 보고 한 줄 써주는 방식으로 해결한다. 이 스킬은 기계가 수집 가능한 영역을 자동화하고, 수작업 범위를 최소화하는 것이 목표이다.
