# Issue #7 스펙 readme-sync 스킬 개발

> 원본 이슈: https://github.com/scroogy-dev/scroogy-agent-skills/issues/7

## 목표 (Goal)

`readme-sync` 스킬을 실제 동작하는 형태로 구현하여, 프로젝트를 분석하고 사람을 위한 README.md를 **두 가지 모드**(`init`: 신규 생성, `update`: 기존 README를 프로젝트 재분석하여 갱신)로 다룰 수 있게 한다.

---

## 원칙 (Principle)

**Simple is Best.** 길면 사람들이 읽지 않는다.

- 생성되는 README는 **꼭 필요한 섹션만** 둔다. 없어도 되는 섹션은 넣지 않는다.
- 각 섹션은 **짧게** 쓴다. 한두 문단·짧은 목록을 기본으로 한다.
- 스킬의 산출물(SKILL.md, 템플릿)도 같은 원칙을 따른다. 장식·중복 설명을 피한다.

---

## 범위 (Scope)

**포함 (In)**

- 유명 오픈소스(예: Spring Framework 등)의 README 스타일 분석 결과를 참고하여, README의 표준 섹션 구성과 작성 톤을 스킬에 반영한다.
- `readme-sync` 스킬의 SKILL.md 본문을 작성한다 (현재는 frontmatter만 있는 placeholder 상태).
- **두 가지 모드를 명시적으로 정의한다.**
  - **`init` 모드**: README.md가 없을 때 (또는 사용자가 신규 생성을 명시적으로 요청할 때) 템플릿 기반으로 새 README.md를 만든다.
  - **`update` 모드**: README.md가 이미 있을 때 (또는 사용자가 갱신을 명시적으로 요청할 때) 현재 프로젝트 구조·코드·문서를 재분석하여 README.md를 최신 상태로 갱신한다. 기존 사용자 작성 콘텐츠는 보존을 우선한다.
  - 모드 선택 규칙: 인자(`--mode=init|update`) 또는 README.md 존재 여부에 따른 기본 추정 — 둘 다 지원한다. 추정과 사용자 의도가 충돌할 가능성이 있으면 사용자에게 확인한다.
- **프로파일 인자 `--profile=individual|business`를 모드와 별개로 지원한다.**
  - 명명 근거: GitHub Copilot 등 SaaS 요금제의 관용 식별값 (Individual / Business)을 차용. 회사 업무인지 개인 작업인지를 한 단어로 구분.
  - **`business`**: 회사 업무 컨텍스트. 라이선스 표시·개인 저작물 고지 기본값을 **모두 "없음/미포함"**으로 둔다 (회사 README 관례).
  - **`individual`**: 개인 작업 컨텍스트. 라이선스·개인 저작물 고지를 대화형으로 묻는다 (기본 포함 후보).
  - 미지정 시 사용자에게 1회 묻거나, `init` 모드에서는 라이선스/고지 질문을 그대로 진행한다.
  - 프로파일은 어디까지나 **기본값 프리셋**이며, 사용자는 개별 질문에서 언제든 다른 선택을 할 수 있다.
- 필요한 템플릿 파일을 `readme-sync/templates/` 아래에 둔다 (필요한 경우에 한해).
- `ai-workspace`가 생성하는 `.ai/AI-CONTEXT.md`와의 역할 분리를 명시한다.
  - AI-CONTEXT.md: AI 에이전트 대상.
  - README.md: 사람 대상. 단, AI-CONTEXT.md를 참고 자료로 활용할 수 있다.
- **README 말미의 라이선스 섹션 + 개인 저작물 고지 패턴을 옵션 섹션으로 지원한다.**
  - 본 repo(`scroogy-agent-skills`)의 README 말미 패턴 (Apache 2.0 + 개인 저작물 고지 + Copyright)을 기준 예시로 둔다.
  - **`init` 모드에서는 대화형으로 두 가지를 사용자에게 묻는다.** 단, `--profile`이 주어졌으면 그에 따른 기본값을 제시하고 확인만 받는다.
    1. **라이선스 표시**: 다음 중 선택 — (a) 오픈소스 라이선스 (예: Apache 2.0, MIT 등 — LICENSE 파일과 연결), (b) 개인 저작물·비공개 표기 (예: `All Rights Reserved`, `UNLICENSED`, 짧은 자체 문구), **(c) 표시하지 않음 (none)** — 회사 업무 등 라이선스 표시가 관례적으로 없는 경우에 선택. `--profile=business` 기본값은 (c), `--profile=individual` 기본값은 (a) 또는 (b) 중 사용자 선택.
    2. **개인 저작물 고지**: 포함 / 미포함을 묻는다. `--profile=business` 기본값은 미포함, `--profile=individual` 기본값은 포함. (라이선스 분기와 별개로 토글 가능)
  - **`update` 모드에서는** 기존 README의 라이선스/고지 상태(있음/없음·분기 종류)를 유지하는 것을 기본으로 한다. `--profile`이 주어져도 기존 상태를 덮어쓰지 않는다. 사용자가 명시적으로 변경을 요청할 때만 묻거나 변경한다.
  - 즉, 라이선스 섹션과 개인 저작물 고지는 둘 다 **옵션**이며, 모두 비워두는 선택도 정상 경로다.

**비포함 (Out)**

- 다국어 README (예: README.en.md) 자동 생성.
- README 외 문서(CHANGELOG, CONTRIBUTING 등) 생성·동기화.
- 외부 README 수집 자동화 도구 작성. (스타일 분석은 사람이 수행하고, 결과만 스킬에 반영)
- `ai-workspace` 스킬 자체의 변경.

---

## 완료의 정의 (Definition of Done)

- [x] `readme-sync/SKILL.md`에 `init` 모드와 `update` 모드 절차가 각각 별도 섹션으로 기술되어 있다.
- [x] 모드 선택 규칙(인자 + README.md 존재 여부 기반 추정 + 충돌 시 사용자 확인)이 SKILL.md에 명시되어 있다.
- [x] `--profile=individual|business` 인자가 정의되어 있고, 각 값이 라이선스·개인 저작물 고지 질문의 기본값을 어떻게 프리셋하는지 SKILL.md에 명시되어 있다.
- [x] `update` 모드에서는 `--profile`이 기존 README 상태를 덮어쓰지 않는다는 정책이 SKILL.md에 명시되어 있다.
- [x] `init` 모드에서 사용할 README 템플릿이 정의되어 있다 (스킬 본문 내 인라인 또는 별도 파일).
- [x] `update` 모드에서 기존 README의 사용자 작성 콘텐츠를 보존하는 정책이 명시되어 있다.
- [x] AI-CONTEXT.md와의 역할 차이(독자, 목적)가 SKILL.md 본문에 명시되어 있다.
- [x] `init` 모드에서 라이선스 표시(오픈소스 / 개인 저작물·비공개 / **표시하지 않음**)와 개인 저작물 고지(포함 / 미포함)를 각각 대화형 질문으로 사용자에게 묻는 절차가 SKILL.md에 명시되어 있다 (단, `--profile`이 주어진 경우 그에 맞춘 기본값으로 확인만 받음).
- [x] 위 두 항목 모두 "표시하지 않음 / 미포함"이 정상 경로로 지원되며, `--profile=business`에서는 그쪽이 기본값으로 안내된다.
- [x] `update` 모드에서는 기존 README의 라이선스·고지 상태(있음/없음·분기)를 기본 유지하며, 변경은 사용자 명시 요청 시에만 수행한다는 정책이 명시되어 있다.
- [x] 개인 저작물·비공개 분기 사용 시 권장 표기 후보가 SKILL.md에 정리되어 있다.
- [x] 템플릿·생성 결과·SKILL.md 본문 모두 "Simple is Best" 원칙을 만족한다 (불필요한 섹션 없음, 각 섹션 짧음).
- [x] 스킬 디렉토리 명명 규칙(`kebab-case`, `name`=디렉토리명)과 SKILL.md 포맷이 프로젝트 규칙을 따른다.
- [x] `.ai/AI-CONTEXT.md`의 스킬 목록 설명이 실제 구현과 일치한다 (이미 등재되어 있으므로 설명 갱신 여부만 점검).
- [x] 본인 repo(`scroogy-agent-skills`)에 스킬을 직접 적용해 `update` 모드 결과가 합리적임을 확인하고, 별도의 빈 디렉토리(또는 임시 위치)에서 `init` 모드 결과도 확인한다.

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `.ai/AI-CONTEXT.md` | 스킬 목록·작성 규칙·언어 정책(한국어 본문, 영어 식별자) 확인 |
| `ai-workspace/SKILL.md` | AI-CONTEXT.md 생성 흐름 참조 (README와의 역할 분리 근거) |
| `ai-workspace/templates/` | 템플릿 파일 배치 패턴 참조 |
| `readme-sync/SKILL.md` | 본 이슈에서 작성·확장하는 대상 파일 |
| `README.md` (본 repo) | 라이선스 섹션 + 개인 저작물 고지 + Copyright 패턴의 기준 예시 |
| `LICENSE`, `NOTICE`, `LICENSE-HEADER.txt` (본 repo) | 오픈소스 라이선스 분기에서 README와 함께 다룰 파일 |

> 참고: `.ai/30_contract/`, `.ai/40_domain/`, `.ai/50_adr/`의 index.md는 현재 placeholder 상태로, 본 이슈에서 직접 참조할 항목 없음.
