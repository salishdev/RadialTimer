//
//  AppSettings.swift
//  RadialTimer
//

import Foundation
import Observation

/// Concrete implementation of AppSettingsProtocol that manages app settings
/// using UserDefaults for persistence and @Observable for reactivity.
@Observable
public final class AppSettings: AppSettingsProtocol {
  /// Shared instance for convenience (can still create custom instances for testing)
  public static let shared = AppSettings()

  private let userDefaults: UserDefaults

  /// The timer duration in seconds
  public var duration: Int {
    didSet {
      userDefaults.set(duration, forKey: SettingsKey.duration.rawValue)
    }
  }

  /// The selected sound option for timer completion
  public var selectedSound: SoundOption {
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

    let soundRawValue = userDefaults.string(forKey: SettingsKey.selectedSound.rawValue) ?? SoundOption.default.rawValue
    self.selectedSound = SoundOption(rawValue: soundRawValue) ?? .default
  }

  /// Resets all settings to their default values
  public func resetToDefaults() {
    duration = 1500 // 25 minutes
    selectedSound = .default
  }
}

/// Type-safe keys for UserDefaults storage
enum SettingsKey: String {
  case duration = "duration"
  case selectedSound = "selectedSound"
}
