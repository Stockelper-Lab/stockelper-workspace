# 📈 Stockelper Workspace

**AI 기반 한국 주식 투자 플랫폼의 중앙 워크스페이스**

Stockelper는 LangGraph 다중 에이전트 시스템, Neo4j 지식 그래프, Black-Litterman 포트폴리오 최적화를 활용하여 투자자에게 맞춤형 투자 전략과 자동매매 기능을 제공하는 종합 투자 플랫폼입니다.

---

## 🌟 프로젝트 개요

Stockelper-Lab은 한국 주식 시장 투자를 위한 AI 기반 통합 플랫폼으로, 7개의 마이크로서비스가 유기적으로 연동되어 다음과 같은 서비스를 제공합니다:

- **AI 투자 상담**: GPT-5.1 기반 실시간 채팅 상담
- **포트폴리오 추천**: 투자 성향 맞춤형 포트폴리오 생성 및 최적화
- **백테스팅**: 투자 전략 시뮬레이션 및 성과 분석
- **지식 그래프**: Neo4j 기반 기업 관계 및 시장 동향 분석
- **데이터 파이프라인**: Apache Airflow 기반 자동화된 데이터 수집

---

## 🏗️ 시스템 아키텍처

### 전체 구조

```
┌─────────────────────────────────────────────────────────────────┐
│                    Stockelper Workspace                          │
│                  (BMAD 중앙 레포지토리)                            │
│            - 문서 및 정책 관리                                      │
│            - 에이전트 정의                                         │
│            - Blueprint & 템플릿                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ Frontend      │    │ LLM Service   │    │ Portfolio     │
│ (Next.js 15)  │◄──►│ (LangGraph)   │◄──►│ Service       │
│ Port: 3000    │    │ Port: 21009   │    │ Port: 21008   │
└───────┬───────┘    └───────┬───────┘    └───────┬───────┘
        │                    │                    │
        │            ┌───────┴───────┐           │
        │            │               │           │
        ▼            ▼               ▼           ▼
┌───────────────┐ ┌─────────────┐ ┌──────────────┐
│ Backtesting   │ │ Airflow     │ │ KG Builder   │
│ (FastAPI)     │ │ (Pipeline)  │ │ (Neo4j)      │
│ Port: 21011   │ │ Port: 21003 │ │ CLI Tool     │
└───────────────┘ └─────────────┘ └──────────────┘
        │                    │            │
        └────────────────────┼────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        ▼                    ▼                    ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ PostgreSQL    │    │ MongoDB       │    │ Neo4j         │
│ - 사용자 데이터 │    │ - 뉴스/리포트  │    │ - 지식 그래프  │
│ - 백테스트 결과│    │ - 경쟁사 정보  │    │ - 기업 관계    │
└───────────────┘    └───────────────┘    └───────────────┘
```

### 데이터 흐름

```
외부 API (DART, KIS, KRX)
        ↓
┌─────────────────┐
│ Airflow DAGs    │ ← 일일 자동 수집 (00:00, 08:00, 20:10 KST)
│ - 주가 데이터    │
│ - 재무제표       │
│ - 공시 정보      │
│ - 뉴스 크롤링    │
└────────┬────────┘
         ↓
┌─────────────────┐
│ 데이터베이스     │
│ - PostgreSQL    │
│ - MongoDB       │
│ - Neo4j         │
└────────┬────────┘
         ↓
┌─────────────────┐
│ LLM 에이전트     │ ← 사용자 질의 분석
│ - 시장 분석      │
│ - 재무 분석      │
│ - 기술적 분석    │
│ - 투자 전략      │
└────────┬────────┘
         ↓
┌─────────────────┐
│ 의사결정 & 실행  │
│ - 포트폴리오 추천│
│ - 백테스팅       │
│ - 자동매매       │
└────────┬────────┘
         ↓
    Frontend ← 사용자
```

---

## 📁 레포지토리 구조

```
Stockelper-Lab/
├── stockelper-workspace/        # 이 레포지토리 (중앙 워크스페이스)
│   ├── .bmad/                   # BMAD 설정 및 정책
│   ├── docs/                    # 프로젝트 문서
│   ├── scripts/                 # 유틸리티 스크립트
│   └── README.md               # 종합 가이드 (이 파일)
│
├── stockelper-fe/               # 프론트엔드
│   ├── src/app/                # Next.js 15 앱
│   ├── prisma/                 # Prisma ORM 스키마
│   └── README.md
│
├── stockelper-llm/              # LLM 멀티 에이전트
│   ├── src/                    # LangGraph 에이전트
│   ├── legacy/                 # 레거시 코드 보관
│   └── README.md
│
├── stockelper-portfolio/        # 포트폴리오 추천
│   ├── src/                    # LangGraph 워크플로우
│   └── README.md
│
├── stockelper-backtesting/      # 백테스팅 서비스
│   ├── src/                    # FastAPI + Worker
│   ├── migrations/             # DB 마이그레이션
│   └── README.md
│
├── stockelper-airflow/          # 데이터 파이프라인
│   ├── dags/                   # Airflow DAG 정의
│   ├── modules/                # Python 모듈
│   └── README.md
│
├── stockelper-kg/               # 지식 그래프 빌더
│   ├── src/stockelper_kg/      # 데이터 수집 및 그래프 구축
│   └── README.md
│
└── stockelper-news-crawler/     # 뉴스 크롤러
    ├── src/                    # 네이버/토스 크롤러
    └── README.md
```

---

## 🚀 빠른 시작 (전체 시스템 구축)

이 섹션은 Stockelper 전체 시스템을 처음부터 구축하는 종합 가이드입니다.

### 사전 요구사항

#### 시스템 요구사항
- **OS**: Linux, macOS, Windows with WSL2
- **RAM**: 16GB 이상 (32GB 권장)
- **Storage**: 50GB 이상 여유 공간
- **Network**: 안정적인 인터넷 연결

#### 필수 소프트웨어

```bash
# Docker & Docker Compose (24.0+)
docker --version
docker-compose --version

# Python 3.12
python3 --version

# Node.js 20+ & pnpm 9+
node --version
pnpm --version  # 설치: npm install -g pnpm

# uv (Python 패키지 관리자)
curl -LsSf https://astral.sh/uv/install.sh | sh
```

#### 필수 API 키

| 서비스 | 목적 | 등록 URL |
|--------|------|----------|
| **OpenDART** | 금융 공시 데이터 | https://opendart.fss.or.kr/ |
| **KIS OpenAPI** | 주식 거래 | https://apiportal.koreainvestment.com/ |
| **OpenAI** | LLM 추론 (GPT-4/5.1) | https://platform.openai.com/ |
| **OpenRouter** | 뉴스 검색 (Perplexity) | https://openrouter.ai/ |

---

## 📦 서비스별 개요

### 1. Frontend (stockelper-fe)

**Next.js 15 기반 웹 애플리케이션**

#### 기술 스택
- Next.js 15.3, React 19.1, TypeScript 5.8
- Tailwind CSS 4.1, Radix UI
- Prisma ORM 6.6
- TanStack React Query 5.90

#### 주요 기능
- 회원가입 및 로그인 (JWT 인증)
- 투자 성향 설문조사 (8가지 질문)
- AI 채팅 인터페이스 (SSE 스트리밍)
- 백테스팅 요청 및 결과 조회
- 포트폴리오 추천 조회
- KIS API 설정 관리

#### 페이지 구조
```
/sign-in              # 로그인
/sign-up              # 회원가입 (2단계: 계정 정보 + 설문조사)
/dashboard            # 대시보드
/chat                 # AI 채팅
/chat/[id]            # 개별 대화
/analysis             # 분석
/backtesting          # 백테스팅
/portfolio            # 포트폴리오
/settings/account     # 계정 설정
/settings/kis         # KIS API 설정
/settings/survey      # 투자 성향 재평가
```

#### 설치 및 실행
```bash
cd stockelper-fe

# 의존성 설치
pnpm install

# 환경 변수 설정
cp .env.example .env
# DATABASE_URL, JWT_SECRET, LLM_ENDPOINT 설정

# Prisma 설정
pnpm prisma:generate
pnpm prisma:migrate

# 개발 서버 실행
pnpm dev
# → http://localhost:3000

# 프로덕션 빌드 및 실행
pnpm build
pnpm start
```

---

### 2. LLM Service (stockelper-llm)

**LangGraph 기반 다중 에이전트 AI 분석 서비스**

#### 기술 스택
- FastAPI 0.111, LangGraph, LangChain 1.0+
- OpenAI GPT-4/GPT-5.1
- Prophet & ARIMA (주가 예측)
- PostgreSQL, Neo4j, Redis

#### 에이전트 시스템

**SupervisorAgent**: 사용자 질의 라우팅 및 거래 액션 생성

**전문 에이전트 (4개)**:

1. **MarketAnalysisAgent** (시장 분석)
   - 뉴스 검색 (Perplexity API)
   - 리포트 감정 분석
   - YouTube 투자 콘텐츠 분석
   - Neo4j 그래프 QA

2. **FundamentalAnalysisAgent** (기본적 분석)
   - DART 재무제표 분석 (5개년)
   - 재무 건전성 평가 (유동비율, 부채비율, ROE 등)

3. **TechnicalAnalysisAgent** (기술적 분석)
   - KIS API 실시간 주가 조회
   - Prophet + ARIMA 앙상블 예측
   - 차트 패턴 분석 (GPT-4 Vision)

4. **InvestmentStrategyAgent** (투자 전략)
   - KIS 계좌 조회
   - 투자 전략 웹 검색
   - 포트폴리오 제안

#### 설치 및 실행
```bash
cd stockelper-llm

# 의존성 설치
uv sync

# 환경 변수 설정
cp env.example .env
# OPENAI_API_KEY, KIS_BASE_URL, DATABASE_URL 등 설정

# 서버 실행
uv run python src/main.py
# → http://localhost:21009

# Docker 실행
docker-compose up -d
docker-compose logs -f llm-server
```

#### API 엔드포인트
- `POST /stock/chat`: SSE 스트리밍 채팅
- `POST /internal/backtesting/interpret`: 백테스트 결과 해석
- `GET /health`: 헬스 체크

---

### 3. Portfolio Service (stockelper-portfolio)

**LangGraph 기반 포트폴리오 추천 및 자동매매**

#### 기술 스택
- FastAPI, LangGraph
- Black-Litterman 모델
- KIS API, DART API
- PostgreSQL

#### 매수 워크플로우
```
Ranking (11개 지표) → Analysis (병렬 3개) → ViewGenerator
  → PortfolioBuilder → PortfolioTrader
```

**11개 랭킹 지표**:
- 거래 활동성, 영업이익률, 성장률, 부채 수준
- 상승률, 안정성, 순이익, 하락률
- 시가총액, ROE, 유동비율

#### 매도 워크플로우
```
GetHoldings → Analysis (병렬 3개) → SellDecisionMaker
  → PortfolioSeller
```

#### 설치 및 실행
```bash
cd stockelper-portfolio

# 의존성 설치
uv sync --dev

# 환경 변수 설정
cp env.example .env

# 서버 실행
PORT=21008 uv run python src/main.py
# → http://localhost:21008

# Docker 실행
docker-compose up -d
```

#### API 엔드포인트
- `POST /portfolio/recommendations`: 포트폴리오 추천
- `POST /portfolio/buy`: 매수 워크플로우 실행
- `POST /portfolio/sell`: 매도 워크플로우 실행

---

### 4. Backtesting Service (stockelper-backtesting)

**FastAPI 기반 비동기 백테스팅 서비스**

#### 기술 스택
- FastAPI, Backtrader
- PostgreSQL (작업 큐)
- Prophet, ARIMA
- FinanceDataReader, OpenDartReader

#### 아키텍처
```
FastAPI Server → PostgreSQL (작업 큐) → Background Worker
   ↓                                          ↓
placeholder row 생성                    백테스트 실행
                                             ↓
                                      결과 파일 저장 (JSON, MD)
                                             ↓
                                      DB 업데이트 (result_file_path)
                                             ↓
                                      LLM 해석 요청 (선택)
```

#### 설치 및 실행
```bash
cd stockelper-backtesting

# 의존성 설치
uv sync

# 환경 변수 설정
cp env.example .env

# 마이그레이션 실행
psql -U postgres -d stockelper_web -f migrations/001_create_public_backtesting.sql
psql -U postgres -d stockelper_web -f migrations/002_add_backtesting_analysis_columns.sql

# 서버 실행
uv run python src/main.py
# → http://localhost:21011

# 워커 실행 (별도 터미널)
PYTHONPATH=src uv run python -m backtesting.worker

# Docker 실행
docker-compose up -d
docker-compose logs -f backtesting-server
docker-compose logs -f backtest-worker
```

#### API 엔드포인트
- `POST /api/backtesting/execute`: 백테스트 실행 요청
- `GET /api/backtesting/{job_id}/status`: 작업 상태 조회
- `GET /api/backtesting/{job_id}/result`: 백테스트 결과 조회

---

### 5. Airflow (stockelper-airflow)

**Apache Airflow 기반 데이터 오케스트레이션 파이프라인**

#### 기술 스택
- Apache Airflow 2.10.4
- PostgreSQL, MongoDB, Neo4j
- Selenium 4.27+ (웹 스크래핑)
- FinanceDataReader

#### DAG 개요

| DAG | 스케줄 | 설명 |
|-----|--------|------|
| `stock_report_crawler_dag` | 매일 00:00 UTC | 금융 리포트 크롤링 → MongoDB |
| `competitor_crawler_dag` | 매일 00:00 UTC | Wisereport 경쟁사 정보 → MongoDB |
| `stock_to_postgres_dag` | @daily | KRX 일일 주가 → PostgreSQL |
| `dart_disclosure_collection_dag` | 매일 08:00 KST | DART 공시 36개 유형 → PostgreSQL |
| `neo4j_kg_etl_dag` | 매일 20:10 KST | Neo4j 지식 그래프 구축 |
| `neo4j_kg_rebuild_dag` | 수동 트리거 | Neo4j 전체 재구축 |
| `log_cleanup_dag` | 매일 02:00 UTC | 7일 이상 로그 정리 |

#### 설치 및 실행
```bash
cd stockelper-airflow

# 환경 변수 설정
cp .env.example .env

# Docker 네트워크 생성
./scripts/setup_network.sh

# Docker Compose 배포
./scripts/deploy.sh

# Airflow UI 접속
# → http://localhost:21003
# 사용자명: admin, 비밀번호: admin (또는 .env 설정값)

# 로그 확인
docker logs stockelper-airflow
```

---

### 6. Knowledge Graph Builder (stockelper-kg)

**Neo4j 기반 한국 주식 시장 지식 그래프 구축**

#### 기술 스택
- Python 3.12, Neo4j 5.11+
- KRX, KIS, DART, MongoDB 통합
- GPT-4 (이벤트 분류)

#### 데이터 수집기
- **KRXCollector**: 상장 종목 정보
- **KISCollector**: 실시간 주가
- **DartCollector**: 재무제표 (5개년)
- **MongoDBCollector**: 경쟁사 관계
- **EventCollector**: 뉴스/이벤트

#### 그래프 구조

**노드 타입**:
- `Company`: 상장 기업
- `StockPrice`: 일별 주가 스냅샷
- `Date`: 캘린더 날짜
- `Event`: 기업 이벤트
- `Document`: 원본 문서

**관계 타입**:
- `HAS_SNAPSHOT`: Company → StockPrice
- `MENTIONS`: Event → Company
- `COMPETES_WITH`: Company ↔ Company
- `OCCURRED_ON`: Event → Date

#### 설치 및 실행
```bash
cd stockelper-kg

# Neo4j 시작
docker compose up -d
# → http://localhost:21004 (Browser)
# → bolt://localhost:21005 (Bolt)

# 환경 변수 설정
cp .env.example .env

# 의존성 설치
uv sync

# 지식 그래프 구축 (스트리밍 모드 권장)
uv run stockelper-kg --date_st 20250101 --date_fn 20250101 --streaming

# 병렬 처리 (4개 워커)
uv run stockelper-kg --date_st 20250101 --date_fn 20250107 --streaming --max-workers 4

# 기존 그래프에 새 날짜 추가
uv run stockelper-kg --date_st 20250110 --date_fn 20250110 --streaming --update-only

# 뉴스 이벤트 처리
uv run stockelper-kg-events --file data/news_articles/article.txt
uv run stockelper-kg-events --dir data/news_articles
```

#### Cypher 쿼리 예시
```cypher
-- 삼성전자의 2025년 모든 이벤트 조회
MATCH (c:Company {name: '삼성전자'})<-[:MENTIONS]-(e:Event)-[:OCCURRED_ON]->(d:Date)
WHERE d.date >= '20250101' AND d.date <= '20251231'
RETURN e.type, e.description, d.date
ORDER BY d.date DESC

-- 경쟁사 네트워크 조회
MATCH (c:Company {name: '삼성전자'})-[:COMPETES_WITH]-(competitor:Company)
RETURN competitor.name, competitor.code, competitor.market
```

---

### 7. News Crawler (stockelper-news-crawler)

**네이버/토스증권 뉴스 크롤러**

#### 기술 스택
- Python 3.11+
- BeautifulSoup4, Requests
- MongoDB
- Typer (CLI)

#### 크롤러 비교

| 크롤러 | 데이터 소스 | 방식 | 페이지네이션 |
|--------|------------|------|-------------|
| **Naver** | 네이버 증권 | HTML 파싱 | 페이지 단위 |
| **Toss** | 토스증권 | REST API | 커서 기반 |

#### 설치 및 실행
```bash
cd stockelper-news-crawler

# 의존성 설치
uv sync

# 환경 변수 설정
cp env.example .env

# MongoDB 시작 (Docker)
docker run -d -p 27017:27017 --name mongodb mongo:7

# 네이버 크롤러 실행
uv run python -m naver_news_crawler \
  --stock-code 005930 \
  --from-date 2024-01-01

# 토스 크롤러 실행
uv run python -m toss_news_crawler \
  --stock-code 005930 \
  --from-date 2024-01-01 \
  --limit 100
```

---

## 🗄️ 데이터베이스 아키텍처

### PostgreSQL (3개 데이터베이스)

#### 1. stockelper_web
메인 애플리케이션 데이터

**주요 테이블**:
- `users`: 사용자 정보 (KIS API 자격증명 포함)
- `survey`: 투자 성향 설문 답변
- `conversations`: 채팅 대화방
- `chats`: 채팅 메시지
- `portfolio_recommendations`: 포트폴리오 추천 이력
- `backtesting`: 백테스트 작업 및 결과

#### 2. checkpoint
LangGraph 상태 체크포인트

**주요 테이블**:
- `checkpoints`: 에이전트 실행 상태 스냅샷
- `checkpoint_writes`: 체크포인트 쓰기 로그

#### 3. ksic
한국 표준 산업 분류 코드

**주요 테이블**:
- `ksic_codes`: 산업 분류 코드 및 설명

### MongoDB (1개 데이터베이스)

#### stockelper
비정형 데이터 저장소

**주요 컬렉션**:
- `stock_reports`: 금융 리포트
- `competitors`: 경쟁사 정보
- `naver_stock_news`: 네이버 뉴스
- `toss_stock_news`: 토스 뉴스

### Neo4j (1개 데이터베이스)

#### neo4j
지식 그래프

**노드 레이블**:
- `Company`, `StockPrice`, `Date`, `Event`, `Document`

**관계 타입**:
- `HAS_SNAPSHOT`, `MENTIONS`, `COMPETES_WITH`, `OCCURRED_ON`

---

## 🔧 전체 시스템 설정 가이드

### Step 1: 저장소 클론

```bash
# 작업 디렉토리 생성
mkdir -p ~/stockelper-lab
cd ~/stockelper-lab

# Workspace 클론
git clone https://github.com/Stockelper-Lab/stockelper-workspace.git
cd stockelper-workspace

# 모든 서비스 레포 클론 (상위 디렉토리에)
cd ..
git clone https://github.com/Stockelper-Lab/stockelper-fe.git
git clone https://github.com/Stockelper-Lab/stockelper-kg.git
git clone https://github.com/Stockelper-Lab/stockelper-llm.git
git clone https://github.com/Stockelper-Lab/stockelper-airflow.git
git clone https://github.com/Stockelper-Lab/stockelper-portfolio.git
git clone https://github.com/Stockelper-Lab/stockelper-backtesting.git
git clone https://github.com/Stockelper-Lab/stockelper-news-crawler.git

# 디렉토리 구조:
# ~/stockelper-lab/
#   ├── stockelper-workspace/
#   ├── stockelper-fe/
#   ├── stockelper-kg/
#   ├── stockelper-llm/
#   ├── stockelper-airflow/
#   ├── stockelper-portfolio/
#   ├── stockelper-backtesting/
#   └── stockelper-news-crawler/
```

### Step 2: 데이터베이스 설정

```bash
cd ~/stockelper-lab/stockelper-workspace

# docker-compose.databases.yml 생성
cat > docker-compose.databases.yml << 'EOF'
version: '3.8'

networks:
  stockelper:
    driver: bridge

services:
  postgres:
    image: postgres:16-alpine
    container_name: stockelper-postgres
    environment:
      POSTGRES_USER: stockelper
      POSTGRES_PASSWORD: your_secure_password_here
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - stockelper
    restart: unless-stopped

  mongodb:
    image: mongo:7-jammy
    container_name: stockelper-mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: stockelper
      MONGO_INITDB_ROOT_PASSWORD: your_secure_password_here
      MONGO_INITDB_DATABASE: stockelper
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
    networks:
      - stockelper
    restart: unless-stopped

  neo4j:
    image: neo4j:5.11-community
    container_name: stockelper-neo4j
    environment:
      NEO4J_AUTH: neo4j/your_secure_password_here
      NEO4J_PLUGINS: '["apoc"]'
    ports:
      - "7474:7474"
      - "7687:7687"
    volumes:
      - neo4j_data:/data
      - neo4j_logs:/logs
    networks:
      - stockelper
    restart: unless-stopped

volumes:
  postgres_data:
  mongodb_data:
  neo4j_data:
  neo4j_logs:
EOF

# 데이터베이스 시작
docker-compose -f docker-compose.databases.yml up -d

# 데이터베이스 초기화 대기
sleep 30
```

### Step 3: PostgreSQL 데이터베이스 초기화

```bash
# 필수 데이터베이스 생성
docker exec -it stockelper-postgres psql -U stockelper -c "CREATE DATABASE stockelper_web;"
docker exec -it stockelper-postgres psql -U stockelper -c "CREATE DATABASE checkpoint;"
docker exec -it stockelper-postgres psql -U stockelper -c "CREATE DATABASE ksic;"
docker exec -it stockelper-postgres psql -U stockelper -c "CREATE DATABASE airflow;"

# 데이터베이스 확인
docker exec -it stockelper-postgres psql -U stockelper -c "\l"
```

### Step 4: Neo4j 초기화

```bash
# Neo4j 브라우저: http://localhost:7474
# 로그인: neo4j / your_secure_password_here

# 또는 CLI로 제약조건 생성
docker exec -it stockelper-neo4j cypher-shell -u neo4j -p your_secure_password_here << 'EOF'
CREATE CONSTRAINT company_code IF NOT EXISTS FOR (c:Company) REQUIRE c.code IS UNIQUE;
CREATE CONSTRAINT date_value IF NOT EXISTS FOR (d:Date) REQUIRE d.value IS UNIQUE;
CREATE CONSTRAINT event_id IF NOT EXISTS FOR (e:Event) REQUIRE e.id IS UNIQUE;
CREATE INDEX company_name IF NOT EXISTS FOR (c:Company) ON (c.name);
CREATE INDEX event_date IF NOT EXISTS FOR (e:Event) ON (e.date);
EOF
```

### Step 5: 환경 변수 설정

각 서비스별 `.env` 파일 설정:

```bash
cd ~/stockelper-lab

# Frontend
cat > stockelper-fe/.env << 'EOF'
DATABASE_URL=postgresql://stockelper:your_secure_password_here@localhost:5432/stockelper_web
JWT_SECRET=your_super_secret_jwt_key_minimum_32_characters_long
JWT_EXPIRES_IN=7d
COOKIE_NAME=auth-token
LLM_ENDPOINT=http://localhost:21009
NODE_ENV=development
EOF

# LLM Service
cat > stockelper-llm/.env << 'EOF'
# AI Services
OPENAI_API_KEY=sk-your_openai_key_here
OPENROUTER_API_KEY=sk-or-your_openrouter_key_here
OPEN_DART_API_KEY=your_dart_api_key_here

# KIS API
KIS_BASE_URL=https://openapivts.koreainvestment.com:29443

# Databases
DATABASE_URL=postgresql://stockelper:your_secure_password_here@localhost:5432/stockelper_web
ASYNC_DATABASE_URL=postgresql+asyncpg://stockelper:your_secure_password_here@localhost:5432/stockelper_web
CHECKPOINT_DATABASE_URI=postgresql://stockelper:your_secure_password_here@localhost:5432/checkpoint

# Neo4j
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your_secure_password_here
EOF

# Portfolio Service
cat > stockelper-portfolio/.env << 'EOF'
HOST=0.0.0.0
PORT=21008
DATABASE_URL=postgresql://stockelper:your_secure_password_here@localhost:5432/stockelper_web
ASYNC_DATABASE_URL=postgresql+asyncpg://stockelper:your_secure_password_here@localhost:5432/stockelper_web
OPEN_DART_API_KEY=your_dart_api_key_here
OPENROUTER_API_KEY=sk-or-your_openrouter_key_here
EOF

# Backtesting Service
cat > stockelper-backtesting/.env << 'EOF'
DATABASE_URL=postgresql://stockelper:your_secure_password_here@localhost:5432/stockelper_web
HOST=0.0.0.0
PORT=21011
BACKTEST_WORKER_POLL_SECONDS=5
EOF

# Knowledge Graph
cat > stockelper-kg/.env << 'EOF'
OPEN_DART_API_KEY=your_dart_api_key_here
KIS_APP_KEY=your_kis_app_key_here
KIS_APP_SECRET=your_kis_app_secret_here
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your_secure_password_here
DB_URI=mongodb://stockelper:your_secure_password_here@localhost:27017
DB_NAME=stockelper
OPENAI_API_KEY=sk-your_openai_key_here
EOF

# Airflow
cat > stockelper-airflow/.env << 'EOF'
MONGODB_URI=mongodb://stockelper:your_secure_password_here@localhost:27017
MONGO_DATABASE=stockelper
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your_secure_password_here
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql://stockelper:your_secure_password_here@localhost:5432/airflow
OPEN_DART_API_KEY=your_dart_api_key_here
EOF

# News Crawler
cat > stockelper-news-crawler/.env << 'EOF'
MONGODB_URI=mongodb://stockelper:your_secure_password_here@localhost:27017
MONGODB_DATABASE=stockelper
MONGODB_COLLECTION=naver_stock_news
EOF

echo "✅ 모든 .env 파일 생성 완료!"
echo "⚠️  각 .env 파일을 열어 실제 API 키와 비밀번호로 교체하세요."
```

### Step 6: 의존성 설치

```bash
cd ~/stockelper-lab

# Frontend
cd stockelper-fe
pnpm install
pnpm prisma:generate
pnpm prisma:migrate

# LLM Service
cd ../stockelper-llm
uv sync

# Portfolio Service
cd ../stockelper-portfolio
uv sync

# Backtesting Service
cd ../stockelper-backtesting
uv sync

# KG Builder
cd ../stockelper-kg
uv sync

# News Crawler
cd ../stockelper-news-crawler
uv sync

# Airflow
cd ../stockelper-airflow
pip install -r requirements.txt
```

### Step 7: 서비스 시작

#### 터미널 1: Frontend
```bash
cd ~/stockelper-lab/stockelper-fe
pnpm dev
# → http://localhost:3000
```

#### 터미널 2: LLM Service
```bash
cd ~/stockelper-lab/stockelper-llm
uv run python src/main.py
# → http://localhost:21009
```

#### 터미널 3: Portfolio Service
```bash
cd ~/stockelper-lab/stockelper-portfolio
PORT=21008 uv run python src/main.py
# → http://localhost:21008
```

#### 터미널 4: Backtesting Server
```bash
cd ~/stockelper-lab/stockelper-backtesting
uv run python src/main.py
# → http://localhost:21011
```

#### 터미널 5: Backtesting Worker
```bash
cd ~/stockelper-lab/stockelper-backtesting
uv run python src/backtesting/worker.py
```

#### 터미널 6: Airflow
```bash
cd ~/stockelper-lab/stockelper-airflow
export AIRFLOW_HOME=$(pwd)
airflow db init
airflow users create --username admin --password admin --firstname Admin --lastname User --role Admin --email admin@stockelper.local
airflow scheduler &
airflow webserver --port 21003
# → http://localhost:21003
```

### Step 8: 초기 데이터 수집

```bash
# 1. 지식 그래프 구축 (최근 10일)
cd ~/stockelper-lab/stockelper-kg
uv run stockelper-kg --date_st 20250101 --date_fn 20250110 --streaming

# 2. DART 공시 수집
# Airflow UI 접속: http://localhost:21003
# 로그인: admin / admin
# DAG 활성화 및 트리거: dart_disclosure_collection_dag

# 3. 주가 데이터 수집
# DAG 트리거: stock_to_postgres_dag

# 4. 경쟁사 데이터 수집
# DAG 트리거: competitor_crawler_dag
```

---

## 🌐 서비스 URL 및 포트

| 서비스 | URL | 포트 | 인증 정보 |
|--------|-----|------|----------|
| **Frontend** | http://localhost:3000 | 3000 | 회원가입 필요 |
| **LLM API** | http://localhost:21009/docs | 21009 | API 문서 |
| **Portfolio API** | http://localhost:21008/docs | 21008 | API 문서 |
| **Backtesting API** | http://localhost:21011/docs | 21011 | API 문서 |
| **Airflow UI** | http://localhost:21003 | 21003 | admin / admin |
| **Neo4j Browser** | http://localhost:7474 | 7474 | neo4j / password |
| **PostgreSQL** | localhost:5432 | 5432 | stockelper / password |
| **MongoDB** | localhost:27017 | 27017 | stockelper / password |

---

## 🔐 보안 모범 사례

### 1. 환경 변수 관리
```bash
# .env 파일 커밋 금지
echo ".env" >> .gitignore

# 강력한 JWT Secret 생성
openssl rand -base64 32

# 데이터베이스 비밀번호 변경
# 프로덕션에서는 반드시 변경!
```

### 2. API 키 보안
```bash
# KIS API 키는 users 테이블에 저장
# 프로덕션에서는 암호화 권장

# OpenAI, DART API 키는 환경 변수로만 관리
# 절대 코드나 Git에 포함하지 않음
```

### 3. 데이터베이스 접근 제어
```sql
-- PostgreSQL: 사용자별 권한 분리
CREATE USER llm_service WITH PASSWORD 'secure_password';
GRANT SELECT, INSERT, UPDATE ON TABLE chats TO llm_service;

-- 프로덕션에서는 네트워크 격리 또는 VPN 사용
```

### 4. HTTPS 설정 (프로덕션)
```nginx
# Nginx 리버스 프록시 설정 예시
server {
    listen 443 ssl;
    server_name stockelper.yourdomain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api/llm {
        proxy_pass http://localhost:21009;
        proxy_buffering off;  # SSE를 위해 버퍼링 비활성화
    }
}
```

---

## 📊 모니터링 및 디버깅

### 로그 확인

```bash
# 데이터베이스 로그
docker logs stockelper-postgres
docker logs stockelper-mongodb
docker logs stockelper-neo4j

# 서비스 로그 (각 터미널에서)
# 또는 Docker 실행 시
docker-compose logs -f llm-server
docker-compose logs -f portfolio-server
docker-compose logs -f backtesting-server

# Airflow 로그
docker logs stockelper-airflow
```

### 데이터베이스 상태 확인

```bash
# PostgreSQL
docker exec -it stockelper-postgres psql -U stockelper -d stockelper_web -c "SELECT COUNT(*) FROM users;"

# MongoDB
docker exec -it stockelper-mongodb mongosh --eval "db.stock_reports.countDocuments()"

# Neo4j
docker exec -it stockelper-neo4j cypher-shell -u neo4j -p password -c "MATCH (n) RETURN count(n);"
```

### 헬스 체크

```bash
# API 헬스 체크
curl http://localhost:3000/api/health
curl http://localhost:21009/health
curl http://localhost:21008/health
curl http://localhost:21011/health

# Airflow 상태
curl http://localhost:21003/health
```

---

## 🛠️ 문제 해결

### 일반적인 문제

#### 1. 데이터베이스 연결 실패
```bash
# 데이터베이스 상태 확인
docker ps

# 로그 확인
docker logs stockelper-postgres

# 재시작
docker-compose -f docker-compose.databases.yml restart
```

#### 2. 포트 충돌
```bash
# 포트 사용 확인
netstat -tuln | grep 3000
netstat -tuln | grep 5432

# 사용 중인 프로세스 종료
kill -9 $(lsof -t -i:3000)

# 또는 다른 포트로 실행
PORT=3001 pnpm dev
```

#### 3. API 키 오류
```bash
# DART API 키 확인
curl "https://opendart.fss.or.kr/api/company.json?crtfc_key=YOUR_KEY&corp_code=00126380"

# KIS API 토큰 발급
# https://apiportal.koreainvestment.com/
# 앱 등록 → APP Key/Secret 복사
```

#### 4. 메모리 부족
```bash
# Docker 메모리 할당 증가
# Docker Desktop > Settings > Resources > Memory: 8GB → 16GB

# 또는 서비스별 메모리 제한
# docker-compose.yml에서 resources.limits.memory 설정
```

#### 5. Neo4j 쿼리 타임아웃
```cypher
-- 인덱스 확인
CALL db.indexes();

-- 통계 업데이트
CALL apoc.stats.degrees('Company');

-- 쿼리 실행 계획 확인
EXPLAIN MATCH (c:Company) WHERE c.code = '005930' RETURN c;
```

### 서비스별 문제 해결

각 서비스의 README.md 파일에서 상세한 문제 해결 가이드를 참조하세요:
- [Frontend 문제 해결](stockelper-fe/README.md#문제-해결)
- [LLM Service 문제 해결](stockelper-llm/README.md#문제-해결)
- [Portfolio Service 문제 해결](stockelper-portfolio/README.md#문제-해결)
- [Backtesting Service 문제 해결](stockelper-backtesting/README.md#문제-해결)
- [Airflow 문제 해결](stockelper-airflow/README.md#문제-해결)
- [KG Builder 문제 해결](stockelper-kg/README.md#문제-해결)

---

## 📚 추가 문서

### 시스템 다이어그램
- **[시스템 아키텍처 (한국어)](docs/diagrams/system-architecture-ko.md)** - 7개 마이크로서비스 전체 구조
- **[데이터 플로우 (한국어)](docs/diagrams/data-flow-ko.md)** - 5가지 핵심 데이터 흐름
- **[다이어그램 가이드](docs/diagrams/README.md)** - 보는 방법, 편집 가이드

### 서비스별 README
- [stockelper-fe/README.md](stockelper-fe/README.md) - 프론트엔드 상세 가이드
- [stockelper-llm/README.md](stockelper-llm/README.md) - LLM 서비스 상세 가이드
- [stockelper-portfolio/README.md](stockelper-portfolio/README.md) - 포트폴리오 서비스 상세 가이드
- [stockelper-backtesting/README.md](stockelper-backtesting/README.md) - 백테스팅 서비스 상세 가이드
- [stockelper-airflow/README.md](stockelper-airflow/README.md) - Airflow 상세 가이드
- [stockelper-kg/README.md](stockelper-kg/README.md) - 지식 그래프 빌더 상세 가이드
- [stockelper-news-crawler/README.md](stockelper-news-crawler/README.md) - 뉴스 크롤러 상세 가이드

### 개발 가이드
- [CONTRIBUTING.md](CONTRIBUTING.md) - 기여 가이드
- [DEPLOY.md](stockelper-fe/DEPLOY.md) - Frontend 배포 가이드

---

## 🎯 다음 단계

### 1. 계정 생성
1. http://localhost:3000/sign-up 접속
2. 회원가입 양식 작성 (이메일, 비밀번호)
3. 투자 성향 설문조사 완료 (8가지 질문)
4. 대시보드로 자동 리다이렉트

### 2. KIS API 설정
1. Settings → KIS Settings
2. App Key, App Secret, 계좌번호 입력
3. 자동으로 Access Token 발급 및 저장

### 3. AI 채팅 사용
1. Chat 페이지로 이동
2. 새 대화 시작
3. 질문 입력 (예: "삼성전자 분석해줘")
4. 실시간 스트리밍 응답 확인

### 4. 포트폴리오 추천
1. Portfolio 페이지로 이동
2. 포트폴리오 추천 요청
3. AI가 투자 성향에 맞는 포트폴리오 생성
4. 종목별 상세 분석 확인

### 5. 백테스팅
1. Backtesting 페이지로 이동
2. 전략 파라미터 설정
3. 백테스트 실행
4. 성과 분석 및 리포트 확인

---

## 🤝 기여 가이드

### 기여 방법
1. 저장소 포크
2. 기능 브랜치 생성: `git checkout -b feature/my-feature`
3. 변경사항 커밋: `git commit -am 'Add new feature'`
4. 브랜치에 푸시: `git push origin feature/my-feature`
5. Pull Request 생성

### 코딩 스타일
- **Python**: Black, isort, flake8, mypy
- **JavaScript/TypeScript**: ESLint, Prettier
- **커밋 메시지**: Conventional Commits 규칙 준수

### 테스트
```bash
# Python 프로젝트
uv run pytest --cov

# Frontend
pnpm test
```

---

## 📄 라이선스

MIT License

Copyright (c) 2025 Stockelper-Lab

자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

## 👨‍💻 팀

**Stockelper-Lab Team**

- **프론트엔드**: Next.js 15, React 19, Prisma ORM
- **백엔드**: FastAPI, LangGraph, Backtrader
- **AI/ML**: LangChain, OpenAI GPT-4/5.1, Prophet
- **데이터**: Airflow, Neo4j, PostgreSQL, MongoDB
- **인프라**: Docker, GitHub Actions

---

## 📞 문의 및 지원

- **Issues**: GitHub Issues (각 레포지토리)
- **Documentation**: `docs/` 디렉토리
- **Email**: admin@stockelper.com

---

## 🙏 감사의 글

이 프로젝트는 다음 오픈소스 프로젝트들의 도움을 받았습니다:

- [Next.js](https://nextjs.org/) - React 프레임워크
- [FastAPI](https://fastapi.tiangolo.com/) - 웹 프레임워크
- [LangChain](https://www.langchain.com/) & [LangGraph](https://langchain-ai.github.io/langgraph/) - AI 오케스트레이션
- [Apache Airflow](https://airflow.apache.org/) - 워크플로우 관리
- [Neo4j](https://neo4j.com/) - 그래프 데이터베이스
- [PostgreSQL](https://www.postgresql.org/) - 관계형 데이터베이스
- [OpenAI](https://openai.com/) - LLM 모델
- [금융감독원 DART](https://opendart.fss.or.kr/) - 금융 공시 데이터
- [한국투자증권](https://www.koreainvestment.com/) - 증권 API

그리고 Stockelper-Lab 프로젝트에 기여해주신 모든 분들께 감사드립니다.

---

**🚀 Happy Building! 행복한 투자 되세요!**

❤️ Made with love by Stockelper-Lab Team
