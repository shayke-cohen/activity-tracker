# AGENTS.md - AI Agent Instructions

> **Last Updated:** 2026-01-23
> **For:** AI agents and Cursor AI working on this project

This document provides context for AI agents. For detailed procedures, see the **Skills** section below.

---

## Quick Reference Commands

```bash
# Build
yarn build                 # Build the project
yarn dev                   # Start development server

# Test
yarn test                  # Run all tests
yarn test --watch          # Watch mode
yarn test --coverage       # With coverage report

# Lint
yarn lint                  # Check for errors
yarn lint:fix              # Auto-fix issues
yarn typecheck             # TypeScript check

# Git workflow
./scripts/start-issue.sh <number>    # Start work on issue
./scripts/finish-issue.sh <number>   # Create PR for issue

# GitHub CLI
gh issue list                        # List open issues
gh issue view <number>               # View issue details
gh pr create                         # Create pull request
```

---

## Project Overview

[PROJECT_NAME] is [brief description of what the project does].

### Key Characteristics
- **Language:** TypeScript/JavaScript (or your language)
- **Framework:** [Your framework]
- **Architecture:** [Monolith/Microservices/etc.]

---

## Tech Stack

See [STACK.md](./STACK.md) for full details on approved tools and versions.

| Category | Tool | Version |
|----------|------|---------|
| Runtime | Node.js | 20.x LTS |
| Package Manager | yarn | 4.x |
| Language | TypeScript | 5.3+ |

---

## Project Structure

```
├── .cursor/
│   ├── rules/              # Cursor AI rules
│   ├── skills/             # AI agent skills
│   └── mcp.json            # MCP server config
├── docs/design/            # Feature specifications
├── knowledge/
│   ├── KNOWN_ISSUES.md     # Documented pitfalls
│   ├── LESSONS_LEARNED.md  # Solutions worth preserving
│   └── DECISIONS.md        # Architecture decisions
├── scripts/                # Helper scripts
├── src/                    # Application source code
├── tests/                  # Unit and integration tests
├── AGENTS.md              # This file (you are here)
├── ARCHITECTURE.md        # System design
└── STACK.md               # Tech stack & versions
```

---

## Skills Reference

Skills provide deep expertise for specific tasks. They are loaded on-demand when relevant.

**40 skills** organized by category:

| Category | Skill | When to Use |
|----------|-------|-------------|
| **Testing** | `test-driven-development` | TDD with RED-GREEN-REFACTOR cycle |
| | `webapp-testing` | Playwright E2E, Vitest unit tests |
| | `exploratory-testing` | Finding bugs through exploration |
| | `visual-regression` | Screenshot comparison testing |
| | `maestro-mobile-testing` | Mobile E2E tests with YAML |
| | `ai-tester-integration` | AI-assisted UI testing |
| **Development** | `code-refactoring` | Safe code improvements |
| | `typescript-api` | TypeScript API development patterns |
| | `react-best-practices` | React components and performance |
| | `react-native` | Mobile app development |
| | `kotlin-android` | Android development |
| | `swift-development` | iOS/macOS development |
| | `frontend-designer` | UI/UX and WCAG accessibility |
| | `database-design` | PostgreSQL and Prisma |
| **Review** | `gh-code-review` | Reviewing pull requests |
| | `security-review` | OWASP patterns and vulnerability scanning |
| **Debugging** | `systematic-debugging` | Root cause analysis methodology |
| | `bug-fix-workflow` | Bug tracking and fixing workflow |
| **Documentation** | `writing-plans` | Feature planning and specs |
| | `executing-plans` | Implementing approved plans |
| | `crafting-readmes` | README documentation |
| | `mermaid-diagrams` | Documentation diagrams |
| **Tools** | `git-worktrees` | Parallel development |
| | `perplexity-search` | AI-powered research |
| | `web-search-research` | Finding docs and solutions |
| **Planning** | `prd-writing` | Product Requirements Documents |
| | `sprint-planning` | Agile sprint planning and estimation |
| | `roadmap-creation` | Product roadmap with Now/Next/Later |
| | `technical-design` | Technical design docs, RFCs, ADRs |
| **UX Design** | `design-system-guidelines` | Design system documentation |
| | `accessibility-audit` | WCAG 2.1 AA compliance checking |
| | `responsive-design` | Mobile-first responsive patterns |
| | `component-design` | UI component design |
| **UX Content** | `ux-writing-microcopy` | Interface copy and microcopy |
| | `error-message-design` | Error message UX patterns |
| | `content-strategy` | Content planning and IA |
| **Security** | `owasp-security` | OWASP Top 10 deep-dive |
| | `threat-modeling` | STRIDE threat modeling |
| | `dependency-audit` | Vulnerability scanning |
| | `api-security` | API security best practices |

### Installing Skills

```bash
# Install all skills
curl -sL https://raw.githubusercontent.com/shayke-cohen/ai-native-engineer/main/templates/scripts/install-skill.sh | bash -s -- --all

# List available skills
curl -sL https://raw.githubusercontent.com/shayke-cohen/ai-native-engineer/main/templates/scripts/install-skill.sh | bash -s -- --list

# Install specific skill
curl -sL https://raw.githubusercontent.com/shayke-cohen/ai-native-engineer/main/templates/scripts/install-skill.sh | bash -s -- test-driven-development
```

---

## Critical Rules

### ALWAYS Do

1. **Read before writing** - Check `knowledge/KNOWN_ISSUES.md` and existing code
2. **Run tests before committing** - `yarn lint && yarn typecheck && yarn test`
3. **Write tests for new code** - Unit tests for functions, integration for endpoints
4. **Post progress updates** - Keep GitHub issues updated at milestones
5. **Follow existing patterns** - Match the style of surrounding code

### NEVER Do

1. ❌ Commit directly to main - Always use feature branches
2. ❌ Skip tests - Even for "small" changes
3. ❌ Hardcode secrets - Use environment variables
4. ❌ Ignore linter errors - Fix them or document exceptions
5. ❌ Make breaking changes without discussion - Get approval first
6. ❌ Guess on important decisions - Ask when uncertain

---

## GitHub Labels

**Type:** `feature`, `enhancement`, `bug`, `hotfix`, `documentation`
**Priority:** `priority:critical`, `priority:high`, `priority:medium`, `priority:low`
**Status:** `status:planning`, `status:in-progress`, `status:review`, `status:blocked`
**Agent:** `agent:assigned`, `agent:needs-human`, `agent:autonomous`

---

## Quick Workflows

### Starting Work on an Issue

```bash
./scripts/start-issue.sh 23
# Or manually:
git checkout -b feature/issue-23-description main
gh issue edit 23 --add-label "status:in-progress"
```

### Posting Progress Updates

```bash
gh issue comment 23 --body "## 🔄 Progress Update

### Completed
- ✅ [What's done]

### In Progress
- 🔄 [Current work]

No blockers. Continuing implementation."
```

### When Blocked

```bash
gh issue edit 23 --add-label "status:blocked"
gh issue comment 23 --body "## 🚫 Blocked

### Blocker
[Clear description]

### What I Need
- [ ] [Specific help needed]"
```

See `writing-plans` and `executing-plans` skills for detailed planning workflows.
See `bug-fix-workflow` skill for test-discovered bug handling.

---

## Testing Requirements

### Before ANY Commit

```bash
yarn lint          # Must pass
yarn typecheck     # Must pass
yarn test          # Must pass
```

### Test Expectations

- Unit tests for new functions
- Integration tests for new endpoints
- Regression tests for bug fixes (write failing test first)
- Aim for >80% coverage on new code

See `test-driven-development` and `webapp-testing` skills for detailed patterns.

---

## Code Style

### Naming Conventions

- **Files:** `kebab-case.ts` for utilities, `PascalCase.tsx` for components
- **Variables/Functions:** `camelCase`
- **Classes/Types:** `PascalCase`
- **Constants:** `UPPER_SNAKE_CASE`

### Commit Messages

```
<type>(<scope>): <subject> (#<issue>)
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## Adding Knowledge

When you solve a non-trivial problem, document it:

### For Known Issues

Add to `knowledge/KNOWN_ISSUES.md`:

```markdown
## [ISSUE-ID] Brief Title
**Date:** YYYY-MM-DD
**Severity:** High/Medium/Low
**Symptoms:** What went wrong
**Root Cause:** Why it happened
**Solution:** How to fix it
```

### For Lessons Learned

Add to `knowledge/LESSONS_LEARNED.md`:

```markdown
## [LESSON-ID] Title
**Context:** When this applies
**Problem:** What was challenging
**Solution:** The approach that worked
**Tags:** searchable, keywords
```

---

## Troubleshooting

### Debugging Approach

1. **Read the error message carefully** - Often contains the solution
2. **Check knowledge/** - May already be documented
3. **Use web search** - For errors, best practices, current docs
4. **Reproduce minimally** - Isolate the failing case
5. **Add logging** - Trace the execution path
6. **Escalate if stuck** - Use `agent:needs-human` after 15-20 min

See `systematic-debugging` skill for detailed methodology.

### Common Issues

| Problem | Solution |
|---------|----------|
| Import not found | `yarn add <package>` |
| Type errors | `yarn typecheck`, fix types |
| Test timeout | Add `await`, increase timeout |
| Lint failing | `yarn lint:fix` |
| Build failing | Check error line, fix syntax |

### When to Escalate

Use `agent:needs-human` when:
- Stuck for more than 15-20 minutes
- Requires external access (credentials, APIs)
- Architecture decision needed
- Security implications unclear

---

## Quick Checklist

Before submitting a PR:

- [ ] All tests pass (`yarn test`)
- [ ] Linter passes (`yarn lint`)
- [ ] Type check passes (`yarn typecheck`)
- [ ] New code has tests
- [ ] Commit messages follow convention
- [ ] PR references the issue number
- [ ] Screenshots included (if UI changes)
