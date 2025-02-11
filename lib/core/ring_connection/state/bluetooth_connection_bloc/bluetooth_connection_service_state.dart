import 'package:equatable/equatable.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/bluetooth_device.dart';
import 'package:health_ring_ai/core/ring_connection/data/models/heart_rate_data.dart';

enum ConnectionStatus { disconnected, connecting, connected }

sealed class BluetoothState extends Equatable {
  const BluetoothState();

  @override
  List<Object?> get props => [];

  BluetoothState copyWith() => this; // Base copyWith method

  ConnectionStatus get connectionStatus => switch (this) {
        BluetoothLoading() => ConnectionStatus.connecting,
        BluetoothConnected() => ConnectionStatus.connected,
        _ => ConnectionStatus.disconnected,
      };

  // Helper method for UI to show loading state
  bool get isLoading => switch (this) {
        BluetoothLoading() => true,
        _ => false,
      };

  // Helper method to get devices if available
  List<BluetoothDevice>? get devices => switch (this) {
        BluetoothScanning(:final devices) => devices,
        _ => null,
      };
}

final class BluetoothInitial extends BluetoothState {}

final class BluetoothLoading extends BluetoothState {}

// Add new permission states
final class BluetoothPermissionDenied extends BluetoothState {
  final List<String> deniedPermissions;

  const BluetoothPermissionDenied({required this.deniedPermissions});

  @override
  List<Object?> get props => [deniedPermissions];
}

final class BluetoothPermissionPermanentlyDenied extends BluetoothState {
  final List<String> permanentlyDeniedPermissions;

  const BluetoothPermissionPermanentlyDenied({
    required this.permanentlyDeniedPermissions,
  });

  @override
  List<Object?> get props => [permanentlyDeniedPermissions];
}

final class BluetoothEnabled extends BluetoothState {}

final class BluetoothDisabled extends BluetoothState {}

final class BluetoothScanning extends BluetoothState {
  @override
  final List<BluetoothDevice> devices;

  const BluetoothScanning({required this.devices});

  @override
  List<Object?> get props => [
        devices,
        connectionStatus,
        isLoading,
        devices,
      ];
}

final class BluetoothConnected extends BluetoothState {
  final BluetoothDevice device;
  final int batteryLevel;
  final List<HeartRateData>? heartRateData;

  const BluetoothConnected({
    required this.device,
    this.batteryLevel = 0,
    this.heartRateData,
  });

  @override
  List<Object?> get props => [
        device,
        batteryLevel,
        heartRateData,
        connectionStatus,
        isLoading,
        devices
      ];

  @override
  BluetoothConnected copyWith({
    BluetoothDevice? device,
    int? batteryLevel,
    List<HeartRateData>? heartRateData,
  }) {
    return BluetoothConnected(
      device: device ?? this.device,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      heartRateData: heartRateData ?? this.heartRateData,
    );
  }
}

final class BluetoothError extends BluetoothState {
  final String message;

  const BluetoothError({required this.message});

  @override
  List<Object?> get props => [message];
}
