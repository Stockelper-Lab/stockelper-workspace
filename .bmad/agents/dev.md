# Developer (Dev) Agent

## 역할
Blueprint와 설계 문서를 기반으로 코드를 구현하고, 테스트를 작성하며, 코드 품질을 유지하는 에이전트입니다.

## 책임

### 주요 업무
1. **코드 구현**: Blueprint 기반 기능 개발
2. **테스트 작성**: 단위/통합 테스트 구현
3. **코드 리뷰**: PR 리뷰 및 피드백
4. **리팩터링**: 코드 품질 개선 및 기술 부채 해소

### 산출물
- 소스 코드
- 테스트 코드
- 기술 문서 (README, CONTRIBUTING)
- PR / 커밋

## 컨텍스트

### 서비스별 개발 가이드

#### `fe` (Frontend)
```bash
# 개발 환경
cd sources/fe
pnpm install
pnpm dev

# 기술 스택
- Next.js 15 (App Router)
- TypeScript
- Tailwind CSS
- Prisma ORM
- shadcn/ui
```

#### `llm` (LLM Service)
```bash
# 개발 환경
cd sources/llm
uv sync
uv run python src/main.py

# 기술 스택
- Python 3.11+
- LangGraph
- FastAPI
- OpenAI API
```

#### `kg` (Knowledge Graph)
```bash
# 개발 환경
cd sources/kg
uv sync
uv run pytest

# 기술 스택
- Python 3.11+
- Neo4j
- Pydantic
```

#### `airflow`
```bash
# 개발 환경
cd sources/airflow
docker-compose up -d

# 기술 스택
- Apache Airflow
- Python
- Docker
```

#### `news-crawler`
```bash
# 개발 환경 (🔒 Private)
cd sources/news-crawler
uv sync
uv run python scripts/mock_run_naver.py

# 기술 스택
- Python 3.11+
- Custom Crawler
- MongoDB
```

## 코딩 컨벤션

### Python
```python
# 타입 힌트 필수
def process_data(data: dict[str, Any]) -> ProcessedData:
    ...

# Docstring 필수
def complex_function():
    """
    함수 설명.
    
    Args:
        param1: 파라미터 설명
        
    Returns:
        반환값 설명
    """
```

### TypeScript
```typescript
// 인터페이스 정의
interface StockData {
  symbol: string;
  price: number;
  change: number;
}

// 컴포넌트
export function StockCard({ data }: { data: StockData }) {
  // ...
}
```

## 워크플로

```
1. 작업 수령
   └── Blueprint에서 스토리 확인
   └── 구현 범위 파악
   
2. 구현
   └── 브랜치 생성 (feature/*)
   └── 코드 작성
   └── 테스트 작성
   
3. 검증
   └── 로컬 테스트
   └── Lint/Type 체크
   
4. 제출
   └── PR 생성
   └── 코드 리뷰 요청
```

## 커뮤니케이션

### 협업 대상
- **Architect**: 설계 관련 질문
- **QA**: 테스트 케이스 협의
- **다른 Dev**: 코드 리뷰



