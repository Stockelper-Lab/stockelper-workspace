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

## B) Filing-Document-Based Event Extraction Status

### ❌ **Status: NOT IMPLEMENTED**

Despite comprehensive planning in documentation and ontology definitions, **filing-document-based event extraction is NOT implemented** in the current codebase.

---

### Evidence of Planning (Documentation)

#### 1. **Ontology Definition** (`stockelper-kg/graph/ontology.py`)

**Document Node Definition (Lines 212-254):**
```python
NodeDefinition(
    name="Document",
    description="원천 데이터(공시, 뉴스 기사)",
    primary_keys=(("rcept_no",), ("document_id",), ("url",), ("title",)),
    properties=(
        NodeProperty("공시번호", "rcept_no", "OpenDART list.json",
                     'dart.list_filings(cc,"2025-01-01","2025-12-31","B").iloc[0]["rcept_no"]'),
        NodeProperty("제목", "report_nm", "OpenDART list.json",
                     'df.iloc[0]["report_nm"]'),
        NodeProperty("게시일", "rcept_dt", "OpenDART list.json",
                     'df.iloc[0]["rcept_dt"]'),
        NodeProperty("URL", "url", "DART viewer / 뉴스 링크",
                     "dart.document_url(rcept_no)"),
        NodeProperty("본문", "body", "OpenDART document.xml / 기사 전문",
                     "dart.document_text(rcept_no)"),
    ),
)
```

**Event Node Definition (Lines 179-210):**
```python
NodeDefinition(
    name="Event",
    description="기업의 사건(공시, 뉴스)",
    primary_keys=(("event_id",),),
    properties=(
        NodeProperty("사건ID", "event_id", "내부", 'f"EVT_{rcept_no}"'),
        NodeProperty("유형(L1)", "pblntf_ty", "OpenDART list.json",
                     'row.get("pblntf_ty", "B")'),
        NodeProperty("유형(L2)", "pblntf_detail_ty", "OpenDART list.json",
                     'row.get("pblntf_detail_ty", row.get("report_nm"))'),
        NodeProperty("일자", "reported_at", "OpenDART list.json",
                     'row["rcept_dt"]'),
    ),
)
```

**18 Event Type Definitions (Lines 764-904):**
- SUPPLY_CAPACITY_CHANGE (공장 건설/증설)
- SUPPLY_HALT (라인/사업장 가동중단)
- DEMAND_SALES_CONTRACT (판매/공급계약)
- REVENUE_EARNINGS (실적 발표)
- EFFICIENCY_AUTOMATION (자동화/DX 투자)
- STRATEGY_MNA (M&A/인수합병)
- STRATEGY_SPINOFF (분할·분할합병)
- STRATEGY_OVERSEAS (해외 투자/법인 설립)
- STRATEGY_PARTNERSHIP (전략적 제휴/MOU)
- TECH_NEW_PRODUCT (신제품/신기술 출시)
- WORKFORCE_EVENT (인력 감축/채용/파업)
- LEGAL_LITIGATION (소송/규제 제재)
- CRISIS_EVENT (화재/횡령/사이버공격)
- PRODUCT_RECALL (리콜/판매중단)
- POLICY_IMPACT (정부 정책/규제 변화)
- VIRAL_EVENT (테마주/밈)
- OWNERSHIP_CHANGE (최대주주 변경/지분 매각)
- REGULATORY_APPROVAL (FDA 승인/특허 등록)
- OTHER (기타)

---

#### 2. **DART Event Documentation** (`docs/references/DART(main events).md`)

Comprehensive documentation of DART disclosure events with real-world examples:

**7 Major Categories:**
1. **자본 변동 관련** (Capital Changes)
   - 유상증자결정 (Paid-in capital increase)
   - 제3자배정 유상증자 (Third-party allocation)
   - CB/BW 발행 (Convertible/bond warrants)
   - 자기주식 취득/소각 (Treasury stock acquisition/retirement)
   - 감자결정 (Capital reduction)

2. **M&A 및 지배구조** (M&A & Governance)
   - 주식양수도계약 (Share transfer)
   - 합병/분할 (Merger/spinoff)
   - 최대주주 변경 (Major shareholder change)
   - 경영권 변경 (Management change)

3. **재무 관련** (Financial)
   - 영업실적 (Operating results)
   - 손익구조 변경 (Profit structure change)
   - 회생절차/부도 (Bankruptcy/default)

4. **영업 및 사업** (Business Operations)
   - 신규사업 진출 (New business entry)
   - 타법인 계약 체결 (Contract signing)
   - 공장 가동중단/재가동 (Plant halt/restart)

5. **배당** (Dividends)
   - 현금/현물배당 (Cash/stock dividends)

6. **소송 및 분쟁** (Legal)
   - 소송 제기/판결 (Litigation)
   - 횡령/배임 (Embezzlement/breach of trust)

7. **기타** (Other)
   - 상장폐지 (Delisting)
   - 풍문 해명 (Rumor clarification)

**Real Examples with Price Impact:**
- CJ CGV 유상증자 (2023.06): 주가 -30%
- SK이노베이션 유상증자 (2023.06): 주가 -6.08%
- HMM 자사주 소각 (2025.08): 주가 +10%

---

#### 3. **Data Collection Planning** (`docs/references/knowledge-graph-data-collection-planning.md`)

**Planned DART API Methods (Lines 20-82):**

| Entity | Property | Planned API Method | Status |
|--------|----------|-------------------|--------|
| Document | rcept_no | `dart.list_filings(cc, start, end, "B")` | ❌ Not Used |
| Document | report_nm | `df.iloc[0]["report_nm"]` | ❌ Not Used |
| Document | rcept_dt | `df.iloc[0]["rcept_dt"]` | ❌ Not Used |
| Document | url | `dart.document_url(rcept_no)` | ❌ Not Used |
| Document | body | `dart.document_text(rcept_no)` | ❌ Not Used |

**Note:** These methods exist in OpenDartReader library but are NOT called anywhere in the Stockelper codebase.

---

### Missing Implementation Components

#### 1. **No Document Collection Pipeline**

**Expected Flow (not implemented):**
```
Company (corp_code)
    ↓
dart.list_filings(corp_code, start_date, end_date, "B")  # ❌ Not called
    ↓
rcept_no (disclosure ID)
    ↓
dart.document(rcept_no) or dart.document_text(rcept_no)  # ❌ Not called
    ↓
Document body (XML/text)
    ↓
LLM-based event extraction  # ❌ Not implemented
    ↓
Event nodes in Neo4j  # ❌ Not stored
```

**Current Reality:**
- Only financial statements (`finstate`, `finstate_all`) are collected
- No document retrieval or parsing
- No event extraction from disclosure text
- Event nodes defined in ontology but never created

---

#### 2. **No Event Extraction Logic**

**Missing Components:**
- LLM prompt engineering for event extraction
- Event type classification logic
- Sentiment scoring for DART events
- Event-Document relationship creation
- Event-Company relationship creation

**From Epic 1.1b Documentation:**
```markdown
Story 1.1b: DART Disclosure Event Extraction with Sentiment Scoring

Acceptance Criteria:
- Extract financial events from DART disclosures using distinct DART-specific prompts
- Extract sentiment score (-1 to 1 range) for each DART event
- Assign source attribute "DART" to all extracted events
- Classify events into 7 major DART categories
- Extract event context: amount, market cap ratio, purpose, timing

Files affected:
- /stockelper-airflow/dags/dart_event_extraction_dag.py (new DAG)  # ❌ Does not exist
- /stockelper-kg/src/stockelper_kg/dart/ (new module)              # ❌ Does not exist
- /stockelper-kg/prompts/dart_event_extraction.py                  # ❌ Does not exist
- /stockelper-kg/ontology/dart_events.py                           # ❌ Does not exist
```

---

#### 3. **No Airflow DAG for DART Event Collection**

**Expected DAG (not implemented):**
```python
# /stockelper-airflow/dags/dart_event_extraction_dag.py  ❌ DOES NOT EXIST

from airflow import DAG
from datetime import datetime

dag = DAG(
    'dart_event_extraction',
    start_date=datetime(2025, 1, 1),
    schedule_interval='0 */3 * * *',  # Every 3 hours
)

# Expected tasks:
# 1. Fetch disclosure list for AI-sector stocks
# 2. Retrieve document bodies for new disclosures
# 3. Extract events using LLM (gpt-5.1)
# 4. Store in Neo4j with sentiment scores
# 5. Create Document/Event nodes and relationships
```

**Current Reality:**
- No Airflow DAG for DART document collection
- No scheduled event extraction
- Only financial statements collected via existing patterns

---

### Gap Analysis

| Component | Planned | Implemented | Gap |
|-----------|---------|-------------|-----|
| **DART API Methods** |
| `company()` | ✅ | ✅ | None |
| `find_corp_code()` | ✅ | ✅ | None |
| `finstate()` | ✅ | ✅ | None |
| `finstate_all()` | ✅ | ✅ | None |
| `list()` / `list_filings()` | ✅ | ❌ | **Missing** |
| `document()` / `document_text()` | ✅ | ❌ | **Missing** |
| `document_url()` | ✅ | ❌ | **Missing** |
| **Data Models** |
| Company node | ✅ | ✅ | None |
| FinancialStatements node | ✅ | ✅ | None |
| Document node | ✅ | ❌ | **Missing** |
| Event node | ✅ | ❌ | **Missing** |
| **Workflows** |
| Financial statement collection | ✅ | ✅ | None |
| DART document collection | ✅ | ❌ | **Missing** |
| Event extraction from documents | ✅ | ❌ | **Missing** |
| Sentiment scoring | ✅ | ❌ | **Missing** |
| Event-Document linking | ✅ | ❌ | **Missing** |

---

### Proposed Implementation Design

#### **Service Boundary Decisions**

Based on existing patterns and BMAD architectural principles:

| Component | Service | Rationale |
|-----------|---------|-----------|
| **DART Document Collection** | `stockelper-kg` | Aligns with existing `collectors/dart.py` pattern |
| **Event Extraction (LLM)** | `stockelper-llm` | gpt-5.1 event classification requires LLM service |
| **Orchestration** | `stockelper-airflow` | Scheduled execution, same as news extraction |
| **Storage** | `stockelper-kg` | Neo4j graph storage, same as other entities |

---

#### **Module Structure**

```
stockelper-kg/
└── src/stockelper_kg/
    ├── collectors/
    │   ├── dart.py                    # ✅ Existing (financial statements)
    │   └── dart_documents.py          # 🆕 NEW (disclosure documents)
    ├── extractors/
    │   └── dart_event_extractor.py    # 🆕 NEW (event extraction logic)
    └── graph/
        └── dart_event_builder.py      # 🆕 NEW (Document/Event nodes)

stockelper-llm/
└── src/
    ├── prompts/
    │   └── dart_event_extraction.py   # 🆕 NEW (LLM prompts for events)
    └── tools/
        └── dart_event_classifier.py   # 🆕 NEW (LangChain tool)

stockelper-airflow/
└── dags/
    └── dart_event_extraction_dag.py   # 🆕 NEW (orchestration DAG)
```

---

#### **Proposed Function Signatures**

**1. Document Collector** (`stockelper-kg/collectors/dart_documents.py`)

```python
from typing import List, Dict, Optional
from datetime import datetime
import pandas as pd
from OpenDartReader import OpenDartReader


class DartDocumentCollector:
    """Collects DART disclosure documents for event extraction."""

    def __init__(self, api_key: str):
        self.dart = OpenDartReader(api_key)

    def fetch_disclosure_list(
        self,
        corp_code: str,
        start_date: str,  # YYYYMMDD
        end_date: str,    # YYYYMMDD
        pblntf_ty: str = "B"  # B=정기공시, A=정기공시, C=정정공시
    ) -> pd.DataFrame:
        """
        Fetch list of disclosures for a company within date range.

        Returns DataFrame with columns:
        - rcept_no (str): Disclosure receipt number
        - corp_code (str): Company code
        - corp_name (str): Company name
        - stock_code (str): Stock code
        - report_nm (str): Report name/title
        - rcept_dt (str): Receipt date YYYYMMDD
        - pblntf_ty (str): Publication type
        - pblntf_detail_ty (str): Detailed type
        - corp_cls (str): Corp class (Y/K/N/E)
        - rm (str): Remarks
        """
        df = self.dart.list(corp_code, start_date, end_date, pblntf_ty)
        return df

    def fetch_document_body(
        self,
        rcept_no: str
    ) -> Optional[str]:
        """
        Fetch full document body text for a disclosure.

        Args:
            rcept_no: Disclosure receipt number

        Returns:
            str: Document body text (XML converted to text)
            None: If document unavailable
        """
        try:
            # OpenDartReader provides document() method
            doc = self.dart.document(rcept_no)
            return doc
        except Exception as e:
            print(f"Failed to fetch document {rcept_no}: {e}")
            return None

    def get_document_url(self, rcept_no: str) -> str:
        """Generate DART viewer URL for a disclosure."""
        return f"https://dart.fss.or.kr/dsaf001/main.do?rcpNo={rcept_no}"
```

**Input/Output Summary:**

| Method | Input | Output |
|--------|-------|--------|
| `fetch_disclosure_list()` | corp_code, start_date, end_date | DataFrame (rcept_no, report_nm, rcept_dt, etc.) |
| `fetch_document_body()` | rcept_no | str (document text) or None |
| `get_document_url()` | rcept_no | str (DART viewer URL) |

---

**2. Event Extractor** (`stockelper-kg/extractors/dart_event_extractor.py`)

```python
from typing import List, Dict, Optional
from dataclasses import dataclass
from enum import Enum


class DartEventCategory(Enum):
    """7 major DART event categories."""
    CAPITAL_CHANGES = "자본 변동"
    MNA_GOVERNANCE = "M&A 및 지배구조"
    FINANCIAL = "재무 관련"
    BUSINESS_OPS = "영업 및 사업"
    DIVIDENDS = "배당"
    LEGAL = "소송 및 분쟁"
    OTHER = "기타"


@dataclass
class ExtractedEvent:
    """Structured event extraction result."""
    event_id: str                    # e.g., "EVT_20250101000001"
    event_type: str                  # Ontology event type
    category: DartEventCategory      # 7-category classification
    sentiment: float                 # -1.0 to 1.0
    description: str                 # Event description
    date: str                        # YYYY-MM-DD
    context: Dict[str, any]          # amount, market_cap_ratio, purpose, timing
    confidence: float                # Extraction confidence 0-1
    source: str = "DART"

    def to_neo4j_dict(self) -> Dict:
        """Convert to Neo4j node properties."""
        return {
            "event_id": self.event_id,
            "event_type": self.event_type,
            "category": self.category.value,
            "sentiment": self.sentiment,
            "description": self.description,
            "date": self.date,
            "source": self.source,
            "confidence": self.confidence,
            **self.context
        }


class DartEventExtractor:
    """Extracts events from DART disclosure documents using LLM."""

    def __init__(self, llm_client):
        """
        Args:
            llm_client: LLM service client (gpt-5.1)
        """
        self.llm = llm_client
        self.ontology = load_dart_ontology()  # 18 event types + 7 categories

    def extract_events(
        self,
        document_body: str,
        rcept_no: str,
        report_nm: str,
        rcept_dt: str
    ) -> List[ExtractedEvent]:
        """
        Extract structured events from document text.

        Args:
            document_body: Full disclosure text
            rcept_no: Disclosure ID
            report_nm: Report title
            rcept_dt: Receipt date YYYYMMDD

        Returns:
            List of ExtractedEvent objects
        """
        # Construct LLM prompt with ontology
        prompt = self._build_extraction_prompt(
            document_body, report_nm, self.ontology
        )

        # Call LLM (gpt-5.1)
        response = self.llm.complete(prompt)

        # Parse structured output
        events = self._parse_llm_response(response, rcept_no, rcept_dt)

        return events

    def _build_extraction_prompt(
        self,
        document_body: str,
        report_nm: str,
        ontology: Dict
    ) -> str:
        """Build LLM prompt with DART-specific instructions."""
        # Prompt engineering for DART event extraction
        # - Include 18 event type definitions
        # - Include 7 category mappings
        # - Request sentiment score (-1 to 1)
        # - Request event context extraction
        # - Emphasize DART-specific patterns
        pass

    def _parse_llm_response(
        self,
        response: str,
        rcept_no: str,
        rcept_dt: str
    ) -> List[ExtractedEvent]:
        """Parse LLM JSON output into ExtractedEvent objects."""
        pass

    def calculate_sentiment(
        self,
        event_type: str,
        event_description: str
    ) -> float:
        """
        Calculate sentiment score for event.

        Uses DART event impact patterns from:
        docs/references/DART(main events).md

        Returns:
            float: -1.0 (negative) to 1.0 (positive)
        """
        # Sentiment mapping based on DART event patterns
        # Example:
        # - 유상증자 → -0.7 (typically negative)
        # - 자사주 소각 → +0.8 (typically positive)
        # - 실적 발표 → contextual (depends on consensus)
        pass
```

**Input/Output Summary:**

| Method | Input | Output |
|--------|-------|--------|
| `extract_events()` | document_body, rcept_no, report_nm, rcept_dt | List[ExtractedEvent] |
| `calculate_sentiment()` | event_type, event_description | float (-1.0 to 1.0) |

---

**3. Graph Builder** (`stockelper-kg/graph/dart_event_builder.py`)

```python
from typing import List
from neo4j import GraphDatabase
from .dart_event_extractor import ExtractedEvent


class DartEventGraphBuilder:
    """Builds Document and Event nodes in Neo4j knowledge graph."""

    def __init__(self, neo4j_uri: str, neo4j_user: str, neo4j_password: str):
        self.driver = GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password))

    def create_document_node(
        self,
        rcept_no: str,
        report_nm: str,
        rcept_dt: str,
        corp_code: str,
        url: str,
        body: str
    ) -> None:
        """
        Create Document node in Neo4j.

        Cypher:
        MERGE (d:Document {rcept_no: $rcept_no})
        SET d.report_nm = $report_nm,
            d.rcept_dt = $rcept_dt,
            d.url = $url,
            d.body = $body
        """
        query = """
        MERGE (d:Document {rcept_no: $rcept_no})
        SET d.report_nm = $report_nm,
            d.rcept_dt = $rcept_dt,
            d.url = $url,
            d.body = $body,
            d.source = 'DART'
        """
        with self.driver.session() as session:
            session.run(query, rcept_no=rcept_no, report_nm=report_nm,
                       rcept_dt=rcept_dt, url=url, body=body)

    def create_event_node(
        self,
        event: ExtractedEvent
    ) -> None:
        """
        Create Event node in Neo4j.

        Cypher:
        MERGE (e:Event {event_id: $event_id})
        SET e.event_type = $event_type,
            e.category = $category,
            e.sentiment = $sentiment,
            e.description = $description,
            e.date = $date,
            e.source = $source
        """
        query = """
        MERGE (e:Event {event_id: $event_id})
        SET e += $properties
        """
        with self.driver.session() as session:
            session.run(query, event_id=event.event_id,
                       properties=event.to_neo4j_dict())

    def link_event_to_document(
        self,
        event_id: str,
        rcept_no: str
    ) -> None:
        """
        Create REPORTED_BY relationship: Event → Document.

        Cypher:
        MATCH (e:Event {event_id: $event_id})
        MATCH (d:Document {rcept_no: $rcept_no})
        MERGE (e)-[:REPORTED_BY]->(d)
        """
        query = """
        MATCH (e:Event {event_id: $event_id})
        MATCH (d:Document {rcept_no: $rcept_no})
        MERGE (e)-[:REPORTED_BY]->(d)
        """
        with self.driver.session() as session:
            session.run(query, event_id=event_id, rcept_no=rcept_no)

    def link_event_to_company(
        self,
        event_id: str,
        stock_code: str
    ) -> None:
        """
        Create INVOLVED_IN relationship: Company → Event.

        Cypher:
        MATCH (c:Company {stock_code: $stock_code})
        MATCH (e:Event {event_id: $event_id})
        MERGE (c)-[:INVOLVED_IN]->(e)
        """
        query = """
        MATCH (c:Company {stock_code: $stock_code})
        MATCH (e:Event {event_id: $event_id})
        MERGE (c)-[:INVOLVED_IN]->(e)
        """
        with self.driver.session() as session:
            session.run(query, event_id=event_id, stock_code=stock_code)
```

**Input/Output Summary:**

| Method | Input | Output |
|--------|-------|--------|
| `create_document_node()` | rcept_no, report_nm, rcept_dt, corp_code, url, body | None (creates node) |
| `create_event_node()` | ExtractedEvent | None (creates node) |
| `link_event_to_document()` | event_id, rcept_no | None (creates edge) |
| `link_event_to_company()` | event_id, stock_code | None (creates edge) |

---

**4. Airflow DAG** (`stockelper-airflow/dags/dart_event_extraction_dag.py`)

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
from stockelper_kg.collectors.dart_documents import DartDocumentCollector
from stockelper_kg.extractors.dart_event_extractor import DartEventExtractor
from stockelper_kg.graph.dart_event_builder import DartEventGraphBuilder
import os


# AI-sector stock codes (MVP pilot scope)
AI_SECTOR_STOCKS = [
    "035420",  # 네이버
    "035720",  # 카카오
    "047560",  # 이스트소프트
    # ... other AI stocks
]


def fetch_and_extract_events(**context):
    """Main task: fetch disclosures and extract events."""

    # Initialize collectors
    dart_collector = DartDocumentCollector(
        api_key=os.getenv("OPEN_DART_API_KEY")
    )
    event_extractor = DartEventExtractor(
        llm_client=get_llm_client()  # gpt-5.1
    )
    graph_builder = DartEventGraphBuilder(
        neo4j_uri=os.getenv("NEO4J_URI"),
        neo4j_user=os.getenv("NEO4J_USER"),
        neo4j_password=os.getenv("NEO4J_PASSWORD")
    )

    # Date range: last 3 hours
    end_date = datetime.now().strftime("%Y%m%d")
    start_date = (datetime.now() - timedelta(hours=3)).strftime("%Y%m%d")

    for stock_code in AI_SECTOR_STOCKS:
        # Get corp_code from stock_code
        corp_code = get_corp_code(stock_code)

        # Fetch disclosure list
        disclosures = dart_collector.fetch_disclosure_list(
            corp_code, start_date, end_date, pblntf_ty="B"
        )

        for _, row in disclosures.iterrows():
            rcept_no = row["rcept_no"]

            # Fetch document body
            body = dart_collector.fetch_document_body(rcept_no)
            if body is None:
                continue

            # Create Document node
            graph_builder.create_document_node(
                rcept_no=rcept_no,
                report_nm=row["report_nm"],
                rcept_dt=row["rcept_dt"],
                corp_code=corp_code,
                url=dart_collector.get_document_url(rcept_no),
                body=body
            )

            # Extract events
            events = event_extractor.extract_events(
                document_body=body,
                rcept_no=rcept_no,
                report_nm=row["report_nm"],
                rcept_dt=row["rcept_dt"]
            )

            # Store events
            for event in events:
                graph_builder.create_event_node(event)
                graph_builder.link_event_to_document(event.event_id, rcept_no)
                graph_builder.link_event_to_company(event.event_id, stock_code)


# DAG definition
dag = DAG(
    'dart_event_extraction',
    description='Extract events from DART disclosures every 3 hours',
    schedule_interval='0 */3 * * *',  # Every 3 hours
    start_date=datetime(2025, 1, 1),
    catchup=False,
    default_args={
        'retries': 3,
        'retry_delay': timedelta(minutes=5),
    }
)

task = PythonOperator(
    task_id='fetch_and_extract_events',
    python_callable=fetch_and_extract_events,
    dag=dag
)
```

**DAG Schedule:** Every 3 hours (aligned with Epic 1.1b requirements)

**Input/Output:**
- **Input:** Environment variables (API keys, Neo4j credentials)
- **Output:** Document nodes, Event nodes, relationships in Neo4j

---

#### **Storage Schema**

**Neo4j Cypher Constraints:**

```cypher
-- Document node
CREATE CONSTRAINT document_rcept_no IF NOT EXISTS
FOR (d:Document) REQUIRE d.rcept_no IS UNIQUE;

-- Event node
CREATE CONSTRAINT event_id IF NOT EXISTS
FOR (e:Event) REQUIRE e.event_id IS UNIQUE;

-- EventDate node
CREATE CONSTRAINT event_date IF NOT EXISTS
FOR (ed:EventDate) REQUIRE ed.date IS UNIQUE;
```

**Document Node Schema:**
```cypher
(:Document {
    rcept_no: STRING,           # PRIMARY KEY
    report_nm: STRING,          # Report title
    rcept_dt: STRING,           # YYYYMMDD
    url: STRING,                # DART viewer URL
    body: STRING,               # Full document text
    source: STRING,             # "DART"
    created_at: DATETIME
})
```

**Event Node Schema:**
```cypher
(:Event {
    event_id: STRING,           # PRIMARY KEY (e.g., "EVT_20250101000001")
    event_type: STRING,         # Ontology type (18 types)
    category: STRING,           # 7-category classification
    sentiment: FLOAT,           # -1.0 to 1.0
    description: STRING,        # Event description
    date: STRING,               # YYYY-MM-DD
    source: STRING,             # "DART"
    confidence: FLOAT,          # 0-1

    # Context fields (optional, varies by event type)
    amount: FLOAT,              # Transaction amount
    market_cap_ratio: FLOAT,    # Relative to market cap
    purpose: STRING,            # Purpose description
    timing: STRING,             # 장중 vs 장마감

    created_at: DATETIME
})
```

**Relationships:**
```cypher
-- Event → Document
(e:Event)-[:REPORTED_BY]->(d:Document)

-- Company → Event
(c:Company)-[:INVOLVED_IN]->(e:Event)

-- Event → EventDate
(e:Event)-[:OCCURRED_ON]->(ed:EventDate)

-- EventDate → Date
(ed:EventDate)-[:IS_DATE]->(d:Date)
```

---

### Implementation Roadmap

**Phase 1: Document Collection (Week 1)**
- [ ] Create `dart_documents.py` collector
- [ ] Implement `fetch_disclosure_list()`
- [ ] Implement `fetch_document_body()`
- [ ] Unit tests with real DART API

**Phase 2: Event Extraction (Week 2-3)**
- [ ] Create `dart_event_extractor.py`
- [ ] Design LLM prompts for 18 event types
- [ ] Implement sentiment scoring logic
- [ ] Test event extraction on sample disclosures

**Phase 3: Graph Storage (Week 3)**
- [ ] Create `dart_event_builder.py`
- [ ] Implement Document/Event node creation
- [ ] Implement relationship creation
- [ ] Neo4j constraint setup

**Phase 4: Orchestration (Week 4)**
- [ ] Create Airflow DAG
- [ ] Implement 3-hour scheduling
- [ ] Error handling and retries
- [ ] Monitoring and logging

**Phase 5: Validation (Week 5)**
- [ ] End-to-end testing
- [ ] Validate against DART(main events).md examples
- [ ] Sentiment score accuracy review
- [ ] Performance optimization

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
