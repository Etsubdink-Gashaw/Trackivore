// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_ingredient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeIngredientAdapter extends TypeAdapter<RecipeIngredient> {
  @override
  final int typeId = 3;

  @override
  RecipeIngredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeIngredient(
      foodId: fields[0] as String,
      quantity: fields[1] as double,
      unit: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeIngredient obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.foodId)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeIngredientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
