<!--
README-template.md — readme-sync `init` 모드 기본 템플릿.

원칙: Simple is Best. 꼭 필요한 섹션만 남기고, 각 섹션은 짧게 쓴다.

사용 방법:
- `<...>` 자리표시자를 실제 값으로 채운다.
- `optional:` 마커로 감싼 섹션은 프로젝트에 필요한 것만 남기고 나머지는 통째로 삭제한다.
- 말미 블록은 라이선스 표시·개인 저작물 고지 조합에 따라 일부 또는 전체를 삭제한다 (Task 2 조합표 참조).
- 이 안내 주석(HTML 주석)은 최종 README에 남기지 않는다.
-->

# <프로젝트명>

> <한 줄 설명 — 무엇인지 한 문장으로>

<!-- optional:badges
배지가 필요한 경우에만 둔다 (예: 빌드 상태, 버전, 라이선스).
-->

## 개요

<이 프로젝트가 무엇이고 왜 필요한지 1~2문단. 길게 쓰지 않는다.>

## Quick Start

<가장 빠른 사용 진입점. 명령어 한두 줄 또는 짧은 코드 스니펫.>

<!-- optional:structure -->
## 디렉토리 구조

<!--
표현 순서는 같은 단계 내에서 **대소문자 무시 알파벳순**으로 정렬하되 **디렉토리를 파일보다 위**에 둡니다(IDE 기본 표시 순서). `.`로 시작하는 숨김 항목도 같은 알파벳순으로 처리하며 별도 위치에 두지 않습니다.
-->

```
<주요 디렉토리·파일 트리. 깊이는 1~2단계로 제한.>
```
<!-- /optional:structure -->

<!-- optional:features
"스킬 목록", "기능", "구성 요소" 등 프로젝트 성격에 맞는 제목을 쓴다.
-->
## <스킬 목록 / 기능 / 구성 요소>

| 항목 | 설명 |
|------|------|
| `<name>` | <한 줄 설명> |
<!-- /optional:features -->

<!-- optional:docs -->
## 문서

- [<문서명>](<경로 또는 URL>)
<!-- /optional:docs -->

<!-- optional:contributing -->
## 기여

<기여 방법을 한두 줄로. 별도 CONTRIBUTING.md가 있으면 그쪽 링크로 대체.>
<!-- /optional:contributing -->

<!--
말미 블록 — 라이선스 × 개인 저작물 고지 6가지 조합 중 하나를 선택해 구성한다.
- 라이선스 (a) 오픈소스: `## 라이선스` 블록 사용. LICENSE 파일·NOTICE 파일을 함께 연결.
- 라이선스 (b) 개인 저작물·비공개: `## 라이선스` 블록을 `All Rights Reserved` 또는 `UNLICENSED`로.
- 라이선스 (c) 표시하지 않음: `## 라이선스` 블록 전체 삭제.
- 개인 저작물 고지 미포함: `### 개인 저작물 고지` 블록 삭제.
- 라이선스·고지 모두 없는 경우: 말미 블록(Copyright 포함) 전체 삭제.
- 라이선스 또는 고지 중 하나라도 남으면 Copyright 라인은 함께 둔다.
-->

<!-- optional:footer-license
라이선스 분기 한 가지를 골라 본문 문구로 채운다:
- (a) 오픈소스: "이 프로젝트는 [<라이선스명>](./LICENSE)에 따라 라이선스가 부여됩니다." (필요 시 NOTICE·LICENSE_HEADER 링크 추가)
- (b) 개인 저작물·비공개: "All Rights Reserved." (또는 npm 진영이면 "UNLICENSED")
- (c) 표시하지 않음: 이 블록 전체 삭제
-->
## 라이선스

<위 분기 중 하나의 문구>
<!-- /optional:footer-license -->

<!-- optional:footer-notice -->
### 개인 저작물 고지

이 프로젝트는 **<작성자>**의 개인 저작물입니다. 특정 기업이나 조직의 업무와 무관하게, 개인적인 목적으로 개발 및 관리되고 있습니다.
<!-- /optional:footer-notice -->

<!-- optional:footer-copyright -->
```
Copyright <YEAR> <AUTHOR> (<EMAIL>)
```
<!-- /optional:footer-copyright -->
