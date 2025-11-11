import AppKit
import Foundation
import SwiftUI
import UserPreferences

public extension GeneralSettingsView {
  @Observable
  final class SettingsViewModel {
    // MARK: - Properties

    public var selectedSound: TimerSound {
      didSet {
        userPreferences?.selectedSound = selectedSound
      }
    }

    private var soundPlayer: NSSound?
    private var userPreferences: UserPreferencesProtocol?

    // MARK: - Initialization

    public init(userPreferences: UserPreferencesProtocol? = nil) {
      self.userPreferences = userPreferences
      // Load saved sound preference from settings
      self.selectedSound = userPreferences?.selectedSound ?? .default
    }

    /// Configure the view model with UserPreferences from the environment
    public func configure(with userPreferences: UserPreferencesProtocol) {
      self.userPreferences = userPreferences
      // Sync current value from settings
      self.selectedSound = userPreferences.selectedSound
    }

    // MARK: - Methods

    public func previewSound() {
      // Handle custom sound vs system sound
      if selectedSound == .custom {
        // Load custom sound from URL
        if let customSoundURL = userPreferences?.customSoundURL {
          soundPlayer = NSSound(contentsOf: customSoundURL, byReference: false)

          if soundPlayer == nil {
            print("Failed to load custom sound from: \(customSoundURL.path)")
            // Fallback to default system sound
            soundPlayer = NSSound(named: TimerSound.default.rawValue)
          }
        } else {
          print("Custom sound selected but no URL provided, using default")
          soundPlayer = NSSound(named: TimerSound.default.rawValue)
        }
      } else {
        // Load the selected macOS system sound
        soundPlayer = NSSound(named: selectedSound.rawValue)
      }

      soundPlayer?.play()
    }

    public func stopPreview() {
      soundPlayer?.stop()
      soundPlayer = nil
    }

    // MARK: - Custom Sound Management

    /// Imports a custom sound file
    /// - Parameter url: The URL of the audio file to import
    /// - Throws: CustomSoundError if import fails
    public func importCustomSound(from url: URL) throws {
      let soundManager = CustomSoundManager.shared
      let copiedURL = try soundManager.importCustomSound(from: url)

      // Update user preferences
      userPreferences?.customSoundURL = copiedURL
      userPreferences?.selectedSound = .custom
      selectedSound = .custom
    }

    /// Removes the custom sound
    public func removeCustomSound() {
      do {
        try CustomSoundManager.shared.removeCustomSound()
        userPreferences?.customSoundURL = nil

        // Switch back to default system sound
        userPreferences?.selectedSound = .default
        selectedSound = .default
      } catch {
        print("Failed to remove custom sound: \(error)")
      }
    }
  }
}
