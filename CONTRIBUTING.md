# 기여 가이드 (Contributing Guide)

Stockelper BMAD 워크스페이스에 기여해 주셔서 감사합니다!

---

## 📋 기여 유형

### 1. 문서/정책 변경 (이 레포)

BMAD 에이전트, 정책, 템플릿, PRD 등의 변경은 이 레포에서 PR을 올립니다.

```bash
# 브랜치 생성
git checkout -b docs/update-prd-template

# 변경 후 커밋
git add .
git commit -m "docs: PRD 템플릿에 성공 지표 섹션 추가"

# PR 생성
git push origin docs/update-prd-template
```

### 2. 서비스 코드 변경 (각 서비스 레포)

서비스별 코드 변경은 해당 서비스 레포에서 작업합니다.

```bash
# 예: KG 서비스 수정
cd sources/kg
git checkout -b feature/add-similarity-api

# 작업 후 해당 레포에서 PR
```

---

## 🌿 브랜치 네이밍 규칙

| 유형 | 패턴 | 예시 |
|------|------|------|
| 기능 추가 | `feature/*` | `feature/add-analyst-agent` |
| 문서 수정 | `docs/*` | `docs/update-readme` |
| 버그 수정 | `bugfix/*` | `bugfix/fix-policy-path` |
| 핫픽스 | `hotfix/*` | `hotfix/critical-agent-fix` |

---

## 📝 커밋 메시지 규칙

[Conventional Commits](https://www.conventionalcommits.org/) 형식을 따릅니다.

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Type

| Type | 설명 |
|------|------|
| `feat` | 새로운 기능 |
| `fix` | 버그 수정 |
| `docs` | 문서 변경 |
| `refactor` | 리팩터링 |
| `test` | 테스트 추가/수정 |
| `chore` | 기타 변경 |

### Scope (선택)

- `agents`: 에이전트 관련
- `policies`: 정책 관련
- `templates`: 템플릿 관련
- `docs`: 문서 관련

### 예시

```bash
feat(agents): Analyst 에이전트에 KG 분석 역할 추가
docs(templates): Epic 템플릿에 서비스 의존성 섹션 추가
fix(policies): org.yaml 파일 경로 오류 수정
```

---

## 🔄 PR 프로세스

### 1. PR 생성

- 명확한 제목과 설명 작성
- 관련 이슈가 있으면 링크
- 리뷰어 지정

### 2. 리뷰

- 최소 1명의 승인 필요
- 모든 코멘트 해결

### 3. 머지

- Squash Merge 권장
- 머지 후 브랜치 삭제

---

## 📂 파일별 수정 가이드

### `.bmad/agents/*.md`

에이전트 정의 파일입니다.

- 역할과 책임 명확히 정의
- 서비스별 컨텍스트 포함
- 워크플로 다이어그램 포함

### `.bmad/policies/org.yaml`

조직 공통 정책입니다.

- 파일/네트워크/코드 정책 정의
- 서비스별 오버라이드 가능
- 변경 시 팀 전체 공지 필요

### `.bmad/templates/*.md`

문서 템플릿입니다.

- 마크다운 형식 유지
- 플레이스홀더는 `[대괄호]` 사용
- 테이블 형식 활용

### `docs/prd/*.md`, `docs/epics/*.md`

실제 PRD, Epic 문서입니다.

- 템플릿 기반으로 작성
- 파일명에 ID 포함 (예: `PRD-001-feature.md`)
- 상태 업데이트 시 날짜 기록

---

## ✅ 체크리스트

PR 생성 전 확인사항:

- [ ] 브랜치 네이밍 규칙 준수
- [ ] 커밋 메시지 규칙 준수
- [ ] 관련 문서 업데이트
- [ ] `.gitignore` 확인 (민감 정보 제외)
- [ ] 마크다운 문법 오류 없음

---

## 🆘 도움이 필요하면

- 이슈 생성: GitHub Issues
- 팀 채널: (Slack/Discord 링크)
- 담당자: (연락처)



