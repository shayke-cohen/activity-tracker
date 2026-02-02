import Foundation

/// Tracks user's activity streak
struct StreakData: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: Date?
    var weeklyGoalsMet: Int
    var totalActiveDays: Int
    
    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastActiveDate: Date? = nil,
        weeklyGoalsMet: Int = 0,
        totalActiveDays: Int = 0
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActiveDate = lastActiveDate
        self.weeklyGoalsMet = weeklyGoalsMet
        self.totalActiveDays = totalActiveDays
    }
    
    /// Check if streak is still active (last activity was today or yesterday)
    var isStreakActive: Bool {
        guard let lastActive = lastActiveDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActiveDay = calendar.startOfDay(for: lastActive)
        let daysDifference = calendar.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0
        return daysDifference <= 1
    }
    
    /// Check if today has activity recorded
    var hasActivityToday: Bool {
        guard let lastActive = lastActiveDate else { return false }
        return Calendar.current.isDateInToday(lastActive)
    }
    
    /// Days until streak is lost
    var daysUntilStreakLost: Int {
        guard let lastActive = lastActiveDate else { return 0 }
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: lastActive))!
        let endOfTomorrow = calendar.date(byAdding: .day, value: 1, to: tomorrow)!
        let now = Date()
        
        if now >= endOfTomorrow {
            return 0
        } else if now >= tomorrow {
            return 1
        } else {
            return 2
        }
    }
    
    /// Update streak after completing an activity
    mutating func recordActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastActive = lastActiveDate {
            let lastActiveDay = calendar.startOfDay(for: lastActive)
            let daysDifference = calendar.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0
            
            if daysDifference == 0 {
                // Already recorded today, no change
                return
            } else if daysDifference == 1 {
                // Consecutive day, increment streak
                currentStreak += 1
            } else {
                // Streak broken, start new
                currentStreak = 1
            }
        } else {
            // First activity ever
            currentStreak = 1
        }
        
        // Update records
        lastActiveDate = Date()
        totalActiveDays += 1
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }
    
    /// Check and update streak at app launch
    mutating func checkStreakStatus() {
        guard let lastActive = lastActiveDate else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActiveDay = calendar.startOfDay(for: lastActive)
        let daysDifference = calendar.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0
        
        // If more than 1 day has passed, streak is broken
        if daysDifference > 1 {
            currentStreak = 0
        }
    }
}

// MARK: - Sample Data

extension StreakData {
    static let sample = StreakData(
        currentStreak: 14,
        longestStreak: 42,
        lastActiveDate: Date(),
        weeklyGoalsMet: 8,
        totalActiveDays: 156
    )
}
