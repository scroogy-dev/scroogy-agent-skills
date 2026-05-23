# Issue #7 실행요약 readme-sync 스킬 개발

> 스펙: [issue-0007-spec.md](./issue-0007-spec.md) | 계획: [issue-0007-plan.md](./issue-0007-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task 3 — 모드·프로파일 정의 (`--mode` / `--profile`)

---

## Task별 수행 결과

### Task 1: README 스타일 조사 및 표준 섹션 정리

- **결과**: 완료
- **수행 내용 요약**:

  표본 4개 README를 조사: `spring-projects/spring-framework`, `openclaw/openclaw`, `facebook/react`, `kubernetes/kubernetes`.

  **섹션 출현 매트릭스:**

  | 섹션 | Spring | OpenClaw | React | K8s | 표준 분류 |
  |------|:------:|:--------:|:-----:|:---:|----------|
  | Header (제목/로고) | O | O | O | O | 필수 |
  | Badges | O | O | O | O | 권장 |
  | Overview / Intro | O | O | O | O | 필수 |
  | Quick Start / Install | (Build) | O | O | (Docs 링크) | 강권장 |
  | Usage / Examples | - | (Install에 포함) | O | - | 선택 |
  | Features | - | O | - | - | 선택 |
  | Configuration | - | O | - | - | 선택 |
  | Documentation 링크 | O | O | O | O | 권장 |
  | Project Structure | - | O (워크스페이스) | - | - | 선택 |
  | Build from Source | O | O | (Contributing) | O | 선택 (OSS) |
  | Contributing | (CoC) | O | O | (Develop) | 선택 (OSS) |
  | Community / Support | O (Stay in Touch) | O | - | O | 선택 (OSS) |
  | Code of Conduct | O | - | O | - | 선택 (OSS) |
  | Sponsors / Adopters | - | O | - | O | 선택 (대형 OSS) |
  | Roadmap / Governance | - | - | - | O | 선택 (대형 OSS) |
  | Star History / Contributors wall | - | O | - | - | 선택 (커뮤니티 강조형) |
  | License | O | (배지만) | O | - | 선택 (프로파일 의존) |

  **본 repo `scroogy-agent-skills` 맥락에서 표준 섹션 (필수 → 선택 순):**

  1. **Header** — 제목 (필요 시 로고/배지)
  2. **Overview** — 1문단 또는 3줄 가치 제안 (이 repo가 무엇인지)
  3. **Quick Start** — 가장 빠른 사용 진입점 (개인 스킬 repo면 "설치"보다 "사용"에 가까움)
  4. **Project Structure** — 디렉토리 트리 (멀티 패키지/스킬 모음 repo에 권장)
  5. **Features / 스킬 목록** — 핵심 자산 목록 (이 repo는 스킬 목록이 곧 Features)
  6. **Documentation** — 외부 문서 또는 AI-CONTEXT.md 같은 보조 문서 포인터
  7. **Contributing** — 기여 방법 (공개 OSS인 경우)
  8. **말미 블록** (옵션 — 라이선스 + 개인 저작물 고지 + Copyright)

  **톤 가이드 (4표본 공통):**
  - 1인칭("we are") 대신 3인칭/명사형 시작이 일반적 ("X is a Y that ...").
  - 평서문·짧은 문장 중심. 격식과 친근함 사이에서 약간 격식 쪽.
  - 절대 금지는 없으나, 이모지/테마성 표현은 프로젝트 정체성과 일치할 때만 (OpenClaw의 🦞처럼).
  - 본 repo는 **한국어 본문 + 영어 식별자/코드** 정책이므로 톤도 한국어 기준으로 잡는다.

  **말미 블록 패턴 (4표본):**
  - Spring: `## License` 단일 섹션 (Apache 2.0 링크)
  - React: License → Contributing → Code of Conduct (법적·윤리적 정리)
  - K8s: 별도 라이선스 섹션 없이 참고 링크로 종료
  - OpenClaw: Star History → Credits → Community → Contributors wall (커뮤니티 강조)
  - **본 repo 기준 패턴(채택)**: Apache 2.0 라이선스 섹션 → 개인 저작물 고지 → Copyright. React 패턴과 유사하나 "개인 저작물 고지" 라인이 추가됨.

- **특이 사항**:
  - K8s 표본은 라이선스 섹션이 README 본문에 없다 → "라이선스 섹션을 README에 두지 않는 것도 정상 경로"라는 Task 2 정책의 근거 사례.
  - OpenClaw는 라이선스를 본문 섹션이 아닌 **배지로만** 표시 → 라이선스 표기 방식의 한 변형으로 Task 2에서 다룬다.
  - Spring/K8s는 큰 OSS 프로젝트라 Governance/Adopters/Roadmap 같은 거버넌스 섹션이 등장하지만, 본 repo 같은 개인·소규모 스킬 저장소에는 과잉이므로 표준에서 제외.

---

### Task 2: 라이선스·개인 저작물 고지 옵션 정책 정리

- **결과**: 완료
- **수행 내용 요약**:

  **(1) 라이선스 표시 3분기**

  | 분기 | 권장 표기 | 동반 파일 | 비고 |
  |------|-----------|-----------|------|
  | (a) 오픈소스 | Apache 2.0 / MIT 등 표준 라이선스 명 + LICENSE 링크 | `LICENSE`, (필요 시) `NOTICE`, `LICENSE-HEADER.txt` | 본 repo 패턴 |
  | (b) 개인 저작물·비공개 | `All Rights Reserved` (권장) / `UNLICENSED` (npm 진영 관례) | LICENSE 파일 없이 README에만 명시 | 짧은 자체 문구도 허용 |
  | (c) 표시하지 않음 | — | 없음 | 회사 업무 관례. 라이선스 섹션 자체를 생략 |

  - (b) 권장 표기 1순위는 **`All Rights Reserved`** (가장 일반적이고 명확). npm 패키지면 `package.json`의 `"license": "UNLICENSED"`와 맞춰 README에도 `UNLICENSED`를 쓰는 게 자연스럽다.

  **(2) 개인 저작물 고지 토글**

  - **포함**: 본 repo처럼 `### 개인 저작물 고지` 소섹션을 추가. "이 프로젝트는 **<이름>**의 개인 저작물입니다. ..." 형식.
  - **미포함**: 회사 업무 컨텍스트 권장. 라이선스 분기와 독립.

  **(3) 조합표 (말미 블록 구성)**

  Copyright 라인은 라이선스 또는 고지 중 하나라도 있으면 함께 둔다(관행). 둘 다 없으면 말미 블록 전체를 생략.

  | 라이선스 | 고지 | 말미 블록 구성 | 대표 케이스 |
  |---|---|---|---|
  | 오픈소스 | 포함 | `## 라이선스` (OSS 문구 + LICENSE 링크) + `### 개인 저작물 고지` + Copyright | 본 repo (`scroogy-agent-skills`) |
  | 오픈소스 | 미포함 | `## 라이선스` (OSS 문구 + LICENSE 링크) + Copyright | 일반 공개 OSS |
  | 비공개 | 포함 | `## 라이선스` (`All Rights Reserved`) + `### 개인 저작물 고지` + Copyright | `ai-onboarding` 같은 개인 비공개 |
  | 비공개 | 미포함 | `## 라이선스` (`All Rights Reserved` 또는 `UNLICENSED`) + Copyright | 비공개 패키지 |
  | 없음 | 포함 | `### 개인 저작물 고지` + Copyright | 개인 메모/실험 repo |
  | 없음 | 미포함 | (말미 블록 전체 생략) | 회사 업무 README |

  **(4) `init` 모드 질문 문구 초안**

  ```
  Q1. README 말미에 라이선스 표시를 둘까요? (개인 작업이면 일반적으로 둡니다)
      (a) 오픈소스 라이선스 — Apache 2.0 / MIT 등. LICENSE 파일과 연결합니다.
      (b) 개인 저작물·비공개 표기 — 권장: All Rights Reserved
      (c) 표시하지 않음 — 회사 업무에서 흔한 선택입니다.
  ```

  ```
  Q2. README에 "개인 저작물 고지" 라인을 포함할까요?
      (포함 / 미포함)
      — 회사 업무라면 미포함이 일반적입니다.
  ```

  - 두 질문 모두 `--profile` 기본값이 있으면 그 값을 하이라이트한 채로 보여주고 확인만 받는다(예: `--profile=business`이면 Q1 기본값 (c), Q2 기본값 미포함).
  - LICENSE 파일이 이미 디렉토리에 있으면 Q1에서 (a)를 기본값으로 제시하고 라이선스 종류는 파일에서 자동 추정한다.

- **특이 사항**:
  - Q1의 (b) 권장 표기 1순위는 `All Rights Reserved`로 확정. `ai-onboarding` 같은 "비공개·본인만 사용 가능" 케이스에서 막힘 없이 채택할 수 있다.
  - 라이선스 (a)에서 LICENSE 파일이 없는 경우 스킬이 LICENSE 파일을 새로 만들지는 **않는다** (스킬 범위 밖). README 문구만 작성하고, LICENSE 파일 생성은 사용자에게 권유한다.
  - Copyright 라인의 이메일·연도는 사용자 정보(`git config user.*`)에서 자동 추정하되 확인을 받는다. 본 repo는 `Copyright 2026 scroogy-dev (scroogy@swtest.co.kr)` 형식.

---

### Task 3: 모드·프로파일 정의 (`--mode` / `--profile`)

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 4: README 템플릿 정의

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 5: SKILL.md 본문 작성

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 6: 본 repo에 셀프 적용 검증 (모드·프로파일·옵션 조합)

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

---

### Task 7: AI-CONTEXT.md 스킬 목록 정합성 점검

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:
