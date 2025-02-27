part of 'continuous_monitoring_bloc.dart';

abstract class BluethoothInteractionsEvent extends Equatable {
  const BluethoothInteractionsEvent();

  @override
  List<Object> get props => [];
}

class GetHeartRateData extends BluethoothInteractionsEvent {
  final List<int> dayIndices;

  const GetHeartRateData({required this.dayIndices});

  @override
  List<Object> get props => [dayIndices];
}

class GetHomeData extends BluethoothInteractionsEvent {
  final int dayIndex;

  const GetHomeData({required this.dayIndex});

  @override
  List<Object> get props => [dayIndex];
}

class HeartRateDataLoading extends BluethoothInteractionsEvent {}

class GetBloodOxygenData extends BluethoothInteractionsEvent {
  final int dayIndex;

  const GetBloodOxygenData({required this.dayIndex});

  @override
  List<Object> get props => [dayIndex];
}

class GetCombinedHealthData extends BluethoothInteractionsEvent {
  final int dayIndex;

  const GetCombinedHealthData(this.dayIndex);

  @override
  List<Object> get props => [dayIndex];
}

class GetSleepData extends BluethoothInteractionsEvent {
  final int dayIndex;

  const GetSleepData(this.dayIndex);

  @override
  List<Object> get props => [dayIndex];
}

class GetBatteryLevel extends BluethoothInteractionsEvent {}

class StartMeasurement extends BluethoothInteractionsEvent {
  final int type;

  const StartMeasurement(this.type);

  @override
  List<Object> get props => [type]; // Change to List<Object>
}

// class RealTimeHeartRateDataReceived extends BluethoothInteractionsEvent {
//   final int heartRate;
//   const RealTimeHeartRateDataReceived(this.heartRate);

//   @override
//   List<Object> get props => [heartRate];
// }
class RealTimeHeartRateUpdated extends BluethoothInteractionsEvent {
  final int heartRate;
  const RealTimeHeartRateUpdated(this.heartRate);
}

class StartRealTimeHeartRate extends BluethoothInteractionsEvent {}

class StopRealTimeHeartRate extends BluethoothInteractionsEvent {}

class RealTimeHeartRateDataReceived extends BluethoothInteractionsEvent {
  final int heartRate;
  const RealTimeHeartRateDataReceived(this.heartRate);
}
