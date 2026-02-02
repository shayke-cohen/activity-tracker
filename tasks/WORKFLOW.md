# Task Workflow

> This document describes how to manage tasks and parallel work in this repository.

---

## Branch Naming Convention

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/<issue-id>-short-description` | `feature/23-user-auth` |
| Bug Fix | `bugfix/<issue-id>-short-description` | `bugfix/45-login-error` |
| Hotfix | `hotfix/<issue-id>-short-description` | `hotfix/99-critical-bug` |
| Task | `task/<issue-id>-short-description` | `task/67-update-deps` |
| Agent | `agent/<agent-name>-<issue-id>` | `agent/cursor-23` |

---

## Task Lifecycle

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Create    │────▶│    Work     │────▶│   Review    │
│   Issue     │     │  (Branch)   │     │    (PR)     │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Update    │◀────│   Merge     │◀────│   Approve   │
│  Knowledge  │     │  to Main    │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Step-by-Step

1. **Create GitHub Issue** with task template
2. **Create branch** from `main` following naming convention
3. **Work in isolation** (agent or human)
4. **Keep branch updated**: `git pull origin main` regularly
5. **Open PR** when ready, reference issue number
6. **Pass CI checks** + code review
7. **Merge** (squash preferred for clean history)
8. **Update knowledge/** if lessons learned
9. **Delete branch** after merge

---

## Parallel Work Rules

### Before Starting

- [ ] Check for conflicting tasks (same files)
- [ ] Claim task via GitHub issue assignment
- [ ] Verify branch name is available

### During Work

- [ ] Commit frequently (at least daily)
- [ ] Rebase/merge from main at least daily
- [ ] Communicate overlapping file changes in issue
- [ ] Post progress updates to GitHub issue

### Conflict Resolution

1. If conflict detected, coordinate with other assignee
2. Smaller/simpler change should merge first
3. Larger change rebases on updated main
4. Use `git rerere` for recurring conflicts

---

## Using Worktrees for Parallel Development

Worktrees allow working on multiple issues simultaneously:

```bash
# Start work on issue 23 (creates worktree)
./scripts/start-issue.sh 23

# This creates:
# .worktrees/issue-23/
# ├── .cursor-task.md  # Task instructions
# └── ... (full repo)

# List all active worktrees
./scripts/list-worktrees.sh

# Finish and create PR
./scripts/finish-issue.sh 23

# Cleanup (after PR merged)
./scripts/finish-issue.sh 23 --cleanup
```

### Worktree Directory Structure

```
project/
├── .worktrees/           # Gitignored
│   ├── issue-23/         # Worktree for issue 23
│   │   ├── .cursor-task.md
│   │   └── ... (full repo)
│   └── issue-45/         # Worktree for issue 45
└── ... (main repo)
```

---

## GitHub Issue Labels

### Type Labels
| Label | Color | Description |
|-------|-------|-------------|
| `feature` | Green | New feature |
| `enhancement` | Blue | Improvement |
| `bug` | Red | Something broken |
| `hotfix` | Dark Red | Critical fix |
| `documentation` | Light Blue | Docs only |

### Priority Labels
| Label | Description |
|-------|-------------|
| `priority:critical` | Drop everything |
| `priority:high` | This sprint |
| `priority:medium` | Next sprint |
| `priority:low` | Backlog |

### Status Labels
| Label | Description |
|-------|-------------|
| `status:planning` | Planning phase |
| `status:in-progress` | Work started |
| `status:review` | PR in review |
| `status:blocked` | Waiting on something |
| `status:approved` | Ready to implement |

### Agent Labels
| Label | Description |
|-------|-------------|
| `agent:assigned` | AI agent working |
| `agent:needs-human` | Needs human help |
| `agent:autonomous` | Agent can work independently |
| `agent:created` | Issue created by AI agent |
| `agent:needs-approval` | Agent waiting for human approval |

### Tier Labels (Agent-Created Issues)
| Label | Description |
|-------|-------------|
| `tier:trivial` | Trivial task, no issue needed |
| `tier:small` | Small task, agent proceeds immediately |
| `tier:medium` | Medium task, needs approval |
| `tier:large` | Large task, needs approval + detailed plan |

---

## Ad-Hoc Task Workflow (Agent-Initiated)

When an agent receives a task via conversation (not from an existing issue), it must classify and potentially create an issue before starting work.

### Task Classification

```
┌─────────────────────────────────────────────────────────────────┐
│                    AGENT RECEIVES AD-HOC TASK                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Classify Task   │
                    │ (see criteria)  │
                    └─────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│   TRIVIAL     │   │    SMALL      │   │ MEDIUM/LARGE  │
│ (no issue)    │   │ (issue, go)   │   │ (issue, wait) │
└───────────────┘   └───────────────┘   └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ Just commit   │   │ Create issue  │   │ Create issue  │
│ with message  │   │ + start work  │   │ + wait for    │
└───────────────┘   └───────────────┘   │   approval    │
                                        └───────────────┘
```

### Classification Criteria

| Tier | Criteria | Issue? | Wait? |
|------|----------|--------|-------|
| **Trivial** | Single-line, typos, formatting | No | No |
| **Small** | Single file, clear scope, low risk | Yes | No |
| **Medium** | Multi-file, some ambiguity, moderate risk | Yes | Yes |
| **Large** | Architectural, security, breaking changes | Yes | Yes |

### Creating Agent Issues

```bash
# Small task - create and proceed
./scripts/create-task-issue.sh \
  --title "Fix button alignment" \
  --request "fix the header button" \
  --understanding "Correct CSS alignment for header nav buttons" \
  --tier small

# Medium task - create and wait
./scripts/create-task-issue.sh \
  --title "Refactor UserService" \
  --request "clean up the auth code" \
  --understanding "Separate auth logic from user management" \
  --tier medium \
  --files "src/services/UserService.ts,src/services/AuthService.ts" \
  --risk medium \
  --plan "1. Extract auth methods\n2. Update imports\n3. Add tests"
```

### Approval Flow

For medium/large tasks, the agent must:

1. Create the issue with `agent:needs-approval` label
2. Post a confirmation message to the user
3. **Wait** for the user to reply with `approved`
4. Only then proceed with implementation

---

## Commit Message Convention

```
<type>(<scope>): <subject> (#<issue>)

<body>

<footer>
```

### Types
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Formatting (no code change)
- `refactor` - Code restructuring
- `test` - Adding tests
- `chore` - Maintenance

### Examples

```bash
feat(auth): add OAuth2 login (#23)

- Implement Google OAuth flow
- Add token refresh mechanism
- Update user model

Closes #23
```

```bash
fix(api): handle null response (#45)

Added null check in parseResponse() to prevent
crash when API returns empty body.

Fixes #45
```

---

## PR Checklist

Before requesting review:

- [ ] Branch is up to date with main
- [ ] All tests pass
- [ ] Linter passes
- [ ] PR description explains changes
- [ ] Issue number referenced
- [ ] Screenshots included (if UI change) - see [Screenshot Guidelines](../AGENTS.md#screenshot-guidelines)
- [ ] Documentation updated (if needed)
- [ ] Knowledge entries added (if learned something)

---

## Quick Reference Commands

```bash
# Create branch for issue
git checkout -b feature/issue-23-description

# Update branch from main
git fetch origin main
git rebase origin/main

# Push branch
git push -u origin feature/issue-23-description

# Create PR
gh pr create --title "Feature: ..." --body "Closes #23"

# Merge PR (after approval)
gh pr merge --squash --delete-branch
```
