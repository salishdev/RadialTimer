// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "RadialTimer",
  platforms: [.macOS(.v14)],
  products: [
    .library(name: "TimerFeature", targets: ["TimerFeature"]),
    .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
    .library(name: "AppSettings", targets: ["AppSettings"]),
  ],
  dependencies: [
    .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.3.0"),
  ],
  targets: [
    .target(
      name: "AppSettings",
      dependencies: []
    ),
    .target(
      name: "TimerFeature",
      dependencies: [
        .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
        "AppSettings",
      ]
    ),
    .target(
      name: "SettingsFeature",
      dependencies: [
        "AppSettings",
      ]
    ),

    .testTarget(name: "AppSettingsTests", dependencies: ["AppSettings"]),
    .testTarget(name: "TimerFeatureTests", dependencies: ["TimerFeature"]),
    .testTarget(name: "SettingsFeatureTests", dependencies: ["SettingsFeature"]),
  ]
)
