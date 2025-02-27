import 'package:flutter/services.dart';
import 'package:health_ring_ai/core/platform_channels/channel_names.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/bluetooth_device.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/blood_oxygen_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/combined_health_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/heart_rate_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/sleep_data.dart';

import '../data/bluetooth_platform_interface.dart';

class BluetoothPlatformAndroid implements BluetoothPlatformInterface {
  static const MethodChannel _channel = bluetoothChannel;
  static const EventChannel _connectionChannel = connectionChannel;
  static const EventChannel _scanChannel = scanChannel;

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
    try {
      await _channel.invokeMethod('enableBluetooth');
    } on PlatformException catch (e) {
      throw Exception('Failed to enable Bluetooth: ${e.message}');
    }
  }

  @override
  Future<void> startScan() async {
    try {
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
    } on PlatformException catch (e) {
      throw Exception('Failed to connect to device: ${e.message}');
    }
  }

  @override
  Future<void> disconnectDevice() async {
    try {
      await _channel.invokeMethod('disconnectDevice');
    } on PlatformException catch (e) {
      throw Exception('Failed to disconnect device: ${e.message}');
    }
  }

  @override
  Stream<bool> get connectionStatus {
    return _connectionChannel
        .receiveBroadcastStream()
        .map((dynamic event) => event as bool);
  }

  @override
  Stream<List<BluetoothDevice>> get discoveredDevices {
    return _scanChannel.receiveBroadcastStream().map((dynamic event) {
      final List<dynamic> devices = event as List<dynamic>;
      return devices.map((device) {
        final Map<String, dynamic> deviceMap = device as Map<String, dynamic>;
        return BluetoothDevice(
          id: deviceMap['id'] as String,
          name: deviceMap['name'] as String,
          rssi: deviceMap['rssi'] as int,
          manufacturerData: deviceMap['manufacturerData'] as String,
        );
      }).toList();
    });
  }

  @override
  Future<int> getBatteryLevel() {
    // TODO: implement getBatteryLevel
    throw UnimplementedError();
  }

  @override
  Future<List<HeartRateData>> getHeartRateData(List<int> dayIndices) {
    // TODO: implement getHeartRateData
    throw UnimplementedError();
  }

  @override
  Future<List<BloodOxygenData>> getBloodOxygenData(int dayIndex) {
    // TODO: implement getBloodOxygenData
    throw UnimplementedError();
  }

  @override
  Future<CombinedHealthData> getHealthData(List<int> dayIndices) {
    // TODO: implement getHealthData
    throw UnimplementedError();
  }

  @override
  Future<List<SleepData>> getSleepData(int dayIndex) {
    // TODO: implement getSleepData
    throw UnimplementedError();
  }

  @override
  Future<bool> reconnectToLastDevice() {
    // TODO: implement reconnectToLastDevice
    throw UnimplementedError();
  }

  @override
  // TODO: implement realTimeHeartRate
  Stream<int> get realTimeHeartRate => throw UnimplementedError();

  @override
  Future<void> stopMeasurement() {
    // TODO: implement stopMeasurement
    throw UnimplementedError();
  }

  @override
  Stream<Map<String, dynamic>> startMeasurement(int type) {
    // TODO: implement startMeasurement
    throw UnimplementedError();
  }
}
