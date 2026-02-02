#!/bin/bash
# install-templates.sh - Install templates from ai-native-engineer
# Usage: ./install-templates.sh --all | --list | --list-category <cat> | --check-updates | <template>

set -e

REPO="shayke-cohen/ai-native-engineer"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"
TEMPLATES_JSON="$BASE_URL/templates/templates.json"
VERSION_FILE=".ai-native-engineer-templates-version"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

log_skip() {
  echo -e "${CYAN}[SKIP]${NC} $1"
}

# Check for required tools
check_dependencies() {
  if ! command -v curl &> /dev/null; then
    log_error "curl is required but not installed"
    exit 1
  fi
  if ! command -v jq &> /dev/null; then
    log_warning "jq not found - some features may not work"
    log_warning "Install with: brew install jq (macOS) or apt install jq (Linux)"
  fi
}

# Fetch templates.json
fetch_manifest() {
  curl -sL "$TEMPLATES_JSON" 2>/dev/null
}

# List all available templates
list_templates() {
  log_info "Available templates:"
  echo ""
  
  if command -v jq &> /dev/null; then
    fetch_manifest | jq -r '.templates[] | "  \(.dest) (\(.category)): \(.description)"'
  else
    log_error "jq is required for listing templates"
    exit 1
  fi
}

# List templates by category
list_by_category() {
  local category="$1"
  log_info "Templates in category '$category':"
  echo ""
  
  if command -v jq &> /dev/null; then
    fetch_manifest | jq -r ".templates[] | select(.category==\"$category\") | \"  \(.dest): \(.description)\""
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
    fetch_manifest | jq -r '.categories | to_entries[] | "  \(.key): \(.value)"'
  else
    log_error "jq is required for listing categories"
    exit 1
  fi
}

# Download a single template
download_template() {
  local source="$1"
  local dest="$2"
  local action="$3"
  
  # Create parent directory if needed
  local dir=$(dirname "$dest")
  if [ "$dir" != "." ]; then
    mkdir -p "$dir"
  fi
  
  # Check action type
  case "$action" in
    "create-if-missing")
      if [ -f "$dest" ]; then
        log_skip "$dest (already exists)"
        return 0
      fi
      ;;
    "overwrite")
      # Will overwrite
      ;;
    "merge")
      if [ -f "$dest" ]; then
        log_warning "$dest requires merge - downloading as $dest.new"
        dest="$dest.new"
      fi
      ;;
  esac
  
  # Download
  if curl -sL "$BASE_URL/$source" -o "$dest" 2>/dev/null; then
    if [ "$action" = "merge" ] && [[ "$dest" == *.new ]]; then
      log_warning "Downloaded $dest - manual merge required"
      log_warning "  Compare with ${dest%.new} and merge sections"
    else
      log_success "Installed $dest"
    fi
    return 0
  else
    log_error "Failed to download $source"
    return 1
  fi
}

# Install a single template by dest path
install_template() {
  local template_dest="$1"
  
  if ! command -v jq &> /dev/null; then
    log_error "jq is required for installing templates"
    exit 1
  fi
  
  local manifest=$(fetch_manifest)
  local template=$(echo "$manifest" | jq -r ".templates[] | select(.dest==\"$template_dest\")")
  
  if [ -z "$template" ] || [ "$template" = "null" ]; then
    log_error "Template not found: $template_dest"
    log_info "Use --list to see available templates"
    exit 1
  fi
  
  local source=$(echo "$template" | jq -r '.source')
  local dest=$(echo "$template" | jq -r '.dest')
  local action=$(echo "$template" | jq -r '.action')
  
  download_template "$source" "$dest" "$action"
}

# Install all templates
install_all() {
  log_info "Installing all templates..."
  echo ""
  
  if ! command -v jq &> /dev/null; then
    log_error "jq is required for installing all templates"
    exit 1
  fi
  
  local manifest=$(fetch_manifest)
  local templates=$(echo "$manifest" | jq -c '.templates[]')
  local total=$(echo "$manifest" | jq '.templates | length')
  local count=0
  local created=0
  local updated=0
  local skipped=0
  local merged=0
  
  while IFS= read -r template; do
    count=$((count + 1))
    local source=$(echo "$template" | jq -r '.source')
    local dest=$(echo "$template" | jq -r '.dest')
    local action=$(echo "$template" | jq -r '.action')
    
    echo -e "${BLUE}[$count/$total]${NC} Processing $dest..."
    
    case "$action" in
      "create-if-missing")
        if [ -f "$dest" ]; then
          log_skip "$dest (already exists)"
          skipped=$((skipped + 1))
        else
          if download_template "$source" "$dest" "$action"; then
            created=$((created + 1))
          fi
        fi
        ;;
      "overwrite")
        if download_template "$source" "$dest" "$action"; then
          updated=$((updated + 1))
        fi
        ;;
      "merge")
        if [ -f "$dest" ]; then
          download_template "$source" "$dest" "$action"
          merged=$((merged + 1))
        else
          if download_template "$source" "$dest" "create-if-missing"; then
            created=$((created + 1))
          fi
        fi
        ;;
    esac
  done <<< "$templates"
  
  # Save version
  echo "$manifest" | jq -r '.version' > "$VERSION_FILE"
  
  echo ""
  log_success "Installation complete!"
  echo "  Created: $created"
  echo "  Updated: $updated"
  echo "  Skipped: $skipped"
  echo "  Needs merge: $merged"
  
  if [ $merged -gt 0 ]; then
    echo ""
    log_warning "Some files need manual merge. Look for .new files and merge them."
  fi
  
  echo ""
  log_info "Don't forget to run: chmod +x scripts/*.sh"
}

# Check for updates
check_updates() {
  log_info "Checking for template updates..."
  echo ""
  
  local local_ver=$(cat "$VERSION_FILE" 2>/dev/null || echo "not installed")
  
  if command -v jq &> /dev/null; then
    local remote_ver=$(fetch_manifest | jq -r '.version')
    
    echo "  Local version:  $local_ver"
    echo "  Remote version: $remote_ver"
    echo ""
    
    if [ "$local_ver" = "not installed" ]; then
      log_warning "Templates not installed. Run: $0 --all"
    elif [ "$local_ver" != "$remote_ver" ]; then
      log_warning "Update available! Run: $0 --all"
    else
      log_success "Templates are up to date"
    fi
  else
    log_error "jq is required for checking updates"
    exit 1
  fi
}

# Show usage
show_usage() {
  echo "install-templates.sh - Install templates from ai-native-engineer"
  echo ""
  echo "Usage:"
  echo "  $0 --all                     Install all templates"
  echo "  $0 --list                    List all available templates"
  echo "  $0 --list-category <cat>     List templates in a category"
  echo "  $0 --categories              List all categories"
  echo "  $0 --check-updates           Check for updates"
  echo "  $0 <dest-path>               Install specific template by dest path"
  echo "  $0 --help                    Show this help"
  echo ""
  echo "Examples:"
  echo "  $0 --all                     Install all templates"
  echo "  $0 AGENTS.md                 Install AGENTS.md template"
  echo "  $0 --list-category rules     List all cursor rules"
  echo ""
  echo "Actions:"
  echo "  create-if-missing  Only create if file doesn't exist"
  echo "  overwrite          Replace file entirely"
  echo "  merge              Download as .new for manual merge"
}

# Main
check_dependencies

case "$1" in
  --list)
    list_templates
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
    install_template "$1"
    ;;
esac
