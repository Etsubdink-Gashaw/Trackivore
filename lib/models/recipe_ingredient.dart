import 'package:hive/hive.dart';

part 'recipe_ingredient.g.dart';

@HiveType(typeId: 3)
class RecipeIngredient {
  @HiveField(0)
  final String foodId;

  @HiveField(1)
  final double quantity;

  @HiveField(2)
  final String unit; // g, ml, pcs, etc

  RecipeIngredient({
    required this.foodId,
    required this.quantity,
    required this.unit,
  });
}
