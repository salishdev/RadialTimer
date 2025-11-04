@testable import SettingsFeature
import UserPreferences
import XCTest

final class SettingsFeatureTests: XCTestCase {
  @MainActor
  func testSettingsViewModelInitialization() throws {
    let mockPreferences = MockUserPreferences(
      duration: 1800,
      selectedSound: .none
    )
    let viewModel = GeneralSettingsView.SettingsViewModel(userPreferences: mockPreferences)

    // Test that view model loads initial values from preferences
    XCTAssertEqual(viewModel.selectedSound, .none)
  }

  @MainActor
  func testSoundSelectionPersistence() throws {
    let mockPreferences = MockUserPreferences(selectedSound: .default)
    let viewModel = GeneralSettingsView.SettingsViewModel(userPreferences: mockPreferences)

    // Change sound selection
    viewModel.selectedSound = .none

    // Verify it updates the mock preferences
    XCTAssertEqual(mockPreferences.selectedSound, .none)

    // Change to default
    viewModel.selectedSound = .default
    XCTAssertEqual(mockPreferences.selectedSound, .default)
  }

  @MainActor
  func testConfigureMethod() throws {
    let mockPreferences1 = MockUserPreferences(selectedSound: .default)
    let mockPreferences2 = MockUserPreferences(selectedSound: .none)

    let viewModel = GeneralSettingsView.SettingsViewModel(userPreferences: mockPreferences1)
    XCTAssertEqual(viewModel.selectedSound, .default)

    // Configure with different preferences
    viewModel.configure(with: mockPreferences2)
    XCTAssertEqual(viewModel.selectedSound, .none)
  }

  @MainActor
  func testSoundOptionDisplayNames() throws {
    XCTAssertEqual(SoundOption.default.displayName, "Default")
    XCTAssertEqual(SoundOption.none.displayName, "None (Silent)")
  }

  @MainActor
  func testSoundPreviewForSilentOption() throws {
    let mockPreferences = MockUserPreferences(selectedSound: .none)
    let viewModel = GeneralSettingsView.SettingsViewModel(userPreferences: mockPreferences)

    // Preview sound when silent is selected should not crash
    viewModel.previewSound()

    // Stop preview should also work without issues
    viewModel.stopPreview()
  }
}
