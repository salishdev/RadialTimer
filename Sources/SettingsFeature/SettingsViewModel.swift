import AVFoundation
import Foundation
import SwiftUI
import AppSettings

public extension SettingsView {
  @Observable
  final class SettingsViewModel {
    // MARK: - Properties

    public var selectedSound: SoundOption {
      didSet {
        appSettings?.selectedSound = selectedSound
      }
    }

    private var soundPlayer: AVPlayer?
    private var appSettings: AppSettingsProtocol?

    // MARK: - Initialization

    public init(appSettings: AppSettingsProtocol? = nil) {
      self.appSettings = appSettings
      // Load saved sound preference from settings
      self.selectedSound = appSettings?.selectedSound ?? .default
    }

    /// Configure the view model with AppSettings from the environment
    public func configure(with appSettings: AppSettingsProtocol) {
      self.appSettings = appSettings
      // Sync current value from settings
      self.selectedSound = appSettings.selectedSound
    }

    // MARK: - Methods

    public func previewSound() {
      guard selectedSound != .none else { return }

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