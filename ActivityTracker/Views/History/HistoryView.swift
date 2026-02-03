import SwiftUI

/// History tab showing past workouts
struct HistoryView: View {
    @EnvironmentObject var healthKitService: HealthKitService
    @EnvironmentObject var workoutStorageService: WorkoutStorageService
    
    @State private var workouts: [Activity] = []
    @State private var selectedFilter: ActivityType?
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter bar
                filterBar
                
                // Workout list
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredWorkouts.isEmpty {
                    emptyState
                } else {
                    workoutList
                }
            }
            .background(Color.safeBackground)
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("This Week") { loadWorkouts(days: 7) }
                        Button("This Month") { loadWorkouts(days: 30) }
                        Button("All Time") { loadWorkouts(days: 365) }
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
            }
            .task {
                await loadInitialWorkouts()
            }
        }
    }
    
    // MARK: - Filter Bar
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    isSelected: selectedFilter == nil
                ) {
                    selectedFilter = nil
                }
                
                ForEach([ActivityType.running, .cycling, .swimming, .walking, .yoga], id: \.self) { type in
                    FilterChip(
                        title: type.displayName,
                        isSelected: selectedFilter == type
                    ) {
                        selectedFilter = type
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Workout List
    
    private var workoutList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(groupedWorkouts.keys.sorted().reversed(), id: \.self) { section in
                    Section {
                        ForEach(groupedWorkouts[section] ?? [], id: \.id) { workout in
                            NavigationLink {
                                WorkoutDetailView(activity: workout)
                            } label: {
                                WorkoutHistoryCard(activity: workout)
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text(sectionTitle(for: section))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No workouts yet")
                .font(.headline)
            
            Text("Start a workout to see your history here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    
    private var filteredWorkouts: [Activity] {
        if let filter = selectedFilter {
            return workouts.filter { $0.type == filter }
        }
        return workouts
    }
    
    private var groupedWorkouts: [String: [Activity]] {
        Dictionary(grouping: filteredWorkouts) { workout in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: workout.startDate)
        }
    }
    
    private func sectionTitle(for dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Data Loading
    
    private func loadInitialWorkouts() async {
        isLoading = true
        
        var allWorkouts: [Activity] = []
        
        // Try to load from HealthKit
        do {
            let hkWorkouts = try await healthKitService.queryWorkouts(days: 30)
            allWorkouts.append(contentsOf: hkWorkouts)
        } catch {
            print("Failed to load workouts from HealthKit: \(error)")
        }
        
        // Also load from local storage and merge
        let localWorkouts = workoutStorageService.getWorkouts(days: 30)
        
        // Merge and deduplicate by combining both sources
        // Use a Set to track which workouts we've added (by start date and type)
        var seen = Set<String>()
        var merged: [Activity] = []
        
        for workout in allWorkouts + localWorkouts {
            let key = "\(workout.type.rawValue)-\(Int(workout.startDate.timeIntervalSince1970))"
            if !seen.contains(key) {
                seen.insert(key)
                merged.append(workout)
            }
        }
        
        // Sort by start date (most recent first)
        workouts = merged.sorted { $0.startDate > $1.startDate }
        
        isLoading = false
    }
    
    private func loadWorkouts(days: Int) {
        Task {
            isLoading = true
            
            var allWorkouts: [Activity] = []
            
            do {
                let hkWorkouts = try await healthKitService.queryWorkouts(days: days)
                allWorkouts.append(contentsOf: hkWorkouts)
            } catch {
                print("Failed to load workouts from HealthKit: \(error)")
            }
            
            // Also load from local storage
            let localWorkouts = workoutStorageService.getWorkouts(days: days)
            
            // Merge and deduplicate
            var seen = Set<String>()
            var merged: [Activity] = []
            
            for workout in allWorkouts + localWorkouts {
                let key = "\(workout.type.rawValue)-\(Int(workout.startDate.timeIntervalSince1970))"
                if !seen.contains(key) {
                    seen.insert(key)
                    merged.append(workout)
                }
            }
            
            workouts = merged.sorted { $0.startDate > $1.startDate }
            
            isLoading = false
        }
    }
}

// MARK: - Workout History Card

struct WorkoutHistoryCard: View {
    let activity: Activity
    
    var body: some View {
        GlassCard(padding: 14) {
            HStack {
                // Activity icon
                ZStack {
                    Circle()
                        .fill(activity.type.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: activity.type.icon)
                        .font(.title3)
                        .foregroundStyle(activity.type.color)
                }
                
                // Activity details
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.type.displayName)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Text(activity.formattedDuration)
                        
                        if let distance = activity.formattedDistance {
                            Text("•")
                            Text(distance)
                        }
                        
                        Text("•")
                        Text("\(Int(activity.calories)) cal")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Workout Detail View

struct WorkoutDetailView: View {
    let activity: Activity
    
    @State private var showingShare = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
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
                .padding(.top)
                
                // Duration
                Text(activity.formattedDuration)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                
                // Stats grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    if let distance = activity.formattedDistance {
                        DetailMetricCard(
                            title: "Distance",
                            value: distance,
                            unit: "",
                            icon: "location.fill",
                            color: .blue
                        )
                    }
                    
                    DetailMetricCard(
                        title: "Calories",
                        value: "\(Int(activity.calories))",
                        unit: "cal",
                        icon: "flame.fill",
                        color: .orange
                    )
                    
                    if let avgHR = activity.averageHeartRate {
                        DetailMetricCard(
                            title: "Avg HR",
                            value: "\(avgHR)",
                            unit: "bpm",
                            icon: "heart.fill",
                            color: .red
                        )
                    }
                    
                    if let pace = activity.formattedPace {
                        DetailMetricCard(
                            title: "Pace",
                            value: pace,
                            unit: "",
                            icon: "speedometer",
                            color: .green
                        )
                    }
                }
                
                // Share button
                GlassButton("Share Workout", icon: "square.and.arrow.up") {
                    showingShare = true
                }
            }
            .padding()
        }
        .background(Color.safeBackground)
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShare) {
            ShareWorkoutView(activity: activity)
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(HealthKitService.shared)
        .environmentObject(WorkoutStorageService.shared)
}
