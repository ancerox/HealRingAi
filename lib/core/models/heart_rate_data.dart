class HeartRateData {
  final String date;
  final List<int> heartRates;
  final int secondInterval;
  final String deviceId;
  final String deviceType;

  HeartRateData({
    required this.date,
    required this.heartRates,
    required this.secondInterval,
    required this.deviceId,
    required this.deviceType,
  });

  factory HeartRateData.fromJson(Map<String, dynamic> json) {
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
}
