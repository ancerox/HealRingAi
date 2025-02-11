import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_ring_ai/core/ring_connection/data/bluetooth_service.dart';

import 'bluetooth_connection_service_event.dart';
import 'bluetooth_connection_service_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final BluetoothService _bluetoothService;
  StreamSubscription? _deviceSubscription;
  StreamSubscription? _connectionSubscription;

  BluetoothBloc({
    required BluetoothService bluetoothService,
  })  : _bluetoothService = bluetoothService,
        super(BluetoothInitial()) {
    on<CheckBluetoothPermissions>(_onCheckPermissions);
    on<RequestBluetoothPermissions>(_onRequestPermissions);
    on<OpenBluetoothSettings>(_onOpenSettings);
    on<CheckBluetoothStatus>(_onCheckStatus);
    on<EnableBluetooth>(_onEnableBluetooth);
    on<StartScanning>(_onStartScanning);
    on<StopScanning>(_onStopScanning);
    on<DisconnectDevice>(_onDisconnectDevice);
    on<BluetoothDevicesUpdated>(_onDevicesUpdated);
    on<GetBatteryLevel>(_onGetBatteryLevel);
    on<ConnectionStatusChanged>(_onConnectionStatusChanged);
    on<ConnectToDevice>(_onConnectToDevice);

//lifecycle observer
    // WidgetsBinding.instance.addObserver(this);

    // Add debug print before checking permissions
    print('Initializing BluetoothBloc');

    _connectionSubscription = _bluetoothService.connectionStatus.listen(
      (status) {
        print('Dart: Received connection status:');
        print('  - Connected: ${status.connected}');
        print('  - State: ${status.state}');
        print('  - Device: ${status.device}');
        add(ConnectionStatusChanged(
          status: status,
          error: null,
        ));
      },
      onError: (error) {
        add(ConnectionStatusChanged(
          status: null,
          error: error.toString(),
        ));
      },
    );

    // if (prefs.getBool('isFirstTime') ?? true) {
    // add(CheckBluetoothPermissions());
    // }

    // Check Bluetooth status
    // add(CheckBluetoothPermissions());
  }

  @override
  Future<void> close() async {
    // Remove lifecycle observer
    // WidgetsBinding.instance.removeObserver(this);
    await _deviceSubscription?.cancel();
    await _connectionSubscription?.cancel();
    return super.close();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   switch (state) {
  //     case AppLifecycleState.resumed:
  //       // App is in the foreground - attempt to reconnect
  //       if (this.state is BluetoothConnected ||
  //           this.state is BluetoothEnabled) {
  //         add(CheckBluetoothStatus());
  //       }
  //       break;
  //     case AppLifecycleState.paused:
  //       // App is in the background - disconnect
  //       if (this.state is BluetoothConnected) {
  //         add(DisconnectDevice());
  //       }
  //       break;
  //     default:
  //       break;
  //   }
  // }

  Future<void> _onConnectToDevice(
    ConnectToDevice event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      emit(BluetoothLoading());
      await Future.delayed(const Duration(seconds: 2));
      await _bluetoothService.connectToDevice(event.device.id);
      emit(BluetoothConnected(device: event.device));
    } catch (e) {
      emit(BluetoothError(message: e.toString()));
    }
  }

  Future<void> _onCheckPermissions(
    CheckBluetoothPermissions event,
    Emitter<BluetoothState> emit,
  ) async {
    // Don't check permissions if we're already connected
    if (state is BluetoothConnected) {
      print('Already connected, skipping permission check');
      return;
    }

    try {
      emit(BluetoothLoading());
      final hasPermissions = await _bluetoothService.checkPermissions();

      if (hasPermissions) {
        // Instead of adding a new event, handle the status check directly here
        final isEnabled = await _bluetoothService.isBluetoothEnabled();
        emit(isEnabled ? BluetoothEnabled() : BluetoothDisabled());
      } else {
        emit(const BluetoothPermissionDenied(deniedPermissions: []));
      }
    } catch (e) {
      emit(BluetoothError(message: e.toString()));
    }
  }

  Future<void> _onRequestPermissions(
    RequestBluetoothPermissions event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      emit(BluetoothLoading());
      final granted = await _bluetoothService.requestPermissions();

      if (granted) {
        add(CheckBluetoothStatus());
      } else {
        emit(const BluetoothPermissionPermanentlyDenied(
          permanentlyDeniedPermissions: [],
        ));
      }
    } catch (e) {
      emit(BluetoothError(message: e.toString()));
    }
  }

  Future<void> _onOpenSettings(
    OpenBluetoothSettings event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      await _bluetoothService.openSettings();
      add(CheckBluetoothPermissions());
    } catch (e) {
      emit(BluetoothError(message: e.toString()));
    }
  }

  Future<void> _onCheckStatus(
    CheckBluetoothStatus event,
    Emitter<BluetoothState> emit,
  ) async {
    // Don't check status if we're already connected
    if (state is BluetoothConnected) {
      print('Already connected, skipping status check');
      return;
    }

    try {
      emit(BluetoothLoading());
      final isEnabled = await _bluetoothService.isBluetoothEnabled();
      emit(isEnabled ? BluetoothEnabled() : BluetoothDisabled());
    } catch (e) {
      emit(BluetoothError(message: e.toString()));
    }
  }

  Future<void> _onEnableBluetooth(
    EnableBluetooth event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      emit(BluetoothLoading());
      await _bluetoothService.enableBluetooth();
      emit(BluetoothEnabled());
    } catch (e) {
      emit(BluetoothError(message: e.toString()));
    }
  }

  Future<void> _onStartScanning(
    StartScanning event,
    Emitter<BluetoothState> emit,
  ) async {
    final hasPermissions = await _bluetoothService.checkPermissions();
    if (!hasPermissions) {
      add(CheckBluetoothPermissions());
      return;
    }

    try {
      await _bluetoothService.startScan();
      await _deviceSubscription?.cancel();
      _deviceSubscription = _bluetoothService.discoveredDevices.listen(
        (devices) => add(BluetoothDevicesUpdated(devices: devices)),
      );
    } catch (e) {
      emit(BluetoothError(message: e.toString()));
    }
  }

  Future<void> _onStopScanning(
    StopScanning event,
    Emitter<BluetoothState> emit,
  ) async {
    await _deviceSubscription?.cancel();
    _deviceSubscription = null;
    await _bluetoothService.stopScan();
    emit(BluetoothEnabled());
  }

  Future<void> _onDisconnectDevice(
    DisconnectDevice event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      emit(BluetoothLoading());
      await _bluetoothService.disconnectDevice();
      emit(BluetoothEnabled());
    } catch (e) {
      emit(BluetoothError(message: e.toString()));
    }
  }

  void _onDevicesUpdated(
    BluetoothDevicesUpdated event,
    Emitter<BluetoothState> emit,
  ) {
    // Don't update state if we're already connected
    if (state is BluetoothConnected) {
      print('Ignoring device updates while connected');
      return;
    }
    emit(BluetoothScanning(devices: event.devices));
  }

  Future<void> _onGetBatteryLevel(
    GetBatteryLevel event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      final batteryLevel = await _bluetoothService.getBatteryLevel();
      print('Dart: Battery level: $batteryLevel');

      final currentState = state as BluetoothConnected;

      emit(BluetoothConnected(
        device: currentState.device,
        batteryLevel: batteryLevel,
      ));
    } catch (e) {
      emit(BluetoothError(message: e.toString()));
    }
  }

  void _onConnectionStatusChanged(
    ConnectionStatusChanged event,
    Emitter<BluetoothState> emit,
  ) async {
    print('DEBUG - Connection status changed:');
    print('  - Current state: $state');
    print('  - Event status: ${event.status?.connected}');
    print('  - Event state: ${event.status?.state}');
    print('  - Event device: ${event.status?.device}');

    if (event.error != null) {
      print('  - Error: ${event.error}');
      emit(BluetoothError(message: event.error!));
      return;
    }

    final status = event.status;
    if (status == null) {
      print('  - Status is null');
      return;
    }

    print('  - Processing state: ${status.state}');
    switch (status.state) {
      case 'connected':
        if (status.device != null) {
          print(
              '  - Emitting BluetoothConnected with device: ${status.device}');
          // Stop scanning when connected

          emit(BluetoothConnected(device: status.device!));
        } else {
          print('  - Device is null, cannot emit BluetoothConnected');
        }
        break;
      case 'disconnected':
        emit(BluetoothEnabled());
        break;
      case 'connecting':
        emit(BluetoothLoading());
        break;
      case 'failed':
        emit(const BluetoothError(message: 'Connection failed'));
        break;
      default:
        // Maintain current state if unknown state
        break;
    }
  }

  @override
  void onTransition(Transition<BluetoothEvent, BluetoothState> transition) {
    super.onTransition(transition);
    print('Bluetooth Transition:');
    print(
        '  Current Bluetooth change: ${transition.currentState} Event: ${transition.event} Next: ${transition.nextState}');
  }
}
