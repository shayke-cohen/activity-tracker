import Foundation
import ActivityKit

/// Attributes for Live Activity during a workout
struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var activityType: ActivityType
        var elapsedTime: TimeInterval
        var calories: Double
        var distance: Double?
        var heartRate: Int?
        var pace: TimeInterval?
        var isPaused: Bool
        
        var formattedElapsedTime: String {
            let hours = Int(elapsedTime) / 3600
            let minutes = (Int(elapsedTime) % 3600) / 60
            let seconds = Int(elapsedTime) % 60
            
            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d", minutes, seconds)
            }
        }
        
        var formattedDistance: String? {
            guard let distance = distance else { return nil }
            let km = distance / 1000
            if km >= 1 {
                return String(format: "%.2f km", km)
            } else {
                return String(format: "%.0f m", distance)
            }
        }
        
        var formattedPace: String? {
            guard let pace = pace, pace > 0 else { return nil }
            let minutes = Int(pace) / 60
            let seconds = Int(pace) % 60
            return String(format: "%d:%02d /km", minutes, seconds)
        }
        
        var formattedCalories: String {
            String(format: "%.0f cal", calories)
        }
        
        var formattedHeartRate: String? {
            guard let hr = heartRate else { return nil }
            return "\(hr) bpm"
        }
    }
    
    // Fixed attributes that don't change during the activity
    var activityName: String
    var startTime: Date
    var activityIcon: String
    var activityColor: String
}

// MARK: - Live Activity Manager

@MainActor
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    private var currentActivity: ActivityKit.Activity<WorkoutActivityAttributes>?
    
    private init() {}
    
    var isActivityActive: Bool {
        currentActivity != nil
    }
    
    func startActivity(for workout: WorkoutSession) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        let attributes = WorkoutActivityAttributes(
            activityName: workout.activityType.displayName,
            startTime: workout.startDate ?? Date(),
            activityIcon: workout.activityType.icon,
            activityColor: workout.activityType.color.description
        )
        
        let initialState = WorkoutActivityAttributes.ContentState(
            activityType: workout.activityType,
            elapsedTime: 0,
            calories: 0,
            distance: nil,
            heartRate: nil,
            pace: nil,
            isPaused: false
        )
        
        do {
            let activity = try ActivityKit.Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            print("Started Live Activity: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    func updateActivity(with state: WorkoutActivityAttributes.ContentState) async {
        guard let activity = currentActivity else { return }
        
        await activity.update(
            ActivityContent(state: state, staleDate: Date().addingTimeInterval(60))
        )
    }
    
    func endActivity() async {
        guard let activity = currentActivity else { return }
        
        let finalState = WorkoutActivityAttributes.ContentState(
            activityType: .other,
            elapsedTime: 0,
            calories: 0,
            distance: nil,
            heartRate: nil,
            pace: nil,
            isPaused: false
        )
        
        await activity.end(
            ActivityContent(state: finalState, staleDate: nil),
            dismissalPolicy: .immediate
        )
        
        currentActivity = nil
    }
}
