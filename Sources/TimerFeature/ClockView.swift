import SwiftUI

struct ClockView: View {
  var progress: Double
  var color: Color

  var body: some View {
    clock(progress)
  }

  func clock(_ progress: Double) -> some View {
    GeometryReader { proxy in
      ZStack {
        Circle()
          .fill(progress > 0.0 ? color.opacity(0.15) : color.opacity(0.60))
        Circle()
          .inset(by: proxy.size.width / 4)
          .trim(from: 0, to: progress)
          .stroke(color.opacity(0.75), style: StrokeStyle(lineWidth: proxy.size.width / 2))
          .rotationEffect(.radians(-.pi / 2))
          .animation(.linear, value: progress)
      }
    }
  }
}

#Preview {
  @Previewable @State var value: Double = 0
  var progress = 1.0 - value

  VStack {
    ClockView(progress: progress, color: progress > 0.0 ? .primary : .red)
      .frame(width: 100, height: 100)
    Slider(value: $value, in: 0.0 ... 1.0)
  }
  .padding()
}
