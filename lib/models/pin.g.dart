// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PinAdapter extends TypeAdapter<Pin> {
  @override
  final int typeId = 2;

  @override
  Pin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pin(
      hashedPin: fields[0] as String,
      createdAt: fields[1] as DateTime,
      updatedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Pin obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.hashedPin)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
