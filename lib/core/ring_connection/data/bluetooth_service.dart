import 'dart:io';

import 'package:health_ring_ai/core/ring_connection/data/models/bluetooth_device.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/combined_health_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/sleep_data.dart';
import 'package:hive/hive.dart';

import '../platform/bluetooth_platform_android.dart';
import '../platform/bluetooth_platform_ios.dart';
import 'bluetooth_platform_interface.dart';

class BluetoothService {
  final BluetoothPlatformInterface _platform;

  // Singleton pattern
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;

  final Box _cache = Hive.box('bluetooth_cache');

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

  Stream<dynamic> get connectionStatus => _platform.connectionStatus;

  Stream<List<BluetoothDevice>> get discoveredDevices =>
      _platform.discoveredDevices;

  Future<int> getBatteryLevel() => _platform.getBatteryLevel();

  Future<CombinedHealthData?> getHealthData(List<int> dayIndices) async {
    final key = 'health_data_${dayIndices.join("_")}';

    try {
      final cachedJson = _cache.get(key);
      final cachedData =
          cachedJson != null ? CombinedHealthData.fromJson(cachedJson) : null;

      if (cachedData == null) {
        final healthData = await _platform.getHealthData(dayIndices);

        if (healthData != null &&
            (healthData.bloodOxygenData.isNotEmpty ||
                healthData.heartRateData.isNotEmpty)) {
          _cache.put(key, healthData.toJson());
        }
        return healthData;
      }

      // If the first day is not today, return the cached data
      if (dayIndices.first != 0) return cachedData;

      final healthData = await _platform.getHealthData(dayIndices);

      if (healthData != null) {
        if (healthData.bloodOxygenData.isEmpty &&
            healthData.heartRateData.isEmpty) {
          return cachedData;
        }
      }

      if (healthData != null &&
          (healthData.bloodOxygenData.isNotEmpty ||
              healthData.heartRateData.isNotEmpty)) {
        _cache.put(key, healthData.toJson());
      }

      return healthData;
    } catch (e, stacktrace) {
      print('Error fetching health data: $e\n$stacktrace');
      return null;
    }
  }

  Future<List<SleepData>> getSleepData(int dayIndex) async {
    final date = DateTime.now().subtract(Duration(days: dayIndex));
    final key = 'sleep_data_${date.year}_${date.month}_${date.day}';

    try {
      // Check if cached data exists
      final cachedData = _cache.get(key);
      if (cachedData != null && dayIndex != 0) {
        return List<SleepData>.from(cachedData);
      }

      // Fetch from platform
      final sleepData = await _platform.getSleepData(dayIndex);

      // Store in cache only if data is not empty
      if (sleepData.isNotEmpty) {
        _cache.put(key, sleepData);
      }

      return sleepData;
    } catch (e, stacktrace) {
      print('Error fetching sleep data: $e\n$stacktrace');
      return [];
    }
  }

  Future<bool> reconnectToLastDevice() => _platform.reconnectToLastDevice();

  Stream<Map<String, dynamic>> startMeasurement(int type) =>
      _platform.startMeasurement(type);

  Future<void> stopMeasurement() => _platform.stopMeasurement();
}
