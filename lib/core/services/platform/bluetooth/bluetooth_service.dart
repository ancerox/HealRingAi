import 'dart:io';

import 'package:health_ring_ai/core/models/combined_health_data.dart';

import './bluetooth_platform_android.dart';
import './bluetooth_platform_interface.dart';
import './bluetooth_platform_ios.dart';

class BluetoothService {
  final BluetoothPlatformInterface _platform;

  // Singleton pattern
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;

  BluetoothService._internal() : _platform = _getPlatform();

  static BluetoothPlatformInterface _getPlatform() {
    if (Platform.isAndroid) {
      return BluetoothPlatformAndroid();
    } else if (Platform.isIOS) {
      return BluetoothPlatformIOS();
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Permission methods
  Future<bool> checkPermissions() => _platform.checkPermissions();

  Future<bool> requestPermissions() => _platform.requestPermissions();

  Future<void> openSettings() => _platform.openSettings();

  // Bluetooth methods
  Future<bool> isBluetoothEnabled() => _platform.isBluetoothEnabled();

  Future<void> enableBluetooth() => _platform.enableBluetooth();

  Future<void> startScan() => _platform.startScan();

  Future<void> stopScan() => _platform.stopScan();

  Future<void> connectToDevice(String deviceId) =>
      _platform.connectToDevice(deviceId);

  Future<void> disconnectDevice() => _platform.disconnectDevice();

  /// Get connection status stream
  /// Returns either a bool or a Map with connection details
  Stream<dynamic> get connectionStatus => _platform.connectionStatus;

  Stream<List<BluetoothDevice>> get discoveredDevices =>
      _platform.discoveredDevices;

  Future<int> getBatteryLevel() => _platform.getBatteryLevel();

  Future<CombinedHealthData> getHealthData(List<int> dayIndices) =>
      _platform.getHealthData(dayIndices);
}
