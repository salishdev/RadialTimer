@testable import SettingsFeature
import UserPreferences
import XCTest

final class SettingsFeatureTests: XCTestCase {
  @MainActor
  func testSettingsViewModelInitialization() throws {
    let mockPreferences = MockUserPreferences(
      duration: 1800,
      isSoundEnabled: false,
      selectedSound: .default
    )
    let viewModel = GeneralSettingsView.SettingsViewModel(userPreferences: mockPreferences)

    // Test that view model loads initial values from preferences
    XCTAssertEqual(viewModel.selectedSound, .default)
  }

  @MainActor
  func testSoundSelectionPersistence() throws {
    let mockPreferences = MockUserPreferences(selectedSound: .default)
    let viewModel = GeneralSettingsView.SettingsViewModel(userPreferences: mockPreferences)

    // Verify initial state
    XCTAssertEqual(viewModel.selectedSound, .default)
    XCTAssertEqual(mockPreferences.selectedSound, .default)
  }

  @MainActor
  func testConfigureMethod() throws {
    let mockPreferences1 = MockUserPreferences(selectedSound: .default)
    let mockPreferences2 = MockUserPreferences(selectedSound: .default)

    let viewModel = GeneralSettingsView.SettingsViewModel(userPreferences: mockPreferences1)
    XCTAssertEqual(viewModel.selectedSound, .default)

    // Configure with different preferences
    viewModel.configure(with: mockPreferences2)
    XCTAssertEqual(viewModel.selectedSound, .default)
  }

  @MainActor
  func testTimerSoundDisplayNames() throws {
    XCTAssertEqual(TimerSound.default.displayName, "Glass")
    XCTAssertEqual(TimerSound.custom.displayName, "Custom")
  }

  @MainActor
  func testSoundPreview() throws {
    let mockPreferences = MockUserPreferences(selectedSound: .default)
    let viewModel = GeneralSettingsView.SettingsViewModel(userPreferences: mockPreferences)

    // Preview sound should not crash
    viewModel.previewSound()

    // Stop preview should also work without issues
    viewModel.stopPreview()
  }
}
