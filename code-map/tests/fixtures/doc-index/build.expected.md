# 기대 결과: build

## 색인 (`.ai/60_codebase/index.md`)

- frontmatter: `source_hash: c0ffee1`, `ssot_dir: docs/`, `status: current`, `last_synced`는 실행 일시
- 머리에 색인 루트 `docs/`를 적는다.
- 절 제목은 `docs/guides`·`docs/policies` 두 개다.
- 표는 `| 파일 경로 | 다루는 주제 | 관련 문서 |` 3열이다.

| 파일 경로 | 관련 문서 칸 |
|-----------|--------------|
| `docs/guides/onboarding.md` | 비어 있음 |
| `docs/policies/retention.md` | `../40_domain/policies/local/retention.md`, `../50_adr/active/0004-retention-period.md` 링크 |
| `docs/policies/refund.md` | `[WHY-NEEDED]` (교육비 환급 비율의 근거 요청) |

- 위 3행 밖의 행은 없다. `notes/`·`README.md`는 `ssot_dir` 밖이라 색인하지 않는다.
- `https://wiki.example.com/` 아래 URL은 색인 어디에도 없다.
- 존재하지 않는 `.ai` 문서를 가리키는 링크가 없다.

## 결과 보고

- 모드: build
- 색인 루트: docs/
- 문서 색인: 3건 (신규 3 / 갱신 0 / 삭제 0)
- 교차 참조: 30_contract 0건, 40_domain 1건, 50_adr 1건
- [WHY-NEEDED]: 1건
