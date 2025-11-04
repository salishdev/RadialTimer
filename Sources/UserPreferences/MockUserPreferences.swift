import Foundation

/// Mock implementation of UserPreferencesProtocol for testing purposes.
/// This allows tests to run in isolation without persisting to UserDefaults.
public final class MockUserPreferences: UserPreferencesProtocol {
  public var duration: Int
  public var isSoundEnabled: Bool
  public var selectedSound: TimerSound

  /// Initialize with optional custom values for testing
  public init(
    duration: Int = 1500,
    isSoundEnabled: Bool = true,
    selectedSound: TimerSound = .default
  ) {
    self.duration = duration
    self.isSoundEnabled = isSoundEnabled
    self.selectedSound = selectedSound
  }

  /// Resets all settings to their default values
  public func resetToDefaults() {
    duration = 1500
    isSoundEnabled = true
    selectedSound = .default
  }
}
