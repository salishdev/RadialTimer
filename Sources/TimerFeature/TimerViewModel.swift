import AVFoundation
import Observation
import SwiftUI

@Observable
public final class TimerViewModel {
  // MARK: - Properties

  public var timeRemaining: Int
  public var duration: Int {
    didSet {
      UserDefaults.standard.set(duration, forKey: "duration")
    }
  }

  public var isTimerOn: Bool = false
  public var isTimerExpired: Bool = false
  public var color: Color = .primary

  // Private
  private var timerTask: Task<Void, Never>?
  private var soundPlayer: AVPlayer?

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
    color: Color = .primary,
    loadFromDefaults: Bool = true
  ) {
    // If duration is explicitly provided, use it. Otherwise, load from UserDefaults if allowed
    let effectiveDuration: Int
    if let explicitDuration = duration {
      effectiveDuration = explicitDuration
    } else if loadFromDefaults {
      effectiveDuration = UserDefaults.standard.object(forKey: "duration") as? Int ?? 60 * 60
    } else {
      effectiveDuration = 60 * 60
    }

    self.duration = effectiveDuration
    self.timeRemaining = timeRemaining ?? effectiveDuration
    self.isTimerOn = isTimerOn
    self.isTimerExpired = isTimerExpired
    self.color = color

    // Initialize sound player
    loadSound()
  }

  deinit {
    timerTask?.cancel()
  }

  // MARK: - Sound Management

  private func loadSound() {
    guard let url = Bundle.main.url(forResource: "Update.caf", withExtension: "") else {
      print("Sound file not found")
      return
    }
    soundPlayer = AVPlayer(url: url)
  }

  private func playSound() {
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
    print(duration)
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
