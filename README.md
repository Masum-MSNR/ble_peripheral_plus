# ble_peripheral_plus

`ble_peripheral_plus` is a maintained Flutter BLE peripheral and GATT server plugin for Android, iOS, macOS, and Windows.

It is a compatibility-focused fork of `ble_peripheral` intended for teams that want to keep the established API shape while getting selected runtime fixes, newer project compatibility updates, and clearer platform guidance.

## Why this fork exists

- Keeps the upstream int-based characteristic and permission API so existing users are not forced into a breaking migration.
- Includes selected fixes from upstream open PRs without merging risky or noisy changes wholesale.
- Adds fork-only improvements such as `getSubscribedClients()` and Android `requireBonding` support.
- Tracks newer Flutter, Android, and Apple project requirements more closely than the original package.

## Highlights

- Create BLE peripherals and GATT services from Flutter.
- Add, remove, inspect, and clear services dynamically.
- Handle read, write, MTU, connection, and subscription callbacks.
- Update characteristics globally or for a specific subscribed client.
- Query subscribed clients with `getSubscribedClients()`.
- Keep Android bonding behavior configurable with `requireBonding`.
- Preserve the upstream API style for easier migration.

## Supported platforms

| Platform | Peripheral / GATT server | Notes |
| --- | --- | --- |
| Android | Yes | Generic manufacturer data is supported. Connection and bond callbacks are available. |
| iOS | Yes | Generic manufacturer data is limited by CoreBluetooth. Use service UUIDs and local name. |
| macOS | Yes | Same Apple advertising limitations as iOS apply. |
| Windows | Yes | Characteristic updates and subscription tracking are supported. |
| Linux | No | Not currently implemented. |

## Install

```yaml
dependencies:
  ble_peripheral_plus: ^2.5.1
```

If you want to use the latest unpublished commit instead of a hosted version:

```yaml
dependencies:
  ble_peripheral_plus:
    git:
      url: https://github.com/Masum-MSNR/ble_peripheral_plus
```

## Quick start

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:ble_peripheral_plus/ble_peripheral_plus.dart';

const serviceId = '0000180F-0000-1000-8000-00805F9B34FB';
const characteristicId = '00002A19-0000-1000-8000-00805F9B34FB';

Future<void> startPeripheral() async {
  await BlePeripheral.initialize();

  if (!await BlePeripheral.isSupported()) {
    throw Exception('BLE peripheral mode is not supported on this device');
  }

  BlePeripheral.setAdvertisingStatusUpdateCallback((advertising, error) {
    print('Advertising: $advertising error: $error');
  });

  BlePeripheral.setCharacteristicSubscriptionChangeCallback(
    (deviceId, charId, isSubscribed, name) {
      print('Subscription change: $deviceId $charId $isSubscribed $name');
    },
  );

  await BlePeripheral.clearServices();
  await BlePeripheral.addService(
    BleService(
      uuid: serviceId,
      primary: true,
      characteristics: [
        BleCharacteristic(
          uuid: characteristicId,
          properties: [
            CharacteristicProperties.read.index,
            CharacteristicProperties.notify.index,
          ],
          permissions: [
            AttributePermissions.readable.index,
          ],
          descriptors: null,
          value: Uint8List.fromList([100]),
        ),
      ],
    ),
  );

  await BlePeripheral.startAdvertising(
    services: [serviceId],
    localName: 'Battery',
    requireBonding: true,
  );
}

Future<void> pushValue() async {
  await BlePeripheral.updateCharacteristic(
    characteristicId: characteristicId,
    value: Uint8List.fromList(utf8.encode('hello')),
  );
}
```

## Core API

### Service management

```dart
await BlePeripheral.addService(service);
await BlePeripheral.getServices();
await BlePeripheral.removeService(serviceId);
await BlePeripheral.clearServices();
```

### Advertising

```dart
await BlePeripheral.startAdvertising(
  services: [serviceId],
  localName: 'Battery',
  manufacturerData: ManufacturerData(
    manufacturerId: 0x004C,
    data: Uint8List.fromList([0x02, 0x15]),
  ),
  addManufacturerDataInScanResponse: false,
  requireBonding: true,
);
```

Notes:

- `requireBonding` is Android-specific and defaults to `true` to preserve previous behavior.
- On Android, if you advertise services and a local name together, keep `localName` short. Long names can overflow the BLE advertisement packet and fail with `ADVERTISE_FAILED_DATA_TOO_LARGE`.
- On iOS and macOS, CoreBluetooth does not expose the same generic manufacturer-data advertising behavior as Android.

### Connected and subscribed clients

```dart
final clients = await BlePeripheral.getSubscribedClients();
for (final client in clients) {
  print('${client.deviceId}: ${client.subscribedCharacteristics}');
}
```

### Callbacks

```dart
BlePeripheral.setAdvertisingStatusUpdateCallback((advertising, error) {});
BlePeripheral.setBleStateChangeCallback((state) {});
BlePeripheral.setServiceAddedCallback((serviceId, error) {});
BlePeripheral.setReadRequestCallback((deviceId, characteristicId, offset, value) {
  return ReadRequestResult(value: Uint8List(0));
});
BlePeripheral.setWriteRequestCallback((deviceId, characteristicId, offset, value) {
  return WriteRequestResult(status: 0);
});
BlePeripheral.setCharacteristicSubscriptionChangeCallback(
  (deviceId, characteristicId, isSubscribed, name) {},
);
BlePeripheral.setMtuChangeCallback((deviceId, mtu) {});
BlePeripheral.setConnectionStateChangeCallback((deviceId, connected) {});
BlePeripheral.setBondStateChangeCallback((deviceId, bondState) {});
```

Platform notes:

- `setConnectionStateChangeCallback` and `setBondStateChangeCallback` are Android-only.
- `setCharacteristicSubscriptionChangeCallback` is the main availability signal on Apple platforms.

## Permissions and setup

### Android

Add the required permissions to `AndroidManifest.xml` and request runtime permissions in your app:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
```

Use a package such as `permission_handler` to request runtime permission where needed.

### iOS and macOS

Add Bluetooth usage text to `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app advertises BLE peripheral data.</string>
```

For macOS, also enable the Bluetooth capability in Xcode.

### Windows

No extra package-specific setup is required beyond normal Bluetooth availability.

## Migration from `ble_peripheral`

- Change the package import from `ble_peripheral` to `ble_peripheral_plus`.
- Existing int-based `CharacteristicProperties` and `AttributePermissions` usage remains valid.
- New fork additions are optional and non-breaking for existing users.

```dart
import 'package:ble_peripheral_plus/ble_peripheral_plus.dart';
```

## Platform limitations

Apple BLE advertising has important system-level limitations that do not exist on Android.

- Generic manufacturer data is not broadly available through Apple peripheral advertising APIs.
- Apple-to-Apple peripheral discovery can be filtered by the platform.
- Current Flutter toolchains can use the included Swift Package Manager manifest, while older projects can keep using CocoaPods.

See [PLATFORM_LIMITATIONS.md](PLATFORM_LIMITATIONS.md) for the detailed breakdown.

## Example app

The package includes a runnable example in `example/` that demonstrates advertising, GATT services, characteristic editing, and live value updates.

## Issues and contributions

Issues and pull requests are welcome at:

- Repository: https://github.com/Masum-MSNR/ble_peripheral_plus
- Issue tracker: https://github.com/Masum-MSNR/ble_peripheral_plus/issues
