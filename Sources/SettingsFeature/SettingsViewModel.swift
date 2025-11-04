import AVFoundation
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

    private var soundPlayer: AVPlayer?
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
      let fileName = "Update.caf"
      guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
        return
      }

      soundPlayer = AVPlayer(url: url)
      soundPlayer?.seek(to: .zero)
      soundPlayer?.play()
    }

    public func stopPreview() {
      soundPlayer?.pause()
      soundPlayer = nil
    }
  }
}
