---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
inputDocuments:
  - 'docs/index.md'
documentCounts:
  briefs: 0
  research: 0
  brainstorming: 0
  projectDocs: 1
workflowType: 'prd'
lastStep: 11
completed: true
project_name: 'Stockelper'
user_name: 'Oldman'
date: '2025-12-08'
completion_date: '2025-12-09'
---

# Product Requirements Document - Stockelper

**Author:** Oldman
**Date:** 2025-12-08

## Executive Summary

Stockelper is evolving from an AI-powered stock analysis platform into an intelligent, event-driven investment assistant for the Korean stock market. This PRD defines new capabilities that transform how users interact with market events, predictions, and portfolio management.

**Current System Capabilities:**
- LangGraph-based multi-agent LLM system with 4 specialized agents (MarketAnalysis, FundamentalAnalysis, TechnicalAnalysis, InvestmentStrategy)
- Neo4j knowledge graph with expanded event ontology (CAPITAL_RAISE, CAPITAL_RETURN, CAPITAL_STRUCTURE_CHANGE, LISTING_STATUS_CHANGE, and more)
- DART data collection: 20 major report types → PostgreSQL with financial metrics extraction
- **[UPDATED 2025-01-06]** Direct use of DART disclosure categories as events with calculated metrics (replaces sentiment-based approach)
- **[POSTPONED 2025-01-06]** News data collection (Naver + Toss crawlers) - to be implemented in future phases
- Real-time data integration (DART API, KIS OpenAPI)
- Automated data pipeline with production DAGs (Apache Airflow)
- Black-Litterman portfolio optimization with 11-factor ranking system
- Async job queue system for backtesting with notification support
- Modern web interface with JWT authentication and Supabase Realtime

**New Capabilities Being Added:**
1. **Event-Driven Prediction Engine:** Extract events from news, add to knowledge graph with date context, analyze stock fluctuations per subgraph, and predict future movements when similar events occur under similar conditions
2. **Intelligent Portfolio Recommendations:** Personalized recommendations based on user investment profiles, delivered at optimal daily times
3. **Automated Event-Based Backtesting:** Automatic backtesting triggered by user holdings, providing historical performance context
4. **Orchestrated User Scenarios:** Time-aware feature delivery ensuring recommendations and backtesting occur at appropriate moments in the user's workflow

**Problem Being Solved:**
The current system provides powerful analysis tools but requires users to manually interpret news and make investment decisions. Users lack:
- Pattern-based predictions that learn from historical event responses
- Personalized, timely portfolio guidance
- Automatic validation of strategies against their actual holdings
- Contextual delivery of insights at the right moments

**Target Users:**
Korean retail investors who want intelligent, proactive investment assistance rather than just analysis tools.

### What Makes This Special

**Event Pattern Intelligence:**
Unlike traditional stock analysis that treats each event as isolated, this system learns from historical patterns. When similar events occur under similar conditions (per subgraph), the system predicts future stock movements by matching against past behaviors. This transforms reactive analysis into proactive prediction.

**Contextual Timing & Automation:**
The system doesn't just provide features—it orchestrates them intelligently:
- Portfolio recommendations arrive at specific daily times when users need them
- Backtesting automatically triggers based on user holdings, not manual setup
- Airflow DAG and chat system built around event-driven core functionality
- Each feature operates with appropriate timing scenarios

**Seamless Integration:**
New capabilities integrate naturally with existing architecture:
- Event extraction feeds knowledge graph (already established)
- LLM agents leverage event patterns for predictions (building on LangGraph)
- User scenarios orchestrated through existing Airflow infrastructure
- Chat interface provides conversational access to all features

**The "Finally!" Moment:**
When users realize the system not only predicts based on similar past events, but automatically provides portfolio recommendations daily and backtests their holdings without manual configuration—moving from "tool I use" to "intelligent assistant that anticipates my needs."

## ⏸️ POSTPONED Features (2025-01-06 Meeting)

The following features have been postponed based on architectural decisions made in the **2025-01-06 meeting** (see `docs/references/20250106.md`):

**News-Based Event Extraction:**
- Dual news crawlers (Naver + Toss): FR1, FR1a-FR1f
- LLM-based event extraction from news: FR2a (news portion)
- Sentiment scoring from news articles: All sentiment references in FR1-FR2
- MongoDB storage for news: Collections `naver_stock_news` and `toss_stock_news` postponed

**Rationale:**
System will initially use DART disclosure categories directly as events with calculated financial metrics (see FR2i-FR2z). This provides more quantitative, reliable data for backtesting. News-based extraction will be implemented in future phases when the metrics-based approach is validated.

**Future Scope:**
- News crawler ontology documentation preserved for future implementation
- Sentiment analysis logic preserved for future use
- MongoDB collections can be activated when news features resume
- LLM-based extraction framework can be extended to news data

**Current Focus:**
- DART disclosure financial metrics extraction (FR2i-FR2z)
- Metric-based backtesting (FR39s-FR39v)
- Direct category-to-event mapping (16 disclosure types)

---

## Project Classification

**Technical Type:** SaaS B2B / Investment Intelligence Platform
**Domain:** Fintech (Korean Stock Market)
**Complexity:** High
**Project Context:** Brownfield - extending existing multi-service system

**Technical Implications:**

*Architecture:*
- Extends existing microservices (Frontend, Airflow, LLM, KG, News Crawler)
- Adds event-driven prediction engine integrated with Neo4j knowledge graph
- Requires time-based orchestration layer for user scenario management
- Chat system integration with event processing core

*Fintech Compliance Considerations:*
- Korean financial market regulations for investment advice
- Investment data accuracy and reliability requirements
- User financial data privacy and security (existing: PostgreSQL with JWT auth)
- Real-time data processing accuracy for predictions
- Audit trail requirements for recommendations and backtesting results

*Data Flow:*
- News Crawler → Event Extraction → Knowledge Graph (date-indexed)
- Knowledge Graph → Event Pattern Analysis → Prediction Engine
- User Profile + Prediction Engine → Portfolio Recommendations (time-scheduled)
- User Holdings + Event Patterns → Automated Backtesting
- All insights → Chat Interface (conversational delivery)

*Key Technical Challenges:*
- Event similarity detection across subgraphs
- Temporal pattern matching for predictions
- Real-time orchestration of time-sensitive features
- Balancing automated recommendations with user control
- Ensuring prediction accuracy and managing user expectations

## Success Criteria

### User Success

**Primary Success Indicator:** Event-based prediction trust and utility

Users successfully leverage event-driven intelligence when they:
- **Understand predictions:** Users can see how similar historical events under similar conditions led to specific stock movements, and understand why the system predicts a particular outcome
- **Trust the system:** Users gain confidence through transparent event-pattern matching that shows the historical basis for each prediction
- **Act on insights:** Users incorporate event-based predictions into their investment decisions, moving from manual news analysis to intelligent, pattern-based guidance

**Measurable User Success:**
- **User Satisfaction Threshold:** 70% of users rate event-driven prediction usefulness as 4/5 or higher
- **"Aha!" Moment:** Users experience their first successful prediction within first week of using event-driven features
- **Feature Adoption:** Users actively view event-based predictions and alerts rather than relying solely on traditional analysis
- **Comprehension:** Users understand the historical event patterns behind predictions (validated through surveys/feedback)

**Emotional Success:**
- **Confident:** "I trust these predictions because I can see the historical patterns"
- **Empowered:** "I understand why the system predicts this outcome"
- **Relieved:** "The system automatically finds relevant events and shows me what happened before"

### Business Success

**3-Month Success Indicators:**
- Event-driven prediction feature has 60%+ adoption among active users
- User satisfaction scores trending toward 70% threshold
- Initial Sharpe Ratio data showing positive signal (event-based strategies showing promise)
- Knowledge graph successfully populated with events from defined ontology
- Multi-timeframe predictions generating user engagement

**12-Month Success Metrics:**
- **User Satisfaction:** 70%+ of users rate event-driven predictions as useful (4/5 or higher)
- **Sharpe Ratio Performance:** Event-based strategies outperform buy-and-hold by 5%
- **User Retention:** Users leveraging event-driven features show higher retention than those using only traditional analysis
- **Feature Stickiness:** Daily active usage of event predictions and alerts
- **Backtesting Validation:** Manual backtesting results demonstrate consistent prediction accuracy

**Key Business Metric:** Combination of user satisfaction (trust) and Sharpe Ratio performance (actual results) validates the event-driven approach as a competitive differentiator for Stockelper.

### Technical Success

**Event Extraction Accuracy (Critical Enabler):**
- **Primary Technical Metric:** Event extraction accuracy from news and disclosure information
- Events correctly identified, classified, and mapped to defined ontology
- Event metadata (date, entities, conditions) accurately captured
- Extraction quality directly impacts prediction accuracy

**Additional Technical Success Criteria:**
- **Knowledge Graph Quality:** Events properly indexed by date with accurate entity relationships per subgraph
- **Pattern Matching Accuracy:** Similar events under similar conditions correctly identified for prediction generation
- **Prediction Confidence Calculation:** Confidence levels accurately reflect historical pattern strength
- **Multi-timeframe Prediction Engine:** Successfully generates short, medium, and long-term predictions based on historical patterns
- **Event Alert System Reliability:** Users receive relevant alerts when similar events occur
- **Chat Interface Integration:** Event-driven predictions accessible through conversational interface
- **Airflow DAG Orchestration:** Reliable pipeline for event extraction → knowledge graph → prediction engine
- **System Performance:** Prediction generation and alert delivery within acceptable latency (sub-second for queries, near-real-time for alerts)

**Technical Validation:**
- Event extraction tested against human-labeled dataset for accuracy benchmark
- Subgraph similarity detection validated through backtesting correlation
- Prediction confidence scores calibrated against actual outcomes

### Measurable Outcomes

**Quantitative Metrics:**
- **70% user satisfaction threshold** for event-driven prediction usefulness
- **5% Sharpe Ratio outperformance** vs. buy-and-hold strategies
- **Event extraction accuracy** maintained above baseline (specific threshold TBD during development)
- **Feature adoption rate:** 60%+ of active users engaging with event-driven predictions
- **Alert relevance:** Users act on event alerts (measured through click-through and portfolio actions)

**Qualitative Metrics:**
- User feedback indicates trust in event-based predictions
- Users demonstrate understanding of prediction rationale
- User testimonials highlight "finally!" moment of event-driven intelligence
- Reduced user anxiety about market events (measured through surveys)

**Validation Approach:**
- **Sharpe Ratio calculated** through backtesting engine comparing event-based strategies vs. buy-and-hold
- **User satisfaction measured** through in-app surveys after prediction usage
- **Event extraction accuracy** validated against human review and backtesting correlation
- **Feature adoption tracked** through usage analytics and engagement metrics

## Product Scope

### MVP - Minimum Viable Product

**Core Event-Driven Prediction Engine:**
1. **Knowledge Graph Foundation:**
   - Event extraction from news and disclosure information
   - Events mapped to **defined ontology** (controlled scope for quality)
   - Date-indexed events with entity relationships per subgraph
   - Knowledge graph integration with existing Neo4j infrastructure

2. **Multi-timeframe Prediction System:**
   - Short-term prediction (days to weeks)
   - Medium-term prediction (weeks to months)
   - Long-term prediction (months+)
   - Historical pattern matching across timeframes
   - **Prediction confidence levels** based on pattern strength

3. **Event Alert System:**
   - Real-time detection of similar events occurring
   - User notifications when relevant event patterns emerge
   - Alert relevance based on user portfolio and interests
   - Integration with chat interface for alert delivery

4. **Manual Portfolio Recommendations:**
   - User-initiated recommendation requests
   - Recommendations based on event patterns and predictions
   - Explanation of event rationale behind recommendations
   - Not yet time-scheduled (manual trigger only for MVP)

5. **Manual Backtesting:**
   - User can test specific stocks or strategies
   - Backtesting engine calculates Sharpe Ratio
   - Historical performance validation of event-based predictions
   - Not yet automatic (user must initiate tests)

6. **Chat Interface Integration:**
   - Conversational access to event-driven predictions
   - Query historical event patterns
   - View prediction confidence and explanations
   - Receive alerts and recommendations through chat

7. **Airflow DAG Orchestration:**
   - Pipeline: News Crawler → Event Extraction → Knowledge Graph
   - Scheduled updates to event data
   - Prediction engine triggered by knowledge graph updates
   - Alert system monitoring for similar events

**MVP Success Criteria:**
- Users can see event-based predictions with confidence levels
- Users understand historical patterns behind predictions
- Users receive alerts for relevant similar events
- Manual backtesting validates prediction accuracy
- System demonstrates path to 70% satisfaction and 5% Sharpe outperformance

**MVP Scope Limitations:**
- Events limited to defined ontology (not all possible event types)
- Portfolio recommendations are manual, not time-scheduled
- Backtesting is user-initiated, not automatic
- Single-market focus (Korean market only)

### Growth Features (Post-MVP)

**Automation Layer:**
1. **Automated Time-Scheduled Portfolio Recommendations:**
   - Daily portfolio recommendations at optimal times
   - Personalized timing based on user behavior
   - Automatic consideration of user investment profile
   - Proactive delivery without user request

2. **Automatic Backtesting Triggered by Holdings:**
   - System automatically backtests stocks in user portfolio
   - Background validation of current holdings against event patterns
   - Proactive alerts if event patterns suggest risk
   - No manual setup required

3. **Expanded Event Coverage:**
   - Beyond defined ontology to broader event extraction
   - Additional data sources beyond news and disclosures
   - Enhanced event classification and categorization

**Enhanced Intelligence:**
4. **Advanced Subgraph Analysis:**
   - More sophisticated similarity detection algorithms
   - Context-aware condition matching
   - Multi-dimensional pattern recognition

5. **Recommendation Explanation Engine:**
   - Detailed rationale for each recommendation
   - Visual representation of event patterns
   - Risk/reward analysis based on historical outcomes

6. **Personalized Event Sensitivity:**
   - Learn which events matter most to each user
   - Adapt predictions based on user portfolio composition
   - Customized alert thresholds per user

### Vision (Future)

**Cross-Market Intelligence:**
1. **Global Event Correlation:**
   - Korean market events + international events
   - Cross-border event impact analysis
   - Currency and geopolitical event integration

2. **Event Pattern Discovery:**
   - AI automatically identifies new event-outcome patterns
   - Unsupervised learning finds hidden correlations
   - Continuous improvement of prediction models

**Social & Collaborative:**
3. **Social Proof Layer:**
   - Show anonymized data on user actions following predictions
   - Community validation of prediction accuracy
   - Collaborative event pattern validation

4. **Portfolio Optimization Engine:**
   - Full portfolio construction based on event intelligence
   - Risk balancing across multiple event scenarios
   - Automated rebalancing recommendations

5. **Predictive Event Detection:**
   - Early warning signals for potential events
   - Leading indicator analysis from data patterns
   - Proactive rather than reactive event intelligence

## User Journeys

### Journey 1: Jimin Kim - Finding Rationale Through Event Patterns

**The Situation:**
Jimin Kim is a 28-year-old office worker who started investing six months ago. She has some savings and wants growth potential, but every time she researches a stock, she's overwhelmed by conflicting news articles, complex financial reports, and contradictory analyst opinions. She needs a way to cut through the noise and find actual rationale for her decisions.

**The Journey:**
One evening, while checking Stockelper's chat interface, Jimin asks about a semiconductor stock she's considering. Instead of generic analysis, the LLM chatbot shows her something different: "This company just announced a new factory expansion. Similar events occurred 3 times in the past under similar conditions. Here's what happened to the stock price each time..."

The system displays three historical instances with clear timelines:
- **2019 expansion announcement:** Stock rose 12% over 3 months
- **2021 expansion announcement:** Stock rose 8% over 2 months  
- **2022 expansion announcement:** Stock rose 15% over 4 months

**Prediction confidence:** High (85%) - stock likely to appreciate 10-15% over next 3 months.

Jimin finally has something concrete. Not vague predictions, but historical patterns showing what actually happened when similar events occurred. She understands the rationale: factory expansions historically led to growth for this type of company under these market conditions.

She invests a modest amount. Over the next two months, the stock performs as predicted. Jimin doesn't feel like she got lucky - she feels like she made an informed decision based on real evidence.

**Requirements Revealed:**
- Event pattern matching with historical examples
- Multi-timeframe prediction display
- Confidence level calculation and display
- Chat interface for natural language queries
- Clear visualization of historical event timelines
- Explanation of "similar conditions" criteria

### Journey 2: Minho Park - Portfolio Recommendations with Evidence

**The Situation:**
Minho Park, 35, has been investing for a year but his portfolio lacks direction. He owns random stocks picked from tips and headlines. He wants growth potential but doesn't know which sectors or companies have real rationale behind them.

**The Journey:**
Minho opens Stockelper and manually requests a portfolio recommendation. Instead of generic "top picks," the system analyzes recent events in the knowledge graph and presents three recommended stocks:

**Recommendation 1: Battery Manufacturer ABC**
- **Event detected:** Major automaker partnership announced yesterday
- **Historical pattern:** Similar partnerships led to avg. 18% growth over 6 months (5 instances)
- **Confidence:** High (82%)
- **Rationale:** Partnership announcements for battery suppliers historically signal increased production capacity and revenue

**Recommendation 2: Pharmaceutical Company XYZ**
- **Event detected:** Phase 3 trial success announced this week
- **Historical pattern:** Phase 3 successes for this drug category led to avg. 25% growth over 3 months (4 instances)
- **Confidence:** Medium (68%)
- **Rationale:** Clinical trial successes typically drive stock appreciation, though variability exists

**Recommendation 3: Tech Company DEF**
- **Event detected:** Government contract award last week
- **Historical pattern:** Government contracts for this sector led to avg. 12% growth over 4 months (7 instances)
- **Confidence:** High (78%)
- **Rationale:** Government contracts provide revenue stability and market confidence

Each recommendation includes the specific event, historical evidence, confidence level, and clear rationale. Minho doesn't need to be a financial expert - he can see why these stocks have growth potential based on what actually happened in similar situations.

He selects two recommendations to add to his portfolio, understanding exactly why these stocks were suggested.

**Requirements Revealed:**
- Manual portfolio recommendation trigger
- Event detection and classification
- Multi-stock recommendation generation
- Historical pattern analysis per recommendation
- Confidence scoring per recommendation
- Clear rationale explanation
- Recommendation filtering by confidence level
- Investment profile consideration (beginner-friendly explanations)

### Journey 3: Sora Lee - Validation Through Backtesting

**The Situation:**
Sora Lee, 31, heard about a biotech stock from a friend. The company just announced FDA approval for a new drug. Her friend is excited, but Sora wants evidence before investing her money.

**The Journey:**
Sora opens Stockelper's chat interface and asks: "Should I invest in [biotech company]? They just got FDA approval."

The LLM chatbot responds: "Let me show you what happened historically when similar biotech companies got FDA approval. Would you like me to run a backtest?"

Sora confirms, and the system runs manual backtesting:

**Backtest Results:**
- **Event Category:** FDA drug approval for biotech companies (small to mid-cap)
- **Historical Instances:** 8 similar events found
- **Performance Analysis:**
  - **3-month returns:** +22% average (range: +8% to +45%)
  - **6-month returns:** +18% average (range: -5% to +52%)
  - **12-month returns:** +12% average (range: -12% to +38%)
- **Sharpe Ratio:** Event-based strategy (buying on FDA approval) = 1.8
- **Buy-and-hold comparison:** Event strategy outperformed by 8%

The backtest shows her that while FDA approvals generally led to positive returns, there's variability. The chatbot explains: "7 out of 8 companies appreciated in value, but one declined. The average outperformance suggests growth potential, but past performance doesn't guarantee future results."

Sora now has rational basis for her decision. She understands both the potential (historically positive) and the risk (one case declined). She invests a amount she's comfortable with, based on evidence rather than just her friend's enthusiasm.

**Requirements Revealed:**
- Manual backtesting trigger via chat
- Event category matching
- Historical instance retrieval
- Multi-timeframe return calculation
- Sharpe Ratio calculation
- Performance range display (best/worst cases)
- Comparison to buy-and-hold baseline
- Risk disclosure in results
- Natural language backtesting interface

### Journey 4: Junho Choi - Event Alert Response

**The Situation:**
Junho Choi, 29, invested in a retail company two months ago based on Stockelper's event-driven prediction. He's monitoring his investment but doesn't have time to constantly check news.

**The Journey:**
While at work, Junho receives a notification from Stockelper: 

"**Event Alert:** Your portfolio stock [Retail Company] - similar event detected

A major competitor just announced bankruptcy. When similar competitive bankruptcies occurred in the past (3 instances), your stock's competitors saw average gains of 15% over 2 months as market share shifted.

**Prediction:** Your stock may appreciate 12-18% over next 2 months
**Confidence:** High (80%)
**Action to consider:** Hold position or increase allocation"

Junho opens the app and sees the detailed historical pattern:
- **2018:** Competitor A bankruptcy → Retail Company B gained 14% in 6 weeks
- **2020:** Competitor C bankruptcy → Retail Company D gained 18% in 8 weeks  
- **2022:** Competitor E bankruptcy → Retail Company F gained 12% in 10 weeks

He understands immediately: when competitors fail, market share flows to remaining players. The pattern has happened before under similar conditions.

Junho decides to hold his position (rather than panic-selling due to market volatility). Two months later, his stock has appreciated 16% as predicted. The event alert helped him stay rational during uncertainty.

**Requirements Revealed:**
- Event monitoring for portfolio holdings
- Similarity detection for new events
- Real-time alert generation
- Push notification system
- Alert contains: event description, historical pattern, prediction, confidence
- Link from alert to detailed analysis
- Action recommendations (hold/buy/sell consideration)
- Historical timeline visualization
- Integration with user portfolio data

### Journey 5: Hyejin Song (Development Team) - Managing Event Ontology

**The Situation:**
Hyejin Song is a data engineer on the Stockelper development team. She's responsible for managing the event ontology that defines what events are extracted from news and disclosure data. The quality of event extraction directly impacts prediction accuracy, so her work is critical.

**The Journey:**
Every two weeks, Hyejin reviews event extraction quality. She opens the ontology management interface and sees:

**Current Ontology Status:**
- **Total event categories:** 45 defined
- **Recent extractions:** 1,247 events this week
- **Extraction accuracy:** 87% (based on sample validation)
- **Unmapped events:** 23 potential new categories flagged

Hyejin reviews the unmapped events - these are news articles or disclosures that the system couldn't classify into existing ontology categories:
- "Supply chain disruption due to port strike" (new category needed?)
- "CEO succession announcement" (already covered, but rule needs refinement)
- "Cryptocurrency adoption for payments" (emerging category - add?)

For the port strike category, Hyejin decides it's important. She:
1. Creates new ontology entry: "Supply Chain Disruption - Port Operations"
2. Defines extraction rules: keywords, entity types, context requirements
3. Tests against historical news to validate the definition
4. Deploys updated ontology to production

The next day, the system successfully extracts a new port strike event and matches it against historical patterns. When a beginner investor asks about a shipping company stock, they get event-based predictions that include this newly categorized event type.

Hyejin also reviews extraction accuracy metrics:
- Which categories have low accuracy (need rule refinement)
- Which events are being missed (ontology gaps)
- Which false positives need filtering (overly broad rules)

She makes incremental improvements, knowing that better event extraction = better predictions = higher user satisfaction.

**Requirements Revealed:**
- Ontology management interface
- Event category definition CRUD operations
- Extraction rule configuration (keywords, entities, context)
- Unmapped event flagging system
- Sample validation workflow
- Accuracy metrics per category
- Historical testing against past news
- Ontology versioning and deployment
- Impact analysis (how many users affected by ontology changes)
- Integration with Airflow DAG for reprocessing

### Journey Requirements Summary

The five journeys above reveal distinct capability requirements:

**Event-Driven Prediction Engine (Journeys 1, 2, 4):**
- Historical event pattern matching across subgraphs
- Multi-timeframe prediction generation (short, medium, long-term)
- Confidence level calculation based on pattern strength
- Event similarity detection and classification
- Real-time event monitoring and alerting
- Natural language query interface via LLM chatbot

**Portfolio & Recommendation System (Journey 2, 4):**
- Manual portfolio recommendation generation
- Event-based stock filtering and ranking
- Rationale explanation with historical evidence
- Portfolio holdings tracking for event alerts
- Action recommendations (hold/buy/sell considerations)

**Backtesting Engine (Journey 3):**
- Manual backtesting trigger via chat interface
- Historical instance retrieval by event category
- Multi-timeframe return calculation (3mo, 6mo, 12mo)
- Sharpe Ratio calculation and comparison
- Performance range analysis (best/worst cases)
- Natural language results explanation

**Knowledge Graph & Ontology (All journeys, especially Journey 5):**
- Event extraction from news and disclosures
- Ontology-based event classification
- Date-indexed event storage in Neo4j
- Event metadata management (entities, conditions, categories)
- Ontology management interface for developers
- Extraction accuracy monitoring and validation

**Chat Interface & User Experience (All journeys):**
- Natural language query handling via LLM
- Conversational access to predictions and recommendations
- Historical pattern visualization
- Confidence level display
- Clear rationale explanations for beginners
- Push notification for event alerts

**System Infrastructure (Supporting all journeys):**
- Airflow DAG orchestration for data pipeline
- Real-time event monitoring and alert generation
- User portfolio data storage and retrieval
- Prediction caching for performance
- Analytics tracking for user satisfaction metrics

## Domain-Specific Requirements

### Fintech Compliance & Regulatory Overview

**Positioning Strategy: Informational/Educational Platform**

Stockelper positions itself as a search-augmented generative chatbot providing informational content and educational insights rather than regulated investment advisory services. This strategic positioning allows the platform to deliver intelligent, event-driven predictions while avoiding the regulatory burden of becoming a registered investment advisor.

**Key Positioning Elements:**
- **Informational Nature:** All predictions, recommendations, and analyses are presented as educational information based on historical pattern analysis
- **User Responsibility:** Users maintain full decision-making authority for all investment choices
- **No Fiduciary Relationship:** Platform does not establish advisor-client fiduciary relationships
- **Embedded Disclaimers:** All outputs include appropriate disclaimers about information vs. advice distinction

**Regulatory Monitoring:**
While not currently subject to FSC (Financial Services Commission) or FSS (Financial Supervisory Service) investment advisory regulations, the platform acknowledges:
- Regulatory landscape may evolve to encompass AI-powered financial information platforms
- Ongoing monitoring of Korean fintech regulations required
- Potential need for legal consultation if positioning is challenged
- Readiness to adapt if regulatory interpretation changes

### Key Domain Concerns

#### 1. Financial Data Accuracy & Reliability

**Critical Requirement:** Event extraction accuracy directly impacts prediction quality and user trust.

**Standards:**
- **Event Extraction Quality:** Maintain accuracy baseline through ontology management and validation
- **Historical Data Integrity:** Ensure knowledge graph contains verified historical event patterns
- **Prediction Confidence Calibration:** Confidence scores must accurately reflect pattern strength
- **Data Source Verification:** News and disclosure data validated against authoritative sources (DART, KIS OpenAPI)

**Validation Approach:**
- Manual review of event extraction samples against human-labeled datasets
- Backtesting correlation validates historical pattern accuracy
- Continuous monitoring of prediction accuracy vs. actual outcomes
- User feedback loop for event classification quality

#### 2. Security Standards

**Baseline Security Implementation** (no dedicated security experts in MVP):

**Infrastructure Security:**
- **HTTPS/TLS Encryption:** All data in transit encrypted
- **JWT Authentication:** Existing user authentication maintained
- **Database Encryption:** Sensitive user data encrypted at rest
- **API Security:** Rate limiting and authentication for all endpoints

**Application Security:**
- **Input Validation:** Prevent injection attacks on user queries
- **Output Sanitization:** Prevent XSS vulnerabilities in chat interface
- **Session Management:** Secure session handling with timeout policies
- **Dependency Management:** Regular updates to address known vulnerabilities

**Implementation Approach:**
- Leverage established security libraries and frameworks (Next.js, FastAPI built-in security)
- Follow OWASP Top 10 mitigation strategies
- Security testing during development lifecycle
- Third-party security assessment considered post-MVP if scaling

#### 3. Audit & Accountability Requirements

**Prediction Logging & Traceability:**

**What Must Be Logged:**
- **Prediction Generation:** Timestamp, user ID, stock symbol, prediction output, confidence level
- **Event Patterns Used:** Which historical events contributed to prediction
- **Model Version:** Knowledge graph state and ontology version at prediction time
- **User Actions:** Portfolio recommendations delivered, backtesting executed
- **Alert Delivery:** Event alerts sent to users with content and timing

**Purpose:**
- **User Support:** Ability to explain why system made specific predictions
- **Quality Improvement:** Analyze prediction accuracy over time
- **Accountability:** Demonstrate non-advisory positioning if questioned
- **Model Validation:** Track model performance for Sharpe Ratio calculations

**Retention Policy:**
- Prediction logs retained for minimum 12 months (aligns with Sharpe Ratio validation period)
- User portfolio data retained per user consent and data retention policies
- Anonymized aggregate data may be retained longer for model improvement

**Sharpe Ratio Validation:**
- Backtesting engine provides objective performance measurement
- Event-based strategies compared against buy-and-hold baseline
- Results logged and available for audit
- Transparent methodology for performance calculation

#### 4. Fraud Prevention & Abuse Mitigation

**Rate Limiting & Usage Controls:**
- **API Rate Limits:** Prevent abuse of prediction and recommendation endpoints
- **Query Throttling:** Reasonable limits on backtesting and portfolio recommendation requests
- **Alert Frequency Caps:** Prevent alert spam to users

**Usage Monitoring:**
- **Anomaly Detection:** Flag unusual query patterns or excessive usage
- **Account Verification:** Basic identity verification for account creation
- **Suspicious Activity Alerts:** Monitor for coordinated manipulation attempts

**Data Integrity:**
- **Event Source Validation:** Verify news and disclosure data authenticity
- **Pattern Manipulation Prevention:** Detect attempts to game prediction system
- **User Feedback Validation:** Prevent fake satisfaction scores

#### 5. Privacy & Personal Data Protection (PIPA Compliance)

**Korean Personal Information Protection Act (PIPA) Requirements:**

**User Consent & Transparency:**
- **Explicit Consent:** Users consent to data collection for investment profile and portfolio tracking
- **Purpose Limitation:** Data collected only for stated purposes (predictions, recommendations, personalization)
- **Transparency:** Clear privacy policy explaining what data is collected and how it's used

**Data Rights:**
- **Access Right:** Users can view their data (portfolio, preferences, prediction history)
- **Correction Right:** Users can update investment profiles and portfolio information
- **Deletion Right:** Users can request account and data deletion
- **Portability:** Users can export their data in standard formats

**Data Security Measures:**
- **Encryption:** Personal data encrypted at rest and in transit
- **Access Controls:** Role-based access to user data within system
- **Anonymization:** Aggregate analytics use anonymized data where possible
- **Breach Notification:** Incident response plan for potential data breaches

**Data Retention:**
- **Active Users:** Data retained while account is active
- **Inactive Accounts:** Data retention policies for dormant accounts
- **Post-Deletion:** Logs may retain anonymized references per audit requirements
- **Legal Compliance:** Minimum retention periods for financial transaction records

**Third-Party Data Sharing:**
- **No Selling of User Data:** Investment profiles and portfolio data not sold to third parties
- **Service Providers:** Limited sharing with essential service providers (cloud hosting, analytics) under data processing agreements
- **Aggregated Insights:** Anonymized, aggregate trends may be shared for research purposes

### Compliance Requirements

**Disclaimers & User Agreements:**

**Required Disclaimers (Embedded in All Outputs):**
- "This information is for educational purposes only and does not constitute investment advice."
- "Past performance does not guarantee future results."
- "You are solely responsible for your investment decisions."
- "Consult a licensed financial advisor for personalized investment advice."

**User Agreement Terms:**
- **Acknowledgment of Risk:** Users acknowledge investment risks
- **No Fiduciary Relationship:** Users understand platform is informational
- **Data Usage Consent:** Users consent to data collection per privacy policy
- **Liability Limitation:** Platform not liable for investment losses

**Compliance Monitoring:**
- **Regulatory Tracking:** Monitor FSC/FSS announcements regarding AI platforms
- **Legal Consultation Trigger:** If positioning is challenged or regulations change
- **Terms of Service Updates:** Maintain current legal terms as landscape evolves

### Industry Standards & Best Practices

**Fintech Platform Standards:**
- **Data Security:** Follow industry-standard encryption and authentication practices
- **API Reliability:** Maintain uptime and performance standards for user-facing services
- **Incident Response:** Plan for handling service disruptions or data issues
- **User Communication:** Transparent communication about system capabilities and limitations

**AI/ML Ethics:**
- **Transparency:** Clear explanations of how predictions are generated
- **Bias Mitigation:** Monitor for systematic biases in event extraction or predictions
- **Model Limitations:** Communicate confidence levels and prediction uncertainty
- **User Control:** Users maintain decision authority despite automation

### Required Expertise & Validation

**During MVP Development:**
- **No Dedicated Legal Counsel:** Operating with informational positioning; legal review triggered if needed
- **No Dedicated Security Experts:** Baseline security through best practices and frameworks
- **No Dedicated Compliance Team:** Monitoring through development team awareness

**Post-MVP Considerations:**
- **Legal Review:** Consider legal consultation if scale increases or regulations change
- **Security Assessment:** Third-party penetration testing or security audit if scaling
- **Compliance Consultation:** Engage fintech compliance experts if positioning is questioned

**Validation Approach:**
- **User Agreements:** Standard terms of service and privacy policy drafted
- **Disclaimer Testing:** Validate disclaimers are visible and clear to users
- **Data Handling Audit:** Verify PIPA compliance through data flow analysis
- **Security Testing:** Basic security testing during development lifecycle

### Implementation Considerations

**Phased Approach:**

**MVP Phase (Immediate):**
- Implement baseline security (HTTPS, JWT, encryption, rate limiting)
- Embed disclaimers in all prediction and recommendation outputs
- Create clear privacy policy and terms of service
- Implement basic prediction logging for accountability

**Growth Phase (Post-MVP):**
- Enhance audit logging with detailed traceability
- Implement comprehensive usage monitoring and anomaly detection
- Consider third-party security and compliance assessments
- Expand user data rights functionality (export, deletion workflows)

**Scale Phase (Future):**
- Legal review of regulatory positioning
- Enhanced fraud prevention systems
- Compliance team consideration if regulatory landscape changes
- Advanced security measures (penetration testing, SIEM, etc.)

**Risk Mitigation:**
- **Positioning Risk:** Clear, consistent communication of informational nature
- **Security Risk:** Follow OWASP guidelines and use established security frameworks
- **Data Risk:** Implement PIPA-compliant data handling from day one
- **Regulatory Risk:** Monitor FSC/FSS announcements; prepared to adapt if needed

### Non-Functional Requirements Derived from Domain

**Performance:**
- Prediction queries: Sub-second response time for user experience
- Event alerts: Near-real-time delivery (within minutes of event detection)
- Backtesting: Complete within reasonable time (seconds for manual requests)

**Reliability:**
- System uptime: Standard for SaaS platforms (99%+ availability goal)
- Data accuracy: Event extraction and prediction quality maintained through validation
- Audit trail: Comprehensive logging for accountability

**Scalability:**
- Support growing user base without degradation
- Knowledge graph growth accommodated in Neo4j infrastructure
- Prediction engine scales with increasing event volume

**Maintainability:**
- Ontology management enables quality control
- Modular architecture supports iterative improvements
- Logging facilitates troubleshooting and optimization

## SaaS B2B Specific Requirements

### Project-Type Overview

Stockelper operates as a simplified SaaS platform targeting individual Korean retail investors. The architecture prioritizes individual user experience over complex enterprise features, operating as a free service in the MVP phase.

**Key Characteristics:**
- **Individual User Focus:** No organizational hierarchies or group structures
- **Free Service Model:** No subscription tiers or payment processing in MVP
- **Single Tenant per User:** Each user operates independently with their own portfolio and preferences
- **Development Team Administration:** System-level features (ontology management) handled by development team, not end users

### Technical Architecture Considerations

#### User & Tenant Model

**Single-User Tenancy:**
- Each user account is an independent entity with isolated data
- PostgreSQL database with existing JWT authentication provides user isolation
- No shared workspaces or collaborative features in MVP
- User data boundaries enforced at application and database levels

**Data Isolation:**
- User portfolios: Private to individual user
- Investment profiles: Private to individual user
- Prediction history: Private to individual user
- Event alerts: User-specific based on portfolio holdings

#### Permission & Access Control

**Simplified Role Structure:**

**End Users (Beginner Investors):**
- View event-driven predictions and confidence levels
- Request portfolio recommendations manually
- Execute manual backtesting
- Manage personal portfolio holdings
- Update investment profile preferences
- View prediction history and event alerts
- **No administrative capabilities**

**Development Team (Internal):**
- Ontology management interface access
- Event extraction rule configuration
- System monitoring and analytics
- Database administration
- **Not exposed to end users in MVP**

**Authentication & Authorization:**
- Existing JWT-based authentication maintained
- Session management with secure token handling
- No complex RBAC (Role-Based Access Control) matrix needed for MVP
- Future consideration: Admin roles if self-service ontology features added

#### Subscription & Monetization Model

**MVP Approach: Free Service**
- No payment processing or subscription management required
- No feature gating based on tiers
- All users access full feature set
- No usage quotas or rate limits based on subscription (only abuse prevention limits)

**Post-MVP Considerations:**
- Potential future tiering: Free vs. Premium
- Possible limits: Number of backtests, prediction queries, portfolio size
- Enterprise tier consideration for institutional users
- **Not implemented in MVP scope**

#### Integration Architecture

**Existing Integrations (Already Implemented):**
- **DART API:** Financial disclosure data extraction
- **KIS OpenAPI:** Korean trading data and market information
- **Naver Finance:** News article scraping and event extraction
- **MongoDB:** Scraped news and raw financial data storage
- **Neo4j:** Knowledge graph entity and relationship storage
- **PostgreSQL:** User data, authentication, LLM checkpoints

**No Additional Integrations Planned:**
- No third-party portfolio tracking services
- No external brokerage API integrations
- No financial news provider APIs beyond Naver
- Existing data sources sufficient for MVP scope

**Data Export Capabilities:**
- Users can view prediction history within application
- Manual data export not prioritized for MVP
- API access for external tools not planned
- Focus on in-app experience rather than programmatic access

#### Compliance Requirements (SaaS-Specific)

**MVP Scope:**
- Basic terms of service and privacy policy (PIPA compliance documented in Domain Requirements)
- Standard uptime expectations without formal SLA guarantees
- Security baseline through HTTPS, JWT, encryption (documented in Domain Requirements)
- Incident response for service disruptions (development team responsibility)

**Post-MVP Considerations:**
- **Data Residency:** Confirm Korean data hosting if scaling internationally
- **SOC 2 / ISO 27001:** If targeting enterprise or institutional clients
- **Service Level Agreements:** Formal uptime guarantees and support commitments
- **Compliance Certifications:** If regulatory landscape changes or enterprise sales pursued

**Current Approach:**
- Informational platform positioning (documented in Domain Requirements)
- Monitor FSC/FSS fintech regulations
- Defer enterprise-grade compliance until business model and scale justify investment

### Implementation Considerations

**Simplified Architecture Benefits:**
- **Faster MVP Development:** No complex multi-tenancy or subscription logic
- **Reduced Operational Overhead:** No payment processing, billing, or tier management
- **Focus on Core Value:** Event-driven predictions and user experience prioritized
- **Scalability Path:** Architecture can evolve to add tiers and features post-MVP

**Technical Decisions:**
- Leverage existing authentication and user database infrastructure
- No additional permission frameworks needed for MVP
- No integration middleware required beyond existing data connectors
- SaaS-specific features deferred to growth phase

**Future Scalability:**
- User isolation design supports future multi-tenancy if needed
- Database schema can accommodate subscription tiers when added
- Integration architecture extensible for future third-party connections
- Permission model can be enhanced with RBAC if admin features exposed

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach: Platform MVP**

Stockelper's MVP focuses on building the foundational platform infrastructure—event extraction, knowledge graph, and prediction engine—with manual user-initiated features. This approach validates the core innovation (event-driven pattern matching) while deferring automation and advanced features to post-MVP phases.

**Strategic Rationale:**
- **Prove the Core Concept:** Validate that event pattern matching delivers accurate predictions and user value
- **Manual Before Automatic:** User-initiated recommendations and backtesting reduce complexity while testing demand
- **Foundation for Scale:** Knowledge graph and prediction engine infrastructure supports future automation
- **Learning-Focused:** MVP generates data on prediction accuracy, user behavior, and feature usage to inform growth priorities

**Resource Requirements:**
- **Team Composition:** Full-stack developers (Next.js frontend), Python backend engineers (FastAPI, LangGraph), data engineers (Airflow, Neo4j), ML/NLP expertise (event extraction, pattern matching)
- **Infrastructure:** Existing microservices (PostgreSQL, MongoDB, Neo4j, Airflow) minimize new infrastructure needs
- **Timeline Expectation:** Medium complexity MVP given knowledge graph construction and multi-agent system integration

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**

**Journey 1 - Event Pattern Discovery (Jimin Kim):**
- Users query about stocks via chat interface
- System shows historical event patterns with confidence levels
- Multi-timeframe predictions displayed (short, medium, long-term)
- Clear explanation of "similar events under similar conditions"

**Journey 2 - Manual Portfolio Recommendations (Minho Park):**
- Users manually request portfolio recommendations
- System analyzes recent events and generates suggestions
- Each recommendation includes event rationale, historical pattern, confidence level
- No automated daily delivery in MVP (manual trigger only)

**Journey 3 - Manual Backtesting (Sora Lee):**
- Users initiate backtesting via chat for specific stocks or strategies
- System retrieves historical instances and calculates performance
- Sharpe Ratio comparison to buy-and-hold baseline
- Results show performance range (best/worst cases) and risk disclosure

**Journey 4 - Event Alerts (Junho Choi):**
- Real-time monitoring for similar events affecting user portfolio holdings
- Push notifications when relevant event patterns detected
- Alert includes prediction, confidence level, and historical examples
- Users can drill down into detailed event analysis

**Journey 5 - Ontology Management (Hyejin Song - Development Team):**
- Internal development team interface for event ontology CRUD operations
- Extraction rule configuration and validation workflow
- Accuracy metrics per category for quality monitoring
- Not exposed to end users in MVP

**Must-Have Capabilities:**

1. **Knowledge Graph Foundation:**
   - Event extraction from news and DART disclosures
   - Events mapped to **defined ontology** (controlled scope—not all event types)
   - Date-indexed events with entity relationships in Neo4j
   - Subgraph structure supporting similarity detection

2. **Prediction Engine:**
   - Multi-timeframe prediction generation (short, medium, long-term)
   - Confidence level calculation based on pattern strength
   - Historical event pattern matching across subgraphs
   - "Similar events under similar conditions" detection logic

3. **User-Initiated Features:**
   - **Manual portfolio recommendations** (user-triggered, not time-scheduled)
   - **Manual backtesting** (user-initiated, not automatic)
   - Chat interface for natural language queries
   - Event alert system for portfolio holdings

4. **System Infrastructure:**
   - Airflow DAG: News Crawler → Event Extraction → Knowledge Graph
   - LangGraph multi-agent system integration for predictions
   - Prediction logging for accountability and Sharpe Ratio validation
   - Basic authentication and user portfolio tracking

**MVP Scope Boundaries (What's NOT Included):**
- ❌ Automated time-scheduled portfolio recommendations
- ❌ Automatic backtesting triggered by user holdings
- ❌ All-encompassing event ontology (limited to defined categories)
- ❌ Advanced subgraph analysis beyond basic similarity
- ❌ Cross-market event correlation
- ❌ Subscription tiers or payment processing
- ❌ Admin privileges for end users

### Post-MVP Features

**Phase 2: Growth Features (Post-Launch)**

**Automation Layer:**
1. **Time-Scheduled Portfolio Recommendations:**
   - Daily recommendations delivered at optimal times (no longer manual)
   - Personalized timing based on user behavior patterns
   - Proactive delivery without user request

2. **Automatic Backtesting:**
   - System automatically backtests stocks in user portfolio
   - Background validation provides proactive risk alerts
   - No manual trigger required

3. **Expanded Event Coverage:**
   - Beyond defined ontology to broader event extraction
   - Additional data sources beyond news and DART
   - Enhanced event classification and categorization

**Enhanced Intelligence:**
4. **Advanced Subgraph Analysis:**
   - More sophisticated similarity detection algorithms
   - Context-aware condition matching
   - Multi-dimensional pattern recognition

5. **Personalized Event Sensitivity:**
   - Learn which events matter most to each user
   - Adapt predictions based on portfolio composition
   - Customized alert thresholds per user

**Phase 3: Expansion Features (Future Vision)**

**Cross-Market & Discovery:**
1. **Global Event Correlation:**
   - Korean market + international event impact analysis
   - Cross-border event correlation and currency/geopolitical integration

2. **Event Pattern Discovery:**
   - AI automatically identifies new event-outcome patterns
   - Unsupervised learning finds hidden correlations
   - Continuous improvement of prediction models

**Social & Optimization:**
3. **Social Proof Layer:**
   - Anonymized user action data following predictions
   - Community validation of prediction accuracy

4. **Portfolio Optimization Engine:**
   - Full portfolio construction based on event intelligence
   - Risk balancing across multiple event scenarios
   - Automated rebalancing recommendations

5. **Subscription Tiers:**
   - Free tier with limited features
   - Premium tier with enhanced predictions and more backtesting
   - Enterprise tier for institutional users

### Risk Mitigation Strategy

**Technical Risks:**

**Risk 1: Event Extraction Accuracy**
- **Impact:** Low extraction quality undermines prediction accuracy and user trust
- **Mitigation:** Defined ontology limits scope; manual validation against human-labeled datasets; continuous accuracy monitoring per category
- **Fallback:** Start with narrow ontology (fewer categories) and expand as quality improves

**Risk 2: Subgraph Similarity Detection Complexity**
- **Impact:** Incorrect pattern matching leads to poor predictions
- **Mitigation:** Backtesting validates similarity algorithm; confidence calibration reflects uncertainty; transparent explanation of "similar conditions"
- **Fallback:** Simplify similarity criteria; use more conservative matching; manual review of pattern matches

**Risk 3: Multi-Timeframe Prediction Complexity**
- **Impact:** Building prediction engine for multiple timeframes increases development time
- **Mitigation:** Start with single timeframe (e.g., medium-term 3-6 months) and add others iteratively
- **Fallback:** MVP could launch with single timeframe if timeline constrained

**Market Risks:**

**Risk 1: User Trust in Pattern-Based Predictions**
- **Impact:** Users don't trust predictions based on historical patterns
- **Mitigation:** Transparent explanations showing historical examples; confidence levels acknowledge uncertainty; disclaimers position as informational
- **Validation:** User satisfaction surveys; usage analytics; retention metrics

**Risk 2: Sharpe Ratio Performance Validation**
- **Impact:** Event-based strategies don't outperform buy-and-hold baseline
- **Mitigation:** Backtesting engine provides objective measurement; MVP focuses on learning and validation before aggressive growth
- **Pivot:** If predictions don't outperform, position as educational/research tool rather than investment assistant

**Resource Risks:**

**Risk 1: Knowledge Graph Construction Time**
- **Impact:** Building Neo4j knowledge graph with date-indexed events takes longer than expected
- **Mitigation:** Leverage existing Airflow infrastructure; start with limited historical data (e.g., past 2 years) and backfill over time
- **Fallback:** Launch with smaller knowledge graph scope; expand coverage post-MVP

**Risk 2: Multi-Agent LLM System Integration**
- **Impact:** LangGraph integration complexity delays MVP
- **Mitigation:** Existing LLM service infrastructure reduces integration burden; chat interface already established
- **Fallback:** Simplify agent architecture; use simpler prediction logic in MVP if needed

**Risk 3: Team Resource Constraints**
- **Impact:** Fewer developers or timeline pressure than expected
- **Minimum Viable Scope:** Single timeframe predictions, limited ontology (10-15 core event categories), manual features only, simplified similarity detection
- **Absolute Core:** Prove event extraction → knowledge graph → pattern matching → predictions works, even with reduced feature scope

## Functional Requirements

### Event Intelligence & Knowledge Graph

**[POSTPONED - 2025-01-06]** News-based event extraction postponed. System will focus on DART disclosure metrics (see FR2i-FR2z).

- **FR1:** **[POSTPONED]** System can extract financial events from Korean news articles with sentiment score (-1 to 1 range) using dual crawlers (Naver + Toss)
- **FR1a:** **[POSTPONED]** System can collect news data via dual crawlers: Naver (mobile API-based) and Toss (RESTful API-based)
- **FR1b:** **[POSTPONED]** System can store news articles in MongoDB with collections: `naver_stock_news` and `toss_stock_news`
- **FR1c:** **[POSTPONED]** System can prevent duplicate news articles using unique index on `articleUrl`
- **FR1d:** **[POSTPONED]** System can extract news data via CLI for historical backfill
- **FR1e:** **[POSTPONED]** System can collect news data on scheduled intervals via Airflow DAGs
- **FR1f:** **[POSTPONED]** System can assign source attribute "NEWS" to all news-extracted events
- **FR2:** **[UPDATED - 2025-01-06]** System uses DART disclosure categories directly as events with calculated financial metrics (not sentiment scores). **Note:** This requirement currently applies ONLY to DART disclosures. News-based event extraction with sentiment scoring is POSTPONED (2025-01-06 meeting).
- **FR2a:** **[POSTPONED for NEWS]** System can use LLM-based extraction with distinct prompts for DART vs NEWS data. Currently: DART metrics calculation only, NEWS extraction postponed.
- **FR2b:** System can assign source attribute "DART" to all DART disclosure metrics
- **FR2c:** **[POSTPONED]** System can standardize sentiment score to 0 for dates with no extracted events. (Sentiment scoring postponed - using metrics instead)
- **FR2d:** System can classify DART events into 6 major categories: (1) Capital Changes, (2) Bond Issuance, (3) Treasury Stock, (4) Business Operations, (5) Securities Transactions, (6) M&A/Restructuring
- **FR2e:** System can extract event context from DART disclosures: amount, market cap ratio, purpose, timing
- **FR2f:** **[POSTPONED for NEWS]** System can use deterministic pre-classification rules before LLM extraction for performance optimization. Currently: Applies to DART metrics calculation, NEWS postponed.
- **FR2g:** **[POSTPONED for NEWS]** System can validate extracted events against slot schema per event type (required + optional slots). Currently: Applies to DART metrics validation, NEWS postponed.
- **FR2h:** **[MODIFIED - 2025-01-06]** System stores calculated DART disclosure metrics in PostgreSQL table `dart_disclosure_metrics` (replaces `dart_event_extractions`). See FR2i-FR2z for metrics details.

**FR2i-FR2z: DART Financial Metrics Extraction (NEW - 2025-01-06)**

**Meeting Reference:** 2025-01-06 meeting decision (see `docs/references/20250106.md`)

- **FR2i:** System extracts financial metrics from 16 DART disclosure types for backtesting (types: 6, 7, 8, 9, 16, 17, 21-26, 29-30, 33-36)
- **FR2j:** System calculates disclosure-specific metrics using API-provided fields and market cap data
- **FR2k:** System stores calculated metrics in PostgreSQL `dart_disclosure_metrics` table with JSONB format
- **FR2l:** Metrics available for backtesting condition specification via API queries
- **FR2m:** System supports user-defined backtesting conditions based on metric thresholds
- **FR2n:** (Future) System recommends optimal backtesting conditions using LLM agent analysis

**FR2i-1: 증자/감자 (Capital Changes) Metrics - Disclosure Types 6, 7, 8, 9**

- **FR2i-1a:** For 유상증자 (Type 6): Calculate 조달비율 = (fdpp_fclt + fdpp_op + fdpp_dtrp + fdpp_ocsa + fdpp_etc) / 시가총액
- **FR2i-1b:** For 유상증자 (Type 6): Calculate 희석률 = nstk_ostk_cnt / bfic_tisstk_ostk
- **FR2i-1c:** For 무상증자 (Type 7): Extract 배정비율 = nstk_ascnt_ps_ostk (direct from API)
- **FR2i-1d:** For 감자 (Type 9): Extract 감자비율 = cr_rt_ostk (direct from API)
- **FR2i-1e:** For 감자 (Type 9): Calculate 자본금감소율 = (bfcr_cpt - atcr_cpt) / bfcr_cpt
- **FR2i-1f:** For 유무상증자 (Type 8): Calculate combined metrics from both 유상 and 무상 formulas

**FR2i-2: 전환사채/BW (Convertible Bonds) Metrics - Disclosure Types 16, 17**

- **FR2i-2a:** For CB (Type 16): Calculate CB_발행비율 = bd_fta / 시가총액
- **FR2i-2b:** For CB (Type 16): Extract CB_전환희석률 = cvisstk_tisstk_vs (direct from API)
- **FR2i-2c:** For CB (Type 16): Calculate 전환가괴리율 = (현재주가 - cv_prc) / 현재주가
- **FR2i-2d:** For BW (Type 17): Calculate BW_발행비율 = bd_fta / 시가총액
- **FR2i-2e:** For BW (Type 17): Extract BW_희석률 = nstk_isstk_tisstk_vs (direct from API)

**FR2i-3: 자기주식 (Treasury Stock) Metrics - Disclosure Types 21-24**

- **FR2i-3a:** For 취득 (Type 21): Calculate 취득금액비율 = aqpln_prc_ostk / 시가총액
- **FR2i-3b:** For 취득 (Type 21): Calculate 취득주식비율 = aqpln_stk_ostk / 발행주식총수
- **FR2i-3c:** For 처분 (Type 22): Calculate 처분금액비율 = dppln_prc_ostk / 시가총액
- **FR2i-3d:** For 처분 (Type 22): Calculate 처분주식비율 = dppln_stk_ostk / 발행주식총수
- **FR2i-3e:** For 신탁체결 (Type 23): Calculate 신탁체결비율 = ctr_prc / 시가총액
- **FR2i-3f:** For 신탁해지 (Type 24): Calculate 신탁해지비율 = ctr_prc_bfcc / 시가총액

**FR2i-4: 영업양수도 (Business Transfer) Metrics - Disclosure Types 25-26**

- **FR2i-4a:** For 영업양수 (Type 25): Calculate 양수가액비율 = inh_prc / 시가총액
- **FR2i-4b:** For 영업양수 (Type 25): Extract 자산비중 = ast_rt (direct from API)
- **FR2i-4c:** For 영업양도 (Type 26): Calculate 양도가액비율 = trf_prc / 시가총액
- **FR2i-4d:** For 영업양도 (Type 26): Extract 자산비중 = ast_rt (direct from API)

**FR2i-5: 타법인주식 (Other Company Stocks) Metrics - Disclosure Types 29-30**

- **FR2i-5a:** For 양수 (Type 29): Calculate 금액비율 = inhdtl_inhprc / 시가총액
- **FR2i-5b:** For 양수 (Type 29): Extract 총자산대비 = inhdtl_tast_vs (direct from API)
- **FR2i-5c:** For 양수 (Type 29): Extract 자기자본대비 = inhdtl_ecpt_vs (direct from API)
- **FR2i-5d:** For 양도 (Type 30): Calculate 금액비율 = trfdtl_trfprc / 시가총액
- **FR2i-5e:** For 양도 (Type 30): Extract 총자산대비 = trfdtl_tast_vs (direct from API)

**FR2i-6: 합병/분할 (M&A) Metrics - Disclosure Types 33-36**

- **FR2i-6a:** For 합병 (Type 33): Extract 합병비율 = mg_rt (direct from API)
- **FR2i-6b:** For 합병 (Type 33): Calculate 피합병사자본대비 = rbsnfdtl_teqt / 당사자기자본
- **FR2i-6c:** For 분할 (Type 34): Extract 분할비율 = dv_rt (direct from API)
- **FR2i-6d:** For 분할 (Type 34): Calculate 분할후자본비율 = ffdtl_teqt / atdvfdtl_teqt
- **FR2i-6e:** For 분할합병 (Type 35): Extract 분할합병비율 = dvmg_rt (direct from API)
- **FR2i-6f:** For 주식교환이전 (Type 36): Extract 교환이전비율 = extr_rt (direct from API)

**FR2k: Metrics Storage Schema**

- Table name: `dart_disclosure_metrics`
- **FR2k-1:** Store rcept_no (receipt number, UNIQUE) as primary disclosure identifier
- **FR2k-2:** Store corp_code (8-digit) and stock_code (6-digit) for company identification
- **FR2k-3:** Store disclosure_type (Korean name) and disclosure_type_code (numeric code 6-36)
- **FR2k-4:** Store calculated metrics as JSONB with metric names as keys
- **FR2k-5:** Store market_cap (DECIMAL) used in calculations for audit trail
- **FR2k-6:** Store rcept_dt (disclosure date) for temporal queries
- **FR2k-7:** Create index on (stock_code, rcept_dt DESC) for fast backtesting queries
- **FR2k-8:** Create index on disclosure_type_code for filtering by type
- **FR2k-9:** Create index on rcept_no for unique lookup

**FR2l: Backtesting Integration**

- **FR2l-1:** Metrics accessible via SQL queries from backtesting service
- **FR2l-2:** Support JSONB operators for metric filtering (e.g., `metrics->>'유상증자_조달비율' > 0.1`)
- **FR2l-3:** Return (stock_code, rcept_dt) tuples matching user-defined conditions
- **FR2l-4:** Calculate returns following metric-triggering disclosure events (1, 3, 6, 12 months)

**FR2m: User-Defined Backtesting Conditions**

- **FR2m-1:** Users specify metric name, operator (>, <, >=, <=, =), and threshold value
- **FR2m-2:** Support AND/OR logical combinations of multiple metric conditions
- **FR2m-3:** Example: "유상증자_조달비율 > 0.1 AND 희석률 < 0.05"
- **FR2m-4:** System translates natural language conditions to SQL WHERE clauses

**FR2n: Agent-Recommended Conditions (Future Enhancement)**

- **FR2n-1:** Agent analyzes historical metric distributions across all disclosures
- **FR2n-2:** Agent identifies statistically significant threshold values
- **FR2n-3:** Agent provides confidence scores (0-1) for recommended conditions
- **FR2n-4:** Agent explains rationale for each recommended threshold

- **FR3:** System can classify extracted events into defined ontology categories
- **FR4:** System can store events in Neo4j knowledge graph with date indexing
- **FR5:** System can capture event metadata (entities, conditions, categories, dates)
- **FR6:** System can establish entity relationships within knowledge graph subgraphs
- **FR7:** System can detect similar events based on historical patterns
- **FR8:** System can identify "similar conditions" across different time periods and subgraphs
- **FR8a:** System can classify events as CAPITAL_RAISE (유상증자/CB/BW/교환사채/증권신고서/전환청구권 등)
- **FR8b:** System can classify events as CAPITAL_RETURN (자사주 취득/처분/소각, 배당 등)
- **FR8c:** System can classify events as CAPITAL_STRUCTURE_CHANGE (감자 등)
- **FR8d:** System can classify events as LISTING_STATUS_CHANGE (거래정지/상장폐지/재개/상폐심사 등)
- **FR8e:** System can extract required and optional slots per event type with validation
- **FR8f:** System can generate InvestorView objects with expected returns and confidence scores (0-1) for Black-Litterman model

### Prediction & Analysis

- **FR9:** System can generate short-term predictions (days to weeks) based on event patterns
- **FR10:** System can generate medium-term predictions (weeks to months) based on event patterns
- **FR11:** System can generate long-term predictions (months+) based on event patterns
- **FR12:** System can calculate prediction confidence levels based on pattern strength
- **FR13:** System can match current events against historical event patterns
- **FR14:** System can analyze stock price fluctuations per subgraph following events
- **FR15:** Users can query specific stocks to view event-based predictions
- **FR16:** Users can view historical event examples that inform current predictions
- **FR17:** Users can see explanations of "similar events under similar conditions"
- **FR18:** System can provide rationale for each prediction showing historical basis

### Portfolio Management

- **FR19:** Users can manually request portfolio recommendations via chat interface
- **FR20:** System can analyze recent events to generate stock recommendations
- **FR21:** System can provide event-based rationale for each recommendation
- **FR22:** System can display historical patterns supporting each recommendation
- **FR23:** System can show confidence levels for each recommendation
- **FR24:** Users can add recommended stocks to their portfolio
- **FR25:** Users can track multiple stocks in their personal portfolio
- **FR26:** Users can update their investment profile preferences
- **FR27:** Users can view their portfolio holdings
- **FR28:** Users can remove stocks from their portfolio
- **FR28a:** System implements Black-Litterman portfolio optimization model with 10-step calculation pipeline
- **FR28b:** System performs 11-factor ranking of stocks: operating profit, net income, liabilities, rise/fall rates, profitability, stability, growth, activity, volume, market cap
- **FR28c:** System executes ranking functions in parallel with rate limiting (default: 20 req/sec for KIS API)
- **FR28d:** System normalizes ranking scores using formula: (n - rank + 1) / (n * (n+1) / 2)
- **FR28e:** System aggregates weighted scores based on configurable RankWeight model
- **FR28f:** System generates LLM-based InvestorViews with expected returns (-20% to +20%) and confidence (0-1)
- **FR28g:** System calculates returns covariance matrix (252-day annualized from daily returns)
- **FR28h:** System calculates market equilibrium implied returns using: pi = delta * Sigma * w_mkt
- **FR28i:** System constructs view matrices (P, Q, Omega) for Black-Litterman posterior calculation
- **FR28j:** System applies portfolio optimization with SLSQP solver and constraints: sum(weights)=1.0, each weight ∈ [0, 0.3]
- **FR28k:** System calculates portfolio metrics: expected return, volatility, Sharpe ratio
- **FR28l:** System filters output to exclude stocks with weight < 0.001
- **FR28m:** System executes buy orders via KIS API with market order type
- **FR28n:** System implements separate Buy and Sell workflows using LangGraph state machines
- **FR28o:** System makes LLM-based sell decisions evaluating: loss/profit thresholds, fundamental deterioration, technical signals, news/risks, industry outlook
- **FR28p:** System auto-loads KIS credentials from database and manages token lifecycle
- **FR28q:** System supports paper trading and live trading modes
- **FR28r:** System provides sell/hold recommendations (no short selling)

### Backtesting & Validation

- **FR29:** Users can manually initiate backtesting for specific stocks via chat
- **FR29a:** LLM can extract backtesting parameters (universe, strategy) from user chat input
- **FR29b:** LLM can prompt users with follow-up questions if backtesting parameters are unclear (human-in-the-loop)
- **FR29c:** System can respond to backtesting requests with "Backtesting in progress, navigate to [backtesting page] to check status"
- **FR30:** Users can manually initiate backtesting for specific investment strategies via chat
- **FR30a:** System can execute backtesting in separate container backend (not LLM server)
- **FR30b:** System can send backtesting parameters (universe, strategy, user_id) from LLM to backtesting container
- **FR31:** System can retrieve historical instances of similar events for backtesting
- **FR31a:** System can notify frontend when backtesting execution completes
- **FR31b:** System can generate backtesting results as downloadable report
- **FR31c:** Users can view backtesting results on dedicated results page (not chat interface)
- **FR32:** System can calculate 3-month historical returns for event-based strategies
- **FR33:** System can calculate 6-month historical returns for event-based strategies
- **FR34:** System can calculate 12-month historical returns for event-based strategies
- **FR35:** System can calculate Sharpe Ratio for event-based strategies
- **FR36:** System can compare event-based strategy performance to buy-and-hold baseline
- **FR37:** System can display performance range (best case and worst case scenarios)
- **FR38:** System can provide risk disclosures with backtesting results
- **FR39:** System can show number of historical instances used in backtest
- **FR39a:** System implements async job queue pattern for backtesting with PostgreSQL storage
- **FR39b:** System creates backtest_jobs table with fields: id, user_id, stock_ticker, strategy_type, status, input_json, error_message, retry_count, timestamps
- **FR39c:** System creates backtest_results table with fields: id, job_id, user_id, stock_ticker, strategy_type, results_json, generated_at
- **FR39d:** System creates notifications table for job completion/failure alerts
- **FR39e:** System supports job statuses: pending → in_progress → completed/failed
- **FR39f:** System implements polling-based async worker with configurable interval (default: 5 seconds)
- **FR39g:** System uses SELECT ... FOR UPDATE SKIP LOCKED for concurrent job reservation
- **FR39h:** System finalizes successful jobs by: inserting result, updating status to completed, creating notification
- **FR39i:** System finalizes failed jobs by: storing error message, updating status to failed, creating notification
- **FR39j:** System provides dual API endpoints: legacy format + architecture-compatible format
- **FR39k:** System maps database statuses to standard statuses: pending→queued(0%), in_progress→running(50%), completed→completed(100%), failed→failed(100%)
- **FR39l:** System returns job_id (UUID string) for tracking
- **FR39m:** System stores flexible input parameters as JSONB
- **FR39n:** System stores flexible results as JSONB with Markdown content
- **FR39o:** System tracks job timestamps: created_at, started_at, completed_at
- **FR39p:** System implements exponential backoff for worker polling
- **FR39q:** System supports user-scoped job isolation (all queries filtered by user_id)
- **FR39r:** System provides progress percentage in status endpoint responses

### Alert & Notification System

- **FR40:** System can monitor for new events matching patterns relevant to user portfolio
- **FR41:** System can detect when similar events occur for stocks in user portfolio
- **FR42:** System can send push notifications when relevant event alerts triggered
- **FR43:** Users can receive event alerts with prediction and confidence level
- **FR44:** Users can view historical examples within event alerts
- **FR45:** Users can drill down from alert notification to detailed event analysis
- **FR46:** System can include action recommendations (hold/buy/sell consideration) in alerts
- **FR47:** Users can configure alert preferences for their portfolio

### User Interaction & Chat Interface

- **FR48:** Users can interact with system via natural language chat interface
- **FR49:** Users can query about specific stocks through conversational interface
- **FR50:** Users can request predictions through chat
- **FR51:** Users can request portfolio recommendations through chat
- **FR52:** Users can initiate backtesting through chat
- **FR53:** System can explain predictions in natural language responses
- **FR54:** System can provide conversational access to all event-driven features
- **FR55:** Users can view prediction history through chat interface
- **FR56:** System can display historical event timelines visually within chat
- **FR56a:** System can stream responses via Server-Sent Events (SSE) for real-time token delivery
- **FR56b:** System can emit progress events showing which agent is currently executing
- **FR56c:** System can emit delta events for token-level streaming of LLM responses
- **FR56d:** System can emit final events with complete message, subgraph data, and trading actions

### LLM Multi-Agent System

- **FR57:** System implements LangGraph-based multi-agent architecture with state management
- **FR58:** System includes SupervisorAgent for routing queries to specialized agents
- **FR59:** System includes MarketAnalysisAgent with tools: SearchNews, SearchReport, YouTubeSearch, ReportSentimentAnalysis, GraphQA
- **FR60:** System includes FundamentalAnalysisAgent with tool: AnalysisFinancialStatement (5-year DART data)
- **FR61:** System includes TechnicalAnalysisAgent with tools: AnalysisStock, PredictStock (Prophet+ARIMA ensemble), StockChartAnalysis
- **FR62:** System includes InvestmentStrategyAgent with tools: GetAccountInfo, InvestmentStrategySearch
- **FR63:** System can execute agent tools in parallel using asyncio.gather() for performance
- **FR64:** System can enforce tool execution limits per agent (default: 5 tools max)
- **FR65:** System can enforce agent recursion limits (default: 3 agent calls max)
- **FR66:** System can extract stock name and code from user queries using fuzzy matching against KRX listings
- **FR67:** System can retrieve Neo4j subgraph data (competitors, sectors) for context
- **FR68:** System supports trading interruption workflow with user confirmation via LangGraph interrupt()
- **FR69:** System can resume trading after user provides human_feedback=true/false
- **FR70:** System uses AsyncPostgresSaver for LangGraph checkpoint persistence
- **FR71:** System auto-refreshes expired KIS tokens and updates database
- **FR72:** System caches global multi-agent graph instance for performance
- **FR73:** Chat service operates in chat-only mode (portfolio separated to dedicated service)

### Ontology Management (Development Team)

- **FR74:** Development team can create new event ontology categories
- **FR75:** Development team can read existing event ontology definitions
- **FR76:** Development team can update event ontology category definitions
- **FR77:** Development team can delete event ontology categories
- **FR78:** Development team can configure event extraction rules (keywords, entities, context)
- **FR79:** Development team can test ontology definitions against historical news articles
- **FR80:** Development team can validate event extraction samples
- **FR81:** Development team can view accuracy metrics per ontology category
- **FR82:** Development team can identify unmapped events flagged by system
- **FR83:** Development team can deploy updated ontology to production
- **FR84:** Development team can version ontology changes
- **FR85:** Development team can analyze impact of ontology changes on users

### Compliance & Audit

- **FR86:** System can embed disclaimers in all prediction outputs
- **FR87:** System can embed disclaimers in all recommendation outputs
- **FR88:** System can log prediction generation (timestamp, user, stock, output, confidence)
- **FR89:** System can log which historical event patterns contributed to predictions
- **FR90:** System can log knowledge graph state and ontology version used for predictions
- **FR91:** System can log portfolio recommendations delivered to users
- **FR92:** System can log backtesting executions
- **FR93:** System can log event alerts sent to users
- **FR94:** System can retain prediction logs for minimum 12 months
- **FR95:** System can provide audit trail for prediction accountability
- **FR96:** Users can view disclaimers explaining informational nature of platform
- **FR97:** Users can access terms of service and privacy policy

### User Account & Authentication

- **FR81:** Users can create new accounts with email and password
- **FR82:** Users can sign in to existing accounts
- **FR83:** Users can sign out of their accounts
- **FR84:** System can authenticate users via JWT tokens
- **FR85:** System can manage user sessions securely
- **FR86:** System can encrypt user data at rest
- **FR87:** System can encrypt user data in transit (HTTPS/TLS)
- **FR88:** Users can view their own user profile
- **FR89:** Users can update their account settings
- **FR90:** System can isolate user data (portfolios, preferences, history) per user account

### Data Pipeline & Orchestration

- **FR91:** System can orchestrate data pipeline via Airflow DAG
- **FR92:** System can schedule news crawler execution
- **FR93:** System can trigger event extraction from scraped news
- **FR94:** System can trigger knowledge graph updates with new events
- **FR95:** System can trigger prediction engine when knowledge graph updated
- **FR96:** System can monitor event alert system for similar events
- **FR97:** System can execute data pipeline on defined schedule

### Rate Limiting & Abuse Prevention

- **FR98:** System can rate limit prediction query requests per user
- **FR99:** System can rate limit portfolio recommendation requests per user
- **FR100:** System can rate limit backtesting execution requests per user
- **FR101:** System can throttle queries to prevent system abuse
- **FR102:** System can monitor for anomalous usage patterns
- **FR103:** System can prevent alert spam to users

### Real-Time Notifications & Supabase Integration

- **FR104:** Frontend can subscribe to PostgreSQL table changes via Supabase Realtime
- **FR105:** System can deliver browser notifications when backtesting jobs complete
- **FR106:** System can deliver browser notifications when portfolio recommendations complete
- **FR107:** Frontend UI updates in real-time when DB state changes (no polling required)
- **FR108:** Browser notifications follow Confluence-style UX pattern (accumulating, non-intrusive)

### Portfolio Recommendation Page

- **FR109:** Users can access dedicated portfolio recommendation page
- **FR110:** Users can generate portfolio recommendations via button click on dedicated page
- **FR111:** System displays accumulated portfolio recommendations sorted by most recent first
- **FR112:** Each recommendation shows creation timestamp and status indicator
- **FR113:** System displays warning message for outdated portfolio recommendations (>3 days old)
- **FR114:** Users can view full Markdown recommendation report by clicking row

### Unified Data Model

- **FR115:** System stores backtesting results with unified schema: content (Markdown), user_id, image_base64, timestamps, status
- **FR116:** System stores portfolio recommendations with unified schema: content (Markdown), user_id, image_base64, timestamps, status
- **FR117:** Status transitions managed by agents/backend: PENDING → IN_PROGRESS → COMPLETED/FAILED
- **FR118:** LLM-generated content stored as Markdown in `content` field
- **FR119:** Agents/backend services fully own data generation, status transitions, and database operations
- **FR120:** Frontend only subscribes to Supabase Realtime and renders UI (does not define schema or push data)

### Backtesting Results Page (Enhanced)

- **FR121:** Backtesting results page displays jobs in table/list format sorted by most recent first
- **FR122:** Clicking backtesting job row opens LLM-generated Markdown report on same page (not new page)
- **FR123:** Backtesting page updates in real-time via Supabase Realtime subscription
- **FR124:** Each backtesting job row shows: stock name, strategy, status, creation timestamp
- **FR125:** Backtesting Markdown reports include charts, tables, and performance metrics

### Data Collection & Storage (Added 2026-01-03)

- **FR126:** System can collect DART disclosures using 20 major report type APIs (6 categories) with structured field extraction
- **FR127:** System can store DART disclosure data in local PostgreSQL with dedicated schemas per report type
- **FR128:** Backtesting jobs include unique job_id (UUID) for tracking and reference across system
- **FR129:** Portfolio recommendation jobs include unique job_id (UUID) for tracking and reference across system
- **FR130:** Status values use Korean enum: 작업 전 (Before Processing), 처리 중 (In Progress), 완료 (Completed), 실패 (Failed)
- **FR131:** System can collect daily stock price data (OHLCV) for all universe stocks via scheduled pipeline

## Non-Functional Requirements

### Performance

**Response Time Requirements:**
- **NFR-P1:** Prediction query responses complete within 2 seconds under normal load
- **NFR-P2:** Chat interface message responses (non-prediction queries) complete within 500ms
- **NFR-P3:** Portfolio recommendation generation completes within 5 seconds
- **NFR-P4:** Backtesting execution for single stock completes within 10 seconds
- **NFR-P5:** Knowledge graph pattern matching queries complete within 1 second
- **NFR-P6:** Event alert generation and delivery occurs within 5 minutes of event detection

**Throughput Requirements:**
- **NFR-P7:** System supports minimum 100 concurrent users with <10% performance degradation
- **NFR-P8:** Prediction engine processes minimum 10 predictions per second
- **NFR-P9:** Event extraction pipeline processes minimum 1000 news articles per hour

**User Experience Performance:**
- **NFR-P10:** Chat interface displays typing indicators within 100ms of user query submission
- **NFR-P11:** Historical event timeline visualization loads within 1 second
- **NFR-P12:** Portfolio view updates within 500ms of user actions (add/remove stocks)

### Security

**Data Protection:**
- **NFR-S1:** All user data encrypted at rest using AES-256 or equivalent
- **NFR-S2:** All data in transit encrypted using TLS 1.2 or higher (HTTPS)
- **NFR-S3:** User passwords hashed using bcrypt or equivalent (minimum 10 rounds)
- **NFR-S4:** JWT tokens expire after 24 hours and require re-authentication
- **NFR-S5:** Database credentials stored in secure environment variables (not hardcoded)

**Access Control:**
- **NFR-S6:** User data isolation enforced at database query level (users cannot access other users' data)
- **NFR-S7:** Development team ontology management interface requires separate authentication
- **NFR-S8:** Session tokens invalidated on logout
- **NFR-S9:** Failed login attempts rate-limited (max 5 attempts per 15 minutes per account)

**Input Validation & Protection:**
- **NFR-S10:** All user inputs sanitized to prevent SQL injection attacks
- **NFR-S11:** All user inputs validated to prevent XSS (Cross-Site Scripting) attacks
- **NFR-S12:** API endpoints protected against CSRF (Cross-Site Request Forgery)
- **NFR-S13:** File uploads (if implemented) restricted by type and size

**Audit & Compliance:**
- **NFR-S14:** Security-relevant events logged (authentication attempts, data access, configuration changes)
- **NFR-S15:** Audit logs retained for minimum 12 months
- **NFR-S16:** Security patches applied within 30 days of release for critical vulnerabilities

### Reliability

**Availability:**
- **NFR-R1:** System uptime target of 99% (allows ~7 hours downtime per month)
- **NFR-R2:** Planned maintenance windows communicated to users 48 hours in advance
- **NFR-R3:** Critical services (authentication, event alerts) prioritized during partial outages

**Data Integrity:**
- **NFR-R4:** Prediction logs persist reliably (no data loss during normal operation)
- **NFR-R5:** User portfolio data changes atomic (all-or-nothing updates)
- **NFR-R6:** Knowledge graph updates transactional (rollback on failure)
- **NFR-R7:** Database backups performed daily with 30-day retention

**Fault Tolerance:**
- **NFR-R8:** Event extraction failures logged and retried (up to 3 attempts with exponential backoff)
- **NFR-R9:** External API failures (DART, KIS, Naver) handled gracefully with user-friendly error messages
- **NFR-R10:** Prediction engine degradation graceful (reduced confidence or "unavailable" status vs. system crash)

**Monitoring & Recovery:**
- **NFR-R11:** Critical system failures trigger alerts to development team within 5 minutes
- **NFR-R12:** System health checks run every 60 seconds for core services
- **NFR-R13:** Recovery time objective (RTO) of 4 hours for complete system restoration

### Scalability

**User Growth:**
- **NFR-SC1:** System architecture supports 10x user growth (from initial capacity) with <10% performance degradation
- **NFR-SC2:** Database queries optimized to handle 100,000+ user accounts
- **NFR-SC3:** Horizontal scaling possible for stateless services (frontend, LLM service APIs)

**Data Growth:**
- **NFR-SC4:** Knowledge graph scales to support 10,000+ events per month without performance degradation
- **NFR-SC5:** MongoDB supports storage of 1 million+ news articles with indexed queries
- **NFR-SC6:** Prediction log storage scales to 100,000+ predictions per month

**Traffic Patterns:**
- **NFR-SC7:** System handles traffic spikes of 3x normal load during market events (e.g., major announcements)
- **NFR-SC8:** Event alert system scales to send 10,000+ simultaneous notifications
- **NFR-SC9:** Airflow DAG scales to process increased event volume without manual reconfiguration

### Integration

**External API Reliability:**
- **NFR-I1:** System tolerates DART API downtime up to 1 hour with queued retries
- **NFR-I2:** System tolerates KIS OpenAPI downtime up to 1 hour with cached fallback data
- **NFR-I3:** System tolerates Naver Finance downtime up to 1 hour with graceful degradation

**API Response Handling:**
- **NFR-I4:** External API timeouts configured at 30 seconds maximum
- **NFR-I5:** Rate limits respected for external APIs (DART, KIS, Naver) with backoff logic
- **NFR-I6:** External API errors logged with sufficient detail for debugging

**Data Freshness:**
- **NFR-I7:** News data refreshed every 1 hour during market hours
- **NFR-I8:** DART disclosure data checked every 30 minutes during business days
- **NFR-I9:** Stock price data (KIS) updated every 5 minutes during market hours

### Maintainability

**Code Quality:**
- **NFR-M1:** Critical business logic covered by automated tests (minimum 70% coverage goal)
- **NFR-M2:** Code follows established style guides for Python (PEP 8) and TypeScript (ESLint)
- **NFR-M3:** Major architectural decisions documented in architecture decision records (ADRs)

**Operational Maintainability:**
- **NFR-M4:** Ontology updates deployable without system downtime
- **NFR-M5:** Knowledge graph schema changes support backward compatibility for 1 release cycle
- **NFR-M6:** Logs structured with sufficient context for troubleshooting (user ID, timestamp, action, result)

**Observability:**
- **NFR-M7:** Key metrics tracked: prediction accuracy, event extraction accuracy, system response times, error rates
- **NFR-M8:** Dashboards provide real-time visibility into system health and usage patterns
- **NFR-M9:** Alerting configured for anomalies: prediction error spikes, extraction failures, performance degradation

### Usability

**Chat Interface:**
- **NFR-U1:** Chat interface supports Korean language input and output
- **NFR-U2:** Error messages provide actionable guidance (not technical jargon)
- **NFR-U3:** System provides clear feedback for long-running operations (backtesting, recommendations)

**Learnability:**
- **NFR-U4:** First-time users can query a stock prediction within 2 minutes of account creation
- **NFR-U5:** System provides contextual help within chat interface for common actions
- **NFR-U6:** Disclaimer visibility ensures users understand informational positioning
