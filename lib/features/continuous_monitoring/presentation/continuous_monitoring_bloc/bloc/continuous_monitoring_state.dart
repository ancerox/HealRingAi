part of 'continuous_monitoring_bloc.dart';

abstract class BluethoothInteractionsState extends Equatable {
  const BluethoothInteractionsState();

  @override
  List<Object> get props => [];
}

class HomeDataRecevied extends BluethoothInteractionsState {
  final List<SleepData> sleepData;
  final CombinedHealthData combinedHealthData;
  final int totalSleepMinutes;
  final int deepSleepMinutes;
  final int lightSleepMinutes;
  final int awakeSleepMinutes;
  final double? avgHeartRate;
  final double? avgSpO2;

  const HomeDataRecevied(
    this.sleepData,
    this.combinedHealthData,
    this.totalSleepMinutes,
    this.deepSleepMinutes,
    this.lightSleepMinutes,
    this.awakeSleepMinutes,
    this.avgHeartRate,
    this.avgSpO2,
  );

  @override
  List<Object> get props => [
        sleepData,
        combinedHealthData,
        totalSleepMinutes,
        deepSleepMinutes,
        lightSleepMinutes,
        awakeSleepMinutes,
        avgHeartRate ?? 0,
        avgSpO2 ?? 0,
      ];
}

class HomeDataLoading extends BluethoothInteractionsState {}

class HomeDataError extends BluethoothInteractionsState {}

class HeartRateInitial extends BluethoothInteractionsState {}

class HeartRateLoading extends BluethoothInteractionsState {}

class HeartRateDataReceived extends BluethoothInteractionsState {
  final CombinedHealthData combinedHealthData;

  const HeartRateDataReceived(this.combinedHealthData);

  @override
  List<Object> get props => [combinedHealthData];
}

class HeartRateError extends BluethoothInteractionsState {
  final String message;

  const HeartRateError({required this.message});

  @override
  List<Object> get props => [message];
}

class HeartRateDataSent extends BluethoothInteractionsState {}

class BloodOxygenDataReceived extends BluethoothInteractionsState {
  final List<dynamic> bloodOxygenData;

  const BloodOxygenDataReceived(this.bloodOxygenData);
}

class SleepDataLoading extends BluethoothInteractionsState {}

class SleepDataReceived extends BluethoothInteractionsState {
  final List<SleepData> sleepData;

  const SleepDataReceived(this.sleepData);

  @override
  List<Object> get props => [sleepData];
}

class SleepDataError extends BluethoothInteractionsState {
  final String message;

  const SleepDataError({required this.message});

  @override
  List<Object> get props => [message];
}

class CombinedDataLoading extends BluethoothInteractionsState {
  const CombinedDataLoading();
}

class CombinedDataReceived extends BluethoothInteractionsState {
  final CombinedHealthData healthData;
  final List<SleepData> sleepData;

  const CombinedDataReceived({
    required this.healthData,
    required this.sleepData,
  });

  @override
  List<Object> get props => [healthData, sleepData];
}

class NoHealthDataAvailable extends BluethoothInteractionsState {
  final String message;
  const NoHealthDataAvailable({this.message = 'No health data available'});

  @override
  List<Object> get props => [message];
}

class NoSleepDataAvailable extends BluethoothInteractionsState {
  final String message;
  const NoSleepDataAvailable({this.message = 'No sleep data available'});

  @override
  List<Object> get props => [message];
}

class BatteryLevelLoading extends BluethoothInteractionsState {}

class BatteryLevelReceived extends BluethoothInteractionsState {
  final int batteryLevel;

  const BatteryLevelReceived(this.batteryLevel);

  @override
  List<Object> get props => [batteryLevel];
}

class BatteryLevelError extends BluethoothInteractionsState {
  final String message;

  const BatteryLevelError({required this.message});

  @override
  List<Object> get props => [message];
}

class MeasurementFinished extends BluethoothInteractionsState {
  final int heartBeat;

  const MeasurementFinished(this.heartBeat);
  @override
  List<Object> get props => []; // Change to List<Object>
}

// Add to states
class MeasurementStarted extends BluethoothInteractionsState {
  @override
  List<Object> get props => []; // Change to List<Object>
}

class MeasurementError extends BluethoothInteractionsState {
  final String message;

  const MeasurementError(this.message);

  @override
  List<Object> get props => [message]; // Change to List<Object>
}

class LifeExpectancyCalculated extends BluethoothInteractionsState {
  final double lifeExpectancy;

  const LifeExpectancyCalculated(this.lifeExpectancy);

  @override
  List<Object> get props => [lifeExpectancy];
}
