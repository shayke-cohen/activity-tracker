import Foundation
import HealthKit

/// Service for managing workout sessions
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
    
    /// Start a new workout session
    func startWorkout(type: ActivityType) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = type.healthKitType
        configuration.locationType = type.usesGPS ? .outdoor : .indoor
        
        // For swimming
        if type == .swimming {
            configuration.swimmingLocationType = .pool
            configuration.lapLength = HKQuantity(unit: .meter(), doubleValue: 25) // Standard pool
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
            
            // Create our workout session model
            currentWorkout = WorkoutSession(activityType: type)
            currentWorkout?.start()
            isWorkoutActive = true
            
            // Start Live Activity
            if let workout = currentWorkout {
                await LiveActivityManager.shared.startActivity(for: workout)
            }
            
        } catch {
            throw WorkoutError.failedToStart(error)
        }
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
        guard let session = workoutSession, let builder = workoutBuilder else {
            throw WorkoutError.noActiveWorkout
        }
        
        // End HK session
        session.end()
        
        // End collection and save
        let endDate = Date()
        try await builder.endCollection(at: endDate)
        
        // Get the final workout
        do {
            try await builder.finishWorkout()
        } catch {
            print("Error finishing workout: \(error)")
        }
        
        // Get our activity from the session
        let activity = currentWorkout?.end()
        
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
        workoutSession?.end()
        try? await workoutBuilder?.discardWorkout()
        
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
        // Handle collected data
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
