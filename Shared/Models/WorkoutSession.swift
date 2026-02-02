import Foundation
import HealthKit

/// Represents an active workout session
@MainActor
class WorkoutSession: ObservableObject {
    // MARK: - State
    
    enum State: Equatable {
        case notStarted
        case countdown(Int)
        case active
        case paused
        case ended
    }
    
    @Published var state: State = .notStarted
    @Published var activityType: ActivityType
    @Published var startDate: Date?
    @Published var elapsedTime: TimeInterval = 0
    @Published var pausedTime: TimeInterval = 0
    
    // MARK: - Live Metrics
    
    @Published var currentHeartRate: Int = 0
    @Published var averageHeartRate: Int = 0
    @Published var maxHeartRate: Int = 0
    @Published var calories: Double = 0
    @Published var distance: Double = 0
    @Published var steps: Int = 0
    @Published var laps: Int = 0
    @Published var currentPace: TimeInterval = 0 // seconds per km
    
    // MARK: - Splits
    
    @Published var splits: [Split] = []
    
    // MARK: - Timer
    
    private var timer: Timer?
    private var pauseStartDate: Date?
    
    // MARK: - Initialization
    
    init(activityType: ActivityType) {
        self.activityType = activityType
    }
    
    // MARK: - Session Control
    
    func startCountdown() {
        state = .countdown(3)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                if case .countdown(let count) = self.state {
                    if count > 1 {
                        self.state = .countdown(count - 1)
                    } else {
                        timer.invalidate()
                        self.start()
                    }
                }
            }
        }
    }
    
    func start() {
        startDate = Date()
        state = .active
        startTimer()
    }
    
    func pause() {
        guard state == .active else { return }
        state = .paused
        pauseStartDate = Date()
        timer?.invalidate()
    }
    
    func resume() {
        guard state == .paused else { return }
        
        if let pauseStart = pauseStartDate {
            pausedTime += Date().timeIntervalSince(pauseStart)
        }
        pauseStartDate = nil
        state = .active
        startTimer()
    }
    
    func end() -> Activity? {
        timer?.invalidate()
        state = .ended
        
        guard let startDate = startDate else { return nil }
        let endDate = Date()
        
        return Activity(
            type: activityType,
            startDate: startDate,
            endDate: endDate,
            calories: calories,
            distance: distance > 0 ? distance : nil,
            steps: steps > 0 ? steps : nil,
            averageHeartRate: averageHeartRate > 0 ? averageHeartRate : nil,
            maxHeartRate: maxHeartRate > 0 ? maxHeartRate : nil,
            laps: laps > 0 ? laps : nil
        )
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateElapsedTime()
            }
        }
    }
    
    private func updateElapsedTime() {
        guard let startDate = startDate else { return }
        elapsedTime = Date().timeIntervalSince(startDate) - pausedTime
        
        // Check for split completion (every km)
        if activityType.usesGPS && distance > 0 {
            let kmCompleted = Int(distance / 1000)
            if kmCompleted > splits.count {
                let splitTime = elapsedTime - splits.reduce(0) { $0 + $1.duration }
                splits.append(Split(
                    number: kmCompleted,
                    distance: 1000,
                    duration: splitTime
                ))
            }
        }
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
        if km >= 1 {
            return String(format: "%.2f", km)
        } else {
            return String(format: "%.0f m", distance)
        }
    }
    
    var formattedPace: String {
        guard currentPace > 0 else { return "--:--" }
        let minutes = Int(currentPace) / 60
        let seconds = Int(currentPace) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Split

struct Split: Identifiable, Codable {
    let id = UUID()
    let number: Int
    let distance: Double // meters
    let duration: TimeInterval
    
    var pace: TimeInterval {
        duration / (distance / 1000)
    }
    
    var formattedPace: String {
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
