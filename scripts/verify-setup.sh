#!/bin/bash
# Verify all prerequisites are met

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "Checking prerequisites..."
echo ""

ERRORS=0

# Check gh CLI
if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) not installed"
    echo "   Install: https://cli.github.com/"
    ERRORS=$((ERRORS + 1))
else
    log_success "GitHub CLI installed"
fi

# Check gh auth
if ! gh auth status &> /dev/null 2>&1; then
    log_error "GitHub CLI not authenticated"
    echo "   Run: gh auth login"
    ERRORS=$((ERRORS + 1))
else
    log_success "GitHub CLI authenticated"
fi

# Check git
if ! command -v git &> /dev/null; then
    log_error "Git not installed"
    ERRORS=$((ERRORS + 1))
else
    log_success "Git installed"
fi

# Check git user.name
if ! git config user.name &> /dev/null; then
    log_error "Git user.name not configured"
    echo "   Run: git config --global user.name 'Your Name'"
    ERRORS=$((ERRORS + 1))
else
    log_success "Git user.name configured: $(git config user.name)"
fi

# Check git user.email
if ! git config user.email &> /dev/null; then
    log_error "Git user.email not configured"
    echo "   Run: git config --global user.email 'you@example.com'"
    ERRORS=$((ERRORS + 1))
else
    log_success "Git user.email configured: $(git config user.email)"
fi

# Check we're in a git repo
if ! git rev-parse --git-dir &> /dev/null 2>&1; then
    log_warning "Not in a git repository (OK for new projects)"
else
    log_success "Git repository detected"
    
    # Check remote
    if ! git remote get-url origin &> /dev/null 2>&1; then
        log_warning "No 'origin' remote configured"
    else
        log_success "Origin remote: $(git remote get-url origin)"
    fi
fi

echo ""
if [ $ERRORS -gt 0 ]; then
    log_error "$ERRORS prerequisite(s) not met"
    exit 1
else
    log_success "All prerequisites met!"
    echo ""
    if gh auth status &> /dev/null 2>&1; then
        echo "   gh user: $(gh api user -q .login 2>/dev/null || echo 'unknown')"
    fi
    echo "   git user: $(git config user.name)"
fi
