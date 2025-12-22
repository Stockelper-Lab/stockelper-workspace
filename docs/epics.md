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

### Epic 0: LangChain v1 Migration & Model Upgrade (Phase 0 Prerequisite)

Development team modernizes AI infrastructure to LangChain v1 patterns and gpt-4.1 model. This is a CRITICAL prerequisite that must be completed before implementing new features.

**FRs covered:** Enables FR9-FR18 (Predictions), FR48-FR56 (Chat Interface)

**Implementation Notes:**
- Update namespace imports (add `langchain-classic`)
- Migrate agent creation from `langgraph.prebuilt.create_react_agent` to `langchain.agents.create_agent`
- Adopt `content_blocks` message handling
- Upgrade all models from gpt-4o/gpt-4o-mini to gpt-4.1
- Refactor all 6 agents + portfolio multi-agent system
- No database schema changes required

#### Story 0.1: Update LangChain Dependencies and Core Imports

**As a** developer
**I want** to update package dependencies and import statements to LangChain v1 patterns
**So that** the codebase is ready for LangChain v1 agent migration

**Acceptance Criteria:**

**Given** the existing stockelper-llm service with LangChain v0.x dependencies
**When** I update the requirements.txt file and import statements
**Then** the following conditions are met:
- `requirements.txt` includes `langchain-classic` package for legacy feature support
- `requirements.txt` updates `langchain` and `langgraph` to v1.0+ versions
- `requirements.txt` updates `langchain-openai` to v1.0+ compatible version
- All agent files update namespace imports (e.g., `from langchain.agents import create_agent` instead of `from langgraph.prebuilt import create_react_agent`)
- `pip install -r requirements.txt` succeeds without dependency conflicts
- No runtime import errors occur when importing updated modules

**Files affected:**
- `/stockelper-llm/requirements.txt`
- `/stockelper-llm/src/multi_agent/*/agent.py` (import statements only)

**Testing:**
- Unit tests pass for all agent import modules
- Dependency installation completes without conflicts
- `python -c "from langchain.agents import create_agent"` executes successfully
- No deprecation warnings appear when importing updated modules

---

#### Story 0.2: Migrate SupervisorAgent to LangChain v1

**As a** developer
**I want** to migrate SupervisorAgent to LangChain v1 agent creation pattern
**So that** task routing works with the new framework and gpt-4.1 model

**Acceptance Criteria:**

**Given** SupervisorAgent currently using `create_react_agent` from langgraph.prebuilt
**When** I refactor the agent creation logic
**Then** the following conditions are met:
- Agent initialization uses `langchain.agents.create_agent()` instead of `langgraph.prebuilt.create_react_agent()`
- Model parameter specifies `"gpt-4.1"` instead of `"gpt-4o"` or `"gpt-4o-mini"`
- Message handling adopts `content_blocks` property for structured content
- Tool definitions remain compatible with v1 agent pattern
- SupervisorAgent successfully routes tasks to other agents in test scenarios
- Response format maintains backward compatibility with existing chat interface
- Agent responds within 2 seconds for typical routing decisions (NFR-P1)

**Files affected:**
- `/stockelper-llm/src/multi_agent/supervisor_agent/agent.py`
- `/stockelper-llm/src/multi_agent/supervisor_agent/tools.py` (if tool signatures need updates)

**Testing:**
- Integration test passes showing SupervisorAgent successfully routes to TechnicalAnalysisAgent, PortfolioAnalysisAgent, and MarketAnalysisAgent based on query type
- Test verifies `content_blocks` message handling works correctly
- Performance test confirms routing decisions complete within 2 seconds (NFR-P1)
- Regression test confirms chat interface compatibility maintained

---

#### Story 0.3: Migrate MarketAnalysisAgent to LangChain v1

**As a** developer
**I want** to migrate MarketAnalysisAgent to LangChain v1 agent creation pattern
**So that** market analysis (news search, sentiment analysis) works with the new framework and gpt-4.1 model

**Acceptance Criteria:**

**Given** MarketAnalysisAgent currently using `create_react_agent` with tools like SearchNewsTool and ReportSentimentAnalysisTool
**When** I refactor the agent creation logic
**Then** the following conditions are met:
- Agent initialization uses `langchain.agents.create_agent()` with `model="gpt-4.1"`
- Message handling adopts `content_blocks` property
- SearchNewsTool integration remains functional
- ReportSentimentAnalysisTool integration remains functional (sentiment analysis already implemented)
- Agent successfully analyzes market conditions for test stock queries
- Response includes structured sentiment analysis results
- Agent responds within 2 seconds for typical market analysis queries (NFR-P1)

**Files affected:**
- `/stockelper-llm/src/multi_agent/market_analysis_agent/agent.py`
- `/stockelper-llm/src/multi_agent/market_analysis_agent/tools/` (if tool signatures need updates)

**Testing:**
- Integration test passes with SearchNewsTool and ReportSentimentAnalysisTool executing successfully
- Test verifies sentiment analysis results are structured correctly
- Performance test confirms market analysis completes within 2 seconds (NFR-P1)
- Test validates gpt-4.1 model is being used

---

#### Story 0.4: Migrate FundamentalAnalysisAgent to LangChain v1

**As a** developer
**I want** to migrate FundamentalAnalysisAgent to LangChain v1 agent creation pattern
**So that** fundamental analysis capabilities work with the new framework and gpt-4.1 model

**Acceptance Criteria:**

**Given** FundamentalAnalysisAgent currently using `create_react_agent`
**When** I refactor the agent creation logic
**Then** the following conditions are met:
- Agent initialization uses `langchain.agents.create_agent()` with `model="gpt-4.1"`
- Message handling adopts `content_blocks` property
- All fundamental analysis tools remain functional
- Agent successfully performs fundamental analysis for test stock queries
- Response format maintains compatibility with supervisor routing
- Agent responds within 2 seconds for typical fundamental analysis queries (NFR-P1)

**Files affected:**
- `/stockelper-llm/src/multi_agent/fundamental_analysis_agent/agent.py`
- `/stockelper-llm/src/multi_agent/fundamental_analysis_agent/tools/` (if tool signatures need updates)

**Testing:**
- Integration test passes showing fundamental analysis tools execute successfully
- Test verifies response format is compatible with SupervisorAgent routing
- Performance test confirms analysis completes within 2 seconds (NFR-P1)
- Test validates agent uses gpt-4.1 model

---

#### Story 0.5: Migrate TechnicalAnalysisAgent to LangChain v1

**As a** developer
**I want** to migrate TechnicalAnalysisAgent to LangChain v1 agent creation pattern
**So that** technical analysis (Prophet + ARIMA predictions) works with the new framework and gpt-4.1 model

**Acceptance Criteria:**

**Given** TechnicalAnalysisAgent currently using `create_react_agent` with StockTool (Prophet + ARIMA)
**When** I refactor the agent creation logic
**Then** the following conditions are met:
- Agent initialization uses `langchain.agents.create_agent()` with `model="gpt-4.1"`
- Message handling adopts `content_blocks` property
- StockTool integration remains functional (Prophet + ARIMA predictions)
- Agent successfully generates short-term, medium-term, and long-term predictions (FR9-FR11)
- Prediction confidence levels calculated correctly (FR12)
- Agent responds within 2 seconds for typical prediction queries (NFR-P1)

**Files affected:**
- `/stockelper-llm/src/multi_agent/technical_analysis_agent/agent.py`
- `/stockelper-llm/src/multi_agent/technical_analysis_agent/tools/stock.py` (if needed)

**Testing:**
- Integration test passes showing Prophet + ARIMA predictions generate for short/medium/long-term timeframes (FR9-FR11)
- Test verifies confidence levels are calculated and included in response (FR12)
- Performance test confirms predictions complete within 2 seconds (NFR-P1)
- Test validates TechnicalAnalysisAgent uses gpt-4.1 model

---

#### Story 0.6: Migrate PortfolioAnalysisAgent to LangChain v1

**As a** developer
**I want** to migrate PortfolioAnalysisAgent to LangChain v1 agent creation pattern
**So that** portfolio analysis capabilities work with the new framework and gpt-4.1 model

**Acceptance Criteria:**

**Given** PortfolioAnalysisAgent currently using `create_react_agent`
**When** I refactor the agent creation logic
**Then** the following conditions are met:
- Agent initialization uses `langchain.agents.create_agent()` with `model="gpt-4.1"`
- Message handling adopts `content_blocks` property
- All portfolio analysis tools remain functional
- Agent successfully analyzes test portfolios
- Agent provides event-based rationale for portfolio recommendations (FR21)
- Response format maintains compatibility with supervisor routing
- Agent responds within 5 seconds for portfolio recommendation generation (NFR-P3)

**Files affected:**
- `/stockelper-llm/src/multi_agent/portfolio_analysis_agent/agent.py`
- `/stockelper-llm/src/multi_agent/portfolio_analysis_agent/tools/` (if tool signatures need updates)

**Testing:**
- Integration test passes showing portfolio analysis with event-based rationale (FR21)
- Test verifies all portfolio analysis tools function correctly
- Performance test confirms recommendations complete within 5 seconds (NFR-P3)
- Test validates PortfolioAnalysisAgent uses gpt-4.1 model

---

#### Story 0.7: Migrate InvestmentStrategyAgent to LangChain v1

**As a** developer
**I want** to migrate InvestmentStrategyAgent to LangChain v1 agent creation pattern
**So that** investment strategy recommendations work with the new framework and gpt-4.1 model

**Acceptance Criteria:**

**Given** InvestmentStrategyAgent currently using `create_react_agent`
**When** I refactor the agent creation logic
**Then** the following conditions are met:
- Agent initialization uses `langchain.agents.create_agent()` with `model="gpt-4.1"`
- Message handling adopts `content_blocks` property
- All investment strategy tools remain functional
- Agent successfully generates investment strategies for test scenarios
- Response format maintains compatibility with supervisor routing
- Agent responds within 2 seconds for typical strategy queries (NFR-P1)

**Files affected:**
- `/stockelper-llm/src/multi_agent/investment_strategy_agent/agent.py`
- `/stockelper-llm/src/multi_agent/investment_strategy_agent/tools/` (if tool signatures need updates)

**Testing:**
- Integration test passes showing investment strategy generation for test scenarios
- Test verifies all investment strategy tools function correctly
- Performance test confirms strategy generation completes within 2 seconds (NFR-P1)
- Test validates InvestmentStrategyAgent uses gpt-4.1 model

---

#### Story 0.8: Migrate Event Extraction Service to gpt-4.1

**As a** developer
**I want** to update event extraction service to use gpt-4.1 model
**So that** event classification quality improves with the latest model

**Acceptance Criteria:**

**Given** stockelper-kg event extraction currently using `"gpt-4o"` model
**When** I update the model configuration
**Then** the following conditions are met:
- `/stockelper-kg/src/stockelper_kg/graph/event.py` specifies `model="gpt-4.1"` for event classification
- Event extraction successfully classifies test news articles
- Event metadata (entities, conditions, categories, dates) captured correctly (FR5)
- Event classification matches defined ontology categories (FR3)
- Extraction pipeline processes minimum 1000 news articles per hour (NFR-P9)
- No breaking changes to Neo4j graph schema

**Files affected:**
- `/stockelper-kg/src/stockelper_kg/graph/event.py`
- `/stockelper-kg/requirements.txt` (if LangChain version updates needed)

**Testing:**
- Integration test passes showing event extraction classifies test articles correctly
- Test verifies event metadata (entities, conditions, categories, dates) captured per FR5
- Test validates event classification matches ontology categories (FR3)
- Performance test confirms pipeline processes minimum 1000 articles/hour (NFR-P9)
- Test validates event extraction uses gpt-4.1 model

---

#### Story 0.9: Portfolio Multi-Agent System Integration Testing

**As a** developer
**I want** to test the complete multi-agent system after LangChain v1 migration
**So that** all agents work together correctly and meet performance requirements

**Acceptance Criteria:**

**Given** all 6 agents migrated to LangChain v1
**When** I execute integration test scenarios
**Then** the following conditions are met:
- SupervisorAgent correctly routes tasks to specialized agents
- Multi-turn chat conversations maintain context within session (session-scoped memory only)
- Chat message responses complete within 500ms for non-prediction queries (NFR-P2)
- Prediction queries complete within 2 seconds (NFR-P1)
- Portfolio recommendations complete within 5 seconds (NFR-P3)
- Agent-to-agent communication works without errors
- Response format compatible with existing chat interface API
- No regression in chat conversation quality (CRITICAL success factor)
- System handles 10 concurrent user queries without degradation (subset of NFR-P7)

**Files affected:**
- `/stockelper-llm/tests/integration/` (new integration tests)
- `/stockelper-llm/src/multi_agent/` (any coordination logic fixes)

**Testing:**
- Integration test suite passes showing SupervisorAgent correctly routes to all specialized agents
- Multi-turn chat conversations maintain session-scoped context
- Performance benchmarks confirm NFR-P1 (predictions <2s), NFR-P2 (chat <500ms), NFR-P3 (recommendations <5s)
- No regression in chat conversation quality (CRITICAL success factor validated)
- System handles 10 concurrent queries without degradation

---

### Epic 1: Event Intelligence Automation & Visualization

Users see rich visualizations of event patterns and historical matches; system automatically processes news into events.

**FRs covered:** FR1-FR8 (automation gaps), FR9-FR18 (visualization gaps), FR48-FR56 (UI enhancements)

**Implementation Notes:**
- Automated Airflow DAG for event extraction (currently manual CLI)
- Frontend event timeline visualization
- Multi-timeframe prediction UI with confidence indicators
- Rich chat prediction cards
- Suggested queries based on portfolio

#### Story 1.1: Automate Event Extraction with Airflow DAG

**As a** user
**I want** the system to automatically extract events from news articles without manual intervention
**So that** I receive timely event-based insights without delays

**Acceptance Criteria:**

**Given** news articles scraped and stored in MongoDB by news crawler
**When** the Airflow DAG executes on schedule
**Then** the following conditions are met:
- Airflow DAG task triggers `stockelper-kg-events` CLI command for each new article
- DAG runs every 2-3 hours for AI-sector stocks (Naver, Kakao, etc.) per MVP pilot scope
- DAG processes all unprocessed articles in MongoDB queue
- Event extraction results stored in Neo4j knowledge graph with date indexing (FR4)
- Event metadata (entities, conditions, categories, dates) captured correctly (FR5)
- Failed extractions retry up to 3 times with exponential backoff (NFR-R8)
- DAG execution logs viewable in Airflow UI
- Pipeline processes minimum 1000 news articles per hour (NFR-P9)
- DAG integrates with existing DART daily pipeline (dual pipeline architecture)

**Database changes:**
- MongoDB: Add `processed` boolean field and `processed_at` timestamp to news_articles collection for deduplication tracking

**Files affected:**
- `/stockelper-airflow/dags/news_event_extraction_dag.py` (new DAG)
- `/stockelper-news-crawler/` (MongoDB schema update)

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

### Epic 2: Portfolio Management UI & Scheduled Recommendations

Users manage portfolios through dedicated UI and receive daily personalized recommendations before market open.

**FRs covered:** FR19-FR28

**Implementation Notes:**
- Frontend portfolio tracking interface (add/remove stocks, view holdings)
- Dedicated portfolio recommendation page (button-triggered)
- Scheduled 9:00 AM daily recommendation DAG (Airflow)
- Notification delivery integration
- Connect chat to existing PortfolioAnalysisAgent backend

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

#### Story 2.4: Dedicated Portfolio Recommendation Page (Button-Triggered)

**As a** user
**I want** a dedicated page where I can request portfolio recommendations
**So that** I can review personalized stock suggestions based on recent events

**Acceptance Criteria:**

**Given** an authenticated user with stocks in their portfolio
**When** the user navigates to the portfolio recommendations page
**Then** the following conditions are met:
- Page displays "Get Recommendations" button prominently
- Clicking button triggers portfolio analysis via existing PortfolioAnalysisAgent (migrated in Epic 0)
- Loading state shows progress indicator with message "Analyzing recent events..." (async UX pattern)
- Recommendations complete within 5 seconds (NFR-P3)
- Results display as cards showing: recommended action (buy/hold/sell consideration), stock name, event rationale (FR21), historical patterns (FR22), confidence level (FR23)
- Each recommendation includes embedded disclaimer (FR70)
- User can add recommended stocks to portfolio directly from results
- Recommendations logged to `portfolio_recommendations_log` table (FR74)
- Page accessible via GNB navigation and notification click (pre-market notification before 9am)
- Empty portfolio shows message: "Add stocks to your portfolio to receive recommendations"

**Database changes:**
- PostgreSQL: Create `portfolio_recommendations_log` table with columns: id, user_id (FK), stock_ticker, recommendation_type (enum: buy/hold/sell), confidence_level (decimal), event_rationale (text), generated_at

**Files affected:**
- `/stockelper-fe/src/app/(has-layout)/recommendations/page.tsx` (new page)
- `/stockelper-fe/src/components/recommendations/recommendation-card.tsx` (new component)
- `/stockelper-fe/src/app/api/recommendations/generate/route.ts` (new endpoint)
- Database migration script for `portfolio_recommendations_log` table

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

Users validate investment strategies through historical backtesting with Sharpe Ratio analysis.

**FRs covered:** FR29-FR39

**Implementation Notes:**
- Complete new implementation (100% new work)
- Event-based strategy simulator
- 3/6/12-month historical return calculation
- Sharpe Ratio calculation and buy-and-hold comparison
- Async job processing (5-10 minutes, PostgreSQL job queue)
- Frontend results visualization with charts
- Notification on completion

#### Story 3.1: Async Backtesting Job Queue Infrastructure

**As a** developer
**I want** to implement asynchronous job processing for backtesting
**So that** users can request long-running backtests without blocking the chat interface

**Acceptance Criteria:**

**Given** a user requests backtesting via chat or UI
**When** the system processes the request
**Then** the following conditions are met:
- PostgreSQL `backtest_jobs` table stores job metadata (user_id, stock_ticker, strategy_type, status, created_at, completed_at)
- Job status tracked as enum: pending, processing, completed, failed
- Background worker process polls `backtest_jobs` table for pending jobs
- Worker updates job status to 'processing' when starting execution
- Backtesting execution completes within 10 seconds for single stock (NFR-P4)
- Job results stored in `backtest_results` table upon completion
- Failed jobs logged with error details and retry count (max 3 retries - NFR-R8)
- Worker implements graceful shutdown (completes current job before stopping)
- Job queue supports concurrent processing (minimum 5 jobs in parallel)

**Database changes:**
- PostgreSQL: Create `backtest_jobs` table with columns: id, user_id (FK), stock_ticker, strategy_type, status (enum), error_message (text), retry_count (int), created_at, started_at, completed_at
- PostgreSQL: Create `backtest_results` table with columns: id, job_id (FK), user_id (FK), stock_ticker, strategy_type, results_json (jsonb), generated_at
- Index on (user_id, status) for fast queue lookups

**Files affected:**
- `/stockelper-llm/src/backtesting/job_queue.py` (new module)
- `/stockelper-llm/src/backtesting/worker.py` (new background worker)
- Database migration scripts for `backtest_jobs` and `backtest_results` tables

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

#### Story 3.6: Backtesting Request via Chat Interface

**As a** user
**I want** to request backtesting through the chat interface
**So that** I can validate strategies conversationally without leaving the chat

**Acceptance Criteria:**

**Given** a user is chatting about a stock or strategy
**When** the user requests backtesting (e.g., "Backtest this strategy for Samsung")
**Then** the following conditions are met:
- Chat interface recognizes backtesting intent via natural language (FR29, FR30, FR52)
- System confirms request with summary: "Backtesting [strategy] for [stock] over 3/6/12 months"
- User can confirm or cancel before submission
- Upon confirmation, backtest job created in `backtest_jobs` table
- Chat displays message: "Backtest submitted! This will take 5-10 minutes. We'll notify you when ready." (async UX pattern)
- Job ID returned and displayed as clickable link to status page
- User can navigate away without losing results (async design requirement)
- Notification delivered when job completes (Epic 4 integration)
- Rate limiting enforced: maximum 5 backtest requests per user per day (FR100)
- Rate limit exceeded shows message: "You've reached your daily backtest limit. Try again tomorrow."

**Database changes:**
- None (uses existing `backtest_jobs` table and rate limiting from Epic 5)

**Files affected:**
- `/stockelper-fe/src/components/chat/chat-window.tsx` (enhance backtesting intent recognition)
- `/stockelper-fe/src/app/api/backtesting/submit/route.ts` (new endpoint)
- `/stockelper-llm/src/multi_agent/supervisor_agent/tools.py` (add BacktestTool)

---

### Epic 4: Event Alerts & Notification System

Users receive proactive alerts when similar events occur for their portfolio stocks.

**FRs covered:** FR40-FR47

**Implementation Notes:**
- Complete new implementation (100% new work)
- Real-time event monitoring service (Neo4j pattern matching)
- Airflow monitoring DAG (every 5 minutes)
- Notification service backend (PostgreSQL notifications table)
- Frontend GNB notification icon with badge (polling pattern)
- Frontend notification center dropdown
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

#### Story 4.3: Notification Service Backend (PostgreSQL Notifications Table)

**As a** developer
**I want** a centralized notification service backend
**So that** all notification types (portfolio recommendations, backtesting complete, event alerts) are managed consistently

**Acceptance Criteria:**

**Given** various system components generating notifications
**When** a notification is created
**Then** the following conditions are met:
- Notifications stored in PostgreSQL `notifications` table
- Table supports three notification types: portfolio_recommendation, backtesting_complete, event_alert
- Each notification includes: user_id, type, title, message, link (URL to relevant page), created_at, read_at
- API endpoint `/api/notifications` returns unread notifications for authenticated user
- API endpoint `/api/notifications/mark-read` marks notifications as read
- API endpoint `/api/notifications/count` returns unread count for badge display
- Notifications sorted by created_at descending (newest first)
- Read notifications retained for 30 days before cleanup
- Unread notifications retained indefinitely until user reads them
- API responses complete within 500ms (NFR-P2)

**Database changes:**
- PostgreSQL: Create `notifications` table with columns: id, user_id (FK), type (enum: portfolio_recommendation, backtesting_complete, event_alert), title (varchar), message (text), link (varchar), created_at, read_at
- Index on (user_id, read_at) for fast unread queries
- Index on created_at for cleanup operations

**Files affected:**
- `/stockelper-llm/src/api/notifications.py` (new API endpoints)
- `/stockelper-fe/src/app/api/notifications/route.ts` (proxy to backend)
- Database migration script for `notifications` table

---

#### Story 4.4: Frontend GNB Notification Icon with Badge (Polling Pattern)

**As a** user
**I want** to see a notification icon in the global navigation bar
**So that** I know when I have new alerts or recommendations

**Acceptance Criteria:**

**Given** the user is authenticated and viewing any page
**When** the frontend polls for notifications
**Then** the following conditions are met:
- GNB displays notification bell icon in top-right corner
- Icon shows badge with unread count when count > 0
- Badge displays number up to 9 (shows "9+" for 10 or more)
- Frontend polls `/api/notifications/count` every 30 seconds (polling pattern, not WebSocket)
- Clicking notification icon opens notification center dropdown (Story 4.5)
- Icon color changes when unread notifications present (e.g., blue vs. gray)
- Polling stops when user logs out or navigates away
- Badge updates within 30 seconds of new notification creation
- Visual design follows UX calm design principles (not distracting)

**Database changes:**
- None (reads from `notifications` table via API)

**Files affected:**
- `/stockelper-fe/src/components/layout/global-nav.tsx` (add notification icon)
- `/stockelper-fe/src/components/notifications/notification-icon.tsx` (new component)
- `/stockelper-fe/src/hooks/useNotifications.ts` (polling hook)

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
- Rate limit state stored in Redis (fast in-memory lookups)
- Exceeding limit returns HTTP 429 (Too Many Requests) with clear message (NFR-U2)
- Error message includes: limit type, current count, reset time
- Rate limits reset at midnight KST daily (or hourly for chat)
- System monitors for anomalous usage patterns (FR102)
- Admin dashboard displays rate limit violations and usage trends
- Rate limits configurable via environment variables (no code changes required)

**Database changes:**
- None (uses Redis for rate limit tracking)

**Files affected:**
- `/stockelper-llm/src/middleware/rate_limiter.py` (new middleware)
- `/stockelper-fe/src/app/api/middleware.ts` (frontend rate limit handling)
- `/stockelper-llm/requirements.txt` (add redis-py dependency)
- Docker Compose configuration (add Redis service)

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

