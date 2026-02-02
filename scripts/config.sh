#!/bin/bash
# Shared configuration for all scripts

# Repository settings
export REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export WORKTREES_DIR="$REPO_ROOT/.worktrees"

# Branch prefixes
export FEATURE_PREFIX="feature"
export BUGFIX_PREFIX="bugfix"
export HOTFIX_PREFIX="hotfix"
export TASK_PREFIX="task"

# Default branch
export DEFAULT_BRANCH="main"

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}
