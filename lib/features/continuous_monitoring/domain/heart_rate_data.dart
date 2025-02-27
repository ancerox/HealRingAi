import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'heart_rate_data.g.dart';

@HiveType(typeId: 2)
class HeartRateData extends Equatable {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final List<int> heartRates;

  @HiveField(2)
  final int secondInterval;

  @HiveField(3)
  final String deviceId;

  @HiveField(4)
  final String deviceType;

  const HeartRateData({
    required this.date,
    required this.heartRates,
    required this.secondInterval,
    required this.deviceId,
    required this.deviceType,
  });

  factory HeartRateData.fromJson(Map<dynamic, dynamic> json) {
    return HeartRateData(
      date: json['date'] as String,
      heartRates: (json['heartRates'] as List).cast<int>(),
      secondInterval: json['secondInterval'] as int,
      deviceId: json['deviceId'] as String? ?? '',
      deviceType: json['deviceType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'heartRates': heartRates,
        'secondInterval': secondInterval,
        'deviceId': deviceId,
        'deviceType': deviceType,
      };

  @override
  String toString() {
    return 'HeartRateData(date: $date, heartRates: ${heartRates.length} readings, secondInterval: $secondInterval, deviceId: $deviceId, deviceType: $deviceType)';
  }

  @override
  List<Object?> get props =>
      [date, heartRates, secondInterval, deviceId, deviceType];
}
