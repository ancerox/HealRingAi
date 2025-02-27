import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'blood_oxygen_data.g.dart';

@HiveType(typeId: 3) // Unique type ID for Hive
class BloodOxygenData extends Equatable {
  @HiveField(0)
  final double date;

  @HiveField(1)
  final List<double> bloodOxygenLevels;

  @HiveField(2)
  final int secondInterval;

  @HiveField(3)
  final String deviceId;

  @HiveField(4)
  final String deviceType;

  const BloodOxygenData({
    required this.date,
    required this.bloodOxygenLevels,
    required this.secondInterval,
    required this.deviceId,
    required this.deviceType,
  });

  factory BloodOxygenData.fromJson(Map<dynamic, dynamic> json) {
    return BloodOxygenData(
      date: json['date'] as double,
      bloodOxygenLevels: (json['bloodOxygenLevels'] as List).cast<double>(),
      secondInterval: json['secondInterval'] as int,
      deviceId: json['deviceId'] as String? ?? '',
      deviceType: json['deviceType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'bloodOxygenLevels': bloodOxygenLevels,
        'secondInterval': secondInterval,
        'deviceId': deviceId,
        'deviceType': deviceType,
      };

  @override
  List<Object?> get props =>
      [date, bloodOxygenLevels, secondInterval, deviceId, deviceType];
}
