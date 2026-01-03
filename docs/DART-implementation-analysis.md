# DART Implementation Analysis Report
**Date:** 2026-01-02
**Analyst:** Claude Code (BMAD Method-based Analysis)
**Workspace:** `/Users/oldman/Library/CloudStorage/OneDrive-개인/001_Documents/001_TelePIX/000_workspace/03_PseudoLab/Stockelper-Lab`

---

## Executive Summary

This report provides a comprehensive analysis of all DART (Data Analysis, Retrieval and Transfer System - 금융감독원 전자공시시스템) implementations across the Stockelper codebase.

**Key Findings:**
1. ✅ **Financial Statement Collection:** Fully implemented across 3 services (KG, LLM, Airflow)
2. ❌ **Filing-Document Event Extraction:** **NOT IMPLEMENTED** (planned but not built)
3. 📋 **DART API Coverage:** 3/7 methods implemented (company, finstate, finstate_all)
4. 🎯 **Missing Capability:** Document retrieval (list, document, document_url, document_text)

---

## A) DART Implementation Inventory

### Summary Table

| File | Service | DART Methods | Input Parameters | Output Fields | Purpose | Status |
|------|---------|--------------|------------------|---------------|---------|--------|
| `stockelper-kg/collectors/dart.py` | KG Builder | `finstate()` | stock_code, date | 7 financial metrics | Production data collection | ✅ Active |
| `stockelper-llm/.../dart.py` | LLM Service | `finstate_all()` | stock_code, year | 13 IFRS accounts → 8 ratios | LangChain financial analysis | ✅ Active |
| `stockelper-llm/.../get_financial_statement.py` | LLM Service | `finstate_all()` | stock_code, year | Same as above | Async portfolio analysis | ✅ Active |
| `stockelper-kg/legacy/stock_graph.py` | KG Builder | `finstate()` | stock_code, date | 7 financial metrics | Legacy graph builder | ⚠️ Legacy |
| `stockelper-airflow/.../data_validator.py` | Airflow | `find_corp_code()`, `company()` | company_name, corp_code | Company metadata | API validation/testing | ✅ Active |
| `stockelper-llm/.../portfolio.py` | LLM Service | `company()` | stock_code | Company info | Portfolio lookup | ✅ Active |

---

### Detailed Implementation Analysis

#### 1. **`stockelper-kg/src/stockelper_kg/collectors/dart.py`**

**Purpose:** Production-grade DART collector for quarterly financial statement data

**OpenDartReader Usage:**
```python
from OpenDartReader import OpenDartReader

class DartCollector:
    def __init__(self, api_key: str):
        self.dart = OpenDartReader(api_key)  # Line 15
```

**DART API Method:** `finstate(corp, bsns_year, reprt_code)`
- **Called at:** Line 58-60
- **Wrapper Function:** `_fetch_quarterly_data(stock_code, date)`

**Input Parameters:**
| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `stock_code` | str | 6-digit stock code | "005930" |
| `date` | str | YYYYMMDD format | "20250315" |
| `bsns_year` | str | 4-digit year (derived) | "2025" |
| `reprt_code` | str | Quarter code | "11013" (Q1) |

**Quarter Code Mapping:**
```python
"11011" → Q4 (annual report)
"11012" → Q2 (semi-annual)
"11013" → Q1 (quarterly)
"11014" → Q3 (quarterly)
```

**Output Fields (Korean → English Mapping):**
```python
columns_kr = [
    "매출액",       # revenue
    "영업이익",     # operating_income
    "당기순이익",   # net_income
    "자산총계",     # total_assets
    "부채총계",     # total_liabilities
    "자본총계",     # total_equity
    "자본금"        # capital_stock
]
```

**Output DataFrame Schema:**
| Column | Type | Source Field | Description |
|--------|------|--------------|-------------|
| `stock_code` | str | Input parameter | 6-digit stock code |
| `year` | int | Derived from date | Fiscal year |
| `quarter` | int | Derived from reprt_code | 1-4 |
| `reported_date` | str | `thstrm_dt` normalized | YYYY-MM-DD format |
| `revenue` | float | `thstrm_amount` for "매출액" | Current period revenue |
| `operating_income` | float | `thstrm_amount` for "영업이익" | Operating income |
| `net_income` | float | `thstrm_amount` for "당기순이익" | Net income |
| `total_assets` | float | `thstrm_amount` for "자산총계" | Total assets |
| `total_liabilities` | float | `thstrm_amount` for "부채총계" | Total liabilities |
| `total_equity` | float | `thstrm_amount` for "자본총계" | Total equity |
| `capital_stock` | float | `thstrm_amount` for "자본금" | Capital stock |

**Data Extraction Logic:**
1. Filters DataFrame for `account_nm` matching target Korean column names
2. Prefers "연결재무제표" (consolidated financial statements)
3. Falls back to "재무제표" (separate financial statements) if consolidated not available
4. Extracts `thstrm_amount` (current period amount)
5. Normalizes `thstrm_dt` (reporting date) using `normalize_date()` function
6. Returns 0 if data unavailable

**Environment Configuration:**
```python
# config.py
OPEN_DART_API_KEY = os.getenv("OPEN_DART_API_KEY")
```

---

#### 2. **`stockelper-llm/src/multi_agent/fundamental_analysis_agent/tools/dart.py`**

**Purpose:** LangChain tool wrapper for financial statement analysis in multi-agent system

**OpenDartReader Usage:**
```python
from OpenDartReader import OpenDartReader

class FinancialStatementTool:
    def __init__(self):
        api_key = os.getenv("OPEN_DART_API_KEY")  # Line 170
        self.dart = OpenDartReader(api_key)       # Line 174
```

**DART API Method:** `finstate_all(stock_code, year)`
- **Called at:** Line 189
- **Wrapper Function:** `get_financial_statements(stock_code)`

**Input Parameters:**
| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `stock_code` | str | 6-digit stock code | "005930" |
| `year` | str | 4-digit year | "2024" |

**Retry Logic:**
- Attempts last 5 years: `[current_year, current_year-1, ..., current_year-4]`
- Returns first successful result
- Returns error message if all years fail

**Output Fields (IFRS Account IDs):**
```python
account_ids = [
    "ifrs-full_CurrentAssets",           # 유동자산
    "ifrs-full_CurrentLiabilities",      # 유동부채
    "ifrs-full_Liabilities",             # 부채총계
    "ifrs-full_Equity",                  # 자본총계
    "ifrs-full_SharePremium",            # 자본잉여금
    "ifrs-full_RetainedEarnings",        # 이익잉여금
    "ifrs-full_IssuedCapital",           # 자본금
    "dart_OperatingIncomeLoss",          # 영업이익
    "dart_OtherGains",                   # 영업외수익
    "dart_OtherLosses",                  # 영업외비용
    "ifrs-full_ProfitLoss",              # 당기순이익
    "ifrs-full_Revenue",                 # 매출액
    "ifrs-full_FinanceCosts"             # 이자비용
]
```

**Calculated Financial Metrics:**

| Metric (Korean) | Metric (English) | Formula | Description |
|-----------------|------------------|---------|-------------|
| 유동비율 | Current Ratio | `(CurrentAssets / CurrentLiabilities) × 100` | Liquidity measure |
| 부채비율 | Debt Ratio | `(Liabilities / Equity) × 100` | Leverage measure |
| 유보율 | Reserve Ratio | `(SharePremium + RetainedEarnings) / IssuedCapital × 100` | Retained earnings ratio |
| 자본잠식률 | Capital Impairment | `(IssuedCapital - Equity) / IssuedCapital × 100` | Capital erosion measure |
| 경상이익 | Ordinary Income | `OperatingIncome + OtherGains - OtherLosses` | Recurring income |
| 매출액경상이익률 | Ordinary Income Margin | `OrdinaryIncome / Revenue × 100` | Profitability margin |
| 이자보상배율 | Interest Coverage | `OperatingIncome / FinanceCosts × 100` | Debt service coverage |
| 자기자본이익률 | ROE | `ProfitLoss / Equity × 100` | Return on equity |

**Output Format:**
```python
{
    "stock_code": "005930",
    "year": "2024",
    "metrics": {
        "current_ratio": 215.3,
        "debt_ratio": 45.2,
        "reserve_ratio": 1850.7,
        # ... 8 metrics total
    }
}
```

---

#### 3. **`stockelper-llm/src/portfolio_multi_agent/nodes/get_financial_statement.py`**

**Purpose:** Async financial statement analysis node for portfolio multi-agent system

**OpenDartReader Usage:**
```python
from OpenDartReader import OpenDartReader

class FinancialStatementNode:
    def __init__(self):
        api_key = os.getenv("OPEN_DART_API_KEY")  # Line 21
        self.dart = OpenDartReader(api_key)       # Line 26
```

**DART API Method:** `finstate_all(stock.code, year)`
- **Called at:** Line 209
- **Async Wrapper:** `asyncio.to_thread(self.analyze_single_stock, stock)` (Line 44)

**Key Features:**
1. **Async/Parallel Execution:**
   ```python
   results = await asyncio.gather(
       *[self.analyze_single_stock_async(stock) for stock in stocks],
       return_exceptions=True
   )
   ```

2. **Error Handling:**
   - Returns `AnalysisResult` with error messages
   - Continues processing other stocks on individual failures

3. **Portfolio-Level Analysis:**
   - Processes multiple stocks concurrently
   - Aggregates results for portfolio view

**Output Schema (per stock):**
```python
{
    "stock_code": str,
    "year": str,
    "metrics": {
        # Same 8 metrics as fundamental_analysis_agent
    },
    "success": bool,
    "error": Optional[str]
}
```

---

#### 4. **`stockelper-kg/legacy/stock_graph.py`** ⚠️ Legacy

**Purpose:** Legacy knowledge graph data collection (pre-refactor)

**OpenDartReader Usage:**
```python
from OpenDartReader import OpenDartReader

# Global instance
dart = OpenDartReader(OPEN_DART_API_KEY)  # Line 432
```

**DART API Method:** `finstate(corp=stock_code, bsns_year=str(bsns_year), reprt_code=reprt_code)`
- **Called at:** Line 440
- **Function:** `_get_fs_df(stock_code, month)`

**Quarterly Data Retrieval Logic:**
```python
def _get_fs_df(stock_code, month):
    year = datetime.now().year

    # Determine quarters to try based on current month
    if month in [1, 2, 3]:
        quarters = [(year-1, '11011', '4')]  # Last year Q4
    elif month in [4, 5, 6]:
        quarters = [(year, '11013', '1'), (year-1, '11011', '4')]
    elif month in [7, 8, 9]:
        quarters = [(year, '11012', '2'), (year, '11013', '1'), (year-1, '11011', '4')]
    else:  # [10, 11, 12]
        quarters = [(year, '11014', '3'), (year, '11012', '2'), (year, '11013', '1')]

    # Try quarters in order until success
    for year, reprt_code, quarter_name in quarters:
        df = dart.finstate(corp=stock_code, bsns_year=str(year), reprt_code=reprt_code)
        if not df.empty:
            return df

    # Return zero-filled DataFrame if all fail
    return create_empty_df(stock_code)
```

**Output Fields:**
- Same 7 columns as modern `dart.py` collector
- Fallback to 0-filled DataFrame on complete failure

---

#### 5. **`stockelper-airflow/modules/api/data_validator.py`**

**Purpose:** Schema validation and API endpoint testing for Airflow DAGs

**OpenDartReader Usage:**
```python
from OpenDartReader import OpenDartReader

dart = OpenDartReader(api_key)  # Line 67
```

**DART API Methods:**

**Method 1:** `find_corp_code(company_name)`
- **Called at:** Line 75
- **Purpose:** Convert Korean company name to corp_code
- **Example:** `dart.find_corp_code("삼성전자")` → `"00126380"`

**Method 2:** `company(corp_code)`
- **Called at:** Line 89
- **Purpose:** Retrieve company profile metadata
- **Returns:**
  ```python
  {
      "corp_name": "삼성전자",
      "corp_name_eng": "Samsung Electronics Co., Ltd.",
      "induty_code": "264",
      "corp_cls": "Y",  # Y=유가증권, K=코스닥, N=코넥스, E=기타
      "stock_code": "005930"
  }
  ```

**Validation Functions:**
- `validate_company()`: Tests company info retrieval
- `validate_product()`: Mock product data (DART doesn't provide this API)
- `validate_facility()`: Mock facility data (DART doesn't provide this API)

**Note:** Product and facility data require parsing business report documents (not implemented).

---

#### 6. **`stockelper-llm/src/multi_agent/portfolio_analysis_agent/tools/portfolio.py`**

**Purpose:** Portfolio analysis tool with DART company lookup

**OpenDartReader Usage:**
```python
from OpenDartReader import OpenDartReader

dart = OpenDartReader(api_key)  # Implicit initialization
```

**DART API Method:** `company(symbol)`
- **Called at:** Line 156
- **Purpose:** Fetch company metadata for portfolio stocks
- **Use Case:** Enrich portfolio data with official company information

**Integration Point:**
- Called during portfolio composition analysis
- Provides company names and metadata for display
- Used in multi-agent portfolio recommendation workflow

---

### Environment Configuration Summary

**Configuration Files:**

1. **`stockelper-kg/src/stockelper_kg/config.py`**
   ```python
   @dataclass
   class Config:
       dart_api_key: str

       @classmethod
       def from_env(cls, env_path: str = ".env") -> "Config":
           dart_api_key = cls._get_required_env("OPEN_DART_API_KEY")
           return cls(dart_api_key=dart_api_key)
   ```

2. **`.env.example` files:**
   - `/stockelper-kg/.env.example`: Line 3
   - `/stockelper-llm/.env.example`: Similar structure

   ```bash
   # DART API Key (required for financial statement collection)
   OPEN_DART_API_KEY=your_api_key_here
   ```

**Security Note:** API keys are loaded from environment variables. Never commit actual keys to version control.

---

### Common Implementation Patterns

**Pattern 1: Rate Limiting**
```python
import time

# Sleep between API calls to avoid rate limiting
time.sleep(0.1)  # 100ms delay
```

**Pattern 2: Error Handling**
```python
try:
    df = dart.finstate(stock_code, year, quarter)
    if df.empty:
        return create_zero_filled_df()
except Exception as e:
    logger.error(f"DART API error: {e}")
    return create_zero_filled_df()
```

**Pattern 3: DataFrame Preference**
```python
# Prefer consolidated statements
consolidated = df[df['fs_nm'] == '연결재무제표']
if not consolidated.empty:
    return consolidated
else:
    # Fallback to separate statements
    return df[df['fs_nm'] == '재무제표']
```

**Pattern 4: Column Mapping**
```python
# Korean → English column mapping for Neo4j storage
column_mapping = {
    "매출액": "revenue",
    "영업이익": "operating_income",
    # ...
}
```

---

## B) DART Disclosure Collection Status - 36 Major Report Types

### 🔄 **Status: ARCHITECTURE REVISED (2026-01-03)**

**Previous Approach (NOT IMPLEMENTED):**
- Generic `list()` → `document()` → LLM event extraction pipeline
- Unstructured text parsing from disclosure documents
- Planned but never built

**New Approach (Updated 2026-01-03 - Based on 민우 work):**
- **36 structured major report type API endpoints**
- Dedicated DART API per report type with structured fields
- Direct data extraction without LLM parsing
- **Local PostgreSQL storage** (NOT remote AWS)

---

### 36 Major Report Types - Complete Catalog

**Data Source:** DART Open API (OpenDartReader library)
**Reference:** `docs/references/DART(modified events).md` (민우 2026-01-03 work)
**Storage:** Local PostgreSQL (36 separate tables, one per report type)

#### Category 1: 기업상태 (Company Status) - 5 Types

| Report Type | API Code | Korean Name | Description |
|-------------|----------|-------------|-------------|
| AST_INHTRF_ETC_PTBK_OPT | astInhtrfEtcPtbkOpt | 자산양수도(기타)_풋백옵션 | Put-back option on asset transfer |
| DF_OCR | dfOcr | 부도발생 | Default occurrence |
| BSN_SP | bsnSp | 영업정지 | Business suspension |
| RVVPRPD_APSTRT_APLFN | rvvprpdApstrtAplfn | 회생절차_개시신청 | Rehabilitation procedure application |
| DSLN_RSN_OCR | dslnRsnOcr | 해산사유_발생 | Dissolution reason occurrence |

**Common Fields:**
- corp_code (VARCHAR) - 8-digit company code
- stock_code (VARCHAR) - 6-digit stock code
- corp_name (VARCHAR) - Company name
- rcept_no (VARCHAR PRIMARY KEY) - Receipt number
- rcept_dt (DATE) - Receipt date

**Report-Specific Examples (dfOcr - Default):**
- df_dt (DATE) - Default date
- df_am (DECIMAL) - Default amount
- df_rsn (TEXT) - Default reason

---

#### Category 2: 증자감자 (Capital Changes) - 4 Types

| Report Type | API Code | Korean Name | Description |
|-------------|----------|-------------|-------------|
| PIIC_DECSN | piicDecsn | 유상증자_결정 | Paid-in capital increase decision |
| BDID_DECSN | bdidDecsn | 무상증자_결정 | Bonus issue decision |
| PIIC_BDID_DECSN | piicBdidDecsn | 유무상증자_결정 | Mixed capital increase decision |
| DSRS_DECSN | dsrsDecsn | 감자_결정 | Capital reduction decision |

**Report-Specific Fields (piicDecsn - Paid-in increase):**
- nstk_astock_co (BIGINT) - Number of new stocks allocated
- nstk_astock_estmtamt (BIGINT) - Estimated amount
- nstk_astock_int (TEXT) - Allocation intent
- fdpp_fclt_atrdsqp_rsn (TEXT) - Reason for facility acquisition

**Example Schema:**
```sql
CREATE TABLE dart_piic_decsn (
    rcept_no VARCHAR PRIMARY KEY,
    corp_code VARCHAR NOT NULL,
    stock_code VARCHAR,
    corp_name VARCHAR,
    rcept_dt DATE NOT NULL,
    nstk_astock_co BIGINT,  -- New stock count
    nstk_astock_estmtamt BIGINT,  -- Estimated amount
    nstk_astock_int TEXT,  -- Allocation intent
    fdpp_fclt_atrdsqp_rsn TEXT,  -- Reason
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_piic_corp ON dart_piic_decsn(corp_code, rcept_dt DESC);
CREATE INDEX idx_piic_stock ON dart_piic_decsn(stock_code, rcept_dt DESC);
```

---

#### Category 3: 채권은행 (Creditor Bank) - 2 Types

| Report Type | API Code | Korean Name | Description |
|-------------|----------|-------------|-------------|
| CRBNMNGPRCD_STR | crbnmngprcdStr | 채권은행_관리절차_개시 | Creditor bank management procedure start |
| CRBNMNGPRCD_DSCD | crbnmngprcdDscd | 채권은행_관리절차_중단 | Creditor bank management procedure suspension |

**Report-Specific Fields:**
- mngprcd_str_dt (DATE) - Management procedure start date
- mngprcd_dscd_dt (DATE) - Management procedure suspension date

---

#### Category 4: 소송 (Litigation) - 1 Type

| Report Type | API Code | Korean Name | Description |
|-------------|----------|-------------|-------------|
| LST_FR | lstFr | 소송등_제기 | Litigation filing |

**Report-Specific Fields:**
- lst_knd (VARCHAR) - Litigation kind
- lst_bdtamt (DECIMAL) - Litigation amount
- lst_fltm (TEXT) - Litigation details/content

---

#### Category 5: 해외상장 (Overseas Listing) - 4 Types

| Report Type | API Code | Korean Name | Description |
|-------------|----------|-------------|-------------|
| OVR_SEC_MKT_LSTG_DECSN | ovrSecMktLstgDecsn | 해외증권시장_상장_결정 | Overseas listing decision |
| OVR_SEC_MKT_DLST_DECSN | ovrSecMktDlstDecsn | 해외증권시장_상장폐지_결정 | Overseas delisting decision |
| OVR_SEC_MKT_LSTG | ovrSecMktLstg | 해외증권시장_상장 | Overseas listing |
| OVR_SEC_MKT_DLST | ovrSecMktDlst | 해외증권시장_상장폐지 | Overseas delisting |

**Report-Specific Fields:**
- ovr_mkt_lstg_exch (VARCHAR) - Exchange name (NASDAQ, NYSE, etc.)
- ovr_mkt_lstg_dt (DATE) - Listing date
- ovr_mkt_dlst_dt (DATE) - Delisting date

---

#### Category 6: 사채발행 (Bond Issuance) - 4 Types

| Report Type | API Code | Korean Name | Description |
|-------------|----------|-------------|-------------|
| CVSBNISSN_DECSN | cvsbnissnDecsn | 전환사채권_발행결정 | Convertible bond issuance decision |
| BDWTISSN_DECSN | bdwtissnDecsn | 신주인수권부사채권_발행결정 | Bond with warrants issuance decision |
| EXBD_ISSN_DECSN | exbdIssnDecsn | 교환사채권_발행결정 | Exchangeable bond issuance decision |
| AMCD_CPBDISSN_DECSN | amcdCpbdissnDecsn | 상각형_조건부자본증권_발행결정 | Amortizing conditional capital security issuance decision |

**Report-Specific Fields (cvsbnissnDecsn):**
- bd_issn_am (DECIMAL) - Bond issuance amount
- bd_issn_cnt (BIGINT) - Bond issuance count
- cvprc_dtm_mth (VARCHAR) - Conversion price determination method
- cvprc (DECIMAL) - Conversion price

---

#### Category 7: 자기주식 (Treasury Stock) - 4 Types

| Report Type | API Code | Korean Name | Description |
|-------------|----------|-------------|-------------|
| OG_STOCK_ACQS_DECSN | ogStockAcqsDecsn | 자기주식_취득_결정 | Treasury stock acquisition decision |
| OG_STOCK_DSPS_DECSN | ogStockDspsDecsn | 자기주식_처분_결정 | Treasury stock disposal decision |
| OG_STOCK_ACQS_TCNTR_SGNT_DECSN | ogStockAcqsTcntrSgntDecsn | 자기주식취득_신탁계약_체결_결정 | Treasury stock acquisition trust contract decision |
| OG_STOCK_ACQS_TCNTR_SGNT_CNLT_DECSN | ogStockAcqsTcntrSgntCnltDecsn | 자기주식취득_신탁계약_해지_결정 | Treasury stock acquisition trust contract termination decision |

**Report-Specific Fields:**
- og_stock_acqs_mth (VARCHAR) - Acquisition method
- og_stock_acqs_cnt (BIGINT) - Acquisition count
- og_stock_dsps_cnt (BIGINT) - Disposal count
- og_stock_acqs_am (DECIMAL) - Acquisition amount

---

#### Category 8: 영업/자산양수도 (Business/Asset Transfer) - 4+ Types

| Report Type | API Code | Korean Name | Description |
|-------------|----------|-------------|-------------|
| BSN_ACQS_DECSN | bsnAcqsDecsn | 영업양수_결정 | Business acquisition decision |
| BSN_TRNF_DECSN | bsnTrnfDecsn | 영업양도_결정 | Business transfer decision |
| TNR_ASSETS_ACQS_DECSN | tnrAssetsAcqsDecsn | 유형자산_양수_결정 | Tangible asset acquisition decision |
| TNR_ASSETS_TRNF_DECSN | tnrAssetsTrnfDecsn | 유형자산_양도_결정 | Tangible asset transfer decision |

**Report-Specific Fields:**
- trnf_target (TEXT) - Transfer target description
- trnf_am (DECIMAL) - Transfer amount
- trnf_rsn (TEXT) - Transfer reason

---

### Collection Pipeline Architecture

**Data Flow:**

```
1. Universe Loading
   ├─ Read: modules/dart_disclosure/universe.ai-sector.template.json
   └─ Extract: List of corp_codes (AI sector stocks)

2. Parallel Collection (Per corp_code)
   ├─ For each corp_code:
   │  ├─ For each of 36 major report types:
   │  │  ├─ API Call: dart.major_report(corp_code, report_type)
   │  │  ├─ Structured fields returned per type
   │  │  └─ Store: Local PostgreSQL (type-specific table)
   │  └─ Rate limiting: 5 requests/sec max
   └─ Deduplication: By rcept_no (receipt number)

3. Event Extraction (Post-collection)
   ├─ Read: Structured data from PostgreSQL tables
   ├─ LLM processing: Extract sentiment + event classification
   └─ Store: Neo4j (Event nodes, Document nodes)

4. Pattern Matching & Notifications
   ├─ Query: Neo4j event graph
   ├─ Match: Similar historical events
   └─ Notify: Users with matching interests
```

**Storage Architecture:**

| Data Type | Storage | Schema |
|-----------|---------|--------|
| **Raw DART Disclosures** | Local PostgreSQL | 36 tables (one per report type) |
| **Event Extraction Results** | Local PostgreSQL | `dart_events` table (sentiment, classification) |
| **Graph Relationships** | Neo4j | `:Document` nodes, `:Event` nodes, `EXTRACTED_FROM` relationships |
| **Backtesting Results** | Remote PostgreSQL (`${POSTGRES_HOST}`) | `backtest_results` table |
| **Portfolio Recommendations** | Remote PostgreSQL (`${POSTGRES_HOST}`) | `portfolio_recommendations` table |

---

### Airflow DAG Specification

**DAG Name:** `dag_dart_disclosure_daily`
**Schedule:** Daily @ 8:00 AM KST
**Owner:** 영상

**Tasks:**

```python
# dags/dart_disclosure_collection_dag.py

from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': '영상',
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'dag_dart_disclosure_daily',
    default_args=default_args,
    description='Collect DART 36 major report types for AI-sector universe',
    schedule_interval='0 8 * * *',  # 8:00 AM KST daily
    start_date=datetime(2026, 1, 1),
    catchup=False,
)

# Task 1: Load Universe
def load_universe_template(**context):
    """Load AI-sector universe from template JSON."""
    import json
    with open('modules/dart_disclosure/universe.ai-sector.template.json', 'r') as f:
        universe = json.load(f)
    corp_codes = [stock['corp_code'] for stock in universe['stocks']]
    context['task_instance'].xcom_push(key='corp_codes', value=corp_codes)

task_load_universe = PythonOperator(
    task_id='load_universe_template',
    python_callable=load_universe_template,
    dag=dag,
)

# Task 2: Collect 36 Major Report Types (per corp_code)
def collect_major_reports(**context):
    """Collect all 36 major report types for each corp_code."""
    from stockelper_kg.collectors.dart_major_reports import DartMajorReportCollector
    import os

    corp_codes = context['task_instance'].xcom_pull(key='corp_codes', task_ids='load_universe_template')
    collector = DartMajorReportCollector(api_key=os.getenv('OPEN_DART_API_KEY'))

    for corp_code in corp_codes:
        collector.collect_all_report_types(corp_code)
        # Stores directly to Local PostgreSQL

task_collect_reports = PythonOperator(
    task_id='collect_36_major_reports',
    python_callable=collect_major_reports,
    dag=dag,
)

# Task 3: Extract Events
def extract_events_from_disclosures(**context):
    """Extract events from collected disclosure data."""
    from stockelper_kg.extractors.dart_event_extractor import DartEventExtractor

    extractor = DartEventExtractor()
    extractor.process_all_new_disclosures()
    # Reads from Local PostgreSQL, extracts events, stores to Neo4j

task_extract_events = PythonOperator(
    task_id='extract_events',
    python_callable=extract_events_from_disclosures,
    dag=dag,
)

# Task 4: Pattern Matching
def match_event_patterns(**context):
    """Match newly extracted events with historical patterns."""
    from stockelper_kg.pattern_matcher import PatternMatcher

    matcher = PatternMatcher()
    matcher.find_similar_events()
    # Creates SIMILAR_TO relationships in Neo4j

task_pattern_match = PythonOperator(
    task_id='pattern_matching',
    python_callable=match_event_patterns,
    dag=dag,
)

# Task Dependencies
task_load_universe >> task_collect_reports >> task_extract_events >> task_pattern_match
```

---

### Implementation Gap Analysis

| Component | Planned | Implemented | Gap Status |
|-----------|---------|-------------|------------|
| **Data Collection** |
| Universe template (JSON) | ✅ | ❌ | **Missing** - File needs creation |
| 36 major report type collector | ✅ | ❌ | **Missing** - Module needs implementation |
| Local PostgreSQL schemas (36 tables) | ✅ | ❌ | **Missing** - Schemas need creation |
| **Event Extraction** |
| DART event extractor module | ✅ | ❌ | **Missing** - Extractor logic needs implementation |
| Sentiment scoring | ✅ | ❌ | **Missing** - LLM integration needed |
| Event classification (7 categories) | ✅ | ❌ | **Missing** - Classification logic needed |
| **Storage** |
| Local PostgreSQL setup | ✅ | ❌ | **Missing** - Database initialization needed |
| Neo4j Document nodes | ✅ | ❌ | **Missing** - Graph schema update needed |
| Neo4j Event nodes | ✅ | ❌ | **Missing** - Graph schema update needed |
| **Orchestration** |
| Airflow DAG | ✅ | ❌ | **Missing** - DAG needs creation |
| Daily schedule (8:00 AM) | ✅ | ❌ | **Missing** - Scheduling needs setup |

---

### Implementation Priority

**CRITICAL (Must implement first):**
1. Create `modules/dart_disclosure/universe.ai-sector.template.json`
2. Implement `stockelper-kg/src/stockelper_kg/collectors/dart_major_reports.py`
3. Create Local PostgreSQL schemas (36 tables)
4. Implement Airflow DAG `dag_dart_disclosure_daily`

**HIGH (Core functionality):**
5. Implement `stockelper-kg/src/stockelper_kg/extractors/dart_event_extractor.py`
6. Update Neo4j ontology for Document/Event nodes
7. Implement sentiment scoring integration

**MEDIUM (Enhancement):**
8. Implement pattern matching logic
9. Add user notification triggers
10. Performance optimization (parallel collection)

---

### Data Requirements

**Universe Template Structure:**
```json
{
  "name": "AI Sector Universe",
  "description": "Investment candidate stocks in AI sector",
  "last_updated": "2026-01-03",
  "stocks": [
    {
      "corp_code": "00126380",
      "stock_code": "005930",
      "corp_name": "삼성전자",
      "sector": "AI Semiconductors"
    },
    {
      "corp_code": "00164742",
      "stock_code": "035420",
      "corp_name": "NAVER",
      "sector": "AI Services"
    }
    // ... additional stocks
  ]
}
```

**Estimated Data Volume:**
- Universe size: ~50-100 AI sector stocks
- Reports per stock per day: 0-5 (average 1-2)
- Data storage per report: ~1-5 KB structured data
- Daily data volume: ~50-500 KB
- Monthly retention: ~1.5-15 MB

---

### Technical Implementation Notes

**API Rate Limiting:**
- DART Open API: 10,000 requests/day limit
- Recommended throttling: 5 requests/sec
- Daily collection window: 8:00-9:00 AM (1-hour max execution time)

**Error Handling:**
- Missing data: Log warning, continue collection
- API failures: Retry 3 times with exponential backoff
- Invalid corp_code: Skip and alert

**Data Validation:**
- Check for duplicate rcept_no before insertion
- Validate required fields (corp_code, rcept_dt, rcept_no)
- Sanitize Korean text encoding (ensure UTF-8)

**Performance Optimization:**
- Parallel collection per corp_code (max 10 concurrent workers)
- Bulk insert to PostgreSQL (batch size: 100 records)
- Connection pooling for database access

---

### Next Steps (Action Items)

**For 영상님 (Implementation Owner):**
1. Review `references/DART(modified events).md` for complete implementation code
2. Create Local PostgreSQL database and 36 table schemas
3. Implement `DartMajorReportCollector` class
4. Create `universe.ai-sector.template.json` with initial stock list
5. Implement Airflow DAG `dag_dart_disclosure_daily`
6. Test collection with 1-2 stocks before full deployment

**For Documentation Team:**
7. Update PRD with FR126 (DART 36-type collection)
8. Update epics.md Story 1.2 with new collection approach
9. Update architecture.md with final implementation details

**Reference Files:**
- `docs/references/DART(modified events).md` - Complete implementation code (민우 2026-01-03)
- `docs/meeting-analysis-2026-01-03.md` - Meeting decisions and requirements
- `docs/DOCUMENTATION-UPDATE-PLAN.md` - Comprehensive update checklist
- `docs/architecture.md` - Updated DART 36-type collection architecture

---
## C) Service Mapping

### Ownership Matrix

| Component | Responsible Service | Purpose | Dependencies |
|-----------|-------------------|---------|--------------|
| **Data Collection** |
| Financial Statements | `stockelper-kg` | Collect `finstate()` / `finstate_all()` data | OPEN_DART_API_KEY |
| Company Metadata | `stockelper-kg` + `stockelper-llm` | Fetch company info via `company()` | OPEN_DART_API_KEY |
| DART Documents | ❌ `stockelper-kg` (planned) | Fetch disclosure lists + bodies | OPEN_DART_API_KEY |
| **Data Normalization/Extraction** |
| Financial Metrics | `stockelper-kg` | Korean→English mapping, consolidation preference | None |
| Financial Ratios | `stockelper-llm` | Calculate 8 financial ratios from IFRS accounts | `stockelper-kg` financial data |
| Event Extraction | ❌ `stockelper-llm` (planned) | LLM-based event extraction from documents | gpt-5.1, ontology |
| Sentiment Scoring | ❌ `stockelper-llm` (planned) | Calculate sentiment (-1 to 1) for events | Event patterns |
| **Data Persistence** |
| Company Nodes | `stockelper-kg` | Store Company nodes in Neo4j | Neo4j |
| FinancialStatements Nodes | `stockelper-kg` | Store quarterly/annual data in Neo4j | Neo4j |
| Document Nodes | ❌ `stockelper-kg` (planned) | Store DART disclosures in Neo4j | Neo4j |
| Event Nodes | ❌ `stockelper-kg` (planned) | Store extracted events in Neo4j | Neo4j, LLM extraction |
| **Orchestration** |
| Financial Statement Collection | `stockelper-airflow` | Schedule periodic collection (implied, not explicit DAG found) | KG collector |
| DART Event Extraction | ❌ `stockelper-airflow` (planned) | Schedule 3-hour event extraction | KG collector, LLM extractor |
| **Consumption** |
| Financial Analysis | `stockelper-llm` | Fundamental analysis tool for multi-agent | KG financial data |
| Portfolio Analysis | `stockelper-llm` | Async portfolio financial analysis | KG financial data |
| Event-Based Predictions | ❌ `stockelper-llm` (planned) | Predict stock movements from events | Event nodes |

---

### Service Communication Flow

#### **Current Implementation (Financial Statements):**

```
┌─────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION LAYER                       │
│                  (stockelper-airflow)                        │
│                                                              │
│  Implied Schedule: Periodic financial statement collection  │
│  (No explicit DAG found, assumed to exist)                   │
└────────────┬────────────────────────────────────────────────┘
             │ triggers
             ▼
┌─────────────────────────────────────────────────────────────┐
│                    COLLECTION LAYER                          │
│                   (stockelper-kg)                            │
│                                                              │
│  collectors/dart.py:                                         │
│    - OpenDartReader.finstate(stock_code, year, quarter)     │
│    - Returns: 7 financial metrics (revenue, assets, etc.)   │
│    - Normalization: Korean→English, consolidation pref      │
└────────────┬────────────────────────────────────────────────┘
             │ stores
             ▼
┌─────────────────────────────────────────────────────────────┐
│                    PERSISTENCE LAYER                         │
│                    (Neo4j Graph DB)                          │
│                                                              │
│  Nodes:                                                      │
│    - Company (stock_code, corp_name, etc.)                  │
│    - FinancialStatements (revenue, net_income, etc.)        │
│  Edges:                                                      │
│    - (Company)-[:HAS_FINANCIAL_STATEMENTS]->(FS)            │
└────────────┬────────────────────────────────────────────────┘
             │ queries
             ▼
┌─────────────────────────────────────────────────────────────┐
│                    CONSUMPTION LAYER                         │
│                   (stockelper-llm)                           │
│                                                              │
│  multi_agent/fundamental_analysis_agent/tools/dart.py:      │
│    - OpenDartReader.finstate_all(stock_code, year)          │
│    - Extracts 13 IFRS accounts                              │
│    - Calculates 8 financial ratios                          │
│    - Returns analysis to LangChain agent                    │
│                                                              │
│  portfolio_multi_agent/nodes/get_financial_statement.py:    │
│    - Async wrapper around finstate_all()                    │
│    - Parallel processing for multiple stocks                │
└─────────────────────────────────────────────────────────────┘
```

**Key Observation:** LLM service calls DART API directly (not reading from Neo4j). This is a **data duplication pattern** - both KG and LLM fetch from DART independently.

---

#### **Planned Implementation (DART Event Extraction):** ❌ Not Built

```
┌─────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION LAYER                       │
│           (stockelper-airflow) ❌ NOT IMPLEMENTED            │
│                                                              │
│  dags/dart_event_extraction_dag.py:                         │
│    - Schedule: Every 3 hours                                │
│    - Scope: AI-sector stocks (MVP pilot)                    │
│    - Tasks:                                                  │
│      1. Fetch disclosure list                               │
│      2. Retrieve document bodies                            │
│      3. Extract events via LLM                              │
│      4. Store in Neo4j                                       │
└────────────┬────────────────────────────────────────────────┘
             │ triggers
             ▼
┌─────────────────────────────────────────────────────────────┐
│                    COLLECTION LAYER                          │
│            (stockelper-kg) ❌ NOT IMPLEMENTED                │
│                                                              │
│  collectors/dart_documents.py:                               │
│    - OpenDartReader.list(corp_code, start, end, "B")        │
│    - OpenDartReader.document(rcept_no)                      │
│    - Returns: DataFrame of disclosures + document bodies    │
└────────────┬────────────────────────────────────────────────┘
             │ sends documents to
             ▼
┌─────────────────────────────────────────────────────────────┐
│                    EXTRACTION LAYER                          │
│            (stockelper-llm) ❌ NOT IMPLEMENTED               │
│                                                              │
│  prompts/dart_event_extraction.py:                          │
│    - LLM prompt with 18 event type definitions              │
│    - Sentiment scoring instructions                         │
│                                                              │
│  extractors/dart_event_classifier.py:                       │
│    - gpt-5.1 classification                                 │
│    - Outputs: ExtractedEvent objects                        │
│      * event_type (18 types from ontology)                  │
│      * category (7 DART categories)                         │
│      * sentiment (-1.0 to 1.0)                              │
│      * context (amount, market_cap_ratio, etc.)             │
└────────────┬────────────────────────────────────────────────┘
             │ sends extracted events to
             ▼
┌─────────────────────────────────────────────────────────────┐
│                    PERSISTENCE LAYER                         │
│            (stockelper-kg) ❌ NOT IMPLEMENTED                │
│                                                              │
│  graph/dart_event_builder.py:                               │
│    - Creates Document nodes                                 │
│    - Creates Event nodes                                    │
│    - Creates relationships:                                 │
│      * (Event)-[:REPORTED_BY]->(Document)                   │
│      * (Company)-[:INVOLVED_IN]->(Event)                    │
│      * (Event)-[:OCCURRED_ON]->(EventDate)                  │
└────────────┬────────────────────────────────────────────────┘
             │ stores in
             ▼
┌─────────────────────────────────────────────────────────────┐
│                    PERSISTENCE LAYER                         │
│                    (Neo4j Graph DB)                          │
│                                                              │
│  Nodes:                                                      │
│    - Document (rcept_no, report_nm, body, url)              │
│    - Event (event_id, event_type, sentiment, date)          │
│    - EventDate (date)                                        │
│  Edges:                                                      │
│    - (Company)-[:INVOLVED_IN]->(Event)                      │
│    - (Event)-[:REPORTED_BY]->(Document)                     │
│    - (Event)-[:OCCURRED_ON]->(EventDate)                    │
│    - (EventDate)-[:IS_DATE]->(Date)                         │
└────────────┬────────────────────────────────────────────────┘
             │ queries (future)
             ▼
┌─────────────────────────────────────────────────────────────┐
│                    CONSUMPTION LAYER                         │
│            (stockelper-llm) ❌ NOT IMPLEMENTED               │
│                                                              │
│  Planned Usage:                                              │
│    - Event-based prediction agents                          │
│    - Similar event pattern matching                         │
│    - Sentiment-weighted stock recommendations               │
│    - Historical event impact analysis                       │
└─────────────────────────────────────────────────────────────┘
```

---

### Service Responsibilities Summary

#### **stockelper-kg (KG Builder Service)**

**Current Responsibilities:**
- ✅ Collect financial statements via `finstate()`
- ✅ Normalize financial data (Korean→English mapping)
- ✅ Store Company nodes in Neo4j
- ✅ Store FinancialStatements nodes in Neo4j
- ✅ Validate DART API endpoints (via data_validator in Airflow)

**Planned Responsibilities (NOT IMPLEMENTED):**
- ❌ Collect DART disclosure lists via `list()`
- ❌ Retrieve document bodies via `document()`
- ❌ Store Document nodes in Neo4j
- ❌ Store Event nodes in Neo4j (after LLM extraction)
- ❌ Create Event-Document-Company relationships

**Key Files:**
- `src/stockelper_kg/collectors/dart.py` ✅
- `src/stockelper_kg/config.py` ✅
- `src/stockelper_kg/graph/ontology.py` ✅ (defines Event/Document schemas)
- `legacy/stock_graph.py` ⚠️ (legacy, being phased out)

---

#### **stockelper-llm (LLM Service)**

**Current Responsibilities:**
- ✅ Fetch financial statements directly from DART API (`finstate_all`)
- ✅ Calculate 8 financial ratios from IFRS accounts
- ✅ Provide FundamentalAnalysisTool for LangChain agents
- ✅ Async portfolio-level financial analysis
- ✅ Fetch company metadata via `company()` for portfolio tools

**Planned Responsibilities (NOT IMPLEMENTED):**
- ❌ LLM-based event extraction from DART documents (gpt-5.1)
- ❌ Event type classification (18 ontology types)
- ❌ Sentiment scoring for events (-1.0 to 1.0)
- ❌ Event context extraction (amount, market_cap_ratio, purpose, timing)
- ❌ Event-based prediction logic

**Key Files:**
- `src/multi_agent/fundamental_analysis_agent/tools/dart.py` ✅
- `src/portfolio_multi_agent/nodes/get_financial_statement.py` ✅
- `src/multi_agent/portfolio_analysis_agent/tools/portfolio.py` ✅

---

#### **stockelper-airflow (Orchestration Service)**

**Current Responsibilities:**
- ✅ Validate DART API schemas (`modules/api/data_validator.py`)
- ✅ Test company lookup (`find_corp_code`, `company`)
- ⚠️ Implied: Schedule financial statement collection (no explicit DAG found)

**Planned Responsibilities (NOT IMPLEMENTED):**
- ❌ Schedule DART event extraction (every 3 hours)
- ❌ Orchestrate document collection → event extraction → storage pipeline
- ❌ Retry logic for failed extractions
- ❌ Monitoring and alerting for extraction failures

**Key Files:**
- `modules/api/data_validator.py` ✅
- `dags/dart_event_extraction_dag.py` ❌ (should exist, doesn't)

---

### Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                         DART API                                 │
│               (금융감독원 전자공시시스템)                          │
│                                                                  │
│  Methods Used:                        Methods Planned:           │
│    ✅ company(corp_code)                ❌ list(corp_code, ...)  │
│    ✅ find_corp_code(name)              ❌ document(rcept_no)    │
│    ✅ finstate(...)                     ❌ document_text(...)    │
│    ✅ finstate_all(...)                 ❌ document_url(...)     │
└──────────────┬───────────────────────────────┬───────────────────┘
               │                               │
               │ Used by                       │ Planned (not implemented)
               ▼                               ▼
┌──────────────────────────┐    ┌──────────────────────────────────┐
│   stockelper-kg          │    │   stockelper-kg (future)         │
│   collectors/dart.py     │    │   collectors/dart_documents.py   │
│                          │    │                                  │
│  finstate() → 7 metrics  │    │  list() → disclosure list        │
│  Korean→English mapping  │    │  document() → document body      │
└──────────┬───────────────┘    └────────────┬─────────────────────┘
           │                                 │
           │ stores                          │ would send to
           ▼                                 ▼
┌──────────────────────────┐    ┌──────────────────────────────────┐
│   Neo4j Graph DB         │    │   stockelper-llm (future)        │
│                          │    │   extractors/event_classifier    │
│  Company nodes           │    │                                  │
│  FinancialStatements     │    │  gpt-5.1 event extraction        │
│  nodes                   │    │  Sentiment scoring               │
└──────────┬───────────────┘    └────────────┬─────────────────────┘
           │                                 │
           │ queried by (future)             │ would store
           │                                 ▼
           │                    ┌──────────────────────────────────┐
           │                    │   stockelper-kg (future)         │
           │                    │   graph/dart_event_builder.py    │
           │                    │                                  │
           │                    │  Document nodes                  │
           │                    │  Event nodes                     │
           │                    │  Relationships                   │
           │                    └────────────┬─────────────────────┘
           │                                 │
           │                                 │ would store
           │◄────────────────────────────────┘
           │
           ▼
┌──────────────────────────────────────────────────────────────────┐
│   stockelper-llm (current + future)                              │
│                                                                  │
│  Current:                                Future:                 │
│    ✅ fundamental_analysis_agent          ❌ event-based         │
│       (calls DART API directly)             predictions         │
│    ✅ portfolio_multi_agent                ❌ similar event      │
│       (async financial analysis)            pattern matching    │
│                                             ❌ sentiment-weighted │
│                                                recommendations   │
└──────────────────────────────────────────────────────────────────┘
```

---

### Environment Variables Required

| Variable | Service | Purpose | Status |
|----------|---------|---------|--------|
| `OPEN_DART_API_KEY` | stockelper-kg | Financial statement collection | ✅ Used |
| `OPEN_DART_API_KEY` | stockelper-llm | Direct financial analysis calls | ✅ Used |
| `OPEN_DART_API_KEY` | stockelper-airflow | API validation | ✅ Used |
| `NEO4J_URI` | stockelper-kg | Graph database connection | ✅ Used |
| `NEO4J_USER` | stockelper-kg | Graph database auth | ✅ Used |
| `NEO4J_PASSWORD` | stockelper-kg | Graph database auth | ✅ Used |
| `OPENAI_API_KEY` | stockelper-llm | LLM inference (gpt-5.1) | ✅ Used |

---

## Summary & Recommendations

### ✅ **What Works Today**

1. **Financial Statement Collection:**
   - Robust quarterly data collection via `finstate()`
   - Comprehensive IFRS account extraction via `finstate_all()`
   - Korean→English normalization
   - Neo4j storage with Company and FinancialStatements nodes

2. **Financial Analysis:**
   - 8 calculated financial ratios (current ratio, ROE, debt ratio, etc.)
   - LangChain tool integration for multi-agent system
   - Async portfolio-level analysis

3. **Company Metadata:**
   - Company lookup via `company()` and `find_corp_code()`
   - Validation infrastructure in place

---

### ❌ **Critical Gaps**

1. **No DART Document Retrieval:**
   - `list()` method never called
   - `document()` / `document_text()` methods never called
   - No disclosure document storage

2. **No Event Extraction:**
   - Ontology fully defined (18 event types, 7 categories)
   - Documentation comprehensive (DART main events with real examples)
   - **Zero implementation code**

3. **No Orchestration:**
   - No Airflow DAG for event extraction
   - No scheduled pipeline

---

### 🎯 **Priority Recommendations**

**High Priority (P0):**
1. Implement `DartDocumentCollector` in `stockelper-kg/collectors/`
2. Implement `DartEventExtractor` in `stockelper-llm/extractors/`
3. Create Airflow DAG for 3-hour scheduled extraction
4. Implement Document/Event node storage in Neo4j

**Medium Priority (P1):**
5. Sentiment scoring logic based on DART event patterns
6. Event-Document-Company relationship creation
7. End-to-end testing with real DART disclosures

**Low Priority (P2):**
8. LLM prompt optimization for event extraction accuracy
9. Performance tuning for large document bodies
10. Monitoring and alerting infrastructure

---

### 📊 **Effort Estimation**

| Component | Complexity | Estimated Effort | Dependencies |
|-----------|------------|------------------|--------------|
| DartDocumentCollector | Low | 1-2 days | OpenDartReader library |
| DartEventExtractor | High | 5-7 days | gpt-5.1 prompts, ontology |
| DartEventGraphBuilder | Medium | 2-3 days | Neo4j schema |
| Airflow DAG | Medium | 2-3 days | All collectors/extractors |
| End-to-end testing | Medium | 3-4 days | All components |
| **Total** | | **13-19 days** | |

---

### 🔒 **Security Considerations**

- ✅ API keys loaded from environment variables (not hardcoded)
- ✅ `.env.example` files provided for reference
- ⚠️ Ensure rate limiting on DART API calls (currently 0.1s sleep)
- ⚠️ Sanitize document body text before Neo4j storage (prevent injection)
- ⚠️ Implement access controls for Neo4j Event nodes (sensitive disclosure data)

---

## Conclusion

The Stockelper codebase has **comprehensive planning** for DART disclosure event extraction, including:
- ✅ Complete ontology definitions (18 event types)
- ✅ Detailed documentation (7 DART categories with real examples)
- ✅ Clear architectural patterns (KG collection, LLM extraction, Neo4j storage)

However, **zero implementation code exists** for:
- ❌ Document retrieval (`list`, `document`)
- ❌ Event extraction (LLM-based classification)
- ❌ Event storage (Document/Event nodes)
- ❌ Orchestration (Airflow DAG)

**Recommendation:** Follow the proposed implementation design in Section B to bridge the gap between documentation and reality. The proposed function signatures, storage schemas, and service boundaries align with existing architectural patterns and should integrate smoothly with current systems.

---

**End of Report**
