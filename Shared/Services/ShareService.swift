import Foundation
import SwiftUI
import UIKit

/// Service for generating shareable workout cards
@MainActor
class ShareService: ObservableObject {
    static let shared = ShareService()
    
    private init() {}
    
    // MARK: - Generate Share Image
    
    /// Generate a shareable image for a workout
    @MainActor
    func generateShareImage(for activity: Activity, format: ShareFormat) -> UIImage? {
        let view = ShareCardContent(activity: activity, format: format)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
    
    // MARK: - Generate Text Summary
    
    func generateTextSummary(for activity: Activity) -> String {
        var lines: [String] = []
        
        lines.append("\(activity.type.icon) \(activity.type.displayName)")
        lines.append("Duration: \(activity.formattedDuration)")
        
        if let distance = activity.formattedDistance {
            lines.append("Distance: \(distance)")
        }
        
        lines.append("Calories: \(Int(activity.calories)) cal")
        
        if let hr = activity.averageHeartRate {
            lines.append("Avg HR: \(hr) bpm")
        }
        
        if let pace = activity.formattedPace {
            lines.append("Pace: \(pace)")
        }
        
        lines.append("")
        lines.append("Tracked with Workout Tracker")
        
        return lines.joined(separator: "\n")
    }
    
    // MARK: - Share
    
    func share(activity: Activity, format: ShareFormat, from viewController: UIViewController) {
        var items: [Any] = []
        
        // Add image
        if let image = generateShareImage(for: activity, format: format) {
            items.append(image)
        }
        
        // Add text for some formats
        if format == .text {
            items.append(generateTextSummary(for: activity))
        }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        viewController.present(activityVC, animated: true)
    }
}

// MARK: - Share Format

enum ShareFormat: String, CaseIterable, Identifiable {
    case instagramStory = "Instagram Story"
    case square = "Square"
    case wide = "Wide"
    case text = "Text Only"
    
    var id: String { rawValue }
    
    var size: CGSize {
        switch self {
        case .instagramStory:
            return CGSize(width: 1080, height: 1920)
        case .square:
            return CGSize(width: 1080, height: 1080)
        case .wide:
            return CGSize(width: 1200, height: 630)
        case .text:
            return .zero
        }
    }
    
    var displaySize: CGSize {
        // Scaled down for preview
        let scale: CGFloat = 0.3
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
}

// MARK: - Share Card View

struct ShareCardContent: View {
    let activity: Activity
    let format: ShareFormat
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient.activityGradient(for: activity.type)
            
            VStack(spacing: 20) {
                // Activity icon and name
                VStack(spacing: 8) {
                    Image(systemName: activity.type.icon)
                        .font(.system(size: format == .instagramStory ? 60 : 40))
                    
                    Text(activity.type.displayName)
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Main metrics
                HStack(spacing: format == .instagramStory ? 40 : 30) {
                    MetricColumn(
                        value: activity.formattedDuration,
                        label: "Duration"
                    )
                    
                    if let distance = activity.formattedDistance {
                        MetricColumn(
                            value: distance,
                            label: "Distance"
                        )
                    }
                }
                
                // Secondary metrics
                HStack(spacing: format == .instagramStory ? 40 : 30) {
                    MetricColumn(
                        value: "\(Int(activity.calories))",
                        label: "Calories"
                    )
                    
                    if let hr = activity.averageHeartRate {
                        MetricColumn(
                            value: "\(hr)",
                            label: "Avg BPM"
                        )
                    }
                    
                    if let pace = activity.formattedPace {
                        MetricColumn(
                            value: pace,
                            label: "Pace"
                        )
                    }
                }
                
                Spacer()
                
                // Location and date
                VStack(spacing: 4) {
                    if let location = activity.locationName {
                        HStack {
                            Image(systemName: "location.fill")
                            Text(location)
                        }
                        .font(.subheadline)
                    }
                    
                    Text(activity.startDate, style: .date)
                        .font(.subheadline)
                }
                .opacity(0.8)
                
                // App branding
                Text("Workout Tracker")
                    .font(.caption)
                    .opacity(0.6)
            }
            .padding(30)
            .foregroundStyle(.white)
        }
        .frame(width: format.displaySize.width, height: format.displaySize.height)
    }
}

struct MetricColumn: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .opacity(0.8)
        }
    }
}

// MARK: - Preview

#Preview {
    ShareCardContent(activity: .sampleRun, format: .square)
}
