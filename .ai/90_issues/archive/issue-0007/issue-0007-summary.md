# Issue #7 실행요약 readme-sync 스킬 개발

> 스펙: [issue-0007-spec.md](./issue-0007-spec.md) | 계획: [issue-0007-plan.md](./issue-0007-plan.md)

## 다음 작업

> ✅ 모든 작업이 완료되었습니다.

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

- **결과**: 완료
- **수행 내용 요약**:

  **(1) 인자 정의**

  | 인자 | 값 | 역할 |
  |------|----|----|
  | `--mode` | `init` / `update` | 동작 모드 |
  | `--profile` | `individual` / `business` | 라이선스·고지 기본값 프리셋 (모드와 독립) |

  **(2) `--mode` 선택 규칙**

  1. 인자가 명시되면 그대로 사용.
  2. 미지정 시 `README.md` 존재 여부로 추정 (없으면 `init`, 있으면 `update`).
  3. 추정과 사용자 의도가 어긋날 가능성이 있으면 1회 확인 (예: README.md가 있는데 "처음 만들어줘"로 요청 → `init`이 맞는지 확인 후 덮어쓸지 결정).

  **(3) `--profile` 기본값 프리셋**

  | 프로파일 | 라이선스 표시 | 개인 저작물 고지 |
  |----------|---------------|------------------|
  | `individual` | (a) 또는 (b) 중 사용자 선택 | 포함 |
  | `business` | (c) 표시하지 않음 | 미포함 |
  | (미지정) | `init`에서 두 질문 그대로 제시 / `update`에서 사용 안 함 | 동일 |

  - 프로파일은 **기본값 프리셋일 뿐**, 사용자는 개별 질문에서 다른 값을 자유롭게 선택할 수 있다.
  - `update` 모드에서는 프로파일이 사용되지 않는다 (보존 우선 — Task 2의 조합표 영향 없음).

  **(4) `init` 모드 흐름**

  1. 프로젝트 디렉토리를 분석한다 (구조·언어·`AI-CONTEXT.md`·LICENSE 파일 유무 등).
  2. 라이선스 질문 Q1을 한다 (Task 2의 질문 문구 사용). `--profile`이 있으면 그 기본값을 하이라이트, LICENSE 파일이 있으면 (a)를 자동 추정.
  3. 개인 저작물 고지 질문 Q2를 한다. `--profile` 기본값을 하이라이트.
  4. 표준 섹션(Task 1)을 골라 채운다. 본 프로젝트 맥락에 무관한 섹션은 제외 (Simple is Best).
  5. Task 2 조합표에 따라 말미 블록을 구성 (또는 생략).
  6. `README.md`로 저장. 기존 파일이 있으면 덮어쓸지 1회 확인.

  **(5) `update` 모드 흐름**

  1. 기존 `README.md`를 읽고 섹션 구조·사용자 작성 콘텐츠·말미 블록(라이선스·고지 유무·분기)을 파악한다.
  2. 프로젝트 디렉토리를 재분석한다 (구조·스킬 목록·문서 등의 변화).
  3. **사용자 작성 콘텐츠는 보존**한다. 자동 갱신 대상은 구조에서 파생되는 부분(예: 디렉토리 트리, 스킬 목록표)에 한정.
  4. **말미 블록의 있음/없음·분기는 그대로 유지**. `--profile`이 들어와도 덮어쓰지 않는다.
  5. 변경된 README를 저장.
  6. 사용자가 라이선스·고지 변경을 명시적으로 요청한 경우에만 Task 2 질문 흐름을 호출한다.

- **특이 사항**:
  - `--profile`은 의도적으로 모드와 직교(orthogonal)로 설계. `init`에서만 효과를 갖고 `update`에서는 무시 → "프로파일 때문에 기존 README가 망가졌다" 사고를 원천 차단.
  - 프로파일 미지정 + `init` 시 두 질문을 그대로 제시 → "조용한 기본값"으로 사용자 의도와 다르게 만들지 않는다.
  - `update` 모드의 "사용자 작성 콘텐츠 보존" 판정은 휴리스틱(섹션 제목 매칭·내용 길이 비교)으로 충분. 정밀 diff까지는 스킬 범위 밖.

---

### Task 4: README 템플릿 정의

- **결과**: 완료
- **수행 내용 요약**:

  `readme-sync/templates/README-template.md` 단일 파일로 작성.

  **구조 (Simple is Best 적용)**:
  - **필수 섹션**: Header (제목 + 한 줄 설명) / 개요 / Quick Start
  - **옵션 섹션**: 디렉토리 구조 / 스킬 목록·기능 / 문서 / 기여 — 모두 `<!-- optional:NAME -->` 마커로 감싸 통째 삭제 가능
  - **말미 블록**: `optional:footer-license` / `optional:footer-notice` / `optional:footer-copyright` 3종 — Task 2 조합표대로 선택해서 남김. 라이선스는 단일 마커 내부에서 (a)/(b)/(c) 분기 문구를 선택하는 구조 (3개 분기를 별도 마커로 두면 시각적으로 중복돼 단일 섹션으로 통합)
  - 자리표시자 형식: `<프로젝트명>`, `<한 줄 설명>`, `<YEAR>`, `<AUTHOR>`, `<EMAIL>` 등 꺾쇠 표기로 통일

  **각 옵션 마커의 사용 규칙**:

  | 마커 | 사용 시점 |
  |------|----------|
  | `optional:badges` | 빌드 상태·버전·라이선스 배지가 의미 있을 때 |
  | `optional:structure` | 멀티 패키지/스킬 모음 등 디렉토리 트리가 가치 있을 때 |
  | `optional:features` | 스킬 목록·기능 목록 같은 핵심 자산이 있을 때 |
  | `optional:docs` | 외부 문서 또는 보조 문서 포인터가 필요할 때 |
  | `optional:contributing` | 공개 OSS인 경우 |
  | `optional:footer-license` | 라이선스 표시. 내부 주석의 (a)/(b) 분기 중 하나로 본문을 채우거나, (c)면 블록 전체 삭제 |
  | `optional:footer-notice` | 개인 저작물 고지 포함 |
  | `optional:footer-copyright` | 라이선스 또는 고지 중 하나라도 남으면 함께 |

  **적용 점검 (본 프로젝트 외)**:
  - 회사 업무 README (`business` + update 보존): 옵션 섹션 대부분 + 말미 블록 전체 생략 → 본문만 남아 깔끔.
  - 개인 비공개 패키지 (`ai-onboarding` 유사): `footer-license`(b 분기) + `footer-notice` + `footer-copyright` 조합으로 한 번에 채움.
  - 본 repo `scroogy-agent-skills`: `optional:structure` + `optional:features`(스킬 목록) + `optional:contributing` + `footer-license`(a 분기) + `footer-notice` + `footer-copyright` 조합 → 현재 README와 동등한 결과 가능.

- **특이 사항**:
  - 템플릿 안내 주석은 HTML 주석(`<!-- ... -->`)으로 작성 → 마크다운 렌더링 결과에는 안 보임. 단, **최종 README에서는 안내 주석을 제거**한다는 규칙을 Task 5 SKILL.md에 명시 필요.
  - 옵션 마커도 최종 결과물에서 제거한다 (`optional:` 마커는 스킬용, 최종 README에는 남기지 않는다).
  - 옵션 섹션을 하나도 안 쓰면 README가 Header + 개요 + Quick Start 3개 섹션만 남는다 — 최소 형태로도 정상 동작.

---

### Task 5: SKILL.md 본문 작성

- **결과**: 완료
- **수행 내용 요약**:

  `readme-sync/SKILL.md`를 placeholder 상태에서 본문 완비 상태로 작성.

  **섹션 구조 (ai-workspace SKILL.md 패턴 차용)**:
  - 개요 (모드 2종 요약 + 설계 원칙: Simple is Best / 모드·프로파일 직교 / 말미 블록 항상 옵션)
  - 사용법 (한 줄)
  - 인자 표 + 모드 선택 규칙 + 프로파일 기본값 프리셋 표
  - `## init 모드` — 1·2·3·4단계 (분석 → Q1·Q2 → 템플릿 적용 → 저장)
  - `## update 모드` — 1·2·3·4단계 (파싱 → 재분석 → 갱신 → 저장)
  - `## 라이선스·개인 저작물 고지 옵션` — Task 2의 3분기·고지 토글·6조합표
  - `## AI-CONTEXT.md와의 역할 분리` — 독자/목적 2행 표
  - `## 관련 skill` — ai-workspace / code-map

  **핵심 적용 사항**:
  - `init-3단계`에서 템플릿 처리 순서를 4단계로 명문화: ① 필수 섹션 채우기 → ② 옵션 섹션 결정 → ③ 말미 블록 결정 → ④ **마커·안내 주석 제거** (사용자가 지적했던 "<위 분기 중 하나의 문구>는 언제 채워지나" 질문에 대한 답)
  - 옵션 마커별 사용 시점을 init-3단계에 직접 기술 (Task 4 summary의 마커 표와 일치)
  - `--profile`은 `init`에서만 효과, `update`에서는 무시 — 본문 두 곳(인자 표, update-3단계)에 명시
  - LICENSE 파일 자동 추정 규칙(Q1)·LICENSE 파일은 스킬이 만들지 않는다는 정책 명시
  - 라이선스·고지 옵션 섹션을 SKILL.md 본문에 두어 사용자가 한 곳에서 모든 분기·조합을 참조 가능

- **특이 사항**:
  - SKILL.md 길이를 Simple is Best로 통제하기 위해 명령어 예시 코드 블록·반복 설명을 최소화. 표·짧은 목록 위주.
  - `update` 모드는 사용자 콘텐츠 보존이 핵심이라 절차를 4단계로 압축 (init보다 짧음).
  - AI-CONTEXT.md 역할 분리 섹션은 2행 표 + 한 문단으로 끝냄 (DoD 만족 + 길게 늘리지 않음).
  - 다른 스킬과의 관계는 ai-workspace / code-map 두 개만 언급 (실제 관련성이 있는 것만 — git-* 스킬은 README 작성과 직접 관련 없으므로 제외).

---

### Task 6: 본 repo에 셀프 적용 검증 (모드·프로파일·옵션 조합)

- **결과**: 완료
- **수행 내용 요약**:

  SKILL.md 절차를 따라 3가지 시나리오를 추적 검증. 본 repo의 실제 `README.md`는 덮어쓰지 않고 절차만 시뮬레이션.

  ---

  **시나리오 1: `--mode=update` (본 repo, `--profile` 유무 무관)**

  - **update-1 파싱 결과**:
    - 섹션: 헤더(제목 + Apache 2.0 배지) / 개요 1문단 / Skill 목록 표(13행) / Skill 간 관계(ASCII 트리) / 설치 방법(install-skills 안내) / 라이선스 / 개인 저작물 고지 / Copyright
    - 말미 블록: (a) 오픈소스 + 포함 — Task 2 조합표의 1행 케이스
  - **update-2 재분석**:
    - 디렉토리 13 + install-skills = 14개 (install-skills는 표가 아닌 "설치 방법" 섹션에서 다뤄지는 의도된 분리)
    - Skill 목록 표의 13개 항목은 실제 디렉토리와 1:1 일치
  - **update-3 갱신 결정**:
    - 자동 갱신 후보: 없음 (디렉토리 변동 없음, 표 일치). 모든 본문은 사용자 작성 콘텐츠로 보존.
    - 말미 블록: `--profile` 미사용 → 기존 (a)+포함 보존
  - **검증 결과**: ✓ 의도대로 동작. 기존 README가 그대로 유지됨.

  ---

  **시나리오 2: `--mode=init --profile=individual` (가상 빈 디렉토리)**

  - **init-1 분석**: 빈 디렉토리 → 자리표시자 채울 정보가 거의 없음. LICENSE 파일 없음.
  - **init-2 Q1**: profile=individual → (a)/(b) 선택 요청. (사용자가 (a) Apache 2.0 선택했다고 가정)
  - **init-2 Q2**: profile=individual → 포함 기본값 하이라이트 → 확인.
  - **init-3 템플릿 처리**:
    - 필수 섹션: Header / 개요 / Quick Start placeholder만 남음
    - 옵션 섹션: 빈 디렉토리라 모두 삭제 (`optional:structure` `features` `docs` `contributing` 모두 제거)
    - 말미 블록: `footer-license` 본문에 "이 프로젝트는 [Apache License 2.0](./LICENSE)에 따라 라이선스가 부여됩니다." 채움 + `footer-notice` 본문에 "이 프로젝트는 **<git user>**의 개인 저작물입니다." 채움 + `footer-copyright`에 `Copyright <시스템 연도> <git user> (<git email>)` 채움
    - 마커·안내 주석 모두 제거
  - **예상 결과 구조**:
    ```
    # <프로젝트명>
    > <한 줄 설명>

    ## 개요
    ...

    ## Quick Start
    ...

    ## 라이선스
    이 프로젝트는 [Apache License 2.0](./LICENSE)에 따라 라이선스가 부여됩니다.

    ### 개인 저작물 고지
    이 프로젝트는 **scroogy-dev**의 개인 저작물입니다. ...

    ```
    Copyright 2026 scroogy-dev (scroogy@naver.com)
    ```
    ```
  - **검증 결과**: ✓ 본 repo의 말미 블록과 동등한 형태가 자연스럽게 생성됨. 다만 LICENSE 파일이 없으므로 `(./LICENSE)` 링크는 깨진 링크 — Q1에 LICENSE 파일이 없을 때의 안내 필요 (특이 사항 참조).

  ---

  **시나리오 3: `--mode=init --profile=business` (가상 빈 디렉토리)**

  - **init-2 Q1**: profile=business → (c) 표시하지 않음 기본값 하이라이트 → 확인.
  - **init-2 Q2**: profile=business → 미포함 기본값 하이라이트 → 확인.
  - **init-3 템플릿 처리**:
    - 말미 블록: `footer-license` 통째 삭제 + `footer-notice` 통째 삭제 + `footer-copyright` 통째 삭제 (라이선스·고지 모두 없으므로)
  - **예상 결과 구조**:
    ```
    # <프로젝트명>
    > <한 줄 설명>

    ## 개요
    ...

    ## Quick Start
    ...
    ```
  - **검증 결과**: ✓ 말미 블록 전체가 자연스럽게 비어 회사 업무 README 관례에 맞음.

- **특이 사항**:
  - **Q1 분기 (a) + LICENSE 파일 없음**: 검증 중 발견된 누락. SKILL.md `init-4단계`를 "검증·저장"으로 확장해 LICENSE 파일 부재 시 사용자에게 생성을 권유하도록 보정 (이 Task에서 즉시 반영).
  - **시나리오 4·5 (옵션 — plan에 명시)**:
    - 시나리오 4(profile 미지정 + init): Q1·Q2를 프리셋 없이 그대로 제시 → 시나리오 2·3과 분기만 다를 뿐 동일 흐름. 명시적 추가 검증 불필요.
    - 시나리오 5(individual + 비공개 표기 (b)): `footer-license` 본문에 "All Rights Reserved" 채움 + `footer-notice` + `footer-copyright`. 의도된 결과로 단순. 명시적 추가 검증 불필요.
  - **본 repo의 자동 갱신 후보가 없는 것**은 update 모드의 한가운데 시나리오를 검증하기에는 약함. 추후 디렉토리 변동(예: 새 스킬 추가) 시점에 실제 적용해서 검증 보강 가능. 현재로서는 절차상 보존 정책이 명시되어 있어 충분.

---

### Task 7: AI-CONTEXT.md 스킬 목록 정합성 점검

- **결과**: 완료
- **수행 내용 요약**:

  - **비교 대상**:
    - AI-CONTEXT.md 스킬 목록 표의 `readme-sync` 행 (기존: "프로젝트를 분석하여 README.md 생성 또는 최신화")
    - SKILL.md frontmatter `description` + 모드/프로파일 (init·update, individual·business)
  - **갱신 패턴**: 같은 표의 `ai-workspace` 행이 "(dev/doc 프로파일 지원)" 형태로 모드/프로파일 정보를 인라인 괄호로 짧게 표기 → 동일 패턴 차용.
  - **갱신 결과**:
    ```
    | readme-sync | 프로젝트를 분석하여 README.md 생성 또는 최신화 (init/update 모드, individual/business 프로파일) |
    ```
  - **점검 범위**: `readme-sync` 한 행으로 한정. 디렉토리 구조 트리(line 70 `├── readme-sync/ # README.md 생성/갱신 스킬`)는 기능 요약만 두는 형태로 변경 불필요.

- **특이 사항**:
  - install-skills는 AI-CONTEXT.md 스킬 목록 표·README.md Skill 목록 표 모두 빠져 있음 (둘 다 "설치 방법" 섹션이나 별도 처리 패턴) — 의도된 분리로 보이며 본 Task 7 범위 밖이라 손대지 않음.
