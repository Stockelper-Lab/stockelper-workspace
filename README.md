# 📈 Stockelper BMAD Workspace

**AI 기반 주식 투자 도우미 프로젝트**의 중앙 BMAD(Build-Measure-Analyze-Deploy) 워크스페이스입니다.

이 레포는 Stockelper 제품의 **문서, 에이전트 정의, 정책, Blueprint**를 관리하는 "조직의 두뇌" 역할을 합니다.

---

## 🏗️ 아키텍처 개요

```
                         ┌─────────────────────────┐
                         │   stockelper-workspace  │
                         │   (BMAD 중앙 레포)      │
                         │   - 에이전트 정의       │
                         │   - 정책/Blueprint      │
                         │   - 제품 문서           │
                         └───────────┬─────────────┘
                                     │
         ┌───────────────────────────┼───────────────────────────┐
         │                           │                           │
         ▼                           ▼                           ▼
┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐
│ stockelper-fe   │        │ stockelper-llm  │        │ stockelper-kg   │
│ 🌐 Public       │        │ 🌐 Public       │        │ 🌐 Public       │
│ AWS t3.small    │        │ AWS t3.medium   │        │ Local           │
└─────────────────┘        └─────────────────┘        └─────────────────┘

         ┌───────────────────────────┬───────────────────────────┐
         ▼                           ▼                           
┌─────────────────┐        ┌─────────────────┐        
│ stockelper-     │        │ stockelper-     │        
│ airflow         │        │ news-crawler    │        
│ 🌐 Public       │        │ 🔒 Private      │        
│ Local           │        │ Local           │        
└─────────────────┘        └─────────────────┘        
```

---

## 📊 시스템 다이어그램

상세한 아키텍처와 데이터 흐름을 시각화한 Mermaid 다이어그램을 확인하세요:

- **[시스템 아키텍처 (한국어)](docs/diagrams/system-architecture-ko.md)** | **[English](docs/diagrams/system-architecture.md)** - 7개 마이크로서비스, 3개 데이터베이스, 외부 API 통합 전체 구조
- **[데이터 플로우 (한국어)](docs/diagrams/data-flow-ko.md)** | **[English](docs/diagrams/data-flow.md)** - 5가지 핵심 데이터 흐름 (DART 수집, 채팅, 포트폴리오, 백테스팅, 실시간 알림)
- **[다이어그램 가이드](docs/diagrams/README.md)** - 다이어그램 보는 방법, 편집 가이드, 트러블슈팅

**렌더링 지원**:
- GitHub/GitLab 마크다운 프리뷰 (자동)
- VS Code (Mermaid 확장 설치)
- [Mermaid Live Editor](https://mermaid.live/)

---

## 📁 디렉터리 구조

```
stockelper-workspace/
├── .bmad/                      # BMAD 코어 설정
│   ├── agents/                 # 에이전트 정의
│   │   ├── analyst.md          # 요구사항 분석
│   │   ├── pm.md               # 제품 관리
│   │   ├── architect.md        # 아키텍처 설계
│   │   ├── dev.md              # 개발
│   │   └── qa.md               # 품질 보증
│   ├── policies/
│   │   └── org.yaml            # 조직 공통 정책
│   ├── profiles/
│   │   └── default.yaml        # 기본 프로필
│   ├── blueprints/             # 서비스별 Blueprint
│   ├── templates/              # 문서 템플릿
│   │   ├── prd.md
│   │   ├── story.md
│   │   └── epic.md
│   └── workspace.yaml          # 워크스페이스 설정
├── docs/                       # 제품 문서
│   ├── prd/                    # PRD 문서
│   ├── architecture/           # 아키텍처 문서
│   └── epics/                  # 에픽/스토리
├── sources/                    # 서비스 레포 (심볼릭 링크, .gitignore)
│   ├── airflow/
│   ├── fe/
│   ├── kg/
│   ├── llm/
│   └── news-crawler/
├── scripts/
│   └── setup-sources.sh        # 소스 링크 설정 스크립트
├── .gitignore
├── README.md
└── CONTRIBUTING.md
```

---

## 🚀 시작하기

### 1. 이 워크스페이스 Clone

```bash
git clone https://github.com/Stockelper-Lab/stockelper-workspace.git
cd stockelper-workspace
```

### 2. 서비스 레포 Clone (상위 디렉터리에)

```bash
cd ..

# Public 레포들
git clone https://github.com/Stockelper-Lab/stockelper-airflow.git
git clone https://github.com/Stockelper-Lab/stockelper-fe.git
git clone https://github.com/Stockelper-Lab/stockelper-kg.git
git clone https://github.com/Stockelper-Lab/stockelper-llm.git

# Private 레포 (권한 필요)
git clone git@github.com:Stockelper-Lab/stockelper-news-crawler.git
```

### 3. Sources 심볼릭 링크 설정

```bash
cd stockelper-workspace
./scripts/setup-sources.sh
```

---

## 📋 서비스 개요

| 서비스 | 설명 | 기술 스택 | 배포 환경 |
|--------|------|-----------|-----------|
| **airflow** | 배치/파이프라인/스케줄링 | Python, Airflow, Docker | Local |
| **fe** | 웹 프론트엔드 | Next.js, TypeScript, Prisma | AWS t3.small |
| **kg** | Knowledge Graph | Python, Neo4j | Local |
| **llm** | LLM 멀티에이전트 | Python, LangGraph, FastAPI | AWS t3.medium |
| **news-crawler** | 뉴스 크롤링 🔒 | Python | Local |

---

## 🤖 BMAD 워크플로

### Plan (계획)

```bash
# 전체 제품 수준 계획
bmad plan

# 서비스별 계획
bmad plan --service kg
bmad plan --service llm
bmad plan --service fe
```

### Build (구현)

```bash
# Blueprint 기반 구현
bmad build --blueprint .bmad/blueprints/kg.json
```

### Verify (검증)

```bash
# Blueprint 기반 검증
bmad verify --blueprint .bmad/blueprints/kg.json
```

---

## 📝 문서 관리

### PRD 작성

```bash
# 템플릿 복사
cp .bmad/templates/prd.md docs/prd/PRD-001-feature-name.md

# 작성 후 PR
```

### Epic/Story 작성

```bash
# Epic 생성
cp .bmad/templates/epic.md docs/epics/EPIC-001-feature.md

# Story 생성
cp .bmad/templates/story.md docs/epics/STORY-001-task.md
```

---

## 🔗 관련 링크

- [stockelper-airflow](https://github.com/Stockelper-Lab/stockelper-airflow) - Airflow DAG
- [stockelper-fe](https://github.com/Stockelper-Lab/stockelper-fe) - Frontend
- [stockelper-kg](https://github.com/Stockelper-Lab/stockelper-kg) - Knowledge Graph
- [stockelper-llm](https://github.com/Stockelper-Lab/stockelper-llm) - LLM Service
- stockelper-news-crawler (🔒 Private) - News Crawler

---

## 🤝 기여 방법

[CONTRIBUTING.md](./CONTRIBUTING.md)를 참조하세요.

---

## 📜 라이선스

이 프로젝트는 PseudoLab Stockelper 팀에서 관리합니다.

---

# 🌍 Complete Setup Guide for Building Stockelper from Scratch

This section provides comprehensive instructions for setting up and running the entire Stockelper system in your own environment.

## System Overview

Stockelper is an AI-powered investment platform for the Korean stock market, consisting of 7 microservices:

| Service | Purpose | Technology | Port |
|---------|---------|-----------|------|
| **Frontend** | Web UI & Authentication | Next.js 15, React 19 | 3000 |
| **LLM Service** | Multi-agent AI analysis | FastAPI, LangGraph, GPT-5.1 | 21009 |
| **Portfolio Service** | Portfolio optimization | FastAPI, Black-Litterman | 21008 |
| **Backtesting Service** | Strategy validation | FastAPI, Worker Queue | 21011 |
| **Airflow** | Data pipeline orchestration | Apache Airflow 2.10 | 21003 |
| **KG Builder** | Knowledge graph construction | Python, Neo4j | CLI |
| **News Crawler** | News aggregation | Python, BeautifulSoup | CLI |

### Database Architecture

- **PostgreSQL**: Users, conversations, DART disclosures, stock prices, backtesting results
- **MongoDB**: News articles, financial reports, competitor data
- **Neo4j**: Company relationships, events, market patterns

## Prerequisites

### System Requirements

- **OS**: Linux, macOS, or Windows with WSL2
- **RAM**: 16GB minimum (32GB recommended)
- **Storage**: 50GB free space
- **Network**: Stable internet connection

### Software Requirements

Install the following before proceeding:

1. **Docker** 24.0+ & Docker Compose 2.20+
   ```bash
   # Verify installation
   docker --version
   docker-compose --version
   ```

2. **Python** 3.11+ (3.12 recommended)
   ```bash
   python3 --version
   ```

3. **Node.js** 20+ & pnpm 9+
   ```bash
   node --version
   pnpm --version  # Install: npm install -g pnpm
   ```

4. **uv** (Python package manager)
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

### API Keys Required

Create accounts and obtain API keys from these services:

| Service | Purpose | Registration URL |
|---------|---------|-----------------|
| **OpenDART** | Korean financial disclosures | https://opendart.fss.or.kr/ |
| **KIS OpenAPI** | Korean stock trading | https://apiportal.koreainvestment.com/ |
| **OpenAI** | LLM inference (GPT-5.1) | https://platform.openai.com/ |
| **OpenRouter** | Alternative LLM (Perplexity) | https://openrouter.ai/ |
| **YouTube API** (optional) | Content analysis | https://console.cloud.google.com/ |

## Step-by-Step Setup

### Step 1: Clone All Repositories

```bash
# Create workspace directory
mkdir -p ~/stockelper-lab
cd ~/stockelper-lab

# Clone workspace (this repo)
git clone https://github.com/Stockelper-Lab/stockelper-workspace.git
cd stockelper-workspace

# Clone all service repositories (run from parent directory)
cd ..
git clone https://github.com/Stockelper-Lab/stockelper-fe.git
git clone https://github.com/Stockelper-Lab/stockelper-kg.git
git clone https://github.com/Stockelper-Lab/stockelper-llm.git
git clone https://github.com/Stockelper-Lab/stockelper-airflow.git
git clone https://github.com/Stockelper-Lab/stockelper-portfolio.git
git clone https://github.com/Stockelper-Lab/stockelper-backtesting.git
git clone https://github.com/Stockelper-Lab/stockelper-news-crawler.git

# Your directory structure should look like:
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

### Step 2: Set Up Databases

Create a `docker-compose.databases.yml` file in the workspace directory:

```bash
cd ~/stockelper-lab/stockelper-workspace
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
    command: >
      postgres
      -c max_connections=200

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
      NEO4J_dbms_security_procedures_unrestricted: apoc.*
    ports:
      - "7474:7474"  # HTTP
      - "7687:7687"  # Bolt
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

# Start databases
docker-compose -f docker-compose.databases.yml up -d

# Wait for databases to be ready
echo "Waiting for databases to initialize..."
sleep 30
```

### Step 3: Initialize PostgreSQL Databases

```bash
# Create required databases
docker exec -it stockelper-postgres psql -U stockelper -c "CREATE DATABASE stockelper_web;"
docker exec -it stockelper-postgres psql -U stockelper -c "CREATE DATABASE checkpoint;"
docker exec -it stockelper-postgres psql -U stockelper -c "CREATE DATABASE ksic;"
docker exec -it stockelper-postgres psql -U stockelper -c "CREATE DATABASE airflow;"

# Verify databases
docker exec -it stockelper-postgres psql -U stockelper -c "\l"
```

### Step 4: Initialize Neo4j

```bash
# Access Neo4j Browser at http://localhost:7474
# Login with: neo4j / your_secure_password_here

# Or run via CLI:
docker exec -it stockelper-neo4j cypher-shell -u neo4j -p your_secure_password_here << 'EOF'
// Create constraints
CREATE CONSTRAINT company_code IF NOT EXISTS FOR (c:Company) REQUIRE c.code IS UNIQUE;
CREATE CONSTRAINT date_value IF NOT EXISTS FOR (d:Date) REQUIRE d.value IS UNIQUE;
CREATE CONSTRAINT event_id IF NOT EXISTS FOR (e:Event) REQUIRE e.id IS UNIQUE;

// Create indexes
CREATE INDEX company_name IF NOT EXISTS FOR (c:Company) ON (c.name);
CREATE INDEX event_date IF NOT EXISTS FOR (e:Event) ON (e.date);
EOF
```

### Step 5: Configure Environment Variables

Each service needs its own `.env` file. Here's a script to set them all up:

```bash
cd ~/stockelper-lab

# Frontend (.env)
cat > stockelper-fe/.env << 'EOF'
DATABASE_URL=postgresql://stockelper:your_secure_password_here@localhost:5432/stockelper_web
JWT_SECRET=your_super_secret_jwt_key_minimum_32_characters_long
JWT_EXPIRES_IN=7d
COOKIE_NAME=auth-token
LLM_ENDPOINT=http://localhost:21009
NODE_ENV=development
EOF

# LLM Service (.env)
cat > stockelper-llm/.env << 'EOF'
# AI Services
OPENAI_API_KEY=sk-your_openai_key_here
OPENROUTER_API_KEY=sk-or-your_openrouter_key_here
OPEN_DART_API_KEY=your_dart_api_key_here
YOUTUBE_API_KEY=your_youtube_key_here

# KIS API Base Config
KIS_BASE_URL=https://openapivts.koreainvestment.com:29443

# Databases
DATABASE_URL=postgresql://stockelper:your_secure_password_here@localhost:5432/stockelper_web
ASYNC_DATABASE_URL=postgresql+asyncpg://stockelper:your_secure_password_here@localhost:5432/stockelper_web
CHECKPOINT_DATABASE_URI=postgresql://stockelper:your_secure_password_here@localhost:5432/checkpoint
ASYNC_DATABASE_URL_KSIC=postgresql+asyncpg://stockelper:your_secure_password_here@localhost:5432/ksic

# Neo4j
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your_secure_password_here

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
EOF

# Portfolio Service (.env)
cat > stockelper-portfolio/.env << 'EOF'
HOST=0.0.0.0
PORT=21008
DEBUG=false

DATABASE_URL=postgresql://stockelper:your_secure_password_here@localhost:5432/stockelper_web
ASYNC_DATABASE_URL=postgresql+asyncpg://stockelper:your_secure_password_here@localhost:5432/stockelper_web
STOCKELPER_WEB_SCHEMA=public
ASYNC_DATABASE_URL_KSIC=postgresql+asyncpg://stockelper:your_secure_password_here@localhost:5432/ksic

OPEN_DART_API_KEY=your_dart_api_key_here
OPENROUTER_API_KEY=sk-or-your_openrouter_key_here

KIS_MAX_REQUESTS_PER_SECOND=20
KIS_ANALYSIS_MAX_REQUESTS_PER_SECOND=1
EOF

# Backtesting Service (.env)
cat > stockelper-backtesting/.env << 'EOF'
DATABASE_URL=postgresql://stockelper:your_secure_password_here@localhost:5432/stockelper_web
STOCKELPER_WEB_SCHEMA=public
STOCKELPER_BACKTESTING_TABLE=backtesting

DB_USER=stockelper
DB_PASSWORD=your_secure_password_here
DB_HOST=localhost
DB_PORT=5432
DB_NAME=postgres

HOST=0.0.0.0
PORT=21011
DEBUG=false
BACKTEST_WORKER_POLL_SECONDS=5
BACKTEST_RESULTS_DIR=outputs/backtesting_results
EOF

# Knowledge Graph Builder (.env)
cat > stockelper-kg/.env << 'EOF'
OPEN_DART_API_KEY=your_dart_api_key_here
KIS_APP_KEY=your_kis_app_key_here
KIS_APP_SECRET=your_kis_app_secret_here

NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your_secure_password_here

DB_URI=mongodb://stockelper:your_secure_password_here@localhost:27017
DB_NAME=stockelper
DB_COLLECTION_NAME=competitors

OPENAI_API_KEY=sk-your_openai_key_here
EOF

# Airflow (.env)
cat > stockelper-airflow/.env << 'EOF'
MONGODB_URI=mongodb://stockelper:your_secure_password_here@localhost:27017
MONGO_DATABASE=stockelper

AIRFLOW_SECRET_KEY=$(openssl rand -hex 32)
AIRFLOW_ADMIN_USERNAME=admin
AIRFLOW_ADMIN_PASSWORD=admin_password_change_in_production
AIRFLOW_ADMIN_EMAIL=admin@stockelper.local

NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your_secure_password_here

AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql://stockelper:your_secure_password_here@localhost:5432/airflow

OPEN_DART_API_KEY=your_dart_api_key_here
DART36_LOOKBACK_DAYS=30
DART36_SLEEP_SECONDS=0.2
DART36_TIMEOUT_SECONDS=30
DART36_MAX_RETRIES=3

STOCK_PRICE_EOD_CUTOFF_HOUR=18
EOF

# News Crawler (.env)
cat > stockelper-news-crawler/.env << 'EOF'
MONGODB_URI=mongodb://stockelper:your_secure_password_here@localhost:27017
MONGODB_DATABASE=stockelper
MONGODB_COLLECTION=naver_stock_news

CRAWLER_PAGE_SIZE=20
CRAWLER_REQUEST_TIMEOUT=10.0
CRAWLER_SLEEP_SECONDS=0.2
EOF

echo "✅ All .env files created! IMPORTANT: Replace placeholder values with your actual credentials."
```

**⚠️ IMPORTANT**: Edit each `.env` file and replace:
- `your_secure_password_here` with your chosen database password
- `your_openai_key_here` with your OpenAI API key
- `your_dart_api_key_here` with your DART API key
- `your_kis_app_key_here` and `your_kis_app_secret_here` with your KIS credentials
- Other placeholder values as needed

### Step 6: Install Dependencies

```bash
# Frontend
cd ~/stockelper-lab/stockelper-fe
pnpm install
pnpm prisma:generate
pnpm prisma:migrate

# LLM Service
cd ~/stockelper-lab/stockelper-llm
uv sync

# Portfolio Service
cd ~/stockelper-lab/stockelper-portfolio
uv sync

# Backtesting Service
cd ~/stockelper-lab/stockelper-backtesting
uv sync

# KG Builder
cd ~/stockelper-lab/stockelper-kg
uv sync

# News Crawler
cd ~/stockelper-lab/stockelper-news-crawler
uv sync

# Airflow
cd ~/stockelper-lab/stockelper-airflow
pip install -r requirements.txt
```

### Step 7: Start Services

Open multiple terminal windows or use tmux/screen:

```bash
# Terminal 1: Frontend
cd ~/stockelper-lab/stockelper-fe
pnpm dev
# Access at: http://localhost:3000

# Terminal 2: LLM Service
cd ~/stockelper-lab/stockelper-llm
uv run python src/main.py
# Access at: http://localhost:21009

# Terminal 3: Portfolio Service
cd ~/stockelper-lab/stockelper-portfolio
PORT=21008 uv run python src/main.py
# Access at: http://localhost:21008

# Terminal 4: Backtesting Service
cd ~/stockelper-lab/stockelper-backtesting
uv run python src/main.py
# Terminal 5 (optional): Backtesting Worker
cd ~/stockelper-lab/stockelper-backtesting
uv run python src/backtesting/worker.py
# Access at: http://localhost:21011

# Terminal 6: Airflow
cd ~/stockelper-lab/stockelper-airflow
export AIRFLOW_HOME=$(pwd)
airflow db init
airflow users create --username admin --password admin --firstname Admin --lastname User --role Admin --email admin@stockelper.local
airflow scheduler &
airflow webserver --port 21003
# Access at: http://localhost:21003
```

### Step 8: Initialize Data

Once services are running:

```bash
# 1. Build initial knowledge graph
cd ~/stockelper-lab/stockelper-kg
# Start with recent data (last 10 days)
uv run stockelper-kg --date_st 20250101 --date_fn 20250110 --streaming

# 2. Collect DART disclosures
# Access Airflow UI: http://localhost:21003
# Login: admin / admin
# Enable and trigger DAG: dart_disclosure_collection_dag

# 3. Collect stock prices
# Trigger DAG: stock_to_postgres_dag

# 4. Collect competitor data
# Trigger DAG: competitor_crawler_dag
```

## Using the System

### 1. Create an Account

1. Navigate to http://localhost:3000/sign-up
2. Complete registration form with email and password
3. Complete investment profile survey (8 questions)
4. You'll be redirected to the dashboard

### 2. Configure KIS API Credentials

1. Go to Settings → KIS Settings
2. Enter your KIS credentials:
   - App Key
   - App Secret
   - Account Number
3. System will automatically fetch and store access token

### 3. Start Using AI Chat

1. Navigate to Chat page
2. Start a new conversation
3. Ask questions in Korean:
   - "삼성전자 분석해줘" (Analyze Samsung Electronics)
   - "AI 섹터 투자 전략 추천해줘" (Recommend AI sector strategy)
   - "포트폴리오 최적화해줘" (Optimize my portfolio)

### 4. Request Portfolio Recommendations

The system provides Black-Litterman optimized portfolio recommendations:
- Uses your investment profile
- Analyzes market conditions
- Provides diversified stock selections

### 5. Run Backtests

Test investment strategies with historical data:
- Select strategy parameters
- Review performance metrics
- Analyze Sharpe ratios and returns

## Service URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | Sign up via UI |
| LLM API | http://localhost:21009/docs | API docs |
| Portfolio API | http://localhost:21008/docs | API docs |
| Backtesting API | http://localhost:21011/docs | API docs |
| Airflow UI | http://localhost:21003 | admin / admin |
| Neo4j Browser | http://localhost:7474 | neo4j / password |

## Troubleshooting

### Database Connection Issues

```bash
# Check if databases are running
docker ps

# View logs
docker logs stockelper-postgres
docker logs stockelper-mongodb
docker logs stockelper-neo4j

# Restart if needed
docker-compose -f docker-compose.databases.yml restart
```

### Service Won't Start

```bash
# Check port availability
netstat -tuln | grep <PORT>

# View service logs for errors
# Check terminal output where service was started

# Verify environment variables are set correctly
cat .env
```

### Missing Dependencies

```bash
# Python services
cd <service-directory>
uv sync --reinstall

# Frontend
cd stockelper-fe
pnpm install --force
```

### Neo4j Query Timeout

```cypher
// Check database size
MATCH (n) RETURN count(n);

// Verify indexes exist
CALL db.indexes();

// Check constraints
SHOW CONSTRAINTS;
```

## Data Pipeline Operations

### Manual Data Collection

```bash
# Update knowledge graph
cd ~/stockelper-lab/stockelper-kg
uv run stockelper-kg --date_st YYYYMMDD --date_fn YYYYMMDD --streaming --update-only

# Crawl news for specific stock
cd ~/stockelper-lab/stockelper-news-crawler
uv run python -m naver_news_crawler --stock-code 005930 --from-date 2025-01-01

# Collect DART data
# Use Airflow UI to trigger: dart_disclosure_collection_dag
```

### Automated Schedule

Airflow DAGs run automatically:
- **00:00 KST**: Financial reports, competitor data
- **08:00 KST**: DART disclosures
- **20:10 KST**: Knowledge graph updates
- **Daily**: Stock price updates

## Security Reminders

1. **Never commit `.env` files** - They contain sensitive credentials
2. **Change default passwords** - Especially for production deployments
3. **Use strong JWT secrets** - Minimum 32 characters
4. **Enable HTTPS** - Use reverse proxy (nginx, Caddy) in production
5. **Restrict database access** - Bind to localhost or use VPN
6. **Rotate API keys** - Regularly update external service credentials

## Next Steps

- **View system diagrams**: [System Architecture](docs/diagrams/system-architecture.md) and [Data Flow](docs/diagrams/data-flow.md)
- Explore individual service READMEs in `sources/*/README.md`
- Read the architecture document: `docs/architecture.md`
- Check the PRD: `docs/prd.md`
- Join discussions in GitHub Issues
- Contribute improvements via Pull Requests

## Support

- **Issues**: GitHub Issues in respective repositories
- **Documentation**: `docs/` directory in workspace
- **Service Docs**: Each service has detailed README with API documentation

---

**Happy Building! 🚀**
