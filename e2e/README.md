# Activity Tracker E2E Tests

End-to-end tests for the Activity Tracker iOS app using [Maestro](https://maestro.mobile.dev/).

## Test Suite

| Test File | Description | Duration |
|-----------|-------------|----------|
| `onboarding.yaml` | App launch and HealthKit permission flow | ~19s |
| `settings.yaml` | Settings screen and all configuration options | ~15s |
| `achievements.yaml` | Achievements tab, streak, and badges sections | ~11s |
| `badge-details.yaml` | Badge details view and category filtering | ~19s |
| `streak-and-badges.yaml` | Comprehensive streak and badge coverage | ~17s |
| `history-view.yaml` | History tab with filters and date ranges | ~30s |
| `full-navigation.yaml` | Complete tab navigation flow | ~25s |
| `dashboard-full.yaml` | Dashboard with progress rings and quick start | ~14s |
| `activity-selection.yaml` | All activity categories and types | ~12s |
| `quick-workout.yaml` | Quick workout flow (activity selection) | ~11s |

**Total: 10 tests, ~3 minutes runtime**

## Requirements

- [Maestro CLI](https://maestro.mobile.dev/getting-started/installing-maestro) installed
- iOS Simulator with iPhone 17 Pro
- Activity Tracker app installed on simulator

## Running Tests

### Run All Tests

```bash
cd /Users/shayco/activity-tracker
maestro test e2e/tests/
```

### Run Individual Test

```bash
maestro test e2e/tests/onboarding.yaml
maestro test e2e/tests/dashboard-full.yaml
```

### Run Specific Tests

```bash
maestro test e2e/tests/onboarding.yaml e2e/tests/settings.yaml e2e/tests/achievements.yaml
```

## Test Coverage

### UI Coverage

- **Dashboard**: Progress rings, metrics, streak card, quick start buttons
- **Awards Tab**: Streak section, badges, categories (Milestones, Streaks, Personal Bests)
- **History Tab**: Workout list, filters (All, Running, Cycling, etc.), date range menu
- **Settings Tab**: Goals, Health integration, Apple Watch, Notifications
- **Navigation**: All tab transitions and back navigation

### Functional Coverage

- App launch and initialization
- HealthKit permission handling (conditional flow)
- Tab navigation (Home, Awards, History, Profile)
- Badge detail views
- Activity type selection (all 15+ types)
- Filter interactions
- Settings configuration

## Key Element Selectors

### Tab Bar Icons
- Home: `id: "house.fill"`
- Awards: `id: "trophy.fill"`
- History: `id: "clock.fill"`
- Profile: `id: "person.fill"`

### Dashboard
- Settings: `id: "gearshape.fill"`
- Quick Start Activities: `text: "Running"`, `text: "Cycling"`, etc.

### Activity Icons
- Running: `id: "figure.run"`
- Swimming: `id: "figure.pool.swim"`
- Yoga: `id: "figure.yoga"`

## Troubleshooting

### Tests Timing Out
- Increase timeout in `extendedWaitUntil` blocks
- Check simulator is responding

### Element Not Found
- Use `maestro studio` to inspect the UI hierarchy
- Verify accessibility IDs match

### Simulator Issues
```bash
# Boot simulator
xcrun simctl boot "iPhone 17 Pro"

# Install app
xcrun simctl install booted /path/to/ActivityTracker.app

# Grant permissions
xcrun simctl privacy booted grant all com.activitytracker.ActivityTracker
```

## Known Limitations

- Workout in-progress tests are unstable due to timing issues with the countdown animation
- Tests focus on UI verification rather than full workout lifecycle
- HealthKit data depends on device/simulator state
