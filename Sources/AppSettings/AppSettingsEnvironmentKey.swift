//
//  AppSettingsEnvironmentKey.swift
//  RadialTimer
//

import SwiftUI

/// Environment key for injecting AppSettings throughout the SwiftUI view hierarchy
private struct AppSettingsEnvironmentKey: EnvironmentKey {
  static let defaultValue: AppSettingsProtocol = AppSettings.shared
}

/// Extension to provide convenient access to AppSettings via @Environment
public extension EnvironmentValues {
  var appSettings: AppSettingsProtocol {
    get { self[AppSettingsEnvironmentKey.self] }
    set { self[AppSettingsEnvironmentKey.self] = newValue }
  }
}

/// View modifier to inject AppSettings into the environment
public extension View {
  func appSettings(_ settings: AppSettingsProtocol) -> some View {
    environment(\.appSettings, settings)
  }
}