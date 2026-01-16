import '../models/recipe.dart';
import '../models/food.dart';
import '../models/nutrition_summary.dart';
import 'recipe_nutrition_calculator.dart';

class DayNutritionCalculator {
  /// Calculates total nutrition for a single day
  /// [recipes] = meals eaten in the day
  /// [foodMap] = foodId -> Food
  static NutritionSummary calculate(
    List<Recipe> recipes,
    Map<String, Food> foodMap,
  ) {
    final daySummary = NutritionSummary();

    for (final recipe in recipes) {
      final recipeSummary = RecipeNutritionCalculator.calculate(
        recipe,
        foodMap,
      );

      daySummary.add(recipeSummary);
    }

    return daySummary;
  }
}
