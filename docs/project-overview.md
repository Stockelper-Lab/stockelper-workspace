# Stockelper Project Overview

**Generated:** 2025-12-08
**Scan Level:** Deep
**Project Type:** Multi-part AI/ML Stock Analysis Platform

## Executive Summary

Stockelper is a comprehensive AI-powered stock investment assistant platform for the Korean stock market. The system combines multiple microservices to provide intelligent stock analysis, portfolio recommendations, and real-time financial data processing through a modern web interface.

## Project Structure

**Repository Type:** Multi-part workspace with symlinked repositories
**Total Parts:** 7 independent services (Backtesting/Portfolio services added)
**Primary Technologies:** TypeScript (Frontend) + Python (Backend Services)
**Architecture Pattern:** Microservices with shared data layer

## Parts Overview

### 1. Frontend (fe)
- **Type:** Web Application
- **Framework:** Next.js 15.3 (React 19)
- **Language:** TypeScript 5.8
- **Purpose:** User-facing web application for stock analysis and portfolio management
- **Path:** `sources/fe/`

### 2. Data Pipeline (airflow)
- **Type:** Data Engineering
- **Framework:** Apache Airflow 2.10
- **Language:** Python
- **Purpose:** Orchestrate data collection, processing, and knowledge graph updates
- **Path:** `sources/airflow/`

### 3. LLM Service (llm)
- **Type:** AI Backend Service
- **Framework:** FastAPI + LangGraph
- **Language:** Python 3.12+
- **Purpose:** Multi-agent AI system for stock analysis and investment recommendations
- **Path:** `sources/llm/`

### 4. Knowledge Graph (kg)
- **Type:** Graph Database Builder
- **Framework:** Python CLI
- **Language:** Python 3.12
- **Purpose:** Build and maintain Neo4j knowledge graph of Korean stock market entities
- **Path:** `sources/kg/`

### 5. News Crawler (news-crawler)
- **Type:** Data Collection Service
- **Framework:** Python CLI (Typer)
- **Language:** Python 3.11+
- **Purpose:** Scrape Korean financial news from Naver and store in MongoDB
- **Path:** `sources/news-crawler/`

### 6. Backtesting Service (backtesting)
- **Type:** Backend Service (separate container)
- **Framework:** FastAPI (planned)
- **Language:** Python 3.12+
- **Purpose:** Execute backtesting jobs asynchronously and persist results for frontend consumption
- **Deployment:** Local (initial phase)
- **Repository split plan:** `../stockelper-backtesting/` (separate repo)

### 7. Portfolio Service (portfolio)
- **Type:** Backend Service (separate container)
- **Framework:** FastAPI (planned)
- **Language:** Python 3.12+
- **Purpose:** Generate portfolio recommendations (button-triggered from dedicated page) and persist results for frontend consumption
- **Deployment:** Local (initial phase)
- **Repository split plan:** `../stockelper-portfolio/` (separate repo)

## Technology Stack Summary

| Part | Primary Tech | Framework/Runtime | Database(s) |
|------|--------------|-------------------|-------------|
| Frontend | TypeScript | Next.js 15.3, React 19 | PostgreSQL (Prisma) |
| Airflow | Python | Apache Airflow 2.10 | MongoDB, PostgreSQL, Neo4j |
| LLM Service | Python 3.12+ | FastAPI, LangGraph | PostgreSQL, MongoDB, Neo4j |
| Knowledge Graph | Python 3.12 | CLI | Neo4j, MongoDB |
| News Crawler | Python 3.11+ | Typer CLI | MongoDB |
| Backtesting Service | Python 3.12+ | FastAPI | PostgreSQL (remote, schema `"stockelper-fe"`) |
| Portfolio Service | Python 3.12+ | FastAPI | PostgreSQL (remote, schema `"stockelper-fe"`) |

## Architecture Type

**Microservices Architecture** with:
- **Frontend Layer:** Next.js SSR/SSG application
- **API Layer:** FastAPI-based LLM service
- **Data Orchestration:** Apache Airflow DAGs
- **Data Storage:** PostgreSQL (relational), MongoDB (documents), Neo4j (graph)
- **AI/ML:** LangGraph multi-agent system with RAG capabilities

## Key Features

- **AI-Powered Analysis:** Multi-agent LLM system using LangGraph
- **Knowledge Graph:** Neo4j-based Korean stock market knowledge base
- **Real-time Data:** Integration with Korean financial APIs (DART, KIS, Mojito)
- **Data Pipeline:** Automated ETL with Airflow
- **Modern UI:** Next.js with Tailwind CSS and Radix UI
- **User Management:** JWT authentication with Prisma ORM

## Domain Context

- **Market:** Korean Stock Market (KOSPI/KOSDAQ)
- **Data Sources:** DART (financial disclosures), Naver Finance (news), KIS OpenAPI (trading)
- **Use Cases:** Stock analysis, portfolio recommendations, financial news aggregation
- **Target Users:** Korean retail investors

## Integration Points

1. **Frontend ↔ LLM Service:** REST API calls for AI analysis
2. **Frontend ↔ Portfolio Service:** Dedicated portfolio recommendation page triggers backend job and reads accumulated history
3. **Frontend ↔ Backtesting Service:** Dedicated backtesting results page triggers jobs and reads job/status/result
4. **LLM Service ↔ Knowledge Graph:** Neo4j queries for entity relationships
5. **Airflow ↔ All Services:** Data pipeline triggers and updates
6. **News Crawler → MongoDB:** Financial news storage
7. **Knowledge Graph Builder → Neo4j:** Graph construction and updates

## Deployment Notes (Updated 2025-12-30)

- **`stockelper-llm-server`** is built and deployed on **AWS EC2**, using `stockelper-llm/cloud.docker-compose.yml` as the source of truth.
- **`stockelper-backtesting-server`** and **`stockelper-portfolio-server`** are built and run **locally** (initial phase).
- Backtesting/Portfolio results are persisted into a **remote PostgreSQL** schema **`"stockelper-fe"`** (credentials must be injected via env/secret manager; do not commit secrets).

## Getting Started

See individual part documentation:
- [Frontend Documentation](../sources/fe/README.md)
- [Airflow Documentation](../sources/airflow/README.md)
- [LLM Service Documentation](../sources/llm/README.md)
- [Knowledge Graph Documentation](../sources/kg/README.md)
- [News Crawler Documentation](../sources/news-crawler/README.md)

## Reference Documentation

Additional planning and domain documents:
- [DART Main Events](./references/DART(main events).md) - Korean financial disclosure events
- [Knowledge Graph Planning](./references/knowledge-graph-data-collection-planning.md) - Detailed KG strategy
- [Portfolio Recommendations](./references/portfolio-rec-user-investment-pref.md) - Investment preference model

## Documentation Status

✅ **Existing Documentation:** 29+ files across all parts
✅ **Architecture Docs:** Available for Airflow, LLM Service
✅ **API Docs:** Available for Airflow, LLM Service
✅ **Domain Planning:** Comprehensive reference documents

## Next Steps for Development

1. **For New Features:** Review relevant part documentation and architecture
2. **For PRD Creation:** Reference this overview + part-specific architecture docs
3. **For Integration:** See integration architecture documentation
4. **For Development:** Follow individual part development guides
