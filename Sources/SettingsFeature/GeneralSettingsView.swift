import SwiftUI
import UserPreferences

public struct GeneralSettingsView: View {
  @State private var viewModel = SettingsViewModel()
  @Environment(\.userPreferences) private var userPreferences

  public init() {}

  public var body: some View {
    Form {
      Section("Sound") {
        Toggle("Play a sound when timer expires", isOn: Binding(
          get: { userPreferences.isSoundEnabled },
          set: { userPreferences.isSoundEnabled = $0 }
        ).animation())

        if userPreferences.isSoundEnabled {
          VStack(alignment: .leading, spacing: 8) {
            ForEach(TimerSound.allCases, id: \.self) { option in
              HStack {
                Image(systemName: viewModel.selectedSound == option ? "circle.inset.filled" : "circle")
                  .foregroundColor(viewModel.selectedSound == option ? .accentColor : .secondary)
                  .imageScale(.medium)

                Text(option.displayName)
                  .font(.body)

                Spacer()

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

            Text("Choose a sound to play when the timer expires")
              .font(.caption)
              .foregroundColor(.secondary)
              .padding(.top, 4)
          }
          .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
        }
      }
    }
    .formStyle(.grouped)
    .frame(width: 400, height: 300)
    .onAppear {
      viewModel.configure(with: userPreferences)
    }
  }
}

#Preview {
  GeneralSettingsView()
    .padding()
}
