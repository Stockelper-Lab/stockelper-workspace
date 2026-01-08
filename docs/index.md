# Stockelper Project Documentation Index

**Last Updated:** 2026-01-07
**Documentation Type:** Multi-part Brownfield Project

---

## Project Overview

- **Project Name:** Stockelper
- **Type:** Multi-part workspace (7 microservices)
- **Primary Languages:** TypeScript (Frontend) + Python (Backend)
- **Architecture:** Microservices with AI/ML capabilities
- **Domain:** Korean Stock Market Analysis Platform

---

## Quick Reference

### Frontend (fe)
- **Type:** Web Application
- **Tech Stack:** Next.js 15.3, React 19, TypeScript 5.8, Tailwind CSS
- **Database:** PostgreSQL (Prisma ORM)
- **Port:** 80 (production)
- **Root:** `sources/fe/`

### Data Pipeline (airflow)
- **Type:** ETL Pipeline Orchestration
- **Tech Stack:** Apache Airflow 2.10, Python
- **Databases:** MongoDB, PostgreSQL, Neo4j
- **Port:** 21003 (Web UI)
- **Root:** `sources/airflow/`

### LLM Service (llm)
- **Type:** Multi-Agent AI Analysis Service
- **Tech Stack:** FastAPI, LangGraph, Python 3.12+
- **Databases:** PostgreSQL, MongoDB, Neo4j
- **Port:** 21009 (API)
- **Root:** `sources/llm/`

### Knowledge Graph (kg)
- **Type:** Graph Database Builder
- **Tech Stack:** Python 3.12, Neo4j, OpenAI
- **Databases:** Neo4j, MongoDB
- **Port:** 21004 (HTTP), 21005 (Bolt)
- **Root:** `sources/kg/`

### News Crawler (news-crawler)
- **Type:** Data Collection
- **Tech Stack:** Python 3.11+, BeautifulSoup, requests
- **Database:** MongoDB
- **Root:** `sources/news-crawler/`

### Portfolio Service (portfolio)
- **Type:** Portfolio Recommendation & Trading
- **Tech Stack:** FastAPI, LangGraph, Black-Litterman
- **Databases:** PostgreSQL
- **Port:** 21008 (API)
- **Root:** `sources/portfolio/`

### Backtesting Service (backtesting)
- **Type:** Strategy Backtesting Engine
- **Tech Stack:** FastAPI, Prophet, ARIMA
- **Databases:** PostgreSQL
- **Port:** 21007 (API)
- **Root:** `sources/backtesting/`

---

## Core Documentation

### Project Planning & Design
- [PRD (Product Requirements Document)](./prd.md) - Complete functional and non-functional requirements
- [Architecture](./architecture.md) - System architecture, technology decisions, data flows
- [Epics & Stories](./epics.md) - Implementation roadmap with detailed stories
- [UX Design Specification](./ux-design-specification.md) - User experience design
- [Project Context](./project_context.md) - AI agent context document

### Technical Analysis
- [Source Tree Analysis](./source-tree-analysis.md) - Directory structure overview
- [Project Overview](./project-overview.md) - Executive summary
- [DART Implementation Analysis](./DART-implementation-analysis.md) - DART disclosure integration
- [DART Disclosure Ingestion](./dart-disclosure-ingestion.md) - Event extraction specification

### Status & Reports
- [Implementation Readiness Report](./implementation-readiness-report-2026-01-04.md) - Current readiness assessment
- [Documentation Update Summary](./DOCUMENTATION-UPDATE-SUMMARY-2026-01-06.md) - Latest documentation status
- [Test Design System](./test-design-system.md) - Testing strategy

---

## Service-Specific Documentation

### Frontend (fe)
- [README](../sources/fe/README.md) - Frontend overview and setup

### Data Pipeline (airflow)
- [README](../sources/airflow/README.md) - Airflow overview
- [Architecture](../sources/airflow/docs/ARCHITECTURE.md) - System architecture
- [API Reference](../sources/airflow/docs/API_REFERENCE.md) - API documentation
- [Quick Start](../sources/airflow/docs/QUICKSTART.md) - Getting started
- [Development](../sources/airflow/docs/DEVELOPMENT.md) - Development guide

### LLM Service (llm)
- [README](../sources/llm/README.md) - LLM service overview
- [AGENTS](../sources/llm/AGENTS.md) - AI agents documentation
- [LangGraph Structure](../sources/llm/docs/Langgraph_Structure.md) - Multi-agent system
- [KIS OpenAPI](../sources/llm/docs/API_KIS-OpenAPI.md) - Korean trading API integration

### Knowledge Graph (kg)
- [README](../sources/kg/README.md) - Knowledge graph overview
- [Streaming Mode](../sources/kg/docs/STREAMING_MODE.md) - Streaming capabilities

### News Crawler (news-crawler)
- [README](../sources/news-crawler/README.md) - Crawler overview (Naver + Toss)

### Portfolio Service (portfolio)
- [README](../sources/portfolio/README.md) - Portfolio service overview

### Backtesting Service (backtesting)
- [README](../sources/backtesting/README.md) - Backtesting service overview

---

## Reference Documentation

Domain and planning documents:

- [References Directory](./references/) - Meeting notes and domain documentation
- [DART Main Events](./references/DART(main events).md) - Korean financial disclosure system events
- [Knowledge Graph Data Collection Planning](./references/knowledge-graph-data-collection-planning.md) - Comprehensive KG strategy
- [Portfolio Recommendation & User Investment Preferences](./references/portfolio-rec-user-investment-pref.md) - Investment preference modeling

---

## Key Integration Points

1. **Frontend <-> LLM Service**
   - SSE streaming for real-time chat responses
   - User authentication and session management

2. **Frontend <-> Portfolio/Backtesting Services**
   - Async job submission and results polling
   - Recommendation and backtest result display

3. **LLM Service <-> Knowledge Graph**
   - Neo4j queries for entity relationships
   - GraphQA tool for subgraph retrieval

4. **Airflow -> All Services**
   - Orchestrates data collection and processing
   - Triggers knowledge graph updates
   - Daily stock price and DART disclosure collection

5. **News Crawler -> MongoDB -> Airflow**
   - Dual crawler pipeline (Naver + Toss)
   - Data enrichment and event extraction

6. **Shared Databases**
   - PostgreSQL: User data, backtest results, portfolio recommendations
   - MongoDB: News articles, stock reports, competitors
   - Neo4j: Knowledge graph entities and relationships

---

## Development Workflow

### Local Development
1. **Frontend:** `cd sources/fe && pnpm dev`
2. **LLM Service:** `cd sources/llm && uv run uvicorn src.main:app --port 21009`
3. **Portfolio:** `cd sources/portfolio && uv run uvicorn src.main:app --port 21008`
4. **Backtesting:** `cd sources/backtesting && uv run uvicorn src.main:app --port 21007`
5. **Airflow:** `docker-compose up` in airflow directory
6. **KG Builder:** `cd sources/kg && uv run stockelper-kg --streaming`
7. **News Crawler:** `cd sources/news-crawler && uv run python -m naver_news_crawler`

### Package Management
- **Python Services:** `uv` (primary), `pip` fallback
- **Frontend:** `pnpm`

### Testing
- **Frontend:** TypeScript type checking, Jest
- **Python Services:** pytest with coverage
- **E2E:** Playwright

---

## Getting Started

### For New Features
1. Review [PRD](./prd.md) for requirements context
2. Check [Architecture](./architecture.md) for system design
3. Review [Epics & Stories](./epics.md) for implementation roadmap
4. Reference [Project Context](./project_context.md) for AI agent context

### For Development
1. Clone workspace repository
2. See individual service READMEs for setup instructions
3. Use `uv` for Python dependency management
4. Use `pnpm` for frontend dependency management

### For Architecture Understanding
1. Start with [Project Overview](./project-overview.md)
2. Review [Architecture](./architecture.md) for detailed design
3. Check [Source Tree Analysis](./source-tree-analysis.md) for code organization

---

**Maintained By:** Stockelper Team
