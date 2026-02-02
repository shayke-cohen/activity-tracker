#!/bin/bash
# install-skill.sh - Install skills from ai-native-engineer
# Usage: ./install-skill.sh <skill-name> | --all | --list | --list-category <cat> | --check-updates

set -e

REPO="shayke-cohen/ai-native-engineer"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/templates/cursor-skills"
DEST_DIR="$HOME/.cursor/skills-cursor"
VERSION_FILE="$DEST_DIR/.ai-native-engineer-version"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check for required tools
check_dependencies() {
  if ! command -v curl &> /dev/null; then
    log_error "curl is required but not installed"
    exit 1
  fi
  if ! command -v jq &> /dev/null; then
    log_warning "jq not found - some features may not work"
  fi
}

# Install a single skill
install_skill() {
  local skill="$1"
  log_info "Installing $skill..."
  
  mkdir -p "$DEST_DIR/$skill"
  
  # Download SKILL.md
  if curl -sL "$BASE_URL/$skill/SKILL.md" -o "$DEST_DIR/$skill/SKILL.md" 2>/dev/null; then
    log_success "Downloaded $skill/SKILL.md"
  else
    log_error "Failed to download $skill/SKILL.md"
    return 1
  fi
  
  # Download skill.json if exists
  if curl -sL "$BASE_URL/$skill/skill.json" -o "$DEST_DIR/$skill/skill.json" 2>/dev/null; then
    log_success "Downloaded $skill/skill.json"
  fi
  
  echo "$skill" >> "$DEST_DIR/.installed-skills"
}

# Install skill with dependencies
install_with_deps() {
  local skill="$1"
  
  # Get dependencies if jq is available
  if command -v jq &> /dev/null; then
    local deps=$(curl -sL "$BASE_URL/$skill/skill.json" 2>/dev/null | jq -r '.dependencies[]?' 2>/dev/null)
    
    # Install dependencies first
    for dep in $deps; do
      if [ -n "$dep" ] && [ ! -d "$DEST_DIR/$dep" ]; then
        log_info "Installing dependency: $dep"
        install_skill "$dep"
      fi
    done
  fi
  
  # Install the skill itself
  install_skill "$skill"
}

# List all available skills
list_skills() {
  log_info "Available skills:"
  echo ""
  
  if command -v jq &> /dev/null; then
    curl -sL "$BASE_URL/skills.json" 2>/dev/null | jq -r '.skills[] | "  \(.name) (\(.category)): \(.description)"'
  else
    curl -sL "$BASE_URL/skills.json" 2>/dev/null | grep -o '"name": "[^"]*"' | cut -d'"' -f4
  fi
}

# List skills by category
list_by_category() {
  local category="$1"
  log_info "Skills in category '$category':"
  echo ""
  
  if command -v jq &> /dev/null; then
    curl -sL "$BASE_URL/skills.json" 2>/dev/null | jq -r ".skills[] | select(.category==\"$category\") | \"  \(.name): \(.description)\""
  else
    log_error "jq is required for category filtering"
    exit 1
  fi
}

# List all categories
list_categories() {
  log_info "Available categories:"
  echo ""
  
  if command -v jq &> /dev/null; then
    curl -sL "$BASE_URL/skills.json" 2>/dev/null | jq -r '.categories | to_entries[] | "  \(.key): \(.value)"'
  else
    log_error "jq is required for listing categories"
    exit 1
  fi
}

# Install all skills
install_all() {
  log_info "Installing all skills..."
  echo ""
  
  mkdir -p "$DEST_DIR"
  
  if command -v jq &> /dev/null; then
    local skills=$(curl -sL "$BASE_URL/skills.json" 2>/dev/null | jq -r '.skills[].name')
    local total=$(echo "$skills" | wc -l | tr -d ' ')
    local count=0
    
    for skill in $skills; do
      count=$((count + 1))
      log_info "[$count/$total] Installing $skill..."
      install_skill "$skill"
    done
    
    # Save version
    curl -sL "$BASE_URL/skills.json" 2>/dev/null | jq -r '.version' > "$VERSION_FILE"
    
    echo ""
    log_success "Installed $total skills to $DEST_DIR"
  else
    log_error "jq is required for installing all skills"
    exit 1
  fi
}

# Check for updates
check_updates() {
  log_info "Checking for updates..."
  echo ""
  
  local local_ver=$(cat "$VERSION_FILE" 2>/dev/null || echo "not installed")
  
  if command -v jq &> /dev/null; then
    local remote_ver=$(curl -sL "$BASE_URL/skills.json" 2>/dev/null | jq -r '.version')
    
    echo "  Local version:  $local_ver"
    echo "  Remote version: $remote_ver"
    echo ""
    
    if [ "$local_ver" = "not installed" ]; then
      log_warning "Skills not installed. Run: $0 --all"
    elif [ "$local_ver" != "$remote_ver" ]; then
      log_warning "Update available! Run: $0 --all"
    else
      log_success "Skills are up to date"
    fi
  else
    log_error "jq is required for checking updates"
    exit 1
  fi
}

# Show usage
show_usage() {
  echo "install-skill.sh - Install skills from ai-native-engineer"
  echo ""
  echo "Usage:"
  echo "  $0 <skill-name>              Install a specific skill (with dependencies)"
  echo "  $0 --all                     Install all skills"
  echo "  $0 --list                    List all available skills"
  echo "  $0 --list-category <cat>     List skills in a category"
  echo "  $0 --categories              List all categories"
  echo "  $0 --check-updates           Check for updates"
  echo "  $0 --help                    Show this help"
  echo ""
  echo "Examples:"
  echo "  $0 test-driven-development   Install TDD skill"
  echo "  $0 --list-category testing   List all testing skills"
  echo "  $0 --all                     Install all 40 skills"
}

# Main
check_dependencies

case "$1" in
  --list)
    list_skills
    ;;
  --list-category)
    if [ -z "$2" ]; then
      log_error "Category name required"
      echo "Usage: $0 --list-category <category>"
      echo ""
      list_categories
      exit 1
    fi
    list_by_category "$2"
    ;;
  --categories)
    list_categories
    ;;
  --all)
    install_all
    ;;
  --check-updates)
    check_updates
    ;;
  --help|-h|"")
    show_usage
    ;;
  *)
    install_with_deps "$1"
    ;;
esac
