import 'package:health_ring_ai/core/models/blood_oxygen_data.dart';
import 'package:health_ring_ai/core/models/heart_rate_data.dart';

class CombinedHealthData {
  final List<HeartRateData> heartRateData;
  final List<BloodOxygenData> bloodOxygenData;

  CombinedHealthData({
    required this.heartRateData,
    required this.bloodOxygenData,
  });

  factory CombinedHealthData.fromJson(Map<String, dynamic> json) {
    return CombinedHealthData(
      heartRateData: (json['heartRateData'] as List)
          .map((data) => HeartRateData.fromJson(data))
          .toList(),
      bloodOxygenData: (json['bloodOxygenData'] as List)
          .map((data) => BloodOxygenData.fromJson(data))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'heartRateData': heartRateData.map((data) => data.toJson()).toList(),
        'bloodOxygenData':
            bloodOxygenData.map((data) => data.toJson()).toList(),
      };
}
