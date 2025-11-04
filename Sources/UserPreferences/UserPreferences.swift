import Foundation
import Observation

/// Concrete implementation of UserPreferencesProtocol that manages user preferences
/// using UserDefaults for persistence and @Observable for reactivity.
@Observable
public final class UserPreferences: UserPreferencesProtocol {
  /// Shared instance for convenience (can still create custom instances for testing)
  public static let shared = UserPreferences()

  private let userDefaults: UserDefaults

  /// The timer duration in seconds
  public var duration: Int {
    didSet {
      userDefaults.set(duration, forKey: SettingsKey.duration.rawValue)
    }
  }

  /// Whether sound is enabled when the timer completes
  public var isSoundEnabled: Bool {
    didSet {
      userDefaults.set(isSoundEnabled, forKey: SettingsKey.isSoundEnabled.rawValue)
    }
  }

  /// The selected timer sound for timer completion
  public var selectedSound: TimerSound {
    didSet {
      userDefaults.set(selectedSound.rawValue, forKey: SettingsKey.selectedSound.rawValue)
    }
  }

  /// Initialize with optional custom UserDefaults (useful for testing)
  /// - Parameter userDefaults: The UserDefaults instance to use. Defaults to .standard
  public init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults

    // Load saved values or use defaults
    self.duration = userDefaults.object(forKey: SettingsKey.duration.rawValue) as? Int ?? 1500 // 25 minutes default
    self.isSoundEnabled = userDefaults.object(forKey: SettingsKey.isSoundEnabled.rawValue) as? Bool ?? true

    let soundRawValue = userDefaults.string(forKey: SettingsKey.selectedSound.rawValue) ?? TimerSound.default.rawValue
    self.selectedSound = TimerSound(rawValue: soundRawValue) ?? .default
  }

  /// Resets all settings to their default values
  public func resetToDefaults() {
    duration = 1500 // 25 minutes
    isSoundEnabled = true
    selectedSound = .default
  }
}

/// Type-safe keys for UserDefaults storage
enum SettingsKey: String {
  case duration = "duration"
  case isSoundEnabled = "isSoundEnabled"
  case selectedSound = "selectedSound"
}
