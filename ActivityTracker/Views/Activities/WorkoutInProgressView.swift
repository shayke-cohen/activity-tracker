import SwiftUI

/// View displayed during an active workout
struct WorkoutInProgressView: View {
    let activityType: ActivityType
    
    @EnvironmentObject var workoutService: WorkoutService
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEndConfirmation = false
    @State private var showingSummary = false
    @State private var completedActivity: Activity?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient.activityGradient(for: activityType)
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Activity header
                HStack {
                    Image(systemName: activityType.icon)
                        .font(.title)
                    
                    Text(activityType.displayName.uppercased())
                        .font(.headline)
                    
                    Spacer()
                    
                    // Status indicator
                    if workoutService.currentWorkout?.state == .paused {
                        Text("PAUSED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(.orange.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                .foregroundStyle(activityType.color)
                .padding(.horizontal)
                
                Spacer()
                
                // Main timer
                Text(workoutService.currentWorkout?.formattedElapsedTime ?? "00:00")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .monospacedDigit()
                
                // Metrics grid
                metricsGrid
                
                Spacer()
                
                // Control buttons
                controlButtons
            }
            .padding()
        }
        .confirmationDialog("End Workout?", isPresented: $showingEndConfirmation) {
            Button("End Workout") {
                endWorkout()
            }
            Button("Discard Workout", role: .destructive) {
                discardWorkout()
            }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showingSummary) {
            if let activity = completedActivity {
                WorkoutSummaryView(activity: activity)
            }
        }
    }
    
    // MARK: - Metrics Grid
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            if let workout = workoutService.currentWorkout {
                // Distance (for GPS activities)
                if activityType.usesGPS {
                    MetricCard(
                        value: workout.formattedDistance,
                        unit: "km",
                        label: "Distance",
                        icon: "location.fill"
                    )
                    
                    MetricCard(
                        value: workout.formattedPace,
                        unit: "/km",
                        label: "Pace",
                        icon: "speedometer"
                    )
                }
                
                // Heart rate
                MetricCard(
                    value: workout.currentHeartRate > 0 ? "\(workout.currentHeartRate)" : "--",
                    unit: "bpm",
                    label: "Heart Rate",
                    icon: "heart.fill",
                    color: .red
                )
                
                // Calories
                MetricCard(
                    value: "\(Int(workout.calories))",
                    unit: "cal",
                    label: "Calories",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Control Buttons
    
    private var controlButtons: some View {
        HStack(spacing: 30) {
            // Pause/Resume button
            Button {
                if workoutService.currentWorkout?.state == .paused {
                    workoutService.resumeWorkout()
                } else {
                    workoutService.pauseWorkout()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: workoutService.currentWorkout?.state == .paused ? "play.fill" : "pause.fill")
                        .font(.title)
                        .foregroundStyle(.primary)
                }
            }
            
            // End button
            Button {
                showingEndConfirmation = true
            } label: {
                ZStack {
                    Circle()
                        .fill(.red.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "stop.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func endWorkout() {
        Task {
            do {
                if let activity = try await workoutService.endWorkout() {
                    completedActivity = activity
                    showingSummary = true
                }
            } catch {
                print("Failed to end workout: \(error)")
            }
        }
    }
    
    private func discardWorkout() {
        Task {
            await workoutService.discardWorkout()
            dismiss()
        }
    }
}

// MARK: - Metric Card

struct MetricCard: View {
    let value: String
    let unit: String
    let label: String
    let icon: String
    var color: Color = .primary
    
    var body: some View {
        GlassCard(padding: 16) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    WorkoutInProgressView(activityType: .running)
        .environmentObject(WorkoutService.shared)
}
