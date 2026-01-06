# Documentation Revision Plan - Based on 2025-01-06 Meeting
**Meeting Date:** 2025-01-05 20:00
**Document Created:** 2026-01-06
**Status:** 🔴 URGENT - Major Architectural Changes Required

---

## 📋 Executive Summary

**CRITICAL CHANGE:** News-based event extraction and sentiment analysis are **POSTPONED**. System will now use **DART disclosure categories directly as events** with extracted financial metrics for backtesting.

**Impact Level:** 🔴 **HIGH** - Requires substantial documentation revisions across PRD, Architecture, Epics, and Stories.

---

## 🚨 Key Changes from Meeting

### 1. **Approach Change: From LLM Event Extraction to Direct Category Usage**

**OLD Approach (Current Documentation):**
- ❌ Extract events from news data using LLM
- ❌ Extract sentiment scores (-1.0 to +1.0)
- ❌ Store events in knowledge graph with sentiment
- ❌ Use events + sentiment for backtesting

**NEW Approach (Meeting Decision):**
- ✅ Use DART disclosure **categories themselves as events**
- ✅ Extract **financial metrics** from each category (not sentiment)
- ✅ Store metrics in PostgreSQL (not Neo4j knowledge graph)
- ✅ Use metrics directly for backtesting

### 2. **News Data Collection - POSTPONED**

**Current Documentation Status:**
- ✅ Documented: Dual crawlers (Naver + Toss)
- ✅ Documented: LLM-based event extraction from news
- ✅ Documented: Sentiment scoring

**Meeting Decision:**
- ⏸️ **POSTPONE** all news data collection
- ⏸️ **POSTPONE** all news-based event extraction
- ⏸️ **POSTPONE** all sentiment analysis logic
- 📝 Keep ontology documentation for future use

### 3. **DART Disclosure Financial Metrics Extraction**

**NEW Requirements from Meeting:**
16 disclosure types (6, 7, 8, 9, 16, 17, 21-26, 29, 30, 33-36) with **specific financial metrics**:

**Categories:**
1. **증자/감자 (Capital Changes):** 4 types with metrics like 조달비율, 희석률, 배정비율
2. **전환사채/BW (Convertible Bonds):** 2 types with CB_발행비율, 전환희석률, BW_발행비율
3. **자기주식 (Treasury Stock):** 4 types with 취득금액비율, 처분금액비율, 신탁계약비율
4. **영업양수도 (Business Transfer):** 4 types with 양수가액비율, 자산비중
5. **타법인주식 (Other Company Stocks):** 2 types with 자기자본대비, 총자산대비
6. **합병/분할 (M&A):** 4 types with 합병비율, 분할비율, 교환이전비율

**Metrics Calculation:** Each metric calculated from DART API fields (e.g., `유상증자_조달비율 = fdpp_fclt / 시가총액`)

### 4. **Knowledge Graph Usage Change**

**OLD (Current Documentation):**
- Store extracted events in Neo4j
- Store sentiment scores
- Use for GraphRAG

**NEW (Meeting Decision):**
- Store DART disclosure categories + financial metrics
- Use for GraphRAG (future)
- Neo4j DAG needs update for new ontology

### 5. **Backtesting Changes**

**OLD:**
- Backtest using events + sentiment scores

**NEW:**
- Backtest using **financial metrics** from DART disclosures
- User can specify backtesting conditions based on metrics
- (Future) Agent decides backtesting conditions

### 6. **Airflow DAG Changes**

**TO REMOVE:**
- ❌ News event extraction DAG
- ❌ Sentiment extraction DAG
- ❌ Any DAG related to news-based events

**TO UPDATE:**
- ✅ DART collection DAG (already daily)
- ✅ Neo4j knowledge graph loading DAG (update with new ontology)

**TO ADD:**
- ✅ DART financial metrics extraction DAG

---

## 🎯 Priority-Ordered Revision Tasks

### Priority 1: CRITICAL - Remove/Postpone News-Based Features (IMMEDIATE)

#### Task 1.1: Update PRD - Remove News Event Extraction
**Files:** `docs/prd.md`

**Changes Required:**
- ⏸️ Mark FR1a-FR1f (dual crawlers) as **POSTPONED**
- ⏸️ Mark FR2a-FR2h (LLM extraction, sentiment) as **POSTPONED** for news data
- ✅ Keep FR2 structure but clarify: applies **ONLY to DART disclosures**
- ❌ Remove sentiment scoring (-1.0 to +1.0) from all FRs
- ✅ Add NEW FR section: **DART Financial Metrics Extraction (FR2i-FR2z)**
  - FR2i: Extract 16 disclosure types with financial metrics
  - FR2j: Calculate metrics per disclosure type (full table from meeting)
  - FR2k: Store metrics in PostgreSQL (not Neo4j)
  - FR2l: Use metrics for backtesting (not sentiment)

**Estimated Impact:** 🔴 HIGH - 50+ FRs affected

---

#### Task 1.2: Update Architecture - Remove News Pipeline
**Files:** `docs/architecture.md`

**Changes Required:**
- ❌ Remove Repository 1 sections related to news crawlers (Naver + Toss)
- ❌ Remove LLM-based event extraction from news
- ❌ Remove sentiment scoring architecture
- ⏸️ Mark MongoDB collections (naver_stock_news, toss_stock_news) as **POSTPONED**
- ⏸️ Mark PostgreSQL `dart_event_extractions` table as **POSTPONED** (or repurpose for metrics)
- ✅ Add NEW section: **DART Financial Metrics Extraction Architecture**
  - Metric calculation logic per disclosure type
  - PostgreSQL storage schema for metrics
  - Integration with backtesting service

**Estimated Impact:** 🔴 HIGH - Major section removal/rewrite

---

#### Task 1.3: Update Epics - Postpone Epic 1 Stories
**Files:** `docs/epics.md`

**Changes Required:**
- ⏸️ Mark **Story 1.1a (News Event Extraction)** as **POSTPONED**
- ✅ Update **Story 1.1b (DART Collection)** to include metrics extraction
  - Update acceptance criteria with 16 disclosure types + metrics
  - Add metrics calculation logic
  - Update database schema (PostgreSQL table for metrics)
- ❌ Remove LangGraph Multi-Agent System references to news/sentiment (keep DART focus)
- ✅ Update Epic 1 implementation notes to clarify DART-only scope

**Estimated Impact:** 🔴 HIGH - Story 1.1a complete rewrite

---

### Priority 2: HIGH - Add DART Financial Metrics Extraction

#### Task 2.1: Add DART Metrics FR Section to PRD
**Files:** `docs/prd.md`

**New FRs to Add (FR2i-FR2z):**
- FR2i: System extracts financial metrics from 16 DART disclosure types
- FR2j: System calculates disclosure-specific metrics (증자조달비율, CB발행비율, etc.)
- FR2k: System stores metrics in PostgreSQL with disclosure metadata
- FR2l: Metrics available for backtesting condition specification
- FR2m: System supports user-defined backtesting conditions based on metrics
- FR2n: (Future) Agent recommends optimal backtesting conditions

**Metric Details Table:**
Include full metrics table from meeting (lines 58-135 of meeting notes)

**Estimated Impact:** 🟡 MEDIUM - Add ~15-20 new FRs

---

#### Task 2.2: Add DART Metrics Architecture Section
**Files:** `docs/architecture.md`

**New Section to Add:**
```
Repository 1b: DART Financial Metrics Extraction

**Purpose:** Extract and calculate disclosure-specific financial metrics

**Architecture:**
- Input: DART API data (20 disclosure types, focus on 16 for backtesting)
- Processing: Metric calculation engine per disclosure type
- Output: PostgreSQL table with calculated metrics

**Metric Calculation Engine:**
- 증자/감자: 조달비율, 희석률, 배정비율, 감자비율
- 전환사채/BW: CB발행비율, 전환희석률, BW발행비율, BW희석률
- 자기주식: 취득금액비율, 처분금액비율, 신탁계약비율
- 영업양수도: 양수가액비율, 자산비중
- 타법인주식: 자기자본대비, 총자산대비
- 합병/분할: 합병비율, 분할비율, 교환이전비율

**Database Schema:**
```sql
CREATE TABLE dart_disclosure_metrics (
    id SERIAL PRIMARY KEY,
    rcept_no VARCHAR(20) NOT NULL,
    corp_code VARCHAR(8) NOT NULL,
    stock_code VARCHAR(6) NOT NULL,
    disclosure_type VARCHAR(50) NOT NULL,  -- e.g., "유상증자결정"
    disclosure_type_code INT NOT NULL,     -- 6, 7, 8, 9, 16, 17, etc.
    metrics JSONB NOT NULL,                 -- {"유상증자_조달비율": 0.15, "희석률": 0.05}
    market_cap DECIMAL(20,2),
    rcept_dt DATE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    INDEX idx_metrics_stock_date (stock_code, rcept_dt DESC),
    INDEX idx_metrics_type (disclosure_type_code),
    INDEX idx_metrics_rcept (rcept_no)
);
```
```

**Estimated Impact:** 🟡 MEDIUM - Add new repository section

---

#### Task 2.3: Add DART Metrics Story to Epic 1
**Files:** `docs/epics.md`

**New Story to Add:**
```
#### Story 1.1c: DART Financial Metrics Extraction and Storage

**As a** backtesting system
**I want** to extract financial metrics from DART disclosures
**So that** I can use these metrics for event-based backtesting

**Acceptance Criteria:**

**Given** DART disclosure data collected in PostgreSQL (20 types)
**When** the metrics extraction pipeline executes
**Then** the following conditions are met:

**Metric Extraction (16 Disclosure Types):**
- System identifies disclosure type from API response
- System extracts required fields per disclosure type (from meeting table)
- System calculates metrics using formulas (e.g., 조달비율 = fdpp_fclt / 시가총액)
- System stores metrics in PostgreSQL `dart_disclosure_metrics` table
- Metrics stored as JSONB for flexibility

**Supported Metrics by Category:**
1. 증자/감자 (6,7,8,9): 조달비율, 희석률, 배정비율, 감자비율
2. 전환사채/BW (16,17): CB발행비율, 전환희석률, BW발행비율, BW희석률
3. 자기주식 (21-24): 취득금액비율, 처분금액비율, 신탁계약비율, 신탁해지비율
4. 영업양수도 (25-26): 양수가액비율, 양도가액비율, 자산비중
5. 타법인주식 (29-30): 자기자본대비, 총자산대비
6. 합병/분할 (33-36): 합병비율, 분할비율, 교환이전비율

**Airflow DAG:**
- Daily execution after DART collection DAG
- Process all newly collected disclosures
- Update metrics for modified disclosures
- Retry failed calculations up to 3 times

**Files affected:**
- `/stockelper-kg/src/stockelper_kg/extractors/dart_metrics_extractor.py` (NEW)
- `/stockelper-kg/src/stockelper_kg/calculators/` (NEW directory with metric calculators)
- `/stockelper-airflow/dags/dart_metrics_extraction_dag.py` (NEW)
- `/stockelper-kg/migrations/004_create_dart_metrics_table.sql` (NEW)
```

**Estimated Impact:** 🟡 MEDIUM - Add new story with detailed acceptance criteria

---

### Priority 3: MEDIUM - Update Backtesting to Use Metrics

#### Task 3.1: Update Backtesting FR in PRD
**Files:** `docs/prd.md`

**Changes Required:**
- ✅ Update FR39 series to clarify backtesting uses **financial metrics** (not sentiment)
- ✅ Add FR39s: User can specify backtesting conditions based on disclosure metrics
- ✅ Add FR39t: System supports metric-based filtering (e.g., "유상증자_조달비율 > 0.1")
- ✅ Add FR39u: System calculates returns following metric-based events

**Estimated Impact:** 🟢 LOW - Minor clarifications

---

#### Task 3.2: Update Backtesting Architecture
**Files:** `docs/architecture.md`

**Changes Required:**
- ✅ Update Repository 7 to show integration with `dart_disclosure_metrics` table
- ✅ Add metric-based filtering logic to backtesting executor
- ✅ Update backtesting input schema to include metric conditions

**Estimated Impact:** 🟢 LOW - Minor updates

---

#### Task 3.3: Update Backtesting Story 3.2
**Files:** `docs/epics.md`

**Changes Required:**
- ✅ Update Story 3.2 (Event-Based Strategy Simulator) acceptance criteria
- ✅ Change from "similar events" to "metric-based conditions"
- ✅ Add examples: "Backtest stocks with 유상증자_조달비율 > 0.1"

**Estimated Impact:** 🟢 LOW - Minor acceptance criteria updates

---

### Priority 4: LOW - Update Infrastructure Documentation

#### Task 4.1: Update Deployment Architecture
**Files:** `docs/architecture.md`

**Changes Required:**
- ✅ Add Portfolio API location: Local server (230 server)
- ✅ Add Backtest API location: To be implemented on local server
- ✅ Clarify PostgreSQL split:
  - t3.medium: User data, portfolio results, backtest results
  - Local (230): DART disclosures, stock prices, metrics

**Estimated Impact:** 🟢 LOW - Infrastructure clarifications

---

#### Task 4.2: Remove News-Related Airflow DAGs from Documentation
**Files:** `docs/architecture.md`, `docs/epics.md`

**Changes Required:**
- ❌ Remove documentation for news event extraction DAG
- ❌ Remove documentation for sentiment extraction DAG
- ✅ Keep DART collection DAG (daily)
- ✅ Update Neo4j loading DAG to use new ontology

**Estimated Impact:** 🟢 LOW - Remove obsolete DAG references

---

## 📊 Summary of Documentation Changes

| Document | Changes | Impact | Priority |
|----------|---------|--------|----------|
| **PRD** | Remove news FRs, Add metrics FRs | 🔴 HIGH | P1 |
| **Architecture** | Remove news pipeline, Add metrics extraction | 🔴 HIGH | P1 |
| **Epics** | Postpone Story 1.1a, Add Story 1.1c | 🔴 HIGH | P1-P2 |
| **Stories** | Update acceptance criteria for backtesting | 🟡 MEDIUM | P3 |
| **Infrastructure** | Update deployment details | 🟢 LOW | P4 |

**Overall Impact:** 🔴 **HIGH** - 30-40% of current documentation requires revision

---

## 🔄 Migration Strategy

### Phase 1: Document Postponement (Immediate)
1. Add "POSTPONED" markers to all news-related sections
2. Add meeting reference note explaining postponement
3. Keep content for future reference

### Phase 2: Add New Requirements (Week 1)
1. Add DART metrics FRs to PRD
2. Add metrics extraction architecture
3. Add Story 1.1c to Epic 1

### Phase 3: Update Dependencies (Week 1-2)
1. Update backtesting to use metrics
2. Update Airflow DAG documentation
3. Update infrastructure details

### Phase 4: Final Verification (Week 2)
1. Cross-check all documents for consistency
2. Update consistency verification report
3. Commit all changes

---

## ✅ Acceptance Criteria for Revision

- [ ] All news-related FRs marked as POSTPONED with clear explanation
- [ ] DART financial metrics extraction fully documented (FRs, Architecture, Story)
- [ ] Backtesting updated to use metrics instead of sentiment
- [ ] All file paths and database schemas updated
- [ ] Airflow DAG documentation reflects actual implementation
- [ ] Consistency verification report updated
- [ ] All commits reference meeting date (2025-01-06) for traceability

---

**Status:** 🔴 **DRAFT - AWAITING APPROVAL TO PROCEED**

**Next Action:** Begin Priority 1 tasks (Remove/Postpone news-based features)
