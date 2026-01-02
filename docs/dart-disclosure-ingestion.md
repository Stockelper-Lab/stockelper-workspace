# DART 공시 기반 이벤트 수집/감성 분석 파이프라인 명세
**작성일:** 2026-01-02  
**대상 코드:** `stockelper-airflow` (크롤링/ETL), `stockelper-kg` (온톨로지/그래프 업로드 참조)  

---

## 1) 목표 (Why)
- **DART 공시(OpenDART)에서 “주요 이벤트”를 장기간(상장 이후 전체) 수집**하여,
  - MongoDB에 **원문/메타데이터(원천 데이터)**를 저장하고
  - 온톨로지에 맞는 **이벤트 구조화 데이터 + 감성지수(-1~1)** 를 생성해 저장한다.
- 생성된 이벤트는 **백테스팅에서 이벤트/감성 신호로 사용**한다.

---

## 2) 범위 (Scope)
### In Scope
- DART 공시 목록(list.json) → 공시 원문(document.xml) 수집
- 공시 원문에서 **이벤트 정보(온톨로지 기반) + 감성지수**를 LLM으로 추출
- MongoDB에 **원문/파생 이벤트 데이터** 저장
- **벌크(초기 백필)** + **일일 업데이트(증분)** 모두 지원
- **중복 처리(동일 일자 동일 이벤트는 통과)** 정책 적용
- (옵션) MongoDB에 저장된 이벤트를 **Neo4j로 업로드** (일일 업데이트 뒤에 연결)

### 구현 상태(현재)
- Airflow DAG:
  - `dart_disclosure_backfill` (수동 실행)
  - `dart_disclosure_daily` (daily schedule)
- Neo4j 업로드:
  - `dart_disclosure_daily`: `update` → `upload_neo4j` → `report`
  - `dart_disclosure_backfill`: `backfill` → `upload_neo4j` → `report` (옵션/환경변수로 범위 조절 가능)

---

## 3) 온톨로지 기준 (Neo4j Schema)
### 참조 파일
- 이벤트 타입/슬롯: `stockelper-kg/src/stockelper_kg/graph/ontology.py`
- 그래프 페이로드 생성 로직: `stockelper-kg/src/stockelper_kg/graph/payload.py`

### DART 주요 공시 → 온톨로지 이벤트 타입(권장 매핑)
> DART 공시는 제목(`report_nm`)이 표준화되어 있어, **규칙 기반 1차 분류 + LLM 슬롯/감성 추출** 조합이 안정적이다.

| DART(main events) 분류(예시 report_nm) | Ontology `event_type` |
| --- | --- |
| 유상증자결정 / 제3자배정 유상증자 / 주주배정 유상증자 / 전환사채권발행결정(CB) / 신주인수권부사채권발행결정(BW) / 교환사채권발행결정 / 전환청구권 행사 / 증권신고서 제출 | `CAPITAL_RAISE` |
| 자기주식 취득 결정 / 자기주식 처분 결정 / 자기주식 소각 결정 / 현금·현물배당 결정 / 분기배당 결정 / 중간배당 결정 | `CAPITAL_RETURN` |
| 감자결정 | `CAPITAL_STRUCTURE_CHANGE` |
| 거래정지처분 / 상장폐지 관련 | `LISTING_STATUS_CHANGE` |
| 주식양수도계약 체결 / 타법인 주식 및 출자증권 취득·처분 결정 / 합병결정 / 영업양수도 결정 | `STRATEGY_MNA` |
| 분할결정 / 분할합병결정 | `STRATEGY_SPINOFF` |
| 최대주주 변경 / 주요주주 변동(5% 공시 등) | `OWNERSHIP_CHANGE` |
| 단일판매·공급계약 체결·해지 / 타법인과의 중요계약 체결·해지 | `DEMAND_SALES_CONTRACT` |
| 영업(잠정)실적(공정공시) / 연결재무제표기준 영업(잠정)실적 / 손익구조 30% 이상 변경 | `REVENUE_EARNINGS` |
| 공장 가동중단·재가동 | `SUPPLY_HALT` |
| 주요 소송 등의 제기·판결 | `LEGAL_LITIGATION` |
| 횡령·배임 등 범죄사실 확인 / 회생절차개시신청 / 단기사채 미상환 등 | `CRISIS_EVENT` |
| 위에 해당하지 않음(풍문/보도 해명, 자율공시 등) | `OTHER` |

### 핵심 노드/관계(요약)
- **Company**(기업)
- **Event**(이벤트): `event_id`, `type`, `summary` + slots
- **Document**(공시 원문): `rcept_no`, `report_nm`, `rcept_dt`, `url`, `body`
- **EventDate/Date**(날짜 정규화)
- 관계 예시:
  - `INVOLVED_IN`: Company → Event
  - `REPORTED_BY`: Event → Document
  - `OCCURRED_ON`: Event → EventDate

---

## 4) 데이터 소스: OpenDART(Open API)
### 필수 환경변수
- `OPEN_DART_API_KEY`: OpenDART 인증키

### 사용할 OpenDART API (권장)
- **corpCode.xml**: `stock_code → corp_code` 매핑 확보(1회 다운로드 후 캐시/저장)
- **list.json**: 기업별/기간별 공시 목록
- **document.xml**: 공시 원문(접수번호 `rcept_no` 기반)

> 구현에서는 `OpenDartReader`를 활용할 수 있으나, **페이징/재시도 제어**를 위해 `requests` 기반 Open API 호출을 우선 권장한다.

---

## 5) 수집 대상(주식 유니버스)
### 원칙
- **특정 종목 목록(유니버스)만 수집**
- 유니버스는 파일/YAML/컬렉션 등으로 관리하여 **추가 확장 용이**하게 설계

### 초기 유니버스 확정(회의 문서 근거)
- 근거 문서:
  - `docs/references/20251208.md`
  - `docs/references/20251215.md`
- 결론: **MVP 초기 수집은 “AI 관련주” 중심으로 시작**한다.
  - 대형 플랫폼/빅테크: 네이버, 카카오
  - AI 소프트웨어/플랫폼: 이스트소프트, 와이즈넛, 코난테크놀로지, 마음AI, 엑셈
  - AI 데이터·언어: 플리토
  - 비전·인증·보안: 알체라, 한국전자인증
  - 로봇·자율주행·스마트팩토리: 레인보우로보틱스, 유진로봇, 로보로보, 큐렉소

### `DART_UNIVERSE_JSON` 템플릿
- 템플릿 파일(레포 포함): `stockelper-airflow/modules/dart_disclosure/universe.ai-sector.template.json`
- Airflow 컨테이너 기준 예시:
  - `DART_UNIVERSE_JSON=/opt/airflow/modules/dart_disclosure/universe.ai-sector.template.json`
- 권장 설정 방식:
  - **Airflow UI → Admin → Variables**에 `DART_UNIVERSE_JSON` 키로 파일 경로를 저장(코드는 Variable 우선 조회)
- **확장 방식(추후 종목 추가)**
  - 항목을 JSON 배열에 추가(권장 필드: `corp_name`, 선택: `stock_code`, `dart_corp_name`, `aliases`, `enabled`, `tags`)
  - `stock_code`를 모를 경우:
    - `corpCode.xml`로부터 `corp_name` 기반으로 자동 해석(가능한 경우)
    - 단, DART 상의 공식 회사명이 다른 경우(예: NAVER) `dart_corp_name` 또는 `aliases`로 보정

### Backfill용 유니버스 vs Daily용 유니버스(분리 옵션)
기본적으로는 **Backfill/Daily 모두 동일 유니버스**(`DART_UNIVERSE_JSON` 또는 `DART_STOCK_CODES`)를 사용한다.
운영 시 비용/속도 목적(예: Daily는 핵심 종목만)으로 분리하고 싶으면 아래 Airflow Variables를 사용한다.

- Backfill 전용(옵션): `DART_UNIVERSE_JSON_BACKFILL`
  - 설정 시 Backfill DAG는 이 경로를 사용
  - 미설정 시 `DART_UNIVERSE_JSON`로 fallback
- Daily 전용(옵션): `DART_UNIVERSE_JSON_DAILY`
  - 설정 시 Daily DAG는 이 경로를 사용
  - 미설정 시 `DART_UNIVERSE_JSON`로 fallback

### 최소 필드(이번 단계)
- `stock_code` (6자리)
- `corp_name` (선택, 없으면 corpCode.xml 매핑에서 보강)

### 상장 이후 전체 기간
- 기본: **상장일 ~ 오늘**
- 상장일은 `FinanceDataReader.StockListing("KRX")`의 `ListingDate` 활용(가능한 경우)
- 불가 시 fallback start date를 사용하되, 유니버스별로 override 가능하게 한다.

---

## 6) MongoDB 저장 설계
### 필수 환경변수
- `MONGODB_URI`
- `MONGO_DATABASE`

### 컬렉션(제안)
1) `dart_corp_codes`
- 목적: `stock_code ↔ corp_code` 매핑 캐시
- Unique Index: `stock_code`

2) `dart_filings`
- 목적: 공시 목록/원문 **원천 저장**
- Unique Index: `rcept_no`
- 주요 필드:
  - `rcept_no` (unique)
  - `corp_code`, `stock_code`, `corp_name`
  - `rcept_dt` (YYYYMMDD), `report_nm`
  - `pblntf_ty`, `pblntf_detail_ty` 등 list.json 메타
  - `url` (DART 뷰어 URL)
  - `body_text` (document.xml → 텍스트 정제)
  - `raw` (원본 row/document 일부 저장 - 필요 시)
  - `ingested_at`

3) `dart_events`
- 목적: 온톨로지 기반 구조화 이벤트 + 감성 점수
- Unique Index: `event_key` (동일 일자 동일 이벤트 중복 방지 키)
- 주요 필드:
  - `event_key` (sha1 기반; 아래 “중복 처리 규칙” 참고)
  - `event_id` (Neo4j용, `stockelper-kg`의 생성 규칙과 호환 권장)
  - `event_type` (ontology enum)
  - `date` (YYYY-MM-DD)
  - `corp_code`, `stock_code`, `corp_name`
  - `summary`
  - `required_slots`, `optional_slots`
  - `sentiment_score` (-1.0 ~ 1.0)
  - `source`: `{rcept_no, report_nm, rcept_dt, url}`
  - `created_at`

4) `dart_ingestion_state`
- 목적: 증분 수집을 위한 상태 관리(마지막 처리 일자/접수번호 등)
- Unique Index: `stock_code`

---

## 7) 이벤트 추출 + 감성지수 추출(LLM)
### 필수 환경변수
- `OPENAI_API_KEY`
- `OPENAI_MODEL` (default: `gpt-5.1`)

### 입력 텍스트 구성(권장)
- `corp_name`, `stock_code`
- `report_nm`, `rcept_dt`, `url`
- `body_text` (길면 앞/뒤 요약 또는 주요 섹션만 포함)

### 출력 스키마(권장; stockelper-kg 스타일 호환)
```json
{
  "event_type": "ONTOLOGY_EVENT_ENUM",
  "corp_name": "회사명",
  "summary": "핵심 요약 1문장",
  "required_slots": { "date": "YYYY-MM-DD", "...": "..." },
  "optional_slots": { "...": "..." },
  "sentiment_score": 0.15
}
```

### 감성지수 정의
- -1: 강한 부정(지분희석/디폴트/상폐/횡령/대규모 손실 등)
- 0: 중립(정보성 공시, 영향 불명확)
- +1: 강한 긍정(대형 수주/자사주 소각/호실적/규제승인 등)

---

## 8) 중복 처리 규칙 (중요)
### 원칙
- **동일 일자에 동일 이벤트 정보가 이미 있으면 통과(pass)**

### 구현 제안
- `event_key = sha1("{stock_code}|{date}|{event_type}|{normalized_summary}")`
- MongoDB `dart_events`에 `event_key` Unique Index 생성
- 공시 원문(`dart_filings`)은 `rcept_no` Unique로 원천 중복 방지

---

## 9) 처리 흐름(벌크 백필 → 일일 업데이트)
### 9-1. 벌크 백필(초기 1회)
1. 유니버스 로드
2. corpCode.xml로 corp_code 매핑 확보(+캐시)
3. 각 종목별 상장일~오늘을 **연/분기 단위로 chunking**
4. `list.json` 페이지네이션 수집
5. 신규 `rcept_no`에 대해:
   - `document.xml` 원문 수집 → 텍스트 정제
   - Mongo `dart_filings` upsert
   - LLM으로 이벤트/감성 추출 → `dart_events` upsert(중복이면 skip)
6. `dart_ingestion_state` 갱신

### 9-2. 일일 업데이트(매일)
- 기본: `last_processed_date - buffer_days` ~ today 범위를 다시 조회(정정공시/누락 대비)
- 신규 `rcept_no`만 처리하고 나머지는 skip

---

## 10) 구현 위치(파일/모듈)
### Airflow (크롤링/ETL)
- `stockelper-airflow/modules/dart_disclosure/`
  - `universe.py` or `universe.yaml`
  - `opendart_api.py` (corpCode/list/document 호출)
  - `mongo_repo.py` (컬렉션/인덱스/업서트)
  - `llm_extractor.py` (이벤트+감성 추출)
  - `runner.py` (bulk_backfill / daily_update 엔트리)

### KG (온톨로지/Neo4j 업로드 참조)
- `stockelper-kg/src/stockelper_kg/graph/ontology.py`
- `stockelper-kg/src/stockelper_kg/graph/payload.py`

### DAG (마지막 단계)
- `stockelper-airflow/dags/`
  - `dart_disclosure_backfill_dag.py` (수동 실행; backfill 후 Neo4j 업로드 포함)
  - `dart_disclosure_daily_dag.py` (daily schedule; daily update 후 Neo4j 업로드 포함)


