# 📈 Stockelper BMAD Workspace

**AI 기반 주식 투자 도우미 프로젝트**의 중앙 BMAD(Build-Measure-Analyze-Deploy) 워크스페이스입니다.

이 레포는 Stockelper 제품의 **문서, 에이전트 정의, 정책, Blueprint**를 관리하는 "조직의 두뇌" 역할을 합니다.

---

## 🏗️ 아키텍처 개요

```
                         ┌─────────────────────────┐
                         │   stockelper-workspace  │
                         │   (BMAD 중앙 레포)      │
                         │   - 에이전트 정의       │
                         │   - 정책/Blueprint      │
                         │   - 제품 문서           │
                         └───────────┬─────────────┘
                                     │
         ┌───────────────────────────┼───────────────────────────┐
         │                           │                           │
         ▼                           ▼                           ▼
┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐
│ stockelper-fe   │        │ stockelper-llm  │        │ stockelper-kg   │
│ 🌐 Public       │        │ 🌐 Public       │        │ 🌐 Public       │
│ AWS t3.small    │        │ AWS t3.medium   │        │ Local           │
└─────────────────┘        └─────────────────┘        └─────────────────┘

         ┌───────────────────────────┬───────────────────────────┐
         ▼                           ▼                           
┌─────────────────┐        ┌─────────────────┐        
│ stockelper-     │        │ stockelper-     │        
│ airflow         │        │ news-crawler    │        
│ 🌐 Public       │        │ 🔒 Private      │        
│ Local           │        │ Local           │        
└─────────────────┘        └─────────────────┘        
```

---

## 📁 디렉터리 구조

```
stockelper-workspace/
├── .bmad/                      # BMAD 코어 설정
│   ├── agents/                 # 에이전트 정의
│   │   ├── analyst.md          # 요구사항 분석
│   │   ├── pm.md               # 제품 관리
│   │   ├── architect.md        # 아키텍처 설계
│   │   ├── dev.md              # 개발
│   │   └── qa.md               # 품질 보증
│   ├── policies/
│   │   └── org.yaml            # 조직 공통 정책
│   ├── profiles/
│   │   └── default.yaml        # 기본 프로필
│   ├── blueprints/             # 서비스별 Blueprint
│   ├── templates/              # 문서 템플릿
│   │   ├── prd.md
│   │   ├── story.md
│   │   └── epic.md
│   └── workspace.yaml          # 워크스페이스 설정
├── docs/                       # 제품 문서
│   ├── prd/                    # PRD 문서
│   ├── architecture/           # 아키텍처 문서
│   └── epics/                  # 에픽/스토리
├── sources/                    # 서비스 레포 (심볼릭 링크, .gitignore)
│   ├── airflow/
│   ├── fe/
│   ├── kg/
│   ├── llm/
│   └── news-crawler/
├── scripts/
│   └── setup-sources.sh        # 소스 링크 설정 스크립트
├── .gitignore
├── README.md
└── CONTRIBUTING.md
```

---

## 🚀 시작하기

### 1. 이 워크스페이스 Clone

```bash
git clone https://github.com/Stockelper-Lab/stockelper-workspace.git
cd stockelper-workspace
```

### 2. 서비스 레포 Clone (상위 디렉터리에)

```bash
cd ..

# Public 레포들
git clone https://github.com/Stockelper-Lab/stockelper-airflow.git
git clone https://github.com/Stockelper-Lab/stockelper-fe.git
git clone https://github.com/Stockelper-Lab/stockelper-kg.git
git clone https://github.com/Stockelper-Lab/stockelper-llm.git

# Private 레포 (권한 필요)
git clone git@github.com:Stockelper-Lab/stockelper-news-crawler.git
```

### 3. Sources 심볼릭 링크 설정

```bash
cd stockelper-workspace
./scripts/setup-sources.sh
```

---

## 📋 서비스 개요

| 서비스 | 설명 | 기술 스택 | 배포 환경 |
|--------|------|-----------|-----------|
| **airflow** | 배치/파이프라인/스케줄링 | Python, Airflow, Docker | Local |
| **fe** | 웹 프론트엔드 | Next.js, TypeScript, Prisma | AWS t3.small |
| **kg** | Knowledge Graph | Python, Neo4j | Local |
| **llm** | LLM 멀티에이전트 | Python, LangGraph, FastAPI | AWS t3.medium |
| **news-crawler** | 뉴스 크롤링 🔒 | Python | Local |

---

## 🤖 BMAD 워크플로

### Plan (계획)

```bash
# 전체 제품 수준 계획
bmad plan

# 서비스별 계획
bmad plan --service kg
bmad plan --service llm
bmad plan --service fe
```

### Build (구현)

```bash
# Blueprint 기반 구현
bmad build --blueprint .bmad/blueprints/kg.json
```

### Verify (검증)

```bash
# Blueprint 기반 검증
bmad verify --blueprint .bmad/blueprints/kg.json
```

---

## 📝 문서 관리

### PRD 작성

```bash
# 템플릿 복사
cp .bmad/templates/prd.md docs/prd/PRD-001-feature-name.md

# 작성 후 PR
```

### Epic/Story 작성

```bash
# Epic 생성
cp .bmad/templates/epic.md docs/epics/EPIC-001-feature.md

# Story 생성
cp .bmad/templates/story.md docs/epics/STORY-001-task.md
```

---

## 🔗 관련 링크

- [stockelper-airflow](https://github.com/Stockelper-Lab/stockelper-airflow) - Airflow DAG
- [stockelper-fe](https://github.com/Stockelper-Lab/stockelper-fe) - Frontend
- [stockelper-kg](https://github.com/Stockelper-Lab/stockelper-kg) - Knowledge Graph
- [stockelper-llm](https://github.com/Stockelper-Lab/stockelper-llm) - LLM Service
- stockelper-news-crawler (🔒 Private) - News Crawler

---

## 🤝 기여 방법

[CONTRIBUTING.md](./CONTRIBUTING.md)를 참조하세요.

---

## 📜 라이선스

이 프로젝트는 PseudoLab Stockelper 팀에서 관리합니다.
