import SwiftUI
import HealthKit

@main
struct ActivityTrackerWatchApp: App {
    @StateObject private var workoutManager = WatchWorkoutManager()
    
    var body: some Scene {
        WindowGroup {
            WatchMainView()
                .environmentObject(workoutManager)
        }
    }
}

// MARK: - Watch Main View

struct WatchMainView: View {
    @EnvironmentObject var workoutManager: WatchWorkoutManager
    
    var body: some View {
        if workoutManager.isWorkoutActive {
            WatchWorkoutInProgressView()
        } else {
            WatchTabView()
        }
    }
}

// MARK: - Watch Tab View

struct WatchTabView: View {
    var body: some View {
        TabView {
            WatchDashboardView()
            WatchWorkoutsListView()
            WatchHistoryView()
        }
        .tabViewStyle(.verticalPage)
    }
}
