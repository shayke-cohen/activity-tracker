import SwiftUI

/// View displayed after completing a workout
struct WorkoutSummaryView: View {
    let activity: Activity
    
    @EnvironmentObject var achievementService: AchievementService
    @EnvironmentObject var streakService: StreakService
    @EnvironmentObject var healthKitService: HealthKitService
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var newAchievements: [Achievement] = []
    @State private var showingShare = false
    @State private var isSaving = false
    @State private var hasSaved = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Achievement banner (if any)
                    if !newAchievements.isEmpty {
                        achievementBanner
                    }
                    
                    // Main stats card
                    mainStatsCard
                    
                    // Detailed metrics
                    detailedMetrics
                    
                    // Splits (if available)
                    if !activity.type.usesGPS {
                        EmptyView()
                    }
                    
                    // Heart rate graph placeholder
                    heartRateSection
                    
                    // Action buttons
                    actionButtons
                }
                .padding()
            }
            .background(Color.safeBackground)
            .navigationTitle("Workout Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
            }
            .sheet(isPresented: $showingShare) {
                ShareWorkoutView(activity: activity)
            }
            .task {
                await processWorkout()
            }
        }
    }
    
    // MARK: - Achievement Banner
    
    private var achievementBanner: some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    
                    Text("NEW ACHIEVEMENT!")
                        .font(.headline)
                        .foregroundStyle(.yellow)
                }
                
                ForEach(newAchievements, id: \.id) { achievement in
                    HStack {
                        Image(systemName: achievement.icon)
                            .font(.title2)
                            .foregroundStyle(achievement.color)
                        
                        VStack(alignment: .leading) {
                            Text(achievement.name)
                                .font(.headline)
                            
                            Text(achievement.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.yellow.opacity(0.5), lineWidth: 2)
        )
    }
    
    // MARK: - Main Stats Card
    
    private var mainStatsCard: some View {
        GlassCard {
            VStack(spacing: 20) {
                // Activity icon and type
                VStack(spacing: 8) {
                    Image(systemName: activity.type.icon)
                        .font(.system(size: 50))
                        .foregroundStyle(activity.type.color)
                    
                    Text(activity.type.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(activity.startDate, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Duration
                Text(activity.formattedDuration)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                
                // Key metrics
                HStack(spacing: 40) {
                    if let distance = activity.formattedDistance {
                        VStack {
                            Text(distance)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Distance")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    VStack {
                        Text("\(Int(activity.calories))")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Calories")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let pace = activity.formattedPace {
                        VStack {
                            Text(pace)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Pace")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Detailed Metrics
    
    private var detailedMetrics: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            if let avgHR = activity.averageHeartRate {
                DetailMetricCard(
                    title: "Avg Heart Rate",
                    value: "\(avgHR)",
                    unit: "bpm",
                    icon: "heart.fill",
                    color: .red
                )
            }
            
            if let maxHR = activity.maxHeartRate {
                DetailMetricCard(
                    title: "Max Heart Rate",
                    value: "\(maxHR)",
                    unit: "bpm",
                    icon: "heart.fill",
                    color: .red.opacity(0.7)
                )
            }
            
            if let steps = activity.steps {
                DetailMetricCard(
                    title: "Steps",
                    value: "\(steps.formatted())",
                    unit: "",
                    icon: "figure.walk",
                    color: .pink
                )
            }
            
            if let laps = activity.laps {
                DetailMetricCard(
                    title: "Laps",
                    value: "\(laps)",
                    unit: "",
                    icon: "arrow.triangle.2.circlepath",
                    color: .cyan
                )
            }
        }
    }
    
    // MARK: - Heart Rate Section
    
    private var heartRateSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("HEART RATE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                if let avg = activity.averageHeartRate, let max = activity.maxHeartRate {
                    HStack {
                        Text("Avg: \(avg)")
                        Spacer()
                        Text("Max: \(max)")
                    }
                    .font(.subheadline)
                    
                    // Simplified heart rate visualization
                    HeartRateGraphPlaceholder()
                        .frame(height: 60)
                } else {
                    Text("No heart rate data available")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            PrimaryButton(
                hasSaved ? "Saved to Health" : "Save Workout",
                icon: hasSaved ? "checkmark" : "square.and.arrow.down",
                color: hasSaved ? .green : .blue
            ) {
                saveWorkout()
            }
            .disabled(isSaving || hasSaved)
            
            GlassButton("Share", icon: "square.and.arrow.up") {
                showingShare = true
            }
        }
    }
    
    // MARK: - Actions
    
    private func processWorkout() async {
        // Record activity for streak
        streakService.recordActivity()
        
        // Check for new achievements
        newAchievements = achievementService.checkAchievements(
            for: activity,
            streak: streakService.streakData
        )
    }
    
    private func saveWorkout() {
        isSaving = true
        
        Task {
            do {
                try await healthKitService.saveWorkout(activity)
                hasSaved = true
            } catch {
                print("Failed to save workout: \(error)")
            }
            isSaving = false
        }
    }
}

// MARK: - Detail Metric Card

struct DetailMetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        GlassCard(padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Heart Rate Graph Placeholder

struct HeartRateGraphPlaceholder: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let points = generateRandomPoints(count: 20, width: width, height: height)
                
                path.move(to: points[0])
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Color.red, lineWidth: 2)
        }
    }
    
    private func generateRandomPoints(count: Int, width: CGFloat, height: CGFloat) -> [CGPoint] {
        (0..<count).map { i in
            let x = width * CGFloat(i) / CGFloat(count - 1)
            let y = height * (0.3 + 0.4 * sin(Double(i) * 0.5))
            return CGPoint(x: x, y: y)
        }
    }
}

#Preview {
    WorkoutSummaryView(activity: .sampleRun)
        .environmentObject(AchievementService.shared)
        .environmentObject(StreakService.shared)
        .environmentObject(HealthKitService.shared)
}
