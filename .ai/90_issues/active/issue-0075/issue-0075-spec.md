# Issue #75 스펙 — git-review 테크 리뷰 카테고리 상세화·역피라미드 결과 구조

> 스펙 출처: https://github.com/scroogy-dev/scroogy-agent-skills/issues/75

## 목표 (Goal)

git-review 결과가 "최종 의견 → 요약 대시보드 → 카테고리별 상세(접기)"의 역피라미드 구조로 기록되고,
테크 리뷰가 7개 카테고리로 상세화되어 카테고리별 건수·상태가 위험도에서 결정적으로 산출된다.

---

## 범위 (Scope)

**포함 (In)**

- `git-review/SKILL.md` 테크 리뷰 절차: 7개 카테고리(기능, 아키텍처, 버그, 보안, 코드품질, 성능, 테스트) 검증으로 상세화
- 카테고리 상태 산출 규칙 신설 — 카테고리 내 최고 위험도 → 상태의 결정적 매핑 (비즈니스·테크 리뷰 상태도 같은 규칙)
- 결과 기록 형식(`temp_review_result.md`) 역피라미드 구조로 교체 — 최종 의견·요약 대시보드(리뷰 상태·검토 파일 수·카테고리별 건수·상태) 상단, 카테고리 상세 접기
- 결과 기록 형식을 `git-review/templates/review-result-template.md`로 분리 — SKILL.md는 템플릿 참조만 유지, 임베드 형식 블록 제거 (`issue-audit`·`issue-work` 선례)
- `.ai/AI-CONTEXT.md` 디렉토리 구조 트리에 `git-review/templates/` 행 추가 — 구조 변경 시 참조 갱신
- 카테고리 검증의 상호 독립(순서 무관) 성질 명시 — 실행 방식(서브에이전트 병렬 등) 지시는 넣지 않음
- 카테고리 체계의 원본 정의 명시 — `issue-audit`이 후속(#76)에서 복사·동기화

**비포함 (Out)**

- `issue-audit` 반영 — #76 후속 이슈
- 비즈니스 리뷰 절차 변경 — 결과 형식에 상태·리뷰 포인트만 편입
- 위험도 분류(2축·매트릭스) 변경 — #72 체계 유지 (원장 K-0002의 재검토 조건 "위험도 분류 소절 재수정 시"를 발동시키지 않음)
- `.ai/10_rules/writing-principles.md` 변경 — ai-workspace 동기화 대상
- 대화창 출력 형식 신설·접기 적용 — 접기는 파일 산출물·PR 코멘트 한정

---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단

- [x] [D] 테크 리뷰에 7개 카테고리가 전부 표 행으로 정의된다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for c in 기능 아키텍처 버그 보안 코드품질 성능 테스트; do
    grep -qE "^\| $c \|" git-review/SKILL.md || echo "누락: $c"
  done
  ```

  - 설계 주의: 결과 기록 형식 예시 표에도 카테고리 행이 등장할 수 있어 개수 대신 카테고리별 존재를 판정한다.
  </details>
- [x] [D] 상태 산출 매핑 표가 존재하고 위험도 등급 앵커 행을 갖는다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for g in '높음\(HIGH\)' '중간\(MEDIUM\)' '낮음\(LOW\)'; do
    grep -qE "^\| ${g}" git-review/SKILL.md || echo "누락: ${g}"
  done
  ```

  - 설계 주의: 위험도 매트릭스 표의 행은 영향 축 값으로 시작하므로 등급으로 시작하는 행은 매핑 표에만 있다.
  </details>
- [x] [D] 위험도 분류 소절은 변경되지 않는다 (K-0002 재검토 조건 비발동)
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  diff <(git show main:git-review/SKILL.md | awk '/^## 위험도 분류$/{f=1;print;next} f&&/^## /{exit} f') \
       <(awk '/^## 위험도 분류$/{f=1;print;next} f&&/^## /{exit} f' git-review/SKILL.md)
  ```

  </details>
- [x] [D] 리뷰 결과 템플릿의 섹션 순서가 역피라미드(최종 의견 → 요약 → 비즈니스 리뷰 → 테크 리뷰)다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -E '^## ' git-review/templates/review-result-template.md \
    | head -4 | paste -sd'|' - \
    | grep -qx '## 최종 의견|## 요약|## 비즈니스 리뷰|## 테크 리뷰' \
    || echo '위반: 템플릿 섹션 순서 불일치'
  ```

  - 설계 주의: 형식이 SKILL.md 임베드 블록에서 템플릿 파일로 분리되어 앵커도 템플릿 파일 기준이다.
  </details>
- [x] [D] 요약 대시보드에 비즈니스 리뷰 상태·테크 리뷰 상태·검토 파일 수 필드가 있다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  for t in '비즈니스 리뷰' '테크 리뷰' '검토 파일'; do
    grep -q "$t" git-review/templates/review-result-template.md || echo "누락: $t"
  done
  ```

  </details>
- [x] [D] 결과 기록 형식이 템플릿 파일로 분리되고 SKILL.md는 참조만 남는다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  [ -f git-review/templates/review-result-template.md ] || echo '누락: 템플릿 파일'
  grep -q 'templates/review-result-template.md' git-review/SKILL.md || echo '누락: SKILL.md 템플릿 참조'
  ! grep -q '^```markdown' git-review/SKILL.md || echo '위반: SKILL.md 임베드 형식 블록 잔존'
  grep -qE '^│   └── templates/' .ai/AI-CONTEXT.md && grep -B1 -E '^│   └── templates/.*리뷰 결과' .ai/AI-CONTEXT.md | grep -q 'git-review/' \
    || echo '누락: AI-CONTEXT 디렉토리 트리 git-review/templates/ 행'
  ```

  - 설계 주의: 임베드 잔존 판정은 현 시점 SKILL.md에 ```` ```markdown ```` 블록이 형식 블록 하나뿐이라는 사실에 의존한다 — 다른 markdown 블록을 추가하는 후속 작업에서는 앵커를 재설계한다.
  </details>
- [x] [D] 카테고리 검증의 상호 독립 성질과 카테고리 체계 동기화 주석이 명시된다
  <details>
  <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

  ```bash
  grep -q '상호 독립' git-review/SKILL.md || echo '누락: 상호 독립'
  [ "$(grep -c '양쪽 동기화' git-review/SKILL.md)" -ge 2 ] || echo '누락: 카테고리 동기화 주석'
  ```

  - 설계 주의: `양쪽 동기화`는 위험도 분류에 1건 기존재하므로 카테고리 추가분 포함 2건 이상으로 판정한다.
  </details>
- [ ] [QD] 카테고리 상태·리뷰 상태가 리뷰어 재량 없이 산출되도록 규칙이 서술된다  (검증: 교차모델 audit이 채점)  ← 강등 사유: 서술이 재량을 봉쇄하는지는 의미 판단이라 명령으로 환원 불가
- [ ] [ND] 역피라미드 구조가 결론 파악을 앞당긴다는 목적을 달성한다  (검증: 사람 리뷰)  ← 강등 사유: 가독성은 주관 판단

---

## 전제 (Assumptions)

- 카테고리 상태 값 명칭: **통과(PASS) / 주의(WARN) / 보완 필요(FAIL)** 3단계, 한글 우선 병기 (#46 관례) — Task 0 질의로 사용자 확정 (2026-08-07)
- 낮음(LOW)·정보(INFO)만 있는 카테고리의 상태: **통과** — 등급별 처리 기준을 두지 않는 #72 철학(낮음·정보는 우선순위 신호일 뿐 보완 강제 아님)과 정합 — Task 0 질의로 사용자 확정 (2026-08-07)
- 검토 파일 수는 리뷰 대상 diff의 변경 파일 수로 센다
- 발견 0건 카테고리도 요약 대시보드 표에는 남긴다(검증을 수행했다는 증거). 테크 리뷰 본문의 카테고리별 소절은 발견이 있는 카테고리만 둔다
- 카테고리 상세 접기의 접기 제목에는 카테고리명이 드러나게 한다 — 접힌 상태에서도 무엇의 상세인지 보이게
- git-review에는 대화창 출력 형식 정의가 원래 없으며 이번에도 신설하지 않는다 (범위 외)
- 결과 기록 형식은 SKILL.md 임베드가 아니라 `templates/review-result-template.md`로 분리한다 — 사용자 요청 (2026-08-07). 파일명은 산출물 기준 `<산출물>-template.md` 관례(`issue-audit-report-template.md` 선례)를 따른 선택
- 템플릿 분리 후에도 산출 경로는 `.ai/99_workspace/temp_review_result.md` 그대로다 — 분리 대상은 형식 정의이지 산출물 위치가 아니다

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `git-review/SKILL.md` | 수정 대상 — 테크 리뷰 절차·상태 산출·결과 기록 형식 참조 |
| `git-review/templates/review-result-template.md` | 신설 대상 — 리뷰 결과 형식의 SSoT (SKILL.md에서 분리) |
| `issue-audit/templates/issue-audit-report-template.md` | 템플릿 분리·명명 선례 |
| `issue-audit/SKILL.md` | 위험도 체계의 원본이자 카테고리 체계의 복사 대상(#76 후속) |
| `.ai/10_rules/writing-principles.md` | 역피라미드·접기 기준의 상위 원칙 (템플릿 우선 규칙 확인용) |
| `.ai/70_ledger/index.md` (K-0002) | 위험도 분류 소절 재수정 시 재검토 조건 — 이번 범위에서 비발동 확인 |
| GitHub #72 | 위험도 매트릭스 도입 선례 — 상태 산출이 계승하는 철학 |
| GitHub #76 | 후속 이슈 — issue-audit 카테고리 복사·동기화 |
