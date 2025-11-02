// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "RadialTimer",
  platforms: [.macOS(.v14)],
  products: [
    .library(name: "TimerFeature", targets: ["TimerFeature"]),
    .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
  ],
  dependencies: [
    .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.3.0"),
  ],
  targets: [
    .target(
      name: "TimerFeature",
      dependencies: [
        .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
      ]
    ),
    .target(
      name: "SettingsFeature",
      dependencies: []
    ),

    .testTarget(name: "TimerFeatureTests", dependencies: ["TimerFeature"]),
    .testTarget(name: "SettingsFeatureTests", dependencies: ["SettingsFeature"]),
  ]
)
