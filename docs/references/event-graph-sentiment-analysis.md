### PR

https://github.com/Stockelper-Lab/stockelper-kg/compare/feat/refactoring-code?expand=1

## 온톨로지 구현

### 1. 회사 정보 지식 그래프 (기존 구현)

이벤트 그래프와 매핑되도록 일부 구현 통일 (date)

### 2. 이벤트 지식 그래프 구축

이벤트(뉴스) 프롬프트가 들어오면 이벤트 그래프 생성

### 3. 회사~이벤트 지식 그래프 연결

![image.png](attachment:17f413a8-a763-42f7-85a6-3a88b4c08f57:image.png)

![image.png](attachment:90f9c15d-89f9-4265-b5e7-ab36648cd444:image.png)

### 병렬 처리

기존 코드는 배치 사이즈를 사용하고 있으나, 실질적으로 직렬 처리가 되고있어 배치 사이즈의 크기가 실행 속도에 영향을 주지 못하고 있었음.

따라서, 배치 사이즈 대신 thread를 도입해 분할적으로 작업을 실행할 수 있도록 함

약 25분 정도 걸리던 작업을, 6~9분까지 속도 절감 (4 thread 기준)

```sql
2025-12-08 13:06:15,075 - stockelper_kg.utils.decorators - INFO - Total Time: 00:07:04
```

## **TODO 및 고민점**

### **Entity Resolution**

뉴스 데이터에서 뽑은 데이터를 Neo4j에 있는 노드에 어떻게 넣을 것인가?

- Entity Resolution: 어떻게 같은 엔티티로 통일시킬 것인가? (e.g SK하이닉스, SKHynix .. )
- Entity Linking: 어디에 속하는 노드인지 아는가? (Facility? Product? ... )

### **Multi Event**

- 이벤트가 여러개 나올 수 있거나, 회사 관련 노드가 여러개 나올 수 있는 경우 처리
    - 기아-현대차 일 경우, Company.corp_name: 기아, Company.corp_name: 현대차 두개로 분리
    - 여러개 이벤트 분리 나올 수 있는 경우 분리

### **실시간 이벤트 처리**

- airflow와 연동해서 처리 필요

### **경쟁사 연결**

- MongoDB 연결이 되지 않아 경쟁사 관련 정보 확인하지 못했음.

---

### 감성분석

### Neo4j Server Production

이벤트 추출 로직에 감성 분석 로직을 추가하였습니다. 이벤트 추출 시 `sentiment_score`로 -1~1 사이의 점수가 추출됩니다.

내용은 희주님께서 작성해주신 감성분석 프롬프트를 참고하였습니다. ([https://www.notion.so/2c35fda040b580ff87d6dedba4685234?source=copy_link#2c85fda040b5803bbb8fe31ab9d7627c](https://www.notion.so/2c35fda040b580ff87d6dedba4685234?pvs=21))

### **Little some change**

`builder.py`와 `payload.py` 리팩토링이 진행되었습니다.

![image](https://private-user-images.githubusercontent.com/42240862/526260265-7c2b3c8b-f379-41ed-af45-b5bdb3b60df6.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NjU3OTgxODUsIm5iZiI6MTc2NTc5Nzg4NSwicGF0aCI6Ii80MjI0MDg2Mi81MjYyNjAyNjUtN2MyYjNjOGItZjM3OS00MWVkLWFmNDUtYjViZGIzYjYwZGY2LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTEyMTUlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUxMjE1VDExMjQ0NVomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWY1N2NlNThmZTE2YWYwYWE5MjE3YjEzNTMxZDU3NDkxZjQ3YjkyZGJlNmQxMjYwNjIxZTA1NWU3OWYyMDg5OTYmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.UfcrlB_FHsnAZ25K-HDr2CH2V1u1yRY_QY5_EMEztrA)

https://github.com/Stockelper-Lab/stockelper-kg/pull/7