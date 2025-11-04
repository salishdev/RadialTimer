import SwiftUI
import UserPreferences

public struct GeneralSettingsView: View {
  @State private var viewModel = SettingsViewModel()
  @Environment(\.userPreferences) private var userPreferences

  public init() {}

  public var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text("Settings")
        .font(.title2)
        .fontWeight(.semibold)

      VStack(alignment: .leading, spacing: 12) {
        Text("Timer Sound")
          .font(.headline)

        VStack(alignment: .leading, spacing: 8) {
          ForEach(SoundOption.allCases, id: \.self) { option in
            HStack {
              Image(systemName: viewModel.selectedSound == option ? "circle.inset.filled" : "circle")
                .foregroundColor(viewModel.selectedSound == option ? .accentColor : .secondary)
                .imageScale(.medium)

              Text(option.displayName)
                .font(.body)

              Spacer()

              if option != .none {
                Button(action: {
                  if viewModel.selectedSound == option {
                    viewModel.previewSound()
                  }
                }) {
                  Image(systemName: "speaker.wave.2")
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Preview sound")
                .disabled(viewModel.selectedSound != option)
                .opacity(viewModel.selectedSound == option ? 1 : 0.3)
              }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
              RoundedRectangle(cornerRadius: 6)
                .fill(viewModel.selectedSound == option ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
            .onTapGesture {
              viewModel.selectedSound = option
            }
          }
        }

        Text("Choose a sound to play when the timer expires")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
    .padding()
    .frame(width: 300, height: 200)
    .onAppear {
      viewModel.configure(with: userPreferences)
    }
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  GeneralSettingsView()
    .padding()
}
