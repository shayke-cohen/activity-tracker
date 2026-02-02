import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var pedometerService: PedometerService
    @EnvironmentObject var healthKitService: HealthKitService
    @EnvironmentObject var streakService: StreakService
    
    @State private var todayCalories: Double = 0
    @State private var showingWorkoutPicker = false
    
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
            .navigationTitle("Activity Tracker")
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
                
                // Progress Rings
                ProgressRingsView(
                    moveProgress: min(todayCalories / 500, 2.0),
                    exerciseProgress: 0.7 // Would be calculated from workouts
                )
                .frame(height: 180)
                
                // Stats Row
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
                    
                    StatItem(
                        value: String(format: "%.1f", pedometerService.todayDistance / 1000),
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
            
            // Sample activities
            ForEach([Activity.sampleRun, Activity.sampleCycle], id: \.id) { activity in
                RecentActivityCard(activity: activity)
            }
        }
    }
    
    // MARK: - Load Data
    
    private func loadTodayData() async {
        do {
            todayCalories = try await healthKitService.queryTodayCalories()
        } catch {
            print("Failed to load calories: \(error)")
        }
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
}
