# Issue #9 스펙 readme-sync 개선: LICENSE 파일 생성 옵션 + 라이선스 인식 가드

> GitHub: https://github.com/scroogy-dev/scroogy-agent-skills/issues/9

## 목표 (Goal)

`readme-sync` 스킬이 README 말미 라이선스 문구뿐 아니라 LICENSE 파일 생성·라이선스 헤더 파일명 가드까지 일관되게 처리하도록 확장하고, 부수적으로 본 저장소의 GitHub "Unknown licenses found" 표기를 해소한다.

---

## 범위 (Scope)

**포함 (In)**

- `readme-sync` init 모드 Q1=(a) 분기에서 LICENSE 파일 생성 옵션 제공
- 라이선스 종류별(Apache 2.0 / MIT) 표준 전문 적용
- 이미 `LICENSE` 파일이 존재하면 덮어쓰지 않고 스킵
- `--force-license` 플래그를 명시한 경우에만 기존 `LICENSE` 덮어쓰기 허용 (초기 오기 수정·라이선스 변경 대응). 동일 라이선스면 무동작, 외부 기여자 존재 시 경고, 대화형 확인을 가드로 둠
- 필요 시 `NOTICE` 파일도 함께 처리
- 라이선스 헤더 파일을 만들 경우 `LICENSE-*` 하이픈 패턴 밖 파일명 사용 (예: `LICENSE_HEADER.txt` 언더스코어 변형)
- 기존에 `LICENSE-HEADER.txt`가 존재하면 리네임/이동 권유
- Q1=(a) 링크 무결성 경고 흐름과 신규 생성 흐름 통합
- 본 저장소의 `LICENSE-HEADER.txt` 처리 (리네임/이동/삭제)
- 본 저장소의 `NOTICE` 파일을 attribution 정석에 맞게 두 줄로 정리 — 재배포 시 Apache 2.0 §4(d)에 의해 본 저장소 저작권자 표기가 후속 배포물에 보존되도록 하기 위함
- 본 저장소 GitHub "Unknown licenses found" 표기 해소 확인

**비포함 (Out)**

- 멀티(듀얼/트라이) 라이선스 지원 — `LICENSE-APACHE` / `LICENSE-MIT` 분리 패턴은 본 스킬 범위 밖
- Apache 2.0 / MIT 외 라이선스 종류 추가
- 기존 `LICENSE` 파일 내용 자동 갱신·동기화
- README 외 다른 문서(예: AI-CONTEXT.md)의 라이선스 표기 변경

---

## 완료의 정의 (Definition of Done)

- [ ] `readme-sync/SKILL.md`에 LICENSE 파일 생성 옵션 사양 기재
- [ ] `readme-sync/SKILL.md`에 `--force-license` 플래그 사양 기재 (동일 라이선스 무동작, 외부 기여자 경고, 대화형 확인 가드 포함)
- [ ] `readme-sync/SKILL.md`에 라이선스 헤더 파일명 가드 사양 기재 (`LICENSE-*` 패턴 회피, 기존 파일 리네임 권유)
- [ ] Q1=(a) 링크 무결성 경고 흐름이 신규 생성 흐름과 충돌 없이 통합되었음을 SKILL.md 본문에서 확인 가능
- [ ] 본 저장소의 `LICENSE-HEADER.txt`가 처리됨 (리네임/이동/삭제 중 한 가지 적용)
- [ ] 본 저장소의 `NOTICE` 파일이 attribution 정석에 맞게 정리됨 (프로젝트명 + 저작권자 두 줄)
- [ ] 본 저장소 GitHub 페이지에 라이선스가 "Apache-2.0"으로 인식됨 (배지/About 영역 확인)

---

## 연관 문서

| 문서 | 역할 |
|------|------|
| `readme-sync/SKILL.md` | 개선 대상 스킬 사양 본문 |
| `LICENSE` / `LICENSE-HEADER.txt` / `NOTICE` (저장소 루트) | 본 저장소의 라이선스 파일 현황·셀프 적용·정리 대상 |
| `.ai/40_domain/index.md` | 도메인 정책 인덱스 (현재 라이선스 관련 항목 없음 — 추후 정책화 검토 시 후보) |
