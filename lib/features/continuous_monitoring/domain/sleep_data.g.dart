// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepDataAdapter extends TypeAdapter<SleepData> {
  @override
  final int typeId = 4;

  @override
  SleepData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepData(
      type: fields[0] as int,
      typeString: fields[1] as String,
      startTime: fields[2] as String,
      endTime: fields[3] as String,
      durationMinutes: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SleepData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.typeString)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.durationMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
