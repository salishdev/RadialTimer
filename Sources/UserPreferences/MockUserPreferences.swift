import Foundation

/// Mock implementation of UserPreferencesProtocol for testing purposes.
/// This allows tests to run in isolation without persisting to UserDefaults.
public final class MockUserPreferences: UserPreferencesProtocol {
  public var duration: Int
  public var isSoundEnabled: Bool
  public var selectedSound: TimerSound
  public var customSoundURL: URL?

  public var customSoundFilename: String? {
    return customSoundURL?.lastPathComponent
  }

  /// Initialize with optional custom values for testing
  public init(
    duration: Int = 1500,
    isSoundEnabled: Bool = true,
    selectedSound: TimerSound = .default,
    customSoundURL: URL? = nil
  ) {
    self.duration = duration
    self.isSoundEnabled = isSoundEnabled
    self.selectedSound = selectedSound
    self.customSoundURL = customSoundURL
  }

  /// Resets all settings to their default values
  public func resetToDefaults() {
    duration = 1500
    isSoundEnabled = true
    selectedSound = .default
    customSoundURL = nil
  }
}
