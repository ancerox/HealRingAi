class SleepData {
  final int type;
  final String typeString;
  final String startTime;
  final String endTime;
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
}
