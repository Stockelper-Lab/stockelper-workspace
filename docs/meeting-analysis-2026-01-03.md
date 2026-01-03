# Meeting Analysis - 2026-01-03
**Date:** 2026-01-03 (combined from 2025-12-29 + 2026-01-03 meetings)
**Status:** Analysis Complete - Critical Updates Required

---

## Executive Summary

Recent team meetings (12/29 and 1/3) introduced **critical implementation details** that significantly refine the architecture and data collection strategy:

### Key Decisions:
1. **DART Collection Strategy**: Complete overhaul based on 36 major report types (민우 1/3 work)
2. **Backtesting Execution Time**: 1-year backtest = 5 minutes (up to 1 hour with complex conditions)
3. **Repository Separation**: stockelper-backtesting and stockelper-portfolio as separate repos
4. **Data Schema Refinement**: Added `job_id` column, clarified data ownership (agents own all data)
5. **Universe Definition**: AI-sector template with specific stock tickers as investment candidates
6. **Daily Stock Price Collection**: New requirement for backtesting data
7. **News Collection**: Deprioritized (lower priority)

---

## 1. DART Data Collection - Major Changes

### Previous Approach (11/17):
- Generic DART disclosure collection
- Unstructured event extraction from general disclosures

### New Approach (1/3 - 민우 work):
**36 Major Report Type API-based Collection**

#### Report Categories (8 categories):
1. **기업상태** (Company Status): 5 types
   - 자산양수도(기타)_풋백옵션, 부도발생, 영업정지, 회생절차_개시신청, 해산사유_발생

2. **증자감자** (Capital Changes): 4 types
   - 유상증자_결정, 무상증자_결정, 유무상증자_결정, 감자_결정

3. **채권은행** (Creditor Bank): 2 types
   - 채권은행_관리절차_개시, 채권은행_관리절차_중단

4. **소송** (Litigation): 1 type
   - 소송등_제기

5. **해외상장** (Overseas Listing): 4 types
   - 해외증권시장_상장_결정, 해외증권시장_상장폐지_결정, 해외증권시장_상장, 해외증권시장_상장폐지

6. **사채발행** (Bond Issuance): 4 types
   - 전환사채권_발행결정, 신주인수권부사채권_발행결정, 교환사채권_발행결정, 상각형_조건부자본증권_발행결정

7. **자기주식** (Treasury Stock): 4 types
   - 자기주식_취득_결정, 자기주식_처분_결정, 자기주식취득_신탁계약_체결_결정, 자기주식취득_신탁계약_해지_결정

8. **영업/자산양수도** (Business/Asset Transfer): 4+ types
   - 영업양수_결정, 영업양도_결정, 유형자산_양수_결정, 유형자산_양도_결정

**Total: 36 structured major report types**

#### Collection Pipeline:
```
1. Universe (AI-sector stocks) → List of corp_codes
2. For each corp_code:
   - Collect 36 major report types via DART API endpoints
   - Each report type has structured fields
3. Event extraction + Sentiment scoring (same as before)
4. Storage: Local PostgreSQL (NOT remote AWS PostgreSQL)
```

#### Key Technical Details:
- **API Endpoints**: Each of 36 report types has dedicated DART API endpoint
- **Data Structure**: Structured fields per report type (not generic text parsing)
- **Storage Target**: **Local PostgreSQL** (NOT remote AWS PostgreSQL at ${POSTGRES_HOST})
- **Schedule**: Daily collection aligned with DART disclosure times

---

## 2. Backtesting Architecture - Performance Constraints

### Execution Time:
- **1-year backtest**: ~5 minutes
- **Complex strategies**: Up to 1 hour
- **Implication**: Async processing with dedicated results page (confirmed)

### Repository Separation:
- **stockelper-backtesting**: Separate repo (confirmed in 1/3 meeting)
- **stockelper-portfolio**: Separate repo (confirmed in 1/3 meeting)

### Data Schema Update:
Added `job_id` column to backtesting results table:

```sql
{
  job_id: UUID,              -- NEW: Unique job identifier
  content: TEXT,             -- LLM-generated Markdown
  image_base64: TEXT,        -- Optional image (PNG)
  user_id: UUID,             -- FK to users table
  created_at: TIMESTAMP,     -- Request initiated
  updated_at: TIMESTAMP,     -- Last modification
  written_at: TIMESTAMP,     -- Result written (nullable)
  completed_at: TIMESTAMP,   -- Job finished (nullable)
  status: ENUM('작업 전', '처리 중', '완료', '실패')  -- Korean status values
}
```

**Status Enum (Korean):**
- `작업 전` (Before Processing)
- `처리 중` (In Progress)
- `완료` (Completed)
- `실패` (Failed)

---

## 3. Universe Definition

### AI-Sector Template:
- **Source**: `modules/dart_disclosure/universe.ai-sector.template.json`
- **Definition**: Investment candidate stock list (not abstract category)
- **Purpose**: Filter target stocks for backtesting and data collection

### Implication:
- Universe = specific list of stock tickers
- Used for:
  - DART disclosure collection scope
  - Backtesting stock candidates
  - Portfolio recommendation pool

---

## 4. Daily Stock Price Collection (NEW)

### Requirement:
- **Owner**: 영상 (from 1/3 meeting action items)
- **Purpose**: Provide price data for backtesting
- **Implementation**: DAG modification required

### DAG Requirement:
- Daily price data collection for universe stocks
- Integration with existing Airflow pipeline
- Storage: TBD (likely PostgreSQL or time-series DB)

---

## 5. Chat-Based Backtesting Parameter Extraction

### Flow:
1. User in chat: "백테스팅을 진행해줘"
2. Assistant: "백테스팅을 위한 전략을 말해주세요"
3. User: "뉴스 이벤트 감성지수 3.8 이상인 경우만 매수해줘"
4. LLM extracts:
   - Universe: (inferred or default)
   - Strategy: Sentiment-based (threshold = 3.8)
5. Trigger backtesting container
6. Response: "백테스팅이 진행 중입니다. 결과 페이지에서 확인해주세요"

### Supported Parameters:
- News event sentiment score (감성지수)
- Fundamental indicators (펀더멘탈 지수)
- Moving average conditions (이평선 상태)
- Universe filter (대형주/소형주/특정섹터)

---

## 6. Portfolio Recommendation - Refined Flow

### Dedicated Page:
- **URL**: `/portfolio/recommendations`
- **Button**: "Generate Recommendation"
- **Display**: Accumulated history (rows)
- **Format**: Markdown output
- **Warning**: Stale recommendations (오래된 추천 경고)

### Agent Ownership:
- **Existing**: PortfolioRecommendationAgent already in llm-server
- **No new agent needed**: Use existing multi-agent system

### Data Ownership (Confirmed):
- ~~Frontend defines columns~~
- **Agents fully own data generation and storage**

---

## 7. Notification Architecture (Reconfirmed)

### Browser Notifications:
- **Pattern**: Confluence-style (accumulating, non-intrusive)
- **Mechanism**: Supabase Realtime (NO custom service)
- **Examples**:
  - "백테스팅이 완료되었습니다"
  - "포트폴리오 추천이 완료되었습니다"

---

## Documentation Updates Required

### 1. PRD Updates:
- Add FR for daily stock price collection
- Update FR2 (DART disclosure extraction) with 36 major report types
- Add FR for `job_id` tracking
- Clarify universe definition (AI-sector template)

### 2. Architecture Updates:
- **DART Collection Section**:
  - Replace generic disclosure pipeline with 36 major report type structure
  - Update storage target: Local PostgreSQL (NOT remote AWS)
  - Add structured data schema per report type
- **Backtesting Section**:
  - Add execution time constraints (5min - 1hr)
  - Add `job_id` column to schema
  - Document Korean status enum values
- **Daily Price Collection**:
  - Add new data pipeline component
  - Define storage strategy

### 3. Epics Updates:
- **Epic 1 (Event Intelligence)**:
  - Story 1.2: Rewrite DART extraction to use 36 major report types
  - Add new story: Daily stock price collection DAG
- **Epic 3 (Backtesting)**:
  - Update Story 3.1: Add `job_id` column, Korean status values
  - Add execution time NFRs (5min - 1hr range)

### 4. DART Implementation Analysis Updates:
- **Section B (Gap Analysis)**:
  - Update with 36 major report type API endpoints
  - Revise collection pipeline design
  - Change storage target: Local PostgreSQL
- **Data Requirements Table**:
  - Add fields for each of 36 report types
  - Document structured schema per type

---

## Action Items Alignment

From 1/3 meeting:
- ✅ **(영상)** 민우님 1/3 작업 기준 → 공시정보 수집 수정 → **local PostgreSQL** 저장
- ✅ **(영상)** stockelper-backtesting 레포지토리 분리
- ✅ **(영상)** stockelper-portfolio 레포지토리 분리
- ✅ **(영상)** 데일리 주가 정보 수집 DAG 수정
- ✅ **(희주)** DART 유니버스 데이터 수집 완료 후 백테스팅 진행
- ✅ **(지동)** `job_id` 컬럼 추가

---

## Critical Conflicts with Existing Documentation

### CONFLICT 1: DART Storage Location
**Current (architecture.md, meeting-analysis-part2.md):**
- Remote PostgreSQL at `${POSTGRES_HOST}` for DART results

**New (1/3 meeting):**
- **Local PostgreSQL** for DART disclosure data

**Resolution:**
- Remote PostgreSQL: Backtesting results, portfolio recommendations, user data
- Local PostgreSQL: DART disclosure data, event extraction results

### CONFLICT 2: DART Collection Method
**Current (DART-implementation-analysis.md):**
- Generic `list()` → `document()` pipeline
- Unstructured text extraction

**New (DART modified events.md):**
- 36 structured major report type APIs
- Dedicated endpoint per report type
- Structured field extraction

**Resolution:**
- Replace generic pipeline with 36-type structured collection
- Update all references in architecture.md, epics.md

### CONFLICT 3: Status Enum Values
**Current:**
- English: `PENDING`, `IN_PROGRESS`, `COMPLETED`, `FAILED`

**New:**
- Korean: `작업 전`, `처리 중`, `완료`, `실패`

**Resolution:**
- Use Korean values in database schema
- Update all documentation to reflect Korean enum

---

**Status:** Ready to proceed with documentation updates
**Next Actions:**
1. Update architecture.md with DART 36-type collection
2. Update PRD with daily price collection FR
3. Update epics.md with revised DART stories
4. Update DART-implementation-analysis.md with new collection design
5. Create DAG specification for daily price collection
