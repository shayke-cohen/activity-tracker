# Fix Failing Test

## Overview
Run a test, analyze failures, and automatically fix issues in code or test.

## Prerequisites
- `ai-tester` MCP server configured
- Test file that's failing (or will be identified)
- App/server running

## Steps

1. **Identify the failing test**:
   - User provides test path, OR
   - Run test suite to find failures

2. **Run the test** with detailed inspection:
   - Capture each step
   - Get screenshots at failure point
   - Capture element tree

3. **Analyze the failure**:
   - Is it a test issue? (wrong selector, outdated assertion)
   - Is it a code bug? (actual functionality broken)
   - Is it an environment issue? (app not running, wrong state)

4. **Determine fix approach**:
   - **Test issue:** Update selectors, assertions, or flow
   - **Code bug:** Fix the application code
   - **Environment:** Report setup requirements

5. **Apply the fix**:
   - Edit the appropriate file
   - Re-run the test to verify

6. **Iterate** until test passes (max 3 attempts)

## Example Prompts

- "Fix the failing login test"
- "Run checkout.yaml and fix any failures"
- "Debug why the payment test is failing"

## Output

```
## Fix Failing Test: checkout.yaml

### Initial Run
- Status: FAILED at step 4
- Error: "Payment Form" not visible

### Analysis
The test expects "Payment Form" but the app shows "Cart Empty".
Root cause: Cart state is lost on navigation.

### Fix Applied
File: src/context/CartContext.tsx
Change: Added persistence to localStorage

### Verification Run
- Status: PASSED
- All 6 steps completed

### Summary
- Issue: Cart state not persisting
- Fix: Added localStorage persistence in CartContext
- Files changed:
  - src/context/CartContext.tsx
```

## Decision Tree

```
Test Failed
    │
    ├─ Element not found?
    │   ├─ Element exists with different selector → Update test
    │   └─ Element missing from app → Fix app code
    │
    ├─ Wrong content/state?
    │   ├─ Test expectation outdated → Update test
    │   └─ App showing wrong content → Fix app code
    │
    └─ Timeout/crash?
        ├─ App not running → Report to user
        └─ App crashing → Investigate and fix
```
