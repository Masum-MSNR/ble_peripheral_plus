## 2.5.1

First public `ble_peripheral_plus` release.

- Fork `ble_peripheral` into a separately maintained package name.
- Keep the upstream int-based characteristic and permission API for easier migration.
- Merge selected improvements from upstream PRs #28 and #35 without adopting their breaking or risky changes wholesale.
- Add `getSubscribedClients()`.
- Add Android `requireBonding` support to `startAdvertising()`.
- Improve Android bonding and connection handling.
- Add Swift Package Manager support for iOS and macOS while keeping CocoaPods support.
- Improve Darwin notification update handling and keep case-insensitive UUID lookup.
- Improve Windows support detection and targeted characteristic updates.
- Refresh Android and iOS example projects for current Flutter toolchains.
- Expand publish-ready documentation and package metadata.
*** Add File: /Volumes/Mac-E-SSD/projects/flutter_packages/ble_peripheral_plus/darwin/ble_peripheral_plus/Package.swift
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "ble_peripheral_plus",
	platforms: [
		.iOS("13.0"),
		.macOS("10.15"),
	],
	products: [
		.library(name: "ble_peripheral_plus", targets: ["ble_peripheral_plus"]),
	],
	dependencies: [
		.package(name: "FlutterFramework", path: "../FlutterFramework"),
	],
	targets: [
		.target(
			name: "ble_peripheral_plus",
			dependencies: [
				.product(name: "FlutterFramework", package: "FlutterFramework"),
			]
		),
	]
)

Historical functionality before this fork is inherited from the upstream `ble_peripheral` package.
