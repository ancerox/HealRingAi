import 'package:equatable/equatable.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/blood_oxygen_data.dart';
import 'package:health_ring_ai/features/continuous_monitoring/domain/heart_rate_data.dart';
import 'package:hive/hive.dart';

part 'combined_health_data.g.dart';

@HiveType(typeId: 1) // Unique type ID for Hive
class CombinedHealthData extends Equatable {
  @HiveField(0)
  final List<HeartRateData> heartRateData;

  @HiveField(1)
  final List<BloodOxygenData> bloodOxygenData;

  const CombinedHealthData({
    required this.heartRateData,
    required this.bloodOxygenData,
  });

  @override
  List<Object?> get props => [heartRateData, bloodOxygenData];

  double? get averageHeartRate {
    if (heartRateData.isEmpty) return null;
    final nonZeroRates = heartRateData
        .expand((data) => data.heartRates)
        .where((rate) => rate > 0)
        .toList();
    if (nonZeroRates.isEmpty) return null;
    return nonZeroRates.reduce((a, b) => a + b) / nonZeroRates.length;
  }

  double? get averageSpO2 {
    if (bloodOxygenData.isEmpty) return null;
    final validReadings = bloodOxygenData
        .where((data) => data.bloodOxygenLevels.first > 0)
        .map((data) => data.bloodOxygenLevels.first)
        .toList();
    if (validReadings.isEmpty) return null;
    return validReadings.reduce((a, b) => a + b) / validReadings.length;
  }

  factory CombinedHealthData.fromJson(Map<dynamic, dynamic> json) {
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
