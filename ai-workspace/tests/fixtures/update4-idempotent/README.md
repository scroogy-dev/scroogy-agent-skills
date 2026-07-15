# update-4 멱등 보강 검사 fixture

> `ai-workspace/SKILL.md` update-4단계 "멱등 보강 검사"의 `## 프로젝트 규칙` 관련 3개 항목
> (섹션·3열 표 존재, `context-loading.md` 행, `writing-principles.md` 행)에 대한 모의 실행 fixture입니다.
> issue #41 audit F-3(모의 실행 재현성 부재) 반영으로 보존합니다.
> 케이스명에 `-doc` 접미사가 없으면 **dev 프로파일 기준**, 있으면 **doc 프로파일 기준**입니다.

## 실행 방법 ([QD] — AI가 채점)

1. AI가 `<케이스>.input.md`를 대상으로 SKILL.md update-4 멱등 보강 검사 중 `## 프로젝트 규칙` 관련 3개 항목을 적용한다.
2. 결과가 `<케이스>.expected.md`와 일치하면 통과.
3. **2회 실행(멱등)**: `<케이스>.expected.md`를 다시 입력으로 같은 검사를 적용했을 때 변경 0건이면 통과.

## 케이스

| 케이스 | 입력 상태 | 기대 결과 |
|--------|----------|----------|
| `no-rules-section` | `## 프로젝트 규칙` 섹션이 통째로 없음 | `## 프로젝트 목적` 바로 다음에 dev 템플릿 골격(안내 주석 + 선행 적용 문구 + 3열 표) 삽입, 사용자 섹션(`## 기술 스택`) 보존 |
| `no-rules-table` | 섹션은 있으나 표가 없고 인라인 규칙만 있음 | 인라인 규칙 보존한 채 섹션 끝에 dev 템플릿 3열 표 삽입 |
| `legacy-two-col` | 2열(파일·설명) 구버전 표 + 사용자 행 | 헤더·구분선만 3열로 확장(사용자 행의 `사용 시점`은 `<사용 시점>` placeholder), 표 끝에 표준 행 2개 삽입 — 기존 표에 구버전 기본 행(`architecture.md` 등)은 보충하지 않음 |
| `missing-rows` | 3열 표에 표준 행 2개(`context-loading.md`·`writing-principles.md`) 누락 | 표 끝에 표준 행 2개 삽입, 기존 행·사용자 행 보존 |
| `missing-rows-doc` | 위와 같으나 **doc 프로파일** | 표 끝에 표준 행 2개 삽입하되 `context-loading.md` 사용 시점은 dev("코드·문서 작업 전")가 아닌 **"문서 작업 전"** — 프로파일별 문구 분기 회귀 검증 |

> `legacy-two-col`의 열 확장 범위는 "열 확장만"입니다 — 구버전 기본 행 복원은 별도 경로인 SKILL.md `#### 구버전 구조 마이그레이션`(→ `references/legacy-migration.md` ②)이 담당하며, 이 fixture의 검사 범위가 아닙니다.

install-skills 배포 시 `tests/`는 제외됩니다 (제외 규칙의 단일 출처는 `install-skills/SKILL.md` 설치 절차 5단계).
