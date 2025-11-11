import SwiftUI

public struct SettingsView: View {
  // Public initializer for external use
  public init() {}

  // Sidebar selection
  @State private var selection: SettingsSection? = .general

  public var body: some View {
    NavigationSplitView {
      // Sidebar
      List(SettingsSection.allCases, selection: $selection) { section in
        Label(section.title, systemImage: section.systemImage)
          .tag(section)
      }
      .navigationTitle("Settings")
      .listStyle(.sidebar)
    } detail: {
      // Detail pane for the selected section
      Group {
        switch selection {
        case .general:
          GeneralSettingsView()
        case .about:
          AboutView(icon: Image(nsImage: NSApplication.shared.applicationIconImage))
        case .none:
          Text("Select a category from the sidebar")
            .foregroundStyle(.secondary)
        }
      }
      .navigationTitle(selection?.title ?? "Settings")
//      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .frame(width: 400, height: 400)
    }
  }
}

// MARK: - Sidebar Model

private enum SettingsSection: String, CaseIterable, Identifiable, Hashable {
  case general
  case about

  var id: String { rawValue }

  var title: String {
    switch self {
    case .general: return "General"
    case .about: return "About"
    }
  }

  var systemImage: String {
    switch self {
    case .general: return "gearshape"
    case .about: return "paintbrush"
    }
  }
}

#Preview {
  SettingsView()
}
