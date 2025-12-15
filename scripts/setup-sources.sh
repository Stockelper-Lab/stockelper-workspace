#!/bin/bash

# ============================================================
# Stockelper Workspace - Sources Setup Script
# ============================================================
# 이 스크립트는 BMAD 워크스페이스에서 서비스 레포들을
# sources/ 디렉터리에 심볼릭 링크로 연결합니다.
#
# 사용법:
#   ./scripts/setup-sources.sh
#
# 전제조건:
#   - 상위 디렉터리에 서비스 레포들이 clone 되어 있어야 함
# ============================================================

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 스크립트 위치 기준으로 workspace 루트 찾기
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"
SOURCES_DIR="$WORKSPACE_ROOT/sources"
PARENT_DIR="$(dirname "$WORKSPACE_ROOT")"

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}  Stockelper BMAD Workspace - Sources Setup${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# 서비스 레포 정보
declare -A SERVICES=(
    ["airflow"]="stockelper-airflow"
    ["fe"]="stockelper-fe"
    ["kg"]="stockelper-kg"
    ["llm"]="stockelper-llm"
    ["news-crawler"]="stockelper-news-crawler"
)

# sources 디렉터리 생성
mkdir -p "$SOURCES_DIR"

echo -e "${YELLOW}📁 Workspace: $WORKSPACE_ROOT${NC}"
echo -e "${YELLOW}📁 Sources: $SOURCES_DIR${NC}"
echo -e "${YELLOW}📁 Parent (레포 위치): $PARENT_DIR${NC}"
echo ""

# 각 서비스에 대해 심볼릭 링크 생성
success_count=0
fail_count=0

for service in "${!SERVICES[@]}"; do
    repo="${SERVICES[$service]}"
    repo_path="$PARENT_DIR/$repo"
    link_path="$SOURCES_DIR/$service"
    
    echo -n "  [$service] "
    
    # 이미 링크가 존재하는지 확인
    if [ -L "$link_path" ]; then
        echo -e "${YELLOW}⚠️  이미 존재 (스킵)${NC}"
        ((success_count++))
        continue
    fi
    
    # 레포가 존재하는지 확인
    if [ -d "$repo_path" ]; then
        # 심볼릭 링크 생성 (상대 경로 사용)
        ln -s "../../$repo" "$link_path"
        echo -e "${GREEN}✅ 링크 생성됨 → $repo${NC}"
        ((success_count++))
    else
        echo -e "${RED}❌ 레포 없음: $repo_path${NC}"
        ((fail_count++))
    fi
done

echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "  결과: ${GREEN}$success_count 성공${NC}, ${RED}$fail_count 실패${NC}"
echo -e "${BLUE}============================================================${NC}"

# 실패한 레포가 있으면 clone 안내
if [ $fail_count -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}💡 누락된 레포를 clone하려면:${NC}"
    echo ""
    echo "  cd $PARENT_DIR"
    for service in "${!SERVICES[@]}"; do
        repo="${SERVICES[$service]}"
        repo_path="$PARENT_DIR/$repo"
        if [ ! -d "$repo_path" ]; then
            if [ "$service" == "news-crawler" ]; then
                echo -e "  git clone git@github.com:YOUR_ORG/$repo.git  ${RED}(🔒 Private)${NC}"
            else
                echo "  git clone https://github.com/YOUR_ORG/$repo.git"
            fi
        fi
    done
    echo ""
fi

# 현재 상태 표시
echo ""
echo -e "${BLUE}📋 현재 sources/ 상태:${NC}"
ls -la "$SOURCES_DIR" 2>/dev/null | grep -v "^total" | grep -v "^\." || echo "  (비어있음)"
echo ""



