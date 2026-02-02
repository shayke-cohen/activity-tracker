# Activity Tracker

A comprehensive iOS activity tracking app with Live Activities, Apple Watch integration, and gamification features.

## Features

### Activity Tracking
- **15+ Activity Types**: Running, Walking, Cycling, Swimming, Hiking, Strength Training, HIIT, Yoga, Pilates, and more
- **Real-time Metrics**: Heart rate, calories, distance, pace, and duration
- **GPS Tracking**: Route mapping for outdoor activities
- **HealthKit Integration**: Sync with Apple Health for comprehensive data

### Live Activities & Widgets
- **Dynamic Island**: Compact and expanded workout views
- **Lock Screen Live Activity**: Real-time workout stats
- **Lock Screen Widgets**: Steps, calories, and streak at a glance
- **Control Buttons**: Pause/resume directly from Dynamic Island

### Apple Watch
- **Full Watch App**: Start workouts independently from your wrist
- **Real-time Metrics**: Heart rate, distance, pace on your watch
- **Water Lock**: For swimming workouts
- **Watch Complications**: Steps, calories, active workout on watch faces

### Gamification
- **Achievement Badges**: 20+ badges across milestones, streaks, and personal bests
- **Streak Tracking**: Track consecutive active days
- **Progress Rings**: Apple Fitness-style Move and Exercise rings
- **Weekly Challenges**: Auto-generated goals

### Social Sharing
- **Shareable Workout Cards**: Beautiful images with stats
- **Multiple Formats**: Instagram Stories, Square, Wide
- **Badge Sharing**: Share your achievements

### Design
- **Liquid Glass UI**: iOS 26's latest design language
- **Dark Mode**: Full support for light and dark themes
- **Accessibility**: WCAG AA compliant

## Project Structure

```
ActivityTracker/
├── ActivityTracker/              # Main iOS App
│   ├── App/                      # App entry point
│   ├── Views/                    # SwiftUI views
│   │   ├── Dashboard/            # Home screen
│   │   ├── Activities/           # Workout views
│   │   ├── Achievements/         # Badges and streaks
│   │   ├── History/              # Past workouts
│   │   ├── Share/                # Sharing UI
│   │   └── Settings/             # App settings
│   └── ViewModels/               # View models
│
├── ActivityTrackerWidgets/       # Widget Extension
│   ├── LiveActivity/             # Dynamic Island & Lock Screen
│   └── LockScreen/               # Static widgets
│
├── ActivityTrackerWatch/         # watchOS App
│   ├── App/                      # Watch app entry
│   ├── Views/                    # Watch UI
│   └── Complications/            # Watch face complications
│
├── Shared/                       # Shared Code
│   ├── Models/                   # Data models
│   ├── Services/                 # Business logic
│   ├── Design/                   # UI components
│   └── Storage/                  # Data persistence
│
├── ActivityTrackerTests/         # Unit Tests
├── ActivityTrackerIntegrationTests/  # Integration Tests
└── e2e/                          # E2E Tests (ai-tester)
```

## Requirements

- iOS 17.0+
- watchOS 10.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

1. Clone the repository:
```bash
git clone https://github.com/shayke-cohen/activity-tracker.git
```

2. Open in Xcode:
```bash
cd activity-tracker
open ActivityTracker.xcodeproj
```

3. Configure signing:
   - Select your development team in Signing & Capabilities
   - Update bundle identifiers if needed

4. Build and run on device (HealthKit requires physical device)

## Testing

### Unit Tests
```bash
xcodebuild test -scheme ActivityTracker -destination 'platform=iOS Simulator,name=iPhone 15'
```

### E2E Tests (ai-tester MCP)
```yaml
# Run all e2e tests
test:
  action: run
  pattern: "e2e/tests/*.yaml"
  platform: ios
  app: com.activitytracker.ActivityTracker
```

## Architecture

### MVVM Pattern
- **Models**: Data structures for activities, achievements, streaks
- **Views**: SwiftUI views with Liquid Glass design
- **ViewModels**: Business logic and state management
- **Services**: HealthKit, CoreMotion, achievements

### Key Services
| Service | Purpose |
|---------|---------|
| `HealthKitService` | Health data and workout saving |
| `PedometerService` | Step counting via CoreMotion |
| `WorkoutService` | HKWorkoutSession management |
| `AchievementService` | Badge unlocking logic |
| `StreakService` | Consecutive day tracking |
| `ShareService` | Shareable image generation |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write tests
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Acknowledgments

- Apple HealthKit and CoreMotion frameworks
- SF Symbols for iconography
- Inspired by Apple Fitness+ design patterns
