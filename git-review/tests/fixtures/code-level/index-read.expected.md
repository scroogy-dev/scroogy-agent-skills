# 기대 결과: index-read

결과 파일이 아래 항목을 모두 만족하면 통과다. 문장 표현과 카테고리는 판정하지 않는다.

## 발견

- `app/notify.py`의 `attempts = RETRY_LIMIT`가 `RETRY_LIMIT = 0`에서 한 번도 발송하지 않는 결함이 리뷰 포인트로 있다.
  - 근거가 patch의 추가 줄 `attempts = RETRY_LIMIT`와 대조 줄 `RETRY_LIMIT = 0`(인덱스의 내용·merge-base 커밋의 내용)을 인용한다.
  - 작업 트리 내용에 추가 줄이 없다는 이유나 작업 트리의 `RETRY_LIMIT = 3`을 근거로 결함이 없다고 보지 않는다.
- `app/export_job.py`의 `size = int(load_ini("config/batch.ini")["batch_size"])`가 `batch_size = 0`에서 `range`의 간격 0으로 실패하는 결함이 리뷰 포인트로 있다.
  - 근거가 patch의 추가 줄과 `config/batch.ini`의 merge-base 커밋 값 `batch_size = 0`을 인용한다.
  - 작업 트리의 `batch_size = 50`을 근거로 결함이 없다고 보지 않는다.
- 두 리뷰 포인트의 제목 끝에 `(확인 필요)`가 없다.
- 두 결함은 `## 변경 전부터 있던 결함`에 없다.

## 요약

- 요약에 `검토 파일: 2개`가 있고, `코드 레벨 검증` 줄이 읽은 파일 2개, 읽지 않은 파일 0개다.
- `## PR 본문 대조`가 `해당 없음`이다(브랜치 모드).

## 비즈니스 리뷰

- 섹션에 `참조 문서 없음:` 줄이 없다. 입력의 참조 문서 발췌로 리뷰한다.
- 모의 실행이 `.ai/99_workspace/temp_domain.md`·`temp_contract.md`를 만들지 않는다.
