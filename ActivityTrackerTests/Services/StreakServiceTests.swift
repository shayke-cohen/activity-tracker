import XCTest
@testable import ActivityTracker

final class StreakServiceTests: XCTestCase {
    
    // MARK: - Streak Data Tests
    
    func testNewStreakStartsAtZero() {
        // Given
        let streak = StreakData()
        
        // Then
        XCTAssertEqual(streak.currentStreak, 0)
        XCTAssertEqual(streak.longestStreak, 0)
        XCTAssertNil(streak.lastActiveDate)
    }
    
    func testRecordFirstActivity() {
        // Given
        var streak = StreakData()
        
        // When
        streak.recordActivity()
        
        // Then
        XCTAssertEqual(streak.currentStreak, 1)
        XCTAssertEqual(streak.longestStreak, 1)
        XCTAssertEqual(streak.totalActiveDays, 1)
        XCTAssertNotNil(streak.lastActiveDate)
    }
    
    func testConsecutiveDayIncreasesStreak() {
        // Given
        var streak = StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastActiveDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            totalActiveDays: 50
        )
        
        // When
        streak.recordActivity()
        
        // Then
        XCTAssertEqual(streak.currentStreak, 6)
        XCTAssertEqual(streak.longestStreak, 10) // Unchanged
        XCTAssertEqual(streak.totalActiveDays, 51)
    }
    
    func testMissedDayResetsStreak() {
        // Given
        var streak = StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastActiveDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
            totalActiveDays: 50
        )
        
        // When
        streak.recordActivity()
        
        // Then
        XCTAssertEqual(streak.currentStreak, 1) // Reset
        XCTAssertEqual(streak.longestStreak, 10) // Unchanged
    }
    
    func testSameDayDoesNotIncrementStreak() {
        // Given
        var streak = StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastActiveDate: Date(),
            totalActiveDays: 50
        )
        
        // When
        streak.recordActivity()
        
        // Then
        XCTAssertEqual(streak.currentStreak, 5) // Unchanged
        XCTAssertEqual(streak.totalActiveDays, 50) // Unchanged
    }
    
    func testNewLongestStreakIsRecorded() {
        // Given
        var streak = StreakData(
            currentStreak: 9,
            longestStreak: 9,
            lastActiveDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            totalActiveDays: 50
        )
        
        // When
        streak.recordActivity()
        
        // Then
        XCTAssertEqual(streak.currentStreak, 10)
        XCTAssertEqual(streak.longestStreak, 10) // Updated
    }
    
    // MARK: - Streak Status Tests
    
    func testIsStreakActiveWhenActivityToday() {
        // Given
        let streak = StreakData(
            currentStreak: 5,
            lastActiveDate: Date()
        )
        
        // Then
        XCTAssertTrue(streak.isStreakActive)
        XCTAssertTrue(streak.hasActivityToday)
    }
    
    func testIsStreakActiveWhenActivityYesterday() {
        // Given
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let streak = StreakData(
            currentStreak: 5,
            lastActiveDate: yesterday
        )
        
        // Then
        XCTAssertTrue(streak.isStreakActive)
        XCTAssertFalse(streak.hasActivityToday)
    }
    
    func testStreakNotActiveWhenMissedDays() {
        // Given
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        let streak = StreakData(
            currentStreak: 5,
            lastActiveDate: twoDaysAgo
        )
        
        // Then
        XCTAssertFalse(streak.isStreakActive)
    }
    
    func testCheckStreakStatusResetsOldStreak() {
        // Given
        var streak = StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastActiveDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())
        )
        
        // When
        streak.checkStreakStatus()
        
        // Then
        XCTAssertEqual(streak.currentStreak, 0) // Reset
        XCTAssertEqual(streak.longestStreak, 10) // Unchanged
    }
}
