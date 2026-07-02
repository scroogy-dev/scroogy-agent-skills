# Antigravity 레거시 경로 점검 — 판정 기준과 배경

`install-skills` 설치 검증 6~7단계에서 `--antigravity-legacy` 플래그가 수행하는 구 Antigravity skills 경로 점검의 상세입니다.
판정 로직 자체는 `scripts/verify-install.sh`가 보유하며, 이 문서는 그 판정을 해석·처리하는 기준을 설명합니다.

## 적용 조건

- Antigravity 경로가 설치 대상일 때만(`--antigravity` 또는 `--all`) 점검합니다.
- Antigravity 경로를 설치하지 않는 대상(`--claude` 등 단독)에 `--antigravity-legacy`를 붙이지 않습니다 — 붙이면 무관한 구 경로 상태로 거짓 FAIL이 날 수 있습니다.

## 판정 기준 (verify-install.sh)

| 구 경로 상태 | 판정 | 처리 |
|---|---|---|
| 심링크 | PASS (INFO) | 보존 — 통상 신(공식) 경로와 동일 위치를 가리키므로 건드리지 않음 |
| 부재 | PASS (INFO) | 정상 — 조치 없음 |
| 빈 실제 디렉토리 | PASS (INFO) | 보존 — skill 중복 인식 위험이 없음 |
| 비어있지 않은 실제 디렉토리 | FAIL | 사용자에게 경고하고 정리(제거)를 제안 — 승인 시에만 제거 |

## 배경

- `--clear`는 신(대상) 경로만 비우므로, 구 경로가 비어있지 않은 실제 디렉토리로 남으면 동일 skill이 중복 인식될 수 있습니다. install-skills가 레거시 잔존을 명시적으로 처리하는 이유입니다.
- 구 Antigravity skills 경로의 리터럴은 SKILL.md가 아니라 `scripts/verify-install.sh`가 단일 출처로 보유합니다 (이슈 #28 결정).
