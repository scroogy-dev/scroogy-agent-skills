# update-3 기존 파일 정리 fixture

> `ai-workspace/SKILL.md` update-3단계 `#### 기존 파일 정리`의 이동 판단 기준 표와 루트 상주 파일 제외 규칙에 대한 모의 실행 fixture입니다.
> 원장 K-0001(update-3 회귀 fixture 부재) 해소로 issue #121에서 둡니다. 판단 기준 표의 디렉토리 5행과 루트 상주 파일·`legacy/`를 함께 덮습니다.
> 케이스 표의 `대상 행`이 판단 기준 표의 디렉토리를 모두 덮는지와 케이스 쌍이 있는지는 `../../run-tests.sh`가 [D]로 보고, 여기서는 규칙을 입력에 적용한 결과를 봅니다.

## 실행 방법 ([QD] — AI가 채점)

1. AI가 `<케이스>.input.md`에 적힌 디렉토리 루트의 파일만 보고 SKILL.md update-3 `#### 기존 파일 정리`를 적용한다. 하위 디렉토리(`active/` 등)는 이미 만들어져 있다고 본다.
2. 파일마다 이동 위치(`active/`·`superseded/`·`archive/`·`specs/`·`policies/local/`·`legacy/`·`루트 유지`)를 정한다.
3. 결과가 `<케이스>.expected.md`의 이동 표와 일치하면 통과다. 근거 열의 문장 표현은 같은 규칙을 가리키면 통과로 본다.

## 케이스

| 케이스 | 대상 행 | 입력 상태 | 기대 결과 |
|--------|---------|----------|----------|
| `domain` | `40_domain/`·`40_domain/policies/`·루트 상주 파일·`legacy/` | `40_domain/` 루트에 기능 명세·정책·메모·`index.md`·`glossary.md`, `policies/` 루트에 정책 파일 | 명세는 `specs/`, 정책과 `policies/` 바로 아래 파일은 `policies/local/`, 어느 쪽도 아닌 메모는 `legacy/`, `index.md`·`glossary.md`는 루트 유지 |
| `adr` | `50_adr/`·루트 상주 파일 | 상태 줄 값이 `대체`·`폐기`·`유효`인 ADR, 상태 줄 없이 본문에 `superseded` 낱말이 있는 ADR, `index.md` | `대체`·`폐기`는 `superseded/`, `유효`와 상태 줄 없는 ADR은 `active/`, `index.md`는 루트 유지. 상태 줄 없는 ADR은 본문 키워드로 판정하던 옛 기준의 회귀 반례 |
| `ledger` | `70_ledger/`·루트 상주 파일 | 상태 값이 `승격`·`해소`·`수용`인 항목, `index.md`·`ledger-entry-template.md` | `승격`·`해소`는 `archive/`, `수용`은 `active/`, `index.md`·`ledger-entry-template.md`는 루트 유지 |
| `issues` | `90_issues/` | Task 체크박스가 모두 완료된 plan, 완료 표시가 있는 summary, 미완료 Task가 남은 plan | 완료된 plan과 완료 표시가 있는 summary는 `archive/`, 미완료 Task가 남은 plan은 `active/` |

install-skills 배포 시 `tests/`는 제외됩니다 (제외 규칙의 단일 출처는 `install-skills/SKILL.md` 설치 절차 5단계).
