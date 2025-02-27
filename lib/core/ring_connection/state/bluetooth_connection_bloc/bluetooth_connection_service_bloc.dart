import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_ring_ai/core/ring_connection/data/bluetooth_service.dart';

import 'bluetooth_connection_service_event.dart';
import 'bluetooth_connection_service_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final BluetoothService _bluetoothService;
  StreamSubscription? _deviceSubscription;
  StreamSubscription? _connectionSubscription;
  int? _lastHeartRate;

  Timer? _sameHeartRateTimer;

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
    on<RealTimeHeartRateUpdated>(_onRealTimeHeartRateUpdated);

    _connectionSubscription = _bluetoothService.connectionStatus.listen(
      (status) {
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
  }
  void _onRealTimeHeartRateUpdated(
    RealTimeHeartRateUpdated event,
    Emitter<BluetoothState> emit,
  ) {
    final currentHR = event.heartRate;

    _sameHeartRateTimer?.cancel();
    _sameHeartRateTimer = Timer(const Duration(seconds: 3), () {
      add(StopMeasurement());
    });

    if (currentHR != _lastHeartRate) {
      _lastHeartRate = currentHR;
      emit(RealTimeHeartRateUpdate(currentHR));
    }
  }

  @override
  Future<void> close() async {
    await _deviceSubscription?.cancel();
    await _connectionSubscription?.cancel();
    return super.close();
  }

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
    if (state is BluetoothConnected) {
      return;
    }

    try {
      emit(BluetoothLoading());
      final hasPermissions = await _bluetoothService.checkPermissions();

      if (hasPermissions) {
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
    if (state is BluetoothConnected) {
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
    if (state is BluetoothConnected) {
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
    if (event.error != null) {
      emit(BluetoothError(message: event.error!));
      return;
    }

    final status = event.status;
    if (status == null) {
      return;
    }

    switch (status.state) {
      case 'connected':
        if (status.device != null) {
          emit(BluetoothConnected(device: status.device!));
        } else {}
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
        break;
    }
  }

  @override
  void onTransition(Transition<BluetoothEvent, BluetoothState> transition) {
    super.onTransition(transition);
  }
}
