---
stepsCompleted: [1, 2, 3]
lastStep: 3
inputDocuments:
  - 'docs/prd.md'
  - 'docs/architecture.md'
  - 'docs/ux-design-specification.md'
workflowType: 'epics'
project_name: 'Stockelper'
user_name: 'Oldman'
date: '2025-12-22'
---

# Stockelper - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Stockelper, decomposing the requirements from the PRD, UX Design, and Architecture into implementable stories.

## Requirements Inventory

### Functional Requirements

**Event Intelligence & Knowledge Graph (FR1-FR8):**
- FR1: System can extract financial events from Korean news articles (Naver Finance)
- FR2: System can extract financial events from DART disclosure data
- FR3: System can classify extracted events into defined ontology categories
- FR4: System can store events in Neo4j knowledge graph with date indexing
- FR5: System can capture event metadata (entities, conditions, categories, dates)
- FR6: System can establish entity relationships within knowledge graph subgraphs
- FR7: System can detect similar events based on historical patterns
- FR8: System can identify "similar conditions" across different time periods and subgraphs

**Prediction & Analysis (FR9-FR18):**
- FR9: System can generate short-term predictions (days to weeks) based on event patterns
- FR10: System can generate medium-term predictions (weeks to months) based on event patterns
- FR11: System can generate long-term predictions (months+) based on event patterns
- FR12: System can calculate prediction confidence levels based on pattern strength
- FR13: System can match current events against historical event patterns
- FR14: System can analyze stock price fluctuations per subgraph following events
- FR15: Users can query specific stocks to view event-based predictions
- FR16: Users can view historical event examples that inform current predictions
- FR17: Users can see explanations of "similar events under similar conditions"
- FR18: System can provide rationale for each prediction showing historical basis

**Portfolio Management (FR19-FR28):**
- FR19: Users can manually request portfolio recommendations via chat interface
- FR20: System can analyze recent events to generate stock recommendations
- FR21: System can provide event-based rationale for each recommendation
- FR22: System can display historical patterns supporting each recommendation
- FR23: System can show confidence levels for each recommendation
- FR24: Users can add recommended stocks to their portfolio
- FR25: Users can track multiple stocks in their personal portfolio
- FR26: Users can update their investment profile preferences
- FR27: Users can view their portfolio holdings
- FR28: Users can remove stocks from their portfolio

**Backtesting & Validation (FR29-FR39):**
- FR29: Users can manually initiate backtesting for specific stocks via chat
- FR30: Users can manually initiate backtesting for specific investment strategies via chat
- FR31: System can retrieve historical instances of similar events for backtesting
- FR32: System can calculate 3-month historical returns for event-based strategies
- FR33: System can calculate 6-month historical returns for event-based strategies
- FR34: System can calculate 12-month historical returns for event-based strategies
- FR35: System can calculate Sharpe Ratio for event-based strategies
- FR36: System can compare event-based strategy performance to buy-and-hold baseline
- FR37: System can display performance range (best case and worst case scenarios)
- FR38: System can provide risk disclosures with backtesting results
- FR39: System can show number of historical instances used in backtest

**Alert & Notification System (FR40-FR47):**
- FR40: System can monitor for new events matching patterns relevant to user portfolio
- FR41: System can detect when similar events occur for stocks in user portfolio
- FR42: System can send push notifications when relevant event alerts triggered
- FR43: Users can receive event alerts with prediction and confidence level
- FR44: Users can view historical examples within event alerts
- FR45: Users can drill down from alert notification to detailed event analysis
- FR46: System can include action recommendations (hold/buy/sell consideration) in alerts
- FR47: Users can configure alert preferences for their portfolio

**User Interaction & Chat Interface (FR48-FR56):**
- FR48: Users can interact with system via natural language chat interface
- FR49: Users can query about specific stocks through conversational interface
- FR50: Users can request predictions through chat
- FR51: Users can request portfolio recommendations through chat
- FR52: Users can initiate backtesting through chat
- FR53: System can explain predictions in natural language responses
- FR54: System can provide conversational access to all event-driven features
- FR55: Users can view prediction history through chat interface
- FR56: System can display historical event timelines visually within chat

**Ontology Management - Development Team (FR57-FR68):**
- FR57: Development team can create new event ontology categories
- FR58: Development team can read existing event ontology definitions
- FR59: Development team can update event ontology category definitions
- FR60: Development team can delete event ontology categories
- FR61: Development team can configure event extraction rules (keywords, entities, context)
- FR62: Development team can test ontology definitions against historical news articles
- FR63: Development team can validate event extraction samples
- FR64: Development team can view accuracy metrics per ontology category
- FR65: Development team can identify unmapped events flagged by system
- FR66: Development team can deploy updated ontology to production
- FR67: Development team can version ontology changes
- FR68: Development team can analyze impact of ontology changes on users

**Compliance & Audit (FR69-FR80):**
- FR69: System can embed disclaimers in all prediction outputs
- FR70: System can embed disclaimers in all recommendation outputs
- FR71: System can log prediction generation (timestamp, user, stock, output, confidence)
- FR72: System can log which historical event patterns contributed to predictions
- FR73: System can log knowledge graph state and ontology version used for predictions
- FR74: System can log portfolio recommendations delivered to users
- FR75: System can log backtesting executions
- FR76: System can log event alerts sent to users
- FR77: System can retain prediction logs for minimum 12 months
- FR78: System can provide audit trail for prediction accountability
- FR79: Users can view disclaimers explaining informational nature of platform
- FR80: Users can access terms of service and privacy policy

**User Account & Authentication (FR81-FR90):**
- FR81: Users can create new accounts with email and password
- FR82: Users can sign in to existing accounts
- FR83: Users can sign out of their accounts
- FR84: System can authenticate users via JWT tokens
- FR85: System can manage user sessions securely
- FR86: System can encrypt user data at rest
- FR87: System can encrypt user data in transit (HTTPS/TLS)
- FR88: Users can view their own user profile
- FR89: Users can update their account settings
- FR90: System can isolate user data (portfolios, preferences, history) per user account

**Data Pipeline & Orchestration (FR91-FR97):**
- FR91: System can orchestrate data pipeline via Airflow DAG
- FR92: System can schedule news crawler execution
- FR93: System can trigger event extraction from scraped news
- FR94: System can trigger knowledge graph updates with new events
- FR95: System can trigger prediction engine when knowledge graph updated
- FR96: System can monitor event alert system for similar events
- FR97: System can execute data pipeline on defined schedule

**Rate Limiting & Abuse Prevention (FR98-FR103):**
- FR98: System can rate limit prediction query requests per user
- FR99: System can rate limit portfolio recommendation requests per user
- FR100: System can rate limit backtesting execution requests per user
- FR101: System can throttle queries to prevent system abuse
- FR102: System can monitor for anomalous usage patterns
- FR103: System can prevent alert spam to users

### Non-Functional Requirements

**Performance (NFR-P1 to P12):**
- NFR-P1: Prediction query responses complete within 2 seconds under normal load
- NFR-P2: Chat interface message responses (non-prediction queries) complete within 500ms
- NFR-P3: Portfolio recommendation generation completes within 5 seconds
- NFR-P4: Backtesting execution for single stock completes within 10 seconds
- NFR-P5: Knowledge graph pattern matching queries complete within 1 second
- NFR-P6: Event alert generation and delivery occurs within 5 minutes of event detection
- NFR-P7: System supports minimum 100 concurrent users with <10% performance degradation
- NFR-P8: Prediction engine processes minimum 10 predictions per second
- NFR-P9: Event extraction pipeline processes minimum 1000 news articles per hour
- NFR-P10: Chat interface displays typing indicators within 100ms of user query submission
- NFR-P11: Historical event timeline visualization loads within 1 second
- NFR-P12: Portfolio view updates within 500ms of user actions (add/remove stocks)

**Security (NFR-S1 to S16):**
- NFR-S1: All user data encrypted at rest using AES-256 or equivalent
- NFR-S2: All data in transit encrypted using TLS 1.2 or higher (HTTPS)
- NFR-S3: User passwords hashed using bcrypt or equivalent (minimum 10 rounds)
- NFR-S4: JWT tokens expire after 24 hours and require re-authentication
- NFR-S5: Database credentials stored in secure environment variables (not hardcoded)
- NFR-S6: User data isolation enforced at database query level
- NFR-S7: Development team ontology management interface requires separate authentication
- NFR-S8: Session tokens invalidated on logout
- NFR-S9: Failed login attempts rate-limited (max 5 attempts per 15 minutes per account)
- NFR-S10: All user inputs sanitized to prevent SQL injection attacks
- NFR-S11: All user inputs validated to prevent XSS (Cross-Site Scripting) attacks
- NFR-S12: API endpoints protected against CSRF (Cross-Site Request Forgery)
- NFR-S13: File uploads (if implemented) restricted by type and size
- NFR-S14: Security-relevant events logged (authentication attempts, data access, configuration changes)
- NFR-S15: Audit logs retained for minimum 12 months
- NFR-S16: Security patches applied within 30 days of release for critical vulnerabilities

**Reliability (NFR-R1 to R13):**
- NFR-R1: System uptime target of 99% (allows ~7 hours downtime per month)
- NFR-R2: Planned maintenance windows communicated to users 48 hours in advance
- NFR-R3: Critical services (authentication, event alerts) prioritized during partial outages
- NFR-R4: Prediction logs persist reliably (no data loss during normal operation)
- NFR-R5: User portfolio data changes atomic (all-or-nothing updates)
- NFR-R6: Knowledge graph updates transactional (rollback on failure)
- NFR-R7: Database backups performed daily with 30-day retention
- NFR-R8: Event extraction failures logged and retried (up to 3 attempts with exponential backoff)
- NFR-R9: External API failures (DART, KIS, Naver) handled gracefully with user-friendly error messages
- NFR-R10: Prediction engine degradation graceful (reduced confidence or "unavailable" status vs. system crash)
- NFR-R11: Critical system failures trigger alerts to development team within 5 minutes
- NFR-R12: System health checks run every 60 seconds for core services
- NFR-R13: Recovery time objective (RTO) of 4 hours for complete system restoration

**Scalability (NFR-SC1 to SC9):**
- NFR-SC1: System architecture supports 10x user growth with <10% performance degradation
- NFR-SC2: Database queries optimized to handle 100,000+ user accounts
- NFR-SC3: Horizontal scaling possible for stateless services
- NFR-SC4: Knowledge graph scales to support 10,000+ events per month without performance degradation
- NFR-SC5: MongoDB supports storage of 1 million+ news articles with indexed queries
- NFR-SC6: Prediction log storage scales to 100,000+ predictions per month
- NFR-SC7: System handles traffic spikes of 3x normal load during market events
- NFR-SC8: Event alert system scales to send 10,000+ simultaneous notifications
- NFR-SC9: Airflow DAG scales to process increased event volume without manual reconfiguration

**Integration (NFR-I1 to I9):**
- NFR-I1: System tolerates DART API downtime up to 1 hour with queued retries
- NFR-I2: System tolerates KIS OpenAPI downtime up to 1 hour with cached fallback data
- NFR-I3: System tolerates Naver Finance downtime up to 1 hour with graceful degradation
- NFR-I4: External API timeouts configured at 30 seconds maximum
- NFR-I5: Rate limits respected for external APIs with backoff logic
- NFR-I6: External API errors logged with sufficient detail for debugging
- NFR-I7: News data refreshed every 1 hour during market hours
- NFR-I8: DART disclosure data checked every 30 minutes during business days
- NFR-I9: Stock price data (KIS) updated every 5 minutes during market hours

**Maintainability (NFR-M1 to M9):**
- NFR-M1: Critical business logic covered by automated tests (minimum 70% coverage goal)
- NFR-M2: Code follows established style guides for Python (PEP 8) and TypeScript (ESLint)
- NFR-M3: Major architectural decisions documented in architecture decision records
- NFR-M4: Ontology updates deployable without system downtime
- NFR-M5: Knowledge graph schema changes support backward compatibility for 1 release cycle
- NFR-M6: Logs structured with sufficient context for troubleshooting
- NFR-M7: Key metrics tracked (prediction accuracy, event extraction accuracy, response times, error rates)
- NFR-M8: Dashboards provide real-time visibility into system health and usage patterns
- NFR-M9: Alerting configured for anomalies (prediction errors, extraction failures, performance degradation)

**Usability (NFR-U1 to U6):**
- NFR-U1: Chat interface supports Korean language input and output
- NFR-U2: Error messages provide actionable guidance (not technical jargon)
- NFR-U3: System provides clear feedback for long-running operations (backtesting, recommendations)
- NFR-U4: First-time users can query a stock prediction within 2 minutes of account creation
- NFR-U5: System provides contextual help within chat interface for common actions
- NFR-U6: Disclaimer visibility ensures users understand informational positioning

### Additional Requirements

**From Architecture:**

**CRITICAL - Phase 0 Prerequisite:**
- **LangChain v1.0+ Migration Required:** Existing LangChain/LangGraph code must be refactored to v1.0+ before implementing new features
- Follow official LangChain v1.0+ migration guide
- Multi-agent system patterns may change significantly
- Test thoroughly after refactoring

**Brownfield Context:**
- This is NOT a greenfield project - no starter template needed
- Extend existing 5-microservice architecture (Frontend, Airflow, LLM, KG Builder, News Crawler)
- First story must address codebase review and LangChain migration requirements

**Database Schema Extensions:**
- Neo4j: Date-indexed events, event metadata, subgraph relationships
- PostgreSQL: Alert preferences, portfolio recommendations log, notification state
- MongoDB: Event extraction metadata, deduplication tracking

**Dual Event Pipeline:**
- Pipeline 1: DART disclosures (checked once daily)
- Pipeline 2: News-based events (Naver + Toss, every 2-3 hours per stock)

**Notification System:**
- Badge pattern with polling (not WebSocket/SSE for MVP)
- GNB notification icon
- Three categories: portfolio recommendations, backtesting complete, event alerts

**MVP Pilot Scope:**
- Focus initially on AI-related sector stocks (Naver, Kakao, 이스트소프트, 알체라, 레인보우로보틱스, etc.)
- Expandable to all sectors post-MVP

**From UX Design:**

**Chat-First Experience:**
- Primary interaction model is conversational
- Chat conversation quality is CRITICAL success factor
- Smooth rendering, zero errors, instant responsiveness required
- Session-scoped memory only (no cross-session persistence)

**Async Backtesting UX:**
- 5-10 minutes processing time
- Users must be able to navigate away without losing results
- Clear progress indicators and completion notifications
- "Request submitted, we'll notify you when ready" messaging

**Portfolio Recommendation Page:**
- Dedicated page (not in chat)
- Button-triggered recommendation delivery
- Pre-market notification (before 9am)
- Users click notification → navigate to page → click button to receive recommendations

**Emotional Design Priorities:**
- Progression from "informed" to "confident"
- Trust through transparency (show WHY behind predictions)
- First prediction must create "aha!" moment
- Calm decision-making environment (no FOMO tactics)

**Platform Requirements:**
- Chrome-based browsers (primary)
- Responsive design (desktop + mobile web)
- No specific accessibility requirements for MVP
- Korean language support throughout

**Existing Implementation:**
- **Sentiment analysis algorithm already fully implemented** (do not create implementation stories for this)

### FR Coverage Map

**Epic 0 (LangChain v1 Migration):** Enables FR9-FR18 (Predictions), FR48-FR56 (Chat Interface)
**Epic 1 (Event Automation & Viz):** FR1-FR8 (automation gaps), FR9-FR18 (UI gaps), FR48-FR56 (UI enhancements)
**Epic 2 (Portfolio UI & Scheduling):** FR19-FR28
**Epic 3 (Backtesting Engine):** FR29-FR39
**Epic 4 (Alerts & Notifications):** FR40-FR47
**Epic 5 (Compliance & Rate Limiting):** FR69-FR80, FR91-FR97, FR98-FR103

**Note:** FR57-FR68 (Ontology Management) already complete, FR81-FR90 (Auth) already complete

## Epic List

### Epic 0: Agent Infrastructure Validation & Model Upgrade (Phase 0 Prerequisite)

Development team validates existing LangChain v1.0+ StateGraph implementation and upgrades models to gpt-5.1 for improved performance. This is a CRITICAL prerequisite that must be completed before implementing new features.

**Status Update (2025-12-29):** Verification revealed codebase already uses LangChain v1.0+ compliant StateGraph patterns. No migration work required. Epic revised to focus on validation and model upgrades.

**FRs covered:** Enables FR9-FR18 (Predictions), FR48-FR56 (Chat Interface)

**Implementation Notes:**
- ✅ LangChain v1.0+ compliance verified (agents use StateGraph pattern)
- ✅ Dependencies include `langchain>=1.0.0` and `langchain-classic>=1.0.0`
- **NEW**: Upgrade all agents from gpt-5.1/gpt-5.1-mini to gpt-5.1
- **NEW**: Validate message handling and content blocks compatibility
- **NEW**: Comprehensive integration testing with StateGraph implementation
- No database schema changes required

#### Story 0.1: Verify LangChain v1.0+ Compliance and Dependencies

**Status:** ✅ COMPLETE (2025-12-29)

**As a** developer
**I want** to verify that the codebase uses LangChain v1.0+ compliant patterns and has appropriate dependencies declared
**So that** the multi-agent system is confirmed ready for production use with LangChain v1.0+

**Acceptance Criteria:**

**Given** the existing stockelper-llm service with LangChain dependencies
**When** I verify the implementation patterns and dependencies
**Then** the following conditions are met:
- ✅ `requirements.txt` includes `langchain>=1.0.0` and `langchain-classic>=1.0.0` packages
- ✅ All agents use LangChain v1.0+ compliant patterns (StateGraph)
- ✅ No deprecated `langgraph.prebuilt.create_react_agent` usage exists
- ✅ All imports use correct v1.0+ namespaces (`langchain_core`, `langgraph.graph`)
- ✅ No runtime import errors occur when importing agent modules
- ✅ Agent architecture uses recommended patterns from LangChain v1.0+ documentation

**Verification Findings:**
- **BaseAnalysisAgent**: Uses `StateGraph(SubState)` pattern - v1.0+ compliant
- **SupervisorAgent**: Uses `StateGraph(State)` pattern - v1.0+ compliant
- **All 5 Analysis Agents**: Inherit from BaseAnalysisAgent - automatically v1.0+ compliant
- **Architecture**: Direct StateGraph construction (more advanced than helper functions)
- **Result**: NO MIGRATION REQUIRED - already production-ready

**Files verified:**
- `/stockelper-llm/requirements.txt`
- `/stockelper-llm/src/multi_agent/base/analysis_agent.py`
- `/stockelper-llm/src/multi_agent/supervisor_agent/agent.py`
- All 5 analysis agent files

**Testing:**
- ✅ Agents import successfully without errors
- ✅ No deprecation warnings from LangChain/LangGraph imports
- ✅ StateGraph pattern confirmed as v1.0+ compliant

**Story file:** `docs/sprint-artifacts/0-1-update-langchain-dependencies-and-core-imports.md`

---

#### Story 0.2: Upgrade Agent Models to gpt-5.1

**Status:** ✅ COMPLETE

**As a** developer
**I want** to upgrade all agent models from gpt-5.1/gpt-5.1-mini to gpt-5.1
**So that** agents benefit from improved model capabilities and performance

**Acceptance Criteria:**

**Given** existing agents using various GPT-4 model versions
**When** I update model configurations across all agents
**Then** the following conditions are met:
- ✅ SupervisorAgent uses `model="gpt-5.1"`
- ✅ BaseAnalysisAgent initialization updated to accept and use `model="gpt-5.1"`
- ✅ All 5 analysis agents (Market, Fundamental, Technical, Portfolio, InvestmentStrategy) automatically use gpt-5.1 via BaseAnalysisAgent
- ✅ Model configuration centralized and easily maintainable
- ✅ Response quality maintained or improved vs. previous models
- ✅ Performance requirements still met: predictions <2s (NFR-P1), chat <500ms (NFR-P2), recommendations <5s (NFR-P3)
- ✅ No breaking changes to agent interfaces or message handling

**Files affected:**
- ✅ `/stockelper-llm/src/multi_agent/base/analysis_agent.py` - Model parameter updated
- ✅ `/stockelper-llm/src/multi_agent/supervisor_agent/agent.py` - Model specification updated
- ✅ Agent initialization/configuration files updated

**Testing:**
- ✅ Integration tests verify all agents use gpt-5.1 model
- ✅ Response quality regression tests pass
- ✅ Performance benchmarks confirm NFR-P1, NFR-P2, NFR-P3 requirements met
- ✅ Test scenarios cover all agent types

**Implementation Results:**
- ✅ Model upgrade completed successfully
- ✅ All agents upgraded from gpt-5.1/gpt-5.1-mini to gpt-5.1
- ✅ StateGraph pattern compatibility confirmed
- ✅ Message handling validated with gpt-5.1

---

#### Story 0.3: Validate Message Handling and Content Blocks

**As a** developer
**I want** to validate that agent message handling works correctly with current message formats
**So that** chat interface and multi-agent communication remain stable and functional

**Acceptance Criteria:**

**Given** agents using StateGraph with current message handling patterns
**When** I test various message scenarios
**Then** the following conditions are met:
- SupervisorAgent correctly parses and routes messages between agents
- BaseAnalysisAgent message handling supports tool calls and responses
- Message format compatible with frontend chat interface API
- Content blocks (if used) properly structured and parsed
- Multi-turn conversations maintain context within session (session-scoped memory)
- Error messages from agents properly formatted for user display
- Korean language content handled correctly (NFR-U1)
- No message parsing errors or dropped messages

**Files affected:**
- `/stockelper-llm/src/multi_agent/supervisor_agent/agent.py` - Message routing logic
- `/stockelper-llm/src/multi_agent/base/analysis_agent.py` - Message handling
- `/stockelper-llm/src/api/chat.py` - Chat API message transformation

**Testing:**
- Integration tests cover message routing scenarios
- Message format validation tests
- Session memory tests (context maintained within session only)
- Korean language message tests
- Frontend API compatibility tests

**Implementation Notes:**
- Verify message format consistency between SupervisorAgent, BaseAnalysisAgent, and frontend
- Ensure ToolMessage format compatible with tool execution flow
- Update message format documentation if gaps found

---

#### Story 0.4: Multi-Agent System Integration Testing

**As a** developer
**I want** to test the complete multi-agent system with StateGraph implementation
**So that** all agents work together correctly and meet performance requirements

**Acceptance Criteria:**

**Given** all agents using StateGraph pattern with gpt-5.1 models
**When** I execute comprehensive integration test scenarios
**Then** the following conditions are met:
- SupervisorAgent correctly routes tasks to specialized agents based on query type
- Multi-turn chat conversations maintain context within session (session-scoped memory only)
- Chat message responses complete within 500ms for non-prediction queries (NFR-P2)
- Prediction queries complete within 2 seconds (NFR-P1)
- Portfolio recommendations complete within 5 seconds (NFR-P3)
- Agent-to-agent communication works without errors
- Response format compatible with existing chat interface API
- No regression in chat conversation quality (CRITICAL success factor)
- System handles 10 concurrent user queries without degradation (subset of NFR-P7)
- StateGraph pattern validated across all coordination scenarios

**Files affected:**
- `/stockelper-llm/tests/integration/test_multi_agent_system.py` (new test suite)
- `/stockelper-llm/tests/integration/test_supervisor_routing.py` (routing tests)
- `/stockelper-llm/tests/integration/test_performance_benchmarks.py` (NFR validation)
- `/stockelper-llm/src/multi_agent/` (any coordination logic fixes)

**Testing Requirements:**
- Simple query routing tests (prediction, market analysis, portfolio)
- Multi-agent coordination tests (complex queries)
- Multi-turn conversation tests (session context)
- Tool execution tests (SearchNewsTool, StockTool)
- Error handling tests (invalid input, tool failures)
- Performance benchmarks (10 concurrent predictions <2s, 20 concurrent chat <500ms)

**Implementation Notes:**
- Set up performance benchmarking framework (k6 or Locust)
- Prepare diverse query set covering all agent types
- Add instrumentation to measure actual latencies
- Establish performance baseline before changes

---

### Epic 1: Event Intelligence Automation & Visualization

Users see rich visualizations of event patterns and historical matches; system automatically processes news into events. Powered by LangGraph multi-agent system for intelligent chat interactions.

**FRs covered:** FR1-FR8 (automation gaps), FR9-FR18 (visualization gaps), FR48-FR56 (UI enhancements), FR57-FR73 (LLM multi-agent system)

**Implementation Notes:**
- Automated Airflow DAG for event extraction (currently manual CLI)
- Frontend event timeline visualization
- Multi-timeframe prediction UI with confidence indicators
- Rich chat prediction cards
- Suggested queries based on portfolio

**LangGraph Multi-Agent System (FR57-FR73):**
- **Architecture:** LangGraph-based (NOT simple LangChain ReAct) with StateGraph pattern
- **Agents:**
  1. **SupervisorAgent:** Routes queries to specialized agents based on query type
  2. **MarketAnalysisAgent:** SearchNews, SearchReport, YouTubeSearch, ReportSentimentAnalysis, GraphQA
  3. **FundamentalAnalysisAgent:** AnalysisFinancialStatement (5-year DART data)
  4. **TechnicalAnalysisAgent:** AnalysisStock, PredictStock (Prophet+ARIMA ensemble), StockChartAnalysis
  5. **InvestmentStrategyAgent:** GetAccountInfo, InvestmentStrategySearch
- **State Management:**
  - @dataclass State: messages, query, agent_messages, agent_results (max 10), execute_agent_count (max 3), trading_action, stock_name, stock_code, subgraph
  - Session-scoped memory only (no cross-session persistence)
- **SSE Streaming (FR56a-FR56d):**
  - Progress events: Show which agent is executing (start/end)
  - Delta events: Token-level streaming for real-time response
  - Final events: Complete message + subgraph + trading_action
- **Key Features:**
  - Trading interruption with LangGraph interrupt() for user confirmation
  - AsyncPostgresSaver for checkpoint persistence (PostgreSQL)
  - KIS token auto-refresh mechanism
  - Chat-only mode (portfolio separated to dedicated service)
  - Parallel tool execution via asyncio.gather()
  - Tool execution limits (default: 5 per agent)
  - Agent recursion limits (default: 3 calls)
  - Stock name/code extraction from queries
  - Neo4j subgraph retrieval for context
- **Models:** All agents upgraded to GPT-5.1 (gpt-4o-mini)
- **Port:** 21009

#### Story 1.1a: Automate News Event Extraction with Dual Crawlers and LLM-Based Extraction

**As a** user
**I want** the system to automatically extract events from news articles using dual crawlers and LLM-based extraction
**So that** I receive timely event-based insights with accurate sentiment analysis from multiple news sources

**Acceptance Criteria:**

**Given** news articles collected from dual crawlers (Naver + Toss)
**When** the news event extraction pipeline executes
**Then** the following conditions are met:

**Dual News Crawlers (FR1a-FR1f):**
- **Naver Crawler:** Mobile API-based collection → MongoDB `naver_stock_news` collection
- **Toss Crawler:** RESTful API-based collection → MongoDB `toss_stock_news` collections
- Both crawlers run every 3 hours during market hours
- Unique index on `articleUrl` prevents duplicate articles
- Unprocessed articles marked with `processed: false` field

**LLM-Based Event Extraction (FR2, FR2a-FR2h):**
- Extract events using GPT-5.1 (OpenAI gpt-4o-mini) with NEWS-specific prompts (FR2a)
- **Pre-classification:** Apply deterministic rules before LLM extraction for performance optimization (FR2f)
- Extract sentiment score (-1.0 to +1.0 range) for each event (FR1, FR2)
- **Slot Validation:** Validate extracted events against per-event-type schema with required + optional slots (FR2g)
- Store extracted events in PostgreSQL `dart_event_extractions` table with JSONB slots (FR2h)
- Assign source attribute "NEWS" to all extracted events (FR1c)
- For dates with no events extracted, standardize sentiment score to 0 (FR2c)

**Scheduled Pipeline (3-hour intervals):**
- Airflow DAG executes every 3 hours (00:00, 03:00, 06:00, 09:00, 12:00, 15:00, 18:00, 21:00) (FR1b)
- DAG processes all unprocessed articles from both MongoDB collections
- Event extraction results stored in PostgreSQL `dart_event_extractions` table
- Knowledge graph updated with new events (optional Neo4j upload)

**Batch CLI (6-month backfill):**
- CLI command can extract last 6 months of news data in single run (FR1a)
- CLI: `stockelper-kg-events extract-news-batch --months=6`
- CLI processes historical backfill without blocking scheduled pipeline

**Error Handling:**
- Failed extractions retry up to 3 times with exponential backoff (NFR-R8)
- DAG execution logs viewable in Airflow UI
- Pipeline processes minimum 1000 news articles per hour (NFR-P9)

**Database changes:**
- MongoDB:
  - Collections: `naver_stock_news` and `toss_stock_news`
  - Add `processed` boolean field and `processed_at` timestamp
  - Unique index on `articleUrl`
- PostgreSQL:
  - Table: `dart_event_extractions` with columns: id, source_type (NEWS/DART), event_type, sentiment_score, slots (JSONB), extracted_at
  - Index on (source_type, extracted_at)
- Neo4j (optional): Add `sentiment` float property (-1 to 1) and `source` string property ("NEWS") to Event nodes

**Files affected:**
- `/stockelper-news-crawler/naver_crawler.py` (Naver mobile API crawler)
- `/stockelper-news-crawler/toss_crawler.py` (Toss RESTful API crawler)
- `/stockelper-airflow/dags/news_event_extraction_dag.py` (new scheduled DAG)
- `/stockelper-kg/src/stockelper_kg/cli/extract_news_batch.py` (new CLI command)
- `/stockelper-kg/src/stockelper_kg/extractors/llm_event_extractor.py` (LLM extraction with pre-classification)
- `/stockelper-kg/src/stockelper_kg/prompts/news_event_extraction.py` (NEWS-specific prompts)
- `/stockelper-kg/src/stockelper_kg/validators/slot_validator.py` (slot schema validation)
- `/stockelper-kg/migrations/003_create_event_extractions_table.sql` (PostgreSQL table)

---

#### Story 1.1b: DART Disclosure Collection using 20 Major Report Type APIs (Updated 2026-01-04)

**As a** user
**I want** the system to collect DART disclosures using 20 structured major report type APIs
**So that** I receive high-quality structured event data for comprehensive event intelligence

**Acceptance Criteria:**

**Given** AI-sector universe stocks defined in template
**When** the DART disclosure collection pipeline executes daily
**Then** the following conditions are met:

**DART Data Collection (FR126, FR127):**
- Collect 20 major report types using dedicated DART API endpoints per type (FR126)
- Collection based on universe template: `modules/dart_disclosure/universe.ai-sector.template.json`
- 6 categories, 20 total report types:
  1. 증자감자 (Capital Changes): 4 types - 유상증자결정, 무상증자결정, 유무상증자결정, 감자결정
  2. 사채발행 (Bond Issuance): 2 types - 전환사채발행결정, 신주인수권부사채발행결정
  3. 자기주식 (Treasury Stock): 4 types - 자기주식취득결정, 자기주식처분결정, 자기주식신탁계약체결결정, 자기주식신탁계약해지결정
  4. 영업양수도 (Business Operations): 4 types - 영업양수결정, 영업양도결정, 유형자산양수결정, 유형자산양도결정
  5. 주식양수도 (Securities Transactions): 2 types - 타법인주식및출자증권취득결정, 타법인주식및출자증권처분결정
  6. 기업인수합병 (M&A/Restructuring): 4 types - 합병결정, 분할결정, 분할합병결정, 주식교환·이전결정
- Store structured data in **Local PostgreSQL** (20 dedicated tables, one per report type) (FR127)
- Each table has common fields (rcept_no, corp_code, stock_code, rcept_dt) plus report-specific fields
- Daily schedule at 8:00 AM KST aligned with DART disclosure times
- Rate limiting: Max 5 requests/sec to respect DART API limits
- Deduplication by rcept_no (receipt number) to prevent duplicates

**Event Extraction (Post-collection):**
- Extract financial events from structured DART data using LLM (FR2, FR2a)
- Extract sentiment score (-1 to 1 range) for each DART event (FR2)
- Assign source attribute "DART" to all extracted events (FR2b)
- For dates with no events extracted, standardize sentiment score to 0 (FR2c)
- Classify events into 6 major DART categories matching the collection categories (FR2d)
- Extract event context from structured fields: amount, market cap ratio, purpose, timing (FR2e)
- Reference implementation: `docs/references/DART(modified events).md` (민우 2026-01-03)

**Database changes:**
- **Local PostgreSQL**: 20 new tables (one per report type) with structured schemas
- **Neo4j**: Add `sentiment` float property (-1 to 1) and `source` string property ("DART") to Event nodes
- **Neo4j**: Add `event_context` JSON property with: {amount, market_cap_ratio, purpose, timing}
- **Neo4j**: Document nodes linked to Event nodes via EXTRACTED_FROM relationship

**Files affected:**
- `/stockelper-kg/modules/dart_disclosure/universe.ai-sector.template.json` (new - universe definition)
- `/stockelper-kg/src/stockelper_kg/collectors/dart_major_reports.py` (new - 20-type collector)
- `/stockelper-kg/migrations/001_create_dart_disclosure_tables.sql` (new - 20 table schemas)
- `/stockelper-airflow/dags/dart_disclosure_collection_dag.py` (new DAG - daily 8AM collection)
- `/stockelper-kg/src/stockelper_kg/extractors/dart_event_extractor.py` (new - event extraction from structured data)
- `/stockelper-kg/src/stockelper_kg/prompts/dart_event_extraction.py` (DART-specific prompts)

**Implementation Reference:**
- Complete architecture: `docs/architecture.md` Lines 232-377
- Implementation guide: `docs/CURSOR-PROMPT-DART-36-TYPE-IMPLEMENTATION.md`
- Reference code: `docs/references/DART(modified events).md` (민우 2026-01-03)

---

#### Story 1.2: Frontend Event Timeline Visualization

**As a** user
**I want** to see a visual timeline of historical events for a stock
**So that** I can understand the event context behind predictions

**Acceptance Criteria:**

**Given** a user queries a stock through the chat interface
**When** the system retrieves historical events from Neo4j
**Then** the following conditions are met:
- Chat interface displays interactive timeline showing events over time
- Timeline groups events by date with visual markers
- Each event shows: category, description, date, entities involved (FR5)
- Timeline highlights "similar events" matched by prediction engine (FR13, FR17)
- Users can click event to expand full details
- Timeline loads within 1 second (NFR-P11)
- Timeline supports Korean language display (NFR-U1)
- Timeline shows minimum 3 months of historical events, maximum 12 months
- Visual design follows UX emotional design priorities (calm, transparent)

**Database changes:**
- None (reads from existing Neo4j event graph)

**Files affected:**
- `/stockelper-fe/src/components/chat/event-timeline.tsx` (new component)
- `/stockelper-fe/src/app/api/events/timeline/route.ts` (new API endpoint)
- `/stockelper-llm/src/api/events.py` (new endpoint for timeline data)

---

#### Story 1.3: Multi-Timeframe Prediction UI with Confidence Indicators

**As a** user
**I want** to see predictions across multiple timeframes (short/medium/long-term) with confidence levels
**So that** I can make informed investment decisions based on different horizons

**Acceptance Criteria:**

**Given** a user requests stock prediction through chat
**When** the prediction response is displayed
**Then** the following conditions are met:
- Chat displays three prediction timeframes: short-term (days-weeks), medium-term (weeks-months), long-term (months+) (FR9-FR11)
- Each timeframe shows: predicted direction, confidence level percentage (FR12), supporting rationale (FR18)
- Confidence levels visually indicated (e.g., color-coded: high=green, medium=yellow, low=red)
- Prediction card shows "Based on X similar historical events" (FR16)
- Users can click to expand historical event examples (FR17)
- Prediction includes embedded disclaimer (FR69)
- Prediction query completes within 2 seconds (NFR-P1)
- UI supports Korean language (NFR-U1)
- Visual design creates "aha moment" for first prediction (UX emotional design)

**Database changes:**
- None (uses existing prediction engine output)

**Files affected:**
- `/stockelper-fe/src/components/chat/prediction-card.tsx` (new component)
- `/stockelper-fe/src/components/chat/confidence-indicator.tsx` (new component)

---

#### Story 1.4: Rich Chat Prediction Cards with Historical Context

**As a** user
**I want** predictions displayed as rich, scannable cards with visual hierarchy
**So that** I can quickly understand the key insights and explore details as needed

**Acceptance Criteria:**

**Given** a prediction response from the chat API
**When** the chat interface renders the prediction
**Then** the following conditions are met:
- Prediction rendered as structured card (not plain text)
- Card header shows: stock name, current event trigger, confidence level
- Card body shows: prediction summary, key historical patterns, rationale (FR18, FR21)
- Card footer shows: "View similar events" expandable section (FR16, FR17)
- Expandable section displays 3-5 most relevant historical event examples
- Each historical example shows: date, event description, outcome, price impact (FR14)
- Card supports "Explain this prediction" interaction for conversational drill-down (FR53)
- Rendering maintains smooth chat performance (zero errors, instant responsiveness - UX critical success factor)
- Card design follows calm, transparent emotional design (no FOMO tactics)

**Database changes:**
- None (uses existing Neo4j historical pattern matching)

**Files affected:**
- `/stockelper-fe/src/components/chat/prediction-card.tsx` (enhance existing component)
- `/stockelper-fe/src/components/chat/historical-example.tsx` (new component)
- `/stockelper-fe/src/styles/chat.css` (card styling)

---

#### Story 1.5: Suggested Queries Based on Portfolio

**As a** user
**I want** the chat interface to suggest relevant queries based on my portfolio
**So that** I can easily discover insights without knowing what to ask

**Acceptance Criteria:**

**Given** a user has stocks in their portfolio
**When** the user opens the chat interface or finishes a conversation
**Then** the following conditions are met:
- Chat displays 3-5 suggested query chips below input field
- Suggestions include: "What's the latest on [stock name]?", "Show predictions for [stock name]", "Any new events for my portfolio?"
- Suggestions dynamically update based on portfolio composition
- Suggestions prioritize stocks with recent events (last 7 days)
- Clicking suggestion chip sends query and triggers prediction/analysis
- Suggestions display in Korean (NFR-U1)
- Suggestions appear within 500ms of page load (NFR-P2)
- Empty portfolio shows generic suggestions: "Try asking about a stock", "How does prediction work?"
- Suggestions follow UX contextual help principle (NFR-U5)

**Database changes:**
- None (reads from existing PostgreSQL user portfolio table)

**Files affected:**
- `/stockelper-fe/src/components/chat/suggested-queries.tsx` (new component)
- `/stockelper-fe/src/app/api/chat/suggestions/route.ts` (new API endpoint)

---

#### Story 1.8: Daily Stock Price Data Collection (NEW - Added 2026-01-03)

**As a** backtesting system
**I want** daily stock price data for all universe stocks collected automatically
**So that** backtesting can calculate historical returns accurately

**Acceptance Criteria:**

**Given** AI-sector universe stocks defined in template
**When** the daily price collection pipeline executes
**Then** the following conditions are met:

**Price Data Collection (FR131):**
- Collect daily OHLCV (Open, High, Low, Close, Volume) data for all universe stocks (FR131)
- Data source: KIS OpenAPI or similar Korean stock market data provider
- Collection based on same universe template: `modules/dart_disclosure/universe.ai-sector.template.json`
- Daily schedule: After market close (4:00 PM KST, weekdays only)
- Store in **Local PostgreSQL** table `daily_stock_prices`
- Include fields: stock_code, trade_date, open_price, high_price, low_price, close_price, volume, market_cap
- Deduplication by (stock_code, trade_date) composite primary key
- Rate limiting: Max 5 requests/sec to respect API limits
- Historical retention: Keep all historical data (no cleanup policy)

**Data Quality:**
- Validate all required fields populated before storage
- Handle missing data gracefully (log warning, continue collection)
- Check for data anomalies (e.g., zero volume, extreme price changes)
- Retry failed requests up to 3 times with exponential backoff

**Database changes:**
- **Local PostgreSQL**: New table `daily_stock_prices` with schema:
  ```sql
  CREATE TABLE daily_stock_prices (
      stock_code VARCHAR(6) NOT NULL,
      trade_date DATE NOT NULL,
      open_price DECIMAL(12,2),
      high_price DECIMAL(12,2),
      low_price DECIMAL(12,2),
      close_price DECIMAL(12,2),
      volume BIGINT,
      market_cap DECIMAL(20,2),
      created_at TIMESTAMP DEFAULT NOW(),
      PRIMARY KEY (stock_code, trade_date)
  );
  CREATE INDEX idx_stock_date ON daily_stock_prices(stock_code, trade_date DESC);
  ```

**Files affected:**
- `/stockelper-airflow/dags/daily_price_collection_dag.py` (new DAG)
- `/stockelper-kg/src/stockelper_kg/collectors/daily_price_collector.py` (new - price data collector)
- `/stockelper-kg/migrations/002_create_daily_price_table.sql` (new - table schema)

**Integration:**
- Backtesting service reads from this table for historical price data
- Portfolio recommendation service may use for performance calculations
- Event intelligence may correlate events with price movements

**Implementation Reference:**
- Complete architecture: `docs/architecture.md` Lines 381-451

---

### Epic 2: Portfolio Management UI & Scheduled Recommendations

Users manage portfolios through dedicated UI and receive daily personalized recommendations before market open using Black-Litterman optimization and LangGraph workflows.

**FRs covered:** FR19-FR28, FR28a-FR28r

**Implementation Notes:**
- Frontend portfolio tracking interface (add/remove stocks, view holdings)
- Dedicated portfolio recommendation page (button-triggered)
- Scheduled 9:00 AM daily recommendation DAG (Airflow)
- Notification delivery integration
- Connect chat to existing PortfolioAnalysisAgent backend

**Black-Litterman Portfolio Optimization (FR28a-FR28r):**
- **11-Factor Ranking System:** Operating profit, net income, total liabilities, rise/fall rates, profitability, stability, growth, activity, volume, market cap
- **Parallel Execution:** All 11 factors computed in parallel with rate limiting (20 req/sec)
- **Normalized Scoring:** (n - rank + 1) / (n * (n+1) / 2) per factor
- **LLM-Based InvestorViews:** GPT-5.1 generates expected returns (-20% to +20%) with confidence scores (0-1)
- **10-Step Pipeline:**
  1. Calculate returns covariance (252-day annualized)
  2. Calculate market weights (score-based)
  3. Calculate risk aversion (6% market premium / variance)
  4. Calculate implied equilibrium returns (pi = delta * Sigma * w_mkt)
  5. Construct view matrices (P, Q, Omega)
  6. Calculate posterior returns (Black-Litterman formula with tau=0.025)
  7. Optimize portfolio (SLSQP solver, constraints: sum=1.0, each ∈ [0, 0.3])
  8. Calculate metrics (return, volatility, Sharpe ratio)
  9. Filter weights < 0.001
  10. Execute via KIS API (market orders)

**LangGraph Buy/Sell Workflows:**
- **Buy Workflow:** LoadUserContext → Ranking (11 factors, parallel) → Analysis (3 parallel nodes: WebSearch, FinancialStatement, TechnicalIndicator) → ViewGenerator (LLM-based InvestorViews) → PortfolioBuilder (Black-Litterman) → PortfolioTrader (KIS API)
- **Sell Workflow:** LoadUserContext → GetPortfolioHoldings → Analysis (3 parallel nodes) → SellDecisionMaker (LLM evaluates 5 criteria: loss/profit thresholds, fundamentals, technicals, news, industry) → PortfolioSeller
- **State Management:** BuyInputState, BuyPrivateState, BuyOutputState, SellInputState, SellPrivateState, SellOutputState
- **Paper/Live Trading Modes:** Configurable via environment variables

**KIS API Integration:**
- KIS OpenAPI for trade execution (Buy/Sell orders)
- Token auto-refresh mechanism
- Paper trading mode for testing
- Live trading with user credentials

#### Story 2.1: Investment Profile Questionnaire During Sign-Up

**As a** new user
**I want** to complete a risk tolerance questionnaire during sign-up
**So that** the system can personalize recommendations based on my investment preferences

**Acceptance Criteria:**

**Given** a user is completing the sign-up process
**When** the user reaches the investment profile step
**Then** the following conditions are met:
- Questionnaire displays 5-7 questions assessing risk tolerance (conservative, moderate, aggressive)
- Questions include: investment horizon, risk comfort level, investment experience, preferred sectors
- User can select answers via radio buttons or dropdowns (Korean language - NFR-U1)
- Questionnaire results calculate risk profile score (1-10 scale)
- Profile saved to PostgreSQL `user_profiles` table with user_id foreign key (FR26)
- User can skip questionnaire (default to "moderate" profile)
- Questionnaire completes within sign-up flow (no separate step post-registration)
- Form validation provides clear error messages (NFR-U2)

**Database changes:**
- PostgreSQL: Create `user_profiles` table with columns: user_id (FK), risk_tolerance (enum: conservative/moderate/aggressive), investment_horizon (enum: short/medium/long), preferred_sectors (JSON array), created_at, updated_at

**Files affected:**
- `/stockelper-fe/src/app/(auth)/signup/investment-profile/page.tsx` (new step)
- `/stockelper-fe/src/app/api/user/profile/route.ts` (new API endpoint)
- `/stockelper-llm/src/api/user_profiles.py` (new endpoint)
- Database migration script for `user_profiles` table

---

#### Story 2.2: KIS OpenAPI Key Registration During Sign-Up

**As a** new user
**I want** to register my KIS OpenAPI key during sign-up
**So that** the system can access real-time stock data for my personalized analysis

**Acceptance Criteria:**

**Given** a user is completing the sign-up process
**When** the user reaches the KIS API configuration step
**Then** the following conditions are met:
- Form displays fields for KIS App Key and KIS App Secret
- User can paste or type keys into secure input fields (masked display)
- "Test Connection" button validates keys against KIS API before saving
- Successful validation displays green checkmark confirmation
- Failed validation shows error message with troubleshooting link
- Keys encrypted at rest using AES-256 (NFR-S1) before storing in PostgreSQL
- Keys stored in `user_kis_credentials` table with user_id foreign key
- User can skip this step (限制 some features until configured)
- Clear messaging explains why KIS keys are needed (transparency - UX priority)

**Database changes:**
- PostgreSQL: Create `user_kis_credentials` table with columns: user_id (FK), app_key_encrypted (text), app_secret_encrypted (text), is_validated (boolean), created_at, updated_at

**Files affected:**
- `/stockelper-fe/src/app/(auth)/signup/kis-setup/page.tsx` (new step)
- `/stockelper-fe/src/app/api/user/kis/route.ts` (new API endpoint)
- `/stockelper-llm/src/api/kis_credentials.py` (new endpoint with encryption)
- Database migration script for `user_kis_credentials` table

---

#### Story 2.3: Portfolio Tracking UI (Add/Remove/View Stocks)

**As a** user
**I want** to manage my portfolio through a dedicated UI
**So that** I can track stocks I'm interested in and receive personalized alerts

**Acceptance Criteria:**

**Given** an authenticated user accesses the portfolio page
**When** the user interacts with the portfolio interface
**Then** the following conditions are met:
- Page displays current portfolio holdings in table format (stock name, ticker, date added)
- "Add Stock" button opens search modal for adding stocks (Korean stock search)
- Search supports Korean company names and ticker symbols (e.g., "삼성전자" or "005930")
- User can add stock to portfolio (FR24), triggers POST to `/api/portfolio/add`
- User can remove stock from portfolio (FR28), triggers DELETE to `/api/portfolio/remove`
- Portfolio updates appear within 500ms (NFR-P12)
- Empty portfolio shows onboarding message: "Add stocks to get started"
- Portfolio limited to AI-sector stocks for MVP (Naver, Kakao, 이스트소프트, 알체라, 레인보우로보틱스)
- User can view up to 20 stocks in portfolio (prevents overwhelming notifications)
- Portfolio changes logged for audit trail

**Database changes:**
- PostgreSQL: Create `user_portfolios` table with columns: id, user_id (FK), stock_ticker (varchar), stock_name_kr (varchar), added_at, updated_at
- Index on (user_id, stock_ticker) for fast lookups

**Files affected:**
- `/stockelper-fe/src/app/(has-layout)/portfolio/page.tsx` (new page)
- `/stockelper-fe/src/components/portfolio/stock-search-modal.tsx` (new component)
- `/stockelper-fe/src/app/api/portfolio/route.ts` (CRUD endpoints)
- Database migration script for `user_portfolios` table

---

#### Story 2.4: Dedicated Portfolio Recommendation Page with Accumulated History

**As a** user
**I want** a dedicated page where I can request portfolio recommendations and view accumulated history
**So that** I can review personalized stock suggestions based on recent events and track recommendations over time

**Acceptance Criteria:**

**Given** an authenticated user with stocks in their portfolio
**When** the user navigates to the portfolio recommendations page
**Then** the following conditions are met:

**Generation & Real-Time Updates (FR109, FR110):**
- Page displays "Generate Recommendation" button prominently
- Clicking button triggers portfolio analysis via LangGraph Buy workflow (gpt-5.1)
- Status transitions: PENDING → IN_PROGRESS → COMPLETED/FAILED (FR117)
- Loading state shows progress indicator with message "Analyzing recent events..." (async UX pattern)
- Recommendations complete within 1-3 minutes (per meeting notes)
- Chat can also trigger generation (response: "Recommendation is in progress and will be completed in 1-3 minutes")
- Results NOT shown directly in chat (appear on this page only)
- Frontend subscribes to Supabase Realtime for `portfolio_recommendations` table changes (FR104, FR107)
- UI updates in real-time when status changes (no manual refresh required)

**Black-Litterman Workflow Implementation (FR28a-FR28r):**
- **LangGraph Buy Workflow Execution:**
  1. LoadUserContext → Load user portfolio, risk tolerance, investment horizon
  2. Ranking → Execute 11-factor ranking in parallel (operating profit, net income, liabilities, rise/fall rates, profitability, stability, growth, activity, volume, market cap)
  3. Analysis → 3 parallel nodes: WebSearch (news), FinancialStatement (5-year DART), TechnicalIndicator (Prophet+ARIMA)
  4. ViewGenerator → LLM generates InvestorViews (expected returns: -20% to +20%, confidence: 0-1)
  5. PortfolioBuilder → Black-Litterman optimization with SLSQP solver
  6. PortfolioTrader → Execute trades via KIS API (paper/live mode)
- **Parallel Execution:** 11 factors ranked in parallel with rate limiting (20 req/sec)
- **Normalized Scoring:** (n - rank + 1) / (n * (n+1) / 2) per factor
- **Black-Litterman 10 Steps:**
  1. Calculate returns covariance (252-day annualized)
  2. Calculate market weights (score-based)
  3. Calculate risk aversion (6% market premium / variance)
  4. Calculate implied equilibrium returns (pi = delta * Sigma * w_mkt)
  5. Construct view matrices (P, Q, Omega)
  6. Calculate posterior returns (Black-Litterman formula with tau=0.025)
  7. Optimize portfolio (SLSQP, constraints: sum=1.0, each ∈ [0, 0.3])
  8. Calculate metrics (return, volatility, Sharpe ratio)
  9. Filter weights < 0.001
  10. Generate Markdown report with recommendations
- **State Management:** BuyInputState (user_id, universe), BuyPrivateState (rankings, analysis results), BuyOutputState (portfolio weights, report)

**Accumulated History Display (FR111, FR112, FR113, FR114):**
- Page displays table/list of ALL previous recommendations sorted by most recent first (FR111)
- Each row shows: creation timestamp, status indicator, preview of recommendations (FR112)
- Clicking row opens LLM-generated Markdown report on same page (NOT new page) (FR114)
- Markdown content rendered with charts, tables, recommended stocks (FR116, FR118)
- Stale recommendations (>3 days old) display warning message: "This recommendation is from X days ago and may be outdated" (FR113)
- Each recommendation row shows status badge: PENDING (gray), IN_PROGRESS (yellow), COMPLETED (green), FAILED (red)

**Data Model & Ownership (FR115, FR116, FR119, FR120):**
- Unified schema: content (Markdown), user_id, image_base64 (optional), created_at, updated_at, completed_at, status (FR116)
- PortfolioAnalysisAgent fully owns data generation, status transitions, database inserts/updates (FR119)
- Frontend only subscribes to Supabase Realtime and renders UI (FR120)

**Notifications (FR106, FR108):**
- Browser notification delivered when recommendation completes (FR106)
- Confluence-style browser notification: "Portfolio recommendation completed" (FR108)
- Clicking notification navigates to portfolio recommendation page

**Other:**
- Each recommendation includes embedded disclaimer (FR70)
- User can add recommended stocks to portfolio directly from Markdown report
- Page accessible via GNB navigation and notification click
- Empty portfolio shows message: "Add stocks to your portfolio to receive recommendations"

**Database changes (Updated 2026-01-03):**
- PostgreSQL on AWS t3.medium: Create `portfolio_recommendations` table with columns:
  - id (SERIAL PRIMARY KEY)
  - **job_id (UUID NOT NULL UNIQUE)** (NEW - FR129) - Unique job identifier for tracking
  - user_id (FK)
  - content (TEXT - Markdown)
  - image_base64 (TEXT nullable) - Optional chart/visualization
  - **status (VARCHAR(20) CHECK constraint)** (UPDATED - FR130) - Korean enum: '작업 전', '처리 중', '완료', '실패'
  - created_at (TIMESTAMP DEFAULT NOW()) - Request initiated
  - updated_at (TIMESTAMP DEFAULT NOW()) - Last modification
  - written_at (TIMESTAMP nullable) - Result written
  - completed_at (TIMESTAMP nullable) - Job finished
- **Indexes:**
  - CREATE INDEX idx_portfolio_user ON portfolio_recommendations(user_id, created_at DESC)
  - CREATE INDEX idx_portfolio_job ON portfolio_recommendations(job_id)
  - CREATE INDEX idx_portfolio_status ON portfolio_recommendations(status) WHERE status IN ('작업 전', '처리 중')
- Enable Supabase Realtime on `portfolio_recommendations` table
- **Korean Status Enum Values (FR130):**
  - '작업 전' (Before Processing) - Initial state
  - '처리 중' (In Progress) - Portfolio generation running
  - '완료' (Completed) - Recommendation ready
  - '실패' (Failed) - Error during generation

**Files affected:**
- `/stockelper-fe/src/app/(has-layout)/recommendations/page.tsx` (updated with table/list + Markdown viewer)
- `/stockelper-fe/src/components/recommendations/recommendation-table.tsx` (new component)
- `/stockelper-fe/src/components/recommendations/markdown-report-viewer.tsx` (new component)
- `/stockelper-fe/src/app/api/recommendations/generate/route.ts` (triggers agent, returns immediately)
- `/stockelper-fe/src/hooks/useSupabaseRealtimeSubscription.ts` (new hook for Supabase Realtime)
- **Portfolio Service (LangGraph Buy Workflow):**
  - `/stockelper-portfolio/src/portfolio_multi_agent/buy/graph.py` (Buy workflow StateGraph definition)
  - `/stockelper-portfolio/src/portfolio_multi_agent/buy/state.py` (BuyInputState, BuyPrivateState, BuyOutputState)
  - `/stockelper-portfolio/src/portfolio_multi_agent/buy/nodes/ranking.py` (11-factor ranking node)
  - `/stockelper-portfolio/src/portfolio_multi_agent/buy/nodes/view_generator.py` (LLM InvestorView generation)
  - `/stockelper-portfolio/src/portfolio_multi_agent/buy/nodes/portfolio_builder.py` (Black-Litterman optimization)
  - `/stockelper-portfolio/src/portfolio_multi_agent/buy/nodes/portfolio_trader.py` (KIS API execution)
  - `/stockelper-portfolio/src/routers/portfolio_router.py` (API endpoints: POST /api/portfolio/buy)
- Database migration script for `portfolio_recommendations` table with Supabase Realtime

**Implementation Reference:**
- Complete Buy workflow: `docs/architecture.md` Lines 2758-2896
- Black-Litterman formulas: Architecture Repository 6 section

---

#### Story 2.5: Scheduled Daily Portfolio Recommendations (9 AM)

**As a** user
**I want** to receive daily portfolio recommendations before market open
**So that** I can review suggestions before making investment decisions

**Acceptance Criteria:**

**Given** a user has stocks in their portfolio and a configured investment profile
**When** the Airflow DAG executes at 9:00 AM KST (before market open at 9:00 AM)
**Then** the following conditions are met:
- Airflow DAG triggers at 8:55 AM KST daily (weekdays only)
- DAG iterates through all users with non-empty portfolios
- For each user, DAG calls PortfolioAnalysisAgent to generate recommendations (FR20)
- Recommendations analyze recent events (last 24 hours) for portfolio stocks
- Generated recommendations saved to `portfolio_recommendations_log` table
- Notification created in `notifications` table with type='portfolio_recommendation'
- Users receive notification via GNB notification icon (notification badge pattern)
- Clicking notification navigates to portfolio recommendations page (Story 2.4)
- DAG execution completes by 9:00 AM (before market open)
- Failed user processing logged and retried (up to 3 attempts - NFR-R8)
- DAG execution logs viewable in Airflow UI

**Database changes:**
- None (uses tables from Stories 2.4 and Epic 4 notification system)

**Files affected:**
- `/stockelper-airflow/dags/daily_portfolio_recommendations_dag.py` (new DAG)
- `/stockelper-llm/src/api/scheduled_recommendations.py` (new endpoint for batch processing)

**Implementation Notes:**
- **Airflow Pattern Source:** Reference Epic 1 Story 1.1 (News Crawler Airflow DAG) for DAG implementation patterns
- Reuse DAG structure, error handling (retry up to 3 times - NFR-R8), and logging patterns from Epic 1.1
- Schedule trigger pattern: cron expression for daily 8:55 AM KST execution

---

### Epic 3: Backtesting Engine

Users validate investment strategies through historical backtesting with async job queue processing and comprehensive results visualization.

**FRs covered:** FR29-FR39, FR39a-FR39r

**Implementation Notes:**
- Complete new implementation (100% new work)
- Event-based strategy simulator
- 3/6/12-month historical return calculation
- Sharpe Ratio calculation and buy-and-hold comparison
- Async job processing (5 minutes to 1 hour execution time)
- PostgreSQL job queue with polling-based async worker
- Frontend results visualization with charts
- Notification on completion

**Async Job Queue Implementation (FR39a-FR39r):**
- **Database Tables:**
  1. `backtest_jobs`: id, user_id, stock_ticker, strategy_type, status, input_json, error_message, retry_count, timestamps
  2. `backtest_results`: id, job_id, user_id, results_json (JSONB), generated_at
  3. `notifications`: id, user_id, type, title, message, data, is_read, timestamps
- **Job Status Flow:** pending → in_progress → completed/failed
- **Polling-Based Async Worker:**
  - Default polling interval: 5 seconds
  - SELECT ... FOR UPDATE SKIP LOCKED for concurrent-safe job reservation
  - Exponential backoff on failures
  - Finalizes success: insert result + update status + create notification
  - Finalizes failure: store error + update status + create notification
- **Dual API Endpoints:**
  - Legacy: POST /backtesting/jobs, GET /backtesting/jobs/{id}
  - Architecture-compatible: POST /api/backtesting/execute, GET /api/backtesting/{id}/status, GET /api/backtesting/{id}/result
- **Status Mapping with Progress:**
  - pending → queued (0%)
  - in_progress → running (50%)
  - completed → completed (100%)
  - failed → failed (100%)
- **Execution Time:**
  - Simple 1-year backtest: ~5 minutes
  - Complex multi-indicator strategy: Up to 1 hour
- **JSONB Flexible Storage:** Results stored as structured JSONB in `backtest_results.results_json`
- **User-Scoped Isolation:** All queries filtered by user_id

**LLM Parameter Extraction (FR29a-FR29b):**
- GPT-5.1 extracts backtesting parameters from chat input: universe (stock list), strategy (event-based strategy name)
- If parameters clear: proceed directly to submission
- If parameters unclear: LLM prompts user with follow-up questions (human-in-the-loop)
- Chat responds: "Backtesting in progress. Navigate to [backtesting results page] to check status."

**Results Visualization:**
- Results NOT shown in chat interface
- Dedicated backtesting results page with table/list format
- Each row shows: stock name, strategy, status, creation timestamp
- Clicking row opens LLM-generated Markdown report with charts and tables
- Browser notification on completion (Confluence-style)

#### Story 3.1: Backtesting Container Backend Infrastructure with LLM Parameter Extraction

**As a** developer
**I want** to implement separate backtesting container backend with LLM parameter extraction
**So that** users can request backtesting via chat with intelligent parameter handling

**Acceptance Criteria:**

**Given** a user requests backtesting via chat
**When** the system processes the request
**Then** the following conditions are met:

**LLM Parameter Extraction (FR29a, FR29b):**
- LLM (gpt-5.1) extracts backtesting parameters from user chat input: universe (stock list), strategy (event-based strategy name)
- If universe and strategy explicitly mentioned, LLM extracts directly and sends to backtesting container
- If parameters unclear or missing, LLM prompts user with follow-up questions (human-in-the-loop) (FR29b)
- Example follow-up: "Which stocks would you like to backtest?" or "Which strategy: event-driven buy, sentiment-based, or pattern-matching?"
- Chat responds with "Backtesting in progress. Navigate to [backtesting results page] to check status." (FR29c)

**Backtesting Container Backend (FR30a, FR30b, FR39a-FR39r):**
- Backtesting runs in separate container backend (NOT in LLM server)
- LLM sends backtesting parameters (universe, strategy, user_id) to backtesting container via API
- Backtesting container: standalone service running on port 21011
- Container processes backtesting request asynchronously via PostgreSQL job queue
- **Async Job Queue Architecture:**
  - PostgreSQL tables: `backtest_jobs`, `backtest_results`, `notifications` (FR39a-FR39d)
  - Job status flow: pending → in_progress → completed/failed (FR39e)
  - Polling-based async worker with 5-second interval (FR39f)
  - **SELECT ... FOR UPDATE SKIP LOCKED** for concurrent-safe job reservation (FR39g)
  - Worker loop: Poll pending jobs → Reserve job → Execute backtest → Finalize (success/failure)
  - Exponential backoff on failures with max retry_count (FR39h)
  - Success finalization: Insert `backtest_results` + Update status to completed + Create notification (FR39i)
  - Failure finalization: Store error_message + Update status to failed + Create notification (FR39j)
- **Dual API Endpoints (FR39k-FR39l):**
  - Legacy: POST /backtesting/jobs, GET /backtesting/jobs/{id}
  - Architecture-compatible: POST /api/backtesting/execute, GET /api/backtesting/{id}/status, GET /api/backtesting/{id}/result
- **Status Mapping Function (FR39m):**
  ```python
  def _map_job_status(db_status):
      mapping = {
          "pending": ("queued", 0),
          "in_progress": ("running", 50),
          "completed": ("completed", 100),
          "failed": ("failed", 100)
      }
      return mapping.get(db_status, ("unknown", 0))
  ```
- **Execution Time:** Simple 1-year backtest ~5 minutes, Complex strategy up to 1 hour (FR39n)
- **JSONB Storage:** Results stored as structured JSONB in `backtest_results.results_json` (FR39o)
- **User-Scoped Isolation:** All queries filtered by user_id (FR39p)

**Notification & Results - Supabase Realtime (FR31a, FR31b, FR31c, FR104-FR108, FR121-FR125):**
- Backtesting container writes results to PostgreSQL on AWS t3.medium when job completes (FR31a)
- Status transitions: PENDING → IN_PROGRESS → COMPLETED/FAILED (FR117)
- Frontend subscribes to Supabase Realtime for `backtest_jobs` table changes (FR104, FR107)
- UI updates in real-time when status changes (no polling required) (FR107)
- Browser notification delivered when job completes: "Backtesting completed for Samsung" (FR105, FR108)
- Confluence-style browser notification (accumulating, non-intrusive) (FR108)
- Results generated as LLM-generated Markdown report (FR31b, FR118)
- Users view results on dedicated backtesting results page (NOT chat interface) (FR31c, FR121)
- Results page displays jobs in table/list format sorted by most recent first (FR121)
- Clicking job row opens Markdown report on same page (NOT new page) (FR122)
- Each row shows: stock name, strategy, status, creation timestamp (FR124)
- Markdown reports include charts, tables, and performance metrics (FR125)

**Data Model & Ownership (FR115, FR117, FR119, FR120):**
- Unified schema: content (Markdown), user_id, image_base64 (optional), universe, strategy, created_at, updated_at, completed_at, status (FR115)
- Backtesting container fully owns data generation, status transitions, database writes (FR119)
- Frontend only subscribes to Supabase Realtime and renders UI (FR120)

**Database changes (Updated 2026-01-03):**
- PostgreSQL on AWS t3.medium: Create `backtest_results` table with columns:
  - id (UUID - SERIAL PRIMARY KEY)
  - **job_id (UUID - UNIQUE)** (NEW - FR128) - Unique job identifier for tracking
  - user_id (FK)
  - universe (JSONB - stock list)
  - strategy (VARCHAR - strategy name)
  - **strategy_description (TEXT)** (NEW) - User's backtesting strategy in natural language
  - **universe_filter (TEXT)** (NEW) - Applied universe filter (e.g., "AI sector")
  - content (TEXT - Markdown report, nullable)
  - image_base64 (TEXT nullable) - Optional performance chart
  - **status (VARCHAR(20) CHECK constraint)** (UPDATED - FR130) - Korean enum: '작업 전', '처리 중', '완료', '실패'
  - error_message (TEXT nullable)
  - retry_count (INT default 0)
  - **execution_time_seconds (INT)** (NEW) - Actual execution duration (5min-1hr range expected)
  - created_at (TIMESTAMP) - Request initiated
  - updated_at (TIMESTAMP) - Last modification
  - **written_at (TIMESTAMP nullable)** (NEW) - Result written
  - started_at (TIMESTAMP nullable)
  - completed_at (TIMESTAMP nullable) - Job finished
- **Indexes:**
  - CREATE INDEX idx_backtest_user ON backtest_results(user_id, created_at DESC)
  - CREATE INDEX idx_backtest_job ON backtest_results(job_id)
  - CREATE INDEX idx_backtest_status ON backtest_results(status) WHERE status IN ('작업 전', '처리 중')
- Enable Supabase Realtime on `backtest_results` table
- **Korean Status Enum Values (FR130):**
  - '작업 전' (Before Processing) - Initial state
  - '처리 중' (In Progress) - Backtesting running (5min-1hr expected)
  - '완료' (Completed) - Results ready for viewing
  - '실패' (Failed) - Error during backtesting
- **Performance Constraints (from 2026-01-03 meeting):**
  - Simple 1-year backtest: ~5 minutes execution time
  - Complex multi-indicator strategy: Up to 1 hour execution time
  - Async processing required with browser notifications on completion

**Files affected:**
- `/stockelper-llm/src/api/backtesting.py` (LLM parameter extraction logic)
- `/stockelper-llm/src/agents/backtesting_agent.py` (human-in-the-loop prompting)
- **Backtesting Service (Async Job Queue):**
  - `/stockelper-backtesting/src/backtesting/models.py` (Database models: BacktestJob, BacktestResult, Notification)
  - `/stockelper-backtesting/src/backtesting/worker.py` (Polling-based async worker with SELECT...FOR UPDATE SKIP LOCKED)
  - `/stockelper-backtesting/src/backtesting/executor.py` (Backtest execution logic)
  - `/stockelper-backtesting/src/routers/backtesting_router.py` (API endpoints)
  - `/stockelper-backtesting/src/utils/status_mapper.py` (Status mapping function)
  - `/stockelper-backtesting/alembic/versions/001_create_backtest_tables.py` (Database migrations)
- `/stockelper-fe/src/app/backtesting/results/page.tsx` (new results page with table/list + Markdown viewer)
- `/stockelper-fe/src/components/backtesting/backtest-table.tsx` (new component)
- `/stockelper-fe/src/components/backtesting/markdown-report-viewer.tsx` (reuse from portfolio)
- `/stockelper-fe/src/hooks/useSupabaseRealtimeSubscription.ts` (shared hook for Supabase Realtime)
- Database migration scripts for `backtest_jobs` table with Supabase Realtime

**Implementation Reference:**
- Complete async job queue architecture: `docs/architecture.md` Lines 2900-3046
- Database schemas with full SQL: Architecture Repository 7 section
- Worker implementation and status mapping: Architecture backtesting section

---

#### Story 3.2: Event-Based Strategy Simulator

**As a** user
**I want** the system to simulate investment strategies based on historical event patterns
**So that** I can validate if event-driven investing would have been profitable

**Acceptance Criteria:**

**Given** a backtesting job for a specific stock and strategy
**When** the simulator executes
**Then** the following conditions are met:
- Simulator retrieves historical instances of similar events from Neo4j (FR31)
- For each historical event instance, simulator captures: event date, stock ticker, event category
- Simulator retrieves stock price data from KIS API for relevant date ranges
- Strategy logic defines entry/exit rules based on event occurrence (e.g., "buy on event detection, hold for 30 days")
- Simulator calculates returns for each historical instance (buy price vs. sell price)
- Simulator aggregates results across all historical instances
- Minimum 5 historical instances required for valid backtest (FR39)
- Simulator shows number of historical instances used in backtest (FR39)
- Simulator handles missing price data gracefully (skip instance with logging)
- Results include: total returns, average return per instance, win rate percentage

**Database changes:**
- None (results stored in `backtest_results` table from Story 3.1)

**Files affected:**
- `/stockelper-llm/src/backtesting/simulator.py` (new module)
- `/stockelper-llm/src/backtesting/strategies/event_driven.py` (strategy definitions)

---

#### Story 3.3: Historical Return Calculation (3/6/12 Months)

**As a** user
**I want** to see backtest results across multiple timeframes
**So that** I can understand strategy performance for different holding periods

**Acceptance Criteria:**

**Given** a backtest simulation completes for a stock
**When** the system calculates historical returns
**Then** the following conditions are met:
- System calculates 3-month returns for event-based strategy (FR32)
- System calculates 6-month returns for event-based strategy (FR33)
- System calculates 12-month returns for event-based strategy (FR34)
- Each timeframe calculation uses appropriate historical window (e.g., 3-month = 90 days holding period)
- Returns calculated as percentage gain/loss from entry price to exit price
- Timeframe results aggregated across all historical instances
- Results include: average return, median return, standard deviation
- Results show performance range: best case (max return) and worst case (min return) (FR37)
- Missing data for specific timeframes marked as "insufficient data" (not failed)

**Database changes:**
- None (results stored in `backtest_results.results_json` field as structured JSON)

**Files affected:**
- `/stockelper-llm/src/backtesting/return_calculator.py` (new module)

---

#### Story 3.4: Sharpe Ratio Calculation and Baseline Comparison

**As a** user
**I want** to see Sharpe Ratio and comparison to buy-and-hold strategy
**So that** I can evaluate risk-adjusted returns of the event-based strategy

**Acceptance Criteria:**

**Given** historical returns calculated for a backtest
**When** the system performs risk analysis
**Then** the following conditions are met:
- Sharpe Ratio calculated using: (average return - risk-free rate) / standard deviation (FR35)
- Risk-free rate assumed as 3% annual (configurable)
- Sharpe Ratio calculated for each timeframe (3/6/12 months)
- Buy-and-hold baseline strategy simulated for same time periods
- Buy-and-hold returns calculated as: buy at start of period, sell at end of period
- Comparison shows: event-based return vs. buy-and-hold return (FR36)
- Comparison shows: event-based Sharpe vs. buy-and-hold Sharpe
- Results clearly indicate which strategy outperformed
- Risk disclosure embedded in results (FR38): "Past performance does not guarantee future results"

**Database changes:**
- None (results stored in `backtest_results.results_json` field)

**Files affected:**
- `/stockelper-llm/src/backtesting/risk_metrics.py` (new module)
- `/stockelper-llm/src/backtesting/baseline_strategies.py` (new module)

---

#### Story 3.5: Backtesting Results Visualization with Charts

**As a** user
**I want** to see backtesting results visualized with charts and clear summaries
**So that** I can quickly understand strategy performance

**Acceptance Criteria:**

**Given** a backtesting job completes successfully
**When** the user views results
**Then** the following conditions are met:
- Results page displays summary card: total return, Sharpe Ratio, win rate, number of instances (FR39)
- Bar chart compares event-based vs. buy-and-hold returns for 3/6/12 month timeframes
- Line chart shows return distribution (best case to worst case) (FR37)
- Table lists individual historical instances with: date, event description, return percentage
- Each historical instance expandable to show event details and price chart
- Prominent disclaimer displayed: "This is historical analysis, not investment advice" (FR38)
- Results page accessible via notification click (from Epic 4)
- Page loads within 1 second (NFR-P11)
- Charts responsive and readable on mobile (responsive design requirement)

**Database changes:**
- None (reads from `backtest_results` table)

**Files affected:**
- `/stockelper-fe/src/app/(has-layout)/backtesting/[jobId]/page.tsx` (new page)
- `/stockelper-fe/src/components/backtesting/results-chart.tsx` (new component)
- `/stockelper-fe/src/components/backtesting/instance-table.tsx` (new component)
- `/stockelper-fe/src/app/api/backtesting/results/[jobId]/route.ts` (new endpoint)

---

#### Story 3.6: Backtesting Request via Chat Interface with Parameter Extraction

**As a** user
**I want** to request backtesting through the chat interface with intelligent parameter handling
**So that** I can validate strategies conversationally and view results on dedicated page

**Acceptance Criteria:**

**Given** a user is chatting about a stock or strategy
**When** the user requests backtesting (e.g., "Backtest this strategy for Samsung")
**Then** the following conditions are met:

**Parameter Extraction & Human-in-the-Loop (FR29a, FR29b):**
- Chat interface recognizes backtesting intent via natural language (FR29, FR30, FR52)
- LLM (gpt-5.1) extracts universe and strategy from user input
- If parameters clear: LLM proceeds directly to submission
- If parameters unclear: LLM asks follow-up questions (FR29b)
  - Example: "Which stocks would you like to include in the backtest?"
  - Example: "Which strategy: event-driven, sentiment-based, or pattern-matching?"
- User responds to clarifying questions, LLM extracts complete parameters

**Backtesting Submission:**
- System confirms request with summary: "Backtesting [strategy] for [stocks] over 3/6/12 months"
- User can confirm or cancel before submission
- Upon confirmation, backtest job sent to backtesting container (FR30a, FR30b)
- Chat displays message: "Backtesting in progress. Navigate to [Backtesting Results Page] to check status." (FR29c)
- Job ID returned and displayed as clickable link to backtesting results page (NOT chat results)
- User can navigate away without losing results (async design requirement)

**Notification & Results (FR31a, FR31c):**
- Notification delivered to frontend when job completes (FR31a)
- User views results on dedicated backtesting results page (FR31c)
- Results NOT displayed in chat interface
- Rate limiting enforced: maximum 5 backtest requests per user per day (FR100)
- Rate limit exceeded shows message: "You've reached your daily backtest limit. Try again tomorrow."

**Database changes:**
- None (uses existing `backtest_jobs` table and notifications table from Story 3.1)

**Files affected:**
- `/stockelper-fe/src/components/chat/chat-window.tsx` (backtesting intent recognition, parameter extraction UI)
- `/stockelper-fe/src/app/api/backtesting/submit/route.ts` (new endpoint, sends to backtesting container)
- `/stockelper-llm/src/multi_agent/supervisor_agent/tools.py` (add BacktestTool with parameter extraction)
- `/stockelper-llm/src/agents/backtesting_agent.py` (human-in-the-loop clarification logic)

---

### Epic 4: Event Alerts & Real-Time Notification System (Supabase Realtime)

Users receive proactive alerts when similar events occur for their portfolio stocks, delivered via Supabase Realtime with Confluence-style browser notifications.

**FRs covered:** FR40-FR47, FR104-FR108

**Implementation Notes:**
- Real-time event monitoring service (Neo4j pattern matching)
- Airflow monitoring DAG (every 5 minutes)
- **Supabase Realtime** for real-time notifications (NO custom notification service backend)
- Database-driven notifications: Backend writes to PostgreSQL, Supabase Realtime detects changes, frontend updates automatically
- Frontend GNB notification icon with badge (Supabase Realtime subscription, no polling)
- Frontend notification center dropdown (real-time updates)
- Confluence-style browser notifications (accumulating, non-intrusive)
- Three notification types: portfolio_recommendation, backtesting_complete, event_alert

#### Story 4.1: Real-Time Event Monitoring Service (Neo4j Pattern Matching)

**As a** user
**I want** the system to monitor for new events matching patterns relevant to my portfolio
**So that** I'm alerted when similar events occur for my stocks

**Acceptance Criteria:**

**Given** new events extracted and stored in Neo4j knowledge graph
**When** the event monitoring service executes
**Then** the following conditions are met:
- Service queries Neo4j for events created in last 5 minutes
- For each new event, service identifies stocks in user portfolios matching event's stock ticker
- Service retrieves historical pattern matches for the event (similar events under similar conditions) (FR40, FR41)
- Pattern matching uses same logic as prediction engine (FR13, FR17)
- Service creates alert records for users with matching portfolio stocks
- Alert includes: stock ticker, event description, event category, confidence level, historical examples (FR43, FR44)
- Action recommendation included: hold/buy/sell consideration (FR46)
- Service handles up to 10,000 simultaneous notifications (NFR-SC8)
- Processing completes within 5 minutes of event detection (NFR-P6)
- Failed pattern matching logged (does not block alert creation)

**Database changes:**
- PostgreSQL: Create `event_alerts` table with columns: id, user_id (FK), stock_ticker, event_id (Neo4j event ID), alert_type (enum: similar_event), confidence_level (decimal), event_description (text), action_recommendation (enum), created_at, read_at

**Files affected:**
- `/stockelper-llm/src/alerts/event_monitor.py` (new module)
- `/stockelper-llm/src/alerts/pattern_matcher.py` (new module)
- Database migration script for `event_alerts` table

---

#### Story 4.2: Airflow Event Alert Monitoring DAG

**As a** system administrator
**I want** event monitoring to run automatically every 5 minutes
**So that** users receive timely alerts without manual intervention

**Acceptance Criteria:**

**Given** the event monitoring service implemented (Story 4.1)
**When** the Airflow DAG executes
**Then** the following conditions are met:
- DAG triggers every 5 minutes during market hours (9:00 AM - 3:30 PM KST)
- DAG triggers every 30 minutes during non-market hours
- DAG calls event monitoring service to check for new events
- DAG processes alerts for all users with non-empty portfolios
- Generated alerts written to `event_alerts` table
- Notifications created in `notifications` table for unread alerts
- Alert spam prevention: maximum 5 alerts per user per hour (FR103)
- Exceeding limit batches alerts into single notification: "You have 5+ new alerts"
- DAG execution logs viewable in Airflow UI
- Failed executions retry up to 3 times (NFR-R8)

**Database changes:**
- None (uses tables from Story 4.1 and Story 4.3)

**Files affected:**
- `/stockelper-airflow/dags/event_alert_monitoring_dag.py` (new DAG)

---

#### Story 4.3: Notification Database Schema with Supabase Realtime

**As a** developer
**I want** a PostgreSQL notifications table with Supabase Realtime enabled
**So that** all notification types (portfolio recommendations, backtesting complete, event alerts) trigger real-time frontend updates

**Acceptance Criteria:**

**Given** various system components generating notifications
**When** a notification is created
**Then** the following conditions are met:

**Database & Supabase Realtime (FR104, FR107):**
- Notifications stored in PostgreSQL `notifications` table on AWS t3.medium
- Table supports three notification types: portfolio_recommendation, backtesting_complete, event_alert
- Each notification includes: user_id, type, title, message, link (URL to relevant page), created_at, read_at
- Supabase Realtime enabled on `notifications` table (FR104)
- Frontend subscribes to table changes filtered by user_id (FR107)
- New notification inserts automatically push to frontend via Supabase Realtime (no polling)
- Update to read_at triggers real-time UI update (badge count decreases)

**API Endpoints:**
- API endpoint `/api/notifications` returns unread notifications for authenticated user
- API endpoint `/api/notifications/mark-read` marks notifications as read (triggers Supabase Realtime update)
- API endpoint `/api/notifications/count` returns unread count for initial page load
- Notifications sorted by created_at descending (newest first)
- Read notifications retained for 30 days before cleanup
- Unread notifications retained indefinitely until user reads them
- API responses complete within 500ms (NFR-P2)

**Database changes:**
- PostgreSQL on AWS t3.medium: Create `notifications` table with columns: id (UUID), user_id (FK), type (ENUM: portfolio_recommendation, backtesting_complete, event_alert), title (VARCHAR), message (TEXT), link (VARCHAR), created_at (TIMESTAMP), read_at (TIMESTAMP nullable)
- Index on (user_id, read_at) for fast unread queries
- Index on created_at for cleanup operations
- **Enable Supabase Realtime on `notifications` table**

**Files affected:**
- `/stockelper-llm/src/api/notifications.py` (API endpoints, writes to PostgreSQL trigger Supabase)
- `/stockelper-fe/src/app/api/notifications/route.ts` (proxy to backend)
- Database migration script for `notifications` table with Supabase Realtime
- Supabase configuration for real-time subscriptions

---

#### Story 4.4: Frontend GNB Notification Icon with Real-Time Badge (Supabase Realtime)

**As a** user
**I want** to see a notification icon in the global navigation bar with real-time updates
**So that** I know immediately when I have new alerts or recommendations

**Acceptance Criteria:**

**Given** the user is authenticated and viewing any page
**When** a new notification is created or marked as read
**Then** the following conditions are met:

**Real-Time Updates (FR104, FR105-FR108):**
- GNB displays notification bell icon in top-right corner
- Icon shows badge with unread count when count > 0
- Badge displays number up to 9 (shows "9+" for 10 or more)
- Frontend subscribes to Supabase Realtime `notifications` table filtered by user_id (FR104)
- Badge updates **instantly** when new notification inserted (NO 30-second delay) (FR107)
- Badge updates **instantly** when notification marked as read (FR107)
- No polling required - Supabase Realtime pushes updates automatically

**Browser Notifications (FR105, FR106, FR108):**
- Browser notification delivered when new notification created (FR105, FR106)
- Confluence-style notifications: accumulating, non-intrusive (FR108)
- Notification titles: "Backtesting completed", "Portfolio recommendation ready", "Event alert for Samsung"
- Clicking browser notification navigates to relevant page and marks notification as read

**UI Behavior:**
- Clicking notification icon opens notification center dropdown (Story 4.5)
- Icon color changes when unread notifications present (e.g., blue vs. gray)
- Subscription stops when user logs out or navigates away
- Visual design follows UX calm design principles (not distracting)

**Database changes:**
- None (reads from `notifications` table via Supabase Realtime)

**Files affected:**
- `/stockelper-fe/src/components/layout/global-nav.tsx` (add notification icon)
- `/stockelper-fe/src/components/notifications/notification-icon.tsx` (new component with Supabase Realtime)
- `/stockelper-fe/src/hooks/useSupabaseRealtimeSubscription.ts` (shared Supabase Realtime hook)
- `/stockelper-fe/src/hooks/useBrowserNotifications.ts` (new hook for Confluence-style notifications)

---

#### Story 4.5: Notification Center Dropdown

**As a** user
**I want** to view all my notifications in a dropdown
**So that** I can see what alerts I've received and navigate to details

**Acceptance Criteria:**

**Given** a user clicks the notification icon in GNB
**When** the dropdown opens
**Then** the following conditions are met:
- Dropdown displays list of recent notifications (up to 20 most recent)
- Each notification shows: icon (based on type), title, message preview, time ago (e.g., "5 minutes ago")
- Notifications grouped by read/unread status (unread first)
- Clicking notification marks as read and navigates to linked page (FR45)
- "Mark all as read" button at bottom of dropdown
- Empty state message: "No new notifications" when no unread items
- Dropdown supports Korean language (NFR-U1)
- Dropdown loads within 500ms of icon click (NFR-P2)
- Dropdown closes when clicking outside or pressing Escape key
- "View all notifications" link at bottom navigates to full notifications page

**Database changes:**
- None (reads from `notifications` table via API)

**Files affected:**
- `/stockelper-fe/src/components/notifications/notification-dropdown.tsx` (new component)
- `/stockelper-fe/src/components/notifications/notification-item.tsx` (new component)
- `/stockelper-fe/src/app/(has-layout)/notifications/page.tsx` (full notifications page)

---

#### Story 4.6: Event Alert Preferences Configuration

**As a** user
**I want** to configure my alert preferences
**So that** I only receive alerts that are relevant to my investment strategy

**Acceptance Criteria:**

**Given** an authenticated user accesses the settings/alerts page
**When** the user configures preferences
**Then** the following conditions are met:
- Settings page displays alert preferences form (FR47)
- User can toggle alerts on/off for each portfolio stock individually
- User can set confidence threshold (e.g., only alert when confidence > 70%)
- User can select event categories to monitor (e.g., only "earnings" and "product launches")
- Preferences saved to PostgreSQL `user_alert_preferences` table
- Event monitoring service (Story 4.1) respects user preferences when creating alerts
- Default preferences: all alerts enabled, 50% confidence threshold, all categories
- Preferences update immediately (no page refresh required)
- Form validation prevents invalid configurations (e.g., threshold must be 0-100%)
- Changes autosave after 2-second debounce (UX smooth experience)

**Database changes:**
- PostgreSQL: Create `user_alert_preferences` table with columns: id, user_id (FK), stock_ticker (varchar), alerts_enabled (boolean), confidence_threshold (decimal), event_categories (JSON array), updated_at
- Unique constraint on (user_id, stock_ticker)

**Files affected:**
- `/stockelper-fe/src/app/(has-layout)/settings/alerts/page.tsx` (new settings page)
- `/stockelper-fe/src/app/api/user/alert-preferences/route.ts` (CRUD endpoints)
- `/stockelper-llm/src/api/alert_preferences.py` (new endpoints)
- `/stockelper-llm/src/alerts/event_monitor.py` (update to respect preferences)
- Database migration script for `user_alert_preferences` table

---

### Epic 5: Compliance, Rate Limiting & Audit Trail

System operates with full regulatory compliance, rate limiting, and comprehensive audit trail.

**FRs covered:** FR69-FR80, FR91-FR97, FR98-FR103

**Implementation Notes:**
- Embedded disclaimers in all prediction/recommendation outputs
- Prediction audit logging (PostgreSQL with 12-month retention)
- Rate limiting middleware (predictions, recommendations, backtesting, chat)
- Frontend legal pages (Terms of Service, Privacy Policy)
- Complete event extraction automation DAG

#### Story 5.1: Embedded Disclaimers in Predictions and Recommendations

**As a** user
**I want** to see clear disclaimers with all predictions and recommendations
**So that** I understand the informational nature of the platform and make my own investment decisions

**Acceptance Criteria:**

**Given** the system generates predictions or recommendations
**When** the output is displayed to the user
**Then** the following conditions are met:
- All prediction outputs include disclaimer: "This prediction is for informational purposes only and does not constitute investment advice. Past performance does not guarantee future results." (FR69)
- All recommendation outputs include disclaimer: "This recommendation is based on historical patterns and does not constitute financial advice. Please conduct your own research before investing." (FR70)
- Disclaimers prominently displayed (not hidden in fine print)
- Disclaimers support Korean language (NFR-U1)
- Backtesting results include disclaimer: "This is historical analysis. Actual results may vary significantly." (FR38)
- Chat responses with predictions/recommendations automatically append disclaimer
- Frontend displays disclaimers with visual emphasis (e.g., border, background color)
- Users can view full Terms of Service via link in disclaimer (FR79, FR80)

**Database changes:**
- None (display-only feature)

**Files affected:**
- `/stockelper-fe/src/components/chat/prediction-card.tsx` (add disclaimer)
- `/stockelper-fe/src/components/recommendations/recommendation-card.tsx` (add disclaimer)
- `/stockelper-fe/src/components/backtesting/results-chart.tsx` (add disclaimer)
- `/stockelper-fe/src/components/common/disclaimer.tsx` (new reusable component)

---

#### Story 5.2: Prediction Audit Logging (PostgreSQL with 12-Month Retention)

**As a** system administrator
**I want** comprehensive audit logging for all predictions and recommendations
**So that** we can provide accountability and analyze system behavior

**Acceptance Criteria:**

**Given** the system generates predictions, recommendations, or backtesting results
**When** the output is delivered to the user
**Then** the following conditions are met:
- Prediction generation logged to PostgreSQL `prediction_audit_log` table (FR71)
- Log includes: timestamp, user_id, stock_ticker, prediction_type, output_summary, confidence_level (FR71)
- Log includes: historical event patterns used (event IDs from Neo4j) (FR72)
- Log includes: knowledge graph state snapshot (ontology version, event count) (FR73)
- Portfolio recommendations logged to `portfolio_recommendations_log` table (already created in Epic 2) (FR74)
- Backtesting executions logged to `backtest_jobs` table (already created in Epic 3) (FR75)
- Event alerts logged to `event_alerts` table (already created in Epic 4) (FR76)
- Logs retained for minimum 12 months (FR77)
- Automated cleanup job removes logs older than 12 months (runs monthly)
- Logs provide complete audit trail for accountability (FR78)
- Logs queryable for analysis and debugging

**Database changes:**
- PostgreSQL: Create `prediction_audit_log` table with columns: id, user_id (FK), stock_ticker, prediction_type (enum: short_term, medium_term, long_term), output_summary (text), confidence_level (decimal), historical_events_used (JSON array), kg_snapshot (JSON), ontology_version (varchar), created_at
- Index on (user_id, created_at) for user history queries
- Index on created_at for cleanup operations

**Files affected:**
- `/stockelper-llm/src/api/audit_logger.py` (new module)
- `/stockelper-llm/src/multi_agent/technical_analysis_agent/agent.py` (integrate logging)
- `/stockelper-llm/src/multi_agent/portfolio_analysis_agent/agent.py` (integrate logging)
- `/stockelper-airflow/dags/audit_log_cleanup_dag.py` (new monthly DAG)
- Database migration script for `prediction_audit_log` table

---

#### Story 5.3: Rate Limiting Middleware

**As a** system administrator
**I want** rate limiting on all API endpoints
**So that** we prevent system abuse and ensure fair usage

**Acceptance Criteria:**

**Given** users making requests to the system
**When** the requests are processed
**Then** the following conditions are met:
- Prediction query requests rate limited to 100 per user per day (FR98)
- Portfolio recommendation requests rate limited to 10 per user per day (FR99)
- Backtesting execution requests rate limited to 5 per user per day (FR100)
- Chat message requests rate limited to 200 per user per hour (prevents spam)
- Rate limits enforced via middleware at API gateway level
- Rate limit state stored in-process (single-instance deployment assumption; no Redis container)
- Exceeding limit returns HTTP 429 (Too Many Requests) with clear message (NFR-U2)
- Error message includes: limit type, current count, reset time
- Rate limits reset at midnight KST daily (or hourly for chat)
- System monitors for anomalous usage patterns (FR102)
- Admin dashboard displays rate limit violations and usage trends
- Rate limits configurable via environment variables (no code changes required)

**Database changes:**
- None (in-process counters; no external store)

**Files affected:**
- `/stockelper-llm/src/middleware/rate_limiter.py` (new middleware)
- `/stockelper-fe/src/app/api/middleware.ts` (frontend rate limit handling)
- Infrastructure configuration (API gateway / reverse proxy rate-limit settings)

---

#### Story 5.4: Frontend Legal Pages (Terms of Service, Privacy Policy)

**As a** user
**I want** to access Terms of Service and Privacy Policy
**So that** I understand my rights and the platform's policies

**Acceptance Criteria:**

**Given** a user accesses legal pages
**When** the user views the content
**Then** the following conditions are met:
- Terms of Service page accessible at `/legal/terms` (FR80)
- Privacy Policy page accessible at `/legal/privacy` (FR80)
- Terms of Service includes: disclaimer of liability, informational nature of predictions, user responsibility for investment decisions
- Privacy Policy includes: data collection practices, data encryption (NFR-S1, NFR-S2), data retention (NFR-S15), third-party integrations (KIS API, OpenAI)
- Both pages support Korean language (NFR-U1)
- Footer links to legal pages on all pages
- Legal pages accessible without authentication (public pages)
- Content formatted for readability (headings, bullet points, sections)
- "Last updated" date displayed at top of each page
- Users can download policies as PDF (optional, nice-to-have)

**Database changes:**
- None (static content pages)

**Files affected:**
- `/stockelper-fe/src/app/legal/terms/page.tsx` (new page)
- `/stockelper-fe/src/app/legal/privacy/page.tsx` (new page)
- `/stockelper-fe/src/components/layout/footer.tsx` (add legal links)
- `/docs/legal/terms-of-service.md` (content source)
- `/docs/legal/privacy-policy.md` (content source)

---

#### Story 5.5: Complete Event Extraction Automation DAG (Dual Pipeline)

**As a** system administrator
**I want** fully automated event extraction from both DART and News sources
**So that** the knowledge graph stays up-to-date without manual intervention

**Acceptance Criteria:**

**Given** the system orchestrates data pipeline via Airflow
**When** the DAGs execute
**Then** the following conditions are met:
- **DART Pipeline DAG** (FR91-FR97):
  - Triggers once daily at 7:00 PM KST (after market close)
  - Scrapes DART disclosures for AI-sector stocks (MVP pilot scope)
  - Extracts events from DART disclosures using event extraction service
  - Updates Neo4j knowledge graph with new events (FR94)
  - Triggers prediction engine when knowledge graph updated (FR95)
  - Monitors event alert system for similar events (FR96)
  - Logs execution status and errors
- **News Pipeline DAG** (already created in Epic 1 Story 1.1):
  - Triggers every 2-3 hours for AI-sector stocks
  - Scrapes Naver Finance news articles
  - Extracts events from news articles
  - Updates Neo4j knowledge graph
- Both pipelines execute on defined schedule (FR97)
- DAG dependencies configured (news crawler → event extraction → KG update → prediction engine → alerts)
- Failed tasks retry up to 3 times (NFR-R8)
- DAG execution logs viewable in Airflow UI for monitoring
- External API failures handled gracefully (NFR-R9)

**Database changes:**
- None (uses existing MongoDB, Neo4j, PostgreSQL tables)

**Files affected:**
- `/stockelper-airflow/dags/dart_event_extraction_dag.py` (new DAG)
- `/stockelper-airflow/dags/news_event_extraction_dag.py` (already created in Epic 1)
- `/stockelper-airflow/dags/master_orchestration_dag.py` (optional: coordinates both pipelines)

**Implementation Notes:**
- **Airflow Pattern Source:** Reference Epic 1 Story 1.1 (News Crawler Airflow DAG) for DAG implementation patterns
- DART Pipeline DAG (new in this story) follows same structure as News Pipeline DAG from Epic 1.1
- Reuse error handling (retry 3 times - NFR-R8), logging, and scheduling patterns from Epic 1.1
- Both DAGs follow consistent pattern: scrape → extract events → update Neo4j → trigger downstream

