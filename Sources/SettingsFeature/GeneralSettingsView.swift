import SwiftUI
import UserPreferences

public struct GeneralSettingsView: View {
  @State private var viewModel = SettingsViewModel()
  @Environment(\.userPreferences) private var userPreferences
  @State private var showingFilePicker = false
  @State private var showingError = false
  @State private var errorMessage = ""

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
            // System Sounds Section
            Text("System Sounds")
              .font(.caption)
              .foregroundColor(.secondary)
              .padding(.bottom, 4)

            ForEach(TimerSound.allCases.filter { $0.isSystemSound }, id: \.self) { option in
              soundOptionRow(for: option)
            }

            Divider()
              .padding(.vertical, 8)

            // Custom Sound Section
            Text("Custom Sound")
              .font(.caption)
              .foregroundColor(.secondary)
              .padding(.bottom, 4)

            if let customFilename = userPreferences.customSoundFilename {
              // Show custom sound option
              soundOptionRow(for: .custom)

              HStack(spacing: 8) {
                Image(systemName: "doc.fill")
                  .foregroundColor(.secondary)
                  .imageScale(.small)

                Text(customFilename)
                  .font(.caption)
                  .foregroundColor(.secondary)

                Spacer()

                Button("Replace") {
                  showingFilePicker = true
                }
                .buttonStyle(.borderless)
                .controlSize(.small)

                Button("Remove") {
                  viewModel.removeCustomSound()
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
              }
              .padding(.vertical, 4)
              .padding(.horizontal, 8)
            } else {
              // Show import button
              Button(action: {
                showingFilePicker = true
              }) {
                HStack {
                  Image(systemName: "plus.circle.fill")
                  Text("Add Custom Sound")
                }
              }
              .buttonStyle(.borderless)
              .padding(.vertical, 4)
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
    .frame(width: 400, height: 400)
    .fileImporter(
      isPresented: $showingFilePicker,
      allowedContentTypes: [.audio],
      allowsMultipleSelection: false
    ) { result in
      handleFileImport(result: result)
    }
    .alert("Error", isPresented: $showingError) {
      Button("OK") {
        showingError = false
      }
    } message: {
      Text(errorMessage)
    }
    .onAppear {
      viewModel.configure(with: userPreferences)
    }
  }

  // MARK: - Helper Views

  @ViewBuilder
  private func soundOptionRow(for option: TimerSound) -> some View {
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

  // MARK: - Helper Methods

  private func handleFileImport(result: Result<[URL], Error>) {
    switch result {
    case .success(let urls):
      guard let url = urls.first else { return }

      do {
        try viewModel.importCustomSound(from: url)
      } catch {
        errorMessage = error.localizedDescription
        showingError = true
      }

    case .failure(let error):
      errorMessage = error.localizedDescription
      showingError = true
    }
  }
}

#Preview {
  GeneralSettingsView()
    .padding()
}
