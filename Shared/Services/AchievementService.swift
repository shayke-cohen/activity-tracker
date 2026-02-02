import Foundation
import SwiftUI

/// Service for managing achievements and badges
@MainActor
class AchievementService: ObservableObject {
    static let shared = AchievementService()
    
    @Published var unlockedAchievements: [UnlockedAchievement] = []
    @Published var recentlyUnlocked: Achievement?
    
    private let userDefaults = UserDefaults.standard
    private let unlockedKey = "unlockedAchievements"
    
    // Stats for checking achievements
    @Published var totalWorkouts: Int = 0
    @Published var totalDistance: Double = 0
    @Published var totalSteps: Int = 0
    @Published var morningWorkouts: Int = 0
    @Published var weekendWorkouts: Int = 0
    @Published var differentActivities: Set<ActivityType> = []
    
    private init() {
        loadUnlockedAchievements()
    }
    
    // MARK: - Persistence
    
    private func loadUnlockedAchievements() {
        if let data = userDefaults.data(forKey: unlockedKey),
           let unlocked = try? JSONDecoder().decode([UnlockedAchievement].self, from: data) {
            unlockedAchievements = unlocked
        }
    }
    
    private func saveUnlockedAchievements() {
        if let data = try? JSONEncoder().encode(unlockedAchievements) {
            userDefaults.set(data, forKey: unlockedKey)
        }
    }
    
    // MARK: - Check Achievements
    
    /// Check for newly unlocked achievements after a workout
    func checkAchievements(for activity: Activity, streak: StreakData) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []
        
        // Update stats
        totalWorkouts += 1
        totalDistance += activity.distance ?? 0
        totalSteps += activity.steps ?? 0
        differentActivities.insert(activity.type)
        
        // Check if morning workout (before 8 AM)
        let hour = Calendar.current.component(.hour, from: activity.startDate)
        if hour < 8 {
            morningWorkouts += 1
        }
        
        // Check if weekend
        let weekday = Calendar.current.component(.weekday, from: activity.startDate)
        if weekday == 1 || weekday == 7 {
            weekendWorkouts += 1
        }
        
        // Check each achievement
        for achievement in Achievement.allAchievements {
            // Skip if already unlocked
            if isUnlocked(achievement) { continue }
            
            if checkRequirement(achievement.requirement, activity: activity, streak: streak) {
                unlock(achievement, value: getValueForRequirement(achievement.requirement, activity: activity))
                newlyUnlocked.append(achievement)
            }
        }
        
        return newlyUnlocked
    }
    
    private func checkRequirement(_ requirement: AchievementRequirement, activity: Activity, streak: StreakData) -> Bool {
        switch requirement {
        case .totalWorkouts(let count):
            return totalWorkouts >= count
            
        case .totalDistance(let meters):
            return totalDistance >= meters
            
        case .totalSteps(let count):
            return totalSteps >= count
            
        case .streakDays(let days):
            return streak.currentStreak >= days
            
        case .singleWorkoutDistance(let meters, let type):
            return activity.type == type && (activity.distance ?? 0) >= meters
            
        case .singleWorkoutDuration(let duration, let type):
            return activity.type == type && activity.duration >= duration
            
        case .morningWorkouts(let count):
            return morningWorkouts >= count
            
        case .weekendWorkouts(let count):
            return weekendWorkouts >= count
            
        case .differentActivities(let count):
            return differentActivities.count >= count
            
        case .laps(let count):
            return (activity.laps ?? 0) >= count
            
        case .calories(let cal):
            return activity.calories >= cal
            
        case .workoutsInWeek:
            return false // Would need weekly tracking
        }
    }
    
    private func getValueForRequirement(_ requirement: AchievementRequirement, activity: Activity) -> Double? {
        switch requirement {
        case .singleWorkoutDistance:
            return activity.distance
        case .singleWorkoutDuration:
            return activity.duration
        case .laps:
            return Double(activity.laps ?? 0)
        case .calories:
            return activity.calories
        default:
            return nil
        }
    }
    
    // MARK: - Unlock
    
    private func unlock(_ achievement: Achievement, value: Double? = nil) {
        let unlocked = UnlockedAchievement(achievement: achievement, value: value)
        unlockedAchievements.append(unlocked)
        saveUnlockedAchievements()
        
        // Set as recently unlocked for UI notification
        recentlyUnlocked = achievement
        
        // Clear after a delay
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            if recentlyUnlocked?.id == achievement.id {
                recentlyUnlocked = nil
            }
        }
    }
    
    // MARK: - Query
    
    func isUnlocked(_ achievement: Achievement) -> Bool {
        unlockedAchievements.contains { $0.achievementId == achievement.id }
    }
    
    func unlockedDate(for achievement: Achievement) -> Date? {
        unlockedAchievements.first { $0.achievementId == achievement.id }?.unlockedDate
    }
    
    func unlockedCount() -> Int {
        unlockedAchievements.count
    }
    
    func totalCount() -> Int {
        Achievement.allAchievements.count
    }
    
    /// Get achievements grouped by category
    func achievementsByCategory() -> [AchievementCategory: [Achievement]] {
        Dictionary(grouping: Achievement.allAchievements, by: { $0.category })
    }
    
    /// Get recently unlocked achievements
    func recentUnlocks(limit: Int = 5) -> [UnlockedAchievement] {
        Array(unlockedAchievements.sorted { $0.unlockedDate > $1.unlockedDate }.prefix(limit))
    }
}
