---
project_name: 'Stockelper'
user_name: 'Oldman'
date: '2025-12-18'
last_updated: '2026-01-04'
sections_completed: ['implementation_priority', 'technology_stack', 'language_rules', 'architectural_decisions', 'service_boundaries', 'ux_patterns', 'common_pitfalls', 'data_schemas_updated']
repositories: 7
repository_list: ['stockelper-fe', 'stockelper-llm', 'stockelper-kg', 'stockelper-airflow', 'stockelper-news-crawler', 'stockelper-backtesting', 'stockelper-portfolio']
implementation_strategy:
  primary_data_source: 'DART Disclosures'
  deferred_data_source: 'News Articles'
  target_stocks_first: true
  revised_sequence_date: '2026-01-04'
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## ⚠️ CRITICAL: Implementation Priority (Updated 2026-01-04)

**Strategic Priority Change:**

**PRIMARY DATA SOURCE: DART Disclosures (Prioritize)**
- Focus on DART disclosure data collection and event/sentiment extraction
- Target stocks only (AI sector) for initial implementation
- DART provides structured, high-quality event data

**DEFERRED DATA SOURCE: News Articles (Defer to Later Phase)**
- News collection and event/sentiment extraction deferred
- Will be implemented after DART-based foundation is operational

**Implementation Sequence (MUST FOLLOW THIS ORDER):**

1. **DART Disclosure Collection** (Story 1.1b - Collection section)
   - 20 major report types via DART API (6 categories)
     - Capital Changes (4): Paid-in Capital Increase, Bonus Issue, Paid-in and Bonus Issue, Capital Reduction
     - Bond Issuance (2): Convertible Bonds, Bonds with Warrants
     - Treasury Stock (4): Acquisition Decision, Disposal Decision, Trust Contract Execution, Trust Contract Termination
     - Business Operations (4): Business Acquisition, Business Transfer, Tangible Asset Acquisition, Tangible Asset Transfer
     - Securities Transactions (2): Acquisition of Shares/Equity Securities, Transfer of Shares/Equity Securities
     - M&A/Restructuring (4): Merger, Corporate Spin-off, Merger Following Spin-off, Stock Exchange/Stock Transfer
   - Store in Local PostgreSQL (20 tables, one per report type)
   - Target stocks only (AI sector)

2. **Event & Sentiment Extraction from DART** (Story 1.1b - Extraction section)
   - LLM-based extraction with DART-specific prompts
   - Store events in Neo4j with sentiment scores (-1 to 1)
   - Source attribute: "DART"

3. **Daily Stock Price Collection** (Story 1.8)
   - OHLCV data from KIS OpenAPI
   - Store in Local PostgreSQL `daily_stock_prices` table
   - Required for backtesting

4. **Knowledge Graph Construction** (Integrated in Story 1.1b)
   - Neo4j graph with Event nodes, Document nodes
   - Entity relationships and pattern matching

5. **Backtesting Container Implementation** (Epic 3 Stories 3.1-3.6)
   - Dedicated independent container service
   - Write results to Remote PostgreSQL (t3.medium)

6. **Portfolio Recommendation Container Implementation** (Epic 2 Stories 2.4, 2.5)
   - Separate container service
   - Write results to Remote PostgreSQL (t3.medium)

7. **Results Persistence to PostgreSQL** (Integrated in above)
   - Both containers write to Remote PostgreSQL on AWS t3.medium
   - Unified data model with Korean status enum

8. **Frontend Implementation**
   - Dedicated Backtesting page (Story 3.1 - Frontend)
   - Dedicated Portfolio Recommendation page (Story 2.4 - Frontend)

9. **User Progress Visualization** (Integrated in frontend)
   - Supabase Realtime subscriptions
   - Real-time status updates

**DEFERRED STORIES (DO NOT IMPLEMENT YET):**
- ❌ Story 1.1a: Automate News Event Extraction
- ❌ Story 1.2: Frontend Event Timeline Visualization
- ❌ Story 1.3: Multi-Timeframe Prediction UI
- ❌ Story 1.4: Rich Chat Prediction Cards
- ❌ Story 1.5: Suggested Queries Based on Portfolio

**Why This Order:**
- DART disclosure data provides structured, reliable event intelligence
- Backtesting and portfolio recommendations are core user value features
- News-based features can be added incrementally after foundation is solid

**Reference:** See `docs/implementation-readiness-report-2026-01-04.md` (ADDENDUM section) for complete details.

---

## Technology Stack & Versions

**Frontend Repository (stockelper-frontend):**
- Next.js 15.3+ (App Router - MUST use App Router, not Pages Router)
- React 19
- TypeScript 5.8+
- Prisma ORM (PostgreSQL client)
- Tailwind CSS 3.4+
- Radix UI
- Zod (validation library)
- SWR (data fetching)

**Backend Repository (stockelper-llm-service):**
- Python 3.12+
- FastAPI
- **LangChain 1.0+** ⚠️ CRITICAL: Must use v1.0+ API patterns (Phase 0 prerequisite)
  - LangChain >= 1.0.0
  - LangChain-OpenAI >= 1.0.0
  - LangGraph >= 1.0.0
- Neo4j Python Driver 5.11+
- PyMongo 4.5+
- Psycopg2 (PostgreSQL driver)

**Knowledge Graph Builder (stockelper-kg):**
- Python 3.12+
- Neo4j Python Driver 5.11+
- PyMongo 4.5+
- Sentence Transformers (for embeddings)

**Crawler Repository (stockelper-crawler):**
- Python 3.12+
- BeautifulSoup4 or Scrapy
- PyMongo 4.5+

**Orchestration Repository (stockelper-airflow):**
- Apache Airflow 2.10+
- Python 3.12+

**Databases:**
- Neo4j 5.11+ (Knowledge Graph storage)
- MongoDB 6+ (Document storage for news/disclosures)
- PostgreSQL 15+ (Transactional data: users, portfolios, audit logs)

**Critical Version Constraints:**

⚠️ **LangChain v1.0+ Migration is MANDATORY** - This is a Phase 0 prerequisite that MUST complete before implementing any new features. All agents must use LangChain v1.0+ API patterns:
- Replace `ConversationChain` with `create_react_agent()` or `AgentExecutor.from_llm_and_tools()`
- Update memory: `ConversationBufferMemory` → `ChatMessageHistory` + `MessagesPlaceholder`
- Update prompt templates: `PromptTemplate` → `ChatPromptTemplate.from_messages()`
- Update invocation: `.run()` → `.invoke()`

---

## Critical Implementation Rules

### Language-Specific Rules

#### **TypeScript Rules (Frontend: stockelper-frontend)**

**Naming Conventions:**
- **Files:** `PascalCase.tsx` for React components (e.g., `PortfolioSummary.tsx`, `PredictionCard.tsx`)
- **Functions:** `camelCase` (e.g., `getPrediction()`, `formatCurrency()`)
- **Classes:** `PascalCase` (e.g., `PredictionService`, `ApiClient`)
- **Constants:** `SCREAMING_SNAKE_CASE` (e.g., `API_BASE_URL`, `MAX_RETRIES`)
- **Interfaces/Types:** `PascalCase` (e.g., `PredictionResponse`, `PortfolioItem`)

**Import/Export Patterns:**
- MUST use named exports for components, not default exports
- Group imports: React/Next.js first, then third-party, then local
- Use absolute imports with `@/` prefix configured in `tsconfig.json`

**Error Handling:**
- Frontend MUST use Error Boundaries for component-level errors
- Inline error handling with try-catch for async operations
- Display user-friendly Korean error messages (never expose stack traces to users)

**React Patterns:**
- MUST use React 19 patterns (no legacy patterns)
- Prefer `use client` directive only when absolutely necessary (server components by default)
- Custom hooks MUST start with `use` prefix (e.g., `usePortfolio`, `usePrediction`)

#### **Python Rules (Backend: stockelper-llm-service, stockelper-kg, stockelper-crawler, stockelper-airflow)**

**Naming Conventions:**
- **Files:** `snake_case.py` (e.g., `prediction_service.py`, `event_extractor.py`)
- **Functions:** `snake_case` (e.g., `extract_events()`, `calculate_sentiment()`)
- **Classes:** `PascalCase` (e.g., `PredictionAgent`, `EventExtractor`)
- **Constants:** `SCREAMING_SNAKE_CASE` (e.g., `NEO4J_URI`, `MAX_EVENTS_PER_BATCH`)
- **Private methods:** `_leading_underscore` (e.g., `_validate_input()`)

**Import Patterns:**
- Standard library imports first, then third-party, then local
- Absolute imports preferred over relative imports
- Group related imports together

**Type Annotations:**
- MUST use type hints for all function parameters and return values
- Use `from typing import` for complex types (List, Dict, Optional, etc.)
- Python 3.12+ syntax preferred (e.g., `list[str]` over `List[str]`)

**Error Handling:**
- Backend MUST use global exception handler in FastAPI
- Raise HTTPException with appropriate status codes (see Architecture Section 5.6)
- Log all errors with structured logging (include context: user_id, request_id, etc.)

**Async/Await Patterns:**
- MUST use `async/await` for all I/O operations (database queries, API calls)
- Use `asyncio.gather()` for parallel operations
- Never block the event loop with synchronous I/O

---

## Critical Architectural Decisions

### Supabase Realtime Integration (CRITICAL)

**Decision:** Use Supabase Realtime for all database change notifications instead of a custom notification service.

**How It Works:**
- Backend services write to PostgreSQL (status updates, new results)
- Supabase Realtime automatically detects DB changes
- Frontend subscribes to Supabase Realtime channels
- UI updates automatically without custom WebSocket layer
- Browser notifications delivered Confluence-style (accumulating, non-intrusive)

**Implementation Rules:**
- ❌ DO NOT create custom notification service or WebSocket server
- ✅ Backend MUST write all status changes to PostgreSQL tables
- ✅ Frontend MUST subscribe to Supabase Realtime channels (NOT polling)
- ✅ Use shared hook: `useSupabaseRealtimeSubscription.ts`
- ✅ Enable Supabase Realtime on tables: `backtest_jobs`, `portfolio_recommendations`, `notifications`

**Tables with Realtime Enabled:**
- `backtest_jobs` - Status updates for backtesting execution
- `portfolio_recommendations` - Status updates for portfolio recommendations
- `notifications` - User notification events

---

### Data Ownership Model (CRITICAL)

**Rule:** Agents/backend services FULLY own data generation and persistence. Frontend ONLY renders.

**Backend Responsibilities:**
- Generate all content (LLM-generated Markdown, charts, images)
- Define database schemas and columns
- Manage status transitions: `PENDING` → `IN_PROGRESS` → `COMPLETED` / `FAILED`
- Write all data to PostgreSQL
- Update timestamps: `created_at`, `updated_at`, `written_at`, `completed_at`

**Frontend Responsibilities:**
- Subscribe to Supabase Realtime for table changes
- Render UI based on database state
- Display loading states during `PENDING` / `IN_PROGRESS`
- Show results when status is `COMPLETED`

**Frontend MUST NOT:**
- Define database columns or schemas
- Push data to backend (except initial request)
- Manage status transitions
- Generate content

---

### Unified Data Model for Backtesting & Portfolio Recommendations (Updated 2026-01-03)

**Schema Pattern (PostgreSQL):**

Both `backtest_results` and `portfolio_recommendations` tables share this structure:

```sql
{
  -- Identifiers
  id: SERIAL PRIMARY KEY,
  job_id: UUID NOT NULL UNIQUE,  -- NEW: Unique job identifier for tracking (FR128, FR129)

  -- Content (generated by agents)
  content: TEXT,              -- LLM-generated Markdown
  image_base64: TEXT,         -- Optional image (nullable)

  -- User context
  user_id: UUID,              -- FK to users table

  -- Timestamps
  created_at: TIMESTAMP,      -- Request initiated
  updated_at: TIMESTAMP,      -- Last modification
  written_at: TIMESTAMP,      -- Result written (nullable)
  completed_at: TIMESTAMP,    -- Job finished (nullable)

  -- Status (UPDATED: Korean enum values - FR130)
  status: VARCHAR(20) CHECK (status IN ('작업 전', '처리 중', '완료', '실패'))
}
```

**Additional Fields (Backtesting Only):**
```sql
{
  strategy_description: TEXT,  -- User's backtesting strategy
  universe_filter: TEXT,       -- Applied universe (e.g., "AI sector")
  execution_time_seconds: INT  -- Actual execution duration (5min-1hr range)
}
```

**Status Transition Rules (Korean Enum - FR130):**
- `작업 전` (Before Processing): Initial state when request created
- `처리 중` (In Progress): Agent is processing request
  - Backtesting: 5 minutes (simple) to 1 hour (complex) expected
  - Portfolio: Typically faster
- `완료` (Completed): Agent finished successfully, results available
- `실패` (Failed): Agent encountered error

**Implementation Notes:**
- NEVER create separate schemas for similar features
- ALWAYS use this pattern for long-running agent tasks
- Status field MUST be updated by backend, NOT frontend
- Status values MUST use Korean strings (작업 전, 처리 중, 완료, 실패)
- job_id MUST be generated as UUID on backend and used for tracking across system

---

### Infrastructure & Database Locations (Updated 2026-01-03)

**Remote PostgreSQL on AWS t3.medium:**
- **Host:** `${POSTGRES_HOST}`
- **Port:** `5432` (default)
- **User:** `postgre`
- **Schema:** `"stockelper-fe"` (note: hyphen requires quoting in PostgreSQL identifiers)
- **Purpose:** Stores backtesting results, portfolio recommendations, user data, notifications
- **Credentials:** MUST use environment variables / secrets (NEVER commit to repo)

**Local PostgreSQL (NEW - FR127):**
- **Purpose:** Stores DART disclosure data (36 major report types), event extraction results, sentiment scores, daily stock price data
- **Tables:** 36 DART disclosure tables (dart_piicDecsn, dart_dfOcr, etc.) + daily_stock_prices + dart_events
- **Location:** Local development machine or dedicated data collection server
- **Connection:** `LOCAL_POSTGRES_CONN_STRING` environment variable

**Storage Location Summary:**
- **Remote PostgreSQL**: Backtesting results, portfolio recommendations, user data, notifications
- **Local PostgreSQL**: DART disclosures (36 types), event extraction, sentiment scores, daily price data
- **Neo4j**: Event nodes, Document nodes, entity relationships, pattern matching
- **MongoDB**: News articles, competitor intelligence, raw crawled data

**Environment Variable Names:**
- Remote: `DATABASE_URL` or `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
- Local: `LOCAL_POSTGRES_CONN_STRING` (format: `postgresql://user:password@localhost:5432/stockelper_local`)

**Local Development Services:**
- **stockelper-airflow:** ETL pipeline scheduling (Airflow)
- **stockelper-neo4j:** Knowledge graph (event data, entity relationships)
- **MongoDB (Compass):** Competitor intelligence, securities firm report summaries
- **Local PostgreSQL:** DART disclosure data storage (36 tables)

**AWS Servers:**
- **stockelper-small (t3.small):** Application servers (LLM service)
- **stockelper-medium (t3.medium):** PostgreSQL database

---

### Service Boundaries & Responsibilities

**Frontend (stockelper-fe):**
- User interface (Next.js App Router)
- Supabase Realtime subscriptions
- Rendering Markdown reports
- Browser notification display
- NO data generation, NO schema definition

**LLM Service (stockelper-llm):**
- Multi-agent LangGraph system
- Portfolio Recommendation Agent (already implemented)
- Chat interface endpoints
- Event extraction and analysis
- Writes results to PostgreSQL

**Backtesting Service (stockelper-backtesting):**
- Separate repository (separate container, local execution initially)
- Processes backtesting requests (5 minutes to 1 hour)
- Writes results to Remote PostgreSQL on AWS t3.medium
- Manages status transitions with Korean enum
- Updates job_id for tracking

**Portfolio Service (stockelper-portfolio):**
- Separate repository (separate container, local execution initially)
- Generates portfolio recommendations
- Writes results to Remote PostgreSQL on AWS t3.medium
- Manages status transitions with Korean enum
- Updates job_id for tracking

**Knowledge Graph Builder (stockelper-kg):**
- Neo4j graph construction
- DART disclosure collection using 36 major report type APIs (FR126, FR127)
- Stores raw DART data in Local PostgreSQL (36 tables)
- Event extraction from structured DART data
- Daily stock price data collection (FR131)
- Entity relationship management

**Airflow (stockelper-airflow):**
- ETL pipeline orchestration
- Scheduled tasks (e.g., daily portfolio recommendations)
- Data pipeline coordination

**News Crawler (stockelper-news-crawler):**
- News article collection from Naver Finance
- Raw data storage in MongoDB

---

### Backtesting Flow - Critical UX Pattern

**Chat Request Flow:**
1. User: "Backtest Samsung with event-driven strategy"
2. LLM extracts parameters (universe, strategy)
3. Chat responds: "Backtesting is in progress (approx. 5–10 minutes)"
4. Chat message includes link: "Check status on [Backtesting Page]"
5. Frontend subscribes to `backtest_jobs` table via Supabase Realtime
6. When status changes to `COMPLETED`, browser notification appears
7. UI updates automatically (real-time AND after page refresh)

**Implementation Rules:**
- DO NOT show results in chat
- ALWAYS provide link to dedicated results page
- MUST use Supabase Realtime for status updates (NO polling)
- Show loading states for `PENDING` / `IN_PROGRESS` status
- Render Markdown report on same page (NOT new page) when clicking row

---

### Portfolio Recommendation Flow - Critical UX Pattern

**Dedicated Portfolio Recommendation Page Required:**
- **Route:** `/portfolio/recommendations`
- **Must have:** "Generate Recommendation" button
- **Must show:** List of previous recommendations (accumulated over time)
- **Must display:** Stale recommendation warnings (>3 days old)

**Button-Triggered Generation:**
1. User clicks "Generate Recommendation" button
2. Request sent to Portfolio Recommendation Agent (LLM server)
3. Status: `PENDING` → `IN_PROGRESS`
4. Frontend subscribes to Supabase Realtime
5. Browser notification when status changes to `COMPLETED`
6. UI updates automatically

**Chat-Triggered Generation:**
1. User: "Give me portfolio recommendations"
2. Chat responds: "Recommendation is in progress (1–3 minutes)"
3. Chat message includes link: "View on [Portfolio Recommendation Page]"
4. Results NOT shown in chat

**Stale Recommendation Warning:**
- Display warning for recommendations >3 days old
- Example: "This recommendation is from 3 days ago and may be outdated"

---

### Notification Architecture

**CRITICAL: NO custom notification service**

**Architecture:**
- Backend → PostgreSQL → Supabase Realtime → Frontend
- NO custom WebSocket server
- NO custom notification microservice
- NO polling mechanisms

**Frontend GNB Notification Icon:**
- Badge shows unread notification count
- Subscribes to `notifications` table via Supabase Realtime
- Clicking notification navigates to relevant page
- Mark as read updates database (triggers Supabase Realtime update)

**Browser Notifications:**
- Confluence-style (accumulating, non-intrusive)
- Examples:
  - "Backtesting completed for Samsung"
  - "Portfolio recommendation completed"
- Clicking notification navigates to relevant page

---

## Common Pitfalls to Avoid

### DO NOT:
1. ❌ Create custom notification service or WebSocket server
2. ❌ Use polling for real-time updates
3. ❌ Let frontend define database schemas
4. ❌ Show long-running results (backtesting, portfolio) in chat
5. ❌ Hard-code database credentials in code
6. ❌ Create new data models without checking for unified schema pattern
7. ❌ Open new pages for results (use same-page rendering)
8. ❌ Skip Supabase Realtime subscriptions
9. ❌ Create separate schemas for similar features

### DO:
1. ✅ Use Supabase Realtime for all real-time updates
2. ✅ Follow unified data model pattern for agent tasks
3. ✅ Let backend fully own data generation and persistence
4. ✅ Provide links to dedicated pages from chat
5. ✅ Use environment variables for all credentials
6. ✅ Enable Supabase Realtime on status tables
7. ✅ Show stale warnings for old recommendations
8. ✅ Use shared `useSupabaseRealtimeSubscription` hook
9. ✅ Render results on same page (not new page)

---

