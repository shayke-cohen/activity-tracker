#!/bin/bash
# Push changes and create PR for an issue

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Parse arguments
ISSUE_NUM=""
CLEANUP=false
CHECK_CI=false
CI_RETRIES=3

while [[ $# -gt 0 ]]; do
    case $1 in
        --cleanup)
            CLEANUP=true
            shift
            ;;
        --check-ci)
            CHECK_CI=true
            shift
            ;;
        --ci-retries)
            CI_RETRIES="$2"
            shift 2
            ;;
        *)
            ISSUE_NUM="$1"
            shift
            ;;
    esac
done

# Validate issue number
if [ -z "$ISSUE_NUM" ]; then
    echo "Usage: $0 <issue-number> [options]"
    echo ""
    echo "Options:"
    echo "  --cleanup       Remove worktree after PR is created"
    echo "  --check-ci      Wait for CI to pass (with retry loop for agent fixes)"
    echo "  --ci-retries <n> Max CI retry attempts (default: 3, requires --check-ci)"
    echo ""
    echo "Examples:"
    echo "  $0 23              # Create PR for issue 23"
    echo "  $0 23 --cleanup    # Create PR and remove worktree"
    echo "  $0 23 --check-ci   # Create PR and verify CI passes"
    exit 1
fi

WORKTREE_PATH="$WORKTREES_DIR/issue-$ISSUE_NUM"

# Check if we're in the worktree or main repo
CURRENT_DIR=$(pwd)
if [[ "$CURRENT_DIR" == "$WORKTREE_PATH"* ]]; then
    cd "$WORKTREE_PATH"
elif [ -d "$WORKTREE_PATH" ]; then
    cd "$WORKTREE_PATH"
else
    log_error "Worktree not found: $WORKTREE_PATH"
    echo "Run ./scripts/start-issue.sh $ISSUE_NUM first"
    exit 1
fi

# Get current branch
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
log_info "Branch: $BRANCH_NAME"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    log_warning "You have uncommitted changes"
    git status --short
    echo ""
    read -p "Commit them now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Commit message: " COMMIT_MSG
        git add .
        git commit -m "$COMMIT_MSG"
    else
        log_error "Please commit or stash changes first"
        exit 1
    fi
fi

# Get issue details for PR
log_info "Fetching issue #$ISSUE_NUM..."
ISSUE_JSON=$(gh issue view "$ISSUE_NUM" --json title,body 2>/dev/null) || {
    log_error "Failed to fetch issue #$ISSUE_NUM"
    exit 1
}

ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')

# Push branch
log_info "Pushing branch..."
git push -u origin "$BRANCH_NAME"

# Check if PR already exists
EXISTING_PR=$(gh pr list --head "$BRANCH_NAME" --json number --jq '.[0].number' 2>/dev/null || echo "")

if [ -n "$EXISTING_PR" ] && [ "$EXISTING_PR" != "null" ]; then
    log_warning "PR #$EXISTING_PR already exists for this branch"
    gh pr view "$EXISTING_PR" --web 2>/dev/null || true
else
    # Create PR
    log_info "Creating pull request..."
    PR_BODY=$(cat << EOF
## Summary
Implements #$ISSUE_NUM - $ISSUE_TITLE

## Changes
<!-- Describe your changes -->

## Testing
- [ ] All tests pass
- [ ] Linting passes
- [ ] Manual testing done

## Checklist
- [ ] Code follows project style
- [ ] Tests added/updated
- [ ] Documentation updated (if needed)

## Knowledge Update
- [ ] No lessons learned
- [ ] Added to knowledge/LESSONS_LEARNED.md

---
Closes #$ISSUE_NUM
EOF
    )

    gh pr create \
        --title "feat: $ISSUE_TITLE (#$ISSUE_NUM)" \
        --body "$PR_BODY" \
        --head "$BRANCH_NAME" \
        --base "$DEFAULT_BRANCH"

    # Update issue
    gh issue edit "$ISSUE_NUM" --add-label "status:review" 2>/dev/null || true
    gh issue comment "$ISSUE_NUM" --body "🔀 **Pull Request Created**

PR is ready for review.

Please review when ready." 2>/dev/null || true
fi

log_success "PR created/updated!"

# Check CI if requested
if [ "$CHECK_CI" = true ]; then
    log_info "Checking CI status..."
    if "$SCRIPT_DIR/check-ci.sh" --retry "$CI_RETRIES"; then
        log_success "CI passed!"
    else
        log_error "CI failed after $CI_RETRIES attempt(s)"
        log_info "Review .ci-failure.log for details"
        exit 1
    fi
fi

# Cleanup if requested
if [ "$CLEANUP" = true ]; then
    log_info "Cleaning up worktree..."
    cd "$REPO_ROOT"
    git worktree remove "$WORKTREE_PATH" --force 2>/dev/null || {
        log_warning "Could not remove worktree automatically"
        echo "Remove manually: rm -rf $WORKTREE_PATH"
    }
    log_success "Worktree removed"
fi

log_success "Done!"
