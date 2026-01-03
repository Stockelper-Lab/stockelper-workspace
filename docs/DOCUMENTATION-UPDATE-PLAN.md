# Documentation Update Plan - 2026-01-03
**Based on:** meetings/20251229.md, meetings/20260103.md, references/DART(modified events).md

---

## Summary of Changes Required

### 1. **DART Collection Architecture** (CRITICAL - Complete Overhaul)

**OLD Approach:**
- Generic `list()` → `document()` → event extraction
- Unstructured text parsing
- Remote PostgreSQL storage

**NEW Approach (1/3 meeting - 민우 work):**
- **36 structured major report type APIs**
- Dedicated DART API endpoint per type
- **Local PostgreSQL storage**
- Structured field extraction

**Impact:** architecture.md, epics.md, DART-implementation-analysis.md, PRD

---

### 2. **Data Schema Updates**

**Backtesting Results Table:**
```sql
-- ADDED: job_id column
{
  job_id: UUID,              -- NEW: Unique job identifier
  content: TEXT,
  image_base64: TEXT,
  user_id: UUID,
  created_at: TIMESTAMP,
  updated_at: TIMESTAMP,
  written_at: TIMESTAMP,
  completed_at: TIMESTAMP,
  status: ENUM('작업 전', '처리 중', '완료', '실패')  -- CHANGED: Korean values
}
```

**Portfolio Recommendations Table:**
```sql
-- Same schema as backtesting (unified model confirmed)
{
  job_id: UUID,              -- NEW: Added for consistency
  content: TEXT,
  image_base64: TEXT,
  user_id: UUID,
  created_at: TIMESTAMP,
  updated_at: TIMESTAMP,
  written_at: TIMESTAMP,
  completed_at: TIMESTAMP,
  status: ENUM('작업 전', '처리 중', '완료', '실패')  -- CHANGED: Korean values
}
```

**Impact:** architecture.md, epics.md, project_context.md

---

### 3. **New Functional Requirements**

**FR125:** System can collect daily stock price data for universe stocks
**FR126:** System can collect DART disclosures using 36 major report type APIs
**FR127:** System can store DART disclosure data in local PostgreSQL
**FR128:** Backtesting jobs include unique `job_id` for tracking
**FR129:** Portfolio recommendation jobs include unique `job_id` for tracking
**FR130:** Status values use Korean enum (`작업 전`, `처리 중`, `완료`, `실패`)

**Impact:** PRD

---

### 4. **Repository Separation** (Confirmed)

**stockelper-backtesting:**
- Separate repository
- Local execution (initial phase)
- Writes to remote PostgreSQL (${POSTGRES_HOST})

**stockelper-portfolio:**
- Separate repository
- Local execution (initial phase)
- Writes to remote PostgreSQL (${POSTGRES_HOST})

**Impact:** project-overview.md, architecture.md

---

### 5. **Storage Location Clarification**

**Remote PostgreSQL (${POSTGRES_HOST}):**
- Backtesting results
- Portfolio recommendations
- User data
- Notifications

**Local PostgreSQL:**
- DART disclosure data (36 major report types)
- Event extraction results
- Sentiment scores

**Impact:** All documentation with PostgreSQL references

---

### 6. **Universe Definition**

**Source:** `modules/dart_disclosure/universe.ai-sector.template.json`

**Definition:** Specific list of AI-sector stock tickers (NOT abstract category)

**Purpose:**
- DART disclosure collection scope
- Backtesting candidate pool
- Portfolio recommendation candidates

**Impact:** architecture.md, epics.md

---

### 7. **New Data Pipeline Component**

**Daily Stock Price Collection:**
- Owner: 영상
- Schedule: Daily
- Source: TBD (KIS API or similar)
- Storage: Local PostgreSQL or time-series DB
- Purpose: Provide price data for backtesting

**Impact:** architecture.md (new pipeline), epics.md (new story)

---

### 8. **Backtesting Execution Constraints**

**Performance:**
- 1-year backtest: ~5 minutes
- Complex strategies: up to 1 hour

**Implication:**
- Async processing confirmed
- Dedicated results page confirmed
- Browser notifications confirmed

**Impact:** architecture.md (NFRs), epics.md

---

### 9. **Chat-Based Parameter Extraction**

**Flow:**
1. User: "백테스팅을 진행해줘"
2. Assistant: "백테스팅을 위한 전략을 말해주세요"
3. User: "뉴스 이벤트 감성지수 3.8 이상인 경우만 매수해줘"
4. LLM extracts: universe + strategy
5. Trigger backtesting
6. Response: "백테스팅이 진행 중입니다"

**Supported Parameters:**
- News event sentiment score (감성지수)
- Fundamental indicators
- Moving average conditions
- Universe filter

**Impact:** architecture.md (chat interface section), epics.md (Story 3.1)

---

### 10. **News Collection Deprioritized**

**Decision:** News collection is lower priority

**Implication:**
- Focus on DART collection first
- News pipeline implementation deferred

**Impact:** Sprint planning, epic priorities

---

## File-by-File Update Plan

### A) architecture.md

**Section 3.3 - DART Disclosure Collection (NEW):**
```markdown
#### DART Disclosure Collection Pipeline (36 Major Report Types)

**Status:** Revised Collection Strategy (2026-01-03)

**Choice:** Structured API-based collection using 36 major report type endpoints

##### Collection Architecture:

**Data Source:**
- DART Open API (36 major report type endpoints)
- Universe: AI-sector stocks (modules/dart_disclosure/universe.ai-sector.template.json)

**36 Major Report Types (8 categories):**
1. 기업상태 (Company Status): 5 types
2. 증자감자 (Capital Changes): 4 types
3. 채권은행 (Creditor Bank): 2 types
4. 소송 (Litigation): 1 type
5. 해외상장 (Overseas Listing): 4 types
6. 사채발행 (Bond Issuance): 4 types
7. 자기주식 (Treasury Stock): 4 types
8. 영업/자산양수도 (Business/Asset Transfer): 4+ types

**Pipeline Flow:**
```
Universe (AI-sector stocks)
  → List of corp_codes
  → For each corp_code:
      - Collect 36 major report type APIs
      - Each API returns structured fields
  → Event extraction + Sentiment scoring
  → Storage: Local PostgreSQL
  → Neo4j: Event/Document nodes
```

**Storage:**
- Local PostgreSQL: Raw disclosure data, extracted events, sentiment scores
- Neo4j: Event nodes, Document nodes, relationships

**Schedule:**
- Daily collection (8:00 AM aligned with DART disclosure times)
```

**Section 3.4 - Daily Stock Price Collection (NEW):**
```markdown
#### Daily Stock Price Collection

**Purpose:** Provide historical price data for backtesting

**Data Source:** TBD (KIS OpenAPI or similar)
**Schedule:** Daily
**Storage:** Local PostgreSQL or time-series DB
**Scope:** All stocks in AI-sector universe
```

**Section 5.2 - Data Schemas (UPDATE):**
- Add `job_id` column to backtesting and portfolio tables
- Change status enum to Korean values
- Clarify storage location (remote vs local PostgreSQL)

---

### B) prd.md

**Functional Requirements (ADD):**
```markdown
**Daily Stock Price Collection (FR125):**
- FR125: System can collect daily stock price data for all universe stocks

**DART Disclosure Collection (FR126-FR127):**
- FR126: System can collect DART disclosures using 36 major report type APIs
- FR127: System can store DART disclosure data in local PostgreSQL with structured schemas

**Job Tracking (FR128-FR129):**
- FR128: Backtesting jobs include unique job_id for tracking and reference
- FR129: Portfolio recommendation jobs include unique job_id for tracking and reference

**Localization (FR130):**
- FR130: Status values use Korean enum (작업 전, 처리 중, 완료, 실패)
```

---

### C) epics.md

**Epic 1 - Event Intelligence:**

**Story 1.2 (REWRITE):**
```markdown
#### Story 1.2: DART Disclosure Collection using 36 Major Report Type APIs

**As a** system
**I want** to collect DART disclosures using 36 structured major report type APIs
**So that** event extraction has high-quality structured data

**Acceptance Criteria:**
- Collect 36 major report types for each corp_code in AI-sector universe
- Store raw disclosure data in local PostgreSQL
- Each report type has dedicated API endpoint and structured fields
- Daily schedule (8:00 AM)

**Technical Details:**
- 8 categories: 기업상태, 증자감자, 채권은행, 소송, 해외상장, 사채발행, 자기주식, 영업/자산양수도
- Source: modules/dart_disclosure/universe.ai-sector.template.json
- Storage: Local PostgreSQL (NOT remote AWS PostgreSQL)

**Files Affected:**
- /stockelper-airflow/dags/dart_disclosure_collection_dag.py (modified)
- /stockelper-kg/src/stockelper_kg/collectors/dart_major_reports.py (new)
```

**Story 1.8 (NEW):**
```markdown
#### Story 1.8: Daily Stock Price Data Collection

**As a** backtesting system
**I want** daily stock price data for all universe stocks
**So that** backtesting can calculate historical returns

**Acceptance Criteria:**
- Collect daily OHLCV data for AI-sector universe stocks
- Store in local PostgreSQL or time-series DB
- Daily schedule
- Data includes: open, high, low, close, volume, date

**Files Affected:**
- /stockelper-airflow/dags/daily_price_collection_dag.py (new)
```

**Epic 3 - Backtesting:**

**Story 3.1 (UPDATE):**
- Add `job_id` column to schema
- Change status enum to Korean
- Add execution time NFR (5min - 1hr)

---

### D) DART-implementation-analysis.md

**Section B (REWRITE):**
```markdown
## B) DART Disclosure Collection Status - 36 Major Report Types

### Current Implementation (2026-01-03):
✅ **36 Major Report Type API Collection**
- Based on 민우 1/3 work
- Structured endpoints per report type
- 8 categories, 36 total types
- Local PostgreSQL storage

### Pipeline Flow:
```
Universe (AI-sector) → corp_codes
  → 36 major report APIs per corp_code
  → Structured field extraction
  → Local PostgreSQL storage
  → Event extraction + sentiment
  → Neo4j (Event/Document nodes)
```

### Data Requirements:
[Table of 36 report types with fields]
```

---

### E) project_context.md

**Data Schema Updates:**
- Add `job_id` to unified data model
- Change status enum to Korean
- Clarify storage locations (remote vs local PostgreSQL)

---

### F) DAG Specifications (NEW DOCUMENT)

Create: `docs/dag-specifications.md`

```markdown
# Airflow DAG Specifications

## 1. DART Disclosure Collection DAG

**Name:** `dag_dart_disclosure_daily`
**Schedule:** Daily @ 8:00 AM KST
**Owner:** 영상

**Tasks:**
1. Load universe (AI-sector stocks)
2. For each corp_code:
   - Collect 36 major report type APIs
3. Store raw data → Local PostgreSQL
4. Trigger event extraction pipeline

**Output:** Local PostgreSQL tables (36 report type tables)

---

## 2. Daily Stock Price Collection DAG

**Name:** `dag_daily_price_collection`
**Schedule:** Daily @ market close
**Owner:** 영상

**Tasks:**
1. Load universe (AI-sector stocks)
2. Collect OHLCV data (KIS API or similar)
3. Store → Local PostgreSQL or time-series DB

**Output:** Price history table
```

---

## Update Priority

**CRITICAL (Must do first):**
1. architecture.md - DART section (36 types)
2. architecture.md - Daily price collection
3. architecture.md - Data schema updates (job_id, Korean status)
4. DART-implementation-analysis.md - Section B rewrite

**HIGH (Must do):**
5. PRD - Add FR125-FR130
6. epics.md - Rewrite Story 1.2, add Story 1.8
7. epics.md - Update Story 3.1 schema
8. project_context.md - Schema updates

**MEDIUM (Should do):**
9. Create dag-specifications.md
10. Update project-overview.md with repo separation

**Reference:**
11. Update meeting-analysis files with cross-references

---

**Estimated Effort:** 2-3 hours for all updates
