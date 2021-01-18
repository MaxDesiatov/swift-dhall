// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-dhall",
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .executable(name: "dhall-grammar-encoder", targets: ["GrammarEncoder"]),
    .library(
      name: "Dhall",
      targets: ["Dhall"]
    ),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/palle-k/Covfefe", from: "0.6.1"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "Dhall",
      dependencies: ["Covfefe"],
      resources: [
        .copy("dhall-grammar.json"),
      ]
    ),
    .target(
      name: "GrammarEncoder",
      dependencies: ["Covfefe"]
    ),
    .testTarget(
      name: "DhallTests",
      dependencies: ["Dhall"]
    ),
  ]
)
