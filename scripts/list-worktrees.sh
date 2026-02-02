#!/bin/bash
# List all active worktrees

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "Active Worktrees"
echo "================"
echo ""

# List git worktrees
WORKTREES=$(git worktree list --porcelain 2>/dev/null)

if [ -z "$WORKTREES" ]; then
    log_info "No worktrees found"
    exit 0
fi

# Parse and display worktrees
MAIN_WORKTREE=""
ISSUE_WORKTREES=()

while IFS= read -r line; do
    if [[ "$line" == "worktree "* ]]; then
        CURRENT_PATH="${line#worktree }"
    elif [[ "$line" == "branch "* ]]; then
        CURRENT_BRANCH="${line#branch refs/heads/}"
        
        if [[ "$CURRENT_PATH" == "$REPO_ROOT" ]]; then
            MAIN_WORKTREE="$CURRENT_PATH"
        elif [[ "$CURRENT_PATH" == "$WORKTREES_DIR"* ]]; then
            # Extract issue number from path
            ISSUE_DIR=$(basename "$CURRENT_PATH")
            ISSUE_NUM="${ISSUE_DIR#issue-}"
            
            # Try to get issue title
            ISSUE_TITLE=$(gh issue view "$ISSUE_NUM" --json title --jq '.title' 2>/dev/null || echo "Unknown")
            
            ISSUE_WORKTREES+=("$ISSUE_NUM|$CURRENT_BRANCH|$ISSUE_TITLE|$CURRENT_PATH")
        fi
    fi
done <<< "$WORKTREES"

# Display main worktree
if [ -n "$MAIN_WORKTREE" ]; then
    echo "📁 Main Repository"
    echo "   Path: $MAIN_WORKTREE"
    echo ""
fi

# Display issue worktrees
if [ ${#ISSUE_WORKTREES[@]} -eq 0 ]; then
    log_info "No issue worktrees active"
else
    echo "🔧 Issue Worktrees"
    echo ""
    
    for worktree in "${ISSUE_WORKTREES[@]}"; do
        IFS='|' read -r ISSUE_NUM BRANCH TITLE PATH <<< "$worktree"
        echo "   Issue #$ISSUE_NUM: $TITLE"
        echo "   Branch: $BRANCH"
        echo "   Path: $PATH"
        echo ""
    done
fi

# Show commands
echo "Commands:"
echo "  Start new:  ./scripts/start-issue.sh <number>"
echo "  Finish:     ./scripts/finish-issue.sh <number>"
echo "  Remove:     git worktree remove <path>"
