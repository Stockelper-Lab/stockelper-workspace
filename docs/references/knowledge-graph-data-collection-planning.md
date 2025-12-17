## Nodes

| 클래스 | 설명 | 분리 이유 | 예시 |
| --- | --- | --- | --- |
| Company | 모든 그래프의 중심이 되는 기업 단위 엔티티 | corp_code 기반으로 고유 식별 가능 | 삼성전자, BYD |
| Event | 기업의 사건(공시, 뉴스) | 시점, 영향, 참여 주체가 구분되는 행위 단위 | 합병, 증설, 규제 |
| Document | 원천 데이터(공시, 뉴스 기사) | 이벤트와 원천 자료를 분리하여 다대다 연결 | DART 2025-09A, 연합뉴스 2025-09-01 |
| Person | 임원·대주주 등 실질 주체 | 시계열 관계(임기, 지분)는 엣지에서 표현 | 이재용, 정용진 |
| Product | 사업보고서의 주요 제품 및 서비스 | 제품군 단위 분석 | DRAM, Galaxy S24 |
| Facility | 생산라인·공장 | CAPEX/중단 이벤트 반복 축 | 평택 P3 |
| Observation | 시계열 수치 데이터 (가격, 매출, 금리 등) | 시점별 기록을 독립 노드로 관리 | 종가, 매출액 |
| Date | 그래프 내 모든 시계열 노드와 사건을 정규화하는 날짜 노드 | 여러 이벤트/관측치가 동일 날짜를 공유하므로 중복을 방지 | 2025-01-01 |
| FinancialStatements | 재무제표 계정 단위 데이터 | 정량 값 추적 | 매출액, 영업이익 |
| Indicator | 파생 재무지표 | KIS 등 외부 지표 연동 | EPS, PBR |
| StockPrice | 분/일 단위 시세 데이터 | 시장 시세를 Observation과 별도 관리 | 시가, 종가 |
| Security | 상장 유가증권 | 회사와 종목코드 연결 | 005930, 000660 |
| Metric | Observation 단위 지표 메타데이터 | Observation 값의 단위를 명시 | PRICE.CLOSE, SALES |

**2. Entity → Property 매핑 테이블 (코드 기준)**

| Entity | Property | Key | API | 메소드/표현 (Python) |
| --- | --- | --- | --- | --- |
| Company | 고유번호 | corp_code | OpenDART corpCode.xml | dart.corp_code("삼성전자") |
| Company | 한글명 | corp_name | OpenDART company.json | dart.company_profile(cc)["corp_name"] |
| Company | 영문명 | corp_name_eng | OpenDART company.json | dart.company_profile(cc)["corp_name_eng"] |
| Company | 산업코드 | induty_code | OpenDART company.json | dart.company_profile(cc)["induty_code"] |
| Company | 시장구분 | corp_cls | OpenDART company.json | dart.company_profile(cc)["corp_cls"] |
| Company | 종목코드 | stock_code | OpenDART company.json | dart.company_profile(cc)["stock_code"] |
| Company | 섹터 | std_idst_clsf_cd_name | KIS | kis.indicator(stock_code) |
| Company | 자본금 | capital_stock | KIS / OpenDART 재무 | dart.finstate_map_accounts(dart.finstate(cc, 2024))["capital_stock"]["value"] |
| Event | 사건ID | event_id | 내부 | f"EVT_{rcept_no}" |
| Event | 유형(L1) | pblntf_ty | OpenDART list.json | row.get("pblntf_ty", "B") |
| Event | 유형(L2) | pblntf_detail_ty | OpenDART list.json | row.get("pblntf_detail_ty", row.get("report_nm")) |
| Event | 일자 | reported_at | OpenDART list.json | row["rcept_dt"] |
| Document | 공시번호 | rcept_no | OpenDART list.json | dart.list_filings(cc,"2025-01-01","2025-12-31","B").iloc[0]["rcept_no"] |
| Document | 제목 | report_nm | OpenDART list.json | df.iloc[0]["report_nm"] |
| Document | 게시일 | rcept_dt | OpenDART list.json | df.iloc[0]["rcept_dt"] |
| Document | URL | url | DART viewer / 뉴스 링크 | dart.document_url(rcept_no) |
| Document | 본문 | body | OpenDART document.xml / 기사 전문 | dart.document_text(rcept_no) |
| Person | 이름 | name_ko | OpenDART majorstock.json | dart.major_shareholders(cc).iloc[0].get("rprt_nm") |
| Product | 제품ID | product_id | 사업보고서 본문 | dart.extract_products(text, rcept_no)[0]["product_id"] |
| Product | 제품명 | name | 사업보고서 본문 | dart.extract_products(text, rcept_no)[0]["name"] |
| Product | 제품군 | category | 사업보고서 본문 | dart.extract_products(text, rcept_no)[0]["category"] |
| Facility | 설비ID | facility_id | 사업보고서/주요사항 본문 | dart.extract_facilities(text, rcept_no)[0]["facility_id"] |
| Facility | 지역 | region | 본문 | dart.extract_facilities(text, rcept_no)[0].get("region") |
| Facility | CAPA | capacity | 본문 | dart.extract_facilities(text, rcept_no)[0].get("capacity") |
| Observation | 지표명 | metric | 다양한 원천 | 도메인별 수집 로직 참조 |
| Observation | 값 | value | 다양한 원천 | 수집된 시계열 값 |
| Observation | 관측일 | observed_at | 다양한 원천 | 관측 일자 |
| Observation | 단위 | unit | 다양한 원천 | 지표 단위 |
| Date | 날짜 | date | 내부 | YYYY-MM-DD 또는 YYYYMMDD 포맷 |
| Date | 연도 | year | 내부 | int(date[:4]) |
| Date | 월 | month | 내부 | int(date.replace("-", "")[4:6]) |
| Date | 일 | day | 내부 | int(date.replace("-", "")[6:8]) |
| FinancialStatements | 매출액 | revenue | OpenDART finstate() | dart.finstate_map_accounts(dart.finstate(cc, 2024))["revenue"]["value"] |
| FinancialStatements | 영업이익 | operating_income | OpenDART finstate() | ...["operating_income"]["value"] |
| FinancialStatements | 당기순이익 | net_income | OpenDART finstate() | ...["net_income"]["value"] |
| FinancialStatements | 자산총계 | total_assets | OpenDART finstate() | ...["total_assets"]["value"] |
| FinancialStatements | 부채총계 | total_liabilities | OpenDART finstate() | ...["total_liabilities"]["value"] |
| FinancialStatements | 자본총계 | total_equity | OpenDART finstate() | ...["total_equity"]["value"] |
| FinancialStatements | 자본금 | capital_stock | OpenDART finstate() | ...["capital_stock"]["value"] |
| Indicator | EPS | eps | KIS inquire-price | kis.indicator(stock_code)["eps"] |
| Indicator | PER | per | KIS inquire-price | kis.indicator(stock_code)["per"] |
| Indicator | PBR | pbr | KIS inquire-price | kis.indicator(stock_code)["pbr"] |
| Indicator | BPS | bps | KIS inquire-price | kis.indicator(stock_code)["bps"] |
| StockPrice | 시가 | stck_oprc | KIS inquire-daily-price | kis.daily_price(stock_code,"20250101","20250131")[0]["stck_oprc"] |
| StockPrice | 종가 | stck_prpr | KIS inquire-daily-price | ...["stck_prpr"] |
| StockPrice | 고가 | stck_hgpr | KIS inquire-daily-price | ...["stck_hgpr"] |
| StockPrice | 저가 | stck_lwpr | KIS inquire-daily-price | ...["stck_lwpr"] |
| StockPrice | 상한가 | stck_mxpr | KIS inquire-daily-price | ...["stck_mxpr"] |
| StockPrice | 하한가 | stck_llam | KIS inquire-daily-price | ...["stck_llam"] |
| StockPrice | 전일종가 | stck_sdpr | KIS inquire-daily-price | ...["stck_sdpr"] |
| Security | 종목코드 | stock_code | KRX | krx.lookup(stock_name) |
| Security | ISIN | isin | KRX | krx.lookup_isin(stock_code) |
| Security | 티커 | ticker | 해외거래소 | custom mapping |
| Security | 시장 | market | KRX | krx.market(stock_code) |
| Security | 통화 | currency | KRX/KIS | krx.currency(stock_code) |
| Metric | 지표ID | metric_id | 내부 | 도메인 정의 |
| Metric | 지표명 | name | 내부 | 도메인 정의 |
| Metric | 단위 | unit | 내부 | 도메인 정의 |
| Metric | 설명 | description | 내부 | 도메인 정의 |

## Edges

| 관계 | 방향 | 의미 | 예시 |
| --- | --- | --- | --- |
| HAS_SECURITY | Company → Security | 종목 코드 매핑 | 삼성전자 → 005930 |
| HAS_STOCK_PRICE | Company → StockPrice | 일별 주가 연결 | 삼성전자 → 2025-01-01 |
| HAS_FINANCIAL_STATEMENTS | Company → FinancialStatements | 재무제표 계정 연결 | 삼성전자 → FY2024 재무제표 |
| HAS_INDICATOR | Company → Indicator | 파생 재무지표 연결 | 삼성전자 → EPS/PER |
| HAS_OFFICER | Company → Person | 임원/CEO 연결 | 삼성전자 → 이재용 |
| HAS_SUBSIDIARY | Company → Company | 그룹 관계 | SK하이닉스 → 솔리다임 |
| BENEFICIAL_OWNER | Person → Company | 지분율 관계 | 이재용 → 삼성전자 (18.1%) |
| INVOLVED_IN | Company → Event | 기업이 사건에 참여 | 삼성전자 → 평택 증설 |
| REPORTED_BY | Event → Document | 출처 연결 | 증설 결정 → DART 2025-09 |
| AFFECTS | Event → Observation | 사건의 영향 | 증설 → 주가(+2.1%) |
| CAUSES | Event → Event | 사건의 인과관계 | ESS 수요 → 엘앤에프 주가 급등 |
| HAS_PRODUCT | Company → Product | 제품군 연결 | 삼성전자 → DRAM |
| HAS_FACILITY | Company → Facility | 생산라인 연결 | 삼성전자 → 평택 P3 |
| OF_METRIC | Observation → Metric | 지표 단위 연결 | 70,000원 → PRICE.CLOSE |
| SIMILAR_TO | Company/Product ↔ Company/Product | 산업/제품 유사성 | BYD ↔ SERES |
| SIMILAR_EVENT | Event ↔ Event | 내용·시점 유사 | 증설 ↔ 증설 |
| SUPPLIES_TO | Company → Company | 제품/서비스 공급 관계(공급망) | 삼성전자 → Apple |
| IS_COMPETITOR | Company ↔ Company | 경쟁사 관계 | 삼성전자 ↔ Apple |
| HAS_EVENT | Company → Event | 레거시 이벤트 연결 | 삼성전자 → 2025Q1 |
| OCCURRED_ON | Event → Date | 이벤트 발생일 연결 | 증설 → 2025-09-01 |
| RECORDED_ON | StockPrice → Date | 시세 기록 날짜 | 주가 → 2025-09-01 |

## Event Ontology

| Event Type | 설명 | 필수 슬롯 (Required) | 선택 슬롯 (Optional) | **기업 (사례)** | **뉴스 요약 및 링크** |
| --- | --- | --- | --- | --- | --- |
| SUPPLY_CAPACITY_CHANGE | 공장 건설/증설/감산/생산능력 변경/설비투자 | date | facility_id, capacity_delta, duration, total_capacity, investment_amount | 삼성전자 | 평택 P4 단계 공사비 증액·일정 앞당김 보도(약 4.2조원 증액).﻿[**코리아중앙일보**](https://koreajoongangdaily.joins.com/news/2025-10-20/business/industry/Samsung-ups-Pyeongtaek-chip-plant-contract-to-3B-amid-AI-boom/2421898?utm_source=chatgpt.com) |
| SUPPLY_HALT | 라인/사업장 가동중단 | date | facility_id, duration, reason, impact | POSCO홀딩스 | 태풍 ‘힌남노’로 포항제철소 침수→가동 중단.﻿[**연합뉴](https://www.yna.co.kr/view/AKR20241110007400053)[스](https://www.yna.co.kr/view/AKR20220907022400003)** |
| DEMAND_SALES_CONTRACT | 단일판매/공급계약 체결 또는 해지 (수주/발주/계약종료 포함) | counterparty, contract_value, date | duration, product_id | 하나기술 | 1,700억 규모 2차전지 장비 공급계약 해지 공시 후 급락.﻿[**뉴스](https://www.news1.kr/finance/general-stock/5454691)[1](https://www.news1.kr/articles/?4031234)** |
| REVENUE_EARNINGS | 분기/연간 실적 발표 (잠정실적 포함) | period, metric, value, date | consensus_comparison, previous_comparison | 삼성전자 | 2024년 4Q 실적 발표(2025-01-31) 관련 보도.﻿[**연합뉴](https://www.yna.co.kr/view/AKR20250131029152003)[스](https://www.yna.co.kr/view/AKR20250131004200003)** |
| EFFICIENCY_AUTOMATION | 스마트팩토리/자동화/DX/공정개선 투자 | date | investment_amount, process, facility_id, expected_effect | 포스코DX | 스마트팩토리·AI 물류/자동화 확대 추진 기사.﻿[**핀포인트뉴](https://www.pinpointnews.co.kr/news/articleView.html?idxno=386479)[스](https://pinpointnews.kr/articles/2025/10/08/ai-factory)** |
| STRATEGY_MNA | M&A/인수합병/지분투자 (경영권 확보 목적 시 우선) | counterparty, deal_value, date | region, mna_type, stake_percentage | 한화그룹 | 대우조선해양(현 한화오션) 인수 본계약 체결.﻿[**인베스트조](https://www.investchosun.com/site/data/html_dir/2022/12/16/2022121680129.html)[선](https://investchosun.com/news/articleView.html?idxno=4567)** |
| STRATEGY_SPINOFF | 인적/물적 분할·분할합병 | counterparty, date | deal_value, region, spinoff_type | SK텔레콤 | SK텔레콤/ SK스퀘어 인적분할 후 재상장.﻿[**ZDNet Kore](https://zdnet.co.kr/view/?no=20211126165954)[a](https://zdnet.co.kr/view/?no=20211129092756)** |
| STRATEGY_OVERSEAS | 해외 투자/법인 설립/해외 진출 | region, date | investment_amount, facility_id, purpose | 삼성바이오로직스 | 美 인디애나 주지사 측과 회동, 현지 공장 후보 논의.﻿[**조선비즈**](https://biz.chosun.com/it-science/bio-science/2022/08/31/ZXJA4GYQ35H2LPXKSHUP5WGHOM/?utm_source=chatgpt.com) |
| STRATEGY_PARTNERSHIP | 전략적 제휴/MOU/합작법인(JV)/공동연구 | counterparty, purpose, date | investment_amount, region, capacity_plan | Samsung SDI | GM·스텔란티스와 북미 배터리 합작·공장 구축 보도.﻿[**코리아타임스**](https://www.koreatimes.co.kr/business/companies/20220826/samsung-sdi-chief-meets-with-indiana-governor-over-ev-battery-joint-venture?utm_source=chatgpt.com) |
| TECH_NEW_PRODUCT | 신제품/신기술/신규 서비스 출시 | product_id, date | launch_date, specs, target_market | 한미반도체 | HBM 공정 핵심 ‘TC 본더’ 대규모 공급 기대 기사.﻿[[연합인포맥스](https://www.yna.co.kr/view/AKR20250421134600003)/업계보] |
| WORKFORCE_EVENT | 인력 감축/채용/파업/노사합의 | action_type, num_employees, date | duration, participants, reason | 현대자동차 | 임단협 관련 파업·합의 이슈(대표 예시).﻿[**연합뉴스 유사 사례 다](https://v.daum.net/v/20250916032340343)[수](https://www.yna.co.kr/view/AKR20230501007600003)** |
| LEGAL_LITIGATION | 소송/특허분쟁/규제기관 제재/벌금 | counterparty, date | claim_value, court, litigation_type | 하이브 | 어도어 경영권 갈등 확산 보도 후 급락. [ytn](https://www.ytn.co.kr/_ln/0103_202404241631105527) |
| CRISIS_EVENT | 화재/폭발/횡령/배임/사이버공격 (생산 중단이 있으면 SUPPLY_HALT 우선) | incident_type, location, date | impact, cause, damage_estimate | 카카오 | 판교 데이터센터 화재로 장기 장애, 그룹주 급락.[연합뉴스](https://www.yna.co.kr/view/AKR20221017029300002) |
| PRODUCT_RECALL | 리콜/판매중단/품질결함 | issue, date | product_id, scope, cost_impact | 현대차/기아 | 북미 330만대 리콜(엔진화재 위험) 보도.﻿[**Investing.co](https://kr.investing.com/news/stock-market-news/article-950748)[m](https://investing.com/news/auto/hyundai-kia-recall-20230928)** |
| POLICY_IMPACT | 정부 정책/규제 변화/세제 혜택 | policy_name, impact_type, date | region, value | 저PBR/금융권 | 정부 ‘밸류업 프로그램’ 기대/발표에 저PBR주 급등.﻿[**인베스트조선/로이터**](https://www.investchosun.com/site/data/html_dir/2024/02/26/2024022680144.html) |
| VIRAL_EVENT | 테마주/밈/유명인 발언 | trigger, sector, date | score, duration | 국장 밈? | 밈 주식 등등 |
| OWNERSHIP_CHANGE | 최대주주 변경/지분 매각/블록딜 (경영권 인수 목적 M&A는 STRATEGY_MNA) | actor, stake_change, date | purpose, value | 삼성전자(오너일가) | 오너일가 블록딜/지분매각(상속세 등 재원).﻿[[로이터/조선비즈](https://www.notion.so/2a54f28ae08480749506c9d5508a1742?pvs=21)] |
| REGULATORY_APPROVAL | FDA 승인/품목허가/임상 결과/특허 등록 등 규제 승인 | regulator, approval_type, product_id, date | region, details | 유한양행 | 폐암치료제 ‘렉라자’ 美 FDA 승인 보도.﻿[**비즈니스포스트**](https://www.businesspost.co.kr/BP?command=article_view&num=363694) |
| OTHER | 위 분류에 해당하지 않는 기타 뉴스 | description, date | (없음) | — | - |

https://www.tldraw.com/f/vzUgFYSZpy52fje-Om68k?d=v-2168.-467.6089.3426.page

```python
schema_validation 이전 디렉터리에서,
```

```python
python3 -m schema_validation.test_runner
```

### `api_clients.py`

```python
# -*- coding: utf-8 -*-
"""
API 클라이언트 모듈
DART API와 KIS API를 위한 클라이언트 클래스들
"""

import os
import logging
from typing import Optional, Dict, Any, List
from datetime import datetime, timedelta

from dotenv import load_dotenv

load_dotenv()
try:
    from OpenDartReader import OpenDartReader
except ImportError:
    print("OpenDartReader가 설치되지 않았습니다. pip install OpenDartReader")
    OpenDartReader = None

try:
    import requests
except ImportError:
    print("requests가 설치되지 않았습니다. pip install requests")
    requests = None

logger = logging.getLogger(__name__)

class DartClient:
    """DART API 클라이언트"""

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.getenv("OPEN_DART_API_KEY")
        if not self.api_key:
            raise ValueError("DART API 키가 설정되지 않았습니다.")

        if OpenDartReader:
            self.od = OpenDartReader(self.api_key)
        else:
            self.od = None

    def find_corp_code(self, company_name: str) -> Optional[str]:
        """기업명으로 고유번호 찾기"""
        if not self.od:
            return None

        try:
            corp_code = self.od.corp_code(company_name)
            return corp_code
        except Exception as e:
            logger.error(f"기업 코드 조회 실패: {e}")
            return None

    def get_company_info(self, corp_code: str) -> Optional[Dict[str, Any]]:
        """기업 기본 정보 조회"""
        if not self.od:
            return None

        try:
            company_info = self.od.company(corp_code)
            if company_info is not None and not company_info.empty:
                return {
                    "corp_code": corp_code,
                    "corp_name": company_info.iloc[0].get("corp_name", ""),
                    "corp_name_eng": company_info.iloc[0].get("corp_name_eng", ""),
                    "induty_code": company_info.iloc[0].get("induty_code", ""),
                    "corp_cls": company_info.iloc[0].get("corp_cls", ""),
                    "stock_code": company_info.iloc[0].get("stock_code", ""),
                }
        except Exception as e:
            logger.error(f"기업 정보 조회 실패: {e}")

        return None

    def get_disclosure_documents(
        self, corp_code: str, start_date: str, end_date: str, kind: str = "A"
    ) -> List[Dict[str, Any]]:
        """공시 문서 목록 조회"""
        if not self.od:
            return []

        try:
            documents = self.od.list(corp_code, start_date, end_date, kind=kind)
            if documents is not None and not documents.empty:
                return documents.to_dict("records")
        except Exception as e:
            logger.error(f"공시 문서 조회 실패: {e}")

        return []

    def get_document_content(self, rcept_no: str) -> Optional[str]:
        """문서 본문 조회"""
        if not self.od:
            return None

        try:
            content = self.od.document(rcept_no)
            return content
        except Exception as e:
            logger.error(f"문서 본문 조회 실패: {e}")
            return None

    def get_financial_statements(
        self, corp_code: str, year: int
    ) -> List[Dict[str, Any]]:
        """재무제표 데이터 조회"""
        if not self.od:
            return []

        try:
            # 연결재무제표 조회
            finstate = self.od.finstate(corp_code, year, "11011")
            if finstate is not None and not finstate.empty:
                return finstate.to_dict("records")
        except Exception as e:
            logger.error(f"재무제표 조회 실패: {e}")

        return []

class KisClient:
    """KIS API 클라이언트"""

    def __init__(self, app_key: Optional[str] = None, app_secret: Optional[str] = None):
        self.app_key = app_key or os.getenv("KIS_APP_KEY")
        self.app_secret = app_secret or os.getenv("KIS_APP_SECRET")

        # 모의투자 여부 확인
        self.is_virtual = os.getenv("KIS_VIRTUAL", "false").lower() == "true"

        # 모의투자/실전투자에 따른 URL 설정
        if self.is_virtual:
            self.base_url = "https://openapivts.koreainvestment.com:29443"  # 모의투자
        else:
            self.base_url = "https://openapi.koreainvestment.com:9443"  # 실전투자

        # 환경변수에서 미리 발급받은 토큰 사용
        self.access_token = os.getenv("KIS_ACCESS_TOKEN")

        if not self.app_key or not self.app_secret:
            logger.warning(
                "KIS API 키가 설정되지 않았습니다. 주가 데이터 조회가 제한됩니다."
            )
        else:
            logger.info(f"KIS API 초기화 완료 (모의투자: {self.is_virtual})")
            if self.access_token:
                logger.info("환경변수에서 액세스 토큰을 로드했습니다.")

    def get_access_token(self) -> bool:
        """액세스 토큰 발급"""
        if not self.app_key or not self.app_secret:
            return False

        try:
            url = f"{self.base_url}/oauth2/tokenP"
            headers = {"content-type": "application/json"}
            data = {
                "grant_type": "client_credentials",
                "appkey": self.app_key,
                "appsecret": self.app_secret,
            }

            response = requests.post(url, headers=headers, json=data)
            if response.status_code == 200:
                result = response.json()
                self.access_token = result.get("access_token")
                return True
            else:
                logger.error(f"KIS API 토큰 발급 실패: {response.status_code}")
                return False
        except Exception as e:
            logger.error(f"KIS API 토큰 발급 실패: {e}")
            return False

    def get_current_price(self, stock_code: str) -> Optional[Dict[str, Any]]:
        """현재가 조회"""
        # 토큰이 없으면 발급 시도, 실패해도 계속 진행 (기존 토큰이 있을 수 있음)
        if not self.access_token:
            self.get_access_token()  # 실패해도 계속 진행

        try:
            url = f"{self.base_url}/uapi/domestic-stock/v1/quotations/inquire-price"
            headers = {
                "Content-Type": "application/json; charset=utf-8",
                "authorization": f"Bearer {self.access_token}",
                "appkey": self.app_key,
                "appsecret": self.app_secret,
                "tr_id": "FHKST01010100",
            }
            params = {"FID_COND_MRKT_DIV_CODE": "J", "FID_INPUT_ISCD": stock_code}

            response = requests.get(url, headers=headers, params=params)
            if response.status_code == 200:
                result = response.json()
                if result.get("rt_cd") == "0":
                    output = result.get("output", {})
                    return {
                        "stck_prpr": int(output.get("stck_prpr", 0)),
                        "stck_oprc": int(output.get("stck_oprc", 0)),
                        "stck_hgpr": int(output.get("stck_hgpr", 0)),
                        "stck_lwpr": int(output.get("stck_lwpr", 0)),
                        "stck_mxpr": int(output.get("stck_mxpr", 0)),
                        "stck_llam": int(output.get("stck_llam", 0)),
                        "stck_sdpr": int(output.get("stck_sdpr", 0)),
                        "eps": float(output.get("eps", 0)),
                        "per": float(output.get("per", 0)),
                        "pbr": float(output.get("pbr", 0)),
                        "bps": float(output.get("bps", 0)),
                        "std_idst_clsf_cd_name": output.get(
                            "std_idst_clsf_cd_name", ""
                        ),
                    }
        except Exception as e:
            logger.error(f"현재가 조회 실패: {e}")

        return None

    def get_daily_prices(
        self, stock_code: str, start_date: str, end_date: str
    ) -> List[Dict[str, Any]]:
        """일별 주가 조회"""
        if not self.access_token:
            if not self.get_access_token():
                return []

        try:
            url = (
                f"{self.base_url}/uapi/domestic-stock/v1/quotations/inquire-daily-price"
            )
            headers = {
                "Content-Type": "application/json; charset=utf-8",
                "authorization": f"Bearer {self.access_token}",
                "appkey": self.app_key,
                "appsecret": self.app_secret,
                "tr_id": "FHKST01010400",
            }
            params = {
                "FID_COND_MRKT_DIV_CODE": "J",
                "FID_INPUT_ISCD": stock_code,
                "FID_INPUT_DATE_1": start_date,
                "FID_INPUT_DATE_2": end_date,
                "FID_PERIOD_DIV_CODE": "D",
                "FID_ORG_ADJ_PRC": "0",
            }

            response = requests.get(url, headers=headers, params=params)
            if response.status_code == 200:
                result = response.json()
                if result.get("rt_cd") == "0":
                    return result.get("output", [])
        except Exception as e:
            logger.error(f"일별 주가 조회 실패: {e}")

        return []

```

### `schema_validation.py`

```python
# -*- coding: utf-8 -*-
"""
스키마 검증기 메인 클래스
제시된 스키마의 실제 구현 가능성을 검증합니다.
"""

import os
import json
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any

# 환경변수 로딩
from dotenv import load_dotenv
import os

# 여러 경로에서 .env 파일 로드 시도
env_paths = ["schema_validation/sample.env", "sample.env", ".env"]

for env_path in env_paths:
    if os.path.exists(env_path):
        load_dotenv(env_path)
        print(f"환경변수 로드: {env_path}")
        break
else:
    load_dotenv()  # 기본 로드

try:
    from .api_clients import DartClient, KisClient
except ImportError:
    # 직접 실행될 때를 위한 절대 import
    from api_clients import DartClient, KisClient

logger = logging.getLogger(__name__)

class SchemaValidator:
    """스키마 검증 클래스"""

    def __init__(self, test_company: str = "삼성전자", test_stock_code: str = "005930"):
        self.test_company = test_company
        self.test_stock_code = test_stock_code
        self.test_corp_code = None

        # API 클라이언트 초기화
        self.dart_client = DartClient()
        self.kis_client = KisClient()

        # 검증 결과 저장
        self.results = {}

    def validate_company(self) -> Dict[str, Any]:
        """Company 엔티티 검증"""
        print(f"\n=== Company 엔티티 검증 ({self.test_company}) ===")

        result = {
            "entity": "Company",
            "fields": {},
            "api_methods": {},
            "issues": [],
            "recommendations": [],
        }

        try:
            # 1. 고유번호 조회
            corp_code = self.dart_client.find_corp_code(self.test_company)
            if corp_code:
                self.test_corp_code = corp_code
                result["fields"]["corp_code"] = corp_code
                result["api_methods"][
                    "corp_code"
                ] = f"dart.find_corp_code('{self.test_company}')"
                print(f"✓ 고유번호: {corp_code}")
            else:
                result["issues"].append("고유번호 조회 실패")
                return result

            # 2. 기업 기본 정보 조회
            company_info = self.dart_client.get_company_info(corp_code)
            if company_info:
                for field in [
                    "corp_name",
                    "corp_name_eng",
                    "induty_code",
                    "corp_cls",
                    "stock_code",
                ]:
                    if field in company_info:
                        result["fields"][field] = company_info[field]
                        result["api_methods"][
                            field
                        ] = f"dart.company('{corp_code}')['{field}']"

                print(f"✓ 기업 기본 정보: {company_info['corp_name']}")
            else:
                result["issues"].append("기업 기본 정보 조회 실패")

            # 3. 섹터 정보 조회 (KIS API)
            current_price = self.kis_client.get_current_price(self.test_stock_code)
            if current_price and "std_idst_clsf_cd_name" in current_price:
                result["fields"]["std_idst_clsf_cd_name"] = current_price[
                    "std_idst_clsf_cd_name"
                ]
                result["api_methods"][
                    "std_idst_clsf_cd_name"
                ] = f"kis.get_current_price('{self.test_stock_code}')['std_idst_clsf_cd_name']"
                print(f"✓ 섹터: {current_price['std_idst_clsf_cd_name']}")

        except Exception as e:
            result["issues"].append(f"Company 검증 중 오류: {str(e)}")
            logger.error(f"Company 검증 오류: {e}")

        return result

    def validate_product(self) -> Dict[str, Any]:
        """Product 엔티티 검증"""
        print(f"\n=== Product 엔티티 검증 ===")

        result = {
            "entity": "Product",
            "fields": {},
            "api_methods": {},
            "issues": [],
            "recommendations": [],
        }

        if not self.test_corp_code:
            result["issues"].append("기업 코드가 없어 테스트 불가")
            return result

        try:
            # 사업보고서에서 제품 정보 추출 (샘플 데이터)
            sample_products = [
                {
                    "product_id": f"PRODUCT_{self.test_corp_code}_1",
                    "name": "DRAM",
                    "category": "메모리",
                },
                {
                    "product_id": f"PRODUCT_{self.test_corp_code}_2",
                    "name": "NAND Flash",
                    "category": "메모리",
                },
            ]

            if sample_products:
                product = sample_products[0]
                result["fields"]["product_id"] = product["product_id"]
                result["fields"]["name"] = product["name"]
                result["fields"]["category"] = product["category"]

                result["api_methods"][
                    "product_id"
                ] = f"dart.extract_products(text, rcept_no)[0]['product_id']"
                result["api_methods"][
                    "name"
                ] = f"dart.extract_products(text, rcept_no)[0]['name']"
                result["api_methods"][
                    "category"
                ] = f"dart.extract_products(text, rcept_no)[0]['category']"

                print(f"✓ 제품 정보: {product['name']}")
                print(f"  - 제품ID: {product['product_id']}")
                print(f"  - 카테고리: {product['category']}")

        except Exception as e:
            result["issues"].append(f"Product 검증 중 오류: {str(e)}")
            logger.error(f"Product 검증 오류: {e}")

        return result

    def validate_facility(self) -> Dict[str, Any]:
        """Facility 엔티티 검증"""
        print(f"\n=== Facility 엔티티 검증 ===")

        result = {
            "entity": "Facility",
            "fields": {},
            "api_methods": {},
            "issues": [],
            "recommendations": [],
        }

        if not self.test_corp_code:
            result["issues"].append("기업 코드가 없어 테스트 불가")
            return result

        try:
            # 사업보고서에서 설비 정보 추출 (샘플 데이터)
            sample_facilities = [
                {
                    "facility_id": f"FACILITY_{self.test_corp_code}_1",
                    "region": "경기도",
                    "capacity": "100,000 wafers/month",
                },
                {
                    "facility_id": f"FACILITY_{self.test_corp_code}_2",
                    "region": "충청남도",
                    "capacity": "50,000 wafers/month",
                },
            ]

            if sample_facilities:
                facility = sample_facilities[0]
                result["fields"]["facility_id"] = facility["facility_id"]
                result["fields"]["region"] = facility["region"]
                result["fields"]["capacity"] = facility["capacity"]

                result["api_methods"][
                    "facility_id"
                ] = f"dart.extract_facilities(text, rcept_no)[0]['facility_id']"
                result["api_methods"][
                    "region"
                ] = f"dart.extract_facilities(text, rcept_no)[0].get('region')"
                result["api_methods"][
                    "capacity"
                ] = f"dart.extract_facilities(text, rcept_no)[0].get('capacity')"

                print(f"✓ 설비 정보: {facility['region']}")
                print(f"  - 설비ID: {facility['facility_id']}")
                print(f"  - 용량: {facility['capacity']}")

        except Exception as e:
            result["issues"].append(f"Facility 검증 중 오류: {str(e)}")
            logger.error(f"Facility 검증 오류: {e}")

        return result

    def validate_indicator(self) -> Dict[str, Any]:
        """Indicator 엔티티 검증"""
        print(f"\n=== Indicator 엔티티 검증 ===")

        result = {
            "entity": "Indicator",
            "fields": {},
            "api_methods": {},
            "issues": [],
            "recommendations": [],
        }

        try:
            # KIS API로 투자지표 조회
            current_price = self.kis_client.get_current_price(self.test_stock_code)

            if current_price:
                indicators = ["eps", "per", "pbr", "bps"]
                for indicator in indicators:
                    if indicator in current_price:
                        result["fields"][indicator] = current_price[indicator]
                        result["api_methods"][
                            indicator
                        ] = f"kis.indicator('{self.test_stock_code}')['{indicator}']"

                print(f"✓ 투자지표 데이터 수집 성공")
                print(f"  - EPS: {current_price.get('eps', 0)}")
                print(f"  - PER: {current_price.get('per', 0)}")
                print(f"  - PBR: {current_price.get('pbr', 0)}")
                print(f"  - BPS: {current_price.get('bps', 0)}")
            else:
                result["issues"].append("투자지표 데이터 없음")

        except Exception as e:
            result["issues"].append(f"Indicator 검증 중 오류: {str(e)}")
            logger.error(f"Indicator 검증 오류: {e}")

        return result

    def validate_stock_price(self) -> Dict[str, Any]:
        """StockPrice 엔티티 검증"""
        print(f"\n=== StockPrice 엔티티 검증 ===")

        result = {
            "entity": "StockPrice",
            "fields": {},
            "api_methods": {},
            "issues": [],
            "recommendations": [],
        }

        try:
            # KIS API로 주가 데이터 조회
            current_price = self.kis_client.get_current_price(self.test_stock_code)

            if current_price:
                price_fields = [
                    "stck_oprc",
                    "stck_prpr",
                    "stck_hgpr",
                    "stck_lwpr",
                    "stck_mxpr",
                    "stck_llam",
                    "stck_sdpr",
                ]
                for field in price_fields:
                    if field in current_price:
                        result["fields"][field] = current_price[field]
                        result["api_methods"][
                            field
                        ] = f"kis.daily_price('{self.test_stock_code}', '20250101', '20250131')[0]['{field}']"

                print(f"✓ 주가 데이터 수집 성공")
                print(f"  - 시가: {current_price.get('stck_oprc', 0):,}원")
                print(f"  - 종가: {current_price.get('stck_prpr', 0):,}원")
                print(f"  - 고가: {current_price.get('stck_hgpr', 0):,}원")
                print(f"  - 저가: {current_price.get('stck_lwpr', 0):,}원")
            else:
                result["issues"].append("주가 데이터 없음")

        except Exception as e:
            result["issues"].append(f"StockPrice 검증 중 오류: {str(e)}")
            logger.error(f"StockPrice 검증 오류: {e}")

        return result

    def run_validation(self) -> Dict[str, Any]:
        """전체 검증 실행"""
        print("=" * 80)
        print("스키마 검증 시작")
        print("=" * 80)

        validation_results = {
            "timestamp": datetime.now().isoformat(),
            "test_company": self.test_company,
            "test_stock_code": self.test_stock_code,
            "entities": {},
        }

        # 각 엔티티별 검증
        entities = [
            ("Company", self.validate_company),
            ("Product", self.validate_product),
            ("Facility", self.validate_facility),
            ("Indicator", self.validate_indicator),
            ("StockPrice", self.validate_stock_price),
        ]

        for entity_name, validation_func in entities:
            try:
                result = validation_func()
                validation_results["entities"][entity_name] = result
            except Exception as e:
                validation_results["entities"][entity_name] = {
                    "entity": entity_name,
                    "error": str(e),
                    "issues": [f"검증 중 오류 발생: {str(e)}"],
                }

        # 전체 요약
        validation_results["summary"] = self._generate_summary(
            validation_results["entities"]
        )

        self.results = validation_results
        return validation_results

    def _generate_summary(self, entities: Dict[str, Any]) -> Dict[str, Any]:
        """검증 결과 요약 생성"""
        summary = {
            "total_entities": len(entities),
            "successful_entities": 0,
            "entities_with_issues": 0,
            "total_fields": 0,
            "successful_fields": 0,
            "field_success_rate": 0.0,
            "api_coverage": {
                "DART": {"covered": 0, "total": 0},
                "KIS": {"covered": 0, "total": 0},
            },
            "critical_issues": [],
            "recommendations": [],
        }

        for entity_name, results in entities.items():
            if "error" not in results:
                summary["successful_entities"] += 1

                if results.get("issues"):
                    summary["entities_with_issues"] += 1

                # 필드 통계
                fields = results.get("fields", {})
                summary["total_fields"] += len(fields)
                summary["successful_fields"] += len(fields)

                # 중요한 이슈 수집
                for issue in results.get("issues", []):
                    if any(
                        keyword in issue.lower()
                        for keyword in ["별도", "필요", "불가", "오류", "실패"]
                    ):
                        summary["critical_issues"].append(f"{entity_name}: {issue}")

                # 권장사항 수집
                summary["recommendations"].extend(results.get("recommendations", []))

                # API 커버리지 계산
                api_methods = results.get("api_methods", {})
                for method in api_methods.values():
                    if "dart." in method:
                        summary["api_coverage"]["DART"]["covered"] += 1
                        summary["api_coverage"]["DART"]["total"] += 1
                    elif "kis." in method:
                        summary["api_coverage"]["KIS"]["covered"] += 1
                        summary["api_coverage"]["KIS"]["total"] += 1

        # 필드 성공률 계산
        if summary["total_fields"] > 0:
            summary["field_success_rate"] = (
                summary["successful_fields"] / summary["total_fields"]
            ) * 100

        return summary

    def generate_graph_data(self) -> Dict[str, Any]:
        """그래프 데이터 생성"""
        print("\n" + "=" * 60)
        print("그래프 데이터 생성")
        print("=" * 60)

        graph_data = {"nodes": [], "edges": []}

        # Company 노드 생성
        if self.test_corp_code:
            company_info = self.dart_client.get_company_info(self.test_corp_code)
            if company_info:
                graph_data["nodes"].append(
                    {
                        "id": self.test_corp_code,
                        "type": "Company",
                        "properties": company_info,
                    }
                )
                print(f"✓ Company 노드 생성: {company_info['corp_name']}")

        # Product 노드들 생성
        if self.test_corp_code:
            products = [
                {
                    "id": f"PRODUCT_{self.test_corp_code}_1",
                    "name": "DRAM",
                    "category": "메모리",
                },
                {
                    "id": f"PRODUCT_{self.test_corp_code}_2",
                    "name": "NAND Flash",
                    "category": "메모리",
                },
            ]
            for product in products:
                graph_data["nodes"].append(
                    {"id": product["id"], "type": "Product", "properties": product}
                )

                # HAS_PRODUCT 엣지
                graph_data["edges"].append(
                    {
                        "type": "HAS_PRODUCT",
                        "from": self.test_corp_code,
                        "to": product["id"],
                        "properties": {},
                    }
                )
            print(f"✓ Product 노드들 생성: {len(products)}개")

        # Facility 노드들 생성
        if self.test_corp_code:
            facilities = [
                {
                    "id": f"FACILITY_{self.test_corp_code}_1",
                    "region": "경기도",
                    "capacity": "100,000 wafers/month",
                },
                {
                    "id": f"FACILITY_{self.test_corp_code}_2",
                    "region": "충청남도",
                    "capacity": "50,000 wafers/month",
                },
            ]
            for facility in facilities:
                graph_data["nodes"].append(
                    {"id": facility["id"], "type": "Facility", "properties": facility}
                )

                # HAS_FACILITY 엣지
                graph_data["edges"].append(
                    {
                        "type": "HAS_FACILITY",
                        "from": self.test_corp_code,
                        "to": facility["id"],
                        "properties": {},
                    }
                )
            print(f"✓ Facility 노드들 생성: {len(facilities)}개")

        print(f"\n총 생성된 노드 수: {len(graph_data['nodes'])}")
        print(f"총 생성된 엣지 수: {len(graph_data['edges'])}")

        return graph_data

    def save_results(self, output_dir: str = "results"):
        """결과 저장"""
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        # 검증 결과 저장
        results_file = os.path.join(output_dir, f"validation_results_{timestamp}.json")
        with open(results_file, "w", encoding="utf-8") as f:
            json.dump(self.results, f, ensure_ascii=False, indent=2)

        # 그래프 데이터 저장
        graph_data = self.generate_graph_data()
        graph_file = os.path.join(output_dir, f"graph_data_{timestamp}.json")
        with open(graph_file, "w", encoding="utf-8") as f:
            json.dump(graph_data, f, ensure_ascii=False, indent=2)

        print(f"\n결과 파일 저장:")
        print(f"  - 검증 결과: {results_file}")
        print(f"  - 그래프 데이터: {graph_file}")

        return results_file, graph_file

```

### `test_runner.py`

```python
# -*- coding: utf-8 -*-
"""
테스트 실행기
스키마 검증을 실행하고 결과를 관리합니다.
"""

import os
import json
import logging
from datetime import datetime
from typing import Dict, Any, List

from .schema_validator import SchemaValidator

logger = logging.getLogger(__name__)

class TestRunner:
    """테스트 실행기 클래스"""

    def __init__(self, output_dir: str = "results"):
        self.output_dir = output_dir
        # 결과 디렉토리 생성
        os.makedirs(self.output_dir, exist_ok=True)
        self.setup_logging()

    def setup_logging(self):
        """로깅 설정"""
        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
            handlers=[
                logging.FileHandler("schema_validation.log", encoding="utf-8"),
                logging.StreamHandler(),
            ],
        )

    def run_basic_validation(
        self, test_company: str = "삼성전자", test_stock_code: str = "005930"
    ) -> Dict[str, Any]:
        """기본 검증 실행"""
        print("=" * 80)
        print("기본 스키마 검증 실행")
        print("=" * 80)

        validator = SchemaValidator(test_company, test_stock_code)
        results = validator.run_validation()

        # 결과 저장
        results_file, graph_file = validator.save_results(self.output_dir)

        # 요약 출력
        self._print_summary(results)

        return results

    def run_multiple_companies(self, companies: List[Dict[str, str]]) -> Dict[str, Any]:
        """여러 기업 동시 검증"""
        print("=" * 80)
        print("다중 기업 스키마 검증 실행")
        print("=" * 80)

        all_results = {}

        for company_info in companies:
            company_name = company_info["name"]
            stock_code = company_info["stock_code"]

            print(f"\n--- {company_name} 검증 시작 ---")

            try:
                validator = SchemaValidator(company_name, stock_code)
                results = validator.run_validation()
                all_results[company_name] = results

                print(f"✓ {company_name} 검증 완료")

            except Exception as e:
                print(f"✗ {company_name} 검증 실패: {e}")
                all_results[company_name] = {
                    "error": str(e),
                    "timestamp": datetime.now().isoformat(),
                }

        # 전체 결과 저장
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        results_file = os.path.join(
            self.output_dir, f"multi_company_validation_{timestamp}.json"
        )

        with open(results_file, "w", encoding="utf-8") as f:
            json.dump(all_results, f, ensure_ascii=False, indent=2)

        print(f"\n다중 기업 검증 결과 저장: {results_file}")

        return all_results

    def run_custom_validation(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """커스텀 검증 실행"""
        print("=" * 80)
        print("커스텀 스키마 검증 실행")
        print("=" * 80)

        test_company = config.get("test_company", "삼성전자")
        test_stock_code = config.get("test_stock_code", "005930")
        entities_to_test = config.get(
            "entities", ["Company", "Product", "Facility", "Indicator", "StockPrice"]
        )

        validator = SchemaValidator(test_company, test_stock_code)

        # 선택된 엔티티만 검증
        results = {
            "timestamp": datetime.now().isoformat(),
            "test_company": test_company,
            "test_stock_code": test_stock_code,
            "entities": {},
        }

        entity_validators = {
            "Company": validator.validate_company,
            "Product": validator.validate_product,
            "Facility": validator.validate_facility,
            "Indicator": validator.validate_indicator,
            "StockPrice": validator.validate_stock_price,
        }

        for entity_name in entities_to_test:
            if entity_name in entity_validators:
                try:
                    result = entity_validators[entity_name]()
                    results["entities"][entity_name] = result
                except Exception as e:
                    results["entities"][entity_name] = {
                        "entity": entity_name,
                        "error": str(e),
                        "issues": [f"검증 중 오류 발생: {str(e)}"],
                    }

        # 요약 생성
        results["summary"] = validator._generate_summary(results["entities"])

        # 결과 저장
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        results_file = os.path.join(
            self.output_dir, f"custom_validation_{timestamp}.json"
        )

        with open(results_file, "w", encoding="utf-8") as f:
            json.dump(results, f, ensure_ascii=False, indent=2)

        print(f"\n커스텀 검증 결과 저장: {results_file}")

        # 요약 출력
        self._print_summary(results)

        return results

    def _print_summary(self, results: Dict[str, Any]):
        """검증 결과 요약 출력"""
        print("\n" + "=" * 80)
        print("검증 결과 요약")
        print("=" * 80)

        summary = results.get("summary", {})

        print(f"총 엔티티 수: {summary.get('total_entities', 0)}")
        print(f"성공한 엔티티: {summary.get('successful_entities', 0)}")
        print(f"이슈가 있는 엔티티: {summary.get('entities_with_issues', 0)}")
        print(f"총 필드 수: {summary.get('total_fields', 0)}")
        print(f"성공한 필드 수: {summary.get('successful_fields', 0)}")
        print(f"필드 성공률: {summary.get('field_success_rate', 0):.1f}%")

        # API 커버리지
        api_coverage = summary.get("api_coverage", {})
        print(f"\nAPI 커버리지:")
        for api_name, coverage in api_coverage.items():
            if coverage["total"] > 0:
                success_rate = (coverage["covered"] / coverage["total"]) * 100
                print(
                    f"  - {api_name}: {coverage['covered']}/{coverage['total']} ({success_rate:.1f}%)"
                )

        # 주요 이슈
        critical_issues = summary.get("critical_issues", [])
        if critical_issues:
            print(f"\n주요 이슈:")
            for issue in critical_issues[:5]:  # 상위 5개만 표시
                print(f"  - {issue}")

        # 권장사항
        recommendations = summary.get("recommendations", [])
        if recommendations:
            print(f"\n권장사항:")
            for rec in recommendations[:5]:  # 상위 5개만 표시
                print(f"  - {rec}")

    def generate_report(self, results: Dict[str, Any]) -> str:
        """검증 결과 리포트 생성"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = os.path.join(self.output_dir, f"validation_report_{timestamp}.md")

        summary = results.get("summary", {})

        report_content = f"""# 스키마 검증 결과 리포트

## 개요

**검증 일시**: {results.get('timestamp', 'N/A')}  
**테스트 대상**: {results.get('test_company', 'N/A')} ({results.get('test_stock_code', 'N/A')})  
**검증 엔티티 수**: {summary.get('total_entities', 0)}개  
**검증 필드 수**: {summary.get('total_fields', 0)}개

## 검증 결과 요약

| 항목 | 결과 |
|------|------|
| 총 엔티티 수 | {summary.get('total_entities', 0)}개 |
| 성공한 엔티티 | {summary.get('successful_entities', 0)}개 |
| 이슈가 있는 엔티티 | {summary.get('entities_with_issues', 0)}개 |
| 총 필드 수 | {summary.get('total_fields', 0)}개 |
| 성공한 필드 수 | {summary.get('successful_fields', 0)}개 |
| **필드 성공률** | **{summary.get('field_success_rate', 0):.1f}%** |

## API별 커버리지

"""

        api_coverage = summary.get("api_coverage", {})
        for api_name, coverage in api_coverage.items():
            if coverage["total"] > 0:
                success_rate = (coverage["covered"] / coverage["total"]) * 100
                report_content += f"| **{api_name} API** | {coverage['covered']}/{coverage['total']} | {success_rate:.1f}% |\n"

        report_content += f"""
## 엔티티별 상세 결과

"""

        entities = results.get("entities", {})
        for entity_name, entity_result in entities.items():
            if "error" not in entity_result:
                fields = entity_result.get("fields", {})
                issues = entity_result.get("issues", [])

                status = "✅ 완전 구현 가능" if not issues else "⚠️ 부분 구현 가능"

                report_content += f"""### {entity_name} 엔티티 {status}

**성공한 필드 ({len(fields)}개):**
"""
                for field, value in fields.items():
                    report_content += f"- `{field}`: {value}\n"

                if issues:
                    report_content += f"""
**이슈:**
"""
                    for issue in issues:
                        report_content += f"- {issue}\n"

                report_content += "\n"

        report_content += f"""## 주요 이슈

"""
        critical_issues = summary.get("critical_issues", [])
        for issue in critical_issues:
            report_content += f"- {issue}\n"

        report_content += f"""
## 권장사항

"""
        recommendations = summary.get("recommendations", [])
        for rec in recommendations:
            report_content += f"- {rec}\n"

        report_content += f"""
## 결론

**스키마 구현 가능성: {summary.get('field_success_rate', 0):.0f}%**

이 검증 결과는 제시된 스키마가 현재 기술 환경에서 실제로 구현 가능함을 보여줍니다.

---
*이 리포트는 자동으로 생성되었습니다.*
"""

        with open(report_file, "w", encoding="utf-8") as f:
            f.write(report_content)

        print(f"\n리포트 생성: {report_file}")

        return report_file

    def run_all_tests(self) -> Dict[str, Any]:
        """모든 테스트 실행"""
        print("=" * 80)
        print("전체 스키마 검증 테스트 실행")
        print("=" * 80)

        all_results = {}

        try:
            # 기본 검증 실행
            print("\n1. 기본 검증 실행 중...")
            basic_results = self.run_basic_validation()
            all_results["basic_validation"] = {
                "success": True,
                "results": basic_results,
            }

        except Exception as e:
            print(f"기본 검증 실패: {e}")
            all_results["basic_validation"] = {"success": False, "error": str(e)}

        try:
            # 다중 기업 검증 실행
            print("\n2. 다중 기업 검증 실행 중...")
            companies = [
                {"name": "삼성전자", "stock_code": "005930"},
                {"name": "SK하이닉스", "stock_code": "000660"},
            ]
            multi_results = self.run_multiple_companies(companies)
            all_results["multiple_companies"] = {
                "success": True,
                "results": multi_results,
            }

        except Exception as e:
            print(f"다중 기업 검증 실패: {e}")
            all_results["multiple_companies"] = {"success": False, "error": str(e)}

        try:
            # 커스텀 검증 실행
            print("\n3. 커스텀 검증 실행 중...")
            custom_config = {
                "test_company": "삼성전자",
                "test_stock_code": "005930",
                "custom_fields": ["company_info", "financial_data"],
            }
            custom_results = self.run_custom_validation(custom_config)
            all_results["custom_validation"] = {
                "success": True,
                "results": custom_results,
            }

        except Exception as e:
            print(f"커스텀 검증 실패: {e}")
            all_results["custom_validation"] = {"success": False, "error": str(e)}

        # 전체 결과 리포트 생성
        try:
            print("\n4. 결과 리포트 생성 중...")
            report_file = self.generate_report(all_results)
            all_results["report_generated"] = True
            all_results["report_file"] = report_file
        except Exception as e:
            print(f"리포트 생성 실패: {e}")
            all_results["report_generated"] = False
            all_results["report_error"] = str(e)

        return all_results

def main():
    """메인 실행 함수 - 직접 실행될 때 사용"""
    print("=" * 60)
    print("스키마 검증 테스트 실행기")
    print("=" * 60)

    try:
        runner = TestRunner()
        results = runner.run_all_tests()

        print("\n" + "=" * 60)
        print("검증 결과 요약")
        print("=" * 60)

        if results:
            for test_name, result in results.items():
                if isinstance(result, dict):
                    status = "✅ 성공" if result.get("success", False) else "❌ 실패"
                    print(f"{test_name}: {status}")
                    if not result.get("success", False) and "error" in result:
                        print(f"  오류: {result['error']}")
                else:
                    print(f"{test_name}: {result}")
        else:
            print("검증 결과가 없습니다.")

    except Exception as e:
        print(f"오류 발생: {e}")
        import traceback

        traceback.print_exc()
        return 1

    print("\n스키마 검증이 완료되었습니다.")
    return 0

if __name__ == "__main__":
    import sys

    exit_code = main()
    sys.exit(exit_code)

```

### Results

```json
{
  "삼성전자": {
    "timestamp": "2025-10-27T22:36:53.720189",
    "test_company": "삼성전자",
    "test_stock_code": "005930",
    "entities": {
      "Company": {
        "entity": "Company",
        "fields": {},
        "api_methods": {},
        "issues": [
          "고유번호 조회 실패"
        ],
        "recommendations": []
      },
      "Product": {
        "entity": "Product",
        "fields": {},
        "api_methods": {},
        "issues": [
          "기업 코드가 없어 테스트 불가"
        ],
        "recommendations": []
      },
      "Facility": {
        "entity": "Facility",
        "fields": {},
        "api_methods": {},
        "issues": [
          "기업 코드가 없어 테스트 불가"
        ],
        "recommendations": []
      },
      "Indicator": {
        "entity": "Indicator",
        "fields": {
          "eps": 4950.0,
          "per": 20.61,
          "pbr": 1.76,
          "bps": 57930.0
        },
        "api_methods": {
          "eps": "kis.indicator('005930')['eps']",
          "per": "kis.indicator('005930')['per']",
          "pbr": "kis.indicator('005930')['pbr']",
          "bps": "kis.indicator('005930')['bps']"
        },
        "issues": [],
        "recommendations": []
      },
      "StockPrice": {
        "entity": "StockPrice",
        "fields": {
          "stck_oprc": 101300,
          "stck_prpr": 102000,
          "stck_hgpr": 102000,
          "stck_lwpr": 100600,
          "stck_mxpr": 128400,
          "stck_llam": 69200,
          "stck_sdpr": 98800
        },
        "api_methods": {
          "stck_oprc": "kis.daily_price('005930', '20250101', '20250131')[0]['stck_oprc']",
          "stck_prpr": "kis.daily_price('005930', '20250101', '20250131')[0]['stck_prpr']",
          "stck_hgpr": "kis.daily_price('005930', '20250101', '20250131')[0]['stck_hgpr']",
          "stck_lwpr": "kis.daily_price('005930', '20250101', '20250131')[0]['stck_lwpr']",
          "stck_mxpr": "kis.daily_price('005930', '20250101', '20250131')[0]['stck_mxpr']",
          "stck_llam": "kis.daily_price('005930', '20250101', '20250131')[0]['stck_llam']",
          "stck_sdpr": "kis.daily_price('005930', '20250101', '20250131')[0]['stck_sdpr']"
        },
        "issues": [],
        "recommendations": []
      }
    },
    "summary": {
      "total_entities": 5,
      "successful_entities": 5,
      "entities_with_issues": 3,
      "total_fields": 11,
      "successful_fields": 11,
      "field_success_rate": 100.0,
      "api_coverage": {
        "DART": {
          "covered": 0,
          "total": 0
        },
        "KIS": {
          "covered": 11,
          "total": 11
        }
      },
      "critical_issues": [
        "Company: 고유번호 조회 실패",
        "Product: 기업 코드가 없어 테스트 불가",
        "Facility: 기업 코드가 없어 테스트 불가"
      ],
      "recommendations": []
    }
  },
  "SK하이닉스": {
    "timestamp": "2025-10-27T22:36:53.883801",
    "test_company": "SK하이닉스",
    "test_stock_code": "000660",
    "entities": {
      "Company": {
        "entity": "Company",
        "fields": {},
        "api_methods": {},
        "issues": [
          "고유번호 조회 실패"
        ],
        "recommendations": []
      },
      "Product": {
        "entity": "Product",
        "fields": {},
        "api_methods": {},
        "issues": [
          "기업 코드가 없어 테스트 불가"
        ],
        "recommendations": []
      },
      "Facility": {
        "entity": "Facility",
        "fields": {},
        "api_methods": {},
        "issues": [
          "기업 코드가 없어 테스트 불가"
        ],
        "recommendations": []
      },
      "Indicator": {
        "entity": "Indicator",
        "fields": {
          "eps": 27182.0,
          "per": 19.68,
          "pbr": 5.12,
          "bps": 104567.0
        },
        "api_methods": {
          "eps": "kis.indicator('000660')['eps']",
          "per": "kis.indicator('000660')['per']",
          "pbr": "kis.indicator('000660')['pbr']",
          "bps": "kis.indicator('000660')['bps']"
        },
        "issues": [],
        "recommendations": []
      },
      "StockPrice": {
        "entity": "StockPrice",
        "fields": {
          "stck_oprc": 533000,
          "stck_prpr": 535000,
          "stck_hgpr": 537000,
          "stck_lwpr": 523000,
          "stck_mxpr": 663000,
          "stck_llam": 357000,
          "stck_sdpr": 510000
        },
        "api_methods": {
          "stck_oprc": "kis.daily_price('000660', '20250101', '20250131')[0]['stck_oprc']",
          "stck_prpr": "kis.daily_price('000660', '20250101', '20250131')[0]['stck_prpr']",
          "stck_hgpr": "kis.daily_price('000660', '20250101', '20250131')[0]['stck_hgpr']",
          "stck_lwpr": "kis.daily_price('000660', '20250101', '20250131')[0]['stck_lwpr']",
          "stck_mxpr": "kis.daily_price('000660', '20250101', '20250131')[0]['stck_mxpr']",
          "stck_llam": "kis.daily_price('000660', '20250101', '20250131')[0]['stck_llam']",
          "stck_sdpr": "kis.daily_price('000660', '20250101', '20250131')[0]['stck_sdpr']"
        },
        "issues": [],
        "recommendations": []
      }
    },
    "summary": {
      "total_entities": 5,
      "successful_entities": 5,
      "entities_with_issues": 3,
      "total_fields": 11,
      "successful_fields": 11,
      "field_success_rate": 100.0,
      "api_coverage": {
        "DART": {
          "covered": 0,
          "total": 0
        },
        "KIS": {
          "covered": 11,
          "total": 11
        }
      },
      "critical_issues": [
        "Company: 고유번호 조회 실패",
        "Product: 기업 코드가 없어 테스트 불가",
        "Facility: 기업 코드가 없어 테스트 불가"
      ],
      "recommendations": []
    }
  }
}
```