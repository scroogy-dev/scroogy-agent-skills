# 입력: build

- 사용자 선택: 없음 (색인이 ai-workspace init 골격뿐이라 0단계가 `build`로 정한다)
- HEAD 커밋: `c0ffee1`
- 실행 일시: 2026-10-23 10:00

## 안내도 머리 (`.ai/AI-CONTEXT.md`)

```markdown
# AI-CONTEXT.md

> last updated: 2026-10-23
> SSoT: 원본 문서. 이 파일은 안내도일 뿐 진실의 원천이 아니다.

## 프로젝트 도메인

| 항목 | 값 |
|------|----|
| domain | 사내 인사 규정 문서 |
| keywords | 인사 규정, 기록 보관, 교육비 |
| ssot_dir | docs/ |
| publish | https://wiki.example.com/hr-handbook/ |
```

## 기존 색인 (`.ai/60_codebase/index.md`)

ai-workspace init이 복사한 템플릿 골격 그대로다.

```markdown
# 60_codebase 인덱스

이 디렉토리는 SSoT 색인을 보관합니다. SSoT 선언에 따라 소스코드의 엔트리포인트·호출 흐름 또는 원본 문서(`ssot_dir` 아래 문서 파일)의 지도를 담습니다.
AI는 구현이나 문서 내용 파악이 필요할 때 이 파일을 먼저 읽고, 관련된 SSoT(소스코드 또는 원본 문서)를 직접 읽어옵니다.

## 파일 목록

| 파일 | 설명 |
|------|------|
| (문서를 추가하면 이 목록에 함께 기재하세요) | |
```

## repo 문서 파일

| 경로 | H1 제목 | 머리 요약 | 근거 서술 |
|------|---------|-----------|-----------|
| `docs/policies/retention.md` | 인사 기록 보관 | 퇴사자 인사 기록을 3년 보관한 뒤 파기한다 | 있음 (분쟁 대응 기간) |
| `docs/policies/refund.md` | 교육비 환급 | 교육비는 수료 후 80%까지 환급한다 | 없음 (규칙만 적힘) |
| `docs/guides/onboarding.md` | 신규 입사자 안내 | 입사 첫 주 일정과 준비물 | 해당 없음 (안내 문서) |
| `notes/meeting-2026-09.md` | 9월 회의 메모 | 팀 회의 메모 | - |
| `README.md` | 인사 규정 문서 저장소 | 저장소 소개 | - |

## 기존 `.ai` 문서

- `.ai/40_domain/policies/local/retention.md` (인사 기록 보관 정책)
- `.ai/50_adr/active/0004-retention-period.md` (보관 기간 3년 결정)
