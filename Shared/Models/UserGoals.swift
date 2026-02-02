import Foundation

/// User's fitness goals
struct UserGoals: Codable {
    var dailyStepGoal: Int
    var dailyCalorieGoal: Double
    var dailyExerciseMinutes: Int
    var weeklyWorkoutGoal: Int
    var weeklyDistanceGoal: Double // meters
    
    init(
        dailyStepGoal: Int = 10_000,
        dailyCalorieGoal: Double = 500,
        dailyExerciseMinutes: Int = 30,
        weeklyWorkoutGoal: Int = 5,
        weeklyDistanceGoal: Double = 20_000
    ) {
        self.dailyStepGoal = dailyStepGoal
        self.dailyCalorieGoal = dailyCalorieGoal
        self.dailyExerciseMinutes = dailyExerciseMinutes
        self.weeklyWorkoutGoal = weeklyWorkoutGoal
        self.weeklyDistanceGoal = weeklyDistanceGoal
    }
    
    static let `default` = UserGoals()
}

// MARK: - Daily Progress

struct DailyProgress: Codable {
    var date: Date
    var steps: Int
    var calories: Double
    var exerciseMinutes: Int
    var workouts: Int
    var distance: Double
    
    init(
        date: Date = Date(),
        steps: Int = 0,
        calories: Double = 0,
        exerciseMinutes: Int = 0,
        workouts: Int = 0,
        distance: Double = 0
    ) {
        self.date = date
        self.steps = steps
        self.calories = calories
        self.exerciseMinutes = exerciseMinutes
        self.workouts = workouts
        self.distance = distance
    }
    
    // MARK: - Ring Progress
    
    func moveProgress(goal: Double) -> Double {
        min(calories / goal, 2.0) // Cap at 200%
    }
    
    func exerciseProgress(goal: Int) -> Double {
        min(Double(exerciseMinutes) / Double(goal), 2.0)
    }
    
    func stepsProgress(goal: Int) -> Double {
        min(Double(steps) / Double(goal), 2.0)
    }
}

// MARK: - Ring Progress

struct RingProgress {
    var current: Double
    var goal: Double
    
    var percentage: Double {
        guard goal > 0 else { return 0 }
        return current / goal
    }
    
    var isComplete: Bool {
        percentage >= 1.0
    }
    
    var displayPercentage: Int {
        Int(percentage * 100)
    }
}

// MARK: - Daily Rings

struct DailyRings {
    var moveRing: RingProgress
    var exerciseRing: RingProgress
    
    var allComplete: Bool {
        moveRing.isComplete && exerciseRing.isComplete
    }
    
    static func from(progress: DailyProgress, goals: UserGoals) -> DailyRings {
        DailyRings(
            moveRing: RingProgress(current: progress.calories, goal: goals.dailyCalorieGoal),
            exerciseRing: RingProgress(current: Double(progress.exerciseMinutes), goal: Double(goals.dailyExerciseMinutes))
        )
    }
}
