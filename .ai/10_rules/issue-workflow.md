# 이슈 작업 워크플로우

## 디렉토리 구조

```
.ai/90_issues/
├── active/     ← 현재 진행 중인 이슈 디렉토리 (항상 읽음)
│   └── issue-<번호>/
│       ├── issue-<번호>-spec.md      ← 목표, 범위, 완료의 정의, 연관 문서
│       ├── issue-<번호>-plan.md      ← 실행 Task 목록 + 완료 체크박스
│       └── issue-<번호>-summary.md   ← 다음 작업, Task별 수행 결과
└── archive/    ← 완료 또는 종료된 이슈 디렉토리 (명시적 요청 시에만 읽음)
    └── issue-<번호>/   ← 이슈 디렉토리 단위로 active에서 이관
```

**AI 컨텍스트 적재 규칙:**
- `active/` 하위 파일은 작업 시작 시 **항상** 읽는다.
- `archive/` 하위 파일은 사용자가 명시적으로 언급하지 않는 한 **읽지 않는다.**

---

## 새 이슈 시작 시

1. `active/` 안에 있는 기존 이슈 디렉토리를 모두 `archive/`로 이동한다.
2. `active/issue-<번호>/` 디렉토리를 생성하고 `.ai/20_templates/`의 템플릿을 참조하여 아래 3개 파일을 생성한다.

| 파일명 | 참조 템플릿 | 역할 | 생명주기 |
|--------|------------|------|---------|
| `issue-<번호>-spec.md` | `issue-spec-template.md` | 목표, 범위, DoD, 연관 문서 | 안정 — 작성 후 거의 변경 없음 |
| `issue-<번호>-plan.md` | `issue-plan-template.md` | 실행 Task 목록 + 체크박스 | 가변 — Task 완료 시 체크, 실행 결과에 따라 Task 추가·수정·삭제 가능 |
| `issue-<번호>-summary.md` | `issue-summary-template.md` | 다음 작업, Task별 수행 결과 | 누적 — Task 완료 시마다 갱신 |

---

## 작업 진행 중

- Task 완료 시 `issue-<번호>-plan.md`의 해당 Task 체크박스를 체크한다.
- Task 완료 시 `issue-<번호>-summary.md`의 수행 결과를 갱신하고 다음 작업을 업데이트한다.

---

## 이슈 완료 시

1. `issue-<번호>-plan.md`의 모든 Task 체크박스가 체크되었는지 확인한다.
2. `issue-<번호>-summary.md` 상단의 다음 작업을 `✅ 모든 작업이 완료되었습니다.`로 업데이트한다.
3. `issue-<번호>/` 디렉토리를 `active/`에서 `archive/`로 디렉토리 단위로 이동한다.