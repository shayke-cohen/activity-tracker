#!/bin/bash
# Create a GitHub issue from an agent-initiated ad-hoc task
#
# This script is used when an agent receives a task via conversation
# (not from an existing issue) and needs to create an issue before
# starting work.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Default values
TITLE=""
BODY=""
TIER="small"
LABELS=""
ORIGINAL_REQUEST=""
UNDERSTANDING=""
SCOPE_FILES=""
RISK="low"
PLAN=""
START_WORK=false

# Usage
usage() {
    cat << EOF
Usage: $0 [options]

Create a GitHub issue for an agent-initiated task.

Required:
  --title <title>          Issue title
  --request <text>         Original user request (quoted)
  --understanding <text>   Agent's interpretation of the request

Optional:
  --tier <tier>            Task tier: trivial, small, medium, large (default: small)
  --labels <labels>        Additional labels (comma-separated)
  --files <files>          Files in scope (comma-separated)
  --risk <level>           Risk level: low, medium, high (default: low)
  --plan <text>            Implementation plan (for medium/large tiers)
  --start                  Immediately start work (create worktree)

Examples:
  # Small task - create issue and proceed
  $0 --title "Fix typo in README" \\
     --request "fix the typo in the readme" \\
     --understanding "Fix spelling error in README.md" \\
     --tier small

  # Medium task - create issue and wait for approval
  $0 --title "Refactor UserService" \\
     --request "clean up the user service" \\
     --understanding "Refactor UserService for better separation of concerns" \\
     --tier medium \\
     --files "src/services/UserService.ts,tests/UserService.test.ts" \\
     --risk medium \\
     --plan "1. Extract validation logic\\n2. Add unit tests\\n3. Update callers"
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
        --request)
            ORIGINAL_REQUEST="$2"
            shift 2
            ;;
        --understanding)
            UNDERSTANDING="$2"
            shift 2
            ;;
        --tier)
            TIER="$2"
            shift 2
            ;;
        --labels)
            LABELS="$2"
            shift 2
            ;;
        --files)
            SCOPE_FILES="$2"
            shift 2
            ;;
        --risk)
            RISK="$2"
            shift 2
            ;;
        --plan)
            PLAN="$2"
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

if [ -z "$ORIGINAL_REQUEST" ]; then
    log_error "Missing required: --request"
    usage
fi

if [ -z "$UNDERSTANDING" ]; then
    log_error "Missing required: --understanding"
    usage
fi

# Validate tier
case $TIER in
    trivial)
        log_warning "Trivial tasks typically don't need issues."
        log_info "Consider just making the change with a descriptive commit."
        read -p "Create issue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
        ;;
    small|medium|large)
        # Valid tiers
        ;;
    *)
        log_error "Invalid tier: $TIER (must be trivial, small, medium, or large)"
        exit 1
        ;;
esac

# Validate risk
case $RISK in
    low|medium|high)
        # Valid risk levels
        ;;
    *)
        log_error "Invalid risk: $RISK (must be low, medium, or high)"
        exit 1
        ;;
esac

# Build issue body
log_info "Creating issue body..."

ISSUE_BODY="## Original Request
> $ORIGINAL_REQUEST

## Agent Understanding
$UNDERSTANDING

## Proposed Scope
- **Risk:** $RISK
- **Tier:** $TIER"

# Add files if provided
if [ -n "$SCOPE_FILES" ]; then
    ISSUE_BODY="$ISSUE_BODY
- **Files:**"
    IFS=',' read -ra FILES_ARRAY <<< "$SCOPE_FILES"
    for file in "${FILES_ARRAY[@]}"; do
        ISSUE_BODY="$ISSUE_BODY
  - \`$(echo "$file" | xargs)\`"
    done
fi

# Add plan for medium/large tiers
if [[ "$TIER" == "medium" || "$TIER" == "large" ]]; then
    if [ -n "$PLAN" ]; then
        # Convert \n to actual newlines
        FORMATTED_PLAN=$(echo -e "$PLAN")
        ISSUE_BODY="$ISSUE_BODY

## Implementation Plan
$FORMATTED_PLAN"
    else
        ISSUE_BODY="$ISSUE_BODY

## Implementation Plan
_To be detailed after scope confirmation._"
    fi
fi

# Add status footer
if [[ "$TIER" == "medium" || "$TIER" == "large" ]]; then
    ISSUE_BODY="$ISSUE_BODY

---
**Status:** ⏳ Awaiting approval

_Reply with \`approved\` to proceed, or edit this issue to correct my understanding._"
else
    ISSUE_BODY="$ISSUE_BODY

---
**Status:** 🚀 In Progress

_This is a small task. Work has begun._"
fi

# Build labels
ALL_LABELS="agent:created,tier:$TIER"

# Add needs-approval for medium/large
if [[ "$TIER" == "medium" || "$TIER" == "large" ]]; then
    ALL_LABELS="$ALL_LABELS,agent:needs-approval"
fi

# Add user-specified labels
if [ -n "$LABELS" ]; then
    ALL_LABELS="$ALL_LABELS,$LABELS"
fi

# Create the issue
log_info "Creating GitHub issue..."
log_info "Title: $TITLE"
log_info "Tier: $TIER"
log_info "Labels: $ALL_LABELS"

ISSUE_URL=$(gh issue create \
    --title "$TITLE" \
    --body "$ISSUE_BODY" \
    --label "$ALL_LABELS" \
    2>&1) || {
    log_error "Failed to create issue"
    echo "$ISSUE_URL"
    exit 1
}

# Extract issue number from URL
ISSUE_NUM=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')

log_success "Created issue #$ISSUE_NUM"
echo "$ISSUE_URL"

# Output for agent consumption
echo ""
echo "---"
echo "ISSUE_NUMBER=$ISSUE_NUM"
echo "ISSUE_URL=$ISSUE_URL"
echo "TIER=$TIER"
echo "NEEDS_APPROVAL=$([[ "$TIER" == "medium" || "$TIER" == "large" ]] && echo "true" || echo "false")"
echo "---"

# Provide next steps
echo ""
if [[ "$TIER" == "medium" || "$TIER" == "large" ]]; then
    log_warning "This task requires approval before proceeding."
    echo ""
    echo "Post this confirmation message to the user:"
    echo ""
    cat << EOF
## ✅ Issue Created

I've created **issue #$ISSUE_NUM** based on your request.

**My understanding:** $UNDERSTANDING

**Scope:** ${SCOPE_FILES:-"To be determined"}

**Risk assessment:** $RISK

**[View Issue]($ISSUE_URL)**

Please review and reply with:
- \`approved\` - I'll proceed with implementation
- \`modify\` - I'll wait for your corrections
- (or edit the issue directly)
EOF
else
    log_success "Small task - proceeding with work."
    
    if [ "$START_WORK" = true ]; then
        log_info "Starting worktree for issue #$ISSUE_NUM..."
        "$SCRIPT_DIR/start-issue.sh" "$ISSUE_NUM" --no-open
    else
        echo ""
        echo "To start work:"
        echo "  ./scripts/start-issue.sh $ISSUE_NUM"
    fi
fi
