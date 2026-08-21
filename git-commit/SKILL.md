---
name: git-commit
description: Conventional Commits 1.0.0 규칙에 따라 커밋 메시지를 작성합니다. 커밋, commit, 커밋 메시지 작성 시 사용합니다.
---

## 개요

[Conventional Commits 1.0.0](https://www.conventionalcommits.org/ko/v1.0.0/) 스펙에 따라 커밋 메시지를 작성합니다.

## 관련 skill

- ai-workspace (권장): `.ai/` 구조가 이미 존재하면 해당 구조를 따릅니다.

---

## 커밋 메시지 포맷

```
<타입>[적용 범위(선택)]: <설명> [(#이슈번호)(선택)]

[본문(선택)]

[꼬리말(선택)]
```

## 타입

| 타입 | 설명 |
|------|------|
| `feat` | 새 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서 변경 |
| `style` | 코드 의미에 영향 없는 변경 (포맷, 공백 등) |
| `refactor` | 기능 변경 없는 코드 구조 개선 |
| `test` | 테스트 추가 또는 수정 |
| `chore` | 빌드, 설정 등 기타 변경 |
| `ci` | CI/CD 설정 변경 |

## 파괴적 변경 (Breaking Change)

타입 뒤에 `!`를 붙이거나, 꼬리말에 `BREAKING CHANGE:` 를 명시합니다.

```
feat(api)!: 응답 구조 변경

BREAKING CHANGE: 기존 클라이언트와 호환되지 않습니다.
```

## 예시

```
feat: 사용자 인증 기능 추가
fix(auth): 토큰 만료 처리 오류 수정
docs: API 명세 업데이트
chore: 의존성 버전 업그레이드
```

## 메시지 검증

메시지를 작성한 뒤 커밋 전에 헬퍼로 규격을 확인합니다. 위 타입 표와 포맷을 눈으로 대조하지 않습니다.

```bash
# <skill 디렉토리>는 이 SKILL.md가 있는 디렉토리. 실행 시 실제 경로로 바꿔 씁니다.
validate='<skill 디렉토리>/scripts/validate-message.sh'

"$validate" --subject 'fix(auth): 토큰 만료 처리 오류 수정'   # 제목 초안만 확인
"$validate" /tmp/commit-message.txt                          # 본문·꼬리말까지 확인
```

통과하면 아무것도 출력하지 않고 종료 코드 0을 냅니다. 규격 위반은 종료 코드 1과 함께 사유를 1행씩 출력하며, 인자 오류는 종료 코드 2입니다.
`Co-Authored-By:` 꼬리말을 사용자가 명시적으로 요청했으면 `--allow-coauthor`를 붙입니다.

위 타입 표와 포맷이 SSoT이며, 표를 고치면 헬퍼와 `tests/`의 기대값을 함께 갱신합니다.

## 주의사항

- `Co-Authored-By:` 꼬리말은 사용자가 명시적으로 요청한 경우에만 작성합니다.
