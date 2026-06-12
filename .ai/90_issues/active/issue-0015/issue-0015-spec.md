# Issue #0015 스펙 issue-work 스킬에 정리 옵션 추가

> 원본 이슈: [scroogy-dev/scroogy-agent-skills#15](https://github.com/scroogy-dev/scroogy-agent-skills/issues/15)

## 목표 (Goal)

issue-work 스킬에 이슈 마무리 정리 옵션을 추가하여, 이슈 디렉토리 archive 이관과 99_workspace 정리, 이슈 댓글 요약 등록을 하나의 옵션으로 수행할 수 있게 한다.

---

## 범위 (Scope)

**포함 (In)**

- 정리 옵션의 옵션명 결정 (이슈 검토사항)
- `issue-work/SKILL.md`의 `## 옵션` 섹션에 새 옵션 정의 추가
  1. 이슈 디렉토리를 `active/` → `archive/`로 이동
  2. `.ai/99_workspace/` 정리
  3. 이슈 댓글로 작업내용 요약을 추가할 것인지 사용자에게 질의 후 진행
- 기존 `## 이슈 완료 시` 절차와의 관계(중복·대체 여부) 정리

**비포함 (Out)**

- 다른 스킬 변경
- 이슈 시작·진행 단계 절차 변경
- 템플릿 파일 구조 변경

---

## 완료의 정의 (Definition of Done)

- [ ] 정리 옵션의 이름이 결정되어 `issue-work/SKILL.md`에 반영됨
- [ ] 옵션 실행 시 이슈 디렉토리가 `active/` → `archive/`로 이동하는 절차가 정의됨
- [ ] `.ai/99_workspace/` 정리 절차(정리 대상·보존 대상)가 정의됨
- [ ] 이슈 댓글 요약 등록 여부를 사용자에게 질의 후 진행하는 절차가 정의됨
- [ ] 기존 `## 이슈 완료 시` 절차와 새 옵션의 관계가 본문에서 모순 없이 설명됨
- [ ] 클로드 코워크에서 skill-creator 스킬로 점검 완료 (이슈 참고사항)

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `issue-work/SKILL.md` | 수정 대상 스킬 본문 (옵션 섹션) |
| `issue-work/templates/` | 절차 변경 시 정합성 확인 대상 |
| `.ai/10_rules/file-change-policy.md` | 파일·디렉토리 이동/삭제 규칙 |
| `.ai/AI-CONTEXT.md` | 스킬 설명 변경 시 동기화 대상 |
