import SwiftUI

/// App color palette with light/dark mode support
extension Color {
    // MARK: - Primary Colors
    
    /// Primary brand color
    static let activityPrimary = Color("ActivityPrimary", bundle: nil)
    
    /// Secondary brand color
    static let activitySecondary = Color("ActivitySecondary", bundle: nil)
    
    // MARK: - Background Colors
    
    /// Main app background
    static let appBackground = Color("AppBackground", bundle: nil)
    
    /// Card/surface background
    static let cardBackground = Color("CardBackground", bundle: nil)
    
    // MARK: - Ring Colors
    
    /// Move ring color (calories)
    static let moveRing = Color.red
    
    /// Exercise ring color (minutes)
    static let exerciseRing = Color.green
    
    /// Stand ring color (hours)
    static let standRing = Color.cyan
    
    // MARK: - Semantic Colors
    
    /// Success/positive state
    static let success = Color.green
    
    /// Warning state
    static let warning = Color.orange
    
    /// Error/negative state
    static let error = Color.red
    
    // MARK: - Fallback Colors (when Asset Catalog not set up)
    
    /// Safe primary color with fallback
    static var safePrimary: Color {
        // Try to load from asset catalog, fallback to system blue
        Color.blue
    }
    
    /// Safe background with fallback
    static var safeBackground: Color {
        Color(uiColor: .systemBackground)
    }
    
    /// Safe card background with fallback
    static var safeCardBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }
}

// MARK: - Gradients

extension LinearGradient {
    /// Primary app gradient
    static let appGradient = LinearGradient(
        colors: [.blue, .purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Dashboard background gradient (adapts to color scheme)
    static func dashboardGradient(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [.black, Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [.white, Color(.systemGray6).opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    /// Workout activity gradient
    static func activityGradient(for type: ActivityType) -> LinearGradient {
        LinearGradient(
            colors: [type.color, type.color.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Ring Gradient

extension AngularGradient {
    /// Ring progress gradient
    static func ringGradient(color: Color) -> AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [color.opacity(0.8), color]),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
    }
}
