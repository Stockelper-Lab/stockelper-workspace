# Stockelper Source Tree Analysis

**Last Updated:** 2026-01-07
**Project Type:** Multi-part workspace (7 microservices)

## Project Root Structure

```
stockelper-workspace/
├── sources/                    # Symlinked service repositories
│   ├── fe/                    # Frontend (Next.js web app)
│   ├── airflow/               # Data pipeline (Apache Airflow)
│   ├── llm/                   # LLM service (FastAPI + LangGraph)
│   ├── kg/                    # Knowledge graph builder (Neo4j)
│   ├── news-crawler/          # News scraper (MongoDB)
│   ├── portfolio/             # Portfolio service (LangGraph + Black-Litterman)
│   └── backtesting/           # Backtesting service (Prophet + ARIMA)
├── docs/                      # Project documentation
│   ├── references/            # Domain and planning documents
│   └── sprint-artifacts/      # Sprint tracking
├── scripts/                   # Setup and utility scripts
└── .bmad/                     # BMAD workflow configuration
```

## Part 1: Frontend (fe)

```
sources/fe/
├── src/
│   ├── app/                          # Next.js app directory (pages + API routes)
│   │   ├── (has-layout)/             # Pages with main layout
│   │   │   └── chat/                 # Chat interface
│   │   ├── (no-layout)/              # Pages without main layout
│   │   │   ├── login/                # Login page
│   │   │   └── signup/               # Sign-up page with survey
│   │   │       └── components/       # Sign-up specific components
│   │   │           ├── survey/       # Investment survey
│   │   │           └── ui/           # UI components
│   │   └── api/                      # Next.js API routes
│   │       ├── auth/                 # Authentication endpoints
│   │       └── settings/             # Settings endpoints
│   ├── components/                   # Reusable React components
│   │   ├── chat/                     # Chat interface components
│   │   ├── survey/                   # Investment survey components
│   │   ├── common/                   # Shared components
│   │   └── ui/                       # Reusable UI elements (shadcn/ui)
│   ├── hooks/                        # Custom React hooks
│   ├── lib/api/                      # API client helpers
│   └── styles/                       # Tailwind config
├── prisma/                           # Database schema and migrations
│   └── schema.prisma                 # Prisma schema for PostgreSQL
├── package.json                      # Dependencies and scripts
├── next.config.ts                    # Next.js configuration
├── tsconfig.json                     # TypeScript configuration
├── tailwind.config.ts                # Tailwind CSS configuration
├── components.json                   # shadcn/ui component config
└── README.md                         # Frontend documentation

Key Technologies:
- Next.js 15.3 (App Router)
- React 19 with TypeScript 5.8
- Prisma ORM (PostgreSQL)
- Tailwind CSS 4.1 + Radix UI + shadcn/ui
- TanStack React Query 5.90
- JWT authentication (bcryptjs)
- XYFlow/ReactFlow (graph visualization)
```

## Part 2: Data Pipeline (airflow)

```
sources/airflow/
├── dags/                             # Airflow DAG definitions
│   ├── stock_report_crawler_dag.py   # Financial report crawling
│   ├── competitor_crawler_dag.py     # Competitor info crawling
│   ├── stock_to_postgres_dag.py      # KRX stock prices to PostgreSQL
│   ├── dart_disclosure_collection_dag.py       # DART disclosure collection
│   ├── dart_disclosure_collection_backfill_dag.py  # Historical DART backfill
│   ├── neo4j_kg_etl_dag.py           # Neo4j knowledge graph ETL
│   ├── neo4j_kg_rebuild_dag.py       # Full KG rebuild
│   └── log_cleanup_dag.py            # Airflow log cleanup
├── modules/                          # Reusable Python modules
│   ├── common/                       # Shared logging, DB connections, settings
│   ├── api/                          # REST API integrations
│   ├── report_crawler/               # Selenium-based crawler
│   ├── company_crawler/              # Wisereport crawler
│   ├── dart_disclosure/              # DART API integration
│   ├── postgres/                     # PostgreSQL connectors
│   ├── neo4j/                        # Neo4j operators
│   └── stock_price/                  # Stock price ETL
├── config/                           # Airflow configuration
├── docs/                             # Comprehensive documentation
│   ├── ARCHITECTURE.md               # System architecture
│   ├── API_REFERENCE.md              # API documentation
│   ├── QUICKSTART.md                 # Getting started guide
│   ├── DEVELOPMENT.md                # Development guide
│   └── TROUBLESHOOTING.md            # Troubleshooting tips
├── scripts/                          # Utility scripts
├── requirements.txt                  # Python dependencies
├── docker-compose.yml                # Docker setup (includes MongoDB)
├── Dockerfile                        # Container definition
└── README.md                         # Main documentation

Key Technologies:
- Apache Airflow 2.10
- MongoDB, PostgreSQL, Neo4j connectors
- Selenium + BeautifulSoup (web scraping)
- finance-datareader (Korean market data)
- OpenDartReader (DART API)
- Pandas + NumPy (data processing)
```

## Part 3: LLM Service (llm)

```
sources/llm/
├── src/
│   ├── multi_agent/                  # LangGraph multi-agent system
│   │   ├── base/                     # Base agent classes
│   │   ├── supervisor_agent/         # Router agent
│   │   ├── market_analysis_agent/    # News/research agent
│   │   ├── fundamental_analysis_agent/   # Financial analysis agent
│   │   ├── technical_analysis_agent/     # Price/chart analysis agent
│   │   └── investment_strategy_agent/    # Strategy agent
│   ├── routers/                      # FastAPI endpoints
│   └── frontend/                     # Optional Streamlit UI
├── docs/                             # Technical documentation
│   ├── API_Architecture_Analysis.md  # API architecture
│   ├── API_KIS-OpenAPI.md            # KIS API integration
│   ├── Langgraph_Structure.md        # LangGraph structure
│   ├── Function_Definition.md        # Function specs
│   └── Functional_Specification.md   # Functional requirements
├── pyproject.toml                    # Project configuration
├── docker-compose.yml                # Docker setup
├── AGENTS.md                         # AI agents documentation
└── README.md                         # Main documentation

Key Technologies:
- FastAPI 0.111
- LangGraph + LangChain 1.0+ (multi-agent AI)
- OpenAI GPT-4o
- PostgreSQL (SQLAlchemy + asyncpg)
- MongoDB (pymongo + motor)
- Neo4j (langchain-neo4j)
- Langfuse (observability)
- Prophet + ARIMA (forecasting)
- KIS OpenAPI (trading)
```

## Part 4: Knowledge Graph (kg)

```
sources/kg/
├── src/
│   └── stockelper_kg/                # Main package
│       ├── collectors/               # Data collectors
│       │   ├── krx.py                # KRX listed companies
│       │   ├── kis.py                # Korea Investment & Securities API
│       │   ├── dart.py               # DART financial statements
│       │   ├── dart_major_reports.py # DART major disclosure types
│       │   ├── mongodb.py            # Competitor data
│       │   ├── event.py              # Multi-source event collection
│       │   ├── streaming_orchestrator.py  # Streaming mode controller
│       │   └── orchestrator.py       # Batch mode controller
│       └── graph/                    # Graph building
│           ├── builder.py            # Main graph builder
│           ├── ontology.py           # Event classification
│           ├── schema.py             # Neo4j constraints & indexes
│           ├── cypher.py             # Cypher query generator
│           └── queries.py            # Pre-built graph queries
├── docs/                             # Documentation
│   └── STREAMING_MODE.md             # Streaming mode guide
├── tests/                            # Test suite
├── pyproject.toml                    # Project configuration
├── docker-compose.yml                # Docker setup
└── README.md                         # Main documentation

Key Technologies:
- Python 3.12
- Neo4j 5.11+ (graph database)
- MongoDB (document storage)
- OpenDartReader (financial data)
- finance-datareader (market data)
- OpenAI (embeddings, event classification)
```

## Part 5: News Crawler (news-crawler)

```
sources/news-crawler/
├── src/
│   ├── naver_news_crawler/           # Naver mobile API crawler
│   │   ├── naver_client.py           # API communication
│   │   ├── crawler.py                # Crawling logic
│   │   ├── article_parser.py         # HTML/content extraction
│   │   ├── storage.py                # MongoDB persistence
│   │   ├── models.py                 # Data models
│   │   └── cli.py                    # Command-line interface
│   └── toss_news_crawler/            # Toss RESTful API crawler
│       └── [same structure]
├── tests/                            # Test suite
├── pyproject.toml                    # Project configuration
├── uv.lock                           # UV lock file
└── README.md                         # Main documentation

Key Technologies:
- Python 3.11+
- Requests + BeautifulSoup4 (web scraping)
- MongoDB (pymongo)
- Typer (CLI framework)
- pytest (testing)
```

## Part 6: Portfolio Service (portfolio)

```
sources/portfolio/
├── src/
│   ├── multi_agent/                  # Base agent classes
│   ├── portfolio_multi_agent/        # Portfolio-specific agents
│   │   └── nodes/                    # LangGraph workflow nodes
│   │       ├── load_user_context.py  # User context loading
│   │       ├── ranking.py            # 11-factor stock ranking
│   │       ├── analysis.py           # Parallel 3-way analysis
│   │       ├── view_generator.py     # Black-Litterman views
│   │       ├── portfolio_builder.py  # Portfolio optimization
│   │       ├── portfolio_trader.py   # KIS order execution
│   │       └── sell_decision.py      # Sell workflow decision
│   ├── routers/                      # FastAPI endpoints
│   └── observability/                # LangFuse integration
├── pyproject.toml                    # Project configuration
├── docker-compose.yml                # Docker setup
└── README.md                         # Main documentation

Key Technologies:
- FastAPI
- LangGraph (Buy/Sell workflows)
- Black-Litterman model (portfolio optimization)
- SciPy SLSQP (optimization)
- KIS OpenAPI (trading)
- PostgreSQL (recommendations storage)
```

## Part 7: Backtesting Service (backtesting)

```
sources/backtesting/
├── src/
│   ├── routers/                      # FastAPI endpoints
│   │   └── backtesting.py            # Job submission API
│   ├── backtesting/                  # Core backtesting logic
│   │   ├── worker.py                 # Async job execution
│   │   └── job_queue.py              # In-memory job management
│   ├── persistence/                  # Database layer
│   │   ├── db.py                     # Database connection
│   │   └── schema.py                 # PostgreSQL models
│   └── notifications/                # Notification service
│       └── service.py                # Result notifications
├── pyproject.toml                    # Project configuration
├── docker-compose.yml                # Docker setup
└── README.md                         # Main documentation

Key Technologies:
- FastAPI, Uvicorn
- LangGraph, LangChain
- Prophet, ARIMA (time-series forecasting)
- SQLAlchemy 2.0+, asyncpg, psycopg
- NumPy, Pandas, Plotly
- OpenAI, Langfuse
```

## Critical Directories by Function

### User Interface
- `sources/fe/src/app/` - Next.js pages and routes
- `sources/fe/src/components/` - Reusable UI components

### API Endpoints
- `sources/fe/src/app/api/` - Next.js API routes (auth, settings)
- `sources/llm/src/routers/` - LLM chat API (SSE streaming)
- `sources/portfolio/src/routers/` - Portfolio recommendation API
- `sources/backtesting/src/routers/` - Backtesting job API

### Data Processing
- `sources/airflow/dags/` - Data pipeline workflows
- `sources/airflow/modules/` - ETL logic

### AI/ML
- `sources/llm/src/multi_agent/` - LangGraph multi-agent system (5 agents)
- `sources/portfolio/src/portfolio_multi_agent/` - Portfolio workflows

### Data Collection
- `sources/news-crawler/src/` - News scraping (Naver + Toss)
- `sources/kg/src/stockelper_kg/collectors/` - KRX, KIS, DART collectors

### Database Schemas
- `sources/fe/prisma/schema.prisma` - User/app data schema
- `sources/kg/src/stockelper_kg/graph/schema.py` - Neo4j graph schema
- `sources/backtesting/src/persistence/schema.py` - Backtesting job schema

### Configuration
- `sources/*/docker-compose.yml` - Docker configurations
- `sources/*/.env` - Environment variables
- `sources/*/pyproject.toml` or `package.json` - Dependencies

### Documentation
- `sources/*/docs/` - Part-specific technical docs
- `docs/references/` - Business domain documents

## Entry Points

### Development
- **Frontend:** `pnpm dev` (Next.js dev server, port 3000)
- **LLM Service:** `uv run uvicorn src.main:app --port 21009`
- **Portfolio:** `uv run uvicorn src.main:app --port 21008`
- **Backtesting:** `uv run uvicorn src.main:app --port 21007`
- **Airflow:** `docker-compose up` (Web UI port 21003)
- **KG Builder:** `uv run stockelper-kg --streaming`
- **News Crawler:** `uv run python -m naver_news_crawler`

### Production
- All services: Docker containers via docker-compose
- Bridge network: `stockelper`

## Integration Architecture

The services integrate through:

1. **Database Sharing:**
   - PostgreSQL: Frontend (users) ↔ LLM/Portfolio/Backtesting (jobs, results)
   - MongoDB: News Crawler → Airflow → LLM Service
   - Neo4j: KG Builder → Airflow → LLM Service (GraphQA)

2. **API Calls:**
   - Frontend → LLM Service (SSE streaming chat)
   - Frontend → Portfolio Service (recommendations)
   - Frontend → Backtesting Service (strategy validation)
   - LLM/Portfolio/Backtesting → Neo4j (graph queries)
   - Portfolio/Backtesting → KIS API (trading operations)

3. **Data Pipeline:**
   - Airflow orchestrates: News Crawler → MongoDB → KG Builder → Neo4j
   - Daily: Stock prices (KRX) → PostgreSQL
   - Daily: DART disclosures → PostgreSQL → Event extraction

## Service Ports

| Service | Port | Description |
|---------|------|-------------|
| Frontend | 80 (prod) / 3000 (dev) | Next.js web app |
| Airflow | 21003 | Web UI |
| KG | 21004 (HTTP), 21005 (Bolt) | Neo4j |
| Backtesting | 21007 | FastAPI |
| Portfolio | 21008 | FastAPI |
| LLM | 21009 | FastAPI |
