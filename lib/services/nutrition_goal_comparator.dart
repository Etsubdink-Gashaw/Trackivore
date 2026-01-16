import '../models/nutrition_goal.dart';
import '../models/nutrition_summary.dart';
import '../models/nutrition_comparison.dart';

class NutritionGoalComparator {
  static NutritionComparison compare(
    NutritionSummary consumed,
    NutritionGoal goal,
  ) {
    final remaining = NutritionSummary()
      ..calories = goal.calories - consumed.calories
      ..protein = goal.protein - consumed.protein
      ..carbs = goal.carbs - consumed.carbs
      ..fat = goal.fat - consumed.fat
      ..fiber = goal.fiber - consumed.fiber;

    return NutritionComparison(consumed: consumed, remaining: remaining);
  }
}
