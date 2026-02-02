import Foundation

/// Service for managing activity streaks
@MainActor
class StreakService: ObservableObject {
    static let shared = StreakService()
    
    @Published var streakData: StreakData
    
    private let userDefaults = UserDefaults.standard
    private let streakKey = "streakData"
    
    private init() {
        // Load saved streak data
        if let data = userDefaults.data(forKey: streakKey),
           let streak = try? JSONDecoder().decode(StreakData.self, from: data) {
            streakData = streak
        } else {
            streakData = StreakData()
        }
        
        // Check if streak is still valid
        streakData.checkStreakStatus()
        save()
    }
    
    // MARK: - Persistence
    
    private func save() {
        if let data = try? JSONEncoder().encode(streakData) {
            userDefaults.set(data, forKey: streakKey)
        }
    }
    
    // MARK: - Record Activity
    
    /// Record that user completed an activity today
    func recordActivity() {
        streakData.recordActivity()
        save()
    }
    
    // MARK: - Computed Properties
    
    var currentStreak: Int {
        streakData.currentStreak
    }
    
    var longestStreak: Int {
        streakData.longestStreak
    }
    
    var isStreakActive: Bool {
        streakData.isStreakActive
    }
    
    var hasActivityToday: Bool {
        streakData.hasActivityToday
    }
    
    var daysUntilStreakLost: Int {
        streakData.daysUntilStreakLost
    }
    
    // MARK: - Streak Status
    
    var streakStatus: StreakStatus {
        if hasActivityToday {
            return .completedToday
        } else if isStreakActive {
            return .atRisk(daysRemaining: daysUntilStreakLost)
        } else {
            return .broken
        }
    }
    
    /// Get streak message for UI
    var streakMessage: String {
        switch streakStatus {
        case .completedToday:
            return "Great job! You're on a \(currentStreak)-day streak!"
        case .atRisk(let days):
            if days == 1 {
                return "Complete a workout today to keep your streak!"
            } else {
                return "You have \(days) days to keep your streak going"
            }
        case .broken:
            return "Start a new streak today!"
        }
    }
    
    // MARK: - Weekly Goals
    
    /// Record that user met their weekly goal
    func recordWeeklyGoalMet() {
        streakData.weeklyGoalsMet += 1
        save()
    }
}

// MARK: - Streak Status

enum StreakStatus: Equatable {
    case completedToday
    case atRisk(daysRemaining: Int)
    case broken
}
