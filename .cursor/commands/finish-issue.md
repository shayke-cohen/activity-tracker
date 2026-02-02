# Finish Issue

## Overview
Complete work on a GitHub issue by running checks, creating a PR, and updating the issue.

## Prerequisites
- `gh` CLI authenticated
- On a feature branch for the issue
- Work completed and committed

## Steps

1. **Identify current issue** from branch name or ask user

2. **Run pre-commit checks**:
   ```bash
   yarn lint && yarn typecheck && yarn test
   ```
   If any fail, fix issues before continuing.

3. **Push branch**:
   ```bash
   git push -u origin HEAD
   ```

4. **Create pull request**:
   ```bash
   gh pr create --title "<type>: <description> (#<issue>)" --body "## Summary
   
   <Brief description of changes>
   
   ## Changes
   - <Change 1>
   - <Change 2>
   
   ## Test Plan
   - [ ] Tests pass locally
   - [ ] Tested manually
   
   Closes #<issue>"
   ```

5. **Update issue labels**:
   ```bash
   gh issue edit <number> --remove-label "status:in-progress" --add-label "status:review"
   ```

6. **Post completion comment**:
   ```bash
   gh issue comment <number> --body "## Ready for Review
   
   PR: <pr-url>
   
   ### Changes Made
   - <Summary of changes>
   
   ### Testing
   - All tests pass
   - <Any manual testing done>"
   ```

## Output

Report:
- PR URL
- CI status (if available)
- Any warnings or notes for reviewer
