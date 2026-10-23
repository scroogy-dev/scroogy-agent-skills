# 입력: invalid-declaration

## 안내도 머리 (`.ai/AI-CONTEXT.md`)

```markdown
# AI-CONTEXT.md

> last updated: 2026-10-23
> SSoT: 위키. 이 파일은 안내도일 뿐 진실의 원천이 아니다.

## 프로젝트 도메인

| 항목 | 값 |
|------|----|
| domain | 인사 시스템 |
| keywords | 인사 기록, 보관 기간, 연차 |
| ssot_dir | docs/ |
```

## repo에 있는 사실

| 위치 | 내용 |
|------|------|
| `src/main/java/com/example/hr/RetentionJob.java` | 퇴사 후 3년이 지난 인사 기록을 파기하는 배치 |
| `docs/leave.md` | 연차는 입사 1년 후 15일을 부여한다. 코드에는 이 규칙이 없다 |

## 후보 자료

| # | 자료 | 위치 | 내용 |
|---|------|------|------|
| C1 | 회의록 "인사 기록 보관 기간 결정" | https://confluence.example.com/pages/301 | 퇴사자 기록을 3년 보관하기로 정한 이유(분쟁 대응 기간) |
| C2 | 가상 법령 「예시근로법」 제60조 | https://law.example.org/acts/60 | 1년 이상 근속자에게 연차 15일을 주도록 정한 조항, 시행일 2026-01-01 |
