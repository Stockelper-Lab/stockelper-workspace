# Meeting Analysis & Documentation Update Plan
**Date:** 2025-12-30
**Status:** Analysis Complete - Ready for Implementation

---

## Executive Summary

The team meeting introduced critical architectural changes and new requirements that require substantial updates across all documentation:

1. **Backtesting Architecture**: Separate container backend (not LLM-integrated)
2. **DART Data Integration**: New data source with distinct event extraction
3. **Sentiment Scoring**: New requirement for both NEWS and DART events
4. **Dual Pipeline Architecture**: Separate extraction prompts and schedules for NEWS vs DART

---

## Key New Requirements

### 1. Backtesting Flow (Epic 3 Impact)

**New Architecture:**
- Backtesting runs in **separate container backend** (not in LLM server)
- LLM extracts backtesting parameters (universe, strategy) from user chat input
- Human-in-the-loop: If parameters unclear, LLM asks follow-up questions
- Chat responds: "Backtesting in progress, check status page"
- Results displayed on **dedicated backtesting page** (not chat interface)
- Notification sent to frontend when backtesting completes
- Results delivered as downloadable report

**Integration Points:**
- LLM → Backtesting Container: Send (universe, strategy, user_id)
- Backtesting Container → Notification Service → Frontend
- Frontend: Separate backtesting results page

**Reference Code:** Will be provided separately

---

### 2. DART (Disclosure) Data Collection & Event Extraction (Epic 1 Impact)

**New Requirements:**
- Extract events from DART disclosure data (unstructured text)
- Extract **sentiment score** for each event: range (-1 to 1)
- For dates with no events: sentiment = 0 (standardized)
- Add `source` attribute: "DART" vs "NEWS"
- Use **different extraction prompts** than news data
- DART collection code will be provided separately

**Event Ontology (from DART reference):**
1. Capital Changes (유상증자, 제3자배정, CB/BW, 자기주식, 감자)
2. M&A & Governance (주식양수도, 합병, 분할, 최대주주변경, 경영권변경)
3. Financial (영업실적, 손익구조변경, 회생절차, 부도)
4. Business Operations (신규사업, 계약체결, 공장가동)
5. Dividends (현금배당, 분기배당)
6. Legal (소송, 횡령/배임)
7. Other (전환청구, 상장폐지, 공시해명)

**Critical Details:**
- Each event type has specific stock price impact patterns
- Event context matters: 금액 규모, 시가총액 대비, 목적, 시장예상치 차이
- Timing matters: 장중 vs 장마감 후 공시

---

### 3. News Data Collection & Event Extraction (Epic 1 Impact)

**Dual Pipeline Architecture:**

**Pipeline 1: Batch Collection (CLI)**
- Extract last 6 months of news data in single run
- Implemented as **standalone CLI command**
- One-time backfill or manual re-extraction

**Pipeline 2: Scheduled Collection (Airflow)**
- Collect news data every **3 hours** (00:00, 03:00, 06:00, 09:00, 12:00, 15:00, 18:00, 21:00)
- Integrated into existing Airflow orchestration
- Continuous real-time collection

**Event Extraction:**
- Extract **sentiment score** for each news event
- Use **different prompts** than DART extraction
- Add `source` attribute: "NEWS"

---

## Conflicts with Current Documentation

### CONFLICT 1: Architecture - Backtesting Service

**Current State (architecture.md):**
- Backtesting described as async job queue within LLM service
- No separate backtesting container/service
- No notification service integration
- Results implied to be shown in chat

**Required Changes:**
- Add **Backtesting Service** as new microservice (6th service)
- Add **Notification Service** backend
- Update service interaction diagrams
- Add frontend: Backtesting Results Page
- Update LLM service: Parameter extraction logic

---

### CONFLICT 2: Epic 3 - Backtesting Stories

**Current State (epics.md - Epic 3):**
- Story 3-1: "Async Backtesting Job Queue Infrastructure"
- Story 3-6: "Backtesting Request via Chat Interface"
- Stories assume results displayed in chat

**Required Changes:**
- Story 3-1: Change to "Backtesting Container Backend Infrastructure"
- Add new story: "LLM Backtesting Parameter Extraction"
- Add new story: "Backtesting Results Page (Frontend)"
- Add new story: "Backtesting Notification System"
- Update Story 3-6: Remove chat display, add "navigate to page" response

---

### CONFLICT 3: Epic 1 - Event Intelligence

**Current State (epics.md - Epic 1):**
- Story 1-1: "Automate Event Extraction with Airflow DAG"
- No distinction between NEWS vs DART
- No sentiment score requirement
- Single extraction pipeline

**Required Changes:**
- Split Story 1-1 into **two stories**:
  - Story 1-1a: News Event Extraction (3-hour scheduled + 6-month CLI)
  - Story 1-1b: DART Event Extraction
- Add sentiment score extraction to acceptance criteria
- Add source attribute (NEWS/DART) to acceptance criteria
- Reference DART event ontology document

---

### CONFLICT 4: Epic 5 - Story 5-5

**Current State (epics.md):**
- Story 5-5: "Complete Event Extraction Automation DAG - Dual Pipeline"
- Vague dual pipeline description

**Required Changes:**
- Clarify dual pipeline = NEWS + DART (not just two news sources)
- Add sentiment scoring requirement
- Add different prompt requirement
- Reference DART events document

---

### CONFLICT 5: PRD - Functional Requirements

**Current State (prd.md):**
- FR1: "Extract financial events from Korean news articles (Naver Finance)"
- FR2: "Extract financial events from DART disclosure data" (exists but incomplete)
- FR29-FR31: Backtesting via chat, no separate service mentioned
- No sentiment score requirements

**Required Changes:**
- **FR1**: Add sentiment score extraction requirement
- **FR2**: Add sentiment score extraction, source attribute, different prompts
- Add **NEW FR**: Sentiment standardization (no events = 0)
- Add **NEW FR**: DART event ontology categories (7 categories from reference)
- **FR29-FR31**: Update backtesting flow (separate container, notification, results page)
- Add **NEW FR**: News 6-month batch CLI
- Add **NEW FR**: News 3-hour scheduled collection

---

### CONFLICT 6: Architecture - Service Diagram

**Current State (architecture.md):**
- 5 microservices: Frontend, Airflow, LLM, KG Builder, News Crawler
- No backtesting service
- No notification service

**Required Changes:**
- Add **Backtesting Service** (6th service)
- Add **Notification Service** backend
- Update service interaction diagrams
- Add data flow: LLM → Backtesting → Notification → Frontend

---

### CONFLICT 7: Model Version References

**Current State (multiple docs):**
- References to gpt-4.0, gpt-4o, gpt-4o-mini, gpt-4.1
- Inconsistent model version across documentation

**Required Changes:**
- Update ALL references to **gpt-5.1**
- Affected files:
  - epic-0-revision-recommendations.md
  - 0-1-update-langchain-dependencies-and-core-imports.md
  - epics.md
  - architecture.md
  - test-design-system.md
  - implementation-readiness-report-2025-12-23.md

---

## Implementation Plan

### Phase 1: Create Conflict Analysis ✅
- Document all conflicts and required changes
- Get alignment on scope

### Phase 2: Update PRD
- Add sentiment score requirements (FR1, FR2)
- Add new FRs for DART ontology, sentiment standardization
- Update backtesting FRs (separate container, notification, results page)
- Add news collection FRs (CLI, scheduled)

### Phase 3: Update Architecture
- Add Backtesting Service (6th microservice)
- Add Notification Service
- Update service interaction diagrams
- Add DART data collection architecture
- Add dual pipeline (NEWS/DART) architecture
- Update all gpt-4.x → gpt-5.1

### Phase 4: Update Epics
- Revise Epic 1 (split event extraction into NEWS/DART)
- Revise Epic 3 (backtesting architecture changes)
- Update Epic 5 Story 5-5 (clarify dual pipeline)
- Update all gpt-4.x → gpt-5.1

### Phase 5: Update Story Files
- Update any drafted story files with new requirements
- Ensure alignment with revised epics

---

## Risk Assessment

**RISK 1: Scope Expansion**
- **Impact:** HIGH - Adding backtesting service + DART integration is significant work
- **Mitigation:** Leverage reference code to be provided separately

**RISK 2: Timeline Impact**
- **Impact:** MEDIUM - Dual pipeline (NEWS/DART) adds complexity to Epic 1
- **Mitigation:** Stories already in backlog, no active work disrupted

**RISK 3: Documentation Consistency**
- **Impact:** MEDIUM - Many files need updates, risk of missing references
- **Mitigation:** Systematic grep-based search for all model version references

---

## Files Requiring Updates

### Critical Updates:
1. ✅ `docs/meeting-analysis-2025-12-30.md` (this file)
2. `docs/prd.md` - Add sentiment, DART, backtesting architecture
3. `docs/architecture.md` - Add services, update diagrams, gpt-5.1
4. `docs/epics.md` - Revise Epic 1, 3, 5, gpt-5.1
5. `docs/sprint-artifacts/sprint-status.yaml` - May need epic/story key updates

### Supporting Updates:
6. `docs/epic-0-revision-recommendations.md` - gpt-5.1
7. `docs/sprint-artifacts/0-1-update-langchain-dependencies-and-core-imports.md` - gpt-5.1
8. `docs/test-design-system.md` - gpt-5.1, new test scenarios
9. `docs/implementation-readiness-report-2025-12-23.md` - gpt-5.1, new gaps

---

## Next Steps

1. ✅ Complete this analysis document
2. Update PRD with new requirements
3. Update Architecture with new services and diagrams
4. Update Epics with revised stories
5. Update all model version references
6. Verify consistency across all documentation

---

## Summary of Changes

### New Components:
- **Backtesting Service** (6th microservice)
- **Notification Service** backend
- **Backtesting Results Page** (frontend)
- **DART Data Collection** pipeline
- **Sentiment Scoring** for NEWS and DART events

### New Requirements:
- Dual event sources (NEWS + DART) with different prompts
- Sentiment score extraction (-1 to 1 range)
- Sentiment standardization (no events = 0)
- DART event ontology (7 categories, ~40 event types)
- News 6-month batch CLI
- News 3-hour scheduled collection
- LLM parameter extraction for backtesting
- Human-in-the-loop for unclear backtesting parameters

### Architecture Changes:
- 5 microservices → 7 microservices (add Backtesting + Notification)
- Chat-based backtesting → Separate page backtesting
- Single event pipeline → Dual pipeline (NEWS + DART)
- gpt-4.x models → gpt-5.1 across all agents

---

**Status:** Ready to proceed with documentation updates
**Next Action:** Update PRD with new requirements
