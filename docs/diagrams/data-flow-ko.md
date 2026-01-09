# Stockelper 데이터 플로우 다이어그램

Stockelper 시스템의 5가지 핵심 데이터 흐름을 보여주는 다이어그램입니다. 데이터가 진입점에서 처리 단계를 거쳐 최종 결과물까지 어떻게 이동하는지 설명합니다.

## 개요

Stockelper 플랫폼은 5가지 주요 흐름을 통해 데이터를 처리합니다:

1. **DART 수집 파이프라인** (매일, 오전 8시) - 자동화된 공시 데이터 수집
2. **사용자 채팅 상호작용** (실시간) - 멀티 에이전트 AI 분석
3. **포트폴리오 추천** (사용자 트리거) - Black-Litterman 최적화
4. **이벤트 기반 백테스팅** (사용자 주도) - 과거 성과 분석
5. **실시간 알림** (이벤트 구동) - 사용자에게 푸시 업데이트

## 범례

- **🔵 파란색 노드**: 데이터 소스 및 진입점
- **🟣 보라색 노드**: 처리 단계 및 변환
- **🟢 초록색 노드**: 저장 작업
- **🟠 주황색 노드**: 출력 및 결과
- **🟡 노란색 노드**: 의사결정 지점

## 데이터 플로우 다이어그램

```mermaid
graph TB
    %% ========== 스타일링 ==========
    classDef dataSource fill:#3498DB,stroke:#2980B9,stroke-width:2px,color:#fff
    classDef process fill:#9B59B6,stroke:#8E44AD,stroke-width:2px,color:#fff
    classDef storage fill:#2ECC71,stroke:#27AE60,stroke-width:2px,color:#fff
    classDef output fill:#E67E22,stroke:#D35400,stroke-width:2px,color:#fff
    classDef decision fill:#F39C12,stroke:#E67E22,stroke-width:2px,color:#000

    %% ========== 플로우 1: DART 수집 파이프라인 ==========
    subgraph FLOW1["📊 플로우 1: DART 공시 수집 (매일 오전 8시 KST)"]
        direction TB
        D1_START["<b>DART API</b><br/>20개 주요 보고서 유형<br/>6개 카테고리"]:::dataSource
        D1_COLLECT["<b>Airflow DAG</b><br/>병렬 API 호출<br/>속도 제한<br/>0.2초 대기"]:::process
        D1_STORE1["<b>원시 데이터 저장</b><br/>로컬 PostgreSQL<br/>20개 분리 테이블<br/>rcept_no로 인덱싱"]:::storage
        D1_EXTRACT["<b>메트릭 추출</b><br/>16개 공시 유형<br/>재무 비율 계산<br/>(조달비율, 희석률 등)"]:::process
        D1_STORE2["<b>메트릭 저장</b><br/>dart_disclosure_metrics<br/>JSONB 형식<br/>연산자로 쿼리 가능"]:::storage
        D1_KG["<b>지식 그래프 구축</b><br/>이벤트 노드 생성<br/>기업 및 날짜 연결<br/>Neo4j 관계"]:::storage

        D1_START --> D1_COLLECT
        D1_COLLECT --> D1_STORE1
        D1_STORE1 --> D1_EXTRACT
        D1_EXTRACT --> D1_STORE2
        D1_STORE2 --> D1_KG
    end

    %% ========== 플로우 2: 사용자 채팅 상호작용 ==========
    subgraph FLOW2["💬 플로우 2: 사용자 채팅 상호작용 (실시간 스트리밍)"]
        direction TB
        C1_USER["<b>사용자 쿼리</b><br/>자연어<br/>예: '삼성전자 분석해줘'"]:::dataSource
        C1_ROUTER["<b>슈퍼바이저 에이전트</b><br/>쿼리 분류<br/>전문가에게 라우팅"]:::process

        subgraph AGENTS["멀티 에이전트 시스템 (asyncio.gather로 병렬 실행)"]
            direction LR
            C1_MARKET["<b>시장분석 에이전트</b><br/>• SearchNews<br/>• SearchReport<br/>• YouTubeSearch<br/>• GraphQA"]:::process
            C1_FUND["<b>기본분석 에이전트</b><br/>• DART API<br/>• 5년 재무제표<br/>• 비율 계산"]:::process
            C1_TECH["<b>기술분석 에이전트</b><br/>• Prophet + ARIMA<br/>• 가격 히스토리<br/>• 지표"]:::process
            C1_INV["<b>투자전략 에이전트</b><br/>• 전략 검색<br/>• 계좌 정보<br/>• 통합"]:::process
        end

        C1_TOOLS["<b>도구 실행</b><br/>• Neo4j 그래프 쿼리<br/>• PostgreSQL 읽기<br/>• KIS API 호출<br/>• OpenAI 추론"]:::process
        C1_STREAM["<b>SSE 스트리밍</b><br/>진행 이벤트<br/>델타 이벤트<br/>토큰 단위"]:::output
        C1_FINAL["<b>최종 응답</b><br/>분석 + 신뢰도<br/>서브그래프 시각화<br/>거래 액션"]:::output

        C1_USER --> C1_ROUTER
        C1_ROUTER --> AGENTS
        AGENTS --> C1_TOOLS
        C1_TOOLS --> C1_STREAM
        C1_STREAM --> C1_FINAL
    end

    %% ========== 플로우 3: 포트폴리오 추천 ==========
    subgraph FLOW3["📈 플로우 3: 포트폴리오 추천 (버튼 트리거)"]
        direction TB
        P1_TRIGGER["<b>사용자 버튼 클릭</b><br/>포트폴리오 페이지<br/>생성 요청"]:::dataSource
        P1_JOB["<b>작업 레코드 생성</b><br/>job_id (UUID)<br/>상태: PENDING<br/>원격 PostgreSQL"]:::storage
        P1_RANK["<b>11-팩터 랭킹</b><br/>• 영업이익<br/>• 순이익<br/>• 부채<br/>• 상승/하락률<br/>• 시가총액<br/>• 등"]:::process
        P1_PARALLEL["<b>병렬 분석</b><br/>웹 검색 (Perplexity)<br/>재무제표 (DART)<br/>기술 지표 (KIS)"]:::process
        P1_VIEW["<b>LLM 뷰 생성</b><br/>기대 수익률<br/>신뢰도 점수<br/>근거"]:::process
        P1_COV["<b>공분산 행렬</b><br/>252일 히스토리<br/>연율화 수익률"]:::process
        P1_BL["<b>Black-Litterman</b><br/>사후 계산<br/>P, Q, Omega 행렬<br/>내재 수익률"]:::process
        P1_OPT["<b>포트폴리오 최적화</b><br/>SLSQP 솔버<br/>제약: Σw=1<br/>개별 최대: 30%"]:::process
        P1_RESULT["<b>결과 저장</b><br/>마크다운 리포트<br/>기대 수익률 및 변동성<br/>샤프 비율<br/>상태: COMPLETED"]:::storage
        P1_NOTIFY["<b>Supabase Realtime</b><br/>브라우저 알림<br/>페이지 자동 업데이트"]:::output

        P1_TRIGGER --> P1_JOB
        P1_JOB --> P1_RANK
        P1_RANK --> P1_PARALLEL
        P1_PARALLEL --> P1_VIEW
        P1_VIEW --> P1_COV
        P1_COV --> P1_BL
        P1_BL --> P1_OPT
        P1_OPT --> P1_RESULT
        P1_RESULT --> P1_NOTIFY
    end

    %% ========== 플로우 4: 백테스팅 ==========
    subgraph FLOW4["🔬 플로우 4: 이벤트 기반 백테스팅 (사용자 주도)"]
        direction TB
        B1_CHAT["<b>사용자 채팅 요청</b><br/>LLM 파라미터 추출<br/>이벤트 유형, 메트릭, 기간"]:::dataSource
        B1_VALIDATE{"<b>파라미터<br/>완료?</b>"}:::decision
        B1_PROMPT["<b>LLM 후속 질문</b><br/>명확화 질문<br/>Human-in-Loop"]:::process
        B1_CREATE["<b>작업 생성</b><br/>job_id (UUID)<br/>상태: PENDING<br/>원격 PostgreSQL"]:::storage
        B1_WORKER["<b>비동기 워커</b><br/>5초마다 폴링<br/>SELECT FOR UPDATE<br/>SKIP LOCKED"]:::process
        B1_QUERY["<b>메트릭 쿼리</b><br/>사용자 정의 조건<br/>JSONB 연산자<br/>예: 조달비율 > 0.05"]:::process
        B1_RETURNS["<b>수익률 계산</b><br/>1, 3, 6, 12개월<br/>가격 히스토리로부터<br/>실현 손익"]:::process
        B1_SHARPE["<b>성과 메트릭</b><br/>샤프 비율<br/>승률<br/>MDD, 총 수익률<br/>매수 보유 대비"]:::process
        B1_REPORT["<b>리포트 생성</b><br/>LLM 마크다운 리포트<br/>차트 (base64 PNG)<br/>상태: COMPLETED"]:::storage
        B1_NOTIFY2["<b>Supabase Realtime</b><br/>브라우저 알림<br/>결과 페이지 업데이트"]:::output

        B1_CHAT --> B1_VALIDATE
        B1_VALIDATE -->|"아니오<br/>(정보 부족)"| B1_PROMPT
        B1_PROMPT --> B1_VALIDATE
        B1_VALIDATE -->|"예<br/>(준비됨)"| B1_CREATE
        B1_CREATE --> B1_WORKER
        B1_WORKER --> B1_QUERY
        B1_QUERY --> B1_RETURNS
        B1_RETURNS --> B1_SHARPE
        B1_SHARPE --> B1_REPORT
        B1_REPORT --> B1_NOTIFY2
    end

    %% ========== 플로우 5: 실시간 알림 ==========
    subgraph FLOW5["🔔 플로우 5: 실시간 알림 흐름 (이벤트 구동)"]
        direction TB
        N1_CHANGE["<b>데이터베이스 변경</b><br/>PostgreSQL 트리거<br/>INSERT/UPDATE<br/>결과 테이블에"]:::dataSource
        N1_SUPABASE["<b>Supabase Realtime</b><br/>변경 감지<br/>WebSocket 프로토콜"]:::process
        N1_SUBSCRIBE["<b>프론트엔드 구독</b><br/>React Hook<br/>useEffect 리스너"]:::process
        N1_UPDATE["<b>UI 자동 업데이트</b><br/>컴포넌트 재렌더링<br/>페이지 새로고침 없음<br/>폴링 없음"]:::output
        N1_BROWSER["<b>브라우저 알림</b><br/>Confluence 스타일 배지<br/>알림 벨<br/>비침해적"]:::output

        N1_CHANGE --> N1_SUPABASE
        N1_SUPABASE --> N1_SUBSCRIBE
        N1_SUBSCRIBE --> N1_UPDATE
        N1_SUBSCRIBE --> N1_BROWSER
    end
```

## 플로우 세부사항

### 플로우 1: DART 수집 파이프라인
**트리거**: 매일 오전 8시 KST (Airflow 스케줄러)

**목적**: 한국 금융 공시를 수집하고 정량적 메트릭 추출

**처리 시간**: 100개 이상 종목에 대해 약 30-60분

**핵심 기술**:
- Apache Airflow 2.10 오케스트레이션
- OpenDART API 데이터 소스
- PostgreSQL 구조화된 저장소
- Neo4j 지식 그래프

**출력**:
- PostgreSQL의 원시 공시 (20개 테이블)
- JSONB 형식의 계산된 메트릭 (16개 유형)
- 지식 그래프 노드 및 관계

---

### 플로우 2: 사용자 채팅 상호작용
**트리거**: 사용자가 채팅 인터페이스에 메시지 입력

**목적**: 멀티 에이전트 시스템을 사용한 실시간 AI 분석 제공

**처리 시간**: 2-5초 (LLM 추론 포함)

**핵심 기술**:
- LangGraph 멀티 에이전트 오케스트레이션
- GPT-5.1 자연어 이해
- Neo4j 그래프 패턴 매칭
- Server-Sent Events 스트리밍

**출력**:
- 스트리밍 분석 응답
- 서브그래프 시각화
- 신뢰도 점수
- 거래 액션 제안

---

### 플로우 3: 포트폴리오 추천
**트리거**: 사용자가 "추천 생성" 버튼 클릭

**목적**: Black-Litterman 모델을 사용한 최적화된 포트폴리오 생성

**처리 시간**: 3-5분 (비동기 작업)

**핵심 기술**:
- 11-팩터 랭킹 알고리즘
- Black-Litterman 최적화
- SLSQP 솔버 (scipy.optimize)
- Perplexity AI 시장 컨텍스트

**출력**:
- 상위 10개 종목 추천
- 기대 수익률 및 변동성
- 기준 대비 샤프 비율
- 차트가 포함된 마크다운 리포트

---

### 플로우 4: 이벤트 기반 백테스팅
**트리거**: 사용자가 채팅 인터페이스를 통해 요청

**목적**: 과거 이벤트 데이터를 사용한 투자 전략 검증

**처리 시간**: 백테스트당 5-10분 (비동기 작업)

**핵심 기술**:
- 워커 폴링 방식 PostgreSQL 작업 큐
- 유연한 쿼리를 위한 JSONB 연산자
- 과거 가격 데이터 분석
- LLM 생성 리포트

**출력**:
- 다중 타임프레임 수익률 (1/3/6/12개월)
- 샤프 비율 비교
- 승률 통계
- 상세 마크다운 리포트

---

### 플로우 5: 실시간 알림
**트리거**: 데이터베이스 변경 (INSERT/UPDATE)

**목적**: 클라이언트 측 폴링 없이 즉각적인 업데이트 제공

**처리 시간**: <100ms 지연시간

**핵심 기술**:
- Supabase Realtime (WebSocket 기반)
- PostgreSQL 트리거
- React 구독 훅

**출력**:
- 자동 UI 업데이트
- 브라우저 알림 배지
- 비침해적 알림

## 데이터 변환 요약

| 플로우 | 입력 형식 | 변환 | 출력 형식 |
|------|-------------|----------------|---------------|
| DART 수집 | XML/JSON | 텍스트 추출, 메트릭 계산 | PostgreSQL 테이블, Neo4j 그래프 |
| 채팅 상호작용 | 자연어 | 멀티 에이전트 분석, 종합 | 스트리밍 텍스트, JSON 서브그래프 |
| 포트폴리오 | 버튼 클릭 | 랭킹, 최적화 | 마크다운 리포트, PNG 차트 |
| 백테스팅 | 채팅 파라미터 | 이벤트 매칭, 수익률 계산 | 성과 메트릭, 리포트 |
| 알림 | DB 트리거 | 변경 감지 | WebSocket 메시지, UI 업데이트 |

## 처리 특성

| 플로우 | 유형 | 동시성 | 규모 |
|------|------|-------------|-------|
| DART 수집 | 배치 | 속도 제한을 둔 순차 | 무제한 과거 데이터 |
| 채팅 상호작용 | 실시간 | 병렬 에이전트 실행 | 100명 이상 동시 사용자 |
| 포트폴리오 | 비동기 작업 | 큐 기반 워커 | 다중 대기 요청 |
| 백테스팅 | 비동기 작업 | 큐 기반 워커 | 다중 대기 요청 |
| 알림 | 이벤트 구동 | 모든 구독자에게 푸시 | 실시간 브로드캐스트 |

## 관련 문서

- [시스템 아키텍처](./system-architecture-ko.md) - 서비스 토폴로지 및 연결
- [아키텍처 결정 문서](../architecture.md) - 상세 설계 결정사항
- [PRD](../prd.md) - 각 플로우의 기능 요구사항
- [개별 서비스 README](../../sources/*/README.md) - 서비스별 세부사항

## 이 다이어그램 보는 방법

- **GitHub**: 마크다운 프리뷰에서 자동 렌더링
- **VS Code**: Mermaid 확장 프로그램 설치하여 라이브 프리뷰
- **Mermaid Live Editor**: 코드를 [mermaid.live](https://mermaid.live/)에 복사
- **내보내기**: Mermaid CLI를 사용하여 프레젠테이션용 PNG/SVG 생성
