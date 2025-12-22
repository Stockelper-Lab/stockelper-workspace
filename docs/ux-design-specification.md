---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7]
inputDocuments:
  - 'docs/prd.md'
  - 'docs/architecture.md'
workflowType: 'ux-design'
lastStep: 7
status: 'complete'
completedAt: '2025-12-22'
project_name: 'Stockelper'
user_name: 'Oldman'
date: '2025-12-22'
---

# UX Design Specification Stockelper

**Author:** Oldman
**Date:** 2025-12-22

---

## Executive Summary

### Project Vision

Stockelper transforms from a passive analysis tool into an intelligent, event-driven investment assistant for Korean retail investors. The system learns from historical event patterns to predict future stock movements, delivering proactive insights at the right moments rather than waiting for users to ask. The vision: move from "tool I use" to "intelligent assistant that anticipates my needs."

**Core Innovation:**
- **Event Pattern Intelligence:** When similar events occur under similar market conditions, the system predicts stock movements by matching historical patterns
- **Contextual Orchestration:** Portfolio recommendations arrive before market open, backtesting triggers on user request with async processing, chat provides conversational access to predictions
- **Proactive Assistance:** The system initiates valuable actions (morning recommendations, event alerts) rather than only responding to queries

### Target Users

**Primary Audience:** Korean retail investors seeking intelligent, proactive investment assistance

**User Characteristics:**
- Want pattern-based predictions, not just raw analysis
- Need personalized, timely portfolio guidance
- Value automatic strategy validation against holdings
- Prefer contextual insights delivered at optimal moments
- Have KIS trading accounts and API access
- Range from intermediate to advanced investors (assessed via investment profile questionnaire)

**User Context:**
- **Primary device:** Web (desktop/laptop)
- **Key usage times:** Morning (pre-market for recommendations), anytime (backtesting requests, predictions), evening (portfolio review)
- **Primary interaction:** Chat-first for queries and requests, dedicated pages for high-stakes features

### Key Design Challenges

**1. Asynchronous Job Communication**
- Backtesting takes 5-10 minutes to process—users need clear feedback that requests are processing, not stuck or failed
- Must communicate async nature clearly: "Submit request → notification when ready"
- Handle potential multiple concurrent backtesting jobs gracefully
- Design prominent but non-intrusive completion notifications

**2. Chat Interface for Complex Financial Data**
- Balance conversational flexibility with guided actions for less experienced users
- Present multi-dimensional financial data (predictions with confidence levels, timeframes, explanations) in chat format without overwhelming users
- Maintain useful chat history for tracking past predictions and recommendations
- Provide quick actions and suggested queries to reduce friction

**3. Notification Management & Prioritization**
- Distinguish notification urgency (time-sensitive event alerts vs. completed backtests vs. daily recommendations)
- Prevent notification overflow for users monitoring many stocks
- Ensure morning recommendations are noticed before market open (9am)
- Design clear notification settings and preferences

**4. Trust & Transparency for Financial Decisions**
- KIS OpenAPI key entry post-login requires high trust and clear security messaging
- Predictions and recommendations need clear confidence levels and rationale
- Users must understand what drives recommendations (event patterns, risk profile, market conditions)
- Provide audit trail of past recommendations vs actual performance

**5. Time-Sensitive Feature Awareness**
- Morning portfolio recommendations must be noticed before market opens
- Predictions need clear temporal context (short/medium/long-term timeframes)
- Event alerts require immediate visibility when significant patterns emerge

### Design Opportunities

**1. Smart Chat Interaction Patterns**
- Quick action buttons and suggested queries to guide users without restricting flexibility
- Rich data cards for predictions (visual confidence indicators, timeframe chips, event context) beyond plain text
- Contextual follow-ups based on user's portfolio and recent queries
- Natural language understanding that accommodates varying levels of financial literacy

**2. Dedicated High-Stakes Experiences**
- Portfolio recommendation page as focused destination (not buried in chat)
- Button-triggered recommendation delivery gives users control over timing
- Clear separation between exploratory chat and actionable recommendations
- Dedicated backtesting results view with comprehensive performance metrics

**3. Progressive Disclosure & Personalization**
- Simple defaults for intermediate investors, power features for advanced users
- Investment profile drives UI complexity and recommendation aggressiveness
- Contextual help and tooltips for complex concepts
- Gradual feature introduction as users gain confidence

**4. Trust-Building Through Transparency**
- Visible confidence levels and uncertainty ranges in predictions
- Clear explanations of recommendation rationale (which events, which patterns)
- Historical accuracy tracking: past predictions vs actual outcomes
- Transparent about system limitations and appropriate use cases (informational, not financial advice)

**5. Seamless Async Experience**
- Clear job status indicators for long-running processes
- Smart notification routing (GNB icon → specific destination page)
- Graceful handling of user navigation during processing
- Persistent results accessible even if notification is missed

## Core User Experience

### Defining Experience

Stockelper's core experience centers on **intelligent conversation**—users engage with an AI assistant that understands their portfolio, learns from market event patterns, and provides proactive investment insights. The most frequent user action is requesting event-based stock price predictions and analysis through the chat interface. This conversational interaction is the product's beating heart.

**The Critical Path:** Chat conversation quality determines success or failure. The chat must render smoothly and reliably without errors, delays, or broken interactions. Every message, every prediction card, every suggested query must feel instant and flawless. If the chat experience falters, the entire product value proposition collapses.

**Primary User Flow:**
1. User opens chat interface
2. System suggests relevant queries based on portfolio
3. User requests event-based prediction or stock analysis
4. System responds with prediction, confidence level, and clear rationale
5. User understands WHY the prediction was made (the "aha!" moment)
6. User continues conversation or submits async requests (backtesting)

### Platform Strategy

**Target Platforms:**
- **Primary:** Desktop web (Chrome-based browsers: Chrome, Edge)
- **Secondary:** Mobile web (responsive design, touch-optimized)
- **Interaction model:** Mouse/keyboard on desktop, touch on mobile
- **Session-based:** Real-time chat with session-scoped memory (no cross-session persistence)

**Technical Requirements:**
- Chrome-based browser optimization (modern JavaScript, CSS Grid/Flexbox)
- Responsive design supporting desktop (1920px+) down to mobile (375px+)
- Real-time chat rendering with WebSocket or polling for notifications
- No offline functionality required
- No specific accessibility requirements for MVP (but semantic HTML preferred)

**Platform Constraints:**
- Desktop provides optimal experience for complex financial data visualization
- Mobile enables on-the-go monitoring and quick queries
- Chat interface must adapt gracefully across screen sizes
- Notification system works across both desktop and mobile browsers

### Effortless Interactions

**What Should Feel Completely Natural:**

1. **Async Job Management:**
   - Users freely navigate away during backtesting (5-10 minutes processing)
   - Results persist and are accessible when user returns
   - Clear progress indicators communicate job status
   - Notifications route directly to results when complete

2. **Contextual Chat Suggestions:**
   - System automatically suggests relevant queries based on user's portfolio
   - Reduces cognitive load—users don't start from blank slate
   - Suggestions adapt to market conditions and recent events
   - Balance guidance with conversational flexibility

3. **Session Memory:**
   - Conversation context maintained within current session
   - Fresh start each session encourages focused queries
   - No confusion from outdated cross-session context
   - Users control their conversational scope

4. **Notification Routing:**
   - Click notification → automatically navigate to relevant page
   - Morning recommendations → portfolio page
   - Backtesting complete → results view
   - Event alerts → prediction with context

5. **Prediction Display:**
   - Complex financial data rendered clearly in chat
   - Confidence levels visually obvious
   - Event rationale immediately understandable
   - Follow-up actions suggested contextually

### Critical Success Moments

**Make-or-Break User Interactions:**

1. **First Event-Based Prediction (The "Aha!" Moment):**
   - User sees their first prediction with clear event-driven rationale
   - Understands WHY the system made this prediction (which historical events, what patterns)
   - Confidence level and timeframe are crystal clear
   - User thinks: "This is different from other tools—this actually explains the reasoning"
   - **If this fails:** User sees generic prediction without context, doesn't understand value proposition

2. **Chat Conversation Quality:**
   - Every message renders instantly and correctly
   - No broken UI, no loading errors, no frozen states
   - Rich prediction cards display properly on first render
   - Suggested queries appear contextually
   - **If this fails:** User loses trust in system reliability, abandons product

3. **Async Backtesting Flow:**
   - User submits backtesting request via chat
   - Clear confirmation: "Request submitted, processing 5-10 minutes, we'll notify you"
   - User navigates away confidently
   - Notification appears when ready
   - Results accessible and comprehensive
   - **If this fails:** User uncertain if job is running, afraid to navigate away, frustrated by ambiguity

4. **Morning Portfolio Recommendation:**
   - Notification arrives before market open (pre-9am)
   - User clicks → navigates to portfolio recommendation page
   - Button click delivers personalized recommendations with event rationale
   - Actionable insights delivered with time to act
   - **If this fails:** Notification missed or late, recommendations not timely, user misses opportunity

5. **Mobile Chat Experience:**
   - Chat works smoothly on mobile browsers
   - Touch interactions feel natural
   - Financial data readable on small screens
   - Users can monitor and query on-the-go
   - **If this fails:** Mobile users frustrated, abandon mobile usage, desktop-only limits engagement

### Experience Principles

These principles guide all UX design decisions for Stockelper:

**1. Chat-First Excellence**
- The chat interface is the heart of the experience—it must be flawless
- Smooth rendering, zero errors, instant responsiveness
- Everything flows through conversational interaction
- Chat quality determines product success or failure

**2. Contextual Intelligence**
- System knows user's portfolio and suggests relevant queries
- Predictions tied to specific events with clear rationale
- First prediction must create the "aha!" moment of understanding
- Intelligence feels proactive, not reactive

**3. Async Transparency**
- Long-running jobs (backtesting) communicate progress clearly
- Users navigate freely without fear of losing work
- Notifications route intelligently to results
- System state is always clear, never ambiguous

**4. Session-Scoped Memory**
- Conversation context maintained within session
- Clean slate each session (no cross-session persistence)
- Users control their conversational context
- Fresh start each time encourages focused queries

**5. Trust Through Explanation**
- Every prediction shows WHY (event patterns, confidence, rationale)
- Transparency builds trust in financial recommendations
- Users understand the basis for system decisions
- Clear confidence levels prevent over-reliance

## Desired Emotional Response

### Primary Emotional Goals

Stockelper's emotional design centers on a **progression from informed understanding to confident decision-making**. Users should feel that the system clarifies market complexity rather than adding to it, building trust through transparency and reliability.

**Core Emotional States:**

1. **Informed Understanding:** Users grasp how event patterns drive predictions, not just what the predictions are
2. **Confidence:** Built progressively through consistent accuracy, clear explanations, and transparent limitations
3. **Trust:** Earned through reliability, honesty about capabilities, and transparent reasoning
4. **Relief:** From having clarity amid market noise and complexity
5. **Control:** Users decide when to act, navigate freely, and manage their own investment decisions

**The Critical "Aha!" Moment:** When users see their first event-based prediction, they should think: "Oh, so this is how it works?"—an intuitive realization that connects historical event patterns to current predictions. This moment transforms skepticism into understanding.

### Emotional Journey Mapping

**Stage 1: First Entry (Onboarding)**
- **Initial feeling:** Uncertain, skeptical about another investment tool
- **Desired shift:** Reassured by clear security messaging, transparent about system purpose
- **UX support:**
  - Clear explanation of KIS API key purpose and security
  - Investment profile questionnaire feels purposeful, not invasive
  - Simple, honest communication about what system does and doesn't do

**Stage 2: First Prediction Request (Chat)**
- **Initial feeling:** Curious but cautious, testing the system
- **Desired shift:** "Oh, so this is how it works!"—intuitive realization
- **UX support:**
  - Exemplary first prediction: clear event → pattern → prediction flow
  - Visual storytelling showing historical event matches
  - Confidence levels help users calibrate trust
  - Simple language, progressive disclosure

**Stage 3: Core Chat Experience (Ongoing)**
- **Desired feeling:** "This is genuinely helping me"—productive collaboration
- **UX support:**
  - Contextual suggestions show system understands portfolio
  - Personalized responses, not generic templates
  - System anticipates follow-up questions
  - Every interaction delivers clear value

**Stage 4: Async Job Submission (Backtesting)**
- **Desired feeling:** Hopeful, optimistic about results
- **UX support:**
  - Positive confirmation: "Request submitted successfully"
  - Clear expectation: "Results in 5-10 minutes, we'll notify you"
  - Encouraging tone without anxiety-inducing progress indicators
  - Freedom to navigate away confidently

**Stage 5: Waiting Period**
- **Desired feeling:** Calm, confident results will arrive
- **UX support:**
  - No anxiety from uncertainty
  - Users can be productive elsewhere
  - Trust that notification will arrive reliably

**Stage 6: Notification Arrival**
- **Desired feeling:** System works as promised, reliable and expected
- **UX support:**
  - Notifications arrive consistently at promised times
  - Clear, actionable notification text
  - Reliable routing to results
  - Users learn to depend on this reliability

**Stage 7: Results Review**
- **Desired feeling:** Informed and empowered to make decisions
- **UX support:**
  - Comprehensive but digestible results
  - Clear insights and actionable takeaways
  - Transparent about confidence and limitations
  - Users maintain control over decisions

**Stage 8: Returning Users**
- **Desired feeling:** Trust deepens, confidence grows
- **UX support:**
  - Consistent reliability builds trust over time
  - Historical accuracy tracking validates system
  - Fresh session starts reduce clutter
  - System feels increasingly valuable

### Micro-Emotions

**Critical Micro-Emotional States:**

**Confidence vs. Confusion:**
- **Target:** High confidence, zero confusion
- **UX approach:** Clear explanations, visual confidence indicators, consistent terminology, progressive disclosure
- **Avoid:** Technical jargon, unexplained complexity, ambiguous predictions

**Trust vs. Skepticism:**
- **Target:** Earned trust through transparency and reliability
- **UX approach:** Show reasoning behind predictions, honest about limitations, consistent accuracy, secure handling of API keys
- **Avoid:** Overpromising, hiding reasoning, inconsistent behavior

**Calm vs. Anxiety:**
- **Target:** Calm decision-making environment
- **UX approach:** No urgency tactics, clear expectations, reliable notifications, freedom to navigate
- **Avoid:** FOMO messaging, urgent countdowns, aggressive alerts, anxiety-inducing uncertainty

**Understanding vs. Overwhelm:**
- **Target:** Intuitive understanding of complex patterns
- **UX approach:** Visual storytelling, simple language, progressive disclosure, contextual help
- **Avoid:** Information dumps, simultaneous complexity, unexplained data

**Empowered vs. Dependent:**
- **Target:** Empowered to make informed decisions
- **UX approach:** Clear information with user control, recommendations not commands, transparent confidence levels
- **Avoid:** Directive language, removing user agency, creating dependency

### Design Implications

**Emotion-Driven UX Decisions:**

**1. Building Informed → Confident Progression:**
- First interactions prioritize explanation and understanding
- Subsequent interactions show consistent accuracy
- Visual confidence indicators help users calibrate trust
- Historical tracking validates system over time
- Progressive complexity as user confidence grows

**2. Creating "Aha!" Moments:**
- First prediction is exemplary: clear event → pattern → prediction
- Visual storytelling shows historical event matches
- Simple, intuitive language
- Progressive disclosure prevents overwhelm
- Clear causality between events and predictions

**3. Transforming Skepticism → Trust:**
- Transparent security messaging for KIS API key
- Clear about system capabilities AND limitations
- Show reasoning behind every recommendation
- Consistent reliability builds trust incrementally
- Historical accuracy tracking provides validation

**4. Enabling "This is Helping Me" Feeling:**
- Contextual suggestions prove system understands portfolio
- Personalized responses, not generic content
- System anticipates follow-up questions
- Clear value delivered in every interaction
- Helpful without being pushy

**5. Supporting Hopeful Optimism During Async Jobs:**
- Positive, encouraging confirmation messages
- Clear time expectations reduce anxiety
- No anxiety-inducing progress bars
- Calm assurance: "We'll notify you when ready"
- Freedom to be productive elsewhere

**6. Establishing Reliable Expectations:**
- Notifications arrive consistently at promised times
- Clear, actionable notification content
- Reliable routing to correct destinations
- System becomes dependable through consistency
- Users learn to trust the timing

**7. Maintaining Calm & Control:**
- No aggressive urgency or FOMO tactics
- Users control when to act on recommendations
- Session-scoped memory reduces clutter
- Navigate freely without losing work
- Always clear about system state

### Emotional Design Principles

**Guiding principles for creating the right emotional experience:**

**1. Transparency Builds Trust**
- Always show WHY behind predictions and recommendations
- Clear confidence levels and uncertainty ranges
- Honest about system capabilities and limitations
- Transparent about data usage and security

**2. Clarity Reduces Anxiety**
- Simple language over technical jargon
- Clear expectations for timing and outcomes
- Unambiguous system state and job status
- Progressive disclosure prevents overwhelm

**3. Reliability Creates Calm**
- Consistent notification timing
- Predictable routing and navigation
- Stable chat rendering without errors
- Dependable system behavior builds comfort

**4. Understanding Precedes Confidence**
- First interactions prioritize explanation
- Visual storytelling aids comprehension
- Intuitive causality: event → pattern → prediction
- "Aha!" moments unlock confidence

**5. Control Empowers Users**
- Users decide when to act on recommendations
- Freedom to navigate during async processes
- Session-scoped memory gives fresh starts
- Information enables decisions, doesn't dictate them

**6. Consistency Deepens Trust**
- Reliable accuracy over time
- Stable terminology and patterns
- Predictable system behavior
- Historical tracking validates promises

## Design System Foundation

### Design System Choice

**Decision:** Follow existing frontend repository specifications

**Approach:** Function-first design using the established design system and component library already implemented in the Stockelper frontend repository (Next.js 15.3 + React 19 + TypeScript).

### Rationale for Selection

**1. Consistency with Existing Codebase:**
- Maintains visual and technical consistency with current frontend
- Avoids introducing new dependencies or learning curves
- Ensures component compatibility with existing architecture

**2. Function-First Priority:**
- No separate brand guidelines at this stage
- Primary goal: functional correctness over visual differentiation
- Focus on reliable, working features for MVP

**3. Team Capability Alignment:**
- Limited design system experience on team
- Using established patterns reduces complexity
- Faster implementation with familiar tools

**4. MVP Speed:**
- No need to evaluate, setup, or learn new design system
- Reuse existing components where possible
- Accelerate development timeline

### Implementation Approach

**Component Strategy:**

**1. Reuse Existing Components:**
- Leverage any existing components in the frontend repository (buttons, forms, inputs, cards, etc.)
- Maintain consistency with current implementation patterns
- Review existing components before building new ones

**2. Build New Components as Needed:**
- Chat interface components (message bubbles, input, suggestions)
- Financial data display components (prediction cards, confidence indicators, charts)
- Notification components (notification center, badge, alerts)
- Async job status components (progress indicators, completion notifications)
- Portfolio recommendation page components

**3. Functional Component Priorities:**
- **Chat Interface:** Message rendering, input, suggested queries, rich prediction cards
- **Data Display:** Confidence levels, timeframes, event patterns, historical matches
- **Notifications:** GNB notification icon, notification list, routing
- **Async Feedback:** Job submission confirmation, status indicators, completion alerts
- **Forms:** KIS API key input (secure), investment profile questionnaire

**4. Design Consistency:**
- Follow existing component patterns and conventions
- Use consistent spacing, typography, and color patterns from current frontend
- Maintain responsive design approach (desktop + mobile web)

### Customization Strategy

**Given Function-First Approach:**

**1. Minimal Visual Customization:**
- Focus on functional clarity over aesthetic uniqueness
- Use default or existing styles where appropriate
- Customize only when function requires it (e.g., confidence level visualization)

**2. Functional Enhancements:**
- **Chat:** Rich message types (text, prediction cards, backtesting results)
- **Financial Data:** Clear confidence indicators, timeframe badges, event context display
- **Async Feedback:** Clear status communication, non-intrusive completion notifications
- **Security:** Secure input patterns for KIS API key with trust-building messaging

**3. Accessibility Basics:**
- Semantic HTML for screen reader support
- Keyboard navigation for all interactive elements
- Sufficient color contrast for readability
- Clear focus states for form inputs

**4. Responsive Design:**
- Desktop-optimized layouts (primary use case)
- Mobile-functional layouts (touch-friendly, readable on small screens)
- Adaptive chat interface across screen sizes
- Responsive financial data tables/cards

**5. Component Documentation:**
- Document any new custom components built
- Maintain consistent naming conventions
- Keep components simple and reusable
- Avoid over-engineering for MVP

## 2. Core User Experience

### 2.1 Defining Experience

**Core Interaction:** "Ask about a stock, get event-driven predictions with clear reasoning"

Stockelper's defining experience is the intelligent chat interaction where users ask about stocks and receive predictions grounded in historical event patterns. This interaction transforms complex market analysis into an understandable conversation.

**What Makes This Defining:**

Users will describe Stockelper as: "I ask about stocks and it shows me predictions based on what happened before with similar events." This simple framing captures the product's unique value: event-driven intelligence delivered conversationally.

**The Magic Moment:**

The first time a user sees a prediction card showing:
- Historical events that match current situation
- Clear pattern explanation: "When X happened before under similar conditions, stocks moved Y"
- Confidence level and timeframe
- Understandable reasoning they can trust

This moment creates the "aha!" realization: "Oh, so this is how it works!"—transforming skepticism into understanding.

### 2.2 User Mental Model

**Current Approach (Without Stockelper):**

Korean retail investors currently:
1. Manually read Korean financial news (Naver Finance, DART disclosures)
2. Try to remember if similar events happened before
3. Guess how events might affect stock prices
4. Feel uncertain about their analysis
5. Make decisions with incomplete context

**Mental Model Gap:**

Users lack:
- Pattern recognition across historical events
- Confidence in their event-to-price predictions
- Time to research every event thoroughly
- Systematic way to learn from past market reactions

**Expected Mental Model with Stockelper:**

Users expect:
- **Conversational access:** "Just ask" rather than navigate complex UIs
- **Intelligent assistant:** System understands context and portfolio
- **Transparent reasoning:** Show WHY, not just WHAT
- **Fast answers:** Prediction arrives in seconds, not after manual research
- **Historical proof:** "This happened before, here's what followed"

**Key Expectation:**

Users think: "Help me understand" not "Tell me what to do." They want informed decision-making, not directive commands.

### 2.3 Success Criteria

**Core Experience Succeeds When:**

**1. Understanding (The "Aha!" Moment):**
- ✅ User sees clear event → pattern → prediction flow
- ✅ Historical examples make sense and feel relevant
- ✅ Confidence level helps calibrate trust appropriately
- ✅ User thinks: "I understand WHY this prediction makes sense"

**2. Speed (Efficiency):**
- ✅ Chat response arrives in <2 seconds (per NFR)
- ✅ Prediction feels instant, not laboriously processed
- ✅ Faster than manual news research and analysis
- ✅ User thinks: "This is so much faster than doing it myself"

**3. Trust (Transparency):**
- ✅ Reasoning is transparent and verifiable
- ✅ System shows sources (which events, which patterns)
- ✅ Confidence levels are honest, not overconfident
- ✅ User thinks: "I can trust this reasoning"

**4. Actionability (Empowerment):**
- ✅ User feels informed enough to make decisions
- ✅ Clear about what to do next (follow-up questions available)
- ✅ Maintains user control (recommendations not commands)
- ✅ User thinks: "I know what I need to know now"

**5. Natural Interaction (Effortless):**
- ✅ Chat feels conversational, not robotic
- ✅ System suggests relevant follow-ups
- ✅ No confusion about how to phrase questions
- ✅ User thinks: "This just works"

**Failure Indicators:**

- ❌ User confused about WHY prediction was made
- ❌ Prediction takes too long, feels slow
- ❌ User skeptical of reasoning or sources
- ❌ User unsure what to do with information
- ❌ Chat feels clunky or difficult to use

### 2.4 Novel vs. Established UX Patterns

**Pattern Analysis:**

Stockelper combines **established patterns** with **innovative content delivery**.

**Established Patterns (Leverage Familiarity):**

**1. Conversational Chat Interface:**
- Users already understand chat UX from KakaoTalk, messaging apps
- Text input, message bubbles, suggested replies are familiar
- No learning curve for basic interaction model

**2. Search-Like Query Pattern:**
- Users know how to "ask questions" from search engines, ChatGPT
- Natural language input is increasingly expected
- Progressive refinement through follow-ups feels natural

**3. Card-Based Information Display:**
- Rich cards for structured data are established (Google results, news feeds)
- Users understand expandable cards, visual hierarchy
- Financial dashboards use card patterns extensively

**Innovative Content (The Unique Twist):**

**1. Event-Driven Prediction Cards:**
- Novel: Showing historical event matches visually
- Novel: Clear causality visualization (event → pattern → prediction)
- Novel: Confidence calibration with event-based rationale
- **Not novel interaction, novel content organization**

**2. Contextual Portfolio-Aware Suggestions:**
- Novel: Chat suggestions based on user's specific portfolio
- Novel: Proactive relevance without explicit user query
- **Familiar pattern (suggestions) with smart content**

**3. Async Job Patterns in Chat:**
- Novel: Backtesting initiated via chat, completed via notification
- Established: Async jobs with progress indicators (Figma, rendering tools)
- **Familiar pattern applied to financial analysis context**

**UX Strategy:**

**Use Proven Patterns for Interaction:**
- Chat interface (familiar)
- Message bubbles and input (familiar)
- Suggested queries (familiar)
- Card-based display (familiar)

**Innovate on Content and Intelligence:**
- Event pattern matching (unique)
- Historical causality visualization (unique)
- Portfolio-contextual suggestions (unique)
- Transparent confidence levels (increasingly expected)

**User Education Needs:**

**Minimal:** Users already know how to chat. Education focuses on:
- What kinds of questions to ask (suggested queries help)
- How to interpret confidence levels (visual + text)
- Understanding event patterns (first prediction teaches this)

### 2.5 Experience Mechanics

**Detailed Flow: Core Chat Prediction Request**

**1. Initiation (How User Starts):**

**Entry Points:**
- User lands on chat page (main interface)
- System shows suggested queries based on portfolio: "Analyze Naver stock based on recent AI news"
- User can type custom query or click suggestion

**Invitation to Act:**
- Empty chat with contextual suggestions (not intimidating blank slate)
- Placeholder text: "Ask about a stock or event..."
- Visual cues: Suggested query chips, input field focus

**2. Interaction (What User Does):**

**User Actions:**
- Types question: "삼성전자 주가 전망은?" or "What's the outlook for Samsung Electronics?"
- Or clicks suggested query
- Presses Enter or clicks send button

**System Response (Real-time):**
- Message appears instantly in chat (user's query)
- Typing indicator shows system is thinking (~1-2 seconds)
- Prediction card renders smoothly below

**Prediction Card Contents:**
- **Header:** Stock name + timeframe chips (short/medium/long-term)
- **Prediction:** Clear statement with confidence indicator (visual + percentage)
- **Event Context:** "Recent events detected: [event name]"
- **Historical Pattern:** "Similar events in [timeframe]: [outcomes]"
- **Visual:** Simple chart or icon showing pattern match
- **Follow-ups:** Suggested next questions

**3. Feedback (How User Knows It's Working):**

**Immediate Feedback:**
- User's message appears instantly (confirms input received)
- Typing indicator shows processing (system is working)
- Prediction card renders smoothly (no broken UI, no errors)

**Success Signals:**
- Confidence level color-coded (green = high, yellow = medium, red = low)
- Event context shows specific, relevant events (not generic)
- Historical patterns feel concrete and verifiable
- Timeframe badges clearly indicate prediction horizon

**Error Handling:**
- If stock not found: "I couldn't find that stock. Did you mean [suggestions]?"
- If no events: "No significant events detected recently. Would you like general analysis?"
- If low confidence: Clear explanation why confidence is low

**4. Completion (User Knows They're Done):**

**Successful Outcome:**
- User understands the prediction and reasoning
- User feels informed enough to make decision
- System suggests logical next actions:
  - "Want to see backtesting for this prediction?"
  - "Compare with other AI stocks?"
  - "Set alert for similar events?"

**What's Next (Continuation):**
- User can ask follow-up questions
- User can submit backtesting request (async job)
- User can explore other stocks
- User can close chat (session-scoped memory, fresh start next time)

**Completion Indicators:**
- No "end" to chat session (continuous conversation)
- User navigates away when satisfied
- Can return anytime for new queries
- Each prediction is self-contained (no dependency on previous messages)
