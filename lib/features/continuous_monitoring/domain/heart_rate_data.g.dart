// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heart_rate_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HeartRateDataAdapter extends TypeAdapter<HeartRateData> {
  @override
  final int typeId = 2;

  @override
  HeartRateData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HeartRateData(
      date: fields[0] as String,
      heartRates: (fields[1] as List).cast<int>(),
      secondInterval: fields[2] as int,
      deviceId: fields[3] as String,
      deviceType: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HeartRateData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.heartRates)
      ..writeByte(2)
      ..write(obj.secondInterval)
      ..writeByte(3)
      ..write(obj.deviceId)
      ..writeByte(4)
      ..write(obj.deviceType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeartRateDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
