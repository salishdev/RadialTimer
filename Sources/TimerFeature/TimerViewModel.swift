import AppSettings
import AVFoundation
import Observation
import SwiftUI

@Observable
public final class TimerViewModel {
  // MARK: - Properties

  public var timeRemaining: Int
  public var duration: Int {
    didSet {
      appSettings?.duration = duration
    }
  }

  public var isTimerOn: Bool = false
  public var isTimerExpired: Bool = false

  // Private
  private var timerTask: Task<Void, Never>?
  private var soundPlayer: AVPlayer?
  private var appSettings: AppSettingsProtocol?

  // MARK: - Computed Properties

  public var durationAsDouble: Double {
    get { Double(duration) }
    set {
      duration = Int(newValue)
      durationChanged(newValue)
    }
  }

  public var formattedTimeRemaining: String {
    var rem = timeRemaining

    let hours = rem / 3600
    rem %= 3600
    let minutes = rem / 60
    rem %= 60
    let seconds = rem

    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
  }

  // MARK: - Initialization

  public init(
    timeRemaining: Int? = nil,
    duration: Int? = nil,
    isTimerOn: Bool = false,
    isTimerExpired: Bool = false,
    appSettings: AppSettingsProtocol? = nil
  ) {
    self.appSettings = appSettings

    // If duration is explicitly provided, use it. Otherwise, load from appSettings if available
    let effectiveDuration: Int
    if let explicitDuration = duration {
      effectiveDuration = explicitDuration
    } else if let settings = appSettings {
      effectiveDuration = settings.duration
    } else {
      effectiveDuration = 60 * 60
    }

    self.duration = effectiveDuration
    self.timeRemaining = timeRemaining ?? effectiveDuration
    self.isTimerOn = isTimerOn
    self.isTimerExpired = isTimerExpired

    // Initialize sound player
    loadSound()
  }

  /// Configure the view model with AppSettings from the environment
  public func configure(with appSettings: AppSettingsProtocol) {
    self.appSettings = appSettings
    // Sync current values from settings
    duration = appSettings.duration
    timeRemaining = appSettings.duration
    loadSound()
  }

  deinit {
    timerTask?.cancel()
  }

  // MARK: - Sound Management

  private func loadSound() {
    // Check user's sound preference from settings
    let soundOption = appSettings?.selectedSound ?? .default

    // If sound is disabled, don't load any sound
    if soundOption == .none {
      soundPlayer = nil
      return
    }

    // Load the appropriate sound file
    let fileName = "Update.caf"
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "") else {
      print("Sound file not found: \(fileName)")
      return
    }
    soundPlayer = AVPlayer(url: url)
  }

  private func playSound() {
    // Reload sound in case preferences changed
    loadSound()

    // Play if sound is enabled
    soundPlayer?.seek(to: .zero)
    soundPlayer?.play()
  }

  // MARK: - Actions

  public func toggleTimer() {
    isTimerOn.toggle()

    if isTimerOn {
      if isTimerExpired {
        // Reset timer duration if expired
        timeRemaining = duration
        isTimerExpired = false
      }

      startTimer()
    } else {
      stopTimer()
    }
  }

  public func resetTimer() {
    timeRemaining = duration
    isTimerExpired = false
    isTimerOn = false
    stopTimer()
  }

  public func durationChanged(_ value: Double) {
    duration = Int(value)
    timeRemaining = duration
    isTimerExpired = false
    isTimerOn = false
    stopTimer()
  }

  // MARK: - Private Timer Management

  private func startTimer() {
    timerTask?.cancel()

    timerTask = Task { @MainActor in
      while !Task.isCancelled && isTimerOn {
        try? await Task.sleep(nanoseconds: 1000000000) // 1 second

        if !Task.isCancelled {
          timerTicked()
        }
      }
    }
  }

  private func stopTimer() {
    timerTask?.cancel()
    timerTask = nil
  }

  private func timerTicked() {
    timeRemaining -= 1

    if timeRemaining == 0 {
      isTimerOn = false
      isTimerExpired = true
      playSound()
      stopTimer()
    }
  }
}
