import 'package:hive/hive.dart';
import 'recipe_ingredient.dart';

part 'recipe.g.dart';

@HiveType(typeId: 4)
class Recipe {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<RecipeIngredient> ingredients;
  // final int servings;

  //@HiveField(3)
  //final List<RecipeIngredient> ingredients;

  Recipe({
    required this.id,
    required this.name,
    //required this.servings,
    required this.ingredients,
  });
}
