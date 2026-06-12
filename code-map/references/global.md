# --global (building 모드) 실행 절차

> `code-map` 스킬의 참조 문서입니다. `--global` 모드 진입 시에만 읽습니다.
> 공통 원칙(SSoT, What/How/Why, 교차 참조 규칙, 태그 체계, 문서 메타데이터)은 [SKILL.md](../SKILL.md)를 따릅니다.

## 트리거 조건

- 멀티 리포 횡단 도메인 지식을 통합·관리할 때
- 공통 도메인 리포에서 작업할 때

## 전제 조건

- 현재 프로젝트는 **소스코드가 없는 문서 전용 리포**이다.
- 현재 프로젝트의 `.ai/60_codebase/repository.yaml`이 존재해야 한다.
- `repository.yaml`에 등록된 각 리포에는 이미 `--local`로 `.ai/60_codebase/index.md`가 존재해야 한다.
- 이 모드는 각 리포의 색인을 분석하여, `.ai/10_rules/` 아래에 리포 간 의존 관계·서비스 호출 흐름·공통 인프라 정보를 아키텍처 문서로 **생성·관리**하는 역할이다.

## repository.yaml

대상 리포 목록을 `.ai/60_codebase/repository.yaml`에 정의한다:

```yaml
org:
  workspace: /Users/dev/projects    # 리포들이 clone되는 상위 디렉토리
  repos:
    - https://github.com/our-org/auth-service
    - https://github.com/our-org/gateway
    - https://github.com/our-org/user-service
```

- 에이전트는 이 파일을 읽어 대상 리포를 결정한다.
- 파일이 없으면 사용자에게 생성을 안내하고 중단한다.
- 로컬 경로는 `workspace` + URL의 리포명으로 도출한다 (예: `/Users/dev/projects/auth-service`).
- `workspace` 경로에 해당 리포가 없으면 디폴트 브랜치로 clone한다.

## 파일 구조

이 스킬이 관리하는 파일:

```
.ai/
├── 10_rules/
│   ├── architecture.md              # 서비스 목록, 리포 간 의존 관계
│   ├── service-call-flows.md        # 서비스 간 호출 흐름
│   └── infra.md                     # 공통 인프라 정보
└── 60_codebase/
    ├── repository.yaml              # 대상 리포 목록 (workspace 경로 + URL)
    └── index.md                     # 건물 안내도 (최상위 진입점)
```

- `architecture.md`: 서비스 목록과 리포 간 의존 관계를 기록한다. `service-call-flows.md`, `infra.md`로의 링크를 포함한다.
- `service-call-flows.md`: 서비스 간 크로스-서비스 호출 흐름을 기록한다.
- `infra.md`: 공통 인프라 정보(메시지 브로커, 서비스 디스커버리, DB 등)를 기록한다.
- `60_codebase/index.md`(건물 안내도)는 리포 목록과 상태를 관리하며, 아키텍처 문서(`10_rules/`)로의 링크를 포함한다.

## 실행 절차

### 0단계: 리포 목록 확인 및 모드 결정

1. `.ai/60_codebase/repository.yaml`을 읽어 대상 리포 목록을 확인한다.
2. 파일이 없으면 사용자에게 `repository.yaml` 생성을 안내하고 중단한다.
3. 각 리포의 로컬 clone 경로를 탐색한다. 찾을 수 없는 리포는 `[REPO-NOT-FOUND]`로 표시하고 사용자에게 보고한다.
4. 각 리포의 `.ai/60_codebase/index.md` 존재 여부를 확인하여 분석 상태를 분류한다.
   - **분석 완료**: `.ai/60_codebase/index.md`에 내용이 있는 리포 → 동기화 대상
   - **미분석**: `.ai/60_codebase/index.md`가 없거나 비어 있는 리포 → 건너뛰고 `[NOT-INDEXED]`로 표시
5. `.ai/60_codebase/index.md`의 내용 유무에 따라 모드를 결정한다.
   - **비어 있음** → `build`(최초 생성) 실행
   - **내용 있음** → 사용자에게 선택 요청
     - `sync`: 각 리포의 변경분을 건물 안내도에 반영
     - `check`: 건물 안내도의 정합성 점검
     - `rebuild`: 전체 재생성

---

### 1단계: 수집 (floor → building)

0단계에서 분석 완료로 분류된 리포만 대상으로 정보를 수집한다.

1. **리포 스캔** — 각 리포의 `.ai/60_codebase/index.md`와 상세 호출 흐름 문서를 읽는다.
2. **변경 감지** — 이전 동기화 이후 변경된 색인을 식별한다.
3. **교차 참조 수집** — 각 리포 색인에 연결된 `.ai/30_contract/`, `.ai/40_domain/`, `.ai/50_adr/` 문서 목록을 수집한다.
4. **크로스-서비스 호출 식별** — 각 리포의 호출 흐름에서 다른 리포의 API를 호출하는 지점을 식별한다.

---

### 2단계: 아키텍처 문서 생성/갱신

각 리포의 색인에서 도출한 정보를 바탕으로 `.ai/10_rules/` 아래 3개 파일을 생성/갱신한다.

**architecture.md** — 서비스 목록, 의존 관계, 다른 문서로의 링크:

`````markdown
# 시스템 아키텍처

## 서비스 목록

| 서비스 | 역할 | 리포 |
|--------|------|------|
| auth-service | 인증/인가 | https://github.com/our-org/auth-service |
| gateway | API 게이트웨이 | https://github.com/our-org/gateway |
| user-service | 사용자 관리 | https://github.com/our-org/user-service |

## 서비스 간 의존 관계

```
gateway → auth-service      # 인증 토큰 검증
gateway → user-service      # 사용자 조회 프록시
auth-service → user-service # 사용자 인증 정보 조회
```

## 관련 문서

- [서비스 간 호출 흐름](service-call-flows.md)
- [공통 인프라](infra.md)
`````

**service-call-flows.md** — 크로스-서비스 호출 흐름:

`````markdown
# 서비스 간 호출 흐름

## 사용자 로그인

```
gateway#POST /api/login
└── auth-service#AuthController#login
    └── user-service#UserController#findByEmail (내부 API)
```
`````

**infra.md** — 공통 인프라 정보:

`````markdown
# 공통 인프라

- 메시지 브로커: Kafka (이벤트 발행/소비)
- 서비스 디스커버리: Eureka
- ...
`````

---

### 3단계: 건물 안내도 갱신

`.ai/60_codebase/index.md` (건물 안내도)를 생성/갱신한다.

```markdown
# 건물 안내도

## 리포 목록

| 리포 | 요약 | URL | 상태 | 마지막 동기화 |
|------|------|-----|------|---------------|
| auth-service | 인증/인가 서비스 | https://github.com/our-org/auth-service | 분석 완료 | 2026-04-08 |
| gateway | API 게이트웨이 | https://github.com/our-org/gateway | 분석 완료 | 2026-04-08 |
| user-service | 사용자 관리 서비스 | https://github.com/our-org/user-service | [NOT-INDEXED] | - |

## 아키텍처 문서

- [시스템 아키텍처](../10_rules/architecture.md)
- [서비스 간 호출 흐름](../10_rules/service-call-flows.md)
- [공통 인프라](../10_rules/infra.md)
```

---

### 4단계: 정합성 점검

`check` 모드 선택 시 1~3단계를 건너뛰고 이 단계만 실행한다.

| 점검 | 설명 |
|------|------|
| 리포 접근성 | `repository.yaml`에 등록된 리포가 로컬에 clone되어 있고 `.ai/60_codebase/index.md`가 존재하는지 |
| 안내도 불일치 | 건물 안내도의 리포 목록과 `repository.yaml`이 일치하는지 |
| 아키텍처 문서 유효성 | `architecture.md`의 서비스·의존 관계, `service-call-flows.md`의 호출 흐름, `infra.md`의 인프라 정보가 각 리포의 현재 색인과 일치하는지 |
| 교차참조 유효성 | 각 리포 색인에 연결된 `.ai/30_contract/`, `.ai/40_domain/`, `.ai/50_adr/` 문서가 실제 존재하는지 |

---

### 5단계: 결과 보고

사용자에게 요약을 보고한다.

   ```
   ## code-map --global 실행 결과

   - 모드: build | sync | check | rebuild
   - 대상 리포: N개 (분석 완료 N / [NOT-INDEXED] N / [REPO-NOT-FOUND] N)
   - 아키텍처 문서: architecture.md (신규 생성 | 갱신 | 변경 없음)
   - 서비스 간 의존 관계: N건
   - 서비스 간 호출 흐름: N건
   - 교차 참조 깨짐: N건

   > 아키텍처: .ai/10_rules/architecture.md
   > 안내도: .ai/60_codebase/index.md
   ```
