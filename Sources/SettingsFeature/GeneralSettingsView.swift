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
            ForEach(TimerSound.allCases.filter { $0.isSystemSound }, id: \.self) { option in
              soundOptionRow(for: option)
            }

            // Custom sound option
            customSoundRow()

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
  private func customSoundRow() -> some View {
    let hasCustomSound = userPreferences.customSoundFilename != nil
    let displayName = hasCustomSound ? (userPreferences.customSoundFilename ?? "Custom") : "Use your own sound..."

    HStack {
      Image(systemName: viewModel.selectedSound == .custom ? "circle.inset.filled" : "circle")
        .foregroundColor(viewModel.selectedSound == .custom ? .accentColor : .secondary)
        .imageScale(.medium)

      Text(displayName)
        .font(.body)
        .foregroundColor(hasCustomSound ? .primary : .secondary)

      Spacer()

      if hasCustomSound {
        Button(action: {
          showingFilePicker = true
        }) {
          Image(systemName: "folder.badge.plus")
            .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .help("Change sound")
      }

      Button(action: {
        if viewModel.selectedSound == .custom {
          viewModel.previewSound()
        }
      }) {
        Image(systemName: "speaker.wave.2")
          .foregroundColor(.secondary)
      }
      .buttonStyle(.plain)
      .help("Preview sound")
      .disabled(viewModel.selectedSound != .custom || !hasCustomSound)
      .opacity(viewModel.selectedSound == .custom && hasCustomSound ? 1 : 0.3)
    }
    .padding(.vertical, 4)
    .padding(.horizontal, 8)
    .background(
      RoundedRectangle(cornerRadius: 6)
        .fill(viewModel.selectedSound == .custom ? Color.accentColor.opacity(0.1) : Color.clear)
    )
    .contentShape(Rectangle())
    .onTapGesture {
      if hasCustomSound {
        viewModel.selectedSound = .custom
      } else {
        showingFilePicker = true
      }
    }
  }

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
