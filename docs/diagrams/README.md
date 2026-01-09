# Stockelper System Diagrams

This directory contains visual diagrams documenting the Stockelper platform architecture and data flows.

## 📊 Available Diagrams

### 1. System Architecture / 시스템 아키텍처
- **[English Version](./system-architecture.md)** - Complete overview of the Stockelper microservices architecture
- **[한국어 버전](./system-architecture-ko.md)** - Stockelper 마이크로서비스 아키텍처 전체 개요

**Shows**:
- All 7 microservices (Frontend, LLM, Portfolio, Backtesting, Airflow, KG Builder, News Crawler)
- 3 database systems (PostgreSQL, MongoDB, Neo4j)
- External API integrations (DART, KIS, OpenAI, Supabase)
- Service-to-service connections
- Deployment topology (AWS Cloud vs Local)
- Port configurations

**Use this for**:
- Understanding system components
- Planning deployment
- Identifying service dependencies
- Onboarding new developers

---

### 2. Data Flow / 데이터 플로우
- **[English Version](./data-flow.md)** - Detailed data flows showing how information moves through the system
- **[한국어 버전](./data-flow-ko.md)** - 시스템을 통해 정보가 이동하는 방식을 보여주는 상세 데이터 흐름

**Shows**:
- DART Collection Pipeline (Daily batch)
- User Chat Interaction (Real-time streaming)
- Portfolio Recommendation (Async job queue)
- Event-Based Backtesting (User-initiated)
- Real-Time Notifications (Event-driven)

**Use this for**:
- Understanding data transformations
- Debugging data issues
- Planning new features
- Performance optimization

---

## 🎨 Diagram Format

All diagrams use **Mermaid**, a markdown-based diagramming language that renders in:
- GitHub markdown preview (automatic)
- GitLab markdown preview (automatic)
- VS Code with Mermaid extension
- JetBrains IDEs with Mermaid plugin
- Most modern markdown viewers

## 👀 How to View Diagrams

### Option 1: GitHub (Recommended)
Simply open the markdown files on GitHub. Mermaid diagrams render automatically:
- [System Architecture on GitHub](./system-architecture.md)
- [Data Flow on GitHub](./data-flow.md)

### Option 2: VS Code
1. Install the **Markdown Preview Mermaid Support** extension:
   ```bash
   code --install-extension bierner.markdown-mermaid
   ```
2. Open any diagram markdown file
3. Press `Cmd+Shift+V` (Mac) or `Ctrl+Shift+V` (Windows/Linux) for preview

### Option 3: Mermaid Live Editor
1. Go to [mermaid.live](https://mermaid.live/)
2. Copy the diagram code from the markdown file
3. Paste into the editor
4. Interact with the live preview

### Option 4: Export as Image
Using Mermaid CLI:
```bash
# Install Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Export as PNG
mmdc -i system-architecture.md -o system-architecture.png

# Export as SVG (vector, scalable)
mmdc -i data-flow.md -o data-flow.svg

# Export as PDF
mmdc -i system-architecture.md -o system-architecture.pdf
```

## 📝 Editing Diagrams

### Mermaid Syntax
Diagrams use Mermaid's `graph TB` (top-to-bottom) syntax. Basic elements:

```mermaid
graph TB
    %% Comments start with %%

    %% Define nodes
    A["Node Label"]
    B["Another Node"]

    %% Define connections
    A --> B
    A -.-> C  %% Dashed line

    %% Styling
    classDef myStyle fill:#f9f,stroke:#333
    class A myStyle
```

### Best Practices
1. **Keep it readable**: Don't overcrowd diagrams
2. **Use subgraphs**: Group related components
3. **Color code**: Consistent colors for node types
4. **Label connections**: Show what data/API is used
5. **Test rendering**: Check on GitHub and locally

### Updating Diagrams
1. Edit the `.md` file in this directory
2. Test rendering locally or in Mermaid Live Editor
3. Commit changes
4. GitHub will render the updated diagram automatically

## 🔗 Related Documentation

### Architecture Documentation
- [Architecture Decision Document](../architecture.md) - Detailed architectural decisions
- [PRD](../prd.md) - Product requirements and features
- [Project Overview](../project-overview.md) - High-level system description

### Service-Specific Documentation
- [Frontend README](../../sources/fe/README.md)
- [LLM Service README](../../sources/llm/README.md)
- [Portfolio Service README](../../sources/portfolio/README.md)
- [Backtesting Service README](../../sources/backtesting/README.md)
- [Airflow README](../../sources/airflow/README.md)
- [KG Builder README](../../sources/kg/README.md)
- [News Crawler README](../../sources/news-crawler/README.md)

### Setup Guides
- [Complete Setup Guide](../../README.md) - Building the system from scratch
- [Deployment Guide](../architecture.md#deployment--build-assumptions) - Production deployment

## 🤝 Contributing

When adding new diagrams:

1. **Create a new `.md` file** in this directory
2. **Use consistent styling**:
   - Follow existing color schemes
   - Use subgraphs for grouping
   - Include comprehensive labels
3. **Add description text** above and below the diagram
4. **Update this README** with a link to the new diagram
5. **Test rendering** on multiple platforms before committing

### Diagram Naming Convention
- Use kebab-case: `system-architecture.md`, `data-flow.md`
- Be descriptive: `authentication-flow.md`, `deployment-topology.md`
- Include purpose in filename when possible

## 📚 Learning Resources

### Mermaid Documentation
- [Official Mermaid Docs](https://mermaid.js.org/)
- [Flowchart Syntax](https://mermaid.js.org/syntax/flowchart.html)
- [Sequence Diagrams](https://mermaid.js.org/syntax/sequenceDiagram.html)
- [C4 Diagrams](https://mermaid.js.org/syntax/c4c.html)

### Tutorials
- [Mermaid Cheat Sheet](https://jojozhuang.github.io/tutorial/mermaid-cheat-sheet/)
- [Interactive Tutorial](https://mermaid-js.github.io/mermaid-live-editor/)

## 🐛 Troubleshooting

### Diagram not rendering on GitHub
- **Issue**: Syntax error in Mermaid code
- **Solution**: Test in [mermaid.live](https://mermaid.live/) first
- **Check**: Proper closing of subgraphs, quotes, brackets

### Colors not showing
- **Issue**: Class definitions after node usage
- **Solution**: Define `classDef` before applying to nodes
- **Example**:
  ```mermaid
  graph TB
      classDef myClass fill:#f9f
      A["Node"]:::myClass
  ```

### Arrows not connecting
- **Issue**: Node ID mismatch
- **Solution**: Use consistent node IDs (case-sensitive)
- **Tip**: Use meaningful IDs like `FE` for Frontend, `LLM` for LLM Service

### Diagram too large
- **Issue**: GitHub has rendering limits
- **Solution**:
  - Split into multiple diagrams
  - Use subgraphs to collapse complexity
  - Reduce node count to <50 per diagram

## 📧 Questions?

- **Architecture questions**: See [architecture.md](../architecture.md)
- **Diagram issues**: Open an issue with "diagram:" prefix
- **Feature requests**: Discuss in project planning meetings

---

**Last Updated**: 2026-01-09
**Maintainer**: Stockelper Team
