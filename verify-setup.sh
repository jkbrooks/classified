#!/bin/bash

echo "🚀 ElizaOS Development Environment Verification"
echo "=============================================="

# Export paths
export PATH="$HOME/.cargo/bin:$HOME/.bun/bin:$PATH"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_tool() {
    local tool=$1
    local command=$2
    
    if command -v $tool >/dev/null 2>&1; then
        local version=$($command 2>/dev/null || echo "unknown")
        echo -e "${GREEN}✅ $tool: $version${NC}"
        return 0
    else
        echo -e "${RED}❌ $tool: Not found${NC}"
        return 1
    fi
}

check_postgres() {
    echo -e "${YELLOW}🔍 Testing PostgreSQL connection...${NC}"
    
    # Check if we can connect to the database (this will work once devcontainer is rebuilt)
    if command -v psql >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PostgreSQL client installed${NC}"
        echo "   To test connection after devcontainer rebuild:"
        echo "   psql \"postgresql://postgres:postgres@db:5432/eliza\""
    else
        echo -e "${RED}❌ PostgreSQL client not found${NC}"
        return 1
    fi
}

echo "📋 Checking required tools..."
echo ""

# Check all required tools
all_good=true

check_tool "node" "node --version" || all_good=false
check_tool "bun" "bun --version" || all_good=false
check_tool "cargo" "cargo --version" || all_good=false
check_tool "cargo-tauri" "cargo-tauri --version" || all_good=false

echo ""
check_postgres || all_good=false

echo ""
echo "📦 Project structure check..."
if [ -f "package.json" ]; then
    echo -e "${GREEN}✅ package.json found${NC}"
else
    echo -e "${RED}❌ package.json not found${NC}"
    all_good=false
fi

if [ -d ".devcontainer" ]; then
    echo -e "${GREEN}✅ .devcontainer directory found${NC}"
else
    echo -e "${RED}❌ .devcontainer directory not found${NC}"
    all_good=false
fi

if [ -d "packages/game" ]; then
    echo -e "${GREEN}✅ Game package found${NC}"
else
    echo -e "${RED}❌ Game package not found${NC}"
    all_good=false
fi

echo ""
echo "🏗️  Build test..."
if bun run lint >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Linting passes${NC}"
else
    echo -e "${YELLOW}⚠️  Linting has issues (may be normal)${NC}"
fi

echo ""
echo "=============================================="
if [ "$all_good" = true ]; then
    echo -e "${GREEN}🎉 Setup verification complete! All tools are ready.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Rebuild your devcontainer to activate PostgreSQL"
    echo "2. Run 'bun run dev' to start development mode"
    echo "3. Run 'bun run test' to run tests"
else
    echo -e "${RED}❌ Some issues found. Please check the errors above.${NC}"
fi
echo "=============================================="
