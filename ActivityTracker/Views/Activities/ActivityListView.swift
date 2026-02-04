import SwiftUI

/// Activity picker view for starting workouts
struct ActivityListView: View {
    @EnvironmentObject var workoutService: WorkoutService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedActivity: ActivityType?
    @State private var showWorkoutInProgress = false
    
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
        .fullScreenCover(isPresented: $showWorkoutInProgress, onDismiss: {
            print("DEBUG: [ActivityListView] fullScreenCover dismissed")
            // Also dismiss this sheet when workout view is dismissed
            dismiss()
        }) {
            if let activityType = workoutService.currentWorkout?.activityType {
                let _ = print("DEBUG: [ActivityListView] Presenting WorkoutInProgressView for \(activityType.displayName)")
                WorkoutInProgressView(activityType: activityType)
            } else {
                let _ = print("DEBUG: [ActivityListView] No activityType found!")
                // Dismiss immediately if no workout
                Color.clear.onAppear { showWorkoutInProgress = false }
            }
        }
        .onChange(of: workoutService.isWorkoutActive) { oldValue, newValue in
            print("DEBUG: [ActivityListView] isWorkoutActive changed: \(oldValue) -> \(newValue)")
            if newValue {
                // Present workout view
                showWorkoutInProgress = true
                // Clear navigation
                selectedActivity = nil
            }
            // Don't auto-dismiss when workout ends - let WorkoutInProgressView
            // handle its own dismissal after showing the summary
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
        // Workout view is now presented from MainTabView when workoutService.isWorkoutActive is true
        // We don't dismiss here - the fullScreenCover will present over the sheet
    }
    
    private func startCountdown() {
        // Skip countdown for debugging - start immediately
        print("DEBUG: [WorkoutCountdownView] startCountdown called - starting workout immediately")
        startWorkout()
        
        // Original countdown code (disabled for debugging)
        // isCountingDown = true
        // countdown = 3
        //
        // Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
        //     if countdown > 1 {
        //         withAnimation(.spring(response: 0.3)) {
        //             countdown -= 1
        //         }
        //     } else {
        //         timer.invalidate()
        //         startWorkout()
        //     }
        // }
    }
    
    private func startWorkout() {
        Task { @MainActor in
            do {
                print("DEBUG: [WorkoutCountdownView] Starting workout for \(activityType.displayName)")
                try await workoutService.startWorkout(type: activityType)
                print("DEBUG: [WorkoutCountdownView] Workout started successfully")
                print("DEBUG: [WorkoutCountdownView] isWorkoutActive: \(workoutService.isWorkoutActive)")
                // The onChange handler will dismiss this view when isWorkoutActive becomes true
                // MainTabView will then present WorkoutInProgressView
            } catch {
                print("DEBUG: [WorkoutCountdownView] Failed to start workout: \(error)")
                isCountingDown = false
            }
        }
    }
}

#Preview {
    ActivityListView()
        .environmentObject(WorkoutService.shared)
}
