import SwiftUI
import SwiftUIIntrospect

struct MyButtonStyle: ButtonStyle {
  @State var isHovering = false

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .padding(2)
      .background(.white.opacity(isHovering ? 0.2 : 0.0))
      .cornerRadius(4.0)
      .contentShape(.rect())
      .onHover(perform: { hovering in
        isHovering = hovering
      })
  }
}

struct MenuButton: View {
  let imageName: String

  let action: () -> Void

  var body: some View {
    Button(action: action, label: {
      Image(systemName: imageName)
        .imageScale(.large)
        .frame(width: 16, height: 16)
        .padding(6)
        .background(.white.opacity(0.2), in: Circle())
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
    })
    .buttonStyle(MyButtonStyle())
    .focusable(false) // prevents focus and removes ring
  }
}

public struct MenuView: View {
  @Bindable public var viewModel: TimerViewModel
  public let onClose: () -> Void
  public let openSettings: () -> Void

  public init(viewModel: TimerViewModel, onClose: @escaping () -> Void = {}, openSettings: @escaping () -> Void = {}) {
    self.viewModel = viewModel
    self.onClose = onClose
    self.openSettings = openSettings
  }

  public var body: some View {
    VStack(spacing: 5) {
      Text(viewModel.formattedTimeRemaining)
        .font(.system(size: 36, weight: .light, design: .monospaced))
        .minimumScaleFactor(0.01)

      HStack(alignment: .center, spacing: 0) {
        MenuButton(imageName: viewModel.isTimerOn ? "pause.fill" : "play.fill") {
          viewModel.toggleTimer()
          onClose()
        }

        MenuButton(imageName: "arrow.counterclockwise") {
          viewModel.resetTimer()
          onClose()
        }
      }
      .padding(.horizontal, 4)

      Slider(
        value: $viewModel.durationAsDouble,
        in: 60 * 5 ... 60 * 60 * 2,
        step: 60 * 5
      )
      .padding(.horizontal, 4)
      .introspect(.slider, on: .macOS(.v10_15, .v11, .v12, .v13, .v14, .v15, .v26)) { slider in
        slider.numberOfTickMarks = 0
        slider.trackFillColor = NSColor.white
      }
    }
    .padding(5)
  }
}

#Preview(traits: .fixedLayout(width: 200, height: 200)) {
  MenuView(viewModel: TimerViewModel())
}
