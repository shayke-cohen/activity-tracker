import Foundation
import HealthKit

/// Represents a completed workout/activity
struct Activity: Identifiable, Codable, Hashable {
    let id: UUID
    let type: ActivityType
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    
    // MARK: - Metrics
    var calories: Double
    var distance: Double? // in meters
    var steps: Int?
    var averageHeartRate: Int?
    var maxHeartRate: Int?
    var laps: Int? // for swimming
    
    // MARK: - Location
    var locationName: String?
    var routeData: Data? // Encoded CLLocation array
    
    // MARK: - Computed Properties
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
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
    
    var pace: TimeInterval? {
        guard let distance = distance, distance > 0 else { return nil }
        let km = distance / 1000
        return duration / km // seconds per km
    }
    
    var formattedPace: String? {
        guard let pace = pace else { return nil }
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d:%02d /km", minutes, seconds)
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        type: ActivityType,
        startDate: Date,
        endDate: Date,
        calories: Double = 0,
        distance: Double? = nil,
        steps: Int? = nil,
        averageHeartRate: Int? = nil,
        maxHeartRate: Int? = nil,
        laps: Int? = nil,
        locationName: String? = nil,
        routeData: Data? = nil
    ) {
        self.id = id
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.duration = endDate.timeIntervalSince(startDate)
        self.calories = calories
        self.distance = distance
        self.steps = steps
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.laps = laps
        self.locationName = locationName
        self.routeData = routeData
    }
    
    /// Initialize from HealthKit HKWorkout
    init?(from hkWorkout: HKWorkout) {
        self.id = UUID()
        self.type = ActivityType(from: hkWorkout.workoutActivityType) ?? .other
        self.startDate = hkWorkout.startDate
        self.endDate = hkWorkout.endDate
        self.duration = hkWorkout.duration
        self.calories = hkWorkout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
        self.distance = hkWorkout.totalDistance?.doubleValue(for: .meter())
        self.steps = nil // Would need to query separately
        self.averageHeartRate = nil // Would need to query from workout samples
        self.maxHeartRate = nil
        // Get swimming stroke count as laps
        if let strokeCount = hkWorkout.totalSwimmingStrokeCount {
            self.laps = Int(strokeCount.doubleValue(for: HKUnit.count()))
        } else {
            self.laps = nil
        }
        self.locationName = nil
        self.routeData = nil
    }
}

// MARK: - Sample Data

extension Activity {
    static let sampleRun = Activity(
        type: .running,
        startDate: Date().addingTimeInterval(-1965), // ~32:45 ago
        endDate: Date(),
        calories: 342,
        distance: 4250,
        averageHeartRate: 156,
        maxHeartRate: 178,
        locationName: "Central Park"
    )
    
    static let sampleSwim = Activity(
        type: .swimming,
        startDate: Date().addingTimeInterval(-1710), // ~28:30 ago
        endDate: Date(),
        calories: 380,
        distance: 1200,
        averageHeartRate: 142,
        laps: 48
    )
    
    static let sampleCycle = Activity(
        type: .cycling,
        startDate: Date().addingTimeInterval(-2700), // 45 min ago
        endDate: Date(),
        calories: 520,
        distance: 12500,
        averageHeartRate: 142,
        maxHeartRate: 165
    )
}
