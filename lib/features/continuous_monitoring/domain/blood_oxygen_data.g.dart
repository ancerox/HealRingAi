// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_oxygen_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BloodOxygenDataAdapter extends TypeAdapter<BloodOxygenData> {
  @override
  final int typeId = 3;

  @override
  BloodOxygenData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BloodOxygenData(
      date: fields[0] as double,
      bloodOxygenLevels: (fields[1] as List).cast<double>(),
      secondInterval: fields[2] as int,
      deviceId: fields[3] as String,
      deviceType: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BloodOxygenData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.bloodOxygenLevels)
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
      other is BloodOxygenDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
