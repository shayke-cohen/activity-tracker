import Foundation
import SwiftUI

/// Achievement badge definition
struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let category: AchievementCategory
    let icon: String
    let requirement: AchievementRequirement
    
    var color: Color {
        category.color
    }
}

// MARK: - Achievement Category

enum AchievementCategory: String, Codable, CaseIterable {
    case milestone
    case streak
    case personalBest
    case consistency
    case activitySpecific
    
    var displayName: String {
        switch self {
        case .milestone: return "Milestones"
        case .streak: return "Streaks"
        case .personalBest: return "Personal Bests"
        case .consistency: return "Consistency"
        case .activitySpecific: return "Activity"
        }
    }
    
    var color: Color {
        switch self {
        case .milestone: return .yellow
        case .streak: return .orange
        case .personalBest: return .purple
        case .consistency: return .green
        case .activitySpecific: return .blue
        }
    }
}

// MARK: - Achievement Requirement

enum AchievementRequirement: Codable, Hashable {
    case totalWorkouts(Int)
    case totalDistance(Double) // meters
    case totalSteps(Int)
    case streakDays(Int)
    case singleWorkoutDistance(Double, ActivityType)
    case singleWorkoutDuration(TimeInterval, ActivityType)
    case workoutsInWeek(Int)
    case morningWorkouts(Int)
    case weekendWorkouts(Int)
    case differentActivities(Int)
    case laps(Int)
    case calories(Double)
}

// MARK: - Unlocked Achievement

struct UnlockedAchievement: Identifiable, Codable {
    let id: UUID
    let achievementId: String
    let unlockedDate: Date
    let value: Double? // The value that triggered the unlock
    
    init(achievement: Achievement, value: Double? = nil) {
        self.id = UUID()
        self.achievementId = achievement.id
        self.unlockedDate = Date()
        self.value = value
    }
}

// MARK: - Predefined Achievements

extension Achievement {
    static let allAchievements: [Achievement] = [
        // Milestones
        Achievement(
            id: "first_workout",
            name: "First Steps",
            description: "Complete your first workout",
            category: .milestone,
            icon: "star.fill",
            requirement: .totalWorkouts(1)
        ),
        Achievement(
            id: "10_workouts",
            name: "Getting Started",
            description: "Complete 10 workouts",
            category: .milestone,
            icon: "flame.fill",
            requirement: .totalWorkouts(10)
        ),
        Achievement(
            id: "50_workouts",
            name: "Dedicated",
            description: "Complete 50 workouts",
            category: .milestone,
            icon: "medal.fill",
            requirement: .totalWorkouts(50)
        ),
        Achievement(
            id: "100_workouts",
            name: "Centurion",
            description: "Complete 100 workouts",
            category: .milestone,
            icon: "trophy.fill",
            requirement: .totalWorkouts(100)
        ),
        Achievement(
            id: "1000km",
            name: "Distance Champion",
            description: "Cover 1,000 km total",
            category: .milestone,
            icon: "map.fill",
            requirement: .totalDistance(1_000_000)
        ),
        
        // Streaks
        Achievement(
            id: "streak_7",
            name: "Week Warrior",
            description: "Maintain a 7-day streak",
            category: .streak,
            icon: "flame.fill",
            requirement: .streakDays(7)
        ),
        Achievement(
            id: "streak_30",
            name: "Monthly Master",
            description: "Maintain a 30-day streak",
            category: .streak,
            icon: "flame.circle.fill",
            requirement: .streakDays(30)
        ),
        Achievement(
            id: "streak_100",
            name: "Unstoppable",
            description: "Maintain a 100-day streak",
            category: .streak,
            icon: "bolt.circle.fill",
            requirement: .streakDays(100)
        ),
        
        // Personal Bests - Running
        Achievement(
            id: "5k_run",
            name: "5K Runner",
            description: "Run 5 km in a single workout",
            category: .personalBest,
            icon: "figure.run",
            requirement: .singleWorkoutDistance(5000, .running)
        ),
        Achievement(
            id: "10k_run",
            name: "10K Runner",
            description: "Run 10 km in a single workout",
            category: .personalBest,
            icon: "figure.run",
            requirement: .singleWorkoutDistance(10000, .running)
        ),
        Achievement(
            id: "half_marathon",
            name: "Half Marathoner",
            description: "Run 21.1 km in a single workout",
            category: .personalBest,
            icon: "figure.run",
            requirement: .singleWorkoutDistance(21100, .running)
        ),
        Achievement(
            id: "marathon",
            name: "Marathoner",
            description: "Run 42.2 km in a single workout",
            category: .personalBest,
            icon: "figure.run.circle.fill",
            requirement: .singleWorkoutDistance(42200, .running)
        ),
        
        // Personal Bests - Cycling
        Achievement(
            id: "century_ride",
            name: "Century Rider",
            description: "Cycle 100 km in a single ride",
            category: .activitySpecific,
            icon: "figure.outdoor.cycle",
            requirement: .singleWorkoutDistance(100000, .cycling)
        ),
        
        // Personal Bests - Swimming
        Achievement(
            id: "100_laps",
            name: "Pool Shark",
            description: "Swim 100 laps in a single session",
            category: .activitySpecific,
            icon: "figure.pool.swim",
            requirement: .laps(100)
        ),
        
        // Consistency
        Achievement(
            id: "early_bird",
            name: "Early Bird",
            description: "Complete 5 workouts before 8 AM",
            category: .consistency,
            icon: "sunrise.fill",
            requirement: .morningWorkouts(5)
        ),
        Achievement(
            id: "weekend_warrior",
            name: "Weekend Warrior",
            description: "Complete 10 weekend workouts",
            category: .consistency,
            icon: "calendar.badge.checkmark",
            requirement: .weekendWorkouts(10)
        ),
        Achievement(
            id: "variety",
            name: "Jack of All Trades",
            description: "Try 5 different activities",
            category: .consistency,
            icon: "star.circle.fill",
            requirement: .differentActivities(5)
        ),
        
        // Steps
        Achievement(
            id: "100k_steps",
            name: "Step Master",
            description: "Walk 100,000 steps total",
            category: .milestone,
            icon: "figure.walk",
            requirement: .totalSteps(100_000)
        ),
        Achievement(
            id: "1m_steps",
            name: "Million Stepper",
            description: "Walk 1,000,000 steps total",
            category: .milestone,
            icon: "figure.walk.diamond.fill",
            requirement: .totalSteps(1_000_000)
        ),
    ]
    
    static func find(by id: String) -> Achievement? {
        allAchievements.first { $0.id == id }
    }
}
