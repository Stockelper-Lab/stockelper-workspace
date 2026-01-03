# CURSOR PROMPT: Implement DART 36 Major Report Type Collection

## Context

You are implementing the DART (Data Analysis, Retrieval and Transfer System) disclosure collection system for the Stockelper project. This system collects 36 major report types from the Korean Financial Supervisory Service's electronic disclosure system using structured API endpoints.

**Updated Strategy (2026-01-03):**
- Previous approach (generic `list()` → `document()` → LLM extraction) has been replaced
- New approach uses 36 structured major report type APIs with dedicated endpoints per type
- Direct structured data extraction without LLM parsing
- Storage: Local PostgreSQL (NOT remote AWS)

**Key References:**
- `docs/architecture.md` - Lines 232-377 (DART 36 Major Report Type Collection architecture)
- `docs/DART-implementation-analysis.md` - Section B (Lines 425-863)
- `docs/references/DART(modified events).md` - Complete implementation code by 민우 (2026-01-03)
- `docs/meeting-analysis-2026-01-03.md` - Section 1 (DART Data Collection requirements)

---

## Implementation Requirements

### 1. Universe Template Creation

**File:** `stockelper-kg/modules/dart_disclosure/universe.ai-sector.template.json`

**Purpose:** Define the specific list of AI-sector stocks for DART disclosure collection

**Schema:**
```json
{
  "name": "AI Sector Universe",
  "description": "Investment candidate stocks in AI sector",
  "last_updated": "2026-01-03",
  "version": "1.0",
  "stocks": [
    {
      "corp_code": "00126380",
      "stock_code": "005930",
      "corp_name": "삼성전자",
      "sector": "AI Semiconductors",
      "market_cap_tier": "large"
    },
    {
      "corp_code": "00164742",
      "stock_code": "035420",
      "corp_name": "NAVER",
      "sector": "AI Services",
      "market_cap_tier": "large"
    },
    {
      "corp_code": "00108413",
      "stock_code": "000660",
      "corp_name": "SK하이닉스",
      "sector": "AI Semiconductors",
      "market_cap_tier": "large"
    }
    // Add 20-50 total AI-sector stocks
  ]
}
```

**Required Fields:**
- `corp_code` (8-digit) - DART company code
- `stock_code` (6-digit) - KRX stock ticker
- `corp_name` (Korean) - Official company name
- `sector` - AI sector classification
- `market_cap_tier` - "large", "mid", or "small"

**Validation:**
- Ensure all corp_codes are valid (8 digits)
- Ensure all stock_codes are valid (6 digits)
- Cross-reference with DART API to verify company names

---

### 2. Data Collector Implementation

**File:** `stockelper-kg/src/stockelper_kg/collectors/dart_major_reports.py`

**Purpose:** Collect 36 major report types from DART API using OpenDartReader

**Reference Implementation:** See `docs/references/DART(modified events).md` for complete code by 민우

**Class Structure:**

```python
from typing import List, Dict, Optional
from enum import Enum
from OpenDartReader import OpenDartReader
import pandas as pd
from datetime import datetime, timedelta


class MajorReportType(Enum):
    """36 major report types across 8 categories."""

    # Category 1: 기업상태 (Company Status) - 5 types
    AST_INHTRF_ETC_PTBK_OPT = ("astInhtrfEtcPtbkOpt", "자산양수도(기타)_풋백옵션", "기업상태")
    DF_OCR = ("dfOcr", "부도발생", "기업상태")
    BSN_SP = ("bsnSp", "영업정지", "기업상태")
    RVVPRPD_APSTRT_APLFN = ("rvvprpdApstrtAplfn", "회생절차_개시신청", "기업상태")
    DSLN_RSN_OCR = ("dslnRsnOcr", "해산사유_발생", "기업상태")

    # Category 2: 증자감자 (Capital Changes) - 4 types
    PIIC_DECSN = ("piicDecsn", "유상증자_결정", "증자감자")
    BDID_DECSN = ("bdidDecsn", "무상증자_결정", "증자감자")
    PIIC_BDID_DECSN = ("piicBdidDecsn", "유무상증자_결정", "증자감자")
    DSRS_DECSN = ("dsrsDecsn", "감자_결정", "증자감자")

    # Category 3: 채권은행 (Creditor Bank) - 2 types
    CRBNMNGPRCD_STR = ("crbnmngprcdStr", "채권은행_관리절차_개시", "채권은행")
    CRBNMNGPRCD_DSCD = ("crbnmngprcdDscd", "채권은행_관리절차_중단", "채권은행")

    # Category 4: 소송 (Litigation) - 1 type
    LST_FR = ("lstFr", "소송등_제기", "소송")

    # Category 5: 해외상장 (Overseas Listing) - 4 types
    OVR_SEC_MKT_LSTG_DECSN = ("ovrSecMktLstgDecsn", "해외증권시장_상장_결정", "해외상장")
    OVR_SEC_MKT_DLST_DECSN = ("ovrSecMktDlstDecsn", "해외증권시장_상장폐지_결정", "해외상장")
    OVR_SEC_MKT_LSTG = ("ovrSecMktLstg", "해외증권시장_상장", "해외상장")
    OVR_SEC_MKT_DLST = ("ovrSecMktDlst", "해외증권시장_상장폐지", "해외상장")

    # Category 6: 사채발행 (Bond Issuance) - 4 types
    CVSBNISSN_DECSN = ("cvsbnissnDecsn", "전환사채권_발행결정", "사채발행")
    BDWTISSN_DECSN = ("bdwtissnDecsn", "신주인수권부사채권_발행결정", "사채발행")
    EXBD_ISSN_DECSN = ("exbdIssnDecsn", "교환사채권_발행결정", "사채발행")
    AMCD_CPBDISSN_DECSN = ("amcdCpbdissnDecsn", "상각형_조건부자본증권_발행결정", "사채발행")

    # Category 7: 자기주식 (Treasury Stock) - 4 types
    OG_STOCK_ACQS_DECSN = ("ogStockAcqsDecsn", "자기주식_취득_결정", "자기주식")
    OG_STOCK_DSPS_DECSN = ("ogStockDspsDecsn", "자기주식_처분_결정", "자기주식")
    OG_STOCK_ACQS_TCNTR_SGNT_DECSN = ("ogStockAcqsTcntrSgntDecsn", "자기주식취득_신탁계약_체결_결정", "자기주식")
    OG_STOCK_ACQS_TCNTR_SGNT_CNLT_DECSN = ("ogStockAcqsTcntrSgntCnltDecsn", "자기주식취득_신탁계약_해지_결정", "자기주식")

    # Category 8: 영업/자산양수도 (Business/Asset Transfer) - 4+ types
    BSN_ACQS_DECSN = ("bsnAcqsDecsn", "영업양수_결정", "영업/자산양수도")
    BSN_TRNF_DECSN = ("bsnTrnfDecsn", "영업양도_결정", "영업/자산양수도")
    TNR_ASSETS_ACQS_DECSN = ("tnrAssetsAcqsDecsn", "유형자산_양수_결정", "영업/자산양수도")
    TNR_ASSETS_TRNF_DECSN = ("tnrAssetsTrnfDecsn", "유형자산_양도_결정", "영업/자산양수도")

    @property
    def api_code(self) -> str:
        """Get the DART API code for this report type."""
        return self.value[0]

    @property
    def korean_name(self) -> str:
        """Get the Korean display name."""
        return self.value[1]

    @property
    def category(self) -> str:
        """Get the category this report belongs to."""
        return self.value[2]


class DartMajorReportCollector:
    """
    Collects 36 major report types from DART API.
    Based on 민우 2026-01-03 implementation.
    """

    def __init__(self, api_key: str, postgres_conn_string: str):
        """
        Initialize collector.

        Args:
            api_key: DART Open API key
            postgres_conn_string: Local PostgreSQL connection string
                Format: "postgresql://user:password@localhost:5432/dbname"
        """
        self.dart = OpenDartReader(api_key)
        self.postgres_conn = postgres_conn_string
        self._rate_limit_delay = 0.2  # 5 requests/sec max

    def load_universe(self, universe_path: str) -> List[Dict]:
        """
        Load universe template JSON.

        Args:
            universe_path: Path to universe.ai-sector.template.json

        Returns:
            List of stock dictionaries with corp_code, stock_code, corp_name
        """
        import json
        with open(universe_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return data['stocks']

    def collect_report_type(
        self,
        corp_code: str,
        report_type: MajorReportType,
        start_date: str,  # YYYYMMDD
        end_date: str,    # YYYYMMDD
    ) -> Optional[pd.DataFrame]:
        """
        Collect specific major report type for a company.

        Args:
            corp_code: 8-digit company code
            report_type: MajorReportType enum value
            start_date: Start date in YYYYMMDD format
            end_date: End date in YYYYMMDD format

        Returns:
            DataFrame with structured report data or None if no data
        """
        import time
        time.sleep(self._rate_limit_delay)  # Rate limiting

        try:
            # Call DART API endpoint for this specific report type
            df = self.dart.major_report(
                corp=corp_code,
                report_type=report_type.api_code,
                start_date=start_date,
                end_date=end_date
            )

            if df is None or df.empty:
                return None

            # Add metadata columns
            df['report_type'] = report_type.api_code
            df['category'] = report_type.category
            df['collected_at'] = datetime.now()

            return df

        except Exception as e:
            print(f"Error collecting {report_type.korean_name} for {corp_code}: {e}")
            return None

    def collect_all_report_types(
        self,
        corp_code: str,
        lookback_days: int = 30
    ) -> Dict[str, pd.DataFrame]:
        """
        Collect all 36 major report types for a single company.

        Args:
            corp_code: 8-digit company code
            lookback_days: Number of days to look back (default: 30)

        Returns:
            Dictionary mapping report_type API code to DataFrame
        """
        end_date = datetime.now()
        start_date = end_date - timedelta(days=lookback_days)

        start_str = start_date.strftime("%Y%m%d")
        end_str = end_date.strftime("%Y%m%d")

        results = {}

        for report_type in MajorReportType:
            df = self.collect_report_type(
                corp_code=corp_code,
                report_type=report_type,
                start_date=start_str,
                end_date=end_str
            )

            if df is not None and not df.empty:
                results[report_type.api_code] = df
                print(f"✓ {report_type.korean_name}: {len(df)} records")

        return results

    def store_to_postgresql(
        self,
        report_type_code: str,
        df: pd.DataFrame
    ):
        """
        Store collected data to Local PostgreSQL.

        Args:
            report_type_code: API code for report type
            df: DataFrame with structured report data

        Table naming: dart_{report_type_code}
        Example: dart_piic_decsn for paid-in capital increase decisions
        """
        import sqlalchemy as sa

        engine = sa.create_engine(self.postgres_conn)
        table_name = f"dart_{report_type_code}"

        # Store with ON CONFLICT DO NOTHING (deduplication by rcept_no)
        df.to_sql(
            table_name,
            engine,
            if_exists='append',
            index=False,
            method='multi'
        )

        print(f"✓ Stored {len(df)} records to {table_name}")

    def collect_universe(self, universe_path: str, lookback_days: int = 30):
        """
        Collect all 36 major report types for entire universe.

        Args:
            universe_path: Path to universe.ai-sector.template.json
            lookback_days: Days to look back (default: 30)
        """
        stocks = self.load_universe(universe_path)

        for stock in stocks:
            corp_code = stock['corp_code']
            corp_name = stock['corp_name']

            print(f"\n{'='*60}")
            print(f"Collecting: {corp_name} ({corp_code})")
            print(f"{'='*60}")

            results = self.collect_all_report_types(
                corp_code=corp_code,
                lookback_days=lookback_days
            )

            # Store each report type to PostgreSQL
            for report_type_code, df in results.items():
                self.store_to_postgresql(report_type_code, df)

        print(f"\n✅ Collection complete for {len(stocks)} stocks")
```

**Implementation Notes:**
- Review `docs/references/DART(modified events).md` for the complete implementation by 민우
- The actual DART API method name should match OpenDartReader library (check if it's `major_report()` or different)
- Implement proper error handling with retries (3 attempts with exponential backoff)
- Add logging for debugging and monitoring

---

### 3. Local PostgreSQL Schema Creation

**File:** `stockelper-kg/migrations/001_create_dart_disclosure_tables.sql`

**Purpose:** Create 36 tables (one per major report type) in Local PostgreSQL

**Schema Pattern (Example for piicDecsn - Paid-in capital increase):**

```sql
-- Table: dart_piic_decsn (유상증자_결정)
CREATE TABLE IF NOT EXISTS dart_piic_decsn (
    -- Common fields (all 36 tables)
    rcept_no VARCHAR(20) PRIMARY KEY,
    corp_code VARCHAR(8) NOT NULL,
    stock_code VARCHAR(6),
    corp_name VARCHAR(100),
    rcept_dt DATE NOT NULL,

    -- Report-specific fields (varies per report type)
    nstk_astock_co BIGINT,              -- Number of new stocks allocated
    nstk_astock_estmtamt BIGINT,        -- Estimated amount
    nstk_astock_int TEXT,               -- Allocation intent
    fdpp_fclt_atrdsqp_rsn TEXT,         -- Reason for facility acquisition

    -- Metadata
    report_type VARCHAR(50) DEFAULT 'piicDecsn',
    category VARCHAR(50) DEFAULT '증자감자',
    collected_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_piic_corp
    ON dart_piic_decsn(corp_code, rcept_dt DESC);

CREATE INDEX IF NOT EXISTS idx_piic_stock
    ON dart_piic_decsn(stock_code, rcept_dt DESC);

CREATE INDEX IF NOT EXISTS idx_piic_date
    ON dart_piic_decsn(rcept_dt DESC);

-- Add unique constraint to prevent duplicates
ALTER TABLE dart_piic_decsn
    ADD CONSTRAINT unique_piic_rcept
    UNIQUE (rcept_no);
```

**Required Tables (36 total):**

Generate similar schemas for all 36 report types. Use this naming convention:
- Table name: `dart_{api_code}` (e.g., `dart_dfOcr` for default occurrence)
- All tables have common fields: rcept_no, corp_code, stock_code, corp_name, rcept_dt
- Each table has report-specific fields based on DART API response structure

**Migration Strategy:**
1. Create all 36 tables with common fields first
2. Add report-specific columns based on actual DART API responses
3. Create indexes for common query patterns
4. Add constraints for data integrity

---

### 4. Airflow DAG Implementation

**File:** `stockelper-airflow/dags/dart_disclosure_collection_dag.py`

**Purpose:** Daily scheduled collection of DART disclosures at 8:00 AM KST

**DAG Structure:**

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import os

default_args = {
    'owner': '영상',
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'execution_timeout': timedelta(hours=1),
}

dag = DAG(
    'dag_dart_disclosure_daily',
    default_args=default_args,
    description='Collect DART 36 major report types for AI-sector universe',
    schedule_interval='0 8 * * *',  # 8:00 AM KST daily
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=['dart', 'disclosure', 'data-collection'],
)


def load_universe(**context):
    """
    Task 1: Load AI-sector universe from template JSON.
    """
    import json

    universe_path = 'modules/dart_disclosure/universe.ai-sector.template.json'

    with open(universe_path, 'r', encoding='utf-8') as f:
        universe_data = json.load(f)

    corp_codes = [stock['corp_code'] for stock in universe_data['stocks']]

    context['task_instance'].xcom_push(key='corp_codes', value=corp_codes)
    context['task_instance'].xcom_push(key='universe_size', value=len(corp_codes))

    print(f"✓ Loaded {len(corp_codes)} stocks from universe")
    return len(corp_codes)


def collect_major_reports(**context):
    """
    Task 2: Collect all 36 major report types for each corp_code.
    """
    from stockelper_kg.collectors.dart_major_reports import DartMajorReportCollector

    api_key = os.getenv('OPEN_DART_API_KEY')
    postgres_conn = os.getenv('LOCAL_POSTGRES_CONN_STRING')

    corp_codes = context['task_instance'].xcom_pull(
        key='corp_codes',
        task_ids='load_universe_template'
    )

    collector = DartMajorReportCollector(
        api_key=api_key,
        postgres_conn_string=postgres_conn
    )

    # Collect with 30-day lookback
    for corp_code in corp_codes:
        results = collector.collect_all_report_types(
            corp_code=corp_code,
            lookback_days=30
        )

        # Store to Local PostgreSQL
        for report_type_code, df in results.items():
            collector.store_to_postgresql(report_type_code, df)

    print(f"✓ Collection complete for {len(corp_codes)} companies")


def extract_events(**context):
    """
    Task 3: Extract events from collected disclosure data.
    (Placeholder - to be implemented in future iteration)
    """
    # TODO: Implement event extraction with LLM
    # This will read from Local PostgreSQL and extract:
    # - Event classification (7 major categories)
    # - Sentiment scores (-1 to 1)
    # - Event context (amount, market cap ratio, timing)

    print("✓ Event extraction placeholder - to be implemented")


def pattern_matching(**context):
    """
    Task 4: Match newly extracted events with historical patterns.
    (Placeholder - to be implemented in future iteration)
    """
    # TODO: Implement Neo4j pattern matching
    # - Find similar events from history
    # - Create SIMILAR_TO relationships
    # - Generate user notifications

    print("✓ Pattern matching placeholder - to be implemented")


# Define tasks
task_load_universe = PythonOperator(
    task_id='load_universe_template',
    python_callable=load_universe,
    dag=dag,
)

task_collect_reports = PythonOperator(
    task_id='collect_36_major_reports',
    python_callable=collect_major_reports,
    dag=dag,
)

task_extract_events = PythonOperator(
    task_id='extract_events',
    python_callable=extract_events,
    dag=dag,
)

task_pattern_match = PythonOperator(
    task_id='pattern_matching',
    python_callable=pattern_matching,
    dag=dag,
)

# Define task dependencies
task_load_universe >> task_collect_reports >> task_extract_events >> task_pattern_match
```

**Environment Variables Required:**
- `OPEN_DART_API_KEY`: DART Open API key
- `LOCAL_POSTGRES_CONN_STRING`: Local PostgreSQL connection string
  - Format: `postgresql://user:password@localhost:5432/stockelper_local`

---

## Implementation Steps

### Phase 1: Setup (Day 1)

**1.1. Create Universe Template**
- [ ] Create file: `stockelper-kg/modules/dart_disclosure/universe.ai-sector.template.json`
- [ ] Research and add 20-50 AI-sector Korean stocks
- [ ] Verify all corp_codes using DART API
- [ ] Commit to repository

**1.2. Setup Local PostgreSQL**
- [ ] Create new PostgreSQL database: `stockelper_local`
- [ ] Configure connection string in environment variables
- [ ] Test connectivity

### Phase 2: Data Collector (Days 2-3)

**2.1. Implement DartMajorReportCollector**
- [ ] Create file: `stockelper-kg/src/stockelper_kg/collectors/dart_major_reports.py`
- [ ] Implement `MajorReportType` enum (36 types)
- [ ] Implement `DartMajorReportCollector` class
- [ ] Add rate limiting (5 requests/sec)
- [ ] Add error handling with retries

**2.2. Test Collector**
- [ ] Test with 1-2 corp_codes
- [ ] Verify all 36 API endpoints work
- [ ] Validate data structure returned by DART API
- [ ] Handle edge cases (no data, API errors)

### Phase 3: Database Schemas (Day 4)

**3.1. Create PostgreSQL Schemas**
- [ ] Create migration file: `stockelper-kg/migrations/001_create_dart_disclosure_tables.sql`
- [ ] Generate 36 table CREATE statements
- [ ] Add indexes for performance
- [ ] Add constraints for data integrity

**3.2. Test Database Storage**
- [ ] Run migration to create tables
- [ ] Test data insertion with sample data
- [ ] Verify deduplication works (rcept_no unique constraint)
- [ ] Test query performance

### Phase 4: Airflow DAG (Day 5)

**4.1. Implement DAG**
- [ ] Create file: `stockelper-airflow/dags/dart_disclosure_collection_dag.py`
- [ ] Implement all 4 tasks
- [ ] Configure environment variables
- [ ] Test DAG execution manually

**4.2. Schedule and Monitor**
- [ ] Deploy DAG to Airflow
- [ ] Configure 8:00 AM KST schedule
- [ ] Test daily execution
- [ ] Set up monitoring and alerts

### Phase 5: Validation (Day 6)

**5.1. End-to-End Testing**
- [ ] Run full collection for all universe stocks
- [ ] Verify data stored correctly in all 36 tables
- [ ] Check for duplicates and data quality issues
- [ ] Measure execution time (should be < 1 hour)

**5.2. Performance Optimization**
- [ ] Implement parallel collection per corp_code
- [ ] Optimize database inserts (bulk operations)
- [ ] Add connection pooling
- [ ] Monitor API rate limits

---

## Success Criteria

**Technical Validation:**
- ✅ All 36 major report types successfully collected
- ✅ Data stored in Local PostgreSQL (36 tables)
- ✅ No duplicate rcept_no in any table
- ✅ Airflow DAG executes daily at 8:00 AM KST
- ✅ Execution time < 1 hour for full universe

**Data Quality:**
- ✅ All required fields populated (corp_code, stock_code, rcept_dt, rcept_no)
- ✅ Korean text properly encoded (UTF-8)
- ✅ Dates in correct format (YYYY-MM-DD)
- ✅ No API errors or timeouts

**Performance:**
- ✅ Rate limiting respected (max 5 requests/sec)
- ✅ Retry logic handles transient failures
- ✅ Database queries execute < 100ms

---

## Reference Documentation

**Primary References:**
1. `docs/architecture.md` (Lines 232-377) - DART collection architecture
2. `docs/DART-implementation-analysis.md` (Section B, Lines 425-863) - Gap analysis and implementation plan
3. `docs/references/DART(modified events).md` - Complete implementation code by 민우
4. `docs/meeting-analysis-2026-01-03.md` (Section 1) - Meeting requirements

**Supporting Documentation:**
5. `docs/DOCUMENTATION-UPDATE-PLAN.md` - Complete update checklist
6. OpenDartReader library documentation - https://github.com/FinanceData/OpenDartReader

**API Documentation:**
- DART Open API: https://opendart.fss.or.kr/
- API Key registration: https://opendart.fss.or.kr/uss/umt/EgovFrntUsrRegist.do

---

## Troubleshooting

**Common Issues:**

**Issue 1: DART API rate limiting (429 Too Many Requests)**
- Solution: Increase `self._rate_limit_delay` from 0.2 to 0.5 seconds
- Verify: Max 5 requests/sec = 0.2 sec delay

**Issue 2: Missing data for specific report types**
- Solution: Some companies may not have all report types - this is expected
- Return `None` or empty DataFrame, continue collection

**Issue 3: Korean text encoding errors**
- Solution: Ensure UTF-8 encoding in all file operations
- Use `encoding='utf-8'` in JSON and CSV operations

**Issue 4: PostgreSQL connection timeout**
- Solution: Increase connection pool size
- Add connection retry logic with exponential backoff

**Issue 5: Airflow task execution timeout**
- Solution: Increase `execution_timeout` in default_args
- Consider parallel processing per corp_code

---

## Next Steps (After Implementation)

**Future Enhancements:**
1. Implement event extraction with LLM (Task 3 in DAG)
2. Implement Neo4j pattern matching (Task 4 in DAG)
3. Add daily stock price collection DAG
4. Integrate with frontend notification system
5. Add data quality monitoring dashboard

**Documentation Updates:**
- Update PRD with FR126 (DART 36-type collection)
- Update epics.md Story 1.2 with implementation details
- Document actual API response structures for each report type
- Create operational runbook for troubleshooting

---

## Contact & Support

**Implementation Owner:** 영상님
**Architecture Reference:** docs/architecture.md
**Code Reference:** docs/references/DART(modified events).md (민우 2026-01-03)
**Meeting Decisions:** docs/meeting-analysis-2026-01-03.md

For questions or clarifications, refer to the documentation files above or reach out to the project team.
