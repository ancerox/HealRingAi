class BloodOxygenData {
  final double date;
  final List<double> bloodOxygenLevels;
  final int secondInterval;
  final String deviceId;
  final String deviceType;

  BloodOxygenData({
    required this.date,
    required this.bloodOxygenLevels,
    required this.secondInterval,
    required this.deviceId,
    required this.deviceType,
  });

  factory BloodOxygenData.fromJson(Map<String, dynamic> json) {
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
}
