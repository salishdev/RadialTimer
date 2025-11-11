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
      Section {
        Toggle("Play a sound when timer expires", isOn: Binding(
          get: { userPreferences.isSoundEnabled },
          set: { userPreferences.isSoundEnabled = $0 }
        ).animation())

        if userPreferences.isSoundEnabled {
          VStack(alignment: .leading, spacing: 8) {
            // System sound option
            systemSoundRow()

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
    .frame(width: 400, height: 200)
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

  // MARK: - Computed Properties

  private var isSystemMode: Bool {
    viewModel.selectedSound != .custom
  }

  private var selectedSystemSound: Binding<TimerSound> {
    Binding(
      get: {
        if viewModel.selectedSound == .custom {
          return .glass // Default fallback
        }
        return viewModel.selectedSound
      },
      set: { newSound in
        if newSound != .custom {
          viewModel.selectedSound = newSound
        }
      }
    )
  }

  // MARK: - Helper Views

  @ViewBuilder
  private func soundRow(
    isActive: Bool,
    @ViewBuilder label: () -> some View,
    @ViewBuilder trailingButtons: () -> some View,
    onTap: @escaping () -> Void
  ) -> some View {
    HStack {
      Image(systemName: isActive ? "circle.inset.filled" : "circle")
        .foregroundColor(isActive ? .accentColor : .secondary)
        .imageScale(.medium)

      label()

      Spacer()

      trailingButtons()
    }
    .padding(.vertical, 4)
    .padding(.horizontal, 8)
    .background(
      RoundedRectangle(cornerRadius: 6)
        .fill(isActive ? Color.accentColor.opacity(0.1) : Color.clear)
    )
    .contentShape(Rectangle())
    .onTapGesture(perform: onTap)
  }

  @ViewBuilder
  private func previewButton(enabled: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Image(systemName: "speaker.wave.2")
        .foregroundColor(.secondary)
    }
    .buttonStyle(.plain)
    .help("Preview sound")
    .disabled(!enabled)
    .opacity(enabled ? 1 : 0.3)
  }

  @ViewBuilder
  private func systemSoundRow() -> some View {
    soundRow(
      isActive: isSystemMode,
    ) {
      Text("System")
        .font(.body)
    } trailingButtons: {
      Picker("", selection: selectedSystemSound) {
        ForEach(TimerSound.allCases.filter { $0.isSystemSound }, id: \.self) { sound in
          Text(sound.displayName).tag(sound)
        }
      }
      .labelsHidden()
      .disabled(!isSystemMode)
      .opacity(isSystemMode ? 1 : 0.5)

      previewButton(enabled: isSystemMode) {
        viewModel.previewSound()
      }
    } onTap: {
      if !isSystemMode {
        viewModel.selectedSound = .glass
      }
    }
  }

  @ViewBuilder
  private func customSoundRow() -> some View {
    let hasCustomSound = userPreferences.customSoundFilename != nil
    let isCustomMode = !isSystemMode
    let displayName = hasCustomSound ? userPreferences.customSoundFilename! : "Custom"

    soundRow(
      isActive: isCustomMode,
    ) {
      Text(displayName)
        .font(.body)
    } trailingButtons: {
      Button(action: {
        showingFilePicker = true
      }) {
        Image(systemName: "folder.badge.plus")
          .foregroundColor(.secondary)
      }
      .buttonStyle(.plain)
      .help("Change sound")
      .disabled(!isCustomMode)
      .opacity(isCustomMode ? 1 : 0.3)

      previewButton(enabled: isCustomMode && hasCustomSound) {
        viewModel.previewSound()
      }
    } onTap: {
      if hasCustomSound {
        viewModel.selectedSound = .custom
      } else {
        showingFilePicker = true
      }
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
