---
last_synced: 2026-09-09
source_hash: 5ab2b67
status: current
---

# git-commit 검증 호출 흐름

## What

Conventional Commits 1.0.0 형식으로 커밋 메시지를 쓰고, 커밋 전에 헬퍼로 규격을 확인한다. 타입 표와 포맷의 SSoT는 SKILL.md다.

## How

```
git-commit/SKILL.md
├── 메시지 작성                        # `## 커밋 메시지 포맷`·`## 타입` 8종·`## 파괴적 변경`
└── scripts/validate-message.sh
    ├── --subject '<제목 줄>'          # 제목만 검사
    ├── [--allow-coauthor] <메시지 파일>   # 본문·꼬리말 포함, Co-Authored-By 는 명시 요청 시에만 허용
    ├── 판정: 타입·범위·설명·말미 " (#N)" 이슈 번호·빈 줄 규칙
    └── exit 0 통과(무출력) / 1 위반 사유 1행씩 / 2 사용오류
```

## Why

- `## 메시지 검증`에 눈으로 대조하지 않는 이유와 표를 고치면 헬퍼·`tests/` 기대값을 함께 갱신한다는 규칙이 있다.
- 분리 판단은 [architecture.md 디자인 원칙](../../10_rules/architecture.md)의 체크리스트(같은 입력에 같은 출력, 반복 호출, 기계 검증)를 통과한 경우다. 배치는 [ADR 0001](../../50_adr/active/0001-skill-deterministic-helper-test-convention.md). 체크리스트 자체와 임계 수치 미도입은 [ADR 0003](../../50_adr/active/0003-verification-levels-and-determinization.md).
- git-pr의 `validate-title.sh`와 규칙이 겹치지만 스킬 독립성 원칙으로 공유하지 않는다(그 스크립트 주석, [ADR 0002](../../50_adr/active/0002-skill-independence-intentional-duplication.md)).
