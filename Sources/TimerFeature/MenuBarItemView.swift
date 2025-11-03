import Playgrounds
import SwiftUI

public struct MenuBarItemView: View {
  public init(viewModel: TimerViewModel) {
    self.viewModel = viewModel
  }

  public let color: Color = .primary
  public let viewModel: TimerViewModel

  public var body: some View {
    ClockView(
      progress: Double(viewModel.timeRemaining) / Double(viewModel.duration),
      color: viewModel.isTimerExpired ? Color.red : color
    )
  }
}

#Preview("") {
  MenuBarItemView(viewModel: TimerViewModel())
    .frame(width: 100, height: 100)
    .padding()
}

#Preview("15min remaining") {
  MenuBarItemView(viewModel: TimerViewModel(timeRemaining: 60 * 15))
    .frame(width: 100, height: 100)
    .padding()
}

#Preview("45min remaining") {
  MenuBarItemView(viewModel: TimerViewModel(timeRemaining: 60 * 45))
    .frame(width: 100, height: 100)
    .padding()
}

#Preview("Expired") {
  MenuBarItemView(viewModel: TimerViewModel(timeRemaining: 0, isTimerExpired: true))
    .frame(width: 100, height: 100)
    .padding()
}
