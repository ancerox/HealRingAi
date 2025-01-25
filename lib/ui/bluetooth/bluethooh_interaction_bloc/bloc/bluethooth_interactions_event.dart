part of 'bluethooth_interactions_bloc.dart';

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

class HeartRateDataLoading extends BluethoothInteractionsEvent {}

class GetBloodOxygenData extends BluethoothInteractionsEvent {
  final int dayIndex;

  const GetBloodOxygenData({required this.dayIndex});

  @override
  List<Object> get props => [dayIndex];
}
