import SwiftUI

/// Watch view for selecting and starting workouts
struct WatchWorkoutsListView: View {
    @EnvironmentObject var workoutManager: WatchWorkoutManager
    @State private var selectedActivity: ActivityType?
    
    private let popularActivities: [ActivityType] = [
        .running, .walking, .cycling, .swimming, .yoga, .hiit
    ]
    
    var body: some View {
        List {
            ForEach(popularActivities, id: \.self) { activity in
                Button {
                    selectedActivity = activity
                } label: {
                    HStack {
                        Image(systemName: activity.icon)
                            .foregroundStyle(activity.color)
                            .frame(width: 30)
                        
                        Text(activity.displayName)
                        
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Workouts")
        .sheet(item: $selectedActivity) { activity in
            WatchCountdownView(activityType: activity)
        }
    }
}

// MARK: - Watch Countdown View

struct WatchCountdownView: View {
    let activityType: ActivityType
    
    @EnvironmentObject var workoutManager: WatchWorkoutManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var countdown = 3
    @State private var isCountingDown = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: activityType.icon)
                .font(.system(size: 40))
                .foregroundStyle(activityType.color)
            
            if isCountingDown {
                Text("\(countdown)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(activityType.color)
            } else {
                Text(activityType.displayName)
                    .font(.headline)
                
                Button {
                    startCountdown()
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(activityType.color)
                
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
        .padding()
    }
    
    private func startCountdown() {
        isCountingDown = true
        countdown = 3
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                startWorkout()
            }
        }
    }
    
    private func startWorkout() {
        Task {
            do {
                try await workoutManager.startWorkout(type: activityType)
                dismiss()
            } catch {
                print("Failed to start workout: \(error)")
                isCountingDown = false
            }
        }
    }
}

#Preview {
    WatchWorkoutsListView()
        .environmentObject(WatchWorkoutManager())
}
