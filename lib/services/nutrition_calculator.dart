import '../models/food.dart';
import '../models/nutrition_summary.dart';

class NutritionCalculator {
  static NutritionSummary fromFood(Food food, double multiplier) {
    final summary = NutritionSummary();

    for (final n in food.nutrients) {
      final value = n.amount * multiplier;

      switch (n.name) {
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

    return summary;
  }
}
