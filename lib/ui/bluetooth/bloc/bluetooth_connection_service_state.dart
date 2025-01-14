import 'package:equatable/equatable.dart';
import 'package:health_ring_ai/core/services/platform/bluetooth/bluetooth_platform_interface.dart';

enum ConnectionStatus { disconnected, connecting, connected }

sealed class BluetoothState extends Equatable {
  const BluetoothState();

  @override
  List<Object?> get props => [];

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
  List<Object?> get props => [devices];
}

final class BluetoothConnected extends BluetoothState {
  final BluetoothDevice device;

  const BluetoothConnected({required this.device});

  @override
  List<Object?> get props => [device];
}

final class BluetoothError extends BluetoothState {
  final String message;

  const BluetoothError({required this.message});

  @override
  List<Object?> get props => [message];
}
