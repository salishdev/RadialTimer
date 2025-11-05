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
    preferences.customSoundURL = URL(fileURLWithPath: "/tmp/test.mp3")

    // Reset
    preferences.resetToDefaults()

    // Verify defaults are restored
    XCTAssertEqual(preferences.duration, 1500)
    XCTAssertEqual(preferences.isSoundEnabled, true)
    XCTAssertEqual(preferences.selectedSound, .default)
    XCTAssertNil(preferences.customSoundURL)
  }

  func testTimerSoundEnum() throws {
    // Test all cases (14 system sounds + 1 custom)
    XCTAssertEqual(TimerSound.allCases.count, 15)
    XCTAssertTrue(TimerSound.allCases.contains(.glass))
    XCTAssertTrue(TimerSound.allCases.contains(.custom))

    // Test raw values
    XCTAssertEqual(TimerSound.default.rawValue, "Glass")
    XCTAssertEqual(TimerSound.custom.rawValue, "Custom")

    // Test display names
    XCTAssertEqual(TimerSound.default.displayName, "Glass")
    XCTAssertEqual(TimerSound.custom.displayName, "Custom")

    // Test isSystemSound
    XCTAssertTrue(TimerSound.glass.isSystemSound)
    XCTAssertTrue(TimerSound.basso.isSystemSound)
    XCTAssertFalse(TimerSound.custom.isSystemSound)
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

  // MARK: - Custom Sound Tests

  func testCustomSoundURLPersistence() throws {
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!
    testDefaults.removePersistentDomain(forName: "TestDefaults")

    let preferences = UserPreferences(userDefaults: testDefaults)

    // Set custom sound URL
    let testURL = URL(fileURLWithPath: "/tmp/custom_sound.mp3")
    preferences.customSoundURL = testURL

    // Create new preferences instance to verify persistence
    let preferences2 = UserPreferences(userDefaults: testDefaults)
    XCTAssertEqual(preferences2.customSoundURL?.path, testURL.path)
  }

  func testCustomSoundFilename() throws {
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!
    testDefaults.removePersistentDomain(forName: "TestDefaults")

    let preferences = UserPreferences(userDefaults: testDefaults)

    // Test nil filename when no custom sound
    XCTAssertNil(preferences.customSoundFilename)

    // Set custom sound URL
    let testURL = URL(fileURLWithPath: "/tmp/my_custom_sound.mp3")
    preferences.customSoundURL = testURL

    // Verify filename is extracted correctly
    XCTAssertEqual(preferences.customSoundFilename, "my_custom_sound.mp3")
  }

  func testCustomSoundURLRemoval() throws {
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!
    testDefaults.removePersistentDomain(forName: "TestDefaults")

    let preferences = UserPreferences(userDefaults: testDefaults)

    // Set custom sound URL
    let testURL = URL(fileURLWithPath: "/tmp/custom_sound.mp3")
    preferences.customSoundURL = testURL
    XCTAssertNotNil(preferences.customSoundURL)

    // Remove custom sound URL
    preferences.customSoundURL = nil

    // Verify persistence of removal
    let preferences2 = UserPreferences(userDefaults: testDefaults)
    XCTAssertNil(preferences2.customSoundURL)
  }

  func testMockUserPreferencesWithCustomSound() throws {
    let testURL = URL(fileURLWithPath: "/tmp/test.mp3")
    let mockPreferences = MockUserPreferences(
      duration: 600,
      isSoundEnabled: false,
      selectedSound: .custom,
      customSoundURL: testURL
    )

    // Test initial values
    XCTAssertEqual(mockPreferences.selectedSound, .custom)
    XCTAssertEqual(mockPreferences.customSoundURL?.path, testURL.path)
    XCTAssertEqual(mockPreferences.customSoundFilename, "test.mp3")

    // Test reset clears custom sound
    mockPreferences.resetToDefaults()
    XCTAssertNil(mockPreferences.customSoundURL)
    XCTAssertNil(mockPreferences.customSoundFilename)
  }
}