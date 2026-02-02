#!/bin/bash
# Create standard labels for the repository

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "Creating GitHub labels..."

# Type labels
gh label create "feature" --color "0E8A16" --description "New feature" --force 2>/dev/null || true
gh label create "enhancement" --color "84b6eb" --description "Improvement" --force 2>/dev/null || true
gh label create "bug" --color "d73a4a" --description "Something broken" --force 2>/dev/null || true
gh label create "hotfix" --color "b60205" --description "Critical fix" --force 2>/dev/null || true
gh label create "documentation" --color "0075ca" --description "Docs only" --force 2>/dev/null || true

# Priority labels
gh label create "priority:critical" --color "b60205" --description "Drop everything" --force 2>/dev/null || true
gh label create "priority:high" --color "d93f0b" --description "This sprint" --force 2>/dev/null || true
gh label create "priority:medium" --color "fbca04" --description "Next sprint" --force 2>/dev/null || true
gh label create "priority:low" --color "0e8a16" --description "Backlog" --force 2>/dev/null || true

# Status labels
gh label create "status:planning" --color "c5def5" --description "Planning phase" --force 2>/dev/null || true
gh label create "status:in-progress" --color "0052cc" --description "Work started" --force 2>/dev/null || true
gh label create "status:review" --color "5319e7" --description "In review" --force 2>/dev/null || true
gh label create "status:blocked" --color "d73a4a" --description "Blocked" --force 2>/dev/null || true
gh label create "status:approved" --color "0e8a16" --description "Approved" --force 2>/dev/null || true

# Agent labels
gh label create "agent:assigned" --color "7057ff" --description "AI agent working" --force 2>/dev/null || true
gh label create "agent:needs-human" --color "d876e3" --description "Needs human" --force 2>/dev/null || true
gh label create "agent:autonomous" --color "0e8a16" --description "Agent independent" --force 2>/dev/null || true
gh label create "agent:created" --color "6f42c1" --description "Issue created by AI agent" --force 2>/dev/null || true
gh label create "agent:needs-approval" --color "fbca04" --description "Agent waiting for approval" --force 2>/dev/null || true
gh label create "agent:discovered" --color "e99695" --description "Bug discovered by agent during testing" --force 2>/dev/null || true

# Tier labels (for agent-created issues)
gh label create "tier:trivial" --color "cccccc" --description "Trivial task, no issue needed" --force 2>/dev/null || true
gh label create "tier:small" --color "0e8a16" --description "Small task" --force 2>/dev/null || true
gh label create "tier:medium" --color "fbca04" --description "Medium task, needs approval" --force 2>/dev/null || true
gh label create "tier:large" --color "d93f0b" --description "Large task, needs approval + plan" --force 2>/dev/null || true

log_success "Labels created!"
