# Platform limitations

`ble_peripheral_plus` supports Android, iOS, macOS, and Windows, but BLE peripheral behavior is not identical across those platforms.

This document calls out the important platform limitations so app teams can design around them early.

## Apple platforms and manufacturer data

On Android and Windows, BLE advertising can include generic manufacturer data.

On iOS and macOS, CoreBluetooth peripheral advertising is more limited. In practice, Apple peripheral advertising reliably exposes:

- service UUIDs
- local name

Generic manufacturer-data advertising is not available in the same way as Android. If your app depends on arbitrary manufacturer data in advertisements, treat that path as Android-focused.

## Apple-to-Apple peripheral discovery

Advertising from an Apple device and scanning from another Apple device is not equivalent to Android-to-Android or Android-to-Apple BLE behavior.

In real testing, iOS and macOS can filter or hide some Apple-originated peripheral advertisements. This is a platform limitation, not a package bug.

What this means in practice:

- Android can usually discover Apple-advertised peripherals more reliably than iOS can.
- iOS and macOS are better treated as centrals that connect to non-Apple peripherals than as the only peripheral platform in a test plan.
- If you need stable cross-device peripheral discovery for production hardware, Android, Windows, Linux, or dedicated BLE hardware are the safer peripheral targets.

## Android advertisement packet size

On Android, advertising a long local name together with services can overflow the advertisement packet and fail with `ADVERTISE_FAILED_DATA_TOO_LARGE`.

Practical guidance:

- Keep `localName` short when advertising services.
- If you need larger payloads, move non-essential data out of the advertisement and into the GATT service.

`ble_peripheral_plus` defensively rejects obviously unsafe Android name lengths when services are also present.

## Connection signals differ by platform

The package offers different signals depending on the platform Bluetooth stack.

- Android provides connection and bond-state callbacks.
- iOS and macOS primarily expose client availability through characteristic subscription callbacks.
- Windows focuses on service hosting and subscription tracking rather than Android-style bond flow.

If you are writing cross-platform code, do not assume one callback means the same thing on every platform.

## Apple dependency management

This package now includes a Swift Package Manager manifest for current Flutter toolchains while still keeping the CocoaPods path for older projects.

That is intentional:

- it removes current Flutter SPM support warnings
- it keeps older project layouts working through CocoaPods
- it avoids forcing a Swift Package Manager-only path on consumers

## Recommended deployment choices

For the broadest compatibility:

- use Android for peripheral-heavy mobile workflows
- use dedicated BLE hardware for production peripherals when Apple central compatibility matters
- treat iOS and macOS peripheral mode as useful, but more constrained than Android

## Recommended testing matrix

- Android peripheral -> Android central
- Android peripheral -> iOS central
- Windows peripheral -> Android central
- Dedicated hardware peripheral -> iOS central
- Apple peripheral -> Android central

Do not rely only on Apple-to-Apple peripheral discovery tests when validating production behavior.