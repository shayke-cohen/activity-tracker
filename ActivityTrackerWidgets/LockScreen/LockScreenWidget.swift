import WidgetKit
import SwiftUI

// MARK: - Steps Widget

struct StepsWidget: Widget {
    let kind: String = "StepsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StepsProvider()) { entry in
            StepsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Steps")
        .description("Track your daily step count")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct StepsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StepsEntry {
        StepsEntry(date: Date(), steps: 8500, goal: 10000)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StepsEntry) -> Void) {
        let entry = StepsEntry(date: Date(), steps: 8500, goal: 10000)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StepsEntry>) -> Void) {
        // Would fetch from shared container
        let entry = StepsEntry(date: Date(), steps: 8500, goal: 10000)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
        completion(timeline)
    }
}

struct StepsEntry: TimelineEntry {
    let date: Date
    let steps: Int
    let goal: Int
    
    var progress: Double {
        Double(steps) / Double(goal)
    }
}

struct StepsWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: StepsEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        default:
            circularView
        }
    }
    
    private var circularView: some View {
        Gauge(value: min(entry.progress, 1.0)) {
            Image(systemName: "figure.walk")
        } currentValueLabel: {
            Text("\(entry.steps / 1000)k")
                .font(.caption2)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(.pink)
    }
    
    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "figure.walk")
                Text("Steps")
                    .font(.caption)
            }
            
            Text("\(entry.steps.formatted())")
                .font(.headline)
            
            ProgressView(value: min(entry.progress, 1.0))
                .tint(.pink)
        }
    }
    
    private var inlineView: some View {
        HStack {
            Image(systemName: "figure.walk")
            Text("\(entry.steps.formatted()) steps")
        }
    }
}

// MARK: - Calories Widget

struct CaloriesWidget: Widget {
    let kind: String = "CaloriesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CaloriesProvider()) { entry in
            CaloriesWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Calories")
        .description("Track your active calories")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct CaloriesProvider: TimelineProvider {
    func placeholder(in context: Context) -> CaloriesEntry {
        CaloriesEntry(date: Date(), calories: 350, goal: 500)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CaloriesEntry) -> Void) {
        completion(CaloriesEntry(date: Date(), calories: 350, goal: 500))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CaloriesEntry>) -> Void) {
        let entry = CaloriesEntry(date: Date(), calories: 350, goal: 500)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
        completion(timeline)
    }
}

struct CaloriesEntry: TimelineEntry {
    let date: Date
    let calories: Int
    let goal: Int
    
    var progress: Double {
        Double(calories) / Double(goal)
    }
}

struct CaloriesWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: CaloriesEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: min(entry.progress, 1.0)) {
                Image(systemName: "flame.fill")
            } currentValueLabel: {
                Text("\(entry.calories)")
                    .font(.caption2)
            }
            .gaugeStyle(.accessoryCircular)
            .tint(.orange)
            
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "flame.fill")
                    Text("Calories")
                        .font(.caption)
                }
                
                Text("\(entry.calories) cal")
                    .font(.headline)
                
                ProgressView(value: min(entry.progress, 1.0))
                    .tint(.orange)
            }
            
        case .accessoryInline:
            HStack {
                Image(systemName: "flame.fill")
                Text("\(entry.calories) cal")
            }
            
        default:
            EmptyView()
        }
    }
}

// MARK: - Streak Widget

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Streak")
        .description("Track your activity streak")
        .supportedFamilies([.accessoryCircular, .accessoryInline])
    }
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streak: 14)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(StreakEntry(date: Date(), streak: 14))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = StreakEntry(date: Date(), streak: 14)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
}

struct StreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
}

struct StreakWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: StreakEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                
                VStack(spacing: 0) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                    
                    Text("\(entry.streak)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            
        case .accessoryInline:
            HStack {
                Image(systemName: "flame.fill")
                Text("\(entry.streak) day streak")
            }
            
        default:
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview("Steps Circular", as: .accessoryCircular) {
    StepsWidget()
} timeline: {
    StepsEntry(date: Date(), steps: 8500, goal: 10000)
}

#Preview("Calories Rectangular", as: .accessoryRectangular) {
    CaloriesWidget()
} timeline: {
    CaloriesEntry(date: Date(), calories: 350, goal: 500)
}
