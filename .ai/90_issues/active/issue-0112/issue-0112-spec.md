# Issue #112 스펙 issue-work·issue-audit: 구현 테스트를 Task별 작업 내용·완료 기준에 두는 배치 규칙 도입과 계획·구현 테스트 관점 분리

## 목표 (Goal)

issue-work로 세운 계획이 계획 관점(인수) 테스트와 구현 관점 테스트를 구분해 구현 테스트를 각 Task 안에 두고, issue-audit 최종 감사가 그 배치를 기준으로 테스트 충분성을 판정한다.

---

## 요구사항 (Requirements)

<!--
목표를 무엇으로 달성하는지 적는 자리다. 산출물(파일) 목록 대신 동작·보장 중심으로 쓴다.
- 포함: 이 이슈로 가능해져야 하는 것을 R1, R2… 번호와 한 문장으로 열거한다.
  이 번호를 완료의 정의(그룹 제목)와 실행계획 Task(`대상 요구사항` 필드)가 참조한다.
- 제외: 검토했지만 요구하지 않는 것을 이유 한 줄(보류·대체·불필요)과 함께 적는다.
  경계 선언은 이 목록이 담당한다. 추적 대상이 아니므로 번호를 붙이지 않는다.
- 근거 표기: GitHub 이슈 본문에 근거가 없는 항목(대화·추론으로 더한 것)은 문장 끝에 그 사실과 출처를 병기한다
  (예: "(이슈 본문 근거 없음. YYYY-MM-DD 대화에서 결정)"). 승인 요청에서 따로 표시되어 확정·제외를 질의받는다.
- 함께 해소 표기: 3-1에서 포함한 원장 항목(함께 해소 후보)은 R 문장 끝에 `(함께 해소: K-<번호>)`를 병기한다.
  이슈 완료 시 원장 해소 기재가 이 표기로 종결 대상을 찾는다.
이 섹션까지 쓴 뒤 사용자 승인을 받고, 승인 뒤에 완료의 정의·plan·summary를 쓴다 (issue-work SKILL.md "새 이슈 시작 시" 3-1·3-2).
아래 예시를 지우고 실제 항목으로 교체하세요.
-->

**포함**

- R1: issue-work SKILL.md "완료 기준 형식"과 spec 템플릿 완료의 정의 주석이 계획 관점 테스트와 구현 관점 테스트의 구분을 안내한다. spec DoD `[D]`는 외부 경계(명령 인자·종료 코드·출력 행·파일 내용)의 인수 테스트이며, 경계가 spec에 고정되면 테스트 러너 호출로 적을 수 있고 그렇지 않으면 명령 수준으로 둔다. 구현 관점 테스트는 plan Task가 맡는다.
- R2: issue-work plan 템플릿 일반 Task의 `작업 내용`·`완료 기준` 주석이 Task별 테스트 배치 규칙을 안내한다. 그 Task 기능의 테스트 작성(fixture·기대 출력)을 작업 단계로 포함하고 테스트 파일을 Task 산출물로 두며, `완료 기준`에 `[D]` "이 Task의 테스트 0 실패" 형태를 예시로 보인다. 별도 테스트 Task는 테스트 자체가 작업 대상일 때만 두고, 전체 테스트 통과는 spec `### 공통` 회귀 방지 항목으로 유지한다.
- R3: issue-audit 최종 감사 2단계 관점 5 "누락된 검증"이 구현 Task마다 테스트 `[D]`가 있는지와 그 테스트가 해당 Task의 변경을 실제로 덮는지를 판단 기준으로 둔다. 카테고리 표의 "테스트" 정의 문구는 바꾸지 않는다(git-review 원본의 사본이라 동기화 의무가 생김). 리포트 템플릿의 테스트 행에는 필요하면 안내 주석만 둔다.
- R4: issue-audit 최종 감사 1단계 완료의 정의 대조가 `[D]` 항목의 검증 명령을 실제로 실행해 그 결과를 판정 근거로 삼도록 지시한다. (이슈 본문은 "둘지 함께 검토한다"로 남김. 2026-10-13 요구사항 승인 시 포함 확정)
- R5: 안내도 `.ai/40_domain/specs/issue-workflow.md`·`.ai/40_domain/specs/issue-audit.md`·`.ai/60_codebase/issue-audit/final-audit-call-flow.md`가 R1~R4의 변경을 반영한다. ADR 0003과 결정 변경 범위를 대조해 결정이 바뀌면 새 ADR로 기록한다.

**제외**

- ai-workspace dev 프로파일 템플릿(`coding-convention.md` 등)에 테스트 작성 가이드 추가: repo별 코딩 컨벤션 영역이라 별도 이슈로 검토(보류).
- 가짜 `[D]` 사전 판별의 헬퍼 결정화(K-0009 본건): 이슈 본문이 범위에서 제외(보류).
- git-review 카테고리 표 동기화: R3이 정의 문구를 바꾸지 않으므로 발생하지 않음(불필요).
- 테스트 작성 Task를 고정 블록으로 추가: Task 독립 검증 원칙과 어긋나고 테스트가 구현을 사후 추인하는 형태가 됨(대체: R2).
- DoD 전체를 테스트 파일로 결정화: 경계가 구현 중 정해지는 작업에서는 계획 단계에 쓸 수 없음(대체: R1의 조건부 허용).
---

## 완료의 정의 (Definition of Done)

> **검증 레벨** — 낮을수록 좋다(자동 검증에 가까움). 기본은 L1, 한 레벨 내릴 때마다 강등 사유를 함께 적는다.
>
> - `[D]`  L1 결정적   — 명령이 합/불을 판정, 사람 판단 없음
> - `[QD]` L2 준결정적 — 다른 AI·기준 체크리스트가 채점
> - `[ND]` L3 비결정적 — 사람이 직접 읽고 판단
>
> 검증 명령은 모두 repo 루트에서 실행한다. 구현 테스트(러너 케이스 편입)는 이 DoD가 아니라 plan Task 완료 기준이 맡는다(`## 전제` 참조).

### R1: 계획·구현 테스트 관점 구분

- [ ] [D]  issue-work SKILL.md "완료 기준 형식" 절에 테스트 관점 규칙 행이 정확히 1개 있고, 그 행이 인수 테스트와 plan Task의 역할 분담을 담는다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^### 완료 기준 형식$/ { s = 1; next } /^#/ { s = 0 }
       s && /^- \*\*테스트 관점\*\*: / { n++; if ($0 !~ /인수 테스트/ || $0 !~ /Task/) print "위반: 테스트 관점 행에 인수 테스트 또는 Task 언급 없음" }
       END { if (n != 1) print "위반: 테스트 관점 행 " n + 0 "개 (기대 1개)" }' issue-work/SKILL.md
  ```

  - 설계 주의: 절 범위를 다음 헤더(`^#`)까지로 잘라, 같은 문구가 다른 절에 있어도 세지 않는다.
  </details>
- [ ] [D]  spec 템플릿 완료의 정의 안내 주석에 테스트 관점 행이 정확히 1개 있고 인수 테스트를 언급한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^## 완료의 정의 \(Definition of Done\)$/ { s = 1; next } /^## / { s = 0 }
       s && /^- 테스트 관점: / { n++; if ($0 !~ /인수 테스트/) print "위반: spec 템플릿 테스트 관점 행에 인수 테스트 언급 없음" }
       END { if (n != 1) print "위반: spec 템플릿 테스트 관점 행 " n + 0 "개 (기대 1개)" }' issue-work/templates/issue-spec-template.md
  ```

  </details>
- [ ] [QD] 두 관점 구분 서술이 ADR 0003의 검증 레벨 결정과 `architecture.md`의 "두 체계는 적용 대상이 다르다"와 충돌하지 않는다  (검증: 감사 모델이 세 문서 대조 채점)  ← 강등 사유: 규칙 간 정합은 의미 대조라 명령으로 환원 불가

### R2: plan 템플릿 Task별 테스트 배치

- [ ] [D]  plan 템플릿 `## Tasks` 머리말에 테스트 배치 규칙 blockquote 문단이 정확히 1개 있고, 별도 테스트 Task 조건 문구(`테스트 자체가 작업 대상`)와 공통 회귀 항목 문구(`회귀 방지`)를 언급한다. 규칙 의미는 아래 `[QD]`가 본다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^## Tasks$/ { s = 1 } /^### Task 0/ { s = 0 }
       s && /^> \*\*테스트 배치\*\*/ { p = 1; n++ }
       p && (/^>[[:space:]]*$/ || !/^>/) { p = 0 }
       p { t = t $0 }
       END { if (n != 1) print "위반: 테스트 배치 규칙 " n + 0 "개 (기대 1개)"
             else { if (t !~ /테스트 자체가 작업 대상/) print "위반: 테스트 배치 규칙에 별도 테스트 Task 조건 문구 없음"
                    if (t !~ /회귀 방지/) print "위반: 테스트 배치 규칙에 공통 회귀 항목 문구 없음" } }' issue-work/templates/issue-plan-template.md
  ```

  - 설계 주의: blockquote 문단이 여러 행에 걸치므로 `>` 빈 행 또는 `>`가 아닌 행 전까지를 한 문단으로 모아 판정한다. 문구 검사는 앵커 실재만 보장하며, 반대 규칙이 같은 낱말을 쓰는 경우는 아래 `[QD]`가 거른다(계획 감사 F-2 보정).
  </details>
- [ ] [D]  Task 1 예시 블록의 `작업 내용` 필드 범위(`- **작업 내용**:`부터 `- **완료 기준**:` 전)에 테스트 작성 단계 안내 주석이 정확히 1행 있고 테스트 파일이 Task 산출물임을 담으며, Task 1의 다른 범위에는 같은 주석이 0행이다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^### Task 1: / { s = 1 } /^### Task 2: / { s = 0 }
       s && /^- \*\*작업 내용\*\*:/ { f = 1 }
       s && /^- \*\*완료 기준\*\*:/ { f = 0 }
       s && /<!--/ && /테스트 작성/ && /산출물/ { if (f) n++; else o++ }
       END { if (n != 1) print "위반: Task 1 작업 내용 테스트 배치 주석 " n + 0 "행 (기대 1행)"
             if (o > 0) print "위반: Task 1 작업 내용 밖에 테스트 배치 주석 " o "행 (기대 0행)" }' issue-work/templates/issue-plan-template.md
  ```

  - 설계 주의: 필드 앵커(`^- \*\*…\*\*:`)로 범위를 자르므로 같은 주석을 `완료 기준` 등 다른 필드로 옮기면 실패한다(계획 감사 F-2 보정).
  </details>
- [ ] [D]  Task 1 예시 블록의 `완료 기준`에 "러너 출력의 케이스 행 + 러너 0 실패" 형태의 테스트 `[D]` 예시 항목이 정확히 1개 있고, 그 접기가 details 1쌍·bash 코드 블록·블록 안 러너 경로 행·블록 안 통과·격추 케이스 grep 행 각 1행 이상·구현 전 통과 설계 주의를 모두 갖춘다. 블록 안 주석 행은 러너·grep 행으로 세지 않는다. 예시가 실제로 동작하는지는 plan Task 2 작업 5의 러너 케이스가 본다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^### Task 1: / { s = 1 } /^### Task 2: / { s = 0; c = 0 }
       s && /^  - \[D\] / && /테스트/ && /0 실패/ { n++; c = 1; next }
       c && /^  - \[/ { c = 0 }
       c && /^    <details>/ { d++ }
       c && /^    <\/details>/ { e++ }
       c && !inb && /^    ```bash/ { b++; inb = 1; next }
       c && inb && /^    ```[[:space:]]*$/ { inb = 0; next }
       c && inb && /^[[:space:]]*#/ { next }
       c && inb && /run-tests\.sh/ { r++ }
       c && inb && /grep/ && / 통과/ { g1++ }
       c && inb && /grep/ && / 격추/ { g2++ }
       c && /설계 주의/ && /구현 전/ { w++ }
       END { if (n != 1) print "위반: Task 1 테스트 [D] 예시 " n + 0 "개 (기대 1개)"
             else { if (d != 1 || e != 1) print "위반: 테스트 [D] 예시 접기 details 여닫음 " d + 0 "/" e + 0 " (기대 1/1)"
                    if (b < 1) print "위반: 테스트 [D] 예시 접기에 bash 코드 블록 없음"
                    if (r < 1) print "위반: 테스트 [D] 예시 코드 블록에 러너 경로 행 없음(주석 제외)"
                    if (g1 < 1 || g2 < 1) print "위반: 테스트 [D] 예시 코드 블록에 통과·격추 grep 행 " g1 + 0 "/" g2 + 0 " (기대 각 1 이상, 주석 제외)"
                    if (w < 1) print "위반: 테스트 [D] 예시 접기에 구현 전 통과 설계 주의 없음" } }' issue-work/templates/issue-plan-template.md
  ```

  - 설계 주의: 예시 항목 본문 행 다음부터 다음 완료 기준 항목(`  - [`) 또는 Task 2 헤더 전까지를 그 항목의 접기로 보고, 접기 구성 요소를 전수 열거해 하나라도 빠지면 실패한다. 러너 호출·grep 행은 bash 코드 블록 안에서만 세어 설계 주의 산문의 낱말이 대신 통과시키지 못하게 한다. 러너 경로 행은 이 repo 관례의 `tests/run-tests.sh`를 앵커로 쓴다(계획 감사 F-1·F-2 보정). 블록 안 주석 행(`#`로 시작)은 건너뛰어 명령을 주석으로만 남긴 예시가 통과하지 못하게 하고, grep 행은 `통과`·`격추` 낱말별로 세어 라벨 총개수만 세는 예시를 거른다(계획 감사 F-3·F-4 보정). 이 검사는 모양만 보장하며, 예시 명령이 fixture 러너에서 기대대로 판정하는지는 plan Task 2 작업 5의 러너 케이스가 맡는다.
  </details>
- [ ] [QD] 테스트 배치 규칙 문단이 구현 테스트를 그 Task의 `작업 내용`·`완료 기준`에 두고, 별도 테스트 Task를 테스트 자체가 작업 대상일 때로 제한하며, 전체 테스트 통과를 spec `### 공통` 회귀 방지 항목으로 유지한다고 읽힌다  (검증: 감사 모델이 R2 문장과 문단을 대조 채점)  ← 강등 사유: 규칙 의미는 문구 검사로 환원 불가. 반대 규칙도 같은 낱말을 쓸 수 있다

### R3: issue-audit 관점 5 판단 기준

- [ ] [D]  최종 감사 2단계 `#### 검증 관점`의 5번 "누락된 검증" 행이 Task별 테스트 `[D]` 존재와 변경 커버 여부를 기준으로 담고, 관점 행은 5개 그대로다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^#### 검증 관점$/ { s = 1; next } /^####/ { s = 0 }
       s && /^[0-9]+\. \*\*/ { c++ }
       s && /^5\. \*\*누락된 검증\*\*/ { n++; if ($0 !~ /\[D\]/ || $0 !~ /Task/) print "위반: 관점 5 행에 Task별 테스트 [D] 기준 없음" }
       END { if (n != 1) print "위반: 관점 5 행 " n + 0 "개 (기대 1개)"; if (c != 5) print "위반: 검증 관점 행 " c + 0 "개 (기대 5개)" }' issue-audit/SKILL.md
  ```

  - 설계 주의: `#### 검증 관점` 헤더는 SKILL.md에 1개뿐이다. `--plan` 절의 관점 목록은 굵은 글씨 문단이라 범위에 들지 않는다.
  </details>
- [ ] [D]  카테고리 표의 테스트 행이 git-review 원본과 같다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -qE '^\| 테스트 \|' issue-audit/SKILL.md \
    && diff <(grep -E '^\| 테스트 \|' issue-audit/SKILL.md) <(grep -E '^\| 테스트 \|' git-review/SKILL.md) >/dev/null \
    || echo '위반: 테스트 카테고리 행이 없거나 git-review 원본과 다름'
  ```

  - 설계 주의: 두 파일 모두 행이 없으면 빈 입력끼리 같아 통과하므로, 행 실재를 먼저 확인한다.
  </details>
- [ ] [QD] 관점 5의 판단 기준 문장이 감사인 재량 없이 적용된다. Task별 테스트 `[D]`의 유무와 커버 여부를 plan과 테스트 파일에서 읽어 판정할 수 있다  (검증: 감사 모델이 그 문장으로 이 이슈 plan을 시범 판정)  ← 강등 사유: 기준 문장의 적용 가능성은 의미 판단이라 명령으로 환원 불가

### R4: 1단계 DoD 대조의 `[D]` 실행 지시

- [ ] [D]  최종 감사 1단계 검증 항목 2 "완료의 정의(DoD) 대조" 행이 `[D]` 항목의 검증 명령을 실제로 실행해 결과를 판정 근거로 삼도록 지시한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  awk '/^### 1단계: 적합성 검증/ { s = 1 } /^### 2단계/ { s = 0 }
       s && /^2\. \*\*완료의 정의\(DoD\) 대조\*\*/ { n++; if ($0 !~ /\[D\]/ || $0 !~ /실제로 실행/) print "위반: DoD 대조 행에 [D] 실제 실행 지시 없음" }
       END { if (n != 1) print "위반: DoD 대조 행 " n + 0 "개 (기대 1개)" }' issue-audit/SKILL.md
  ```

  </details>
- [ ] [QD] 실행 지시가 `--plan` 관점 2(구현 전 실행으로 가짜 `[D]` 판별)와 역할이 겹치지 않고, 최종 감사에서는 통과 확인으로만 읽힌다  (검증: 감사 모델이 두 절 대조 채점)  ← 강등 사유: 역할 구분은 의미 대조라 명령으로 환원 불가

### R5: 안내도·ADR 정합

- [ ] [D]  `specs/issue-workflow.md`의 spec 구성 행이 인수 테스트를, plan 구성 행이 테스트 배치를 언급한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  f=.ai/40_domain/specs/issue-workflow.md
  grep -E '^- spec 구성: ' "$f" | grep -q '인수 테스트' || echo '위반: spec 구성 행에 인수 테스트 없음'
  grep -E '^- plan 구성: ' "$f" | grep -q '테스트' || echo '위반: plan 구성 행에 테스트 배치 없음'
  ```

  </details>
- [ ] [D]  `specs/issue-audit.md`의 1단계 행이 `[D]` 실행을, 2단계 행이 Task별 테스트 기준을 언급한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  f=.ai/40_domain/specs/issue-audit.md
  grep -E '^- 1단계 적합성 검증: ' "$f" | grep -q '\[D\]' || echo '위반: 1단계 행에 [D] 실행 없음'
  grep -E '^- 2단계 비판적 검증: ' "$f" | grep -q 'Task' || echo '위반: 2단계 행에 Task별 테스트 기준 없음'
  ```

  </details>
- [ ] [D]  `60_codebase/issue-audit/final-audit-call-flow.md`가 관점 5의 Task별 테스트 기준을 언급한다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  grep -q 'Task별 테스트' .ai/60_codebase/issue-audit/final-audit-call-flow.md || echo '위반: 호출 흐름 색인에 Task별 테스트 기준 없음'
  ```

  </details>
- [ ] [D]  `final-audit-call-flow.md`의 `source_hash`가 `issue-audit/SKILL.md`의 최종 변경 커밋과 같거나 그 뒤를 가리킨다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  h=$(sed -n 's/^source_hash: //p' .ai/60_codebase/issue-audit/final-audit-call-flow.md)
  last=$(git log -1 --format=%H -- issue-audit/SKILL.md)
  [ -n "$h" ] && [ -n "$last" ] && git merge-base --is-ancestor "$last" "$h" \
    || echo "위반: source_hash($h)가 SKILL.md 최종 변경 커밋보다 앞서거나 비어 있음"
  ```

  - 설계 주의: 구현 전에는 색인이 최신이라 통과하고, Task 3 커밋 뒤 Task 4가 해시를 갱신하기 전까지 실패한다. 색인이 소스보다 뒤처지지 않음을 보장하는 회귀 방지 항목이다.
  </details>
- [ ] [D]  새 ADR 0019 파일과 `50_adr/index.md` 행이 있다
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  { [ -n "$(find .ai/50_adr/active -name '0019-*.md' -print -quit)" ] && grep -qE '^\| `active/0019-' .ai/50_adr/index.md; } \
    || echo '위반: ADR 0019 파일 또는 index 행 없음'
  ```

  </details>
- [ ] [QD] 안내도·ADR 서술이 변경된 SKILL.md·템플릿 원문과 어긋나지 않는다  (검증: 감사 모델이 원문 대조 채점)  ← 강등 사유: 의미 대조라 명령으로 환원 불가

### 공통

- [ ] [D]  repo 전체 스킬 테스트가 통과한다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  for t in */tests/run-tests.sh; do "$t" >/dev/null 2>&1 || echo "위반: $t 실패"; done
  ```

  </details>
- [ ] [D]  이 이슈에서 바꾼 파일에 줄 끝 공백이 없다 (회귀 방지 항목)
  <details>
  <summary>검증 명령 — 출력 0건이면 통과</summary>

  ```bash
  git diff --name-only main...HEAD | while read -r f; do [ -f "$f" ] && grep -nE ' +$' "$f" | grep -vE '  $'; done
  ```

  - 설계 주의: 두 칸 공백은 마크다운 강제 개행이라 제외한다. 삭제된 파일은 건너뛴다.
  </details>

---

## 전제 (Assumptions)

- 새 ADR: ADR 0003은 검증 레벨·접기 형식·결정화 판단을 정하고 테스트의 관점 구분과 배치는 정하지 않는다. 0003 보강 대신 새 ADR `0019-test-perspectives-and-task-level-placement.md`를 쓴다(번호는 active 최대 0018 + 1). 2026-10-13 계획 시점에 확정.
- 구현 테스트의 위치: 러너(`run-tests.sh`) 케이스 편입은 spec DoD가 아니라 plan Task 완료 기준에 둔다. 이 이슈 plan이 R2 규칙을 선적용한 것이며, spec DoD는 조항·예시의 존재(인수)만 본다.
- 테스트 `[D]`의 형태: Task 완료 기준의 테스트 `[D]`는 러너를 1회 실행해 종료 코드 0과 출력의 케이스 행(`ok     - <케이스 설명>`)이 정상 통과·반례 격추 한 쌍 이상 있음을 함께 본다. 케이스 설명은 `<라벨>… 통과` 또는 `<라벨>… 격추`로 끝맺고 한 설명에 두 낱말을 같이 쓰지 않으며, 명령은 라벨 행을 `통과`·`격추` 낱말별로 따로 센다. 라벨 행 총개수만 세면 통과 케이스 2개로 쌍 요구를 우회한다(계획 감사 F-3 보정). 러너 파일 전체를 grep하는 형태는 주석 안의 라벨도 통과시키므로 쓰지 않는다(계획 감사 F-1 보정). 러너만 돌리면 케이스를 넣기 전에도 통과해 `--plan` 관점 2에 가짜 `[D]`로 걸린다. 템플릿 예시도 같은 형태로 두며, 구체 예는 이 repo 관례(`<skill>/tests/run-tests.sh`, ADR 0001)의 러너 경로와 `ok` 행 형식을 쓴다. 예시의 러너 경로는 코드 블록 첫 행의 `R=` 할당으로 분리한다. issue-work 러너가 그 행을 떼고 fixture 러너 경로를 주입해 예시 명령을 실제로 실행하기 위한 계약이며, 기존 Task N 게이트의 `P=`/`S=` 행과 같은 방식이다(계획 감사 F-4 보정).
- 러너 케이스 방식: 조항 문장이 곧 계약인 변경은 issue-audit 관점 2 조항 검사(`assert_fake_d_clause`)처럼 실제 파일 통과와 삭제 반례 격추 한 쌍으로 편입한다. 케이스 라벨은 `ok` 출력 행의 케이스 설명에 넣고, 설명 끝은 그 러너의 기존 관례(`관점 2 조항: 실제 SKILL.md 통과` / `관점 2 조항: … 격추`)대로 `통과`·`격추`로 맺는다.
- 카테고리 표: issue-audit 카테고리 표의 테스트 행은 git-review 원본과 같게 유지하고, 판단 기준은 관점 5 행에만 더한다. 리포트 템플릿 테스트 행 주석은 선택이라 DoD에 두지 않는다.
- 템플릿 머리말 형식: plan 템플릿 `## Tasks` 머리말의 새 blockquote는 이웃 행과 같은 `> **라벨** — 본문` 형식을 따른다. 템플릿 구조 일관성이 우선이다. 문단에는 `테스트 자체가 작업 대상`과 `회귀 방지` 문구를 그대로 써서 R2 첫 `[D]`의 앵커로 삼는다(계획 감사 F-2 보정).
- Task 1 예시: 테스트 `[D]` 예시는 기존 줄 끝 공백 `[D]` 예시를 대체하지 않고 추가한다. 두 예시가 각각 명령형과 러너형을 보인다.
- 예시 라벨 표기: 테스트 `[D]` 예시의 grep 정규식은 케이스 라벨을 `<라벨>` 자리표시자로 둔다. `R=` 행의 `<skill>`, 기존 `P=`/`S=` 행의 `<번호>`와 같은 꺾쇠 표기다. Task 2 작업 5의 fixture 러너는 `<라벨>` 문자열을 그대로 담은 `ok` 행을 낸다. 2026-10-14 Task 0에서 사용자 확정.
- 색인 해시: `final-audit-call-flow.md`의 `source_hash`·`last_synced`는 code-map 전체 재실행 없이 Task 1~3의 최종 소스 커밋으로 손으로 갱신한다(#110 선례). `60_codebase/index.md`는 내용 변경이 없으면 그대로 둔다.
- 커밋 단위: Task 1~4는 완료할 때마다 git-commit 규칙으로 1커밋씩 남긴다(그 Task의 테스트 변경 포함, push 없음). Task 4의 `source_hash`는 Task 3 커밋을 가리킨다. 2026-10-14 Task 0에서 사용자 확정.
- 검증 환경: 검증 명령은 repo 루트에서 zsh·bash 공용으로 실행한다. 글롭 실패 차이를 피하려고 파일 존재 확인은 `find`로 쓴다.

---

## 연관 문서

<!-- 이 이슈 작업 시 참고할 .ai 내 문서를 나열하세요. (스펙, 정책, ADR, 용어사전 등) -->

| 문서 | 역할 |
|------|------|
| `.ai/50_adr/active/0003-verification-levels-and-determinization.md` | 검증 레벨·완료 기준 접기 형식 결정. R1·R2의 결정 변경 범위 대조 기준(R5) |
| `.ai/50_adr/active/0001-skill-deterministic-helper-test-convention.md` | 이 repo 헬퍼 테스트 배치 관례. R1에서 repo 고유 규칙과 스킬 규칙을 가르는 근거 |
| `.ai/50_adr/active/0014-inverted-pyramid-and-verdict-derivation.md` | 카테고리 7종 원본이 git-review라는 결정. R3이 카테고리 표 문구를 유지하는 근거 |
| `.ai/50_adr/active/0016-spec-requirements-layer-and-plan-audit.md` | DoD R 그룹·`--plan` 가짜 `[D]` 판별 결정. R1·R4와의 정합 확인 |
| `.ai/40_domain/specs/issue-workflow.md` | issue-work 절차 안내도. R5 갱신 대상 |
| `.ai/40_domain/specs/issue-audit.md` | issue-audit 단계 요건 안내도. R5 갱신 대상 |
| `.ai/60_codebase/issue-audit/final-audit-call-flow.md` | 최종 감사 호출 흐름 색인. R5 갱신 대상 |
| `.ai/10_rules/architecture.md` | 디자인 원칙과 검증 레벨의 관계. R1 서술이 "두 체계는 적용 대상이 다르다"와 충돌하지 않는지 확인 |
