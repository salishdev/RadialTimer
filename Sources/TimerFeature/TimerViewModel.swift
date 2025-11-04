import AppKit
import Observation
import SwiftUI

import UserPreferences

@Observable
public final class TimerViewModel {
  // MARK: - Properties

  public var timeRemaining: Int
  public var duration: Int {
    didSet {
      userPreferences?.duration = duration
    }
  }

  public var isTimerOn: Bool = false
  public var isTimerExpired: Bool = false

  // Private
  private var timerTask: Task<Void, Never>?
  private var soundPlayer: NSSound?
  private var userPreferences: UserPreferencesProtocol?

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
    userPreferences: UserPreferencesProtocol? = nil
  ) {
    self.userPreferences = userPreferences

    // If duration is explicitly provided, use it. Otherwise, load from userPreferences if available
    let effectiveDuration: Int
    if let explicitDuration = duration {
      effectiveDuration = explicitDuration
    } else if let preferences = userPreferences {
      effectiveDuration = preferences.duration
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

  /// Configure the view model with UserPreferences from the environment
  public func configure(with userPreferences: UserPreferencesProtocol) {
    self.userPreferences = userPreferences
    // Sync current values from settings
    duration = userPreferences.duration
    timeRemaining = userPreferences.duration
    loadSound()
  }

  deinit {
    timerTask?.cancel()
  }

  // MARK: - Sound Management

  private func loadSound() {
    // If sound is disabled, don't load any sound
    guard userPreferences?.isSoundEnabled == true else {
      soundPlayer = nil
      return
    }

    // Load the selected macOS system sound
    let soundName = userPreferences?.selectedSound.rawValue ?? TimerSound.default.rawValue
    soundPlayer = NSSound(named: soundName)

    if soundPlayer == nil {
      print("System sound not found: \(soundName)")
    }
  }

  private func playSound() {
    // Reload sound in case preferences changed
    loadSound()

    // Play if sound is enabled
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
        try? await Task.sleep(nanoseconds: 10000000) // 1 second

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
