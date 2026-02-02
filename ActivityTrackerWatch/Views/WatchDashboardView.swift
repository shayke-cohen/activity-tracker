import SwiftUI

/// Watch dashboard showing today's summary
struct WatchDashboardView: View {
    @State private var steps: Int = 8500
    @State private var calories: Int = 350
    @State private var distance: Double = 4.2
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Title
                Text("TODAY")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // Steps ring
                ZStack {
                    Circle()
                        .stroke(.pink.opacity(0.2), lineWidth: 8)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: min(Double(steps) / 10000, 1.0))
                        .stroke(.pink, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 100, height: 100)
                    
                    VStack(spacing: 2) {
                        Text("\(steps / 1000).\((steps % 1000) / 100)k")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("steps")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Stats row
                HStack(spacing: 20) {
                    VStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(calories)")
                            .font(.headline)
                        Text("cal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.blue)
                        Text(String(format: "%.1f", distance))
                            .font(.headline)
                        Text("km")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Quick start button
                NavigationLink {
                    WatchWorkoutsListView()
                } label: {
                    Label("Start Workout", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding()
        }
        .navigationTitle("Activity")
    }
}

#Preview {
    WatchDashboardView()
}
