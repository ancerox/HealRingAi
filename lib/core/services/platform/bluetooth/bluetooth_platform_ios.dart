import 'package:flutter/services.dart';

import './bluetooth_platform_interface.dart';

class BluetoothPlatformIOS implements BluetoothPlatformInterface {
  static const MethodChannel _channel = MethodChannel('bluetooth_channel');
  static const EventChannel _connectionChannel =
      EventChannel('bluetooth_connection_channel');
  static const EventChannel _scanChannel =
      EventChannel('bluetooth_scan_channel');

  String? _lastConnectedDeviceId;
  bool _isReconnecting = false;

  // Add this set to track discovered devices
  final Set<String> _discoveredDeviceIds = {};

  @override
  Future<bool> checkPermissions() async {
    try {
      final bool result = await _channel.invokeMethod('checkPermissions');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to check permissions: ${e.message}');
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final bool result = await _channel.invokeMethod('requestPermissions');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to request permissions: ${e.message}');
    }
  }

  @override
  Future<void> openSettings() async {
    try {
      await _channel.invokeMethod('openSettings');
    } on PlatformException catch (e) {
      throw Exception('Failed to open settings: ${e.message}');
    }
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('isBluetoothEnabled');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to check Bluetooth status: ${e.message}');
    }
  }

  @override
  Future<void> enableBluetooth() async {
    // On iOS, we can't programmatically enable Bluetooth
    // Instead, we should show a dialog asking the user to enable it in settings
    throw Exception('Cannot enable Bluetooth programmatically on iOS');
  }

  @override
  Future<void> startScan() async {
    try {
      // Clear the set when starting a new scan
      _discoveredDeviceIds.clear();
      await _channel.invokeMethod('startScan');
    } on PlatformException catch (e) {
      throw Exception('Failed to start scan: ${e.message}');
    }
  }

  @override
  Future<void> stopScan() async {
    try {
      await _channel.invokeMethod('stopScan');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop scan: ${e.message}');
    }
  }

  @override
  Future<void> connectToDevice(String deviceId) async {
    try {
      await _channel.invokeMethod('connectToDevice', {'deviceId': deviceId});
      _lastConnectedDeviceId = deviceId;
    } on PlatformException catch (e) {
      throw Exception('Failed to connect to device: ${e.message}');
    }
  }

  @override
  Future<void> disconnectDevice() async {
    try {
      await _channel.invokeMethod('disconnectDevice');
      _lastConnectedDeviceId = null;
    } on PlatformException catch (e) {
      throw Exception('Failed to disconnect device: ${e.message}');
    }
  }

  @override
  Stream<bool> get connectionStatus {
    return _connectionChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is Map<dynamic, dynamic>) {
        final isConnected = event['connected'] as bool;
        final device = event['device'] as Map<dynamic, dynamic>?;

        if (isConnected && device != null) {
          _lastConnectedDeviceId = device['id'] as String;
        }

        return isConnected;
      }
      return event as bool;
    });
  }

  @override
  Stream<List<BluetoothDevice>> get discoveredDevices {
    return _scanChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is List<dynamic>) {
        return event.map((dynamic device) {
          final Map<String, dynamic> deviceMap =
              Map<String, dynamic>.from(device as Map);
          return BluetoothDevice(
            id: deviceMap['id'] as String,
            name: deviceMap['name'] as String,
            rssi: deviceMap['rssi'] as int,
            manufacturerData: deviceMap['manufacturerData'] as String,
          );
        }).toList();
      }
      return <BluetoothDevice>[];
    });
  }

  Future<void> _attemptReconnection() async {
    if (_isReconnecting || _lastConnectedDeviceId == null) return;

    _isReconnecting = true;
    try {
      print('Attempting to reconnect to device: $_lastConnectedDeviceId');
      await connectToDevice(_lastConnectedDeviceId!);
    } catch (e) {
      print('Reconnection failed: $e');
      // Add a delay before the next attempt
      await Future.delayed(const Duration(seconds: 2));
      if (_lastConnectedDeviceId != null) {
        _attemptReconnection(); // Retry
      }
    } finally {
      _isReconnecting = false;
    }
  }
}
