---
last_synced: 2026-09-09
source_hash: 5ab2b67
status: current
---

# ai-workspace-directory update 호출 흐름

## What

기존 로비를 진단(SSoT 위배·로비 역할 위배·drift·형식)하고 재구성안을 제시한 뒤 승인받아 덮어쓴다. floor로 옮길 본문은 목록만 내고 파일을 수정하지 않는다.

## How

```
ai-workspace-directory/SKILL.md
├── 1단계: 모드 결정                  # update→init 전환 시 덮어쓰기 재확인·수동 백업 안내
├── update-0단계: 입력 수집
├── update-1단계: 진단 리포트 출력
│   ├── references/ssot-checklist.md   # SSoT 위배 항목
│   ├── 로비 역할 위배 판정            # 정책 본문·도메인 본문 중복
│   ├── drift·메타 일치 검사           # 각 repo `## 프로젝트 도메인` domain/keywords ↔ Repos 행
│   └── scripts/check-lobby.sh <파일>  # 형식 위배 8종 1행씩·exit 1 (frontmatter·last updated·SSoT 문구·H2 순서·Repos 4열·status 열거값·진입 절차)
├── update-2단계: 재구성 로비 전문 출력   # "이대로 덮어쓸까요?" 승인 게이트
├── update-3단계: floor 이동 후보 목록    # YAML, target_location_hint 로 repo `.ai/40_domain/…` 제안, 파일 미수정
└── update-4단계: 보고
```

## Why

- 설계 근거는 init 흐름과 같은 `### 대전제`·`### 산출물의 본질`이다. 로비에 도메인 본문이 쌓이면 SSoT가 갈라지므로 이동 후보만 내고 실제 이동은 사람이 한다.
- `check-lobby.sh`의 형식 검사 8종은 `references/standard-structure.md`가 정한 골격의 사본이다.
- 명세: [.ai 작업공간과 안내도 요건](../../40_domain/specs/ai-workspace.md)(`status: placeholder`·`archived`는 drift 검사 제외, `Repos` 4열 1:1 동기화).
- 정책: [SSoT 원칙과 안내도 라우터](../../40_domain/policies/local/ssot-and-router-principle.md)(로비에 도메인 본문·코드 스니펫·운영 정보·상세 목차를 두지 않는 근거).
- 헬퍼·테스트 배치는 [ADR 0001](../../50_adr/active/0001-skill-deterministic-helper-test-convention.md).
