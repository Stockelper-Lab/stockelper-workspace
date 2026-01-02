현재 MongoDB에는 100개의 뉴스만 있어서, [daekeun-ml/naver-news-summarization-ko](https://huggingface.co/datasets/daekeun-ml/naver-news-summarization-ko)에 있는 22k 개수의 뉴스로 중복제거 로직을 테스트해봄 

```python
20287개의 뉴스 중 실제 삭제된 개수 (중복 뉴스가 없음)
{0.9: 91, 0.8: 377, 0.7: 807, 0.6: 1295, 0.5: 2323}

22194개의 뉴스 중 (중복 뉴스 포함)
{0.9: 1998, 0.8: 2284, 0.7: 2714, 0.6: 3202, 0.5: 4230}
```

실제 Threshold를 0.9부터 0.5까지 설정함에 따라 제거된 중복으로 판단된 개수

---

완전 중복인 경우는 잘 탐지된다는 가정하에서 100% 중복이 없는 경우에 대해 비슷한 뉴스가 잘 탐지된지 확인 시에 거의 비슷한 뉴스들이 잘 제거되는 것을 확인함. 

단, 좀 더 비슷한 것도 제거하길 원하면 threshold를 더 낮게하면 되고 반대면 높게 설정하면 될 듯 

```jsx
금융감독원이 발표한 상장사의 최대주주 변경 실태분석 결과 자료에 따르면 2019부터 지난해까지 3년간 최대주주가 변경된 상장사는 총 501개사로 집계됐다. 사진 뉴스1 최근 3년간 상장사 5곳 가운데 1곳에서 최대주주 변경이 발생한 것으로 나타났다. 금융감독원은 최대주주가 빈번하게 바뀐 곳에서는 횡령·배임 재무상태 부실 등이 발생할 가능성이 높다며 투자자들...

상장사의 최대주주 변경 실태분석 결과 자료에 따르면 2019부터 지난해까지 3년간 최대주주가 변경된 상장사는 총 501개사로 지난해 말 기준 전체 상장사 2383개사 의 21.0% 수준이다. 사진 뉴스1 금융감독원이 최대주주가 자주 바뀐 기업에서 횡령·배임 재무상태 부실 등이 발생할 가능성이 높다며 투자자들에게 주의를 당부했다. 4일 금감원이 발표한 상장사...
```

```jsx
뉴스리뷰 앵커 6월 소비자물가 상승률이 6%를 기록하면서 한국은행이 기준금리를 한 번에 0.5% 포인트 올리는 빅스텝 을 사상 처음으로 단행할 것이란 전망이 나옵니다. 그래도 고공행진하는 물가를 잡을 수 있을진 미지수여서 통화당국의 고민이 깊어지고 있습니다. 김동욱 기자입니다. 기자 6% 급등하며 외환위기 이후 약 24년 만에 최고를 나타낸 6월 소비자물가..

앵커 6월 소비자물가 상승률이 6%를 기록하면서 한국은행이 기준금리를 한 번에 0.5% 포인트 올리는 빅스텝 을 사상 처음으로 단행할 것이란 전망이 나옵니다. 그래도 고공행진하는 물가를 잡을 수 있을진 미지수여서 통화당국의 고민이 깊어지고 있습니다. 김동욱 기자입니다. 기자 6% 급등하며 외환위기 이후 약 24년 만에 최고를 나타낸 6월 소비자물가. 올여름...
```

---

아래에서 샘플 테스트 해볼 수 있음 

```jsx
from datasketch import MinHash, MinHashLSH
from nltk.util import ngrams      # O (올바른 경로)
from tqdm import tqdm

class MinHashDeduplicator:
    def __init__(self, threshold=0.7, num_perm=128, n_gram=3):
        self.threshold = threshold
        self.num_perm = num_perm
        self.n_gram = n_gram
        # LSH(Locality Sensitive Hashing) 인덱스 생성
        self.lsh = MinHashLSH(threshold=self.threshold, num_perm=self.num_perm)
        self.seen_hashes = {} # 중복 체크를 위한 저장소
        
    def _get_minhash(self, text):
        tokens = text.split()

        m = MinHash(num_perm=self.num_perm)

        if len(tokens) < self.n_gram:
            # 짧은 문장은 토큰 단위로 업데이트
            for tok in tokens:
                m.update(tok.encode('utf-8'))
            return m

        # N-gram을 구분자와 함께 결합해 경계를 유지
        for gram in ngrams(tokens, self.n_gram):
            s = " ".join(gram).encode('utf-8')
            m.update(s)
        return m

    def deduplicate(self, texts):
        unique_texts = []
        
        print(f"MinHash 중복 제거 시작 (총 {len(texts)}개)...")
        
        # 1차 순회: LSH 인덱스 구축 및 중복 확인
        for i, text in enumerate(tqdm(texts)):
                
            minhash = self._get_minhash(text)
            
            # 현재 텍스트와 유사한게 이미 LSH에 있는지 조회
            result = self.lsh.query(minhash)
            
            if len(result) == 0:
                # 유사한게 없으면 -> 유니크함 -> 저장소에 등록
                self.lsh.insert(f"doc_{i}", minhash)
                unique_texts.append(text)
            else:
                # 이미 유사한 문서가 존재함 -> 중복으로 간주하고 패스
                pass
                
        print(f"완료! 원본: {len(texts)} -> 정제 후: {len(unique_texts)}")
        return unique_texts

if __name__ == "__main__":
    data = [
        "한국어 특화 LLM을 만드는 연구자입니다.",          # 원본
        "저는 한국어 특화 LLM을 만드는 연구자입니다.",      # 유사함 (중복 제거 대상)
        "한국어 LLM 연구를 진행하고 있습니다.",             # 다름 (유지)
        "완전히 다른 문장입니다.",                         # 다름 (유지)
        "한국어 특화 LLM을 만드는 연구자입니다."            # 완전 중복 (중복 제거 대상)
    ]

    deduper = MinHashDeduplicator(threshold=0.5) # 테스트라 threshold를 낮게 잡음
    clean_data = deduper.deduplicate(data)

    print("\n[최종 결과]")
    for text in clean_data:
        print(f"- {text}")
```