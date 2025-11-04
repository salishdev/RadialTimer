@testable import TimerFeature
import UserPreferences
import XCTest

final class TimerFeatureTests: XCTestCase {
  @MainActor
  func testTimerStartAndStop() async throws {
    let mockPreferences = MockUserPreferences(duration: 60)
    let viewModel = TimerViewModel(duration: 60, userPreferences: mockPreferences)

    // Test initial state
    XCTAssertFalse(viewModel.isTimerOn)
    XCTAssertFalse(viewModel.isTimerExpired)
    XCTAssertEqual(viewModel.timeRemaining, 60)

    // Start timer
    viewModel.toggleTimer()
    XCTAssertTrue(viewModel.isTimerOn)
    XCTAssertFalse(viewModel.isTimerExpired)

    // Wait for timer to tick
    try await Task.sleep(nanoseconds: 1100000000) // 1.1 seconds
    XCTAssertLessThan(viewModel.timeRemaining, 60)

    // Stop timer
    viewModel.toggleTimer()
    XCTAssertFalse(viewModel.isTimerOn)
  }

  @MainActor
  func testTimerReset() async throws {
    let mockPreferences = MockUserPreferences(duration: 60)
    let viewModel = TimerViewModel(duration: 60, userPreferences: mockPreferences)

    // Start timer
    viewModel.toggleTimer()
    XCTAssertTrue(viewModel.isTimerOn)

    // Wait for timer to tick
    try await Task.sleep(nanoseconds: 1100000000) // 1.1 seconds
    let timeAfterTick = viewModel.timeRemaining
    XCTAssertLessThan(timeAfterTick, 60)

    // Reset timer
    viewModel.resetTimer()
    XCTAssertFalse(viewModel.isTimerOn)
    XCTAssertFalse(viewModel.isTimerExpired)
    XCTAssertEqual(viewModel.timeRemaining, 60)
  }

  @MainActor
  func testTimerStartFromExpiredState() throws {
    let mockPreferences = MockUserPreferences(duration: 60)
    let viewModel = TimerViewModel(timeRemaining: 0, duration: 60, isTimerExpired: true, userPreferences: mockPreferences)

    // Verify expired state
    XCTAssertTrue(viewModel.isTimerExpired)
    XCTAssertEqual(viewModel.timeRemaining, 0)

    // Start timer from expired state
    viewModel.toggleTimer()
    XCTAssertTrue(viewModel.isTimerOn)
    XCTAssertFalse(viewModel.isTimerExpired)
    XCTAssertEqual(viewModel.timeRemaining, 60) // Should reset to full duration
  }

  @MainActor
  func testTimeFormatting() throws {
    let mockPreferences = MockUserPreferences()
    let viewModel = TimerViewModel(timeRemaining: 9932, duration: 9932, userPreferences: mockPreferences)
    XCTAssertEqual(viewModel.formattedTimeRemaining, "02:45:32")

    let viewModel2 = TimerViewModel(timeRemaining: 3661, duration: 3661, userPreferences: mockPreferences)
    XCTAssertEqual(viewModel2.formattedTimeRemaining, "01:01:01")

    let viewModel3 = TimerViewModel(timeRemaining: 59, duration: 59, userPreferences: mockPreferences)
    XCTAssertEqual(viewModel3.formattedTimeRemaining, "00:00:59")
  }

  @MainActor
  func testDurationChange() throws {
    let mockPreferences = MockUserPreferences(duration: 60)
    let viewModel = TimerViewModel(duration: 60, userPreferences: mockPreferences)

    // Change duration
    viewModel.durationChanged(120)
    XCTAssertEqual(viewModel.duration, 120)
    XCTAssertEqual(viewModel.timeRemaining, 120)
    XCTAssertFalse(viewModel.isTimerOn)
    XCTAssertFalse(viewModel.isTimerExpired)

    // Verify duration is saved to mock preferences
    XCTAssertEqual(mockPreferences.duration, 120)
  }

  @MainActor
  func testDurationAsDoubleBinding() throws {
    let mockPreferences = MockUserPreferences(duration: 60)
    let viewModel = TimerViewModel(duration: 60, userPreferences: mockPreferences)

    // Test getter
    XCTAssertEqual(viewModel.durationAsDouble, 60.0)

    // Test setter
    viewModel.durationAsDouble = 180.0
    XCTAssertEqual(viewModel.duration, 180)
    XCTAssertEqual(viewModel.timeRemaining, 180)
  }
}
