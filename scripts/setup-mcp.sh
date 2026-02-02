#!/bin/bash
# Setup MCP configuration

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "Setting up MCP servers..."

MCP_DIR="$REPO_ROOT/.cursor"
MCP_FILE="$MCP_DIR/mcp.json"
MCP_EXAMPLE="$MCP_DIR/mcp.json.example"

# Check if mcp.json exists
if [ -f "$MCP_FILE" ]; then
    log_warning ".cursor/mcp.json already exists"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipped MCP setup."
        exit 0
    fi
fi

# Check if example exists
if [ ! -f "$MCP_EXAMPLE" ]; then
    log_error "mcp.json.example not found"
    exit 1
fi

# Copy example
cp "$MCP_EXAMPLE" "$MCP_FILE"
log_success "Created .cursor/mcp.json"

echo ""
echo "Required environment variables:"
echo "  GITHUB_TOKEN - For GitHub MCP server"
echo ""
echo "Set these in your shell or .env file:"
echo "  export GITHUB_TOKEN='ghp_...'"
echo ""
echo "Then restart Cursor to load MCP servers."
