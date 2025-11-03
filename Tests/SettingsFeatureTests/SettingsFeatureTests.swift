@testable import SettingsFeature
import AppSettings
import XCTest

final class SettingsFeatureTests: XCTestCase {
  @MainActor
  func testSettingsViewModelInitialization() throws {
    let mockSettings = MockAppSettings(
      duration: 1800,
      selectedSound: .none
    )
    let viewModel = SettingsView.SettingsViewModel(appSettings: mockSettings)

    // Test that view model loads initial values from settings
    XCTAssertEqual(viewModel.selectedSound, .none)
  }

  @MainActor
  func testSoundSelectionPersistence() throws {
    let mockSettings = MockAppSettings(selectedSound: .default)
    let viewModel = SettingsView.SettingsViewModel(appSettings: mockSettings)

    // Change sound selection
    viewModel.selectedSound = .none

    // Verify it updates the mock settings
    XCTAssertEqual(mockSettings.selectedSound, .none)

    // Change to default
    viewModel.selectedSound = .default
    XCTAssertEqual(mockSettings.selectedSound, .default)
  }

  @MainActor
  func testConfigureMethod() throws {
    let mockSettings1 = MockAppSettings(selectedSound: .default)
    let mockSettings2 = MockAppSettings(selectedSound: .none)

    let viewModel = SettingsView.SettingsViewModel(appSettings: mockSettings1)
    XCTAssertEqual(viewModel.selectedSound, .default)

    // Configure with different settings
    viewModel.configure(with: mockSettings2)
    XCTAssertEqual(viewModel.selectedSound, .none)
  }

  @MainActor
  func testSoundOptionDisplayNames() throws {
    XCTAssertEqual(SoundOption.default.displayName, "Default")
    XCTAssertEqual(SoundOption.none.displayName, "None (Silent)")
  }

  @MainActor
  func testSoundPreviewForSilentOption() throws {
    let mockSettings = MockAppSettings(selectedSound: .none)
    let viewModel = SettingsView.SettingsViewModel(appSettings: mockSettings)

    // Preview sound when silent is selected should not crash
    viewModel.previewSound()

    // Stop preview should also work without issues
    viewModel.stopPreview()
  }
}