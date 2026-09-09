---
source: github_issue
source_url: https://github.com/scroogy-dev/scroogy-agent-skills/issues/9
last_harvested: 2026-09-09
---

# 라이선스 정책

## 정책

- 저장소 라이선스는 Apache 2.0이며 루트 `LICENSE`와 `NOTICE`로 일괄 적용한다. 각 SKILL.md 본문에는 라이선스 헤더를 넣지 않는다.
- `NOTICE`는 프로젝트명과 저작권자 두 줄만 둔다. 라이선스 본문 발췌를 넣지 않는다.
- 라이선스 헤더 파일은 `LICENSE-*` 하이픈 패턴 밖의 이름을 쓴다(현재 `LICENSE_HEADER.txt`).
- readme-sync는 init 모드에서 라이선스 3분기(오픈소스 / 개인 저작물·비공개 / 표시하지 않음)와 개인 저작물 고지 포함 여부를 질의한다. 둘 다 비우는 것이 정상 경로다(회사 업무 README 관례).
- 오픈소스 선택 시 LICENSE 파일 생성 옵션(Apache 2.0 / MIT)을 제공하고, 기존 파일이 있으면 기본 스킵한다. `--force-license`는 동일 라이선스 무동작, 외부 기여자 존재 시 경고, 대화형 확인의 가드 3종을 거친다.
- 링크 무결성 점검은 `LICENSE` 파일 존재 여부로 갈린다. 존재하면 경고 없음, 부재면 별도 생성을 권유한다.
- 멀티(듀얼/트라이) 라이선스와 Apache 2.0·MIT 외 종류는 범위 밖이다.

<details>
<summary>근거 펼치기</summary>

- `LICENSE-HEADER.txt`가 GitHub Licensee의 `LICENSE-*` 후보 평가(듀얼 라이선스 명명 관례)에 걸려 짧은 헤더 내용이 표준 전문과 매칭에 실패하고 "Unknown licenses found"가 표시됐다. 언더스코어 변형으로 회피했다 (#9).
- Apache 2.0 §4(d)는 NOTICE에 기재된 attribution을 재배포물에 보존하도록 강제한다. attribution 외 내용을 제거해 보존 범위를 명확히 했다 (#9).
- 스킬 본문 헤더 미삽입은 기존 12개 스킬 패턴을 따른 결정이다 (#1).
- 오픈소스 선택 후 LICENSE 파일이 없으면 README 링크가 깨지므로 생성 옵션과 링크 무결성 점검을 통합했다 (#7, #9).

</details>

## 원본 출처

<details>
<summary>출처 목록 펼치기</summary>

- [Issue #1 (라이선스 헤더 결정)](https://github.com/scroogy-dev/scroogy-agent-skills/issues/1)
- [Issue #7 readme-sync 스킬 개발](https://github.com/scroogy-dev/scroogy-agent-skills/issues/7)
- [Issue #9 readme-sync LICENSE 파일 생성 옵션 + 라이선스 인식 가드](https://github.com/scroogy-dev/scroogy-agent-skills/issues/9)
- 상세 사양: [`readme-sync/references/license.md`](../../../../readme-sync/references/license.md)

</details>
