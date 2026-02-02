# Run Test

## Overview
Run an existing test file (Maestro YAML or Playwright) with step-by-step inspection.

## Prerequisites
- `ai-tester` MCP server configured
- Test file exists
- App/server running

## Steps

1. **Get test file path** from user or find in project:
   - Maestro: `tests/flows/*.yaml`
   - Playwright: `tests/e2e/*.spec.ts`

2. **Detect test type** from file extension/content

3. **Run the test** with ai-tester:
   - Maestro: Execute YAML steps with inspection
   - Playwright: Run with tracing enabled

4. **Monitor execution**:
   - Report each step as it executes
   - Capture screenshots on failures
   - Provide element tree on failures for debugging

5. **Report results**

## Example Prompts

- "Run the login test"
- "Run tests/flows/checkout.yaml on iOS"
- "Execute all Maestro tests"

## Output

**Passing Test:**
```
## Test Run: login.yaml

Platform: iOS (iPhone 15 Pro)
Duration: 12.3s

### Steps
1. launchApp - PASSED (1.2s)
2. tapOn "Sign In" - PASSED (0.3s)
3. inputText email - PASSED (0.5s)
4. inputText password - PASSED (0.4s)
5. tapOn "Login" - PASSED (0.8s)
6. assertVisible "Dashboard" - PASSED (0.2s)

### Result: PASSED

Video: tests/recordings/login-2024-01-20.mp4
```

**Failing Test:**
```
## Test Run: checkout.yaml

### Steps
1. launchApp - PASSED
2. tapOn "Add to Cart" - PASSED
3. tapOn "Checkout" - PASSED
4. assertVisible "Payment Form" - FAILED

### Failure Details
- Expected: "Payment Form" visible
- Actual: "Error: Cart is empty" displayed
- Screenshot: [attached]
- Element tree: [attached]

### Suggested Fix
The cart state may not be persisting. Check CartContext provider.
```

## Options

- Single test: Run one specific test file
- All tests: Run all tests in directory
- With video: Enable video recording (default on)
- Headless: Run without UI (web only)
