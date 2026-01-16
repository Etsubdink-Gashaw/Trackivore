import '../models/recipe.dart';
import '../models/food.dart';
import '../models/nutrition_summary.dart';

class RecipeNutritionCalculator {
  /// Assumes nutrient.amount is per 100g
  static NutritionSummary calculate(Recipe recipe, Map<String, Food> foodMap) {
    final summary = NutritionSummary();

    for (final ingredient in recipe.ingredients) {
      final food = foodMap[ingredient.foodId];
      if (food == null) continue;

      final multiplier = ingredient.quantity / 100;

      for (final nutrient in food.nutrients) {
        final value = nutrient.amount * multiplier;

        switch (nutrient.name) {
          case 'Calories':
            summary.calories += value;
            break;
          case 'Protein':
            summary.protein += value;
            break;
          case 'Carbohydrates':
            summary.carbs += value;
            break;
          case 'Fat':
            summary.fat += value;
            break;
          case 'Fiber':
            summary.fiber += value;
            break;
        }
      }
    }

    return summary;
  }
}
