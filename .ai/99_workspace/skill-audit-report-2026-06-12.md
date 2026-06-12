# 스킬 감사 보고서

> 감사일: 2026-06-12 · 대상: scroogy-agent-skills 저장소의 스킬 14개 · 파일 수정 없음 (보고서만 산출)

## 감사 기준

1. SKILL.md frontmatter 유효성 (name, description 형식)
2. description 품질 — 트리거 상황의 구체성, 트리거 키워드 충분성
3. 본문 구조 — progressive disclosure 준수 (SKILL.md 간결 + 상세는 참조 파일 분리, 이상 기준 500줄 미만)
4. 토큰 효율 — 불필요하게 긴 부분
5. 스킬 간 중복/충돌 — 트리거 겹침 여부

---

## 종합 판정 표

| 스킬 | 줄수 | ① frontmatter | ② description | ③ 구조 | ④ 토큰 효율 | ⑤ 중복/충돌 | 우선순위 |
|------|-----:|:---:|:---:|:---:|:---:|:---:|:---:|
| ai-workspace-directory | 827 | ✅ | ⚠️ | ❌ | ❌ | ⚠️ | **상** |
| ai-workspace | 275 | ✅ | ❌ | ⚠️ | ⚠️ | ⚠️ | **상** |
| code-map | 566 | ✅ | ✅ | ❌ | ⚠️ | ✅ | **중상** |
| git-review-context | 125 | ✅ | ⚠️ | ✅ | ✅ | ⚠️ | **중** |
| git-review | 108 | ✅ | ⚠️ | ✅ | ⚠️ | ⚠️ | **중** |
| context-harvest | 313 | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | **중** |
| install-skills | 73 | ✅ | ✅ | ✅ | ⚠️ | ✅ | **중하** |
| readme-sync | 268 | ✅ | ⚠️ | ⚠️ | ⚠️ | ✅ | **중하** |
| context-save | 215 | ✅ | ✅ | ✅ | ⚠️ | ✅ | **하** |
| git-pr | 149 | ✅ | ✅ | ✅ | ⚠️ | ✅ | **하** |
| issue-work | 93 | ✅ | ⚠️ | ✅ | ✅ | ✅ | **하** |
| issue-audit | 143 | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| git-qa | 168 | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| git-commit | 60 | ✅ | ✅ | ✅ | ✅ | ✅ | — |

✅ 양호 · ⚠️ 개선 권장 · ❌ 위반

---

## 기준별 상세 발견 사항

### ① Frontmatter 유효성 — 전원 통과

14개 모두 `name`/`description` 존재, `name`이 디렉토리명과 일치하며 kebab-case 형식 유효. YAML 파싱 오류 없음. description 길이도 65~187자로 모두 안전 범위.

### ② Description 품질

| 스킬 | 발견 사항 | 심각도 |
|------|-----------|:---:|
| ai-workspace | **트리거 키워드가 전혀 없음** (`"...초기화하거나 갱신합니다. dev 또는 doc 프로파일..."`). 자매 스킬 ai-workspace-directory는 키워드 5종(로비, lobby, AI-CONTEXT.md, building 인덱스, 안내판)을 보유해 라우팅 경쟁에서 일방적으로 유리. 특히 **`AI-CONTEXT.md` 키워드가 directory 쪽에만 있어**, 단일 repo에서 "AI-CONTEXT.md 갱신해줘"라고 하면 floor 담당인 ai-workspace 대신 로비 담당 스킬이 트리거될 수 있음 | **상** |
| git-review-context | 본문에는 "사용자가 명시적으로 요청한 경우에만 실행"이라는 핵심 트리거 제약이 있으나 **description에는 없음**. 트리거 판단은 description만으로 이루어지므로 제약이 작동하지 않음 | 중 |
| git-review | "코드 리뷰, PR 리뷰" 키워드가 git-review-context의 "리뷰 준비"와 회색지대 형성 (아래 ⑤ 참고) | 중 |
| readme-sync | `"X, Y 시 사용합니다"` 트리거 패턴 미적용. README.md 키워드가 자연 포함되어 실해는 작으나 다른 12개 스킬과의 일관성 결여 | 하 |
| issue-work | description에 CLI 플래그(`--workflow-only`, `--resume`)가 들어 있음. "이어하기, resume" 자연어 키워드는 유용하나 괄호 플래그 표기는 트리거에 기여하지 않는 노이즈 | 하 |

### ③ 본문 구조 (Progressive Disclosure)

| 스킬 | 발견 사항 | 심각도 |
|------|-----------|:---:|
| ai-workspace-directory | **827줄 — 이상 기준(500줄)의 1.65배.** `references/` 디렉토리 없음. 분리 후보: ① 예시 2건(init/update, 542~827행, 약 285줄 — 완성 산출물 전문 포함), ② SSoT 위배 체크리스트(492~541행), ③ 표준 섹션 구조 상세(408~491행). 본문에는 실행 절차와 분리 파일 포인터만 남기면 200줄 내외로 압축 가능 | **상** |
| code-map | **566줄.** `--local`/`--global` 두 모드가 한 파일에 공존 — skill-creator의 domain organization 패턴(모드별 `references/local.md`, `references/global.md` 분리) 적용 대상. 진입 시 한쪽 모드만 필요하므로 분리 효과 큼 | **중상** |
| context-harvest | `templates/` 디렉토리에 템플릿 3종이 실재하는데 SKILL.md 본문(207~278행)에 동일 템플릿이 전문 인라인 중복 | 중 |
| ai-workspace | "구버전 구조 마이그레이션" 소섹션(215~254행)이 주석으로 "일회성 로직, 전환 완료 후 제거 가능"이라 자가 선언함 — 참조 파일로 빼거나 제거 시점 도래 여부 점검 필요 | 중 |
| readme-sync | 라이선스 처리 세부 사양(`--force-license` 가드, 헤더 파일명 가드 등 158~237행, 약 80줄)은 Q1=(a) 분기에서만 필요 — `references/license.md` 분리 후보 | 하 |
| context-save | 템플릿이 `templates/context-note-template.md`로 분리되어 있는데 본문(149~185행)에 또 인라인됨 | 하 |

### ④ 토큰 효율

| 항목 | 내용 |
|------|------|
| ai-workspace-directory | 표준 섹션 규칙이 본문에서 **3회 반복** (init-4단계 필수 규칙 ≒ "표준 섹션 구조 > 필수 규칙" ≒ SSoT 체크리스트 형식·메타 위배 항목). 예시 2건이 산출물 전문을 포함해 전체의 약 35% 차지 |
| 템플릿 인라인 중복 | context-harvest(3종), context-save(1종) — templates/ 파일과 본문 양쪽에 동일 내용 |
| git-review | "PR 리뷰 모드", "Self 리뷰 모드", "4단계: 기타 테크 검증" 섹션이 **빈 placeholder 주석만 보유**. 의도된 커스터마이징 포인트라면 주석 한 줄로 충분하고, 아니라면 채우거나 제거 필요 |
| install-skills | 스킬 목록 13개 하드코딩. 현재는 정확하나 스킬 추가/이름 변경 시마다 수동 갱신 필요한 drift 위험. "저장소 내 SKILL.md 보유 디렉토리를 스캔(install-skills 제외)" 한 줄로 대체 가능 |
| git-pr | 호출 흐름 작성 지침(98행)이 한 문단에 과밀 — 분리하면 가독성 개선. 실질 토큰 낭비는 적음 |

### ⑤ 스킬 간 중복/충돌

**(a) 트리거 충돌 — git-review ↔ git-review-context** (요청하신 중점 점검 대상)

| 스킬 | description 키워드 |
|------|--------------------|
| git-review | 코드 리뷰, PR 리뷰, self review |
| git-review-context | 리뷰 컨텍스트, review context, 리뷰 준비 |
| git-qa | QA 체크리스트, qa checklist, 배포 QA, deploy QA |

- **git-qa는 충돌 없음** — "QA/체크리스트" 도메인으로 명확히 분리됨.
- **git-review vs git-review-context는 회색지대 존재**: "PR 리뷰 준비해줘", "리뷰 전에 변경사항 정리해줘" 류 요청이 양쪽 모두에 매칭됨. 본문 차원의 방어("git-review가 자동 호출하지 않음", "명시적 요청 시에만 실행")는 잘 되어 있으나, 트리거 판단에 쓰이는 description에는 이 구분이 없음. git-review-context description에 "git-review 실행 전 사전 분석 단계이며 사용자가 명시적으로 요청한 경우에만" 취지를 명시하면 해소.
- issue-audit ↔ git-review: 본문에 차이 명시("PR 단위 코드 품질 리뷰 vs 이슈 단위 스펙 충족 감사")가 있고 키워드도 분리되어 충돌 낮음. 양호 사례.

**(b) 트리거 충돌 — ai-workspace ↔ ai-workspace-directory**

두 스킬 모두 `.ai/AI-CONTEXT.md`를 산출하는데(층/로비), `AI-CONTEXT.md` 키워드는 directory 쪽 description에만 존재. ai-workspace에 키워드가 없어서 floor 작업 요청이 로비 스킬로 오라우팅될 위험. ②에서 상세 기술.

**(c) 본문 콘텐츠 중복 (설계상 트레이드오프)**

| 중복 콘텐츠 | 등장 스킬 | 비고 |
|-------------|-----------|------|
| "코드베이스 색인 갱신이 필요해 보입니다 (`/code-map`)" 문구·절차 | git-pr, git-review, git-review-context, issue-audit (4곳) | 거의 동일 문단 |
| "디렉토리 트리 정렬 규칙" 섹션 | ai-workspace, code-map, readme-sync (3곳) | 축어적 동일 |
| ASCII 호출 흐름 다이어그램 작성 지침 (`ClassName#methodName`, 트리 기호 등) | git-pr, git-review-context (2곳, code-map도 유사 형식) | 거의 동일 |

스킬이 개별 디렉토리 단위로 설치되는 구조(install-skills)라 스킬 간 공유 참조 파일이 불가능하므로 의도된 중복일 수 있음. 다만 규칙 변경 시 3~4곳 동시 수정이 필요한 유지보수 비용은 인지 필요. 공통 규칙을 `.ai/10_rules/`(ai-workspace 템플릿)에 두고 각 스킬은 한 줄 포인터만 갖는 구조가 대안.

---

## 우선순위별 권고 요약 (수정 미적용 — 권고만)

| 순위 | 대상 | 권고 | 예상 효과 |
|:---:|------|------|-----------|
| 1 | ai-workspace | description에 트리거 키워드 추가 (`.ai 디렉토리, AI-CONTEXT.md, 안내도, workspace 초기화` 등) + directory와의 역할 구분 명시 | 수정 1줄로 오라우팅 위험 해소 — 비용 대비 효과 최대 |
| 2 | ai-workspace-directory | 예시·체크리스트·표준 구조 상세를 `references/`로 분리, 3중 반복 규칙 단일화 → 본문 200줄대 목표 | 트리거 시 적재 토큰 약 70% 절감 |
| 3 | code-map | `--local`/`--global`을 `references/` 모드별 파일로 분리 | 트리거 시 적재 토큰 약 50% 절감 |
| 4 | git-review-context | "명시적 요청 시에만, git-review의 사전 단계" 제약을 description으로 승격 | git-review와의 트리거 회색지대 해소 |
| 5 | context-harvest, context-save | 본문 인라인 템플릿 제거, templates/ 포인터만 유지 | 중복 제거 |
| 6 | git-review | 빈 placeholder 섹션 3곳 채우기 또는 제거 | 미완성 인상 제거 |
| 7 | install-skills | 스킬 목록 하드코딩 → 디렉토리 스캔 방식 | 목록 drift 위험 제거 |
| 8 | 공통 | "트리 정렬 규칙"·"색인 갱신 문구" 등 교차 중복의 단일 출처화 검토 | 유지보수 비용 절감 (설계 판단 필요) |

### 잘 되어 있는 점

- frontmatter 14/14 유효, name 규칙 일관.
- git-commit, git-qa, issue-audit, issue-work는 간결한 본문 + 명확한 트리거의 모범 사례.
- issue-audit의 "git-review와의 차이" 명시, code-map ↔ context-harvest의 쌍 관계 문서화 등 스킬 간 경계 서술이 대체로 충실.
- 템플릿의 `templates/` 분리, "index 먼저 → 관련 파일만 선택적으로" 로딩 규칙 등 progressive disclosure 의식이 저장소 전반에 깔려 있음 — 위 2~3건의 대형 파일만 정리하면 전체 품질이 고르게 올라감.
