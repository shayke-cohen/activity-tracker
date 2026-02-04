import SwiftUI
import Combine

/// View displayed during an active workout
struct WorkoutInProgressView: View {
    let activityType: ActivityType
    
    @EnvironmentObject var workoutService: WorkoutService
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEndConfirmation = false
    @State private var showingSummary = false
    @State private var completedActivity: Activity?
    
    // Timer to force UI updates every second
    @State private var timerCancellable: AnyCancellable?
    @State private var displayTime: String = "00:00"
    @State private var displayCalories: Int = 0
    @State private var displayHeartRate: Int = 0
    @State private var displayDistance: Double = 0
    @State private var displayPace: String = "--:--"
    @State private var isPaused: Bool = false
    
    init(activityType: ActivityType) {
        self.activityType = activityType
        print("DEBUG: [WorkoutInProgressView] init called for \(activityType.displayName)")
    }
    
    var body: some View {
        let _ = print("DEBUG: [WorkoutInProgressView] body evaluated")
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
                    if isPaused {
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
                
                // Main timer - using local state that updates every second
                Text(displayTime)
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
        .fullScreenCover(isPresented: $showingSummary, onDismiss: {
            // When summary is dismissed, dismiss this view too
            dismiss()
        }) {
            if let activity = completedActivity {
                WorkoutSummaryView(activity: activity)
                    .environmentObject(AchievementService.shared)
                    .environmentObject(StreakService.shared)
                    .environmentObject(HealthKitService.shared)
            }
        }
        .onAppear {
            startDisplayTimer()
        }
        .onDisappear {
            stopDisplayTimer()
        }
    }
    
    // MARK: - Display Timer
    
    private func startDisplayTimer() {
        // Update display immediately
        updateDisplay()
        
        // Start timer to update display every second
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                updateDisplay()
            }
    }
    
    private func stopDisplayTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func updateDisplay() {
        guard let workout = workoutService.currentWorkout else { return }
        
        displayTime = workout.formattedElapsedTime
        displayCalories = Int(workout.calories)
        displayHeartRate = workout.currentHeartRate
        displayDistance = workout.distance
        displayPace = workout.formattedPace
        isPaused = workout.state == .paused
    }
    
    // MARK: - Metrics Grid
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            // Distance (for GPS activities)
            if activityType.usesGPS {
                MetricCard(
                    value: formatDistance(displayDistance),
                    unit: "km",
                    label: "Distance",
                    icon: "location.fill"
                )
                
                MetricCard(
                    value: displayPace,
                    unit: "/km",
                    label: "Pace",
                    icon: "speedometer"
                )
            }
            
            // Heart rate
            MetricCard(
                value: displayHeartRate > 0 ? "\(displayHeartRate)" : "--",
                unit: "bpm",
                label: "Heart Rate",
                icon: "heart.fill",
                color: .red
            )
            
            // Calories
            MetricCard(
                value: "\(displayCalories)",
                unit: "cal",
                label: "Calories",
                icon: "flame.fill",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
    
    private func formatDistance(_ distance: Double) -> String {
        let km = distance / 1000
        if km >= 1 {
            return String(format: "%.2f", km)
        } else {
            return String(format: "%.0f m", distance)
        }
    }
    
    // MARK: - Control Buttons
    
    private var controlButtons: some View {
        HStack(spacing: 30) {
            // Pause/Resume button
            Button {
                if isPaused {
                    workoutService.resumeWorkout()
                    isPaused = false
                } else {
                    workoutService.pauseWorkout()
                    isPaused = true
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
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
        stopDisplayTimer()
        Task {
            do {
                if let activity = try await workoutService.endWorkout() {
                    completedActivity = activity
                    showingSummary = true
                } else {
                    // No activity returned, just dismiss
                    dismiss()
                }
            } catch {
                print("Failed to end workout: \(error)")
                dismiss()
            }
        }
    }
    
    private func discardWorkout() {
        stopDisplayTimer()
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
