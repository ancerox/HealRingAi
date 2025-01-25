part of 'bluethooth_interactions_bloc.dart';

abstract class BluethoothInteractionsState extends Equatable {
  const BluethoothInteractionsState();

  @override
  List<Object> get props => [];
}

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
