import SwiftUI

/// Watch view showing workout history
struct WatchHistoryView: View {
    // Sample data
    private let recentWorkouts: [(type: ActivityType, duration: String, date: String)] = [
        (.running, "32:15", "Today"),
        (.cycling, "45:00", "Yesterday"),
        (.swimming, "28:30", "Jan 31"),
    ]
    
    var body: some View {
        List {
            ForEach(recentWorkouts, id: \.date) { workout in
                HStack {
                    Image(systemName: workout.type.icon)
                        .foregroundStyle(workout.type.color)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(workout.type.displayName)
                            .font(.headline)
                        
                        Text(workout.duration)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(workout.date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("History")
    }
}

// MARK: - Watch Workout Summary View

struct WatchWorkoutSummaryView: View {
    let activityType: ActivityType
    let duration: String
    let calories: Int
    let distance: Double?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Success indicator
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.green)
                
                Text("Complete!")
                    .font(.headline)
                
                // Stats
                VStack(spacing: 8) {
                    Text(duration)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    
                    HStack(spacing: 20) {
                        if let distance = distance {
                            VStack {
                                Text(String(format: "%.2f", distance / 1000))
                                    .font(.headline)
                                Text("km")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        VStack {
                            Text("\(calories)")
                                .font(.headline)
                            Text("cal")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding()
        }
    }
}

#Preview {
    WatchHistoryView()
}
