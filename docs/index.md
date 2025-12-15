# Stockelper Project Documentation Index

**Generated:** 2025-12-08
**Documentation Type:** Multi-part Brownfield Project
**Scan Level:** Deep

---

## Project Overview

- **Project Name:** Stockelper
- **Type:** Multi-part workspace (5 services)
- **Primary Languages:** TypeScript (Frontend) + Python (Backend)
- **Architecture:** Microservices with AI/ML capabilities
- **Domain:** Korean Stock Market Analysis Platform

---

## Quick Reference

### Frontend (fe)
- **Type:** Web Application
- **Tech Stack:** Next.js 15.3, React 19, TypeScript 5.8
- **Database:** PostgreSQL (Prisma ORM)
- **Root:** `sources/fe/`

### Data Pipeline (airflow)
- **Type:** Data Engineering
- **Tech Stack:** Apache Airflow 2.10, Python
- **Databases:** MongoDB, PostgreSQL, Neo4j
- **Root:** `sources/airflow/`

### LLM Service (llm)
- **Type:** AI Backend Service
- **Tech Stack:** FastAPI, LangGraph, Python 3.12+
- **Databases:** PostgreSQL, MongoDB, Neo4j
- **Root:** `sources/llm/`

### Knowledge Graph (kg)
- **Type:** Graph Database Builder
- **Tech Stack:** Python 3.12, Neo4j, OpenAI
- **Databases:** Neo4j, MongoDB
- **Root:** `sources/kg/`

### News Crawler (news-crawler)
- **Type:** Data Collection
- **Tech Stack:** Python 3.11+, Typer CLI
- **Database:** MongoDB
- **Root:** `sources/news-crawler/`

---

## Generated Documentation

### Core Documentation
- [Project Overview](./project-overview.md) - Executive summary and architecture overview
- [Source Tree Analysis](./source-tree-analysis.md) - Complete directory structure with annotations
- [Integration Architecture](./integration-architecture.md) _(To be generated)_ - How services communicate
- [Technology Stack Details](./technology-stack.md) _(To be generated)_ - Comprehensive tech analysis

### Part-Specific Documentation

#### Frontend (fe)
- [Architecture - Frontend](./architecture-fe.md) _(To be generated)_
- [API Routes - Frontend](./api-routes-fe.md) _(To be generated)_
- [Component Inventory - Frontend](./component-inventory-fe.md) _(To be generated)_
- [Data Models - Frontend](./data-models-fe.md) _(To be generated)_
- [Development Guide - Frontend](./development-guide-fe.md) _(To be generated)_

#### Data Pipeline (airflow)
- [Architecture - Airflow](./architecture-airflow.md) _(To be generated)_
- [DAGs Documentation](./dags-airflow.md) _(To be generated)_
- [Data Models - Airflow](./data-models-airflow.md) _(To be generated)_
- [Development Guide - Airflow](./development-guide-airflow.md) _(To be generated)_

#### LLM Service (llm)
- [Architecture - LLM](./architecture-llm.md) _(To be generated)_
- [API Contracts - LLM](./api-contracts-llm.md) _(To be generated)_
- [Agent System](./agent-system-llm.md) _(To be generated)_
- [Data Models - LLM](./data-models-llm.md) _(To be generated)_
- [Development Guide - LLM](./development-guide-llm.md) _(To be generated)_

#### Knowledge Graph (kg)
- [Architecture - KG](./architecture-kg.md) _(To be generated)_
- [Graph Schema](./graph-schema-kg.md) _(To be generated)_
- [Development Guide - KG](./development-guide-kg.md) _(To be generated)_

#### News Crawler (news-crawler)
- [Architecture - Crawler](./architecture-crawler.md) _(To be generated)_
- [Development Guide - Crawler](./development-guide-crawler.md) _(To be generated)_

---

## Existing Documentation

### Frontend (fe)
- [README](../sources/fe/README.md) - Frontend overview and setup

### Data Pipeline (airflow)
- [README](../sources/airflow/README.md) - Airflow overview
- [DEPLOYMENT](../sources/airflow/DEPLOYMENT.md) - Deployment guide
- [SCRIPTS_UPDATE](../sources/airflow/SCRIPTS_UPDATE.md) - Scripts documentation
- [Architecture](../sources/airflow/docs/ARCHITECTURE.md) - System architecture
- [API Reference](../sources/airflow/docs/API_REFERENCE.md) - API documentation
- [Quick Start](../sources/airflow/docs/QUICKSTART.md) - Getting started
- [Development](../sources/airflow/docs/DEVELOPMENT.md) - Development guide
- [Log Management](../sources/airflow/docs/LOG_MANAGEMENT.md) - Logging guide
- [Logging Guide](../sources/airflow/docs/LOGGING_GUIDE.md) - Logging best practices
- [Troubleshooting](../sources/airflow/docs/TROUBLESHOOTING.md) - Common issues
- [Admin Setup](../sources/airflow/docs/ADMIN_USER_SETUP.md) - Admin configuration
- [Docker Compose Changes](../sources/airflow/docs/DOCKER_COMPOSE_CHANGES.md) - Docker updates

### LLM Service (llm)
- [README](../sources/llm/README.md) - LLM service overview
- [AGENTS](../sources/llm/AGENTS.md) - AI agents documentation
- [Pre-commit Guide](../sources/llm/pre-commit-guide.md) - Development practices
- [API Architecture Analysis](../sources/llm/docs/API_Architecture_Analysis.md) - API design
- [KIS OpenAPI](../sources/llm/docs/API_KIS-OpenAPI.md) - Korean trading API integration
- [LangGraph Structure](../sources/llm/docs/Langgraph_Structure.md) - Multi-agent system
- [Function Definition](../sources/llm/docs/Function_Definition.md) - Function specs
- [Functional Specification](../sources/llm/docs/Functional_Specification.md) - Requirements

### Knowledge Graph (kg)
- [README](../sources/kg/README.md) - Knowledge graph overview
- [Streaming Mode](../sources/kg/docs/STREAMING_MODE.md) - Streaming capabilities

### News Crawler (news-crawler)
- [README](../sources/news-crawler/README.md) - Crawler overview

---

## Reference Documentation

Domain and planning documents:

- [DART Main Events](./references/DART(main events).md) - Korean financial disclosure system events
- [Knowledge Graph Data Collection Planning](./references/knowledge-graph-data-collection-planning.md) - Comprehensive KG strategy (62KB)
- [Portfolio Recommendation & User Investment Preferences](./references/portfolio-rec-user-investment-pref.md) - Investment preference modeling
- [2026-11-17 Planning Doc](./references/20261117.md) - Project planning document

---

## Getting Started

### For New Features (PRD Creation)
1. Review [Project Overview](./project-overview.md) for system understanding
2. Check [Source Tree Analysis](./source-tree-analysis.md) for code organization
3. Reference relevant part documentation (see Existing Documentation above)
4. Review [Reference Documentation](#reference-documentation) for domain context
5. Use this index as primary context for AI-assisted PRD creation

### For Development
1. **Frontend:** See `sources/fe/README.md`
2. **Airflow:** See `sources/airflow/docs/QUICKSTART.md`
3. **LLM Service:** See `sources/llm/README.md`
4. **Knowledge Graph:** See `sources/kg/README.md`
5. **News Crawler:** See `sources/news-crawler/README.md`

### For Architecture Understanding
1. Start with [Project Overview](./project-overview.md)
2. Review [Source Tree Analysis](./source-tree-analysis.md)
3. Read part-specific architecture docs (Airflow, LLM have detailed docs)
4. Check integration patterns in existing READMEs

---

## Key Integration Points

1. **Frontend ↔ LLM Service**
   - REST API calls for AI-powered stock analysis
   - User authentication and session management

2. **LLM Service ↔ Knowledge Graph**
   - Neo4j queries for entity relationships
   - RAG (Retrieval-Augmented Generation) for context

3. **Airflow ↔ All Services**
   - Orchestrates data collection and processing
   - Triggers knowledge graph updates

4. **News Crawler → MongoDB → Airflow**
   - Financial news collection pipeline
   - Data enrichment and storage

5. **Shared Databases**
   - PostgreSQL: User data, LLM checkpoints
   - MongoDB: Scraped news, raw financial data
   - Neo4j: Knowledge graph entities and relationships

---

## Development Workflow

### Local Development
1. **Frontend:** `cd sources/fe && npm run dev`
2. **LLM Service:** Docker compose or local Python environment
3. **Airflow:** `docker-compose up` in airflow directory
4. **KG Builder:** CLI commands via `stockelper-kg`
5. **News Crawler:** Python scripts

### Testing
- **Frontend:** TypeScript type checking
- **Python Services:** pytest with coverage
- **Integration:** Manual testing via Postman/curl

### Deployment
- All services containerized with Docker
- See individual deployment guides in part-specific docs

---

## Documentation Status

✅ **Project Overview:** Complete
✅ **Source Tree Analysis:** Complete
⚠️ **Part-Specific Architecture:** To be generated (see sections above)
⚠️ **API Documentation:** Partial (exists for Airflow/LLM, needs generation for FE)
⚠️ **Data Models:** To be generated
⚠️ **Development Guides:** Partial (exists in READMEs, needs consolidation)

---

## Next Steps

### For Brownfield PRD
When creating a PRD for new features:
1. Point PRD workflow to this index.md
2. Specify which part(s) the feature affects
3. Reference relevant existing documentation
4. Include domain context from reference docs

### For Full Documentation
To generate remaining documentation marked as "_(To be generated)_":
1. Run document-project workflow again
2. Select option to generate incomplete documentation
3. Choose which specific documents to create

---

**Last Updated:** 2025-12-08
**Documentation Tool:** BMAD Method - Document Project Workflow
**Maintained By:** Stockelper Team
