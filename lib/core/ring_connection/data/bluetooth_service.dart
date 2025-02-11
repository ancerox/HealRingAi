import 'dart:io';

import 'package:health_ring_ai/core/ring_connection/data/models/bluetooth_device.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/combined_health_data.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/sleep_data.dart';

import '../platform/bluetooth_platform_android.dart';
import '../platform/bluetooth_platform_ios.dart';
import 'bluetooth_platform_interface.dart';

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

  Future<CombinedHealthData?> getHealthData(List<int> dayIndices) =>
      _platform.getHealthData(dayIndices);

  Future<List<SleepData>> getSleepData(int dayIndex) =>
      _platform.getSleepData(dayIndex);

  Future<bool> reconnectToLastDevice() => _platform.reconnectToLastDevice();

  Future<int> startMeasurement(int type) => _platform.startMeasurement(type);

  Stream<int> get realTimeHeartRate => _platform.realTimeHeartRate;

  Future<void> stopMeasurement() => _platform.stopMeasurement();
}
