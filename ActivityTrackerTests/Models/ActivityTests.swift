import XCTest
@testable import ActivityTracker

final class ActivityTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testActivityCreation() {
        // Given
        let startDate = Date().addingTimeInterval(-1800)
        let endDate = Date()
        
        // When
        let activity = Activity(
            type: .running,
            startDate: startDate,
            endDate: endDate,
            calories: 250,
            distance: 5000
        )
        
        // Then
        XCTAssertEqual(activity.type, .running)
        XCTAssertEqual(activity.startDate, startDate)
        XCTAssertEqual(activity.endDate, endDate)
        XCTAssertEqual(activity.calories, 250)
        XCTAssertEqual(activity.distance, 5000)
        XCTAssertEqual(activity.duration, 1800, accuracy: 1)
    }
    
    // MARK: - Duration Formatting Tests
    
    func testFormattedDurationUnderOneHour() {
        // Given
        let activity = Activity(
            type: .running,
            startDate: Date().addingTimeInterval(-1965),
            endDate: Date(),
            calories: 250
        )
        
        // Then
        XCTAssertEqual(activity.formattedDuration, "32:45")
    }
    
    func testFormattedDurationOverOneHour() {
        // Given
        let activity = Activity(
            type: .cycling,
            startDate: Date().addingTimeInterval(-4500), // 1:15:00
            endDate: Date(),
            calories: 500
        )
        
        // Then
        XCTAssertEqual(activity.formattedDuration, "1:15:00")
    }
    
    // MARK: - Distance Formatting Tests
    
    func testFormattedDistanceInKilometers() {
        // Given
        let activity = Activity(
            type: .running,
            startDate: Date().addingTimeInterval(-1800),
            endDate: Date(),
            calories: 250,
            distance: 5250 // 5.25 km
        )
        
        // Then
        XCTAssertEqual(activity.formattedDistance, "5.25 km")
    }
    
    func testFormattedDistanceInMeters() {
        // Given
        let activity = Activity(
            type: .running,
            startDate: Date().addingTimeInterval(-600),
            endDate: Date(),
            calories: 80,
            distance: 800 // 800 m
        )
        
        // Then
        XCTAssertEqual(activity.formattedDistance, "800 m")
    }
    
    func testFormattedDistanceNilWhenNoDistance() {
        // Given
        let activity = Activity(
            type: .yoga,
            startDate: Date().addingTimeInterval(-1800),
            endDate: Date(),
            calories: 150
        )
        
        // Then
        XCTAssertNil(activity.formattedDistance)
    }
    
    // MARK: - Pace Calculation Tests
    
    func testPaceCalculation() {
        // Given
        let activity = Activity(
            type: .running,
            startDate: Date().addingTimeInterval(-1800), // 30 minutes
            endDate: Date(),
            calories: 250,
            distance: 5000 // 5 km
        )
        
        // Then - pace should be 6 minutes per km = 360 seconds
        XCTAssertEqual(activity.pace!, 360, accuracy: 1)
    }
    
    func testFormattedPace() {
        // Given
        let activity = Activity(
            type: .running,
            startDate: Date().addingTimeInterval(-1965), // 32:45
            endDate: Date(),
            calories: 250,
            distance: 4250 // 4.25 km
        )
        
        // Then - pace should be around 7:42 per km
        XCTAssertNotNil(activity.formattedPace)
        XCTAssertTrue(activity.formattedPace!.contains(":"))
    }
    
    func testPaceNilWhenNoDistance() {
        // Given
        let activity = Activity(
            type: .yoga,
            startDate: Date().addingTimeInterval(-1800),
            endDate: Date(),
            calories: 150
        )
        
        // Then
        XCTAssertNil(activity.pace)
        XCTAssertNil(activity.formattedPace)
    }
    
    // MARK: - Sample Data Tests
    
    func testSampleRunHasValidData() {
        let sample = Activity.sampleRun
        
        XCTAssertEqual(sample.type, .running)
        XCTAssertGreaterThan(sample.calories, 0)
        XCTAssertNotNil(sample.distance)
        XCTAssertNotNil(sample.averageHeartRate)
    }
    
    func testSampleSwimHasValidData() {
        let sample = Activity.sampleSwim
        
        XCTAssertEqual(sample.type, .swimming)
        XCTAssertGreaterThan(sample.calories, 0)
        XCTAssertNotNil(sample.laps)
    }
}
