import AVFoundation
import Foundation
import SwiftUI

public extension SettingsView {
  enum SoundOption: String, CaseIterable {
    case defaultSound = "Update"
    case disabled = "None"

    var displayName: String {
      switch self {
      case .defaultSound: return "Default"
      case .disabled: return "None (Silent)"
      }
    }

    var fileName: String? {
      switch self {
      case .defaultSound: return "Update.caf"
      case .disabled: return nil
      }
    }
  }

  @Observable
  final class SettingsViewModel {
    // MARK: - Properties

    public var selectedSound: SoundOption {
      didSet {
        UserDefaults.standard.set(selectedSound.rawValue, forKey: "selectedSound")
      }
    }

    private var soundPlayer: AVPlayer?

    // MARK: - Initialization

    public init() {
      // Load saved sound preference
      if let savedSound = UserDefaults.standard.string(forKey: "selectedSound"),
         let sound = SoundOption(rawValue: savedSound)
      {
        self.selectedSound = sound
      } else {
        self.selectedSound = .defaultSound
      }
    }

    // MARK: - Methods

    public func previewSound() {
      guard let fileName = selectedSound.fileName,
            let url = Bundle.main.url(forResource: fileName, withExtension: nil)
      else {
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
