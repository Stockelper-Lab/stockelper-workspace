# Story 0.1: Update LangChain Dependencies and Core Imports

Status: ready-for-dev

## Story

As a developer,
I want to update package dependencies and import statements to LangChain v1 patterns,
so that the codebase is ready for LangChain v1 agent migration.

## Acceptance Criteria

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

## Tasks / Subtasks

### Task 1: Update requirements.txt with LangChain v1.0+ Dependencies (AC: All ACs)
- [ ] Research LangChain v1.0+ version compatibility
  - Check official LangChain v1.0+ documentation for minimum versions
  - Verify `langchain` >= 1.0.0 compatibility with `langchain-openai`
  - Verify `langgraph` >= 1.0.0 compatibility with new agent patterns
  - Document langchain-classic package purpose (legacy feature support)
- [ ] Update requirements.txt with LangChain v1.0+ package versions
  - Add `langchain-classic` for legacy feature support
  - Update `langchain` to v1.0+ (specify minimum: `langchain>=1.0.0`)
  - Update `langgraph` to v1.0+ (specify minimum: `langgraph>=1.0.0`)
  - Update `langchain-openai` to v1.0+ compatible version (specify minimum: `langchain-openai>=1.0.0`)
  - Preserve all other existing dependencies
- [ ] Test dependency installation
  - Run `pip install -r requirements.txt` in clean virtual environment
  - Verify no dependency conflicts during installation
  - Document any version constraint issues and resolutions

### Task 2: Update Agent Import Statements (AC: All ACs)
- [ ] Identify all agent files requiring import updates
  - List all agent files: `/stockelper-llm/src/multi_agent/*/agent.py`
  - Agents to update:
    - `supervisor_agent/agent.py`
    - `market_analysis_agent/agent.py`
    - `fundamental_analysis_agent/agent.py`
    - `technical_analysis_agent/agent.py`
    - `portfolio_analysis_agent/agent.py`
    - `investment_strategy_agent/agent.py`
- [ ] Update namespace imports in all agent files
  - Replace `from langgraph.prebuilt import create_react_agent` with `from langchain.agents import create_agent`
  - Update any other v0.x imports to v1.0+ equivalents per official migration guide
  - **DO NOT** change agent logic/implementation (imports only)
  - Document all import changes made
- [ ] Verify import statements execute without errors
  - Test each agent file: `python -c "from multi_agent.{agent_name} import agent"`
  - Verify no runtime import errors
  - Verify no deprecation warnings appear
  - Document any unexpected warnings or errors

### Task 3: Integration Testing and Validation (AC: Testing requirements)
- [ ] Run existing unit tests
  - Execute pytest for all agent import modules
  - Verify all tests pass
  - Document any test failures and root causes
- [ ] Validate new import patterns
  - Execute `python -c "from langchain.agents import create_agent"` successfully
  - Test import of all 6 agent modules
  - Verify no deprecation warnings in test output
- [ ] Document migration completion
  - List all updated files with changes made
  - Note any issues encountered and resolutions
  - Confirm all acceptance criteria met

## Dev Notes

### Critical Context: Phase 0 Prerequisite

⚠️ **THIS IS A CRITICAL BLOCKING STORY** - LangChain v1.0+ migration is a **MANDATORY prerequisite** for all feature work. Epic 0 must complete before implementing any Epic 1-5 stories.

**Why This Migration is Critical:**
- LangChain recently updated to v1.0+ with breaking API changes
- All multi-agent system patterns have changed significantly
- Existing code uses deprecated `create_react_agent` from langgraph.prebuilt
- New code MUST use `langchain.agents.create_agent()` pattern
- Failure to migrate blocks all chat interface functionality (FR48-FR56)

### Architecture Context

**Repository:** `stockelper-llm` (Backend LLM Service)

**Current State:**
- LangChain v0.x patterns in use (deprecated)
- 6 agents using `langgraph.prebuilt.create_react_agent()`
- Chat interface depends on multi-agent system
- **Blocking:** Cannot implement predictions, recommendations, or chat features without migration

**Target State:**
- LangChain v1.0+ patterns throughout
- All agents using `langchain.agents.create_agent()`
- `langchain-classic` package added for legacy feature compatibility
- Import statements updated across all agent files

**Multi-Agent System Architecture:**
```
SupervisorAgent (coordinator)
├── MarketAnalysisAgent (news search, sentiment analysis)
├── FundamentalAnalysisAgent (financial analysis)
├── TechnicalAnalysisAgent (Prophet + ARIMA predictions)
├── PortfolioAnalysisAgent (portfolio recommendations)
└── InvestmentStrategyAgent (strategy generation)
```

### Technical Requirements

**LangChain v1.0+ Migration Guidelines:**

**1. Package Dependencies (requirements.txt):**
```python
# NEW - Add langchain-classic for legacy features
langchain-classic>=1.0.0

# UPDATE - Core LangChain packages to v1.0+
langchain>=1.0.0          # (previously: langchain~=0.x)
langgraph>=1.0.0          # (previously: langgraph~=0.x)
langchain-openai>=1.0.0   # (previously: langchain-openai~=0.x)

# PRESERVE - All other existing dependencies unchanged
fastapi==0.115.12
uvicorn==0.33.0
# ... (keep all others as-is)
```

**2. Import Statement Changes:**
```python
# OLD (v0.x - REMOVE)
from langgraph.prebuilt import create_react_agent

# NEW (v1.0+ - ADD)
from langchain.agents import create_agent
```

**3. Agent Files to Update (imports only, DO NOT change logic):**
- `/stockelper-llm/src/multi_agent/supervisor_agent/agent.py`
- `/stockelper-llm/src/multi_agent/market_analysis_agent/agent.py`
- `/stockelper-llm/src/multi_agent/fundamental_analysis_agent/agent.py`
- `/stockelper-llm/src/multi_agent/technical_analysis_agent/agent.py`
- `/stockelper-llm/src/multi_agent/portfolio_analysis_agent/agent.py`
- `/stockelper-llm/src/multi_agent/investment_strategy_agent/agent.py`

### File Structure Requirements

**Directory Structure (from source-tree-analysis.md):**
```
stockelper-llm/
├── requirements.txt                          # UPDATE: Add LangChain v1.0+ deps
├── src/
│   └── multi_agent/
│       ├── supervisor_agent/
│       │   └── agent.py                      # UPDATE: Import statements
│       ├── market_analysis_agent/
│       │   └── agent.py                      # UPDATE: Import statements
│       ├── fundamental_analysis_agent/
│       │   └── agent.py                      # UPDATE: Import statements
│       ├── technical_analysis_agent/
│       │   └── agent.py                      # UPDATE: Import statements
│       ├── portfolio_analysis_agent/
│       │   └── agent.py                      # UPDATE: Import statements
│       └── investment_strategy_agent/
│           └── agent.py                      # UPDATE: Import statements
```

### Library & Framework Requirements

**LangChain v1.0+ Official Documentation:**
- Reference: https://python.langchain.com/docs/introduction/
- Migration Guide: Follow official v1.0 migration documentation
- Key Changes:
  - Agent creation: `langgraph.prebuilt.create_react_agent` → `langchain.agents.create_agent`
  - Namespace reorganization: imports moved to `langchain.agents` module
  - Legacy features: `langchain-classic` package for backward compatibility

**Version Constraints:**
- Python: 3.12+ (already established in project)
- LangChain: >= 1.0.0 (MUST be v1.0+)
- LangGraph: >= 1.0.0 (MUST be v1.0+)
- LangChain-OpenAI: >= 1.0.0 (MUST be v1.0+ compatible)

**Critical Dependencies to Preserve:**
- FastAPI: 0.115.12 (existing)
- Neo4j Python Driver: 5.11+ (existing)
- PyMongo: 4.5+ (existing)
- All other existing packages (DO NOT modify)

### Testing Requirements

**Unit Test Execution:**
```bash
# Verify all agent imports work
cd stockelper-llm
pytest src/multi_agent/*/test_*.py -v

# Test specific import statement
python -c "from langchain.agents import create_agent"

# Verify no deprecation warnings
python -c "import warnings; warnings.filterwarnings('error'); from multi_agent.supervisor_agent.agent import *"
```

**Expected Outcomes:**
- All pytest tests pass (100% pass rate required)
- No `ImportError` exceptions
- No `DeprecationWarning` messages
- `pip install` completes without conflicts

**Test Coverage:**
- Verify each of 6 agent files imports successfully
- Validate `create_agent` function available from `langchain.agents`
- Confirm langchain-classic package installed

### Project Context Reference

**Related Architecture Decisions:**
- [Source: docs/architecture.md#critical-technical-updates-required] - "LangChain v1.0+ Migration: Existing LangChain/LangGraph code must be refactored. Follow official LangChain v1.0+ documentation for migration. Multi-agent patterns may change significantly. Test thoroughly after refactoring."
- [Source: docs/project_context.md#technology-stack] - "LangChain >= 1.0.0, LangChain-OpenAI >= 1.0.0, LangGraph >= 1.0.0"

**Brownfield Context:**
- This is NOT a greenfield project - extend existing codebase
- 5-microservice architecture already established
- Multi-agent system operational (needs v1.0+ refactor)
- [Source: docs/architecture.md#brownfield-extension] - "Core Principle: Extend, Don't Replace"

**Next Stories (Epic 0):**
- Story 0.2: Migrate SupervisorAgent to LangChain v1
- Story 0.3: Migrate MarketAnalysisAgent to LangChain v1
- Story 0.4-0.7: Migrate remaining agents
- Story 0.8: Migrate Event Extraction Service to gpt-4.1
- Story 0.9: Portfolio Multi-Agent System Integration Testing

### Development Guidelines

**DO:**
- ✅ Update `requirements.txt` with exact version constraints (>=1.0.0)
- ✅ Add `langchain-classic` package for legacy features
- ✅ Update import statements in all 6 agent files
- ✅ Test each import individually before committing
- ✅ Run full pytest suite to catch regressions
- ✅ Verify no deprecation warnings in output
- ✅ Document all version changes made
- ✅ Follow Python naming conventions (snake_case for files/functions)

**DON'T:**
- ❌ Change agent logic/implementation (imports ONLY)
- ❌ Modify function signatures or method definitions
- ❌ Update tool definitions (preserve existing tools)
- ❌ Refactor code beyond import statements
- ❌ Remove existing dependencies (preserve all)
- ❌ Skip testing (ALL tests must pass)
- ❌ Ignore deprecation warnings (must be zero)

**Code Quality Standards:**
- Follow PEP 8 Python style guide (already established)
- Type hints required for function parameters (project convention)
- Structured logging for all errors (project convention)
- 70% test coverage goal (NFR-M1)

### Implementation Sequence

**Step 1: Requirements Update**
1. Research LangChain v1.0+ compatibility
2. Update `requirements.txt` with version constraints
3. Test installation in clean environment

**Step 2: Import Updates**
1. Update SupervisorAgent imports
2. Update MarketAnalysisAgent imports
3. Update FundamentalAnalysisAgent imports
4. Update TechnicalAnalysisAgent imports
5. Update PortfolioAnalysisAgent imports
6. Update InvestmentStrategyAgent imports

**Step 3: Validation**
1. Run pytest for all agent modules
2. Verify zero deprecation warnings
3. Test individual imports manually
4. Document completion

### Related Non-Functional Requirements

**Performance (Not Applicable to This Story):**
- This story does not introduce performance changes
- Subsequent stories (0.2-0.9) will address NFR-P1 (predictions <2s), NFR-P2 (chat <500ms)

**Maintainability (NFR-M1):**
- Test coverage: Minimum 70% coverage goal
- All unit tests must pass before marking story complete

**Reliability (NFR-R8):**
- Dependency conflicts must be resolved (no installation failures)
- Import errors must be zero (no runtime failures)

### Common Pitfalls to Avoid

**Pitfall 1: Partial Migration**
- ❌ Updating only some agent imports
- ✅ Update ALL 6 agent files consistently

**Pitfall 2: Breaking Changes Beyond Imports**
- ❌ Modifying agent logic while updating imports
- ✅ Limit changes to import statements ONLY

**Pitfall 3: Ignoring Deprecation Warnings**
- ❌ Leaving deprecation warnings unaddressed
- ✅ Verify zero warnings in all test output

**Pitfall 4: Missing langchain-classic Package**
- ❌ Forgetting to add `langchain-classic` dependency
- ✅ Explicitly add to requirements.txt

**Pitfall 5: Version Conflicts**
- ❌ Using incompatible version combinations
- ✅ Test pip install in clean environment first

## Dev Agent Record

### Context Reference

Story generated by BMM create-story workflow with comprehensive context analysis from:
- Epic 0 requirements (docs/epics.md)
- Architecture decisions (docs/architecture.md - LangChain v1.0+ migration section)
- Project context rules (docs/project_context.md)
- PRD functional requirements (docs/prd.md - FR9-FR18, FR48-FR56)
- Test design system review (docs/test-design-system.md - ASR-001)
- Implementation readiness report (docs/implementation-readiness-report-2025-12-23.md)

### Agent Model Used

<!-- Will be populated by dev-story workflow -->

### Debug Log References

<!-- Will be populated during development -->

### Completion Notes List

<!-- Will be populated after story completion -->

### File List

**Files to Modify:**
- `/stockelper-llm/requirements.txt` - Add LangChain v1.0+ dependencies
- `/stockelper-llm/src/multi_agent/supervisor_agent/agent.py` - Update imports
- `/stockelper-llm/src/multi_agent/market_analysis_agent/agent.py` - Update imports
- `/stockelper-llm/src/multi_agent/fundamental_analysis_agent/agent.py` - Update imports
- `/stockelper-llm/src/multi_agent/technical_analysis_agent/agent.py` - Update imports
- `/stockelper-llm/src/multi_agent/portfolio_analysis_agent/agent.py` - Update imports
- `/stockelper-llm/src/multi_agent/investment_strategy_agent/agent.py` - Update imports

**Files to Create:**
- None (all changes to existing files)

**Files to Read (for context):**
- `/stockelper-llm/pyproject.toml` or `/stockelper-llm/setup.py` (if exists - verify no additional dependency config)
- `/stockelper-llm/src/multi_agent/*/tools.py` (verify tool imports, but DO NOT modify in this story)
