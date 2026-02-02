# Test Flow

## Overview
Test a user flow (login, checkout, onboarding, etc.) using AI-Tester MCP.

## Prerequisites
- `ai-tester` MCP server configured in `.cursor/mcp.json`
- Target app running (simulator, emulator, or web server)

## Steps

1. **Get test details from user**:
   - What flow to test? (e.g., "login flow", "checkout process")
   - Platform: iOS, Android, macOS, or Web
   - App identifier or URL:
     - iOS/Android: Bundle ID (e.g., `com.myapp.ios`)
     - Web: URL (e.g., `http://localhost:3000`)

2. **Connect to the app** using ai-tester tools:
   - Mobile: Appium connection
   - Web: Playwright connection

3. **Execute the flow**:
   - Perform each step of the user flow
   - Take screenshots at key points
   - Verify expected states
   - Handle errors gracefully

4. **Report findings**:
   - Steps completed successfully
   - Any issues or bugs found
   - Screenshots of key states

## Example Prompts

- "Test the login flow on my iOS app (com.myapp.ios)"
- "Test checkout on web at http://localhost:3000"
- "Test the onboarding flow on Android"

## Output

```
## Test Flow: Login

### Steps Executed
1. Launched app - OK
2. Tapped "Sign In" button - OK
3. Entered email - OK
4. Entered password - OK
5. Tapped "Login" - OK
6. Verified dashboard loaded - OK

### Result: PASSED

### Screenshots
[Screenshot 1: Login screen]
[Screenshot 2: Dashboard after login]

### Notes
- Login took 2.3 seconds
- No visual issues detected
```

## On Failure

If a step fails:
1. Capture screenshot of failure state
2. Log element tree for debugging
3. Report exact error
4. Ask if user wants to investigate or continue
