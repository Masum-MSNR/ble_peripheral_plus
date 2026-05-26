## 2.5.2

- Fix the Swift Package Manager product name so Flutter's generated iOS and macOS package graph resolves `ble_peripheral_plus` correctly.
- Keep the existing CocoaPods integration unchanged.

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

Historical functionality before this fork is inherited from the upstream `ble_peripheral` package.
