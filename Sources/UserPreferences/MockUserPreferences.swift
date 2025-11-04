import Foundation

/// Mock implementation of UserPreferencesProtocol for testing purposes.
/// This allows tests to run in isolation without persisting to UserDefaults.
public final class MockUserPreferences: UserPreferencesProtocol {
  public var duration: Int
  public var selectedSound: SoundOption

  /// Initialize with optional custom values for testing
  public init(
    duration: Int = 1500,
    selectedSound: SoundOption = .default
  ) {
    self.duration = duration
    self.selectedSound = selectedSound
  }

  /// Resets all settings to their default values
  public func resetToDefaults() {
    duration = 1500
    selectedSound = .default
  }
}
