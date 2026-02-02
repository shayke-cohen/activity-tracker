import SwiftUI

/// App typography styles
extension Font {
    // MARK: - Display
    
    /// Large display text (e.g., main stats)
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    
    /// Medium display text
    static let displayMedium = Font.system(size: 36, weight: .bold, design: .rounded)
    
    /// Small display text
    static let displaySmall = Font.system(size: 28, weight: .bold, design: .rounded)
    
    // MARK: - Headings
    
    /// Section heading
    static let sectionHeading = Font.system(size: 20, weight: .semibold, design: .default)
    
    /// Card title
    static let cardTitle = Font.system(size: 17, weight: .semibold, design: .default)
    
    // MARK: - Body
    
    /// Primary body text
    static let bodyPrimary = Font.system(size: 17, weight: .regular, design: .default)
    
    /// Secondary body text
    static let bodySecondary = Font.system(size: 15, weight: .regular, design: .default)
    
    // MARK: - Metrics
    
    /// Large metric value (e.g., "12,456")
    static let metricLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    
    /// Medium metric value
    static let metricMedium = Font.system(size: 24, weight: .semibold, design: .rounded)
    
    /// Small metric value
    static let metricSmall = Font.system(size: 17, weight: .medium, design: .rounded)
    
    /// Metric label (e.g., "steps")
    static let metricLabel = Font.system(size: 13, weight: .medium, design: .default)
    
    // MARK: - Caption
    
    /// Caption text
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    
    /// Caption text emphasized
    static let captionEmphasis = Font.system(size: 12, weight: .medium, design: .default)
}

// MARK: - Text Style Modifiers

extension View {
    /// Apply display large style
    func displayLargeStyle() -> some View {
        self.font(.displayLarge)
    }
    
    /// Apply metric style with optional color
    func metricStyle(size: MetricSize = .medium, color: Color = .primary) -> some View {
        self
            .font(size.font)
            .foregroundStyle(color)
    }
    
    /// Apply label style
    func labelStyle() -> some View {
        self
            .font(.metricLabel)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }
}

enum MetricSize {
    case large, medium, small
    
    var font: Font {
        switch self {
        case .large: return .metricLarge
        case .medium: return .metricMedium
        case .small: return .metricSmall
        }
    }
}
