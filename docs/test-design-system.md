# System-Level Test Design - Stockelper

**Date:** 2025-12-23
**Author:** Oldman
**Phase:** Solutioning (Phase 3) - Testability Review
**Status:** Draft

---

## Executive Summary

**Testability Decision:** **CONCERNS** - System is testable but requires critical prerequisite work (LangChain v1 migration) before implementation phase.

**Critical Blocker:**
- **🚨 LangChain v1.0+ Migration Required:** All LangGraph agents must be refactored to v1.0+ patterns before test implementation. Current v0.x patterns will break during testing.

**Key Findings:**
- **Controllability:** PASS with CONCERNS (API seeding possible, but LangChain v1 migration blocks test implementation)
- **Observability:** PASS (logging exists, prediction audit trail design needed)
- **Reliability:** CONCERNS (parallel test execution needs careful design for brownfield Neo4j/PostgreSQL/MongoDB state management)

**Recommendation for Gate Check:**
- **CONCERNS** → Proceed with Epic 0 (LangChain v1 Migration) as mandatory Phase 0 prerequisite
- Complete Epic 0 before implementing test framework or epic-level testing
- Re-assess testability after Epic 0 completion

---

## Testability Assessment

### Controllability: PASS with CONCERNS

**✅ System State Control:**
- API seeding available for all 3 databases:
  - PostgreSQL: User accounts, portfolios, authentication data
  - MongoDB: News articles, raw financial data (deduplication tracking)
  - Neo4j: Events, knowledge graph relationships, temporal patterns
- FastAPI backend supports dependency injection for mockable services
- Next.js frontend with API routes allows test data injection

**✅ External Dependencies Mockable:**
- DART API (financial disclosures) - HTTP mocking supported
- KIS OpenAPI (market data) - HTTP mocking supported
- Naver Finance (news scraping) - HTTP mocking supported
- OpenAI API (LLM inference) - HTTP mocking supported

**✅ Error Condition Triggering:**
- Fault injection via API route mocking (Next.js)
- Chaos engineering possible via Docker network simulation
- External API failures testable via HTTP 500/503 mocking

**🚨 CRITICAL CONCERN - LangChain v1 Migration:**
- **Current State:** LangGraph v0.x patterns (`langgraph.prebuilt.create_react_agent`)
- **Required State:** LangChain v1.0+ patterns (`langchain.agents.create_agent`)
- **Impact on Testing:**
  - All 6 agents (SupervisorAgent, MarketAnalysisAgent, FundamentalAnalysisAgent, TechnicalAnalysisAgent, PortfolioAnalysisAgent, InvestmentStrategyAgent) require refactoring
  - Message handling adopts `content_blocks` property (breaking change)
  - Test mocks for agent interactions must follow new v1 patterns
  - Integration tests cannot be written until migration completes
- **Mitigation:** Epic 0 must complete before any agent testing
- **Owner:** Development team
- **Timeline:** Phase 0 prerequisite (blocks all test implementation)

---

### Observability: PASS

**✅ State Inspection:**
- Neo4j knowledge graph queryable for validation (events, relationships, subgraphs)
- PostgreSQL audit logs for predictions, recommendations, backtesting (FR71-FR78)
- MongoDB stores raw news articles for extraction verification
- API endpoints expose system state for assertions

**✅ Deterministic Results:**
- Prediction engine uses controlled event data → deterministic outputs
- Event extraction with fixed test articles → reproducible classifications
- Neo4j temporal pattern matching with seed data → stable predictions

**✅ NFR Validation Approach:**
- **Security:** Playwright E2E for auth/authz, SQL injection, XSS validation
- **Performance:** k6 load testing for SLO/SLA enforcement (p95 <500ms, error rate <1%)
- **Reliability:** Playwright E2E + API tests for error handling, retries, health checks
- **Maintainability:** CI tools (coverage ≥70%, duplication <5%, npm audit)

**⚠️ Design Needed:**
- Prediction audit logging schema (PostgreSQL table with 12-month retention)
- Telemetry headers (Server-Timing, X-Trace-ID) for observability validation
- Structured logging format for correlation across microservices

---

### Reliability: CONCERNS

**⚠️ Parallel Test Execution Concerns:**
- **Multi-Database State Pollution Risk:**
  - 3 databases (PostgreSQL, MongoDB, Neo4j) require coordinated cleanup
  - Knowledge graph temporal data (date-indexed events) must isolate by test run
  - Event deduplication in MongoDB may conflict across parallel tests
  - **Mitigation Strategy:**
    - Use unique event IDs per test (`faker.datatype.uuid()`)
    - Test-scoped date ranges for Neo4j temporal queries
    - PostgreSQL transaction rollback for user data
    - MongoDB collection per test worker (shard by worker ID)

**✅ Reproducible Failures:**
- HAR capture for network requests (deterministic API mocking)
- Seed data with `faker` for reproducible test scenarios
- Deterministic waits (`waitForResponse`) instead of hard timeouts

**✅ Component Isolation:**
- Microservices architecture supports independent testing
- Docker containers provide test environment isolation
- Neo4j supports graph database snapshots for rollback

**⚠️ Brownfield Complexity:**
- Existing implementations may have hidden state dependencies
- Legacy test patterns (if any) may not follow parallel-safe principles
- Requires codebase review before test framework setup

---

## Architecturally Significant Requirements (ASRs)

### Critical (Score 9) - BLOCKER

| ASR ID | Requirement | Category | Probability | Impact | Score | Testability Challenge | Mitigation |
|--------|------------|----------|-------------|--------|-------|----------------------|------------|
| ASR-001 | **LangChain v1.0+ Migration** | TECH | 3 | 3 | 9 | All agent tests unwritable until migration complete. Breaking changes in agent creation, message handling, tool definitions. | **MANDATORY**: Epic 0 completion before test implementation. Post-migration, validate all 6 agents + portfolio multi-agent system with integration tests. |

### High Priority (Score 6-8)

| ASR ID | Requirement | Category | Probability | Impact | Score | Testability Challenge | Testing Approach |
|--------|------------|----------|-------------|--------|-------|----------------------|------------------|
| ASR-002 | Prediction queries <2s (NFR-P1) | PERF | 3 | 2 | 6 | Real-world event patterns complex; synthetic test data may not reflect production load. | k6 load testing with realistic event graph seeded from production-like data. P95 latency target <2s enforced in CI. |
| ASR-003 | 99% uptime (NFR-R1) | PERF | 2 | 3 | 6 | Uptime validation requires long-running tests (days/weeks). | Health check endpoint monitoring (E2E validation). Chaos engineering for failure scenarios (circuit breaker, retries). |
| ASR-004 | Data encryption AES-256 (NFR-S1) | SEC | 2 | 3 | 6 | Encryption at-rest validation requires database-level inspection. | Playwright E2E validates secrets never logged/exposed. Integration tests verify database encryption configuration. |
| ASR-005 | Event extraction accuracy | DATA | 3 | 2 | 6 | LLM-based extraction non-deterministic; hard to assert exact outputs. | Golden dataset tests (human-labeled news articles → expected events). Confidence threshold validation (ontology category accuracy ≥85%). |

### Medium Priority (Score 4-5)

| ASR ID | Requirement | Category | Score | Testing Approach |
|--------|------------|----------|-------|------------------|
| ASR-006 | 10x scalability (NFR-SC1) | PERF | 4 | k6 stress testing to identify breaking point (ramp up to 1000 concurrent users). |
| ASR-007 | Multi-database consistency | DATA | 4 | Integration tests validate PostgreSQL, MongoDB, Neo4j state synchronization after pipeline execution. |
| ASR-008 | Airflow DAG orchestration (FR91-FR97) | OPS | 4 | Airflow DAG testing with mocked tasks. Validate task dependencies and retry logic. |

---

## Test Levels Strategy

Based on architecture (5-microservice brownfield, AI/ML-heavy, multi-database):

### Recommended Split: 40% E2E / 30% API / 20% Component / 10% Unit

**Rationale:**
- **E2E (40%):** High proportion due to:
  - Multi-system integration critical (5 microservices + 3 databases)
  - User journeys span Frontend → LLM → KG → Airflow
  - Chat interface quality is **CRITICAL success factor** (UX requirement)
  - Predictions must validate end-to-end (event extraction → Neo4j → prediction → chat display)
- **API (30%):** Business logic validation:
  - Event extraction accuracy (news → events → ontology classification)
  - Prediction confidence calculation (pattern strength → confidence %)
  - Portfolio recommendations (event-based rationale generation)
  - Backtesting engine (historical return calculation, Sharpe Ratio)
- **Component (20%):** Frontend UI components:
  - Event timeline visualization
  - Prediction cards with confidence indicators
  - Portfolio recommendation page (button-triggered, async UX)
  - Notification center dropdown
- **Unit (10%):** Pure business logic only:
  - Risk scoring (probability × impact)
  - Date-based event filtering
  - Discount/tax calculations (if applicable)

### Test Environment Requirements

**Local Development:**
- Docker Compose with all 5 services + 3 databases
- Test-scoped PostgreSQL database (`stockelper_test`)
- Test-scoped MongoDB collection (`news_articles_test`)
- Test-scoped Neo4j graph database (`test` database, not `neo4j`)
- Playwright + pytest frameworks installed

**CI Pipeline:**
- GitHub Actions or equivalent
- Parallel workers: 4 (for Playwright test execution)
- Database containers ephemeral (create → test → destroy per workflow run)
- k6 for performance testing (separate job, runs on PRs to main)

**Staging:**
- Production-like environment for smoke tests
- Real DART/KIS/Naver API integrations (rate-limited test accounts)
- Separate knowledge graph for staging (not production data)

---

## NFR Testing Approach

### Security (NFR-S1 to S16)

**Test Approach:** Playwright E2E + Security Tools

**P0 Tests (Critical - Run on every commit):**
- `auth-unauthenticated-redirect.spec.ts` - Verify unauthenticated users cannot access protected routes (redirect to /login)
- `auth-jwt-expiry.spec.ts` - JWT tokens expire after 24 hours (NFR-S4), API returns 401
- `auth-rbac-portfolio-isolation.spec.ts` - Users can only access their own portfolios (NFR-S6), 403 for unauthorized access
- `security-sql-injection.spec.ts` - SQL injection blocked in search endpoints (NFR-S10), no database exposure
- `security-xss-sanitization.spec.ts` - XSS attempts sanitized in user inputs (NFR-S11), scripts escaped not executed
- `security-secrets-logging.spec.ts` - Passwords/API keys never logged or exposed in console/network/errors (NFR-S5)

**P1 Tests (High - Run on PR to main):**
- `security-csrf-protection.spec.ts` - CSRF protection on state-changing endpoints (NFR-S12)
- `security-rate-limiting-login.spec.ts` - Failed login attempts rate-limited (max 5 per 15 min - NFR-S9)
- `security-audit-logging.spec.ts` - Security events logged (auth attempts, data access - NFR-S14)

**Tools:**
- Playwright for E2E security validation
- OWASP ZAP for automated vulnerability scanning (CI job)
- npm audit for dependency vulnerabilities (CI job, no critical/high allowed)

**Gate Criteria:** ✅ PASS if all P0 security tests green + npm audit clean

---

### Performance (NFR-P1 to P12)

**Test Approach:** k6 Load Testing (NOT Playwright)

**SLO/SLA Thresholds:**
- P95 request duration <500ms (chat responses - NFR-P2)
- P95 prediction latency <2s (NFR-P1)
- P95 portfolio recommendation <5s (NFR-P3)
- Error rate <1% under load
- 100+ concurrent users with <10% degradation (NFR-P7)

**k6 Test Scenarios:**

```javascript
// tests/nfr/performance.k6.js
export const options = {
  stages: [
    { duration: '1m', target: 50 },   // Ramp up
    { duration: '3m', target: 50 },   // Sustained load
    { duration: '1m', target: 100 },  // Spike to 100 users
    { duration: '3m', target: 100 },  // Sustained spike
    { duration: '1m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],     // P95 <2s for predictions
    'http_req_duration{endpoint:chat}': ['p(95)<500'], // P95 <500ms for chat
    'http_req_duration{endpoint:recommendations}': ['p(95)<5000'], // P95 <5s
    errors: ['rate<0.01'],  // Error rate <1%
  },
};
```

**Test Endpoints:**
- `/api/chat` (chat messages - NFR-P2: <500ms)
- `/api/predictions` (stock predictions - NFR-P1: <2s)
- `/api/recommendations` (portfolio recommendations - NFR-P3: <5s)
- `/api/backtesting` (backtesting execution - NFR-P4: <10s)

**Gate Criteria:** ✅ PASS if all SLO/SLA thresholds met with k6 profiling evidence

---

### Reliability (NFR-R1 to R13)

**Test Approach:** Playwright E2E + API Tests

**P0 Tests:**
- `reliability-500-error-graceful.spec.ts` - API 500 error shows user-friendly message + retry button (not crash)
- `reliability-retry-logic.spec.ts` - API client retries on transient failures (3 attempts with exponential backoff - NFR-R8)
- `reliability-health-check.spec.ts` - `/api/health` endpoint returns service status (database, cache, queue UP)
- `reliability-circuit-breaker.spec.ts` - Circuit breaker opens after 5 failures (fallback UI, stop retries)

**P1 Tests:**
- `reliability-offline-handling.spec.ts` - Network disconnection graceful ("You are offline" message)
- `reliability-rate-limiting-429.spec.ts` - 429 responses handled (Retry-After header respected)

**Gate Criteria:** ✅ PASS if error handling, retries, health checks validated

---

### Maintainability (NFR-M1 to M9)

**Test Approach:** CI Tools (NOT Playwright)

**CI Jobs:**

```yaml
# .github/workflows/nfr-maintainability.yml
jobs:
  test-coverage:
    steps:
      - run: pytest --cov=src --cov-report=json
      - run: |
          COVERAGE=$(jq '.totals.percent_covered' coverage.json)
          if (( $(echo "$COVERAGE < 70" | bc -l) )); then
            echo "❌ FAIL: Coverage $COVERAGE% below 70% threshold"
            exit 1
          fi

  code-duplication:
    steps:
      - run: npx jscpd src/ --threshold 5

  vulnerability-scan:
    steps:
      - run: npm audit --audit-level=moderate
```

**Playwright Observability Validation:**
- `observability-error-tracking.spec.ts` - Errors captured by monitoring (Sentry integration validated)
- `observability-telemetry-headers.spec.ts` - Server-Timing headers present for APM
- `observability-structured-logging.spec.ts` - X-Trace-ID in responses (correlation IDs)

**Gate Criteria:** ✅ PASS if coverage ≥70%, duplication <5%, no critical vulnerabilities, observability validated

---

## Test Environment Requirements

### Docker Compose Test Stack

```yaml
# docker-compose.test.yml
services:
  postgres-test:
    image: postgres:15
    environment:
      POSTGRES_DB: stockelper_test
      POSTGRES_USER: test
      POSTGRES_PASSWORD: testpass

  mongodb-test:
    image: mongo:7
    environment:
      MONGO_INITDB_DATABASE: stockelper_test

  neo4j-test:
    image: neo4j:5.11
    environment:
      NEO4J_AUTH: neo4j/testpass
      NEO4J_PLUGINS: '["apoc"]'
      NEO4J_dbms_default__database: test
```

### Required Tools & Frameworks

**Frontend Testing:**
- Playwright 1.40+ (E2E, component tests)
- @playwright/test (TypeScript support)
- faker-js (unique test data generation)

**Backend Testing:**
- pytest 7.4+ (Python unit/integration tests)
- pytest-asyncio (async test support)
- pytest-cov (coverage reporting)
- httpx (API client for integration tests)

**Performance Testing:**
- k6 (load/stress/spike testing)
- Artillery (alternative for complex scenarios)

**Security Testing:**
- OWASP ZAP (vulnerability scanning)
- npm audit (dependency scanning)
- Snyk (optional: real-time vulnerability monitoring)

**CI/CD:**
- GitHub Actions (or equivalent)
- Docker + Docker Compose
- jscpd (code duplication detection)

---

## Testability Concerns

### 🚨 CRITICAL BLOCKER

**TC-001: LangChain v1.0+ Migration Incomplete**

**Risk Category:** TECH
**Probability:** 3 (Certain - documented in architecture.md)
**Impact:** 3 (Critical - blocks all agent testing)
**Score:** 9 (BLOCKER)

**Description:**
- All 6 LangGraph agents use v0.x patterns (`langgraph.prebuilt.create_react_agent`)
- LangChain v1.0+ requires migration to `langchain.agents.create_agent`
- Message handling adopts `content_blocks` property (breaking change)
- Tool definitions may require updates for v1 compatibility

**Impact on Testability:**
- Cannot write integration tests for agents until migration complete
- Agent mocking strategies differ between v0.x and v1.0+
- Test fixtures for multi-agent system require v1 patterns
- Epic 1-5 testing blocked until Epic 0 (migration) completes

**Mitigation:**
- **MANDATORY:** Epic 0 (LangChain v1 Migration & Model Upgrade) must complete before any test implementation
- After Epic 0: Validate all 6 agents with integration tests
- Post-migration: Update test-design-system.md with v1-specific testability review

**Owner:** Development team
**Timeline:** Phase 0 prerequisite (before implementation phase)
**Status:** OPEN - blocks release to implementation phase

---

### ⚠️ HIGH CONCERN

**TC-002: Multi-Database State Pollution in Parallel Tests**

**Risk Category:** DATA
**Probability:** 2 (Possible - brownfield complexity)
**Impact:** 2 (Degraded - test flakiness, false failures)
**Score:** 4 (CONCERN)

**Description:**
- 3 databases (PostgreSQL, MongoDB, Neo4j) require coordinated cleanup
- Neo4j temporal data (date-indexed events) may overlap across parallel tests
- Event deduplication in MongoDB may conflict if tests use same article IDs

**Impact on Testability:**
- Parallel test execution may produce flaky failures
- Test isolation difficult to maintain across 3 database systems
- Cleanup logic complex (require PostgreSQL transactions, MongoDB collection scoping, Neo4j graph snapshots)

**Mitigation:**
- Test-scoped unique identifiers (`faker.datatype.uuid()` for all entities)
- PostgreSQL: Use transactions with rollback in fixtures
- MongoDB: Shard collections by test worker ID
- Neo4j: Test-scoped date ranges for temporal queries
- Integration test: `*framework` workflow sets up parallel-safe fixtures

**Owner:** Test Architect / QA Lead
**Timeline:** Before Sprint 0 test framework setup
**Status:** OPEN - requires design during `*framework` workflow

---

### ⚠️ MEDIUM CONCERN

**TC-003: Event Extraction Non-Determinism (LLM-Based)**

**Risk Category:** DATA
**Probability:** 2 (Possible - LLM outputs vary)
**Impact:** 2 (Degraded - hard to assert exact outputs)
**Score:** 4 (CONCERN)

**Description:**
- Event extraction uses gpt-4.1 (post-Epic 0) for classification
- LLM outputs non-deterministic even with `temperature=0`
- Exact event descriptions may vary run-to-run

**Impact on Testability:**
- Cannot assert exact event text (e.g., `expect(event.description).toBe("Samsung announces...")`)
- Confidence thresholds for ontology classification may fluctuate

**Mitigation:**
- **Golden dataset tests:** Human-labeled news articles → expected ontology categories (assert category, not exact text)
- **Confidence threshold validation:** Assert `event.confidence ≥ 0.85` (not exact value)
- **Pattern matching:** Use regex for flexible assertions (`expect(event.description).toMatch(/Samsung.*announces/)`)
- **Mocked LLM responses:** For deterministic tests, mock OpenAI API with fixed responses

**Owner:** QA Lead
**Timeline:** Epic 1 (Event Automation) testing
**Status:** OPEN - requires golden dataset creation

---

## Recommendations for Sprint 0

Before implementing Epic 1-5 tests, complete the following foundational work:

### 1. Complete Epic 0 (LangChain v1 Migration) - MANDATORY

**Critical Prerequisite:**
- Migrate all 6 agents to LangChain v1.0+ patterns
- Update model references from gpt-4o to gpt-4.1
- Validate multi-agent system integration
- Run Epic 0 Story 0.9 (Integration Testing) to ensure no regressions

**Test Readiness Validation:**
- After Epic 0 completion, re-run this testability review
- Update test-design-system.md with v1-specific patterns
- Confirm agent mocking strategies for v1

---

### 2. Run `*framework` Workflow (Test Infrastructure Setup)

**Objectives:**
- Install Playwright 1.40+ with TypeScript support
- Install pytest 7.4+ with async support and coverage
- Configure Docker Compose test stack (PostgreSQL, MongoDB, Neo4j)
- Set up parallel-safe fixtures (database cleanup, unique data generation)
- Configure CI pipeline (GitHub Actions with 4 parallel workers)

**Deliverables:**
- `playwright.config.ts` with environment switching, timeout standards
- `pytest.ini` with coverage thresholds (≥70%)
- `docker-compose.test.yml` with ephemeral database containers
- `playwright/support/fixtures/` with database, auth, network fixtures
- `.github/workflows/test.yml` with Playwright + pytest + k6 jobs

---

### 3. Run `*ci` Workflow (CI Pipeline & Burn-In)

**Objectives:**
- Configure CI pipeline with staged jobs (lint → unit → integration → e2e)
- Set up burn-in loops for flaky test detection
- Configure artifact collection (HAR files, traces, screenshots)
- Implement selective test execution (run only tests affected by changes)

**Deliverables:**
- CI pipeline with P0 tests on every commit (<10 min)
- P1 tests on PR to main (<30 min)
- P2/P3 tests nightly or weekly
- Burn-in job: Run P0 tests 10x to detect flakiness

---

### 4. Create Golden Dataset for Event Extraction

**Objectives:**
- Collect 50-100 Korean news articles (Naver Finance, DART disclosures)
- Human-label expected ontology categories for each article
- Store in `tests/fixtures/golden-dataset/` directory
- Use for event extraction accuracy validation

**Deliverables:**
- `golden-dataset.json` with articles and expected classifications
- Integration test: `event-extraction-accuracy.spec.ts` validating ≥85% accuracy

---

### 5. Design Prediction Audit Logging Schema

**Objectives:**
- Define PostgreSQL schema for `prediction_audit_log` table (FR71-FR73)
- Include: timestamp, user_id, stock_ticker, prediction_type, confidence, historical_events_used, kg_snapshot, ontology_version
- Set up 12-month retention policy (automated cleanup job)
- Create observability validation tests

**Deliverables:**
- Database migration: `create_prediction_audit_log.sql`
- Integration test: `prediction-audit-logging.spec.ts` validates log creation
- Playwright test: `observability-telemetry-headers.spec.ts` validates Server-Timing headers

---

## Quality Gate Criteria

Before proceeding to Implementation Phase:

- [x] **Epic 0 Complete:** LangChain v1 migration validated with integration tests
- [ ] **Test Framework Installed:** Playwright + pytest + k6 configured
- [ ] **CI Pipeline Operational:** P0 tests run on every commit (<10 min)
- [ ] **Parallel-Safe Fixtures:** Database cleanup and unique data generation working
- [ ] **Golden Dataset Created:** Event extraction accuracy baseline established
- [ ] **Audit Logging Schema Deployed:** Prediction logging validated in integration tests

**Gate Decision:** **CONCERNS** → Epic 0 must complete before PASS

---

## Next Steps

1. **Complete Epic 0 (LangChain v1 Migration)** - MANDATORY Phase 0 prerequisite
2. **Run `/bmad:bmm:workflows:testarch-framework`** - Set up Playwright + pytest infrastructure
3. **Run `/bmad:bmm:workflows:testarch-ci`** - Configure CI pipeline with burn-in
4. **Create Golden Dataset** - 50-100 labeled news articles for event extraction accuracy
5. **Design Audit Logging** - PostgreSQL schema + retention policy + observability tests
6. **Re-Assess Testability** - Update test-design-system.md post-Epic 0
7. **Run `/bmad:bmm:workflows:check-implementation-readiness`** - Validate PRD + Architecture + Epics + UX + Test Design

---

**Generated by**: BMad TEA Agent - Test Architect Module
**Workflow**: `.bmad/bmm/testarch/test-design`
**Version**: 4.0 (BMad v6)
