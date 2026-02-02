import WidgetKit
import SwiftUI

// MARK: - Steps Complication

struct StepsComplication: Widget {
    let kind = "StepsComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StepsComplicationProvider()) { entry in
            StepsComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Steps")
        .description("Your daily step count")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct StepsComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> StepsComplicationEntry {
        StepsComplicationEntry(date: Date(), steps: 8500, goal: 10000)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StepsComplicationEntry) -> Void) {
        completion(StepsComplicationEntry(date: Date(), steps: 8500, goal: 10000))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StepsComplicationEntry>) -> Void) {
        let entry = StepsComplicationEntry(date: Date(), steps: 8500, goal: 10000)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
        completion(timeline)
    }
}

struct StepsComplicationEntry: TimelineEntry {
    let date: Date
    let steps: Int
    let goal: Int
    
    var progress: Double {
        Double(steps) / Double(goal)
    }
}

struct StepsComplicationView: View {
    @Environment(\.widgetFamily) var family
    let entry: StepsComplicationEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: min(entry.progress, 1.0)) {
                Image(systemName: "figure.walk")
            } currentValueLabel: {
                Text("\(entry.steps / 1000)k")
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(.pink)
            
        case .accessoryCorner:
            Text("\(entry.steps / 1000)k")
                .font(.headline)
                .widgetCurvesContent()
                .widgetLabel {
                    Gauge(value: min(entry.progress, 1.0)) {
                        Text("Steps")
                    }
                    .gaugeStyle(.accessoryLinearCapacity)
                    .tint(.pink)
                }
            
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "figure.walk")
                    Text("Steps")
                }
                .font(.caption)
                
                Text("\(entry.steps.formatted())")
                    .font(.headline)
                
                ProgressView(value: min(entry.progress, 1.0))
                    .tint(.pink)
            }
            
        case .accessoryInline:
            Label("\(entry.steps.formatted()) steps", systemImage: "figure.walk")
            
        default:
            EmptyView()
        }
    }
}

// MARK: - Calories Complication

struct CaloriesComplication: Widget {
    let kind = "CaloriesComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CaloriesComplicationProvider()) { entry in
            CaloriesComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Calories")
        .description("Active calories burned")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline
        ])
    }
}

struct CaloriesComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> CaloriesComplicationEntry {
        CaloriesComplicationEntry(date: Date(), calories: 350, goal: 500)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CaloriesComplicationEntry) -> Void) {
        completion(CaloriesComplicationEntry(date: Date(), calories: 350, goal: 500))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CaloriesComplicationEntry>) -> Void) {
        let entry = CaloriesComplicationEntry(date: Date(), calories: 350, goal: 500)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
        completion(timeline)
    }
}

struct CaloriesComplicationEntry: TimelineEntry {
    let date: Date
    let calories: Int
    let goal: Int
    
    var progress: Double {
        Double(calories) / Double(goal)
    }
}

struct CaloriesComplicationView: View {
    @Environment(\.widgetFamily) var family
    let entry: CaloriesComplicationEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: min(entry.progress, 1.0)) {
                Image(systemName: "flame.fill")
            } currentValueLabel: {
                Text("\(entry.calories)")
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(.orange)
            
        case .accessoryCorner:
            Text("\(entry.calories)")
                .font(.headline)
                .widgetCurvesContent()
                .widgetLabel {
                    Gauge(value: min(entry.progress, 1.0)) {
                        Text("Cal")
                    }
                    .gaugeStyle(.accessoryLinearCapacity)
                    .tint(.orange)
                }
            
        case .accessoryInline:
            Label("\(entry.calories) cal", systemImage: "flame.fill")
            
        default:
            EmptyView()
        }
    }
}

// MARK: - Active Workout Complication

struct ActiveWorkoutComplication: Widget {
    let kind = "ActiveWorkoutComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ActiveWorkoutProvider()) { entry in
            ActiveWorkoutComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Active Workout")
        .description("Current workout status")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}

struct ActiveWorkoutProvider: TimelineProvider {
    func placeholder(in context: Context) -> ActiveWorkoutEntry {
        ActiveWorkoutEntry(date: Date(), isActive: true, activityType: .running, duration: "32:45")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ActiveWorkoutEntry) -> Void) {
        completion(ActiveWorkoutEntry(date: Date(), isActive: false, activityType: nil, duration: nil))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ActiveWorkoutEntry>) -> Void) {
        let entry = ActiveWorkoutEntry(date: Date(), isActive: false, activityType: nil, duration: nil)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60)))
        completion(timeline)
    }
}

struct ActiveWorkoutEntry: TimelineEntry {
    let date: Date
    let isActive: Bool
    let activityType: ActivityType?
    let duration: String?
}

struct ActiveWorkoutComplicationView: View {
    @Environment(\.widgetFamily) var family
    let entry: ActiveWorkoutEntry
    
    var body: some View {
        if entry.isActive, let type = entry.activityType, let duration = entry.duration {
            switch family {
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground()
                    
                    VStack(spacing: 0) {
                        Image(systemName: type.icon)
                            .font(.caption)
                        Text(duration)
                            .font(.caption2)
                            .monospacedDigit()
                    }
                }
                
            case .accessoryRectangular:
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: type.icon)
                        Text(type.displayName)
                    }
                    .font(.caption)
                    
                    Text(duration)
                        .font(.headline)
                        .monospacedDigit()
                    
                    Text("In Progress")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
            default:
                EmptyView()
            }
        } else {
            // No active workout
            switch family {
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground()
                    
                    Image(systemName: "figure.run")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
            case .accessoryRectangular:
                VStack(alignment: .leading) {
                    Text("No Active Workout")
                        .font(.caption)
                    
                    Text("Tap to start")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Widget Bundle

@main
struct ActivityTrackerWatchWidgets: WidgetBundle {
    var body: some Widget {
        StepsComplication()
        CaloriesComplication()
        ActiveWorkoutComplication()
    }
}
