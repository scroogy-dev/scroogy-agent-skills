# Issue #134 실행계획 ai-workspace: update가 스킬 소유 구간을 최신본으로 반영하고 안내도에 프로파일을 표시한다

> 스펙: [issue-0134-spec.md](./issue-0134-spec.md)

---

## 계획 종료 게이트 (고정)

> **점검 질문**: 이 spec/plan만 보고, 작성에 참여하지 않은 쪽이 구현에 필요한 내용을 스스로 알 수 있는가?

- [x] 점검 완료
- **점검 대상** (작성 중 머릿속에만 있었던 것):
  - 코드베이스 관례: 헬퍼 형식, bash 3.2·BSD awk 제약, 러너 라벨 규칙을 spec 전제에 적었다.
  - 버전·환경 제약: macOS 기본 bash·awk 제약을 spec 전제에 적었다.
  - 검토 후 버린 대안: spec 전제의 "검토 후 버린 대안"에 적었다.
  - 사용자와의 합의로만 정해진 값: spec 전제의 "사용자 합의"에 적었다.
- **발견 시 조치**: 헬퍼 경계와 구간 규칙은 대화에서만 정해져 spec 전제에 옮겼다.

---

## Tasks

### Task 0 (고정): 구현 시작 게이트 (전제·모호점 확인)

- [x] 완료
- **목표**: 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 코드 작성 전에 걷어낸다.
- **작업 내용**:
  1. spec/plan을 읽고, 구현에 필요하지만 문서만으로는 알 수 없는 전제·모호점을 나열한다.
  2. 항목이 있으면 **코드를 쓰기 전에 사용자에게 질의**하고, 답변을 spec `## 전제 (Assumptions)` 섹션에 반영한 뒤 구현을 시작한다.
  3. 항목이 없으면 summary Task 0의 `수행 내용 요약`에 `전제 누락 없음` 한 줄을 기록하고 진행한다.
- **완료 기준**:
  - [ND] 나열한 항목이 전부 spec `## 전제 (Assumptions)`에 반영되어 미해소 0건이거나, summary Task 0에 `전제 누락 없음`이 기록된다  (검증: 사람 리뷰)  ← 강등 사유: 전제·모호점을 빠짐없이 나열했는지는 의미 판단이라 명령으로 환원 불가

---

### Task 1: 소유 구간 동기화 헬퍼와 테스트

- [x] 완료
- **목표**: 스킬 소유 파일과 구간을 결정적으로 맞추는 `sync-owned.sh`의 `--dirs`·`--context` 모드를 만든다.
- **대상 요구사항**: R1, R2, R3, R4, R5, R6, R8, R9
- **작업 내용**:
  1. `ai-workspace/scripts/sync-owned.sh`를 만들고 실행 권한을 준다. 모드·출력·종료 코드·구간 규칙은 spec 전제의 "헬퍼 경계"와 "구간 규칙"을 따른다. `--profile` 모드 자리는 Task 2에서 채운다.
  2. 대상 하나를 처리하는 공통 함수를 둔다. 임시 파일에 결과를 만든 뒤 설치본과 다를 때만 덮어쓰고, 실패하면 설치본을 건드리지 않는다.
  3. `ai-workspace/tests/run-tests.sh`에 `# --- 소유 구간 동기화 ---` 절을 추가한다. 테스트 입력은 러너 안에서 임시 디렉토리에 만든다.
     - `소유 구간 정상`: 원장 템플릿 교체, 머리말·`## 수명 주기` 교체, 표준 섹션 교체, 재실행 무출력
     - `소유 구간 섹션 없음`: 없는 섹션의 파일 끝 추가, 없는 골격 파일 복사
     - `소유 구간 사용자 섹션 보존`: 파일 목록, 항목 목록, `## Active ADR`, 있는 `glossary.md` 유지
     - `소유 구간 실패 경로`: 같은 제목 둘, `##` 제목 없음, 템플릿에 구간 없음, 없는 `AI-CONTEXT.md`, 닫히지 않은 코드 펜스·HTML 주석, 표준 문구가 아닌 SSoT 선언, 실패 뒤 다른 대상 계속 처리
     - `소유 구간 SSoT 선언별 템플릿 선택`: 소스 코드, 원본 문서, doc 프로파일과 소스 코드 조합
     - `소유 구간 소제목 유지`: 템플릿에 없는 `###` 유지, 템플릿에 있는 `###` 중복 없음
     - `소유 구간 쓰기 도중 실패`: 부분 쓰기 뒤 원본 바이트·권한·심볼릭 링크 유지, 새 파일 잔여물 없음, 복구 실패 시 백업 경로 보고, 다른 대상 계속 처리 (최종 감사 F-1 보정)
     - `소유 구간 임시 결과 조립 실패`: 구간 잇기, 교체 구간, 끝 정리, 이동, 소제목, `--profile` 조립의 실패에서 원본 바이트 유지와 변경 행 없음, 실패 표시가 다음 대상으로 이어지지 않음 (`--response` 2차 검토에서 승인)
     - 코드 펜스와 HTML 주석 안의 `## `를 제목으로 보지 않는 케이스도 `소유 구간 정상`에 넣는다.
  4. 헬퍼의 보호 코드를 지운 사본으로 격추 케이스를 3개 이상 둔다: 같은 제목 검사 제거, `###` 유지 제거, 템플릿 선택을 dev로 고정.
  5. 러너 머리의 실행 권한 확인에 `sync-owned.sh`를 더한다.
- **완료 기준**:
  - [D] 헬퍼가 실행 권한을 갖고 bash 문법 검사를 통과한다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    H=ai-workspace/scripts/sync-owned.sh
    [ -x "$H" ] || echo '위반: 실행 권한 없음'
    bash -n "$H" 2>&1
    ```

    </details>
  - [D] 이 Task의 테스트가 새 케이스를 포함해 0 실패로 통과한다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    R=ai-workspace/tests/run-tests.sh
    out=$("$R" 2>&1) \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 소유 구간.* 통과')" -ge 6 ] \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 소유 구간.* 격추')" -ge 3 ] \
      || echo '위반: 테스트 실패 또는 소유 구간 케이스(통과 6·격추 3 이상) 미실행'
    ```

    - 설계 주의: 러너만 실행하면 케이스를 넣기 전에도 통과하므로 `ok` 행을 낱말별로 센다.
    </details>

---

### Task 2: profile 행과 프로파일 결정 헬퍼

- [x] 완료
- **목표**: 안내도에 프로파일을 표시하고, update가 그 값을 내용 추정 없이 읽고 쓰게 한다.
- **대상 요구사항**: R11, R12
- **작업 내용**:
  1. dev·doc `AI-CONTEXT.md` 템플릿의 `## 프로젝트 도메인` 표에서 `keywords` 다음에 `| profile | dev |`·`| profile | doc |` 행을 넣고, 표 위 안내 주석에 `profile` 설명을 한 줄 더한다.
  2. `check-context.sh`의 필수 행에 `profile`을 더하고 값이 `dev`·`doc`이 아니면 `'## 프로젝트 도메인' 표의 \`profile\` 값 — 실제 [<값>]`을 보고한다. 행이 둘 이상이면 `'## 프로젝트 도메인' 표의 \`profile\` 행 — <N>개`를 보고한다. `profile`은 다른 필수 행과 달리 첫 표 안에서만 찾는다. SSoT 선언과 대조하지 않는다.
  3. `check-context.sh --profile <AI-CONTEXT.md> [dev|doc]` 모드를 더한다. 판정은 아래 표대로이고 파일을 바꾸지 않는다. 위 행부터 차례로 적용한다.

     | 인자 | `profile` 값 | 출력 | 종료 코드 |
     |------|--------------|------|-----------|
     | 그 외 값 | 상관없음 | `질의: <사유>` | 1 |
     | 없음, `dev`·`doc` | 행이 둘 이상 | `질의: <사유>` | 1 |
     | 없음 | 유효 | 값 | 0 |
     | 없음 | 없음·무효, 또는 안내도 없음 | `질의: <사유>` | 1 |
     | `dev`·`doc` | 같음 | 값 | 0 |
     | `dev`·`doc` | 없음·무효, 또는 안내도 없음 | 인자 | 0 |
     | `dev`·`doc` | 다름 | `질의: <사유>` | 1 |

  4. `sync-owned.sh --profile <dev|doc> <.ai 디렉토리>` 모드를 더한다. 행이 둘 이상이면 첫 행을 그 값으로 바꾸고 나머지를 지운다.
  5. `SKILL.md` update-4 표에 `profile` 행을 더해 표 행 수와 헬퍼 판정 수를 13개 중 11개로 고치고, `check-context.sh` 머리 주석의 같은 수를 맞춘다. `## 프로젝트 도메인` 행의 골격 설명에도 `profile` 행을 더한다. 머리 주석 줄 수가 바뀌면 `usage()`의 줄 범위도 맞춘다. `run-tests.sh`의 같은 수(539·550·551행 근처)를 13행·11종으로 고치고, `--profile dev`를 알 수 없는 옵션 예로 쓰는 567행 근처 케이스는 다른 옵션으로 바꾼다.
  6. `## 프로젝트 도메인` 표가 있는 `tests/fixtures/update4-idempotent/` 입력·기대 쌍에 `profile` 행을 넣고, 이 repo `.ai/AI-CONTEXT.md`에 `| profile | dev |`를 넣는다.
  7. 러너에 케이스를 더한다: `프로파일 행 누락 격추`, `프로파일 행 중복 격추`, `프로파일 값 오류 격추`, `프로파일 SSoT 조합 통과`, `프로파일 결정 통과`(표의 7행), `프로파일 쓰기 통과`(추가·교체·행 정리·재실행 무출력), `프로파일 쓰기 실패 경로 통과`(섹션 없음).
- **완료 기준**:
  - [D] 이 Task의 테스트가 새 케이스를 포함해 0 실패로 통과한다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    R=ai-workspace/tests/run-tests.sh
    out=$("$R" 2>&1) \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 프로파일.* 통과')" -ge 4 ] \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 프로파일.* 격추')" -ge 3 ] \
      || echo '위반: 테스트 실패 또는 프로파일 케이스(통과 4·격추 3 이상) 미실행'
    ```

    </details>
  - [D] 이 repo 안내도에 `profile` 행이 있어 저장소 안내도 검사의 입력이 된다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    grep -qxF '| profile | dev |' .ai/AI-CONTEXT.md || echo '위반: 저장소 안내도 profile 행 없음'
    ai-workspace/scripts/check-context.sh .ai/AI-CONTEXT.md
    ```

    </details>

---

### Task 3: 안내 주석, SKILL.md 절차, 이 repo 사본 동기화

- [x] 완료
- **목표**: 템플릿에 안내 주석을 넣고 update 절차가 헬퍼를 호출하게 고친 뒤, 이 repo의 사본을 맞춘다.
- **대상 요구사항**: R1, R2, R3, R4, R6, R7, R8, R12
- **작업 내용**:
  1. 안내 주석을 넣는다. 문구는 spec R7의 검증 명령과 글자까지 같게 쓴다.
     - `ledger-entry-template.md`: 첫 주석 블록 안에 한 줄
     - `50_adr/index.md`, `70_ledger/index.md` 템플릿: `## 수명 주기` 제목 바로 아래
     - dev·doc `AI-CONTEXT.md` 템플릿: 표준 섹션 4개의 제목 바로 아래
  2. `ai-workspace/SKILL.md` `### 1단계: 프로파일 확인`을 고친다. `check='<skill 디렉토리>/scripts/check-context.sh'`와 `"$check" --profile '.ai/AI-CONTEXT.md' '<인자, 없으면 생략>'` 호출, 종료 코드별 처리를 적는다. "내용을 보고 추정하지 않습니다", "안내도 값을 자동으로 바꾸지 않습니다", 사용자가 바꾸기로 답하면 그 값이 update-4에서 반영된다는 문장을 넣는다. `profile` 행이 둘 이상일 때 사용자가 고른 값으로 update-4가 행을 하나로 정리한다는 문장도 넣는다. 사용법의 "프로파일을 생략하면 사용자에게 선택을 요청합니다"(39행)도 이 규칙에 맞춘다.
  3. update-3의 골격 복사 문단(현재 "대상 디렉토리 자체가 없으면…" 문단)을 `sync=…`와 `"$sync" --dirs '<skill 디렉토리>/templates' '.ai'` 호출로 바꾸고, 대상별 처리를 적는다. 하위 디렉토리 생성 뒤, 기존 파일 정리 앞에서 호출한다.
  4. update-4에 `#### 표준 구간 최신화` 소절을 `#### 구버전 구조 마이그레이션` 다음에 둔다. `"$sync" --profile '<1단계에서 정한 프로파일>' '.ai'`와 `"$sync" --context '<skill 디렉토리>/templates' '.ai'`를 차례로 호출한다. SSoT 선언 행과 건물 repo 행의 "4곳을 바꾼다" 조치는 이 소절이 맡는다고 고친다. `## 에이전트 운영 지침` 행의 삽입 규칙은 유지하고, 사용자 추가분 보존 문장은 템플릿에 없는 `###` 소제목 유지로 맞춘다. SSoT 선언 행과 건물 repo 행의 "사용자 작성분은 보존한다" 조항(259·260행)을 뺀다. `실패:`·종료 코드 처리는 spec 전제의 "헬퍼 경계"를 따른다.
  5. update-5 목록에 `- 최신본으로 바꾼 파일·구간과 실패 항목 (\`sync-owned.sh\` 출력의 \`교체:\`·\`추가:\`·\`실패:\` 행)`을 더한다. 설계 설명의 init 복사 정책 목록에 원장 템플릿 정책을 맞춘다.
  6. `ai-workspace/tests/run-tests.sh`에 `소유 구간 절차` 조항 검사를 더한다. 1단계·update-3·update-4·update-5의 앵커가 제자리에 있으면 통과, 각 앵커를 지운 사본은 격추한다. 598행 근처 주석의 "update가 덮어쓰지 않아 직접 고치므로"를 새 동작에 맞춘다.
  7. 이 repo에 헬퍼를 실행해 `.ai/` 사본을 맞춘다. 실행 전에 임시 사본에 먼저 실행해 `diff -ru`로 바뀔 구간을 확인하고, 출력 행을 summary 특이 사항에 적는다. `.ai/AI-CONTEXT.md`의 `> last updated`도 갱신한다.
     ```bash
     ai-workspace/scripts/sync-owned.sh --dirs ai-workspace/templates .ai
     ai-workspace/scripts/sync-owned.sh --context ai-workspace/templates .ai
     ```
- **완료 기준**:
  - [D] 이 Task의 테스트가 새 케이스를 포함해 0 실패로 통과한다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    R=ai-workspace/tests/run-tests.sh
    out=$("$R" 2>&1) \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 소유 구간 절차.* 통과')" -ge 1 ] \
      && [ "$(printf '%s\n' "$out" | grep -cE '^ok +- 소유 구간 절차.* 격추')" -ge 4 ] \
      || echo '위반: 테스트 실패 또는 소유 구간 절차 케이스(통과 1·격추 4 이상) 미실행'
    ```

    </details>
  - [D] 이 repo의 `.ai/` 사본에 다시 실행해도 바뀔 내용이 없다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    W=$(mktemp -d); cp -R .ai "$W/.ai"
    ai-workspace/scripts/sync-owned.sh --dirs ai-workspace/templates "$W/.ai" || echo '위반: --dirs 종료 코드'
    ai-workspace/scripts/sync-owned.sh --context ai-workspace/templates "$W/.ai" || echo '위반: --context 종료 코드'
    rm -rf "$W"
    ```

    </details>

---

### Task 4: ADR, 명세, 코드맵 갱신

- [x] 완료
- **목표**: 소유 구분과 프로파일 표시 결정을 기록하고, 이 repo 문서를 새 동작에 맞춘다.
- **대상 요구사항**: R10
- **작업 내용**:
  1. `.ai/50_adr/active/0028-ai-workspace-owned-sections-and-profile-row.md`를 쓴다. 형식은 ADR 0023을 따른다. 결정에는 파일 단위 최신본, 구간 단위 교체, 사용자 작성의 3분류와 대상, 헬퍼 분리, `profile` 행과 SSoT 선언의 역할 구분, 1단계 결정 규칙을 적는다. 근거에는 비교 결과와 버린 대안, `## Git 정책` 미검사 리스크(#70)가 해소된 경위를 적는다.
  2. `.ai/50_adr/index.md` 파일 목록에 행을 더하고, 쓰임이 넓어진 ADR 0007·0008의 관련 결정에 ADR 0028 링크를 더한다.
  3. `.ai/40_domain/specs/ai-workspace.md`의 update 서술을 새 동작에 맞춘다(14·17·18행 근처). 18행의 "사용자 작성분 보존" 서술도 섹션 교체에 맞춘다. `.ai/40_domain/index.md` 설명에 필요한 경우 소유 구간과 `profile`을 더한다.
  4. `.ai/AI-CONTEXT.md` `## 디렉토리 구조`의 `ai-workspace/scripts/`·`tests/` 설명에 헬퍼를 더한다.
  5. `.ai/60_codebase/ai-workspace/update-call-flow.md`·`init-call-flow.md`의 트리와 시퀀스, `check-context.sh` 항목 수를 새 절차에 맞춘다. `.ai/60_codebase/index.md`의 트리와 헬퍼 공통 규약 목록에 `sync-owned.sh`를 더하고, 성공해도 출력이 있는 경우(변경 행, `--profile` 값)를 예외로 적는다. `source_hash`·`last_synced` 표지는 고치지 않고 커밋 뒤 코드맵 sync로 갱신한다.
- **완료 기준**:
  - [D] ADR 0028과 index 행이 있고, 명세와 코드맵이 헬퍼를 가리킨다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    A=.ai/50_adr/active/0028-ai-workspace-owned-sections-and-profile-row.md
    [ -f "$A" ] || echo '위반: ADR 없음'
    grep -qF "| \`active/0028-ai-workspace-owned-sections-and-profile-row.md\` |" .ai/50_adr/index.md || echo '위반: index 행 없음'
    grep -qF 'sync-owned.sh' .ai/40_domain/specs/ai-workspace.md || echo '위반: 명세'
    grep -qF 'sync-owned.sh' .ai/AI-CONTEXT.md || echo '위반: 안내도 트리'
    grep -qF 'sync-owned.sh' .ai/60_codebase/ai-workspace/update-call-flow.md || echo '위반: 코드맵'
    ```

    </details>
  - [D] 고친 문서의 원장·상대 링크가 깨지지 않는다
    <details>
    <summary>검증 명령 — 출력 0건이면 통과</summary>

    ```bash
    issue-work/scripts/check-ledger-links.sh .ai || echo '위반: 원장 링크 검사 실패'
    for f in .ai/50_adr/active/0028-ai-workspace-owned-sections-and-profile-row.md \
      .ai/50_adr/index.md .ai/50_adr/active/0007-*.md .ai/50_adr/active/0008-*.md \
      .ai/40_domain/specs/ai-workspace.md .ai/40_domain/index.md .ai/AI-CONTEXT.md \
      .ai/60_codebase/ai-workspace/update-call-flow.md .ai/60_codebase/ai-workspace/init-call-flow.md .ai/60_codebase/index.md; do
      [ -r "$f" ] || { echo "위반: 읽을 수 없음 ${f}"; continue; }
      d=$(dirname "$f")
      grep -oE '\]\([^)#[:space:]]+' "$f" | sed 's/^](//' | grep -vE '^[a-z][a-z0-9+.-]*:' \
        | while read -r p; do [ -e "$d/$p" ] || echo "위반: ${f} 끊긴 링크 ${p}"; done
    done
    ```

    </details>

---

### Task N (고정): 교차모델 issue-audit 검증 (사용자 수동 수행)

- [x] 완료
- **목표**: 스펙 위반·누락·소스코드와의 모순을 구현 모델과 다른 시각으로 잡는다.
- **실행 주체**: **사용자가 직접** 수행한다. 구현 AI는 이 Task를 **자동으로 닫지 않으며**, `issue-audit`를 자동 실행하지도 않는다.
- **작업 내용**:
  1. spec `완료의 정의`의 `[D]` 항목 검증 명령을 전부 재실행해 통과를 확인한다.
  2. 구현을 수행한 모델과 **다른 벤더 모델**(최소 동급 이상 역량)로 사용자가 직접 `issue-audit`를 실행한다. 방향은 칭찬이 아니라 허점 탐색("스펙 위반·누락·소스코드와의 모순을 찾아라").
  3. 사용자가 audit 결과(지적 사항·감사 모델·감사 effort)를 summary에 반영·기록한다. 발견사항 보정은 issue-work `--response`로 검토한다. **피드백 먼저, 항목별 승인 후에만** 앞 Task를 보정하며, 리포트를 받자마자 자동 보정하지 않는다.
- **완료 기준**:
  - [D] spec `완료의 정의`의 `[D]` 항목 검증 명령 전부 통과  (검증: 해당 명령 재실행)
  - [D] summary의 Task 헤더 집합이 plan과 일치한다. 블록 전체 누락·Task N 누락·빈 summary·두 경로 오기를 차단하며, 아래 두 게이트의 선행 조건이라 블록 자체가 없으면 그 두 게이트는 검사 대상이 사라져 그대로 통과한다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0건이면 통과</summary>

    ```bash
    P=.ai/90_issues/archive/issue-0134/issue-0134-plan.md
    S=.ai/90_issues/archive/issue-0134/issue-0134-summary.md
    { grep -qE '^### Task ' "$P" && grep -qE '^### Task ' "$S" \
      && diff <(grep -E '^### Task ' "$P") <(grep -E '^### Task ' "$S") \
      || echo '위반: 입력 접근 실패 또는 Task 집합 불일치'; }
    ```

    - 설계 주의: 프로세스 치환 안의 `grep` 실패는 `diff` 종료 상태로 전파되지 않아 두 경로가 모두 잘못되면 빈 입력끼리 비교해 통과한다. 선행 `grep -q`로 두 파일의 Task 헤더 실재를 먼저 확인하고 실패를 stdout 위반 행으로 환원한다.
    - 의존 근거: 아래 두 게이트는 `^### Task ` 블록 안의 행만 훑는 awk라 블록 유무 자체를 판정할 수 없다. 그 판정은 이 게이트에만 있다.
    </details>
  - [D] 이 검증 전에 Task 0 및 모든 일반 실행 Task의 summary `결과`가 완료·부분 완료·스킵 중 하나로 확정된다. Task N 제외 블록마다 유효 `결과` 행 정확히 1개, 무효·중복 0건이며, 아래 `수행 모델` 게이트의 선행 조건이라 비워 두면 그 게이트의 검사 대상이 공집합이 되어 통과처럼 보인다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0이면 통과</summary>

    ```bash
    S=.ai/90_issues/archive/issue-0134/issue-0134-summary.md
    awk '
      /^### Task / { if (o && !n && v != 1) b++; o = 1; v = 0; n = ($0 ~ /^### Task N/) }
      o && /^- \*\*결과\*\*:/ {
        if ($0 ~ /^- \*\*결과\*\*: (완료|부분 완료|스킵)[[:space:]]*$/) v++
        else if (!n) b++
      }
      END { if (o && !n && v != 1) b++; print b+0 }
    ' "$S"
    ```

    - 설계 주의: 총개수 비교는 한 블록의 미확정을 다른 블록의 중복 행으로 상쇄해도 통과하므로 블록 단위로 센다.
    - 의존 근거: 아래 게이트의 "`수행 모델` 값 필수" 조건은 `결과`가 완료·부분 완료인 블록에서만 발동하도록 걸려 있다.
    </details>
  - [D] 완료·부분 완료 Task의 `수행 모델`이 비어 있지 않고 `-`도 아닌 행 정확히 1개(`-`는 미착수·스킵 전용)이며, 아래 교차 벤더 조건의 선행 조건이라 전부 `-`로 남기면 그 조건이 공집합이 되어 우회가 된다
    <details>
    <summary>검증 명령 — repo 루트에서 실행, 출력 0이면 통과</summary>

    ```bash
    S=.ai/90_issues/archive/issue-0134/issue-0134-summary.md
    awk '
      /^### Task / { if (o && !n && d && (t != 1 || m != 1)) b++; o = 1; d = 0; t = 0; m = 0; n = ($0 ~ /^### Task N/) }
      o && /^- \*\*결과\*\*: (완료|부분 완료)[[:space:]]*$/ { d = 1 }
      o && /^- \*\*수행 모델\*\*:/ { t++; if ($0 ~ /^- \*\*수행 모델\*\*: [^-[:space:]]/) m++ }
      END { if (o && !n && d && (t != 1 || m != 1)) b++; print b+0 }
    ' "$S"
    ```

    - 설계 주의: 리터럴 `-`만 거부하면 빈 값·행 누락·중복이 통과하므로 "없음"의 세 형태와 중복을 전부 실패로 센다.
    - 의존 근거: 아래 교차 벤더 조건은 비어 있지 않은 `수행 모델` 값에서만 벤더를 뽑아 대조한다.
    </details>
  - [QD] summary `모델 기록` 표의 `구현 모델`·`최종 audit 모델` 두 행이 "벤더, 모델명 (모델 ID)" 형식으로 채워지고 서로 다른 벤더  (검증: 교차모델 audit이 두 행 대조 채점)  ← 강등 사유: 벤더 토큰 추출이 자유 문자열 의미 대조라 명령으로 환원하면 표기 변형에 취약하다
  - [QD] 구현에 여러 벤더가 관여했으면 최종 audit 모델의 벤더가 Task 0 및 일반 실행 Task의 비어 있지 않은 모든 `수행 모델` 값에 나열된 벤더 전부와도 상이  (검증: 교차모델 audit이 `수행 모델` 행 전수 추출 후 audit 벤더와 대조 채점)  ← 강등 사유: 위와 같음. 표의 대표값 비교만으로는 audit 벤더의 구현 참여를 놓치고, 한 Task를 여러 모델이 수행했으면 그 값에 나열된 벤더를 모두 비교 대상에 넣는다
  - [ND] audit이 칭찬이 아니라 허점 탐색 방향으로 수행됨  (검증: 사용자가 audit 리포트 내용으로 판단)  ← 강등 사유: 감사 방향성은 리포트 서술의 의미 판단이라 명령으로 환원 불가
