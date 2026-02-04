import Foundation
import HealthKit

/// Service for managing workout sessions with iOS 26 HKLiveWorkoutBuilder
@MainActor
class WorkoutService: ObservableObject {
    static let shared = WorkoutService()
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    
    @Published var currentWorkout: WorkoutSession?
    @Published var isWorkoutActive = false
    
    private init() {}
    
    // MARK: - Start Workout
    
    /// Start a new workout session with HKLiveWorkoutBuilder
    /// Falls back to local-only mode if HealthKit is unavailable
    func startWorkout(type: ActivityType) async throws {
        print("DEBUG: [WorkoutService] startWorkout called for \(type.displayName)")
        
        // Always create our local workout session first
        currentWorkout = WorkoutSession(activityType: type)
        print("DEBUG: [WorkoutService] Created WorkoutSession: \(String(describing: currentWorkout))")
        
        currentWorkout?.start()
        print("DEBUG: [WorkoutService] WorkoutSession started")
        
        isWorkoutActive = true
        print("DEBUG: [WorkoutService] isWorkoutActive = true")
        
        // Try to set up HealthKit integration
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = type.healthKitType
        configuration.locationType = type.usesGPS ? .outdoor : .indoor
        
        // For swimming
        if type == .swimming {
            configuration.swimmingLocationType = .pool
            configuration.lapLength = HKQuantity(unit: .meter(), doubleValue: 25)
        }
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            
            // Set up delegate callbacks
            workoutSession?.delegate = WorkoutSessionDelegate.shared
            workoutBuilder?.delegate = WorkoutBuilderDelegate.shared
            
            // Start the session
            let startDate = Date()
            workoutSession?.startActivity(with: startDate)
            try await workoutBuilder?.beginCollection(at: startDate)
            
        } catch {
            // HealthKit failed - continue in local-only mode
            print("DEBUG: [WorkoutService] HealthKit unavailable, running in local-only mode: \(error)")
            workoutSession = nil
            workoutBuilder = nil
        }
        
        print("DEBUG: [WorkoutService] HealthKit setup complete (session: \(workoutSession != nil), builder: \(workoutBuilder != nil))")
        
        // Start Live Activity
        if let workout = currentWorkout {
            print("DEBUG: [WorkoutService] Starting Live Activity...")
            await LiveActivityManager.shared.startActivity(for: workout)
            print("DEBUG: [WorkoutService] Live Activity started")
        }
        
        print("DEBUG: [WorkoutService] startWorkout completed successfully")
    }
    
    // MARK: - Pause/Resume
    
    func pauseWorkout() {
        workoutSession?.pause()
        currentWorkout?.pause()
        
        Task {
            await updateLiveActivity()
        }
    }
    
    func resumeWorkout() {
        workoutSession?.resume()
        currentWorkout?.resume()
        
        Task {
            await updateLiveActivity()
        }
    }
    
    // MARK: - End Workout
    
    func endWorkout() async throws -> Activity? {
        // Ensure we have an active workout
        guard currentWorkout != nil else {
            throw WorkoutError.noActiveWorkout
        }
        
        // Try to end HealthKit session if it exists
        if let session = workoutSession, let builder = workoutBuilder {
            // End HK session
            session.end()
            
            // End collection and save
            let endDate = Date()
            do {
                try await builder.endCollection(at: endDate)
                try await builder.finishWorkout()
            } catch {
                print("Error finishing HealthKit workout: \(error)")
            }
        }
        
        // Get our activity from the session (works regardless of HealthKit)
        let activity = currentWorkout?.end()
        
        // Save to local storage
        if let activity = activity {
            WorkoutStorageService.shared.saveWorkout(activity)
            
            // Update streak
            StreakService.shared.recordActivity()
            
            // Check for achievements
            let streak = StreakService.shared.streakData
            _ = AchievementService.shared.checkAchievements(for: activity, streak: streak)
        }
        
        // End Live Activity
        await LiveActivityManager.shared.endActivity()
        
        // Clean up
        workoutSession = nil
        workoutBuilder = nil
        currentWorkout = nil
        isWorkoutActive = false
        
        return activity
    }
    
    // MARK: - Discard Workout
    
    func discardWorkout() async {
        // End HealthKit session if it exists
        if let session = workoutSession {
            session.end()
        }
        if let builder = workoutBuilder {
            try? await builder.discardWorkout()
        }
        
        await LiveActivityManager.shared.endActivity()
        
        workoutSession = nil
        workoutBuilder = nil
        currentWorkout = nil
        isWorkoutActive = false
    }
    
    // MARK: - Update Metrics
    
    func updateMetrics(heartRate: Int?, calories: Double?, distance: Double?) {
        guard let workout = currentWorkout else { return }
        
        if let hr = heartRate {
            workout.currentHeartRate = hr
            if hr > workout.maxHeartRate {
                workout.maxHeartRate = hr
            }
        }
        
        if let cal = calories {
            workout.calories = cal
        }
        
        if let dist = distance {
            workout.distance = dist
            // Calculate pace
            if dist > 0 && workout.elapsedTime > 0 {
                workout.currentPace = workout.elapsedTime / (dist / 1000)
            }
        }
        
        Task {
            await updateLiveActivity()
        }
    }
    
    // MARK: - Live Activity
    
    private func updateLiveActivity() async {
        guard let workout = currentWorkout else { return }
        
        let state = WorkoutActivityAttributes.ContentState(
            activityType: workout.activityType,
            elapsedTime: workout.elapsedTime,
            calories: workout.calories,
            distance: workout.distance > 0 ? workout.distance : nil,
            heartRate: workout.currentHeartRate > 0 ? workout.currentHeartRate : nil,
            pace: workout.currentPace > 0 ? workout.currentPace : nil,
            isPaused: workout.state == .paused
        )
        
        await LiveActivityManager.shared.updateActivity(with: state)
    }
}

// MARK: - Workout Session Delegate

class WorkoutSessionDelegate: NSObject, HKWorkoutSessionDelegate {
    static let shared = WorkoutSessionDelegate()
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("Workout state changed: \(fromState.rawValue) -> \(toState.rawValue)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error)")
    }
}

// MARK: - Workout Builder Delegate

class WorkoutBuilderDelegate: NSObject, HKLiveWorkoutBuilderDelegate {
    static let shared = WorkoutBuilderDelegate()
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            
            Task { @MainActor in
                switch quantityType {
                case HKQuantityType.quantityType(forIdentifier: .heartRate):
                    if let heartRate = statistics?.mostRecentQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) {
                        WorkoutService.shared.updateMetrics(heartRate: Int(heartRate), calories: nil, distance: nil)
                    }
                case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                    if let calories = statistics?.sumQuantity()?.doubleValue(for: .kilocalorie()) {
                        WorkoutService.shared.updateMetrics(heartRate: nil, calories: calories, distance: nil)
                    }
                case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
                     HKQuantityType.quantityType(forIdentifier: .distanceCycling),
                     HKQuantityType.quantityType(forIdentifier: .distanceSwimming):
                    if let distance = statistics?.sumQuantity()?.doubleValue(for: .meter()) {
                        WorkoutService.shared.updateMetrics(heartRate: nil, calories: nil, distance: distance)
                    }
                default:
                    break
                }
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Handle workout events (lap, pause, etc.)
    }
}

// MARK: - Errors

enum WorkoutError: Error, LocalizedError {
    case failedToStart(Error)
    case noActiveWorkout
    case failedToEnd
    
    var errorDescription: String? {
        switch self {
        case .failedToStart(let error):
            return "Failed to start workout: \(error.localizedDescription)"
        case .noActiveWorkout:
            return "No active workout to end"
        case .failedToEnd:
            return "Failed to end workout"
        }
    }
}
