import ActivityKit
import WidgetKit
import SwiftUI

/// Live Activity for active workouts
struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            // Lock Screen presentation
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color(context.attributes.activityColor))
                
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: context.attributes.activityIcon)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(context.attributes.activityName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(context.state.formattedElapsedTime)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        if let distance = context.state.formattedDistance {
                            Text(distance)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Distance")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    HStack(spacing: 20) {
                        if let hr = context.state.heartRate {
                            VStack {
                                HStack(spacing: 2) {
                                    Image(systemName: "heart.fill")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                    Text("\(hr)")
                                        .font(.headline)
                                }
                                Text("bpm")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        VStack {
                            Text("\(Int(context.state.calories))")
                                .font(.headline)
                            Text("cal")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let pace = context.state.formattedPace {
                            VStack {
                                Text(pace)
                                    .font(.headline)
                                Text("/km")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 20) {
                        // Pause button
                        Button(intent: PauseWorkoutIntent()) {
                            Image(systemName: context.state.isPaused ? "play.fill" : "pause.fill")
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
                        // Stop button
                        Button(intent: StopWorkoutIntent()) {
                            Image(systemName: "stop.fill")
                                .font(.title3)
                                .foregroundStyle(.red)
                                .frame(width: 44, height: 44)
                                .background(.red.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
            } compactLeading: {
                // Compact leading
                Image(systemName: context.attributes.activityIcon)
                    .foregroundStyle(Color(context.attributes.activityColor))
            } compactTrailing: {
                // Compact trailing
                Text(context.state.formattedElapsedTime)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            } minimal: {
                // Minimal (when two activities)
                Image(systemName: context.attributes.activityIcon)
                    .foregroundStyle(Color(context.attributes.activityColor))
            }
        }
    }
}

// MARK: - Lock Screen Live Activity View

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>
    
    var body: some View {
        HStack {
            // Left side - Activity info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: context.attributes.activityIcon)
                    Text(context.attributes.activityName)
                        .fontWeight(.semibold)
                    
                    if context.state.isPaused {
                        Text("PAUSED")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.orange.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                
                Text(context.state.formattedElapsedTime)
                    .font(.title)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            
            Spacer()
            
            // Right side - Metrics
            VStack(alignment: .trailing, spacing: 8) {
                if let distance = context.state.formattedDistance {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(distance)
                    }
                }
                
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("\(Int(context.state.calories)) cal")
                }
                
                if let hr = context.state.heartRate {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                        Text("\(hr) bpm")
                    }
                }
            }
            .font(.subheadline)
        }
        .padding()
    }
}

// MARK: - App Intents for Live Activity buttons

import AppIntents

struct PauseWorkoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Pause Workout"
    
    func perform() async throws -> some IntentResult {
        // Would communicate with main app to pause
        return .result()
    }
}

struct StopWorkoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Workout"
    
    func perform() async throws -> some IntentResult {
        // Would communicate with main app to stop
        return .result()
    }
}

// MARK: - Preview

#Preview("Live Activity", as: .content, using: WorkoutActivityAttributes(
    activityName: "Running",
    startTime: Date(),
    activityIcon: "figure.run",
    activityColor: "orange"
)) {
    WorkoutLiveActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState(
        activityType: .running,
        elapsedTime: 1965,
        calories: 342,
        distance: 4250,
        heartRate: 156,
        pace: 462,
        isPaused: false
    )
}
