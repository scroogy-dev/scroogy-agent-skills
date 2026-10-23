# 원본 문서 색인 모의 실행 fixture

> `code-map/references/doc.md`(SSoT 선언이 원본 문서일 때의 `--local` 절차)에 대한 모의 실행 fixture입니다.
> issue #114 최종 감사 F-3(Task별 테스트 부재) 반영으로 둡니다. 절차 문장이 제자리에 있는지는 `../../run-tests.sh`가 [D]로 보고, 여기서는 절차를 입력에 적용한 결과를 봅니다.

## 실행 방법 ([QD] — AI가 채점)

1. AI가 `<케이스>.input.md`에 적힌 사용자 선택·안내도 머리·기존 색인·`git diff` 출력·문서 목록만 보고 doc.md 0~4단계를 적용한다. git 명령을 실제로 실행하지 않고 입력에 적힌 출력을 그대로 쓴다.
2. 결과 색인(`.ai/60_codebase/index.md`)과 결과 보고가 `<케이스>.expected.md`의 조건과 일치하면 통과다.
3. `다루는 주제` 칸의 문장 표현과 `[DOC-NEEDED]` 병기 여부는 판정하지 않는다. 행의 유무·파일 경로·관련 문서 링크·`[WHY-NEEDED]` 태그와 설명·frontmatter 값·보고의 모드와 판정 항목을 본다.

## 케이스

| 케이스 | 입력 상태 | 기대 결과 |
|--------|----------|----------|
| `build` | 빈 색인, `ssot_dir` `docs/`, `publish` 행 있음, 루트 밖 문서와 기존 `.ai` 문서 있음 | `docs/` 아래 파일만 행으로 만들고, 존재하는 문서만 링크하며, 근거 없는 규칙 문서는 `[WHY-NEEDED]`, 퍼블리싱 URL 없음 |
| `sync-same-root` | 루트 일치, `--name-status -M` 출력에 수정·삭제·루트 안 이름 변경·루트 밖으로 이동·루트 안으로 이동·루트 밖 추가 | 수정 행 갱신, 삭제 행 제거, 이름 변경은 Why 태깅을 새 행으로 옮김, 밖으로 나간 행 제거, 안으로 들어온 행 추가, 루트 밖 추가는 무시, 반영 후 `source_hash` 갱신 |
| `root-changed-sync` | 안내도 `ssot_dir`이 `docs/, handbook/`으로 넓어졌고 색인은 `docs/`, diff에는 안내도만 잡힘, 사용자가 `sync` 선택 | `rebuild`로 전환하고 사용자에게 알림, 새 루트의 기존 문서 행 추가, 기존 행의 Why 태깅 보존, 반영 후 frontmatter `ssot_dir` 갱신 |
| `root-changed-check` | 위와 같은 루트 불일치, 사용자가 `check` 선택 | 색인 행을 바꾸지 않고 색인 전체를 `[UPDATE-NEEDED]`로 보고, `rebuild` 권고, 색인을 최신으로 보고하지 않음 |
| `rename-check` | 루트 일치, `docs/old.md`가 `docs/remote-work.md`로 이름이 바뀐 뒤 `sync` 전에 사용자가 `check` 선택 | 색인 행과 frontmatter를 바꾸지 않음, 파일이 없는 `docs/old.md` 행을 Why 태깅과 함께 남기고 `[UPDATE-NEEDED]`로 보고. 이어지는 `sync`의 태깅 이전은 `sync-same-root`가 봄 |

install-skills 배포 시 `tests/`는 제외됩니다 (제외 규칙의 단일 출처는 `install-skills/SKILL.md` 설치 절차 5단계).
