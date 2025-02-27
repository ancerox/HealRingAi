import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_ring_ai/core/ring_connection/data/bluetooth_service.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/core/ring_connection/state/bluetooth_connection_bloc/bluetooth_connection_service_state.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/combined_health_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/sleep_data.dart';

part 'continuous_monitoring_event.dart';
part 'continuous_monitoring_state.dart';

class ContinuousMonitoringBloc
    extends Bloc<BluethoothInteractionsEvent, BluethoothInteractionsState> {
  final BluetoothService _bluetoothService;
  final BluetoothBloc _bluetoothBloc;
  StreamSubscription<int>? _heartRateSubscription;
  Timer? _sameHeartRateTimer;

  ContinuousMonitoringBloc({
    required BluetoothService bluetoothService,
    required BluetoothBloc bluetoothBloc,
  })  : _bluetoothService = bluetoothService,
        _bluetoothBloc = bluetoothBloc,
        super(HomeDataLoading()) {
    on<GetHeartRateData>(_onGetHeartRateData);
    on<GetSleepData>(_onGetSleepData);
    on<GetHomeData>(_onGetHomeData);
    on<GetBatteryLevel>(_onGetBatteryLevel);
  }

  @override
  Future<void> close() {
    _heartRateSubscription?.cancel();
    _sameHeartRateTimer?.cancel();
    return super.close();
  }

  Future<void> _onGetHeartRateData(
    GetHeartRateData event,
    Emitter<BluethoothInteractionsState> emit,
  ) async {
    if (_bluetoothBloc.state is! BluetoothConnected) {
      emit(const HeartRateError(message: 'Device not connected'));

      return;
    }

    try {
      emit(HeartRateLoading());
      final combinedHealthData =
          await _bluetoothService.getHealthData(event.dayIndices);

      emit(HeartRateDataReceived(combinedHealthData!));
    } catch (e) {
      emit(HeartRateError(message: e.toString()));
    }
  }

  Future<void> _onGetSleepData(
    GetSleepData event,
    Emitter<BluethoothInteractionsState> emit,
  ) async {
    if (_bluetoothBloc.state is! BluetoothConnected) {
      emit(const HeartRateError(message: 'Device not connected'));

      return;
    }

    try {
      emit(SleepDataLoading());
      final sleepData = await _bluetoothService.getSleepData(event.dayIndex);

      emit(SleepDataReceived(sleepData));
    } catch (e) {
      emit(SleepDataError(message: e.toString()));
    }
  }

  Future<void> _onGetHomeData(GetHomeData event, emit) async {
    try {
      emit(HomeDataLoading());
      final combinedHealthData =
          await _bluetoothService.getHealthData([event.dayIndex]);

      if (combinedHealthData != null) {
        final sleepData = await _bluetoothService.getSleepData(event.dayIndex);

        // Existing sleep calculations
        final totalSleepMinutes = sleepData
            .where((sleep) =>
                sleep.typeString != 'no_data' && sleep.typeString != 'not_worn')
            .fold(0, (sum, sleep) => sum + sleep.durationMinutes);

        final deepSleepMinutes = sleepData
            .where((sleep) => sleep.typeString == 'deep')
            .fold(0, (sum, sleep) => sum + sleep.durationMinutes);

        final lightSleepMinutes = sleepData
            .where((sleep) => sleep.typeString == 'light')
            .fold(0, (sum, sleep) => sum + sleep.durationMinutes);

        final awakeSleepMinutes = sleepData
            .where((sleep) => sleep.typeString == 'awake')
            .fold(0, (sum, sleep) => sum + sleep.durationMinutes);

        // New heart rate calculations
        final nonZeroHeartRates = combinedHealthData.heartRateData.isEmpty
            ? <int>[]
            : combinedHealthData.heartRateData.first.heartRates
                .where((rate) => rate > 0)
                .toList();

        final avgHeartRate = nonZeroHeartRates.isEmpty
            ? null
            : nonZeroHeartRates.reduce((a, b) => a + b) /
                nonZeroHeartRates.length;

        // New SpO2 calculations
        final validSpO2Readings = combinedHealthData.bloodOxygenData
            .where((data) => data.bloodOxygenLevels.first > 0)
            .map((data) => data.bloodOxygenLevels.first)
            .toList();

        final avgSpO2 = validSpO2Readings.isEmpty
            ? null
            : validSpO2Readings.reduce((a, b) => a + b) /
                validSpO2Readings.length;

        emit(HomeDataRecevied(
          sleepData,
          combinedHealthData,
          totalSleepMinutes,
          deepSleepMinutes,
          lightSleepMinutes,
          awakeSleepMinutes,
          avgHeartRate,
          avgSpO2,
        ));
        return;
      }

      emit(HomeDataError());
    } catch (e) {
      emit(HeartRateError(message: e.toString()));
    }
  }

  Future<void> _onGetBatteryLevel(
    GetBatteryLevel event,
    Emitter<BluethoothInteractionsState> emit,
  ) async {
    if (_bluetoothBloc.state is! BluetoothConnected) {
      emit(const BatteryLevelError(message: 'Device not connected'));
      return;
    }

    try {
      emit(BatteryLevelLoading());
      final batteryLevel = await _bluetoothService.getBatteryLevel();
      emit(BatteryLevelReceived(batteryLevel));
    } catch (e) {
      emit(BatteryLevelError(message: e.toString()));
    }
  }

  @override
  void onTransition(
      Transition<BluethoothInteractionsEvent, BluethoothInteractionsState>
          transition) {
    super.onTransition(transition);
  }
}
