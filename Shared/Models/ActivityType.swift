import Foundation
import SwiftUI
import HealthKit

/// All supported activity types in the app
enum ActivityType: String, CaseIterable, Codable, Identifiable {
    // MARK: - Cardio
    case steps
    case running
    case walking
    case cycling
    case swimming
    case hiking
    
    // MARK: - Gym & Strength
    case strengthTraining
    case hiit
    case functionalTraining
    case coreTraining
    case rowing
    case elliptical
    case stairClimbing
    
    // MARK: - Mind & Body
    case yoga
    case pilates
    case stretching
    
    // MARK: - Other
    case other
    
    var id: String { rawValue }
    
    // MARK: - HealthKit Mapping
    
    var healthKitType: HKWorkoutActivityType {
        switch self {
        case .steps, .walking: return .walking
        case .running: return .running
        case .cycling: return .cycling
        case .swimming: return .swimming
        case .hiking: return .hiking
        case .strengthTraining: return .traditionalStrengthTraining
        case .hiit: return .highIntensityIntervalTraining
        case .functionalTraining: return .functionalStrengthTraining
        case .coreTraining: return .coreTraining
        case .rowing: return .rowing
        case .elliptical: return .elliptical
        case .stairClimbing: return .stairClimbing
        case .yoga: return .yoga
        case .pilates: return .pilates
        case .stretching: return .flexibility
        case .other: return .other
        }
    }
    
    /// Initialize from HKWorkoutActivityType
    init?(from hkType: HKWorkoutActivityType) {
        switch hkType {
        case .walking: self = .walking
        case .running: self = .running
        case .cycling: self = .cycling
        case .swimming: self = .swimming
        case .hiking: self = .hiking
        case .traditionalStrengthTraining: self = .strengthTraining
        case .highIntensityIntervalTraining: self = .hiit
        case .functionalStrengthTraining: self = .functionalTraining
        case .coreTraining: self = .coreTraining
        case .rowing: self = .rowing
        case .elliptical: self = .elliptical
        case .stairClimbing: self = .stairClimbing
        case .yoga: self = .yoga
        case .pilates: self = .pilates
        case .flexibility: self = .stretching
        default: self = .other
        }
    }
    
    // MARK: - Display Properties
    
    var displayName: String {
        switch self {
        case .steps: return "Steps"
        case .running: return "Running"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .swimming: return "Swimming"
        case .hiking: return "Hiking"
        case .strengthTraining: return "Strength Training"
        case .hiit: return "HIIT"
        case .functionalTraining: return "Functional Training"
        case .coreTraining: return "Core Training"
        case .rowing: return "Rowing"
        case .elliptical: return "Elliptical"
        case .stairClimbing: return "Stair Climbing"
        case .yoga: return "Yoga"
        case .pilates: return "Pilates"
        case .stretching: return "Stretching"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "figure.outdoor.cycle"
        case .swimming: return "figure.pool.swim"
        case .hiking: return "figure.hiking"
        case .strengthTraining: return "dumbbell.fill"
        case .hiit: return "bolt.heart.fill"
        case .functionalTraining: return "figure.cross.training"
        case .coreTraining: return "figure.core.training"
        case .rowing: return "figure.rower"
        case .elliptical: return "figure.elliptical"
        case .stairClimbing: return "figure.stair.stepper"
        case .yoga: return "figure.yoga"
        case .pilates: return "figure.pilates"
        case .stretching: return "figure.flexibility"
        case .other: return "figure.mixed.cardio"
        }
    }
    
    var color: Color {
        switch self {
        case .steps: return .pink
        case .running: return .orange
        case .walking: return .green
        case .cycling: return .blue
        case .swimming: return .cyan
        case .hiking: return .brown
        case .strengthTraining: return .purple
        case .hiit: return .red
        case .functionalTraining: return .indigo
        case .coreTraining: return .yellow
        case .rowing: return .teal
        case .elliptical: return .mint
        case .stairClimbing: return .gray
        case .yoga: return .purple.opacity(0.7)
        case .pilates: return .pink.opacity(0.7)
        case .stretching: return .green.opacity(0.7)
        case .other: return .secondary
        }
    }
    
    var usesGPS: Bool {
        switch self {
        case .running, .walking, .cycling, .hiking, .swimming:
            return true
        default:
            return false
        }
    }
    
    var category: ActivityCategory {
        switch self {
        case .steps, .running, .walking, .cycling, .swimming, .hiking:
            return .cardio
        case .strengthTraining, .hiit, .functionalTraining, .coreTraining, .rowing, .elliptical, .stairClimbing:
            return .gym
        case .yoga, .pilates, .stretching:
            return .mindBody
        case .other:
            return .other
        }
    }
    
    /// Primary metric unit for this activity
    var primaryMetricUnit: String {
        switch self {
        case .steps:
            return "steps"
        case .swimming:
            return "laps"
        case .strengthTraining, .hiit, .functionalTraining, .coreTraining:
            return "reps"
        default:
            return "km"
        }
    }
}

// MARK: - Activity Category

enum ActivityCategory: String, CaseIterable {
    case cardio = "Cardio"
    case gym = "Gym & Strength"
    case mindBody = "Mind & Body"
    case other = "Other"
    
    var displayName: String {
        rawValue
    }
    
    var activities: [ActivityType] {
        ActivityType.allCases.filter { $0.category == self }
    }
}
