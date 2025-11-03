//
//  AppSettingsProtocol.swift
//  RadialTimer
//

import Foundation

/// Protocol defining all application settings.
/// This protocol provides a clean interface for accessing and modifying app settings,
/// allowing for easy testing with mock implementations.
public protocol AppSettingsProtocol: AnyObject {
  /// The timer duration in seconds
  var duration: Int { get set }

  /// The selected sound option for timer completion
  var selectedSound: SoundOption { get set }

  /// Resets all settings to their default values
  func resetToDefaults()
}

/// Sound options available for timer completion
public enum SoundOption: String, CaseIterable {
  case `default` = "default"
  case none = "none"

  /// User-friendly display name for the sound option
  public var displayName: String {
    switch self {
    case .default:
      return "Default"
    case .none:
      return "None (Silent)"
    }
  }
}