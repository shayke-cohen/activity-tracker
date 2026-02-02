import WidgetKit
import SwiftUI

@main
struct ActivityTrackerWidgetsBundle: WidgetBundle {
    var body: some Widget {
        // Lock Screen Widgets
        StepsWidget()
        CaloriesWidget()
        StreakWidget()
        
        // Live Activity
        WorkoutLiveActivity()
    }
}
