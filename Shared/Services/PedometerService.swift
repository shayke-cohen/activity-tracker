import Foundation
import CoreMotion

/// Service for step counting using CoreMotion
@MainActor
class PedometerService: ObservableObject {
    static let shared = PedometerService()
    
    private let pedometer = CMPedometer()
    
    @Published var todaySteps: Int = 0
    @Published var todayDistance: Double = 0 // meters
    @Published var todayFloors: Int = 0
    @Published var isAuthorized = false
    @Published var isUpdating = false
    
    private init() {}
    
    // MARK: - Availability
    
    var isStepCountingAvailable: Bool {
        CMPedometer.isStepCountingAvailable()
    }
    
    var isDistanceAvailable: Bool {
        CMPedometer.isDistanceAvailable()
    }
    
    var isFloorCountingAvailable: Bool {
        CMPedometer.isFloorCountingAvailable()
    }
    
    // MARK: - Authorization
    
    func checkAuthorization() {
        switch CMPedometer.authorizationStatus() {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            // Will be requested when we start updates
            isAuthorized = false
        case .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    // MARK: - Query Historical Data
    
    /// Query step data for a date range
    func querySteps(from startDate: Date, to endDate: Date) async throws -> CMPedometerData? {
        guard isStepCountingAvailable else {
            throw PedometerError.notAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            pedometer.queryPedometerData(from: startDate, to: endDate) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: data)
                }
            }
        }
    }
    
    /// Query today's steps
    func queryTodaySteps() async throws -> Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let data = try await querySteps(from: startOfDay, to: Date())
        return data?.numberOfSteps.intValue ?? 0
    }
    
    // MARK: - Live Updates
    
    /// Start receiving live step updates
    func startUpdates() {
        guard isStepCountingAvailable else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        isUpdating = true
        
        pedometer.startUpdates(from: startOfDay) { [weak self] data, error in
            Task { @MainActor in
                guard let self = self, error == nil, let data = data else { return }
                
                self.isAuthorized = true
                self.todaySteps = data.numberOfSteps.intValue
                
                if let distance = data.distance {
                    self.todayDistance = distance.doubleValue
                }
                
                if let floors = data.floorsAscended {
                    self.todayFloors = floors.intValue
                }
            }
        }
    }
    
    /// Stop receiving live updates
    func stopUpdates() {
        pedometer.stopUpdates()
        isUpdating = false
    }
    
    // MARK: - Historical Data
    
    /// Get steps for the past week
    func getWeeklySteps() async throws -> [DailyStepData] {
        var weekData: [DailyStepData] = []
        let calendar = Calendar.current
        
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            if let data = try await querySteps(from: startOfDay, to: min(endOfDay, Date())) {
                weekData.append(DailyStepData(
                    date: startOfDay,
                    steps: data.numberOfSteps.intValue,
                    distance: data.distance?.doubleValue ?? 0,
                    floors: data.floorsAscended?.intValue ?? 0
                ))
            } else {
                weekData.append(DailyStepData(date: startOfDay, steps: 0, distance: 0, floors: 0))
            }
        }
        
        return weekData.reversed()
    }
}

// MARK: - Daily Step Data

struct DailyStepData: Identifiable {
    let id = UUID()
    let date: Date
    let steps: Int
    let distance: Double
    let floors: Int
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var formattedDistance: String {
        let km = distance / 1000
        return String(format: "%.1f km", km)
    }
}

// MARK: - Errors

enum PedometerError: Error, LocalizedError {
    case notAvailable
    case authorizationDenied
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Step counting is not available on this device"
        case .authorizationDenied:
            return "Motion & Fitness access was denied"
        }
    }
}
