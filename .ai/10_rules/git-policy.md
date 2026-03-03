# Git 운영 정책

## 커밋 메시지 규칙

[Conventional Commits 1.0.0](https://www.conventionalcommits.org/ko/v1.0.0/) 스펙을 따릅니다.

### 포맷

```
<타입>[적용 범위(선택)]: <설명>

[본문(선택)]

[꼬리말(선택)]
```

### 타입

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

### 파괴적 변경 (Breaking Change)

타입 뒤에 `!`를 붙이거나, 꼬리말에 `BREAKING CHANGE:` 를 명시합니다.

```
feat(api)!: 응답 구조 변경

BREAKING CHANGE: 기존 클라이언트와 호환되지 않습니다.
```

### 예시

```
feat: 사용자 인증 기능 추가
fix(auth): 토큰 만료 처리 오류 수정
docs: API 명세 업데이트
chore: 의존성 버전 업그레이드
```

### 주의사항

- `Co-Authored-By:` 꼬리말은 사용자가 명시적으로 요청한 경우에만 작성합니다.

---

## PR 규칙

<!-- PR 규칙을 추가하세요. -->
