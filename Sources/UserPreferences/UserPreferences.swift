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

  /// The URL of the custom sound file (if custom sound is selected)
  public var customSoundURL: URL? {
    didSet {
      if let url = customSoundURL {
        userDefaults.set(url.path, forKey: SettingsKey.customSoundPath.rawValue)
      } else {
        userDefaults.removeObject(forKey: SettingsKey.customSoundPath.rawValue)
      }
    }
  }

  /// The filename of the custom sound (computed from customSoundURL)
  public var customSoundFilename: String? {
    return customSoundURL?.lastPathComponent
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

    // Load custom sound URL if it exists
    if let customSoundPath = userDefaults.string(forKey: SettingsKey.customSoundPath.rawValue) {
      self.customSoundURL = URL(fileURLWithPath: customSoundPath)
    } else {
      self.customSoundURL = nil
    }
  }

  /// Resets all settings to their default values
  public func resetToDefaults() {
    duration = 1500 // 25 minutes
    isSoundEnabled = true
    selectedSound = .default
    customSoundURL = nil
  }
}

/// Type-safe keys for UserDefaults storage
enum SettingsKey: String {
  case duration = "duration"
  case isSoundEnabled = "isSoundEnabled"
  case selectedSound = "selectedSound"
  case customSoundPath = "customSoundPath"
}
