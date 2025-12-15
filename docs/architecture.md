---
stepsCompleted: [1, 2, 3]
inputDocuments:
  - 'docs/prd.md'
  - 'docs/index.md'
  - 'docs/project-overview.md'
  - 'docs/source-tree-analysis.md'
workflowType: 'architecture'
lastStep: 3
project_name: 'Stockelper'
user_name: 'Oldman'
date: '2025-12-12'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**

The system encompasses 103 functional requirements across 11 major domains:

1. **Event Intelligence & Knowledge Graph (FR1-FR8):** Extract events from Korean news (Naver Finance) and DART disclosures, classify into defined ontology, store in Neo4j with date indexing, detect similar events across subgraphs
2. **Prediction & Analysis (FR9-FR18):** Multi-timeframe predictions (short/medium/long-term), confidence calculation, historical pattern matching, explanation generation
3. **Portfolio Management (FR19-FR28):** Manual recommendation requests, event-based rationale, portfolio tracking, investment profile management
4. **Backtesting & Validation (FR29-FR39):** User-initiated backtesting, multi-timeframe returns (3/6/12 months), Sharpe Ratio calculation, performance range analysis
5. **Alert & Notification (FR40-FR47):** Real-time event monitoring, similar event detection for user portfolios, push notifications with predictions
6. **Chat Interface (FR48-FR56):** Natural language queries for predictions/recommendations/backtesting, conversational explanations, prediction history
7. **Ontology Management (FR57-FR68):** Development team CRUD operations for event categories, extraction rule configuration, accuracy metrics, validation workflow
8. **Compliance & Audit (FR69-FR80):** Embedded disclaimers, comprehensive prediction logging (12-month retention), audit trail for accountability
9. **User Account & Authentication (FR81-FR90):** JWT-based authentication, secure session management, data isolation per user
10. **Data Pipeline & Orchestration (FR91-FR97):** Airflow DAG for News Crawler → Event Extraction → Knowledge Graph → Prediction Engine
11. **Rate Limiting & Abuse Prevention (FR98-FR103):** Query throttling, anomaly detection, alert frequency caps

**Non-Functional Requirements:**

Critical NFRs that will drive architectural decisions:

- **Performance (NFR-P1 to P12):** Prediction queries <2s, chat responses <500ms, backtesting <10s, event alerts within 5 minutes, 100+ concurrent users, 10 predictions/second throughput
- **Security (NFR-S1 to S16):** AES-256 encryption at rest, TLS 1.2+ in transit, bcrypt password hashing, JWT 24-hour expiration, SQL injection & XSS prevention, 12-month audit logs
- **Reliability (NFR-R1 to R13):** 99% uptime target, daily backups with 30-day retention, transactional knowledge graph updates, exponential backoff retries, 4-hour RTO
- **Scalability (NFR-SC1 to SC9):** 10x user growth support, 10,000+ events/month, 1M+ news articles, 3x traffic spike handling during market events
- **Integration (NFR-I1 to I9):** Tolerate 1-hour API downtime (DART/KIS/Naver), 30s timeouts, hourly news refresh, 5-minute stock price updates
- **Maintainability (NFR-M1 to M9):** 70% test coverage goal, zero-downtime ontology deployments, structured logs, accuracy metrics dashboards
- **Usability (NFR-U1 to U6):** Korean language support, actionable error messages, 2-minute time-to-first-prediction for new users

**Scale & Complexity:**

- **Primary domain:** Full-stack AI-powered fintech platform (web + backend services + data pipelines + ML/AI)
- **Complexity level:** High
  - Brownfield extension of existing 5-microservice system
  - AI/ML with multi-agent LangGraph system
  - Graph database (Neo4j) with temporal pattern matching
  - Real-time event detection and alerting
  - Multi-database coordination (PostgreSQL, MongoDB, Neo4j)
  - Fintech compliance requirements
- **Estimated architectural components:**
  - 3 major new subsystems (Event Extraction Engine, Prediction Engine, Alert System)
  - 5 existing services to extend (Frontend, Airflow, LLM, KG Builder, News Crawler)
  - 8+ integration points across services
  - 3 database systems requiring coordination

### Technical Constraints & Dependencies

**Existing Infrastructure (Must Integrate With):**
- **Frontend:** Next.js 15.3 with React 19, TypeScript 5.8, Prisma ORM, JWT authentication
- **Data Pipeline:** Apache Airflow 2.10 orchestration already established
- **LLM Service:** FastAPI + LangGraph multi-agent system operational
- **Knowledge Graph:** Neo4j 5.11+ with existing entity relationships
- **News Crawler:** Python-based scraper for Naver Finance
- **Databases:** PostgreSQL (users/auth), MongoDB (raw news), Neo4j (knowledge graph)

**External Dependencies:**
- **DART API:** Financial disclosure data (official Korean source)
- **KIS OpenAPI:** Korean trading data and real-time market information
- **Naver Finance:** News article source for event extraction
- **OpenAI API:** LLM inference for chat interface and event classification

**Korean Market Constraints:**
- Korean language processing for event extraction
- Korean financial regulations (informational platform positioning)
- PIPA compliance (Personal Information Protection Act)
- Business hours aligned with Korean market trading times

**MVP Scope Boundaries:**
- Events limited to defined ontology (not all-encompassing)
- Portfolio recommendations manual (not time-scheduled in MVP)
- Backtesting user-initiated (not automatic in MVP)
- Single market focus (Korean only)

### Cross-Cutting Concerns Identified

**1. Event Extraction Accuracy (Foundation)**
- Quality of event extraction directly impacts all prediction accuracy
- Requires ontology management interface for continuous improvement
- Validation workflow with human review samples
- Accuracy metrics per category tracked in observability system

**2. Multi-Database Consistency**
- Three databases must remain synchronized: PostgreSQL (users), MongoDB (news), Neo4j (events/relationships)
- Transaction boundaries across database types
- Data pipeline orchestration through Airflow DAG
- Rollback strategies when updates fail

**3. Real-Time Orchestration**
- Event alerts must trigger within 5 minutes of detection
- Real-time similarity matching against knowledge graph
- Push notification delivery system
- Background monitoring without impacting user-facing performance

**4. Prediction Confidence & Transparency**
- Confidence levels calculated from pattern strength (historical instances)
- Clear explanation of "similar events under similar conditions"
- Historical examples shown to users
- Disclaimers embedded in all outputs (informational, not advice)

**5. Security & Privacy**
- User portfolio data isolation (cannot access other users' holdings)
- Investment profile privacy
- Prediction history per-user
- Audit logs without exposing personal data in aggregate analytics

**6. Observability & Debugging**
- Prediction logging: timestamp, user, stock, confidence, historical patterns used
- Event extraction quality metrics
- System performance tracking (response times, error rates)
- Airflow DAG monitoring for pipeline health

**7. Korean Fintech Compliance**
- Embedded disclaimers: "educational purposes only, not investment advice"
- 12-month audit trail retention
- PIPA data rights (access, correction, deletion, portability)
- Rate limiting to prevent abuse

## Starter Template Evaluation

### Project Type: Brownfield Extension

This is **not a greenfield project** requiring a starter template. Stockelper has an established 5-microservice architecture that we're extending with event-driven intelligence capabilities.

### Existing Technical Stack (Foundation)

**Frontend Layer:**
- **Framework:** Next.js 15.3 with React 19
- **Language:** TypeScript 5.8
- **Database:** PostgreSQL with Prisma ORM
- **Authentication:** JWT-based session management
- **Styling:** Tailwind CSS + Radix UI component library
- **State Management:** React hooks and context
- **API Routes:** Next.js API routes for backend endpoints

**Backend Services:**
- **LLM Service:** FastAPI + LangGraph multi-agent system (Python 3.12+)
  - **Critical Update Required:** Refactor to LangChain v1.0+ (recently updated)
  - Implementation must follow official LangChain v1.0+ documentation
- **Data Pipeline:** Apache Airflow 2.10 for orchestration
- **Knowledge Graph Builder:** Python 3.12 CLI for Neo4j management
- **News Crawler:** Python 3.11+ with Typer CLI framework

**Data Layer:**
- **PostgreSQL:** User accounts, authentication, LLM checkpoints
- **MongoDB:** Scraped news articles, raw financial data
- **Neo4j 5.11+:** Knowledge graph entities and relationships

**External Integrations:**
- **DART API:** Korean financial disclosures (checked **once daily**)
- **KIS OpenAPI:** Korean trading data and real-time market information
- **Naver Securities News:** News scraping (periodic per stock every **2-3 hours**)
- **Toss Securities News:** News scraping (periodic per stock every **2-3 hours**)
- **OpenAI API:** LLM inference for chat interface and event classification

### Dual Event Pipeline Architecture

**Pipeline 1: Disclosure-Based Events (DART)**
- **Frequency:** Checked once per day
- **Source:** DART API (official Korean financial disclosure system)
- **Workflow:**
  1. Daily check for new disclosure information
  2. When new disclosure detected → Extract events
  3. Add events to Neo4j knowledge graph
  4. Compare new event with historical events (already in graph)
  5. Measure resulting stock price movement
  6. Notify user based on pattern matching

**Pipeline 2: News-Based Events**
- **Frequency:** Every 2-3 hours per specific stock
- **Sources:** Naver Securities News + Toss Securities News
- **Workflow:**
  1. Periodic crawling for specific stocks
  2. **Deduplication:** Apply effective deduplication strategy (must be designed)
  3. Event extraction from deduplicated news articles
  4. Add events to Neo4j knowledge graph
  5. Pattern matching and user notification (same as Pipeline 1)

**Deduplication Strategy (To Be Designed):**
- News articles from multiple sources must be deduplicated before event extraction
- Strategy must account for:
  - Same news from different sources (Naver vs Toss)
  - Similar news with slight variations
  - Timestamp-based duplicate detection
  - Content similarity scoring
- Effective deduplication critical for knowledge graph quality

### Architectural Extension Strategy

**Core Principle: Extend, Don't Replace**

All new functionality integrates into existing services following established patterns:

**1. Portfolio Recommendations (Extension):**
- **Existing Capability:** Recommendation generation already implemented in LLM service
- **New Requirement:** Daily scheduling at 9:00 AM using previous day's closing prices
- **Implementation Approach:** Add Airflow DAG for scheduled execution (9:00 AM trigger)
- **Pattern to Follow:** Existing Airflow DAG style and conventions
- **Note:** Core recommendation logic exists; only scheduling integration needed

**2. Event-Driven Backtesting (User-Initiated):**
- **Trigger:** Explicit user requests only (not automatic)
- **User Experience:** Progress notifications for time-consuming operations
- **Implementation Approach:** Async processing with status updates
- **Pattern to Follow:** Existing async task patterns in LLM service
- **Notification:** Separate notification to inform user of progress or completion

**3. Event Notifications (New Feature):**
- **Requirement:** Real-time alerts when similar events occur
- **Trigger:** New disclosure event or news event matches historical patterns
- **Implementation Approach:** Leverage existing notification patterns
- **Integration:** Event monitoring system triggers notifications after pattern matching
- **Pattern to Follow:** Existing push notification infrastructure (if available) or establish pattern consistent with current architecture

**4. Airflow DAG Extensions:**
- **Guideline:** New DAGs must follow existing style and conventions
- **New DAGs Required:**
  - Daily DART disclosure check (once per day)
  - Periodic news crawling (every 2-3 hours per stock)
  - Portfolio recommendation scheduling (9:00 AM daily)
  - Event pattern matching and notification triggers
- **Requirement:** Review existing DAG structure before implementing new pipelines

**5. API Structure Adherence:**
- **Principle:** Reuse and adhere to existing API patterns
- **Frontend ↔ LLM Service:** Maintain consistent endpoint structure
- **Authentication:** JWT pattern already established
- **Error Handling:** Follow existing error response formats
- **New Endpoints:** Event queries, backtesting requests, recommendation retrieval

**6. Database Schema Evolution:**
- **PostgreSQL:** Reuse existing schemas for user data, add alert preferences
- **MongoDB:** Reuse existing schemas for news/financial data
- **Neo4j:**
  - Reuse existing entity and relationship schemas where possible
  - **New schemas required:**
    - Date-indexed events (for temporal pattern matching)
    - Subgraph pattern structures
    - Event metadata (source, disclosure vs news, deduplication markers)
    - Historical price movements linked to events
  - Ensure backward compatibility with existing graph queries

### Architectural Decisions Inherited from Existing Stack

**Language & Runtime:**
- TypeScript 5.8 for frontend development
- Python 3.12+ for backend services and AI/ML
- Node.js for Next.js runtime

**AI/ML Framework Update:**
- **Current:** LangChain + LangGraph (older version)
- **Required:** Refactor to **LangChain v1.0+** (recently updated)
- **Implementation Guide:** Official LangChain v1.0+ documentation must be followed
- **Impact:** Multi-agent system patterns may change; review v1.0 migration guide

**Styling & UI:**
- Tailwind CSS utility-first approach
- Radix UI for accessible component primitives
- Responsive design patterns already established

**Build Tooling:**
- Next.js build system for frontend
- Python package management (pip/requirements.txt)
- Docker containerization for all services

**Testing Framework:**
- Testing infrastructure exists (pytest for Python services)
- Follow existing test patterns and coverage expectations

**Code Organization:**
- Microservices architecture maintained
- Each service has independent deployment
- Shared database layer with service-specific access patterns

**Development Experience:**
- Hot reloading via Next.js dev server
- TypeScript strict mode configuration
- Environment variable management patterns established
- Docker Compose for local development

**Deployment Patterns:**
- Containerized services (Docker)
- Existing CI/CD patterns (if established)
- Environment configuration management

### Key Architectural Constraints

**Must Preserve:**
- Existing microservices boundaries
- Current authentication flow (JWT)
- Database connection patterns
- API endpoint versioning (if established)
- Error handling conventions

**Must Follow:**
- Airflow DAG style and conventions for new scheduled tasks
- Existing notification patterns for event alerts
- Current API structure and response formats
- Established code organization within each service
- LangChain v1.0+ patterns for AI/ML refactoring

**Must Design:**
- Effective news deduplication strategy before event extraction
- Dual event pipeline coordination (disclosure vs news)
- Event pattern matching algorithm for historical comparison
- Stock price movement measurement and attribution to events

**May Extend:**
- Neo4j schemas for event-driven features (date indexing, subgraph patterns, event metadata)
- Airflow DAGs for new orchestration needs (4 new DAGs identified)
- Frontend components following Radix UI + Tailwind patterns
- LLM service endpoints for new prediction capabilities

### Integration Points for New Features

**Event Extraction Engine (Dual Pipeline):**

**Pipeline 1 - Disclosure Events:**
- Input: DART API (daily check)
- Processing: Event extraction → Deduplication (if needed)
- Output: Neo4j knowledge graph (disclosure event schema)

**Pipeline 2 - News Events:**
- Input: News Crawler → Naver Securities News + Toss Securities News (every 2-3 hours)
- Processing: Deduplication (critical) → Event extraction
- Output: Neo4j knowledge graph (news event schema)

**Pattern Matching & Notification:**
- Input: New event in knowledge graph (from either pipeline)
- Processing: Compare with historical events → Measure stock price movement
- Output: User notification if pattern match found

**Prediction Engine:**
- Input: Neo4j knowledge graph queries (historical event patterns)
- Processing: LangGraph agents in LLM service (extend existing multi-agent system, refactored to LangChain v1.0+)
- Output: REST API endpoints for frontend consumption

**Alert System:**
- Monitoring: Triggered by event pipeline completion (Airflow DAG tasks)
- Storage: PostgreSQL for user alert preferences
- Delivery: Leverage existing notification patterns + push notifications

**Chat Interface:**
- Frontend: Extend existing Next.js pages/components
- Backend: LLM service API routes (FastAPI endpoints)
- Real-time: Consider existing WebSocket patterns or add if needed

**Scheduled Portfolio Recommendations:**
- Trigger: Airflow DAG scheduled at 9:00 AM daily
- Input: Previous day's closing prices + user portfolio holdings
- Processing: Existing recommendation logic (already implemented)
- Output: Precomputed recommendations delivered to users at 9:00 AM

### Critical Technical Updates Required

**1. LangChain v1.0+ Migration:**
- Existing LangChain/LangGraph code must be refactored
- Follow official LangChain v1.0+ documentation for migration
- Multi-agent patterns may change significantly
- Test thoroughly after refactoring

**2. News Deduplication Strategy:**
- Design effective deduplication before event extraction
- Consider content similarity algorithms (TF-IDF, embeddings, fuzzy matching)
- Implement deduplication markers in MongoDB storage
- Track deduplication effectiveness metrics

**3. Dual Event Pipeline Coordination:**
- Separate Airflow DAGs for disclosure vs news events
- Unified event schema in Neo4j (with source metadata)
- Consistent pattern matching logic across both pipelines
- Handle different update frequencies (daily vs 2-3 hours)

### No Starter Template Initialization Required

**Rationale:**
This is a brownfield project with established technical decisions. The architecture document will guide AI agents to extend existing services following current patterns, not initialize a new project from scratch.

**First Implementation Story:**
Rather than "Initialize project from starter template," the first story will be "Review existing codebase structure and LangChain v1.0+ migration requirements" to ensure AI agents understand the existing architecture and necessary refactoring before making changes.
