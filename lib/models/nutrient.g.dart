// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutrientAdapter extends TypeAdapter<Nutrient> {
  @override
  final int typeId = 1;

  @override
  Nutrient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Nutrient(
      name: fields[0] as String,
      amount: fields[1] as double,
      unit: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Nutrient obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutrientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
