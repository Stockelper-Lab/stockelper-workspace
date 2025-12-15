# Stockelper Source Tree Analysis

**Generated:** 2025-12-08
**Project Type:** Multi-part workspace

## Project Root Structure

```
stockelper-workspace/
├── sources/                    # Symlinked service repositories
│   ├── fe/                    # Frontend (Next.js web app)
│   ├── airflow/               # Data pipeline (Apache Airflow)
│   ├── llm/                   # LLM service (FastAPI + LangGraph)
│   ├── kg/                    # Knowledge graph builder (Neo4j)
│   └── news-crawler/          # News scraper (MongoDB)
├── docs/                      # Project documentation
│   ├── references/            # Domain and planning documents
│   ├── prd/                   # Product requirements (to be created)
│   ├── architecture/          # Architecture docs (to be created)
│   ├── epics/                 # User stories (to be created)
│   └── sprint-artifacts/      # Sprint tracking
├── scripts/                   # Setup and utility scripts
└── .bmad/                     # BMAD workflow configuration
```

## Part 1: Frontend (fe)

```
sources/fe/
├── src/
│   ├── app/                          # Next.js app directory (pages + API routes)
│   │   ├── (no-layout)/             # Pages without main layout
│   │   │   ├── sign-in/             # Sign-in page
│   │   │   └── sign-up/             # Sign-up page with survey
│   │   │       ├── components/      # Sign-up specific components
│   │   │       │   ├── user-form/   # User registration form
│   │   │       │   ├── survey/      # Investment survey
│   │   │       │   └── ui/          # UI components
│   │   ├── api/                     # Next.js API routes (backend endpoints)
│   │   │   ├── auth/                # Authentication endpoints
│   │   │   │   ├── register/        # User registration
│   │   │   │   ├── logout/          # Logout
│   │   │   │   └── me/              # Current user info
│   │   │   └── settings/            # Settings endpoints
│   │   │       ├── kis/             # KIS API configuration
│   │   │       └── account/         # Account settings
│   ├── components/                   # Reusable React components
│   ├── hooks/                        # Custom React hooks
│   ├── lib/                          # Utility libraries
│   ├── generated/prisma/            # Prisma generated types
│   └── middleware.ts                 # Next.js middleware (auth, routing)
├── prisma/                           # Database schema and migrations
│   └── schema.prisma                 # Prisma schema for PostgreSQL
├── package.json                      # Dependencies and scripts
├── next.config.ts                    # Next.js configuration
├── tsconfig.json                     # TypeScript configuration
├── tailwind.config.ts               # Tailwind CSS configuration
├── components.json                   # shadcn/ui component config
└── README.md                         # Frontend documentation

Key Technologies:
- Next.js 15.3 (App Router)
- React 19.1 with TypeScript
- Prisma ORM (PostgreSQL)
- Radix UI + Tailwind CSS
- JWT authentication
```

## Part 2: Data Pipeline (airflow)

```
sources/airflow/
├── dags/                             # Airflow DAG definitions
│   └── [data orchestration workflows]
├── modules/                          # Reusable Python modules
│   └── [ETL logic, connectors]
├── config/                           # Airflow configuration
├── docs/                             # Comprehensive documentation
│   ├── ARCHITECTURE.md               # System architecture
│   ├── API_REFERENCE.md              # API documentation
│   ├── QUICKSTART.md                 # Getting started guide
│   ├── DEVELOPMENT.md                # Development guide
│   ├── LOG_MANAGEMENT.md             # Logging guide
│   ├── TROUBLESHOOTING.md            # Troubleshooting tips
│   └── ADMIN_USER_SETUP.md           # Admin configuration
├── scripts/                          # Utility scripts
├── requirements.txt                  # Python dependencies
├── docker-compose.yml                # Docker setup
├── Dockerfile                        # Container definition
├── DEPLOYMENT.md                     # Deployment guide
├── SCRIPTS_UPDATE.md                 # Scripts documentation
└── README.md                         # Main documentation

Key Technologies:
- Apache Airflow 2.10.4
- MongoDB, PostgreSQL, Neo4j connectors
- Selenium + BeautifulSoup (web scraping)
- finance-datareader (Korean market data)
- Pandas + NumPy (data processing)
```

## Part 3: LLM Service (llm)

```
sources/llm/
├── src/                              # Source code
│   └── [FastAPI app, LangGraph agents]
├── docs/                             # Technical documentation
│   ├── API_Architecture_Analysis.md  # API architecture
│   ├── API_KIS-OpenAPI.md            # KIS API integration
│   ├── Langgraph_Structure.md        # LangGraph structure
│   ├── Function_Definition.md        # Function specs
│   └── Functional_Specification.md   # Functional requirements
├── pyproject.toml                    # Project configuration
├── requirements.txt                  # Python dependencies
├── docker-compose.yml                # Docker setup (local/cloud)
├── cloud.docker-compose.yml          # Cloud-specific config
├── local.docker-compose.yml          # Local development config
├── AGENTS.md                         # AI agents documentation
├── pre-commit-guide.md               # Development practices
└── README.md                         # Main documentation

Key Technologies:
- FastAPI 0.111.0
- LangGraph + LangChain (multi-agent AI)
- OpenAI API
- PostgreSQL (SQLAlchemy + asyncpg)
- MongoDB (pymongo + motor)
- Neo4j (langchain-neo4j)
- Langfuse (monitoring)
- Prophet (forecasting)
- finance-datareader, opendartreader, mojito2
```

## Part 4: Knowledge Graph (kg)

```
sources/kg/
├── src/                              # Source code
│   └── stockelper_kg/                # Main package
│       └── cli.py                    # CLI entry point
├── docs/                             # Documentation
│   └── STREAMING_MODE.md             # Streaming mode guide
├── tests/                            # Test suite
├── examples/                         # Usage examples
├── scripts/                          # Utility scripts
├── pyproject.toml                    # Project configuration
├── requirements.txt                  # Python dependencies
├── uv.lock                           # UV lock file
├── docker-compose.yml                # Docker setup
├── Dockerfile                        # Container definition
├── entrypoint.sh                     # Container entry point
└── README.md                         # Main documentation

Key Technologies:
- Python 3.12
- Neo4j 5.11+ (graph database)
- MongoDB (document storage)
- OpenDartReader (financial data)
- finance-datareader (market data)
- OpenAI (embeddings)
- scikit-learn (ML utilities)
```

## Part 5: News Crawler (news-crawler)

```
sources/news-crawler/
├── src/                              # Source code
│   └── [crawler modules]
├── tests/                            # Test suite
├── scripts/                          # Utility scripts
├── pyproject.toml                    # Project configuration
├── uv.lock                           # UV lock file
├── env.example                       # Environment template
└── README.md                         # Main documentation

Key Technologies:
- Python 3.11+
- Requests + BeautifulSoup4 (web scraping)
- MongoDB (pymongo)
- Typer (CLI framework)
- pytest (testing)
```

## Critical Directories by Function

### User Interface
- `sources/fe/src/app/` - Next.js pages and routes
- `sources/fe/src/components/` - Reusable UI components

### API Endpoints
- `sources/fe/src/app/api/` - Next.js API routes
- `sources/llm/src/` - FastAPI endpoints

### Data Processing
- `sources/airflow/dags/` - Data pipeline workflows
- `sources/airflow/modules/` - ETL logic

### AI/ML
- `sources/llm/src/` - LangGraph multi-agent system

### Data Collection
- `sources/news-crawler/src/` - News scraping logic
- `sources/kg/src/` - Knowledge graph construction

### Database Schemas
- `sources/fe/prisma/schema.prisma` - User/app data schema
- `sources/kg/src/` - Neo4j graph schema

### Configuration
- `sources/*/docker-compose.yml` - Docker configurations
- `sources/*/.env` - Environment variables
- `sources/*/requirements.txt` or `package.json` - Dependencies

### Documentation
- `sources/*/docs/` - Part-specific technical docs
- `docs/references/` - Business domain documents

## Entry Points

### Development
- **Frontend:** `npm run dev` (Next.js dev server)
- **LLM Service:** `uvicorn` (FastAPI server)
- **Airflow:** `docker-compose up` (Airflow webserver + scheduler)
- **KG Builder:** `stockelper-kg` CLI command
- **News Crawler:** Python scripts

### Production
- **All services:** Docker containers via docker-compose

## Integration Architecture

The services integrate through:

1. **Database Sharing:**
   - PostgreSQL: Frontend (users) ↔ LLM Service (checkpoints)
   - MongoDB: News Crawler → Airflow → LLM Service
   - Neo4j: KG Builder → Airflow → LLM Service

2. **API Calls:**
   - Frontend → LLM Service (REST API)
   - LLM Service → Neo4j (graph queries)

3. **Data Pipeline:**
   - Airflow orchestrates: News Crawler → MongoDB → KG Builder → Neo4j

## Development Workflow

1. **Frontend Development:** Next.js hot reload at `localhost:3000`
2. **Backend Development:** FastAPI auto-reload at `localhost:8000`
3. **Data Pipeline:** Airflow UI at `localhost:8080`
4. **Database Access:** PostgreSQL, MongoDB, Neo4j via clients
5. **Testing:** pytest for Python, Jest for TypeScript (if configured)
