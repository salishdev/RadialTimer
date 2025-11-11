import SwiftUI

public struct AboutView: View {
  public var icon: Image

  private var year: String {
    "\(Calendar.current.component(.year, from: Date()))"
  }

  private var version: String {
    guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
          let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else { return "" }
    return "\(version) (\(build))"
  }

  public init(icon: Image) {
    self.icon = icon
  }

  public var body: some View {
    VStack {
      HStack {
        icon
          .resizable()
          .frame(width: 100, height: 100)

        VStack(alignment: .leading) {
          Text("Radial Timer")
            .font(.system(size: 18, weight: .bold))

          Text(version)
        }
      }

      HStack {
        Link("Website", destination: URL(string: "https://astere.software")!)
        Divider().frame(height: 20)
        Link("GitHub", destination: URL(string: "https://github.com/salishdev/RadialTimer")!)
        Divider().frame(height: 20)
        Link("Support", destination: URL(string: "mailto:support@astere.software")!)
      }

      Text("Copyright © \(year) Astere Software, LLC")
        .font(.footnote)
        .padding(.vertical, 5)
    }
    .frame(width: 300, height: 200)
  }
}

#Preview {
  AboutView(icon: Image(nsImage: NSApplication.shared.applicationIconImage))
}
