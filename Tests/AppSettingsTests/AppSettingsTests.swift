//
//  AppSettingsTests.swift
//  RadialTimer
//

@testable import AppSettings
import XCTest

final class AppSettingsTests: XCTestCase {
  func testDefaultValues() throws {
    // Use a custom UserDefaults suite for testing
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!

    // Clear any existing values
    testDefaults.removePersistentDomain(forName: "TestDefaults")

    let settings = AppSettings(userDefaults: testDefaults)

    // Test default values
    XCTAssertEqual(settings.duration, 1500) // 25 minutes default
    XCTAssertEqual(settings.selectedSound, .default)
  }

  func testDurationPersistence() throws {
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!
    testDefaults.removePersistentDomain(forName: "TestDefaults")

    let settings = AppSettings(userDefaults: testDefaults)

    // Change duration
    settings.duration = 3600 // 1 hour

    // Create new settings instance to verify persistence
    let settings2 = AppSettings(userDefaults: testDefaults)
    XCTAssertEqual(settings2.duration, 3600)
  }

  func testSoundPersistence() throws {
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!
    testDefaults.removePersistentDomain(forName: "TestDefaults")

    let settings = AppSettings(userDefaults: testDefaults)

    // Change sound
    settings.selectedSound = .none

    // Create new settings instance to verify persistence
    let settings2 = AppSettings(userDefaults: testDefaults)
    XCTAssertEqual(settings2.selectedSound, .none)
  }

  func testResetToDefaults() throws {
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!
    testDefaults.removePersistentDomain(forName: "TestDefaults")

    let settings = AppSettings(userDefaults: testDefaults)

    // Change values
    settings.duration = 7200
    settings.selectedSound = .none

    // Reset
    settings.resetToDefaults()

    // Verify defaults are restored
    XCTAssertEqual(settings.duration, 1500)
    XCTAssertEqual(settings.selectedSound, .default)
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

  func testMockAppSettings() throws {
    let mockSettings = MockAppSettings(
      duration: 600,
      selectedSound: .none
    )

    // Test initial values
    XCTAssertEqual(mockSettings.duration, 600)
    XCTAssertEqual(mockSettings.selectedSound, .none)

    // Test mutations
    mockSettings.duration = 1200
    mockSettings.selectedSound = .default

    XCTAssertEqual(mockSettings.duration, 1200)
    XCTAssertEqual(mockSettings.selectedSound, .default)

    // Test reset
    mockSettings.resetToDefaults()
    XCTAssertEqual(mockSettings.duration, 1500)
    XCTAssertEqual(mockSettings.selectedSound, .default)
  }

  func testSharedInstance() throws {
    let shared1 = AppSettings.shared
    let shared2 = AppSettings.shared

    // Verify it's the same instance
    XCTAssertTrue(shared1 === shared2)
  }
}