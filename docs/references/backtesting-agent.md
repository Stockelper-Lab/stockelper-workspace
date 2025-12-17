### 주가 데이터 적재

- yfinance로 적재 되지 않은 최신 주가 종목들 KRX 이용해 적재 완료 (148개 종목)

## 백테스팅 설계

### 레퍼런스 참고

| **플랫폼** | URL | **주력 분야** |
| --- | --- | --- |
| **퀀터스** | https://www.quantus.kr/foundry | 팩터 투자, 재무 분석 |
| **젠포트** | https://genport.newsystock.com/backtest/BackTest.aspx | 자동매매, 기술적 분석 |
| **퀀트킹** | https://quantking.net/ | 데이터 분석, 소형주 |
- 퀀터스
- 젠포트
    
    [[트레이딩] 백테스트](https://www.notion.so/c5a302137ec84490a3e5d2f2e23e0818?pvs=21) 
    
- 퀀트킹
    
    ![image.png](attachment:dc8d3b09-0b6c-4f57-bbb3-128c8301fb5d:image.png)
    

### Input/Output

Input

- 주식 유니버스 : 코스피 중대형, 코스피 중소형, 코스닥 대형, 코스닥 중형, 코스닥 소형, 코스닥 초소형
- 업종
- 종목 필터 : 해당 팩터 상위/하위 %, 값 기준
- 종목 정렬 : 정렬 기준.
    - 모멘텀, 가격, 종합점수, 펀더멘탈 등
    - **이벤트 감성 점수, 이벤트 타입**
- 투자금액
- 리밸런싱 주기
- 최대 보유 종목 수
- 포트폴리오 최대 종목 수
- 투자 시작일 - 투자 종료일
- 수수료율, 슬리피지
- 주가정보

Output

- 성과 지표 : 누적 수익률, MDD, 총 손익 등
- 거래 내역 : 일자별 매매 종목
    - 매매 수량, 금액, 매매 사유 등
- 리포트 생성 (LLM 기반)
    - 성과지표와 거래내역 기반 백테스팅 결과 리포트 + 어떤 이벤트가 발생했을 때 수익률이 가장 좋았는지

### 논의사항

- 감성분석 실시 주기 : 백테스팅 실행 시, **이벤트 수집 시 바로 감성분석 (모든 종목에 대해 2-3시간 주기)**, 일간
    - 프롬프트 전달
- 백테스팅 시 필요한 사용자 정보 정의
    - 선택 :
    - 고정 :
- 어디서 이벤트 데이터를 가져와야 하는지
- 챗봇 vs. 서비스
    - 걸리는 시간 체크 필요
    - 유저 경험, 효율성 고려해야 해서 좀 더 고민 필요
- 주가 적재  코드
    - 힘찬님께 전달

## 액션 아이템

- [ ]  백테스팅 에이전트 구현
- [x]  프롬프트 전달
- [x]  주가적재 코드 전달

### 감성분석 프롬프트

```jsx
NEWS_SENTIMENT_SYSTEM_PROMPT = """You are a financial news sentiment analysis expert specializing in Korean stock market news.
Analyze the given Korean news title and body to evaluate its impact on the stock market,
and calculate a sentiment score between -1 (very negative) and 1 (very positive).

Analysis considerations:
1. The news content is in Korean. Comprehensively analyze both the Korean title and body of the news.
2. Positive factors affecting stock price: earnings improvement (실적 개선), new contracts (신규 계약), technological innovation (기술 혁신), positive outlook (긍정적 전망), etc.
3. Negative factors affecting stock price: earnings deterioration (실적 악화), increased risks (리스크 증가), negative outlook (부정적 전망), regulatory tightening (규제 강화), etc.
4. Neutral news should be evaluated close to 0
5. Extract the Korean company name mentioned in the news (for knowledge graph relationship creation). Return the company name exactly as it appears in Korean.
6. You MUST always classify the news into an event type. Analyze the Korean news content and identify the primary event category that best describes the news. If multiple events are mentioned, select the most significant one. Use a descriptive event type name in lowercase with underscores (e.g., "earnings", "share_buyback", "dividend", "merger_acquisition", "new_contract", "regulatory", "product_launch", "management_change", "general", etc.). You can use any appropriate event type name that accurately describes the news content.

Output must be in JSON format only."""

NEWS_SENTIMENT_USER_PROMPT = """Analyze the sentiment of the following Korean news article.

News information:
- Title: {title}
- Body: {body}
- Date: {date}

Output only in the following JSON format (no other explanation, JSON only):
{{
    "sentiment_score": <float>,  // Real number between -1.0 (very negative) and 1.0 (very positive)
    "event_type": "<string>",  // REQUIRED: Event category that best describes the news. Use a descriptive name in lowercase with underscores. Examples include: "earnings", "share_buyback", "dividend", "merger_acquisition", "new_contract", "regulatory", "product_launch", "management_change", "general", "partnership", "investment", "lawsuit", "ipo", etc. If multiple events exist, select the most significant one. Never use "none" or null.
    "company": "<company_name>"  // Korean company name mentioned in the news (return exactly as it appears in Korean, null if not mentioned)
}}

Notes:
- The news content is in Korean. Analyze the Korean text carefully.
- sentiment_score must be a real number between -1.0 and 1.0.
- event_type is REQUIRED and must always be a descriptive string in lowercase with underscores. Examples include but are not limited to: "earnings", "share_buyback", "dividend", "merger_acquisition", "new_contract", "regulatory", "product_launch", "management_change", "general", "partnership", "investment", "lawsuit", "ipo", "stock_split", "bankruptcy", etc. Never use "none" or null. If multiple events are mentioned, select the most important/primary one.
- company must be the Korean company name exactly as it appears in the news (e.g., "삼성전자", "SK하이닉스"). Use null if no company is mentioned.
- Output JSON format only, no additional explanation or markdown formatting."""

```

### 주가 적재 코드

```python
import FinanceDataReader as fdr
import pandas as pd
from tqdm import tqdm
from datetime import datetime
from sqlalchemy import create_engine, text
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s', filename='stock_chatbot/stockelper-llm/src/multi_agent/store_daily_stock_price.log')
logger = logging.getLogger(__name__)

# ----------------------------------------------------------
# 설정
# ----------------------------------------------------------
db_user = "stockelper"
db_password = 
db_host = 
db_port = 
db_name = "postgres"
table_name = "daily_stock_price"

engine = create_engine(f'postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}')

with engine.connect() as conn:
    current_db = conn.execute(text("SELECT current_database();")).fetchone()[0]
    logger.info(f"Current database: {current_db}")
    if current_db != db_name:
        conn.execute(text(f"CREATE DATABASE {db_name};"))
        conn.commit()
    else:
        logger.info(f"Database {db_name} already exists")

with engine.connect() as conn:
    conn.execute(text("""
        ALTER TABLE daily_stock_price 
        ALTER COLUMN open TYPE NUMERIC(15, 2),
        ALTER COLUMN high TYPE NUMERIC(15, 2),
        ALTER COLUMN low TYPE NUMERIC(15, 2),
        ALTER COLUMN close TYPE NUMERIC(15, 2),
        ALTER COLUMN adj_close TYPE NUMERIC(20, 6);
    """))
    conn.commit()

# 테이블 생성 함수
def create_table_if_not_exists(engine):
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS daily_stock_price (
                id SERIAL PRIMARY KEY,
                symbol VARCHAR(10) NOT NULL,
                date DATE NOT NULL,
                open NUMERIC(12, 2),
                high NUMERIC(12, 2),
                low NUMERIC(12, 2),
                close NUMERIC(12, 2),
                volume BIGINT,
                adj_close NUMERIC(12, 6),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(symbol, date)
            );
            
            CREATE INDEX IF NOT EXISTS idx_symbol_date ON daily_stock_price(symbol, date);
            CREATE INDEX IF NOT EXISTS idx_date ON daily_stock_price(date);
        """))
        conn.commit()

# 배치 UPSERT 함수 (대용량 데이터 처리용)
def bulk_upsert(engine, df, table_name, batch_size=10000):
    """
    대용량 데이터를 배치로 처리하여 UPSERT 수행
    """
    temp_table = f"{table_name}_temp_{pd.Timestamp.now().strftime('%Y%m%d%H%M%S')}"
    
    try:
        # 1. 임시 테이블에 DataFrame 전체를 한 번에 삽입 
        df.to_sql(temp_table, engine, if_exists='replace', index=False, method='multi')
        
        # 2. 한 번의 SQL 쿼리로 모든 데이터 UPSERT 
        logger.info(f"   🔄 UPSERT 실행 중...")
        with engine.begin() as conn:  # 자동 커밋
            conn.execute(text(f"""
                INSERT INTO {table_name} (symbol, date, open, high, low, close, volume, adj_close)
                SELECT symbol, date, open, high, low, close, volume, adj_close
                FROM {temp_table}
                ON CONFLICT (symbol, date) 
                DO UPDATE SET
                    open = EXCLUDED.open,
                    high = EXCLUDED.high,
                    low = EXCLUDED.low,
                    close = EXCLUDED.close,
                    volume = EXCLUDED.volume,
                    adj_close = EXCLUDED.adj_close
            """))
        
        # 3. 임시 테이블 삭제
        with engine.connect() as conn:
            conn.execute(text(f"DROP TABLE IF EXISTS {temp_table};"))
            conn.commit()
            
        logger.info(f"   ✅ {len(df):,}행 처리 완료!")
        
    except Exception as e:
        # 에러 발생 시 임시 테이블 정리
        try:
            with engine.connect() as conn:
                conn.execute(text(f"DROP TABLE IF EXISTS {temp_table};"))
                conn.commit()
        except:
            pass
        raise e

def report_ingestion_status(engine, all_symbols):
    """
    DB에 적재된 종목 수와 전체 종목 수를 비교해 리포트
    """
    total_symbols = len(all_symbols)
    with engine.connect() as conn:
        ingested_symbols = [
            row[0]
            for row in conn.execute(
                text("SELECT DISTINCT symbol FROM daily_stock_price")
            )
        ]
        ingested_count = len(ingested_symbols)
        ingested_set = set(ingested_symbols)
        missing_symbols = [sym for sym in all_symbols if sym not in ingested_set]

    coverage = (
        (ingested_count / total_symbols) * 100 if total_symbols > 0 else 0
    )
    logger.info("===== DB 적재 현황 =====")
    logger.info(f"전체 상장 종목 수: {total_symbols:,}")
    logger.info(f"적재 완료 종목 수: {ingested_count:,} ({coverage:.2f}%)")
    if missing_symbols:
        logger.info(f"미적재 종목 수: {len(missing_symbols):,}")
        logger.info(f"예시 미적재 종목: {missing_symbols[:10]}")
    else:
        logger.info("모든 종목이 적재되었습니다.")

    return missing_symbols

# ----------------------------------------------------------
# 1️⃣ KRX 상장종목 리스트 가져오기
krx = fdr.StockListing("KRX")
symbols = krx['Code'].tolist()
logger.info(f"KRX 상장종목 리스트 가져오기 완료: {len(symbols)}개")

target_symbols = [symbols[1]]
from_date = '2005-01-01'
to_date = datetime.now().strftime('%Y-%m-%d')

# 테이블 생성
create_table_if_not_exists(engine)

missing_symbols = report_ingestion_status(engine, symbols)

# 데이터 수집 및 저장
for sym in tqdm(missing_symbols, desc="데이터 수집"):
    try:
        # 데이터 가져오기
        krx_df = fdr.DataReader(f'KRX:{sym}', start=from_date, end=to_date)
        yh_df = fdr.DataReader(f'YAHOO:{sym}.KS', start=from_date, end=to_date)

        # 데이터 병합
        df = yh_df.merge(krx_df, left_index=True, right_index=True, suffixes=('', '_krx'), how='outer')
        df[['Open', 'High', 'Low', 'Close', 'Volume', 'Adj Close']] = df[['Open', 'High', 'Low', 'Close', 'Volume', 'Adj Close']].bfill()
        df.dropna(inplace=True)
        df = df[['Open', 'High', 'Low', 'Close', 'Volume', 'Adj Close']]

    except Exception as e:
        if 'Not Found for url' in str(e):
            df = krx_df.copy()[['Open', 'High', 'Low', 'Close', 'Volume']]
            df['Adj Close'] = df['Close']
        else:
            raise e
        
        df.index.name = 'Date'
        df.reset_index(inplace=True)
        
        # 심볼 추가
        df['symbol'] = sym
        
        # 컬럼명 정리
        df = df.rename(columns={
            'Open': 'open',
            'High': 'high',
            'Low': 'low',
            'Close': 'close',
            'Volume': 'volume',
            'Adj Close': 'adj_close',
            'Date': 'date'
        })
        
        # 컬럼 순서 조정
        df = df[['symbol', 'date', 'open', 'high', 'low', 'close', 'volume', 'adj_close']]
        
        # 배치 UPSERT 실행
        bulk_upsert(engine, df, table_name)        
        logger.info(f"✅ {sym} 저장 완료 ({len(df):,} rows)")
        
    except Exception as e:
        logger.error(f"❌ {sym} 저장 실패: {str(e)}")
        continue

logger.info(f"\n모든 데이터 저장 완료!")
# missing_symbols = report_ingestion_status(engine, symbols)

```

# 포트폴리오 백테스팅

---

## 시스템 구조

```python
portfolio_backtest.py
├── BacktestInput: 입력 파라미터 정의
├── BacktestOutput: 출력 결과 구조
├── generate_synthetic_sentiment_data(): 임의 감성 데이터 생성
├── DataLoader: DB 데이터 조회 클래스
│   ├── get_stock_price_data(): PostgreSQL에서 주가 조회
│   └── get_news_sentiment_data(): 
├── PortfolioStrategy: 백테스팅 전략 클래스
│   ├── rebalance(): 포트폴리오 리밸런싱
│   └── manage_position(): 개별 포지션 관리
└── run_backtest(): 메인 실행 함수
```

---

## Input 파라미터

### BacktestInput 클래스

백테스팅에 필요한 모든 입력 파라미터를 정의하는 데이터 클래스

```python
class BacktestInput:
    """
    백테스팅 입력 파라미터 클래스
    
    이 클래스는 백테스팅에 필요한 모든 입력 파라미터를 정의합니다.
    유니버스, 필터, 정렬 기준, 투자 파라미터 등을 포함합니다.
    """
    # 주식 유니버스: 투자 대상이 되는 시장 구분
    # 예: 코스피 중대형, 코스닥 대형 등
    universe: List[str] = field(default_factory=lambda: [
        "코스피 중대형", "코스피 중소형", "코스닥 대형", 
        "코스닥 중형", "코스닥 소형", "코스닥 초소형"
    ])
    
    # 업종 필터: 특정 업종만 선택 (None이면 모든 업종)
    sectors: Optional[List[str]] = None
    
    # 종목 필터 설정
    filter_type: Optional[str] = None  # "top": 상위, "bottom": 하위, "value": 값 기준
    filter_percent: Optional[float] = None  # 상위/하위 % (예: 20 = 상위 20%)
    filter_value: Optional[float] = None  # 값 기준 필터링
    
    # 종목 정렬 기준
    # "momentum": 모멘텀, "price": 가격, "composite_score": 종합점수,
    # "fundamental": 펀더멘탈, "sentiment_score": 감성 점수, "event_type": 이벤트 타입
    sort_by: str = "sentiment_score"
    sort_ascending: bool = False  # False: 내림차순(높은 순), True: 오름차순
    
    # 투자 파라미터
    initial_cash: float = 100_000_000  # 초기 투자금액 (1억원)
    rebalancing_period: str = "monthly"  # 리밸런싱 주기: "daily", "weekly", "monthly", "quarterly"
    max_positions: int = 10  # 최대 보유 종목 수
    max_portfolio_size: int = 20  # 포트폴리오 최대 종목 수 (선택 대상)
    
    # 백테스팅 기간
    start_date: str = "2024-01-01"
    end_date: str = "2024-12-31"
    
    # 거래 비용
    commission_rate: float = 0.0005  # 거래 수수료율 (0.05%)
    slippage_rate: float = 0.001  # 슬리피지율 (0.1%)
    
    # DB 연결 설정
    db_user: str = "stockelper"
    db_password: str = 
    db_host: str = 
    db_port: str = "21002"
    db_name: str = "postgres"
    
    # MongoDB 설정 (뉴스 감성 데이터 - 선택사항)
    mongo_uri: Optional[str] = None  # 환경변수에서 가져옴, 없으면 임의 생성

```

**1. 주식 유니버스 설정**

- **설명**: 투자 대상이 되는 시장 구분
- **기본값**: 모든 유니버스 포함
- **예시**: [        "코스피 중대형", "코스피 중소형", "코스닥 대형", 
        "코스닥 중형", "코스닥 소형", "코스닥 초소형"]
- 필터링 로직 구현 필요!

**2. 업종 필터**

sectors: Optional[List[str]] = None

- **설명**: 특정 업종만 선택 (None이면 모든 업종)
- **예시**: ["반도체", "바이오"]

**3. 종목 필터**

filter_type: Optional[str] = None  *# "top", "bottom", "value"*

filter_percent: Optional[float] = None  *# 상위/하위 %*

filter_value: Optional[float] = None  *# 값 기준*

**4. 종목 정렬 기준**

sort_by: str = "sentiment_score" # momentum, price, composite_score, fundamental, 

sort_ascending: bool = False

- **sort_by**: 정렬 기준 (구현 필요)
    - "momentum": 모멘텀
    - "price": 가격
    - "composite_score": 종합점수
    - "fundamental": 펀더멘탈
    - "sentiment_score": **감성 점수** (기본값)
    - "event_type": 이벤트 타입
- **sort_ascending**: False = 내림차순 (높은 순), True = 오름차순

**5. 투자 파라미터**

initial_cash: float = 100_000_000  *# 초기 투자금액 (1억원)*

rebalancing_period: str = "monthly"  *# 리밸런싱 주기 : daily, weekly, monthly, quarterly*

max_positions: int = 10  *# 최대 보유 종목 수*

max_portfolio_size: int = 20  *# 포트폴리오 최대 종목 수*

**6. 백테스팅 기간**

start_date: str = "2024-01-01"

end_date: str = "2024-12-31"

- **형식**: "YYYY-MM-DD"

**7. 거래 비용**

commission_rate: float = 0.0005  *# 0.05%*

slippage_rate: float = 0.001  *# 0.1%*

- **commission_rate**: 거래 수수료율
- **slippage_rate**: 슬리피지율 (체결 가격과 주문 가격의 차이)

**8. DB 연결 설정**

- DB 연결 정보

## **Output 결과**

**BacktestOutput 클래스**

**1. 성과 지표**

```python
cumulative_return: float  *# 누적 수익률 (소수)*
total_return: float       *# 총 수익률 (%)*
annualized_return: float  *# 연환산 수익률 (%)*
mdd: float               *# Maximum Drawdown (최대 낙폭, %)*
sharpe_ratio: float      *# 샤프 지수*
win_rate: float          *# 승률 (%)*
total_trades: int        *# 총 거래 횟수*
total_profit: float      *# 총 수익 (원)*
total_loss: float        *# 총 손실 (원)*
```

**2. 거래 내역**

trades: List[Dict]

각 거래는 다음 정보를 포함

{

'date': '2024-01-15',      *# 거래 일자*

'symbol': '005930',         *# 종목 코드*

'action': 'BUY',            *# 매매 행위 (BUY/SELL)*

'size': 100,                *# 거래 수량*

'price': 75000.0,           *# 거래 가격*

'amount': 7500000.0,       *# 거래 금액*

'reason': '감성점수: 0.75'  *# 매매 사유*

}

**3. 리포트**

report: str

- 마크다운 형식의 백테스팅 결과 리포트
- 실행 정보, 성과 지표, 손익 분석, 이벤트별 성과, 거래 내역 포함

**4. 이벤트별 수익률 분석**

event_performance: Dict[str, Dict]

각 이벤트 타입별 통계:

{

'earnings': {

'count': 10,           *# 거래 횟수*

'total_profit': 1000000, *# 총 수익*

'total_loss': 500000,   *# 총 손실*

'win_count': 7,         *# 수익 거래 수*

'loss_count': 3         *# 손실 거래 수*

},

'share_buyback': {...},

'general': {...}

}

## **PortfolioStrategy 전략**

### 1. 리밸런싱 메커니즘

- 정기적으로(매월/매주 등) 포트폴리오 재구성
- 현재 보유 종목을 모두 청산하고 새로운 종목 선택
- 리밸런싱 주기: rebalancing_period 파라미터로 설정

### 2. 종목 선택 로직

감성 점수 >= sentiment_buy_th (기본값: 0.3) → 매수감성 점수 <= sentiment_sell_th (기본값: -0.4) → 즉시 청산

- 감성 점수가 임계값 이상인 종목만 매수
- 최대 보유 종목 수 제한 (max_positions)

### 3. 포지션 관리

- 부정적 감성 체크: 감성 점수가 sentiment_sell_th 이하이면 즉시 청산
- ATR 기반 리스크 관리:
- 스탑로스: 현재가 - 2×ATR
- 이익실현: 현재가 + 3×ATR
- 각 종목별 독립적인 리스크 관리

### 4. 기술적 지표 활용

- SMA(이동평균선): 단기(10일), 장기(30일) 이동평균으로 추세 파악
- ATR(평균 진폭): 변동성 지표로 리스크 관리

## **동작 흐름**

1. 데이터 로딩: PostgreSQL에서 주가 데이터 조회
2. 감성 데이터 처리: MongoDB에 데이터가 없으면 임의 생성
3. 데이터 병합: 주가 데이터와 감성 데이터를 날짜 기준으로 병합
4. 백테스팅 실행: Backtrader 엔진으로 전략 실행
5. 결과 분석: 성과 지표, 거래 내역, 이벤트별 분석
6. 리포트 생성: 마크다운 형식의 리포트 생성

### 사용예시

```python
from portfolio_backtest import BacktestInput, run_backtest
import asyncio

# 설정
input_params = BacktestInput(
    start_date="2024-01-01",
    end_date="2024-12-31",
    initial_cash=100_000_000,
    rebalancing_period="monthly",
    max_positions=10
)

# 실행
output = asyncio.run(run_backtest(input_params))

# 결과 확인
print(output.report)
```

![image.png](attachment:09f2b307-6d81-4ad5-8e05-7ab817f87a94:image.png)

## 앞으로 TO DO LIST

**필터링 로직 구현 (높음)**

1. 유니버스 필터링 구현 : 코스피 대형, 중소형 등 
2. 종목 필터링 로직 구현 
    - filter_type 기반 필터링 (top/bottom/value)
    - filter_percent 기반 상위/하위 N% 선택
    - filter_value 기반 값 기준 필터링
    - 필터링 기준 지표 계산 (모멘텀, 펀더멘탈 등)
3. 종목 정렬 로직 구현 : 현재는 감성점수만 구현 
    1. 예시 
        - composite_score: 종합 점수 계산 및 정렬
        - fundamental: 펀더멘탈 지표 기반 정렬
        - sentiment_score: 감성 점수 기반 정렬
        - event_type: 이벤트 타입 우선순위 정렬
4. 업종 필터링 구현
    1. 종목 업종 정보 가져와야 함 

**전략 고도화**

1. 포지션 사이징 개선 (높음)
    1. 균등 분할 투자(현재) → 감성 점수 기반 / 리스크 기반 포지션 사이징  
2.  ****이벤트 기반 매매 로직 강화
    1. 실제 이벤트 데이터 가져오기 
    2. 이벤트별 가중치 적용
    3. 이벤트 조합 적용 
3.  ****리밸런싱 로직 개선 
    1. (현재) 모든 종목 청산 후 재매수 → 부분 리밸런싱
4. 펀더멘탈 데이터 통합 (높음)
    - 현재 상태: 주가 데이터만 사용
    - 구현 필요:
        - 재무제표 데이터 조회 및 통합
        - PER, PBR, ROE 등 지표 계산
        - 펀더멘탈 기반 필터링/정렬
5. 기술적 지표 추가
    - 현재 상태: SMA, ATR만 사용
    - 추가 필요:
    - RSI, MACD, 볼린저 밴드 등
    - 모멘텀 지표 (ROC, Stochastic 등)
    - 추세 지표 (ADX, Parabolic SAR 등)

**분석 및 리포트**

1. 성과 지표 추가
2. LLM 기반 리포트 생성 (높음)
3. 시각화 추가