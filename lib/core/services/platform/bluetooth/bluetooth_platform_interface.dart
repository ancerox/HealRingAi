import 'package:health_ring_ai/core/models/combined_health_data.dart';

abstract class BluetoothPlatformInterface {
  /// Check permissions
  Future<bool> checkPermissions();

  /// Request permissions
  Future<bool> requestPermissions();

  /// Open settings
  Future<void> openSettings();

  /// Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled();

  /// Enable Bluetooth
  Future<void> enableBluetooth();

  /// Start scanning for devices
  Future<void> startScan();

  /// Stop scanning for devices
  Future<void> stopScan();

  /// Connect to device
  Future<void> connectToDevice(String deviceId);

  /// Disconnect from device
  Future<void> disconnectDevice();

  /// Get connected device status
  /// Returns either a bool or a Map with connection details
  Stream<dynamic> get connectionStatus;

  /// Get discovered devices
  Stream<List<BluetoothDevice>> get discoveredDevices;

  /// Get battery level
  Future<int> getBatteryLevel();

  /// Get health data
  Future<CombinedHealthData> getHealthData(List<int> dayIndices);
}

class BluetoothDevice {
  final String id;
  final String name;
  final int rssi;
  final String manufacturerData;

  BluetoothDevice({
    required this.id,
    required this.name,
    required this.rssi,
    this.manufacturerData = '',
  });

  @override
  String toString() => 'BluetoothDevice(id: $id, name: $name, rssi: $rssi)';
}
