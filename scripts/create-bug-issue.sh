#!/bin/bash
# Create a GitHub issue for a bug discovered during testing
#
# This script is used when an agent discovers a bug while running tests
# and needs to create a structured bug report issue.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Default values
TITLE=""
TEST_COMMAND=""
TEST_NAME=""
ERROR_OUTPUT=""
EXPECTED=""
ACTUAL=""
SUSPECTED_CAUSE=""
FILES=""
SEVERITY="medium"
LABELS=""
START_WORK=false

# Usage
usage() {
    cat << EOF
Usage: $0 [options]

Create a GitHub issue for a bug discovered during testing.

Required:
  --title <title>          Issue title (will be prefixed with "Bug: ")
  --test-command <cmd>     Test command that was run (e.g., "yarn test src/...")
  --error <text>           Error output from test failure

Optional:
  --test-name <name>       Name of the failing test
  --expected <text>        What was expected to happen
  --actual <text>          What actually happened
  --cause <text>           Suspected cause of the bug
  --files <files>          Files involved (comma-separated)
  --severity <level>       Bug severity: critical, high, medium, low (default: medium)
  --labels <labels>        Additional labels (comma-separated)
  --start                  Immediately start work (create worktree)

Examples:
  # Basic bug report
  $0 --title "UserService.createUser not validating email" \\
     --test-command "yarn test src/services/user.service.test.ts" \\
     --error "Expected ValidationError, got undefined"

  # Detailed bug report
  $0 --title "API returns 500 on null input" \\
     --test-command "yarn test tests/integration/api.test.ts" \\
     --test-name "POST /users > should reject null body" \\
     --error "Error: Cannot read property 'email' of null" \\
     --expected "400 Bad Request with validation error" \\
     --actual "500 Internal Server Error" \\
     --cause "Missing null check in request handler" \\
     --files "src/routes/users.ts,src/middleware/validate.ts" \\
     --severity high
EOF
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --title)
            TITLE="$2"
            shift 2
            ;;
        --test-command)
            TEST_COMMAND="$2"
            shift 2
            ;;
        --test-name)
            TEST_NAME="$2"
            shift 2
            ;;
        --error)
            ERROR_OUTPUT="$2"
            shift 2
            ;;
        --expected)
            EXPECTED="$2"
            shift 2
            ;;
        --actual)
            ACTUAL="$2"
            shift 2
            ;;
        --cause)
            SUSPECTED_CAUSE="$2"
            shift 2
            ;;
        --files)
            FILES="$2"
            shift 2
            ;;
        --severity)
            SEVERITY="$2"
            shift 2
            ;;
        --labels)
            LABELS="$2"
            shift 2
            ;;
        --start)
            START_WORK=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required fields
if [ -z "$TITLE" ]; then
    log_error "Missing required: --title"
    usage
fi

if [ -z "$TEST_COMMAND" ]; then
    log_error "Missing required: --test-command"
    usage
fi

if [ -z "$ERROR_OUTPUT" ]; then
    log_error "Missing required: --error"
    usage
fi

# Validate severity
case $SEVERITY in
    critical|high|medium|low)
        # Valid severity levels
        ;;
    *)
        log_error "Invalid severity: $SEVERITY (must be critical, high, medium, or low)"
        exit 1
        ;;
esac

# Map severity to priority label
case $SEVERITY in
    critical)
        PRIORITY_LABEL="priority:critical"
        ;;
    high)
        PRIORITY_LABEL="priority:high"
        ;;
    medium)
        PRIORITY_LABEL="priority:medium"
        ;;
    low)
        PRIORITY_LABEL="priority:low"
        ;;
esac

# Build issue body
log_info "Creating bug issue body..."

# Get current branch and last commit
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
LAST_COMMIT=$(git log -1 --oneline 2>/dev/null || echo "unknown")

ISSUE_BODY="## 🐛 Bug Discovered During Testing

**Test Command:** \`$TEST_COMMAND\`"

# Add test name if provided
if [ -n "$TEST_NAME" ]; then
    ISSUE_BODY="$ISSUE_BODY
**Failing Test:** \`$TEST_NAME\`"
fi

ISSUE_BODY="$ISSUE_BODY

### Error Output
\`\`\`
$ERROR_OUTPUT
\`\`\`

### Analysis"

# Add expected/actual if provided
if [ -n "$EXPECTED" ]; then
    ISSUE_BODY="$ISSUE_BODY
- **Expected:** $EXPECTED"
fi

if [ -n "$ACTUAL" ]; then
    ISSUE_BODY="$ISSUE_BODY
- **Actual:** $ACTUAL"
fi

if [ -n "$SUSPECTED_CAUSE" ]; then
    ISSUE_BODY="$ISSUE_BODY
- **Suspected Cause:** $SUSPECTED_CAUSE"
fi

# Add files if provided
if [ -n "$FILES" ]; then
    ISSUE_BODY="$ISSUE_BODY

### Files Involved"
    IFS=',' read -ra FILES_ARRAY <<< "$FILES"
    for file in "${FILES_ARRAY[@]}"; do
        ISSUE_BODY="$ISSUE_BODY
- \`$(echo "$file" | xargs)\`"
    done
fi

# Add environment info
ISSUE_BODY="$ISSUE_BODY

### Environment
- **Branch:** \`$CURRENT_BRANCH\`
- **Last Commit:** \`$LAST_COMMIT\`
- **Severity:** $SEVERITY

---
**Status:** 🔍 Investigating"

# Build labels
ALL_LABELS="bug,agent:created,agent:discovered,$PRIORITY_LABEL"

# Add user-specified labels
if [ -n "$LABELS" ]; then
    ALL_LABELS="$ALL_LABELS,$LABELS"
fi

# Create the issue
log_info "Creating GitHub issue..."
log_info "Title: Bug: $TITLE"
log_info "Severity: $SEVERITY"
log_info "Labels: $ALL_LABELS"

ISSUE_URL=$(gh issue create \
    --title "Bug: $TITLE" \
    --body "$ISSUE_BODY" \
    --label "$ALL_LABELS" \
    2>&1) || {
    log_error "Failed to create issue"
    echo "$ISSUE_URL"
    exit 1
}

# Extract issue number from URL
ISSUE_NUM=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')

log_success "Created bug issue #$ISSUE_NUM"
echo "$ISSUE_URL"

# Output for agent consumption
echo ""
echo "---"
echo "ISSUE_NUMBER=$ISSUE_NUM"
echo "ISSUE_URL=$ISSUE_URL"
echo "SEVERITY=$SEVERITY"
echo "---"

# Provide next steps
echo ""
log_info "Next steps:"
echo ""
echo "1. Investigate the bug and post findings:"
echo "   gh issue comment $ISSUE_NUM --body \"## 🔍 Investigation Update"
echo ""
echo "   ### Root Cause"
echo "   [explanation]"
echo ""
echo "   ### Proposed Fix"
echo "   [approach]"
echo ""
echo "   ---"
echo "   **Status:** 🔧 Implementing fix\""
echo ""
echo "2. After fixing, post completion update:"
echo "   gh issue comment $ISSUE_NUM --body \"## ✅ Fix Complete"
echo ""
echo "   ### Changes Made"
echo "   - [change]"
echo ""
echo "   ### Verification"
echo "   - [x] Tests pass"
echo ""
echo "   ---"
echo "   **Status:** ✅ Fixed\""
echo ""
echo "3. Close the issue when done:"
echo "   gh issue close $ISSUE_NUM --comment \"Fixed in commit/PR\""

# Optionally start work
if [ "$START_WORK" = true ]; then
    log_info "Starting worktree for issue #$ISSUE_NUM..."
    "$SCRIPT_DIR/start-issue.sh" "$ISSUE_NUM" --no-open
fi
