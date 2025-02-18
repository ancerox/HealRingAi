import 'package:hive/hive.dart';

part 'sleep_data.g.dart';

@HiveType(typeId: 4) // Unique type ID for Hive
class SleepData {
  @HiveField(0)
  final int type;

  @HiveField(1)
  final String typeString;

  @HiveField(2)
  final String startTime;

  @HiveField(3)
  final String endTime;

  @HiveField(4)
  final int durationMinutes;

  SleepData({
    required this.type,
    required this.typeString,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
  });

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      type: json['type'] as int,
      typeString: json['typeString'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      durationMinutes: json['durationMinutes'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'typeString': typeString,
        'startTime': startTime,
        'endTime': endTime,
        'durationMinutes': durationMinutes,
      };
}
