import 'package:equatable/equatable.dart';
import 'package:health_ring_ai/core/services/platform/bluetooth/bluetooth_platform_interface.dart';
import 'package:health_ring_ai/core/services/platform/bluetooth/bluetooth_platform_ios.dart';

sealed class BluetoothEvent extends Equatable {
  const BluetoothEvent();

  @override
  List<Object?> get props => [];
}

// Add permission events
final class CheckBluetoothPermissions extends BluetoothEvent {}

final class RequestBluetoothPermissions extends BluetoothEvent {}

final class OpenBluetoothSettings extends BluetoothEvent {}

final class CheckBluetoothStatus extends BluetoothEvent {}

final class EnableBluetooth extends BluetoothEvent {}

final class StartScanning extends BluetoothEvent {}

final class StopScanning extends BluetoothEvent {}

final class ConnectToDevice extends BluetoothEvent {
  final BluetoothDevice device;

  const ConnectToDevice({required this.device});

  @override
  List<Object?> get props => [device];
}

final class DisconnectDevice extends BluetoothEvent {}

final class BluetoothDevicesUpdated extends BluetoothEvent {
  final List<BluetoothDevice> devices;

  const BluetoothDevicesUpdated({required this.devices});

  @override
  List<Object?> get props => [devices];
}

final class ConnectionStatusChanged extends BluetoothEvent {
  final ConnectionInfo? status;
  final String? error;

  const ConnectionStatusChanged({this.status, this.error});

  @override
  List<Object?> get props => [status, error];
}

final class GetBatteryLevel extends BluetoothEvent {
  const GetBatteryLevel();
}

// final class GetHeartRateData extends BluetoothEvent {
//   final List<int> dayIndices;

//   const GetHeartRateData({required this.dayIndices});

//   @override
//   List<Object?> get props => [dayIndices];
// }
