# Generate Regression

## Overview
Generate regression tests from the current testing session or a described flow.

## Prerequisites
- `ai-tester` MCP server configured
- Either:
  - Just completed exploratory testing session, OR
  - User describes the flow to test

## Steps

1. **Determine test source**:
   - From recent session: Review actions taken during exploration
   - From description: User provides the flow to test

2. **Choose test format** based on platform:
   - iOS/Android: Maestro YAML
   - Web: Playwright Test
   - macOS: AppleScript

3. **Generate test file**:
   - Convert actions to test steps
   - Add assertions for key states
   - Include setup/teardown
   - Add meaningful test names

4. **Save to appropriate location**:
   - Maestro: `tests/flows/<name>.yaml`
   - Playwright: `tests/e2e/<name>.spec.ts`

5. **Validate the test** by running it once

## Example Prompts

- "Generate a regression test from this session"
- "Create a Maestro test for the login flow"
- "Generate Playwright tests for the checkout process"

## Output

### Maestro YAML Example
```yaml
# tests/flows/login.yaml
appId: com.myapp.ios
---
- launchApp
- tapOn: "Sign In"
- inputText:
    id: "email-input"
    text: "test@example.com"
- inputText:
    id: "password-input"
    text: "password123"
- tapOn: "Login"
- assertVisible: "Dashboard"
```

### Playwright Example
```typescript
// tests/e2e/login.spec.ts
import { test, expect } from '@playwright/test';

test('user can login successfully', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await page.click('text=Sign In');
  await page.fill('[data-testid="email"]', 'test@example.com');
  await page.fill('[data-testid="password"]', 'password123');
  await page.click('text=Login');
  await expect(page.locator('h1')).toContainText('Dashboard');
});
```

## After Generation

Report:
- File path where test was saved
- How to run the test
- Any manual adjustments recommended
