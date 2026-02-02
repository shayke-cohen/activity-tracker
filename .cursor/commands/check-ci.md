# Check CI

## Overview
Check CI status for the current branch with optional self-healing loop.

## Prerequisites
- `gh` CLI authenticated
- Code pushed to remote branch

## Steps

1. **Get current branch**:
   ```bash
   git branch --show-current
   ```

2. **Check for CI runs**:
   ```bash
   gh run list --branch <branch> --limit 1
   ```

3. **Watch the run** (if in progress):
   ```bash
   gh run watch <run-id>
   ```

4. **If CI fails**, get failure details:
   ```bash
   gh run view <run-id> --log-failed
   ```

5. **Self-healing loop** (if requested):
   - Read the failure log
   - Identify the issue (lint error, test failure, type error)
   - Fix the issue
   - Commit and push
   - Watch the new CI run
   - Repeat until passing or max retries

## Output

Report CI status:

**CI Passing:**
```
CI Status: Passed
Run: https://github.com/owner/repo/actions/runs/123
Duration: 2m 30s
```

**CI Failing:**
```
CI Status: Failed
Run: https://github.com/owner/repo/actions/runs/123
Failed Step: test
Error: Expected true, got false in user.test.ts:45

Attempting fix...
```

## Options

- Default: Check status once and report
- With retry: Keep checking and fixing until pass (max 3 attempts)
