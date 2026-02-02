import SwiftUI

/// Activity picker view for starting workouts
struct ActivityListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedActivity: ActivityType?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(ActivityCategory.allCases, id: \.self) { category in
                        if !category.activities.isEmpty {
                            categorySection(category)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Start Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(item: $selectedActivity) { activity in
                WorkoutCountdownView(activityType: activity)
            }
        }
    }
    
    private func categorySection(_ category: ActivityCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.displayName.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(category.activities, id: \.self) { activity in
                    ActivityButton(activity: activity) {
                        selectedActivity = activity
                    }
                }
            }
        }
    }
}

struct ActivityButton: View {
    let activity: ActivityType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(activity.color.opacity(0.15))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: activity.icon)
                        .font(.title)
                        .foregroundStyle(activity.color)
                }
                
                Text(activity.displayName)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Workout Countdown View

struct WorkoutCountdownView: View {
    let activityType: ActivityType
    
    @EnvironmentObject var workoutService: WorkoutService
    @Environment(\.dismiss) private var dismiss
    
    @State private var countdown = 3
    @State private var isCountingDown = false
    @State private var showWorkoutInProgress = false
    
    var body: some View {
        ZStack {
            // Background
            activityType.color.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Activity icon
                Image(systemName: activityType.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(activityType.color)
                
                // Countdown or start button
                if isCountingDown {
                    Text("\(countdown)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundStyle(activityType.color)
                        .contentTransition(.numericText())
                } else {
                    VStack(spacing: 20) {
                        Text(activityType.displayName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        PrimaryButton("Start Workout", icon: "play.fill", color: activityType.color) {
                            startCountdown()
                        }
                        .frame(width: 200)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(isCountingDown)
        .toolbar {
            if !isCountingDown {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showWorkoutInProgress) {
            WorkoutInProgressView(activityType: activityType)
        }
    }
    
    private func startCountdown() {
        isCountingDown = true
        countdown = 3
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                withAnimation(.spring(response: 0.3)) {
                    countdown -= 1
                }
            } else {
                timer.invalidate()
                startWorkout()
            }
        }
    }
    
    private func startWorkout() {
        Task {
            do {
                try await workoutService.startWorkout(type: activityType)
                showWorkoutInProgress = true
            } catch {
                print("Failed to start workout: \(error)")
                isCountingDown = false
            }
        }
    }
}

#Preview {
    ActivityListView()
        .environmentObject(WorkoutService.shared)
}
