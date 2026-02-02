#!/bin/bash
# Create worktree and start working on an issue

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Parse arguments
ISSUE_NUM=""
OPEN_MODE="terminal"  # terminal, gui, or none

while [[ $# -gt 0 ]]; do
    case $1 in
        --gui)
            OPEN_MODE="gui"
            shift
            ;;
        --no-open)
            OPEN_MODE="none"
            shift
            ;;
        *)
            ISSUE_NUM="$1"
            shift
            ;;
    esac
done

# Validate issue number
if [ -z "$ISSUE_NUM" ]; then
    echo "Usage: $0 <issue-number> [--gui|--no-open]"
    echo ""
    echo "Options:"
    echo "  --gui      Open Cursor GUI instead of terminal"
    echo "  --no-open  Create worktree only, don't open anything"
    echo ""
    echo "Examples:"
    echo "  $0 23           # Start issue 23 in terminal"
    echo "  $0 23 --gui     # Start issue 23 in Cursor GUI"
    echo "  $0 23 --no-open # Just create the worktree"
    exit 1
fi

# Fetch issue details
log_info "Fetching issue #$ISSUE_NUM..."
ISSUE_JSON=$(gh issue view "$ISSUE_NUM" --json title,body,labels,state 2>/dev/null) || {
    log_error "Failed to fetch issue #$ISSUE_NUM"
    exit 1
}

ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')
ISSUE_BODY=$(echo "$ISSUE_JSON" | jq -r '.body // "No description provided"')
ISSUE_LABELS=$(echo "$ISSUE_JSON" | jq -r '.labels[].name' | tr '\n' ', ' | sed 's/,$//')
ISSUE_STATE=$(echo "$ISSUE_JSON" | jq -r '.state')

if [ "$ISSUE_STATE" == "CLOSED" ]; then
    log_warning "Issue #$ISSUE_NUM is closed"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Create branch name from issue title
BRANCH_SLUG=$(echo "$ISSUE_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-40)
BRANCH_NAME="feature/issue-${ISSUE_NUM}-${BRANCH_SLUG}"
WORKTREE_PATH="$WORKTREES_DIR/issue-$ISSUE_NUM"

log_info "Issue: $ISSUE_TITLE"
log_info "Branch: $BRANCH_NAME"
log_info "Worktree: $WORKTREE_PATH"

# Check if worktree already exists
if [ -d "$WORKTREE_PATH" ]; then
    log_warning "Worktree already exists: $WORKTREE_PATH"
    read -p "Remove and recreate? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git worktree remove "$WORKTREE_PATH" --force 2>/dev/null || rm -rf "$WORKTREE_PATH"
    else
        exit 0
    fi
fi

# Create worktree directory
mkdir -p "$WORKTREES_DIR"

# Fetch latest from origin
log_info "Fetching latest from origin..."
git fetch origin "$DEFAULT_BRANCH" 2>/dev/null || true

# Create worktree with new branch
log_info "Creating worktree..."
git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "origin/$DEFAULT_BRANCH" 2>/dev/null || {
    # Branch might already exist
    git worktree add "$WORKTREE_PATH" "$BRANCH_NAME" 2>/dev/null || {
        log_error "Failed to create worktree"
        exit 1
    }
}

# Create task file
TASK_FILE="$WORKTREE_PATH/.cursor-task.md"
log_info "Creating task file..."

cat > "$TASK_FILE" << EOF
# Task: Issue #$ISSUE_NUM - $ISSUE_TITLE

## Labels
$ISSUE_LABELS

## Issue Description
$ISSUE_BODY

---

## Your Instructions

Follow these steps in order. Do NOT skip any step.

### Phase 0: Planning (REQUIRED BEFORE IMPLEMENTATION)

1. **Read the documentation**
   - Read \`AGENTS.md\` for project guidelines
   - Check \`knowledge/KNOWN_ISSUES.md\` for related issues
   - Review \`ARCHITECTURE.md\` for system context

2. **Create implementation plan**
   - List files to create/modify
   - Outline your approach
   - Identify potential risks

3. **Post plan to GitHub issue**
   \`\`\`bash
   gh issue comment $ISSUE_NUM --body "## 📋 Implementation Plan

   ### Approach
   [Your approach]

   ### Files to Modify
   - \\\`path/to/file1\\\`
   - \\\`path/to/file2\\\`

   ### Testing Strategy
   - [ ] Test 1
   - [ ] Test 2

   ---
   **Waiting for approval.** Reply with 'approved' to proceed."
   \`\`\`

4. **WAIT for approval before proceeding**

### Phase 1: Implementation (after approval)

1. **Post starting update**
   \`\`\`bash
   gh issue edit $ISSUE_NUM --add-label "status:in-progress"
   gh issue comment $ISSUE_NUM --body "🚀 **Starting implementation**"
   \`\`\`

2. **Implement the feature**
   - Follow the plan
   - Write clean, tested code
   - Commit frequently

3. **Run tests**
   \`\`\`bash
   yarn lint
   yarn typecheck
   yarn test
   \`\`\`

### Phase 2: Complete

1. **Post completion update**
   \`\`\`bash
   gh issue comment $ISSUE_NUM --body "✅ **Implementation complete**

   ### Changes Made
   - [List changes]

   ### Testing Done
   - [x] All tests pass

   Creating PR now..."
   \`\`\`

2. **Create PR**
   \`\`\`bash
   cd $WORKTREE_PATH
   ../scripts/finish-issue.sh $ISSUE_NUM
   \`\`\`

---

## Quick Commands

\`\`\`bash
# Post progress update
gh issue comment $ISSUE_NUM --body "🔄 **Progress Update**
- ✅ Completed: [what]
- 🔄 In progress: [what]
- ⏳ Remaining: [what]"

# If blocked
gh issue edit $ISSUE_NUM --add-label "status:blocked"
gh issue comment $ISSUE_NUM --body "🚫 **Blocked**
**Reason**: [why]
**Need**: [what you need]"

# Run tests
yarn lint && yarn typecheck && yarn test
\`\`\`
EOF

log_success "Task file created: $TASK_FILE"

# Update GitHub issue
log_info "Updating GitHub issue..."
gh issue edit "$ISSUE_NUM" --add-label "status:in-progress" --add-label "agent:assigned" 2>/dev/null || true

# Open based on mode
case $OPEN_MODE in
    terminal)
        log_success "Worktree ready!"
        echo ""
        echo "To start working:"
        echo "  cd $WORKTREE_PATH"
        echo ""
        echo "Read .cursor-task.md for instructions"
        ;;
    gui)
        log_info "Opening Cursor GUI..."
        cursor "$WORKTREE_PATH" 2>/dev/null || code "$WORKTREE_PATH" 2>/dev/null || {
            log_warning "Could not open editor. Open manually: $WORKTREE_PATH"
        }
        ;;
    none)
        log_success "Worktree created at: $WORKTREE_PATH"
        ;;
esac

log_success "Done! Issue #$ISSUE_NUM is ready for work."
