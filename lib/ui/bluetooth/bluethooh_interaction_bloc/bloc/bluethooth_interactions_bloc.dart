import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_ring_ai/core/models/combined_health_data.dart';
import 'package:health_ring_ai/core/services/platform/bluetooth/bluetooth_service.dart';
import 'package:health_ring_ai/ui/bluetooth/bluethooth_connection_bloc/bluetooth_connection_service_bloc.dart';
import 'package:health_ring_ai/ui/bluetooth/bluethooth_connection_bloc/bluetooth_connection_service_state.dart';

part 'bluethooth_interactions_event.dart';
part 'bluethooth_interactions_state.dart';

class BluethoothInteractionsBloc
    extends Bloc<BluethoothInteractionsEvent, BluethoothInteractionsState> {
  final BluetoothService _bluetoothService;
  final BluetoothBloc _bluetoothBloc;

  BluethoothInteractionsBloc({
    required BluetoothService bluetoothService,
    required BluetoothBloc bluetoothBloc,
  })  : _bluetoothService = bluetoothService,
        _bluetoothBloc = bluetoothBloc,
        super(HeartRateInitial()) {
    on<GetHeartRateData>(_onGetHeartRateData);
    // on<GetBloodOxygenData>(_onGetBloodOxygenData);
    // on<GetBatteryLevel>(_onGetBatteryLevel);\
  }

  Future<void> _onGetHeartRateData(
    GetHeartRateData event,
    Emitter<BluethoothInteractionsState> emit,
  ) async {
    if (_bluetoothBloc.state is! BluetoothConnected) {
      emit(const HeartRateError(message: 'Device not connected'));
      print('Device not connected');
      return;
    }

    try {
      emit(HeartRateLoading());
      final combinedHealthData =
          await _bluetoothService.getHealthData(event.dayIndices);
      print('Heart rate data received: $combinedHealthData');
      emit(HeartRateDataReceived(combinedHealthData));
    } catch (e) {
      print('Error getting heart rate data: $e');
      emit(HeartRateError(message: e.toString()));
    }
  }

  // Future<void> _onGetBloodOxygenData(
  //   GetBloodOxygenData event,
  //   Emitter<BluethoothInteractionsState> emit,
  // ) async {
  //   if (_bluetoothBloc.state is! BluetoothConnected) {
  //     emit(const HeartRateError(message: 'Device not connected'));
  //     return;
  //   }

  //   try {
  //     emit(HeartRateLoading());
  //     final bloodOxygenData =
  //         await _bluetoothService.getBloodOxygenData(event.dayIndex);
  //     emit(BloodOxygenDataReceived(bloodOxygenData));
  //   } catch (e) {
  //     print('Error getting blood oxygen data: $e');
  //     emit(HeartRateError(message: e.toString()));
  //   }
  // }

  // Future<void> _onGetBatteryLevel(
  //   GetBatteryLevel event,
  //   Emitter<BluethoothInteractionsState> emit,
  // ) async {
  //   final batteryLevel = await _bluetoothService.getBatteryLevel();
  //   emit(BatteryLevelReceived(batteryLevel));
  // }

  @override
  void onTransition(
      Transition<BluethoothInteractionsEvent, BluethoothInteractionsState>
          transition) {
    super.onTransition(transition);
    print('Bluetooth Transition:');
    print('  Current: ${transition.currentState}');
    print('  Event: ${transition.event}');
    print('  Next: ${transition.nextState}');
  }
}
