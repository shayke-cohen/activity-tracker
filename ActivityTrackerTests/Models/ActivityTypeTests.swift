import XCTest
import HealthKit
@testable import ActivityTracker

final class ActivityTypeTests: XCTestCase {
    
    // MARK: - HealthKit Mapping Tests
    
    func testRunningMapsToCorrectHKType() {
        XCTAssertEqual(ActivityType.running.healthKitType, .running)
    }
    
    func testSwimmingMapsToCorrectHKType() {
        XCTAssertEqual(ActivityType.swimming.healthKitType, .swimming)
    }
    
    func testCyclingMapsToCorrectHKType() {
        XCTAssertEqual(ActivityType.cycling.healthKitType, .cycling)
    }
    
    func testYogaMapsToCorrectHKType() {
        XCTAssertEqual(ActivityType.yoga.healthKitType, .yoga)
    }
    
    func testHIITMapsToCorrectHKType() {
        XCTAssertEqual(ActivityType.hiit.healthKitType, .highIntensityIntervalTraining)
    }
    
    func testAllActivityTypesHaveValidHKMapping() {
        for type in ActivityType.allCases {
            XCTAssertNotNil(type.healthKitType, "Activity type \(type) should have valid HK mapping")
        }
    }
    
    // MARK: - Display Property Tests
    
    func testAllTypesHaveDisplayName() {
        for type in ActivityType.allCases {
            XCTAssertFalse(type.displayName.isEmpty, "Activity type \(type) should have display name")
        }
    }
    
    func testAllTypesHaveIcon() {
        for type in ActivityType.allCases {
            XCTAssertFalse(type.icon.isEmpty, "Activity type \(type) should have icon")
        }
    }
    
    func testAllTypesHaveCategory() {
        for type in ActivityType.allCases {
            XCTAssertNotNil(type.category, "Activity type \(type) should have category")
        }
    }
    
    // MARK: - Category Tests
    
    func testCardioActivitiesInCorrectCategory() {
        let cardioTypes: [ActivityType] = [.running, .walking, .cycling, .swimming, .hiking]
        
        for type in cardioTypes {
            XCTAssertEqual(type.category, .cardio, "\(type) should be in cardio category")
        }
    }
    
    func testGymActivitiesInCorrectCategory() {
        let gymTypes: [ActivityType] = [.strengthTraining, .hiit, .functionalTraining, .coreTraining, .rowing, .elliptical, .stairClimbing]
        
        for type in gymTypes {
            XCTAssertEqual(type.category, .gym, "\(type) should be in gym category")
        }
    }
    
    func testMindBodyActivitiesInCorrectCategory() {
        let mindBodyTypes: [ActivityType] = [.yoga, .pilates, .stretching]
        
        for type in mindBodyTypes {
            XCTAssertEqual(type.category, .mindBody, "\(type) should be in mind & body category")
        }
    }
    
    // MARK: - GPS Usage Tests
    
    func testOutdoorActivitiesUseGPS() {
        let gpsTypes: [ActivityType] = [.running, .walking, .cycling, .hiking, .swimming]
        
        for type in gpsTypes {
            XCTAssertTrue(type.usesGPS, "\(type) should use GPS")
        }
    }
    
    func testIndoorActivitiesDoNotUseGPS() {
        let indoorTypes: [ActivityType] = [.yoga, .pilates, .strengthTraining, .hiit, .elliptical, .stairClimbing]
        
        for type in indoorTypes {
            XCTAssertFalse(type.usesGPS, "\(type) should not use GPS")
        }
    }
    
    // MARK: - Category Activities Tests
    
    func testCategoryContainsCorrectActivities() {
        let cardioActivities = ActivityCategory.cardio.activities
        
        XCTAssertTrue(cardioActivities.contains(.running))
        XCTAssertTrue(cardioActivities.contains(.swimming))
        XCTAssertFalse(cardioActivities.contains(.yoga))
    }
}
