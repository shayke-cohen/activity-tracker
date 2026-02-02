#!/bin/bash
# Check CI status and capture failure logs for agent visibility
#
# Usage:
#   ./scripts/check-ci.sh              # Check CI once
#   ./scripts/check-ci.sh --retry 3    # Retry up to 3 times (wait for new runs)
#   ./scripts/check-ci.sh --timeout 600 # Max 10 min wait per run

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Default values
MAX_RETRIES=1
TIMEOUT=900  # 15 minutes default
FAILURE_LOG="$REPO_ROOT/.ci-failure.log"
POLL_INTERVAL=30  # seconds between checking for new runs

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --retry)
            MAX_RETRIES="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Check CI status on the current branch and capture failure logs."
            echo ""
            echo "Options:"
            echo "  --retry <n>     Max retry attempts (default: 1, no retry)"
            echo "  --timeout <s>   Max seconds to wait per CI run (default: 900)"
            echo "  --help          Show this help message"
            echo ""
            echo "Output:"
            echo "  On failure, writes details to .ci-failure.log"
            echo "  Exit code 0 on success, 1 on failure"
            echo ""
            echo "Examples:"
            echo "  $0                  # Check CI once"
            echo "  $0 --retry 3        # Allow 3 attempts for agent to fix"
            echo "  $0 --timeout 1200   # Wait up to 20 minutes per run"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check prerequisites
if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) is required but not installed"
    exit 1
fi

if ! gh auth status &> /dev/null 2>&1; then
    log_error "GitHub CLI not authenticated. Run: gh auth login"
    exit 1
fi

# Get current branch
BRANCH=$(git branch --show-current)
if [ -z "$BRANCH" ]; then
    log_error "Could not determine current branch"
    exit 1
fi

log_info "Branch: $BRANCH"

# Function to get the latest run ID for the current branch
get_latest_run_id() {
    gh run list --branch "$BRANCH" --limit 1 --json databaseId,status,conclusion,headSha \
        --jq '.[0] | "\(.databaseId)|\(.status)|\(.conclusion // "")|\(.headSha)"' 2>/dev/null || echo ""
}

# Function to wait for a CI run to complete
wait_for_run() {
    local run_id="$1"
    local start_time=$(date +%s)
    
    log_info "Watching CI run #$run_id..."
    
    # Use gh run watch with timeout
    if timeout "$TIMEOUT" gh run watch "$run_id" --exit-status 2>/dev/null; then
        return 0
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            log_error "CI run timed out after ${TIMEOUT}s"
        fi
        return 1
    fi
}

# Function to capture failure logs
capture_failure_logs() {
    local run_id="$1"
    local attempt="$2"
    
    log_info "Capturing failure logs..."
    
    # Get run details
    local run_info=$(gh run view "$run_id" --json conclusion,status,headSha,createdAt,url \
        --jq '"\(.conclusion)|\(.status)|\(.headSha)|\(.createdAt)|\(.url)"' 2>/dev/null || echo "")
    
    local conclusion=$(echo "$run_info" | cut -d'|' -f1)
    local status=$(echo "$run_info" | cut -d'|' -f2)
    local commit=$(echo "$run_info" | cut -d'|' -f3)
    local created_at=$(echo "$run_info" | cut -d'|' -f4)
    local run_url=$(echo "$run_info" | cut -d'|' -f5)
    
    # Write failure report header
    cat > "$FAILURE_LOG" << EOF
=== CI FAILURE REPORT ===
Run ID: $run_id
Branch: $BRANCH
Commit: ${commit:0:7}
Failed at: $created_at
Attempt: $attempt of $MAX_RETRIES
Run URL: $run_url

=== FAILED STEP LOGS ===
EOF
    
    # Append failed logs
    gh run view "$run_id" --log-failed >> "$FAILURE_LOG" 2>&1 || {
        echo "Could not retrieve detailed logs. Check the run URL above." >> "$FAILURE_LOG"
    }
    
    log_error "CI failed! Details written to .ci-failure.log"
    echo ""
    echo "--- Failure Summary ---"
    # Show first 50 lines of failure log for immediate visibility
    head -n 50 "$FAILURE_LOG"
    if [ $(wc -l < "$FAILURE_LOG") -gt 50 ]; then
        echo ""
        echo "... (truncated, see .ci-failure.log for full output)"
    fi
    echo "------------------------"
}

# Function to wait for a new run after failure
wait_for_new_run() {
    local last_run_id="$1"
    local last_commit="$2"
    
    log_info "Waiting for new commit/CI run..."
    log_info "Fix the issues in .ci-failure.log, commit, and push"
    echo ""
    
    local waited=0
    local max_wait=3600  # Max 1 hour waiting for new run
    
    while [ $waited -lt $max_wait ]; do
        sleep "$POLL_INTERVAL"
        waited=$((waited + POLL_INTERVAL))
        
        local new_run_info=$(get_latest_run_id)
        if [ -z "$new_run_info" ]; then
            continue
        fi
        
        local new_run_id=$(echo "$new_run_info" | cut -d'|' -f1)
        local new_commit=$(echo "$new_run_info" | cut -d'|' -f4)
        
        # Check if this is a new run (different ID or different commit)
        if [ "$new_run_id" != "$last_run_id" ] || [ "$new_commit" != "$last_commit" ]; then
            log_success "New CI run detected: #$new_run_id"
            echo "$new_run_id"
            return 0
        fi
        
        # Show waiting indicator every 2 minutes
        if [ $((waited % 120)) -eq 0 ]; then
            log_info "Still waiting for new run... (${waited}s elapsed)"
        fi
    done
    
    log_error "Timed out waiting for new CI run"
    return 1
}

# Clean up old failure log on success
cleanup_on_success() {
    if [ -f "$FAILURE_LOG" ]; then
        rm -f "$FAILURE_LOG"
        log_info "Removed old .ci-failure.log"
    fi
}

# Main retry loop
attempt=1
last_run_id=""
last_commit=""

while [ $attempt -le $MAX_RETRIES ]; do
    log_info "CI check attempt $attempt of $MAX_RETRIES"
    
    # Get latest run
    run_info=$(get_latest_run_id)
    
    if [ -z "$run_info" ]; then
        log_warning "No CI runs found for branch '$BRANCH'"
        log_info "Push changes to trigger a CI run, or check if workflows are enabled"
        
        if [ $attempt -lt $MAX_RETRIES ]; then
            # Wait for a run to appear
            new_run_id=$(wait_for_new_run "" "")
            if [ -n "$new_run_id" ]; then
                run_info=$(get_latest_run_id)
            else
                exit 1
            fi
        else
            exit 1
        fi
    fi
    
    run_id=$(echo "$run_info" | cut -d'|' -f1)
    run_status=$(echo "$run_info" | cut -d'|' -f2)
    run_conclusion=$(echo "$run_info" | cut -d'|' -f3)
    run_commit=$(echo "$run_info" | cut -d'|' -f4)
    
    log_info "Run #$run_id (commit: ${run_commit:0:7})"
    
    # If run is still in progress, wait for it
    if [ "$run_status" = "in_progress" ] || [ "$run_status" = "queued" ] || [ "$run_status" = "pending" ]; then
        if wait_for_run "$run_id"; then
            log_success "CI passed!"
            cleanup_on_success
            exit 0
        else
            capture_failure_logs "$run_id" "$attempt"
        fi
    elif [ "$run_conclusion" = "success" ]; then
        log_success "CI already passed!"
        cleanup_on_success
        exit 0
    else
        # Run already completed with failure
        capture_failure_logs "$run_id" "$attempt"
    fi
    
    # If we have more retries, wait for a new run
    if [ $attempt -lt $MAX_RETRIES ]; then
        new_run_id=$(wait_for_new_run "$run_id" "$run_commit")
        if [ -z "$new_run_id" ]; then
            log_error "No new CI run detected. Giving up."
            exit 1
        fi
    fi
    
    attempt=$((attempt + 1))
done

log_error "CI failed after $MAX_RETRIES attempt(s)"
log_info "Review .ci-failure.log and fix remaining issues"
exit 1
