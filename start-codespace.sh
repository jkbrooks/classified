#!/bin/bash

# ElizaOS Codespace Quick Start Script
# This script helps you get ElizaOS running in GitHub Codespaces

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 ElizaOS Codespace Quick Start${NC}"
echo "=================================="

# Function to get codespace name
get_codespace_name() {
    if [ -n "$CODESPACE_NAME" ]; then
        echo "$CODESPACE_NAME"
    else
        # Fallback: extract from hostname or environment
        hostname | sed 's/codespaces-[a-f0-9]*//' | sed 's/^-*//' | sed 's/-*$//'
    fi
}

# Get the codespace name
CODESPACE=$(get_codespace_name)

echo -e "${YELLOW}📍 Detected Codespace: $CODESPACE${NC}"
echo ""

# Check if devcontainer is properly set up
if [ ! -f ".devcontainer/devcontainer.json" ]; then
    echo -e "${RED}❌ Devcontainer not found. Please rebuild the container first.${NC}"
    echo "Run: Ctrl+Shift+P -> 'Dev Containers: Rebuild Container'"
    exit 1
fi

# Export paths for tools
export PATH="$HOME/.cargo/bin:$HOME/.bun/bin:$PATH"

# Check if PostgreSQL is running
echo -e "${YELLOW}🔍 Checking PostgreSQL connection...${NC}"
if ! psql "postgresql://postgres:postgres@db:5432/eliza" -c "SELECT 1;" >/dev/null 2>&1; then
    echo -e "${RED}❌ PostgreSQL not available. Rebuilding devcontainer...${NC}"
    echo "Please run: Ctrl+Shift+P -> 'Dev Containers: Rebuild Container'"
    exit 1
fi
echo -e "${GREEN}✅ PostgreSQL is running${NC}"

# Display URLs that will be available
echo ""
echo -e "${BLUE}🌐 Your ElizaOS URLs (after starting):${NC}"
echo "=================================="
echo -e "Frontend (React UI): ${GREEN}https://${CODESPACE}-5173.app.github.dev${NC}"
echo -e "Backend API:         ${GREEN}https://${CODESPACE}-7777.app.github.dev${NC}"
echo -e "Database (external): ${GREEN}${CODESPACE}-5432.app.github.dev${NC}"
echo ""

# Ask what to start
echo -e "${YELLOW}What would you like to start?${NC}"
echo "1) Full development mode (backend + frontend)"
echo "2) Backend only (AgentServer on port 7777)"
echo "3) Frontend only (Vite on port 5173)"
echo "4) Just show me the setup info"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo -e "${BLUE}🎯 Starting full development mode...${NC}"
        echo ""
        echo "This will:"
        echo "- Build and start the AgentServer (port 7777)"
        echo "- Start the Vite frontend (port 5173)"
        echo "- Enable hot reload for development"
        echo ""
        echo -e "${YELLOW}⏳ Starting in 3 seconds... (Ctrl+C to cancel)${NC}"
        sleep 3
        cd packages/game
        bun run dev
        ;;
    2)
        echo -e "${BLUE}🎯 Starting backend only...${NC}"
        echo ""
        echo "AgentServer will be available at:"
        echo -e "${GREEN}https://${CODESPACE}-7777.app.github.dev${NC}"
        echo ""
        echo -e "${YELLOW}⏳ Starting in 3 seconds... (Ctrl+C to cancel)${NC}"
        sleep 3
        cd packages/agentserver
        bun run dev
        ;;
    3)
        echo -e "${BLUE}🎯 Starting frontend only...${NC}"
        echo ""
        echo "Frontend will be available at:"
        echo -e "${GREEN}https://${CODESPACE}-5173.app.github.dev${NC}"
        echo ""
        echo -e "${YELLOW}⏳ Starting in 3 seconds... (Ctrl+C to cancel)${NC}"
        sleep 3
        cd packages/game
        bun vite dev --host 0.0.0.0 --port 5173
        ;;
    4)
        echo -e "${BLUE}📋 Setup Information${NC}"
        echo "==================="
        echo ""
        echo "Manual commands:"
        echo ""
        echo "Backend only:"
        echo "  cd packages/agentserver && bun run dev"
        echo ""
        echo "Frontend only:"
        echo "  cd packages/game && bun vite dev --host 0.0.0.0 --port 5173"
        echo ""
        echo "Full development:"
        echo "  cd packages/game && bun run dev"
        echo ""
        echo "Test API:"
        echo "  curl https://${CODESPACE}-7777.app.github.dev/api/server/ping"
        echo ""
        echo "Test Database:"
        echo "  psql \"postgresql://postgres:postgres@db:5432/eliza\""
        echo ""
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac
