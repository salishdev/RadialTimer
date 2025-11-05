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

  /// The URL of the custom sound file (if custom sound is selected)
  var customSoundURL: URL? { get set }

  /// The filename of the custom sound (computed from customSoundURL)
  var customSoundFilename: String? { get }

  /// Resets all settings to their default values
  func resetToDefaults()
}

/// Timer sounds available for timer completion
/// These correspond to macOS system sounds accessible via NSSound
public enum TimerSound: String, CaseIterable {
  case basso = "Basso"
  case blow = "Blow"
  case bottle = "Bottle"
  case frog = "Frog"
  case funk = "Funk"
  case glass = "Glass"
  case hero = "Hero"
  case morse = "Morse"
  case ping = "Ping"
  case pop = "Pop"
  case purr = "Purr"
  case sosumi = "Sosumi"
  case submarine = "Submarine"
  case tink = "Tink"
  case custom = "Custom"

  /// User-friendly display name for the timer sound
  public var displayName: String {
    return rawValue
  }

  /// Whether this is a system sound (vs custom sound)
  public var isSystemSound: Bool {
    return self != .custom
  }

  /// Default sound to use when no preference is set
  public static let `default`: TimerSound = .glass
}
