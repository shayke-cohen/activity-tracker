#!/bin/bash
# Main setup script - runs all setup steps

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "🚀 Setting up AI-Native Repository"
echo "=================================="

# Step 1: Verify prerequisites
echo ""
echo "Step 1: Verifying prerequisites..."
"$SCRIPT_DIR/verify-setup.sh"

# Step 2: Setup GitHub labels (if in a git repo with origin)
if git remote get-url origin &> /dev/null 2>&1; then
    echo ""
    echo "Step 2: Setting up GitHub labels..."
    "$SCRIPT_DIR/setup-labels.sh"
else
    echo ""
    log_warning "Step 2: Skipping GitHub labels (no origin remote)"
fi

# Step 3: Setup MCP configuration
echo ""
echo "Step 3: Setting up MCP servers..."
"$SCRIPT_DIR/setup-mcp.sh"

# Step 4: Create .worktrees directory
echo ""
echo "Step 4: Creating worktrees directory..."
mkdir -p "$WORKTREES_DIR"

# Add to .gitignore if not already there
if ! grep -q "^\.worktrees/" "$REPO_ROOT/.gitignore" 2>/dev/null; then
    echo ".worktrees/" >> "$REPO_ROOT/.gitignore"
    log_success "Added .worktrees/ to .gitignore"
else
    log_success ".worktrees/ already in .gitignore"
fi

# Step 5: Copy skills to .cursor/skills-cursor
echo ""
echo "Step 5: Setting up Cursor skills..."
SKILLS_SOURCE="$SCRIPT_DIR/../cursor-skills"
SKILLS_DEST="$REPO_ROOT/.cursor/skills-cursor"

if [ -d "$SKILLS_SOURCE" ]; then
    mkdir -p "$SKILLS_DEST"
    
    # Copy all skill directories
    for skill_dir in "$SKILLS_SOURCE"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            mkdir -p "$SKILLS_DEST/$skill_name"
            cp "$skill_dir"* "$SKILLS_DEST/$skill_name/" 2>/dev/null || true
            log_success "Copied skill: $skill_name"
        fi
    done
    
    log_success "Skills setup complete ($(ls -1 "$SKILLS_DEST" | wc -l | tr -d ' ') skills)"
else
    log_warning "Skills source not found at $SKILLS_SOURCE"
fi

# Done
echo ""
echo "=================================="
log_success "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Set environment variables (copy .env.example to .env)"
echo "  2. Restart Cursor to load MCP servers"
echo "  3. Create your first issue: gh issue create"
echo "  4. Start working: ./scripts/start-issue.sh <number>"
