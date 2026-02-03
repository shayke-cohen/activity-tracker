import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var pedometerService: PedometerService
    @EnvironmentObject var healthKitService: HealthKitService
    @EnvironmentObject var streakService: StreakService
    @EnvironmentObject var workoutStorageService: WorkoutStorageService
    
    @State private var todayCalories: Double = 0
    @State private var todayDistance: Double = 0
    @State private var todayExerciseMinutes: Double = 0
    @State private var recentActivities: [Activity] = []
    @State private var showingWorkoutPicker = false
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress Rings Card
                    progressRingsSection
                    
                    // Streak Card
                    streakSection
                    
                    // Quick Start Section
                    quickStartSection
                    
                    // Recent Activity
                    recentActivitySection
                }
                .padding()
            }
            .background(Color.safeBackground)
            .navigationTitle("Workout Tracker")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingWorkoutPicker) {
                ActivityListView()
            }
            .task {
                await loadTodayData()
            }
        }
    }
    
    // MARK: - Progress Rings Section
    
    private var progressRingsSection: some View {
        GlassCard {
            VStack(spacing: 16) {
                Text("TODAY'S PROGRESS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                // Progress Rings - calories goal 500, exercise goal 30 min
                ProgressRingsView(
                    moveProgress: min(todayCalories / 500, 2.0),
                    exerciseProgress: min(todayExerciseMinutes / 30, 2.0)
                )
                .frame(height: 180)
                
                // Stats Row - use real data from pedometer and HealthKit
                HStack(spacing: 30) {
                    StatItem(
                        value: "\(pedometerService.todaySteps.formatted())",
                        label: "Steps",
                        icon: "figure.walk",
                        color: .pink
                    )
                    
                    StatItem(
                        value: "\(Int(todayCalories))",
                        label: "Calories",
                        icon: "flame.fill",
                        color: .orange
                    )
                    
                    // Use real distance from pedometer or HealthKit
                    StatItem(
                        value: String(format: "%.1f", max(pedometerService.todayDistance, todayDistance) / 1000),
                        label: "km",
                        icon: "location.fill",
                        color: .blue
                    )
                }
            }
        }
    }
    
    // MARK: - Streak Section
    
    private var streakSection: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(streakService.currentStreak) Day Streak")
                            .font(.headline)
                    }
                    
                    Text(streakService.streakMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Streak badge
                ZStack {
                    Circle()
                        .fill(.orange.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text("\(streakService.currentStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                }
            }
        }
    }
    
    // MARK: - Quick Start Section
    
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK START")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach([ActivityType.running, .cycling, .swimming, .yoga], id: \.self) { activity in
                        QuickStartButton(activity: activity) {
                            showingWorkoutPicker = true
                        }
                    }
                    
                    // More button
                    Button {
                        showingWorkoutPicker = true
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(.gray.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text("More")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Recent Activity Section
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT ACTIVITY")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if recentActivities.isEmpty {
                // Empty state
                GlassCard(padding: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "figure.run")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text("No recent workouts")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Start a workout to see it here")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                // Real activities from HealthKit
                ForEach(recentActivities.prefix(5), id: \.id) { activity in
                    RecentActivityCard(activity: activity)
                }
            }
        }
    }
    
    // MARK: - Load Data
    
    private func loadTodayData() async {
        isLoading = true
        
        // Load from HealthKit in parallel
        async let caloriesTask = healthKitService.queryTodayCalories()
        async let distanceTask = healthKitService.queryTodayDistance()
        async let exerciseTask = healthKitService.queryTodayExerciseMinutes()
        async let workoutsTask = healthKitService.queryRecentWorkouts(limit: 5)
        
        do {
            todayCalories = try await caloriesTask
        } catch {
            print("Failed to load calories from HealthKit: \(error)")
            // Fallback to local storage
            todayCalories = workoutStorageService.todayStats.calories
        }
        
        do {
            todayDistance = try await distanceTask
        } catch {
            print("Failed to load distance from HealthKit: \(error)")
            // Fallback to local storage
            todayDistance = workoutStorageService.todayStats.distance
        }
        
        do {
            todayExerciseMinutes = try await exerciseTask
        } catch {
            print("Failed to load exercise minutes from HealthKit: \(error)")
            // Fallback to local storage
            todayExerciseMinutes = workoutStorageService.todayStats.duration / 60
        }
        
        do {
            let hkWorkouts = try await workoutsTask
            if hkWorkouts.isEmpty {
                // Use local storage if HealthKit has no data
                recentActivities = workoutStorageService.getRecentWorkouts(limit: 5)
            } else {
                recentActivities = hkWorkouts
            }
        } catch {
            print("Failed to load recent workouts from HealthKit: \(error)")
            // Fallback to local storage
            recentActivities = workoutStorageService.getRecentWorkouts(limit: 5)
        }
        
        // Start pedometer updates for real-time step counting
        pedometerService.startUpdates()
        
        isLoading = false
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct QuickStartButton: View {
    let activity: ActivityType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(activity.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: activity.icon)
                        .font(.title2)
                        .foregroundStyle(activity.color)
                }
                
                Text(activity.displayName)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct RecentActivityCard: View {
    let activity: Activity
    
    var body: some View {
        GlassCard(padding: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(activity.type.color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: activity.type.icon)
                        .foregroundStyle(activity.type.color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.type.displayName)
                        .font(.headline)
                    
                    Text("\(activity.formattedDuration) • \(activity.formattedDistance ?? "")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(activity.startDate, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environmentObject(PedometerService.shared)
        .environmentObject(HealthKitService.shared)
        .environmentObject(StreakService.shared)
        .environmentObject(WorkoutStorageService.shared)
}
