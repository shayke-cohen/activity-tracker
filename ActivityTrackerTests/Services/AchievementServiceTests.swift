import XCTest
@testable import ActivityTracker

final class AchievementServiceTests: XCTestCase {
    var sut: AchievementService!
    
    @MainActor
    override func setUp() {
        super.setUp()
        sut = AchievementService.shared
        // Reset state before each test to ensure isolation
        sut.resetForTesting()
    }
    
    @MainActor
    override func tearDown() {
        // Clean up after tests
        sut.resetForTesting()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Achievement Check Tests
    
    @MainActor
    func testFirstWorkoutAchievement() {
        // Given
        let activity = Activity(
            type: .running,
            startDate: Date().addingTimeInterval(-1800),
            endDate: Date(),
            calories: 200
        )
        let streak = StreakData(currentStreak: 1)
        
        // When
        let unlocked = sut.checkAchievements(for: activity, streak: streak)
        
        // Then
        XCTAssertTrue(unlocked.contains { $0.id == "first_workout" })
    }
    
    @MainActor
    func testStreakAchievement() {
        // Given
        let activity = Activity(
            type: .walking,
            startDate: Date().addingTimeInterval(-900),
            endDate: Date(),
            calories: 100
        )
        let streak = StreakData(currentStreak: 7)
        
        // When
        let unlocked = sut.checkAchievements(for: activity, streak: streak)
        
        // Then
        XCTAssertTrue(unlocked.contains { $0.id == "streak_7" })
    }
    
    @MainActor
    func test5KRunAchievement() {
        // Given
        let activity = Activity(
            type: .running,
            startDate: Date().addingTimeInterval(-1800),
            endDate: Date(),
            calories: 300,
            distance: 5200 // 5.2 km
        )
        let streak = StreakData(currentStreak: 1)
        
        // When
        let unlocked = sut.checkAchievements(for: activity, streak: streak)
        
        // Then
        XCTAssertTrue(unlocked.contains { $0.id == "5k_run" })
    }
    
    @MainActor
    func testNoUnlockForInsufficientDistance() {
        // Given
        let activity = Activity(
            type: .running,
            startDate: Date().addingTimeInterval(-900),
            endDate: Date(),
            calories: 150,
            distance: 3000 // Only 3 km
        )
        let streak = StreakData(currentStreak: 1)
        
        // When
        let unlocked = sut.checkAchievements(for: activity, streak: streak)
        
        // Then
        XCTAssertFalse(unlocked.contains { $0.id == "5k_run" })
    }
    
    // MARK: - Achievement Query Tests
    
    @MainActor
    func testTotalAchievementCount() {
        // When
        let total = sut.totalCount()
        
        // Then
        XCTAssertGreaterThan(total, 0)
        XCTAssertEqual(total, Achievement.allAchievements.count)
    }
    
    @MainActor
    func testAchievementsByCategory() {
        // When
        let grouped = sut.achievementsByCategory()
        
        // Then
        XCTAssertTrue(grouped.keys.contains(.milestone))
        XCTAssertTrue(grouped.keys.contains(.streak))
        XCTAssertTrue(grouped.keys.contains(.personalBest))
    }
    
    @MainActor
    func testFindAchievementById() {
        // When
        let achievement = Achievement.find(by: "first_workout")
        
        // Then
        XCTAssertNotNil(achievement)
        XCTAssertEqual(achievement?.name, "First Steps")
    }
}
