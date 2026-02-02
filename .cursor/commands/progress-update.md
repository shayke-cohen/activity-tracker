# Progress Update

## Overview
Post a progress update to the current GitHub issue.

## Prerequisites
- `gh` CLI authenticated
- Working on an issue (on feature branch)

## Steps

1. **Identify current issue** from branch name (e.g., `feature/issue-23-...`)

2. **Gather progress information**:
   - What's completed since last update?
   - What's currently in progress?
   - What remains to be done?
   - Any blockers?

3. **Post update comment**:
   ```bash
   gh issue comment <number> --body "## Progress Update
   
   ### Completed
   - <What's done>
   
   ### In Progress
   - <Current work>
   
   ### Remaining
   - <What's left>
   
   ### Blockers
   <None / describe blockers>
   
   ---
   *Continuing implementation...*"
   ```

4. **If blocked**, also update labels:
   ```bash
   gh issue edit <number> --add-label "status:blocked"
   ```

## Output

Confirm the update was posted with a link to the comment.

## When to Use

Post updates at these milestones:
- After completing a significant component
- When blocked and need help
- Before ending a work session
- When scope changes or new issues discovered
