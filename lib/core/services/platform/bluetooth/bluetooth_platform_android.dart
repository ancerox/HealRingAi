import 'package:flutter/services.dart';
import 'package:health_ring_ai/core/models/blood_oxygen_data.dart';
import 'package:health_ring_ai/core/models/combined_health_data.dart';
import 'package:health_ring_ai/core/models/heart_rate_data.dart';

import './bluetooth_platform_interface.dart';

class BluetoothPlatformAndroid implements BluetoothPlatformInterface {
  static const MethodChannel _channel = MethodChannel('bluetooth_channel');
  static const EventChannel _connectionChannel =
      EventChannel('bluetooth_connection_channel');
  static const EventChannel _scanChannel =
      EventChannel('bluetooth_scan_channel');

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
}
