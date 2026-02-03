import Foundation

/// Service for persisting completed workouts locally
@MainActor
class WorkoutStorageService: ObservableObject {
    static let shared = WorkoutStorageService()
    
    private let storageKey = "com.activitytracker.completedWorkouts"
    private let userDefaults = UserDefaults.standard
    
    @Published var completedWorkouts: [Activity] = []
    
    private init() {
        loadWorkouts()
    }
    
    // MARK: - CRUD Operations
    
    /// Save a completed workout
    func saveWorkout(_ activity: Activity) {
        completedWorkouts.insert(activity, at: 0)
        persistWorkouts()
    }
    
    /// Delete a workout
    func deleteWorkout(_ activity: Activity) {
        completedWorkouts.removeAll { $0.id == activity.id }
        persistWorkouts()
    }
    
    /// Get all workouts
    func getAllWorkouts() -> [Activity] {
        return completedWorkouts
    }
    
    /// Get workouts for a specific date range
    func getWorkouts(from startDate: Date, to endDate: Date) -> [Activity] {
        completedWorkouts.filter { workout in
            workout.startDate >= startDate && workout.startDate <= endDate
        }
    }
    
    /// Get workouts for today
    func getTodayWorkouts() -> [Activity] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return getWorkouts(from: startOfDay, to: Date())
    }
    
    /// Get recent workouts
    func getRecentWorkouts(limit: Int = 10) -> [Activity] {
        Array(completedWorkouts.prefix(limit))
    }
    
    /// Get workouts for the past N days
    func getWorkouts(days: Int) -> [Activity] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return getWorkouts(from: startDate, to: Date())
    }
    
    // MARK: - Statistics
    
    /// Get total workout count
    var totalWorkoutCount: Int {
        completedWorkouts.count
    }
    
    /// Get total calories burned (all time)
    var totalCaloriesBurned: Double {
        completedWorkouts.reduce(0) { $0 + $1.calories }
    }
    
    /// Get total distance (all time)
    var totalDistance: Double {
        completedWorkouts.compactMap { $0.distance }.reduce(0, +)
    }
    
    /// Get total duration (all time)
    var totalDuration: TimeInterval {
        completedWorkouts.reduce(0) { $0 + $1.duration }
    }
    
    /// Get workout count by type
    func workoutCount(for type: ActivityType) -> Int {
        completedWorkouts.filter { $0.type == type }.count
    }
    
    /// Get today's stats
    var todayStats: (calories: Double, distance: Double, duration: TimeInterval, workouts: Int) {
        let today = getTodayWorkouts()
        let calories = today.reduce(0) { $0 + $1.calories }
        let distance = today.compactMap { $0.distance }.reduce(0, +)
        let duration = today.reduce(0) { $0 + $1.duration }
        return (calories, distance, duration, today.count)
    }
    
    // MARK: - Persistence
    
    private func loadWorkouts() {
        guard let data = userDefaults.data(forKey: storageKey) else {
            completedWorkouts = []
            return
        }
        
        do {
            let decoder = JSONDecoder()
            completedWorkouts = try decoder.decode([Activity].self, from: data)
        } catch {
            print("Failed to decode workouts: \(error)")
            completedWorkouts = []
        }
    }
    
    private func persistWorkouts() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(completedWorkouts)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            print("Failed to encode workouts: \(error)")
        }
    }
    
    /// Clear all stored workouts
    func clearAll() {
        completedWorkouts = []
        userDefaults.removeObject(forKey: storageKey)
    }
}
