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

    // Change sound
    preferences.selectedSound = .none

    // Create new preferences instance to verify persistence
    let preferences2 = UserPreferences(userDefaults: testDefaults)
    XCTAssertEqual(preferences2.selectedSound, .none)
  }

  func testResetToDefaults() throws {
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!
    testDefaults.removePersistentDomain(forName: "TestDefaults")

    let preferences = UserPreferences(userDefaults: testDefaults)

    // Change values
    preferences.duration = 7200
    preferences.selectedSound = .none

    // Reset
    preferences.resetToDefaults()

    // Verify defaults are restored
    XCTAssertEqual(preferences.duration, 1500)
    XCTAssertEqual(preferences.selectedSound, .default)
  }

  func testSoundOptionEnum() throws {
    // Test all cases
    XCTAssertEqual(SoundOption.allCases.count, 2)
    XCTAssertTrue(SoundOption.allCases.contains(.default))
    XCTAssertTrue(SoundOption.allCases.contains(.none))

    // Test raw values
    XCTAssertEqual(SoundOption.default.rawValue, "default")
    XCTAssertEqual(SoundOption.none.rawValue, "none")

    // Test display names
    XCTAssertEqual(SoundOption.default.displayName, "Default")
    XCTAssertEqual(SoundOption.none.displayName, "None (Silent)")
  }

  func testMockUserPreferences() throws {
    let mockPreferences = MockUserPreferences(
      duration: 600,
      selectedSound: .none
    )

    // Test initial values
    XCTAssertEqual(mockPreferences.duration, 600)
    XCTAssertEqual(mockPreferences.selectedSound, .none)

    // Test mutations
    mockPreferences.duration = 1200
    mockPreferences.selectedSound = .default

    XCTAssertEqual(mockPreferences.duration, 1200)
    XCTAssertEqual(mockPreferences.selectedSound, .default)

    // Test reset
    mockPreferences.resetToDefaults()
    XCTAssertEqual(mockPreferences.duration, 1500)
    XCTAssertEqual(mockPreferences.selectedSound, .default)
  }

  func testSharedInstance() throws {
    let shared1 = UserPreferences.shared
    let shared2 = UserPreferences.shared

    // Verify it's the same instance
    XCTAssertTrue(shared1 === shared2)
  }
}