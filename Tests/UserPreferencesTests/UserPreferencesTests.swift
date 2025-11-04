//
//  UserPreferencesTests.swift
//  RadialTimer
//

@testable import UserPreferences
import XCTest

final class UserPreferencesTests: XCTestCase {
  func testDefaultValues() throws {
    // Use a custom UserDefaults suite for testing
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!

    // Clear any existing values
    testDefaults.removePersistentDomain(forName: "TestDefaults")

    let preferences = UserPreferences(userDefaults: testDefaults)

    // Test default values
    XCTAssertEqual(preferences.duration, 1500) // 25 minutes default
    XCTAssertEqual(preferences.isSoundEnabled, true)
    XCTAssertEqual(preferences.selectedSound, .default)
  }

  func testDurationPersistence() throws {
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!
    testDefaults.removePersistentDomain(forName: "TestDefaults")

    let preferences = UserPreferences(userDefaults: testDefaults)

    // Change duration
    preferences.duration = 3600 // 1 hour

    // Create new preferences instance to verify persistence
    let preferences2 = UserPreferences(userDefaults: testDefaults)
    XCTAssertEqual(preferences2.duration, 3600)
  }

  func testSoundPersistence() throws {
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!
    testDefaults.removePersistentDomain(forName: "TestDefaults")

    let preferences = UserPreferences(userDefaults: testDefaults)

    // Change sound enabled state
    preferences.isSoundEnabled = false

    // Create new preferences instance to verify persistence
    let preferences2 = UserPreferences(userDefaults: testDefaults)
    XCTAssertEqual(preferences2.isSoundEnabled, false)
  }

  func testResetToDefaults() throws {
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!
    testDefaults.removePersistentDomain(forName: "TestDefaults")

    let preferences = UserPreferences(userDefaults: testDefaults)

    // Change values
    preferences.duration = 7200
    preferences.isSoundEnabled = false

    // Reset
    preferences.resetToDefaults()

    // Verify defaults are restored
    XCTAssertEqual(preferences.duration, 1500)
    XCTAssertEqual(preferences.isSoundEnabled, true)
    XCTAssertEqual(preferences.selectedSound, .default)
  }

  func testTimerSoundEnum() throws {
    // Test all cases
    XCTAssertEqual(TimerSound.allCases.count, 1)
    XCTAssertTrue(TimerSound.allCases.contains(.default))

    // Test raw values
    XCTAssertEqual(TimerSound.default.rawValue, "default")

    // Test display names
    XCTAssertEqual(TimerSound.default.displayName, "Default")
  }

  func testMockUserPreferences() throws {
    let mockPreferences = MockUserPreferences(
      duration: 600,
      isSoundEnabled: false,
      selectedSound: .default
    )

    // Test initial values
    XCTAssertEqual(mockPreferences.duration, 600)
    XCTAssertEqual(mockPreferences.isSoundEnabled, false)
    XCTAssertEqual(mockPreferences.selectedSound, .default)

    // Test mutations
    mockPreferences.duration = 1200
    mockPreferences.isSoundEnabled = true

    XCTAssertEqual(mockPreferences.duration, 1200)
    XCTAssertEqual(mockPreferences.isSoundEnabled, true)

    // Test reset
    mockPreferences.resetToDefaults()
    XCTAssertEqual(mockPreferences.duration, 1500)
    XCTAssertEqual(mockPreferences.isSoundEnabled, true)
    XCTAssertEqual(mockPreferences.selectedSound, .default)
  }

  func testSharedInstance() throws {
    let shared1 = UserPreferences.shared
    let shared2 = UserPreferences.shared

    // Verify it's the same instance
    XCTAssertTrue(shared1 === shared2)
  }
}