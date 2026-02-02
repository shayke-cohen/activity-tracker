# Start Issue

## Overview
Start work on a GitHub issue by creating a branch, updating labels, and posting a starting comment.

## Prerequisites
- `gh` CLI authenticated
- Issue number provided by user

## Steps

1. **Get issue number** from user (e.g., "start issue 23" or just "23")

2. **Fetch issue details**:
   ```bash
   gh issue view <number>
   ```

3. **Create feature branch**:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/issue-<number>-<brief-description>
   ```

4. **Update issue labels**:
   ```bash
   gh issue edit <number> --add-label "status:in-progress" --add-label "agent:assigned"
   ```

5. **Post starting comment**:
   ```bash
   gh issue comment <number> --body "## Starting Work
   
   **Branch:** \`feature/issue-<number>-<description>\`
   
   Will post plan for approval before implementation."
   ```

6. **Read relevant context**:
   - Check `knowledge/KNOWN_ISSUES.md` for related issues
   - Read files mentioned in the issue
   - Understand the scope

## Output

Report:
- Branch name created
- Issue URL
- Brief summary of what needs to be done
- Ask if user wants to see a plan before implementation
