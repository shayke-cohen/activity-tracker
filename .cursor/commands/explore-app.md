# Explore App

## Overview
Explore an app with AI assistance to find bugs, UI issues, or unexpected behavior.

## Prerequisites
- `ai-tester` MCP server configured in `.cursor/mcp.json`
- Target app running

## Steps

1. **Get app details from user**:
   - Platform: iOS, Android, macOS, or Web
   - App identifier or URL
   - Focus area (optional): "settings", "user profile", "entire app"

2. **Connect to the app** using ai-tester tools

3. **Systematic exploration**:
   - Navigate through screens
   - Interact with UI elements
   - Test edge cases:
     - Empty states
     - Long text inputs
     - Rapid tapping
     - Back navigation
     - Rotation (mobile)
   - Look for:
     - UI glitches
     - Broken layouts
     - Unresponsive elements
     - Crashes
     - Error messages

4. **Document findings** as you go

## Example Prompts

- "Explore my iOS app and look for UI issues"
- "Explore the settings section of my web app at localhost:3000"
- "Do exploratory testing on my Android app"

## Output

```
## Exploratory Testing Report

### App: com.myapp.ios
### Duration: 15 minutes
### Screens Visited: 12

### Issues Found

#### Issue 1: Button overlap on small screens
- **Location:** Settings > Profile
- **Severity:** Medium
- **Screenshot:** [attached]
- **Steps to reproduce:**
  1. Navigate to Settings
  2. Tap Profile
  3. Observe "Save" button overlaps with text field

#### Issue 2: Missing loading indicator
- **Location:** Dashboard
- **Severity:** Low
- **Description:** Data loads without spinner, appears frozen

### Areas Tested
- Login/Logout
- Settings
- Profile
- Dashboard
- Navigation

### No Issues Found In
- Main navigation
- Form validation
- Error handling
```

## Tips

- Mention specific areas you want tested
- Ask for "edge case testing" for thorough exploration
- Request "accessibility check" for a11y issues
