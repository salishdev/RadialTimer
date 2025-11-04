import SwiftUI

public struct AboutView: View {
  public var icon: Image

  public init(icon: Image) {
    self.icon = icon
  }

  public var body: some View {
    VStack {
      icon
      HStack {
        Text("Radial Timer")
          .font(.largeTitle.bold())
      }
    }
    .frame(width: 300, height: 200)
  }
}

#Preview {
  AboutView(icon: Image(nsImage: NSApplication.shared.applicationIconImage))
}
