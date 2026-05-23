# Issue #7 실행요약 readme-sync 스킬 개발

> 스펙: [issue-0007-spec.md](./issue-0007-spec.md) | 계획: [issue-0007-plan.md](./issue-0007-plan.md)

## 다음 작업

> ▶️ 다음 작업: Task 2 — 라이선스·개인 저작물 고지 옵션 정책 정리

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

### Task 2: 라이선스 분기 정책 정리 (오픈소스 / 개인 저작물·비공개)

- **결과**:
- **수행 내용 요약**:
- **특이 사항**:

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
