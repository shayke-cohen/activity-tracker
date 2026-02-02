import SwiftUI
import WatchKit

/// Watch view during an active workout
struct WatchWorkoutInProgressView: View {
    @EnvironmentObject var workoutManager: WatchWorkoutManager
    @State private var showingEndConfirmation = false
    
    var body: some View {
        TabView {
            // Main metrics page
            metricsPage
            
            // Controls page
            controlsPage
        }
        .tabViewStyle(.verticalPage)
        .confirmationDialog("End Workout?", isPresented: $showingEndConfirmation) {
            Button("End", role: .destructive) {
                endWorkout()
            }
            Button("Discard", role: .destructive) {
                discardWorkout()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    // MARK: - Metrics Page
    
    private var metricsPage: some View {
        VStack(spacing: 8) {
            // Activity header
            HStack {
                Image(systemName: workoutManager.currentActivityType.icon)
                    .foregroundStyle(workoutManager.currentActivityType.color)
                
                Text(workoutManager.currentActivityType.displayName.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if workoutManager.isPaused {
                    Text("PAUSED")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            
            // Timer
            Text(workoutManager.formattedElapsedTime)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .monospacedDigit()
            
            Divider()
            
            // Metrics grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                if workoutManager.currentActivityType.usesGPS {
                    WatchMetricView(
                        value: workoutManager.formattedDistance,
                        unit: "km",
                        icon: "location.fill"
                    )
                }
                
                WatchMetricView(
                    value: "\(workoutManager.heartRate)",
                    unit: "bpm",
                    icon: "heart.fill",
                    iconColor: .red
                )
                
                WatchMetricView(
                    value: "\(Int(workoutManager.calories))",
                    unit: "cal",
                    icon: "flame.fill",
                    iconColor: .orange
                )
                
                if workoutManager.currentActivityType.usesGPS {
                    WatchMetricView(
                        value: workoutManager.formattedPace,
                        unit: "/km",
                        icon: "speedometer"
                    )
                }
            }
        }
        .padding()
    }
    
    // MARK: - Controls Page
    
    private var controlsPage: some View {
        VStack(spacing: 16) {
            // Pause/Resume button
            Button {
                if workoutManager.isPaused {
                    workoutManager.resumeWorkout()
                } else {
                    workoutManager.pauseWorkout()
                }
            } label: {
                Label(
                    workoutManager.isPaused ? "Resume" : "Pause",
                    systemImage: workoutManager.isPaused ? "play.fill" : "pause.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.yellow)
            
            // End button
            Button(role: .destructive) {
                showingEndConfirmation = true
            } label: {
                Label("End", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            
            // Water lock (for swimming)
            if workoutManager.currentActivityType == .swimming {
                Button {
                    WKInterfaceDevice.current().enableWaterLock()
                } label: {
                    Label("Water Lock", systemImage: "drop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.cyan)
            }
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func endWorkout() {
        Task {
            await workoutManager.endWorkout()
        }
    }
    
    private func discardWorkout() {
        Task {
            await workoutManager.discardWorkout()
        }
    }
}

// MARK: - Watch Metric View

struct WatchMetricView: View {
    let value: String
    let unit: String
    let icon: String
    var iconColor: Color = .primary
    
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(iconColor)
                
                Text(value)
                    .font(.headline)
            }
            
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    WatchWorkoutInProgressView()
        .environmentObject(WatchWorkoutManager())
}
