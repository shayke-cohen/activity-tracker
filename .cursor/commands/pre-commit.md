# Pre-Commit

## Overview
Run all checks before committing: lint, typecheck, and tests.

## Prerequisites
- Project dependencies installed
- Changes staged or ready to stage

## Steps

1. **Check for uncommitted changes**:
   ```bash
   git status
   ```

2. **Run linter**:
   ```bash
   yarn lint
   ```
   If errors, run `yarn lint:fix` and review changes.

3. **Run type checker**:
   ```bash
   yarn typecheck
   ```
   If errors, fix type issues before continuing.

4. **Run tests**:
   ```bash
   yarn test
   ```
   If failures, investigate and fix.

5. **Report results**

## Output

**All Passing:**
```
Pre-commit checks: All passed

- Lint: Passed
- TypeCheck: Passed  
- Tests: Passed (42 tests)

Ready to commit!
```

**With Failures:**
```
Pre-commit checks: Failed

- Lint: Failed (2 errors)
  - src/utils.ts:15 - Missing semicolon
  - src/api.ts:23 - Unused variable
  
- TypeCheck: Passed
- Tests: Passed

Fix lint errors before committing.
```

## Auto-Fix Mode

If user says "fix" or "auto-fix":
1. Run `yarn lint:fix` automatically
2. Stage the fixes
3. Re-run checks
4. Report final status
