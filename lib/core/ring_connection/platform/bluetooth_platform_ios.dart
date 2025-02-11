import 'package:flutter/services.dart';
import 'package:health_ring_ai/core/platform_channels/channel_names.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/blood_oxygen_data.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/bluetooth_device.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/combined_health_data.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/heart_rate_data.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/sleep_data.dart';

import '../data/bluetooth_platform_interface.dart';

class BluetoothPlatformIOS implements BluetoothPlatformInterface {
  static const MethodChannel _channel = bluetoothChannel;
  static const EventChannel _connectionChannel = connectionChannel;
  static const EventChannel _scanChannel = scanChannel;
  static const EventChannel _heartRateChannel = heartRateChannel;

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
    } on PlatformException catch (e) {
      if (e.code == 'DEVICE_OUT_OF_RANGE') {
        throw Exception(
            'Device signal is too weak for reliable connection. Please move closer to the device.');
      }
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
  Stream<ConnectionInfo> get connectionStatus {
    print("is getting Connmetions");
    return _connectionChannel.receiveBroadcastStream().map((dynamic event) {
      print(event);
      if (event is Map) {
        final isConnected = event['connected'] as bool? ?? false;
        final state = event['state'] as String? ?? 'disconnected';
        final deviceMap = event['device'] as Map?;

        BluetoothDevice? device;
        if (deviceMap != null) {
          try {
            device = BluetoothDevice(
              id: deviceMap['id'] as String,
              name: deviceMap['name'] as String,
              rssi: deviceMap['rssi'] as int? ?? 0,
              manufacturerData: deviceMap['manufacturerData'] as String? ?? '',
            );
            // print('Received device data: ${deviceMap.toString()}'); // Debug log
          } catch (e) {
            print('Error parsing device data: $e'); // Debug log
            print('Raw device data: ${deviceMap.toString()}'); // Debug log
          }
        }

        return ConnectionInfo(
          connected: isConnected,
          state: state,
          device: device,
        );
      }

      return ConnectionInfo(
        connected: false,
        state: 'disconnected',
        device: null,
      );
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

  @override
  Future<int> getBatteryLevel() async {
    try {
      final int result = await _channel.invokeMethod('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to get battery level: ${e.message}');
    }
  }

  @override
  Future<CombinedHealthData?> getHealthData(List<int> dayIndices) async {
    try {
      print('Flutter: Requesting health data for days: $dayIndices');
      final result = await _channel.invokeMethod(
        'getHeartRateHistory',
        {'dayIndices': dayIndices},
      );
      print('Flutter: Raw health data received: $result');

      // Process Heart Rate Data
      final heartRateData = (result['heartRateData'] as List<dynamic>)
          .map((dynamic item) {
            if (item == null) return null;
            try {
              final map = Map<String, dynamic>.from(item as Map);
              return HeartRateData.fromJson(map);
            } catch (e) {
              print('Flutter: Error processing heart rate item: $e');
              return null;
            }
          })
          .whereType<HeartRateData>()
          .toList();

      // Process Blood Oxygen Data
      final bloodOxygenData = (result['bloodOxygenData'] as List<dynamic>)
          .map((dynamic item) {
            if (item == null) return null;
            try {
              final map = Map<String, dynamic>.from(item as Map);
              return BloodOxygenData.fromJson(map);
            } catch (e) {
              print('Flutter: Error processing blood oxygen item: $e');
              return null;
            }
          })
          .whereType<BloodOxygenData>()
          .toList();

      print(
          'Flutter: Successfully processed ${heartRateData.length} heart rate records');
      print(
          'Flutter: Successfully processed ${bloodOxygenData.length} blood oxygen records');

      return CombinedHealthData(
        heartRateData: heartRateData,
        bloodOxygenData: bloodOxygenData,
      );
    } on PlatformException catch (e) {
      return null;
    } catch (e, stack) {
      return null;
    }
  }

  @override
  Future<List<SleepData>> getSleepData(int dayIndex) async {
    try {
      print('Flutter: Requesting sleep data for day index: $dayIndex');
      final result = await _channel.invokeMethod(
        'getSleepData',
        {'dayIndex': dayIndex},
      );
      print("flutter SleepData Result $result");

      if (result == null) {
        return [];
      }

      final List<SleepData> sleepData = (result as List<dynamic>)
          .map((dynamic item) {
            if (item == null) return null;
            try {
              final map = Map<String, dynamic>.from(item as Map);
              return SleepData.fromJson(map);
            } catch (e) {
              print('Flutter: Error processing sleep data item: $e');
              return null;
            }
          })
          .whereType<SleepData>()
          .toList();

      print(
          'Flutter: Successfully processed ${sleepData.length} sleep records');
      return sleepData;
    } on PlatformException catch (e) {
      print('Flutter: PlatformException while getting sleep data:');
      print('  Code: ${e.code}');
      print('  Message: ${e.message}');
      print('  Details: ${e.details}');
      throw Exception('Failed to get sleep data: ${e.message}');
    } catch (e, stack) {
      print('Flutter: Unexpected error while getting sleep data: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  @override
  Future<bool> reconnectToLastDevice() async {
    try {
      // Call the native platform to reconnect to the last device
      final isConnected =
          await _channel.invokeMethod<bool>('reconnectToLastDevice');
      return isConnected ?? false;
    } catch (e) {
      throw Exception("Failed to reconnect: $e");
    }
  }

  @override
  Future<int> startMeasurement(int type) async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('startMeasurement', {'type': 0});

      final int heartRate = result['heartRate'];
      print("$heartRate DATA HEART!!!!!!");
      // If starting heart rate measurement, listen to the stream
      return heartRate;
    } on PlatformException catch (e) {
      throw Exception('Failed to start measurement: ${e.message}');
    }
  }

  @override
  Stream<int> get realTimeHeartRate {
    return _heartRateChannel.receiveBroadcastStream().map((dynamic data) {
      if (data is int) {
        return data;
      }
      return 0; // Default value if invalid data
    });
  }

  @override
  Future<void> stopMeasurement() {
    // TODO: implement stopMeasurement
    throw UnimplementedError();
  }
}

class ConnectionInfo {
  final bool connected;
  final String state;
  final BluetoothDevice? device;

  ConnectionInfo({
    required this.connected,
    required this.state,
    this.device,
  });
}
