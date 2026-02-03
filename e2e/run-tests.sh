#!/bin/bash

# Activity Tracker E2E Test Runner
# Usage: ./run-tests.sh [test-name]

set -e

# Configuration
APP_BUNDLE_ID="com.activitytracker.ActivityTracker"
DEVICE_NAME="iPhone 17 Pro"
APP_PATH="${APP_PATH:-/Users/shayco/Library/Developer/Xcode/DerivedData/ActivityTracker-accqohzvmamtcobrxvyxzxeroqug/Build/Products/Debug-iphonesimulator/ActivityTracker.app}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Activity Tracker E2E Tests"
echo "=========================================="

# Check if Maestro is installed
if ! command -v maestro &> /dev/null; then
    echo -e "${YELLOW}Maestro not found. Installing...${NC}"
    curl -Ls "https://get.maestro.mobile.dev" | bash
    export PATH="$PATH:$HOME/.maestro/bin"
fi

# Boot simulator if needed
echo -e "\n${YELLOW}Checking simulator status...${NC}"
if ! xcrun simctl list devices | grep "$DEVICE_NAME" | grep -q "Booted"; then
    echo "Booting $DEVICE_NAME..."
    xcrun simctl boot "$DEVICE_NAME" 2>/dev/null || true
    sleep 5
fi

# Install app
echo -e "\n${YELLOW}Installing app...${NC}"
if [ -d "$APP_PATH" ]; then
    xcrun simctl install booted "$APP_PATH"
    echo -e "${GREEN}App installed successfully${NC}"
else
    echo -e "${RED}App not found at: $APP_PATH${NC}"
    echo "Please build the app first with: xcodebuild build -scheme ActivityTracker"
    exit 1
fi

# Pre-grant permissions
echo -e "\n${YELLOW}Granting HealthKit permissions...${NC}"
xcrun simctl privacy booted grant health-share "$APP_BUNDLE_ID" 2>/dev/null || true
xcrun simctl privacy booted grant health-clinical "$APP_BUNDLE_ID" 2>/dev/null || true
xcrun simctl privacy booted grant motion "$APP_BUNDLE_ID" 2>/dev/null || true

# Create output directories
mkdir -p tests/screenshots
mkdir -p tests/videos
mkdir -p tests/results

# Run tests
echo -e "\n${YELLOW}Running E2E tests...${NC}"
echo "=========================================="

TEST_DIR="$(dirname "$0")/tests"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="tests/results/e2e-results-${TIMESTAMP}.json"

if [ -n "$1" ]; then
    # Run specific test
    TEST_FILE="$TEST_DIR/$1.yaml"
    if [ -f "$TEST_FILE" ]; then
        echo -e "\nRunning: $1"
        maestro test "$TEST_FILE" --output "tests/results/$1-${TIMESTAMP}.xml"
    else
        echo -e "${RED}Test not found: $TEST_FILE${NC}"
        exit 1
    fi
else
    # Run all tests
    TESTS=("onboarding" "workout-flow" "achievements" "settings")
    PASSED=0
    FAILED=0
    
    for test in "${TESTS[@]}"; do
        echo -e "\n${YELLOW}Running: $test${NC}"
        TEST_FILE="$TEST_DIR/$test.yaml"
        
        if maestro test "$TEST_FILE" --output "tests/results/$test-${TIMESTAMP}.xml"; then
            echo -e "${GREEN}✓ $test PASSED${NC}"
            ((PASSED++))
        else
            echo -e "${RED}✗ $test FAILED${NC}"
            ((FAILED++))
        fi
    done
    
    echo ""
    echo "=========================================="
    echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}"
    echo "=========================================="
    
    # Exit with error if any tests failed
    [ $FAILED -eq 0 ] || exit 1
fi

echo -e "\n${GREEN}E2E tests completed!${NC}"
echo "Screenshots: tests/screenshots/"
echo "Results: tests/results/"
