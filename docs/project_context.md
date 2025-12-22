---
project_name: 'Stockelper'
user_name: 'Oldman'
date: '2025-12-18'
sections_completed: ['technology_stack', 'language_rules']
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

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

