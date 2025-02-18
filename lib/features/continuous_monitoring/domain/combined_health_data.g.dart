// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combined_health_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CombinedHealthDataAdapter extends TypeAdapter<CombinedHealthData> {
  @override
  final int typeId = 1;

  @override
  CombinedHealthData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CombinedHealthData(
      heartRateData: (fields[0] as List).cast<HeartRateData>(),
      bloodOxygenData: (fields[1] as List).cast<BloodOxygenData>(),
    );
  }

  @override
  void write(BinaryWriter writer, CombinedHealthData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.heartRateData)
      ..writeByte(1)
      ..write(obj.bloodOxygenData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombinedHealthDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
