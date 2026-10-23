# 입력: doc-publish

## 안내도 머리 (`.ai/AI-CONTEXT.md`)

```markdown
# AI-CONTEXT.md

> last updated: 2026-10-23
> SSoT: 원본 문서. 이 파일은 안내도일 뿐 진실의 원천이 아니다.

## 프로젝트 도메인

| 항목 | 값 |
|------|----|
| domain | 사내 인사 규정 문서 |
| keywords | 인사 규정, 연차, 기록 보관 |
| ssot_dir | docs/ |
| publish | https://wiki.example.com/hr-handbook/ |
```

## SSoT에 반영된 사실 (`docs/` 아래 원본 문서)

| 위치 | 반영된 사실 |
|------|-------------|
| `docs/leave.md` | 연차는 입사 1년 후 15일을 부여한다 |
| `docs/retention.md` | 퇴사자 인사 기록은 3년 보관한 뒤 파기한다 |

## 후보 자료

| # | 자료 | 위치 | 내용 |
|---|------|------|------|
| C1 | 위키 페이지 "연차 안내" | https://wiki.example.com/hr-handbook/leave | `docs/leave.md`를 위키 서식으로 옮긴 페이지 |
| C2 | 가상 법령 「예시근로법」 제60조 | https://law.example.org/acts/60 | 1년 이상 근속자에게 연차 15일을 주도록 정한 조항, 시행일 2026-01-01 |
| C3 | 회의록 "인사 기록 보관 기간 결정" | https://confluence.example.com/pages/301 | 퇴사자 기록을 3년 보관하기로 정한 이유(분쟁 대응 기간) |
| C4 | GitHub 이슈 "반차 단위 연차 도입 요청" | https://github.example.com/hr-docs/issues/7 | 반차 단위 연차 요청. `docs/`에 반영되지 않음 |
