# Visual Regression

## Overview
Compare screenshots against baselines to detect visual changes.

## Prerequisites
- `ai-tester` MCP server configured
- Baseline screenshots (or will create them)
- App/server running

## Steps

1. **Determine mode**:
   - **Create baseline:** First run, save screenshots as reference
   - **Compare:** Compare current state against baseline
   - **Update baseline:** Accept current state as new baseline

2. **Identify screens to test**:
   - User specifies screens, OR
   - Run through key screens automatically

3. **Capture screenshots**:
   - Navigate to each screen
   - Wait for content to load
   - Capture full-page or specific elements

4. **Compare against baselines** (if not creating):
   - Pixel-by-pixel comparison
   - Highlight differences
   - Calculate diff percentage

5. **Report results**

## Example Prompts

- "Run visual regression on the dashboard"
- "Create baseline screenshots for all screens"
- "Compare login screen against baseline"
- "Update baseline for settings page"

## Output

**No Changes:**
```
## Visual Regression: Dashboard

Screens tested: 5
Baseline date: 2024-01-15

### Results
| Screen | Status | Diff |
|--------|--------|------|
| Home | MATCH | 0.0% |
| Profile | MATCH | 0.0% |
| Settings | MATCH | 0.1% |
| Dashboard | MATCH | 0.0% |
| Login | MATCH | 0.0% |

All screens match baseline.
```

**With Changes:**
```
## Visual Regression: Dashboard

### Results
| Screen | Status | Diff |
|--------|--------|------|
| Home | MATCH | 0.0% |
| Profile | CHANGED | 5.2% |
| Settings | MATCH | 0.1% |

### Changes Detected

#### Profile Screen
- Diff: 5.2%
- Change type: Layout shift
- Details: Avatar image moved 10px right

[Baseline] [Current] [Diff overlay]

### Actions
- Type "accept" to update baseline
- Type "ignore" to skip this change
- Type "investigate" to look closer
```

## Exclusion Regions

For dynamic content (timestamps, ads, user data):
```
Exclude from comparison:
- Header timestamp
- Ad banner region
- User avatar (changes per user)
```

## Thresholds

- **0-0.5%:** Match (minor anti-aliasing)
- **0.5-2%:** Review (might be acceptable)
- **2%+:** Changed (needs attention)
