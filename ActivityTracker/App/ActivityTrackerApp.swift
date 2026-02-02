import SwiftUI

@main
struct ActivityTrackerApp: App {
    @StateObject private var healthKitService = HealthKitService.shared
    @StateObject private var pedometerService = PedometerService.shared
    @StateObject private var workoutService = WorkoutService.shared
    @StateObject private var achievementService = AchievementService.shared
    @StateObject private var streakService = StreakService.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(healthKitService)
                .environmentObject(pedometerService)
                .environmentObject(workoutService)
                .environmentObject(achievementService)
                .environmentObject(streakService)
                .task {
                    await requestPermissions()
                }
        }
    }
    
    private func requestPermissions() async {
        // Request HealthKit authorization
        do {
            try await healthKitService.requestAuthorization()
        } catch {
            print("HealthKit authorization failed: \(error)")
        }
        
        // Start pedometer updates
        pedometerService.startUpdates()
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            AchievementsView()
                .tabItem {
                    Label("Awards", systemImage: "trophy.fill")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(HealthKitService.shared)
        .environmentObject(PedometerService.shared)
        .environmentObject(WorkoutService.shared)
        .environmentObject(AchievementService.shared)
        .environmentObject(StreakService.shared)
}
