import Foundation
import HealthKit

/// Service for interacting with HealthKit
@MainActor
class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var authorizationError: Error?
    
    private init() {}
    
    // MARK: - Authorization
    
    /// Types we want to read from HealthKit
    private var readTypes: Set<HKObjectType> {
        Set([
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .swimmingStrokeCount)!,
        ])
    }
    
    /// Types we want to write to HealthKit
    private var writeTypes: Set<HKSampleType> {
        Set([
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
        ])
    }
    
    /// Request authorization for HealthKit access
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
            isAuthorized = true
        } catch {
            authorizationError = error
            throw error
        }
    }
    
    // MARK: - Heart Rate
    
    /// Query current heart rate
    func queryHeartRate() async throws -> Int? {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let heartRate = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
                continuation.resume(returning: heartRate)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Active Calories
    
    /// Query active calories burned today
    func queryTodayCalories() async throws -> Double {
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: calorieType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let calories = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: calories)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Steps
    
    /// Query steps for today
    func queryTodaySteps() async throws -> Int {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let steps = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                continuation.resume(returning: steps)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Save Workout
    
    /// Save a completed workout to HealthKit
    func saveWorkout(_ activity: Activity) async throws {
        let workout = HKWorkout(
            activityType: activity.type.healthKitType,
            start: activity.startDate,
            end: activity.endDate,
            duration: activity.duration,
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: activity.calories),
            totalDistance: activity.distance.map { HKQuantity(unit: .meter(), doubleValue: $0) },
            metadata: nil
        )
        
        try await healthStore.save(workout)
    }
    
    // MARK: - Query Workouts
    
    /// Query workouts for a date range
    func queryWorkouts(from startDate: Date, to endDate: Date) async throws -> [HKWorkout] {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let workouts = samples as? [HKWorkout] ?? []
                continuation.resume(returning: workouts)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// Query workouts and convert to Activity models
    func queryActivities(from startDate: Date, to endDate: Date) async throws -> [Activity] {
        let hkWorkouts = try await queryWorkouts(from: startDate, to: endDate)
        return hkWorkouts.compactMap { Activity(from: $0) }
    }
    
    /// Query today's workouts
    func queryTodayWorkouts() async throws -> [Activity] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return try await queryActivities(from: startOfDay, to: Date())
    }
    
    /// Query recent workouts (last 7 days)
    func queryRecentWorkouts(limit: Int = 10) async throws -> [Activity] {
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let activities = try await queryActivities(from: startDate, to: Date())
        return Array(activities.prefix(limit))
    }
    
    /// Query workouts for past N days
    func queryWorkouts(days: Int) async throws -> [Activity] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return try await queryActivities(from: startDate, to: Date())
    }
    
    /// Query today's exercise minutes
    func queryTodayExerciseMinutes() async throws -> Double {
        let workouts = try await queryTodayWorkouts()
        let totalSeconds = workouts.reduce(0.0) { $0 + $1.duration }
        return totalSeconds / 60
    }
    
    /// Query today's total distance (walking + running)
    func queryTodayDistance() async throws -> Double {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let distance = result?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                continuation.resume(returning: distance)
            }
            
            healthStore.execute(query)
        }
    }
}

// MARK: - Errors

enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case authorizationDenied
    case queryFailed
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .authorizationDenied:
            return "HealthKit authorization was denied"
        case .queryFailed:
            return "Failed to query HealthKit data"
        }
    }
}
