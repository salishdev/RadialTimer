import SwiftUI

/// Environment key for injecting UserPreferences throughout the SwiftUI view hierarchy
private struct UserPreferencesEnvironmentKey: EnvironmentKey {
  static let defaultValue: UserPreferencesProtocol = UserPreferences.shared
}

/// Extension to provide convenient access to UserPreferences via @Environment
public extension EnvironmentValues {
  var userPreferences: UserPreferencesProtocol {
    get { self[UserPreferencesEnvironmentKey.self] }
    set { self[UserPreferencesEnvironmentKey.self] = newValue }
  }
}

/// View modifier to inject UserPreferences into the environment
public extension View {
  func userPreferences(_ preferences: UserPreferencesProtocol) -> some View {
    environment(\.userPreferences, preferences)
  }
}
