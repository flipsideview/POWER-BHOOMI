#!/bin/bash

# POWER-BHOOMI Version Test Script
# Tests both 4-worker and 8-worker versions for basic functionality

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║       POWER-BHOOMI Version Validation Test                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test Python availability
echo -e "${YELLOW}[1/5] Checking Python...${NC}"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓ $PYTHON_VERSION${NC}"
else
    echo -e "${RED}✗ Python3 not found${NC}"
    exit 1
fi

# Test if files exist
echo ""
echo -e "${YELLOW}[2/5] Checking files...${NC}"
if [ -f "bhoomi_web_app_v2.py" ]; then
    echo -e "${GREEN}✓ 4 Workers version found${NC}"
else
    echo -e "${RED}✗ 4 Workers version missing${NC}"
    exit 1
fi

if [ -f "bhoomi_web_app_v2_8workers.py" ]; then
    echo -e "${GREEN}✓ 8 Workers version found${NC}"
else
    echo -e "${RED}✗ 8 Workers version missing${NC}"
    exit 1
fi

# Check syntax of both files
echo ""
echo -e "${YELLOW}[3/5] Validating Python syntax...${NC}"
if python3 -m py_compile bhoomi_web_app_v2.py 2>/dev/null; then
    echo -e "${GREEN}✓ 4 Workers version syntax valid${NC}"
else
    echo -e "${RED}✗ 4 Workers version has syntax errors${NC}"
    exit 1
fi

if python3 -m py_compile bhoomi_web_app_v2_8workers.py 2>/dev/null; then
    echo -e "${GREEN}✓ 8 Workers version syntax valid${NC}"
else
    echo -e "${RED}✗ 8 Workers version has syntax errors${NC}"
    exit 1
fi

# Check for required dependencies
echo ""
echo -e "${YELLOW}[4/5] Checking dependencies...${NC}"
MISSING_DEPS=0

python3 -c "import flask" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Flask installed${NC}"
else
    echo -e "${RED}✗ Flask missing (pip install flask)${NC}"
    MISSING_DEPS=1
fi

python3 -c "import selenium" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Selenium installed${NC}"
else
    echo -e "${RED}✗ Selenium missing (pip install selenium)${NC}"
    MISSING_DEPS=1
fi

python3 -c "from bs4 import BeautifulSoup" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ BeautifulSoup4 installed${NC}"
else
    echo -e "${RED}✗ BeautifulSoup4 missing (pip install beautifulsoup4)${NC}"
    MISSING_DEPS=1
fi

python3 -c "import requests" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Requests installed${NC}"
else
    echo -e "${RED}✗ Requests missing (pip install requests)${NC}"
    MISSING_DEPS=1
fi

# Check worker configuration
echo ""
echo -e "${YELLOW}[5/5] Verifying worker configuration...${NC}"
WORKERS_4=$(grep "MAX_WORKERS = 4" bhoomi_web_app_v2.py)
WORKERS_8=$(grep "MAX_WORKERS = 8" bhoomi_web_app_v2_8workers.py)

if [ ! -z "$WORKERS_4" ]; then
    echo -e "${GREEN}✓ 4 Workers version: MAX_WORKERS = 4${NC}"
else
    echo -e "${RED}✗ 4 Workers version configuration error${NC}"
fi

if [ ! -z "$WORKERS_8" ]; then
    echo -e "${GREEN}✓ 8 Workers version: MAX_WORKERS = 8${NC}"
else
    echo -e "${RED}✗ 8 Workers version configuration error${NC}"
fi

# Final summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
if [ $MISSING_DEPS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Both versions ready to use.${NC}"
    echo ""
    echo "To run 4 Workers version:"
    echo "  python3 bhoomi_web_app_v2.py"
    echo ""
    echo "To run 8 Workers version:"
    echo "  python3 bhoomi_web_app_v2_8workers.py"
    echo ""
    echo "Then navigate to: http://localhost:5001"
else
    echo -e "${YELLOW}⚠ Some dependencies missing. Install them first:${NC}"
    echo "  pip install -r requirements.txt"
fi
echo "═══════════════════════════════════════════════════════════════"

