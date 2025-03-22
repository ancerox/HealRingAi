import 'package:flutter/services.dart';
import 'package:health_ring_ai/core/platform_channels/channel_names.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/bluetooth_device.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/blood_oxygen_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/combined_health_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/heart_rate_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/sleep_data.dart';

import '../data/bluetooth_platform_interface.dart';

class BluetoothPlatformIOS implements BluetoothPlatformInterface {
  static const MethodChannel _channel = bluetoothChannel;
  static const EventChannel _connectionChannel = connectionChannel;
  static const EventChannel _scanChannel = scanChannel;
  static const EventChannel _heartRateChannel = heartRateChannel;

  String? _lastConnectedDeviceId;
  bool _isReconnecting = false;

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
    throw Exception('Cannot enable Bluetooth programmatically on iOS');
  }

  @override
  Future<void> startScan() async {
    try {
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
    return _connectionChannel.receiveBroadcastStream().map((dynamic event) {
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
          } catch (e) {}
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
      await connectToDevice(_lastConnectedDeviceId!);
    } catch (e) {
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
      final result = await _channel.invokeMethod(
        'getHeartRateHistory',
        {'dayIndices': dayIndices},
      );

      // Process Heart Rate Data
      final heartRateData = (result['heartRateData'] as List<dynamic>)
          .map((dynamic item) {
            if (item == null) return null;
            try {
              final map = Map<String, dynamic>.from(item as Map);
              return HeartRateData.fromJson(map);
            } catch (e) {
              return null;
            }
          })
          .whereType<HeartRateData>()
          .toList();

      final bloodOxygenData = (result['bloodOxygenData'] as List<dynamic>)
          .map((dynamic item) {
            if (item == null) return null;
            try {
              final map = Map<String, dynamic>.from(item as Map);
              return BloodOxygenData.fromJson(map);
            } catch (e) {
              return null;
            }
          })
          .whereType<BloodOxygenData>()
          .toList();

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
      final result = await _channel.invokeMethod(
        'getSleepData',
        {'dayIndex': dayIndex},
      );

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
              return null;
            }
          })
          .whereType<SleepData>()
          .toList();

      return sleepData;
    } on PlatformException catch (e) {
      throw Exception('Failed to get sleep data: ${e.message}');
    } catch (e, stack) {
      rethrow;
    }
  }

  @override
  Future<bool> reconnectToLastDevice() async {
    try {
      final isConnected =
          await _channel.invokeMethod<bool>('reconnectToLastDevice');
      return isConnected ?? false;
    } catch (e) {
      throw Exception("Failed to reconnect: $e");
    }
  }

  @override
  Stream<Map<String, dynamic>> startMeasurement(int type) {
    _channel.invokeMethod('startMeasurement', {'type': type});
    return _heartRateChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is Map) {
        return {
          'dataType': event['dataType'],
          'value': event['value'],
          'isError': event['isError'] ?? false,
          'errorCode': event['errorCode'],
          'errorMessage': event['errorMessage'],
        };
      }
      return {
        'isError': true,
        'errorMessage': 'Invalid data format',
        'errorCode': -1
      };
    });
  }

  @override
  Future<void> stopMeasurement() async {
    try {
      await _channel.invokeMethod('stopMeasurement');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop measurement: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentSteps() async {
    try {
      final result = await _channel.invokeMethod('getCurrentSteps');
      if (result == null) {
        return {'steps': 0, 'calories': 0, 'distance': 0, 'duration': 0};
      }
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to get current steps: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error getting steps: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDailySteps(int dayIndex) async {
    try {
      final result = await _channel.invokeMethod(
        'getDailySteps',
        {'dayIndex': dayIndex},
      );

      if (result == null) {
        return {
          'steps': 0,
          'calories': 0,
          'distance': 0,
          'duration': 0,
          'date': ''
        };
      }

      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to get daily steps: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error getting daily steps: $e');
    }
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
