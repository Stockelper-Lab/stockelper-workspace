```python
"""
DART 공시 정보 수집기 (상장사 대상) - 확장판
=============================================

상장 기업들의 특정 기간 공시 정보를 수집하여 Excel로 내보내는 스크립트입니다.
dart_api_collector.py의 36개 주요사항보고서 API 유형별 수집 체계를 지원합니다.

주요 기능:
1. 상장사 고유번호 매핑 테이블 생성
2. DART 공시목록 API를 통한 전체 공시 수집
3. 36개 주요사항보고서 API를 통한 유형별 상세 정보 수집
4. 수집된 공시 데이터를 Excel로 내보내기 (유형별 시트 분리)

사용법:
    # 전체 공시 수집
    python dart_disclosure_collector.py

    # 테스트 모드 (랜덤 100개 기업)
    python dart_disclosure_collector.py test 100

    # 주요사항보고서 유형별 수집
    python dart_disclosure_collector.py major

    # 주요사항보고서 유형별 수집 테스트
    python dart_disclosure_collector.py major test 100
"""

import os
import io
import zipfile
import xml.etree.ElementTree as ET
from typing import Optional, Dict, Any, List, Tuple, Union
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
import time
import random
import requests
import pandas as pd
from pathlib import Path

# 프로젝트 설정
from config import dart_api_key

# ==================== 주요사항보고서 API 정의 ====================

class MajorReportType(Enum):
    """
    주요사항보고서 API 유형 (36개)

    각 항목은 (endpoint, 한글명, 카테고리) 형식
    """
    # 기업 상태 관련
    AST_INHTRF_ETC_PTBK_OPT = ("astInhtrfEtcPtbkOpt", "자산양수도(기타)_풋백옵션", "기업상태")
    DF_OCR = ("dfOcr", "부도발생", "기업상태")
    BSN_SP = ("bsnSp", "영업정지", "기업상태")
    CTRCVS_BGRQ = ("ctrcvsBgrq", "회생절차_개시신청", "기업상태")
    DS_RS_OCR = ("dsRsOcr", "해산사유_발생", "기업상태")

    # 증자/감자 관련
    PIIC_DECSN = ("piicDecsn", "유상증자_결정", "증자감자")
    FRIC_DECSN = ("fricDecsn", "무상증자_결정", "증자감자")
    PIFRIC_DECSN = ("pifricDecsn", "유무상증자_결정", "증자감자")
    CR_DECSN = ("crDecsn", "감자_결정", "증자감자")

    # 채권은행 관련
    EX_BNK_MNG_PCBG = ("exBnkMngPcbg", "채권은행_관리절차_개시", "채권은행")
    EX_BNK_MNG_PCSP = ("exBnkMngPcsp", "채권은행_관리절차_중단", "채권은행")

    # 소송 관련
    LWST_ETC_PRPS = ("lwstEtcPrps", "소송등_제기", "소송")

    # 해외 상장 관련
    OVSCS_MKT_LST_DECSN = ("ovscsMktLstDecsn", "해외증권시장_상장_결정", "해외상장")
    OVSCS_MKT_DLST_DECSN = ("ovscsMktDlstDecsn", "해외증권시장_상장폐지_결정", "해외상장")
    OVSCS_MKT_LST = ("ovscsMktLst", "해외증권시장_상장", "해외상장")
    OVSCS_MKT_DLST = ("ovscsMktDlst", "해외증권시장_상장폐지", "해외상장")

    # 사채 발행 관련
    CVBD_IS_DECSN = ("cvbdIsDecsn", "전환사채권_발행결정", "사채발행")
    BDWT_IS_DECSN = ("bdwtIsDecsn", "신주인수권부사채권_발행결정", "사채발행")
    EXBD_IS_DECSN = ("exbdIsDecsn", "교환사채권_발행결정", "사채발행")
    WOCCS_IS_DECSN = ("woccsIsDecsn", "상각형_조건부자본증권_발행결정", "사채발행")

    # 자기주식 관련
    TSSTK_AQ_DECSN = ("tsstkAqDecsn", "자기주식_취득_결정", "자기주식")
    TSSTK_DP_DECSN = ("tsstkDpDecsn", "자기주식_처분_결정", "자기주식")
    TSSTK_AQ_TRC_CTR_DECSN = ("tsstkAqTrcCtrDecsn", "자기주식취득_신탁계약_체결_결정", "자기주식")
    TSSTK_AQ_TRC_CTR_CC_DECSN = ("tsstkAqTrcCtrCcDecsn", "자기주식취득_신탁계약_해지_결정", "자기주식")

    # 영업양수도 관련
    BSN_INH_DECSN = ("bsnInhDecsn", "영업양수_결정", "영업양수도")
    BSN_TRF_DECSN = ("bsnTrfDecsn", "영업양도_결정", "영업양수도")

    # 자산양수도 관련
    TG_AST_INH_DECSN = ("tgAstInhDecsn", "유형자산_양수_결정", "자산양수도")
    TG_AST_TRF_DECSN = ("tgAstTrfDecsn", "유형자산_양도_결정", "자산양수도")

    # 타법인 주식 관련
    OTCPR_STK_INH_DECSN = ("otcprStkInhDecsn", "타법인주식_양수결정", "타법인주식")
    OTCPR_STK_TRF_DECSN = ("otcprStkTrfDecsn", "타법인주식_양도결정", "타법인주식")

    # 사채권 양수도 관련
    STK_RTBD_INH_DECSN = ("stkRtbdInhDecsn", "주권관련_사채권_양수_결정", "사채권양수도")
    STK_RTBD_TRF_DECSN = ("stkRtbdTrfDecsn", "주권관련_사채권_양도_결정", "사채권양수도")

    # 합병/분할 관련
    CMP_MG_DECSN = ("cmpMgDecsn", "회사합병_결정", "합병분할")
    CMP_DV_DECSN = ("cmpDvDecsn", "회사분할_결정", "합병분할")
    CMP_DVMG_DECSN = ("cmpDvmgDecsn", "회사분할합병_결정", "합병분할")
    STK_EXTR_DECSN = ("stkExtrDecsn", "주식교환이전_결정", "합병분할")

    def __init__(self, endpoint: str, name: str, category: str):
        self._endpoint = endpoint
        self._name = name
        self._category = category

    @property
    def endpoint(self) -> str:
        return self._endpoint

    @property
    def name(self) -> str:
        return self._name

    @property
    def category(self) -> str:
        return self._category

    @classmethod
    def get_by_category(cls, category: str) -> List['MajorReportType']:
        """카테고리별 API 유형 반환"""
        return [t for t in cls if t.category == category]

    @classmethod
    def get_all_categories(cls) -> List[str]:
        """모든 카테고리 반환"""
        return list(set(t.category for t in cls))

# 카테고리별 그룹 정의
REPORT_CATEGORIES = {
    "기업상태": ["부도발생", "영업정지", "회생절차", "해산사유", "자산양수도"],
    "증자감자": ["유상증자", "무상증자", "유무상증자", "감자"],
    "채권은행": ["채권은행 관리절차"],
    "소송": ["소송 제기"],
    "해외상장": ["해외 증권시장 상장/상장폐지"],
    "사채발행": ["전환사채권", "신주인수권부사채권", "교환사채권", "조건부자본증권"],
    "자기주식": ["자기주식 취득/처분", "신탁계약"],
    "영업양수도": ["영업양수", "영업양도"],
    "자산양수도": ["유형자산 양수/양도"],
    "타법인주식": ["타법인 주식 양수/양도"],
    "사채권양수도": ["주권관련 사채권 양수/양도"],
    "합병분할": ["회사합병", "회사분할", "분할합병", "주식교환이전"],
}

# ==================== 데이터 모델 ====================

@dataclass
class ListedCompany:
    """상장사 정보"""
    corp_code: str      # 고유번호 (8자리)
    corp_name: str      # 회사명
    stock_code: str     # 종목코드 (6자리)
    corp_cls: str = ""  # 법인구분 (Y=유가증권, K=코스닥, N=코넥스)

    @property
    def market_name(self) -> str:
        """시장 구분명"""
        mapping = {"Y": "유가증권", "K": "코스닥", "N": "코넥스", "E": "기타"}
        return mapping.get(self.corp_cls, "기타")

@dataclass
class Disclosure:
    """일반 공시 정보"""
    corp_code: str          # 고유번호
    corp_name: str          # 회사명
    stock_code: str         # 종목코드
    corp_cls: str           # 법인구분
    report_nm: str          # 보고서명
    rcept_no: str           # 접수번호
    flr_nm: str             # 공시제출인명
    rcept_dt: str           # 접수일자 (YYYYMMDD)
    rm: str                 # 비고

    def to_dict(self) -> Dict:
        return {
            "고유번호": self.corp_code,
            "회사명": self.corp_name,
            "종목코드": self.stock_code,
            "법인구분": self.corp_cls,
            "보고서명": self.report_nm,
            "접수번호": self.rcept_no,
            "공시제출인명": self.flr_nm,
            "접수일자": self.rcept_dt,
            "비고": self.rm
        }

@dataclass
class MajorReport:
    """주요사항보고서 정보"""
    report_type: str        # 보고서 유형
    category: str           # 카테고리
    corp_code: str          # 고유번호
    corp_name: str          # 회사명
    stock_code: str         # 종목코드
    corp_cls: str           # 법인구분
    rcept_no: str           # 접수번호
    rcept_dt: str           # 접수일자
    raw_data: Dict = field(default_factory=dict)  # 원본 데이터

    def to_dict(self) -> Dict:
        base = {
            "보고서유형": self.report_type,
            "카테고리": self.category,
            "고유번호": self.corp_code,
            "회사명": self.corp_name,
            "종목코드": self.stock_code,
            "법인구분": self.corp_cls,
            "접수번호": self.rcept_no,
            "접수일자": self.rcept_dt,
        }
        # 원본 데이터의 주요 필드 추가
        for key, value in self.raw_data.items():
            if key not in ['corp_code', 'corp_name', 'corp_cls', 'rcept_no']:
                base[key] = value
        return base

# ==================== API 오류 클래스 ====================

class DartAPIError(Exception):
    """DART API 오류"""

    ERROR_CODES = {
        "000": "정상",
        "010": "등록되지 않은 키입니다.",
        "011": "사용할 수 없는 키입니다.",
        "012": "접근할 수 없는 IP입니다.",
        "013": "조회된 데이타가 없습니다.",
        "014": "파일이 존재하지 않습니다.",
        "020": "요청 제한을 초과하였습니다.",
        "100": "필드의 부적절한 값입니다.",
        "800": "시스템 점검으로 인한 서비스가 중지 중입니다.",
        "900": "정의되지 않은 오류가 발생하였습니다.",
    }

    def __init__(self, status: str, message: str):
        self.status = status
        self.message = message
        super().__init__(f"[{status}] {message}")

# ==================== DART API 클라이언트 ====================

class DartDisclosureCollector:
    """
    DART 공시 수집기 (확장판)

    상장 기업들의 공시 정보를 수집하는 클라이언트입니다.
    일반 공시목록 API와 36개 주요사항보고서 API를 모두 지원합니다.
    """

    BASE_URL = "https://opendart.fss.or.kr/api"

    def __init__(
        self,
        api_key: str,
        timeout: int = 30,
        request_delay: float = 0.1
    ):
        """
        클라이언트 초기화

        Args:
            api_key: DART API 인증키 (40자리)
            timeout: 요청 타임아웃 (초)
            request_delay: 요청 간 대기 시간 (초) - API 제한 방지
        """
        if not api_key or len(api_key) != 40:
            raise ValueError("API 인증키는 40자리여야 합니다.")

        self.api_key = api_key
        self.timeout = timeout
        self.request_delay = request_delay
        self._session = requests.Session()
        self._listed_companies: List[ListedCompany] = []

    # ==================== 고유번호 API ====================

    def download_corp_codes(self) -> List[ListedCompany]:
        """
        고유번호 API - 상장사 고유번호 목록 다운로드

        DART에 등록된 모든 공시대상회사 중 상장사만 필터링합니다.

        Returns:
            List[ListedCompany]: 상장사 정보 목록
        """
        print("고유번호 목록 다운로드 중...")
        url = f"{self.BASE_URL}/corpCode.xml"
        params = {"crtfc_key": self.api_key}

        try:
            response = self._session.get(url, params=params, timeout=60)
            response.raise_for_status()

            listed_companies = []

            with zipfile.ZipFile(io.BytesIO(response.content)) as zf:
                xml_files = [f for f in zf.namelist() if f.endswith('.xml')]
                if not xml_files:
                    raise DartAPIError("900", "ZIP 파일 내 XML 파일이 없습니다.")

                with zf.open(xml_files[0]) as xml_file:
                    tree = ET.parse(xml_file)
                    root = tree.getroot()

                    for corp in root.findall('.//list'):
                        stock_code = self._get_xml_text(corp, 'stock_code')

                        # 상장사만 필터링 (stock_code가 있는 경우)
                        if stock_code and stock_code.strip():
                            company = ListedCompany(
                                corp_code=self._get_xml_text(corp, 'corp_code'),
                                corp_name=self._get_xml_text(corp, 'corp_name'),
                                stock_code=stock_code.strip()
                            )
                            listed_companies.append(company)

            self._listed_companies = listed_companies
            print(f"상장사 {len(listed_companies)}개 로드 완료")
            return listed_companies

        except zipfile.BadZipFile:
            try:
                root = ET.fromstring(response.content)
                status = root.findtext('status', '')
                message = root.findtext('message', '')
                raise DartAPIError(status, message)
            except ET.ParseError:
                raise DartAPIError("900", "응답 파싱 실패")
        except requests.RequestException as e:
            raise DartAPIError("999", f"네트워크 오류: {str(e)}")

    def _get_xml_text(self, element, tag: str) -> str:
        """XML 요소에서 텍스트 추출"""
        child = element.find(tag)
        return child.text.strip() if child is not None and child.text else ""

    # ==================== 공시검색 API ====================

    def get_disclosure_list(
        self,
        corp_code: str,
        bgn_de: str,
        end_de: str,
        page_no: int = 1,
        page_count: int = 100
    ) -> Tuple[List[Dict], int, int]:
        """
        공시검색 API - 공시 목록 조회

        Args:
            corp_code: 고유번호 (8자리)
            bgn_de: 시작일 (YYYYMMDD)
            end_de: 종료일 (YYYYMMDD)
            page_no: 페이지 번호
            page_count: 페이지당 건수 (최대 100)

        Returns:
            (공시목록, 전체건수, 전체페이지수)
        """
        url = f"{self.BASE_URL}/list.json"
        params = {
            "crtfc_key": self.api_key,
            "corp_code": corp_code,
            "bgn_de": bgn_de,
            "end_de": end_de,
            "page_no": page_no,
            "page_count": page_count
        }

        try:
            response = self._session.get(url, params=params, timeout=self.timeout)
            response.raise_for_status()
            data = response.json()

            status = data.get("status", "")

            if status == "000":
                return (
                    data.get("list", []),
                    int(data.get("total_count", 0)),
                    int(data.get("total_page", 0))
                )
            elif status == "013":
                return ([], 0, 0)
            else:
                message = data.get("message", DartAPIError.ERROR_CODES.get(status, "알 수 없는 오류"))
                raise DartAPIError(status, message)

        except requests.RequestException as e:
            raise DartAPIError("999", f"네트워크 오류: {str(e)}")

    def get_all_disclosures_for_company(
        self,
        company: ListedCompany,
        bgn_de: str,
        end_de: str
    ) -> List[Disclosure]:
        """
        특정 기업의 모든 공시 조회 (페이지네이션 처리)
        """
        disclosures = []
        page_no = 1

        while True:
            try:
                items, total_count, total_page = self.get_disclosure_list(
                    corp_code=company.corp_code,
                    bgn_de=bgn_de,
                    end_de=end_de,
                    page_no=page_no
                )

                for item in items:
                    disclosure = Disclosure(
                        corp_code=company.corp_code,
                        corp_name=item.get("corp_name", company.corp_name),
                        stock_code=company.stock_code,
                        corp_cls=item.get("corp_cls", company.corp_cls),
                        report_nm=item.get("report_nm", ""),
                        rcept_no=item.get("rcept_no", ""),
                        flr_nm=item.get("flr_nm", ""),
                        rcept_dt=item.get("rcept_dt", ""),
                        rm=item.get("rm", "")
                    )
                    disclosures.append(disclosure)

                if page_no >= total_page or not items:
                    break

                page_no += 1
                time.sleep(self.request_delay)

            except DartAPIError as e:
                if e.status == "013":
                    break
                raise

        return disclosures

    # ==================== 주요사항보고서 API ====================

    def get_major_report(
        self,
        report_type: MajorReportType,
        corp_code: str,
        bgn_de: str,
        end_de: str
    ) -> List[Dict]:
        """
        주요사항보고서 API - 특정 유형의 보고서 조회

        Args:
            report_type: 보고서 유형
            corp_code: 고유번호 (8자리)
            bgn_de: 시작일 (YYYYMMDD)
            end_de: 종료일 (YYYYMMDD)

        Returns:
            보고서 목록
        """
        url = f"{self.BASE_URL}/{report_type.endpoint}.json"
        params = {
            "crtfc_key": self.api_key,
            "corp_code": corp_code,
            "bgn_de": bgn_de,
            "end_de": end_de
        }

        try:
            response = self._session.get(url, params=params, timeout=self.timeout)
            response.raise_for_status()
            data = response.json()

            status = data.get("status", "")

            if status == "000":
                return data.get("list", [])
            elif status == "013":
                return []
            else:
                message = data.get("message", DartAPIError.ERROR_CODES.get(status, "알 수 없는 오류"))
                raise DartAPIError(status, message)

        except requests.RequestException as e:
            raise DartAPIError("999", f"네트워크 오류: {str(e)}")

    def get_major_reports_for_company(
        self,
        company: ListedCompany,
        bgn_de: str,
        end_de: str,
        report_types: Optional[List[MajorReportType]] = None
    ) -> Dict[str, List[MajorReport]]:
        """
        특정 기업의 주요사항보고서 조회 (유형별)

        Args:
            company: 상장사 정보
            bgn_de: 시작일
            end_de: 종료일
            report_types: 조회할 보고서 유형 목록 (None이면 전체)

        Returns:
            유형별 보고서 목록 딕셔너리
        """
        if report_types is None:
            report_types = list(MajorReportType)

        results: Dict[str, List[MajorReport]] = {}

        for report_type in report_types:
            try:
                items = self.get_major_report(
                    report_type=report_type,
                    corp_code=company.corp_code,
                    bgn_de=bgn_de,
                    end_de=end_de
                )

                if items:
                    reports = []
                    for item in items:
                        report = MajorReport(
                            report_type=report_type.name,
                            category=report_type.category,
                            corp_code=company.corp_code,
                            corp_name=item.get("corp_name", company.corp_name),
                            stock_code=company.stock_code,
                            corp_cls=item.get("corp_cls", company.corp_cls),
                            rcept_no=item.get("rcept_no", ""),
                            rcept_dt=item.get("rcept_dt", "") if "rcept_dt" in item else "",
                            raw_data=item
                        )
                        reports.append(report)

                    if report_type.category not in results:
                        results[report_type.category] = []
                    results[report_type.category].extend(reports)

                time.sleep(self.request_delay)

            except DartAPIError as e:
                # 013: 데이터 없음, 020: 요청 제한, 101: 잘못된 URL (지원 안됨)
                if e.status not in ["013", "020", "101"]:
                    pass  # 조용히 무시

        return results

    # ==================== 통합 수집 기능 ====================

    def collect_all_disclosures(
        self,
        bgn_de: str,
        end_de: str,
        companies: Optional[List[ListedCompany]] = None,
        progress_callback: Optional[callable] = None
    ) -> List[Disclosure]:
        """전체 상장사의 일반 공시 수집"""
        if companies is None:
            if not self._listed_companies:
                self.download_corp_codes()
            companies = self._listed_companies

        all_disclosures = []
        total = len(companies)

        for idx, company in enumerate(companies, 1):
            if progress_callback:
                progress_callback(idx, total, company.corp_name)
            else:
                print(f"[{idx}/{total}] {company.corp_name} ({company.stock_code}) 수집 중...")

            try:
                disclosures = self.get_all_disclosures_for_company(
                    company=company,
                    bgn_de=bgn_de,
                    end_de=end_de
                )

                if disclosures:
                    all_disclosures.extend(disclosures)
                    print(f"  -> {len(disclosures)}건 수집")

            except DartAPIError as e:
                if e.status == "020":
                    print(f"  -> 요청 제한 초과. 60초 대기 후 재시도...")
                    time.sleep(60)
                    try:
                        disclosures = self.get_all_disclosures_for_company(
                            company=company,
                            bgn_de=bgn_de,
                            end_de=end_de
                        )
                        if disclosures:
                            all_disclosures.extend(disclosures)
                            print(f"  -> {len(disclosures)}건 수집")
                    except Exception as retry_e:
                        print(f"  -> 재시도 실패: {retry_e}")
                elif e.status != "013":
                    print(f"  -> 오류: {e}")

            except Exception as e:
                print(f"  -> 예외 발생: {e}")

            time.sleep(self.request_delay)

        return all_disclosures

    def collect_major_reports(
        self,
        bgn_de: str,
        end_de: str,
        companies: Optional[List[ListedCompany]] = None,
        report_types: Optional[List[MajorReportType]] = None,
        categories: Optional[List[str]] = None
    ) -> Dict[str, List[MajorReport]]:
        """
        전체 상장사의 주요사항보고서 수집 (유형별/카테고리별)

        Args:
            bgn_de: 시작일
            end_de: 종료일
            companies: 대상 기업 목록 (None이면 전체)
            report_types: 조회할 보고서 유형 목록 (None이면 전체)
            categories: 조회할 카테고리 목록 (None이면 전체)

        Returns:
            카테고리별 보고서 목록
        """
        if companies is None:
            if not self._listed_companies:
                self.download_corp_codes()
            companies = self._listed_companies

        # 카테고리로 필터링
        if categories is not None and report_types is None:
            report_types = []
            for cat in categories:
                report_types.extend(MajorReportType.get_by_category(cat))

        all_reports: Dict[str, List[MajorReport]] = {}
        total = len(companies)

        for idx, company in enumerate(companies, 1):
            print(f"[{idx}/{total}] {company.corp_name} ({company.stock_code}) 주요사항보고서 수집 중...")

            try:
                reports = self.get_major_reports_for_company(
                    company=company,
                    bgn_de=bgn_de,
                    end_de=end_de,
                    report_types=report_types
                )

                for category, report_list in reports.items():
                    if category not in all_reports:
                        all_reports[category] = []
                    all_reports[category].extend(report_list)
                    print(f"  -> {category}: {len(report_list)}건")

            except DartAPIError as e:
                if e.status == "020":
                    print(f"  -> 요청 제한 초과. 60초 대기...")
                    time.sleep(60)
                elif e.status != "013":
                    print(f"  -> 오류: {e}")

            except Exception as e:
                print(f"  -> 예외 발생: {e}")

        return all_reports

    # ==================== Excel 내보내기 ====================

    def export_to_excel(
        self,
        disclosures: List[Disclosure],
        output_path: str,
        sheet_name: str = "공시목록"
    ) -> str:
        """일반 공시 데이터를 Excel로 내보내기"""
        if not disclosures:
            print("내보낼 공시 데이터가 없습니다.")
            return ""

        data = [d.to_dict() for d in disclosures]
        df = pd.DataFrame(data)

        df['접수일자'] = pd.to_datetime(df['접수일자'], format='%Y%m%d', errors='coerce')
        df = df.sort_values(['접수일자', '회사명'], ascending=[False, True])
        df['접수일자'] = df['접수일자'].dt.strftime('%Y-%m-%d')

        with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
            df.to_excel(writer, sheet_name=sheet_name, index=False)
            self._adjust_column_width(writer, sheet_name, df)

        print(f"Excel 파일 저장 완료: {output_path}")
        print(f"총 {len(disclosures)}건의 공시 데이터")
        return output_path

    def export_major_reports_to_excel(
        self,
        reports: Dict[str, List[MajorReport]],
        output_path: str
    ) -> str:
        """
        주요사항보고서 데이터를 Excel로 내보내기 (카테고리별 시트)

        Args:
            reports: 카테고리별 보고서 목록
            output_path: 출력 파일 경로

        Returns:
            저장된 파일 경로
        """
        if not reports:
            print("내보낼 주요사항보고서 데이터가 없습니다.")
            return ""

        with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
            # 전체 요약 시트
            summary_data = []
            total_count = 0

            for category, report_list in reports.items():
                summary_data.append({
                    "카테고리": category,
                    "건수": len(report_list)
                })
                total_count += len(report_list)

                # 카테고리별 시트 생성
                if report_list:
                    data = [r.to_dict() for r in report_list]
                    df = pd.DataFrame(data)

                    # 시트 이름은 31자 제한
                    sheet_name = category[:31]
                    df.to_excel(writer, sheet_name=sheet_name, index=False)
                    self._adjust_column_width(writer, sheet_name, df)

            # 요약 시트
            summary_df = pd.DataFrame(summary_data)
            summary_df.loc[len(summary_df)] = ["합계", total_count]
            summary_df.to_excel(writer, sheet_name="요약", index=False)
            self._adjust_column_width(writer, "요약", summary_df)

        print(f"Excel 파일 저장 완료: {output_path}")
        print(f"총 {total_count}건의 주요사항보고서 데이터 ({len(reports)}개 카테고리)")
        return output_path

    def export_combined_to_excel(
        self,
        disclosures: List[Disclosure],
        major_reports: Dict[str, List[MajorReport]],
        output_path: str
    ) -> str:
        """
        일반 공시와 주요사항보고서를 통합하여 Excel로 내보내기

        Args:
            disclosures: 일반 공시 목록
            major_reports: 카테고리별 주요사항보고서
            output_path: 출력 파일 경로

        Returns:
            저장된 파일 경로
        """
        with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
            # 요약 시트
            summary_data = [{"구분": "일반공시", "건수": len(disclosures)}]
            total_major = 0

            for category, report_list in major_reports.items():
                summary_data.append({"구분": f"[주요] {category}", "건수": len(report_list)})
                total_major += len(report_list)

            summary_data.append({"구분": "합계", "건수": len(disclosures) + total_major})
            summary_df = pd.DataFrame(summary_data)
            summary_df.to_excel(writer, sheet_name="요약", index=False)
            self._adjust_column_width(writer, "요약", summary_df)

            # 일반 공시 시트
            if disclosures:
                data = [d.to_dict() for d in disclosures]
                df = pd.DataFrame(data)
                df['접수일자'] = pd.to_datetime(df['접수일자'], format='%Y%m%d', errors='coerce')
                df = df.sort_values(['접수일자', '회사명'], ascending=[False, True])
                df['접수일자'] = df['접수일자'].dt.strftime('%Y-%m-%d')
                df.to_excel(writer, sheet_name="일반공시", index=False)
                self._adjust_column_width(writer, "일반공시", df)

            # 주요사항보고서 시트 (카테고리별)
            for category, report_list in major_reports.items():
                if report_list:
                    data = [r.to_dict() for r in report_list]
                    df = pd.DataFrame(data)
                    sheet_name = f"[주요]{category}"[:31]
                    df.to_excel(writer, sheet_name=sheet_name, index=False)
                    self._adjust_column_width(writer, sheet_name, df)

        total = len(disclosures) + total_major
        print(f"Excel 파일 저장 완료: {output_path}")
        print(f"총 {total}건 (일반공시 {len(disclosures)}건, 주요사항보고서 {total_major}건)")
        return output_path

    def _adjust_column_width(self, writer, sheet_name: str, df: pd.DataFrame):
        """열 너비 자동 조정"""
        worksheet = writer.sheets[sheet_name]
        for idx, col in enumerate(df.columns):
            max_len = max(
                df[col].astype(str).str.len().max() if len(df) > 0 else 0,
                len(str(col))
            ) + 2
            col_letter = chr(65 + idx) if idx < 26 else f"{chr(64 + idx // 26)}{chr(65 + idx % 26)}"
            worksheet.column_dimensions[col_letter].width = min(max_len, 50)

    # ==================== 세션 관리 ====================

    def close(self):
        """세션 종료"""
        self._session.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

# ==================== 날짜 유틸리티 ====================

def parse_date(date_str: str) -> Optional[str]:
    """
    다양한 형식의 날짜 문자열을 YYYYMMDD 형식으로 변환

    지원 형식:
    - YYYYMMDD (예: 20251201)
    - YYYY-MM-DD (예: 2025-12-01)
    - YYYY/MM/DD (예: 2025/12/01)
    - YYYY.MM.DD (예: 2025.12.01)
    """
    if not date_str:
        return None

    # 구분자 제거
    cleaned = date_str.replace("-", "").replace("/", "").replace(".", "")

    # 8자리 숫자인지 확인
    if len(cleaned) == 8 and cleaned.isdigit():
        # 유효한 날짜인지 확인
        try:
            datetime.strptime(cleaned, "%Y%m%d")
            return cleaned
        except ValueError:
            return None

    return None

def format_date_display(date_str: str) -> str:
    """YYYYMMDD 형식을 YYYY-MM-DD 형식으로 변환"""
    if len(date_str) == 8:
        return f"{date_str[:4]}-{date_str[4:6]}-{date_str[6:]}"
    return date_str

def get_date_input(prompt: str, default: Optional[str] = None) -> str:
    """사용자로부터 날짜 입력 받기"""
    while True:
        if default:
            user_input = input(f"{prompt} [{format_date_display(default)}]: ").strip()
            if not user_input:
                return default
        else:
            user_input = input(f"{prompt}: ").strip()

        parsed = parse_date(user_input)
        if parsed:
            return parsed
        else:
            print("  잘못된 날짜 형식입니다. YYYY-MM-DD 또는 YYYYMMDD 형식으로 입력하세요.")

def get_default_date_range() -> Tuple[str, str]:
    """기본 날짜 범위 반환 (최근 1개월)"""
    today = datetime.now()
    end_date = today.strftime("%Y%m%d")

    # 1개월 전
    if today.month == 1:
        start_date = f"{today.year - 1}12{today.day:02d}"
    else:
        start_date = f"{today.year}{today.month - 1:02d}{today.day:02d}"

    return start_date, end_date

# ==================== 메인 실행 함수 ====================

def run_collection(
    mode: str = "general",
    bgn_de: Optional[str] = None,
    end_de: Optional[str] = None,
    sample_size: Optional[int] = None,
    interactive: bool = False
):
    """
    통합 수집 실행 함수

    Args:
        mode: 수집 모드 ("general", "major", "combined")
        bgn_de: 시작일 (YYYYMMDD)
        end_de: 종료일 (YYYYMMDD)
        sample_size: 샘플 기업 수 (None이면 전체)
        interactive: 인터랙티브 모드 여부
    """
    # 모드별 타이틀
    mode_titles = {
        "general": "DART 공시 정보 수집기",
        "major": "DART 주요사항보고서 수집기",
        "combined": "DART 통합 공시 수집기"
    }

    print("=" * 60)
    print(f"{mode_titles.get(mode, 'DART 공시 수집기')} (상장사 대상)")
    print("=" * 60)

    # 날짜 설정
    default_start, default_end = get_default_date_range()

    if interactive:
        print("\n[날짜 설정]")
        bgn_de = get_date_input("시작일 (YYYY-MM-DD)", default_start)
        end_de = get_date_input("종료일 (YYYY-MM-DD)", default_end)

        if sample_size is None:
            sample_input = input("샘플 기업 수 (전체는 Enter): ").strip()
            if sample_input.isdigit():
                sample_size = int(sample_input)
    else:
        bgn_de = bgn_de or default_start
        end_de = end_de or default_end

    # 출력 디렉토리 설정
    OUTPUT_DIR = Path("data/dart/disclosures")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # 파일명 생성
    suffix = f"_sample_{sample_size}" if sample_size else "_all"
    if mode == "general":
        OUTPUT_FILE = OUTPUT_DIR / f"disclosures_{bgn_de}_{end_de}{suffix}.xlsx"
    elif mode == "major":
        OUTPUT_FILE = OUTPUT_DIR / f"major_reports_{bgn_de}_{end_de}{suffix}.xlsx"
    else:
        OUTPUT_FILE = OUTPUT_DIR / f"combined_{bgn_de}_{end_de}{suffix}.xlsx"

    print(f"\n수집 기간: {format_date_display(bgn_de)} ~ {format_date_display(end_de)}")
    print(f"수집 대상: {'전체 상장사' if not sample_size else f'랜덤 {sample_size}개 기업'}")
    print(f"출력 파일: {OUTPUT_FILE}")

    if mode == "major":
        print(f"\n수집 대상 주요사항보고서 유형: {len(MajorReportType)}개")

    print()

    # 확인
    if interactive:
        confirm = input("수집을 시작하시겠습니까? (Y/n): ").strip().lower()
        if confirm == 'n':
            print("수집이 취소되었습니다.")
            return None

    try:
        with DartDisclosureCollector(api_key=dart_api_key) as collector:
            # 상장사 목록 로드
            all_companies = collector.download_corp_codes()

            # 샘플 선택
            if sample_size:
                random.seed(42)
                companies = random.sample(all_companies, min(sample_size, len(all_companies)))
                print(f"랜덤 {len(companies)}개 기업 선택 완료\n")
            else:
                companies = all_companies
                print(f"총 {len(companies)}개 상장사 대상 수집 시작\n")

            start_time = time.time()

            if mode == "general":
                # 일반 공시 수집
                all_disclosures = collector.collect_all_disclosures(
                    bgn_de=bgn_de,
                    end_de=end_de,
                    companies=companies
                )
                elapsed_time = time.time() - start_time

                print(f"\n수집 완료: 총 {len(all_disclosures)}건 ({elapsed_time:.1f}초 소요)")

                if all_disclosures:
                    collector.export_to_excel(
                        disclosures=all_disclosures,
                        output_path=str(OUTPUT_FILE)
                    )
                    _print_summary(all_disclosures)
                else:
                    print("수집된 공시가 없습니다.")

                return all_disclosures

            elif mode == "major":
                # 주요사항보고서 수집
                all_reports = collector.collect_major_reports(
                    bgn_de=bgn_de,
                    end_de=end_de,
                    companies=companies
                )
                elapsed_time = time.time() - start_time

                total_count = sum(len(v) for v in all_reports.values())
                print(f"\n수집 완료: 총 {total_count}건 ({elapsed_time:.1f}초 소요)")

                if all_reports:
                    print("\n카테고리별 수집 결과:")
                    for category, reports in sorted(all_reports.items()):
                        print(f"  {category}: {len(reports)}건")

                    collector.export_major_reports_to_excel(
                        reports=all_reports,
                        output_path=str(OUTPUT_FILE)
                    )
                else:
                    print("수집된 주요사항보고서가 없습니다.")

                return all_reports

            else:  # combined
                # 일반 공시 수집
                print("=" * 40)
                print("1. 일반 공시 수집")
                print("=" * 40)
                all_disclosures = collector.collect_all_disclosures(
                    bgn_de=bgn_de,
                    end_de=end_de,
                    companies=companies
                )

                # 주요사항보고서 수집
                print("\n" + "=" * 40)
                print("2. 주요사항보고서 수집")
                print("=" * 40)
                all_reports = collector.collect_major_reports(
                    bgn_de=bgn_de,
                    end_de=end_de,
                    companies=companies
                )
                elapsed_time = time.time() - start_time

                total_major = sum(len(v) for v in all_reports.values())
                print(f"\n수집 완료: 일반 {len(all_disclosures)}건, 주요사항 {total_major}건 ({elapsed_time:.1f}초 소요)")

                if all_disclosures or all_reports:
                    collector.export_combined_to_excel(
                        disclosures=all_disclosures,
                        major_reports=all_reports,
                        output_path=str(OUTPUT_FILE)
                    )

                return all_disclosures, all_reports

    except KeyboardInterrupt:
        print("\n\n수집이 중단되었습니다.")
        return None
    except Exception as e:
        print(f"\n오류 발생: {e}")
        raise

def _print_summary(disclosures: List[Disclosure]):
    """공시 수집 결과 요약 출력"""
    if not disclosures:
        return

    # 기업별 공시 건수
    corp_counts = {}
    for d in disclosures:
        key = f"{d.corp_name} ({d.stock_code})"
        corp_counts[key] = corp_counts.get(key, 0) + 1

    print("\n기업별 공시 건수 (상위 10개):")
    sorted_counts = sorted(corp_counts.items(), key=lambda x: x[1], reverse=True)
    for name, count in sorted_counts[:10]:
        print(f"  {name}: {count}건")

def print_usage():
    """사용법 출력"""
    print("""
DART 공시 정보 수집기 - 사용법
==============================

기본 사용법:
  python dart_disclosure_collector.py [명령] [옵션]

명령어:
  (없음)          인터랙티브 모드 실행
  general         일반 공시 수집
  major           주요사항보고서 수집
  combined        통합 수집 (일반 + 주요사항보고서)
  help            이 도움말 표시

옵션:
  --start, -s     시작일 (YYYY-MM-DD 또는 YYYYMMDD)
  --end, -e       종료일 (YYYY-MM-DD 또는 YYYYMMDD)
  --sample, -n    샘플 기업 수 (지정하지 않으면 전체)

사용 예시:
  # 인터랙티브 모드 (날짜 직접 입력)
  python dart_disclosure_collector.py

  # 기간 지정하여 전체 상장사 공시 수집
  python dart_disclosure_collector.py general -s 2025-12-01 -e 2026-01-01

  # 기간 지정하여 100개 기업 샘플 수집
  python dart_disclosure_collector.py general -s 2025-12-01 -e 2026-01-01 -n 100

  # 주요사항보고서 수집
  python dart_disclosure_collector.py major -s 2025-12-01 -e 2026-01-01

  # 통합 수집 (랜덤 50개 기업)
  python dart_disclosure_collector.py combined -s 2025-12-01 -e 2026-01-01 -n 50

주요사항보고서 카테고리 (36개 API):
""")
    for cat in sorted(MajorReportType.get_all_categories()):
        types = MajorReportType.get_by_category(cat)
        print(f"  - {cat}: {len(types)}개")
        for t in types:
            print(f"      * {t.name}")

def parse_args(args: List[str]) -> Dict[str, Any]:
    """명령줄 인자 파싱"""
    result = {
        "mode": None,
        "bgn_de": None,
        "end_de": None,
        "sample_size": None,
        "interactive": False
    }

    i = 0
    while i < len(args):
        arg = args[i]

        if arg in ["general", "major", "combined"]:
            result["mode"] = arg
        elif arg in ["help", "-h", "--help"]:
            result["mode"] = "help"
        elif arg in ["-s", "--start"]:
            if i + 1 < len(args):
                result["bgn_de"] = parse_date(args[i + 1])
                i += 1
        elif arg in ["-e", "--end"]:
            if i + 1 < len(args):
                result["end_de"] = parse_date(args[i + 1])
                i += 1
        elif arg in ["-n", "--sample"]:
            if i + 1 < len(args) and args[i + 1].isdigit():
                result["sample_size"] = int(args[i + 1])
                i += 1

        i += 1

    # 모드가 지정되지 않았으면 인터랙티브 모드
    if result["mode"] is None:
        result["interactive"] = True
        result["mode"] = "general"

    return result

if __name__ == "__main__":
    import sys

    args = sys.argv[1:]

    if not args:
        # 인터랙티브 모드
        print("=" * 60)
        print("DART 공시 정보 수집기 - 인터랙티브 모드")
        print("=" * 60)
        print("\n수집 모드를 선택하세요:")
        print("  1. 일반 공시 수집 (general)")
        print("  2. 주요사항보고서 수집 (major)")
        print("  3. 통합 수집 (combined)")
        print("  q. 종료")

        mode_input = input("\n선택 [1]: ").strip()
        mode_map = {"1": "general", "2": "major", "3": "combined", "": "general"}

        if mode_input.lower() == 'q':
            print("종료합니다.")
            sys.exit(0)

        mode = mode_map.get(mode_input, "general")
        run_collection(mode=mode, interactive=True)
    else:
        # 명령줄 인자 처리
        parsed = parse_args(args)

        if parsed["mode"] == "help":
            print_usage()
            sys.exit(0)

        run_collection(
            mode=parsed["mode"],
            bgn_de=parsed["bgn_de"],
            end_de=parsed["end_de"],
            sample_size=parsed["sample_size"],
            interactive=parsed["interactive"]
        ) 
```

[config.py](http://config.py) 에 dart_api_key 인자 세팅 후 실행해주셔야 합니다.

```python
dart_api_key = "40자리APIKEY"
```

DB에 올리는 방향으로 수정이 필요하며, 

각 보고서에 공통 출력 인자인 접수번호에서 앞 8자리로 공시 발행 날짜를 가져오면 백테스팅에 사용할 수 있을 것 같습니다!

## 테이블 스키마 정리

1. **자산양수도(기타), 풋백옵션**

**API URL:** astInhtrfEtcPtbkOpt

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| rp_rsn | 보고 사유 | 보고 사유 |
| ast_inhtrf_prc | 자산양수ㆍ도 가액 | 숫자 |
1. **부도발생**

**API URL:** dfOcr

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| df_cn | 부도내용 | 부도내용 |
| df_amt | 부도금액 | 숫자 |
| df_bnk | 부도발생은행 | 부도발생은행 |
| dfd | 최종부도(당좌거래정지)일자 | 일자 |
| df_rs | 부도사유 및 경위 | 부도사유 및 경위 |
1. **영업정지**

**API URL:** bsnSp

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| bsnsp_rm | 영업정지 분야 | 영업정지 분야 |
| bsnsp_amt | 영업정지 내역(영업정지금액) | 숫자 |
| rsl | 영업정지 내역(최근매출총액) | 숫자 |
| sl_vs | 영업정지 내역(매출액 대비) | 비율 |
| ls_atn | 영업정지 내역(대규모법인여부) | 여부 |
| krx_stt_atn | 영업정지 내역(거래소 의무공시 해당 여부) | 여부 |
| bsnsp_cn | 영업정지 내용 | 영업정지 내용 |
| bsnsp_rs | 영업정지사유 | 영업정지사유 |
| ft_ctp | 향후대책 | 향후대책 |
| bsnsp_af | 영업정지영향 | 영업정지영향 |
| bsnspd | 영업정지일자 | 일자 |
| bddd | 이사회결의일(결정일) | 일자 |
| od_a_at_t | 사외이사 참석여부(참석) | 숫자 |
| od_a_at_b | 사외이사 참석여부(불참) | 숫자 |
| adt_a_atn | 감사(감사위원) 참석여부 | 여부 |
1. **회생절차 개시신청**

**API URL:** ctrcvsBgrq

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| apcnt | 신청인 (회사와의 관계) | 신청인 정보 |
| cpct | 관할법원 | 관할법원 |
| rq_rs | 신청사유 | 신청사유 |
| rqd | 신청일자 | 일자 |
| ft_ctp_sc | 향후대책 및 일정 | 향후대책 및 일정 |
1. **해산사유 발생**

**API URL:** dsRsOcr

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| ds_rs | 해산사유 | 해산사유 |
| ds_rsd | 해산사유발생일(결정일) | 일자 |
| od_a_at_t | 사외이사 참석여부(참석) | 숫자 |
| od_a_at_b | 사외이사 참석여부(불참) | 숫자 |
| adt_a_atn | 감사(감사위원) 참석 여부 | 여부 |
1. **유상증자 결정**

**API URL:** piicDecsn

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| nstk_ostk_cnt | 신주의 종류와 수(보통주식) | 숫자(주) |
| nstk_estk_cnt | 신주의 종류와 수(기타주식) | 숫자(주) |
| fv_ps | 1주당 액면가액 | 숫자(원) |
| bfic_tisstk_ostk | 증자전 발행주식총수(보통주식) | 숫자(주) |
| bfic_tisstk_estk | 증자전 발행주식총수(기타주식) | 숫자(주) |
| fdpp_fclt | 자금조달의 목적(시설자금) | 숫자(원) |
| fdpp_bsninh | 자금조달의 목적(영업양수자금) | 숫자(원) |
| fdpp_op | 자금조달의 목적(운영자금) | 숫자(원) |
| fdpp_dtrp | 자금조달의 목적(채무상환자금) | 숫자(원) |
| fdpp_ocsa | 자금조달의 목적(타법인 증권 취득자금) | 숫자(원) |
| fdpp_etc | 자금조달의 목적(기타자금) | 숫자(원) |
| ic_mthn | 증자방식 | 증자방식 |
| ssl_at | 공매도 해당여부 | 여부 |
| ssl_bgd | 공매도 시작일 | 일자 |
| ssl_edd | 공매도 종료일 | 일자 |
1. **무상증자 결정**

**API URL:** fricDecsn

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| nstk_ostk_cnt | 신주의 종류와 수(보통주식) | 숫자(주) |
| nstk_estk_cnt | 신주의 종류와 수(기타주식) | 숫자(주) |
| fv_ps | 1주당 액면가액 | 숫자(원) |
| bfic_tisstk_ostk | 증자전 발행주식총수(보통주식) | 숫자(주) |
| bfic_tisstk_estk | 증자전 발행주식총수(기타주식) | 숫자(주) |
| nstk_asstd | 신주배정기준일 | 일자 |
| nstk_ascnt_ps_ostk | 1주당 신주배정 주식수(보통주식) | 소수점 최대 20자리 |
| nstk_ascnt_ps_estk | 1주당 신주배정 주식수(기타주식) | 소수점 최대 20자리 |
| nstk_dividrk | 신주의 배당기산일 | 일자 |
| nstk_dlprd | 신주권교부예정일 | 일자 |
| nstk_lstprd | 신주의 상장 예정일 | 일자 |
| bddd | 이사회결의일(결정일) | 일자 |
| od_a_at_t | 사외이사 참석여부(참석) | 숫자(명) |
| od_a_at_b | 사외이사 참석여부(불참) | 숫자(명) |
| adt_a_atn | 감사(감사위원)참석 여부 | 여부 |
1. **유무상증자 결정**

**API URL:** pifricDecsn

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| piic_nstk_ostk_cnt | 유상증자(신주의 종류와 수(보통주식)) | 숫자 |
| piic_nstk_estk_cnt | 유상증자(신주의 종류와 수(기타주식)) | 숫자 |
| piic_fv_ps | 유상증자(1주당 액면가액) | 숫자(원) |
| piic_bfic_tisstk_ostk | 유상증자(증자전 발행주식총수(보통주식)) | 숫자 |
| piic_bfic_tisstk_estk | 유상증자(증자전 발행주식총수(기타주식)) | 숫자 |
| piic_fdpp_fclt | 유상증자(자금조달-시설자금) | 숫자(원) |
| piic_fdpp_bsninh | 유상증자(자금조달-영업양수자금) | 숫자(원) |
| piic_fdpp_op | 유상증자(자금조달-운영자금) | 숫자(원) |
| piic_fdpp_dtrp | 유상증자(자금조달-채무상환자금) | 숫자(원) |
| piic_fdpp_ocsa | 유상증자(자금조달-타법인 증권 취득자금) | 숫자(원) |
| piic_fdpp_etc | 유상증자(자금조달-기타자금) | 숫자(원) |
| piic_ic_mthn | 유상증자(증자방식) | 증자방식 |
| fric_nstk_ostk_cnt | 무상증자(신주의 종류와 수(보통주식)) | 숫자 |
| fric_nstk_estk_cnt | 무상증자(신주의 종류와 수(기타주식)) | 숫자 |
| fric_fv_ps | 무상증자(1주당 액면가액) | 숫자(원) |
| fric_bfic_tisstk_ostk | 무상증자(증자전 발행주식총수(보통주식)) | 숫자 |
| fric_bfic_tisstk_estk | 무상증자(증자전 발행주식총수(기타주식)) | 숫자 |
| fric_nstk_asstd | 무상증자(신주배정기준일) | 일자 |
| fric_nstk_ascnt_ps_ostk | 무상증자(1주당 신주배정 주식수(보통주식)) | 소수점 최대 20자리 |
| fric_nstk_ascnt_ps_estk | 무상증자(1주당 신주배정 주식수(기타주식)) | 소수점 최대 20자리 |
| fric_nstk_dividrk | 무상증자(신주의 배당기산일) | 일자 |
| fric_nstk_dlprd | 무상증자(신주권교부예정일) | 일자 |
| fric_nstk_lstprd | 무상증자(신주의 상장 예정일) | 일자 |
| fric_bddd | 무상증자(이사회결의일) | 일자 |
| fric_od_a_at_t | 무상증자(사외이사 참석(명)) | 숫자 |
| fric_od_a_at_b | 무상증자(사외이사 불참(명)) | 숫자 |
| fric_adt_a_atn | 무상증자(감사(감사위원)참석 여부) | 여부 |
| ssl_at | 공매도 해당여부 | 여부 |
| ssl_bgd | 공매도 시작일 | 일자 |
| ssl_edd | 공매도 종료일 | 일자 |
1. **감자 결정**

**API URL:** crDecsn

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| crstk_ostk_cnt | 감자주식의 종류와 수(보통주식) | 숫자(주) |
| crstk_estk_cnt | 감자주식의 종류와 수(기타주식) | 숫자(주) |
| fv_ps | 1주당 액면가액 | 숫자(원) |
| bfcr_cpt | 감자전후 자본금(감자전) | 숫자(원) |
| atcr_cpt | 감자전후 자본금(감자후) | 숫자(원) |
| bfcr_tisstk_ostk | 감자전후 발행주식수(보통주식 감자전) | 숫자 |
| atcr_tisstk_ostk | 감자전후 발행주식수(보통주식 감자후) | 숫자 |
| bfcr_tisstk_estk | 감자전후 발행주식수(기타주식 감자전) | 숫자 |
| atcr_tisstk_estk | 감자전후 발행주식수(기타주식 감자후) | 숫자 |
| cr_rt_ostk | 감자비율(보통주식 %) | 비율 |
| cr_rt_estk | 감자비율(기타주식 %) | 비율 |
| cr_std | 감자기준일 | 일자 |
| cr_mth | 감자방법 | 감자방법 |
| cr_rs | 감자사유 | 감자사유 |
| crsc_gmtsck_prd | 감자일정(주주총회 예정일) | 일자 |
| crsc_trnmsppd | 감자일정(명의개서정지기간) | 기간 |
| crsc_osprpd | 감자일정(구주권 제출기간) | 기간 |
| crsc_trspprpd | 감자일정(매매거래 정지예정기간) | 기간 |
| crsc_osprpd_bgd | 감자일정(구주권 제출기간 시작일) | 일자 |
| crsc_osprpd_edd | 감자일정(구주권 제출기간 종료일) | 일자 |
| crsc_trspprpd_bgd | 감자일정(매매거래 정지예정기간 시작일) | 일자 |
| crsc_trspprpd_edd | 감자일정(매매거래 정지예정기간 종료일) | 일자 |
| crsc_nstkdlprd | 감자일정(신주권교부예정일) | 일자 |
| crsc_nstklstprd | 감자일정(신주상장예정일) | 일자 |
| cdobprpd_bgd | 채권자 이의제출기간(시작일) | 일자 |
| cdobprpd_edd | 채권자 이의제출기간(종료일) | 일자 |
| ospr_nstkdl_pl | 구주권제출 및 신주권교부장소 | 장소 |
| bddd | 이사회결의일(결정일) | 일자 |
| od_a_at_t | 사외이사 참석여부(참석) | 숫자(명) |
| od_a_at_b | 사외이사 참석여부(불참) | 숫자(명) |
| adt_a_atn | 감사(감사위원) 참석여부 | 여부 |
| ftc_stt_atn | 공정거래위원회 신고대상 여부 | 여부 |
1. **소송 등의 제기**

**API URL:** lwstLg

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| icnm | 사건의 명칭 | 사건의 명칭 |
| ac_ap | 원고ㆍ신청인 | 원고ㆍ신청인 |
| rq_cn | 청구내용 | 청구내용 |
| cpct | 관할법원 | 관할법원 |
| ft_ctp | 향후대책 | 향후대책 |
| lgd | 제기일자 | 일자 |
| cfd | 확인일자 | 일자 |
1. **전환사채권 발행결정**

**API URL:** cvbdIsDecsn

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| bd_tm | 사채의 종류(회차) | 회차 |
| bd_knd | 사채의 종류(종류) | 종류 |
| bd_fta | 사채의 권면(전자등록)총액 | 숫자(원) |
| atcsc_rmislmt | 정관상 잔여 발행한도 | 숫자(원) |
| ovis_fta | 해외발행(권면총액) | 숫자 |
| ovis_fta_crn | 해외발행(통화단위) | 통화 |
| ovis_ster | 해외발행(기준환율등) | 환율 |
| ovis_isar | 해외발행(발행지역) | 지역 |
| ovis_mktnm | 해외발행(해외상장시 시장의 명칭) | 시장명 |
| fdpp_fclt | 자금조달의 목적(시설자금) | 숫자(원) |
| fdpp_bsninh | 자금조달의 목적(영업양수자금) | 숫자(원) |
| fdpp_op | 자금조달의 목적(운영자금) | 숫자(원) |
| fdpp_dtrp | 자금조달의 목적(채무상환자금) | 숫자(원) |
| fdpp_ocsa | 자금조달의 목적(타법인 증권 취득자금) | 숫자(원) |
| fdpp_etc | 자금조달의 목적(기타자금) | 숫자(원) |
| bd_intr_ex | 사채의 이율(표면이자율 %) | 비율 |
| bd_intr_sf | 사채의 이율(만기이자율 %) | 비율 |
| bd_mtd | 사채만기일 | 일자 |
| bdis_mthn | 사채발행방법 | 발행방법 |
| cv_rt | 전환비율(%) | 비율 |
| cv_prc | 전환가액(원/주) | 숫자 |
| cvisstk_knd | 전환에 따라 발행할 주식(종류) | 종류 |
| cvisstk_cnt | 전환에 따라 발행할 주식(주식수) | 숫자 |
| cvisstk_tisstk_vs | 전환에 따라 발행할 주식(주식총수 대비 비율%) | 비율 |
| cvrqpd_bgd | 전환청구기간(시작일) | 일자 |
| cvrqpd_edd | 전환청구기간(종료일) | 일자 |
| act_mktprcfl_cvprc_lwtrsprc | 시가하락에 따른 전환가액 조정(최저 조정가액) | 숫자(원) |
| act_mktprcfl_cvprc_lwtrsprc_bs | 시가하락에 따른 전환가액 조정(최저 조정가액 근거) | 근거 |
| rmislmt_lt70p | 발행당시 전환가액의 70% 미만으로 조정가능한 잔여 발행한도 | 숫자(원) |
| abmg | 합병 관련 사항 | 합병사항 |
| sbd | 청약일 | 일자 |
| pymd | 납입일 | 일자 |
| rpmcmp | 대표주관회사 | 회사명 |
| grint | 보증기관 | 기관명 |
| bddd | 이사회결의일(결정일) | 일자 |
| od_a_at_t | 사외이사 참석(명) | 숫자 |
| od_a_at_b | 사외이사 불참(명) | 숫자 |
| adt_a_atn | 감사(감사위원) 참석여부 | 여부 |
| rs_sm_atn | 증권신고서 제출대상 여부 | 여부 |
| ex_sm_r | 제출을 면제받은 경우 그 사유 | 사유 |
| ovis_ltdtl | 해외발행과 연계된 대차거래 내역 | 내역 |
| ftc_stt_atn | 공정거래위원회 신고대상 여부 | 여부 |
1. **신주인수권부사채권 발행결정**

**API URL:** bdwtIsDecsn

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| bd_tm | 사채의 종류(회차) | 회차 |
| bd_knd | 사채의 종류(종류) | 종류 |
| bd_fta | 사채의 권면(전자등록)총액 | 숫자(원) |
| atcsc_rmislmt | 정관상 잔여 발행한도 | 숫자(원) |
| ovis_fta | 해외발행(권면총액) | 숫자 |
| ovis_fta_crn | 해외발행(통화단위) | 통화 |
| ovis_ster | 해외발행(기준환율등) | 환율 |
| ovis_isar | 해외발행(발행지역) | 지역 |
| ovis_mktnm | 해외발행(해외상장시 시장의 명칭) | 시장명 |
| fdpp_fclt~fdpp_etc | 자금조달의 목적 | 숫자(원) |
| bd_intr_ex | 사채의 이율(표면이자율 %) | 비율 |
| bd_intr_sf | 사채의 이율(만기이자율 %) | 비율 |
| bd_mtd | 사채만기일 | 일자 |
| bdis_mthn | 사채발행방법 | 발행방법 |
| ex_rt | 신주인수권에 관한 사항(행사비율 %) | 비율 |
| ex_prc | 신주인수권에 관한 사항(행사가액 원/주) | 숫자 |
| ex_prc_dmth | 신주인수권에 관한 사항(행사가액 결정방법) | 결정방법 |
| bdwt_div_atn | 신주인수권에 관한 사항(사채와 인수권의 분리여부) | 여부 |
| nstk_pym_mth | 신주인수권에 관한 사항(신주대금 납입방법) | 납입방법 |
| nstk_isstk_knd | 신주인수권 행사에 따라 발행할 주식(종류) | 종류 |
| nstk_isstk_cnt | 신주인수권 행사에 따라 발행할 주식(주식수) | 숫자 |
| nstk_isstk_tisstk_vs | 신주인수권 행사에 따라 발행할 주식(주식총수 대비 비율%) | 비율 |
| expd_bgd | 권리행사기간(시작일) | 일자 |
| expd_edd | 권리행사기간(종료일) | 일자 |
| act_mktprcfl_cvprc_lwtrsprc | 시가하락에 따른 행사가액 조정(최저 조정가액) | 숫자(원) |
| act_mktprcfl_cvprc_lwtrsprc_bs | 시가하락에 따른 행사가액 조정(최저 조정가액 근거) | 근거 |
| rmislmt_lt70p | 발행당시 행사가액의 70% 미만으로 조정가능한 잔여 발행한도 | 숫자(원) |
| (공통 필드) | 합병관련, 청약일, 납입일, 대표주관회사, 보증기관, 이사회결의일 등 | 전환사채와 동일 |
1. **교환사채권 발행결정**

**API URL:** exbdIsDecsn

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| bd_tm | 사채의 종류(회차) | 회차 |
| bd_knd | 사채의 종류(종류) | 종류 |
| bd_fta | 사채의 권면(전자등록)총액 | 숫자(원) |
| ovis_fta~ovis_mktnm | 해외발행 관련 | 해외발행 정보 |
| fdpp_fclt~fdpp_etc | 자금조달의 목적 | 숫자(원) |
| bd_intr_ex | 사채의 이율(표면이자율 %) | 비율 |
| bd_intr_sf | 사채의 이율(만기이자율 %) | 비율 |
| bd_mtd | 사채만기일 | 일자 |
| bdis_mthn | 사채발행방법 | 발행방법 |
| ex_rt | 교환비율(%) | 비율 |
| ex_prc | 교환가액(원/주) | 숫자 |
| ex_prc_dmth | 교환가액 결정방법 | 결정방법 |
| extg | 교환대상(종류) | 종류 |
| extg_stkcnt | 교환대상(주식수) | 숫자 |
| extg_tisstk_vs | 교환대상(주식총수 대비 비율%) | 비율 |
| exrqpd_bgd | 교환청구기간(시작일) | 일자 |
| exrqpd_edd | 교환청구기간(종료일) | 일자 |
| (공통 필드) | 청약일, 납입일, 대표주관회사, 이사회결의일, 증권신고서 등 | 전환사채와 유사 |
1. **자기주식 취득 결정**

**API URL:** tsstkAqDecsn

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| rcept_no | 접수번호 | 접수번호(14자리) |
| corp_cls | 법인구분 | Y(유가), K(코스닥), N(코넥스), E(기타) |
| corp_code | 고유번호 | 공시대상회사의 고유번호(8자리) |
| corp_name | 회사명 | 공시대상회사명 |
| aqpln_stk_ostk | 취득예정주식(보통주식) | 숫자(주) |
| aqpln_stk_estk | 취득예정주식(기타주식) | 숫자(주) |
| aqpln_prc_ostk | 취득예정금액(보통주식) | 숫자(원) |
| aqpln_prc_estk | 취득예정금액(기타주식) | 숫자(원) |
| aqexpd_bgd | 취득예상기간(시작일) | 일자 |
| aqexpd_edd | 취득예상기간(종료일) | 일자 |
| hdexpd_bgd | 보유예상기간(시작일) | 일자 |
| hdexpd_edd | 보유예상기간(종료일) | 일자 |
| aq_pp | 취득목적 | 취득목적 |
| aq_mth | 취득방법 | 취득방법 |
| cs_iv_bk | 위탁투자중개업자 | 업자명 |
| aq_wtn_div_ostk | 취득 전 자기주식 보유현황(배당가능이익 범위 내 취득-보통주식) | 숫자(주) |
| aq_wtn_div_ostk_rt | 취득 전 자기주식 보유현황(배당가능이익 |  |
1. **자기주식 취득 결정 (tsstkAqDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| aq_wtn | 취득방법-장내직접취득 | 주식수 |
| aq_ovtm | 취득방법-시간외매매 | 주식수 |
| aq_pp | 취득방법-자사주펀드 | 주식수 |
| aq_etc | 취득방법-기타 | 주식수 |
| aq_wtn_am | 취득방법-장내직접취득 금액 | 원 |
| aq_ovtm_am | 취득방법-시간외매매 금액 | 원 |
| aq_pp_am | 취득방법-자사주펀드 금액 | 원 |
| aq_etc_am | 취득방법-기타 금액 | 원 |
| aq_stk_ostk | 취득주식-보통주 | 주식수 |
| aq_stk_estk | 취득주식-기타주식 | 주식수 |
| aq_expd_bgd | 취득예상기간-시작일 | YYYY-MM-DD |
| aq_expd_edd | 취득예상기간-종료일 | YYYY-MM-DD |
| aq_pp | 취득목적 | - |
| aq_mk_tm | 취득주식을 수탁한 신탁업자 | - |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| d1_slodlm_ostk | 1일 매수 주문수량 한도-보통주 | 주식수 |
| d1_slodlm_estk | 1일 매수 주문수량 한도-기타주식 | 주식수 |
1. **자기주식 처분 결정 (tsstkDpDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| dp_stk_ostk | 처분주식수-보통주 | 주식수 |
| dp_stk_estk | 처분주식수-기타주식 | 주식수 |
| dp_prc_ostk | 처분예정금액-보통주 | 원 |
| dp_prc_estk | 처분예정금액-기타주식 | 원 |
| dp_expd_bgd | 처분예정기간-시작일 | YYYY-MM-DD |
| dp_expd_edd | 처분예정기간-종료일 | YYYY-MM-DD |
| dp_pp | 처분목적 | - |
| dp_m | 처분방법 | - |
| dp_wtn | 처분방법-장내직접처분 | 주식수 |
| dp_ovtm | 처분방법-시간외매매 | 주식수 |
| dp_trco | 처분방법-교환 | 주식수 |
| dp_etc | 처분방법-기타 | 주식수 |
| cs_iv_bk | 자사주 교환거래의 상대방 | - |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| d1_slodlm_ostk | 1일 매도 주문수량 한도-보통주 | 주식수 |
| d1_slodlm_estk | 1일 매도 주문수량 한도-기타주식 | 주식수 |
1. **자기주식취득 신탁계약 체결 결정 (tsstkAqTrctrCnsDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| ctr_am | 계약금액 | 원 |
| ctr_pd_bgd | 계약기간-시작일 | YYYY-MM-DD |
| ctr_pd_edd | 계약기간-종료일 | YYYY-MM-DD |
| ctr_pp | 계약목적 | - |
| tc | 신탁업자 | - |
| ctr_cns_d | 계약체결일 | YYYY-MM-DD |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
1. **자기주식취득 신탁계약 해지 결정 (tsstkAqTrctrCcDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| ctr_m | 계약내용-계약금액 | 원 |
| ctr_m_pd | 계약내용-계약기간 | - |
| ctr_m_pp | 계약내용-계약목적 | - |
| ctr_m_atn | 계약내용-신탁업자 | - |
| cc_rs | 해지사유 | - |
| cc_d | 해지예정일 | YYYY-MM-DD |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
1. **영업양수 결정 (bsnInhDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| inh_bsn | 양수영업 | - |
| inh_bsn_pp | 양수영업의 주된 목적 | - |
| inh_prc | 양수가액 | 원 |
| inh_prc_ta | 양수가액-자산총계 대비 | % |
| inh_prc_mc | 양수가액-자기자본 대비 | % |
| inh_pd | 양수예정일 | YYYY-MM-DD |
| trf_cnm | 양도회사 | - |
| trf_ccd | 양도회사-고유번호 | - |
| trf_cap | 양도회사-대표이사 | - |
| trf_ccap | 양도회사-자본금 | 원 |
| trf_cr | 양도회사와의 관계 | - |
| inh_tr_bsn_rs | 양수영업의 내용 | - |
| inh_ta | 양수영업 최근 사업연도 자산총액 | 원 |
| inh_mc | 양수영업 최근 사업연도 당기순이익 | 원 |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| gm_da | 주주총회 예정일 | YYYY-MM-DD |
| drc | 채권자 이의제출기간 | - |
| ex_sm | 외부평가 여부-평가의견 | - |
| ex_evo | 외부평가 여부-평가기관 | - |
1. **영업양도 결정 (bsnTrfDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| trf_bsn | 양도영업 | - |
| trf_bsn_pp | 양도영업의 주된 목적 | - |
| trf_prc | 양도가액 | 원 |
| trf_prc_ta | 양도가액-자산총계 대비 | % |
| trf_prc_mc | 양도가액-매출액 대비 | % |
| trf_pd | 양도예정일 | YYYY-MM-DD |
| inh_cnm | 양수회사 | - |
| inh_ccd | 양수회사-고유번호 | - |
| inh_cap | 양수회사-대표이사 | - |
| inh_ccap | 양수회사-자본금 | 원 |
| inh_cr | 양수회사와의 관계 | - |
| trf_tr_bsn_rs | 양도영업의 내용 | - |
| trf_ta | 양도영업 최근 사업연도 자산총액 | 원 |
| trf_mc | 양도영업 최근 사업연도 당기순이익 | 원 |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| gm_da | 주주총회 예정일 | YYYY-MM-DD |
| drc | 채권자 이의제출기간 | - |
| ex_sm | 외부평가 여부-평가의견 | - |
| ex_evo | 외부평가 여부-평가기관 | - |
1. **유형자산 양수 결정 (tgastInhDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| inh_ast | 양수자산 | - |
| inh_pp | 양수목적 | - |
| inh_prc | 양수가액 | 원 |
| inh_prc_ta | 양수가액-자산총계 대비 | % |
| inh_prc_mc | 양수가액-자기자본 대비 | % |
| inh_pd | 양수예정일 | YYYY-MM-DD |
| trf_cnm | 양도자 | - |
| trf_cr | 양도자와의 관계 | - |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| ex_sm | 외부평가 여부-평가의견 | - |
| ex_evo | 외부평가 여부-평가기관 | - |
1. **유형자산 양도 결정 (tgastTrfDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| trf_ast | 양도자산 | - |
| trf_pp | 양도목적 | - |
| trf_prc | 양도가액 | 원 |
| trf_prc_ta | 양도가액-자산총계 대비 | % |
| trf_prc_mc | 양도가액-매출액 대비 | % |
| trf_pd | 양도예정일 | YYYY-MM-DD |
| inh_cnm | 양수자 | - |
| inh_cr | 양수자와의 관계 | - |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| ex_sm | 외부평가 여부-평가의견 | - |
| ex_evo | 외부평가 여부-평가기관 | - |
1. **타법인 주식 및 출자증권 양수결정 (otcprStkInvscrInhDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| ic_nm | 발행회사 | - |
| ic_cc | 발행회사-고유번호 | - |
| ic_crd | 발행회사-대표이사 | - |
| ic_cap | 발행회사-자본금 | 원 |
| ic_rsz | 발행회사-발행주식총수 | 주 |
| ic_r | 발행회사와의 관계 | - |
| inh_stk | 양수주식수 | 주 |
| inh_stk_rt | 양수주식-지분비율 | % |
| inh_prc | 양수가액 | 원 |
| inh_prc_ta | 양수가액-자산총계 대비 | % |
| inh_prc_mc | 양수가액-자기자본 대비 | % |
| inh_pp | 양수목적 | - |
| inh_pd | 양수예정일 | YYYY-MM-DD |
| trf | 양도자 | - |
| trf_r | 양도자와의 관계 | - |
| ba_rt | 양수 전 | 지분비율 % |
| af_rt | 양수 후 | 지분비율 % |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| ex_sm | 외부평가 여부-평가의견 | - |
| ex_evo | 외부평가 여부-평가기관 | - |
1. **타법인 주식 및 출자증권 양도결정 (otcprStkInvscrTrfDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| ic_nm | 발행회사 | - |
| ic_cc | 발행회사-고유번호 | - |
| ic_crd | 발행회사-대표이사 | - |
| ic_cap | 발행회사-자본금 | 원 |
| ic_rsz | 발행회사-발행주식총수 | 주 |
| ic_r | 발행회사와의 관계 | - |
| trf_stk | 양도주식수 | 주 |
| trf_stk_rt | 양도주식-지분비율 | % |
| trf_prc | 양도가액 | 원 |
| trf_prc_ta | 양도가액-자산총계 대비 | % |
| trf_prc_mc | 양도가액-매출액 대비 | % |
| trf_pp | 양도목적 | - |
| trf_pd | 양도예정일 | YYYY-MM-DD |
| inh | 양수자 | - |
| inh_r | 양수자와의 관계 | - |
| ba_rt | 양도 전 | 지분비율 % |
| af_rt | 양도 후 | 지분비율 % |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| ex_sm | 외부평가 여부-평가의견 | - |
| ex_evo | 외부평가 여부-평가기관 | - |
1. **주권 관련 사채권 양수 결정 (stkrtbdInhDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| bd_tp | 사채의 종류 | - |
| ic_nm | 발행회사 | - |
| ic_cc | 발행회사-고유번호 | - |
| ic_crd | 발행회사-대표이사 | - |
| ic_cap | 발행회사-자본금 | 원 |
| ic_r | 발행회사와의 관계 | - |
| inh_prc | 양수금액 | 원 |
| inh_prc_ta | 양수금액-자산총계 대비 | % |
| inh_prc_mc | 양수금액-자기자본 대비 | % |
| cv_stk | 권리행사시 취득주식 | 주 |
| cv_stk_rt | 권리행사시 취득주식-지분비율 | % |
| inh_pp | 양수목적 | - |
| inh_pd | 양수예정일 | YYYY-MM-DD |
| trf | 양도자 | - |
| trf_r | 양도자와의 관계 | - |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| ex_sm | 외부평가 여부-평가의견 | - |
| ex_evo | 외부평가 여부-평가기관 | - |
1. **주권 관련 사채권 양도 결정 (stkrtbdTrfDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| bd_tp | 사채의 종류 | - |
| ic_nm | 발행회사 | - |
| ic_cc | 발행회사-고유번호 | - |
| ic_crd | 발행회사-대표이사 | - |
| ic_cap | 발행회사-자본금 | 원 |
| ic_r | 발행회사와의 관계 | - |
| trf_prc | 양도금액 | 원 |
| trf_prc_ta | 양도금액-자산총계 대비 | % |
| trf_prc_mc | 양도금액-매출액 대비 | % |
| trf_pp | 양도목적 | - |
| trf_pd | 양도예정일 | YYYY-MM-DD |
| inh | 양수자 | - |
| inh_r | 양수자와의 관계 | - |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| ex_sm | 외부평가 여부-평가의견 | - |
| ex_evo | 외부평가 여부-평가기관 | - |
1. **회사합병 결정 (cmpMgDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| mg_cnm | 합병상대회사 | - |
| mg_ccd | 합병상대회사-고유번호 | - |
| mg_crd | 합병상대회사-대표이사 | - |
| mg_ccap | 합병상대회사-자본금 | 원 |
| mg_cr | 합병상대회사와의 관계 | - |
| mg_rt | 합병비율 | - |
| mg_rt_bs | 합병비율 산출근거 | - |
| mg_af | 합병교부금 등 | - |
| mg_pp | 합병목적 | - |
| mg_pd | 합병예정일 | YYYY-MM-DD |
| mg_tp | 합병형태 | - |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| gm_da | 주주총회 예정일 | YYYY-MM-DD |
| drc | 채권자 이의제출기간 | - |
| ex_sm | 외부평가 여부-평가의견 | - |
| ex_evo | 외부평가 여부-평가기관 | - |
1. **회사분할 결정 (cmpDvDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| dv_nc | 분할신설회사 | - |
| dv_nc_bs | 분할신설회사-분할되는 사업부문 | - |
| dv_nc_ns | 분할신설회사-분할 후 재산 및 채무부담 | - |
| dv_rt | 분할비율 | - |
| dv_rt_bs | 분할비율 산출근거 | - |
| dv_pp | 분할목적 | - |
| dv_pd | 분할예정일 | YYYY-MM-DD |
| dv_tp | 분할형태 | - |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| gm_da | 주주총회 예정일 | YYYY-MM-DD |
| drc | 채권자 이의제출기간 | - |
| ex_sm | 외부평가 여부-평가의견 | - |
| ex_evo | 외부평가 여부-평가기관 | - |
1. **회사분할합병 결정 (cmpDvmgDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| dvmg_cnm | 분할합병 상대회사 | - |
| dvmg_ccd | 분할합병 상대회사-고유번호 | - |
| dvmg_crd | 분할합병 상대회사-대표이사 | - |
| dvmg_ccap | 분할합병 상대회사-자본금 | 원 |
| dvmg_cr | 분할합병 상대회사와의 관계 | - |
| dv_bs | 분할되는 사업부문 | - |
| dv_ns | 분할 후 재산 및 채무부담 | - |
| dvmg_rt | 분할합병비율 | - |
| dvmg_rt_bs | 분할합병비율 산출근거 | - |
| dvmg_af | 분할합병 교부금 등 | - |
| dvmg_pp | 분할합병목적 | - |
| dvmg_pd | 분할합병예정일 | YYYY-MM-DD |
| dvmg_tp | 분할합병형태 | - |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| gm_da | 주주총회 예정일 | YYYY-MM-DD |
| drc | 채권자 이의제출기간 | - |
| ex_sm | 외부평가 여부-평가의견 | - |
| ex_evo | 외부평가 여부-평가기관 | - |
1. **주식교환·이전 결정 (stkExtrDecsn)**

| **응답키** | **명칭** | **출력설명** |
| --- | --- | --- |
| status | 에러 및 정보 코드 | 000:정상 |
| message | 에러 및 정보 메시지 | - |
| list | 응답결과 리스트 | - |
| rcept_no | 접수번호 | 14자리 |
| corp_cls | 법인구분 | Y:유가, K:코스닥, N:코넥스, E:기타 |
| corp_code | 고유번호 | 8자리 |
| corp_name | 회사명 | - |
| extr_tp | 주식교환·이전 구분 | - |
| extr_cnm | 주식교환·이전 상대회사 | - |
| extr_ccd | 주식교환·이전 상대회사-고유번호 | - |
| extr_crd | 주식교환·이전 상대회사-대표이사 | - |
| extr_ccap | 주식교환·이전 상대회사-자본금 | 원 |
| extr_cr | 주식교환·이전 상대회사와의 관계 | - |
| extr_rt | 주식교환·이전 비율 | - |
| extr_rt_bs | 주식교환·이전 비율 산출근거 | - |
| extr_af | 주식교환·이전 교부금 등 | - |
| extr_pp | 주식교환·이전 목적 | - |
| extr_pd | 주식교환·이전 예정일 | YYYY-MM-DD |
| bddd | 이사회결의일(결정일) | YYYY-MM-DD |
| od_a_at_t | 사외이사 참석여부-참석(명) | - |
| od_a_at_b | 사외이사 참석여부-불참(명) | - |
| adt_a_atn | 감사(감사위원) 참석 여부 | - |
| rs_sm_atn | 결의내용-찬성 | - |
| rs_sm_otn | 결의내용-반대 | - |
| rs_sm_xtn | 결의내용-기권 | - |
| gm_da | 주주총회 예정일 | YYYY-MM-DD |
| drc | 채권자 이의제출기간 | - |
| ex_sm | 외부평가 여부-평가의견 | - |
| ex_evo | 외부평가 여부-평가기관 | - |