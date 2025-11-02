import SwiftUI

public struct CircularAnalogView: View {
  public init(viewModel: TimerViewModel) {
    self.viewModel = viewModel
  }

  public let viewModel: TimerViewModel

  public var body: some View {
    Canvas(
      opaque: true,
      rendersAsynchronously: false
    ) { context, size in
      let radius: CGFloat = min(size.width, size.height) * 0.48

      context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
      context.rotate(by: .degrees(-90))

      let bgPath = Path { p in
        p.move(to: .zero)
        p.addArc(
          center: .zero,
          radius: radius,
          startAngle: .zero,
          endAngle: Angle(degrees: 360),
          clockwise: false
        )
        p.closeSubpath()
      }

      context.fill(bgPath, with: .color(
        !viewModel.isTimerExpired ? viewModel.color.opacity(0.15) : Color.red.opacity(0.75)
      ))

      let path = Path { p in
        p.move(to: .zero)
        p.addArc(
          center: .zero,
          radius: radius,
          startAngle: .zero,
          endAngle: Angle(degrees: 360) * CGFloat(viewModel.timeRemaining) / CGFloat(viewModel.duration),
          clockwise: false
        )
        p.closeSubpath()
      }

      context.fill(path, with: .color(viewModel.color.opacity(0.75)))
    }
  }
}

#Preview("") {
  CircularAnalogView(viewModel: TimerViewModel())
}

#Preview("15min remaining") {
  CircularAnalogView(viewModel: TimerViewModel(timeRemaining: 60 * 15))
}

#Preview("45min remaining") {
  CircularAnalogView(viewModel: TimerViewModel(timeRemaining: 60 * 45))
}

#Preview("Expired") {
  CircularAnalogView(viewModel: TimerViewModel(timeRemaining: 0, isTimerExpired: true))
}
