import Foundation

/// Protocol defining all user preferences.
/// This protocol provides a clean interface for accessing and modifying user preferences,
/// allowing for easy testing with mock implementations.
public protocol UserPreferencesProtocol: AnyObject {
  /// The timer duration in seconds
  var duration: Int { get set }

  /// Whether sound is enabled when the timer completes
  var isSoundEnabled: Bool { get set }

  /// The selected timer sound for timer completion
  var selectedSound: TimerSound { get set }

  /// Resets all settings to their default values
  func resetToDefaults()
}

/// Timer sounds available for timer completion
public enum TimerSound: String, CaseIterable {
  case `default`

  /// User-friendly display name for the timer sound
  public var displayName: String {
    switch self {
    case .default:
      return "Default"
    }
  }
}
