import Foundation
import HealthKit
import WatchKit

/// Manages workouts on Apple Watch
@MainActor
class WatchWorkoutManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published var isWorkoutActive = false
    @Published var isPaused = false
    @Published var currentActivityType: ActivityType = .running
    
    // Metrics
    @Published var elapsedTime: TimeInterval = 0
    @Published var heartRate: Int = 0
    @Published var calories: Double = 0
    @Published var distance: Double = 0
    @Published var pace: TimeInterval = 0
    
    // MARK: - HealthKit
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    private var startDate: Date?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws {
        let typesToShare: Set<HKSampleType> = [
            HKObjectType.workoutType()
        ]
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.workoutType()
        ]
        
        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
    }
    
    // MARK: - Workout Control
    
    func startWorkout(type: ActivityType) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = type.healthKitType
        configuration.locationType = type.usesGPS ? .outdoor : .indoor
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            
            workoutSession?.delegate = self
            workoutBuilder?.delegate = self
            
            startDate = Date()
            currentActivityType = type
            
            workoutSession?.startActivity(with: startDate!)
            try await workoutBuilder?.beginCollection(at: startDate!)
            
            isWorkoutActive = true
            isPaused = false
            
            // Haptic feedback
            WKInterfaceDevice.current().play(.start)
            
        } catch {
            throw error
        }
    }
    
    func pauseWorkout() {
        workoutSession?.pause()
        isPaused = true
        WKInterfaceDevice.current().play(.stop)
    }
    
    func resumeWorkout() {
        workoutSession?.resume()
        isPaused = false
        WKInterfaceDevice.current().play(.start)
    }
    
    func endWorkout() async {
        workoutSession?.end()
        
        guard let builder = workoutBuilder else { return }
        
        do {
            try await builder.endCollection(at: Date())
            try await builder.finishWorkout()
        } catch {
            print("Error ending workout: \(error)")
        }
        
        WKInterfaceDevice.current().play(.success)
        
        resetWorkout()
    }
    
    func discardWorkout() async {
        workoutSession?.end()
        try? await workoutBuilder?.discardWorkout()
        resetWorkout()
    }
    
    private func resetWorkout() {
        workoutSession = nil
        workoutBuilder = nil
        isWorkoutActive = false
        isPaused = false
        elapsedTime = 0
        heartRate = 0
        calories = 0
        distance = 0
        pace = 0
        startDate = nil
    }
    
    // MARK: - Formatted Values
    
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
    
    var formattedDistance: String {
        let km = distance / 1000
        return String(format: "%.2f", km)
    }
    
    var formattedPace: String {
        guard pace > 0 else { return "--:--" }
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - HKWorkoutSessionDelegate

extension WatchWorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        Task { @MainActor in
            switch toState {
            case .running:
                isPaused = false
            case .paused:
                isPaused = true
            case .ended:
                isWorkoutActive = false
            default:
                break
            }
        }
    }
    
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension WatchWorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            let statistics = workoutBuilder.statistics(for: quantityType)
            
            Task { @MainActor in
                updateMetrics(from: statistics, for: quantityType)
            }
        }
    }
    
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Handle workout events
    }
    
    @MainActor
    private func updateMetrics(from statistics: HKStatistics?, for type: HKQuantityType) {
        guard let statistics = statistics else { return }
        
        switch type {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            if let value = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) {
                heartRate = Int(value)
            }
            
        case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
            if let value = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) {
                calories = value
            }
            
        case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
             HKQuantityType.quantityType(forIdentifier: .distanceCycling):
            if let value = statistics.sumQuantity()?.doubleValue(for: .meter()) {
                distance = value
                
                // Calculate pace
                if let start = startDate, distance > 0 {
                    let elapsed = Date().timeIntervalSince(start)
                    pace = elapsed / (distance / 1000)
                    elapsedTime = elapsed
                }
            }
            
        default:
            break
        }
    }
}
