# Cursor AI Prompts for Documentation Revisions (2025-01-06 Meeting)

**Reference Documents:**
- Meeting Notes: `docs/references/20250106.md`
- Revision Plan: `docs/REVISION-PLAN-20250106.md`
- Current PRD: `docs/prd.md`
- Current Architecture: `docs/architecture.md`
- Current Epics: `docs/epics.md`

---

## Priority 1: CRITICAL - Remove/Postpone News-Based Features

### Cursor Prompt 1.1: Update PRD - Postpone News Features

```
@prd.md 

TASK: Update PRD to postpone all news-based event extraction features based on 2025-01-06 meeting decision.

CONTEXT:
Meeting decided to POSTPONE all news data collection and sentiment analysis. System will now use DART disclosure categories directly as events with financial metrics.

CHANGES REQUIRED:

1. **Mark as POSTPONED (add section header before each):**
   - Add "**[POSTPONED - 2025-01-06]**" marker before:
     - FR1a-FR1f (dual crawlers - Naver + Toss)
     - All sentiment scoring references (-1.0 to +1.0)
   
2. **Update FR2 series:**
   - Keep FR2 main description but add clarification:
     "**Note:** This requirement currently applies ONLY to DART disclosures. News-based event extraction is POSTPONED (2025-01-06 meeting)."
   - Mark FR2a-FR2h as POSTPONED for news data:
     - FR2a: LLM-based extraction (POSTPONED for news, active for DART)
     - FR2f: Pre-classification rules (POSTPONED for news)
     - FR2g: Slot validation (POSTPONED for news)
     - FR2h: PostgreSQL dart_event_extractions (POSTPONED)

3. **Add POSTPONEMENT Notice Section:**
   After the "Current System Capabilities" section, add:
   ```markdown
   ## ⏸️ POSTPONED Features (2025-01-06 Meeting)
   
   The following features have been postponed based on architectural decisions made in the 2025-01-06 meeting:
   
   **News-Based Event Extraction:**
   - Dual news crawlers (Naver + Toss): FR1a-FR1f
   - LLM-based event extraction from news: FR2a (news portion)
   - Sentiment scoring from news articles: All references
   - MongoDB storage for news: Collections postponed
   
   **Rationale:**
   System will initially use DART disclosure categories directly as events with calculated financial metrics. News-based extraction will be implemented in future phases.
   
   **Future Scope:**
   - News crawler ontology documentation preserved for future implementation
   - Sentiment analysis logic preserved for future use
   - MongoDB collections can be activated when news features resume
   ```

4. **Remove sentiment scoring from all FRs:**
   - Search for "sentiment score (-1 to 1)" and mark as POSTPONED
   - Search for "sentiment" and review each occurrence

VERIFICATION:
- All news-related FRs clearly marked as POSTPONED
- FR2 series updated with clarification
- New POSTPONED section added with meeting reference
- No broken FR references

Generate the updated PRD sections.
```

---

### Cursor Prompt 1.2: Add DART Financial Metrics FRs to PRD

```
@prd.md @/docs/references/20250106.md

TASK: Add comprehensive DART Financial Metrics Extraction requirements to PRD.

CONTEXT:
Meeting specified 16 DART disclosure types with calculated financial metrics (not sentiment) for backtesting. Each disclosure type has specific metric calculation formulas.

ADD NEW FR SECTION (after FR2h):

**FR2i-FR2z: DART Financial Metrics Extraction**

- **FR2i:** System extracts financial metrics from 16 DART disclosure types for backtesting
- **FR2j:** System calculates disclosure-specific metrics using API-provided fields
- **FR2k:** System stores calculated metrics in PostgreSQL `dart_disclosure_metrics` table
- **FR2l:** Metrics available for backtesting condition specification
- **FR2m:** System supports user-defined backtesting conditions based on metrics
- **FR2n:** (Future) System recommends optimal backtesting conditions using agent

**FR2i-1: 증자/감자 Metrics (Disclosure Types 6, 7, 8, 9):**
- **FR2i-1a:** 유상증자_조달비율 = (fdpp_fclt + fdpp_op + fdpp_dtrp + fdpp_ocsa + fdpp_etc) / 시가총액
- **FR2i-1b:** 유상증자_희석률 = nstk_ostk_cnt / bfic_tisstk_ostk
- **FR2i-1c:** 무상증자_배정비율 = nstk_ascnt_ps_ostk
- **FR2i-1d:** 감자_비율 = cr_rt_ostk (from API)
- **FR2i-1e:** 자본금_감소율 = (bfcr_cpt - atcr_cpt) / bfcr_cpt

**FR2i-2: 전환사채/BW Metrics (Disclosure Types 16, 17):**
- **FR2i-2a:** CB_발행비율 = bd_fta / 시가총액
- **FR2i-2b:** CB_전환희석률 = cvisstk_tisstk_vs (from API)
- **FR2i-2c:** 전환가_괴리율 = (현재주가 - cv_prc) / 현재주가
- **FR2i-2d:** BW_발행비율 = bd_fta / 시가총액
- **FR2i-2e:** BW_희석률 = nstk_isstk_tisstk_vs (from API)

**FR2i-3: 자기주식 Metrics (Disclosure Types 21-24):**
- **FR2i-3a:** 자사주_취득금액비율 = aqpln_prc_ostk / 시가총액
- **FR2i-3b:** 자사주_취득주식비율 = aqpln_stk_ostk / 발행주식총수
- **FR2i-3c:** 자사주_처분금액비율 = dppln_prc_ostk / 시가총액
- **FR2i-3d:** 자사주_처분주식비율 = dppln_stk_ostk / 발행주식총수
- **FR2i-3e:** 자사주신탁_체결비율 = ctr_prc / 시가총액
- **FR2i-3f:** 자사주신탁_해지비율 = ctr_prc_bfcc / 시가총액

**FR2i-4: 영업양수도 Metrics (Disclosure Types 25-26):**
- **FR2i-4a:** 영업양수_비율 = inh_prc / 시가총액
- **FR2i-4b:** 영업양수_자산비중 = ast_rt (from API)
- **FR2i-4c:** 영업양도_비율 = trf_prc / 시가총액
- **FR2i-4d:** 영업양도_자산비중 = ast_rt (from API)

**FR2i-5: 타법인주식 Metrics (Disclosure Types 29-30):**
- **FR2i-5a:** 타법인양수_금액비율 = inhdtl_inhprc / 시가총액
- **FR2i-5b:** 타법인양수_총자산대비 = inhdtl_tast_vs (from API)
- **FR2i-5c:** 타법인양수_자기자본대비 = inhdtl_ecpt_vs (from API)
- **FR2i-5d:** 타법인양도_금액비율 = trfdtl_trfprc / 시가총액
- **FR2i-5e:** 타법인양도_총자산대비 = trfdtl_tast_vs (from API)

**FR2i-6: 합병/분할 Metrics (Disclosure Types 33-36):**
- **FR2i-6a:** 합병_비율 = mg_rt (from API)
- **FR2i-6b:** 피합병사_자본대비 = rbsnfdtl_teqt / 당사_자기자본
- **FR2i-6c:** 분할_비율 = dv_rt (from API)
- **FR2i-6d:** 분할후_자본비율 = ffdtl_teqt / atdvfdtl_teqt
- **FR2i-6e:** 분할합병_비율 = dvmg_rt (from API)
- **FR2i-6f:** 주식교환이전_비율 = extr_rt (from API)

**FR2k: Metrics Storage Schema:**
- Table: `dart_disclosure_metrics`
- Fields: id, rcept_no, corp_code, stock_code, disclosure_type, disclosure_type_code, metrics (JSONB), market_cap, rcept_dt, created_at
- Indexes: (stock_code, rcept_dt), disclosure_type_code, rcept_no

**FR2l: Backtesting Integration:**
- Metrics accessible via backtesting API
- Support metric-based filtering (e.g., "유상증자_조달비율 > 0.1")
- Calculate returns following metric-triggering disclosures

**FR2m: User-Defined Conditions:**
- Users specify metric thresholds for backtesting
- Example: "Backtest stocks where 유상증자_조달비율 > 0.1 AND 희석률 < 0.05"

**FR2n: Agent-Recommended Conditions (Future):**
- Agent analyzes historical data to suggest optimal metric thresholds
- Provides confidence scores for recommended conditions

VERIFICATION:
- All 16 disclosure types covered
- All metric formulas match meeting notes (lines 58-135)
- FR numbering sequential (FR2i through FR2n with sub-numbering)
- Database schema specified

Generate the new FR section.
```

---

### Cursor Prompt 1.3: Update Architecture - Remove News Pipeline

```
@architecture.md @/docs/references/20250106.md

TASK: Remove/postpone news-based pipeline sections and add POSTPONEMENT notices.

CHANGES REQUIRED:

1. **Add POSTPONEMENT Notice (after Table of Contents):**
   ```markdown
   ## ⏸️ POSTPONED FEATURES (2025-01-06 Meeting)
   
   **News-Based Event Extraction Pipeline:**
   The following sections describe features that have been POSTPONED based on 2025-01-06 meeting decisions:
   - Dual news crawlers (Naver + Toss)
   - LLM-based event extraction from news
   - Sentiment scoring architecture
   - MongoDB news storage
   
   These sections are preserved for future implementation reference.
   
   **Current Focus:** DART disclosure financial metrics extraction (see Repository 1b)
   ```

2. **Mark Repository 1 News Sections as POSTPONED:**
   - Find sections describing:
     - Naver mobile API crawler
     - Toss RESTful API crawler
     - MongoDB `naver_stock_news` collection
     - MongoDB `toss_stock_news` collection
     - LLM-based event extraction from news
     - Sentiment scoring (-1.0 to +1.0)
   - Add "**[POSTPONED - 2025-01-06]**" header before each section
   - Keep content intact for future reference

3. **Update PostgreSQL dart_event_extractions Table Status:**
   - Mark as POSTPONED or note it will be repurposed for metrics
   - Add comment: "To be replaced/repurposed as dart_disclosure_metrics (see Repository 1b)"

VERIFICATION:
- All news-related sections clearly marked as POSTPONED
- Content preserved (not deleted)
- Meeting reference date (2025-01-06) visible
- Clear direction to new metrics section (Repository 1b)

Generate the updated Architecture sections.
```

---

## Priority 2: HIGH - Add DART Financial Metrics Extraction

### Cursor Prompt 2.1: Add DART Metrics Architecture Section

```
@architecture.md @/docs/references/20250106.md @prd.md

TASK: Add comprehensive DART Financial Metrics Extraction architecture section.

ADD NEW SECTION (Repository 1b - after Repository 1):

```markdown
## Repository 1b: DART Financial Metrics Extraction (NEW - 2025-01-06)

**Purpose:** Extract and calculate disclosure-specific financial metrics from DART API data for backtesting.

**Status:** 🆕 New requirement from 2025-01-06 meeting
**Priority:** HIGH - Critical for backtesting functionality

### Overview

Instead of extracting generic "events" with sentiment scores, the system calculates specific financial metrics from each DART disclosure type. These metrics are quantitative indicators (ratios, percentages) that measure the financial impact of corporate actions.

**Key Difference from Previous Approach:**
- ❌ OLD: Extract events → Assign sentiment → Use for backtesting
- ✅ NEW: Calculate metrics → Store quantitative values → Use for backtesting

### Architecture Diagram

```
[DART API] → [Metrics Calculator] → [PostgreSQL: dart_disclosure_metrics]
                    ↓
         [16 Disclosure Types]
                    ↓
    [Type-Specific Metric Formulas]
                    ↓
         [JSONB Storage with Metadata]
```

### Supported Disclosure Types and Metrics

**Category 1: 증자/감자 (Capital Changes) - Types 6, 7, 8, 9**

| Type | Name | Metrics Calculated |
|------|------|-------------------|
| 6 | 유상증자결정 | 조달비율, 희석률 |
| 7 | 무상증자결정 | 배정비율 |
| 8 | 유무상증자결정 | 조달비율, 희석률, 배정비율 |
| 9 | 감자결정 | 감자비율, 자본금감소율 |

**Calculation Examples (Type 6 - 유상증자):**
```python
# 유상증자_조달비율
조달금액 = fdpp_fclt + fdpp_op + fdpp_dtrp + fdpp_ocsa + fdpp_etc
조달비율 = 조달금액 / 시가총액

# 유상증자_희석률
희석률 = nstk_ostk_cnt / bfic_tisstk_ostk
```

**Category 2: 전환사채/BW (Convertible Bonds) - Types 16, 17**

| Type | Name | Metrics Calculated |
|------|------|-------------------|
| 16 | 전환사채발행결정 | CB_발행비율, CB_전환희석률, 전환가_괴리율 |
| 17 | 신주인수권부사채발행결정 | BW_발행비율, BW_희석률 |

**Calculation Examples (Type 16 - CB):**
```python
# CB_발행비율
CB_발행비율 = bd_fta / 시가총액

# CB_전환희석률 (from API)
CB_전환희석률 = cvisstk_tisstk_vs

# 전환가_괴리율
전환가_괴리율 = (현재주가 - cv_prc) / 현재주가
```

**Category 3: 자기주식 (Treasury Stock) - Types 21-24**

| Type | Name | Metrics Calculated |
|------|------|-------------------|
| 21 | 자기주식취득결정 | 취득금액비율, 취득주식비율 |
| 22 | 자기주식처분결정 | 처분금액비율, 처분주식비율 |
| 23 | 자기주식신탁계약체결결정 | 신탁체결비율 |
| 24 | 자기주식신탁계약해지결정 | 신탁해지비율 |

**Category 4: 영업양수도 (Business Transfer) - Types 25-26**

| Type | Name | Metrics Calculated |
|------|------|-------------------|
| 25 | 영업양수결정 | 양수가액비율, 자산비중 |
| 26 | 영업양도결정 | 양도가액비율, 자산비중 |

**Category 5: 타법인주식 (Other Company Stocks) - Types 29-30**

| Type | Name | Metrics Calculated |
|------|------|-------------------|
| 29 | 타법인주식양수결정 | 금액비율, 총자산대비, 자기자본대비 |
| 30 | 타법인주식양도결정 | 금액비율, 총자산대비 |

**Category 6: 합병/분할 (M&A) - Types 33-36**

| Type | Name | Metrics Calculated |
|------|------|-------------------|
| 33 | 회사합병결정 | 합병비율, 피합병사자본대비 |
| 34 | 회사분할결정 | 분할비율, 분할후자본비율 |
| 35 | 회사분할합병결정 | 분할합병비율 |
| 36 | 주식교환이전결정 | 교환이전비율 |

### Database Schema

```sql
CREATE TABLE dart_disclosure_metrics (
    id SERIAL PRIMARY KEY,
    rcept_no VARCHAR(20) NOT NULL UNIQUE,
    corp_code VARCHAR(8) NOT NULL,
    stock_code VARCHAR(6) NOT NULL,
    disclosure_type VARCHAR(100) NOT NULL,      -- e.g., "유상증자결정"
    disclosure_type_code INT NOT NULL,          -- 6, 7, 8, 9, 16, 17, etc.
    metrics JSONB NOT NULL,                     -- {"유상증자_조달비율": 0.15, "희석률": 0.05}
    market_cap DECIMAL(20,2),                   -- 시가총액 at disclosure date
    rcept_dt DATE NOT NULL,                     -- Disclosure date
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_metrics_stock_date ON dart_disclosure_metrics(stock_code, rcept_dt DESC);
CREATE INDEX idx_metrics_type ON dart_disclosure_metrics(disclosure_type_code);
CREATE INDEX idx_metrics_rcept ON dart_disclosure_metrics(rcept_no);

-- Example JSONB content:
{
  "유상증자_조달비율": 0.152,
  "유상증자_희석률": 0.048,
  "계산일시": "2025-01-06T10:00:00",
  "시가총액": 150000000000,
  "신주수": 5000000,
  "증자전발행주식수": 100000000
}
```

### Metric Calculator Service

**Architecture:**
```
MetricsExtractor
├── TypeIdentifier: Identify disclosure_type_code from API response
├── FieldExtractor: Extract required fields per type
├── MetricCalculator: Apply type-specific formulas
│   ├── CapitalChangeCalculator (Types 6-9)
│   ├── ConvertibleBondCalculator (Types 16-17)
│   ├── TreasuryStockCalculator (Types 21-24)
│   ├── BusinessTransferCalculator (Types 25-26)
│   ├── OtherCompanyStockCalculator (Types 29-30)
│   └── MergerCalculator (Types 33-36)
└── MetricsPersistence: Store in PostgreSQL
```

**Processing Flow:**
1. Read newly collected DART disclosure from PostgreSQL (20 types)
2. Identify if disclosure_type_code is in target list (6,7,8,9,16,17,21-26,29,30,33-36)
3. If yes:
   a. Extract required fields from API response JSON
   b. Retrieve current market cap from daily_stock_prices table
   c. Calculate metrics using type-specific formulas
   d. Validate calculated metrics (non-negative, reasonable ranges)
   e. Store in dart_disclosure_metrics table with JSONB
4. If no: Skip (not a backtesting-relevant disclosure)

### Airflow DAG: DART Metrics Extraction

**DAG Name:** `dart_metrics_extraction_dag`
**Schedule:** Daily at 9:00 PM KST (after DART collection DAG)
**Dependencies:** Requires `dart_disclosure_collection_dag` to complete first

**Tasks:**
1. `check_new_disclosures`: Query for unprocessed disclosures
2. `extract_metrics_parallel`: Process disclosures in parallel (batch size: 100)
3. `validate_metrics`: Check for calculation errors
4. `update_knowledge_graph`: (Optional) Update Neo4j with metrics
5. `cleanup`: Mark processed disclosures

**Error Handling:**
- Retry up to 3 times with exponential backoff
- Log failed disclosures to separate error table
- Alert on >10% failure rate

### Integration with Backtesting

**Backtesting Service Queries Metrics:**
```sql
-- Example: Find all 유상증자 events with 조달비율 > 10%
SELECT 
    stock_code,
    rcept_dt,
    metrics->>'유상증자_조달비율' AS 조달비율,
    metrics->>'유상증자_희석률' AS 희석률
FROM dart_disclosure_metrics
WHERE disclosure_type_code = 6
  AND (metrics->>'유상증자_조달비율')::NUMERIC > 0.10
ORDER BY rcept_dt DESC;
```

**User-Defined Backtesting Conditions:**
- Users specify: "Backtest stocks with 유상증자_조달비율 > 0.1 AND 희석률 < 0.05"
- System translates to SQL query on dart_disclosure_metrics
- Returns: List of (stock_code, rcept_dt) matching conditions
- Calculates returns: 1, 3, 6, 12 months after rcept_dt

### File Locations

**New Files (to be created):**
- `/stockelper-kg/src/stockelper_kg/extractors/dart_metrics_extractor.py`
- `/stockelper-kg/src/stockelper_kg/calculators/capital_change_calculator.py`
- `/stockelper-kg/src/stockelper_kg/calculators/convertible_bond_calculator.py`
- `/stockelper-kg/src/stockelper_kg/calculators/treasury_stock_calculator.py`
- `/stockelper-kg/src/stockelper_kg/calculators/business_transfer_calculator.py`
- `/stockelper-kg/src/stockelper_kg/calculators/other_company_stock_calculator.py`
- `/stockelper-kg/src/stockelper_kg/calculators/merger_calculator.py`
- `/stockelper-airflow/dags/dart_metrics_extraction_dag.py`
- `/stockelper-kg/migrations/004_create_dart_metrics_table.sql`

**Configuration:**
- `/stockelper-kg/config/metrics_config.yaml` - Metric formulas and validation rules

### Port and Deployment

- **Service:** Part of stockelper-kg on Local Server (230)
- **Database:** Local PostgreSQL
- **Airflow:** Local Airflow instance

### Performance Considerations

- **Processing Time:** ~1-2 minutes for 100 disclosures
- **Database Size:** Estimated 10,000-20,000 metrics/year
- **Query Performance:** Indexed on (stock_code, rcept_dt) for fast backtesting queries

### Future Enhancements

1. **Agent-Recommended Conditions (FR2n):**
   - Analyze historical metric distributions
   - Recommend optimal thresholds for backtesting
   - Provide confidence scores

2. **Knowledge Graph Integration:**
   - Store metrics in Neo4j for GraphRAG
   - Enable complex relationship queries

3. **Real-Time Alerts:**
   - Monitor newly calculated metrics
   - Alert users when metrics exceed thresholds

---
```

VERIFICATION:
- All 16 disclosure types documented
- Complete database schema with indexes
- Processing flow clearly explained
- Integration with backtesting specified
- File locations provided

Generate the new Repository 1b section.
```

---

### Cursor Prompt 2.2: Add DART Metrics Story to Epics

```
@epics.md @/docs/references/20250106.md @architecture.md

TASK: Add comprehensive Story 1.1c for DART Financial Metrics Extraction.

ADD NEW STORY (after Story 1.1b in Epic 1):

```markdown
---

#### Story 1.1c: DART Financial Metrics Extraction and Storage (NEW - 2025-01-06)

**Status:** 🆕 New (2025-01-06 meeting)
**Priority:** HIGH
**Dependencies:** Story 1.1b (DART Collection)

**As a** backtesting system
**I want** to extract and calculate financial metrics from DART disclosures
**So that** I can use quantitative indicators for event-based backtesting strategies

**Acceptance Criteria:**

**Given** DART disclosure data collected in PostgreSQL (20 types from Story 1.1b)
**When** the DART metrics extraction pipeline executes daily
**Then** the following conditions are met:

**Metric Extraction Pipeline (16 Target Disclosure Types):**
- System identifies disclosure_type_code from collected DART data
- System checks if code is in target list: 6, 7, 8, 9, 16, 17, 21, 22, 23, 24, 25, 26, 29, 30, 33, 34, 35, 36
- If target disclosure:
  - Extract required API fields per disclosure type
  - Retrieve current market cap from `daily_stock_prices` table
  - Calculate type-specific metrics using formulas
  - Validate calculated values (non-negative, reasonable ranges)
  - Store in `dart_disclosure_metrics` table with JSONB
- If non-target disclosure: Skip processing (log and continue)

**Supported Metrics by Category (FR2i-1 through FR2i-6):**

**1. 증자/감자 (Types 6, 7, 8, 9):**
- Type 6 (유상증자): 조달비율, 희석률
- Type 7 (무상증자): 배정비율
- Type 8 (유무상증자): 조달비율, 희석률, 배정비율 (combined)
- Type 9 (감자): 감자비율, 자본금감소율

**Calculation Formulas (Type 6 example):**
```python
# 유상증자_조달비율
조달금액 = fdpp_fclt + fdpp_op + fdpp_dtrp + fdpp_ocsa + fdpp_etc
조달비율 = 조달금액 / 시가총액

# 유상증자_희석률
희석률 = nstk_ostk_cnt / bfic_tisstk_ostk
```

**2. 전환사채/BW (Types 16, 17):**
- Type 16 (CB): CB_발행비율, CB_전환희석률, 전환가_괴리율
- Type 17 (BW): BW_발행비율, BW_희석률

**3. 자기주식 (Types 21-24):**
- Type 21: 취득금액비율, 취득주식비율
- Type 22: 처분금액비율, 처분주식비율
- Type 23: 신탁체결비율
- Type 24: 신탁해지비율

**4. 영업양수도 (Types 25-26):**
- Type 25: 양수가액비율, 자산비중
- Type 26: 양도가액비율, 자산비중

**5. 타법인주식 (Types 29-30):**
- Type 29: 금액비율, 총자산대비, 자기자본대비
- Type 30: 금액비율, 총자산대비

**6. 합병/분할 (Types 33-36):**
- Type 33: 합병비율, 피합병사자본대비
- Type 34: 분할비율, 분할후자본비율
- Type 35: 분할합병비율
- Type 36: 교환이전비율

**Database Storage:**
- Table: `dart_disclosure_metrics`
- Schema:
  ```sql
  CREATE TABLE dart_disclosure_metrics (
      id SERIAL PRIMARY KEY,
      rcept_no VARCHAR(20) NOT NULL UNIQUE,
      corp_code VARCHAR(8) NOT NULL,
      stock_code VARCHAR(6) NOT NULL,
      disclosure_type VARCHAR(100) NOT NULL,
      disclosure_type_code INT NOT NULL,
      metrics JSONB NOT NULL,
      market_cap DECIMAL(20,2),
      rcept_dt DATE NOT NULL,
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW()
  );
  ```
- Indexes:
  - `idx_metrics_stock_date` on (stock_code, rcept_dt DESC)
  - `idx_metrics_type` on disclosure_type_code
  - `idx_metrics_rcept` on rcept_no

**JSONB Metrics Format:**
```json
{
  "유상증자_조달비율": 0.152,
  "유상증자_희석률": 0.048,
  "계산일시": "2025-01-06T10:00:00Z",
  "시가총액": 150000000000,
  "신주수": 5000000,
  "증자전발행주식수": 100000000,
  "API필드": {
    "fdpp_fclt": 10000000000,
    "fdpp_op": 5000000000,
    "nstk_ostk_cnt": 5000000
  }
}
```

**Airflow DAG Execution:**
- DAG Name: `dart_metrics_extraction_dag`
- Schedule: Daily at 9:00 PM KST (after `dart_disclosure_collection_dag`)
- Dependencies: Requires DART collection to complete first
- Processing:
  - Query for disclosures collected in last 24 hours
  - Process in parallel batches (batch size: 100)
  - Retry failed calculations up to 3 times with exponential backoff
  - Log errors to separate error tracking table
- Execution logs viewable in Airflow UI
- Alert on >10% calculation failure rate

**Integration with Backtesting:**
- Metrics queryable by backtesting service via SQL
- Support user-defined conditions: "유상증자_조달비율 > 0.1 AND 희석률 < 0.05"
- Return matching (stock_code, rcept_dt) tuples for backtest execution
- Example query:
  ```sql
  SELECT stock_code, rcept_dt, metrics
  FROM dart_disclosure_metrics
  WHERE disclosure_type_code = 6
    AND (metrics->>'유상증자_조달비율')::NUMERIC > 0.10
    AND (metrics->>'유상증자_희석률')::NUMERIC < 0.05
  ORDER BY rcept_dt DESC;
  ```

**Validation Rules:**
- All ratio metrics must be non-negative
- Ratio metrics typically in range [0, 1.0] (except rare cases)
- Market cap must be > 0
- Required API fields must be present (fail if missing)
- Calculated metrics logged with source field values for audit

**Error Handling:**
- Missing API fields: Log error, skip disclosure, alert on high frequency
- Division by zero: Handle gracefully (market cap = 0 case), log warning
- Invalid data types: Convert with validation, log conversion errors
- Retry logic: 3 attempts with exponential backoff (1s, 2s, 4s)

**Performance Requirements:**
- Process 100 disclosures in < 2 minutes (NFR-P9 adapted)
- Database inserts complete within 500ms per disclosure
- Parallel processing with up to 10 concurrent workers

**Files affected:**
- `/stockelper-kg/src/stockelper_kg/extractors/dart_metrics_extractor.py` (NEW)
- `/stockelper-kg/src/stockelper_kg/calculators/capital_change_calculator.py` (NEW)
- `/stockelper-kg/src/stockelper_kg/calculators/convertible_bond_calculator.py` (NEW)
- `/stockelper-kg/src/stockelper_kg/calculators/treasury_stock_calculator.py` (NEW)
- `/stockelper-kg/src/stockelper_kg/calculators/business_transfer_calculator.py` (NEW)
- `/stockelper-kg/src/stockelper_kg/calculators/other_company_stock_calculator.py` (NEW)
- `/stockelper-kg/src/stockelper_kg/calculators/merger_calculator.py` (NEW)
- `/stockelper-airflow/dags/dart_metrics_extraction_dag.py` (NEW)
- `/stockelper-kg/migrations/004_create_dart_metrics_table.sql` (NEW)
- `/stockelper-kg/config/metrics_config.yaml` (NEW - metric formulas configuration)

**Testing:**
- Unit tests for each calculator class (80%+ coverage)
- Integration test for full extraction pipeline
- Validation test with known DART API responses
- Performance test with 1000 disclosure batch

**Implementation Reference:**
- Complete metrics architecture: `docs/architecture.md` Repository 1b section
- Meeting notes with metric formulas: `docs/references/20250106.md` lines 58-135

---
```

VERIFICATION:
- All 16 disclosure types covered
- All metric calculation formulas specified
- Database schema complete
- Airflow DAG details included
- Integration with backtesting explained
- File locations provided

Generate the new Story 1.1c.
```

---

## Priority 3: MEDIUM - Update Backtesting and Other Documents

### Cursor Prompt 3.1: Update Backtesting to Use Metrics

```
@prd.md @architecture.md @epics.md

TASK: Update backtesting documentation to use DART financial metrics instead of sentiment scores.

CHANGES REQUIRED:

1. **PRD (docs/prd.md) - Update FR39 series:**
   - FR39a-FR39r already documented for async job queue
   - ADD NEW FRs:
     - **FR39s:** System supports user-defined backtesting conditions based on DART disclosure metrics
     - **FR39t:** System filters disclosures by metric thresholds (e.g., "유상증자_조달비율 > 0.1")
     - **FR39u:** System calculates returns following metric-triggering disclosure events
     - **FR39v:** System compares returns across different metric threshold conditions

2. **Architecture (docs/architecture.md) - Repository 7:**
   - Update backtesting input schema to include:
     ```json
     {
       "user_id": "user123",
       "universe": ["005930", "035420"],
       "strategy_type": "metric_based",
       "metric_conditions": [
         {
           "disclosure_type_code": 6,
           "metric_name": "유상증자_조달비율",
           "operator": ">",
           "threshold": 0.1
         }
       ],
       "timeframes": [30, 90, 180, 365]
     }
     ```
   - Add integration diagram:
     ```
     [Backtesting Service] → [dart_disclosure_metrics table]
                          ↓
             [Filter by metric conditions]
                          ↓
          [Retrieve matching (stock, date) pairs]
                          ↓
              [Calculate returns from daily_stock_prices]
                          ↓
                  [Generate results]
     ```

3. **Epics (docs/epics.md) - Story 3.2:**
   - Update Story 3.2 acceptance criteria:
     - Change "similar events from Neo4j" to "metric-based conditions from dart_disclosure_metrics"
     - Update example: "Backtest stocks with 유상증자_조달비율 > 0.1 over past 5 years"
     - Add metric condition parsing and SQL query generation

VERIFICATION:
- Backtesting clearly uses metrics (not sentiment)
- Integration with dart_disclosure_metrics table specified
- User-defined conditions supported
- Examples provided

Generate the updates.
```

---

### Cursor Prompt 3.2: Mark Story 1.1a as POSTPONED

```
@epics.md

TASK: Mark Story 1.1a (News Event Extraction) as POSTPONED.

CHANGES REQUIRED:

1. **Update Story 1.1a Title:**
   Change:
   ```
   #### Story 1.1a: Automate News Event Extraction with Dual Crawlers and LLM-Based Extraction
   ```
   To:
   ```
   #### Story 1.1a: Automate News Event Extraction with Dual Crawlers and LLM-Based Extraction **[POSTPONED - 2025-01-06]**
   ```

2. **Add POSTPONEMENT Notice at top of Story 1.1a:**
   ```markdown
   **⏸️ STATUS: POSTPONED (2025-01-06 Meeting)**
   
   This story has been postponed based on architectural decisions made in the 2025-01-06 meeting. The system will initially focus on DART disclosure financial metrics (Story 1.1c) instead of news-based event extraction.
   
   **Rationale:** Direct use of DART disclosure categories with calculated metrics provides more quantitative, reliable data for backtesting. News-based extraction will be implemented in future phases.
   
   **Content Preserved:** This story documentation is preserved for future reference when news features are implemented.
   
   ---
   ```

3. **Update Epic 1 Implementation Notes:**
   - Remove news crawler references from current scope
   - Clarify DART-only focus
   - Add note: "News-based extraction postponed (Story 1.1a) - see Story 1.1c for current DART metrics approach"

VERIFICATION:
- Story 1.1a clearly marked as POSTPONED
- Meeting reference date visible
- Rationale explained
- Content preserved (not deleted)

Generate the updates.
```

---

## Summary: How to Use These Prompts

**Step 1: Priority 1 Tasks (CRITICAL - Do First)**
1. Run Cursor Prompt 1.1 → Update PRD with POSTPONED markers
2. Run Cursor Prompt 1.2 → Add DART metrics FRs to PRD
3. Run Cursor Prompt 1.3 → Mark Architecture news sections as POSTPONED

**Step 2: Priority 2 Tasks (HIGH - Do Second)**
4. Run Cursor Prompt 2.1 → Add DART metrics architecture (Repository 1b)
5. Run Cursor Prompt 2.2 → Add Story 1.1c to Epics

**Step 3: Priority 3 Tasks (MEDIUM - Do Third)**
6. Run Cursor Prompt 3.1 → Update backtesting to use metrics
7. Run Cursor Prompt 3.2 → Mark Story 1.1a as POSTPONED

**Step 4: Verification**
8. Review all generated content
9. Verify cross-references between documents
10. Commit changes with meeting reference

**Estimated Time:**
- Priority 1: 2-3 hours
- Priority 2: 2-3 hours
- Priority 3: 1 hour
- Verification: 1 hour
- **Total: 6-8 hours**

---

**Meeting Reference:** 2025-01-06 (docs/references/20250106.md)
**Revision Plan:** docs/REVISION-PLAN-20250106.md
